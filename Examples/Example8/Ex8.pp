// Use CP866
//Решение нелинейных систему. Метод простой итерации + delta^2 процесс Эйткена.
{$INCLUDE SaGe.inc}
program Example8;
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
	NotLineSystem : packed array of TSGExpression = nil;
	Variables : packed array of TSGString = nil;
	IterationSystem : packed array of TSGExpression = nil;

function abs(const a : Extended):Extended;inline;
begin
if a<0 then
	Result := -a
else
	Result:=a;
end;

procedure WriteF(const i : LongWord; const kk : boolean = True);
var
	ii : LongWord;
begin
TextColor(15);
Write('f');
TextColor(14);
Write(i+1);
TextColor(15);
Write('(');
for ii:=0 to High(Variables) do
	begin
	if Variables[ii] = #0 then
		begin
		TextColor(12);
		Write('?');
		end
	else
		begin
		TextColor(11);
		Write(Variables[ii]);
		end;
	if ii<>High(Variables) then
		begin
		TextColor(15);
		Write(',');
		end;
	end;
TextColor(15);
Write(')=');
if kk then
	Write('0=');
TextColor(7);
end;

procedure ReadSystem();
var
	n,i,ii,iii: LongWord;
	s:String;
	c,c1 : TSGBoolean;
	Ex : TSGExpression  = nil;
	ExVariables : TArPChar = nil;
begin
c:= True;
while c do
	begin
	Write('Введите размерность системы:');
	TextColor(10);
	ReadLn(n);
	TextColor(7);
	SetLength(NotLineSystem,n);
	for i:=0 to n-1 do
		NotLineSystem[i] := nil;
	SetLength(Variables,n);
	for i:=0 to n-1 do
		Variables[i] := #0;
	for i:=0 to n-1 do
		begin
		Ex := TSGExpression.Create();
		Ex.QuickCalculation := False;
		c := False;
		while not c do
			begin
			s := '';
			while s = '' do
				begin
				WriteF(i);
				ReadLn(s);
				if S = '' then
					WriteLn('Вы ничего не ввели. Попробуйте снова.');
				end;
			Ex.Expression := SGStringToPChar(s);
			Ex.CanculateExpression();
			if (Ex.ErrorsQuantity=0) then
				begin
				Ex.BeginCalculate();
				ExVariables := Ex.Variables;
				if ExVariables <> nil then
					for ii:=0 to High(ExVariables) do
						Ex.ChangeVariables(ExVariables[ii],TSGExpressionChunkCreateReal(0));
				Ex.Calculate();
				end;
			C := Ex.ErrorsQuantity = 0;
			if not C then
				begin
				for ii:=1 to Ex.ErrorsQuantity do
					begin
					TextColor(12);
					Write('Error:  ');
					TextColor(15);
					WriteLn(Ex.Errors(ii));
					end;
				TextColor(7);
				WriteLn('В вырожении содержится ошибка. Попробуйте снова.');
				end;
			if C then
				begin
				if ExVariables<>nil then
					for ii := 0 to High(ExVariables) do
						begin
						c1 := False;
						for iii:=0 to n-1 do
							if (Variables[iii]<>#0) and (Variables[iii] = SGPCharToString(ExVariables[ii])) then
								begin
								c1 := True;
								Break;
								end;
						if not c1 then
							begin
							for iii := 0 to n-1 do
								if Variables[iii] = #0 then
									begin
									c1 := True;
									Break;
									end;
							if not c1 then
								begin
								C := False;
								WriteLn('У Вас что то не так с переменными. Попробуйте ввести выражение снова.');
								end
							else
								Variables[iii] := SGPCharToString(ExVariables[ii]);
							end;
						if not c then
							Break;
						end;
				end;
			Ex.Destroy();
			Ex := TSGExpression.Create();
			Ex.QuickCalculation := False;
			SetLength(ExVariables,0);
			ExVariables:=nil;
			end;
		Ex.Destroy();
		Ex := TSGExpression.Create();
		Ex.Expression := SGStringToPChar(s);
		Ex.CanculateExpression();
		NotLineSystem[i] := Ex;
		Ex := nil;
		end;
	c := False;
	for i:=0 to n-1 do
		if Variables[i] = #0 then
			begin
			c := True;
			Break;
			end;
	if C then
		begin
		WriteLn('Дело в том, что вы использовали мало переменных. Количество переменных должно совподать с размерностью системы. Попробуйте ввести систему заного.');
		for i:=0 to n-1 do
			Variables[i] := #0;
		for i:=0 to n-1 do
			if NotLineSystem[i] <>nil then
				begin
				NotLineSystem[i].Destroy();
				NotLineSystem[i]:=nil;
				end;
		end;
	end;
WriteLn('Система:');
for i := 0 to n-1 do
	begin
	Write(' ');
	WriteF(i,False);
	TextColor(15);
	WriteLn(NotLineSystem[i].Expression,'=0');
	end;
TextColor(7);
end;

procedure DoIneration();
var
	i, ii : LongWord;
	r : Extended = 999;
	eps : Extended = 0.01;
	xs : packed array of 
		packed array of Extended = nil;
	OldIndex : LongWord;
	Index : LongWord;
	CountIterations : LongWord = 0;

function SysFunc(const ExIndex : LongWord; const ID : LongWord):Extended;
var
	h : LongWord;
begin
NotLineSystem[ExIndex].BeginCalculate();
for h:=0 to High(Variables) do
	NotLineSystem[ExIndex].ChangeVariables(SGStringToPChar(Variables[h]),TSGExpressionChunkCreateReal(Xs[ID][h]));
NotLineSystem[ExIndex].Calculate();
Result:=NotLineSystem[ExIndex].Resultat.FConst;
end;

function PrivFunc(const ExIndex : LongWord; const ID : LongWord):Extended;
var
	h : LongWord;
begin
IterationSystem[ExIndex].BeginCalculate();
for h:=0 to High(Variables) do
	IterationSystem[ExIndex].ChangeVariables(SGStringToPChar(Variables[h]),TSGExpressionChunkCreateReal(Xs[ID][h]));
IterationSystem[ExIndex].Calculate();
Result:=IterationSystem[ExIndex].Resultat.FConst;
end;

procedure WriteXs(const Ind : LongWord;const s : string);
var
	i : LongWord;
begin
TextColor(7);
WriteLn(s,':');
for i:=0 to High(Xs[Ind]) do
	begin
	TextColor(15);
	Write('  ',Variables[i],'=');
	TextColor(10);
	WriteLn(SGStrExtended(Xs[Ind,i],10));
	end;
TextColor(7);
end;

procedure ProcessMatrix();
var
	f1,f2,f3 : Extended;
	x1,x2,x3 : Extended;
	Matrix : array of
		array of
			Extended = nil;
	i,ii,iii : LongWord;
	pr1,pr2,pr: Extended;
	s : string;
procedure Inverse(const n : LongInt);
var
    i, j, k: LongInt;
    t: Extended;
begin
for i := 0 to n-1 do
	SetLength(Matrix[i],n+n);

//====  скопипастеный код который находит обратную матрицу (бээ)
    for i := 1 to n do begin
        for j := 1 to n do Matrix[i-1,n+j-1] := 0.0;
        Matrix[i-1,n+i-1] := 1.0;
    end;
    for i := 1 to n do begin
        t := abs(Matrix[i-1,i-1]);
        k := i;
        for j := i+1 to n do
            if abs(Matrix[j-1,i-1]) > t then begin
                t := abs(Matrix[j-1,i-1]);
                k := j;
            end;
        for j := 1 to 2*n do begin
            t := Matrix[i-1,j-1];
            Matrix[i-1,j-1] := Matrix[k-1,j-1];
            Matrix[k-1,j-1] := t;
        end;
        t := 1.0/Matrix[i-1,i-1];
        for j := 1 to 2*n do Matrix[i-1,j-1] := Matrix[i-1,j-1]*t;
        for j := i+1 to n do begin
            t := Matrix[j-1,i-1];
            for k := 1 to 2*n do
                Matrix[j-1,k-1] := Matrix[j-1,k-1]-Matrix[i-1,k-1]*t;
        end
    end;
    for i := n downto 2 do begin
        for j := i-1 downto 1 do begin
            t := Matrix[j-1,i-1];
            for k := i to 2*n do
                Matrix[j-1,k-1] := Matrix[j-1,k-1]-Matrix[i-1,k-1]*t;
        end;
    end;
//=====
for i := 0 to n-1 do
	for j := 0 to n-1 do
		Matrix[i][j] := Matrix[i][n+j];
for i := 0 to n-1 do
	SetLength(Matrix[i],n);
end;

begin
SetLength(Matrix,Length(Variables));
for i:=0 to High(Matrix) do
	SetLength(Matrix[i],Length(Variables));

for i:=0 to High(Variables) do
	for ii := 0 to High(Variables) do
		begin
		x2 := Xs[OldIndex][ii];
		x1 := Xs[OldIndex][ii] - eps;
		x3 := Xs[OldIndex][ii] + eps;
		
		f2 := SysFunc(i,OldIndex);
		Xs[OldIndex][ii] := x1;
		f1 := SysFunc(i,OldIndex);
		Xs[OldIndex][ii] := x3;
		f3 := SysFunc(i,OldIndex);
		Xs[OldIndex][ii] := x2;
		
		Pr1 := (f2-f1)/eps;
		Pr2 := (f3-f2)/eps;
		Pr := (Pr1 + Pr2) / 2;
		
		Matrix[i][ii] := Pr;
		end;

Inverse(Length(Variables));

for i := 0 to High(Variables) do
	for ii:= 0 to High(Variables) do
		Matrix[i][ii]*=-1;

SetLength(IterationSystem,Length(NotLineSystem));
for i:= 0 to High(NotLineSystem) do
	begin
	s := Variables[i];
	for ii := 0 to High(Variables) do
		if abs(Matrix[i][ii])>eps*eps then
			s += '+('+SGStrExtended(Matrix[i][ii],10)+')*('+SGPCharToString(NotLineSystem[ii].Expression)+')';
	
	IterationSystem[i]:= TSGExpression.Create();
	IterationSystem[i].Expression := SGStringToPChar(s);
	IterationSystem[i].CanculateExpression();
	end;

for i:=0 to High(Matrix) do
	SetLength(Matrix[i],0);
SetLength(Matrix,0);
Matrix := nil;
end;

var
	d1,d2,d3 : TSGDateTime;
	S:TSGString;
begin
SetLength(Xs,20);
for i:=0 to High(Xs) do
	SetLength(Xs[i],Length(Variables));
for i:=0 to High(Xs[0]) do
	Xs[0][i]:=(random()-0.5)*20;
Index := 1;
OldIndex := 0;
WriteXs(OldIndex,'Начальное приближение');

WriteLn('Приводим систему к нужному нам виду.');
//Находим матрицу Якоби, состоящую из часных произодных в точках начального приближения, находим ей обратную, и умножаем на "-1".');
ProcessMatrix();

TextColor(15);
for i := 0 to High(NotLineSystem) do
	WriteLn('  ',Variables[i],'=',IterationSystem[i].Expression);
TextColor(7);

d1.Get();
d3 := d1;

while abs(r) > 0.001 do
	begin
	for i:=0 to High(NotLineSystem) do
		Xs[Index][i] := PrivFunc(i,OldIndex);
	r := 0;
	for i := 0 to High(Xs[Index]) do
		r += Abs(SysFunc(i,Index));
	
	{WriteLn('rrrr=',r:0:10);
	WriteXs(Index,'Промежуточные корни');}
	
	OldIndex := Index;
	if Index = High(Xs) then Index := 0
	else Index += 1;
	CountIterations += 1;
	
	d2.Get();
	if (d2-d3).GetPastSeconds() >= 3 then
		begin
		S:=SGSecondsToStringTime((d2-d1).GetPastSeconds());
		Windows1251ToOEM866(s);
		if S[Length(S)]=' ' then
			SetLength(S,Length(S)-1);
		WriteLn('Брооо, шота долговато...  Прошло: '+S+'. Кол-во итераций: ',CountIterations,'. Отклонение: ',r:0:10);
		WriteXs(Index,'Промежуточные корни');
		d3 := d2;
		end;
	end;
WriteXs(OldIndex,'Окончательный ответ');
WriteLn('Количество итераций: ',CountIterations,'.');
end;

begin
ClrScr();
WriteLn('Это программа решает нелинейные системы уравнений методом простой итерации');
ReadSystem();
DoIneration();

end.
