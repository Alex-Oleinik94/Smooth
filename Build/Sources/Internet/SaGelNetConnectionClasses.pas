{$INCLUDE SaGe.inc}

unit SaGelNetConnectionClasses;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeDateTime
	,SaGelNetBase
	,SaGelNetUDPConnection
	
	,Classes
	,lNet
	;

type
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

implementation

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

initialization
begin

end;

finalization
begin

end;

end.
