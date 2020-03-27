{$INCLUDE Smooth.inc}

unit SmoothInternetConnectionsCaptor;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothInternetPacketCaptureHandler
	,SmoothInternetConnection
	,SmoothDateTime
	,SmoothEthernetPacketFrame
	,SmoothInternetBase
	,SmoothCriticalSection
	,SmoothTextStream
	
	,Classes
	;

type
	TSInternetConnectionsCaptor = class(TSInternetPacketCaptureHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FCriticalSection : TSCriticalSection;
		FConnections : TSInternetConnectionList;
		
		FIncompatiblePacketsSize : TSUInt64;
		FIncompatiblePacketsCount : TSUInt64;
		FCompatiblePacketsSize : TSUInt64;
		FCompatiblePacketsCount : TSUInt64;
		
		FModeDataTransfer : TSBoolean;
		FModeRuntimeDataDumper : TSBoolean;
		FModePacketStorage : TSBoolean;
		FModeRuntimePacketDumper : TSBoolean;
		
		FLargeStatisticsInformation : TSBoolean;
		
		// Dump modes
		FDumpDirectory : TSString;
		FIncompatibleDumpDirectory : TSString;
		FPacketDataFileExtension : TSString;
		FPacketInfoFileExtension : TSString;
		FDeviceInformationFileExtension : TSString;
		
		// Data tansfer
		FConnectionsHandler : ISConnectionsHandler;
			public
		function Start() : TSBoolean; override;
		procedure LogStatistic();
			protected
		procedure RenameConnectionDirectoriesIncludeSize();
		procedure PrintStatistic(const TextTime : TSString);
		procedure ViewStatistic(const TextTime : TSString; const TextStream : TSTextStream; const DestroyTextStream : TSBoolean = True);
		function ConnectionsLength() : TSMaxEnum;
		procedure CreateDumpDirectory();
		procedure PutConnectionModesInfo(const Connection : TSInternetConnection);
		procedure PutConnectionIPv4Info(const Connection : TSInternetConnection; const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator);
		procedure DumpIncompatiblePacket(const Date : TSDateTime; const Time : TSTime; const Packet : TSEthernetPacketFrame; const Stream : TStream);
			protected
		procedure HandlePacket(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSTime); override;
		procedure HandleDevice(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator); override;
		function HandleTimeOutUpdate(const Now : TSDateTime) : TSBoolean; override;
			protected
		function HandleNewConnection(const ConnectionClass : TSInternetConnectionClass; const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSEthernetPacketFrame; const Date : TSDateTime; const Time : TSTime) : TSBoolean;
		function HandlePacketNewConnections(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSEthernetPacketFrame; const Date : TSDateTime; const Time : TSTime) : TSBoolean;
		function HandlePacketConnections(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSEthernetPacketFrame; const Date : TSDateTime; const Time : TSTime) : TSBoolean;
			public
		property ConnectionsCount : TSMaxEnum read ConnectionsLength;
		property ModeDataTransfer : TSBoolean read FModeDataTransfer write FModeDataTransfer;
		property ModePacketStorage : TSBoolean read FModePacketStorage write FModePacketStorage;
		property ModeRuntimeDataDumper : TSBoolean read FModeRuntimeDataDumper write FModeRuntimeDataDumper;
		property ModeRuntimePacketDumper : TSBoolean read FModeRuntimePacketDumper write FModeRuntimePacketDumper;
		property ConnectionsHandler : ISConnectionsHandler read FConnectionsHandler write FConnectionsHandler;
		property LargeStatisticsInformation : TSBoolean read FLargeStatisticsInformation write FLargeStatisticsInformation;
		end;

procedure SKill(var Connections : TSInternetConnectionsCaptor); overload;
procedure SRegisterInternetConnectionClass(const ClassVariable : TSInternetConnectionClass);

implementation

uses
	 SmoothInternetConnectionTCPIPv4
	,SmoothTextConsoleStream
	,SmoothTextLogStream
	,SmoothBaseUtils
	,SmoothStringUtils
	,SmoothStreamUtils
	,SmoothFileUtils
	,SmoothTextFileStream
	,SmoothInternetDumperBase
	,SmoothLog
	
	,StrMan
	;

var
	ConnectionClasses : TSInternetConnectionClassList = nil;

procedure SRegisterInternetConnectionClass(const ClassVariable : TSInternetConnectionClass);
var
	Index : TSMaxEnum;
	Add : TSBoolean;
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

procedure SKill(var Connections : TSInternetConnectionsCaptor); overload;
begin
if Connections <> nil then
	begin
	Connections.Destroy();
	Connections := nil;
	end;
end;

// ========================================
// ======TSInternetConnectionsCaptor======
// ========================================

procedure TSInternetConnectionsCaptor.DumpIncompatiblePacket(const Date : TSDateTime; const Time : TSTime; const Packet : TSEthernetPacketFrame; const Stream : TStream);
var
	DateTimeString : TSString;
	FileName : TSString;
	Description : TSString;
	FileNameInfo : TSString;
	FileNameData : TSString;
	TextStream : TSTextFileStream = nil;
	FileStream : TFileStream = nil;
begin
DateTimeString := SDateTimeCorrectionString(Date, Time, True);
FileName := FIncompatibleDumpDirectory + DirectorySeparator + DateTimeString + ' {' + SStr(FIncompatiblePacketsCount) + '}';
Description := Packet.Description;
if Description <> '' then
	FileName += ' (' + Description + ')';
FileNameInfo := FileName + Iff(FPacketInfoFileExtension <> '', '.' + FPacketInfoFileExtension, '');
FileNameData := FileName + Iff(FPacketDataFileExtension <> '', '.' + FPacketDataFileExtension, '');

TextStream := TSTextFileStream.Create(FileNameInfo);
TextStream.WriteLn('[packet]');
TextStream.WriteLn(['DataTime = ', SDateTimeCorrectionString(Date, Time, False)]);
TextStream.WriteLn(['Size     = ', SGetSizeString(Stream.Size, 'EN')]);
TextStream.WriteLn();
Packet.ExportInfo(TextStream);
SKill(TextStream);

FileStream := TFileStream.Create(FileNameData, fmCreate);
Stream.Position := 0;
SCopyPartStreamToStream(Stream, FileStream, Stream.Size);
SKill(FileStream);

Stream.Position := 0;
end;

function TSInternetConnectionsCaptor.Start() : TSBoolean;
begin
if FModeRuntimeDataDumper or FModeRuntimePacketDumper then
	CreateDumpDirectory();
Result := inherited Start();
end;

procedure TSInternetConnectionsCaptor.CreateDumpDirectory();
begin
if FModeRuntimeDataDumper or FModeRuntimePacketDumper then
	begin
	FDumpDirectory := 'Connections analyzer ' + SDateTimeString(True);
	SMakeDirectory(FDumpDirectory);
	
	FIncompatibleDumpDirectory := FDumpDirectory + DirectorySeparator + 'Incompatible packets';
	SMakeDirectory(FIncompatibleDumpDirectory);
	end;
end;

function TSInternetConnectionsCaptor.ConnectionsLength() : TSMaxEnum;
begin
Result := 0;
if (FConnections <> nil) then
	Result := Length(FConnections);
end;

procedure TSInternetConnectionsCaptor.PrintStatistic(const TextTime : TSString);
begin
ViewStatistic(TextTime, TSTextConsoleStream.Create(), True);
end;

procedure TSInternetConnectionsCaptor.LogStatistic();
begin
ViewStatistic(STextTimeBetweenDates(TimeBegining, SNow(), 'EN'), TSTextLogStream.Create(), True);
end;

procedure TSInternetConnectionsCaptor.ViewStatistic(const TextTime : TSString; const TextStream : TSTextStream; const DestroyTextStream : TSBoolean = True);

procedure PrintNotLargeStatisticsInformation(const TextStream : TSTextStream);
type
	PSShortConnectionInfo = ^ TSShortConnectionInfo;
	TSShortConnectionInfo = packed record
		FAbbreviation : TSString;
		FPacketCount : TSUInt64;
		FDataSize : TSUInt64;
		FCount : TSUInt64;
		end;
	TSShortConnectionsInfo = packed array of TSShortConnectionInfo;
var
	ShortConnectionsInfo : TSShortConnectionsInfo = nil;

function FindShortConnectionInfo(const ProtocolAbbreviation : TSString) : PSShortConnectionInfo;
var
	Index : TSMaxEnum;
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

procedure AddNotExistsConnectionInfo(const Index : TSMaxEnum);
var
	ShortConnectionInfo : PSShortConnectionInfo = nil;
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
	Index : TSMaxEnum;
	NumberCount : TSMaxEnum;
	ShortConnectionInfo : PSShortConnectionInfo = nil;
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
	NumberCount := Length(SStr(Length(ShortConnectionsInfo)));
	for Index := 0 to High(ShortConnectionsInfo) do
		begin
		TextStream.Write(['  ', StringJustifyRight(SStr(Index + 1), NumberCount, ' '), ') ']);
		TextStream.TextColor(15);
		TextStream.Write([ShortConnectionsInfo[Index].FAbbreviation]);
		TextStream.TextColor(7);
		TextStream.Write(['(', ShortConnectionsInfo[Index].FCount, ')[', ShortConnectionsInfo[Index].FPacketCount, ']: ', SGetSizeString(ShortConnectionsInfo[Index].FDataSize, 'EN')]);
		TextStream.WriteLn();
		end;
	SetLength(ShortConnectionsInfo, 0);
	end;
end;

procedure PrintConnectionsList(const TextStream : TSTextStream);
var
	NumberCount : TSMaxEnum;
	Index : TSMaxEnum;
begin
NumberCount := Length(SStr(ConnectionsCount));
for Index := 0 to High(FConnections) do
	begin
	TextStream.Write(['  ', StringJustifyRight(SStr(Index + 1), NumberCount, ' '), ') ']);
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
		TextStream.Write(['Compatible[', FCompatiblePacketsCount, ']: ', SGetSizeString(FCompatiblePacketsSize, 'ENG'), Iff((FIncompatiblePacketsCount <> 0), '; ', '.')]);
	if (FIncompatiblePacketsCount <> 0) then
		TextStream.Write(['Incompatible[', FIncompatiblePacketsCount, ']: ', SGetSizeString(FIncompatiblePacketsSize, 'ENG'), '.']);
	TextStream.WriteLn();
	end;
if DestroyTextStream then
	TextStream.Destroy();
end;

function TSInternetConnectionsCaptor.HandleTimeOutUpdate(const Now : TSDateTime) : TSBoolean;
begin
Result := inherited HandleTimeOutUpdate(Now);
PrintStatistic(STextTimeBetweenDates(TimeBegining, SNow(), 'EN'));
end;

procedure TSInternetConnectionsCaptor.HandleDevice(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator); 
begin
end;

procedure TSInternetConnectionsCaptor.PutConnectionModesInfo(const Connection : TSInternetConnection);
begin
Connection.Identifier := SStr(Length(FConnections) + 1);
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

procedure TSInternetConnectionsCaptor.PutConnectionIPv4Info(const Connection : TSInternetConnection; const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator);
var
	IPv4Net, IPv4Mask : TSIPv4Address;
begin
IPv4Net := SIPv4StringToAddress(FindDeviceOption(Identificator, 'IPv4 Net'));
IPv4Mask := SIPv4StringToAddress(FindDeviceOption(Identificator, 'IPv4 Mask'));
if (IPv4Mask <> 0) or (IPv4Net <> 0) then
	Connection.AddDeviceIPv4(IPv4Net, IPv4Mask);
end;

function TSInternetConnectionsCaptor.HandleNewConnection(const ConnectionClass : TSInternetConnectionClass; const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSEthernetPacketFrame; const Date : TSDateTime; const Time : TSTime) : TSBoolean;
var
	NewConnection : TSInternetConnection = nil;
	FrameSize : TSUInt64;
begin
NewConnection := ConnectionClass.Create();
PutConnectionModesInfo(NewConnection);
PutConnectionIPv4Info(NewConnection, Identificator);
NewConnection.DeviceIdentificator := Identificator;

FrameSize := Frame.Size;
Result := NewConnection.PacketPushed(Time, Date, Frame);
if not Result then
	SKill(NewConnection)
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

function TSInternetConnectionsCaptor.HandlePacketNewConnections(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSEthernetPacketFrame; const Date : TSDateTime; const Time : TSTime) : TSBoolean;
var
	Index : TSMaxEnum;
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

function TSInternetConnectionsCaptor.HandlePacketConnections(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSEthernetPacketFrame; const Date : TSDateTime; const Time : TSTime) : TSBoolean;
var
	Index : TSMaxEnum;
	FrameSize : TSUInt64;
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

procedure TSInternetConnectionsCaptor.HandlePacket(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSTime);
var
	Frame : TSEthernetPacketFrame;
	Date : TSDateTime;
begin
Date.Get();
Frame := TSEthernetPacketFrame.Create();
Stream.Position := 0;
Frame.Read(Stream, Stream.Size);
if not HandlePacketConnections(Identificator, Frame, Date, Time) then
	if not HandlePacketNewConnections(Identificator, Frame, Date, Time) then
		begin
		FIncompatiblePacketsSize += Stream.Size;
		FIncompatiblePacketsCount += 1;
		
		if FModeRuntimeDataDumper or FModeRuntimePacketDumper then
			DumpIncompatiblePacket(Date, Time, Frame, Stream);
		SKill(Frame);
		end;
end;

constructor TSInternetConnectionsCaptor.Create();
begin
inherited;
FCriticalSection := TSCriticalSection.Create();
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
FPacketDataFileExtension := SmoothInternetDumperBase.PacketFileExtension;
FPacketInfoFileExtension := SmoothInternetDumperBase.PacketInfoFileExtension;
FDeviceInformationFileExtension := SmoothInternetDumperBase.DeviceInformationFileExtension;
end;

procedure TSInternetConnectionsCaptor.RenameConnectionDirectoriesIncludeSize();
var
	CountRenamed, Index : TSMaxEnum;
begin
if (FModeRuntimeDataDumper or FModeRuntimePacketDumper) and (FConnections <> nil) and (Length(FConnections) > 0) then
	begin
	SHint(['Adding size to connection directories...']);
	CountRenamed := 0;
	for Index := 0 to High(FConnections) do
		if FConnections[Index].RenameConnectionDirectoryIncludeSize() then
			CountRenamed += 1;
	SHint(['Added size to ', CountRenamed, '/', Length(FConnections), ' connection directories.']);
	end;
end;

destructor TSInternetConnectionsCaptor.Destroy();
var
	Index : TSMaxEnum;
begin
if (FConnections <> nil) and (Length(FConnections) > 0) then
	for Index := 0 to High(FConnections) do
		SKill(FConnections[Index]);
SKill(FConnections);
SKill(FCriticalSection);
inherited;
end;

end.
