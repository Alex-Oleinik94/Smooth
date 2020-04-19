{$INCLUDE Smooth.inc}

unit SmoothInternetConnectionTCPIPv4;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothInternetBase
	,SmoothInternetConnection
	,SmoothDateTime
	,SmoothEthernetPacketFrame
	,SmoothTextStream
	,SmoothInternetPacketStorage
	,SmoothCriticalSection
	,SmoothStreamUtils
	,SmoothEmulatorTCP
	
	,Classes
	;

type
	TSInternetConnectionTCPIPv4 = class;
	
	TSEmulatorTCP = class(TSEmulatorTransmissionControlProtocol)
			public
		constructor Create(const _Connection : TSInternetConnectionTCPIPv4);
			protected
		FConnection : TSInternetConnectionTCPIPv4;
			public
		property Connection : TSInternetConnectionTCPIPv4 read FConnection write FConnection;
			public
		procedure HandleData(const Data : TStream); override;
		end;
	
	TSInternetConnectionTCPIPv4 = class(TSInternetConnection)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FCritacalSectionTCP : TSCriticalSection;
		FSourcePort, FDestinationPort : TSUInt16;
		FSourceAddress, FDestinationAddress : TSIPv4Address;
		FSenderFinalized : TSBoolean;
		FRecieverFinalized : TSBoolean;
		
		// TCP protocol emulation
		FSenderEmulator : TSEmulatorTransmissionControlProtocol;
		FRecieverEmulator : TSEmulatorTransmissionControlProtocol;
		
		// Data dumper
		FDataDumpsCount : TSUInt64;
		FDataDumpsSize  : TSUInt64;
		FSenderDataStreamFile, FRecieverDataStreamFile : TSString;
		FSenderDataStream, FRecieverDataStream : TFileStream;
			public
		class function ProtocolAbbreviation(const FileSystemSuport : TSBoolean = False) : TSString; override;
		procedure PrintTextInfo(const TextStream : TSTextStream; const FileSystemSuport : TSBoolean = False); override;
			protected
		procedure KillEmulators();
		function PacketPushed(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame) : TSBoolean; override;
		class function PacketCompatible(const Packet : TSEthernetPacketFrame) : TSBoolean; override;
		function Finalized() : TSBoolean; override;
			protected
		procedure DumpPacket(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame);
		procedure HandlePacket(const Packet : TSEthernetPacketFrame);
		function InitFirstPacket(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame) : TSBoolean;
		function InitPacket(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame) : TSBoolean;
		procedure PushPacket(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame);
		procedure UpDateStatistic(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame);
		procedure DumpData(const Stream : TStream; const EmulatorString : TSString);
		procedure PushData(const Stream : TStream; const Emulator : TSEmulatorTCP);
		procedure CreateBlockStreams();
		end;

implementation

uses
	 SmoothInternetConnectionsCaptor
	,SmoothStringUtils
	,SmoothBaseUtils
	,SmoothLog
	,SmoothInternetDumperBase
	//,SmoothTextFileStream
	
	,StrMan
	;

constructor TSEmulatorTCP.Create(const _Connection : TSInternetConnectionTCPIPv4);
begin
inherited Create();
FConnection := _Connection;
end;

procedure TSEmulatorTCP.HandleData(const Data : TStream);
begin
if FConnection <> nil then
	FConnection.PushData(Data, Self);
end;

procedure TSInternetConnectionTCPIPv4.DumpData(const Stream : TStream; const EmulatorString : TSString);
var
	FileStream : TFileStream = nil;
begin
FDataDumpsCount += 1;
FDataDumpsSize += Stream.Size;

FileStream := TFileStream.Create(
	FConnectionDataDumpDirectory + DirectorySeparator + StringJustifyRight(SStr(FDataDumpsCount), 5, '0') + ' (' + EmulatorString + ')' + 
	Iff(PacketDataFileExtension <> '', '.' + SmoothInternetDumperBase.PacketDataFileExtension) , fmCreate);
Stream.Position := 0;
SCopyPartStreamToStream(Stream, FileStream, Stream.Size);
SKill(FileStream);
end;

procedure TSInternetConnectionTCPIPv4.PushData(const Stream : TStream; const Emulator : TSEmulatorTCP);
var
	DataType : TSConnectionDataType = SNoData;
begin
if FModeDataTransfer and (FConnectionsHandler <> nil) then
	begin
	if Emulator = FSenderEmulator then
		DataType := SSenderData
	else if Emulator = FRecieverEmulator then
		DataType := SRecieverData;
	if not FConnectionsHandler.HandleConnectionData(Self, DataType, Stream) then
		MakeFictitious();
	end;
if FModeRuntimeDataDumper then
	begin
	DumpData(Stream, 
		Iff(Emulator = FSenderEmulator, 'Sender') + 
		Iff(Emulator = FRecieverEmulator, 'Reciever'));
	
	Stream.Position := 0;
	if Emulator = FSenderEmulator then
		SCopyPartStreamToStream(Stream, FSenderDataStream, Stream.Size)
	else if Emulator = FRecieverEmulator then
		SCopyPartStreamToStream(Stream, FRecieverDataStream, Stream.Size);
	end;
end;

procedure TSInternetConnectionTCPIPv4.HandlePacket(const Packet : TSEthernetPacketFrame);
begin
FCritacalSectionTCP.Enter();
if AddressCorrespondsToNetMask(Packet.IPv4^.Destination) then
	begin
	FRecieverEmulator.HandleData(Packet.TCPIP^, Packet.Data);
	FSenderEmulator.HandleAcknowledgement(Packet.TCPIP^.AcknowledgementNumber);
	end;
if AddressCorrespondsToNetMask(Packet.IPv4^.Source) then
	begin
	FSenderEmulator.HandleData(Packet.TCPIP^, Packet.Data);
	FRecieverEmulator.HandleAcknowledgement(Packet.TCPIP^.AcknowledgementNumber);
	end;
if ((FSenderEmulator <> nil) and FSenderEmulator.Finalized) then
	FSenderFinalized := True;
if ((FRecieverEmulator <> nil) and FRecieverEmulator.Finalized) then
	FRecieverFinalized := True;
FCritacalSectionTCP.Leave();
end;

procedure TSInternetConnectionTCPIPv4.DumpPacket(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame);
var
	DateTimeString : TSString;
	FileName : TSString;
	Description : TSString;
	FileNameInfo : TSString;
	FileNameData : TSString;
begin
DateTimeString := SDateTimeCorrectionString(Date, Time, True);
FileName := FConnectionPacketDumpDirectory + DirectorySeparator + DateTimeString + ' {' + SStr(FPacketCount) + '}';
Description := Packet.Description;
if Description <> '' then
	FileName += ' (' + Description + ')';
FileNameInfo := FileName + Iff(FPacketInfoFileExtension <> '', '.' + FPacketInfoFileExtension, '');
FileNameData := FileName + Iff(FPacketDataFileExtension <> '', '.' + FPacketDataFileExtension, '');

//try
	DumpPacketFiles(Time, Date, Packet, FileNameInfo, FileNameData);
{except
	Packet.ExportInfo(TSTextFileStream.Create('123.ini'));
	PSFloat32(nil)^ := 1/0;
end;}
end;

function TSInternetConnectionTCPIPv4.Finalized() : TSBoolean; 
begin
Result := ((FRecieverEmulator <> nil) and FRecieverEmulator.Finalized and MinimumOneDataModeEnabled());
end;

class function TSInternetConnectionTCPIPv4.ProtocolAbbreviation(const FileSystemSuport : TSBoolean = False) : TSString;
begin
Result := 'TCP' + Iff(not FileSystemSuport, '&', '_') + 'IPv4';
end;

procedure TSInternetConnectionTCPIPv4.PrintTextInfo(const TextStream : TSTextStream; const FileSystemSuport : TSBoolean = False);
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
if (not FileSystemSuport) and (ProtocolAbbreviation() <> '') then
	begin
	if (not Finalized()) then
		if (SNow() - FDateLastPacket).GetPastMilliseconds() > 100 * FSecondsMeansConnectionActive then
			TextStream.TextColor(ColorActive5secProtocol)
		else
			TextStream.TextColor(ColorActiveProtocol)
	else
		TextStream.TextColor(ColorFinalizedProtocol);
	TextStream.Write(ProtocolAbbreviation() +' ');
	end;
if FDeviceIPv4Supported then
	begin
	TextStream.TextColor(ColorText);
	TextStream.Write('Port' + Iff(FileSystemSuport, '=', ':'));
	TextStream.TextColor(ColorPort);
	TextStream.Write(StringJustifyRight(SStr(FSourcePort), 5, ' '));
	
	TextStream.TextColor(ColorText);
	TextStream.Write(';Address' + Iff(FileSystemSuport, '=', ':'));
	SIPv4AddressView(FDestinationAddress, TextStream, ColorAddressNumber, ColorAddressPoint);
	
	TextStream.TextColor(ColorText);
	TextStream.Write(';DPort' + Iff(FileSystemSuport, '=', ':'));
	TextStream.TextColor(ColorPort);
	TextStream.Write(StringJustifyRight(SStr(FDestinationPort), 5, ' '));
	end
else
	begin
	TextStream.TextColor(ColorText);
	TextStream.Write('sa' + Iff(FileSystemSuport, '=', ':'));
	SIPv4AddressView(FSourceAddress, TextStream, ColorAddressNumber, ColorAddressPoint);
	
	TextStream.TextColor(ColorText);
	TextStream.Write('sp' + Iff(FileSystemSuport, '=', ':'));
	TextStream.TextColor(ColorPort);
	TextStream.Write(StringJustifyRight(SStr(FSourcePort), 5, ' '));
	
	TextStream.TextColor(ColorText);
	TextStream.Write('da' + Iff(FileSystemSuport, '=', ':'));
	SIPv4AddressView(FDestinationAddress, TextStream, ColorAddressNumber, ColorAddressPoint);
	
	TextStream.TextColor(ColorText);
	TextStream.Write('dp' + Iff(FileSystemSuport, '=', ':'));
	TextStream.TextColor(ColorPort);
	TextStream.Write(StringJustifyRight(SStr(FDestinationPort), 5, ' '));
	end;
if not FileSystemSuport then
	begin
	TextStream.TextColor(ColorText);
	TextStream.Write(';Size' + Iff(FileSystemSuport, '=', ':'));
	if FDataSize > 1024 * 400 then
		TextStream.TextColor(ColorBigSize)
	else
		TextStream.TextColor(ColorSize);
	TextStream.Write(SMemorySizeToString(FDataSize, 'EN'));
	end;

TextStream.TextColor(7);
end;

class function TSInternetConnectionTCPIPv4.PacketCompatible(const Packet : TSEthernetPacketFrame) : TSBoolean;
begin
Result := (Packet.TCPIP <> nil) and (Packet.IPv4 <> nil);
end;

procedure TSInternetConnectionTCPIPv4.CreateBlockStreams();
begin
FSenderDataStreamFile   := 
	FConnectionDumpDirectory + DirectorySeparator + 'Sender_data' + 
	Iff(PacketDataFileExtension <> '', '.' + SmoothInternetDumperBase.PacketDataFileExtension);
FRecieverDataStreamFile := 
	FConnectionDumpDirectory + DirectorySeparator + 'Reciever_data' + 
	Iff(PacketDataFileExtension <> '', '.' + SmoothInternetDumperBase.PacketDataFileExtension);
SKill(FSenderDataStream);
SKill(FRecieverDataStream);
FSenderDataStream := TFileStream.Create(FSenderDataStreamFile, fmCreate);
FRecieverDataStream := TFileStream.Create(FRecieverDataStreamFile, fmCreate);
end;

function TSInternetConnectionTCPIPv4.InitFirstPacket(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame) : TSBoolean;
begin
Result := True;

FSourcePort := Packet.TCPIP^.SourcePort;
FDestinationPort := Packet.TCPIP^.DestinationPort;
FSourceAddress := Packet.IPv4^.Source;
FDestinationAddress := Packet.IPv4^.Destination;
FFirstPacketIsSelfSender := not AddressCorrespondsToNetMask(FDestinationAddress);

if FDeviceIPv4Supported and (not FFirstPacketIsSelfSender) then
	begin
	Swap(FSourcePort, FDestinationPort);
	Swap(FSourceAddress, FDestinationAddress);
	end;

FTimeFirstPacket := Time;
FDateFirstPacket := Date;

if (FModeRuntimeDataDumper or FModeRuntimePacketDumper) and (not FFictitious) then
	CreateConnectionDumpDirectory();
if FModeRuntimeDataDumper and (not FFictitious) then
	CreateBlockStreams();
if FModePacketStorage and (not FFictitious) then
	begin
	SKill(FPacketStorage);
	FPacketStorage := TSInternetPacketStorage.Create();
	end;
if MinimumOneDataModeEnabled() and (not FFictitious) then
	begin
	SKill(FSenderEmulator);
	SKill(FRecieverEmulator);
	FSenderEmulator := TSEmulatorTCP.Create(Self);
	FRecieverEmulator := TSEmulatorTCP.Create(Self);
	end;
end;

function TSInternetConnectionTCPIPv4.InitPacket(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame) : TSBoolean;
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

procedure TSInternetConnectionTCPIPv4.UpDateStatistic(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame);
begin
FTimeLastPacket := Time;
FDateLastPacket := Date;

FDataSize += Packet.Size;
FPacketCount += 1;
end;

procedure TSInternetConnectionTCPIPv4.PushPacket(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame);
begin
if FModeDataTransfer or FModeRuntimeDataDumper then
	HandlePacket(Packet);
if FModeRuntimePacketDumper then
	DumpPacket(Time, Date, Packet);
if FModePacketStorage then
	FPacketStorage.Add(Time, Date, Packet);

if not FModePacketStorage then
	Packet.Destroy();
end;

function TSInternetConnectionTCPIPv4.PacketPushed(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame) : TSBoolean;
begin
Result := False;
FCritacalSection.Enter();
if PacketCompatible(Packet) then
	if (FPacketCount = 0) and (not FSenderFinalized) and (not FRecieverFinalized) and (not FFictitious) then
		Result := InitFirstPacket(Time, Date, Packet)
	else if (FPacketCount > 0) and (
			((not FSenderFinalized) and (not FRecieverFinalized)) or
			(FSenderFinalized and AddressCorrespondsToNetMask(Packet.IPv4^.Destination)) or
			(FRecieverFinalized and AddressCorrespondsToNetMask(Packet.IPv4^.Source)) ) then
		Result := InitPacket(Time, Date, Packet);
if Result then
	UpDateStatistic(Time, Date, Packet);
if Result and (not FFictitious) then
	PushPacket(Time, Date, Packet)
else if FFictitious then
	KillEmulators();
FCritacalSection.Leave();
end;

constructor TSInternetConnectionTCPIPv4.Create();
begin
inherited;
FSourceAddress := 0;
FSourcePort := 0;
FDestinationAddress := 0;
FDestinationPort := 0;
FSenderFinalized := False;
FRecieverFinalized := False;
FCritacalSectionTCP := TSCriticalSection.Create();
FDataDumpsCount := 0;
FDataDumpsSize := 0;
FSenderEmulator := nil;
FRecieverEmulator := nil;
FSenderDataStream := nil;
FRecieverDataStream := nil;
FSenderDataStreamFile := '';
FRecieverDataStreamFile := '';
end;

procedure TSInternetConnectionTCPIPv4.KillEmulators();
begin
SKill(FSenderEmulator);
SKill(FRecieverEmulator);
end;

destructor TSInternetConnectionTCPIPv4.Destroy();
begin
KillEmulators();
SKill(FCritacalSectionTCP);
inherited;
end;

initialization
begin
SRegisterInternetConnectionClass(TSInternetConnectionTCPIPv4);
end;

end.
