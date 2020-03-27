{$INCLUDE Smooth.inc}

{$RESOURCE .\..\..\Platforms\Windows\ExecutableResourse\Smooth.res}

unit SmoothWinAPIUtils;

interface

uses
	 Classes
	,SysUtils
	,Windows
	
	,SmoothBase
	,SmoothCasesOfPrint
	,SmoothLists
	;

const
	SCWAPI_ICON = 2;
type
	TSWinAPIParam =
		{$IFDEF CPU64}
			TSInt64
		{$ELSE} {$IFDEF CPU32}
			TSInt32
		{$ELSE} {$IFDEF CPU16}
			TSInt16
		{$ENDIF} {$ENDIF} {$ENDIF}
		;
type
	TSWinAPIHandle =
		{$IFDEF CPU64}
			TSUInt64
		{$ELSE} {$IFDEF CPU32}
			TSUInt32
		{$ELSE} {$IFDEF CPU16}
			TSUInt16
		{$ENDIF} {$ENDIF} {$ENDIF}
		;
function SWinAPISystemVersion(): TSString;
function SWinAPIRegistryRead(const VRootKey : HKEY; const VKey : TSString; const VStringName : TSString = '') : TSString;
function SSystemKeyPressed(const Index : TSByte) : TSBool;
function SWinAPIQueschion(const VQuestion, VCaption : TSString):TSBoolean;
function SKeyboardLayout(): TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SViewVideoDevices(const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SLogInternetAdaptersInfo() : TSMaxEnum;
function SInternetAdapterNames() : TSStringList;
function SInternetAdapterDescriptionFromName(const AdapterName : TSString) : TSString;

implementation

uses
	 Registry
	,MultiMon
	,StrMan
	
	// Internet tools
	,JwaIpHlpApi
	,JwaIpTypes
	
	,SmoothBaseUtils
	,SmoothStringUtils
	,SmoothLog
	;

function SInternetAdapterDescriptionFromName(const AdapterName : TSString) : TSString;
var
	BufferLength : TSUInt32 = 0;
	AdaptersInfo : PIP_ADAPTER_INFO = nil;
	AdapterInfo : PIP_ADAPTER_INFO = nil;
begin
Result := '';
GetAdaptersInfo(nil, BufferLength);
if BufferLength = 0 then
	exit;

AdaptersInfo := GetMem(BufferLength);
if GetAdaptersInfo(AdaptersInfo, BufferLength) = NO_ERROR then
	begin
	AdapterInfo := AdaptersInfo;
	while AdapterInfo <> nil do
		begin
		if AdapterInfo^.AdapterName = AdapterName then
			begin
			Result := AdapterInfo^.Description;
			break;
			end;
		AdapterInfo := AdapterInfo^.Next;
		end;
	end;
FreeMem(AdaptersInfo);
end;

function SInternetAdapterNames() : TSStringList;
var
	BufferLength : TSUInt32 = 0;
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

function SLogInternetAdaptersInfo() : TSMaxEnum;
type
	TAddress = array [0..MAX_ADAPTER_ADDRESS_LENGTH - 1] of TSUInt8;

function AddressToString(const Address : TAddress; const AddressLength : TSUInt32) : TSString;
var
	i : TSMaxEnum;
begin
Result := '';
for i := 0 to AddressLength - 1 do
	begin
	Result += SStr(Address[i]);
	if i <> AddressLength - 1 then
		Result += ' ';
	end;
end;

function IPAddressToString(const Address : IP_ADDR_STRING) : TSString;
begin
Result := '';
Result += 'IP=';
Result += Address.IpAddress.S;
Result += ', Mask=';
Result += Address.IpMask.S;
Result += ', Context=';
Result += SStr(Address.Context);
end;

procedure LogCurrentIPAddresses(const AdapterInfo : IP_ADAPTER_INFO);
var
	Address : PIP_ADDR_STRING = nil;
	Index : TSMaxEnum;
begin
Address := AdapterInfo.CurrentIpAddress;
Index := 0;
if Address = nil then
	begin
	SLog.Source(['        CurrentIpAddress(es): nil']);
	exit;
	end
else
	SLog.Source(['        CurrentIpAddress(es):']);
while Address <> nil do
	begin
	SLog.Source(['            Address ', Index, ': ', IPAddressToString(Address^), '.']);
	Index += 1;
	Address := Address^.Next;
	end;
end;

function TypeToString(const TheType : TSUInt32) : TSString;
var
	TextType : TSString = '';
begin
Result := SStr(TheType);
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
	BufferLength : TSUInt32 = 0;
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
	SLog.Source('Internet adapters:');
	while AdapterInfo <> nil do
		begin
		SLog.Source(['    Device ',Result,':']);
		SLog.Source(['        Name:          ', AdapterInfo^.AdapterName]);
		SLog.Source(['        Description:   ', AdapterInfo^.Description]);
		SLog.Source(['        Address:       ', AddressToString(AdapterInfo^.Address, AdapterInfo^.AddressLength)]);
		SLog.Source(['        Index:         ', AdapterInfo^.Index]);
		SLog.Source(['        Type:          ', TypeToString(AdapterInfo^.Type_)]);
		SLog.Source(['        DhcpEnabled:   ', AdapterInfo^.DhcpEnabled]);
		LogCurrentIPAddresses(AdapterInfo^);
		SLog.Source(['        IpAddressList: ', IPAddressToString(AdapterInfo^.IpAddressList)]);
		SLog.Source(['        GatewayList:   ', IPAddressToString(AdapterInfo^.GatewayList)]);
		SLog.Source(['        DhcpServer:    ', IPAddressToString(AdapterInfo^.DhcpServer)]);
		SLog.Source(['        HaveWins:      ', AdapterInfo^.HaveWins]);
		SLog.Source(['        PrimaryWinsServer:   ', IPAddressToString(AdapterInfo^.PrimaryWinsServer)]);
		SLog.Source(['        SecondaryWinsServer: ', IPAddressToString(AdapterInfo^.SecondaryWinsServer)]);
		
		Result += 1;
		AdapterInfo := AdapterInfo^.Next;
		end;
	end;
FreeMem(AdaptersInfo);
end;

procedure SViewVideoDevices(const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Devices : TSStringList = nil;
	Names : TSStringList = nil;

procedure ConstructLists();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	lpDisplayDevice : TDisplayDevice;
	dwFlags : TSLongWord;
	cc : TSLongWord;
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
	QuoteChar : TSChar = '"';
var
	i, ml0, ml1, ml2, h : TSMaxEnum;
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
		if Length(SStr(i)) > ml0 then
			ml0 := Length(SStr(i));
		if Length(Devices[i]) > ml1 then
			ml1 := Length(Devices[i]);
		if Length(Names[i]) > ml2 then
			ml2 := Length(Names[i]);
		end;
	ml1 += 3;
	ml2 += 3;
	SHint('Display devices: (' + SStr(h + 1) + ') --->', CasesOfPrint, True);
	for i := 0 to h do
		SHint([
				'	#', 
				StringJustifyRight(SStr(i), ml0, ' '),
				' - Device : ',
				StringJustifyLeft(QuoteChar + Devices[i] + QuoteChar + ',', ml1, ' '),
				' Name : ',
				StringTrimAll(StringJustifyLeft(QuoteChar + Names[i] + QuoteChar + Iff(i = h, '.', ';'), ml2, ' '), ' ')
			], CasesOfPrint);
	end
else
	SHint('Display devices are not found!', CasesOfPrint, True);
SKill(Devices);
SKill(Names);
end;

function SKeyboardLayout(): TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Layout : array [0..kl_namelength] of TSChar;
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

function SWinAPIQueschion(const VQuestion, VCaption : TSString):TSBoolean;
var
	PQuestion, PCaption : PSChar;
begin
PQuestion := SStringToPChar(VQuestion);
PCaption := SStringToPChar(VCaption);
Result := MessageBox(0, PQuestion, PCaption, MB_YESNO OR MB_ICONQUESTION) <> IDNO;
SPCharFree(PCaption);
SPCharFree(PQuestion);
end;

function SSystemKeyPressed(const Index : TSByte) : TSBool;
const
	KeyboardStateLength = 256;
var
	KeyboardState : PSByte;
begin
GetMem(KeyboardState, KeyboardStateLength);
if GetKeyboardState(KeyboardState) then
	Result := TSBoolean(KeyboardState[Index])
else
	Result := False;
FreeMem(KeyboardState, KeyboardStateLength);
end;

function SWinAPIRegistryRead(const VRootKey : HKEY; const VKey : TSString; const VStringName : TSString = '') : TSString;
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

function SWinAPISystemVersion(): TSString;
const
	VersionKey = '\SOFTWARE\Microsoft\Windows NT\CurrentVersion';
var
	ProductName : TSString = '';
	CSDVersion : TSString = '';
	CurrentBuild : TSString = '';
	CurrentVersion : TSString = '';
begin
Result := '';
ProductName := SWinAPIRegistryRead(HKEY_LOCAL_MACHINE, VersionKey, 'ProductName');
CSDVersion := SWinAPIRegistryRead(HKEY_LOCAL_MACHINE, VersionKey, 'CSDVersion');
CurrentBuild := SWinAPIRegistryRead(HKEY_LOCAL_MACHINE, VersionKey, 'CurrentBuild');
CurrentVersion := SWinAPIRegistryRead(HKEY_LOCAL_MACHINE, VersionKey, 'CurrentVersion');
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
