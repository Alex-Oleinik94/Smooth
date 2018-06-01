{$INCLUDE SaGe.inc}

unit SaGeInternetPacketRuntimeDumper;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeDateTime
	,SaGeInternetPacketCaptureHandler
	
	,Classes
	;
const
	SGDumperDeviceDirectoryIdentifier = '#DeviceDirectory';
type
	TSGInternetPacketRuntimeDumper = class(TSGInternetPacketCaptureHandler)
			public
		constructor Create(); override;
			private
		FGeneralDirectory : TSGString;
		FPacketDataFileExtension : TSGString;
		FDeviceInformationFileExtension : TSGString;
		FPacketInfoFileExtension : TSGString;
			private
		procedure PrintInformation(const NowDateTime : TSGDateTime);
		procedure DumpPacketDataToFile(const FileName : TSGString; const Stream : TStream);
		procedure DumpPacketData(const Directory : TSGString; const Stream : TStream; const Time : TSGTime);
		procedure ExportPacketInfoToFile(const DateTimeString, FileNameWithOutExtension : TSGString; const Stream : TStream);
			protected
		procedure UpdateGeneralDirectory(const MakeDirectory : TSGBoolean = True);
			public
		procedure Loop(); override;
			protected
		procedure HandlePacket(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSGTime); override;
		procedure HandleDevice(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator); override;
		function HandleTimeOutUpdate(const Now : TSGDateTime) : TSGBoolean; override;
		end;

implementation

uses
	 SaGeFileUtils
	,SaGeStreamUtils
	,SaGeStringUtils
	,SaGeVersion
	,SaGeInternetPacketDeterminer
	,SaGeTextFileStream
	,SaGeTextConsoleStream
	,SaGeBaseUtils
	,SaGeInternetDumperBase
	;

// ==========================================
// ======TSGInternetPacketRuntimeDumper======
// ==========================================

procedure TSGInternetPacketRuntimeDumper.Loop();
begin
UpdateGeneralDirectory(True);
inherited Loop();
PrintStatistic();
end;

procedure TSGInternetPacketRuntimeDumper.HandleDevice(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator);
var
	DeviceDirectory : TSGString;
	Device : PSGInternetPacketCaptureHandlerDeviceData;
begin
Device := FindDevice(Identificator);
DeviceDirectory := FGeneralDirectory + DirectorySeparator + Device^.DeviceDescription;
SGMakeDirectory(DeviceDirectory);
CreateDeviceInformationFile(Identificator, DeviceDirectory + '.' + FDeviceInformationFileExtension);
Device^.AdditionalOptions += SGDoubleString(SGDumperDeviceDirectoryIdentifier, DeviceDirectory);
end;

function TSGInternetPacketRuntimeDumper.HandleTimeOutUpdate(const Now : TSGDateTime) : TSGBoolean;
begin
Result := inherited HandleTimeOutUpdate(Now);
PrintInformation(Now);
end;

procedure TSGInternetPacketRuntimeDumper.DumpPacketDataToFile(const FileName : TSGString; const Stream : TStream);
var
	FileStream : TFileStream = nil;
begin
FileStream := TFileStream.Create(FileName, fmCreate);
Stream.Position := 0;
SGCopyPartStreamToStream(Stream, FileStream, Stream.Size);
Stream.Position := 0;
FileStream.Destroy();
FileStream := nil;
end;

procedure TSGInternetPacketRuntimeDumper.HandlePacket(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSGTime);
var
	DeviceDirectory : TSGString = '';
begin
DeviceDirectory := (SGDumperDeviceDirectoryIdentifier in FindDevice(Identificator)^.AdditionalOptions);
if DeviceDirectory <> '' then
	DumpPacketData(DeviceDirectory, Stream, Time);
end;

procedure TSGInternetPacketRuntimeDumper.ExportPacketInfoToFile(const DateTimeString, FileNameWithOutExtension : TSGString; const Stream : TStream);
var
	TextFile : TSGTextFileStream = nil;
begin
TextFile := TSGTextFileStream.Create(SGFreeFileName(FileNameWithOutExtension + Iff(FPacketInfoFileExtension <> '', '.' + FPacketInfoFileExtension, ''), ''));
TextFile.WriteLn('[packet]');
TextFile.WriteLn(['DataTime=', DateTimeString]);
TextFile.WriteLn(['Size=', Stream.Size]);
TextFile.WriteLn();
Stream.Position := 0;
SGWritePacketInfo(TextFile, Stream, False);
TextFile.Destroy();
TextFile := nil;
end;

procedure TSGInternetPacketRuntimeDumper.DumpPacketData(const Directory : TSGString; const Stream : TStream; const Time : TSGTime);
var
	DateTimeString : TSGString;
	Description : TSGString;
	FileNameWithOutExtension : TSGString;
	FileName : TSGString;
	DataFileName : TSGString;
begin
DateTimeString := SGDateTimeCorrectionString(Time, True);
FileNameWithOutExtension := Directory + DirectorySeparator + DateTimeString;
Description := SGPacketDescription(Stream);
if Description <> '' then
	FileNameWithOutExtension += ' (' + Description + ')';
FileName := FileNameWithOutExtension + Iff(FPacketDataFileExtension <> '', '.' + FPacketDataFileExtension, '');
DataFileName := SGFreeFileName(FileName, '');

DumpPacketDataToFile(DataFileName, Stream);
ExportPacketInfoToFile(DateTimeString, FileNameWithOutExtension, Stream);
end;

procedure TSGInternetPacketRuntimeDumper.PrintInformation(const NowDateTime : TSGDateTime);
begin
SGPrintEngineVersion();
with TSGTextConsoleStream.Create() do
	begin
	TextColor(15);
	Write('После ');
	TextColor(10);
	Write(SGTextTimeBetweenDates(FTimeBegining, NowDateTime, 'ENG'));
	TextColor(15);
	Write(' всего перехвачено ');
	TextColor(12);
	Write(SGGetSizeString(AllDataSize(), 'EN'));
	TextColor(15);
	WriteLn(' данных.');
	TextColor(7);
	
	Destroy();
	end;
end;

procedure TSGInternetPacketRuntimeDumper.UpdateGeneralDirectory(const MakeDirectory : TSGBoolean = True);
begin
FGeneralDirectory := SGAplicationFileDirectory() + DirectorySeparator + SGDateTimeString(True) + ' Packet Dump';
if MakeDirectory then
	SGMakeDirectory(FGeneralDirectory);
end;

constructor TSGInternetPacketRuntimeDumper.Create();
begin
inherited;
UpdateGeneralDirectory(False);
FPacketDataFileExtension := SaGeInternetDumperBase.PacketFileExtension;
FDeviceInformationFileExtension := SaGeInternetDumperBase.DeviceInformationFileExtension;
FPacketInfoFileExtension := SaGeInternetDumperBase.PacketInfoFileExtension;
PossibilityBreakLoopFromConsole := True;
ProcessTimeOutUpdates := True;
InfoTimeOut := 90;
end;

end.
