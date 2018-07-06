{$INCLUDE SaGe.inc}

unit SaGeInternetConnectionTCPIPv4;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	,SaGeInternetBase
	,SaGeInternetConnection
	,SaGeDateTime
	,SaGeEthernetPacketFrame
	,SaGeTextStream
	,SaGeInternetPacketStorage
	,SaGeCriticalSection
	,SaGeStreamUtils
	,SaGeEmulatorTCP
	
	,Classes
	;

type
	TSGInternetConnectionTCPIPv4 = class;
	
	TSGEmulatorTCP = class(TSGEmulatorTransmissionControlProtocol)
			public
		constructor Create(const _Connection : TSGInternetConnectionTCPIPv4);
			protected
		FConnection : TSGInternetConnectionTCPIPv4;
			public
		property Connection : TSGInternetConnectionTCPIPv4 read FConnection write FConnection;
			public
		procedure HandleData(const Data : TStream); override;
		end;
	
	TSGInternetConnectionTCPIPv4 = class(TSGInternetConnection)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FCritacalSectionTCP : TSGCriticalSection;
		FSourcePort, FDestinationPort : TSGUInt16;
		FSourceAddress, FDestinationAddress : TSGIPv4Address;
		FSenderFinalized : TSGBoolean;
		FRecieverFinalized : TSGBoolean;
		
		// TCP protocol emulation
		FSenderEmulator : TSGEmulatorTransmissionControlProtocol;
		FRecieverEmulator : TSGEmulatorTransmissionControlProtocol;
		
		// Data dumper
		FDataDumpsCount : TSGUInt64;
		FDataDumpsSize  : TSGUInt64;
		FSenderDataStreamFile, FRecieverDataStreamFile : TSGString;
		FSenderDataStream, FRecieverDataStream : TFileStream;
			public
		class function ProtocolAbbreviation(const FileSystemSuport : TSGBoolean = False) : TSGString; override;
		procedure PrintTextInfo(const TextStream : TSGTextStream; const FileSystemSuport : TSGBoolean = False); override;
			protected
		procedure KillEmulators();
		function PacketPushed(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean; override;
		class function PacketComparable(const Packet : TSGEthernetPacketFrame) : TSGBoolean; override;
			protected
		procedure DumpPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame);
		procedure HandlePacket(const Packet : TSGEthernetPacketFrame);
		function InitFirstPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean;
		function InitPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean;
		procedure PushPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame);
		procedure DumpData(const Stream : TStream; const EmulatorString : TSGString);
		procedure PushData(const Stream : TStream; const Emulator : TSGEmulatorTCP);
		procedure CreateBlockStreams();
		end;

implementation

uses
	 SaGeInternetConnections
	,SaGeStringUtils
	,SaGeBaseUtils
	,SaGeLog
	,SaGeInternetDumperBase
	//,SaGeTextFileStream
	
	,StrMan
	;

constructor TSGEmulatorTCP.Create(const _Connection : TSGInternetConnectionTCPIPv4);
begin
inherited Create();
FConnection := _Connection;
end;

procedure TSGEmulatorTCP.HandleData(const Data : TStream);
begin
if FConnection <> nil then
	FConnection.PushData(Data, Self);
end;

procedure TSGInternetConnectionTCPIPv4.DumpData(const Stream : TStream; const EmulatorString : TSGString);
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

procedure TSGInternetConnectionTCPIPv4.PushData(const Stream : TStream; const Emulator : TSGEmulatorTCP);
var
	DataType : TSGConnectionDataType = SGNoData;
begin
if FModeDataTransfer and (FConnectionsHandler <> nil) then
	begin
	if Emulator = FSenderEmulator then
		DataType := SGSenderData
	else if Emulator = FRecieverEmulator then
		DataType := SGRecieverData;
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
		SGCopyPartStreamToStream(Stream, FSenderDataStream, Stream.Size)
	else if Emulator = FRecieverEmulator then
		SGCopyPartStreamToStream(Stream, FRecieverDataStream, Stream.Size);
	end;
end;

procedure TSGInternetConnectionTCPIPv4.HandlePacket(const Packet : TSGEthernetPacketFrame);
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
if ((FSenderEmulator <> nil) and FSenderEmulator.Finalized) then
	FSenderFinalized := True;
if ((FRecieverEmulator <> nil) and FRecieverEmulator.Finalized) then
	FRecieverFinalized := True;
FCritacalSectionTCP.Leave();
end;

procedure TSGInternetConnectionTCPIPv4.DumpPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame);
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

//try
	DumpPacketFiles(Time, Date, Packet, FileNameInfo, FileNameData);
{except
	Packet.ExportInfo(TSGTextFileStream.Create('123.ini'));
	PSGFloat32(nil)^ := 1/0;
end;}
end;

class function TSGInternetConnectionTCPIPv4.ProtocolAbbreviation(const FileSystemSuport : TSGBoolean = False) : TSGString;
begin
Result := 'TCP' + Iff(not FileSystemSuport, '/') + 'IPv4';
end;

procedure TSGInternetConnectionTCPIPv4.PrintTextInfo(const TextStream : TSGTextStream; const FileSystemSuport : TSGBoolean = False);
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
	if (FRecieverEmulator <> nil) and (not FRecieverEmulator.Finalized) then
		if (SGNow() - FDateLastPacket).GetPastMiliSeconds() > 100 * FSecondsMeansConnectionActive then
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
	TextStream.Write(StringJustifyRight(SGStr(FSourcePort), 5, ' '));
	
	TextStream.TextColor(ColorText);
	TextStream.Write(';Address' + Iff(FileSystemSuport, '=', ':'));
	SGIPv4AddressView(FDestinationAddress, TextStream, ColorAddressNumber, ColorAddressPoint);
	
	TextStream.TextColor(ColorText);
	TextStream.Write(';DPort' + Iff(FileSystemSuport, '=', ':'));
	TextStream.TextColor(ColorPort);
	TextStream.Write(StringJustifyRight(SGStr(FDestinationPort), 5, ' '));
	end
else
	begin
	TextStream.TextColor(ColorText);
	TextStream.Write('sa' + Iff(FileSystemSuport, '=', ':'));
	SGIPv4AddressView(FSourceAddress, TextStream, ColorAddressNumber, ColorAddressPoint);
	
	TextStream.TextColor(ColorText);
	TextStream.Write('sp' + Iff(FileSystemSuport, '=', ':'));
	TextStream.TextColor(ColorPort);
	TextStream.Write(StringJustifyRight(SGStr(FSourcePort), 5, ' '));
	
	TextStream.TextColor(ColorText);
	TextStream.Write('da' + Iff(FileSystemSuport, '=', ':'));
	SGIPv4AddressView(FDestinationAddress, TextStream, ColorAddressNumber, ColorAddressPoint);
	
	TextStream.TextColor(ColorText);
	TextStream.Write('dp' + Iff(FileSystemSuport, '=', ':'));
	TextStream.TextColor(ColorPort);
	TextStream.Write(StringJustifyRight(SGStr(FDestinationPort), 5, ' '));
	end;
if not FileSystemSuport then
	begin
	TextStream.TextColor(ColorText);
	TextStream.Write(';Size' + Iff(FileSystemSuport, '=', ':'));
	if FDataSize > 1024 * 400 then
		TextStream.TextColor(ColorBigSize)
	else
		TextStream.TextColor(ColorSize);
	TextStream.Write(SGGetSizeString(FDataSize, 'EN'));
	end;

TextStream.TextColor(7);
end;

class function TSGInternetConnectionTCPIPv4.PacketComparable(const Packet : TSGEthernetPacketFrame) : TSGBoolean;
begin
Result := (Packet.TCPIP <> nil) and (Packet.IPv4 <> nil);
end;

procedure TSGInternetConnectionTCPIPv4.CreateBlockStreams();
begin
FSenderDataStreamFile   := 
	FConnectionDumpDirectory + DirectorySeparator + 'Sender_data' + 
	Iff(PacketDataFileExtension <> '', '.' + SaGeInternetDumperBase.PacketDataFileExtension);
FRecieverDataStreamFile := 
	FConnectionDumpDirectory + DirectorySeparator + 'Reciever_data' + 
	Iff(PacketDataFileExtension <> '', '.' + SaGeInternetDumperBase.PacketDataFileExtension);
SGKill(FSenderDataStream);
SGKill(FRecieverDataStream);
FSenderDataStream := TFileStream.Create(FSenderDataStreamFile, fmCreate);
FRecieverDataStream := TFileStream.Create(FRecieverDataStreamFile, fmCreate);
end;

function TSGInternetConnectionTCPIPv4.InitFirstPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean;
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

if (FModeRuntimeDataDumper or FModeRuntimePacketDumper) and (not FFictitious) then
	CreateConnectionDumpDirectory();
if FModeRuntimeDataDumper and (not FFictitious) then
	CreateBlockStreams();
if FModePacketStorage and (not FFictitious) then
	begin
	SGKill(FPacketStorage);
	FPacketStorage := TSGInternetPacketStorage.Create();
	end;
if (FModeDataTransfer or FModeRuntimeDataDumper) and (not FFictitious) then
	begin
	FSenderEmulator := TSGEmulatorTCP.Create(Self);
	FRecieverEmulator := TSGEmulatorTCP.Create(Self);
	end;
end;

function TSGInternetConnectionTCPIPv4.InitPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean;
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

procedure TSGInternetConnectionTCPIPv4.PushPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame);
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

function TSGInternetConnectionTCPIPv4.PacketPushed(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean;
begin
Result := False;
FCritacalSection.Enter();
if PacketComparable(Packet) then
	if (FPacketCount = 0) and (not FSenderFinalized) and (not FRecieverFinalized) and (not FFictitious) then
		Result := InitFirstPacket(Time, Date, Packet)
	else if (FPacketCount > 0) and (
			((not FSenderFinalized) and (not FRecieverFinalized)) or
			(FSenderFinalized and AddressMatchesNetMask(Packet.IPv4^.Destination)) or
			(FRecieverFinalized and AddressMatchesNetMask(Packet.IPv4^.Source)) ) then
		Result := InitPacket(Time, Date, Packet);
if Result and (not FFictitious) then
	PushPacket(Time, Date, Packet)
else if FFictitious then
	KillEmulators();
FCritacalSection.Leave();
end;

constructor TSGInternetConnectionTCPIPv4.Create();
begin
inherited;
FSourceAddress := 0;
FSourcePort := 0;
FDestinationAddress := 0;
FDestinationPort := 0;
FSenderFinalized := False;
FRecieverFinalized := False;
FCritacalSectionTCP := TSGCriticalSection.Create();
FDataDumpsCount := 0;
FDataDumpsSize := 0;
FSenderEmulator := nil;
FRecieverEmulator := nil;
FSenderDataStream := nil;
FRecieverDataStream := nil;
FSenderDataStreamFile := '';
FRecieverDataStreamFile := '';
end;

procedure TSGInternetConnectionTCPIPv4.KillEmulators();
begin
SGKill(FSenderEmulator);
SGKill(FRecieverEmulator);
end;

destructor TSGInternetConnectionTCPIPv4.Destroy();
begin
KillEmulators();
SGKill(FCritacalSectionTCP);
inherited;
end;

initialization
begin
SGRegisterInternetConnectionClass(TSGInternetConnectionTCPIPv4);
end;

end.
