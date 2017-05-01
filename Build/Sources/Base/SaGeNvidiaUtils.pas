{$INCLUDE SaGe.inc}

unit SaGeNvidiaUtils;

interface

uses
	 SaGeBase
	,SaGeLog
	;

const
	SGNVidiaViewingShift = '	';

procedure SGNVidiaViewInfo(const ViewType : TSGViewErrorType = [SGLogType, SGPrintType]);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SGNVidiaViewGraphicInfo(const ViewType : TSGViewErrorType = [SGLogType, SGPrintType]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGNVidiaViewSystemInfo(const ViewType : TSGViewErrorType = [SGLogType, SGPrintType]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGNVidiaViewStereoscopicInfo(const ViewType : TSGViewErrorType = [SGLogType, SGPrintType]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGNVidiaViewDisplayInfo(const ViewType : TSGViewErrorType = [SGLogType, SGPrintType]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGNVidiaViewGPUInfo(const ViewType : TSGViewErrorType = [SGLogType, SGPrintType]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeDllManager
	,SaGeBaseUtils
	,SaGeStringUtils
	
	,SysUtils
	
	,StrMan
	,nvapi
	;

procedure SGNVidiaViewGraphicInfo(const ViewType : TSGViewErrorType = [SGLogType, SGPrintType]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
  info  : NV_DISPLAY_DRIVER_VERSION;
  res   : NvAPI_Status;
begin
SGHint('Graphic driver: ', ViewType, WithTime);
FillChar(info, sizeof(info), 0);
info.version := NV_DISPLAY_DRIVER_VERSION_VER;
res := NvAPI_GetDisplayDriverVersion(0, @info);
if res = NVAPI_OK then
	begin
	SGHint([Shift, 'Driver version: ', info.drvVersion div 100, '.', info.drvVersion mod 100], ViewType, WithTime);
	SGHint([Shift, 'Branch:         ', info.szBuildBranchString], ViewType, WithTime);
	SGHint([Shift, 'Adpater:        ', info.szAdapterString], ViewType, WithTime);
	end
else
	SGHint([Shift, 'Not available or Failed (err ', Integer(res),')'], ViewType, WithTime);
end;

procedure SGNVidiaViewGPUInfo(const ViewType : TSGViewErrorType = [SGLogType, SGPrintType]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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
	SGHint('GPU:', ViewType, WithTime);
	inited := True;
	SGHint([Shift, 'Physical GPUs ', cnt], ViewType, WithTime);
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
		SGHint(S, ViewType, WithTime);
		end;
	end;
if NvAPI_EnumLogicalGPUs(log, cnt) = NVAPI_OK then
	begin
	if not inited then
		SGHint('GPU:', ViewType, WithTime);
	SGHint([Shift, 'Logical GPUs ', cnt], ViewType, WithTime);
	end;
end;

procedure SGNVidiaViewDisplayInfo(const ViewType : TSGViewErrorType = [SGLogType, SGPrintType]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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
			SGHint('Display:', ViewType, WithTime);
			inited := True;
			end;
		SGHint(Shift + 'Display: ' + name, ViewType, WithTime);
		end;
	inc(i);
	end;
end;

procedure SGNVidiaViewStereoscopicInfo(const ViewType : TSGViewErrorType = [SGLogType, SGPrintType]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	res : NvAPI_Status;
	b   : NvU8;
begin
res := NvAPI_Stereo_IsEnabled(b);
if res = NVAPI_OK then
	begin
	SGHint('Stereoscopic:', ViewType, WithTime);
	SGHint(Shift + 'Stereo is available and now ' + Iff(b = 0, 'disabled', 'enabled') + '.');
	end;
end;

procedure SGNVidiaViewSystemInfo(const ViewType : TSGViewErrorType = [SGLogType, SGPrintType]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	info  : NV_CHIPSET_INFO_v1;
	res   : NvAPI_Status;
begin
SGHint('System: ', ViewType, WithTime);
FillChar(info, sizeof(info), 0);
info.version := NV_CHIPSET_INFO_VER_1;
res := NvAPI_SYS_GetChipSetInfo (info);
if res = NVAPI_OK then
	begin
	SGHint([Shift, 'Vendor:    ', info.szVendorName], ViewType, WithTime);
	if 'Unknown' <> info.szChipsetName then
		SGHint([Shift, 'Chipset:   ', info.szChipsetName], ViewType, WithTime);
	SGHint([Shift, 'Vendor ID: ', IntToHex(info.vendorId, 4)], ViewType, WithTime);
	SGHint([Shift, 'Device ID: ', IntToHex(info.deviceId, 4)], ViewType, WithTime);
	end;
end;

procedure SGNVidiaViewInfo(const ViewType : TSGViewErrorType = [SGLogType, SGPrintType]);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure ViewNVidiaVersion();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	ver  : NvAPI_ShortString;
begin
NvAPI_GetInterfaceVersionString(ver);
SGHint([SGNVidiaViewingShift, 'Version: ', ver], ViewType);
end;

begin
if DllManager.Suppored('nvapi') then
	begin
	SGHint('NVidia information:', ViewType, True);
	ViewNVidiaVersion();
	SGNVidiaViewSystemInfo      (ViewType, False);
	SGNVidiaViewGraphicInfo     (ViewType, False);
	SGNVidiaViewDisplayInfo     (ViewType, False);
	SGNVidiaViewGPUInfo         (ViewType, False);
	SGNVidiaViewStereoscopicInfo(ViewType, False);
	end;
end;

// For set to High Performance Graphics
var
	NvOptimusEnablement : TSGUInt32 = 1; export;

initialization
begin
NvOptimusEnablement := 1;
end;

end.
