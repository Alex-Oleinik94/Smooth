{$INCLUDE SaGe.inc}

unit SaGeImageJpeg;

interface

uses
	 Classes
	
	,SaGeBitMap
	;

procedure SGLoadBitMapAsJpegToStream(const _Stream : TStream; const _BitMap : TSGBitMap);
procedure SGSaveBitMapAsJpegToStream(const _Stream : TStream; const _BitMap : TSGBitMap);

implementation

uses
	 pasjpeg
	
	,SaGeBase
	,SaGeImageBmp
	;

procedure SGSaveBitMapAsJpegToStream(const _Stream : TStream; const _BitMap : TSGBitMap);
var
	BmpStream : TMemoryStream = nil;
begin
BmpStream := TMemoryStream.Create();
SaveBMP(_BitMap, BmpStream);
BmpStream.Position := 0;
SaveJPEG(BmpStream, _Stream);
BmpStream.Destroy();
SGKill(BmpStream);
end;

procedure SGLoadBitMapAsJpegToStream(const _Stream : TStream; const _BitMap : TSGBitMap);
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

