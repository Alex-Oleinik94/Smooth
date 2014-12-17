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
	S : TSGLineSystem = nil;
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
p += n;
end;

function MyFunc(const x : Extended):Extended;inline;
begin
Func.BeginCalculate();
Func.ChangeVariables(Func.Variable,TSGExpressionChunkCreateReal(x));
Func.Calculate();
Result:=Func.Resultat.FConst;
end;

type
	TSGApprFunction=class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			private
		FGraphic : TSGGraphic;
		end;

procedure TSGApprFunction.Draw();
begin
FGraphic.Draw();
end;

destructor TSGApprFunction.Destroy();
begin
FGraphic.Destroy();
end;

constructor TSGApprFunction.Create(const VContext : TSGContext);
function GetInterPaliasionMnogoclen():TSGString;
var
	i : LongWord;
begin
Result:='';
for i := 0 to p do
	Result += '('+SGStrExtended(S.x[i],16)+')*(x^'+SGStr(i)+')+';
Result+='0';
WriteLn(Result);
end;

begin
inherited Create(VContext);

FGraphic:=TSGGraphic.Create(Context);
FGraphic.MathGraphics := 2;
FGraphic.Colors[0].Import(0,1,1,1);
FGraphic.ArMathGraphics[0].Expression := Func.Expression;
FGraphic.Colors[1].Import(1,1,0,1);
FGraphic.ArMathGraphics[1].Expression := SGStringToPChar(GetInterPaliasionMnogoclen());
FGraphic.Changet := True;
//InitGraphicView();
end;

class function TSGApprFunction.ClassName():TSGString;
begin
Result := 'Геометрическая интерпритация';
end;

procedure Go();
var
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

ExampleClass := TSGApprFunction;
RunApplication();

S.Destroy();
end;

begin
ReadAll();
Go();
end.
