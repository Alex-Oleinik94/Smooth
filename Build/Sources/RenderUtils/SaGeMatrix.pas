{$INCLUDE SaGe.inc}

unit SaGeMatrix;

interface

uses
	 SaGeBase
	,SaGeCommon
	,SaGeQuaternion
	;

type
	TSGMatrixFloat = TSGCommonFloat;
	PSGMatrixFloat = ^ TSGMatrixFloat;
	TSGMatrixVector2 = TSGCommonVector2;
	TSGMatrixVector3 = TSGCommonVector3;
	TSGMatrixVector4 = TSGCommonVector4;
type
	TSGMatrix4x4Type = TSGMatrixFloat;
	PSGMatrix4x4Type = ^ TSGMatrix4x4Type;
	TSGMatrix4x4 = array [0..3, 0..3] of TSGMatrix4x4Type;
	PSGMatrix4x4 = ^ TSGMatrix4x4;
	TSGMatrix4x4Array = array [0..15] of TSGMatrix4x4Type;
	
	TSGMatrix4x4f = TSGMatrix4x4;
	PSGMatrix4x4f = PSGMatrix4x4;

operator * (const A, B : TSGMatrix4x4) : TSGMatrix4x4;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator = (const A, B : TSGMatrix4x4) : TSGBoolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (const Vector : TSGMatrixVector4; const Matrix : TSGMatrix4x4) : TSGMatrixVector4;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (const Vector3 : TSGMatrixVector3; const Matrix : TSGMatrix4x4) : TSGMatrixVector3; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGMatrix4x4Import(const _0x0, _0x1, _0x2, _0x3, _1x0, _1x1, _1x2, _1x3, _2x0, _2x1, _2x2, _2x3, _3x0, _3x1, _3x2, _3x3 : TSGMatrix4x4Type) : TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetFrustumMatrix(const vleft,vright,vbottom,vtop,vnear,vfar:TSGMatrix4x4Type):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetPerspectiveMatrix(const vAngle,vAspectRatio,vNear,vFar:TSGMatrix4x4Type):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetLookAtMatrix(const Eve, At:TSGMatrixVector3; Up:TSGMatrixVector3):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetOrthoMatrix(const l, r, b, t, vNear, vFar : TSGMatrix4x4Type):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGWriteMatrix4x4(const Matrix : TSGMatrix4x4);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGTranslateMatrix(const Matrix : TSGMatrix4x4; const Vector : TSGMatrixVector3) : TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGMultiplyPartMatrix(const m1:TSGMatrix4x4;const m2:TSGMatrix4x4):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGRotateVectorInverse(const Matrix : TSGMatrix4x4;const Vec : TSGMatrixVector3):TSGMatrixVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGTranslateVectorInverse(const Matrix : TSGMatrix4x4;const Vec : TSGMatrixVector3):TSGMatrixVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGTransformVector(const Matrix : TSGMatrix4x4; const Vec : TSGMatrixVector3):TSGMatrixVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGIdentityMatrix() : TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGRotateMatrix(const Angle : TSGMatrix4x4Type; const Axis : TSGMatrixVector3) : TSGMatrix4x4; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGTranslateMatrix(const Vertex : TSGMatrixVector3) : TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGInverseMatrix(const VSourseMatrix : TSGMatrix4x4) : TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGScaleMatrix(const Vector : TSGMatrixVector3): TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGMatrixDiagonalInverse(const Matrix : TSGMatrix4x4) : TSGMatrix4x4; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SGSetMatrixRotation(var Matrix : TSGMatrix4x4;const Angles : TSGMatrixVector3);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGSetMatrixRotationQuaternion(var Matrix : TSGMatrix4x4;const Quat : TSGQuaternion);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGSetMatrixTranslation(var Matrix : TSGMatrix4x4; const Trans : TSGMatrixVector3);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 Crt
	,Math
	
	,SaGeCommonStructs
	;

operator = (const A, B : TSGMatrix4x4) : TSGBoolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i,ii : TSGUInt8;
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

function SGRotateMatrix(const Angle : TSGMatrix4x4Type; const Axis : TSGMatrixVector3) : TSGMatrix4x4; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
    CosinusAngle, SinusAngle : TSGMatrix4x4Type;
begin
Result := SGIdentityMatrix();
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

function SGScaleMatrix(const Vector : TSGMatrixVector3): TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGIdentityMatrix();
Result[0][0] := Vector.x;
Result[1][1] := Vector.y;
Result[2][2] := Vector.z;
end;

// Инвертирование матрицы
function SGInverseMatrix(const VSourseMatrix : TSGMatrix4x4) : TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function mat(const  i : TSGByte) : TSGFloat; inline;
begin
Result := TSGMatrix4x4Array(VSourseMatrix)[i];
end;

procedure ret(const i : TSGByte; const f : TSGFloat); inline; overload;
begin
TSGMatrix4x4Array(Result)[i] := f;
end;

var
	det,idet : TSGFloat;
begin
det:=((((((((mat(0)*mat(5)*mat(10))+(mat(4)*mat(9)*mat(2))))+(mat(8)*mat(1)*mat(6)))-(mat(8)*mat(5)*mat(2))))-(mat(4)*mat(1)*mat(10)))-(mat(0)*mat(9)*mat(6)));
if abs(det) < 0.0000001 then
	Result := SGIdentityMatrix()
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
	ret(12,-(mat(12)*TSGMatrix4x4Array(Result)[0]+mat(13)*TSGMatrix4x4Array(Result)[4]+mat(14)*TSGMatrix4x4Array(Result)[8]));
	ret(13,-(mat(12)*TSGMatrix4x4Array(Result)[1]+mat(13)*TSGMatrix4x4Array(Result)[5]+mat(14)*TSGMatrix4x4Array(Result)[9]));
	ret(14,-(mat(12)*TSGMatrix4x4Array(Result)[2]+mat(13)*TSGMatrix4x4Array(Result)[6]+mat(14)*TSGMatrix4x4Array(Result)[10]));
	ret(15,1.0);
	end;
end;

function SGTransformVector(const Matrix : TSGMatrix4x4; const Vec : TSGMatrixVector3):TSGMatrixVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Data[0]:= Vec.Data[0]*Matrix[0,0]+Vec.Data[1]*Matrix[1,0]+Vec.Data[2]*Matrix[2,0]+Matrix[3,0];
Result.Data[1]:= Vec.Data[0]*Matrix[0,1]+Vec.Data[1]*Matrix[1,1]+Vec.Data[2]*Matrix[2,1]+Matrix[3,1];
Result.Data[2]:= Vec.Data[0]*Matrix[0,2]+Vec.Data[1]*Matrix[1,2]+Vec.Data[2]*Matrix[2,2]+Matrix[3,2];
end;

function SGTranslateVectorInverse(const Matrix : TSGMatrix4x4;const Vec : TSGMatrixVector3):TSGMatrixVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Data[0]:= Vec.Data[0]-Matrix[3,0];
Result.Data[1]:= Vec.Data[1]-Matrix[3,1];
Result.Data[2]:= Vec.Data[2]-Matrix[3,2];
end;

function SGRotateVectorInverse(const Matrix : TSGMatrix4x4;const Vec : TSGMatrixVector3):TSGMatrixVector3;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

procedure SGSetMatrixRotation(var Matrix : TSGMatrix4x4;const Angles : TSGMatrixVector3);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var cr,sr,cp,sp,cy,sy,
	srsp,crsp         : TSGMatrix4x4Type;
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

procedure SGSetMatrixTranslation(var Matrix : TSGMatrix4x4; const Trans : TSGMatrixVector3);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Matrix[3,0] := Trans.x;
Matrix[3,1] := Trans.y;
Matrix[3,2] := Trans.z;
end;

function SGTranslateMatrix(const Vertex : TSGMatrixVector3):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Index : TSGUInt8;
begin
FillChar(Result, SizeOf(Result), 0);
for Index := 0 to 3 do
	Result[Index, Index] := 1;
Result[3,0] := Vertex.x;
Result[3,1] := Vertex.y;
Result[3,2] := Vertex.z;
end;

function SGIdentityMatrix():TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGByte;
begin
FillChar(Result,SizeOf(Result),0);
for i:=0 to 3 do
	Result[i,i]:=1;
end;

function SGMatrixDiagonalInverse(const Matrix : TSGMatrix4x4) : TSGMatrix4x4; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii : TSGUInt8;
begin
for i := 0 to 3 do
	for ii := 0 to 3 do
		Result[ii, i] := Matrix[i, ii];
end;

function SGGetOrthoMatrix(const l, r, b, t, vNear, vFar : TSGMatrix4x4Type):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGMatrixDiagonalInverse(SGMatrix4x4Import(
	2 / (r - l), 0,           0,                    - ((r + l) / (r - l)),
	0,           2 / (t - b), 0,                    - ((t + b)/(t - b)),
	0,           0,           - 2 / (vFar - vNear), - ((vFar + vNear) / (vFar - vNear)),
	0,           0,           0,                    1));
end;

procedure SGWriteMatrix4x4(const Matrix : TSGMatrix4x4);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGByte;
begin
TextColor(10);
for i := 0 to 15 do
	begin
	Write(TSGMatrix4x4Array(Matrix)[i]:0:10, ' ');
	if (i + 1) mod 4 = 0 then
		WriteLn();
	end;
TextColor(7);
end;

operator * (const Vector3 : TSGMatrixVector3; const Matrix : TSGMatrix4x4) : TSGMatrixVector3; overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Vector4 : TSGMatrixVector4;
begin
Vector4.Import(Vector3.x, Vector3.y, Vector3.z, 1);
Result := Vector4 * Matrix;
end;

operator * (const Vector : TSGMatrixVector4; const Matrix : TSGMatrix4x4) : TSGMatrixVector4;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, k : TSGUInt8;
begin
FillChar(Result, Sizeof(Result), 0);
for i := 0 to 3 do
	for k := 0 to 3 do
		Result.Data[i] += Vector.Data[k] * Matrix[i, k];
end;

operator * (const A,B:TSGMatrix4x4):TSGMatrix4x4;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, j, k: TSGByte;
begin
FillChar(Result,Sizeof(Result),0);
for i:=0 to 3 do
	for j:=0 to 3 do
		for k:=0 to 3 do
			Result[i,j]+=A[i,k]*B[k,j];
end;

function SGGetFrustumMatrix(const vleft,vright,vbottom,vtop,vnear,vfar:TSGMatrix4x4Type):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGMatrix4x4Import(
	2.0 * vnear / (vright - vleft), 0, 0, 0,
	0, 2.0 * vnear / (vtop - vbottom), 0, 0,
	(vright + vleft) / (vright - vleft), (vtop + vbottom) / (vtop - vbottom), -(vfar + vnear) / (vfar - vnear), -1.0,
	0,0, -2.0 * vfar * vnear / (vfar - vnear), 0);
end;

function SGGetPerspectiveMatrix(const vAngle, vAspectRatio, vNear, vFar : TSGMatrix4x4Type) : TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	vTop : TSGMatrixFloat;
begin
vTop := vNear * Math.tan(vAngle * 3.1415927 / 360.0);
Result := SGGetFrustumMatrix(
	(-vTop) * vAspectRatio, vTop * vAspectRatio, -vTop, vTop, vNear, vFar);
end;

function SGTranslateMatrix(const Matrix : TSGMatrix4x4; const Vector : TSGMatrixVector3) : TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Matrix;
Result[3, 0] := Result[0, 0] * Vector.x + Result[1, 0] * Vector.y + Result[2, 0] * Vector.z + Result[3, 0];
Result[3, 1] := Result[0, 1] * Vector.x + Result[1, 1] * Vector.y + Result[2, 1] * Vector.z + Result[3, 1];
Result[3, 2] := Result[0, 2] * Vector.x + Result[1, 2] * Vector.y + Result[2, 2] * Vector.z + Result[3, 2];
Result[3, 3] := Result[0, 3] * Vector.x + Result[1, 3] * Vector.y + Result[2, 3] * Vector.z + Result[3, 3];
end;

function SGGetLookAtMatrix(const Eve, At : TSGMatrixVector3; Up : TSGMatrixVector3) : TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	vForward, vSide : TSGMatrixVector3;
begin
vForward :=   (Eve - At).Normalized();
vSide := (Up * vForward).Normalized();
Up := (vForward * vSide).Normalized();
Result := SGMatrix4x4Import(
	vSide.x, Up.x, vForward.x, 0,
	vSide.y, Up.y, vForward.y, 0,
	vSide.z, Up.z, vForward.z, 0,
	0,       0,    0,          1);
Result := SGTranslateMatrix(Result, - Eve);
end;

function SGMatrix4x4Import(const _0x0, _0x1, _0x2, _0x3, _1x0, _1x1, _1x2, _1x3, _2x0, _2x1, _2x2, _2x3, _3x0, _3x1, _3x2, _3x3 : TSGMatrix4x4Type) : TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result[0, 0] := _0x0;
Result[0, 1] := _0x1;
Result[0, 2] := _0x2;
Result[0, 3] := _0x3;
Result[1, 0] := _1x0;
Result[1, 1] := _1x1;
Result[1, 2] := _1x2;
Result[1, 3] := _1x3;
Result[2, 0] := _2x0;
Result[2, 1] := _2x1;
Result[2, 2] := _2x2;
Result[2, 3] := _2x3;
Result[3, 0] := _3x0;
Result[3, 1] := _3x1;
Result[3, 2] := _3x2;
Result[3, 3] := _3x3;
end;

end.
