{$IFDEF SGREADINTERFACE}
type
	TSGContextLazarusForm=class(TForm)
			public
		constructor Create(AOwner: TComponent); override;
			public
		Panel1:TPanel;
		ApplicationEvents1:TApplicationProperties;
			public
		procedure Form1create(Sender: TObject);
		procedure Form1resize(Sender: TObject);
		procedure Form1destroy(Sender: TObject);
		procedure FromPaint(Sender: TObject;var Done:Boolean);
		procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
		procedure FormMouseUp(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
		procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;  MousePos: TPoint; var Handled: Boolean);
		procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;  MousePos: TPoint; var Handled: Boolean);
		end;
	TSGContextLazarus=class(TSGContext)
			public
		constructor Create;
		destructor Destroy;override;
			public
		procedure Initialize;override;
		procedure Run;override;
		procedure Messages;override;
		procedure SwapBuffers;override;
		class function TopShift:LongWord;override;
		function GetCursorPosition:TSGPoint2f;override;
		function GetWindowRect:TSGPoint2f;override;
		function GetScreenResolution:TSGPoint2f;override;
		procedure Resize;override;
		class function MouseShift:TSGPoint2f;override;
			public
		rc : HGLRC;  
		dc  : HDC;
		Form1:TSGContextLazarusForm;
		end;
{$ENDIF}


{$IFDEF SGREADIMPLEMENTATION}

class function TSGContextLazarus.MouseShift:TSGPoint2f;
begin
Result.Import(
{$IFDEF MSWINDOWS}
	-7,-30
{$ELSE}
	-3,-25
	{$ENDIF}
	);
end;

procedure TSGContextLazarus.Resize;
begin
inherited;
end;


procedure TSGContextLazarusForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
SGContext.FKeyPressed:=Key;
SGContext.FKeyPressedType:=SGDownKey;
SGContext.FKeysPressed[Key]:=True;
end;

procedure TSGContextLazarusForm.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
SGContext.FKeyPressed:=Key;
SGContext.FKeyPressedType:=SGUpKey;
SGContext.FKeysPressed[Key]:=False;
end;

procedure TSGContextLazarusForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
	Bnt:TSGCursorButtons;
begin
case Button of
mbLeft:
	Bnt:=SGLeftCursorButton;
mbRight:
	Bnt:=SGRightCursorButton;
mbMiddle:
	Bnt:=SGMiddleCursorButton;
end;
SGContext.FCursorKeyPressed:=Bnt;
SGContext.FCursorKeyPressedType:=SGDownKey;
SGContext.FCursorKeysPressed[Bnt]:=True;
end;

procedure TSGContextLazarusForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
	Bnt:TSGCursorButtons;
begin
case Button of
mbLeft:
	Bnt:=SGLeftCursorButton;
mbRight:
	Bnt:=SGRightCursorButton;
mbMiddle:
	Bnt:=SGMiddleCursorButton;
end;
SGContext.FCursorKeyPressed:=Bnt;
SGContext.FCursorKeyPressedType:=SGUpKey;
SGContext.FCursorKeysPressed[Bnt]:=False;
end;

procedure TSGContextLazarusForm.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
SGContext.FCursorWheel:=SGUpCursorWheel;
end;

procedure TSGContextLazarusForm.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
SGContext.FCursorWheel:=SGDownCursorWheel;
end;

procedure TSGContextLazarusForm.Form1create(Sender: TObject);
var pfd : TPIXELFORMATDESCRIPTOR;
    pf  : Integer;
begin
Caption:=SGContext.Tittle;
Height:=SGContext.Height-20;
Width:=SGContext.Width - 20;

ClientHeight:=Height;
ClientWidth:= Width;

Left:=(SGContext.GetScreenResolution.x-SGContext.Width-20) div 2;
Top:=(SGContext.GetScreenResolution.y - SGContext.Height-20) div 2;
Color:=clBtnFace;
Font.Color:=clWindowText;
Font.Height := -11;
Font.Name := 'Tahoma';

Position := poDesktopCenter;
LCLVersion := '1.0.2.0';

Visible := True;

ApplicationEvents1:=TApplicationProperties.Create(Self);
ApplicationEvents1.OnIdle:=@FromPaint;
ApplicationEvents1.Tag:=0;

Panel1:=TPanel.Create(Self);
Panel1.Parent:=Self;
Panel1.Height:=SGContext.Height;
Panel1.Width:=SGContext.Width;
Panel1.TabOrder:=0;
Panel1.Align := alClient;
Panel1.Color := clBlack;
Panel1.Visible:=True;

with TSGContextLazarus(Pointer(SGContext)) do
	begin
	dc:=GetDC(Panel1.Handle);
	pfd.nSize:=sizeof(pfd);
	pfd.nVersion:=1;
	pfd.dwFlags:=PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER or 0;
	pfd.iPixelType:=PFD_TYPE_RGBA;
	pfd.cColorBits:=32;
	pfd.cDepthBits    := 24;
	pf :=ChoosePixelFormat(dc, @pfd);
	SetPixelFormat(dc, pf, @pfd);
	rc :=wglCreateContext(dc);
	wglMakeCurrent(dc,rc);
	end;
{$IFDEF MSWINDOWS}
  Icon.Handle:=(LoadIcon(GetModuleHandle(nil),PChar(SGContext.IconIdentifier)));
  Screen.Cursors[crDefault]:=LoadCursor(GetModuleHandle(nil),PCHAR(SGContext.CursorIdentifier));
  {$ENDIF}
with Panel1 do
	begin
	OnKeyDown:=@FormKeyDown;
	OnKeyUp:=@FormKeyUp; 
	OnMouseDown:=@FormMouseDown;
	OnMouseUp:=@FormMouseUp;
	OnMouseWheelDown:=@FormMouseWheelDown;
	OnMouseWheelUp:=@FormMouseWheelUp;
	end;
SGInitOpenGL;

if SGContext.FCallInitialize<>nil then
	SGContext.FCallInitialize();
mmtimeAlloc;
end;

procedure TSGContextLazarusForm.Form1resize(Sender: TObject);
begin
SGContext.Width:=Panel1.Width;
SGContext.Height:=panel1.Height;
SGContext.Resize;
end;

procedure TSGContextLazarusForm.Form1destroy(Sender: TObject);
begin
if SGContext<>nil then
   SGContext.Active:=False;

//SGContext:=nil;
//Halt(0);
end;

procedure TSGContextLazarusForm.FromPaint(Sender: TObject;var Done:Boolean);
begin
mmtimeElapsed;
glClear(GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT);
SGInitMatrixMode(SG_3D);
if SGContext.FCallDraw<>nil then
	SGContext.FCallDraw();
SGIIdleFunction;
if SGCLPaintProcedure<>nil then
	SGCLPaintProcedure;
SGContext.SwapBuffers;
SGContext.ClearKeys;
SGContext.Messages;
end;

constructor TSGContextLazarusForm.Create(AOwner: TComponent);
begin
OnCreate := @Form1create;
OnDestroy := @Form1destroy;
OnResize := @Form1resize;
//OnPaint:=@FromPaint;
inherited Create(AOwner);
end;

constructor TSGContextLazarus.Create;
begin
inherited;
rc:=0;
dc:=0;
end;

destructor TSGContextLazarus.Destroy;
begin
Form1.Destroy;
inherited;
end;

procedure TSGContextLazarus.Initialize;
begin
Application.Initialize; 
Application.CreateForm(TSGContextLazarusForm, Form1);
end;

procedure TSGContextLazarus.Run;
begin
Application.Run;
end;

procedure TSGContextLazarus.Messages;
begin
inherited;

end;

procedure TSGContextLazarus.SwapBuffers;
begin
Windows.SwapBuffers(DC);
end;

class function TSGContextLazarus.TopShift:LongWord;
begin
Result:=0;
end;

function TSGContextLazarus.GetCursorPosition:TSGPoint2f;
begin
Result.Import(
	Mouse.CursorPos.x,
	Mouse.CursorPos.y);
end;

function TSGContextLazarus.GetWindowRect:TSGPoint2f;
begin
Result.Import(Form1.Left,Form1.Top);
end;

function TSGContextLazarus.GetScreenResolution:TSGPoint2f;
begin
Result.Import(Screen.Width,Screen.Height);
end;

{$ENDIF}
