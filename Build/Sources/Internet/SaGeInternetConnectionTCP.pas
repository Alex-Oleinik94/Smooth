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
	
	,Classes
	;

type
	TSGInternetConnectionTCP = class(TSGInternetConnection)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FCritacalSectionTCP : TSGCriticalSection;
		FSourcePort, FDestinationPort : TSGUInt16;
		FSourceAddress, FDestinationAddress : TSGIPv4Address;
		
		// TCP protocol emulation
		FBuffer : TSGTcpSequenceBuffer;
		FFirstBufferElement : TSGInt32;
		FFirstBufferElementAddress : TSGTcpSequence;
		FFirstBufferElementSeted : TSGBoolean;
		FAcknowledgement : TSGTcpSequence;
		FFinalized : TSGBoolean;
		
		// Data transfer
		FPushedData : TSGMemoryStreamList;
		
		// Data dumper
		FCountDataDumps : TSGUInt64;
			public
		procedure PrintTextInfo(const TextStream : TSGTextStream; const ForFileSystem : TSGBoolean = False); override;
			protected
		function PacketPushed(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean; override;
		class function PacketComparable(const Packet : TSGEthernetPacketFrame) : TSGBoolean; override;
			protected
		procedure DumpPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame);
		procedure HandlePacket(const Packet : TSGEthernetPacketFrame);
		procedure PutData(const TcpSequencePointer : TSGTcpSequence; const Stream : TStream);
		procedure PutAcknowledgement(const AcknowledgementNumber : TSGTcpSequence);
		function InitFirstPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean;
		function InitPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean;
		procedure PushPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame);
		procedure DumpData(const Stream : TStream);
			public
		function HandleData(const Stream : TStream) : TSGBoolean; override;
		function HasData() : TSGBoolean; override;
		function CountData() : TSGMaxEnum; override;
			protected
		procedure ResetBuffer();
		procedure PushData(const Number : TSGTcpSequence); overload;
		procedure PushData(var Stream : TMemoryStream); overload;
		end;

implementation

uses
	 SaGeInternetConnections
	,SaGeStringUtils
	,SaGeBaseUtils
	,SaGeLog
	
	,StrMan
	;

procedure TSGInternetConnectionTCP.PutAcknowledgement(const AcknowledgementNumber : TSGTcpSequence);
begin

end;

procedure TSGInternetConnectionTCP.PushData(const Number : TSGTcpSequence); overload;
var
	Stream : TMemoryStream = nil;
begin
if FFirstBufferElementSeted and (Number - FFirstBufferElementAddress > 0) then
	begin
	Stream := TMemoryStream.Create();
	Stream.Write(FBuffer[FFirstBufferElement + Number - FFirstBufferElementAddress], Number - FFirstBufferElementAddress);
	FFirstBufferElement += Number - FFirstBufferElementAddress;
	FFirstBufferElementAddress := Number;
	PushData(Stream);
	end;
end;

procedure TSGInternetConnectionTCP.DumpData(const Stream : TStream);
var
	FileStream : TFileStream = nil;
begin
FCountDataDumps += 1;

FileStream := TFileStream.Create(FConnectionDataDumpDirectory + DirectorySeparator + SGStr(FCountDataDumps), fmCreate);
Stream.Position := 0;
SGCopyPartStreamToStream(Stream, FileStream, Stream.Size);
SGKill(FileStream);
end;

procedure TSGInternetConnectionTCP.PushData(var Stream : TMemoryStream); overload;
begin
if FModeDataTransfer then
	FPushedData += Stream;
if FModeRuntimeDataDumper then
	DumpData(Stream);
if not FModeDataTransfer then
	SGKill(Stream);
end;

procedure TSGInternetConnectionTCP.PutData(const TcpSequencePointer : TSGTcpSequence; const Stream : TStream);
begin
if not FFirstBufferElementSeted then
	begin
	FFirstBufferElement := 0;
	FFirstBufferElementSeted := True;
	FFirstBufferElementAddress := TcpSequencePointer;
	end;
Stream.Position := 0;
Stream.Read(FBuffer[FFirstBufferElement + TcpSequencePointer - FFirstBufferElementAddress], Stream.Size);
end;

procedure TSGInternetConnectionTCP.ResetBuffer();
begin
FillChar(FBuffer^, SG_TCP_BUFFER_SIZE, 0);
FAcknowledgement := 0;
FFirstBufferElement := 0;
FFirstBufferElementSeted := False;
FFirstBufferElementAddress := 0;
end;

procedure TSGInternetConnectionTCP.HandlePacket(const Packet : TSGEthernetPacketFrame);
begin
if AddressMatchesNetMask(Packet.IPv4^.Destination) then
	begin
	FCritacalSectionTCP.Enter();
	
	if Packet.Data <> nil then
		PutData(Packet.TCPIP^.SequenceNumber, Packet.Data);
	if Packet.TCPIP^.Acknowledgement then
		PutAcknowledgement(Packet.TCPIP^.AcknowledgementNumber);
	if Packet.TCPIP^.Push then
		PushData(Packet.TCPIP^.SequenceNumber + Packet.Data.Size);
	if Packet.TCPIP^.Reset then
		ResetBuffer();
	
	FCritacalSectionTCP.Leave();
	end;
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
if (not FFinalized) then
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

if Packet.TCPIP^.Final then
	FFinalized := True;
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
FBuffer := GetMem(SG_TCP_BUFFER_SIZE);
FillChar(FBuffer^, SG_TCP_BUFFER_SIZE, 0);
ResetBuffer();
FCritacalSectionTCP := TSGCriticalSection.Create();
FPushedData := nil;
FCountDataDumps := 0;
end;

destructor TSGInternetConnectionTCP.Destroy();
begin
if FBuffer <> nil then
	begin
	FreeMem(FBuffer, SG_TCP_BUFFER_SIZE);
	FBuffer := nil;
	end;
SGKill(FCritacalSectionTCP);
inherited;
end;

function TSGInternetConnectionTCP.HandleData(const Stream : TStream) : TSGBoolean;
var
	MemStream : TMemoryStream;
begin
Result := False;
if (FPushedData <> nil) and (Length(FPushedData) > 0) then
	begin
	Result := True;
	MemStream := FPushedData[0];
	FPushedData -= MemStream;
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
if (FPushedData <> nil) then
	Result := Length(FPushedData);
end;

initialization
begin
SGRegisterInternetConnectionClass(TSGInternetConnectionTCP);
end;

end.
