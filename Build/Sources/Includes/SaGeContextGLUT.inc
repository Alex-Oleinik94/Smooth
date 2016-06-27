{$IFDEF SGREADINTERFACE}
type
	TSGContextGLUT=class(TSGContext)
			public
		constructor Create;
		destructor Destroy;override;
			public
		procedure Initialize;override;
		procedure Run;override;
		procedure Messages;override;
		procedure SwapBuffers;override;
		function TopShift:LongWord;override;
		function GetCursorPosition:TSGPoint2f;override;
		function GetWindowRect:TSGPoint2f;override;
		function GetScreenResolution:TSGPoint2f;override;
		procedure Resize;override;
		function MouseShift:TSGPoint2f;override;
		class function RectInCoords:Boolean;override;
		procedure InitFullscreen(const b:boolean); override;
			public
		FCursorMoution:TSGPoint2f;
			public
		function GetRC:LongWord;override;
		procedure SetRC(const NewRC:LongWord);override;
		end;
{$ENDIF}


{$IFDEF SGREADIMPLEMENTATION}

procedure TSGContextGLUT.InitFullscreen(const b:boolean); 
begin
if FFullscreen<>b then
	begin
	if b then
		glutFullScreen
	else
		begin
		glutReshapeWindow(Width,Height);
		//glutPositionWindow
		end;
	end;
inherited;
end;

function TSGContextGLUT.GetRC:LongWord;
begin
Result:=glutGetWindow();
end;

procedure TSGContextGLUT.SetRC(const NewRC:LongWord);
begin
glutSetWindow(NewRC);
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

procedure GLUTDrawGLScreen; cdecl;
begin
glClear(GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT);
SGInitMatrixMode(SG_3D);
if SGContext.FCallDraw<>nil then
	SGContext.FCallDraw();
SGIIdleFunction;
SGScreen.Paint();
SGContext.SwapBuffers;
SGContext.ClearKeys;
SGContext.Messages;
{if SGContext.FNewContextType<>nil then
	glutDestroyWindow(glutGetWindow());}
end;

procedure GLUTIdle; cdecl;
begin
glutPostWindowRedisplay(glutGetWindow());
end;

procedure GLUTVisible(vis:integer); cdecl;
begin
glutIdleFunc(@GLUTIdle);
end;

procedure GLUTReSizeScreen(Width, Height: Integer); cdecl;
begin
if Height = 0 then
	Height := 1;
SGContext.Width:=Width;
SGContext.Height:=Height;
SGContext.Resize;
end;

procedure GLUTKeyboard(Key: 
byte
//glint
; X, Y: Longint); cdecl;
begin
WriteLn(Key,' ',GLUT_KEY_F11);
TSGContextGLUT(Pointer(SGContext)).FCursorMoution.x:=x;
TSGContextGLUT(Pointer(SGContext)).FCursorMoution.y:=y;

SGContext.SetKey(SGDownKey,Key);
end;

procedure GLUTMouse(Button:integer; State:integer; x,y:integer);cdecl;
var
	Bnt:TSGCursorButtons;
	BntType:TSGCursorButtonType;
begin
TSGContextGLUT(Pointer(SGContext)).FCursorMoution.x:=x;
TSGContextGLUT(Pointer(SGContext)).FCursorMoution.y:=y;
case Button of
GLUT_LEFT_BUTTON:
	Bnt:=SGLeftCursorButton;
GLUT_RIGHT_BUTTON:
	Bnt:=SGRightCursorButton;
GLUT_MIDDLE_BUTTON:
	Bnt:=SGMiddleCursorButton;
end;
if State=0 then
	begin
	BntType:=SGDownKey;
	SGContext.FCursorKeysPressed[Bnt]:=True;
	end
else
	begin
	BntType:=SGUpKey;
	SGContext.FCursorKeysPressed[Bnt]:=False;
	end;
SGContext.FCursorKeyPressed:=Bnt;
SGContext.FCursorKeyPressedType:=BntType;
end;

procedure GLUTMotionPassive(x,y:longint);cdecl;
begin
TSGContextGLUT(Pointer(SGContext)).FCursorMoution.x:=x;
TSGContextGLUT(Pointer(SGContext)).FCursorMoution.y:=y;
SGContext.FCursorKeysPressed[SGLeftCursorButton]:=False;
SGContext.FCursorKeysPressed[SGMiddleCursorButton]:=False;
SGContext.FCursorKeysPressed[SGRightCursorButton]:=False;
end;

procedure GLUTMotion(x,y:longint);cdecl;
begin
TSGContextGLUT(Pointer(SGContext)).FCursorMoution.x:=x;
TSGContextGLUT(Pointer(SGContext)).FCursorMoution.y:=y;
end;

function TSGContextGLUT.MouseShift:TSGPoint2f;
begin
Result.Import(
{$IFDEF MSWINDOWS}
	0,0
{$ELSE}
	0,0
	{$ENDIF}
	);
end;

procedure TSGContextGLUT.Resize;
begin
inherited;
end;

class function TSGContextGLUT.RectInCoords:Boolean;
begin
Result:=False;
end;

constructor TSGContextGLUT.Create;
begin
inherited;
FCursorMoution.Import();
end;

destructor TSGContextGLUT.Destroy;
begin

inherited;
end;

procedure TSGContextGLUT.Initialize;
type
	TF=procedure (a:Byte;b,c:LongInt);cdecl;
begin
glutInitPascal(True);
glutInitDisplayMode(GLUT_DOUBLE or GLUT_RGB or GLUT_DEPTH);


if Fullscreen then 
	begin
	glutGameModeString(SGStringToPChar(SGStr(Width)+'x'+SGStr(Height)+':32@60'));
	glutEnterGameMode();
	end
else 
	begin
	glutInitWindowSize(Width, Height);
	glutInitWindowPosition((GetScreenResolution.x - Width) div 2,(GetScreenResolution.y - Height) div 2);
	glutCreateWindow(SGStringToPChar(FTitle));
	end;

glutSetCursor(GLUT_CURSOR_LEFT_ARROW);

glutDisplayFunc(@GLUTDrawGLScreen);
glutVisibilityFunc(@GLUTVisible);
glutReshapeFunc(@GLUTReSizeScreen);
glutKeyboardFunc(TF(@GLUTKeyboard));
glutMouseFunc(@GLUTMouse);
glutMotionFunc(@GLUTMotion);
glutPassiveMotionFunc(@GLUTMotionPassive);
glutSetIconTitle(PChar(FIconIdentifier));

SGInitOpenGL;

if SGContext.FCallInitialize<>nil then
	SGContext.FCallInitialize();
end;

procedure TSGContextGLUT.Run;
begin
glutMainLoop;
end;

procedure TSGContextGLUT.Messages;
begin
inherited;
end;

procedure TSGContextGLUT.SwapBuffers;
begin
glutSwapBuffers;
end;

function TSGContextGLUT.TopShift:LongWord;
begin
Result:=0;
end;

function TSGContextGLUT.GetCursorPosition:TSGPoint2f;
begin
Result:=FCursorMoution;
end;

function TSGContextGLUT.GetWindowRect:TSGPoint2f;
begin
Result.Import(
	glutGet(GLUT_WINDOW_X),
	glutGet(GLUT_WINDOW_Y));
end;

function TSGContextGLUT.GetScreenResolution:TSGPoint2f;
begin
Result.Import(
	glutGet(GLUT_SCREEN_WIDTH),
	glutGet(GLUT_SCREEN_HEIGHT));
end;

{$ENDIF}
