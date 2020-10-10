{$INCLUDE Smooth.inc}

unit SmoothFractalSierpinskiCarpet2;

interface

uses
	 SmoothBase
	,SmoothCommonStructs
	,SmoothContextInterface
	,Smooth3DFractal
	,Smooth3DFractalForm
	,SmoothScreenClasses
	;

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
// v4..v3                         ##    ######

type
	TSFractalSierpinskiCarpet2 = class(TS3DFractalForm)
		public
	constructor Create(const VContext : ISContext); override;
	destructor Destroy(); override;
	class function ClassName():TSString; override;
		protected
	class function CountingTheNumberOfPolygons(const _Depth : TSMaxEnum) : TSMaxEnum; override; // counting the number of polygons
		protected
	procedure Generate4(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f; var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt);
	procedure Generate2(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f; var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt);
	procedure Generate1(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f; var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt);
		public
	procedure PolygonsConstruction(); override; // fractal construction
	procedure PushPolygonData(var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt; const v1, v2, v3, v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF} // adding data to array
	end;

implementation

uses
	 SmoothArithmeticUtils
	,SmoothRenderBase
	,SmoothScreenBase
	;

constructor TSFractalSierpinskiCarpet2.Create(const VContext : ISContext);
begin
inherited Create(VContext);

FEnableColors := True;
FIs2D := True;
FPrimetiveType := SR_QUADS;
FPrimetiveParam := 0;
Threads:={$IFDEF ANDROID}0{$ELSE}1{$ENDIF};
Depth := 4;

Construct();
end;

destructor TSFractalSierpinskiCarpet2.Destroy();
begin
inherited;
end;

class function TSFractalSierpinskiCarpet2.ClassName():TSString;
begin
Result := 'Ковёр Серпинского 2';
end;

class function TSFractalSierpinskiCarpet2.CountingTheNumberOfPolygons(const _Depth : TSMaxEnum) : TSMaxEnum; // counting the number of polygons

function Counting1(const _Depth : TSMaxEnum) : TSMaxEnum;
var
	ResultsOfFunction : packed array of TSUInt64 = nil;
	Index, Index2 : TSMaxEnum;
begin
// Counting1(Index)...
// 0) 1 (if else)
// 1) 1
// 2) 2  + Counting2(Index - 1) = 2 + 2 = 4
// 3) 4  + Counting2(Index - 1) + Counting2(Index - 2) * 2 * 3 = 4 + 8 + 12 = 24
// 4) 8  + Counting2(Index - 1) + Counting2(Index - 2) * 6 + Counting2(Index - 3) * 6 * 2 * 3 = 8 + 48 + 48 + 72 = 176
// 5) 16 + Counting2(Index - 1) + Counting2(Index - 2) * 6 + Counting2(Index - 3) * 36 + Counting2(Index - 4) * 36 * 2 * 3 = 16 + 352 + 288 + 288 + 432 = 1376
// n) C(n) = 2^(n-1) + C(n-1) * 2 * 6^0 + C(n-2) * 2 * 6^1 + C(n-3) * 2 * 6^2 + C(n-4) * 2 * 6^3 + C(n-5) * 2 * 6^4 + ... + C(n-k) * 2 * 6^(k-1)
// n) C(n) = 2^(n-1) + SUM(1..n-1, C(n-k) * 2 * 6^(k-1))
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
//  0 одинакого
//  1 лучше на 50%
//  2 лучше на 75%
//  3 лучше на 81,25%
//  4 лучше на 82,8125%
//  5 лучше на 83,203125%
//  6 лучше на 83,30078125%
//  7 лучше на 83,3251953125%
//  8 лучше на 83,331298828125%
//  9 лучше на 83,33282470703125%
// 10 лучше на 83,33320617675781%
// Предел отношения эффективности 83,(3)%
//  9 лучше в 5,999816900119015 раз
// 10 лучше в 5,999954223982056 раз
// 11 лучше в 5,999988555930031 раз
// В пределе лучше в 6 раз
if _Depth = 0 then
	Result := Counting1(_Depth)
else
	Result := Counting2(_Depth) * 2;
end;

begin
Result := Counting4(_Depth);
end;

procedure TSFractalSierpinskiCarpet2.PolygonsConstruction();
var
	ObjectNumber, VertexIndex, FaceIndex, ObjectSize : TSFractalIndexInt;
begin
ObjectNumber := 0;
VertexIndex := 0;
FaceIndex := 0;
ObjectSize := 4;
Generate4(FDepth,
	TSVector2f.Create(1, 1) * ObjectSize, TSVector2f.Create(1, -1) * ObjectSize, TSVector2f.Create(-1, -1) * ObjectSize, TSVector2f.Create(-1, 1) * ObjectSize, 
	TSColor3f.Create(1, 0, 0), TSColor3f.Create(0, 1, 0), TSColor3f.Create(0, 0, 1), TSColor3f.Create(1, 1, 1),
	ObjectNumber, VertexIndex, FaceIndex);
EndOfPolygonsConstruction(ObjectNumber);
end;

procedure TSFractalSierpinskiCarpet2.PushPolygonData(var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt; const v1, v2, v3, v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
_VertexIndex+=4;
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex - 4, v1);
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex - 3, v2);
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex - 2, v3);
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex - 1, v4);

if FEnableColors then
	begin
	F3dObject.Objects[_ObjectNumber].SetColor(_VertexIndex - 4, _c1);
	F3dObject.Objects[_ObjectNumber].SetColor(_VertexIndex - 3, _c2);
	F3dObject.Objects[_ObjectNumber].SetColor(_VertexIndex - 2, _c3);
	F3dObject.Objects[_ObjectNumber].SetColor(_VertexIndex - 1, _c4);
	end;

F3dObject.Objects[_ObjectNumber].SetFaceQuad(0, _FaceIndex, _VertexIndex - 1, _VertexIndex - 2, _VertexIndex - 3, _VertexIndex - 4);
_FaceIndex+=1;

AfterPushingPolygonData(_ObjectNumber, FThreadsEnable, _VertexIndex, _FaceIndex);
end;

procedure TSFractalSierpinskiCarpet2.Generate4(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f; var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt);
begin
if _Depth = 0 then
	Generate1(_Depth, _v1, _v2, _v3, _v4, _c1, _c2, _c3, _c4, _ObjectNumber, _VertexIndex, _FaceIndex)
else
	begin
	Generate2(_Depth, _v1, _v2, _v3, _v4, _c1, _c2, _c3, _c4, _ObjectNumber, _VertexIndex, _FaceIndex);
	Generate2(_Depth, _v2, _v3, _v4, _v1, _c2, _c3, _c4, _c1, _ObjectNumber, _VertexIndex, _FaceIndex);
	end;
end;

procedure TSFractalSierpinskiCarpet2.Generate2(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f; var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt);
begin
Generate1(_Depth, _v1, (_v1 * 2 + _v2)/3, (_v4 * 2 + _v3)/3, _v4, _c1, (_c1 * 2 + _c2)/3, (_c4 * 2 + _c3)/3, _c4, _ObjectNumber, _VertexIndex, _FaceIndex);
Generate1(_Depth, (_v2 * 2 + _v1)/3, _v2, _v3, (_v3 * 2 + _v4)/3, (_c2 * 2 + _c1)/3, _c2, _c3, (_c3 * 2 + _c4)/3, _ObjectNumber, _VertexIndex, _FaceIndex);
end;

procedure TSFractalSierpinskiCarpet2.Generate1(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f; var _ObjectNumber, _VertexIndex, _FaceIndex : TSFractalIndexInt);
// 0 1 2 3  4   5    ...
// 1 1 4 24 176 1376 ...

procedure Generate(const _Depth, _Depth2 : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f);
var
	PatchNumber, DivNumber : TSInt64;
	Index : TSMaxEnum;
	Step : TSVector2f;
	StepC41, StepC32 : TSVector3f;
begin
if (_Depth2 = 0) then
	PushPolygonData(_ObjectNumber, _VertexIndex, _FaceIndex, _v1, _v2, _v3, _v4, _c1, _c2, _c3, _c4)
else
	begin
	Generate(_Depth, _Depth2 - 1, _v1, (_v1 * 2 + _v2)/3, (_v4 * 2 + _v3)/3, _v4, _c1, (_c1 * 2 + _c2)/3, (_c4 * 2 + _c3)/3, _c4);
	Generate(_Depth, _Depth2 - 1, (_v2 * 2 + _v1)/3, _v2, _v3, (_v3 * 2 + _v4)/3, (_c2 * 2 + _c1)/3, _c2, _c3, (_c3 * 2 + _c4)/3);
	PatchNumber := 3**(_Depth - _Depth2 - 1);
	DivNumber := 3*PatchNumber;
	Step := (_v4 - _v1)/DivNumber;
	StepC41 := (_c4 - _c1)/DivNumber;
	StepC32 := (_c3 - _c2)/DivNumber;
	for Index := 1 to PatchNumber do
		Generate2(_Depth2, 
		//(_v1 * (1 + Index * 3) + _v4 * (DivNumber - (Index + 1) * 3 - 2))/DivNumber - _v1,
		//(_v2 * (1 + Index * 3) + _v3 * (DivNumber - (Index + 1) * 3 - 2))/DivNumber - _v2,
		//(_v2 * (2 + Index * 3) + _v3 * (DivNumber - (Index + 1) * 3 - 1))/DivNumber - _v2,
		//(_v1 * (2 + Index * 3) + _v4 * (DivNumber - (Index + 1) * 3 - 1))/DivNumber - _v1,
		_v2 + Step * 3 * (Index - 1) + Step,
		_v2 + Step * 3 * (Index - 1) + Step * 2,
		_v1 + Step * 3 * (Index - 1) + Step * 2,
		_v1 + Step * 3 * (Index - 1) + Step,
		
		_c2 + StepC32 * 3 * (Index - 1) + StepC32,
		_c2 + StepC32 * 3 * (Index - 1) + StepC32 * 2,
		_c1 + StepC41 * 3 * (Index - 1) + StepC41 * 2,
		_c1 + StepC41 * 3 * (Index - 1) + StepC41,
		_ObjectNumber, _VertexIndex, _FaceIndex);
	end;
end;

begin
if (_Depth = 0) or (_Depth = 1) then
	PushPolygonData(_ObjectNumber, _VertexIndex, _FaceIndex, _v1, _v2, _v3, _v4, _c1, _c2, _c3, _c4)
else
	// constructing...
	Generate(_Depth, _Depth - 1, _v1, _v2, _v3, _v4, _c1, _c2, _c3, _c4);
end;

end.