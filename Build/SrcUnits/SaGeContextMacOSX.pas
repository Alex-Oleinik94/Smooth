{$INCLUDE Includes\SaGe.inc}
unit SaGeContextMacOSX;

interface

uses 
	SaGeBase
	,SaGeBased
	,SaGeCommon
	,SaGeRender
	,SaGeContext
	,MacOSAll
	,unix
	,agl;
	
type
	TSGContextMacOSX=class(TSGContext)
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
		procedure SetTittle(const NewTittle:TSGString);override;
			public
		wnd_Handle  : WindowRef;
		function  CreateWindow():Boolean;
			public
		function Get(const What:string):Pointer;override;
		end;
implementation

procedure TSGContextMacOSX.SetTittle(const NewTittle:TSGString);
begin
inherited SetTittle(NewTittle);
end;

function TSGContextMacOSX.Get(const What:string):Pointer;
begin
IF What='DESKTOP WINDOW HANDLE' then
	Result:=Pointer(wnd_Handle)
else
	Result:=Inherited Get(What);
end;

procedure TSGContextMacOSX.SetCursorPosition(const a:TSGPoint2f);
begin
SGLog.Sourse('"TSGContextMacOSX.SetCursorPosition" isn''t possible!');
end;

procedure TSGContextMacOSX.ShowCursor(const b:Boolean);
begin
SGLog.Sourse('"TSGContextMacOSX.ShowCursor" isn''t possible!');
end;

function TSGContextMacOSX.GetScreenResolution:TSGPoint2f;
begin
Result.Import(
	CGDisplayPixelsWide(CGMainDisplayID()),
	CGDisplayPixelsHigh(CGMainDisplayID())
);
end;

function TSGContextMacOSX.GetCursorPosition:TSGPoint2f;
begin

end;

function TSGContextMacOSX.GetWindowRect():TSGPoint2f;
begin
Result.Import();
end;

constructor TSGContextMacOSX.Create();
begin
inherited;
wnd_Handle:=nil;
end;

destructor TSGContextMacOSX.Destroy();
begin
ReleaseWindow( wnd_Handle );
inherited;
end;

procedure TSGContextMacOSX.Initialize();
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

procedure TSGContextMacOSX.Run();
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

procedure TSGContextMacOSX.SwapBuffers();
begin
Render.SwapBuffers();
end;

procedure TSGContextMacOSX.Messages();
var
	Event : EventRecord;
begin
while GetNextEvent( everyEvent, Event ) do
	begin
	
	end;
inherited;
end;

function TSGContextMacOSX.CreateWindow():Boolean;
var
	size   : MAcOSAll.Rect;
	status : OSStatus;
	ScreenRS:TSGPoint2f;
begin 
Result:=agl.InitAGL();
if not Result then
	Exit;
ScreenRS:=GetScreenResolution();
size.Left   := (ScreenRS.x-FWidth) div 2;
size.Top    := (ScreenRS.y-FHeight) div 2;
size.Right  := FWidth + (ScreenRS.x-FWidth) div 2;
size.Bottom := FHeight + (ScreenRS.y-FHeight) div 2;
status      := CreateNewWindow( kDocumentWindowClass, 
	kWindowCloseBoxAttribute or kWindowCollapseBoxAttribute or kWindowStandardHandlerAttribute, 
	size, wnd_Handle );
if ( status <> noErr ) or ( wnd_Handle = nil ) Then
	Exit;
SelectWindow( wnd_Handle );
ShowWindow( wnd_Handle );
if FRender=nil then
	begin
	FRender:=FRenderClass.Create();
	FRender.Window:=Self;
	Result:=FRender.CreateContext();
	if Result then 
		FRender.Init();
	end
else
	begin
	FRender.Window:=Self;
	Result:=FRender.SetPixelFormat();
	if Result then
		Render.MakeCurrent();
	end;
SetWTitle(wnd_Handle,FTitle);
end;

procedure TSGContextMacOSX.InitFullscreen(const b:boolean); 
begin

inherited InitFullscreen(b);

end;

end.
