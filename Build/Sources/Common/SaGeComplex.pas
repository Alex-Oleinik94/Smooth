{$INCLUDE SaGe.inc}

unit SaGeComplex;

interface

uses
	 SaGeBase
	,SaGeCommon
	;

type
	TSGComplexNumber = object(TSGVertex2f)
		end;

operator + (const a,b:TSGComplexNumber):TSGComplexNumber;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (const a,b:TSGComplexNumber):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const a,b:TSGComplexNumber):TSGComplexNumber;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator / (const a,b:TSGComplexNumber):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator ** (const a:TSGComplexNumber;const b:LongInt):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator = (const a,b:TSGComplexNumber):Boolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGComplexNumberImport(const x:real = 0;const y:real = 0):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

operator = (const a,b:TSGComplexNumber):Boolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=(a.x=b.x) and (b.y=a.y);
end;

function SGComplexNumberImport(const x:real = 0;const y:real = 0):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(x,y);
end;

operator - (const a,b:TSGComplexNumber):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(a.x-b.x,a.y-b.y);
end;

operator / (const a,b:TSGComplexNumber):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(
	(a.x*b.x+a.y*b.y)/(b.x*b.x-b.y*b.y),
	(a.y*b.x-a.x*b.y)/(b.x*b.x-b.y*b.y));
end;

operator * (const a,b:TSGComplexNumber):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
result.Import(a.x*b.x-a.y*b.y,a.x*b.y+b.x*a.y);
end;

operator + (const a,b:TSGComplexNumber):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(a.x+b.x,a.y+b.y);
end;

operator ** (const a:TSGComplexNumber;const b:LongInt):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i:LongInt;
begin
Result.Import(1,0);
for i:=1 to b do
	Result*=a;
end;

end.
