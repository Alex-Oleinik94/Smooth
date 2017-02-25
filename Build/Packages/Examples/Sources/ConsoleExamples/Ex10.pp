// Use CP866
{$INCLUDE SaGe.inc}
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
	 SaGeContext
	,SaGeBase
	,SaGeMath
	,SaGeCommon
	,SaGeAdamsSystemExample
	,SaGeStringUtils
	{$IF defined(ENGINE)}
		,SaGeConsoleToolsBase
		,SaGeConsoleTools
		{$ENDIF}
	
	,Crt
	;
var
	Functions : TSGFunctionArray = nil;
	Y0 : TSGExtenededArray;
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
WriteLn('Эта программа решает систему уравнений неявным одношаговым методом Адамса.');
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

procedure Go();
const
	Output_file = 'Ex10_output.txt';
var
	AdamsResult : TSGExtenededArrayArray;
	i : LongWord;
begin
AdamsResult := SaGeAdamsSystemExample.AdamsSystem(a, b, eps, ns, n, Functions, Y0, Output_file);
WriteLn('Результат сохранен в "', Output_file, '".');
for i := 0 to High(AdamsResult) do
	SetLength(AdamsResult[i],0);
SetLength(AdamsResult,0);
end;

{$IFDEF ENGINE}
	procedure SGConsoleEx10(const VParams : TSGConcoleCallerParams = nil);
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
	SGOtherConsoleCaller.AddComand('Examples', @SGConsoleEx10, ['ex10'], 'Example 10');
	end;
	
	end.
	{$ENDIF}
