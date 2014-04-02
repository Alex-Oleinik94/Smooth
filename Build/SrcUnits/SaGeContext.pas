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
	//Типы нажатий клавиш мышки
	TSGCursorButtons = (SGNoCursorButton,SGMiddleCursorButton,SGLeftCursorButton,SGRightCursorButton);
	//Тип "нажатия"
	TSGCursorButtonType = (SGDownKey,SGUpKey);
	//Тип использования колесика
	TSGCursorWheel = (SGNoCursorWheel,SGUpCursorWheel,SGDownCursorWheel);
	//Это тип, по которому разделяются хранящиеся в последующем классе координаты мышы
	// SGDeferenseCursorPosition - Это разница между SGNowCursorPosition и SGLastCursorPosition
	// SGNowCursorPosition       - Координаты мыши в настоящий момент
	// SGLastCursorPosition      - Координаты мыши, полученые при преведущем этапе цикла
	TSGCursorPosition = (SGDeferenseCursorPosition,SGNowCursorPosition,SGLastCursorPosition);
	// Предописание класса контекста
	TSGContext = class;
	// Указатель на класс контекста
	PSGContext = ^ TSGContext;
	// Тип класса контекста
	TSGContextClass = class of TSGContext;
	// Контекстная процедура
	TSGContextProcedure = procedure(const a:TSGContext);
	// Класс контекста
	TSGContext=class(TSGClass)
			public
		// Конструктор контекста
		constructor Create(); override; 
		// Деструктеор контекста
		destructor Destroy(); override;
			public
		// Процедурка, инициализирующая онко и указаный рендер
		procedure Initialize();virtual;abstract;
		// Запускает главный цикл программф
		procedure Run();virtual;abstract;
		// Отлов сообщений системы
		procedure Messages();virtual;
		// Вывод на экран буфера
		procedure SwapBuffers();virtual;abstract;
		// Смещение с верху (если сверху по какой то причине не видно нифига)
		function TopShift():LongWord;virtual;
		// Возвращает координаты мыши в данный момент
		function GetCursorPosition():TSGPoint2f;virtual;abstract;
		// Устанавливает координаты мышки в данный момент
		procedure SetCursorPosition(const a:TSGPoint2f);virtual;abstract;
		// Устанавливает координаты окна на рабочем столе пользователя
		function GetWindowRect():TSGPoint2f;virtual;abstract;
		// Возвращает разрешение экрана
		function GetScreenResolution():TSGPoint2f;virtual;abstract;
			protected
		// Возвращает ширину окна
		function GetWidth():LongWord;virtual;
		// Устанавливает ширину окна
		procedure SetWidth(const NewWidth:LongWord);virtual;
		// Устанавливает высоту окна
		procedure SetHeight(const NewHeight:LongWord);virtual;
			public
		// Вызывается после того, как ширина или высота окна была изменена
		procedure Resize();virtual;
		// Смещение координат мыши, получаемых из системы до координат над чем она остановилась в окне
		function MouseShift():TSGPoint2f;virtual;
		// Возвращает, возвращает ли функция GetCursorPosition() вместе с координатами мыши и 
		// координаты верзхнего левого угла как сумму этих параметров
		class function RectInCoords:Boolean;virtual;
		// Нормальное закрытие контекста
		procedure Close();virtual;
			protected
		// Вызывается при изменении режима окна (fullscreen or not fullscreen)
		procedure InitFullscreen(const b:Boolean);virtual;
			public
		// Устанавливает значение параметра, влияющего на видимость курсора над окном
		procedure ShowCursor(const b:Boolean);virtual;abstract;
		procedure SetTittle(const NewTittle:TSGString);virtual;
			protected
		// Тут хнанятся ширина и высота экраза
		FWidth, FHeight  : TSGLongWord;
		// Тут режим окна
		FFullscreen      : TSGBoolean;
		//Тут хранится значнеия параметров ширины и высоты экрана перед тем, как его развернули на полный экран
		FFullscreenData  : packed record 
			FNotFullscreenWidth, FNotFullscreenHeight : TSGLongWord;
			end;
		// Заголовок окна
		FTitle          : TSGString;
		// Будет ли окно закрыто после этого шага главного его цикла
		FActive          : TSGBoolean;
		// Курсор приложения
		FCursorIdenifier : TSGLongWord;
		// Иконка главного окна
		FIconIdentifier  : TSGLongWord;
			public
		// пользовательские процедуры, которые нужно вызвать во время отрисовки и после инициализации
		FCallDraw, FCallInitialize : TSGContextProcedure;
		// Разница в милесекундах между этим и преведущим шагами главного цикле приложения
		FElapsedTime     : TSGLongWord;
		// Время в данный момент времени
		FElapsedDateTime : TSGDateTime;
			public
		// Разница в милесекундах между этим и преведущим шагами главного цикле приложения
		property ElapsedTime         : TSGLongWord         read FElapsedTime;
		// Ширина окна
		property Width               : TSGLongWord         read GetWidth         write SetWidth;
		// Высота окна
		property Height              : TSGLongWord         read FHeight          write SetHeight;
		// Процедура, которую этот класс выполняет при отрисовке окна
		property DrawProcedure       : TSGContextProcedure read FCallDraw        write FCallDraw;
		// Процедура, которую этот крассс выполняет после инициализации
		property InitializeProcedure : TSGContextProcedure read FCallInitialize  write FCallInitialize;
		// Вызвращает развернуто на полный экран окно, или нет
		property Fullscreen          : TSGBoolean          read FFullscreen      write InitFullscreen;
		// Если этот праметр установить как ложь, то программа выйдет из своего главного цикла
		property Active              : TSGBoolean          read FActive          write FActive;
		// Курсорчик
		property CursorIdentifier    : TSGLongWord         read FCursorIdenifier write FCursorIdenifier;
		// Иконка
		property IconIdentifier      : TSGLongWord         read FIconIdentifier  write FIconIdentifier;
		// Заголовок окна
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
		// Возвращает, зажата ли клавиша
		function KeysPressed(const  Index : TSGInteger ) : TSGBoolean;virtual;overload;
		// Возвращает, зажата ли клавиша
		function KeysPressed(const  Index : TSGChar ) : Boolean;inline;overload;
		// Возвращает, нажата ли любая клавиша
		function KeyPressed():TSGBoolean;inline;overload;
		// Возвращает тип нажатия клавижи (либо ее отпустили в данный момент, либо нажали)
		function KeyPressedType():TSGCursorButtonType;inline;overload;
		// Возвращает клавишу, нажатую в данный момент
		function KeyPressedChar():TSGChar;inline;overload;
		// Возвращает клавишу, нажатую в данный момент
		function KeyPressedByte():TSGLongWord;inline;overload;
		// Эта процедура не для смертных
		procedure ClearKeys();inline;
		// Возвращает что за кнопка мышки былоа нажата в данный момент
		function CursorKeyPressed():TSGCursorButtons;overload;inline;
		// Возвращает тип нажатия кнопки мышки в данный момент
		function CursorKeyPressedType():TSGCursorButtonType;overload;inline;
		// Возвращает, зажата ли определененая параметром Index клавиша мышки в даннный могмент времени
		function CursorKeysPressed(const Index : TSGCursorButtons ):TSGBoolean;overload;inline;
		// Возвраащет прокрутку колесика мышки
		function CursorWheel():TSGCursorWheel;overload;inline;
		// Возвращает позицию курсора
		function CursorPosition(const Index : TSGCursorPosition = SGNowCursorPosition ) : TSGPoint2f;overload;inline;
			public
		// Устанавливает указаную операцию с указанной клавишей
		procedure SetKey(ButtonType:TSGCursorButtonType;Key:TSGLongInt);virtual;overload;
		// Устанавливает указаную операцию с указанной кнопкой мышки
		procedure SetCursorKey(ButtonType:TSGCursorButtonType;Key:TSGCursorButtons);virtual;overload;
			public
		// Копирует информацию с другого контекста
		procedure CopyInfo(const C:TSGContext);virtual;
			public
		FNewContextType:TSGContextClass;
			public
		FRenderClass : TSGRenderClass;
		FRender      : TSGRender;
		FSelfPoint   : PSGContext;
			public
		// В этом свойстве перед инициализацией контекста должен быть установлет тип класса рендера
		property RenderClass:TSGRenderClass read FRenderClass write FRenderClass;
		// Возвращает рендер (работает после инициализации и создания самого экземпляра класса реддера из типа класса рендера при инизиализации)
		property Render:TSGRender read FRender write FRender;
		// Сюда должен быть присвоен указатель на экземпляр этого класса в том месте, где пользователь его описал
		property SelfPoint:PSGContext read FSelfPoint write FSelfPoint;
			public
		// Получить определенную имнформацию, заключенную в индентификаторе What
		function Get(const What:string):Pointer;override;
		end;
type
	// Это тип, с которого пишутся все классы, которые используют Context
	TSGContextObject=class(TSGClass)
			public
		// Так как этот класс должен создаваться с готовым экземпляром класса контекста,
		// то этот конструктор теперь нельзя будет трогать
		constructor Create();override;deprecated;
		destructor Destroy();override;
		constructor Create(const VContext:TSGContext);virtual;overload;
			public
		// Указатель на экземпляр класса контекста
		FContext:PSGContext;
			public
		// С помощью этой процедуры можно установить контекст в этом классе (если он был создан без него)
		procedure SetContext(const VContext:TSGContext);inline;
		// Возвращает контекст
		function GetContext():TSGContext;inline;
		//Возвращает рендер
		function GetRender():TSGRender;inline;
			public
		// Возвращает контекст
		property Context:TSGContext read GetContext write SetContext;
		//Возвращает рендер
		property Render:TSGRender read GetRender;
		end;
	
	// Это предописание класса
	TSGDrawClass=class;
	// Это тип класса
	TSGClassOfDrawClass = class of TSGDrawClass;
	TSGDrawClassClass = TSGClassOfDrawClass; 
	// Это класс, от которого будут наследоваться все классы, которые могут вывести что нить на экран
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
