{$INCLUDE Includes\SaGe.inc}

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
	,SaGeContextInterface
	,SaGeBaseClasses
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
	TSGCursorButtons =            SaGeContextInterface.TSGCursorButtons;
	TSGCursorButtonType =         SaGeContextInterface.TSGCursorButtonType;
	TSGCursorWheel =              SaGeContextInterface.TSGCursorWheel;
	TSGCursorPosition =           SaGeContextInterface.TSGCursorPosition;
const
	 SGDeferenseCursorPosition =  SaGeContextInterface.SGDeferenseCursorPosition; // - Это разница между SGNowCursorPosition и SGLastCursorPosition
	 SGNowCursorPosition =        SaGeContextInterface.SGNowCursorPosition;       //- Координаты мыши в настоящий момент
	 SGLastCursorPosition =       SaGeContextInterface.SGLastCursorPosition;      // - Координаты мыши, полученые при преведущем этапе цикла
	 SGNoCursorButton =           SaGeContextInterface.SGNoCursorButton;
	 
	 SGMiddleCursorButton =       SaGeContextInterface.SGMiddleCursorButton;
	 SGLeftCursorButton =         SaGeContextInterface.SGLeftCursorButton;
	 SGRightCursorButton =        SaGeContextInterface.SGRightCursorButton;
	 
	 SGDownKey =                  SaGeContextInterface.SGDownKey;
	 SGUpKey =                    SaGeContextInterface.SGUpKey;
	 
	 SGNoCursorWheel =            SaGeContextInterface.SGNoCursorWheel;
	 SGUpCursorWheel =            SaGeContextInterface.SGUpCursorWheel;
	 SGDownCursorWheel =          SaGeContextInterface.SGDownCursorWheel;
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
			protected
		FWidth, FHeight  : TSGLongWord;
		FFullscreen      : TSGBoolean;
		FFullscreenData  : packed record 
			FNotFullscreenWidth, FNotFullscreenHeight : TSGLongWord;
			end;
		FTitle           : TSGString;
		FActive          : TSGBoolean;
		FCursorIdenifier : TSGLongWord;
		FIconIdentifier  : TSGLongWord;
			public
		FCallDraw, 
		 FCallInitialize : TSGContextProcedure;
		FElapsedTime     : TSGLongWord;
		FElapsedDateTime : TSGDateTime;
		FShowCursor      : TSGBoolean;
			protected
		FPaintWithHandlingMessages : TSGBoolean;
			protected
		procedure SetRenderClass(const NewRender : TSGRenderClass);virtual;
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
		function  GetCursorIcon():TSGPointer;virtual;
		procedure SetCursorIcon(const VIcon : TSGPointer);virtual;
		function GetIcon():TSGPointer;virtual;
		procedure SetIcon(const VIcon : TSGPointer);virtual;
			public
		property SelfLink : PISGContext read GetSelfLink write SetSelfLink;
		property Fullscreen : TSGBoolean read GetFullscreen write InitFullscreen;
		property Active : TSGBoolean read GetActive write SetActive;
		property CursorIcon : TSGPointer read GetCursorIcon write SetCursorIcon;
		property Icon : TSGPointer read GetIcon write SetIcon;
		property Left : TSGLongWord read GetLeft write SetLeft;
		property Top : TSGLongWord read GetTop write SetTop;
		property Width : TSGLongWord read GetWidth write SetWidth;
		property Height : TSGLongWord read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		property Render : ISGRender read GetRender;
		property ElapsedTime : TSGLongWord read GetElapsedTime;
		property CursorCentered : TSGBoolean read GetCursorCentered write SetCursorCentered;
			public
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
			public
		procedure SetKey(ButtonType:TSGCursorButtonType;Key:TSGLongInt);virtual;
		procedure SetCursorKey(ButtonType:TSGCursorButtonType;Key:TSGCursorButtons);virtual;
			public
		procedure CopyInfo(const C : ISGContext);virtual;
			public
		FNewContextType : TSGContextClass;
		FRenderClass    : TSGRenderClass;
		FRender         : TSGRender;
		FSelfLink       : PISGContext;
			public
		property RenderClass : TSGRenderClass      read FRenderClass write SetRenderClass;
			public
		function Get(const What:string):Pointer;override;
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

procedure TSGContext.SetRenderClass(const NewRender : TSGRenderClass);
begin
FRenderClass := NewRender;
if Active and (not (Render is FRenderClass)) then
	ReinitializeRender();
end;

function GetRender() : ISGRender;
procedure StartComputeTimer();
function GetElapsedTime() : TSGLongWord;
function GetTitle() : TSGString;
procedure SetTitle(const VTitle : TSGString);
function GetWidth() : TSGLongWord;
function GetHeight() : TSGLongWord;
procedure SetWidth(const VWidth : TSGLongWord);
procedure SetHeight(const VHeight : TSGLongWord);
function GetLeft() : TSGLongWord;virtual;
function GetTop() : TSGLongWord;virtual;
procedure SetLeft(const VLeft : TSGLongWord);virtual;
procedure SetTop(const VTop : TSGLongWord);virtual;
function  GetFullscreen() : TSGBoolean;virtual;
procedure InitFullscreen(const VFullscreen : TSGBoolean);virtual;
procedure SetActive(const VActive : TSGBoolean);virtual;
function  GetActive():TSGBoolean;virtual;
procedure SetCursorCentered(const VCentered : TSGBoolean);virtual;
function GetCursorCentered() : TSGBoolean;virtual;
procedure SetSelfLink(const VLink : PISGContext);virtual;
function GetSelfLink() : PISGContext;virtual;
function GetCursorIcon():TSGPointer;virtual;
procedure SetCursorIcon(const VIcon : TSGPointer);virtual;
function GetIcon():TSGPointer;virtual;
procedure SetIcon(const VIcon : TSGPointer);virtual;

procedure TSGContext.Initialize();
begin
StartComputeTimer();
end;

procedure TSGContext.UpdateElapsedTime();
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
FElapsedDateTime.Get();
while FActive and (FNewContextType = nil) do
	Paint();
end;

procedure TSGContext.Paint();
begin
UpdateElapsedTime();
Render.Clear(SGR_COLOR_BUFFER_BIT OR SGR_DEPTH_BUFFER_BIT);
if FCallDraw<>nil then
	begin
	Render.InitMatrixMode(SG_3D);
	FCallDraw(Self);
	end;
if FPaintWithHandlingMessages then
	begin
	ClearKeys();
	Messages();
	end;
SGScreen.Paint();
SwapBuffers();
end;

procedure TSGContext.SetTitle(const NewTittle:TSGString);
begin
FTitle:=NewTittle;
end;

function TSGContext.Get(const What:string):Pointer;
begin
if What='HEIGHT' then
	Result:=Pointer(FHeight)
else if What='WIDTH' then
	Result:=Pointer(FWidth)
else if What='CURPOSY' then
	Result:=Pointer(FCursorPosition[SGNowCursorPosition].y)
else if What='CURPOSX' then
	Result:=Pointer(FCursorPosition[SGNowCursorPosition].x)
else if What='FULLSCREEN' then
	Result:=Pointer(Byte(FFullscreen))
else
	Result:=nil;
end;

procedure TSGContext.CopyInfo(const C : TSGContextInterface);
begin
if C=nil then
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
FCallInitialize:=C.CallInitialize;
end;

procedure TSGContext.InitFullscreen(const b:Boolean);
begin
if (b=True) and (FFullscreen=False) then
	begin
	FFullscreenData.FNotFullscreenHeight:=Height;
	FFullscreenData.FNotFullscreenWidth:=Width;
	Width:=GetScreenResolution.x;
	Height:=GetScreenResolution.y;
	//WriteLn(FFullscreen,' ',b,' ',Width,' ',Height);
	end
else
	if (not b) and (FFullscreen) then
		begin
		if not ((FFullscreenData.FNotFullscreenHeight=0) or (FFullscreenData.FNotFullscreenWidth=0)) then
			begin
			Width:=FFullscreenData.FNotFullscreenWidth;
			Height:=FFullscreenData.FNotFullscreenHeight;
			//WriteLn(FFullscreen,' ',b,' ',Width,' ',Height);
			end;
		end;
FFullscreen:=b;
Resize();
end;

function TSGContext.KeyPressedType():TSGCursorButtonType;overload;
begin
Result:=FKeyPressedType;
end;

procedure TSGContext.SetCursorKey(ButtonType:TSGCursorButtonType;Key:TSGCursorButtons);overload;
begin
FCursorKeyPressed:=Key;
FCursorKeyPressedType:=ButtonType;
FCursorKeysPressed[Key]:=ButtonType = SGDownKey;
end;

procedure TSGContext.SetKey(ButtonType:TSGCursorButtonType;Key:LongInt);overload;
begin
FKeysPressed[Key]:=ButtonType = SGDownKey;
FKeyPressedType:=ButtonType;
FKeyPressed:=Key;
//WriteLn(Key);
end;

procedure TSGContext.Close();
begin
FActive:=False;
end;

function TSGContext.ShiftClientArea() : TSGPoint2f; 
begin
Result.Import(0,0);
end;

class function TSGContext.RectInCoords():Boolean;
begin
Result:=True;
end;

procedure TSGContext.Resize();
begin
SGScreen.Resize();
end;

function TSGContext.GetWidth():LongWord;
begin
Result:=FWidth;
end;

procedure TSGContext.SetWidth(const NewWidth:LongWord);
begin
FWidth:=NewWidth;
end;

procedure TSGContext.SetHeight(const NewHeight:LongWord);
begin
FHeight:=NewHeight;
end;

function TSGContext.CursorWheel():TSGCursorWheel;overload;
begin
Result:=FCursorWheel;
end;

procedure TSGContext.SetCursorInCenter(const NP : TSGBoolean);
var
	Point : TSGPoint2f;
begin
FCursorInCenter := NP;
if (@SetCursorPosition<>nil) and NP then
	begin
	Point.Import(Trunc(Render.Width*0.5),Trunc(Render.Height*0.5));
	SetCursorPosition(Point + ShiftClientArea());
	FCursorPosition[SGLastCursorPosition] := Point;
	FCursorPosition[SGNowCursorPosition] := Point;
	FCursorPosition[SGDeferenseCursorPosition]:=0;
	end;
end;

procedure TSGContext.Messages();
var
	Point:TSGPoint2f;
begin
Point:=GetCursorPosition();
if RectInCoords() then
	Point -= GetWindowRect();
Point -= ShiftClientArea();
FCursorPosition[SGLastCursorPosition]:=FCursorPosition[SGNowCursorPosition];
FCursorPosition[SGNowCursorPosition]:=Point;
FCursorPosition[SGDeferenseCursorPosition]:=FCursorPosition[SGNowCursorPosition]-FCursorPosition[SGLastCursorPosition];
if CursorInCenter and (@SetCursorPosition<>nil) then
	begin
	Point.Import(Trunc(Render.Width*0.5),Trunc(Render.Height*0.5));
	SetCursorPosition(Point + ShiftClientArea());
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

function TSGContext.CursorPosition(const Index : TSGCursorPosition = SGNowCursorPosition ) : TSGPoint2f;overload;
begin
Result:=FCursorPosition[Index];
end;

function TSGContext.CursorKeyPressed():TSGCursorButtons;overload;
begin
Result:=FCursorKeyPressed;
end;

function TSGContext.CursorKeyPressedType():TSGCursorButtonType;overload;
begin
Result:=FCursorKeyPressedType;
end;

function TSGContext.CursorKeysPressed(const Index : TSGCursorButtons ):Boolean;overload;
begin
if Index=SGNoCursorButton then
	Result:=False
else
	Result:=FCursorKeysPressed[Index];
end;

constructor TSGContext.Create();
var
	i:LongWord;
begin
inherited;
FShowCursor:=True;
FCursorInCenter:=False;
FWidth:=0;
FHeight:=0;
FCallDraw:=nil;
FCallInitialize:=nil;
FTitle:='SaGe Window';
FFullscreen:=False;
FCursorIdenifier:=0;
FIconIdentifier:=0;
FActive:=False;
FNewContextType:=nil;
for i:=0 to 255 do
	FKeysPressed[i]:=False;
FKeyPressed:=0;
FCursorPosition[SGDeferenseCursorPosition].Import();
FCursorPosition[SGNowCursorPosition].Import();
FCursorPosition[SGLastCursorPosition].Import();
FCursorKeyPressed:=SGNoCursorButton;
FCursorKeysPressed[SGMiddleCursorButton]:=False;
FCursorKeysPressed[SGLeftCursorButton]:=False;
FCursorKeysPressed[SGRightCursorButton]:=False;
FFullscreenData.FNotFullscreenHeight:=0;
FFullscreenData.FNotFullscreenWidth:=0;
FRender:=nil;
FPaintWithHandlingMessages := True;
end;

procedure TSGContext.ClearKeys();
begin
FCursorKeyPressed:=SGNoCursorButton;
FKeyPressed:=0;
FCursorWheel:=SGNoCursorWheel; 
end;

destructor TSGContext.Destroy();
begin
if FRender<>nil then
	begin
	FRender.Destroy();
	FRender:=nil;
	end;
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

function TSGContext.KeyPressed:Boolean;overload;
begin
Result:=FKeyPressed<>0;
end;

function TSGContext.KeyPressedChar:Char;overload;
begin
Result:=Char(FKeyPressed);
end;

function TSGContext.KeyPressedByte:LongWord;overload;
begin
Result:=FKeyPressed;
end;

initialization
begin

end;

end.
