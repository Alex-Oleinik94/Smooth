{$INCLUDE SaGe.inc}

unit SaGeInternetPacketStorage;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	,SaGeEthernetPacketFrame
	,SaGeDateTime
	;
type
	TSGInternetPacket = object
			protected
		FPacket : TSGEthernetPacketFrame;
		FDate : TSGDateTime;
		FTime : TSGTime;
			public
		procedure Kill();
		class function Create(const _Time : TSGTime; const _Date : TSGDateTime; const _Packet : TSGEthernetPacketFrame) : TSGInternetPacket;
			public
		property Packet : TSGEthernetPacketFrame read FPacket write FPacket;
		property Date : TSGDateTime read FDate write FDate;
		property Time : TSGTime read FTime write FTime;
		end;
const
	SGInternetPacketStorageChunckLength = 2000;
type
	PSGInternetPacketStorageChunck = ^ TSGInternetPacketStorageChunck;
	TSGInternetPacketStorageChunck = object
			protected
		FPackets : array[0..SGInternetPacketStorageChunckLength-1] of TSGInternetPacket;
		FLength : TSGUInt32;
			public
		property Length : TSGUInt32 read FLength;
			public
		procedure Kill();
		procedure Add(const Packet : TSGInternetPacket);
		end;

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSGInternetPacketStorageListHelper}
{$DEFINE DATATYPE_LIST        := TSGInternetPacketStorageList}
{$DEFINE DATATYPE             := PSGInternetPacketStorageChunck}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}
type
	TSGInternetPacketStorage = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FChunckList : TSGInternetPacketStorageList;
		FHasData : TSGBoolean;
			public
		procedure Add(const Packet : TSGInternetPacket);
		procedure Add(const _Time : TSGTime; const _Date : TSGDateTime; const _Packet : TSGEthernetPacketFrame);
			protected
		procedure AddNewChunck(const Packet : TSGInternetPacket);
			public
		property HasData : TSGBoolean read FHasData;
		end;

procedure SGKill(var Storage : TSGInternetPacketStorage);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

constructor TSGInternetPacketStorage.Create();
begin
inherited;
FChunckList := nil;
FHasData := False;
end;

destructor TSGInternetPacketStorage.Destroy();
var
	Index : TSGMaxEnum;
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

procedure TSGInternetPacketStorage.AddNewChunck(const Packet : TSGInternetPacket);
var
	NewChunck : PSGInternetPacketStorageChunck;
begin
NewChunck := GetMem(SizeOf(TSGInternetPacketStorageChunck));
FillChar(NewChunck^, SizeOf(TSGInternetPacketStorageChunck), 0);
NewChunck^.Add(Packet);
FChunckList += NewChunck;
end;

procedure TSGInternetPacketStorage.Add(const Packet : TSGInternetPacket);
begin
if (FChunckList = nil) or (Length(FChunckList) = 0) then
	AddNewChunck(Packet)
else if FChunckList[High(FChunckList)]^.Length = SGInternetPacketStorageChunckLength then
	AddNewChunck(Packet)
else if FChunckList[High(FChunckList)]^.Length < SGInternetPacketStorageChunckLength then
	FChunckList[High(FChunckList)]^.Add(Packet);
FHasData := True;
end;

procedure TSGInternetPacketStorage.Add(const _Time : TSGTime; const _Date : TSGDateTime; const _Packet : TSGEthernetPacketFrame);
begin
Add(TSGInternetPacket.Create(_Time, _Date, _Packet));
end;

procedure TSGInternetPacketStorageChunck.Kill();
var
	Index : TSGMaxEnum;
begin
if FLength > 0 then
	begin
	for Index := 0 to FLength - 1 do
		FPackets[Index].Kill();
	FLength := 0;
	end;
end;

procedure TSGInternetPacketStorageChunck.Add(const Packet : TSGInternetPacket);
begin
FPackets[FLength] := Packet;
FLength += 1;
end;

class function TSGInternetPacket.Create(const _Time : TSGTime; const _Date : TSGDateTime; const _Packet : TSGEthernetPacketFrame) : TSGInternetPacket;
begin
Result.FPacket := _Packet;
Result.FTime := _Time;
Result.FDate := _Date;
end;

procedure TSGInternetPacket.Kill();
begin
FPacket.Destroy();
FillChar(Self, SizeOf(Self), 0);
end;

procedure SGKill(var Storage : TSGInternetPacketStorage);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if Storage <> nil then
	begin
	Storage.Destroy();
	Storage := nil;
	end;
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSGInternetPacketStorageListHelper}
{$DEFINE DATATYPE_LIST        := TSGInternetPacketStorageList}
{$DEFINE DATATYPE             := PSGInternetPacketStorageChunck}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
