{$INCLUDE Smooth.inc}

unit SmoothContextUtils;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothAudioRender
	{$IF defined(ANDROID)}
		,android_native_app_glue
		{$ENDIF}
	;

const
	S_ALT_KEY = 18;
	S_CTRL_KEY = 17;
	S_SHIFT_KEY = 16;
	S_ESC_KEY = 27;
	S_ESCAPE_KEY = S_ESC_KEY;
type
	TSCursorButton = (
		SNullCursorButton,
		SMiddleCursorButton, 
		SLeftCursorButton,
		SRightCursorButton);
	TSCursorButtonType = (SNullKey, SDownKey, SUpKey, SDoubleClick);
	TSCursorWheel = (SNullCursorWheel, SUpCursorWheel, SDownCursorWheel);
	TSCursorPosition = (
		SDeferenseCursorPosition, // - Это разница между SNowCursorPosition и SLastCursorPosition
		SNowCursorPosition,       // - Текущие координаты курсора
		SLastCursorPosition);     // - Координаты курсора, полученные в предыдущей итерации цикла
type
	TSContextOption = TSOption;
	TSContextSettings = TSSettings;
	TSPaintableSettings = TSSettings;
	TSPaintableOption = TSOption;
const
	SCMaximizedWindow = 'MaximizedWindow';
	SCMinimizedWindow = 'MinimizedWindow';
	SCFullscreenWindow = 'FullscreenWindow';
type
	TSContextWindowPlacement = (SPlacementNormal, SPlacementMaximized, SPlacementMinimized);

function SContextOptionWidth(const VVariable : TSUInt32) : TSContextOption;
function SContextOptionHeight(const VVariable : TSUInt32) : TSContextOption;
function SContextOptionLeft(const VVariable : TSUInt32) : TSContextOption;
function SContextOptionTop(const VVariable : TSUInt32) : TSContextOption;
function SContextOptionFullscreen(const VVariable : TSBoolean) : TSContextOption;
function SContextOptionMax() : TSContextOption;
function SContextOptionMin() : TSContextOption;
function SContextOptionTitle(const VVariable : TSString) : TSContextOption;
function SContextOptionImport(const VName : TSString; const VOption : TSPointer) : TSContextOption;
{$IFDEF ANDROID}
function SContextOptionAndroidApp(const State : TSPointer) : TSContextOption;
{$ENDIF}
function SContextOptionAudioRender(const VAudioRender : TSAudioRenderClass) : TSContextOption;

function SContextOption(const VName : TSString; var VSettings : TSContextSettings) : TSOptionPointer;
function SContextSettingsCopy(const VSettings : TSContextSettings ) : TSContextSettings;

implementation

uses
	 SmoothStringUtils
	;

function SContextOptionTitle(const VVariable : TSString) : TSContextOption;
begin
Result.Import('TITLE', SStringToPChar(VVariable));
end;

function SContextSettingsCopy(const VSettings : TSContextSettings ) : TSContextSettings;
var
	i : TSUInt32;
begin
Result := nil;
if VSettings <> nil then if Length(VSettings) > 0 then
	begin
	SetLength(Result, Length(VSettings));
	for i := 0 to High(Result) do
		Result[i] := VSettings[i];
	end;
end;

function SContextOptionMax() : TSContextOption;
begin
Result.Import(SCMaximizedWindow, nil);
end;

function SContextOptionMin() : TSContextOption;
begin
Result.Import(SCMaximizedWindow, nil);
end;

function SContextOptionImport(const VName : TSString; const VOption : TSPointer) : TSContextOption;
begin
Result.Import(VName, VOption);
end;

function SContextOptionWidth(const VVariable : TSLongWord) : TSContextOption;
begin
Result.Import('WIDTH', TSPointer(VVariable));
end;

function SContextOptionHeight(const VVariable : TSLongWord) : TSContextOption;
begin
Result.Import('HEIGHT', TSPointer(VVariable));
end;

function SContextOptionLeft(const VVariable : TSLongWord) : TSContextOption;
begin
Result.Import('LEFT', TSPointer(VVariable));
end;

function SContextOptionAudioRender(const VAudioRender : TSAudioRenderClass) : TSContextOption;
begin
Result.Import('AUDIORENDER', TSPointer(VAudioRender));
end;

function SContextOptionTop(const VVariable : TSLongWord) : TSContextOption;
begin
Result.Import('TOP', TSPointer(VVariable));
end;

function SContextOptionFullscreen(const VVariable : TSBoolean) : TSContextOption;
begin
Result.Import(SCFullscreenWindow, TSPointer(TSByte(VVariable)));
end;

{$IFDEF ANDROID}
function SContextOptionAndroidApp(const State : TSPointer) : TSContextOption;
begin
Result.Import('ANDROIDAPP', State);
end;
{$ENDIF}

function SContextOption(const VName : TSString; var VSettings : TSContextSettings) : TSOptionPointer;
var
	O, OSets : TSOption;
	Sets : TSBool = False;
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

end.
