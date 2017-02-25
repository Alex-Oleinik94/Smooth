{$INCLUDE SaGe.inc}

unit SaGeCursor;

interface

uses
	 SaGeBase
	,SaGeImagesBase
	,SaGeCommon
	;

type
	TSGCursorHandle = type TSGUInt32;

const
	SGC_NULL = 0;
	SGC_APPSTARTING = 32650;
	SGC_NORMAL = 32512;
	SGC_CROSS = 32515;
	SGC_HAND = 32649;
	SGC_HELP = 32651;
	SGC_IBEAM = 32513;
	SGC_NO = 32648;
	SGC_SIZEALL = 32646;
	SGC_SIZENESW = 32643;
	SGC_SIZENS = 32645;
	SGC_SIZENWSE = 32642;
	SGC_SIZEWE = 32644;
	SGC_UP = 32516;
	SGC_WAIT = 32514;
	SGC_GLASSY = 20000;

type
	TSGHotPixelType = TSGLongInt;

	TSGCursor = class(TSGBitMap)
			public
		constructor Create(const VStandartCursor : TSGCursorHandle = SGC_NULL);virtual;
		function LoadFrom(const VFileName : TSGString; const HotX : TSGFloat = 0; const HotY : TSGFloat = 0):TSGCursor;virtual;
		class function Copy(const VCursor : TSGCursor):TSGCursor;
		procedure CopyFrom(const VCursor : TSGCursor);
			private
		FHotPixel : TSGPoint2int32;
		FStandartCursor : TSGCursorHandle;
			public
		property HotPixelX : TSGHotPixelType read FHotPixel.x write FHotPixel.x;
		property HotPixelY : TSGHotPixelType read FHotPixel.y write FHotPixel.y;
		property StandartHandle : TSGCursorHandle read FStandartCursor;
		end;

implementation

uses
	 SaGeImages
	;

procedure TSGCursor.CopyFrom(const VCursor : TSGCursor);
begin
(Self as TSGBitMap).CopyFrom(VCursor as TSGBitMap);
FHotPixel       := VCursor.FHotPixel;
FStandartCursor := VCursor.FStandartCursor;
end;

class function TSGCursor.Copy(const VCursor : TSGCursor):TSGCursor;
begin
Result := TSGCursor.Create();
Result.CopyFrom(VCursor);
end;

function TSGCursor.LoadFrom(const VFileName : TSGString; const HotX : TSGFloat = 0; const HotY : TSGFloat = 0):TSGCursor;
var
	Image : TSGImage;
begin
Image := TSGImage.Create(VFileName);
Image.Loading();

(Self as TSGBitMap).CopyFrom(Image.Image);
HotPixelX := Trunc(HotX * Width );
HotPixelY := Trunc(HotY * Height);

Image.Destroy();
Image := nil;

Result := Self;
end;

constructor TSGCursor.Create(const VStandartCursor : TSGCursorHandle = SGC_NULL);
begin
inherited Create();
FHotPixel.Import(0, 0);
FStandartCursor := VStandartCursor;
end;

end.
