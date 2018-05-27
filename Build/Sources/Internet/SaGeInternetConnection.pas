{$INCLUDE SaGe.inc}

unit SaGeInternetConnection;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeDateTime
	,SaGeEthernetPacketFrame
	,SaGeInternetPacketStorage
	
	,Classes
	;
type
	TSGInternetConnectionSizeInt = TSGUInt64;
	TSGInternetConnection = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			private
		FDataSize : TSGInternetConnectionSizeInt;
		FTimeFirstPacket : TSGTime;
		FDateFirstPacket : TSGDateTime;
		FPacketStorage : TSGInternetPacketStorage;
		
			public
		function PacketPushed(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean; virtual;
		class function PacketComparable(const Packet : TSGEthernetPacketFrame) : TSGBoolean; virtual;
			public
		property DataSize : TSGInternetConnectionSizeInt read FDataSize;
		property TimeFirstPacket : TSGTime read FTimeFirstPacket;
		property DateFirstPacket : TSGDateTime read FDateFirstPacket;
		end;
	TSGInternetConnectionClass = class of TSGInternetConnection;

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSGInternetConnectionListHelper}
{$DEFINE DATATYPE_LIST        := TSGInternetConnectionList}
{$DEFINE DATATYPE             := TSGInternetConnection}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGInternetConnectionClassListHelper}
{$DEFINE DATATYPE_LIST        := TSGInternetConnectionClassList}
{$DEFINE DATATYPE             := TSGInternetConnectionClass}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

procedure SGKill(var Variable : TSGInternetConnection);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

procedure SGKill(var Variable : TSGInternetConnection);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if Variable <> nil then
	begin
	Variable.Destroy();
	Variable := nil;
	end;
end;

class function TSGInternetConnection.PacketComparable(const Packet : TSGEthernetPacketFrame) : TSGBoolean;
begin
Result := False;
end;

function TSGInternetConnection.PacketPushed(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean;
begin
Result := False;
end;

constructor TSGInternetConnection.Create();
begin
inherited;
FDataSize := 0;
FPacketStorage := nil;
end;

destructor TSGInternetConnection.Destroy();
begin
SGKill(FPacketStorage);
inherited;
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSGInternetConnectionListHelper}
{$DEFINE DATATYPE_LIST        := TSGInternetConnectionList}
{$DEFINE DATATYPE             := TSGInternetConnection}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}

{$DEFINE DATATYPE_LIST_HELPER := TSGInternetConnectionClassListHelper}
{$DEFINE DATATYPE_LIST        := TSGInternetConnectionClassList}
{$DEFINE DATATYPE             := TSGInternetConnectionClass}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
