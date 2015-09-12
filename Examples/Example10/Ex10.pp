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
	Functions : array of TSGExpression = nil;
	Coords : array[0..2] of array of Extended;
	Y0 : array of Extended;
	a, b, eps : Extended;
	n, ns: LongWord;

function EnterFunction(const ss: String; const cout_variables: LongWord; const variables:String = ''):TSGExpression;
var
	s: String;
	Ex : TSGExpression = nil;
	iii,ii,i : LongWord;
begin
Write('Введите функцию: ');
Write(ss+'('+variables+')=');
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
	if (iii>cout_variables) then
		iii := cout_variables;
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
	Write(ss+'('+variables+')=');
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
var
	S : String;
	Ex : TSGExpression = nil;
	ii,i : LongWord;
begin
ClrScr();
WriteLn('Эта программа решает систему уравнений методом Адамса (Неявным одношаговым).');
Write('Введите размерность системы: ');
ReadLn(ns);
S :='';
for i := 0 to ns-1 do
	S += 'y' + SGStr(i)+',';
S +='x';

WriteLn('Система:');
for i := 0 to ns - 1 do
	WriteLn('    y'+SGStr(i)+''' = f'+SGStr(i)+'('+S+')');
WriteLn('Условия:');
for i := 0 to ns - 1 do
	WriteLn('    y'+SGStr(i)+'(a) = Y'+SGStr(i));

SetLength(Functions,ns);
SetLength(Y0,ns);
SetLength(Coords[0],ns+1);
SetLength(Coords[1],ns+1);
SetLength(Coords[2],ns+1);

Write('Введите начало отрезка {float}: a=');
ReadLn(a);
Write('Введите конец отрезка {float}: b=');
ReadLn(b);

for i := 0 to High(Functions) do
	Functions[i] := EnterFunction('f'+SGStr(i),ns+1,S);

WriteLn('Введите начальные условия:');
for i := 0 to High(Functions) do
	begin
	Write('    y'+SGStr(i)+'(a) = ');
	ReadLn(Y0[i]);
	end;

Write('Введите количество разбиение сетки {numeric}:');
ReadLn(n);
Write('Введите эпсилон {float}:');
ReadLn(eps);
end;

function MyFunc(const index_of_function : LongWord; const index_of_array : LongWord):Extended;inline;
var
	i : LongWord;
begin
Functions[index_of_function].BeginCalculate();
if (LongInt(ns) - 1 >= 0) then 
	for i := 0 to ns - 1 do
		Functions[index_of_function].ChangeVariables(SGStringToPChar('y'+SGStr(i)),TSGExpressionChunkCreateReal(Coords[index_of_array][i]));
Functions[index_of_function].ChangeVariables('x',TSGExpressionChunkCreateReal(Coords[index_of_array][n-1]));
Functions[index_of_function].Calculate();
Result:=Functions[index_of_function].Resultat.FConst;
end;

procedure Go();

function x(const i: LongWord):Extended;
begin
Result := a + abs(b-a)*(i/n)
end;

var
	max_eps : Extended;
	i, ii : LongWord;
	h : Extended;
var
	f : TextFile;

procedure OutToFile();
var
	q : LongWord;
begin
for q := 0 to ns do
	Write(f,Coords[0][q]:0:5,' ');
WriteLn(f);
end;

begin
Assign(f,'Ex10_Output.txt');
Rewrite(f);
h := abs(b-a)/n;
for i := 0 to ns - 1 do
	Coords[0][i] := y0[i];
Coords[0][ns] := a;
OutToFile();
for i := 1 to n do
	begin
	Coords[0][ns] := x(i);
	for ii := 0 to ns - 1 do
		Coords[2][ii] := Coords[0][ii] + h * MyFunc(ii,0);
	Coords[2][ns] := x(i);
	repeat
	for ii := 0 to ns do
		Write(Coords[2][ii]:0:5,' ');
	ReadLn();
	for ii := 0 to ns do
		Coords[1][ii] := Coords[2][ii];
	for ii := 0 to ns - 1 do
		Coords[2][ii] := Coords[1][ii] + h * MyFunc(ii,1);
	max_eps := 0;
	for ii := 0 to ns - 1 do
		if max_eps < abs(Coords[1][ii] - Coords[2][ii]) then
			max_eps := abs(Coords[1][ii] - Coords[2][ii]);
	until max_eps < eps;
	for ii := 0 to ns do
		Coords[0][ii] := Coords[2][ii];
	OutToFile();
	end;
Close(f);
end;

begin
ReadAll();
Go();
end.
