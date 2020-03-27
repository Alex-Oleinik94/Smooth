{$INCLUDE Smooth.inc}

unit SmoothEthernetPacketFrameIPv4;

interface

uses
	 SmoothBase
	,SmoothTextFileStream
	,SmoothEthernetPacketFrameBase
	,SmoothInternetBase
	;

type
	TSEthernetPacketFrameIPv4 = class(TSEthernetPacketProtocolFrame)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FIPv4Header : TSIPv4Header;
		FProtocolFrame : TSEthernetPacketProtocolFrame;
		FProtocolOptions : TSIPv4Options;
			public
		procedure Read(const Stream : TSEthernetPacketFrameStream; const BlockSize : TSEthernetPacketFrameSize); override;
		procedure Write(const Stream : TSEthernetPacketFrameStream); override;
		procedure ExportInfo(const Stream : TSTextFileStream); override;
		function Size() : TSEthernetPacketFrameSize; override;
		function SizeEncapsulated() : TSEthernetPacketFrameSize;
		procedure ExportOptionsInfo(const Stream : TSTextFileStream); override;
		function CreateStream() : TSEthernetPacketFrameCreatedStream; override;
			protected
		procedure KillProtocolFrame();
		class function ProtocolClass(const ProtocolValue : TSInternetProtocol) : TSEthernetPacketProtocolFrameClass;
			public // Headers
		function IPv4() : PSIPv4Header;
		function TCP() : PSTCPHeader;
		function Data() : TSEthernetPacketFrameStream; override;
		end;
	
implementation

uses
	 SmoothStreamUtils
	,SmoothStringUtils
	,SmoothEthernetPacketFrameTCP
	;

// ==============================================
// ======TSEthernetPacketFrameIPv4 HEADERS======
// ==============================================

function TSEthernetPacketFrameIPv4.IPv4() : PSIPv4Header;
begin
Result := @FIPv4Header;
end;

function TSEthernetPacketFrameIPv4.TCP() : PSTCPHeader;
begin
Result := nil;
if (FProtocolFrame <> nil) and (FProtocolFrame is TSEthernetPacketFrameTCP) then
	Result := (FProtocolFrame as TSEthernetPacketFrameTCP).TCP();
end;

function TSEthernetPacketFrameIPv4.Data() : TSEthernetPacketFrameStream;
begin
if (FProtocolFrame <> nil) then
	Result := FProtocolFrame.Data();
end;

// ======================================
// ======TSEthernetPacketFrameIPv4======
// ======================================

function TSEthernetPacketFrameIPv4.CreateStream() : TSEthernetPacketFrameCreatedStream;
var
	IncapsulatedStream : TSEthernetPacketFrameCreatedStream = nil;
begin
Result := inherited;
if Result = nil then
	Result := TSEthernetPacketFrameCreatedStream.Create();
Result.Write(FIPv4Header, SizeOf(FIPv4Header));
if (FProtocolOptions <> nil) then
	begin
	FProtocolOptions.Position := 0;
	SCopyPartStreamToStream(FProtocolOptions, Result, FProtocolOptions.Size);
	end;
if (FProtocolFrame <> nil) then
	IncapsulatedStream := FProtocolFrame.CreateStream();
if IncapsulatedStream <> nil then
	begin
	IncapsulatedStream.Position := 0;
	SCopyPartStreamToStream(IncapsulatedStream, Result, IncapsulatedStream.Size);
	SKill(IncapsulatedStream);
	end;
end;

class function TSEthernetPacketFrameIPv4.ProtocolClass(const ProtocolValue : TSInternetProtocol) : TSEthernetPacketProtocolFrameClass;
begin
case ProtocolValue of
SIP_TCP : Result := TSEthernetPacketFrameTCP;
SIP_UDP : Result := nil;
else Result := nil;
end;
end;

procedure TSEthernetPacketFrameIPv4.KillProtocolFrame();
begin
if FProtocolOptions <> nil then
	begin
	FProtocolOptions.Destroy();
	FProtocolOptions := nil;
	end;
KillProtocol(FProtocolFrame);
end;

constructor TSEthernetPacketFrameIPv4.Create();
begin
inherited;
FillChar(FIPv4Header, SizeOf(TSIPv4Header), 0);
FProtocolFrame := nil;
FProtocolOptions := nil;
FFrameName := SEthernetProtocolToString(SEP_IPv4);
end;

destructor TSEthernetPacketFrameIPv4.Destroy();
begin
KillProtocolFrame();
FillChar(FIPv4Header, SizeOf(TSIPv4Header), 0);
inherited;
end;

procedure TSEthernetPacketFrameIPv4.Read(const Stream : TSEthernetPacketFrameStream; const BlockSize : TSEthernetPacketFrameSize);
begin
KillProtocolFrame();
Stream.ReadBuffer(FIPv4Header, SizeOf(TSIPv4Header));
FProtocolOptions := SProtocolOptions(Stream, FIPv4Header.HeaderSize - SizeOf(TSIPv4Header));
ReadProtocolClass(
	ProtocolClass(FIPv4Header.Protocol),
	SizeEncapsulated(),
	FProtocolFrame,
	Stream);
end;

function TSEthernetPacketFrameIPv4.SizeEncapsulated() : TSEthernetPacketFrameSize;
begin
Result := FIPv4Header.TotalSize - FIPv4Header.HeaderSize;
end;

function TSEthernetPacketFrameIPv4.Size() : TSEthernetPacketFrameSize;
begin
Result := FIPv4Header.TotalSize;
end;

procedure TSEthernetPacketFrameIPv4.Write(const Stream : TSEthernetPacketFrameStream);
begin
Stream.WriteBuffer(FIPv4Header, SizeOf(TSIPv4Header));
SProtocolOptions(FProtocolOptions, Stream);
if FProtocolFrame <> nil then
	FProtocolFrame.Write(Stream);
end;

procedure TSEthernetPacketFrameIPv4.ExportOptionsInfo(const Stream : TSTextFileStream);
begin
Stream.WriteLn(['Options sets   = ', (FProtocolOptions <> nil) and (FProtocolOptions.Size > 0)]);
if (FProtocolOptions <> nil) and (FProtocolOptions.Size > 0) then
	begin
	Stream.WriteLn(['Options size   = ', FProtocolOptions.Size, ', ', SGetSizeString(FProtocolOptions.Size, 'EN')]);
	Stream.WriteLn(['Options        = 0x', SStreamToHexString(FProtocolOptions), '[hex]']);
	end;
end;

procedure TSEthernetPacketFrameIPv4.ExportInfo(const Stream : TSTextFileStream);
begin
inherited;
Stream.WriteLn(['Frame.Protocol = ', ProtocolName]);
Stream.WriteLn(['Frame.Size     = ', Size(), ', ', SGetSizeString(Size(), 'EN')]);
Stream.WriteLn(['Frame.Encapsulated size= ', SizeEncapsulated(), ', ', SGetSizeString(SizeEncapsulated(), 'EN')]);
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
Stream.WriteLn(['Protocol       = ', SInternetProtocolToStringExtended(FIPv4Header.Protocol)]);
Stream.WriteLn(['Checksum       = 0x', SStr2BytesHex(FIPv4Header.Checksum, False), '[hex]']);
Stream.WriteLn(['Source         = ', SIPv4AddressToString(FIPv4Header.Source)]);
Stream.WriteLn(['Destination    = ', SIPv4AddressToString(FIPv4Header.Destination)]);
ExportOptionsInfo(Stream);
Stream.WriteLn();
if FProtocolFrame <> nil then
	FProtocolFrame.ExportInfo(Stream);
end;

end.
