unit TBUP;

interface

procedure Run_TBUP();

implementation

uses crt;

type     b=byte;
	 ar_m_b=array[1..10,1..10] of b;

const m:array[1..12] of string = ( 'Начать игру...','Выход...',
		'Палубы', 'Корабли', 'Компьютер','4 3 2 1',
		'1 2 3 4','Игрок','Опции...','Цвет меню...',
		'Цвет игры...','Назад...'  );

{//      ▒ ░ ▓ ▓ ╝ ╓ ╧   ╞     ╫ ╒ ╘ ╟ ╗ ║ │}
{//      ╬ └ ╔	 =}

var     chv_m,chv_ig,chv_k:b;


	{Для Змейки}
	x,y:array [1..1000] of integer; {ЗМЕЯ}
	q1,q2,S:byte; {Еда}
	j,sh,kol_zm,Delay_zm,level:integer; {Счетчики}
	Top,Left,schet,i,uuuu:integer; {Движенние и счет}
	Key:char; {Клавиши}
	Dostup:boolean; {Блокировка клавиш}
	fail_zm_rec:text;

{//------------------------NNN-----------------------PR+++---}
procedure t(a:b);
begin
textcolor(a);
end;
{//-----------------------------------------------------PR+++}
procedure tb(a:b);
begin
textbackground(a);
end;
{//-----------------------------------------------------PR+++}
procedure gt(a,b:b);
begin
gotoxy(a,b);
end;
{//-----------------------------------------------------PR+++}
procedure san_cl;
begin
tb(chv_m);
clrscr;
end;
{//-----------------------------------------------------PR+++}
procedure gtn;
begin
gotoxy(80,25);
end;
{//-----------------------------------------------------PR+++}
function s_ran(a,b:integer):byte;
var tttt,qqqq:byte;
begin
tttt:=1;
while tttt=1 do
	begin
	qqqq:=random(b+1);
	if qqqq>a-1 then
		begin
		tttt:=2;
		end;
	end;
s_ran:=qqqq;
end;
{//-----------------------------------------------------PR+++}
procedure ramka( x,y:b; log:string; tipe:b; zn:string );
var kol,i:b;
begin
kol:=length(log);
gt(x,y);
case tipe of
1:
	begin
	t(15);
	write(#201);for i:=1 to kol do write(#205);write(#187);
	gt(x,y+1);write(#186,log,#186);
	gt(x,y+2);
	write(#200);for i:=1 to kol do write(#205);write(#188);
	end;
2:
	begin
	t(chv_k);
	write(#218);for i:=1 to kol do write(#196);write(#191);
	gt(x,y+1);write(#179,log,#179);
	gt(x,y+2);
	write(#192);for i:=1 to kol do write(#196);write(#217);
	end;
end;
gtn;
end;
{//-----------------------------------------------------PR+++}
Procedure Zmeya(cvet:byte);
 var t,tm:char; i:b;
 begin
	t:=#254;
	tm:=chr(s_ran(1,2));
 TextColor(cvet);
 For i:=1 to kol_zm do
  begin
  GoToXY(x[i],y[i]);
  if i=1 then write(tm) else Write(t);
  end;
 end;
{//-----------------------------------------------------PR+++}
Procedure Zmeya5(cvet:byte);
 var t,tm:char; i:b;
 begin
	t:=#254;
	tm:=chr(s_ran(1,2));
 TextColor(cvet);
 For i:=1 to kol_zm-1 do
  begin
  GoToXY(x[i],y[i]);
  if i=1 then write(tm) else Write(t);
  end;
 end;

 {//-----------------------------------------------------PR+++}
Procedure Zmeya1(cvet:byte);
 var t,tm:char; i{,dddd}:b;
 begin

	t:=#254;
	tm:=chr(s_ran(1,2));

 TextColor(cvet);
 {if uuuu=1 then dddd:=kol_zm-4 else dddd:=kol_zm-2;
 uuuu:=2;}
 For i:=1 to 3 do
  begin
  GoToXY(x[i],y[i]);
  if i=1 then write(tm) else Write(t);
  end;
 for i:={dddd}kol_zm-3 to kol_zm do
  begin
  GoToXY(x[i],y[i]);
  Write(t);
  end;
 end;
 {//-----------------------------------------------------PR+++}
Procedure Zmeya2(cvet:byte);
 var t:char;  i:b;
 begin
	t:=' ';
 TextColor(cvet);
 For i:=kol_zm-2 to kol_zm do
  begin
  GoToXY(x[i],y[i]);
  Write(t);
  end;
 end;
{ //--------------------------------------------------------PR+++}
{Изменение змеи}
Procedure Izmenenie_Zmei;
 begin
 For i:=kol_zm downto 2 do
  begin
  x[i]:=x[i-1];
  y[i]:=y[i-1];
  end;
 x[1]:=x[1]+Left;
 y[1]:=y[1]+Top;
 end;
{//----------------------------------------------------PR+++}

procedure risyn_us;
var v,c,n,p,l:char;i:b;
begin
tb(1);t(15);
c:=#219;
v:=#223;
n:=#220;
p:=#222;
l:=#221;
clrscr;
t(11);
gt(7,6);write(c,l,'   ',p,c);
gt(26,5);write(n,c,n);
gt(26,6);write(c,' ',c,'     ',c,' ',c);
gt(7,7);write(c,l,'   ',p,c);
gt(26,7);write(c,' ',p,'     ',c,' ',c);
gt(7,8);write(c,l,'   ',p,c,'  ',p,v,v,l,' ',c,c,c,' ',p,c,l,'  ',c,' ',c,' ',c,' ',c);
gt(7,9);write(c,l,'   ',p,c,'  ',p,n,'   ',c,n,'   ',c,'   ',c,' ',c,' ',c,' ',c);
gt(7,10);write(p,c,n,n,n,c,c,l,'   ',v,l,' ',c,v,'   ',c,'   ',c,' ',c,' ',c,' ',c);
gt(8,11);write(p,c,c,c,l,p,c,' ',p,n,n,l,' ',c,c,c,'  ',c,'   ',v,c,v,' ',c,' ',c);
{----------------------2-------}t(13);
gt(27,13);write(c,c,c,l);
gt(27,14);write(c,'  ',c);
gt(27,15);write(c,'  ',c);
gt(27,16);write(c,c,c,l);
gt(27,17);write(c);
gt(27,18);write(c);
{---------------------3-------}gt(45,3);t(10);write('The Best');t(14);
gt(33,15);write(c,n,c,c,' ',c,c,c,' ',c,c,c,' ',c,n,c,c,' ',n,c,n,' ',c,l,p,c);
gt(33,16);write(c,v,' ',v,' ',c,' ',c,' ',c,' ',c,' ',c,v,' ',v,' ',c,' ',c,' ',c,c,c,c);
gt(33,17);write(c,'    ');for i:=1 to 5 do write(c,' ');write('   ',c,n,c,' ',c,p,l,c);
gt(33,18);write(c,'    ',c,c,c,' ',c,c,c,' ',c,'    ',c,' ',c,' ',c,'  ',c,' ',c,' ',c,' ',c);
t(10);
gt(50,23);write('(c) by Sanches Corporation.');
gt(50,24);write('Protected by МПСМП.');
gtn;Delay(2000);
end;

{//----------------------------------------------------PR+++}
procedure risyn_fuck;
var chv_1,chv_2,chv_3:integer;
	p,l,n,v,m,o:char;
begin
textcolor(15);
textbackground(0);
clrscr;
l:=#221;
p:=#222;
v:=#223;
n:=#220;
m:=#219;
o:=' ';
chv_1:=0;
while chv_1=0 do chv_1:=random(6);
chv_2:=chv_1;
while chv_2=chv_1 do chv_2:=chv_2+random(6);
chv_3:=chv_2;
while chv_3=chv_2 do chv_3:=chv_3+random(6);
{//-tretego-nach}
textcolor(chv_1);
{//--1-st}
gotoxy(6,3);
write(m,m,m,m,m,'	     ',m,l);
{//--2-st}
gotoxy(6,4);
write(m,m,m,m,m,' ',m,m,l,o,m,m,m,o,m,m,m,o,m,l,o,o,m,m,m,o,m,m,m,o,m,m,m);
{//--3-st}
gotoxy(7,5);
write(p,m,l,o,o,m,l,m,o,m,n,'   ',m,o,o,m,m,l,o,m,n,o,o,m,o,v,o,m,o,m);
{//--4-st}
gotoxy(7,6);
write(p,m,l,o,o,m,m,l,o,m,v,'   ',m,o,o,m,l,m,o,m,v,o,o,m,'   ',m,o,m);
{//--5-st}
gotoxy(7,7);
write(p,m,l,o,o,m,l,o,o,m,m,m,o,o,m,o,o,m,m,l,o,m,m,m,o,m,'   ',m,m,m);
{//--6-st}
gotoxy(12,8);
write(m,l);
{//-tretego-kon
//-ne-nach}
textcolor(chv_2);
{//1}
gotoxy(35,10);
write(m,m,o,o,m,m,o,m,m,m,m,m);
{//2}
gotoxy(35,11);
write(m,m,o,o,m,m,o,m,m,v,v,v);
{//3}
gotoxy(35,12);
write(m,m,m,m,m,m,o,m,m,m,m);
{//4}
gotoxy(35,13);
write(m,m,v,v,m,m,o,m,m,n,n,n);
{//5}
gotoxy(35,14);
write(m,m,o,o,m,m,o,m,m,m,m,m);
{//-ne-kon
//-dano-nach}
textcolor(chv_3);
{//0}
gotoxy(69,18);
write(m,l);
{//1}
gotoxy(51,19);
write(n,'     ',n,'	   ',m,l);
{//2}
gotoxy(50,20);
write(p,m,l,o,o,o,p,m,l,o,m,o,o,m,o,m,m,m,o,m,l);
{//3}
gotoxy(50,21);
write(m,v,m,o,o,o,m,v,m,o,m,n,n,m,o,m,o,m,o,m,l);
{//4}
gotoxy(50,22);
write(m,o,m,o,o,o,m,n,m,o,m,v,v,m,o,m,o,m);
{//5}
gotoxy(48,23);
write(n,n,m,m,m,n,n,o,m,o,m,o,m,o,o,m,o,m,m,m,o,m,l);
{//6}
gotoxy(48,24);
write(m,l,o,o,o,p,m);
{//--dano-kon}
gotoxy(80,25);
delay(1200);
textcolor(15);
gotoxy(60,5);
write('(Fuck You!!!)');
gotoxy(80,25);
delay(2000);
end;
{//----------------------------------------------------PR+++}
procedure risyn;
var     i:longint;
	pr,l,n,ve,vs,p,v:char;
begin
clrscr;
textbackground(16);
textcolor(10);
writeln;
pr:=chr(222);
vs:=chr(219);
ve:=chr(223);
n:=chr(220);
l:=chr(221);
p:=' ';
{//Начало надписи "SANCHS"------------------------------------HAЧ}
gotoxy(1,8);
{//1-ая строка--------------------------------------------------1}
write('		 ');
write(chr(219));
for i:=1 to 3 do write(chr(223));
write(chr(219), '  ');
for i:=1 to 2 do write(chr(220));
write('  ', chr(219), chr(221), '   ', chr(219), '  ');
for i:=1 to 2 do write(chr(219));
write('  ', chr(219),'   ', chr(219), ' ');
for i:=1 to 5 do write(chr(219));
write(' ',chr(219));
for i:=1 to 3 do write(chr(223));
writeln(chr(219));
{//2-ая строка--------------------------------------------------2}
write('		 ');
write(chr(219), '   ', chr(223), ' ');
write(chr(222), chr(221),chr(222),chr(221), ' ');
write(chr(219), ve, l, p,p,vs,p,pr,ve,ve,l,p,vs,p,p,p,vs,p,vs,vs,p,p,p,p);
write(vs,p,p,p,ve);
writeln;
{//3-я строка---------------------------------------------------3}
write('		 ');
write(chr(219), p,p,p,p,p,vs,l,pr,vs,p,vs,p,l,p,p,vs,p,vs,p,p,ve,p,vs,p,p,p);
write(vs,p,vs,vs,p,p,p,p,vs);
writeln;
{//4-ая строка--------------------------------------------------4}
write('		 ');
write(pr);
for i:=1 to 2 do write(chr(220));
write(p,p,p,vs,p,p,vs,p,vs,p,ve,l,p,vs,p,vs,p,p,p,p,vs);
for i:=1 to 3 do write(n);
write(vs,p,vs,vs,n,n,p,p,pr,n,n);
writeln;
{//5-ая строка--------------------------------------------------5}
write('		 ');
write('  ');
for i:=1 to 2 do write(chr(223));
write(chr(221),p,vs,n,n,vs,p,vs,p,p,l,p,vs,p,vs,p,p,p,p,vs);
for i:=1 to 3 do write(ve);
write(vs,p,vs,vs,ve,ve,p,p,p,p,ve,ve,l);
writeln;
{//6-ая строка--------------------------------------------------6}
write('		 ');
write('    ', chr(219),p,vs,p,p,vs,p,vs,p,p,ve,l,vs,p,vs,p,p,n,p);
write(vs,p,p,p,vs,p,vs,vs,p,p,p,p,p,p,p,p,vs);
writeln;
{//7-мая строка-------------------------------------------------7}
write('		 ');
write(chr(220), '   ', chr(219),p,vs,p,p,vs,p,vs,p,p,p,l,vs,p,pr,n,n,l,p,vs,p,p,p);
write(vs,p,vs,vs,p,p,p,p,n,p,p,p,vs);
writeln;
{//8-мая строка-------------------------------------------------8}
write('		 ');
write(chr(219));
for i:=1 to 3 do write(chr(220));
write(chr(219),p,vs,p,p,vs,p,vs,p,p,p,ve,vs,p,p,vs,vs,p,p,vs,p,p,p,vs,p);
write(vs,vs,vs,vs,vs,p,vs,n,n,n,vs);
textcolor(16);
writeln;
{//readln;}
gotoxy(80,25);
Delay(1200);
{//Конеч надписи "SANCHES"------------------------------------KOH}
{//Начало надписи "corporation"-----------------------------НАЧ}
clrscr;
writeln;
textcolor(11);
gotoxy(1,10);
{//1-ая строка-------------------------------------------------1}
write('	       ');
write(p,n,n,n,p,n,n,n,p,n,n,n,p
,n,n,n,p,n,n,n,p,n,n,n,p,n,n,n,p,n,n,n,p,n,p);
writeln(n,n,n,p,n,p,n);
{//2-ая строка-------------------------------------------------2}
write('	       ');
write(p,vs,p,vs,p,vs,vs,vs,p,vs,p,pr,p,vs,p,pr,p,vs,vs,vs,p,vs,p,pr,p,vs,p,vs);
writeln(p,vs,vs,vs,p,n,p,vs,vs,vs,p,vs,l,vs);
{//3-я строка--------------------------------------------------3}
write('	       ');
write(p,l,p,p,p,vs,p,vs,p,vs,vs,ve,p,vs,ve,ve);
v:=chr(223);
write(p,vs,p,vs,p,vs,vs,v,p,vs,v,vs,p,p,vs,p,p,vs,p,vs,p,vs,p);
for i:=1 to 3 do write(vs);
writeln;
{//4-ая строка-------------------------------------------------4}
write('	       ');
write(p,vs,p,vs,p,vs,vs,vs,p,vs,v,l,p,vs,p,p,p,vs,vs,vs,p,vs,v,l,p,vs,p,vs,p,p);
writeln(vs,p,p,vs,p,vs,vs,vs,p,vs,pr,vs);
{]//5-ая строка-------------------------------------------------5}
write('	       ');
write(p,v,v,v,p,v,v,v,p,v,p,v,p,v,p,p,p,v,v,v,p,v,p,v,p,v,p,v,p,p,v,p,p);
writeln(v,p,v,v,v,p,v,p,v);
{//Конец надписи "corporation"-------------------------------КОН}
writeln;
gotoxy(80,25);
Delay(1200);
clrscr;
writeln;
textcolor(12);
{//Начало надписи "present"-------------------------------------НАЧ}
gotoxy(1,10);
{//1-я строка-----------------------------------------------------1}
write('		      ');
writeln(p,n,n,n,p,n,n,n,p,n,n,n,p,n,n,n,p,n,n,n,p,n,p,n,p,n,n,n);
{/2-я строка-----------------------------------------------------2}
write('		      ');
writeln(' ',vs,p,pr,p,vs,p,pr,p,vs,p,p,p,vs,p,p,p,vs,p,p,p,vs,l,vs,p,vs,vs,vs);
{//3-я строка-----------------------------------------------------3}
write('		      ');
writeln(p,vs,v,v,p,vs,vs,v,p,vs,vs,vs,p,v,vs,n,p,vs,vs,vs,p,vs,vs,vs,p,p,vs);
{//4-я строка-----------------------------------------------------4}
write('		      ');
writeln(p,vs,p,p,p,vs,v,l,p,vs,p,p,p,p,p,vs,p,vs,p,p,p,vs,pr,vs,p,p,vs);
{//5-я строка-----------------------------------------------------5}
write('		      ');
writeln(p,v,'   ',v,p,v,p,v,v,v,p,v,v,v,p,v,v,v,p,v,p,v,p,p,v);
{//Конец надписи "present"--------------------------------------КОН}
gotoxy(80,25);
Delay(1200);
{//readln;}
end;

{//----------------------------------------------------PR+++}

procedure _ABC( a:b );
var d:char;
begin
d:=chr(205);
case a of
2:
write('╔А',d,'Б',d,'В',d,'Г',d,'Д',d,'Е',d,'Ж',d,'З',d,'И',d,'К',d,'╗');
1:
write(chr(200),'',d,'А',d,'Б',d,'В',d,'Г',d,'Д',d,'Е',d,'Ж',d,'З',d,'И',d,'К╝');
end;
end;
{//-----------------------------------------------------PR+++}

procedure risyn_smile_big1;
var c:char;
begin
tb(10);
clrscr;
c:=#219;
gt(42,2);t(0);write(c,' ',c);
gt(41,3);write(c);t(12);write(c);t(0);write(c);t(12);write(c);t(0);write(c);
gt(41,4);write(c);t(12);write(c,c,c);t(0);write(c);
gt(42,5);write(c);t(12);write(c);t(0);write(c);
gt(33,6);write(c,c,c,c,c,c,c,'   ',c);
gt(31,7);write(c,c);t(14);write(c,c,c,c,c,c,c);t(0);write(c,c,'    ',c,' ',c);
gt(30,8);write(c);t(14);for i:=1 to 11 do write(c);t(0);write(c,'  ',c);t(12);write(c);t(0);write(c);
	t(12);write(c);t(0);write(c);
gt(29,9);write(c);t(14);for i:=1 to 13 do write(c);t(0);write(c,' ',c);t(12);write(c,c,c);
	t(0);write(c);
gt(28,10);write(c);t(14);for i:=1 to 15 do write(c);t(0);write(c,' ',c);t(12);write(c);
	t(0);write(c);
gt(28,11);write(c);t(14);write(c,c,c,c);t(0);write(c,c);t(14);write(c,c,c);t(0);
	write(c,c);t(14);write(c,c,c,c);t(0);write(c,'  ',c);
gt(27,12);write(c);t(14);write(c,c,c,c);t(0);write(c);t(15);write(c);t(0);write(c,c);
	t(14);write(c);t(0);write(c);t(15);write(c);t(0);write(c,c);t(14);write(c,c,c,c);
	t(0);write(c);
gt(27,13);write(c);t(14);write(c,c,c,c);t(0);write(c);t(15);write(c,c);t(0);write(c);
	t(14);write(c);t(0);write(c);t(15);write(c,c);t(0);write(c);t(14);write(c,c,c,c);
	t(0);write(c,'  ',c,' ',c);
gt(27,14);write(c);t(14);write(c,c,c,c,c);t(0);write(c,c);t(14);write(c,c,c);
	t(0);write(c,c);t(14);write(c,c,c,c,c);t(0);write(c,' ',c);t(12);write(c);
	t(0);write(c);t(12);write(c);t(0);write(c);
gt(27,15);write(c);t(14);for i:=1 to 17 do write(c);t(0);write(c,' ',c);t(12);write(c,c,c);
	t(0);write(c);
gt(27,16);write(c);t(14);write(c,c);t(0);write(c);t(14);for i:=1 to 11 do write(c);
	t(0);write(c);t(14);write(c,c);t(0);write(c,'  ',c);t(12);write(c);t(0);write(c);
gt(27,17);write(c);t(14);write(c);t(0);write(c,c);t(14);for i:=1 to 10 do write(c);
	t(0);write(c,c,c);t(14);write(c);t(0);write(c,c,'  ',c);
gt(27,18);write(c);t(14);write(c,c,c);t(0);write(c);t(14);write(c,c,c,c,c,c,c,c);
	t(0);write(c);t(12);write(c,c);t(0);write(c,c);t(12);write(c,c);t(0);write(c);
gt(28,19);write(c);t(14);write(c,c,c);t(0);write(c);t(14);write(c,c,c,c,c,c);t(0);
	write(c);t(12);for i:=1 to 8 do write(c);t(0);write(c);
gt(28,20);write(c);t(14);write(c,c,c,c);t(0);for i:=1 to 7 do write(c);t(12);
	for i:=1 to 8 do write(c);t(0);write(c);
gt(29,21);write(c);t(14);for i:=1 to 10 do write(c);t(0);write(c);t(12);
	for i:=1 to 6 do write(c);t(0);write(c);
gt(30,22);write(c);t(14);for i:=1 to 10 do write(c);t(0);write(c);t(12);
	write(c,c,c,c);t(0);write(c);
gt(31,23);write(c,c);t(14);write(c,c,c,c,c,c,c);t(0);write(c,c,c);t(12);
	write(c,c);t(0);write(c);
gt(33,24);for i:=1 to 7 do write(c);write('   ',c,c);
end;
{//-----------------------------------------------------PR+++}

procedure risyn_smile_big2;
var c:char; i,ii:b;
begin
tb(3);
clrscr;
c:=#219;
gt(33,6);t(0);for i:=1 to 7 do write(c);
gt(31,7);write(c,c);t(14);for i:=1 to 7 do write(c);t(0);write(c,c);
gt(30,8);write(c);t(14);for i:=1 to 11 do write(c);t(0);write(c);
gt(29,9);write(c);t(14);for i:=1 to 13 do write(c);t(0);write(C);
gt(28,10);write(c);t(14);for i:=1 to 15 do write(c);t(0);write(c);
gt(28,11);write(c);t(14);write(c,c);t(0);write(c,c,c);t(14);write(c,c,c,c,c);t(0);
	write(c,c,c);t(14);write(c,c);t(0);write(c);
gt(27,12);write(c);t(14);write(c,c);t(0);write(c);t(14);write(c,c);t(0);write(c,c);
	t(14);write(c,c,c);t(0);write(c,c);t(14);write(c,c);t(0);write(c);t(14);
	write(c,c);t(0);write(c);
for ii:=13 to 15 do
	begin
	gt(27,ii);write(c);t(14);for i:=1 to 17 do write(c);t(0);write(c);
	end;
gt(27,16);write(c);t(14);write(c,c);t(0);write(c);t(14);for i:=1 to 11 do
	write(c);t(0);write(c);t(14);write(c,c);t(0);write(c);
gt(27,17);write(c);t(14);write(c);t(0);write(c);t(14);write(c);t(0);write(c);
	t(14);for i:=1 to 9 do write(c);t(0);
	write(c);t(14);write(c);t(0);write(c);t(14);write(c);t(0);write(c);
gt(27,18);write(c);t(14);write(c,c,c,c);t(0);write(c);t(14);write(c,c,c,c,c,c,c);t(0);write(c);
	t(14);write(c,c,c,c);t(0);write(c);
gt(28,19);write(c);t(14);write(c,c,c,c);t(0);write(c,c,c,c,c,c,c);t(12);
	write(c);
	t(14);write(c,c,c);t(0);write(c);
gt(28,20);write(c);t(14);write(c,c,c,c,c,c,c);t(12);write(c,c,c,c,c,c);t(14);
	write(c,c);t(0);write(c);
gt(29,21);write(c);t(14);write(c,c,c,c,c,c,c);t(12);write(c,c,c,c);t(14);
	write(c,c);t(0);write(c);
gt(30,22);write(c);t(14);for i:=1 to 5 do write(c,c);write(c);t(0);write(c);
gt(31,23);write(c,c);t(14);write(c,c,c,c,c,c,c);t(0);write(c,c);
gt(33,24);write(c,c,c,c,c,c,c);
end;
{//-----------------------------------------------------PR+++}
procedure risyn_smile_big;
var gg:integer;
begin
case s_ran(1,2) of
1:
	begin
	risyn_smile_big1;
	gg:=1;
	end;
2:
	begin
	risyn_smile_big2;
	gg:=2;
	end;
end;
if gg=1 then t(0) else t(15);
gt(3,3);write('ООО "Sanches Corporation".');
gt(3,4);write('Лицензия МПТР России');
gt(3,5);write('ВАФ № 77-12 от 3.3.2010г.');
gt(55,3);write('Все права защищены.');
gt(55,4);write('Воспроизведение');
gt(55,5);write('(копирование),');
gt(55,6);write('сдача в прокат, публич-');
gt(55,7);write('ное исполнение и пере-');
gt(55,8);write('дача в эфир без разреше-');
gt(55,9);write('ния правообладателя зап-');
gt(55,10);write('рещены.');
gt(3,20);write('Не подлежит обязательной');
gt(3,21);write('сертификации.');
gt(3,22);write('Изготовлено в России.');
gt(53,21);write('(c) by Sanches Corporation.');
gt(53,22);write('Protected by МПСМП.');
if gg=1 then t(10) else t(11);
gt(25,25);write('Нажмите любую клавишу для выхода в преведущее меню...');
gt(80,25);Delay(200);while not keypressed do delay(10);
end;
{//-----------------------------------------------------PR+++}
procedure zapo;
var     i,ii:b;
begin
textbackground(chv_ig);
clrscr;
GoToXY(2,2);
_ABC(2);
GoToXY(2,23);
_ABC(1);
GoToXY(29,2);
_ABC(2);
gotoxy(29,23);
_ABC(1);
gotoxy(61,3);
write(m[3]);
gotoxy(61,7);
write(m[3]);
gotoxy(61,5);
write(m[4]);
gotoxy(61,9);
write(m[4]);
gotoxy(67,2);
write(m[8]);
gotoxy(65,6);
write(m[5]);
gotoxy(70,3);
write(m[6]);
gotoxy(70,7);
write(m[6]);
gotoxy(70,5);
write(m[7]);
gotoxy(70,9);
write(m[7]);
gotoxy(70,4);write(#179,' ',#179,' ',#179,' ',#179);
gotoxy(70,8);write(#179,' ',#179,' ',#179,' ',#179);
for i:=3 to 22 do
	begin
	gotoxy(2,i);
	case i of
	4:write('1');
	6:write('2');
	8:write('3');
	10:write('4');
	12:write('5');
	14:write('6');
	16:write('7');
	18:write('8');
	20:write('9');
	22:begin gotoxy(1,i); write('10') end
	else write(chr(186));
	end;
	end;
for i:=3 to 22 do
	begin
	gotoxy(29,i);
	case i of
	4:write('1');
	6:write('2');
	8:write('3');
	10:write('4');
	12:write('5');
	14:write('6');
	16:write('7');
	18:write('8');
	20:write('9');
	22:begin gotoxy(28,i); write('10') end
	else write(chr(186));
	end;
	end;
for i:=3 to 22 do
	begin
	gotoxy(23,i);
	case i of
	3:write('1');
	5:write('2');
	7:write('3');
	9:write('4');
	11:write('5');
	13:write('6');
	15:write('7');
	17:write('8');
	19:write('9');
	21:begin gotoxy(23,i); write('10') end
	else write(chr(186));
	end;
	end;
for i:=3 to 22 do
	begin
	gotoxy(50,i);
	case i of
	3:write('1');
	5:write('2');
	7:write('3');
	9:write('4');
	11:write('5');
	13:write('6');
	15:write('7');
	17:write('8');
	19:write('9');
	21:begin gotoxy(50,i); write('10') end
	else write(chr(186));
	end;
	end;
textbackground(1);
for i:=1 to 20 do
	begin
	gotoxy(3,2+i);
	write('		    ');
	{for ii:=1 to 20 do
		begin
		write(' ');
		//delay(1);
		end;  }
	end;
textbackground(0);
t(1);
for i:=1 to 20 do
	begin
	gotoxy(30,2+i);
	{write('		    ');}
	for ii:=1 to 10 do write(#175,#175);
	{for ii:=1 to 20 do
		begin
		write(' ');
		//delay(1);
		end;}
	end;
end;


{//-----------------------------------------------PR+++}
procedure inf_m_n;
begin
textcolor(chv_m+random(15));
gotoxy(67,1);write(#186,'Информация...');
gotoxy(67,2);write(#200);for i:=1 to 13 do write(#205);
textcolor(15);
end;
{//-----------------------------------------------PR+++}
procedure infor_chv;
var i:b;
rrr:char;
begin
tb(0);
t(15);
clrscr;
gt(2,2);write('Информация о цвете в Паскале...');
gt(1,3);for i:=1 to 31 do write(#205);
gt(32,1);write(#186);
gt(32,2);write(#186);
gt(32,3);write(#188);
gt(2,5);WRITE(#218);FOR I:=1 to 27 do write(#196);write(#191);
gt(1,8);for i:=1 to 80 do if ((i=2) or (i=30) or (i=51) or (i=79)) then write(#193) else write(#196);
for i:=8 to 19 do
	begin
	gt(40,i);
	if i=8 then write(#194) else write(#179);
	end;
gt(1,20);
for i:=1 to 80 do if i=40 then write(#193) else write(#196);
gt(51,5);write(#218);for i:=1 to 27 do write(#196);write(#191);
gt(2,6);write(#179);
gt(2,7);write(#179);
gt(30,6);write(#179);
gt(30,7);write(#179);
gt(51,6);write(#179);
gt(51,7);write(#179);
gt(79,6);write(#179);
gt(79,7);write(#179);
t(15);
gt(3,24);write('Нажмите любую клавишу чтоб перейти в преведущее меню...');
t(15);
gt(3,6);write('Цвета, которые поддерживают');
gt(3,7);write('       цвет фона...');
gt(52,6);write('Цвета, которые поддерживают');
gt(52,7);write('   цвет текста и фона...');
for i:=10 to 17 do
	begin
	if i=10 then
		begin
		gt(3,i);
		t(15);
		write('0 -');
		end
	else
		begin
		gt(3,i);
		t(i-10);
		write(i-10,' -');
		end;
	end;
t(15);
for i:=10 to 18 do
	begin
	gt(43,i);
	t(i-2);
	write(i-2,' ');
	if i-2<10 then write(' -') else write('-');
	end;
t(15);gt(8,10);write('Чёрный...');
t(1);gt(8,11);write('Тёмно-синий   - ',#219);
t(2);gt(8,12);write('Тёмно-зелёный - ',#219);
t(3);gt(8,13);write('Тёмно-голубой - ',#219);
t(4);gt(8,14);write('Тёмно-красный - ',#219);
t(5);gt(8,15);write('Тёмно-розовый - ',#219);
t(6);gt(8,16);write('Тёмно-жёлтый  - ',#219);
t(7);gt(8,17);write('Светло-серый  - ',#219);

 t(8);gt(48,10);write('Серый	 - ',#219);
 t(9);gt(48,11);write('Ярко-синий    - ',#219);
t(10);gt(48,12);write('Салатовый     - ',#219);
t(11);gt(48,13);write('Ярко-голубой  - ',#219);
t(12);gt(48,14);write('Ярко-красный  - ',#219);
t(13);gt(48,15);write('Ярко-розовый  - ',#219);
t(14);gt(48,16);write('Ярко-жёлтый   - ',#219);
t(15);gt(48,17);write('Белоснежный   - ',#219);
	gt(51,18);write('+ те, которые в 1-ой колонке...');

gt(3,21);write('Если значение чвета больше 15, то в значение цвета будет идти');
gt(1,22);write('остаток от деления на 16...');
gt(3,23);write('Чтоб цвет мигал надо к значению цвета прибавить 180...');
gtn;
delay(500);
while not KeyPressed do Delay(10);
for i:=1 to 10 do if keypressed then rrr:=readkey;
rrr:=' ';
end;
{//-----------------------------------------------PR+++}
procedure info_o;
var k,k1,u,i,x1:b;
	rrr:char;
begin
tb(chv_m);
clrscr;
x1:=s_ran(5,40);
{--------------}
t(15);
gt(x1,11);write(#201);for i:=1 to 9 do write(#205);write(#187);
gt(x1,12);write(#186,'Ролики...',#186);
gt(x1,13);write(#200);for i:=1 to 9 do write(#205);write(#188);
gt(x1,15);write(#201);for i:=1 to 8 do write(#205);write(#187);
gt(x1,16);write(#186,'Назад...',#186);
gt(x1,17);write(#200);for i:=1 to 8 do write(#205);write(#188);
{--------------}
inf_m_n;
u:=1;
k1:=2;
k:=1;
while u=1 do
	begin
	if KeyPressed then
		case readkey of
		#72:if k<>1 then k:=k-1;
		#80:if k<>4 then k:=k+1;
		#13:case k of
		    1:
			begin
			infor_chv;
			tb(chv_m);
			clrscr;
			inf_m_n;
			k:=1;
			k1:=2;
			t(15);
			gt(x1,11);write(#201);for i:=1 to 9 do write(#205);write(#187);
			gt(x1,12);write(#186,'Ролики...',#186);
			gt(x1,13);write(#200);for i:=1 to 9 do write(#205);write(#188);
			gt(x1,15);write(#201);for i:=1 to 8 do write(#205);write(#187);
			gt(x1,16);write(#186,'Назад...',#186);
			gt(x1,17);write(#200);for i:=1 to 8 do write(#205);write(#188);
			inf_m_n;
			end;
		    2:
			begin
			risyn_smile_big;
			tb(chv_m);
			clrscr;
			k:=2;
			k1:=1;
			inf_m_n;
			t(15);
			gt(x1,11);write(#201);for i:=1 to 9 do write(#205);write(#187);
			gt(x1,12);write(#186,'Ролики...',#186);
			gt(x1,13);write(#200);for i:=1 to 9 do write(#205);write(#188);
			gt(x1,15);write(#201);for i:=1 to 8 do write(#205);write(#187);
			gt(x1,16);write(#186,'Назад...',#186);
			gt(x1,17);write(#200);for i:=1 to 8 do write(#205);write(#188);
			gtn;
			end;
		    3:
			begin
			tb(16);
			risyn;
			risyn_us;
			for i:=1 to 10 do if keypressed then rrr:=readkey;
			rrr:=' ';
			tb(chv_m);
			clrscr;
			k:=3;
			k1:=2;
			inf_m_n;
			t(15);
			gt(x1,15);write(#201);for i:=1 to 8 do write(#205);write(#187);
			gt(x1,16);write(#186,'Назад...',#186);
			gt(x1,17);write(#200);for i:=1 to 8 do write(#205);write(#188);
			gt(x1,3);write(#201);for i:=1 to 8 do write(#205);write(#187);
			gt(x1,4);write(#186,'Цвета...',#186);
			gt(x1,5);write(#200);for i:=1 to 8 do write(#205);write(#188);
			end;
		    4:u:=2;
		    end;
		end;
	if k1<>k then
		begin
		case k of
			1:begin
			  t(chv_k);
			  gt(x1,3);write(#218);for i:=1 to 8 do write(#196);write(#191);
			  gt(x1,4);write(#179,'Цвета...',#179);
			  gt(x1,5);write(#192);for i:=1 to 8 do write(#196);write(#217);
			  {gt;}
			  end;
			2:begin
			  t(chv_k);
			  gt(x1-2,7);write(#218);for i:=1 to 12 do write(#196);write(#191);
			  gt(x1-2,8);write(#179,'Создатели...',#179);
			  gt(x1-2,9);write(#192);for i:=1 to 12 do write(#196);write(#217);
			  {gt;}
			  end;
			3:begin
			  t(chv_k);
			  gt(x1,11);write(#218);for i:=1 to 9 do write(#196);write(#191);
			  gt(x1,12);write(#179,'Ролики...',#179);
			  gt(x1,13);write(#192);for i:=1 to 9 do write(#196);write(#217);
			  {gt;}
			  end;
			4:begin
			  t(chv_k);
			  gt(x1,15);write(#218);for i:=1 to 8 do write(#196);write(#191);
			  gt(x1,16);write(#179,'Назад...',#179);
			  gt(x1,17);write(#192);for i:=1 to 8 do write(#196);write(#217);
			  {gt;}
			  end;
			end;
		case k1 of
			1:begin
			  t(15);
			  gt(x1,3);write(#201);for i:=1 to 8 do write(#205);write(#187);
			  gt(x1,4);write(#186,'Цвета...',#186);
			  gt(x1,5);write(#200);for i:=1 to 8 do write(#205);write(#188);
			  gtn;
			  end;
			2:begin
			  t(15);
			  gt(x1-2,7);write(#201);for i:=1 to 12 do write(#205);write(#187);
			  gt(x1-2,8);write(#186,'Создатели...',#186);
			  gt(x1-2,9);write(#200);for i:=1 to 12 do write(#205);write(#188);
			  gtn;
			  end;
			3:begin
			  t(15);
			  gt(x1,11);write(#201);for i:=1 to 9 do write(#205);write(#187);
			  gt(x1,12);write(#186,'Ролики...',#186);
			  gt(x1,13);write(#200);for i:=1 to 9 do write(#205);write(#188);
			  gtn;
			  end;
			4:begin
			  t(15);
			  gt(x1,15);write(#201);for i:=1 to 8 do write(#205);write(#187);
			  gt(x1,16);write(#186,'Назад...',#186);
			  gt(x1,17);write(#200);for i:=1 to 8 do write(#205);write(#188);
			  gtn;
			  end;
			end;
		k1:=k;
		end;
	end;
end;

{//-----------------------------------------------PR+++}
procedure zapo_m_b( var yy:ar_m_b);
var i,k,g,oo:b;
    r:array[0..9] of ar_m_b;
begin
fillchar(r,sizeof(r),0);
{1111}
r[1,1,1]:=1;
r[1,2,1]:=1;
r[1,3,1]:=1;
r[1,4,1]:=1;
r[1,6,1]:=1;
r[1,10,1]:=1;
r[1,6,2]:=1;
r[1,10,2]:=1;
r[1,6,3]:=1;
r[1,1,3]:=1;
r[1,1,4]:=1;
r[1,1,5]:=1;
r[1,4,6]:=1;
r[1,6,6]:=1;
r[1,8,6]:=1;
r[1,1,7]:=1;
r[1,2,7]:=1;
r[1,2,10]:=1;
r[1,9,9]:=1;
r[1,9,10]:=1;
{kon----1---}
{2222222}
r[2,4,1]:=1;
r[2,5,1]:=1;
r[2,6,1]:=1;
r[2,8,2]:=1;
r[2,2,3]:=1;
r[2,5,4]:=1;
r[2,9,6]:=1;
r[2,3,6]:=1;
r[2,4,6]:=1;
r[2,5,8]:=1;
r[2,6,8]:=1;
r[2,10,2]:=1;
r[2,10,3]:=1;
r[2,10,4]:=1;
r[2,8,9]:=1;
r[2,9,9]:=1;
r[2,1,7]:=1;
r[2,1,8]:=1;
r[2,1,9]:=1;
r[2,1,10]:=1;
{kon----2---}
{33333333}
r[3,2,1]:=1;
r[3,7,1]:=1;
r[3,8,1]:=1;
r[3,10,3]:=1;
r[3,8,3]:=1;
r[3,7,3]:=1;
r[3,6,3]:=1;
r[3,4,3]:=1;
r[3,4,4]:=1;
r[3,4,5]:=1;
r[3,4,6]:=1;
r[3,2,5]:=1;
r[3,7,6]:=1;
r[3,9,8]:=1;
r[3,9,9]:=1;
r[3,4,9]:=1;
r[3,3,9]:=1;
{kon---3---}
{00000000}
r[0,4,1]:=1;
r[0,7,2]:=1;
r[0,8,2]:=1;
r[0,10,2]:=1;
r[0,10,4]:=1;
r[0,9,4]:=1;
r[0,8,4]:=1;
r[0,9,6]:=1;
r[0,9,7]:=1;
r[0,8,10]:=1;
r[0,6,7]:=1;
r[0,6,8]:=1;
r[0,6,9]:=1;
r[0,2,9]:=1;
r[0,2,5]:=1;
r[0,1,5]:=1;
r[0,4,4]:=1;
r[0,4,5]:=1;
r[0,4,6]:=1;
r[0,4,7]:=1;
{kon----0---}
{44444444}
r[4,2,5]:=1;
r[4,2,8]:=1;
r[4,7,8]:=1;
r[4,10,9]:=1;


randomize;
oo:=random(4);
case s_ran(1,2) of

1:for k:=1 to 10 do
	for g:=1 to 10 do
		yy[k,g]:=r[oo,k,g];

2:for k:=1 to 10 do
	for g:=1 to 10 do
		yy[k,g]:=r[oo,g,k];
3:for k:=1 to 10 do
	for g:=1 to 10 do
		yy[g,k]:=r[oo,k,g];
4:for k:=1 to 10 do
	for g:=1 to 10 do
		yy[g,k]:=r[oo,g,k];
end;
end;
{//------------------------------------------------------------PR+++}
procedure nach_m_b;
var     igr,pr:ar_m_b;
	ext:boolean;
	bool:array[1..10] of boolean;
	w:array[1..10] of b;
	c:char;
	i,ii,k,k1,u,g,g1,pov,n4,vvv,bool11:byte;
begin
zapo;
ext:=false;
fillchar(pr,sizeof(pr),0);
fillchar(igr,sizeof(igr),0);
n4:=7;
k:=1;
k1:=2;
u:=1;
g:=1;
g1:=1;
pov:=1;
textbackground(1);
while u=1 do
	begin
	if keypressed then
		begin
		c:=readkey;
		case c of
		#13,#28:
			case pov of
			1:
				begin
				t(15);
				gotoxy(1+2*k,1+2*g);
				write(#176,#176);
				gotoxy(1+2*k,2+2*g);
				write(#176,#176);
				gotoxy(1+2*k,3+2*g);
				write(#176,#176);
				gotoxy(1+2*k,4+2*g);
				write(#176,#176);
				gotoxy(1+2*k,5+2*g);
				write(#176,#176);
				gotoxy(1+2*k,6+2*g);
				write(#176,#176);
				gotoxy(1+2*k,7+2*g);
				write(#176,#176);
				gotoxy(1+2*k,8+2*g);
				write(#176,#176);
				gotoxy(80,25);
				igr[k,g]:=n4;
				igr[k,g+1]:=n4;
				igr[k,g+2]:=n4;
				igr[k,g+3]:=n4;
				u:=2;
				end;
			2:
				begin
				t(15);
				gotoxy(1+2*k,1+2*g);
				for i:=1 to 8 do write(#176);
				gotoxy(1+2*k,2+2*g);
				for i:=1 to 8 do write(#176);
				gotoxy(80,25);
				igr[k,g]:=n4;
				igr[k+1,g]:=n4;
				igr[k+2,g]:=n4;
				igr[k+3,g]:=n4;
				u:=2;
				end;
			end;
		#72:if g>1 then g:=g-1;{//ВВЕРХ}
		#80:
			if pov=1 then begin if g<7 then g:=g+1 end {//ВНИЗ}
				else if g<10 then g:=g+1;

		#75:if k>1 then k:=k-1;{//ВЛЕВО}
		#77:
			if pov=2 then begin if k<7 then k:=k+1 end
				else if k<10 then k:=k+1;{//ВПРАВО}
		#27:
			begin
			u:=2;
			ext:=true;
			end;
		#9:begin
		   case pov of
			1:begin
			  gotoxy(1+2*k1,1+2*g1);
			  write('  ');
			  gotoxy(1+2*k1,2+2*g1);
			  write('  ');
			  gotoxy(1+2*k1,3+2*g1);
			  write('  ');
			  gotoxy(1+2*k1,4+2*g1);
			  write('  ');
			  gotoxy(1+2*k1,5+2*g1);
			  write('  ');
			  gotoxy(1+2*k1,6+2*g1);
			  write('  ');
			  gotoxy(1+2*k1,7+2*g1);
			  write('  ');
			  gotoxy(1+2*k1,8+2*g1);
			  write('  ');
			  if k>7 then
				begin
				k1:=7;
				k:=7;
				end;
			  textcolor(chv_k);
			  gotoxy(1+2*k,1+2*g);
			  {//write(#177,#177);}
			  for i:=1 to 8 do write(#177);
			  gotoxy(1+2*k,2+2*g);
			  {//write(#177,#177);}
			  for i:=1 to 8 do write(#177);
			  {//if g1<8 then g1:=g1+1 else g1:=g1-1;}
			  gotoxy(80,25);
			  end;
			2:begin
			  gotoxy(1+2*k1,1+2*g1);
			  write('	');
			  gotoxy(1+2*k1,2+2*g1);
			  write('	');
			  if g>7 then
				begin
				g:=7;
				g1:=7;
				end;
			  textcolor(chv_k);
			  gotoxy(1+2*k,1+2*g);
			  write(#177,#177);
			  gotoxy(1+2*k,2+2*g);
			  write(#177,#177);
			  gotoxy(1+2*k,3+2*g);
			  write(#177,#177);
			  gotoxy(1+2*k,4+2*g);
			  write(#177,#177);
			  gotoxy(1+2*k,5+2*g);
			  write(#177,#177);
			  gotoxy(1+2*k,6+2*g);
			  write(#177,#177);
			  gotoxy(1+2*k,7+2*g);
			  write(#177,#177);
			  gotoxy(1+2*k,8+2*g);
			  write(#177,#177);
			  gotoxy(80,25);
			  {//if k1<8 then k1:=k1+1 else k1:=k1-1;}
			  end;
		   end;
		   if pov=1 then pov:=2 else
		   if pov=2 then pov:=1;
		   end;
		end;
		end;
	if ((k1<>k) or (g1<>g)) then
		begin
		case pov of
		1:
		{//----------------------POV___111111111111111111}
		begin
		if k1<>k then
		begin
		textcolor(chv_k);
		gotoxy(1+2*k,1+2*g);
		write(#177,#177);
		gotoxy(1+2*k,2+2*g);
		write(#177,#177);
		gotoxy(1+2*k,3+2*g);
		write(#177,#177);
		gotoxy(1+2*k,4+2*g);
		write(#177,#177);
		gotoxy(1+2*k,5+2*g);
		write(#177,#177);
		gotoxy(1+2*k,6+2*g);
		write(#177,#177);
		gotoxy(1+2*k,7+2*g);
		write(#177,#177);
		gotoxy(1+2*k,8+2*g);
		write(#177,#177);
		{//-----------------}
		gotoxy(1+2*k1,1+2*g1);
		write('  ');
		gotoxy(1+2*k1,2+2*g1);
		write('  ');
		gotoxy(1+2*k1,3+2*g1);
		write('  ');
		gotoxy(1+2*k1,4+2*g1);
		write('  ');
		gotoxy(1+2*k1,5+2*g1);
		write('  ');
		gotoxy(1+2*k1,6+2*g1);
		write('  ');
		gotoxy(1+2*k1,7+2*g1);
		write('  ');
		gotoxy(1+2*k1,8+2*g1);
		write('  ');
		k1:=k;
		g1:=g;
		gotoxy(80,25);
		end;
		{//------------------------------------}
		if g>g1 then
			begin
			gotoxy(1+2*k1,1+2*g1);
			write('  ');
			gotoxy(1+2*k1,2+2*g1);
			write('  ');
			{//-------------}
			gotoxy(1+2*k,7+2*g);
			write(#177,#177);
			gotoxy(1+2*k,8+2*g);
			write(#177,#177);
			k1:=k;
			g1:=g;
			gotoxy(80,25);
			end;
		{//-------------------------------------}
		if g<g1 then
			begin
			gotoxy(1+2*k1,-1+2*g1);
			write(#177,#177);
			gotoxy(1+2*k1,2*g1);
			write(#177,#177);
			{//-------------}
			gotoxy(1+2*k,9+2*g);
			write('  ');
			gotoxy(1+2*k,10+2*g);
			write('  ');
			k1:=k;
			g1:=g;
			gotoxy(80,25);
			end;
		end;
		2:      {//-----------------------------POV____2222222222222222}
			begin


			if g1<>g then
			begin
			textcolor(chv_k);
			gotoxy(1+2*k,1+2*g);
			{//write(#177,#177);}
			for i:=1 to 8 do write(#177);
			gotoxy(1+2*k,2+2*g);
			{//write(#177,#177);}
			for i:=1 to 8 do write(#177);
			{//-----------------}
			gotoxy(1+2*k1,1+2*g1);
			write('	');
			gotoxy(1+2*k1,2+2*g1);
			write('	');
			k1:=k;
			g1:=g;
			gotoxy(80,25);
			end;
			if k>k1 then
				begin
				gotoxy(1+2*k1,1+2*g1);
				write('  ');
				gotoxy(1+2*k1,2+2*g1);
				write('  ');
				{//-------------}
				gotoxy(7+2*k,1+2*g);
				write(#177,#177);
				gotoxy(7+2*k,2+2*g);
				write(#177,#177);
				k1:=k;
				g1:=g;
				gotoxy(80,25);
				end;
			if k<k1 then
			begin
			gotoxy(7+2*k1,1+2*g1);
			write('  ');
			gotoxy(7+2*k1,2+2*g1);
			write('  ');
			{//-------------}
			gotoxy(1+2*k,1+2*g);
			write(#177,#177);
			gotoxy(1+2*k,2+2*g);
			write(#177,#177);
			k1:=k;
			g1:=g;
			gotoxy(80,25);
			end;
			end;



		end;
		end;
	end;


{ Начало 3-------палубы!!!!!!!!!}
fillchar(bool,sizeof(bool),true);
vvv:=1;
while not ((vvv>2) or (ext=true)) do
begin
inc(vvv);
k:=1;
k1:=2;
u:=1;
g:=1;
pov:=1;
g1:=2;
		{111111111}
		if ((k=1) or (g=1)) then bool[1]:=true else
			begin
			if igr[k-1,g-1]=0 then bool[1]:=true
				else bool[1]:=false;
			end;
		{2222222}
		if g=1 then bool[2]:=true else
			if igr[k,g-1]=0 then bool[2]:=true
				else bool[2]:=false;
		{333333333}
		if ((k=10) or (g=1)) then bool[3]:=true else
			if igr[k+1,g-1]=0 then bool[3]:=true
				else bool[3]:=false;
		{444444444444}
		if k=10 then bool[4]:=true else
			if ((igr[k+1,g]=0) and (igr[k+1,g+1]=0) and (igr[k+1,g+2]=0)) then
				bool[4]:=true else bool[4]:=false;
		{5555555555}
		if ((k=10) or (g=8)) then bool[5]:=true else
			if igr[k+1,g+3]=0 then bool[5]:=true
				else bool[5]:=false;
		{6666666666666}
		if g=8 then bool[6]:=true else
			if igr[k,g+3]=0 then bool[6]:=true
				else bool[6]:=false;
		{777777777}
		if ((k=1) or (g=8)) then bool[7]:=true else
			if igr[k-1,g+3]=0 then bool[7]:=true
				else bool[7]:=false;
		{888888888}
		if k=1 then bool[8]:=true else
			if ((igr[k-1,g]=0) and (igr[k-1,g+1]=0) and (igr[k-1,g+2]=0)) then
				bool[8]:=true else bool[8]:=false;
		{999999999999}
		if ((igr[k,g]=0) and (igr[k,g+1]=0) and (igr[k,g+2]=0)) then bool[9]:=true
			else bool[9]:=false;
		{---------10-------}
		bool11:=0;
		for i:=1 to 9 do
			if bool[i]=false then inc(bool11);
		if bool11=0 then bool[10]:=true else bool[10]:=false;
		if bool[10]=true then t(chv_k) else t(12);
gotoxy(1+2*k,1+2*g);
write(#177,#177);
gotoxy(1+2*k,2+2*g);
write(#177,#177);
gotoxy(1+2*k,3+2*g);
write(#177,#177);
gotoxy(1+2*k,4+2*g);
write(#177,#177);
gotoxy(1+2*k,5+2*g);
write(#177,#177);
gotoxy(1+2*k,6+2*g);
write(#177,#177);
k1:=k;
g1:=g;
gotoxy(80,25);
t(15);
while u=1 do
	begin
	if keypressed then
		begin
		c:=readkey;
		case c of
		#72:if g>1 then g:=g-1;{//ВВЕРХ}
		#80:if pov=1 then begin if g<8 then g:=g+1 end {//ВНИЗ}
				else if g<10 then g:=g+1;
{}		#75:if k>1 then k:=k-1;{//ВЛЕВО}
		#77:if pov=2 then begin if k<8 then k:=k+1 end
				else if k<10 then k:=k+1;{//ВПРАВО}
		#27:
			begin
			u:=2;
			ext:=true;
			end;
		#1:
			begin
			clrscr;
			for ii:=1 to 10 do
				for i:=1 to 10 do
					if i=10 then  writeln(igr[i,ii])
						else write(igr[i,ii]);
			u:=2;
			readln;
			end;
		#13,#28:
			begin
			if bool[10]=true then
			begin
			case pov of
			1:
				begin
				igr[k,g]:=5;
				igr[k,g+1]:=5;
				igr[k,g+2]:=5;
				t(15);
				gotoxy(1+2*k,1+2*g);
				write(#176,#176);
				gotoxy(1+2*k,2+2*g);
				write(#176,#176);
				gotoxy(1+2*k,3+2*g);
				write(#176,#176);
				gotoxy(1+2*k,4+2*g);
				write(#176,#176);
				gotoxy(1+2*k,5+2*g);
				write(#176,#176);
				gotoxy(1+2*k,6+2*g);
				write(#176,#176);
				end;
			2:
				begin
				igr[k,g]:=5;
				igr[k+1,g]:=5;
				igr[k+2,g]:=5;
				t(15);
				gotoxy(1+2*k,1+2*g);
				write(#176,#176,#176,#176,#176,#176);
				gotoxy(1+2*k,2+2*g);
				write(#176,#176,#176,#176,#176,#176);
				end;
			end;
			u:=2;
			end else
				begin
				gt(62,12);
				tb(chv_ig);
				t(12);
				write('Невозможно!!!!');
				gtn;
				delay(1000);
				gt(62,12);
				write('	      ');
				tb(1);
				gtn;
				end;
			end;
		#9:
			begin
			case pov of
			1:
				begin
				if igr[k1,g1]=0 then
			begin
			gotoxy(1+2*k1,1+2*g1);
			write('  ');
			gotoxy(1+2*k1,2+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(1+2*k1,1+2*g1);
			write(#176,#176);
			gotoxy(1+2*k1,2+2*g1);
			write(#176,#176);
			end;
		if igr[k1,g1+1]=0 then
			begin
			gotoxy(1+2*k1,3+2*g1);
			write('  ');
			gotoxy(1+2*k1,4+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(1+2*k1,3+2*g1);
			write(#176,#176);
			gotoxy(1+2*k1,4+2*g1);
			write(#176,#176);
			end;
		if igr[k1,g1+2]=0 then
			begin
			gotoxy(1+2*k1,5+2*g1);
			write('  ');
			gotoxy(1+2*k1,6+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(1+2*k1,5+2*g1);
			write(#176,#176);
			gotoxy(1+2*k1,6+2*g1);
			write(#176,#176);
			end;
				t(chv_k);{--------------}
				if k>8 then
					begin
					k:=8;
					k1:=8;
					end;
				{---------1---------}
		IF ((K=1) OR (G=1)) THEN bool[1]:=true else
			if igr[k-1,g-1]=0 then bool[1]:=true
				else bool[1]:=false;
		{---------2-----------}
		if g=1 then bool[2]:=true else
			if ((igr[k,g-1]=0) and (igr[k+1,g-1]=0) and (igr[k+2,g-1]=0)) then bool[2]:=true
				else bool[2]:=false;
		{---------3---------}
		if ((k=8) or (g=1)) then bool[3]:=true else
			if igr[k+3,g-1]=0 then bool[3]:=true
				else bool[3]:=false;
		{------------4---------}
		if k=8 then bool[4]:=true else
			if igr[k+3,g]=0 then bool[4]:=true
				else bool[4]:=false;
		{---------5------}
		if ((k=8) or (g=10)) then bool[5]:=true else
			if igr[k+3,g+1]=0 then bool[5]:=true
				else bool[5]:=false;
		{------6------}
		if g=10 then bool[6]:=true else
			if ((igr[k,g+1]=0) and (igr[k+1,g+1]=0) and (igr[k+2,g+1]=0)) then bool[6]:=true
				else bool[6]:=false;
		{------7------}
		if ((k=1) or (g=10)) then bool[7]:=true else
			if igr[k-1,g+1]=0 then bool[7]:=true
				else bool[7]:=false;
		{---8---}
		if k=1 then bool[8]:=true else
			if igr[k-1,g]=0 then bool[8]:=true
				else bool[8]:=false;
		{--9--}
		if ((igr[k,g]=0) and (igr[k+1,g]=0) and (igr[k+2,g]=0)) then bool[9]:=true
			else bool[9]:=false;
		bool11:=0;
		for i:=1 to 9 do if bool[i]=false then inc(bool11);
		if bool11=0 then t(chv_k) else t(12);
				gotoxy(1+2*k,1+2*g);
				write(#177,#177,#177,#177,#177,#177);
				gotoxy(1+2*k,2+2*g);
				write(#177,#177,#177,#177,#177,#177);
				gtn;
				end;
			2:
				begin
			if igr[k1,g1]=0 then
				begin
				gotoxy(1+2*k1,1+2*g1);
				write('  ');
				gotoxy(1+2*k1,2+2*g1);
				write('  ');
				end
			else
				begin
				t(15);
				gotoxy(1+2*k1,1+2*g1);
				write(#176,#176);
				gotoxy(1+2*k1,2+2*g1);
				write(#176,#176);
				end;
			if igr[k1+1,g1]=0 then
				begin
				gotoxy(3+2*k1,1+2*g1);
				write('  ');
				gotoxy(3+2*k1,2+2*g1);
				write('  ');
				end
			else
				begin
				t(15);
				gotoxy(3+2*k1,1+2*g1);
				write(#176,#176);
				gotoxy(3+2*k1,2+2*g1);
				write(#176,#176);
				end;
			if igr[k1+2,g1]=0 then
				begin
				gotoxy(5+2*k1,1+2*g1);
				write('  ');
				gotoxy(5+2*k1,2+2*g1);
				write('  ');
				end
			else
				begin
				t(15);
				gotoxy(5+2*k1,1+2*g1);
				write(#176,#176);
				gotoxy(5+2*k1,2+2*g1);
				write(#176,#176);
				end;
				t(chv_k);{-------------}
				if g>8 then
					begin
					g:=8;
					g1:=8;
					end;
				{111111111}
		if ((k=1) or (g=1)) then bool[1]:=true else
			begin
			if igr[k-1,g-1]=0 then bool[1]:=true
				else bool[1]:=false;
			end;
		{2222222}
		if g=1 then bool[2]:=true else
			if igr[k,g-1]=0 then bool[2]:=true
				else bool[2]:=false;
		{333333333}
		if ((k=10) or (g=1)) then bool[3]:=true else
			if igr[k+1,g-1]=0 then bool[3]:=true
				else bool[3]:=false;
		{444444444444}
		if k=10 then bool[4]:=true else
			if ((igr[k+1,g]=0) and (igr[k+1,g+1]=0) and (igr[k+1,g+2]=0)) then
				bool[4]:=true else bool[4]:=false;
		{5555555555}
		if ((k=10) or (g=8)) then bool[5]:=true else
			if igr[k+1,g+3]=0 then bool[5]:=true
				else bool[5]:=false;
		{6666666666666}
		if g=8 then bool[6]:=true else
			if igr[k,g+3]=0 then bool[6]:=true
				else bool[6]:=false;
		{777777777}
		if ((k=1) or (g=8)) then bool[7]:=true else
			if igr[k-1,g+3]=0 then bool[7]:=true
				else bool[7]:=false;
		{888888888}
		if k=1 then bool[8]:=true else
			if ((igr[k-1,g]=0) and (igr[k-1,g+1]=0) and (igr[k-1,g+2]=0)) then
				bool[8]:=true else bool[8]:=false;
		{999999999999}
		if ((igr[k,g]=0) and (igr[k,g+1]=0) and (igr[k,g+2]=0)) then bool[9]:=true
			else bool[9]:=false;
		{---------10-------}
		bool11:=0;
		for i:=1 to 9 do
			if bool[i]=false then inc(bool11);
		if bool11=0 then bool[10]:=true else bool[10]:=false;
		if bool[10]=true then t(chv_k) else t(12);
				gotoxy(1+2*k,1+2*g);
				write(#177,#177);
				gotoxy(1+2*k,2+2*g);
				write(#177,#177);
				gotoxy(1+2*k,3+2*g);
				write(#177,#177);
				gotoxy(1+2*k,4+2*g);
				write(#177,#177);
				gotoxy(1+2*k,5+2*g);
				write(#177,#177);
				gotoxy(1+2*k,6+2*g);
				write(#177,#177);
				gtn;
				end;
			end;
			if  pov=1 then pov:=2 else pov:=1;
			end;
		end;
	if ((k1<>k) or (g1<>g)) then
		begin
		case pov of
		1:
		begin
		if igr[k1,g1]=0 then
			begin
			gotoxy(1+2*k1,1+2*g1);
			write('  ');
			gotoxy(1+2*k1,2+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(1+2*k1,1+2*g1);
			write(#176,#176);
			gotoxy(1+2*k1,2+2*g1);
			write(#176,#176);
			end;
		if igr[k1,g1+1]=0 then
			begin
			gotoxy(1+2*k1,3+2*g1);
			write('  ');
			gotoxy(1+2*k1,4+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(1+2*k1,3+2*g1);
			write(#176,#176);
			gotoxy(1+2*k1,4+2*g1);
			write(#176,#176);
			end;
		if igr[k1,g1+2]=0 then
			begin
			gotoxy(1+2*k1,5+2*g1);
			write('  ');
			gotoxy(1+2*k1,6+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(1+2*k1,5+2*g1);
			write(#176,#176);
			gotoxy(1+2*k1,6+2*g1);
			write(#176,#176);
			end;
		{//---------}
		t(chv_k);
		fillchar(bool,sizeof(bool),false);
		{111111111}
		if ((k=1) or (g=1)) then bool[1]:=true else
			begin
			if igr[k-1,g-1]=0 then bool[1]:=true
				else bool[1]:=false;
			end;
		{2222222}
		if g=1 then bool[2]:=true else
			if igr[k,g-1]=0 then bool[2]:=true
				else bool[2]:=false;
		{333333333}
		if ((k=10) or (g=1)) then bool[3]:=true else
			if igr[k+1,g-1]=0 then bool[3]:=true
				else bool[3]:=false;
		{444444444444}
		if k=10 then bool[4]:=true else
			if ((igr[k+1,g]=0) and (igr[k+1,g+1]=0) and (igr[k+1,g+2]=0)) then
				bool[4]:=true else bool[4]:=false;
		{5555555555}
		if ((k=10) or (g=8)) then bool[5]:=true else
			if igr[k+1,g+3]=0 then bool[5]:=true
				else bool[5]:=false;
		{6666666666666}
		if g=8 then bool[6]:=true else
			if igr[k,g+3]=0 then bool[6]:=true
				else bool[6]:=false;
		{777777777}
		if ((k=1) or (g=8)) then bool[7]:=true else
			if igr[k-1,g+3]=0 then bool[7]:=true
				else bool[7]:=false;
		{888888888}
		if k=1 then bool[8]:=true else
			if ((igr[k-1,g]=0) and (igr[k-1,g+1]=0) and (igr[k-1,g+2]=0)) then
				bool[8]:=true else bool[8]:=false;
		{999999999999}
		if ((igr[k,g]=0) and (igr[k,g+1]=0) and (igr[k,g+2]=0)) then bool[9]:=true
			else bool[9]:=false;
		{---------10-------}
		bool11:=0;
		for i:=1 to 9 do
			if bool[i]=false then inc(bool11);
		if bool11=0 then bool[10]:=true else bool[10]:=false;
		if bool[10]=true then t(chv_k) else t(12);
		gotoxy(1+2*k,1+2*g);
		write(#177,#177);
		gotoxy(1+2*k,2+2*g);
		write(#177,#177);
		gotoxy(1+2*k,3+2*g);
		write(#177,#177);
		gotoxy(1+2*k,4+2*g);
		write(#177,#177);
		gotoxy(1+2*k,5+2*g);
		write(#177,#177);
		gotoxy(1+2*k,6+2*g);
		write(#177,#177);
		k1:=k;
		g1:=g;
		gotoxy(80,25);
		end;
		2:
		begin
		if igr[k1,g1]=0 then
			begin
			gotoxy(1+2*k1,1+2*g1);
			write('  ');
			gotoxy(1+2*k1,2+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(1+2*k1,1+2*g1);
			write(#176,#176);
			gotoxy(1+2*k1,2+2*g1);
			write(#176,#176);
			end;
		if igr[k1+1,g1]=0 then
			begin
			gotoxy(3+2*k1,1+2*g1);
			write('  ');
			gotoxy(3+2*k1,2+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(3+2*k1,1+2*g1);
			write(#176,#176);
			gotoxy(3+2*k1,2+2*g1);
			write(#176,#176);
			end;
		if igr[k1+2,g1]=0 then
			begin
			gotoxy(5+2*k1,1+2*g1);
			write('  ');
			gotoxy(5+2*k1,2+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(5+2*k1,1+2*g1);
			write(#176,#176);
			gotoxy(5+2*k1,2+2*g1);
			write(#176,#176);
			end;
		{////-----}
		fillchar(bool,sizeof(bool),true);
		{---------1---------}
		IF ((K=1) OR (G=1)) THEN bool[1]:=true else
			if igr[k-1,g-1]=0 then bool[1]:=true
				else bool[1]:=false;
		{---------2-----------}
		if g=1 then bool[2]:=true else
			if ((igr[k,g-1]=0) and (igr[k+1,g-1]=0) and (igr[k+2,g-1]=0)) then bool[2]:=true
				else bool[2]:=false;
		{---------3---------}
		if ((k=8) or (g=1)) then bool[3]:=true else
			if igr[k+3,g-1]=0 then bool[3]:=true
				else bool[3]:=false;
		{------------4---------}
		if k=8 then bool[4]:=true else
			if igr[k+3,g]=0 then bool[4]:=true
				else bool[4]:=false;
		{---------5------}
		if ((k=8) or (g=10)) then bool[5]:=true else
			if igr[k+3,g+1]=0 then bool[5]:=true
				else bool[5]:=false;
		{------6------}
		if g=10 then bool[6]:=true else
			if ((igr[k,g+1]=0) and (igr[k+1,g+1]=0) and (igr[k+2,g+1]=0)) then bool[6]:=true
				else bool[6]:=false;
		{------7------}
		if ((k=1) or (g=10)) then bool[7]:=true else
			if igr[k-1,g+1]=0 then bool[7]:=true
				else bool[7]:=false;
		{---8---}
		if k=1 then bool[8]:=true else
			if igr[k-1,g]=0 then bool[8]:=true
				else bool[8]:=false;
		{--9--}
		if ((igr[k,g]=0) and (igr[k+1,g]=0) and (igr[k+2,g]=0)) then bool[9]:=true
			else bool[9]:=false;
		bool11:=0;
		for i:=1 to 9 do if bool[i]=false then inc(bool11);
		if bool11=0 then bool[10]:=true else bool[10]:=false;
		if bool11=0 then t(chv_k) else t(12);
		gotoxy(1+2*k,1+2*g);
		write(#177,#177,#177,#177,#177,#177);
		gotoxy(1+2*k,2+2*g);
		write(#177,#177,#177,#177,#177,#177);
		k1:=k;
		g1:=g;
		gotoxy(80,25);
		end;
		end;
		end;
		end;
	end;
end;{Это END от vvv!!!!!!}

vvv:=1;
while not ((vvv>3) or (ext=true)) do
begin
k:=1;
k1:=2;
u:=1;
g:=1;
g1:=1;
inc(vvv);
pov:=1;
while u=1 do
	begin
	if keypressed then
		begin
		case readkey of
		#72:if g>1 then g:=g-1;{//ВВЕРХ}
		#80:if pov=1 then begin if g<9 then g:=g+1 end
			else if g<10 then g:=g+1;{//ВНИЗ}
		#75:if k>1 then k:=k-1;{//ВЛЕВО}
		#77:if pov=2 then begin if k<9 then k:=k+1 end
			else if k<10 then k:=k+1;{//ВПРАВО}
		#27:
			begin
			u:=2;
			ext:=true;
			end;
		#13:
			begin
			if bool[10]=TRUE then
				begin
				case pov of
				1:
					begin
					t(15);
					gotoxy(1+2*k,1+2*g);
					write(#176,#176);
					gotoxy(1+2*k,2+2*g);
					write(#176,#176);
					gotoxy(1+2*k,3+2*g);
					write(#176,#176);
					gotoxy(1+2*k,4+2*g);
					write(#176,#176);
					igr[k,g]:=3;
					igr[k,g+1]:=3;
					gtn;
					end;
				2:
					begin
					textcolor(15);
					gotoxy(1+2*k,1+2*g);
					write(#176,#176,#176,#176);
					gotoxy(1+2*k,2+2*g);
					write(#176,#176,#176,#176);
					igr[k,g]:=3;
					igr[k+1,g]:=3;
					gtn;
					end;
				end;
				u:=2;
				end
			else
				begin
				gt(62,12);
				tb(chv_ig);
				t(12);
				write('Невозможно!!!!');
				gtn;
				delay(1000);
				gt(62,12);
				write('	      ');
				tb(1);
				gtn;
				end;
			end;
		#9:
			begin
			CASE POV OF
			1:
				begin
				if igr[k1,g1]=0 then
			begin
			gotoxy(1+2*k1,1+2*g1);
			write('  ');
			gotoxy(1+2*k1,2+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(1+2*k1,1+2*g1);
			write(#176,#176);
			gotoxy(1+2*k1,2+2*g1);
			write(#176,#176);
			end;
		if igr[k1,g1+1]=0 then
			begin
			gotoxy(1+2*k1,3+2*g1);
			write('  ');
			gotoxy(1+2*k1,4+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(1+2*k1,3+2*g1);
			write(#176,#176);
			gotoxy(1+2*k1,4+2*g1);
			write(#176,#176);
			end;
				if k>9 then
					begin
					k:=9;
					k1:=9;
					end;
				{!!!!!!!!!!!!!!}
				bool11:=0;
		{----------1----------}
		if ((g=1) or (k=1)) then bool[1]:=true else
			if igr[k-1,g-1]=0 then bool[1]:=true else
				bool[1]:=false;
		{---------2---------}
		if g=1 then bool[2]:=true else
			if ((igr[k,g-1]=0) and (igr[k+1,g-1]=0)) then bool[2]:=true else
				bool[2]:=false;
		{--------3-------}
		if ((g=1) or (k=9)) then bool[3]:=true else
			if igr[k+2,g-1]=0 then bool[3]:=true else
				bool[3]:=false;
		{------4-------}
		if k=9 then bool[4]:=true else
			if igr[k+2,g]=0 then bool[4]:=true else
				bool[4]:=false;
		{------5------}
		if ((k=9) or (g=10)) then bool[5]:=true else
			if igr[k+2,g+1]=0 then bool[5]:=true else
				bool[5]:=false;
		{-----6-----}
		if g=10 then bool[6]:=true else
			if ((igr[k+1,g+1]=0) and (igr[k,g+1]=0)) then bool[6]:=true else
				bool[6]:=false;
		{----7----}
		if ((g=10) or (k=1)) then bool[7]:=true else
			if igr[k-1,g+1]=0 then bool[7]:=true else
				bool[7]:=false;
		{---8---}
		if k=1 then bool[8]:=true else
			if igr[k-1,g]=0 then bool[8]:=true else
				bool[8]:=false;
		{--9--}
		if ((igr[k,g]=0) and (igr[k+1,g]=0)) then bool[9]:=true else
			bool[9]:=false;
		for i:=1 to 9 do if bool[i]=false then inc(bool11);
		if bool11=0 then
			begin
			bool[10]:=true;
			t(chv_k);
			end
		else
			begin
			bool[10]:=false;
			t(12);
			end;
				gotoxy(1+2*k,1+2*g);
				write(#177,#177,#177,#177);
				gotoxy(1+2*k,2+2*g);
				write(#177,#177,#177,#177);
				end;
			2:
				begin
				if igr[k1,g1]=0 then
			begin
			gotoxy(1+2*k1,1+2*g1);
			write('  ');
			gotoxy(1+2*k1,2+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(1+2*k1,1+2*g1);
			write(#176,#176);
			gotoxy(1+2*k1,2+2*g1);
			write(#176,#176);
			end;
		if igr[k1+1,g1]=0 then
			begin
			gotoxy(3+2*k1,1+2*g1);
			write('  ');
			gotoxy(3+2*k1,2+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(3+2*k1,1+2*g1);
			write(#176,#176);
			gotoxy(3+2*k1,2+2*g1);
			write(#176,#176);
			end;
				if g>9 then
					begin
					g:=9;
					g1:=9;
					end;
				{!!!!!!!!!!!!!!!!!}
				bool11:=0;
		fillchar(bool,sizeof(bool),false);
		{----------1----------}
		if ((g=1) or (k=1)) then bool[1]:=true else
			if igr[k-1,g-1]=0 then bool[1]:=true else
				bool[1]:=false;
		{---------2---------}
		if g=1 then bool[2]:=true else
			if ((igr[k,g-1]=0)) then bool[2]:=true else
				bool[2]:=false;
		{--------3-------}
		if ((g=1) or (k=10)) then bool[3]:=true else
			if igr[k+1,g-1]=0 then bool[3]:=true else
				bool[3]:=false;
		{------4-------}
		if k=10 then bool[4]:=true else
			if ((igr[k+1,g]=0) and (igr[k+1,g+1]=0)) then bool[4]:=true else
				bool[4]:=false;
		{------5------}
		if ((k=10) or (g=9)) then bool[5]:=true else
			if igr[k+1,g+2]=0 then bool[5]:=true else
				bool[5]:=false;
		{-----6-----}
		if g=9 then bool[6]:=true else
			if ((igr[k,g+2]=0)) then bool[6]:=true else
				bool[6]:=false;
		{----7----}
		if ((g=9) or (k=1)) then bool[7]:=true else
			if igr[k-1,g+2]=0 then bool[7]:=true else
				bool[7]:=false;
		{---8---}
		if k=1 then bool[8]:=true else
			if ((igr[k-1,g]=0) and (igr[k-1,g+1]=0)) then bool[8]:=true else
				bool[8]:=false;
		{--9--}
		if ((igr[k,g]=0) and (igr[k,g+1]=0)) then bool[9]:=true else
			bool[9]:=false;
		for i:=1 to 9 do if bool[i]=false then inc(bool11);
		if bool11=0 then
			begin
			bool[10]:=true;
			t(chv_k);
			end
		else
			begin
			bool[10]:=false;
			t(12);
			end;
				gotoxy(1+2*k,1+2*g);
				write(#177,#177);
				gotoxy(1+2*k,2+2*g);
				write(#177,#177);
				gotoxy(1+2*k,3+2*g);
				write(#177,#177);
				gotoxy(1+2*k,4+2*g);
				write(#177,#177);
				end;
			end;
			if pov=1 then pov:=2 else pov:=1;
			gtn;
			end;
		end;
		end;
	if ((k1<>k) or (g1<>g)) then       {----!!---IF-(K<>G)----!!----}
		begin
		case pov of
		1:
		begin
		if igr[k1,g1]=0 then
			begin
			gotoxy(1+2*k1,1+2*g1);
			write('  ');
			gotoxy(1+2*k1,2+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(1+2*k1,1+2*g1);
			write(#176,#176);
			gotoxy(1+2*k1,2+2*g1);
			write(#176,#176);
			end;
		if igr[k1,g1+1]=0 then
			begin
			gotoxy(1+2*k1,3+2*g1);
			write('  ');
			gotoxy(1+2*k1,4+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(1+2*k1,3+2*g1);
			write(#176,#176);
			gotoxy(1+2*k1,4+2*g1);
			write(#176,#176);
			end;
		{//-----------------}
		bool11:=0;
		fillchar(bool,sizeof(bool),false);
		{----------1----------}
		if ((g=1) or (k=1)) then bool[1]:=true else
			if igr[k-1,g-1]=0 then bool[1]:=true else
				bool[1]:=false;
		{---------2---------}
		if g=1 then bool[2]:=true else
			if ((igr[k,g-1]=0)) then bool[2]:=true else
				bool[2]:=false;
		{--------3-------}
		if ((g=1) or (k=10)) then bool[3]:=true else
			if igr[k+1,g-1]=0 then bool[3]:=true else
				bool[3]:=false;
		{------4-------}
		if k=10 then bool[4]:=true else
			if ((igr[k+1,g]=0) and (igr[k+1,g+1]=0)) then bool[4]:=true else
				bool[4]:=false;
		{------5------}
		if ((k=10) or (g=9)) then bool[5]:=true else
			if igr[k+1,g+2]=0 then bool[5]:=true else
				bool[5]:=false;
		{-----6-----}
		if g=9 then bool[6]:=true else
			if ((igr[k,g+2]=0)) then bool[6]:=true else
				bool[6]:=false;
		{----7----}
		if ((g=9) or (k=1)) then bool[7]:=true else
			if igr[k-1,g+2]=0 then bool[7]:=true else
				bool[7]:=false;
		{---8---}
		if k=1 then bool[8]:=true else
			if ((igr[k-1,g]=0) and (igr[k-1,g+1]=0)) then bool[8]:=true else
				bool[8]:=false;
		{--9--}
		if ((igr[k,g]=0) and (igr[k,g+1]=0)) then bool[9]:=true else
			bool[9]:=false;
		for i:=1 to 9 do if bool[i]=false then inc(bool11);
		if bool11=0 then
			begin
			bool[10]:=true;
			t(chv_k);
			end
		else
			begin
			bool[10]:=false;
			t(12);
			end;
		gotoxy(1+2*k,1+2*g);
		write(#177,#177);
		gotoxy(1+2*k,2+2*g);
		write(#177,#177);
		gotoxy(1+2*k,3+2*g);
		write(#177,#177);
		gotoxy(1+2*k,4+2*g);
		write(#177,#177);
		k1:=k;
		g1:=g;
		gotoxy(80,25);
		end;
		2:
		begin
		if igr[k1,g1]=0 then
			begin
			gotoxy(1+2*k1,1+2*g1);
			write('  ');
			gotoxy(1+2*k1,2+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(1+2*k1,1+2*g1);
			write(#176,#176);
			gotoxy(1+2*k1,2+2*g1);
			write(#176,#176);
			end;
		if igr[k1+1,g1]=0 then
			begin
			gotoxy(3+2*k1,1+2*g1);
			write('  ');
			gotoxy(3+2*k1,2+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(3+2*k1,1+2*g1);
			write(#176,#176);
			gotoxy(3+2*k1,2+2*g1);
			write(#176,#176);
			end;
		{//-----------------}{textcolor(chv_k);}
		bool11:=0;
		{----------1----------}
		if ((g=1) or (k=1)) then bool[1]:=true else
			if igr[k-1,g-1]=0 then bool[1]:=true else
				bool[1]:=false;
		{---------2---------}
		if g=1 then bool[2]:=true else
			if ((igr[k,g-1]=0) and (igr[k+1,g-1]=0)) then bool[2]:=true else
				bool[2]:=false;
		{--------3-------}
		if ((g=1) or (k=9)) then bool[3]:=true else
			if igr[k+2,g-1]=0 then bool[3]:=true else
				bool[3]:=false;
		{------4-------}
		if k=9 then bool[4]:=true else
			if igr[k+2,g]=0 then bool[4]:=true else
				bool[4]:=false;
		{------5------}
		if ((k=9) or (g=10)) then bool[5]:=true else
			if igr[k+2,g+1]=0 then bool[5]:=true else
				bool[5]:=false;
		{-----6-----}
		if g=10 then bool[6]:=true else
			if ((igr[k+1,g+1]=0) and (igr[k,g+1]=0)) then bool[6]:=true else
				bool[6]:=false;
		{----7----}
		if ((g=10) or (k=1)) then bool[7]:=true else
			if igr[k-1,g+1]=0 then bool[7]:=true else
				bool[7]:=false;
		{---8---}
		if k=1 then bool[8]:=true else
			if igr[k-1,g]=0 then bool[8]:=true else
				bool[8]:=false;
		{--9--}
		if ((igr[k,g]=0) and (igr[k+1,g]=0)) then bool[9]:=true else
			bool[9]:=false;
		for i:=1 to 9 do if bool[i]=false then inc(bool11);
		if bool11=0 then
			begin
			bool[10]:=true;
			t(chv_k);
			end
		else
			begin
			bool[10]:=false;
			t(12);
			end;
		gotoxy(1+2*k,1+2*g);
		write(#177,#177,#177,#177);
		gotoxy(1+2*k,2+2*g);
		write(#177,#177,#177,#177);
		k1:=k;
		g1:=g;
		gotoxy(80,25);
		end;
		end;
		end;
	end;
end;{eto END ot VVV!!!!!!}

vvv:=1;
while not ((vvv>4) or (ext=true)) do
begin
inc(vvv);
k:=1;
k1:=2;
u:=1;
g:=1;
g1:=1;
while u=1 do
	begin
	if ((k1<>k) or (g1<>g)) then
		begin
		if igr[k1,g1]=0 then
			begin
			gotoxy(1+2*k1,1+2*g1);
			write('  ');
			gotoxy(1+2*k1,2+2*g1);
			write('  ');
			end
		else
			begin
			t(15);
			gotoxy(1+2*k1,1+2*g1);
			write(#176,#176);
			gotoxy(1+2*k1,2+2*g1);
			write(#176,#176);
			end;
		bool11:=0;
		{----------1----------}
		if ((g=1) or (k=1)) then bool[1]:=true else
			if igr[k-1,g-1]=0 then bool[1]:=true else
				bool[1]:=false;
		{---------2---------}
		if g=1 then bool[2]:=true else
			if ((igr[k,g-1]=0)) then bool[2]:=true else
				bool[2]:=false;
		{--------3-------}
		if ((g=1) or (k=10)) then bool[3]:=true else
			if igr[k+1,g-1]=0 then bool[3]:=true else
				bool[3]:=false;
		{------4-------}
		if k=10 then bool[4]:=true else
			if igr[k+1,g]=0 then bool[4]:=true else
				bool[4]:=false;
		{------5------}
		if ((k=10) or (g=10)) then bool[5]:=true else
			if igr[k+1,g+1]=0 then bool[5]:=true else
				bool[5]:=false;
		{-----6-----}
		if g=10 then bool[6]:=true else
			if ((igr[k,g+1]=0)) then bool[6]:=true else
				bool[6]:=false;
		{----7----}
		if ((g=10) or (k=1)) then bool[7]:=true else
			if igr[k-1,g+1]=0 then bool[7]:=true else
				bool[7]:=false;
		{---8---}
		if k=1 then bool[8]:=true else
			if igr[k-1,g]=0 then bool[8]:=true else
				bool[8]:=false;
		{--9--}
		if ((igr[k,g]=0)) then bool[9]:=true else
			bool[9]:=false;
		for i:=1 to 9 do if bool[i]=false then inc(bool11);
		if bool11=0 then
			begin
			bool[10]:=true;
			t(chv_k);
			end
		else
			begin
			bool[10]:=false;
			t(12);
			end;
		gotoxy(1+2*k,1+2*g);
		write(#177,#177);
		gotoxy(1+2*k,2+2*g);
		write(#177,#177);
		k1:=k;
		g1:=g;
		gotoxy(80,25);
		end;
	if keypressed then
		begin
		c:=readkey;
		case c of
		#72:if g>1 then g:=g-1;//ВВЕРХ
		#80:if g<10 then g:=g+1;//ВНИЗ
		#75:if k>1 then k:=k-1;//ВЛЕВО
		#77:if k<10 then k:=k+1;//ВПРАВО
		#27:
			begin
			u:=2;
			ext:=true;
			end;
		#13,#28:
			CASE bool[10] of
			true:
				begin
				t(15);
				gotoxy(1+2*k,1+2*g);
				write(#176,#176);
				gotoxy(1+2*k,2+2*g);
				write(#176,#176);
				igr[k,g]:=1;
				u:=2;
				end;
			false:
				begin
				gt(62,12);
				tb(chv_ig);
				t(12);
				write('Невозможно!!!!');
				gtn;
				delay(1000);
				gt(62,12);
				write('	      ');
				tb(1);
				gtn;
				end;
			end;
		end;
		end;
	end;
 end;

fillchar(pr,sizeof(pr),0);
zapo_m_b(pr);

k:=1;
k1:=2;
if ext=false then u:=1;
g:=1;
g1:=1;
fillchar(w,sizeof(w),0);
vvv:=s_ran(1,2);
while u=1 do
	begin
	if keypressed then
		begin
		c:=readkey;
		case c of
		#72:if g>1 then g:=g-1;//ВВЕРХ
		#80:if g<10 then g:=g+1;//ВНИЗ
		#75:if k>1 then k:=k-1;//ВЛЕВО
		#77:if k<10 then k:=k+1;//ВПРАВО
		#27:u:=2;
		#13,#28:
			begin
			case pr[k,g] of
			9,2:
				begin
				gt(62,12);
				tb(chv_ig);
				t(12);
				write('Невозможно!!!');
				gtn;
				delay(1000);
				gt(62,12);
				write('	      ');
				tb(1);
				gtn;
				end;
			1:
				begin
				pr[k,g]:=2;
				gt(62,12);
				tb(chv_ig);
				t(10);
				write('Вы попали...',#1);
				gtn;
				delay(1000);
				gt(62,12);
				write('	      ');
				tb(1);
				gtn;
				end;
			0:
				begin
				pr[k,g]:=9;
				gt(62,12);
				tb(chv_ig);
				t(14);
				write('Промох...',#2);
				gtn;
				delay(1000);
				gt(62,12);
				write('	      ');
				tb(1);
				gtn;
				end;
			end;
			end;
		end;
		end;
	if ((k1<>k) or (g1<>g)) then
		begin
		case pr[k1,g1] of
		0,1:
			begin
			t(1);
			tb(0);
			gotoxy(28+2*k1,1+2*g1);
			write(#175,#175);
			gotoxy(28+2*k1,2+2*g1);
			write(#175,#175);
			end;
		9:
			begin
			tb(1);
			gotoxy(28+2*k1,1+2*g1);
			write('  ');
			gotoxy(28+2*k1,2+2*g1);
			write('  ');
			end;
		2:
			begin
			t(15);
			tb(0);
			gotoxy(28+2*k1,1+2*g1);
			write(#178,#178);
			gotoxy(28+2*k1,2+2*g1);
			write(#178,#178);
			end;
		end;
		textcolor(chv_k);
		gotoxy(28+2*k,1+2*g);
		write(#177,#177);
		gotoxy(28+2*k,2+2*g);
		write(#177,#177);
		k1:=k;
		g1:=g;
		gtn;
		end;
	end;
end;


{//------------------------------------------------PR+++}

procedure gl_men_n;
var i:b;
begin
textcolor(chv_m+random(15));
gotoxy(65,1);write(#186,'Главное меню...');
gotoxy(65,2);write(#200);for i:=1 to 15 do write(#205);
textcolor(15);
end;

{//--------------------------------------------------------PR+++}


procedure opch_m_n;
var i:b;
begin
textcolor({div_16(}chv_m+random(15));
gotoxy(72,1);write(#186,'Опции...');
gotoxy(72,2);write(#200);for i:=1 to 8 do write(#205);
textcolor(15);
end;

{//--------------------------------------------------------PR+++}

function vihod_v:b;
var i,x,x1,x2,u,k,k1:b;
	c:char;
begin
clrscr;
x:=1;
x2:=57;
x1:=23;
textcolor(15);
gotoxy(x1,10);write(#201);for i:=1 to 33 do write(#205);write(#187);
gotoxy(x1,15);write(#200);for i:=1 to 33 do write(#205);write(#188);
gotoxy(x1,11);write(#186);
gotoxy(x1,12);write(#186);
gotoxy(x1,13);write(#186);
gotoxy(x1,14);write(#186);
gotoxy(x2,11);write(#186);
gotoxy(x2,12);write(#186);
gotoxy(x2,13);write(#186);
gotoxy(x2,14);write(#186);
gotoxy(25,11);write('Вы действительно хотите выйти ?');
gotoxy(48,14);textcolor(4);textbackground(chv_m);write('Незнаю');
k:=2;
k1:=1;
u:=1;
while u=1 do
	begin
	if k1<>k then
	begin
	case k of
	1:begin
	  gotoxy(27,14);textcolor(10);textbackground(2);write(' Да! ');gotoxy(80,25);
	  end;
	2:begin
	  gotoxy(38,14);textcolor(10);textbackground(2);write(' Нет ');gotoxy(80,25);
	  end;
	3:begin
	  gotoxy(48,14);textcolor(10);textbackground(2);write('Незнаю');gotoxy(80,25);
	  end;
	end;
	case k1 of
	1:begin
	  gotoxy(27,14);textcolor(4);textbackground(chv_m);write(' Да! ');gotoxy(80,25);
	  end;
	2:begin
	  gotoxy(38,14);textcolor(4);textbackground(chv_m);write(' Нет ');gotoxy(80,25);
	  end;
	3:begin
	  gotoxy(48,14);textcolor(4);textbackground(chv_m);write('Незнаю');gotoxy(80,25);
	  end;
	end;
	k1:=k;
	end;
	{//----}
	if keypressed then
		begin
		c:=readkey;
		case c of
		#77:if k<>3 then k:=k+1;
		#75:if k<>1 then k:=k-1;
		#13,#28:
			case k of
				1:begin
				  u:=2;
				  vihod_v:=1;
				  end;
				2:begin
				  u:=2;
				  vihod_v:=0;
				  end;
				3:begin
				  x:=2;
				  u:=2;
				  end;
				end;
				end;
		end;
		end;

{----------------------=====------PR}
if x=2 then
	begin
risyn_fuck;
textbackground(chv_m);
clrscr;
x2:=57;
x1:=23;
textcolor(15);
gotoxy(x1,10);write(#201);for i:=1 to 33 do write(#205);write(#187);
gotoxy(x1,15);write(#200);for i:=1 to 33 do write(#205);write(#188);
gotoxy(x1,11);write(#186);
gotoxy(x1,12);write(#186);
gotoxy(x1,13);write(#186);
gotoxy(x1,14);write(#186);
gotoxy(x2,11);write(#186);
gotoxy(x2,12);write(#186);
gotoxy(x2,13);write(#186);
gotoxy(x2,14);write(#186);
gotoxy(25,11);write('Вы действительно хотите выйти ?');
k:=2;
k1:=1;
u:=1;
while u=1 do
	begin
	if k1<>k then
	begin
	case k of
	1:begin
	  gotoxy(27,14);textcolor(10);textbackground(2);write(' Да! ');gotoxy(80,25);
	  end;
	2:begin
	  gotoxy(49,14);textcolor(10);textbackground(2);write(' Нет ');gotoxy(80,25);
	  end;
	end;
	case k1 of
	1:begin
	  gotoxy(27,14);textcolor(4);textbackground(chv_m);write(' Да! ');gotoxy(80,25);
	  end;
	2:begin
	  gotoxy(49,14);textcolor(4);textbackground(chv_m);write(' Нет ');gotoxy(80,25);
	  end;
	end;
	k1:=k;
	end;
	{//----}
	if keypressed then
		begin
		c:=readkey;
		case c of
		#77:if k<>2 then k:=k+1;
		#75:if k<>1 then k:=k-1;
		#13,#28:
			case k of
				1:begin
				  u:=2;
				  vihod_v:=1;
				  end;
				2:begin
				  u:=2;
				  vihod_v:=0;
				  end;
				end;
				end;
		end;
		end;
		end;
textcolor(15);
textbackground(chv_m);
end;

{//--------------------------------------------------------PR+++}

procedure opch;
var     u,k,k1,i:b;
	c:char;
begin
clrscr;
u:=1;
k:=1;
k1:=2;
opch_m_n;
{//----------H}
textcolor(15);
gotoxy(5,10); write(chr(201)); for i:=1 to 15 do write(chr(205)); write(chr(187),'    ',chr(201),chr(205),chr(187));
gotoxy(5,11); write(chr(186),'Цвет курсора...',chr(186),' ',chv_k,' ',chr(186));
textcolor(chv_k); write(chr(219)); textcolor(15); write(chr(186)); gotoxy(5,12);
write(chr(200)); for i:=1 to 15 do write(chr(205)); write(chr(202)); for i:=1 to 4 do write(chr(205));
write(chr(202),chr(205),chr(188));
{//----------}
gotoxy(5,14); write(chr(201)); for i:=1 to 13 do write(chr(205)); write(chr(187));
gotoxy(5,15); write(chr(186),'Информация...',chr(186));
gotoxy(5,16); write(chr(200)); for i:=1 to 13 do write(chr(205)); write(chr(188));
{//----------K}
gotoxy(5,18); write(chr(201)); for i:=1 to 8 do write(chr(205)); write(chr(187));
gotoxy(5,19); write(chr(186),'Назад...',chr(186));
gotoxy(5,20); write(chr(200)); for i:=1 to 8 do write(chr(205)); write(chr(188));
while u=1 do
begin
if k1<>k then
	begin
		if k=1 then
			begin
			{//---------------------}
			textcolor(chv_k);
			gotoxy(5,2); write(chr(218)); for i:=1 to 12 do write(chr(196));
			write(chr(191),'       ',chr(218),chr(196),chr(191));
			gotoxy(5,3); write(chr(179),'Цвет меню...',chr(179),'    ');
			textcolor(15);if chv_m>9 then write(chv_m) else write(' ',chv_m); textcolor(chv_k);
			write(' ',chr(179));
			textcolor(chv_m); write(chr(219)); textcolor(chv_k);
			write(chr(179)); gotoxy(5,4); write(chr(192)); for i:=1 to 12 do write(chr(196));
			write(chr(193)); for i:=1 to 7 do write(chr(196)); write(chr(193));
			write(chr(196),chr(217));
			{//----------------------]}
			textcolor(15);gotoxy(5,6);write(chr(201)); for i:=1 to 12 do write(chr(205));
			write(chr(187),'       ',chr(201),chr(205),chr(187));
			gotoxy(5,7); write(chr(186),'Цвет игры...',chr(186),'    ');
			if chv_ig>9 then write(chv_ig) else write(' ',chv_ig);write(' ',chr(186));
			textcolor(chv_ig); write(chr(219)); textcolor(15);
			write(chr(186)); gotoxy(5,8); write(chr(200)); for i:=1 to 12 do write(chr(205));
			write(chr(202)); for i:=1 to 7 do write(chr(205)); write(chr(202));
			write(chr(205),chr(188));
			{//----------------------}
			gotoxy(80,25);
			end;
		if k=2 then
			begin
			{//----------------------}
			textcolor(chv_k);gotoxy(5,6);write(chr(218)); for i:=1 to 12 do write(chr(196));
			write(chr(191),'       ',chr(218),chr(196),chr(191));
			gotoxy(5,7); write(chr(179),'Цвет игры...',chr(179),'    ');textcolor(15);
			if chv_ig>9 then write(chv_ig) else write(' ',chv_ig);textcolor(chv_k);write(' ',chr(179));
			textcolor(chv_ig); write(chr(219)); textcolor(chv_k);
			write(chr(179)); gotoxy(5,8); write(chr(192)); for i:=1 to 12 do write(chr(196));
			write(chr(193)); for i:=1 to 7 do write(chr(196)); write(chr(193));
			write(chr(196),chr(217));
			{//----------------------}
			if k1=1 then
				begin
				textcolor(15);gotoxy(5,2);write(chr(201)); for i:=1 to 12 do write(chr(205));
				write(chr(187),'       ',chr(201),chr(205),chr(187));
				gotoxy(5,3); write(chr(186),'Цвет меню...',chr(186),'    ');
				if chv_m>9 then write(chv_m) else write(' ',chv_m);
				write(' ',chr(186));
				textcolor(chv_m); write(chr(219)); textcolor(15);
				write(chr(186)); gotoxy(5,4); write(chr(200)); for i:=1 to 12 do write(chr(205));
				write(chr(202)); for i:=1 to 7 do write(chr(205)); write(chr(202));
				write(chr(205),chr(188));
				end;
			if k1=3 then
				begin
				textcolor(15);
				gotoxy(5,10); write(chr(201)); for i:=1 to 15 do write(chr(205));
				write(chr(187),'    ',chr(201),chr(205),chr(187));
				gotoxy(5,11); write(chr(186),'Цвет курсора...',chr(186),' ');if chv_k>9 then write(chv_k) else
				write(' ',chv_k);write(' ',chr(186));
				textcolor(chv_k); write(chr(219)); textcolor(15); write(chr(186)); gotoxy(5,12);
				write(chr(200)); for i:=1 to 15 do write(chr(205)); write(chr(202)); for i:=1 to 4 do
				write(chr(205));
				write(chr(202),chr(205),chr(188));
				end;
			gotoxy(80,25);
			end;
		if k=3 then
			begin
			textcolor(chv_k);
			gotoxy(5,10); write(chr(218)); for i:=1 to 15 do write(chr(196));
			write(chr(191),'    ',chr(218),chr(196),chr(191));
			gotoxy(5,11); write(chr(179),'Цвет курсора...',chr(179));textcolor(15);
			write(' ');if chv_k>9 then write(chv_k) else write(' ',chv_k);write(' ');textcolor(chv_k);
			write(chr(179));
			write(chr(219));write(chr(179)); gotoxy(5,12);
			write(chr(192)); for i:=1 to 15 do write(chr(196)); write(chr(193)); for i:=1 to 4 do write(chr(196));
			write(chr(193),chr(196),chr(217));
			{//-----------------------}
			textcolor(15);
			if k1=2 then
				begin
				gotoxy(5,6);write(chr(201)); for i:=1 to 12 do write(chr(205));
				write(chr(187),'       ',chr(201),chr(205),chr(187));
				gotoxy(5,7); write(chr(186),'Цвет игры...',chr(186),'    ');
				if chv_ig>9 then write(chv_ig) else write(' ',chv_ig);write(' ',chr(186));
				textcolor(chv_ig); write(chr(219)); textcolor(15);
				write(chr(186)); gotoxy(5,8); write(chr(200)); for i:=1 to 12 do write(chr(205));
				write(chr(202)); for i:=1 to 7 do write(chr(205)); write(chr(202));
				write(chr(205),chr(188));
				end;
			if k1=4 then
				begin
				gotoxy(5,14); write(chr(201)); for i:=1 to 13 do write(chr(205)); write(chr(187));
				gotoxy(5,15); write(chr(186),'Информация...',chr(186));
				gotoxy(5,16); write(chr(200)); for i:=1 to 13 do write(chr(205)); write(chr(188));
				end;
			gotoxy(80,25);
			end;
		if k=4 then
			begin
			textcolor(chv_k);
			gotoxy(5,14); write(chr(218)); for i:=1 to 13 do write(chr(196)); write(chr(191));
			gotoxy(5,15); write(chr(179),'Информация...',chr(179));
			gotoxy(5,16); write(chr(192)); for i:=1 to 13 do write(chr(196)); write(chr(217));
			textcolor(15);
			{//-------------------}
			if k1=3 then
				begin
				gotoxy(5,10); write(chr(201)); for i:=1 to 15 do write(chr(205));
				write(chr(187),'    ',chr(201),chr(205),chr(187));
				gotoxy(5,11); write(chr(186),'Цвет курсора...',chr(186),' ');if chv_k>9 then write(chv_k) else
				write(' ',chv_k);write(' ',chr(186));
				textcolor(chv_k); write(chr(219)); textcolor(15); write(chr(186)); gotoxy(5,12);
				write(chr(200)); for i:=1 to 15 do write(chr(205)); write(chr(202)); for i:=1 to 4 do
				write(chr(205));
				write(chr(202),chr(205),chr(188));
				end;
			if k1=5 then
				begin
				gotoxy(5,18); write(chr(201)); for i:=1 to 8 do write(chr(205)); write(chr(187));
				gotoxy(5,19); write(chr(186),'Назад...',chr(186));
				gotoxy(5,20); write(chr(200)); for i:=1 to 8 do write(chr(205)); write(chr(188));
				end;
			gotoxy(80,25);
			end;
		if k=5 then
			begin
			textcolor(chv_k);
			gotoxy(5,18); write(chr(218)); for i:=1 to 8 do write(chr(196)); write(chr(191));
			gotoxy(5,19); write(chr(179),'Назад...',chr(179));
			gotoxy(5,20); write(chr(192)); for i:=1 to 8 do write(chr(196)); write(chr(217));
			textcolor(15);
			{//------------------------}
			gotoxy(5,14); write(chr(201)); for i:=1 to 13 do write(chr(205)); write(chr(187));
			gotoxy(5,15); write(chr(186),'Информация...',chr(186));
			gotoxy(5,16); write(chr(200)); for i:=1 to 13 do write(chr(205)); write(chr(188));
			gotoxy(80,25);
			end;
		k1:=k;
		end;
	if keypressed then
		begin
		c:=readkey;
		case c of
		#72:case k of
			2..5:k:=k-1;
			end;
		#80:case k of
			1..4:k:=k+1;
			end;
		{//#27:u:=2;}
		#63:
				begin
				textcolor(15);
				textbackground(chv_m);
				clrscr;
				opch_m_n;
				{//---------------------------}
				gotoxy(5,18); write(chr(201)); for i:=1 to 8 do write(chr(205)); write(chr(187));
				gotoxy(5,19); write(chr(186),'Назад...',chr(186));
				gotoxy(5,20); write(chr(200)); for i:=1 to 8 do write(chr(205)); write(chr(188));
				{//---------------------------}
				gotoxy(5,2);write(chr(201)); for i:=1 to 12 do write(chr(205));
				write(chr(187),'       ',chr(201),chr(205),chr(187));
				gotoxy(5,3); write(chr(186),'Цвет меню...',chr(186),'    ');
				if chv_m>9 then write(chv_m) else write(' ',chv_m);
				write(' ',chr(186));
				textcolor(chv_m); write(chr(219)); textcolor(15);
				write(chr(186)); gotoxy(5,4); write(chr(200)); for i:=1 to 12 do write(chr(205));
				write(chr(202)); for i:=1 to 7 do write(chr(205)); write(chr(202));
				write(chr(205),chr(188));
				{//----------------------------}
				gotoxy(5,6);write(chr(201)); for i:=1 to 12 do write(chr(205));
				write(chr(187),'       ',chr(201),chr(205),chr(187));
				gotoxy(5,7); write(chr(186),'Цвет игры...',chr(186),'    ');
				if chv_ig>9 then write(chv_ig) else write(' ',chv_ig);write(' ',chr(186));
				textcolor(chv_ig); write(chr(219)); textcolor(15);
				write(chr(186)); gotoxy(5,8); write(chr(200)); for i:=1 to 12 do write(chr(205));
				write(chr(202)); for i:=1 to 7 do write(chr(205)); write(chr(202));
				write(chr(205),chr(188));
				k1:=3;k:=4;
				end;
		#13,#28:case k of
			5:u:=2;
			4:
				begin
				info_o;
				textcolor(15);
				textbackground(chv_m);
				clrscr;
				opch_m_n;
				{//---------------------------}
				gotoxy(5,18); write(chr(201)); for i:=1 to 8 do write(chr(205)); write(chr(187));
				gotoxy(5,19); write(chr(186),'Назад...',chr(186));
				gotoxy(5,20); write(chr(200)); for i:=1 to 8 do write(chr(205)); write(chr(188));
				{//---------------------------}
				gotoxy(5,2);write(chr(201)); for i:=1 to 12 do write(chr(205));
				write(chr(187),'       ',chr(201),chr(205),chr(187));
				gotoxy(5,3); write(chr(186),'Цвет меню...',chr(186),'    ');
				if chv_m>9 then write(chv_m) else write(' ',chv_m);
				write(' ',chr(186));
				textcolor(chv_m); write(chr(219)); textcolor(15);
				write(chr(186)); gotoxy(5,4); write(chr(200)); for i:=1 to 12 do write(chr(205));
				write(chr(202)); for i:=1 to 7 do write(chr(205)); write(chr(202));
				write(chr(205),chr(188));
				{//----------------------------}
				gotoxy(5,6);write(chr(201)); for i:=1 to 12 do write(chr(205));
				write(chr(187),'       ',chr(201),chr(205),chr(187));
				gotoxy(5,7); write(chr(186),'Цвет игры...',chr(186),'    ');
				if chv_ig>9 then write(chv_ig) else write(' ',chv_ig);write(' ',chr(186));
				textcolor(chv_ig); write(chr(219)); textcolor(15);
				write(chr(186)); gotoxy(5,8); write(chr(200)); for i:=1 to 12 do write(chr(205));
				write(chr(202)); for i:=1 to 7 do write(chr(205)); write(chr(202));
				write(chr(205),chr(188));
				{//---------------------------}
				k:=4; k1:=3;
				end;
			1:
				begin
				gotoxy(23,3);
				write('   ');
				gotoxy(23,3);
				read(chv_m);
				gotoxy(27,3);
				textcolor(chv_m);
				write(chr(219));
				textcolor(15);
				gotoxy(23,3);
				if chv_m>9 then write(chv_m) else write(' ',chv_m);
				gotoxy(80,25);
				end;
			2:
				begin
				gotoxy(23,7);
				write('   ');
				gotoxy(23,7);
				read(chv_ig);
				gotoxy(23,7);
				if chv_ig>9 then write(chv_ig) else write(' ',chv_ig);
				gotoxy(27,7);
				textcolor(chv_ig);
				write(chr(219));
				textcolor(15);
				gotoxy(80,25);
				end;
			3:
				begin
				gotoxy(23,11);
				write('   ');
				gotoxy(23,11);
				read(chv_k);
				gotoxy(23,11);
				if chv_k>9 then write(chv_k) else write(' ',chv_k);
				gotoxy(27,11);
				textcolor(chv_k);
				write(chr(219));
				textcolor(15);
				gotoxy(80,25);
				end;
			end;
		end;
		end;

end;
end;

{//--------------------------------------------------------PR+++}
procedure nym_inf;
var i,u,k,k1:b;
begin
u:=1;
k:=1;
k1:=2;
repeat
if k<>k1 then
begin
clrscr;
gt(35,1);write(#201);for i:=1 to 9 do write(#205);write(#187);
gt(1,3);for i:=1 to 80 do if ((i=35) or (i=45)) then write(#202) else write(#205);
gt(35,2);write(#186);
gt(45,2);write(#186);t(10);
gt(36,2);write('Помощь...');t(15);
gt(55,2);write('Страница ',k,'/2...');
case k of
1:begin
gt(5,2);t(14);write('Самое начало...');t(15);
gt(3,4);write('"1" - Сила характера...');
gt(3,5);write('"2" - Энергия внешних действий...');
gt(3,6);write('"3" - Интерес...');
gt(3,7);write('"4" - Здоровье, физическая сила...');
gt(3,8);write('"5" - Логика...');
gt(3,9);write('"6" - Показатель интенсивности работы руками...');
gt(3,10);write('"7" - Везение, познание мира...');
gt(3,11);write('"8" - Терпение, почитание родителей...');
gt(3,12);write('"9" - Ум, память...');
gt(3,13);write('"0" - Истина... ');
{t(3);
gt(4,14);write('Максимум проявления качества в ячейке, строке, линии или диаганали - 5 цифр.');
t(15);}
gt(3,14);write('1-ая строка (1,4,7) - Целеустремлённость...');
gt(3,15);write('2-ая строка (2,5,8) - Качество семьянина...');
gt(3,16);write('3-я  строка (3,6,9) - Стабильность...');
gt(3,17);write('1-й столбец (1,2,3) - Самооценка...');
gt(3,18);write('2-й столбец (4,5,6) - Прокорм семьи...');
gt(3,19);write('3-й столбец (7,8,9) - Сила таланатa...');
gt(3,20);write('Нисходящая диаганаль (1,5,9) - Духовная диаганаль, сила духа...');
gt(3,21);write('Восходящая диаганаль (3,5,7) - Плоцкая диаганаль, отражает плоцкие ');
gt(50,22);write('качества и желания...');t(12);
gt(3,23);write('Цифра "0" в психоматрицу не входит',#19);t(15);
  end;
2:begin
  gt(3,2);t(14);write('Активность качеств...');t(15);
  gt(3,4);write('0 Цифр  - Качество непроявлено...');
  gt(3,5);write('1 Цифра - Качество слабопроявлено...');
  gt(3,6);write('2 Цифры - Норма проявления качества...');
  gt(3,7);write('3 Цыфры - Качество препроявляется спонтанно, но в полной силе...');
  gt(3,8);write('4 Цыфры - Качество проявляется сильно...');
  gt(3,9);write('5 Цифр  - Максимум проявления качества, которое частично подавляет');
	gt(50,10);write('другие ккачества...');
  gt(3,11);write('6 и более цифр - Перегрузка качества приводит к его ослаблению...');

  end;
  end;
k1:=k;
gt(1,24);for i:=1 to 80 do if ((i=28) or (i=58)) then write(#203) else write(#205);
gt(2,25);t(13);write('PageUp - Страница вверх...');t(15);write(#186);t(13);
write(' PageDown - Страница вниз... ');t(15);write(#186);t(13);
write('   Esc - Назад...');  t(15);
gtn;
end;
if keypressed then
	case readkey of
	#73:if k<>1 then dec(k);
	#81:if k<>2 then inc(k);
	#27:u:=2;
	end;
until u<>1;
end;
//--------------------------------------------------------PR+++
procedure nymer;
var     a, r, b, d, e, f, s, f2, f3, sa, norm,
	m, t, c, i, ii, uu1, uu2:longint;
	w, w1, rrr:array[0..100] of longint;
	gggg:array[1..3] of longint;
	ppp:string;
	key:char;
	fail_s:text;
	{vty.}k,k1,u:byte;
begin
uu1:=1;
while uu1=1 do
	begin
	norm:=0;
	textbackground(0);
	clrscr;
	textcolor(15);
	gotoxy(2,2);
	write(#201,#205,#205,#203,#205,#205,#203);
	for i:=1 to 4 do write(#205);write(#187);
	gotoxy(14,3);write('Введите число рождения...');
	gotoxy(2,3);write(#186,'  ',#186,'  ',#186,'    ',#186);
	gotoxy(2,4);write(#200,#205,#205,#202,#205,#205,#202,#205,#205,#205,#205,#188);
	gotoxy(3,3);readln(a);
	gggg[1]:=a;
	gotoxy(14,3);write('Введите месяц рождения...');
	gotoxy(6,3);readln(b);
	gggg[2]:=b;
	gotoxy(14,3);write('Введите  год  рождения...');
	gotoxy(9,3);readln(c);
	gggg[3]:=c;
	gotoxy(14,3);write('			 ');
	gotoxy(14,3);write('  -  Дата рождения...');
	gotoxy(2,4);write();
	gotoxy(1,5);
	fillchar(w1,sizeof(w1),0);
	rrr[1]:=0;
	i:=0;
	d:=0;
	e:=0;
	m:=0;
	if ((a<32) and (a>0) and (b>0) and (b<13)) then
		begin
		norm:=5;
		if norm=5 then norm:=5;
		f:=a;

		while a>0 do
				begin
				inc(i);
				w[i]:=a mod 10;
				a:=a div 10;
				end;
		sa:=w[i];
		while b>0 do
				begin
				inc(i);
				w[i]:=b mod 10;
				b:=b div 10;
				end;
		while c>0 do
				begin
				inc(i);
				w[i]:=c mod 10;
				c:=c div 10;
				end;
		for t:=1 to i do
			begin
			d:=d+w[t];
			end;
		d:=abs(d);
		rrr[1]:=d;
		while d>0 do
				begin
				inc(i);
				w[i]:=d mod 10;
				d:=d div 10;
				e:=e+w[i];
				end;
		e:=abs(e);
		rrr[2]:=e;
		while e>0 do
				begin
				inc(i);
				w[i]:=e mod 10;
				e:=e div 10;
				end;
		f:=(rrr[1])-(sa*2);
		f2:=i+1;
		f:=abs(f);
		rrr[3]:=f;
		while f>0 do
				begin
				inc(i);
				w[i]:=f mod 10;
				f:=f div 10;
				end;
		f3:=i;
		for t:=f2 to f3 do m:=m+w[t];
		m:=abs(m);
		rrr[4]:=m;
		while m>0 do
				begin
				inc(i);
				w[i]:=m mod 10;
				m:=m div 10;
				end;
		gt(2,4);write(#204);
		gt(5,3);write(#186);
		gt(8,3);write(#186);
		gt(13,3);write(#186);
		gt(11,4);write(#203);
		gt(13,4);write(chr(202),#187);
		gt(5,4);write(#206);
		gt(8,4);write(#206);
		gt(2,5);write(#186,'  ',#186,'  ',#186,'  ',#186,'  ',#186);
		gt(2,6);write(#200,#205,#205,#202,#205,#205,#202,#205,#205,#202,#205,#205,#188);
		gt(3,5);write(rrr[1]);
		gt(6,5);write(rrr[2]);
		gt(9,5);write(rrr[3]);
		gt(12,5);write(rrr[4]);
		gt(15,5);write(' - Дополнительные числа...');
		end;
	for t:=1 to i do
		for s:=0 to 9 do
			if (w[t]=s) then inc(w1[s]);
	if rrr[1]>0 then
		begin
		gt(21,7);
		write('Психоматрица');
		gt(20,6);write(#201);for i:=1 to 12 do write(#205);write(#187);
		gt(20,7);write(#186);
		gt(33,7);write(#186);
		gt(2,8);write(#201);for i:=1 to 10 do write(#205);write(#203);
			for i:=1 to 6 do write(#205);write(#202);write(#205,#205,#205,#203);
			for i:=1 to 8 do write(#205);write(#202,#205,#187);
		gt(2,9);write(#186);
		gt(13,9);write(#186);
		gt(24,9);write(#186);
		gt(35,9);write(#186);
		gt(2,11);write(#186);
		gt(13,11);write(#186);
		gt(24,11);write(#186);
		gt(35,11);write(#186);
		gt(2,13);write(#186);
		gt(13,13);write(#186);
		gt(24,13);write(#186);
		gt(35,13);write(#186);
		gt(46,13);write(#186);
		gt(2,10);write(#204);for i:=1 to 10 do write(#205);write(#206);
			for i:=1 to 10 do write(#205);write(#206);
			for i:=1 to 10 do write(#205);WRITE(#185);
		gt(2,12);write(#204);for i:=1 to 10 do write(#205);write(#206);
			for i:=1 to 10 do write(#205);write(#206);
			for i:=1 to 10 do write(#205);WRITE(#206);
			for i:=1 to 10 do write(#205);write(#187);
		gt(2,14);write(#200);for i:=1 to 10 do write(#205);write(#202);
			for i:=1 to 10 do write(#205);write(#202);
			for i:=1 to 10 do write(#205);WRITE(#202);
			for i:=1 to 10 do write(#205);write(#188);

		end;
	if norm<>5 then
		begin
		gt(20,5);
		textcolor(12);
		write('    Вы ввели некорректные данные...');
		gt(20,6);
		write('     Приложение перезапускается...');
		textcolor(15);
		gt(9,8);write('[');
		gt(71,8);write(']');
		for i:=1 to 61 do
			begin
			gt(9+i,8);
			case i of
			1 :textcolor(4);
			11:textcolor(12);
			21:textcolor(6);
			31:textcolor(14);
			41:textcolor(2);
			51:textcolor(10);
			end;
			write(chr(176+random(3)));
			gtn;
			Delay(50);
			end;
		Delay(300);
		{readln;}
		end;
	textcolor (white);
	if rrr[1]>0 then
	begin
	gt(3,9);
	//---------------------------------------111111111
	if w1[1]=0 then write ('    -     ');
	if w1[1]=1 then write ('    1     ');
	if w1[1]=2 then write ('    11    ');
	if w1[1]=3 then write ('   111    ');
	if w1[1]=4 then write ('   1111   ');
	if w1[1]=5 then write ('  11111   ');
	if w1[1]=6 then write ('  111111  ');
	if w1[1]=7 then write (' 1111111  ');
	if w1[1]=8 then write (' 11111111 ');
	if w1[1]=9 then write ('111111111 ');
	if w1[1]=10 then write ('1111111111');
	gt(14,9);
	//-----------------------------------------4444444444444
	if w1[4]=0 then write ('    -     ');
	if w1[4]=1 then write ('    4     ');
	if w1[4]=2 then write ('    44    ');
	if w1[4]=3 then write ('   444    ');
	if w1[4]=4 then write ('   4444   ');
	if w1[4]=5 then write ('  44444   ');
	if w1[4]=6 then write ('  444444  ');
	if w1[4]=7 then write (' 4444444  ');
	if w1[4]=8 then write (' 44444444 ');
	if w1[4]=9 then write ('444444444 ');
	if w1[4]=10 then write ('4444444444');
	gt(25,9);
	///////////////1--------------------------777777777777777777
	if w1[7]=0 then write ('    -     ');
	if w1[7]=1 then write ('    7     ');
	if w1[7]=2 then write ('    77    ');
	if w1[7]=3 then write ('   777    ');
	if w1[7]=4 then write ('   7777   ');
	if w1[7]=5 then write ('  77777   ');
	if w1[7]=6 then write ('  777777  ');
	if w1[7]=7 then write (' 7777777  ');
	if w1[7]=8 then write (' 77777777 ');
	if w1[7]=9 then write ('777777777 ');
	if w1[7]=10 then write ('7777777777');
	gt(3,11);
	//----------------------------------------2222222222222
	if w1[2]=0 then write ('    -     ');
	if w1[2]=1 then write ('    2     ');
	if w1[2]=2 then write ('    22    ');
	if w1[2]=3 then write ('   222    ');
	if w1[2]=4 then write ('   2222   ');
	if w1[2]=5 then write ('  22222   ');
	if w1[2]=6 then write ('  222222  ');
	if w1[2]=7 then write (' 2222222  ');
	if w1[2]=8 then write (' 22222222 ');
	if w1[2]=9 then write ('222222222 ');
	if w1[2]=10 then write ('2222222222');
	gt(14,11);
	//------------------------------------5555555555555
	if w1[5]=0 then write ('    -     ');
	if w1[5]=1 then write ('    5     ');
	if w1[5]=2 then write ('    55    ');
	if w1[5]=3 then write ('   555    ');
	if w1[5]=4 then write ('   5555   ');
	if w1[5]=5 then write ('  55555   ');
	if w1[5]=6 then write ('  555555  ');
	if w1[5]=7 then write (' 5555555  ');
	if w1[5]=8 then write (' 55555555 ');
	if w1[5]=9 then write ('555555555 ');
	if w1[5]=10 then write ('5555555555');
	gt(25,11);
	//-------------------------------------8888888888888
	if w1[8]=0 then write ('    -     ');
	if w1[8]=1 then write ('    8     ');
	if w1[8]=2 then write ('    88    ');
	if w1[8]=3 then write ('   888    ');
	if w1[8]=4 then write ('   8888   ');
	if w1[8]=5 then write ('  88888   ');
	if w1[8]=6 then write ('  888888  ');
	if w1[8]=7 then write (' 8888888  ');
	if w1[8]=8 then write (' 88888888 ');
	if w1[8]=9 then write ('888888888 ');
	if w1[8]=10 then write ('8888888888');
	gt(3,13);
	//----------------------------------333333333333333333
	if w1[3]=0 then write ('    -     ');
	if w1[3]=1 then write ('    3     ');
	if w1[3]=2 then write ('    33    ');
	if w1[3]=3 then write ('   333    ');
	if w1[3]=4 then write ('   3333   ');
	if w1[3]=5 then write ('  33333   ');
	if w1[3]=6 then write ('  333333  ');
	if w1[3]=7 then write (' 3333333  ');
	if w1[3]=8 then write (' 33333333 ');
	if w1[3]=9 then write ('333333333 ');
	if w1[3]=10 then write ('3333333333');
	gt(14,13);
	//----------------------------------------66666666666666666666
	if w1[6]=0 then write ('    -     ');
	if w1[6]=1 then write ('    6     ');
	if w1[6]=2 then write ('    66    ');
	if w1[6]=3 then write ('   666    ');
	if w1[6]=4 then write ('   6666   ');
	if w1[6]=5 then write ('  66666   ');
	if w1[6]=6 then write ('  666666  ');
	if w1[6]=7 then write (' 6666666  ');
	if w1[6]=8 then write (' 66666666 ');
	if w1[6]=9 then write ('666666666 ');
	if w1[6]=10 then write ('6666666666');
	gt(25,13);
	//-----------------------------------------999999999999999999
	if w1[9]=0 then write ('    -     ');
	if w1[9]=1 then write ('    9     ');
	if w1[9]=2 then write ('    99    ');
	if w1[9]=3 then write ('   999    ');
	if w1[9]=4 then write ('   9999   ');
	if w1[9]=5 then write ('  99999   ');
	if w1[9]=6 then write ('  999999  ');
	if w1[9]=7 then write (' 9999999  ');
	if w1[9]=8 then write (' 99999999 ');
	if w1[9]=9 then write ('999999999 ');
	if w1[9]=10 then write ('9999999999');
	gt(36,13);
	if w1[0]=0 then write ('    -     ');
	if w1[0]=1 then write ('    0     ');
	if w1[0]=2 then write ('    00    ');
	if w1[0]=3 then write ('   000    ');
	if w1[0]=4 then write ('   0000   ');
	if w1[0]=5 then write ('  00000   ');
	if w1[0]=6 then write ('  000000  ');
	if w1[0]=7 then write (' 0000000  ');
	if w1[0]=8 then write (' 00000000 ');
	if w1[0]=9 then write ('000000000 ');
	if w1[0]=10 then write ('0000000000');
	gt(3,15);
	writeln('Психоматрица заполнена...');
	writeln('  Нажмите F1 для помощи и перезапуска приложения...');
	writeln('  Нажмите Esc хля выхода...');
	writeln('  Нажмите F2 для сохранения в файл и выхода...');
	writeln('  Нажмите Ctrl+X для перезапуска приложения...');
	uu2:=1;
	gotoxy(80,25);
	while uu2=1 do
		begin
		if keypressed then
			begin
			key:=readkey;
			case key of
			#24:uu2:=2;
			#27:
				begin
				uu2:=2;
				uu1:=2;
				end;
			#60:
				begin
				gt(3,15);for i:=1 to 10 do write('   ');
				gt(3,16);for i:=1 to 20 do write('   ');
				gt(3,17);for i:=1 to 20 do write('   ');
				gt(3,18);for i:=1 to 20 do write('   ');
				gt(3,19);for i:=1 to 20 do write('   ');
				uu2:=2;
				uu1:=2;
				gotoxy(3,15);
				writeln('Введите имя файла...');
				write('  Внимание:'); textcolor(12); write(' Консоль не поддерживает русские буквы...');textcolor(15);
				ppp:='';
				writeln;
				write('  Имя=>');
				readln(ppp);
				ppp:=ppp+'.txt';
				assign(fail_s,ppp);
				rewrite(fail_s);
				writeln(fail_s,gggg[1],' ',gggg[2],' ',gggg[3],'    - Data rozhdenia...');
				for i:=1 to 4 do write(fail_s,rrr[i],' ');
				writeln(fail_s,'  - Dopolnitelnie chisla...');
				writeln(fail_s,'	   Psihomatrisha...');
				{----------------}
				//------------1
					i:=1;
					if w1[i]=0 then write(fail_s,'	 -') else begin
					r:=0;
					for ii:=1 to w1[i] do
						begin
						if r<>0 then r:=r*10;
						r:=r+i;
						end;
					write(fail_s,r:10);    end;
				//--------------4
					i:=4;
					if w1[i]=0 then write(fail_s,'	 -') else begin
					r:=0;
					for ii:=1 to w1[i] do
						begin
						if r<>0 then r:=r*10;
						r:=r+i;
						end;
					write(fail_s,r:10);     end;
				//--------------7
					i:=7;
					if w1[i]=0 then write(fail_s,'	 -') else begin
					r:=0;
					for ii:=1 to w1[i] do
						begin
						if r<>0 then r:=r*10;
						r:=r+i;
						end;
					write(fail_s,r:10);   end;
					writeln(fail_s);
				//--------------2
					i:=2;
					if w1[i]=0 then write(fail_s,'	 -') else begin
					r:=0;
					for ii:=1 to w1[i] do
						begin
						if r<>0 then r:=r*10;
						r:=r+i;
						end;
					write(fail_s,r:10);   end;
				//--------------5
					i:=5;
					if w1[i]=0 then write(fail_s,'	 -') else begin
					r:=0;
					for ii:=1 to w1[i] do
						begin
						if r<>0 then r:=r*10;
						r:=r+i;
						end;
					write(fail_s,r:10); end;
				//--------------8
					i:=8;
					if w1[i]=0 then write(fail_s,'	 -') else begin
					r:=0;
					for ii:=1 to w1[i] do
						begin
						if r<>0 then r:=r*10;
						r:=r+i;
						end;
					write(fail_s,r:10);  end;
					writeln(fail_s);
				//---------------3
					i:=3;
					if w1[i]=0 then write(fail_s,'	 -') else begin
					r:=0;
					for ii:=1 to w1[i] do
						begin
						if r<>0 then r:=r*10;
						r:=r+i;
						end;
					write(fail_s,r:10); end;
				//--------------6
					i:=6;
					if w1[i]=0 then write(fail_s,'	 -') else begin
					r:=0;
					for ii:=1 to w1[i] do
						begin
						if r<>0 then r:=r*10;
						r:=r+i;
						end;
					write(fail_s,r:10);  end;
				//--------------9
					i:=9;
					if w1[i]=0 then write(fail_s,'	 -') else begin
					r:=0;
					for ii:=1 to w1[i] do
						begin
						if r<>0 then r:=r*10;
						r:=r+i;
						end;
					write(fail_s,r:10);  end;
				//------------------VS

				if w1[0]=0 then write(fail_s,'	 -') else begin
				r:=10-w1[0];
				for i:=1 to r do write(fail_s,' ');
				for i:=1 to w1[0] do write(fail_s,'0'); end;
				writeln(fail_s);
				close(fail_s);
				writeln('  Сохранено как "',ppp,'".');
				writeln('  Нажмите F12 для выхода из приложения...');
				gotoxy(80,25);
				while not ((keypressed) and (readkey=#134)) do delay(10);
				end;
			#59:
				begin
				nym_inf;
				tb(0);
				clrscr;
				uu2:=2;
				end;
			end;
			end;
			end;
	end;
	end;
end;
{//--------------------------------------------------------PR+++}
procedure parol(a:b);
var x1,x2,kont,kont2:b;
	sss:string;
	nnn:boolean;
begin
kont2:=0;
nnn:=false;

repeat

tb(0);
kont:=0;
clrscr;
x2:=57;
x1:=23;
textcolor(15);
gotoxy(x1,10);write(#201);for i:=1 to 33 do write(#205);write(#187);
gotoxy(x1,15);write(#200);for i:=1 to 33 do write(#205);write(#188);
gotoxy(x1,11);write(#186);
gotoxy(x1,12);write(#186);
gotoxy(x1,13);write(#186);
gotoxy(x1,14);write(#186);
gotoxy(x2,11);write(#186);
gotoxy(x2,12);write(#186);
gotoxy(x2,13);write(#186);
gotoxy(x2,14);write(#186);
gotoxy(25,11);write('  Введите пароль доступа...');
gt(34,12);write('Попытка ');
	case kont2 of
	0:t(10);
	1:t(14);
	2:t(12);
	end;
	write(kont2+1);t(15);write('/3...');
gt(30,13);
write('Пароль=>');
t(0);
readln(sss);
case a of
1:
	if ((sss='379973111')) then
	 begin
	 kont:=2;
	 gt(30,14);t(10);
	 write('Пароль верен...');
	 nnn:=true;
	 t(15);
	 gtn;
	 delay(1000);
	 nymer;
	 end;


end;
if kont=0 then
	begin
	inc(kont2);
	gt(30,14);t(12);
	write('Пароль неверен...');
	t(15);
	gtn;
	delay(1000);
	end;

until ((nnn=true) or (kont2=3));

end;
{//--------------------------------------------------------PR+++}
procedure programma_nomer_2;//matrix
var a,b,i,chv:byte;
begin
textcolor(10);
clrscr;
while not ((KeyPressed) and (readkey=#27)) do
    begin
    //Delay(1);
    chv:=Random(2);
    case chv of
	0:textcolor(green);
	1:textcolor(10);
	end;
    a:=0;
    i:=0;
    while a=0 do a:=Random(26);
    while i=0 do i:=Random(81);
    GoToXY(i,a);
    b:=Random(31);
    case b of
	0..10:write('0');
	11..20:write(' ');
	22..30:write('1');
	21:
		begin
		gotoxy(80,25);
		writeln;
		end;
	end;
    end;
end;

//--------------------------------------------------------PR+++
procedure programma_nomer_1;
var u,tt,i:b;
begin
clrscr;
textcolor({chv_m+1}15);
gotoxy(5,5);
write(#201);for i:=1 to 66 do write(#205);write(#187);
gotoxy(6,6);
write('    Нажимайте клавиши, а в поле будет высвечиваться их код...');
gotoxy(30,7);
write('(Esc ');
textcolor(14);
write('(=');
textcolor(11);
write('#27');
textcolor(14);
write(')');
textcolor(15);
write(' - Выход)');
for i:=1 to 2 do
	begin
	gotoxy(5,5+i);
	write(#186);
	end;
for i:=1 to 2 do
	begin
	gotoxy(72,5+i);
	write(#186);
	end;
gotoxy(5,8);write(#199);
for i:=1 to 66 do write(#196);
write(#182);
for i:=1 to 5 do
	begin
	gotoxy(5,8+i);
	write(#186);
	end;
for i:=1 to 5 do
	begin
	gotoxy(72,8+i);
	write(#186);
	end;
gotoxy(5,14);
write(#200);for i:=1 to 66 do write(#205);write(#188);
textcolor(10);gotoxy(30,10);
write(#201);for i:=1 to 15 do write(#205);write(#187);
gotoxy(30,11);write(#186);gotoxy(38,11);write(':');
gotoxy(46,11);write(#186);
gotoxy(30,12);
write(#200);for i:=1 to 15 do write(#205);write(#188);
gotoxy(80,25);
u:=1;
textcolor(15);
while u=1 do if keypressed then
	begin
	gotoxy(42,11);
	write('    ');
	gotoxy(42,11);
	tt:=ord(readkey);
	if tt=27 then u:=2;
	write(tt);
	gotoxy(32,11);
	write('   ');
	gotoxy(32,11);
	write(chr(tt));
	gotoxy(80,25);
	end;
end;


//--------------------------------------------------------PR+++

procedure  programma_nomer_3;
var i,a,x,y,p,a1:longint;
begin
textcolor(15);
{repeat
begin}
textbackground(0);
clrscr;
writeln('Введите число...');
readln(a);
x:=2;
y:=3;
a1:=a;
p:=0;
while a1>0 do
	begin
	a1:=a1 div 10;
	inc(p);
	end;
inc(p);
gotoxy(1,25);
a1:=0;
write('Вычисляем.');
for i:=1 to a do
	begin
	inc(a1);
	if (a mod i=0) then
		begin
		Textcolor(15);
		inc(y);
		gotoxy(x,y);
		write(i);
		//if i=a then write('.') else write(',');
		//write(' ');
		//if wereX>=70 then writeln;
		if y=23 then
			begin
			x:=x+p;
			y:=3;
			end;
		gotoxy(80,25);
		end;
	case a1 of
	5000000:
		begin
		gotoxy(10,25);
		write('	 ');
		textcolor(12);
		gotoxy(10,25);
		write('...');
		gotoxy(80,25);
		end;
	10000000:
		begin
		textcolor(14);
		gotoxy(10,25);
		write('   ');
		gotoxy(10,25);
		write('.....');
		gotoxy(80,25);
		end;
	15000000:
		begin
		textcolor(10);
		gotoxy(10,25);
		write('     ');
		gotoxy(10,25);
		write('........');
		gotoxy(80,25);
		a1:=0;
		end;
	end;
	end;
gotoxy(1,25);
write('									      ');
gotoxy(1,25);
write('Нажмите Еnter для выхода...');
gotoxy(80,25);
readln;
//if keypressed and readkey=#27 then u:=2;
{end;
until ((keypressed) and (readkey=#27));}
end;
//--------------------------------------------------------PR+++

procedure nach_p;
var k,k1,u:b;
	c:char;
begin
textbackground(chv_m);
clrscr;
//---------
ramka(5,20,'Назад...',1,'');
//---------
ramka(5,12,'Узнавалка естественных делителей числа...',1,'');
//----------
ramka(5,16,'Про нумерологию...',1,'');
//----------
u:=1;
k:=1;
k1:=2;
while u=1 do
	begin
	if k1<>k then begin
	case k of
	1:
		begin
		ramka(5,4,'Программа пишет код набранной клавиши...',2,'');
		end;
	2:
		begin
		ramka(5,8,'Матрица...',2,'');
		end;
	3:
		begin
		ramka(5,12,'Узнавалка естественных делителей числа...',2,'');
		end;
	4:
		begin
		ramka(5,16,'Про нумерологию...',2,'');
		end;
	5:
		begin
		ramka(5,20,'Назад...',2,'');
		end;
	end;
	case k1 of
	1:
		begin
		ramka(5,4,'Программа пишет код набранной клавиши...',1,'');
		end;
	2:
		begin
		ramka(5,8,'Матрица...',1,'');
		end;
	3:
		begin
		ramka(5,12,'Узнавалка естественных делителей числа...',1,'');
		end;
	4:
		begin
		ramka(5,16,'Про нумерологию...',1,'');
		end;
	5:
		begin
		ramka(5,20,'Назад...',1,'');
		end;
	end;
	k1:=k;
	end;
	if keypressed then
		begin
		c:=readkey;
		case c of
		#72:if k<>1 then k:=k-1;
		#80:if k<>5 then k:=k+1;
		#13:
			case k of
			1:
				begin
				programma_nomer_1;
				clrscr;
				ramka(5,20,'Назад...',1,'');
				//---------
				ramka(5,12,'Узнавалка естественных делителей числа...',1,'');
				//----------
				ramka(5,16,'Про нумерологию...',1,'');
				k:=1;
				k1:=2;
				end;
			2:
				begin
				programma_nomer_2;
				//risyn_smile_big;
				clrscr;
				k:=2;
				k1:=1;
				ramka(5,20,'Назад...',1,'');
				//---------
				ramka(5,12,'Узнавалка естественных делителей числа...',1,'');
				//----------
				ramka(5,16,'Про нумерологию...',1,'');
				end;
			3:
				begin
				programma_nomer_3;
				clrscr;
				k:=3;
				k1:=2;
				ramka(5,20,'Назад...',1,'');
				//---------
				ramka(5,16,'Про нумерологию...',1,'');
				//----------
				ramka(5,4,'Программа пишет код набранной клавиши...',1,'');
				end;
			4:
				begin
				parol(1);
				{nymer;}
				textbackground(chv_m);
				clrscr;
				k:=4;
				k1:=3;
				//textcolor(15);
				ramka(5,4,'Программа пишет код набранной клавиши...',1,'');
				ramka(5,8,'Матрица...',1,'');
				ramka(5,20,'Назад...',1,'');
				end;
			5:u:=2;
			end;
		end;end;
	end;
end;
{//--------------------------------------------------------PR+++}
procedure record_zm;
var     I,kol_rec:longint;
	st:string;
	rec:array[1..1000] of string;
begin
assign(fail_zm_rec,'r.txt');readln;delay(1000);
//reset(frc);
{readln(frc,kol_rec);
gt(1,23);
for i:=1 to 8 do write('	  ');
gt(1,24);
for i:=1 to 8 do write('	  ');
gt(1,25);
for i:=1 to 8 do write('	  ');
}gt(3,24);readln;{
t(15);
for i:=1 to kol_rec do readln(frc,rec[i]);
//close(frc);}
rewrite(fail_zm_rec);readln;
//write(frc,kol_rec+1);
//for i:=1 to kol_rec do writeln(frc,rec[i]);
write('Введите ваше имя =>'); readln;
readln(st);
writeln(fail_zm_rec,schet,'   ',level,'   ',st);
end;


{//--------------------------------------------------------PR+++}


function vopr( r:boolean ):boolean;
var i,u,k,k1:b;
begin
gt(1,23);
for i:=1 to 8 do write('	  ');
gt(1,24);
for i:=1 to 8 do write('	  ');
gt(1,25);
for i:=1 to 8 do write('	  ');
gt(3,24);
t(15);
write('Варианты дальнейших действий :');
k:=1;
u:=1;
k1:=2;
if r=true then ramka(74,23,'Выйти',1,'');
case r of
true:
while u=1 do
	begin
	if k1<>k then
		begin
		case k1 of
		1:ramka(33,23,'Продолжить игру',1,'');
		2:ramka(50,23,'Себя в рекорды и Выйти',1,'');
		3:ramka(74,23,'Выйти',1,'');
		end;
		case k of
		1:ramka(33,23,'Продолжить игру',2,'');
		2:ramka(50,23,'Себя в рекорды и Выйти',2,'');
		3:ramka(74,23,'Выйти',2,'');
		end;
		k1:=k;
		gtn;
		end;
	if keypressed then
		case readkey of
		#77:if k<>3 then k:=k+1;
		#75:if k<>1 then k:=k-1;
		#13,#28:
			case k of
			1:
				begin
				u:=2;
				vopr:=false;
				end;
			2:
				begin
				u:=2;
				vopr:=true;
				record_zm;
				end;
			3:
				begin
				u:=2;
				vopr:=true;
				end;
			end;

		end;
	end;
false:
while u=1 do
	begin
	if k1<>k then
		begin
		case k1 of
		1:ramka(33,23,'Продолжить игру...',1,'');
		2:ramka(55,23,'Выйти...',1,'');
		end;
		case k of
		1:ramka(33,23,'Продолжить игру...',2,'');
		2:ramka(55,23,'Выйти...',2,'');
		end;
		k1:=k;
		gtn;
		end;
	if keypressed then
		case readkey of
		#77:if k<>2 then k:=k+1;
		#75:if k<>1 then k:=k-1;
		#13,#28:
			case k of
			1:
				begin
				u:=2;
				vopr:=false;
				end;

			2:
				begin
				u:=2;
				vopr:=true;
				end;
			end;

		end;
	end;
end;
end;
{//--------------------------------------------------------PR+++}
procedure nach_zm;
var i,rrr,ff1,ff2,keyy:byte;
	ext:boolean;
Begin
TextBackgRound(chv_ig);
ClrScr;

fillchar(y,sizeof(y),0);
fillchar(x,sizeof(x),0);
Key:=' ';
Left:=0;
Top:=0;
kol_zm:=5;
Delay_zm:=40;
sh:=98;
schet:=0;
rrr:=1;
level:=1;
ext:=false;
keyy:=1;

{Игровое поле}
t(15);
gt(2,2);write(#201);for i:=1 to 76 do write(#205);write(#187);
gt(2,22);write(#200);for i:=1 to 76 do write(#205);write(#188);
for i:=3 to 21 do
	begin
	gt(2,i);
	write(#186);
	end;
for i:=3 to 21 do
	begin
	gt(79,i);
	write(#186);
	end;

   GoToXY(6,24);
   Write('Esc - Выход');
   GoToXY(35,24);
   Write('Счёт - ',schet);
   gt(60,24);
   write('Уровень - ',level);

   ff1:=s_ran(10,70);
   ff2:=s_ran(12,19);

{Начальные кординаты}
schet:=0;
For i:=1 to kol_zm do
 begin
 x[i]:=ff1-i;
 y[i]:=ff2;
 end;

{Прорисовка змеи}
Dostup:=True;
Zmeya(chv_k);
Repeat

 if ((dostup=false) and (key<>' ')) then
		begin
		top:=0;
		left:=0;
		key:=' ';
		zmeya(12);
		kol_zm:=1;
		t(10);
		GoToXY(6,24);
		Write('Esc - Выход...');
		end;

 if dostup then Zmeya1(chv_k);

 gtn;
 if rrr=1 then
	begin
	gt(25,7);
	t(chv_ig+1);
	highvideo;
	write('Нажмите ',#24,',',#25,' или ',#26,' для начала игры...');
	gt(30,8);
	write('Или Esc для выхода...');
	gtn;
	while not ((key=#77) or (key=#80) or (key=#27) or (key=#72)) do
		begin
		if keypressed then key:=readkey;
		end;
	rrr:=2;
	gt(25,7);
	write('					      ');
	gt(30,8);
	write('		     ');
	case key of
	#72:if (Top=1) and (Left=0) then begin end else begin Top:=-1; Left:=0; end;
	#80:if (Top=-1) and (Left=0) then begin end else begin Top:=1; Left:=0; end;
	#77:if (Top=0) and (Left=-1) then begin end else begin Top:=0; Left:=1; end;
	#75:if (Top=0) and (Left=1) then begin end else begin Top:=0; Left:=-1; end;
	end;
	end;
 if Delay_zm>0 then Delay(Delay_zm);
 //TextColor(2);
 if dostup then Zmeya2(chv_ig);
 if not dostup then
	begin
	zmeya(12);
	gtn;
	delay(100);
	end;

{Квавиши для движение змейки}

if KeyPressed=True then Key:=Readkey;
  Case Key of
   #27:
	begin
	Zmeya5(chv_k);
	case vopr(dostup) of
	true:
		begin
		keyy:=2;
		end;
	false:
		begin
		t(15);
		gt(1,23);
		for i:=1 to 8 do write('	  ');
		gt(1,24);
		for i:=1 to 8 do write('	  ');
		gt(1,25);
		for i:=1 to 8 do write('	  ');
		GoToXY(6,24);
		Write('Esc - Выход');
		GoToXY(35,24);
		Write('Счёт - ',schet);
		gt(60,24);
		write('Уровень - ',level);
		if dostup=false then key:=#72 else key:=' ';
		end;
	end;
	end;
   #72:if (Top=1) and (Left=0) then begin end else begin Top:=-1; Left:=0; end;
   #80:if (Top=-1) and (Left=0) then begin end else begin Top:=1; Left:=0; end;
   #77:if (Top=0) and (Left=-1) then begin end else begin Top:=0; Left:=1; end;
   #75:if (Top=0) and (Left=1) then begin end else begin Top:=0; Left:=-1; end;
  end;

if dostup then Izmenenie_Zmei;

{Еда}
if dostup=true then
begin
 if sh=100 then
  begin
  GotoXY(q1,q2);write(' ');
  TextColor(s_ran(10,15));
  highvideo;
  q1:=random(74)+3;
  q2:=random(17)+3;
  S:=s_ran(1,9);
  gt(q1,q2);
  Write(S);
  sh:=0;
  uuuu:=3;
  end
   else inc(sh);

 if (x[1] = q1) and (y[1]=q2) then
   begin
   sh:=100;
   inc(kol_zm,1);
   schet:=schet+s;
   TextColor(5);
   highvideo;
   GoToXY(42,24);
   Write(schet);
   if schet>100*level then
	begin
	inc(level);
	gt(70,24);
	write(level);
	if Delay_zm>7 then Delay_zm:=Delay_zm-5 else
		if Delay_zm>0 then Delay_zm:=Delay_zm-1;
	end;
   end;
end;

{Конец игры}
if dostup=true then
begin
if (Left<>0) and ((x[1]<3)) or (x[1]>78) then
 begin
 GoToXY(35,12);
 TextColor(chv_ig+1);
 highvideo;
 Write('ИГРА ОКОНЧЕНА!!!');
 Dostup:=False;
 end;
if (Top<>0) and ((y[1]<3)) or (y[1]>21) then
 begin
 GoToXY(35,12);
 TextColor(chv_ig+1);
 highvideo;
 Write('ИГРА ОКОНЧЕНА!!!');
 Dostup:=False;
 end;
end;

if KeyPressed=True then Key:=Readkey;

until Keyy=2;

End;


//--------------------------------------------------------PR+++
procedure nach_ig;
var u,k,k1:b;
begin
textbackground(chv_m);
clrscr;
u:=1;
k:=1;
k1:=2;
ramka(5,13,'Назад...',1,'');
while u=1 do
	begin
	if  k<>k1 then
		begin
		case k of
		1:begin
		  ramka(5,5,'Морской бой...',2,'');
		  end;
		2:begin
		  ramka(5,9,'Змейка...',2,'');
		  end;
		3:begin
		  ramka(5,13,'Назад...',2,'');
		  end;
		end;
		case k1 of
		1:begin
		  ramka(5,5,'Морской бой...',1,'');
		  end;
		2:begin
		  ramka(5,9,'Змейка...',1,'');
		  end;
		3:begin
		  ramka(5,13,'Назад...',1,'');
		  end;
		end;
		k1:=k;
		end;
	if keypressed then
		begin
		case readkey of
		#72:if k<>1 then k:=k-1;
		#80:if k<>3 then k:=k+1;
		#13:case k of
			3:u:=2;
			1:begin
			  nach_m_b;
			  textbackground(chv_m);
			  clrscr;
			  ramka(5,13,'Назад...',1,'');
			  k:=1;
			  k1:=2;
			  end;
			2:begin
			  nach_zm;
			  textbackground(chv_m);
			  clrscr;
			  ramka(5,13,'Назад...',1,'');
			  k:=2;
			  k1:=1;
			  end;
			end;
		end;
		end;
	end;
end;


//--------------------------------------------------------PR+++
procedure p_menu;   // k - позиция, k1 - её изменение
var     k1,u,k,vih:b;
	c:char;
	i:b;
begin
tb(chv_m);
clrscr;
u:=1;
k:=1;
k1:=2;
textcolor(15);
gotoxy(6,10);write(#201);
for i:=1 to 8 do write(#205);write(#187);
gotoxy(6,11);write(#186,'Опции...',#186);
gotoxy(6,12);write(#200);for i:=1 to 8 do write(#205);
write(#188);gotoxy(80,25);
gotoxy(6,14);write(#201);
for i:=1 to 8 do write(#205);write(#187);
gotoxy(6,15);write(#186,m[2],#186);
gotoxy(6,16);write(#200);for i:=1 to 8 do write(#205);
write(#188);gotoxy(80,25);
gl_men_n;
while u=1 do
begin
if k1<>k then
	begin
	case k of
	1:
		begin
		//clrscr;
		//------------------
		gotoxy(6,2);
		textcolor(chv_k);
		write(#218);for i:=1 to 14 do write(#196);write(#191);
		gotoxy(6,3);write(#179,'Начать игру...',#179);
		gotoxy(6,4);write(#192);for i:=1 to 14 do write(#196);
		write(#217);textcolor(15);
		end;
	2:
		begin
		gotoxy(6,6);textcolor(chv_k);write(#218);
		for i:=1 to 18 do write(#196);write(#191);
		gotoxy(6,7);write(#179,'Запуск программ...',#179);
		gotoxy(6,8);write(#192);for i:=1 to 18 do write(#196);
		write(#217);textcolor(15);
		end;
	3:
		begin
		gotoxy(6,10);textcolor(chv_k);write(#218);
		for i:=1 to 8 do write(#196);write(#191);
		gotoxy(6,11);write(#179,'Опции...',#179);
		gotoxy(6,12);write(#192);for i:=1 to 8 do write(#196);
		write(#217);textcolor(15);
		end;
	4:
		begin
		textcolor(chv_k);gotoxy(6,14);write(#218);
		for i:=1 to 8 do write(#196);write(#191);
		gotoxy(6,15);write(#179,m[2],#179);
		gotoxy(6,16);write(#192);for i:=1 to 8 do write(#196);
		write(#217);textcolor(15);
		end;
	end;
	case k1 of
	1:
		begin
		gotoxy(6,2);
		write(#201);for i:=1 to 14 do write(#205);write(#187);
		gotoxy(6,3);write(#186,'Начать игру...',#186);
		gotoxy(6,4);write(#200);for i:=1 to 14 do write(#205);
		write(#188);gotoxy(80,25);
		end;
	2:
		begin
		gotoxy(6,6);
		write(#201);for i:=1 to 18 do write(#205);write(#187);
		gotoxy(6,7);write(#186,'Запуск программ...',#186);
		gotoxy(6,8);write(#200);for i:=1 to 18 do write(#205);
		write(#188);gotoxy(80,25);
		end;
	3:
		begin
		gotoxy(6,10);write(#201);
		for i:=1 to 8 do write(#205);write(#187);
		gotoxy(6,11);write(#186,'Опции...',#186);
		gotoxy(6,12);write(#200);for i:=1 to 8 do write(#205);
		write(#188);gotoxy(80,25);
		end;
	4:
		begin
		gotoxy(6,14);write(#201);
		for i:=1 to 8 do write(#205);write(#187);
		gotoxy(6,15);write(#186,m[2],#186);
		gotoxy(6,16);write(#200);for i:=1 to 8 do write(#205);
		write(#188);gotoxy(80,25);
		end;
	end;
	k1:=k;
	end;
if KeyPressed then
	begin
	c:=ReadKey;
	case c of
		#80:
			begin
			case k of
				1:k:=2;
				2:k:=3;
				3:k:=4;
				end;
			end;
		#72:
			begin
			case k of
				2:k:=1;
				3:k:=2;
				4:k:=3;
				end;
			end;
		{#77,}#28,#13:
			begin
			case k of
				1:
					begin
					nach_ig;
					textbackground(chv_m);
					clrscr;
					gl_men_n;
					k:=1;
					k1:=2;
					textcolor(15);
					gotoxy(6,10);write(#201);
					for i:=1 to 8 do write(#205);write(#187);
					gotoxy(6,11);write(#186,'Опции...',#186);
					gotoxy(6,12);write(#200);for i:=1 to 8 do write(#205);
					write(#188);gotoxy(80,25);
					gotoxy(6,14);write(#201);
					for i:=1 to 8 do write(#205);write(#187);
					gotoxy(6,15);write(#186,m[2],#186);
					gotoxy(6,16);write(#200);for i:=1 to 8 do write(#205);
					write(#188);gotoxy(80,25);
					end;

				4:      begin
					vih:=0;
					vih:=vihod_v;
					case vih of
					0:begin
					clrscr;
					k:=4;
					k1:=3;
					gotoxy(6,2);
					write(#201);for i:=1 to 14 do write(#205);write(#187);
					gotoxy(6,3);write(#186,'Начать игру...',#186);
					gotoxy(6,4);write(#200);for i:=1 to 14 do write(#205);
					write(#188);
					gotoxy(6,6);
					write(#201);for i:=1 to 18 do write(#205);write(#187);
					gotoxy(6,7);write(#186,'Запуск программ...',#186);
					gotoxy(6,8);write(#200);for i:=1 to 18 do write(#205);
					write(#188);gotoxy(80,25);
					 end;
					1:u:=2;
					end;
					end;
				3:
					begin
					opch;
					textbackground(chv_m);
					clrscr;
					gl_men_n;
					k:=3;
					k1:=4;
					gotoxy(6,2);textcolor(15);
					write(#201);for i:=1 to 14 do write(#205);write(#187);
					gotoxy(6,3);write(#186,'Начать игру...',#186);
					gotoxy(6,4);write(#200);for i:=1 to 14 do write(#205);
					write(#188);
					gotoxy(6,6);
					write(#201);for i:=1 to 18 do write(#205);write(#187);
					gotoxy(6,7);write(#186,'Запуск программ...',#186);
					gotoxy(6,8);write(#200);for i:=1 to 18 do write(#205);
					write(#188);gotoxy(80,25);
					end;
				2:
					begin
					nach_p;
					clrscr;
					gl_men_n;
					k:=2;
					k1:=1;
					gotoxy(6,10);write(#201);
					for i:=1 to 8 do write(#205);write(#187);
					gotoxy(6,11);write(#186,'Опции...',#186);
					gotoxy(6,12);write(#200);for i:=1 to 8 do write(#205);
					write(#188);
					gotoxy(6,14);write(#201);
					for i:=1 to 8 do write(#205);write(#187);
					gotoxy(6,15);write(#186,m[2],#186);
					gotoxy(6,16);write(#200);for i:=1 to 8 do write(#205);
					write(#188);gotoxy(80,25);
					end;
				end;
			end;
		//#75:halt(1);
		end;
	end;

end;
end;

{//-----------------------KKKKKKKKK------------------------PR---+++}

procedure Run_TBUP();
begin
//risyn; risyn_us;
chv_m:=16;
chv_ig:=16;
chv_k:=10;
RandomIze;
p_menu;
end;

end.
