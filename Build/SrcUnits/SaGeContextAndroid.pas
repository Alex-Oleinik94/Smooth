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
			protected
		procedure InitFullscreen(const b:boolean); override;
			public
		procedure ShowCursor(const b:Boolean);override;
		procedure SetCursorPosition(const a:TSGPoint2f);override;
			public
		FDisplay:Pointer;
		FSurface: EGLSurface;
		FAndroidApp:Pandroid_app;
		FConfig: EGLConfig;
		FAnimating:cint;
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
if What='WINDOW HANDLE' then
	Result:=AndroidApp^.Window
else if What='DESCTOP WINDOW HANDLE' then
	Result:=FDisplay
else if What='VISUAL INFO' then
	Result:=FConfig
else if What = 'SURFACE' then
	Result:=FSurface
else
	Result:=inherited Get(What);
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
FAnimating:=0;
FAndroidApp:=nil;
FSurface:=nil;
FDisplay:=nil;
FLastTouch.Import();
FInitialized:=False;
FConfig:=nil;
end;

destructor TSGContextAndroid.Destroy();
begin
SGLog.Sourse('Entering "TSGContextAndroid.Destroy".');
if (FDisplay <> EGL_NO_DISPLAY) then
	begin
	FRender.ReleaseCurrent();
	FRender.Destroy();
	FRender:=nil;
	if (FSurface <> EGL_NO_SURFACE) then
		eglDestroySurface(FDisplay, FSurface);
	eglTerminate(FDisplay);
	end;
inherited;
SGLog.Sourse('Leaving "TSGContextAndroid.Destroy".');
end;

procedure TSGContextAndroid.Initialize();
begin
Active:=True;
end;

procedure TSGContextAndroid.InitWindow();
//{$DEFINE SGDEPTHANDROID24}
const
	Attribs: array[0..{$IFDEF SGDEPTHANDROID24}10{$ELSE}8{$ENDIF}] of EGLint = (
		EGL_SURFACE_TYPE, EGL_WINDOW_BIT,
		EGL_BLUE_SIZE, 8,
		EGL_GREEN_SIZE, 8,
		EGL_RED_SIZE, 8,
		{$IFDEF SGDEPTHANDROID24}EGL_DEPTH_SIZE, 24,{$ENDIF}
		EGL_NONE);
var
	Format,NumConfigs: EGLint;
	FunctiosResult : TSGMaxEnum;
begin
SGLog.Sourse('Entering "TSGContextAndroid.InitWindow".');
FDisplay:=eglGetDisplay(EGL_DEFAULT_DISPLAY);
SGLog.Sourse('"TSGContextAndroid.InitWindow" : "eglGetDisplay" calling sucssesful! Result="'+SGStr(TSGMaxEnum(FDisplay))+'"');
FunctiosResult := eglInitialize(FDisplay, nil,nil);
SGLog.Sourse('"TSGContextAndroid.InitWindow" : Called "eglInitialize". Result="'+SGStr(FunctiosResult)+'".');
FunctiosResult := eglChooseConfig(FDisplay, Attribs, @FConfig, 1, @NumConfigs); 
SGLog.Sourse('"TSGContextAndroid.InitWindow" : Called "eglChooseConfig". Result="'+SGStr(FunctiosResult)+'".');
FunctiosResult := eglGetConfigAttrib(FDisplay, FConfig, EGL_NATIVE_VISUAL_ID, @Format);
SGLog.Sourse('"TSGContextAndroid.InitWindow" : Called "eglGetConfigAttrib". Result="'+SGStr(FunctiosResult)+'".');
FunctiosResult := ANativeWindow_SetBuffersGeometry(FAndroidApp^.Window, 0, 0, Format); 
SGLog.Sourse('"TSGContextAndroid.InitWindow" : Called "ANativeWindow_SetBuffersGeometry". Result="'+SGStr(FunctiosResult)+'"');
FSurface:=eglCreateWindowSurface(FDisplay, FConfig, AndroidApp^.Window, nil);
SGLog.Sourse('"TSGContextAndroid.InitWindow" : Called "eglCreateWindowSurface". Result="'+SGStr(FunctiosResult)+'"');
if FRender=nil then
	begin
	FRender:=FRenderClass.Create();
	FRender.Window:=Self;
	if FRender.CreateContext() then 
		FRender.Init()
	else
		Active:=False;
	end
else
	begin
	FRender.Window:=Self;
	if FRender.SetPixelFormat() then
		Render.MakeCurrent()
	else
		Active:=False;
	end;
SGLog.Sourse('"TSGContextAndroid.InitWindow" : Render created!');
Width:=GetScreenResolution().x;
Height:=GetScreenResolution().y;
SGLog.Sourse('"TSGContextAndroid.InitWindow" : Screen resolution = ('+SGStr(Width)+','+SGStr(Height)+').');
if SGScreenLoadProcedure<>nil then
	begin
	SGScreenLoadProcedure(Self);
	SGLog.Sourse('"TSGContextAndroid.InitWindow" : Called "SGScreenLoadProcedure(Self)".');
	end;
if FCallInitialize<>nil then
	begin
	FCallInitialize(Self);
	SGLog.Sourse('"TSGContextAndroid.InitWindow" : Called "FCallInitialize(Self)".');
	end;
SGLog.Sourse('Leaving "TSGContextAndroid.InitWindow".');
end;

procedure TSGContextAndroid.HandleComand(const Comand:cint32);
begin
SGLog.Sourse('Entering "TSGContextAndroid.HandleCommand" : Comand="'+SGStr(Comand)+'"');
case Comand of
APP_CMD_SAVE_STATE://Наверное сохранить память приложения, для очистки оперы...
	begin
	SGLog.Sourse('"TSGContextAndroid.HandleCommand" : Comand is "APP_CMD_SAVE_STATE"');
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
	SGLog.Sourse('"TSGContextAndroid.HandleCommand" : Comand is "APP_CMD_INIT_WINDOW"');
	InitWindow();
	end;
APP_CMD_TERM_WINDOW://Убиваем окно
	begin
	SGLog.Sourse('"TSGContextAndroid.HandleCommand" : Comand is "APP_CMD_TERM_WINDOW"');
	Active:=False;
	end;
APP_CMD_GAINED_FOCUS://Тогда когда приложение используется
	begin
	SGLog.Sourse('"TSGContextAndroid.HandleCommand" : Comand is "APP_CMD_GAINED_FOCUS"');
	FAnimating:=1;
	end;
APP_CMD_LOST_FOCUS://Тогда когда приложение свернуто/блакировка экрана или т п, в общем ради батарейки
	begin
	SGLog.Sourse('"TSGContextAndroid.HandleCommand" : Comand is "APP_CMD_LOST_FOCUS"');
	FAnimating:=0;
	end;
end;
SGLog.Sourse('Leaving "TSGContextAndroid.HandleCommand".');
end;

function TSGContextAndroid.HandleEvent(Event:PAInputEvent):cint32;
begin
SGLog.Sourse('Entering "TSGContextAndroid.HandleEvent". Event type ="'+SGStr(AInputEvent_getType(event))+'"');
case AInputEvent_getType(event) of
AINPUT_EVENT_TYPE_MOTION:
	begin
	SGLog.Sourse('"TSGContextAndroid.HandleEvent" : Event is "AINPUT_EVENT_TYPE_MOTION"');
	FLastTouch.Import(
		Round(AMotionEvent_getX(event, 0)),
		Round(AMotionEvent_getY(event, 0)));
	FAnimating:=1;
	end;
else
	begin
	SGLog.Sourse('Leaving "TSGContextAndroid.HandleEvent" : Program don''t know what is the event!');
	Result:=0;
	Exit;
	end;
end;
Result:=1;
SGLog.Sourse('Leaving "TSGContextAndroid.HandleEvent".');
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
SGLog.Sourse('Entering "TSGContextAndroid.Run".');
FAndroidApp^.UserData := Self;
FAndroidApp^.OnAppCmd:=@TSGContextAndroid_HandleComand;
FAndroidApp^.OnInputEvent:=@TSGContextAndroid_HandleInput;
Messages();
while FActive and (FNewContextType=nil) do
	begin
	//Calc ElapsedTime
	FDT.Get();
	FElapsedTime:=(FDT-FElapsedDateTime).GetPastMiliSeconds;
	FElapsedDateTime:=FDT;
	if FDisplay<>nil then
		if FAnimating<>0 then
			begin
			Render.Clear(SGR_COLOR_BUFFER_BIT OR SGR_DEPTH_BUFFER_BIT);
			Render.InitMatrixMode(SG_3D);
			if FCallDraw<>nil then
				FCallDraw(Self);
			//SGIIdleFunction;
			
			ClearKeys();
			Messages();
			
			if SGScreenPaintProcedure<>nil then
				SGScreenPaintProcedure(Self);
			SwapBuffers();
			end
		else
			begin
			ClearKeys();
			Messages();
			
			Render.Clear(SGR_COLOR_BUFFER_BIT OR SGR_DEPTH_BUFFER_BIT);
			SwapBuffers();
			end
	else
		begin
		Messages();
		end;
	end;
SGLog.Sourse('Leaving "TSGContextAndroid.Run".');
end;

procedure TSGContextAndroid.SwapBuffers();
begin
eglSwapBuffers(FDisplay,FSurface);
end;

procedure TSGContextAndroid.Messages();
var
	Ident, Events, Val: cint;
	source: PAndroid_Poll_Source;
begin
SGLog.Sourse('Entering "TSGContextAndroid.Messages".');
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
inherited;
SGLog.Sourse('Leaving "TSGContextAndroid.Messages".');
end;

procedure TSGContextAndroid.InitFullscreen(const b:boolean); 
begin
FFullscreen := True;
//inherited InitFullscreen(b);
end;

end.
