{$INCLUDE SaGe.inc}

unit SaGeInternetConnection;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeDateTime
	,SaGeEthernetPacketFrame
	,SaGeInternetPacketStorage
	,SaGeTextStream
	,SaGeInternetBase
	,SaGeCriticalSection
	
	,Classes
	;
type
	TSGInternetConnection = class;
	
	TSGInternetConnectionSizeInt = TSGUInt64;
	TSGConnectionDataType = (
		SGNoData,
		SGSenderData,
		SGRecieverData);
type
	ISGConnectionsHandler = interface(ISGInterface)
		['{57ac272a-c488-41c5-adae-122ee2dc0540}']
		procedure HandleConnectionData(const Connection : TSGInternetConnection; const DataType : TSGConnectionDataType; const Data : TStream);
		end;
	
	TSGConnectionsHandler = class(TSGNamed, ISGConnectionsHandler)
			public
		procedure HandleConnectionData(const Connection : TSGInternetConnection; const DataType : TSGConnectionDataType; const Data : TStream); virtual; abstract;
		end;
type
	TSGInternetConnection = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FCritacalSection : TSGCriticalSection;
		FPacketStorage : TSGInternetPacketStorage;
		FModeDataTransfer : TSGBoolean;
		FModePacketStorage : TSGBoolean;
		FModeRuntimeDataDumper : TSGBoolean;
		FModeRuntimePacketDumper : TSGBoolean;
		FIdentifier : TSGString;
		
		FTimeFirstPacket : TSGTime;
		FDateFirstPacket : TSGDateTime;
		FTimeLastPacket : TSGTime;
		FDateLastPacket : TSGDateTime;
		FSecondsMeansConnectionActive : TSGUInt16;
		FFirstPacketIsSelfSender : TSGBoolean;
		
		FDataSize : TSGInternetConnectionSizeInt;
		FPacketCount : TSGInternetConnectionSizeInt;
		
		FDeviceIPv4Supported : TSGBoolean;
		FDeviceIPv4Net  : TSGIPv4Address;
		FDeviceIPv4Mask : TSGIPv4Address;
		
		// Data ftansfer
		FConnectionsHandler : TSGConnectionsHandler;
		
		// Dumper modes
		FDumpDirectory : TSGString;
		FConnectionDumpDirectory : TSGString;
		FConnectionDataDumpDirectory : TSGString;
		FConnectionPacketDumpDirectory : TSGString;
		FPacketDataFileExtension : TSGString;
		FPacketInfoFileExtension : TSGString;
			protected
		class function ProtocolAbbreviation(const FileSystemSuport : TSGBoolean = False) : TSGString; virtual;
		procedure CreateConnectionDumpDirectory(); virtual;
		function PrintableTextString(const FileSystemSuport : TSGBoolean = True) : TSGString;
		procedure DumpPacketFiles(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame; const InfoFileName, DataFileName : TSGString);
		procedure DumpPacketInfoFile(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame; const InfoFileName : TSGString);
		procedure DumpPacketDataFile(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame; const DataFileName : TSGString);
		function AddressMatchesNetMask(const AddressValue : TSGIPv4Address) : TSGBoolean;
			public
		function RenameConnectionDirectoryIncludeSize() : TSGBoolean;
		procedure PrintTextInfo(const TextStream : TSGTextStream; const FileSystemSuport : TSGBoolean = False); virtual;
		function PacketPushed(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean; virtual;
		class function PacketComparable(const Packet : TSGEthernetPacketFrame) : TSGBoolean; virtual;
		procedure AddDeviceIPv4(const Net, Mask : TSGIPv4Address); virtual;
			public
		property DataSize : TSGInternetConnectionSizeInt read FDataSize;
		property TimeFirstPacket : TSGTime read FTimeFirstPacket;
		property DateFirstPacket : TSGDateTime read FDateFirstPacket;
		property ModeDataTransfer : TSGBoolean read FModeDataTransfer write FModeDataTransfer;
		property ModePacketStorage : TSGBoolean read FModePacketStorage write FModePacketStorage;
		property ModeRuntimeDataDumper : TSGBoolean read FModeRuntimeDataDumper write FModeRuntimeDataDumper;
		property ModeRuntimePacketDumper : TSGBoolean read FModeRuntimePacketDumper write FModeRuntimePacketDumper;
		property DumpDirectory : TSGString read FDumpDirectory write FDumpDirectory;
		property FirstPacketIsSelfSender : TSGBoolean read FFirstPacketIsSelfSender write FFirstPacketIsSelfSender;
		property ConnectionDumpDirectory : TSGString read FConnectionDumpDirectory;
		property PacketInfoFileExtension : TSGString read FPacketInfoFileExtension write FPacketInfoFileExtension;
		property PacketDataFileExtension : TSGString read FPacketDataFileExtension write FPacketDataFileExtension;
		property Identifier : TSGString read FIdentifier write FIdentifier;
		property ConnectionsHandler : TSGConnectionsHandler read FConnectionsHandler write FConnectionsHandler;
		end;
	TSGInternetConnectionClass = class of TSGInternetConnection;

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSGInternetConnectionListHelper}
{$DEFINE DATATYPE_LIST        := TSGInternetConnectionList}
{$DEFINE DATATYPE             := TSGInternetConnection}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGInternetConnectionClassListHelper}
{$DEFINE DATATYPE_LIST        := TSGInternetConnectionClassList}
{$DEFINE DATATYPE             := TSGInternetConnectionClass}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

procedure SGKill(var Variable : TSGInternetConnection);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

uses
	 SaGeStringTextStream
	,SaGeFileUtils
	,SaGeTextFileStream
	,SaGeStreamUtils
	,SaGeStringUtils
	,SaGeInternetDumperBase
	;

procedure SGKill(var Variable : TSGInternetConnection);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if Variable <> nil then
	begin
	Variable.Destroy();
	Variable := nil;
	end;
end;

function TSGInternetConnection.AddressMatchesNetMask(const AddressValue : TSGIPv4Address) : TSGBoolean;
begin
Result := False;
if FDeviceIPv4Supported then
	Result := (FDeviceIPv4Mask.Address and AddressValue.Address) = FDeviceIPv4Net.Address;
end;

procedure TSGInternetConnection.DumpPacketInfoFile(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame; const InfoFileName : TSGString);
var
	TextStream : TSGTextFileStream = nil;
begin
TextStream := TSGTextFileStream.Create(InfoFileName);
TextStream.WriteLn('[packet]');
TextStream.WriteLn(['DataTime = ', SGDateTimeCorrectionString(Date, Time, False)]);
TextStream.WriteLn(['Size     = ', SGGetSizeString(Packet.Size, 'EN')]);
TextStream.WriteLn();
Packet.ExportInfo(TextStream);
SGKill(TextStream);
end;

procedure TSGInternetConnection.DumpPacketDataFile(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame; const DataFileName : TSGString);
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
	SGCopyPartStreamToStream(Stream, FileStream, Stream.Size);
	SGKill(FileStream);
	SGKill(Stream);
	end;
end;

procedure TSGInternetConnection.DumpPacketFiles(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame; const InfoFileName, DataFileName : TSGString);
begin
DumpPacketInfoFile(Time, Date, Packet, InfoFileName);
DumpPacketDataFile(Time, Date, Packet, DataFileName);
end;

function TSGInternetConnection.PrintableTextString(const FileSystemSuport : TSGBoolean = True) : TSGString;
var
	StringTextSteam : TSGStringTextStream = nil;
begin
Result := '';
StringTextSteam := TSGStringTextStream.Create();
if FileSystemSuport and (ProtocolAbbreviation(FileSystemSuport) <> '') then
	Result += ProtocolAbbreviation(FileSystemSuport) + ' ';
if FileSystemSuport and (Identifier <> '') then
	Result += '{' + Identifier + '} ';
PrintTextInfo(StringTextSteam, FileSystemSuport);
Result += StringTextSteam.Value;
SGKill(StringTextSteam);
end;

procedure TSGInternetConnection.CreateConnectionDumpDirectory();
begin
if FModeRuntimeDataDumper or FModeRuntimePacketDumper then
	begin
	FConnectionDumpDirectory := SGFreeDirectoryName(FDumpDirectory + DirectorySeparator + PrintableTextString(), '');
	SGMakeDirectory(FConnectionDumpDirectory);
	end;
if FModeRuntimeDataDumper then
	begin
	FConnectionDataDumpDirectory := SGFreeDirectoryName(FConnectionDumpDirectory + DirectorySeparator + 'Data', '');
	SGMakeDirectory(FConnectionDataDumpDirectory);
	end;
if FModeRuntimePacketDumper then
	begin
	FConnectionPacketDumpDirectory := SGFreeDirectoryName(FConnectionDumpDirectory + DirectorySeparator + 'Packets', '');
	SGMakeDirectory(FConnectionPacketDumpDirectory);
	end;
end;

procedure TSGInternetConnection.AddDeviceIPv4(const Net, Mask : TSGIPv4Address);
begin
FDeviceIPv4Supported := True;
FDeviceIPv4Net  := Net;
FDeviceIPv4Mask := Mask;
end;

procedure TSGInternetConnection.PrintTextInfo(const TextStream : TSGTextStream; const FileSystemSuport : TSGBoolean = False);
begin
end;

class function TSGInternetConnection.PacketComparable(const Packet : TSGEthernetPacketFrame) : TSGBoolean;
begin
Result := False;
end;

function TSGInternetConnection.PacketPushed(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean;
begin
Result := False;
end;

class function TSGInternetConnection.ProtocolAbbreviation(const FileSystemSuport : TSGBoolean = False) : TSGString;
begin
Result := '';
end;

constructor TSGInternetConnection.Create();
begin
inherited;
FDataSize := 0;
FPacketCount := 0;
FPacketStorage := nil;
FCritacalSection := TSGCriticalSection.Create();
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
FPacketDataFileExtension := SaGeInternetDumperBase.PacketFileExtension;
FPacketInfoFileExtension := SaGeInternetDumperBase.PacketInfoFileExtension;
FConnectionsHandler := nil;
end;

function TSGInternetConnection.RenameConnectionDirectoryIncludeSize() : TSGBoolean;
var
	NewConnectionDumpDirectory : TSGString;
begin
Result := False;
if (FConnectionDumpDirectory <> '') and (FDataSize > 0) then
	begin
	NewConnectionDumpDirectory := FConnectionDumpDirectory + ' [' + SGStr(FPacketCount) + ', ' + SGGetSizeString(FDataSize, 'EN') + ']';
	SGRenameFile(FConnectionDumpDirectory, NewConnectionDumpDirectory);
	FConnectionDumpDirectory := NewConnectionDumpDirectory;
	Result := True;
	end;
end;

destructor TSGInternetConnection.Destroy();
begin
RenameConnectionDirectoryIncludeSize();
SGKill(FCritacalSection);
SGKill(FPacketStorage);
inherited;
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSGInternetConnectionListHelper}
{$DEFINE DATATYPE_LIST        := TSGInternetConnectionList}
{$DEFINE DATATYPE             := TSGInternetConnection}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGInternetConnectionClassListHelper}
{$DEFINE DATATYPE_LIST        := TSGInternetConnectionClassList}
{$DEFINE DATATYPE             := TSGInternetConnectionClass}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
