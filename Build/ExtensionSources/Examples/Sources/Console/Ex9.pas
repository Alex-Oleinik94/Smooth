// Use CP866
{$INCLUDE Smooth.inc}
{$IFDEF ENGINE}
	unit Ex9;
	interface
	implementation
{$ELSE}
	program Example9;
	{$ENDIF}
uses
	{$IF defined(UNIX) and (not defined(ANDROID)) and (not defined(ENGINE))}
		cthreads,
		{$ENDIF}
	 SmoothContext
	,SmoothBase
	{$IF defined(ENGINE)}
		,SmoothConsoleCaller
		,SmoothConsoleTools
		{$ENDIF}
	,SmoothConsolePaintableTools
	,SmoothMath
	,SmoothStringUtils
	,SmoothContextInterface
	,SmoothContextClasses
	,SmoothGraphicViewer
	,SmoothEncodingUtils
	,SmoothMathUtils
	
	,Crt
	;
var
	Func : TSExpression = nil;
	x0 : Extended = 0;
	n,p : LongWord;
	S : TSLineSystem = nil;

procedure ReadAll();
var
	S : String;
	Ex : TSExpression = nil;
	ii,i : LongWord;
begin
ClrScr();
Write('Введите функцию: f(?)=');
repeat
i := 1;
ReadLn(S);
Ex := TSExpression.Create();
Ex.QuickCalculation := False;
Ex.Expression := SStringToPChar(S);
Ex.CanculateExpression();
if (Ex.ErrorsQuantity=0) then
	begin
	if (Length(Ex.Variables) <> 1) then
		begin
		TextColor(15);
		WriteLn('Ошибка: Введите функцию одной переменной!');
		TextColor(7);
		i := 0;
		end;
	Ex.BeginCalculate();
	Ex.ChangeVariables(Ex.Variable,TSExpressionChunkCreateReal(random));
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
	Write('Давайка еще раз: f(?)=')
else
	begin
	Func := TSExpression.Create();
	Func.Expression := SStringToPChar(S);
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
p += n;
end;

function MyFunc(const x : Extended):Extended;inline;
begin
Func.BeginCalculate();
Func.ChangeVariables(Func.Variable,TSExpressionChunkCreateReal(x));
Func.Calculate();
Result:=Func.Resultat.FConst;
end;

type
	TSApprFunction=class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
			private
		FGraphic : TSGraphic;
		end;

procedure TSApprFunction.Paint();
begin
FGraphic.Paint();
end;

destructor TSApprFunction.Destroy();
begin
if FGraphic <> nil then
	begin
	FGraphic.Destroy();
	FGraphic := nil;
	end;
end;

constructor TSApprFunction.Create(const VContext : ISContext);

function GetInterPaliasionMnogoclen():TSString;
var
	i : LongWord;
begin
Result:='';
for i := 0 to p do
	Result += '('+SStrMathFloat(S.x[i],16)+')*(x^'+SStr(i)+')+';
Result+='0';
WriteLn(Result);
end;

begin
inherited Create(VContext);

FGraphic:=TSGraphic.Create(Context);
FGraphic.MathGraphics := 2;
FGraphic.Colors[0].Import(0,1,1,1);
FGraphic.ArMathGraphics[0].Expression := Func.Expression;
FGraphic.Colors[1].Import(1,1,0,1);
FGraphic.ArMathGraphics[1].Expression := SStringToPChar(GetInterPaliasionMnogoclen());
FGraphic.Changet := True;
//InitGraphicView();
end;

class function TSApprFunction.ClassName():TSString;
begin
Result := 'Геометрическая интерпритация';
OEM866ToWindows1251(Result);
end;

procedure Go();
var
	e : Extended = 0.1;
	xx : Extended;
	i,ii : LongWord;
begin
S := TSLineSystem.Create(p+1);
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


SConsoleRunPaintable(TSApprFunction);

S.Destroy();
end;

{$IFDEF ENGINE}
	procedure SConsoleEx9(const VParams : TSConcoleCallerParams = nil);
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
	SOtherConsoleCaller.AddComand('Examples', @SConsoleEx9, ['ex9'], 'Example 9');
	end;
	
	end.
	{$ENDIF}
