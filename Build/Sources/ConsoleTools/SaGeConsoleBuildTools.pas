{$INCLUDE SaGe.inc}

unit SaGeConsoleBuildTools;

interface

uses
	 SaGeBase
	,SaGeConsoleToolsBase
	;

procedure SGConsoleBuildFiles                                  (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleBuild                                       (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleClearFileRegistrationResources              (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleClearFileRegistrationPackages               (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleConvertFileToPascalUnitAndRegisterUnit      (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleIncEngineVersion                            (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleConvertDirectoryFilesToPascalUnits          (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleConvertFileToPascalUnit                     (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleConvertCachedFileToPascalUnitAndRegisterUnit(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleIsConsole                                   (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleMake                                        (const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	 StrMan
	,Crt
	,Process
	
	,SaGeVersion
	,SaGeResourceManager
	,SaGeMakefileReader
	,SaGePackages
	,SaGeStringUtils
	,SaGeConsoleUtils
	,SaGeLog
	,SaGeFileUtils
	;

procedure SGConsoleMake(const VParams : TSGConcoleCallerParams = nil);
var
	Make : TSGMakefileReader;
	Param : TSGString;
begin
Make := TSGMakefileReader.Create('./Makefile');
if (VParams = nil) or (Length(VParams) = 0) then
	Param := ''
else
	Param := VParams[0];
Make.Execute(Param);
Make.Destroy();
end;

procedure SGConsoleIsConsole(const VParams : TSGConcoleCallerParams = nil);
begin
Halt(TSGByte(SGIsConsole()));
end;

procedure SGConsoleConvertDirectoryFilesToPascalUnits(const VParams : TSGConcoleCallerParams = nil);
begin
if (SGCountConsoleParams(VParams) = 3) and SGResourceFiles.FileExists(VParams[2]) and SGExistsDirectory(VParams[0])and SGExistsDirectory(VParams[1]) then
	SGConvertDirectoryFilesToPascalUnits(VParams[0],VParams[1],'',VParams[2])
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString,'"@dir_name @out_dir_name @file_registration_resources_path"');
	end;
end;

procedure SGConsoleConvertFileToPascalUnit(const VParams : TSGConcoleCallerParams = nil);
var
	Param : TSGString;
begin
if ((SGCountConsoleParams(VParams) = 3) or ((SGCountConsoleParams(VParams) = 4) and (SGIsBoolConsoleParam(VParams[3])))) and SGResourceFiles.FileExists(VParams[0]) and SGExistsDirectory(VParams[1]) then
	begin
	Param := 'false';
	if SGCountConsoleParams(VParams) = 4 then
		Param := VParams[3];
	SGConvertFileToPascalUnit(VParams[0],VParams[1],VParams[2],(SGUpCaseString(Param)<>'FALSE') and (Param <> '0'));
	end
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString,'"@filename @outdirname @unitname @flag", @flag is true if needs to register file in manager when it was compiled');
	end;
end;

procedure SGConsoleIncEngineVersion(const VParams : TSGConcoleCallerParams = nil);
var
	Param : TSGString;
begin
if  (SGCountConsoleParams(VParams) = 0) or
	((SGCountConsoleParams(VParams) = 1) and (SGIsBoolConsoleParam(VParams[0]))) then
	begin
	if SGCountConsoleParams(VParams) = 1 then
		Param := VParams[0]
	else
		Param := 'false';
	SGIncEngineVersion((Param='1') or (SGUpCaseString(Param)='TRUE'))
	end
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString,'"@flag", @flag is true when version is release');
	end;
end;

procedure SGConsoleConvertCachedFileToPascalUnitAndRegisterUnit(const VParams : TSGConcoleCallerParams = nil);
var
	ii : TSGLongWord;
begin
ii := 0;
if (VParams <> nil) then
	ii := Length(VParams);
if (ii = 5) and SGResourceFiles.FileExists(VParams[0]) and SGResourceFiles.FileExists(VParams[4]) and SGExistsDirectory(VParams[1]) then
	begin
	SGConvertFileToPascalUnit(VParams[0],VParams[1],VParams[2],VParams[3],True).Print();
	SGRegisterUnit(VParams[3],VParams[4]);
	end
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString,'"@file_path @unit_dir @cache_dir @unit_name @registration_file_path"');
	end;
end;

procedure SGConsoleConvertFileToPascalUnitAndRegisterUnit(const VParams : TSGConcoleCallerParams = nil);
var
	ii : TSGLongWord;
begin
ii := 0;
if (VParams <> nil) then
	ii := Length(VParams);
if (ii = 4) and SGResourceFiles.FileExists(VParams[0]) and SGResourceFiles.FileExists(VParams[3]) and SGExistsDirectory(VParams[1]) then
	begin
	SGConvertFileToPascalUnit(VParams[0],VParams[1],VParams[2],True).Print();
	SGRegisterUnit(VParams[2],VParams[3]);
	end
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString,'"@file_path @unit_dir @unit_name @registration_file_path"');
	end;
end;

procedure SGConsoleClearFileRegistrationPackages(const VParams : TSGConcoleCallerParams = nil);
begin
if (VParams <> nil) and (Length(VParams) = 1) and (VParams[0] <> '') then
	SGClearFileRegistrationPackages(VParams[0])
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString,'"@filename"');
	end;
end;

procedure SGConsoleClearFileRegistrationResources(const VParams : TSGConcoleCallerParams = nil);
begin
if (VParams <> nil) and (Length(VParams) = 1) and (VParams[0] <> '') then
	SGClearFileRegistrationResources(VParams[0])
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString,'"@filename"');
	end;
end;

procedure SGConsoleBuild(const VParams : TSGConcoleCallerParams = nil);
const
	BuildComand = 
		{$IF defined(MSWINDOWS)}
			'cmd.exe /C "cd ./../Build/Scripts & _Make_Debug.bat false false"'
		{$ELSEIF defined(LINUX)}
			''
		{$ELSE}
			''
			{$ENDIF};

function ConsoleParam() : TSGString;
begin
Result := StringTrimAll(SGStringFromStringList(VParams,' '),' ');
end;

var
	Target : TSGString = '';
	Packages : TSGStringList = nil;
	OpenPackages : TSGBool = False;
	Bitrate : TSGByte = 0;

function IsRelease() : TSGBool;
begin
Result := 
	(SGUpCaseString(Target) = 'RELEASE') or
	(SGUpCaseString(Target) = 'RELEASE_X64');
end;

function ReadParams(const Make : TSGMakefileReader) : TSGBool;

procedure ReadError(const S : TSGString);
begin
WriteLn('Error simbol "', S, '"');
Result := False;
end;

function GetPackageNameFromComandName(const C : TSGString) : TSGString;
var
	i : TSGUInt32;
begin
Result := '';
if Length(C) > 1 then
	begin
	for i := 2 to Length(C) do
		Result += C[i];
	end;
end;

var
	i : TSGUInt32;
	AllTargets : TSGStringList = nil;
	S, SUP, P : TSGString;
begin
Result := True;
AllTargets := SGStringListFromString(Make.GetConstant('SG_TARGET_LIST'),',');
if AllTargets <> nil then if Length(AllTargets) > 0 then
	for i := 0 to High(AllTargets) do
		AllTargets[i] := SGUpCaseString(StringTrimAll(AllTargets[i],' '));
if ConsoleParam() = '' then
	exit
else 
	if VParams <> nil then
		if Length(VParams) > 0 then
		begin
		for i := 0 to High(VParams) do
			begin
			if (StringTrimLeft(VParams[i],'-') <> VParams[i]) then
				begin
				S := StringTrimLeft(VParams[i],'-');
				SUP := SGUpCaseString(S);
				if (SUP = 'PS') or
				   (SUP = 'PACKAGES') or
				   (SUP = 'PALL') then
					OpenPackages := True
				else if (SUP = '32') or
				   (SUP = '64') or
				   (SUP = 'X32') or
				   (SUP = 'X86') or
				   (SUP = '86') or
				   (SUP = 'X64') or
				   (SUP = 'I386') or
				   (SUP = '86_64') or
				   (SUP = 'X86_64') then
					begin
					if  (SUP = '32') or
						(SUP = 'X32') or
						(SUP = 'I386')  then
							Bitrate := 32
					else if (SUP = 'X86') or
						(SUP = '86') or
						(SUP = 'X64') or
						(SUP = '64') or
						(SUP = '86_64') or
						(SUP = 'X86_64') then
							Bitrate := 64;
					end
				else
					begin
					if Length(SUP) > 0 then
						begin
						if SUP[1] = 'P' then
							begin
							P := GetPackageNameFromComandName(S);
							if P = '' then
								ReadError(VParams[i])
							else
								Packages += P;
							end
						else
							ReadError(VParams[i]);
						end
					else
						ReadError(VParams[i]);
					end;
				end
			else
				begin
				if (SGUpCaseString(VParams[i]) in AllTargets) and (i = High(VParams)) then
					begin
					Target := VParams[i];
					end
				else
					ReadError(VParams[i]);
				end;
			end;
		end;
SetLength(AllTargets, 0);
end;

procedure ExecuteBuild();

procedure ProcessVersionFile(var Make : TSGMakefileReader; const ReleaseVersion : TSGString = 'False');
begin
SGConsoleIncEngineVersion(ReleaseVersion);
SGConvertFileToPascalUnit(
	Make.GetConstant('SGDATAPATH') + '/Engine/version.txt',
	Make.GetConstant('SGRESOURCESPATH'),
	Make.GetConstant('SGRESOURCESCACHEPATH'),
	'SaGeVersionFile',
	True).Print();
SGRegisterUnit(
	'SaGeVersionFile',
	Make.GetConstant('SGFILEREGISTRATIONRESOURCES'));
end;

procedure ProcessPackages(var Make : TSGMakefileReader);
var
	i : TSGUInt32;
begin
if OpenPackages then
	SGPackagesToMakefile(Make, IsRelease);
if Packages <> nil then
	if Length(Packages) > 0 then
		for i := 0 to High(Packages) do
			SGPackageToMakefile(Make, Packages[i], IsRelease);
end;

procedure PrintTarget(const Target : TSGString);
begin
Write('Making target: "');
TextColor(15);
Write(Target);
TextColor(7);
WriteLn('".');
end;

var
	Make : TSGMakefileReader = nil;
begin
Make := TSGMakefileReader.Create('./Makefile');
if not ReadParams(Make) then
	begin
	Make.Destroy();
	WriteLn('Error while reading console params!');
	Halt(1);
	end;
Make.Execute('clear_files');
if IsRelease then
	begin
	SGBuildFiles(
		Make.GetConstant('SGBUILDPATH') + '/BuildFiles.ini',
		Make.GetConstant('SGRESOURCESPATH'),
		Make.GetConstant('SGRESOURCESCACHEPATH'),
		Make.GetConstant('SGFILEREGISTRATIONRESOURCES'));
	ProcessVersionFile(Make,'True');
	end
else
	ProcessVersionFile(Make,'False');
ProcessPackages(Make);
if IsRelease() then
	begin
	if Bitrate = 32 then
		Target := 'release_x32'
	else if Bitrate = 64 then
		Target := 'release_x64';
	end
else
	begin
	if Bitrate = 32 then
		Target := 'debug_x32'
	else if Bitrate = 64 then
		Target := 'debug_x64';
	end;
PrintTarget(Target);
Make.Execute(Target);
Make.Execute('clear_files');
Make.Destroy();
end;

begin
SGPrintEngineVersion();
TextColor(15);
SGHint('===============================');
SGHint('|Building SaGe from executable|');
SGHint('===============================');
TextColor(7);
ExecuteBuild();
SetLength(Packages, 0);
end;

procedure SGConsoleBuildFiles(const VParams : TSGConcoleCallerParams = nil);
begin
SGBuildFiles(VParams[0],VParams[1],VParams[2],VParams[3]);
end;

end.
