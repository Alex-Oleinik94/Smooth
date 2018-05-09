{$INCLUDE SaGe.inc}

unit SaGeNvidiaUtils;

interface

uses
	 SaGeBase
	,SaGeCasesOfPrint
	;

const
	SGNVidiaViewingShift = '	';

procedure SGNVidiaViewInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SGNVidiaViewGraphicInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGNVidiaViewSystemInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGNVidiaViewStereoscopicInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGNVidiaViewDisplayInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGNVidiaViewGPUInfo(const CasesOfPrint : TSGCasesOfPrint = [SGCaseLog, SGCasePrint]; const WithTime : TSGBoolean = True; const Shift : TSGString = SGNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeLog
	,SaGeDllManager
	,SaGeBaseUtils
	,SaGeStringUtils
	
	,SysUtils
	
	,StrMan
	,nvapi
	;

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

// For set to High Performance Graphics
var
	NvOptimusEnablement : TSGUInt32 = 1; export;

initialization
begin
NvOptimusEnablement := 1;
end;

end.
