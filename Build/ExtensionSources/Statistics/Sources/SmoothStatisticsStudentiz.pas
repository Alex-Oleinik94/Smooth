//DEPRECATED

{$INCLUDE Smooth.inc}

unit SmoothStatisticsStudentiz;

interface

uses
	 SmoothBase
	;

function SStatisticsTDistribution(const x : TSFloat64; const N : TSMaxEnum) : TSFloat64;
function SStatisticsTCorr(const Corr : TSFloat64; const N : TSMaxEnum) : TSFloat64;

implementation

uses
	 Math
	
	,SmoothMathUtils
	;

function SStatisticsTCorr(const Corr : TSFloat64; const N : TSMaxEnum) : TSFloat64;
begin
Result := Corr * Sqrt(N - 2) / Sqrt(1 - Sqr(Corr));
end;

function SStatisticsTDistribution(const x : TSFloat64; const N : TSMaxEnum) : TSFloat64;

function gamma(const x : TSFloat64) : TSFloat64;
var
	tmp, ser : TSFloat64;
begin
tmp := (x - 0.5) * Ln(x + 4.5) - (x + 4.5);
ser := 1.0 + 
	76.18009173   / (x + 0.0) -  86.50532033   / (x + 1.0) +
	24.01409822   / (x + 2.0) -  1.231739516   / (x + 3.0) +
	0.00120858003 / (x + 4.0) -  0.00000536382 / (x + 5.0);    
Result := Exp(tmp + Ln(ser * Sqrt(2 * PI)));
end;

function gammaRatio(const x, y : TSFloat64) : TSFloat64;
var
	m : TSFloat64;
begin
m := Abs(Max(x, y));
if (m <= 100.0) then
	Result :=  gamma(x) / gamma(y)
else
	Result :=  (2.0 ** (x - y))  *  
				gammaRatio(x * 0.5, y * 0.5)  * 
				gammaRatio(x * 0.5 + 0.5, y * 0.5 + 0.5);
end;

function hyperGeom(const a, b, c, z : TSFloat64; const deep : TSMaxEnum) : TSFloat64; overload;
var
	M, d : TSFloat64;
	i, j : TSMaxEnum;
begin
Result := 1;   
for i := 1 to deep do
	begin
	M := z ** TSFloat64(i);
	for j := 0 to i - 1 do
		M *= (a + j) * (b + j) / ((1.0 + j) * (c + j));
	Result += M;      
	end;
end;

function hyperGeom(const a, b, c, z : TSFloat64) : TSFloat64; overload;
begin
Result := hyperGeom(a, b, c, z, 20);
end;

begin
Result := 0.5 + x * gammaRatio(0.5 * (N + 1.0), 0.5 * N) * hyperGeom(0.5, 0.5 * (N + 1.0), 1.5, -x*x / N) / Sqrt(PI * N);
end;

end.
