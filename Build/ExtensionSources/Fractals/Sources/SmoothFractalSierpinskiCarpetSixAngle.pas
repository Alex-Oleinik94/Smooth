{$INCLUDE Smooth.inc}

unit SmoothFractalSierpinskiCarpetSixAngle;

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
	TSVector2fList6 = array[0..5] of TSVector2f;
	PSVector2fList6 = ^ TSVector2fList6;
	TSFractalSierpinskiCarpetSixAngle = class(TS3DFractalForm)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
			protected
		class function CountingTheNumberOfPolygons(const _Depth : TSMaxEnum) : TSMaxEnum; override;
		procedure GenerateInteriorPolygons(const _List, _List1, _List2, _List3 : PSVector2fList6);
		procedure Generate(const _PointCenter : TSVector2d; const _Radius : TSFloat64);
		function TypeToSpins(const _Type : TSUInt8) : TSVector4int8;
		function CalculatePolygonsLimit() : TSUInt64; override;
			public
		procedure PolygonsConstruction(); override;
		procedure PushPolygonData(var _ObjectNumber : TSFractalIndexInt; const _VectorList : PSVector2fList6; var _VertexIndex, _FaceIndex : TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetType(const _Type : TSUInt8);
			protected
		FTypeComboBox : TSScreenComboBox;
		FSpins : TSVector4int8;
		end;

function SVector2fList6Import(const v1, v2, v3, v4, v5, v6 : TSVector2f): TSVector2fList6;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SPVector2fList6Create(const v1, v2, v3, v4, v5, v6 : TSVector2f): PSVector2fList6;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SVector2fList6Spin(var List : TSVector2fList6; const AboveZero : TSBool = True); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SVector2fList6Spining(Count : TSInt8; const List : TSVector2fList6): TSVector2fList6; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SVector2fList6Write(const _List : PSVector2fList6);

implementation

uses
	 SmoothArithmeticUtils
	,SmoothRenderBase
	,SmoothScreenBase
	,SmoothLog
	;

function SVector2fList6Spining(Count : TSInt8; const List : TSVector2fList6): TSVector2fList6; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Count := Count mod 6;
Result := List;
while Count <> 0 do
	begin
	SVector2fList6Spin(Result, Count > 0);
	if Count < 0 then
		Count += 1
	else
		Count -= 1;
	end;
end;

procedure SVector2fList6Spin(var List : TSVector2fList6; const AboveZero : TSBool = True); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Vector : TSVector2f;
	Index : TSByte;
begin
if AboveZero then
	begin
	Vector := List[5];
	for Index := 4 downto 0 do
		List[Index + 1] := List[Index];
	List[0] := Vector;
	end
else
	begin
	Vector := List[0];
	for Index := 0 to 4 do
		List[Index] := List[Index + 1];
	List[5] := Vector;
	end;
end;

function SPVector2fList6Create(const v1, v2, v3, v4, v5, v6 : TSVector2f): PSVector2fList6;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := GetMem(SizeOf(TSVector2fList6));
Result^ := SVector2fList6Import(v1, v2, v3, v4, v5, v6);
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

procedure SVector2fList6Write(const _List : PSVector2fList6);
var
	Index : TSMaxEnum;
begin
for Index := 0 to 5 do
	begin
	Write('(', _List^[Index].x:0:5, ', ', _List^[Index].y:0:5,')');
	if Index < 5 then
		Write('; ');
	end;
WriteLn();
end;

// TSFractalSierpinskiCarpetSixAngle

function TSFractalSierpinskiCarpetSixAngle.CalculatePolygonsLimit() : TSUInt64;
var
	Index : TSMaxEnum;
begin
Result := 0;
Index := 0;
while (inherited > Result + CountingTheNumberOfPolygons(Index) * 2) do
	begin
	Result += CountingTheNumberOfPolygons(Index) * 2;
	Index += 1;
	end;
//SLog.Source(['dasdasd',Result]);
end;

procedure TSFractalSierpinskiCarpetSixAngle.SetType(const _Type : TSUInt8);
var
	Spins : TSVector4int8;
begin
if (_Type >= 0) and (_Type <= 11) then
	begin
	Spins := TypeToSpins(_Type);
	if (Spins <> FSpins) then
		begin
		FSpins := Spins;
		//FSpins.WriteLn();
		Construct();
		end;
	end;
end;

function TSFractalSierpinskiCarpetSixAngle.TypeToSpins(const _Type : TSUInt8) : TSVector4int8;
begin
case _Type of
0 : Result := TSVector4int8.Create(0, 0, 0, 0);   // Треугольник
1 : Result := TSVector4int8.Create(3, 2, -2, 0);  // Ладья
2 : Result := TSVector4int8.Create(3, 0, 0, 0);   // Тупой глиф
3 : Result := TSVector4int8.Create(-2, 2, 3, -2); // Острый глиф
4 : Result := TSVector4int8.Create(-1, 1, 0, -2); // Красивый узор
5 : Result := TSVector4int8.Create(-1, 0, 1, 2);  // Лист
6 : Result := TSVector4int8.Create(3, 3, 0, -2);  // Пушинки
7 : Result := TSVector4int8.Create(3, 3, 1, 2);   // Звезда
8 : Result := TSVector4int8.Create(2, -2, 1, -2); // Причудливый узор
9 : Result := TSVector4int8.Create(-1, -2, 2, -2);// Зигзаг
10: Result := TSVector4int8.Create(2, 1, 0, 2);   // Орнамент
else Result := TSVector4int8.Create(Random(6) - 2, Random(6) - 2, Random(6) - 2, Random(6) - 2);
end;
end;

procedure TSFractalSierpinskiCarpetSixAngle__SetType(_PreviousItemIndex, _ItemIndex : TSUInt32; _Component : TSScreenComboBox);
begin
TSFractalSierpinskiCarpetSixAngle(_Component.FUserPointer1).SetType(_ItemIndex);
end;

constructor TSFractalSierpinskiCarpetSixAngle.Create(const VContext : ISContext);
var
	StartType : TSUInt8 = 0;
begin
inherited Create(VContext);

FPolygonsLimit := CalculatePolygonsLimit();
StartType := Random(11);
FSpins := TypeToSpins(StartType);
FFractalDimension := SFractal2D;
FPrimetiveType := SR_LINES;
FPrimetiveParam := 0;
Threads:={$IFDEF ANDROID}0{$ELSE}1{$ENDIF};
Depth := 7;

FTypeComboBox := TSScreenComboBox.Create();
Screen.CreateInternalComponent(FTypeComboBox);
with FTypeComboBox do
	begin
	Anchors := [SAnchRight];
	SetBounds(Render.Width - 550, 5, 180, 30);
	BoundsMakeReal();
	CreateItem('Треугольник');
	CreateItem('Ладья');
	CreateItem('Тупой глиф');
	CreateItem('Острый глиф');	
	CreateItem('Красивый узор');
	CreateItem('Лист');
	CreateItem('Пушинки');
	CreateItem('Звезда');
	CreateItem('Причудливый узор');
	CreateItem('Зигзаг');
	CreateItem('Орнамент');
	CreateItem('Случайный узор');
	SelectItem := StartType;
	CursorQuickSelect := True;
	FUserPointer1 := Self;
	CallBackProcedure := TSScreenComboBoxProcedure(@TSFractalSierpinskiCarpetSixAngle__SetType);
	Visible := True;
	Active := True;
	end;

Construct();
end;

destructor TSFractalSierpinskiCarpetSixAngle.Destroy();
begin
SKill(FTypeComboBox);
inherited;
end;

class function TSFractalSierpinskiCarpetSixAngle.ClassName():TSString;
begin
Result := 'Шестиугольник Серпинского';
end;

class function TSFractalSierpinskiCarpetSixAngle.CountingTheNumberOfPolygons(const _Depth : TSMaxEnum) : TSMaxEnum;
begin
Result := 6 * (3 ** _Depth);
end;

procedure TSFractalSierpinskiCarpetSixAngle.GenerateInteriorPolygons(const _List, _List1, _List2, _List3 : PSVector2fList6);
begin
_List1^ := SVector2fList6Import(_List^[0], (_List^[0] + _List^[1]) / 2, (_List^[0] + _List^[2]) / 2, (_List^[0] + _List^[2] + _List^[4]) / 3, (_List^[4] + _List^[0]) / 2, (_List^[5] + _List^[0]) / 2);
_List2^ := SVector2fList6Import(_List^[2], (_List^[2] + _List^[3]) / 2, (_List^[2] + _List^[4]) / 2, (_List^[0] + _List^[2] + _List^[4]) / 3, (_List^[0] + _List^[2]) / 2, (_List^[1] + _List^[2]) / 2);
_List3^ := SVector2fList6Import(_List^[4], (_List^[4] + _List^[5]) / 2, (_List^[4] + _List^[0]) / 2, (_List^[0] + _List^[2] + _List^[4]) / 3, (_List^[2] + _List^[4]) / 2, (_List^[3] + _List^[4]) / 2);
end;

procedure TSFractalSierpinskiCarpetSixAngle.PolygonsConstruction();
begin
Generate(TSVertex2d.Create(0, 0), 4);
end;

procedure TSFractalSierpinskiCarpetSixAngle.Generate(const _PointCenter : TSVector2d; const _Radius : TSFloat64);
var
	ObjectNumber, VertexIndex, FaceIndex : TSFractalIndexInt;

procedure Rec(const _List : PSVector2fList6; const _Depth : TSUInt32);
var
	List1, List2, List3 : PSVector2fList6;
begin
//SLog.Source(['TSFractalSierpinskiCarpetSixAngle.Rec(',_Depth,').B']);
if _Depth > 0 then
	begin
	_List^ := SVector2fList6Spining(FSpins.w, _List^);
	List1 := GetMem(SizeOf(TSVector2fList6));
	List2 := GetMem(SizeOf(TSVector2fList6));
	List3 := GetMem(SizeOf(TSVector2fList6));
	GenerateInteriorPolygons(_List, List1, List2, List3);
	List1^ := SVector2fList6Spining(FSpins.x, List1^);
	Rec(List1, _Depth - 1);
	List2^ := SVector2fList6Spining(FSpins.y, List2^);
	Rec(List2, _Depth - 1);
	List3^ := SVector2fList6Spining(FSpins.z, List3^);
	Rec(List3, _Depth - 1);
	FreeMem(List1);
	FreeMem(List2);
	FreeMem(List3);
	end
else
	PushPolygonData(ObjectNumber, _List, VertexIndex, FaceIndex);
//SLog.Source(['TSFractalSierpinskiCarpetSixAngle.Rec(',_Depth,').E']);
end;

var
	PointList : PSVector2fList6;
	Index : TSUInt32;
begin
VertexIndex := 0;
FaceIndex := 0;
ObjectNumber := 0;
PointList := GetMem(SizeOf(TSVector2fList6));
for Index := 0 to 5 do
	PointList^[Index] := TSVector2f.Create(
		_PointCenter.x + Sin(Index/6*2*PI) * _Radius,
		_PointCenter.y + Cos(Index/6*2*PI) * _Radius);
Rec(PointList, FDepth);
//SLog.Source(['End1(',FDepth,')']);
FreeMem(PointList);
//SLog.Source(['End2(',FDepth,')']);
EndOfPolygonsConstruction(ObjectNumber);
//SLog.Source(['End3(',FDepth,')']);
end;

procedure TSFractalSierpinskiCarpetSixAngle.PushPolygonData(var _ObjectNumber : TSFractalIndexInt; const _VectorList : PSVector2fList6; var _VertexIndex, _FaceIndex : TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex + 0, _VectorList^[0]);
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex + 1, _VectorList^[1]);
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex + 2, _VectorList^[2]);
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex + 3, _VectorList^[3]);
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex + 4, _VectorList^[4]);
F3dObject.Objects[_ObjectNumber].SetVertex(_VertexIndex + 5, _VectorList^[5]);

F3dObject.Objects[_ObjectNumber].SetFaceLine(0, _FaceIndex + 0, _VertexIndex + 0, _VertexIndex + 1);
F3dObject.Objects[_ObjectNumber].SetFaceLine(0, _FaceIndex + 1, _VertexIndex + 1, _VertexIndex + 2);
F3dObject.Objects[_ObjectNumber].SetFaceLine(0, _FaceIndex + 2, _VertexIndex + 2, _VertexIndex + 3);
F3dObject.Objects[_ObjectNumber].SetFaceLine(0, _FaceIndex + 3, _VertexIndex + 3, _VertexIndex + 4);
F3dObject.Objects[_ObjectNumber].SetFaceLine(0, _FaceIndex + 4, _VertexIndex + 4, _VertexIndex + 5);
F3dObject.Objects[_ObjectNumber].SetFaceLine(0, _FaceIndex + 5, _VertexIndex + 5, _VertexIndex + 0);

_VertexIndex += 6;
_FaceIndex += 6;

AfterPushingPolygonData(_ObjectNumber, FThreadsEnable, _VertexIndex);
end;

end.
