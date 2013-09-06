{$MODE OBJFPC}
unit SGUser;
interface
uses 
	crt
	,SaGe
	,GL
	,SaGeCL
	,GLu
	,SaGeMath
	;
const
	Quantity:LongInt = 100000;
var
	IdentityObject:SGIdentityObject;
	Expression:TSGExpression = nil;
	Variable:PChar;
	Ar:TArTSGVertex2f;
	ArLength:LongInt = 0;
	Thread:TSGThread = nil;

procedure UserOnBeginProgram;
procedure UserOnActivate;
procedure UserOnPaint;

implementation


procedure ThreadConstruct;
var
	i:LongInt;
	PositionDebug:LongInt = -1;
begin
for i:=0 to Quantity-1 do
	begin
	Expression.BeginCalculate;
	if not SGPCharsEqual(Variable,'') then
		Expression.ChangeVariables(Variable,TSGExpressionChunk.CreateReal((i-Quantity*0.5)/200));
	Expression.Calculate;
	if Expression.Resultat<>nil then
		Ar[i].Import((i-Quantity*0.5)/200/10,Expression.Resultat.FConst/10);
	ArLength:=i+1;
	if PositionDebug+4<=I then
		begin
		if (((Ar[i-3].y<=Ar[i-2].y) and ((Ar[i-1].y<=Ar[i-0].y)) and (Ar[i-2].y>Ar[i-1].y)) or (((Ar[i-3].y>=Ar[i-2].y) and ((Ar[i-1].y>=Ar[i-0].y)) and (Ar[i-2].y<Ar[i-1].y)))) and (SGAbsTwoVertex2f(Ar[i-3],Ar[i-2])+SGAbsTwoVertex2f(Ar[i-1],Ar[i-0])<SGAbsTwoVertex2f(Ar[i-1],Ar[i-2])) then
			begin
			Ar[i-2].y:=Nan;
			Ar[i-2].x:=Nan;
			PositionDebug:=i-1;
			end;
		end;
	end;
end;

procedure UserOnPaint; {DONT RENAME THIS PROCEDURE!!!!}
var
	i:LongInt;
begin
IdentityObject.ChangeAndInit;

glBegin(GL_LINES);

glColor3f(0,1,0);
glVertex3f(-5000,0,0);
glVertex3f(5000,0,0);

glColor3f(1,0,0);
glVertex3f(0,-5000,0);
glVertex3f(0,5000,0);

glEnd;

glColor3f(1,1,1);
glBegin(GL_LINE_STRIP);
for i:=0 to ArLength-1 do
	Ar[i].Vertex;
glEnd();

if (Thread<>nil) and (Thread.Finished) and crt.keypressed and (crt.readkey=#13) then
	begin
	readln;
	IdentityObject.Clear;
	Expression.Expression:=SGPCharRead;
	Expression.CanculateExpression;
	Variable:=Expression.Variable;
	SetLength(Ar,Quantity);
	ArLength:=0;
	Thread:=TSGThread.Create(TSGThreadProcedure(@ThreadConstruct),nil);
	end;
if SGKeyPressedChar=#27 then
	Halt;
end;

procedure UserOnActivate; {DONT RENAME THIS PROCEDURE!!!!}
begin
IdentityObject.Clear;
Expression.CanculateExpression;
Variable:=Expression.Variable;
SetLength(Ar,Quantity);
Thread:=TSGThread.Create(TSGThreadProcedure(@ThreadConstruct),nil);
end;

procedure UserOnBeginProgram;
begin
textcolor(white);
Expression:=TSGExpression.Create;
Expression.Expression:=SGPCharRead;
//Expression.DeBug:=True;
end;

end.
