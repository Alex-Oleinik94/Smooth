{$INCLUDE Smooth.inc}

unit SmoothMultiImage;

interface

uses
	 SmoothBase
	,SmoothImage
	,SmoothCommonStructs
	,SmoothBitMap
	;

type
	TSMultiImage = class(TSImage)
			public
		constructor Create();
		destructor Destroy();override;
			public
		procedure Add(const VImageIdentifier : TSString;const VImage : TSBitMap;const Color : TSVertex4ui8);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetTexCoord(const VFileName : TSString; const VCoord : TSVertex2f):TSVertex2f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			protected
		FPoints : packed array of
			TSPoint2ui32;
		FImages : packed array of
			packed record
				FFileName : TSString;
				FDestination , FBounds : TSPoint2ui32;
				end;
			protected
		procedure AddImageInfo(const VFileName : TSString; const VX, VY, VWidth, VHeight : TSUInt32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

implementation

constructor TSMultiImage.Create();
begin
inherited;
FPoints := SVertex2uint32Import(0, 0);
FImages := nil;
end;

destructor TSMultiImage.Destroy();
begin
SetLength(FImages, 0);
SetLength(FPoints, 0);
inherited;
end;

function TSMultiImage.GetTexCoord(const VFileName : TSString; const VCoord : TSVertex2f):TSVertex2f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSMaxEnum;
begin
Result.Import(0, 0);
if FImages <> nil then
	if Length(FImages) > 0 then
		for i := 0 to High(FImages) do
			begin
			if FImages[i].FFileName = VFileName then
				begin
				Result.Import(
					(FImages[i].FDestination.x + VCoord.x * FImages[i].FBounds.x) / Width,
					(FImages[i].FDestination.y + VCoord.y * FImages[i].FBounds.y) / Height
					);
				break;
				end;
			end;
end;

procedure TSMultiImage.AddImageInfo(const VFileName : TSString; const VX, VY, VWidth, VHeight : TSUInt32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FImages = nil then
	SetLength(FImages, 1)
else
	SetLength(FImages, Length(FImages) + 1);
FImages[High(FImages)].FFileName := VFileName;
FImages[High(FImages)].FDestination.Import(VX, VY);
FImages[High(FImages)].FBounds.Import(VWidth, VHeight);
end;

procedure TSMultiImage.Add(const VImageIdentifier : TSString;const VImage : TSBitMap;const Color : TSVertex4ui8);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function FindPoint() : TSPoint2ui32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Distance : TSFloat = 100000;
	NowDistance : TSFloat;
	TempPoint : TSPoint2ui32;
begin
for TempPoint in FPoints do
	begin
	NowDistance := Abs(TempPoint);
	if NowDistance < Distance then
		begin
		Distance := NowDistance;
		Result := TempPoint;
		end;
	end;
end;

procedure RecheckPoints();
begin

end;

var
	Point, Point2 : TSPoint2ui32;
begin
if (FBitMap = nil) then
	begin
	FBitMap := TSBitMap.Create();
	FBitMap.CopyFrom(VImage);
	SetLength(FPoints, 0);
	Point.Import(VImage.Width, 0);
	FPoints += Point;
	Point.Import(0, VImage.Height);
	FPoints += Point;
	Point.Import(0,0);
	end
else
	begin
	Point := FindPoint();
	FPoints -= Point;
	FBitMap.ReAllocateForBounds(Max(Width, Point.x + VImage.Width),Max(Height, Point.y + VImage.Height));
	FBitMap.PutImage(VImage, Point.x, Point.y);
	Point2.Import(Point.x + VImage.Width, Point.y);
	FPoints += Point2;
	Point2.Import(Point.x, Point.y + VImage.Height);
	FPoints += Point2;
	RecheckPoints();
	end;
AddImageInfo(VImageIdentifier, Point.x, Point.y, VImage.Width, VImage.Height);
if Color <> SVertex4uint8Import(255,255,255,255) then
	FBitMap.PaintSquare(Color, Point.x, Point.y, VImage.Width, VImage.Height);
end;

end.
