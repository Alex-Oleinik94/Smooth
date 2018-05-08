{$INCLUDE SaGe.inc}

unit SaGeInternetPacketCaptureHandler;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeDateTime
	,SaGeInternetPacketCaptor
	
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
		FBeginingTime : TSGDateTime;
		FPossibilityBreakLoopFromConsole : TSGBoolean;
		FInfoTimeOut : TSGUInt64;
		FProcessTimeOutUpdates : TSGBoolean;
			public
		property PossibilityBreakLoopFromConsole : TSGBoolean read FPossibilityBreakLoopFromConsole write FPossibilityBreakLoopFromConsole;
		property ProcessTimeOutUpdates : TSGBoolean read FProcessTimeOutUpdates write FProcessTimeOutUpdates;
		property InfoTimeOut : TSGUInt64 read FInfoTimeOut write FInfoTimeOut;
		property BeginingTime : TSGDateTime read FBeginingTime;
		property PacketCaptor : TSGInternetPacketCaptor read FPacketCaptor;
			protected
		function AllDataSize() : TSGUInt64;
		function FindDevice(const DeviceName : TSGString) : PSGInternetPacketCaptureHandlerDeviceData;
		function FindDevice(const DeviceIdentificator : TSGInternetPacketCaptureHandlerDeviceIdentificator) : PSGInternetPacketCaptureHandlerDeviceData;
		function AddDevice(const DeviceData : TSGInternetPacketCaptorDeviceData) : PSGInternetPacketCaptureHandlerDeviceData;
		procedure CreateDeviceInformationFile(const Identificator : TSGInternetPacketCaptureHandlerDeviceIdentificator; const FileName : TSGString);
			public
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
TextFile.WriteLn(['SystemName= ', SGPcapInternetAdapterSystemName(Device^.DeviceName)]);
TextFile.WriteLn(['PcapDescription= ', SGPcapInternetAdapterPcapDescriptionFromName(Device^.DeviceName)]);
TextFile.WriteLn(['SystemDescription= ', SGPcapInternetAdapterSystemDescriptionFromName(Device^.DeviceName)]);
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

procedure TSGInternetPacketCaptureHandler.Loop();
var
	LastInfoTime, NowInfoTime : TSGDateTime;
	BreakLoopingFlag : TSGBoolean = False;
begin
if FPossibilityBreakLoopFromConsole then
	begin
	SGPrintEngineVersion();
	WriteLn('Internet Packet Capture Handler: Press ESC to exit');
	end;

FPacketCaptor := TSGInternetPacketCaptor.Create();
FPacketCaptor.CallBack := TSGInternetPacketCaptorCallBack(@SGPacketCaptureHandler_CallBack);
FPacketCaptor.CallBackData := Self;
if FPacketCaptor.BeginLoopThreads(True) then
	begin
	FBeginingTime.Get();
	if FProcessTimeOutUpdates then
		LastInfoTime := FBeginingTime;
	while (not BreakLoopingFlag) and (not FPacketCaptor.AllThreadsFinished()) do
		begin
		if FPossibilityBreakLoopFromConsole and KeyPressed() and (ReadKey = #27) then
			break;
		if FProcessTimeOutUpdates then
			begin
			NowInfoTime.Get();
			if (NowInfoTime - LastInfoTime).GetPastMiliSeconds() > FInfoTimeOut then
				begin
				LastInfoTime := NowInfoTime;
				BreakLoopingFlag := HandleTimeOutUpdate(NowInfoTime);
				end;
			end;
		if BreakLoopingFlag then
			FPacketCaptor.DefaultDelay();
		end;
	end;
FPacketCaptor.Destroy();
FPacketCaptor := nil;
end;

constructor TSGInternetPacketCaptureHandler.Create();
begin
inherited;
FDevicesData := nil;
FPacketCaptor := nil;
FInfoTimeOut := 100;
FillChar(FBeginingTime, SizeOf(FBeginingTime), 0);
FPossibilityBreakLoopFromConsole := False;
FProcessTimeOutUpdates := False;
end;

destructor TSGInternetPacketCaptureHandler.Destroy();
var
	Index : TSGMaxEnum;
begin
if FPacketCaptor <> nil then
	begin
	FPacketCaptor.Destroy();
	FPacketCaptor := nil;
	end;
if (FDevicesData <> nil) and (Length(FDevicesData) > 0) then
	begin
	for Index := 0 to High(FDevicesData) do
		SGKill(FDevicesData[Index].AdditionalOptions);
	SetLength(FDevicesData, 0);
	end;
inherited;
end;

end.
