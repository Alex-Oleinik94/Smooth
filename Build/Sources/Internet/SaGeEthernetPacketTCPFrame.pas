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
		FOptions : TSGTCPOptions;
		FData : TMemoryStream;
		FSize : TSGEthernetPacketFrameSize;
			public
		procedure Read(const Stream : TSGEthernetPacketFrameStream; const BlockSize : TSGEthernetPacketFrameSize); override;
		procedure Write(const Stream : TSGEthernetPacketFrameStream); override;
		procedure ExportInfo(const Stream : TSGTextFileStream); override;
		function Size() : TSGEthernetPacketFrameSize; override;
		function SizeEncapsulated() : TSGEthernetPacketFrameSize;
		procedure ExportOptionsInfo(const Stream : TSGTextFileStream); override;
		function DataExists() : TSGBoolean;
		procedure ExportData(const Stream : TSGTextFileStream);
			protected
		procedure FreeData();
		end;
	
implementation

uses
	 SaGeStreamUtils
	,SaGeStringUtils
	,SaGeClasses
	;

function TSGEthernetPacketTCPFrame.Size() : TSGEthernetPacketFrameSize;
begin
Result := FSize;
end;

function TSGEthernetPacketTCPFrame.SizeEncapsulated() : TSGEthernetPacketFrameSize;
begin
Result := FSize - FTCPHeader.HeaderSize;
end;

procedure TSGEthernetPacketTCPFrame.FreeData();
begin
SGKill(FData);
SGKill(FOptions);
end;

constructor TSGEthernetPacketTCPFrame.Create();
begin
inherited;
FillChar(FTCPHeader, SizeOf(TSGTCPHeader), 0);
FData := nil;
FSize := 0;
FOptions := nil;
FFrameName := SGInternetProtocolToString(SGIP_TCP);
end;

destructor TSGEthernetPacketTCPFrame.Destroy();
begin
FreeData();
FillChar(FTCPHeader, SizeOf(TSGTCPHeader), 0);
FSize := 0;
inherited;
end;

procedure TSGEthernetPacketTCPFrame.Read(const Stream : TSGEthernetPacketFrameStream; const BlockSize : TSGEthernetPacketFrameSize);
begin
FreeData();
FSize := BlockSize;
Stream.ReadBuffer(FTCPHeader, SizeOf(TSGTCPHeader));
if (FTCPHeader.HeaderSize - SizeOf(TSGTCPHeader)) > 0 then
	FOptions := SGProtocolOptions(Stream, FTCPHeader.HeaderSize - SizeOf(TSGTCPHeader));

FData := TMemoryStream.Create();
SGCopyPartStreamToStream(Stream, FData, BlockSize - FTCPHeader.HeaderSize);
FData.Position := 0;
end;

procedure TSGEthernetPacketTCPFrame.Write(const Stream : TSGEthernetPacketFrameStream);
begin
Stream.WriteBuffer(FTCPHeader, SizeOf(TSGTCPHeader));
if (FData <> nil) and (FData.Size > 0) then
	begin
	FData.Position := 0;
	SGCopyPartStreamToStream(FData, Stream, FData.Size);
	end;
end;

procedure TSGEthernetPacketTCPFrame.ExportOptionsInfo(const Stream : TSGTextFileStream);
begin
inherited;
Stream.WriteLn(['Options sets   = ', (FOptions <> nil) and (FOptions.Size > 0)]);
if (FOptions <> nil) and (FOptions.Size > 0) then
	begin
	Stream.WriteLn(['Options size   = ', FOptions.Size, ', ', SGGetSizeString(FOptions.Size, 'EN')]);
	Stream.WriteLn(['Options        = 0x', SGStreamToHexString(FOptions), '[hex]']);
	end;
end;

function TSGEthernetPacketTCPFrame.DataExists() : TSGBoolean;
begin
Result := (FData <> nil) and (FData.Size > 0);
end;

procedure TSGEthernetPacketTCPFrame.ExportData(const Stream : TSGTextFileStream);
var
	DataByte : TSGUInt8;
	BytesWrited : TSGUInt8;
	DataString : TSGString;
begin
Stream.WriteLn(['Size   = ', FData.Size, ', ', SGGetSizeString(FData.Size, 'EN')]);
Stream.WriteLn(['Data   =...']);

FData.Position := 0;
BytesWrited := 0;
DataString := '  0x';
while FData.Position < FData.Size do
	begin
	FData.ReadBuffer(DataByte, 1);
	DataString += SGStrByteHex(DataByte, False);
	BytesWrited += 1;
	
	if ((BytesWrited = 64) or (FData.Position = FData.Size)) and (not (DataString = '')) then
		begin
		if FData.Position = FData.Size then
			DataString += '[hexadecimal]';
		Stream.WriteLn([DataString]);
		DataString := '    ';
		BytesWrited := 0;
		end
	else if (BytesWrited mod 16 = 0) then
		DataString += '   '
	else if (BytesWrited mod 4 = 0) then
		DataString += ' ';
	end;
FData.Position := 0;
end;

procedure TSGEthernetPacketTCPFrame.ExportInfo(const Stream : TSGTextFileStream);
begin
inherited;
Stream.WriteLn(['Frame.Protocol     = ', ProtocolName]);
Stream.WriteLn(['Frame.Size         = ', Size(), ', ', SGGetSizeString(Size(), 'EN')]);
Stream.WriteLn(['Frame.EncapsulatedSize= ', SizeEncapsulated(), ', ', SGGetSizeString(SizeEncapsulated(), 'EN')]);
Stream.WriteLn(['Source port        = ', FTCPHeader.SourcePort]);
Stream.WriteLn(['Destination port   = ', FTCPHeader.DestinationPort]);
Stream.WriteLn(['Sequence number    = 0x', SGStr4BytesHex(FTCPHeader.SequenceNumber, False), '[hex]']);
Stream.WriteLn(['Acknowledgement num= 0x', SGStr4BytesHex(FTCPHeader.AcknowledgementNumber, False), '[hex]']);
Stream.WriteLn(['Reserved bits      = ', FTCPHeader.ReservedBitsAsBoolString]);
Stream.WriteLn(['Flags.ECN_Nonce    = ', FTCPHeader.ECN_Nonce]);
Stream.WriteLn(['Flags.CWR          = ', FTCPHeader.CWR]);
Stream.WriteLn(['Flags.ECN_Echo     = ', FTCPHeader.ECN_Echo]);
Stream.WriteLn(['Flags.Urgent       = ', FTCPHeader.Urgent]);
Stream.WriteLn(['Flags.Acknowledgeme= ', FTCPHeader.Acknowledgement]);
Stream.WriteLn(['Flags.Push         = ', FTCPHeader.Push]);
Stream.WriteLn(['Flags.Reset        = ', FTCPHeader.Reset]);
Stream.WriteLn(['Flags.Final        = ', FTCPHeader.Final]);
Stream.WriteLn(['Flags.WindowSize   = ', FTCPHeader.WindowSize, ', ', SGGetSizeString(FTCPHeader.WindowSize, 'EN')]);
Stream.WriteLn(['Flags.Checksum     = 0x', SGStr2BytesHex(FTCPHeader.Checksum, False), '[hex]']);
Stream.WriteLn(['Flags.UrgentPointer= 0x', SGStr2BytesHex(FTCPHeader.UrgentPointer), '[hex], ', FTCPHeader.UrgentPointer, '[dec]']);
ExportOptionsInfo(Stream);
Stream.WriteLn();

Stream.WriteLn(['[data]']);
Stream.WriteLn(['Exists = ', DataExists()]);
if DataExists() then
	ExportData(Stream);
Stream.WriteLn();
end;

end.
