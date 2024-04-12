{$INCLUDE Smooth.inc}

//{$DEFINE CONTEXT_DEBUGING}
//{$DEFINE CONTEXT_CHANGE_DEBUGING}

unit SmoothContext;

interface

uses
	 SmoothBase
	,SmoothDateTime
	,SmoothRender
	,SmoothContextClasses
	,SmoothBaseClasses
	,SmoothBitMap
	,SmoothScreen
	,SmoothAudioRender
	,SmoothCursor
	,SmoothRenderInterface
	,SmoothAudioRenderInterface
	,SmoothCommonStructs
	,SmoothContextUtils
	,SmoothContextInterface
	,SmoothBaseContextInterface
	,SmoothScreenCustomComponent
	;

type
	TSContext = class;
	PSContext = ^ TSContext;
	TSContextClass = class of TSContext;
	TSContextProcedure = procedure(const a:TSContext);
	
	ISExtendedContextObject = interface(ISInterface)
		['{2cc5e532-35f5-441f-8f18-11991415e602}']
		procedure SetContextExemplar(const _ContextExemplar : PSContext);
		function GetContextExemplar() : PSContext;
		
		property ContextExemplar : PSContext read GetContextExemplar write SetContextExemplar;
		end;
	
	TSContext = class(TSNamed, ISContext)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		class function ContextName() : TSString; virtual;
		procedure Initialize(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal);virtual;
		procedure Run();virtual;
		procedure Messages();virtual;
		procedure Paint();virtual;
		procedure UpdateTimer();virtual;
		procedure Resize();virtual;
		procedure Close();virtual;
		function ShiftClientArea() : TSPoint2int32; virtual;
		procedure SwapBuffers();virtual;
		procedure SetRenderClass(const NewRender : TSNamedClass);virtual;
		procedure Kill();virtual;
		class function Supported() : TSBoolean; virtual;
		function GetDefaultWindowColor():TSColor3f; virtual;
		procedure Minimize();virtual;
		procedure Maximize();virtual;
		procedure PrintBounds();
		class function UserProfilePath() : TSString; virtual;
			public
		procedure ShowCursor(const VVisibility : TSBoolean);virtual;
		function GetCursorPosition():TSPoint2int32;virtual;abstract;
		procedure SetCursorPosition(const VPosition : TSPoint2int32);virtual;abstract;
		function GetWindowArea():TSPoint2int32;virtual;abstract;
		function GetScreenArea():TSPoint2int32;virtual;abstract;
		function GetClientArea():TSPoint2int32;virtual;abstract;
		function GetClientAreaShift() : TSPoint2int32;virtual;abstract;
		procedure SetForeground(); virtual;
			protected
		FVisible         : TSBoolean;
		FActive          : TSBoolean;
		FInitialized     : TSBoolean;
		FWidth, FHeight  : TSAreaInt;
		FClientWidth, FClientHeight  : TSAreaInt;
		FLeft, FTop      : TSAreaInt;
		FFullscreen      : TSBoolean;
		FTitle           : TSString;
		FElapsedTime     : TSTimerInt;
		FElapsedDateTime : TSDateTime;
		FShowCursor      : TSBoolean;
		FIcon            : TSBitMap;
		FCursor          : TSCursor;
		FIncessantlyPainting : TSLongInt;
			protected
		FPaintWithHandlingMessages : TSBoolean;
			protected
		procedure SetVisible(const _Visible : TSBoolean); virtual;
		function  GetVisible() : TSBoolean; virtual;
		procedure ReinitializeRender(); virtual;
		function  GetRender() : ISRender; virtual;
		procedure StartComputeTimer(); virtual;
		function  GetElapsedTime() : TSTimerInt; virtual;
		function  GetTitle() : TSString; virtual;
		procedure SetTitle(const VTitle : TSString); virtual;
		function  GetWidth() : TSAreaInt; virtual;
		function  GetHeight() : TSAreaInt; virtual;
		procedure SetWidth(const VWidth : TSAreaInt); virtual;
		procedure SetHeight(const VHeight : TSAreaInt); virtual;
		function  GetLeft() : TSAreaInt; virtual;
		function  GetTop() : TSAreaInt; virtual;
		procedure SetLeft(const VLeft : TSAreaInt); virtual;
		procedure SetTop(const VTop : TSAreaInt); virtual;
		function  GetFullscreen() : TSBoolean; virtual;
		procedure InitFullscreen(const VFullscreen : TSBoolean); virtual;
		procedure SetActive(const VActive : TSBoolean); virtual;
		function  GetActive():TSBoolean; virtual;
		procedure SetCursorCentered(const VCentered : TSBoolean); virtual;
		function  GetCursorCentered() : TSBoolean; virtual;
		procedure SetInterfaceLink(const VLink : PISContext); virtual;
		function  GetInterfaceLink() : PISContext; virtual;
		function  GetCursor():TSCursor; virtual;
		procedure SetCursor(const VCursor : TSCursor); virtual;
		function  GetIcon():TSBitMap; virtual;
		procedure SetIcon(const VIcon : TSBitMap); virtual;
		procedure BeginIncessantlyPainting(); virtual;
		procedure EndIncessantlyPainting(); virtual;

		function  GetClientWidth() : TSAreaInt; virtual;
		function  GetClientHeight() : TSAreaInt; virtual;
		function  GetOption(const VName : TSString) : TSPointer; virtual; abstract;
		procedure SetOption(const VName : TSString; const VValue : TSPointer); virtual; abstract;
		procedure SetClientWidth(const VClientWidth : TSAreaInt); virtual;
		procedure SetClientHeight(const VClientHeight : TSAreaInt); virtual;
		function  GetWindow() : TSPointer; virtual;
		function  GetDevice() : TSPointer; virtual;
		function FileOpenDialog(const VTitle: TSString; const VFilter : TSString) : TSString; virtual; abstract;
		function FileSaveDialog(const VTitle: TSString; const VFilter : TSString;const Extension : TSString) : TSString; virtual; abstract;
			public
		property Visible : TSBoolean read GetVisible write SetVisible;
		property InterfaceLink : PISContext read GetInterfaceLink write SetInterfaceLink;
		property Fullscreen : TSBoolean read GetFullscreen write InitFullscreen;
		property Active : TSBoolean read GetActive write SetActive;
		property Cursor : TSCursor read GetCursor write SetCursor;
		property Icon : TSBitMap read GetIcon write SetIcon;
		property Left : TSAreaInt read GetLeft write SetLeft;
		property Top : TSAreaInt read GetTop write SetTop;
		property Width : TSAreaInt read GetWidth write SetWidth;
		property Height : TSAreaInt read GetHeight write SetHeight;
		property Title : TSString read GetTitle write SetTitle;
		property Render : ISRender read GetRender;
		property ElapsedTime : TSTimerInt read GetElapsedTime;
		property CursorCentered : TSBoolean read GetCursorCentered write SetCursorCentered;
		property Device : TSPointer read GetDevice;
		property Window : TSPointer read GetWindow;
		property ClientWidth : TSAreaInt read GetClientWidth write SetClientWidth;
		property ClientHeight : TSAreaInt read GetClientHeight write SetClientHeight;
			protected
		FKeysPressed      : packed array [0..255] of TSBoolean;
		FKeyPressed       : TSLongWord;
		FKeyPressedType   : TSCursorButtonType;

		FCursorPosition       : packed array [TSCursorPosition] of TSPoint2int32;
		FCursorKeyPressed     : TSCursorButton;
		FCursorKeyPressedType : TSCursorButtonType;
		FCursorKeysPressed    : packed array [SMiddleCursorButton..SRightCursorButton] of TSBoolean;
		FCursorWheel          : TSCursorWheel;
		FCursorInCenter       : TSBoolean;
		FDefaultCursorPosition: TSVector2int32;
			public
		function KeysPressed(const  Index : TSInteger ) : TSBoolean;virtual;overload;
		function KeysPressed(const  Index : TSChar ) : Boolean;virtual;overload;
		function KeyPressed():TSBoolean;virtual;
		function KeyPressedType():TSCursorButtonType;virtual;
		function KeyPressedChar():TSChar;virtual;
		function KeyPressedByte():TSLongWord;virtual;
		procedure ClearKeys();virtual;
		function CursorKeyPressed():TSCursorButton;virtual;
		function CursorKeyPressedType():TSCursorButtonType;virtual;
		function CursorKeysPressed(const Index : TSCursorButton ):TSBoolean;virtual;
		function CursorWheel():TSCursorWheel;virtual;
		function CursorPosition(const Index : TSCursorPosition = SNowCursorPosition ) : TSPoint2int32;virtual;

		procedure SetKey(ButtonType:TSCursorButtonType;Key:TSLongInt);virtual;
		procedure SetCursorKey(ButtonType:TSCursorButtonType;Key:TSCursorButton);virtual;
		procedure SetCursorWheel(const VCursorWheel : TSCursorWheel);virtual;
			public
		procedure MoveInfo(var FormerContext : TSContext);virtual;
		procedure SetNewContext(const NewContextClass : TSNamedClass);virtual;
			protected
		FNewContextType : TSContextClass;
		FInterfaceLink  : PISContext;
		FExtendedLink   : PSContext;
			protected
		FPaintableClass    : TSPaintableObjectClass;
		FPaintable         : TSPaintableObject;
		FPaintableSettings : TSPaintableSettings;
			protected
		FRenderClassOld     : TSRenderClass;
		FRenderClass        : TSRenderClass;
		FRenderClassChanget : TSBoolean;
		FRender             : TSRender;
			protected
		FScreen : TSScreen;
			protected
		procedure PaintScreen();
		procedure SetPaintableSettings(); virtual;
		procedure KillRender(); virtual;
			private
		function GetScreen() : TSScreenCustomComponent; virtual;
			public
		property ExtendedLink : PSContext read FExtendedLink write FExtendedLink;
		property NewContext : TSContextClass read FNewContextType write FNewContextType;
		property PaintableExemplar : TSPaintableObject read FPaintable;
		property Paintable : TSPaintableObjectClass write FPaintableClass;
		property RenderClass : TSNamedClass write SetRenderClass;
		property PaintableSettings : TSPaintableSettings write FPaintableSettings;
		property Screen : TSScreen read FScreen;
			public
		procedure DeleteRenderResources(); virtual;
		procedure LoadRenderResources(); virtual;
			protected
		FAudioRender      : TSAudioRender;
		FAudioRenderClass : TSAudioRenderClass;
			protected
		function GetAudioRender() : ISAudioRender;
		procedure CreateAudio();
		procedure KillAudio();
			public
		property AudioRender : ISAudioRender read GetAudioRender;
		end;

function TSCompatibleContext() : TSContextClass;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SysUtils
	
	,SmoothLog
	,SmoothLists
	,SmoothStringUtils
	,SmoothRenderBase
	,SmoothEngineConfigurationPanel
	{$IFDEF MSWINDOWS}
		,SmoothContextWinAPI
		{$ENDIF}
	{$IFDEF LINUX}
		,SmoothContextLinux
		{$ENDIF}
	{$IFDEF ANDROID}
		,SmoothContextAndroid
		{$ENDIF}
	{$IFDEF DARWIN}
		,SmoothContextMacOSX
		{$ENDIF}
	{$IFDEF WITH_GLUT}
		,SmoothContextGLUT
		{$ENDIF}
	;

class function TSContext.ContextName() : TSString;
begin
Result := 'Unknown';
end;

procedure TSContext.SetForeground();
begin
end;

class function TSContext.UserProfilePath() : TSString;
begin
Result := '.';
end;

procedure TSContext.CreateAudio();
begin
if FAudioRenderClass = nil then
	if 'AUDIORENDER' in FPaintableSettings then
		FAudioRenderClass := TSAudioRenderClass(SContextOption('AUDIORENDER', FPaintableSettings));
if FAudioRenderClass <> nil then
	begin
	if FAudioRender <> nil then
		KillAudio();
	FAudioRender := FAudioRenderClass.Create();
	FAudioRender.Initialize();
	end;
end;

procedure TSContext.KillRender();
begin
if FRender <> nil then
	begin
	FRender.Destroy();
	FRender := nil;
	end;
end;

procedure TSContext.KillAudio();
begin
if FAudioRender <> nil then
	begin
	FAudioRender.Destroy();
	FAudioRender := nil;
	end;
end;

function TSContext.GetScreen() : TSScreenCustomComponent;
begin
Result := FScreen;
end;

procedure TSContext.Minimize();
begin
end;

procedure TSContext.Maximize();
begin
end;

procedure TSContext.PrintBounds();
begin
WriteLn('L:', FLeft, ';T:', FTop);
WriteLn('W:', FWidth, ';H:', FHeight);
WriteLn('CW:', FClientWidth, ';CH:', FClientHeight);
end;

function TSContext.GetDefaultWindowColor():TSColor3f;
begin
Result.Import(1, 1, 1);
end;

function  TSContext.GetWindow() : TSPointer;
begin
Result := nil;
end;

function  TSContext.GetDevice() : TSPointer;
begin
Result := nil;
end;

class function TSContext.Supported() : TSBoolean;
begin
Result := False;
end;

procedure TSContext.SetNewContext(const NewContextClass : TSNamedClass);
begin
FNewContextType := TSContextClass(NewContextClass);
end;

procedure TSContext.DeleteRenderResources();
begin
if (FPaintable <> nil) then
	FPaintable.DeleteRenderResources();
if (FScreen <> nil) then
	FScreen.DeleteRenderResources();
end;

procedure TSContext.LoadRenderResources();
begin
if (FPaintable <> nil) then
	FPaintable.LoadRenderResources();
if (FScreen <> nil) then
	FScreen.LoadRenderResources();
end;

procedure TSContext.MoveInfo(var FormerContext : TSContext);
begin
if FormerContext = nil then
	Exit;
{$IFDEF CONTEXT_CHANGE_DEBUGING}
	SLog.Source([ClassName(), '(',SAddrStr(Self),')__MoveInfo(FormerContext=',SAddrStr(FormerContext),'). Enter.']);
	{$ENDIF}
SKill(FScreen);
FInterfaceLink := FormerContext.FInterfaceLink;
FExtendedLink  := FormerContext.FExtendedLink;
FRenderClass   := FormerContext.FRenderClass;
FWidth         := FormerContext.FWidth;
FHeight        := FormerContext.FHeight;
FFullscreen    := FormerContext.FFullscreen;
FTitle         := FormerContext.FTitle;
FPaintable     := FormerContext.FPaintable;
FPaintableClass:= FormerContext.FPaintableClass;
FShowCursor    := FormerContext.FShowCursor;
FIcon          := FormerContext.FIcon;
FCursor        := TSCursor.Copy(FormerContext.FCursor);
FScreen        := FormerContext.FScreen;
FAudioRender   := FormerContext.FAudioRender;
FormerContext.FScreen      := nil;
FormerContext.FPaintable   := nil;
FormerContext.FAudioRender := nil;
{$IFDEF CONTEXT_CHANGE_DEBUGING}
	SLog.Source([ClassName(), '(',SAddrStr(Self),')__MoveInfo(FormerContext=',SAddrStr(FormerContext),'). Leave.']);
	{$ENDIF}
end;

function TSCompatibleContext() : TSContextClass;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result :=
	{$IFDEF MSWINDOWS}TSContextWinAPI {$ELSE}
	{$IFDEF LINUX}    TSContextLinux  {$ELSE}
	{$IFDEF ANDROID}  TSContextAndroid{$ELSE}
	{$IFDEF DARWIN}   TSContextMacOSX {$ELSE}
	                  nil
	{$ENDIF}   {$ENDIF}   {$ENDIF}   {$ENDIF}
	;
{$IFDEF WITH_GLUT}
if Result = nil then
	Result := TSContextGLUT;
	{$ENDIF}
end;

procedure TSContext.ShowCursor(const VVisibility : TSBoolean);
begin
FShowCursor := VVisibility;
end;

procedure TSContext.SetCursorWheel(const VCursorWheel : TSCursorWheel);
begin
FCursorWheel := VCursorWheel;
end;

procedure TSContext.ReinitializeRender();

procedure DestroyRender();
begin
FRender.Context := nil;
FRender.Destroy();
FRender := nil;
end;

function InitNewRenderClass(const NewRenderClass : TSRenderClass) : TSBool;

procedure Fatal();
begin
Result := False;
if FRender <> nil then
	DestroyRender();
end;

begin
if NewRenderClass = nil then
	begin
	Result := False;
	Exit;
	end;
Result := True;
try
	FRender := NewRenderClass.Create();
	FRender.Context := Self as ISContext;
	if FRender.CreateContext() then
		begin
		FRender.Init();
		FRenderClass    := NewRenderClass;
		FRenderClassOld := nil;
		end
	else
		Fatal();
except
	Fatal();
end;
end;

var
	DT1, DT2 : TSDateTime;
	OldRenderClassName : TSString = '';
	ResultSuccess : TSBool = False;
begin
OldRenderClassName := FRender.ClassName();
DT1.Get();
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSContext__ReinitializeRender() : Begining');
	{$ENDIF}
DeleteRenderResources();
if FRender <> nil then
	DestroyRender();
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSContext__ReinitializeRender() : After destroying, before creating');
	{$ENDIF}
ResultSuccess := InitNewRenderClass(FRenderClass);
if not ResultSuccess then
	ResultSuccess := InitNewRenderClass(FRenderClassOld);
if (not ResultSuccess) and (TSCompatibleRender <> nil) then
	ResultSuccess := InitNewRenderClass(TSCompatibleRender);
if not ResultSuccess then
	begin
	SHint('TSContext__ReinitializeRender() : Can''t initialize render.');
	Halt(1);
	end;
FRenderClassChanget := False;
LoadRenderResources();
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSContext__ReinitializeRender() : End');
	{$ENDIF}
DT2.Get();
SLog.Source('TSContext__ReinitializeRender : ' + OldRenderClassName + ' --> ' + FRender.ClassName() +' : Remaning ' + SSecondsToStringTime((DT2 - DT1).GetPastSeconds(), 'ENG') + SStr((DT2 - DT1).GetPastMilliseconds() mod 100) + ' ms.');
end;

procedure TSContext.SwapBuffers();
begin
if FRender <> nil then
	FRender.SwapBuffers();
end;

procedure TSContext.SetRenderClass(const NewRender : TSNamedClass);
begin
{$IFDEF CONTEXT_DEBUGING}
WriteLn('TSContext__SetRenderClass(...) : Begining');
	{$ENDIF}
FRenderClassOld := FRenderClass;
FRenderClass := TSRenderClass(NewRender);
if FInitialized and (not (Render is FRenderClass)) then
	begin
	FRenderClassChanget := True;
	end;
{$IFDEF CONTEXT_DEBUGING}
WriteLn('TSContext__SetRenderClass(...) : End');
	{$ENDIF}
end;

function TSContext.GetRender() : ISRender;
begin
Result := FRender;
end;

procedure TSContext.StartComputeTimer();
begin
FElapsedDateTime.Get();
FElapsedTime := 0;
end;

function TSContext.GetElapsedTime() : TSTimerInt;
begin
Result := FElapsedTime;
end;

function TSContext.GetTitle() : TSString;
begin
Result := FTitle;
end;

function TSContext.GetWidth() : TSAreaInt;
begin
Result := FWidth;
end;

function TSContext.GetHeight() : TSAreaInt;
begin
Result := FHeight;
end;

procedure TSContext.SetWidth(const VWidth : TSAreaInt);
begin
FWidth := VWidth;
end;

procedure TSContext.SetHeight(const VHeight : TSAreaInt);
begin
FHeight := VHeight;
end;

function TSContext.GetLeft() : TSAreaInt;
begin
Result := FLeft;
end;

function TSContext.GetTop() : TSAreaInt;
begin
Result := FTop;
end;

procedure TSContext.SetLeft(const VLeft : TSAreaInt);
begin
FLeft := VLeft;
end;

procedure TSContext.SetTop(const VTop : TSAreaInt);
begin
FTop := VTop;
end;

function  TSContext.GetFullscreen() : TSBoolean;
begin
Result := FFullscreen;
end;

procedure TSContext.SetActive(const VActive : TSBoolean);
begin
FActive := VActive;
end;

function  TSContext.GetActive():TSBoolean;
begin
Result := FActive;
end;

procedure TSContext.SetCursorCentered(const VCentered : TSBoolean);
var
	Point : TSPoint2int32;
begin
if (VCentered = FCursorInCenter) then
	exit;
FCursorInCenter := VCentered;
if (FCursorInCenter) then
	FDefaultCursorPosition := GetCursorPosition()
else
	SetCursorPosition(FDefaultCursorPosition);
if (@SetCursorPosition <> nil) and VCentered then
	begin
	FDefaultCursorPosition := GetCursorPosition();
	Point.Import(Trunc(Render.Width * 0.5), Trunc(Render.Height * 0.5));
	SetCursorPosition(Point);
	FCursorPosition[SLastCursorPosition] := Point;
	FCursorPosition[SNowCursorPosition] := Point;
	FCursorPosition[SDeferenseCursorPosition]:=0;
	end;
end;

function TSContext.GetCursorCentered() : TSBoolean;
begin
Result := FCursorInCenter;
end;

procedure TSContext.SetInterfaceLink(const VLink : PISContext);
begin
FInterfaceLink := VLink;
end;

function TSContext.GetInterfaceLink() : PISContext;
begin
Result := FInterfaceLink;
end;

function TSContext.GetCursor():TSCursor;
begin
Result := FCursor;
end;

procedure TSContext.SetCursor(const VCursor : TSCursor);
begin
SKill(FCursor);
FCursor := VCursor;
end;

function TSContext.GetIcon():TSBitMap;
begin
Result := FIcon;
end;

procedure TSContext.SetIcon(const VIcon : TSBitMap);
begin
if FIcon <> nil then
	FIcon.Destroy();
FIcon := VIcon;
end;

procedure TSContext.Initialize(const _WindowPlacement : TSContextWindowPlacement = SPlacementNormal);
begin
StartComputeTimer();
FInitialized := True;
if FPaintableClass <> nil then
	begin
	if (not FScreen.ContextAssigned()) then
		FScreen.Load(Self);
	CreateAudio();
	if (FPaintable = nil) and (FPaintableClass <> nil) then
		begin
		FPaintable := FPaintableClass.Create(Self);
		SetPaintableSettings();
		FPaintable.LoadRenderResources();
		end;
	end;
end;

procedure TSContext.UpdateTimer();
var
	DateTime : TSDateTime;
begin
if (not FElapsedDateTime.IsNull()) then
	begin
	DateTime.Get();
	FElapsedTime := (DateTime - FElapsedDateTime).GetPastMilliseconds();
	FElapsedDateTime := DateTime;
	end
else
	FElapsedTime := 0;
end;

procedure TSContext.Run();
begin
Messages();
StartComputeTimer();
while Active and (FNewContextType = nil) do
	begin
	if FVisible then
		if FIncessantlyPainting > 0 then
			Paint()
		else
			begin
			Sleep(200);
			Paint();
			end
	else
		Sleep(20);
	{$IFDEF CONTEXT_DEBUGING}
		WriteLn('TSContext__Run(): Before continue looping');
		{$ENDIF}
	if FRenderClassChanget then
		ReinitializeRender();
	end;
end;

procedure TSContext.PaintScreen();
begin
if (KeysPressed(S_CTRL_KEY)) and
   (KeysPressed(S_ALT_KEY)) and
   (KeyPressedType = SDownKey) and
   (KeyPressedChar = 'O') and
   TSEngineConfigurationPanel.CanCreate(FScreen) then // Ctrl + Alt + O
	begin
	FScreen.CreateInternalComponent(TSEngineConfigurationPanel.Create()).Resize();
	SetKey(SNullKey, 0);
	end;

FScreen.Paint();
end;

procedure TSContext.Paint();
begin
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSContext__Paint() : Begining, Before "UpdateTimer();"');
	{$ENDIF}
UpdateTimer();
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSContext__Paint() : Before "Render.Clear(...);"');
	{$ENDIF}
Render.Clear(SR_COLOR_BUFFER_BIT or SR_DEPTH_BUFFER_BIT);
if FPaintable <> nil then
	begin
	{$IFDEF CONTEXT_DEBUGING}
		WriteLn('TSContext__Paint() : Before "Render.InitMatrixMode(S_3D);" & "FPaintable.Paint();"');
		{$ENDIF}
	Render.InitMatrixMode(S_3D);
	FPaintable.Paint();
	end;
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSContext__Paint() : Before "ClearKeys();" & "Messages();"');
	{$ENDIF}
if FPaintWithHandlingMessages then
	begin
	ClearKeys();
	Messages();
	end;
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSContext__Paint() : Before "PaintScreen();"');
	{$ENDIF}
PaintScreen();
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSContext__Paint() : Before "SwapBuffers();"');
	{$ENDIF}
SwapBuffers();
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSContext__Paint() : End');
	{$ENDIF}
end;

procedure TSContext.SetTitle(const VTitle : TSString);
begin
FTitle := VTitle;
end;

procedure TSContext.InitFullscreen(const VFullscreen : TSBoolean);
begin
FFullscreen := VFullscreen;
Resize();
end;

function TSContext.KeyPressedType():TSCursorButtonType;
begin
Result:=FKeyPressedType;
end;

procedure TSContext.SetCursorKey(ButtonType:TSCursorButtonType;Key:TSCursorButton);
begin
FCursorKeyPressed     := Key;
FCursorKeyPressedType := ButtonType;
if Key <> SNullCursorButton then
	FCursorKeysPressed[Key] := ButtonType = SDownKey;
end;

procedure TSContext.SetKey(ButtonType:TSCursorButtonType;Key:LongInt);
begin
FKeysPressed[Key]:=ButtonType = SDownKey;
FKeyPressedType:=ButtonType;
FKeyPressed:=Key;
end;

procedure TSContext.Close();
begin
FActive:=False;
end;

function TSContext.ShiftClientArea() : TSPoint2int32;
begin
Result.Import(0,0);
end;

procedure TSContext.Resize();
begin
with FScreen do
	begin
	SetBounds(0, 0, ClientWidth, ClientHeight);
	BoundsMakeReal();
	Resize();
	end;
if (FPaintable <> nil) then
	FPaintable.Resize();
end;

function TSContext.CursorWheel():TSCursorWheel;
begin
Result := FCursorWheel;
end;

procedure TSContext.Messages();
var
	Point : TSPoint2int32;
begin
Point := GetCursorPosition();
Point -= ShiftClientArea();
FCursorPosition[SLastCursorPosition]:=FCursorPosition[SNowCursorPosition];
FCursorPosition[SNowCursorPosition]:=Point;
FCursorPosition[SDeferenseCursorPosition]:=FCursorPosition[SNowCursorPosition]-FCursorPosition[SLastCursorPosition];
if CursorCentered and (@SetCursorPosition<>nil) then
	begin
	Point.Import(Trunc(Render.Width*0.5),Trunc(Render.Height*0.5));
	SetCursorPosition(Point);
	FCursorPosition[SLastCursorPosition] := Point;
	FCursorPosition[SNowCursorPosition] := Point;
	end;

if  ((KeyPressed) and (KeyPressedByte=13) and (KeysPressed(S_ALT_KEY)) and (KeyPressedType=SDownKey)) or
	((KeyPressed) and (KeyPressedByte=122)  and (KeyPressedType=SDownKey)) then
	begin
	Fullscreen:= not Fullscreen;
	if ((KeyPressed) and (KeyPressedByte=13) and (KeysPressed(S_ALT_KEY)) and (KeyPressedType=SDownKey)) then
		SetKey(SUpKey, 13);
	end;
end;

function TSContext.CursorPosition(const Index : TSCursorPosition = SNowCursorPosition ) : TSPoint2int32;
begin
Result:=FCursorPosition[Index];
end;

function TSContext.CursorKeyPressed():TSCursorButton;
begin
Result:=FCursorKeyPressed;
end;

function TSContext.CursorKeyPressedType():TSCursorButtonType;
begin
Result:=FCursorKeyPressedType;
end;

function TSContext.CursorKeysPressed(const Index : TSCursorButton):Boolean;
begin
if Index = SNullCursorButton then
	Result:=False
else
	Result:=FCursorKeysPressed[Index];
end;

procedure TSContext.BeginIncessantlyPainting();
begin
FIncessantlyPainting += 1;
end;

procedure TSContext.EndIncessantlyPainting();
begin
if FIncessantlyPainting > 0 then
	FIncessantlyPainting -= 1;
end;

function  TSContext.GetClientWidth() : TSAreaInt;
begin
Result := FClientWidth;
end;

function  TSContext.GetClientHeight() : TSAreaInt;
begin
Result := FClientHeight;
end;

procedure TSContext.SetClientWidth(const VClientWidth : TSAreaInt);
begin
FClientWidth := VClientWidth;
end;

procedure TSContext.SetClientHeight(const VClientHeight : TSAreaInt);
begin
FClientHeight := VClientHeight;
end;

procedure TSContext.SetPaintableSettings();
var
	O : TSPaintableOption;
begin
if FPaintableSettings <> nil then
	begin
	if Length(FPaintableSettings) > 0 then
		begin
		if FPaintable <> nil then
			for O in FPaintableSettings do
					FPaintable.SetOption(O.FName, O.FOption);
		SetLength(FPaintableSettings, 0);
		end;
	FPaintableSettings := nil;
	end;
end;

function TSContext.GetAudioRender() : ISAudioRender;
begin
Result := nil;
if FAudioRender <> nil then
	Result := FAudioRender as ISAudioRender;
end;

procedure TSContext.SetVisible(const _Visible : TSBoolean);
begin
FVisible := _Visible;
end;

function  TSContext.GetVisible() : TSBoolean;
begin
Result := FVisible;
end;

constructor TSContext.Create();
var
	i:LongWord;
begin
inherited;
FExtendedLink := nil;
FInterfaceLink := nil;
FAudioRender := nil;
FLeft := 0;
FTop := 0;
FClientHeight := 0;
FClientWidth := 0;
FIncessantlyPainting := 1;
FRenderClassChanget := False;
FRenderClass := nil;
FRenderClassOld := nil;
FIcon := nil;
FCursor := nil;
FInitialized := False;
FShowCursor:=True;
FCursorInCenter:=False;
FDefaultCursorPosition.Import();
FWidth:=0;
FHeight:=0;
FTitle:='Smooth Window';
FFullscreen := False;
FActive := False;
FVisible := True;
FNewContextType:=nil;
for i:=0 to 255 do
	FKeysPressed[i]:=False;
FKeyPressed:=0;
FCursorPosition[SDeferenseCursorPosition].Import();
FCursorPosition[SNowCursorPosition].Import();
FCursorPosition[SLastCursorPosition].Import();
FCursorKeyPressed:=SNullCursorButton;
FCursorKeysPressed[SMiddleCursorButton]:=False;
FCursorKeysPressed[SLeftCursorButton]:=False;
FCursorKeysPressed[SRightCursorButton]:=False;
FRender:=nil;
FPaintWithHandlingMessages := True;
FPaintableSettings := nil;
FPaintableClass := nil;
FPaintable := nil;
FScreen := TSScreen.Create();
end;

procedure TSContext.ClearKeys();
begin
FCursorKeyPressed:=SNullCursorButton;
FKeyPressed:=0;
FCursorWheel:=SNullCursorWheel;
end;

procedure TSContext.Kill();
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
SKill(FScreen);
KillAudio();
if FRender <> nil then
	begin
	FRender.Destroy();
	FRender:=nil;
	end;
end;

destructor TSContext.Destroy();
begin
FActive := False;
Kill();
inherited;
end;

function TSContext.KeysPressed(const  Index : integer ) : Boolean;overload;
begin
Result:=FKeysPressed[Index];
end;

function TSContext.KeysPressed(const  Index : char ) : Boolean;overload;
begin
Result:=KeysPressed(LongWord(Index));
end;

function TSContext.KeyPressed() : TSBoolean;
begin
Result:=FKeyPressed<>0;
end;

function TSContext.KeyPressedChar() : TSChar;
begin
Result:=Char(FKeyPressed);
end;

function TSContext.KeyPressedByte() : TSLongWord;
begin
Result:=FKeyPressed;
end;

initialization
begin

end;

end.
