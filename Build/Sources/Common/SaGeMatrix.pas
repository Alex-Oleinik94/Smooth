{$INCLUDE SaGe.inc}

unit SaGeMatrix;

interface

uses
	 SaGeBase
	,SaGeCommon
	,SaGeQuaternion
	;

type
	TSGMatrixType = TSGFloat32;
	TSGMatrix4x4Type = TSGMatrixType;
	PSGMatrix4x4Type = ^ TSGMatrix4x4Type;
	TSGMatrix4x4 = array [0..3, 0..3] of TSGMatrix4x4Type;
	PSGMatrix4x4 = ^ TSGMatrix4x4;

operator * (const A,B:TSGMatrix4x4):TSGMatrix4x4;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator = (const A,B:TSGMatrix4x4):Boolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (const A:TSGVertex4f;const B:TSGMatrix4x4):TSGVertex4f;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (const A:TSGVertex3f;const B:TSGMatrix4x4):TSGVertex3f;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGMatrix4x4Import(const _0x0,_0x1,_0x2,_0x3,_1x0,_1x1,_1x2,_1x3,_2x0,_2x1,_2x2,_2x3,_3x0,_3x1,_3x2,_3x3:TSGMatrix4x4Type):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetFrustumMatrix(const vleft,vright,vbottom,vtop,vnear,vfar:TSGMatrix4x4Type):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetPerspectiveMatrix(const vAngle,vAspectRatio,vNear,vFar:TSGMatrix4x4Type):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetLookAtMatrix(const Eve, At:TSGVertex3f;Up:TSGVertex3f):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetOrthoMatrix(const l,r,b,t,vNear,vFar:TSGMatrix4x4Type):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGWriteMatrix4x4(const Matrix : TSGMatrix4x4);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetIdentityMatrix():TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetTranslateMatrix(const Vertex : TSGVertex3f):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGTranslateMatrix(const VMatrix : TSGMatrix4x4; const VVertex : TSGVertex3f):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetRotateMatrix(const Angle:Single;const Axis:TSGVertex3f) : TSGMatrix4x4; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGMultiplyPartMatrix(const m1:TSGMatrix4x4;const m2:TSGMatrix4x4):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGSetMatrixRotation(var Matrix : TSGMatrix4x4;const Angles : TSGVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGSetMatrixRotationQuaternion(var Matrix : TSGMatrix4x4;const Quat : TSGQuaternion);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGSetMatrixTranslation(var Matrix : TSGMatrix4x4; const Trans : TSGVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGRotateVectorInverse(const Matrix : TSGMatrix4x4;const Vec : TSGVertex3f):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGTranslateVectorInverse(const Matrix : TSGMatrix4x4;const Vec : TSGVertex3f):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGTransformVector(const Matrix : TSGMatrix4x4; const Vec : TSGVertex3f):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGInverseMatrix(const VSourseMatrix : TSGMatrix4x4) : TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetScaleMatrix(const VVertex : TSGVertex3f): TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 Crt
	,Math
	;

operator = (const A,B:TSGMatrix4x4):Boolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i,ii : LongWord;
begin
Result := True;
for i := 0 to 3 do
	for ii := 0 to 3 do
		if A[i][ii] <> B[i][ii] then
			begin
			Result := False;
			break;
			end;
end;

function SGGetRotateMatrix(const Angle:Single;const Axis:TSGVertex3f) : TSGMatrix4x4; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
    CosinusAngle, SinusAngle : Single;
begin
 Result:=SGGetIdentityMatrix();
 CosinusAngle:=cos(Angle);
 SinusAngle:=sin(Angle);
 Result[0,0]:=CosinusAngle+((1-CosinusAngle)*Axis.x*Axis.x);
 Result[1,0]:=((1-CosinusAngle)*Axis.x*Axis.y)-(Axis.z*SinusAngle);
 Result[2,0]:=((1-CosinusAngle)*Axis.x*Axis.z)+(Axis.y*SinusAngle);
 Result[0,1]:=((1-CosinusAngle)*Axis.x*Axis.z)+(Axis.z*SinusAngle);
 Result[1,1]:=CosinusAngle+((1-CosinusAngle)*Axis.y*Axis.y);
 Result[2,1]:=((1-CosinusAngle)*Axis.y*Axis.z)-(Axis.x*SinusAngle);
 Result[0,2]:=((1-CosinusAngle)*Axis.x*Axis.z)-(Axis.y*SinusAngle);
 Result[1,2]:=((1-CosinusAngle)*Axis.y*Axis.z)+(Axis.x*SinusAngle);
 Result[2,2]:=CosinusAngle+((1-CosinusAngle)*Axis.z*Axis.z);
end;

function SGGetScaleMatrix(const VVertex : TSGVertex3f): TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGGetIdentityMatrix();
Result[0][0] := VVertex.x;
Result[1][1] := VVertex.y;
Result[2][2] := VVertex.z;
end;

// Инвертирование матрицы
function SGInverseMatrix(const VSourseMatrix : TSGMatrix4x4) : TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
type
	TMatrix = array [0..15] of TSGMatrix4x4Type;

function mat(const  i : Byte) : TSGFloat; inline;
begin
Result := TMatrix(VSourseMatrix)[i];
end;

procedure ret(const i : byte; const f : TSGFloat); inline; overload;
begin
TMatrix(Result)[i] := f;
end;

var
	det,idet : TSGFloat;
begin
det:=((((((((mat(0)*mat(5)*mat(10))+(mat(4)*mat(9)*mat(2))))+(mat(8)*mat(1)*mat(6)))-(mat(8)*mat(5)*mat(2))))-(mat(4)*mat(1)*mat(10)))-(mat(0)*mat(9)*mat(6)));
if abs(det) < 0.0000001 then
	Result := SGGetIdentityMatrix()
else
	begin
	idet := 1/det;
	ret(0,(mat(5)*mat(10)-mat(9)*mat(6))*idet);
	ret(1,-(mat(1)*mat(10)-mat(9)*mat(2))*idet);
	ret(2, (mat(1)*mat(6)-mat(5)*mat(2))*idet);
	ret(3,0.0);
	ret(4,-(mat(4)*mat(10)-mat(8)*mat(6))*idet);
	ret(5, (mat(0)*mat(10)-mat(8)*mat(2))*idet);
	ret(6,-(mat(0)*mat(6)-mat(4)*mat(2))*idet);
	ret(7,0.0);
	ret(8, (mat(4)*mat(9)-mat(8)*mat(5))*idet);
	ret(9,-(mat(0)*mat(9)-mat(8)*mat(1))*idet);
	ret(10, (mat(0)*mat(5)-mat(4)*mat(1))*idet);
	ret(11,0.0);
	ret(12,-(mat(12)*TMatrix(Result)[0]+mat(13)*TMatrix(Result)[4]+mat(14)*TMatrix(Result)[8]));
	ret(13,-(mat(12)*TMatrix(Result)[1]+mat(13)*TMatrix(Result)[5]+mat(14)*TMatrix(Result)[9]));
	ret(14,-(mat(12)*TMatrix(Result)[2]+mat(13)*TMatrix(Result)[6]+mat(14)*TMatrix(Result)[10]));
	ret(15,1.0);
	end;
end;

function SGTransformVector(const Matrix : TSGMatrix4x4; const Vec : TSGVertex3f):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Data[0]:= Vec.Data[0]*Matrix[0,0]+Vec.Data[1]*Matrix[1,0]+Vec.Data[2]*Matrix[2,0]+Matrix[3,0];
Result.Data[1]:= Vec.Data[0]*Matrix[0,1]+Vec.Data[1]*Matrix[1,1]+Vec.Data[2]*Matrix[2,1]+Matrix[3,1];
Result.Data[2]:= Vec.Data[0]*Matrix[0,2]+Vec.Data[1]*Matrix[1,2]+Vec.Data[2]*Matrix[2,2]+Matrix[3,2];
end;

function SGTranslateVectorInverse(const Matrix : TSGMatrix4x4;const Vec : TSGVertex3f):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Data[0]:= Vec.Data[0]-Matrix[3,0];
Result.Data[1]:= Vec.Data[1]-Matrix[3,1];
Result.Data[2]:= Vec.Data[2]-Matrix[3,2];
end;

function SGRotateVectorInverse(const Matrix : TSGMatrix4x4;const Vec : TSGVertex3f):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Data[0]:= Vec.Data[0]*Matrix[0,0]+Vec.Data[1]*Matrix[0,1]+Vec.Data[2]*Matrix[0,2];
Result.Data[1]:= Vec.Data[0]*Matrix[1,0]+Vec.Data[1]*Matrix[1,1]+Vec.Data[2]*Matrix[1,2];
Result.Data[2]:= Vec.Data[0]*Matrix[2,0]+Vec.Data[1]*Matrix[2,1]+Vec.Data[2]*Matrix[2,2];
end;

procedure SGSetMatrixRotationQuaternion(var Matrix : TSGMatrix4x4;const Quat : TSGQuaternion);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Matrix[0,0]:= ( 1.0 - 2.0*Quat.Data[1]*Quat.Data[1] - 2.0*Quat.Data[2]*Quat.Data[2]);
Matrix[0,1]:= ( 2.0*Quat.Data[0]*Quat.Data[1] + 2.0*Quat.Data[3]*Quat.Data[2] );
Matrix[0,2]:= ( 2.0*Quat.Data[0]*Quat.Data[2] - 2.0*Quat.Data[3]*Quat.Data[1] );

Matrix[1,0]:= ( 2.0*Quat.Data[0]*Quat.Data[1] - 2.0*Quat.Data[3]*Quat.Data[2] );
Matrix[1,1]:= ( 1.0 - 2.0*Quat.Data[0]*Quat.Data[0] - 2.0*Quat.Data[2]*Quat.Data[2] );
Matrix[1,2]:= ( 2.0*Quat.Data[1]*Quat.Data[2] + 2.0*Quat.Data[3]*Quat.Data[0] );

Matrix[2,0]:= ( 2.0*Quat.Data[0]*Quat.Data[2] + 2.0*Quat.Data[3]*Quat.Data[1] );
Matrix[2,1]:= ( 2.0*Quat.Data[1]*Quat.Data[2] - 2.0*Quat.Data[3]*Quat.Data[0] );
Matrix[2,2]:= ( 1.0 - 2.0*Quat.Data[0]*Quat.Data[0] - 2.0*Quat.Data[1]*Quat.Data[1] );
end;

function SGMultiplyPartMatrix(const m1:TSGMatrix4x4;const m2:TSGMatrix4x4):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result[0,0]:= m1[0,0]*m2[0,0] + m1[1,0]*m2[0,1] + m1[2,0]*m2[0,2];
Result[0,1]:= m1[0,1]*m2[0,0] + m1[1,1]*m2[0,1] + m1[2,1]*m2[0,2];
Result[0,2]:= m1[0,2]*m2[0,0] + m1[1,2]*m2[0,1] + m1[2,2]*m2[0,2];
Result[0,3]:= 0;

Result[1,0]:= m1[0,0]*m2[1,0] + m1[1,0]*m2[1,1] + m1[2,0]*m2[1,2];
Result[1,1]:= m1[0,1]*m2[1,0] + m1[1,1]*m2[1,1] + m1[2,1]*m2[1,2];
Result[1,2]:= m1[0,2]*m2[1,0] + m1[1,2]*m2[1,1] + m1[2,2]*m2[1,2];
Result[1,3]:= 0;

Result[2,0]:= m1[0,0]*m2[2,0] + m1[1,0]*m2[2,1] + m1[2,0]*m2[2,2];
Result[2,1]:= m1[0,1]*m2[2,0] + m1[1,1]*m2[2,1] + m1[2,1]*m2[2,2];
Result[2,2]:= m1[0,2]*m2[2,0] + m1[1,2]*m2[2,1] + m1[2,2]*m2[2,2];
Result[2,3]:= 0;

Result[3,0]:= m1[0,0]*m2[3,0] + m1[1,0]*m2[3,1] + m1[2,0]*m2[3,2] + m1[3,0];
Result[3,1]:= m1[0,1]*m2[3,0] + m1[1,1]*m2[3,1] + m1[2,1]*m2[3,2] + m1[3,1];
Result[3,2]:= m1[0,2]*m2[3,0] + m1[1,2]*m2[3,1] + m1[2,2]*m2[3,2] + m1[3,2];
Result[3,3]:= 1;
end;

procedure SGSetMatrixRotation(var Matrix : TSGMatrix4x4;const Angles : TSGVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var cr,sr,cp,sp,cy,sy,
	srsp,crsp         : single;
begin
cr:= cos(angles.Data[0]);
sr:= sin(angles.Data[0]);
cp:= cos(angles.Data[1]);
sp:= sin(angles.Data[1]);
cy:= cos(angles.Data[2]);
sy:= sin(angles.Data[2]);

matrix[0][0]:=cp*cy;
matrix[0][1]:=cp*sy;
matrix[0][2]:=-sp;

srsp:= sr*sp;
crsp:= cr*sp;

matrix[1][0]:= srsp*cy-cr*sy;
matrix[1][1]:= srsp*sy+cr*cy;
matrix[1][2]:= sr*cp;

matrix[2][0]:= crsp*cy+sr*sy;
matrix[2][1]:= crsp*sy-sr*cy;
matrix[2][2]:= cr*cp;
end;

procedure SGSetMatrixTranslation(var Matrix : TSGMatrix4x4; const Trans : TSGVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
 matrix[3,0]:=trans.x;
 matrix[3,1]:=trans.y;
 matrix[3,2]:=trans.z;
end;

function SGGetTranslateMatrix(const Vertex : TSGVertex3f):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGByte;
begin
FillChar(Result,SizeOf(Result),0);
for i:=0 to 3 do
	Result[i,i]:=1;
Result[3,0]:=Vertex.x;
Result[3,1]:=Vertex.y;
Result[3,2]:=Vertex.z;
end;

function SGGetIdentityMatrix():TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGByte;
begin
FillChar(Result,SizeOf(Result),0);
for i:=0 to 3 do
	Result[i,i]:=1;
end;

function SGGetOrthoMatrix(const l,r,b,t,vNear,vFar:TSGMatrix4x4Type):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	m:TSGMatrix4x4;
	i,ii:byte;
begin
Result:=SGMatrix4x4Import(
	2/(r-l),0,0,-((r+l)/(r-l)),
	0,2/(t-b),0,-((t+b)/(t-b)),
	0,0,-2/(vFar-vNear),-((vFar+vNear)/(vFar-vNear)),
	0,0,0,1);
for i:=0 to 3 do
	for ii:=0 to 3 do
		m[i,ii]:=Result[ii,i];
Result:=m;
end;

procedure SGWriteMatrix4x4(const Matrix : TSGMatrix4x4);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGByte;
begin
TextColor(10);
for i:=0 to 15 do
	begin
	Write(PSGMatrix4x4Type(@Matrix)[i]:0:10, ' ');
	if (i + 1) mod 4 = 0 then
		WriteLn();
	end;
TextColor(7);
end;

operator * (const A:TSGVertex3f;const B:TSGMatrix4x4):TSGVertex3f;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C:TSGVertex4f;
begin
C.Import(A.x,A.y,A.z,1);
Result:=C*B;
end;

operator * (const A:TSGVertex4f;const B:TSGMatrix4x4):TSGVertex4f;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
type
	PTSGFloat32 = ^ TSGFloat32;
var
	i,k:TSGWord;
begin
FillChar(Result,Sizeof(Result),0);
for i:=0 to 3 do
	for k:=0 to 3 do
		PTSGFloat32(@Result)[i]+=PTSGFloat32(@A)[k]*B[i,k];
end;

operator * (const A,B:TSGMatrix4x4):TSGMatrix4x4;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i,j,k:byte;
begin
FillChar(Result,Sizeof(Result),0);
for i:=0 to 3 do
	for j:=0 to 3 do
		for k:=0 to 3 do
			Result[i,j]+=A[i,k]*B[k,j];
end;

function SGMatrix4Import(const _0x0,_0x1,_0x2,_0x3,_1x0,_1x1,_1x2,_1x3,_2x0,_2x1,_2x2,_2x3,_3x0,_3x1,_3x2,_3x3:TSGMatrix4x4Type):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result[0,0]:=_0x0;
Result[0,1]:=_0x1;
Result[0,2]:=_0x2;
Result[0,3]:=_0x3;
Result[1,0]:=_1x0;
Result[1,1]:=_1x1;
Result[1,2]:=_1x2;
Result[1,3]:=_1x3;
Result[2,0]:=_2x0;
Result[2,1]:=_2x1;
Result[2,2]:=_2x2;
Result[2,3]:=_2x3;
Result[3,0]:=_3x0;
Result[3,1]:=_3x1;
Result[3,2]:=_3x2;
Result[3,3]:=_3x3;
end;

function SGGetFrustumMatrix(const vleft,vright,vbottom,vtop,vnear,vfar:TSGMatrix4x4Type):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=SGMatrix4Import(
	2.0 * vnear / (vright - vleft), 0, 0, 0,
	0, 2.0 * vnear / (vtop - vbottom), 0, 0,
	(vright + vleft) / (vright - vleft), (vtop + vbottom) / (vtop - vbottom), -(vfar + vnear) / (vfar - vnear), -1.0,
	0,0, -2.0 * vfar * vnear / (vfar - vnear), 0);
end;

function SGGetPerspectiveMatrix(const vAngle,vAspectRatio,vNear,vFar:TSGMatrix4x4Type):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	vTop:Single;
begin
vTop := vNear * Math.tan(vAngle * 3.1415927 / 360.0);
Result:=SGGetFrustumMatrix(
	(-vTop)*vAspectRatio,vTop*vAspectRatio,-vTop,vTop,vNear,vFar);
end;

function SGTranslateMatrix(const VMatrix : TSGMatrix4x4; const VVertex : TSGVertex3f):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := VMatrix;
Result[3,0]:=Result[0,0]*VVertex.x+Result[1,0]*VVertex.y+Result[2,0]*VVertex.z+Result[3,0];
Result[3,1]:=Result[0,1]*VVertex.x+Result[1,1]*VVertex.y+Result[2,1]*VVertex.z+Result[3,1];
Result[3,2]:=Result[0,2]*VVertex.x+Result[1,2]*VVertex.y+Result[2,2]*VVertex.z+Result[3,2];
Result[3,3]:=Result[0,3]*VVertex.x+Result[1,3]*VVertex.y+Result[2,3]*VVertex.z+Result[3,3];
end;

function SGGetLookAtMatrix(const Eve, At:TSGVertex3f;Up:TSGVertex3f):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	vForward,vSide:TSGVertex3f;
begin
vForward :=   (Eve - At).Normalized();
vSide := (Up * vForward).Normalized();
Up := (vForward * vSide).Normalized();
Result := SGMatrix4x4Import(
	vside.x, up.x, vforward.x, 0,
	vside.y, up.y, vforward.y, 0,
	vside.z, up.z, vforward.z, 0,
	0, 0, 0, 1);
Result := SGTranslateMatrix(Result, -Eve);
end;

function SGMatrix4x4Import(const _0x0,_0x1,_0x2,_0x3,_1x0,_1x1,_1x2,_1x3,_2x0,_2x1,_2x2,_2x3,_3x0,_3x1,_3x2,_3x3:TSGMatrix4x4Type):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result[0,0]:=_0x0;
Result[0,1]:=_0x1;
Result[0,2]:=_0x2;
Result[0,3]:=_0x3;
Result[1,0]:=_1x0;
Result[1,1]:=_1x1;
Result[1,2]:=_1x2;
Result[1,3]:=_1x3;
Result[2,0]:=_2x0;
Result[2,1]:=_2x1;
Result[2,2]:=_2x2;
Result[2,3]:=_2x3;
Result[3,0]:=_3x0;
Result[3,1]:=_3x1;
Result[3,2]:=_3x2;
Result[3,3]:=_3x3;
end;

end.
