{$INCLUDE SaGe.inc}

unit SaGeEthernetPacketTCPFrame;

interface

uses
	 SaGeBase
	,SaGeTextFileStream
	,SaGeEthernetPacketFrameBase
	,SaGeInternetBase
	
	,Classes
	;

type
	TSGEthernetPacketTCPFrame = class(TSGEthernetPacketProtocolFrame)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FTCPHeader : TSGTCPHeader;
		FData : TMemoryStream;
			public
		procedure Read(const Stream : TSGEthernetPacketDataFrameStream); override;
		procedure Write(const Stream : TSGEthernetPacketDataFrameStream); override;
		procedure ExportInfo(const Stream : TSGTextFileStream); override;
			protected
		procedure FreeData();
		end;
	
implementation

uses
	 SaGeStreamUtils
	;

procedure TSGEthernetPacketTCPFrame.FreeData();
begin
if FData <> nil then
	begin
	FData.Destroy();
	FData := nil;
	end;
end;

constructor TSGEthernetPacketTCPFrame.Create();
begin
inherited;
FillChar(FTCPHeader, SizeOf(TSGTCPHeader), 0);
FData := nil;
end;

destructor TSGEthernetPacketTCPFrame.Destroy();
begin
FreeData();
FillChar(FTCPHeader, SizeOf(TSGTCPHeader), 0);
inherited;
end;

procedure TSGEthernetPacketTCPFrame.Read(const Stream : TSGEthernetPacketDataFrameStream);
var
	EncapsulatedProtocolClass : TSGEthernetPacketProtocolFrameClass = nil;
begin
FreeData();
Stream.ReadBuffer(FTCPHeader, SizeOf(TSGTCPHeader));

end;

procedure TSGEthernetPacketTCPFrame.Write(const Stream : TSGEthernetPacketDataFrameStream);
begin
Stream.WriteBuffer(FTCPHeader, SizeOf(TSGTCPHeader));
if (FData <> nil) and (FData.Size > 0) then
	begin
	FData.Position := 0;
	SGCopyPartStreamToStream(FData, Stream, FData.Size);
	end;
end;

procedure TSGEthernetPacketTCPFrame.ExportInfo(const Stream : TSGTextFileStream);
begin
inherited;
Stream.WriteLn(['Protocol type= ', SGInternetProtocolToString(SGIP_TCP)]);
Stream.WriteLn(['Source port= ', FTCPHeader.SourcePort]);
Stream.WriteLn(['Destination port= ', FTCPHeader.DestinationPort]);
Stream.WriteLn(['Sequence number= ', FTCPHeader.SequenceNumber]);
Stream.WriteLn(['Acknowledgement number= ', FTCPHeader.AcknowledgementNumber]);
Stream.WriteLn(['Reserved bits= ', FTCPHeader.ReservedBitsAsBoolString]);
Stream.WriteLn(['Flags.ECN_Nonce= ', FTCPHeader.ECN_Nonce]);
Stream.WriteLn(['Flags.CWR= ', FTCPHeader.CWR]);
Stream.WriteLn(['Flags.ECN_Echo= ', FTCPHeader.ECN_Echo]);
Stream.WriteLn(['Flags.Urgent= ', FTCPHeader.Urgent]);
Stream.WriteLn(['Flags.Acknowledgement= ', FTCPHeader.Acknowledgement]);
Stream.WriteLn(['Flags.Push= ', FTCPHeader.Push]);
Stream.WriteLn(['Flags.Reset= ', FTCPHeader.Reset]);
Stream.WriteLn(['Flags.Final= ', FTCPHeader.Final]);
Stream.WriteLn(['Flags.WindowSize= ', FTCPHeader.WindowSize]);
Stream.WriteLn(['Flags.Checksum= ', FTCPHeader.Checksum]);
Stream.WriteLn(['Flags.UrgentPointer= ', FTCPHeader.UrgentPointer]);
Stream.WriteLn();

end;

end.
