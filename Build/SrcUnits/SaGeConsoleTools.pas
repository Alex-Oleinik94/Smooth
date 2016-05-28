{$INCLUDE Includes\SaGe.inc}

unit SaGeConsoleTools;

interface

uses 
	(* ============ System Includes ============ *)
	 dos
	,crt
	,process
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
		,jni
		,android_native_app_glue
		{$ENDIF}
	
	(* ============ Engine Includes ============ *)
	{$IFDEF MSWINDOWS}
		,SaGeRenderDirectX
		,SaGeContextWinAPI
		{$ENDIF}
	{$IFDEF LINUX}
		,SaGeContextLinux
		{$ENDIF}
	{$IFDEF DARWIN}
		,SaGeContextMacOSX
		{$ENDIF}
	{$IFDEF ANDROID}
		,SaGeContextAndroid
		{$ENDIF}
	,SaGeRender
	,SaGeRenderOpenGL
	,SaGeCommon
	,SaGeImagesBase
	,SaGeContext
	,SaGeImages
	,SaGeBase
	,SaGeBased
	,SaGeMath
	,SaGeExamples
	,SaGeTotal
	,SaGeFractals
	,SaGeUtils
	,SaGeModel
	,SaGeMesh
	,SaGeShaders
	,SaGeNet
	,SaGeResourseManager
	,SaGeVersion
	
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
	,Ex15
	;

type
	TSGConcoleCallerParams = TSGArString;
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

procedure ConcoleCaller(const VParams : TSGConcoleCallerParams);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure StandartCallConcoleCaller();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SystemParamsToConcoleCallerParams() : TSGConcoleCallerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure FPCTCTransliater();
procedure GoogleReNameCache();
procedure GoViewer(const FileWay : String);
procedure DllScan();
procedure ImageResizer();


procedure SGConcoleCaller(const VParams : TSGConcoleCallerParams);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGDecConsoleParam(const Params : TSGConcoleCallerParams) : TSGConcoleCallerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGConsoleConvertImageToSaGeImageAlphaFormat(const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleShowAllApplications(const VParams : TSGConcoleCallerParams = nil{$IFDEF ANDROID};const State : PAndroid_App = nil{$ENDIF});

implementation

procedure InitAllApplications(const Context:TSGContext);
begin
with TSGDrawClasses.Create(Context) do
	begin
	Add(TSGExample15);
	Add(TSGGasDiffusion);
	Add(TSGAllFractals,False);
	Add(TSGAllExamples,False);
	Add(TSGLoading);
	Add(TSGGraphViewer);
	Add(TSGKillKostia);
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

procedure SGConcoleCaller(const VParams : TSGConcoleCallerParams);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	ConsoleCaller : TSGConsoleCaller = nil;
begin
ConsoleCaller := TSGConsoleCaller.Create(VParams);
ConsoleCaller.AddComand(@SGConsoleConvertImageToSaGeImageAlphaFormat, ['CTSGIA'], 'Convert image To SaGeImagesAlpha format');
ConsoleCaller.AddComand(@SGConsoleShowAllApplications, ['GUI',''], 'Shows all scenes in this application');
ConsoleCaller.Execute();
ConsoleCaller.Destroy();
end;

function SGDecConsoleParam(const Params : TSGConcoleCallerParams) : TSGConcoleCallerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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
	SGConvertToSGIA(VParams[1],VParams[2])
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
		TextColor(12);
		Write('Unknown simbol "');
		TextColor(15);
		Write(FParams[0]);
		TextColor(12);
		WriteLn('", use "--help"');
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
	WriteLn('Try to open file(-s):');
	for i := 0 to High(FParams) do
		WriteLn('   ',FParams[i]);
	ReadLn();
	end
else
	begin
	Comand := ComandCheck();
	if (Comand = 'HELP') or (Comand = 'H') then
		begin
		if (FComands <> nil) and (Length(FComands)>0) then
			begin
			SGPrintEngineVersion();
			WriteLn('Help:');
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
						TextColor(12);
						Write('Abstrac comand "');
						TextColor(15);
						Write(Comand);
						TextColor(12);
						WriteLn('"!');
						TextColor(7);
						iii := 0;
						end
					else
						begin
						Params := SGDecConsoleParam(FParams);
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
			WriteLn('Unknown comand "',Comand,'"!');
			end;
		end;
	end;
end;

function SystemParamsToConcoleCallerParams() : TSGConcoleCallerParams;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
SetLength(Result, argc - 1);
if Length(Result) > 0 then
	for i := 0 to High(Result) do
		Result[i] := SGPCharToString(argv[i+1]);
end;

procedure StandartCallConcoleCaller();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Params : TSGConcoleCallerParams;
begin
Params := SystemParamsToConcoleCallerParams();
ConcoleCaller(Params);
SetLength(Params,0);
end;

procedure ConcoleCaller(const VParams : TSGConcoleCallerParams);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	S : TSGString;
	Params : TSGConcoleCallerParams;
	i : TSGLongWord;
begin
if (Length(VParams)=1) and (SGFileExists(VParams[0])) and 
	(	(SGGetFileExpansion(VParams[0])='PNG') or 
		(SGGetFileExpansion(VParams[0])='JPG') or 
		(SGGetFileExpansion(VParams[0])='JPEG')) then
	begin
	GoViewer(VParams[0]);
	end
else if Length(VParams)>0 then
	begin
	S := SGUpCaseString(VParams[0]);
	if S[1]='-' then
		begin
		S := SGGetComand(S);
		if s='CTSGIA' then
			begin
			if (SGUpCaseString(VParams[1])='-H') or (SGUpCaseString(VParams[1])='-HELP') then
				begin
				WriteLn('Convert To SaGe Images Alpha format.');
				WriteLn('Use "-CTSGIA P1 P2".');
				WriteLn('    P1 is way to input file, for example "/images/qwerty/asdfgh.png".');
				WriteLn('    P2 is way to output file, for example "/images/qwerty/asdfgh.sgia".');
				end
			else
				SGConvertToSGIA(VParams[1],VParams[2]);
			end
		else if S = 'SRW' then
			begin
			SetLength(Params,Length(VParams)-3);
			if Length(Params)>0 then
				for i := 3 to High(VParams) do
					Params[i-3] := VParams[i];
			SGSaveShaderSourseToFile(VParams[2],
				SGReadShaderSourseFromFile(VParams[1],Params));
			SetLength(Params,0);
			end
		else if s='CRF' then
			begin
			SGClearRFFile(VParams[1]);
			end
		else if s='CFTPUARU' then
			begin
			SGConvertFileToPascalUnit(VParams[1],VParams[2],VParams[3],True);
			SGRegisterUnit(VParams[3],VParams[4]);
			end
		else if s='CDTPUARU' then
			begin
			SGConvertDirectoryFilesToPascalUnits(VParams[1],VParams[2],VParams[3]);
			end
		else if s='EF' then
			begin
			SGResourseFiles.ExtractFiles(VParams[1],(SGUpCaseString(VParams[2]) = 'TRUE') or (VParams[2] = '1'));
			end
		else if s='CFTPU' then
			begin
			if (SGUpCaseString(VParams[1])='-H') or (SGUpCaseString(VParams[1])='-HELP') then
				begin
				WriteLn('Convert File To Pascal Unit help');
				WriteLn('   Use: "-CFTPU P1 P2 P3 P4"');
				WriteLn('   P1 is way to input file');
				WriteLn('   P2 is way to output file directory');
				WriteLn('   P3 is name of pascal unit');
				WriteLn('   P4 is FALSE or TRUE');
				end
			else
				begin
				SGConvertFileToPascalUnit(VParams[1],VParams[2],VParams[3],SGUpCaseString(VParams[4])<>'FALSE');
				end;
			end
		else if S = 'IV' then
			begin
			SGIncEngineVersion(VParams[1]='1');
			end
		else if s='ATL' then
			begin
			AddToLog(VParams[1],VParams[2]);
			end
		else if s='FPCTC' then
			begin
			{$IFNDEF RELEASE}
				WriteLn('FPC To C transliater.');
				{$ENDIF}
			FPCTCTransliater();
			end
		else if s='FIP' then
			begin
			{$IFNDEF RELEASE}
				WriteLn('Find In Pas');
				{$ENDIF}
			FindInPas(True);
			end
		else if s='IPSERVER' then
			begin
			IPSERVER();
			end
		else if s='IR' then
			ImageResizer()
		else if s='GUI' then
			begin
			Params := SGDecConsoleParam(VParams);
			SGConsoleShowAllApplications(Params);
			SetLength(Params,0);
			end
		else if s='ATRD' then
			begin
			SGAttachToMyRemoteDesktop();
			end
		else if s = 'BUILD' then
			begin
			WriteLn('Building SaGe...');
			SGRunComand('cmd /c "cd ./../Build & FPC_Make_Debug.bat"');
			end
		else
			begin
			WriteLn('Unknown command "', S, '".');
			WriteLn('Use "-help" for help!');
			end;
		end
	else
		begin
		WriteLn('Error syntax command string "', S, '". Before comand must be simbol "-".');
		WriteLn('Use "-help" for help!');
		end;
	end
else
	SGConsoleShowAllApplications(VParams);
end;

var
	InitBe : TSGByte = 0;

procedure DrawAllApplications(const Context:TSGContext);
begin
case InitBe of
0 : InitBe +=1;
1 :
	begin
	InitAllApplications(Context);
	InitBe += 1;
	end;
end;
end;

procedure SGConsoleShowAllApplications(const VParams : TSGConcoleCallerParams = nil{$IFDEF ANDROID};const State : PAndroid_App = nil{$ENDIF});
var
	Context:TSGContext = nil;
	{$IFDEF MSWINDOWS}
		FRenderState:(SGBR_OPENGL,SGBR_DIRECTX,SGBR_UNKNOWN) = SGBR_OPENGL;
		{$ENDIF}
	VFullscreen:TSGBoolean = {$IFDEF ANDROID}True{$ELSE}False{$ENDIF};

procedure ContextTypeWatcherCallAction();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	NewContext:TSGContext = nil;
begin
if Context.Active and (Context.FNewContextType<>nil) then
	begin
	NewContext:=Context.FNewContextType.Create();
	NewContext.CopyInfo(Context);
	NewContext.FCallInitialize:=nil;
	Pointer(Context.FRender):=nil;
	Context.Destroy();
	Context:=NewContext;
	NewContext:=nil;
	Context.Initialize();
	end;
end;

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
			if (S='HELP') or (S='H') then
				begin
				WriteLn('Whis is help for funning GUI.');
				WriteLn('     -H; -HELP       : for run help');
				{$IFDEF MSWINDOWS}
					WriteLn('     -OPENGL         : for set prioritet render "OpenGL"');
					WriteLn('     -DIRECTX        : for set prioritet render "DirectX"');
					{$ENDIF}
				WriteLn('     -F; -FULLSCREEN : for change fullscreen');
				GoToExit := True;
				HelpUsed := True;
				Break;
				end
			{$IFDEF MSWINDOWS}
				else if (S='OGL') or (S='OPENGL') then
					begin
					{$IFDEF SGMoreDebuging}
						WriteLn('Set prioritet render : "OpenGL"');
						{$ENDIF}
					FRenderState:=SGBR_OPENGL;
					end
				else if (S='D3DX') or (S='DIRECT3D')or (S='DIRECTX')or (S='DIRECT3DX') then
					begin
					{$IFDEF SGMoreDebuging}
						WriteLn('Set prioritet render : "DirectX"');
						{$ENDIF}
					FRenderState:=SGBR_DIRECTX;
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

begin
{$IFNDEF ANDROID}
SGPrintEngineVersion();
if (VParams<>nil) and (Length(VParams)>0) then
	ReadParams();
{$ENDIF}

Context:=
{$IFDEF LAZARUS}
	TSGContextLazarus
{$ELSE}
	{$IFDEF GLUT}
		TSGContextGLUT
	{$ELSE}
		{$IFDEF MSWINDOWS}TSGContextWinAPI {$ENDIF}
		{$IFDEF LINUX}    TSGContextLinux  {$ENDIF}
		{$IFDEF ANDROID}  TSGContextAndroid{$ENDIF}
		{$IFDEF DARWIN}   TSGContextMacOSX {$ENDIF}
		{$ENDIF}
	{$ENDIF}
		.Create();

with Context do
	begin
	Width  := GetScreenResolution.x;
	Height := GetScreenResolution.y;
	Fullscreen:=VFullscreen;
	{$IFDEF ANDROID}
		(Context as TSGContextAndroid).AndroidApp:=State;
		{$ENDIF}
	
	{$IFDEF MSWINDOWS}
		if FRenderState=SGBR_DIRECTX then
			Tittle:='SaGe DirectX Window'
		else
		{$ENDIF}
			Tittle:='SaGe OpenGL Window';
		
	DrawProcedure:=TSGContextProcedure(@DrawAllApplications);
	//InitializeProcedure:=TSGContextProcedure(@InitAllApplications);
	
	IconIdentifier:=5;
	CursorIdentifier:=5;
	
	SelfPoint:=@Context;
	{$IFDEF MSWINDOWS}
		if FRenderState=SGBR_DIRECTX then
			RenderClass:=TSGRenderDirectX
		else
		{$ENDIF}
			RenderClass:=TSGRenderOpenGL;
	end;

Context.Initialize();
repeat
Context.Run();
ContextTypeWatcherCallAction();
until (Context.Active = False);
Context.Destroy();
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
		Context:=
			   {$IFDEF MSWINDOWS} TSGContextWinAPI {$ENDIF}
			   {$IFDEF LINUX}     TSGContextLinux  {$ENDIF}
			   {$IFDEF DARWIN}    TSGContextMacOSX {$ENDIF}
				.Create();
		Context.Width:=ViewerImage.Width;
		Context.Height:=ViewerImage.Height;
		Context.Fullscreen:=False;
		Context.DrawProcedure:=TSGContextProcedure(@ViewerDraw);
		Context.Tittle:='"'+FileWay+'" - SaGe Image Viewer';
		Context.RenderClass:=
				//{$IFDEF MSWINDOWS}TSGRenderDirectX{$ENDIF}
				//{$IFDEF UNIX}     
				TSGRenderOpenGL;// {$ENDIF};
		Context.SelfPoint:=@Context;
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

procedure DllScan();
var
	FailWay:string;
	Lib:TSGLibrary;
	A:array [#0..#255] of Boolean;
	i,iii:TSGMaxEnum;
	S:STring;
	axtung:Boolean;
	Pc:PChar;

procedure RecDll(const Depth:LongWord);
var
	ii:Byte;
begin
for ii:=0 to 129 do
	if  A[char(ii)] then
	begin
	S+=Char(ii);
	if Depth=1 then
		begin
		Pc:=SGStringToPChar(S);
		iii:=0;
		try
		iii:=TSGMaxEnum(SaGeBase.GetProcAddress(Lib,Pc));
		except
		end;
		if iii<>0 then
			WriteLn('Result "',S,'"!!!');
		FreeMem(Pc);
		end
	else
		begin
		RecDll(Depth-1);
		end;
	SetLength(S,Length(S)-1);
	end;
end;

begin
if argc<=2 then
	begin
	Writeln('Enter file please as paramrter!');
	Exit;
	end;
FailWay:=argv[2];
if not SGFileExists(FailWay) then
	begin
	Writeln('File must be exists!');
	Exit;
	end;
Lib:=SaGeBase.LoadLibrary(SGStringToPChar(FailWay));
WriteLn(Lib);
if Lib=0 then
	begin
	Writeln('Load library failed!');
	Exit;
	end;
FillChar(A[char(0)],256,0);
for i:=0 to 255 do
	if char(i) in ['a'..'z','A'..'Z','_','0'..'9'] then
		A[char(i)]:=True;
S:='';
for i:=1 to 255 do
	begin
	Writeln('Scaning ',i,' simbol words..');
	RecDll(i);
	end;
end;

procedure ImageResizer();
var
	Image:TSGImage;
begin
if (argc=5) and SGFileExists(argv[2]) and (SGVal(SGPCharToString(argv[3]))>0)and (SGVal(SGPCharToString(argv[4]))>0)  then
	begin
	Image:=TSGImage.Create();
	Image.Way:=argv[2];
	Image.Loading();
	Image.Image.SetBounds(
		SGVal(SGPCharToString(argv[3])),
		SGVal(SGPCharToString(argv[4])));
	Image.Way:=SGGetFreeFileName(Image.Way);
	Image.Saveing();
	Image.Destroy();
	end
else
	WriteLn('Error in parameters You must enter @filename, @new_width and @new_height!');
end;

end.
