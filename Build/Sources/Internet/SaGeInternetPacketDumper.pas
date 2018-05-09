{$INCLUDE SaGe.inc}

unit SaGeInternetPacketDumper;

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
	TSGInternetPacketDumper = class(TSGInternetPacketCaptureHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FGeneralDirectory : TSGString;
		FPacketDataFileExtension : TSGString;
		FDeviceInfarmationFileExtension : TSGString;
		FPacketInfoFileExtension : TSGString;
			private
		procedure PrintInformation(const NowDateTime : TSGDateTime);
		procedure DumpPacketDataToFile(const FileName : TSGString; const Stream : TStream);
		procedure DumpPacketData(const Directory : TSGString; const Stream : TStream; const Time : TSGTime);
		procedure ExportPacketInfoToFile(const DateTimeString, FileNameWithOutExtension : TSGString; const Stream : TStream);
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
	,SaGeStringUtils
	,SaGeVersion
	,SaGeInternetPacketDeterminer
	,SaGeTextFileStream
	
	,Crt
	;

// ===================================
// ======TSGInternetPacketDumper======
// ===================================

procedure TSGInternetPacketDumper.Loop();
begin
inherited Loop();
PrintStatistic();
end;

procedure TSGInternetPacketDumper.HandleDevice(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator);
var
	DeviceDirectory : TSGString;
	Device : PSGInternetPacketCaptureHandlerDeviceData;
begin
Device := FindDevice(Identificator);
DeviceDirectory := FGeneralDirectory + DirectorySeparator + Device^.DeviceDescription;
SGMakeDirectory(DeviceDirectory);
CreateDeviceInformationFile(Identificator, DeviceDirectory + '.' + FDeviceInfarmationFileExtension);
Device^.AdditionalOptions += SGDoubleString(SGDumperDeviceDirectoryIdentifier, DeviceDirectory);
end;

function TSGInternetPacketDumper.HandleTimeOutUpdate(const Now : TSGDateTime) : TSGBoolean;
begin
Result := inherited HandleTimeOutUpdate(Now);
PrintInformation(Now);
end;

procedure TSGInternetPacketDumper.DumpPacketDataToFile(const FileName : TSGString; const Stream : TStream);
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

procedure TSGInternetPacketDumper.HandlePacket(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSGTime);
var
	DeviceDirectory : TSGString = '';
begin
DeviceDirectory := (SGDumperDeviceDirectoryIdentifier in FindDevice(Identificator)^.AdditionalOptions);
if DeviceDirectory <> '' then
	DumpPacketData(DeviceDirectory, Stream, Time);
end;

procedure TSGInternetPacketDumper.ExportPacketInfoToFile(const DateTimeString, FileNameWithOutExtension : TSGString; const Stream : TStream);
var
	TextFile : TSGTextFileStream = nil;
begin
TextFile := TSGTextFileStream.Create(SGFreeFileName(FileNameWithOutExtension + FPacketInfoFileExtension, ''));
TextFile.WriteLn('[packet]');
TextFile.WriteLn(['DataTime=', DateTimeString]);
TextFile.WriteLn(['Size=', Stream.Size]);
TextFile.WriteLn();
Stream.Position := 0;
SGWritePacketInfo(TextFile, Stream, False);
TextFile.Destroy();
TextFile := nil;
end;

procedure TSGInternetPacketDumper.DumpPacketData(const Directory : TSGString; const Stream : TStream; const Time : TSGTime);
var
	DateTimeString : TSGString;
	FileNameWithOutExtension : TSGString;
begin
DateTimeString := SGDateTimeCorrectionString(Time, True);
FileNameWithOutExtension := Directory + DirectorySeparator + DateTimeString + '.';
DumpPacketDataToFile(SGFreeFileName(FileNameWithOutExtension + FPacketDataFileExtension, ''), Stream);
ExportPacketInfoToFile(DateTimeString, FileNameWithOutExtension, Stream);
end;

procedure TSGInternetPacketDumper.PrintInformation(const NowDateTime : TSGDateTime);
begin
SGPrintEngineVersion();
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
end;

constructor TSGInternetPacketDumper.Create();
begin
inherited;
FGeneralDirectory := SGAplicationFileDirectory() + DirectorySeparator + SGDateTimeString(True) + ' Packet Dump';
SGMakeDirectory(FGeneralDirectory);
FPacketDataFileExtension := 'ipdpd';
FDeviceInfarmationFileExtension := 'ini';
FPacketInfoFileExtension := 'ini';
PossibilityBreakLoopFromConsole := True;
ProcessTimeOutUpdates := True;
InfoTimeOut := 90;
end;

destructor TSGInternetPacketDumper.Destroy();
begin
inherited;
end;

end.
