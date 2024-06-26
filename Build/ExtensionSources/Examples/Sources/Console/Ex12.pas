// Use CP866
{$INCLUDE Smooth.inc}
{$IFDEF ENGINE}
	unit Ex12;
	interface
	implementation
{$ELSE}
	program Example12;
	{$ENDIF}
uses
	{$IF defined(UNIX) and (not defined(ANDROID)) and (not defined(ENGINE))}
		cthreads,
		{$ENDIF}
	 SmoothContext
	,SmoothBase
	,Smooth3dObject
	,SmoothComputableExpression
	,SmoothVertexObject
	,SmoothRender
	,SmoothStringUtils
	,SmoothCamera
	,SmoothRenderBase
	,SmoothEncodingUtils
	,SmoothContextClasses
	,SmoothContextInterface
	{$IF defined(ENGINE)}
		,SmoothConsoleHandler
		,SmoothConsoleTools
		{$ENDIF}
	,SmoothConsolePaintableTools
	
	,Crt
	;
var
	FuncMU1 : TSExpression = nil;
	FuncMU2 : TSExpression = nil;
	FuncU0D : TSExpression = nil;
	FuncU0 : TSExpression = nil;
	a, b : Extended;
	n : LongWord;
	T : Extended;
	ttt : Extended;
var 
	Setka : array of
		array of 
			Extended = nil;
var
	h : Extended;

function EnterFunction(const ss: String; const cout_variables: LongWord):TSExpression;
var
	s: String;
	Ex : TSExpression = nil;
	iii,ii,i : LongWord;
begin
Write('������ �㭪��: ');
Write(ss+'(?');
for iii:= 2 to cout_variables do
	Write(',?');
Write(')=');
repeat
i := 1;
ReadLn(S);
Ex := TSExpression.Create();
Ex.QuickCalculation := False;
Ex.Expression := SStringToPChar(S);
Ex.CanculateExpression();
if (Ex.ErrorsQuantity=0) and (Length(Ex.Variables)>0) then
	begin
	Ex.BeginCalculate();
	ii := 0;
	while (ii <= cout_variables - 1) do
		begin
		if (Length(Ex.Variables) >= ii+1) then
			Ex.ChangeVariables(Ex.Variables[ii],TSExpressionChunkCreateReal(random));
		ii+=1;
		end;
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
	Result := TSExpression.Create();
	Result.Expression := SStringToPChar(S);
	Result.CanculateExpression();
	end;
Ex.Destroy();
Ex:=nil;
until i = 1;
end;

procedure ReadAll();
begin
ClrScr();
WriteLn('�ணࠬ�� �蠥� �ࠢ����� ���������:');
WriteLn('     (d^2 u)/(d ?^2)=(d^2 u)/(d ??^2)');
WriteLn('� ���⢠��� "? in [a; b]" � "?? in [0; T]".');
WriteLn('C ��砫�묨 �᫮��ﬨ:');
Writeln('     u(a,??)=Mu1(??)');
Writeln('     u(b,??)=Mu2(??)');
Writeln('     (du/d??)(?,0)=U0D(?)');
Writeln('     u(?,0)=U0(?)');
FuncMU1 := EnterFunction('Mu1',1);
FuncMU2 := EnterFunction('Mu2',1);
FuncU0 := EnterFunction('U0',1);
FuncU0D := EnterFunction('U0D',1);
Write('������ ��砫� ��१�� {float}:');
ReadLn(a);
Write('������ ����� ��१�� {float}:');
ReadLn(b);
Write('������ ������⢮ ࠧ������ �⪨ {numeric}:');
ReadLn(n);
Write('������ T {numeric}:');
ReadLn(T);
end;

function FuncOneVariable(var Func : TSExpression; const x : Extended):Extended;
begin
Func.BeginCalculate();
if (Length(Func.Variables) >= 1) then
	Func.ChangeVariables(Func.Variables[0],TSExpressionChunkCreateReal(x));
Func.Calculate();
Result:=Func.Resultat.FConst;
end;

function FMU1(const x : Extended):Extended;inline;
begin
Result := FuncOneVariable(FuncMU1,x);
end;
function FMU2(const x : Extended):Extended;inline;
begin
Result := FuncOneVariable(FuncMU2,x);
end;
function FU0D(const x : Extended):Extended;inline;
begin
Result := FuncOneVariable(FuncU0D,x);
end;
function FU0(const x : Extended):Extended;inline;
begin
Result := FuncOneVariable(FuncU0,x);
end;

type
	TSApprFunction=class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
			private
		function Calculate3dObject():TSCustomModel;
			private
		F3dObject : TSCustomModel;
		FCamera : TSCamera;
		end;

function TSApprFunction.Calculate3dObject():TSCustomModel;
var
	i, ii, iii : TSLongWord;
	max, min, c : Extended;
begin
Result:=TSCustomModel.Create();
Result.Context := Context;

Result.AddObject();
Result.LastObject().ObjectPolygonsType := SR_TRIANGLES;
Result.LastObject().HasNormals := False;
Result.LastObject().HasTexture := False;
Result.LastObject().HasColors  := True;
Result.LastObject().EnableCullFace := False;
Result.LastObject().VertexType := S3dObjectVertexType3f;
Result.LastObject().SetColorType(S3dObjectColorType4b);

Result.LastObject().Vertices   := Length(Setka)*Length(Setka[0]);
Result.LastObject().QuantityFaceArrays := 1;
Result.LastObject().PolygonsType[0]:=SR_TRIANGLES;

Result.LastObject().AutoSetIndexFormat(0,Result.LastObject().Vertices);
Result.LastObject().SetFaceLength(0,High(Setka)*High(Setka[0])*2);

max := -1000000;
min := 1000000;
for i := 0 to High(Setka) do
	for ii := 0 to High(Setka[i]) do
		begin
		if (Setka[i][ii] > max) then
			max := Setka[i][ii];
		if (Setka[i][ii] < min) then
			min := Setka[i][ii];
		end;

for i := 0 to High(Setka) do
	for ii := 0 to High(Setka[i]) do
		begin
		Result.LastObject().ArVertex3f[i*Length(Setka[i])+ii]^.Import(-1 +  h*ii/abs(b-a)*2, Setka[i][ii]/abs(b-a)*2 , - ttt*High(Setka)/abs(b-a) +  ttt*i/abs(b-a)*2);
		c := (Setka[i][ii] - min) / (max - min);
		Result.LastObject().SetColor(i*Length(Setka[i])+ii,
			1-c,
			c,
			byte(i < 20)*(20-i)/20);
		end;

iii := 0;
for i := 0 to High(Setka)-1 do
	for ii := 0 to High(Setka[i])-1 do
		begin
		Result.LastObject().SetFaceTriangle(0,iii  ,i*Length(Setka[i])+ii, (i+1)*Length(Setka[i])+ii, (i+1)*Length(Setka[i])+ii+1);
		Result.LastObject().SetFaceTriangle(0,iii+1,i*Length(Setka[i])+ii, i*Length(Setka[i])+ii+1, (i+1)*Length(Setka[i])+ii+1);
		iii+=2;
		end;
Result.LoadToVBO();
end;

procedure TSApprFunction.Paint();
begin
FCamera.InitMatrixAndMove();
F3dObject.Paint();
end;

destructor TSApprFunction.Destroy();
begin
F3dObject.Destroy();
FCamera.Destroy();
end;

constructor TSApprFunction.Create(const VContext : ISContext);
begin
inherited Create(VContext);
F3dObject := Calculate3dObject();
FCamera := TSCamera.Create();
FCamera.Context := Context;
FCamera.MatrixMode := S_3D;
FCamera.ViewMode:=SMotileObject;
end;

class function TSApprFunction.ClassName():TSString;
begin
Result := '�ࠢ����� ���������';
OEM866ToWindows1251(Result);
end;


procedure Go();

procedure OutToFile(const filename:String);
var
	f : TextFile;
	i,ii : LongWord;
begin
Assign(f,filename);
Rewrite(f);

for i := 0 to n do
	begin
	for ii := 0 to High(Setka) do
		begin
		Write(f, Setka[ii][i] :0:5,' ');
		end;
	WriteLn(f);
	end;

Close(f);
end;

var
	i, ii : LongWord;
	d : Extended;
	yyy : Extended;
begin
h := abs(b-a)/n;
ttt := h /2 ;
yyy := (ttt*ttt)/(h*h);
SetLength(Setka, Trunc( T / (ttt + 0.000001))+1);
for i := 0 to High(Setka) do
	SetLength(Setka[i],n+1);
d := a;
for i := 0 to n do
	begin
	Setka[0][i] := FU0(d);
	d += h;
	end;
d := a;
for i := 0 to n do
	begin
	Setka[1][i] := Setka[0][i] + ttt * FU0D(d);
	d += h;
	end;
d := 0;
for i := 0 to High(Setka) do
	begin
	Setka[i][0] := FMU1(d);
	d += ttt;
	end;
d := 0;
for i := 0 to High(Setka) do
	begin
	Setka[i][n] := FMU2(d);
	d += ttt;
	end;

for ii := 2 to High(Setka) do
	for i := 1 to n-1 do
		Setka[ii][i] := 2 * Setka[ii-1][i] - Setka[ii-2][i] + yyy*(Setka[ii-1][i+1] - 2 * Setka[ii-1][i] + Setka[ii-1][i-1]);

OutToFile('Ex12_OutPut.txt');

SConsoleRunPaintable(TSApprFunction);

for i := 0 to High(Setka) do
	SetLength(Setka[i],0);
SetLength(Setka,0);
end;

{$IFDEF ENGINE}
	procedure SConsoleEx12(const VParams : TSConsoleHandlerParams = nil);
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
	SConsoleToolsConsoleHandler.AddComand('Examples', @SConsoleEx12, ['ex12'], 'Example 12');
	end;
	
	end.
	{$ENDIF}
