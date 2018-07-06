{$INCLUDE SaGe.inc}

unit SaGeInternetPacketCaptor;

interface

uses
	 SaGeBase
	,SaGeLists
	,SaGeBaseClasses
	,SaGeThreads
	,SaGePcapUtils
	,SaGeInternetBase
	,SaGeCriticalSection
	;

const
	SGInternetPacketCaptorDefaultDelay = 5;
type
	TSGInternetPacketCaptor = class;
	
	PSGInternetPacketCaptorDeviceData = ^ TSGInternetPacketCaptorDeviceData;
	TSGInternetPacketCaptorDeviceData = object
			public
		DeviceName : TSGPcapDeviceName;
		DeviceDescription : TSGString;
		DeviceNet  : TSGIPv4Address;
		DeviceMask : TSGIPv4Address;
		end;
	
	PSGInternetPacketCaptorDevice = ^ TSGInternetPacketCaptorDevice;
	TSGInternetPacketCaptorDevice = object(TSGInternetPacketCaptorDeviceData)
			public
		DeviceHandle  : TSGPcapDeviceHandle;
		Handler       : TSGInternetPacketCaptor;
		HandlerThread : TSGThread;
		end;
	TSGInternetPacketCaptorDevices = packed array of TSGInternetPacketCaptorDevice;
	
	PSGInternetCaptorPacket = ^ TSGInternetCaptorPacket;
	TSGInternetCaptorPacket = object
			public
		Data   : TSGPcapPacket;
		Device : PSGInternetPacketCaptorDeviceData;
		end;
	
	TSGInternetPacketCaptorCallBack = procedure (Data : TSGPointer; Packet : TSGInternetCaptorPacket);
	
	TSGInternetPacketCaptor = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FCriticalSection : TSGCriticalSection;
		FCallBack : TSGInternetPacketCaptorCallBack;
		FCallBackData : TSGPointer;
		FDevices : TSGInternetPacketCaptorDevices;
			public
		property CriticalSection : TSGCriticalSection read FCriticalSection;
		property CallBack : TSGInternetPacketCaptorCallBack read FCallBack write FCallBack;
		property CallBackData : TSGPointer read FCallBackData write FCallBackData;
			private
		procedure StartThreads();
		procedure InitThreads();
		function InitDevice(const DeviceName : TSGString; var DeviceData : TSGInternetPacketCaptorDevice) : TSGBoolean;
		procedure AddDevice(const DeviceData : TSGInternetPacketCaptorDevice);
		function DevicesConstruct() : TSGBoolean;
		procedure DevicesFree();
			public
		procedure DefaultDelay();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AllThreadsFinished() : TSGBoolean;
		function BeginLoopThreads(const WithDelay : TSGBoolean = False) : TSGBoolean; 
		procedure LoopThreads(); virtual;
		procedure LoopNonThread(); deprecated;
		end;

procedure SGInternetPacketCaptor(const CaptorCallBack : TSGInternetPacketCaptorCallBack; const CaptorCallBackData : TSGPointer = nil);
procedure SGKill(var Variable : TSGInternetPacketCaptor);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

uses
	 SaGeLog
	,SaGeStringUtils
	{$IFDEF MSWINDOWS}
		,SaGeWinAPIUtils
		{$ENDIF}
	,SaGeDateTime
	
	,Crt
	;

procedure SGKill(var Variable : TSGInternetPacketCaptor);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if Variable <> nil then
	begin
	Variable.Destroy();
	Variable := nil;
	end;
end;

procedure SGInternetPacketCaptor(const CaptorCallBack : TSGInternetPacketCaptorCallBack; const CaptorCallBackData : TSGPointer = nil);
begin
with TSGInternetPacketCaptor.Create() do
	begin
	CallBack := CaptorCallBack;
	CallBackData := CaptorCallBackData;
	LoopThreads();
	Destroy();
	end;
end;

// ===============================================
// ======TSGInternetPacketCaptor CallBacks======
// ===============================================

procedure TSGInternetPacketCaptor_LoopCallBack(DeviceData: PSGInternetPacketCaptorDevice; Header: PSGPcapPacketHeader; Data: PByte);cdecl;
var
	Packet : TSGInternetCaptorPacket;
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

procedure TSGInternetPacketCaptor_ThreadCallBack(DeviceData : PSGInternetPacketCaptorDevice);
begin
SGPCAPEndlessLoop(
	DeviceData^.DeviceHandle,
	TSGPcapCallBack(@TSGInternetPacketCaptor_LoopCallBack),
	DeviceData);
end;

// =====================================
// ======TSGInternetPacketCaptor======
// =====================================

procedure TSGInternetPacketCaptor.InitThreads();
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
		TSGThreadProcedure(@TSGInternetPacketCaptor_ThreadCallBack), 
		@FDevices[Index],
		False);
	end;
end;

function TSGInternetPacketCaptor.AllThreadsFinished() : TSGBoolean;
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

procedure TSGInternetPacketCaptor.StartThreads();
var
	Index : TSGMaxEnum;
begin
for Index := 0 to High(FDevices) do
	if FDevices[Index].HandlerThread <> nil then
		FDevices[Index].HandlerThread.Start();
end;

procedure TSGInternetPacketCaptor.LoopNonThread(); deprecated;
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
			TSGPcapCallBack(@TSGInternetPacketCaptor_LoopCallBack),
			@FDevices[Index]);
	if KeyPressed and (ReadKey = #27) then
		Runs := False;
	end;
end;

function TSGInternetPacketCaptor.BeginLoopThreads(const WithDelay : TSGBoolean = False) : TSGBoolean; 
begin
Result := DevicesConstruct();
if Result then
	begin
	InitThreads();
	StartThreads();
	if WithDelay then
		Delay(SGInternetPacketCaptorDefaultDelay * Length(FDevices));
	end;
end;

procedure TSGInternetPacketCaptor.LoopThreads();
begin
if BeginLoopThreads(True) then
	while not AllThreadsFinished() do
		DefaultDelay();
end;

procedure TSGInternetPacketCaptor.DefaultDelay();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Delay(SGInternetPacketCaptorDefaultDelay);
end;

function TSGInternetPacketCaptor.InitDevice(const DeviceName : TSGString; var DeviceData : TSGInternetPacketCaptorDevice) : TSGBoolean;
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

procedure TSGInternetPacketCaptor.AddDevice(const DeviceData : TSGInternetPacketCaptorDevice);
begin
if FDevices = nil then
	SetLength(FDevices, 1)
else
	SetLength(FDevices, Length(FDevices) + 1);
FDevices[High(FDevices)] := DeviceData;
end;

function TSGInternetPacketCaptor.DevicesConstruct() : TSGBoolean;
var
	DeviceNames : TSGStringList = nil;
	TempDeviceData : TSGInternetPacketCaptorDevice;
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

procedure TSGInternetPacketCaptor.DevicesFree();
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

constructor TSGInternetPacketCaptor.Create();
begin
inherited;
FCriticalSection := TSGCriticalSection.Create();
FCallBack := nil;
FDevices := nil;
end;

destructor TSGInternetPacketCaptor.Destroy();
begin
DevicesFree();
FCriticalSection.Destroy();
inherited;
end;

end.
