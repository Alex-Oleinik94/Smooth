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
	Func : TSGExpression = nil;
	a, b, eps : Extended;
	n : LongWord;
	y0 : Extended;

procedure ReadAll();
var
	S : String;
	Ex : TSGExpression = nil;
	ii,i : LongWord;
begin
ClrScr();
WriteLn('Эта программа решает систему уравнений методом Адамса (Неявным одношаговым).');
WriteLn('	??''=f(?,??(?)), [a; b]');
WriteLn('	??(a)=x0');
Write('Введите функцию: f(?,??(?))=');
repeat
i := 1;
ReadLn(S);
Ex := TSGExpression.Create();
Ex.QuickCalculation := False;
Ex.Expression := SGStringToPChar(S);
Ex.CanculateExpression();
if (Ex.ErrorsQuantity=0) then
	begin
	if (Length(Ex.Variables) <> 2) then
		begin
		TextColor(15);
		WriteLn('Ошибка: Введите функцию двух переменных!');
		TextColor(7);
		i := 0;
		end;
	Ex.BeginCalculate();
	if (Length(Ex.Variables) >= 1) then
		Ex.ChangeVariables(Ex.Variables[0],TSGExpressionChunkCreateReal(random));
	if (Length(Ex.Variables) >= 2) then
		Ex.ChangeVariables(Ex.Variables[1],TSGExpressionChunkCreateReal(random));
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
Write('Введите начало отрезка {float}: a=');
ReadLn(a);
Write('Введите конец отрезка {float}: b=');
ReadLn(b);
Write('Введите количество разбиение сетки {numeric}:');
ReadLn(n);
Write('Введите эпсилон {float}:');
ReadLn(eps);
Write('Введите '+Func.Variables[1]+'(a), где a-начало отрезка {float}: x0=');
ReadLn(y0);
end;

function MyFunc(const x : Extended; const y : Extended):Extended;inline;
begin
Func.BeginCalculate();
Func.ChangeVariables(Func.Variables[0],TSGExpressionChunkCreateReal(x));
Func.ChangeVariables(Func.Variables[1],TSGExpressionChunkCreateReal(y));
Func.Calculate();
Result:=Func.Resultat.FConst;
end;

procedure Go();

function x(const i: LongWord):Extended;
begin
Result := a + abs(b-a)*(i/n)
end;

var
	y : array of Extended = nil;
	ypred : Extended;
	i : LongWord;
	h : Extended;

procedure OutToFile(const s:String);
var
	f : TextFile;
	i : LongWord;
begin
Assign(f,s);
Rewrite(f);
for i := 0 to High(y) do
	begin
	WriteLn(f,y[i]);
	end;
Close(f);
end;

begin
SetLength(y,n+1);
h := abs(b-a)/n;
y[0] := y0;
for i := 1 to n do
	begin
	y[i] := y[i-1] + h * MyFunc(x(i-1),y[i-1]);
	repeat
	ypred := y[i];
	y[i] := y[i-1] + h * MyFunc(x(i),y[i]); 
	until abs(y[i] - ypred) < eps
	end;
OutToFile('Ex10_output.txt');
end;

begin
ReadAll();
Go();
if (Func <> nil) then
	begin
	Func.Destroy();
	Func := nil;
	end;
end.
