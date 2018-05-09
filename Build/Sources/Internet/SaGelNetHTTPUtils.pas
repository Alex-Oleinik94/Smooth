{$INCLUDE SaGe.inc}

unit SaGelNetHTTPUtils;

interface

uses
	 SaGeBase
	,SaGeCasesOfPrint
	,SaGelNetBase
	
	,Classes
	
	,lNet
	,lhttp
	;
const
	SGDefaultHTTPTimeOut = SGDefaultTimeOut;
type
	TSGHTTPHandler = class
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

function SGHTTPGetString      (const URL : TSGString; const Timeout : TSGLongWord = SGDefaultHTTPTimeOut; const CasesOfPrint : TSGCasesOfPrint = []) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGHTTPGetMemoryStream(const URL : TSGString; const Timeout : TSGLongWord = SGDefaultHTTPTimeOut; const CasesOfPrint : TSGCasesOfPrint = []) : TMemoryStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGHTTPGetStream      (const URL : TSGString; const Timeout : TSGLongWord = SGDefaultHTTPTimeOut; const CasesOfPrint : TSGCasesOfPrint = []) : TStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGHTTPGet            (const URL : TSGString; const Timeout : TSGLongWord = SGDefaultHTTPTimeOut; const CasesOfPrint : TSGCasesOfPrint = []) : TStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGMemoryStreamToString(MS : TMemoryStream; const DestroyStream : TSGBoolean = False) : TSGString;

implementation

uses
	 SaGelNetURIParser
	,SaGeLog
	,SaGeStringUtils
	
	,SysUtils
	;

function SGMemoryStreamToString(MS : TMemoryStream; const DestroyStream : TSGBoolean = False) : TSGString;
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

function SGHTTPGetString(const URL : TSGString; const Timeout : TSGLongWord = SGDefaultHTTPTimeOut; const CasesOfPrint : TSGCasesOfPrint = []) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGMemoryStreamToString(SGHTTPGetMemoryStream(URL, Timeout, CasesOfPrint), True);
end;

function SGHTTPGetStream(const URL : TSGString; const Timeout : TSGLongWord = SGDefaultHTTPTimeOut; const CasesOfPrint : TSGCasesOfPrint = []) : TStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGHTTPGetMemoryStream(URL, Timeout, CasesOfPrint);
end;

function SGHTTPGet(const URL : TSGString; const Timeout : TSGLongWord = SGDefaultHTTPTimeOut; const CasesOfPrint : TSGCasesOfPrint = []) : TStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGHTTPGetMemoryStream(URL, Timeout, CasesOfPrint);
end;

function SGHTTPGetMemoryStream(const URL : TSGString; const Timeout : TSGLongWord = SGDefaultHTTPTimeOut; const CasesOfPrint : TSGCasesOfPrint = []) : TMemoryStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
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
SGHint(['HTTP:Get<lNet>: Protocol="', Protocol, '"'], CasesOfPrint);
if Protocol = '' then
	Protocol := 'http';
FinalURL := SGCheckURL(URL, Protocol);
UseSSL := SGDecomposeURL(FinalURL, Host, URI, Port);
SGHint(['HTTP:Get<lNet>: URL="', FinalURL, '"'], CasesOfPrint);
if UseSSL then
	begin
	SGHint(['HTTP:Get<lNet>: SSL does not supporting! Exit.'], CasesOfPrint + [SGCaseLog]);
	Exit;
	end;

SGHint(['HTTP:Get<lNet>: Try get from: Host="',Host,'", URI="',URI,'", Port="',Port,'", TimeOut="',TimeOut,'"'], CasesOfPrint);

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

SGHint('HTTP:Get<lNet>: Begin looping...', CasesOfPrint);

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

SGHint(['HTTP:Get<lNet>: Done with  Result=',SGAddrStr(Result),'.'], CasesOfPrint);
if Result <> nil then
	Result.Position := 0;
end;

// ========================================
// =============TSGHTTPHandler=============
// ========================================

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

end.
