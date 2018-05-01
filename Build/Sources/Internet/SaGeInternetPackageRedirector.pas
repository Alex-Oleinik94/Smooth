{$INCLUDE SaGe.inc}

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
	{$IFDEF MSWINDOWS}
		,SaGeWindowsUtils
		{$ENDIF}
	
	,Pcap
	;

procedure SGInternetPackageRedirector();
var
	Device : TSGPCAPDeviceName = nil;
	IP, Mask : TSGUInt32;
	Handle : TSGPCAPDeviceHandle = nil;

begin
//SGLogInternetAdaptersInfo();
Handle := SGPCAPInitializeDevice(Device, @IP, @Mask);
if Handle = nil then
	exit;

SGPCAPInitializeDeviceFilter(Handle, 'port 23', IP);

SGPCAPJackOnePacket(Handle).Free();

pcap_close(Handle);
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
