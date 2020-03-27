// Use CP866
{$INCLUDE Smooth.inc}
{$IFDEF ENGINE}
	unit Ex10;
	interface
	implementation
{$ELSE}
	program Example10;
	{$ENDIF}
uses
	{$IF defined(UNIX) and (not defined(ANDROID)) and (not defined(ENGINE))}
		cthreads,
		{$ENDIF}
	 SmoothContext
	,SmoothBase
	,SmoothMath
	,SmoothAdamsSystemExample
	,SmoothStringUtils
	{$IF defined(ENGINE)}
		,SmoothConsoleCaller
		,SmoothConsoleTools
		{$ENDIF}
	
	,Crt
	;
var
	Functions : TSFunctionArray = nil;
	Y0 : TSExtenededArray;
	a, b, eps : Extended;
	n, ns: LongWord;

function EnterFunction(const ss: String; const cout_variables: LongWord; const variables:String = ''):TSExpression;
var
	s: String;
	Ex : TSExpression = nil;
	iii,ii,i : LongWord;
begin
Write('Введите функцию: ');
Write(ss+'('+variables+')=');
repeat
i := 1;
ReadLn(S);
Ex := TSExpression.Create();
Ex.QuickCalculation := False;
Ex.Expression := SStringToPChar(S);
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
				Ex.ChangeVariables(Ex.Variables[ii],TSExpressionChunkCreateReal(random));
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
	Result := TSExpression.Create();
	Result.Expression := SStringToPChar(S);
	Result.CanculateExpression();
	end;
Ex.Destroy();
Ex:=nil;
until i = 1;
end;

procedure ReadAll();
var
	S : String;
	Ex : TSExpression = nil;
	ii,i : LongWord;
begin
ClrScr();
WriteLn('Эта программа решает систему уравнений неявным одношаговым методом Адамса.');
Write('Введите размерность системы: ');
ReadLn(ns);
S :='';
for i := 0 to ns-1 do
	S += 'y' + SStr(i)+',';
S +='x';

WriteLn('Система:');
for i := 0 to ns - 1 do
	WriteLn('    y'+SStr(i)+''' = f'+SStr(i)+'('+S+')');
WriteLn('Условия:');
for i := 0 to ns - 1 do
	WriteLn('    y'+SStr(i)+'(a) = Y'+SStr(i));

SetLength(Functions,ns);
SetLength(Y0,ns);

Write('Введите начало отрезка {float}: a=');
ReadLn(a);
Write('Введите конец отрезка {float}: b=');
ReadLn(b);

for i := 0 to High(Functions) do
	Functions[i] := EnterFunction('f'+SStr(i),ns+1,S);

WriteLn('Введите начальные условия:');
for i := 0 to High(Functions) do
	begin
	Write('    y'+SStr(i)+'(a) = ');
	ReadLn(Y0[i]);
	end;

Write('Введите количество разбиение сетки {numeric}:');
ReadLn(n);
Write('Введите эпсилон {float}:');
ReadLn(eps);
end;

procedure Go();
const
	Output_file = 'Ex10_output.txt';
var
	AdamsResult : TSExtenededArrayArray;
	i : LongWord;
begin
AdamsResult := SmoothAdamsSystemExample.AdamsSystem(a, b, eps, ns, n, Functions, Y0, Output_file);
WriteLn('Результат сохранен в "', Output_file, '".');
for i := 0 to High(AdamsResult) do
	SetLength(AdamsResult[i],0);
SetLength(AdamsResult,0);
end;

{$IFDEF ENGINE}
	procedure SConsoleEx10(const VParams : TSConcoleCallerParams = nil);
	{$ENDIF}
begin
ClrScr();
ReadAll();
Go();

{$IFNDEF ENGINE}
	end.
{$ELSE}
	end;
	initialization
	begin
	SOtherConsoleCaller.AddComand('Examples', @SConsoleEx10, ['ex10'], 'Example 10');
	end;
	
	end.
	{$ENDIF}
