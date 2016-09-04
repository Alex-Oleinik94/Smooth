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

	ISGAudioRenderSource = interface(ISGInterface)
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

		procedure Update();

		procedure Play();
		function Played() : TSGBool;
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

	TSGAudioRenderSourceCoords = object
			public
		FPosition  : TSGVector3f;
		FDirection : TSGVector3f;
		FVelocity  : TSGVector3f;
			public
		procedure Clear();
		end;

	TSGAudioRenderSource = class(TSGAudioRenderObject, ISGAudioRenderSource)
			public
		constructor Create(const VAudioRender : TSGAudioRender); override;
		class function ClassName() : TSGString; override;
			protected
		FCoords  : TSGAudioRenderSourceCoords;
		FLooping : TSGBool;
		FRelative: TSGBool;
			protected
		function GetSource() : ISGAudioRenderSource; virtual;
			protected
		property Source : ISGAudioRenderSource read GetSource;
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
		function Played() : TSGBool; virtual;
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

	TSGAudioRenderFileSource = class(TSGAudioRenderSource)
			public
		constructor Create(const VAudioRender : TSGAudioRender); override;
		class function ClassName() : TSGString; override;
			protected
		FFileName : TSGString;
			protected
		function GetEnded() : TSGBool; virtual; abstract;
		procedure SetFile(const VFileName : TSGString); virtual;
			public
		procedure Play(); virtual; abstract;
			public
		property Ended : TSGBool read GetEnded;
		property FileName : TSGString read FFileName write SetFile;
		end;

	TSGAudioRender = class(TSGNamed, ISGAudioRender)
			public
		constructor Create(); override;
		destructor  Destroy(); override;
		class function Suppored() : TSGBool; virtual;
		class function ClassName() : TSGString; override;
		class function SupporedAudioFormats() : TSGStringList; virtual;
			protected
		FInitialized : TSGBool;
			public
		procedure Initialize(); virtual;
		procedure Init(); virtual; abstract;
		function CreateDevice() : TSGBool; virtual; abstract;
		procedure Kill(); virtual;
		function CreateFileSource(const VFileName : TSGString) : TSGAudioRenderFileSource; virtual;
			public
		property Initialized : TSGBool read FInitialized;
		end;

function TSGCompatibleAudioRender():TSGAudioRenderClass;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	Crt
	{$IFNDEF MOBILE}
	,SaGeAudioRenderOpenAL
	{$ENDIF}
	;
procedure TSGAudioRenderSource.Play();
begin
if Source <> nil then
	Source.Play();
end;

function TSGAudioRenderSource.Played() : TSGBool;
begin
Result := False;
if Source <> nil then
	Result := Source.Played();
end;

procedure TSGAudioRenderSource.Pause();
begin
if Source <> nil then
	Source.Pause();
end;

function TSGAudioRenderSource.Paused() : TSGBool;
begin
Result := False;
if Source <> nil then
	Result := Source.Paused();
end;

procedure TSGAudioRenderSource.Stop();
begin
if Source <> nil then
	Source.Stop();
end;

function TSGAudioRenderSource.Stoped : TSGBool;
begin
Result := False;
if Source <> nil then
	Result := Source.Stoped();
end;

function TSGAudioRenderSource.GetSource() : ISGAudioRenderSource;
begin
Result := nil;
end;

procedure TSGAudioRenderSource.SetPosition(const VPosition : TSGVector3f);
begin
FCoords.FPosition := VPosition;
if Source <> nil then
	Source.Position := VPosition;
end;

function  TSGAudioRenderSource.GetPosition() : TSGVector3f;
begin
Result := FCoords.FPosition;
end;

procedure TSGAudioRenderSource.SetDirection(const VDirection : TSGVector3f);
begin
FCoords.FDirection := VDirection;
if Source <> nil then
	Source.Direction := VDirection;
end;

function  TSGAudioRenderSource.GetDirection() : TSGVector3f;
begin
Result := FCoords.FDirection;
end;

procedure TSGAudioRenderSource.SetVelocity(const VVelocity : TSGVector3f);
begin
FCoords.FVelocity := VVelocity;
if Source <> nil then
	Source.Velocity := VVelocity;
end;

function  TSGAudioRenderSource.GetVelocity() : TSGVector3f;
begin
Result := FCoords.FVelocity;
end;

procedure TSGAudioRenderSource.SetLooping(const VLooping : TSGBool);
begin
FLooping := VLooping;
if Source <> nil then
	Source.Looping := VLooping;
end;

function  TSGAudioRenderSource.GetLooping() : TSGBool;
begin
Result := FLooping;
end;

procedure TSGAudioRenderSource.SetRelative(const VRelative : TSGBool);
begin
FRelative := VRelative;
if Source <> nil then
	Source.Relative := FRelative;
end;

function TSGAudioRenderSource.GetRelative() : TSGBool;
begin
if Source <> nil then
	Result := Source.Relative
else
	Result := False;
end;

procedure TSGAudioRenderSource.Update();
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

procedure TSGAudioRenderSourceCoords.Clear();
begin
FPosition .Import(0, 0, 0);
FDirection.Import(0, 0, 0);
FVelocity .Import(0, 0, 0);
end;

constructor TSGAudioRenderSource.Create(const VAudioRender : TSGAudioRender);
begin
inherited Create(VAudioRender);
FCoords.Clear();
end;

class function TSGAudioRenderSource.ClassName() : TSGString;
begin
Result := 'TSGAudioRenderSource';
end;

constructor TSGAudioRenderFileSource.Create(const VAudioRender : TSGAudioRender);
begin
inherited Create(VAudioRender);
FFileName := '';
end;

procedure TSGAudioRenderFileSource.SetFile(const VFileName : TSGString);
begin
FFileName := VFileName;
end;

class function TSGAudioRenderFileSource.ClassName() : TSGString;
begin
Result := 'TSGAudioRenderFileSource';
end;

function TSGAudioRender.CreateFileSource(const VFileName : TSGString) : TSGAudioRenderFileSource;
begin
Result := nil;
end;

class function TSGAudioRender.SupporedAudioFormats() : TSGStringList;
begin
Result := nil;
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
