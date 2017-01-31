{$INCLUDE SaGe.inc}

unit MBPackage;

interface

uses 
	 SaGeBase
	,SaGeConsoleToolsBase
	;

procedure SGConsoleMB(const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	 SaGeConsoleTools
	,SaGeVersion
	,MB
	;

procedure SGConsoleMB(const VParams : TSGConcoleCallerParams = nil);
begin
if (VParams = nil) or (Length(VParams) = 0) then
	Run_MB()
else
	begin
	SGPrintEngineVersion();
	WriteLn('Params is not allowed here!');
	end;
end;

initialization
begin
SGOtherConsoleCaller.AddComand(@SGConsoleMB, ['mb'], 'Run MB');
end;

END.
