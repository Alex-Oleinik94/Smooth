{$INCLUDE Smooth.inc}

unit SmoothlNetUDPConnection;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothCasesOfPrint
	,SmoothlNetBase
	
	,Classes
	,lNet
	;

type
	TSUDPConnectionClass = class(TLUDP)
		function SendMemoryStream(const AStream:TMemoryStream):Integer;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		end;
	
	TSReceiveProcedure       = procedure(Parent : TSPointer; AStream : TMemoryStream; aSocket : TLSocket);
	TSNestedReceiveProcedure = procedure(Parent : TSPointer; AStream : TMemoryStream; aSocket : TLSocket) is nested;
	
	TSUDPConnection = class(TSNamed)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSString; override;
			protected
		FViewErrorCase : TSCasesOfPrint;
		FConnection : TSUDPConnectionClass;
		FReceiveProcedure : TSReceiveProcedure;
		FNestedReceiveProcedure : TSNestedReceiveProcedure;
		FParent : TSPointer;
		FAddress : TSString;
		FPort : TSUInt16;
		FConnectionMode : TSConnectionMode;
		FConnectionResult : TSBool;
			protected
		procedure OnError(const Msg: TSString; aSocket: TLSocket);
		procedure OnReceive(aSocket: TLSocket);
		function Listen() : TSBool;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function Connect() : TSBool;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
			public
		function Start() : TSBool;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		procedure CallAction();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function SendMemoryStream(const AStream:TMemoryStream):Integer;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
			public
		property ReceiveProcedure:TSReceiveProcedure read FReceiveProcedure write FReceiveProcedure;
		property NestedReceiveProcedure:TSNestedReceiveProcedure read FNestedReceiveProcedure write FNestedReceiveProcedure;
		property Parent:Pointer read FParent write FParent;
		property ConnectionMode:TSConnectionMode read FConnectionMode write FConnectionMode;
		property Port : TSUInt16 read FPort write FPort;
		property Host : TSString read FAddress write FAddress;
		property Address : TSString read FAddress write FAddress;
		property Ready : TSBoolean read FConnectionResult;
		end;

procedure SConsoleUDPConnection(const IsServer : TSBool; const URL : TSString; const ServerPort : TSUInt16 = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SConsoleUDPServer(const Port : TSUInt16);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SConsoleUDPClient(const URL : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothStringUtils
	,SmoothStreamUtils
	,SmoothLog
	,SmoothVersion
	,SmoothlNetURIParser
	,SmoothConsoleUtils
	
	,Crt
	,SysUtils
	,lCommon
	;

procedure SConsoleUDPClient(const URL : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SConsoleUDPConnection(False, URL);
end;

procedure SConsoleUDPServer(const Port : TSUInt16);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SConsoleUDPConnection(True, '', Port);
end;

procedure SConsoleUDPConnection(const IsServer : TSBool; const URL : TSString; const ServerPort : TSUInt16 = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function ConnectionType() : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if IsServer then
	Result := 'Server'
else
	Result := 'Client';
end;

function ConnectionParam() : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if IsServer then
	Result := SStr(ServerPort)
else
	Result := URL;
end;

procedure SetConnectionURL(const Connection : TSUDPConnection; const URL : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Port : TSUInt16;
	Host, URI : TSString;
begin
SDecomposeURL(URL, Host, URI, Port);
SHint(['UDP Connection<', ConnectionType, '>(', ConnectionParam, '): Host="',Host,'", URI="',URI,'", Port="',Port,'"']);
Connection.Address := Host + URI;
Connection.Port := Port;
end;

procedure OnReceive(Parent : TSPointer; AStream : TMemoryStream; aSocket : TLSocket);
begin
Write('Received:"');
SWriteStream(AStream);
WriteLn('" PeerAddress: "', aSocket.PeerAddress, '", PeerPort: "', aSocket.PeerPort, '".');
end;

var
	Connection : TSUDPConnection = nil;
	RK : TSChar = #0;
begin
SPrintEngineVersion();
Connection := TSUDPConnection.Create();
if IsServer then
	begin
	Connection.ConnectionMode := SServerMode;
	Connection.Port := ServerPort;
	end
else
	begin
	Connection.ConnectionMode := SClientMode;
	SetConnectionURL(Connection, URL);
	end;
Connection.NestedReceiveProcedure := @OnReceive;
Connection.Start();
SHint(['UDP Connection<', ConnectionType, '>(', ConnectionParam, '): Ready=', Connection.Ready]);
while Connection.Ready do
	begin
	if KeyPressed then
		begin
		RK := ReadKey;
		WriteLn('Send:"',RK,'".');
		Connection.SendMemoryStream(SStringToStream(RK));
		end;
	Connection.CallAction();
	Sleep(2);
	end;
Connection.Destroy();
end;

//===================================
//=========TSUDPConnection==========
//===================================

class function TSUDPConnection.ClassName() : TSString;
begin
Result := 'TSUDPConnection';
end;

function TSUDPConnection.SendMemoryStream(const AStream:TMemoryStream):Integer;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := FConnection.SendMemoryStream(AStream);
end;

function TSUDPConnection.Listen() : TSBool;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := FConnection.Listen(FPort);
FConnectionResult := Result;
end;

procedure TSUDPConnection.CallAction();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
FConnection.CallAction();
end;

function TSUDPConnection.Start() : TSBool;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
case FConnectionMode of
SClientMode : Result := Connect();
SServerMode : Result := Listen();
end;
FConnectionResult := Result;
end;

function TSUDPConnection.Connect() : TSBool;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := FConnection.Connect(FAddress, FPort);
FConnectionResult := Result;
end;

function TSUDPConnectionClass.SendMemoryStream(const AStream : TMemoryStream):Integer;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := Send(AStream.Memory^, AStream.Size);
end;

constructor TSUDPConnection.Create();
begin
inherited;
FNestedReceiveProcedure := nil;
FReceiveProcedure := nil;
FViewErrorCase := [SCasePrint, SCaseLog];
FConnection := TSUDPConnectionClass.Create(nil);
FConnection.OnError := TLSocketErrorEvent(@OnError);
FConnection.OnReceive := @OnReceive;
FConnection.Timeout := 100; 
FParent := nil;
FAddress := 'localhost';
FPort := 5233;
FConnectionMode := SClientMode;
FConnectionResult := False;
end;

destructor TSUDPConnection.Destroy();
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

procedure TSUDPConnection.OnError(const msg: string; aSocket: TLSocket);
begin
SHint('TSUDPConnection: Error: "' + Msg + '"; Socket: '+SAddrStr(aSocket) +'.', FViewErrorCase);
FConnectionResult := False;
end;

procedure TSUDPConnection.OnReceive(aSocket: TLSocket);
var
	Stream : TMemoryStream;
	AMemory : TSPointer;
	ASize : TSInt32;
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

end.
