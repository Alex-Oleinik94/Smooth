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
	TSGALFormat = TALenum;

	TSGOpenALBufferInfo = object
			public
		FFrequency   : TALsizei;
		FLoop        : TALint;
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
	TSGOpenALMP123FilePlayer = class(TSGThread)
			public
		constructor Create(const FilePath: TSGString);
		destructor Destroy(); override;
			protected
		FMaxBufferSize : TSGMaxEnum;
		FSource   : TSGALSource;
		FBuffers  : array[0..1] of TSGALBuffer;
		FFormat   : TALenum;
		FFileName : TSGString;
		FMPGHandle: PMPG123_Handle;
		FMPGInfo  : Tmpg123_frameinfo;
		FRate     : Integer;
		FChannels : Integer;
		FEncoding : Integer;
		FPlaying  : TSGBool;
			protected
		function UpdateBuffer() : TSGBool;
		procedure PreBuffer();
		function Stream(const VBuffer : TSGALBuffer) : TSGUInt64;
			public
		procedure Execute(); override;
		procedure Play();
		procedure Stop();
			public
		property Playing : TSGBool read FPlaying;
		end;
	{$ENDIF}

type
	TSGAudioRenderOpenALFileSource = class(TSGAudioRenderFileSource)
			public
		constructor Create(const VAudioRender : TSGAudioRender); override;
		class function ClassName() : TSGString; override;
			private
		{$IFDEF USE_MPG123}
		FMPG123Player : TSGOpenALMP123FilePlayer;
		{$ENDIF}
		{$IFDEF USE_OGG}
		{$ENDIF}
		FWav : packed record
			FTrack  : TSGOpenALTrack;
			FBuffer : TSGOpenALBuffer;
			FSource : TSGOpenALSource;
			end;
		FExpansion : TSGString;
			protected
		function GetEnded() : TSGBool; override;
		procedure SetFile(const VFileName : TSGString); override;
			public
		procedure Play(); override;
		end;

	TSGAudioRenderOpenAL = class(TSGAudioRender)
			public
		constructor Create(); override;
		class function Suppored() : TSGBool; override;
		class function ClassName() : TSGString; override;
		class function SupporedAudioFormats() : TSGStringList; override;
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
		function CreateFileSource(const VFileName : TSGString) : TSGAudioRenderFileSource; override;
			public
		{$IFDEF USE_MPG123}
		function SupporedMPG123() : TSGBool;
		{$ENDIF}
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

constructor TSGAudioRenderOpenALFileSource.Create(const VAudioRender : TSGAudioRender);
begin
inherited Create(VAudioRender);
{$IFDEF USE_MPG123}
FMPG123Player := nil;
{$ENDIF}
FExpansion := '';
FWav.FTrack.Clear();
FWav.FBuffer.Clear();
FWav.FSource.Clear();
end;

class function TSGAudioRenderOpenALFileSource.ClassName() : TSGString;
begin
Result := 'TSGAudioRenderOpenALFileSource';
end;

function TSGAudioRenderOpenALFileSource.GetEnded() : TSGBool;
begin
Result := True;
if (FExpansion = 'WAV') then
	begin
	Result := not (FWav.FSource.State() = AL_PLAYING)
	end
{$IFDEF USE_MPG123}
else if FExpansion = 'MP3' then
	begin
	Result := not FMPG123Player.Playing;
	end
{$ENDIF}
else
	begin
	SGLog.Sourse('TSGAudioRenderOpenALFileSource - GetEnded():TSGBool - Unknown expansion(''' + FExpansion + ''')!');
	end;
end;

procedure TSGAudioRenderOpenALFileSource.SetFile(const VFileName : TSGString);
begin
inherited SetFile(VFileName);
FExpansion := SGGetFileExpansion(FFileName);
if (FExpansion = 'WAV') and ((AudioRender as TSGAudioRenderOpenAL) <> nil) then
	begin
	FWav.FTrack := (AudioRender as TSGAudioRenderOpenAL).LoadWAVFromFile(FFileName);
	FWav.FBuffer := (AudioRender as TSGAudioRenderOpenAL).CreateBuffer(FWav.FTrack);
	FWav.FSource := (AudioRender as TSGAudioRenderOpenAL).CreateSource(FWav.FBuffer);
	end
{$IFDEF USE_MPG123}
else if (FExpansion = 'MP3') and AudioRenderAssigned() and ((AudioRender as TSGAudioRenderOpenAL) <> nil) and (AudioRender as TSGAudioRenderOpenAL).SupporedMPG123 then
	begin
	FMPG123Player := TSGOpenALMP123FilePlayer.Create(FFileName);
	end
{$ENDIF}
else
	begin
	SGLog.Sourse('TSGAudioRenderOpenALFileSource - SetFile(''' + VFileName + ''') - Unknown expansion(''' + FExpansion + ''')!');
	FExpansion := '';
	end;
end;

procedure TSGAudioRenderOpenALFileSource.Play();
begin
if FExpansion = 'WAV' then
	begin
	if FWav.FSource.FSource <> 0 then
		FWav.FSource.Play()
	else
		SGLog.Sourse('TSGAudioRenderOpenALFileSource - Play() - Expansion=''' + FExpansion + ''', but FWav.FSourceis not assigned!');
	end
{$IFDEF USE_MPG123}
else if FExpansion = 'MP3' then
	begin
	if FMPG123Player <> nil then
		FMPG123Player.Play()
	else
		SGLog.Sourse('TSGAudioRenderOpenALFileSource - Play() - Expansion=''' + FExpansion + ''', but FMPG123Player = nil!');
	end
{$ENDIF}
else
	begin
	SGLog.Sourse('TSGAudioRenderOpenALFileSource - Play() - Unknown expansion(''' + FExpansion + ''')!');
	end;
end;

function TSGAudioRenderOpenAL.CreateFileSource(const VFileName : TSGString) : TSGAudioRenderFileSource;
begin
Result := TSGAudioRenderOpenALFileSource.Create(Self);
Result.FileName := VFileName;
end;

{$IFDEF USE_MPG123}
function TSGAudioRenderOpenAL.SupporedMPG123() : TSGBool;
begin
Result := FMPG123Suppored and FMPG123Initialized;
end;
{$ENDIF}

class function TSGAudioRenderOpenAL.SupporedAudioFormats() : TSGStringList;
begin
Result := nil;
Result += 'wav';
{$IFDEF USE_MPG123}
if DllManager.Suppored('mpg123') then
	Result += 'mp3';
{$ENDIF}
{$IFDEF USE_OGG}
if DllManager.Suppored('ogg') then
	Result += 'ogg';
{$ENDIF}
end;

{$IFDEF USE_MPG123}
destructor TSGOpenALMP123FilePlayer.Destroy();
begin
alSourceStop(FSource);
alDeleteSources(1, @FSource);
alDeleteBuffers(2, @FBuffers[0]);
mpg123_close(FMPGHandle);
inherited;
end;

procedure TSGOpenALMP123FilePlayer.Execute();
var
	Critical : TRTLCriticalSection;
begin
InitializeCriticalSection(Critical);
while FPlaying do
	begin
	EnterCriticalSection(Critical);
	if not UpdateBuffer() then
		FPlaying := False;
	LeaveCriticalSection(Critical);
	if FPlaying then
		Sleep(50);
	end;
DeleteCriticalSection(Critical);
end;

constructor TSGOpenALMP123FilePlayer.Create(const FilePath: TSGString);

function StrOpenALFormat(const VFormat : TSGALFormat) : TSGString;
begin
case VFormat of
AL_FORMAT_MONO16 :
	Result := 'AL_FORMAT_MONO16';
AL_FORMAT_MONO8 :
	Result := 'AL_FORMAT_MONO8';
AL_FORMAT_STEREO16 :
	Result := 'AL_FORMAT_STEREO16';
AL_FORMAT_STEREO8 :
	Result := 'AL_FORMAT_STEREO8';
else
	Result := '?';
end;
end;

function StrMPG123Encoding(const VEncoding : integer) : TSGString;
begin
case VEncoding of
MPG123_ENC_16 :
	Result := 'MPG123_ENC_16';
MPG123_ENC_SIGNED_16 :
	Result := 'MPG123_ENC_SIGNED_16';
MPG123_ENC_UNSIGNED_16 :
	Result := 'MPG123_ENC_UNSIGNED_16';
MPG123_ENC_8 :
	Result := 'MPG123_ENC_8';
MPG123_ENC_SIGNED_8 :
	Result := 'MPG123_ENC_SIGNED_8';
MPG123_ENC_UNSIGNED_8 :
	Result := 'MPG123_ENC_UNSIGNED_8';
MPG123_ENC_ULAW_8 :
	Result := 'MPG123_ENC_ULAW_8';
MPG123_ENC_ALAW_8 :
	Result := 'MPG123_ENC_ALAW_8';
else
	Result := '?';
end;
end;

function GetMPG123AudioDecoder() : PChar;
var
	Decoders : PPChar;
begin
Decoders := mpg123_supported_decoders();
Result := nil;
if Decoders <> nil then
	if Decoders[0] <> nil then
		Result := Decoders[0];
end;

begin
inherited Create(nil, nil, False);
FFileName := FilePath;
FMaxBufferSize := 4096*8;
FillChar(FMPGInfo,SizeOf(FMPGInfo),0);

if GetMPG123AudioDecoder() = nil then
	begin
	SGLog.Sourse('TSGOpenALMP123FilePlayer : Error while determine decoder!');
	Exit;
	end;

FMPGHandle := mpg123_new(GetMPG123AudioDecoder(), nil);
if FMPGHandle = nil then
	begin
	SGLog.Sourse('TSGOpenALMP123FilePlayer : Error while creating MP3 handle!');
	Exit;
	end;

mpg123_open(FMPGHandle, PChar(FFileName));
mpg123_getformat(FMPGHandle, @FRate, @FChannels, @FEncoding);
mpg123_format_none(FMPGHandle);
mpg123_format(FMPGHandle, FRate, FChannels, FEncoding);
SGLog.Sourse('TSGOpenALMP123FilePlayer : File=''' + FilePath + ''', Encoding=''' + SGStr(FEncoding) + ''' is ''' + StrMPG123Encoding(FEncoding) + ''', Rate=''' + SGStr(FRate) + ''', Channels=''' + SGStr(FChannels) + '''.');

FFormat := 0;
case FEncoding of
MPG123_ENC_16, MPG123_ENC_SIGNED_16, MPG123_ENC_UNSIGNED_16 :
	if FChannels = MPG123_MONO then
		FFormat := AL_FORMAT_MONO16
	else if FChannels = MPG123_STEREO then
		FFormat := AL_FORMAT_STEREO16;
MPG123_ENC_8, MPG123_ENC_SIGNED_8, MPG123_ENC_UNSIGNED_8, MPG123_ENC_ULAW_8, MPG123_ENC_ALAW_8 :
	if FChannels = MPG123_MONO then
		FFormat := AL_FORMAT_MONO8
	else if FChannels = MPG123_STEREO then
		FFormat := AL_FORMAT_STEREO8;
end;
if FFormat = 0 then
	SGLog.Sourse('TSGOpenALMP123FilePlayer : - Unknown encoding(''' + SGStr(FEncoding) + ''' is ''' + StrMPG123Encoding(FEncoding) + ''')!')
else
	SGLog.Sourse('TSGOpenALMP123FilePlayer : - Format : ''' + StrMPG123Encoding(FEncoding) + ''' --> ''' + StrOpenALFormat(FFormat) + '''.');

alGenBuffers(2, @FBuffers[0]);
alGenSources(1, @FSource);
alSource3f(FSource, AL_POSITION, 0, 0, 0);
alSource3f(FSource, AL_VELOCITY, 0, 0, 0);
alSource3f(FSource, AL_DIRECTION, 0, 0, 0);
alSourcef (FSource, AL_ROLLOFF_FACTOR, 0);
alSourcei (FSource, AL_SOURCE_RELATIVE, AL_TRUE);
end;

function TSGOpenALMP123FilePlayer.UpdateBuffer() : TSGBool;
var
	Processed : TALint;
	Buffer    : TSGALBuffer;
	BufferLength : TSGUInt64;
begin
Result := False;
alGetSourcei(FSource, AL_BUFFERS_PROCESSED, @Processed);
if Processed > 0 then
	repeat
	alSourceUnqueueBuffers(FSource, 1, @Buffer);
	BufferLength := Stream(Buffer);
	if BufferLength <> 0 then
		begin
		alSourceQueueBuffers(FSource, 1, @Buffer);
		Result := True;
		end
	else
		break;
	dec(Processed);
	until Processed <= 0
else
	Result := True;
end;

procedure TSGOpenALMP123FilePlayer.PreBuffer();
begin
Stream(FBuffers[0]);
Stream(FBuffers[1]);
alSourceQueueBuffers(FSource, 2, @FBuffers[0]);
end;

function TSGOpenALMP123FilePlayer.Stream(const VBuffer : TSGALBuffer) : TSGUInt64;
var
	Data : PByte;
	DataLength : Cardinal;
begin
GetMem(data, FMaxBufferSize);
mpg123_read(FMPGHandle, Data, FMaxBufferSize, @DataLength);
if DataLength <> 0 then
	alBufferData(VBuffer, FFormat, Data, DataLength, FRate);
FreeMem(Data);
Result := DataLength;
end;

procedure TSGOpenALMP123FilePlayer.Play();
begin
PreBuffer();
FPlaying := True;
Start();
alSourcePlay(FSource);
end;

procedure TSGOpenALMP123FilePlayer.Stop();
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

{$IFDEF USE_MPG123}
procedure _MPG123Initialize();
var
	SD : PPChar;
	i : TSGUInt32;
	Decoders : TSGString = '';
begin
if not FMPG123Initialized then
	begin
	FMPG123Initialized := mpg123_init() = 0;
	SGLog.Sourse('TSGAudioRenderOpenAL : MPG123 : ' + Iff(FMPG123Initialized, 'Initialized.', 'Initialization fail.'));
	if FMPG123Initialized then
		begin
		SD := mpg123_supported_decoders();
		i := 0;
		while SD[i] <> nil do
			begin
			if i <> 0 then
				Decoders += ', ';
			Decoders += SGPCharToString(SD[i]);
			i += 1;
			end;
		SGLog.Sourse('TSGAudioRenderOpenAL : MPG123 : Supored decoders - ' + Decoders + '.');
		end;
	end;
end;
{$ENDIF}

begin
if DllManager.Dll('OpenAL') <> nil then
	DllManager.Dll('OpenAL').ReadExtensions();

{$IFDEF USE_MPG123}
_MPG123Initialize();
{$ENDIF}

alListenerfv(AL_POSITION,    @ListenerPos);
alListenerfv(AL_VELOCITY,    @ListenerVel);
alListenerfv(AL_ORIENTATION, @ListenerOri);
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
