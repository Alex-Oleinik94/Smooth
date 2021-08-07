{$INCLUDE Smooth.inc}

unit SmoothFractalSierpinskiPentagon;

interface

uses
	 SmoothBase
	,SmoothCommonStructs
	,SmoothContextInterface
	,Smooth3DFractal
	,Smooth3DFractalForm
	,SmoothScreenClasses
	;

type
	TSVector2fList5 = array[0..4] of TSVector2f;
	PSVector2fList5 = ^ TSVector2fList5;
	TSFractalSierpinskiPentagon = class(TS3DFractalForm)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
			protected
		class function CountingTheNumberOfPolygons(const _Depth : TSMaxEnum) : TSMaxEnum; override;
		procedure Generate(const _PointCenter : TSVector2d; const _Radius : TSFloat64);
		class function NormalizeIndex(const Index : TSMaxSignedEnum) : TSMaxSignedEnum;
			public
		procedure PolygonsConstruction(); override;
		procedure PushPolygonData(var _ObjectNumber : TSFractalIndexInt; const _VectorList : TSVector2fList5; var _VertexIndex, _FaceIndex : TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetType(const _Type : TSUInt8);
			protected
		FTypeComboBox : TSScreenComboBox;
		FProportionate : TSBoolean;
		end;

implementation

uses
	 SmoothArithmeticUtils
	,SmoothRenderBase
	,SmoothScreenBase
	,SmoothLog
	,SmoothCommon
	;

// TSFractalSierpinskiPentagon

procedure TSFractalSierpinskiPentagon.SetType(const _Type : TSUInt8);
var
	Spins : TSVector4int8;
begin
if (_Type >= 0) and (_Type <= 1) and (_Type <> TSUInt8(FProportionate)) then
	begin
	FProportionate := _Type = 1;
	Construct();
	end;
end;

class function TSFractalSierpinskiPentagon.NormalizeIndex(const Index : TSMaxSignedEnum) : TSMaxSignedEnum;
begin
Result := Index;
if (Result < 0) then
	begin
	Result -= 3;
	Result *= -1;
	end;
if (Result > 4) then
	Result := Result mod 5;	
end;

procedure TSFractalSierpinskiPentagon__SetType(_PreviousItemIndex, _ItemIndex : TSUInt32; _Component : TSScreenComboBox);
begin
TSFractalSierpinskiPentagon(_Component.FUserPointer1).SetType(_ItemIndex);
end;

constructor TSFractalSierpinskiPentagon.Create(const VContext : ISContext);
var
	StartType : TSUInt8 = 0;
begin
inherited Create(VContext);

StartType := Random(2);
FProportionate := StartType = 1;
FFractalDimension := SFractal2D;
FPolygonsType := SR_LINES;
FVertexMultiplier := 0;
Threads:={$IFDEF ANDROID}0{$ELSE}1{$ENDIF};
Depth := 5;

FTypeComboBox := TSScreenComboBox.Create();
Screen.CreateInternalComponent(FTypeComboBox);
with FTypeComboBox do
	begin
	Anchors := [SAnchRight];
	SetBounds(Render.Width - 550, 5, 180, 30);
	BoundsMakeReal();
	CreateItem('Непропорциональный');
	CreateItem('Пропорциональный');
	SelectItem := StartType;
	CursorQuickSelect := True;
	FUserPointer1 := Self;
	CallBackProcedure := TSScreenComboBoxProcedure(@TSFractalSierpinskiPentagon__SetType);
	Visible := True;
	Active := True;
	end;

Construct();
end;

destructor TSFractalSierpinskiPentagon.Destroy();
begin
SKill(FTypeComboBox);
inherited;
end;

class function TSFractalSierpinskiPentagon.ClassName():TSString;
begin
Result := 'Пятиугольник Серпинского';
end;

class function TSFractalSierpinskiPentagon.CountingTheNumberOfPolygons(const _Depth : TSMaxEnum) : TSMaxEnum;
begin
Result := 5 ** (_Depth + 1);
end;

procedure TSFractalSierpinskiPentagon.PolygonsConstruction();
begin
Generate(TSVertex2d.Create(0, 0), 4);
end;

procedure TSFractalSierpinskiPentagon.Generate(const _PointCenter : TSVector2d; const _Radius : TSFloat64);
var
	ObjectNumber, VertexIndex, FaceIndex{Polygons Index} : TSFractalIndexInt;

procedure Rec(const _List : TSVector2fList5; const _Depth : TSUInt32);
var
	InteriorPoints, Points : TSVector2fList5;
	SizeB : TSFloat32;
	Index : TSMaxSignedEnum;
begin
if _Depth > 0 then
	begin
	for Index := 0 to 4 do
		InteriorPoints[Index] := S2LinesIntersectionVector(
			_List[Index], _List[NormalizeIndex(Index + 2)],
			_List[NormalizeIndex(Index - 1)], _List[NormalizeIndex(Index + 1)]);
	SizeB := Abs(InteriorPoints[0] - InteriorPoints[1]);
	
	for Index := 0 to 4 do
		begin
		Points[0] := _List[Index];
		Points[2] := InteriorPoints[Index];
		Points[3] := InteriorPoints[NormalizeIndex(Index - 1)];
		if (FProportionate) then
			begin
			Points[1] := (_List[NormalizeIndex(Index + 1)] - _List[Index]).Normalized * SizeB + _List[Index];
			Points[4] := (_List[NormalizeIndex(Index - 1)] - _List[Index]).Normalized * SizeB + _List[Index];
			end
		else
			begin
			Points[1] := (_List[Index] + _List[NormalizeIndex(Index + 1)]) / 2;
			Points[4] := (_List[NormalizeIndex(Index - 1)] + _List[Index]) / 2;
			end;
		Rec(Points, _Depth - 1);
		end;
	end
else
	PushPolygonData(ObjectNumber, _List, VertexIndex, FaceIndex);
end;

var
	PointList : TSVector2fList5;
	Index : TSMaxEnum;
begin
VertexIndex := 0;
FaceIndex := 0;
ObjectNumber := 0;
for Index := 0 to 4 do
	PointList[Index] := TSVector2f.Create(
		_PointCenter.x + Sin(Index/5*2*PI) * _Radius,
		_PointCenter.y + Cos(Index/5*2*PI) * _Radius);
Rec(PointList, FDepth);
EndOfPolygonsConstruction(ObjectNumber);
end;

procedure TSFractalSierpinskiPentagon.PushPolygonData(var _ObjectNumber : TSFractalIndexInt; const _VectorList : TSVector2fList5; var _VertexIndex, _FaceIndex : TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex + 0, _VectorList[0]);
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex + 1, _VectorList[1]);
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex + 2, _VectorList[2]);
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex + 3, _VectorList[3]);
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex + 4, _VectorList[4]);

F3dObject.Objects[_ObjectNumber].SetFaceLine(0, _FaceIndex + 0, _VertexIndex + 0, _VertexIndex + 1);
F3dObject.Objects[_ObjectNumber].SetFaceLine(0, _FaceIndex + 1, _VertexIndex + 1, _VertexIndex + 2);
F3dObject.Objects[_ObjectNumber].SetFaceLine(0, _FaceIndex + 2, _VertexIndex + 2, _VertexIndex + 3);
F3dObject.Objects[_ObjectNumber].SetFaceLine(0, _FaceIndex + 3, _VertexIndex + 3, _VertexIndex + 4);
F3dObject.Objects[_ObjectNumber].SetFaceLine(0, _FaceIndex + 4, _VertexIndex + 4, _VertexIndex + 0);

_VertexIndex += 5;
_FaceIndex += 5;

AfterPushingPolygonData(_ObjectNumber, FThreadsEnable, _VertexIndex, _FaceIndex);
end;

end.
