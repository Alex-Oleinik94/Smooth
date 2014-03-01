{$INCLUDE Includes\SaGe.inc}
unit SaGeContextLinux;
interface

uses 
	SaGeBase
	,SaGeBased
	,SaGeCommon
	,SaGeRender
	,SaGeContext
	,unix
	,x
	,xlib
	,xutil
	,glx
	;
type
	TSGContextLinux=class(TSGContext)
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

procedure TSGContextLinux.SetUnixKey(const VKey:word; const VKeyType:TSGCursorButtonType);
{
	* }(*WinAPI Codes*){
	* 8 - Tab
	* 20 - Caps Lock
	* 32 - Space
	* 16 - Right & Left Shift
	* 17 - Right & Left Ctrl
	* SG_ALT_KEY - Right & Left Alt
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
//WriteLn(PKey[0],' ',PKey[1]);
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
	233,234:NormalKey:=SG_ALT_KEY;//Alt
	227,228:NormalKey:=SG_CTRL_KEY;//Ctrl
	end;
	end;
end;
if NormalKey<>0 then
	SetKey(VKeyType,NormalKey);
end;

function TSGContextLinux.Get(const What:string):Pointer;
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

procedure TSGContextLinux.SetCursorPosition(const a:TSGPoint2f);
begin
SGLog.Sourse('"TSGContextLinux.SetCursorPosition" isn''t possible!');
end;

procedure TSGContextLinux.ShowCursor(const b:Boolean);
begin
SGLog.Sourse('"TSGContextLinux.ShowCursor" isn''t possible!');
end;

function TSGContextLinux.GetScreenResolution:TSGPoint2f;
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

function TSGContextLinux.GetCursorPosition:TSGPoint2f;
begin
Result.Import(FCursorX,FCursorY)
end;

function TSGContextLinux.GetWindowRect():TSGPoint2f;
begin
Result.Import();
end;

constructor TSGContextLinux.Create();
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

destructor TSGContextLinux.Destroy();
begin
XCloseDisplay(dpy);
inherited;
end;

procedure TSGContextLinux.Initialize();
begin
Active:=CreateWindow();
if Active then
	begin
	if SGScreenLoadProcedure<>nil then
		SGScreenLoadProcedure(Self);
	if FCallInitialize<>nil then
		FCallInitialize(Self);
	end;
end;

procedure TSGContextLinux.Run;
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
		FCallDraw(Self);
	//SGIIdleFunction;
	
	ClearKeys();
	Messages();
	
	if SGScreenPaintProcedure<>nil then
		SGScreenPaintProcedure(Self);
	SwapBuffers();
	end;
end;

procedure TSGContextLinux.SwapBuffers();
begin
Render.SwapBuffers();
end;

procedure TSGContextLinux.Messages();
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
		4:FCursorWheel:=SGUpCursorWheel;
		5:FCursorWheel:=SGDownCursorWheel;
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
		SGLog.Sourse('TSGContextLinux__Messages : Note : Window is closed for API.');
		Active:=False;
		end;
	end;
	end;
inherited;
end;



function TSGContextLinux.CreateWindow():Boolean;
var
	errorBase,eventBase: integer;
	window_title_property: TXTextProperty;
var
	attr: Array[0..10] of integer = (GLX_RGBA,GLX_RED_SIZE,8,GLX_GREEN_SIZE,8,GLX_BLUE_SIZE,8,GLX_DEPTH_SIZE,24,GLX_DOUBLEBUFFER,none);
	Name:PChar = nil;
begin 
Result:=False;
dpy := XOpenDisplay(nil);
if dpy = nil then
	begin
	SGLog.Sourse('TSGContextLinux__CreateWindow : Error : Could not connect to X server!');
	Exit;
	end;
if not (glXQueryExtension(dpy,errorBase,eventBase)) then
	begin
	SGLog.Sourse('TSGContextLinux__CreateWindow : Error : GLX extension not supported!');
	Exit;
	end;
visinfo := glXChooseVisual(dpy,DefaultScreen(dpy), Attr);
if(visinfo = nil) then
	begin
	SGLog.Sourse('TSGContextLinux__CreateWindow : Error : Could not find visual!');
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
	SGLog.Sourse('TSGContextLinux__CreateWindow : Error : Could not create window!');
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
procedure TSGContextLinux.InitFullscreen(const b:boolean); 
begin

inherited InitFullscreen(b);

end;

end.
