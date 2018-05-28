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
	TSGNVidiaDriverOptimusMode = (
		SGNVidiaUnknown,
		SGNVidiaHighPerfomance,
		SGNVidiaIntegrated,
		SGNVidiaAutoSelect);

function SGNVidiaStrDriverOptimusMode(const Mode : TSGNVidiaDriverOptimusMode) : TSGString;
function SGNVidiaSetDriverOptimusMode(const Mode : TSGNVidiaDriverOptimusMode = SGNVidiaHighPerfomance) : TSGBoolean;
function SGNVidiaGetDriverOptimusMode() : TSGNVidiaDriverOptimusMode;

implementation

uses
	 SaGeLog
	,SaGeDllManager
	,SaGeDateTime
	
	;

function SGNVidiaGetDriverOptimusMode() : TSGNVidiaDriverOptimusMode;
var
	hSession : NvDRSSessionHandle;
	status : NvAPI_Status;
	hProfile : NvDRSProfileHandle;
	drsSetting : NVDRS_SETTING;
begin
Result := SGNVidiaUnknown;
if not DllManager.Suppored('nvapi') then
	exit;

hSession := 0;
status := NvAPI_DRS_CreateSession(@hSession);
if (status <> NVAPI_OK) then
	begin
	{$IFDEF NVDRS_DEBUG}
	SGHint(['NvAPI_DRS_CreateSession error!']);
	{$ENDIF}
	exit;
	end;

// (2) load all the system settings into the session
status := NvAPI_DRS_LoadSettings(hSession);
if (status <> NVAPI_OK) then 
	begin
	{$IFDEF NVDRS_DEBUG}
	SGHint(['NvAPI_DRS_LoadSettings error!']);
	{$ENDIF}
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

//WriteLn('SGNVidiaGetNumProfilies=',SGNVidiaGetNumProfilies(hSession));

// (3) Obtain the Base profile. Any setting needs to be inside
// a profile, putting a setting on the Base Profile enforces it
// for all the processes on the system
hProfile := 0;
status := NvAPI_DRS_GetBaseProfile(hSession, @hProfile);
if (status <> NVAPI_OK) then 
	begin
	{$IFDEF NVDRS_DEBUG}
	SGHint(['NvAPI_DRS_GetBaseProfile error!']);
	{$ENDIF}
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

// Now get the settings
fillchar(drsSetting, SizeOf(drsSetting), 0);
drsSetting.version := NVDRS_SETTING_VER;
drsSetting.settingId := SHIM_MCCOMPAT_ID;
drsSetting.settingType := NVDRS_DWORD_TYPE;

status := NvAPI_DRS_GetSetting(hSession, hProfile, SHIM_MCCOMPAT_ID, @drsSetting);
if(drsSetting.u32CurrentValue = SHIM_MCCOMPAT_ENABLE) then
	Result := SGNVidiaHighPerfomance
else if(drsSetting.u32CurrentValue = SHIM_MCCOMPAT_INTEGRATED) then
	Result := SGNVidiaIntegrated
else
	Result := SGNVidiaAutoSelect;

status := NvAPI_DRS_DestroySession(hSession);
{$IFDEF NVDRS_DEBUG}
if (status <> NVAPI_OK) then
	SGHint(['NvAPI_DRS_DestroySession error!']);
{$ENDIF}
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
// (1) Create the session handle to access driver settings
hSession := 0;
status := NvAPI_DRS_CreateSession(@hSession);
if (status <> NVAPI_OK) then
	begin
	{$IFDEF NVDRS_DEBUG}
	SGHint(['NvAPI_DRS_CreateSession error!']);
	{$ENDIF}
	exit;
	end;

// (2) load all the system settings into the session
status := NvAPI_DRS_LoadSettings(hSession);
if (status <> NVAPI_OK) then 
	begin
	{$IFDEF NVDRS_DEBUG}
	SGHint(['NvAPI_DRS_LoadSettings error!']);
	{$ENDIF}
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

// (3) Obtain the Base profile. Any setting needs to be inside
// a profile, putting a setting on the Base Profile enforces it
// for all the processes on the system
hProfile := 0;
status := NvAPI_DRS_GetBaseProfile(hSession, @hProfile);
if (status <> NVAPI_OK) then 
	begin
	{$IFDEF NVDRS_DEBUG}
	SGHint(['NvAPI_DRS_GetBaseProfile error!']);
	{$ENDIF}
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

// Now modify the settings to set NVIDIA global
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

// Optimus flags for enabled applications
if(Mode = SGNVidiaHighPerfomance) then
	drsSetting1.u32CurrentValue := SHIM_MCCOMPAT_ENABLE
else if(Mode = SGNVidiaIntegrated) then
	drsSetting1.u32CurrentValue := SHIM_MCCOMPAT_INTEGRATED
else
	drsSetting1.u32CurrentValue := SHIM_MCCOMPAT_AUTO_SELECT;
// other options
//		SHIM_MCCOMPAT_INTEGRATED		// 1
//		SHIM_MCCOMPAT_USER_EDITABLE
//		SHIM_MCCOMPAT_VARYING_BIT
//		SHIM_MCCOMPAT_AUTO_SELECT		// 2

// Enable application for Optimus
// drsSetting2.u32CurrentValue = SHIM_RENDERING_MODE_ENABLE;
if(Mode = SGNVidiaHighPerfomance)then
	drsSetting2.u32CurrentValue := SHIM_RENDERING_MODE_ENABLE
else if(Mode = SGNVidiaIntegrated)then
	drsSetting2.u32CurrentValue := SHIM_RENDERING_MODE_INTEGRATED
else
	drsSetting2.u32CurrentValue := SHIM_RENDERING_MODE_ENABLE;
// other options
//		SHIM_RENDERING_MODE_INTEGRATED		// 1
//		SHIM_RENDERING_MODE_USER_EDITABLE
//		SHIM_RENDERING_MODE_VARYING_BIT
//		SHIM_RENDERING_MODE_AUTO_SELECT		// 2
//		SHIM_RENDERING_MODE_OVERRIDE_BIT
//		SHIM_MCCOMPAT_OVERRIDE_BIT

// Shim rendering modes per application for Optimus
// drsSetting3.u32CurrentValue = SHIM_RENDERING_OPTIONS_DEFAULT_RENDERING_MODE;
if(Mode = SGNVidiaHighPerfomance)then
	drsSetting3.u32CurrentValue := SHIM_RENDERING_OPTIONS_DEFAULT_RENDERING_MODE
else if(Mode = SGNVidiaIntegrated)then
	drsSetting3.u32CurrentValue := SHIM_RENDERING_OPTIONS_DEFAULT_RENDERING_MODE or SHIM_RENDERING_OPTIONS_IGPU_TRANSCODING
else
	drsSetting3.u32CurrentValue := SHIM_RENDERING_OPTIONS_DEFAULT_RENDERING_MODE;
// other options
//		SHIM_RENDERING_OPTIONS_DISABLE_ASYNC_PRESENT,
//		SHIM_RENDERING_OPTIONS_EHSHELL_DETECT,
//		SHIM_RENDERING_OPTIONS_FLASHPLAYER_HOST_DETECT,
//		SHIM_RENDERING_OPTIONS_VIDEO_DRM_APP_DETECT,
//		SHIM_RENDERING_OPTIONS_IGNORE_OVERRIDES,
//		SHIM_RENDERING_OPTIONS_CHILDPROCESS_DETECT,
//		SHIM_RENDERING_OPTIONS_ENABLE_DWM_ASYNC_PRESENT,
//		SHIM_RENDERING_OPTIONS_PARENTPROCESS_DETECT,
//		SHIM_RENDERING_OPTIONS_ALLOW_INHERITANCE,
//		SHIM_RENDERING_OPTIONS_DISABLE_WRAPPERS,
//		SHIM_RENDERING_OPTIONS_DISABLE_DXGI_WRAPPERS,
//		SHIM_RENDERING_OPTIONS_PRUNE_UNSUPPORTED_FORMATS,
//		SHIM_RENDERING_OPTIONS_ENABLE_ALPHA_FORMAT,
//		SHIM_RENDERING_OPTIONS_IGPU_TRANSCODING,				// 1 ** include for force integrated
//		SHIM_RENDERING_OPTIONS_DISABLE_CUDA,
//		SHIM_RENDERING_OPTIONS_ALLOW_CP_CAPS_FOR_VIDEO,
//		SHIM_RENDERING_OPTIONS_ENABLE_NEW_HOOKING,
//		SHIM_RENDERING_OPTIONS_DISABLE_DURING_SECURE_BOOT,
//		SHIM_RENDERING_OPTIONS_INVERT_FOR_QUADRO,
//		SHIM_RENDERING_OPTIONS_INVERT_FOR_MSHYBRID,
//		SHIM_RENDERING_OPTIONS_REGISTER_PROCESS_ENABLE_GOLD,


// Code from "SOP" example
//	if( ForceIntegrated )then begin
//		drsSetting1.u32CurrentValue := SHIM_MCCOMPAT_INTEGRATED;
//		drsSetting2.u32CurrentValue := SHIM_RENDERING_MODE_INTEGRATED;
//		drsSetting3.u32CurrentValue := SHIM_RENDERING_OPTIONS_DEFAULT_RENDERING_MODE or SHIM_RENDERING_OPTIONS_IGPU_TRANSCODING;
//	end else begin
//		drsSetting1.u32CurrentValue := SHIM_MCCOMPAT_ENABLE;
//		drsSetting2.u32CurrentValue := SHIM_RENDERING_MODE_ENABLE;
//		drsSetting3.u32CurrentValue := SHIM_RENDERING_OPTIONS_DEFAULT_RENDERING_MODE;
//	end

status := NvAPI_DRS_SetSetting(hSession, hProfile, @drsSetting1);
if (status <> NVAPI_OK) then
	begin
	{$IFDEF NVDRS_DEBUG}
	SGHint(['NvAPI_DRS_SetSetting 1 error!']);
	{$ENDIF}
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

status := NvAPI_DRS_SetSetting(hSession, hProfile, @drsSetting2);
if (status <> NVAPI_OK) then
	begin
	{$IFDEF NVDRS_DEBUG}
	SGHint(['NvAPI_DRS_SetSetting 2 error!']);
	{$ENDIF}
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

status := NvAPI_DRS_SetSetting(hSession, hProfile, @drsSetting3);
if (status <> NVAPI_OK) then
	begin
	{$IFDEF NVDRS_DEBUG}
	SGHint(['NvAPI_DRS_SetSetting 3 error!']);
	{$ENDIF}
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

status := NvAPI_DRS_SaveSettings(hSession);
if (status <> NVAPI_OK) then
	begin
	{$IFDEF NVDRS_DEBUG}
	SGHint(['NvAPI_DRS_SaveSettings error!!!']);
	{$ENDIF}
	end;

status := NvAPI_DRS_DestroySession(hSession);
{$IFDEF NVDRS_DEBUG}
if (status <> NVAPI_OK) then
	SGHint(['NvAPI_DRS_DestroySession error!']);
{$ENDIF}
end;

{$IFDEF NVDRS_DEBUG}
var
	d1, d2 : TSGDateTime;
{$ENDIF}
begin
//SGNVidiaGetDriverOptimusMode();
Result := False;
if not DllManager.Suppored('nvapi') then
	exit;
{$IFDEF NVDRS_DEBUG}
d1.Get();
{$ENDIF}
SetDriverOptimusMode();
{$IFDEF NVDRS_DEBUG}
d2.Get();
SGHint(['NVidia : Driver optimus sets at ', SGTextTimeBetweenDates(d1, d2, 'ENG'), ' seconds!']);
{$ENDIF}
end;

function SGNVidiaGetNumProfilies(const hSession : NvDRSSessionHandle) : NvU32;
begin
Result := 0;
if not DllManager.Suppored('nvapi') then
	exit;
NvAPI_DRS_GetNumProfiles(hSession, Result);
end;

end.
