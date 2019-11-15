{$INCLUDE SaGe.inc}

unit SaGeBitMapBase;

interface

uses
	 SaGeBase
	,SaGeCommonStructs
	;
type
	PSGPixel3b = PSGVertex3ui8;
	TSGPixel3b = TSGVertex3ui8;
	
	PSGPixel4b = PSGVertex4ui8;
	TSGPixel4b = TSGVertex4ui8;
	
	TSGBitMapInt = TSGInt32;
	TSGBitMapUInt = TSGUInt32;
	
	TSGPixelInfo = object
		FArray : packed array of 
			packed record 
				FProcent : TSGFloat64;
				FIdentifity : TSGUInt32;
				end;
		procedure Get(const Old, New, Position : TSGUInt32); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Clear; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

operator = (const a,b:TSGPixel3b):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (const a:TSGPixel3b; const b:Real):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator + (const a,b:TSGPixel3b):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator not (const a:TSGPixel3b):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGConvertPixelRGBToAlpha(const P : TSGPixel4b) : TSGPixel4b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGMultPixel4b(const Pixel1, Pixel2 : TSGPixel4b):TSGPixel4b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGBGRAToRGBAPixel(const _Pixel : TSGPixel4b) : TSGPixel4b;

implementation

uses
	 SaGeMathUtils
	;

function SGBGRAToRGBAPixel(const _Pixel : TSGPixel4b) : TSGPixel4b;
begin
Result := _Pixel;
Result.r := _Pixel.b;
Result.b := _Pixel.r;
end;

function SGMultPixel4b(const Pixel1, Pixel2 : TSGPixel4b):TSGPixel4b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure MultByte(var a : TSGByte; const b : TSGByte);
begin
if a > b then
	a := b;
end;

begin
Result := Pixel1;
MultByte(Result.x, Pixel2.x);
MultByte(Result.y, Pixel2.y);
MultByte(Result.z, Pixel2.z);
MultByte(Result.w, Pixel2.w);
end;

function SGConvertPixelRGBToAlpha(const P : TSGPixel4b) : TSGPixel4b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	max : byte;
	s : single;
begin
Result := P;
if (Result.r >= Result.b) and (Result.r >= Result.g) then
	max := Result.r
else if (Result.b >= Result.r) and (Result.b >= Result.g) then
	max := Result.b
else
	max := Result.g;
if max = 0 then
	Result.a := 0
else
	begin
	s := 255/max;
	Result.r := trunc(s * Result.r);
	Result.g := trunc(s * Result.g);
	Result.b := trunc(s * Result.b);
	Result.a := max;
	end;
end;

operator not (const a:TSGPixel3b):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(255-a.r,255-a.g,255-a.b);
end;

operator + (const a,b:TSGPixel3b):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(
	SGTruncUp((a.r+b.r)/2),
	SGTruncUp((a.g+b.g)/2),
	SGTruncUp((a.b+b.b)/2));
end;

operator * (const a:TSGPixel3b; const b:Real):TSGPixel3b;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(SGTruncUp(a.r*b),SGTruncUp(a.g*b),SGTruncUp(a.b*b));
end;

operator = (const a,b:TSGPixel3b):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin 
Result:=(a.r=b.r) and (a.g=b.g) and (a.b=b.b);
end;

procedure TSGPixelInfo.Clear;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetLength(FArray,0);
FArray:=nil;
end;

procedure TSGPixelInfo.Get(const Old,New,Position:LongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
// Old - Old Width; 
// New - New Width;
// Position - i
var
	a,b:LongWord;
	c,// c - 1st position
	d,// d - 2nd position
	e
		:single;
	i:Word;
begin
SetLength(FArray,0);
a:=Position;
b:=a+1;
c:=(a/New)*Old;
d:=(b/New)*Old;
while abs(d-c)>0.001 do
	begin
	SetLength(FArray,Length(FArray)+1);
	FArray[High(FArray)].FProcent:=0;
	FArray[High(FArray)].FIdentifity:=0;
	
	if Trunc(c)=Trunc(d) then
		begin
		FArray[High(FArray)].FProcent:=Abs(d-c);
		FArray[High(FArray)].FIdentifity:=Trunc(c);
		c:=d;
		end
	else
		begin
		e:=Trunc(c)+1;
		FArray[High(FArray)].FProcent:=Abs(e-c);
		FArray[High(FArray)].FIdentifity:=Trunc(c);
		c:=e;
		end;
	end;
e:=0;
i:=0;
while i<=High(FArray) do
	begin
	e+=FArray[i].FProcent;
	Inc(i);
	end;
i:=0;
while i<=High(FArray) do
	begin
	FArray[i].FProcent:=FArray[i].FProcent/e;
	Inc(i);
	end;
end;

end.
