{$INCLUDE Smooth.inc}

unit SmoothContextAndroid;

interface

uses
	 SmoothBase
	,SmoothCommonStructs
	,SmoothRender
	,SmoothContext
	,SmoothBaseClasses
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothContextUtils
		//android units:
	,unix
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
	TSContextAndroid = class(TSContext)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		class function ContextName() : TSString; override;
		procedure Initialize(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal);override;
		procedure Run();override;
		procedure Messages();override;
		procedure SwapBuffers();override;
		function  GetCursorPosition(): TSPoint2int32;override;
		function  GetWindowArea(): TSPoint2int32;override;
		function  GetScreenArea(): TSPoint2int32;override;
		class function Supported() : TSBoolean; override;
			protected
		procedure InitFullscreen(const b:boolean); override;
			public
		procedure ShowCursor(const b:Boolean);override;
		procedure SetCursorPosition(const a: TSPoint2int32);override;
			public
		FDisplay:Pointer;
		FSurface: EGLSurface;
		FAndroidApp:Pandroid_app;
		FConfig: EGLConfig;
		FAnimating:cint;
			private
		FLastTouch: TSPoint2int32;
		function InitWindow():TSBoolean;
		procedure DestroyWondow();
			public
		function GetOption(const What : TSString) : TSPointer;override;
			public
		procedure HandleComand(const Comand:cint32);
		function HandleEvent(Event:PAInputEvent):cint32;
			public
		property AndroidApp:Pandroid_app read FAndroidApp write FAndroidApp;
		end;

implementation

uses
	 SmoothScreen
	,SmoothLog
	,SmoothStringUtils
	;

class function TSContextAndroid.ContextName() : TSString;
begin
Result := 'Android';
end;

class function TSContextAndroid.Supported() : TSBoolean;
begin
Result := True;
end;

function TSContextAndroid.GetOption(const What : TSString) : TSPointer;
begin
if What='WINDOW HANDLE' then
	Result:=AndroidApp^.Window
else if What='DESKTOP WINDOW HANDLE' then
	Result:=FDisplay
else if What='VISUAL INFO' then
	Result:=FConfig
else if What = 'SURFACE' then
	Result:=FSurface
else
	Result := nil;
end;

procedure TSContextAndroid.SetCursorPosition(const a: TSPoint2int32);
begin
SLog.Source('"TSContextAndroid.SetCursorPosition" isn''t possible!');
end;

procedure TSContextAndroid.ShowCursor(const b:Boolean);
begin
SLog.Source('"TSContextAndroid.ShowCursor" isn''t possible!');
end;

function TSContextAndroid.GetScreenArea(): TSPoint2int32;
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

function TSContextAndroid.GetCursorPosition(): TSPoint2int32;
begin
Result:=FLastTouch;
end;

function TSContextAndroid.GetWindowArea(): TSPoint2int32;
begin
Result.Import();
end;

constructor TSContextAndroid.Create();
begin
inherited;
FAnimating:=0;
FAndroidApp:=nil;
FSurface:=nil;
FDisplay:=nil;
FLastTouch.Import();
FConfig:=nil;
end;

destructor TSContextAndroid.Destroy();
begin
SLog.Source('Entering "TSContextAndroid.Destroy".');
if (FDisplay <> EGL_NO_DISPLAY) then
	begin
	DestroyWondow();
	FRender.Destroy();
	FRender:=nil;
	end;
inherited;
SLog.Source('Leaving "TSContextAndroid.Destroy".');
end;

procedure TSContextAndroid.Initialize(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal);
begin
Active:=True;
end;

procedure TSContextAndroid.DestroyWondow();
begin
if Render<>nil then
	Render.LockResources();
if (FSurface <> EGL_NO_SURFACE) then
	begin
	eglDestroySurface(FDisplay, FSurface);
	FSurface := EGL_NO_SURFACE;
	end;
if FDisplay<> EGL_NO_DISPLAY then
	begin
	eglTerminate(FDisplay);
	FDisplay:= EGL_NO_DISPLAY;
	end;
end;

function TSContextAndroid.InitWindow():TSBoolean;
{$DEFINE SDEPTHANDROID}
const
	Attribs: array[0..{$IFDEF SDEPTHANDROID}10{$ELSE}8{$ENDIF}] of EGLint = (
		EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
		EGL_BLUE_SIZE, 8,
		EGL_GREEN_SIZE, 8,
		EGL_RED_SIZE, 8,
		{$IFDEF SDEPTHANDROID}EGL_DEPTH_SIZE, 24,{$ENDIF}
		EGL_NONE);
var
	Format,NumConfigs: EGLint;
	FunctiosResult : TSMaxEnum;

procedure InitPixelFormat();inline;
begin
FunctiosResult := eglChooseConfig(FDisplay, Attribs, @FConfig, 1, @NumConfigs);
SLog.Source('"TSContextAndroid.InitWindow" : Called "eglChooseConfig". Result="'+SStr(FunctiosResult)+'".');
FunctiosResult := eglGetConfigAttrib(FDisplay, FConfig, EGL_NATIVE_VISUAL_ID, @Format);
if Attribs[8] <> EGL_NONE then
	SLog.Source('"TSContextAndroid.InitWindow" : Called "eglGetConfigAttrib". Result="'+SStr(FunctiosResult)+'", Depth Size = "'+SStr(Attribs[9])+'".')
else
	SLog.Source('"TSContextAndroid.InitWindow" : Called "eglGetConfigAttrib". Result="'+SStr(FunctiosResult)+'", Without Depth.');
end;

begin
Result:=False;
SLog.Source('Entering "TSContextAndroid.InitWindow".');
if FDisplay = EGL_NO_DISPLAY then
	begin
	FDisplay       := eglGetDisplay(EGL_DEFAULT_DISPLAY);
	SLog.Source('"TSContextAndroid.InitWindow" : "eglGetDisplay" calling sucssesful! Result="'+SStr(TSMaxEnum(FDisplay))+'"');
	FunctiosResult := eglInitialize(FDisplay, nil,nil);
	SLog.Source('"TSContextAndroid.InitWindow" : Called "eglInitialize". Result="'+SStr(FunctiosResult)+'".');
	InitPixelFormat();
	{$IFDEF SDEPTHANDROID}
		while (FunctiosResult = 0) and (Attribs[9]<>8) do
			begin
			Attribs[9] -= 8;
			InitPixelFormat();
			end;
		if FunctiosResult = 0 then
			begin
			Attribs[8] := EGL_NONE;
			InitPixelFormat();
			end;
		{$ENDIF}
	if FunctiosResult = 0 then
		begin
		SLog.Source('"TSContextAndroid.InitWindow" : FATAL : Can''t initialize pixel formats.');
		Result := False;
		Active := False;
		Exit;
		end;
	FunctiosResult := ANativeWindow_SetBuffersGeometry(FAndroidApp^.Window, 0, 0, Format);
	SLog.Source('"TSContextAndroid.InitWindow" : Called "ANativeWindow_SetBuffersGeometry". Result="'+SStr(FunctiosResult)+'"');
	end;
FSurface       := eglCreateWindowSurface(FDisplay, FConfig, AndroidApp^.Window, nil);
SLog.Source('"TSContextAndroid.InitWindow" : Called "eglCreateWindowSurface". Result="'+SStr(FunctiosResult)+'"');
if FRender=nil then
	begin
	FRender:=FRenderClass.Create();
	FRender.Context := Self as ISContext;
	if FRender.CreateContext() then
		begin
		FRender.Init();
		Result:=True;
		end
	else
		Active:=False;
	end
else
	begin
	FRender.Context := Self as ISContext;
	FRender.UnLockResources();
	Result:=True;
	end;
FWidth :=GetScreenArea().x;
FHeight:=GetScreenArea().y;
SLog.Source('"TSContextAndroid.InitWindow" : Screen resolution = ('+SStr(Width)+','+SStr(Height)+').');
if not FInitialized then
	begin
	if not Screen.ContextAssigned() then
		Screen.Load(Self);
	SLog.Source('"TSContextAndroid.InitWindow" : Called "Screen.Load(Self)".');
	if (FPaintable = nil) and (FPaintableClass <> nil) then
		begin
		FPaintable := FPaintableClass.Create(Self);
		SetPaintableSettings();
		FPaintable.LoadDeviceResources();
		SLog.Source('"TSContextAndroid.InitWindow" : Paintable created');
		end;
	end;
SLog.Source('Leaving "TSContextAndroid.InitWindow".');
FInitialized:=Result;
end;

procedure TSContextAndroid.HandleComand(const Comand:cint32);

function WITC():TSString;
begin
case Comand of
APP_CMD_INPUT_CHANGED : Result := 'APP_CMD_INPUT_CHANGED';
APP_CMD_INIT_WINDOW   : Result := 'APP_CMD_INIT_WINDOW';
APP_CMD_TERM_WINDOW   : Result := 'APP_CMD_TERM_WINDOW';
APP_CMD_WINDOW_RESIZED: Result := 'APP_CMD_WINDOW_RESIZED';
APP_CMD_WINDOW_REDRAW_NEEDED: Result := 'APP_CMD_WINDOW_REDRAW_NEEDED';
APP_CMD_CONTENT_RECT_CHANGED : Result := 'APP_CMD_CONTENT_RECT_CHANGED';
APP_CMD_GAINED_FOCUS : Result := 'APP_CMD_GAINED_FOCUS';
APP_CMD_LOST_FOCUS : Result := 'APP_CMD_LOST_FOCUS';
APP_CMD_CONFIG_CHANGED : Result := 'APP_CMD_CONFIG_CHANGED';
APP_CMD_LOW_MEMORY : Result := 'APP_CMD_LOW_MEMORY';
APP_CMD_START : Result := 'APP_CMD_START';
APP_CMD_RESUME : Result := 'APP_CMD_RESUME';
APP_CMD_SAVE_STATE : Result := 'APP_CMD_SAVE_STATE';
APP_CMD_PAUSE : Result := 'APP_CMD_PAUSE';
APP_CMD_STOP : Result := 'APP_CMD_STOP';
APP_CMD_DESTROY : Result := 'APP_CMD_DESTROY';
else Result := 'UNKNOWN('+SStr(Comand)+')';
end;
end;

begin
SLog.Source('Entering "TSContextAndroid.HandleCommand" : New comand = "'+WITC()+'"');
case Comand of
APP_CMD_SAVE_STATE://Cохранить память приложения...
	begin
	//хз
	end;
(*
// The system has asked us to save our current state.  Do so.
engine^.app^.savedState := malloc(sizeof(Tsaved_state));
Psaved_state(engine^.app^.savedState)^ := engine^.state;
engine^.app^.savedStateSize := sizeof(Tsaved_state);
*)
APP_CMD_INIT_WINDOW://Иницианализируем окно
	begin
	Active:=InitWindow();
	FAnimating:=1;
	end;
APP_CMD_TERM_WINDOW://Убиваем окно
	begin
	FAnimating:=0;
	DestroyWondow();
	end;
APP_CMD_GAINED_FOCUS://Тогда когда приложение используется
	begin
	FAnimating:=1;
	end;
APP_CMD_LOST_FOCUS,APP_CMD_PAUSE,APP_CMD_STOP://Тогда когда приложение свернуто/блакировка экрана или т п, в общем ради батарейки
	begin
	FAnimating:=0;
	end;
APP_CMD_CONFIG_CHANGED://Поворот экрана и т п
	begin
	FAnimating:=1;
	///.......
	///AConfiguration_getOrientation(..)
	end;
APP_CMD_DESTROY://Завершение работы приложения
	begin
	Active:=False;
	FAnimating:=0;
	end;
end;
end;

function TSContextAndroid.HandleEvent(Event:PAInputEvent):cint32;
var
	EventType, EventActionAndMask,EventAction,EventPointerIndex, EventCode, EventScanCode, PointersCount : TSLongInt;

function WITE():TSString;inline;
begin
case EventType of
AINPUT_EVENT_TYPE_MOTION : Result := 'AINPUT_EVENT_TYPE_MOTION';
AINPUT_EVENT_TYPE_KEY    : Result := 'AINPUT_EVENT_TYPE_KEY';
else Result := 'UNKNOWN('+SStr(EventType)+')';
end;
end;

function WITA():TSString;inline;
begin
case EventAction of
AKEY_EVENT_ACTION_DOWN : Result := 'AKEY_EVENT_ACTION_DOWN';
AKEY_EVENT_ACTION_UP    : Result := 'AKEY_EVENT_ACTION_UP';
AKEY_EVENT_ACTION_MULTIPLE : Result := 'AKEY_EVENT_ACTION_MULTIPLE';
else Result := 'UNKNOWN('+SStr(EventAction)+')';
end;
end;


function WITAM():TSString;inline;
begin
case EventAction of
AMOTION_EVENT_ACTION_DOWN : Result := 'AMOTION_EVENT_ACTION_DOWN';
AMOTION_EVENT_ACTION_UP : Result := 'AMOTION_EVENT_ACTION_UP';
AMOTION_EVENT_ACTION_MOVE : Result := 'AMOTION_EVENT_ACTION_MOVE';
AMOTION_EVENT_ACTION_CANCEL : Result := 'AMOTION_EVENT_ACTION_CANCEL';
AMOTION_EVENT_ACTION_POINTER_DOWN : Result := 'AMOTION_EVENT_ACTION_POINTER_DOWN';
AMOTION_EVENT_ACTION_OUTSIDE : Result := 'AMOTION_EVENT_ACTION_OUTSIDE';
AMOTION_EVENT_ACTION_POINTER_UP : Result := 'AMOTION_EVENT_ACTION_POINTER_UP';
AMOTION_EVENT_ACTION_HOVER_MOVE : Result := 'AMOTION_EVENT_ACTION_HOVER_MOVE';
AMOTION_EVENT_ACTION_SCROLL : Result := 'AMOTION_EVENT_ACTION_SCROLL';
AMOTION_EVENT_ACTION_HOVER_ENTER : Result := 'AMOTION_EVENT_ACTION_HOVER_ENTER';
AMOTION_EVENT_ACTION_HOVER_EXIT : Result := 'AMOTION_EVENT_ACTION_HOVER_EXIT';
else Result := 'UNKNOWN('+SStr(EventAction)+')';
end;
end;

var
	i: TSLongWord;
	S : STRING = '';
begin
EventType := AInputEvent_getType(event);
//SLog.Source('Entering "TSContextAndroid.HandleEvent". Event type ="'+WITE()+'"');
case EventType of
AINPUT_EVENT_TYPE_MOTION:
	begin
	EventActionAndMask := AMotionEvent_getAction(event);
	EventAction := AMOTION_EVENT_ACTION_MASK and EventActionAndMask;
	EventPointerIndex := (AMOTION_EVENT_ACTION_POINTER_INDEX_MASK and EventActionAndMask) shr AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT;
	PointersCount := AMotionEvent_getPointerCount(event);
	FLastTouch.Import(
		Round(AMotionEvent_getX(event, 0)),
		Round(AMotionEvent_getY(event, 0)));
	case EventAction of
	AMOTION_EVENT_ACTION_UP:
			SetCursorKey(SUpKey,SLeftCursorButton);
	AMOTION_EVENT_ACTION_DOWN:
		begin
		SetCursorKey(SDownKey,SLeftCursorButton);
		FCursorPosition[SDeferenseCursorPosition].Import(0,0);
		FCursorPosition[SNowCursorPosition]:=FLastTouch;
		FCursorPosition[SLastCursorPosition]:=FLastTouch;
		end;
	end;
	{S+= '"TSContextAndroid.HandleEvent" : Action = "'+WITAM()+'", PointerIndex = "'+SStr(EventPointerIndex)+'", PointersCount = "'+SStr(PointersCount)+'"';
	for i := 0 to PointersCount-1 do
		S+=', Pointer'+SStr(i+1)+':('+SStr(Round(AMotionEvent_getX(event, i)))+','+SStr(Round(AMotionEvent_getY(event, i)))+')';
	SLog.Source(s);}
	FAnimating:=1;
	end;
{AINPUT_EVENT_TYPE_KEY:
	begin
	EventCode     := AKeyEvent_getKeyCode(event);
	EventScanCode := AKeyEvent_getScanCode(event);

	SLog.Source('"TSContextAndroid.HandleEvent" : Key = (Code:'+SStr(EventCode)+';ScanCode:'+SStr(EventScanCode)+'), Action = "'+WITA()+'"');
	end;}
else
	begin
	Result:=0;
	Exit;
	end;
end;
Result:=1;
end;

function TSContextAndroid_HandleInput(Application: PAndroid_App; Event: PAInputEvent): cint32;cdecl;
begin
Result:=TSContextAndroid(Application^.UserData).HandleEvent(Event);
end;
procedure TSContextAndroid_HandleComand(Application: PAndroid_App; Comand: cint32); cdecl;
begin
TSContextAndroid(Application^.UserData).HandleComand(Comand);
end;

procedure TSContextAndroid.Run();

procedure ChangingResolution();
var
	FPoint : TSPoint2int32;
begin
FPoint := GetScreenArea();
if (FPoint.x<>FWidth) or (FPoint.y<>FHeight) then
	begin
	FWidth :=FPoint.x;
	FHeight:=FPoint.y;
	Resize();
	end;
end;

begin
SLog.Source('Entering "TSContextAndroid.Run".');
FAndroidApp^.UserData := Self;
FAndroidApp^.OnAppCmd:=@TSContextAndroid_HandleComand;
FAndroidApp^.OnInputEvent:=@TSContextAndroid_HandleInput;
Messages();
SLog.Source('"TSContextAndroid.Run" : before circle Active="'+SStr(Active)+'", Animating="'+SStr(FAnimating)+'".');
StartComputeTimer();

while FActive and (FNewContextType=nil) do
	begin
	if (FDisplay<>nil) and (FAnimating<>0) then
		begin
		//SLog.Source('"TSContextAndroid.Run" : Begin paint!');
		Paint();
		//SLog.Source('"TSContextAndroid.Run" : End paint...');

		ChangingResolution();
		end
	else
		begin
		UpdateTimer();
		//SLog.Source('"TSContextAndroid.Run" : Wait!');
		Messages();
		end;
	end;
SLog.Source('Leaving "TSContextAndroid.Run".');
end;

procedure TSContextAndroid.SwapBuffers();
begin
Render.SwapBuffers();
end;

procedure TSContextAndroid.Messages();
var
	Ident, Events, Val: cint;
	source: PAndroid_Poll_Source;
begin
//SLog.Source('Entering "TSContextAndroid.Messages".');
if FAnimating<>0 then
	Val:=0
else
	Val:=-1;
Ident := ALooper_PollAll(Val, nil, @Events,@Source);
while (Ident >= 0) do
	begin
	 if (Source <> nil) then
		Source^.Process(FAndroidApp, Source);
	 if (Ident = LOOPER_ID_USER) then
		begin
		{if (engine.accelerometerSensor != nil) then
		begin
		   ASensorEvent event;
		   while (ASensorEventQueue_getEvents(engine.sensorEventQueue, &event, 1) > 0) do
		   begin
			  LOGI("accelerometer: x=%f y=%f z=%f",
					  [event.acceleration.x, event.acceleration.y,
					  event.acceleration.z]);
		   end;
		end;}
		end;
	if (FAndroidApp^.DestroyRequested <> 0) then
		begin
		LOGW('Destroy requested');
		Active:=False;
		end;
	if FAnimating<>0 then
		Val := 0
	else
		Val := -1;
	Ident := ALooper_pollAll(Val, nil, @Events,@Source);
	end;
if FAnimating <> 0 then
	inherited;
//SLog.Source('Leaving "TSContextAndroid.Messages".');
end;

procedure TSContextAndroid.InitFullscreen(const b:boolean);
begin
FFullscreen := True;
end;

end.
