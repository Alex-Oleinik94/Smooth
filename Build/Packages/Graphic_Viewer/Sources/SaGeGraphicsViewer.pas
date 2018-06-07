{$INCLUDE SaGe.inc}

unit SaGeGraphicsViewer;

interface

uses 
	 SaGeConsoleCaller
	;

procedure SGConsoleViewGraphic(const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	 SaGeConsoleTools
	,SaGePackages
	,SaGeLog
	
	,SaGeGraphicViewer
	,SaGeGraphicViewer3D
	;

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
