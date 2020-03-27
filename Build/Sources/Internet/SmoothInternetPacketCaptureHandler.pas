{$INCLUDE Smooth.inc}

unit SmoothInternetPacketCaptureHandler;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothBaseClasses
	,SmoothDateTime
	,SmoothInternetPacketCaptor
	,SmoothCasesOfPrint
	,SmoothCriticalSection
	
	,Classes
	;

type
	TSInternetPacketCaptureHandlerDeviceIdentificator = TSUInt64;
	PSInternetPacketCaptureHandlerDeviceData = ^ TSInternetPacketCaptureHandlerDeviceData;
	TSInternetPacketCaptureHandlerDeviceData = object
			public
		Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator;
		Device : TSString;
		DeviceDescription : TSString;
		AdditionalOptions : TSDoubleStrings;
			public
		// Statistics
		CountPackets : TSUInt64;
		CountPacketsSize : TSUInt64;
		CountDefectivePackets : TSUInt64;
			public
		property DeviceName : TSString read Device;
		end;
	TSInternetPacketCaptureHandlerDevicesData = packed array of TSInternetPacketCaptureHandlerDeviceData;
	
	TSInternetPacketCaptureHandler = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FCriticalSection : TSCriticalSection;
		FDevicesData  : TSInternetPacketCaptureHandlerDevicesData;
		FPacketCaptor : TSInternetPacketCaptor;
			protected
		FTimeBegining : TSDateTime;
		FTimeLastUpdateInfo : TSDateTime;
		FPossibilityBreakLoopFromConsole : TSBoolean;
		FProcessTimeOutUpdates : TSBoolean;
		FInfoTimeOut : TSUInt64;
			public
		property PossibilityBreakLoopFromConsole : TSBoolean read FPossibilityBreakLoopFromConsole write FPossibilityBreakLoopFromConsole;
		property ProcessTimeOutUpdates : TSBoolean read FProcessTimeOutUpdates write FProcessTimeOutUpdates;
		property InfoTimeOut : TSUInt64 read FInfoTimeOut write FInfoTimeOut;
		property TimeBegining : TSDateTime read FTimeBegining;
		property PacketCaptor : TSInternetPacketCaptor read FPacketCaptor;
			protected
		function AllDataSize() : TSUInt64;
		function FindDevice(const DeviceName : TSString) : PSInternetPacketCaptureHandlerDeviceData;
		function FindDevice(const DeviceIdentificator : TSInternetPacketCaptureHandlerDeviceIdentificator) : PSInternetPacketCaptureHandlerDeviceData;
		function FindDeviceOption(const DeviceIdentificator : TSInternetPacketCaptureHandlerDeviceIdentificator; const OptionName : TSString) : TSString;
		function AddDevice(const DeviceData : TSInternetPacketCaptorDeviceData) : PSInternetPacketCaptureHandlerDeviceData;
		procedure WriteConsoleString(const Str : TSString; const Log : TSBoolean = True);
			protected
		procedure PrintStatistic(const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog]);
		procedure CreateDeviceInformationFile(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator; const FileName : TSString);
			public
		function Start() : TSBoolean; virtual;
		procedure Stop();
		function Update() : TSBoolean;
		procedure Loop(); virtual;
		procedure HandlePacket(const Packet : TSInternetCaptorPacket);
			protected
		procedure HandlePacket(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSTime); virtual;
		procedure HandleDevice(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator); virtual;
		function HandleTimeOutUpdate(const Now : TSDateTime) : TSBoolean; virtual;
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothLog
	,SmoothVersion
	,SmoothInternetBase
	,SmoothTextFileStream
	,SmoothPCapUtils
	
	,Crt
	;

// ====================================================
// ======TSInternetPacketCaptureHandler CallBack======
// ====================================================

procedure SPacketCaptureHandler_CallBack(Self : TSInternetPacketCaptureHandler; Packet : TSInternetCaptorPacket);
begin
Self.HandlePacket(Packet);
end;

// ===========================================
// ======TSInternetPacketCaptureHandler======
// ===========================================

procedure TSInternetPacketCaptureHandler.PrintStatistic(const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog]);
var
	Index : TSMaxEnum;
begin
if (CasesOfPrint <> []) and (FDevicesData <> nil) and (Length(FDevicesData) > 0) then
	begin
	TextColor(7);
	SHint(['Capture statistics (', STextTimeBetweenDates(FTimeBegining, SNow(), 'EN'), '):'], CasesOfPrint);
	for Index := 0 to High(FDevicesData) do
		begin
		SHint(['    Device "', FDevicesData[Index].DeviceDescription, '":'], CasesOfPrint);
		SHint(['        Count packets = ', FDevicesData[Index].CountPackets], CasesOfPrint);
		SHint(['        Size packets = ', SGetSizeString(FDevicesData[Index].CountPacketsSize, 'EN')], CasesOfPrint);
		SHint(['        Defective packets = ', FDevicesData[Index].CountDefectivePackets], CasesOfPrint);
		end;
	end;
end;

procedure TSInternetPacketCaptureHandler.CreateDeviceInformationFile(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator; const FileName : TSString);
var
	TextFile : TSTextFileStream = nil;
	Device : PSInternetPacketCaptureHandlerDeviceData = nil;
	Index : TSMaxEnum;
begin
Device := FindDevice(Identificator);
TextFile := TSTextFileStream.Create(FileName);
TextFile.WriteLn('[Device]');
TextFile.WriteLn(['Name= ', Device^.DeviceName]);
TextFile.WriteLn(['System Name= ', SPcapInternetAdapterSystemName(Device^.DeviceName)]);
TextFile.WriteLn(['Pcap Description= ', SPcapInternetAdapterPcapDescriptionFromName(Device^.DeviceName)]);
TextFile.WriteLn(['System Description= ', SPcapInternetAdapterSystemDescriptionFromName(Device^.DeviceName)]);
if (Device^.AdditionalOptions <> nil) and (Length(Device^.AdditionalOptions) > 0) then
	for Index := 0 to High(Device^.AdditionalOptions) do
		TextFile.WriteLn([Device^.AdditionalOptions[Index][0], '= ', Device^.AdditionalOptions[Index][1]]);
TextFile.Destroy();
TextFile := nil;
end;

function TSInternetPacketCaptureHandler.HandleTimeOutUpdate(const Now : TSDateTime) : TSBoolean;
begin
Result := False;
end;

procedure TSInternetPacketCaptureHandler.HandleDevice(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator); 
begin
end;

procedure TSInternetPacketCaptureHandler.HandlePacket(const Identificator : TSInternetPacketCaptureHandlerDeviceIdentificator; const Stream : TStream; const Time : TSTime);
begin
end;

function TSInternetPacketCaptureHandler.AllDataSize() : TSUInt64;
var
	Index : TSMaxEnum;
begin
Result := 0;
if (FDevicesData <> nil) and (Length(FDevicesData) > 0) then
	for Index := 0 to High(FDevicesData) do
		Result += FDevicesData[Index].CountPacketsSize;
end;

procedure TSInternetPacketCaptureHandler.HandlePacket(const Packet : TSInternetCaptorPacket);
var
	Device : PSInternetPacketCaptureHandlerDeviceData = nil;
	Stream : TStream = nil;
begin
FCriticalSection.Enter();

Device := FindDevice(SPCharToString(Packet.Device^.DeviceName));
if Device = nil then
	Device := AddDevice(Packet.Device^);
if Device <> nil then
	if Packet.Data.Header.CapLen = Packet.Data.Header.Len then
		begin
		Device^.CountPackets += 1;
		Device^.CountPacketsSize += Packet.Data.Header.CapLen;
		
		Stream := Packet.Data.CreateStream();
		HandlePacket(Device^.Identificator, Stream, TSTime.Import(Packet.Data.Header.ts.tv_sec, Packet.Data.Header.ts.tv_usec));
		Stream.Destroy();
		Stream := nil;
		end
	else
		Device^.CountDefectivePackets += 1;

FCriticalSection.Leave();
end;

function TSInternetPacketCaptureHandler.FindDeviceOption(const DeviceIdentificator : TSInternetPacketCaptureHandlerDeviceIdentificator; const OptionName : TSString) : TSString;
var
	Device : PSInternetPacketCaptureHandlerDeviceData = nil;
	Index : TSMaxEnum;
begin
Result := '';
Device := FindDevice(DeviceIdentificator);
if (Device <> nil) and (Device^.AdditionalOptions <> nil) and (Length(Device^.AdditionalOptions) > 0) then
	for Index := 0 to High(Device^.AdditionalOptions) do
		if Device^.AdditionalOptions[Index][0] = OptionName then
			begin
			Result := Device^.AdditionalOptions[Index][1];
			break;
			end;
end;

function TSInternetPacketCaptureHandler.FindDevice(const DeviceIdentificator : TSInternetPacketCaptureHandlerDeviceIdentificator) : PSInternetPacketCaptureHandlerDeviceData;
var
	Index : TSMaxEnum;
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

function TSInternetPacketCaptureHandler.FindDevice(const DeviceName : TSString) : PSInternetPacketCaptureHandlerDeviceData;
var
	Index : TSMaxEnum;
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

function TSInternetPacketCaptureHandler.AddDevice(const DeviceData : TSInternetPacketCaptorDeviceData) : PSInternetPacketCaptureHandlerDeviceData;
begin
FCriticalSection.Enter();

if (FDevicesData = nil) or (Length(FDevicesData) = 0) then
	SetLength(FDevicesData, 1)
else
	SetLength(FDevicesData, Length(FDevicesData) + 1);
Result := @FDevicesData[High(FDevicesData)];
Result^.Device := SPCharToString(DeviceData.DeviceName);
Result^.DeviceDescription := DeviceData.DeviceDescription;
Result^.CountPackets := 0;
Result^.CountDefectivePackets := 0;
Result^.CountPacketsSize := 0;
Result^.Identificator := Length(FDevicesData);
Result^.AdditionalOptions := nil;
Result^.AdditionalOptions += SDoubleString('IPv4 Net', SIPv4AddressToString(DeviceData.DeviceNet));
Result^.AdditionalOptions += SDoubleString('IPv4 Mask', SIPv4AddressToString(DeviceData.DeviceMask));

HandleDevice(Result^.Identificator);

FCriticalSection.Leave();
end;

procedure TSInternetPacketCaptureHandler.WriteConsoleString(const Str : TSString; const Log : TSBoolean = True);
var
	CasesOfPrint : TSCasesOfPrint;
begin
SPrintEngineVersion();
CasesOfPrint := [SCasePrint];
if Log then
	CasesOfPrint += [SCaseLog];
SHint([Str], CasesOfPrint);
end;

function TSInternetPacketCaptureHandler.Start() : TSBoolean;
var
	InitStartTime : TSDateTime;
begin
Result := False;
FillChar(FTimeBegining, SizeOf(FTimeBegining), 0);

InitStartTime.Get();
if FPossibilityBreakLoopFromConsole then
	WriteConsoleString('Initializing devices...');
FPacketCaptor := TSInternetPacketCaptor.Create();
FPacketCaptor.CallBack := TSInternetPacketCaptorCallBack(@SPacketCaptureHandler_CallBack);
FPacketCaptor.CallBackData := Self;
Result := FPacketCaptor.BeginLoopThreads(False);
if Result then
	begin
	FTimeBegining.Get();
	if FProcessTimeOutUpdates then
		FTimeLastUpdateInfo := FTimeBegining;
	
	if FPossibilityBreakLoopFromConsole then
		begin
		WriteConsoleString('Initializing was completed in ' + STextTimeBetweenDates(InitStartTime, FTimeBegining, 'ENG') + '.');
		WriteConsoleString('Capturing begins. Press Escape to stop!', False);
		end;
	
	FPacketCaptor.DefaultDelay();
	end
else
	Stop();
end;

procedure TSInternetPacketCaptureHandler.Stop();
begin
SKill(FPacketCaptor);
end;

function TSInternetPacketCaptureHandler.Update() : TSBoolean;
var
	TimeNow : TSDateTime;
	CrashedDevicesNumber : TSMaxEnum;
begin
CrashedDevicesNumber := FPacketCaptor.DevicesWithCrashedThreads();
Result := CrashedDevicesNumber <> 0;
if Result then
	WriteConsoleString('Error: ' + SStr(CrashedDevicesNumber) + ' of ' + SStr(FPacketCaptor.DevicesNumber()) + ' thread(-s) crashed while capturing. Stopping.');
if (not Result) then
	Result := FPacketCaptor.AllThreadsFinished();
if  (not Result) and FPossibilityBreakLoopFromConsole and
	(KeyPressed() and (ReadKey = #27)) then
		Result := True;
if (not Result) and FProcessTimeOutUpdates then
	begin
	TimeNow.Get();
	if (TimeNow - FTimeLastUpdateInfo).GetPastMiliSeconds() > FInfoTimeOut then
		begin
		FTimeLastUpdateInfo := TimeNow;
		Result := HandleTimeOutUpdate(TimeNow);
		end;
	end;
end;

procedure TSInternetPacketCaptureHandler.Loop();
begin
if Start() then
	begin
	while not Update() do
		FPacketCaptor.DefaultDelay();
	Stop();
	end;
end;

constructor TSInternetPacketCaptureHandler.Create();
begin
inherited;
FDevicesData := nil;
FPacketCaptor := nil;
FInfoTimeOut := 100;
FillChar(FTimeBegining, SizeOf(FTimeBegining), 0);
FillChar(FTimeLastUpdateInfo, SizeOf(FTimeLastUpdateInfo), 0);
FPossibilityBreakLoopFromConsole := False;
FProcessTimeOutUpdates := False;
FCriticalSection := TSCriticalSection.Create();
end;

destructor TSInternetPacketCaptureHandler.Destroy();
var
	Index : TSMaxEnum;
begin
Stop();
if (FDevicesData <> nil) and (Length(FDevicesData) > 0) then
	begin
	for Index := 0 to High(FDevicesData) do
		SKill(FDevicesData[Index].AdditionalOptions);
	SetLength(FDevicesData, 0);
	end;
SKill(FCriticalSection);
inherited;
end;

end.
