{$INCLUDE SaGe.inc}

//{$DEFINE GLUT_DEBUG}

unit SaGeContextGLUT;

interface

uses
	Classes
	,SaGeBase
	,SaGeBased
	,SaGeContext
	,SaGeCommon
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
		constructor Create;
		destructor Destroy;override;
			public
		procedure Initialize;override;
		procedure Run;override;
		procedure Messages;override;
		procedure SwapBuffers;override;
		function GetCursorPosition: TSGPoint2int32;override;
		function GetWindowArea: TSGPoint2int32;override;
		function GetScreenArea: TSGPoint2int32;override;
		procedure Resize;override;
		procedure InitFullscreen(const b:boolean); override;
		class function Suppored() : TSGBoolean; override;
			public
		function  GetClientWidth() : TSGLongWord;override;
		function  GetClientHeight() : TSGLongWord;override;
			protected
		function InitRender() : TSGBoolean;
			public
		FCursorMoution: TSGPoint2int32;
		end;

implementation

uses
	SaGeRenderOpenGL,
	SaGeCommonClasses,
	SaGeRender;
var
	ContextGLUT : TSGContextGLUT = nil;

{$IFDEF GLUT_DEBUG}
procedure GLUTHint(const S : TSGString);
begin
SGLog.Sourse(S);
WriteLn(S);
end;
{$ENDIF}

class function TSGContextGLUT.Suppored() : TSGBoolean;
begin
Result := GLUT.GLUTLoaded;
end;

function  TSGContextGLUT.GetClientWidth() : TSGLongWord;
begin
Result := FWidth;
end;

function  TSGContextGLUT.GetClientHeight() : TSGLongWord;
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
			glutReshapeWindow(Width,Height);
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

procedure GLUTDrawGLScreen; cdecl;
begin
{$IFDEF GLUT_DEBUG}GLUTHint('GLUTDrawGLScreen');{$ENDIF}
ContextGLUT.Paint();
end;

procedure GLUTIdle; cdecl;
begin
{$IFDEF GLUT_DEBUG}GLUTHint('GLUTIdle');{$ENDIF}
glutPostWindowRedisplay(glutGetWindow());
end;

procedure GLUTVisible(vis:integer); cdecl;
begin
{$IFDEF GLUT_DEBUG}GLUTHint('GLUTVisible(Visible='+SGStr(vis)+')');{$ENDIF}
glutIdleFunc(@GLUTIdle);
end;

procedure GLUTReSizeScreen(Width, Height: Integer); cdecl;
begin
{$IFDEF GLUT_DEBUG}GLUTHint('GLUTReSizeScreen(Width='+SGStr(Width)+',Height='+SGStr(Height)+')');{$ENDIF}
if Height = 0 then
	Height := 1;
ContextGLUT.Width  := Width;
ContextGLUT.Height := Height;
ContextGLUT.Resize();
end;

procedure GLUTKeyboard(Key: byte{glint}; X, Y: Longint); cdecl;
begin
{$IFDEF GLUT_DEBUG}GLUTHint('GLUTReSizeScreen(Key='+SGStr(Key)+',X='+SGStr(X)+',Y='+SGStr(Y)+'), Char(Key)="'+Char(Key)+'"');{$ENDIF}
ContextGLUT.FCursorMoution.x:=x;
ContextGLUT.FCursorMoution.y:=y;

ContextGLUT.SetKey(SGUpKey, Key);
end;

procedure GLUTMouse(Button:integer; State:integer; x,y:integer);cdecl;
var
	Bnt:TSGCursorButtons;
	BntType:TSGCursorButtonType;
begin
{$IFDEF GLUT_DEBUG}GLUTHint('GLUTMouse');{$ENDIF}
ContextGLUT.FCursorMoution.x:=x;
ContextGLUT.FCursorMoution.y:=y;
case Button of
GLUT_LEFT_BUTTON:
	Bnt:=SGLeftCursorButton;
GLUT_RIGHT_BUTTON:
	Bnt:=SGRightCursorButton;
GLUT_MIDDLE_BUTTON:
	Bnt:=SGMiddleCursorButton;
end;
if State=0 then
	BntType:=SGDownKey
else
	BntType:=SGUpKey;
ContextGLUT.SetCursorKey(BntType, Bnt);
end;

procedure GLUTMotionPassive(x,y:longint);cdecl;
begin
{$IFDEF GLUT_DEBUG}GLUTHint('GLUTMotionPassive');{$ENDIF}
ContextGLUT.FCursorMoution.x:=x;
ContextGLUT.FCursorMoution.y:=y;
end;

procedure GLUTMotion(x,y:longint);cdecl;
begin
{$IFDEF GLUT_DEBUG}GLUTHint('GLUTMotion');{$ENDIF}
ContextGLUT.FCursorMoution.x:=x;
ContextGLUT.FCursorMoution.y:=y;
end;

procedure GLUTWindowStatus(Status:integer); cdecl;
begin
{$IFDEF GLUT_DEBUG}GLUTHint('GLUTWindowStatus(Status='+SGStr(Status)+')');{$ENDIF}
end;

procedure TSGContextGLUT.Initialize();
type
	TF = procedure (a:Byte;b,c:LongInt);cdecl;
begin
if ContextGLUT <> nil then
	begin
	SGLog.Sourse('TSGContextGLUT__InitRender() : Finded other GLUT context, destroyed!');
	ContextGLUT.Destroy();
	ContextGLUT := nil;
	end;

ContextGLUT := Self;

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
	glutInitWindowPosition((GetScreenArea.x - Width) div 2,(GetScreenArea.y - Height) div 2);
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
//glutSetIconTitle(PChar(5));
//glutWindowStatusFunc(@GLUTWindowStatus);

Active := InitRender();
if Active then
	inherited;
end;

procedure TSGContextGLUT.Resize;
begin
inherited;
end;

constructor TSGContextGLUT.Create();
begin
inherited;
FCursorMoution.Import();
end;

destructor TSGContextGLUT.Destroy();
begin
if glutGetWindow() <> 0 then
	glutDestroyWindow(glutGetWindow());
ContextGLUT := nil;
inherited;
end;

function TSGContextGLUT.InitRender() : TSGBoolean;
const
	TempRender : TSGRender = nil;
begin
if (FRenderClass = nil) then
	begin
	FRenderClass := TSGRenderOpenGL;
	end
else
	begin
	SGLog.Sourse('TSGContextGLUT__InitRender() : Testing render class!');
	TempRender := FRenderClass.Create();
	if not (TempRender is TSGRenderOpenGL) then
		begin
		SGLog.Sourse('TSGContextGLUT__InitRender() : GLUT can work only with OpenGL! Render replaced!');
		FRenderClass := TSGRenderOpenGL;
		end;
	TempRender.Destroy();
	TempRender := nil;
	end;

if FRender = nil then
	begin
	{$IFDEF GLUT_DEBUG}
		SGLog.Sourse('TSGContextGLUT__InitRender() : Createing render');
		{$ENDIF}
	FRender := FRenderClass.Create();
	FRender.Context := Self as ISGContext;
	FRender.Init();
	Result := FRender <> nil;
	{$IFDEF GLUT_DEBUG}
		SGLog.Sourse('TSGContextGLUT__InitRender() : Created render (Render='+SGAddrStr(FRender)+')');
		{$ENDIF}
	end
else
	begin
	if not (FRender is TSGRenderOpenGL) then
		begin
		SGLog.Sourse('TSGContextGLUT__InitRender() : GLUT can work only with OpenGL! Render recreated!');
		FRender.Destroy();
		FRender := nil;
		Result := InitRender();
		end;
	
	{$IFDEF GLUT_DEBUG}
		SGLog.Sourse('TSGContextGLUT__InitRender() : Formating render (Render='+SGAddrStr(FRender)+')');
		{$ENDIF}
	FRender.Context := Self as ISGContext;
	Result := FRender.MakeCurrent();
	end;
end;

procedure TSGContextGLUT.Run;
begin
StartComputeTimer();
while Active and (FNewContextType = nil) do
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

function TSGContextGLUT.GetCursorPosition: TSGPoint2int32;
begin
Result:=FCursorMoution;
end;

function TSGContextGLUT.GetWindowArea: TSGPoint2int32;
begin
Result.Import(
	glutGet(GLUT_WINDOW_X),
	glutGet(GLUT_WINDOW_Y));
end;

function TSGContextGLUT.GetScreenArea: TSGPoint2int32;
begin
Result.Import(
	glutGet(GLUT_SCREEN_WIDTH),
	glutGet(GLUT_SCREEN_HEIGHT));
end;

end.
