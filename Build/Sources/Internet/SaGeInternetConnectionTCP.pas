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
	
	,Classes
	;

type
	TSGInternetConnectionTCP = class(TSGInternetConnection)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FSourcePort, FDestinationPort : TSGUInt16;
		FSourceAddress, FDestinationAddress : TSGIPv4Address;
		FFinalized : TSGBoolean;
		
		FBuffer : TSGTcpSequenceBuffer;
		FAcknowledgement : TSGTcpSequence;
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
			public
		procedure HandleData(const Stream : TStream); virtual;
		function HasData() : TSGBoolean; virtual;
		function CountData() : TSGMaxEnum; virtual;
		end;

implementation

uses
	 SaGeInternetConnections
	,SaGeStringUtils
	,SaGeBaseUtils
	,SaGeLog
	,SaGeTextFileStream
	,SaGeStreamUtils
	
	,StrMan
	;

procedure TSGInternetConnectionTCP.PutAcknowledgement(const AcknowledgementNumber : TSGTcpSequence);
begin

end;

procedure TSGInternetConnectionTCP.PutData(const TcpSequencePointer : TSGTcpSequence; const Stream : TStream);
begin

end;

procedure TSGInternetConnectionTCP.HandlePacket(const Packet : TSGEthernetPacketFrame);
begin
// todo: data transfer/dumper mode
end;

procedure TSGInternetConnectionTCP.DumpPacket(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame);
var
	DateTimeString : TSGString;
	FileName : TSGString;
	Description : TSGString;
	FileNameInfo : TSGString;
	FileNameData : TSGString;
	TextStream : TSGTextFileStream = nil;
	FileStream : TFileStream = nil;
	Stream : TMemoryStream = nil;
begin
DateTimeString := SGDateTimeCorrectionString(Date, Time, True);
FileName := FConnectionPacketDumpDirectory + DirectorySeparator + DateTimeString + ' {' + SGStr(FPacketCount) + '}';
Description := Packet.Description;
if Description <> '' then
	FileName += ' (' + Description + ')';
FileNameInfo := FileName + Iff(FPacketInfoFileExtension <> '', '.' + FPacketInfoFileExtension, '');
FileNameData := FileName + Iff(FPacketDataFileExtension <> '', '.' + FPacketDataFileExtension, '');

TextStream := TSGTextFileStream.Create(FileNameInfo);
TextStream.WriteLn('[packet]');
TextStream.WriteLn(['DataTime = ', SGDateTimeCorrectionString(Date, Time, False)]);
TextStream.WriteLn(['Size     = ', SGGetSizeString(Packet.Size, 'EN')]);
TextStream.WriteLn();
Packet.ExportInfo(TextStream);
SGKill(TextStream);

Stream := Packet.CreateStream();
if Stream <> nil then
	begin
	FileStream := TFileStream.Create(FileNameData, fmCreate);
	Stream.Position := 0;
	SGCopyPartStreamToStream(Stream, FileStream, Stream.Size);
	SGKill(FileStream);
	SGKill(Stream);
	end;
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
FFirstPacketIsSelfSender := not ((FDeviceIPv4Mask.Address and FDestinationAddress.Address) = FDeviceIPv4Net.Address);

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
	((((Packet.TCPIP^.SourcePort = FSourcePort) and
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

if Packet.TCPIP^.Final {or Packet.TCPIP^.Reset} then
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
FAcknowledgement := 0;
FBuffer := GetMem(SG_TCP_BUFFER_SIZE);
FillChar(FBuffer^, SG_TCP_BUFFER_SIZE, 0);
end;

destructor TSGInternetConnectionTCP.Destroy();
begin
if FBuffer <> nil then
	begin
	FreeMem(FBuffer, SG_TCP_BUFFER_SIZE);
	FBuffer := nil;
	end;
inherited;
end;

procedure TSGInternetConnectionTCP.HandleData(const Stream : TStream);
begin
end;

function TSGInternetConnectionTCP.HasData() : TSGBoolean;
begin
Result := False;
end;

function TSGInternetConnectionTCP.CountData() : TSGMaxEnum;
begin
Result := 0;
end;

initialization
begin
SGRegisterInternetConnectionClass(TSGInternetConnectionTCP);
end;

end.
