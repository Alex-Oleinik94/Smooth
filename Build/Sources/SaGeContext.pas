{$INCLUDE SaGe.inc}

//{$DEFINE CONTEXT_DEBUGING}

unit SaGeContext;

interface
uses
	SaGeBase
	,SaGeBased
	,SaGeCommon
	,Classes
	,SysUtils
	,crt
	,SaGeRender
	,SaGeRenderConstants
	,SaGeCommonClasses
	,SaGeClasses
	,SaGeImagesBase
	{$IFDEF LAZARUS}
		,Interfaces,
		LMessages,
		Messages,
		Variants,
		Graphics,
		Buttons,
		Menus,
		ComCtrls,
		LCLIntf,
		LCLType,
		Extctrls,
		Controls
		,Forms
		,_mmtime
		{$ENDIF}
	;
const
	SG_ALT_KEY = 18;
	SG_CTRL_KEY = 17;
	SG_SHIFT_KEY = 16;
	SG_ESC_KEY = 27;
	SG_ESCAPE_KEY = SG_ESC_KEY;
type
	TSGCursorButtons =            SaGeCommonClasses.TSGCursorButtons;
	TSGCursorButtonType =         SaGeCommonClasses.TSGCursorButtonType;
	TSGCursorWheel =              SaGeCommonClasses.TSGCursorWheel;
	TSGCursorPosition =           SaGeCommonClasses.TSGCursorPosition;
const
	 SGDeferenseCursorPosition =  SaGeCommonClasses.SGDeferenseCursorPosition; // - Это разница между SGNowCursorPosition и SGLastCursorPosition
	 SGNowCursorPosition =        SaGeCommonClasses.SGNowCursorPosition;       // - Координаты мыши в настоящий момент
	 SGLastCursorPosition =       SaGeCommonClasses.SGLastCursorPosition;      // - Координаты мыши, полученые при преведущем этапе цикла
	 SGNullCursorButton =         SaGeCommonClasses.SGNullCursorButton;
	 
	 SGMiddleCursorButton =       SaGeCommonClasses.SGMiddleCursorButton;
	 SGLeftCursorButton =         SaGeCommonClasses.SGLeftCursorButton;
	 SGRightCursorButton =        SaGeCommonClasses.SGRightCursorButton;
	 
	 SGDownKey =                  SaGeCommonClasses.SGDownKey;
	 SGUpKey =                    SaGeCommonClasses.SGUpKey;
	 
	 SGNullCursorWheel =          SaGeCommonClasses.SGNullCursorWheel;
	 SGUpCursorWheel =            SaGeCommonClasses.SGUpCursorWheel;
	 SGDownCursorWheel =          SaGeCommonClasses.SGDownCursorWheel;
type
	TSGContext = class;
	PSGContext = ^ TSGContext;
	TSGContextClass = class of TSGContext;
	TSGContextProcedure = procedure(const a:TSGContext);
	
	TSGContext = class(TSGNamed, ISGContext)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		procedure Initialize();virtual;
		procedure Run();virtual;
		procedure Messages();virtual;
		procedure Paint();virtual;
		procedure UpdateTimer();virtual;
		procedure Resize();virtual;
		procedure Close();virtual;
		function ShiftClientArea() : TSGPoint2f; virtual;
		procedure SwapBuffers();virtual;
		procedure SetRenderClass(const NewRender : TSGPointer);virtual;
		procedure Kill();virtual;
			public
		procedure ShowCursor(const VVisibility : TSGBoolean);virtual;
		function GetCursorPosition():TSGPoint2f;virtual;abstract;
		procedure SetCursorPosition(const VPosition : TSGPoint2f);virtual;abstract;
		function GetWindowArea():TSGPoint2f;virtual;abstract;
		function GetScreenArea():TSGPoint2f;virtual;abstract;
		function GetClientArea():TSGPoint2f;virtual;abstract;
		function GetClientAreaShift() : TSGPoint2f;virtual;abstract;
			protected
		FActive          : TSGBoolean;
		FInitialized     : TSGBoolean;
		FWidth, FHeight  : TSGLongWord;
		FFullscreen      : TSGBoolean;
		FTitle           : TSGString;
		FElapsedTime     : TSGLongWord;
		FElapsedDateTime : TSGDateTime;
		FShowCursor      : TSGBoolean;
		FIcon            : TSGBitMap;
		FCursor          : TSGCursor;
			protected
		FPaintWithHandlingMessages : TSGBoolean;
			protected
		procedure ReinitializeRender();virtual;
		function  GetRender() : ISGRender;virtual;
		procedure StartComputeTimer();virtual;
		function  GetElapsedTime() : TSGLongWord;virtual;
		function  GetTitle() : TSGString;virtual;
		procedure SetTitle(const VTitle : TSGString);virtual;
		function  GetWidth() : TSGLongWord;virtual;
		function  GetHeight() : TSGLongWord;virtual;
		procedure SetWidth(const VWidth : TSGLongWord);virtual;
		procedure SetHeight(const VHeight : TSGLongWord);virtual;
		function  GetLeft() : TSGLongWord;virtual;
		function  GetTop() : TSGLongWord;virtual;
		procedure SetLeft(const VLeft : TSGLongWord);virtual;
		procedure SetTop(const VTop : TSGLongWord);virtual;
		function  GetFullscreen() : TSGBoolean;virtual;
		procedure InitFullscreen(const VFullscreen : TSGBoolean);virtual;
		procedure SetActive(const VActive : TSGBoolean);virtual;
		function  GetActive():TSGBoolean;virtual;
		procedure SetCursorCentered(const VCentered : TSGBoolean);virtual;
		function  GetCursorCentered() : TSGBoolean;virtual;
		procedure SetSelfLink(const VLink : PISGContext);virtual;
		function  GetSelfLink() : PISGContext;virtual;
		function  GetCursor():TSGCursor;virtual;
		procedure SetCursor(const VCursor : TSGCursor);virtual;
		function  GetIcon():TSGBitMap;virtual;
		procedure SetIcon(const VIcon : TSGBitMap);virtual;
		
		function  GetClientWidth() : TSGLongWord;virtual;abstract;
		function  GetClientHeight() : TSGLongWord;virtual;abstract;
		function  GetOption(const VName : TSGString) : TSGPointer;virtual;abstract;
		procedure SetOption(const VName : TSGString; const VValue : TSGPointer);virtual;abstract;
		procedure SetClientWidth(const VClientWidth : TSGLongWord);virtual;abstract;
		procedure SetClientHeight(const VClientHeight : TSGLongWord);virtual;abstract;
		function  GetWindow() : TSGPointer;virtual;abstract;
		function  GetDevice() : TSGPointer;virtual;abstract;
		function FileOpenDialog(const VTittle: TSGString; const VFilter : TSGString) : TSGString; virtual;abstract;
		function FileSaveDialog(const VTittle: TSGString; const VFilter : TSGString;const Extension : TSGString) : TSGString; virtual;abstract;
			public
		property SelfLink : PISGContext read GetSelfLink write SetSelfLink;
		property Fullscreen : TSGBoolean read GetFullscreen write InitFullscreen;
		property Active : TSGBoolean read GetActive write SetActive;
		property Cursor : TSGCursor read GetCursor write SetCursor;
		property Icon : TSGBitMap read GetIcon write SetIcon;
		property Left : TSGLongWord read GetLeft write SetLeft;
		property Top : TSGLongWord read GetTop write SetTop;
		property Width : TSGLongWord read GetWidth write SetWidth;
		property Height : TSGLongWord read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		property Render : ISGRender read GetRender;
		property ElapsedTime : TSGLongWord read GetElapsedTime;
		property CursorCentered : TSGBoolean read GetCursorCentered write SetCursorCentered;
		property Device : TSGPointer read GetDevice;
		property Window : TSGPointer read GetWindow;
		property ClientWidth : TSGLongWord read GetClientWidth write SetClientWidth;
		property ClientHeight : TSGLongWord read GetClientHeight write SetClientHeight;
			protected
		FKeysPressed      : packed array [0..255] of TSGBoolean;
		FKeyPressed       : TSGLongWord;
		FKeyPressedType   : TSGCursorButtonType;
		
		FCursorPosition       : packed array [TSGCursorPosition] of TSGPoint2f;
		FCursorKeyPressed     : TSGCursorButtons;
		FCursorKeyPressedType : TSGCursorButtonType;
		FCursorKeysPressed    : packed array [SGMiddleCursorButton..SGRightCursorButton] of TSGBoolean;
		FCursorWheel          : TSGCursorWheel;
		FCursorInCenter       : TSGBoolean;
			public
		function KeysPressed(const  Index : TSGInteger ) : TSGBoolean;virtual;overload;
		function KeysPressed(const  Index : TSGChar ) : Boolean;virtual;overload;
		function KeyPressed():TSGBoolean;virtual;
		function KeyPressedType():TSGCursorButtonType;virtual;
		function KeyPressedChar():TSGChar;virtual;
		function KeyPressedByte():TSGLongWord;virtual;
		procedure ClearKeys();virtual;
		function CursorKeyPressed():TSGCursorButtons;virtual;
		function CursorKeyPressedType():TSGCursorButtonType;virtual;
		function CursorKeysPressed(const Index : TSGCursorButtons ):TSGBoolean;virtual;
		function CursorWheel():TSGCursorWheel;virtual;
		function CursorPosition(const Index : TSGCursorPosition = SGNowCursorPosition ) : TSGPoint2f;virtual;
		
		procedure SetKey(ButtonType:TSGCursorButtonType;Key:TSGLongInt);virtual;
		procedure SetCursorKey(ButtonType:TSGCursorButtonType;Key:TSGCursorButtons);virtual;
		procedure SetCursorWheel(const VCursorWheel : TSGCursorWheel);virtual;
			public
		procedure CopyInfo(const C : ISGContext);virtual;
			protected
		FNewContextType : TSGContextClass;
		FRenderClass    : TSGRenderClass;
		FRenderClassChanget : TSGBoolean;
		FRender         : TSGRender;
		FSelfLink       : PISGContext;
		FPaintableClass : TSGDrawableClass;
		FPaintable       : TSGDrawable;
			public
		property Paintable : TSGDrawableClass write FPaintableClass;
		property RenderClass : TSGPointer write SetRenderClass;
		end;

{$DEFINE SGREADINTERFACE}
{$IFDEF GLUT}
	{$I Includes\SaGeContextGLUT.inc}
	{$ENDIF}
{$IFDEF LAZARUS}
	{$I Includes\SaGeContextLazarus.inc}
	{$ENDIF}
{$UNDEF SGREADINTERFACE}

implementation

uses
	SaGeScreen;

{$DEFINE SGREADIMPLEMENTATION}
{$IFDEF GLUT}
	{$I Includes\SaGeContextGLUT.inc}
	{$ENDIF}
{$IFDEF LAZARUS}
	{$I Includes\SaGeContextLazarus.inc}
	{$ENDIF}
{$UNDEF SGREADIMPLEMENTATION}

procedure TSGContext.ShowCursor(const VVisibility : TSGBoolean);
begin
FShowCursor := VVisibility;
end;

procedure TSGContext.SetCursorWheel(const VCursorWheel : TSGCursorWheel);
begin
FCursorWheel := VCursorWheel;
end;

procedure TSGContext.ReinitializeRender();
begin
{$IFDEF CONTEXT_DEBUGING}
WriteLn('TSGContext.ReinitializeRender() : Begining');
	{$ENDIF}
if FPaintable <> nil then
	FPaintable.DeleteDeviceResourses();
SGScreen.DeleteDeviceResourses();
if FRender <> nil then
	begin
	FRender.Context := nil;
	FRender.Destroy();
	FRender := nil;
	end;
{$IFDEF CONTEXT_DEBUGING}
WriteLn('TSGContext.ReinitializeRender() : After destroying, before creating');
	{$ENDIF}
FRender := FRenderClass.Create();
FRender.Context := Self as ISGContext;
if FRender.CreateContext() then
	FRender.Init();
FRenderClassChanget := False;
if FPaintable <> nil then
	FPaintable.LoadDeviceResourses();
SGScreen.LoadDeviceResourses();
{$IFDEF CONTEXT_DEBUGING}
WriteLn('TSGContext.ReinitializeRender() : End');
	{$ENDIF}
end;

procedure TSGContext.SwapBuffers();
begin
if FRender <> nil then
	FRender.SwapBuffers();
end;

procedure TSGContext.SetRenderClass(const NewRender : TSGPointer);
begin
{$IFDEF CONTEXT_DEBUGING}
WriteLn('TSGContext.SetRenderClass(...) : Begining');
	{$ENDIF}
FRenderClass := TSGRenderClass(NewRender);
if FInitialized and (not (Render is FRenderClass)) then
	begin
	FRenderClassChanget := True;
	end;
{$IFDEF CONTEXT_DEBUGING}
WriteLn('TSGContext.SetRenderClass(...) : End');
	{$ENDIF}
end;

function TSGContext.GetRender() : ISGRender;
begin
Result := FRender;
end;

procedure TSGContext.StartComputeTimer();
begin
FElapsedDateTime.Get();
FElapsedTime := 0;
end;

function TSGContext.GetElapsedTime() : TSGLongWord;
begin
Result := FElapsedTime;
end;

function TSGContext.GetTitle() : TSGString;
begin
Result := FTitle;
end;

function TSGContext.GetWidth() : TSGLongWord;
begin
Result := FWidth;
end;

function TSGContext.GetHeight() : TSGLongWord;
begin
Result := FHeight;
end;

procedure TSGContext.SetWidth(const VWidth : TSGLongWord);
begin
FWidth := VWidth;
end;

procedure TSGContext.SetHeight(const VHeight : TSGLongWord);
begin
FHeight := VHeight;
end;

function TSGContext.GetLeft() : TSGLongWord;
begin

end;

function TSGContext.GetTop() : TSGLongWord;
begin

end;

procedure TSGContext.SetLeft(const VLeft : TSGLongWord);
begin

end;

procedure TSGContext.SetTop(const VTop : TSGLongWord);
begin

end;

function  TSGContext.GetFullscreen() : TSGBoolean;
begin
Result := FFullscreen;
end;

procedure TSGContext.SetActive(const VActive : TSGBoolean);
begin
FActive := VActive;
end;

function  TSGContext.GetActive():TSGBoolean;
begin
Result := FActive;
end;

procedure TSGContext.SetCursorCentered(const VCentered : TSGBoolean);
var
	Point : TSGPoint2f;
begin
FCursorInCenter := VCentered;
if (@SetCursorPosition <> nil) and VCentered then
	begin
	Point.Import(Trunc(Render.Width * 0.5), Trunc(Render.Height * 0.5));
	SetCursorPosition(Point);
	FCursorPosition[SGLastCursorPosition] := Point;
	FCursorPosition[SGNowCursorPosition] := Point;
	FCursorPosition[SGDeferenseCursorPosition]:=0;
	end;
end;

function TSGContext.GetCursorCentered() : TSGBoolean;
begin
Result := FCursorInCenter;
end;

procedure TSGContext.SetSelfLink(const VLink : PISGContext);
begin
FSelfLink := VLink;
end;

function TSGContext.GetSelfLink() : PISGContext;
begin
Result := FSelfLink;
end;

function TSGContext.GetCursor():TSGCursor;
begin
Result := FCursor;
end;

procedure TSGContext.SetCursor(const VCursor : TSGCursor);
begin
if FCursor <> nil then
	FCursor.Destroy();
FCursor := VCursor;
end;

function TSGContext.GetIcon():TSGBitMap;
begin
Result := FIcon;
end;

procedure TSGContext.SetIcon(const VIcon : TSGBitMap);
begin
if FIcon <> nil then
	FIcon.Destroy();
FIcon := VIcon;
end;

procedure TSGContext.Initialize();
begin
StartComputeTimer();
FInitialized := True;
if FPaintableClass <> nil then
	begin
	SGScreen.Load(Self);
	FPaintable := FPaintableClass.Create(Self);
	FPaintable.LoadDeviceResourses();
	end;
end;

procedure TSGContext.UpdateTimer();
var
	DataTime : TSGDateTime;
begin
DataTime.Get();
FElapsedTime := (DataTime - FElapsedDateTime).GetPastMiliSeconds();
FElapsedDateTime := DataTime;
end;

procedure TSGContext.Run();
begin
Messages();
StartComputeTimer();
while Active and (FNewContextType = nil) do
	begin
	Paint();
	{$IFDEF CONTEXT_DEBUGING}
		WriteLn('TSGContext.Run(): Before continue looping');
		{$ENDIF}
	if FRenderClassChanget then
		ReinitializeRender();
	end;
end;

procedure TSGContext.Paint();
begin
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSGContext.Paint() : Begining, Before "UpdateTimer();"');
	{$ENDIF}
UpdateTimer(); 
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSGContext.Paint() : Before "Render.Clear(...);"');
	{$ENDIF}
Render.Clear(SGR_COLOR_BUFFER_BIT OR SGR_DEPTH_BUFFER_BIT);
if FPaintable <> nil then
	begin
	{$IFDEF CONTEXT_DEBUGING}
		WriteLn('TSGContext.Paint() : Before "Render.InitMatrixMode(SG_3D);" & "FPaintable.Paint();"');
		{$ENDIF}
	Render.InitMatrixMode(SG_3D);
	FPaintable.Paint();
	end;
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSGContext.Paint() : Before "ClearKeys();" & "Messages();"');
	{$ENDIF}
if FPaintWithHandlingMessages then
	begin
	ClearKeys();
	Messages();
	end;
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSGContext.Paint() : Before "SGScreen.Paint();"');
	{$ENDIF}
SGScreen.Paint();
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSGContext.Paint() : Before "SwapBuffers();"');
	{$ENDIF}
SwapBuffers();
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSGContext.Paint() : End');
	{$ENDIF}
end;

procedure TSGContext.SetTitle(const VTitle : TSGString);
begin
FTitle := VTitle;
end;

procedure TSGContext.CopyInfo(const C : ISGContext);
begin
{if C=nil then
	Exit;
FSelfPoint:=C.SelfPoint;
FRenderClass:=C.RenderClass;
FWidth:=C.Width;
FHeight:=C.Height;
FFullscreen:=C.Fullscreen;
FTitle:=C.Title;
FCursorIdenifier:=C.CursorIdenifier;
FIconIdentifier:=C.IconIdentifier;
FCallDraw:=C.CallDraw;
FCallInitialize:=C.CallInitialize;}
end;

procedure TSGContext.InitFullscreen(const VFullscreen : TSGBoolean);
begin
FFullscreen := VFullscreen;
Resize();
end;

function TSGContext.KeyPressedType():TSGCursorButtonType;
begin
Result:=FKeyPressedType;
end;

procedure TSGContext.SetCursorKey(ButtonType:TSGCursorButtonType;Key:TSGCursorButtons);
begin
FCursorKeyPressed     := Key;
FCursorKeyPressedType := ButtonType;
if Key <> SGNullCursorButton then
	FCursorKeysPressed[Key] := ButtonType = SGDownKey;
end;

procedure TSGContext.SetKey(ButtonType:TSGCursorButtonType;Key:LongInt);
begin
FKeysPressed[Key]:=ButtonType = SGDownKey;
FKeyPressedType:=ButtonType;
FKeyPressed:=Key;
end;

procedure TSGContext.Close();
begin
FActive:=False;
end;

function TSGContext.ShiftClientArea() : TSGPoint2f; 
begin
Result.Import(0,0);
end;

procedure TSGContext.Resize();
begin
SGScreen.Resize();
end;

function TSGContext.CursorWheel():TSGCursorWheel;
begin
Result := FCursorWheel;
end;

procedure TSGContext.Messages();
var
	Point:TSGPoint2f;
begin
Point := GetCursorPosition();
Point -= ShiftClientArea();
FCursorPosition[SGLastCursorPosition]:=FCursorPosition[SGNowCursorPosition];
FCursorPosition[SGNowCursorPosition]:=Point;
FCursorPosition[SGDeferenseCursorPosition]:=FCursorPosition[SGNowCursorPosition]-FCursorPosition[SGLastCursorPosition];
if CursorCentered and (@SetCursorPosition<>nil) then
	begin
	Point.Import(Trunc(Render.Width*0.5),Trunc(Render.Height*0.5));
	SetCursorPosition(Point);
	FCursorPosition[SGLastCursorPosition] := Point;
	FCursorPosition[SGNowCursorPosition] := Point;
	end;

if ((KeyPressed) and (KeyPressedByte=13) and (KeysPressed(SG_ALT_KEY)) and (KeyPressedType=SGDownKey)) or
	((KeyPressed) and (KeyPressedByte=122)  and (KeyPressedType=SGDownKey))then
	begin
	Fullscreen:= not Fullscreen;
	SetKey(SGUpKey,13);
	end;
end;

function TSGContext.CursorPosition(const Index : TSGCursorPosition = SGNowCursorPosition ) : TSGPoint2f;
begin
Result:=FCursorPosition[Index];
end;

function TSGContext.CursorKeyPressed():TSGCursorButtons;
begin
Result:=FCursorKeyPressed;
end;

function TSGContext.CursorKeyPressedType():TSGCursorButtonType;
begin
Result:=FCursorKeyPressedType;
end;

function TSGContext.CursorKeysPressed(const Index : TSGCursorButtons ):Boolean;
begin
if Index = SGNullCursorButton then
	Result:=False
else
	Result:=FCursorKeysPressed[Index];
end;

constructor TSGContext.Create();
var
	i:LongWord;
begin
inherited;
FRenderClassChanget := False;
FIcon := nil;
FCursor := nil;
FInitialized := False;
FShowCursor:=True;
FCursorInCenter:=False;
FWidth:=0;
FHeight:=0;
FTitle:='SaGe Window';
FFullscreen:=False;
FActive:=False;
FNewContextType:=nil;
for i:=0 to 255 do
	FKeysPressed[i]:=False;
FKeyPressed:=0;
FCursorPosition[SGDeferenseCursorPosition].Import();
FCursorPosition[SGNowCursorPosition].Import();
FCursorPosition[SGLastCursorPosition].Import();
FCursorKeyPressed:=SGNullCursorButton;
FCursorKeysPressed[SGMiddleCursorButton]:=False;
FCursorKeysPressed[SGLeftCursorButton]:=False;
FCursorKeysPressed[SGRightCursorButton]:=False;
FRender:=nil;
FPaintWithHandlingMessages := True;
end;

procedure TSGContext.ClearKeys();
begin
FCursorKeyPressed:=SGNullCursorButton;
FKeyPressed:=0;
FCursorWheel:=SGNullCursorWheel; 
end;

procedure TSGContext.Kill();
begin
if FCursor <> nil then
	begin
	FCursor.Destroy();
	FCursor := nil;
	end;
if FIcon <> nil then
	begin
	FIcon.Destroy();
	FIcon := nil;
	end;
if FPaintable <> nil then
	begin
	FPaintable.Destroy();
	FPaintable := nil;
	end;
if FRender <> nil then
	begin
	FRender.Destroy();
	FRender:=nil;
	end;
end;

destructor TSGContext.Destroy();
begin
Kill();
inherited;
end;

function TSGContext.KeysPressed(const  Index : integer ) : Boolean;overload;
begin
Result:=FKeysPressed[Index];
end;

function TSGContext.KeysPressed(const  Index : char ) : Boolean;overload;
begin
Result:=KeysPressed(LongWord(Index));
end;

function TSGContext.KeyPressed() : TSGBoolean;
begin
Result:=FKeyPressed<>0;
end;

function TSGContext.KeyPressedChar() : TSGChar;
begin
Result:=Char(FKeyPressed);
end;

function TSGContext.KeyPressedByte() : TSGLongWord;
begin
Result:=FKeyPressed;
end;

initialization
begin

end;

end.
