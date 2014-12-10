// Use CP866
{$INCLUDE SaGe.inc}
program Example9;
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
	Func : TSGExpression = nil;
	x0 : Extended = 0;
	n,p : LongWord;
procedure ReadAll();
var
	S : String;
	Ex : TSGExpression = nil;
	ii,i : LongWord;
begin
ClrScr();
Write('Введите функцию: f(?)=');
repeat
ReadLn(S);
Ex := TSGExpression.Create();
Ex.QuickCalculation := False;
Ex.Expression := SGStringToPChar(S);
Ex.CanculateExpression();
if (Ex.ErrorsQuantity=0) then
	begin
	Ex.BeginCalculate();
	Ex.ChangeVariables(Ex.Variable,TSGExpressionChunkCreateReal(random));
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
	end
else
	i := 1;
if i = 0 then
	Write('Братишка давайка еще раз: f(?)=')
else
	begin
	Func := TSGExpression.Create();
	Func.Expression := SGStringToPChar(S);
	Func.CanculateExpression();
	end;
Ex.Destroy();
Ex:=nil;
until i = 1;
Write('Введите точку {float}:');
ReadLn(x0);
Write('Введите порядок точности {numeric}:');
ReadLn(p);
Write('Введите порядок производной {numeric}:');
ReadLn(n);
end;

function MyFunc(const x : Extended):Extended;inline;
begin
Func.BeginCalculate();
Func.ChangeVariables(Func.Variable,TSGExpressionChunkCreateReal(x));
Func.Calculate();
Result:=Func.Resultat.FConst;
end;

procedure Go();
var
	S : TSGLineSystem = nil;
	e : Extended = 0.1;
	xx : Extended;
	i,ii : LongWord;
begin
S := TSGLineSystem.Create(p+1);
xx := -(p div 2)*e+x0;
for i:=0 to p do
	S.b[i] := MyFunc(xx + i * e);
for i:=0 to p do
	for ii:=0 to p do
		S.a[i,ii] := Extended(xx + i * e)**Extended(ii);
S.CalculateRotate();
for ii := 1 to n do 
	begin
	for i := 0 to p-1 do
		begin
		S.x[i] := S.x[i+1]*(i+1);
		end;
	S.x[p] := 0;
	end;
xx := 0;
for i := 0 to p do
	xx += S.x[i]*(x0**Extended(i));
WriteLn('Ответ: ',xx:0:15);
S.Destroy();
end;

begin
ReadAll();
Go();
end.
