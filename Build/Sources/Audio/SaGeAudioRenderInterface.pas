{$INCLUDE SaGe.inc}

unit SaGeAudioRenderInterface;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeRenderBase
	,SaGeCommonStructs
	;

type
	ISGAudioRender = interface;
type
	ISGAudioRender = interface
		['{cb4d7649-16ee-44f6-b9f1-bf393f6bb18c}']
		procedure Initialize();
		procedure Init();
		function CreateDevice() : TSGBool;
		procedure Kill();
		end;

implementation

end.
