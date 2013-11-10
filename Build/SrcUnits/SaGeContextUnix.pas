{$I Includes\SaGe.inc}
unit SaGeContextUnix;
interface

uses 
	SaGeBase, SaGeBased
	,SaGeCommon
	,SaGeRender
	,SaGeContext
	{$IFDEF UNIX}
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
		procedure SetUnixKey(const VKey:word; const VKeyType:TSGCursorButtonType);
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

procedure TSGContextUnix.SetUnixKey(const VKey:word; const VKeyType:TSGCursorButtonType);
var
	PKey:PByte = nil;
	NormalKey:Byte = 0;
begin
PKey := PByte(@VKey);
WriteLn(PKey[0],' ',PKey[1]);
case PKey[1] of
0://English
	begin
	(*
	[48..57] - [)!@#$%^&*(] of 0..9
	32 - Space
	114 - R key
	*)
	case PKey[0] of
	114:NormalKey:=82;// R key
	32:NormalKey:=32;// Space
	end;
	end;
6://Russian
	begin
	
	
	end;
255://System
	begin
	(*
	227 - Left Ctrl
	228 - Right Ctrl
	235 - Windows
	233 - Left Alt
	234 - Right Alt
	103 - Option 
	13 - Enter
	225 - Left Shift
	226 - Right Shift
	9 - Tab
	229 - cAPS LOCK
	8 - Back Space
	255 - Delete
	27 - Escape
	85 - Page Up
	86 - Page Down
	80 - Home
	87 - End
	82 - Up
	81 - Left
	83 - Right
	84 - Down
	[190..201] - F1 .. F12
	68 - F - Help (F1)
	149 - F - WiFi (F3)
	0 - F - Lighting Down (F11)
	177 - F- Lighting Up (F12)
	99 - Ins
	127 - Num Lock
	19 - Pause | Break
	*)
	case PKey[0] of
	82:NormalKey:=38;// Up
	81:NormalKey:=37;// Left
	83:NormalKey:=39;// Right
	84:NormalKey:=40;// Down
	8:NormalKey:=8;// Backspace
	27:NormalKey:=27;// Escape
	13:NormalKey:=13;// Enter
	end;
	end;
end;
if NormalKey<>0 then
	SetKey(VKeyType,NormalKey);
end;

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
if dpy = nil then
	begin
	Result.Import(
		XWidthOfScreen(XScreenOfDisplay(XOpenDisplay(nil),0)),
		XHeightOfScreen(XScreenOfDisplay(XOpenDisplay(nil),0)));
	end
else
	begin
	Result.Import(
		XWidthOfScreen(XScreenOfDisplay(dpy,0)),
		XHeightOfScreen(XScreenOfDisplay(dpy,0)));
	end;
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
		SetUnixKey(Keysum,SGDownKey);
		end;
	KeyRelease:
		begin
		XLookupString(@Event.Xkey,@s,sizeof(s),@KeySum,nil);
		SetUnixKey(Keysum,SGUpKey);
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
