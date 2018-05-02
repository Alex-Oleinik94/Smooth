{$INCLUDE SaGe.inc}

unit SaGePcapUtils;

interface

uses
	 SaGeBase
	,SaGeClasses
	
	,Pcap
	,Sockets
	;

const
	BUFSIZ = 8192;
type
	TSGPCAPErrorString = array[0..PCAP_ERRBUF_SIZE-1] of TSGChar;
	TSGPCAPString = PSGChar;
	TSGPCAPDevice = TSGPCAPString;
	TSGPCAPDeviceName = TSGPCAPString;
	TSGPCAPDeviceHandle = PPcap;
	TSGPCAPDeviceFilter = PBPF_Program;
	TSGPCAPAddress = TSGUInt32;
	TSGPCAPIPAddress = TSGPCAPAddress;
	TSGPCAPMask = TSGPCAPAddress;
	
	TSGPCAPPacket = object
			public
		Header : TPcap_Pkthdr;
		Data : PSGByte;
			public
		procedure Free();
		procedure ZeroMemory();
		end;

function SGPCAPInitializeDevice(Device : TSGPCAPDevice; const P_NET : PSGUInt32 = nil; const P_Mask : PSGUInt32 = nil) : TSGPCAPDeviceHandle;
function SGPCAPInitializeDeviceFilter(const DeviceHandle : TSGPCAPDeviceHandle; const FilterString : PSGChar = ''; const IP : TSGUInt32 = 0) : TSGPCAPDeviceFilter;
function SGPCAPErrorString(const Error : TSGPCAPErrorString; const WithComma : TSGBoolean = False) : TSGString;
function SGPCAPJackOnePacket(const DeviceHandle : TSGPCAPDeviceHandle) : TSGPCAPPacket;
procedure SGPCAPJackOnePacketFromDefaultDevice();
procedure SGPCAPTryOpenDevice(const DeviceName : TSGString);
function SGPCAPLogInternetDevices() : TSGMaxEnum;
function SGPCAPInternetAdapterNames() : TSGStringList;
function SGPCAPAddressToString(Address : TSGPCAPAddress) : TSGString;

implementation

uses
	 SaGeLog
	,SaGeDllManager
	,SaGeStringUtils
	;

function SGPCAPInternetAdapterDescriptionFromName(const AdapterName : TSGString) : TSGString;
var
	Error : TSGPCAPErrorString;
	Device : PPcap_If = nil;
	FirstDevice : PPcap_If = nil;
	ReturnedValue : TSGInt32 = 0;
	Index : TSGMaxEnum = 0;
begin
Result := '';
if AdapterName <> '' then
	begin
	if not DllManager.Suppored('pcap') then
		begin
		SGLog.Source(['Невозможно использовать библиотеку PCAP!']);
		exit;
		end;
	if pcap_findalldevs = nil then
		begin
		SGLog.Source(['Невозможно использовать функцию PCAP.pcap_findalldevs(..)!']);
		exit;
		end;
	Error := '';
	
	ReturnedValue := pcap_findalldevs(@Device, Error);
	if ReturnedValue <> -1 then
		begin
		FirstDevice := Device;
		while Device <> nil do
			begin
			if Device^.Name = AdapterName then
				begin
				Result := Device^.description;
				break;
				end;
			
			Device := Device^.Next;
			Index += 1;
			end;
		{if FirstDevice <> nil then
			FreeMem(FirstDevice);}
		
		{$IFDEF MSWINDOWS}
		if (AdapterName = '\') and (Result = '') then
			Result := 'Default';
		{$ENDIF}
		end
	else
		SGLog.Source(['PCAP:pcap_findalldevs(..) : Returned value "', ReturnedValue, '", error: "', Error, '".']);
	end;
end;

function SGPCAPAddressToString(Address : TSGPCAPAddress) : TSGString;
begin
Result := 
	SGStr(PSGByte(@Address)[0]) + '.' +
	SGStr(PSGByte(@Address)[1]) + '.' +
	SGStr(PSGByte(@Address)[2]) + '.' +
	SGStr(PSGByte(@Address)[3]) ;
end;

function SGPCAPInternetAdapterNames() : TSGStringList;
var
	Error : TSGPCAPErrorString;
	Device : PPcap_If = nil;
	FirstDevice : PPcap_If = nil;
	ReturnedValue : TSGInt32 = 0;
	Index : TSGMaxEnum = 0;
begin
Result := nil;
if not DllManager.Suppored('pcap') then
	begin
	SGLog.Source(['Невозможно использовать библиотеку PCAP!']);
	exit;
	end;
if pcap_findalldevs = nil then
	begin
	SGLog.Source(['Невозможно использовать функцию PCAP.pcap_findalldevs(..)!']);
	exit;
	end;
Error := '';

ReturnedValue := pcap_findalldevs(@Device, Error);
if ReturnedValue <> -1 then
	begin
	FirstDevice := Device;
	while Device <> nil do
		begin
		Result += Device^.Name;
		Device := Device^.Next;
		Index += 1;
		end;
	{if FirstDevice <> nil then
		FreeMem(FirstDevice);}
	end
else
	SGLog.Source(['PCAP:pcap_findalldevs(..) : Returned value "', ReturnedValue, '", error: "', Error, '".']);
end;

function SGPCAPLogInternetDevices() : TSGMaxEnum;

function LogAddresses(const Addresses : PPcap_Addr = nil) : TSGMaxEnum;

procedure LogSocketAddress(const Name : TSGString; const SocketAddress :  PSockAddr);
type
	TDataList14 = array [0..13] of TSGUInt8;

function DataToString(const Data : TDataList14) : TSGString;
var
	Index : TSGMaxEnum;
begin
Result := '';
for Index := 0 to 13 do
	begin
	Result += SGStr(Data[Index]);
	if Index <> 13 then
		Result += ' ';
	end;
end;

begin
if SocketAddress = nil then
	SGLog.Source(['            ', Name, ' : nil'])
else
	begin
	SGLog.Source(['            ', Name, ' : ']);
	SGLog.Source(['                Address family : ', SocketAddress^.sa_family]);
	SGLog.Source(['                Addres data    : ', DataToString(SocketAddress^.sa_data)]);
	end;
end;

var
	Address : PPcap_Addr = nil;
begin
Result := 0;
if Addresses = nil then
	begin
	SGLog.Source(['        Addresses : nil']);
	end
else
	begin
	Address := Addresses;
	while Address <> nil do
		begin
		SGLog.Source(['        Address ', Result, ':']);
		LogSocketAddress('addr', Address^.addr);
		LogSocketAddress('netmask', Address^.netmask);
		LogSocketAddress('broadaddr', Address^.broadaddr);
		LogSocketAddress('dstaddr', Address^.dstaddr);
		
		Result += 1;
		Address := Address^.Next;
		end;
	end;
end;

var
	Error : TSGPCAPErrorString;
	Device : PPcap_If = nil;
	FirstDevice : PPcap_If = nil;
	ReturnedValue : TSGInt32 = 0;
begin
Result := 0;
if not DllManager.Suppored('pcap') then
	begin
	SGLog.Source(['Невозможно использовать библиотеку PCAP!']);
	exit;
	end;
if pcap_findalldevs = nil then
	begin
	SGLog.Source(['Невозможно использовать функцию PCAP.pcap_findalldevs(..)!']);
	exit;
	end;
Error := '';

ReturnedValue := pcap_findalldevs(@Device, Error);
if ReturnedValue <> -1 then
	begin
	SGLog.Source(['All PCAP internet devices:']);
	FirstDevice := Device;
	while Device <> nil do
		begin
		SGLog.Source(['    Device ', Result, ':']);
		SGLog.Source(['        Name : ', Device^.Name]);
		SGLog.Source(['        Description : ', Device^.description]);
		SGLog.Source(['        Flags : ', Device^.flags]);
		LogAddresses(Device^.addresses);
		
		Device := Device^.Next;
		Result += 1;
		end;
	{if FirstDevice <> nil then
		FreeMem(FirstDevice);}
	end
else
	SGLog.Source(['PCAP:pcap_findalldevs(..) : Returned value "', ReturnedValue, '", error: "', Error, '".']);
end;

procedure SGPCAPTryOpenDevice(const DeviceName : TSGString);
var
	Device : TSGPCAPDeviceName = nil;
	IP, Mask : TSGUInt32;
	Handle : TSGPCAPDeviceHandle = nil;
begin
Device := SGStringToPChar(DeviceName);
Handle := SGPCAPInitializeDevice(Device, @IP, @Mask);
if Handle <> nil then
	pcap_close(Handle);
end;

procedure SGPCAPJackOnePacketFromDefaultDevice();
var
	Device : TSGPCAPDeviceName = nil;
	IP, Mask : TSGUInt32;
	Handle : TSGPCAPDeviceHandle = nil;
begin
Handle := SGPCAPInitializeDevice(Device, @IP, @Mask);
if Handle = nil then
	exit;
//SGPCAPInitializeDeviceFilter(Handle, 'port 23', IP);
SGPCAPJackOnePacket(Handle).Free();
pcap_close(Handle);
end;

procedure TSGPCAPPacket.Free();
begin
FreeMem(Data);
ZeroMemory();
end;

procedure TSGPCAPPacket.ZeroMemory();
begin
FillChar(Self, SizeOf(Self), 0);
end;

function SGPCAPJackOnePacket(const DeviceHandle : PPcap) : TSGPCAPPacket;
begin
Result.ZeroMemory();
Result.Data := PSGByte(pcap_next(DeviceHandle, @Result.Header));
SGHint(['Перехвачен пакет с длинной "', Result.Header.Len, '", Packet = "', TSGPointer(Result.Data), '".']);
end;

function SGPCAPErrorString(const Error : TSGPCAPErrorString; const WithComma : TSGBoolean = False) : TSGString;
begin
Result := '';
if Error <> '' then
	begin
	if WithComma then
		Result += ',';
	Result += ' ';
	Result += 'Error = "' + Error + '"';
	end;
end;

function SGPCAPInitializeDevice(Device : TSGPCAPDevice; const P_NET : PSGUInt32 = nil; const P_Mask : PSGUInt32 = nil) : PPcap;
var
	Error : TSGPCAPErrorString;
	Description : TSGString;
begin
FillChar(Result, SizeOf(Result), 0);

if not DllManager.Suppored('pcap') then
	begin
	SGHint(['Невозможно использовать библиотеку PCAP!']);
	exit;
	end;

if Device = nil then
	begin
	Device := pcap_lookupdev(@Error);
	if Device = nil then
		begin
		SGHint(['Невозможно найти устройство по-умолчанию!', SGPCAPErrorString(Error)]);
		exit;
		end
	else
		SGHint(['Устройство по-умолчанию найдено! DeviceName = "', Device, '"']);
	end;

Description := SGPCAPInternetAdapterDescriptionFromName(SGPCharToString(Device));
if Description = '' then
	Description := SGPCharToString(Device);

if (P_NET <> nil) or (P_Mask <> nil) then
	if (pcap_lookupnet(Device, P_NET, P_Mask, Error) = -1) then
		begin
		SGHint(['Невозможно узнать маску для устройства "', Description, '"!']);
		if P_NET <> nil then
			P_NET^ := 0;
		if P_Mask <> nil then
			P_Mask^ := 0;
		end
	else
		begin
		SGHint(['Данные устройства "', Description, '":']);
		if (P_NET <> nil) then
			SGHint(['    NET = ', SGPCAPAddressToString(P_NET^)]);
		if (P_Mask <> nil) then
			SGHint(['    Маска = ', SGPCAPAddressToString(P_Mask^)]);
		end;

Result := pcap_open_live(Device, BUFSIZ, 1, 1000, Error);
if Result = nil then
	begin
	SGHint(['Невозможно открыть устройство "', Description, '"', SGPCAPErrorString(Error, True), '!']);
	exit;
	end
else
	SGHint(['Устройство "', Description, '" открыто.']);
end;

function SGPCAPInitializeDeviceFilter(const DeviceHandle : PPcap; const FilterString : PSGChar = ''; const IP : TSGUInt32 = 0) : PBPF_Program;
begin
if DeviceHandle = nil then
	Exit;

if (pcap_compile(DeviceHandle, @Result, FilterString, 0, IP) = -1) then
	begin
	SGHint(['Couldn''t parse filter "', FilterString, '", Error: "', pcap_geterr(DeviceHandle), '"!']);
	exit;
	end;
if (pcap_setfilter(DeviceHandle, @Result) = -1) then
	begin
	SGHint(['Couldn''t install filter "', FilterString, '", Error: "', pcap_geterr(DeviceHandle), '"!']);
	exit;
	end;
end;

end.
