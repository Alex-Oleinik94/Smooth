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
	{$IF defined(ANDROID)}
		,android_native_app_glue
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
	TSGConsoleCaller = class
			public
		constructor Create(const VParams : TSGConcoleCallerParams);
		destructor Destroy();override;
		procedure AddComand(const VComand : TSGConcoleCallerProcedure; const VSyntax : packed array of const; const VHelp : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Execute();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			private
		FParams : TSGConcoleCallerParams;
		FComands : packed array of
			packed record
				FComand : TSGConcoleCallerProcedure;
				FSyntax : TSGConcoleCallerParams;
				FHelpString : TSGString;
				end;
		end;

procedure SGStandartCallConcoleCaller();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure FPCTCTransliater();
procedure GoogleReNameCache();
procedure GoViewer(const FileWay : String);

function SGDecConsoleParams(const Params : TSGConcoleCallerParams) : TSGConcoleCallerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGCountConsoleParams(const Params : TSGConcoleCallerParams) : TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGIsBoolConsoleParam(const Param : TSGString):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGPrintConsoleParams();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGConsoleRunPaintable(const VPaintabeClass : TSGDrawableClass; const VParams : TSGConcoleCallerParams = nil{$IFDEF ANDROID};const State : PAndroid_App = nil{$ENDIF});

procedure SGConcoleCaller(const VParams : TSGConcoleCallerParams = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGConsoleShowAllApplications(const VParams : TSGConcoleCallerParams = nil{$IFDEF ANDROID};const State : PAndroid_App = nil{$ENDIF});
procedure SGConsoleConvertImageToSaGeImageAlphaFormat(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleBuild(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleShaderReadWrite(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleClearRFFile(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleConvertFileToPascalUnitAndRegisterUnit(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleAddToLog(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleIncEngineVersion(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleConvertFileToPascalUnit(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleExtractFiles(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleConvertDirectoryFilesToPascalUnits(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleFindInPas(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleImageResizer(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleMake(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleConvertHeaderToDynamic(const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	SaGeConvertHeaderToDynamic
	{$IFDEF MSWINDOWS}
		,SaGeRenderDirectX9
		,SaGeRenderDirectX8
		,SaGeRenderDirectX12
		{$ENDIF}
	,SaGeRenderOpenGL
	{$IFDEF ANDROID}
		,SaGeContextAndroid
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
ConsoleCaller.AddComand(@SGConsoleExtractFiles, ['EF'], 'Extract all Files in this application');
ConsoleCaller.AddComand(@SGConsoleConvertDirectoryFilesToPascalUnits, ['CDTPUARU'], 'Convert Directory Files To Pascal Units');
ConsoleCaller.AddComand(@SGConsoleFindInPas, ['FIP'], 'Find In Pas program');
ConsoleCaller.AddComand(@SGConsoleImageResizer, ['IR'], 'Image Resizer');
ConsoleCaller.AddComand(@SGConsoleMake, ['MAKE'], 'Make utility');
ConsoleCaller.AddComand(@SGConsoleConvertHeaderToDynamic, ['CHTD','DDH'], 'Convert header to dynamic utility');
ConsoleCaller.AddComand(TSGConcoleCallerProcedure(@SGConsoleShowAllApplications), ['GUI',''], 'Shows all scenes in this application');
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
	SGSaveShaderSourseToFile(VParams[1],
		SGReadShaderSourseFromFile(VParams[0],Params));
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

procedure TSGConsoleCaller.AddComand(const VComand : TSGConcoleCallerProcedure; const VSyntax : packed array of const; const VHelp : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
if FComands = nil then
	SetLength(FComands, 1)
else
	SetLength(FComands, Length(FComands) + 1);
FComands[High(FComands)].FComand := VComand;
FComands[High(FComands)].FHelpString := VHelp;
FComands[High(FComands)].FSyntax := SGArConstToArString(VSyntax);
if (FComands[High(FComands)].FSyntax <> nil) and (Length(FComands[High(FComands)].FSyntax)>0) then
	for i := 0 to High(FComands[High(FComands)].FSyntax) do
		FComands[High(FComands)].FSyntax[i] := SGUpCaseString(FComands[High(FComands)].FSyntax[i]);
end;

procedure TSGConsoleCaller.Execute();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

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
		SGPrintEngineVersion();
		TextColor(12);
		Write('Console caller : error : unknown simbol "');
		TextColor(15);
		Write(FParams[0]);
		TextColor(12);
		Write('", use "');
		TextColor(15);
		Write('--help');
		TextColor(12);
		WriteLn('"');
		TextColor(7);
		end;
	end;
end;

var
	i, ii, iii : TSGLongWord;
	Comand : TSGString;
	Params : TSGConcoleCallerParams;

begin
if OpenFileCheck() then
	begin
	SGPrintEngineVersion();
	WriteLn('Try to open file(-s):');
	for i := 0 to High(FParams) do
		WriteLn('   ',FParams[i]);
	ReadLn();
	end
else
	begin
	Comand := ComandCheck();
	if (Comand = 'HELP') or (Comand = 'H') or (Comand = '?') then
		begin
		if (FComands <> nil) and (Length(FComands)>0) then
			begin
			SGPrintEngineVersion();
			WriteLn('Help:');
			WriteLn(' "--help", "--h", "--?" - Shows this');
			for i := 0 to High(FComands) do
				begin
				if (FComands[i].FSyntax <> nil) and (Length(FComands[i].FSyntax)>0) then
					begin
					for ii := 0 to High(FComands[i].FSyntax) do
						if FComands[i].FSyntax[ii] <> '' then
							begin
							if ii <> 0 then
								Write(',');
							Write(' "--',StringCase(FComands[i].FSyntax[ii],@LowerCase),'"');
							end;
					WriteLn(' - ',FComands[i].FHelpString);
					end;
				end;
			end;
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
						SGPrintEngineVersion();
						TextColor(12);
						Write('Console caller : error : abstrac comand "');
						TextColor(15);
						Write(SGDownCaseString(Comand));
						TextColor(12);
						WriteLn('"!');
						TextColor(7);
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
			SGPrintEngineVersion();
			SGPrintEngineVersion();
			TextColor(12);
			Write('Console caller : error : unknown comand "');
			TextColor(15);
			Write(SGDownCaseString(Comand));
			TextColor(12);
			Write('", use "');
			TextColor(15);
			Write('--help');
			TextColor(12);
			WriteLn('"');
			TextColor(7);
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

procedure SGConsoleRunPaintable(const VPaintabeClass : TSGDrawableClass; const VParams : TSGConcoleCallerParams = nil{$IFDEF ANDROID};const State : PAndroid_App = nil{$ENDIF});
var
	{$IFDEF MSWINDOWS}
		FRenderState:(SGBR_OPENGL,SGBR_DIRECTX_9,SGBR_DIRECTX_8,SGBR_UNKNOWN) = SGBR_OPENGL;
		{$ENDIF}
	VFullscreen:TSGBoolean = {$IFDEF ANDROID}True{$ELSE}False{$ENDIF};

procedure ReadParams();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	GoToExit : TSGBoolean = False;
	i, ii : TSGLongWord;
	S : TSGString;
	HelpUsed : TSGBoolean = False;
begin
if (VParams<>nil) and (Length(VParams)>0) then
	begin
	for i:= 0 to High(VParams) do
		if StringTrimLeft(VParams[i], '-') <> VParams[i] then
			begin
			S := SGUpCaseString(StringTrimLeft(VParams[i], '-'));
			if (S='HELP') or (S='H')or (S='?') then
				begin
				WriteLn('This is additional params for running GUI.');
				WriteLn('     -h; -help; -?   : for show this');
				{$IFDEF MSWINDOWS}
					Write('     -ogl            : for use OpenGL');WriteLn();
					Write('     -d3dx9          : for use DirectX 9');
					if TSGRenderDirectX9.Suppored() then
						WriteLn()
					else
						WriteLn(', but it is impossible for your system!');
					Write('     -d3dx8          : for use DirectX 8');
					if TSGRenderDirectX8.Suppored() then
						WriteLn()
					else
						WriteLn(', but it is impossible for your system!');
					{$ENDIF}
				WriteLn('     -f; -fullscreen : for change fullscreen mode');
				GoToExit := True;
				HelpUsed := True;
				Break;
				end
			{$IFDEF MSWINDOWS}
				else if (S='OGL') or (S='OPENGL') then
					begin
					{$IFDEF SGMoreDebuging}
						WriteLn('Engine uses OpenGL.');
						{$ENDIF}
					FRenderState:=SGBR_OPENGL;
					end
				else if (S='D3DX') or (S='DIRECT3D')or (S='DIRECTX')or (S='DIRECT3DX') or (S='D3DX9') or (S='DIRECT3D9')or (S='DIRECTX9')or (S='DIRECT3DX9') then
					begin
					{$IFDEF SGMoreDebuging}
						WriteLn('Engine uses DirectX 9.');
						{$ENDIF}
					FRenderState:=SGBR_DIRECTX_9;
					end
				else if (S='D3DX8') or (S='DIRECT3D8')or (S='DIRECTX8')or (S='DIRECT3DX8') then
					begin
					{$IFDEF SGMoreDebuging}
						WriteLn('Engine uses DirectX 8.');
						{$ENDIF}
					FRenderState:=SGBR_DIRECTX_8;
					end
				{$ENDIF}
			else if (S='F') or (S='FULLSCREEN') then
				begin
				VFullscreen:=not VFullscreen;
				{$IFDEF SGMoreDebuging}
					WriteLn('Set fullscreen : "',VFullscreen,'"');
					{$ENDIF}
				end
			else
				begin
				WriteLn('Unknown comand "',S,'"!');
				GoToExit := True;
				end;
			end
		else
			begin
			WriteLn('Unknown comand string "',VParams[i],'"!');
			GoToExit := True;
			end;
	end;
if GoToExit then
	begin
	if not HelpUsed then
		WriteLn('Use "-help" for help!');
	Halt();
	end;
end;

var
	RenderClass : TSGRenderClass;

begin
{$IFNDEF ANDROID}
SGPrintEngineVersion();
if (VParams<>nil) and (Length(VParams)>0) then
	ReadParams();
{$ENDIF}

{$IFDEF MSWINDOWS}
if FRenderState = SGBR_DIRECTX_9 then
	RenderClass := TSGRenderDirectX9
else if FRenderState = SGBR_DIRECTX_8 then
	RenderClass := TSGRenderDirectX8
else
{$ENDIF}
	RenderClass := TSGRenderOpenGL;

SGRunPaintable(
	VPaintabeClass
	,TSGCompatibleContext
	,RenderClass
	{$IFDEF ANDROID},State{$ENDIF}
	,VFullscreen);
end;

type
	TSGAllApplicationsDrawable = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		procedure LoadDeviceResourses();override;
		procedure DeleteDeviceResourses();override;
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

procedure SGConsoleShowAllApplications(const VParams : TSGConcoleCallerParams = nil{$IFDEF ANDROID};const State : PAndroid_App = nil{$ENDIF});
begin
SGConsoleRunPaintable(TSGAllApplicationsDrawable,VParams{$IFDEF ANDROID},State{$ENDIF});
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

var
	ViewerImage:TSGImage = nil;
procedure ViewerDraw(const Context:PSGContext);
begin
Context^.Render.InitMatrixMode(SG_2D);
ViewerImage.DrawImageFromTwoVertex2f(
	SGVertex2fImport(0,0),
	SGVertex2fImport(Context^.Width,Context^.Height));
end;

procedure GoViewer(const FileWay:String);
var
	Context:TSGContext = nil;
begin
if 
(SGGetFileExpansion(FileWay)='PNG') or
(SGGetFileExpansion(FileWay)='JPG') or 
(SGGetFileExpansion(FileWay)='JPEG') or 
(SGGetFileExpansion(FileWay)='BMP') or 
(SGGetFileExpansion(FileWay)='TGA') then
	begin
	ViewerImage:=TSGImage.Create();
	ViewerImage.Way:=FileWay;
	if ViewerImage.Loading() then
		begin
		Context:=TSGCompatibleContext.Create();
		Context.Width:=ViewerImage.Width;
		Context.Height:=ViewerImage.Height;
		Context.Fullscreen:=False;
		//Context.DrawProcedure:=TSGContextProcedure(@ViewerDraw);
		Context.Title:='"'+FileWay+'" - SaGe Image Viewer';
		Context.RenderClass:=TSGCompatibleRender;
		Context.SelfLink:=@Context;
		Context.Initialize();
		ViewerImage.SetContext(Context);
		ViewerImage.ToTexture();
		Context.Run();
		Context.Destroy();
		end
	else
		begin
		WriteLn('Error while loading bit map!');
		end;
	ViewerImage.Destroy();
	end
else
	WriteLn('Unknown expansion "',(SGGetFileExpansion(FileWay)),'"!');
end;

end.
