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
		procedure ReadClientALC(const Stream : TStream); virtual;
		procedure HandleData(const DataType : TSGConnectionDataType; const Data : TStream); virtual;
			protected
		FConnection : TSGInternetConnection;
		FClientALC_Sets : TSGBoolean;
		FServerALC_Sets : TSGBoolean;
		FClientALC : TSGWOW_ALC_Client;
		FServerALC : TSGWOW_ALC_Server;
			public
		property Connection : TSGInternetConnection read FConnection write FConnection;
		property ClientALC : TSGWOW_ALC_Client read FClientALC;
		property ClientALC_Sets : TSGBoolean read FClientALC_Sets;
		property ServerALC : TSGWOW_ALC_Server read FServerALC;
		property ServerALC_Sets : TSGBoolean read FServerALC_Sets;
		end;

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSGWOWLogonConnectionListHelper}
{$DEFINE DATATYPE_LIST        := TSGWOWLogonConnectionList}
{$DEFINE DATATYPE             := TSGWOWLogonConnection}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

implementation

procedure TSGWOWLogonConnection.HandleData(const DataType : TSGConnectionDataType; const Data : TStream);
begin
if (not FServerALC_Sets) and FClientALC_Sets then
	begin
	FServerALC := SGReadServerAuthenticationLogonChallenge(Data);
	FServerALC_Sets := True;
	end
else if FServerALC_Sets and FClientALC_Sets then
	begin
	
	end;
end;

procedure TSGWOWLogonConnection.ReadClientALC(const Stream : TStream);
begin
FClientALC := SGReadClientAuthenticationLogonChallenge(Stream);
FClientALC_Sets := True;
end;

constructor TSGWOWLogonConnection.Create();
begin
inherited;
FillChar(FClientALC, SizeOf(FClientALC), 0);
FillChar(FServerALC, SizeOf(FServerALC), 0);
FConnection := nil;
FClientALC_Sets := False;
FServerALC_Sets := False;
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
