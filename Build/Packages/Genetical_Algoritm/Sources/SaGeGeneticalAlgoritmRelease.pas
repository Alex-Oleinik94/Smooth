{$INCLUDE SaGe.inc}
Unit SaGeGeneticalAlgoritmRelease;
interface
uses 
	crt
	,SaGeBase
	,SaGeBased
	,SaGeGeneticalAlgoritm
	,SaGeScreen
	,SaGeScreenBase
	,SaGeCommonClasses
	,SaGeGraphicViewer
	,SaGeMath
	,SaGePackages
	,SaGeRenderConstants
	,SaGeCommon
	;

{$DEFINE SGREADINTERFACE}
{$INCLUDE SaGeExampleGeneticalAlgoritm.inc}
{$UNDEF SGREADINTERFACE}

implementation

{$DEFINE SGREADIMPLEMENTATION}
{$INCLUDE SaGeExampleGeneticalAlgoritm.inc}
{$UNDEF SGREADIMPLEMENTATION}

initialization
begin
SGRegisterDrawClass(TSGGenAlg);
end;

END.
