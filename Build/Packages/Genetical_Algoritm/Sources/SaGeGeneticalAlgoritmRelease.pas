{$INCLUDE SaGe.inc}

unit SaGeGeneticalAlgoritmRelease;

interface

uses 
	 Crt
	
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

uses
	 SaGeStringUtils
	;

{$DEFINE SGREADIMPLEMENTATION}
{$INCLUDE SaGeExampleGeneticalAlgoritm.inc}
{$UNDEF SGREADIMPLEMENTATION}

initialization
begin
SGRegisterDrawClass(TSGGenAlg);
end;

END.
