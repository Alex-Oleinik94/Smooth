{$INCLUDE Smooth.inc}

unit SmoothEthernetPacketFrame;

interface

uses
	 SmoothBase
	,SmoothTextFileStream
	,SmoothEthernetPacketFrameBase
	,SmoothInternetBase
	;

type
	TSEthernetPacketFrame = class(TSEthernetPacketDataFrame)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FEthernetPacketHeader : TSEthernetHeader;
		FProtocolFrame : TSEthernetPacketProtocolFrame;
		FEthernetSize : TSEthernetPacketFrameSize;
			public
		procedure Read(const _Stream : TSEthernetPacketFrameStream; const _BlockSize : TSEthernetPacketFrameSize); override;
		procedure Write(const Stream : TSEthernetPacketFrameStream); override;
		procedure ExportInfo(const Stream : TSTextFileStream); override;
		function Size() : TSEthernetPacketFrameSize; override;
		function SizeEncapsulated() : TSEthernetPacketFrameSize;
		function Description() : TSString; override;
		function CreateStream() : TSEthernetPacketFrameCreatedStream; override;
			protected
		class function ProtocolClass(const ProtocolValue : TSEnthernetProtocol) : TSEthernetPacketProtocolFrameClass;
			public
		function Destination() : TSString;
		function Source() : TSString;
		function Protocol() : TSString;
			public // Headers
		function Ethernet() : PSEthernetHeader;
		function IPv4() : PSIPv4Header;
		function TCPIP() : PSTCPHeader;
		function Data() : TSEthernetPacketFrameStream; override;
		end;

procedure SKill(var Variable : TSEthernetPacketFrame);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

uses
	 SmoothEthernetPacketFrameIPv4
	,SmoothStringUtils
	,SmoothStreamUtils
	;

procedure SKill(var Variable : TSEthernetPacketFrame);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if Variable <> nil then
	begin
	Variable.Destroy();
	Variable := nil;
	end;
end;

// ==========================================
// ======TSEthernetPacketFrame HEADERS======
// ==========================================

function TSEthernetPacketFrame.Ethernet() : PSEthernetHeader;
begin
Result := @FEthernetPacketHeader;
end;

function TSEthernetPacketFrame.IPv4() : PSIPv4Header;
begin
Result := nil;
if (FProtocolFrame <> nil) and (FProtocolFrame is TSEthernetPacketFrameIPv4) then
	Result := (FProtocolFrame as TSEthernetPacketFrameIPv4).IPv4();
end;

function TSEthernetPacketFrame.TCPIP() : PSTCPHeader;
begin
Result := nil;
if (FProtocolFrame <> nil) and (FProtocolFrame is TSEthernetPacketFrameIPv4) then
	Result := (FProtocolFrame as TSEthernetPacketFrameIPv4).TCP();
end;

function TSEthernetPacketFrame.Data() : TSEthernetPacketFrameStream;
begin
if (FProtocolFrame <> nil) then
	Result := FProtocolFrame.Data();
end;

// ==================================
// ======TSEthernetPacketFrame======
// ==================================

function TSEthernetPacketFrame.CreateStream() : TSEthernetPacketFrameCreatedStream;
var
	IncapsulatedStream : TSEthernetPacketFrameCreatedStream = nil;
begin
Result := inherited;
if Result = nil then
	Result := TSEthernetPacketFrameCreatedStream.Create();
Result.Write(FEthernetPacketHeader, SizeOf(FEthernetPacketHeader));
if (FProtocolFrame <> nil) then
	IncapsulatedStream := FProtocolFrame.CreateStream();
if IncapsulatedStream <> nil then
	begin
	IncapsulatedStream.Position := 0;
	SCopyPartStreamToStream(IncapsulatedStream, Result, IncapsulatedStream.Size);
	SKill(IncapsulatedStream);
	end;
end;

function TSEthernetPacketFrame.Description() : TSString;
begin
Result := SEthernetProtocolToString(FEthernetPacketHeader.Protocol);
if IPv4 <> nil then
	Result += ', ' + SInternetProtocolToString(IPv4^.Protocol);
end;

function TSEthernetPacketFrame.SizeEncapsulated() : TSEthernetPacketFrameSize;
begin
Result := FEthernetSize - S_ETHERNET_HEADER_SIZE;
end;

function TSEthernetPacketFrame.Size() : TSEthernetPacketFrameSize;
begin
Result := FEthernetSize;
end;

class function TSEthernetPacketFrame.ProtocolClass(const ProtocolValue : TSEnthernetProtocol) : TSEthernetPacketProtocolFrameClass;
begin
case ProtocolValue of
SEP_IPv4 : Result := TSEthernetPacketFrameIPv4;
else Result := nil;
end;
end;

function TSEthernetPacketFrame.Destination() : TSString;
begin
Result := SEthernetAddesssToString(FEthernetPacketHeader.Destination);
end;

function TSEthernetPacketFrame.Source() : TSString;
begin
Result := SEthernetAddesssToString(FEthernetPacketHeader.Source);
end;

function TSEthernetPacketFrame.Protocol() : TSString;
begin
Result := SEthernetProtocolToStringExtended(FEthernetPacketHeader.Protocol);
end;

constructor TSEthernetPacketFrame.Create();
begin
inherited;
FillChar(FEthernetPacketHeader, SizeOf(FEthernetPacketHeader), 0);
FProtocolFrame := nil;
FEthernetSize := 0;
FFrameName := 'Ethernet';
end;

destructor TSEthernetPacketFrame.Destroy();
begin
KillProtocol(FProtocolFrame);
FillChar(FEthernetPacketHeader, SizeOf(FEthernetPacketHeader), 0);
FEthernetSize := 0;
inherited;
end;

procedure TSEthernetPacketFrame.Read(const _Stream : TSEthernetPacketFrameStream; const _BlockSize : TSEthernetPacketFrameSize);
begin
FEthernetSize := _BlockSize;
_Stream.ReadBuffer(FEthernetPacketHeader, SizeOf(TSEthernetHeader));
TSEthernetPacketProtocolFrame.ReadProtocolClass(
	ProtocolClass(FEthernetPacketHeader.Protocol),
	SizeEncapsulated(),
	FProtocolFrame,
	_Stream);
end;

procedure TSEthernetPacketFrame.Write(const Stream : TSEthernetPacketFrameStream);
begin
Stream.WriteBuffer(FEthernetPacketHeader, SizeOf(TSEthernetHeader));
if FProtocolFrame <> nil then
	FProtocolFrame.Write(Stream);
end;

procedure TSEthernetPacketFrame.ExportInfo(const Stream : TSTextFileStream);
begin
with Stream do
	begin
	WriteLn('[ethernet]');
	WriteLn(['Frame.Protocol= ', FrameName]);
	WriteLn(['Frame.Size    = ', Size(), ', ', SMemorySizeToString(Size(), 'EN')]);
	WriteLn(['Frame.Encapsulated size = ', SizeEncapsulated(), ', ', SMemorySizeToString(SizeEncapsulated(), 'EN')]);
	WriteLn(['Destination   = ', Destination()]);
	WriteLn(['Source        = ', Source()]);
	WriteLn(['Protocol      = ', Protocol()]);
	WriteLn();
	end;
if FProtocolFrame <> nil then
	FProtocolFrame.ExportInfo(Stream);
end;

end.
