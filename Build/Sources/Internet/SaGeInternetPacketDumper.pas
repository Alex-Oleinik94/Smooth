{$INCLUDE SaGe.inc}

unit SaGeInternetPacketDumper;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeDateTime
	,SaGeInternetPacketListener
	;

type
	PSGInternetPacketDumperDeviceData = ^ TSGInternetPacketDumperDeviceData;
	TSGInternetPacketDumperDeviceData = object
			public
		Device : TSGString;
		DeviceDescription : TSGString;
		DeviceDirectory : TSGString;
		CountPackets : TSGUInt64;
		CountPacketsSize : TSGUInt64;
			public
		property DeviceName : TSGString read Device;
		end;
	TSGInternetPacketDumperDevicesData = packed array of TSGInternetPacketDumperDeviceData;
	
	TSGInternetPacketDumper = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FGeneralDirectory : TSGString;
		FDevicesData : TSGInternetPacketDumperDevicesData;
		FPacketDataFileExtension : TSGString;
		FDeviceInfarmationFileExtension : TSGString;
		FPacketListener : TSGInternetPacketListener;
		FInfoTimeOut : TSGUInt64;
		FBeginingTime : TSGDateTime;
			private
		function AllDataSize() : TSGUInt64;
		function FindDeviceDirectory(const DeviceName : TSGString) : TSGString;
		function FindDevice(const DeviceName : TSGString) : PSGInternetPacketDumperDeviceData;
		function AddDevice(const DeviceData : TSGInternetPacketListenerDeviceData) : PSGInternetPacketDumperDeviceData;
		procedure CreateDeviceInformationFile(const DumpDeviceData : TSGInternetPacketDumperDeviceData; const DeviceData : TSGInternetPacketListenerDeviceData);
		procedure PrintInformation(const NowDateTime : TSGDateTime);
		procedure DumpPacketData(const Directory : TSGString; const Packet : TSGInternetPacket);
			public
		procedure Start(); virtual;
		procedure DumpPacket(const Packet : TSGInternetPacket);
		end;

procedure SGInternetPacketDumper();

implementation

uses
	 SaGeFileUtils
	,SaGeStringUtils
	,SaGePcapUtils
	,SaGeVersion
	
	,Crt
	,Classes
	;

procedure SGInternetPacketDumper();
begin
with TSGInternetPacketDumper.Create() do
	begin
	Start();
	Destroy();
	end;
end;

// ============================================
// ======TSGInternetPacketDumper CallBack======
// ============================================

procedure SGPacketDumping_CallBack(Self : TSGInternetPacketDumper; Packet : TSGInternetPacket);
begin
Self.DumpPacket(Packet);
end;

// ===================================
// ======TSGInternetPacketDumper======
// ===================================

function TSGInternetPacketDumper.AllDataSize() : TSGUInt64;
var
	Index : TSGMaxEnum;
begin
Result := 0;
if (FDevicesData <> nil) and (Length(FDevicesData) > 0) then
	for Index := 0 to High(FDevicesData) do
		Result := FDevicesData[Index].CountPacketsSize;
end;

procedure TSGInternetPacketDumper.DumpPacketData(const Directory : TSGString; const Packet : TSGInternetPacket);
var
	Stream : TFileStream = nil;
	FileName : TSGString = '';
begin
FileName := Directory + DirectorySeparator + SGDateTimeString(True) + '.' + FPacketDataFileExtension;
FileName := SGFreeFileName(FileName, '');
Stream := TFileStream.Create(FileName, fmCreate);
Stream.WriteBuffer(Packet.Data.Data^, Packet.Data.Header.Len);
Stream.Destroy();
Stream := nil;
end;

procedure TSGInternetPacketDumper.DumpPacket(const Packet : TSGInternetPacket);
var
	Device : PSGInternetPacketDumperDeviceData = nil;
begin
Device := FindDevice(SGPCharToString(Packet.Device^.DeviceName));
if Device = nil then
	Device := AddDevice(Packet.Device^);
Device^.CountPackets += 1;
Device^.CountPacketsSize += Packet.Data.Header.Len;

DumpPacketData(Device^.DeviceDirectory, Packet);
end;

function TSGInternetPacketDumper.FindDevice(const DeviceName : TSGString) : PSGInternetPacketDumperDeviceData;
var
	Index : TSGMaxEnum;
begin
Result := nil;
if (FDevicesData <> nil) and (Length(FDevicesData) > 0) then
	for Index := 0 to High(FDevicesData) do
		if FDevicesData[Index].Device = DeviceName then
			begin
			Result := @FDevicesData[Index];
			break;
			end;
end;

function TSGInternetPacketDumper.FindDeviceDirectory(const DeviceName : TSGString):TSGString;
var
	DeviceData : PSGInternetPacketDumperDeviceData = nil;
begin
DeviceData := FindDevice(DeviceName);
if DeviceData = nil then
	Result := ''
else
	Result := DeviceData^.DeviceDirectory;
end;

function TSGInternetPacketDumper.AddDevice(const DeviceData : TSGInternetPacketListenerDeviceData) : PSGInternetPacketDumperDeviceData;
begin
if (FDevicesData = nil) or (Length(FDevicesData) = 0) then
	SetLength(FDevicesData, 1)
else
	SetLength(FDevicesData, Length(FDevicesData) + 1);
Result := @FDevicesData[High(FDevicesData)];
Result^.Device := SGPCharToString(DeviceData.DeviceName);
Result^.DeviceDescription := DeviceData.DeviceDescription;
Result^.CountPackets := 0;
Result^.CountPacketsSize := 0;
Result^.DeviceDirectory := FGeneralDirectory + DirectorySeparator + Result^.DeviceDescription;
SGMakeDirectory(Result^.DeviceDirectory);

CreateDeviceInformationFile(FDevicesData[High(FDevicesData)], DeviceData);
end;

procedure TSGInternetPacketDumper.CreateDeviceInformationFile(const DumpDeviceData : TSGInternetPacketDumperDeviceData; const DeviceData : TSGInternetPacketListenerDeviceData);
var
	Stream : TFileStream = nil;
	Eoln : TSGString = SGWinEoln;
begin
Stream := TFileStream.Create(FGeneralDirectory + DirectorySeparator + FDevicesData[High(FDevicesData)].DeviceDescription + '.' + FDeviceInfarmationFileExtension, fmCreate);
SGWriteStringToStream('Name: ' + DumpDeviceData.DeviceName + Eoln, Stream);
SGWriteStringToStream('SystemName: ' + SGPcapInternetAdapterSystemName(DumpDeviceData.DeviceName) + Eoln, Stream);
SGWriteStringToStream('PcapDescription: ' + SGPcapInternetAdapterPcapDescriptionFromName(DumpDeviceData.DeviceName) + Eoln, Stream);
SGWriteStringToStream('SystemDescription: ' + SGPcapInternetAdapterSystemDescriptionFromName(DumpDeviceData.DeviceName) + Eoln, Stream);
SGWriteStringToStream('Net: ' + SGPcapAddressToString(DeviceData.DeviceNet) + Eoln, Stream);
SGWriteStringToStream('Mask: ' + SGPcapAddressToString(DeviceData.DeviceMask) + Eoln, Stream);
Stream.Destroy();
end;

procedure TSGInternetPacketDumper.PrintInformation(const NowDateTime : TSGDateTime);
begin
SGPrintEngineVersion();
TextColor(15);
Write('После ');
TextColor(10);
Write(SGTextTimeBetweenDates(FBeginingTime, NowDateTime, 'ENG'));
TextColor(15);
Write(' всего перехвачено ');
TextColor(12);
Write(SGGetSizeString(AllDataSize(), 'EN'));
TextColor(15);
WriteLn(' данных.');
TextColor(7);
end;

procedure TSGInternetPacketDumper.Start();
var
	LastInfoTime, NowInfoTime : TSGDateTime;
begin
FPacketListener := TSGInternetPacketListener.Create();
FPacketListener.CallBack := TSGInternetPacketListenerCallBack(@SGPacketDumping_CallBack);
FPacketListener.CallBackData := Self;
if FPacketListener.BeginLoopThreads(True) then
	begin
	FBeginingTime.Get();
	LastInfoTime := FBeginingTime;
	while not FPacketListener.AllThreadsFinished() do
		begin
		NowInfoTime.Get();
		if (NowInfoTime - LastInfoTime).GetPastMiliSeconds() > FInfoTimeOut then
			begin
			LastInfoTime := NowInfoTime;
			PrintInformation(NowInfoTime);
			end;
		FPacketListener.DefaultDelay();
		end;
	end;
FPacketListener.Destroy();
FPacketListener := nil;
end;

constructor TSGInternetPacketDumper.Create();
begin
inherited;
FGeneralDirectory := SGAplicationFileDirectory() + DirectorySeparator + SGDateTimeString(True) + ' Packet Dump';
SGMakeDirectory(FGeneralDirectory);
FDevicesData := nil;
FPacketDataFileExtension := 'ipdpd';
FDeviceInfarmationFileExtension := 'txt';
FPacketListener := nil;
FInfoTimeOut := 100;
FillChar(FBeginingTime, SizeOf(FBeginingTime), 0);
end;

destructor TSGInternetPacketDumper.Destroy();
begin
if FPacketListener <> nil then
	begin
	FPacketListener.Destroy();
	FPacketListener := nil;
	end;
if (FDevicesData <> nil) and (Length(FDevicesData) > 0) then
	SetLength(FDevicesData, 0);
inherited;
end;

end.
