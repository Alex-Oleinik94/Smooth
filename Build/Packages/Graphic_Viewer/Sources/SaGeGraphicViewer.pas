{$INCLUDE SaGe.inc}
Unit SaGeGraphicViewer;
interface
uses 
	crt
	,SaGeBase
	,SaGeBased
	,SaGeGeneticalAlgoritm
	,SaGeScreen
	,SaGeCommonClasses
	,SaGeFractals
	,SaGeCommon
	,SaGeMath
	,SaGeImages
	,SaGeRenderConstants
	,SaGeMesh
	,SaGePackages
	;

{$DEFINE SGREADINTERFACE}
{$INCLUDE SaGeExampleGraphViewer.inc}
{$INCLUDE SaGeExampleGraphViewer3D.inc}
{$UNDEF SGREADINTERFACE}

implementation

{$DEFINE SGREADIMPLEMENTATION}
{$INCLUDE SaGeExampleGraphViewer.inc}
{$INCLUDE SaGeExampleGraphViewer3D.inc}
{$UNDEF SGREADIMPLEMENTATION}

initialization
begin
(*
	Add(TSGGraphViewer);
	//Add(TSGGraphic);
	//Add(TSGGraphViewer3D);
*)
SGRegisterDrawClass(TSGGraphViewer);
end;

END.
