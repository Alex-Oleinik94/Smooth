{$INCLUDE Smooth.inc}
//{$DEFINE PCAP_HINT_TEST}

unit SmoothPCapUtils;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothBaseClasses
	,SmoothInternetBase
	
	,Sockets
	,Classes
	
	,Pcap
	;

// PCap extensions
type
	TPcap_PacketHeader = TPcap_Pkthdr;
	PPcap_PacketHeader = PPcap_Pkthdr;
const
	pcap_default_timeout  = 0;
	pcap_promiscuous_mode = $0001;
	pcap_default_mode     = $0000;

// PCap
type
	TSPcapString = PSChar;
const
	SPcapMaxBufferSize = 2000000000; //8192
type
	TSPcapDevice = TSPcapString;
	TSPcapDeviceName = TSPcapString;
	
	TSPcapErrorString = array[0..PCAP_ERRBUF_SIZE-1] of TSChar;
	TSPcapDeviceHandle = PPcap;
	TSPcapDeviceFilter = PBPF_Program;
	TSPcapCallBack = TPcapHandler;
	PSPcapPacketHeader = PPcap_PacketHeader;
	TSPcapPacketHeader = TPcap_PacketHeader;
	
	TSPcapIPv4Address = TSIPv4Address;
	TSPcapIPv4Mask = TSIPv4Address;
	TSPcapIPv4Net = TSIPv4Address;
	TSPcapHandler = TSPcapCallBack;
	
	TSPcapPacket = object
			public
		Header : TPcap_PacketHeader;
		Data : PSByte;
			public
		function CreateStream() : TMemoryStream;
		procedure Free();
		procedure ZeroMemory();
		end;
	
function SPcapInitializeDevice(Device : TSPcapDevice; const P_NET : PSUInt32 = nil; const P_Mask : PSUInt32 = nil) : TSPcapDeviceHandle;
function SPcapInitializeDeviceFilter(const DeviceHandle : TSPcapDeviceHandle; const FilterString : PSChar = ''; const IP : TSUInt32 = 0) : TSPcapDeviceFilter;
function SPcapErrorString(const Error : TSPcapErrorString; const WithComma : TSBoolean = False) : TSString;
function SPcapJackOnePacket(const DeviceHandle : TSPcapDeviceHandle) : TSPcapPacket;
procedure SPcapJackOnePacketFromDefaultDevice();
procedure SPcapTryOpenDevice(const DeviceName : TSString);
function SPcapLogInternetDevices() : TSMaxEnum;
function SPcapInternetAdapterNames() : TSStringList;
function SPcapInternetAdapterDescriptionFromName(const AdapterName : TSString) : TSString;
function SPcapInternetAdapterPcapDescriptionFromName(const AdapterName : TSString) : TSString;
function SPcapInternetAdapterSystemDescriptionFromName(const AdapterName : TSString) : TSString;
function SPcapInternetAdapterSystemName(const AdapterName : TSString) : TSString;
function SPcapTestDeviceNetMask(const AdapterName : TSString) : TSBoolean;
function SPcapEndlessLoop(const Handle : TSPcapDeviceHandle; const Handler : TSPcapHandler; const UserData : TSPointer = nil) : TSInt32;
procedure SPcapClose(const Handle : TSPcapDeviceHandle);
function SPcapNext(const Handle : TSPcapDeviceHandle; const Handler : TSPcapHandler; const UserData : TSPointer = nil) : TSBoolean;

implementation

uses
	 SmoothLog
	,SmoothDllManager
	,SmoothStringUtils
	{$IFDEF MSWINDOWS}
		,SmoothWinAPIUtils
		{$ENDIF}
	;


function TSPcapPacket.CreateStream() : TMemoryStream;
begin
Result := TMemoryStream.Create();
Result.WriteBuffer(Data^, Header.CapLen);
Result.Position := 0;
end;

procedure SPcapClose(const Handle : TSPcapDeviceHandle);
begin
pcap_close(Handle);
end;

function SPcapNext(const Handle : TSPcapDeviceHandle; const Handler : TSPcapHandler; const UserData : TSPointer = nil) : TSBoolean;
var
	Data : PChar;
	Header : TSPcapPacketHeader;
begin
Result := False;
if not DllManager.Supported('pcap') then
	begin
	SLog.Source(['Невозможно использовать библиотеку PCAP!']);
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

function SPcapEndlessLoop(const Handle : TSPcapDeviceHandle; const Handler : TSPcapHandler; const UserData : TSPointer = nil) : TSInt32;
begin
Result := 0;
if not DllManager.Supported('pcap') then
	begin
	SLog.Source(['Невозможно использовать библиотеку PCAP!']);
	exit;
	end;
Result := pcap_loop ( // Возвращает количество считаных пакетов, -1 если ошибка
	Handle,    // Устройство
	-1,        // Количество пакетов, прослушаных до возврата функции
	Handler,   // Функция обратного вызова
	UserData); // Пользовательские данные
end;

function SPcapInternetAdapterSystemDescriptionFromName(const AdapterName : TSString) : TSString;
begin
Result := '';
{$IFDEF MSWINDOWS}
Result := SInternetAdapterDescriptionFromName(
	SPcapInternetAdapterSystemName(AdapterName));
{$ENDIF}
end;

function SPcapInternetAdapterSystemName(const AdapterName : TSString) : TSString;
{$IFDEF MSWINDOWS}
const
	WindowsStringBegin = '\Device\NPF_';
{$ENDIF}
begin
Result := AdapterName;
{$IFDEF MSWINDOWS}
if SExistsFirstPartString(AdapterName, WindowsStringBegin) and 
	(Length(WindowsStringBegin) + 1 <= Length(AdapterName)) then
	Result := SStringGetPart(AdapterName, Length(WindowsStringBegin) + 1, Length(AdapterName));
{$ENDIF}
end;

function SPcapInternetAdapterDescriptionFromName(const AdapterName : TSString) : TSString;
var
	SystemDescription : TSString = '';
begin
Result := SPcapInternetAdapterPcapDescriptionFromName(AdapterName);
SystemDescription := SPcapInternetAdapterSystemDescriptionFromName(AdapterName);
if Length(Result) < Length(SystemDescription) then
	Result := SystemDescription;
end;

function SPcapInternetAdapterPcapDescriptionFromName(const AdapterName : TSString) : TSString;
var
	Error : TSPcapErrorString;
	Device : PPcap_If = nil;
	FirstDevice : PPcap_If = nil;
	ReturnedValue : TSInt32 = 0;
	Index : TSMaxEnum = 0;
begin
Result := '';
if AdapterName <> '' then
	begin
	if not DllManager.Supported('pcap') then
		begin
		SLog.Source(['Невозможно использовать библиотеку PCAP!']);
		exit;
		end;
	if pcap_findalldevs = nil then
		begin
		SLog.Source(['Невозможно использовать функцию PCAP.pcap_findalldevs(..)!']);
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
		SLog.Source(['PCAP:pcap_findalldevs(..) : Returned value "', ReturnedValue, '", error: "', Error, '".']);
	end;
end;

function SPcapInternetAdapterNames() : TSStringList;
var
	Error : TSPcapErrorString;
	Device : PPcap_If = nil;
	FirstDevice : PPcap_If = nil;
	ReturnedValue : TSInt32 = 0;
	Index : TSMaxEnum = 0;
begin
Result := nil;
if not DllManager.Supported('pcap') then
	begin
	SLog.Source(['Невозможно использовать библиотеку PCAP!']);
	exit;
	end;
if pcap_findalldevs = nil then
	begin
	SLog.Source(['Невозможно использовать функцию PCAP.pcap_findalldevs(..)!']);
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
	SLog.Source(['PCAP:pcap_findalldevs(..) : Returned value "', ReturnedValue, '", error: "', Error, '".']);
end;

function SPcapLogInternetDevices() : TSMaxEnum;

function LogAddresses(const Addresses : PPcap_Addr = nil) : TSMaxEnum;

procedure LogSocketAddress(const Name : TSString; const SocketAddress :  PSockAddr);
type
	TDataList14 = array [0..13] of TSUInt8;

function DataToString(const Data : TDataList14) : TSString;
var
	Index : TSMaxEnum;
begin
Result := '';
for Index := 0 to 13 do
	begin
	Result += SStr(Data[Index]);
	if Index <> 13 then
		Result += ' ';
	end;
end;

begin
if SocketAddress = nil then
	SLog.Source(['            ', Name, ' : nil'])
else
	begin
	SLog.Source(['            ', Name, ' : ']);
	SLog.Source(['                Address family : ', SocketAddress^.sa_family]);
	SLog.Source(['                Addres data    : ', DataToString(SocketAddress^.sa_data)]);
	end;
end;

var
	Address : PPcap_Addr = nil;
begin
Result := 0;
if Addresses = nil then
	begin
	SLog.Source(['        Addresses : nil']);
	end
else
	begin
	Address := Addresses;
	while Address <> nil do
		begin
		SLog.Source(['        Address ', Result, ':']);
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
	Error : TSPcapErrorString;
	Device : PPcap_If = nil;
	FirstDevice : PPcap_If = nil;
	ReturnedValue : TSInt32 = 0;
begin
Result := 0;
if not DllManager.Supported('pcap') then
	begin
	SLog.Source(['Невозможно использовать библиотеку PCAP!']);
	exit;
	end;
if pcap_findalldevs = nil then
	begin
	SLog.Source(['Невозможно использовать функцию PCAP.pcap_findalldevs(..)!']);
	exit;
	end;
Error := '';

ReturnedValue := pcap_findalldevs(@Device, Error);
if ReturnedValue <> -1 then
	begin
	SLog.Source(['All PCAP internet devices:']);
	FirstDevice := Device;
	while Device <> nil do
		begin
		SLog.Source(['    Device ', Result, ':']);
		SLog.Source(['        Name : ', Device^.Name]);
		SLog.Source(['        Description : ', Device^.description]);
		SLog.Source(['        Flags : ', Device^.flags]);
		LogAddresses(Device^.addresses);
		
		Device := Device^.Next;
		Result += 1;
		end;
	{if FirstDevice <> nil then
		FreeMem(FirstDevice);}
	end
else
	SLog.Source(['PCAP:pcap_findalldevs(..) : Returned value "', ReturnedValue, '", error: "', Error, '".']);
end;

procedure SPcapTryOpenDevice(const DeviceName : TSString);
var
	Device : TSPcapDeviceName = nil;
	IP, Mask : TSUInt32;
	Handle : TSPcapDeviceHandle = nil;
begin
Device := SStringToPChar(DeviceName);
Handle := SPcapInitializeDevice(Device, @IP, @Mask);
if Handle <> nil then
	pcap_close(Handle);
end;

procedure SPcapJackOnePacketFromDefaultDevice();
var
	Device : TSPcapDeviceName = nil;
	IP, Mask : TSUInt32;
	Handle : TSPcapDeviceHandle = nil;
begin
Handle := SPcapInitializeDevice(Device, @IP, @Mask);
if Handle = nil then
	exit;
//SPcapInitializeDeviceFilter(Handle, 'port 23', IP);
SPcapJackOnePacket(Handle).Free();
pcap_close(Handle);
end;

procedure TSPcapPacket.Free();
begin
FreeMem(Data);
ZeroMemory();
end;

procedure TSPcapPacket.ZeroMemory();
begin
FillChar(Self, SizeOf(TSPcapPacket), 0);
end;

function SPcapJackOnePacket(const DeviceHandle : PPcap) : TSPcapPacket;
begin
Result.ZeroMemory();
Result.Data := PSByte(pcap_next(DeviceHandle, @Result.Header));
{$IFDEF PCAP_TEST}
SHint(['Перехвачен пакет с длинной "', Result.Header.Len, '", Packet = "', TSPointer(Result.Data), '".']);
{$ENDIF}
end;

function SPcapErrorString(const Error : TSPcapErrorString; const WithComma : TSBoolean = False) : TSString;
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

function SPcapInitializeDevice(Device : TSPcapDevice; const P_NET : PSUInt32 = nil; const P_Mask : PSUInt32 = nil) : PPcap;
var
	Error : TSPcapErrorString;
	Description : TSString;
begin
FillChar(Result, SizeOf(Result), 0);

if not DllManager.Supported('pcap') then
	begin
	{$IFDEF PCAP_TEST}
	SHint(['Невозможно использовать библиотеку PCAP!']);
	{$ENDIF}
	exit;
	end;

if Device = nil then
	begin
	Device := pcap_lookupdev(@Error);
	if Device = nil then
		begin
		{$IFDEF PCAP_TEST}
		SHint(['Невозможно найти устройство по-умолчанию!', SPcapErrorString(Error)]);
		{$ENDIF}
		exit;
		end
	else
		begin
		{$IFDEF PCAP_TEST}
		SHint(['Устройство по-умолчанию найдено! DeviceName = "', Device, '"']);
		{$ENDIF}
		end;
	end;

Description := SPcapInternetAdapterDescriptionFromName(SPCharToString(Device));
if Description = '' then
	Description := SPCharToString(Device);

if (P_NET <> nil) or (P_Mask <> nil) then
	if (pcap_lookupnet(Device, P_NET, P_Mask, Error) = -1) then
		begin
		{$IFDEF PCAP_TEST}
		SHint(['Невозможно узнать маску для устройства "', Description, '"!']);
		if P_NET <> nil then
			P_NET^ := 0;
		if P_Mask <> nil then
			P_Mask^ := 0;
		{$ENDIF}
		end
	else
		begin
		{$IFDEF PCAP_TEST}
		SHint(['Данные устройства "', Description, '":']);
		if (P_NET <> nil) then
			SHint(['    NET = ', SPcapAddressToString(P_NET^)]);
		if (P_Mask <> nil) then
			SHint(['    Маска = ', SPcapAddressToString(P_Mask^)]);
		{$ENDIF}
		end;

Result := pcap_open_live(
	Device,               // Имя устройства
	SPcapMaxBufferSize,  // Максимальное количество байтов, которое будет записано
	pcap_promiscuous_mode,// TRUE - promiscuous mode или default mode
	pcap_default_timeout, // Таймаут
	Error);
if Result = nil then
	begin
	{$IFDEF PCAP_TEST}
	SHint(['Невозможно открыть устройство "', Description, '"', SPcapErrorString(Error, True), '!']);
	{$ENDIF}
	exit;
	end
else
	begin
	{$IFDEF PCAP_TEST}
	SHint(['Устройство "', Description, '" открыто.']);
	{$ENDIF}
	end;
end;

function SPcapTestDeviceNetMask(const AdapterName : TSString) : TSBoolean;
var
	Error : TSPcapErrorString;
	Net, Mask : TSIPv4Address;
	Device : TSPcapDevice;
begin
Result := False;
if not DllManager.Supported('pcap') then
	begin
	{$IFDEF PCAP_TEST}
	SHint(['Невозможно использовать библиотеку PCAP!']);
	{$ENDIF}
	exit;
	end;
if pcap_lookupnet = nil then
	begin
	{$IFDEF PCAP_TEST}
	SHint(['Невозможно использовать функцию PCAP.pcap_lookupnet(..)!']);
	{$ENDIF}
	exit;
	end;

Device := SStringToPChar(AdapterName);
if (pcap_lookupnet(Device, @Net, @Mask, Error) <> -1) then
	Result := (Net <> 0) and (Mask <> 0)
else
	begin
	{$IFDEF PCAP_TEST}
	SHint(['PCAP.pcap_lookupnet(..) : Error "', Error, '"!']);
	{$ENDIF}
	end;
FreeMem(Device);
end;

function SPcapInitializeDeviceFilter(const DeviceHandle : PPcap; const FilterString : PSChar = ''; const IP : TSUInt32 = 0) : PBPF_Program;
begin
if DeviceHandle = nil then
	Exit;

if (pcap_compile(DeviceHandle, @Result, FilterString, 0, IP) = -1) then
	begin
	{$IFDEF PCAP_TEST}
	SHint(['Couldn''t parse filter "', FilterString, '", Error: "', pcap_geterr(DeviceHandle), '"!']);
	{$ENDIF}
	exit;
	end;
if (pcap_setfilter(DeviceHandle, @Result) = -1) then
	begin
	{$IFDEF PCAP_TEST}
	SHint(['Couldn''t install filter "', FilterString, '", Error: "', pcap_geterr(DeviceHandle), '"!']);
	{$ENDIF}
	exit;
	end;
end;

end.
