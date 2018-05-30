{$INCLUDE SaGe.inc}

unit SaGeInternetConnection;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeDateTime
	,SaGeEthernetPacketFrame
	,SaGeInternetPacketStorage
	,SaGeTextStream
	,SaGeInternetBase
	,SaGeCriticalSection
	
	,Classes
	;
type
	TSGInternetConnectionSizeInt = TSGUInt64;
	TSGInternetConnection = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FCritacalSection : TSGCriticalSection;
		FPacketStorage : TSGInternetPacketStorage;
		FModeDataTransfer : TSGBoolean;
		FModePacketStorage : TSGBoolean;
		FModeDataDumper : TSGBoolean;
		
		FTimeFirstPacket : TSGTime;
		FDateFirstPacket : TSGDateTime;
		FTimeLastPacket : TSGTime;
		FDateLastPacket : TSGDateTime;
		FSecondsMeansConnectionActive : TSGUInt16;
		
		FDataSize : TSGInternetConnectionSizeInt;
		FPacketCount : TSGInternetConnectionSizeInt;
		
		FDeviceIPv4Supported : TSGBoolean;
		FDeviceIPv4Net  : TSGIPv4Address;
		FDeviceIPv4Mask : TSGIPv4Address;
			public
		procedure PrintTextInfo(const TextStream : TSGTextStream); virtual;
			public
		function PacketPushed(const Time : TSGTime; const Date : TSGDateTime; const Packet : TSGEthernetPacketFrame) : TSGBoolean; virtual;
		class function PacketComparable(const Packet : TSGEthernetPacketFrame) : TSGBoolean; virtual;
		procedure AddDeviceIPv4(const Net, Mask : TSGIPv4Address); virtual;
			public
		property DataSize : TSGInternetConnectionSizeInt read FDataSize;
		property TimeFirstPacket : TSGTime read FTimeFirstPacket;
		property DateFirstPacket : TSGDateTime read FDateFirstPacket;
		property ModeDataTransfer : TSGBoolean read FModeDataTransfer write FModeDataTransfer;
		property ModePacketStorage : TSGBoolean read FModePacketStorage write FModePacketStorage;
		property ModeDataDumper : TSGBoolean read FModeDataDumper write FModeDataDumper;
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

procedure TSGInternetConnection.AddDeviceIPv4(const Net, Mask : TSGIPv4Address);
begin
FDeviceIPv4Supported := True;
FDeviceIPv4Net  := Net;
FDeviceIPv4Mask := Mask;
end;

procedure TSGInternetConnection.PrintTextInfo(const TextStream : TSGTextStream);
begin
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
FPacketCount := 0;
FPacketStorage := TSGInternetPacketStorage.Create();
FCritacalSection := TSGCriticalSection.Create();
FDeviceIPv4Supported := False;
FSecondsMeansConnectionActive := 10;
FModePacketStorage := False;
FModeDataTransfer := True;
FModeDataDumper := False;
end;

destructor TSGInternetConnection.Destroy();
begin
SGKill(FCritacalSection);
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
