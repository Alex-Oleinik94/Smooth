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
			private
		FIPv4Header : TSGIPv4Header;
			public
		procedure Read(const Stream : TSGEthernetPacketDataFrameStream); override;
		procedure Write(const Stream : TSGEthernetPacketDataFrameStream); override;
		procedure ExportInfo(const Stream : TSGTextFileStream); override;
		end;
	
implementation

procedure TSGEthernetPacketIPv4Frame.Read(const Stream : TSGEthernetPacketDataFrameStream);
begin
Stream.ReadBuffer(FIPv4Header, SizeOf(TSGIPv4Header));
end;

procedure TSGEthernetPacketIPv4Frame.Write(const Stream : TSGEthernetPacketDataFrameStream);
begin

end;

procedure TSGEthernetPacketIPv4Frame.ExportInfo(const Stream : TSGTextFileStream);
begin
inherited;
Stream.WriteLn(['Version= ', FIPv4Header.Version]);
Stream.WriteLn(['Header length= ', FIPv4Header.HeaderLength]);
Stream.WriteLn();
end;

end.
