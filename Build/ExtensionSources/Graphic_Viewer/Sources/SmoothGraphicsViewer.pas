{$INCLUDE Smooth.inc}

unit SmoothGraphicsViewer;

interface

uses 
	 SmoothConsoleCaller
	;

procedure SConsoleViewGraphic(const VParams : TSConcoleCallerParams = nil);

implementation

uses
	 SmoothConsoleTools
	,SmoothExtensionManager
	,SmoothLog
	
	,SmoothGraphicViewer
	,SmoothGraphicViewer3D
	;

procedure SConsoleViewGraphic(const VParams : TSConcoleCallerParams = nil);
begin
SHint('Todo...');
end;

initialization
begin
(*
	Add(TSGraphViewer);
	//Add(TSGraphic);
	//Add(TSGraphViewer3D);
*)
SRegisterDrawClass(TSGraphViewer);
SOtherConsoleCaller.AddComand('Math tools', @SConsoleViewGraphic, ['vg'], 'View graphic');
end;

END.
