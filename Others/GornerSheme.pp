{$MODE OBJFPC}
program _1;
uses crt
	,SaGe
	,SaGeBase;



function SGGetDelitels(const r:real;const WithMinus:Boolean = True):TArReal;
var
	i,ii:LongInt;
begin
Result:=nil;
ii:=Trunc(R);
for i:=2 to (ii div 2) do
	if Abs(R/i)<=0.001 then
		begin
		SetLength(Result,Length(Result)+1);
		Result[High(Result)]:=i;
		end;
end;

function SGGetGornerScheme(const Params:TArReal = nil):TArReal;
var
	DelitelsA:TArReal = nil;
	DelitelsC:TArReal = nil;
	Delitels:TArReal = nil;
	R:Real;
var
	i,ii,iii,iiii:LongInt;
begin
Result:=nil;
if Length(Params)=3 then
	begin
	if (Params[1]**2-4*Params[0]*Params[2])>= 0 then
		begin
		SetLength(Result,2);
		Result[0]:=(-Params[1]+sqrt((Params[1]**2-4*Params[0]*Params[2])))/(2*Params[0]);
		Result[1]:=(-Params[1]-sqrt((Params[1]**2-4*Params[0]*Params[2])))/(2*Params[0]);
		end;
	end
else
	begin
	DelitelsA:=SGGetDelitels(Params[0]);
	DelitelsC:=SGGetDelitels(Params[High(Params)]);
	for i:=0 to High(DelitelsA) do
		for ii:=0 to High(DelitelsC) do
			begin
			R:=DelitelsC[ii]/DelitelsA[i];
			iiii:=0;
			for iii:=0 to High(Delitels) do
				if Delitels[iii]=R then
					begin
					iiii:=1;
					Break;
					end;
			if iiii=0 then
				begin
				SetLength(Delitels,Length(Delitels)+1);
				Delitels[High(Delitels)]:=R;
				end;
			end;
	SetLength(DelitelsA,0);
	SetLength(DelitelsC,0);
	for i:=0 to High(Delitels) do
		begin
		
		end;
	end;
end;

var
	Date:TArReal = nil;
	Result:TArReal = nil;
	i:LongInt;
begin
readln(i);
SetLength(Date,i);
for i:=0 to High(Date) do
	Read(Date[i]);
Result:=SGGetGornerScheme(Date);
for i:=0 to High(Result) do
	write(Result[i]:0:10,' ');
WriteLn();
ReadLn;
end.
