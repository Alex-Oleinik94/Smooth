{$INCLUDE Smooth.inc}

unit SmoothNvidiaInformationUtils;

interface

uses
	 SmoothBase
	,SmoothCasesOfPrint
	;

const
	SNVidiaViewingShift = '	';

procedure SNVidiaViewInfo(const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SNVidiaViewGraphicInfo(const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]; const WithTime : TSBoolean = True; const Shift : TSString = SNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SNVidiaViewSystemInfo(const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]; const WithTime : TSBoolean = True; const Shift : TSString = SNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SNVidiaViewStereoscopicInfo(const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]; const WithTime : TSBoolean = True; const Shift : TSString = SNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SNVidiaViewDisplayInfo(const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]; const WithTime : TSBoolean = True; const Shift : TSString = SNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SNVidiaViewGPUInfo(const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]; const WithTime : TSBoolean = True; const Shift : TSString = SNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothLog
	,SmoothDllManager
	,SmoothBaseUtils
	,SmoothStringUtils
	
	,SysUtils
	
	// NVidia
	,nvapi
	,nvapi_lite_common
	;

procedure SNVidiaViewGraphicInfo(const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]; const WithTime : TSBoolean = True; const Shift : TSString = SNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
  info  : NV_DISPLAY_DRIVER_VERSION;
  res   : NvAPI_Status;
begin
SHint('Graphic driver: ', CasesOfPrint, WithTime);
FillChar(info, sizeof(info), 0);
info.version := NV_DISPLAY_DRIVER_VERSION_VER;
res := NvAPI_GetDisplayDriverVersion(0, @info);
if res = NVAPI_OK then
	begin
	SHint([Shift, 'Driver version: ', info.drvVersion div 100, '.', info.drvVersion mod 100], CasesOfPrint, WithTime);
	SHint([Shift, 'Branch:         ', info.szBuildBranchString], CasesOfPrint, WithTime);
	SHint([Shift, 'Adpater:        ', info.szAdapterString], CasesOfPrint, WithTime);
	end
else
	SHint([Shift, 'Not available or Failed (err ', Integer(res),')'], CasesOfPrint, WithTime);
end;

procedure SNVidiaViewGPUInfo(const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]; const WithTime : TSBoolean = True; const Shift : TSString = SNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	phys  : TNvPhysicalGpuHandleArray;
	log   : TNvLogicalGpuHandleArray;
	cnt   : LongWord;
	i     : Integer;
	name  : NvAPI_ShortString;
	thermal : TNvGPUThermalSettings;
	res   : NvAPI_Status;
	s     : TSString;
	inited : TSBool = False;
begin
if NvAPI_EnumPhysicalGPUs(phys, cnt) = NVAPI_OK then
	begin
	SHint('GPU:', CasesOfPrint, WithTime);
	inited := True;
	SHint([Shift, 'Physical GPUs ', cnt], CasesOfPrint, WithTime);
	for i:=0 to cnt - 1 do
	if NvAPI_GPU_GetFullName(phys[i], name) = NVAPI_OK then
		begin
		s := Shift;
		S += '	Name: ' + Name;
		FillChar(thermal, sizeof(thermal), 0);
		thermal.version := NV_GPU_THERMAL_SETTINGS_VER;
		res := NvAPI_GPU_GetThermalSettings(phys[i], 0, @thermal);
		if res = NVAPI_OK then
			S += ', Temp: ' + SStr(thermal.sensor[0].currentTemp) + ' C';
		SHint(S, CasesOfPrint, WithTime);
		end;
	end;
if NvAPI_EnumLogicalGPUs(log, cnt) = NVAPI_OK then
	begin
	if not inited then
		SHint('GPU:', CasesOfPrint, WithTime);
	SHint([Shift, 'Logical GPUs ', cnt], CasesOfPrint, WithTime);
	end;
end;

procedure SNVidiaViewDisplayInfo(const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]; const WithTime : TSBoolean = True; const Shift : TSString = SNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i      : Integer;
	hnd    : NvDisplayHandle;
	name   : NvAPI_ShortString;
	inited : TSBool = False;
begin
i   := 0;
hnd := 0;
while NvAPI_EnumNVidiaDisplayHandle(i, hnd) = NVAPI_OK do
	begin
	if NvAPI_GetAssociatedNVidiaDisplayName(hnd, name) = NVAPI_OK then
		begin
		if not inited then
			begin
			SHint('Display:', CasesOfPrint, WithTime);
			inited := True;
			end;
		SHint(Shift + 'Display: ' + name, CasesOfPrint, WithTime);
		end;
	inc(i);
	end;
end;

procedure SNVidiaViewStereoscopicInfo(const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]; const WithTime : TSBoolean = True; const Shift : TSString = SNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	res : NvAPI_Status;
	b   : NvU8;
begin
res := NvAPI_Stereo_IsEnabled(b);
if res = NVAPI_OK then
	begin
	SHint('Stereoscopic:', CasesOfPrint, WithTime);
	SHint(Shift + 'Stereo is available and now ' + Iff(b = 0, 'disabled', 'enabled') + '.');
	end;
end;

procedure SNVidiaViewSystemInfo(const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]; const WithTime : TSBoolean = True; const Shift : TSString = SNVidiaViewingShift);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	info  : NV_CHIPSET_INFO_v1;
	res   : NvAPI_Status;
begin
SHint('System: ', CasesOfPrint, WithTime);
FillChar(info, sizeof(info), 0);
info.version := NV_CHIPSET_INFO_VER_1;
res := NvAPI_SYS_GetChipSetInfo (info);
if res = NVAPI_OK then
	begin
	SHint([Shift, 'Vendor:    ', info.szVendorName], CasesOfPrint, WithTime);
	if 'Unknown' <> info.szChipsetName then
		SHint([Shift, 'Chipset:   ', info.szChipsetName], CasesOfPrint, WithTime);
	SHint([Shift, 'Vendor ID: ', IntToHex(info.vendorId, 4)], CasesOfPrint, WithTime);
	SHint([Shift, 'Device ID: ', IntToHex(info.deviceId, 4)], CasesOfPrint, WithTime);
	end;
end;

procedure SNVidiaViewInfo(const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure ViewNVidiaVersion();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	ver  : NvAPI_ShortString;
begin
NvAPI_GetInterfaceVersionString(ver);
SHint([SNVidiaViewingShift, 'Version: ', ver], CasesOfPrint);
end;

begin
if DllManager.Supported('nvapi') then
	begin
	SHint('NVidia information:', CasesOfPrint, True);
	ViewNVidiaVersion();
	SNVidiaViewSystemInfo      (CasesOfPrint, False);
	SNVidiaViewGraphicInfo     (CasesOfPrint, False);
	SNVidiaViewDisplayInfo     (CasesOfPrint, False);
	SNVidiaViewGPUInfo         (CasesOfPrint, False);
	SNVidiaViewStereoscopicInfo(CasesOfPrint, False);
	end;
end;

end.
