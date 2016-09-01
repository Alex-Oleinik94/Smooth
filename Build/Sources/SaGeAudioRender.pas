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
		class function Suppored() : TSGBool; virtual;
		class function ClassName() : TSGString; override;
		end;

function TSGCompatibleAudioRender():TSGAudioRenderClass;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	Crt
	{$IFNDEF MOBILE}
	,SaGeAudioRenderOpenAL
	{$ENDIF}
	;

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
