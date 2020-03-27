{$INCLUDE Smooth.inc}

unit SmoothFractalSierpinskiCarpetSixAngle;

interface

uses
	 SmoothBase
	,SmoothCommonStructs
	,SmoothContextInterface
	,SmoothFractalForm
	,SmoothScreenClasses
	;

const
	SFractalSierpinskiCarpetSixAngleTypesCount = 7;
type
	TSVector2fList6 = array[0..5] of TSVector2f;
	TSFractalSierpinskiCarpetSixAngleType = TSByte;
	TSFractalSierpinskiCarpetSixAngle = class(TS3DFractalForm)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
			protected
		function RecQuantity(const RecDepth : TSMaxEnum) : TSMaxEnum; override;
			public
		procedure CalculateFromThread(); override;
		procedure PushIndexes(var ObjectId : TSUInt32; const v1, v2, v3, v4, v5, v6 : TSVector2f; var FVertexIndex, FFaceIndex : TSUInt32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetType(const NewType : TSFractalSierpinskiCarpetSixAngleType);
			protected
		FTypeComboBox : TSScreenComboBox;
		FType : TSFractalSierpinskiCarpetSixAngleType;
		end;

function SVector2fList6Import(const v1, v2, v3, v4, v5, v6 : TSVector2f): TSVector2fList6;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SVector2fList6Swap(var List : TSVector2fList6); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SVector2fList6Swaping(Count : TSByte; const List : TSVector2fList6): TSVector2fList6; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothMathUtils
	,SmoothRenderBase
	,SmoothScreenBase
	;

function SVector2fList6Swaping(Count : TSByte; const List : TSVector2fList6): TSVector2fList6; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Count := Count mod 6;
Result := List;
while Count > 0 do
	begin
	SVector2fList6Swap(Result);
	Count -= 1;
	end;
end;

procedure SVector2fList6Swap(var List : TSVector2fList6); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Vector : TSVector2f;
	i : TSByte;
begin
Vector := List[0];
for i := 0 to 5 do
	List[i] := List[i + 1];
List[5] := Vector;
end;

function SVector2fList6Import(const v1, v2, v3, v4, v5, v6 : TSVector2f): TSVector2fList6;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result[0] := v1;
Result[1] := v2;
Result[2] := v3;
Result[3] := v4;
Result[4] := v5;
Result[5] := v6;
end;

procedure TSFractalSierpinskiCarpetSixAngle.SetType(const NewType : TSFractalSierpinskiCarpetSixAngleType);
begin
if (NewType >= 0) and (NewType <= SFractalSierpinskiCarpetSixAngleTypesCount - 1) and (NewType <> FType) then
	begin
	FType := NewType;
	Calculate();
	end;
end;

procedure TSFractalSierpinskiCarpetSixAngle__SetType(a, b : TSUInt32; Component : TSScreenComboBox);
begin
TSFractalSierpinskiCarpetSixAngle(Component.FUserPointer1).SetType(b);
end;

constructor TSFractalSierpinskiCarpetSixAngle.Create(const VContext : ISContext);
begin
inherited Create(VContext);

FIs2D := True;
FPrimetiveType := SR_LINES;
FPrimetiveParam := 0;
FType := Random(SFractalSierpinskiCarpetSixAngleTypesCount);
FDepth := 7;

FTypeComboBox := TSScreenComboBox.Create();
Screen.CreateChild(FTypeComboBox);
with FTypeComboBox do
	begin
	Anchors := [SAnchRight];
	SetBounds(Render.Width - 550, 5, 180, 30);
	BoundsMakeReal();
	CreateItem('�����������');
	CreateItem('����');
	CreateItem('�������� ����');
	CreateItem('������');
	CreateItem('����������� ����');
	CreateItem('�����');
	CreateItem('��������� ����');
	SelectItem := FType;
	FUserPointer1 := Self;
	CallBackProcedure := TSScreenComboBoxProcedure(@TSFractalSierpinskiCarpetSixAngle__SetType);
	Visible := True;
	Active := True;
	end;

Calculate();
end;

destructor TSFractalSierpinskiCarpetSixAngle.Destroy();
begin
FTypeComboBox.Destroy();
FTypeComboBox := nil;
inherited;
end;

class function TSFractalSierpinskiCarpetSixAngle.ClassName():TSString;
begin
Result := '�������������� �����������';
end;

function TSFractalSierpinskiCarpetSixAngle.RecQuantity(const RecDepth : TSMaxEnum) : TSMaxEnum;
begin
Result := 6 * (3 ** RecDepth);
end;

procedure TSFractalSierpinskiCarpetSixAngle.CalculateFromThread();
type
	TListRecProcedure = procedure (const List : TSVector2fList6; const CountSwap : TSByte; const RecDepth : TSUInt32) is nested;
var 
	ObjectId : TSUInt32; 
	FVertexIndex, FFaceIndex : TSUInt32;
	RecList : TListRecProcedure = nil;

procedure Rec(const v1, v2, v3, v4, v5, v6 : TSVector2f; const RecDepth : TSUInt32); overload;
var
	Center,
	v12, v23, v34, v45, v56, v61,
	v13, v35, v51
		: TSVector2f;
begin
if RecDepth = 0 then
	PushIndexes(ObjectId, v1, v2, v3, v4, v5, v6, FVertexIndex, FFaceIndex)
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
	1 : // 2 ���� �����
		begin
		Rec(v1, v12, v13, Center, v51, v61, RecDepth - 1);
		Rec(v23, v3, v34, v35, Center, v13, RecDepth - 1);
		Rec(v56, v51, Center, v35, v45, v5, RecDepth - 1);
		end;
	2 : // 3 �������� �����
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
		RecList(SVector2fList6Import(Center, v51, v61, v1, v12, v13), Random(6), RecDepth - 1);
		RecList(SVector2fList6Import(v34, v35, Center, v13, v23, v3), Random(6), RecDepth - 1);
		RecList(SVector2fList6Import(v45, v5, v56, v51, Center, v35), Random(6), RecDepth - 1);
		end;
	end;
	end;
end;

procedure RecListProcedure(const List : TSVector2fList6; const CountSwap : TSByte; const RecDepth : TSUInt32);
var
	SwapedList : TSVector2fList6;
begin
SwapedList := SVector2fList6Swaping(CountSwap, List);
Rec(
	SwapedList[0],
	SwapedList[1],
	SwapedList[2],
	SwapedList[3],
	SwapedList[4],
	SwapedList[5],
	RecDepth);
end;

procedure Rec(const PointCenter : TSVector2f; const Radius : TSFloat64; const RecDepth : TSUInt32); overload;
var
	PointList : array[0..5] of TSVector2f;
	Index : TSUInt32;
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
ObjectId := 0;
RecList := @RecListProcedure;
Rec(SVertex2fImport(0, 0),
	4,
	Depth);
FinalizeCalculateFromThread(ObjectId);
end;

procedure TSFractalSierpinskiCarpetSixAngle.PushIndexes(var ObjectId : TSUInt32; const v1, v2, v3, v4, v5, v6 : TSVector2f; var FVertexIndex, FFaceIndex : TSUInt32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
F3dObject.Objects[ObjectId].SetVertex(FVertexIndex + 0, v1);
F3dObject.Objects[ObjectId].SetVertex(FVertexIndex + 1, v2);
F3dObject.Objects[ObjectId].SetVertex(FVertexIndex + 2, v3);
F3dObject.Objects[ObjectId].SetVertex(FVertexIndex + 3, v4);
F3dObject.Objects[ObjectId].SetVertex(FVertexIndex + 4, v5);
F3dObject.Objects[ObjectId].SetVertex(FVertexIndex + 5, v6);
FVertexIndex += 6;

F3dObject.Objects[ObjectId].SetFaceLine(0, FFaceIndex + 0, FVertexIndex + 0, FVertexIndex + 1);
F3dObject.Objects[ObjectId].SetFaceLine(0, FFaceIndex + 1, FVertexIndex + 1, FVertexIndex + 2);
F3dObject.Objects[ObjectId].SetFaceLine(0, FFaceIndex + 2, FVertexIndex + 2, FVertexIndex + 3);
F3dObject.Objects[ObjectId].SetFaceLine(0, FFaceIndex + 3, FVertexIndex + 3, FVertexIndex + 4);
F3dObject.Objects[ObjectId].SetFaceLine(0, FFaceIndex + 4, FVertexIndex + 4, FVertexIndex + 5);
F3dObject.Objects[ObjectId].SetFaceLine(0, FFaceIndex + 5, FVertexIndex + 5, FVertexIndex + 0);
FFaceIndex += 6;

AfterPushIndexes(ObjectId, FThreadsEnable, FVertexIndex);
end;

end.
