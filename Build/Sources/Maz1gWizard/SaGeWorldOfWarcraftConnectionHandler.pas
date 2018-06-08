{$INCLUDE SaGe.inc}

unit SaGeWorldOfWarcraftConnectionHandler;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeInternetConnection
	,SaGeInternetConnections
	,SaGeWorldOfWarcraftLogonStructs
	
	,Classes
	;
type
	TSGWorldOfWarcraftConnectionHandler = class(TSGNamed, ISGConnectionsHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		function HandleConnectionData(const Connection : TSGInternetConnection; const DataType : TSGConnectionDataType; const Data : TStream) : TSGBoolean;
		procedure HandleConnectionStatus(const Connection : TSGInternetConnection; const Status : TSGConnectionStatus);
			protected
		FWOWConnections : TSGInternetConnectionList;
		FConnections : TSGInternetConnections;
			public
		function AllDataSize() : TSGUInt64;
		end;

procedure SGKill(var WorldOfWarcraftConnectionHandler : TSGWorldOfWarcraftConnectionHandler); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

function TSGWorldOfWarcraftConnectionHandler.AllDataSize() : TSGUInt64;
var
	Index : TSGMaxEnum;
begin
Result := 0;
if (FWOWConnections <> nil) and (Length(FWOWConnections) > 0) then
	for Index := 0 to High(FWOWConnections) do
		Result += FWOWConnections[Index].DataSize;
end;

function TSGWorldOfWarcraftConnectionHandler.HandleConnectionData(const Connection : TSGInternetConnection; const DataType : TSGConnectionDataType; const Data : TStream) : TSGBoolean;
begin
Result := False;
if (DataType = SGSenderData) and SGIsAuthenticationLogonChallenge(Data) then
	begin // Logon to game server
	Result := True;
	if (not (Connection in FWOWConnections)) then
		FWOWConnections += Connection;
	end;
if (not Result) and (Connection in FWOWConnections) then
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
FWOWConnections := nil;
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

destructor TSGWorldOfWarcraftConnectionHandler.Destroy();
begin
SGKIll(FWOWConnections);
SGKIll(FConnections);
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
