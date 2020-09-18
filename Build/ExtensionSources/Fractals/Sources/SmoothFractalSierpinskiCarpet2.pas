{$INCLUDE Smooth.inc}

unit SmoothFractalSierpinskiCarpet2;

interface

uses
	 SmoothBase
	,SmoothCommonStructs
	,SmoothContextInterface
	,SmoothFractalForm
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
	procedure Generate4(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f; var _ObjectNumber, _VertexIndex, _FaceIndex : TSUInt32);
	procedure Generate2(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f; var _ObjectNumber, _VertexIndex, _FaceIndex : TSUInt32);
	procedure Generate1(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f; var _ObjectNumber, _VertexIndex, _FaceIndex : TSUInt32);
		public
	procedure PolygonsConstruction(); override; // fractal construction
	procedure PushPoligonData(var _ObjectNumber, _VertexIndex, _FaceIndex : TSUInt32; const v1, v2, v3, v4 : TSVector2f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF} // adding data to array
	end;

implementation

uses
	 SmoothMathUtils
	,SmoothRenderBase
	,SmoothScreenBase
	;

constructor TSFractalSierpinskiCarpet2.Create(const VContext : ISContext);
begin
inherited Create(VContext);

FIs2D := True;
FPrimetiveType := SR_QUADS;
FPrimetiveParam := 0;
FDepth := 3;

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
	ObjectNumber, VertexIndex, FaceIndex : TSUInt32;
begin
ObjectNumber := 0;
VertexIndex := 0;
FaceIndex := 0;
Generate4(FDepth, TSVector2f.Create(1, 1), TSVector2f.Create(1, -1), TSVector2f.Create(-1, -1), TSVector2f.Create(-1, 1), 
	TSColor3f.Create(1, 0, 0), TSColor3f.Create(0, 1, 0), TSColor3f.Create(0, 0, 1), TSColor3f.Create(1, 1, 0),
	ObjectNumber, VertexIndex, FaceIndex);
EndOfPolygonsConstruction(ObjectNumber);
end;

procedure TSFractalSierpinskiCarpet2.PushPoligonData(var _ObjectNumber, _VertexIndex, _FaceIndex : TSUInt32; const v1, v2, v3, v4 : TSVector2f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
_VertexIndex+=4;
if not (Render.RenderType in [SRenderDirectX9, SRenderDirectX8]) then
	begin
	F3dObject.Objects[_ObjectNumber].ArVertex2f[_VertexIndex-4]^:=v1;
	F3dObject.Objects[_ObjectNumber].ArVertex2f[_VertexIndex-3]^:=v2;
	F3dObject.Objects[_ObjectNumber].ArVertex2f[_VertexIndex-2]^:=v3;
	F3dObject.Objects[_ObjectNumber].ArVertex2f[_VertexIndex-1]^:=v4;
	end
else
	begin
	F3dObject.Objects[_ObjectNumber].ArVertex3f[_VertexIndex-4]^.Import(v1.x,v1.y);
	F3dObject.Objects[_ObjectNumber].ArVertex3f[_VertexIndex-3]^.Import(v2.x,v2.y);
	F3dObject.Objects[_ObjectNumber].ArVertex3f[_VertexIndex-2]^.Import(v3.x,v3.y);
	F3dObject.Objects[_ObjectNumber].ArVertex3f[_VertexIndex-1]^.Import(v4.x,v4.y);
	end;

F3dObject.Objects[_ObjectNumber].SetFaceQuad(0,_FaceIndex+0,_VertexIndex-1,_VertexIndex-2,_VertexIndex-3,_VertexIndex-4);
_FaceIndex+=1;

AfterPushingPoligonData(_ObjectNumber,FThreadsEnable,_VertexIndex,_FaceIndex);
end;

procedure TSFractalSierpinskiCarpet2.Generate4(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f; var _ObjectNumber, _VertexIndex, _FaceIndex : TSUInt32);
begin
if _Depth = 0 then
	Generate1(_Depth, _v1, _v2, _v3, _v4, _c1, _c2, _c3, _c4, _ObjectNumber, _VertexIndex, _FaceIndex)
else
	begin
	Generate2(_Depth, _v1, _v2, _v3, _v4, _c1, _c2, _c3, _c4, _ObjectNumber, _VertexIndex, _FaceIndex);
	Generate2(_Depth, _v4, _v1, _v2, _v3, _c4, _c1, _c2, _c3, _ObjectNumber, _VertexIndex, _FaceIndex);
	end;
end;

procedure TSFractalSierpinskiCarpet2.Generate2(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f; var _ObjectNumber, _VertexIndex, _FaceIndex : TSUInt32);
begin
Generate1(_Depth, _v1, (_v2 - _v1) / 3 + _v1, _v3, (_v3 - _v4) / 3 + _v4, _c1, (_c2 - _c1) / 3 + _c1, _c3, (_c3 - _c4) / 3 + _c4, _ObjectNumber, _VertexIndex, _FaceIndex);
Generate1(_Depth, (_v1 - _v2) / 3 + _v2, _v2, _v3, (_v4 - _v3) / 3 + _v3, (_c1 - _c2) / 3 + _c2, _c2, _c3, (_c4 - _c3) / 3 + _c3, _ObjectNumber, _VertexIndex, _FaceIndex);
end;

procedure TSFractalSierpinskiCarpet2.Generate1(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f; var _ObjectNumber, _VertexIndex, _FaceIndex : TSUInt32);
begin
if _Depth = 0 then
	PushPoligonData(_ObjectNumber, _VertexIndex, _FaceIndex, _v1, _v2, _v3, _v4)
else
	begin
	// constructing...
	end;
end;

end.