{$I Includes\SaGe.inc}
unit SaGeContextUnix;
interface

uses 
	SaGeBase, SaGeBased
	,SaGeCommon
	,SaGeRender
	,SaGeContext
	{$IFDEF UNIX}
		,Dl
		,unix
		,x
		,xlib
		,xutil
		,glx
		{$ENDIF}
	;
type
	TSGContextUnix=class(TSGContext)
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
		function  KeysPressed(const  Index : integer ) : Boolean;override;overload;
			public
		winAttr: TXSetWindowAttributes;
		dpy: PDisplay;
		win: TWindow;
		visinfo: PXVisualInfo;
		cm: TColormap;
			//Cursor Buffer
		FCursorX,FCursorY:LongWord;
		function  CreateWindow():Boolean;
			public
		function Get(const What:string):Pointer;override;
		end;
implementation

function TSGContextUnix.Get(const What:string):Pointer;
begin
if What='WINDOW HANDLE' then
	Result:=Pointer(win)
else if What='DESCTOP WINDOW HANDLE' then
	Result:=Pointer(dpy)
else if What = 'VISUAL INFO' then
	Result:=visinfo
else
	Result:=Inherited Get(What);
end;

function TSGContextUnix.KeysPressed(const  Index : integer ) : Boolean;overload;
begin

end;

procedure TSGContextUnix.SetCursorPosition(const a:TSGPoint2f);
begin


end;

procedure TSGContextUnix.ShowCursor(const b:Boolean);
begin

end;

function TSGContextUnix.GetScreenResolution:TSGPoint2f;
begin
Result.Import(
	XWidthOfScreen(XScreenOfDisplay(XOpenDisplay(nil),0)),
	XHeightOfScreen(XScreenOfDisplay(XOpenDisplay(nil),0)));
end;

function TSGContextUnix.GetCursorPosition:TSGPoint2f;
begin
Result.Import(FCursorX,FCursorY)
end;

function TSGContextUnix.GetWindowRect():TSGPoint2f;
begin
Result.Import();
end;

constructor TSGContextUnix.Create();
begin
inherited;
FillChar(winAttr,sizeof(winAttr),0);
dpy:=nil;
win:=0;
visinfo:=nil;
cm:=0;
FCursorY:=0;
FCursorX:=0;
end;

destructor TSGContextUnix.Destroy();
begin
XCloseDisplay(dpy);
inherited;
end;

procedure TSGContextUnix.Initialize();
begin
Active:=CreateWindow();
if Active then
	begin
	if SGCLLoadProcedure<>nil then
		SGCLLoadProcedure(FSelfPoint);
	if FCallInitialize<>nil then
		FCallInitialize(FSelfPoint);
	end;
end;

procedure TSGContextUnix.Run;
var
	FDT:TSGDateTime;
begin
Messages;
FElapsedDateTime.Get;
while FActive and (FNewContextType=nil) do
	begin
	//Calc ElapsedTime
	FDT.Get;
	FElapsedTime:=(FDT-FElapsedDateTime).GetPastMiliSeconds;
	FElapsedDateTime:=FDT;
	
	Render.Clear(SGR_COLOR_BUFFER_BIT OR SGR_DEPTH_BUFFER_BIT);
	Render.InitMatrixMode(SG_3D);
	if FCallDraw<>nil then
		FCallDraw(FSelfPoint);
	//SGIIdleFunction;
	
	ClearKeys();
	Messages();
	
	if SGCLPaintProcedure<>nil then
		SGCLPaintProcedure(FSelfPoint);
	SwapBuffers();
	end;
end;

procedure TSGContextUnix.SwapBuffers();
begin
Render.SwapBuffers();
end;

procedure TSGContextUnix.Messages();
var 
	Event: TXEvent;
    KeySum:TKeySym;
    s:string[4];
begin
While XPending(dpy)<>0 do
	begin 
	XNextEvent(dpy,@event);
	case Event._Type of
	ConfigureNotify:
		begin
		Width:=Event.XConfigure.Width;
		Height:=Event.XConfigure.Height;
		Resize();
		end;
	MotionNotify:
		begin
		FCursorY:=Event.XButton.y;
		FCursorX:=Event.XButton.x;
		end;
	ButtonPress:
		begin
		case Event.XButton.Button of
		1:SetCursorKey(SGDownKey,SGLeftCursorButton);
		2:SetCursorKey(SGDownKey,SGMiddleCursorButton);
		3:SetCursorKey(SGDownKey,SGRightCursorButton);
		4:FCursorWheel:=SGDownCursorWheel;
		5:FCursorWheel:=SGUpCursorWheel;
		end;
		end;
	ButtonRelease:
		begin
		case Event.XButton.Button of
		1:SetCursorKey(SGUpKey,SGLeftCursorButton);
		2:SetCursorKey(SGUpKey,SGMiddleCursorButton);
		3:SetCursorKey(SGUpKey,SGRightCursorButton);
		end;
		end;
	KeyPress:
		begin
		XLookupString(@Event.Xkey,@s,sizeof(s),@KeySum,nil);
		//SetKey(SGDownKey,WParam);
		(*SGSetKey(char(Keysum));
		SGSetKeyDown(char(Keysum));*)
		end;
	KeyRelease:
		begin
		XLookupString(@Event.Xkey,@s,sizeof(s),@KeySum,nil);
		//SetKey(SGUpKey,WParam);
		(*SGSetKeyUp(char(Keysum));*)
		end;
	DestroyNotify:
		begin
		SGLog.Sourse('TSGContextUnix__Messages : Note : Window is closed for API.');
		Active:=False;
		end;
	end;
	end;
inherited;
end;



function TSGContextUnix.CreateWindow():Boolean;
var
	errorBase,eventBase: integer;
	window_title_property: TXTextProperty;
var
	attr: Array[0..8] of integer = (GLX_RGBA,GLX_RED_SIZE,1,GLX_GREEN_SIZE,1,GLX_BLUE_SIZE,1,GLX_DOUBLEBUFFER,none);
	Name:PChar = nil;
begin 
Result:=False;
dpy := XOpenDisplay(nil);
if dpy = nil then
	begin
	SGLog.Sourse('TSGContextUnix__CreateWindow : Error : Could not connect to X server!');
	Exit;
	end;
if not (glXQueryExtension(dpy,errorBase,eventBase)) then
	begin
	SGLog.Sourse('TSGContextUnix__CreateWindow : Error : GLX extension not supported!');
	Exit;
	end;
visinfo := glXChooseVisual(dpy,DefaultScreen(dpy), Attr);
if(visinfo = nil) then
	begin
	SGLog.Sourse('TSGContextUnix__CreateWindow : Error : Could not find visual!');
	Exit;
	end;
cm := XCreateColormap(dpy,RootWindow(dpy,visinfo^.screen),visinfo^.visual,AllocNone);
winAttr.colormap := cm;
winAttr.border_pixel := 0;
winAttr.background_pixel := 0;
winAttr.event_mask := ExposureMask or PointerMotionMask or ButtonPressMask or ButtonReleaseMask or StructureNotifyMask or KeyPressMask or KeyReleaseMask;
win := XCreateWindow(dpy,RootWindow(dpy,visinfo^.screen),0,0,Width,Height,0,visinfo^.depth,InputOutput,visinfo^.visual,CWBorderPixel or CWColormap or CWEventMask,@winAttr);
if win = 0 then
	begin
	SGLog.Sourse('TSGContextUnix__CreateWindow : Error : Could not create window!');
	Exit;
	end;
Name:=SGStringAsPChar(FTittle);
XStringListToTextProperty(@Name,1,@window_title_property);
XSetWMName(dpy,win,@window_title_property);

if FRender=nil then
	begin
	FRender:=FRenderClass.Create();
	FRender.Window:=Self;
	Result:=FRender.CreateContext();
	if Result then 
		FRender.Init();
	
	XMapWindow(dpy,win);
	end
else
	begin
	FRender.Window:=Self;
	Result:=FRender.SetPixelFormat();
	if Result then
		Render.MakeCurrent();
	end;
end;

procedure TSGContextUnix.InitFullscreen(const b:boolean); 
begin

inherited InitFullscreen(b);

end;

end.
