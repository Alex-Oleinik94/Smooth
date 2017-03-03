{$INCLUDE SaGe.inc}

//{$DEFINE GLUT_DEBUG}
{$IFDEF GLUT_DEBUG}
	//{$DEFINE GLUT_PAINT_DEBUG}
	{$ENDIF}

unit SaGeContextGLUT;

interface

uses
	 Classes
	
	,SaGeBase
	,SaGeContext
	,SaGeScreen
	,SaGeClasses
	,SaGeCommonStructs
	
	{$IFNDEF MOBILE}
		,dglOpenGL
	{$ELSE}
		,gles
		,gles11
		,gles20
		{$ENDIF}
	,glut
	,FreeGlut
	;

type
	TSGContextGLUT = class(TSGContext)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		procedure Initialize();override;
		procedure Run();override;
		procedure Messages();override;
		procedure SwapBuffers();override;
		function GetCursorPosition(): TSGPoint2int32;override;
		function GetWindowArea(): TSGPoint2int32;override;
		function GetScreenArea(): TSGPoint2int32;override;
		procedure Resize();override;
		procedure InitFullscreen(const b:boolean); override;
		class function Suppored() : TSGBoolean; override;
		procedure Paint();override;
		class function ClassName() : TSGString;override;
		procedure Close();override;
			public
		function  GetClientWidth() : TSGAreaInt;override;
		function  GetClientHeight() : TSGAreaInt;override;
		procedure SetNewContext(const NewContextClass : TSGPointer);override;
			protected
		function InitRender() : TSGBoolean;
			protected
		FCursorMoution: TSGPoint2int32;
		FFreeGLUTSuppored : TSGBool;
			public
		procedure SetGLUTMoution(const VX, VY : TSGInt32);
		end;

implementation

uses
	 SaGeRenderOpenGL
	,SaGeCommonClasses
	,SaGeRender
	,SaGeDllManager
	,SaGeStringUtils
	,SaGeLog
	,SaGeBaseUtils
	,SaGeRenderBase
	;

var
	ContextGLUT : TSGContextGLUT = nil;

procedure TSGContextGLUT.SetNewContext(const NewContextClass : TSGPointer);
begin
inherited;
{$IFDEF GLUT_DEBUG}SGHint([ClassName(), '__SetNewContext(', FNewContextType.ClassName(), ').']);{$ENDIF}
if (not (Self is FNewContextType)) and  FFreeGLUTSuppored and (glutLeaveMainLoop <> nil) then
	glutLeaveMainLoop();
end;

procedure TSGContextGLUT.Close();
begin
inherited;
if FFreeGLUTSuppored and (glutLeaveMainLoop <> nil) then
	glutLeaveMainLoop();
end;

class function TSGContextGLUT.ClassName() : TSGString;
begin
Result := 'TSGContext' + Iff(DllManager.Suppored('FreeGLUT'), 'Free') + 'GLUT';
end;

procedure TSGContextGLUT.SetGLUTMoution(const VX, VY : TSGInt32);
begin
FCursorMoution.Import(VX, VY);
end;

class function TSGContextGLUT.Suppored() : TSGBoolean;
begin
Result := DllManager.Suppored('glut');
end;

function  TSGContextGLUT.GetClientWidth() : TSGAreaInt;
begin
Result := FWidth;
end;

function  TSGContextGLUT.GetClientHeight() : TSGAreaInt;
begin
Result := FHeight;
end;

procedure TSGContextGLUT.InitFullscreen(const b:boolean);
begin
if FInitialized then
	if FFullscreen <> b then
		begin
		if b then
			glutFullScreen()
		else
			begin
			glutReshapeWindow(Width, Height);
			if glutPositionWindow <> nil then
				glutPositionWindow(0, 0);
			end;
		end;
inherited;
end;

procedure glutInitPascal(ParseCmdLine: Boolean);
var
	Cmd: array of PChar;
	CmdCount, I: Integer;
begin
if ParseCmdLine then
	CmdCount := ParamCount + 1
else
	CmdCount := 1;
SetLength(Cmd, CmdCount);
for I := 0 to CmdCount - 1 do
	Cmd[I] := PChar(ParamStr(I));
glutInit(@CmdCount, @Cmd);
end;

procedure GLUTDrawGLScreen(); cdecl;
begin
{$IFDEF GLUT_DEBUG}SGHint('GLUT:DrawGLScreen()');{$ENDIF}
ContextGLUT.Paint();
end;

procedure GLUTIdle(); cdecl;
begin
{$IFDEF GLUT_DEBUG}SGHint('GLUT:Idle()');{$ENDIF}
glutPostWindowRedisplay(glutGetWindow());
end;

procedure GLUTVisible(vis:integer); cdecl;
begin
{$IFDEF GLUT_DEBUG}SGHint('GLUT:Visible(Visible='+SGStr(vis)+')');{$ENDIF}
glutIdleFunc(@GLUTIdle);
end;

procedure GLUTReSizeScreen(Width, Height: Integer); cdecl;
begin
{$IFDEF GLUT_DEBUG}SGHint('GLUT:ReSizeScreen(Width='+SGStr(Width)+',Height='+SGStr(Height)+')');{$ENDIF}
if Height = 0 then
	Height := 1;
ContextGLUT.Width  := Width;
ContextGLUT.Height := Height;
ContextGLUT.Resize();
end;

procedure GLUTKeyboard(Key: byte{glint}; X, Y: Longint); cdecl;
begin
{$IFDEF GLUT_DEBUG}SGHint('GLUT:ReSizeScreen(Key='+SGStr(Key)+',X='+SGStr(X)+',Y='+SGStr(Y)+'), Char(Key)="'+Char(Key)+'"');{$ENDIF}
ContextGLUT.SetGLUTMoution(X, Y);
ContextGLUT.SetKey(SGDownKey, Key);
end;

procedure GLUTMouse(Button:integer; State:integer; x,y:integer);cdecl;
var
	ContextButton : TSGCursorButtons;
	ContextButtonType : TSGCursorButtonType;
	ContextButtonUnknown : TSGBoolean = False;
begin
{$IFDEF GLUT_DEBUG}SGHint(['GLUT:Mouse(',Button,',',State,',',x,',',y,')']);{$ENDIF}
ContextGLUT.SetGLUTMoution(X, Y);
case Button of
GLUT_LEFT_BUTTON:
	ContextButton := SGLeftCursorButton;
GLUT_RIGHT_BUTTON:
	ContextButton := SGRightCursorButton;
GLUT_MIDDLE_BUTTON:
	ContextButton := SGMiddleCursorButton;
else
	ContextButtonUnknown := True;
end;
if State = 0 then
	ContextButtonType := SGDownKey
else
	ContextButtonType := SGUpKey;
if not ContextButtonUnknown then
	ContextGLUT.SetCursorKey(ContextButtonType, ContextButton);
end;

procedure GLUTMotionPassive(x,y:longint);cdecl;
begin
{$IFDEF GLUT_DEBUG}SGHint(['GLUT:MotionPassive(',x,',',y,')']);{$ENDIF}
ContextGLUT.SetGLUTMoution(X, Y);
end;

procedure GLUTMotion(x,y:longint);cdecl;
begin
{$IFDEF GLUT_DEBUG}SGHint(['GLUT:Motion(',x,',',y,')']);{$ENDIF}
ContextGLUT.SetGLUTMoution(X, Y);
end;

procedure GLUTWindowStatus(Status:integer); cdecl;
begin
{$IFDEF GLUT_DEBUG}SGHint('GLUT:WindowStatus(Status='+SGStr(Status)+')');{$ENDIF}
end;

procedure FreeGLUTWheel(Wheel, Direction, X, Y: Integer); cdecl;
begin
{$IFDEF GLUT_DEBUG}SGHint(['GLUT:WindowStatus(',Wheel, ',', Direction, ',', X, ',', Y,')']);{$ENDIF}
if Direction = -1 then
	ContextGLUT.SetCursorWheel(SGDownCursorWheel)
else if Direction = 1 then
	ContextGLUT.SetCursorWheel(SGUpCursorWheel);
ContextGLUT.SetGLUTMoution(X, Y);
end;

procedure TSGContextGLUT.Initialize();
begin
if ContextGLUT <> nil then
	begin
	SGLog.Source([ClassName(), '__InitRender() : Finded other GLUT context, destroyed!']);
	ContextGLUT.Destroy();
	ContextGLUT := nil;
	end;

ContextGLUT := Self;

glutInitDisplayMode(GLUT_DOUBLE or GLUT_RGB or GLUT_DEPTH);

if Fullscreen then
	begin
	glutGameModeString(SGStringToPChar(SGStr(Width)+'x'+SGStr(Height)+':32@60'));
	glutEnterGameMode();
	end
else
	begin
	glutInitWindowSize(Width, Height);
	glutInitWindowPosition((GetScreenArea.x - Width) div 2, (GetScreenArea.y - Height) div 2);
	glutCreateWindow(SGStringToPChar(FTitle));
	end;

glutSetCursor(GLUT_CURSOR_LEFT_ARROW);

glutDisplayFunc(@GLUTDrawGLScreen);
glutVisibilityFunc(@GLUTVisible);
glutReshapeFunc(@GLUTReSizeScreen);
glutKeyboardFunc(@GLUTKeyboard);
glutMouseFunc(@GLUTMouse);
glutMotionFunc(@GLUTMotion);
glutPassiveMotionFunc(@GLUTMotionPassive);
if FFreeGLUTSuppored then
	begin
	if glutMouseWheelFunc <> nil then
		glutMouseWheelFunc(@FreeGLUTWheel);
	if glutSetOption <> nil then
		glutSetOption(GLUT_ACTION_ON_WINDOW_CLOSE, GLUT_ACTION_CONTINUE_EXECUTION);
	end;

//glutSetIconTitle(PChar(5));
//glutWindowStatusFunc(@GLUTWindowStatus);

Active := InitRender();
if Active then
	inherited;
end;

procedure TSGContextGLUT.Resize();
begin
inherited;
end;

constructor TSGContextGLUT.Create();
begin
inherited Create();
FCursorMoution.Import();
glutInitPascal(False);
FFreeGLUTSuppored := DllManager.Suppored('FreeGLUT');
end;

destructor TSGContextGLUT.Destroy();
begin
if glutGetWindow() <> 0 then
	glutDestroyWindow(glutGetWindow());
ContextGLUT := nil;
inherited;
end;

function TSGContextGLUT.InitRender() : TSGBoolean;

function TestRender() : TSGBool;
var
	TempRender : TSGRender = nil;
begin
TempRender := FRenderClass.Create();
Result := TempRender is TSGRenderOpenGL;
TempRender.Destroy();
TempRender := nil;
end;

begin
if (FRenderClass = nil) then
	FRenderClass := TSGRenderOpenGL
else if not TestRender() then
	begin
	SGLog.Source([ClassName(), '__InitRender() : GLUT can work only with OpenGL! Render replaced from "', FRenderClass.ClassName(), '"!']);
	FRenderClass := TSGRenderOpenGL;
	end;

if FRender = nil then
	begin
	{$IFDEF GLUT_DEBUG}
		SGLog.Source([ClassName(), '__InitRender() : Creating render...']);
		{$ENDIF}
	FRender := FRenderClass.Create();
	FRender.Context := Self as ISGContext;
	FRender.Init();
	Result := FRender <> nil;
	{$IFDEF GLUT_DEBUG}
		SGLog.Source([ClassName(), '__InitRender() : Created render (Render='+SGAddrStr(FRender)+').']);
		{$ENDIF}
	end
else
	begin
	if not (FRender is TSGRenderOpenGL) then
		begin
		SGLog.Source([ClassName(), '__InitRender() : GLUT can work only with OpenGL! Render recreated from "', FRender.ClassName(), '"!']);
		FRenderClass := TSGRenderOpenGL;
		KillRender();
		Result := InitRender();
		end;

	{$IFDEF GLUT_DEBUG}
		SGLog.Source([ClassName(), '__InitRender() : Formating render (Render='+SGAddrStr(FRender)+')']);
		{$ENDIF}
	FRender.Context := Self as ISGContext;
	Result := FRender.MakeCurrent();
	end;
end;

procedure TSGContextGLUT.Paint();
var
	SCR : TSGBool;
begin
{$IFDEF GLUT_PAINT_DEBUG}
	SGHint([ClassName(), '__Paint() : Begining, Before "UpdateTimer();"']);
{$ELSE GLUT_PAINT_DEBUG}
{$IFDEF GLUT_DEBUG}
	SGHint([ClassName(), '__Paint().']);
{$ENDIF GLUT_DEBUG}
{$ENDIF GLUT_PAINT_DEBUG}
SCR := Screen.UpDateScreen();
UpdateTimer();
{$IFDEF GLUT_PAINT_DEBUG}
	SGHint([ClassName(), 'Paint() : Before "Render.Clear(...);"']);
	{$ENDIF}
Render.Clear(SGR_COLOR_BUFFER_BIT OR SGR_DEPTH_BUFFER_BIT);
if FPaintable <> nil then
	begin
	{$IFDEF GLUT_PAINT_DEBUG}
		SGHint([ClassName(), '__Paint() : Before "Render.InitMatrixMode(SG_3D);" & "FPaintable.Paint();"']);
		{$ENDIF}
	Render.InitMatrixMode(SG_3D);
	FPaintable.Paint();
	end;
{$IFDEF GLUT_PAINT_DEBUG}
	SGHint([ClassName(), 'Paint() : Before "ClearKeys();" & "Messages();"']);
	{$ENDIF}
{$IFDEF GLUT_PAINT_DEBUG}
	SGHint([ClassName(), 'Paint() : Before "SGScreen.Paint();"']);
	{$ENDIF}
Screen.CustomPaint(SCR);
{$IFDEF GLUT_PAINT_DEBUG}
	SGHint([ClassName(), 'Paint() : Before "SwapBuffers();"']);
	{$ENDIF}
SwapBuffers();
{$IFDEF GLUT_PAINT_DEBUG}
	SGHint([ClassName(), 'Paint() : End.']);
	{$ENDIF}
if FPaintWithHandlingMessages then
	begin
	ClearKeys();
	Messages();
	end;
end;

procedure TSGContextGLUT.Run();
begin
StartComputeTimer();
while Active and (FNewContextType = nil) do
	begin
	glutMainLoop();
	if glutSetOption <> nil then
		FActive := False;
	end;
end;

procedure TSGContextGLUT.Messages();
begin
inherited;
end;

procedure TSGContextGLUT.SwapBuffers();
begin
glutSwapBuffers();
end;

function TSGContextGLUT.GetCursorPosition(): TSGPoint2int32;
begin
Result := FCursorMoution;
end;

function TSGContextGLUT.GetWindowArea(): TSGPoint2int32;
begin
Result.Import(
	glutGet(GLUT_WINDOW_X),
	glutGet(GLUT_WINDOW_Y));
end;

function TSGContextGLUT.GetScreenArea(): TSGPoint2int32;
begin
Result.Import(
	glutGet(GLUT_SCREEN_WIDTH),
	glutGet(GLUT_SCREEN_HEIGHT));
end;

end.
