{$INCLUDE SaGe.inc}

unit SaGeInternetConnectionsCaptor;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	,SaGeInternetPacketCaptureHandler
	,SaGeInternetConnection
	,SaGeDateTime
	,SaGeEthernetPacketFrame
	,SaGeInternetBase
	,SaGeCriticalSection
	,SaGeTextStream
	
	,Classes
	;

type
	TSGInternetConnectionsCaptor = class(TSGInternetPacketCaptureHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FCriticalSection : TSGCriticalSection;
		FConnections : TSGInternetConnectionList;
		
		FIncompatiblePacketsSize : TSGUInt64;
		FIncompatiblePacketsCount : TSGUInt64;
		FCompatiblePacketsSize : TSGUInt64;
		FCompatiblePacketsCount : TSGUInt64;
		
		FModeDataTransfer : TSGBoolean;
		FModeRuntimeDataDumper : TSGBoolean;
		FModePacketStorage : TSGBoolean;
		FModeRuntimePacketDumper : TSGBoolean;
		
		FLargeStatisticsInformation : TSGBoolean;
		
		// Dump modes
		FDumpDirectory : TSGString;
		FIncompatibleDumpDirectory : TSGString;
		FPacketDataFileExtension : TSGString;
		FPacketInfoFileExtension : TSGString;
		FDeviceInformationFileExtension : TSGString;
		
		// Data tansfer
		FConnectionsHandler : ISGConnectionsHandler;
			public
		function Start() : TSGBoolean; override;
		procedure LogStatistic();
			protected
		procedure RenameConnectionDirectoriesIncludeSize();
		procedure PrintStatistic(const TextTime : TSGString);
		procedure ViewStatistic(const TextTime : TSGString; const TextStream : TSGTextStream; const DestroyTextStream : TSGBoolean = True);
		function ConnectionsLength() : TSGMaxEnum;
		procedure CreateDumpDirectory();
		procedure PutConnectionModesInfo(const Connection : TSGInternetConnection);
		procedure PutConnectionIPv4Info(const Connection : TSGInternetConnection; const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator);
		procedure DumpIncompatiblePacket(const Date : TSGDateTime; const Time : TSGTime; const Packet : TSGEthernetPacketFrame; const Stream : TStream);
			protected
		procedure HandlePacket(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSGTime); override;
		procedure HandleDevice(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator); override;
		function HandleTimeOutUpdate(const Now : TSGDateTime) : TSGBoolean; override;
			protected
		function HandleNewConnection(const ConnectionClass : TSGInternetConnectionClass; const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSGEthernetPacketFrame; const Date : TSGDateTime; const Time : TSGTime) : TSGBoolean;
		function HandlePacketNewConnections(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSGEthernetPacketFrame; const Date : TSGDateTime; const Time : TSGTime) : TSGBoolean;
		function HandlePacketConnections(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSGEthernetPacketFrame; const Date : TSGDateTime; const Time : TSGTime) : TSGBoolean;
			public
		property ConnectionsCount : TSGMaxEnum read ConnectionsLength;
		property ModeDataTransfer : TSGBoolean read FModeDataTransfer write FModeDataTransfer;
		property ModePacketStorage : TSGBoolean read FModePacketStorage write FModePacketStorage;
		property ModeRuntimeDataDumper : TSGBoolean read FModeRuntimeDataDumper write FModeRuntimeDataDumper;
		property ModeRuntimePacketDumper : TSGBoolean read FModeRuntimePacketDumper write FModeRuntimePacketDumper;
		property ConnectionsHandler : ISGConnectionsHandler read FConnectionsHandler write FConnectionsHandler;
		property LargeStatisticsInformation : TSGBoolean read FLargeStatisticsInformation write FLargeStatisticsInformation;
		end;

procedure SGKill(var Connections : TSGInternetConnectionsCaptor); overload;
procedure SGRegisterInternetConnectionClass(const ClassVariable : TSGInternetConnectionClass);

implementation

uses
	 SaGeInternetConnectionTCPIPv4
	,SaGeTextConsoleStream
	,SaGeTextLogStream
	,SaGeBaseUtils
	,SaGeStringUtils
	,SaGeStreamUtils
	,SaGeFileUtils
	,SaGeTextFileStream
	,SaGeInternetDumperBase
	,SaGeLog
	
	,StrMan
	;

var
	ConnectionClasses : TSGInternetConnectionClassList = nil;

procedure SGRegisterInternetConnectionClass(const ClassVariable : TSGInternetConnectionClass);
var
	Index : TSGMaxEnum;
	Add : TSGBoolean;
begin
Add := False;
if (ConnectionClasses = nil) or (Length(ConnectionClasses) = 0) then
	Add := True
else
	begin
	Add := True;
	for Index := 0 to High(ConnectionClasses) do
		if ConnectionClasses[Index] = ClassVariable then
			begin
			Add := False;
			break;
			end;
	end;
if Add then
	ConnectionClasses += ClassVariable;
end;

procedure SGKill(var Connections : TSGInternetConnectionsCaptor); overload;
begin
if Connections <> nil then
	begin
	Connections.Destroy();
	Connections := nil;
	end;
end;

// ========================================
// ======TSGInternetConnectionsCaptor======
// ========================================

procedure TSGInternetConnectionsCaptor.DumpIncompatiblePacket(const Date : TSGDateTime; const Time : TSGTime; const Packet : TSGEthernetPacketFrame; const Stream : TStream);
var
	DateTimeString : TSGString;
	FileName : TSGString;
	Description : TSGString;
	FileNameInfo : TSGString;
	FileNameData : TSGString;
	TextStream : TSGTextFileStream = nil;
	FileStream : TFileStream = nil;
begin
DateTimeString := SGDateTimeCorrectionString(Date, Time, True);
FileName := FIncompatibleDumpDirectory + DirectorySeparator + DateTimeString + ' {' + SGStr(FIncompatiblePacketsCount) + '}';
Description := Packet.Description;
if Description <> '' then
	FileName += ' (' + Description + ')';
FileNameInfo := FileName + Iff(FPacketInfoFileExtension <> '', '.' + FPacketInfoFileExtension, '');
FileNameData := FileName + Iff(FPacketDataFileExtension <> '', '.' + FPacketDataFileExtension, '');

TextStream := TSGTextFileStream.Create(FileNameInfo);
TextStream.WriteLn('[packet]');
TextStream.WriteLn(['DataTime = ', SGDateTimeCorrectionString(Date, Time, False)]);
TextStream.WriteLn(['Size     = ', SGGetSizeString(Stream.Size, 'EN')]);
TextStream.WriteLn();
Packet.ExportInfo(TextStream);
SGKill(TextStream);

FileStream := TFileStream.Create(FileNameData, fmCreate);
Stream.Position := 0;
SGCopyPartStreamToStream(Stream, FileStream, Stream.Size);
SGKill(FileStream);

Stream.Position := 0;
end;

function TSGInternetConnectionsCaptor.Start() : TSGBoolean;
begin
if FModeRuntimeDataDumper or FModeRuntimePacketDumper then
	CreateDumpDirectory();
Result := inherited Start();
end;

procedure TSGInternetConnectionsCaptor.CreateDumpDirectory();
begin
if FModeRuntimeDataDumper or FModeRuntimePacketDumper then
	begin
	FDumpDirectory := 'Connections analyzer ' + SGDateTimeString(True);
	SGMakeDirectory(FDumpDirectory);
	
	FIncompatibleDumpDirectory := FDumpDirectory + DirectorySeparator + 'Incompatible packets';
	SGMakeDirectory(FIncompatibleDumpDirectory);
	end;
end;

function TSGInternetConnectionsCaptor.ConnectionsLength() : TSGMaxEnum;
begin
Result := 0;
if (FConnections <> nil) then
	Result := Length(FConnections);
end;

procedure TSGInternetConnectionsCaptor.PrintStatistic(const TextTime : TSGString);
begin
ViewStatistic(TextTime, TSGTextConsoleStream.Create(), True);
end;

procedure TSGInternetConnectionsCaptor.LogStatistic();
begin
ViewStatistic(SGTextTimeBetweenDates(TimeBegining, SGNow(), 'EN'), TSGTextLogStream.Create(), True);
end;

procedure TSGInternetConnectionsCaptor.ViewStatistic(const TextTime : TSGString; const TextStream : TSGTextStream; const DestroyTextStream : TSGBoolean = True);

procedure PrintNotLargeStatisticsInformation(const TextStream : TSGTextStream);
type
	PSGShortConnectionInfo = ^ TSGShortConnectionInfo;
	TSGShortConnectionInfo = packed record
		FAbbreviation : TSGString;
		FPacketCount : TSGUInt64;
		FDataSize : TSGUInt64;
		FCount : TSGUInt64;
		end;
	TSGShortConnectionsInfo = packed array of TSGShortConnectionInfo;
var
	ShortConnectionsInfo : TSGShortConnectionsInfo = nil;

function FindShortConnectionInfo(const ProtocolAbbreviation : TSGString) : PSGShortConnectionInfo;
var
	Index : TSGMaxEnum;
begin
Result := nil;
if (ShortConnectionsInfo <> nil) then
	for Index := 0 to High(ShortConnectionsInfo) do
		if (ShortConnectionsInfo[Index].FAbbreviation = ProtocolAbbreviation) then
			begin
			Result := @ShortConnectionsInfo[Index];
			break;
			end;
end;

procedure AddNotExistsConnectionInfo(const Index : TSGMaxEnum);
var
	ShortConnectionInfo : PSGShortConnectionInfo = nil;
begin
if (ShortConnectionsInfo = nil) then
	SetLength(ShortConnectionsInfo, 1)
else
	SetLength(ShortConnectionsInfo, Length(ShortConnectionsInfo) + 1);
ShortConnectionInfo := @ShortConnectionsInfo[High(ShortConnectionsInfo)];
ShortConnectionInfo^.FAbbreviation := FConnections[Index].ProtocolAbbreviation();
ShortConnectionInfo^.FPacketCount := FConnections[Index].PacketCount;
ShortConnectionInfo^.FDataSize := FConnections[Index].DataSize;
ShortConnectionInfo^.FCount := 1;
end;

var
	Index : TSGMaxEnum;
	NumberCount : TSGMaxEnum;
	ShortConnectionInfo : PSGShortConnectionInfo = nil;
begin
for Index := 0 to High(FConnections) do
	begin
	ShortConnectionInfo := FindShortConnectionInfo(FConnections[Index].ProtocolAbbreviation());
	if (ShortConnectionInfo = nil) then
		AddNotExistsConnectionInfo(Index)
	else
		begin
		ShortConnectionInfo^.FPacketCount += FConnections[Index].PacketCount;
		ShortConnectionInfo^.FDataSize += FConnections[Index].DataSize;
		ShortConnectionInfo^.FCount += 1;
		end;
	end;
if (ShortConnectionInfo <> nil) then
	begin
	NumberCount := Length(SGStr(Length(ShortConnectionsInfo)));
	for Index := 0 to High(ShortConnectionsInfo) do
		begin
		TextStream.Write(['  ', StringJustifyRight(SGStr(Index + 1), NumberCount, ' '), ') ']);
		TextStream.TextColor(15);
		TextStream.Write([ShortConnectionsInfo[Index].FAbbreviation]);
		TextStream.TextColor(7);
		TextStream.Write(['(', ShortConnectionsInfo[Index].FCount, ')[', ShortConnectionsInfo[Index].FPacketCount, ']: ', SGGetSizeString(ShortConnectionsInfo[Index].FDataSize, 'EN')]);
		TextStream.WriteLn();
		end;
	SetLength(ShortConnectionsInfo, 0);
	end;
end;

procedure PrintConnectionsList(const TextStream : TSGTextStream);
var
	NumberCount : TSGMaxEnum;
	Index : TSGMaxEnum;
begin
NumberCount := Length(SGStr(ConnectionsCount));
for Index := 0 to High(FConnections) do
	begin
	TextStream.Write(['  ', StringJustifyRight(SGStr(Index + 1), NumberCount, ' '), ') ']);
	FConnections[Index].PrintTextInfo(TextStream);
	TextStream.WriteLn();
	end;
end;

begin
TextStream.Clear();
TextStream.TextColor(7);
TextStream.WriteLn(['Capturing connections ', TextTime, ' (', ConnectionsCount, ')', Iff(ConnectionsCount = 0, '.', ':')]);
if (ConnectionsCount <> 0) then
	if LargeStatisticsInformation then
		PrintConnectionsList(TextStream)
	else
		PrintNotLargeStatisticsInformation(TextStream);
if (FIncompatiblePacketsCount <> 0) or (FCompatiblePacketsCount <> 0) then
	begin
	TextStream.Write('Packets: ');
	if (FCompatiblePacketsCount <> 0) then
		TextStream.Write(['Compatible[', FCompatiblePacketsCount, ']: ', SGGetSizeString(FCompatiblePacketsSize, 'ENG'), Iff((FIncompatiblePacketsCount <> 0), '; ', '.')]);
	if (FIncompatiblePacketsCount <> 0) then
		TextStream.Write(['Incompatible[', FIncompatiblePacketsCount, ']: ', SGGetSizeString(FIncompatiblePacketsSize, 'ENG'), '.']);
	TextStream.WriteLn();
	end;
if DestroyTextStream then
	TextStream.Destroy();
end;

function TSGInternetConnectionsCaptor.HandleTimeOutUpdate(const Now : TSGDateTime) : TSGBoolean;
begin
Result := inherited HandleTimeOutUpdate(Now);
PrintStatistic(SGTextTimeBetweenDates(TimeBegining, SGNow(), 'EN'));
end;

procedure TSGInternetConnectionsCaptor.HandleDevice(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator); 
begin
end;

procedure TSGInternetConnectionsCaptor.PutConnectionModesInfo(const Connection : TSGInternetConnection);
begin
Connection.Identifier := SGStr(Length(FConnections) + 1);
Connection.ModeDataTransfer := FModeDataTransfer;
Connection.ModePacketStorage := FModePacketStorage;
Connection.ModeRuntimeDataDumper := FModeRuntimeDataDumper;
Connection.ModeRuntimePacketDumper := FModeRuntimePacketDumper;
if FModeRuntimePacketDumper or FModeRuntimeDataDumper then
	begin
	Connection.PacketDataFileExtension := FPacketDataFileExtension;
	Connection.PacketInfoFileExtension := FPacketInfoFileExtension;
	Connection.DumpDirectory := FDumpDirectory;
	end;
if FModeDataTransfer then
	Connection.ConnectionsHandler := FConnectionsHandler;
end;

procedure TSGInternetConnectionsCaptor.PutConnectionIPv4Info(const Connection : TSGInternetConnection; const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator);
var
	IPv4Net, IPv4Mask : TSGIPv4Address;
begin
IPv4Net := SGIPv4StringToAddress(FindDeviceOption(Identificator, 'IPv4 Net'));
IPv4Mask := SGIPv4StringToAddress(FindDeviceOption(Identificator, 'IPv4 Mask'));
if (IPv4Mask <> 0) or (IPv4Net <> 0) then
	Connection.AddDeviceIPv4(IPv4Net, IPv4Mask);
end;

function TSGInternetConnectionsCaptor.HandleNewConnection(const ConnectionClass : TSGInternetConnectionClass; const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSGEthernetPacketFrame; const Date : TSGDateTime; const Time : TSGTime) : TSGBoolean;
var
	NewConnection : TSGInternetConnection = nil;
	FrameSize : TSGUInt64;
begin
NewConnection := ConnectionClass.Create();
PutConnectionModesInfo(NewConnection);
PutConnectionIPv4Info(NewConnection, Identificator);
NewConnection.DeviceIdentificator := Identificator;

FrameSize := Frame.Size;
Result := NewConnection.PacketPushed(Time, Date, Frame);
if not Result then
	SGKill(NewConnection)
else
	begin
	FCriticalSection.Enter();
	
	FConnections += NewConnection;
	FCompatiblePacketsCount += 1;
	FCompatiblePacketsSize += FrameSize;
	
	FCriticalSection.Leave();
	
	if FModeRuntimeDataDumper or FModeRuntimePacketDumper then
		CreateDeviceInformationFile(Identificator, 
			NewConnection.ConnectionDumpDirectory + DirectorySeparator + 'Device' + 
				Iff(FDeviceInformationFileExtension <> '', '.' + FDeviceInformationFileExtension));
	end;
end;

function TSGInternetConnectionsCaptor.HandlePacketNewConnections(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSGEthernetPacketFrame; const Date : TSGDateTime; const Time : TSGTime) : TSGBoolean;
var
	Index : TSGMaxEnum;
begin
Result := False;
if (ConnectionClasses <> nil) and (Length(ConnectionClasses) > 0) then
	for Index := High(ConnectionClasses) downto 0 do
		if ConnectionClasses[Index].PacketCompatible(Frame) then
			begin
			Result := HandleNewConnection(
				ConnectionClasses[Index],
				Identificator,
				Frame,
				Date,
				Time);
			if Result then
				break;
			end;
end;

function TSGInternetConnectionsCaptor.HandlePacketConnections(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSGEthernetPacketFrame; const Date : TSGDateTime; const Time : TSGTime) : TSGBoolean;
var
	Index : TSGMaxEnum;
	FrameSize : TSGUInt64;
begin
Result := False;
FCriticalSection.Enter();
FrameSize := Frame.Size;
if (FConnections <> nil) and (Length(FConnections) > 0) then
	for Index := High(FConnections) downto 0 do
		if (FConnections[Index].DeviceIdentificator = Identificator) and FConnections[Index].PacketPushed(Time, Date, Frame) then
			begin
			Result := True;
			FCompatiblePacketsCount += 1;
			FCompatiblePacketsSize += FrameSize;
			break;
			end;
FCriticalSection.Leave();
end;

procedure TSGInternetConnectionsCaptor.HandlePacket(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSGTime);
var
	Frame : TSGEthernetPacketFrame;
	Date : TSGDateTime;
begin
Date.Get();
Frame := TSGEthernetPacketFrame.Create();
Stream.Position := 0;
Frame.Read(Stream, Stream.Size);
if not HandlePacketConnections(Identificator, Frame, Date, Time) then
	if not HandlePacketNewConnections(Identificator, Frame, Date, Time) then
		begin
		FIncompatiblePacketsSize += Stream.Size;
		FIncompatiblePacketsCount += 1;
		
		if FModeRuntimeDataDumper or FModeRuntimePacketDumper then
			DumpIncompatiblePacket(Date, Time, Frame, Stream);
		SGKill(Frame);
		end;
end;

constructor TSGInternetConnectionsCaptor.Create();
begin
inherited;
FCriticalSection := TSGCriticalSection.Create();
FConnections := nil;
FConnectionsHandler := nil;
FIncompatiblePacketsSize := 0;
FIncompatiblePacketsCount := 0;
FCompatiblePacketsCount := 0;
FCompatiblePacketsSize := 0;
FModePacketStorage := False;
FModeDataTransfer := True;
FModeRuntimeDataDumper := False;
FModeRuntimePacketDumper := False;
FLargeStatisticsInformation := False;
FDumpDirectory := '';
FIncompatibleDumpDirectory := '';
FPacketDataFileExtension := SaGeInternetDumperBase.PacketFileExtension;
FPacketInfoFileExtension := SaGeInternetDumperBase.PacketInfoFileExtension;
FDeviceInformationFileExtension := SaGeInternetDumperBase.DeviceInformationFileExtension;
end;

procedure TSGInternetConnectionsCaptor.RenameConnectionDirectoriesIncludeSize();
var
	CountRenamed, Index : TSGMaxEnum;
begin
if (FModeRuntimeDataDumper or FModeRuntimePacketDumper) and (FConnections <> nil) and (Length(FConnections) > 0) then
	begin
	SGHint(['Adding size to connection directories...']);
	CountRenamed := 0;
	for Index := 0 to High(FConnections) do
		if FConnections[Index].RenameConnectionDirectoryIncludeSize() then
			CountRenamed += 1;
	SGHint(['Added size to ', CountRenamed, '/', Length(FConnections), ' connection directories.']);
	end;
end;

destructor TSGInternetConnectionsCaptor.Destroy();
var
	Index : TSGMaxEnum;
begin
if (FConnections <> nil) and (Length(FConnections) > 0) then
	for Index := 0 to High(FConnections) do
		SGKill(FConnections[Index]);
SGKill(FConnections);
SGKill(FCriticalSection);
inherited;
end;

end.
