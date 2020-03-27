{$INCLUDE Smooth.inc}

unit SmoothGameNet;

interface

uses
	 SmoothBase
	,SmoothModel
	,SmoothGameBase
	,SmoothlNetBase
	,SmoothlNetUDPConnection
	;

type
	TSNet = class(TSMutator)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		procedure UpDate();override;
		procedure Start();override;
			protected
		FUDPConnection : TSUDPConnection;
		FConnectionMode : TSConnectionMode;
			public
		property ConnectionMode : TSConnectionMode read FConnectionMode write FConnectionMode;
		end;

implementation

constructor TSNet.Create();
begin
inherited;
FUDPConnection:=nil;
FConnectionMode:=SClientMode;
end;

destructor TSNet.Destroy();
begin
if FUDPConnection<>nil then
	FUDPConnection.Destroy();
inherited;
end;

procedure TSNet.UpDate();
begin

end;

procedure TSNet.Start();
begin

end;

end.
