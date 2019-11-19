{$INCLUDE SaGe.inc}

//{$DEFINE SG_IMAGES_DEBUG}

unit SaGeBitMap;

interface

uses 
	 Crt
	
	,SaGeBase
	,SaGeResourceManager
	,SaGeBitMapBase
	,SaGeCasesOfPrint
	;
type
	TSGBitMap = class(TSGResource)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
			// properties
		FWidth  : TSGBitMapUInt;
		FHeight : TSGBitMapUInt;
		
		FChannels    : TSGBitMapUInt; // BitsPerPixel = Channels * ChannelSize
		FChannelSize : TSGBitMapUInt; // (in bits)
		
			// data
		FData : TSGBitMapData;
			public
		procedure Clear(); virtual;
		procedure FreeData(); virtual;
		procedure CopyFrom(const VBitMap : TSGBitMap); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure WriteInfo(const PredStr : TSGString = ''; const CasesOfPrint : TSGCasesOfPrint = [SGCasePrint, SGCaseLog]);
		procedure ReAllocateMemory();
		function DataSize() : TSGUInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function BitsPerPixel() : TSGBitMapUInt; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function HasData() : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		procedure PutImage(const VImage : TSGBitMap; const VX, VY : TSGBitMapUInt);
		procedure PaintSquare(const VColor : TSGPixel4b;  const VX, VY, VWidth, VHeight : TSGBitMapUInt);
			public
		function PixelRGBA32(const x, y : TSGMaxEnum) : TSGPixel4b; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetPixelRGBA32(const _X, _Y : TSGMaxEnum; const _Pixel : TSGPixel4b); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		procedure ReAllocateForBounds(const NewWidth, NewHeight : TSGBitMapUInt);
		procedure SetWidth(const NewWidth : TSGBitMapUInt);
		procedure SetHeight(const NewHeight : TSGBitMapUInt);
		procedure SetBounds(const NewWidth, NewHeight : TSGBitMapUInt); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetBounds(const NewBound : TSGBitMapUInt); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetPixel(const _X, _Y : TSGBitMapUInt; const _Pixel : TSGPixel3b); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property Width        : TSGBitMapUInt read FWidth       write SetWidth;
		property Height       : TSGBitMapUInt read FHeight      write SetHeight;
		property Channels     : TSGBitMapUInt read FChannels    write FChannels;
		property ChannelSize  : TSGBitMapUInt read FChannelSize write FChannelSize;
		property Data         : TSGBitMapData read FData;
		end;

procedure SGKill(var _BitMap : TSGBitMap); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeLog
	,SaGeStringUtils
	;

procedure SGKill(var _BitMap : TSGBitMap); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (_BitMap <> nil) then
	begin
	_BitMap.Destroy();
	_BitMap := nil;
	end;
end;

procedure TSGBitMap.SetPixel(const _X, _Y : TSGBitMapUInt; const _Pixel : TSGPixel3b); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (FChannelSize = 8) and (FChannels = 3) then
	PSGPixel3b(FData)[_Y * Width + _X] := _Pixel;
end;

procedure TSGBitMap.PaintSquare(const VColor : TSGPixel4b;  const VX, VY, VWidth, VHeight : TSGBitMapUInt);
var
	i, ii : TSGMaxEnum;
	Pixel : PSGPixel4b = nil;
begin
for i := 0 to VWidth - 1 do
	for ii := 0 to VHeight - 1 do
		begin
		Pixel := @PSGPixel4b(FData)[VX + i + (VY + ii) * Width];
		Pixel^ := SGMultPixel4b(Pixel^, VColor);
		end;
end;

procedure TSGBitMap.ReAllocateForBounds(const NewWidth, NewHeight : TSGBitMapUInt);
var
	NewBitMap : TSGBitMapData;
	Size, i : TSGMaxEnum;
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

procedure TSGBitMap.PutImage(const VImage : TSGBitMap; const VX, VY : TSGBitMapUInt);
var
	i : TSGMaxEnum;
begin
for i := 0 to VImage.Height - 1 do
	Move(VImage.Data[Channels * VImage.Width * i], FData[((i + VY) * Width + VX ) * Channels], VImage.Width * Channels);
end;

procedure TSGBitMap.SetPixelRGBA32(const _X, _Y : TSGMaxEnum; const _Pixel : TSGPixel4b); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
PSGPixel4b(FData)[_Y* FWidth + _X] := _Pixel;
end;

function TSGBitMap.PixelRGBA32(const x, y : TSGMaxEnum) : TSGPixel4b; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := PSGPixel4b(FData)[y* FWidth + x];
end;

procedure TSGBitMap.SetBounds(const NewBound : TSGBitMapUInt);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetBounds(NewBound, NewBound);
end;

procedure TSGBitMap.SetBounds(const NewWidth, NewHeight : TSGBitMapUInt);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetHeight(NewHeight);
SetWidth(NewWidth);
end;

procedure TSGBitMap.SetHeight(const NewHeight : TSGBitMapUInt);
var
	NewBitMap : TSGBitMapData = nil;
	I, II, III, IIII : TSGMaxEnum;
	Info : TSGPixelInfo = (FArray : nil);
	a : TSGFloat32;
begin
{$IFDEF SG_IMAGES_DEBUG}
SGLog.Sourse('TSGBitMap : Beginning to set new Height "'+SGStr(FHeight)+'" -> "'+SGStr(NewHeight)+'" (Width = '+SGStr(FWidth)+').');
{$ENDIF}
if (NewHeight = FHeight) then
	begin
	{$IFDEF SG_IMAGES_DEBUG}
	SGLog.Sourse('TSGBitMap : Setting new Height not need.');
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

procedure TSGBitMap.SetWidth(const NewWidth : TSGBitMapUInt);
var
	NewBitMap : TSGBitMapData = nil;
	I, II, III, IIII : TSGMaxEnum;
	Info : TSGPixelInfo = (FArray : nil);
	a : TSGFloat32;
begin
{$IFDEF SG_IMAGES_DEBUG}
SGLog.Sourse('TSGBitMap : Begin to set new Width "'+SGStr(FWidth)+'" -> "'+SGStr(NewWidth)+'" (Height = '+SGStr(FHeight)+').');
{$ENDIF}
if (NewWidth = FWidth) then
	begin
	{$IFDEF SG_IMAGES_DEBUG}
	SGLog.Sourse('TSGBitMap: Set new Width not need.');
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

procedure TSGBitMap.WriteInfo(const PredStr : TSGString = ''; const CasesOfPrint : TSGCasesOfPrint = [SGCasePrint, SGCaseLog]);
begin
SGHint(PredStr + 'TSGBitMap__WriteInfo(..)', CasesOfPrint);
SGHint([PredStr,' Width    = ',FWidth], CasesOfPrint);
SGHint([PredStr,' Height   = ',FHeight], CasesOfPrint);
SGHint([PredStr,' Channels = ',FChannels], CasesOfPrint);
SGHint([PredStr,' ChannelSize = ',FChannelSize], CasesOfPrint);
TextColor(15);
SGHint([PredStr,' Size     = ',SGGetSizeString(DataSize(),'EN')], CasesOfPrint);
TextColor(7);
end;

function TSGBitMap.HasData() : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (DataSize() <> 0) and (FData <> nil);
end;

function TSGBitMap.BitsPerPixel() : TSGBitMapUInt; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Channels * ChannelSize;
end;

function TSGBitMap.DataSize() : TSGUInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	TempSize : TSGUInt64;
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

procedure TSGBitMap.ReAllocateMemory();
var
	BitMapDataSize : TSGUInt64;
begin
SGKill(FData);
BitMapDataSize := DataSize();
GetMem(FData, BitMapDataSize);
fillchar(FData^, BitMapDataSize, 0);
end;

procedure TSGBitMap.FreeData(); 
begin
SGKill(FData);
end;

procedure TSGBitMap.Clear();
begin
SGKill(FData);
FWidth       := 0;
FHeight      := 0;
FChannelSize := 0;
FChannels    := 0;
end;

procedure TSGBitMap.CopyFrom(const VBitMap : TSGBitMap);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Size : TSGMaxEnum;
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

constructor TSGBitMap.Create();
begin
inherited;
FData := nil;
Clear();
end;

destructor TSGBitMap.Destroy();
begin
Clear();
inherited;
end;

end.
