{$INCLUDE SaGe.inc}

unit SaGeFractalSixAngle;

interface

uses
	 SaGeBase
	,SaGeCommonStructs
	,SaGeCommonClasses
	,SaGeFractalForm
	,SaGeScreen
	;

const
	SGFractalSixAngleTypesCount = 7;
type
	TSGVector2fList6 = array[0..5] of TSGVector2f;
	TSGFractalSixAngleType = TSGByte;
	TSGFractalSixAngle = class(TSG3DFractalForm)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			protected
		function RecQuantity(const RecDepth : TSGMaxEnum) : TSGMaxEnum; override;
			public
		procedure CalculateFromThread(); override;
		procedure PushIndexes(var MeshID : TSGUInt32; const v1, v2, v3, v4, v5, v6 : TSGVector2f; var FVertexIndex, FFaceIndex : TSGUInt32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetType(const NewType : TSGFractalSixAngleType);
			protected
		FTypeComboBox : TSGComboBox;
		FType : TSGFractalSixAngleType;
		end;

function SGVector2fList6Import(const v1, v2, v3, v4, v5, v6 : TSGVector2f): TSGVector2fList6;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGVector2fList6Swap(var List : TSGVector2fList6); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGVector2fList6Swaping(Count : TSGByte; const List : TSGVector2fList6): TSGVector2fList6; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeMathUtils
	,SaGeRenderBase
	,SaGeScreenBase
	;

function SGVector2fList6Swaping(Count : TSGByte; const List : TSGVector2fList6): TSGVector2fList6; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Count := Count mod 6;
Result := List;
while Count > 0 do
	begin
	SGVector2fList6Swap(Result);
	Count -= 1;
	end;
end;

procedure SGVector2fList6Swap(var List : TSGVector2fList6); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Vector : TSGVector2f;
	i : TSGByte;
begin
Vector := List[0];
for i := 0 to 5 do
	List[i] := List[i + 1];
List[5] := Vector;
end;

function SGVector2fList6Import(const v1, v2, v3, v4, v5, v6 : TSGVector2f): TSGVector2fList6;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result[0] := v1;
Result[1] := v2;
Result[2] := v3;
Result[3] := v4;
Result[4] := v5;
Result[5] := v6;
end;

procedure TSGFractalSixAngle.SetType(const NewType : TSGFractalSixAngleType);
begin
if (NewType >= 0) and (NewType <= SGFractalSixAngleTypesCount - 1) and (NewType <> FType) then
	begin
	FType := NewType;
	Calculate();
	end;
end;

procedure TSGFractalSixAngle__SetType(a, b : TSGUInt32; Component : TSGComboBox);
begin
TSGFractalSixAngle(Component.FUserPointer1).SetType(b);
end;

constructor TSGFractalSixAngle.Create(const VContext : ISGContext);
begin
inherited Create(VContext);

FIs2D := True;
FPrimetiveType := SGR_LINES;
FPrimetiveParam := 0;
FType := Random(SGFractalSixAngleTypesCount);
FDepth := 7;

FTypeComboBox := TSGComboBox.Create();
Screen.CreateChild(FTypeComboBox);
with FTypeComboBox do
	begin
	Anchors := [SGAnchRight];
	SetBounds(Render.Width - 550, 5, 180, 30);
	BoundsToNeedBounds();
	CreateItem('Треугольник');
	CreateItem('Лист');
	CreateItem('Геометрия');
	CreateItem('Звезда');
	CreateItem('Нечто');
	CreateItem('Ладья');
	CreateItem('Случайная');
	SelectItem := FType;
	FUserPointer1 := Self;
	CallBackProcedure := TSGComboBoxProcedure(@TSGFractalSixAngle__SetType);
	Visible := True;
	Active := True;
	end;

Calculate();
end;

destructor TSGFractalSixAngle.Destroy();
begin
FTypeComboBox.Destroy();
FTypeComboBox := nil;
inherited;
end;

class function TSGFractalSixAngle.ClassName():TSGString;
begin
Result := 'Соты шестиугольника';
end;

function TSGFractalSixAngle.RecQuantity(const RecDepth : TSGMaxEnum) : TSGMaxEnum;
begin
Result := 6 * (3 ** RecDepth);
end;

procedure TSGFractalSixAngle.CalculateFromThread();
type
	TListRecProcedure = procedure (const List : TSGVector2fList6; const CountSwap : TSGByte; const RecDepth : TSGUInt32) is nested;
var 
	MeshID : TSGUInt32; 
	FVertexIndex, FFaceIndex : TSGUInt32;
	RecList : TListRecProcedure = nil;

procedure Rec(const v1, v2, v3, v4, v5, v6 : TSGVector2f; const RecDepth : TSGUInt32); overload;
var
	Center,
	v12, v23, v34, v45, v56, v61,
	v13, v35, v51
		: TSGVector2f;
begin
if RecDepth = 0 then
	PushIndexes(MeshID, v1, v2, v3, v4, v5, v6, FVertexIndex, FFaceIndex)
else
	begin
	Center := (v1 + v3 + v5) / 3;
	v12 := (v1 + v2) / 2;
	v23 := (v2 + v3) / 2;
	v34 := (v3 + v4) / 2;
	v45 := (v4 + v5) / 2;
	v56 := (v5 + v6) / 2;
	v61 := (v6 + v1) / 2;
	v13 := (v1 + v3) / 2;
	v35 := (v3 + v5) / 2;
	v51 := (v5 + v1) / 2;
	case FType of
	0 : // 1 Triangle
		begin
		Rec(v1, v12, v13, Center, v51, v61, RecDepth - 1);
		Rec(v3, v34, v35, Center, v13, v23, RecDepth - 1);
		Rec(v5, v56, v51, Center, v35, v45, RecDepth - 1);
		end;
	1 : // 2 Лист клена
		begin
		Rec(v1, v12, v13, Center, v51, v61, RecDepth - 1);
		Rec(v23, v3, v34, v35, Center, v13, RecDepth - 1);
		Rec(v56, v51, Center, v35, v45, v5, RecDepth - 1);
		end;
	2 : // 3 Забавная штука
		begin
		Rec(v1, v12, v13, Center, v51, v61, RecDepth - 1);
		Rec(v34, v35, Center, v13, v23, v3, RecDepth - 1);
		Rec(v45, v5, v56, v51, Center, v35, RecDepth - 1);
		end;
	3 : // 4 Star
		begin
		Rec(Center, v51, v61, v1, v12, v13, RecDepth - 1);
		Rec(v34, v35, Center, v13, v23, v3, RecDepth - 1);
		Rec(v45, v5, v56, v51, Center, v35, RecDepth - 1);
		end;
	4 : // 5 Nothing
		begin
		Rec(v61, v1, v12, v13, Center, v51, RecDepth - 1);
		Rec(v3, v34, v35, Center, v13, v23, RecDepth - 1);
		Rec(v5, v56, v51, Center, v35, v45, RecDepth - 1);
		end;
	5 : // 6 ?
		begin
		Rec(Center, v51, v61, v1, v12, v13, RecDepth - 1);
		Rec(v13, v23, v3, v34, v35, Center, RecDepth - 1);
		Rec(v51, Center, v35, v45, v5, v56, RecDepth - 1);
		end;
	6 : // 7 Random
		begin
		RecList(SGVector2fList6Import(Center, v51, v61, v1, v12, v13), Random(6), RecDepth - 1);
		RecList(SGVector2fList6Import(v34, v35, Center, v13, v23, v3), Random(6), RecDepth - 1);
		RecList(SGVector2fList6Import(v45, v5, v56, v51, Center, v35), Random(6), RecDepth - 1);
		end;
	end;
	end;
end;

procedure RecListProcedure(const List : TSGVector2fList6; const CountSwap : TSGByte; const RecDepth : TSGUInt32);
var
	SwapedList : TSGVector2fList6;
begin
SwapedList := SGVector2fList6Swaping(CountSwap, List);
Rec(
	SwapedList[0],
	SwapedList[1],
	SwapedList[2],
	SwapedList[3],
	SwapedList[4],
	SwapedList[5],
	RecDepth);
end;

procedure Rec(const PointCenter : TSGVector2f; const Radius : TSGFloat64; const RecDepth : TSGUInt32); overload;
var
	PointList : array[0..5] of TSGVector2f;
	Index : TSGUInt32;
begin
for Index := 0 to 5 do
	PointList[Index].Import(
		PointCenter.x + Sin(Index/6*2*PI) * Radius,
		PointCenter.y + Cos(Index/6*2*PI) * Radius);
Rec(PointList[0],
	PointList[1],
	PointList[2],
	PointList[3],
	PointList[4],
	PointList[5],
	RecDepth);
end;

begin
FVertexIndex := 0;
FFaceIndex := 0;
MeshID := 0;
RecList := @RecListProcedure;
Rec(SGVertex2fImport(0, 0),
	4,
	Depth);
FinalizeCalculateFromThread(MeshID);
end;

procedure TSGFractalSixAngle.PushIndexes(var MeshID : TSGUInt32; const v1, v2, v3, v4, v5, v6 : TSGVector2f; var FVertexIndex, FFaceIndex : TSGUInt32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FMesh.Objects[MeshID].SetVertex(FVertexIndex + 0, v1);
FMesh.Objects[MeshID].SetVertex(FVertexIndex + 1, v2);
FMesh.Objects[MeshID].SetVertex(FVertexIndex + 2, v3);
FMesh.Objects[MeshID].SetVertex(FVertexIndex + 3, v4);
FMesh.Objects[MeshID].SetVertex(FVertexIndex + 4, v5);
FMesh.Objects[MeshID].SetVertex(FVertexIndex + 5, v6);
FVertexIndex += 6;

FMesh.Objects[MeshID].SetFaceLine(0, FFaceIndex + 0, FVertexIndex + 0, FVertexIndex + 1);
FMesh.Objects[MeshID].SetFaceLine(0, FFaceIndex + 1, FVertexIndex + 1, FVertexIndex + 2);
FMesh.Objects[MeshID].SetFaceLine(0, FFaceIndex + 2, FVertexIndex + 2, FVertexIndex + 3);
FMesh.Objects[MeshID].SetFaceLine(0, FFaceIndex + 3, FVertexIndex + 3, FVertexIndex + 4);
FMesh.Objects[MeshID].SetFaceLine(0, FFaceIndex + 4, FVertexIndex + 4, FVertexIndex + 5);
FMesh.Objects[MeshID].SetFaceLine(0, FFaceIndex + 5, FVertexIndex + 5, FVertexIndex + 0);
FFaceIndex += 6;

AfterPushIndexes(MeshID, FThreadsEnable, FVertexIndex);
end;

end.
