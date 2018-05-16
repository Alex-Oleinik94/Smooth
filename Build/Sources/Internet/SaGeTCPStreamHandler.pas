{$INCLUDE SaGe.inc}

unit SaGeTCPStreamHandler;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeInternetBase
	,SaGeInternetPacketDeterminer
	,SaGeCriticalSection
	,SaGeTCPConnectionHandler
	
	,Classes
	;

type
	TSGTCPStreamHandler = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FPacketDeterminer : TSGInternetPacketDeterminer;
		FCritacalSection : TSGCriticalSection;
		FPacketHandler : TSGTCPConnectionHandler;
			protected
		procedure HandlePacket();
			public
		procedure HandleData(const Stream : TStream); virtual;
		function HasData() : TSGBoolean; virtual;
		function CountData() : TSGMaxEnum; virtual;
		end;

implementation

procedure TSGTCPStreamHandler.HandlePacket();
begin
FCritacalSection.Enter();

FCritacalSection.Leave();
end;

constructor TSGTCPStreamHandler.Create();
begin
inherited;
FCritacalSection := TSGCriticalSection.Create();
end;

destructor TSGTCPStreamHandler.Destroy();
begin
if FCritacalSection <> nil then
	begin
	FCritacalSection.Destroy();
	FCritacalSection := nil;
	end;
inherited;
end;

procedure TSGTCPStreamHandler.HandleData(const Stream : TStream);
begin
end;

function TSGTCPStreamHandler.HasData() : TSGBoolean;
begin
Result := False;
end;

function TSGTCPStreamHandler.CountData() : TSGMaxEnum;
begin
Result := 0;
end;

end.
