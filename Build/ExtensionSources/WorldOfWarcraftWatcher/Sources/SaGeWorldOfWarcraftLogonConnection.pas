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
		FClientALC : TSGWOW_ALC_Client;
			public
		property Connection : TSGInternetConnection read FConnection write FConnection;
		property ClientALC : TSGWOW_ALC_Client read FClientALC;
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
begin
FClientALC := SGReadAuthenticationLogonChallenge(Stream);
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
