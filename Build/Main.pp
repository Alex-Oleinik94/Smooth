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

procedure _1;
var
	SGT:SGTranslater = nil;
begin
SGT:=SGTranslater.Create('_1.pas');
SGT.GoTranslate;
SGT.Destroy;
end;

begin
{_1;
Exit;}

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

end.
