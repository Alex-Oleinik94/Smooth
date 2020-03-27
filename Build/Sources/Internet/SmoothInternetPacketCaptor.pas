{$INCLUDE Smooth.inc}

unit SmoothInternetPacketCaptor;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothBaseClasses
	,SmoothThreads
	,SmoothPcapUtils
	,SmoothInternetBase
	,SmoothCriticalSection
	;

const
	SInternetPacketCaptorDefaultDelay = 5;
type
	TSInternetPacketCaptor = class;
	
	PSInternetPacketCaptorDeviceData = ^ TSInternetPacketCaptorDeviceData;
	TSInternetPacketCaptorDeviceData = object
			public
		DeviceName : TSPcapDeviceName;
		DeviceDescription : TSString;
		DeviceNet  : TSIPv4Address;
		DeviceMask : TSIPv4Address;
		end;
	
	PSInternetPacketCaptorDevice = ^ TSInternetPacketCaptorDevice;
	TSInternetPacketCaptorDevice = object(TSInternetPacketCaptorDeviceData)
			public
		DeviceHandle  : TSPcapDeviceHandle;
		Handler       : TSInternetPacketCaptor;
		HandlerThread : TSThread;
		end;
	TSInternetPacketCaptorDevices = packed array of TSInternetPacketCaptorDevice;
	
	PSInternetCaptorPacket = ^ TSInternetCaptorPacket;
	TSInternetCaptorPacket = object
			public
		Data   : TSPcapPacket;
		Device : PSInternetPacketCaptorDeviceData;
		end;
	
	TSInternetPacketCaptorCallBack = procedure (Data : TSPointer; Packet : TSInternetCaptorPacket);
	
	TSInternetPacketCaptor = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FCriticalSection : TSCriticalSection;
		FCallBack : TSInternetPacketCaptorCallBack;
		FCallBackData : TSPointer;
		FDevices : TSInternetPacketCaptorDevices;
			public
		property CriticalSection : TSCriticalSection read FCriticalSection;
		property CallBack : TSInternetPacketCaptorCallBack read FCallBack write FCallBack;
		property CallBackData : TSPointer read FCallBackData write FCallBackData;
			private
		procedure StartThreads();
		procedure InitThreads();
		function InitDevice(const DeviceName : TSString; var DeviceData : TSInternetPacketCaptorDevice) : TSBoolean;
		procedure AddDevice(const DeviceData : TSInternetPacketCaptorDevice);
		function DevicesConstruct() : TSBoolean;
		procedure DevicesFree();
			public
		procedure DefaultDelay();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AllThreadsFinished() : TSBoolean;
		function BeginLoopThreads(const WithDelay : TSBoolean = False) : TSBoolean; 
		procedure LoopThreads(); virtual;
		procedure LoopNonThread(); deprecated;
		function DevicesNumber() : TSMaxEnum;
		function DevicesWithCrashedThreads() : TSMaxEnum;
		end;

procedure SInternetPacketCaptor(const CaptorCallBack : TSInternetPacketCaptorCallBack; const CaptorCallBackData : TSPointer = nil);
procedure SKill(var Variable : TSInternetPacketCaptor);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

uses
	 SmoothLog
	,SmoothStringUtils
	{$IFDEF MSWINDOWS}
		,SmoothWinAPIUtils
		{$ENDIF}
	,SmoothDateTime
	
	,Crt
	;

procedure SKill(var Variable : TSInternetPacketCaptor);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if Variable <> nil then
	begin
	Variable.Destroy();
	Variable := nil;
	end;
end;

procedure SInternetPacketCaptor(const CaptorCallBack : TSInternetPacketCaptorCallBack; const CaptorCallBackData : TSPointer = nil);
begin
with TSInternetPacketCaptor.Create() do
	begin
	CallBack := CaptorCallBack;
	CallBackData := CaptorCallBackData;
	LoopThreads();
	Destroy();
	end;
end;

// ===============================================
// ======TSInternetPacketCaptor CallBacks======
// ===============================================

procedure TSInternetPacketCaptor_LoopCallBack(DeviceData: PSInternetPacketCaptorDevice; Header: PSPcapPacketHeader; Data: PByte);cdecl;
var
	Packet : TSInternetCaptorPacket;
begin
DeviceData^.Handler.CriticalSection.Enter();
try
	if DeviceData^.Handler.CallBack <> nil then
		begin
		FillChar(Packet, SizeOf(Packet), 0);
		Packet.Device := DeviceData;
		Packet.Data.Header := Header^;
		Packet.Data.Data   := Data;
		DeviceData^.Handler.CallBack(DeviceData^.Handler.CallBackData, Packet);
		end;
finally
	DeviceData^.Handler.CriticalSection.Leave();
end;
end;

procedure TSInternetPacketCaptor_ThreadCallBack(DeviceData : PSInternetPacketCaptorDevice);
begin
SPCAPEndlessLoop(
	DeviceData^.DeviceHandle,
	TSPcapCallBack(@TSInternetPacketCaptor_LoopCallBack),
	DeviceData);
end;

// =====================================
// ======TSInternetPacketCaptor======
// =====================================

function TSInternetPacketCaptor.DevicesNumber() : TSMaxEnum;
begin
if (FDevices <> nil) then
	Result := Length(FDevices)
else
	Result := 0;
end;

function TSInternetPacketCaptor.DevicesWithCrashedThreads() : TSMaxEnum;
var
	Index : TSMaxEnum;
begin
Result := 0;
if (FDevices <> nil) then
	for Index := 0 to High(FDevices) do
		if FDevices[Index].HandlerThread <> nil then
			if FDevices[Index].HandlerThread.Crashed then
				Result += 1;
end;

procedure TSInternetPacketCaptor.InitThreads();
var
	Index : TSMaxEnum;
begin
for Index := 0 to High(FDevices) do
	begin
	if FDevices[Index].HandlerThread <> nil then
		begin
		FDevices[Index].HandlerThread.Destroy();
		FDevices[Index].HandlerThread := nil;
		end;
	FDevices[Index].HandlerThread := TSThread.Create(
		TSThreadProcedure(@TSInternetPacketCaptor_ThreadCallBack), 
		@FDevices[Index],
		False);
	end;
end;

function TSInternetPacketCaptor.AllThreadsFinished() : TSBoolean;
var
	Index : TSMaxEnum;
begin
Result := True;
for Index := 0 to High(FDevices) do
	if not FDevices[Index].HandlerThread.Finished then
		begin
		Result := False;
		break;
		end;
end;

procedure TSInternetPacketCaptor.StartThreads();
var
	Index : TSMaxEnum;
begin
for Index := 0 to High(FDevices) do
	if FDevices[Index].HandlerThread <> nil then
		FDevices[Index].HandlerThread.Start();
end;

procedure TSInternetPacketCaptor.LoopNonThread(); deprecated;
var
	Index : TSMaxEnum;
	Runs : TSBoolean = True;
begin
if not DevicesConstruct() then
	exit;

while Runs do
	begin
	for Index := 0 to High(FDevices) do
		SPcapNext(
			FDevices[Index].DeviceHandle,
			TSPcapCallBack(@TSInternetPacketCaptor_LoopCallBack),
			@FDevices[Index]);
	if KeyPressed and (ReadKey = #27) then
		Runs := False;
	end;
end;

function TSInternetPacketCaptor.BeginLoopThreads(const WithDelay : TSBoolean = False) : TSBoolean; 
begin
Result := DevicesConstruct();
if Result then
	begin
	InitThreads();
	StartThreads();
	if WithDelay then
		Delay(SInternetPacketCaptorDefaultDelay * Length(FDevices));
	end;
end;

procedure TSInternetPacketCaptor.LoopThreads();
begin
if BeginLoopThreads(True) then
	while not AllThreadsFinished() do
		DefaultDelay();
end;

procedure TSInternetPacketCaptor.DefaultDelay();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Delay(SInternetPacketCaptorDefaultDelay);
end;

function TSInternetPacketCaptor.InitDevice(const DeviceName : TSString; var DeviceData : TSInternetPacketCaptorDevice) : TSBoolean;
begin
Result := False;
DeviceData.DeviceName := SStringToPChar(DeviceName);
if SPCAPTestDeviceNetMask(DeviceData.DeviceName) then
	begin
	DeviceData.DeviceHandle := SPCAPInitializeDevice(
		DeviceData.DeviceName,
		@DeviceData.DeviceNet,
		@DeviceData.DeviceMask);
	Result := DeviceData.DeviceHandle <> nil;
	if Result then
		begin
		DeviceData.DeviceDescription := SPCAPInternetAdapterDescriptionFromName(DeviceData.DeviceName);
		DeviceData.Handler := Self;
		end
	else
		begin
		FreeMem(DeviceData.DeviceName);
		DeviceData.DeviceName := nil;
		end;
	end
else
	begin
	FreeMem(DeviceData.DeviceName);
	DeviceData.DeviceName := nil;
	end;
end;

procedure TSInternetPacketCaptor.AddDevice(const DeviceData : TSInternetPacketCaptorDevice);
begin
if FDevices = nil then
	SetLength(FDevices, 1)
else
	SetLength(FDevices, Length(FDevices) + 1);
FDevices[High(FDevices)] := DeviceData;
end;

function TSInternetPacketCaptor.DevicesConstruct() : TSBoolean;
var
	DeviceNames : TSStringList = nil;
	TempDeviceData : TSInternetPacketCaptorDevice;
	Index : TSMaxEnum;
begin
Result := False;
if (FDevices <> nil) and (Length(FDevices) > 0) then
	begin
	Result := True;
	Exit;
	end;

DeviceNames := SPCAPInternetAdapterNames();
if (DeviceNames = nil) or (Length(DeviceNames) = 0) then
	exit;

for Index := 0 to High(DeviceNames) do
	begin
	FillChar(TempDeviceData, SizeOf(TempDeviceData), 0);
	if InitDevice(DeviceNames[Index], TempDeviceData) then
		begin
		AddDevice(TempDeviceData);
		FillChar(TempDeviceData, SizeOf(TempDeviceData), 0);
		end;
	end;
SetLength(DeviceNames, 0);
FillChar(TempDeviceData, SizeOf(TempDeviceData), 0);

if (FDevices <> nil) and (Length(FDevices) > 0) then
	Result := True;
end;

procedure TSInternetPacketCaptor.DevicesFree();
var
	Index : TSMaxEnum;
begin
if (FDevices = nil) or (Length(FDevices) = 0) then
	Exit;

for Index := 0 to High(FDevices) do
	with FDevices[Index] do
		begin
		if DeviceName <> nil then
			begin
			FreeMem(DeviceName);
			DeviceName := nil;
			end;
		if DeviceHandle <> nil then
			begin
			SPCAPClose(DeviceHandle);
			DeviceHandle := nil;
			end;
		DeviceNet := 0;
		DeviceMask := 0;
		if HandlerThread <> nil then
			begin
			HandlerThread.Destroy();
			HandlerThread := nil;
			end;
		Handler := nil;
		end;
SetLength(FDevices, 0);
end;

constructor TSInternetPacketCaptor.Create();
begin
inherited;
FCriticalSection := TSCriticalSection.Create();
FCallBack := nil;
FDevices := nil;
end;

destructor TSInternetPacketCaptor.Destroy();
begin
DevicesFree();
FCriticalSection.Destroy();
inherited;
end;

end.
