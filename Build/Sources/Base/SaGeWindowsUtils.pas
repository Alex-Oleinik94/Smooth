{$INCLUDE SaGe.inc}

{$RESOURCE .\..\..\Platforms\Windows\ExecutableResourse\Sun.res}

unit SaGeWindowsUtils;

interface

uses
	 Classes
	,SysUtils
	,Windows
	
	,SaGeBase
	,SaGeLog
	;

function SGWindowsVersion(): TSGString;
function SGWindowsRegistryRead(const VRootKey : HKEY; const VKey : TSGString; const VStringName : TSGString = '') : TSGString;
function SGSystemKeyPressed(const Index : TSGByte) : TSGBool;
function SGWinAPIQueschion(const VQuestion, VCaption : TSGString):TSGBoolean;
function SGKeyboardLayout(): TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGViewVideoDevices(const ViewType : TSGViewErrorType = [SGLogType, SGPrintType]);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGLogInternetAdaptersInfo() : TSGMaxEnum;
function SGInternetAdapterNames() : TSGStringList;

implementation

uses
	 Registry
	,MultiMon
	,StrMan
	
	// Internet tools
	,JwaIpHlpApi
	,JwaIpTypes
	
	,SaGeBaseUtils
	,SaGeStringUtils
	;

function SGInternetAdapterNames() : TSGStringList;
var
	BufferLength : TSGUInt32 = 0;
	AdaptersInfo : PIP_ADAPTER_INFO = nil;
	AdapterInfo : PIP_ADAPTER_INFO = nil;
begin
Result := nil;
GetAdaptersInfo(nil, BufferLength);
if BufferLength = 0 then
	exit;
AdaptersInfo := GetMem(BufferLength);
if GetAdaptersInfo(AdaptersInfo, BufferLength) = NO_ERROR then
	begin
	AdapterInfo := AdaptersInfo;
	while AdapterInfo <> nil do
		begin
		Result += AdapterInfo^.AdapterName;
		AdapterInfo := AdapterInfo^.Next;
		end;
	end;
FreeMem(AdaptersInfo);
end;

function SGLogInternetAdaptersInfo() : TSGMaxEnum;
type
	TAddress = array [0..MAX_ADAPTER_ADDRESS_LENGTH - 1] of TSGUInt8;

function AddressToString(const Address : TAddress; const AddressLength : TSGUInt32) : TSGString;
var
	i : TSGMaxEnum;
begin
Result := '';
for i := 0 to AddressLength - 1 do
	begin
	Result += SGStr(Address[i]);
	if i <> AddressLength - 1 then
		Result += ' ';
	end;
end;

function IPAddressToString(const Address : IP_ADDR_STRING) : TSGString;
begin
Result := '';
Result += 'IP=';
Result += Address.IpAddress.S;
Result += ', Mask=';
Result += Address.IpMask.S;
Result += ', Context=';
Result += SGStr(Address.Context);
end;

procedure LogCurrentIPAddresses(const AdapterInfo : IP_ADAPTER_INFO);
var
	Address : PIP_ADDR_STRING = nil;
	Index : TSGMaxEnum;
begin
Address := AdapterInfo.CurrentIpAddress;
Index := 0;
if Address = nil then
	begin
	SGLog.Source(['        CurrentIpAddress(es): nil']);
	exit;
	end
else
	SGLog.Source(['        CurrentIpAddress(es):']);
while Address <> nil do
	begin
	SGLog.Source(['            Address ', Index, ': ', IPAddressToString(Address^), '.']);
	Index += 1;
	Address := Address^.Next;
	end;
end;

function TypeToString(const TheType : TSGUInt32) : TSGString;
var
	TextType : TSGString = '';
begin
Result := SGStr(TheType);
case TheType of
1  : TextType := 'MIB_IF_TYPE_OTHER';
6  : TextType := 'MIB_IF_TYPE_ETHERNET';
9  : TextType := 'IF_TYPE_ISO88025_TOKENRING';
23 : TextType := 'MIB_IF_TYPE_PPP';
24 : TextType := 'MIB_IF_TYPE_LOOPBACK';
28 : TextType := 'MIB_IF_TYPE_SLIP';
71 : TextType := 'IF_TYPE_IEEE80211';
end;
if TextType <> '' then
	Result += ' is ' + TextType;
end;

var
	BufferLength : TSGUInt32 = 0;
	AdaptersInfo : PIP_ADAPTER_INFO = nil;
	AdapterInfo : PIP_ADAPTER_INFO = nil;
begin
Result := 0;
GetAdaptersInfo(nil, BufferLength);
if BufferLength = 0 then
	exit;
AdaptersInfo := GetMem(BufferLength);
if GetAdaptersInfo(AdaptersInfo, BufferLength) = NO_ERROR then
	begin
	AdapterInfo := AdaptersInfo;
	SGLog.Source('Internet adapters:');
	while AdapterInfo <> nil do
		begin
		SGLog.Source(['    Device ',Result,':']);
		SGLog.Source(['        Name:          ', AdapterInfo^.AdapterName]);
		SGLog.Source(['        Description:   ', AdapterInfo^.Description]);
		SGLog.Source(['        Address:       ', AddressToString(AdapterInfo^.Address, AdapterInfo^.AddressLength)]);
		SGLog.Source(['        Index:         ', AdapterInfo^.Index]);
		SGLog.Source(['        Type:          ', TypeToString(AdapterInfo^.Type_)]);
		SGLog.Source(['        DhcpEnabled:   ', AdapterInfo^.DhcpEnabled]);
		LogCurrentIPAddresses(AdapterInfo^);
		SGLog.Source(['        IpAddressList: ', IPAddressToString(AdapterInfo^.IpAddressList)]);
		SGLog.Source(['        GatewayList:   ', IPAddressToString(AdapterInfo^.GatewayList)]);
		SGLog.Source(['        DhcpServer:    ', IPAddressToString(AdapterInfo^.DhcpServer)]);
		SGLog.Source(['        HaveWins:      ', AdapterInfo^.HaveWins]);
		SGLog.Source(['        PrimaryWinsServer:   ', IPAddressToString(AdapterInfo^.PrimaryWinsServer)]);
		SGLog.Source(['        SecondaryWinsServer: ', IPAddressToString(AdapterInfo^.SecondaryWinsServer)]);
		
		Result += 1;
		AdapterInfo := AdapterInfo^.Next;
		end;
	end;
FreeMem(AdaptersInfo);
end;

procedure SGViewVideoDevices(const ViewType : TSGViewErrorType = [SGLogType, SGPrintType]);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Devices : TSGStringList = nil;
	Names : TSGStringList = nil;

procedure ConstructLists();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	lpDisplayDevice : TDisplayDevice;
	dwFlags : TSGLongWord;
	cc : TSGLongWord;
begin
lpDisplayDevice.cb := sizeof(lpDisplayDevice);
dwFlags := 0;
cc := 0;
while (EnumDisplayDevices(nil, cc, @lpDisplayDevice, dwFlags)) do
	begin
	Devices += lpDisplayDevice.DeviceString;
	Names += lpDisplayDevice.DeviceName;
	cc := cc + 1;
	end;
end;

const
	QuoteChar : TSGChar = '"';
var
	i, ml0, ml1, ml2, h : TSGMaxEnum;
begin
ConstructLists();
h := Min(High(Devices), High(Names));
if h <> 0 then
	begin
	ml0 := 0;
	ml1 := 0;
	ml2 := 0;
	for i := 0 to h do
		begin
		if Length(SGStr(i)) > ml0 then
			ml0 := Length(SGStr(i));
		if Length(Devices[i]) > ml1 then
			ml1 := Length(Devices[i]);
		if Length(Names[i]) > ml2 then
			ml2 := Length(Names[i]);
		end;
	ml1 += 3;
	ml2 += 3;
	SGHint('Display devices: (' + SGStr(h + 1) + ') --->', ViewType, True);
	for i := 0 to h do
		SGHint([
				'	#', 
				StringJustifyRight(SGStr(i), ml0, ' '),
				' - Device : ',
				StringJustifyLeft(QuoteChar + Devices[i] + QuoteChar + ',', ml1, ' '),
				' Name : ',
				StringTrimAll(StringJustifyLeft(QuoteChar + Names[i] + QuoteChar + Iff(i = h, '.', ';'), ml2, ' '), ' ')
			], ViewType);
	end
else
	SGHint('Display devices are not found!', ViewType, True);
SGKill(Devices);
SGKill(Names);
end;

function SGKeyboardLayout(): TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Layout : array [0..kl_namelength] of TSGChar;
begin
GetKeyboardLayoutName(Layout);
// HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts
if Layout = '00000409' then
	Result := 'EN'
else if Layout = '00000419' then
	Result := 'RU'
else
	Result := 'Unknown';
end;

function SGWinAPIQueschion(const VQuestion, VCaption : TSGString):TSGBoolean;
var
	PQuestion, PCaption : PSGChar;
begin
PQuestion := SGStringToPChar(VQuestion);
PCaption := SGStringToPChar(VCaption);
Result := MessageBox(0, PQuestion, PCaption, MB_YESNO OR MB_ICONQUESTION) <> IDNO;
SGPCharFree(PCaption);
SGPCharFree(PQuestion);
end;

function SGSystemKeyPressed(const Index : TSGByte) : TSGBool;
const
	KeyboardStateLength = 256;
var
	KeyboardState : PSGByte;
begin
GetMem(KeyboardState, KeyboardStateLength);
if GetKeyboardState(KeyboardState) then
	Result := TSGBoolean(KeyboardState[Index])
else
	Result := False;
FreeMem(KeyboardState, KeyboardStateLength);
end;

function SGWindowsRegistryRead(const VRootKey : HKEY; const VKey : TSGString; const VStringName : TSGString = '') : TSGString;
begin
with TRegistry.Create() do
	begin
	try
		RootKey := VRootKey;
		if OpenKeyReadOnly(VKey) then
			Result := ReadString(VStringName);
	finally
		Free;
	end;
	end;
end;

function SGWindowsVersion(): TSGString;
const
	VersionKey = '\SOFTWARE\Microsoft\Windows NT\CurrentVersion';
var
	ProductName : TSGString = '';
	CSDVersion : TSGString = '';
	CurrentBuild : TSGString = '';
	CurrentVersion : TSGString = '';
begin
Result := '';
ProductName := SGWindowsRegistryRead(HKEY_LOCAL_MACHINE, VersionKey, 'ProductName');
CSDVersion := SGWindowsRegistryRead(HKEY_LOCAL_MACHINE, VersionKey, 'CSDVersion');
CurrentBuild := SGWindowsRegistryRead(HKEY_LOCAL_MACHINE, VersionKey, 'CurrentBuild');
CurrentVersion := SGWindowsRegistryRead(HKEY_LOCAL_MACHINE, VersionKey, 'CurrentVersion');
if ProductName = '' then
	begin
	if CurrentVersion <> '' then
		Result += Iff(Result <> '', ' ') + 'Version ' + CurrentVersion;
	if CurrentBuild <> '' then
		Result += Iff(Result <> '', ' ') + 'Build ' + CurrentBuild;
	end
else
	begin
	Result := ProductName;
	if CSDVersion <> '' then
		Result += ' ' + CSDVersion;
	if CurrentBuild + CurrentVersion <> '' then
		begin
		Result += ' (';
		if CurrentVersion <> '' then
			Result += 'Version ' + CurrentVersion;
		if CurrentBuild <> '' then
			Result += Iff(CurrentVersion <> '', ' ') + 'Build ' + CurrentBuild;
		Result += ')';
		end;
	end;
end;

end.
