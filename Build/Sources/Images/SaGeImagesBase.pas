{$INCLUDE SaGe.inc}

//{$DEFINE SG_IMAGES_DEBUG}

unit SaGeImagesBase;

interface

uses 
	 Crt
	
	,SaGeBase
	,SaGeRenderConstants
	,SaGeResourceManager
	,SaGeCommon
	;
type
	TSGImageByte = type TSGByte;
	TSGIByte = TSGImageByte;
	TSGImageFormat = TSGUInt32;
const 
	SGI_NONE =              $00000000;
	SGI_LOADING =           $00000001;
	SGI_LOAD = SGI_LOADING;
	SGI_SAVE =              $00000002;
	SGI_SAVEING = SGI_SAVE;
	SGI_BMP =               $00000003;
	SGI_SAVEING_COMPLITE =  $00000004;
	SGI_SAVE_COMPLITE =  SGI_SAVEING_COMPLITE;
	{$IFDEF WITHLIBPNG}
		SGI_PNG =           $00000005;
		{$ENDIF}
	SGI_JPG =               $00000006;
	SGI_JPEG = SGI_JPG;
	SGI_TGA =               $00000007;
	SGI_TARGA =             SGI_TGA;
	SGI_SGIA =              $00000008;
	SGI_DEFAULT =           $00000009;
	SGI_MBM  =              $00000010;
type
	PSGPixel3b = PSGVertex3ui8;
	TSGPixel3b = TSGVertex3ui8;
	
	PSGPixel4b = PSGVertex4ui8;
	TSGPixel4b = TSGVertex4ui8;
	
	TSGBitMapInt = TSGInt32;
	TSGBitMapUInt = TSGUInt32;
	
	TSGPixelInfo = object
		FArray : packed array of 
			packed record 
				FProcent:real;
				FIdentifity:LongWord;
				end;
		procedure Get(const Old,New,Position:LongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Clear;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;
	
	TSGBitMap = class(TSGResource)
			public
		constructor Create();override;
		destructor Destroy();override;
			protected
		FBitMap : PSGByte;
		
		FWidth  : TSGBitMapUInt;
		FHeight : TSGBitMapUInt;
		
		FChannels    : TSGBitMapUInt;
		FSizeChannel : TSGBitMapUInt;
		
		FFormatType : TSGBitMapUInt;
		FDataType   : TSGBitMapUInt;
			public
		procedure Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ClearBitMapBits();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure CopyFrom(const VBitMap : TSGBitMap);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure WriteInfo(const PredStr : TSGString = '');
		procedure ReAllocateMemory();
			public
		procedure CreateTypes(const Alpha:TSGBitMapUInt = SG_UNKNOWN;const Grayscale:TSGBitMapUInt = SG_UNKNOWN);
		function PixelsRGBA(const x,y:TSGBitMapUInt):PSGPixel4b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure PutImage(const VImage : TSGBitMap; const VX, VY : TSGBitMapUInt);
		procedure PaintSquare(const VColor : TSGPixel4b;  const VX, VY, VWidth, VHeight : TSGBitMapUInt);
			public
		procedure ReAllocateForBounds(const NewWidth, NewHeight : TSGBitMapUInt);
		procedure SetWidth(const NewWidth:TSGBitMapUInt);
		procedure SetHeight(const NewHeight:TSGBitMapUInt);
		procedure SetBounds(const NewWidth,NewHeight:TSGBitMapUInt);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetBounds(const NewBound:TSGBitMapUInt);overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property Width       : TSGBitMapUInt read FWidth       write FWidth;
		property Height      : TSGBitMapUInt read FHeight      write FHeight;
		property Channels    : TSGBitMapUInt read FChannels    write FChannels;
		property BitDepth    : TSGBitMapUInt read FSizeChannel write FSizeChannel;
		property SizeChannel : TSGBitMapUInt read FSizeChannel write FSizeChannel;
		property PixelFormat : TSGBitMapUInt read FFormatType  write FFormatType;
		property PixelType   : TSGBitMapUInt read FDataType    write FDataType;
		property BitMap      : PSGByte       read FBitMap      write FBitMap;
		end;

operator = (const a,b:TSGPixel3b):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (const a:TSGPixel3b; const b:Real):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator + (const a,b:TSGPixel3b):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator not (const a:TSGPixel3b):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGConvertPixelRGBToAlpha(const P : TSGPixel4b) : TSGPixel4b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGMultPixel4b(const Pixel1, Pixel2 : TSGPixel4b):TSGPixel4b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeStringUtils
	,SaGeMathUtils
	;

function SGMultPixel4b(const Pixel1, Pixel2 : TSGPixel4b):TSGPixel4b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure MultByte(var a : TSGByte; const b : TSGByte);
begin
if a > b then
	a := b;
end;

begin
Result := Pixel1;
MultByte(Result.x, Pixel2.x);
MultByte(Result.y, Pixel2.y);
MultByte(Result.z, Pixel2.z);
MultByte(Result.w, Pixel2.w);
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

function SGConvertPixelRGBToAlpha(const P : TSGPixel4b) : TSGPixel4b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	max : byte;
	s : single;
begin
Result := P;
if (Result.r >= Result.b) and (Result.r >= Result.g) then
	max := Result.r
else if (Result.b >= Result.r) and (Result.b >= Result.g) then
	max := Result.b
else
	max := Result.g;
if max = 0 then
	Result.a := 0
else
	begin
	s := 255/max;
	Result.r := trunc(s * Result.r);
	Result.g := trunc(s * Result.g);
	Result.b := trunc(s * Result.b);
	Result.a := max;
	end;
end;

function TSGBitMap.PixelsRGBA(const x,y:LongWord):PSGPixel4b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := @PSGPixel4b(FBitMap)[y* FWidth + x];
end;

operator not (const a:TSGPixel3b):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(255-a.r,255-a.g,255-a.b);
end;

operator + (const a,b:TSGPixel3b):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(
	SGTruncUp((a.r+b.r)/2),
	SGTruncUp((a.g+b.g)/2),
	SGTruncUp((a.b+b.b)/2));
end;

operator * (const a:TSGPixel3b; const b:Real):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(SGTruncUp(a.r*b),SGTruncUp(a.g*b),SGTruncUp(a.b*b));
end;

operator = (const a,b:TSGPixel3b):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin 
Result:=(a.r=b.r) and (a.g=b.g) and (a.b=b.b);
end;

procedure TSGPixelInfo.Clear;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetLength(FArray,0);
FArray:=nil;
end;

procedure TSGPixelInfo.Get(const Old,New,Position:LongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
// Old - Old Width; 
// New - New Width;
// Position - i
var
	a,b:LongWord;
	c,// c - 1st position
	d,// d - 2nd position
	e
		:single;
	i:Word;
begin
SetLength(FArray,0);
a:=Position;
b:=a+1;
c:=(a/New)*Old;
d:=(b/New)*Old;
while abs(d-c)>0.001 do
	begin
	SetLength(FArray,Length(FArray)+1);
	FArray[High(FArray)].FProcent:=0;
	FArray[High(FArray)].FIdentifity:=0;
	
	if Trunc(c)=Trunc(d) then
		begin
		FArray[High(FArray)].FProcent:=Abs(d-c);
		FArray[High(FArray)].FIdentifity:=Trunc(c);
		c:=d;
		end
	else
		begin
		e:=Trunc(c)+1;
		FArray[High(FArray)].FProcent:=Abs(e-c);
		FArray[High(FArray)].FIdentifity:=Trunc(c);
		c:=e;
		end;
	end;
e:=0;
i:=0;
while i<=High(FArray) do
	begin
	e+=FArray[i].FProcent;
	Inc(i);
	end;
i:=0;
while i<=High(FArray) do
	begin
	FArray[i].FProcent:=FArray[i].FProcent/e;
	Inc(i);
	end;
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

case FChannels*FSizeChannel of
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

case FChannels*FSizeChannel of
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

procedure TSGBitMap.WriteInfo(const PredStr : TSGString = '');
begin
WriteLn('TSGBitMap__WriteInfo()');
WriteLn(PredStr,' Width    = ',FWidth);
WriteLn(PredStr,' Height   = ',FHeight);
WriteLn(PredStr,' Channels = ',FChannels);
WriteLn(PredStr,' BitDepth = ',FSizeChannel);
TextColor(15);
WriteLn(PredStr,' Size     = ',SGGetSizeString(FWidth*FHeight*FChannels*FSizeChannel div 8,'EN'));
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
case FSizeChannel of
8:
	FDataType:=SGR_UNSIGNED_BYTE;
else
	FDataType:=SGR_BITMAP;
end;
end;

procedure TSGBitMap.ReAllocateMemory();
begin
ClearBitMapBits();
GetMem(FBitMap, Width * Height * Channels);
fillchar(FBitMap^, Width * Height * Channels, 0);
end;

procedure TSGBitMap.ClearBitMapBits();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FBitMap <> nil then
	begin
	FreeMem(FBitMap);
	FBitMap := nil;
	end;
end;

procedure TSGBitMap.Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
ClearBitMapBits();
FWidth      := 0;
FHeight     := 0;
FSizeChannel:= 0;
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
FSizeChannel := VBitMap.BitDepth;
FChannels := VBitMap.Channels;
FFormatType := VBitMap.PixelFormat;
FDataType := VBitMap.PixelType;
if VBitMap.BitMap <> nil then
	begin
	Size := Width * Height * Channels;
	FBitMap := GetMem(Size);
	Move(VBitMap.BitMap^, FBitMap^, Size); 
	end;
end;

constructor TSGBitMap.Create();
begin
inherited;
FBitMap:=nil;
Clear();
end;

destructor TSGBitMap.Destroy();
begin
Clear();
inherited;
end;

end.
