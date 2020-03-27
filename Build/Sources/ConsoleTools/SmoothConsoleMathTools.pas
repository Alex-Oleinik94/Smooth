{$INCLUDE Smooth.inc}

unit SmoothConsoleMathTools;

interface

uses
	 SmoothBase
	,SmoothConsoleCaller
	;

procedure SConsoleCalculateBoolTable(const VParams : TSConcoleCallerParams = nil);
procedure SConsoleCalculateExpression(const VParams : TSConcoleCallerParams = nil);

implementation

uses
	Crt
	,StrMan
	
	,SmoothMath
	,SmoothStringUtils
	;

procedure SConsoleCalculateBoolTable(const VParams : TSConcoleCallerParams = nil);

function IsDebug() : TSBool;
begin
if VParams <> nil then
	if Length(VParams) > 0 then
		Result := (StringTrimLeft(SUpCaseString(VParams[0]), '-') = 'D') or
				  (StringTrimLeft(SUpCaseString(VParams[0]), '-') = 'DEBUG');
end;

var
	Exp:TSExpression = nil;
	Variables:TSPCharList = nil;
	Consts:packed array of TSBoolean = nil;
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
TextColor(15);
Exp:=TSExpression.Create;
Exp.DeBug:=IsDebug();
Exp.Expression:=SConsoleCallerParamsToPChar(VParams, TSByte(IsDebug));
Exp.CanculateExpression;
Variables:=Exp.Variables;
SetLength(Consts,Length(Variables));
for I:=0 to High(Consts) do
	Consts[i]:=False;
while not Trues do
	begin
	Exp.BeginCalculate;
	for i:=0 to High(Consts) do
		Exp.ChangeVariables(Variables[i],TSExpressionChunkCreateBoolean(Consts[i]));
	Exp.Calculate;
	for i:=0 to High(Consts) do
		begin
		Write(Variables[i]);
		TextColor(7);
		Write('=');
		case byte(Consts[i]) of
		0 : TextColor(12);
		1 : TextColor(10);
		end;
		Write(byte(Consts[i]));
		TextColor(15);
		Write(' ');
		end;
	Write('Out: ');
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
Exp.Destroy();
end;

procedure SConsoleCalculateExpression(const VParams : TSConcoleCallerParams = nil);

function IsDebug() : TSBool;
begin
if VParams <> nil then
	if Length(VParams) > 0 then
		Result := (StringTrimLeft(SUpCaseString(VParams[0]), '-') = 'D') or
				  (StringTrimLeft(SUpCaseString(VParams[0]), '-') = 'DEBUG');
end;

var
	Exp : TSExpression = nil;
begin
Exp := TSExpression.Create();
Exp.DeBug := IsDebug();
Exp.Expression := SConsoleCallerParamsToPChar(VParams, TSByte(IsDebug));
Exp.CanculateExpression();
Exp.Calculate();
if Exp.Resultat.Quantity = 0 then 
	Exp.WriteErrors()
else
	Exp.Resultat.WriteLnConsole();
Exp.Destroy();
end;

end.
