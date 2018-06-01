{$INCLUDE SaGe.inc}

unit SaGeInternetConnectionTCP;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeInternetBase
	,SaGeInternetConnection
	,SaGeDateTime
	,SaGeEthernetPacketFrame
	,SaGeTextStream
	,SaGeInternetPacketStorage
	,SaGeCriticalSection
	,SaGeStreamUtils
	,SaGeTransmissionControlProtocolEmulator
	
	,Classes
	;

type
	TSGInternetConnectionTCP = class;
	
	TSGTCPEmulator = class(TSGTransmissionControlProtocolEmulator)
			public
		constructor Create(const _Connection : TSGInternetConnectionTCP);
			protected
		FConnection : TSGInternetConnectionTCP;
			public
		property Connection : TSGInternetConnectionTCP read FConnection write FConnection;
			public
		procedure HandleData(const Data : TStream); override;
		end;
	
	TSGInternetConnectionTCP = class(TSGInternetConnection)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FCritacalSectionTCP : TSGCriticalSection;
		FSourcePort, FDestinationPort : TSGUInt16;
		FSourceAddress, FDestinationAddress : TSGIPv4Address;
		FFinalized : TSGBoolean;
		
		// TCP protocol emulation
		FSenderEmulator : TSGTransmissionControlProtocolEmulator;
		FRecieverEmulator : TSGTransmissionControlProtocolEmulator;
		
		// Data transfer
		FSenderData : TSGMemoryStreamList;
		FRecieverData : TSGMemoryStreamList;
		
		// Data dumper
		FDataDumpsCount : TSGUInt64;
		FDataDumpsSize  : TSGUInt64;
			public
		procedure PrintTextInfo(const TextStream : TSGTextStream; const ForFileSystem : TSGBoolean = False); override;
			protected
		function PacketPushed(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean; override;
		class function PacketComparable(const Packet : TSGEthernetPacketFrame) : TSGBoolean; override;
			protected
		procedure DumpPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame);
		procedure HandlePacket(const Packet : TSGEthernetPacketFrame);
		function InitFirstPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean;
		function InitPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean;
		procedure PushPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame);
		procedure DumpData(const Stream : TStream; const EmulatorString : TSGString);
		procedure PushData(const Stream : TStream; const Emulator : TSGTCPEmulator);
			public
		function HandleData(const Stream : TStream) : TSGConnectionDataType; override;
		function HasData() : TSGBoolean; override;
		function CountData() : TSGMaxEnum; override;
		end;

implementation

uses
	 SaGeInternetConnections
	,SaGeStringUtils
	,SaGeBaseUtils
	,SaGeLog
	,SaGeInternetDumperBase
	
	,StrMan
	;

constructor TSGTCPEmulator.Create(const _Connection : TSGInternetConnectionTCP);
begin
inherited Create();
FConnection := _Connection;
end;

procedure TSGTCPEmulator.HandleData(const Data : TStream);
begin
if FConnection <> nil then
	FConnection.PushData(Data, Self);
end;

procedure TSGInternetConnectionTCP.DumpData(const Stream : TStream; const EmulatorString : TSGString);
var
	FileStream : TFileStream = nil;
begin
FDataDumpsCount += 1;
FDataDumpsSize += Stream.Size;

FileStream := TFileStream.Create(
	FConnectionDataDumpDirectory + DirectorySeparator + StringJustifyRight(SGStr(FDataDumpsCount), 5, '0') + ' (' + EmulatorString + ')' + 
	Iff(PacketDataFileExtension <> '', '.' + SaGeInternetDumperBase.PacketDataFileExtension) , fmCreate);
Stream.Position := 0;
SGCopyPartStreamToStream(Stream, FileStream, Stream.Size);
SGKill(FileStream);
end;

procedure TSGInternetConnectionTCP.PushData(const Stream : TStream; const Emulator : TSGTCPEmulator);
begin
if FModeDataTransfer and (Emulator = FSenderEmulator) then
	FSenderData += SGStreamCopyMemory(Stream);
if FModeDataTransfer and (Emulator = FRecieverEmulator) then
	FRecieverData += SGStreamCopyMemory(Stream);
if FModeRuntimeDataDumper then
	DumpData(Stream, 
		Iff(Emulator = FSenderEmulator, 'Sender') + 
		Iff(Emulator = FRecieverEmulator, 'Reciever'));
end;

procedure TSGInternetConnectionTCP.HandlePacket(const Packet : TSGEthernetPacketFrame);
begin
FCritacalSectionTCP.Enter();
if AddressMatchesNetMask(Packet.IPv4^.Destination) then
	begin
	FRecieverEmulator.HandleData(Packet.TCPIP^, Packet.Data);
	FSenderEmulator.HandleAcknowledgement(Packet.TCPIP^.AcknowledgementNumber);
	end;
if AddressMatchesNetMask(Packet.IPv4^.Source) then
	begin
	FSenderEmulator.HandleData(Packet.TCPIP^, Packet.Data);
	FRecieverEmulator.HandleAcknowledgement(Packet.TCPIP^.AcknowledgementNumber);
	end;
if ((FSenderEmulator <> nil) and FSenderEmulator.Finalized) or
   ((FRecieverEmulator <> nil) and FRecieverEmulator.Finalized) then
	FFinalized := True;
FCritacalSectionTCP.Leave();
end;

procedure TSGInternetConnectionTCP.DumpPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame);
var
	DateTimeString : TSGString;
	FileName : TSGString;
	Description : TSGString;
	FileNameInfo : TSGString;
	FileNameData : TSGString;
begin
DateTimeString := SGDateTimeCorrectionString(Date, Time, True);
FileName := FConnectionPacketDumpDirectory + DirectorySeparator + DateTimeString + ' {' + SGStr(FPacketCount) + '}';
Description := Packet.Description;
if Description <> '' then
	FileName += ' (' + Description + ')';
FileNameInfo := FileName + Iff(FPacketInfoFileExtension <> '', '.' + FPacketInfoFileExtension, '');
FileNameData := FileName + Iff(FPacketDataFileExtension <> '', '.' + FPacketDataFileExtension, '');

DumpPacketFiles(Time, Date, Packet, FileNameInfo, FileNameData);
end;

procedure TSGInternetConnectionTCP.PrintTextInfo(const TextStream : TSGTextStream; const ForFileSystem : TSGBoolean = False);
const
	ColorPort = 11;
	ColorSize = 6;
	ColorBigSize = 14;
	ColorAddressNumber = 13;
	ColorAddressPoint = 15;
	ColorText = 7;
	ColorActiveProtocol = 10;
	ColorActive5secProtocol = 2;
	ColorFinalizedProtocol = 4; {12}
begin
if (FRecieverEmulator <> nil) and (not FRecieverEmulator.Finalized) then
	if (SGNow() - FDateLastPacket).GetPastMiliSeconds() > 100 * FSecondsMeansConnectionActive then
		TextStream.TextColor(ColorActive5secProtocol)
	else
		TextStream.TextColor(ColorActiveProtocol)
else
	TextStream.TextColor(ColorFinalizedProtocol);
TextStream.Write('TCP ');

if FDeviceIPv4Supported then
	begin
	TextStream.TextColor(ColorText);
	TextStream.Write('Port' + Iff(ForFileSystem, '=', ':'));
	TextStream.TextColor(ColorPort);
	TextStream.Write(StringJustifyRight(SGStr(FSourcePort), 5, ' '));
	
	TextStream.TextColor(ColorText);
	TextStream.Write(';Address' + Iff(ForFileSystem, '=', ':'));
	SGIPv4AddressView(FDestinationAddress, TextStream, ColorAddressNumber, ColorAddressPoint);
	
	TextStream.TextColor(ColorText);
	TextStream.Write(';DPort' + Iff(ForFileSystem, '=', ':'));
	TextStream.TextColor(ColorPort);
	TextStream.Write(StringJustifyRight(SGStr(FDestinationPort), 5, ' '));
	end
else
	begin
	TextStream.TextColor(ColorText);
	TextStream.Write('sa' + Iff(ForFileSystem, '=', ':'));
	SGIPv4AddressView(FSourceAddress, TextStream, ColorAddressNumber, ColorAddressPoint);
	
	TextStream.TextColor(ColorText);
	TextStream.Write('sp' + Iff(ForFileSystem, '=', ':'));
	TextStream.TextColor(ColorPort);
	TextStream.Write(StringJustifyRight(SGStr(FSourcePort), 5, ' '));
	
	TextStream.TextColor(ColorText);
	TextStream.Write('da' + Iff(ForFileSystem, '=', ':'));
	SGIPv4AddressView(FDestinationAddress, TextStream, ColorAddressNumber, ColorAddressPoint);
	
	TextStream.TextColor(ColorText);
	TextStream.Write('dp' + Iff(ForFileSystem, '=', ':'));
	TextStream.TextColor(ColorPort);
	TextStream.Write(StringJustifyRight(SGStr(FDestinationPort), 5, ' '));
	end;
if not ForFileSystem then
	begin
	TextStream.TextColor(ColorText);
	TextStream.Write(';Size' + Iff(ForFileSystem, '=', ':'));
	if FDataSize > 1024 * 400 then
		TextStream.TextColor(ColorBigSize)
	else
		TextStream.TextColor(ColorSize);
	TextStream.Write(SGGetSizeString(FDataSize, 'EN'));
	end;

TextStream.TextColor(7);
end;

class function TSGInternetConnectionTCP.PacketComparable(const Packet : TSGEthernetPacketFrame) : TSGBoolean;
begin
Result := (Packet.TCPIP <> nil) and (Packet.IPv4 <> nil);
end;

function TSGInternetConnectionTCP.InitFirstPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean;
begin
Result := True;

FSourcePort := Packet.TCPIP^.SourcePort;
FDestinationPort := Packet.TCPIP^.DestinationPort;
FSourceAddress := Packet.IPv4^.Source;
FDestinationAddress := Packet.IPv4^.Destination;
FFirstPacketIsSelfSender := not AddressMatchesNetMask(FDestinationAddress);

if FDeviceIPv4Supported and (not FFirstPacketIsSelfSender) then
	begin
	Swap(FSourcePort, FDestinationPort);
	Swap(FSourceAddress, FDestinationAddress);
	end;

FTimeFirstPacket := Time;
FDateFirstPacket := Date;

if FModeRuntimeDataDumper or FModeRuntimePacketDumper then
	CreateConnectionDumpDirectory();
if FModePacketStorage then
	begin
	SGKill(FPacketStorage);
	FPacketStorage := TSGInternetPacketStorage.Create();
	end;
if FModeDataTransfer or FModeRuntimeDataDumper then
	begin
	FSenderEmulator := TSGTCPEmulator.Create(Self);
	FRecieverEmulator := TSGTCPEmulator.Create(Self);
	end;
end;

function TSGInternetConnectionTCP.InitPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean;
begin
Result := 
	((
	  ((Packet.TCPIP^.SourcePort = FSourcePort) and
	  (Packet.IPv4^.Source = FSourceAddress))
	  and
	  ((Packet.TCPIP^.DestinationPort = FDestinationPort) and
	  (Packet.IPv4^.Destination = FDestinationAddress))
	) or (
	  ((Packet.TCPIP^.SourcePort = FDestinationPort) and
	  (Packet.IPv4^.Source = FDestinationAddress))
	  and
	  ((Packet.TCPIP^.DestinationPort = FSourcePort) and
	  (Packet.IPv4^.Destination = FSourceAddress))
	));
end;

procedure TSGInternetConnectionTCP.PushPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame);
begin
FTimeLastPacket := Time;
FDateLastPacket := Date;

FDataSize += Packet.Size;
FPacketCount += 1;

if FModeDataTransfer or FModeRuntimeDataDumper then
	HandlePacket(Packet);
if FModeRuntimePacketDumper then
	DumpPacket(Time, Date, Packet);
if FModePacketStorage then
	FPacketStorage.Add(Time, Date, Packet);

if not FModePacketStorage then
	Packet.Destroy();
end;

function TSGInternetConnectionTCP.PacketPushed(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean;
begin
Result := False;
FCritacalSection.Enter();
if (not FFinalized) and (FPacketCount = 0) and PacketComparable(Packet) then
	Result := InitFirstPacket(Time, Date, Packet)
else if (not FFinalized) and (FPacketCount > 0) and PacketComparable(Packet) then
	Result := InitPacket(Time, Date, Packet);
if Result then
	PushPacket(Time, Date, Packet);
FCritacalSection.Leave();
end;

constructor TSGInternetConnectionTCP.Create();
begin
inherited;
FSourceAddress := 0;
FSourcePort := 0;
FDestinationAddress := 0;
FDestinationPort := 0;
FFinalized := False;
FCritacalSectionTCP := TSGCriticalSection.Create();
FDataDumpsCount := 0;
FDataDumpsSize := 0;
FSenderEmulator := nil;
FRecieverEmulator := nil;
FRecieverData := nil;
FSenderData := nil;
end;

destructor TSGInternetConnectionTCP.Destroy();
begin
SGKill(FSenderEmulator);
SGKill(FRecieverEmulator);
SGKill(FCritacalSectionTCP);
inherited;
end;

function TSGInternetConnectionTCP.HandleData(const Stream : TStream) : TSGConnectionDataType;
var
	MemStream : TMemoryStream = nil;
begin
Result := SGNoData;
if (FSenderData <> nil) and (Length(FSenderData) > 0) then
	begin
	Result := SGSenderData;
	MemStream := FSenderData[0];
	FSenderData -= MemStream;
	end;
if (MemStream = nil) and (FRecieverData <> nil) and (Length(FRecieverData) > 0) then
	begin
	Result := SGRecieverData;
	MemStream := FRecieverData[0];
	FRecieverData -= MemStream;
	end;
if (MemStream <> nil) then
	begin
	MemStream.Position := 0;
	SGCopyPartStreamToStream(MemStream, Stream, MemStream.Size);
	SGKill(MemStream);
	end;
end;

function TSGInternetConnectionTCP.HasData() : TSGBoolean;
begin
Result := CountData() > 0;
end;

function TSGInternetConnectionTCP.CountData() : TSGMaxEnum;
begin
Result := 0;
if (FSenderData <> nil) then
	Result += Length(FSenderData);
if (FRecieverData <> nil) then
	Result += Length(FRecieverData);
end;

initialization
begin
SGRegisterInternetConnectionClass(TSGInternetConnectionTCP);
end;

end.
