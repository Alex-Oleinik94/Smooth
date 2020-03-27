{$INCLUDE Smooth.inc}

unit SmoothInternetPacketStorage;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothEthernetPacketFrame
	,SmoothDateTime
	;
type
	TSInternetPacket = object
			protected
		FPacket : TSEthernetPacketFrame;
		FDate : TSDateTime;
		FTime : TSTime;
			public
		procedure Kill();
		class function Create(const _Time : TSTime; const _Date : TSDateTime; const _Packet : TSEthernetPacketFrame) : TSInternetPacket;
			public
		property Packet : TSEthernetPacketFrame read FPacket write FPacket;
		property Date : TSDateTime read FDate write FDate;
		property Time : TSTime read FTime write FTime;
		end;
const
	SInternetPacketStorageChunckLength = 2000;
type
	PSInternetPacketStorageChunck = ^ TSInternetPacketStorageChunck;
	TSInternetPacketStorageChunck = object
			protected
		FPackets : array[0..SInternetPacketStorageChunckLength-1] of TSInternetPacket;
		FLength : TSUInt32;
			public
		property Length : TSUInt32 read FLength;
			public
		procedure Kill();
		procedure Add(const Packet : TSInternetPacket);
		end;

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSInternetPacketStorageListHelper}
{$DEFINE DATATYPE_LIST        := TSInternetPacketStorageList}
{$DEFINE DATATYPE             := PSInternetPacketStorageChunck}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}
type
	TSInternetPacketStorage = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FChunckList : TSInternetPacketStorageList;
		FHasData : TSBoolean;
			public
		procedure Add(const Packet : TSInternetPacket);
		procedure Add(const _Time : TSTime; const _Date : TSDateTime; const _Packet : TSEthernetPacketFrame);
			protected
		procedure AddNewChunck(const Packet : TSInternetPacket);
			public
		property HasData : TSBoolean read FHasData;
		end;

procedure SKill(var Storage : TSInternetPacketStorage);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

constructor TSInternetPacketStorage.Create();
begin
inherited;
FChunckList := nil;
FHasData := False;
end;

destructor TSInternetPacketStorage.Destroy();
var
	Index : TSMaxEnum;
begin
if (FChunckList <> nil) and (Length(FChunckList) > 0) then
	begin
	for Index := 0 to High(FChunckList) do
		if (FChunckList[Index] <> nil) then
			begin
			if (FChunckList[Index]^.Length > 0) then
				FChunckList[Index]^.Kill();
			FreeMem(FChunckList[Index]);
			FChunckList[Index] := nil;
			end;
	SetLength(FChunckList, 0);
	FChunckList := nil;
	end;
inherited;
end;

procedure TSInternetPacketStorage.AddNewChunck(const Packet : TSInternetPacket);
var
	NewChunck : PSInternetPacketStorageChunck;
begin
NewChunck := GetMem(SizeOf(TSInternetPacketStorageChunck));
FillChar(NewChunck^, SizeOf(TSInternetPacketStorageChunck), 0);
NewChunck^.Add(Packet);
FChunckList += NewChunck;
end;

procedure TSInternetPacketStorage.Add(const Packet : TSInternetPacket);
begin
if (FChunckList = nil) or (Length(FChunckList) = 0) then
	AddNewChunck(Packet)
else if FChunckList[High(FChunckList)]^.Length = SInternetPacketStorageChunckLength then
	AddNewChunck(Packet)
else if FChunckList[High(FChunckList)]^.Length < SInternetPacketStorageChunckLength then
	FChunckList[High(FChunckList)]^.Add(Packet);
FHasData := True;
end;

procedure TSInternetPacketStorage.Add(const _Time : TSTime; const _Date : TSDateTime; const _Packet : TSEthernetPacketFrame);
begin
Add(TSInternetPacket.Create(_Time, _Date, _Packet));
end;

procedure TSInternetPacketStorageChunck.Kill();
var
	Index : TSMaxEnum;
begin
if FLength > 0 then
	begin
	for Index := 0 to FLength - 1 do
		FPackets[Index].Kill();
	FLength := 0;
	end;
end;

procedure TSInternetPacketStorageChunck.Add(const Packet : TSInternetPacket);
begin
FPackets[FLength] := Packet;
FLength += 1;
end;

class function TSInternetPacket.Create(const _Time : TSTime; const _Date : TSDateTime; const _Packet : TSEthernetPacketFrame) : TSInternetPacket;
begin
Result.FPacket := _Packet;
Result.FTime := _Time;
Result.FDate := _Date;
end;

procedure TSInternetPacket.Kill();
begin
FPacket.Destroy();
FillChar(Self, SizeOf(Self), 0);
end;

procedure SKill(var Storage : TSInternetPacketStorage);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if Storage <> nil then
	begin
	Storage.Destroy();
	Storage := nil;
	end;
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSInternetPacketStorageListHelper}
{$DEFINE DATATYPE_LIST        := TSInternetPacketStorageList}
{$DEFINE DATATYPE             := PSInternetPacketStorageChunck}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
