{$MODE OBJFPC}
program BooleanTable;
uses crt
	{$IFDEF UNIX}
		,cthreads
		{$ENDIF}
	,dos
	,SaGeMath
	,SaGe
	,SaGeBase
	;
var
	Exp:TSGExpression = nil;
	Variables:TArPChar = nil;
	Consts:TArBoolean = nil;
	I:LongInt;
	NeedExit:Boolean = False;

function Trues:Boolean;
var
	I:LongInt = 0;
begin
if NeedExit then
	Result:=True
else
	begin
	Result:=True;
	for i:=0 to High(Consts) do
		if not Consts[i] then
			begin
			Result:=False;
			Break;
			end;
	NeedExit:=Result;
	Result:=False;
	end;
end;

begin
textcolor(white);
Exp:=TSGExpression.Create;
//Exp.DeBug:=True;
Exp.Expression:=SGPCharRead;
Exp.CanculateExpression;
Variables:=Exp.Variables;
SetLength(Consts,Length(Variables));
for I:=0 to High(Consts) do
	Consts[i]:=False;
Writeln();
while not Trues do
	begin
	Exp.BeginCalculate;
	for i:=0 to High(Consts) do
		Exp.ChangeVariables(Variables[i],TSGExpressionChunkCreateBoolean(Consts[i]));
	Exp.Calculate;
	for i:=0 to High(Consts) do
		write(Variables[i],'=',byte(Consts[i]),' ');
	if Exp.Resultat.Quantity=0 then 
		Exp.WriteErrors
	else
		Exp.Resultat.WriteLnConsole;
	I:=High(Consts);
	while not Consts[i]=False do
		begin
		Consts[i]:=not Consts[i];
		I-=1;
		end;
	if I in [0..High(Consts)] then
		Consts[i]:=true;
	end;
readln;
readln;
end.
