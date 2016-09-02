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
	TSGOpenALBufferInfo = object
			public
		FFrequency   : TALsizei;
		FLoop   : TALint;
			public
		procedure Clear();
		end;

	TSGOpenALBuffer = object(TSGOpenALBufferInfo)
			public
		FBuffer : TALuint;
			public
		procedure Clear();
			public
		procedure DeleteBuffer();
		end;

	TSGOpenALSource = object(TSGOpenALBuffer)
			public
		FSource : TALuint;
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

type
	TSGAudioRenderOpenAL = class(TSGAudioRender)
			public
		constructor Create(); override;
		class function Suppored() : TSGBool; override;
		class function ClassName() : TSGString; override;
			private
		FALUTSuppored : TSGBool;
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
	;

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

alListenerfv(AL_POSITION,    @ListenerPos);
alListenerfv(AL_VELOCITY,    @ListenerVel);
alListenerfv(AL_ORIENTATION, @ListenerOri);

//Test :
//CreateSource(CreateBuffer(LoadWAVFromFile('./../../Sounds/SystemBass.wav'))).Play();
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
