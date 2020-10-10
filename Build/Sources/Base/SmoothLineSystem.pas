{$INCLUDE Smooth.inc}

unit SmoothLineSystem;

interface

uses 
	 SmoothBase
	;

type 
	TSLineSystemFloat = TSFloat64;
	TSLineSystem = class
			public
		constructor Create(const nn : LongWord);
		destructor Destroy();override;
		procedure CalculateGauss();
		procedure CalculateRotate();
		procedure View();
			public
		a : array of array of TSLineSystemFloat;
		b : array of TSLineSystemFloat;
		n : LongWord;
		x : array of TSLineSystemFloat;
		end;

implementation

procedure TSLineSystem.View();
var
	i,ii : LongWord;
begin
for i:=0 to n-1 do
	begin
	for ii:=0 to n-1 do
		Write(a[i,ii]:0:4,' ');
	WriteLn('| ',b[i]:0:4);
	end;
end;

procedure TSLineSystem.CalculateRotate();
var
	i, ii, iii : LongWord;
	C, S, r, ai, aii : TSLineSystemFloat;
begin
for i:=0 to n-2 do
	for ii:=i+1 to n-1 do
		begin
		C := a[i,i]/sqrt(sqr(a[ii,i])+sqr(a[i,i]));
		S := a[ii,i] /sqrt(sqr(a[ii,i])+sqr(a[i,i]));
		for iii := i to n - 1 do
			begin
			ai  := a[ i,iii];
			aii := a[ii,iii];
			a[i,iii]  := C*ai+S*aii;
			a[ii,iii] := -S*ai+C*aii;
			end;
		ai := b[i];
		aii := b[ii];
		b[i] := C*ai+S*aii;
		b[ii]:= -S*ai+C*aii;
		end;
for i:=n-1 downto 0 do
	begin
	r:=b[i];
	for ii:=n-1 downto i do
		r-=x[ii]*a[i,ii];
	x[i]:=r/a[i,i];
	end;
end;

constructor TSLineSystem.Create(const nn : LongWord);
var
	i : LongWord;
begin
n := nn;
SetLength(b,n);
SetLength(x,n);
SetLength(a,n);
for i:=0 to n-1 do
	SetLength(a[i],n);
end;

destructor TSLineSystem.Destroy();
var
	i : TSUInt32;
begin
SetLength(b,0);
SetLength(x,0);
for i:=0 to n-1 do
	SetLength(a[i],0);
SetLength(a,0);
inherited;
end;

procedure TSLineSystem.CalculateGauss();
var
	r : TSLineSystemFloat;
	i, ii,iii:LongWord;
begin
for i:=1 to n-1 do
	begin
	for ii:=i to n-1 do
		begin
		r := -a[ii,i-1]/a[i-1,i-1];
		for iii:=0 to n-1 do
			a[ii,iii]+=r*a[i-1,iii];
		b[ii]+=r*b[i-1];
		end;
	end;
for i:=n-1 downto 0 do
	begin
	r:=b[i];
	for ii:=n-1 downto i do
		begin
		r-=x[ii]*a[i,ii];
		end;
	x[i]:=r/a[i,i];
	end;
end;

end.
