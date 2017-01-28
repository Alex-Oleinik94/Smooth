{$INCLUDE SaGe.inc}

unit SaGeImageFormatDeterminer;

interface

uses
	 Classes
	,SaGeBase
	,SaGeBased
	,SaGeImagesBase
	;
type
	TSGImageFormatDeterminer = class
			public
		class function IsBMP(const Stream : TStream) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function IsMBM(const Stream : TStream) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function IsPNG(const Stream : TStream) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function IsJPEG(const Stream : TStream) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function IsSGIA(const Stream : TStream) : TSGBoolean; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function DetermineFormat(const Stream : TStream) : TSGImageFormat; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function DetermineExpansion(const Stream : TStream) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function DetermineExpansionFromFormat(const Format : TSGImageFormat) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

implementation

class function TSGImageFormatDeterminer.DetermineExpansion(const Stream : TStream) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := DetermineExpansionFromFormat(DetermineFormat(Stream));
end;

class function TSGImageFormatDeterminer.DetermineExpansionFromFormat(const Format : TSGImageFormat) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case Format of
SGI_TGA  : Result := 'tga';
SGI_BMP  : Result := 'bmp';
SGI_JPG  : Result := 'jpeg';
SGI_SGIA : Result := 'sgia';
{$IFDEF WITHLIBPNG}
SGI_PNG  : Result := 'png';
{$ENDIF}
else
	Result:='';
end;
end;

class function TSGImageFormatDeterminer.DetermineFormat(const Stream : TStream) : TSGImageFormat; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := 0;
{$IFDEF WITHLIBPNG}
if IsPNG(Stream) then
	Result := SGI_PNG
else
{$ENDIF}
if IsBMP(Stream) then
	Result := SGI_BMP
else if IsMBM(Stream) then
	Result := SGI_MBM
else if IsJPEG(Stream) then
	Result := SGI_JPG
else if IsSGIA(Stream) then
	Result := SGI_SGIA;
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
