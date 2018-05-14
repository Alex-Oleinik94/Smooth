{$INCLUDE SaGe.inc}

unit SaGeEthernetPacketIPv4Frame;

interface

uses
	 SaGeBase
	,SaGeTextFileStream
	,SaGeEthernetPacketFrameBase
	,SaGeInternetBase
	;

type
	TSGEthernetPacketIPv4Frame = class(TSGEthernetPacketProtocolFrame)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FIPv4Header : TSGIPv4Header;
		FProtocolFrame : TSGEthernetPacketProtocolFrame;
		FProtocolOptions : TSGIPv4Options;
			public
		procedure Read(const Stream : TSGEthernetPacketFrameStream; const BlockSize : TSGEthernetPacketFrameSize); override;
		procedure Write(const Stream : TSGEthernetPacketFrameStream); override;
		procedure ExportInfo(const Stream : TSGTextFileStream); override;
		function Size() : TSGEthernetPacketFrameSize; override;
		function SizeEncapsulated() : TSGEthernetPacketFrameSize;
		procedure ExportOptionsInfo(const Stream : TSGTextFileStream); override;
			protected
		procedure KillProtocolFrame();
		class function ProtocolClass(const ProtocolValue : TSGInternetProtocol) : TSGEthernetPacketProtocolFrameClass;
		end;
	
implementation

uses
	 SaGeStreamUtils
	,SaGeStringUtils
	,SaGeEthernetPacketTCPFrame
	;

class function TSGEthernetPacketIPv4Frame.ProtocolClass(const ProtocolValue : TSGInternetProtocol) : TSGEthernetPacketProtocolFrameClass;
begin
case ProtocolValue of
SGIP_TCP : Result := TSGEthernetPacketTCPFrame;
SGIP_UDP : Result := nil;
else Result := nil;
end;
end;

procedure TSGEthernetPacketIPv4Frame.KillProtocolFrame();
begin
if FProtocolOptions <> nil then
	begin
	FProtocolOptions.Destroy();
	FProtocolOptions := nil;
	end;
KillProtocol(FProtocolFrame);
end;

constructor TSGEthernetPacketIPv4Frame.Create();
begin
inherited;
FillChar(FIPv4Header, SizeOf(TSGIPv4Header), 0);
FProtocolFrame := nil;
FProtocolOptions := nil;
FFrameName := SGEthernetProtocolToString(SGEP_IPv4);
end;

destructor TSGEthernetPacketIPv4Frame.Destroy();
begin
KillProtocolFrame();
FillChar(FIPv4Header, SizeOf(TSGIPv4Header), 0);
inherited;
end;

procedure TSGEthernetPacketIPv4Frame.Read(const Stream : TSGEthernetPacketFrameStream; const BlockSize : TSGEthernetPacketFrameSize);
begin
KillProtocolFrame();
Stream.ReadBuffer(FIPv4Header, SizeOf(TSGIPv4Header));
FProtocolOptions := SGProtocolOptions(Stream, FIPv4Header.HeaderSize - SizeOf(TSGIPv4Header));
ReadProtocolClass(
	ProtocolClass(FIPv4Header.Protocol),
	SizeEncapsulated(),
	FProtocolFrame,
	Stream);
end;

function TSGEthernetPacketIPv4Frame.SizeEncapsulated() : TSGEthernetPacketFrameSize;
begin
Result := FIPv4Header.TotalSize - FIPv4Header.HeaderSize;
end;

function TSGEthernetPacketIPv4Frame.Size() : TSGEthernetPacketFrameSize;
begin
Result := FIPv4Header.TotalSize;
end;

procedure TSGEthernetPacketIPv4Frame.Write(const Stream : TSGEthernetPacketFrameStream);
begin
Stream.WriteBuffer(FIPv4Header, SizeOf(TSGIPv4Header));
SGProtocolOptions(FProtocolOptions, Stream);
if FProtocolFrame <> nil then
	FProtocolFrame.Write(Stream);
end;

procedure TSGEthernetPacketIPv4Frame.ExportOptionsInfo(const Stream : TSGTextFileStream);
begin
Stream.WriteLn(['Options sets   = ', (FProtocolOptions <> nil) and (FProtocolOptions.Size > 0)]);
if (FProtocolOptions <> nil) and (FProtocolOptions.Size > 0) then
	begin
	Stream.WriteLn(['Options size   = ', FProtocolOptions.Size, ', ', SGGetSizeString(FProtocolOptions.Size, 'EN')]);
	Stream.WriteLn(['Options        = 0x', SGStreamToHexString(FProtocolOptions), '[hex]']);
	end;
end;

procedure TSGEthernetPacketIPv4Frame.ExportInfo(const Stream : TSGTextFileStream);
begin
inherited;
Stream.WriteLn(['Frame.Protocol = ', ProtocolName]);
Stream.WriteLn(['Frame.Size     = ', Size(), ', ', SGGetSizeString(Size(), 'EN')]);
Stream.WriteLn(['Frame.EncapsulatedSize= ', SizeEncapsulated(), ', ', SGGetSizeString(SizeEncapsulated(), 'EN')]);
Stream.WriteLn(['Version        = ', FIPv4Header.Version]);
Stream.WriteLn(['Header size    = ', FIPv4Header.HeaderSize]);
Stream.WriteLn(['Differentiated services codepoint= ', FIPv4Header.DifferentiatedServicesCodepoint]);
Stream.WriteLn(['Expilit congestion notification= ', FIPv4Header.ExpilitCongestionNotification]);
Stream.WriteLn(['Total size     = ', FIPv4Header.TotalSize]);
Stream.WriteLn(['Reserved bit   = ', FIPv4Header.ReservedBit]);
Stream.WriteLn(['Dont fragment  = ', FIPv4Header.DontFragment]);
Stream.WriteLn(['More fragments = ', FIPv4Header.MoreFragments]);
Stream.WriteLn(['Fragment offset= ', FIPv4Header.FragmentOffset]);
Stream.WriteLn(['Time to live   = ', FIPv4Header.TimeToLive]);
Stream.WriteLn(['Protocol       = ', SGInternetProtocolToStringExtended(FIPv4Header.Protocol)]);
Stream.WriteLn(['Checksum       = 0x', SGStr2BytesHex(FIPv4Header.Checksum, False), '[hex]']);
Stream.WriteLn(['Source         = ', SGIPv4AddressToString(FIPv4Header.Source)]);
Stream.WriteLn(['Destination    = ', SGIPv4AddressToString(FIPv4Header.Destination)]);
ExportOptionsInfo(Stream);
Stream.WriteLn();
if FProtocolFrame <> nil then
	FProtocolFrame.ExportInfo(Stream);
end;

end.
