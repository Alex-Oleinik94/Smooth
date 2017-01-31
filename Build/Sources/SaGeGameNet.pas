{$INCLUDE Includes\SaGe.inc}

unit SaGeGameNet;

interface

uses
	 SaGeBase
	,SaGeModel
	,SaGeGameBase
	,SaGeNet
	;

type
	TSGNet = class(TSGMutator)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		procedure UpDate();override;
		procedure Start();override;
			protected
		FUDPConnection : TSGUDPConnection;
		FConnectionMode : TSGConnectionMode;
			public
		property ConnectionMode : TSGConnectionMode read FConnectionMode write FConnectionMode;
		end;

implementation

constructor TSGNet.Create();
begin
inherited;
FUDPConnection:=nil;
FConnectionMode:=SGClientMode;
end;

destructor TSGNet.Destroy();
begin
if FUDPConnection<>nil then
	FUDPConnection.Destroy();
inherited;
end;

procedure TSGNet.UpDate();
begin

end;

procedure TSGNet.Start();
begin

end;

end.
