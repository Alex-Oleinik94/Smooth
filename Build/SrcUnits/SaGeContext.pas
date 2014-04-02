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
type
	//���� ������� ������ �����
	TSGCursorButtons = (SGNoCursorButton,SGMiddleCursorButton,SGLeftCursorButton,SGRightCursorButton);
	//��� "�������"
	TSGCursorButtonType = (SGDownKey,SGUpKey);
	//��� ������������� ��������
	TSGCursorWheel = (SGNoCursorWheel,SGUpCursorWheel,SGDownCursorWheel);
	//��� ���, �� �������� ����������� ���������� � ����������� ������ ���������� ����
	// SGDeferenseCursorPosition - ��� ������� ����� SGNowCursorPosition � SGLastCursorPosition
	// SGNowCursorPosition       - ���������� ���� � ��������� ������
	// SGLastCursorPosition      - ���������� ����, ��������� ��� ���������� ����� �����
	TSGCursorPosition = (SGDeferenseCursorPosition,SGNowCursorPosition,SGLastCursorPosition);
	// ������������ ������ ���������
	TSGContext = class;
	// ��������� �� ����� ���������
	PSGContext = ^ TSGContext;
	// ��� ������ ���������
	TSGContextClass = class of TSGContext;
	// ����������� ���������
	TSGContextProcedure = procedure(const a:TSGContext);
	// ����� ���������
	TSGContext=class(TSGClass)
			public
		// ����������� ���������
		constructor Create(); override; 
		// ����������� ���������
		destructor Destroy(); override;
			public
		// ����������, ���������������� ���� � �������� ������
		procedure Initialize();virtual;abstract;
		// ��������� ������� ���� ���������
		procedure Run();virtual;abstract;
		// ����� ��������� �������
		procedure Messages();virtual;
		// ����� �� ����� ������
		procedure SwapBuffers();virtual;abstract;
		// �������� � ����� (���� ������ �� ����� �� ������� �� ����� ������)
		function TopShift():LongWord;virtual;
		// ���������� ���������� ���� � ������ ������
		function GetCursorPosition():TSGPoint2f;virtual;abstract;
		// ������������� ���������� ����� � ������ ������
		procedure SetCursorPosition(const a:TSGPoint2f);virtual;abstract;
		// ������������� ���������� ���� �� ������� ����� ������������
		function GetWindowRect():TSGPoint2f;virtual;abstract;
		// ���������� ���������� ������
		function GetScreenResolution():TSGPoint2f;virtual;abstract;
			protected
		// ���������� ������ ����
		function GetWidth():LongWord;virtual;
		// ������������� ������ ����
		procedure SetWidth(const NewWidth:LongWord);virtual;
		// ������������� ������ ����
		procedure SetHeight(const NewHeight:LongWord);virtual;
			public
		// ���������� ����� ����, ��� ������ ��� ������ ���� ���� ��������
		procedure Resize();virtual;
		// �������� ��������� ����, ���������� �� ������� �� ��������� ��� ��� ��� ������������ � ����
		function MouseShift():TSGPoint2f;virtual;
		// ����������, ���������� �� ������� GetCursorPosition() ������ � ������������ ���� � 
		// ���������� ��������� ������ ���� ��� ����� ���� ����������
		class function RectInCoords:Boolean;virtual;
		// ���������� �������� ���������
		procedure Close();virtual;
			protected
		// ���������� ��� ��������� ������ ���� (fullscreen or not fullscreen)
		procedure InitFullscreen(const b:Boolean);virtual;
			public
		// ������������� �������� ���������, ��������� �� ��������� ������� ��� �����
		procedure ShowCursor(const b:Boolean);virtual;abstract;
		procedure SetTittle(const NewTittle:TSGString);virtual;
			protected
		// ��� �������� ������ � ������ ������
		FWidth, FHeight  : TSGLongWord;
		// ��� ����� ����
		FFullscreen      : TSGBoolean;
		//��� �������� �������� ���������� ������ � ������ ������ ����� ���, ��� ��� ���������� �� ������ �����
		FFullscreenData  : packed record 
			FNotFullscreenWidth, FNotFullscreenHeight : TSGLongWord;
			end;
		// ��������� ����
		FTitle          : TSGString;
		// ����� �� ���� ������� ����� ����� ���� �������� ��� �����
		FActive          : TSGBoolean;
		// ������ ����������
		FCursorIdenifier : TSGLongWord;
		// ������ �������� ����
		FIconIdentifier  : TSGLongWord;
			public
		// ���������������� ���������, ������� ����� ������� �� ����� ��������� � ����� �������������
		FCallDraw, FCallInitialize : TSGContextProcedure;
		// ������� � ������������ ����� ���� � ���������� ������ �������� ����� ����������
		FElapsedTime     : TSGLongWord;
		// ����� � ������ ������ �������
		FElapsedDateTime : TSGDateTime;
			public
		// ������� � ������������ ����� ���� � ���������� ������ �������� ����� ����������
		property ElapsedTime         : TSGLongWord         read FElapsedTime;
		// ������ ����
		property Width               : TSGLongWord         read GetWidth         write SetWidth;
		// ������ ����
		property Height              : TSGLongWord         read FHeight          write SetHeight;
		// ���������, ������� ���� ����� ��������� ��� ��������� ����
		property DrawProcedure       : TSGContextProcedure read FCallDraw        write FCallDraw;
		// ���������, ������� ���� ������ ��������� ����� �������������
		property InitializeProcedure : TSGContextProcedure read FCallInitialize  write FCallInitialize;
		// ���������� ���������� �� ������ ����� ����, ��� ���
		property Fullscreen          : TSGBoolean          read FFullscreen      write InitFullscreen;
		// ���� ���� ������� ���������� ��� ����, �� ��������� ������ �� ������ �������� �����
		property Active              : TSGBoolean          read FActive          write FActive;
		// ���������
		property CursorIdentifier    : TSGLongWord         read FCursorIdenifier write FCursorIdenifier;
		// ������
		property IconIdentifier      : TSGLongWord         read FIconIdentifier  write FIconIdentifier;
		// ��������� ����
		property Tittle              : TSGString           read FTitle          write SetTittle;
			public
		FKeysPressed      : packed array [0..255] of TSGBoolean;
		FKeyPressed       : TSGLongWord;
		FKeyPressedType   : TSGCursorButtonType;
		
		FCursorPosition       : packed array [TSGCursorPosition] of TSGPoint2f;
		FCursorKeyPressed     : TSGCursorButtons;
		FCursorKeyPressedType : TSGCursorButtonType;
		FCursorKeysPressed    : packed array [SGMiddleCursorButton..SGRightCursorButton] of TSGBoolean;
		FCursorWheel          : TSGCursorWheel;
			public
		// ����������, ������ �� �������
		function KeysPressed(const  Index : TSGInteger ) : TSGBoolean;virtual;overload;
		// ����������, ������ �� �������
		function KeysPressed(const  Index : TSGChar ) : Boolean;inline;overload;
		// ����������, ������ �� ����� �������
		function KeyPressed():TSGBoolean;inline;overload;
		// ���������� ��� ������� ������� (���� �� ��������� � ������ ������, ���� ������)
		function KeyPressedType():TSGCursorButtonType;inline;overload;
		// ���������� �������, ������� � ������ ������
		function KeyPressedChar():TSGChar;inline;overload;
		// ���������� �������, ������� � ������ ������
		function KeyPressedByte():TSGLongWord;inline;overload;
		// ��� ��������� �� ��� ��������
		procedure ClearKeys();inline;
		// ���������� ��� �� ������ ����� ����� ������ � ������ ������
		function CursorKeyPressed():TSGCursorButtons;overload;inline;
		// ���������� ��� ������� ������ ����� � ������ ������
		function CursorKeyPressedType():TSGCursorButtonType;overload;inline;
		// ����������, ������ �� ������������� ���������� Index ������� ����� � ������� ������� �������
		function CursorKeysPressed(const Index : TSGCursorButtons ):TSGBoolean;overload;inline;
		// ���������� ��������� �������� �����
		function CursorWheel():TSGCursorWheel;overload;inline;
		// ���������� ������� �������
		function CursorPosition(const Index : TSGCursorPosition = SGNowCursorPosition ) : TSGPoint2f;overload;inline;
			public
		// ������������� �������� �������� � ��������� ��������
		procedure SetKey(ButtonType:TSGCursorButtonType;Key:TSGLongInt);virtual;overload;
		// ������������� �������� �������� � ��������� ������� �����
		procedure SetCursorKey(ButtonType:TSGCursorButtonType;Key:TSGCursorButtons);virtual;overload;
			public
		// �������� ���������� � ������� ���������
		procedure CopyInfo(const C:TSGContext);virtual;
			public
		FNewContextType:TSGContextClass;
			public
		FRenderClass : TSGRenderClass;
		FRender      : TSGRender;
		FSelfPoint   : PSGContext;
			public
		// � ���� �������� ����� �������������� ��������� ������ ���� ���������� ��� ������ �������
		property RenderClass:TSGRenderClass read FRenderClass write FRenderClass;
		// ���������� ������ (�������� ����� ������������� � �������� ������ ���������� ������ ������� �� ���� ������ ������� ��� �������������)
		property Render:TSGRender read FRender write FRender;
		// ���� ������ ���� �������� ��������� �� ��������� ����� ������ � ��� �����, ��� ������������ ��� ������
		property SelfPoint:PSGContext read FSelfPoint write FSelfPoint;
			public
		// �������� ������������ �����������, ����������� � ��������������� What
		function Get(const What:string):Pointer;override;
		end;
type
	// ��� ���, � �������� ������� ��� ������, ������� ���������� Context
	TSGContextObject=class(TSGClass)
			public
		// ��� ��� ���� ����� ������ ����������� � ������� ����������� ������ ���������,
		// �� ���� ����������� ������ ������ ����� �������
		constructor Create();override;deprecated;
		destructor Destroy();override;
		constructor Create(const VContext:TSGContext);virtual;overload;
			public
		// ��������� �� ��������� ������ ���������
		FContext:PSGContext;
			public
		// � ������� ���� ��������� ����� ���������� �������� � ���� ������ (���� �� ��� ������ ��� ����)
		procedure SetContext(const VContext:TSGContext);inline;
		// ���������� ��������
		function GetContext():TSGContext;inline;
		//���������� ������
		function GetRender():TSGRender;inline;
			public
		// ���������� ��������
		property Context:TSGContext read GetContext write SetContext;
		//���������� ������
		property Render:TSGRender read GetRender;
		end;
	
	// ��� ������������ ������
	TSGDrawClass=class;
	// ��� ��� ������
	TSGClassOfDrawClass = class of TSGDrawClass;
	TSGDrawClassClass = TSGClassOfDrawClass; 
	// ��� �����, �� �������� ����� ������������� ��� ������, ������� ����� ������� ��� ���� �� �����
	TSGDrawClass=class(TSGContextObject)
			public
		procedure Draw();virtual;abstract;
		class function ClassName():String;override;
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

{$DEFINE SGREADIMPLEMENTATION}
{$IFDEF GLUT}
	{$I Includes\SaGeContextGLUT.inc}
	{$ENDIF}
{$IFDEF LAZARUS}
	{$I Includes\SaGeContextLazarus.inc}
	{$ENDIF}
{$UNDEF SGREADIMPLEMENTATION}

constructor TSGContextObject.Create(const VContext:TSGContext);overload;
begin
Create();
FContext:=nil;
SetContext(VContext);
end;

function TSGContextObject.GetRender():TSGRender;inline;
begin
Result:=FContext^.Render;
end;

procedure TSGContextObject.SetContext(const VContext:TSGContext);inline;
begin
if VContext<>nil then
	FContext:=VContext.SelfPoint
else
	FContext:=nil;
end;

function TSGContextObject.GetContext():TSGContext;inline;
begin
Result:=FContext^;
end;

constructor TSGContextObject.Create();
begin
inherited;
FContext:=nil;
//SGLog.Sourse('TSGContextObject__Create : Warning : Create without Context!!');
end;

destructor TSGContextObject.Destroy();
begin
inherited;
end;

class function TSGDrawClass.ClassName():String;
begin
Result:='SaGe Draw Class';
end;

procedure TSGContext.SetTittle(const NewTittle:TSGString);
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

procedure TSGContext.CopyInfo(const C:TSGContext);
begin
if C=nil then
	Exit;
FSelfPoint:=C.FSelfPoint;
Render:=C.Render;
FWidth:=C.FWidth;
FHeight:=C.FHeight;
FFullscreen:=C.FFullscreen;
FTitle:=C.FTitle;
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

function TSGContext.KeyPressedType():TSGCursorButtonType;inline;overload;
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

class function TSGContext.RectInCoords():Boolean;
begin
Result:=True;
end;

function TSGContext.MouseShift():TSGPoint2f;
var
	VA,VB:LongInt;
begin
if Render=nil then
	Result.Import(0,0)
else
	begin
	Render.MouseShift(VA,VB,FFullscreen);
	Result.x:=VA;
	Result.y:=VB;
	end;
end;

procedure TSGContext.Resize();
begin
if SGScreenForReSizeScreenProcedure<>nil then
	SGScreenForReSizeScreenProcedure(Self);
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

function TSGContext.CursorWheel():TSGCursorWheel;overload;inline;
begin
Result:=FCursorWheel;
end;

procedure TSGContext.Messages();
var
	Point:TSGPoint2f;
begin
Point:=GetCursorPosition();
if RectInCoords() then
	Point-=GetWindowRect();
Point+=MouseShift();
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

function TSGContext.TopShift():LongWord;
begin
if Render = nil then
	Result:=0
else
	Result:=Render.TopShift(FFullscreen);
end;

function TSGContext.CursorPosition(const Index : TSGCursorPosition = SGNowCursorPosition ) : TSGPoint2f;overload;inline;
begin
Result:=FCursorPosition[Index];
end;

function TSGContext.CursorKeyPressed():TSGCursorButtons;overload;inline;
begin
Result:=FCursorKeyPressed;
end;

function TSGContext.CursorKeyPressedType():TSGCursorButtonType;overload;inline;
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

constructor TSGContext.Create();
var
	i:LongWord;
begin
inherited;
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
end;

procedure TSGContext.ClearKeys();inline;
begin
FCursorKeyPressed:=SGNoCursorButton;
FKeyPressed:=0;
FCursorWheel:=SGNoCursorWheel; 
end;

destructor TSGContext.Destroy();
begin
inherited;
end;

function TSGContext.KeysPressed(const  Index : integer ) : Boolean;overload;
begin
Result:=FKeysPressed[Index];
end;

function TSGContext.KeysPressed(const  Index : char ) : Boolean;inline;overload;
begin
Result:=KeysPressed(LongWord(Index));
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
