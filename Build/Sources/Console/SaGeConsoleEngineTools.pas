{$INCLUDE SaGe.inc}

unit SaGeConsoleEngineTools;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeConsoleToolsBase
	;

procedure SGConsoleAddToLog                              (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleExtractFiles                          (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleWriteOpenableExpansions               (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleWriteFiles                            (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleDllPrintStat                          (const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	StrMan
	
	,SaGeVersion
	,SaGeResourceManager
	,SaGeDllManager
	,SaGeFileOpener
	;

procedure SGConsoleAddToLog(const VParams : TSGConcoleCallerParams = nil);
begin
if (SGCountConsoleParams(VParams) = 2) and SGResourceFiles.FileExists(VParams[0]) then
	SGAddToLog(VParams[0],VParams[1])
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString,'"@log_file_name @line"');
	end;
end;

procedure SGConsoleExtractFiles(const VParams : TSGConcoleCallerParams = nil);
var
	Param : TSGString;
begin
if ((SGCountConsoleParams(VParams) = 1) or ((SGCountConsoleParams(VParams) = 2) and (SGIsBoolConsoleParam(VParams[1])))) and SGExistsDirectory(VParams[0]) then
	begin
	Param := 'false';
	if SGCountConsoleParams(VParams) = 2 then
		Param := VParams[1];
	SGResourceFiles.ExtractFiles(VParams[0],(SGUpCaseString(Param) = 'TRUE') or (Param = '1'));
	end
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString,'"@outdirname @flag", @flag is true when need to keeps file system file names');
	end;
end;

procedure SGConsoleWriteOpenableExpansions(const VParams : TSGConcoleCallerParams = nil);
begin
if (VParams <> nil) and (Length(VParams) > 0) then
	begin
	SGPrintEngineVersion();
	WriteLn('Params is not allowed here!');
	end
else
	SGWriteOpenableExpansions();
end;

procedure SGConsoleWriteFiles(const VParams : TSGConcoleCallerParams = nil);
begin
if (VParams <> nil) and (Length(VParams) > 0) then
	begin
	SGPrintEngineVersion();
	WriteLn('Params is not allowed here!');
	end
else
	SGResourceFiles.WriteFiles();
end;

procedure SGConsoleDllPrintStat(const VParams : TSGConcoleCallerParams = nil);
var
	Dll : TSGDll;
begin
if (VParams <> nil) and (Length(VParams) > 0) then
	begin
	Dll := nil;
	if Length(VParams) = 1 then
		begin
		Dll := DllManager.Dll(VParams[0]);
		if Dll <> nil then
			begin
			SGPrintEngineVersion();
			Dll.PrintStat(True);
			end;
		end;
	if Dll = nil then
		begin
		SGPrintEngineVersion();
		WriteLn(SGConsoleErrorString,'"[@library]". Param @library is Engine''s name of this Library.');
		end;
	end
else
	DllManager.PrintStat();
end;

end.
