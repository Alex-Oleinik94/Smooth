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
			public
		procedure Read(const Stream : TSGEthernetPacketDataFrameStream); override;
		procedure Write(const Stream : TSGEthernetPacketDataFrameStream); override;
		procedure ExportInfo(const Stream : TSGTextFileStream); override;
			protected
		procedure KillProtocolFrame();
		class function ProtocolClass(const ProtocolValue : TSGInternetProtocol) : TSGEthernetPacketProtocolFrameClass;
		end;
	
implementation

uses
	 SaGeStringUtils
	;

class function TSGEthernetPacketIPv4Frame.ProtocolClass(const ProtocolValue : TSGInternetProtocol) : TSGEthernetPacketProtocolFrameClass;
begin
case ProtocolValue of
SGIP_TCP : Result := nil;
SGIP_UDP : Result := nil;
else Result := nil;
end;
end;

procedure TSGEthernetPacketIPv4Frame.KillProtocolFrame();
begin
if FProtocolFrame <> nil then
	begin
	FProtocolFrame.Destroy();
	FProtocolFrame := nil;
	end;
end;

constructor TSGEthernetPacketIPv4Frame.Create();
begin
inherited;
FillChar(FIPv4Header, SizeOf(FIPv4Header), 0);
FProtocolFrame := nil;
end;

destructor TSGEthernetPacketIPv4Frame.Destroy();
begin
KillProtocolFrame();
FillChar(FIPv4Header, SizeOf(FIPv4Header), 0);
inherited;
end;

procedure TSGEthernetPacketIPv4Frame.Read(const Stream : TSGEthernetPacketDataFrameStream);
var
	EncapsulatedProtocolClass : TSGEthernetPacketProtocolFrameClass = nil;
begin
KillProtocolFrame();
Stream.ReadBuffer(FIPv4Header, SizeOf(TSGIPv4Header));
EncapsulatedProtocolClass := ProtocolClass(FIPv4Header.Protocol);
if EncapsulatedProtocolClass <> nil then
	begin
	FProtocolFrame := EncapsulatedProtocolClass.Create();
	FProtocolFrame.Read(Stream);
	end;
end;

procedure TSGEthernetPacketIPv4Frame.Write(const Stream : TSGEthernetPacketDataFrameStream);
begin

end;

procedure TSGEthernetPacketIPv4Frame.ExportInfo(const Stream : TSGTextFileStream);
begin
inherited;
Stream.WriteLn(['Version= ', FIPv4Header.Version]);
Stream.WriteLn(['Header length= ', FIPv4Header.HeaderLength]);
Stream.WriteLn(['Differentiated services codepoint= ', FIPv4Header.DifferentiatedServicesCodepoint]);
Stream.WriteLn(['Expilit congestion notification= ', FIPv4Header.ExpilitCongestionNotification]);
Stream.WriteLn(['Total length= ', FIPv4Header.TotalLength]);
Stream.WriteLn(['Reserved bit= ', FIPv4Header.ReservedBit]);
Stream.WriteLn(['Dont fragment= ', FIPv4Header.DontFragment]);
Stream.WriteLn(['More fragments= ', FIPv4Header.MoreFragments]);
Stream.WriteLn(['Fragment offset= ', FIPv4Header.FragmentOffset]);
Stream.WriteLn(['Time to live= ', FIPv4Header.TimeToLive]);
Stream.WriteLn(['Protocol= ', SGInternetProtocolToStringExtended(FIPv4Header.Protocol)]);
Stream.WriteLn(['Checksum= 0x', SGStr2BytesHex(FIPv4Header.Checksum, False), '[hex]']);
Stream.WriteLn(['Source= ', SGIPv4AddressToString(FIPv4Header.Source)]);
Stream.WriteLn(['Destination= ', SGIPv4AddressToString(FIPv4Header.Destination)]);
Stream.WriteLn();
end;

end.
