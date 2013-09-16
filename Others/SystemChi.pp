{$MODE OBJFPC}
program _1;
uses crt,SaGe,SaGeBase;

function Perevod(a:string;b,c:byte):string;
var
	i:LongInt;
	ii:LongInt = 0;
	d:string = '';
function Ost(const a:byte):char;
begin
case a of
0..9:Result:=SGStr(a)[1];
10:Result:='A';
11:Result:='B';
12:Result:='C';
13:Result:='D';
14:Result:='E';
15:Result:='F';
end;
end;

function ValChar(c:char):Byte;
begin
case c of
'0'..'9':Result:=SGVal(c);
'A','a':Result:=10;
'B','b':Result:=11;
'C','c':Result:=12;
'D','d':Result:=13;
'E','e':Result:=14;
'F','f':Result:=15;
else
	Result:=0;
end;
end;

begin
if b = c then
	begin
	Result:=a;
	exit;
	end;
Result:='';
if (c=10) or (b=10) then
	begin
	if (c=10) then
		begin
		for i:=Length(a) downto 1 do
			begin
			ii+=ValChar(a[i])*(b**(Length(a)-i));
			end;
		Result:=SGStr(ii);
		end
	else
		if (b=10) then
			begin
			ii:=SGVal(Perevod(a,b,10));
			while ii<>0 do
				begin
				if ii>=c then
					begin
					d+=Ost(ii mod c);
					ii:= ii div c;
					end
				else
					begin
					d+=Ost(ii);
					ii:=0;
					end;
				end;
			for i:=Length(d) downto 1 do
				Result+=d[i];
			end;
	end
else
	begin
	Result:=Perevod(Perevod(a,b,10),10,c);
	end;
end;
begin
while true do
	begin
	writeln(Perevod(SGReadLnString,SGReadLnByte,SGReadLnByte));
	writeln;
	end;
end.
