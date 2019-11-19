{$INCLUDE SaGe.inc}

//{$DEFINE SGIA_DEBUG}

// SGIA Image = ['SGIA',QuadWordJpegImage1Size,JpegImage1(RGB(3)),QuadWordJpegImage2Size,JpegImage2(Alpha(3))]

unit SaGeImageSGIA;

interface

uses
	 SaGeBitMap
	
	,Classes
	;

procedure SaveSGIA(const Stream : TStream; var FBitMap : TSGBitMap);
procedure LoadSGIAToBitMap(const FStream : TStream; var FBitMap : TSGBitMap);

implementation

uses
	 SaGeBase
	,SaGeImageJpeg
	,SaGeImageBmp
	,SaGeStreamUtils
	,SaGeBitMapBase
	
	,SysUtils
	;

procedure LoadSGIAToBitMap(const FStream : TStream; var FBitMap : TSGBitMap);
var
	JpegSize : TSGUInt64;
	Stream : TMemoryStream;
	BitMapRGB, BitMapAlpha : TSGBitMap;
	i : TSGMaxEnum;
begin
if (FBitMap = nil) then FBitMap := TSGBitMap.Create() else FBitMap.Clear();
BitMapRGB:=TSGBitMap.Create();
BitMapAlpha:=TSGBitMap.Create();

FStream.Position:=FStream.Position+4;
FStream.ReadBuffer(JpegSize, SizeOf(JpegSize));

Stream:=TMemoryStream.Create();
SGCopyPartStreamToStream(FStream, Stream, JpegSize);
Stream.Position:=0;
LoadJPEGToBitMap(Stream,BitMapRGB);
Stream.Destroy();

FStream.ReadBuffer(JpegSize, SizeOf(JpegSize));

Stream:=TMemoryStream.Create();
SGCopyPartStreamToStream(FStream, Stream, JpegSize);
Stream.Position:=0;
LoadJPEGToBitMap(Stream,BitMapAlpha);
Stream.Destroy();

FBitMap.Width:=BitMapRGB.Width;
FBitMap.Height:=BitMapRGB.Height;
FBitMap.ChannelSize:=8;
FBitMap.Channels:=4;
FBitMap.ReAllocateMemory();

for i:=0 to FBitMap.Width*FBitMap.Height-1 do
	begin
	FBitMap.Data[4*i+0]:=BitMapRGB.Data[BitMapRGB.Channels*i+0];
	FBitMap.Data[4*i+1]:=BitMapRGB.Data[BitMapRGB.Channels*i+1];
	FBitMap.Data[4*i+2]:=BitMapRGB.Data[BitMapRGB.Channels*i+2];
	FBitMap.Data[4*i+3]:=BitMapAlpha.Data[BitMapAlpha.Channels*i];
	end;

SGKill(BitMapRGB);
SGKill(BitMapAlpha);
end;

procedure SaveSGIA(const Stream : TStream; var FBitMap : TSGBitMap);
var
	ImageBitMap : TSGBitMap;
	i : TSGMaxEnum;
	MemStream2 : TMemoryStream = nil;
	JpegSize : TSGUInt64;
begin
if (FBitMap.Channels <> 4) then
	Exit;

{$IFDEF SGIA_DEBUG}
	FBitMap.WriteInfo('Total Image: ');
	{$ENDIF}

ImageBitMap:=TSGBitMap.Create();
ImageBitMap.Width:=FBitMap.Width;
ImageBitMap.Height:=FBitMap.Height;
ImageBitMap.Channels:=3;
ImageBitMap.ChannelSize:=8;
ImageBitMap.ReAllocateMemory();

for i:=0 to FBitMap.Width*FBitMap.Height-1 do
	begin
	ImageBitMap.Data[i*3+0]:=FBitMap.Data[i*4+0];
	ImageBitMap.Data[i*3+1]:=FBitMap.Data[i*4+1];
	ImageBitMap.Data[i*3+2]:=FBitMap.Data[i*4+2];
	end;

{$IFDEF SGIA_DEBUG}
	ImageBitMap.WriteInfo('1'' Image: ');
	{$ENDIF}

MemStream2 := TMemoryStream.Create();
SaveJPEGFromBitMap(MemStream2,ImageBitMap);
SGKill(ImageBitMap);
SGWriteStringToStream('SGIA', Stream, False);
JpegSize := MemStream2.Size;
Stream.WriteBuffer(JpegSize, SizeOf(JpegSize));
MemStream2.Position:=0;
MemStream2.SaveToStream(Stream);
SGKill(MemStream2);

ImageBitMap:=TSGBitMap.Create();
ImageBitMap.Width := FBitMap.Width;
ImageBitMap.Height := FBitMap.Height;
ImageBitMap.Channels := 3;
ImageBitMap.ChannelSize := 8;
ImageBitMap.ReAllocateMemory();

for i:=0 to FBitMap.Width*FBitMap.Height-1 do
	begin
	ImageBitMap.Data[i*3+0]:=FBitMap.Data[i*4+3];
	ImageBitMap.Data[i*3+1]:=FBitMap.Data[i*4+3];
	ImageBitMap.Data[i*3+2]:=FBitMap.Data[i*4+3];
	end;

{$IFDEF SGIA_DEBUG}
	ImageBitMap.WriteInfo('2'' Image: ');
	{$ENDIF}

MemStream2 := TMemoryStream.Create();
SaveJPEGFromBitMap(MemStream2,ImageBitMap);
SGKill(ImageBitMap);
JpegSize := MemStream2.Size;
Stream.WriteBuffer(JpegSize, SizeOf(JpegSize));
MemStream2.Position:=0;
MemStream2.SaveToStream(Stream);
SGKill(MemStream2);
end;

end.
