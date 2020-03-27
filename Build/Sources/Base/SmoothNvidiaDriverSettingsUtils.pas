{$INCLUDE Smooth.inc}
//{$DEFINE NVDRS_DEBUG}

unit SmoothNvidiaDriverSettingsUtils;

interface

uses
	 SmoothBase
	,SmoothCasesOfPrint
	
	// NVidia
	,NvApiDriverSettings
	,nvapi_lite_common
	;

function SNVidiaGetNumProfilies(const hSession : NvDRSSessionHandle) : NvU32;

type
	TSNVidiaDriverModeOptimus = (
		SNVidiaBase,
		SNVidiaCurrentGlobal);
	TSNVidiaDriverOptimusMode = (
		SNVidiaUnknown,
		SNVidiaHighPerfomance,
		SNVidiaIntegrated,
		SNVidiaAutoSelect);

function SNVidiaStrDriverOptimusMode(const Mode : TSNVidiaDriverOptimusMode) : TSString;
function SNVidiaSetDriverOptimusMode(const Mode : TSNVidiaDriverOptimusMode = SNVidiaHighPerfomance) : TSBoolean;
function SNVidiaGetDriverOptimusMode(const Mode : TSNVidiaDriverModeOptimus = SNVidiaBase) : TSNVidiaDriverOptimusMode;
procedure SNVidiaViewDriverSetting(const Setting : NvU32; const Mode : TSNVidiaDriverModeOptimus = SNVidiaBase; const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]); overload;
procedure SNVidiaViewDriverSetting(const Setting : NVDRS_SETTING; const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]); overload;

function SNvApiStrBinarySetting(const BinarySetting : NVDRS_BINARY_SETTING) : TSString;

implementation

uses
	 SmoothLog
	,SmoothDllManager
	,SmoothDateTime
	,SmoothStringUtils
	;

procedure SNVidiaViewDriverSetting(const Setting : NVDRS_SETTING; const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]); overload;
begin
SHint('Driver setting: ', CasesOfPrint);
SHint(['    Version = ', Setting.version], CasesOfPrint);
SHint(['    Setting name = ', Setting.settingName], CasesOfPrint);
SHint(['    Setting ID = ', Setting.settingId], CasesOfPrint);
SHint(['    Setting type = ', Setting.settingType], CasesOfPrint);
SHint(['    Setting location = ', Setting.settingLocation], CasesOfPrint);
SHint(['    Is current predefined = ', Setting.isCurrentPredefined], CasesOfPrint);
SHint(['    Is predefined valid = ', Setting.isPredefinedValid], CasesOfPrint);
SHint(['    Predefined : Value (uint32) = ', Setting.u32PredefinedValue], CasesOfPrint);
SHint(['    Predefined : Binary value = ', SNvApiStrBinarySetting(Setting.binaryPredefinedValue)], CasesOfPrint);
SHint(['    Predefined : Value (wide string) = ', Setting.wszPredefinedValue], CasesOfPrint);
SHint(['    Current : Value (uint32) = ', Setting.u32CurrentValue], CasesOfPrint);
SHint(['    Current : Binary value = ', SNvApiStrBinarySetting(Setting.binaryCurrentValue)], CasesOfPrint);
SHint(['    Current : Value (wide string) = ', Setting.wszCurrentValue], CasesOfPrint);
end;

procedure SNVidiaViewDriverSetting(const Setting : NvU32; const Mode : TSNVidiaDriverModeOptimus = SNVidiaBase; const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]);
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
if Mode = SNVidiaBase then
	status := NvAPI_DRS_GetBaseProfile(hSession, @hProfile)
else
	status := NvAPI_DRS_GetCurrentGlobalProfile(hSession, @hProfile);
if (status <> NVAPI_OK) then 
	begin
	SHint(['NVidia : View driver setting : Get*?Profile error : ', SNvApiStrStatus(status), '!'], [SCaseLog{$IFDEF NVDRS_DEBUG}, SCasePrint{$ENDIF}], True);
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
	SHint(['NVidia : View driver setting : GetSetting error : ', SNvApiStrStatus(status), '!'], [SCaseLog{$IFDEF NVDRS_DEBUG}, SCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

SNVidiaViewDriverSetting(drsSetting, CasesOfPrint);

NvAPI_DRS_DestroySession(hSession);
end;

function SNVidiaGetDriverOptimusMode(const Mode : TSNVidiaDriverModeOptimus = SNVidiaBase) : TSNVidiaDriverOptimusMode;
var
	hSession : NvDRSSessionHandle;
	status : NvAPI_Status;
	hProfile : NvDRSProfileHandle;
	drsSetting : NVDRS_SETTING;
begin
Result := SNVidiaUnknown;
if not DllManager.Supported('nvapi') then
	exit;

hSession := 0;
status := NvAPI_DRS_CreateSession(@hSession);
if (status <> NVAPI_OK) then
	begin
	SHint(['NvAPI_DRS_CreateSession error : ', SNvApiStrStatus(status), '!'], [SCaseLog{$IFDEF NVDRS_DEBUG}, SCasePrint{$ENDIF}], True);
	exit;
	end;

status := NvAPI_DRS_LoadSettings(hSession);
if (status <> NVAPI_OK) then 
	begin
	SHint(['NvAPI_DRS_LoadSettings error : ', SNvApiStrStatus(status), '!'], [SCaseLog{$IFDEF NVDRS_DEBUG}, SCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

//WriteLn('SNVidiaGetNumProfilies=',SNVidiaGetNumProfilies(hSession));

hProfile := 0;
if Mode = SNVidiaBase then
	status := NvAPI_DRS_GetBaseProfile(hSession, @hProfile)
else
	status := NvAPI_DRS_GetCurrentGlobalProfile(hSession, @hProfile);
if (status <> NVAPI_OK) then 
	begin
	SHint(['NvAPI_DRS_GetBaseProfile error : ', SNvApiStrStatus(status), '!'], [SCaseLog{$IFDEF NVDRS_DEBUG}, SCasePrint{$ENDIF}], True);
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
	SHint(['NVidia : Get driver optimus mode : GetSetting error : ', SNvApiStrStatus(status), '!'], [SCaseLog{$IFDEF NVDRS_DEBUG}, SCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;
if(drsSetting.u32CurrentValue = SHIM_MCCOMPAT_ENABLE) then
	Result := SNVidiaHighPerfomance
else if(drsSetting.u32CurrentValue = SHIM_MCCOMPAT_INTEGRATED) then
	Result := SNVidiaIntegrated
else
	Result := SNVidiaAutoSelect;

status := NvAPI_DRS_DestroySession(hSession);
if (status <> NVAPI_OK) then
	SHint(['NvAPI_DRS_DestroySession error : ', SNvApiStrStatus(status), '!'], [SCaseLog{$IFDEF NVDRS_DEBUG}, SCasePrint{$ENDIF}], True);
end;

function SNVidiaStrDriverOptimusMode(const Mode : TSNVidiaDriverOptimusMode) : TSString;
begin
case Mode of
SNVidiaUnknown : Result := 'SNVidiaUnknown';
SNVidiaHighPerfomance : Result := 'SNVidiaHighPerfomance';
SNVidiaIntegrated : Result := 'SNVidiaIntegrated';
SNVidiaAutoSelect : Result := 'SNVidiaAutoSelect';
end;
end;

function SNVidiaSetDriverOptimusMode(const Mode : TSNVidiaDriverOptimusMode = SNVidiaHighPerfomance) : TSBoolean;

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
	SHint(['NVidia : Set driver optimus mode : CreateSession error : ', SNvApiStrStatus(status), '!'], [SCaseLog{$IFDEF NVDRS_DEBUG}, SCasePrint{$ENDIF}], True);
	exit;
	end;

status := NvAPI_DRS_LoadSettings(hSession);
if (status <> NVAPI_OK) then 
	begin
	SHint(['NVidia : Set driver optimus mode : LoadSettings error : ', SNvApiStrStatus(status), '!'], [SCaseLog{$IFDEF NVDRS_DEBUG}, SCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

hProfile := 0;
status := NvAPI_DRS_GetBaseProfile(hSession, @hProfile);
if (status <> NVAPI_OK) then 
	begin
	SHint(['NVidia : Set driver optimus mode : GetBaseProfile error : ', SNvApiStrStatus(status), '!'], [SCaseLog{$IFDEF NVDRS_DEBUG}, SCasePrint{$ENDIF}], True);
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

if(Mode = SNVidiaHighPerfomance) then
	drsSetting1.u32CurrentValue := SHIM_MCCOMPAT_ENABLE
else if(Mode = SNVidiaIntegrated) then
	drsSetting1.u32CurrentValue := SHIM_MCCOMPAT_INTEGRATED
else
	drsSetting1.u32CurrentValue := SHIM_MCCOMPAT_AUTO_SELECT;

if(Mode = SNVidiaHighPerfomance)then
	drsSetting2.u32CurrentValue := SHIM_RENDERING_MODE_ENABLE
else if(Mode = SNVidiaIntegrated)then
	drsSetting2.u32CurrentValue := SHIM_RENDERING_MODE_INTEGRATED
else
	drsSetting2.u32CurrentValue := SHIM_RENDERING_MODE_ENABLE;

if(Mode = SNVidiaHighPerfomance)then
	drsSetting3.u32CurrentValue := SHIM_RENDERING_OPTIONS_DEFAULT_RENDERING_MODE
else if(Mode = SNVidiaIntegrated)then
	drsSetting3.u32CurrentValue := SHIM_RENDERING_OPTIONS_DEFAULT_RENDERING_MODE or SHIM_RENDERING_OPTIONS_IGPU_TRANSCODING
else
	drsSetting3.u32CurrentValue := SHIM_RENDERING_OPTIONS_DEFAULT_RENDERING_MODE;

status := NvAPI_DRS_SetSetting(hSession, hProfile, @drsSetting1);
if (status <> NVAPI_OK) then
	begin
	SHint(['NVidia : Set driver optimus mode : SetSetting(1) error : ', SNvApiStrStatus(status), '!'], [SCaseLog{$IFDEF NVDRS_DEBUG}, SCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

status := NvAPI_DRS_SetSetting(hSession, hProfile, @drsSetting2);
if (status <> NVAPI_OK) then
	begin
	SHint(['NVidia : Set driver optimus mode : SetSetting(2) error : ', SNvApiStrStatus(status), '!'], [SCaseLog{$IFDEF NVDRS_DEBUG}, SCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

status := NvAPI_DRS_SetSetting(hSession, hProfile, @drsSetting3);
if (status <> NVAPI_OK) then
	begin
	SHint(['NVidia : Set driver optimus mode : SetSetting(3) error : ', SNvApiStrStatus(status), '!'], [SCaseLog{$IFDEF NVDRS_DEBUG}, SCasePrint{$ENDIF}], True);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

status := NvAPI_DRS_SaveSettings(hSession);
if (status <> NVAPI_OK) then
	begin
	SHint(['NVidia : Set driver optimus mode : SaveSettings error : ', SNvApiStrStatus(status), '!'], [SCaseLog{$IFDEF NVDRS_DEBUG}, SCasePrint{$ENDIF}], True);
	end;

status := NvAPI_DRS_DestroySession(hSession);
if (status <> NVAPI_OK) then
	SHint(['NVidia : Set driver optimus mode : DestroySession error : ', SNvApiStrStatus(status), '!'], [SCaseLog{$IFDEF NVDRS_DEBUG}, SCasePrint{$ENDIF}], True);
end;

var
	d1, d2 : TSDateTime;
begin
{SHint(SNVidiaStrDriverOptimusMode(SNVidiaGetDriverOptimusMode(SNVidiaBase)));
SHint(SNVidiaStrDriverOptimusMode(SNVidiaGetDriverOptimusMode(SNVidiaCurrentGlobal)));
SNVidiaViewDriverSetting(SHIM_MCCOMPAT_ID, SNVidiaBase);
SNVidiaViewDriverSetting(SHIM_MCCOMPAT_ID, SNVidiaCurrentGlobal);}
Result := False;
if not DllManager.Supported('nvapi') then
	exit;
d1.Get();
SetDriverOptimusMode();
d2.Get();
SHint(['NVidia : Driver optimus sets at ', STextTimeBetweenDates(d1, d2, 'ENG'), ' seconds!'], [SCaseLog{$IFDEF NVDRS_DEBUG}, SCasePrint{$ENDIF}], True);
end;

function SNVidiaGetNumProfilies(const hSession : NvDRSSessionHandle) : NvU32;
begin
Result := 0;
if not DllManager.Supported('nvapi') then
	exit;
NvAPI_DRS_GetNumProfiles(hSession, Result);
end;

function SNvApiStrBinarySetting(const BinarySetting : NVDRS_BINARY_SETTING) : TSString;
var
	Index : TSMaxEnum;
begin
Result := '(size = ' + SGetSizeString(BinarySetting.valueLength, 'EN') + ')';
if BinarySetting.valueLength > 0 then
	begin
	Result += ' 0x';
	for Index := 0 to BinarySetting.valueLength - 1 do
		Result += SStrByteHex(BinarySetting.valueData[Index], False);
	end;
end;

end.
