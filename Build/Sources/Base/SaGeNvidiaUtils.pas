{$INCLUDE SaGe.inc}

unit SaGeNvidiaUtils;

interface

uses
	 SaGeBase
	,SaGeCasesOfPrint
	;

// Method That Enable NVIDIA High Performance Graphics Rendering on Optimus Systems
// Global Variable NvOptimusEnablement (new in Driver Release 302)
var
	NvOptimusEnablement : TSGUInt32 = $00000001; cvar;
	AmdPowerXpressRequestHighPerformance : TSGUInt32 = $00000001; cvar;

const
	SGNVidiaViewingShift = '	';

procedure SGNVidiaViewInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SGNVidiaViewGraphicInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGNVidiaViewSystemInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGNVidiaViewStereoscopicInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGNVidiaViewDisplayInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGNVidiaViewGPUInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

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
	,SaGeBaseUtils
	,SaGeStringUtils
	,SaGeDateTime
	
	,SysUtils
	,Crt
	
	,StrMan
	
	// NVidia
	,nvapi
	,NvApiDriverSettings
	,nvapi_lite_common
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
	SGHint(['NvAPI_DRS_CreateSession error!']);
	exit;
	end;

// (2) load all the system settings into the session
status := NvAPI_DRS_LoadSettings(hSession);
if (status <> NVAPI_OK) then 
	begin
	SGHint(['NvAPI_DRS_LoadSettings error!']);
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
	SGHint(['NvAPI_DRS_GetBaseProfile error!']);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

// Now get the settings
fillchar(drsSetting, SizeOf(drsSetting), 0);
drsSetting.version := NVDRS_SETTING_VER;
drsSetting.settingId := NvU32(SHIM_MCCOMPAT_ID);
drsSetting.settingType := NVDRS_DWORD_TYPE;

status := NvAPI_DRS_GetSetting(hSession, hProfile, NvU32(SHIM_MCCOMPAT_ID), @drsSetting);
if(drsSetting.u32CurrentValue = 1) then
	Result := SGNVidiaHighPerfomance
else if(drsSetting.u32CurrentValue = 0) then
	Result := SGNVidiaIntegrated
else
	Result := SGNVidiaAutoSelect;

status := NvAPI_DRS_DestroySession(hSession);
if (status <> NVAPI_OK) then
	SGHint(['NvAPI_DRS_DestroySession error!']);
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
	SGHint(['NvAPI_DRS_CreateSession error!']);
	exit;
	end;

// (2) load all the system settings into the session
status := NvAPI_DRS_LoadSettings(hSession);
if (status <> NVAPI_OK) then 
	begin
	SGHint(['NvAPI_DRS_LoadSettings error!']);
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
	SGHint(['NvAPI_DRS_GetBaseProfile error!']);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

// Now modify the settings to set NVIDIA global
fillchar(drsSetting1, SizeOf(drsSetting1), 0);
drsSetting1.version := NVDRS_SETTING_VER;
drsSetting1.settingId := NvU32(SHIM_MCCOMPAT_ID);
drsSetting1.settingType := NVDRS_DWORD_TYPE;

fillchar(drsSetting2, SizeOf(drsSetting1), 0);
drsSetting2.version := NVDRS_SETTING_VER;
drsSetting2.settingId := NvU32(SHIM_RENDERING_MODE_ID);
drsSetting2.settingType := NVDRS_DWORD_TYPE;

fillchar(drsSetting3, SizeOf(drsSetting1), 0);
drsSetting3.version := NVDRS_SETTING_VER;
drsSetting3.settingId := NvU32(SHIM_RENDERING_OPTIONS_ID);
drsSetting3.settingType := NVDRS_DWORD_TYPE;

// Optimus flags for enabled applications
if(Mode = SGNVidiaHighPerfomance) then
	drsSetting1.u32CurrentValue := NvU32(SHIM_MCCOMPAT_ENABLE)
else if(Mode = SGNVidiaIntegrated) then
	drsSetting1.u32CurrentValue := NvU32(SHIM_MCCOMPAT_INTEGRATED)
else
	drsSetting1.u32CurrentValue := NvU32(SHIM_MCCOMPAT_AUTO_SELECT);
// other options
//		SHIM_MCCOMPAT_INTEGRATED		// 1
//		SHIM_MCCOMPAT_USER_EDITABLE
//		SHIM_MCCOMPAT_VARYING_BIT
//		SHIM_MCCOMPAT_AUTO_SELECT		// 2

// Enable application for Optimus
// drsSetting2.u32CurrentValue = SHIM_RENDERING_MODE_ENABLE;
if(Mode = SGNVidiaHighPerfomance)then
	drsSetting2.u32CurrentValue := NvU32(SHIM_RENDERING_MODE_ENABLE)
else if(Mode = SGNVidiaIntegrated)then
	drsSetting2.u32CurrentValue := NvU32(SHIM_RENDERING_MODE_INTEGRATED)
else
	drsSetting2.u32CurrentValue := NvU32(SHIM_RENDERING_MODE_ENABLE);
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
	drsSetting3.u32CurrentValue := NvU32(SHIM_RENDERING_OPTIONS_DEFAULT_RENDERING_MODE)
else if(Mode = SGNVidiaIntegrated)then
	drsSetting3.u32CurrentValue := NvU32(SHIM_RENDERING_OPTIONS_DEFAULT_RENDERING_MODE) or NvU32(SHIM_RENDERING_OPTIONS_IGPU_TRANSCODING)
else
	drsSetting3.u32CurrentValue := NvU32(SHIM_RENDERING_OPTIONS_DEFAULT_RENDERING_MODE);
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
	SGHint(['NvAPI_DRS_SetSetting 1 error!']);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

status := NvAPI_DRS_SetSetting(hSession, hProfile, @drsSetting2);
if (status <> NVAPI_OK) then
	begin
	SGHint(['NvAPI_DRS_SetSetting 2 error!']);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

status := NvAPI_DRS_SetSetting(hSession, hProfile, @drsSetting3);
if (status <> NVAPI_OK) then
	begin
	SGHint(['NvAPI_DRS_SetSetting 3 error!']);
	NvAPI_DRS_DestroySession(hSession);
	exit;
	end;

status := NvAPI_DRS_SaveSettings(hSession);
if (status <> NVAPI_OK) then
	begin
	SGHint(['NvAPI_DRS_SaveSettings error!!!']);
	end;

status := NvAPI_DRS_DestroySession(hSession);
if (status <> NVAPI_OK) then
	SGHint(['NvAPI_DRS_DestroySession error!']);
end;

var
	d1, d2 : TSGDateTime;
begin
Result := False;
if not DllManager.Suppored('nvapi') then
	exit;
d1.Get();
SetDriverOptimusMode();
d2.Get();
SGHint(['NVidia : Driver optimus enabling at ', SGTextTimeBetweenDates(d1, d2, 'ENG'), ' seconds!']);
end;

procedure SGNVidiaViewGraphicInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
  info  : NV_DISPLAY_DRIVER_VERSION;
  res   : NvAPI_Status;
begin
SGHint('Graphic driver: ', CasesOfPrint, WithTime);
FillChar(info, sizeof(info), 0);
info.version := NV_DISPLAY_DRIVER_VERSION_VER;
res := NvAPI_GetDisplayDriverVersion(0, @info);
if res = NVAPI_OK then
	begin
	SGHint([Shift, 'Driver version: ', info.drvVersion div 100, '.', info.drvVersion mod 100], CasesOfPrint, WithTime);
	SGHint([Shift, 'Branch:         ', info.szBuildBranchString], CasesOfPrint, WithTime);
	SGHint([Shift, 'Adpater:        ', info.szAdapterString], CasesOfPrint, WithTime);
	end
else
	SGHint([Shift, 'Not available or Failed (err ', Integer(res),')'], CasesOfPrint, WithTime);
end;

procedure SGNVidiaViewGPUInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	phys  : TNvPhysicalGpuHandleArray;
	log   : TNvLogicalGpuHandleArray;
	cnt   : LongWord;
	i     : Integer;
	name  : NvAPI_ShortString;
	thermal : TNvGPUThermalSettings;
	res   : NvAPI_Status;
	s     : TSGString;
	inited : TSGBool = False;
begin
if NvAPI_EnumPhysicalGPUs(phys, cnt) = NVAPI_OK then
	begin
	SGHint('GPU:', CasesOfPrint, WithTime);
	inited := True;
	SGHint([Shift, 'Physical GPUs ', cnt], CasesOfPrint, WithTime);
	for i:=0 to cnt - 1 do
	if NvAPI_GPU_GetFullName(phys[i], name) = NVAPI_OK then
		begin
		s := Shift;
		S += '	Name: ' + Name;
		FillChar(thermal, sizeof(thermal), 0);
		thermal.version := NV_GPU_THERMAL_SETTINGS_VER;
		res := NvAPI_GPU_GetThermalSettings(phys[i], 0, @thermal);
		if res = NVAPI_OK then
			S += ', Temp: ' + SGStr(thermal.sensor[0].currentTemp) + ' C';
		SGHint(S, CasesOfPrint, WithTime);
		end;
	end;
if NvAPI_EnumLogicalGPUs(log, cnt) = NVAPI_OK then
	begin
	if not inited then
		SGHint('GPU:', CasesOfPrint, WithTime);
	SGHint([Shift, 'Logical GPUs ', cnt], CasesOfPrint, WithTime);
	end;
end;

procedure SGNVidiaViewDisplayInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i      : Integer;
	hnd    : NvDisplayHandle;
	name   : NvAPI_ShortString;
	inited : TSGBool = False;
begin
i   := 0;
hnd := 0;
while NvAPI_EnumNVidiaDisplayHandle(i, hnd) = NVAPI_OK do
	begin
	if NvAPI_GetAssociatedNVidiaDisplayName(hnd, name) = NVAPI_OK then
		begin
		if not inited then
			begin
			SGHint('Display:', CasesOfPrint, WithTime);
			inited := True;
			end;
		SGHint(Shift + 'Display: ' + name, CasesOfPrint, WithTime);
		end;
	inc(i);
	end;
end;

procedure SGNVidiaViewStereoscopicInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	res : NvAPI_Status;
	b   : NvU8;
begin
res := NvAPI_Stereo_IsEnabled(b);
if res = NVAPI_OK then
	begin
	SGHint('Stereoscopic:', CasesOfPrint, WithTime);
	SGHint(Shift + 'Stereo is available and now ' + Iff(b = 0, 'disabled', 'enabled') + '.');
	end;
end;

procedure SGNVidiaViewSystemInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	info  : NV_CHIPSET_INFO_v1;
	res   : NvAPI_Status;
begin
SGHint('System: ', CasesOfPrint, WithTime);
FillChar(info, sizeof(info), 0);
info.version := NV_CHIPSET_INFO_VER_1;
res := NvAPI_SYS_GetChipSetInfo (info);
if res = NVAPI_OK then
	begin
	SGHint([Shift, 'Vendor:    ', info.szVendorName], CasesOfPrint, WithTime);
	if 'Unknown' <> info.szChipsetName then
		SGHint([Shift, 'Chipset:   ', info.szChipsetName], CasesOfPrint, WithTime);
	SGHint([Shift, 'Vendor ID: ', IntToHex(info.vendorId, 4)], CasesOfPrint, WithTime);
	SGHint([Shift, 'Device ID: ', IntToHex(info.deviceId, 4)], CasesOfPrint, WithTime);
	end;
end;

procedure SGNVidiaViewInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure ViewNVidiaVersion();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	ver  : NvAPI_ShortString;
begin
NvAPI_GetInterfaceVersionString(ver);
SGHint([SGNVidiaViewingShift, 'Version: ', ver], CasesOfPrint);
end;

begin
if DllManager.Suppored('nvapi') then
	begin
	SGHint('NVidia information:', CasesOfPrint, True);
	ViewNVidiaVersion();
	SGNVidiaViewSystemInfo      (CasesOfPrint, False);
	SGNVidiaViewGraphicInfo     (CasesOfPrint, False);
	SGNVidiaViewDisplayInfo     (CasesOfPrint, False);
	SGNVidiaViewGPUInfo         (CasesOfPrint, False);
	SGNVidiaViewStereoscopicInfo(CasesOfPrint, False);
	end;
end;

exports NvOptimusEnablement, AmdPowerXpressRequestHighPerformance;

initialization
begin
NvOptimusEnablement :=  $00000001;
AmdPowerXpressRequestHighPerformance :=  $00000001;
end;

end.
