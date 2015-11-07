{$MODE OBJFPC}
program ProjectExpression;
uses 
	crt
	{$IFDEF UNIX}
		,cthreads
		{$ENDIF}
	,SaGe
	,SGUser
	,SaGeMath
	,Math
	;
var
	Exp:TSGExpression = nil;
begin
while true do
	begin
	textcolor(white);
	Exp:=TSGExpression.Create;
	Exp.DeBug:=True;
	Exp.Expression:=SGPCharRead;
	Exp.CanculateExpression;
	Exp.Calculate;
	if Exp.Resultat.Quantity = 0 then 
		Exp.WriteErrors
	else
		Exp.Resultat.WriteLnConsole;
	Exp.Destroy;
	ReadLn;
	end;
end.
