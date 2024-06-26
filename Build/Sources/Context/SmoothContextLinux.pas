{$INCLUDE Smooth.inc}

unit SmoothContextLinux;

interface

uses 
	 SmoothBase
	,SmoothCommon
	,SmoothRender
	,SmoothContext
	,SmoothBaseClasses
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothContextUtils
	
	,unix
	,x
	,xlib
	,xutil
	,glx
	;
type
	TSContextLinux = class(TSContext)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		class function ContextName() : TSString; override;
		procedure Initialize(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal);override;
		procedure Run();override;
		procedure Messages();override;
		procedure SwapBuffers();override;
		function  GetCursorPosition(): TSPoint2int32;override;
		function  GetScreenArea(): TSPoint2int32;override;
		procedure Kill();override;
		class function Supported() : TSBoolean; override;
			protected
		procedure InitFullscreen(const b:boolean); override;
			public
		procedure ShowCursor(const VVisibility : TSBoolean);override;
		procedure SetCursorPosition(const a: TSPoint2int32);override;
		procedure SetTitle(const NewTitle:TSString);override;
		procedure SetCursor(const VCursor : TSCursor);override;
			private
		procedure SetUnixKey(const VKey:word; const VKeyType:TSCursorButtonType);
			private
		dpy: PDisplay;
		win: TWindow;
		visinfo: PXVisualInfo;
		cm: TColormap;
			//Cursor Buffer
		FCursorX, FCursorY:LongWord;
		FCursorPtr : TSLongWord;
		function  CreateWindow():Boolean;
		procedure SetLinuxCursor(const VCursorPtr : TSLongWord; const VCursorVisibility : TSBoolean);
		class function GetPtrCursor(const VSPtr : TSCursorHandle) : TSLongWord;
		procedure SetBmpCursor(const VCursor : TSCursor);
			public
		function  GetOption(const What:string):Pointer;override;
		function  GetWindow() : TSPointer; override;
		function  GetDevice() : TSPointer; override;
			protected
		function  GetClientWidth() : TSAreaInt;override;
		function  GetClientHeight() : TSAreaInt;override;
		end;

implementation

uses
	 SmoothScreen
	,SmoothEncodingUtils
	,SmoothLog
	,SmoothStringUtils
	;

class function TSContextLinux.ContextName() : TSString;
begin
Result := 'Linux';
end;

class function TSContextLinux.Supported() : TSBoolean; 
begin
Result := True;
end;

procedure TSContextLinux.SetBmpCursor(const VCursor : TSCursor);
begin
FCursorPtr := 0;

end;

procedure TSContextLinux.SetCursor(const VCursor : TSCursor);
begin
if VCursor.StandartHandle <> SC_NULL then
	begin
	SetLinuxCursor(GetPtrCursor(VCursor.StandartHandle), FShowCursor);
	inherited;
	end
else
	begin
	SetBmpCursor(VCursor);
	inherited;
	end;
end;

class function TSContextLinux.GetPtrCursor(const VSPtr : TSCursorHandle) : TSLongWord;
const
	XC_left_ptr = 68;
	XC_xterm    = 152;
	XC_hand1    = 58; 
begin
case VSPtr of
SC_NULL: Result := 0;
SC_APPSTARTING: Result := 0;
SC_NORMAL: Result := XC_left_ptr;
SC_CROSS: Result := 0;
SC_HAND: Result := XC_hand1;
SC_HELP: Result := 0;
SC_IBEAM: Result := XC_xterm;
SC_NO: Result := 0;
SC_SIZEALL: Result := 0;
SC_SIZENESW: Result := 0;
SC_SIZENS: Result := 0;
SC_SIZENWSE: Result := 0;
SC_SIZEWE: Result := 0;
SC_UP: Result := 0;
SC_WAIT: Result := 0;
SC_GLASSY: Result := 0;
end;
//WriteLn(VSPtr,' ',Result);
end;

function  TSContextLinux.GetClientWidth() : TSAreaInt;
begin
Result := Width;
end;

function  TSContextLinux.GetClientHeight() : TSAreaInt;
begin
Result := Height;
end;

procedure TSContextLinux.SetTitle(const NewTitle:TSString);
begin
FTitle := SConvertAnsiToASCII(NewTitle);
end;

procedure TSContextLinux.SetUnixKey(const VKey:word; const VKeyType:TSCursorButtonType);
{
	* }(*WinAPI Codes*){
	* 8 - Tab
	* 20 - Caps Lock
	* 32 - Space
	* 16 - Right & Left Shift
	* 17 - Right & Left Ctrl
	* S_ALT_KEY - Right & Left Alt
	* 8 - BackSpace
	* 13 - Enter
	* 93 - Option
	* 33 - Page Up
	* 34 - Page Down
	* 36 - Home
	* 35 - End
	* 46 - Delete
	* 220 - \
	* 189 - -_
	* 187 - =+
	* 16 - Shift
	* 45 - Inc
	* [112..123] - F1 -F12
	* }
var
	PKey:PByte = nil;
	NormalKey:Byte = 0;
begin
PKey := PByte(@VKey);
//WriteLn(PKey[0],'=',char(PKey[0]),' ',PKey[1],'=',char(PKey[1]));
case PKey[1] of
0://English
	begin
	(*
	[48..57] - 0..9
	32 - Space
	114 - R key
	33 - ! (1)
	64 - @ (2)
	35 - # (3)
	36 - $ (4)
	37 - % (5)
	94 - ^ (6)
	38 - & (7)
	42 - * (8)
	40 - ( (9)
	41 - ) (0)
	45 - -
	95 - _
	61 - =
	43 - +
	59 - ;
	*)
	case PKey[0] of
	65,97 :NormalKey:=65;//a A key
	66,98 :NormalKey:=66;//b B key
	67,99 :NormalKey:=67;//c C key
	68,100:NormalKey:=68;//d D key
	69,101:NormalKey:=69;//e E key
	70,102:NormalKey:=70;//f F key
	71,103:NormalKey:=71;//g G key
	72,104:NormalKey:=72;//h H key
	73,105:NormalKey:=73;//i I key
	74,106:NormalKey:=74;//j J key
	75,107:NormalKey:=75;//k K key
	76,108:NormalKey:=76;//l L key
	77,109:NormalKey:=77;//m M key
	78,110:NormalKey:=78;//n N key
	79,111:NormalKey:=79;//o O key
	80,112:NormalKey:=80;//p P key
	81,113:NormalKey:=81;//q Q key
	82,114:NormalKey:=82;//r R key
	83,115:NormalKey:=83;//s S key
	84,116:NormalKey:=84;//t T key
	85,117:NormalKey:=85;//u U key
	86,118:NormalKey:=86;//v V key
	87,119:NormalKey:=87;//w W key
	88,120:NormalKey:=88;//x X key
	89,121:NormalKey:=89;//y Y key
	90,122:NormalKey:=90;//z Z key
	
	
	32:NormalKey:=32;// Space
	92:NormalKey:=220;// \
	47:NormalKey:=191;// /
	// =====0..9====
	48,49,50,51,52,53,54,55,56,57: // - Normal
		NormalKey:=PKey[0];
	//With Shift
	41:NormalKey:=48;//0
	33:NormalKey:=49;//1
	64:NormalKey:=50;//2
	35:NormalKey:=51;//3
	36:NormalKey:=52;//4
	37:NormalKey:=53;//5
	94:NormalKey:=54;//6
	38:NormalKey:=55;//7
	42:NormalKey:=56;//8
	40:NormalKey:=57;//9
	
	end;
	end;
6://Russian
	begin
	case PKey[0] of
	176:NormalKey:=51;//Nomer ("3")
	end;
	
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
	80:NormalKey:=36;// Home
	87:NormalKey:=35;// End
	85:NormalKey:=33;// Page Up
	86:NormalKey:=34;// Page Down
	82:NormalKey:=38;// Up
	81:NormalKey:=37;// Left
	83:NormalKey:=39;// Right
	84:NormalKey:=40;// Down
	8:NormalKey:=8;// Backspace
	27:NormalKey:=27;// Escape
	13:NormalKey:=13;// Enter
	255:NormalKey:=46;// Delete
	225,226:NormalKey:=16;// Shift
	229:NormalKey:=20;// Caps Lock
	233,234:NormalKey:=S_ALT_KEY;//Alt
	227,228:NormalKey:=S_CTRL_KEY;//Ctrl
	end;
	end;
end;
if NormalKey<>0 then
	SetKey(VKeyType,NormalKey);
end;

function  TSContextLinux.GetWindow() : TSPointer;
begin
Result := TSPointer(win);
end;

function  TSContextLinux.GetDevice() : TSPointer;
begin
Result := TSPointer(dpy);
end;

function TSContextLinux.GetOption(const What:string):Pointer;
begin
if What='WINDOW HANDLE' then
	Result:=Pointer(win)
else if What='DESKTOP WINDOW HANDLE' then
	Result:=Pointer(dpy)
else if What = 'VISUAL INFO' then
	Result:=visinfo
else if @(inherited GetOption) <> nil then
	;//Result := inherited GetOption(What);
end;

procedure TSContextLinux.SetCursorPosition(const a: TSPoint2int32);
begin
if dpy = nil then
	dpy := XOpenDisplay(nil);
if (dpy=nil) or(win=0) then 
	Exit;
XSelectInput(dpy, RootWindow(dpy, 0), KeyReleaseMask);
XWarpPointer(dpy, win, win, 0, 0, 0, 0, a.x, a.y);
XFlush(dpy);
end;

procedure TSContextLinux.SetLinuxCursor(const VCursorPtr : TSLongWord; const VCursorVisibility : TSBoolean);

procedure CreateNullCursor();
var
	XCursor          : TCursor;
	bitmapNoData    : TPixmap;
	black           : TXColor;
	noData          : packed array[0..7] of byte = (0,0,0,0,0,0,0,0);
begin
black.red := 0;
black.green := 0;
black.blue :=0;
bitmapNoData    := XCreateBitmapFromData(dpy, win, PChar(@noData), 8, 8);
Xcursor := XCreatePixmapCursor(dpy, bitmapNoData, bitmapNoData, 
	@black, @black, 0, 0);
XDefineCursor(dpy,win, Xcursor);
XFreeCursor(dpy, Xcursor);
end;

procedure CreatePtrCursor(const VCursorPtr : TSLongWord);
var
	XCursor          : TCursor;
begin
Xcursor := XCreateFontCursor(dpy,VCursorPtr);
XDefineCursor(dpy, win, Xcursor);
XFreeCursor(dpy, Xcursor);
end;

begin
if dpy = nil then
	dpy := XOpenDisplay(nil);
if (dpy = nil) or (win=0) then
	Exit;
if VCursorVisibility and (VCursorPtr <> 0) then
	begin
	if (VCursorPtr <> FCursorPtr) or (VCursorVisibility <> FShowCursor) then
		begin
		CreatePtrCursor(VCursorPtr);
		FCursorPtr := VCursorPtr;
		end;
	end
else if VCursorVisibility and (VCursorPtr = 0) then
	begin
	if FCursor.StandartHandle <> SC_NULL then
		begin
		SetLinuxCursor(GetPtrCursor(FCursor.StandartHandle), FShowCursor);
		FCursorPtr := GetPtrCursor(FCursor.StandartHandle);
		end
	else
		begin
		SetBmpCursor(FCursor);
		FCursorPtr := 0;
		end;
	end
else
	begin
	CreateNullCursor();
	FCursorPtr := 0;
	end;
end;

procedure TSContextLinux.ShowCursor(const VVisibility : TSBoolean);
begin
SetLinuxCursor(FCursorPtr, VVisibility);
inherited;
end;

function TSContextLinux.GetScreenArea(): TSPoint2int32;
begin
if dpy = nil then
	dpy:=XOpenDisplay(nil);
if dpy = nil then
	begin
	Result.Import(0,0);
	Exit;
	end;
Result.Import(
	XWidthOfScreen(XScreenOfDisplay(dpy,0)),
	XHeightOfScreen(XScreenOfDisplay(dpy,0)));
end;

function TSContextLinux.GetCursorPosition(): TSPoint2int32;
begin
Result.Import(FCursorX,FCursorY)
end;

constructor TSContextLinux.Create();
const
	XC_left_ptr = 68;
begin
inherited;
dpy:=nil;
win:=0;
visinfo:=nil;
cm:=0;
FCursorY:=0;
FCursorX:=0;
FCursorPtr := XC_left_ptr;
end;

procedure TSContextLinux.Kill();
begin
if (win<>0) and (dpy<>nil) then
	begin
	XDestroyWindow(dpy,win);
	win:=0;
	end;
if dpy<>nil then
	begin
	XCloseDisplay(dpy);
	dpy:=nil;
	end;
end;

destructor TSContextLinux.Destroy();
begin
inherited;
end;

procedure TSContextLinux.Initialize(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal);
begin
Active:=CreateWindow();
if Active then
	inherited;
end;

procedure TSContextLinux.Run();
begin
Messages();
StartComputeTimer();
while FActive and (FNewContextType = nil) do
	Paint();
end;

procedure TSContextLinux.SwapBuffers();
begin
Render.SwapBuffers();
end;

procedure TSContextLinux.Messages();
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
		1:SetCursorKey(SDownKey,SLeftCursorButton);
		2:SetCursorKey(SDownKey,SMiddleCursorButton);
		3:SetCursorKey(SDownKey,SRightCursorButton);
		4:FCursorWheel:=SUpCursorWheel;
		5:FCursorWheel:=SDownCursorWheel;
		end;
		end;
	ButtonRelease:
		begin
		case Event.XButton.Button of
		1:SetCursorKey(SUpKey,SLeftCursorButton);
		2:SetCursorKey(SUpKey,SMiddleCursorButton);
		3:SetCursorKey(SUpKey,SRightCursorButton);
		end;
		end;
	KeyPress:
		begin
		XLookupString(@Event.Xkey,@s,sizeof(s),@KeySum,nil);
		SetUnixKey(Keysum,SDownKey);
		end;
	KeyRelease:
		begin
		XLookupString(@Event.Xkey,@s,sizeof(s),@KeySum,nil);
		SetUnixKey(Keysum,SUpKey);
		end;
	DestroyNotify:
		begin
		SLog.Source('TSContextLinux__Messages : Note : Window is closed for API.');
		Active:=False;
		end;
	end;
	end;
inherited;
end;

function TSContextLinux.CreateWindow():Boolean;
var
	errorBase,eventBase: integer;
	window_title_property: TXTextProperty;
		winAttr: TXSetWindowAttributes;
var
	attr: Array[0..10] of integer = (GLX_RGBA,GLX_RED_SIZE,8,GLX_GREEN_SIZE,8,GLX_BLUE_SIZE,8,GLX_DEPTH_SIZE,24,GLX_DOUBLEBUFFER,none);
	Name:PChar = nil;
begin 
Result:=False;
if dpy = nil then
	dpy := XOpenDisplay(nil);
if dpy = nil then
	begin
	SLog.Source('TSContextLinux__CreateWindow : Error : Could not connect to X server!');
	Exit;
	end;
if not (glXQueryExtension(dpy,errorBase,eventBase)) then
	begin
	SLog.Source('TSContextLinux__CreateWindow : Error : GLX extension not supported!');
	Exit;
	end;
visinfo := glXChooseVisual(dpy,DefaultScreen(dpy), Attr);
if(visinfo = nil) then
	begin
	SLog.Source('TSContextLinux__CreateWindow : Error : Could not find visual!');
	Exit;
	end;
cm := XCreateColormap(dpy,RootWindow(dpy,visinfo^.screen),visinfo^.visual,AllocNone);
FillChar(winAttr,sizeof(winAttr),0);
winAttr.colormap := cm;
winAttr.border_pixel := 0;
winAttr.background_pixel := 0;
winAttr.event_mask := ExposureMask or PointerMotionMask or ButtonPressMask or ButtonReleaseMask or StructureNotifyMask or KeyPressMask or KeyReleaseMask;
win := XCreateWindow(dpy,RootWindow(dpy,visinfo^.screen),FLeft,FTop,FWidth,FHeight,0,visinfo^.depth,
	InputOutput,visinfo^.visual,CWBorderPixel or CWColormap or CWEventMask,@winAttr);
if win = 0 then
	begin
	SLog.Source('TSContextLinux__CreateWindow : Error : Could not create window!');
	Exit;
	end;
Name := SStringAsPChar(FTitle);
XStringListToTextProperty(@Name,1,@window_title_property);
XSetWMName(dpy,win,@window_title_property);
if FRender=nil then
	begin
	FRender:=FRenderClass.Create();
	FRender.Context := Self as ISContext;
	Result:=FRender.CreateContext();
	if Result then 
		FRender.Init();
	
	XMapWindow(dpy,win);
	end
else
	begin
	FRender.Context := Self as ISContext;
	Result := FRender.SetPixelFormat();
	if Result then
		Render.MakeCurrent();
	end;
if FullScreen then
	begin
	FFullscreen:=False;
	FullScreen:=True;
	end;
end;

procedure TSContextLinux.InitFullscreen(const b:boolean); 
var
	Event:TXEvent;
begin
if FullScreen<>b then
	begin
	if win <> 0 then
		if b then
			begin
			XMoveWindow(dpy, win, 0, 0);
			XFlush(dpy);
			
			FillChar(Event,SizeOf(Event),0);
			event._type := ClientMessage;
			event.xclient.window := win;
			event.xclient.display := dpy;
			event.xclient.format := 32; // Data is 32-bit longs
			event.xclient.message_type := XInternAtom( dpy, '_NET_WM_STATE', false );
			event.xclient.data.l[0] := 1;
			event.xclient.data.l[1] := XInternAtom( dpy, '_NET_WM_STATE_FULLSCREEN', false );
			event.xclient.data.l[2] := 0; // No secondary property
			event.xclient.data.l[3] := 1; // Sender is a normal application

			XSendEvent(dpy,
			   RootWindow(dpy,visinfo^.screen),
			   False,
			   SubstructureNotifyMask or SubstructureRedirectMask,
			   @event);
			end
		else
			begin
			FillChar(Event,SizeOf(Event),0);
			
			event._type := ClientMessage;
			event.xclient.window := win;
			event.xclient.display := dpy;
			event.xclient.format := 32; // Data is 32-bit longs
			event.xclient.message_type := XInternAtom( dpy, '_NET_WM_STATE', false );
			event.xclient.data.l[0] := 0;
			event.xclient.data.l[1] := XInternAtom( dpy, '_NET_WM_STATE_FULLSCREEN', false );
			event.xclient.data.l[2] := 0; // No secondary property
			event.xclient.data.l[3] := 1; // Sender is a normal application
			
			XSendEvent(dpy,
			   RootWindow(dpy,visinfo^.screen),
			   False,
			   SubstructureNotifyMask or SubstructureRedirectMask,
			   @event);
			end;
	inherited InitFullscreen(b);
	end;
end;

end.
