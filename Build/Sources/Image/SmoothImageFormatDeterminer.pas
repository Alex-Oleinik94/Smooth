{$INCLUDE Smooth.inc}

unit SmoothImageFormatDeterminer;

interface

uses
	 Classes
	
	,SmoothBase
	,SmoothBitMap
	;
type
	TSImageFormat = (SImageFormatNull,
			// bit map
			// mime-тип "image/bmp"
			// .bmp, .dib или .rle
		SImageFormatBMP,
			// portable network graphics
			// mime-тип "image/png"
			// .png
		SImageFormatPNG,
			// Joint Photographic Experts Group
			// mime-тип "image/jpeg"
			// .jpg, .jfif, .jpe или .jpeg
		SImageFormatJpeg,
			// Truevision TGA
			// mime-типы "image/x-targa" и "image/x-tga"
			// .tga, .tpic, .vda, .vst или .icb
		SImageFormatTarga,
			// SmoothImageAlpha format (32-bit jpeg with alpha channel)
			// .sia
		SImageFormatSmoothImageAlpha,
			// MultiBitMap (Symbian OS image file format. suppored Nokia smartphones);
			// .mbm
		SImageFormatMBM,
			// Microsoft Windows OS icon
			// mime-типы: "image/vnd.microsoft.icon" и "image/x-icon"
			// .ico
		SImageFormatICO,
			// Microsoft Windows OS cursors
			// mime-типы: "image/vnd.microsoft.icon" и "image/x-icon"
			// .cur
		SImageFormatCUR
		);
const
	SImageFormatJpg = SImageFormatJpeg;
	SImageFormatTga = SImageFormatTarga;
	SImageFormatSImageAlpha = SImageFormatSmoothImageAlpha;
	SImageFormatSIA = SImageFormatSmoothImageAlpha;
type
	TSImageFormatDeterminer = class
			public
		class function IsICO(const Stream : TStream) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function IsBMP(const Stream : TStream) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function IsMBM(const Stream : TStream) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function IsPNG(const Stream : TStream) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function IsJPEG(const Stream : TStream) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function IsSIA(const Stream : TStream) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		class function DetermineFormat(const Stream : TStream) : TSImageFormat; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function DetermineExpansion(const Stream : TStream) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function DetermineExpansionFromFormat(const Format : TSImageFormat) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

implementation

uses
	 SmoothImageICO
	;

class function TSImageFormatDeterminer.IsICO(const Stream : TStream) : TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SIsICOData(Stream);
end;

class function TSImageFormatDeterminer.DetermineExpansion(const Stream : TStream) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := DetermineExpansionFromFormat(DetermineFormat(Stream));
end;

class function TSImageFormatDeterminer.DetermineExpansionFromFormat(const Format : TSImageFormat) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case Format of
SImageFormatTga  : Result := 'tga';
SImageFormatBMP  : Result := 'bmp';
SImageFormatJpeg : Result := 'jpeg';
SImageFormatSIA : Result := 'sia';
SImageFormatPNG  : Result := 'png';
SImageFormatICO  : Result := 'ico';
SImageFormatCUR  : Result := 'cur';
SImageFormatMBM  : Result := 'mbm';
else Result := '';
end;
end;

class function TSImageFormatDeterminer.DetermineFormat(const Stream : TStream) : TSImageFormat; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SImageFormatNull;
if (Stream.Size = 0) then
	Exit
else if IsPNG(Stream) then
	Result := SImageFormatPNG
else if IsICO(Stream) then
	Result := SImageFormatICO
else if IsBMP(Stream) then
	Result := SImageFormatBMP
else if IsMBM(Stream) then
	Result := SImageFormatMBM
else if IsJPEG(Stream) then
	Result := SImageFormatJpeg
else if IsSIA(Stream) then
	Result := SImageFormatSIA;
end;

class function TSImageFormatDeterminer.IsPNG(const Stream : TStream):TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	BeginPosition : TSMaxEnum;
	Temp : array[0..7] of TSByte;
begin
BeginPosition := Stream.Position;
Stream.ReadBuffer(Temp, SizeOf(Temp));
Result:=
	(Temp[0]=$89) and
	(Temp[1]=$50) and
	(Temp[2]=$4E) and
	(Temp[3]=$47) and
	(Temp[4]=$0D) and
	(Temp[5]=$0A) and
	(Temp[6]=$1A) and
	(Temp[7]=$0A);
Stream.Position := BeginPosition;
end;

class function TSImageFormatDeterminer.IsSIA(const Stream : TStream):TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	BeginPosition : TSMaxEnum;
	Temp : array[0..2] of TSByte;
begin
BeginPosition := Stream.Position;
Stream.ReadBuffer(Temp, SizeOf(Temp));
Result:=
	(Temp[0]=$53) and
	(Temp[1]=$49) and
	(Temp[2]=$41);
Stream.Position := BeginPosition;
end;

class function TSImageFormatDeterminer.IsJPEG(const Stream : TStream):TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	BeginPosition : TSMaxEnum;
	Temp : array[0..2] of TSByte;
begin
BeginPosition := Stream.Position;
Stream.ReadBuffer(Temp, SizeOf(Temp));
Result:=
    (Temp[0]=$FF) and
	(Temp[1]=$D8) and
	(Temp[2]=$FF);
Stream.Position := BeginPosition;
end;

class function TSImageFormatDeterminer.IsMBM(const Stream : TStream):TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	BeginPosition : TSMaxEnum;
	Temp : array[0..3] of TSByte;
begin
BeginPosition := Stream.Position;
Stream.ReadBuffer(Temp, SizeOf(Temp));
Result:=
	(Temp[0]=$37) and
	(Temp[1]=$0) and
	(Temp[2]=$0) and
	(Temp[3]=$10);
Stream.Position := BeginPosition;
end;

class function TSImageFormatDeterminer.IsBMP(const Stream : TStream):TSBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	BeginPosition : TSMaxEnum;
	Temp : array[0..1] of TSByte;
begin
BeginPosition := Stream.Position;
Stream.ReadBuffer(Temp, SizeOf(Temp));
Result:=
	(Temp[0]=66) and
	(Temp[1]=77);
Stream.Position := BeginPosition;
end;

end.
