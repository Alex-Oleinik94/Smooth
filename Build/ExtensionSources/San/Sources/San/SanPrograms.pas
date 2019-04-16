//{$APPTYPE GUI}
{$NOTE Soglasheniya}
{$MODE OBJFPC}
(*
 ArDPoint, ArArDPoint {is DPoint}
 -2 = Obj
 -1 = User
 else = Sech
 
 Ar2DPoint {is DPoint}
 -1 = Tochka
 -2 = Line
 -3 = Poligone
 
 ArDDPoint {is DDPoint}
 
	(
	Line
	Length(ArGlSanKoor) = 3
	Length(ArDPoint) = 2
		{
		 0 = Tochka
		 1 = Line
		}
	)

	(
	Sechenie
	Length(ArLongint) = 1 (ID Secheniya)
	Length(ArGlSanKoor) = 3
	Length(ArDPoint) = 3 
	)
*)
unit SanPrograms;
interface
uses san,gl,crt,dos,math,SaGe;
const VersionSDD=6;
procedure InitWindowDoska();
implementation 
procedure GlSanSortArrayKoor( const pk,pn:pointer);
type
	TP=array of GlSanKoor;
	TN=array of longint;
var
	a:^TP=nil;
	ArN:^TN=nil;
	sk,k:GlSanKoor;
	ii,i,iii:longint;
	ArGSK1:array of GlSanKoor = nil;
	ArCos:array of real = nil;
	r,r1:REAL;
function GetAngle(const a:GlSanKoor):real;
begin
GetAngle:=arcCOS({GlSanRast(a,GlSanKoorImport(a.x,0,0))/}GlSanRast(a,GlSanKoorImport(0,a.y,0)));
if (a.x<0)and(a.y>0)then GetAngle+=pi/2;
if (a.x<0)and(a.y<0)then GetAngle+=pi;
if (a.x>0)and(a.y<0)then GetAngle+=3*pi/2;
end;
begin
a:=pk;
ArN:=pn;
sk:=NilKoor;
for i:=Low(a^) to High(a^) do
	sk+=a^[i];
sk/=Length(a^);
SetLength(ArGSK1,Length(a^));
SetLength(ArCos,Length(a^));
for i:=Low(ArGSK1) to High(ArGSK1) do
	ArGSK1[i]:=(a^[i]-sk)/GlSanRast(NilKoor,(a^[i]-sk));
for i:=Low(ArCos) to High(ArCos) do
	ArCos[i]:=GetAngle(ArGSK1[i]);
for i:=Low(a^) to High(a^) do
	begin
	iii:=-1;
	r:=3*pi;
	for ii:=i to High(a^) do
		begin
		if ArCos[ii]<r then
			begin
			r:=ArCos[ii];
			iii:=ii;
			end;
		end;
	if iii<>-1 then
		begin
		k:=a^[i];
		a^[i]:=a^[iii];
		a^[iii]:=k;
		k:=ArGSK1[i];
		ArGSK1[i]:=ArGSK1[iii];
		ArGSK1[iii]:=k;
		r1:=ArCos[i];
		ArCos[i]:=ArCos[iii];
		ArCos[iii]:=r1;
		ii:=ArN^[i];
		ArN^[i]:=ArN^[iii];
		ArN^[iii]:=ii;
		end;
	end;
SetLength(ArCos,0);
SetLength(ArGSK1,0);
end;
function CurKoorInObj(wnd:pointer; cur:pointer):boolean;
var
	UM:^GlSanWndUserMemory;
	O:^GlSanObj3;
	i:longint;
	CurKoor:GlSanKoor;
	K:^GlSanKoor;
	t:array[1..3]of GlSanKoor;
	ii:longint;
begin
CurKoorInObj:=false;
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
O:=@UM^.GlSanObj31;
if cur=nil then
	CurKoor:=GlSanReadMouseXYZ
else
	begin
	k:=cur;
	CurKoor:=k^;
	end;
{Точки обьекта}
i:=Low(O^.V);
while (i<>High(O^.V)+1) and (CurKoorInObj=false) do
	begin
	if GlSanPrinCub(O^.V[i],CurKoor,UM^.ArReal[Low(UM^.ArReal)])then
		CurKoorInObj:=true;
	i+=1;
	end;
i:=Low(UM^.ArDPoint);
while (i<>High(UM^.ArDPoint)+1) and (CurKoorInObj=false) do
	begin
	for ii:=1 to 2 do
		case UM^.ArDPoint[i,ii].ID of
		-2:t[ii]:=UM^.GlSanObj31.v[UM^.ArDPoint[i,ii].i];
		-1:t[ii]:=UM^.ArGlSanKoor[UM^.ArDPoint[i,ii].i];
		else t[ii]:=UM^.ArGlSanObj3[UM^.ArDPoint[i,ii].ID].v[UM^.ArDPoint[i,ii].i];
		end;
	if abs(abs(GlSanRast(t[1],t[2])-(GlSanRast(t[1],CurKoor)+GlSanRast(t[2],CurKoor))))<=GlSanMin then
		CurKoorInObj:=true;
	i+=1;
	end;
i:=Low(UM^.ArGlSanObj3);
while (i<>High(UM^.ArGlSanObj3)+1) and (CurKoorInObj=false) do
	begin
	ii:=Low(UM^.ArGlSanObj3[i].v);
	while (ii<>High(UM^.ArGlSanObj3[i].v)+1) and (CurKoorInObj=false) do
		begin
		if GlSanPrinCub(UM^.ArGlSanObj3[i].v[ii],CurKoor,UM^.ArReal[Low(UM^.ArReal)+2])then
			CurKoorInObj:=true;
		ii+=1;
		end;
	i+=1;
	end;
i:=Low(UM^.ArArDPoint);
while (i<>High(UM^.ArArDPoint)+1) and (CurKoorInObj=false) do
	begin
	case UM^.ArArDPoint[i,0].ID of
	-2:t[1]:=UM^.GlSanObj31.v[UM^.ArArDPoint[i,0].i];
	-1:t[1]:=UM^.ArGlSanKoor[UM^.ArArDPoint[i,0].i];
	else t[1]:=UM^.ArGlSanObj3[UM^.ArArDPoint[i,0].ID].v[UM^.ArArDPoint[i,0].i];
	end;
	ii:=Low(UM^.ArArDPoint[i])+1;
	while (ii<>High(UM^.ArArDPoint[i])) and (CurKoorInObj=false) do
		begin
		case UM^.ArArDPoint[i,ii].ID of
		-2:t[2]:=UM^.GlSanObj31.v[UM^.ArArDPoint[i,ii].i];
		-1:t[2]:=UM^.ArGlSanKoor[UM^.ArArDPoint[i,ii].i];
		else t[2]:=UM^.ArGlSanObj3[UM^.ArArDPoint[i,ii].ID].v[UM^.ArArDPoint[i,ii].i];
		end;
		case UM^.ArArDPoint[i,ii+1].ID of
		-2:t[3]:=UM^.GlSanObj31.v[UM^.ArArDPoint[i,ii+1].i];
		-1:t[3]:=UM^.ArGlSanKoor[UM^.ArArDPoint[i,ii+1].i];
		else t[3]:=UM^.ArGlSanObj3[UM^.ArArDPoint[i,ii+1].ID].v[UM^.ArArDPoint[i,ii+1].i];
		end;
		if GlSanPrinTreug(t[1],t[2],t[3],CurKoor) then
			CurKoorInObj:=true;
		ii+=1;
		end;
	i+=1;
	end;
i:=Low(O^.F);
while (i<>High(O^.F)+1) and (CurKoorInObj=false) do
	begin
	case length(o^.f[i]) of
	4:
		begin
		if GlSanPrinQuad(o^.v[o^.f[i,0]],o^.v[o^.f[i,1]],o^.v[o^.f[i,2]],o^.v[o^.f[i,3]],CurKoor) then
			CurKoorInObj:=true;
		end;
	3:
		begin
		if GlSanPrinTreug(o^.v[o^.f[i,0]],o^.v[o^.f[i,1]],o^.v[o^.f[i,2]],CurKoor) then
			CurKoorInObj:=true;
		end;
	else
		begin
		t[1]:=o^.v[o^.f[i,0]];
		for ii:=1 to  High (o^.f[i])-1 do
			begin
			if GlSanPrinTreug(t[1],o^.v[o^.f[i,ii]],o^.v[o^.f[i,ii+1]],CurKoor) then
				CurKoorInObj:=true;
			end;
		end;
	end;
	i+=1;
	end;
end;
function CurKoorOnlyInObj(wnd:pointer; cur:pointer):boolean;
var
	UM:^GlSanWndUserMemory;
	O:^GlSanObj3;
	i,ii:longint;
	CurKoor:GlSanKoor;
	K:^GlSanKoor;
	t:array [1..3] of GlSanKoor;
begin
CurKoorOnlyInObj:=false;
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
O:=@UM^.GlSanObj31;
if cur=nil then
	CurKoor:=GlSanReadMouseXYZ
else
	begin
	k:=cur;
	CurKoor:=k^;
	end;
i:=Low(O^.F);
while (i<>High(O^.F)+1) and (CurKoorOnlyInObj=false) do
	begin
	case length(o^.f[i]) of
	4:
		begin
		if GlSanPrinQuad(o^.v[o^.f[i,0]],o^.v[o^.f[i,1]],o^.v[o^.f[i,2]],o^.v[o^.f[i,3]],CurKoor) then
			CurKoorOnlyInObj:=true;
		end;
	3:
		begin
		if GlSanPrinTreug(o^.v[o^.f[i,0]],o^.v[o^.f[i,1]],o^.v[o^.f[i,2]],CurKoor) then
			CurKoorOnlyInObj:=true;
		end;
	else
		begin
		t[1]:=o^.v[o^.f[i,0]];
		for ii:=1 to  High (o^.f[i])-1 do
			begin
			if GlSanPrinTreug(t[1],o^.v[o^.f[i,ii]],o^.v[o^.f[i,ii+1]],CurKoor) then
				CurKoorOnlyInObj:=true;
			end;
		end;
	end;
	i+=1;
	end;
end;
procedure TetraedrObj3(var O:GlSanObj3);
procedure SetLengths;
begin O.Dispose;
SetLength(O.V,4);SetLength(O.F,4);
SetLength(O.F[0],3);SetLength(O.F[1],3);
SetLength(O.F[2],3);SetLength(O.F[3],3);
end;begin SetLengths;
O.V[0].Import(cos((2*pi/3)*1)*2,-0.8,sin((2*pi/3)*1)*2);
O.V[1].Import(cos((2*pi/3)*2)*2,-0.8,sin((2*pi/3)*2)*2);
O.V[2].Import(cos((2*pi/3)*3)*2,-0.8,sin((2*pi/3)*3)*2);
O.V[3].Import(0,2,0);
O.F[0,0]:=0;O.F[0,1]:=1;O.F[0,2]:=2;O.F[1,0]:=1;O.F[1,1]:=2;O.F[1,2]:=3;
O.F[2,0]:=0;O.F[2,1]:=1;O.F[2,2]:=3;O.F[3,0]:=0;O.F[3,1]:=2;O.F[3,2]:=3;
end;
procedure Puram4Obj3(var O:GlSanObj3);
procedure SetLengths;
begin O.Dispose;
SetLength(O.V,5);SetLength(O.F,5);
SetLength(O.F[0],3);SetLength(O.F[1],3);
SetLength(O.F[2],3);SetLength(O.F[3],3);
SetLength(O.F[4],4);end;begin SetLengths;
O.V[0].Import(0,2,0);O.V[1].Import(-1,-1,1);O.V[2].Import(1,-1,1);O.V[3].Import(1,-1,-1);O.V[4].Import(-1,-1,-1);
O.F[0,0]:=0;O.F[0,1]:=1;O.F[0,2]:=2;O.F[1,0]:=0;O.F[1,1]:=2;O.F[1,2]:=3;O.F[2,0]:=0;O.F[2,1]:=3;
O.F[2,2]:=4;O.F[3,0]:=0;O.F[3,1]:=4;O.F[3,2]:=1;O.F[4,0]:=1;O.F[4,1]:=2;O.F[4,2]:=3;O.F[4,3]:=4;
end;
procedure LoadLinesOfObj(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	i,ii,i1,i2,iii:longint;
	b:boolean;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
for i:=Low(UM^.ArArLongint) to High(UM^.ArArLongint) do
	SetLength(UM^.ArArLongint[i],0);
SetLength(UM^.ArArLongint,0);
for i:=Low(UM^.GlSanObj31.F) to High(UM^.GlSanObj31.F) do
	begin
	for ii:=Low(UM^.GlSanObj31.F[i]) to High(UM^.GlSanObj31.F[i]) do
		begin
		if ii=Low(UM^.GlSanObj31.F[i]) then
			i2:=UM^.GlSanObj31.F[i,High(UM^.GlSanObj31.F[i])]
		else
			i2:=UM^.GlSanObj31.F[i,ii-1];
		i1:=UM^.GlSanObj31.F[i,ii];
		b:=true;
		for iii:=Low(UM^.ArArLongint) to High(UM^.ArArLongint) do
			begin
			if (((i1=UM^.ArArLongint[i,Low(UM^.ArArLongint[i])]) and (i2=UM^.ArArLongint[i,High(UM^.ArArLongint[i])])) or
				((i2=UM^.ArArLongint[i,Low(UM^.ArArLongint[i])]) and (i1=UM^.ArArLongint[i,High(UM^.ArArLongint[i])]))) then
				begin
				b:=false;
				end;
			end;
		if b then
			begin
			SetLength(UM^.ArArLongint,Length(UM^.ArArLongint)+1);
			SetLength(UM^.ArArLongint[High(UM^.ArArLongint)],2);
			UM^.ArArLongint[High(UM^.ArArLongint),Low(UM^.ArArLongint[High(UM^.ArArLongint)])]:=i1;
			UM^.ArArLongint[High(UM^.ArArLongint),High(UM^.ArArLongint[High(UM^.ArArLongint)])]:=i2;
			end;
		end;
	end;
end;
procedure DeteleObjDoska(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	i:longint;
{$NOTE Delete Obj Of Doska}
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
SetLength(UM^.ArGlSanKoor,0);
UM^.GlSanObj31.Dispose;
for i:=0 to High(UM^.ArGlSanObj3) do
	UM^.ArGlSanObj3[i].Dispose;
SetLength(UM^.ArGlSanObj3,0);
SetLength(UM^.ArDPoint,0);
for i:=0 to High(UM^.ArArDPoint) do
	SetLength(UM^.ArArDPoint[i],0);
SetLength(UM^.ArArDPoint,0);
for i:=Low(UM^.ArDDPoint) to High(UM^.ArDDPoint) do
	UM^.ArDDPoint[i].Dispose;
SetLength(UM^.ArDDPoint,0);
end;
function RNRGetSech(const PObj:pointer;const P1,P2,P3:GlSanKoor; const Wnd:PGlSanWnd):pointer;
var
	PSech:^GlSanObj3;
	Obj:^GlSanObj3;
	i,ii,iii,iiii:longint;
	Koor:GlSanKoor;
	b:boolean = false;

	{ArK:array of GlSanKoor = nil ;
	ArN:array of longint = nil;
	ArN2:array of longint = nil;}
	
	IDT:array [1..3] of boolean = (false, false , false);
{$NOTE RNRGetSech}
	procedure RecRNRSech(const Pred2,Pred1,TStop:longint);
	var
		Pred0:longint = -1;
		i:longint = 0;
		ii:longint = 0;
		iii:longint =0 ;
		PlPred1:longint = -1;
	begin
	{Ищем, какой плоскости принадлежит Pred1 и изкомая следующая тоска}
	for i:=Low(Obj^.f) to High(Obj^.f) do
		begin
		if GlSanPointOnPlosk(PSech^.v[Pred1],
			GlSanPloskKoor(		Obj^.v[Obj^.f[i,0]],
								Obj^.v[Obj^.f[i,1]],
								Obj^.v[Obj^.f[i,2]])) and 
		(not GlSanPointOnPlosk(PSech^.v[Pred2],
				GlSanPloskKoor(	Obj^.v[Obj^.f[i,0]],
								Obj^.v[Obj^.f[i,1]],
								Obj^.v[Obj^.f[i,2]]))) then
			begin
			iii:=-1;
			for ii:=Low(PSech^.v) to High(PSech^.v) do
				begin
				Koor:=PSech^.v[ii];
				if (ii<>Pred1)  and 
				GlSanPointOnPlosk(PSech^.v[ii],
					GlSanPloskKoor(		Obj^.v[Obj^.f[i,0]],
										Obj^.v[Obj^.f[i,1]],
										Obj^.v[Obj^.f[i,2]]))
						and (GlSanRast(PSech^.v[ii],PSech^.v[Pred1])>GlSanMin)
						and  CurKoorOnlyInObj(wnd,@Koor) then
					iii:=ii;
				end;
			if iii<>-1 then
				PlPred1:=i;
			end;
		end;
	if PlPred1<>-1 then
		begin
		{Ищем следующую точку}
		for i:=low(PSech^.v) to high(PSech^.v) do
			begin
			Koor:=PSech^.v[i];
			if CurKoorOnlyInObj(wnd,@Koor) then
				begin
				if  (i<>pred2)and(i<>pred1) then
					begin
					if		GlSanPointOnPlosk(PSech^.v[i],
							GlSanPloskKoor(	Obj^.v[Obj^.f[PlPred1,0]],
											Obj^.v[Obj^.f[PlPred1,1]],
											Obj^.v[Obj^.f[PlPred1,2]]))then
							begin
							Pred0:=i;
							end;
					end;
				end;
			end;
		
		if (Pred0<>TStop) and (Pred0<>-1) then 
			begin
			//writeln(Pred0,'-sl ',PlPred1,' ts ',TStop);delay(100);
			SetLength(PSech^.f[Low(PSech^.f)],Length(PSech^.f[Low(PSech^.f)])+1);
			PSech^.f[Low(PSech^.f)][High(PSech^.f[Low(PSech^.f)])]:=Pred0;
			RecRNRSech(Pred1,Pred0,TStop);
			end;
		end;
	end;

procedure GetSechSaGe;
var
	b:array of cardinal = nil;
	ti:LongInt;
	tii,tiii:LongInt;
	Normal:GlSanKoor;
	Plosk:GlSanKoorPlosk;
	Znak:real = 0;
	R:real;
	tiiii:LongInt;

function Podstv(const a:glSanKoorPlosk;const b:GlSanKoor):real;
begin
Podstv:=a.a*b.x+a.b*b.y+a.c*b.z+a.d;
end;

begin
for ti:=0 to High(PSech^.v) do
	begin
	if CurKoorOnlyInObj(wnd,@PSech^.v[ti]) then
		begin
		SetLength(b,Length(b)+1);
		b[High(b)]:=ti;
		end;
	end;
SetLength(PSech^.f,1);
SetLength(PSech^.f[High(PSech^.f)],1);
PSech^.f[Low(PSech^.f)][Low(PSech^.f[Low(PSech^.f)])]:=b[high(b)];
SetLength(b,Length(b)-1);
Normal:=GetNormalVector(PSech^.v[0],PSech^.v[1],PSech^.v[2]);
tiiii:=0;
while (tiiii<>-1) and (Length(b)>0) do
	begin
	tiiii:=-1;
	for ti:=0 to High(b) do
		begin
		Znak:=0;
		Plosk:=GlSanPloskKoor(
			PSech^.v[b[ti]],
			PSech^.v[PSech^.f[High(PSech^.f)][High(PSech^.f[High(PSech^.f)])]],
			PSech^.v[PSech^.f[High(PSech^.f)][High(PSech^.f[High(PSech^.f)])]]+Normal);
		tiii:=-1;
		for tii:=0 to High(b) do
			if (tii<>ti) and (tii<>PSech^.f[High(PSech^.f)][High(PSech^.f[High(PSech^.f)])]) then
				begin
				r:=Podstv(Plosk,PSech^.v[b[tii]]);
				if Znak=0 then
					Znak:=r
				else
					begin
					if ((Znak>0)and(r<0))or((Znak<0)and(r>0)) then
						begin
						tiii:=0;
						break;
						end;
					end;
				end;
		if tiii=-1 then
			begin
			for tii:=0 to High(PSech^.f[High(PSech^.f)])-1 do
				begin
				r:=Podstv(Plosk,PSech^.v[PSech^.f[High(PSech^.f)][tii]]);
				if Znak=0 then
					Znak:=r
				else
					begin
					if ((Znak>0)and(r<0))or((Znak<0)and(r>0)) then
						begin
						tiii:=0;
						break;
						end;
					end;
				end;
			end;
		if tiii=-1 then
			begin
			SetLength(PSech^.f[High(PSech^.f)],Length(PSech^.f[High(PSech^.f)])+1);
			PSech^.f[High(PSech^.f)][High(PSech^.f[High(PSech^.f)])]:=b[ti];
			for tii:=ti+1 to High(b) do
				b[tii-1]:=b[tii];
			SetLength(b,Length(b)-1);
			tiiii:=0;
			Break;
			end;
		end;
	end;
SetLength(b,0);
end;

begin
Obj:=PObj;
PSech:=nil;
System.New(PSech);
RNRGetSech:=PSech;
PSech^.Dispose;
{Проверка на принодлежность одной грани}
(*Если все точки лежат в обной грани многогранника, то сечением будет эта грань и никаких точек и линий небудет...*)
ii:=-1;
for i:=Low(Obj^.f) to High(Obj^.f) do
	if ii=-1 then
		if 	((Length(Obj^.f[i])=3) and 
			GlSanPrinTreug(Obj^.v[Obj^.f[i,0]],Obj^.v[Obj^.f[i,1]],Obj^.v[Obj^.f[i,2]],p1) and
			GlSanPrinTreug(Obj^.v[Obj^.f[i,0]],Obj^.v[Obj^.f[i,1]],Obj^.v[Obj^.f[i,2]],p2) and
			GlSanPrinTreug(Obj^.v[Obj^.f[i,0]],Obj^.v[Obj^.f[i,1]],Obj^.v[Obj^.f[i,2]],p3))
			or
			((Length(Obj^.f[i])=4) and 
			GlSanPrinQuad(Obj^.v[Obj^.f[i,0]],Obj^.v[Obj^.f[i,1]],Obj^.v[Obj^.f[i,2]],Obj^.v[Obj^.f[i,3]],p1) and 
			GlSanPrinQuad(Obj^.v[Obj^.f[i,0]],Obj^.v[Obj^.f[i,1]],Obj^.v[Obj^.f[i,2]],Obj^.v[Obj^.f[i,3]],p2) and 
			GlSanPrinQuad(Obj^.v[Obj^.f[i,0]],Obj^.v[Obj^.f[i,1]],Obj^.v[Obj^.f[i,2]],Obj^.v[Obj^.f[i,3]],p3))  then
				ii:=i
		else
			if (Length(Obj^.f[i])>4) then
				begin
				Koor:=obj^.v[obj^.f[i,0]];
				IDT[1]:=false;
				IDT[2]:=false;
				IDT[3]:=false;
				for iii:=1 to  High (obj^.f[i])-1 do
					if ii=-1 then
						begin
						if GlSanPrinTreug(Koor,obj^.v[obj^.f[i,iii]],obj^.v[obj^.f[i,iii+1]],p1) then
							IDT[1]:=true;
						if  GlSanPrinTreug(Koor,obj^.v[obj^.f[i,iii]],obj^.v[obj^.f[i,iii+1]],p2) then
							IDT[2]:=true;
						if GlSanPrinTreug(Koor,obj^.v[obj^.f[i,iii]],obj^.v[obj^.f[i,iii+1]],p3) then
							IDT[3]:=true;
						end;
				if IDT[1] and IDT[2] and IDT[3] then
					ii:=i;
				end;
if ii<>-1 then
	begin
	SetLength(PSech^.f,1);
	SetLength(PSech^.f[Low(PSech^.f)],Length(Obj^.f[ii]));
	SetLength(PSech^.v,Length(Obj^.f[ii]));
	for i:=Low(PSech^.f[Low(PSech^.f)]) to High(PSech^.f[Low(PSech^.f)]) do
		PSech^.f[Low(PSech^.f)][i]:=i;
	for i:=Low(PSech^.f[Low(PSech^.f)]) to High(PSech^.f[Low(PSech^.f)]) do
		PSech^.v[i]:=Obj^.v[Obj^.f[ii,i]];
	exit;
	end;
{Вычисление точек}
{for i:=low(Obj^.f) to high(Obj^.f) do
	for ii:=low(Obj^.f) to high(Obj^.f) do
		if (i<>ii)  and (Length(Obj^.f[i])>=3) and (Length(Obj^.f[ii])>=3) then
			begin
			Koor:=GlSanTP3P(
					GlSanPloskKoor(Obj^.v[Obj^.f[i,0]],Obj^.v[Obj^.f[i,1]],Obj^.v[Obj^.f[i,2]]),
					GlSanPloskKoor(Obj^.v[Obj^.f[ii,0]],Obj^.v[Obj^.f[ii,1]],Obj^.v[Obj^.f[ii,2]]),
					GlSanPloskKoor(p1,p2,p3)
					);
			b:=true;
			for iii:=Low(PSech^.V) to High(PSech^.V) do
				if GlSanRast(PSech^.V[iii],Koor)<GlSanWndMin then
					b:=false;
			if GlSanMXYZT(Koor) and b then
				begin
				SetLength(PSech^.v,Length(PSech^.v)+1);
				PSech^.v[High(PSech^.v)]:=Koor;
				end;
			end;}
{Вычисление точек}
(*Просто вычисляем все точки, которые у нас будут в плоскости сечения*)
for i:=Low(Wnd^.UserMemory.ArArLongint) to High(Wnd^.UserMemory.ArArLongint) do
	begin
	Koor:=GlSanLineToPlosk(p1,p2,p3,
		Obj^.v[Wnd^.UserMemory.ArArLongint[i,0]],
		Obj^.v[Wnd^.UserMemory.ArArLongint[i,1]]);
	iii:=0;
	for ii:=0 to High(PSech^.v) do
		if GlSanRast(Koor,PSech^.v[ii])<0.005 then
			begin
			iii:=1;
			Break;
			end;
	if GlSanMXYZT(Koor) and (iii=0) then
		begin
		SetLength(PSech^.v,Length(PSech^.v)+1);
		PSech^.v[High(PSech^.v)]:=Koor;
		end;
	end;
(*NewSechenie ( SaGe ) *)
GetSechSaGe;
{Вычисление плоскости сечения}
(*СтарьЁ*)
//Ищем первую точку для плоскости
(*for i:=low(PSech^.v) to high(PSech^.v) do
	begin
	if CurKoorOnlyInObj(wnd,@PSech^.v[i])then
		begin
		iii:=i;
		end;
	end;*)
//Ищем плоскость первой точки
(*for i:=low(Obj^.f) to high(Obj^.f) do
	begin
	if GlSanPointOnPlosk(PSech^.v[iii],GlSanPloskKoor(Obj^.v[Obj^.f[i,0]],Obj^.v[Obj^.f[i,1]],Obj^.v[Obj^.f[i,2]]))then
		for ii:=low(PSech^.v) to high(PSech^.v) do
			begin
			if (iii<>ii) and GlSanPointOnPlosk(PSech^.v[ii],GlSanPloskKoor(Obj^.v[Obj^.f[i,0]],Obj^.v[Obj^.f[i,1]],Obj^.v[Obj^.f[i,2]]))
				and CurKoorOnlyInObj(wnd,@PSech^.v[ii]) then
				begin
				iiii:=ii;
				end;
			end;
	end;*)
//Заполняем массив найденными точками и Выполняем рекурсию
(*SetLength(PSech^.f,1);
SetLength(PSech^.f[High(PSech^.f)],2);
PSech^.f[Low(PSech^.f)][Low(PSech^.f[Low(PSech^.f)])+0]:=iii;
PSech^.f[Low(PSech^.f)][Low(PSech^.f[Low(PSech^.f)])+1]:=iiii;
if (iii<>-1) and (iiii<>-1) then RecRNRSech(iii,iiii,iii);*)
{// Вычисление по новому
SetLength(PSech^.f,1);
SetLength(PSech^.f[High(PSech^.f)],0);
SetLength(ArK,0);
SetLength(ArN,0);
SetLength(ArN2,0);
for i:=Low(PSech^.v) to High(PSech^.v) do
	begin
	if CurKoorOnlyInObj(wnd,@PSech^.v[i]) then
		begin
		SetLength(ArK,Length(ArK)+1);
		SetLength(ArN,Length(ArN)+1);
		ArK[High(ArK)]:=PSech^.v[i];
		ArN[High(ArN)]:=i;
		end;
	end;
SetLength(ArN2,Length(ArN));
for i:=Low(ArN) to High(ArN2) do
	ArN2[i]:=ArN[i];
GlSanSortArrayKoor(@ArK,@ArN);
SetLength(PSech^.f[High(PSech^.f)],Length(ArN));
for i:=Low(ArN) to High(ArN) do
	begin
	PSech^.f[High(PSech^.f)][i]:=ArN[i];
	end;
SetLength(ArK,0);
SetLength(ArN,0);
SetLength(ArN2,0);}

{Вычисление линий}
{for i:=Low(Obj^.f) to High(Obj^.f) do
	begin
	SetLength(PSech^.f,Length(PSech^.F)+1);
	SetLength(PSech^.F[High(PSech^.F)],0);
	for ii:=lOw(PSech^.v) to High(PSech^.v) do
		begin
		iii:=0;
		if GlSanPointOnPlosk(PSech^.v[ii],GlSanPloskKoor(Obj^.v[Obj^.f[i,0]],Obj^.v[Obj^.f[i,1]],Obj^.v[Obj^.f[i,2]])) then
			iii:=1;
		if iii=1 then 
			begin
			SetLength(PSech^.F[High(PSech^.F)],Length(PSech^.F[High(PSech^.F)])+1);
			PSech^.F[High(PSech^.F)][High(PSech^.F[High(PSech^.F)])]:=ii;
			end;
		end;
	writeln(Length(PSech^.F[High(PSech^.F)]));
	iii:=-1;
	r:=0;
	for ii:=0 to High(PSech^.F[High(PSech^.F)])do
		begin
		if (GlSanRast(NilKoor,PSech^.v[PSech^.F[High(PSech^.F),ii]])>r)then
			begin
			r:=GlSanRast(NilKoor,PSech^.v[PSech^.F[High(PSech^.F),ii]]);
			iii:=ii;
			end;
		end;
	r:=0;
	iiii:=-1;
	for ii:=0 to High(PSech^.F[High(PSech^.F)])do
		begin
		if (GlSanRast(PSech^.v[PSech^.F[High(PSech^.F),iii]],PSech^.v[PSech^.F[High(PSech^.F),ii]])>r)then
			begin
			r:=GlSanRast(PSech^.v[PSech^.F[High(PSech^.F),iii]],PSech^.v[PSech^.F[High(PSech^.F),ii]]);
			iiii:=ii;
			end;
		end;
	if iiii+iii>=0 then
		begin
		SetLength(PSech^.F[High(PSech^.F)],2);
		PSech^.F[High(PSech^.F),0]:=iii;
		PSech^.F[High(PSech^.F),1]:=iiii;
		end;
	end;}
for i:=Low(PSech^.v) to High(PSech^.v) do
	for ii:=Low(PSech^.v) to High(PSech^.v) do
		if (ii<>i) then
			begin
			b:=false;
			for iii:=Low(Obj^.f) to High(Obj^.f) do
				if (Length(Obj^.f[iii])>=3) then
					begin
					if GlSanPointOnPlosk(PSech^.v[ii],GlSanPloskKoor(Obj^.v[Obj^.f[iii,0]],Obj^.v[Obj^.f[iii,1]],Obj^.v[Obj^.f[iii,2]])) and
						GlSanPointOnPlosk(PSech^.v[i],GlSanPloskKoor(Obj^.v[Obj^.f[iii,0]],Obj^.v[Obj^.f[iii,1]],Obj^.v[Obj^.f[iii,2]])) then
						begin
						b:=true;
						end;
					end;
			if b then
				begin
				for iii:=Low(PSech^.F) to High(PSech^.F) do
					if (Length(PSech^.F[iii])=2) and (((i=PSech^.F[iii,1]) and (ii=PSech^.F[iii,0])) or ((ii=PSech^.F[iii,1]) and (i=PSech^.F[iii,0]))) then
						b:=false;
				end;
			if b then
				begin
				Koor:=PSech^.v[ii];
				if CurKoorOnlyInObj(wnd,@Koor) then
					begin
					Koor:=PSech^.v[i];
					if CurKoorOnlyInObj(wnd,@Koor) then
						b:=false;
					end
				else
					begin
					Koor:=PSech^.v[i];
					end;
				end;
			if b then
				begin
				SetLength(PSech^.f,Length(PSech^.F)+1);
				SetLength(PSech^.F[High(PSech^.F)],2);
				PSech^.f[High(PSech^.f),0]:=i;
				PSech^.f[High(PSech^.f),1]:=ii;
				end;
			end;
{Вычисление линий сечения к объекту}
for i:=Low(PSech^.v) to High(PSech^.v) do
	begin
	koor:=PSech^.v[i];
	if not CurKoorOnlyInObj(wnd,@Koor)then
		begin
		ii:=0;
		iiii:=-1;
		while 	(ii<=High(Wnd^.UserMemory.ArArLongint)) and (iiii=-1) do
			begin
			if (GlSanKoorOnLine(Obj^.v[Wnd^.UserMemory.ArArLongint[ii,0]],Obj^.v[Wnd^.UserMemory.ArArLongint[ii,1]],PSech^.v[i])) then
				begin
				iiii:=0;
				SetLength(PSech^.f,Length(PSech^.F)+1);
				SetLength(PSech^.F[High(PSech^.F)],2);
				if GlSanRast(PSech^.v[i],Obj^.v[Wnd^.UserMemory.ArArLongint[ii,0]])>GlSanRast(PSech^.v[i],Obj^.v[Wnd^.UserMemory.ArArLongint[ii,1]]) then
					PSech^.f[High(PSech^.f),0]:=Wnd^.UserMemory.ArArLongint[ii,1]+High(PSech^.v)+1
				else
					PSech^.f[High(PSech^.f),0]:=Wnd^.UserMemory.ArArLongint[ii,0]+High(PSech^.v)+1;
				PSech^.f[High(PSech^.f),1]:=i;
				end;
			ii+=1;
			end;
		end;
	end;
end;
procedure ReSech(Wnd:pointer;l:longint);
var
	UM:^GlSanWndUserMemory;
	Obj:^GlSanObj3;
	W:PGlSanWnd;
	i,ii:longint;
	t13:array [0..2] of GlSanKoor;
{$NOTE ReSech}
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
w:=wnd;
for i:=Low(UM^.ArDDPoint[l].ArDPoint) to High(UM^.ArDDPoint[l].ArDPoint) do
	case UM^.ArDDPoint[l].ArDPoint[i].ID of
	-2:t13[i]:=UM^.GlSanObj31.v[UM^.ArDDPoint[l].ArDPoint[i].i];
	-1:t13[i]:=UM^.ArGlSanKoor[UM^.ArDDPoint[l].ArDPoint[i].i];
	end;
Obj:=RNRGetSech(@W^.UserMemory.GlSanObj31,t13[0],t13[1],t13[2],wnd);
UM^.ArGlSanObj3[UM^.ArDDPoint[l].ArLongint[Low(UM^.ArDDPoint[l].ArDPoint)]].Dispose;
SetLength(UM^.ArGlSanObj3[UM^.ArDDPoint[l].ArLongint[Low(UM^.ArDDPoint[l].ArDPoint)]].v,Length(Obj^.v));
SetLength(UM^.ArGlSanObj3[UM^.ArDDPoint[l].ArLongint[Low(UM^.ArDDPoint[l].ArDPoint)]].f,Length(Obj^.f));
for i:=Low(Obj^.f) to High(Obj^.f) DO
	SetLength(UM^.ArGlSanObj3[UM^.ArDDPoint[l].ArLongint[Low(UM^.ArDDPoint[l].ArDPoint)]].f[i],Length(Obj^.f[i]));
for i:=Low(Obj^.v) to High(Obj^.v) do
	UM^.ArGlSanObj3[UM^.ArDDPoint[l].ArLongint[Low(UM^.ArDDPoint[l].ArDPoint)]].v[i]:=Obj^.v[i];
for i:=Low(Obj^.f) to High(Obj^.f) do
	for ii:=Low(Obj^.f[i]) to High(Obj^.f[i]) do
		begin
		UM^.ArGlSanObj3[UM^.ArDDPoint[l].ArLongint[Low(UM^.ArDDPoint[l].ArDPoint)]].f[i,ii]:=Obj^.f[i,ii];
		end;
UM^.ArDDPoint[l].ArGlSanKoor[Low(UM^.ArDDPoint[l].ArGlSanKoor)+0]:=t13[0];
UM^.ArDDPoint[l].ArGlSanKoor[Low(UM^.ArDDPoint[l].ArGlSanKoor)+1]:=t13[1];
UM^.ArDDPoint[l].ArGlSanKoor[Low(UM^.ArDDPoint[l].ArGlSanKoor)+2]:=t13[2];
Obj^.Dispose;
System.Dispose(Obj);
end;

procedure ReLoadObj(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	k:GlSanKoor;
	i:longint;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
k.Import(0,0,0);
for i:=0 to High(UM^.GlSanObj31.v) do
	begin
	K.Togever(UM^.GlSanObj31.v[i]);
	end;
K.Zum(-1/Length(UM^.GlSanObj31.v));
for i:=0 to High(UM^.GlSanObj31.v) do
	begin
	UM^.GlSanObj31.v[i].Togever(k);
	end;
end;
function GetVersionSDD(const s:string):longint;
var
	ID:longint = 8;
	St2:string = '';
begin
repeat
St2+=s[ID];
ID+=1;
until not (s[ID] in ['0'..'9']);
GetVersionSDD:=GlSanVal(St2);
end;
function LoadFileDoska2(s:string;w:pointer;b:boolean):boolean;
var
	f:text;
	i,ii:longint;
	s1:string;
	UM:^GlSanWndUserMemory;
{$NOTE LoadFile}
begin
LoadFileDoska2:=false;
UM:=GlSanWndGetPointerOfUserMemory(@W);
assign(f,s);
reset(f);
readln(f,s1);
for i:=1 to Length(s1) do
	s1[i]:=UpCase(s1[i]);
if ((s1[1]='S') and (s1[2]='S') and (s1[3]='D')) then
	begin
	if GetVersionSDD(s1)=VersionSDD then
		begin
		DeteleObjDoska(w);
		if b then
			readln(f,UM^.Zum,UM^.Rot1,UM^.Rot2,UM^.LZ,UM^.UZ)
		else
			readln(f);
		for i:=Low(UM^.ArGlSanColor4f) to High(UM^.ArGlSanColor4f) do
			UM^.ArGlSanColor4f[i].ReadlnFromFile(@f);
		for i:=Low(UM^.ArReal) to High(UM^.ArReal) do
			readln(f,UM^.ArReal[i]);
		UM^.GlSanObj31.ReadlnFromFile(@f);
		Readln(f,i);
		SetLength(UM^.ArGlSanKoor,i);
		for i:=Low(UM^.ArGlSanKoor) to High(UM^.ArGlSanKoor) do
			UM^.ArGlSanKoor[i].ReadlnFromFile(@F);
		Readln(f,i);
		SetLength(UM^.ArGlSanObj3,i);
		for i:=Low(UM^.ArGlSanObj3) to High(UM^.ArGlSanObj3) do
			UM^.ArGlSanObj3[i].ReadlnFromFile(@F);
		Readln(f,i);
		SetLength(UM^.ArDPoint,i);
		for i:=0 to High(UM^.ArDPoint) do
			readln(f,UM^.ArDPoint[i,1].ID,UM^.ArDPoint[i,1].I,UM^.ArDPoint[i,2].ID,UM^.ArDPoint[i,2].I);
		readln(f,i);
		SetLength(UM^.ArArDPoint,i);
		for i:=0 to High(UM^.ArArDPoint) do
			begin
			read(f,ii);
			SetLength(UM^.ArArDPoint[i],ii);
			for ii:=0 to high(UM^.ArArDPoint[i]) do
				read(f,UM^.ArArDPoint[i,ii].ID,UM^.ArArDPoint[i,ii].I);
			readln(f);
			end;
		readln(f,i);
		SetLength(UM^.ArDDPoint,i);
		for i:=Low(UM^.ArDDPoint) to High(UM^.ArDDPoint) do
			begin
			readln(f,ii);
			SetLength(UM^.ArDDPoint[i].ArLongint,ii);
			for ii:=Low(UM^.ArDDPoint[i].ArLongint) to High(UM^.ArDDPoint[i].ArLongint) do
				read(f,UM^.ArDDPoint[i].ArLongint[ii]);
			readln(f);
			readln(f,ii);
			SetLength(UM^.ArDDPoint[i].ArGlSanKoor,ii);
			for ii:=Low(UM^.ArDDPoint[i].ArGlSanKoor) to High(UM^.ArDDPoint[i].ArGlSanKoor) do
				UM^.ArDDPoint[i].ArGlSanKoor[ii].ReadlnFromFile(@F);
			readln(f,ii);
			SetLength(UM^.ArDDPoint[i].ArDPoint,ii);
			for ii:=Low(UM^.ArDDPoint[i].ArDPoint) to High(UM^.ArDDPoint[i].ArDPoint) do
				begin
				readln(f,UM^.ArDDPoint[i].ArDPoint[ii].ID,UM^.ArDDPoint[i].ArDPoint[ii].I);
				end;
			end;
		if b then GlSanCreateOKWnd(W,'Загружено','Cохранение загружено успешно!');
		LoadFileDoska2:=true;
		LoadLinesOfObj(W);
		end
	else
		begin
		if b then GlSanCreateOKWnd(W,'Невозможно','Нужен файл версии ('+GlSanStr(VersionSDD)+')');
		end;
	end
else
	begin
	if ((s1[1]='O') and (s1[2]='F') and (s1[3]='F')) then
		begin
		DeteleObjDoska(w);
		SetLength(UM^.ArGlSanKoor,0);
		for i:=Low(UM^.ArGlSanObj3) to High(UM^.ArGlSanObj3) do
			UM^.ArGlSanObj3[i].Dispose;
		SetLength(UM^.ArGlSanObj3,0);
		close(f);
		assign(f,s);
		reset(f);
		UM^.GlSanObj31.ReadlnFromFile(@f);
		if b then GlSanCreateOKWnd(W,'Загружено','Cохранение загружено успешно!');
		LoadFileDoska2:=true;
		ReLoadObj(w);
		LoadLinesOfObj(W);
		end
	else
		begin
		if b then GlSanCreateOKWnd(W,'Невозможно','Невозможно установить тип файла');
		end;
	end;
close(f);
if b then
	UM^.ArBoolean[11]:=true;
end;
procedure SaveSSD(Wnd:pointer;Str:string);
var
	UM:^GlSanWndUserMemory;
	F:text;
	i,ii:longint;
{$NOTE SaveSSD Doska}
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
assign(f,str);
rewrite(f);
writeln(f,'SSD (v.'+GlSanStr(VersionSDD)+')');
writeln(f,UM^.Zum:0:7,' ',UM^.Rot1:0:6,' ',UM^.Rot2:0:6,' ',UM^.LZ:0:6,' ',UM^.UZ:0:7);
for i:=Low(UM^.ArGlSanColor4f) to High(UM^.ArGlSanColor4f) do
	begin
	writeln(f,
	UM^.ArGlSanColor4f[i].a:0:6,' ',
	UM^.ArGlSanColor4f[i].b:0:6,' ',
	UM^.ArGlSanColor4f[i].c:0:6,' ',
	UM^.ArGlSanColor4f[i].d:0:6);
	end;
for i:=Low(UM^.ArReal) to High(UM^.ArReal) do
	begin
	writeln(f,UM^.ArReal[i]:0:6);
	end;
UM^.GlSanObj31.WritelnToFile(@F);
writeln(f,Length(UM^.ArGlSanKoor));
for i:=Low(UM^.ArGlSanKoor) to High(UM^.ArGlSanKoor) do
	UM^.ArGlSanKoor[i].WritelnToFile(@F);
writeln(f,Length(UM^.ArGlSanObj3));
for i:=Low(UM^.ArGlSanObj3) to High(UM^.ArGlSanObj3) do
	UM^.ArGlSanObj3[i].WritelnToFile(@F);
writeln(f,Length(UM^.ArDPoint));
for i:=0 to High(UM^.ArDPoint) do
	writeln(f,UM^.ArDPoint[i,1].ID,' ',UM^.ArDPoint[i,1].I,' ',UM^.ArDPoint[i,2].ID,' ',UM^.ArDPoint[i,2].I);
writeln(f,Length(UM^.ArArDPoint));
for i:=0 to High(UM^.ArArDPoint) do
	begin
	write(f,Length(UM^.ArArDPoint[i]),' ');
	for ii:=0 to High(UM^.ArArDPoint[i]) do
		begin
		write(f,UM^.ArArDPoint[i,ii].ID,' ',UM^.ArArDPoint[i,ii].I,' ');
		end;
	writeln(f);
	end;
(*Сохранение Родительских связей*)
writeln(f,Length(UM^.ArDDPoint),' fds');
for i:=Low(UM^.ArDDPoint) to High(UM^.ArDDPoint) do
	begin
	writeln(f,Length(UM^.ArDDPoint[i].ArLongint));
	for ii:=Low(UM^.ArDDPoint[i].ArLongint) to High(UM^.ArDDPoint[i].ArLongint) do
		write(f,UM^.ArDDPoint[i].ArLongint[ii],' ');
	writeln(f);
	writeln(f,Length(UM^.ArDDPoint[i].ArGlSanKoor));
	for ii:=Low(UM^.ArDDPoint[i].ArGlSanKoor) to High(UM^.ArDDPoint[i].ArGlSanKoor) do
		UM^.ArDDPoint[i].ArGlSanKoor[ii].WritelnToFile(@F);
	writeln(f,Length(UM^.ArDDPoint[i].ArDPoint));
	for ii:=Low(UM^.ArDDPoint[i].ArDPoint) to High(UM^.ArDDPoint[i].ArDPoint) do
		writeln(f,UM^.ArDDPoint[i].ArDPoint[ii].ID,' ',UM^.ArDDPoint[i].ArDPoint[ii].I);
	end;
close(f);
end;

procedure CanselWndDoska(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	w:GlSanUWnd;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
if Length(UM^.ArPointer)>0 then
	begin
	w:=UM^.ArPointer[Low(UM^.ArPointer)];
	GlSanWndOldDependentWnd(@w,wnd);
	end;
GlSanKillWnd(@Wnd);
end;
procedure ImportFalseParalilepiped4(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
begin
uM:=GlSanWndGetPointerOfUserMemory(@Wnd);
DeteleObjDoska(Wnd);
FalseParalilepiped4Obj3(UM^.GlSanObj31);
UM^.ArBoolean[11]:=true;
ReLoadObj(wnd);
LoadLinesOfObj(wnd);
end;
procedure ImportTruePrizma6(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
begin
uM:=GlSanWndGetPointerOfUserMemory(@Wnd);
DeteleObjDoska(Wnd);
TruePrizma6Obj3(UM^.GlSanObj31);
UM^.ArBoolean[11]:=true;
ReLoadObj(wnd);
LoadLinesOfObj(wnd);
end;
procedure ImportTruePrizma3(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
begin
uM:=GlSanWndGetPointerOfUserMemory(@Wnd);
DeteleObjDoska(Wnd);
TruePrizma3Obj3(UM^.GlSanObj31);
UM^.ArBoolean[11]:=true;
ReLoadObj(wnd);
LoadLinesOfObj(wnd);
end;
procedure ImportParalilepiped(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
begin
uM:=GlSanWndGetPointerOfUserMemory(@Wnd);
DeteleObjDoska(Wnd);
ParalilepipedObj3(UM^.GlSanObj31);
UM^.ArBoolean[11]:=true;
ReLoadObj(wnd);
LoadLinesOfObj(wnd);
end;
procedure ImportOktaedr(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
begin
uM:=GlSanWndGetPointerOfUserMemory(@Wnd);
DeteleObjDoska(Wnd);
OktaedrObj3(UM^.GlSanObj31);
UM^.ArBoolean[11]:=true;
ReLoadObj(wnd);
LoadLinesOfObj(wnd);
end;
procedure ImportIkosaedr(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
begin
uM:=GlSanWndGetPointerOfUserMemory(@Wnd);
DeteleObjDoska(Wnd);
IkosaedrObj3(UM^.GlSanObj31);
UM^.ArBoolean[11]:=true;
ReLoadObj(wnd);
LoadLinesOfObj(wnd);
end;
procedure ImportDadekaedr(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
begin
uM:=GlSanWndGetPointerOfUserMemory(@Wnd);
DeteleObjDoska(Wnd);
DadekaedrObj3(UM^.GlSanObj31);
UM^.ArBoolean[11]:=true;
ReLoadObj(wnd);
LoadLinesOfObj(wnd);
end;
procedure ImportTetraedr(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
begin
uM:=GlSanWndGetPointerOfUserMemory(@Wnd);
DeteleObjDoska(Wnd);
TetraedrObj3(UM^.GlSanObj31);
UM^.ArBoolean[11]:=true;
ReLoadObj(wnd);
LoadLinesOfObj(wnd);
end;
procedure ImportCube(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
begin
uM:=GlSanWndGetPointerOfUserMemory(@Wnd);
DeteleObjDoska(Wnd);
CubObj3(UM^.GlSanObj31);
UM^.ArBoolean[11]:=true;
ReLoadObj(wnd);
LoadLinesOfObj(wnd);
end;
procedure ImportPyram(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
begin
uM:=GlSanWndGetPointerOfUserMemory(@Wnd);
DeteleObjDoska(Wnd);
Puram4Obj3(UM^.GlSanObj31);
UM^.ArBoolean[11]:=true;
ReLoadObj(wnd);
LoadLinesOfObj(wnd);
end;

function NameFile(const s:string):string;
var
	i:longint;
begin
i:=1;
NameFile:='';
while ((s[i]<>'.') and (Length(s)>i-1)) do
	begin
	NameFile+=s[i];
	i+=1;
	end;
end;

procedure SaveSDDToBuffer(Wnd:pointer);
var
	sr:DOS.SearchRec;
	i,ii,iii,iiii:longint;
	UM:^GlSanWndUserMemory;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
i:=-1;
DOS.findfirst('Buffer\SSD\*.ssd',$3F,sr);
While (dos.DosError<>18) do
	begin
	ii:=-1;
	iii:=1;
	while ((sr.name[iii]<>'.') and (iii-1<Length(sr.name))) do
		begin
		if  not (sr.name[iii] in ['0','1','2','3','4','5','6','7','8','9']) then
			ii:=0;
		iii+=1;
		end;
	if ii=-1 then
		begin
		iiii:=GlSanVal(NameFile(sr.name));
		if iiii>i then
			i:=iiii;
		end;
	DOS.findnext(sr);
	end;
FindClose(sr);
if i=-1 then
	begin
	SaveSSD(Wnd,'Buffer\SSD\'+GlSanStr(1)+'.ssd');
	UM^.ArLongint[4]:=1;
	UM^.ArBoolean[11]:=false;
	end
else
	begin
	SaveSSD(Wnd,'Buffer\SSD\'+GlSanStr(i+1)+'.ssd');
	UM^.ArLongint[4]:=i+1;
	UM^.ArBoolean[11]:=false;
	end;
end;
procedure LoadFromBufferDoska(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	sr:DOS.SearchRec;
	i,ii,iii,iiii:longint;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
i:=-1;
DOS.findfirst('Buffer\SSD\*.ssd',$3F,sr);
While (dos.DosError<>18) do
	begin
	ii:=-1;
	iii:=1;
	while ((sr.name[iii]<>'.') and (iii-1<Length(sr.name))) do
		begin
		if  not (sr.name[iii] in ['0','1','2','3','4','5','6','7','8','9']) then
			ii:=0;
		iii+=1;
		end;
	if ii=-1 then
		begin
		iiii:=GlSanVal(NameFile(sr.name));
		if iiii>i then
			i:=iiii;
		end;
	DOS.findnext(sr);
	end;
FindClose(sr);
if i<>-1 then
	if i<UM^.ArLongint[4] then
		begin
		UM^.ArLongint[4]-=1;
		end
	else
		begin
		LoadFileDoska2('Buffer\SSD\'+GlSanStr(UM^.ArLongint[4])+'.ssd',wnd,false);
		end;
end;
procedure DeleteLine(Wnd:PGlSanWnd);
var i,ii:longint;
	UM:^GlSanWndUserMemory;
	ParentDelleted:boolean=false;
begin
{Удаление линии}
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
if Wnd^.UserMemory.ArLongint[5]<>-1 then
	begin
	for i:=Wnd^.UserMemory.ArLongint[5] to high(UM^.ArDPoint)-1 do
		begin
		UM^.ArDPoint[i]:=UM^.ArDPoint[i+1];
		end;
	SetLength(UM^.ArDPoint,Length(UM^.ArDPoint)-1);
	UM^.ArBoolean[11]:=true;
	end;
{Тут должно быть удаление возможного Парент-Чилда этой линии!!!!!!!!!!!}
(*Тут*)
if Wnd^.UserMemory.ArLongint[5]<>-1 then
	begin
	i:=Low(UM^.ArDDPoint);
	while i<=High(UM^.ArDDPoint) do
		begin
		if (Length(UM^.ArDDPoint[i].ArLongint)=2) and (Length(UM^.ArDDPoint[i].ArGlSanKoor)=3) and (Length(UM^.ArDDPoint[i].ArDPoint)=0)then
			begin
			if(UM^.ArDDPoint[i].ArLongint[1]>Wnd^.UserMemory.ArLongint[5]) and (Wnd^.UserMemory.ArLongint[5]>=1) then
				begin
				UM^.ArDDPoint[i].ArLongint[1]-=1;
				end
			else
				if(UM^.ArDDPoint[i].ArLongint[1]=Wnd^.UserMemory.ArLongint[5])and( not ParentDelleted) then
					begin
					UM^.ArDDPoint[i].Dispose;
					for ii:=i to High(UM^.ArDDPoint)-1 do
						UM^.ArDDPoint[ii]:=UM^.ArDDPoint[ii+1];
					SetLength(UM^.ArDDPoint,Length(UM^.ArDDPoint)-1);
					i-=1;
					ParentDelleted:=true;
					end;
			end;
		i+=1;
		end;
	Wnd^.UserMemory.ArLongint[5]:=-1;
	UM^.ArBoolean[11]:=true;
	end;
end;
procedure DeletePoligone(Wnd:PGlSanWnd);
var i,ii,iii,iiii,selected:longint;
	UM:^GlSanWndUserMemory;
begin
selected:=Wnd^.UserMemory.ArLongint[5];
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
if Wnd^.UserMemory.ArLongint[5]<>-1 then
	begin
	i:=Low(UM^.ArDDPoint);
		WHILE  i<=High(UM^.ArDDPoint) do
			begin
			iiii:=0;
			if (Length(UM^.ArDDPoint[i].ArLongint)=1) and (Length(UM^.ArDDPoint[i].ArGlSanKoor)=4) and (Length(UM^.ArDDPoint[i].ArDPoint)=3) then
				begin
				for iii:=low(UM^.ArArDPoint[Wnd^.UserMemory.ArLongint[5]]) to high(UM^.ArArDPoint[Wnd^.UserMemory.ArLongint[5]]) do
					begin
					if (UM^.ArArDPoint[selected,iii]=UM^.ArDDPoint[i].ArDPoint[0])or
					(UM^.ArArDPoint[selected,iii]=UM^.ArDDPoint[i].ArDPoint[1])or
					(UM^.ArArDPoint[selected,iii]=UM^.ArDDPoint[i].ArDPoint[2])then
						begin
						iiii+=1;
						end;
					end;
				if iiii=3 then
					begin
					UM^.ArDDPoint[i].Dispose;
					for iii:=i to High(UM^.ArDDPoint)-1 do
						UM^.ArDDPoint[iii]:=UM^.ArDDPoint[iii+1];
					SetLength(UM^.ArDDPoint,Length(UM^.ArDDPoint)-1);
					i-=1;
					end;
				end;
			i+=1;
			end;
	end;
	SetLength(UM^.ArArDPoint[Wnd^.UserMemory.ArLongint[5]],0);
	for ii:=Wnd^.UserMemory.ArLongint[5] to High(UM^.ArArDPoint)-1 do
		begin
		UM^.ArArDPoint[ii]:=UM^.ArArDPoint[ii+1];
		end;
	SetLength(UM^.ArArDPoint,Length(UM^.ArArDPoint)-1);
	Wnd^.UserMemory.ArLongint[5]:=-1;
	UM^.ArBoolean[11]:=true;
	end;

procedure GeneralProcDoska(Wnd:pointer);
label
	GoReOut1,GoReOut2;
var
	UM:^GlSanWndUserMemory;
	i,ii,iii,iiii:longint;
	CurKoor:GlSanKoor;
	C:GlSanColor4f;
	t:array[1..5] of GlSanKoor;
	r,r1:real;
	ArD:array [1..3] of DPoint;
begin
{$NOTE General Process Of Doska}
glDisable(gl_Lighting);
glDisable(gl_Line_smooth);
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
if GlSanGetReOut(@Wnd) then
	begin
	goto GoReOut1;
	end;
(*Сохранение в SSD буфер*)
if UM^.ArBoolean[Low(UM^.ArBoolean)+11] then
	SaveSDDToBuffer(Wnd);
(*Загрузка из буфера*)
if GlSanDownKey(17) and (GlSanReadKey=90) then
	begin
	if GlSanDownKey(16) then
		begin
		UM^.ArLongint[4]+=1;
		LoadFromBufferDoska(Wnd);
		end
	else
		begin 
		if UM^.ArLongint[4]>1 then UM^.ArLongint[4]-=1;
		LoadFromBufferDoska(Wnd);
		end;
	end;
if GlSanReadKey=9 then
	UM^.ArBoolean[1]:= not UM^.ArBoolean[1];
UM^.ArGlSanColor4f[11].ClearColor;
if (not GlSanMouseB(1)) and (not GlSanMouseB(3)) then UM^.ArBoolean[Low(UM^.ArBoolean)]:=false;
if GlSanMouseB(3) and UM^.ArBoolean[Low(UM^.ArBoolean)] then
	begin
	UM^.Rot1-=GlSanMouseXY(1).x/3;
	if (UM^.Rot2-GlSanMouseXY(1).y/3>-90)and(UM^.Rot2-GlSanMouseXY(1).y/3<90)then
		UM^.Rot2-=GlSanMouseXY(1).y/3;
	end;
if GlSanMouseB(1) and UM^.ArBoolean[Low(UM^.ArBoolean)] then
	begin
	UM^.UZ+=GlSanMouseXY(1).y/(170);
	UM^.LZ-=GlSanMouseXY(1).x/(170);
	end;
(* Перерасчёт сечений *){Parent-Child}
for i:=Low(UM^.ArDDPoint) to High(UM^.ArDDPoint) do
	begin
	if (Length(UM^.ArDDPoint[i].ArLongint)=1) and (Length(UM^.ArDDPoint[i].ArGlSanKoor)=3) and (Length(UM^.ArDDPoint[i].ArDPoint)=3) then
		begin
		{Sech}
		for ii:=Low(UM^.ArDDPoint[i].ArDPoint) to High(UM^.ArDDPoint[i].ArDPoint) do
			case UM^.ArDDPoint[i].ArDPoint[ii].ID of
			-2:t[ii+1]:=UM^.GlSanObj31.v[UM^.ArDDPoint[i].ArDPoint[ii].i];
			-1:t[ii+1]:=UM^.ArGlSanKoor[UM^.ArDDPoint[i].ArDPoint[ii].i];
			end;
		iii:=-1;
		for ii:=1 to 3 do
			if GlSanRast(t[ii],UM^.ArDDPoint[i].ArGlSanKoor[ii-1])>GlSanMin then
				iii:=0;
		if iii=0 then
			ReSech(Wnd,i);
		end
	else
		begin
		if (Length(UM^.ArDDPoint[i].ArLongint)=2) and (Length(UM^.ArDDPoint[i].ArGlSanKoor)=3) and (Length(UM^.ArDDPoint[i].ArDPoint)=0) then
			begin
			{Line}
			for iii:=1 to 2 do
				case UM^.ArDPoint[UM^.ArDDPoint[i].ArLongint[1],iii].ID of
				-2:t[iii]:=UM^.GlSanObj31.v[UM^.ArDPoint[UM^.ArDDPoint[i].ArLongint[1],iii].i];
				-1:t[iii]:=UM^.ArGlSanKoor[UM^.ArDPoint[UM^.ArDDPoint[i].ArLongint[1],iii].i];
				else t[iii]:=UM^.ArGlSanObj3[UM^.ArDPoint[UM^.ArDDPoint[i].ArLongint[1],iii].ID].
					v[UM^.ArDPoint[UM^.ArDDPoint[i].ArLongint[1],iii].i];
				end;
			iii:=-1;
			for ii:=1 to 2 do
				if GlSanRast(t[ii],UM^.ArDDPoint[i].ArGlSanKoor[ii])>GlSanMin then
					iii:=0;
			if iii=0 then
				begin
				r:=GlSanRast(UM^.ArDDPoint[i].ArGlSanKoor[1],UM^.ArDDPoint[i].ArGlSanKoor[0])/
					GlSanRast(UM^.ArDDPoint[i].ArGlSanKoor[1],UM^.ArDDPoint[i].ArGlSanKoor[2]);
				UM^.ArGlSanKoor[UM^.ArDDPoint[i].ArLongint[0]].Import(
				-r*(t[1].x-t[2].x)+t[1].x,-r*(t[1].y-t[2].y)+t[1].y,-r*(t[1].z-t[2].z)+t[1].z);
				UM^.ArDDPoint[i].ArGlSanKoor[0]:=UM^.ArGlSanKoor[UM^.ArDDPoint[i].ArLongint[0]];
				UM^.ArDDPoint[i].ArGlSanKoor[1]:=t[1];
				UM^.ArDDPoint[i].ArGlSanKoor[2]:=t[2];
				end;
			end
		else
			begin
			if (Length(UM^.ArDDPoint[i].ArLongint)=1) and (Length(UM^.ArDDPoint[i].ArGlSanKoor)=4) and (Length(UM^.ArDDPoint[i].ArDPoint)=3) then
				begin
				{Plygone}
				for iii:=1 to 3 do
					case UM^.ArDDPoint[i].ArDPoint[iii-1].ID of
					-2:t[iii]:=UM^.GlSanObj31.v[UM^.ArDDPoint[i].ArDPoint[iii-1].i];
					-1:t[iii]:=UM^.ArGlSanKoor[UM^.ArDDPoint[i].ArDPoint[iii-1].i];
					else t[iii]:=UM^.ArGlSanObj3[UM^.ArDDPoint[i].ArDPoint[iii-1].ID].v[UM^.ArDDPoint[i].ArDPoint[iii-1].i];
					end;
				iii:=-1;
				for ii:=1 to 3 do
					if GlSanRast(t[ii],UM^.ArDDPoint[i].ArGlSanKoor[ii])>GlSanMin then
						iii:=0;
				if iii=0 then
					begin
					t[4]:=GlSanGetPeresLines(UM^.ArDDPoint[i].ArGlSanKoor[1],UM^.ArDDPoint[i].ArGlSanKoor[2],
						UM^.ArDDPoint[i].ArGlSanKoor[3],UM^.ArDDPoint[i].ArGlSanKoor[0]);
					r:=GlSanGetOtn(t[4],UM^.ArDDPoint[i].ArGlSanKoor[1],UM^.ArDDPoint[i].ArGlSanKoor[2]);
					r1:=GlSanGetOtn(UM^.ArDDPoint[i].ArGlSanKoor[0],t[4],UM^.ArDDPoint[i].ArGlSanKoor[3]);
					t[5]:=GlSanGetKoor(t[1],t[2],r);{}
					UM^.ArGlSanKoor[UM^.ArDDPoint[i].ArLongint[0]]:=GlSanGetKoor(t[5],t[3],r1);
					UM^.ArDDPoint[i].ArGlSanKoor[0]:=UM^.ArGlSanKoor[UM^.ArDDPoint[i].ArLongint[0]];
					for iii:=1 to 3 do
						case UM^.ArDDPoint[i].ArDPoint[iii-1].ID of
						-2:UM^.ArDDPoint[i].ArGlSanKoor[iii]:=UM^.GlSanObj31.v[UM^.ArDDPoint[i].ArDPoint[iii-1].i];
						-1:UM^.ArDDPoint[i].ArGlSanKoor[iii]:=UM^.ArGlSanKoor[UM^.ArDDPoint[i].ArDPoint[iii-1].i];
						else UM^.ArDDPoint[i].ArGlSanKoor[iii]:=UM^.ArGlSanObj3[UM^.ArDDPoint[i].ArDPoint[iii-1].ID].v[UM^.ArDDPoint[i].ArDPoint[iii-1].i];
						end;
					end;
				end
			else
				begin
				
				end;
			end;
		end;
	end;
GoReOut1:
glloadidentity();
gltranslatef(UM^.LZ,UM^.UZ,-6+UM^.Zum);
glrotatef(UM^.Rot2,1,0,0);
glrotatef(UM^.Rot1,0,1,0);
if GlSanGetReOut(@Wnd) then
	begin
	goto GoReOut2;
	end;
{Перемещение пользовательской точки}
if UM^.ArLongint[3]<>-1 then
	begin
	if GlSanMouseB(1) then
		begin
		glcolor4f(0,0,0,1);
		if UM^.ArBoolean[1] then
			UM^.GlSanObj31.Init(GlSanKoorImport(0,0,0),1);
		glLineWidth (UM^.ArReal[4]);
		{Инициализация пользовательских линий}
		glBegin(GL_LINES);
		for i:=Low(UM^.ArDPoint) to High(UM^.ArDPoint) do
			if not 
			(((UM^.ArDPoint[i,1].ID=-1) and (UM^.ArDPoint[i,1].I=UM^.ArLongint[3])) or
			 ((UM^.ArDPoint[i,2].ID=-1) and (UM^.ArDPoint[i,2].I=UM^.ArLongint[3])))then
			for ii:=1 to 2 do
				case UM^.ArDPoint[i,ii].ID of
				-2:UM^.GlSanObj31.v[UM^.ArDPoint[i,ii].i].Vertex;
				-1:UM^.ArGlSanKoor[UM^.ArDPoint[i,ii].i].Vertex;
				else UM^.ArGlSanObj3[UM^.ArDPoint[i,ii].ID].v[UM^.ArDPoint[i,ii].i].Vertex;
				end;
		glEnd();
		{Инициализация пользовательских полигонов}
		for i:=Low(UM^.ArArDPoint) to High(UM^.ArArDPoint) do
			begin
			iii:=-1;
			for ii:=Low(UM^.ArArDPoint[i]) to High(UM^.ArArDPoint[i]) do
				if (UM^.ArArDPoint[i,ii].ID=-1) and (UM^.ArArDPoint[i,ii].I=UM^.ArLongint[3]) then
					iii:=0;
			if iii=-1 then
				begin
				GlBegin(GL_POLYGON);
				for ii:=Low(UM^.ArArDPoint[i]) to High(UM^.ArArDPoint[i]) do
					begin
					case UM^.ArArDPoint[i,ii].ID of
					-2:UM^.GlSanObj31.v[UM^.ArArDPoint[i,ii].i].Vertex;
					-1:UM^.ArGlSanKoor[UM^.ArArDPoint[i,ii].i].Vertex;
					else UM^.ArGlSanObj3[UM^.ArArDPoint[i,ii].ID].v[UM^.ArArDPoint[i,ii].i].Vertex;
					end;
					end;
				GlEnd();
				end;
			end;
		CurKoor:=GlSanReadMouseXYZ;
		if GlSanMXYZT(CurKoor) and (CurKoorInObj(Wnd,@CurKoor)) then
			begin
			{Опускаем перпендикуляр на линии объекта}
			ii:=-1;
			for i:=Low(UM^.ArArLongint) to High(UM^.ArArLongint) do
				if (ii=-1) and (Length(UM^.ArArLongint[i])=2) then
					begin
					t[1]:=GlSanGetPerpedKoor(UM^.GlSanObj31.v[UM^.ArArLongint[i,0]],UM^.GlSanObj31.v[UM^.ArArLongint[i,1]],CurKoor);
					if GlSanPrinOtr(UM^.GlSanObj31.v[UM^.ArArLongint[i,0]],UM^.GlSanObj31.v[UM^.ArArLongint[i,1]],t[1]) then
						begin
						if GlSanRast(t[1],CurKoor)<0.07 then
							begin
							ii:=0;
							CurKoor:=t[1];
							end;
						end;
					end;
			{Опускаем перпендикуляр на линии пользователя}
			if ii=-1 then
				begin
				for i:=Low(UM^.ArDPoint) to High(UM^.ArDPoint) do
					begin
					for iii:=1 to 2 do
						case UM^.ArDPoint[i,iii].ID of
						-2:t[iii]:=UM^.GlSanObj31.v[UM^.ArDPoint[i,iii].i];
						-1:t[iii]:=UM^.ArGlSanKoor[UM^.ArDPoint[i,iii].i];
						else t[iii]:=UM^.ArGlSanObj3[UM^.ArDPoint[i,iii].ID].v[UM^.ArDPoint[i,iii].i];
						end;
					t[3]:=GlSanGetPerpedKoor(t[1],t[2],CurKoor);
					if GlSanPrinOtr(t[1],t[2],t[3]) and (GlSanRast(t[3],CurKoor)<0.07)
					and (not ((UM^.ArDPoint[i,1].ID=-1) and (UM^.ArDPoint[i,1].I=UM^.ArLongint[3]))) 
					and (not ((UM^.ArDPoint[i,2].ID=-1) and (UM^.ArDPoint[i,2].I=UM^.ArLongint[3]))) then
						begin
						ii:=0;
						CurKoor:=t[3];
						end;
					end;
				end;
			UM^.ArGlSanKoor[UM^.ArLongint[3]]:=CurKoor;
			end;
		if UM^.ArBoolean[0]=true then
			UM^.ArBoolean[0]:=false;
		end
	else
		begin
		iiii:=-1;
		for i:=Low(UM^.ArDPoint) to High(UM^.ArDPoint) do
			begin
			for iii:=1 to 2 do
				case UM^.ArDPoint[i,iii].ID of
				-2:t[iii]:=UM^.GlSanObj31.v[UM^.ArDPoint[i,iii].i];
				-1:t[iii]:=UM^.ArGlSanKoor[UM^.ArDPoint[i,iii].i];
				else t[iii]:=UM^.ArGlSanObj3[UM^.ArDPoint[i,iii].ID].v[UM^.ArDPoint[i,iii].i];
				end;
			if GlSanPrinOtr(t[1],t[2],UM^.ArGlSanKoor[UM^.ArLongint[3]])
					and (not ((UM^.ArDPoint[i,1].ID=-1) and (UM^.ArDPoint[i,1].I=UM^.ArLongint[3]))) 
					and (not ((UM^.ArDPoint[i,2].ID=-1) and (UM^.ArDPoint[i,2].I=UM^.ArLongint[3]))) then
				begin
				iiii:=i;
				end;
			end;
		if iiii<>-1 then
			begin
			{Вхождение в п-ч линий}
			SetLength(UM^.ArDDPoint,Length(UM^.ArDDPoint)+1);
			SetLength(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor,3);
			SetLength(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArLongint,2);
			for iii:=1 to 2 do
				case UM^.ArDPoint[iiii,iii].ID of
				-2:UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor[Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor)+iii]:=
					UM^.GlSanObj31.v[UM^.ArDPoint[iiii,iii].i];
				-1:UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor[Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor)+iii]:=
					UM^.ArGlSanKoor[UM^.ArDPoint[iiii,iii].i];
				else UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor[Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor)+iii]:=
					UM^.ArGlSanObj3[UM^.ArDPoint[iiii,iii].ID].v[UM^.ArDPoint[iiii,iii].i];
				end;
			UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor[Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor)]:=
				UM^.ArGlSanKoor[UM^.ArLongint[3]];
			UM^.ArDDPoint[High(UM^.ArDDPoint)].ArLongint[Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArLongint)+0]:=UM^.ArLongint[3];
			UM^.ArDDPoint[High(UM^.ArDDPoint)].ArLongint[Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArLongint)+1]:=iiii;
			end
		else
			begin
			{Начало вхождения в п-ч полигонов}
			iii:=-1;
			iiii:=-1;
			i:=Low(UM^.ArArDPoint);
			while (i<=High(UM^.ArArDPoint)) and ((iii=-1)) do
				begin
				case UM^.ArArDPoint[i,0].ID of
				-2:t[1]:=UM^.GlSanObj31.v[UM^.ArArDPoint[i,0].i];
				-1:t[1]:=UM^.ArGlSanKoor[UM^.ArArDPoint[i,0].i];
				else t[1]:=UM^.ArGlSanObj3[UM^.ArArDPoint[i,0].ID].v[UM^.ArArDPoint[i,0].i];
				end;
				ii:=Low(UM^.ArArDPoint[i])+1;
				while (ii<High(UM^.ArArDPoint[i])) and ((iii=-1)) do
					begin
					case UM^.ArArDPoint[i,ii].ID of
					-2:t[2]:=UM^.GlSanObj31.v[UM^.ArArDPoint[i,ii].i];
					-1:t[2]:=UM^.ArGlSanKoor[UM^.ArArDPoint[i,ii].i];
					else t[2]:=UM^.ArGlSanObj3[UM^.ArArDPoint[i,ii].ID].v[UM^.ArArDPoint[i,ii].i];
					end;
					case UM^.ArArDPoint[i,ii+1].ID of
					-2:t[3]:=UM^.GlSanObj31.v[UM^.ArArDPoint[i,ii+1].i];
					-1:t[3]:=UM^.ArGlSanKoor[UM^.ArArDPoint[i,ii+1].i];
					else t[3]:=UM^.ArGlSanObj3[UM^.ArArDPoint[i,ii+1].ID].v[UM^.ArArDPoint[i,ii+1].i];
					end;
					if GlSanPrinTreug(t[1],t[2],t[3],UM^.ArGlSanKoor[UM^.ArLongint[3]]) then
						begin
						iii:=i;
						ArD[1]:=UM^.ArArDPoint[i,0];
						ArD[2]:=UM^.ArArDPoint[i,ii];
						ArD[3]:=UM^.ArArDPoint[i,ii+1];
						end;
					ii+=1;
					end;
				i+=1;
				end;
			if (iii<>-1) then
				begin
				{Мы проверяем, нет ли этой точки в полигоне, к которому мы хотим опустить этот п-ч}
				i:=-1;
				for ii:=Low(UM^.ArArDPoint[iii]) to high(UM^.ArArDPoint[iii]) do
					if (UM^.ArArDPoint[iii][ii].ID=-1) and (UM^.ArArDPoint[iii][ii].I=UM^.ArLongint[3]) then
						i:=0;
				if i=-1 then
					begin
					SetLength(UM^.ArDDPoint,Length(UM^.ArDDPoint)+1);
					UM^.ArDDPoint[High(UM^.ArDDPoint)].Dispose;
					SetLength(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArLongint,1);
					SetLength(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArDPoint,3);
					SetLength(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor,4);
					UM^.ArDDPoint[High(UM^.ArDDPoint)].ArLongint[Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArLongint)+0]:=UM^.ArLongint[3];
					UM^.ArDDPoint[High(UM^.ArDDPoint)].ArDPoint[Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArDPoint)+0]:=ArD[1];
					UM^.ArDDPoint[High(UM^.ArDDPoint)].ArDPoint[Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArDPoint)+1]:=ArD[2];
					UM^.ArDDPoint[High(UM^.ArDDPoint)].ArDPoint[Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArDPoint)+2]:=ArD[3];
					UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor[Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor)+0]:=
						UM^.ArGlSanKoor[UM^.ArLongint[3]];
					for i:=1 to 3 do
						case ArD[i].ID of
						-2:UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor[Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor)+i]:=UM^.GlSanObj31.v[ArD[i].i];
						-1:UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor[Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor)+i]:=UM^.ArGlSanKoor[ArD[i].i];
						else UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor[Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor)+i]:=UM^.ArGlSanObj3[ArD[i].ID].v[ArD[i].i];
						end;
					end;
				end;
			end;
		UM^.ArLongint[3]:=-1;
		UM^.ArBoolean[11]:=true;
		end;
	if UM^.ArLongint[3]<>-1 then
		begin
		glClear(GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT);
		glcolor4f(0,1,1,0.3);
		Sphere.Init(UM^.ArGlSanKoor[UM^.ArLongint[3]],UM^.ArReal[1]*1.1);
		GlSanSetReOut(@Wnd);
		end;
	end;
GoReOut2:
{Вывод точек объекта}
if UM^.ArBoolean[3] then
	begin
	UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)+2].SanSetColor;
	for i:=Low(UM^.glSanObj31.v) to High(UM^.glSanObj31.v) do
		case UM^.ArLongint[Low(UM^.ArLongint)+0] of
		1:GlSanSphere(UM^.glSanObj31.v[i],UM^.ArReal[Low(UM^.ArReal)+0]);
		2:Kub.Init(UM^.glSanObj31.v[i],UM^.ArReal[Low(UM^.ArReal)+0]);
		end;
	end;
{Вывод точек пользователя}
if UM^.ArBoolean[5] then
	begin
	UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)+4].Color;
	for i:=Low(UM^.ArGlSanKoor) to High(UM^.ArGlSanKoor) do
		case UM^.ArLongint[Low(UM^.ArLongint)+1] of
		1:GlSanSphere(UM^.ArGlSanKoor[i],UM^.ArReal[Low(UM^.ArReal)+1]);
		2:Kub.Init(UM^.ArGlSanKoor[i],UM^.ArReal[Low(UM^.ArReal)+1]);
		end;
	end;
{Вывод точек cечений}
if UM^.ArBoolean[7] then
	for i:=Low(UM^.ArGlSanObj3) to High(UM^.ArGlSanObj3) do
		begin
		UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)+6].Color;
		for ii:=Low(UM^.ArGlSanObj3[i].v) to High(UM^.ArGlSanObj3[i].v) do
			case UM^.ArLongint[Low(UM^.ArLongint)+2] of
			1:GlSanSphere(UM^.ArGlSanObj3[i].v[ii],UM^.ArReal[Low(UM^.ArReal)+2]);
			2:Kub.Init(UM^.ArGlSanObj3[i].v[ii],UM^.ArReal[Low(UM^.ArReal)+2]);
			end;
		end;
{Вывод огранки пользовательских полигонов}
if UM^.ArBoolean[6] then
	begin
	C:=UM^.ArGlSanColor4f[10];
	c.Zum(1.3);
	C.Color;
	glLineWidth (1.5);
	for i:=0 to High(UM^.ArArDPoint) do
		begin
		GlBegin(GL_LINE_LOOP);
		for ii:=0 to High(UM^.ArArDPoint[i]) do
			begin
			case UM^.ArArDPoint[i,ii].ID of
			-2:UM^.GlSanObj31.v[UM^.ArArDPoint[i,ii].i].Vertex;
			-1:UM^.ArGlSanKoor[UM^.ArArDPoint[i,ii].i].Vertex;
			else UM^.ArGlSanObj3[UM^.ArArDPoint[i,ii].ID].v[UM^.ArArDPoint[i,ii].i].Vertex;
			end;
			end;
		glEnd();
		end;
	end;
{Вывод линий сечений}
if UM^.ArBoolean[8] then
	begin
	UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)+7].Color;
	glLineWidth (UM^.ArReal[5]);
	glBegin(GL_LINES);
	for i:=Low(UM^.ArGlSanObj3) to High(UM^.ArGlSanObj3) do
		begin
		For ii:=Low(UM^.ArGlSanObj3[i].f)+1 to High(UM^.ArGlSanObj3[i].f) do
			if Length(UM^.ArGlSanObj3[i].f[ii])=2 then
				begin
				if UM^.ArGlSanObj3[i].f[ii][0]>High(UM^.ArGlSanObj3[i].v) then
					begin
					UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)+1].Color;
					UM^.GlSanObj31.v[UM^.ArGlSanObj3[i].f[ii][0]-High(UM^.ArGlSanObj3[i].v)-1].Vertex;
					UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)+7].Color;
					end
				else
					UM^.ArGlSanObj3[i].v[UM^.ArGlSanObj3[i].f[ii,0]].Vertex;
				UM^.ArGlSanObj3[i].v[UM^.ArGlSanObj3[i].f[ii,High(UM^.ArGlSanObj3[i].f[ii])]].Vertex;
				end;
		end;
	glEnd();
	end;
if UM^.ArBoolean[2] then
	begin
	UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)+1].SanSetColor;
	glLineWidth (UM^.ArReal[3]);
	glBegin(GL_LINES);
	for i:=Low(UM^.ArArLongint) to High(UM^.ArArLongint) do
		begin
		UM^.GlSanObj31.V[UM^.ArArLongint[i,Low(UM^.ArArLongint[i])]].Vertex;
		UM^.GlSanObj31.V[UM^.ArArLongint[i,High(UM^.ArArLongint[i])]].Vertex;
		end;
	glEnd();
	end;
{Инициализация пользовательских линий}
if UM^.ArBoolean[4] then
	begin
	UM^.ArGlSanColor4f[9].Color;
	if ((GlSanWndActive(@Wnd)) and (GlSanDownKey(17))) then glLineWidth (5) else glLineWidth (UM^.ArReal[4]);
	glBegin(GL_LINES);
	for i:=Low(UM^.ArDPoint) to High(UM^.ArDPoint) do
		for ii:=1 to 2 do
			case UM^.ArDPoint[i,ii].ID of
			-2:UM^.GlSanObj31.v[UM^.ArDPoint[i,ii].i].Vertex;
			-1:UM^.ArGlSanKoor[UM^.ArDPoint[i,ii].i].Vertex;
			else UM^.ArGlSanObj3[UM^.ArDPoint[i,ii].ID].v[UM^.ArDPoint[i,ii].i].Vertex;
			end;
	glEnd();
	end;
{Вывод полигона сечения}
if UM^.ArBoolean[9] then
	begin
	UM^.ArGlSanColor4f[8].Color;
	for i:=Low(UM^.ArGlSanObj3) to High(UM^.ArGlSanObj3) do
		begin
		glBegin(GL_POLYGON);
		for ii:=Low(UM^.ArGlSanObj3[i].f[Low(UM^.ArGlSanObj3[i].f)]) to High(UM^.ArGlSanObj3[i].f[Low(UM^.ArGlSanObj3[i].f)]) do
			begin
			UM^.ArGlSanObj3[i].v[UM^.ArGlSanObj3[i].f[Low(UM^.ArGlSanObj3[i].f)][ii]].Vertex;
			end;
		glEnd();
		end;
	end;
{Это вывод пользовательских полигонов}
if UM^.ArBoolean[6] then
	begin
	UM^.ArGlSanColor4f[10].Color;
	for i:=Low(UM^.ArArDPoint) to High(UM^.ArArDPoint) do
		begin
		GlBegin(GL_POLYGON);
		for ii:=Low(UM^.ArArDPoint[i]) to High(UM^.ArArDPoint[i]) do
			begin
			case UM^.ArArDPoint[i,ii].ID of
			-2:UM^.GlSanObj31.v[UM^.ArArDPoint[i,ii].i].Vertex;
			-1:UM^.ArGlSanKoor[UM^.ArArDPoint[i,ii].i].Vertex;
			else UM^.ArGlSanObj3[UM^.ArArDPoint[i,ii].ID].v[UM^.ArArDPoint[i,ii].i].Vertex;
			end;
			end;
		GlEnd();
		end;
	end;
{Вывод обьекта}
if UM^.ArBoolean[1] then
	begin
	UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)].SanSetColor;
	UM^.GlSanObj31.Init(GlSanKoorImport(0,0,0),1);
	end;
if GlSanGetReOut(@Wnd) then
	exit;
{Это вход в перетаскивания точки}
if ((GlSanMouseReadKey=1)) then
	begin
	ii:=-1;
	CurKoor:=GlSanReadMouseXYZ;
	for i:=0 to High(UM^.ArGlSanKoor) do
		if GlSanPrinCub(UM^.ArGlSanKoor[i],CurKoor,um^.ArReal[1]) then
			begin
			ii:=i;
			end;
	if ii<>-1 then
		BEGIN
		UM^.ArLongint[3]:=ii;
		{Удаление Parent-Child с этой точкой}
		i:=Low(UM^.ArDDPoint);
		WHILE  i<=High(UM^.ArDDPoint) do
			begin
			if (Length(UM^.ArDDPoint[i].ArLongint)=2) and (Length(UM^.ArDDPoint[i].ArGlSanKoor)=3) and (Length(UM^.ArDDPoint[i].ArDPoint)=0) then
				if UM^.ArDDPoint[i].ArLongint[0]=ii then
					begin
					UM^.ArDDPoint[i].Dispose;
					for iii:=i to High(UM^.ArDDPoint)-1 do
						UM^.ArDDPoint[iii]:=UM^.ArDDPoint[iii+1];
					SetLength(UM^.ArDDPoint,Length(UM^.ArDDPoint)-1);
					i-=1;
					end;
			i+=1;
			end;
		{Удаление п-ч с полигоном}
		i:=Low(UM^.ArDDPoint);
		WHILE  i<=High(UM^.ArDDPoint) do
			begin
			if (Length(UM^.ArDDPoint[i].ArLongint)=1) and (Length(UM^.ArDDPoint[i].ArGlSanKoor)=4) and (Length(UM^.ArDDPoint[i].ArDPoint)=3) then
				if UM^.ArDDPoint[i].ArLongint[0]=ii then
					begin
					UM^.ArDDPoint[i].Dispose;
					for iii:=i to High(UM^.ArDDPoint)-1 do
						UM^.ArDDPoint[iii]:=UM^.ArDDPoint[iii+1];
					SetLength(UM^.ArDDPoint,Length(UM^.ArDDPoint)-1);
					i-=1;
					end;
			i+=1;
			end;
		end;
	end;
{Начало интерфейса примитивов}
CurKoor:=GlSanReadMouseXYZ;
iii:=-1;
i:=Low(UM^.ArDPoint);
while (i<>High(UM^.ArDPoint)+1)and(iii=-1) do
	begin
	for ii:=1 to 2 do
		case UM^.ArDPoint[i,ii].ID of
		-2:t[ii]:=UM^.GlSanObj31.v[UM^.ArDPoint[i,ii].i];
		-1:t[ii]:=UM^.ArGlSanKoor[UM^.ArDPoint[i,ii].i];
		else t[ii]:=UM^.ArGlSanObj3[UM^.ArDPoint[i,ii].ID].v[UM^.ArDPoint[i,ii].i];
		end;
	if abs(abs(GlSanRast(t[1],t[2])-(GlSanRast(t[1],CurKoor)+GlSanRast(t[2],CurKoor))))<=GlSanMin then
		iii:=i;
	i+=1;
	end;
if iii<>-1 then
	begin
	glcolor4f(0.8,0.8,0.8,0.9);
	glLineWidth (9);
	GlSanLine(t[1],t[2]);
	if GlSanMouseReadKey=2 then
		begin
		UM^.ArLongint[5]:=iii;
		GlSanContextMenuBeginning(NewContext);
		GlSanContextMenuAddString(NewContext,'Удалить линию',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@DeleteLine);
		GlSanContextMenuAddString(NewContext,'Отмена',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@GlSanKillContext);
		GlSanContextMenuMake(NewContext,@Wnd,nil);
		end;
	end
else
	begin
	i:=Low(UM^.ArArDPoint);
	while (i<>High(UM^.ArArDPoint)+1) and (iii=-1) do
		begin
		case UM^.ArArDPoint[i,0].ID of
		-2:t[1]:=UM^.GlSanObj31.v[UM^.ArArDPoint[i,0].i];
		-1:t[1]:=UM^.ArGlSanKoor[UM^.ArArDPoint[i,0].i];
		else t[1]:=UM^.ArGlSanObj3[UM^.ArArDPoint[i,0].ID].v[UM^.ArArDPoint[i,0].i];
		end;
		ii:=Low(UM^.ArArDPoint[i])+1;
		while (ii<>High(UM^.ArArDPoint[i])) and (iii=-1) do
			begin
			case UM^.ArArDPoint[i,ii].ID of
			-2:t[2]:=UM^.GlSanObj31.v[UM^.ArArDPoint[i,ii].i];
			-1:t[2]:=UM^.ArGlSanKoor[UM^.ArArDPoint[i,ii].i];
			else t[2]:=UM^.ArGlSanObj3[UM^.ArArDPoint[i,ii].ID].v[UM^.ArArDPoint[i,ii].i];
			end;
			case UM^.ArArDPoint[i,ii+1].ID of
			-2:t[3]:=UM^.GlSanObj31.v[UM^.ArArDPoint[i,ii+1].i];
			-1:t[3]:=UM^.ArGlSanKoor[UM^.ArArDPoint[i,ii+1].i];
			else t[3]:=UM^.ArGlSanObj3[UM^.ArArDPoint[i,ii+1].ID].v[UM^.ArArDPoint[i,ii+1].i];
			end;
			if GlSanPrinTreug(t[1],t[2],t[3],CurKoor) then
				iii:=i;
			ii+=1;
			end;
		i+=1;
		end;
	if iii<>-1 then
		begin
		glcolor4f(0.6,0.6,0.6,0.6);
		GlBegin(GL_POLYGON);
		for ii:=Low(UM^.ArArDPoint[iii]) to High(UM^.ArArDPoint[iii]) do
			begin
			case UM^.ArArDPoint[iii,ii].ID of
			-2:UM^.GlSanObj31.v[UM^.ArArDPoint[iii,ii].i].Vertex;
			-1:UM^.ArGlSanKoor[UM^.ArArDPoint[iii,ii].i].Vertex;
			else UM^.ArGlSanObj3[UM^.ArArDPoint[iii,ii].ID].v[UM^.ArArDPoint[iii,ii].i].Vertex;
			end;
			end;
		GlEnd();
		glLineWidth (2);
		glcolor4f(0.9,0.9,0.9,0.9);
		GlBegin(GL_LINE_LOOP);
		for ii:=0 to High(UM^.ArArDPoint[iii]) do
			begin
			case UM^.ArArDPoint[iii,ii].ID of
			-2:UM^.GlSanObj31.v[UM^.ArArDPoint[iii,ii].i].Vertex;
			-1:UM^.ArGlSanKoor[UM^.ArArDPoint[iii,ii].i].Vertex;
			else UM^.ArGlSanObj3[UM^.ArArDPoint[iii,ii].ID].v[UM^.ArArDPoint[iii,ii].i].Vertex;
			end;
			end;
		glEnd();
		if GlSanMouseReadKey=2 then
			begin
			UM^.ArLongint[5]:=iii;
			GlSanContextMenuBeginning(NewContext);
			GlSanContextMenuAddString(NewContext,'Удалить поверхность',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@DeletePoligone);
			GlSanContextMenuAddString(NewContext,'Отмена',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@GlSanKillContext);
			GlSanContextMenuMake(NewContext,@Wnd,nil);
			end;
		end
	else
		begin
		
		end;
	end;
{Вход в поворот и\или перенос обьекта}
if ((GlSanMouseReadKey=1) or (GlSanMouseReadKey=3)) and (CurKoorInObj(Wnd,nil)) then
	begin
	UM^.ArBoolean[Low(UM^.ArBoolean)]:=true;
	end;
{Колёсико}
if (SGMouseWheel<>0) and ((CurKoorInObj(Wnd,nil))) then
	case SGMouseWheel of
	-1:if GlSanDownKey(16) then UM^.zum+=0.65 else UM^.zum+=0.2;
	1: if GlSanDownKey(16) then UM^.zum-=0.65 else UM^.zum-=00.2;
	end;
end;

procedure SetColorDoska(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	W:^GlSanWnd;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
W:=UM^.ArPointer[Low(UM^.ArPointer)];
case GlSanWndGetPositionFromComboBox(@Wnd,1) of
1:GlSanWndRunCOlorWnd4f(@w^.UserMemory.ArGlSanColor4f[Low(w^.UserMemory.ArGlSanColor4f)],'Обьекта',w);
2:GlSanWndRunCOlorWnd4f(@w^.UserMemory.ArGlSanColor4f[Low(w^.UserMemory.ArGlSanColor4f)+1],'Линий Обьекта',W);
3:GlSanWndRunCOlorWnd4f(@w^.UserMemory.ArGlSanColor4f[Low(w^.UserMemory.ArGlSanColor4f)+2],'Точек Обьекта',W);
4:GlSanWndRunCOlorWnd4f(@w^.UserMemory.ArGlSanColor4f[Low(w^.UserMemory.ArGlSanColor4f)+4],'Точек Пользователя',W);
5:GlSanWndRunCOlorWnd4f(@w^.UserMemory.ArGlSanColor4f[Low(w^.UserMemory.ArGlSanColor4f)+9],'Линий Пользователя',W);
6:GlSanWndRunCOlorWnd4f(@w^.UserMemory.ArGlSanColor4f[Low(w^.UserMemory.ArGlSanColor4f)+10],'Плоскостей Пользователя',W);
7:GlSanWndRunCOlorWnd4f(@w^.UserMemory.ArGlSanColor4f[Low(w^.UserMemory.ArGlSanColor4f)+6],'Точек Сечения',W);
8:GlSanWndRunCOlorWnd4f(@w^.UserMemory.ArGlSanColor4f[Low(w^.UserMemory.ArGlSanColor4f)+7],'Линий Сечения',W);
9:GlSanWndRunCOlorWnd4f(@w^.UserMemory.ArGlSanColor4f[Low(w^.UserMemory.ArGlSanColor4f)+8],'Плоскостей Сечения',W);
10:GlSanWndRunCOlorWnd4f(@w^.UserMemory.ArGlSanColor4f[Low(w^.UserMemory.ArGlSanColor4f)+11],'Фона',W);
end;
GlSanWndOldDependentWnd(@W,Wnd);
GlSanKillThisWindow(wnd);
end;
procedure DoskaOptionOfColorStart(Wnd:pointer);
begin
GlSanCreateWnd(@NewWnd,'Настройки Цветов',glSanKoor2fImport(200,150));
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(8,80),GlSanKoor2fImport(192,110),'Настроить',@SetColorDoska);
GlSanWndNewComboBox(@NewWnd,GlSanKoor2fImport(5,45),GlSanKoor2fImport(195,75));
GlSanWndNewStringInComboBox(@NewWnd,1,'Цвет Объекта');
GlSanWndNewStringInComboBox(@NewWnd,1,'Цвет Линий Объекта');
GlSanWndNewStringInComboBox(@NewWnd,1,'Цвет Точек Объекта');
GlSanWndNewStringInComboBox(@NewWnd,1,'Цвет Польз. Точек');
GlSanWndNewStringInComboBox(@NewWnd,1,'Цвет Польз. Линий');
GlSanWndNewStringInComboBox(@NewWnd,1,'Цвет Польз. Плоск.');
GlSanWndNewStringInComboBox(@NewWnd,1,'Цвет Точек Сечения');
GlSanWndNewStringInComboBox(@NewWnd,1,'Цвет Линий Сечения');
GlSanWndNewStringInComboBox(@NewWnd,1,'Цвет Плоск. Сечения');
GlSanWndNewStringInComboBox(@NewWnd,1,'Цвет Фона');
GlSanWndSetPositionOnComboBox(@NewWnd,1,1);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(108,115),GlSanKoor2fImport(192,145),'Отмена',@CanselWndDoska);
GlSanWndNewDependentWnd(@Wnd,NewWnd);
SetLength(NewWnd^.UserMemory.ArPointer,1);
NewWnd^.UserMemory.ArPointer[High(NewWnd^.UserMemory.ArPointer)]:=Wnd;
GlSanWndDispose(@NewWnd);
end;
procedure ProcOOGS(Wnd:pointer);
var
	UM,UM2:^GlSanWndUserMemory;
	W:^GlSanWnd;
	i:longint;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
W:=UM^.ArPointer[Low(UM^.ArPointer)];
UM:=GlSanWndGetPointerOfUserMemory(@W);
UM2:=GlSanWndGetPointerOfUserMemory(@Wnd);
for i:=1 to 9 do
	if GlSanWndGetCaptionFromCheckBox(@Wnd,i)<>UM^.ArBoolean[Low(UM^.ArBoolean)+i] then
		begin
		UM^.ArBoolean[Low(UM^.ArBoolean)+i]:=GlSanWndGetCaptionFromCheckBox(@Wnd,i);
		end;
if GlSanWndGetPositionFromComboBox(@Wnd,1)<>UM2^.ArLongint[0] then
	begin
	UM2^.ArLongint[0]:=GlSanWndGetPositionFromComboBox(@Wnd,1);
	case GlSanWndGetPositionFromComboBox(@Wnd,1) of
	1:GlSanWndSetPositionOnComboBox(@Wnd,2,UM^.ArLongint[0]);
	2:GlSanWndSetPositionOnComboBox(@Wnd,2,UM^.ArLongint[1]);
	3:GlSanWndSetPositionOnComboBox(@Wnd,2,UM^.ArLongint[2]);
	end;
	UM2^.ArLongint[1]:=GlSanWndGetPositionFromComboBox(@wnd,2);
	end;
if UM2^.ArLongint[1]<>GlSanWndGetPositionFromComboBox(@Wnd,2) then
	begin
	UM2^.ArLongint[1]:=GlSanWndGetPositionFromComboBox(@wnd,2);
	UM^.ArLongint[UM2^.ArLongint[0]-1]:=UM2^.ArLongint[1];
	end;
GlSanWndSetNewTittleText(@Wnd,3,GlSanStrReal(UM^.ArReal[GlSanWndGetPositionFromComboBox(@wnd,3)-1],4));
if GlSanWndGetPositionFromComboBox(@wnd,3) in [1..3] then
	begin
	if GlSanWndClickButton(@Wnd,1) then
		if UM^.ArReal[GlSanWndGetPositionFromComboBox(@wnd,3)-1]-0.002>0 then
			UM^.ArReal[GlSanWndGetPositionFromComboBox(@wnd,3)-1]-=0.002;
	if GlSanWndClickButton(@Wnd,2) then
		UM^.ArReal[GlSanWndGetPositionFromComboBox(@wnd,3)-1]+=0.002;
	end
else
	begin
	if GlSanWndClickButton(@Wnd,1) then
		if UM^.ArReal[GlSanWndGetPositionFromComboBox(@wnd,3)-1]-0.02>0 then
			UM^.ArReal[GlSanWndGetPositionFromComboBox(@wnd,3)-1]-=0.02;
	if GlSanWndClickButton(@Wnd,2) then
		UM^.ArReal[GlSanWndGetPositionFromComboBox(@wnd,3)-1]+=0.02;
	end;
end;
procedure DoskaOptionOfGraphStart(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	W:^GlSanWnd;
begin
W:=Wnd;
UM:=GlSanWndGetPointerOfUserMemory(@W);
GlSanCreateWnd(@NewWnd,'Настройки Оформления',glSanKoor2fImport(640,400));
GlSanWndSetProc(@NewWnd,@ProcOOGS);
GlSanWndNewComboBox(@NewWnd,GlSanKoor2fImport(25,45),GlSanKoor2fImport(345,75));
GlSanWndNewComboBox(@NewWnd,GlSanKoor2fImport(350,45),GlSanKoor2fImport(615,75));
GlSanWndNewStringInComboBox(@NewWnd,1,'Тип вывода точек Объекта');
GlSanWndNewStringInComboBox(@NewWnd,1,'Тип вывода точек Пользователя');
GlSanWndNewStringInComboBox(@NewWnd,1,'Тип вывода точек Сечений');
GlSanWndNewStringInComboBox(@NewWnd,2,'Сфера');
GlSanWndNewStringInComboBox(@NewWnd,2,'Куб');
GlSanWndSetPositionOnComboBox(@NewWnd,1,1);
GlSanWndSetPositionOnComboBox(@NewWnd,2,UM^.ArLongint[0]);
SetLength(NewWnd^.UserMemory.ArLongint,2);
NewWnd^.UserMemory.ArLongint[0]:=1;
NewWnd^.UserMemory.ArLongint[1]:=UM^.ArLongint[0];
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(30,80),GlSanKoor2fImport(210,110),'Настройки вывода.');
GlSanWndSetNewColorText(@NewWnd,1,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(1,1,1,1)));
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(380,80),GlSanKoor2fImport(500,110),'Размеры.');
GlSanWndSetNewColorText(@NewWnd,2,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(1,1,1,1)));
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(380,145),GlSanKoor2fImport(585,175),' ');
GlSanWndNewCheckBox(@NewWnd,GlSanKoor2fImport(25,115),GlSanKoor2fImport(50,140),UM^.ArBoolean[Low(UM^.ArBoolean)+1]);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(55,115),GlSanKoor2fImport(170,140),'Многогранник');
GlSanWndNewCheckBox(@NewWnd,GlSanKoor2fImport(25,145),GlSanKoor2fImport(50,175),UM^.ArBoolean[Low(UM^.ArBoolean)+2]);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(55,145),GlSanKoor2fImport(200,175),'Линии Многогранника');
GlSanWndNewCheckBox(@NewWnd,GlSanKoor2fImport(25,180),GlSanKoor2fImport(50,210),UM^.ArBoolean[Low(UM^.ArBoolean)+3]);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(55,180),GlSanKoor2fImport(200,210),'Точки Многогранника');
GlSanWndNewCheckBox(@NewWnd,GlSanKoor2fImport(25,245),GlSanKoor2fImport(50,270),UM^.ArBoolean[Low(UM^.ArBoolean)+4]);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(55,245),GlSanKoor2fImport(200,270),'Линии Пользователя');
GlSanWndNewCheckBox(@NewWnd,GlSanKoor2fImport(25,215),GlSanKoor2fImport(50,240),UM^.ArBoolean[Low(UM^.ArBoolean)+5]);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(55,215),GlSanKoor2fImport(200,240),'Точки Пользователя');
GlSanWndNewCheckBox(@NewWnd,GlSanKoor2fImport(25,275),GlSanKoor2fImport(50,300),UM^.ArBoolean[Low(UM^.ArBoolean)+6]);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(55,275),GlSanKoor2fImport(200,300),'Плоскости Пользователя');
GlSanWndNewCheckBox(@NewWnd,GlSanKoor2fImport(25,305),GlSanKoor2fImport(50,330),UM^.ArBoolean[Low(UM^.ArBoolean)+7]);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(55,305),GlSanKoor2fImport(200,330),'Точки Сечений');
GlSanWndNewCheckBox(@NewWnd,GlSanKoor2fImport(25,335),GlSanKoor2fImport(50,360),UM^.ArBoolean[Low(UM^.ArBoolean)+8]);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(55,335),GlSanKoor2fImport(200,360),'Линии Сечений');
GlSanWndNewCheckBox(@NewWnd,GlSanKoor2fImport(25,365),GlSanKoor2fImport(50,390),UM^.ArBoolean[Low(UM^.ArBoolean)+9]);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(55,365),GlSanKoor2fImport(200,390),'Плоскости Сечений');
GlSanWndNewComboBox(@NewWnd,GlSanKoor2fImport(350,115),GlSanKoor2fImport(615,140));
GlSanWndNewStringInComboBox(@NewWnd,3,'Точка Объекта');
GlSanWndNewStringInComboBox(@NewWnd,3,'Точка Пользователя');
GlSanWndNewStringInComboBox(@NewWnd,3,'Точка Cечения');
GlSanWndNewStringInComboBox(@NewWnd,3,'Линия Объекта');
GlSanWndNewStringInComboBox(@NewWnd,3,'Линия Пользователя');
GlSanWndNewStringInComboBox(@NewWnd,3,'Линия Cечения');
GlSanWndSetPositionOnComboBox(@NewWnd,3,1);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(350,145),GlSanKoor2fImport(375,175),'-');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(590,145),GlSanKoor2fImport(615,175),'+');
GlSanWndSetButtonOnClick(@NewWnd,1,true);
GlSanWndSetButtonOnClick(@NewWnd,2,true);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(565,445-85),GlSanKoor2fImport(635,475-85),'Закрыть',@CanselWndDoska);
GlSanWndSetLastButtonColor(@NewWnd,7,GlSanColor4fImport(1,1,0,0.3));
GlSanWndSetLastButtonColor(@NewWnd,8,GlSanColor4fImport(1,0,0,0.3));
GlSanWndOldDependentWnd(@W,Wnd);
GlSanWndNewDependentWnd(@W,NewWnd);
SetLength(NewWnd^.UserMemory.ArPointer,1);
NewWnd^.UserMemory.ArPointer[High(NewWnd^.UserMemory.ArPointer)]:=W;
GlSanWndDispose(@NewWnd);
end;
procedure ProcOptionOfBuffer(Wnd:pointer);
var
	sr:DOS.SearchRec;
	i,ii,iii,iiii:longint;
	f:file;
begin
if FPSMoment or (Wnd=nil) then
	begin
	i:=-1;
	DOS.findfirst('Buffer\SSD\*.ssd',$3F,sr);
	While (dos.DosError<>18) do
		begin
		ii:=-1;
		iii:=1;
		while ((sr.name[iii]<>'.') and (iii-1<Length(sr.name))) do
			begin
			if  not (sr.name[iii] in ['0','1','2','3','4','5','6','7','8','9']) then
				ii:=0;
			iii+=1;
			end;
		if ii=-1 then
			begin
			iiii:=GlSanVal(NameFile(sr.name));
			if iiii>i then
				i:=iiii;
			end;
		DOS.findnext(sr);
		end;
	FindClose(sr);
	if i<>-1 then
		GlSanWndSetNewTittleText(@Wnd,1,'Сохранений в нем - '+GlSanStr(i)+'.')
	else
		GlSanWndSetNewTittleText(@Wnd,1,'Сохранений в нем - '+GlSanStr(0)+'.');
	iiii:=0;
	for ii:=1 to i do
		begin
		assign(f,'Buffer\SSD\'+GlSanStr(ii)+'.ssd');
		reset(f);
		iiii+=FileSize(f);
		close(f);
		end;
	GlSanWndSetNewTittleText(@Wnd,2,'Занимаемая память - '+GlSanStr(iiii)+'байт.');
	if GlSanWndClickButton(@Wnd,2) then
		begin
		for ii:=1 to i do
			begin
			assign(f,'Buffer\SSD\'+GlSanStr(ii)+'.ssd');
			erase(f);
			end;
		end;
	end;
end;
procedure DoskaOptionOfBufferStart(Wnd:pointer);
var
	W:^GlSanWnd;
begin
GlSanCreateWnd(@NewWnd,'О Буфере',glSanKoor2fImport(200,150));
GlSanWndSetProc(@NewWnd,@ProcOptionOfBuffer);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(108,115),GlSanKoor2fImport(192,145),'Отмена',@CanselWndDoska);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(8,115),GlSanKoor2fImport(92,145),'Сбросить');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(8,45),GlSanKoor2fImport(192,75),'Сохранений в нем - 0');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(8,80),GlSanKoor2fImport(192,110),'Занимаемая память - 0');
W:=Wnd;
GlSanWndNewDependentWnd(@W,NewWnd);
SetLength(NewWnd^.UserMemory.ArPointer,1);
NewWnd^.UserMemory.ArPointer[High(NewWnd^.UserMemory.ArPointer)]:=W;
GlSanWndDispose(@NewWnd);
ProcOptionOfBuffer(nil);
end;

procedure GeneralProcNewPointDoska(Wnd:pointer);
var
	UM,UM2:^GlSanWndUserMemory;
	Koor:GlSanKoor;
	GW:^GlSanWnd;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
GW:=UM^.ArPointer[Low(UM^.ArPointer)];
UM2:=GlSanWndGetPointerOfUserMemory(@GW);
if GlSanWndClickButton(@wnd,2) then
	begin
	UM^.ArBoolean[Low(UM^.ArBoolean)]:=not UM^.ArBoolean[Low(UM^.ArBoolean)];
	end;
if {(GlSanWndClickButton(@wnd,1)or ((GlSanWndActive(@Wnd)) and (GlSanReadKey in [13,27]))) and} (UM^.ArBoolean[Low(UM^.ArBoolean)+1]) then
	begin
	SetLength(UM2^.ArGlSanKoor,Length(UM2^.ArGlSanKoor)+1);
	UM2^.ArGlSanKoor[High(UM2^.ArGlSanKoor)]:=UM^.ArGlSanKoor[Low(UM^.ArGlSanKoor)];
	GlSanWndOldDependentWnd(@GW,Wnd);
	CanselWndDoska(Wnd);
	UM2^.ArBoolean[11]:=true;
	exit;
	end;
if GlSanWndActive(@Wnd) then
	begin
	if UM^.ArBoolean[Low(UM^.ArBoolean)] then
		begin
		GlSanWndSetNewColorText(@Wnd,2,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(0,0.9,0,0.9)));
		GlSanWndSetNewTittleText(@Wnd,2,'Установка');
		GlSanWndSetNewTittleButton(@Wnd,2,'Отменить');
		Koor:=GlSanReadMouseXYZ;
		if GlSanMXYZT(Koor) and (CurKoorInObj(UM^.ArPointer[Low(UM^.ArPointer)],@Koor)) then
			begin
			GW^.UserMemory.ArGlSanColor4f[Low(GW^.UserMemory.ArGlSanColor4f)+3].Color;
			GlSanSphere(Koor,0.03);
			GlSanSphere(Koor,0.1);
			if GlSanMouseReadKey=1 then
				begin
				UM^.ArGlSanKoor[Low(UM^.ArGlSanKoor)]:=Koor;
				UM^.ArBoolean[Low(UM^.ArBoolean)+0]:=false;
				UM^.ArBoolean[Low(UM^.ArBoolean)+1]:=true;
				end;
			end;
		end
	else
		begin
		if UM^.ArBoolean[Low(UM^.ArBoolean)+1] then
			GlSanWndSetNewColorText(@Wnd,2,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(0.9,0.9,0.9,0.9)))
		else
			GlSanWndSetNewColorText(@Wnd,2,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(0.9,0.9,0,0.9)));
		GlSanWndSetNewTittleText(@Wnd,2,'Остановлен');
		GlSanWndSetNewTittleButton(@Wnd,2,'Установить');
		end;
	if UM^.ArBoolean[Low(UM^.ArBoolean)+1] then
		begin
		GlSanWndSetNewColorText(@Wnd,4,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(0,0.9,0,0.9)));
		GlSanWndSetNewTittleText(@Wnd,4,'Установлена');
		GW^.UserMemory.ArGlSanColor4f[Low(GW^.UserMemory.ArGlSanColor4f)+5].Color;
		GlSanSphere(UM^.ArGlSanKoor[Low(UM^.ArGlSanKoor)],0.03);
		GlSanSphere(UM^.ArGlSanKoor[Low(UM^.ArGlSanKoor)],0.1);
		end
	else
		begin
		GlSanWndSetNewColorText(@Wnd,4,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(0.9,0,0,0.9)));
		GlSanWndSetNewTittleText(@Wnd,4,'Не Установлена');
		end;
	end
else
	begin
	GlSanWndSetNewTittleButton(@Wnd,2,'-');
	if UM^.ArBoolean[Low(UM^.ArBoolean)] then
		begin
		GlSanWndSetNewColorText(@Wnd,2,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(0.9,0.9,0.9,0.9)));
		GlSanWndSetNewTittleText(@Wnd,2,'Ожидание');
		end
	else
		begin
		if UM^.ArBoolean[Low(UM^.ArBoolean)+1] then
			GlSanWndSetNewColorText(@Wnd,2,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(0.9,0.9,0.9,0.9)))
		else
			GlSanWndSetNewColorText(@Wnd,2,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(0.9,0.9,0,0.9)));
		GlSanWndSetNewTittleText(@Wnd,2,'Остановлен');
		end;
	if UM^.ArBoolean[Low(UM^.ArBoolean)+1] then
		begin
		GlSanWndSetNewColorText(@Wnd,4,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(0,0.9,0,0.9)));
		GlSanWndSetNewTittleText(@Wnd,4,'Установлена');
		end
	else
		begin
		GlSanWndSetNewColorText(@Wnd,4,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(0.9,0,0,0.9)));
		GlSanWndSetNewTittleText(@Wnd,4,'Не Установлена');
		end;
	end;
end;
procedure NewPointDoska(Wnd:pointer);
var
	W:^GlSanWnd;
begin
GlSanCreateWnd(@NewWnd,'Установка Точки',glSanKoor2fImport(200,300));
GlSanWndSetProc(@NewWnd,@GeneralProcNewPointDoska);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(8,45),GlSanKoor2fImport(192,65),'Статус Процесса:');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(8,70),GlSanKoor2fImport(192,90),'');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(8,95),GlSanKoor2fImport(192,115),'Статус Точки:');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(8,120),GlSanKoor2fImport(192,140),'');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(8,275),GlSanKoor2fImport(92,295),'Создать');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(8,250),GlSanKoor2fImport(92,270),'Установить');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(108,275),GlSanKoor2fImport(192,295),'Отмена',@CanselWndDoska);
GlSanWndSetLastButtonColor(@NewWnd,7,GlSanColor4fImport(1,1,0,0.3));
GlSanWndSetLastButtonColor(@NewWnd,8,GlSanColor4fImport(1,0,0,0.3));
GlSanWndUserMove(@NewWnd,3,GlSanKoor2fImport(ContextWidth-10,0));
W:=wnd;
GlSanWndNewDependentWnd(@W,NewWnd);
SetLength(NewWnd^.UserMemory.ArPointer,1);
NewWnd^.UserMemory.ArPointer[High(NewWnd^.UserMemory.ArPointer)]:=W;
SetLength(NewWnd^.UserMemory.ArGlSanKoor,1);
NewWnd^.UserMemory.ArGlSanKoor[Low(NewWnd^.UserMemory.ArGlSanKoor)].Import(0,0,0);				//Точка
SetLength(NewWnd^.UserMemory.ArBoolean,2);
NewWnd^.UserMemory.ArBoolean[Low(NewWnd^.UserMemory.ArBoolean)]:=true;							//Процесс
NewWnd^.UserMemory.ArBoolean[Low(NewWnd^.UserMemory.ArBoolean)+1]:=false;						//Точка
GlSanWndDispose(@NewWnd);
end;


procedure NewSech(Wnd:pointer);
var
	UM,um2:^GlSanWndUserMemory;
	Obj:^GlSanObj3;
	W:PGlSanWnd;
	i,ii:longint;
	T13:array [1..3] of GlSanKoor;
{$NOTE NewSech}
begin
UM2:=GlSanWndGetPointerOfUserMemory(@Wnd);
W:=UM2^.ArPointer[Low(UM2^.ArPointer)];
UM:=GlSanWndGetPointerOfUserMemory(@W);
for i:=Low(UM2^.ArDPoint)  to High(UM2^.ArDPoint) do
	case UM2^.ArDPoint[i,1].ID of
	-2:t13[i+1]:=UM^.GlSanObj31.v[UM2^.ArDPoint[i,1].i];
	-1:t13[i+1]:=UM^.ArGlSanKoor[UM2^.ArDPoint[i,1].i];
	else t13[i+1]:=UM^.ArGlSanObj3[UM2^.ArDPoint[i,1].ID].v[UM2^.ArDPoint[i,1].i];
	end;
Obj:=RNRGetSech(@W^.UserMemory.GlSanObj31,t13[1],t13[2],t13[3],w);
SetLength(UM^.ArGlSanObj3,Length(UM^.ArGlSanObj3)+1);
UM^.ArGlSanObj3[High(UM^.ArGlSanObj3)].Dispose;
SetLength(UM^.ArGlSanObj3[High(UM^.ArGlSanObj3)].v,Length(Obj^.v));
SetLength(UM^.ArGlSanObj3[High(UM^.ArGlSanObj3)].f,Length(Obj^.f));
for i:=Low(Obj^.f) to High(Obj^.f) DO
	SetLength(UM^.ArGlSanObj3[High(UM^.ArGlSanObj3)].f[i],Length(Obj^.f[i]));
for i:=Low(Obj^.v) to High(Obj^.v) do
	UM^.ArGlSanObj3[High(UM^.ArGlSanObj3)].v[i]:=Obj^.v[i];
for i:=Low(Obj^.f) to High(Obj^.f) do
	for ii:=Low(Obj^.f[i]) to High(Obj^.f[i]) do
		begin
		UM^.ArGlSanObj3[High(UM^.ArGlSanObj3)].f[i,ii]:=Obj^.f[i,ii];
		end;
SetLEngth(UM^.ArDDPoint,Length(UM^.ArDDPoint)+1);
UM^.ArDDPoint[High(UM^.ArDDPoint)].Dispose;
SetLength(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArDPoint,3);
SetLength(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArLongint,1);
SetLength(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor,3);
for i:=Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor) to High(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor) do
	UM^.ArDDPoint[High(UM^.ArDDPoint)].ArGlSanKoor[i]:=t13[i+1];
for i:=Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArDPoint) to High(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArDPoint) do
	UM^.ArDDPoint[High(UM^.ArDDPoint)].ArDPoint[i]:=UM2^.ArDPoint[i,1];
UM^.ArDDPoint[High(UM^.ArDDPoint)].ArLongint[Low(UM^.ArDDPoint[High(UM^.ArDDPoint)].ArLongint)]:=High(UM^.ArGlSanObj3);
Obj^.Dispose;
System.Dispose(Obj);
end;

procedure ProcRunSech(Wnd:pointer);
var UM,UM2:^GlSanWndUserMemory;
	w:^GlSanWnd;
	CurKoor:GlSanKoor;
	i,ii:longint;
{$NOTE ProcRunSech}
begin
UM2:=GlSanWndGetPointerOfUserMemory(@Wnd);
w:=UM2^.ArPointer[0];
UM:=GlSanWndGetPointerOfUserMemory(@W);
if GlSanWndActive(@Wnd) and (Length(UM2^.ArDPoint)<3) then
	begin
	CurKoor:=GlSanReadMouseXYZ;
	if GlSanMXYZT(CurKoor) and (length(UM2^.ArGlSanKoor)<3) then
		begin
		ii:=-1;
		for i:=0 to High(UM^.ArGlSanKoor) do
			if GlSanPrinCub(UM^.ArGlSanKoor[i],CurKoor,um^.ArReal[1])then
				ii:=i;
		if ii<>-1 then
			begin
			glcolor4f(0,1,1,0.4);
			GlSanSphere(UM^.ArGlSanKoor[ii],um^.ArReal[1]*2);
			if GlMouseReadKey=1 then
				begin
				SetLength(UM2^.ArDPoint,Length(UM2^.ArDPoint)+1);
				UM2^.ArDPoint[High(UM2^.ArDPoint)][1].ID:=-1;
				UM2^.ArDPoint[High(UM2^.ArDPoint)][1].I:=ii;
				RNRPlayAudio('SystemBeep');
				end;
			end
		else
			begin
			ii:=-1;
			for i:=0 to High(UM^.GlSanObj31.v) do
				if GlSanPrinCub(UM^.GlSanObj31.v[i],CurKoor,um^.ArReal[0])then
					ii:=i;
			if ii<>-1 then
				begin
				glcolor4f(0,1,1,0.4);
				GlSanSphere(UM^.GlSanObj31.v[ii],um^.ArReal[0]*2);
				if GlMouseReadKey=1 then
					begin
					SetLength(UM2^.ArDPoint,Length(UM2^.ArDPoint)+1);
					UM2^.ArDPoint[High(UM2^.ArDPoint)][1].ID:=-2;
					UM2^.ArDPoint[High(UM2^.ArDPoint)][1].I:=ii;
					RNRPlayAudio('SystemBeep');
					end;
				end;
			end;
		end;
	end;
if Length(UM2^.ArDPoint)>0 then
	begin
	glcolor4f(0,1,1,0.4);
	for i:=0 to high(UM2^.ArDPoint) do
		case UM2^.ArDPoint[i,1].ID of
		-2:Sphere.Init(UM^.GlSanObj31.v[UM2^.ArDPoint[i,1].i],UM^.ArReal[0]*2);
		-1:Sphere.Init(UM^.ArGlSanKoor[UM2^.ArDPoint[i,1].i],UM^.ArReal[1]*2);
		end;
	end;
if GlSanWndClickButton(@Wnd,3) then
	begin
	SetLength(UM2^.ArDPoint,0);
	CanselWndDoska(Wnd);
	exit;
	end;
if GlSanWndClickButton(@Wnd,1) then
	begin
	if length(UM2^.ArDPoint)=3 then
		begin
		NewSech(Wnd);
		CanselWndDoska(wnd);
		UM^.ArBoolean[11]:=true;
		end;
	end;
if GlSanWndClickButton(@Wnd,2) then
	begin
	UM^.ArBoolean[1]:=not UM^.ArBoolean[1];
	end;
end;

procedure RunSech(Wnd:pointer);
var
	w:^GlSanWnd;
begin
w:=wnd;
GlSanCreateWnd(@NewWnd,'Новое сечение',glSanKoor2fImport(200,113));
GlSanWndUserMove(@NewWnd,3,GlSanKoor2fImport(ContextWidth-10,0));
GlSanWndSetProc(@NewWnd,@ProcRunSech);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(3,45),GlSanKoor2fImport(197,75),'Создать');
GlSanWndButtonHintAdd(@NewWnd,1+0,'Проводит сечение через');
GlSanWndButtonHintAdd(@NewWnd,1+0,'выбранные точки');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(3,80),GlSanKoor2fImport(97,110),'Показ\Cкр');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(103,80),GlSanKoor2fImport(197,110),'Отмена',nil);
SetLength(NewWnd^.UserMemory.ArGlSanKoor,0);
SetLength(NewWnd^.UserMemory.ArPointer,1);
GlSanWndNewDependentWnd(@W,NewWnd);
NewWnd^.UserMemory.ArPointer[0]:=w;
GlSanWndDispose(@NewWnd);
end;

procedure ProcLineDoska(Wnd:pointer);
var
	UM,UM2:^GlSanWndUserMemory;
	w:^GlSanWnd;
	CurKoor:GlSanKoor;
	i,ii,iii,iiii:longint;
begin
UM2:=GlSanWndGetPointerOfUserMemory(@Wnd);
w:=UM2^.ArPointer[0];
UM:=GlSanWndGetPointerOfUserMemory(@W);
if GlSanWndActive(@Wnd) then
	begin
	CurKoor:=GlSanReadMouseXYZ;
	if GlSanMXYZT(CurKoor) then
		begin
		ii:=-1;
		for i:=0 to High(UM^.ArGlSanKoor) do
			if abs(GlSanRast(UM^.ArGlSanKoor[i],CurKoor)-um^.ArReal[1])<GlSanMin then
				ii:=i;
		if ii<>-1 then
			begin
			glcolor4f(0,1,1,0.4);
			GlSanSphere(UM^.ArGlSanKoor[ii],um^.ArReal[1]*2);
			if GlMouseReadKey=1 then
				begin
				Case Length(UM2^.ArDPoint) of
				0,2:begin
					SetLength(UM2^.ArDPoint,1);
					UM2^.ArDPoint[0,1].i:=ii;
					UM2^.ArDPoint[0,1].ID:=-1;
					end;
				1:	begin
					SetLength(UM2^.ArDPoint,2);
					UM2^.ArDPoint[1,1].i:=ii;
					UM2^.ArDPoint[1,1].ID:=-1;
					end;
				end;
				end;
			end
		else
			begin
			ii:=-1;
			for i:=0 to High(UM^.GlSanObj31.v) do
				if abs(GlSanRast(UM^.GlSanObj31.v[i],CurKoor)-um^.ArReal[0])<GlSanMin then
					ii:=i;
			if ii<>-1 then
				begin
				glcolor4f(0,1,1,0.4);
				GlSanSphere(UM^.GlSanObj31.v[ii],um^.ArReal[0]*2);
				if GlMouseReadKey=1 then
					begin
					Case Length(UM2^.ArDPoint) of
					0,2:begin
						SetLength(UM2^.ArDPoint,1);
						UM2^.ArDPoint[0,1].i:=ii;
						UM2^.ArDPoint[0,1].ID:=-2;
						end;
					1:	begin
						SetLength(UM2^.ArDPoint,2);
						UM2^.ArDPoint[1,1].i:=ii;
						UM2^.ArDPoint[1,1].ID:=-2;
						end;
					end;
					end;
				end
			else
				begin
				ii:=-1;
				for iii:=0 to high(UM^.ArGlSanObj3)do
					begin
					for i:=0 to High(UM^.ArGlSanObj3[iii].v) do
						if abs(GlSanRast(UM^.ArGlSanObj3[iii].v[i],CurKoor)-um^.ArReal[2])<GlSanMin then
							begin
							ii:=i;
							iiii:=iii;
							end;
					end;
				if ii<>-1 then
					begin
					glcolor4f(0,1,1,0.4);
					GlSanSphere(UM^.ArGlSanObj3[iiii].v[ii],um^.ArReal[2]*2);
					if GlMouseReadKey=1 then
						begin
						Case Length(UM2^.ArDPoint) of
						0,2:begin
							SetLength(UM2^.ArDPoint,1);
							UM2^.ArDPoint[0,1].i:=ii;
							UM2^.ArDPoint[0,1].ID:=iiii;
							end;
						1:	begin
							SetLength(UM2^.ArDPoint,2);
							UM2^.ArDPoint[1,1].i:=ii;
							UM2^.ArDPoint[1,1].ID:=iiii;
							end;
						end;
						end;
					end;
				end;
			end;
		end;
	end;
if Length(UM2^.ArDPoint)<>0 then
	begin
	GlColor4f(1,0,1,0.4);
	for i:=0 to high(UM2^.ArDPoint) do
		case UM2^.ArDPoint[i,1].ID of
		-2:GlSanSphere(UM^.GlSanObj31.v[UM2^.ArDPoint[i,1].I],um^.ArReal[0]*2);
		-1:GlSanSphere(UM^.ArGlSanKoor[UM2^.ArDPoint[i,1].I],um^.ArReal[1]*2);
		else
			GlSanSphere(UM^.ArGlSanObj3[UM2^.ArDPoint[i,1].ID].v[UM2^.ArDPoint[i,1].I],um^.ArReal[2]*2);
		end;
	end;
if Length(UM2^.ArDPoint)= 2 then
	begin
	GlColor4f(1,0,1,0.4);
	glBegin(GL_LINES);
	for i:=Low(UM2^.ArDPoint) to High(UM2^.ArDPoint) do
			case UM2^.ArDPoint[i,1].ID of
			-2:UM^.GlSanObj31.v[UM2^.ArDPoint[i,1].i].Vertex;
			-1:UM^.ArGlSanKoor[UM2^.ArDPoint[i,1].i].Vertex;
			else UM^.ArGlSanObj3[UM2^.ArDPoint[i,1].ID].v[UM2^.ArDPoint[i,1].i].Vertex;
			end;
	glEnd();
	end;
if GlSanWndClickButton(@Wnd,1) and (Length(UM2^.ArDPoint)=2) then
	begin
	SetLength(UM^.ArDPoint,Length(UM^.ArDPoint)+1);
	UM^.ArDPoint[high(UM^.ArDPoint),1]:=UM2^.ArDPoint[0,1];
	UM^.ArDPoint[high(UM^.ArDPoint),2]:=UM2^.ArDPoint[1,1];
	GlSanKillWnd(@wnd);
	UM^.ArBoolean[1]:=true;
	UM^.ArBoolean[11]:=true;
	end;
if GlSanWndClickButton(@Wnd,2) then
	begin
	UM^.ArBoolean[1]:=not UM^.ArBoolean[1];
	end;
if GlSanWndClickButton(@Wnd,3) then
	begin
	UM^.ArBoolean[1]:=not UM^.ArBoolean[1];
	CanselWndDoska(Wnd);
	exit;
	end;
end;

procedure NewLineDoska(Wnd:pointer);
var
	W:^GlSanWnd;
begin
GlSanCreateWnd(@NewWnd,'Новая Линия',glSanKoor2fImport(200,113));
GlSanWndSetProc(@NewWnd,@ProcLineDoska);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(3,45),GlSanKoor2fImport(197,75),'Создать');
GlSanWndButtonHintAdd(@NewWnd,1+0,'Проводит линию между');
GlSanWndButtonHintAdd(@NewWnd,1+0,'выбранными точками');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(3,80),GlSanKoor2fImport(97,110),'Показ\Cкр');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(103,80),GlSanKoor2fImport(197,110),'Отмена',nil);
GlSanWndSetLastButtonColor(@NewWnd,7,GlSanColor4fImport(1,1,0,0.3));
GlSanWndSetLastButtonColor(@NewWnd,8,GlSanColor4fImport(1,0,0,0.3));
GlSanWndUserMove(@NewWnd,3,GlSanKoor2fImport(-10+ContextWidth,0));
SetLength(NewWnd^.UserMemory.ArPointer,1);
w:=wnd;
GlSanWndNewDependentWnd(@W,NewWnd);
NewWnd^.UserMemory.ArPointer[0]:=w;
GlSanWndDispose(@NewWnd);
w^.UserMemory.ArBoolean[1]:=false;
end;

procedure ProcPolygoneDoska(Wnd:pointer);
var
	UM,UM2:^GlSanWndUserMemory;
	w:^GlSanWnd;
	CurKoor:GlSanKoor;
	i,ii,iii,iiii:longint;
begin
UM2:=GlSanWndGetPointerOfUserMemory(@Wnd);
w:=UM2^.ArPointer[0];
UM:=GlSanWndGetPointerOfUserMemory(@W);
if GlSanWndActive(@Wnd) then
	begin
	CurKoor:=GlSanReadMouseXYZ;
	if GlSanMXYZT(CurKoor) then
		begin
		ii:=-1;
		for i:=0 to High(UM^.ArGlSanKoor) do
			if GlSanPrinCub(UM^.ArGlSanKoor[i],CurKoor,um^.ArReal[1])then
				ii:=i;
		if ii<>-1 then
			begin
			glcolor4f(0,1,1,0.4);
			GlSanSphere(UM^.ArGlSanKoor[ii],um^.ArReal[1]*2);
			if GlMouseReadKey=1 then
				begin
				SetLength(UM2^.ArArDPoint[0],Length(UM2^.ArArDPoint[0])+1);
				UM2^.ArArDPoint[0,high(UM2^.ArArDPoint[0])].i:=ii;
				UM2^.ArArDPoint[0,high(UM2^.ArArDPoint[0])].ID:=-1;
				end;
			end
		else
			begin
			ii:=-1;
			for i:=0 to High(UM^.GlSanObj31.v) do
				if GlSanPrinCub(UM^.GlSanObj31.v[i],CurKoor,um^.ArReal[0])then
					ii:=i;
			if ii<>-1 then
				begin
				glcolor4f(0,1,1,0.4);
				GlSanSphere(UM^.GlSanObj31.v[ii],um^.ArReal[0]*2);
				if GlMouseReadKey=1 then
					begin
					SetLength(UM2^.ArArDPoint[0],Length(UM2^.ArArDPoint[0])+1);
					UM2^.ArArDPoint[0,high(UM2^.ArArDPoint[0])].i:=ii;
					UM2^.ArArDPoint[0,high(UM2^.ArArDPoint[0])].ID:=-2;
					end;
				end
			else
				begin
				ii:=-1;
				for iii:=0 to high(UM^.ArGlSanObj3)do
					begin
					for i:=0 to High(UM^.ArGlSanObj3[iii].v) do
						if GlSanPrinCub(UM^.ArGlSanObj3[iii].v[i],CurKoor,um^.ArReal[2])then
							begin
							ii:=i;
							iiii:=iii;
							end;
					end;
				if ii<>-1 then
					begin
					glcolor4f(0,1,1,0.4);
					GlSanSphere(UM^.ArGlSanObj3[iiii].v[ii],um^.ArReal[2]*2);
					if GlMouseReadKey=1 then
						begin
						SetLength(UM2^.ArArDPoint[0],Length(UM2^.ArArDPoint[0])+1);
						UM2^.ArArDPoint[0,high(UM2^.ArArDPoint[0])].i:=ii;
						UM2^.ArArDPoint[0,high(UM2^.ArArDPoint[0])].ID:=iiii;
						end;
					end;
				end;
			end;
		end;
	end;
if Length(UM2^.ArArDPoint[0])<>0 then
	begin
	GlColor4f(1,0,1,0.4);
	for i:=0 to high(UM2^.ArArDPoint[0]) do
		case UM2^.ArArDPoint[0,i].ID of
		-2:GlSanSphere(UM^.GlSanObj31.v[UM2^.ArArDPoint[0,i].I],um^.ArReal[0]*2);
		-1:GlSanSphere(UM^.ArGlSanKoor[UM2^.ArArDPoint[0,i].I],um^.ArReal[1]*2);
		else
			GlSanSphere(UM^.ArGlSanObj3[UM2^.ArArDPoint[0,i].ID].v[UM2^.ArArDPoint[0,i].I],um^.ArReal[2]*2);
		end;
	end;
if Length(UM2^.ArArDPoint[0])>2 then
	begin
	GlColor4f(1,0,1,0.4);
	glBegin(GL_POLYGON);
	for i:=Low(UM2^.ArArDPoint[0]) to High(UM2^.ArArDPoint[0]) do
			case UM2^.ArArDPoint[0,i].ID of
			-2:UM^.GlSanObj31.v[UM2^.ArArDPoint[0,i].i].Vertex;
			-1:UM^.ArGlSanKoor[UM2^.ArArDPoint[0,i].i].Vertex;
			else UM^.ArGlSanObj3[UM2^.ArArDPoint[0,i].ID].v[UM2^.ArArDPoint[0,i].i].Vertex;
			end;
	glEnd();
	end;
if GlSanWndClickButton(@Wnd,1) and (Length(UM2^.ArArDPoint[0])>2) then
	begin
	SetLength(UM^.ArArDPoint,Length(UM^.ArArDPoint)+1);
	SetLength(UM^.ArArDPoint[High(UM^.ArArDPoint)],Length(UM2^.ArArDPoint[0]));
	for i:=0 to High(UM2^.ArArDPoint[0]) do
		begin
		UM^.ArArDPoint[high(UM^.ArArDPoint),i]:=UM2^.ArArDPoint[0,i];
		end;
	UM^.ArBoolean[1]:=true;
	UM^.ArBoolean[11]:=true;
	GlSanKillThisWindow(Wnd);
	exit;
	end;
if GlSanWndClickButton(@Wnd,2) then
	begin
	UM^.ArBoolean[1]:=not UM^.ArBoolean[1];
	end;
if GlSanWndClickButton(@Wnd,3) then
	begin
	UM^.ArBoolean[1]:=not UM^.ArBoolean[1];
	CanselWndDoska(Wnd);
	exit;
	end;
GlSanWndSetNewTittleText(@Wnd,1,'Выбрано точек '+GlSanStr(Length(UM2^.ArArDPoint[0])));
end;

procedure NewPolygoneDoska(Wnd:pointer);
var
	W:^GlSanWnd;
begin
GlSanCreateWnd(@NewWnd,'Новый Полигон',glSanKoor2fImport(200,140));
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(8,113),GlSanKoor2fImport(192,137),'');
GlSanWndSetProc(@NewWnd,@ProcPolygoneDoska);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(3,45),GlSanKoor2fImport(197,75),'Создать');
GlSanWndButtonHintAdd(@NewWnd,1+0,'Проводит многоугольник ограниченный');
GlSanWndButtonHintAdd(@NewWnd,1+0,'выбранными точками');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(3,80),GlSanKoor2fImport(97,110),'Показ\Cкр');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(103,80),GlSanKoor2fImport(197,110),'Отмена',nil);
GlSanWndSetLastButtonColor(@NewWnd,7,GlSanColor4fImport(1,1,0,0.3));
GlSanWndSetLastButtonColor(@NewWnd,8,GlSanColor4fImport(1,0,0,0.3));
GlSanWndUserMove(@NewWnd,3,GlSanKoor2fImport(ContextWidth-10,0));
SetLength(NewWnd^.UserMemory.ArPointer,1);
SetLength(NewWnd^.UserMemory.ArArDPoint,1);
w:=Wnd;
GlSanWndNewDependentWnd(@W,NewWnd);
NewWnd^.UserMemory.ArPointer[0]:=w;
GlSanWndDispose(@NewWnd);
w^.UserMemory.ArBoolean[1]:=false;
end;

procedure LoadFileDoska(Wnd:pointer);
var
	A:array of string;
begin
SetLength(a,2);
a[Low(a)+0]:='ssd';
a[Low(a)+1]:='off';
GlSanWndRunLoadFile('Обьекта',@LoadFileDoska2,Wnd,@a);
SetLength(a,0);
end;
procedure SeveProcDoska(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	GW:^GlSanWnd;
	St:string;
	b:boolean = false;
	i:Longint;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
GW:=UM^.ArPointer[Low(UM^.ArPointer)];
St:=GlSanWndGetCaptionFromEdit(@Wnd,1);
for i:=1 to Length(St) do
	if St[i] in ['р'..'ё','А'..'п'] then b:=true;
if b=false then
	begin
	SaveSSD(GW,st+'.ssd');
	GlSanWndOldDependentWnd(@GW,Wnd);
	GlSanKillWnd(@Wnd);
	GlSanCreateOKWnd(GW,'Сохранено','Cохранение прошло успешно!');
	end
else
	begin
	GlSanCreateOKWnd(GW,'Читайте внимательней!','Пока что нельзя использовать Русские буквы');
	end;
end;
procedure SaveToFileDoska(Wnd:pointer);
begin
GlSanCreateWnd(@NewWnd,'Сохранение Обьекта',glSanKoor2fImport(480,225));
SetLength(NewWnd^.UserMemory.ArPointer,1);
NewWnd^.UserMemory.ArPointer[Low(NewWnd^.UserMemory.ArPointer)]:=Wnd;
GlSanWndNewDependentWnd(@Wnd,NewWnd);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(5,45),GlSanKoor2fImport(475,65),'Введите имя файла английскими буквами:');
GlSanWndNewEdit(@NewWnd,GlSanKoor2fImport(5,70),GlSanKoor2fImport(475,100),'Lost');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(5,105),GlSanKoor2fImport(475,125),'Файл будет сохранен в папке с программой.');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(5,130),GlSanKoor2fImport(475,150),'Будушее расширение файла: "*.ssd".');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(155,190),GlSanKoor2fImport(315,220),'Отмена',@CanselWndDoska);
GlSanWndSetLastButtonColor(@NewWnd,7,GlSanColor4fImport(1,1,0,0.3));
GlSanWndSetLastButtonColor(@NewWnd,8,GlSanColor4fImport(1,0,0,0.3));
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(155,155),GlSanKoor2fImport(315,185),'Сохранить',@SeveProcDoska);
GlSanWndDispose(@NewWnd);
end;

procedure NavigationProc(Wnd:pointer);
var UM:^GlSanWndUserMemory;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
UM:=GlSanWndGetPointerOfUserMemory(@UM^.ArPointer[Low(UM^.ArPointer)]);
if GlSanWndClickButton(@Wnd,1) then
	if UM^.Rot2<90 then
		UM^.Rot2+=1.5;
if GlSanWndClickButton(@Wnd,3) then
	UM^.Rot1-=1.5;
if GlSanWndClickButton(@Wnd,2) then
	UM^.Rot1+=1.5;
if GlSanWndClickButton(@Wnd,4) then
	if UM^.Rot2>-90 then
		UM^.Rot2-=1.5;
if GlSanWndClickButton(@Wnd,5) then
	UM^.Zum+=0.1;
if GlSanWndClickButton(@Wnd,6) then
	UM^.Zum-=0.1;
end;

procedure NavigationFigure(Wnd:pointer);
begin
GlSanCreateWnd(@NewWnd,'Навигация',glSanKoor2fImport(430,90));
GlSanWndSetProc(@NewWnd,@NavigationProc);
GlSanWndNewDependentWnd(@Wnd,NewWnd);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(90,45),GlSanKoor2fImport(170,63),'Вверх');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(5,45),GlSanKoor2fImport(85,85),'Влево');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(175,45),GlSanKoor2fImport(255,85),'Вправо');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(90,67),GlSanKoor2fImport(170,85),'Вниз');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(260,45),GlSanKoor2fImport(340,63),'Зум +');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(260,67),GlSanKoor2fImport(340,85),'Зум -');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(345,45),GlSanKoor2fImport(425,85),'Закрыть',@CanselWndDoska);
GlSanWndSetLastButtonColor(@NewWnd,7,GlSanColor4fImport(1,1,0,0.3));
GlSanWndSetLastButtonColor(@NewWnd,8,GlSanColor4fImport(1,0,0,0.3));
GlSanWndSetButtonOnClick(@NewWnd,1,true);
GlSanWndSetButtonOnClick(@NewWnd,2,true);
GlSanWndSetButtonOnClick(@NewWnd,3,true);
GlSanWndSetButtonOnClick(@NewWnd,4,true);
GlSanWndSetButtonOnClick(@NewWnd,5,true);
GlSanWndSetButtonOnClick(@NewWnd,6,true);
GlSanWndUserMove(@NewWnd,3,GlSanKoor2fImport(0,ContextHeight-10));
SetLength(NewWnd^.UserMemory.ArPointer,1);
NewWnd^.UserMemory.ArPointer[High(NewWnd^.UserMemory.ArPointer)]:=Wnd;
GlSanWndDispose(@NewWnd);
end;

procedure InitBufferDoska(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	sr:DOS.SearchRec;
	i,ii,iii,iiii:longint;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
i:=-1;
DOS.findfirst('*.*',$3F,sr);
While (dos.DosError<>18) and (i=-1) do
	begin
	if sr.Name='Buffer' then
		i:=0;
	DOS.findnext(sr);
	end;
if i=-1 then
	MKDIR('Buffer');
i:=-1;
DOS.findfirst('Buffer\*.*',$3F,sr);
While (dos.DosError<>18) and (i=-1) do
	begin
	if sr.Name='SSD' then
		i:=0;
	DOS.findnext(sr);
	end;
if i=-1 then
	MKDIR('Buffer\SSD');
i:=-1;
DOS.findfirst('Buffer\SSD\*.ssd',$3F,sr);
While (dos.DosError<>18) do
	begin
	ii:=-1;
	iii:=1;
	while ((sr.name[iii]<>'.') and (iii-1<Length(sr.name))) do
		begin
		if  not (sr.name[iii] in ['0','1','2','3','4','5','6','7','8','9']) then
			ii:=0;
		iii+=1;
		end;
	if ii=-1 then
		begin
		iiii:=GlSanVal(NameFile(sr.name));
		if iiii>i then
			i:=iiii;
		end;
	DOS.findnext(sr);
	end;
if i=-1 then
	UM^.ArLongint[4]:=1
else
	UM^.ArLongint[4]:=i+1;
end;

function InitContextMenuImportFigure(W:PGlSanWnd):pointer;
begin
GlSanContextMenuBeginning(NewContext);
GlSanContextMenuAddString(NewContext,'Тетраэдр',GL_SAN_CONTEXT_ENABLED_PROCEDURE,							@ImportTetraedr);
GlSanContextMenuAddString(NewContext,'Гексаэдр (Куб)',GL_SAN_CONTEXT_ENABLED_PROCEDURE,								@ImportCube);
GlSanContextMenuAddString(NewContext,'Октаэдр',GL_SAN_CONTEXT_ENABLED_PROCEDURE,							@ImportOktaedr);
GlSanContextMenuAddString(NewContext,'Додекаэдр',GL_SAN_CONTEXT_ENABLED_PROCEDURE,							@ImportDadekaedr);
GlSanContextMenuAddString(NewContext,'Икосаэдр',GL_SAN_CONTEXT_ENABLED_PROCEDURE,							@ImportIkosaedr);
GlSanContextMenuAddString(NewContext,'Четырехугольная пирамида',GL_SAN_CONTEXT_ENABLED_PROCEDURE,			@ImportPyram);
GlSanContextMenuAddString(NewContext,'Параллелепипед',GL_SAN_CONTEXT_ENABLED_PROCEDURE,						@ImportParalilepiped);
GlSanContextMenuAddString(NewContext,'Треугольная прямая призма',GL_SAN_CONTEXT_ENABLED_PROCEDURE,			@ImportTruePrizma3);
GlSanContextMenuAddString(NewContext,'Шестиугольная прямая призма',GL_SAN_CONTEXT_ENABLED_PROCEDURE,		@ImportTruePrizma6);
GlSanContextMenuAddString(NewContext,'Четырехугольная призма общего вида',GL_SAN_CONTEXT_ENABLED_PROCEDURE,	@ImportFalseParalilepiped4);
GlSanContextMenuIntoMake(NewContext,@w,nil,InitContextMenuImportFigure);
end;

procedure SetColorPolyhedron(Wnd:PGlSanWnd);
begin
GlSanWndRunCOlorWnd4f(@Wnd^.UserMemory.ArGlSanColor4f[Low(Wnd^.UserMemory.ArGlSanColor4f)],'Многогранника',Wnd);
end;

procedure SetColorPolyhedronPoints(Wnd:PGlSanWnd);
begin
GlSanWndRunCOlorWnd4f(@Wnd^.UserMemory.ArGlSanColor4f[Low(Wnd^.UserMemory.ArGlSanColor4f)+2],'Точек многогранника',Wnd);
end;

procedure SetColorPolyhedronLines(Wnd:PGlSanWnd);
begin
GlSanWndRunCOlorWnd4f(@Wnd^.UserMemory.ArGlSanColor4f[Low(Wnd^.UserMemory.ArGlSanColor4f)+1],'Ребер многогранника',Wnd);
end;

procedure SetColorPoints(Wnd:PGlSanWnd);
begin
GlSanWndRunCOlorWnd4f(@Wnd^.UserMemory.ArGlSanColor4f[Low(Wnd^.UserMemory.ArGlSanColor4f)+4],'Произвольных точек',Wnd);
end;

procedure SetColorLines(Wnd:PGlSanWnd);
begin
GlSanWndRunCOlorWnd4f(@Wnd^.UserMemory.ArGlSanColor4f[Low(Wnd^.UserMemory.ArGlSanColor4f)+9],'Произвольных отрезков',Wnd);
end;

procedure SetColorPolygones(Wnd:PGlSanWnd);
begin
GlSanWndRunCOlorWnd4f(@Wnd^.UserMemory.ArGlSanColor4f[Low(Wnd^.UserMemory.ArGlSanColor4f)+10],'Произвольных поверхностей',Wnd);
end;

procedure SetColorCut(Wnd:PGlSanWnd);
begin
GlSanWndRunCOlorWnd4f(@Wnd^.UserMemory.ArGlSanColor4f[Low(Wnd^.UserMemory.ArGlSanColor4f)+8],'Сечения',Wnd);
end;
procedure SetColorCutPoints(Wnd:PGlSanWnd);
begin
GlSanWndRunCOlorWnd4f(@Wnd^.UserMemory.ArGlSanColor4f[Low(Wnd^.UserMemory.ArGlSanColor4f)+6],'Опорных точек сечения',Wnd);
end;
procedure SetColorCutLines(Wnd:PGlSanWnd);
begin
GlSanWndRunCOlorWnd4f(@Wnd^.UserMemory.ArGlSanColor4f[Low(Wnd^.UserMemory.ArGlSanColor4f)+7],'Линий сечения',Wnd);
end;
procedure SetColorBackground(Wnd:PGlSanWnd);
begin
GlSanWndRunCOlorWnd4f(@Wnd^.UserMemory.ArGlSanColor4f[Low(Wnd^.UserMemory.ArGlSanColor4f)+11],'Фона',Wnd);
end;

function InitContextMenuOptionsColor(W:PGlSanWnd):pointer;
begin
GlSanContextMenuBeginning(NewContext);
GlSanContextMenuAddString(NewContext,'Многогранник'				,GL_SAN_CONTEXT_ENABLED_PROCEDURE,@SetColorPolyhedron);
GlSanContextMenuAddString(NewContext,'Точки многогранника'		,GL_SAN_CONTEXT_ENABLED_PROCEDURE,@SetColorPolyhedronPoints);
GlSanContextMenuAddString(NewContext,'Ребра многогранника'		,GL_SAN_CONTEXT_ENABLED_PROCEDURE,@SetColorPolyhedronLines);

GlSanContextMenuAddString(NewContext,'Произвольные точки'		,GL_SAN_CONTEXT_ENABLED_PROCEDURE,@SetColorPoints);
GlSanContextMenuAddString(NewContext,'Произвольные отрезки'		,GL_SAN_CONTEXT_ENABLED_PROCEDURE,@SetColorLines);
GlSanContextMenuAddString(NewContext,'Произвольные поверхности'	,GL_SAN_CONTEXT_ENABLED_PROCEDURE,@SetColorPolygones);

GlSanContextMenuAddString(NewContext,'Сечение'					,GL_SAN_CONTEXT_ENABLED_PROCEDURE,@SetColorCut);
GlSanContextMenuAddString(NewContext,'Опорные точки сечения'	,GL_SAN_CONTEXT_ENABLED_PROCEDURE,@SetColorCutPoints);
GlSanContextMenuAddString(NewContext,'Линии сечения'			,GL_SAN_CONTEXT_ENABLED_PROCEDURE,@SetColorCutLines);

GlSanContextMenuAddString(NewContext,'Фон'						,GL_SAN_CONTEXT_ENABLED_PROCEDURE,@SetColorBackground);

GlSanContextMenuIntoMake(NewContext,@w,nil,InitContextMenuOptionsColor);
end;

procedure InitContextMenuOptions(W:PGlSanWnd);
begin
GlSanContextMenuBeginning(NewContext);
GlSanContextMenuAddString(NewContext,'Цвета',GL_SAN_CONTEXT_ENABLED_FUNCTION,@InitContextMenuOptionsColor);
GlSanContextMenuAddString(NewContext,'Оформление',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@DoskaOptionOfGraphStart);
GlSanContextMenuAddString(NewContext,'Буфер сохранений',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@DoskaOptionOfBufferStart);
GlSanContextMenuMake(NewContext,@w,nil);
end;
procedure CtrlZ(W:PGlSanWnd);
begin
W^.UserMemory.ArLongint[4]+=1;
LoadFromBufferDoska(W);
end;
procedure ShiftCtrlZ(W:PGlSanWnd);
begin
if W^.UserMemory.ArLongint[4]>1 then W^.UserMemory.ArLongint[4]-=1;
LoadFromBufferDoska(W);
end;
procedure InitContextMenuFile(W:PGlSanWnd);
begin
GlSanContextMenuBeginning(NewContext);
//GlSanContextMenuSetViewType(NewContext,GL_SAN_TEXT_AND_ICONS);
GlSanContextMenuAddString(NewContext,'Новый многогранник',GL_SAN_CONTEXT_ENABLED_FUNCTION,@InitContextMenuImportFigure);
GlSanContextMenuAddString(NewContext,'Сохранить',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@SaveToFileDoska);
GlSanContextMenuAddString(NewContext,'Загрузить',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@LoadFileDoska);
GlSanContextMenuAddString(NewContext,'Отменить      [Ctrl+Z]',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@CtrlZ);
GlSanContextMenuAddString(NewContext,'Вернуть [Ctrl+Shift+Z]',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@ShiftCtrlZ);
GlSanContextMenuAddString(NewContext,'Выход',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@GlSanKillThisWindow);
GlSanContextMenuMake(NewContext,@w,nil);
end;

procedure InitWindowDoska();
begin
{$NOTE Beginning InitWindowDoska}
if not GlSanWndGenInf(GSB_INF_SOMETHING) then exit;
GlSanCreateWnd(@NewWnd,'Панель Управления',glSanKoor2fImport(ContextWidth,35));
GlSanWndSetInf(@NewWnd,GSB_INF_SOMETHING);
GlSanWndSetProgramName(@NewWnd,'Doska '+'®'+'SG Corporation');
GlSanWndDontSeeTittle(@NewWnd);
GlSanWndSetProc(@NewWnd,@GeneralProcDoska);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(5,5),GlSanKoor2fImport(105,30),'Файл',@InitContextMenuFile);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(215,5),GlSanKoor2fImport(395,30),'Навигация',@NavigationFigure);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(ContextWidth-290,5),GlSanKoor2fImport(ContextWidth-265,30),'',@NewPointDoska);
GlSanWndButtonHintAdd(@NewWnd,3,'Создает пользовательскую точку,');
GlSanWndButtonHintAdd(@NewWnd,3,'которую в последствии можно');
GlSanWndButtonHintAdd(@NewWnd,3,'перемещать по многограннику...');
GlSanWndSetLastButtonTexture(@NewWnd,'point');
GlSanWndSetLastButtonTextureOnClick(@NewWnd,'point_over');
GlSanWndSetLastButtonTextureClick(@NewWnd,'point_pressed');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(ContextWidth-260,5),GlSanKoor2fImport(ContextWidth-210,30),'',@NewLineDoska);
GlSanWndButtonHintAdd(@NewWnd,4,'Создает линию, которой можно');
GlSanWndButtonHintAdd(@NewWnd,4,'соединить две любые точки...');
GlSanWndSetLastButtonTexture(@NewWnd,'Line');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(ContextWidth-205,5),GlSanKoor2fImport(ContextWidth-180,30),'',@NewPolygoneDoska);
GlSanWndButtonHintAdd(@NewWnd,5,'Создает поверхность между выбранными точками.');
GlSanWndButtonHintAdd(@NewWnd,5,'Точек может быть бесконечно много.');
GlSanWndSetLastButtonTexture(@NewWnd,'Plosk');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(ContextWidth-175,5),GlSanKoor2fImport(ContextWidth-35,30),'Сечение',@RunSech);
GlSanWndButtonHintAdd(@NewWnd,6,'Cоздает сечение через выбранные');
GlSanWndButtonHintAdd(@NewWnd,6,'три точки не сечений...');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(ContextWidth-5-25,5),GlSanKoor2fImport(ContextWidth-5,30),'X',@GlSanKillThisWindow);
GlSanWndSetLastButtonColor(@NewWnd,7,GlSanColor4fImport(1,1,0,0.3));
GlSanWndSetLastButtonColor(@NewWnd,8,GlSanColor4fImport(1,0,0,0.3));
GlSanWndButtonHintAdd(@NewWnd,1+6,'Не забудьте сохраниться!');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(110,5),GlSanKoor2fImport(210,30),'Опции',@InitContextMenuOptions);
SetLength(NewWnd^.UserMemory.ArBoolean,12);
NewWnd^.UserMemory.ArBoolean[Low(NewWnd^.UserMemory.ArBoolean)+0]:=false;								//Лежит Ли Мышка На Обьекте
NewWnd^.UserMemory.ArBoolean[Low(NewWnd^.UserMemory.ArBoolean)+1]:=true;								//Показывать ли Обьект
NewWnd^.UserMemory.ArBoolean[Low(NewWnd^.UserMemory.ArBoolean)+2]:=true;								//Показывать ли Его Линии
NewWnd^.UserMemory.ArBoolean[Low(NewWnd^.UserMemory.ArBoolean)+3]:=true;								//Показывать ли Его Точки
NewWnd^.UserMemory.ArBoolean[Low(NewWnd^.UserMemory.ArBoolean)+4]:=true;								//Показывать ли Пользователя Линии
NewWnd^.UserMemory.ArBoolean[Low(NewWnd^.UserMemory.ArBoolean)+5]:=true;								//Показывать ли Пользователя Точки
NewWnd^.UserMemory.ArBoolean[Low(NewWnd^.UserMemory.ArBoolean)+6]:=true;								//Показывать ли Пользователя Плоскости
NewWnd^.UserMemory.ArBoolean[Low(NewWnd^.UserMemory.ArBoolean)+7]:=true;								//Показывать ли Точки Сечения
NewWnd^.UserMemory.ArBoolean[Low(NewWnd^.UserMemory.ArBoolean)+8]:=true;								//Показывать ли Линии Сечения
NewWnd^.UserMemory.ArBoolean[Low(NewWnd^.UserMemory.ArBoolean)+9]:=true;								//Показывать ли Плоскости Сечения
NewWnd^.UserMemory.ArBoolean[Low(NewWnd^.UserMemory.ArBoolean)+10]:=false;								//Навигация вверх
NewWnd^.UserMemory.ArBoolean[Low(NewWnd^.UserMemory.ArBoolean)+11]:=false;								//Флажок Сохранения в буфер
SetLength(NewWnd^.UserMemory.ArGlSanColor4f,12);
NewWnd^.UserMemory.ArGlSanColor4f[Low(NewWnd^.UserMemory.ArGlSanColor4f)+0].Import(1,1,1,0.329);		//Цвет обьекта
NewWnd^.UserMemory.ArGlSanColor4f[Low(NewWnd^.UserMemory.ArGlSanColor4f)+1].Import(1,0,0,0.6);			//Цвет Линий Обьекта
NewWnd^.UserMemory.ArGlSanColor4f[Low(NewWnd^.UserMemory.ArGlSanColor4f)+2].Import(0,1,0,0.6);			//Цвет Точек Обьекта
NewWnd^.UserMemory.ArGlSanColor4f[Low(NewWnd^.UserMemory.ArGlSanColor4f)+3].Import(0,1,1,0.6);			//Цвет Устонавлиемой Точки
NewWnd^.UserMemory.ArGlSanColor4f[Low(NewWnd^.UserMemory.ArGlSanColor4f)+4].Import(1,1,1,0.6);			//Цвет Пользовательских Точек
NewWnd^.UserMemory.ArGlSanColor4f[Low(NewWnd^.UserMemory.ArGlSanColor4f)+5].Import(1,0.5,0,0.6);		//Цвет Почти Установленой Точеки
NewWnd^.UserMemory.ArGlSanColor4f[Low(NewWnd^.UserMemory.ArGlSanColor4f)+6].Import(1,0.5,0,0.6);		//Цвет Точек Сечения
NewWnd^.UserMemory.ArGlSanColor4f[Low(NewWnd^.UserMemory.ArGlSanColor4f)+7].Import(0,0,1,0.6);			//Цвет Линий Сечения
NewWnd^.UserMemory.ArGlSanColor4f[Low(NewWnd^.UserMemory.ArGlSanColor4f)+8].Import(80/255,240/255,60/255,0.6);	//Цвет Плоскости Сечения
NewWnd^.UserMemory.ArGlSanColor4f[Low(NewWnd^.UserMemory.ArGlSanColor4f)+9].Import(1,1,0,0.6);			//Цвет Пользовательских Линий
NewWnd^.UserMemory.ArGlSanColor4f[Low(NewWnd^.UserMemory.ArGlSanColor4f)+10].Import(0.5,0,0.5,0.6);		//Цвет Пользовательских Плоскостей
NewWnd^.UserMemory.ArGlSanColor4f[Low(NewWnd^.UserMemory.ArGlSanColor4f)+11].Import(0,0,0,1);			//Цвет Фона
SetLength(NewWnd^.UserMemory.ArReal,6);
NewWnd^.UserMemory.ArReal[Low(NewWnd^.UserMemory.ArReal)+0]:=0.05;										//Радиус Точек Обьекта
NewWnd^.UserMemory.ArReal[Low(NewWnd^.UserMemory.ArReal)+1]:=0.05;										//Радиус Точек Пользователя
NewWnd^.UserMemory.ArReal[Low(NewWnd^.UserMemory.ArReal)+2]:=0.05;										//Радиус Точек Сечений
NewWnd^.UserMemory.ArReal[Low(NewWnd^.UserMemory.ArReal)+3]:=3;										//Ширина Линий Обьекта
NewWnd^.UserMemory.ArReal[Low(NewWnd^.UserMemory.ArReal)+4]:=3;										//Ширина Линий Пользователя
NewWnd^.UserMemory.ArReal[Low(NewWnd^.UserMemory.ArReal)+5]:=3;										//Ширина Линий Сечений
SetLength(NewWnd^.UserMemory.ArLongint,6);
NewWnd^.UserMemory.ArLongint[Low(NewWnd^.UserMemory.ArLongint)+0]:=1;									//Точки О (2=Kub)
NewWnd^.UserMemory.ArLongint[Low(NewWnd^.UserMemory.ArLongint)+1]:=1;									//Точки П (1=Sphere)
NewWnd^.UserMemory.ArLongint[Low(NewWnd^.UserMemory.ArLongint)+2]:=1;									//Точки С (...)
NewWnd^.UserMemory.ArLongint[Low(NewWnd^.UserMemory.ArLongint)+3]:=-1;									//Идентификатор Перемещаемой Пользовательской Точки
NewWnd^.UserMemory.ArLongint[Low(NewWnd^.UserMemory.ArLongint)+4]:=1;									//Текущая позиция в буфере
NewWnd^.UserMemory.ArLongint[Low(NewWnd^.UserMemory.ArLongint)+5]:=-1;									//ID Выбранного примитива
GlSanWndUserMove(@NewWnd,1,GlSanKoor2fImport(0.1,0.1));
InitBufferDoska(NewWnd);
GlSanWndDispose(@NewWnd);
end;
procedure RecNd(const l:longint; const t:GlSanKoor; const wnd:GlSanUWnd);
var
	ID1,ID2:longint;
	t2:GlSanKoor;
	i:longint;
begin
if l=3 then
	begin
	SetLength(Wnd^.UserMemory.ArGlSanKoor,Length(Wnd^.UserMemory.ArGlSanKoor)+8);
	for i:=0 to 7 do
		begin
		Wnd^.UserMemory.ArGlSanKoor[High(Wnd^.UserMemory.ArGlSanKoor)-8+i+1]:=
			GlSanKoorImport(Kub.v[i].x+t.x+0.5,Kub.v[i].y+t.y+0.5,Kub.v[i].z+t.z+0.5);
		end;
		
	end
else
	begin
	ID1:=l*2-1-6;
	ID2:=l*2-2-6;
	t2:=t;
	t2.Togever(GlSanKoorImport(
			cos(Wnd^.UserMemory.ArReal[ID1]*(pi/180)),
			sin(Wnd^.UserMemory.ArReal[ID1]*(pi/180)),
			cos(Wnd^.UserMemory.ArReal[ID2]*(pi/180))
			));
	RecNd(l-1,t,wnd);
	RecNd(l-1,t2,wnd);
	end;
end;
function GlSanSqr(const n,st:longint):longint;
var
	i:longint;
begin
GlSanSqr:=1;
for i:=1 to st do
	GlSanSqr*=n;
end;
procedure ProcND(Wnd:PGlSanWnd);
var
	UM:^GlSanWndUserMemory;
	i,ii,iii:longint;
	t:GlSanKoor;
	KolR:longint = 0;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
i:=0;
if GlSanWndClickButton(@Wnd,1) then
	begin
	if UM^.ArLongint[Low(UM^.ArLongint)]>3 then
		begin
		UM^.ArLongint[Low(UM^.ArLongint)]-=1;
		i:=-1;
		end;
	end;
if GlSanWndClickButton(@Wnd,2) then
	begin
	UM^.ArLongint[Low(UM^.ArLongint)]+=1;
	i:=1;
	end;
if GlSanWndClickButton(@Wnd,3) then
	begin
	for iii:=Low(UM^.Ar2Real) to High(UM^.Ar2Real) do
		UM^.Ar2Real[iii]*=1.2;
	end;
if GlSanWndClickButton(@Wnd,4) then
	begin
	for iii:=Low(UM^.Ar2Real) to High(UM^.Ar2Real) do
		UM^.Ar2Real[iii]*=0.8;
	end;
if GlSanWndClickButton(@Wnd,5) then
	begin
	for i:=Low(UM^.Ar2Real) to High(UM^.Ar2Real) do
		UM^.Ar2Real[i]:=random(10)/3;
	end;
if (i<>0) or (GlSanWndGetPositionFromComboBox(@Wnd,1)<>UM^.ArLongint[Low(UM^.ArLongint)+1]) then
	begin
	GlSanWndSetNewTittleText(@Wnd,1,'N='+GlSanStr(UM^.ArLongint[Low(UM^.ArLongint)]));
	case i of
	-1:
		begin
		SetLength(UM^.ArReal,Length(UM^.ArReal)-2);
		end;
	1:
		begin
		SetLength(UM^.ArReal,Length(UM^.ArReal)+2);
		UM^.ArReal[High(UM^.ArReal)-0]:=random(360);
		UM^.ArReal[High(UM^.ArReal)-1]:=random(360);
		end;
	end;
	SetLength(Wnd^.ArComboBox[Low(Wnd^.ArComboBox)].Text,0);
	Wnd^.ArComboBox[Low(Wnd^.ArComboBox)].Open:=false;
	Wnd^.ArComboBox[Low(Wnd^.ArComboBox)].OpenProgress:=0;
	GlSanWndNewStringInComboBox(@WNd,1,'Только камеру');
	GlSanWndNewStringInComboBox(@WNd,1,'Только с 4 по N');
	GlSanWndNewStringInComboBox(@WNd,1,'Крутить всё');
	GlSanWndNewStringInComboBox(@WNd,1,'Ничего не надо');
	UM^.ArLongint[Low(UM^.ArLongint)+1]:=4;
	GlSanWndSetNewTittleText(@Wnd,4,GlSanStr(UM^.ArLongint[Low(UM^.ArLongint)])+' Рёбер из 1-й точки');
	end;
if (i<>0) or (GlSanWndGetPositionFromComboBox(@Wnd,1)<>UM^.ArLongint[Low(UM^.ArLongint)+1]) then
	begin
	UM^.ArLongint[Low(UM^.ArLongint)+1]:=GlSanWndGetPositionFromComboBox(@Wnd,1);
	case UM^.ArLongint[Low(UM^.ArLongint)+1] of
	1:
		begin
		SetLength(UM^.Ar2Real,2);
		for i:=Low(UM^.Ar2Real) to High(UM^.Ar2Real) do
			UM^.Ar2Real[i]:=random(5)/3;
		end;
	2:
		begin
		SetLength(UM^.Ar2Real,Length(UM^.ArReal));
		for i:=Low(UM^.Ar2Real) to High(UM^.Ar2Real) do
			UM^.Ar2Real[i]:=random(10)/3;
		end;
	3:
		begin
		SetLength(UM^.Ar2Real,Length(UM^.ArReal)+2);
		for i:=Low(UM^.Ar2Real) to Low(UM^.Ar2Real)+1 do
			UM^.Ar2Real[i]:=random(5)/3;
		for i:=Low(UM^.Ar2Real)+2 to High(UM^.Ar2Real) do
			UM^.Ar2Real[i]:=random(10)/3;
		end;
	4:
		SetLength(UM^.Ar2Real,0);
	end;
	end;
case UM^.ArLongint[Low(UM^.ArLongint)+1] of
1:
	begin
	UM^.Rot2+=UM^.Ar2Real[Low(UM^.Ar2Real)+0];
	UM^.Rot1+=UM^.Ar2Real[Low(UM^.Ar2Real)+1];
	if UM^.Rot2>360 then
		UM^.Rot2-=360;
	if UM^.Rot1>360 then
		UM^.Rot1-=360;
	end;
2:
	begin
	for i:=Low(UM^.ArReal) to High(UM^.ArReal) do
		begin
		UM^.ArReal[i]+=UM^.Ar2Real[i];
		if UM^.ArReal[i]>360 then
			UM^.ArReal[i]-=360;
		end;
	end;
3:
	begin
	UM^.Rot2+=UM^.Ar2Real[Low(UM^.Ar2Real)+0];
	UM^.Rot1+=UM^.Ar2Real[Low(UM^.Ar2Real)+1];
	if UM^.Rot2>360 then
		UM^.Rot2-=360;
	if UM^.Rot1>360 then
		UM^.Rot1-=360;
	for i:=Low(UM^.ArReal) to High(UM^.ArReal) do
		begin
		UM^.ArReal[i]+=UM^.Ar2Real[i+2];
		if UM^.ArReal[i]>360 then
			UM^.ArReal[i]-=360;
		end;
	end;
end;
if GlSanMouseB(3)then
	begin
	UM^.Rot1-=GlSanMouseXY(1).x/3;
		UM^.Rot2-=GlSanMouseXY(1).y/3;
	end;
if GlSanMouseB(1)then
	begin
	UM^.UZ+=GlSanMouseXY(1).y/(170);
	UM^.LZ-=GlSanMouseXY(1).x/(170);
	end;
if (SGMouseWheel<>0) then
	case SGMouseWheel of
	-1:if GlSanDownKey(16) then UM^.zum+=0.35 else UM^.zum+=0.08;
	1: if GlSanDownKey(16) then UM^.zum-=0.35 else UM^.zum-=0.08;
	end;
SetLength(UM^.ArGlSanKoor,0);
RecNd(UM^.ArLongint[Low(UM^.ArLongint)],GlSanKoorImport(0,0,0),wnd);
t.Import(0,0,0);
for i:=Low(UM^.ArGlSanKoor) to High(UM^.ArGlSanKoor) do
	t.Togever(UM^.ArGlSanKoor[i]);
t.Zum(-1/Length(UM^.ArGlSanKoor));
for i:=Low(UM^.ArGlSanKoor) to High(UM^.ArGlSanKoor) do
	UM^.ArGlSanKoor[i].Togever(t);
glloadidentity();
gltranslatef(UM^.LZ,UM^.UZ,-6+UM^.Zum);
glrotatef(UM^.Rot2,1,0,0);
glrotatef(UM^.Rot1,0,1,0);
GLCOLOR4F(0,1,0,0.7);
if GlSanWndGetCaptionFromCheckBox(@Wnd,3) then
	if GlSanWndGetCaptionFromCheckBox(@Wnd,2) then
		for i:=Low(UM^.ArGlSanKoor) to High(UM^.ArGlSanKoor) do
			GlSanSphere(UM^.ArGlSanKoor[i],0.05)
	else
		for i:=Low(UM^.ArGlSanKoor) to High(UM^.ArGlSanKoor) do
			Kub.Init(UM^.ArGlSanKoor[i],0.02);
GlSanWndSetNewTittleText(@Wnd,2,GlSanStr(Length(UM^.ArGlSanKoor))+' Точек');
GLCOLOR4F(0,0.6,1,0.7);
glBegin(GL_LINES);
for i:=Low(UM^.ArGlSanKoor) to High(UM^.ArGlSanKoor) do
	if i mod 4 = 0 then
		begin
		UM^.ArGlSanKoor[i+0].Vertex;
		UM^.ArGlSanKoor[i+1].Vertex;
		UM^.ArGlSanKoor[i+1].Vertex;
		UM^.ArGlSanKoor[i+2].Vertex;
		UM^.ArGlSanKoor[i+2].Vertex;
		UM^.ArGlSanKoor[i+3].Vertex;
		UM^.ArGlSanKoor[i+3].Vertex;
		UM^.ArGlSanKoor[i+0].Vertex;
		KolR+=4;
		end;
for ii:=3 to UM^.ArLongint[Low(UM^.ArLongint)] do
	begin
	for iii:=0 to (Length(UM^.ArGlSanKoor) div GlSanSqr(2,ii))-1 do
		for i:=0 to GlSanSqr(2,ii-1)-1 do
			begin
			UM^.ArGlSanKoor[i+iii*GlSanSqr(2,ii)].Vertex;
			UM^.ArGlSanKoor[i+iii*GlSanSqr(2,ii)+GlSanSqr(2,ii-1)].Vertex;
			KolR+=1;
			end;
	end;
glEnd;
GlSanWndSetNewTittleText(@Wnd,3,GlSanStr(KolR)+' Ребер');
SetLength(UM^.ArGlSanKoor,0);
if GlSanWndGetCaptionFromCheckBox(@Wnd,1) then
	begin
	GLCOLOR4F(0.8,0,0,0.7);
	GlSanLine(GlSanKoorImport(0,0,5000),GlSanKoorImport(0,0,-5000));
	GlSanLine(GlSanKoorImport(0,5000,0),GlSanKoorImport(0,-5000,0));
	GlSanLine(GlSanKoorImport(5000,0,0),GlSanKoorImport(-5000,0,0));
	glBegin(GL_LINES);
	for i:=4 to UM^.ArLongint[Low(UM^.ArLongint)] do
		begin
		t.Import(cos(UM^.ArReal[(i-4)*2+1]*(pi/180))*5000,sin(UM^.ArReal[(i-4)*2+1]*(pi/180))*5000,cos(UM^.ArReal[(i-4)*2]*(pi/180))*5000);
		t.Vertex;
		t.Zum(-1);
		t.Vertex;
		end;
	glEnd;
	GLCOLOR4F(1,1,0,0.7);
	t.Import(0,0,0);
	GlSanSphere(t,0.05);
	end;
end;
procedure InitWndND;
begin
{$NOTE Beginning InitWndND}
if not GlSanWndGenInf(GSB_INF_ALL) then exit;
GlSanCreateWnd(@NewWnd,'N-мерный куб.',glSanKoor2fImport(200,470));
GlSanWndSetProgramName(@NewWnd,'ND '+'®'+'SG Corporation');
GlSanWndSetProc(@NewWnd,@ProcND);
GlSanWndSetInf(@NewWnd,GSB_INF_ALL);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(8,45),GlSanKoor2fImport(92,85),'-');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(108,45),GlSanKoor2fImport(192,85),'+');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(8,90),GlSanKoor2fImport(192,130),'N=3');
GlSanWndNewComboBox(@NewWnd,GlSanKoor2fImport(8,135),GlSanKoor2fImport(192,175));
GlSanWndNewStringInComboBox(@NewWNd,1,'Только камеру');
GlSanWndNewStringInComboBox(@NewWNd,1,'Только с 4 по N');
GlSanWndNewStringInComboBox(@NewWNd,1,'Крутить всё');
GlSanWndNewStringInComboBox(@NewWNd,1,'Ничего не надо');
NewWnd^.ArComboBox[Low(NewWnd^.ArComboBox)].Position:=3;
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(8,180),GlSanKoor2fImport(192,203),'Увеличить скорости вращения');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(8,207),GlSanKoor2fImport(192,230),'Уменьшить скорости вращения');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(8,235),GlSanKoor2fImport(192,257),'Изменить скорости вращения');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(8,330),GlSanKoor2fImport(192,360),'  Точек');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(8,365),GlSanKoor2fImport(192,395),'  Рёбер');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(8,400),GlSanKoor2fImport(192,430),'  Рёбер из 1-й точки');
GlSanWndNewCheckBox(@NewWnd,GlSanKoor2fImport(8,263),GlSanKoor2fImport(25,280),false);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(25,263),GlSanKoor2fImport(192,280),'Показывать оси');
GlSanWndNewCheckBox(@NewWnd,GlSanKoor2fImport(8,285),GlSanKoor2fImport(25,305),true);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(25,285),GlSanKoor2fImport(192,305),'Cферы вместо кубов в точках');
GlSanWndNewCheckBox(@NewWnd,GlSanKoor2fImport(8,310),GlSanKoor2fImport(25,325),true);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(25,310),GlSanKoor2fImport(192,325),'Показывать точки');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(8,435),GlSanKoor2fImport(192,465),'Выход',@GlSanKillThisWindow);
SetLength(NewWnd^.UserMemory.ArLongint,2);
NewWnd^.UserMemory.ArLongint[Low(NewWnd^.UserMemory.ArLongint)+0]:=3;//Nomber standing izmereniya
NewWnd^.UserMemory.ArLongint[Low(NewWnd^.UserMemory.ArLongint)+1]:=0;//Nombel Combo box pos
GlSanWndUserMove(@NewWnd,1,GlSanKoor2fImport(10,0));
GlSanWndDispose(@NewWnd);
randomize;
end;

procedure CreateFolder;
var
	bool:boolean;
	sr:DOS.SearchRec;
begin;
bool:=false;
DOS.findfirst('Program Files\*.*',$3F,sr);
While (dos.DosError<>18) and (bool=false) do
	begin
	if sr.Name='Notepad' then
		bool:=true;
	DOS.findnext(sr);
	end;
if not bool then
	begin
	MKDIR('Program Files\Notepad');
	end;
end;
procedure CreateComboBox;
var
	sr:DOS.SearchRec;
begin
DOS.findfirst('Program Files\Notepad\*.ssn',$3F,sr);
While (dos.DosError<>18) do
	begin
	GlSanWndNewStringInComboBox(@NewWnd,1,GlSanCopy(sr.name,1,Length(sr.name)-4));
	DOS.findnext(sr);
	end;
SetLEngth(NewWnd^.UserMemory.ArBoolean,1);
if Length(NewWnd^.ArComboBox[0].Text)=0 then
	begin
	NewWnd^.UserMemory.ArBoolean[0]:=false;
	GlSanWndNewStringInComboBox(@NewWnd,1,'Нет записей...');
	GlSanWndSetPositionOnComboBox(@NewWnd,1,1);
	end
else
	begin
	NewWnd^.UserMemory.ArBoolean[0]:=true;
	GlSanWndSetPositionOnComboBox(@NewWnd,1,1);
	end;
end;
procedure CreateNilNote(const s:string);
var
	f:file of GlSanFriend;
begin
assign(f,s);
rewrite(f);
close(f);
end;
procedure PackAndEraseNote(const d,sf:string);
var
	a:array of string = nil;
	sr:DOS.SearchRec;
	i:longint;
	f:file;
begin
DOS.findfirst(d+'*.*',$3F,sr);
While (dos.DosError<>18) do
	begin
	if (sr.name<>'.') and (sr.name<>'..') then
		begin
		SetLength(a,Length(a)+1);
		a[High(a)]:=d+sr.name;
		end;
	DOS.findnext(sr);
	end;
DOS.findclose(sr);
GlSanPack(@a,sf);
for i:=Low(A) to High(a) do
	begin
	assign(f,a[i]);
	erase(f);
	end;
end;
procedure EraseNote(const sd:string);
var
	sr:DOS.SearchRec;
	f:file;
begin
DOS.findfirst(sd+'*.*',$3F,sr);
While (dos.DosError<>18) do
	begin
	if (sr.name<>'.') and (sr.name<>'..') then
		begin
		assign(f,sd+sr.name);
		erase(f);
		end;
	DOS.findnext(sr);
	end;
DOS.findclose(sr);
end;
procedure MKDIRLast;
var
	bool:boolean;
	sr:DOS.SearchRec;
begin;
bool:=false;
DOS.findfirst('Program Files\Notepad\*.*',$3F,sr);
While (dos.DosError<>18) and (bool=false) do
	begin
	if sr.Name='Last' then
		bool:=true;
	DOS.findnext(sr);
	end;
if not bool then
	begin
	MKDIR('Program Files\Notepad\Last');
	end;
end;
procedure LoadGeneral(const w:PGlSanWnd;const sd:string);
var
	f:file of GlSanFriend;
	UM:^GlSanWndUserMemory;
	i:longint;
begin
UM:=GlSanWndGetPointerOfUserMemory(@W);
for i:=0 to high(UM^.ArGlSanFriend) do
	UM^.ArGlSanFriend[i].Dispose;
SetLength(UM^.ArGlSanFriend,0);
assign(f,sd+'Conf.cfg');
reset(f);
while not eof(f) do
	begin
	SetLength(UM^.ArGlSanFriend,Length(UM^.ArGlSanFriend)+1);
	UM^.ArGlSanFriend[High(UM^.ArGlSanFriend)].Dispose;
	read(f,UM^.ArGlSanFriend[High(UM^.ArGlSanFriend)]);
	if UM^.ArGlSanFriend[High(UM^.ArGlSanFriend)].FaceS<>'' then
		UM^.ArGlSanFriend[High(UM^.ArGlSanFriend)].FaceG:=
			GlSanLoadTexture(sd+UM^.ArGlSanFriend[High(UM^.ArGlSanFriend)].FaceS);
	end;
close(f);
end;
procedure InitStrings(const w:PGlSanWnd);
var
	UM:^GlSanWndUserMemory;
	i:longint;
begin
UM:=GlSanWndGetPointerOfUserMemory(@W);
GlSanWndClearListBox(@w,1);
for i:=Low(UM^.ArGlSanFriend) to High(UM^.ArGlSanFriend) do
	begin
	GlSanWndNewStringInLintBox(@w,1,UM^.ArGlSanFriend[i].Family+' '+UM^.ArGlSanFriend[i].Name);
	end;
end;
procedure SaveNote(const Wnd:PGlSanWnd;const sf:string);
var
	f:file of GlSanFriend;
	i:longint;
begin
assign(f,sf);
rewrite(f);
for i:=Low(Wnd^.UserMemory.ArGlSanFriend) to High(Wnd^.UserMemory.ArGlSanFriend) do
	write(f,Wnd^.UserMemory.ArGlSanFriend[i]);
close(f);
end;
procedure RecSaveCont(Wnd:PGlSanWnd);
var
	UM,UMG:^GlSanWndUserMemory;
	WndG:PGlSanWnd;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
WndG:=UM^.ArPointer[Low(UM^.ArPointer)];
UMG:=GlSanWndGetPointerOfUserMemory(@WndG);
with UMg^.ArGlSanFriend[Wnd^.UserMemory.ArLongint[Low(Wnd^.UserMemory.ArLongint)]-2]do
	begin
	FaceG:=0;
	FaceS:=GlSanWndGetCaptionFromEdit(@Wnd,5);
	Name:=GlSanWndGetCaptionFromEdit(@Wnd,1);
	Family:=GlSanWndGetCaptionFromEdit(@Wnd,2);
	Namber:=GlSanWndGetCaptionFromEdit(@Wnd,4);
	Addres:=GlSanWndGetCaptionFromEdit(@Wnd,3);
	end;
GlSanUnPack('Program Files\Notepad\'+UMG^.ArString[Low(UMG^.ArString)]+'.ssn','Program Files\Notepad\Last\');
SaveNote(Wndg,'Program Files\Notepad\Last\Conf.cfg');
(*IMAGE========<<<<<<<<<<<<<<<<<<<<<<*)
LoadGeneral(Wndg,'Program Files\Notepad\Last\');
InitStrings(Wndg);
PackAndEraseNote('Program Files\Notepad\Last\','Program Files\Notepad\'+UMG^.ArString[Low(UMG^.ArString)]+'.ssn');
GlSanKillThisWindow(Wnd);
end;
function LoadAva2(s:string;w:PGlSanWnd;b:boolean):boolean;
begin
 LoadAva2:=true;
 w^.ArEdit[4].Caption:=s;
 {if w^.UserMemory.ArLongint[1]<>0 then
	FreeMem(pointer(w^.UserMemory.ArLongint[1]));}
 w^.UserMemory.ArLongint[1]:=
	GlSanLoadTexture(s);
 GlSanWndSetImageTexture(@w,1,w^.UserMemory.ArLongint[1]);
end;
procedure LoadAva(wnd:PGlSanWnd);
var
	A:array of string;
begin
SetLength(a,4);
a[Low(a)+0]:='jpg';
a[Low(a)+1]:='png';
a[Low(a)+2]:='bmp';
a[Low(a)+3]:='jpeg';
GlSanWndRunLoadFile('Аватара',@LoadAva2,Wnd,@a);
SetLength(a,0);
end;
procedure RecNewCont(Wnd:PGlSanWnd);
var
	UM,UMG:^GlSanWndUserMemory;
	WndG:PGlSanWnd;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
WndG:=UM^.ArPointer[Low(UM^.ArPointer)];
UMG:=GlSanWndGetPointerOfUserMemory(@WndG);
SetLength(UMg^.ArGlSanFriend,Length(UMg^.ArGlSanFriend)+1);
with UMg^.ArGlSanFriend[High(UMg^.ArGlSanFriend)] do
	begin
	FaceG:=0;
	FaceS:=GlSanWndGetCaptionFromEdit(@Wnd,5);
	Name:=GlSanWndGetCaptionFromEdit(@Wnd,1);
	Family:=GlSanWndGetCaptionFromEdit(@Wnd,2);
	Namber:=GlSanWndGetCaptionFromEdit(@Wnd,4);
	Addres:=GlSanWndGetCaptionFromEdit(@Wnd,3);
	end;
GlSanUnPack('Program Files\Notepad\'+UMG^.ArString[Low(UMG^.ArString)]+'.ssn','Program Files\Notepad\Last\');
SaveNote(Wndg,'Program Files\Notepad\Last\Conf.cfg');
(*IMAGE========<<<<<<<<<<<<<<<<<<<<<<*)
LoadGeneral(Wndg,'Program Files\Notepad\Last\');
InitStrings(Wndg);
PackAndEraseNote('Program Files\Notepad\Last\','Program Files\Notepad\'+UMG^.ArString[Low(UMG^.ArString)]+'.ssn');
GlSanKillThisWindow(Wnd);
end;
procedure NewContact(Wnd:PGlSanWnd);
begin
GlSanCreateWnd(@NewWnd,'Новый контакт',GlSanKoor2fImport(510,260));
GlSanWndNewCloseButton(@NewWnd);
GlSanWndNewDependentWnd(@Wnd,NewWnd);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,40),GlSanKoor2fImport(100,70),'Имя:');
GlSanWndNewEdit(@NewWnd,GlSanKoor2fImport(110,40),GlSanKoor2fImport(390,70),'');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,75),GlSanKoor2fImport(100,105),'Фамилия:');
GlSanWndNewEdit(@NewWnd,GlSanKoor2fImport(110,75),GlSanKoor2fImport(390,105),'');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,110),GlSanKoor2fImport(100,140),'Адрес:');
GlSanWndNewEdit(@NewWnd,GlSanKoor2fImport(110,110),GlSanKoor2fImport(390,140),'');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,145),GlSanKoor2fImport(100,175),'Номер:');
GlSanWndNewEdit(@NewWnd,GlSanKoor2fImport(110,145),GlSanKoor2fImport(390,175),'');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,180),GlSanKoor2fImport(100,210),'Аватар:');
GlSanWndNewEdit(@NewWnd,GlSanKoor2fImport(110,180),GlSanKoor2fImport(390,210),'');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(400,180),GlSanKoor2fImport(500,210),'Обзор',@LoadAva);
GlSanWndNewImage(@NewWnd,GlSanKoor2fImport(400,40),GlSanKoor2fImport(500,175),GlSanGetGLUint('UN'));
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(100,215),GlSanKoor2fImport(300,250),'Создать такой контакт',@RecNewCont);
SetLength(NewWnd^.UserMemory.ArPointer,1);
NewWnd^.UserMemory.ArPointer[Low(NewWnd^.UserMemory.ArPointer)]:=Wnd;
sETLength(NewWnd^.UserMemory.ArLongint,2);
NewWnd^.UserMemory.ArLongint[Low(NewWnd^.UserMemory.ArLongint)+1]:=0;
GlSanWndDispose(@NewWnd);
end;
procedure RewriteC(Wnd:PGlSanWnd);
begin
GlSanCreateWnd(@NewWnd,'Изменить контакт',GlSanKoor2fImport(510,260));
GlSanWndNewCloseButton(@NewWnd);
GlSanWndNewDependentWnd(@Wnd,NewWnd);
sETLength(NewWnd^.UserMemory.ArLongint,2);
NewWnd^.UserMemory.ArLongint[Low(NewWnd^.UserMemory.ArLongint)]:=Wnd^.UserMemory.ArLongint[Low(Wnd^.UserMemory.ArLongint)];
NewWnd^.UserMemory.ArLongint[Low(NewWnd^.UserMemory.ArLongint)+1]:=0;
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,40),GlSanKoor2fImport(100,70),'Имя:');
GlSanWndNewEdit(@NewWnd,GlSanKoor2fImport(110,40),GlSanKoor2fImport(390,70),
	Wnd^.UserMemory.ArGlSanFriend[Wnd^.UserMemory.ArLongint[lOW(Wnd^.UserMemory.ArLongint)]-2].Name);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,75),GlSanKoor2fImport(100,105),'Фамилия:');
GlSanWndNewEdit(@NewWnd,GlSanKoor2fImport(110,75),GlSanKoor2fImport(390,105),
	Wnd^.UserMemory.ArGlSanFriend[Wnd^.UserMemory.ArLongint[lOW(Wnd^.UserMemory.ArLongint)]-2].Family);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,110),GlSanKoor2fImport(100,140),'Адрес:');
GlSanWndNewEdit(@NewWnd,GlSanKoor2fImport(110,110),GlSanKoor2fImport(390,140),
	Wnd^.UserMemory.ArGlSanFriend[Wnd^.UserMemory.ArLongint[lOW(Wnd^.UserMemory.ArLongint)]-2].Addres);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,145),GlSanKoor2fImport(100,175),'Номер:');
GlSanWndNewEdit(@NewWnd,GlSanKoor2fImport(110,145),GlSanKoor2fImport(390,175),
	Wnd^.UserMemory.ArGlSanFriend[Wnd^.UserMemory.ArLongint[lOW(Wnd^.UserMemory.ArLongint)]-2].Namber);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,180),GlSanKoor2fImport(100,210),'Аватар:');
GlSanWndNewEdit(@NewWnd,GlSanKoor2fImport(110,180),GlSanKoor2fImport(390,210),
	Wnd^.UserMemory.ArGlSanFriend[Wnd^.UserMemory.ArLongint[lOW(Wnd^.UserMemory.ArLongint)]-2].FaceS);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(400,180),GlSanKoor2fImport(500,210),'Обзор',@LoadAva);
GlSanWndNewImage(@NewWnd,GlSanKoor2fImport(400,40),GlSanKoor2fImport(500,175),GlSanGetGLUint('UN'));
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(100,215),GlSanKoor2fImport(300,250),'Сохранить изменения',@RecSaveCont);
SetLength(NewWnd^.UserMemory.ArPointer,1);
NewWnd^.UserMemory.ArPointer[Low(NewWnd^.UserMemory.ArPointer)]:=Wnd;
GlSanWndDispose(@NewWnd);
end;
procedure InitDefaultContext(Wnd:PGlSanWnd);
begin
GlSanContextMenuBeginning(NewContext);
GlSanContextMenuAddString(NewContext,'Новый контакт',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@NewContact);
GlSanContextMenuAddString(NewContext,'Отмена',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@GlSanKillContext);
GlSanContextMenuMake(NewContext,@wnd,nil);
end;
procedure ViewC(Wnd:PGlSanWnd);
begin
GlSanCreateWnd(@NewWnd,'Просмотр контакта.',GlSanKoor2fImport(600,200));
GlSanWndNewDependentWnd(@Wnd,NewWnd);
GlSanWndNewCloseButton(@NewWnd);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(100+10,40),GlSanKoor2fImport(590,70),'Имя:'+
	Wnd^.UserMemory.ArGlSanFriend[Wnd^.UserMemory.ArLongint[lOW(Wnd^.UserMemory.ArLongint)]-2].Name);
GlSanWndSetLastTextParametrs(@NewWnd,GSB_LEFT_TEXT,GSB_CANCULATE_HEIGHT);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(100+10,75),GlSanKoor2fImport(590,105),'Фамилия:'+
	Wnd^.UserMemory.ArGlSanFriend[Wnd^.UserMemory.ArLongint[lOW(Wnd^.UserMemory.ArLongint)]-2].Family);
GlSanWndSetLastTextParametrs(@NewWnd,GSB_LEFT_TEXT,GSB_CANCULATE_HEIGHT);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(100+10,110),GlSanKoor2fImport(590,140),'Адрес:'+
	Wnd^.UserMemory.ArGlSanFriend[Wnd^.UserMemory.ArLongint[lOW(Wnd^.UserMemory.ArLongint)]-2].Addres);
GlSanWndSetLastTextParametrs(@NewWnd,GSB_LEFT_TEXT,GSB_CANCULATE_HEIGHT);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(100+10,145),GlSanKoor2fImport(590,175),'Номер:'+
	Wnd^.UserMemory.ArGlSanFriend[Wnd^.UserMemory.ArLongint[lOW(Wnd^.UserMemory.ArLongint)]-2].Namber);
GlSanWndSetLastTextParametrs(@NewWnd,GSB_LEFT_TEXT,GSB_CANCULATE_HEIGHT);
if Wnd^.UserMemory.ArGlSanFriend[Wnd^.UserMemory.ArLongint[lOW(Wnd^.UserMemory.ArLongint)]-2].FaceS='' then
	GlSanWndNewImage(@NewWnd,GlSanKoor2fImport(10,40),GlSanKoor2fImport(100,175),GlSanGetGLUint('UN'))
else
	GlSanWndNewImage(@NewWnd,GlSanKoor2fImport(10,40),GlSanKoor2fImport(100,175),
	Wnd^.UserMemory.ArGlSanFriend[Wnd^.UserMemory.ArLongint[lOW(Wnd^.UserMemory.ArLongint)]-2].FaceG);
GlSanWndDispose(@NewWnd);
end;
procedure DeleteC(Wnd:PGlSanWnd);
var
	UM:^GlSanWndUserMemory;
	WndG:PGlSanWnd;
	i:longint;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
wndg:=wnd;
for i:=Wnd^.UserMemory.ArLongint[Low(Wnd^.UserMemory.ArLongint)]-2 to high(UM^.ArGlSanFriend)-1 do
	begin
	UM^.ArGlSanFriend[i]:=UM^.ArGlSanFriend[i+1];
	end;
SetLength(UM^.ArGlSanFriend,Length(UM^.ArGlSanFriend)-1);
GlSanUnPack('Program Files\Notepad\'+UM^.ArString[Low(UM^.ArString)]+'.ssn','Program Files\Notepad\Last\');
SaveNote(Wndg,'Program Files\Notepad\Last\Conf.cfg');
(*IMAGE========<<<<<<<<<<<<<<<<<<<<<<*)
LoadGeneral(Wndg,'Program Files\Notepad\Last\');
InitStrings(Wndg);
PackAndEraseNote('Program Files\Notepad\Last\','Program Files\Notepad\'+Um^.ArString[Low(UM^.ArString)]+'.ssn');
end;
procedure DeleteAll(Wnd:PGlSanWnd);
begin

end;
procedure InitGeneralContext(Wnd:PGlSanWnd);
begin
GlSanContextMenuBeginning(NewContext);
GlSanContextMenuAddString(NewContext,'Просмотр',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@ViewC);
GlSanContextMenuAddString(NewContext,'Изменить',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@RewriteC);
GlSanContextMenuAddString(NewContext,'Удалить',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@DeleteC);
GlSanContextMenuAddString(NewContext,'Удалить все контакты',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@DeleteAll);
GlSanContextMenuAddString(NewContext,'Новый контакт',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@NewContact);
GlSanContextMenuAddString(NewContext,'Отмена',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@GlSanKillContext);
GlSanContextMenuMake(NewContext,@wnd,nil);
end;
procedure Proc2(Wnd:PGlSanWnd);
var
	Pos:longint;
begin
if GlMouseReadKey=2 then
	begin
	Pos:=GlSanWndGetOnPositionFromListBox(@Wnd,1);
	case Pos of
	0:
		InitDefaultContext(Wnd);
	else 
		if Pos <> -1 then
			begin
			Wnd^.UserMemory.ArLongint[Low(Wnd^.UserMemory.ArLongint)]:=Pos;
			InitGeneralContext(Wnd);
			end;
	end;
	end;
end;
procedure LoadNote(const w:PGlSanWnd;const sf:string);
begin
if Fail_est('Program Files\Notepad\'+sf) then
	begin
	GlSanKillThisWindow(w);
	GlSanCreateWnd(@NewWnd,'Контакты ("'+GlSanCopy(sf,1,Length(sf)-4)+'")',GlSanKoor2fImport(400,600));
	GlSanWndSetProgramName(@NewWnd,'SG Corporation');
	GlSanWndSetProc(@NewWnd,@Proc2);
	GlSanWndNewCloseButton(@NewWnd);
	GlSanWndNewListBox(@NewWnd,GlSanKoor2fImport(10,50),GlSanKoor2fImport(390,590),
		GlSanKoor2fImport(30,20),true);
	GlSanUnPack('Program Files\Notepad\'+sf,'Program Files\Notepad\Last\');
	LoadGeneral(NewWnd,'Program Files\Notepad\Last\');
	InitStrings(NewWnd);
	EraseNote('Program Files\Notepad\Last\');
	SetLength(NewWnd^.UserMemory.ArLongint,1);
	SetLength(NewWnd^.UserMemory.ArString,1);
	NewWnd^.UserMemory.ArString[Low(NewWnd^.UserMemory.ArString)]:=GlSanCopy(sf,1,Length(sf)-4);
	GlSanWndDispose(@NewWnd);
	end;
end;
procedure CreateNewNotepad(Wnd:PGlSanWnd);
begin
if GlSanWndGetCaptionFromEdit(@Wnd,1)<>'' then
	begin
	MKDIRLast;
	CreateNilNote('Program Files\Notepad\Last\Conf.cfg');
	PackAndEraseNote('Program Files\Notepad\Last\','Program Files\Notepad\'+GlSanWndGetCaptionFromEdit(@Wnd,1)+'.ssn');
	LoadNote(Wnd,GlSanWndGetCaptionFromEdit(@Wnd,1)+'.ssn');
	end
else
	GlSanCreateOKWnd(Wnd ,'Писать научись!','Введи ну хоть что-нибудь!');
end;
procedure LoadNotepad(Wnd:PGlSanWnd);
begin
if Wnd^.UserMemory.ArBoolean[0] then
	begin
	LoadNote(Wnd,Wnd^.ArComboBox[0].Text[GlSanWndGetPositionFromComboBox(@Wnd,1)-1]+'.ssn');
	end;
end;
procedure InitWindowZapisnaya();
begin
{$NOTE Beginning InitWindowZapisnaya}
CreateFolder;
GlSanCreateWnd(@NewWnd,'Вход',GlSanKoor2fImport(400,185));
GlSanWndSetProgramName(@NewWnd,'Notebook '+'®'+'SG Corporation');
GlSanWndNewCloseButton(@NewWnd);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,40),GlSanKoor2fImport(390,70),'Coздать новую книжку...');
GlSanWndNewEdit(@NewWnd,GlSanKoor2fImport(10,75),GlSanKoor2fImport(295,105),'');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(305,75),GlSanKoor2fImport(390,105),'Создать',@CreateNewNotepad);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,110),GlSanKoor2fImport(390,140),'Выбрать уже созданную...');
GlSanWndNewComboBox(@NewWnd,GlSanKoor2fImport(10,145),GlSanKoor2fImport(295,175));
CreateComboBox;
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(305,145),GlSanKoor2fImport(390,175),'Загрузить',@LoadNotepad);
GlSanWndDispose(@NewWnd);
end;

procedure ProcKoh_6U(Wnd:PGlSanWnd);
type
	ArQuad=array[1..6] of GlSanKoor;
var
	a:ArQuad;
	i,ii:longint;
procedure Rec(const a:ArQuad; const l:longint);
var b:array[1..10] of GlSanKoor;
	c:ArQuad;
	i:longint;
begin
if l>1 then
	begin
	case WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)+1] of
	1:
		begin
		b[1]:=a[2];b[1].Togever(a[1]);b[1].Zum(1/2);b[2]:=a[3];b[2].Togever(a[2]);b[2].Zum(1/2);
		b[3]:=a[4];b[3].Togever(a[3]);b[3].Zum(1/2);b[4]:=a[5];b[4].Togever(a[4]);b[4].Zum(1/2);
		b[5]:=a[6];b[5].Togever(a[5]);b[5].Zum(1/2);b[6]:=a[1];b[6].Togever(a[6]);b[6].Zum(1/2);
		b[10]:=a[2];b[10].Togever(a[5]);b[10].Zum(1/2);
		b[7]:=b[10];b[7].Togever(b[6]);b[7].Togever(b[1]);b[7].Zum(1/3);
		b[8]:=b[10];b[8].Togever(b[2]);b[8].Togever(b[3]);b[8].Zum(1/3);
		b[9]:=b[5];b[9].Togever(b[10]);b[9].Togever(b[4]);b[9].Zum(1/3);
		c[1]:=b[1];c[2]:=b[7];c[3]:=b[10];c[4]:=b[8];c[5]:=b[2];c[6]:=a[2];rec(c,l-1);
		c[1]:=b[10];c[2]:=b[8];c[3]:=b[3];c[4]:=a[4];c[5]:=b[4];c[6]:=b[9];rec(c,l-1);
		c[1]:=b[6];c[2]:=b[7];c[3]:=b[10];c[4]:=b[9];c[5]:=b[5];c[6]:=a[6];rec(c,l-1);
		end;
	2:
		begin
		b[1]:=a[2];b[1].Togever(a[1]);b[1].Zum(1/2);b[2]:=a[3];b[2].Togever(a[2]);b[2].Zum(1/2);
		b[3]:=a[4];b[3].Togever(a[3]);b[3].Zum(1/2);b[4]:=a[5];b[4].Togever(a[4]);b[4].Zum(1/2);
		b[5]:=a[6];b[5].Togever(a[5]);b[5].Zum(1/2);b[6]:=a[1];b[6].Togever(a[6]);b[6].Zum(1/2);
		b[10]:=a[2];b[10].Togever(a[5]);b[10].Zum(1/2);
		b[7]:=b[10];b[7].Togever(b[6]);b[7].Togever(b[1]);b[7].Zum(1/3);
		b[8]:=b[10];b[8].Togever(b[2]);b[8].Togever(b[3]);b[8].Zum(1/3);
		b[9]:=b[5];b[9].Togever(b[10]);b[9].Togever(b[4]);b[9].Zum(1/3);
		c[1]:=b[7];c[2]:=b[10];c[3]:=b[8];c[4]:=b[2];c[5]:=a[2];c[6]:=b[1];rec(c,l-1);
		c[1]:=b[8];c[2]:=b[3];c[3]:=a[4];c[4]:=b[4];c[5]:=b[9];c[6]:=b[10];rec(c,l-1);
		c[1]:=b[7];c[2]:=b[10];c[3]:=b[9];c[4]:=b[5];c[5]:=a[6];c[6]:=b[6];rec(c,l-1);
		end;
	3:
		begin
		b[1]:=a[2];b[1].Togever(a[1]);b[1].Zum(1/2);b[2]:=a[3];b[2].Togever(a[2]);b[2].Zum(1/2);
		b[3]:=a[4];b[3].Togever(a[3]);b[3].Zum(1/2);b[4]:=a[5];b[4].Togever(a[4]);b[4].Zum(1/2);
		b[5]:=a[6];b[5].Togever(a[5]);b[5].Zum(1/2);b[6]:=a[1];b[6].Togever(a[6]);b[6].Zum(1/2);
		b[10]:=a[2];b[10].Togever(a[5]);b[10].Zum(1/2);
		b[7]:=b[10];b[7].Togever(b[6]);b[7].Togever(b[1]);b[7].Zum(1/3);
		b[8]:=b[10];b[8].Togever(b[2]);b[8].Togever(b[3]);b[8].Zum(1/3);
		b[9]:=b[5];b[9].Togever(b[10]);b[9].Togever(b[4]);b[9].Zum(1/3);
		c[1]:=b[6];c[2]:=b[7];c[3]:=b[10];c[4]:=b[9];c[5]:=b[5];c[6]:=a[6];rec(c,l-1);
		c[1]:=b[7];c[2]:=b[10];c[3]:=b[8];c[4]:=b[2];c[5]:=a[2];c[6]:=b[1];rec(c,l-1);
		c[1]:=b[10];c[2]:=b[8];c[3]:=b[3];c[4]:=a[4];c[5]:=b[4];c[6]:=b[9];rec(c,l-1);
		end;
	4:
		begin
		b[1]:=a[2];b[1].Togever(a[1]);b[1].Zum(1/2);b[2]:=a[3];b[2].Togever(a[2]);b[2].Zum(1/2);
		b[3]:=a[4];b[3].Togever(a[3]);b[3].Zum(1/2);b[4]:=a[5];b[4].Togever(a[4]);b[4].Zum(1/2);
		b[5]:=a[6];b[5].Togever(a[5]);b[5].Zum(1/2);b[6]:=a[1];b[6].Togever(a[6]);b[6].Zum(1/2);
		b[10]:=a[2];b[10].Togever(a[5]);b[10].Zum(1/2);
		b[7]:=b[10];b[7].Togever(b[6]);b[7].Togever(b[1]);b[7].Zum(1/3);
		b[8]:=b[10];b[8].Togever(b[2]);b[8].Togever(b[3]);b[8].Zum(1/3);
		b[9]:=b[5];b[9].Togever(b[10]);b[9].Togever(b[4]);b[9].Zum(1/3);
		c[1]:=b[6];c[2]:=b[7];c[3]:=b[10];c[4]:=b[9];c[5]:=b[5];c[6]:=a[6];rec(c,l-1);
		c[1]:=b[7];c[2]:=b[10];c[3]:=b[8];c[4]:=b[2];c[5]:=a[2];c[6]:=b[1];rec(c,l-1);
		c[1]:=b[9];c[2]:=b[10];c[3]:=b[8];c[4]:=b[3];c[5]:=a[4];c[6]:=b[4];rec(c,l-1);
		end;
	end;
	end
else
	begin
	SetLength(Wnd^.UserMemory.ArGlSanKoor,Length(Wnd^.UserMemory.ArGlSanKoor)+6);
	for i:=1 to 6 do
		Wnd^.UserMemory.ArGlSanKoor[High(Wnd^.UserMemory.ArGlSanKoor)+1-i]:=a[i];
	end;
end;
begin
if WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)+2]=0 then
	begin
	for i:=1 to 6 do begin a[i].Import(cos(I*(PI/3)-pi/6)*3,sIN(I*(PI/3)-pi/6)*3,0); end;
	SetLength(Wnd^.UserMemory.ArGlSanKoor,0);
	REC(a,WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)]);
	Wnd^.UserMemory.rot1:=0;
	Wnd^.UserMemory.rot2:=0;
	Wnd^.UserMemory.Zum:=1;
	Wnd^.UserMemory.Uz:=0;
	Wnd^.UserMemory.LZ:=0;
	WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)+2]:=1;
	end;
glTranslatef(Wnd^.UserMemory.LZ,Wnd^.UserMemory.UZ,-6*Wnd^.UserMemory.Zum);
glrotatef(Wnd^.UserMemory.Rot1,1,0,0);
glrotatef(Wnd^.UserMemory.Rot2,0,0,1);
glcolor4f(0,0.5,0.5,0.2);
if GlSanWndClickButton(@Wnd,1) then
	begin
	WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)]:=WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)]+1;
	SetLength(Wnd^.UserMemory.ArGlSanKoor,0);
	if WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)+1]=4 then
		 for i:=1 to 6 do a[i].Import(cos(I*(PI/3)-pi/6+2*pi/3)*3,sIN(I*(PI/3)-pi/6+2*pi/3)*3,0)
	else
		for i:=1 to 6 do  a[i].Import(cos(I*(PI/3)-pi/6)*3,sIN(I*(PI/3)-pi/6)*3,0); 
	REC(a,WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)]);
	GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)]));
	end;
if GlSanWndClickButton(@Wnd,2) and (WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)]>1) then
	begin
	WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)]:=WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)]-1;
	SetLength(Wnd^.UserMemory.ArGlSanKoor,0);
	if WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)+1]=4 then
		 for i:=1 to 6 do a[i].Import(cos(I*(PI/3)-pi/6+2*pi/3)*3,sIN(I*(PI/3)-pi/6+2*pi/3)*3,0)
	else
		for i:=1 to 6 do  a[i].Import(cos(I*(PI/3)-pi/6)*3,sIN(I*(PI/3)-pi/6)*3,0); 
	REC(a,WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)]);
	GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)]));
	end;
if GlSanWndClickButton(@Wnd,3) then
	begin
	if WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)+1]=4 then 
		WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)+1]:=1 else 
		WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)+1]:=WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)+1]+1;
	SetLength(Wnd^.UserMemory.ArGlSanKoor,0);
	case WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)+1] of
	1:GlSanWndSetNewTittleText(@Wnd,2,'Тип-Треугольник');
	2:GlSanWndSetNewTittleText(@Wnd,2,'Тип-Звезда');
	3:GlSanWndSetNewTittleText(@Wnd,2,'Тип-Что-то');
	4:GlSanWndSetNewTittleText(@Wnd,2,'Тип-Лист');
	end;
	if WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)+1]=4 then
		 for i:=1 to 6 do a[i].Import(cos(I*(PI/3)-pi/6+2*pi/3)*3,sIN(I*(PI/3)-pi/6+2*pi/3)*3,0)
	else
		for i:=1 to 6 do  a[i].Import(cos(I*(PI/3)-pi/6)*3,sIN(I*(PI/3)-pi/6)*3,0); 
	REC(a,WNd^.UserMemory.ArLongint[Low(WNd^.UserMemory.ArLongint)]);
	end;
glcolor4f(0,1,1,0.9);
for i:=1 to Length(Wnd^.UserMemory.ArGlSanKoor) div 6 do
	begin
	glBegin(GL_LINE_LOOP);
	for ii:=(i-1)*6 to i*6-1 do 
		begin
		GlSanVertex3f(Wnd^.UserMemory.ArGlSanKoor[ii]);
		end;
	glEnd();
	end;
if GlSanMouseB(3) then
	begin
	Wnd^.UserMemory.Rot2-=GlSanMouseXY(1).x/3;
	Wnd^.UserMemory.Rot1-=GlSanMouseXY(1).y/3;
	end;
if GlSanMouseB(1) then
	begin
	Wnd^.UserMemory.UZ+=GlSanMouseXY(1).y/(170);
	Wnd^.UserMemory.LZ-=GlSanMouseXY(1).x/(170);
	end;
case SGMouseWheel of
1:Wnd^.UserMemory.Zum*=1.1;
-1:Wnd^.UserMemory.Zum*=0.9;
end;
end;

procedure InitWindowKoh_6U;
begin
{$NOTE Beginning InitWindowKoh_6U}
if not GlSanWndGenInf(GSB_INF_ALL) then exit;
GlSanCreateWnd(@NewWnd,'Управление',GlSanKoor2fImport(130,270));
GlSanWndSetProc(@NewWnd,@ProcKoh_6U);
GlSanWndSetProgramName(@NewWnd,'Koh6U '+'®'+'SG Corporation');
GlSanWndSetInf(@NewWnd,GSB_INF_ALL);
SetLength(NewWnd^.UserMemory.ArLongint,3);
NewWNd^.UserMemory.ArLongint[Low(NewWNd^.UserMemory.ArLongint)]:=2;
NewWNd^.UserMemory.ArLongint[Low(NewWNd^.UserMemory.ArLongint)+1]:=1;
NewWNd^.UserMemory.ArLongint[Low(NewWNd^.UserMemory.ArLongint)+2]:=0;
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(6,50),GlSanKoor2fImport(60,100),'+');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(70,50),GlSanKoor2fImport(124,100),'-');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(6,170),GlSanKoor2fImport(124,210),'Переключить Тип');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(6,110),GlSanKoor2fImport(124,160),' ');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(6,220),GlSanKoor2fImport(124,260),'Тип-Треугольник');
GlSanWndUserMove(@NewWnd,3,GlSanKoor2fImport(GetContextWidth-10,0));
GlSanWndSetNewTittleText(@NewWnd,1,GlSanStr(NewWNd^.UserMemory.ArLongint[Low(NewWNd^.UserMemory.ArLongint)]));
GlSanWndNewCloseButton(@NewWnd);
GlSanWndDispose(@NewWnd);
end;
initialization
begin
GlSanNewProgramInBuffer('Doska (Beta)','DoskaProgram',@InitWindowDoska);
GlSanNewProgramInBuffer('N-мерный куб','NDProgram',@InitWndND);
GlSanNewProgramInBuffer('Записная книжка','ZapisnayaProgram',@InitWindowZapisnaya);
GlSanNewProgramInBuffer('6-угольник Коха','ProgrammaKoh6U',@InitWindowKoh_6U);
end;
begin

end;

end.
