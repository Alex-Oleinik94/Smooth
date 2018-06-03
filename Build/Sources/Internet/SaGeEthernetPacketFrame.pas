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
		procedure Read(const _Stream : TSGEthernetPacketFrameStream; const _BlockSize : TSGEthernetPacketFrameSize); override;
		procedure Write(const Stream : TSGEthernetPacketFrameStream); override;
		procedure ExportInfo(const Stream : TSGTextFileStream); override;
		function Size() : TSGEthernetPacketFrameSize; override;
		function SizeEncapsulated() : TSGEthernetPacketFrameSize;
		function Description() : TSGString; override;
		function CreateStream() : TSGEthernetPacketFrameCreatedStream; override;
			protected
		class function ProtocolClass(const ProtocolValue : TSGEnthernetProtocol) : TSGEthernetPacketProtocolFrameClass;
			public
		function Destination() : TSGString;
		function Source() : TSGString;
		function Protocol() : TSGString;
			public // Headers
		function Ethernet() : PSGEthernetHeader;
		function IPv4() : PSGIPv4Header;
		function TCPIP() : PSGTCPHeader;
		function Data() : TSGEthernetPacketFrameStream; override;
		end;

procedure SGKill(var Variable : TSGEthernetPacketFrame);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

uses
	 SaGeEthernetPacketFrameIPv4
	,SaGeStringUtils
	,SaGeStreamUtils
	;

procedure SGKill(var Variable : TSGEthernetPacketFrame);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if Variable <> nil then
	begin
	Variable.Destroy();
	Variable := nil;
	end;
end;

// ==========================================
// ======TSGEthernetPacketFrame HEADERS======
// ==========================================

function TSGEthernetPacketFrame.Ethernet() : PSGEthernetHeader;
begin
Result := @FEthernetPacketHeader;
end;

function TSGEthernetPacketFrame.IPv4() : PSGIPv4Header;
begin
Result := nil;
if (FProtocolFrame <> nil) and (FProtocolFrame is TSGEthernetPacketFrameIPv4) then
	Result := (FProtocolFrame as TSGEthernetPacketFrameIPv4).IPv4();
end;

function TSGEthernetPacketFrame.TCPIP() : PSGTCPHeader;
begin
Result := nil;
if (FProtocolFrame <> nil) and (FProtocolFrame is TSGEthernetPacketFrameIPv4) then
	Result := (FProtocolFrame as TSGEthernetPacketFrameIPv4).TCP();
end;

function TSGEthernetPacketFrame.Data() : TSGEthernetPacketFrameStream;
begin
if (FProtocolFrame <> nil) then
	Result := FProtocolFrame.Data();
end;

// ==================================
// ======TSGEthernetPacketFrame======
// ==================================

function TSGEthernetPacketFrame.CreateStream() : TSGEthernetPacketFrameCreatedStream;
var
	IncapsulatedStream : TSGEthernetPacketFrameCreatedStream = nil;
begin
Result := inherited;
if Result = nil then
	Result := TSGEthernetPacketFrameCreatedStream.Create();
Result.Write(FEthernetPacketHeader, SizeOf(FEthernetPacketHeader));
if (FProtocolFrame <> nil) then
	IncapsulatedStream := FProtocolFrame.CreateStream();
if IncapsulatedStream <> nil then
	begin
	IncapsulatedStream.Position := 0;
	SGCopyPartStreamToStream(IncapsulatedStream, Result, IncapsulatedStream.Size);
	SGKill(IncapsulatedStream);
	end;
end;

function TSGEthernetPacketFrame.Description() : TSGString;
begin
Result := SGEthernetProtocolToString(FEthernetPacketHeader.Protocol);
if IPv4 <> nil then
	Result += ', ' + SGInternetProtocolToString(IPv4^.Protocol);
end;

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
SGEP_IPv4 : Result := TSGEthernetPacketFrameIPv4;
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

procedure TSGEthernetPacketFrame.Read(const _Stream : TSGEthernetPacketFrameStream; const _BlockSize : TSGEthernetPacketFrameSize);
begin
FEthernetSize := _BlockSize;
_Stream.ReadBuffer(FEthernetPacketHeader, SizeOf(TSGEthernetHeader));
TSGEthernetPacketProtocolFrame.ReadProtocolClass(
	ProtocolClass(FEthernetPacketHeader.Protocol),
	SizeEncapsulated(),
	FProtocolFrame,
	_Stream);
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
	WriteLn(['Frame.Encapsulated size = ', SizeEncapsulated(), ', ', SGGetSizeString(SizeEncapsulated(), 'EN')]);
	WriteLn(['Destination   = ', Destination()]);
	WriteLn(['Source        = ', Source()]);
	WriteLn(['Protocol      = ', Protocol()]);
	WriteLn();
	end;
if FProtocolFrame <> nil then
	FProtocolFrame.ExportInfo(Stream);
end;

end.
