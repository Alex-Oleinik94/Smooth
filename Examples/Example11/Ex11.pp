// Use CP866
{$INCLUDE SaGe.inc}
program Example10;
uses
	{$IFDEF UNIX}
		{$IFNDEF ANDROID}
			cthreads,
			{$ENDIF}
		{$ENDIF}
	 SaGeContext
	,SaGeBased
	,SaGeBase
	,SaGeBaseExample
	,SaGeUtils
	,SaGeMath
	,SaGeExamples
	,SaGeCommon
	,Crt
	;
var
	FuncP : TSGExpression = nil;
	FuncQ : TSGExpression = nil;
	FuncF : TSGExpression = nil;
	a, b, eps : Extended;
	n : LongWord;
	y_a : Extended;
	y_b : Extended;
	alpha_1, alpha_2, betta_1, betta_2 : Extended;

function EnterFunction(const ss: String; const cout_variables: LongWord):TSGExpression;
var
	s: String;
	Ex : TSGExpression = nil;
	iii,ii,i : LongWord;
begin
Write('Введите функцию: ');
Write(ss+'(?');
for iii:= 2 to n do
	Write(',?');
Write(')=');
repeat
i := 1;
ReadLn(S);
Ex := TSGExpression.Create();
Ex.QuickCalculation := False;
Ex.Expression := SGStringToPChar(S);
Ex.CanculateExpression();
if (Ex.ErrorsQuantity=0) then
	begin
	Ex.BeginCalculate();
	iii := Length(Ex.Variables);
	if (iii>n) then
		iii := n;
	if (iii <> 0) then
		for ii := 0 to LongInt(iii)-1 do
			if (Length(Ex.Variables) >= ii+1) then
				Ex.ChangeVariables(Ex.Variables[ii],TSGExpressionChunkCreateReal(random));
	Ex.Calculate();
	end;
if not (Ex.ErrorsQuantity = 0) then
	begin
	for ii:=1 to Ex.ErrorsQuantity do
		begin
		TextColor(12);
		Write('Error:  ');
		TextColor(15);
		WriteLn(Ex.Errors(ii));
		end;
	TextColor(7);
	i := 0;
	end;
if i = 0 then
	begin
	Write('Братишка давайка еще раз: ');
	Write(ss+'(?');
	for iii:= 2 to n do
		Write(',?');
	Write(')=');
	end
else
	begin
	Result := TSGExpression.Create();
	Result.Expression := SGStringToPChar(S);
	Result.CanculateExpression();
	end;
Ex.Destroy();
Ex:=nil;
until i = 1;
end;

procedure ReadAll();
begin
ClrScr();
WriteLn('Программа решает уравнение:');
WriteLn('     "y''''+p(?)*y''+q(?)*y=f(?)" в инретвале "? in [a; b]".');
WriteLn('C начальными условиями:');
Writeln('     "alpha_1*y''(a)+alpha_2*y(a)=y_a" и "betta_1*y''(b)+betta_2*y(b)=y_b".');
FuncF := EnterFunction('f',1);
FuncQ := EnterFunction('q',1);
FuncP := EnterFunction('p',1);
Write('Введите начало отрезка {float}:');
ReadLn(a);
Write('Введите конец отрезка {float}:');
ReadLn(b);
Write('Введите количество разбиение сетки {numeric}:');
ReadLn(n);
Write('Введите эпсилон {float}:');
ReadLn(eps);
Write('Введите alpha_1 {float}:');
ReadLn(alpha_1);
Write('Введите alpha_2 {float}:');
ReadLn(alpha_2);
Write('Введите betta_1 {float}:');
ReadLn(betta_1);
Write('Введите betta_2 {float}:');
ReadLn(betta_2);
Write('Введите y_a {float}:');
ReadLn(y_a);
Write('Введите y_b {float}:');
ReadLn(y_b);
end;

function FF(const x : Extended):Extended;inline;
begin
FuncF.BeginCalculate();
FuncF.ChangeVariables(FuncF.Variables[0],TSGExpressionChunkCreateReal(x));
FuncF.Calculate();
Result:=FuncF.Resultat.FConst;
end;

function FQ(const x : Extended):Extended;inline;
begin
FuncQ.BeginCalculate();
FuncQ.ChangeVariables(FuncQ.Variables[0],TSGExpressionChunkCreateReal(x));
FuncQ.Calculate();
Result:=FuncQ.Resultat.FConst;
end;

function FP(const x : Extended):Extended;inline;
begin
FuncP.BeginCalculate();
FuncP.ChangeVariables(FuncP.Variables[0],TSGExpressionChunkCreateReal(x));
FuncP.Calculate();
Result:=FuncP.Resultat.FConst;
end;

function x(const i: LongWord):Extended;
begin
Result := a + abs(b-a)*(i/n)
end;

procedure Go();
var
	ps : array of record 
		a : Extended;
		r : Extended;
		end = nil;
	s : array [0..2] of
		array of Extended;
begin
SetLength(ps,0);

end;

begin
ReadAll();
Go();
end.
