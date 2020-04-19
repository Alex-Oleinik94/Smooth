{$INCLUDE Smooth.inc}

unit STBUP;

interface

uses 
	 SmoothBase
	,SmoothConsoleHandler
	;

procedure SConsoleMB(const VParams : TSConsoleHandlerParams = nil);

implementation

uses
	 SmoothConsoleTools
	,SmoothVersion
	,TBUP
	;

procedure SConsoleMB(const VParams : TSConsoleHandlerParams = nil);
begin
if (VParams = nil) or (Length(VParams) = 0) then
	Run_TBUP()
else
	begin
	SPrintEngineVersion();
	WriteLn('Params is not allowed here.');
	end;
end;

initialization
begin
SConsoleToolsConsoleHandler.AddComand(@SConsoleMB, ['TBUP'], 'Run "TBUP"');
end;

END.
