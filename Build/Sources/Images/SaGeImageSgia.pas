{$INCLUDE SaGe.inc}

//{$DEFINE SGIA_DEBUG}

// SGIA Image = ['SGIA',QuadWordJpegImage1Size,JpegImage1(RGB(3)),QuadWordJpegImage2Size,JpegImage2(Alpha(3))]

unit SaGeImageSgia;

interface

uses
	 SysUtils
	,Classes
	
	,SaGeBase
	,SaGeImageJpeg
	,SaGeImageBmp
	,SaGeBitMap
	,SaGeStringUtils
	;

procedure SaveSGIA(const Stream:TStream;var FImage:TSGBitMap);
procedure LoadSGIAToBitMap(const FStream:TStream;var FImage:TSGBitMap);

implementation


procedure LoadSGIAToBitMap(const FStream:TStream;var FImage:TSGBitMap);
var
	q : TSGQuadWord;
	Stream:TMemoryStream;
	BitMapRGB,BitMapAlpha:TSGBitMap;
	PBits : PByte;
	i : TSGMaxEnum;
begin
if FImage=nil then
	begin
	FImage:=TSGBitMap.Create();
	end
else
	FImage.Clear();
BitMapRGB:=TSGBitMap.Create();
BitMapAlpha:=TSGBitMap.Create();

FStream.Position:=FStream.Position+4;
FStream.ReadBuffer(q,SizeOf(q));

Stream:=TMemoryStream.Create();
SGCopyPartStreamToStream(FStream, Stream, q);
Stream.Position:=0;
LoadJPEGToBitMap(Stream,BitMapRGB);
Stream.Destroy();

FStream.ReadBuffer(q,SizeOf(q));

Stream:=TMemoryStream.Create();
SGCopyPartStreamToStream(FStream, Stream, q);
Stream.Position:=0;
LoadJPEGToBitMap(Stream,BitMapAlpha);
Stream.Destroy();

FImage.Width:=BitMapRGB.Width;
FImage.Height:=BitMapRGB.Height;
FImage.BitDepth:=8;
FImage.Channels:=4;
GetMem(PBits,4*FImage.Width*FImage.Height);

for i:=0 to FImage.Width*FImage.Height-1 do
	begin
	PBits[4*i+0]:=BitMapRGB.BitMap[BitMapRGB.Channels*i+0];
	PBits[4*i+1]:=BitMapRGB.BitMap[BitMapRGB.Channels*i+1];
	PBits[4*i+2]:=BitMapRGB.BitMap[BitMapRGB.Channels*i+2];
	PBits[4*i+3]:=BitMapAlpha.BitMap[BitMapAlpha.Channels*i];
	end;

FImage.BitMap:=PBits;
BitMapRGB.Destroy();
BitMapAlpha.Destroy();
FImage.CreateTypes();
end;

procedure SaveSGIA(const Stream:TStream;var FImage:TSGBitMap);
var
	ImageBitMap:TSGBitMap;
	PBits : PByte = nil;
	i : TSGMaxEnum;
	MemStream2 : TMemoryStream = nil;
	q : TSGQuadWord;
begin
if FImage.Channels<>4 then
	Exit;

{$IFDEF SGIA_DEBUG}
	FImage.WriteInfo('Total Image: ');
	{$ENDIF}

ImageBitMap:=TSGBitMap.Create();
ImageBitMap.Width:=FImage.Width;
ImageBitMap.Height:=FImage.Height;
ImageBitMap.Channels:=3;
ImageBitMap.BitDepth:=8;

GetMem(PBits,FImage.Width*FImage.Height*3);
ImageBitMap.BitMap:=PBits;
for i:=0 to FImage.Width*FImage.Height-1 do
	begin
	PBits[i*3+0]:=FImage.BitMap[i*4+0];
	PBits[i*3+1]:=FImage.BitMap[i*4+1];
	PBits[i*3+2]:=FImage.BitMap[i*4+2];
	end;

{$IFDEF SGIA_DEBUG}
	ImageBitMap.WriteInfo('1'' Image: ');
	{$ENDIF}

MemStream2 := TMemoryStream.Create();
SaveJPEGFromBitMap(MemStream2,ImageBitMap);
FreeMem(PBits,FImage.Width*FImage.Height*3);
PBits:=nil;
ImageBitMap.BitMap:=nil;
ImageBitMap.Destroy();
SGWriteStringToStream('SGIA',Stream,False);
q := MemStream2.Size;
Stream.WriteBuffer(q,SizeOf(q));
MemStream2.Position:=0;
MemStream2.SaveToStream(Stream);
MemStream2.Destroy();
MemStream2:=nil;


ImageBitMap:=TSGBitMap.Create();
ImageBitMap.Width:=FImage.Width;
ImageBitMap.Height:=FImage.Height;
ImageBitMap.Channels:=3;
ImageBitMap.BitDepth:=8;

GetMem(PBits,FImage.Width*FImage.Height*3);
ImageBitMap.BitMap:=PBits;
for i:=0 to FImage.Width*FImage.Height-1 do
	begin
	PBits[i*3+0]:=FImage.BitMap[i*4+3];
	PBits[i*3+1]:=FImage.BitMap[i*4+3];
	PBits[i*3+2]:=FImage.BitMap[i*4+3];
	end;

{$IFDEF SGIA_DEBUG}
	ImageBitMap.WriteInfo('2'' Image: ');
	{$ENDIF}

MemStream2 := TMemoryStream.Create();
SaveJPEGFromBitMap(MemStream2,ImageBitMap);
FreeMem(PBits,FImage.Width*FImage.Height*3);
PBits:=nil;
ImageBitMap.BitMap:=nil;
ImageBitMap.Destroy();
q := MemStream2.Size;
Stream.WriteBuffer(q,SizeOf(q));
MemStream2.Position:=0;
MemStream2.SaveToStream(Stream);
MemStream2.Destroy();
MemStream2:=nil;
end;

end.
