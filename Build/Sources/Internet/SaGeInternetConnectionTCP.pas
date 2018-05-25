{$INCLUDE SaGe.inc}

unit SaGeInternetConnectionTCP;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeInternetBase
	,SaGeInternetPacketDeterminer
	,SaGeCriticalSection
	,SaGeInternetConnection
	
	,Classes
	;

type
	TSGInternetConnectionTCP = class(TSGInternetConnection)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FPacketDeterminer : TSGInternetPacketDeterminer;
		FCritacalSection : TSGCriticalSection;
			protected
		procedure HandlePacket();
			public
		procedure HandleData(const Stream : TStream); virtual;
		function HasData() : TSGBoolean; virtual;
		function CountData() : TSGMaxEnum; virtual;
		end;

implementation

uses
	 SaGeInternetConnections
	;

procedure TSGInternetConnectionTCP.HandlePacket();
begin
FCritacalSection.Enter();

FCritacalSection.Leave();
end;

constructor TSGInternetConnectionTCP.Create();
begin
inherited;
FCritacalSection := TSGCriticalSection.Create();
end;

destructor TSGInternetConnectionTCP.Destroy();
begin
SGKill(FCritacalSection);
inherited;
end;

procedure TSGInternetConnectionTCP.HandleData(const Stream : TStream);
begin
end;

function TSGInternetConnectionTCP.HasData() : TSGBoolean;
begin
Result := False;
end;

function TSGInternetConnectionTCP.CountData() : TSGMaxEnum;
begin
Result := 0;
end;

initialization
begin
SGRegisterInternetConnectionClass(TSGInternetConnectionTCP);
end;

end.
