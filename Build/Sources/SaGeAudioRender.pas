{$INCLUDE SaGe.inc}

//{$DEFINE AUDIO_RENDER_DEBUG}

unit SaGeAudioRender;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeClasses
	,SaGeCommon
	;

type
	TSGAudioRender = class;
	TSGAudioRenderClass = class of TSGAudioRender;
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
