{$INCLUDE SaGe.inc}

unit SaGeInternetConnectionTCP;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeInternetBase
	,SaGeCriticalSection
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
			private
		FCritacalSection : TSGCriticalSection;
		FPacketStorage : TSGInternetPacketStorage;
		FSizeData : TSGUInt64;
			private
		FSourcePort, FDestinationPort : TSGUInt16;
		FSourceAddress, FDestinationAddress : TSGIPv4Address;
			public
		procedure PrintTextInfo(const TextStream : TSGTextStream); override;
			protected
		function PacketPushed(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean; override;
		class function PacketComparable(const Packet : TSGEthernetPacketFrame) : TSGBoolean; override;
			public
		procedure HandleData(const Stream : TStream); virtual;
		function HasData() : TSGBoolean; virtual;
		function CountData() : TSGMaxEnum; virtual;
		end;

implementation

uses
	 SaGeInternetConnections
	,SaGeStringUtils
	;

procedure TSGInternetConnectionTCP.PrintTextInfo(const TextStream : TSGTextStream);
begin
TextStream.TextColor(14);
TextStream.Write('TCP ');

TextStream.TextColor(7);
TextStream.Write('sa:');
TextStream.TextColor(13);
TextStream.Write(SGIPv4AddressToString(FSourceAddress));

TextStream.TextColor(7);
TextStream.Write('sp:');
TextStream.TextColor(15);
TextStream.Write([FSourcePort]);

TextStream.TextColor(7);
TextStream.Write('da:');
TextStream.TextColor(13);
TextStream.Write(SGIPv4AddressToString(FDestinationAddress));

TextStream.TextColor(7);
TextStream.Write('dp:');
TextStream.TextColor(15);
TextStream.Write([FDestinationPort]);

TextStream.TextColor(7);
TextStream.Write('size:');
TextStream.TextColor(12);
TextStream.Write(SGGetSizeString(FSizeData, 'EN'));

TextStream.TextColor(7);
end;

class function TSGInternetConnectionTCP.PacketComparable(const Packet : TSGEthernetPacketFrame) : TSGBoolean;
begin
Result := Packet.TCPIP() <> nil;
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
	end
else if FPacketStorage.HasData then
	begin
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
	end;
if Result then
	begin
	FSizeData += Packet.Size;
	FPacketStorage.Add(Time, Date, Packet);
	end;
FCritacalSection.Leave();
end;

constructor TSGInternetConnectionTCP.Create();
begin
inherited;
FCritacalSection := TSGCriticalSection.Create();
FPacketStorage := TSGInternetPacketStorage.Create();
FSourceAddress := 0;
FSourcePort := 0;
FDestinationAddress := 0;
FDestinationPort := 0;
FSizeData := 0;
end;

destructor TSGInternetConnectionTCP.Destroy();
begin
SGKill(FPacketStorage);
SGKill(FCritacalSection);
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
