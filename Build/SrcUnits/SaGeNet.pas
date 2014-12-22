{$I Includes\SaGe.inc}

unit SaGeNet;

interface

uses
	Crt
	,SysUtils
	,Classes
	,StrUtils
	
	,SaGeBase
	,SaGeBased
	,SaGeCommon
	
	,lCommon
	,lhttp
	,lnetSSL
	,lNet
	,URIParser
	,lHTTPUtil
	;

type
	TSGSocket = TLSocket;
	TSGUDPConnectionClass=class(TLUDP)
		function SendMemoryStream(const AStream:TMemoryStream):Integer;inline;
		end;
	
	TSGReceiveProcedure=procedure(Parant:Pointer;AStream:TMemoryStream; aSocket: TSGSocket);
	
	TSGConnectionMode = (SGServerMode,SGClientMode);
	
	TSGUDPConnection=class
			public
		constructor Create;
		destructor Destroy;override;
			public
		FConnection: TSGUDPConnectionClass;
		FReceiveProcedure:TSGReceiveProcedure;
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
		property Parent:Pointer read FParent write FParent;
		property ConnectionMode:TSGConnectionMode read FConnectionMode write FConnectionMode;
		property Port:Word read FPort write FPort;
		property Host:String read FAddress write FAddress;
		property Address:String read FAddress write FAddress;
		property Ready:boolean read FConnectionResult;
		end;

	TSGHTTPHandler=class
			public
		Done : Boolean;
		Stream : TMemoryStream;
			public
		procedure ClientDisconnect(ASocket: TLSocket);
		procedure ClientDoneInput(ASocket: TLHTTPClientSocket);
		procedure ClientError(const Msg: string; aSocket: TLSocket);
		function ClientInput(ASocket: TLHTTPClientSocket; ABuffer: pchar; ASize: Integer): Integer;
		procedure ClientProcessHeaders(ASocket: TLHTTPClientSocket);
		end;

function SGGetFromHTTP(const Way : String; const Timeout : LongWord = 200):TMemoryStream;

implementation

procedure TSGHTTPHandler.ClientProcessHeaders(ASocket: TLHTTPClientSocket);
begin
  {write('Response: ', HTTPStatusCodes[ASocket.ResponseStatus], ' ', 
    ASocket.ResponseReason, ', data...');}
end;

procedure TSGHTTPHandler.ClientError(const Msg: string; aSocket: TLSocket);
begin
  {writeln('Error: ', Msg);}
end;

procedure TSGHTTPHandler.ClientDisconnect(ASocket: TLSocket);
begin
  {writeln('Disconnected.');}
  done := true;
end;
  
procedure TSGHTTPHandler.ClientDoneInput(ASocket: TLHTTPClientSocket);
begin
  //writeln('done.');
  //close(OutputFile);
  Stream.Position := 0;
  ASocket.Disconnect;
end;

function TSGHTTPHandler.ClientInput(ASocket: TLHTTPClientSocket;
  ABuffer: pchar; ASize: Integer): Integer;
begin
  {blockwrite(outputfile, ABuffer^, ASize, Result);
  write(IntToStr(ASize) + '...');}
  Stream.WriteBuffer(ABuffer^,ASize);
  Result := ASize;
end;

function SGGetFromHTTP(const Way : String; const Timeout : LongWord = 200):TMemoryStream;
var
	Client : TSGHTTPHandler = nil;
	HttpClient : TLHTTPClient = nil;
	UseSSL : Boolean;
	Port : Word;
	Host, URI : STring;
begin
Result:=nil;

UseSSL := DecomposeURL(Way, Host, URI, Port);
if UseSSL then
	Exit;

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

while not Client.Done do
	HttpClient.CallAction;

HttpClient.Free;

if Client.Done then
	Result := Client.Stream
else
	Client.Stream.Destroy();

Client.Destroy();
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
FConnection.Destroy;
FConnection:=nil;
inherited;
end;

procedure TSGUDPConnection.OnError(const msg: string; aSocket: TLSocket);
begin
Writeln(msg);
end;

procedure TSGUDPConnection.OnReceive(aSocket: TLSocket);
var
	Stream:TMemoryStream;
	AMemory:Pointer;
	ASize:LongInt;
begin
Stream:=TMemoryStream.Create;
ASize:=BUFFER_SIZE;
GetMem(AMemory,ASize);
ASize:=aSocket.Get(AMemory^,ASize);
Stream.WriteBuffer(AMemory^,ASize);
FreeMem(AMemory,BUFFER_SIZE);
Stream.Position:=0;
if FReceiveProcedure<>nil then
	FReceiveProcedure(FParent,Stream,aSocket);
Stream.Free;
end;

end.
