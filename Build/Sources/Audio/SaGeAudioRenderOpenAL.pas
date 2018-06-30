{$INCLUDE SaGe.inc}

//{$DEFINE OPENAL_RENDER_DEBUG}

unit SaGeAudioRenderOpenAL;

interface

uses
	// Engine
	 SaGeBase
	,SaGeClasses
	,SaGeCommonStructs
	,SaGeAudioRender
	,SaGeAudioDecoder
	
	// System
	,Classes
	,SysUtils
	,SyncObjs
	
	// Audio Library
	,OpenAL
	,Alut
	;

type
	TSGALSource = TALuint;
	TSGALBuffer = TALuint;
	TSGALFormat = TALenum;

	TSGOpenALCustomSource = class(TSGAudioRenderObject, ISGAudioSource)
			public
		constructor Create(const VAudioRender : TSGAudioRender); override;
		destructor Destroy(); override;
			protected
		FSource : TSGALSource;
			public
		property Source : TSGALSource read FSource;
			public
		class function ClassName() : TSGString; override;
			public
		procedure SetPosition(const VPosition : TSGVector3f); virtual;
		function  GetPosition() : TSGVector3f; virtual;
		procedure SetDirection(const VDirection : TSGVector3f); virtual;
		function  GetDirection() : TSGVector3f; virtual;
		procedure SetVelocity(const VVelocity : TSGVector3f); virtual;
		function  GetVelocity() : TSGVector3f; virtual;
		procedure SetLooping(const VLooping : TSGBool); virtual;
		function  GetLooping() : TSGBool; virtual;
		procedure SetRelative(const VRelative : TSGBool); virtual;
		function GetRelative() : TSGBool; virtual;
		procedure Play(); virtual;
		function Playing() : TSGBool; virtual;
		procedure Pause(); virtual;
		function Paused() : TSGBool; virtual;
		procedure Stop(); virtual;
		function Stoped : TSGBool; virtual;
		end;

	TSGOpenALBufferedSource = class(TSGAudioBufferedSource)
			public
		constructor Create(const VAudioRender : TSGAudioRender); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			private
		FCustomSource : TSGOpenALCustomSource;
		FBuffers  : array[0..1] of TSGALBuffer;
		FFormat   : TALenum;
		FAudioInfo: TSGAudioInfo;
			protected
		function GetSource() : ISGAudioSource; override;
		function CountProcessedBuffers() : TSGUInt32; override;
		procedure DataProcessedBuffer(var Data; const VDataLength : TSGUInt64); override;
		procedure PreBuffer(); override;
			protected
		procedure BufferSource(const VBuffer : TSGALBuffer; var Data; const VDataLength : TSGUInt64);
		end;

	TSGAudioRenderOpenAL = class(TSGAudioRender)
			public
		constructor Create(); override;
		class function Suppored() : TSGBool; override;
		class function ClassName() : TSGString; override;
		class function AudioRenderName() : TSGString; override;
			private
		FALUTSuppored : TSGBool;
			private
		FContext      : PALCcontext;
		FDevice       : PALCdevice;
			public
		procedure Init(); override;
		function CreateDevice() : TSGBool; override;
		procedure Kill(); override;
		function CreateBufferedSource() : TSGAudioBufferedSource; override;
		end;

function SGOpenALFormatFromAudioInfo(const VInfo : TSGAudioInfo) : TSGALFormat;
function SGOpenALStrFormat(const VFormat : TSGALFormat) : TSGString;

implementation

uses
	 SaGeDllManager
	,SaGeStringUtils
	,SaGeLog
	;

function SGOpenALFormatFromAudioInfo(const VInfo : TSGAudioInfo) : TSGALFormat;
begin
Result := 0;
case VInfo.FBitsPerSample of
16:
	if VInfo.FChannels = 1 then
		Result := AL_FORMAT_MONO16
	else if VInfo.FChannels = 2 then
		Result := AL_FORMAT_STEREO16;
8:
	if VInfo.FChannels = 1 then
		Result := AL_FORMAT_MONO8
	else if VInfo.FChannels = 2 then
		Result := AL_FORMAT_STEREO8;
end;
end;

function SGOpenALStrFormat(const VFormat : TSGALFormat) : TSGString;
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

procedure TSGOpenALBufferedSource.BufferSource(const VBuffer : TSGALBuffer; var Data; const VDataLength : TSGUInt64);
begin
alBufferData(VBuffer, FFormat, @Data, VDataLength, FAudioInfo.FFrequency);
end;

constructor TSGOpenALBufferedSource.Create(const VAudioRender : TSGAudioRender);
begin
inherited Create(VAudioRender);
FCustomSource := TSGOpenALCustomSource.Create(VAudioRender);
FillChar(FFormat, SizeOf(FFormat), 0);
FillChar(FAudioInfo, SizeOf(FAudioInfo), 0);
FillChar(FBuffers, SizeOf(FBuffers), 0);
end;

destructor TSGOpenALBufferedSource.Destroy();
begin
if FBuffers[0] + FBuffers[1] <> 0 then
	alDeleteBuffers(2, @FBuffers[0]);
FCustomSource.Destroy();
inherited;
end;

class function TSGOpenALBufferedSource.ClassName() : TSGString;
begin
Result := 'TSGOpenALBufferedSource';
end;

function TSGOpenALBufferedSource.GetSource() : ISGAudioSource;
begin
Result := FCustomSource;
end;

function TSGOpenALBufferedSource.CountProcessedBuffers() : TSGUInt32;
var
	Processed : TALint;
begin
alGetSourcei(FCustomSource.Source, AL_BUFFERS_PROCESSED, @Processed);
Result := Processed;
end;

procedure TSGOpenALBufferedSource.DataProcessedBuffer(var Data; const VDataLength : TSGUInt64);
var
	Buffer : TSGALBuffer;
begin
if VDataLength > 0 then
	begin
	alSourceUnqueueBuffers(FCustomSource.Source, 1, @Buffer);
	BufferSource(Buffer, Data, VDataLength);
	alSourceQueueBuffers(FCustomSource.Source, 1, @Buffer);
	end;
end;

procedure TSGOpenALBufferedSource.PreBuffer();

function DecodeAndSendDataToBufferBuffer(const VBuffer : TSGALBuffer; var Data; const MaxBufferSize : TSGUInt64) : TSGUInt64;
begin
Result := FDecoder.Read(Data, MaxBufferSize);
if Result > 0 then
	BufferSource(VBuffer, Data, Result);
end;

var
	DecodedDataLength : TSGUInt64 = 0;
	Data : Pointer = nil;
begin
FAudioInfo := FDecoder.Info;
FFormat := SGOpenALFormatFromAudioInfo(FAudioInfo);
SGLog.Source('TSGOpenALBufferedSource__PreBuffer : Determine format ''' + SGOpenALStrFormat(FFormat) + '''.');

if SGOpenALStrFormat(FFormat) = '?' then 
	exit;

GetMem(Data, SGAudioDecoderBufferSize);
FillChar(Data^, SizeOf(SGAudioDecoderBufferSize), 0);

alGenBuffers(2, @FBuffers[0]);
DecodedDataLength += DecodeAndSendDataToBufferBuffer(FBuffers[0], Data^, SGAudioDecoderBufferSize);
DecodedDataLength += DecodeAndSendDataToBufferBuffer(FBuffers[1], Data^, SGAudioDecoderBufferSize);
SGLog.Source('TSGOpenALBufferedSource__PreBuffer : Decoded data size ''' + SGStr(DecodedDataLength) + '''.');
alSourceQueueBuffers(FCustomSource.Source, 2, @FBuffers[0]);

FreeMem(Data);
SGLog.Source('TSGOpenALBufferedSource__PreBuffer : Done.');
end;

constructor TSGOpenALCustomSource.Create(const VAudioRender : TSGAudioRender);
begin
inherited Create(VAudioRender);
alGenSources(1, @FSource);
alSourcef  (FSource, AL_PITCH,     1.0 );
alSourcef  (FSource, AL_GAIN,      1.0 );
alSource3f (FSource, AL_POSITION,  0, 0, 0);
alSource3f (FSource, AL_VELOCITY,  0, 0, 0);
alSource3f (FSource, AL_DIRECTION, 0, 0, 0);
alSourcei  (FSource, AL_LOOPING,   AL_FALSE);
alSourcei  (FSource, AL_SOURCE_RELATIVE, AL_FALSE);
end;

destructor TSGOpenALCustomSource.Destroy();
begin
alDeleteSources(1, @FSource);
inherited;
end;

class function TSGOpenALCustomSource.ClassName() : TSGString;
begin
Result := 'TSGOpenALCustomSource';
end;

procedure TSGOpenALCustomSource.SetPosition(const VPosition : TSGVector3f);
var
	Position : TSGVector3f;
begin
Position := VPosition;
alSourcefv(FSource, AL_POSITION, @Position);
end;

function  TSGOpenALCustomSource.GetPosition() : TSGVector3f;
begin
alGetSourcefv(FSource, AL_POSITION, @Result);
end;

procedure TSGOpenALCustomSource.SetDirection(const VDirection : TSGVector3f);
var
	Direction : TSGVector3f;
begin
Direction := VDirection;
alSourcefv(FSource, AL_DIRECTION, @Direction);
end;

function  TSGOpenALCustomSource.GetDirection() : TSGVector3f;
begin
alGetSourcefv(FSource, AL_DIRECTION, @Result);
end;

procedure TSGOpenALCustomSource.SetVelocity(const VVelocity : TSGVector3f);
var
	Velocity : TSGVector3f;
begin
Velocity := VVelocity;
alSourcefv(FSource, AL_VELOCITY, @Velocity);
end;

function  TSGOpenALCustomSource.GetVelocity() : TSGVector3f;
begin
alGetSourcefv(FSource, AL_VELOCITY, @Result);
end;

procedure TSGOpenALCustomSource.SetLooping(const VLooping : TSGBool);
var
	Looping : TALint;
begin
Looping := AL_TRUE * Byte(VLooping) + AL_FALSE * Byte(not VLooping);
alSourcei(FSource, AL_LOOPING, Looping);
end;

function  TSGOpenALCustomSource.GetLooping() : TSGBool;
var
	Looping : TALint;
begin
alGetSourcei(FSource, AL_LOOPING, @Looping);
Result := Looping = AL_TRUE;
end;

procedure TSGOpenALCustomSource.SetRelative(const VRelative : TSGBool);
var
	Relative : TALint;
begin
Relative := AL_TRUE * Byte(VRelative) + AL_FALSE * Byte(not VRelative);
alSourcei(FSource, AL_SOURCE_RELATIVE, Relative);
end;

function TSGOpenALCustomSource.GetRelative() : TSGBool;
var
	Relative : TALint;
begin
alGetSourcei(FSource, AL_SOURCE_RELATIVE, @Relative);
Result := Relative = AL_TRUE;
end;

procedure TSGOpenALCustomSource.Play();
begin
alSourcePlay(FSource);
end;

function TSGOpenALCustomSource.Playing() : TSGBool;
var
	State : TALint;
begin
alGetSourcei(FSource, AL_SOURCE_STATE, @State);
Result := AL_PLAYING = State;
end;

procedure TSGOpenALCustomSource.Pause();
begin
alSourcePause(FSource);
end;

function TSGOpenALCustomSource.Paused() : TSGBool;
var
	State : TALint;
begin
alGetSourcei(FSource, AL_SOURCE_STATE, @State);
Result := AL_PAUSED = State;
end;

procedure TSGOpenALCustomSource.Stop();
begin
alSourceStop(FSource);
end;

function TSGOpenALCustomSource.Stoped : TSGBool;
var
	State : TALint;
begin
alGetSourcei(FSource, AL_SOURCE_STATE, @State);
Result := AL_STOPPED = State;
end;

function TSGAudioRenderOpenAL.CreateBufferedSource() : TSGAudioBufferedSource;
begin
Result := TSGOpenALBufferedSource.Create(Self);
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

SGLog.Source('TSGAudioRenderOpenAL : Context = ' + SGAddrStr(FContext) + ', Device = ' + SGAddrStr(FDevice) + '.');
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

class function TSGAudioRenderOpenAL.AudioRenderName() : TSGString;
begin
Result := 'OpenAL';
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
