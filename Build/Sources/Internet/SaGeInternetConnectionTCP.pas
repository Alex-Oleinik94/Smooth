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
		FActive : TSGBoolean;
		
		FBuffer : TSGTcpSequenceBuffer;
		FAcknowledgement : TSGTcpSequence;
			public
		procedure PrintTextInfo(const TextStream : TSGTextStream); override;
			protected
		function PacketPushed(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean; override;
		class function PacketComparable(const Packet : TSGEthernetPacketFrame) : TSGBoolean; override;
		procedure HandlePacket(const Packet : TSGEthernetPacketFrame);
		procedure PutData(const TcpSequencePointer : TSGTcpSequence; const Stream : TStream);
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
	
	,StrMan
	;

procedure TSGInternetConnectionTCP.PutData(const TcpSequencePointer : TSGTcpSequence; const Stream : TStream);
begin

end;

procedure TSGInternetConnectionTCP.HandlePacket(const Packet : TSGEthernetPacketFrame);
begin
// todo: data transfer/dumper mode
end;

procedure TSGInternetConnectionTCP.PrintTextInfo(const TextStream : TSGTextStream);
const
	ColorPort = 11;
	ColorSize = 6;
	ColorBigSize = 14;
	ColorAddressNumber = 13;
	ColorAddressPoint = 15;
	ColorText = 7;
	ColorActiveProtocol = 10;
	ColorActive5secProtocol = 2;
	ColorFinalizedProtocol = 12;
begin
if FActive then
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
	TextStream.Write('Port:');
	TextStream.TextColor(ColorPort);
	TextStream.Write(StringJustifyRight(SGStr(FSourcePort), 5, ' '));
	
	TextStream.TextColor(ColorText);
	TextStream.Write(';Address:');
	SGIPv4AddressView(FDestinationAddress, TextStream, ColorAddressNumber, ColorAddressPoint);
	
	TextStream.TextColor(ColorText);
	TextStream.Write(';DPort:');
	TextStream.TextColor(ColorPort);
	TextStream.Write(StringJustifyRight(SGStr(FDestinationPort), 5, ' '));
	end
else
	begin
	TextStream.TextColor(ColorText);
	TextStream.Write('sa:');
	SGIPv4AddressView(FSourceAddress, TextStream, ColorAddressNumber, ColorAddressPoint);
	
	TextStream.TextColor(ColorText);
	TextStream.Write('sp:');
	TextStream.TextColor(ColorPort);
	TextStream.Write(StringJustifyRight(SGStr(FSourcePort), 5, ' '));
	
	TextStream.TextColor(ColorText);
	TextStream.Write('da:');
	SGIPv4AddressView(FDestinationAddress, TextStream, ColorAddressNumber, ColorAddressPoint);
	
	TextStream.TextColor(ColorText);
	TextStream.Write('dp:');
	TextStream.TextColor(ColorPort);
	TextStream.Write(StringJustifyRight(SGStr(FDestinationPort), 5, ' '));
	end;
TextStream.TextColor(ColorText);
TextStream.Write(';Size:');
if FDataSize > 1024 * 400 then
	TextStream.TextColor(ColorBigSize)
else
	TextStream.TextColor(ColorSize);
TextStream.Write(SGGetSizeString(FDataSize, 'EN'));

TextStream.TextColor(7);
end;

class function TSGInternetConnectionTCP.PacketComparable(const Packet : TSGEthernetPacketFrame) : TSGBoolean;
begin
Result := (Packet.TCPIP <> nil) and (Packet.IPv4 <> nil);
end;

function TSGInternetConnectionTCP.PacketPushed(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean;
begin
Result := False;
FCritacalSection.Enter();
if (not FPacketStorage.HasData) and PacketComparable(Packet) then
	begin
	Result := True;
	
	FSourcePort := Packet.TCPIP^.SourcePort;
	FDestinationPort := Packet.TCPIP^.DestinationPort;
	FSourceAddress := Packet.IPv4^.Source;
	FDestinationAddress := Packet.IPv4^.Destination;
	
	if FDeviceIPv4Supported and ((FDeviceIPv4Mask.Address and FDestinationAddress.Address) = FDeviceIPv4Net.Address) then
		begin
		Swap(FSourcePort, FDestinationPort);
		Swap(FSourceAddress, FDestinationAddress);
		end;
	
	FTimeFirstPacket := Time;
	FDateFirstPacket := Date;
	end
else if FPacketStorage.HasData and PacketComparable(Packet) then
	Result := ((
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
if Result then
	begin
	FTimeLastPacket := Time;
	FDateLastPacket := Date;
	
	FDataSize += Packet.Size;
	FPacketCount += 1;
	
	if Packet.TCPIP^.Final {or Packet.TCPIP^.Reset} then
		FActive := False
	else
		FActive := True;
	if FModeDataTransfer or FModeDataDumper then
		HandlePacket(Packet);
	if FModePacketStorage then
		FPacketStorage.Add(Time, Date, Packet)
	else
		Packet.Destroy();
	end;
FCritacalSection.Leave();
end;

constructor TSGInternetConnectionTCP.Create();
begin
inherited;
FSourceAddress := 0;
FSourcePort := 0;
FDestinationAddress := 0;
FDestinationPort := 0;
FActive := False;
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
