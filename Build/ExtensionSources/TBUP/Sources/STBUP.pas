{$INCLUDE Smooth.inc}

unit STBUP;

interface

uses 
	 SmoothBase
	,SmoothConsoleCaller
	;

procedure SConsoleMB(const VParams : TSConcoleCallerParams = nil);

implementation

uses
	 SmoothConsoleTools
	,SmoothVersion
	,TBUP
	;

procedure SConsoleMB(const VParams : TSConcoleCallerParams = nil);
begin
if (VParams = nil) or (Length(VParams) = 0) then
	Run_TBUP()
else
	begin
	SPrintEngineVersion();
	WriteLn('Params is not allowed here!');
	end;
end;

initialization
begin
SOtherConsoleCaller.AddComand(@SConsoleMB, ['TBUP'], 'Run TBUP');
end;

END.
