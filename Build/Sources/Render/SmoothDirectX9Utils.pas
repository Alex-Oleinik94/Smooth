{$INCLUDE Smooth.inc}

unit SmoothDirectX9Utils;

interface

uses
	 SmoothBase
	
	// Direct X 9
	,DXTypes
	,DXErr9
	,D3DX9
	,Direct3D9
	;

function SD3D9StrDepthFormat(const DepthFormat : TSMaxEnum) : TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SD3D9StrSDKVersion(const Version : TSMaxEnum) : TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SD3D9StrMULTISAMPLE(const MS : D3DMULTISAMPLE_TYPE) : TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
procedure SD3D9LogError(const Error : HRESULT); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
function SD3D9StrErrorCodeHex(const ErrorCode : HRESULT) : TSString;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	SD3D9AdaptersLoged : TSBool = False;
procedure SD3D9LogAdapters(const pD3D : IDirect3D9);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

	
implementation

uses
	 SmoothLog
	,SmoothStringUtils
	,SmoothBaseUtils
	
	,SysUtils
	;


procedure SD3D9LogAdapters(const pD3D : IDirect3D9);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	AdapterCount : TSMaxEnum;
	i : TSMaxEnum;
	Adapter : TD3DAdapterIdentifier9;
begin
AdapterCount := pD3D.GetAdapterCount();
SLog.Source(['Direct3D9: Finded ', AdapterCount, ' adapter(-s)', Iff(AdapterCount = 0, '.', ':')]);
if AdapterCount > 0 then
	for i := 0 to AdapterCount - 1 do
		if pD3D.GetAdapterIdentifier(i, 0, Adapter) = D3D_OK then
			begin
			SLog.Source('Adapter #' + SStr(i) + ':', False);
			SLog.Source('	Driver:           ' + Adapter.Driver, False);
			SLog.Source('	Description:      ' + Adapter.Description, False);
			SLog.Source('	DeviceName:       ' + Adapter.DeviceName, False);
{$IFDEF WIN32}
			SLog.Source(['	DriverVersion:    ', Adapter.DriverVersion], False);
{$ELSE}
			SLog.Source(['	DriverVersionLowPart:   ', Adapter.DriverVersionLowPart], False);
			SLog.Source(['	DriverVersionHighPart:  ', Adapter.DriverVersionHighPart], False);
{$ENDIF}
			SLog.Source(['	VendorIdentifier: ', Adapter.VendorId], False);
			SLog.Source(['	DeviceIdentifier: ', Adapter.DeviceId], False);
			SLog.Source(['	SubSysIdentifier: ', Adapter.SubSysId], False);
			SLog.Source(['	Revision:         ', Adapter.Revision], False);
			SLog.Source(['	DeviceIdentifier: ', GUIDToString(Adapter.DeviceIdentifier)], False);
			SLog.Source(['	WHQLLevel:        ', Adapter.WHQLLevel], False);
			end;
end;

function SD3D9StrErrorCodeHex(const ErrorCode : HRESULT) : TSString;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
{For example, if CreateDevice returns 0x8876086c, the first 4 digits are 0x8876 - that first 8 means "failure" (The high bit is set), 
the 876 part means "D3D", 
and the 086c part is the error code - 2156 in decimal. 
If you search d3d9.h for that number, you'll come across this:
#define D3DERR_INVALIDCALL MAKE_D3DHRESULT(2156)}
var
	Index : TSByte;
begin
Result := '0x';
for Index := SizeOf(HRESULT) - 1 downto 0 do
	Result += SStrByteHex(PSByte(@ErrorCode)[Index], True);
end;

procedure SD3D9LogError(const Error : HRESULT); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
SLogMakeSignificant();
SLog.Source(['TSRenderDirectX9: DirectX Error:']);
SLog.Source(['    ID (dec): ',Error]);
SLog.Source(['    ID (hex): ',SD3D9StrErrorCodeHex(Error)]);
SLog.Source(['    Discription: ',SPCharToString(DXGetErrorString9(Error))]);
end;

function SD3D9StrMULTISAMPLE(const MS : D3DMULTISAMPLE_TYPE) : TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
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

function SD3D9StrSDKVersion(const Version : TSMaxEnum) : TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
case Version of
D3D9b_SDK_VERSION : Result := 'D3D9b_SDK_VERSION';
D3D_SDK_VERSION   : Result := 'D3D_SDK_VERSION';
else Result := '';
end;
end;

function SD3D9StrDepthFormat(const DepthFormat : TSMaxEnum) : TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
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
