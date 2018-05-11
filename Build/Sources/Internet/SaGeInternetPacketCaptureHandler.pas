{$INCLUDE SaGe.inc}

unit SaGeInternetPacketCaptureHandler;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeDateTime
	,SaGeInternetPacketCaptor
	,SaGeCasesOfPrint
	
	,Classes
	;

type
	TSGInternetPacketCaptureHandlerDeviceIdentificator = TSGUInt64;
	PSGInternetPacketCaptureHandlerDeviceData = ^ TSGInternetPacketCaptureHandlerDeviceData;
	TSGInternetPacketCaptureHandlerDeviceData = object
			public
		Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator;
		Device : TSGString;
		DeviceDescription : TSGString;
		AdditionalOptions : TSGDoubleStrings;
			public
		// Statistics
		CountPackets : TSGUInt64;
		CountPacketsSize : TSGUInt64;
		CountDefectivePackets : TSGUInt64;
			public
		property DeviceName : TSGString read Device;
		end;
	TSGInternetPacketCaptureHandlerDevicesData = packed array of TSGInternetPacketCaptureHandlerDeviceData;
	
	TSGInternetPacketCaptureHandler = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FDevicesData  : TSGInternetPacketCaptureHandlerDevicesData;
		FPacketCaptor : TSGInternetPacketCaptor;
			protected
		FTimeBegining : TSGDateTime;
		FTimeLastUpdateInfo : TSGDateTime;
		FPossibilityBreakLoopFromConsole : TSGBoolean;
		FProcessTimeOutUpdates : TSGBoolean;
		FInfoTimeOut : TSGUInt64;
			public
		property PossibilityBreakLoopFromConsole : TSGBoolean read FPossibilityBreakLoopFromConsole write FPossibilityBreakLoopFromConsole;
		property ProcessTimeOutUpdates : TSGBoolean read FProcessTimeOutUpdates write FProcessTimeOutUpdates;
		property InfoTimeOut : TSGUInt64 read FInfoTimeOut write FInfoTimeOut;
		property TimeBegining : TSGDateTime read FTimeBegining;
		property PacketCaptor : TSGInternetPacketCaptor read FPacketCaptor;
			protected
		function AllDataSize() : TSGUInt64;
		function FindDevice(const DeviceName : TSGString) : PSGInternetPacketCaptureHandlerDeviceData;
		function FindDevice(const DeviceIdentificator : TSGInternetPacketCaptureHandlerDeviceIdentificator) : PSGInternetPacketCaptureHandlerDeviceData;
		function AddDevice(const DeviceData : TSGInternetPacketCaptorDeviceData) : PSGInternetPacketCaptureHandlerDeviceData;
		procedure WriteConsoleString(const Str : TSGString);
			protected
		procedure PrintStatistic(const CasesOfPrint : TSGCasesOfPrint = [SGCasePrint, SGCaseLog]);
		procedure CreateDeviceInformationFile(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const FileName : TSGString);
			public
		function Start() : TSGBoolean;
		procedure Stop();
		function Update() : TSGBoolean;
		procedure Loop(); virtual;
		procedure HandlePacket(const Packet : TSGInternetCaptorPacket);
			protected
		procedure HandlePacket(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSGTime); virtual;
		procedure HandleDevice(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator); virtual;
		function HandleTimeOutUpdate(const Now : TSGDateTime) : TSGBoolean; virtual;
		end;

implementation

uses
	 SaGeStringUtils
	,SaGeLog
	,SaGeVersion
	,SaGeInternetBase
	,SaGeTextFileStream
	,SaGePCapUtils
	
	,Crt
	;

// ====================================================
// ======TSGInternetPacketCaptureHandler CallBack======
// ====================================================

procedure SGPacketCaptureHandler_CallBack(Self : TSGInternetPacketCaptureHandler; Packet : TSGInternetCaptorPacket);
begin
Self.HandlePacket(Packet);
end;

// ===========================================
// ======TSGInternetPacketCaptureHandler======
// ===========================================

procedure TSGInternetPacketCaptureHandler.PrintStatistic(const CasesOfPrint : TSGCasesOfPrint = [SGCasePrint, SGCaseLog]);
var
	Index : TSGMaxEnum;
begin
if (CasesOfPrint <> []) and (FDevicesData <> nil) and (Length(FDevicesData) > 0) then
	begin
	TextColor(7);
	SGHint(['Capture statistics:'], CasesOfPrint);
	for Index := 0 to High(FDevicesData) do
		begin
		SGHint(['    Device "', FDevicesData[Index].DeviceDescription, '":'], CasesOfPrint);
		SGHint(['        Count packets = ', FDevicesData[Index].CountPackets], CasesOfPrint);
		SGHint(['        Size packets = ', SGGetSizeString(FDevicesData[Index].CountPacketsSize, 'EN')], CasesOfPrint);
		SGHint(['        Defective packets = ', FDevicesData[Index].CountDefectivePackets], CasesOfPrint);
		end;
	end;
end;

procedure TSGInternetPacketCaptureHandler.CreateDeviceInformationFile(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const FileName : TSGString);
var
	TextFile : TSGTextFileStream = nil;
	Device : PSGInternetPacketCaptureHandlerDeviceData = nil;
	Index : TSGMaxEnum;
begin
Device := FindDevice(Identificator);
TextFile := TSGTextFileStream.Create(FileName);
TextFile.WriteLn('[Device]');
TextFile.WriteLn(['Name= ', Device^.DeviceName]);
TextFile.WriteLn(['System Name= ', SGPcapInternetAdapterSystemName(Device^.DeviceName)]);
TextFile.WriteLn(['Pcap Description= ', SGPcapInternetAdapterPcapDescriptionFromName(Device^.DeviceName)]);
TextFile.WriteLn(['System Description= ', SGPcapInternetAdapterSystemDescriptionFromName(Device^.DeviceName)]);
if (Device^.AdditionalOptions <> nil) and (Length(Device^.AdditionalOptions) > 0) then
	for Index := 0 to High(Device^.AdditionalOptions) do
		TextFile.WriteLn([Device^.AdditionalOptions[Index][0], '= ', Device^.AdditionalOptions[Index][1]]);
TextFile.Destroy();
TextFile := nil;
end;

function TSGInternetPacketCaptureHandler.HandleTimeOutUpdate(const Now : TSGDateTime) : TSGBoolean;
begin
Result := False;
end;

procedure TSGInternetPacketCaptureHandler.HandleDevice(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator); 
begin
end;

procedure TSGInternetPacketCaptureHandler.HandlePacket(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSGTime);
begin
end;

function TSGInternetPacketCaptureHandler.AllDataSize() : TSGUInt64;
var
	Index : TSGMaxEnum;
begin
Result := 0;
if (FDevicesData <> nil) and (Length(FDevicesData) > 0) then
	for Index := 0 to High(FDevicesData) do
		Result := FDevicesData[Index].CountPacketsSize;
end;

procedure TSGInternetPacketCaptureHandler.HandlePacket(const Packet : TSGInternetCaptorPacket);
var
	Device : PSGInternetPacketCaptureHandlerDeviceData = nil;
	Stream : TStream = nil;
begin
Device := FindDevice(SGPCharToString(Packet.Device^.DeviceName));
if Device = nil then
	Device := AddDevice(Packet.Device^);
if Device <> nil then
	if Packet.Data.Header.CapLen = Packet.Data.Header.Len then
		begin
		Device^.CountPackets += 1;
		Device^.CountPacketsSize += Packet.Data.Header.CapLen;
		
		Stream := Packet.Data.CreateStream();
		HandlePacket(Device^.Identificator, Stream, TSGTime.Import(Packet.Data.Header.ts.tv_sec, Packet.Data.Header.ts.tv_usec));
		Stream.Destroy();
		Stream := nil;
		end
	else
		Device^.CountDefectivePackets += 1;
end;

function TSGInternetPacketCaptureHandler.FindDevice(const DeviceIdentificator : TSGInternetPacketCaptureHandlerDeviceIdentificator) : PSGInternetPacketCaptureHandlerDeviceData;
var
	Index : TSGMaxEnum;
begin
Result := nil;
if (FDevicesData <> nil) and (Length(FDevicesData) > 0) then
	for Index := 0 to High(FDevicesData) do
		if FDevicesData[Index].Identificator = DeviceIdentificator then
			begin
			Result := @FDevicesData[Index];
			break;
			end;
end;

function TSGInternetPacketCaptureHandler.FindDevice(const DeviceName : TSGString) : PSGInternetPacketCaptureHandlerDeviceData;
var
	Index : TSGMaxEnum;
begin
Result := nil;
if (FDevicesData <> nil) and (Length(FDevicesData) > 0) then
	for Index := 0 to High(FDevicesData) do
		if FDevicesData[Index].Device = DeviceName then
			begin
			Result := @FDevicesData[Index];
			break;
			end;
end;

function TSGInternetPacketCaptureHandler.AddDevice(const DeviceData : TSGInternetPacketCaptorDeviceData) : PSGInternetPacketCaptureHandlerDeviceData;
begin
if (FDevicesData = nil) or (Length(FDevicesData) = 0) then
	SetLength(FDevicesData, 1)
else
	SetLength(FDevicesData, Length(FDevicesData) + 1);
Result := @FDevicesData[High(FDevicesData)];
Result^.Device := SGPCharToString(DeviceData.DeviceName);
Result^.DeviceDescription := DeviceData.DeviceDescription;
Result^.CountPackets := 0;
Result^.CountDefectivePackets := 0;
Result^.CountPacketsSize := 0;
Result^.Identificator := Length(FDevicesData);
Result^.AdditionalOptions := nil;
Result^.AdditionalOptions += SGDoubleString('IPv4 Net', SGIPv4AddressToString(DeviceData.DeviceNet));
Result^.AdditionalOptions += SGDoubleString('IPv4 Mask', SGIPv4AddressToString(DeviceData.DeviceMask));

HandleDevice(Result^.Identificator);
end;

procedure TSGInternetPacketCaptureHandler.WriteConsoleString(const Str : TSGString);
begin
SGPrintEngineVersion();
SGHint([Str], [SGCasePrint]);
end;

function TSGInternetPacketCaptureHandler.Start() : TSGBoolean;
var
	InitStartTime : TSGDateTime;
begin
Result := False;
FillChar(FTimeBegining, SizeOf(FTimeBegining), 0);

InitStartTime.Get();
if FPossibilityBreakLoopFromConsole then
	WriteConsoleString('Initializing devices...');
FPacketCaptor := TSGInternetPacketCaptor.Create();
FPacketCaptor.CallBack := TSGInternetPacketCaptorCallBack(@SGPacketCaptureHandler_CallBack);
FPacketCaptor.CallBackData := Self;
Result := FPacketCaptor.BeginLoopThreads(False);
if Result then
	begin
	FTimeBegining.Get();
	if FProcessTimeOutUpdates then
		FTimeLastUpdateInfo := FTimeBegining;
	
	if FPossibilityBreakLoopFromConsole then
		begin
		WriteConsoleString('Initializing was completed in ' + SGTextTimeBetweenDates(InitStartTime, FTimeBegining, 'ENG') + '.');
		WriteConsoleString('Capturing begins. Press Escape to stop!');
		end;
	
	FPacketCaptor.DefaultDelay();
	end
else
	Stop();
end;

procedure TSGInternetPacketCaptureHandler.Stop();
begin
if FPacketCaptor <> nil then
	begin
	FPacketCaptor.Destroy();
	FPacketCaptor := nil;
	end;
end;

function TSGInternetPacketCaptureHandler.Update() : TSGBoolean;
var
	Now : TSGDateTime;
begin
Result := FPacketCaptor.AllThreadsFinished();
if (not Result) and FPossibilityBreakLoopFromConsole and KeyPressed() and (ReadKey = #27) then
	Result := True;
if (not Result) and FProcessTimeOutUpdates then
	begin
	Now.Get();
	if (Now - FTimeLastUpdateInfo).GetPastMiliSeconds() > FInfoTimeOut then
		begin
		FTimeLastUpdateInfo := Now;
		Result := HandleTimeOutUpdate(Now);
		end;
	end;
end;

procedure TSGInternetPacketCaptureHandler.Loop();
begin
if Start() then
	begin
	while not Update() do
		FPacketCaptor.DefaultDelay();
	Stop();
	end;
end;

constructor TSGInternetPacketCaptureHandler.Create();
begin
inherited;
FDevicesData := nil;
FPacketCaptor := nil;
FInfoTimeOut := 100;
FillChar(FTimeBegining, SizeOf(FTimeBegining), 0);
FillChar(FTimeLastUpdateInfo, SizeOf(FTimeLastUpdateInfo), 0);
FPossibilityBreakLoopFromConsole := False;
FProcessTimeOutUpdates := False;
end;

destructor TSGInternetPacketCaptureHandler.Destroy();
var
	Index : TSGMaxEnum;
begin
Stop();
if (FDevicesData <> nil) and (Length(FDevicesData) > 0) then
	begin
	for Index := 0 to High(FDevicesData) do
		SGKill(FDevicesData[Index].AdditionalOptions);
	SetLength(FDevicesData, 0);
	end;
inherited;
end;

end.
