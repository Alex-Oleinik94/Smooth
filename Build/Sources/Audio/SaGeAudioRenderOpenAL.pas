{$INCLUDE SaGe.inc}

//{$DEFINE OPENAL_RENDER_DEBUG}

unit SaGeAudioRenderOpenAL;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeClasses
	,SaGeCommon
	,SaGeAudioRender

	,OpenAL
	;

type
	TSGAudioRenderOpenAL = class(TSGAudioRender)
			public
		class function Suppored() : TSGBool; override;
		class function ClassName() : TSGString; override;
		end;

implementation

uses
	SaGeDllManager
	;

class function TSGAudioRenderOpenAL.ClassName() : TSGString;
begin
Result := 'TSGAudioRenderOpenAL';
end;

class function TSGAudioRenderOpenAL.Suppored() : TSGBool;
begin
Result := DllManager.Suppored('OpenAL');
end;

end.
