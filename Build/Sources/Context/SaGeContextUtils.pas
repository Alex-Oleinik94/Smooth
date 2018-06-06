{$INCLUDE SaGe.inc}

unit SaGeContextUtils;

interface

uses
	 SaGeBase
	,SaGeLists
	,SaGeAudioRender
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
	TSGCursorButton = (
		SGNullCursorButton,
		SGMiddleCursorButton, 
		SGLeftCursorButton,
		SGRightCursorButton);
	TSGCursorButtonType = (SGNullKey, SGDownKey, SGUpKey, SGDoubleClick);
	TSGCursorWheel = (SGNullCursorWheel, SGUpCursorWheel, SGDownCursorWheel);
	TSGCursorPosition = (
		SGDeferenseCursorPosition, // - Это разница между SGNowCursorPosition и SGLastCursorPosition
		SGNowCursorPosition,       // - Координаты мыши в настоящий момент
		SGLastCursorPosition);     // - Координаты мыши, полученые при преведущей итерации цикла
type
	TSGContextOption = TSGOption;
	TSGContextSettings = TSGSettings;
	TSGPaintableSettings = TSGSettings;
	TSGPaintableOption = TSGOption;

function SGContextOptionWidth(const VVariable : TSGUInt32) : TSGContextOption;
function SGContextOptionHeight(const VVariable : TSGUInt32) : TSGContextOption;
function SGContextOptionLeft(const VVariable : TSGUInt32) : TSGContextOption;
function SGContextOptionTop(const VVariable : TSGUInt32) : TSGContextOption;
function SGContextOptionFullscreen(const VVariable : TSGBoolean) : TSGContextOption;
function SGContextOptionMax() : TSGContextOption;
function SGContextOptionMin() : TSGContextOption;
function SGContextOptionTitle(const VVariable : TSGString) : TSGContextOption;
function SGContextOptionImport(const VName : TSGString; const VOption : TSGPointer) : TSGContextOption;
{$IFDEF ANDROID}
function SGContextOptionAndroidApp(const State : TSGPointer) : TSGContextOption;
{$ENDIF}
function SGContextOptionAudioRender(const VAudioRender : TSGAudioRenderClass) : TSGContextOption;

function SGContextOption(const VName : TSGString; var VSettings : TSGContextSettings) : TSGOptionPointer;
function SGContextSettingsCopy(const VSettings : TSGContextSettings ) : TSGContextSettings;

implementation

uses
	 SaGeStringUtils
	;

function SGContextOptionTitle(const VVariable : TSGString) : TSGContextOption;
begin
Result.Import('TITLE', SGStringToPChar(VVariable));
end;

function SGContextSettingsCopy(const VSettings : TSGContextSettings ) : TSGContextSettings;
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

function SGContextOption(const VName : TSGString; var VSettings : TSGContextSettings) : TSGOptionPointer;
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

end.
