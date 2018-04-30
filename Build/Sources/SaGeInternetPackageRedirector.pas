{$INCLUDE SaGe.inc}

unit SaGeInternetPackageRedirector;

interface

uses
	 SaGeBase
	,SaGeClasses
	
	,Pcap
	;

const
	BUFSIZ = 8192;

type
	TSGIPRErrorString = array[0..PCAP_ERRBUF_SIZE-1] of TSGChar;
	TSGIPRString = PSGChar;
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
	,SaGeDllManager
	;

procedure SGInternetPackageRedirector();
var
	Error : TSGIPRErrorString;
	Device : TSGIPRString = nil;
	Mask, Net : TSGUInt32;
	Handle : PPcap = nil;
	FilterString : PSGChar = 'port 23';
	Filter : PBPF_Program = nil;
	Header : TPcap_Pkthdr;
	Packet : PSGByte = nil;
begin
if not DllManager.Suppored('pcap') then
	begin
	SGHint(['Ќевозможно использовать библиотеку PCAP!']);
	exit;
	end;

Device := pcap_lookupdev(@Error);
if Device = nil then
	begin
	SGHint(['Ќевозможно найти устройство по-умолчанию! Error = "', Error, '"']);
	exit;
	end
else
	SGHint(['”стройство по-умолчанию найдено! Device = "', Device, '"']);

if (pcap_lookupnet(Device, @Net, @Mask, Error) = -1) then
	begin
	SGHint(['Can''t get netmask for device "', Device, '"!']);
	Net := 0;
	Mask := 0;
	end;

Handle := pcap_open_live(Device, BUFSIZ, 1, 1000, Error);
if Handle = nil then
	begin
	SGHint(['Couldn''t open device "', Device, '", Error: "', Error, '"!']);
	exit;
	end;
if (pcap_compile(Handle, @Filter, FilterString, 0, Net) = -1) then
	begin
	SGHint(['Couldn''t parse filter "', FilterString, '", Error: "', pcap_geterr(Handle), '"!']);
	exit;
	end;
if (pcap_setfilter(Handle, @Filter) = -1) then
	begin
	SGHint(['Couldn''t install filter "', FilterString, '", Error: "', pcap_geterr(handle), '"!']);
	exit;
	end;

fillchar(Header, SizeOf(TPcap_Pkthdr), 0);
Packet := PSGByte(pcap_next(Handle, @Header));
SGHint(['Jacked a packet with length of "', Header.Len, '", Packet = "', TSGPointer(Packet), '".']);

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
