{$INCLUDE Smooth.inc}

unit SmoothComplex;

interface

uses
	 SmoothBase
	,SmoothCommonStructs
	;

type
	TSComplexNumber = TSVector2d;

operator + (const a,b:TSComplexNumber):TSComplexNumber;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (const a,b:TSComplexNumber):TSComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const a,b:TSComplexNumber):TSComplexNumber;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator / (const a,b:TSComplexNumber):TSComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator ** (const a:TSComplexNumber;const b:LongInt):TSComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator = (const a,b:TSComplexNumber):Boolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

operator = (const a,b:TSComplexNumber):Boolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=(a.x=b.x) and (b.y=a.y);
end;

operator - (const a,b:TSComplexNumber):TSComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(a.x-b.x,a.y-b.y);
end;

operator / (const a,b:TSComplexNumber):TSComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(
	(a.x*b.x+a.y*b.y)/(b.x*b.x-b.y*b.y),
	(a.y*b.x-a.x*b.y)/(b.x*b.x-b.y*b.y));
end;

operator * (const a,b:TSComplexNumber):TSComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
result.Import(a.x*b.x-a.y*b.y,a.x*b.y+b.x*a.y);
end;

operator + (const a,b:TSComplexNumber):TSComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(a.x+b.x,a.y+b.y);
end;

operator ** (const a:TSComplexNumber;const b:LongInt):TSComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i:LongInt;
begin
Result.Import(1,0);
for i:=1 to b do
	Result*=a;
end;

end.
