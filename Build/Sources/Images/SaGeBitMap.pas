{$INCLUDE SaGe.inc}

//{$DEFINE SG_IMAGES_DEBUG}

unit SaGeBitMap;

interface

uses 
	 Crt
	
	,SaGeBase
	,SaGeRenderBase
	,SaGeResourceManager
	,SaGeBitMapBase
	,SaGeCasesOfPrint
	;
type
	TSGBitMap = class(TSGResource)
			public
		constructor Create();override;
		destructor Destroy();override;
			protected
		FBitMap : PSGByte;
		
		FWidth  : TSGBitMapUInt;
		FHeight : TSGBitMapUInt;
		
		FChannels    : TSGBitMapUInt;
		FChannelSize : TSGBitMapUInt;
		
		FFormatType : TSGBitMapUInt;
		FDataType   : TSGBitMapUInt;
			public
		procedure Clear(); virtual;
		procedure ClearBitMapBits(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure CopyFrom(const VBitMap : TSGBitMap); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure WriteInfo(const PredStr : TSGString = ''; const CasesOfPrint : TSGCasesOfPrint = [SGCasePrint, SGCaseLog]);
		procedure ReAllocateMemory();
		function DataSize() : TSGUInt64; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		procedure CreateTypes(const Alpha:TSGBitMapUInt = SG_UNKNOWN;const Grayscale:TSGBitMapUInt = SG_UNKNOWN);
		function PixelsRGBA(const x,y:TSGBitMapUInt):PSGPixel4b; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure PutImage(const VImage : TSGBitMap; const VX, VY : TSGBitMapUInt);
		procedure PaintSquare(const VColor : TSGPixel4b;  const VX, VY, VWidth, VHeight : TSGBitMapUInt);
			public
		procedure ReAllocateForBounds(const NewWidth, NewHeight : TSGBitMapUInt);
		procedure SetWidth(const NewWidth : TSGBitMapUInt);
		procedure SetHeight(const NewHeight : TSGBitMapUInt);
		procedure SetBounds(const NewWidth, NewHeight : TSGBitMapUInt); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetBounds(const NewBound : TSGBitMapUInt); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetPixel(const _X, _Y : TSGBitMapUInt; const _Pixel : TSGPixel3b); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property Width       : TSGBitMapUInt read FWidth       write FWidth;
		property Height      : TSGBitMapUInt read FHeight      write FHeight;
		property Channels    : TSGBitMapUInt read FChannels    write FChannels;
		property BitDepth    : TSGBitMapUInt read FChannelSize write FChannelSize;
		property ChannelSize : TSGBitMapUInt read FChannelSize write FChannelSize;
		property PixelFormat : TSGBitMapUInt read FFormatType  write FFormatType;
		property PixelType   : TSGBitMapUInt read FDataType    write FDataType;
		property BitMap      : PSGByte       read FBitMap      write FBitMap;
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
	PSGPixel3b(FBitMap)[_Y * Width + _X] := _Pixel;
end;

procedure TSGBitMap.PaintSquare(const VColor : TSGPixel4b;  const VX, VY, VWidth, VHeight : TSGBitMapUInt);
var
	i, ii : TSGMaxEnum;
	Pixel : PSGPixel4b = nil;
begin
for i := 0 to VWidth - 1 do
	for ii := 0 to VHeight - 1 do
		begin
		Pixel := @PSGPixel4b(BitMap)[VX + i + (VY + ii) * Width];
		Pixel^ := SGMultPixel4b(Pixel^, VColor);
		end;
end;

procedure TSGBitMap.ReAllocateForBounds(const NewWidth, NewHeight : TSGBitMapUInt);
var
	NewBitMap : PByte;
	Size, i : TSGMaxEnum;
begin
Size := Channels * NewWidth * NewHeight;
NewBitMap := GetMem(Size);
fillchar(NewBitMap^, Size, 0);
for i := 0 to FHeight - 1 do
	begin
	Move(BitMap[i * Width * Channels], NewBitMap[i * NewWidth * Channels], Width * Channels);
	end;
FreeMem(BitMap);
BitMap := NewBitMap;
FWidth := NewWidth;
FHeight := NewHeight;
end;

procedure TSGBitMap.PutImage(const VImage : TSGBitMap; const VX, VY : TSGBitMapUInt);
var
	i : TSGMaxEnum;
begin
for i := 0 to VImage.Height - 1 do
	begin
	Move(VImage.BitMap[Channels * VImage.Width * i], BitMap[((i + VY) * Width + VX ) * Channels], VImage.Width * Channels);
	end;
end;

function TSGBitMap.PixelsRGBA(const x,y:LongWord):PSGPixel4b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := @PSGPixel4b(FBitMap)[y* FWidth + x];
end;

procedure TSGBitMap.SetBounds(const NewBound:TSGBitMapUInt);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetBounds(NewBound,NewBound);
end;

procedure TSGBitMap.SetBounds(const NewWidth,NewHeight:TSGBitMapUInt);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetHeight(NewHeight);
SetWidth(NewWidth);
end;

procedure TSGBitMap.SetHeight(const NewHeight:TSGBitMapUInt);
var
	NewBitMap:PByte = nil;
	I,II,III,IIII:LongWord;
	Info:TSGPixelInfo = (FArray:nil);
	a:single;
begin
{$IFDEF SG_IMAGES_DEBUG}
SGLog.Sourse('TSGBitMap : Beginning to set new Height "'+SGStr(FHeight)+'" -> "'+SGStr(NewHeight)+'" (Width = '+SGStr(FWidth)+').');
{$ENDIF}
if NewHeight=FHeight then
	begin
	{$IFDEF SG_IMAGES_DEBUG}
	SGLog.Sourse('TSGBitMap : Setting new Height not need.');
	{$ENDIF}
	Exit;
	end;

case FChannels*FChannelSize of
24,32:
	begin
	GetMem(NewBitMap,FChannels*Width*NewHeight);
	for i:=0 to NewHeight-1 do
		begin
		Info.Get(Height,NewHeight,i);
		
		{for ii:=0 to High(Info.FArray) do
			begin
			SGLog.Sourse(SGStr(ii)+' '+SGStrReal(Info.FArray[ii].FProcent,3)+' '+SGStr(Info.FArray[ii].FIdentifity));
			end;}
		for ii:=0 to Width-1 do
			begin
			for iiii:=0 to FChannels-1 do
				begin
				a:=0;
				for iii:=0 to High(Info.FArray) do
					a+=FBitMap[
						(ii+Info.FArray[iii].FIdentifity*Width)
						*FChannels+iiii]
						*Info.FArray[iii].FProcent;
				NewBitMap[(i*Width+ii)*FChannels+iiii]:=Round(a);
				end;
			end;
		end;
	FreeMem(FBitMap);
	FBitMap:=NewBitMap;
	FHeight:=NewHeight;
	Info.Clear;
	end;
end;
end;

procedure TSGBitMap.SetWidth(const NewWidth:TSGBitMapUInt);
var
	NewBitMap:PByte = nil;
	I,II,III,IIII:LongWord;
	Info:TSGPixelInfo = (FArray:nil);
	a:single;
begin
{$IFDEF SG_IMAGES_DEBUG}
SGLog.Sourse('TSGBitMap : Beginning to set new Width "'+SGStr(FWidth)+'" -> "'+SGStr(NewWidth)+'" (Height = '+SGStr(FHeight)+').');
{$ENDIF}
if NewWidth=FWidth then
	begin
	{$IFDEF SG_IMAGES_DEBUG}
	SGLog.Sourse('TSGBitMap : Setting new Width not need.');
	{$ENDIF}
	Exit;
	end;

case FChannels*FChannelSize of
24,32:
	begin
	GetMem(NewBitMap,FChannels*NewWidth*Height);
	for i:=0 to NewWidth-1 do
		begin
		Info.Get(Width,NewWidth,i);
		for ii:=0 to Height-1 do
			begin
			for iiii:=0 to FChannels-1 do
				begin
				a:=0;
				for iii:=0 to High(Info.FArray) do
					a+=FBitMap[(Info.FArray[iii].FIdentifity+ii*Width)*FChannels+iiii]*Info.FArray[iii].FProcent;
				NewBitMap[(i+ii*NewWidth)*FChannels+iiii]:=Round(a);
				end;
			end;
		end;
	FreeMem(FBitMap);
	FBitMap:=NewBitMap;
	FWidth:=NewWidth;
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
SGHint([PredStr,' BitDepth = ',FChannelSize], CasesOfPrint);
TextColor(15);
SGHint([PredStr,' Size     = ',SGGetSizeString(FWidth*FHeight*FChannels*FChannelSize div 8,'EN')], CasesOfPrint);
TextColor(7);
end;

procedure TSGBitMap.CreateTypes(const Alpha:TSGBitMapUInt = SG_UNKNOWN;const Grayscale:TSGBitMapUInt = SG_UNKNOWN);
begin
FFormatType:=0;
FDataType:=0;
case FChannels of 
1:
	begin 
	if Grayscale=SG_TRUE then 
		FFormatType:=SGR_LUMINANCE
	else
		if Alpha=SG_TRUE then
			FFormatType:=SGR_ALPHA
		else
			if (Alpha=SG_FALSE) and (Grayscale=SG_FALSE) then
				FFormatType:=SGR_INTENSITY
			else
				FFormatType:=SGR_RED;
	end;
2:
	begin
	//if (Grayscale=SG_TRUE) and (Alpha=SG_TRUE) then
		FFormatType:=SGR_LUMINANCE_ALPHA;
		
	end;
3:
	begin
	FFormatType:=SGR_RGB;
	end;
4:
	begin
	FFormatType:=SGR_RGBA;
	end;
else
	FFormatType:=0;
end;
case FChannelSize of
8:
	FDataType:=SGR_UNSIGNED_BYTE;
else
	FDataType:=SGR_BITMAP;
end;
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
ClearBitMapBits();
BitMapDataSize := DataSize();
GetMem(FBitMap, BitMapDataSize);
fillchar(FBitMap^, BitMapDataSize, 0);
end;

procedure TSGBitMap.ClearBitMapBits();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FBitMap <> nil then
	begin
	FreeMem(FBitMap);
	FBitMap := nil;
	end;
end;

procedure TSGBitMap.Clear();
begin
ClearBitMapBits();
FWidth      := 0;
FHeight     := 0;
FChannelSize:= 0;
FFormatType := 0;
FDataType   := 0;
FChannels   := 0;
end;

procedure TSGBitMap.CopyFrom(const VBitMap : TSGBitMap);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Size : TSGMaxEnum;
begin
Clear();
FWidth  := VBitMap.Width;
FHeight := VBitMap.Height;
FChannelSize := VBitMap.BitDepth;
FChannels := VBitMap.Channels;
FFormatType := VBitMap.PixelFormat;
FDataType := VBitMap.PixelType;
if (VBitMap.BitMap <> nil) then
	begin
	Size := VBitMap.DataSize();
	FBitMap := GetMem(Size);
	Move(VBitMap.BitMap^, FBitMap^, Size); 
	end;
end;

constructor TSGBitMap.Create();
begin
inherited;
FBitMap := nil;
Clear();
end;

destructor TSGBitMap.Destroy();
begin
Clear();
inherited;
end;

end.
