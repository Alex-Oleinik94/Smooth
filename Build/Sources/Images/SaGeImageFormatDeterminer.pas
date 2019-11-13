{$INCLUDE SaGe.inc}

unit SaGeImageFormatDeterminer;

interface

uses
	 Classes
	
	,SaGeBase
	,SaGeBitMap
	;
type
	TSGImageFormat = (SGImageFormatNull,
			// bit map
			// mime-тип "image/bmp"
			// .bmp, .dib или .rle
		SGImageFormatBMP,
			// portable network graphics
			// mime-тип "image/png"
			// .png
		SGImageFormatPNG,
			// Joint Photographic Experts Group
			// mime-тип "image/jpeg"
			// .jpg, .jfif, .jpe или .jpeg
		SGImageFormatJpeg,
			// Truevision TGA
			// mime-типы "image/x-targa" и "image/x-tga"
			// .tga, .tpic, .vda, .vst или .icb
		SGImageFormatTarga,
			// SaGeImageAlpha format (32-bit jpeg with alpha channel)
			// .sgia
		SGImageFormatSaGeImageAlpha,
			// MultiBitMap (Symbian OS image file format. suppored Nokia smartphones);
			// .mbm
		SGImageFormatMBM,
			// Microsoft Windows OS icon
			// mime-типы: "image/vnd.microsoft.icon" и "image/x-icon"
			// .ico
		SGImageFormatICO,
			// Microsoft Windows OS cursors
			// mime-типы: "image/vnd.microsoft.icon" и "image/x-icon"
			// .cur
		SGImageFormatCUR
		);
const
	SGImageFormatJpg = SGImageFormatJpeg;
	SGImageFormatTga = SGImageFormatTarga;
	SGImageFormatSGImageAlpha = SGImageFormatSaGeImageAlpha;
	SGImageFormatSGIA = SGImageFormatSaGeImageAlpha;
type
	TSGImageFormatDeterminer = class
			public
		class function IsICO(const Stream : TStream) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function IsBMP(const Stream : TStream) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function IsMBM(const Stream : TStream) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function IsPNG(const Stream : TStream) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function IsJPEG(const Stream : TStream) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function IsSGIA(const Stream : TStream) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		class function DetermineFormat(const Stream : TStream) : TSGImageFormat; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function DetermineExpansion(const Stream : TStream) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function DetermineExpansionFromFormat(const Format : TSGImageFormat) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

implementation

uses
	 SaGeImageICO
	;

class function TSGImageFormatDeterminer.IsICO(const Stream : TStream) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGIsICOData(Stream);
end;

class function TSGImageFormatDeterminer.DetermineExpansion(const Stream : TStream) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := DetermineExpansionFromFormat(DetermineFormat(Stream));
end;

class function TSGImageFormatDeterminer.DetermineExpansionFromFormat(const Format : TSGImageFormat) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case Format of
SGImageFormatTga  : Result := 'tga';
SGImageFormatBMP  : Result := 'bmp';
SGImageFormatJpeg : Result := 'jpeg';
SGImageFormatSGIA : Result := 'sgia';
SGImageFormatPNG  : Result := 'png';
SGImageFormatICO  : Result := 'ico';
SGImageFormatCUR  : Result := 'cur';
SGImageFormatMBM  : Result := 'mbm';
else Result := '';
end;
end;

class function TSGImageFormatDeterminer.DetermineFormat(const Stream : TStream) : TSGImageFormat; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if IsPNG(Stream) then
	Result := SGImageFormatPNG
else if IsICO(Stream) then
	Result := SGImageFormatICO
else if IsBMP(Stream) then
	Result := SGImageFormatBMP
else if IsMBM(Stream) then
	Result := SGImageFormatMBM
else if IsJPEG(Stream) then
	Result := SGImageFormatJpeg
else if IsSGIA(Stream) then
	Result := SGImageFormatSGIA
else Result := SGImageFormatNull;
end;

class function TSGImageFormatDeterminer.IsPNG(const Stream : TStream):TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	BeginPosition : TSGMaxEnum;
	Temp : array[0..7] of TSGByte;
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

class function TSGImageFormatDeterminer.IsSGIA(const Stream : TStream):TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	BeginPosition : TSGMaxEnum;
	Temp : array[0..3] of TSGByte;
begin
BeginPosition := Stream.Position;
Stream.ReadBuffer(Temp, SizeOf(Temp));
Result:=
	(Temp[0]=$53) and
	(Temp[1]=$47) and
	(Temp[2]=$49) and
	(Temp[3]=$41);
Stream.Position := BeginPosition;
end;

class function TSGImageFormatDeterminer.IsJPEG(const Stream : TStream):TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	BeginPosition : TSGMaxEnum;
	Temp : array[0..2] of TSGByte;
begin
BeginPosition := Stream.Position;
Stream.ReadBuffer(Temp, SizeOf(Temp));
Result:=
    (Temp[0]=$FF) and
	(Temp[1]=$D8) and
	(Temp[2]=$FF);
Stream.Position := BeginPosition;
end;

class function TSGImageFormatDeterminer.IsMBM(const Stream : TStream):TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	BeginPosition : TSGMaxEnum;
	Temp : array[0..3] of TSGByte;
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

class function TSGImageFormatDeterminer.IsBMP(const Stream : TStream):TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	BeginPosition : TSGMaxEnum;
	Temp : array[0..1] of TSGByte;
begin
BeginPosition := Stream.Position;
Stream.ReadBuffer(Temp, SizeOf(Temp));
Result:=
	(Temp[0]=66) and
	(Temp[1]=77);
Stream.Position := BeginPosition;
end;

end.
