{$INCLUDE Smooth.inc}

//{$DEFINE S_IMAGES_DEBUG}

unit SmoothBitMap;

interface

uses 
	 Crt
	
	,SmoothBase
	,SmoothResourceManager
	,SmoothBitMapBase
	,SmoothCasesOfPrint
	;
type
	TSBitMap = class(TSResource)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
			// properties
		FWidth  : TSBitMapUInt;
		FHeight : TSBitMapUInt;
		
		FChannels    : TSBitMapUInt; // BitsPerPixel = Channels * ChannelSize
		FChannelSize : TSBitMapUInt; // (in bits)
		
			// data
		FData : TSBitMapData;
			public
		procedure Clear(); virtual;
		procedure FreeData(); virtual;
		procedure CopyFrom(const VBitMap : TSBitMap); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure WriteInfo(const PredStr : TSString = ''; const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog]);
		procedure ReAllocateMemory();
		function DataSize() : TSUInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function BitsPerPixel() : TSBitMapUInt; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function HasData() : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		procedure PutImage(const VImage : TSBitMap; const VX, VY : TSBitMapUInt);
		procedure PaintSquare(const VColor : TSPixel4b;  const VX, VY, VWidth, VHeight : TSBitMapUInt);
			public
		function PixelRGBA32(const x, y : TSMaxEnum) : TSPixel4b; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetPixelRGBA32(const _X, _Y : TSMaxEnum; const _Pixel : TSPixel4b); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		procedure ReAllocateForBounds(const NewWidth, NewHeight : TSBitMapUInt);
		procedure SetWidth(const NewWidth : TSBitMapUInt);
		procedure SetHeight(const NewHeight : TSBitMapUInt);
		procedure SetBounds(const NewWidth, NewHeight : TSBitMapUInt); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetBounds(const NewBound : TSBitMapUInt); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetPixel(const _X, _Y : TSBitMapUInt; const _Pixel : TSPixel3b); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property Width        : TSBitMapUInt read FWidth       write SetWidth;
		property Height       : TSBitMapUInt read FHeight      write SetHeight;
		property Channels     : TSBitMapUInt read FChannels    write FChannels;
		property ChannelSize  : TSBitMapUInt read FChannelSize write FChannelSize;
		property Data         : TSBitMapData read FData;
		end;

procedure SKill(var _BitMap : TSBitMap); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothLog
	,SmoothStringUtils
	;

procedure SKill(var _BitMap : TSBitMap); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (_BitMap <> nil) then
	begin
	_BitMap.Destroy();
	_BitMap := nil;
	end;
end;

procedure TSBitMap.SetPixel(const _X, _Y : TSBitMapUInt; const _Pixel : TSPixel3b); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (FChannelSize = 8) and (FChannels = 3) then
	PSPixel3b(FData)[_Y * Width + _X] := _Pixel;
end;

procedure TSBitMap.PaintSquare(const VColor : TSPixel4b;  const VX, VY, VWidth, VHeight : TSBitMapUInt);
var
	i, ii : TSMaxEnum;
	Pixel : PSPixel4b = nil;
begin
for i := 0 to VWidth - 1 do
	for ii := 0 to VHeight - 1 do
		begin
		Pixel := @PSPixel4b(FData)[VX + i + (VY + ii) * Width];
		Pixel^ := SMultPixel4b(Pixel^, VColor);
		end;
end;

procedure TSBitMap.ReAllocateForBounds(const NewWidth, NewHeight : TSBitMapUInt);
var
	NewBitMap : TSBitMapData;
	Size, i : TSMaxEnum;
begin
Size := Channels * NewWidth * NewHeight;
NewBitMap := GetMem(Size);
fillchar(NewBitMap^, Size, 0);
for i := 0 to FHeight - 1 do
	Move(FData[i * Width * Channels], NewBitMap[i * NewWidth * Channels], Width * Channels);
FreeMem(FData);
FData := NewBitMap;
FWidth := NewWidth;
FHeight := NewHeight;
end;

procedure TSBitMap.PutImage(const VImage : TSBitMap; const VX, VY : TSBitMapUInt);
var
	i : TSMaxEnum;
begin
for i := 0 to VImage.Height - 1 do
	Move(VImage.Data[Channels * VImage.Width * i], FData[((i + VY) * Width + VX ) * Channels], VImage.Width * Channels);
end;

procedure TSBitMap.SetPixelRGBA32(const _X, _Y : TSMaxEnum; const _Pixel : TSPixel4b); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
PSPixel4b(FData)[_Y* FWidth + _X] := _Pixel;
end;

function TSBitMap.PixelRGBA32(const x, y : TSMaxEnum) : TSPixel4b; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := PSPixel4b(FData)[y* FWidth + x];
end;

procedure TSBitMap.SetBounds(const NewBound : TSBitMapUInt);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetBounds(NewBound, NewBound);
end;

procedure TSBitMap.SetBounds(const NewWidth, NewHeight : TSBitMapUInt);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetHeight(NewHeight);
SetWidth(NewWidth);
end;

procedure TSBitMap.SetHeight(const NewHeight : TSBitMapUInt);
var
	NewBitMap : TSBitMapData = nil;
	I, II, III, IIII : TSMaxEnum;
	Info : TSPixelInfo = (FArray : nil);
	a : TSFloat32;
begin
{$IFDEF S_IMAGES_DEBUG}
SLog.Sourse('TSBitMap : Beginning to set new Height "'+SStr(FHeight)+'" -> "'+SStr(NewHeight)+'" (Width = '+SStr(FWidth)+').');
{$ENDIF}
if (NewHeight = FHeight) then
	begin
	{$IFDEF S_IMAGES_DEBUG}
	SLog.Sourse('TSBitMap : Setting new Height not need.');
	{$ENDIF}
	Exit;
	end
else if ((FHeight = 0) or (FData = nil)) then
	begin
	FHeight := NewHeight;
	Exit;
	end;

case FChannels * FChannelSize of
24, 32:
	begin
	GetMem(NewBitMap,FChannels*Width*NewHeight);
	for i:=0 to NewHeight-1 do
		begin
		Info.Get(Height,NewHeight,i);
		for ii:=0 to Width-1 do
			begin
			for iiii:=0 to FChannels-1 do
				begin
				a:=0;
				for iii:=0 to High(Info.FArray) do
					a+=FData[
						(ii+Info.FArray[iii].FIdentifity*Width)
						*FChannels+iiii]
						*Info.FArray[iii].FProcent;
				NewBitMap[(i*Width+ii)*FChannels+iiii]:=Round(a);
				end;
			end;
		end;
	FreeMem(FData);
	FData := NewBitMap;
	FHeight := NewHeight;
	Info.Clear;
	end;
end;
end;

procedure TSBitMap.SetWidth(const NewWidth : TSBitMapUInt);
var
	NewBitMap : TSBitMapData = nil;
	I, II, III, IIII : TSMaxEnum;
	Info : TSPixelInfo = (FArray : nil);
	a : TSFloat32;
begin
{$IFDEF S_IMAGES_DEBUG}
SLog.Sourse('TSBitMap : Begin to set new Width "'+SStr(FWidth)+'" -> "'+SStr(NewWidth)+'" (Height = '+SStr(FHeight)+').');
{$ENDIF}
if (NewWidth = FWidth) then
	begin
	{$IFDEF S_IMAGES_DEBUG}
	SLog.Sourse('TSBitMap: Set new Width not need.');
	{$ENDIF}
	Exit;
	end
else if ((FWidth = 0) or (FData = nil)) then
	begin
	FWidth := NewWidth;
	Exit;
	end;

case FChannels*FChannelSize of
24,32:
	begin
	GetMem(NewBitMap, FChannels*NewWidth*Height);
	for i:=0 to NewWidth-1 do
		begin
		Info.Get(Width,NewWidth,i);
		for ii:=0 to Height-1 do
			begin
			for iiii:=0 to FChannels-1 do
				begin
				a:=0;
				for iii:=0 to High(Info.FArray) do
					a+=FData[(Info.FArray[iii].FIdentifity+ii*Width)*FChannels+iiii]*Info.FArray[iii].FProcent;
				NewBitMap[(i+ii*NewWidth)*FChannels+iiii]:=Round(a);
				end;
			end;
		end;
	FreeMem(FData);
	FData := NewBitMap;
	FWidth := NewWidth;
	Info.Clear;
	end;
end;
end;

procedure TSBitMap.WriteInfo(const PredStr : TSString = ''; const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog]);
begin
SHint(PredStr + 'TSBitMap__WriteInfo(..)', CasesOfPrint);
SHint([PredStr,' Width    = ',FWidth], CasesOfPrint);
SHint([PredStr,' Height   = ',FHeight], CasesOfPrint);
SHint([PredStr,' Channels = ',FChannels], CasesOfPrint);
SHint([PredStr,' ChannelSize = ',FChannelSize], CasesOfPrint);
TextColor(15);
SHint([PredStr,' Size     = ',SGetSizeString(DataSize(),'EN')], CasesOfPrint);
TextColor(7);
end;

function TSBitMap.HasData() : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (DataSize() <> 0) and (FData <> nil);
end;

function TSBitMap.BitsPerPixel() : TSBitMapUInt; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Channels * ChannelSize;
end;

function TSBitMap.DataSize() : TSUInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	TempSize : TSUInt64;
begin
// BitsPerPixel = ChannelSize * Channels
// DataSize = Width * Height * (BitsPerPixel div 8)
if (ChannelSize = 8{bit}) then
	Result := Width * Height * Channels
else
	begin
	TempSize := Width * Height * Channels * ChannelSize;
	Result := TempSize div 8;
	if (TempSize mod 8 <> 0) then
		Result += 1;
	end;
end;

procedure TSBitMap.ReAllocateMemory();
var
	BitMapDataSize : TSUInt64;
begin
SKill(FData);
BitMapDataSize := DataSize();
GetMem(FData, BitMapDataSize);
fillchar(FData^, BitMapDataSize, 0);
end;

procedure TSBitMap.FreeData(); 
begin
SKill(FData);
end;

procedure TSBitMap.Clear();
begin
SKill(FData);
FWidth       := 0;
FHeight      := 0;
FChannelSize := 0;
FChannels    := 0;
end;

procedure TSBitMap.CopyFrom(const VBitMap : TSBitMap);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Size : TSMaxEnum;
begin
Clear();
FWidth  := VBitMap.Width;
FHeight := VBitMap.Height;
FChannelSize := VBitMap.ChannelSize;
FChannels := VBitMap.Channels;
if (VBitMap.Data <> nil) then
	begin
	Size := VBitMap.DataSize();
	FData := GetMem(Size);
	Move(VBitMap.Data^, FData^, Size); 
	end;
end;

constructor TSBitMap.Create();
begin
inherited;
FData := nil;
Clear();
end;

destructor TSBitMap.Destroy();
begin
Clear();
inherited;
end;

end.
