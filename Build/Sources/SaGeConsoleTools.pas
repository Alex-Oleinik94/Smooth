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
	,SaGeRender
	,SaGeCommon
	,SaGeImagesBase
	,SaGeContext
	,SaGeImages
	,SaGeBase
	,SaGeBased
	,SaGeMath
	,SaGeExamples
	,SaGeCommonUtils
	,SaGeFractals
	,SaGeUtils
	,SaGeModel
	,SaGeMesh
	,SaGeShaders
	,SaGeNet
	,SaGeResourseManager
	,SaGeVersion
	,SaGeMakefileReader
	,SaGeCommonClasses
	,SaGeFileOpener
	
	(* ============ Additional Engine Includes ============ *)
	,SaGeFPCToC
	,SaGeModelRedactor
	,SaGeGasDiffusion
	,SaGeClientWeb
	,SaGeGeneticalAlgoritm
	,SaGeAllExamples
	,SaGeUserTesting
	,SaGeTron
	,SaGeLoading
	,SaGeNotepad
	,SaGeKiller
	;

const
	SGErrorString = 'Error of parameters, use ';

type
	TSGConcoleCallerProcedure = procedure (const VParams : TSGConcoleCallerParams = nil);
	TSGConcoleCallerNestedProcedure = function (const VParam : TSGString) : TSGBool is nested;
	TSGConsoleCaller = class
			public
		constructor Create(const VParams : TSGConcoleCallerParams);
		destructor Destroy();override;
		procedure AddComand(const VComand       : TSGConcoleCallerProcedure;       const VSyntax : packed array of const; const VHelp : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure AddComand(const VNestedComand : TSGConcoleCallerNestedProcedure; const VSyntax : packed array of const; const VHelp : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		function Execute() : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			private
		FParams : TSGConcoleCallerParams;
		FComands : packed array of
			packed record
				FComand       : TSGConcoleCallerProcedure;
				FNestedComand : TSGConcoleCallerNestedProcedure;
				FSyntax       : TSGConcoleCallerParams;
				FHelpString   : TSGString;
				end;
			private
		function AllNested() : TSGBool;
		function AllNormal() : TSGBool;
		end;

procedure FPCTCTransliater();
procedure GoogleReNameCache();

procedure SGConcoleCaller                                (const VParams : TSGConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGConsoleShowAllApplications                   (const VParams : TSGConcoleCallerParams = nil);overload;
procedure SGConsoleConvertImageToSaGeImageAlphaFormat    (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleBuild                                 (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleShaderReadWrite                       (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleClearRFFile                           (const VParams : TSGConcoleCallerParams = nil);
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

function SGDecConsoleParams(const Params : TSGConcoleCallerParams) : TSGConcoleCallerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGCountConsoleParams(const Params : TSGConcoleCallerParams) : TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGIsBoolConsoleParam(const Param : TSGString):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGPrintConsoleParams();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SGConsoleRunPaintable(const VPaintabeClass : TSGDrawableClass; const VParams : TSGConcoleCallerParams = nil; ContextSettings : TSGContextSettings = nil);
procedure SGConsoleShowAllApplications(const VParams : TSGConcoleCallerParams = nil;  ContextSettings : TSGContextSettings = nil);overload;
procedure SGStandartCallConcoleCaller();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

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
	;

procedure SGConsoleConvertHeaderToDynamic(const VParams : TSGConcoleCallerParams = nil);
begin
if (Length(VParams) = 2) and (SGResourseFiles.FileExists(VParams[0])) then
	SGConvertHeaderToDynamic(VParams[0], VParams[1])
else if (Length(VParams) = 3) and (SGResourseFiles.FileExists(VParams[0])) and ((SGUpCaseString(VParams[2]) = 'OBJFPC') or (SGUpCaseString(VParams[2]) = 'DELPHI') or (SGUpCaseString(VParams[2]) = 'FPC')) then
	SGConvertHeaderToDynamic(VParams[0], VParams[1], VParams[2])
else
	begin 
	SGPrintEngineVersion();
	WriteLn(SGErrorString,'"@infilename @outfilename [@mode]. Param @mode is in set of "ObjFpc", "fpc" or "Delphi".');
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
	SGResourseFiles.WriteFiles();
end;

procedure SGConcoleCaller(const VParams : TSGConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	ConsoleCaller : TSGConsoleCaller = nil;
begin
ConsoleCaller := TSGConsoleCaller.Create(VParams);
ConsoleCaller.AddComand(@SGConcoleCaller, ['CONSOLE'], 'Run console caller');
ConsoleCaller.AddComand(@SGConsoleConvertImageToSaGeImageAlphaFormat, ['CTSGIA'], 'Convert image To SaGeImagesAlpha format');
ConsoleCaller.AddComand(@SGConsoleBuild, ['BUILD'], 'Building SaGe Engine');
ConsoleCaller.AddComand(@SGConsoleShaderReadWrite, ['SRW'], 'Read shader file with params and write it');
ConsoleCaller.AddComand(@SGConsoleClearRFFile, ['CRF'], 'Clear RF File');
ConsoleCaller.AddComand(@SGConsoleConvertFileToPascalUnitAndRegisterUnit, ['CFTPUARU'], 'Convert File To Pascal Unit And Register Unit in rffile');
ConsoleCaller.AddComand(@SGConsoleAddToLog, ['ATL'], 'Add line To Log');
ConsoleCaller.AddComand(@SGConsoleIncEngineVersion, ['IV'], 'Inc engine Version');
ConsoleCaller.AddComand(@SGConsoleConvertFileToPascalUnit, ['CFTPU'], 'Convert File To Pascal Unit');
ConsoleCaller.AddComand(@SGConsoleExtractFiles, ['EF'], 'Extract all files in this application');
ConsoleCaller.AddComand(@SGConsoleWriteFiles, ['WF'], 'Write all files in this application');
ConsoleCaller.AddComand(@SGConsoleConvertDirectoryFilesToPascalUnits, ['CDTPUARU'], 'Convert Directory Files To Pascal Units');
ConsoleCaller.AddComand(@SGConsoleFindInPas, ['FIP'], 'Find In Pas program');
ConsoleCaller.AddComand(@SGConsoleImageResizer, ['IR'], 'Image Resizer');
ConsoleCaller.AddComand(@SGConsoleMake, ['MAKE'], 'Make utility');
ConsoleCaller.AddComand(@SGConsoleWriteOpenableExpansions, ['woe'], 'Write all of openable expansions of files');
ConsoleCaller.AddComand(@SGConsoleConvertHeaderToDynamic, ['CHTD','DDH'], 'Convert header to dynamic utility');
ConsoleCaller.AddComand(@SGConsoleShowAllApplications, ['GUI',''], 'Shows all scenes in this application');
ConsoleCaller.Execute();
ConsoleCaller.Destroy();
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
if (SGCountConsoleParams(VParams) = 3) and SGResourseFiles.FileExists(VParams[2]) and SGExistsDirectory(VParams[0])and SGExistsDirectory(VParams[1]) then
	SGConvertDirectoryFilesToPascalUnits(VParams[0],VParams[1],VParams[2])
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGErrorString,'"@dirname @outdirname @rffile"');
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
	SGResourseFiles.ExtractFiles(VParams[0],(SGUpCaseString(Param) = 'TRUE') or (Param = '1'));
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
if ((SGCountConsoleParams(VParams) = 3) or ((SGCountConsoleParams(VParams) = 4) and (SGIsBoolConsoleParam(VParams[3])))) and SGResourseFiles.FileExists(VParams[0]) and SGExistsDirectory(VParams[1]) then
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
if (SGCountConsoleParams(VParams) = 2) and SGResourseFiles.FileExists(VParams[0]) then
	SGAddToLog(VParams[0],VParams[1])
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGErrorString,'"@logfilename @line"');
	end;
end;

procedure SGConsoleConvertFileToPascalUnitAndRegisterUnit(const VParams : TSGConcoleCallerParams = nil);
var
	i, ii : TSGLongWord;
begin
ii := 0;
if (VParams <> nil) then
	ii := Length(VParams);
if (ii = 4) and SGResourseFiles.FileExists(VParams[0]) and SGResourseFiles.FileExists(VParams[3]) and SGExistsDirectory(VParams[1]) then
	begin
	SGConvertFileToPascalUnit(VParams[0],VParams[1],VParams[2],True);
	SGRegisterUnit(VParams[2],VParams[3]);
	end
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGErrorString,'"@filename @unitdir @unitname @rffilename"');
	end;
end;

procedure SGConsoleClearRFFile(const VParams : TSGConcoleCallerParams = nil);
begin
if (VParams <> nil) and (Length(VParams) = 1) and (VParams[0] <> '') then
	SGClearRFFile(VParams[0])
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGErrorString,'"@filename"');
	end;
end;

procedure SGConsoleBuild(const VParams : TSGConcoleCallerParams = nil);
begin
SGPrintEngineVersion();
WriteLn('Building SaGe...');
SGRunComand('cmd /c "cd ./../Build & ./FPC_Make_Debug.cmd"');
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
if (ii >= 2) and SGResourseFiles.FileExists(VParams[0]) then
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
else if (VParams <> nil) and (Length(VParams) = 2) and SGResourseFiles.FileExists(VParams[0]) then
	SGConvertToSGIA(VParams[0],VParams[1])
else
	begin
	SGPrintEngineVersion();
	WriteLn('Error!');
	end;
end;

constructor TSGConsoleCaller.Create(const VParams : TSGConcoleCallerParams);
begin
FParams := VParams;
FComands := nil;
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

procedure TSGConsoleCaller.AddComand(const VComand : TSGConcoleCallerProcedure; const VSyntax : packed array of const; const VHelp : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i : TSGLongWord;
begin
if FComands = nil then
	SetLength(FComands, 1)
else
	SetLength(FComands, Length(FComands) + 1);
FComands[High(FComands)].FComand := VComand;
FComands[High(FComands)].FNestedComand := nil;
FComands[High(FComands)].FHelpString := VHelp;
FComands[High(FComands)].FSyntax := SGArConstToArString(VSyntax);
if (FComands[High(FComands)].FSyntax <> nil) and (Length(FComands[High(FComands)].FSyntax)>0) then
	for i := 0 to High(FComands[High(FComands)].FSyntax) do
		FComands[High(FComands)].FSyntax[i] := SGUpCaseString(FComands[High(FComands)].FSyntax[i]);
end;

procedure TSGConsoleCaller.AddComand(const VNestedComand : TSGConcoleCallerNestedProcedure; const VSyntax : packed array of const; const VHelp : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i : TSGLongWord;
begin
if FComands = nil then
	SetLength(FComands, 1)
else
	SetLength(FComands, Length(FComands) + 1);
FComands[High(FComands)].FComand := nil;
FComands[High(FComands)].FNestedComand := VNestedComand;
FComands[High(FComands)].FHelpString := VHelp;
FComands[High(FComands)].FSyntax := SGArConstToArString(VSyntax);
if (FComands[High(FComands)].FSyntax <> nil) and (Length(FComands[High(FComands)].FSyntax)>0) then
	for i := 0 to High(FComands[High(FComands)].FSyntax) do
		FComands[High(FComands)].FSyntax[i] := SGUpCaseString(FComands[High(FComands)].FSyntax[i]);
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
		if not SGResourseFiles.FileExists(FParams[i]) then
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
	i, ii : TSGLongWord;
begin
if (FComands <> nil) and (Length(FComands)>0) then
	begin
	SGPrintEngineVersion();
	WriteLn('Help:');
	WriteLn(' --help, --h, --? - Shows this');
	for i := 0 to High(FComands) do
		begin
		if (FComands[i].FSyntax <> nil) and (Length(FComands[i].FSyntax)>0) then
			begin
			for ii := 0 to High(FComands[i].FSyntax) do
				if FComands[i].FSyntax[ii] <> '' then
					begin
					if ii <> 0 then
						Write(',');
					Write(' --',SGDownCaseString(FComands[i].FSyntax[ii]));
					end;
			WriteLn(' - ',FComands[i].FHelpString);
			end;
		end;
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
			ContextSettings += SGContextOptionFullscreen(False);
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

const TitleQuote : TSGChar = '''';

function ProccessTitle(const Comand : TSGString):TSGBool;
begin
Result := True;
if ('TITLE' in ContextSettings) then
	begin
	ContextSettings -= 'TITLE';
	end;
ContextSettings += SGContextOptionTitle(StringWordGet(Comand,TitleQuote,2));
end;

procedure Run();
begin
SGRunPaintable(
	VPaintabeClass
	,ContextClass
	,RenderClass
	,ContextSettings);
end;

function ImposibleParam(const B : TSGBool):TSGString;
begin
Result := Iff(not B,', but it is impossible!','')
end;

var
	ConsoleCaller : TSGConsoleCaller = nil;
begin
SGPrintEngineVersion();
ContextClass := TSGCompatibleContext;
RenderClass  := TSGCompatibleRender;
if (VParams<>nil) and (Length(VParams)>0) then
	begin
	ConsoleCaller := TSGConsoleCaller.Create(VParams);
	ConsoleCaller.AddComand(@ProccessGLUT,      ['GLUT'],               'For use GLUT' +          ImposibleParam(IsGLUTSuppored()));
	ConsoleCaller.AddComand(@ProccessDirectX12, ['D3D12','D3DX12'],     'For use Direct3D X 12' + ImposibleParam(IsD3DX12Suppored()));
	ConsoleCaller.AddComand(@ProccessDirectX9,  ['D3D9', 'D3DX9'],      'For use Direct3D X 9' +  ImposibleParam(IsD3DX9Suppored()));
	ConsoleCaller.AddComand(@ProccessDirectX8,  ['D3D8', 'D3DX8'],      'For use Direct3D X 8' +  ImposibleParam(IsD3DX8Suppored()));
	ConsoleCaller.AddComand(@ProccessFullscreen,['F','FULLSCREEN'],     'For set window fullscreen mode');
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
		procedure LoadDeviceResourses();override;
		procedure DeleteDeviceResourses();override;
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
	Add(TSGNotepadApplication);
	Add(TSGGasDiffusion);
	Add(TSGAllFractals,False);
	Add(TSGAllExamples,False);
	Add(TSGLoading);
	Add(TSGGraphViewer);
	Add(TSGKiller);
	Add(TSGGenAlg);
	
	//Add(TSGUserTesting);
	//Add(TSGGraphic);
	//Add(TSGGraphViewer3D);
	//Add(TSGMeshViever);
	//Add(TSGExampleShader);
	//Add(TSGModelRedactor);
	//Add(TSGGameTron);
	//Add(TSGClientWeb);
	
	Initialize();
	end;
end;

procedure TSGAllApplicationsDrawable.LoadDeviceResourses();
begin
end;

procedure TSGAllApplicationsDrawable.DeleteDeviceResourses();
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
if (SGCountConsoleParams(VParams) = 3) and SGResourseFiles.FileExists(VParams[0]) and (SGVal(VParams[1]) > 0) and (SGVal(VParams[2]) > 0)  then
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
	i,ii,iii:LongWord;
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
wRITElN(' derictoryes...');
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

SetLength(ArF,10);
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

end.
