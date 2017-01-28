{$INCLUDE SaGe.inc}

unit SaGeGraphicViewer;

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
	,SaGeConsoleToolsBase
	;

{$DEFINE SGREADINTERFACE}
{$INCLUDE SaGeExampleGraphViewer.inc}
{$INCLUDE SaGeExampleGraphViewer3D.inc}
{$UNDEF SGREADINTERFACE}

procedure SGConsoleViewGraphic(const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	 SaGeConsoleTools
	,SaGeConsolePaintableTools
	;

{$DEFINE SGREADIMPLEMENTATION}
{$INCLUDE SaGeExampleGraphViewer.inc}
{$INCLUDE SaGeExampleGraphViewer3D.inc}
{$UNDEF SGREADIMPLEMENTATION}

procedure SGConsoleViewGraphic(const VParams : TSGConcoleCallerParams = nil);
begin
SGHint('Todo...');
end;

initialization
begin
(*
	Add(TSGGraphViewer);
	//Add(TSGGraphic);
	//Add(TSGGraphViewer3D);
*)
SGRegisterDrawClass(TSGGraphViewer);
SGOtherConsoleCaller.AddComand('Math tools', @SGConsoleViewGraphic, ['vg'], 'View graphic');
end;

END.
