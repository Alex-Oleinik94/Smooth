{$INCLUDE Smooth.inc}

unit SmoothFractalMengerSponge2;

interface

uses
	 SmoothBase
	,SmoothCommonStructs
	,Smooth3DFractal
	,Smooth3DFractalForm
	,SmoothContextInterface
	,SmoothScreenClasses
	;

type
	TSMengerSpongeVectors = packed array[0..7] of TSVector3f;
	TSMengerSpongePolygonsSigns = array[0..5] of TSBool;
const
	MengerSpongePolygonsSignsFalse : TSMengerSpongePolygonsSigns = (False, False, False, False, False, False);
	MengerSpongePolygonsSignsTrue : TSMengerSpongePolygonsSigns = (True, True, True, True, True, True);
type
	TSFractalMengerSponge2 = class(TS3DFractalForm)
		public
	constructor Create(const VContext : ISContext); override;
	destructor Destroy(); override;
	class function ClassName():TSString; override;
		protected //Construct Sierpinski Carpet
	procedure Generate4(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector3f; const _NormalIndex : TSMaxEnum; var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt);
	procedure Generate2(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector3f; const _NormalIndex : TSMaxEnum; var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt);
	procedure Generate1(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector3f; const _NormalIndex : TSMaxEnum; var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt);
		protected
	class function CountingTheNumberOfPolygons(const _Depth : TSMaxEnum) : TSMaxEnum; override; // counting the number of polygons
	class function CountingTheNumberOfPolygonsMengerSponge(const _PolygonsSigns : TSMengerSpongePolygonsSigns; const _Depth : TSMaxEnum) : TSMaxEnum;
	class function ValidIndexes(const _Index1, _Index2, _Index3 : TSMaxEnum) : TSBoolean;
	class function CountingTheNumberOfPolygonsSierpinskiCarpet(const _Depth : TSMaxEnum) : TSMaxEnum;
	class function ConstructPolygonsSigns(const _Index1, _Index2, _Index3 : TSMaxEnum) : TSMengerSpongePolygonsSigns;
	class function ConstructCube(const _Cube : TSMengerSpongeVectors; const _Index1, _Index2, _Index3 : TSMaxEnum) : TSMengerSpongeVectors;
	procedure ConstructMengerSponge(const _Depth : TSMaxEnum; _Cube : TSMengerSpongeVectors; const _PolygonsSigns : TSMengerSpongePolygonsSigns; var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt);
	procedure PushPolygonData(var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt; const v1, v2, v3, v4 : TSVector3f; const _NormalIndex : TSMaxEnum);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		protected
	FNormals : packed array [0..5] of TSVector3f;
	FObjectSize : TSFloat32;
		public
	procedure PolygonsConstruction(); override; // fractal construction
	end;

implementation

uses
	 SmoothArithmeticUtils
	,SmoothStringUtils
	,SmoothScreenBase
	,SmoothRenderBase
	,SmoothThreads
	,SmoothFileUtils
	;

class function TSFractalMengerSponge2.ConstructCube(const _Cube : TSMengerSpongeVectors; const _Index1, _Index2, _Index3 : TSMaxEnum) : TSMengerSpongeVectors;
var
	CubeSize : TSFloat32;
begin
CubeSize := Abs(_Cube[1] - _Cube[0]) / 3;
Result[0] := _Cube[0] + TSVector3f.Create(_Index1 * CubeSize, _Index2 * CubeSize, _Index3 * CubeSize);
Result[1] := Result[0] + TSVector3f.Create(CubeSize, 0, 0);
Result[2] := Result[0] + TSVector3f.Create(CubeSize, 0, CubeSize);
Result[3] := Result[0] + TSVector3f.Create(0, 0, CubeSize);
Result[4] := Result[0] + TSVector3f.Create(0, CubeSize, 0);
Result[5] := Result[0] + TSVector3f.Create(CubeSize, CubeSize, 0);
Result[6] := Result[0] + TSVector3f.Create(CubeSize, CubeSize, CubeSize);
Result[7] := Result[0] + TSVector3f.Create(0, CubeSize, CubeSize);
end;

procedure TSFractalMengerSponge2.ConstructMengerSponge(const _Depth : TSMaxEnum; _Cube : TSMengerSpongeVectors; const _PolygonsSigns : TSMengerSpongePolygonsSigns; var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt);
var
	Index, Index2, Index3 : TSMaxEnum;
begin
if _PolygonsSigns[0] then
	Generate4(_Depth, _Cube[0], _Cube[1], _Cube[2], _Cube[3], 0, _ObjectNumber, _VertexIndex, _FaceIndex);
if _PolygonsSigns[1] then
	Generate4(_Depth, _Cube[0], _Cube[1], _Cube[5], _Cube[4], 1, _ObjectNumber, _VertexIndex, _FaceIndex);
if _PolygonsSigns[2] then
	Generate4(_Depth, _Cube[1], _Cube[2], _Cube[6], _Cube[5], 2, _ObjectNumber, _VertexIndex, _FaceIndex);
if _PolygonsSigns[3] then
	Generate4(_Depth, _Cube[2], _Cube[3], _Cube[7], _Cube[6], 3, _ObjectNumber, _VertexIndex, _FaceIndex);
if _PolygonsSigns[4] then
	Generate4(_Depth, _Cube[3], _Cube[0], _Cube[4], _Cube[7], 4, _ObjectNumber, _VertexIndex, _FaceIndex);
if _PolygonsSigns[5] then
	Generate4(_Depth, _Cube[6], _Cube[7], _Cube[4], _Cube[5], 5, _ObjectNumber, _VertexIndex, _FaceIndex);
if (_Depth > 0) then
	for Index := 0 to 2 do
		for Index2 := 0 to 2 do
			for Index3 := 0 to 2 do
				if ValidIndexes(Index, Index2, Index3) then
					ConstructMengerSponge(_Depth - 1,
						ConstructCube(_Cube, Index, Index2, Index3),
						ConstructPolygonsSigns(Index, Index2, Index3),
						_ObjectNumber, _VertexIndex, _FaceIndex);
end;

procedure TSFractalMengerSponge2.PolygonsConstruction();
var
	ObjectNumber, VertexIndex, FaceIndex : TSFractalIndexInt;
	Cube : TSMengerSpongeVectors;
	Index : TSMaxEnum;
	VectorScale :TSFloat32;
begin
ObjectNumber := 0;
VertexIndex := 0;
FaceIndex := 0;
VectorScale := FObjectSize / 2;
Cube[0] := TSVector3f.Create(-VectorScale, -VectorScale, -VectorScale);
Cube[1] := TSVector3f.Create(VectorScale, -VectorScale, -VectorScale);
Cube[2] := TSVector3f.Create(VectorScale, -VectorScale, VectorScale);
Cube[3] := TSVector3f.Create(-VectorScale, -VectorScale, VectorScale);
Cube[4] := TSVector3f.Create(-VectorScale, VectorScale, -VectorScale);
Cube[5] := TSVector3f.Create(VectorScale, VectorScale, -VectorScale);
Cube[6] := TSVector3f.Create(VectorScale, VectorScale, VectorScale);
Cube[7] := TSVector3f.Create(-VectorScale, VectorScale, VectorScale);
ConstructMengerSponge(Depth, Cube, MengerSpongePolygonsSignsTrue, ObjectNumber, VertexIndex, FaceIndex);
EndOfPolygonsConstruction(ObjectNumber);
end;

//procedure Generate4 = Generate2 + Generate2
//procedure Generate2 = Generate1 + Generate1
//procedure Generate1 = цикл построения четвёртой части фрактала + двойной цикл с заплатками Generate2
//procedure Generate4(0) = Generate1(0)
//    Generate4
// v1..v2    ##..##     ######    ######
// ...... is ##..## and ...... or ###### if 0
// v4..v3    ##..##     ######    ######
//    Generate2
// v1..v2    ##..##
// ...... is ##..##
// v4..v3    ##..##
//    Generate1
// v1..v2                         ##    ######
// ...... is fractal construction ## or ###### if 0
// v4..v3  
procedure TSFractalMengerSponge2.Generate4(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector3f; const _NormalIndex : TSMaxEnum; var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt);
begin
if _Depth = 0 then
	Generate1(_Depth, _v1, _v2, _v3, _v4, _NormalIndex, _ObjectNumber, _VertexIndex, _FaceIndex)
else
	begin
	Generate2(_Depth, _v1, _v2, _v3, _v4, _NormalIndex, _ObjectNumber, _VertexIndex, _FaceIndex);
	Generate2(_Depth, _v2, _v3, _v4, _v1, _NormalIndex, _ObjectNumber, _VertexIndex, _FaceIndex);
	end;
end;

procedure TSFractalMengerSponge2.Generate2(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector3f; const _NormalIndex : TSMaxEnum; var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt);
begin
Generate1(_Depth, _v1, (_v1 * 2 + _v2)/3, (_v4 * 2 + _v3)/3, _v4, _NormalIndex, _ObjectNumber, _VertexIndex, _FaceIndex);
Generate1(_Depth, (_v2 * 2 + _v1)/3, _v2, _v3, (_v3 * 2 + _v4)/3, _NormalIndex, _ObjectNumber, _VertexIndex, _FaceIndex);
end;

procedure TSFractalMengerSponge2.Generate1(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector3f; const _NormalIndex : TSMaxEnum; var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt);
// 0 1 2 3  4   5    ...
// 1 1 4 24 176 1376 ...

procedure Generate(const _Depth, _Depth2 : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector3f; const _NormalIndex : TSMaxEnum);
var
	PatchNumber, DivNumber : TSInt64;
	Index : TSMaxEnum;
	Step : TSVector3f;
begin
if (_Depth2 = 0) then
	PushPolygonData(_ObjectNumber, _VertexIndex, _FaceIndex, _v1, _v2, _v3, _v4, _NormalIndex)
else
	begin
	Generate(_Depth, _Depth2 - 1, _v1, (_v1 * 2 + _v2)/3, (_v4 * 2 + _v3)/3, _v4, _NormalIndex);
	Generate(_Depth, _Depth2 - 1, (_v2 * 2 + _v1)/3, _v2, _v3, (_v3 * 2 + _v4)/3, _NormalIndex);
	PatchNumber := 3 ** (_Depth - _Depth2 - 1);
	DivNumber := 3 * PatchNumber;
	Step := (_v4 - _v1) / DivNumber;
	for Index := 1 to PatchNumber do
		Generate2(_Depth2,
		_v2 + Step * 3 * (Index - 1) + Step,
		_v2 + Step * 3 * (Index - 1) + Step * 2,
		_v1 + Step * 3 * (Index - 1) + Step * 2,
		_v1 + Step * 3 * (Index - 1) + Step,
		_NormalIndex, _ObjectNumber, _VertexIndex, _FaceIndex);
	end;
end;

begin
if (_Depth = 0) or (_Depth = 1) then
	PushPolygonData(_ObjectNumber, _VertexIndex, _FaceIndex, _v1, _v2, _v3, _v4, _NormalIndex)
else
	Generate(_Depth, _Depth - 1, _v1, _v2, _v3, _v4, _NormalIndex); // constructing..
end;

procedure TSFractalMengerSponge2.PushPolygonData(var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt; const v1, v2, v3, v4 : TSVector3f; const _NormalIndex : TSMaxEnum);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	VectorScale : TSFloat32;
begin
_VertexIndex+=4;
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex - 4, v1);
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex - 3, v2);
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex - 2, v3);
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex - 1, v4);

if FEnableColors then
	begin
	VectorScale := FObjectSize / 2;
	F3dObject.Objects[_ObjectNumber].SetColor(_VertexIndex - 4, (v1 + TSVector3f.Create(VectorScale, VectorScale, VectorScale)) / FObjectSize);
	F3dObject.Objects[_ObjectNumber].SetColor(_VertexIndex - 3, (v2 + TSVector3f.Create(VectorScale, VectorScale, VectorScale)) / FObjectSize);
	F3dObject.Objects[_ObjectNumber].SetColor(_VertexIndex - 2, (v3 + TSVector3f.Create(VectorScale, VectorScale, VectorScale)) / FObjectSize);
	F3dObject.Objects[_ObjectNumber].SetColor(_VertexIndex - 1, (v4 + TSVector3f.Create(VectorScale, VectorScale, VectorScale)) / FObjectSize);
	end;

if FEnableNormals then
	begin
	F3dObject.Objects[_ObjectNumber].ArNormal[_VertexIndex - 4]^ := FNormals[_NormalIndex];
	F3dObject.Objects[_ObjectNumber].ArNormal[_VertexIndex - 3]^ := FNormals[_NormalIndex];
	F3dObject.Objects[_ObjectNumber].ArNormal[_VertexIndex - 2]^ := FNormals[_NormalIndex];
	F3dObject.Objects[_ObjectNumber].ArNormal[_VertexIndex - 1]^ := FNormals[_NormalIndex];
	end;

F3dObject.Objects[_ObjectNumber].SetFaceQuad(0, _FaceIndex, _VertexIndex - 1, _VertexIndex - 2, _VertexIndex - 3, _VertexIndex - 4);
_FaceIndex+=1;

AfterPushingPolygonData(_ObjectNumber, FThreadsEnable, _VertexIndex, _FaceIndex);
end;

class function TSFractalMengerSponge2.ConstructPolygonsSigns(const _Index1, _Index2, _Index3 : TSMaxEnum) : TSMengerSpongePolygonsSigns;
begin
Result := MengerSpongePolygonsSignsFalse;
if (_Index1 = 1) or (_Index2 = 1) or (_Index3 = 1) then
	begin
	if _Index1 = 1 then
		begin
		Result[2] := False;
		Result[4] := False;
		end;
	if _Index2 = 1 then
		begin
		Result[0] := False;
		Result[5] := False;
		end;
	if _Index3 = 1 then
		begin
		Result[1] := False;
		Result[3] := False;
		end;
	if _Index1 = 0 then
		Result[2] := True;
	if _Index2 = 0 then
		Result[5] := True;
	if _Index3 = 0 then
		Result[3] := True;
	if _Index1 = 2 then
		Result[4] := True;
	if _Index2 = 2 then
		Result[0] := True;
	if _Index3 = 2 then
		Result[1] := True;
	end
else
	begin
	if _Index1 = 0 then
		Result[2] := False;
	if _Index2 = 0 then
		Result[5] := False;
	if _Index3 = 0 then
		Result[3] := False;
	if _Index1 = 2 then
		Result[4] := False;
	if _Index2 = 2 then
		Result[0] := False;
	if _Index3 = 2 then
		Result[1] := False;
	end;
end;

class function TSFractalMengerSponge2.CountingTheNumberOfPolygons(const _Depth : TSMaxEnum) : TSMaxEnum;
begin
Result := CountingTheNumberOfPolygonsMengerSponge(MengerSpongePolygonsSignsTrue, _Depth);
end;

class function TSFractalMengerSponge2.ValidIndexes(const _Index1, _Index2, _Index3 : TSMaxEnum) : TSBoolean;
begin
Result := not (((_Index1 = 1) and (_Index2 = 1)) or ((_Index1 = 1) and (_Index3 = 1)) or ((_Index2 = 1) and (_Index3 = 1)));
end;

class function TSFractalMengerSponge2.CountingTheNumberOfPolygonsMengerSponge(const _PolygonsSigns : TSMengerSpongePolygonsSigns; const _Depth : TSMaxEnum) : TSMaxEnum;
var
	Index, Index2, Index3 : TSMaxEnum;
begin
{MS0=6
MS1=48
MS2=672
MS3=12480
MS4=244608
MS5=4857600}
Result := 0;
for Index := 0 to 5 do
	if _PolygonsSigns[Index] then
		Result += CountingTheNumberOfPolygonsSierpinskiCarpet(_Depth);
if _Depth > 0 then
	for Index := 0 to 2 do
		for Index2 := 0 to 2 do
			for Index3 := 0 to 2 do
				if ValidIndexes(Index, Index2, Index3) then
					Result += CountingTheNumberOfPolygonsMengerSponge(ConstructPolygonsSigns(Index, Index2, Index3), _Depth - 1);
end;

class function TSFractalMengerSponge2.CountingTheNumberOfPolygonsSierpinskiCarpet(const _Depth : TSMaxEnum) : TSMaxEnum;

function Counting1(const _Depth : TSMaxEnum) : TSMaxEnum;
var
	ResultsOfFunction : packed array of TSUInt64 = nil;
	Index, Index2 : TSMaxEnum;
begin
// C(n) = 2^(n-1) + SUM(1..n-1, C(n-k) * 2 * 6^(k-1))
SetLength(ResultsOfFunction, _Depth + 1);
ResultsOfFunction[0] := 1;
Index := 1;
while Index <= _Depth do
	begin
	ResultsOfFunction[Index] := 2**(Index-1);
	Index2 := 1;
	while Index2 < Index do
		begin
		ResultsOfFunction[Index] += ResultsOfFunction[Index - Index2] * 2 * (6**(Index2 - 1));
		Index2 += 1;
		end;
	Index += 1;
	end;
Result := ResultsOfFunction[_Depth];
SetLength(ResultsOfFunction, 0);
end;

function Counting2(const _Depth : TSMaxEnum) : TSMaxEnum;
begin
Result := Counting1(_Depth) * 2;
end;

function Counting4(const _Depth : TSMaxEnum) : TSMaxEnum;
begin
// В пределе каждое следующее значение функции больше предыдущего в 8 раз (похоже на функцию из предыдущего способа реализации)
// Предел отношения эффективности 83,(3)%
if _Depth = 0 then
	Result := Counting1(_Depth)
else
	Result := Counting2(_Depth) * 2;
end;

begin
Result := Counting4(_Depth);
end;

constructor TSFractalMengerSponge2.Create(const VContext : ISContext);
begin
inherited Create(VContext);

EnableColors := True;
EnableNormals := True;
Is2D := False;
FPrimetiveType := SR_QUADS;
FPrimetiveParam := 0;
Threads := {$IFDEF ANDROID} 0 {$ELSE} 1 {$ENDIF};
Depth := 3;
FObjectSize := 5;

if FEnableNormals then
	begin
	FNormals[0] := TSVector3f.Create(0,1,0).Normalized();
	FNormals[1] := TSVector3f.Create(0,0,1).Normalized();
	FNormals[2] := TSVector3f.Create(-1,0,0).Normalized();
	FNormals[3] := TSVector3f.Create(0,0,-1).Normalized();
	FNormals[4] := TSVector3f.Create(1,0,0).Normalized();
	FNormals[5] := TSVector3f.Create(0,-1,0).Normalized();
	end;

Construct();
end;

destructor TSFractalMengerSponge2.Destroy();
begin
inherited;
end;

class function TSFractalMengerSponge2.ClassName():TSString;
begin
Result := 'Губка Менгера 2';
end;

end.
