{$INCLUDE SaGe.inc}

unit SaGeInternetPacketDumper;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeInternetPacketListener
	;

type
	TSGInternetPacketDumperDeviceData = object
			public
		Device : TSGString;
		DeviceDescription : TSGString;
		DeviceDerictory : TSGString;
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
			private
		function FindDeviceDirectory(const DeviceName : TSGString):TSGString;
		procedure AddDevice(const DeviceData : TSGInternetPacketListenerDeviceData);
		procedure CreateDeviceInformationFile(const DumpDeviceData : TSGInternetPacketDumperDeviceData; const DeviceData : TSGInternetPacketListenerDeviceData);
			public
		procedure Start(); virtual;
		procedure DumpPacket(const Packet : TSGInternetPacket);
		end;

procedure SGInternetPacketDumper();

implementation

uses
	 SaGeFileUtils
	,SaGeDateTime
	,SaGeStringUtils
	,SaGePcapUtils
	
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

procedure TSGInternetPacketDumper.DumpPacket(const Packet : TSGInternetPacket);
var
	DeviceDirectory : TSGString = '';
	Stream : TFileStream = nil;
begin
DeviceDirectory := FindDeviceDirectory(SGPCharToString(Packet.Device^.DeviceName));
if DeviceDirectory = '' then
	begin
	AddDevice(Packet.Device^);
	DeviceDirectory := FindDeviceDirectory(SGPCharToString(Packet.Device^.DeviceName));
	end;

Stream := TFileStream.Create(DeviceDirectory + DirectorySeparator + SGDateTimeString(True) + '.' + FPacketDataFileExtension, fmCreate);
Stream.WriteBuffer(Packet.Data.Data^, Packet.Data.Header.Len);
Stream.Destroy();
end;

function TSGInternetPacketDumper.FindDeviceDirectory(const DeviceName : TSGString):TSGString;
var
	Index : TSGMaxEnum;
begin
Result := '';
if (FDevicesData = nil) or (Length(FDevicesData) = 0) then
	exit;

for Index := 0 to High(FDevicesData) do
	if FDevicesData[Index].Device = DeviceName then
		begin
		Result := FDevicesData[Index].DeviceDerictory;
		break;
		end;
end;

procedure TSGInternetPacketDumper.AddDevice(const DeviceData : TSGInternetPacketListenerDeviceData);
begin
if (FDevicesData = nil) or (Length(FDevicesData) = 0) then
	SetLength(FDevicesData, 1)
else
	SetLength(FDevicesData, Length(FDevicesData) + 1);
FDevicesData[High(FDevicesData)].Device := SGPCharToString(DeviceData.DeviceName);
FDevicesData[High(FDevicesData)].DeviceDescription := DeviceData.DeviceDescription;
FDevicesData[High(FDevicesData)].CountPackets := 0;
FDevicesData[High(FDevicesData)].CountPacketsSize := 0;
FDevicesData[High(FDevicesData)].DeviceDerictory := FGeneralDirectory + DirectorySeparator + FDevicesData[High(FDevicesData)].DeviceDescription;
SGMakeDirectory(FDevicesData[High(FDevicesData)].DeviceDerictory);

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

procedure TSGInternetPacketDumper.Start();
begin
SGInternetPacketListener(
	TSGInternetPacketListenerCallBack(@SGPacketDumping_CallBack),
	Self);
end;

constructor TSGInternetPacketDumper.Create();
begin
inherited;
FGeneralDirectory := SGAplicationFileDirectory() + DirectorySeparator + SGDateTimeString(True) + ' Packet Dump';
SGMakeDirectory(FGeneralDirectory);
FDevicesData := nil;
FPacketDataFileExtension := 'hexdata';
FDeviceInfarmationFileExtension := 'txt';
end;

destructor TSGInternetPacketDumper.Destroy();
begin
inherited;
end;

end.
