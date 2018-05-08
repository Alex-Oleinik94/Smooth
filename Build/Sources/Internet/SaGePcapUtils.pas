{$INCLUDE SaGe.inc}
//{$DEFINE PCAP_HINT_TEST}

unit SaGePcapUtils;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeInternetBase
	
	,Sockets
	,Classes
	
	,Pcap
	;

type
	TPcap_PacketHeader = TPcap_Pkthdr;
	PPcap_PacketHeader = PPcap_Pkthdr;
type
	TSGPcapString = PSGChar;
const
	SGPcapMaxBufferSize = 2000000000; //8192
const
	pcap_default_timeout  = 0;
	pcap_promiscuous_mode = $0001;
	pcap_default_mode     = $0000;
type
	TSGPcapDevice = TSGPcapString;
	TSGPcapDeviceName = TSGPcapString;
	
	TSGPcapErrorString = array[0..PCAP_ERRBUF_SIZE-1] of TSGChar;
	TSGPcapDeviceHandle = PPcap;
	TSGPcapDeviceFilter = PBPF_Program;
	TSGPcapCallBack = TPcapHandler;
	PSGPcapPacketHeader = PPcap_PacketHeader;
	TSGPcapPacketHeader = TPcap_PacketHeader;
	
	TSGPcapIPv4Address = TSGIPv4Address;
	TSGPcapIPv4Mask = TSGIPv4Address;
	TSGPcapIPv4Net = TSGIPv4Address;
	TSGPcapHandler = TSGPcapCallBack;
	
	TSGPcapPacket = object
			public
		Header : TPcap_PacketHeader;
		Data : PSGByte;
			public
		function CreateStream() : TMemoryStream;
		procedure Free();
		procedure ZeroMemory();
		end;
	
function SGPcapInitializeDevice(Device : TSGPcapDevice; const P_NET : PSGUInt32 = nil; const P_Mask : PSGUInt32 = nil) : TSGPcapDeviceHandle;
function SGPcapInitializeDeviceFilter(const DeviceHandle : TSGPcapDeviceHandle; const FilterString : PSGChar = ''; const IP : TSGUInt32 = 0) : TSGPcapDeviceFilter;
function SGPcapErrorString(const Error : TSGPcapErrorString; const WithComma : TSGBoolean = False) : TSGString;
function SGPcapJackOnePacket(const DeviceHandle : TSGPcapDeviceHandle) : TSGPcapPacket;
procedure SGPcapJackOnePacketFromDefaultDevice();
procedure SGPcapTryOpenDevice(const DeviceName : TSGString);
function SGPcapLogInternetDevices() : TSGMaxEnum;
function SGPcapInternetAdapterNames() : TSGStringList;
function SGPcapInternetAdapterDescriptionFromName(const AdapterName : TSGString) : TSGString;
function SGPcapInternetAdapterPcapDescriptionFromName(const AdapterName : TSGString) : TSGString;
function SGPcapInternetAdapterSystemDescriptionFromName(const AdapterName : TSGString) : TSGString;
function SGPcapInternetAdapterSystemName(const AdapterName : TSGString) : TSGString;
function SGPcapTestDeviceNetMask(const AdapterName : TSGString) : TSGBoolean;
function SGPcapEndlessLoop(const Handle : TSGPcapDeviceHandle; const Handler : TSGPcapHandler; const UserData : TSGPointer = nil) : TSGInt32;
procedure SGPcapClose(const Handle : TSGPcapDeviceHandle);
function SGPcapNext(const Handle : TSGPcapDeviceHandle; const Handler : TSGPcapHandler; const UserData : TSGPointer = nil) : TSGBoolean;

implementation

uses
	 SaGeLog
	,SaGeDllManager
	,SaGeStringUtils
	{$IFDEF MSWINDOWS}
		,SaGeWindowsUtils
		{$ENDIF}
	;


function TSGPcapPacket.CreateStream() : TMemoryStream;
begin
Result := TMemoryStream.Create();
Result.WriteBuffer(Data^, Header.CapLen);
Result.Position := 0;
end;

procedure SGPcapClose(const Handle : TSGPcapDeviceHandle);
begin
pcap_close(Handle);
end;

function SGPcapNext(const Handle : TSGPcapDeviceHandle; const Handler : TSGPcapHandler; const UserData : TSGPointer = nil) : TSGBoolean;
var
	Data : PChar;
	Header : TSGPcapPacketHeader;
begin
Result := False;
if not DllManager.Suppored('pcap') then
	begin
	SGLog.Source(['Невозможно использовать библиотеку PCAP!']);
	exit;
	end;
Data := pcap_next(Handle, @Header);
Result := Data <> nil;
if Result then
	begin
	if Handler <> nil then
		Handler(UserData, @Header, Data);
	//FreeMem(Data);
	end;
end;

function SGPcapEndlessLoop(const Handle : TSGPcapDeviceHandle; const Handler : TSGPcapHandler; const UserData : TSGPointer = nil) : TSGInt32;
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

function SGPcapInternetAdapterSystemDescriptionFromName(const AdapterName : TSGString) : TSGString;
begin
Result := '';
{$IFDEF MSWINDOWS}
Result := SGInternetAdapterDescriptionFromName(
	SGPcapInternetAdapterSystemName(AdapterName));
{$ENDIF}
end;

function SGPcapInternetAdapterSystemName(const AdapterName : TSGString) : TSGString;
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

function SGPcapInternetAdapterDescriptionFromName(const AdapterName : TSGString) : TSGString;
var
	SystemDescription : TSGString = '';
begin
Result := SGPcapInternetAdapterPcapDescriptionFromName(AdapterName);
SystemDescription := SGPcapInternetAdapterSystemDescriptionFromName(AdapterName);
if Length(Result) < Length(SystemDescription) then
	Result := SystemDescription;
end;

function SGPcapInternetAdapterPcapDescriptionFromName(const AdapterName : TSGString) : TSGString;
var
	Error : TSGPcapErrorString;
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

function SGPcapInternetAdapterNames() : TSGStringList;
var
	Error : TSGPcapErrorString;
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

function SGPcapLogInternetDevices() : TSGMaxEnum;

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
	Error : TSGPcapErrorString;
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

procedure SGPcapTryOpenDevice(const DeviceName : TSGString);
var
	Device : TSGPcapDeviceName = nil;
	IP, Mask : TSGUInt32;
	Handle : TSGPcapDeviceHandle = nil;
begin
Device := SGStringToPChar(DeviceName);
Handle := SGPcapInitializeDevice(Device, @IP, @Mask);
if Handle <> nil then
	pcap_close(Handle);
end;

procedure SGPcapJackOnePacketFromDefaultDevice();
var
	Device : TSGPcapDeviceName = nil;
	IP, Mask : TSGUInt32;
	Handle : TSGPcapDeviceHandle = nil;
begin
Handle := SGPcapInitializeDevice(Device, @IP, @Mask);
if Handle = nil then
	exit;
//SGPcapInitializeDeviceFilter(Handle, 'port 23', IP);
SGPcapJackOnePacket(Handle).Free();
pcap_close(Handle);
end;

procedure TSGPcapPacket.Free();
begin
FreeMem(Data);
ZeroMemory();
end;

procedure TSGPcapPacket.ZeroMemory();
begin
FillChar(Self, SizeOf(TSGPcapPacket), 0);
end;

function SGPcapJackOnePacket(const DeviceHandle : PPcap) : TSGPcapPacket;
begin
Result.ZeroMemory();
Result.Data := PSGByte(pcap_next(DeviceHandle, @Result.Header));
{$IFDEF PCAP_TEST}
SGHint(['Перехвачен пакет с длинной "', Result.Header.Len, '", Packet = "', TSGPointer(Result.Data), '".']);
{$ENDIF}
end;

function SGPcapErrorString(const Error : TSGPcapErrorString; const WithComma : TSGBoolean = False) : TSGString;
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

function SGPcapInitializeDevice(Device : TSGPcapDevice; const P_NET : PSGUInt32 = nil; const P_Mask : PSGUInt32 = nil) : PPcap;
var
	Error : TSGPcapErrorString;
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
		SGHint(['Невозможно найти устройство по-умолчанию!', SGPcapErrorString(Error)]);
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

Description := SGPcapInternetAdapterDescriptionFromName(SGPCharToString(Device));
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
			SGHint(['    NET = ', SGPcapAddressToString(P_NET^)]);
		if (P_Mask <> nil) then
			SGHint(['    Маска = ', SGPcapAddressToString(P_Mask^)]);
		{$ENDIF}
		end;

Result := pcap_open_live(
	Device,               // Имя устройства
	SGPcapMaxBufferSize,  // Максимальное количество байтов, которое будет записано
	pcap_promiscuous_mode,// TRUE - promiscuous mode или default mode
	pcap_default_timeout, // Таймаут
	Error);
if Result = nil then
	begin
	{$IFDEF PCAP_TEST}
	SGHint(['Невозможно открыть устройство "', Description, '"', SGPcapErrorString(Error, True), '!']);
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

function SGPcapTestDeviceNetMask(const AdapterName : TSGString) : TSGBoolean;
var
	Error : TSGPcapErrorString;
	Net, Mask : TSGIPv4Address;
	Device : TSGPcapDevice;
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

function SGPcapInitializeDeviceFilter(const DeviceHandle : PPcap; const FilterString : PSGChar = ''; const IP : TSGUInt32 = 0) : PBPF_Program;
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
