{$INCLUDE SaGe.inc}

unit SaGeMultiImage;

interface

uses
	 SaGeBase
	,SaGeImage
	,SaGeCommonStructs
	,SaGeBitMap
	;

type
	TSGMultiImage = class(TSGImage)
			public
		constructor Create();
		destructor Destroy();override;
			public
		procedure Add(const VImageIdentifier : TSGString;const VImage : TSGBitMap;const Color : TSGVertex4ui8);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetTexCoord(const VFileName : TSGString; const VCoord : TSGVertex2f):TSGVertex2f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			protected
		FPoints : packed array of
			TSGPoint2ui32;
		FImages : packed array of
			packed record
				FFileName : TSGString;
				FDestination , FBounds : TSGPoint2ui32;
				end;
			protected
		procedure AddImageInfo(const VFileName : TSGString; const VX, VY, VWidth, VHeight : TSGUInt32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

implementation

constructor TSGMultiImage.Create();
begin
inherited;
FPoints := SGVertex2uint32Import(0, 0);
FImages := nil;
end;

destructor TSGMultiImage.Destroy();
begin
SetLength(FImages, 0);
SetLength(FPoints, 0);
inherited;
end;

function TSGMultiImage.GetTexCoord(const VFileName : TSGString; const VCoord : TSGVertex2f):TSGVertex2f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGMaxEnum;
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

procedure TSGMultiImage.AddImageInfo(const VFileName : TSGString; const VX, VY, VWidth, VHeight : TSGUInt32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FImages = nil then
	SetLength(FImages, 1)
else
	SetLength(FImages, Length(FImages) + 1);
FImages[High(FImages)].FFileName := VFileName;
FImages[High(FImages)].FDestination.Import(VX, VY);
FImages[High(FImages)].FBounds.Import(VWidth, VHeight);
end;

procedure TSGMultiImage.Add(const VImageIdentifier : TSGString;const VImage : TSGBitMap;const Color : TSGVertex4ui8);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function FindPoint() : TSGPoint2ui32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Distance : TSGFloat = 100000;
	NowDistance : TSGFloat;
	TempPoint : TSGPoint2ui32;
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
	Point, Point2 : TSGPoint2ui32;
begin
if FImage = nil then
	begin
	FImage := TSGBitMap.Create();
	FImage.CopyFrom(VImage);
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
	Image.ReAllocateForBounds(Max(Width, Point.x + VImage.Width),Max(Height, Point.y + VImage.Height));
	Image.PutImage(VImage, Point.x, Point.y);
	Point2.Import(Point.x + VImage.Width, Point.y);
	FPoints += Point2;
	Point2.Import(Point.x, Point.y + VImage.Height);
	FPoints += Point2;
	RecheckPoints();
	end;
AddImageInfo(VImageIdentifier, Point.x, Point.y, VImage.Width, VImage.Height);
if Color <> SGVertex4uint8Import(255,255,255,255) then
	Image.PaintSquare(Color, Point.x, Point.y, VImage.Width, VImage.Height);
end;

end.
