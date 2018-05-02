{$INCLUDE SaGe.inc}

//listener
unit SaGeInternetPackageRedirector;

interface

uses
	 SaGeBase
	,SaGeClasses
	;

type
	TSGInternetPackageRedirector = class(TSGObject)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ObjectName() : TSGString; override;
		end;

procedure SGInternetPackageRedirector();

implementation

uses
	 SaGeLog
	,SaGePcapUtils
	,SaGeStringUtils
	{$IFDEF MSWINDOWS}
		,SaGeWindowsUtils
		{$ENDIF}
	
	,Pcap
	;

procedure SGInternetPackageRedirector();
var
	Devices : packed array of
		packed record
			Device : TSGPCAPDeviceName;
			Net, Mask : TSGUInt32;
			Handle : TSGPCAPDeviceHandle;
			end = nil;
	DeviceNames : TSGStringList = nil;
	i : TSGMaxEnum;
begin
//SGPCAPLogInternetDevices();
//SGLogInternetAdaptersInfo();
DeviceNames := SGPCAPInternetAdapterNames();
if (DeviceNames = nil) or (Length(DeviceNames) = 0) then
	exit;

SetLength(Devices, Length(DeviceNames));
FillChar(Devices[0], SizeOf(Devices[0]) * Length(DeviceNames), 0);
for i := 0 to High(DeviceNames) do
	with Devices[i] do
		begin
		Device := SGStringToPChar(DeviceNames[i]);
		if SGPCAPTestDeviceNetMask(Device) then
			begin
			Handle := SGPCAPInitializeDevice(Device, @Net, @Mask);
			pcap_close(Handle);
			end;
		FreeMem(Device);
		end;
SetLength(Devices, 0);

//SGPCAPInitializeDeviceFilter(Handle, 'port 23', IP);

//SGPCAPJackOnePacket(Handle).Free();

//pcap_close(Handle);
end;

constructor TSGInternetPackageRedirector.Create();
begin
inherited;
end;

destructor TSGInternetPackageRedirector.Destroy();
begin
inherited;
end;

class function TSGInternetPackageRedirector.ObjectName() : TSGString;
begin
Result := 'TSGInternetPackageRedirector';
end;

end.
