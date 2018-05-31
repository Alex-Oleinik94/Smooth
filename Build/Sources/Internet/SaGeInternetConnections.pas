{$INCLUDE SaGe.inc}

unit SaGeInternetConnections;

interface

uses
	 SaGeBase
	,SaGeClasses
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
	TSGInternetConnections = class(TSGInternetPacketCaptureHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FCriticalSection : TSGCriticalSection;
		FConnections : TSGInternetConnectionList;
		
		FOutPacketsSize : TSGUInt64;
		FOutPacketsCount : TSGUInt64;
		FComparablePacketsSize : TSGUInt64;
		FComparablePacketsCount : TSGUInt64;
		
		FModeDataTransfer : TSGBoolean;
		FModeRuntimeDataDumper : TSGBoolean;
		FModePacketStorage : TSGBoolean;
		FModeRuntimePacketDumper : TSGBoolean;
		
		// Dump modes
		FDumpDirectory : TSGString;
		FOutDumpDirectory : TSGString;
		FPacketDataFileExtension : TSGString;
		FPacketInfoFileExtension : TSGString;
			public
		procedure Loop(); override;
			protected
		procedure PrintStatistic(const TextTime : TSGString);
		procedure ViewStatistic(const TextTime : TSGString; const TextStream : TSGTextStream; const DestroyTextStream : TSGBoolean = True);
		procedure LogStatistic();
		function ConnectionsLength() : TSGMaxEnum;
		procedure CreateDumpDirectory();
		procedure DumpOutPacket(const Date : TSGDateTime; const Time : TSGTime; const Packet : TSGEthernetPacketFrame; const Stream : TStream);
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
		end;

procedure SGKill(var Connections : TSGInternetConnections); overload;
procedure SGRegisterInternetConnectionClass(const ClassVariable : TSGInternetConnectionClass);
procedure SGConnectionsAnalyzer();

implementation

uses
	 SaGeInternetConnectionTCP
	,SaGeTextConsoleStream
	,SaGeTextLogStream
	,SaGeBaseUtils
	,SaGeStringUtils
	,SaGeStreamUtils
	,SaGeFileUtils
	,SaGeTextFileStream
	
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

procedure SGKill(var Connections : TSGInternetConnections); overload;
begin
if Connections <> nil then
	begin
	Connections.Destroy();
	Connections := nil;
	end;
end;

procedure SGConnectionsAnalyzer();
var
	Connections : TSGInternetConnections = nil;
begin
Connections := TSGInternetConnections.Create();
Connections.PossibilityBreakLoopFromConsole := True;
Connections.ProcessTimeOutUpdates := True;
Connections.InfoTimeOut := 120;
Connections.ModeDataTransfer := False;
Connections.ModePacketStorage := True;
Connections.ModeRuntimeDataDumper := True;
Connections.ModeRuntimePacketDumper := True;
Connections.Loop();
Connections.LogStatistic();
SGKill(Connections);
end;

// ==================================
// ======TSGInternetConnections======
// ==================================

procedure TSGInternetConnections.DumpOutPacket(const Date : TSGDateTime; const Time : TSGTime; const Packet : TSGEthernetPacketFrame; const Stream : TStream);
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
FileName := FOutDumpDirectory + DirectorySeparator + DateTimeString + ' {' + SGStr(FOutPacketsCount) + '}';
Description := Packet.Description;
if Description <> '' then
	FileName += ' (' + Description + ')';
FileNameInfo := FileName + Iff(FPacketInfoFileExtension <> '', '.' + FPacketInfoFileExtension, '');
FileNameData := FileName + Iff(FPacketDataFileExtension <> '', '.' + FPacketDataFileExtension, '');

TextStream := TSGTextFileStream.Create(FileNameInfo);
TextStream.WriteLn('[packet]');
TextStream.WriteLn(['DataTime=', SGDateTimeCorrectionString(Date, Time, False)]);
TextStream.WriteLn(['Size=', Stream.Size]);
TextStream.WriteLn();
Packet.ExportInfo(TextStream);
SGKill(TextStream);

FileStream := TFileStream.Create(FileNameData, fmCreate);
Stream.Position := 0;
SGCopyPartStreamToStream(Stream, FileStream, Stream.Size);
SGKill(FileStream);

Stream.Position := 0;
end;

procedure TSGInternetConnections.Loop();
begin
if FModeRuntimeDataDumper or FModeRuntimePacketDumper then
	CreateDumpDirectory();
inherited Loop();
end;

procedure TSGInternetConnections.CreateDumpDirectory();
begin
if FModeRuntimeDataDumper or FModeRuntimePacketDumper then
	begin
	FDumpDirectory := 'Connections analyzer ' + SGDateTimeString(True);
	SGMakeDirectory(FDumpDirectory);
	
	FOutDumpDirectory := FDumpDirectory + DirectorySeparator + 'Out packets';
	SGMakeDirectory(FOutDumpDirectory);
	end;
end;

function TSGInternetConnections.ConnectionsLength() : TSGMaxEnum;
begin
Result := 0;
if (FConnections <> nil) then
	Result := Length(FConnections);
end;

procedure TSGInternetConnections.PrintStatistic(const TextTime : TSGString);
begin
ViewStatistic(TextTime, TSGTextConsoleStream.Create(), True);
end;

procedure TSGInternetConnections.LogStatistic();
begin
ViewStatistic(SGTextTimeBetweenDates(TimeBegining, SGNow(), 'EN'), TSGTextLogStream.Create(), True);
end;

procedure TSGInternetConnections.ViewStatistic(const TextTime : TSGString; const TextStream : TSGTextStream; const DestroyTextStream : TSGBoolean = True);

procedure PrintConnectionsList(const TextStream : TSGTextStream);
var
	NumberCount : TSGMaxEnum;
	Index : TSGMaxEnum;
begin
FCriticalSection.Enter();
NumberCount := Length(SGStr(ConnectionsCount));
for Index := 0 to High(FConnections) do
	begin
	TextStream.Write(['  ', StringJustifyRight(SGStr(Index + 1), NumberCount, ' '), ') ']);
	FConnections[Index].PrintTextInfo(TextStream);
	TextStream.WriteLn();
	end;
FCriticalSection.Leave();
end;

begin
TextStream.Clear();
TextStream.TextColor(7);
TextStream.WriteLn(['Connections (', TextTime, ') [', ConnectionsCount, ']', Iff(ConnectionsCount = 0, '.', ':')]);
if ConnectionsCount <> 0 then
	PrintConnectionsList(TextStream);
if (FOutPacketsCount <> 0) or (FComparablePacketsCount <> 0) then
	begin
	TextStream.Write('Packets: ');
	if (FComparablePacketsCount <> 0) then
		TextStream.Write(['Comparable[', FComparablePacketsCount, ']: ', SGGetSizeString(FComparablePacketsSize, 'ENG'), Iff((FOutPacketsCount <> 0), '; ', '.')]);
	if (FOutPacketsCount <> 0) then
		TextStream.Write(['Out[', FOutPacketsCount, ']: ', SGGetSizeString(FOutPacketsSize, 'ENG'), '.']);
	TextStream.WriteLn();
	end;
if DestroyTextStream then
	TextStream.Destroy();
end;

function TSGInternetConnections.HandleTimeOutUpdate(const Now : TSGDateTime) : TSGBoolean;
begin
Result := inherited HandleTimeOutUpdate(Now);
PrintStatistic(SGTextTimeBetweenDates(TimeBegining, SGNow(), 'EN'));
end;

procedure TSGInternetConnections.HandleDevice(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator); 
begin
end;

function TSGInternetConnections.HandleNewConnection(const ConnectionClass : TSGInternetConnectionClass; const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSGEthernetPacketFrame; const Date : TSGDateTime; const Time : TSGTime) : TSGBoolean;
var
	NewConnection : TSGInternetConnection = nil;
	IPv4Net, IPv4Mask : TSGIPv4Address;
begin
NewConnection := ConnectionClass.Create();
NewConnection.ModeDataTransfer := FModeDataTransfer;
NewConnection.ModePacketStorage := FModePacketStorage;
NewConnection.ModeRuntimeDataDumper := FModeRuntimeDataDumper;
NewConnection.ModeRuntimePacketDumper := FModeRuntimePacketDumper;
if FModeRuntimePacketDumper or FModeRuntimeDataDumper then
	NewConnection.DumpDirectory := FDumpDirectory;

IPv4Net := SGIPv4StringToAddress(FindDeviceOption(Identificator, 'IPv4 Net'));
IPv4Mask := SGIPv4StringToAddress(FindDeviceOption(Identificator, 'IPv4 Mask'));
if (IPv4Mask <> 0) or (IPv4Net <> 0) then
	NewConnection.AddDeviceIPv4(IPv4Net, IPv4Mask);
	
Result := NewConnection.PacketPushed(Time, Date, Frame);
if not Result then
	SGKill(NewConnection)
else
	begin
	FCriticalSection.Enter();
	
	FConnections += NewConnection;
	FComparablePacketsCount += 1;
	FComparablePacketsSize += Frame.Size;
	
	FCriticalSection.Leave();
	end;
end;

function TSGInternetConnections.HandlePacketNewConnections(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSGEthernetPacketFrame; const Date : TSGDateTime; const Time : TSGTime) : TSGBoolean;
var
	Index : TSGMaxEnum;
begin
Result := False;
if (ConnectionClasses <> nil) and (Length(ConnectionClasses) > 0) then
	for Index := High(ConnectionClasses) downto 0 do
		if ConnectionClasses[Index].PacketComparable(Frame) then
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

function TSGInternetConnections.HandlePacketConnections(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Frame : TSGEthernetPacketFrame; const Date : TSGDateTime; const Time : TSGTime) : TSGBoolean;
var
	Index : TSGMaxEnum;
begin
Result := False;
FCriticalSection.Enter();
if (FConnections <> nil) and (Length(FConnections) > 0) then
	for Index := High(FConnections) downto 0 do
		if FConnections[Index].PacketPushed(Time, Date, Frame) then
			begin
			Result := True;
			FComparablePacketsCount += 1;
			FComparablePacketsSize += Frame.Size;
			break;
			end;
FCriticalSection.Leave();
end;

procedure TSGInternetConnections.HandlePacket(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSGTime);
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
		FOutPacketsSize += Stream.Size;
		FOutPacketsCount += 1;
		
		if FModeRuntimeDataDumper or FModeRuntimePacketDumper then
			DumpOutPacket(Date, Time, Frame, Stream);
		SGKill(Frame);
		end;
end;

constructor TSGInternetConnections.Create();
begin
inherited;
FCriticalSection := TSGCriticalSection.Create();
FConnections := nil;
FOutPacketsSize := 0;
FOutPacketsCount := 0;
FComparablePacketsCount := 0;
FComparablePacketsSize := 0;
FModePacketStorage := False;
FModeDataTransfer := True;
FModeRuntimeDataDumper := False;
FModeRuntimePacketDumper := False;
FDumpDirectory := '';
FOutDumpDirectory := '';
FPacketDataFileExtension := 'ipdpd';
FPacketInfoFileExtension := 'ini';
end;

destructor TSGInternetConnections.Destroy();
var
	Index : TSGMaxEnum;
begin
if (FConnections <> nil) and (Length(FConnections) > 0) then
	for Index := 0 to High(FConnections) do
		SGKill(FConnections[Index]);
SGKill(FCriticalSection);
SGKill(FConnections);
inherited;
end;

end.
