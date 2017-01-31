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
	,SaGeBase
	,SaGeBaseExample
	,SaGeUtils
	,SaGeMath
	,SaGeExamples
	,SaGeCommon
	,Crt
	,SaGeAdamsSystemExample
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
Write('������ �㭪��: ');
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
	Write('���誠 ������� �� ࠧ: ');
	Write(ss+'(?');
	for iii:= 2 to cout_variables do
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
WriteLn('�ணࠬ�� �蠥� �ࠢ�����:');
WriteLn('     "y''''+p(x)*y''+q(x)*y=f(x)" � ���⢠�� "x in [a; b]".');
WriteLn('C ��砫�묨 �᫮��ﬨ:');
Writeln('     "alpha_1*y''(a)+alpha_2*y(a)=y_a" � "betta_1*y''(b)+betta_2*y(b)=y_b".');
FuncF := EnterFunction('f',1);
FuncQ := EnterFunction('q',1);
FuncP := EnterFunction('p',1);
Write('������ ��砫� ��१�� {float}:');
ReadLn(a);
Write('������ ����� ��१�� {float}:');
ReadLn(b);
Write('������ ������⢮ ࠧ������ �⪨ {numeric}:');
ReadLn(n);
Write('������ ��ᨫ�� {float}:');
ReadLn(eps);
Write('������ alpha_1 {float}:');
ReadLn(alpha_1);
Write('������ alpha_2 {float}:');
ReadLn(alpha_2);
Write('������ betta_1 {float}:');
ReadLn(betta_1);
Write('������ betta_2 {float}:');
ReadLn(betta_2);
Write('������ y_a {float}:');
ReadLn(y_a);
Write('������ y_b {float}:');
ReadLn(y_b);
end;

function x(const i: LongWord):Extended;
begin
Result := a + abs(b-a)*(i/n)
end;

procedure Go();
var
	Expressions : TSGFunctionArray = nil;
	FR, SR, TR : TSGExtenededArrayArray;
	BeginningParams:TSGExtenededArray;
	Point1,Point2, TotalPoint, Coord1, Coord2: Extended;
procedure UpdateBeginningParams(const Point : Extended);
begin
if(abs(alpha_1) > eps) then
	begin
	BeginningParams[0] := Point;
	BeginningParams[1] := (y_a-alpha_2*Point)/alpha_1;
	end
else if(abs(alpha_2) > eps)then
	begin
	BeginningParams[0] := y_a/alpha_2;
	BeginningParams[1] := Point;
	end
else 
	WriteLn('|alpha1|+|alpha2| ~ 0');
end;

begin
SetLength(Expressions,2);
SetLength(BeginningParams,2);
Expressions[0] := TSGExpression.Create();
Expressions[0].Expression := 'y1';
Expressions[0].CanculateExpression();
Expressions[1] := TSGExpression.Create();
Expressions[1].Expression := 
	SGStringToPChar('('+
		SGPCharToString(FuncF.Expression)+')-y1*('+
		SGPCharToString(FuncP.Expression)+')-y0*('+
		SGPCharToString(FuncQ.Expression)+')');
Expressions[1].CanculateExpression();

Point1 := Random()*10 - 5;

UpdateBeginningParams(Point1);

FR := AdamsSystem(a,b,eps,2,n,Expressions,BeginningParams);//,'Ex11_Output1.txt');

Point2 := random()*20 - 10;

UpdateBeginningParams(Point2);

SR := AdamsSystem(a,b,eps,2,n,Expressions,BeginningParams);//,'Ex11_Output2.txt');

Coord1 := betta_1 * FR[High(FR)][1] + betta_2 * FR[High(FR)][0] - y_b;
Coord2 := betta_1 * SR[High(FR)][1] + betta_2 * SR[High(FR)][0] - y_b;

TotalPoint := Point2 - Coord1 * (Point2 - Point1) / (Coord2 - Coord1);

UpdateBeginningParams(TotalPoint);

TR := AdamsSystem(a,b,eps,2,n,Expressions,BeginningParams,'Ex11_Output.txt');
end;

begin
ReadAll();
Go();
end.
