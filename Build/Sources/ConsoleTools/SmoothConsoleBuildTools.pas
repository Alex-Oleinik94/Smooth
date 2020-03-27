{$INCLUDE Smooth.inc}

unit SmoothConsoleBuildTools;

interface

uses
	 SmoothBase
	,SmoothConsoleCaller
	;

procedure SConsoleBuildFiles                                  (const VParams : TSConcoleCallerParams = nil);
procedure SConsoleBuild                                       (const VParams : TSConcoleCallerParams = nil);
procedure SConsoleClearFileRegistrationResources              (const VParams : TSConcoleCallerParams = nil);
procedure SConsoleClearFileForRegistrationExtensions          (const VParams : TSConcoleCallerParams = nil);
procedure SConsoleConvertFileToPascalUnitAndRegisterUnit      (const VParams : TSConcoleCallerParams = nil);
procedure SConsoleIncEngineVersion                            (const VParams : TSConcoleCallerParams = nil);
procedure SConsoleConvertDirectoryFilesToPascalUnits          (const VParams : TSConcoleCallerParams = nil);
procedure SConsoleConvertFileToPascalUnit                     (const VParams : TSConcoleCallerParams = nil);
procedure SConsoleConvertCachedFileToPascalUnitAndRegisterUnit(const VParams : TSConcoleCallerParams = nil);
procedure SConsoleIsConsole                                   (const VParams : TSConcoleCallerParams = nil);
procedure SConsoleMake                                        (const VParams : TSConcoleCallerParams = nil);
procedure SConsoleDefineSkiper                                (const VParams : TSConcoleCallerParams = nil);
procedure SConsoleVersionTo_RC_WindowsFile                    (const VParams : TSConcoleCallerParams = nil);
procedure SConsoleOpenLastLog                                 (const VParams : TSConcoleCallerParams = nil);

implementation

uses
	 StrMan
	,Crt
	,Process
	,SysUtils
	
	,SmoothVersion
	,SmoothLists
	,SmoothResourceManager
	,SmoothMakefileReader
	,SmoothExtensionManager
	,SmoothStringUtils
	,SmoothConsoleUtils
	,SmoothLog
	,SmoothFileUtils
	,SmoothDefinesSkiper
	;

procedure SConsoleOpenLastLog(const VParams : TSConcoleCallerParams = nil);
var
	SL : TSStringList = nil;
begin
if SCountConsoleParams(VParams) = 0 then
	begin
	SL := SDirectoryFiles(SLogDirectory() + DirectorySeparator);
	SLog.Source('Opens ' + '"' + SLogDirectory() + DirectorySeparator + SL[High(SL) - 1] + '"');
	ExecuteProcess('"' + SLogDirectory() + DirectorySeparator + SL[High(SL) - 1] + '"', []);
	SKill(SL);
	end
else
	SHint('Params are not alowed here!');
end;

procedure SConsoleVersionTo_RC_WindowsFile(const VParams : TSConcoleCallerParams = nil);
begin
if (SCountConsoleParams(VParams) = 2) and (SResourceFiles.FileExists(VParams[0])) then
	SPushVersionToWindowsResourseFile(VParams[0], VParams[1])
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString, '"@file_name @define_name"');
	end;
end;

procedure SConsoleDefineSkiper(const VParams : TSConcoleCallerParams = nil);
begin
if (SCountConsoleParams(VParams) = 2) and (SResourceFiles.FileExists(VParams[0])) then
	SDefinesSkiper(VParams[0], VParams[1])
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString, '"@input_file_name @output_file_name"');
	end;
end;

procedure SConsoleMake(const VParams : TSConcoleCallerParams = nil);
var
	Make : TSMakefileReader;
	Param : TSString;
begin
Make := TSMakefileReader.Create('./Makefile');
if (VParams = nil) or (Length(VParams) = 0) then
	Param := ''
else
	Param := VParams[0];
Make.Execute(Param);
Make.Destroy();
end;

procedure SConsoleIsConsole(const VParams : TSConcoleCallerParams = nil);
begin
Halt(TSByte(SIsConsole()));
end;

procedure SConsoleConvertDirectoryFilesToPascalUnits(const VParams : TSConcoleCallerParams = nil);
begin
if (SCountConsoleParams(VParams) = 3) and SResourceFiles.FileExists(VParams[2]) and SExistsDirectory(VParams[0])and SExistsDirectory(VParams[1]) then
	SConvertDirectoryFilesToPascalUnits(VParams[0],VParams[1],'',VParams[2])
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString,'"@dir_name @out_dir_name @file_registration_resources_path"');
	end;
end;

procedure SConsoleConvertFileToPascalUnit(const VParams : TSConcoleCallerParams = nil);
var
	Param : TSString;
begin
if ((SCountConsoleParams(VParams) = 3) or ((SCountConsoleParams(VParams) = 4) and (SIsBoolConsoleParam(VParams[3])))) and SResourceFiles.FileExists(VParams[0]) and SExistsDirectory(VParams[1]) then
	begin
	Param := 'false';
	if SCountConsoleParams(VParams) = 4 then
		Param := VParams[3];
	SConvertFileToPascalUnit(VParams[0],VParams[1],VParams[2],(SUpCaseString(Param)<>'FALSE') and (Param <> '0'));
	end
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString,'"@filename @outdirname @unitname @flag", @flag is true if needs to register file in manager when it was compiled');
	end;
end;

procedure SConsoleIncEngineVersion(const VParams : TSConcoleCallerParams = nil);
var
	Param : TSString;
begin
if  (SCountConsoleParams(VParams) = 0) or
	((SCountConsoleParams(VParams) = 1) and (SIsBoolConsoleParam(VParams[0]))) then
	begin
	if SCountConsoleParams(VParams) = 1 then
		Param := VParams[0]
	else
		Param := 'false';
	SLog.Source(['Current version: ', SIncEngineVersion((Param='1') or (SUpCaseString(Param)='TRUE'))]);
	end
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString,'"@flag", @flag is true when version is release');
	end;
end;

procedure SConsoleConvertCachedFileToPascalUnitAndRegisterUnit(const VParams : TSConcoleCallerParams = nil);
var
	ii : TSLongWord;
begin
ii := 0;
if (VParams <> nil) then
	ii := Length(VParams);
if (ii = 5) and SResourceFiles.FileExists(VParams[0]) and SResourceFiles.FileExists(VParams[4]) and SExistsDirectory(VParams[1]) then
	begin
	SConvertFileToPascalUnit(VParams[0],VParams[1],VParams[2],VParams[3],True).Print();
	SRegisterUnit(VParams[3],VParams[4]);
	end
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString,'"@file_path @unit_dir @cache_dir @unit_name @registration_file_path"');
	end;
end;

procedure SConsoleConvertFileToPascalUnitAndRegisterUnit(const VParams : TSConcoleCallerParams = nil);
var
	ii : TSLongWord;
begin
ii := 0;
if (VParams <> nil) then
	ii := Length(VParams);
if (ii = 4) and SResourceFiles.FileExists(VParams[0]) and SResourceFiles.FileExists(VParams[3]) and SExistsDirectory(VParams[1]) then
	begin
	SConvertFileToPascalUnit(VParams[0],VParams[1],VParams[2],True).Print();
	SRegisterUnit(VParams[2],VParams[3]);
	end
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString,'"@file_path @unit_dir @unit_name @registration_file_path"');
	end;
end;

procedure SConsoleClearFileForRegistrationExtensions(const VParams : TSConcoleCallerParams = nil);
begin
if (VParams <> nil) and (Length(VParams) = 1) and (VParams[0] <> '') then
	SClearFileForRegistrationExtensions(VParams[0])
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString,'"@filename"');
	end;
end;

procedure SConsoleClearFileRegistrationResources(const VParams : TSConcoleCallerParams = nil);
begin
if (VParams <> nil) and (Length(VParams) = 1) and (VParams[0] <> '') then
	SClearFileRegistrationResources(VParams[0])
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString, '"@filename"');
	end;
end;

procedure SConsoleBuild(const VParams : TSConcoleCallerParams = nil);
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
	Target : TSString = '';
	Extensions : TSStringList = nil;
	OpenExtensions : TSBool = False;
	Bitrate : TSByte = 0;

procedure PrintLogo();
begin
TextColor(15);
SHint('=================================');
SHint('|Building Smooth from executable|');
SHint('=================================');
TextColor(7);
end;

function IsRelease() : TSBool;
begin
Result := 
	(SUpCaseString(Target) = 'RELEASE') or
	(SUpCaseString(Target) = 'ANDROID') or
	(SUpCaseString(Target) = 'RELEASE_X64');
end;

function ReadParams(const Make : TSMakefileReader) : TSBool;
var
	i : TSUInt32;
	AllTargets : TSStringList = nil;
	S, SUP: TSString;

function Proccess32(const Comand : TSString):TSBool;
begin
Result := True;
Bitrate := 32;
end;

function Proccess64(const Comand : TSString):TSBool;
begin
Result := True;
Bitrate := 64;
end;

function ProccessOE(const Comand : TSString):TSBool;
begin
Result := True;
OpenExtensions := True;
end;

function ProccessExtension(const Comand : TSString) : TSBool;
var
	i : TSUInt32;
	ExtensionName : TSString = '';
begin
if Length(Comand) > 1 then
	begin
	for i := 2 to Length(Comand) do
		ExtensionName += Comand[i];
	end;
Result := ExtensionName <> '';
if Result then
	Extensions += ExtensionName;
end;

function ProccessTarget(const Comand : TSString) : TSBool;
begin
Result := (Target = '') and (SUpCaseString(Comand) in AllTargets);
if Result then
	Target := Comand;
end;

begin
Result := True;
AllTargets := SStringListFromString(Make.GetConstant('S_TARGET_LIST'), ',');
SStringListTrimAll(AllTargets, ' ');
AllTargets := SUpCasedStringList(AllTargets, True);
with TSConsoleCaller.Create(VParams) do
	begin
	Category('Bitrate');
	AddComand(@Proccess32, ['32', 'x32', 'i386'], 'Building 32 bit target');
	AddComand(@Proccess64, ['64', 'x64', '86_64', 'x86_64'], 'Building 64 bit target');
	Category('Extensions');
	AddComand(@ProccessOE, ['oe', 'extensions', 'eall'], 'Building all open extensions');
	AddComand(@ProccessExtension, ['e*?'], 'Building an extension');
	Category('Target');
	AddComand(@ProccessTarget, ['*?'], 'Building an target');
	Result := Execute();
	Destroy();
	end;
SetLength(AllTargets, 0);
end;

procedure ExecuteBuild();

procedure ProcessVersionFile(var Make : TSMakefileReader; const ReleaseVersion : TSString = 'False');
begin
SConsoleIncEngineVersion(ReleaseVersion);
SConvertFileToPascalUnit(
	Make.GetConstant('SDATAPATH') + DirectorySeparator + 'Engine' + DirectorySeparator + 'version.txt',
	Make.GetConstant('SRESOURCESPATH'),
	Make.GetConstant('SRESOURCESCACHEPATH'),
	'SmoothVersionFile',
	True).Hint();
SRegisterUnit(
	'SmoothVersionFile',
	Make.GetConstant('SFILEREGISTRATIONRESOURCES'));
end;

procedure ProcessExtensions(var Make : TSMakefileReader);
var
	i : TSMaxEnum;
begin
if OpenExtensions then
	SExtensionsToMakefile(Make, Target, IsRelease);
if Extensions <> nil then
	if Length(Extensions) > 0 then
		for i := 0 to High(Extensions) do
			SExtensionToMakefile(Make, Target, Extensions[i], IsRelease);
end;

procedure PrintTarget(const Target : TSString);
begin
Write('Making target: "');
TextColor(15);
Write(Target);
TextColor(7);
WriteLn('".');
SLog.Source(['Making target: "',Target,'".']);
end;

var
	Make : TSMakefileReader = nil;
begin
Make := TSMakefileReader.Create('.' + DirectorySeparator + 'Makefile');
if not ReadParams(Make) then
	begin
	Make.Destroy();
	Exit;
	end
else
	SLogMakeSignificant();
PrintLogo();
Make.Execute('clear_files');
if IsRelease then
	begin
	SBuildFiles(
		Make.GetConstant('SBUILDPATH') + DirectorySeparator + 'BuildFiles.ini',
		Make.GetConstant('SRESOURCESPATH'),
		Make.GetConstant('SRESOURCESCACHEPATH'),
		Make.GetConstant('SFILEREGISTRATIONRESOURCES'));
	ProcessVersionFile(Make, 'True');
	end
else
	ProcessVersionFile(Make, 'False');
ProcessExtensions(Make);
if SUpCaseString(Target) = 'ANDROID' then
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
SPrintEngineVersion();
ExecuteBuild();
SetLength(Extensions, 0);
end;

procedure SConsoleBuildFiles(const VParams : TSConcoleCallerParams = nil);
begin
SBuildFiles(VParams[0], VParams[1], VParams[2], VParams[3]);
end;

end.
