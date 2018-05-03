{$INCLUDE SaGe.inc}

unit SaGeInternetPacketListener;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeThreads
	,SaGePcapUtils
	;

type
	TSGInternetPacketListener = class;
	
	TSGInternetPacket = TSGPCAPDevicePacket;
	PSGInternetPacket = ^ TSGInternetPacket;
	
	TSGInternetPacketListenerCallBack = procedure (Packet : TSGInternetPacket);
	
	TSGInternetPacketListenerDevice = object
			public
		DeviceName : TSGPCAPDeviceName;
		DeviceHandle : TSGPCAPDeviceHandle;
		DeviceNet  : TSGUInt32;
		DeviceMask : TSGUInt32;
		Handler : TSGInternetPacketListener;
		HandlerThread : TSGThread;
		end;
	TSGInternetPacketListenerDevices = packed array of TSGInternetPacketListenerDevice;
	
	TSGInternetPacketListenerDeviceData = TSGInternetPacketListenerDevice;
	PSGInternetPacketListenerDeviceData = ^ TSGInternetPacketListenerDeviceData;
	
	TSGInternetPacketListener = class(TSGObject)
			public
		constructor Create(); override;
		constructor Create(const CallBack : TSGInternetPacketListenerCallBack);
		destructor Destroy(); override;
			private
		FCriticalSection : TSGCriticalSection;
		FCallBack : TSGInternetPacketListenerCallBack;
		FDevices : TSGInternetPacketListenerDevices;
			public
		property CriticalSection : TSGCriticalSection read FCriticalSection;
		property CallBack : TSGInternetPacketListenerCallBack read FCallBack write FCallBack;
			public
		procedure DevicesConstruct();
		procedure DevicesFree();
		procedure Loop(); virtual;
		end;

procedure SGInternetPacketListener();

implementation

uses
	 SaGeLog
	,SaGeStringUtils
	{$IFDEF MSWINDOWS}
		,SaGeWindowsUtils
		{$ENDIF}
	
	,Crt
	;

procedure TSGInternetPacketListener_PacketCallBack(Packet : TSGInternetPacket);
begin
SGHint([
	SGPCAPInternetAdapterDescriptionFromName(Packet.Device),
	' ',
	Packet.Header.Len]);
end;

procedure SGInternetPacketListener();
begin
with TSGInternetPacketListener.Create() do
	begin
	CallBack := @TSGInternetPacketListener_PacketCallBack;
	Loop();
	Destroy();
	end;
end;

procedure TSGInternetPacketListener_LoopCallBack(DeviceData: PSGInternetPacketListenerDeviceData; Header: PSGPCAPPacket; Data: PByte);cdecl;
var
	Packet : TSGPCAPDevicePacket;
begin
DeviceData^.Handler.CriticalSection.Enter();
try
	if DeviceData^.Handler.CallBack <> nil then
		begin
		FillChar(Packet, SizeOf(Packet), 0);
		Packet.Device := SGPCharToString(DeviceData^.DeviceName);
		Packet.Header := Header^;
		Packet.Data := Data;
		DeviceData^.Handler.CallBack(Packet);
		end;
finally
	DeviceData^.Handler.CriticalSection.Leave();
end;
end;

procedure TSGInternetPacketListener_ThreadCallBack(DeviceData : PSGInternetPacketListenerDeviceData);
begin
SGPCAPEndlessLoop(
	DeviceData^.DeviceHandle,
	TSGPCAPCallBack(@TSGInternetPacketListener_LoopCallBack),
	DeviceData);
end;

procedure TSGInternetPacketListener.Loop();

function AllHandlersDone() : TSGBoolean;
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

const
	DelayForWaiting  = 5;
var
	Index : TSGMaxEnum;
begin
DevicesConstruct();
if (FDevices = nil) or (Length(FDevices) = 0) then
	exit;

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
		True);
	end;
Delay(DelayForWaiting * Length(FDevices));

while not AllHandlersDone() do
	Delay(DelayForWaiting);
end;

procedure TSGInternetPacketListener.DevicesConstruct();

function TryInitDevice(const DeviceName : TSGString; var DeviceData : TSGInternetPacketListenerDeviceData) : TSGBoolean;
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
	if not Result then
		begin
		FreeMem(DeviceData.DeviceName);
		DeviceData.DeviceName := nil;
		end
	else
		begin
		DeviceData.Handler := Self;
		end;
	end
else
	begin
	FreeMem(DeviceData.DeviceName);
	DeviceData.DeviceName := nil;
	end;
end;

var
	DeviceNames : TSGStringList = nil;
	TempDeviceData : TSGInternetPacketListenerDeviceData;
	Index : TSGMaxEnum;
begin
if (FDevices <> nil) and (Length(FDevices) > 0) then
	Exit;

DeviceNames := SGPCAPInternetAdapterNames();
if (DeviceNames = nil) or (Length(DeviceNames) = 0) then
	exit;

for Index := 0 to High(DeviceNames) do
	begin
	FillChar(TempDeviceData, SizeOf(TempDeviceData), 0);
	if TryInitDevice(DeviceNames[Index], TempDeviceData) then
		begin
		if FDevices = nil then
			SetLength(FDevices, 1)
		else
			SetLength(FDevices, Length(FDevices) + 1);
		FDevices[High(FDevices)] := TempDeviceData;
		FillChar(TempDeviceData, SizeOf(TempDeviceData), 0);
		end;
	end;
SetLength(DeviceNames, 0);
FillChar(TempDeviceData, SizeOf(TempDeviceData), 0);
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

constructor TSGInternetPacketListener.Create(const CallBack : TSGInternetPacketListenerCallBack);
begin
Create();
FCallBack := CallBack;
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
