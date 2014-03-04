{$INCLUDE Includes\SaGe.inc}

unit SaGeGameNet;

interface

uses
	SaGeBase
	,SaGeBased
	,SaGeModel
	,SaGeGameBase
	,SaGeNet
	;

type
	TSGNet = class(TSGMutator)
			public
		procedure UpDate();override;
			protected
		FConnectionMode : TSGConnectionMode;
			public
		property ConnectionMode : TSGConnectionMode read FConnectionMode write FConnectionMode;
		end;

implementation

procedure TSGNet.UpDate();
begin

end;

end.
