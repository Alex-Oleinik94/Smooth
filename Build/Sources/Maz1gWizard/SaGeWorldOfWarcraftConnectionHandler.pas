{$INCLUDE SaGe.inc}

unit SaGeWorldOfWarcraftConnectionHandler;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeInternetConnection
	,SaGeInternetConnections
	
	,Classes
	;
type
	TSGWorldOfWarcraftConnectionHandler = class(TSGNamed, ISGConnectionsHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		function HandleConnectionData(const Connection : TSGInternetConnection; const DataType : TSGConnectionDataType; const Data : TStream) : TSGBoolean;
			protected
		FConnections : TSGInternetConnections;
		end;

procedure SGKill(var WorldOfWarcraftConnectionHandler : TSGWorldOfWarcraftConnectionHandler); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

function TSGWorldOfWarcraftConnectionHandler.HandleConnectionData(const Connection : TSGInternetConnection; const DataType : TSGConnectionDataType; const Data : TStream) : TSGBoolean;
begin

end;

constructor TSGWorldOfWarcraftConnectionHandler.Create();
begin
inherited;
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
