{$INCLUDE SaGe.inc}
//{$DEFINE NVDRS_DEBUG}

unit SaGeNvidiaDriverSettingsUtils;

interface

uses
	 SaGeBase
	,SaGeCasesOfPrint
	
	// NVidia
	,NvApiDriverSettings
	,nvapi_lite_common
	;

function SGNVidiaGetNumProfilies(const hSession : NvDRSSessionHandle) : NvU32;

type
	TSGNVidiaDriverModeOptimus = (
		SGNVidiaBase,
		SGNVidiaCurrentGlobal);
	TSGNVidiaDriverOptimusMode = (
		SGNVidiaUnknown,
		SGNVidiaHighPerfomance,
		SGNVidiaIntegrated,
		SGNVidiaAutoSelect);

function SGNVidiaStrDriverOptimusMode(const Mode : TSGNVidiaDriverOptimusMode) : TSGString;
function SGNVidiaSetDriverOptimusMode(const Mode : TSGNVidiaDriverOptimusMode = SGNVidiaHighPerfomance) : TSGBoolean;
function SGNVidiaGetDriverOptimusMode(const Mode : TSGNVidiaDriverModeOptimus = SGNVidiaBase) : TSGNVidiaDriverOptimusMode;
procedure SGNVidiaViewDriverSetting(const Setting : NvU32; const Mode : TSGNVidiaDriverModeOptimus = SGNVidiaBase; const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]); overload;
procedure SGNVidiaViewDriverSetting(const Setting : NVDRS_SETTING; const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]); overload;

function SGNvApiStrBinarySetting(const BinarySetting : NVDRS_BINARY_SETTING) : TSGString;

implementation

uses
	 SaGeLog
	,SaGeDllManager
	,SaGeDateTime
	,SaGeStringUtils
	;

procedure SGNVidiaViewDriverSetting(const Setting : NVDRS_SETTING; const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]); overload;
begin
SGHint('Driver setting: ', CasesOfPrint);
SGHint(['    Version = ', Setting.version], CasesOfPrint);
SGHint(['    Setting name = ', Setting.settingName], CasesOfPrint);
SGHint(['    Setting ID = ', Setting.settingId], CasesOfPrint);
SGHint(['    Setting type = ', Setting.settingType], CasesOfPrint);
SGHint(['    Setting location = ', Setting.settingLocation], CasesOfPrint);
SGHint(['    Is current predefined = ', Setting.isCurrentPredefined], CasesOfPrint);
SGHint(['    Is predefined valid = ', Setting.isPredefinedValid], CasesOfPrint);
SGHint(['    Predefined : Value (uint32) = ', Setting.u32PredefinedValue], CasesOfPrint);
SGHint(['    Predefined : Binary value = ', SGNvApiStrBinarySetting(Setting.binaryPredefinedValue)], CasesOfPrint);
SGHint(['    Predefined : Value (wide string) = ', Setting.wszPredefinedValue], CasesOfPrint);
SGHint(['    Current : Value (uint32) = ', Setting.u32CurrentValue], CasesOfPrint);
SGHint(['    Current : Binary value = ', SGNvApiStrBinarySetting(Setting.binaryCurrentValue)], CasesOfPrint);
SGHint(['    Current : Value (wide string) = ', Setting.wszCurrentValue], CasesOfPrint);
end;

procedure SGNVidiaViewDriverSetting(const Setting : NvU32; const Mode : TSGNVidiaDriverModeOptimus = SGNVidiaBase; const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]);
var
	hSession : NvDRSSessionHandle;
	status : NvAPI_Status;
	hProfile : NvDRSProfileHandle;
	drsSetting : NVDRS_SETTING;
begin
if not DllManager.Supported('nvapi') then
	exit;

hSession := 0;
status := NvAPI_DRS_CreateSession(@hSession);
if (status <> NVAPI_OK) then
	exit;

status := NvAPI_DRS_LoadSettings(hSession);
if (status <> NVAPI_OK) then 
	begin
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

hProfile := 0;
if Mode = SGNVidiaBase then
	status := NvAPI_DRS_GetBaseProfile(hSession, @hProfile)
else
	status := NvAPI_DRS_GetCurrentGlobalProfile(hSession, @hProfile);
if (status <> NVAPI_OK) then 
	begin
	SGHint(['NVidia : View driver setting : Get*?Profile error : ', SGNvApiStrStatus(status), '!'], [SGCaseLog{$IFDEF NVDRS_DEBUG}, SGCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

fillchar(drsSetting, SizeOf(drsSetting), 0);
drsSetting.version := NVDRS_SETTING_VER;
drsSetting.settingId := Setting;
drsSetting.settingType := NVDRS_DWORD_TYPE;

status := NvAPI_DRS_GetSetting(hSession, hProfile, Setting, @drsSetting);
if (status <> NVAPI_OK) then
	begin
	SGHint(['NVidia : View driver setting : GetSetting error : ', SGNvApiStrStatus(status), '!'], [SGCaseLog{$IFDEF NVDRS_DEBUG}, SGCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

SGNVidiaViewDriverSetting(drsSetting, CasesOfPrint);

NvAPI_DRS_DestroySession(hSession);
end;

function SGNVidiaGetDriverOptimusMode(const Mode : TSGNVidiaDriverModeOptimus = SGNVidiaBase) : TSGNVidiaDriverOptimusMode;
var
	hSession : NvDRSSessionHandle;
	status : NvAPI_Status;
	hProfile : NvDRSProfileHandle;
	drsSetting : NVDRS_SETTING;
begin
Result := SGNVidiaUnknown;
if not DllManager.Supported('nvapi') then
	exit;

hSession := 0;
status := NvAPI_DRS_CreateSession(@hSession);
if (status <> NVAPI_OK) then
	begin
	SGHint(['NvAPI_DRS_CreateSession error : ', SGNvApiStrStatus(status), '!'], [SGCaseLog{$IFDEF NVDRS_DEBUG}, SGCasePrint{$ENDIF}], True);
	exit;
	end;

status := NvAPI_DRS_LoadSettings(hSession);
if (status <> NVAPI_OK) then 
	begin
	SGHint(['NvAPI_DRS_LoadSettings error : ', SGNvApiStrStatus(status), '!'], [SGCaseLog{$IFDEF NVDRS_DEBUG}, SGCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

//WriteLn('SGNVidiaGetNumProfilies=',SGNVidiaGetNumProfilies(hSession));

hProfile := 0;
if Mode = SGNVidiaBase then
	status := NvAPI_DRS_GetBaseProfile(hSession, @hProfile)
else
	status := NvAPI_DRS_GetCurrentGlobalProfile(hSession, @hProfile);
if (status <> NVAPI_OK) then 
	begin
	SGHint(['NvAPI_DRS_GetBaseProfile error : ', SGNvApiStrStatus(status), '!'], [SGCaseLog{$IFDEF NVDRS_DEBUG}, SGCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

fillchar(drsSetting, SizeOf(drsSetting), 0);
drsSetting.version := NVDRS_SETTING_VER;
drsSetting.settingId := SHIM_MCCOMPAT_ID;
drsSetting.settingType := NVDRS_DWORD_TYPE;

status := NvAPI_DRS_GetSetting(hSession, hProfile, SHIM_MCCOMPAT_ID, @drsSetting);
if (status <> NVAPI_OK) then
	begin
	SGHint(['NVidia : Get driver optimus mode : GetSetting error : ', SGNvApiStrStatus(status), '!'], [SGCaseLog{$IFDEF NVDRS_DEBUG}, SGCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;
if(drsSetting.u32CurrentValue = SHIM_MCCOMPAT_ENABLE) then
	Result := SGNVidiaHighPerfomance
else if(drsSetting.u32CurrentValue = SHIM_MCCOMPAT_INTEGRATED) then
	Result := SGNVidiaIntegrated
else
	Result := SGNVidiaAutoSelect;

status := NvAPI_DRS_DestroySession(hSession);
if (status <> NVAPI_OK) then
	SGHint(['NvAPI_DRS_DestroySession error : ', SGNvApiStrStatus(status), '!'], [SGCaseLog{$IFDEF NVDRS_DEBUG}, SGCasePrint{$ENDIF}], True);
end;

function SGNVidiaStrDriverOptimusMode(const Mode : TSGNVidiaDriverOptimusMode) : TSGString;
begin
case Mode of
SGNVidiaUnknown : Result := 'SGNVidiaUnknown';
SGNVidiaHighPerfomance : Result := 'SGNVidiaHighPerfomance';
SGNVidiaIntegrated : Result := 'SGNVidiaIntegrated';
SGNVidiaAutoSelect : Result := 'SGNVidiaAutoSelect';
end;
end;

function SGNVidiaSetDriverOptimusMode(const Mode : TSGNVidiaDriverOptimusMode = SGNVidiaHighPerfomance) : TSGBoolean;

procedure SetDriverOptimusMode();
var
	hSession : NvDRSSessionHandle;
	hProfile : NvDRSProfileHandle;
	status : NvAPI_Status;
	drsSetting1, drsSetting2, drsSetting3 : NVDRS_SETTING;
begin
hSession := 0;
status := NvAPI_DRS_CreateSession(@hSession);
if (status <> NVAPI_OK) then
	begin
	SGHint(['NVidia : Set driver optimus mode : CreateSession error : ', SGNvApiStrStatus(status), '!'], [SGCaseLog{$IFDEF NVDRS_DEBUG}, SGCasePrint{$ENDIF}], True);
	exit;
	end;

status := NvAPI_DRS_LoadSettings(hSession);
if (status <> NVAPI_OK) then 
	begin
	SGHint(['NVidia : Set driver optimus mode : LoadSettings error : ', SGNvApiStrStatus(status), '!'], [SGCaseLog{$IFDEF NVDRS_DEBUG}, SGCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

hProfile := 0;
status := NvAPI_DRS_GetBaseProfile(hSession, @hProfile);
if (status <> NVAPI_OK) then 
	begin
	SGHint(['NVidia : Set driver optimus mode : GetBaseProfile error : ', SGNvApiStrStatus(status), '!'], [SGCaseLog{$IFDEF NVDRS_DEBUG}, SGCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

fillchar(drsSetting1, SizeOf(drsSetting1), 0);
drsSetting1.version := NVDRS_SETTING_VER;
drsSetting1.settingId := SHIM_MCCOMPAT_ID;
drsSetting1.settingType := NVDRS_DWORD_TYPE;

fillchar(drsSetting2, SizeOf(drsSetting1), 0);
drsSetting2.version := NVDRS_SETTING_VER;
drsSetting2.settingId := SHIM_RENDERING_MODE_ID;
drsSetting2.settingType := NVDRS_DWORD_TYPE;

fillchar(drsSetting3, SizeOf(drsSetting1), 0);
drsSetting3.version := NVDRS_SETTING_VER;
drsSetting3.settingId := SHIM_RENDERING_OPTIONS_ID;
drsSetting3.settingType := NVDRS_DWORD_TYPE;

if(Mode = SGNVidiaHighPerfomance) then
	drsSetting1.u32CurrentValue := SHIM_MCCOMPAT_ENABLE
else if(Mode = SGNVidiaIntegrated) then
	drsSetting1.u32CurrentValue := SHIM_MCCOMPAT_INTEGRATED
else
	drsSetting1.u32CurrentValue := SHIM_MCCOMPAT_AUTO_SELECT;

if(Mode = SGNVidiaHighPerfomance)then
	drsSetting2.u32CurrentValue := SHIM_RENDERING_MODE_ENABLE
else if(Mode = SGNVidiaIntegrated)then
	drsSetting2.u32CurrentValue := SHIM_RENDERING_MODE_INTEGRATED
else
	drsSetting2.u32CurrentValue := SHIM_RENDERING_MODE_ENABLE;

if(Mode = SGNVidiaHighPerfomance)then
	drsSetting3.u32CurrentValue := SHIM_RENDERING_OPTIONS_DEFAULT_RENDERING_MODE
else if(Mode = SGNVidiaIntegrated)then
	drsSetting3.u32CurrentValue := SHIM_RENDERING_OPTIONS_DEFAULT_RENDERING_MODE or SHIM_RENDERING_OPTIONS_IGPU_TRANSCODING
else
	drsSetting3.u32CurrentValue := SHIM_RENDERING_OPTIONS_DEFAULT_RENDERING_MODE;

status := NvAPI_DRS_SetSetting(hSession, hProfile, @drsSetting1);
if (status <> NVAPI_OK) then
	begin
	SGHint(['NVidia : Set driver optimus mode : SetSetting(1) error : ', SGNvApiStrStatus(status), '!'], [SGCaseLog{$IFDEF NVDRS_DEBUG}, SGCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

status := NvAPI_DRS_SetSetting(hSession, hProfile, @drsSetting2);
if (status <> NVAPI_OK) then
	begin
	SGHint(['NVidia : Set driver optimus mode : SetSetting(2) error : ', SGNvApiStrStatus(status), '!'], [SGCaseLog{$IFDEF NVDRS_DEBUG}, SGCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

status := NvAPI_DRS_SetSetting(hSession, hProfile, @drsSetting3);
if (status <> NVAPI_OK) then
	begin
	SGHint(['NVidia : Set driver optimus mode : SetSetting(3) error : ', SGNvApiStrStatus(status), '!'], [SGCaseLog{$IFDEF NVDRS_DEBUG}, SGCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

status := NvAPI_DRS_SaveSettings(hSession);
if (status <> NVAPI_OK) then
	begin
	SGHint(['NVidia : Set driver optimus mode : SaveSettings error : ', SGNvApiStrStatus(status), '!'], [SGCaseLog{$IFDEF NVDRS_DEBUG}, SGCasePrint{$ENDIF}], True);
	end;

status := NvAPI_DRS_DestroySession(hSession);
if (status <> NVAPI_OK) then
	SGHint(['NVidia : Set driver optimus mode : DestroySession error : ', SGNvApiStrStatus(status), '!'], [SGCaseLog{$IFDEF NVDRS_DEBUG}, SGCasePrint{$ENDIF}], True);
end;

var
	d1, d2 : TSGDateTime;
begin
{SGHint(SGNVidiaStrDriverOptimusMode(SGNVidiaGetDriverOptimusMode(SGNVidiaBase)));
SGHint(SGNVidiaStrDriverOptimusMode(SGNVidiaGetDriverOptimusMode(SGNVidiaCurrentGlobal)));
SGNVidiaViewDriverSetting(SHIM_MCCOMPAT_ID, SGNVidiaBase);
SGNVidiaViewDriverSetting(SHIM_MCCOMPAT_ID, SGNVidiaCurrentGlobal);}
Result := False;
if not DllManager.Supported('nvapi') then
	exit;
d1.Get();
SetDriverOptimusMode();
d2.Get();
SGHint(['NVidia : Driver optimus sets at ', SGTextTimeBetweenDates(d1, d2, 'ENG'), ' seconds!'], [SGCaseLog{$IFDEF NVDRS_DEBUG}, SGCasePrint{$ENDIF}], True);
end;

function SGNVidiaGetNumProfilies(const hSession : NvDRSSessionHandle) : NvU32;
begin
Result := 0;
if not DllManager.Supported('nvapi') then
	exit;
NvAPI_DRS_GetNumProfiles(hSession, Result);
end;

function SGNvApiStrBinarySetting(const BinarySetting : NVDRS_BINARY_SETTING) : TSGString;
var
	Index : TSGMaxEnum;
begin
Result := '(size = ' + SGGetSizeString(BinarySetting.valueLength, 'EN') + ')';
if BinarySetting.valueLength > 0 then
	begin
	Result += ' 0x';
	for Index := 0 to BinarySetting.valueLength - 1 do
		Result += SGStrByteHex(BinarySetting.valueData[Index], False);
	end;
end;

end.
