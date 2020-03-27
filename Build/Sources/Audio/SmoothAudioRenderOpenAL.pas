{$INCLUDE Smooth.inc}

//{$DEFINE OPENAL_RENDER_DEBUG}

unit SmoothAudioRenderOpenAL;

interface

uses
	// Engine
	 SmoothBase
	,SmoothBaseClasses
	,SmoothCommonStructs
	,SmoothAudioRender
	,SmoothAudioDecoder
	
	// System
	,Classes
	,SysUtils
	,SyncObjs
	
	// Audio Library
	,OpenAL
	,Alut
	;

type
	TSALSource = TALuint;
	TSALBuffer = TALuint;
	TSALFormat = TALenum;

	TSOpenALCustomSource = class(TSAudioRenderObject, ISAudioSource)
			public
		constructor Create(const VAudioRender : TSAudioRender); override;
		destructor Destroy(); override;
			protected
		FSource : TSALSource;
			public
		property Source : TSALSource read FSource;
			public
		class function ClassName() : TSString; override;
			public
		procedure SetPosition(const VPosition : TSVector3f); virtual;
		function  GetPosition() : TSVector3f; virtual;
		procedure SetDirection(const VDirection : TSVector3f); virtual;
		function  GetDirection() : TSVector3f; virtual;
		procedure SetVelocity(const VVelocity : TSVector3f); virtual;
		function  GetVelocity() : TSVector3f; virtual;
		procedure SetLooping(const VLooping : TSBool); virtual;
		function  GetLooping() : TSBool; virtual;
		procedure SetRelative(const VRelative : TSBool); virtual;
		function GetRelative() : TSBool; virtual;
		procedure Play(); virtual;
		function Playing() : TSBool; virtual;
		procedure Pause(); virtual;
		function Paused() : TSBool; virtual;
		procedure Stop(); virtual;
		function Stoped : TSBool; virtual;
		end;

	TSOpenALBufferedSource = class(TSAudioBufferedSource)
			public
		constructor Create(const VAudioRender : TSAudioRender); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			private
		FCustomSource : TSOpenALCustomSource;
		FBuffers  : array[0..1] of TSALBuffer;
		FFormat   : TALenum;
		FAudioInfo: TSAudioInfo;
			protected
		function GetSource() : ISAudioSource; override;
		function CountProcessedBuffers() : TSUInt32; override;
		procedure DataProcessedBuffer(var Data; const VDataLength : TSUInt64); override;
		procedure PreBuffer(); override;
			protected
		procedure BufferSource(const VBuffer : TSALBuffer; var Data; const VDataLength : TSUInt64);
		end;

	TSAudioRenderOpenAL = class(TSAudioRender)
			public
		constructor Create(); override;
		class function Supported() : TSBool; override;
		class function ClassName() : TSString; override;
		class function AudioRenderName() : TSString; override;
			private
		FALUTSupported : TSBool;
			private
		FContext      : PALCcontext;
		FDevice       : PALCdevice;
			public
		procedure Init(); override;
		function CreateDevice() : TSBool; override;
		procedure Kill(); override;
		function CreateBufferedSource() : TSAudioBufferedSource; override;
		end;

function SOpenALFormatFromAudioInfo(const VInfo : TSAudioInfo) : TSALFormat;
function SOpenALStrFormat(const VFormat : TSALFormat) : TSString;
function SOpenALStrError(const _Error : TALenum) : TSString;

implementation

uses
	 SmoothDllManager
	,SmoothStringUtils
	,SmoothLog
	;

function SOpenALStrError(const _Error : TALenum) : TSString;
begin
case _Error of
AL_NO_ERROR: Result := 'AL_NO_ERROR';
AL_INVALID_NAME: Result := 'AL_INVALID_NAME';
AL_ILLEGAL_ENUM: Result := 'AL_ILLEGAL_ENUM or AL_INVALID_ENUM';
AL_INVALID_VALUE: Result := 'AL_INVALID_VALUE';
AL_ILLEGAL_COMMAND: Result := 'AL_ILLEGAL_COMMAND or AL_INVALID_OPERATION';
AL_OUT_OF_MEMORY: Result := 'AL_OUT_OF_MEMORY';
else Result := 'Can''t determine error!'
end;
end;

function SOpenALFormatFromAudioInfo(const VInfo : TSAudioInfo) : TSALFormat;
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

function SOpenALStrFormat(const VFormat : TSALFormat) : TSString;
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

// =============================
// ===TSOpenALBufferedSource===
// =============================

procedure TSOpenALBufferedSource.BufferSource(const VBuffer : TSALBuffer; var Data; const VDataLength : TSUInt64);
begin
alBufferData(VBuffer, FFormat, @Data, VDataLength, FAudioInfo.FFrequency);
end;

constructor TSOpenALBufferedSource.Create(const VAudioRender : TSAudioRender);
begin
inherited Create(VAudioRender);
FCustomSource := TSOpenALCustomSource.Create(VAudioRender);
FillChar(FFormat, SizeOf(FFormat), 0);
FillChar(FAudioInfo, SizeOf(FAudioInfo), 0);
FillChar(FBuffers, SizeOf(FBuffers), 0);
end;

destructor TSOpenALBufferedSource.Destroy();
begin
if FBuffers[0] + FBuffers[1] <> 0 then
	alDeleteBuffers(2, @FBuffers[0]);
FCustomSource.Destroy();
inherited;
end;

class function TSOpenALBufferedSource.ClassName() : TSString;
begin
Result := 'TSOpenALBufferedSource';
end;

function TSOpenALBufferedSource.GetSource() : ISAudioSource;
begin
Result := FCustomSource;
end;

function TSOpenALBufferedSource.CountProcessedBuffers() : TSUInt32;
var
	Processed : TALint;
begin
alGetSourcei(FCustomSource.Source, AL_BUFFERS_PROCESSED, @Processed);
Result := Processed;
end;

procedure TSOpenALBufferedSource.DataProcessedBuffer(var Data; const VDataLength : TSUInt64);
var
	Buffer : TSALBuffer;
begin
if VDataLength > 0 then
	begin
	alSourceUnqueueBuffers(FCustomSource.Source, 1, @Buffer);
	BufferSource(Buffer, Data, VDataLength);
	alSourceQueueBuffers(FCustomSource.Source, 1, @Buffer);
	end;
end;

procedure TSOpenALBufferedSource.PreBuffer();

function DecodeAndSendDataToBufferBuffer(const VBuffer : TSALBuffer; var Data; const MaxBufferSize : TSUInt64) : TSUInt64;
begin
Result := FDecoder.Read(Data, MaxBufferSize);
if Result > 0 then
	BufferSource(VBuffer, Data, Result);
end;

var
	DecodedDataLength : TSUInt64 = 0;
	Data : Pointer = nil;
begin
FAudioInfo := FDecoder.Info;
FFormat := SOpenALFormatFromAudioInfo(FAudioInfo);
SLog.Source('TSOpenALBufferedSource__PreBuffer : Determine format ''' + SOpenALStrFormat(FFormat) + '''.');

if SOpenALStrFormat(FFormat) = '?' then 
	exit;

GetMem(Data, SAudioDecoderBufferSize);
FillChar(Data^, SizeOf(SAudioDecoderBufferSize), 0);

alGenBuffers(2, @FBuffers[0]);
DecodedDataLength += DecodeAndSendDataToBufferBuffer(FBuffers[0], Data^, SAudioDecoderBufferSize);
DecodedDataLength += DecodeAndSendDataToBufferBuffer(FBuffers[1], Data^, SAudioDecoderBufferSize);
SLog.Source('TSOpenALBufferedSource__PreBuffer : Decoded data size ''' + SStr(DecodedDataLength) + '''.');
alSourceQueueBuffers(FCustomSource.Source, 2, @FBuffers[0]);

FreeMem(Data);
SLog.Source('TSOpenALBufferedSource__PreBuffer : Done.');
end;

// ===========================
// ===TSOpenALCustomSource===
// ===========================

constructor TSOpenALCustomSource.Create(const VAudioRender : TSAudioRender);
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

destructor TSOpenALCustomSource.Destroy();
begin
alDeleteSources(1, @FSource);
inherited;
end;

class function TSOpenALCustomSource.ClassName() : TSString;
begin
Result := 'TSOpenALCustomSource';
end;

procedure TSOpenALCustomSource.SetPosition(const VPosition : TSVector3f);
var
	Position : TSVector3f;
begin
Position := VPosition;
alSourcefv(FSource, AL_POSITION, @Position);
end;

function  TSOpenALCustomSource.GetPosition() : TSVector3f;
begin
alGetSourcefv(FSource, AL_POSITION, @Result);
end;

procedure TSOpenALCustomSource.SetDirection(const VDirection : TSVector3f);
var
	Direction : TSVector3f;
begin
Direction := VDirection;
alSourcefv(FSource, AL_DIRECTION, @Direction);
end;

function  TSOpenALCustomSource.GetDirection() : TSVector3f;
begin
alGetSourcefv(FSource, AL_DIRECTION, @Result);
end;

procedure TSOpenALCustomSource.SetVelocity(const VVelocity : TSVector3f);
var
	Velocity : TSVector3f;
begin
Velocity := VVelocity;
alSourcefv(FSource, AL_VELOCITY, @Velocity);
end;

function  TSOpenALCustomSource.GetVelocity() : TSVector3f;
begin
alGetSourcefv(FSource, AL_VELOCITY, @Result);
end;

procedure TSOpenALCustomSource.SetLooping(const VLooping : TSBool);
var
	Looping : TALint;
begin
Looping := AL_TRUE * Byte(VLooping) + AL_FALSE * Byte(not VLooping);
alSourcei(FSource, AL_LOOPING, Looping);
end;

function  TSOpenALCustomSource.GetLooping() : TSBool;
var
	Looping : TALint;
begin
alGetSourcei(FSource, AL_LOOPING, @Looping);
Result := Looping = AL_TRUE;
end;

procedure TSOpenALCustomSource.SetRelative(const VRelative : TSBool);
var
	Relative : TALint;
begin
Relative := AL_TRUE * Byte(VRelative) + AL_FALSE * Byte(not VRelative);
alSourcei(FSource, AL_SOURCE_RELATIVE, Relative);
end;

function TSOpenALCustomSource.GetRelative() : TSBool;
var
	Relative : TALint;
begin
alGetSourcei(FSource, AL_SOURCE_RELATIVE, @Relative);
Result := Relative = AL_TRUE;
end;

procedure TSOpenALCustomSource.Play();
begin
alSourcePlay(FSource);
end;

function TSOpenALCustomSource.Playing() : TSBool;
var
	State : TALint;
begin
alGetSourcei(FSource, AL_SOURCE_STATE, @State);
Result := AL_PLAYING = State;
end;

procedure TSOpenALCustomSource.Pause();
begin
alSourcePause(FSource);
end;

function TSOpenALCustomSource.Paused() : TSBool;
var
	State : TALint;
begin
alGetSourcei(FSource, AL_SOURCE_STATE, @State);
Result := AL_PAUSED = State;
end;

procedure TSOpenALCustomSource.Stop();
begin
alSourceStop(FSource);
end;

function TSOpenALCustomSource.Stoped : TSBool;
var
	State : TALint;
begin
alGetSourcei(FSource, AL_SOURCE_STATE, @State);
Result := AL_STOPPED = State;
end;

// ==========================
// ===TSAudioRenderOpenAL===
// ==========================

function TSAudioRenderOpenAL.CreateBufferedSource() : TSAudioBufferedSource;
begin
Result := TSOpenALBufferedSource.Create(Self);
end;

procedure TSAudioRenderOpenAL.Init();
var
	ListenerPos: array [0..2] of TALfloat= ( 0.0, 0.0, 0.0);
	ListenerVel: array [0..2] of TALfloat= ( 0.0, 0.0, 0.0);
	ListenerOri: array [0..5] of TALfloat= ( 0.0, 0.0, -1.0, 0.0, 1.0, 0.0);

begin
if (DllManager.Dll('OpenAL') <> nil) then
	DllManager.Dll('OpenAL').ReadExtensions();

alListenerfv(AL_POSITION,    @ListenerPos);
alListenerfv(AL_VELOCITY,    @ListenerVel);
alListenerfv(AL_ORIENTATION, @ListenerOri);
end;

function TSAudioRenderOpenAL.CreateDevice() : TSBool;
var
	ErrorHandle : TALenum;
begin
Result := False;
if (not FALUTSupported) then
	int_alutInit()
else
	ext_alutInit(nil, nil);

FContext := alcGetCurrentContext();
ErrorHandle := alGetError();
if (ErrorHandle <> AL_NO_ERROR) then
	SLog.Source([ClassName(), ': Error "', SOpenALStrError(ErrorHandle), '".'])
else if (FContext = nil) then
	SLog.Source([ClassName(), ': Couldn''t to create OpenAL context but not returned any error!']);

FDevice := alcGetContextsDevice(FContext);
ErrorHandle := alGetError();
if (ErrorHandle <> AL_NO_ERROR) then
	SLog.Source([ClassName(), ': Error "', SOpenALStrError(ErrorHandle), '".'])
else if (FDevice = nil) then
	SLog.Source([ClassName(), ': Couldn''t to create OpenAL device but not returned any error!']);

Result := (FContext <> nil) and (FDevice <> nil);

if ((FContext = nil) and (FDevice = nil)) then
	SLog.Source(ClassName() + ': Couldn''t to create OpenAL audio render!')
else
	SLog.Source(ClassName() + ': Context = ' + SAddrStr(FContext) + ', Device = ' + SAddrStr(FDevice) + '.');
end;

procedure TSAudioRenderOpenAL.Kill();
begin
if (not FALUTSupported) then
	int_alutExit()
else
	ext_alutExit();
FContext := nil;
FDevice := nil;
inherited;
end;

constructor TSAudioRenderOpenAL.Create();
begin
inherited;
FALUTSupported := DllManager.Supported('alut');
FContext := nil;
FDevice := nil;
end;

class function TSAudioRenderOpenAL.AudioRenderName() : TSString;
begin
Result := 'OpenAL';
end;

class function TSAudioRenderOpenAL.ClassName() : TSString;
begin
Result := 'TSAudioRenderOpenAL';
end;

class function TSAudioRenderOpenAL.Supported() : TSBool;
begin
Result := DllManager.Supported('OpenAL');
end;

end.
