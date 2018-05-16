{$INCLUDE SaGe.inc}

unit SaGeTCPConnectionHandler;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeInternetPacketCaptureHandler
	
	,Classes
	;

type
	TSGTCPConnectionHandler = class(TSGInternetPacketCaptureHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		
		end;

implementation

constructor TSGTCPConnectionHandler.Create();
begin
inherited;

end;

destructor TSGTCPConnectionHandler.Destroy();
begin

inherited;
end;

end.
