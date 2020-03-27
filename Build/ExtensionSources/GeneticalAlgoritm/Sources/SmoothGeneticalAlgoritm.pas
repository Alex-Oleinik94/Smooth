{$INCLUDE Smooth.inc}
Unit SmoothGeneticalAlgoritm;
interface
uses 
	 Crt
	
	,SmoothBase
	;
type
	TSGAValueType = extended;//Тип значений функции
	TSGAFunction=function(const x:TSGAValueType;const p:pointer):TSGAValueType;//тип функциии
	TSGAHromosoma = packed record //Хромосома
		FBits:packed array [0..25] of byte;//гены
		FValue:TSGAValueType;//значение переменной целевой функции
		FFunctionResult:Extended;//значение функции от этого FValue
		end;
	TSGAPopulation= packed array of TSGAHromosoma;//популяция
	TSGA=class//Класс генетиченского алгоритма
			public
		constructor Create;
		destructor Destroy;override;
			public
		FWhatFind:Boolean;//что мы ищем? минимум или максимум
		FQuantityPopulation:LongWord;//размер популяции
		FQuantityIteration:LongWord;//количество итераций
		FPopulation:TSGAPopulation;//сама популяция
		FFunction:TSGAFunction;//переменная в которую отправляют указатель на функцию
		FKrossingoverType:LongWord;//тип оператора кроссинговера
		FMutationType:LongWord;//тип мутации
		Interval:packed record//интервал
			a,b:TSGAValueType;
			end;
			public
		FOperatorOtbora:Byte;// тип оператора отбора
		FFunctionPointer:Pointer;//дополнительное значение, посылаемое в функцию
		FResultat:TSGAValueType;//Результат работы алгоритма
		FSelection1Param:TSGAValueType;//Значение переменной целевой функции, которое используется при селекции по заданной шкале
		FMutationRate,FKrossingoverRate:Extended;//вероятности операторов мутации и селекции
		procedure NewPopulation(const Param:LongWord);//создание новой популяции
		procedure Krossingover(const a,b:TSGAHromosoma; out c,d:TSGAHromosoma);//оператор кроссинговера
		function Mutation(const a:TSGAHromosoma):TSGAHromosoma;//оператор мутации
		procedure Calculate(const SelectionType:LongWord);//Реализация алгоритма
		procedure ToBits(var Hromosoma:TSGAHromosoma);//перекодиравание хромосоиы из значиния функции в гены
		procedure ToValue(var Hromosoma:TSGAHromosoma);//перекодирование хромосомы из гена в FValue:TSGAValueType
		procedure Sort(const HS:LongWord);//Обычная сортировка
		procedure Sort1(const Hig:LongWord);//Сортировка, используемая при селекции по з0аданной шкале
			public //свойства
		property WhatFind:boolean read FWhatFind write FWhatFind;
		property KrossingoverType:LongWord read FKrossingoverType write FKrossingoverType;
		property MutationType:LongWord read FMutationType write FMutationType;
		property FunctionPointer:Pointer read FFunctionPointer write FFunctionPointer;
		property Resultat:TSGAValueType read FResultat;
		property Selection1Param:TSGAValueType read FSelection1Param write FSelection1Param;
		end;
	SGA=TSGA;
implementation

procedure SGA.Sort1(const Hig:LongWord);
var
	i,ii,iii:LongWord;
	Hromosoma:TSGAHromosoma;
begin
for i:=0 to Hig-1 do
	begin
	iii:=i;
	for ii:=i to Hig do
		begin
		if (abs(FPopulation[iii].FValue-FSelection1Param)>abs(FPopulation[ii].FValue-FSelection1Param)) and 
			((Interval.a<=FPopulation[ii].FValue) and (Interval.b>=FPopulation[ii].FValue)) then
			begin
			iii:=ii;
			end;
		end;
	Hromosoma:=FPopulation[i];
	FPopulation[i]:=FPopulation[iii];
	FPopulation[iii]:=Hromosoma;
	end;
end;

procedure SGA.Sort(const HS:LongWord);
var
	i,ii,iii:LongWord;
	Hromosoma:TSGAHromosoma;
begin
for i:=0 to HS-1 do
	begin
	iii:=i;
	for ii:=i to HS do
		begin
		if (((not FWhatFind) and (FPopulation[ii].FFunctionResult<FPopulation[iii].FFunctionResult)) or 
			((FWhatFind) and ((FPopulation[ii].FFunctionResult>FPopulation[iii].FFunctionResult))))
		and ((Interval.a<=FPopulation[ii].FValue) and (Interval.b>=FPopulation[ii].FValue)) then
			begin
			iii:=ii;
			end;
		end;
	Hromosoma:=FPopulation[i];
	FPopulation[i]:=FPopulation[iii];
	FPopulation[iii]:=Hromosoma;
	end;
end;

procedure TSGA.ToValue(var Hromosoma:TSGAHromosoma);
var
	i{,ii,iii}:LongWord;
	{A,B,}C:TSGAValueType;
begin
(*Jorjies*)
C:=Abs(Interval.A+Interval.B);
Hromosoma.FValue:=Interval.A;
with Hromosoma do
	for i:=0 to High(FBits) do
		begin
		C*=0.5;
		if Boolean(FBits[i]) then
			FValue+=C;
		end;
(*For Extended*)
{with Hromosoma do
	begin
	iii:=0;
	for ii:=0 to 9 do
		begin
		PByte(@FValue)[ii]:=0;
		for i:=7 downto 0 do
			begin
			PByte(@FValue)[ii]:=(FBits[iii] shl i) or PByte(@FValue)[ii];
			iii+=1;
			end;
		end;
	end;}
(*For LongInt*)
{Hromosoma.FValue:=0;
for i:=0 to 30 do
	Hromosoma.FValue+=Hromosoma.FBits[i]*(2**i);
if Hromosoma.FBits[31]=1 then
	Hromosoma.FValue*=-1;}
end;

procedure TSGA.ToBits(var Hromosoma:TSGAHromosoma);
var
	i{,ii,iii}:LongWord;
	A,B,C:TSGAValueType;
begin
//writeln(Hromosoma.FValue:0:10);
(*Jorjies*)
A:=Interval.A;
B:=Interval.B;
with Hromosoma do
	for i:=0 to High(FBits) do
		begin
		C:=(A+B)*0.5;
		FBits[i]:=Byte(FValue>C);
		if Boolean(FBits[i]) then
			A:=C
		else
			B:=C;
		end;
(*For Extended*)
{with Hromosoma do
	begin
	iii:=0;
	for ii:=0 to 9 do
		for i:=7 downto 0 do
			begin
			FBits[iii]:=(PByte(@FValue)[ii] shr i) and 1;
			iii+=1;
			end;
	end;}
(*For LongInt*)
{for i:=0 to 31 do
	Hromosoma.FBits[i]:=0;
if Hromosoma.FValue<0 then
	Hromosoma.FBits[31]:=1;
i:=Abs(Hromosoma.FValue);
if i>0 then 
	begin
	ii:=0;
	while i<>0 do
		begin
		Hromosoma.FBits[ii]:=i mod 2;
		ii+=1;
		i:=i div 2;
		end;
	end;}
{for i:=0 to High(Hromosoma.FBits) do
	write(Hromosoma.FBits[i]);
writeln;}
end;

procedure SGA.NewPopulation(const Param:LongWord);
var
	i:LongWord;
begin
SetLength(FPopulation,FQuantityPopulation);
case Param of
0://Одеяло
	begin
	for i:=0 to High(FPopulation) do
		begin
		FPopulation[i].FValue:=(
			Interval.a+
			Abs(Interval.b-Interval.a)*(i/High(FPopulation)));
		end;
	end;
1://Дробовик
	begin
	for i:=0 to High(FPopulation) do
		begin
		FPopulation[i].FValue:=Interval.a+(Random(1001)/1000)*Abs(Interval.b-Interval.a);
		end;
	end;
end;
for i:=0 to High(FPopulation) do
	begin
	ToBits(FPopulation[i]);
	FPopulation[i].FFunctionResult:=FFunction(FPopulation[i].FValue,FFunctionPointer);
	end;
end;


constructor SGA.Create;
begin
inherited;
FMutationRate:=0.2;
FKrossingoverRate:=0.7;
FPopulation:=nil;
FFunction:=nil;
FQuantityPopulation:=10;
FQuantityIteration:=10;
FOperatorOtbora:=0;
FKrossingoverType:=0;
FMutationType:=0;
FFunctionPointer:=nil;
FResultat:=0;
end;

destructor SGA.Destroy;
begin
inherited;
end;

procedure SGA.Calculate(const SelectionType:LongWord);
var
	i,ii,iii,iiii:LongWord;
	QuantityM,QuantityK:LongWord;
	A,B,C,D:TSGAHromosoma;
begin
QuantityK:=Round(FKrossingoverRate*FQuantityPopulation);
QuantityM:=Round(FMutationRate*FQuantityPopulation);
SetLength(FPopulation,FQuantityPopulation+QuantityK*2+QuantityM);
for i:=1 to FQuantityIteration do
	begin
	for ii:=1 to QuantityK do
		begin
		case SelectionType of
		0://Имбридинг
			begin
			Sort(FQuantityPopulation+(ii-1)*2-1);
			A:=FPopulation[0];
			iii:=1;
			for iiii:=2 to FQuantityPopulation+(ii-1)*2-1 do
				if A.FValue=FPopulation[iiii].FValue then
					iii:=iiii
				else
					Break;
			B:=FPopulation[iii];
			end;
		2://Оутбридинг
			begin
			Sort(FQuantityPopulation+(ii-1)*2-1);
			A:=FPopulation[0];
			B:=FPopulation[FQuantityPopulation+(ii-1)*2-1];
			end;
		1://Селекция по заданной  шкале
			begin
			Sort1(FQuantityPopulation+(ii-1)*2-1);
			A:=FPopulation[0];
			iii:=1;
			for iiii:=2 to FQuantityPopulation+(ii-1)*2-1 do
				if A.FValue=FPopulation[iiii].FValue then
					iii:=iiii
				else
					Break;
			B:=FPopulation[iii];
			end;
		end;
		Krossingover(A,B,C,D);
		ToValue(C);ToValue(D);
		C.FFunctionResult:=FFunction(C.FValue,FFunctionPointer);
		D.FFunctionResult:=FFunction(D.FValue,FFunctionPointer);
		FPopulation[FQuantityPopulation+(ii-1)*2]:=D;
		FPopulation[FQuantityPopulation+(ii-1)*2+1]:=C;
		end;
	Sort(FQuantityPopulation+QuantityK*2-1);
	for ii:=0 to QuantityM-1 do
		begin
		FPopulation[FQuantityPopulation+QuantityK*2+ii]:=Mutation(FPopulation[FQuantityPopulation+QuantityK*2-1-ii]);
		ToValue(FPopulation[FQuantityPopulation+QuantityK*2+ii]);
		FPopulation[FQuantityPopulation+QuantityK*2+ii].FFunctionResult:=
			FFunction(FPopulation[FQuantityPopulation+QuantityK*2+ii].FValue,FFunctionPointer);
		end;
	end;
case FOperatorOtbora of
0://Элитный
	begin
	Sort(FQuantityPopulation+QuantityK*2+QuantityM-1);
	SetLength(FPopulation,1);
	
	{write('Pop =>');
	for i:=0 to High(FPopulation) do
		begin
		write(FPopulation[i].FValue:0:5,' ');
		end;writeln;}
	
	FResultat:=FPopulation[0].FValue;
	SetLength(FPopulation,0);
	end;
end;
end;

procedure SGA.Krossingover(const a,b:TSGAHromosoma; out c,d:TSGAHromosoma);
const
	zs = 1/1.618;//Золотое сечение
var
	i,ii,iii,iiii,iiiii:LongWord;

//Это для сачтично соответствующего одноточечьного
procedure a123(var a:TSGAHromosoma; const b,c:TSGAHromosoma);
var
	i:LongWord;
function b123(const a,b:TSGAHromosoma;const c:Byte):Byte;
var
	i:LongWord;
begin
iii:=iiii;
for i:=iiii+1 to High(a.FBits) do
	if a.FBits[i]=c then
		begin
		iii:=i;
		Break;
		end;
if iii=iiii then
	Result:=c
else
	begin
	Result:=b.FBits[iii];
	end;
end;

begin
for i:=0 to iiii do
	a.FBits[i]:=b123(b,c,a.FBits[i]);
end;

begin
case FKrossingoverType of
0://Cтандартный двуточечьный
	begin
	c:=a;
	d:=b;
	ii:=Random(High(a.FBits));
	for i:=ii+1 to High(a.FBits) do
		c.FBits[i]:=b.FBits[i];
	for i:=ii+1 to High(a.FBits) do
		d.FBits[i]:=a.FBits[i];
	end;
1://Частично соответствующий одноточечьный
	begin
	c:=a;
	d:=b;
	iiii:=Random(High(a.FBits));
	a123(c,a,b);
	a123(d,b,a);
	end;
2://Упорядоченный одноточечьный
	begin
	c:=a;
	d:=b;
	iiii:=Random(High(a.FBits));
	iii:=iiii+1;
	for i:=0 to High(a.FBits) do
		begin
		iiiii:=0;
		for ii:=0 to iiii do
			if b.FBits[i]=a.FBits[ii] then
				begin
				iiiii:=1;
				Break;
				end;
		if iiiii=0 then
			begin
			c.FBits[iii]:=b.FBits[i];
			iii+=1;
			end;
		end;
	for i:=0 to High(a.FBits) do
		begin
		iiiii:=0;
		for ii:=0 to iiii do
			if a.FBits[i]=b.FBits[ii] then
				begin
				iiiii:=1;
				Break;
				end;
		if iiiii=0 then
			begin
			d.FBits[iii]:=a.FBits[i];
			iii+=1;
			end;
		end;
	end;
3://На основе золотого сечения
	begin
	ii:=Random(2);
	c:=a;
	d:=b;
	ii:=Round((1-zs)*High(a.FBits));
	for i:=0 to ii do
		begin
		c.FBits[i]:=b.FBits[i];
		d.FBits[i]:=a.FBits[i];
		end;
	end;
end;
end;

function SGA.Mutation(const a:TSGAHromosoma):TSGAHromosoma;
var
	i{,ii},iii,iiii,iiiii:LongWord;

function R(const a,b:Byte):Byte;
begin
Result:=Random(b-a+1)+a;
end;

begin
case FMutationType of
0://Простая
	begin
	Result:=a;
	i:=Random(High(a.FBits)+1);
	Result.FBits[i]:=Byte(not boolean(a.FBits[i]));
	end;
1://Транспозиция
	begin 
	iiiii:=R(Low(a.FBits),High(a.FBits)-3);
	iiii:=R(iiiii+1,High(a.FBits)-2);
	iii:=R(iiii+1,High(a.FBits)-1);
	Result:=a;
	for i:=1 to iii-iiii do
		Result.FBits[iiiii+i]:=a.FBits[iiii+i];
	for i:=1 to iiii-iiiii do
		Result.FBits[iiiii+iii-iiii+i]:=a.FBits[iiiii+i];
	end;
end;
end;

END.
