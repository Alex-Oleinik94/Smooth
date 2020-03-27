{$INCLUDE Smooth.inc}

unit SmoothAudioRenderInterface;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothRenderBase
	,SmoothCommonStructs
	;

type
	ISAudioRender = interface;
type
	ISAudioRender = interface
		['{cb4d7649-16ee-44f6-b9f1-bf393f6bb18c}']
		procedure Initialize();
		procedure Init();
		function CreateDevice() : TSBool;
		procedure Kill();
		end;

implementation

end.
