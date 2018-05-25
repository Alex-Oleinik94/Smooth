{$INCLUDE SaGe.inc}

unit SaGeInternetConnections;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeInternetPacketCaptureHandler
	,SaGeInternetConnection
	
	,Classes
	;

type
	TSGInternetConnections = class(TSGInternetPacketCaptureHandler)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FConnections : TSGInternetConnectionList;
		
		end;

procedure SGRegisterInternetConnectionClass(const ClassVariable : TSGInternetConnectionClass);

implementation

uses
	 SaGeInternetConnectionTCP
	;

var
	ConnectionClasses : TSGInternetConnectionClassList = nil;

procedure SGRegisterInternetConnectionClass(const ClassVariable : TSGInternetConnectionClass);
var
	Index : TSGMaxEnum;
	Add : TSGBoolean;
begin
Add := False;
if (ConnectionClasses = nil) or (Length(ConnectionClasses) = 0) then
	Add := True
else
	begin
	Add := True;
	for Index := 0 to High(ConnectionClasses) do
		if ConnectionClasses[Index] = ClassVariable then
			begin
			Add := False;
			break;
			end;
	end;
if Add then
	ConnectionClasses += ClassVariable;
end;

constructor TSGInternetConnections.Create();
begin
inherited;
FConnections := nil;
end;

destructor TSGInternetConnections.Destroy();
begin
SGKill(FConnections);
inherited;
end;

end.
