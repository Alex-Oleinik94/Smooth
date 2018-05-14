{$INCLUDE SaGe.inc}

unit SaGeEthernetPacketFrame;

interface

uses
	 SaGeBase
	,SaGeTextFileStream
	,SaGeEthernetPacketFrameBase
	,SaGeInternetBase
	;

type
	TSGEthernetPacketFrame = class(TSGEthernetPacketDataFrame)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FEthernetPacketHeader : TSGEthernetHeader;
		FProtocolFrame : TSGEthernetPacketProtocolFrame;
		FEthernetSize : TSGEthernetPacketFrameSize;
			public
		procedure Read(const Stream : TSGEthernetPacketFrameStream; const BlockSize : TSGEthernetPacketFrameSize); override;
		procedure Write(const Stream : TSGEthernetPacketFrameStream); override;
		procedure ExportInfo(const Stream : TSGTextFileStream); override;
		function Size() : TSGEthernetPacketFrameSize; override;
		function SizeEncapsulated() : TSGEthernetPacketFrameSize;
			protected
		class function ProtocolClass(const ProtocolValue : TSGEnthernetProtocol) : TSGEthernetPacketProtocolFrameClass;
			public
		function Destination() : TSGString;
		function Source() : TSGString;
		function Protocol() : TSGString;
		end;

implementation

uses
	 SaGeEthernetPacketIPv4Frame
	,SaGeStringUtils
	;

function TSGEthernetPacketFrame.SizeEncapsulated() : TSGEthernetPacketFrameSize;
begin
Result := FEthernetSize - SG_ETHERNET_HEADER_SIZE;
end;

function TSGEthernetPacketFrame.Size() : TSGEthernetPacketFrameSize;
begin
Result := FEthernetSize;
end;

class function TSGEthernetPacketFrame.ProtocolClass(const ProtocolValue : TSGEnthernetProtocol) : TSGEthernetPacketProtocolFrameClass;
begin
case ProtocolValue of
SGEP_IPv4 : Result := TSGEthernetPacketIPv4Frame;
else Result := nil;
end;
end;

function TSGEthernetPacketFrame.Destination() : TSGString;
begin
Result := SGEthernetAddesssToString(FEthernetPacketHeader.Destination);
end;

function TSGEthernetPacketFrame.Source() : TSGString;
begin
Result := SGEthernetAddesssToString(FEthernetPacketHeader.Source);
end;

function TSGEthernetPacketFrame.Protocol() : TSGString;
begin
Result := SGEthernetProtocolToStringExtended(FEthernetPacketHeader.Protocol);
end;

constructor TSGEthernetPacketFrame.Create();
begin
inherited;
FillChar(FEthernetPacketHeader, SizeOf(FEthernetPacketHeader), 0);
FProtocolFrame := nil;
FEthernetSize := 0;
FFrameName := 'Ethernet';
end;

destructor TSGEthernetPacketFrame.Destroy();
begin
KillProtocol(FProtocolFrame);
FillChar(FEthernetPacketHeader, SizeOf(FEthernetPacketHeader), 0);
FEthernetSize := 0;
inherited;
end;

procedure TSGEthernetPacketFrame.Read(const Stream : TSGEthernetPacketFrameStream; const BlockSize : TSGEthernetPacketFrameSize);
begin
FEthernetSize := BlockSize;
Stream.ReadBuffer(FEthernetPacketHeader, SizeOf(TSGEthernetHeader));
TSGEthernetPacketProtocolFrame.ReadProtocolClass(
	ProtocolClass(FEthernetPacketHeader.Protocol),
	SizeEncapsulated(),
	FProtocolFrame,
	Stream);
end;

procedure TSGEthernetPacketFrame.Write(const Stream : TSGEthernetPacketFrameStream);
begin
Stream.WriteBuffer(FEthernetPacketHeader, SizeOf(TSGEthernetHeader));
if FProtocolFrame <> nil then
	FProtocolFrame.Write(Stream);
end;

procedure TSGEthernetPacketFrame.ExportInfo(const Stream : TSGTextFileStream);
begin
with Stream do
	begin
	WriteLn('[ethernet]');
	WriteLn(['Frame.Protocol= ', FrameName]);
	WriteLn(['Frame.Size    = ', Size(), ', ', SGGetSizeString(Size(), 'EN')]);
	WriteLn(['Frame.EncapsulatedSize = ', SizeEncapsulated(), ', ', SGGetSizeString(SizeEncapsulated(), 'EN')]);
	WriteLn(['Destination   = ', Destination()]);
	WriteLn(['Source        = ', Source()]);
	WriteLn(['Protocol      = ', Protocol()]);
	WriteLn();
	end;
if FProtocolFrame <> nil then
	FProtocolFrame.ExportInfo(Stream);
end;

end.
