{$INCLUDE SaGe.inc}

unit SaGelNetUDPConnection;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	,SaGeCasesOfPrint
	,SaGelNetBase
	
	,Classes
	,lNet
	;

type
	TSGUDPConnectionClass = class(TLUDP)
		function SendMemoryStream(const AStream:TMemoryStream):Integer;{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		end;
	
	TSGReceiveProcedure       = procedure(Parent : TSGPointer; AStream : TMemoryStream; aSocket : TLSocket);
	TSGNestedReceiveProcedure = procedure(Parent : TSGPointer; AStream : TMemoryStream; aSocket : TLSocket) is nested;
	
	TSGUDPConnection = class(TSGNamed)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
			protected
		FViewErrorCase : TSGCasesOfPrint;
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

procedure SGConsoleUDPConnection(const IsServer : TSGBool; const URL : TSGString; const ServerPort : TSGUInt16 = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGConsoleUDPServer(const Port : TSGUInt16);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGConsoleUDPClient(const URL : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeStringUtils
	,SaGeStreamUtils
	,SaGeLog
	,SaGeVersion
	,SaGelNetURIParser
	,SaGeConsoleUtils
	
	,Crt
	,SysUtils
	,lCommon
	;

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

//===================================
//=========TSGUDPConnection==========
//===================================

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
FViewErrorCase := [SGCasePrint, SGCaseLog];
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

end.
