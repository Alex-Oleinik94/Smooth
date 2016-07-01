{$INCLUDE Includes\SaGe.inc}
unit SaGeContextAndroid;
interface

uses 
	SaGeBase
	,SaGeBased
	,SaGeCommon
	,SaGeRender
	,SaGeContext
	,SaGeCommonClasses
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
	TSGContextAndroid=class(TSGContext)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		procedure Initialize();override;
		procedure Run();override;
		procedure Messages();override;
		procedure SwapBuffers();override;
		function  GetCursorPosition(): TSGPoint2int32;override;
		function  GetWindowArea(): TSGPoint2int32;override;
		function  GetScreenArea(): TSGPoint2int32;override;
			protected
		procedure InitFullscreen(const b:boolean); override;
			public
		procedure ShowCursor(const b:Boolean);override;
		procedure SetCursorPosition(const a: TSGPoint2int32);override;
			public
		FDisplay:Pointer;
		FSurface: EGLSurface;
		FAndroidApp:Pandroid_app;
		FConfig: EGLConfig;
		FAnimating:cint;
			private
		FLastTouch: TSGPoint2int32;
		function InitWindow():TSGBoolean;
		procedure DestroyWondow();
			public
		function GetOption(const What : TSGString) : TSGPointer;override;
			public
		procedure HandleComand(const Comand:cint32);
		function HandleEvent(Event:PAInputEvent):cint32;
			public
		property AndroidApp:Pandroid_app read FAndroidApp write FAndroidApp;
		end;

implementation

uses
	SaGeScreen;

function TSGContextAndroid.GetOption(const What : TSGString) : TSGPointer;
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

procedure TSGContextAndroid.SetCursorPosition(const a: TSGPoint2int32);
begin
SGLog.Sourse('"TSGContextAndroid.SetCursorPosition" isn''t possible!');
end;

procedure TSGContextAndroid.ShowCursor(const b:Boolean);
begin
SGLog.Sourse('"TSGContextAndroid.ShowCursor" isn''t possible!');
end;

function TSGContextAndroid.GetScreenArea(): TSGPoint2int32;
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

function TSGContextAndroid.GetCursorPosition(): TSGPoint2int32;
begin
Result:=FLastTouch;
end;

function TSGContextAndroid.GetWindowArea(): TSGPoint2int32;
begin
Result.Import();
end;

constructor TSGContextAndroid.Create();
begin
inherited;
FAnimating:=0;
FAndroidApp:=nil;
FSurface:=nil;
FDisplay:=nil;
FLastTouch.Import();
FConfig:=nil;
end;

destructor TSGContextAndroid.Destroy();
begin
SGLog.Sourse('Entering "TSGContextAndroid.Destroy".');
if (FDisplay <> EGL_NO_DISPLAY) then
	begin
	DestroyWondow();
	FRender.Destroy();
	FRender:=nil;
	end;
inherited;
SGLog.Sourse('Leaving "TSGContextAndroid.Destroy".');
end;

procedure TSGContextAndroid.Initialize();
begin
Active:=True;
end;

procedure TSGContextAndroid.DestroyWondow();
begin
if Render<>nil then
	Render.LockResourses();
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

function TSGContextAndroid.InitWindow():TSGBoolean;
{$DEFINE SGDEPTHANDROID}
const
	Attribs: array[0..{$IFDEF SGDEPTHANDROID}10{$ELSE}8{$ENDIF}] of EGLint = (
		EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
		EGL_BLUE_SIZE, 8,
		EGL_GREEN_SIZE, 8,
		EGL_RED_SIZE, 8,
		{$IFDEF SGDEPTHANDROID}EGL_DEPTH_SIZE, 24,{$ENDIF}
		EGL_NONE);
var
	Format,NumConfigs: EGLint;
	FunctiosResult : TSGMaxEnum;

procedure InitPixelFormat();inline;
begin
FunctiosResult := eglChooseConfig(FDisplay, Attribs, @FConfig, 1, @NumConfigs); 
SGLog.Sourse('"TSGContextAndroid.InitWindow" : Called "eglChooseConfig". Result="'+SGStr(FunctiosResult)+'".');
FunctiosResult := eglGetConfigAttrib(FDisplay, FConfig, EGL_NATIVE_VISUAL_ID, @Format);
if Attribs[8] <> EGL_NONE then
	SGLog.Sourse('"TSGContextAndroid.InitWindow" : Called "eglGetConfigAttrib". Result="'+SGStr(FunctiosResult)+'", Depth Size = "'+SGStr(Attribs[9])+'".')
else
	SGLog.Sourse('"TSGContextAndroid.InitWindow" : Called "eglGetConfigAttrib". Result="'+SGStr(FunctiosResult)+'", Without Depth.');
end;

begin
Result:=False;
SGLog.Sourse('Entering "TSGContextAndroid.InitWindow".');
if FDisplay = EGL_NO_DISPLAY then
	begin
	FDisplay       := eglGetDisplay(EGL_DEFAULT_DISPLAY);
	SGLog.Sourse('"TSGContextAndroid.InitWindow" : "eglGetDisplay" calling sucssesful! Result="'+SGStr(TSGMaxEnum(FDisplay))+'"');
	FunctiosResult := eglInitialize(FDisplay, nil,nil);
	SGLog.Sourse('"TSGContextAndroid.InitWindow" : Called "eglInitialize". Result="'+SGStr(FunctiosResult)+'".');
	InitPixelFormat();
	{$IFDEF SGDEPTHANDROID}
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
		SGLog.Sourse('"TSGContextAndroid.InitWindow" : FATAL : Can''t initialize pixel formats.');
		Result := False;
		Active := False;
		Exit;
		end;
	FunctiosResult := ANativeWindow_SetBuffersGeometry(FAndroidApp^.Window, 0, 0, Format); 
	SGLog.Sourse('"TSGContextAndroid.InitWindow" : Called "ANativeWindow_SetBuffersGeometry". Result="'+SGStr(FunctiosResult)+'"');
	end;
FSurface       := eglCreateWindowSurface(FDisplay, FConfig, AndroidApp^.Window, nil);
SGLog.Sourse('"TSGContextAndroid.InitWindow" : Called "eglCreateWindowSurface". Result="'+SGStr(FunctiosResult)+'"');
if FRender=nil then
	begin
	FRender:=FRenderClass.Create();
	FRender.Context := Self as ISGContext;
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
	FRender.Context := Self as ISGContext;
	FRender.UnLockResourses();
	Result:=True;
	end;
FWidth :=GetScreenArea().x;
FHeight:=GetScreenArea().y;
SGLog.Sourse('"TSGContextAndroid.InitWindow" : Screen resolution = ('+SGStr(Width)+','+SGStr(Height)+').');
if not FInitialized then
	begin
	SGScreen.Load(Self);
	SGLog.Sourse('"TSGContextAndroid.InitWindow" : Called "SGScreen.Load(Self)".');
	if FPaintableClass <> nil then
		begin
		SGScreen.Load(Self);
		FPaintable := FPaintableClass.Create(Self);
		FPaintable.LoadDeviceResourses();
		SGLog.Sourse('"TSGContextAndroid.InitWindow" : Paintable created');
		end;
	end;
SGLog.Sourse('Leaving "TSGContextAndroid.InitWindow".');
FInitialized:=Result;
end;

procedure TSGContextAndroid.HandleComand(const Comand:cint32);

function WITC():TSGString;
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
else Result := 'UNKNOWN('+SGStr(Comand)+')';
end;
end;

begin
SGLog.Sourse('Entering "TSGContextAndroid.HandleCommand" : New comand = "'+WITC()+'"');
case Comand of
APP_CMD_SAVE_STATE://C�������� ������ ����������...
	begin
	//��
	end;
(*
// The system has asked us to save our current state.  Do so.
engine^.app^.savedState := malloc(sizeof(Tsaved_state));
Psaved_state(engine^.app^.savedState)^ := engine^.state;
engine^.app^.savedStateSize := sizeof(Tsaved_state); 
*)
APP_CMD_INIT_WINDOW://���������������� ����
	begin
	Active:=InitWindow();
	FAnimating:=1;
	end;
APP_CMD_TERM_WINDOW://������� ����
	begin
	FAnimating:=0;
	DestroyWondow();
	end;
APP_CMD_GAINED_FOCUS://����� ����� ���������� ������������
	begin
	FAnimating:=1;
	end;
APP_CMD_LOST_FOCUS,APP_CMD_PAUSE,APP_CMD_STOP://����� ����� ���������� ��������/���������� ������ ��� � �, � ����� ���� ���������
	begin
	FAnimating:=0;
	end;
APP_CMD_CONFIG_CHANGED://������� ������ � � �
	begin
	FAnimating:=1;
	///.......
	///AConfiguration_getOrientation(..)
	end;
APP_CMD_DESTROY://���������� ������ ����������
	begin
	Active:=False;
	FAnimating:=0;
	end;
end;
end;

function TSGContextAndroid.HandleEvent(Event:PAInputEvent):cint32;
var 
	EventType, EventActionAndMask,EventAction,EventPointerIndex, EventCode, EventScanCode, PointersCount : TSGLongInt;

function WITE():TSGString;inline;
begin
case EventType of
AINPUT_EVENT_TYPE_MOTION : Result := 'AINPUT_EVENT_TYPE_MOTION';
AINPUT_EVENT_TYPE_KEY    : Result := 'AINPUT_EVENT_TYPE_KEY';
else Result := 'UNKNOWN('+SGStr(EventType)+')';
end;
end;

function WITA():TSGString;inline;
begin
case EventAction of
AKEY_EVENT_ACTION_DOWN : Result := 'AKEY_EVENT_ACTION_DOWN';
AKEY_EVENT_ACTION_UP    : Result := 'AKEY_EVENT_ACTION_UP';
AKEY_EVENT_ACTION_MULTIPLE : Result := 'AKEY_EVENT_ACTION_MULTIPLE';
else Result := 'UNKNOWN('+SGStr(EventAction)+')';
end;
end;


function WITAM():TSGString;inline;
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
else Result := 'UNKNOWN('+SGStr(EventAction)+')';
end;
end;

var
	i: TSGLongWord;
	S : STRING = '';
begin
EventType := AInputEvent_getType(event);
//SGLog.Sourse('Entering "TSGContextAndroid.HandleEvent". Event type ="'+WITE()+'"');
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
			SetCursorKey(SGUpKey,SGLeftCursorButton);
	AMOTION_EVENT_ACTION_DOWN:
		begin
		SetCursorKey(SGDownKey,SGLeftCursorButton);
		FCursorPosition[SGDeferenseCursorPosition].Import(0,0);
		FCursorPosition[SGNowCursorPosition]:=FLastTouch;
		FCursorPosition[SGLastCursorPosition]:=FLastTouch;
		end;
	end;
	{S+= '"TSGContextAndroid.HandleEvent" : Action = "'+WITAM()+'", PointerIndex = "'+SGStr(EventPointerIndex)+'", PointersCount = "'+SGStr(PointersCount)+'"';
	for i := 0 to PointersCount-1 do
		S+=', Pointer'+SGStr(i+1)+':('+SGStr(Round(AMotionEvent_getX(event, i)))+','+SGStr(Round(AMotionEvent_getY(event, i)))+')';
	SGLog.Sourse(s);}
	FAnimating:=1;
	end;
{AINPUT_EVENT_TYPE_KEY:
	begin
	EventCode     := AKeyEvent_getKeyCode(event);
	EventScanCode := AKeyEvent_getScanCode(event);
	
	SGLog.Sourse('"TSGContextAndroid.HandleEvent" : Key = (Code:'+SGStr(EventCode)+';ScanCode:'+SGStr(EventScanCode)+'), Action = "'+WITA()+'"');
	end;}
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

procedure ChangingResolution();
var
	FPoint : TSGPoint2int32;
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
SGLog.Sourse('Entering "TSGContextAndroid.Run".');
FAndroidApp^.UserData := Self;
FAndroidApp^.OnAppCmd:=@TSGContextAndroid_HandleComand;
FAndroidApp^.OnInputEvent:=@TSGContextAndroid_HandleInput;
Messages();
SGLog.Sourse('"TSGContextAndroid.Run" : before circle Active="'+SGStr(Active)+'", Animating="'+SGStr(FAnimating)+'".');
StartComputeTimer();

while FActive and (FNewContextType=nil) do
	begin
	if (FDisplay<>nil) and (FAnimating<>0) then
		begin
		//SGLog.Sourse('"TSGContextAndroid.Run" : Begin paint!');
		Paint();
		//SGLog.Sourse('"TSGContextAndroid.Run" : End paint...');
		
		ChangingResolution();
		end
	else
		begin
		UpdateTimer();
		//SGLog.Sourse('"TSGContextAndroid.Run" : Wait!');
		Messages();
		end;
	end;
SGLog.Sourse('Leaving "TSGContextAndroid.Run".');
end;

procedure TSGContextAndroid.SwapBuffers();
begin
Render.SwapBuffers();
end;

procedure TSGContextAndroid.Messages();
var
	Ident, Events, Val: cint;
	source: PAndroid_Poll_Source;
begin
//SGLog.Sourse('Entering "TSGContextAndroid.Messages".');
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
//SGLog.Sourse('Leaving "TSGContextAndroid.Messages".');
end;

procedure TSGContextAndroid.InitFullscreen(const b:boolean); 
begin
FFullscreen := True;
end;

end.
