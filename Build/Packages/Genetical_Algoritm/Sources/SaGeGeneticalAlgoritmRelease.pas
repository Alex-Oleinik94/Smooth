{$INCLUDE SaGe.inc}

unit SaGeGeneticalAlgoritmRelease;

interface

uses 
	 Crt
	
	,SaGeBase
	,SaGeGeneticalAlgoritm
	,SaGeScreen
	,SaGeScreenBase
	,SaGeCommonClasses
	,SaGeGraphicViewer
	,SaGeMath
	,SaGePackages
	,SaGeRenderBase
	,SaGeCommon
	;

{$DEFINE SGREADINTERFACE}
{$INCLUDE SaGeExampleGeneticalAlgoritm.inc}
{$UNDEF SGREADINTERFACE}

implementation

uses
	 SaGeStringUtils
	,SaGeMathUtils
	;

{$DEFINE SGREADIMPLEMENTATION}
{$INCLUDE SaGeExampleGeneticalAlgoritm.inc}
{$UNDEF SGREADIMPLEMENTATION}

initialization
begin
SGRegisterDrawClass(TSGGenAlg);
end;

END.
