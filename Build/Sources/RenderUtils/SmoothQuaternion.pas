{$INCLUDE Smooth.inc}

unit SmoothQuaternion;

interface

uses
	 SmoothBase
	,SmoothCommon
	;

type
	PSQuaternion = ^ TSQuaternion;
	TSQuaternion = object(TSCommonVector4)
			public
		procedure Inverse();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function Intersed() : TSQuaternion;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

operator + (const A,B : TSQuaternion):TSQuaternion;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator - (const A   : TSQuaternion):TSQuaternion;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator - (const A,B : TSQuaternion):TSQuaternion;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (const A : TSQuaternion;const B:TSFloat32):TSQuaternion;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (const A,B : TSQuaternion):TSFloat;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGetQuaternionFromAngleVector3f(const Angles : TSCommonVector3):TSQuaternion;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SQuaternionSlerp(q1,q2:TSQuaternion; interp:TSFloat):TSQuaternion;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SQuaternionLerp(q1,q2:TSQuaternion; interp:TSFloat):TSQuaternion;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 Math
	;

function SQuaternionLerp(q1,q2:TSQuaternion; interp:TSFloat):TSQuaternion;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if ((q1 * q2) < 0) then
	Result := (q1 - ((q2 + q1) * interp))
else
	Result := (q1 + ((q2 - q1) * interp));
end;

operator + (const A,B : TSQuaternion):TSQuaternion;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Data[0] := A.Data[0] + B.Data[0];
Result.Data[1] := A.Data[1] + B.Data[1];
Result.Data[2] := A.Data[2] + B.Data[2];
Result.Data[3] := A.Data[3] + B.Data[3];
end;

operator - (const A   : TSQuaternion):TSQuaternion;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Data[0] := - A.Data[0];
Result.Data[1] := - A.Data[1];
Result.Data[2] := - A.Data[2];
Result.Data[3] := - A.Data[3];
end;

operator - (const A,B : TSQuaternion):TSQuaternion;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Data[0] := A.Data[0] - B.Data[0];
Result.Data[1] := A.Data[1] - B.Data[1];
Result.Data[2] := A.Data[2] - B.Data[2];
Result.Data[3] := A.Data[3] - B.Data[3];
end;

operator * (const A : TSQuaternion;const B:TSFloat32):TSQuaternion;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Data[0] := A.Data[0] * B;
Result.Data[1] := A.Data[1] * B;
Result.Data[2] := A.Data[2] * B;
Result.Data[3] := A.Data[3] * B;
end;

operator * (const A,B : TSQuaternion):TSFloat;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := A.Data[0] * B.Data[0] + A.Data[1] * B.Data[1] + A.Data[2] * B.Data[2] + A.Data[3] * B.Data[3];
end;

function SQuaternionSlerp(q1,q2:TSQuaternion; interp:TSFloat):TSQuaternion;
var i           : integer;
	a,b         : single;
	cosom       : single;
	sclq1,sclq2 : single;
	omega,sinom : single;

begin
a:=0;
b:=0;
for i:=0 to 3 do
	begin
	a:=a+( q1.Data[i]-q2.Data[i] )*( q1.Data[i]-q2.Data[i] );
	b:=b+( q1.Data[i]+q2.Data[i] )*( q1.Data[i]+q2.Data[i] );
	end;
if ( a > b ) then
	q2.Inverse();

cosom:=q1.Data[0]*q2.Data[0]+q1.Data[1]*q2.Data[1]
	+q1.Data[2]*q2.Data[2]+q1.Data[3]*q2.Data[3];

if (( 1.0+cosom ) > 0.00000001 ) then
	begin
	if (( 1.0-cosom ) > 0.00000001 ) then
		begin
		omega:= arccos( cosom );
		sinom:= sin( omega );
		sclq1:= sin(( 1.0-interp )*omega )/sinom;
		sclq2:= sin( interp*omega )/sinom;
		end
	else
		begin
		sclq1:= 1.0-interp;
		sclq2:= interp;
		end;
	for i:=0 to 3 do
		result.data[i]:=sclq1*q1.data[i]
			+sclq2*q2.data[i];
	end
else
	with result do
		begin
		data[0]:=-q1.data[1];
		data[1]:=q1.data[0];
		data[2]:=-q1.data[3];
		data[3]:=q1.data[2];
		sclq1:= sin(( 1.0-interp )*0.5*PI );
		sclq2:= sin( interp*0.5*PI );
		for i:=0 to 2 do
			data[i]:=sclq1*q1.data[i]
				+sclq2*data[i];
		end;
end;

function SGetQuaternionFromAngleVector3f(const Angles : TSCommonVector3):TSQuaternion;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var angle             : single;
    sr,sp,sy,cr,cp,cy : single;
    crcp,srsp         : single;
begin
angle:=angles.z*0.5;
sy:=sin( angle );
cy:=cos( angle );
angle:= angles.y*0.5;
sp:= sin( angle );
cp:= cos( angle );
angle:= angles.x*0.5;
sr:= sin( angle );
cr:= cos( angle );

crcp:= cr*cp;
srsp:= sr*sp;

Result.Import(
	sr*cp*cy-cr*sp*sy,
	cr*sp*cy+sr*cp*sy,
	crcp*sy -srsp*cy,
	crcp*cy +srsp*sy);
end;

procedure TSQuaternion.Inverse();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
x := -x;
y := -y;
z := -z;
w := -w;
end;

function TSQuaternion.Intersed():TSQuaternion;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(-x,-y,-z,-w);
end;

end.
