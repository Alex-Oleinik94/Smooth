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
		FPacketInfoFileExtension : TSGString;
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
		procedure DumpPacketDataToFile(const FileName : TSGString; const Data; const DataLength : TSGUInt64);
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
	,SaGeInternetPacketDeterminer
	,SaGeInternetBase
	,SaGeTextFileStream
	
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

procedure TSGInternetPacketDumper.DumpPacketDataToFile(const FileName : TSGString; const Data; const DataLength : TSGUInt64);
var
	Stream : TFileStream = nil;
begin
with TFileStream.Create(FileName, fmCreate) do
	begin
	WriteBuffer(Data, DataLength);
	Destroy();
	end;
end;

procedure TSGInternetPacketDumper.DumpPacketData(const Directory : TSGString; const Packet : TSGInternetPacket);
var
	DateTimeString : TSGString;

procedure ProcessPacket();
var
	FileName : TSGString;
begin
FileName := Directory + DirectorySeparator + DateTimeString + '.' + FPacketDataFileExtension;
FileName := SGFreeFileName(FileName, '');
DumpPacketDataToFile(FileName, Packet.Data.Data^, Packet.Data.Header.CapLen);
end;

procedure ProcessPacketInfo();
var
	FileName : TSGString;
	Stream : TSGTextFileStream = nil;
begin
FileName := Directory + DirectorySeparator + DateTimeString + '.' + FPacketInfoFileExtension;
FileName := SGFreeFileName(FileName, '');
Stream := TSGTextFileStream.Create(FileName);
Stream.WriteLn('[packet]');
Stream.WriteLn(['DataTime="', DateTimeString, '"']);
Stream.WriteLn(['Length=', Packet.Data.Header.Len]);
Stream.WriteLn(['ActualLength=', Packet.Data.Header.CapLen]);
Stream.WriteLn();
if Packet.Data.Header.CapLen = Packet.Data.Header.Len then
	SGWritePacketInfo(Stream, Packet.Data.Data^, Packet.Data.Header.CapLen);
Stream.Destroy();
Stream := nil;
end;

begin
DateTimeString := SGDateTimeCorrectionString(TSGTime.Import(Packet.Data.Header.ts.tv_sec, Packet.Data.Header.ts.tv_usec), True);
ProcessPacket();
ProcessPacketInfo();
end;

procedure TSGInternetPacketDumper.DumpPacket(const Packet : TSGInternetPacket);
var
	Device : PSGInternetPacketDumperDeviceData = nil;
begin
Device := FindDevice(SGPCharToString(Packet.Device^.DeviceName));
if Device = nil then
	Device := AddDevice(Packet.Device^);
Device^.CountPackets += 1;
Device^.CountPacketsSize += Packet.Data.Header.CapLen;

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
SGWriteStringToStream('Net: ' + SGIPv4AddressToString(DeviceData.DeviceNet) + Eoln, Stream);
SGWriteStringToStream('Mask: ' + SGIPv4AddressToString(DeviceData.DeviceMask) + Eoln, Stream);
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
	BreakCircle : TSGBoolean = False;
begin
SGPrintEngineVersion();
WriteLn('InternetPacketDumper: Press ESC to exit');
FPacketListener := TSGInternetPacketListener.Create();
FPacketListener.CallBack := TSGInternetPacketListenerCallBack(@SGPacketDumping_CallBack);
FPacketListener.CallBackData := Self;
if FPacketListener.BeginLoopThreads(True) then
	begin
	FBeginingTime.Get();
	LastInfoTime := FBeginingTime;
	while (not FPacketListener.AllThreadsFinished()) and (not BreakCircle) do
		begin
		if KeyPressed() and (ReadKey = #27) then
			break;
		NowInfoTime.Get();
		if (NowInfoTime - LastInfoTime).GetPastMiliSeconds() > FInfoTimeOut then
			begin
			LastInfoTime := NowInfoTime;
			PrintInformation(NowInfoTime);
			end;
		FPacketListener.DefaultDelay();
		end;
	end;
PrintInformation(SGNow());
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
FPacketInfoFileExtension := 'ini';
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
