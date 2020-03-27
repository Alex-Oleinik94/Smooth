{$INCLUDE Smooth.inc}

unit SmoothEthernetPacketFrameTCP;

interface

uses
	 SmoothBase
	,SmoothTextFileStream
	,SmoothEthernetPacketFrameBase
	,SmoothInternetBase
	
	,Classes
	;

type
	TSEthernetPacketFrameTCP = class(TSEthernetPacketProtocolFrame)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FTCPHeader : TSTCPHeader;
		FOptions : TSTCPOptions;
		FData : TMemoryStream;
		FSize : TSEthernetPacketFrameSize;
			public
		procedure Read(const Stream : TSEthernetPacketFrameStream; const BlockSize : TSEthernetPacketFrameSize); override;
		procedure Write(const Stream : TSEthernetPacketFrameStream); override;
		procedure ExportInfo(const Stream : TSTextFileStream); override;
		function Size() : TSEthernetPacketFrameSize; override;
		function SizeEncapsulated() : TSEthernetPacketFrameSize;
		procedure ExportOptionsInfo(const Stream : TSTextFileStream); override;
		function CreateStream() : TSEthernetPacketFrameCreatedStream; override;
		function DataExists() : TSBoolean;
		procedure ExportData(const Stream : TSTextFileStream);
			protected
		procedure FreeData();
			public // Headers
		function TCP() : PSTCPHeader;
		function Data() : TSEthernetPacketFrameStream; override;
		end;
	
implementation

uses
	 SmoothStreamUtils
	,SmoothStringUtils
	,SmoothBaseClasses
	;

// =============================================
// ======TSEthernetPacketFrameTCP HEADERS======
// =============================================

function TSEthernetPacketFrameTCP.TCP() : PSTCPHeader;
begin
Result := @FTCPHeader;
end;

function TSEthernetPacketFrameTCP.Data() : TSEthernetPacketFrameStream;
begin
Result := FData;
end;

// =====================================
// ======TSEthernetPacketFrameTCP======
// =====================================

function TSEthernetPacketFrameTCP.CreateStream() : TSEthernetPacketFrameCreatedStream;
begin
Result := inherited;
if Result = nil then
	Result := TSEthernetPacketFrameCreatedStream.Create();
Result.Write(FTCPHeader, SizeOf(FTCPHeader));
if (FOptions <> nil) then
	begin
	FOptions.Position := 0;
	SCopyPartStreamToStream(FOptions, Result, FOptions.Size);
	end;
if FData <> nil then
	begin
	FData.Position := 0;
	SCopyPartStreamToStream(FData, Result, FData.Size);
	end;
end;

function TSEthernetPacketFrameTCP.Size() : TSEthernetPacketFrameSize;
begin
Result := FSize;
end;

function TSEthernetPacketFrameTCP.SizeEncapsulated() : TSEthernetPacketFrameSize;
begin
Result := FSize - FTCPHeader.HeaderSize;
end;

procedure TSEthernetPacketFrameTCP.FreeData();
begin
SKill(FData);
SKill(FOptions);
end;

constructor TSEthernetPacketFrameTCP.Create();
begin
inherited;
FillChar(FTCPHeader, SizeOf(TSTCPHeader), 0);
FData := nil;
FSize := 0;
FOptions := nil;
FFrameName := SInternetProtocolToString(SIP_TCP);
end;

destructor TSEthernetPacketFrameTCP.Destroy();
begin
FreeData();
FillChar(FTCPHeader, SizeOf(TSTCPHeader), 0);
FSize := 0;
inherited;
end;

procedure TSEthernetPacketFrameTCP.Read(const Stream : TSEthernetPacketFrameStream; const BlockSize : TSEthernetPacketFrameSize);
begin
FreeData();
FSize := BlockSize;
Stream.ReadBuffer(FTCPHeader, SizeOf(TSTCPHeader));
if (FTCPHeader.HeaderSize - SizeOf(TSTCPHeader)) > 0 then
	FOptions := SProtocolOptions(Stream, FTCPHeader.HeaderSize - SizeOf(TSTCPHeader));

FData := TMemoryStream.Create();
SCopyPartStreamToStream(Stream, FData, BlockSize - FTCPHeader.HeaderSize);
FData.Position := 0;
end;

procedure TSEthernetPacketFrameTCP.Write(const Stream : TSEthernetPacketFrameStream);
begin
Stream.WriteBuffer(FTCPHeader, SizeOf(TSTCPHeader));
if (FData <> nil) and (FData.Size > 0) then
	begin
	FData.Position := 0;
	SCopyPartStreamToStream(FData, Stream, FData.Size);
	end;
end;

procedure TSEthernetPacketFrameTCP.ExportOptionsInfo(const Stream : TSTextFileStream);
begin
inherited;
Stream.WriteLn(['Options sets   = ', (FOptions <> nil) and (FOptions.Size > 0)]);
if (FOptions <> nil) and (FOptions.Size > 0) then
	begin
	Stream.WriteLn(['Options size   = ', FOptions.Size, ', ', SGetSizeString(FOptions.Size, 'EN')]);
	Stream.WriteLn(['Options        = 0x', SStreamToHexString(FOptions), '[hex]']);
	end;
end;

function TSEthernetPacketFrameTCP.DataExists() : TSBoolean;
begin
Result := (FData <> nil) and (FData.Size > 0);
end;

procedure TSEthernetPacketFrameTCP.ExportData(const Stream : TSTextFileStream);
var
	DataByte : TSUInt8;
	BytesWrited : TSUInt8;
	DataString : TSString;
begin
Stream.WriteLn(['Size   = ', FData.Size, ', ', SGetSizeString(FData.Size, 'EN')]);
Stream.WriteLn(['Data   =...']);

FData.Position := 0;
BytesWrited := 0;
DataString := '  0x';
while FData.Position < FData.Size do
	begin
	FData.ReadBuffer(DataByte, 1);
	DataString += SStrByteHex(DataByte, False);
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

procedure TSEthernetPacketFrameTCP.ExportInfo(const Stream : TSTextFileStream);
begin
inherited;
Stream.WriteLn(['Frame.Protocol     = ', ProtocolName]);
Stream.WriteLn(['Frame.Size         = ', Size(), ', ', SGetSizeString(Size(), 'EN')]);
Stream.WriteLn(['Frame.Encapsulated size= ', SizeEncapsulated(), ', ', SGetSizeString(SizeEncapsulated(), 'EN')]);
Stream.WriteLn(['Source port        = ', FTCPHeader.SourcePort]);
Stream.WriteLn(['Destination port   = ', FTCPHeader.DestinationPort]);
Stream.WriteLn(['Sequence number    = 0x', SStr4BytesHex(FTCPHeader.SequenceNumber, False), '[hex]']);
Stream.WriteLn(['Acknowledgement num= 0x', SStr4BytesHex(FTCPHeader.AcknowledgementNumber, False), '[hex]']);
Stream.WriteLn(['Reserved bits      = ', FTCPHeader.ReservedBitsAsBoolString]);
Stream.WriteLn(['Flags.ECN_Nonce    = ', FTCPHeader.ECN_Nonce]);
Stream.WriteLn(['Flags.CWR          = ', FTCPHeader.CWR]);
Stream.WriteLn(['Flags.ECN_Echo     = ', FTCPHeader.ECN_Echo]);
Stream.WriteLn(['Flags.Urgent       = ', FTCPHeader.Urgent]);
Stream.WriteLn(['Flags.Acknowledgeme= ', FTCPHeader.Acknowledgement]);
Stream.WriteLn(['Flags.Push         = ', FTCPHeader.Push]);
Stream.WriteLn(['Flags.Reset        = ', FTCPHeader.Reset]);
Stream.WriteLn(['Flags.Final        = ', FTCPHeader.Final]);
Stream.WriteLn(['Flags.WindowSize   = ', FTCPHeader.WindowSize, ', ', SGetSizeString(FTCPHeader.WindowSize, 'EN')]);
Stream.WriteLn(['Flags.Checksum     = 0x', SStr2BytesHex(FTCPHeader.Checksum, False), '[hex]']);
Stream.WriteLn(['Flags.UrgentPointer= 0x', SStr2BytesHex(FTCPHeader.UrgentPointer), '[hex], ', FTCPHeader.UrgentPointer, '[dec]']);
ExportOptionsInfo(Stream);
Stream.WriteLn();

Stream.WriteLn(['[data]']);
Stream.WriteLn(['Exists = ', DataExists()]);
if DataExists() then
	ExportData(Stream);
Stream.WriteLn();
end;

end.
