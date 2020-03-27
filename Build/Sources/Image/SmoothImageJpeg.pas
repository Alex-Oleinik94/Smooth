{$INCLUDE Smooth.inc}

unit SmoothImageJpeg;

interface

uses
	 Classes
	
	,SmoothBitMap
	;

procedure SLoadBitMapAsJpegToStream(const _Stream : TStream; const _BitMap : TSBitMap);
procedure SSaveBitMapAsJpegToStream(const _Stream : TStream; const _BitMap : TSBitMap);

implementation

uses
	 pasjpeg
	
	,SmoothBase
	,SmoothImageBmp
	;

procedure SSaveBitMapAsJpegToStream(const _Stream : TStream; const _BitMap : TSBitMap);
var
	BmpStream : TMemoryStream = nil;
begin
BmpStream := TMemoryStream.Create();
SaveBMP(_BitMap, BmpStream);
BmpStream.Position := 0;
SaveJPEG(BmpStream, _Stream);
BmpStream.Destroy();
SKill(BmpStream);
end;

procedure SLoadBitMapAsJpegToStream(const _Stream : TStream; const _BitMap : TSBitMap);
var
	Stream : TMemoryStream = nil;
begin
Stream := TMemoryStream.Create();
LoadJPEG(_Stream, Stream, True, 0, nil);
Stream.Position := 0;
LoadBMP(Stream, _BitMap);
Stream.Destroy();
end;

end.

