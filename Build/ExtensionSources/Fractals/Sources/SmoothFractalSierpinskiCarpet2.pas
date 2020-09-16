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
//procedure Generate4(0) = Generate2(0) = Generate1(0)
//    Generate4
// v1..v2    ##..##     ######    ######
// ...... is ##..## and ...... or ###### if 0
// v4..v3    ##..##     ######    ######
//    Generate2
// v1..v2    ##..##    ######
// ...... is ##..## or ###### if 0
// v4..v3    ##..##    ######
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
	function RecQuantity(const RecDepth : TSMaxEnum) : TSMaxEnum; override; // counting the number of polygons
		protected
	procedure Generate4(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f; var _ObjectNumber, _VertexIndex, _FaceIndex : TSUInt32);
	procedure Generate2(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f; var _ObjectNumber, _VertexIndex, _FaceIndex : TSUInt32);
	procedure Generate1(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f; var _ObjectNumber, _VertexIndex, _FaceIndex : TSUInt32);
		public
	procedure CalculateFromThread(); override; // fractal construction
	procedure AddData(var _ObjectNumber, _VertexIndex, _FaceIndex : TSUInt32; const v1, v2, v3, v4 : TSVector2f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF} // adding data to array
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

Calculate();
end;

destructor TSFractalSierpinskiCarpet2.Destroy();
begin
inherited;
end;

class function TSFractalSierpinskiCarpet2.ClassName():TSString;
begin
Result := 'Ковёр Серпинского 2';
end;

function TSFractalSierpinskiCarpet2.RecQuantity(const RecDepth : TSMaxEnum) : TSMaxEnum; // counting the number of polygons

function Counting1(const _Depth : TSMaxEnum) : TSMaxEnum;
begin
// counting...
end;

function Counting2(const _Depth : TSMaxEnum) : TSMaxEnum;
begin
Result := Counting1(_Depth) * 2;
end;

function Counting4(const _Depth : TSMaxEnum) : TSMaxEnum;
begin
if _Depth = 0 then
	Result := 1
else
	Result := Counting2(_Depth - 1) * 2;
end;

begin
Result := Counting4(FDepth);
end;

procedure TSFractalSierpinskiCarpet2.CalculateFromThread();
var
	ObjectNumber, VertexIndex, FaceIndex : TSUInt32;
begin
Generate4(FDepth, TSVector2f.Create(1, 1), TSVector2f.Create(1, -1), TSVector2f.Create(-1, -1), TSVector2f.Create(-1, 1), 
	TSColor3f.Create(1, 0, 0), TSColor3f.Create(0, 1, 0), TSColor3f.Create(0, 0, 1), TSColor3f.Create(1, 1, 0),
	ObjectNumber, VertexIndex, FaceIndex);
end;

procedure TSFractalSierpinskiCarpet2.AddData(var _ObjectNumber, _VertexIndex, _FaceIndex : TSUInt32; const v1, v2, v3, v4 : TSVector2f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

AfterPushIndexes(_ObjectNumber,FThreadsEnable,_VertexIndex,_FaceIndex);
end;

procedure TSFractalSierpinskiCarpet2.Generate4(const _Depth : TSMaxEnum; const _v1, _v2, _v3, _v4 : TSVector2f; const _c1, _c2, _c3, _c4 : TSColor3f; var _ObjectNumber, _VertexIndex, _FaceIndex : TSUInt32);
begin
if _Depth = 0 then
	Generate1(_Depth, _v1, _v2, _v3, _v4, _c1, _c2, _c3, _c4, _ObjectNumber, _VertexIndex, _FaceIndex)
else
	begin
	Generate2(_Depth - 1, _v1, _v2, _v3, _v4, _c1, _c2, _c3, _c4, _ObjectNumber, _VertexIndex, _FaceIndex);
	Generate2(_Depth - 1, _v4, _v1, _v2, _v3, _c4, _c1, _c2, _c3, _ObjectNumber, _VertexIndex, _FaceIndex);
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
	AddData(_ObjectNumber, _VertexIndex, _FaceIndex, _v1, _v2, _v3, _v4)
else
	begin
	// constructing...
	end;
end;

end.