{$INCLUDE Smooth.inc}

unit SmoothInternetPacketDeterminer;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothInternetBase
	,SmoothTextFileStream
	,SmoothEthernetPacketFrame
	
	,Classes
	;

type
	TSInternetPacketDeterminer = class(TSNamed)
			public
		destructor Destroy(); override;
		constructor Create(); override;
			private
		FEthernetFrame : TSEthernetPacketFrame;
			private
		procedure DeterminePacket(const Stream : TStream);
		procedure KillFrame();
			public
		procedure Determine(const Stream : TStream; const DestroyPacketStreamAfter : TSBoolean = True);
		procedure WriteInfoToStream(const Stream : TSTextFileStream);
			public
		property EthernetFrame : TSEthernetPacketFrame read FEthernetFrame;
		end;

function SPacketDescription(const Stream : TStream) : TSString;
procedure SWritePacketInfo(const Stream : TSTextFileStream; const Packet : TStream; const DestroyPacketStreamAfter : TSBoolean = True);
procedure SKill(var Variable : TSInternetPacketDeterminer);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

procedure SKill(var Variable : TSInternetPacketDeterminer);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if Variable <> nil then
	begin
	Variable.Destroy();
	Variable := nil;
	end;
end;

function SPacketDescription(const Stream : TStream) : TSString;
var
	Frame : TSEthernetPacketFrame;
begin
Frame := TSEthernetPacketFrame.Create();
Stream.Position := 0;
Frame.Read(Stream, Stream.Size);
Stream.Position := 0;
Result := Frame.Description;
SKill(Frame);
end;

procedure SWritePacketInfo(const Stream : TSTextFileStream; const Packet : TStream; const DestroyPacketStreamAfter : TSBoolean = True);
begin
with TSInternetPacketDeterminer.Create() do
	begin
	Determine(Packet, DestroyPacketStreamAfter);
	WriteInfoToStream(Stream);
	Destroy();
	end;
end;

// =================================
// ===TSInternetPacketDeterminer===
// =================================

procedure TSInternetPacketDeterminer.KillFrame();
begin
if FEthernetFrame <> nil then
	begin
	FEthernetFrame.Destroy();
	FEthernetFrame := nil;
	end;
end;

procedure TSInternetPacketDeterminer.DeterminePacket(const Stream : TStream);
begin
KillFrame();
FEthernetFrame := TSEthernetPacketFrame.Create();
FEthernetFrame.Read(Stream, Stream.Size - Stream.Position);
end;

procedure TSInternetPacketDeterminer.Determine(const Stream : TStream; const DestroyPacketStreamAfter : TSBoolean = True);
begin
if Stream <> nil then
	begin
	DeterminePacket(Stream);
	if DestroyPacketStreamAfter then
		Stream.Destroy();
	end;
end;

procedure TSInternetPacketDeterminer.WriteInfoToStream(const Stream : TSTextFileStream);
begin
if FEthernetFrame <> nil then
	FEthernetFrame.ExportInfo(Stream);
end;

destructor TSInternetPacketDeterminer.Destroy();
begin
KillFrame();
inherited;
end;

constructor TSInternetPacketDeterminer.Create();
begin
inherited;
FEthernetFrame := nil;
end;

end.
