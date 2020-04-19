{$INCLUDE Smooth.inc}

unit SmoothInternetPacketRuntimeDumper;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothDateTime
	,SmoothInternetPacketCaptureHandler
	
	,Classes
	;
const
	SDumperDeviceDirectoryIdentifier = '#DeviceDirectory';
type
	TSInternetPacketRuntimeDumper = class(TSInternetPacketCaptureHandler)
			public
		constructor Create(); override;
			private
		FGeneralDirectory : TSString;
		FPacketDataFileExtension : TSString;
		FDeviceInformationFileExtension : TSString;
		FPacketInfoFileExtension : TSString;
			private
		procedure PrintInformation(const NowDateTime : TSDateTime);
		procedure DumpPacketDataToFile(const FileName : TSString; const Stream : TStream);
		procedure DumpPacketData(const Directory : TSString; const Stream : TStream; const Time : TSTime);
		procedure ExportPacketInfoToFile(const DateTimeString, FileNameWithOutExtension : TSString; const Stream : TStream);
			protected
		procedure UpdateGeneralDirectory(const MakeDirectory : TSBoolean = True);
			public
		procedure Loop(); override;
			protected
		procedure HandlePacket(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSTime); override;
		procedure HandleDevice(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator); override;
		function HandleTimeOutUpdate(const Now : TSDateTime) : TSBoolean; override;
		end;

implementation

uses
	 SmoothFileUtils
	,SmoothLists
	,SmoothStreamUtils
	,SmoothStringUtils
	,SmoothVersion
	,SmoothInternetPacketDeterminer
	,SmoothTextFileStream
	,SmoothTextConsoleStream
	,SmoothBaseUtils
	,SmoothInternetDumperBase
	;

// ==========================================
// ======TSInternetPacketRuntimeDumper======
// ==========================================

procedure TSInternetPacketRuntimeDumper.Loop();
begin
UpdateGeneralDirectory(True);
inherited Loop();
PrintStatistic();
end;

procedure TSInternetPacketRuntimeDumper.HandleDevice(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator);
var
	DeviceDirectory : TSString;
	Device : PSInternetPacketCaptureHandlerDeviceData;
begin
Device := FindDevice(Identificator);
DeviceDirectory := FGeneralDirectory + DirectorySeparator + Device^.DeviceDescription;
SMakeDirectory(DeviceDirectory);
CreateDeviceInformationFile(Identificator, DeviceDirectory + '.' + FDeviceInformationFileExtension);
Device^.AdditionalOptions += SDoubleString(SDumperDeviceDirectoryIdentifier, DeviceDirectory);
end;

function TSInternetPacketRuntimeDumper.HandleTimeOutUpdate(const Now : TSDateTime) : TSBoolean;
begin
Result := inherited HandleTimeOutUpdate(Now);
PrintInformation(Now);
end;

procedure TSInternetPacketRuntimeDumper.DumpPacketDataToFile(const FileName : TSString; const Stream : TStream);
var
	FileStream : TFileStream = nil;
begin
FileStream := TFileStream.Create(FileName, fmCreate);
Stream.Position := 0;
SCopyPartStreamToStream(Stream, FileStream, Stream.Size);
Stream.Position := 0;
FileStream.Destroy();
FileStream := nil;
end;

procedure TSInternetPacketRuntimeDumper.HandlePacket(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSTime);
var
	DeviceDirectory : TSString = '';
begin
DeviceDirectory := (SDumperDeviceDirectoryIdentifier in FindDevice(Identificator)^.AdditionalOptions);
if DeviceDirectory <> '' then
	DumpPacketData(DeviceDirectory, Stream, Time);
end;

procedure TSInternetPacketRuntimeDumper.ExportPacketInfoToFile(const DateTimeString, FileNameWithOutExtension : TSString; const Stream : TStream);
var
	TextFile : TSTextFileStream = nil;
begin
TextFile := TSTextFileStream.Create(SFreeFileName(FileNameWithOutExtension + Iff(FPacketInfoFileExtension <> '', '.' + FPacketInfoFileExtension, ''), ''));
TextFile.WriteLn('[packet]');
TextFile.WriteLn(['DataTime=', DateTimeString]);
TextFile.WriteLn(['Size=', Stream.Size]);
TextFile.WriteLn();
Stream.Position := 0;
SWritePacketInfo(TextFile, Stream, False);
TextFile.Destroy();
TextFile := nil;
end;

procedure TSInternetPacketRuntimeDumper.DumpPacketData(const Directory : TSString; const Stream : TStream; const Time : TSTime);
var
	DateTimeString : TSString;
	Description : TSString;
	FileNameWithOutExtension : TSString;
	FileName : TSString;
	DataFileName : TSString;
begin
DateTimeString := SDateTimeCorrectionString(Time, True);
FileNameWithOutExtension := Directory + DirectorySeparator + DateTimeString;
Description := SPacketDescription(Stream);
if Description <> '' then
	FileNameWithOutExtension += ' (' + Description + ')';
FileName := FileNameWithOutExtension + Iff(FPacketDataFileExtension <> '', '.' + FPacketDataFileExtension, '');
DataFileName := SFreeFileName(FileName, '');

DumpPacketDataToFile(DataFileName, Stream);
ExportPacketInfoToFile(DateTimeString, FileNameWithOutExtension, Stream);
end;

procedure TSInternetPacketRuntimeDumper.PrintInformation(const NowDateTime : TSDateTime);
begin
SPrintEngineVersion();
with TSTextConsoleStream.Create() do
	begin
	TextColor(15);
	Write('После ');
	TextColor(10);
	Write(STextTimeBetweenDates(FTimeBegining, NowDateTime, 'ENG'));
	TextColor(15);
	Write(' всего перехвачено ');
	TextColor(12);
	Write(SMemorySizeToString(AllDataSize(), 'EN'));
	TextColor(15);
	WriteLn(' данных.');
	TextColor(7);
	
	Destroy();
	end;
end;

procedure TSInternetPacketRuntimeDumper.UpdateGeneralDirectory(const MakeDirectory : TSBoolean = True);
begin
FGeneralDirectory := SAplicationFileDirectory() + DirectorySeparator + SDateTimeString(True) + ' Packet Dump';
if MakeDirectory then
	SMakeDirectory(FGeneralDirectory);
end;

constructor TSInternetPacketRuntimeDumper.Create();
begin
inherited;
UpdateGeneralDirectory(False);
FPacketDataFileExtension := SmoothInternetDumperBase.PacketFileExtension;
FDeviceInformationFileExtension := SmoothInternetDumperBase.DeviceInformationFileExtension;
FPacketInfoFileExtension := SmoothInternetDumperBase.PacketInfoFileExtension;
PossibilityBreakLoopFromConsole := True;
ProcessTimeOutUpdates := True;
InfoTimeOut := 90;
end;

end.
