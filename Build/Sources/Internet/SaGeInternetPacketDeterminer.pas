{$INCLUDE SaGe.inc}

unit SaGeInternetPacketDeterminer;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeInternetBase
	,SaGeTextFileStream
	,SaGeEthernetPacketFrame
	
	,Classes
	;

type
	TSGInternetPacketDeterminer = class(TSGNamed)
			public
		destructor Destroy(); override;
		constructor Create(); override;
			private
		FEthernetFrame : TSGEthernetPacketFrame;
			private
		procedure DeterminePacket(const Stream : TStream);
			public
		procedure Determine(const Stream : TStream; const DestroyPacketStreamAfter : TSGBoolean = True);
		procedure WriteInfoToStream(const Stream : TSGTextFileStream);
			public
		property EthernetFrame : TSGEthernetPacketFrame read FEthernetFrame;
		end;

procedure SGWritePacketInfo(const Stream : TSGTextFileStream; const Packet : TStream; const DestroyPacketStreamAfter : TSGBoolean = True);

implementation

procedure SGWritePacketInfo(const Stream : TSGTextFileStream; const Packet : TStream; const DestroyPacketStreamAfter : TSGBoolean = True);
begin
with TSGInternetPacketDeterminer.Create() do
	begin
	Determine(Packet, DestroyPacketStreamAfter);
	WriteInfoToStream(Stream);
	Destroy();
	end;
end;

// =================================
// ===TSGInternetPacketDeterminer===
// =================================

procedure TSGInternetPacketDeterminer.DeterminePacket(const Stream : TStream);
begin
if FEthernetFrame <> nil then
	begin
	FEthernetFrame.Destroy();
	FEthernetFrame := nil;
	end;
FEthernetFrame := TSGEthernetPacketFrame.Create();
FEthernetFrame.Read(Stream);
end;

procedure TSGInternetPacketDeterminer.Determine(const Stream : TStream; const DestroyPacketStreamAfter : TSGBoolean = True);
begin
if Stream <> nil then
	begin
	DeterminePacket(Stream);
	if DestroyPacketStreamAfter then
		Stream.Destroy();
	end;
end;

procedure TSGInternetPacketDeterminer.WriteInfoToStream(const Stream : TSGTextFileStream);
begin
if FEthernetFrame <> nil then
	FEthernetFrame.ExportInfo(Stream);
end;

destructor TSGInternetPacketDeterminer.Destroy();
begin
if FEthernetFrame <> nil then
	begin
	FEthernetFrame.Destroy();
	FEthernetFrame := nil;
	end;
inherited;
end;

constructor TSGInternetPacketDeterminer.Create();
begin
inherited;
FEthernetFrame := nil;
end;

end.
