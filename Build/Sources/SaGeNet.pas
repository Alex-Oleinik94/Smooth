{$INCLUDE SaGe.inc}

unit SaGeNet;

interface

uses
	 Crt
	,SysUtils
	,Classes
	,StrUtils
	,Process
	
	,SaGeBase
	,SaGeBased
	,SaGeCommon
	,SaGeVersion
	,SaGeClasses
	
	,lCommon
	,lhttp
	,lnetSSL
	,lNet
	,URIParser
	,lHTTPUtil
	;
const 
	SGDefaultTimeOut = 200;
	SGDefaultHTTPTimeOut = SGDefaultTimeOut;

type
	TSGUDPConnectionClass = class(TLUDP)
		function SendMemoryStream(const AStream:TMemoryStream):Integer;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		end;
	
	TSGReceiveProcedure       = procedure(Parent : TSGPointer; AStream : TMemoryStream; aSocket : TLSocket);
	TSGNestedReceiveProcedure = procedure(Parent : TSGPointer; AStream : TMemoryStream; aSocket : TLSocket) is nested;
	
	TSGConnectionMode = (SGServerMode,SGClientMode);
	
	TSGUDPConnection = class(TSGNamed)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
			protected
		FViewErrorCase : TSGViewErrorType;
		FConnection : TSGUDPConnectionClass;
		FReceiveProcedure : TSGReceiveProcedure;
		FNestedReceiveProcedure : TSGNestedReceiveProcedure;
		FParent : TSGPointer;
		FAddress : TSGString;
		FPort : TSGUInt16;
		FConnectionMode : TSGConnectionMode;
		FConnectionResult : TSGBool;
			protected
		procedure OnError(const Msg: TSGString; aSocket: TLSocket);
		procedure OnReceive(aSocket: TLSocket);
		function Listen() : TSGBool;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function Connect() : TSGBool;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
			public
		function Start() : TSGBool;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		procedure CallAction();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function SendMemoryStream(const AStream:TMemoryStream):Integer;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
			public
		property ReceiveProcedure:TSGReceiveProcedure read FReceiveProcedure write FReceiveProcedure;
		property NestedReceiveProcedure:TSGNestedReceiveProcedure read FNestedReceiveProcedure write FNestedReceiveProcedure;
		property Parent:Pointer read FParent write FParent;
		property ConnectionMode:TSGConnectionMode read FConnectionMode write FConnectionMode;
		property Port : TSGUInt16 read FPort write FPort;
		property Host : TSGString read FAddress write FAddress;
		property Address : TSGString read FAddress write FAddress;
		property Ready : TSGBoolean read FConnectionResult;
		end;
	
	TSGHost = object
			public
		FAddress : TSGString;
		FPort : TSGUInt16;
		FURL : TSGString;
		FLastSend : TSGDateTime;
		FLastRecieved : TSGDateTime;
		FLastSendIterator : TSGUInt64;
		FLastRecievedIterator : TSGUInt64;
		end;
	PSGHost = ^ TSGHost;
	TSGHostList = packed array of TSGHost;
	
	TSGCustomConnectionHandler = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			protected
		FHosts : TSGHostList;
		FIterator : TSGUInt64;
			protected
		function GetHost(const Index : TSGMaxEnum) : PSGHost; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		function HostsCount() : TSGMaxEnum; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property Hosts[Index : TSGMaxEnum]:PSGHost read GetHost;
		end;
	
	TSGCustomUDPConnectionHandler = class(TSGCustomConnectionHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			public
		procedure Recieved(const Stream : TMemoryStream; const Socket : TLSocket);
			protected
		FConnection : TSGUDPConnection;
			public
		property Connection : TSGUDPConnection read FConnection;
		end;
	
	TSGPacketType = TSGString;
	TSGDataType = TSGString;
	(*
	Packet = ['SAGEPACKET', $PacketIterator<UInt64>, $PacketType, #0, $PacketData];
	PacketData<TryConnect> = [];
	PacketData<ConnectionSuccess> = [];
	PacketData<Check> = [];
	PacketData<CheckSuccess> = [];
	PacketData<Disconnect> = [];
	PacketData<Data> = [$DataType, #0, $Data];
	*)
const
	SGPacketTryConnect        : TSGPacketType = 'TRYCONNECT';
	SGPacketConnectionSuccess : TSGPacketType = 'CONNECTIONSUCS';
	SGPacketCheck             : TSGPacketType = 'CHECK';
	SGPacketCheckSuccess      : TSGPacketType = 'CHECKSUCS';
	SGPacketDisconnect        : TSGPacketType = 'DISCONNECT';
	SGPacketData              : TSGPacketType = 'DATA';
type
	TSGUDPServer = class(TSGCustomUDPConnectionHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			protected
		FCkeckInterval : TSGUInt16;
		end;
	
	TSGUDPClient = class(TSGCustomUDPConnectionHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
		end;
	
	TSGHTTPHandler=class
			public
		Done, Error : TSGBoolean;
		Stream : TMemoryStream;
			public
		procedure ClientDisconnect(ASocket: TLSocket);
		procedure ClientDoneInput(ASocket: TLHTTPClientSocket);
		procedure ClientError(const Msg: string; aSocket: TLSocket);
		function ClientInput(ASocket: TLHTTPClientSocket; ABuffer: pchar; ASize: Integer): Integer;
		procedure ClientProcessHeaders(ASocket: TLHTTPClientSocket);
		end;

function SGHTTPGetString      (const URL : TSGString; const Timeout : TSGLongWord = SGDefaultHTTPTimeOut; const ErrorViewCase : TSGViewErrorType = []) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGHTTPGetMemoryStream(const URL : TSGString; const Timeout : TSGLongWord = SGDefaultHTTPTimeOut; const ErrorViewCase : TSGViewErrorType = []) : TMemoryStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGHTTPGetStream      (const URL : TSGString; const Timeout : TSGLongWord = SGDefaultHTTPTimeOut; const ErrorViewCase : TSGViewErrorType = []) : TStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGHTTPGet            (const URL : TSGString; const Timeout : TSGLongWord = SGDefaultHTTPTimeOut; const ErrorViewCase : TSGViewErrorType = []) : TStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGMemoryStreamToString(MS : TMemoryStream;const DestroyStream : Boolean = False):String;

function SGCheckURL(const URL : TSGString; const Protocol : TSGString = ''; const Port : TSGUInt16 = 0) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetURLProtocol(const URL : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGSetURLProtocol(const URL, Protocol : TSGString) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGDecomposeURL(const URL : TSGString; out Host, URI : TSGString; out Port : TSGUInt16) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SGConsoleUDPConnection(const IsServer : TSGBool; const URL : TSGString; const ServerPort : TSGUInt16 = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGConsoleUDPServer(const Port : TSGUInt16);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGConsoleUDPClient(const URL : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	StrMan
	,SaGeConsoleTools
	;

// TSGUDPClient

constructor TSGUDPClient.Create();
begin
inherited;
FConnection.ConnectionMode := SGClientMode;
end;

destructor TSGUDPClient.Destroy();
begin
inherited;
end;

class function TSGUDPClient.ClassName() : TSGString;
begin
Result := 'TSGUDPClient';
end;

// TSGUDPServer

constructor TSGUDPServer.Create();
begin
inherited;
FCkeckInterval := 50;
FConnection.ConnectionMode := SGServerMode;
end;

destructor TSGUDPServer.Destroy();
begin
inherited;
end;

class function TSGUDPServer.ClassName() : TSGString;
begin
Result := 'TSGUDPServer';
end;

// TSGCustomUDPConnectionHandler

procedure TSGCustomUDPConnectionHandler.Recieved(const Stream : TMemoryStream; const Socket : TLSocket);
begin

end;

procedure TSGCustomUDPConnectionHandler_Received(Parent : TSGCustomUDPConnectionHandler; AStream : TMemoryStream; aSocket : TLSocket);
begin
Parent.Recieved(AStream, aSocket);
end;

constructor TSGCustomUDPConnectionHandler.Create();
begin
inherited;
FConnection := TSGUDPConnection.Create();
FConnection.ReceiveProcedure := TSGReceiveProcedure(@TSGCustomUDPConnectionHandler_Received);
FConnection.Parent := Self;
end;

destructor TSGCustomUDPConnectionHandler.Destroy();
begin
if FConnection <> nil then
	begin
	FConnection.Destroy();
	FConnection := nil;
	end;
inherited;
end;

class function TSGCustomUDPConnectionHandler.ClassName() : TSGString;
begin
Result := 'TSGCustomUDPConnectionHandler';
end;

// TSGCustomConnectionHandler

function TSGCustomConnectionHandler.HostsCount() : TSGMaxEnum; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := 0;
if FHosts <> nil then
	Result := Length(FHosts);
end;

function TSGCustomConnectionHandler.GetHost(const Index : TSGMaxEnum) : PSGHost; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := nil;
if (Index >= 0) and (Index < HostsCount()) then
	Result := @FHosts[Index];
end;

constructor TSGCustomConnectionHandler.Create();
begin
inherited;
FIterator := 1;
FHosts := nil;
end;

destructor TSGCustomConnectionHandler.Destroy();
begin
if FHosts <> nil then
	begin
	SetLength(FHosts, 0);
	FHosts := nil;
	end;
inherited;
end;

class function TSGCustomConnectionHandler.ClassName() : TSGString;
begin
Result := 'TSGCustomConnectionHandler';
end;

function SGSetURLProtocol(const URL, Protocol : TSGString) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := URL;
if StringWordCount(URL, ':') = 2 then
	Result := Protocol + ':' + StringWordGet(URL, ':', 2)
else if StringWordCount(URL, ':') = 1 then
	Result := Protocol + '://' + URL
else
	Result := URL;
end;

function SGGetURLProtocol(const URL : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, Pos2 : TSGUInt32;
begin
if StringWordCount(URL, ':') = 2 then
	Result := StringWordGet(URL, ':', 1)
else
	Result := '';
end;

function SGCheckURL(const URL : TSGString; const Protocol : TSGString = ''; const Port : TSGUInt16 = 0) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	VPort : TSGUInt16;
	Host, URI : TSGString;
	URLProtocol : TSGString;
begin
Result := URL;
URLProtocol := SGGetURLProtocol(Result);
if (URLProtocol = '') and (Protocol <> '') then
	begin
	URLProtocol := Protocol;
	Result := SGSetURLProtocol(Result, URLProtocol);
	end;
DecomposeURL(Result, Host, URI, VPort);
if Port <> 0 then
	VPort := Port;
if URI = '' then
	URI := '/';
Result := URLProtocol + '://' + Host + URI;
if Port <> 0 then
	Result += ':' + SGStr(Port);
SGLog.Source(Result);
end;

function SGMemoryStreamToString(MS : TMemoryStream;const DestroyStream : Boolean = False):String;
var
	c : char;
begin
Result := '';
if MS <> nil then
	begin
	MS.Position := 0;
	while MS.Position <> MS.Size do
		begin
		MS.ReadBuffer(c, 1);
		Result += c;
		end;
	if DestroyStream then
		MS.Destroy();
	end;
end;

procedure TSGHTTPHandler.ClientProcessHeaders(ASocket: TLHTTPClientSocket);
begin
{$IFDEF SGDebuging}
	SGLog.Source(['TSGHTTPHandler.ClientProcessHeaders - "'+'ResponseStatus="', HTTPStatusCodes[ASocket.ResponseStatus],'", ResponseReason="',ASocket.ResponseReason, '"']);
	{$ENDIF}
end;

procedure TSGHTTPHandler.ClientError(const Msg: string; aSocket: TLSocket);
begin
{$IFDEF SGDebuging}
	SGLog.Source('TSGHTTPHandler.ClientError - Error="'+Msg+'"');
	{$ENDIF}
Error := True;
end;

procedure TSGHTTPHandler.ClientDisconnect(ASocket: TLSocket);
begin
Done := True;
{$IFDEF SGDebuging}
	SGLog.Source('TSGHTTPHandler.ClientDisconnect');
	{$ENDIF}
end;
  
procedure TSGHTTPHandler.ClientDoneInput(ASocket: TLHTTPClientSocket);
begin
Stream.Position := 0;
ASocket.Disconnect();
{$IFDEF SGDebuging}
	SGLog.Source('TSGHTTPHandler.ClientDoneInput');
	{$ENDIF}
end;

function TSGHTTPHandler.ClientInput(ASocket: TLHTTPClientSocket;
  ABuffer: PChar; ASize: Integer): Integer;
begin
Stream.WriteBuffer(ABuffer^,ASize);
Result := ASize;
{$IFDEF SGDebuging}
	SGLog.Source('TSGHTTPHandler.ClientInput');
	{$ENDIF}
end;

function SGHTTPGetString(const URL : TSGString; const Timeout : TSGLongWord = SGDefaultHTTPTimeOut; const ErrorViewCase : TSGViewErrorType = []) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGMemoryStreamToString(SGHTTPGetMemoryStream(URL, Timeout, ErrorViewCase), True);
end;

function SGHTTPGetStream(const URL : TSGString; const Timeout : TSGLongWord = SGDefaultHTTPTimeOut; const ErrorViewCase : TSGViewErrorType = []) : TStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGHTTPGetMemoryStream(URL, Timeout, ErrorViewCase);
end;

function SGHTTPGet(const URL : TSGString; const Timeout : TSGLongWord = SGDefaultHTTPTimeOut; const ErrorViewCase : TSGViewErrorType = []) : TStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGHTTPGetMemoryStream(URL, Timeout, ErrorViewCase);
end;

function SGHTTPGetMemoryStream(const URL : TSGString; const Timeout : TSGLongWord = SGDefaultHTTPTimeOut; const ErrorViewCase : TSGViewErrorType = []) : TMemoryStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	Client : TSGHTTPHandler = nil;
	HttpClient : TLHTTPClient = nil;
	UseSSL : TSGBool;
	Port : TSGUInt16;
	Host, URI : TSGString;
	Protocol : TSGString;
	FinalURL : TSGString;
begin
Result:=nil;
Protocol := SGGetURLProtocol(URL);
SGHint(['HTTP:Get<lNet>: Protocol="', Protocol, '"'], ErrorViewCase);
if Protocol = '' then
	Protocol := 'http';
FinalURL := SGCheckURL(URL, Protocol);
UseSSL := DecomposeURL(FinalURL, Host, URI, Port);
SGHint(['HTTP:Get<lNet>: URL="', FinalURL, '"'], ErrorViewCase);
if UseSSL then
	begin
	SGHint(['HTTP:Get<lNet>: SSL does not supporting! Exit.'], ErrorViewCase + [SGLogError]);
	Exit;
	end;

SGHint(['HTTP:Get<lNet>: Try get from: Host="',Host,'", URI="',URI,'", Port="',Port,'", TimeOut="',TimeOut,'"'], ErrorViewCase);

Client := TSGHTTPHandler.Create();
Client.Done := False;
Client.Stream := TMemoryStream.Create();

HttpClient := TLHTTPClient.Create(nil);
HttpClient.Session := nil;
HttpClient.Host := Host;
HttpClient.Method := hmGet;
HttpClient.Port := Port;
HttpClient.URI := URI;
HttpClient.Timeout := Timeout;
HttpClient.OnDisconnect := @Client.ClientDisconnect;
HttpClient.OnDoneInput := @Client.ClientDoneInput;
HttpClient.OnError := @Client.ClientError;
HttpClient.OnInput := @Client.ClientInput;
HttpClient.OnProcessHeaders := @Client.ClientProcessHeaders;
HttpClient.SendRequest();
Client.Done := False;
Client.Error := False;

SGHint('HTTP:Get<lNet>: Begin looping...', ErrorViewCase);

while (not Client.Done) and (not Client.Error) do
	begin
	HttpClient.CallAction();
	SysUtils.Sleep(3);
	end;

HttpClient.Free;

if Client.Done then
	Result := Client.Stream
else
	Client.Stream.Destroy();

Client.Destroy();

SGHint(['HTTP:Get<lNet>: Done with  Result=',SGAddrStr(Result),'.'], ErrorViewCase);
if Result <> nil then
	Result.Position := 0;
end;

class function TSGUDPConnection.ClassName() : TSGString;
begin
Result := 'TSGUDPConnection';
end;

function TSGUDPConnection.SendMemoryStream(const AStream:TMemoryStream):Integer;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := FConnection.SendMemoryStream(AStream);
end;

function TSGUDPConnection.Listen() : TSGBool;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := FConnection.Listen(FPort);
FConnectionResult := Result;
end;

procedure TSGUDPConnection.CallAction();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
FConnection.CallAction();
end;

function TSGUDPConnection.Start() : TSGBool;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
case FConnectionMode of
SGClientMode : Result := Connect();
SGServerMode : Result := Listen();
end;
FConnectionResult := Result;
end;

function TSGUDPConnection.Connect() : TSGBool;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := FConnection.Connect(FAddress, FPort);
FConnectionResult := Result;
end;

function TSGUDPConnectionClass.SendMemoryStream(const AStream : TMemoryStream):Integer;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := Send(AStream.Memory^, AStream.Size);
end;

constructor TSGUDPConnection.Create();
begin
inherited;
FNestedReceiveProcedure := nil;
FReceiveProcedure := nil;
FViewErrorCase := [SGPrintError, SGLogError];
FConnection := TSGUDPConnectionClass.Create(nil);
FConnection.OnError := TLSocketErrorEvent(@OnError);
FConnection.OnReceive := @OnReceive;
FConnection.Timeout := 100; 
FParent := nil;
FAddress := 'localhost';
FPort := 5233;
FConnectionMode := SGClientMode;
FConnectionResult := False;
end;

destructor TSGUDPConnection.Destroy();
begin
if FConnection <> nil then
	begin
	try
	FConnection.Free();
	except on e:Exception do
	end;
	FConnection:=nil;
	end;
inherited;
end;

procedure TSGUDPConnection.OnError(const msg: string; aSocket: TLSocket);
begin
SGHint('TSGUDPConnection: Error: "' + Msg + '"; Socket: '+SGAddrStr(aSocket) +'.', FViewErrorCase);
FConnectionResult := False;
end;

procedure TSGUDPConnection.OnReceive(aSocket: TLSocket);
var
	Stream : TMemoryStream;
	AMemory : TSGPointer;
	ASize : TSGInt32;
begin
ASize := BUFFER_SIZE;
GetMem(AMemory, ASize);
ASize := aSocket.Get(AMemory^, ASize);
Stream := TMemoryStream.Create();
Stream.WriteBuffer(AMemory^, ASize);
FreeMem(AMemory, BUFFER_SIZE);
Stream.Position := 0;
if FReceiveProcedure<>nil then
	FReceiveProcedure(FParent, Stream, aSocket);
if FNestedReceiveProcedure<>nil then
	FNestedReceiveProcedure(FParent, Stream, aSocket);
Stream.Free();
end;

function SGDecomposeURL(const URL : TSGString; out Host, URI : TSGString; out Port : TSGUInt16) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function StringIsNumber(const Str : TSGString) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGUInt32;
begin
Result := Str <> '';
if Result then
	for i := 1 to Length(Str) do
		if not (Str[i] in '0123456789') then
			begin
			Result := False;
			break;
			end;
end;

begin
Result := False;
if StringMatching(SGUpCaseString(URL), 'LOCALHOST*') then
	begin
	Host := 'localhost';
	Port := 0;
	URI := '';
	if (StringWordCount(URL, ':') = 2) then
		if StringIsNumber(StringWordGet(URL, ':', 2)) then
			Port := SGVal(StringWordGet(URL, ':', 2))
		else
			SGHint('SGDecomposeURL: Error while pasring port!');
	end
else if StringMatching(URL, '*?.*?.*?.*?:*?') then
	begin
	Port := 0;
	URI := '';
	Host := StringWordGet(URL, ':', 1);
	if StringIsNumber(StringWordGet(URL, ':', 2)) then
		Port := SGVal(StringWordGet(URL, ':', 2))
	else
		SGHint('SGDecomposeURL: Error while pasring port!');
	end
else if StringMatching(URL, '*?.*?.*?.*?') then
	begin
	Port := 0;
	Host := URL;
	URI := '';
	end
else
	begin
	Result := DecomposeURL(URL, Host, URI, Port);
	end;
end;

procedure SGConsoleUDPClient(const URL : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SGConsoleUDPConnection(False, URL);
end;

procedure SGConsoleUDPServer(const Port : TSGUInt16);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SGConsoleUDPConnection(True, '', Port);
end;

procedure SGConsoleUDPConnection(const IsServer : TSGBool; const URL : TSGString; const ServerPort : TSGUInt16 = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function ConnectionType() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if IsServer then
	Result := 'Server'
else
	Result := 'Client';
end;

function ConnectionParam() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if IsServer then
	Result := SGStr(ServerPort)
else
	Result := URL;
end;

procedure SetConnectionURL(const Connection : TSGUDPConnection; const URL : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Port : TSGUInt16;
	Host, URI : TSGString;
begin
SGDecomposeURL(URL, Host, URI, Port);
SGHint(['UDP Connection<', ConnectionType, '>(', ConnectionParam, '): Host="',Host,'", URI="',URI,'", Port="',Port,'"']);
Connection.Address := Host + URI;
Connection.Port := Port;
end;

procedure OnReceive(Parent : TSGPointer; AStream : TMemoryStream; aSocket : TLSocket);
begin
Write('Received:"');
SGWriteStream(AStream);
WriteLn('" PeerAddress: "', aSocket.PeerAddress, '", PeerPort: "', aSocket.PeerPort, '".');
end;

var
	Connection : TSGUDPConnection = nil;
	RK : TSGChar = #0;
begin
SGPrintEngineVersion();
Connection := TSGUDPConnection.Create();
if IsServer then
	begin
	Connection.ConnectionMode := SGServerMode;
	Connection.Port := ServerPort;
	end
else
	begin
	Connection.ConnectionMode := SGClientMode;
	SetConnectionURL(Connection, URL);
	end;
Connection.NestedReceiveProcedure := @OnReceive;
Connection.Start();
SGHint(['UDP Connection<', ConnectionType, '>(', ConnectionParam, '): Ready=', Connection.Ready]);
while Connection.Ready do
	begin
	if KeyPressed then
		begin
		RK := ReadKey;
		WriteLn('Send:"',RK,'".');
		Connection.SendMemoryStream(SGStringToStream(RK));
		end;
	Connection.CallAction();
	Sleep(2);
	end;
Connection.Destroy();
end;

initialization
begin

end;

finalization
begin

end;

end.
