{$INCLUDE SaGe.inc}

unit SaGeConsoleTools;

interface

uses
	(* ============ System Includes ============ *)
	 Dos
	,Crt
	,Process
	,Classes
	,SysUtils
	,PAPPE
	//,kraft
	,StrMan
	{$IF defined(MSWINDOWS)}
		,Windows
	{$ELSEIF defined(UNIX)}
		,unix
		{$ENDIF}
	,SNMPsend

	(* ============ Engine Includes ============ *)
	,SaGeAudioRender
	,SaGeRender
	,SaGeCommon
	,SaGeImagesBase
	,SaGeContext
	,SaGeImages
	,SaGeBase
	,SaGeBased
	,SaGeMath
	,SaGeCommonUtils
	,SaGeFractals
	,SaGeUtils
	,SaGeModel
	,SaGeMesh
	,SaGeShaders
	,SaGeNet
	,SaGeResourceManager
	,SaGeVersion
	,SaGeMakefileReader
	,SaGeCommonClasses
	,SaGeFileOpener
	,SaGeHash
	,SaGePackages

	(* ============ Additional Engine Includes ============ *)
	,SaGeFPCToC
	,SaGeModelRedactor
	,SaGeClientWeb
	,SaGeUserTesting
	,SaGeTron
	,SaGeLoading
	;

const
	SGErrorString = 'Error of parameters, use ';
	SGConcoleCallerHelpParams = ' --help, --h, --?';
	SGConcoleCallerUnknownCategory = '--unknown--';

type
	TSGConcoleCallerProcedure = procedure (const VParams : TSGConcoleCallerParams = nil);
	TSGConcoleCallerNestedHelpFunction = function () : TSGString is nested;
	TSGConcoleCallerNestedProcedure = function (const VParam : TSGString) : TSGBool is nested;
	TSGConsoleCallerComand = object
			public
		FComand             : TSGConcoleCallerProcedure;
		FNestedComand       : TSGConcoleCallerNestedProcedure;
		FNestedHelpFunction : TSGConcoleCallerNestedHelpFunction;
		FSyntax             : TSGConcoleCallerParams;
		FHelpString         : TSGString;
		FCategory           : TSGString;
			public
		procedure Free();
		end;
	TSGConsoleCallerComands = packed array of TSGConsoleCallerComand;

	TSGConsoleCaller = class
			public
		constructor Create(const VParams : TSGConcoleCallerParams);
		destructor Destroy();override;
		procedure AddComand(const VComand       : TSGConcoleCallerProcedure;       const VSyntax : packed array of const; const VHelp : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure AddComand(const VNestedComand : TSGConcoleCallerNestedProcedure; const VSyntax : packed array of const; const VHelp : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure AddComand(const VNestedComand : TSGConcoleCallerNestedProcedure; const VSyntax : packed array of const; const VHelp : TSGConcoleCallerNestedHelpFunction);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure CheckForLastComand();
		function Execute() : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Category(const VC : TSGString);
			private
		FCurrentCategory : TSGString;
		FParams : TSGConcoleCallerParams;
		FComands : TSGConsoleCallerComands;
			private
		function AllNested() : TSGBool;
		function AllNormal() : TSGBool;
			public
		property Params : TSGConcoleCallerParams write FParams;
		end;

procedure FPCTCTransliater();
procedure GoogleReNameCache();

procedure SGConcoleCaller                                (const VParams : TSGConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGConsoleShowAllApplications                   (const VParams : TSGConcoleCallerParams = nil);overload;
procedure SGConsoleConvertImageToSaGeImageAlphaFormat    (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleBuild                                 (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleShaderReadWrite                       (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleClearFileRegistrationResources        (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleConvertFileToPascalUnitAndRegisterUnit(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleAddToLog                              (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleIncEngineVersion                      (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleConvertFileToPascalUnit               (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleExtractFiles                          (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleConvertDirectoryFilesToPascalUnits    (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleFindInPas                             (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleImageResizer                          (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleMake                                  (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleConvertHeaderToDynamic                (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleWriteOpenableExpansions               (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleWriteFiles                            (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleDllPrintStat                          (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleCalculateExpression                   (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleCalculateBoolTable                    (const VParams : TSGConcoleCallerParams = nil);

function SGConsoleCallerParamsToPChar(const VParams : TSGConcoleCallerParams = nil; const BeginPosition : TSGUInt32 = 0) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGDecConsoleParams(const Params : TSGConcoleCallerParams) : TSGConcoleCallerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGCountConsoleParams(const Params : TSGConcoleCallerParams) : TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGIsBoolConsoleParam(const Param : TSGString):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGPrintConsoleParams();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SGConsoleRunPaintable(const VPaintabeClass : TSGDrawableClass; const VParams : TSGConcoleCallerParams = nil; ContextSettings : TSGContextSettings = nil);
procedure SGConsoleShowAllApplications(const VParams : TSGConcoleCallerParams = nil;  ContextSettings : TSGContextSettings = nil);overload;
procedure SGStandartCallConcoleCaller();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

var
	GeneralConsoleCaller : TSGConsoleCaller = nil;
	OtherEnginesConsoleProgramsConsoleCaller : TSGConsoleCaller = nil;

implementation

uses
	SaGeConvertHeaderToDynamic
	{$IFDEF MSWINDOWS}
		,SaGeRenderDirectX9
		,SaGeRenderDirectX8
		,SaGeRenderDirectX12
		{$ENDIF}
	,SaGeRenderOpenGL
	{$IFDEF WITH_GLUT}
		,SaGeContextGLUT
		{$ENDIF}
	,SaGeDllManager
	{$IFNDEF MOBILE}
		,SaGeAudioRenderOpenAL
		{$ENDIF}
	;

procedure SGConsoleConvertHeaderToDynamic(const VParams : TSGConcoleCallerParams = nil);

function ParamIsMode(const VParam : TSGString): TSGBool;
var
	UpCasedParam : TSGString;
begin
UpCasedParam := SGUpCaseString(VParam);
Result := ((UpCasedParam = SGDDHModeObjFpc) or (UpCasedParam = SGDDHModeDelphi) or (UpCasedParam = SGDDHModeFpc));
end;

function ParamIsWriteMode(const VParam : TSGString):TSGBool;
var
	UpCasedParam : TSGString;
begin
UpCasedParam := SGUpCaseString(VParam);
Result := ((UpCasedParam = SGDDHWriteModeFpc) or (UpCasedParam = SGDDHWriteModeSaGe) or (UpCasedParam = SGDDHWriteModeObjectSaGe));
end;

function IsNullUtil() : TSGBool;
begin
Result := (Length(VParams) = 4) and (SGResourceFiles.FileExists(VParams[1])) and ParamIsMode(VParams[3]);
if not Result then
	Result := (Length(VParams) = 3) and (SGResourceFiles.FileExists(VParams[1]));
if Result then
	Result := SGUpCaseString(StringTrimLeft(VParams[0], '-')) = 'NU';
end;

begin
if (Length(VParams) = 2) and (SGResourceFiles.FileExists(VParams[0])) then
	SGConvertHeaderToDynamic(VParams[0], VParams[1])
else if (Length(VParams) = 4) and (SGResourceFiles.FileExists(VParams[0])) and ParamIsMode(VParams[2]) and ParamIsWriteMode(VParams[3]) then
	SGConvertHeaderToDynamic(VParams[0], VParams[1], VParams[2], VParams[3])
else if (Length(VParams) = 3) and (SGResourceFiles.FileExists(VParams[0])) and ParamIsWriteMode(VParams[2]) then
	SGConvertHeaderToDynamic(VParams[0], VParams[1], SGDDHModeDef, VParams[2])
else if (Length(VParams) = 3) and (SGResourceFiles.FileExists(VParams[0])) and ParamIsMode(VParams[2]) then
	SGConvertHeaderToDynamic(VParams[0], VParams[1], VParams[2])
else if IsNullUtil() then
	if (Length(VParams) = 3) then
		TSGDoDynamicHeader.NullUtil(VParams[1], VParams[2])
	else
		TSGDoDynamicHeader.NullUtil(VParams[1], VParams[2], VParams[3])
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGErrorString,'"[--nu] @infilename @outfilename [@mode] [@write_mode]". ');
	WriteLn('Param @mode is in set of "',SGDDHModeObjFpc,'", "',SGDDHModeFpc,'" or "',SGDDHModeDelphi,'".');
	WriteLn('Param @write_mode is in set of "',SGDDHWriteModeFpc,'", "',SGDDHWriteModeSaGe,'" or "',SGDDHWriteModeObjectSaGe,'".');
	end;
end;

procedure SGConsoleBuildFiles(const VParams : TSGConcoleCallerParams = nil);
begin
SGBuildFiles(VParams[0],VParams[1],VParams[2],VParams[3]);
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
		WriteLn(SGErrorString,'"[@library]". Param @library is Engine''s name of this Library.');
		end;
	end
else
	DllManager.PrintStat();
end;

procedure SGConcoleCaller(const VParams : TSGConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
GeneralConsoleCaller.Params := VParams;
GeneralConsoleCaller.Execute();
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

procedure SGConsoleConvertDirectoryFilesToPascalUnits(const VParams : TSGConcoleCallerParams = nil);
begin
if (SGCountConsoleParams(VParams) = 3) and SGResourceFiles.FileExists(VParams[2]) and SGExistsDirectory(VParams[0])and SGExistsDirectory(VParams[1]) then
	SGConvertDirectoryFilesToPascalUnits(VParams[0],VParams[1],'',VParams[2])
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGErrorString,'"@dir_name @out_dir_name @file_registration_resources_path"');
	end;
end;

procedure SGConsoleIsConsole(const VParams : TSGConcoleCallerParams = nil);
begin
Halt(TSGByte(SGIsConsole()));
end;

procedure SGConsoleHash(const VParams : TSGConcoleCallerParams = nil);
begin
SGConsoleHashFile(VParams[0]);
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
	WriteLn(SGErrorString,'"@outdirname @flag", @flag is true when need to keeps file system file names');
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
	WriteLn(SGErrorString,'"@filename @outdirname @unitname @flag", @flag is true if needs to register file in manager when it was compiled');
	end;
end;

function SGIsBoolConsoleParam(const Param : TSGString):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result :=   (SGUpCaseString(Param) = 'TRUE') or
			(SGUpCaseString(Param) = 'FALSE') or
			(Param = '0') or
			(Param = '1');
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
	WriteLn(SGErrorString,'"@flag", @flag is true when version is release');
	end;
end;

procedure SGConsoleAddToLog(const VParams : TSGConcoleCallerParams = nil);
begin
if (SGCountConsoleParams(VParams) = 2) and SGResourceFiles.FileExists(VParams[0]) then
	SGAddToLog(VParams[0],VParams[1])
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGErrorString,'"@log_file_name @line"');
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
	WriteLn(SGErrorString,'"@file_path @unit_dir @cache_dir @unit_name @registration_file_path"');
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
	WriteLn(SGErrorString,'"@file_path @unit_dir @unit_name @registration_file_path"');
	end;
end;

procedure SGConsoleClearFileRegistrationPackages(const VParams : TSGConcoleCallerParams = nil);
begin
if (VParams <> nil) and (Length(VParams) = 1) and (VParams[0] <> '') then
	SGClearFileRegistrationPackages(VParams[0])
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGErrorString,'"@filename"');
	end;
end;

procedure SGConsoleClearFileRegistrationResources(const VParams : TSGConcoleCallerParams = nil);
begin
if (VParams <> nil) and (Length(VParams) = 1) and (VParams[0] <> '') then
	SGClearFileRegistrationResources(VParams[0])
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGErrorString,'"@filename"');
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
WriteLn(Make.GetConstant('SG_TARGET_LIST'));
AllTargets := SGStringListFromString(Make.GetConstant('SG_TARGET_LIST'),',');
if AllTargets <> nil then if Length(AllTargets) > 0 then
	for i := 0 to High(AllTargets) do
		begin
		AllTargets[i] := SGUpCaseString(StringTrimAll(AllTargets[i],' '));
		WriteLn(AllTargets[i]);
		end;
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
	SGPackagesToMakefile(Make);
if Packages <> nil then
	if Length(Packages) > 0 then
		for i := 0 to High(Packages) do
			if not SGIsPackageOpen(Make, Packages[i]) then
				SGPackageToMakefile(Make, Packages[i], IsRelease);
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

function SGCountConsoleParams(const Params : TSGConcoleCallerParams) : TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := 0;
if (Params <> nil) then
	Result := Length(Params);
end;

procedure SGConsoleShaderReadWrite(const VParams : TSGConcoleCallerParams = nil);
var
	i, ii : TSGLongWord;
	Params : TSGConcoleCallerParams;
begin
ii := 0;
if (VParams <> nil) then
	ii := Length(VParams);
if (ii >= 2) and SGResourceFiles.FileExists(VParams[0]) then
	begin
	SetLength(Params,Length(VParams)-2);
	if Length(Params)>0 then
		for i := 2 to High(VParams) do
			Params[i-2] := VParams[i];
	SGReadAndSaveShaderSourceFile(VParams[0], VParams[1], Params);
	SetLength(Params,0);
	end
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGErrorString,'"@infile @outfile[ @shaderParam(i)]"');
	end;
end;

function SGDecConsoleParams(const Params : TSGConcoleCallerParams) : TSGConcoleCallerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
if (Params = nil) or (Length(Params)<=1) then
	Result := nil
else
	begin
	SetLength(Result,Length(Params)-1);
	for i := 1 to High(Params) do
		Result[i-1] := Params[i];
	end;
end;

function SGConsoleCallerParamsToPChar(const VParams : TSGConcoleCallerParams = nil; const BeginPosition : TSGUInt32 = 0) : PSGChar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	S : TSGString;
	i : TSGUInt32;
begin
Result := nil;
S := '';
if VParams <> nil then
	if Length(VParams) > 0 then
		for i := BeginPosition to High(VParams) do
			S += VParams[i] + ' ';
if S <> '' then
	Result := SGStringToPChar(S);
end;

procedure SGConsoleCalculateBoolTable(const VParams : TSGConcoleCallerParams = nil);

function IsDebug() : TSGBool;
begin
if VParams <> nil then
	if Length(VParams) > 0 then
		Result := (StringTrimLeft(SGUpCaseString(VParams[0]), '-') = 'D') or
				  (StringTrimLeft(SGUpCaseString(VParams[0]), '-') = 'DEBUG');
end;

var
	Exp:TSGExpression = nil;
	Variables:TArPChar = nil;
	Consts:TArBoolean = nil;
	I:LongInt;
	NeedExit:Boolean = False;

function Trues:Boolean;
var
	I:LongInt = 0;
begin
if NeedExit then
	Result:=True
else
	begin
	Result:=True;
	for i:=0 to High(Consts) do
		if not Consts[i] then
			begin
			Result:=False;
			Break;
			end;
	NeedExit:=Result;
	Result:=False;
	end;
end;

begin
TextColor(15);
Exp:=TSGExpression.Create;
Exp.DeBug:=IsDebug();
Exp.Expression:=SGConsoleCallerParamsToPChar(VParams, TSGByte(IsDebug));
Exp.CanculateExpression;
Variables:=Exp.Variables;
SetLength(Consts,Length(Variables));
for I:=0 to High(Consts) do
	Consts[i]:=False;
while not Trues do
	begin
	Exp.BeginCalculate;
	for i:=0 to High(Consts) do
		Exp.ChangeVariables(Variables[i],TSGExpressionChunkCreateBoolean(Consts[i]));
	Exp.Calculate;
	for i:=0 to High(Consts) do
		begin
		Write(Variables[i]);
		TextColor(7);
		Write('=');
		case byte(Consts[i]) of
		0 : TextColor(12);
		1 : TextColor(10);
		end;
		Write(byte(Consts[i]));
		TextColor(15);
		Write(' ');
		end;
	Write('Out: ');
	if Exp.Resultat.Quantity=0 then 
		Exp.WriteErrors
	else
		Exp.Resultat.WriteLnConsole;
	I:=High(Consts);
	while not Consts[i]=False do
		begin
		Consts[i]:=not Consts[i];
		I-=1;
		end;
	if I in [0..High(Consts)] then
		Consts[i]:=true;
	end;
Exp.Destroy();
end;

procedure SGConsoleCalculateExpression(const VParams : TSGConcoleCallerParams = nil);

function IsDebug() : TSGBool;
begin
if VParams <> nil then
	if Length(VParams) > 0 then
		Result := (StringTrimLeft(SGUpCaseString(VParams[0]), '-') = 'D') or
				  (StringTrimLeft(SGUpCaseString(VParams[0]), '-') = 'DEBUG');
end;

var
	Exp : TSGExpression = nil;
begin
Exp := TSGExpression.Create();
Exp.DeBug := IsDebug();
Exp.Expression := SGConsoleCallerParamsToPChar(VParams, TSGByte(IsDebug));
Exp.CanculateExpression();
Exp.Calculate();
if Exp.Resultat.Quantity = 0 then 
	Exp.WriteErrors()
else
	Exp.Resultat.WriteLnConsole();
Exp.Destroy();
end;

procedure SGConsoleConvertImageToSaGeImageAlphaFormat(const VParams : TSGConcoleCallerParams = nil);
begin
if (VParams <> nil) and (Length(VParams) = 1) and (
	(StringTrimLeft(SGUpCaseString(VParams[0]), '-') = 'H') or
	(StringTrimLeft(SGUpCaseString(VParams[0]), '-') = 'HELP')) then
	begin
	SGPrintEngineVersion();
	WriteLn('Convert image To SaGe Images Alpha format');
	WriteLn('Use "--CTSGIA P1 P2"');
	WriteLn('   P1 - way to input file, for example "/images/qwerty/asdfgh.png"');
	WriteLn('   P2 - way to output file, for example "/images/qwerty/asdfgh.sgia"');
	end
else if (VParams = nil) or (Length(VParams)<2) then
	begin
	SGPrintEngineVersion();
	WriteLn('Error count of parameters!');
	end
else if (VParams <> nil) and (Length(VParams) = 2) and SGResourceFiles.FileExists(VParams[0]) then
	SGConvertToSGIA(VParams[0],VParams[1])
else
	begin
	SGPrintEngineVersion();
	WriteLn('Error!');
	end;
end;

procedure TSGConsoleCaller.Category(const VC : TSGString);
begin
FCurrentCategory := VC;
end;

constructor TSGConsoleCaller.Create(const VParams : TSGConcoleCallerParams);
begin
FParams := VParams;
FComands := nil;
FCurrentCategory := SGConcoleCallerUnknownCategory;
end;

function TSGConsoleCaller.AllNested() : TSGBool;
var
	i : TSGLongWord;
begin
Result := False;
if FComands <> nil then
	if Length(FComands) > 0 then
		begin
		Result := True;
		for i := 0 to High(FComands) do
			if (FComands[i].FNestedComand = nil) or (FComands[i].FComand <> nil) then
				begin
				Result := False;
				break;
				end;
		end;
end;

function TSGConsoleCaller.AllNormal() : TSGBool;
var
	i : TSGLongWord;
begin
Result := False;
if FComands <> nil then
	if Length(FComands) > 0 then
		begin
		Result := True;
		for i := 0 to High(FComands) do
			if (FComands[i].FNestedComand <> nil) or (FComands[i].FComand = nil) then
				begin
				Result := False;
				break;
				end;
		end;
end;

destructor TSGConsoleCaller.Destroy();
var
	i : TSGLongWord;
begin
SetLength(FParams,0);
if (FComands <> nil) and (Length(FComands)>0) then
	begin
	for i := 0 to High(FComands) do
		SetLength(FComands[i].FSyntax,0);
	SetLength(FComands,0);
	end;
inherited;
end;

procedure TSGConsoleCallerComand.Free();
begin
FComand             := nil;
FNestedComand       := nil;
FNestedHelpFunction := nil;
FSyntax             := nil;
FHelpString         := '';
FCategory           := '';
end;

procedure TSGConsoleCaller.CheckForLastComand();
var
	i, iiii : TSGLongWord;
	ii : TSGInt32;
	iii : TSGBool;
begin
with FComands[High(FComands)] do
	if (FSyntax <> nil) and (Length(FSyntax)>0) then
		begin
		// Upcaseing
		for i := 0 to High(FSyntax) do
			FSyntax[i] := SGUpCaseString(FSyntax[i]);
		// Deleting dublicates of syntax for this comand
		ii := 0;
		i := 0;
		while i < Length(FSyntax) do
			begin
			ii := i - 1;
			iii := False;
			while ii > -1 do
				begin
				if FSyntax[i] = FSyntax[ii] then
					begin
					iii := True;
					break;
					end;
				ii -= 1;
				end;
			if iii then
				begin
				if ii < High(FSyntax) then
					for iiii := ii to High(FSyntax) - 1 do
						FSyntax[ii] := FSyntax[ii + 1];
				SetLength(FSyntax,Length(FSyntax) - 1);
				end
			else
				i += 1;
			end;
		// Deleting dublicates of all comands if this comand is general
		// General comand started if no comands is in params
		ii := 0;
		for i := 0 to High(FSyntax) do
			if FSyntax[i] = '' then
				begin
				ii := 1;
				break;
				end;
		if ii = 1 then
			begin
			if Length(FComands) > 1 then
				for i := 0 to High(FComands) - 1 do
					begin
					ii := 0;
					while ii < Length(FComands[i].FSyntax) do
						if FComands[i].FSyntax[ii] = '' then
							begin
							if ii <> High(FComands[i].FSyntax) then
								for iiii := ii to High(FComands[i].FSyntax) - 1 do
									FComands[i].FSyntax[ii] := FComands[i].FSyntax[ii + 1];
							SetLength(FComands[i].FSyntax,Length(FComands[i].FSyntax) - 1);
							end
						else
							ii += 1;
					end;
			end;
		end;
end;

procedure TSGConsoleCaller.AddComand(const VComand : TSGConcoleCallerProcedure; const VSyntax : packed array of const; const VHelp : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if FComands = nil then
	SetLength(FComands, 1)
else
	SetLength(FComands, Length(FComands) + 1);
FComands[High(FComands)].Free();
FComands[High(FComands)].FComand := VComand;
FComands[High(FComands)].FHelpString := VHelp;
FComands[High(FComands)].FCategory := FCurrentCategory;
FComands[High(FComands)].FSyntax := SGArConstToArString(VSyntax);
CheckForLastComand();
end;

procedure TSGConsoleCaller.AddComand(const VNestedComand : TSGConcoleCallerNestedProcedure; const VSyntax : packed array of const; const VHelp : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if FComands = nil then
	SetLength(FComands, 1)
else
	SetLength(FComands, Length(FComands) + 1);
FComands[High(FComands)].Free();
FComands[High(FComands)].FNestedComand := VNestedComand;
FComands[High(FComands)].FHelpString := VHelp;
FComands[High(FComands)].FCategory := FCurrentCategory;
FComands[High(FComands)].FSyntax := SGArConstToArString(VSyntax);
CheckForLastComand();
end;

procedure TSGConsoleCaller.AddComand(const VNestedComand : TSGConcoleCallerNestedProcedure; const VSyntax : packed array of const; const VHelp : TSGConcoleCallerNestedHelpFunction);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if FComands = nil then
	SetLength(FComands, 1)
else
	SetLength(FComands, Length(FComands) + 1);
FComands[High(FComands)].Free();
FComands[High(FComands)].FNestedComand := VNestedComand;
FComands[High(FComands)].FNestedHelpFunction := VHelp;
FComands[High(FComands)].FCategory := FCurrentCategory;
FComands[High(FComands)].FSyntax := SGArConstToArString(VSyntax);
CheckForLastComand();
end;

function TSGConsoleCaller.Execute() : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure ErrorUnknownComand(const Comand : TSGString);
begin
SGPrintEngineVersion();
TextColor(12);
Write('Console caller : error : abstract comand "');
TextColor(15);
Write(SGDownCaseString(Comand));
TextColor(12);
WriteLn('"!');
TextColor(7);
end;

procedure ErrorUnknownSimbol(const Comand : TSGString);
begin
SGPrintEngineVersion();
TextColor(12);
Write('Console caller : error : unknown simbol "');
TextColor(15);
Write(Comand);
TextColor(12);
Write('", use "');
TextColor(15);
Write('--help');
TextColor(12);
WriteLn('"');
TextColor(7);
end;

function OpenFileCheck() : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
Result := (FParams <> nil) and (Length(FParams)>0);
if Result then
	begin
	for i := 0 to High(FParams) do
		if not SGResourceFiles.FileExists(FParams[i]) then
			begin
			Result := False;
			break;
			end;
	end;
end;

function IsComandHelp(const Comand : TSGString) : TSGBool;
begin
Result := (Comand = 'HELP') or (Comand = 'H') or (Comand = '?');
end;

procedure ExecuteHelp();
var
	FCategoriesSpaces : packed array of
		packed record
			FCategory : TSGString;
			FSpaces   : TSGUInt32;
			end = nil;

function CategorySpace(const C : TSGString):TSGUInt32;
var
	i : TSGUInt32;
begin
Result := 0;
if FCategoriesSpaces <> nil then if Length(FCategoriesSpaces) > 0 then
	for i := 0 to High(FCategoriesSpaces) do
		if FCategoriesSpaces[i].FCategory = C then
			begin
			Result := FCategoriesSpaces[i].FSpaces;
			break;
			end;
end;

procedure CalcCategorySpaces();

function LastCatecory() : TSGString;
begin
if FCategoriesSpaces = nil then
	Result := SGConcoleCallerUnknownCategory
else if Length(FCategoriesSpaces) = 0 then
	Result := SGConcoleCallerUnknownCategory
else
	Result := FCategoriesSpaces[High(FCategoriesSpaces)].FCategory;
end;

function ComandSpace(const i : TSGLongWord) : TSGLongWord;
var
	ii : TSGUInt32;
begin
Result := 0;
for ii := 0 to High(FComands[i].FSyntax) do
	if FComands[i].FSyntax[ii] <> '' then
		begin
		if ii <> 0 then
			Result += 1;
		Result += 3 + Length(FComands[i].FSyntax[ii]);
		end;
if FComands[i].FCategory = SGConcoleCallerUnknownCategory then
	if Result < Length(SGConcoleCallerHelpParams) then
		Result := Length(SGConcoleCallerHelpParams);
end;

procedure AddNewCatSpase(const C : TSGString; const S : TSGUInt32);
begin
if FCategoriesSpaces = nil then
	SetLength(FCategoriesSpaces, 1)
else
	SetLength(FCategoriesSpaces, Length(FCategoriesSpaces) + 1);
FCategoriesSpaces[High(FCategoriesSpaces)].FCategory := C;
FCategoriesSpaces[High(FCategoriesSpaces)].FSpaces   := S;
end;

var
	i, ii : TSGLongWord;
begin
if FComands <> nil then if Length(FComands) > 0 then
	for i := 0 to High(FComands) do
		begin
		if (LastCatecory() <> FComands[i].FCategory) or (FCategoriesSpaces = nil) or (Length(FCategoriesSpaces) = 0) then
			AddNewCatSpase(FComands[i].FCategory, ComandSpace(i))
		else
			begin
			ii := ComandSpace(i);
			if ii > FCategoriesSpaces[High(FCategoriesSpaces)].FSpaces then
				FCategoriesSpaces[High(FCategoriesSpaces)].FSpaces := ii;
			end;
		end;
end;

function IsDefParam(const i : TSGLongWord):TSGBoolean;
var
	ii : TSGUInt32;
begin
Result := False;
if FComands[i].FSyntax <> nil then
	if Length(FComands[i].FSyntax) <> 0 then
		for ii := 0 to High(FComands[i].FSyntax) do
			if FComands[i].FSyntax[ii] = '' then
				begin
				Result := True;
				break;
				end;
end;

const
	CategoryColor = 15;
	StandartColor = 7;
	DefParamColor = 11;
	CommaColor = 14;
var
	i, ii, iii : TSGLongWord;
	LCat : TSGString;
	dp : TSGBool;
begin
if (FComands <> nil) and (Length(FComands)>0) then
	begin
	SGPrintEngineVersion();
	TextColor(CategoryColor);
	Write('Help');
	TextColor(StandartColor);
	WriteLn(':');
	WriteLn(SGConcoleCallerHelpParams, ' - Shows this');
	CalcCategorySpaces();
	LCat := SGConcoleCallerUnknownCategory;
	for i := 0 to High(FComands) do
		begin
		if (FComands[i].FSyntax <> nil) and (Length(FComands[i].FSyntax)>0) then
			begin
			if LCat <> FComands[i].FCategory then
				begin
				LCat := FComands[i].FCategory;
				TextColor(CategoryColor);
				Write(LCat);
				TextColor(CommaColor);
				WriteLn(':');
				TextColor(StandartColor);
				end;
			dp := IsDefParam(i);
			if DP then
				TextColor(DefParamColor);
			iii := 0;
			for ii := 0 to High(FComands[i].FSyntax) do
				if FComands[i].FSyntax[ii] <> '' then
					begin
					if ii <> 0 then
						begin
						TextColor(CommaColor);
						Write(',');
						iii += 1;
						if DP then
							TextColor(DefParamColor)
						else
							TextColor(StandartColor);
						end;
					Write(' --',SGDownCaseString(FComands[i].FSyntax[ii]));
					iii += 3 + Length(FComands[i].FSyntax[ii]);
					end;
			ii := CategorySpace(FComands[i].FCategory);
			while iii < ii do
				begin
				Write(' ');
				iii += 1;
				end;
			if FComands[i].FNestedHelpFunction <> nil then
				FComands[i].FHelpString := FComands[i].FNestedHelpFunction();
			WriteLn(' - ',FComands[i].FHelpString);
			TextColor(StandartColor);
			end;
		end;
	SetLength(FCategoriesSpaces, 0);
	end;
end;

procedure ExecuteNormal();

function ComandCheck():TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	TempString : TSGString;
begin
Result := '';
if (FParams <> nil) and (Length(FParams)>0) then
	begin
	TempString := StringTrimLeft(FParams[0],'-');
	if Length(TempString) <> Length(FParams[0]) then
		begin
		Result := SGUpCaseString(TempString);
		end
	else
		begin
		ErrorUnknownSimbol(FParams[0]);
		end;
	end;
end;

var
	i, ii, iii : TSGLongWord;
	Comand : TSGString;
	Params : TSGConcoleCallerParams;
begin
Comand := ComandCheck();
if IsComandHelp(Comand) then
	begin
	ExecuteHelp();
	end
else if Comand <> '' then
	begin
	iii := 0;
	if (FComands <> nil) and (Length(FComands)>0) then
		begin
		for i := 0 to High(FComands) do
			begin
			iii := 0;
			if (FComands[i].FSyntax <> nil) and (Length(FComands[i].FSyntax)>0) then
				begin
				for ii := 0 to High(FComands[i].FSyntax) do
					if FComands[i].FSyntax[ii] = Comand then
						begin
						iii := 1;
						break;
						end;
				end;
			if iii = 1 then
				begin
				if FComands[i].FComand = nil then
					begin
					ErrorUnknownComand(Comand);
					iii := 0;
					end
				else
					begin
					Params := SGDecConsoleParams(FParams);
					FComands[i].FComand(Params);
					SetLength(Params,0);
					break;
					end;
				end;
			end;
		end;
	if iii = 0 then
		begin
		ErrorUnknownComand(Comand);
		end;
	end
else if (Comand = '') and (SGCountConsoleParams(FParams) = 0) then
	begin
	iii := 0;
	if (FComands <> nil) and (Length(FComands)>0) then
		begin
		for i := 0 to High(FComands) do
			begin
			iii := 0;
			if (FComands[i].FSyntax <> nil) and (Length(FComands[i].FSyntax)>0) then
				begin
				for ii := 0 to High(FComands[i].FSyntax) do
					if FComands[i].FSyntax[ii] = '' then
						begin
						iii := 1;
						break;
						end;
				if (iii = 1) then
					begin
					FComands[i].FComand();
					break;
					end;
				end;
			end;
		end;
	end;
end;

function ExecuteNested() : TSGBool;

function TestComand(const Comand : TSGString):TSGBool;
var
	ii, iii : TSGLongWord;
begin
Result := False;
for ii := 0 to High(FComands) do
	begin
	for iii := 0 to High(FComands[ii].FSyntax) do
		begin
		if StringMatching(Comand, FComands[ii].FSyntax[iii]) then
			begin
			Result := True;
			break;
			end;
		end;
	if Result then
		break;
	end;
end;

var
	Comand : TSGString;
	i, hi, e, ii, iii : TSGLongWord;
begin
Result := False;
if (FParams <> nil) and (Length(FParams) > 0) then
	begin
	hi := Length(FParams);
	e := 0;
	for i := 0 to High(FParams) do
		begin
		Comand := StringTrimLeft(FParams[i],'-');
		if Length(Comand) <> Length(FParams[i]) then
			begin
			Comand := SGUpCaseString(Comand);
			if IsComandHelp(Comand) then
				hi := i
			else if not TestComand(Comand) then
				begin
				ErrorUnknownComand(Comand);
				e += 1;
				end
			end
		else
			begin
			e += 1;
			ErrorUnknownSimbol(Comand);
			end;
		end;
	if e <> 0 then
		begin
		SGPrintEngineVersion();
		TextColor(12);
		WriteLn('Console caller : fatal : total ',e,' errors!');
		TextColor(7);
		end;
	if hi <> Length(FParams) then
		begin
		ExecuteHelp();
		end
	else if e = 0 then
		begin
		for i := 0 to High(FParams) do
			begin
			Comand := StringTrimLeft(FParams[i],'-');
			Comand := SGUpCaseString(Comand);
			hi := Length(FComands);
			for ii := 0 to High(FComands) do
				begin
				for iii := 0 to High(FComands[ii].FSyntax) do
					begin
					if StringMatching(Comand, FComands[ii].FSyntax[iii]) then
						begin
						hi := ii;
						break;
						end;
					end;
				if hi <> Length(FComands) then
					break;
				end;
			if hi = Length(FComands) then
				begin
				ErrorUnknownComand(Comand);
				e += 1;
				end
			else
				begin
				if not FComands[hi].FNestedComand(StringTrimLeft(FParams[i],'-')) then
					begin
					SGPrintEngineVersion();
					TextColor(12);
					Write('Console caller : error : error while executing comand "');
					TextColor(15);
					Write(Comand);
					TextColor(12);
					Write('", use "');
					TextColor(15);
					Write('--help');
					TextColor(12);
					WriteLn('"');
					TextColor(7);
					e += 1;
					end;
				end;
			end;
		Result := e = 0;
		if not Result then
			begin
			SGPrintEngineVersion();
			TextColor(12);
			WriteLn('Console caller : fatal : total ',e,' errors!');
			TextColor(7);
			end;
		end;
	end;
end;

begin
Result := True;
if OpenFileCheck() then
	begin
	SGPrintEngineVersion();
	SGTryOpenFiles(FParams);
	end
else if AllNormal() then
	begin
	ExecuteNormal();
	end
else if AllNested() then
	Result := ExecuteNested()
else
	begin
	TextColor(12);
	Write('Console caller : error : unknown configuration!');
	TextColor(7);
	Result := False;
	end;
end;

procedure SGPrintConsoleParams();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Params : TSGConcoleCallerParams;
	i : TSGLongWord;
begin
Params := SGSystemParamsToConcoleCallerParams();
if Params <> nil then
	if Length(Params) <> 0 then
		begin
		for i := 0 to High(Params) do
			begin
			WriteLn(i+1,' - "',Params[i],'"');
			end;
		end;
end;

procedure SGStandartCallConcoleCaller();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Params : TSGConcoleCallerParams;
begin
Params := SGSystemParamsToConcoleCallerParams();
SGConcoleCaller(Params);
SetLength(Params,0);
end;

procedure SGConsoleRunPaintable(const VPaintabeClass : TSGDrawableClass; const VParams : TSGConcoleCallerParams = nil; ContextSettings : TSGContextSettings = nil);
var
	RenderClass   : TSGRenderClass = nil;
	ContextClass  : TSGContextClass = nil;
	AudioRenderClass : TSGAudioRenderClass = nil;
	AudioDisabled : TSGBool = False;

function ProccessFullscreen(const Comand : TSGString):TSGBool;
begin
Result := True;
if ('FULLSCREEN' in ContextSettings) then
	begin
	if SGContextOptionFullscreen(False) in ContextSettings then
		begin
		ContextSettings -= SGContextOptionFullscreen(False);
		ContextSettings += SGContextOptionFullscreen(True);
		end
	else
		begin
		if SGContextOptionFullscreen(True) in ContextSettings then
			begin
			ContextSettings -= SGContextOptionFullscreen(True);
			end
		else
			Result := False;
		end;
	end
else
	ContextSettings += SGContextOptionFullscreen(True);
end;

function IsGLUTSuppored() : TSGBool;
begin
{$IFDEF WITH_GLUT}
Result := TSGContextGLUT.Suppored();
{$ELSE}
Result := False;
{$ENDIF}
end;

function IsD3DX8Suppored() : TSGBool;
begin
{$IFDEF MSWINDOWS}
Result := TSGRenderDirectX8.Suppored();
{$ELSE}
Result := False;
{$ENDIF}
end;

function IsD3DX9Suppored() : TSGBool;
begin
{$IFDEF MSWINDOWS}
Result := TSGRenderDirectX9.Suppored();
{$ELSE}
Result := False;
{$ENDIF}
end;

function IsD3DX12Suppored() : TSGBool;
begin
{$IFDEF MSWINDOWS}
Result := TSGRenderDirectX12.Suppored();
{$ELSE}
Result := False;
{$ENDIF}
end;

function ProccessGLUT(const Comand : TSGString):TSGBool;
begin
Result := True;
if not IsGLUTSuppored() then
	begin
	WriteLn('GLUT can''t be used in your system!');
	Result := False;
	end;
{$IFDEF WITH_GLUT}
if Result then
	ContextClass := TSGContextGLUT;
{$ENDIF}
end;

function ProccessDirectX12(const Comand : TSGString):TSGBool;
begin
Result := True;
if not IsD3DX12Suppored() then
	begin
	WriteLn('Direct3D X 12 can''t be used in your system!');
	Result := False;
	end;
{$IFDEF MSWINDOWS}
if Result then
	RenderClass := TSGRenderDirectX12;
{$ENDIF}
end;

function ProccessDirectX9(const Comand : TSGString):TSGBool;
begin
Result := True;
if not IsD3DX9Suppored() then
	begin
	WriteLn('Direct3D X 9 can''t be used in your system!');
	Result := False;
	end;
{$IFDEF MSWINDOWS}
if Result then
	RenderClass := TSGRenderDirectX9;
{$ENDIF}
end;

function ProccessDirectX8(const Comand : TSGString):TSGBool;
begin
Result := True;
if not IsD3DX8Suppored() then
	begin
	WriteLn('Direct3D X 8 can''t be used in your system!');
	Result := False;
	end;
{$IFDEF MSWINDOWS}
if Result then
	RenderClass := TSGRenderDirectX8;
{$ENDIF}
end;

function ProccessOpenGL(const Comand : TSGString):TSGBool;
begin
Result := True;
if not TSGRenderOpenGL.Suppored() then
	begin
	WriteLn('OpenGL can''t be used in your system!');
	Result := False;
	end;
{$IFDEF MSWINDOWS}
if Result then
	RenderClass := TSGRenderOpenGL;
{$ENDIF}
end;

function StringIsNumber(const S : TSGString) : TSGBool;
var
	i : TSGLongWord;
begin
Result := Length(S) > 0;
for i := 1 to Length(S) do
	begin
	if not (S[i] in '0123456789') then
		begin
		Result := false;
		break;
		end;
	end;
end;

function ProccessWidth(const Comand : TSGString):TSGBool;
var
	MustBeNumber : TSGString;
begin
MustBeNumber := StringTrimLeft(Comand,'WIDTHwidth');
Result := StringIsNumber(MustBeNumber);
if Result then
	begin
	if ('WIDTH' in ContextSettings) then
		begin
		ContextSettings -= 'WIDTH';
		end;
	ContextSettings += SGContextOptionWidth(SGVal(MustBeNumber));
	end;
end;

function ProccessHeight(const Comand : TSGString):TSGBool;
var
	MustBeNumber : TSGString;
begin
MustBeNumber := StringTrimLeft(Comand,'HEIGHTheight');
Result := StringIsNumber(MustBeNumber);
if Result then
	begin
	if ('HEIGHT' in ContextSettings) then
		begin
		ContextSettings -= 'HEIGHT';
		end;
	ContextSettings += SGContextOptionHeight(SGVal(MustBeNumber));
	end;
end;

function ProccessLeft(const Comand : TSGString):TSGBool;
var
	MustBeNumber : TSGString;
begin
MustBeNumber := StringTrimLeft(Comand,'XLEFTxleft');
Result := StringIsNumber(MustBeNumber);
if Result then
	begin
	if ('LEFT' in ContextSettings) then
		begin
		ContextSettings -= 'LEFT';
		end;
	ContextSettings += SGContextOptionLeft(SGVal(MustBeNumber));
	end;
end;

function ProccessTop(const Comand : TSGString):TSGBool;
var
	MustBeNumber : TSGString;
begin
MustBeNumber := StringTrimLeft(Comand,'YTOPytop');
Result := StringIsNumber(MustBeNumber);
if Result then
	begin
	if ('TOP' in ContextSettings) then
		begin
		ContextSettings -= 'TOP';
		end;
	ContextSettings += SGContextOptionTop(SGVal(MustBeNumber));
	end;
end;

function ProccessWH(const Comand : TSGString):TSGBool;
var
	C, X : TSGChar;
	CountXX : TSGLongWord = 0;
begin
Result := Length(Comand) > 2;
for C in Comand do
	begin
	if not (C in '0123456789Xx') then
		begin
		Result := False;
		break;
		end;
	end;
if Result then
	begin
	CountXX := 0;
	for C in Comand do
		if C in 'xX' then
			begin
			X := C;
			CountXX += 1;
			end;
	Result := CountXX = 1;
	end;
if Result then
	begin
	Result := (Length(StringWordGet(Comand,X,1)) > 0) and (Length(StringWordGet(Comand,X,2))>0);
	end;
if Result then
	begin
	if ('WIDTH' in ContextSettings) then
		begin
		ContextSettings -= 'WIDTH';
		end;
	if ('HEIGHT' in ContextSettings) then
		begin
		ContextSettings -= 'HEIGHT';
		end;
	ContextSettings += SGContextOptionWidth (SGVal(StringWordGet(Comand,X,1)));
	ContextSettings += SGContextOptionHeight(SGVal(StringWordGet(Comand,X,2)));
	end;
end;

const TitleQuote : TSGChar = {$IFDEF MSWINDOWS}''''{$ELSE}'-'{$ENDIF};

function ProccessTitle(const Comand : TSGString):TSGBool;
begin
Result := True;
if ('TITLE' in ContextSettings) then
	begin
	ContextSettings -= 'TITLE';
	end;
ContextSettings += SGContextOptionTitle(StringWordGet(Comand,TitleQuote,2));
end;

function ProccessMax(const Comand : TSGString):TSGBool;
begin
Result := True;
ContextSettings -= 'MAX';
ContextSettings -= 'MIN';
ContextSettings += SGContextOptionMax();
end;

function ProccessMin(const Comand : TSGString):TSGBool;
begin
Result := True;
ContextSettings -= 'MAX';
ContextSettings -= 'MIN';
ContextSettings += SGContextOptionMin();
end;

function ImposibleParam(const B : TSGBool):TSGString;
begin
Result := Iff(not B,', but it is impossible!','')
end;

function HelpFuncGLUT() : TSGString;
begin
Result := 'For use GLUT' + ImposibleParam(IsGLUTSuppored());
end;

function HelpFuncDX8() : TSGString;
begin
Result := 'For use Direct3D X 8' +  ImposibleParam(IsD3DX8Suppored());
end;

function HelpFuncDX9() : TSGString;
begin
Result := 'For use Direct3D X 9' +  ImposibleParam(IsD3DX9Suppored());
end;

function HelpFuncDX12() : TSGString;
begin
Result := 'For use Direct3D X 12' + ImposibleParam(IsD3DX12Suppored());
end;

function HelpFuncOGL() : TSGString;
begin
Result := 'For use OpenGL' + ImposibleParam(TSGRenderOpenGL.Suppored());
end;

function IsOpenALSuppored() : TSGBoolean;
begin
Result :=
	{$IFDEF MOBILE}
	False
	{$ELSE}
	TSGAudioRenderOpenAL.Suppored()
	{$ENDIF}
	;
end;

function HelpFuncOAL() : TSGString;
begin
Result := 'For use OpenAL' + ImposibleParam(IsOpenALSuppored());
end;

function ProccessWA(const Comand : TSGString):TSGBool;
begin
Result := True;
AudioRenderClass := nil;
AudioDisabled := True;
end;

function ProccessOpenAL(const Comand : TSGString):TSGBool;
begin
Result := True;
if not IsOpenALSuppored() then
	begin
	WriteLn('OpenAL can''t be used in your system!');
	Result := False;
	end;
if AudioDisabled then
	begin
	WriteLn('Audio suppport allready disabled!');
	Result := False;
	end;
{$IFNDEF MOBILE}
if Result then
	AudioRenderClass := TSGAudioRenderOpenAL;
{$ENDIF}
end;

procedure Run();
begin
if (AudioRenderClass = nil) and (not AudioDisabled) then
	AudioRenderClass := TSGCompatibleAudioRender;
if (AudioRenderClass <> nil) then
	ContextSettings += SGContextOptionAudioRender(AudioRenderClass);
SGRunPaintable(
	VPaintabeClass
	,ContextClass
	,RenderClass
	,ContextSettings);
end;

var
	ConsoleCaller : TSGConsoleCaller = nil;
begin
SGPrintEngineVersion();
ContextClass := TSGCompatibleContext;
RenderClass  := TSGRenderOpenGL;
if (VParams<>nil) and (Length(VParams)>0) then
	begin
	ConsoleCaller := TSGConsoleCaller.Create(VParams);
	ConsoleCaller.Category('Context settings');
	ConsoleCaller.AddComand(@ProccessGLUT,      ['GLUT'],               @HelpFuncGLUT);
	ConsoleCaller.Category('Render settings');
	ConsoleCaller.AddComand(@ProccessDirectX12, ['D3D12','D3DX12'],     @HelpFuncDX12);
	ConsoleCaller.AddComand(@ProccessDirectX9,  ['D3D9', 'D3DX9'],      @HelpFuncDX9);
	ConsoleCaller.AddComand(@ProccessDirectX8,  ['D3D8', 'D3DX8'],      @HelpFuncDX8);
	ConsoleCaller.AddComand(@ProccessOpenGL  ,  ['ogl', 'OpenGL'],      @HelpFuncOGL);
	ConsoleCaller.Category('Audio settings');
	ConsoleCaller.AddComand(@ProccessOpenAL  ,  ['oal', 'OpenAL'],      @HelpFuncOAL);
	ConsoleCaller.AddComand(@ProccessWA      ,  ['wa', 'WithoutAudio'], 'Disable audio support');
	ConsoleCaller.Category('Window settings');
	ConsoleCaller.AddComand(@ProccessFullscreen,['F','FULLSCREEN'],     'For set window fullscreen mode');
	ConsoleCaller.AddComand(@ProccessMax,       ['MAX'],                'For maximize window arter initialization');
	ConsoleCaller.AddComand(@ProccessMin,       ['MIN'],                'For minimize window arter initialization');
	ConsoleCaller.AddComand(@ProccessWH,        ['?*X*?'],              'For set window width and height');
	ConsoleCaller.AddComand(@ProccessTitle,     ['t' + TitleQuote + '*' + TitleQuote],   'For set window title');
	ConsoleCaller.AddComand(@ProccessWidth,     ['W*?','WIDTH*?'],      'For set window width');
	ConsoleCaller.AddComand(@ProccessHeight,    ['H*?','HEIGHT*?'],     'For set window height');
	ConsoleCaller.AddComand(@ProccessLeft,      ['L*?','LEFT*?','X*?'], 'For set window x');
	ConsoleCaller.AddComand(@ProccessTop,       ['T*?','TOP*?', 'Y*?'], 'For set window y');
	if ConsoleCaller.Execute() then
		begin
		ConsoleCaller.Destroy();
		Run();
		end
	else
		ConsoleCaller.Destroy();
	end
else
	Run();
end;

type
	TSGAllApplicationsDrawable = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		procedure LoadDeviceResources();override;
		procedure DeleteDeviceResources();override;
		class function ClassName() : TSGString;override;
		end;

class function TSGAllApplicationsDrawable.ClassName() : TSGString;
begin
Result := 'TSGAllApplicationsDrawable';
end;

constructor TSGAllApplicationsDrawable.Create(const VContext : ISGContext);
begin
inherited Create(VContext);

with TSGDrawClasses.Create(Context) do
	begin
	Add(TSGLoading);
	
	Add(SGGetRegisteredDrawClasses());
	//Add(TSGUserTesting);
	//Add(TSGMeshViever);
	//Add(TSGExampleShader);
	//Add(TSGModelRedactor);
	//Add(TSGGameTron);
	//Add(TSGClientWeb);

	Initialize();
	end;
end;

procedure TSGAllApplicationsDrawable.LoadDeviceResources();
begin
end;

procedure TSGAllApplicationsDrawable.DeleteDeviceResources();
begin
end;

destructor TSGAllApplicationsDrawable.Destroy();
begin
inherited;
end;

procedure TSGAllApplicationsDrawable.Paint();
begin
end;

procedure SGConsoleShowAllApplications(const VParams : TSGConcoleCallerParams = nil;  ContextSettings : TSGContextSettings = nil);overload;
begin
SGConsoleRunPaintable(TSGAllApplicationsDrawable, VParams, ContextSettings);
end;

procedure SGConsoleShowAllApplications(const VParams : TSGConcoleCallerParams = nil);overload;
begin
SGConsoleRunPaintable(TSGAllApplicationsDrawable, VParams);
end;

procedure SGConsoleImageResizer(const VParams : TSGConcoleCallerParams = nil);
var
	Image:TSGImage;
begin
if (SGCountConsoleParams(VParams) = 3) and SGResourceFiles.FileExists(VParams[0]) and (SGVal(VParams[1]) > 0) and (SGVal(VParams[2]) > 0)  then
	begin
	Image:=TSGImage.Create();
	Image.Way := VParams[0];
	Image.Loading();
	Image.Image.SetBounds(
		SGVal(VParams[1]),
		SGVal(VParams[2]));
	Image.Way := SGGetFreeFileName(Image.Way);
	Image.Saveing();
	Image.Destroy();
	end
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGErrorString,'"@filename @new_width @new_height"!');
	end;
end;

procedure SGConsoleFindInPas(const VParams : TSGConcoleCallerParams = nil);
var
	ArWords:array of string = nil;
	Oy:LongWord;
	PF,PS:LongWord;
	FArF:packed array of TFileStream = nil;
	i,ii:LongWord;
	ArF:packed array of string = nil;
	FDir:string = '.';
var
	TempS,TempS2:String;
	NameFolder:string = '';
	ChisFi:LongWord = 0;
	StartingNow : Boolean = False;

procedure FindInFile(const VFile:String);
var
	f:text;
	Str:string;
	i:LongWord;
	ii:LongWord;
	iii:LongWord;
	iiii:LongWord;
	KolStr:LongWord = 0;
begin
PF+=1;
assign(f,VFile);
reset(f);
KolStr:=0;
while not eof(f) do
	begin
	KolStr+=1;
	readln(f,str);
	for ii:=1 to Length(str) do
		str[ii]:=UpCase(str[ii]);
	iii:=0;
	for ii:=Low(ArWords) to High(ArWords) do
		begin
		iiii:=Pos(ArWords[ii],str);
		if iiii<>0 then
			begin
			iii+=1;
			end;
		end;
	if iii<>0 then
		begin
		PS+=iii;
		if FArF=nil then
			iiii:=0
		else
			iiii:=Length(FArF);
		if iii>iiii then
			begin
			SetLength(FArF,iii);
			for i:=iiii to iii-1 do
				FArF[i]:=nil;
			end;
		if FArF[iii-1]=nil then
			FArF[iii-1]:=TFileStream.Create(NameFolder+Slash+'Results of '+SGStr(iii)+' matches.txt',fmCreate);
		SGWriteStringToStream('"'+VFile+'" : "'+SGStr(KolStr)+'"'+SGWinEoln,FArF[iii-1],False);
		end;
	end;
close(f);

Gotoxy(1,Oy);
textcolor(15);
write('Finded ');
textcolor(10);
write(PS);
textcolor(15);
write(' matches. Processed ');
textcolor(10);
write(PF);
textcolor(15);
write(' files in ');
TextColor(14);
Write(ChisFi);
TextColor(15);
wRITElN(' derictories...');
end;

procedure DoFiles(const VDir:string);
var
	sr:dos.searchrec;
	I:LongWord;
begin
for i:=0 to High(ArF) do
	begin
	dos.findfirst(VDir+Slash+'*.'+ArF[i],$3F,sr);
	while DosError<>18 do
		begin
		FindInFile(VDir+sr.name);
		dos.findnext(sr);
		end;
	dos.findclose(sr);
	end;
end;

procedure ConstWords;
var
	l:longint;
	i:longint;
	ii : LongWord;
begin
textcolor(15);
write('Enter words quantity:');
textcolor(10);
readln(l);
textcolor(15);
if (ArWords = nil) then
	ii := 0
else
	ii := Length(ArWords);
SetLength(ArWords,ii+l);
if (l>0) then
	for i:=ii to High(ArWords) do
		begin
		textcolor(15);
		write('Enter ',i+1,' word:');
		textcolor(10);
		readln(ArWords[i]);
		textcolor(15);
		end;
end;

procedure SkanWords;
var
	i:longint;
	ii:longint;
begin
for i:=Low(ArWords) to High(ArWords) do
	begin
	for ii:=1 to Length(ArWords[i]) do
		ArWords[i][ii]:=UpCase(ArWords[i][ii]);
	end;
i:=Low(ArWords);
while i<=High(ArWords) do
	begin
	if (ArWords[i]='') or (ArWords[i]=' ') or (ArWords[i]='  ') or (ArWords[i]='   ') or (ArWords[i]='    ') then
		begin
		for ii:=i to High(ArWords)-1 do
			ArWords[i]:=ArWords[i+1];
		SetLength(ArWords,Length(ArWords)-1);
		end;
	i+=1;
	end;
end;

procedure DoDirectories(const VDir:string);
var
	sr:dos.searchrec;
begin
DoFiles(VDir+Slash);
dos.findfirst(VDir+Slash+'*',$10,sr);
while DosError<>18 do
	begin
	if (sr.name<>'.') and (sr.name<>'..') and (not(SGFileExists(VDir+Slash+sr.name))) then
		BEGIN
		ChisFi+=1;
		DoDirectories(VDir+Slash+sr.name);
		END;
	dos.findnext(sr);
	end;
dos.findclose(sr);
end;

begin
SGPrintEngineVersion();

SetLength(ArF,13);
ArF[0]:='pas';
ArF[1]:='pp';
ArF[2]:='inc';
ArF[3]:='cpp';
ArF[4]:='cxx';
ArF[5]:='h';
ArF[6]:='hpp';
ArF[7]:='hxx';
ArF[8]:='c';
ArF[9]:='html';
ArF[10]:='bat';
ArF[11]:='cmd';
ArF[12]:='sh';
textcolor(15);

if SGCountConsoleParams(VParams) <> 0 then
	for i := 0 to SGCountConsoleParams(VParams) - 1 do
		begin
		TempS := SGUpCaseString(StringTrimLeft(VParams[i],'-'));
		if TempS <> SGUpCaseString(VParams[i]) then
			begin
			if (Length(TempS)>2) or (TempS='H') then
				if (TempS[1]='F') and (TempS[2]='D') then
					begin
					TempS2:='';
					for ii:=3 to Length(TempS) do
						TempS2+=TempS[ii];
					while (Length(TempS2)>0) and ((TempS2[Length(TempS2)]='\') or (TempS2[Length(TempS2)]='/')) do
						SetLength(TempS2,Length(TempS2)-1);
					if TempS2='' then
						TempS2:='.';
					FDir:=TempS2;
					Write('Selected find directory "');TextColor(14);Write(FDir);TextColor(15);WriteLn('".');
					end
				else if (TempS='VIEWEXP') then
					begin
					Write('Finding expansion:');textColor(14);Write('{');
					for ii:=0 to High(ArF) do
						begin
						TextColor(13);Write(ArF[ii]);TextColor(14);
						if ii<>High(ArF) then
							Write(',');
						end;
					TextColor(14);WriteLn('}');TextColor(15);
					end
				else if (TempS='HELP') or (TempS='H') then
					begin
					WriteLn('This is help for "Find in pas".');
					Write('    -FD');TextColor(13);Write('($directory)');TextColor(15);WriteLn(' : for change find directory.');
					WriteLn('    -H; -HELP : for run help.');
					WriteLn('    -VIEWEXP : for view expansion for find');
					Exit;
					end
				else if (Length(TempS)>4) and (TempS[1]='W')and (TempS[2]='O')and (TempS[3]='R')and (TempS[4]='D') then
					begin
					if (ArWords = nil) then
						SetLength(ArWords,1)
					else
						SetLength(ArWords,Length(ArWords)+1);

					if (TempS[5] = '"') then
						begin
						TempS2 := '';
						for ii := 6 to Length(TempS)-1 do
							TempS2+=TempS[ii];
						end
					else
						begin
						TempS2 := '';
						for ii := 5 to Length(TempS) do
							TempS2+=TempS[ii];
						end;
					ArWords[High(ArWords)] := TempS2;
					TempS2:='';
					end
				else if (TempS='START') then
					begin
					StartingNow := True;
					end
				else
					WriteLn('FindInPas : error : comand syntax "',VParams[i],'"')
			else
				WriteLn('FindInPas : error : comand syntax "',VParams[i],'"');
			end
		else
			WriteLn('FindInPas : error : simbol "',VParams[i],'"');
		end;

PF:=0;PS:=0;OY:=0;
NameFolder:=SGGetFreeDirectoryName('Find In Pas Results','Part');
SGMakeDirectory(NameFolder);
Write('Created results directory "');TextColor(14);Write(NameFolder);TextColor(15);WriteLn('".');
if (not StartingNow) then
	ConstWords();
if Length(ArWords)<>0 then
	begin
	SkanWords;
	writeln('Find was begining... Psess any key to stop him...');
	Oy:=WhereY;
	DoDirectories(FDir);
	if FArF<>nil then
		begin
		for i:=0 to High(FArF) do
			if FArF[i]<>nil then
				begin
				FArF[i].Destroy;
				end;
		SetLength(FArF,0);
		end;
	end;
if PS=0 then
	begin
	RMDIR(NameFolder);
	if Length(ArWords)<>0 then begin TextColor(12);Writeln('Matches don''t exists...'); end;
	TextColor(15);Write('Deleted results directory "');TextColor(14);Write(NameFolder);TextColor(15);WriteLn('".');
	end;
SetLength(ArF,0);
SetLength(ArWords,0);
end;


procedure FPCTCTransliater();
var
	SGT:SGTranslater = nil;
begin
SGT:=SGTranslater.Create('cmd');
SGT.GoTranslate;
SGT.Destroy;
end;

procedure GoogleReNameCache();
var
	Cache:string = 'Cache';
var
	sr:DOS.SearchRec;
	f:TFileStream;
	b:word;
	razr:string;

function IsRazr(const a:string):Boolean;
var
	i:LongWord;
begin
Result:=False;
for i:=1 to Length(a) do
	if a[i]='.' then
		begin
		Result:=True;
		Break;
		end;
end;

begin
if argc>2 then
	Cache:=SGGetComand(argv[2]);
if not SGExistsDirectory('.'+Slash+Cache) then
	begin
	WriteLn('Cashe Directory is not exists: "','.\'+Slash+Cache,'".');
	Exit;
	end;
SGMakeDirectory('.'+Slash+Cache+Slash+'Temp');
SGMakeDirectory('.'+Slash+Cache+Slash+'Complited');
DOS.findfirst('.'+Slash+Cache+Slash+'f_*',$3F,sr);
While (dos.DosError<>18) do
	begin
	if not IsRazr(sr.name) then
		begin
		razr:='';
		F:=TFileStream.Create('.'+Slash+Cache+Slash+sr.Name,fmOpenRead);
		if F.Size >=2 then
		F.ReadBuffer(b,2);
		F.Destroy;
		case b of
		22339:;//хз
		0:
			begin
			F:=TFileStream.Create('.'+Slash+Cache+Slash+sr.Name,fmOpenRead);
			if F.Size >=4 then
			F.ReadBuffer(b,2);
			F.ReadBuffer(b,2);
			F.Destroy;
			if b = 8192 then
				razr:='wmv'
			else
				begin writeln('Unknown ',sr.Name,' 0, ',b,'.');  end;
			end;
		8508,29230,35615,10799,12079,28777,10250:razr:=' ';
		20617:razr:='png';
		55551:razr:='jpg';
		17481:razr:='mp3';
		18759:razr:='gif';
		else begin writeln('Unknown ',sr.Name,' ',b,'.');  end;
		end;
		if razr=' ' then
			begin
			{$IFDEF MSWINDOWS}MoveFile{$ELSE}RenameFile{$ENDIF}(SGStringToPChar('.'+Slash+Cache+Slash+sr.Name),SGStringToPChar('.'+Slash+Cache+Slash+'Temp'+Slash+sr.Name));
			end
		else
			if razr<>'' then
				{$IFDEF MSWINDOWS}MoveFile{$ELSE}RenameFile{$ENDIF}(SGStringToPChar('.'+Slash+Cache+Slash+sr.Name),SGStringToPChar('.'+Slash+Cache+Slash+'Complited'+Slash+sr.Name+'.'+razr));
		end;
	DOS.findnext(sr);
	end;
DOS.findclose(sr);
end;

procedure RunOtherEnginesConsoleProgramsConsoleCaller(const VParams : TSGConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
OtherEnginesConsoleProgramsConsoleCaller.Params := VParams;
OtherEnginesConsoleProgramsConsoleCaller.Execute();
end;

procedure InitOtherEnginesConsoleProgramsConsoleCaller();
begin
OtherEnginesConsoleProgramsConsoleCaller := TSGConsoleCaller.Create(nil);
OtherEnginesConsoleProgramsConsoleCaller.Category('Images tools');
OtherEnginesConsoleProgramsConsoleCaller.AddComand(@SGConsoleImageResizer, ['IR',''], 'Image Resizer');
OtherEnginesConsoleProgramsConsoleCaller.AddComand(@SGConsoleConvertImageToSaGeImageAlphaFormat, ['CTSGIA'], 'Convert image To SaGeImagesAlpha format');
OtherEnginesConsoleProgramsConsoleCaller.Category('Math tools');
OtherEnginesConsoleProgramsConsoleCaller.AddComand(@SGConsoleCalculateExpression, ['ce'], 'Calculate Expression');
OtherEnginesConsoleProgramsConsoleCaller.AddComand(@SGConsoleCalculateBoolTable, ['cbt'], 'Calculate Boolean Table');
end;

procedure InitGeneralConsoleCaller();
begin
GeneralConsoleCaller := TSGConsoleCaller.Create(nil);
GeneralConsoleCaller.AddComand(@SGConcoleCaller, ['CONSOLE'], 'Run console caller');
GeneralConsoleCaller.Category('Applications');
GeneralConsoleCaller.AddComand(@SGConsoleFindInPas, ['FIP'], 'Find In Pas program');
GeneralConsoleCaller.AddComand(@SGConsoleMake, ['MAKE'], 'Make utility');
GeneralConsoleCaller.AddComand(@SGConsoleShowAllApplications, ['GUI',''], 'Shows all 3D/2D scenes');
GeneralConsoleCaller.Category('System applications');
GeneralConsoleCaller.AddComand(@SGConsoleAddToLog, ['ATL'], 'Add line To Log');
GeneralConsoleCaller.AddComand(@SGConsoleConvertDirectoryFilesToPascalUnits, ['CDTPUARU'], 'Convert Directory Files To Pascal Units utility');
GeneralConsoleCaller.AddComand(@SGConsoleConvertHeaderToDynamic, ['CHTD','DDH'], 'Convert pascal Header to Dynamic utility');
GeneralConsoleCaller.AddComand(@SGConsoleConvertFileToPascalUnit, ['CFTPU'], 'Convert File To Pascal Unit utility');
GeneralConsoleCaller.AddComand(@SGConsoleShaderReadWrite, ['SRW'], 'Read shader file with params and write it as single file without directives');
GeneralConsoleCaller.AddComand(@RunOtherEnginesConsoleProgramsConsoleCaller, ['oecp'], 'Other Engine''s Console Programs');
GeneralConsoleCaller.Category('Build tools');
GeneralConsoleCaller.AddComand(@SGConsoleBuild, ['BUILD'], 'Building SaGe Engine');
GeneralConsoleCaller.AddComand(@SGConsoleClearFileRegistrationResources, ['Cfrr'], 'Clear File Registration Resources');
GeneralConsoleCaller.AddComand(@SGConsoleClearFileRegistrationPackages, ['Cfrp'], 'Clear File Registration Packages');
GeneralConsoleCaller.AddComand(@SGConsoleConvertFileToPascalUnitAndRegisterUnit, ['CFTPUARU'], 'Convert File To Pascal Unit And Register Unit in registration file');
GeneralConsoleCaller.AddComand(@SGConsoleConvertCachedFileToPascalUnitAndRegisterUnit, ['CCFTPUARU'], 'Convert Cached File To Pascal Unit And Register Unit in registration file');
GeneralConsoleCaller.AddComand(@SGConsoleIncEngineVersion, ['IV'], 'Increment engine Version');
GeneralConsoleCaller.AddComand(@SGConsoleBuildFiles, ['BF'], 'Build files in datafile');
GeneralConsoleCaller.Category('System tools');
GeneralConsoleCaller.AddComand(@SGConsoleHash, ['hash'], 'Print checksum for file');
GeneralConsoleCaller.AddComand(@SGConsoleIsConsole, ['ic'], 'Return bool value, is console or not');
GeneralConsoleCaller.AddComand(@SGConsoleExtractFiles, ['EF'], 'Extract all files in this application');
GeneralConsoleCaller.AddComand(@SGConsoleWriteOpenableExpansions, ['woe'], 'Write all of openable expansions of files');
GeneralConsoleCaller.AddComand(@SGConsoleWriteFiles, ['WF'], 'Write all files in this application');
GeneralConsoleCaller.AddComand(@SGConsoleDllPrintStat, ['dlps'], 'Prints all statistics data of dynamic libraries, used in this application');
end;

procedure DestroyOtherEnginesConsoleProgramsConsoleCaller();
begin
OtherEnginesConsoleProgramsConsoleCaller.Destroy();
OtherEnginesConsoleProgramsConsoleCaller := nil;
end;

procedure DestroyGeneralConsoleCaller();
begin
GeneralConsoleCaller.Destroy();
GeneralConsoleCaller := nil;
end;

initialization
begin
InitGeneralConsoleCaller();
InitOtherEnginesConsoleProgramsConsoleCaller();
end;

finalization
begin
DestroyOtherEnginesConsoleProgramsConsoleCaller();
DestroyGeneralConsoleCaller();
end;

end.
