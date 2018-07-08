{$INCLUDE SaGe.inc}

unit SaGeWorldOfWarcraftLogonConnection;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	,SaGeInternetConnection
	,SaGeWorldOfWarcraftLogonStructs
	
	,Classes
	;

type
	TSGWOWLogonConnection = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		procedure ReadClientALC(const Stream : TStream);
			protected
		FConnection : TSGInternetConnection;
		FClientALC_Sets : TSGBoolean;
		FClientALC : TSGWOW_ALC_Client_Full;
			public
		property Connection : TSGInternetConnection read FConnection write FConnection;
		property ClientALC : TSGWOW_ALC_Client_Full read FClientALC;
		end;

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSGWOWLogonConnectionListHelper}
{$DEFINE DATATYPE_LIST        := TSGWOWLogonConnectionList}
{$DEFINE DATATYPE             := TSGWOWLogonConnection}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

implementation

procedure TSGWOWLogonConnection.ReadClientALC(const Stream : TStream);

function ReadString(const StringLength : TSGMaxEnum) : TSGString;
var
	Index : TSGMaxEnum;
	C : TSGChar;
begin
Result := '';
for Index := 1 to StringLength do
	begin
	Stream.Read(C, 1);
	Result += C;
	end;
end;

begin
Stream.Position := 0;
Stream.Read(FClientALC, SizeOf(TSGWOW_ALC_Client));
FClientALC.SRP_I := ReadString(FClientALC.SRP_I_length);
FClientALC_Sets := True;
end;

constructor TSGWOWLogonConnection.Create();
begin
inherited;
FillChar(FClientALC, SizeOf(FClientALC), 0);
FConnection := nil;
FClientALC_Sets := False;
end;

destructor TSGWOWLogonConnection.Destroy();
begin
inherited;
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSGWOWLogonConnectionListHelper}
{$DEFINE DATATYPE_LIST        := TSGWOWLogonConnectionList}
{$DEFINE DATATYPE             := TSGWOWLogonConnection}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
