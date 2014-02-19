{$INCLUDE Includes\SaGe.inc}
unit SaGeContextAndroid;
interface

uses 
	SaGeBase
	,SaGeBased
	,SaGeCommon
	,SaGeRender
	,SaGeContext
	,unix
		//android units:
	,cmem
	,gles
	,egl
	,ctypes
	,native_activity
	,native_window
	,looper
	,input
	,android_native_app_glue
	,log
	;
type
	TSGContextAndroid=class(TSGContext)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		procedure Initialize();override;
		procedure Run();override;
		procedure Messages();override;
		procedure SwapBuffers();override;
		function  GetCursorPosition():TSGPoint2f;override;
		function  GetWindowRect():TSGPoint2f;override;
		function  GetScreenResolution():TSGPoint2f;override;
		procedure InitFullscreen(const b:boolean); override;
		procedure ShowCursor(const b:Boolean);override;
		procedure SetCursorPosition(const a:TSGPoint2f);override;
			public
		FDisplay:Pointer;
		FSurface: EGLSurface;
		FAndroidApp:Pandroid_app;
			private
		FLastTouch:TSGPoint2f;
		FInitialized:Boolean;
		procedure InitWindow();
			public
		function Get(const What:string):Pointer;override;
			public
		procedure HandleComand(const Comand:cint32);
		function HandleEvent(Event:PAInputEvent):cint32;
			public
		property AndroidApp:Pandroid_app read FAndroidApp write FAndroidApp;
		end;

implementation

function TSGContextAndroid.Get(const What:string):Pointer;
begin
//if What='WINDOW HANDLE' then
//else if What='DESCTOP WINDOW HANDLE' then
//else if What = 'VISUAL INFO' then
end;

procedure TSGContextAndroid.SetCursorPosition(const a:TSGPoint2f);
begin
SGLog.Sourse('"TSGContextAndroid.SetCursorPosition" isn''t possible!');
end;

procedure TSGContextAndroid.ShowCursor(const b:Boolean);
begin
SGLog.Sourse('"TSGContextAndroid.ShowCursor" isn''t possible!');
end;

function TSGContextAndroid.GetScreenResolution():TSGPoint2f;
var
	w,h:EGLint;
begin
if (FSurface<>nil) and (FDisplay<>nil) then
	begin
	eglQuerySurface(Fdisplay, Fsurface, EGL_WIDTH, @w);
	eglQuerySurface(Fdisplay, Fsurface, EGL_HEIGHT, @h);
	Result.Import(w,h);
	end
else
	Result.Import();
end;

function TSGContextAndroid.GetCursorPosition():TSGPoint2f;
begin
Result:=FLastTouch;
end;

function TSGContextAndroid.GetWindowRect():TSGPoint2f;
begin
Result.Import();
end;

constructor TSGContextAndroid.Create();
begin
inherited;
FAndroidApp:=nil;
FSurface:=nil;
FDisplay:=nil;
FLastTouch.Import();
FInitialized:=False;
end;

destructor TSGContextAndroid.Destroy();
begin
if (Fdisplay <> EGL_NO_DISPLAY) then
	begin
	eglMakeCurrent(Fdisplay, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
	{if (Fcontext <> EGL_NO_CONTEXT) then
		eglDestroyContext(Fdisplay, Fcontext);}
	if (Fsurface <> EGL_NO_SURFACE) then
		eglDestroySurface(Fdisplay, Fsurface);
	eglTerminate(Fdisplay);
	end;
inherited;
end;

procedure TSGContextAndroid.Initialize();
begin
Active:=True;
end;

procedure TSGContextAndroid.InitWindow();
const
	Attribs: array[0..8] of EGLint = (
		EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
		EGL_BLUE_SIZE, 8,
		EGL_GREEN_SIZE, 8,
		EGL_RED_SIZE, 8,
		EGL_NONE);
var
	Format,NumConfigs: EGLint;
	Config: EGLConfig;
begin
FDisplay:=eglGetDisplay(EGL_DEFAULT_DISPLAY);
eglInitialize(FDisplay, nil,nil);
eglChooseConfig(FDisplay, Attribs, @Config, 1, @NumConfigs); 
eglGetConfigAttrib(FDisplay, Config, EGL_NATIVE_VISUAL_ID, @Format);

ANativeWindow_SetBuffersGeometry(FAndroidApp^.Window, 0, 0, Format); 



if SGCLLoadProcedure<>nil then
	SGCLLoadProcedure(FSelfPoint);
if FCallInitialize<>nil then
	FCallInitialize(FSelfPoint);
end;

procedure TSGContextAndroid.HandleComand(const Comand:cint32);
begin
case Comand of
APP_CMD_SAVE_STATE://В душе не ебу
	;
APP_CMD_INIT_WINDOW://Иницианализируем окно
	InitWindow();
APP_CMD_TERM_WINDOW://Убиваем окно
	Active:=False;
APP_CMD_GAINED_FOCUS://Тогда когда приложение используется
	;
APP_CMD_LOST_FOCUS://Тогда когда приложение свернуто/блакировка экрана или т п, в общем ради батарейки
	;
end;
end;

function TSGContextAndroid.HandleEvent(Event:PAInputEvent):cint32;
begin
case AInputEvent_getType(event) of
AINPUT_EVENT_TYPE_MOTION:
	begin
	FLastTouch.Import(
		Round(AMotionEvent_getX(event, 0)),
		Round(AMotionEvent_getY(event, 0)));
	end;
else
	begin
	Result:=0;
	Exit;
	end;
end;
Result:=1;
end;

function TSGContextAndroid_HandleInput(Application: PAndroid_App; Event: PAInputEvent): cint32;cdecl;
begin
Result:=TSGContextAndroid(Application^.UserData).HandleEvent(Event);
end;
procedure TSGContextAndroid_HandleComand(Application: PAndroid_App; Comand: cint32); cdecl;
begin
TSGContextAndroid(Application^.UserData).HandleComand(Comand);
end;

procedure TSGContextAndroid.Run();
var
	FDT:TSGDateTime;
begin
FAndroidApp^.UserData := Self;
FAndroidApp^.OnAppCmd:=@TSGContextAndroid_HandleComand;
FAndroidApp^.OnInputEvent:=@TSGContextAndroid_HandleInput;

end;

procedure TSGContextAndroid.SwapBuffers();
begin
eglSwapBuffers(FDisplay,FSurface);
end;

procedure TSGContextAndroid.Messages();
begin

inherited;
end;

procedure TSGContextAndroid.InitFullscreen(const b:boolean); 
begin

inherited InitFullscreen(b);

end;

end.
