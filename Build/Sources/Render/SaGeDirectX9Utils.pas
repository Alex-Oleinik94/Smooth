{$INCLUDE SaGe.inc}

unit SaGeDirectX9Utils;

interface

uses
	 SaGeBase
	
	// Direct X 9
	,DXTypes
	,DXErr9
	,D3DX9
	,Direct3D9
	;

function SGD3D9StrDepthFormat(const DepthFormat : TSGMaxEnum) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SGD3D9StrSDKVersion(const Version : TSGMaxEnum) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SGD3D9StrMULTISAMPLE(const MS : D3DMULTISAMPLE_TYPE) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
procedure SGD3D9LogError(const Error : HRESULT); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SGD3D9StrErrorCodeHex(const ErrorCode : HRESULT) : TSGString;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	SGD3D9AdaptersLoged : TSGBool = False;
procedure SGD3D9LogAdapters(const pD3D : IDirect3D9);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

	
implementation

uses
	 SaGeLog
	,SaGeStringUtils
	,SaGeBaseUtils
	
	,SysUtils
	;


procedure SGD3D9LogAdapters(const pD3D : IDirect3D9);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	AdapterCount : TSGMaxEnum;
	i : TSGMaxEnum;
	Adapter : TD3DAdapterIdentifier9;
begin
AdapterCount := pD3D.GetAdapterCount();
SGLog.Source(['Direct3D9: Finded ', AdapterCount, ' adapter(-s)', Iff(AdapterCount = 0, '.', ':')]);
if AdapterCount > 0 then
	for i := 0 to AdapterCount - 1 do
		if pD3D.GetAdapterIdentifier(i, 0, Adapter) = D3D_OK then
			begin
			SGLog.Source('Adapter #' + SGStr(i) + ':', False);
			SGLog.Source('	Driver:           ' + Adapter.Driver, False);
			SGLog.Source('	Description:      ' + Adapter.Description, False);
			SGLog.Source('	DeviceName:       ' + Adapter.DeviceName, False);
{$IFDEF WIN32}
			SGLog.Source(['	DriverVersion:    ', Adapter.DriverVersion], False);
{$ELSE}
			SGLog.Source(['	DriverVersionLowPart:   ', Adapter.DriverVersionLowPart], False);
			SGLog.Source(['	DriverVersionHighPart:  ', Adapter.DriverVersionHighPart], False);
{$ENDIF}
			SGLog.Source(['	VendorIdentifier: ', Adapter.VendorId], False);
			SGLog.Source(['	DeviceIdentifier: ', Adapter.DeviceId], False);
			SGLog.Source(['	SubSysIdentifier: ', Adapter.SubSysId], False);
			SGLog.Source(['	Revision:         ', Adapter.Revision], False);
			SGLog.Source(['	DeviceIdentifier: ', GUIDToString(Adapter.DeviceIdentifier)], False);
			SGLog.Source(['	WHQLLevel:        ', Adapter.WHQLLevel], False);
			end;
end;

function SGD3D9StrErrorCodeHex(const ErrorCode : HRESULT) : TSGString;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	Index : TSGByte;
begin
Result := '0x';
for Index := SizeOf(HRESULT) - 1 downto 0 do
	Result += SGStrByteHex(PSGByte(@ErrorCode)[Index], True);
end;

procedure SGD3D9LogError(const Error : HRESULT); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
SGLogMakeSignificant();
SGLog.Source(['TSGRenderDirectX9: DirectX Error:']);
SGLog.Source(['    ID (dec): ',Error]);
SGLog.Source(['    ID (hex): ',SGD3D9StrErrorCodeHex(Error)]);
SGLog.Source(['    Discription: ',SGPCharToString(DXGetErrorString9(Error))]);
end;

function SGD3D9StrMULTISAMPLE(const MS : D3DMULTISAMPLE_TYPE) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
case MS of
D3DMULTISAMPLE_NONE       : Result := 'D3DMULTISAMPLE_NONE';
D3DMULTISAMPLE_NONMASKABLE: Result := 'D3DMULTISAMPLE_NONMASKABLE';
D3DMULTISAMPLE_2_SAMPLES  : Result := 'D3DMULTISAMPLE_2_SAMPLES';
D3DMULTISAMPLE_3_SAMPLES  : Result := 'D3DMULTISAMPLE_3_SAMPLES';
D3DMULTISAMPLE_4_SAMPLES  : Result := 'D3DMULTISAMPLE_4_SAMPLES';
D3DMULTISAMPLE_5_SAMPLES  : Result := 'D3DMULTISAMPLE_5_SAMPLES';
D3DMULTISAMPLE_6_SAMPLES  : Result := 'D3DMULTISAMPLE_6_SAMPLES';
D3DMULTISAMPLE_7_SAMPLES  : Result := 'D3DMULTISAMPLE_7_SAMPLES';
D3DMULTISAMPLE_8_SAMPLES  : Result := 'D3DMULTISAMPLE_8_SAMPLES';
D3DMULTISAMPLE_9_SAMPLES  : Result := 'D3DMULTISAMPLE_9_SAMPLES';
D3DMULTISAMPLE_10_SAMPLES : Result := 'D3DMULTISAMPLE_10_SAMPLES';
D3DMULTISAMPLE_11_SAMPLES : Result := 'D3DMULTISAMPLE_11_SAMPLES';
D3DMULTISAMPLE_12_SAMPLES : Result := 'D3DMULTISAMPLE_12_SAMPLES';
D3DMULTISAMPLE_13_SAMPLES : Result := 'D3DMULTISAMPLE_13_SAMPLES';
D3DMULTISAMPLE_14_SAMPLES : Result := 'D3DMULTISAMPLE_14_SAMPLES';
D3DMULTISAMPLE_15_SAMPLES : Result := 'D3DMULTISAMPLE_15_SAMPLES';
D3DMULTISAMPLE_16_SAMPLES : Result := 'D3DMULTISAMPLE_16_SAMPLES';
end;
end;

function SGD3D9StrSDKVersion(const Version : TSGMaxEnum) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
case Version of
D3D9b_SDK_VERSION : Result := 'D3D9b_SDK_VERSION';
D3D_SDK_VERSION   : Result := 'D3D_SDK_VERSION';
else Result := '';
end;
end;

function SGD3D9StrDepthFormat(const DepthFormat : TSGMaxEnum) : TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
case DepthFormat of
D3DFMT_UNKNOWN       : Result := 'D3DFMT_UNKNOWN';
D3DFMT_S8_LOCKABLE   : Result := 'D3DFMT_S8_LOCKABLE';
D3DFMT_D15S1         : Result := 'D3DFMT_D15S1';
D3DFMT_D16_LOCKABLE  : Result := 'D3DFMT_D16_LOCKABLE';
D3DFMT_D16           : Result := 'D3DFMT_D16';
D3DFMT_D24X8         : Result := 'D3DFMT_D24X8';
D3DFMT_D24S8         : Result := 'D3DFMT_D24S8';
D3DFMT_D24X4S4       : Result := 'D3DFMT_D24X4S4';
D3DFMT_D32           : Result := 'D3DFMT_D32';
D3DFMT_D32F_LOCKABLE : Result := 'D3DFMT_D32F_LOCKABLE';
D3DFMT_D24FS8        : Result := 'D3DFMT_D24FS8';
D3DFMT_D32_LOCKABLE  : Result := 'D3DFMT_D32_LOCKABLE';
else Result := '';
end;
end;

end.
