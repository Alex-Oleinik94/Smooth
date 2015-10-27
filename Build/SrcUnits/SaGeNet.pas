{$I Includes\SaGe.inc}

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
	
	,lCommon
	,lhttp
	,lnetSSL
	,lNet
	,URIParser
	,lHTTPUtil
	;
const 
	SGGetDynamicIPAdres = 'for-alexander-oleynikov.net46.net';
	SGSetDynamicIPAdres = SGGetDynamicIPAdres + '/?data=';
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
		Done, Error : Boolean;
		Stream : TMemoryStream;
			public
		procedure ClientDisconnect(ASocket: TLSocket);
		procedure ClientDoneInput(ASocket: TLHTTPClientSocket);
		procedure ClientError(const Msg: string; aSocket: TLSocket);
		function ClientInput(ASocket: TLHTTPClientSocket; ABuffer: pchar; ASize: Integer): Integer;
		procedure ClientProcessHeaders(ASocket: TLHTTPClientSocket);
		end;

function SGGetFromHTTP(const Way : String; const Timeout : LongWord = 200):TMemoryStream;
function SGGetDynamicIPFromStaticServer(const StaticServerIP : String = SGGetDynamicIPAdres):String;
function SGSetDynamicIPToStaticServer(const DynamicIP:String;const StaticServerIP : String = SGSetDynamicIPAdres):Boolean;
procedure FindMyIp();
procedure IPSERVER();
procedure SGAttachToMyRemoteDesktop();

implementation

function SGSetDynamicIPToStaticServer(const DynamicIP:String;const StaticServerIP : String = SGSetDynamicIPAdres):Boolean;
var
	a : TProcess;
	s : TStringList;
	i : LongWord;
begin
a := TProcess.Create(nil);
a.Executable := 'curl';
a.Parameters.Add('-s');
a.Parameters.Add(StaticServerIP+DynamicIP);
a.Options := a.Options + [poUsePipes];
a.Execute;
a.WaitOnExit();
Result:= False;
if (a.ExitStatus = 0) then
	begin
	s := TStringList.Create;
	s.LoadFromStream(a.Output);
	if (S.Count = 1) then
		if (S[0] = 'success') then
			Result := True;
	s.Free;
	end;
a.Free; 
end;

function SGGetDynamicIPFromStaticServer(const StaticServerIP : String = SGGetDynamicIPAdres):String;
var
	a : TProcess;
	s : TStringList;
	i : LongWord;
begin
a := TProcess.Create(nil);
a.Executable := 'curl';
a.Parameters.Add('-s');
a.Parameters.Add(StaticServerIP);
a.Options := a.Options + [poUsePipes];
a.Execute;
a.WaitOnExit();
if (a.ExitStatus = 0) then
	begin
	s := TStringList.Create;
	Result:= '';
	s.LoadFromStream(a.Output);
	for i := 0 to s.Count-1 do
		begin
		if Result <> '' then
			Result += SGWinEoln;
		Result += s[i];
		end;
	s.Free;
	end
else
	Result := 'error';
a.Free; 
end;

procedure TSGHTTPHandler.ClientProcessHeaders(ASocket: TLHTTPClientSocket);
begin
    SGLog.Sourse(['in TSGHTTPHandler.ClientProcessHeaders : "'+'Response: ', HTTPStatusCodes[ASocket.ResponseStatus], ' ', 
    ASocket.ResponseReason, ', data...'+'"']);
end;

procedure TSGHTTPHandler.ClientError(const Msg: string; aSocket: TLSocket);
begin
  {writeln('Error: ', Msg);}
  SGLog.Sourse('in TSGHTTPHandler.ClientError : "'+Msg+'"');
  Error := True;
end;

procedure TSGHTTPHandler.ClientDisconnect(ASocket: TLSocket);
begin
  {writeln('Disconnected.');}
  done := true;
  SGLog.Sourse('in TSGHTTPHandler.ClientDisconnect');
end;
  
procedure TSGHTTPHandler.ClientDoneInput(ASocket: TLHTTPClientSocket);
begin
  //writeln('done.');
  //close(OutputFile);
  Stream.Position := 0;
  ASocket.Disconnect;
  SGLog.Sourse('in TSGHTTPHandler.ClientDoneInput');
end;

function TSGHTTPHandler.ClientInput(ASocket: TLHTTPClientSocket;
  ABuffer: pchar; ASize: Integer): Integer;
begin
  {blockwrite(outputfile, ABuffer^, ASize, Result);
  write(IntToStr(ASize) + '...');}
  Stream.WriteBuffer(ABuffer^,ASize);
  Result := ASize;
  SGLog.Sourse('in TSGHTTPHandler.ClientInput');
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
Client.Error := false;

SGLog.Sourse('Begin circle');
while (not Client.Done) and (not Client.Error) do
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

// IP SERVER

procedure FindMyIp();
function FindIp(var S:String):Boolean;
var
	i,ii : LongWord;
	filename, line : string;
	f : TextFile;
begin
Result := False;
ii := 0;
for i := 1 to Length(S) do
	begin
	if S[i] = '"' then
		ii+=1;
	end;
if ii = 4 then
	begin
	ii := 0;
	line := '';
	filename := '';
	for i := 1 to Length(S) do
		begin
		if S[i] = '"' then
			ii+=1;
		case ii of
		1 : if S[i] <> '"' then
			filename += S[i];
		3 : if S[i] <> '"' then
			line += S[i];
		end;
		end;
	assign(f,filename);
	reset(f);
	for i := 1 to SGVal(line) do
		ReadLn(f,s);
	close(f);
	ii := 0;
	line := '';
	for i := 1 to Length(S) do
		begin
		if S[i] = '''' then
			ii+=1;
		if (ii = 1) and (S[i] <> '''') then
			line +=S[i];
		end;
	S := line;
	Result := True;
	end;
end;
var
	f : TextFile;
	s : String;
	to_ext : Boolean = False;
	AProcess: TProcess;
	DatTime : TSGDateTime;
begin
Assign(f,'l_i.txt');
Reset(f);
while (not seekeof(f)) and (not to_ext) do
	begin
	ReadLn(f,S);
	to_ext := FindIp(S);
	end;
close(f);
if (to_ext) then
	begin
	DatTime.Get();
	WriteLn('[',DatTime.Years,'.',DatTime.Month,'.',DatTime.Day,' ',DatTime.Hours,':',DatTime.Minutes,':',DatTime.Seconds,'] Your ip is "',S,'".');
	SGSetDynamicIPToStaticServer(S);
	end;
end;

procedure IPSERVER();
function  RunCmd():Boolean;
begin
Result := False;

if (SGFileExists('myip.html')) then DeleteFile('myip.html');
SGRunComand('curl -s "2ip.ru" -o "myip.html"',[poWaitOnExit,poUsePipes]);

if (SGFileExists('Find In Pas Results\Results of 1 matches.txt')) then DeleteFile('Find In Pas Results\Results of 1 matches.txt');
if (SGExistsDirectory('Find In Pas Results')) then RemoveDir('Find In Pas Results');
if (SGFileExists('myip.html')) then SGRunComand('main -FIP -WORDclip.settext -START',[poWaitOnExit,poUsePipes],True);

if (SGFileExists('l_i.txt')) then DeleteFile('l_i.txt');
if (SGFileExists('Find In Pas Results\Results of 1 matches.txt')) then RenameFile('Find In Pas Results\Results of 1 matches.txt','l_i.txt');
if (SGFileExists('Find In Pas Results\Results of 1 matches.txt')) then DeleteFile('Find In Pas Results\Results of 1 matches.txt');
if (SGExistsDirectory('Find In Pas Results')) then RemoveDir('Find In Pas Results');
if (SGFileExists('myip.html')and SGFileExists('l_i.txt')) then FindMyIp();

if (SGFileExists('myip.html')) then DeleteFile('myip.html');
if (SGFileExists('l_i.txt')) then DeleteFile('l_i.txt');
end;
var
	to_ext : Boolean = False;
begin
ClrScr();
WriteLn('SaGe IP Server is running....');
while not to_ext do
	begin
	RunCmd();
	sysutils.sleep(100000);
	end;
end;

procedure SGAttachToMyRemoteDesktop();
var
	IP : String;
begin
IP := SGGetDynamicIPFromStaticServer();
if (IP <> 'error') then
	SGRunComand('mstsc "/v:'+IP+':4000"')
else
	Writeln('Somethink error..');
end;

end.
