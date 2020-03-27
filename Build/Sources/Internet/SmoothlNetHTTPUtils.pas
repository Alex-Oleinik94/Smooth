{$INCLUDE Smooth.inc}

unit SmoothlNetHTTPUtils;

interface

uses
	 SmoothBase
	,SmoothCasesOfPrint
	,SmoothlNetBase
	
	,Classes
	
	,lNet
	,lhttp
	;
const
	SDefaultHTTPTimeOut = SDefaultTimeOut;
type
	TSHTTPHandler = class
			public
		Done, Error : TSBoolean;
		Stream : TMemoryStream;
			public
		procedure ClientDisconnect(ASocket: TLSocket);
		procedure ClientDoneInput(ASocket: TLHTTPClientSocket);
		procedure ClientError(const Msg: string; aSocket: TLSocket);
		function ClientInput(ASocket: TLHTTPClientSocket; ABuffer: pchar; ASize: Integer): Integer;
		procedure ClientProcessHeaders(ASocket: TLHTTPClientSocket);
		end;

function SHTTPGetString      (const URL : TSString; const Timeout : TSLongWord = SDefaultHTTPTimeOut; const CasesOfPrint : TSCasesOfPrint = []) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SHTTPGetMemoryStream(const URL : TSString; const Timeout : TSLongWord = SDefaultHTTPTimeOut; const CasesOfPrint : TSCasesOfPrint = []) : TMemoryStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SHTTPGetStream      (const URL : TSString; const Timeout : TSLongWord = SDefaultHTTPTimeOut; const CasesOfPrint : TSCasesOfPrint = []) : TStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SHTTPGet            (const URL : TSString; const Timeout : TSLongWord = SDefaultHTTPTimeOut; const CasesOfPrint : TSCasesOfPrint = []) : TStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SMemoryStreamToString(MS : TMemoryStream; const DestroyStream : TSBoolean = False) : TSString;

implementation

uses
	 SmoothlNetURIParser
	,SmoothLog
	,SmoothStringUtils
	
	,SysUtils
	;

function SMemoryStreamToString(MS : TMemoryStream; const DestroyStream : TSBoolean = False) : TSString;
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

function SHTTPGetString(const URL : TSString; const Timeout : TSLongWord = SDefaultHTTPTimeOut; const CasesOfPrint : TSCasesOfPrint = []) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SMemoryStreamToString(SHTTPGetMemoryStream(URL, Timeout, CasesOfPrint), True);
end;

function SHTTPGetStream(const URL : TSString; const Timeout : TSLongWord = SDefaultHTTPTimeOut; const CasesOfPrint : TSCasesOfPrint = []) : TStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SHTTPGetMemoryStream(URL, Timeout, CasesOfPrint);
end;

function SHTTPGet(const URL : TSString; const Timeout : TSLongWord = SDefaultHTTPTimeOut; const CasesOfPrint : TSCasesOfPrint = []) : TStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SHTTPGetMemoryStream(URL, Timeout, CasesOfPrint);
end;

function SHTTPGetMemoryStream(const URL : TSString; const Timeout : TSLongWord = SDefaultHTTPTimeOut; const CasesOfPrint : TSCasesOfPrint = []) : TMemoryStream;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	Client : TSHTTPHandler = nil;
	HttpClient : TLHTTPClient = nil;
	UseSSL : TSBool;
	Port : TSUInt16;
	Host, URI : TSString;
	Protocol : TSString;
	FinalURL : TSString;
begin
Result:=nil;
Protocol := SGetURLProtocol(URL);
SHint(['HTTP:Get<lNet>: Protocol="', Protocol, '"'], CasesOfPrint);
if Protocol = '' then
	Protocol := 'http';
FinalURL := SCheckURL(URL, Protocol);
UseSSL := SDecomposeURL(FinalURL, Host, URI, Port);
SHint(['HTTP:Get<lNet>: URL="', FinalURL, '"'], CasesOfPrint);
if UseSSL then
	begin
	SHint(['HTTP:Get<lNet>: SSL does not supporting! Exit.'], CasesOfPrint + [SCaseLog]);
	Exit;
	end;

SHint(['HTTP:Get<lNet>: Try get from: Host="',Host,'", URI="',URI,'", Port="',Port,'", TimeOut="',TimeOut,'"'], CasesOfPrint);

Client := TSHTTPHandler.Create();
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

SHint('HTTP:Get<lNet>: Begin looping...', CasesOfPrint);

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

SHint(['HTTP:Get<lNet>: Done with  Result=',SAddrStr(Result),'.'], CasesOfPrint);
if Result <> nil then
	Result.Position := 0;
end;

// ========================================
// =============TSHTTPHandler=============
// ========================================

procedure TSHTTPHandler.ClientProcessHeaders(ASocket: TLHTTPClientSocket);
begin
{$IFDEF SDebuging}
	SLog.Source(['TSHTTPHandler.ClientProcessHeaders - "'+'ResponseStatus="', HTTPStatusCodes[ASocket.ResponseStatus],'", ResponseReason="',ASocket.ResponseReason, '"']);
	{$ENDIF}
end;

procedure TSHTTPHandler.ClientError(const Msg: string; aSocket: TLSocket);
begin
{$IFDEF SDebuging}
	SLog.Source('TSHTTPHandler.ClientError - Error="'+Msg+'"');
	{$ENDIF}
Error := True;
end;

procedure TSHTTPHandler.ClientDisconnect(ASocket: TLSocket);
begin
Done := True;
{$IFDEF SDebuging}
	SLog.Source('TSHTTPHandler.ClientDisconnect');
	{$ENDIF}
end;
  
procedure TSHTTPHandler.ClientDoneInput(ASocket: TLHTTPClientSocket);
begin
Stream.Position := 0;
ASocket.Disconnect();
{$IFDEF SDebuging}
	SLog.Source('TSHTTPHandler.ClientDoneInput');
	{$ENDIF}
end;

function TSHTTPHandler.ClientInput(ASocket: TLHTTPClientSocket;
  ABuffer: PChar; ASize: Integer): Integer;
begin
Stream.WriteBuffer(ABuffer^,ASize);
Result := ASize;
{$IFDEF SDebuging}
	SLog.Source('TSHTTPHandler.ClientInput');
	{$ENDIF}
end;

end.
