{$INCLUDE SaGe.inc}

unit SaGeWorldOfWarcraftConnectionHandler;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeInternetConnection
	,SaGeInternetConnections
	,SaGeWorldOfWarcraftLogonStructs
	,SaGeWorldOfWarcraftLogonConnection
	
	,Classes
	;
type
	ISGWorldOfWarcraftConnectionHandlerCallBacks = interface(ISGInterface)
		['{69818e8c-7d88-4b20-ac1b-bd86e37df5e2}']
		procedure LogonConnectionCallBack(const LogonConnection : TSGWOWLogonConnection);
		end;
	
	TSGWorldOfWarcraftConnectionHandler = class(TSGNamed, ISGConnectionsHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		function HandleConnectionData(const Connection : TSGInternetConnection; const DataType : TSGConnectionDataType; const Data : TStream) : TSGBoolean;
		procedure HandleConnectionStatus(const Connection : TSGInternetConnection; const Status : TSGConnectionStatus);
			protected
		FLogonConnections : TSGWOWLogonConnectionList;
		FConnections : TSGInternetConnections;
		FCallBacks : ISGWorldOfWarcraftConnectionHandlerCallBacks;
			protected
		function LogonConnectionExists(const Connection : TSGInternetConnection) : TSGBoolean;
		procedure KillLogonConnections();
		procedure CreateNewLogonConnection(const Connection : TSGInternetConnection; const DataType : TSGConnectionDataType; const Data : TStream);
			public
		function AllDataSize() : TSGUInt64;
		property CallBacks : ISGWorldOfWarcraftConnectionHandlerCallBacks read FCallBacks write FCallBacks;
		end;

procedure SGKill(var WorldOfWarcraftConnectionHandler : TSGWorldOfWarcraftConnectionHandler); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

function TSGWorldOfWarcraftConnectionHandler.LogonConnectionExists(const Connection : TSGInternetConnection) : TSGBoolean;
var
	Index : TSGMaxEnum;
begin
Result := False;
if (FLogonConnections <> nil) and (Length(FLogonConnections) > 0) then
	for Index := 0 to High(FLogonConnections) do
		if FLogonConnections[Index].Connection = Connection then
			begin
			Result := True;
			break;
			end;
end;

function TSGWorldOfWarcraftConnectionHandler.AllDataSize() : TSGUInt64;
var
	Index : TSGMaxEnum;
begin
Result := 0;
if (FLogonConnections <> nil) and (Length(FLogonConnections) > 0) then
	for Index := 0 to High(FLogonConnections) do
		Result += FLogonConnections[Index].Connection.DataSize;
end;

procedure TSGWorldOfWarcraftConnectionHandler.CreateNewLogonConnection(const Connection : TSGInternetConnection; const DataType : TSGConnectionDataType; const Data : TStream);
var
	LogonConnection : TSGWOWLogonConnection = nil;
begin
LogonConnection := TSGWOWLogonConnection.Create();
LogonConnection.Connection := Connection;
LogonConnection.ReadClientALC(Data);
FLogonConnections += LogonConnection;
if (FCallBacks <> nil) then
	FCallBacks.LogonConnectionCallBack(LogonConnection);
end;

function TSGWorldOfWarcraftConnectionHandler.HandleConnectionData(const Connection : TSGInternetConnection; const DataType : TSGConnectionDataType; const Data : TStream) : TSGBoolean;
begin
Result := False;
if (DataType = SGSenderData) and SGIsAuthenticationLogonChallenge(Data) and (not LogonConnectionExists(Connection)) then
	CreateNewLogonConnection(Connection, DataType, Data);
if (not Result) and LogonConnectionExists(Connection) then
	Result := True;
end;

procedure TSGWorldOfWarcraftConnectionHandler.HandleConnectionStatus(const Connection : TSGInternetConnection; const Status : TSGConnectionStatus);
begin
if (Status = SGStartStatus) then
	begin
	
	end;
end;

constructor TSGWorldOfWarcraftConnectionHandler.Create();
begin
inherited;
FCallBacks := nil;
FLogonConnections := nil;
FConnections := TSGInternetConnections.Create();
FConnections.PossibilityBreakLoopFromConsole := False;
FConnections.ProcessTimeOutUpdates := False;
FConnections.ModeDataTransfer := True;
FConnections.ModePacketStorage := False;
FConnections.ModeRuntimeDataDumper := False;
FConnections.ModeRuntimePacketDumper := False;
FConnections.ConnectionsHandler := Self;
FConnections.Start();
end;

procedure TSGWorldOfWarcraftConnectionHandler.KillLogonConnections();
var
	Index : TSGMaxEnum;
begin
if (FLogonConnections <> nil) and (Length(FLogonConnections) > 0) then
	for Index := 0 to High(FLogonConnections) do
		FLogonConnections[Index].Destroy();
SGKill(FLogonConnections);
end;

destructor TSGWorldOfWarcraftConnectionHandler.Destroy();
begin
KillLogonConnections();
SGKill(FConnections);
inherited;
end;

procedure SGKill(var WorldOfWarcraftConnectionHandler : TSGWorldOfWarcraftConnectionHandler);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if WorldOfWarcraftConnectionHandler <> nil then
	begin
	WorldOfWarcraftConnectionHandler.Destroy();
	WorldOfWarcraftConnectionHandler := nil;
	end;
end;

end.
