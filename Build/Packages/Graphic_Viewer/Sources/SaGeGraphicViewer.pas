{$INCLUDE SaGe.inc}

unit SaGeGraphicViewer;

interface

uses 
	Crt
	
	,SaGeBase
	,SaGeGeneticalAlgoritm
	,SaGeScreen
	,SaGeCommonClasses
	,SaGeFractals
	,SaGeCommon
	,SaGeMath
	,SaGeImage
	,SaGeRenderBase
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
	,SaGeStringUtils
	,SaGeFileUtils
	,SaGeLog
	,SaGeMathUtils
	,SaGeBaseUtils
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
