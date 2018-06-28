{$INCLUDE SaGe.inc}

unit SaGeConsoleBuildTools;

interface

uses
	 SaGeBase
	,SaGeConsoleCaller
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
procedure SGConsoleDefineSkiper                                (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleVersionTo_RC_WindowsFile                    (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleOpenLastLog                                 (const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	 StrMan
	,Crt
	,Process
	,SysUtils
	
	,SaGeVersion
	,SaGeLists
	,SaGeResourceManager
	,SaGeMakefileReader
	,SaGePackages
	,SaGeStringUtils
	,SaGeConsoleUtils
	,SaGeLog
	,SaGeFileUtils
	,SaGeDefinesSkiper
	;

procedure SGConsoleOpenLastLog(const VParams : TSGConcoleCallerParams = nil);
var
	SL : TSGStringList = nil;
begin
if SGCountConsoleParams(VParams) = 0 then
	begin
	SL := SGDirectoryFiles(SGLogDirectory() + DirectorySeparator);
	SGLog.Source('Opens ' + '"' + SGLogDirectory() + DirectorySeparator + SL[High(SL) - 1] + '"');
	ExecuteProcess('"' + SGLogDirectory() + DirectorySeparator + SL[High(SL) - 1] + '"', []);
	SGKill(SL);
	end
else
	SGHint('Params are not alowed here!');
end;

procedure SGConsoleVersionTo_RC_WindowsFile(const VParams : TSGConcoleCallerParams = nil);
begin
if (SGCountConsoleParams(VParams) = 2) and (SGResourceFiles.FileExists(VParams[0])) then
	SGPushVersionToWindowsResourseFile(VParams[0], VParams[1])
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString, '"@file_name @define_name"');
	end;
end;

procedure SGConsoleDefineSkiper(const VParams : TSGConcoleCallerParams = nil);
begin
if (SGCountConsoleParams(VParams) = 2) and (SGResourceFiles.FileExists(VParams[0])) then
	SGDefinesSkiper(VParams[0], VParams[1])
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString, '"@input_file_name @output_file_name"');
	end;
end;

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
	SGLog.Source(['Current version: ', SGIncEngineVersion((Param='1') or (SGUpCaseString(Param)='TRUE'))]);
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
	WriteLn(SGConsoleErrorString, '"@filename"');
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
var
	Target : TSGString = '';
	Packages : TSGStringList = nil;
	OpenPackages : TSGBool = False;
	Bitrate : TSGByte = 0;

procedure PrintLogo();
begin
TextColor(15);
SGHint('===============================');
SGHint('|Building SaGe from executable|');
SGHint('===============================');
TextColor(7);
end;

function IsRelease() : TSGBool;
begin
Result := 
	(SGUpCaseString(Target) = 'RELEASE') or
	(SGUpCaseString(Target) = 'ANDROID') or
	(SGUpCaseString(Target) = 'RELEASE_X64');
end;

function ReadParams(const Make : TSGMakefileReader) : TSGBool;
var
	i : TSGUInt32;
	AllTargets : TSGStringList = nil;
	S, SUP, P : TSGString;

function Proccess32(const Comand : TSGString):TSGBool;
begin
Result := True;
Bitrate := 32;
end;

function Proccess64(const Comand : TSGString):TSGBool;
begin
Result := True;
Bitrate := 64;
end;

function ProccessPS(const Comand : TSGString):TSGBool;
begin
Result := True;
OpenPackages := True;
end;

function ProccessPackage(const Comand : TSGString):TSGBool;
var
	i : TSGUInt32;
	PackageName : TSGString = '';
begin
if Length(Comand) > 1 then
	begin
	for i := 2 to Length(Comand) do
		PackageName += Comand[i];
	end;
Result := PackageName <> '';
if Result then
	Packages += P;
end;

function ProccessTarget(const Comand : TSGString):TSGBool;
begin
Result := (Target = '') and (SGUpCaseString(Comand) in AllTargets);
if Result then
	Target := Comand;
end;

begin
Result := True;
AllTargets := SGStringListFromString(Make.GetConstant('SG_TARGET_LIST'), ',');
SGStringListTrimAll(AllTargets, ' ');
AllTargets := SGUpCasedStringList(AllTargets, True);
with TSGConsoleCaller.Create(VParams) do
	begin
	Category('Bitrate');
	AddComand(@Proccess32, ['32', 'x32', 'i386'], 'Building 32 bit target');
	AddComand(@Proccess64, ['64', 'x64', '86_64', 'x86_64'], 'Building 64 bit target');
	Category('Packages');
	AddComand(@ProccessPS, ['ps', 'packages', 'pall'], 'Building all open packages');
	AddComand(@ProccessPackage, ['p*?'], 'Building an package');
	Category('Target');
	AddComand(@ProccessTarget, ['*?'], 'Building an target');
	Result := Execute();
	Destroy();
	end;
SetLength(AllTargets, 0);
end;

procedure ExecuteBuild();

procedure ProcessVersionFile(var Make : TSGMakefileReader; const ReleaseVersion : TSGString = 'False');
begin
SGConsoleIncEngineVersion(ReleaseVersion);
SGConvertFileToPascalUnit(
	Make.GetConstant('SGDATAPATH') + DirectorySeparator + 'Engine' + DirectorySeparator + 'version.txt',
	Make.GetConstant('SGRESOURCESPATH'),
	Make.GetConstant('SGRESOURCESCACHEPATH'),
	'SaGeVersionFile',
	True).Hint();
SGRegisterUnit(
	'SaGeVersionFile',
	Make.GetConstant('SGFILEREGISTRATIONRESOURCES'));
end;

procedure ProcessPackages(var Make : TSGMakefileReader);
var
	i : TSGMaxEnum;
begin
if OpenPackages then
	SGPackagesToMakefile(Make, Target, IsRelease);
if Packages <> nil then
	if Length(Packages) > 0 then
		for i := 0 to High(Packages) do
			SGPackageToMakefile(Make, Target, Packages[i], IsRelease);
end;

procedure PrintTarget(const Target : TSGString);
begin
Write('Making target: "');
TextColor(15);
Write(Target);
TextColor(7);
WriteLn('".');
SGLog.Source(['Making target: "',Target,'".']);
end;

var
	Make : TSGMakefileReader = nil;
begin
Make := TSGMakefileReader.Create('.' + DirectorySeparator + 'Makefile');
if not ReadParams(Make) then
	begin
	Make.Destroy();
	Exit;
	end
else
	SGLogMakeSignificant();
PrintLogo();
Make.Execute('clear_files');
if IsRelease then
	begin
	SGBuildFiles(
		Make.GetConstant('SGBUILDPATH') + DirectorySeparator + 'BuildFiles.ini',
		Make.GetConstant('SGRESOURCESPATH'),
		Make.GetConstant('SGRESOURCESCACHEPATH'),
		Make.GetConstant('SGFILEREGISTRATIONRESOURCES'));
	ProcessVersionFile(Make, 'True');
	end
else
	ProcessVersionFile(Make, 'False');
ProcessPackages(Make);
if SGUpCaseString(Target) = 'ANDROID' then
	Bitrate := 32
else if IsRelease() then
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
ExecuteBuild();
SetLength(Packages, 0);
end;

procedure SGConsoleBuildFiles(const VParams : TSGConcoleCallerParams = nil);
begin
SGBuildFiles(VParams[0], VParams[1], VParams[2], VParams[3]);
end;

end.
