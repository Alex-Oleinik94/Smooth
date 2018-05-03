{$INCLUDE SaGe.inc}
//{$DEFINE PCAP_TEST}

unit SaGePcapUtils;

interface

uses
	 SaGeBase
	,SaGeClasses
	
	,Pcap
	,Sockets
	;

const
	MAX_BUFFER_SIZE = 2000000000; //8192
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
	TSGPCAPCallBack = TPcapHandler;
	TSGPCAPHandler = TSGPCAPCallBack;
	PSGPCAPPacket = PPcap_Pkthdr;
	
	TSGPCAPPacket = object
			public
		Header : TPcap_Pkthdr;
		Data : PSGByte;
			public
		procedure Free();
		procedure ZeroMemory();
		end;
	
	TSGPCAPDevicePacket = object(TSGPCAPPacket)
			public
		Device : TSGString;
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
function SGPCAPInternetAdapterDescriptionFromName(const AdapterName : TSGString) : TSGString;
function SGPCAPInternetAdapterSystemName(const AdapterName : TSGString) : TSGString;
function SGPCAPInternetAdapterSystemDescriptionFromName(const AdapterName : TSGString) : TSGString;
function SGPCAPTestDeviceNetMask(const AdapterName : TSGString) : TSGBoolean;
function SGPCAPEndlessLoop(const Handle : TSGPCAPDeviceHandle; const Handler : TSGPCAPHandler; const UserData : TSGPointer = nil) : TSGInt32;
procedure SGPCAPClose(const Handle : TSGPCAPDeviceHandle);

implementation

uses
	 SaGeLog
	,SaGeDllManager
	,SaGeStringUtils
	{$IFDEF MSWINDOWS}
		,SaGeWindowsUtils
		{$ENDIF}
	;

procedure SGPCAPClose(const Handle : TSGPCAPDeviceHandle);
begin
pcap_close(Handle);
end;

function SGPCAPEndlessLoop(const Handle : TSGPCAPDeviceHandle; const Handler : TSGPCAPHandler; const UserData : TSGPointer = nil) : TSGInt32;
begin
Result := 0;
if not DllManager.Suppored('pcap') then
	begin
	SGLog.Source(['Невозможно использовать библиотеку PCAP!']);
	exit;
	end;
Result := pcap_loop ( // Возвращает количество считаных пакетов, -1 если ошибка
	Handle,    // Устройство
	-1,        // Количество пакетов, прослушаных до возврата функции
	Handler,   // Функция обратного вызова
	UserData); // Пользовательские данные
end;

function SGPCAPInternetAdapterSystemDescriptionFromName(const AdapterName : TSGString) : TSGString;
begin
Result := '';
{$IFDEF MSWINDOWS}
Result := SGInternetAdapterDescriptionFromName(
	SGPCAPInternetAdapterSystemName(AdapterName));
{$ENDIF}
end;

function SGPCAPInternetAdapterSystemName(const AdapterName : TSGString) : TSGString;
{$IFDEF MSWINDOWS}
const
	WindowsStringBegin = '\Device\NPF_';
{$ENDIF}
begin
Result := AdapterName;
{$IFDEF MSWINDOWS}
if SGExistsFirstPartString(AdapterName, WindowsStringBegin) and 
	(Length(WindowsStringBegin) + 1 <= Length(AdapterName)) then
	Result := SGStringGetPart(AdapterName, Length(WindowsStringBegin) + 1, Length(AdapterName));
{$ENDIF}
end;

function SGPCAPInternetAdapterDescriptionFromName(const AdapterName : TSGString) : TSGString;
var
	Error : TSGPCAPErrorString;
	Device : PPcap_If = nil;
	FirstDevice : PPcap_If = nil;
	ReturnedValue : TSGInt32 = 0;
	Index : TSGMaxEnum = 0;
	SystemDescription : TSGString = '';
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

SystemDescription := SGPCAPInternetAdapterSystemDescriptionFromName(AdapterName);
if Length(Result) < Length(SystemDescription) then
	Result := SystemDescription;
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

procedure TSGPCAPDevicePacket.Free();
begin
FreeMem(Data);
ZeroMemory();
end;

procedure TSGPCAPDevicePacket.ZeroMemory();
begin
FillChar(Self, SizeOf(TSGPCAPPacket), 0);
Device := '';
end;

procedure TSGPCAPPacket.Free();
begin
FreeMem(Data);
ZeroMemory();
end;

procedure TSGPCAPPacket.ZeroMemory();
begin
FillChar(Self, SizeOf(TSGPCAPPacket), 0);
end;

function SGPCAPJackOnePacket(const DeviceHandle : PPcap) : TSGPCAPPacket;
begin
Result.ZeroMemory();
Result.Data := PSGByte(pcap_next(DeviceHandle, @Result.Header));
{$IFDEF PCAP_TEST}
SGHint(['Перехвачен пакет с длинной "', Result.Header.Len, '", Packet = "', TSGPointer(Result.Data), '".']);
{$ENDIF}
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
	{$IFDEF PCAP_TEST}
	SGHint(['Невозможно использовать библиотеку PCAP!']);
	{$ENDIF}
	exit;
	end;

if Device = nil then
	begin
	Device := pcap_lookupdev(@Error);
	if Device = nil then
		begin
		{$IFDEF PCAP_TEST}
		SGHint(['Невозможно найти устройство по-умолчанию!', SGPCAPErrorString(Error)]);
		{$ENDIF}
		exit;
		end
	else
		begin
		{$IFDEF PCAP_TEST}
		SGHint(['Устройство по-умолчанию найдено! DeviceName = "', Device, '"']);
		{$ENDIF}
		end;
	end;

Description := SGPCAPInternetAdapterDescriptionFromName(SGPCharToString(Device));
if Description = '' then
	Description := SGPCharToString(Device);

if (P_NET <> nil) or (P_Mask <> nil) then
	if (pcap_lookupnet(Device, P_NET, P_Mask, Error) = -1) then
		begin
		{$IFDEF PCAP_TEST}
		SGHint(['Невозможно узнать маску для устройства "', Description, '"!']);
		if P_NET <> nil then
			P_NET^ := 0;
		if P_Mask <> nil then
			P_Mask^ := 0;
		{$ENDIF}
		end
	else
		begin
		{$IFDEF PCAP_TEST}
		SGHint(['Данные устройства "', Description, '":']);
		if (P_NET <> nil) then
			SGHint(['    NET = ', SGPCAPAddressToString(P_NET^)]);
		if (P_Mask <> nil) then
			SGHint(['    Маска = ', SGPCAPAddressToString(P_Mask^)]);
		{$ENDIF}
		end;

Result := pcap_open_live(
	Device, // Имя устройства
	MAX_BUFFER_SIZE, // Максимальное количество байтов, которое будет записано
	0,      // TRUE - беспорядочный режим работы устройства
	2,      // Таймаут
	Error);
if Result = nil then
	begin
	{$IFDEF PCAP_TEST}
	SGHint(['Невозможно открыть устройство "', Description, '"', SGPCAPErrorString(Error, True), '!']);
	{$ENDIF}
	exit;
	end
else
	begin
	{$IFDEF PCAP_TEST}
	SGHint(['Устройство "', Description, '" открыто.']);
	{$ENDIF}
	end;
end;

function SGPCAPTestDeviceNetMask(const AdapterName : TSGString) : TSGBoolean;
var
	Error : TSGPCAPErrorString;
	Net, Mask : TSGPCAPAddress;
	Device : TSGPCAPDevice;
begin
Result := False;
if not DllManager.Suppored('pcap') then
	begin
	{$IFDEF PCAP_TEST}
	SGHint(['Невозможно использовать библиотеку PCAP!']);
	{$ENDIF}
	exit;
	end;
if pcap_lookupnet = nil then
	begin
	{$IFDEF PCAP_TEST}
	SGHint(['Невозможно использовать функцию PCAP.pcap_lookupnet(..)!']);
	{$ENDIF}
	exit;
	end;

Device := SGStringToPChar(AdapterName);
if (pcap_lookupnet(Device, @Net, @Mask, Error) <> -1) then
	Result := (Net <> 0) and (Mask <> 0)
else
	begin
	{$IFDEF PCAP_TEST}
	SGHint(['PCAP.pcap_lookupnet(..) : Error "', Error, '"!']);
	{$ENDIF}
	end;
FreeMem(Device);
end;

function SGPCAPInitializeDeviceFilter(const DeviceHandle : PPcap; const FilterString : PSGChar = ''; const IP : TSGUInt32 = 0) : PBPF_Program;
begin
if DeviceHandle = nil then
	Exit;

if (pcap_compile(DeviceHandle, @Result, FilterString, 0, IP) = -1) then
	begin
	{$IFDEF PCAP_TEST}
	SGHint(['Couldn''t parse filter "', FilterString, '", Error: "', pcap_geterr(DeviceHandle), '"!']);
	{$ENDIF}
	exit;
	end;
if (pcap_setfilter(DeviceHandle, @Result) = -1) then
	begin
	{$IFDEF PCAP_TEST}
	SGHint(['Couldn''t install filter "', FilterString, '", Error: "', pcap_geterr(DeviceHandle), '"!']);
	{$ENDIF}
	exit;
	end;
end;

end.
