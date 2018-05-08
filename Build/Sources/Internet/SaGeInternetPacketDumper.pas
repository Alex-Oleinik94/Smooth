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
			public
		procedure Loop(); override;
			protected
		procedure HandlePacket(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSGTime); override;
		procedure HandleDevice(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator); override;
		function HandleTimeOutUpdate(const Now : TSGDateTime) : TSGBoolean; override;
		end;

procedure SGInternetPacketDumper();

implementation

uses
	 SaGeFileUtils
	,SaGeStringUtils
	,SaGeVersion
	,SaGeInternetPacketDeterminer
	,SaGeTextFileStream
	
	,Crt
	;

procedure SGInternetPacketDumper();
begin
with TSGInternetPacketDumper.Create() do
	begin
	Loop();
	Destroy();
	end;
end;

// ===================================
// ======TSGInternetPacketDumper======
// ===================================

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

procedure TSGInternetPacketDumper.DumpPacketData(const Directory : TSGString; const Stream : TStream; const Time : TSGTime);
var
	DateTimeString : TSGString;

procedure ProcessPacket();
var
	FileName : TSGString;
begin
FileName := Directory + DirectorySeparator + DateTimeString + '.' + FPacketDataFileExtension;
FileName := SGFreeFileName(FileName, '');
DumpPacketDataToFile(FileName, Stream);
end;

procedure ProcessPacketInfo();
var
	FileName : TSGString;
	TextFile : TSGTextFileStream = nil;
begin
FileName := Directory + DirectorySeparator + DateTimeString + '.' + FPacketInfoFileExtension;
FileName := SGFreeFileName(FileName, '');
TextFile := TSGTextFileStream.Create(FileName);
TextFile.WriteLn('[packet]');
TextFile.WriteLn(['DataTime=', DateTimeString]);
TextFile.WriteLn(['Size=', Stream.Size]);
TextFile.WriteLn();
SGWritePacketInfo(TextFile, Stream, False);
TextFile.Destroy();
TextFile := nil;
end;

begin
DateTimeString := SGDateTimeCorrectionString(Time, True);
ProcessPacket();
ProcessPacketInfo();
end;

procedure TSGInternetPacketDumper.PrintInformation(const NowDateTime : TSGDateTime);
begin
SGPrintEngineVersion();
TextColor(15);
Write('После ');
TextColor(10);
Write(SGTextTimeBetweenDates(FBeginingTime, NowDateTime, 'ENG'));
TextColor(15);
Write(' всего перехвачено ');
TextColor(12);
Write(SGGetSizeString(AllDataSize(), 'EN'));
TextColor(15);
WriteLn(' данных.');
TextColor(7);
end;

procedure TSGInternetPacketDumper.Loop();
begin
PossibilityBreakLoopFromConsole := True;
ProcessTimeOutUpdates := True;
inherited Loop();
end;

constructor TSGInternetPacketDumper.Create();
begin
inherited;
FGeneralDirectory := SGAplicationFileDirectory() + DirectorySeparator + SGDateTimeString(True) + ' Packet Dump';
SGMakeDirectory(FGeneralDirectory);
FPacketDataFileExtension := 'ipdpd';
FDeviceInfarmationFileExtension := 'ini';
FPacketInfoFileExtension := 'ini';
end;

destructor TSGInternetPacketDumper.Destroy();
begin
inherited;
end;

end.
