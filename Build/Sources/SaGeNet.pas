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
	TSGSocket = TLSocket;
	TSGUDPConnectionClass=class(TLUDP)
		function SendMemoryStream(const AStream:TMemoryStream):Integer;inline;
		end;
	
	TSGReceiveProcedure       = procedure(Parent : TSGPointer; AStream : TMemoryStream; aSocket : TSGSocket);
	TSGNestedReceiveProcedure = procedure(Parent : TSGPointer; AStream : TMemoryStream; aSocket : TSGSocket) is nested;
	
	TSGConnectionMode = (SGServerMode,SGClientMode);
	
	TSGUDPConnection=class
			public
		constructor Create;
		destructor Destroy;override;
			public
		FViewErrorCase : TSGViewErrorType;
		FConnection: TSGUDPConnectionClass;
		FReceiveProcedure:TSGReceiveProcedure;
		FNestedReceiveProcedure:TSGNestedReceiveProcedure;
		FParent:Pointer;
		FAddress:string;
		FPort:Word;
		FConnectionMode:TSGConnectionMode;
		FConnectionResult:Boolean;
		procedure OnError(const msg: string; aSocket: TLSocket);
		procedure OnReceive(aSocket: TLSocket);
			public
		procedure Listen;inline;
		procedure Connect;inline;
		procedure Start;inline;
		procedure CallAction;inline;
		function SendMemoryStream(const AStream:TMemoryStream):Integer;inline;
			public
		property ReceiveProcedure:TSGReceiveProcedure read FReceiveProcedure write FReceiveProcedure;
		property NestedReceiveProcedure:TSGNestedReceiveProcedure read FNestedReceiveProcedure write FNestedReceiveProcedure;
		property Parent:Pointer read FParent write FParent;
		property ConnectionMode:TSGConnectionMode read FConnectionMode write FConnectionMode;
		property Port:Word read FPort write FPort;
		property Host:String read FAddress write FAddress;
		property Address:String read FAddress write FAddress;
		property Ready:boolean read FConnectionResult;
		end;

	TSGHTTPHandler=class
			public
		Done, Error : Boolean;
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
procedure SGConsoleServer(const Port : TSGUInt16);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGConsoleClient(const URL : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	StrMan
	,SaGeConsoleTools
	;

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
		MS.ReadBuffer(c,1);
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
Done := true;
{$IFDEF SGDebuging}
	SGLog.Source('TSGHTTPHandler.ClientDisconnect');
	{$ENDIF}
end;
  
procedure TSGHTTPHandler.ClientDoneInput(ASocket: TLHTTPClientSocket);
begin
Stream.Position := 0;
ASocket.Disconnect;
{$IFDEF SGDebuging}
	SGLog.Source('TSGHTTPHandler.ClientDoneInput');
	{$ENDIF}
end;

function TSGHTTPHandler.ClientInput(ASocket: TLHTTPClientSocket;
  ABuffer: pchar; ASize: Integer): Integer;
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
SGHint(['lNet HTTP Get: Protocol="', Protocol, '"'], ErrorViewCase);
if Protocol = '' then
	Protocol := 'http';
FinalURL := SGCheckURL(URL, Protocol);
UseSSL := DecomposeURL(FinalURL, Host, URI, Port);
SGHint(['lNet HTTP Get: URL="', FinalURL, '"'], ErrorViewCase);
if UseSSL then
	begin
	SGHint(['lNet HTTP Get: SSL does not supporting! Exit.'], ErrorViewCase);
	Exit;
	end;

SGHint(['lNet HTTP Get: Try get from: Host="',Host,'", URI="',URI,'", Port="',Port,'", TimeOut="',TimeOut,'"'], ErrorViewCase);

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
HttpClient.SendRequest;
Client.Done := false;
Client.Error := false;

SGHint('lNet HTTP Get: Begin looping...', ErrorViewCase);

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

SGHint(['lNet HTTP Get: Done with  Result=',SGAddrStr(Result),'.'], ErrorViewCase);
if Result <> nil then
	Result.Position := 0;
end;

function TSGUDPConnection.SendMemoryStream(const AStream:TMemoryStream):Integer;inline;
begin
Result:=FConnection.SendMemoryStream(AStream);
end;

procedure TSGUDPConnection.Listen;inline;
begin
FConnectionResult:=FConnection.Listen(FPort);
end;

procedure TSGUDPConnection.CallAction;inline;
begin
FConnection.CallAction;
end;

procedure TSGUDPConnection.Start;inline;
begin
case FConnectionMode of
SGClientMode:Connect;
SGServerMode:Listen;
end;
end;

procedure TSGUDPConnection.Connect;inline;
begin
FConnectionResult:=FConnection.Connect(FAddress,FPort);
end;

function TSGUDPConnectionClass.SendMemoryStream(const AStream:TMemoryStream):Integer;inline;
begin
Result:=Send(AStream.Memory^,AStream.Size);
end;

constructor TSGUDPConnection.Create;
begin
inherited;
FNestedReceiveProcedure := nil;
FReceiveProcedure := nil;
FViewErrorCase := [SGPrintError, SGLogError];
FConnection := TSGUDPConnectionClass.Create(nil);
FConnection.OnError := TLSocketErrorEvent(@OnError);
FConnection.OnReceive := @OnReceive;
FConnection.Timeout := 100; 
FParent:=nil;
FAddress:='localhost';
FPort:=5233;
FConnectionMode:=SGClientMode;
FConnectionResult:=False;
end;

destructor TSGUDPConnection.Destroy;
begin
if FConnection <> nil then
	begin
	FConnection.Destroy;
	FConnection:=nil;
	end;
inherited;
end;

procedure TSGUDPConnection.OnError(const msg: string; aSocket: TLSocket);
begin
SGHint('TSGUDPConnection: Error: "' + Msg + '; Socket: '+SGAddrStr(aSocket) +'.', FViewErrorCase);
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
else
	begin
	Result := DecomposeURL(URL, Host, URI, Port);
	end;
end;

procedure SGConsoleServer(const Port : TSGUInt16);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Connection : TSGUDPConnection = nil;

procedure OnReceive(Parent : TSGPointer; AStream : TMemoryStream; aSocket : TSGSocket);
begin
SGWriteStream(AStream);
end;

var
	RK : TSGChar = #0;
begin
SGPrintEngineVersion();
Connection := TSGUDPConnection.Create();
Connection.ConnectionMode := SGServerMode;
Connection.Port := Port;
Connection.NestedReceiveProcedure := @OnReceive;
Connection.Start();
SGHint(['SGConsoleServer(',Port,'): Ready=', Connection.Ready]);
while Connection.Ready do
	begin
	if KeyPressed then
		begin
		RK := ReadKey;
		Write(RK);
		Connection.SendMemoryStream(SGStringToStream(RK));
		end;
	Connection.CallAction();
	Sleep(5);
	end;
Connection.Destroy();
end;

procedure SGConsoleClient(const URL : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Connection : TSGUDPConnection = nil;

procedure OnReceive(Parent : TSGPointer; AStream : TMemoryStream; aSocket : TSGSocket);
begin
SGWriteStream(AStream);
end;

procedure SetURL();
var
	Port : TSGUInt16;
	Host, URI : TSGString;
begin
SGDecomposeURL(URL, Host, URI, Port);
SGHint(['SGConsoleClient("',URL,'"): Host="',Host,'", URI="',URI,'", Port="',Port,'"']);
Connection.Address := Host + URI;
Connection.Port := Port;
end;

var
	RK : TSGChar = #0;
begin
SGPrintEngineVersion();
Connection := TSGUDPConnection.Create();
Connection.ConnectionMode := SGClientMode;
SetURL();
Connection.NestedReceiveProcedure := @OnReceive;
Connection.Start();
SGHint(['SGConsoleClient("',URL,'"): Ready=', Connection.Ready]);
while Connection.Ready do
	begin
	if KeyPressed then
		begin
		RK := ReadKey;
		Write(RK);
		Connection.SendMemoryStream(SGStringToStream(RK));
		end;
	Connection.CallAction();
	Sleep(5);
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
