{$INCLUDE SaGe.inc}

//{$DEFINE CONTEXT_DEBUGING}
//{$DEFINE CONTEXT_CHANGE_DEBUGING}

unit SaGeContext;

interface

uses
	 SaGeBase
	,SaGeLists
	,SaGeDateTime
	,SaGeRenderBase
	,SaGeRender
	,SaGeCommonClasses
	,SaGeClasses
	,SaGeBitMap
	,SaGeScreen
	,SaGeAudioRender
	,SaGeCursor
	,SaGeRenderInterface
	,SaGeAudioRenderInterface
	,SaGeCommonStructs
	,SaGeCasesOfPrint
	,SaGeContextUtils
	
	,Classes
	,Crt
	;

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
		function ShiftClientArea() : TSGPoint2int32; virtual;
		procedure SwapBuffers();virtual;
		procedure SetRenderClass(const NewRender : TSGPointer);virtual;
		procedure Kill();virtual;
		class function Suppored() : TSGBoolean; virtual;
		function GetDefaultWindowColor():TSGColor3f; virtual;
		procedure Minimize();virtual;
		procedure Maximize();virtual;
		procedure PrintBounds();
		class function UserProfilePath() : TSGString; virtual;
			public
		procedure ShowCursor(const VVisibility : TSGBoolean);virtual;
		function GetCursorPosition():TSGPoint2int32;virtual;abstract;
		procedure SetCursorPosition(const VPosition : TSGPoint2int32);virtual;abstract;
		function GetWindowArea():TSGPoint2int32;virtual;abstract;
		function GetScreenArea():TSGPoint2int32;virtual;abstract;
		function GetClientArea():TSGPoint2int32;virtual;abstract;
		function GetClientAreaShift() : TSGPoint2int32;virtual;abstract;
			protected
		FActive          : TSGBoolean;
		FInitialized     : TSGBoolean;
		FWidth, FHeight  : TSGAreaInt;
		FClientWidth, FClientHeight  : TSGAreaInt;
		FLeft, FTop      : TSGAreaInt;
		FFullscreen      : TSGBoolean;
		FTitle           : TSGString;
		FElapsedTime     : TSGTimerInt;
		FElapsedDateTime : TSGDateTime;
		FShowCursor      : TSGBoolean;
		FIcon            : TSGBitMap;
		FCursor          : TSGCursor;
		FIncessantlyPainting : TSGLongInt;
			protected
		FPaintWithHandlingMessages : TSGBoolean;
			protected
		procedure ReinitializeRender();virtual;
		function  GetRender() : ISGRender;virtual;
		procedure StartComputeTimer();virtual;
		function  GetElapsedTime() : TSGTimerInt;virtual;
		function  GetTitle() : TSGString;virtual;
		procedure SetTitle(const VTitle : TSGString);virtual;
		function  GetWidth() : TSGAreaInt;virtual;
		function  GetHeight() : TSGAreaInt;virtual;
		procedure SetWidth(const VWidth : TSGAreaInt);virtual;
		procedure SetHeight(const VHeight : TSGAreaInt);virtual;
		function  GetLeft() : TSGAreaInt;virtual;
		function  GetTop() : TSGAreaInt;virtual;
		procedure SetLeft(const VLeft : TSGAreaInt);virtual;
		procedure SetTop(const VTop : TSGAreaInt);virtual;
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
		procedure BeginIncessantlyPainting();virtual;
		procedure EndIncessantlyPainting();virtual;

		function  GetClientWidth() : TSGAreaInt;virtual;
		function  GetClientHeight() : TSGAreaInt;virtual;
		function  GetOption(const VName : TSGString) : TSGPointer;virtual;abstract;
		procedure SetOption(const VName : TSGString; const VValue : TSGPointer);virtual;abstract;
		procedure SetClientWidth(const VClientWidth : TSGAreaInt);virtual;
		procedure SetClientHeight(const VClientHeight : TSGAreaInt);virtual;
		function  GetWindow() : TSGPointer;virtual;
		function  GetDevice() : TSGPointer;virtual;
		function FileOpenDialog(const VTitle: TSGString; const VFilter : TSGString) : TSGString; virtual;abstract;
		function FileSaveDialog(const VTitle: TSGString; const VFilter : TSGString;const Extension : TSGString) : TSGString; virtual;abstract;
			public
		property SelfLink : PISGContext read GetSelfLink write SetSelfLink;
		property Fullscreen : TSGBoolean read GetFullscreen write InitFullscreen;
		property Active : TSGBoolean read GetActive write SetActive;
		property Cursor : TSGCursor read GetCursor write SetCursor;
		property Icon : TSGBitMap read GetIcon write SetIcon;
		property Left : TSGAreaInt read GetLeft write SetLeft;
		property Top : TSGAreaInt read GetTop write SetTop;
		property Width : TSGAreaInt read GetWidth write SetWidth;
		property Height : TSGAreaInt read GetHeight write SetHeight;
		property Title : TSGString read GetTitle write SetTitle;
		property Render : ISGRender read GetRender;
		property ElapsedTime : TSGTimerInt read GetElapsedTime;
		property CursorCentered : TSGBoolean read GetCursorCentered write SetCursorCentered;
		property Device : TSGPointer read GetDevice;
		property Window : TSGPointer read GetWindow;
		property ClientWidth : TSGAreaInt read GetClientWidth write SetClientWidth;
		property ClientHeight : TSGAreaInt read GetClientHeight write SetClientHeight;
			protected
		FKeysPressed      : packed array [0..255] of TSGBoolean;
		FKeyPressed       : TSGLongWord;
		FKeyPressedType   : TSGCursorButtonType;

		FCursorPosition       : packed array [TSGCursorPosition] of TSGPoint2int32;
		FCursorKeyPressed     : TSGCursorButton;
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
		function CursorKeyPressed():TSGCursorButton;virtual;
		function CursorKeyPressedType():TSGCursorButtonType;virtual;
		function CursorKeysPressed(const Index : TSGCursorButton ):TSGBoolean;virtual;
		function CursorWheel():TSGCursorWheel;virtual;
		function CursorPosition(const Index : TSGCursorPosition = SGNowCursorPosition ) : TSGPoint2int32;virtual;

		procedure SetKey(ButtonType:TSGCursorButtonType;Key:TSGLongInt);virtual;
		procedure SetCursorKey(ButtonType:TSGCursorButtonType;Key:TSGCursorButton);virtual;
		procedure SetCursorWheel(const VCursorWheel : TSGCursorWheel);virtual;
			public
		procedure MoveInfo(var FormerContext : TSGContext);virtual;
		procedure SetNewContext(const NewContextClass : TSGPointer);virtual;
			protected
		FNewContextType : TSGContextClass;
		FSelfLink       : PISGContext;
			protected
		FPaintableClass    : TSGDrawableClass;
		FPaintable         : TSGDrawable;
		FPaintableSettings : TSGPaintableSettings;
			protected
		FRenderClassOld     : TSGRenderClass;
		FRenderClass        : TSGRenderClass;
		FRenderClassChanget : TSGBoolean;
		FRender             : TSGRender;
			protected
		FScreen : TSGScreen;
			protected
		procedure SetPaintableSettings(); virtual;
		procedure KillRender(); virtual;
			private
		function GetScreen() : TSGPointer; virtual;
		procedure DestroyScreen(); virtual;
			public
		property NewContext : TSGContextClass read FNewContextType write FNewContextType;
		property Paintable : TSGDrawableClass write FPaintableClass;
		property RenderClass : TSGPointer write SetRenderClass;
		property PaintableSettings : TSGPaintableSettings write FPaintableSettings;
		property Screen : TSGScreen read FScreen;
			public
		procedure DeleteDeviceResources();
		procedure LoadDeviceResources();
			protected
		FAudioRender      : TSGAudioRender;
		FAudioRenderClass : TSGAudioRenderClass;
			protected
		function GetAudioRender() : ISGAudioRender;
		procedure CreateAudio();
		procedure KillAudio();
			public
		property AudioRender : ISGAudioRender read GetAudioRender;
		end;

function TSGCompatibleContext() : TSGContextClass;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SysUtils
	
	,SaGeLog
	,SaGeStringUtils
	,SaGeBaseUtils
	{$IFDEF MSWINDOWS}
		,SaGeContextWinAPI
		,SaGeNvidiaOptimusEnablement
		,SaGeNvidiaDriverSettingsUtils
		{$ENDIF}
	{$IFDEF LINUX}
		,SaGeContextLinux
		{$ENDIF}
	{$IFDEF ANDROID}
		,SaGeContextAndroid
		{$ENDIF}
	{$IFDEF DARWIN}
		,SaGeContextMacOSX
		{$ENDIF}
	{$IFDEF WITH_GLUT}
		,SaGeContextGLUT
		{$ENDIF}
	;

class function TSGContext.UserProfilePath() : TSGString;
begin
Result := '.';
end;

procedure TSGContext.CreateAudio();
begin
if FAudioRenderClass = nil then
	if 'AUDIORENDER' in FPaintableSettings then
		FAudioRenderClass := TSGAudioRenderClass(SGContextOption('AUDIORENDER', FPaintableSettings));
if FAudioRenderClass <> nil then
	begin
	if FAudioRender <> nil then
		KillAudio();
	FAudioRender := FAudioRenderClass.Create();
	FAudioRender.Initialize();
	end;
end;

procedure TSGContext.KillRender();
begin
if FRender <> nil then
	begin
	FRender.Destroy();
	FRender := nil;
	end;
end;

procedure TSGContext.KillAudio();
begin
if FAudioRender <> nil then
	begin
	FAudioRender.Destroy();
	FAudioRender := nil;
	end;
end;

procedure TSGContext.DestroyScreen();
begin
if FScreen <> nil then
	begin
	FScreen.Destroy();
	FScreen := nil;
	end;
end;

function TSGContext.GetScreen() : TSGPointer;
begin
Result := FScreen;
end;

procedure TSGContext.Minimize();
begin
end;

procedure TSGContext.Maximize();
begin
end;

procedure TSGContext.PrintBounds();
begin
WriteLn('L:', FLeft, ';T:', FTop);
WriteLn('W:', FWidth, ';H:', FHeight);
WriteLn('CW:', FClientWidth, ';CH:', FClientHeight);
end;

function TSGContext.GetDefaultWindowColor():TSGColor3f;
begin
Result.Import(1, 1, 1);
end;

function  TSGContext.GetWindow() : TSGPointer;
begin
Result := nil;
end;

function  TSGContext.GetDevice() : TSGPointer;
begin
Result := nil;
end;

class function TSGContext.Suppored() : TSGBoolean;
begin
Result := False;
end;

procedure TSGContext.SetNewContext(const NewContextClass : TSGPointer);
begin
FNewContextType := TSGContextClass(NewContextClass);
end;

procedure TSGContext.DeleteDeviceResources();
begin
if FPaintable <> nil then
	FPaintable.DeleteDeviceResources();
if Screen <> nil then
	Screen.DeleteDeviceResources();
end;

procedure TSGContext.LoadDeviceResources();
begin
if FPaintable <> nil then
	FPaintable.LoadDeviceResources();
if Screen <> nil then
	Screen.LoadDeviceResources();
end;

procedure TSGContext.MoveInfo(var FormerContext : TSGContext);
begin
if FormerContext = nil then
	Exit;
{$IFDEF CONTEXT_CHANGE_DEBUGING}
	SGLog.Source([ClassName(), '(',SGAddrStr(Self),')__MoveInfo(FormerContext=',SGAddrStr(FormerContext),'). Enter.']);
	{$ENDIF}
DestroyScreen();
FSelfLink      := FormerContext.FSelfLink;
FRenderClass   := FormerContext.FRenderClass;
FWidth         := FormerContext.FWidth;
FHeight        := FormerContext.FHeight;
FFullscreen    := FormerContext.FFullscreen;
FTitle         := FormerContext.FTitle;
FPaintable     := FormerContext.FPaintable;
FPaintableClass:= FormerContext.FPaintableClass;
FShowCursor    := FormerContext.FShowCursor;
FIcon          := FormerContext.FIcon;
FCursor        := TSGCursor.Copy(FormerContext.FCursor);
FScreen        := FormerContext.FScreen;
FAudioRender   := FormerContext.FAudioRender;
FormerContext.FScreen      := nil;
FormerContext.FPaintable   := nil;
FormerContext.FAudioRender := nil;
{$IFDEF CONTEXT_CHANGE_DEBUGING}
	SGLog.Source([ClassName(), '(',SGAddrStr(Self),')__MoveInfo(FormerContext=',SGAddrStr(FormerContext),'). Leave.']);
	{$ENDIF}
end;

function TSGCompatibleContext() : TSGContextClass;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result :=
	{$IFDEF MSWINDOWS}TSGContextWinAPI {$ELSE}
	{$IFDEF LINUX}    TSGContextLinux  {$ELSE}
	{$IFDEF ANDROID}  TSGContextAndroid{$ELSE}
	{$IFDEF DARWIN}   TSGContextMacOSX {$ELSE}
	                  nil
	{$ENDIF}   {$ENDIF}   {$ENDIF}    {$ENDIF}
	;
{$IFDEF WITH_GLUT}
if Result = nil then
	Result := TSGContextGLUT;
	{$ENDIF}
end;

procedure TSGContext.ShowCursor(const VVisibility : TSGBoolean);
begin
FShowCursor := VVisibility;
end;

procedure TSGContext.SetCursorWheel(const VCursorWheel : TSGCursorWheel);
begin
FCursorWheel := VCursorWheel;
end;

procedure TSGContext.ReinitializeRender();

procedure DestroyRender();
begin
FRender.Context := nil;
FRender.Destroy();
FRender := nil;
end;

function InitNewRenderClass(const NewRenderClass : TSGRenderClass) : TSGBool;

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
	FRender.Context := Self as ISGContext;
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
	DT1, DT2 : TSGDateTime;
	OldRenderClassName : TSGString = '';
	ResultSuccess : TSGBool = False;
begin
OldRenderClassName := FRender.ClassName();
DT1.Get();
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSGContext__ReinitializeRender() : Begining');
	{$ENDIF}
if FPaintable <> nil then
	FPaintable.DeleteDeviceResources();
Screen.DeleteDeviceResources();
if FRender <> nil then
	DestroyRender();
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSGContext__ReinitializeRender() : After destroying, before creating');
	{$ENDIF}
ResultSuccess := InitNewRenderClass(FRenderClass);
if not ResultSuccess then
	ResultSuccess := InitNewRenderClass(FRenderClassOld);
if (not ResultSuccess) and (TSGCompatibleRender <> nil) then
	ResultSuccess := InitNewRenderClass(TSGCompatibleRender);
if not ResultSuccess then
	begin
	SGHint('TSGContext__ReinitializeRender() : Can''t initialize render.');
	Halt(1);
	end;
FRenderClassChanget := False;
if FPaintable <> nil then
	FPaintable.LoadDeviceResources();
Screen.LoadDeviceResources();
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSGContext__ReinitializeRender() : End');
	{$ENDIF}
DT2.Get();
SGLog.Source('TSGContext__ReinitializeRender : ' + OldRenderClassName + ' --> ' + FRender.ClassName() +' : Remaning ' + SGSecondsToStringTime((DT2 - DT1).GetPastSeconds(), 'ENG') + SGStr((DT2 - DT1).GetPastMiliSeconds() mod 100) + ' ms.');
end;

procedure TSGContext.SwapBuffers();
begin
if FRender <> nil then
	FRender.SwapBuffers();
end;

procedure TSGContext.SetRenderClass(const NewRender : TSGPointer);
begin
{$IFDEF CONTEXT_DEBUGING}
WriteLn('TSGContext__SetRenderClass(...) : Begining');
	{$ENDIF}
FRenderClassOld := FRenderClass;
FRenderClass := TSGRenderClass(NewRender);
if FInitialized and (not (Render is FRenderClass)) then
	begin
	FRenderClassChanget := True;
	end;
{$IFDEF CONTEXT_DEBUGING}
WriteLn('TSGContext__SetRenderClass(...) : End');
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

function TSGContext.GetElapsedTime() : TSGTimerInt;
begin
Result := FElapsedTime;
end;

function TSGContext.GetTitle() : TSGString;
begin
Result := FTitle;
end;

function TSGContext.GetWidth() : TSGAreaInt;
begin
Result := FWidth;
end;

function TSGContext.GetHeight() : TSGAreaInt;
begin
Result := FHeight;
end;

procedure TSGContext.SetWidth(const VWidth : TSGAreaInt);
begin
FWidth := VWidth;
end;

procedure TSGContext.SetHeight(const VHeight : TSGAreaInt);
begin
FHeight := VHeight;
end;

function TSGContext.GetLeft() : TSGAreaInt;
begin
Result := FLeft;
end;

function TSGContext.GetTop() : TSGAreaInt;
begin
Result := FTop;
end;

procedure TSGContext.SetLeft(const VLeft : TSGAreaInt);
begin
FLeft := VLeft;
end;

procedure TSGContext.SetTop(const VTop : TSGAreaInt);
begin
FTop := VTop;
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
	Point : TSGPoint2int32;
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
	if not Screen.ContextAssigned() then
		Screen.Load(Self);
	CreateAudio();
	if (FPaintable = nil) and (FPaintableClass <> nil) then
		begin
		FPaintable := FPaintableClass.Create(Self);
		SetPaintableSettings();
		FPaintable.LoadDeviceResources();
		end;
	end;
end;

procedure TSGContext.UpdateTimer();
var
	DateTime : TSGDateTime;
begin
if (not FElapsedDateTime.IsNull()) then
	begin
	DateTime.Get();
	FElapsedTime := (DateTime - FElapsedDateTime).GetPastMiliSeconds();
	FElapsedDateTime := DateTime;
	end
else
	FElapsedTime := 0;
end;

procedure TSGContext.Run();
begin
Messages();
StartComputeTimer();
while Active and (FNewContextType = nil) do
	begin
	if FIncessantlyPainting > 0 then
		Paint()
	else
		begin
		Sleep(200);
		Paint();
		end;
	{$IFDEF CONTEXT_DEBUGING}
		WriteLn('TSGContext__Run(): Before continue looping');
		{$ENDIF}
	if FRenderClassChanget then
		ReinitializeRender();
	end;
end;

procedure TSGContext.Paint();
begin
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSGContext__Paint() : Begining, Before "UpdateTimer();"');
	{$ENDIF}
UpdateTimer();
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSGContext__Paint() : Before "Render.Clear(...);"');
	{$ENDIF}
Render.Clear(SGR_COLOR_BUFFER_BIT OR SGR_DEPTH_BUFFER_BIT);
if FPaintable <> nil then
	begin
	{$IFDEF CONTEXT_DEBUGING}
		WriteLn('TSGContext__Paint() : Before "Render.InitMatrixMode(SG_3D);" & "FPaintable.Paint();"');
		{$ENDIF}
	Render.InitMatrixMode(SG_3D);
	FPaintable.Paint();
	end;
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSGContext__Paint() : Before "ClearKeys();" & "Messages();"');
	{$ENDIF}
if FPaintWithHandlingMessages then
	begin
	ClearKeys();
	Messages();
	end;
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSGContext__Paint() : Before "Screen.Paint();"');
	{$ENDIF}
Screen.Paint();
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSGContext__Paint() : Before "SwapBuffers();"');
	{$ENDIF}
SwapBuffers();
{$IFDEF CONTEXT_DEBUGING}
	WriteLn('TSGContext__Paint() : End');
	{$ENDIF}
end;

procedure TSGContext.SetTitle(const VTitle : TSGString);
begin
FTitle := VTitle;
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

procedure TSGContext.SetCursorKey(ButtonType:TSGCursorButtonType;Key:TSGCursorButton);
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

function TSGContext.ShiftClientArea() : TSGPoint2int32;
begin
Result.Import(0,0);
end;

procedure TSGContext.Resize();
begin
Screen.Resize();
if FPaintable <> nil then
	FPaintable.Resize();
end;

function TSGContext.CursorWheel():TSGCursorWheel;
begin
Result := FCursorWheel;
end;

procedure TSGContext.Messages();
var
	Point : TSGPoint2int32;
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

if  ((KeyPressed) and (KeyPressedByte=13) and (KeysPressed(SG_ALT_KEY)) and (KeyPressedType=SGDownKey)) or
	((KeyPressed) and (KeyPressedByte=122)  and (KeyPressedType=SGDownKey)) then
	begin
	Fullscreen:= not Fullscreen;
	if ((KeyPressed) and (KeyPressedByte=13) and (KeysPressed(SG_ALT_KEY)) and (KeyPressedType=SGDownKey)) then
		SetKey(SGUpKey, 13);
	end;
end;

function TSGContext.CursorPosition(const Index : TSGCursorPosition = SGNowCursorPosition ) : TSGPoint2int32;
begin
Result:=FCursorPosition[Index];
end;

function TSGContext.CursorKeyPressed():TSGCursorButton;
begin
Result:=FCursorKeyPressed;
end;

function TSGContext.CursorKeyPressedType():TSGCursorButtonType;
begin
Result:=FCursorKeyPressedType;
end;

function TSGContext.CursorKeysPressed(const Index : TSGCursorButton):Boolean;
begin
if Index = SGNullCursorButton then
	Result:=False
else
	Result:=FCursorKeysPressed[Index];
end;

procedure TSGContext.BeginIncessantlyPainting();
begin
FIncessantlyPainting += 1;
end;

procedure TSGContext.EndIncessantlyPainting();
begin
if FIncessantlyPainting > 0 then
	FIncessantlyPainting -= 1;
end;

function  TSGContext.GetClientWidth() : TSGAreaInt;
begin
Result := FClientWidth;
end;

function  TSGContext.GetClientHeight() : TSGAreaInt;
begin
Result := FClientHeight;
end;

procedure TSGContext.SetClientWidth(const VClientWidth : TSGAreaInt);
begin
FClientWidth := VClientWidth;
end;

procedure TSGContext.SetClientHeight(const VClientHeight : TSGAreaInt);
begin
FClientHeight := VClientHeight;
end;

procedure TSGContext.SetPaintableSettings();
var
	O : TSGPaintableOption;
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

function TSGContext.GetAudioRender() : ISGAudioRender;
begin
Result := nil;
if FAudioRender <> nil then
	Result := FAudioRender as ISGAudioRender;
end;

constructor TSGContext.Create();
var
	i:LongWord;
begin
inherited;
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
FPaintableSettings := nil;
FPaintableClass := nil;
FPaintable := nil;
FScreen := TSGScreen.Create();
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
if FScreen <> nil then
	begin
	FScreen.Destroy();
	FScreen := nil;
	end;
KillAudio();
if FRender <> nil then
	begin
	FRender.Destroy();
	FRender:=nil;
	end;
end;

destructor TSGContext.Destroy();
begin
FActive := False;
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
