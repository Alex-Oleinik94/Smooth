{$INCLUDE SaGe.inc}

unit SaGeExamples;

interface
uses
	 SaGeCommon
	,Classes
	,SaGeMesh
	,SaGeFractals
	,SaGeUtils
	,SaGeContext
	,SaGeScreen
	,SaGeNet
	,SaGeMath
	,SaGeGeneticalAlgoritm
	,SaGeBase
	,SaGeBased
	,SaGeRender
	,SaGeImages
	,SaGeRenderConstants
	,SaGeCommonClasses
	,SaGeScreenBase
	;

{$DEFINE SGREADINTERFACE}
{$INCLUDE SaGeExampleGraphViewer.inc}
{$INCLUDE SaGeExampleGeneticalAlgoritm.inc}
{$INCLUDE SaGeExampleGraphViewer3D.inc}
{$UNDEF SGREADINTERFACE}

implementation

{$DEFINE SGREADIMPLEMENTATION}
{$INCLUDE SaGeExampleGraphViewer.inc}
{$INCLUDE SaGeExampleGeneticalAlgoritm.inc}
{$INCLUDE SaGeExampleGraphViewer3D.inc}
{$UNDEF SGREADIMPLEMENTATION}

end.
