{$I Includes\SaGe.inc}
unit SaGeContext;

interface
uses
	SaGeBase
	,SaGeCommon
	,Classes
	,SysUtils
	,crt
	,SaGeRender
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
	{,Gl
	,Glu
	,GLext
	{$IFDEF GLUT}
		,glut
		{$ENDIF}}
	;
const
	SG_ALT_KEY = 18;
	SG_CTRL_KEY = 17;
type
	TSGCursorButtons = (SGNoCursorButton,SGMiddleCursorButton,SGLeftCursorButton,SGRightCursorButton);
	TSGCursorButtonType = (SGDownKey,SGUpKey);
	TSGCursorWheel = (SGNoCursorWheel,SGUpCursorWheel,SGDownCursorWheel);
	TSGCursorPosition = (SGDeferenseCursorPosition,SGNowCursorPosition,SGLastCursorPosition);
	TSGContext = class;
	TSGContextClass = class of TSGContext;
	TSGContextProcedure = TProcedure;
	TSGContext=class(TSGClass)
			public
		constructor Create;override;
		destructor Destroy;override;
			public
		procedure Initialize;virtual;abstract;
		procedure Run;virtual;abstract;
		procedure Messages;virtual;
		procedure SwapBuffers;virtual;abstract;
		function TopShift:LongWord;virtual;
		function GetCursorPosition:TSGPoint2f;virtual;abstract;
		procedure SetCursorPosition(const a:TSGPoint2f);virtual;abstract;
		function GetWindowRect:TSGPoint2f;virtual;abstract;
		function GetScreenResolution:TSGPoint2f;virtual;abstract;
		function GetWidth:LongWord;virtual;
		procedure SetWidth(const NewWidth:LongWord);virtual;
		procedure SetHeight(const NewHeight:LongWord);virtual;
		procedure Resize;virtual;
		function MouseShift:TSGPoint2f;virtual;
		class function RectInCoords:Boolean;virtual;
		procedure Close;virtual;
		procedure InitFullscreen(const b:Boolean);virtual;
		procedure ShowCursor(const b:Boolean);virtual;abstract;
			public
		FWidth,FHeight:LongWord;
		FFullscreen:Boolean;
		FFullscreenData:packed record
			FNotFullscreenWidth,FNotFullscreenHeight:LongWord;
			end;
		FTittle:String;
		FActive:Boolean;
		FCursorIdenifier:longword;
		FIconIdentifier:longword;
			public
		FCallDraw,FCallInitialize:TSGContextProcedure;
		
		FElapsedTime:LongWord;
		FElapsedDateTime:TSGDateTime;
			public
		property ElapsedTime:LongWord read FElapsedTime;
		property Width : LongWord read GetWidth write SetWidth;
		property Height : LongWord read FHeight write FHeight;
		property DrawProcedure : TSGContextProcedure read FCallDraw write FCallDraw;
		property InitializeProcedure : TSGContextProcedure read FCallInitialize write FCallInitialize;
		property Fullscreen:Boolean read FFullscreen write InitFullscreen;
		property Active: Boolean read FActive write FActive;
		property CursorIdentifier : LongWord read FCursorIdenifier write FCursorIdenifier;
		property IconIdentifier : LongWord read FIconIdentifier write FIconIdentifier;
		property Tittle:String read FTittle write FTittle;
			public
		FKeysPressed:packed array [0..255] of Boolean;
		FKeyPressed:LongWord;
		FKeyPressedType:TSGCursorButtonType;
		
		FCursorPosition:packed array [TSGCursorPosition] of TSGPoint2f;
		FCursorKeyPressed:TSGCursorButtons;
		FCursorKeyPressedType:TSGCursorButtonType;
		FCursorKeysPressed:packed array [SGMiddleCursorButton..SGRightCursorButton] of Boolean;
		FCursorWheel:TSGCursorWheel;
			public
		function KeysPressed(const  Index : integer ) : Boolean;virtual;overload;
		function KeysPressed(const  qwerty : char ) : Boolean;inline;overload;
		function KeyPressed:Boolean;inline;overload;
		function KeyPressedType:TSGCursorButtonType;inline;overload;
		function KeyPressedChar:Char;inline;overload;
		function KeyPressedByte:LongWord;inline;overload;
		procedure ClearKeys;inline;
		function CursorKeyPressed:TSGCursorButtons;overload;inline;
		function CursorKeyPressedType:TSGCursorButtonType;overload;inline;
		function CursorKeysPressed(const Index : TSGCursorButtons ):Boolean;overload;inline;
		function CursorWheel:TSGCursorWheel;overload;inline;
		function CursorPosition(const Index : TSGCursorPosition = SGNowCursorPosition ) : TSGPoint2f;overload;inline;
			public
		procedure SetKey(ButtonType:TSGCursorButtonType;Key:LongInt);virtual;overload;
		procedure SetCursorKey(ButtonType:TSGCursorButtonType;Key:TSGCursorButtons);virtual;overload;
			public
		function GetRC:LongWord;virtual;abstract;
		procedure SetRC(const NewRC:LongWord);virtual;abstract;
		procedure CopyInfo(const C:TSGContext);virtual;
			public
		FNewContextType:TSGContextClass;
			public
		FRenderClass:TSGRenderClass;
		FRender:TSGRender;
			public
		property RenderClass:TSGRenderClass read FRenderClass write FRenderClass;
		property Render:TSGRender read FRender write FRender;
			public
		function Get(const What:string):Pointer;override;
		end;
type
	TSGContextObject=class(TSGRenderObject)
			protected
		FContext:TSGContext;
			public
		property Context:TSGContext read FContext write FContext;
		end;
	
	TSGDrawClass=class;
	TSGClassOfDrawClass = class of TSGDrawClass;
	TSGDrawClassClass = TSGClassOfDrawClass; 
	TSGDrawClass=class(TSGContextObject)
			public
		procedure Draw;virtual;abstract;
		class function ClassName:String;override;
		end;

{$DEFINE SGREADINTERFACE}
{$IFDEF GLUT}
	{$I Includes\SaGeContextGLUT.inc}
	{$ENDIF}
{$IFDEF LAZARUS}
	{$I Includes\SaGeContextLazarus.inc}
	{$ENDIF}
{$UNDEF SGREADINTERFACE}
{var
	SGContext:TSGContext = nil;
var // Используется для пеехода к другому типу сонтекста
	NewContext:TSGContext = nil;}
implementation

{$DEFINE SGREADIMPLEMENTATION}
{$IFDEF GLUT}
	{$I Includes\SaGeContextGLUT.inc}
	{$ENDIF}
{$IFDEF LAZARUS}
	{$I Includes\SaGeContextLazarus.inc}
	{$ENDIF}
{$UNDEF SGREADIMPLEMENTATION}

class function TSGDrawClass.ClassName:String;
begin
Result:='SaGe Draw Class';
end;

function TSGContext.Get(const What:string):Pointer;
begin
if What='HEIGHT' then
	Result:=Pointer(FHeight)
else if What='WIDHT' then
	Result:=Pointer(FWidth)
else
	Result:=nil;
end;

procedure TSGContext.CopyInfo(const C:TSGContext);
begin
if C.GetRC<>0 then
	SetRC(C.GetRC);
FWidth:=C.FWidth;
FHeight:=C.FHeight;
FFullscreen:=C.FFullscreen;
FTittle:=C.FTittle;
FCursorIdenifier:=C.FCursorIdenifier;
FIconIdentifier:=C.FIconIdentifier;
FCallDraw:=C.FCallDraw;
FCallInitialize:=C.FCallInitialize;
end;

procedure TSGContext.InitFullscreen(const b:Boolean);
begin
if (b=True) and (FFullscreen=False) then
	begin
	FFullscreenData.FNotFullscreenHeight:=Height;
	FFullscreenData.FNotFullscreenWidth:=Width;
	Width:=GetScreenResolution.x;
	Height:=GetScreenResolution.y;
	//WriteLn(b,' ',Width,' ',Height);
	end
else
	if (not b) and (FFullscreen) then
		begin
		if not ((FFullscreenData.FNotFullscreenHeight=0) or (FFullscreenData.FNotFullscreenWidth=0)) then
			begin
			Width:=FFullscreenData.FNotFullscreenWidth;
			Height:=FFullscreenData.FNotFullscreenHeight;
			//WriteLn(b,' ',Width,' ',Height);
			end;
		end;
FFullscreen:=b;
Resize;
end;

function TSGContext.KeyPressedType:TSGCursorButtonType;inline;overload;
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
WriteLn(Key);
end;

procedure TSGContext.Close;
begin
FActive:=False;
end;

class function TSGContext.RectInCoords:Boolean;
begin
Result:=True;
end;

function TSGContext.MouseShift:TSGPoint2f;
begin
Result.Import(0,0);
end;

procedure TSGContext.Resize;
begin
if SGCLForReSizeScreenProcedure<>nil then
	SGCLForReSizeScreenProcedure();
end;

function TSGContext.GetWidth:LongWord;
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

function TSGContext.CursorWheel:TSGCursorWheel;overload;inline;
begin
Result:=FCursorWheel;
end;

procedure TSGContext.Messages;
var
	Point:TSGPoint2f;
begin
Point:=GetCursorPosition;
if RectInCoords then
	Point-=GetWindowRect;
Point+=MouseShift;
FCursorPosition[SGLastCursorPosition]:=FCursorPosition[SGNowCursorPosition];
FCursorPosition[SGNowCursorPosition]:=Point;
FCursorPosition[SGDeferenseCursorPosition]:=FCursorPosition[SGNowCursorPosition]-FCursorPosition[SGLastCursorPosition];

if ((KeyPressed) and (KeyPressedByte=13) and (KeysPressed(SG_ALT_KEY)) and (KeyPressedType=SGDownKey)) or
	((KeyPressed) and (KeyPressedByte=122)  and (KeyPressedType=SGDownKey))then
	begin
	Fullscreen:= not Fullscreen;
	SetKey(SGUpKey,13);
	end;
end;

function TSGContext.TopShift:LongWord;
begin
Result:=0;
end;

function TSGContext.CursorPosition(const Index : TSGCursorPosition = SGNowCursorPosition ) : TSGPoint2f;overload;inline;
begin
Result:=FCursorPosition[Index];
end;

function TSGContext.CursorKeyPressed:TSGCursorButtons;overload;inline;
begin
Result:=FCursorKeyPressed;
end;

function TSGContext.CursorKeyPressedType:TSGCursorButtonType;overload;inline;
begin
Result:=FCursorKeyPressedType;
end;

function TSGContext.CursorKeysPressed(const Index : TSGCursorButtons ):Boolean;overload;inline;
begin
if Index=SGNoCursorButton then
	Result:=False
else
	Result:=FCursorKeysPressed[Index];
end;

constructor TSGContext.Create;
var
	i:LongWord;
begin
inherited;
FWidth:=0;
FHeight:=0;
FCallDraw:=nil;
FCallInitialize:=nil;
FTittle:='SaGe Context Tittle';
FFullscreen:=False;
FCursorIdenifier:=0;
FIconIdentifier:=0;
FActive:=False;
FNewContextType:=nil;
for i:=0 to 255 do
	FKeysPressed[i]:=False;
FKeyPressed:=0;
FCursorPosition[SGDeferenseCursorPosition].Import;
FCursorPosition[SGNowCursorPosition].Import;
FCursorPosition[SGLastCursorPosition].Import;
FCursorKeyPressed:=SGNoCursorButton;
FCursorKeysPressed[SGMiddleCursorButton]:=False;
FCursorKeysPressed[SGLeftCursorButton]:=False;
FCursorKeysPressed[SGRightCursorButton]:=False;
FFullscreenData.FNotFullscreenHeight:=0;
FFullscreenData.FNotFullscreenWidth:=0;
end;

procedure TSGContext.ClearKeys;inline;
begin
FCursorKeyPressed:=SGNoCursorButton;
FKeyPressed:=0;
FCursorWheel:=SGNoCursorWheel; 
end;

destructor TSGContext.Destroy;
begin
inherited;
end;

function TSGContext.KeysPressed(const  Index : integer ) : Boolean;overload;
begin
Result:=FKeysPressed[Index];
end;

function TSGContext.KeysPressed(const  qwerty : char ) : Boolean;inline;overload;
begin
Result:=KeysPressed(LongWord(qwerty));
end;

function TSGContext.KeyPressed:Boolean;inline;overload;
begin
Result:=FKeyPressed<>0;
end;

function TSGContext.KeyPressedChar:Char;inline;overload;
begin
Result:=Char(FKeyPressed);
end;

function TSGContext.KeyPressedByte:LongWord;inline;overload;
begin
Result:=FKeyPressed;
end;

initialization
begin

end;

end.
