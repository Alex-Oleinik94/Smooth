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
	,SaGe
	,SaGeBase
	,SaGeFractals
	,SaGeUtils
	,SaGeCL
	,SaGeTotal
	,SaGeMesh
	,SaGeMath
	,SaGeExamples
	,SaGeShaders
	,SaGeFPCToC
	,gl
	,glext
	,SaGeNet
	,SageGeneticalAlgoritm;

procedure Draw;
begin

end;

procedure Init;
begin
SGScreen.Font:=TSGGLFont.Create('.'+Slash+'..'+Slash+'Data'+Slash+'Fonts'+Slash+'Tahoma.bmp');
SGScreen.Font.Loading;

with TSGDrawClasses.Create do
	begin
	
	
	Add(TSGFractalLomanaya);
	Add(TSGFractalPodkova);
	Add(TSGKillKostia);
	Add(TSGFractalKohTriangle);
	Add(TSGFractalMengerSpunchRelease);
	Add(TSGFractalMandelbrodRelease);
	Add(TSGGenAlg);
	Add(TSGGraphic);
	Add(TSGGraphViewer);
	Add(TSGGraphViewer3D);
	
	//Add(TSGMeshViever);
	//Add(TSGExampleShader);
	//Add(TSGSeaBatle);
	//Add(TSGminecraft);
	
	Initialize;
	end;
end;

procedure FPCTCTransliater;
var
	SGT:SGTranslater = nil;
begin
SGT:=SGTranslater.Create('cmd');
SGT.GoTranslate;
SGT.Destroy;
end;

procedure GoGUI;
begin
SGContext:=
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

with SGContext do
	begin
	Width:=GetScreenResolution.x;
	Height:=GetScreenResolution.y;
	Fullscreen:=False;
	Tittle:='SaGe OpenGL Window';
	
	DrawProcedure:=TProcedure(@Draw);
	InitializeProcedure:=TProcedure(@Init);
	
	IconIdentifier:=5;
	CursorIdentifier:=5;
	end;

SGContext.Initialize;

repeat

SGContext.Run;

if SGContext.Active and (SGContext.FNewContextType<>nil) then
	begin
	NewContext:=SGContext.FNewContextType.Create;
	NewContext.CopyInfo(SGContext);
	NewContext.FCallInitialize:=nil;
	SGContext.SetRC(0);
	SGContext.Destroy;
	SGContext:=NewContext;
	NewContext:=nil;
	SGContext.Initialize;
	end;

until (SGContext.Active = False);

SGContext.Destroy;

end;

function GetComand(const comand:string):string;
var
	i:LongWord;
begin
Result:='';
for i:=2 to Length(comand) do
	Result+=comand[i];
Result:=SGUpCaseString(Result);
end;

var
	i:LongWord;
	s:string;

begin
if argc>1 then
	begin
	WriteLn('Entered ',argc-1,' parametrs.');
	s:=SGPCharToString(argv[1]);
	if s[1]='-' then
		begin
		s:=GetComand(s);
		if s='FPCTC' then
			begin
			WriteLn('Beginning FPC to C transliater.');
			FPCTCTransliater;
			end
		else
			WriteLn('Unknown command "',s,'".');
		end
	else
		WriteLn('Trror sintexis command "',s,'". Befor cjmand must be simbol "''".');
	//for i:=0 to argc-1 do WriteLn('"',argv[i],'"');
	end
else
	GoGUI;
end.
