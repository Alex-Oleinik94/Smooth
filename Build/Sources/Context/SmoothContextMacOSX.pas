{$INCLUDE Smooth.inc}

unit SmoothContextMacOSX;

interface

uses 
	 SmoothBase
	,SmoothCommon
	,SmoothRender
	,SmoothContext
	,SmoothContextUtils
	,SmoothBaseClasses
	,SmoothContextClasses
	,SmoothContextInterface
	
	,MacOSAll
	,unix
	,agl
	;
	
type
	TSContextMacOSX = class(TSContext)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		class function ContextName() : TSString; override;
		procedure Initialize(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal); override;
		procedure Run(); override;
		procedure Messages(); override;
		procedure SwapBuffers(); override;
		function  GetCursorPosition() : TSPoint2f; override;
		function  GetWindowRect() : TSPoint2f; override;
		function  GetScreenResolution() : TSPoint2f; override;
		class function Supported() : TSBoolean; override;
			protected
		procedure InitFullscreen(const b : TSBoolean); override;
			public
		procedure ShowCursor(const b : TSBoolean); override;
		procedure SetCursorPosition(const a : TSPoint2f); override;
		procedure SetTittle(const NewTittle : TSString); override;
			public
		wnd_Handle  : WindowRef;
		function  CreateWindow() : TSBoolean;
			public
		function Get(const What : TSString) : TSPointer; override;
		end;

implementation

uses
	 SmoothScreen
	;

class function TSContextMacOSX.ContextName() : TSString;
begin
Result := 'Mac OS X';
end;

class function TSContextMacOSX.Supported() : TSBoolean;
begin
Result := True;
end;

procedure TSContextMacOSX.SetTittle(const NewTittle : TSString);
begin
inherited SetTittle(NewTittle);
end;

function TSContextMacOSX.Get(const What : TSString) : TSPointer;
begin
IF (What = 'DESKTOP WINDOW HANDLE') then
	Result := TSPointer(wnd_Handle)
else
	Result := inherited Get(What);
end;

procedure TSContextMacOSX.SetCursorPosition(const a : TSPoint2f);
begin
SLog.Source('"TSContextMacOSX.SetCursorPosition" isn''t possible!');
end;

procedure TSContextMacOSX.ShowCursor(const b : TSBoolean);
begin
SLog.Source('"TSContextMacOSX.ShowCursor" isn''t possible!');
end;

function TSContextMacOSX.GetScreenResolution() : TSPoint2f;
begin
Result.Import(
	CGDisplayPixelsWide(CGMainDisplayID()),
	CGDisplayPixelsHigh(CGMainDisplayID()));
end;

function TSContextMacOSX.GetCursorPosition() : TSPoint2f;
begin

end;

function TSContextMacOSX.GetWindowRect() : TSPoint2f;
begin
Result.Import();
end;

constructor TSContextMacOSX.Create();
begin
inherited;
wnd_Handle := nil;
end;

destructor TSContextMacOSX.Destroy();
begin
ReleaseWindow(wnd_Handle);
inherited;
end;

procedure TSContextMacOSX.Initialize(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal);
begin
Active := CreateWindow();
if Active then
	begin
	SScreen.Load(Self);
	if (FCallInitialize <> nil) then
		FCallInitialize(Self);
	end;
end;

procedure TSContextMacOSX.Run();
begin
Messages();
FElapsedDateTime.Get();
while (FActive and (FNewContextType = nil)) do
	Paint();
end;

procedure TSContextMacOSX.SwapBuffers();
begin
Render.SwapBuffers();
end;

procedure TSContextMacOSX.Messages();
var
	Event : EventRecord;
begin
while GetNextEvent(everyEvent, Event) do
	begin
	
	end;
inherited;
end;

function TSContextMacOSX.CreateWindow() : TSBoolean;
var
	size     : MAcOSAll.Rect;
	status   : OSStatus;
	ScreenRS : TSPoint2f;
begin 
Result := agl.InitAGL();
if not Result then
	Exit;
ScreenRS := GetScreenResolution();
size.Left   := (ScreenRS.x - FWidth) div 2;
size.Top    := (ScreenRS.y - FHeight) div 2;
size.Right  := FWidth + (ScreenRS.x-FWidth) div 2;
size.Bottom := FHeight + (ScreenRS.y-FHeight) div 2;
status      := CreateNewWindow(kDocumentWindowClass, 
	kWindowCloseBoxAttribute or kWindowCollapseBoxAttribute or kWindowStandardHandlerAttribute, 
	size, wnd_Handle);
if (status <> noErr) or (wnd_Handle = nil) Then
	Exit;
SelectWindow(wnd_Handle);
ShowWindow(wnd_Handle);
if (FRender = nil) then
	begin
	FRender := FRenderClass.Create();
	FRender.Window := Self;
	Result := FRender.CreateContext();
	if (Result) then 
		FRender.Init();
	end
else
	begin
	FRender.Window := Self;
	Result := FRender.SetPixelFormat();
	if (Result) then
		Render.MakeCurrent();
	end;
SetWTitle(wnd_Handle, FTitle);
end;

procedure TSContextMacOSX.InitFullscreen(const b : TSBoolean); 
begin
inherited InitFullscreen(b);
end;

end.
