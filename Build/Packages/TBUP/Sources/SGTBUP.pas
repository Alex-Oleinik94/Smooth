{$INCLUDE SaGe.inc}

unit SGTBUP;

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
	,TBUP
	;

procedure SGConsoleMB(const VParams : TSGConcoleCallerParams = nil);
begin
if (VParams = nil) or (Length(VParams) = 0) then
	Run_TBUP()
else
	begin
	SGPrintEngineVersion();
	WriteLn('Params is not allowed here!');
	end;
end;

initialization
begin
SGOtherConsoleCaller.AddComand(@SGConsoleMB, ['TBUP'], 'Run TBUP');
end;

END.
