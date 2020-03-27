{$INCLUDE Smooth.inc}

unit SmoothWorldOfWarcraftConnectionHandler;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothInternetConnection
	,SmoothInternetConnectionsCaptor
	,SmoothWorldOfWarcraftLogonStructs
	,SmoothWorldOfWarcraftLogonConnection
	
	,Classes
	;
type
	ISWorldOfWarcraftConnectionHandlerCallBacks = interface(ISInterface)
		['{69818e8c-7d88-4b20-ac1b-bd86e37df5e2}']
		procedure LogonConnectionCallBack(const LogonConnection : TSWOWLogonConnection);
		end;
	
	TSWorldOfWarcraftConnectionHandler = class(TSNamed, ISConnectionsHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		function HandleConnectionData(const Connection : TSInternetConnection; const DataType : TSConnectionDataType; const Data : TStream) : TSBoolean;
		procedure HandleConnectionStatus(const Connection : TSInternetConnection; const Status : TSConnectionStatus);
			protected
		FLogonConnections : TSWOWLogonConnectionList;
		FConnectionsCaptor : TSInternetConnectionsCaptor;
		FCallBacks : ISWorldOfWarcraftConnectionHandlerCallBacks;
			protected
		function LogonConnectionExists(const Connection : TSInternetConnection) : TSBoolean;
		procedure KillLogonConnections();
		procedure CreateNewLogonConnection(const Connection : TSInternetConnection; const DataType : TSConnectionDataType; const Data : TStream);
		function GetLogonConnectionsNumber() : TSMaxEnum;
		function FindLogonConnection(const Connection : TSInternetConnection) : TSWOWLogonConnection;
			public
		function AllDataSize() : TSUInt64;
		property CallBacks : ISWorldOfWarcraftConnectionHandlerCallBacks read FCallBacks write FCallBacks;
		property LogonConnections : TSWOWLogonConnectionList read FLogonConnections;
		property LogonConnectionsNumber : TSMaxEnum read GetLogonConnectionsNumber;
		end;

procedure SKill(var WorldOfWarcraftConnectionHandler : TSWorldOfWarcraftConnectionHandler); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

function TSWorldOfWarcraftConnectionHandler.GetLogonConnectionsNumber() : TSMaxEnum;
begin
if (FLogonConnections = nil) then
	Result := 0
else
	Result := Length(FLogonConnections);
end;

function TSWorldOfWarcraftConnectionHandler.LogonConnectionExists(const Connection : TSInternetConnection) : TSBoolean;
var
	Index : TSMaxEnum;
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

function TSWorldOfWarcraftConnectionHandler.AllDataSize() : TSUInt64;
var
	Index : TSMaxEnum;
begin
Result := 0;
if (FLogonConnections <> nil) and (Length(FLogonConnections) > 0) then
	for Index := 0 to High(FLogonConnections) do
		Result += FLogonConnections[Index].Connection.DataSize;
end;

procedure TSWorldOfWarcraftConnectionHandler.CreateNewLogonConnection(const Connection : TSInternetConnection; const DataType : TSConnectionDataType; const Data : TStream);
var
	LogonConnection : TSWOWLogonConnection = nil;
begin
LogonConnection := TSWOWLogonConnection.Create();
LogonConnection.Connection := Connection;
LogonConnection.ReadClientALC(Data);
FLogonConnections += LogonConnection;
if (FCallBacks <> nil) then
	FCallBacks.LogonConnectionCallBack(LogonConnection);
end;

function TSWorldOfWarcraftConnectionHandler.FindLogonConnection(const Connection : TSInternetConnection) : TSWOWLogonConnection;
var
	Index : TSMaxEnum;
begin
Result := nil;
if (FLogonConnections <> nil) and (Length(FLogonConnections) > 0) then
	for Index := 0 to High(FLogonConnections) do
		if FLogonConnections[Index].Connection = Connection then
			begin
			Result := FLogonConnections[Index];
			break;
			end;
end;

function TSWorldOfWarcraftConnectionHandler.HandleConnectionData(const Connection : TSInternetConnection; const DataType : TSConnectionDataType; const Data : TStream) : TSBoolean;
begin
Result := False;
if (DataType = SSenderData) and SIsAuthenticationLogonChallenge(Data) and (not LogonConnectionExists(Connection)) then
	begin
	CreateNewLogonConnection(Connection, DataType, Data);
	Result := True;
	end
else if (LogonConnectionExists(Connection)) then
	begin
	FindLogonConnection(Connection).HandleData(DataType, Data);
	Result := True;
	end;
end;

procedure TSWorldOfWarcraftConnectionHandler.HandleConnectionStatus(const Connection : TSInternetConnection; const Status : TSConnectionStatus);
begin
if (Status = SStartStatus) then
	begin
	
	end;
end;

constructor TSWorldOfWarcraftConnectionHandler.Create();
begin
inherited;
FCallBacks := nil;
FLogonConnections := nil;
FConnectionsCaptor := TSInternetConnectionsCaptor.Create();
FConnectionsCaptor.PossibilityBreakLoopFromConsole := False;
FConnectionsCaptor.ProcessTimeOutUpdates := False;
FConnectionsCaptor.ModeDataTransfer := True;
FConnectionsCaptor.ModePacketStorage := False;
FConnectionsCaptor.ModeRuntimeDataDumper := False;
FConnectionsCaptor.ModeRuntimePacketDumper := False;
FConnectionsCaptor.ConnectionsHandler := Self;
FConnectionsCaptor.Start();
end;

procedure TSWorldOfWarcraftConnectionHandler.KillLogonConnections();
var
	Index : TSMaxEnum;
begin
if (FLogonConnections <> nil) and (Length(FLogonConnections) > 0) then
	for Index := 0 to High(FLogonConnections) do
		FLogonConnections[Index].Destroy();
SKill(FLogonConnections);
end;

destructor TSWorldOfWarcraftConnectionHandler.Destroy();
begin
KillLogonConnections();
SKill(FConnectionsCaptor);
inherited;
end;

procedure SKill(var WorldOfWarcraftConnectionHandler : TSWorldOfWarcraftConnectionHandler);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if WorldOfWarcraftConnectionHandler <> nil then
	begin
	WorldOfWarcraftConnectionHandler.Destroy();
	WorldOfWarcraftConnectionHandler := nil;
	end;
end;

end.
