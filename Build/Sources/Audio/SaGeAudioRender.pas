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

	TSGAudioRenderSourceCoords = object
			public
		FPosition  : TSGVector3f;
		FDirection : TSGVector3f;
		FVelocity  : TSGVector3f;
			public
		procedure Clear();
		end;

	TSGAudioRenderSource = class(TSGAudioRenderObject)
			public
		constructor Create(const VAudioRender : TSGAudioRender); override;
		class function ClassName() : TSGString; override;
			protected
		FCoords : TSGAudioRenderSourceCoords;
			public
		procedure UpdateSource(); virtual; abstract;
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
