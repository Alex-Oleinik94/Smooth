{$INCLUDE Smooth.inc}

//{$DEFINE SIA_DEBUG}

// SIA Image = ['SIA',QuadWordJpegImage1Size,JpegImage1(RGB(3)),QuadWordJpegImage2Size,JpegImage2(Alpha(3))]

unit SmoothImageSIA;

interface

uses
	 SmoothBitMap
	
	,Classes
	;

procedure SaveSIA(const Stream : TStream; var FBitMap : TSBitMap);
procedure LoadSIAToBitMap(const FStream : TStream; var FBitMap : TSBitMap);

implementation

uses
	 SmoothBase
	,SmoothImageJpeg
	,SmoothImageBmp
	,SmoothStreamUtils
	,SmoothBitMapBase
	
	,SysUtils
	;

procedure LoadSIAToBitMap(const FStream : TStream; var FBitMap : TSBitMap);
var
	JpegSize : TSUInt64;
	Stream : TMemoryStream;
	BitMapRGB, BitMapAlpha : TSBitMap;
	i : TSMaxEnum;
begin
if (FBitMap = nil) then FBitMap := TSBitMap.Create() else FBitMap.Clear();
BitMapRGB:=TSBitMap.Create();
BitMapAlpha:=TSBitMap.Create();

FStream.Position:=FStream.Position+3;
FStream.ReadBuffer(JpegSize, SizeOf(JpegSize));

Stream:=TMemoryStream.Create();
SCopyPartStreamToStream(FStream, Stream, JpegSize);
Stream.Position:=0;
SLoadBitMapAsJpegToStream(Stream, BitMapRGB);
Stream.Destroy();

FStream.ReadBuffer(JpegSize, SizeOf(JpegSize));

Stream:=TMemoryStream.Create();
SCopyPartStreamToStream(FStream, Stream, JpegSize);
Stream.Position:=0;
SLoadBitMapAsJpegToStream(Stream, BitMapAlpha);
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

SKill(BitMapRGB);
SKill(BitMapAlpha);
end;

procedure SaveSIA(const Stream : TStream; var FBitMap : TSBitMap);
var
	ImageBitMap : TSBitMap;
	i : TSMaxEnum;
	MemStream2 : TMemoryStream = nil;
	JpegSize : TSUInt64;
begin
if (FBitMap.Channels <> 4) then
	Exit;

{$IFDEF SIA_DEBUG}
	FBitMap.WriteInfo('Total Image: ');
	{$ENDIF}

ImageBitMap:=TSBitMap.Create();
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

{$IFDEF SIA_DEBUG}
	ImageBitMap.WriteInfo('1'' Image: ');
	{$ENDIF}

MemStream2 := TMemoryStream.Create();
SSaveBitMapAsJpegToStream(MemStream2, ImageBitMap);
SKill(ImageBitMap);
SWriteStringToStream('SIA', Stream, False);
JpegSize := MemStream2.Size;
Stream.WriteBuffer(JpegSize, SizeOf(JpegSize));
MemStream2.Position:=0;
MemStream2.SaveToStream(Stream);
SKill(MemStream2);

ImageBitMap:=TSBitMap.Create();
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

{$IFDEF SIA_DEBUG}
	ImageBitMap.WriteInfo('2'' Image: ');
	{$ENDIF}

MemStream2 := TMemoryStream.Create();
SSaveBitMapAsJpegToStream(MemStream2, ImageBitMap);
SKill(ImageBitMap);
JpegSize := MemStream2.Size;
Stream.WriteBuffer(JpegSize, SizeOf(JpegSize));
MemStream2.Position:=0;
MemStream2.SaveToStream(Stream);
SKill(MemStream2);
end;

end.
