{$INCLUDE Smooth.inc}

unit SmoothlNetConnectionClasses;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothDateTime
	,SmoothlNetBase
	,SmoothlNetUDPConnection
	
	,Classes
	,lNet
	;

type
	TSHost = object
			public
		FAddress : TSString;
		FPort : TSUInt16;
		FURL : TSString;
		FLastSend : TSDateTime;
		FLastRecieved : TSDateTime;
		FLastSendIterator : TSUInt64;
		FLastRecievedIterator : TSUInt64;
		end;
	PSHost = ^ TSHost;
	TSHostList = packed array of TSHost;
	
	TSCustomConnectionHandler = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			protected
		FHosts : TSHostList;
		FIterator : TSUInt64;
			protected
		function GetHost(const Index : TSMaxEnum) : PSHost; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		function HostsCount() : TSMaxEnum; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property Hosts[Index : TSMaxEnum]:PSHost read GetHost;
		end;
	
	TSCustomUDPConnectionHandler = class(TSCustomConnectionHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			public
		procedure Recieved(const Stream : TMemoryStream; const Socket : TLSocket);
			protected
		FConnection : TSUDPConnection;
			public
		property Connection : TSUDPConnection read FConnection;
		end;
	
	TSPacketType = TSString;
	TSDataType = TSString;
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
	SPacketTryConnect        : TSPacketType = 'TRYCONNECT';
	SPacketConnectionSuccess : TSPacketType = 'CONNECTIONSUCS';
	SPacketCheck             : TSPacketType = 'CHECK';
	SPacketCheckSuccess      : TSPacketType = 'CHECKSUCS';
	SPacketDisconnect        : TSPacketType = 'DISCONNECT';
	SPacketData              : TSPacketType = 'DATA';
type
	TSUDPServer = class(TSCustomUDPConnectionHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			protected
		FCkeckInterval : TSUInt16;
		end;
	
	TSUDPClient = class(TSCustomUDPConnectionHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
		end;

implementation

// TSUDPClient

constructor TSUDPClient.Create();
begin
inherited;
FConnection.ConnectionMode := SClientMode;
end;

destructor TSUDPClient.Destroy();
begin
inherited;
end;

class function TSUDPClient.ClassName() : TSString;
begin
Result := 'TSUDPClient';
end;

// TSUDPServer

constructor TSUDPServer.Create();
begin
inherited;
FCkeckInterval := 50;
FConnection.ConnectionMode := SServerMode;
end;

destructor TSUDPServer.Destroy();
begin
inherited;
end;

class function TSUDPServer.ClassName() : TSString;
begin
Result := 'TSUDPServer';
end;

// TSCustomUDPConnectionHandler

procedure TSCustomUDPConnectionHandler.Recieved(const Stream : TMemoryStream; const Socket : TLSocket);
begin

end;

procedure TSCustomUDPConnectionHandler_Received(Parent : TSCustomUDPConnectionHandler; AStream : TMemoryStream; aSocket : TLSocket);
begin
Parent.Recieved(AStream, aSocket);
end;

constructor TSCustomUDPConnectionHandler.Create();
begin
inherited;
FConnection := TSUDPConnection.Create();
FConnection.ReceiveProcedure := TSReceiveProcedure(@TSCustomUDPConnectionHandler_Received);
FConnection.Parent := Self;
end;

destructor TSCustomUDPConnectionHandler.Destroy();
begin
if FConnection <> nil then
	begin
	FConnection.Destroy();
	FConnection := nil;
	end;
inherited;
end;

class function TSCustomUDPConnectionHandler.ClassName() : TSString;
begin
Result := 'TSCustomUDPConnectionHandler';
end;

// TSCustomConnectionHandler

function TSCustomConnectionHandler.HostsCount() : TSMaxEnum; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := 0;
if FHosts <> nil then
	Result := Length(FHosts);
end;

function TSCustomConnectionHandler.GetHost(const Index : TSMaxEnum) : PSHost; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := nil;
if (Index >= 0) and (Index < HostsCount()) then
	Result := @FHosts[Index];
end;

constructor TSCustomConnectionHandler.Create();
begin
inherited;
FIterator := 1;
FHosts := nil;
end;

destructor TSCustomConnectionHandler.Destroy();
begin
if FHosts <> nil then
	begin
	SetLength(FHosts, 0);
	FHosts := nil;
	end;
inherited;
end;

class function TSCustomConnectionHandler.ClassName() : TSString;
begin
Result := 'TSCustomConnectionHandler';
end;

initialization
begin

end;

finalization
begin

end;

end.
