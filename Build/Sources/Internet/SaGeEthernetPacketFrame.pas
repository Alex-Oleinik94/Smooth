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
			public
		procedure Read(const Stream : TSGEthernetPacketDataFrameStream); override;
		procedure Write(const Stream : TSGEthernetPacketDataFrameStream); override;
		procedure ExportInfo(const Stream : TSGTextFileStream); override;
			protected
		procedure KillProtocolFrame();
		class function ProtocolClass(const ProtocolValue : TSGEnthernetProtocol) : TSGEthernetPacketProtocolFrameClass;
			public
		function Destination() : TSGString;
		function Source() : TSGString;
		function Protocol() : TSGString;
		end;
	
implementation

uses
	 SaGeEthernetPacketIPv4Frame
	;

class function TSGEthernetPacketFrame.ProtocolClass(const ProtocolValue : TSGEnthernetProtocol) : TSGEthernetPacketProtocolFrameClass;
begin
case ProtocolValue of
SGEP_IPv4 : Result := TSGEthernetPacketIPv4Frame;
else Result := nil;
end;
end;

procedure TSGEthernetPacketFrame.KillProtocolFrame();
begin
if FProtocolFrame <> nil then
	begin
	FProtocolFrame.Destroy();
	FProtocolFrame := nil;
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
end;

destructor TSGEthernetPacketFrame.Destroy();
begin
KillProtocolFrame();
FillChar(FEthernetPacketHeader, SizeOf(FEthernetPacketHeader), 0);
inherited;
end;

procedure TSGEthernetPacketFrame.Read(const Stream : TSGEthernetPacketDataFrameStream);
var
	EthernetPacketProtocol : TSGEthernetPacketProtocolFrameClass = nil;
begin
KillProtocolFrame();
Stream.ReadBuffer(FEthernetPacketHeader, SizeOf(TSGEthernetHeader));
EthernetPacketProtocol := ProtocolClass(FEthernetPacketHeader.Protocol);
if EthernetPacketProtocol <> nil then
	begin
	FProtocolFrame := EthernetPacketProtocol.Create();
	FProtocolFrame.Read(Stream);
	end;
end;

procedure TSGEthernetPacketFrame.Write(const Stream : TSGEthernetPacketDataFrameStream);
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
	WriteLn(['Destination = ', Destination()]);
	WriteLn(['Source      = ', Source()]);
	WriteLn(['Protocol    = ', Protocol()]);
	WriteLn();
	end;
if FProtocolFrame <> nil then
	FProtocolFrame.ExportInfo(Stream);
end;

end.
