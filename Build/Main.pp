{$I SrcUnits\Includes\SaGe.inc}
//{$APPTYPE CONSOLE}
//{$APPTYPE GUI}
program Main;
uses
	{$IFDEF UNIX}
		{$IFDEF UseCThreads}
			cthreads,
			{$ENDIF}
		{$ENDIF}
	crt
	{$IFDEF MSWINDOWS}
		,windows
		{$ENDIF}
	,dos
	,Classes
	,SysUtils
	,SaGeContext
	,SaGeContextWinAPI
	,SaGeCommon
	,SaGeBase
	,SaGeFractals
	,SaGeUtils
	,SaGeCL
	,SaGeTotal
	,SaGeMesh
	,SaGeMath
	//,SaGeExamples
	//,SaGeShaders
	,SaGeFPCToC
	,gl
	,glext
	,SaGeNet
	,SageGeneticalAlgoritm
	,SaGeRenderOpenGL;

procedure FPCTCTransliater;
var
	SGT:SGTranslater = nil;
begin
SGT:=SGTranslater.Create('cmd');
SGT.GoTranslate;
SGT.Destroy;
end;

procedure Draw(const Context:TSGContext);
begin

end;

procedure Init(const MyContext:TSGContext);
begin
SGScreen.Font:=TSGGLFont.Create('.'+Slash+'..'+Slash+'Data'+Slash+'Fonts'+Slash+'Tahoma.bmp');
SGScreen.Font.Context := MyContext;
SGScreen.Font.Loading;

with TSGDrawClasses.Create(MyContext) do
	begin
	{Add(TSGFractalLomanaya);
	Add(TSGFractalPodkova);
	Add(TSGKillKostia);}
	Add(TSGFractalKohTriangle);
	{Add(TSGFractalMengerSpunchRelease);
	Add(TSGFractalMandelbrodRelease);
	Add(TSGGenAlg);
	Add(TSGGraphic);
	Add(TSGGraphViewer);
	Add(TSGGraphViewer3D);}
	
	//Add(TSGMeshViever);
	//Add(TSGExampleShader);
	//Add(TSGSeaBatle);
	//Add(TSGminecraft);
	
	Initialize;
	end;
end;

procedure GoGUI;
var
	Context:TSGContext = nil;
var
	NewContext:TSGContext;
begin
Context:=
{$IFDEF LAZARUS}
      TSGContextLazarus
{$ELSE}
       {$IFDEF GLUT}
               TSGContextGLUT
       {$ELSE}
		   {$IFDEF MSWINDOWS}TSGContextWinAPI{$ENDIF}
		   {$IFDEF UNIX}     TSGContextGlX   {$ENDIF}
		   {$ENDIF}
       {$ENDIF}
		.Create;

with Context do
	begin
	Width:=GetScreenResolution.x;
	Height:=GetScreenResolution.y;
	Fullscreen:=False;
	Tittle:='SaGe OpenGL Window';
	
	DrawProcedure:=TSGContextProcedure(@Draw);
	InitializeProcedure:=TSGContextProcedure(@Init);
	
	IconIdentifier:=5;
	CursorIdentifier:=5;
	
	Context.RenderClass:=TSGRenderOpenGL;
	Context.Render:=TSGRenderOpenGL.Create;
	end;

Context.Initialize;


repeat

Context.Run;

if Context.Active and (Context.FNewContextType<>nil) then
	begin
	NewContext:=Context.FNewContextType.Create;
	NewContext.CopyInfo(Context);
	NewContext.FCallInitialize:=nil;
	Context.SetRC(0);
	Context.Destroy;
	Context:=NewContext;
	NewContext:=nil;
	Context.Initialize;
	end;

until (Context.Active = False);

Context.Destroy;

end;

procedure GoogleReNameCache;
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
			MoveFile(SGStringToPChar('.'+Slash+Cache+Slash+sr.Name),SGStringToPChar('.'+Slash+Cache+Slash+'Temp'+Slash+sr.Name));
			end
		else
			if razr<>'' then
				MoveFile(SGStringToPChar('.'+Slash+Cache+Slash+sr.Name),SGStringToPChar('.'+Slash+Cache+Slash+'Complited'+Slash+sr.Name+'.'+razr));
		end;
	DOS.findnext(sr);
	end;
DOS.findclose(sr);
end;

var
	//i:LongWord;
	s:string;

begin
if argc>1 then
	begin
	WriteLn('Entered ',argc-1,' parametrs.');
	s:=SGPCharToString(argv[1]);
	if s[1]='-' then
		begin
		s:=SGGetComand(s);
		if s='FPCTC' then
			begin
			WriteLn('Beginning FPC to C transliater.');
			FPCTCTransliater;
			end
		else if s='FIP' then
			begin
			WriteLn('Beginning Find in pas.');
			FindInPas;
			end
		else if s='GRNC' then
			begin
			WriteLn('Beginning Google ReName Cashe.');
			GoogleReNameCache;
			end
		else if (s='H') or (s='HELP') then
			begin
			WriteLn('This is help. You can use:');
			WriteLn('   -FIP: for run "Find in pas" program');
			WriteLn('   -FPCTC: for run "FPC to C converter" program');
			WriteLn('   -GRNC: for run "Google ReName Cashe" program');
			WriteLn('   -H;-HELP: for run help');
			end
		else
			WriteLn('Unknown command "',s,'".');
		end
	else
		WriteLn('Error sintexis command "',s,'". Befor cjmand must be simbol "''".');
	//for i:=0 to argc-1 do WriteLn('"',argv[i],'"');
	end
else
	GoGUI;
end.
