{$INCLUDE Smooth.inc}

//{$DEFINE GLUT_DEBUG}
{$IFDEF GLUT_DEBUG}
	//{$DEFINE GLUT_PAINT_DEBUG}
	{$ENDIF}

unit SmoothContextGLUT;

interface

uses
	 Classes
	
	,SmoothBase
	,SmoothContext
	,SmoothScreen
	,SmoothBaseClasses
	,SmoothCommonStructs
	,SmoothBaseContextInterface
	,SmoothContextInterface
	,SmoothContextUtils
	
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
	TSContextGLUT = class(TSContext)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		class function ContextName() : TSString; override;
		procedure Initialize(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal);override;
		procedure Run();override;
		procedure Messages();override;
		procedure SwapBuffers();override;
		function GetCursorPosition(): TSPoint2int32;override;
		function GetWindowArea(): TSPoint2int32;override;
		function GetScreenArea(): TSPoint2int32;override;
		procedure Resize();override;
		procedure InitFullscreen(const b:boolean); override;
		class function Supported() : TSBoolean; override;
		procedure Paint();override;
		class function ClassName() : TSString;override;
		procedure Close();override;
			public
		function  GetClientWidth() : TSAreaInt;override;
		function  GetClientHeight() : TSAreaInt;override;
		procedure SetNewContext(const NewContextClass : TSNamedClass);override;
			protected
		function InitRender() : TSBoolean;
			protected
		FCursorMoution: TSPoint2int32;
		FFreeGLUTSupported : TSBool;
			public
		procedure SetGLUTMoution(const VX, VY : TSInt32);
		end;

implementation

uses
	 SmoothRenderOpenGL
	,SmoothContextClasses
	,SmoothRender
	,SmoothDllManager
	,SmoothStringUtils
	,SmoothLog
	,SmoothBaseUtils
	,SmoothRenderBase
	;

var
	ContextGLUT : TSContextGLUT = nil;

procedure TSContextGLUT.SetNewContext(const NewContextClass : TSNamedClass);
begin
inherited;
{$IFDEF GLUT_DEBUG}SHint([ClassName(), '__SetNewContext(', FNewContextType.ClassName(), ').']);{$ENDIF}
if (not (Self is FNewContextType)) and  FFreeGLUTSupported and (glutLeaveMainLoop <> nil) then
	glutLeaveMainLoop();
end;

procedure TSContextGLUT.Close();
begin
inherited;
if FFreeGLUTSupported and (glutLeaveMainLoop <> nil) then
	glutLeaveMainLoop();
end;

class function TSContextGLUT.ContextName() : TSString;
begin
Result := Iff(DllManager.Supported('FreeGLUT'), 'Free') + 'GLUT';
end;

class function TSContextGLUT.ClassName() : TSString;
begin
Result := 'TSContext' + ContextName();
end;

procedure TSContextGLUT.SetGLUTMoution(const VX, VY : TSInt32);
begin
FCursorMoution.Import(VX, VY);
end;

class function TSContextGLUT.Supported() : TSBoolean;
begin
Result := DllManager.Supported('glut');
end;

function  TSContextGLUT.GetClientWidth() : TSAreaInt;
begin
Result := FWidth;
end;

function  TSContextGLUT.GetClientHeight() : TSAreaInt;
begin
Result := FHeight;
end;

procedure TSContextGLUT.InitFullscreen(const b:boolean);
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
{$IFDEF GLUT_DEBUG}SHint('GLUT:DrawGLScreen()');{$ENDIF}
ContextGLUT.Paint();
end;

procedure GLUTIdle(); cdecl;
begin
{$IFDEF GLUT_DEBUG}SHint('GLUT:Idle()');{$ENDIF}
glutPostWindowRedisplay(glutGetWindow());
end;

procedure GLUTVisible(vis:integer); cdecl;
begin
{$IFDEF GLUT_DEBUG}SHint('GLUT:Visible(Visible='+SStr(vis)+')');{$ENDIF}
glutIdleFunc(@GLUTIdle);
end;

procedure GLUTReSizeScreen(Width, Height: Integer); cdecl;
begin
{$IFDEF GLUT_DEBUG}SHint('GLUT:ReSizeScreen(Width='+SStr(Width)+',Height='+SStr(Height)+')');{$ENDIF}
if Height = 0 then
	Height := 1;
ContextGLUT.Width  := Width;
ContextGLUT.Height := Height;
ContextGLUT.Resize();
end;

procedure GLUTKeyboard(Key: byte{glint}; X, Y: Longint); cdecl;
begin
{$IFDEF GLUT_DEBUG}SHint('GLUT:ReSizeScreen(Key='+SStr(Key)+',X='+SStr(X)+',Y='+SStr(Y)+'), Char(Key)="'+Char(Key)+'"');{$ENDIF}
ContextGLUT.SetGLUTMoution(X, Y);
ContextGLUT.SetKey(SDownKey, Key);
end;

procedure GLUTMouse(Button:integer; State:integer; x,y:integer);cdecl;
var
	ContextButton : TSCursorButton;
	ContextButtonType : TSCursorButtonType;
	ContextButtonUnknown : TSBoolean = False;
begin
{$IFDEF GLUT_DEBUG}SHint(['GLUT:Mouse(',Button,',',State,',',x,',',y,')']);{$ENDIF}
ContextGLUT.SetGLUTMoution(X, Y);
case Button of
GLUT_LEFT_BUTTON:
	ContextButton := SLeftCursorButton;
GLUT_RIGHT_BUTTON:
	ContextButton := SRightCursorButton;
GLUT_MIDDLE_BUTTON:
	ContextButton := SMiddleCursorButton;
else
	ContextButtonUnknown := True;
end;
if State = 0 then
	ContextButtonType := SDownKey
else
	ContextButtonType := SUpKey;
if not ContextButtonUnknown then
	ContextGLUT.SetCursorKey(ContextButtonType, ContextButton);
end;

procedure GLUTMotionPassive(x,y:longint);cdecl;
begin
{$IFDEF GLUT_DEBUG}SHint(['GLUT:MotionPassive(',x,',',y,')']);{$ENDIF}
ContextGLUT.SetGLUTMoution(X, Y);
end;

procedure GLUTMotion(x,y:longint);cdecl;
begin
{$IFDEF GLUT_DEBUG}SHint(['GLUT:Motion(',x,',',y,')']);{$ENDIF}
ContextGLUT.SetGLUTMoution(X, Y);
end;

procedure GLUTWindowStatus(Status:integer); cdecl;
begin
{$IFDEF GLUT_DEBUG}SHint('GLUT:WindowStatus(Status='+SStr(Status)+')');{$ENDIF}
end;

procedure FreeGLUTWheel(Wheel, Direction, X, Y: Integer); cdecl;
begin
{$IFDEF GLUT_DEBUG}SHint(['GLUT:WindowStatus(',Wheel, ',', Direction, ',', X, ',', Y,')']);{$ENDIF}
if Direction = -1 then
	ContextGLUT.SetCursorWheel(SDownCursorWheel)
else if Direction = 1 then
	ContextGLUT.SetCursorWheel(SUpCursorWheel);
ContextGLUT.SetGLUTMoution(X, Y);
end;

procedure TSContextGLUT.Initialize(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal);
begin
if ContextGLUT <> nil then
	begin
	SLog.Source([ClassName(), '__InitRender() : Finded other GLUT context, destroyed!']);
	ContextGLUT.Destroy();
	ContextGLUT := nil;
	end;

ContextGLUT := Self;

glutInitDisplayMode(GLUT_DOUBLE or GLUT_RGB or GLUT_DEPTH);

if Fullscreen then
	begin
	glutGameModeString(SStringToPChar(SStr(Width)+'x'+SStr(Height)+':32@60'));
	glutEnterGameMode();
	end
else
	begin
	glutInitWindowSize(Width, Height);
	glutInitWindowPosition((GetScreenArea.x - Width) div 2, (GetScreenArea.y - Height) div 2);
	glutCreateWindow(SStringToPChar(FTitle));
	end;

glutSetCursor(GLUT_CURSOR_LEFT_ARROW);

glutDisplayFunc(@GLUTDrawGLScreen);
glutVisibilityFunc(@GLUTVisible);
glutReshapeFunc(@GLUTReSizeScreen);
glutKeyboardFunc(@GLUTKeyboard);
glutMouseFunc(@GLUTMouse);
glutMotionFunc(@GLUTMotion);
glutPassiveMotionFunc(@GLUTMotionPassive);
if FFreeGLUTSupported then
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

procedure TSContextGLUT.Resize();
begin
inherited;
end;

constructor TSContextGLUT.Create();
begin
inherited Create();
FCursorMoution.Import();
glutInitPascal(False);
FFreeGLUTSupported := DllManager.Supported('FreeGLUT');
end;

destructor TSContextGLUT.Destroy();
begin
if glutGetWindow() <> 0 then
	glutDestroyWindow(glutGetWindow());
ContextGLUT := nil;
inherited;
end;

function TSContextGLUT.InitRender() : TSBoolean;

function TestRender() : TSBool;
var
	TempRender : TSRender = nil;
begin
TempRender := FRenderClass.Create();
Result := TempRender is TSRenderOpenGL;
TempRender.Destroy();
TempRender := nil;
end;

begin
if (FRenderClass = nil) then
	FRenderClass := TSRenderOpenGL
else if not TestRender() then
	begin
	SLog.Source([ClassName(), '__InitRender() : GLUT can work only with OpenGL! Render replaced from "', FRenderClass.ClassName(), '"!']);
	FRenderClass := TSRenderOpenGL;
	end;

if FRender = nil then
	begin
	{$IFDEF GLUT_DEBUG}
		SLog.Source([ClassName(), '__InitRender() : Creating render...']);
		{$ENDIF}
	FRender := FRenderClass.Create();
	FRender.Context := Self as ISContext;
	FRender.Init();
	Result := FRender <> nil;
	{$IFDEF GLUT_DEBUG}
		SLog.Source([ClassName(), '__InitRender() : Created render (Render='+SAddrStr(FRender)+').']);
		{$ENDIF}
	end
else
	begin
	if not (FRender is TSRenderOpenGL) then
		begin
		SLog.Source([ClassName(), '__InitRender() : GLUT can work only with OpenGL! Render recreated from "', FRender.ClassName(), '"!']);
		FRenderClass := TSRenderOpenGL;
		KillRender();
		Result := InitRender();
		end;

	{$IFDEF GLUT_DEBUG}
		SLog.Source([ClassName(), '__InitRender() : Formating render (Render='+SAddrStr(FRender)+')']);
		{$ENDIF}
	FRender.Context := Self as ISContext;
	Result := FRender.MakeCurrent();
	end;
end;

procedure TSContextGLUT.Paint();
begin
{$IFDEF GLUT_PAINT_DEBUG}
	SHint([ClassName(), '__Paint() : Begining, Before "UpdateTimer();"']);
{$ELSE GLUT_PAINT_DEBUG}
{$IFDEF GLUT_DEBUG}
	SHint([ClassName(), '__Paint().']);
{$ENDIF GLUT_DEBUG}
{$ENDIF GLUT_PAINT_DEBUG}
Screen.UpDateScreen();
UpdateTimer();
{$IFDEF GLUT_PAINT_DEBUG}
	SHint([ClassName(), 'Paint() : Before "Render.Clear(...);"']);
	{$ENDIF}
Render.Clear(SR_COLOR_BUFFER_BIT OR SR_DEPTH_BUFFER_BIT);
if FPaintable <> nil then
	begin
	{$IFDEF GLUT_PAINT_DEBUG}
		SHint([ClassName(), '__Paint() : Before "Render.InitMatrixMode(S_3D);" & "FPaintable.Paint();"']);
		{$ENDIF}
	Render.InitMatrixMode(S_3D);
	FPaintable.Paint();
	end;
{$IFDEF GLUT_PAINT_DEBUG}
	SHint([ClassName(), 'Paint() : Before "ClearKeys();" & "Messages();"']);
	{$ENDIF}
{$IFDEF GLUT_PAINT_DEBUG}
	SHint([ClassName(), 'Paint() : Before "SScreen.Paint();"']);
	{$ENDIF}
Screen.CustomPaint();
{$IFDEF GLUT_PAINT_DEBUG}
	SHint([ClassName(), 'Paint() : Before "SwapBuffers();"']);
	{$ENDIF}
SwapBuffers();
{$IFDEF GLUT_PAINT_DEBUG}
	SHint([ClassName(), 'Paint() : End.']);
	{$ENDIF}
if FPaintWithHandlingMessages then
	begin
	ClearKeys();
	Messages();
	end;
end;

procedure TSContextGLUT.Run();
begin
StartComputeTimer();
while Active and (FNewContextType = nil) do
	begin
	glutMainLoop();
	if glutSetOption <> nil then
		FActive := False;
	end;
end;

procedure TSContextGLUT.Messages();
begin
inherited;
end;

procedure TSContextGLUT.SwapBuffers();
begin
glutSwapBuffers();
end;

function TSContextGLUT.GetCursorPosition(): TSPoint2int32;
begin
Result := FCursorMoution;
end;

function TSContextGLUT.GetWindowArea(): TSPoint2int32;
begin
Result.Import(
	glutGet(GLUT_WINDOW_X),
	glutGet(GLUT_WINDOW_Y));
end;

function TSContextGLUT.GetScreenArea(): TSPoint2int32;
begin
Result.Import(
	glutGet(GLUT_SCREEN_WIDTH),
	glutGet(GLUT_SCREEN_HEIGHT));
end;

end.
