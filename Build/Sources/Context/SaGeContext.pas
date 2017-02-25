{$INCLUDE SaGe.inc}

//{$DEFINE CONTEXT_DEBUGING}
//{$DEFINE CONTEXT_CHANGE_DEBUGING}

unit SaGeContext;

interface

uses
	 SaGeBase
	,SaGeDateTime
	,SaGeCommon
	,SaGeRenderBase
	,SaGeRender
	,SaGeCommonClasses
	,SaGeClasses
	,SaGeBitMap
	,SaGeScreen
	,SaGeAudioRender
	,SaGeCursor
	,SaGeRenderInterface
	
	,Classes
	,Crt
	
	{$IF defined(ANDROID)}
		,android_native_app_glue
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
	TSGContextOption = TSGOption;
	TSGContextSettings = TSGSettings;
	TSGPaintableSettings = TSGSettings;
	TSGPaintableOption = TSGOption;
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
		function FileOpenDialog(const VTittle: TSGString; const VFilter : TSGString) : TSGString; virtual;abstract;
		function FileSaveDialog(const VTittle: TSGString; const VFilter : TSGString;const Extension : TSGString) : TSGString; virtual;abstract;
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
		function CursorPosition(const Index : TSGCursorPosition = SGNowCursorPosition ) : TSGPoint2int32;virtual;

		procedure SetKey(ButtonType:TSGCursorButtonType;Key:TSGLongInt);virtual;
		procedure SetCursorKey(ButtonType:TSGCursorButtonType;Key:TSGCursorButtons);virtual;
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

function SGContextOptionWidth(const VVariable : TSGLongWord) : TSGContextOption;
function SGContextOptionHeight(const VVariable : TSGLongWord) : TSGContextOption;
function SGContextOptionLeft(const VVariable : TSGLongWord) : TSGContextOption;
function SGContextOptionTop(const VVariable : TSGLongWord) : TSGContextOption;
function SGContextOptionFullscreen(const VVariable : TSGBoolean) : TSGContextOption;
function SGContextOptionMax() : TSGContextOption;
function SGContextOptionMin() : TSGContextOption;
function SGContextOptionTitle(const VVariable : TSGString) : TSGContextOption;
function SGContextOptionImport(const VName : TSGString; const VOption : TSGPointer) : TSGContextOption;
{$IFDEF ANDROID}
function SGContextOptionAndroidApp(const State : TSGPointer) : TSGContextOption;
{$ENDIF}
function SGContextOptionAudioRender(const VAudioRender : TSGAudioRenderClass) : TSGContextOption;

function SGCopyContextSettings(const VSettings : TSGContextSettings ) : TSGContextSettings;
function SGProcessContextOption(const VName : TSGString; var VSettings : TSGContextSettings) : TSGOptionPointer;

function TSGCompatibleContext() : TSGContextClass;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SGRunPaintable(const VPaintableClass : TSGDrawableClass; const VContextClass : TSGContextClass; const VRenderClass : TSGRenderClass; const VSettings : TSGContextSettings = nil);
procedure SGCompatibleRunPaintable(const VPaintableClass : TSGDrawableClass; const VSettings : TSGContextSettings = nil);
function SGTryChangeContextType(var Context : TSGContext; var IContext : ISGContext):TSGBoolean;
procedure SGPrintContextSettings(const VSettings : TSGContextSettings);
function SGSetContextSettings(var Context : TSGContext; var Settings : TSGContextSettings):TSGContextSettings;

implementation

uses
	 SysUtils
	
	,SaGeStringUtils
	,SaGeLog
	,SaGeBaseUtils
	{$IFDEF MSWINDOWS}
		,SaGeContextWinApi
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

function SGProcessContextOption(const VName : TSGString; var VSettings : TSGContextSettings) : TSGOptionPointer;
var
	O, OSets : TSGOption;
	Sets : TSGBool = False;
begin
Result := nil;
for O in VSettings do
	if O.FName = VName then
		begin
		OSets := O;
		Sets := True;
		break;
		end;
if Sets then
	begin
	Result := OSets.FOption;
	VSettings -= OSets;
	end;
end;

class function TSGContext.UserProfilePath() : TSGString;
begin
Result := '.';
end;

procedure TSGContext.CreateAudio();
begin
if FAudioRenderClass = nil then
	if 'AUDIORENDER' in FPaintableSettings then
		FAudioRenderClass := TSGAudioRenderClass(SGProcessContextOption('AUDIORENDER', FPaintableSettings));
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

function SGCopyContextSettings(const VSettings : TSGContextSettings ) : TSGContextSettings;
var
	i : TSGUInt32;
begin
Result := nil;
if VSettings <> nil then if Length(VSettings) > 0 then
	begin
	SetLength(Result, Length(VSettings));
	for i := 0 to High(Result) do
		Result[i] := VSettings[i];
	end;
end;

procedure SGCompatibleRunPaintable(const VPaintableClass : TSGDrawableClass; const VSettings : TSGContextSettings = nil);
var
	Settings : TSGContextSettings = nil;
begin
Settings := SGCopyContextSettings(VSettings);
if not ('AUDIORENDER' in Settings) then if TSGCompatibleAudioRender <> nil then
	Settings += SGContextOptionAudioRender(TSGCompatibleAudioRender);
SGRunPaintable(VPaintableClass, TSGCompatibleContext, TSGCompatibleRender, Settings);
SetLength(Settings, 0);
end;

function SGContextOptionMax() : TSGContextOption;
begin
Result.Import('MAX', nil);
end;

function SGContextOptionMin() : TSGContextOption;
begin
Result.Import('MIN', nil);
end;

function SGContextOptionImport(const VName : TSGString; const VOption : TSGPointer) : TSGContextOption;
begin
Result.Import(VName, VOption);
end;

procedure SGPrintContextSettings(const VSettings : TSGContextSettings);

function WordName(const S : TSGString):TSGString;
begin
Result := SGDownCaseString(S);
if Length(Result) > 0 then
	Result[1] := UpCase(Result[1]);
end;

var
	O : TSGContextOption;
	First : TSGBoolean = True;
	S : TSGString = '';
	StandartOptions : TSGStringList = nil;
	i : TSGUInt32;
begin
if VSettings = nil then
	exit;
if Length(VSettings) = 0 then
	exit;
S += 'Options (';
StandartOptions += 'WIDTH';
StandartOptions += 'HEIGHT';
StandartOptions += 'LEFT';
StandartOptions += 'TOP';
for O in VSettings do
	begin
	if First then
		First := False
	else
		S += ', ';
	if (O.FName = 'FULLSCREEN') and (TSGMaxEnum(O.FOption) = 0) then
		S += '!';
	if O.FName = 'AUDIORENDER' then
		S += 'Audio'
	else
		S += WordName(O.FName);
	if O.FName in StandartOptions then
		begin
		S += '=' + SGStr(TSGMaxEnum(O.FOption));
		end
	else if O.FName = 'AUDIORENDER' then
		S += ' is ' + TSGAudioRenderClass(O.FOption).ClassName()
	else if O.FName = 'TITLE' then
		begin
		S += '=' + '''' + SGPCharToString(PChar(O.FOption)) + '''';
		end
	else if (O.FName = 'FILES TO OPEN') then
		begin
		S += '=[';
		if Length(TSGStringList(O.FOption)) > 0 then
			for i := 0 to High(TSGStringList(O.FOption)) do
				begin
				if i <> 0 then
					S += ', ';
				S += '`' + TSGStringList(O.FOption)[i] + '`';
				end;
		S += ']';
		end
	else if (O.FName = 'MIN') or (O.FName = 'MAX') or (O.FName = 'FULLSCREEN') then
		begin
		end
	else
		begin
		S += '=' + SGAddrStr(O.FOption);
		end;
	end;
SetLength(StandartOptions, 0);
S += ')';
SGHint(S);
S := '';
end;

function SGContextOptionWidth(const VVariable : TSGLongWord) : TSGContextOption;
begin
Result.Import('WIDTH', TSGPointer(VVariable));
end;

function SGContextOptionHeight(const VVariable : TSGLongWord) : TSGContextOption;
begin
Result.Import('HEIGHT', TSGPointer(VVariable));
end;

function SGContextOptionLeft(const VVariable : TSGLongWord) : TSGContextOption;
begin
Result.Import('LEFT', TSGPointer(VVariable));
end;

function SGContextOptionAudioRender(const VAudioRender : TSGAudioRenderClass) : TSGContextOption;
begin
Result.Import('AUDIORENDER', TSGPointer(VAudioRender));
end;

function SGContextOptionTop(const VVariable : TSGLongWord) : TSGContextOption;
begin
Result.Import('TOP', TSGPointer(VVariable));
end;

function SGContextOptionFullscreen(const VVariable : TSGBoolean) : TSGContextOption;
begin
Result.Import('FULLSCREEN', TSGPointer(TSGByte(VVariable)));
end;

{$IFDEF ANDROID}
function SGContextOptionAndroidApp(const State : TSGPointer) : TSGContextOption;
begin
Result.Import('ANDROIDAPP', State);
end;
{$ENDIF}

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

function SGTryChangeContextType(var Context : TSGContext; var IContext : ISGContext):TSGBoolean;
// Result = True : Continue loop
// Result = False : Exit loop
var
	NewContext : TSGContext = nil;
	OldContextName : TSGString = '';
begin
Result := False;
{$IFDEF CONTEXT_CHANGE_DEBUGING}
	SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(Context),', IContext=',SGAddrStr(IContext),'). Enter.']);
	{$ENDIF}
if (Context.NewContext <> nil) and (Context.Active or (not (Context is Context.NewContext))) then
	begin
	OldContextName := Context.ClassName();
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(Context),', IContext=',SGAddrStr(IContext),'). Begin changing.']);
		SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(Context),', IContext=',SGAddrStr(IContext),'). Creating new context.']);
		{$ENDIF}
	NewContext := Context.NewContext.Create();
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(Context),', IContext=',SGAddrStr(IContext),'). Delete old context device recources.']);
		{$ENDIF}
	Context.DeleteDeviceResources();
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(Context),', IContext=',SGAddrStr(IContext),'). Moving info.']);
		{$ENDIF}
	NewContext.MoveInfo(Context);
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(Context),', IContext=',SGAddrStr(IContext),'). Change "IContext".']);
		{$ENDIF}
	IContext := NewContext;
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(Context),', IContext=',SGAddrStr(IContext),'). Destroying old context.']);
		{$ENDIF}
	Context.Destroy();
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(Context),', IContext=',SGAddrStr(IContext),'). Initializing new context.']);
		{$ENDIF}
	Context := NewContext;
	Context.Initialize();
	Context.LoadDeviceResources();
	Result := Context.Active;
	SGHint(['Changing context (`' + OldContextName + '` --> `' + Context.ClassName() + '`)' + Iff(Result, ' successfull.', ' failed!')]);
	end;
{$IFDEF CONTEXT_CHANGE_DEBUGING}
	SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(Context),', IContext=',SGAddrStr(IContext),'). Leave.']);
	{$ENDIF}
end;

function SGContextOptionTitle(const VVariable : TSGString) : TSGContextOption;
begin
Result.Import('TITLE', SGStringToPChar(VVariable));
end;

function SGSetContextSettings(var Context : TSGContext; var Settings : TSGContextSettings):TSGContextSettings;
var
	O : TSGContextOption;
begin
Result := nil;
for O in Settings do
	begin
	if O.FName  = 'WIDTH' then
		Context.Width := TSGMaxEnum(O.FOption)
	else if O.FName  = 'HEIGHT' then
		Context.Height := TSGMaxEnum(O.FOption)
	else if O.FName  = 'LEFT' then
		Context.Left := TSGMaxEnum(O.FOption)
	else if O.FName  = 'TOP' then
		Context.Top := TSGMaxEnum(O.FOption)
	else if O.FName  = 'FULLSCREEN' then
		Context.Fullscreen := TSGBool(TSGMaxEnum(O.FOption))
	else if O.FName  = 'CURSOR' then
		Context.Cursor := TSGCursor(O.FOption)
	else if O.FName  = 'TITLE' then
		begin
		Context.Title := SGPCharToString(PChar(O.FOption));
		FreeMem(O.FOption);
		end
	{$IFDEF ANDROID}
	else if (Context is TSGContextAndroid) and (O.FName = 'ANDROIDAPP') then
		(Context as TSGContextAndroid).AndroidApp := PAndroid_App(O.FOption)
		{$ENDIF}
	else
		begin
		Result += O;
		end;
	end;
if not ('WIDTH' in Settings) then
	Context.Width  := Context.GetScreenArea().x;
if not ('HEIGHT' in Settings) then
	Context.Height  := Context.GetScreenArea().y;
if not ('FULLSCREEN' in Settings) then
	Context.Fullscreen := {$IFDEF ANDROID}True{$ELSE}False{$ENDIF};
if not ('CURSOR' in Settings) then
	Context.Cursor := TSGCursor.Create(SGC_NORMAL);
if not ('TITLE' in Settings) then
	Context.Title := 'SaGe Engine Window';
end;

procedure SGRunPaintable(const VPaintableClass : TSGDrawableClass; const VContextClass : TSGContextClass; const VRenderClass : TSGRenderClass; const VSettings : TSGContextSettings = nil);
var
	Context : TSGContext = nil;
	IContext : ISGContext = nil;
	Settings : TSGContextSettings = nil;
var
	PaintableSettings : TSGPaintableSettings = nil;
	Placement : TSGByte = 0;

procedure CheckPlacement();
var
	MinExists, MaxExists : TSGBool;
begin
MinExists := ('MIN' in PaintableSettings);
MaxExists := ('MAX' in PaintableSettings);
if MaxExists or MinExists then
	begin
	if MinExists xor MaxExists then
		begin
		PaintableSettings -= (Iff(MinExists, 'MIN','') + Iff(MaxExists, 'MAX',''));
		Placement := 2 * Byte(MaxExists) + 1 * Byte(MinExists);
		end
	else
		begin
		PaintableSettings -= 'MAX';
		PaintableSettings -= 'MIN';
		SGHint('Run : warning : maximization and minimization are not available at the same time!');
		end;
	end;
end;

procedure InitPlacement();
begin
case Placement of
2 : Context.Maximize();
1 : Context.Minimize();
end;
end;

begin
SGHint('Run (Class = `'+VPaintableClass.ClassName() +'`, Context = `'+VContextClass.ClassName()+'`, Render = `'+VRenderClass.ClassName()+'`)');
SGPrintContextSettings(VSettings);
Settings := VSettings;
if not VRenderClass.Suppored then
	begin
	SGHint(VRenderClass.ClassName() + ' not suppored!');
	SetLength(Settings, 0);
	exit;
	end;

Context := VContextClass.Create();
IContext := Context;

PaintableSettings := SGSetContextSettings(Context, Settings);
CheckPlacement();
Context.PaintableSettings := PaintableSettings;
Context.SelfLink := @IContext;
Context.RenderClass := VRenderClass;
Context.Paintable := VPaintableClass;

Context.Initialize();
if Context.Active then
	begin
	InitPlacement();
	repeat
	Context.Run();
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SGHint
	{$ELSE CONTEXT_CHANGE_DEBUGING}
		SGLog.Source
	{$ENDIF CONTEXT_CHANGE_DEBUGING}
			(['Leving from ', Context.ClassName(), ' loop!']);
	until not SGTryChangeContextType(Context, IContext);
	end;
Context.Kill();
IContext := nil;
Context.Destroy();
Context := nil;
SetLength(Settings, 0);
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
