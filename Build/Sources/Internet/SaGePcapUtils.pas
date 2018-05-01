{$INCLUDE SaGe.inc}

unit SaGePcapUtils;

interface

uses
	 SaGeBase
	,SaGeClasses
	
	,Pcap
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
procedure SGPCAPLogInternetDevices();

implementation

uses
	 SaGeLog
	,SaGeDllManager
	,SaGeStringUtils
	
	{$IFDEF WINDOWS}
	,Windows
	,JwaIpHlpApi
	,JwaIpTypes
	{$ENDIF}
	;

procedure SGPCAPLogInternetDevices();
var
	Error : TSGPCAPErrorString;
	Devices : PPPcap_If = nil;
	Device : PPcap_If = nil;
	i : TSGMaxEnum;
begin
if not DllManager.Suppored('pcap') then
	begin
	SGHint(['Невозможно использовать библиотеку PCAP!']);
	exit;
	end;

{Devices := GetMem(SizeOf(TSGPointer));
Devices^ := GetMem(SizeOf(Devices^^) * 100);}
if pcap_findalldevs(Devices, Error) = -1 then
	begin
	i := 0;
	SGHint(['All PCAP internet devices=',Devices]);
	Device := Devices^;
	SGHint(['All PCAP internet devices:']);
	while Device <> nil do
		begin
		SGHint(['    Device ',i,':']);
		SGHint(['        Name : ', Device^.Name]);
		SGHint(['        Description : ', Device^.description]);
		SGHint(['        Flags : ', Device^.flags]);
		Device := Device^.Next;
		i += 1;
		end;
	end
else
	SGHint(['PCAP:pcap_findalldevs(..) : Returned error!']);
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
		SGHint(['Устройство по-умолчанию найдено! Device = "', Device, '"']);
	end;

if (P_NET <> nil) or (P_Mask <> nil) then
	if (pcap_lookupnet(Device, P_NET, P_Mask, Error) = -1) then
		begin
		SGHint(['Невозможно узнать маску для устройства "', Device, '"!']);
		if P_NET <> nil then
			P_NET^ := 0;
		if P_Mask <> nil then
			P_Mask^ := 0;
		end
	else
		begin
		if (P_NET <> nil) and (P_Mask <> nil) then
			SGHint(['Данные устройства "', Device, '": NET = ', P_NET^, ', Маска = ', P_Mask^, '.'])
		else if (P_NET <> nil) then
			SGHint(['Данные устройства "', Device, '": NET = ', P_NET^, '.'])
		else if (P_Mask <> nil) then
			SGHint(['Данные устройства "', Device, '": Маска = ', P_Mask^, '.']);
		end;

Result := pcap_open_live(Device, BUFSIZ, 1, 1000, Error);
if Result = nil then
	begin
	SGHint(['Невозможно открыть устройство "', Device, '"', SGPCAPErrorString(Error, True), '!']);
	exit;
	end
else
	SGHint(['Устройство "', Device, '" открыто.']);
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
