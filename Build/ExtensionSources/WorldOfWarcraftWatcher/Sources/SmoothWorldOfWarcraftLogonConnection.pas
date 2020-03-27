{$INCLUDE Smooth.inc}

unit SmoothWorldOfWarcraftLogonConnection;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothInternetConnection
	,SmoothWorldOfWarcraftLogonStructs
	
	,Classes
	;

type
	TSWOWLogonConnection = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		procedure ReadClientALC(const Stream : TStream); virtual;
		procedure HandleData(const DataType : TSConnectionDataType; const Data : TStream); virtual;
			protected
		FConnection : TSInternetConnection;
		FClientALC_Sets : TSBoolean;
		FServerALC_Sets : TSBoolean;
		FClientALC : TSWOW_ALC_Client;
		FServerALC : TSWOW_ALC_Server;
			public
		property Connection : TSInternetConnection read FConnection write FConnection;
		property ClientALC : TSWOW_ALC_Client read FClientALC;
		property ClientALC_Sets : TSBoolean read FClientALC_Sets;
		property ServerALC : TSWOW_ALC_Server read FServerALC;
		property ServerALC_Sets : TSBoolean read FServerALC_Sets;
		end;

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSWOWLogonConnectionListHelper}
{$DEFINE DATATYPE_LIST        := TSWOWLogonConnectionList}
{$DEFINE DATATYPE             := TSWOWLogonConnection}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

implementation

procedure TSWOWLogonConnection.HandleData(const DataType : TSConnectionDataType; const Data : TStream);
begin
if (not FServerALC_Sets) and FClientALC_Sets then
	begin
	FServerALC := SReadServerAuthenticationLogonChallenge(Data);
	FServerALC_Sets := True;
	end
else if FServerALC_Sets and FClientALC_Sets then
	begin
	
	end;
end;

procedure TSWOWLogonConnection.ReadClientALC(const Stream : TStream);
begin
FClientALC := SReadClientAuthenticationLogonChallenge(Stream);
FClientALC_Sets := True;
end;

constructor TSWOWLogonConnection.Create();
begin
inherited;
FillChar(FClientALC, SizeOf(FClientALC), 0);
FillChar(FServerALC, SizeOf(FServerALC), 0);
FConnection := nil;
FClientALC_Sets := False;
FServerALC_Sets := False;
end;

destructor TSWOWLogonConnection.Destroy();
begin
inherited;
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSWOWLogonConnectionListHelper}
{$DEFINE DATATYPE_LIST        := TSWOWLogonConnectionList}
{$DEFINE DATATYPE             := TSWOWLogonConnection}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
