{$INCLUDE Smooth.inc}

unit SmoothGraphicsViewer;

interface

uses 
	 SmoothConsoleHandler
	;

procedure SConsoleViewGraphic(const VParams : TSConsoleHandlerParams = nil);

implementation

uses
	 SmoothConsoleTools
	,SmoothExtensionManager
	,SmoothLog
	
	,SmoothGraphicViewer
	,SmoothGraphicViewer3D
	;

procedure SConsoleViewGraphic(const VParams : TSConsoleHandlerParams = nil);
begin
SHint('Todo.');
end;

initialization
begin
(*
	Add(TSGraphViewer);
	//Add(TSGraphic);
	//Add(TSGraphViewer3D);
*)
SRegisterDrawClass(TSGraphViewer);
SConsoleToolsConsoleHandler.AddComand('Math tools', @SConsoleViewGraphic, ['vg'], 'View graphic');
end;

END.
