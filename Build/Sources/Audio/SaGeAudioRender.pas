{$INCLUDE SaGe.inc}

//{$DEFINE AUDIO_RENDER_DEBUG}

unit SaGeAudioRender;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeClasses
	,SaGeCommon
	,SaGeAudioDecoder

	,Classes
	;

type
	TSGAudioRender = class;
	TSGAudioRenderClass = class of TSGAudioRender;

	TSGAudioRenderObject = class;
	TSGAudioRenderObject = class(TSGNamed)
			public
		constructor Create(const VAudioRender : TSGAudioRender); virtual;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			protected
		FAudioRender : TSGAudioRender;
			public
		function GetAudioRender() : TSGAudioRender;virtual;
		function AudioRenderAssigned() : TSGBool; virtual;
			public
		property AudioRender : TSGAudioRender read GetAudioRender;
		end;

	ISGAudioSource = interface(ISGInterface)
		['{78510d07-ffc2-4223-b178-abf674dd856c}']
		procedure SetPosition(const VPosition : TSGVector3f);
		function  GetPosition() : TSGVector3f;
		procedure SetDirection(const VDirection : TSGVector3f);
		function  GetDirection() : TSGVector3f;
		procedure SetVelocity(const VVelocity : TSGVector3f);
		function  GetVelocity() : TSGVector3f;
		procedure SetLooping(const VLooping : TSGBool);
		function  GetLooping() : TSGBool;
		procedure SetRelative(const VRelative : TSGBool);
		function GetRelative() : TSGBool;

		procedure Play();
		function Playing() : TSGBool;
		procedure Pause();
		function Paused() : TSGBool;
		procedure Stop();
		function Stoped : TSGBool;

		property Relative  : TSGBool     read GetRelative  write SetRelative;
		property Looping   : TSGBool     read GetLooping   write SetLooping;
		property Velocity  : TSGVector3f read GetVelocity  write SetVelocity;
		property Direction : TSGVector3f read GetDirection write SetDirection;
		property Position  : TSGVector3f read GetPosition  write SetPosition;
		end;

	TSGAudioSourceCoords = object
			public
		FPosition  : TSGVector3f;
		FDirection : TSGVector3f;
		FVelocity  : TSGVector3f;
			public
		procedure Clear();
		end;

	TSGAudioSource = class(TSGAudioRenderObject, ISGAudioSource)
			public
		constructor Create(const VAudioRender : TSGAudioRender); override;
		class function ClassName() : TSGString; override;
			protected
		FCoords  : TSGAudioSourceCoords;
		FLooping : TSGBool;
		FRelative: TSGBool;
			protected
		function GetSource() : ISGAudioSource; virtual;
			protected
		property Source : ISGAudioSource read GetSource;
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
		procedure Update(); virtual;
		procedure Play(); virtual;
		function Playing() : TSGBool; virtual;
		procedure Pause(); virtual;
		function Paused() : TSGBool; virtual;
		procedure Stop(); virtual;
		function Stoped : TSGBool; virtual;
			public
		property Relative  : TSGBool     read GetRelative  write SetRelative;
		property Looping   : TSGBool     read GetLooping   write SetLooping;
		property Velocity  : TSGVector3f read GetVelocity  write SetVelocity;
		property Direction : TSGVector3f read GetDirection write SetDirection;
		property Position  : TSGVector3f read GetPosition  write SetPosition;
		end;

	TSGAudioBufferedSource = class(TSGAudioSource)
			public
		constructor Create(const VAudioRender : TSGAudioRender); override;
		destructor Destroy(); override;
			private
		procedure StartThread();
		procedure StopThread();
		function UpDateBuffers() : TSGUInt64;
		procedure KillDecoder();
			protected
		FThread  : TSGThread;
		FDecoder : TSGAudioDecoder;
		FPreBuffered : TSGBool;
			protected
		function CountProcessedBuffers() : TSGUInt32; virtual; abstract;
		procedure DataProcessedBuffer(var Data; const VDataLength : TSGUInt64); virtual; abstract;
		procedure PreBuffer(); virtual; abstract;
			public
		procedure Attach(const VDecoder : TSGAudioDecoder); virtual;
		procedure UpdateLoop(); virtual;
		procedure Play(); override;
		procedure Stop(); override;
			public
		property Decoder : TSGAudioDecoder read FDecoder;
		end;

	TSGAudioRender = class(TSGNamed, ISGAudioRender)
			public
		constructor Create(); override;
		destructor  Destroy(); override;
		class function Suppored() : TSGBool; virtual;
		class function ClassName() : TSGString; override;
			protected
		FInitialized : TSGBool;
			public
		procedure Initialize(); virtual;
		procedure Init(); virtual; abstract;
		function CreateDevice() : TSGBool; virtual; abstract;
		procedure Kill(); virtual;
		function CreateBufferedSource() : TSGAudioBufferedSource; virtual;
			public
		property Initialized : TSGBool read FInitialized;
		end;

function TSGCompatibleAudioRender():TSGAudioRenderClass;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	SysUtils
	,SyncObjs
	{$IFNDEF MOBILE}
	,SaGeAudioRenderOpenAL
	{$ENDIF}
	;

function TSGAudioRender.CreateBufferedSource() : TSGAudioBufferedSource;
begin
Result := nil;
end;

procedure TSGAudioBufferedSource.KillDecoder();
begin
if FDecoder <> nil then
	begin
	FDecoder.Destroy();
	FDecoder := nil;
	end;
end;

procedure TSGAudioBufferedSource.Attach(const VDecoder : TSGAudioDecoder);
begin
KillDecoder();
FDecoder := VDecoder;
Decoder.ReadInfo();
//WriteLn('Decoder size = ' + SGStr(Decoder.Size));
//WriteLn('Decoder position = ' + SGStr(Decoder.Position));
end;

procedure TSGAudioBufferedSource_Execute(const VSource : TSGAudioBufferedSource);
begin
VSource.UpdateLoop();
end;

procedure TSGAudioBufferedSource.StartThread();
begin
if FThread <> nil then
	exit;
FThread := TSGThread.Create(TSGThreadProcedure(@TSGAudioBufferedSource_Execute), Self, True);
end;

procedure TSGAudioBufferedSource.StopThread();
begin
if FThread = nil then
	exit;
while not FThread.Finished do
	Sleep(3);
FThread.Destroy();
FThread := nil;
end;

procedure TSGAudioBufferedSource.UpdateLoop();
var
	CriticalSection : TCriticalSection = nil;
	InPlaying : TSGBool = True;
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

procedure TSGAudioBufferedSource.Play();
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

procedure TSGAudioBufferedSource.Stop();
begin
FPreBuffered := False;
inherited;
if FThread <> nil then
	StopThread();
end;

function TSGAudioBufferedSource.UpDateBuffers() : TSGUInt64;

function DecodeDataAndSendToBuffer() : TSGUInt64;
var
	Data : TSGPointer = nil;
begin
GetMem(Data, SGAudioDecoderBufferSize);
Result := FDecoder.Read(Data^, SGAudioDecoderBufferSize);
DataProcessedBuffer(Data^, Result);
FreeMem(Data);
end;

var
	i : TSGUInt32;
begin
Result := 0;
i := CountProcessedBuffers();
while i > 0 do
	begin
	Result += DecodeDataAndSendToBuffer();
	i -= 1;
	end;
end;

constructor TSGAudioBufferedSource.Create(const VAudioRender : TSGAudioRender);
begin
inherited Create(VAudioRender);
FThread := nil;
FDecoder := nil;
FPreBuffered := False;
end;

destructor TSGAudioBufferedSource.Destroy();
begin
if FThread <> nil then
	StopThread();
KillDecoder();
inherited;
end;

procedure TSGAudioSource.Play();
begin
if Source <> nil then
	Source.Play();
end;

function TSGAudioSource.Playing() : TSGBool;
begin
Result := False;
if Source <> nil then
	Result := Source.Playing();
end;

procedure TSGAudioSource.Pause();
begin
if Source <> nil then
	Source.Pause();
end;

function TSGAudioSource.Paused() : TSGBool;
begin
Result := False;
if Source <> nil then
	Result := Source.Paused();
end;

procedure TSGAudioSource.Stop();
begin
if Source <> nil then
	Source.Stop();
end;

function TSGAudioSource.Stoped : TSGBool;
begin
Result := False;
if Source <> nil then
	Result := Source.Stoped();
end;

function TSGAudioSource.GetSource() : ISGAudioSource;
begin
Result := nil;
end;

procedure TSGAudioSource.SetPosition(const VPosition : TSGVector3f);
begin
FCoords.FPosition := VPosition;
if Source <> nil then
	Source.Position := VPosition;
end;

function  TSGAudioSource.GetPosition() : TSGVector3f;
begin
Result := FCoords.FPosition;
end;

procedure TSGAudioSource.SetDirection(const VDirection : TSGVector3f);
begin
FCoords.FDirection := VDirection;
if Source <> nil then
	Source.Direction := VDirection;
end;

function  TSGAudioSource.GetDirection() : TSGVector3f;
begin
Result := FCoords.FDirection;
end;

procedure TSGAudioSource.SetVelocity(const VVelocity : TSGVector3f);
begin
FCoords.FVelocity := VVelocity;
if Source <> nil then
	Source.Velocity := VVelocity;
end;

function  TSGAudioSource.GetVelocity() : TSGVector3f;
begin
Result := FCoords.FVelocity;
end;

procedure TSGAudioSource.SetLooping(const VLooping : TSGBool);
begin
FLooping := VLooping;
if Source <> nil then
	Source.Looping := VLooping;
end;

function  TSGAudioSource.GetLooping() : TSGBool;
begin
Result := FLooping;
end;

procedure TSGAudioSource.SetRelative(const VRelative : TSGBool);
begin
FRelative := VRelative;
if Source <> nil then
	Source.Relative := FRelative;
end;

function TSGAudioSource.GetRelative() : TSGBool;
begin
if Source <> nil then
	Result := Source.Relative
else
	Result := False;
end;

procedure TSGAudioSource.Update();
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

constructor TSGAudioRenderObject.Create(const VAudioRender : TSGAudioRender);
begin
inherited Create();
FAudioRender := VAudioRender;
end;

destructor TSGAudioRenderObject.Destroy();
begin
FAudioRender := nil;
inherited;
end;

class function TSGAudioRenderObject.ClassName() : TSGString;
begin
Result := 'TSGAudioRenderObject';
end;

function TSGAudioRenderObject.GetAudioRender() : TSGAudioRender;
begin
Result := FAudioRender;
end;

function TSGAudioRenderObject.AudioRenderAssigned() : TSGBool;
begin
Result := FAudioRender <> nil;
end;

procedure TSGAudioSourceCoords.Clear();
begin
FPosition .Import(0, 0, 0);
FDirection.Import(0, 0, 0);
FVelocity .Import(0, 0, 0);
end;

constructor TSGAudioSource.Create(const VAudioRender : TSGAudioRender);
begin
inherited Create(VAudioRender);
FCoords.Clear();
end;

class function TSGAudioSource.ClassName() : TSGString;
begin
Result := 'TSGAudioSource';
end;

procedure TSGAudioRender.Kill();
begin
FInitialized := False;
end;

procedure TSGAudioRender.Initialize();
begin
FInitialized := CreateDevice();
if Initialized then
	Init();
end;

constructor TSGAudioRender.Create();
begin
inherited;
FInitialized := False;
end;

destructor  TSGAudioRender.Destroy();
begin
Kill();
inherited;
end;

function TSGCompatibleAudioRender():TSGAudioRenderClass;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := nil;

{$IFNDEF MOBILE}
if (Result = nil) and (TSGAudioRenderOpenAL.Suppored()) then
	Result := TSGAudioRenderOpenAL;
{$ENDIF}
end;

class function TSGAudioRender.ClassName() : TSGString;
begin
Result := 'TSGAudioRender';
end;

class function TSGAudioRender.Suppored() : TSGBool;
begin
Result := False;
end;

end.
