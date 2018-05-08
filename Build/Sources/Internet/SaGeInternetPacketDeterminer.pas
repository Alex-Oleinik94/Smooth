{$INCLUDE SaGe.inc}

unit SaGeInternetPacketDeterminer;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeInternetBase
	,SaGeTextFileStream
	
	,Classes
	;

type
	TSGEthernetProtocolData = object
		
		end;
	
	TSGInternetPacketDeterminer = class(TSGNamed)
			public
		destructor Destroy(); override;
		constructor Create(); override;
			private
		FEthernetHeader : TSGEthernetHeader;
		FProtocolData : TSGEthernetProtocolData;
			private
		procedure DeterminePacket(const Stream : TStream);
			public
		procedure Determine(const Stream : TStream; const DestryPacketStreamAfter : TSGBoolean = True);
		procedure WriteInfoToStream(const Stream : TSGTextFileStream);
			public
		function EthernetDestination() : TSGString;
		function EthernetSource() : TSGString;
		function EthernetProtocol() : TSGString;
		end;

procedure SGWritePacketInfo(const Stream : TSGTextFileStream; const Packet : TStream; const DestryPacketStreamAfter : TSGBoolean = True);

implementation

procedure SGWritePacketInfo(const Stream : TSGTextFileStream; const Packet : TStream; const DestryPacketStreamAfter : TSGBoolean = True);
begin
with TSGInternetPacketDeterminer.Create() do
	begin
	Determine(Packet, DestryPacketStreamAfter);
	WriteInfoToStream(Stream);
	Destroy();
	end;
end;

// =================================
// ===TSGInternetPacketDeterminer===
// =================================

procedure TSGInternetPacketDeterminer.DeterminePacket(const Stream : TStream);
begin
Stream.ReadBuffer(FEthernetHeader, SizeOf(TSGEthernetHeader));
//todo
end;

procedure TSGInternetPacketDeterminer.Determine(const Stream : TStream; const DestryPacketStreamAfter : TSGBoolean = True);
begin
if Stream <> nil then
	begin
	DeterminePacket(Stream);
	if DestryPacketStreamAfter then
		Stream.Destroy();
	end;
end;

procedure TSGInternetPacketDeterminer.WriteInfoToStream(const Stream : TSGTextFileStream);
begin
with Stream do
	begin
	WriteLn('[ethernet]');
	WriteLn(['Destination = ', EthernetDestination()]);
	WriteLn(['Source      = ', EthernetSource()]);
	WriteLn(['Protocol    = ', EthernetProtocol()]);
	WriteLn();
	end;
//todo
end;


function TSGInternetPacketDeterminer.EthernetDestination() : TSGString;
begin
Result := SGEthernetAddesssToString(FEthernetHeader.Destination);
end;

function TSGInternetPacketDeterminer.EthernetSource() : TSGString;
begin
Result := SGEthernetAddesssToString(FEthernetHeader.Source);
end;

function TSGInternetPacketDeterminer.EthernetProtocol() : TSGString;
begin
Result := SGEthernetProtocolToStringExtended(FEthernetHeader.Protocol);
end;

destructor TSGInternetPacketDeterminer.Destroy();
begin
FillChar(FEthernetHeader, SizeOf(FEthernetHeader), 0);
inherited;
end;

constructor TSGInternetPacketDeterminer.Create();
begin
inherited;
FillChar(FEthernetHeader, SizeOf(FEthernetHeader), 0);
end;

end.
