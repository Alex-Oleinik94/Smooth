{$I Includes\SaGe.inc}

unit SaGeNet;

interface

uses
	crt
	,SaGeBase
	,SaGe
	,lNet
	,lCommon
	,SysUtils
	,Classes
	;

type
	TSGSocket = TLSocket;
	TSGUDPConnectionClass=class(TLUDP)
		function SendMemoryStream(const AStream:TMemoryStream):Integer;inline;
		end;
	
	TSGReceiveProcedure=procedure(Parant:Pointer;AStream:TMemoryStream; aSocket: TSGSocket);
	
	TSGConnectionMode = (TSGServerMode,TSGClientMode);
	
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
	

implementation

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
TSGClientMode:Connect;
TSGServerMode:Listen;
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
FConnectionMode:=TSGClientMode;
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
