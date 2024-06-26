{$INCLUDE Smooth.inc}

unit SmoothConsoleEngineTools;

interface

uses
	 SmoothBase
	,SmoothConsoleHandler
	;

procedure SConsoleAddToLog                              (const VParams : TSConsoleHandlerParams = nil);
procedure SConsoleExtractFiles                          (const VParams : TSConsoleHandlerParams = nil);
procedure SConsoleWriteOpenableExtensions               (const VParams : TSConsoleHandlerParams = nil);
procedure SConsoleWriteFiles                            (const VParams : TSConsoleHandlerParams = nil);
procedure SConsoleDllPrintStat                          (const VParams : TSConsoleHandlerParams = nil);

implementation

uses
	StrMan
	
	,SmoothVersion
	,SmoothResourceManager
	,SmoothDllManager
	,SmoothFileOpener
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothLog
	;

procedure SConsoleAddToLog(const VParams : TSConsoleHandlerParams = nil);
begin
if (SCountConsoleParams(VParams) = 2) and SResourceFiles.FileExists(VParams[0]) then
	SAddToLog(VParams[0],VParams[1])
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString,'"@log_file_name @line".');
	end;
end;

procedure SConsoleExtractFiles(const VParams : TSConsoleHandlerParams = nil);
var
	Param : TSString;
begin
if ((SCountConsoleParams(VParams) = 1) or ((SCountConsoleParams(VParams) = 2) and (SIsBoolConsoleParam(VParams[1])))) and SExistsDirectory(VParams[0]) then
	begin
	Param := 'false';
	if SCountConsoleParams(VParams) = 2 then
		Param := VParams[1];
	SResourceFiles.ExtractFiles(VParams[0],(SUpCaseString(Param) = 'TRUE') or (Param = '1'));
	end
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString,'"@outdirname @flag"; @flag is "true" when keep file system file names.');
	end;
end;

procedure SConsoleWriteOpenableExtensions(const VParams : TSConsoleHandlerParams = nil);
begin
if (VParams <> nil) and (Length(VParams) > 0) then
	begin
	SPrintEngineVersion();
	WriteLn('Params is not allowed here!');
	end
else
	SWriteOpenableExtensions();
end;

procedure SConsoleWriteFiles(const VParams : TSConsoleHandlerParams = nil);
begin
if (VParams <> nil) and (Length(VParams) > 0) then
	begin
	SPrintEngineVersion();
	WriteLn('Params is not allowed here!');
	end
else
	SResourceFiles.WriteFiles();
end;

procedure SConsoleDllPrintStat(const VParams : TSConsoleHandlerParams = nil);
var
	Dll : TSDll;
begin
if (VParams <> nil) and (Length(VParams) > 0) then
	begin
	Dll := nil;
	if Length(VParams) = 1 then
		begin
		Dll := DllManager.Dll(VParams[0]);
		if Dll <> nil then
			begin
			SPrintEngineVersion();
			Dll.PrintStat(True);
			end;
		end;
	if Dll = nil then
		begin
		SPrintEngineVersion();
		WriteLn(SConsoleErrorString,'"[@library]". Param @library is name of this library of engine.');
		end;
	end
else
	DllManager.PrintStat();
end;

end.
