{$INCLUDE SaGe.inc}

unit SaGeInternetPacketListener;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeThreads
	,SaGePcapUtils
	,SaGeInternetBase
	,SaGeCriticalSection
	;

const
	SGInternetPacketListenerDefaultDelay = 5;
type
	TSGInternetPacketListener = class;
	
	PSGInternetPacketListenerDeviceData = ^ TSGInternetPacketListenerDeviceData;
	TSGInternetPacketListenerDeviceData = object
			public
		DeviceName : TSGPcapDeviceName;
		DeviceDescription : TSGString;
		DeviceNet  : TSGIPv4Address;
		DeviceMask : TSGIPv4Address;
		end;
	
	PSGInternetPacketListenerDevice = ^ TSGInternetPacketListenerDevice;
	TSGInternetPacketListenerDevice = object(TSGInternetPacketListenerDeviceData)
			public
		DeviceHandle  : TSGPcapDeviceHandle;
		Handler       : TSGInternetPacketListener;
		HandlerThread : TSGThread;
		end;
	TSGInternetPacketListenerDevices = packed array of TSGInternetPacketListenerDevice;
	
	PSGInternetPacket = ^ TSGInternetPacket;
	TSGInternetPacket = object
			public
		Data   : TSGPcapPacket;
		Device : PSGInternetPacketListenerDeviceData;
		end;
	
	TSGInternetPacketListenerCallBack = procedure (Data : TSGPointer; Packet : TSGInternetPacket);
	
	TSGInternetPacketListener = class(TSGObject)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FCriticalSection : TSGCriticalSection;
		FCallBack : TSGInternetPacketListenerCallBack;
		FCallBackData : TSGPointer;
		FDevices : TSGInternetPacketListenerDevices;
			public
		property CriticalSection : TSGCriticalSection read FCriticalSection;
		property CallBack : TSGInternetPacketListenerCallBack read FCallBack write FCallBack;
		property CallBackData : TSGPointer read FCallBackData write FCallBackData;
			private
		procedure StartThreads();
		procedure InitThreads();
		function InitDevice(const DeviceName : TSGString; var DeviceData : TSGInternetPacketListenerDevice) : TSGBoolean;
		procedure AddDevice(const DeviceData : TSGInternetPacketListenerDevice);
		function DevicesConstruct() : TSGBoolean;
		procedure DevicesFree();
			public
		procedure DefaultDelay();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AllThreadsFinished() : TSGBoolean;
		function BeginLoopThreads(const WithDelay : TSGBoolean = False) : TSGBoolean; 
		procedure LoopThreads(); virtual;
		procedure LoopNonThread(); deprecated;
		end;

procedure SGInternetPacketListener(const ListenerCallBack : TSGInternetPacketListenerCallBack; const ListenerCallBackData : TSGPointer = nil);

implementation

uses
	 SaGeLog
	,SaGeStringUtils
	{$IFDEF MSWINDOWS}
		,SaGeWindowsUtils
		{$ENDIF}
	,SaGeDateTime
	
	,Crt
	;

procedure SGInternetPacketListener(const ListenerCallBack : TSGInternetPacketListenerCallBack; const ListenerCallBackData : TSGPointer = nil);
begin
with TSGInternetPacketListener.Create() do
	begin
	CallBack := ListenerCallBack;
	CallBackData := ListenerCallBackData;
	LoopThreads();
	Destroy();
	end;
end;

// ===============================================
// ======TSGInternetPacketListener CallBacks======
// ===============================================

procedure TSGInternetPacketListener_LoopCallBack(DeviceData: PSGInternetPacketListenerDevice; Header: PSGPcapPacketHeader; Data: PByte);cdecl;
var
	Packet : TSGInternetPacket;
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

procedure TSGInternetPacketListener_ThreadCallBack(DeviceData : PSGInternetPacketListenerDevice);
begin
SGPCAPEndlessLoop(
	DeviceData^.DeviceHandle,
	TSGPcapCallBack(@TSGInternetPacketListener_LoopCallBack),
	DeviceData);
end;

// =====================================
// ======TSGInternetPacketListener======
// =====================================

procedure TSGInternetPacketListener.InitThreads();
var
	Index : TSGMaxEnum;
begin
for Index := 0 to High(FDevices) do
	begin
	if FDevices[Index].HandlerThread <> nil then
		begin
		FDevices[Index].HandlerThread.Destroy();
		FDevices[Index].HandlerThread := nil;
		end;
	FDevices[Index].HandlerThread := TSGThread.Create(
		TSGThreadProcedure(@TSGInternetPacketListener_ThreadCallBack), 
		@FDevices[Index],
		False);
	end;
end;

function TSGInternetPacketListener.AllThreadsFinished() : TSGBoolean;
var
	Index : TSGMaxEnum;
begin
Result := True;
for Index := 0 to High(FDevices) do
	if not FDevices[Index].HandlerThread.Finished then
		begin
		Result := False;
		break;
		end;
end;

procedure TSGInternetPacketListener.StartThreads();
var
	Index : TSGMaxEnum;
begin
for Index := 0 to High(FDevices) do
	if FDevices[Index].HandlerThread <> nil then
		FDevices[Index].HandlerThread.Start();
end;

procedure TSGInternetPacketListener.LoopNonThread(); deprecated;
var
	Index : TSGMaxEnum;
	Runs : TSGBoolean = True;
begin
if not DevicesConstruct() then
	exit;

while Runs do
	begin
	for Index := 0 to High(FDevices) do
		SGPcapNext(
			FDevices[Index].DeviceHandle,
			TSGPcapCallBack(@TSGInternetPacketListener_LoopCallBack),
			@FDevices[Index]);
	if KeyPressed and (ReadKey = #27) then
		Runs := False;
	end;
end;

function TSGInternetPacketListener.BeginLoopThreads(const WithDelay : TSGBoolean = False) : TSGBoolean; 
begin
Result := DevicesConstruct();
if Result then
	begin
	InitThreads();
	StartThreads();
	if WithDelay then
		Delay(SGInternetPacketListenerDefaultDelay * Length(FDevices));
	end;
end;

procedure TSGInternetPacketListener.LoopThreads();
begin
if BeginLoopThreads(True) then
	while not AllThreadsFinished() do
		DefaultDelay();
end;

procedure TSGInternetPacketListener.DefaultDelay();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Delay(SGInternetPacketListenerDefaultDelay);
end;

function TSGInternetPacketListener.InitDevice(const DeviceName : TSGString; var DeviceData : TSGInternetPacketListenerDevice) : TSGBoolean;
begin
Result := False;
DeviceData.DeviceName := SGStringToPChar(DeviceName);
if SGPCAPTestDeviceNetMask(DeviceData.DeviceName) then
	begin
	DeviceData.DeviceHandle := SGPCAPInitializeDevice(
		DeviceData.DeviceName,
		@DeviceData.DeviceNet,
		@DeviceData.DeviceMask);
	Result := DeviceData.DeviceHandle <> nil;
	if Result then
		begin
		DeviceData.DeviceDescription := SGPCAPInternetAdapterDescriptionFromName(DeviceData.DeviceName);
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

procedure TSGInternetPacketListener.AddDevice(const DeviceData : TSGInternetPacketListenerDevice);
begin
if FDevices = nil then
	SetLength(FDevices, 1)
else
	SetLength(FDevices, Length(FDevices) + 1);
FDevices[High(FDevices)] := DeviceData;
end;

function TSGInternetPacketListener.DevicesConstruct() : TSGBoolean;
var
	DeviceNames : TSGStringList = nil;
	TempDeviceData : TSGInternetPacketListenerDevice;
	Index : TSGMaxEnum;
begin
Result := False;
if (FDevices <> nil) and (Length(FDevices) > 0) then
	begin
	Result := True;
	Exit;
	end;

DeviceNames := SGPCAPInternetAdapterNames();
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

procedure TSGInternetPacketListener.DevicesFree();
var
	Index : TSGMaxEnum;
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
			SGPCAPClose(DeviceHandle);
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

constructor TSGInternetPacketListener.Create();
begin
inherited;
FCriticalSection := TSGCriticalSection.Create();
FCallBack := nil;
FDevices := nil;
end;

destructor TSGInternetPacketListener.Destroy();
begin
DevicesFree();
FCriticalSection.Destroy();
inherited;
end;

end.
