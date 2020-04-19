{$INCLUDE Smooth.inc}

unit SmoothInternetConnection;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothDateTime
	,SmoothEthernetPacketFrame
	,SmoothInternetPacketStorage
	,SmoothTextStream
	,SmoothInternetBase
	,SmoothCriticalSection
	,SmoothInternetPacketCaptureHandler
	
	,Classes
	;
type
	TSInternetConnection = class;
	
	TSInternetConnectionSizeInt = TSUInt64;
	TSConnectionDataType = (
		SNoData,
		SSenderData,
		SRecieverData);
	TSConnectionStatus = (
		SNoStatus,
		SStartStatus,
		SFinalStatus);
type
	ISConnectionsHandler = interface(ISInterface)
		['{57ac272a-c488-41c5-adae-122ee2dc0540}']
		function HandleConnectionData(const Connection : TSInternetConnection; const DataType : TSConnectionDataType; const Data : TStream) : TSBoolean;
		procedure HandleConnectionStatus(const Connection : TSInternetConnection; const Status : TSConnectionStatus);
		end;
type
	TSInternetConnection = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FCritacalSection : TSCriticalSection;
		FPacketStorage : TSInternetPacketStorage;
		FModeDataTransfer : TSBoolean;
		FModePacketStorage : TSBoolean;
		FModeRuntimeDataDumper : TSBoolean;
		FModeRuntimePacketDumper : TSBoolean;
		FIdentifier : TSString;
		FFictitious : TSBoolean;
		
		FTimeFirstPacket : TSTime;
		FDateFirstPacket : TSDateTime;
		FTimeLastPacket : TSTime;
		FDateLastPacket : TSDateTime;
		FSecondsMeansConnectionActive : TSUInt16;
		FFirstPacketIsSelfSender : TSBoolean;
		
		FDataSize : TSInternetConnectionSizeInt;
		FPacketCount : TSInternetConnectionSizeInt;
		
		FDeviceIdentificator : TSInternetPacketCaptureHandlerDeviceIdentificator;
		FDeviceIPv4Supported : TSBoolean;
		FDeviceIPv4Net  : TSIPv4Address;
		FDeviceIPv4Mask : TSIPv4Address;
		
		// Data ftansfer
		FConnectionsHandler : ISConnectionsHandler;
		
		// Dumper modes
		FDumpDirectory : TSString;
		FConnectionDumpDirectory : TSString;
		FConnectionDataDumpDirectory : TSString;
		FConnectionPacketDumpDirectory : TSString;
		FPacketDataFileExtension : TSString;
		FPacketInfoFileExtension : TSString;
			protected
		procedure CreateConnectionDumpDirectory(); virtual;
		function PrintableTextString(const FileSystemSuport : TSBoolean = True) : TSString;
		procedure DumpPacketFiles(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame; const InfoFileName, DataFileName : TSString);
		procedure DumpPacketInfoFile(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame; const InfoFileName : TSString);
		procedure DumpPacketDataFile(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame; const DataFileName : TSString);
		function AddressCorrespondsToNetMask(const AddressValue : TSIPv4Address) : TSBoolean;
		function MinimumOneModeEnabled() : TSBoolean;
		function MinimumOneDataModeEnabled() : TSBoolean;
		function Finalized() : TSBoolean; virtual;
			public
		class function ProtocolAbbreviation(const FileSystemSuport : TSBoolean = False) : TSString; virtual;
		function RenameConnectionDirectoryIncludeSize() : TSBoolean;
		procedure PrintTextInfo(const TextStream : TSTextStream; const FileSystemSuport : TSBoolean = False); virtual;
		function PacketPushed(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame) : TSBoolean; virtual;
		class function PacketCompatible(const Packet : TSEthernetPacketFrame) : TSBoolean; virtual;
		procedure AddDeviceIPv4(const Net, Mask : TSIPv4Address); virtual;
		procedure MakeFictitious(); virtual;
			public
		property DataSize : TSInternetConnectionSizeInt read FDataSize;
		property PacketCount : TSInternetConnectionSizeInt read FPacketCount;
		property TimeFirstPacket : TSTime read FTimeFirstPacket;
		property DateFirstPacket : TSDateTime read FDateFirstPacket;
		property ModeDataTransfer : TSBoolean read FModeDataTransfer write FModeDataTransfer;
		property ModePacketStorage : TSBoolean read FModePacketStorage write FModePacketStorage;
		property ModeRuntimeDataDumper : TSBoolean read FModeRuntimeDataDumper write FModeRuntimeDataDumper;
		property ModeRuntimePacketDumper : TSBoolean read FModeRuntimePacketDumper write FModeRuntimePacketDumper;
		property DumpDirectory : TSString read FDumpDirectory write FDumpDirectory;
		property FirstPacketIsSelfSender : TSBoolean read FFirstPacketIsSelfSender write FFirstPacketIsSelfSender;
		property ConnectionDumpDirectory : TSString read FConnectionDumpDirectory;
		property PacketInfoFileExtension : TSString read FPacketInfoFileExtension write FPacketInfoFileExtension;
		property PacketDataFileExtension : TSString read FPacketDataFileExtension write FPacketDataFileExtension;
		property Identifier : TSString read FIdentifier write FIdentifier;
		property ConnectionsHandler : ISConnectionsHandler read FConnectionsHandler write FConnectionsHandler;
		property Fictitious : TSBoolean read FFictitious write FFictitious;
		property DeviceIdentificator : TSInternetPacketCaptureHandlerDeviceIdentificator read FDeviceIdentificator write FDeviceIdentificator;
		end;
	TSInternetConnectionClass = class of TSInternetConnection;

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSInternetConnectionListHelper}
{$DEFINE DATATYPE_LIST        := TSInternetConnectionList}
{$DEFINE DATATYPE             := TSInternetConnection}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSInternetConnectionClassListHelper}
{$DEFINE DATATYPE_LIST        := TSInternetConnectionClassList}
{$DEFINE DATATYPE             := TSInternetConnectionClass}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

procedure SKill(var Variable : TSInternetConnection); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothStringTextStream
	,SmoothFileUtils
	,SmoothTextFileStream
	,SmoothStreamUtils
	,SmoothStringUtils
	,SmoothInternetDumperBase
	;

procedure SKill(var Variable : TSInternetConnection); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if Variable <> nil then
	begin
	Variable.Destroy();
	Variable := nil;
	end;
end;

function TSInternetConnection.Finalized() : TSBoolean;
begin
Result := False;
end;

function TSInternetConnection.MinimumOneDataModeEnabled() : TSBoolean;
begin
Result := FModeDataTransfer or FModeRuntimeDataDumper;
end;

function TSInternetConnection.MinimumOneModeEnabled() : TSBoolean;
begin
Result := FModeDataTransfer or FModePacketStorage or FModeRuntimeDataDumper or FModeRuntimePacketDumper;
end;

function TSInternetConnection.AddressCorrespondsToNetMask(const AddressValue : TSIPv4Address) : TSBoolean;
begin
Result := False;
if FDeviceIPv4Supported then
	Result := (FDeviceIPv4Mask.Address and AddressValue.Address) = FDeviceIPv4Net.Address;
end;

procedure TSInternetConnection.DumpPacketInfoFile(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame; const InfoFileName : TSString);
var
	TextStream : TSTextFileStream = nil;
begin
TextStream := TSTextFileStream.Create(InfoFileName);
TextStream.WriteLn('[packet]');
TextStream.WriteLn(['DataTime = ', SDateTimeCorrectionString(Date, Time, False)]);
TextStream.WriteLn(['Size     = ', SMemorySizeToString(Packet.Size, 'EN')]);
TextStream.WriteLn();
Packet.ExportInfo(TextStream);
SKill(TextStream);
end;

procedure TSInternetConnection.DumpPacketDataFile(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame; const DataFileName : TSString);
var
	FileStream : TFileStream = nil;
	Stream : TMemoryStream = nil;
begin
if (Packet <> nil) then
	Stream := Packet.CreateStream();
if (Stream <> nil) then
	begin
	FileStream := TFileStream.Create(DataFileName, fmCreate);
	Stream.Position := 0;
	SCopyPartStreamToStream(Stream, FileStream, Stream.Size);
	SKill(FileStream);
	SKill(Stream);
	end;
end;

procedure TSInternetConnection.DumpPacketFiles(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame; const InfoFileName, DataFileName : TSString);
begin
DumpPacketInfoFile(Time, Date, Packet, InfoFileName);
DumpPacketDataFile(Time, Date, Packet, DataFileName);
end;

function TSInternetConnection.PrintableTextString(const FileSystemSuport : TSBoolean = True) : TSString;
var
	StringTextSteam : TSStringTextStream = nil;
begin
Result := '';
StringTextSteam := TSStringTextStream.Create();
if FileSystemSuport and (ProtocolAbbreviation(FileSystemSuport) <> '') then
	Result += ProtocolAbbreviation(FileSystemSuport) + ' ';
if FileSystemSuport and (Identifier <> '') then
	Result += '{' + Identifier + '} ';
PrintTextInfo(StringTextSteam, FileSystemSuport);
Result += StringTextSteam.Value;
SKill(StringTextSteam);
end;

procedure TSInternetConnection.CreateConnectionDumpDirectory();
begin
if FModeRuntimeDataDumper or FModeRuntimePacketDumper then
	begin
	FConnectionDumpDirectory := SFreeDirectoryName(FDumpDirectory + DirectorySeparator + PrintableTextString(), '');
	SMakeDirectory(FConnectionDumpDirectory);
	end;
if FModeRuntimeDataDumper then
	begin
	FConnectionDataDumpDirectory := SFreeDirectoryName(FConnectionDumpDirectory + DirectorySeparator + 'Data', '');
	SMakeDirectory(FConnectionDataDumpDirectory);
	end;
if FModeRuntimePacketDumper then
	begin
	FConnectionPacketDumpDirectory := SFreeDirectoryName(FConnectionDumpDirectory + DirectorySeparator + 'Packets', '');
	SMakeDirectory(FConnectionPacketDumpDirectory);
	end;
end;

procedure TSInternetConnection.AddDeviceIPv4(const Net, Mask : TSIPv4Address);
begin
FDeviceIPv4Supported := True;
FDeviceIPv4Net  := Net;
FDeviceIPv4Mask := Mask;
end;

procedure TSInternetConnection.PrintTextInfo(const TextStream : TSTextStream; const FileSystemSuport : TSBoolean = False);
begin
end;

class function TSInternetConnection.PacketCompatible(const Packet : TSEthernetPacketFrame) : TSBoolean;
begin
Result := False;
end;

function TSInternetConnection.PacketPushed(const Time : TSTime; const Date : TSDateTime; const Packet : TSEthernetPacketFrame) : TSBoolean;
begin
Result := False;
end;

class function TSInternetConnection.ProtocolAbbreviation(const FileSystemSuport : TSBoolean = False) : TSString;
begin
Result := '';
end;

constructor TSInternetConnection.Create();
begin
inherited;
FDataSize := 0;
FPacketCount := 0;
FPacketStorage := nil;
FCritacalSection := TSCriticalSection.Create();
FIdentifier := '';
FDeviceIPv4Supported := False;
FSecondsMeansConnectionActive := 10;
FFirstPacketIsSelfSender := False;
FModePacketStorage := False;
FModeDataTransfer := True;
FModeRuntimeDataDumper := False;
FModeRuntimePacketDumper := False;
FDumpDirectory := '';
FConnectionDumpDirectory := '';
FConnectionDataDumpDirectory := '';
FConnectionPacketDumpDirectory := '';
FillChar(FTimeFirstPacket, SizeOf(FTimeFirstPacket), 0);
FillChar(FTimeLastPacket, SizeOf(FTimeLastPacket), 0);
FillChar(FDateFirstPacket, SizeOf(FDateFirstPacket), 0);
FillChar(FDateLastPacket, SizeOf(FDateLastPacket), 0);
FPacketDataFileExtension := SmoothInternetDumperBase.PacketFileExtension;
FPacketInfoFileExtension := SmoothInternetDumperBase.PacketInfoFileExtension;
FConnectionsHandler := nil;
FFictitious := False;
FDeviceIdentificator := 0;
end;

procedure TSInternetConnection.MakeFictitious();
begin
FFictitious := True;
FModePacketStorage := False;
FModeDataTransfer := False;
FModeRuntimeDataDumper := False;
FModeRuntimePacketDumper := False;
SKill(FPacketStorage);
end;

function TSInternetConnection.RenameConnectionDirectoryIncludeSize() : TSBoolean;
var
	NewConnectionDumpDirectory : TSString;
begin
Result := False;
if (FConnectionDumpDirectory <> '') and (FDataSize > 0) then
	begin
	NewConnectionDumpDirectory := FConnectionDumpDirectory + ' [' + SStr(FPacketCount) + ', ' + SMemorySizeToString(FDataSize, 'EN') + ']';
	SRenameFile(FConnectionDumpDirectory, NewConnectionDumpDirectory);
	FConnectionDumpDirectory := NewConnectionDumpDirectory;
	Result := True;
	end;
end;

destructor TSInternetConnection.Destroy();
begin
RenameConnectionDirectoryIncludeSize();
SKill(FCritacalSection);
SKill(FPacketStorage);
inherited;
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSInternetConnectionListHelper}
{$DEFINE DATATYPE_LIST        := TSInternetConnectionList}
{$DEFINE DATATYPE             := TSInternetConnection}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSInternetConnectionClassListHelper}
{$DEFINE DATATYPE_LIST        := TSInternetConnectionClassList}
{$DEFINE DATATYPE             := TSInternetConnectionClass}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
