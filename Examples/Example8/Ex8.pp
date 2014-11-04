//��襭�� ���������� ��⥬�. ��⮤ ���⮩ ���樨 + delta^2 ����� ��⪥��.
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
	Write('������ ࠧ��୮��� ��⥬�:');
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
					WriteLn('�� ��祣� �� �����. ���஡�� ᭮��.');
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
				WriteLn('� ��஦���� ᮤ�ন��� �訡��. ���஡�� ᭮��.');
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
								WriteLn('� ��� �� � �� ⠪ � ��६���묨. ���஡�� ����� ��ࠦ���� ᭮��.');
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
		WriteLn('���� � ⮬, �� �� �ᯮ�짮���� ���� ��६�����. ������⢮ ��६����� ������ ᮢ������ � ࠧ��୮���� ��⥬�. ���஡�� ����� ��⥬� ������.');
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
WriteLn('���⥬�:');
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
	xs : packed array of 
		packed array of Extended = nil;
	OldIndex : LongWord = 0;
	Index : LongWord = 1;

function SysFunc(const ExIndex : LongWord; const ID : LongWord):Extended;
var
	h : LongWord;
begin
NotLineSystem[ExIndex].BeginCalculate();
for h:=0 to High(Variables) do
	NotLineSystem[ExIndex].ChangeVariables(SGStringToPChar(Variables[h]),TSGExpressionChunkCreateReal(Xs[ID][h]));
Result:=NotLineSystem[ExIndex].Resultat.FConst;
end;

begin
WriteLn('�ਢ���� ��⥬� � �㦭��� ��� ����.');
SetLength(IterationSystem,Length(NotLineSystem));
for i:= 0 to High(NotLineSystem) do
	begin
	IterationSystem[i]:= TSGExpression.Create();
	IterationSystem[i].Expression := 
		SGStringToPChar(Variables[i]+'+('+SGPCharToString(NotLineSystem[i].Expression)+')');
	IterationSystem[i].CanculateExpression();
	end;
TextColor(15);
for i := 0 to High(NotLineSystem) do
	WriteLn('  ',Variables[i],'=',IterationSystem[i].Expression);
TextColor(7);
SetLength(Xs,20);
for i:=0 to High(Xs) do
	SetLength(Xs[i],Length(Variables));
for i:=0 to High(Xs[0]) do
	Xs[0][i]:=random();
while abs(r) > 0.001 do
	begin
	for i:=0 to High(NotLineSystem) do
		begin
		NotLineSystem[i].BeginCalculate();
		for ii:=0 to High(Variables) do
			NotLineSystem[i].ChangeVariables(SGStringToPChar(Variables[ii]),TSGExpressionChunkCreateReal(Xs[OldIndex][ii]));
		NotLineSystem[i].Calculate();
		Xs[Index][i] := NotLineSystem[i].Resultat.FConst - Xs[OldIndex][i];
		end;
	r := 0;
	for i := 0 to High(Xs[Index]) do
		r += Abs(SysFunc(i,Index));
	TextColor(7);
	WriteLn('� �⮣� ����砥��� �⢥�:');
	for i:=0 to Length(Xs[Index])-1 do
		begin
		TextColor(15);
		Write('  ',Variables[i],'=');
		TextColor(10);
		WriteLn(SGStrExtended(Xs[Index,i],10));
		end;
	TextColor(7);
	ReadLn();
	OldIndex := Index;
	if Index = High(Xs) then Index := 0
	else Index += 1;
	end;
TextColor(7);
WriteLn('� �⮣� ����砥��� �⢥�:');
for i:=0 to Length(Xs[Index])-1 do
	begin
	TextColor(15);
	Write('  ',Variables[i],'=');
	TextColor(10);
	WriteLn(SGStrExtended(Xs[Index,i],10));
	end;
TextColor(7);
end;

begin
ClrScr();
WriteLn('�� �ணࠬ�� �蠥� ��������� ��⥬� �ࠢ����� ��⮤�� ���⮩ ���樨');
ReadSystem();
DoIneration();

end.
