{$INCLUDE SaGe.inc}

unit SaGeInternetPacketFileDumper;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeDateTime
	,SaGeInternetPacketCaptureHandler
	,SaGePCapNG
	
	,Classes
	;
type
	TSGInternetPacketDumper = class(TSGInternetPacketCaptureHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FDumpFileName : TSGString;
		FDump : TSGPCapNGFile;
			private
		procedure PrintInformation(const NowDateTime : TSGDateTime);
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
begin

end;

function TSGInternetPacketDumper.HandleTimeOutUpdate(const Now : TSGDateTime) : TSGBoolean;
begin
Result := inherited HandleTimeOutUpdate(Now);
PrintInformation(Now);
end;

procedure TSGInternetPacketDumper.HandlePacket(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSGTime);
begin

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
FDumpFileName := '';
FDump := nil;
end;

destructor TSGInternetPacketDumper.Destroy();
begin
if FDump <> nil then
	begin
	FDump.Destroy();
	FDump := nil;
	end;
inherited;
end;

end.
