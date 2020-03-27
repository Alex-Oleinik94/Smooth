{$INCLUDE Smooth.inc}

//{$DEFINE AUDIO_RENDER_DEBUG}

unit SmoothAudioRender;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothCommonStructs
	,SmoothAudioRenderInterface
	,SmoothAudioDecoder
	,SmoothThreads
	
	,Classes
	;

type
	TSAudioRender = class;
	TSAudioRenderClass = class of TSAudioRender;

	TSAudioRenderObject = class;
	TSAudioRenderObject = class(TSNamed)
			public
		constructor Create(const VAudioRender : TSAudioRender); virtual;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			protected
		FAudioRender : TSAudioRender;
			public
		function GetAudioRender() : TSAudioRender;virtual;
		function AudioRenderAssigned() : TSBool; virtual;
			public
		property AudioRender : TSAudioRender read GetAudioRender;
		end;

	ISAudioSource = interface(ISInterface)
		['{78510d07-ffc2-4223-b178-abf674dd856c}']
		procedure SetPosition(const VPosition : TSVector3f);
		function  GetPosition() : TSVector3f;
		procedure SetDirection(const VDirection : TSVector3f);
		function  GetDirection() : TSVector3f;
		procedure SetVelocity(const VVelocity : TSVector3f);
		function  GetVelocity() : TSVector3f;
		procedure SetLooping(const VLooping : TSBool);
		function  GetLooping() : TSBool;
		procedure SetRelative(const VRelative : TSBool);
		function GetRelative() : TSBool;

		procedure Play();
		function Playing() : TSBool;
		procedure Pause();
		function Paused() : TSBool;
		procedure Stop();
		function Stoped : TSBool;

		property Relative  : TSBool     read GetRelative  write SetRelative;
		property Looping   : TSBool     read GetLooping   write SetLooping;
		property Velocity  : TSVector3f read GetVelocity  write SetVelocity;
		property Direction : TSVector3f read GetDirection write SetDirection;
		property Position  : TSVector3f read GetPosition  write SetPosition;
		end;

	TSAudioSourceCoords = object
			public
		FPosition  : TSVector3f;
		FDirection : TSVector3f;
		FVelocity  : TSVector3f;
			public
		procedure Clear();
		end;

	TSAudioSource = class(TSAudioRenderObject, ISAudioSource)
			public
		constructor Create(const VAudioRender : TSAudioRender); override;
		class function ClassName() : TSString; override;
			protected
		FCoords  : TSAudioSourceCoords;
		FLooping : TSBool;
		FRelative: TSBool;
			protected
		function GetSource() : ISAudioSource; virtual;
			protected
		property Source : ISAudioSource read GetSource;
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
		procedure Update(); virtual;
		procedure Play(); virtual;
		function Playing() : TSBool; virtual;
		procedure Pause(); virtual;
		function Paused() : TSBool; virtual;
		procedure Stop(); virtual;
		function Stoped : TSBool; virtual;
			public
		property Relative  : TSBool     read GetRelative  write SetRelative;
		property Looping   : TSBool     read GetLooping   write SetLooping;
		property Velocity  : TSVector3f read GetVelocity  write SetVelocity;
		property Direction : TSVector3f read GetDirection write SetDirection;
		property Position  : TSVector3f read GetPosition  write SetPosition;
		end;

	TSAudioBufferedSource = class(TSAudioSource)
			public
		constructor Create(const VAudioRender : TSAudioRender); override;
		destructor Destroy(); override;
			private
		procedure StartThread();
		procedure StopThread();
		function UpDateBuffers() : TSUInt64;
		procedure KillDecoder();
			protected
		FThread  : TSThread;
		FDecoder : TSAudioDecoder;
		FPreBuffered : TSBool;
			protected
		function CountProcessedBuffers() : TSUInt32; virtual; abstract;
		procedure DataProcessedBuffer(var Data; const VDataLength : TSUInt64); virtual; abstract;
		procedure PreBuffer(); virtual; abstract;
			public
		procedure Attach(const VDecoder : TSAudioDecoder); virtual;
		procedure UpdateLoop(); virtual;
		procedure Play(); override;
		procedure Stop(); override;
			public
		property Decoder : TSAudioDecoder read FDecoder;
		end;

	TSAudioRender = class(TSNamed, ISAudioRender)
			public
		constructor Create(); override;
		destructor  Destroy(); override;
		class function Supported() : TSBool; virtual;
		class function ClassName() : TSString; override;
		class function AudioRenderName() : TSString; virtual;
			protected
		FInitialized : TSBool;
			public
		procedure Initialize(); virtual;
		procedure Init(); virtual; abstract;
		function CreateDevice() : TSBool; virtual; abstract;
		procedure Kill(); virtual;
		function CreateBufferedSource() : TSAudioBufferedSource; virtual;
			public
		property Initialized : TSBool read FInitialized;
		end;

function TSCompatibleAudioRender():TSAudioRenderClass;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	SysUtils
	,SyncObjs
	{$IFNDEF MOBILE}
		,SmoothAudioRenderOpenAL
		,SmoothAudioRenderBASS
		{$ENDIF}
	;

class function TSAudioRender.AudioRenderName() : TSString;
begin
Result := 'Unknown';
end;

function TSAudioRender.CreateBufferedSource() : TSAudioBufferedSource;
begin
Result := nil;
end;

procedure TSAudioBufferedSource.KillDecoder();
begin
if FDecoder <> nil then
	begin
	FDecoder.Destroy();
	FDecoder := nil;
	end;
end;

procedure TSAudioBufferedSource.Attach(const VDecoder : TSAudioDecoder);
begin
KillDecoder();
FDecoder := VDecoder;
Decoder.ReadInfo();
//WriteLn('Decoder size = ' + SStr(Decoder.Size));
//WriteLn('Decoder position = ' + SStr(Decoder.Position));
end;

procedure TSAudioBufferedSource_Execute(const VSource : TSAudioBufferedSource);
begin
VSource.UpdateLoop();
end;

procedure TSAudioBufferedSource.StartThread();
begin
if FThread <> nil then
	exit;
FThread := TSThread.Create(TSThreadProcedure(@TSAudioBufferedSource_Execute), Self, True);
end;

procedure TSAudioBufferedSource.StopThread();
begin
if FThread = nil then
	exit;
while not FThread.Finished do
	Sleep(3);
FThread.Destroy();
FThread := nil;
end;

procedure TSAudioBufferedSource.UpdateLoop();
var
	CriticalSection : TCriticalSection = nil;
	InPlaying : TSBool = True;
begin
CriticalSection := TCriticalSection.Create();
while InPlaying do
	begin
	CriticalSection.Acquire();
	InPlaying := Source.Playing;
	if InPlaying then
		UpDateBuffers();
	CriticalSection.Release();
	if InPlaying then
		Sleep(20);
	end;
CriticalSection.Destroy();
end;

procedure TSAudioBufferedSource.Play();
begin
if not FPreBuffered then
	begin
	PreBuffer();
	FPreBuffered := True;
	end;
inherited;
if FThread = nil then
	StartThread();
end;

procedure TSAudioBufferedSource.Stop();
begin
FPreBuffered := False;
inherited;
if FThread <> nil then
	StopThread();
end;

function TSAudioBufferedSource.UpDateBuffers() : TSUInt64;

function DecodeDataAndSendToBuffer() : TSUInt64;
var
	Data : TSPointer = nil;
begin
GetMem(Data, SAudioDecoderBufferSize);
Result := FDecoder.Read(Data^, SAudioDecoderBufferSize);
DataProcessedBuffer(Data^, Result);
FreeMem(Data);
end;

var
	i : TSUInt32;
begin
Result := 0;
i := CountProcessedBuffers();
while i > 0 do
	begin
	Result += DecodeDataAndSendToBuffer();
	i -= 1;
	end;
end;

constructor TSAudioBufferedSource.Create(const VAudioRender : TSAudioRender);
begin
inherited Create(VAudioRender);
FThread := nil;
FDecoder := nil;
FPreBuffered := False;
end;

destructor TSAudioBufferedSource.Destroy();
begin
if FThread <> nil then
	StopThread();
KillDecoder();
inherited;
end;

procedure TSAudioSource.Play();
begin
if Source <> nil then
	Source.Play();
end;

function TSAudioSource.Playing() : TSBool;
begin
Result := False;
if Source <> nil then
	Result := Source.Playing();
end;

procedure TSAudioSource.Pause();
begin
if Source <> nil then
	Source.Pause();
end;

function TSAudioSource.Paused() : TSBool;
begin
Result := False;
if Source <> nil then
	Result := Source.Paused();
end;

procedure TSAudioSource.Stop();
begin
if Source <> nil then
	Source.Stop();
end;

function TSAudioSource.Stoped : TSBool;
begin
Result := False;
if Source <> nil then
	Result := Source.Stoped();
end;

function TSAudioSource.GetSource() : ISAudioSource;
begin
Result := nil;
end;

procedure TSAudioSource.SetPosition(const VPosition : TSVector3f);
begin
FCoords.FPosition := VPosition;
if Source <> nil then
	Source.Position := VPosition;
end;

function  TSAudioSource.GetPosition() : TSVector3f;
begin
Result := FCoords.FPosition;
end;

procedure TSAudioSource.SetDirection(const VDirection : TSVector3f);
begin
FCoords.FDirection := VDirection;
if Source <> nil then
	Source.Direction := VDirection;
end;

function  TSAudioSource.GetDirection() : TSVector3f;
begin
Result := FCoords.FDirection;
end;

procedure TSAudioSource.SetVelocity(const VVelocity : TSVector3f);
begin
FCoords.FVelocity := VVelocity;
if Source <> nil then
	Source.Velocity := VVelocity;
end;

function  TSAudioSource.GetVelocity() : TSVector3f;
begin
Result := FCoords.FVelocity;
end;

procedure TSAudioSource.SetLooping(const VLooping : TSBool);
begin
FLooping := VLooping;
if Source <> nil then
	Source.Looping := VLooping;
end;

function  TSAudioSource.GetLooping() : TSBool;
begin
Result := FLooping;
end;

procedure TSAudioSource.SetRelative(const VRelative : TSBool);
begin
FRelative := VRelative;
if Source <> nil then
	Source.Relative := FRelative;
end;

function TSAudioSource.GetRelative() : TSBool;
begin
if Source <> nil then
	Result := Source.Relative
else
	Result := False;
end;

procedure TSAudioSource.Update();
begin
if Source <> nil then
	begin
	Source.Position := FCoords.FPosition;
	Source.Direction := FCoords.FDirection;
	Source.Velocity := FCoords.FVelocity;
	Source.Looping := FLooping;
	Source.Relative := FRelative;
	end;
end;

constructor TSAudioRenderObject.Create(const VAudioRender : TSAudioRender);
begin
inherited Create();
FAudioRender := VAudioRender;
end;

destructor TSAudioRenderObject.Destroy();
begin
FAudioRender := nil;
inherited;
end;

class function TSAudioRenderObject.ClassName() : TSString;
begin
Result := 'TSAudioRenderObject';
end;

function TSAudioRenderObject.GetAudioRender() : TSAudioRender;
begin
Result := FAudioRender;
end;

function TSAudioRenderObject.AudioRenderAssigned() : TSBool;
begin
Result := FAudioRender <> nil;
end;

procedure TSAudioSourceCoords.Clear();
begin
FPosition .Import(0, 0, 0);
FDirection.Import(0, 0, 0);
FVelocity .Import(0, 0, 0);
end;

constructor TSAudioSource.Create(const VAudioRender : TSAudioRender);
begin
inherited Create(VAudioRender);
FCoords.Clear();
end;

class function TSAudioSource.ClassName() : TSString;
begin
Result := 'TSAudioSource';
end;

procedure TSAudioRender.Kill();
begin
FInitialized := False;
end;

procedure TSAudioRender.Initialize();
begin
FInitialized := CreateDevice();
if Initialized then
	Init();
end;

constructor TSAudioRender.Create();
begin
inherited;
FInitialized := False;
end;

destructor  TSAudioRender.Destroy();
begin
Kill();
inherited;
end;

function TSCompatibleAudioRender():TSAudioRenderClass;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := nil;

{$IFNDEF MOBILE}
if (Result = nil) and (TSAudioRenderOpenAL.Supported()) then
	Result := TSAudioRenderOpenAL;
if (Result = nil) and (TSAudioRenderBASS.Supported()) then
	Result := TSAudioRenderBASS;
{$ENDIF}
end;

class function TSAudioRender.ClassName() : TSString;
begin
Result := 'TSAudioRender';
end;

class function TSAudioRender.Supported() : TSBool;
begin
Result := False;
end;

end.
