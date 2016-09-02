{$INCLUDE SaGe.inc}

//{$DEFINE OPENAL_RENDER_DEBUG}

{$IF defined(DESKTOP)}
	{$DEFINE USE_OGG}
	{$ENDIF}

{$IF defined(MSWINDOWS) and defined(DESKTOP)}
		{$DEFINE USE_MPG123}
		{$ENDIF}

unit SaGeAudioRenderOpenAL;

interface

uses
	// Engine
	 SaGeBase
	,SaGeBased
	,SaGeClasses
	,SaGeCommon
	,SaGeAudioRender

	// System
	,Classes

	// Audio Library
	,OpenAL

	// Codecs :
		(* ogg *)
	{$IFDEF USE_OGG}
	,Ogg
	,Codec
	,CommentUtils
	,OSTypes
	,VCEdit
	,VorbisEnc
	,VorbisFile
	{$ENDIF}

		(* mp3 and etc *)
	{$IFDEF USE_MPG123}
	,mpg123
	{$ENDIF}
	;

type
	TSGALSource = TALuint;
	TSGALBuffer = TALuint;

	TSGOpenALBufferInfo = object
			public
		FFrequency   : TALsizei;
		FLoop   : TALint;
			public
		procedure Clear();
		end;

	TSGOpenALBuffer = object(TSGOpenALBufferInfo)
			public
		FBuffer : TSGALBuffer;
			public
		procedure Clear();
			public
		procedure DeleteBuffer();
		end;

	TSGOpenALSource = object(TSGOpenALBuffer)
			public
		FSource : TSGALSource;
			public
		procedure Clear();
			public
		procedure Play();
		procedure Pause();
		procedure Stop();
		procedure DeleteSource();
		procedure Looping(const VLoop : TSGBool);
		function State() : TALint;
		end;

	TSGOpenALTrack = object(TSGOpenALBufferInfo)
			public
		FFormat : TALenum;
		FData   : TALvoid;
		FSize   : TALsizei;
			public
		procedure Clear();
		function Assigned() : TSGBool;
		end;

	{$IFDEF USE_MPG123}
	TSGOpenALMP3 = class(TSGThread)
			public
		constructor Create(const FilePath: TSGString);
		destructor Destroy(); override;
			protected
		FMaxBufferSize : TSGMaxEnum;
		FSource   : TSGALSource;
		FBuffers  : array[0..1] of TSGALBuffer;
		FFormat   : TALenum;
		FFileName : TSGString;
		FMPGHandle   : PMPG123_Handle;
		FRate     : Integer;
		FChannels : Integer;
		FEncoding : Integer;
		FPlaying  : TSGBool;
			protected
		procedure UpdateBuffer();
		procedure PreBuffer();
		procedure Stream(const VBuffer : TSGALBuffer);
			public
		procedure Execute(); override;
		procedure Play();
		procedure Stop();
		end;
	{$ENDIF}

type
	TSGAudioRenderOpenAL = class(TSGAudioRender)
			public
		constructor Create(); override;
		class function Suppored() : TSGBool; override;
		class function ClassName() : TSGString; override;
			private
		{$IFDEF USE_MPG123}
			FMPG123Suppored : TSGBool;
			FMPG123Initialized : TSGBool;
			{$ENDIF}
		FALUTSuppored : TSGBool;
			private
		FContext      : PALCcontext;
		FDevice       : PALCdevice;
			public
		procedure Init(); override;
		function CreateDevice() : TSGBool; override;
		procedure Kill(); override;
			protected
		function LoadWAVFromFile(const VFileName : TSGString) : TSGOpenALTrack;
		function LoadWAVFromStream(const VStream : TStream) : TSGOpenALTrack;
		procedure UnloadTrack(var VTrack : TSGOpenALTrack);
		function CreateBuffer(VTrack : TSGOpenALTrack; const VUnloadTrack : TSGBool = True) : TSGOpenALBuffer;
		function CreateSource(const VBuffer : TSGOpenALBuffer) : TSGOpenALSource;
		end;

implementation

uses
	SaGeDllManager
	{$IFDEF USE_MPG123}
	,Windows
	{$ENDIF}
	;

{$IFDEF USE_MPG123}
destructor TSGOpenALMP3.Destroy();
begin
alSourceStop(FSource);
alDeleteSources(1, @FSource);
alDeleteBuffers(1, @FBuffers);
mpg123_close(FMPGHandle);
inherited;
end;

procedure TSGOpenALMP3.Execute();
var
	Critical : TRTLCriticalSection;
begin
InitializeCriticalSection(Critical);
while FPlaying do
	begin
	EnterCriticalSection(Critical);
	UpdateBuffer();
	LeaveCriticalSection(Critical);
	Sleep(50);
	end;
DeleteCriticalSection(Critical);
end;

constructor TSGOpenALMP3.Create(const FilePath: TSGString);
begin
inherited Create(nil, nil, False);
FFileName := FilePath;
FMaxBufferSize := 4096*8;

FMPGHandle := mpg123_new('MMX', nil); //TODO: make this a property. MMX is common
if FMPGHandle = nil then
	begin
	SGLog.Sourse('TSGOpenALMP3 : Error while creating MP3 handle!');
	Exit;
	end;

mpg123_open(FMPGHandle, PChar(FFileName));
mpg123_getformat(FMPGHandle, @FRate, @FChannels, @FEncoding);
mpg123_format_none(FMPGHandle);
mpg123_format(FMPGHandle, FRate, FChannels, FEncoding);

FFormat := AL_FORMAT_STEREO16; //TODO: this should be determined from mp3 file
alGenBuffers(2, @FBuffers);
alGenSources(1, @FSource);
alSource3f(FSource, AL_POSITION, 0, 0, 0);
alSource3f(FSource, AL_VELOCITY, 0, 0, 0);
alSource3f(FSource, AL_DIRECTION, 0, 0, 0);
alSourcef (FSource, AL_ROLLOFF_FACTOR, 0);
alSourcei (FSource, AL_SOURCE_RELATIVE, AL_TRUE);
end;

procedure TSGOpenALMP3.UpdateBuffer();
var
 Processed : TALint;
 Buffer    : TALUInt;
begin
//TODO: detect end of mp3
alGetSourcei(FSource, AL_BUFFERS_PROCESSED, @Processed);
if Processed > 0 then
	repeat
	alSourceUnqueueBuffers(FSource, 1, @Buffer);
	Stream(Buffer);
	alSourceQueueBuffers(FSource, 1, @Buffer);
	dec(Processed);
	until Processed <= 0;
end;

procedure TSGOpenALMP3.PreBuffer();
begin
Stream(FBuffers[0]);
Stream(FBuffers[1]);
alSourceQueueBuffers(FSource, 2, @FBuffers);
end;

procedure TSGOpenALMP3.Stream(const VBuffer : TSGALBuffer);
var
  Data : PByte;
  D    : Cardinal;
begin
  GetMem(data, FMaxBufferSize);
  mpg123_read(FMPGHandle, Data, FMaxBufferSize, @D);
  alBufferData(VBuffer, FFormat, Data, FMaxBufferSize, FRate);
  FreeMem(Data);
end;

procedure TSGOpenALMP3.Play();
begin
PreBuffer();
FPlaying := True;
Start();
alSourcePlay(FSource);
end;

procedure TSGOpenALMP3.Stop();
begin
FPlaying := False;
alSourceStop(FSource);
end;
{$ENDIF}

procedure TSGOpenALBuffer.DeleteBuffer();
begin
AlDeleteBuffers(1, @FBuffer);
FBuffer := 0;
end;

function TSGOpenALSource.State() : TALint;
begin
alGetSourcei( FSource, AL_SOURCE_STATE, @Result);
end;

procedure TSGOpenALSource.Looping(const VLoop : TSGBool);
begin
if VLoop then
	AlSourcei ( FSource, AL_LOOPING, AL_TRUE )
else
	AlSourcei ( FSource, AL_LOOPING, FLoop );
end;

procedure TSGOpenALSource.DeleteSource();
begin
AlDeleteSources(1, @FSource);
FSource := 0;
end;

procedure TSGOpenALSource.Play();
begin
AlSourcePlay(FSource);
end;

procedure TSGOpenALSource.Pause();
begin
AlSourcePause(FSource);
end;

procedure TSGOpenALSource.Stop();
begin
AlSourceStop(FSource);
end;

function TSGAudioRenderOpenAL.CreateSource(const VBuffer : TSGOpenALBuffer) : TSGOpenALSource;
var
	sourcepos: array [0..2] of TALfloat= ( 0.0, 0.0, 0.0 );
	sourcevel: array [0..2] of TALfloat= ( 0.0, 0.0, 0.0 );
begin
Result.Clear();
TSGOpenALBuffer(Result) := VBuffer;
alGenSources(1, @Result.FSource);
alSourcei  ( Result.FSource, AL_BUFFER,   VBuffer.FBuffer);
alSourcef  ( Result.FSource, AL_PITCH,    1.0 );
alSourcef  ( Result.FSource, AL_GAIN,     1.0 );
alSourcefv ( Result.FSource, AL_POSITION, @sourcepos);
alSourcefv ( Result.FSource, AL_VELOCITY, @sourcevel);
alSourcei  ( Result.FSource, AL_LOOPING,  Result.FLoop);
end;

function TSGAudioRenderOpenAL.CreateBuffer(VTrack : TSGOpenALTrack; const VUnloadTrack : TSGBool = True) : TSGOpenALBuffer;
begin
Result.Clear();
TSGOpenALBufferInfo(Result) := TSGOpenALBufferInfo(VTrack);
alGenBuffers(1, @Result.FBuffer);
alBufferData(Result.FBuffer, VTrack.FFormat, VTrack.FData, VTrack.FSize, VTrack.FFrequency);
if VUnloadTrack then
	UnloadTrack(VTrack);
end;

function TSGAudioRenderOpenAL.LoadWAVFromFile(const VFileName : TSGString) : TSGOpenALTrack;
begin
Result.Clear();
if FALUTSuppored and (ext_alutLoadWAVFile <> nil) then
	ext_alutLoadWAVFile(VFileName, Result.FFormat, Result.FData, Result.FSize, Result.FFrequency, Result.FLoop);
if not Result.Assigned() then
	Result.Clear();
if not Result.Assigned() then
	int_alutLoadWAVFile(VFileName, Result.FFormat, Result.FData, Result.FSize, Result.FFrequency, Result.FLoop);
if not Result.Assigned() then
	Result.Clear();
end;

function TSGAudioRenderOpenAL.LoadWAVFromStream(const VStream : TStream) : TSGOpenALTrack;
var
	Memory : PALbyte = nil;
begin
Result.Clear();
if FALUTSuppored and (ext_alutLoadWAVMemory <> nil) then
	begin
	Memory := GetMem(VStream.Size);
	VStream.Position := 0;
	VStream.WriteBuffer(Memory^, VStream.Size);
	ext_alutLoadWAVMemory(Memory, Result.FFormat, Result.FData, Result.FSize, Result.FFrequency, Result.FLoop);
	FreeMem(Memory);
	Memory := nil;
	VStream.Position := 0;
	end;
if not Result.Assigned() then
	Result.Clear();
if not Result.Assigned() then
	if not int_LoadWavStream(VStream, Result.FFormat, Result.FData, Result.FSize, Result.FFrequency, Result.FLoop) then
		UnloadTrack(Result);
if not Result.Assigned() then
	Result.Clear();
end;

procedure TSGAudioRenderOpenAL.UnloadTrack(var VTrack : TSGOpenALTrack);
begin
if FALUTSuppored and (ext_alutUnloadWAV <> nil) then
	ext_alutUnloadWAV(VTrack.FFormat, VTrack.FData, VTrack.FSize, VTrack.FFrequency)
else
	int_alutUnloadWAV(VTrack.FFormat, VTrack.FData, VTrack.FSize, VTrack.FFrequency);
VTrack.FData := nil;
end;

function TSGOpenALTrack.Assigned() : TSGBool;
begin
Result := FData <> nil;
end;

procedure TSGOpenALSource.Clear();
begin
FSource := 0;
inherited;
end;

procedure TSGOpenALBuffer.Clear();
begin
FBuffer := 0;
inherited;
end;

procedure TSGOpenALBufferInfo.Clear();
begin
FFrequency   := 0;
FLoop        := 0;
end;

procedure TSGOpenALTrack.Clear();
begin
FFormat := 0;
FData   := nil;
FSize   := 0;
inherited;
end;

procedure TSGAudioRenderOpenAL.Init();
var
	ListenerPos: array [0..2] of TALfloat= ( 0.0, 0.0, 0.0);
	ListenerVel: array [0..2] of TALfloat= ( 0.0, 0.0, 0.0);
	ListenerOri: array [0..5] of TALfloat= ( 0.0, 0.0, -1.0, 0.0, 1.0, 0.0);
begin
if DllManager.Dll('OpenAL') <> nil then
	DllManager.Dll('OpenAL').ReadExtensions();

{$IFDEF USE_MPG123}
if not FMPG123Initialized then
	begin
	FMPG123Initialized := mpg123_init() = 0;
	SGLog.Sourse('TSGAudioRenderOpenAL : MPG123 : ' + Iff(FMPG123Initialized, 'Initialized.', 'Initialization fail.'));
	end;
{$ENDIF}

alListenerfv(AL_POSITION,    @ListenerPos);
alListenerfv(AL_VELOCITY,    @ListenerVel);
alListenerfv(AL_ORIENTATION, @ListenerOri);

//Test :
//CreateSource(CreateBuffer(LoadWAVFromFile('./../../Sounds/SystemBass.wav'))).Play();
//{$IFDEF USE_MPG123} TSGOpenALMP3.Create('./../../Sounds/Test.mp3').Play(); {$ENDIF}
end;

function TSGAudioRenderOpenAL.CreateDevice() : TSGBool;
begin
Result := False;
if not FALUTSuppored then
	int_alutInit()
else
	ext_alutInit(nil, nil);

FContext := alcGetCurrentContext();
if FContext <> nil then
	FDevice := alcGetContextsDevice(FContext);

Result := (FContext <> nil) and (FDevice <> nil);

SGLog.Sourse('TSGAudioRenderOpenAL : Context = ' + SGAddrStr(FContext) + ', Device = ' + SGAddrStr(FDevice) + '.');
end;

procedure TSGAudioRenderOpenAL.Kill();
begin
{$IFDEF USE_MPG123}
if FMPG123Initialized then
	begin
	mpg123_exit();
	FMPG123Initialized := False;
	end;
{$ENDIF}
if not FALUTSuppored then
	int_alutExit()
else
	ext_alutExit();
FContext := nil;
FDevice := nil;
inherited;
end;

constructor TSGAudioRenderOpenAL.Create();
begin
inherited;
FALUTSuppored := DllManager.Suppored('alut');
FContext := nil;
FDevice := nil;
{$IFDEF USE_MPG123}
FMPG123Suppored := DllManager.Suppored('mpg123');
FMPG123Initialized := False;
{$ENDIF}
end;

class function TSGAudioRenderOpenAL.ClassName() : TSGString;
begin
Result := 'TSGAudioRenderOpenAL';
end;

class function TSGAudioRenderOpenAL.Suppored() : TSGBool;
begin
Result := DllManager.Suppored('OpenAL');
end;

end.
