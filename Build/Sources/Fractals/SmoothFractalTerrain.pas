{$INCLUDE Smooth.inc}

unit SmoothFractalTerrain;

interface
uses 
	 Classes
	
	,SmoothCommonStructs
	,SmoothBaseClasses
	,SmoothBase
	,SmoothImage
	,SmoothContextInterface
	,SmoothVertexObject
	,SmoothRenderBase
	;
type
	TSFTGCornersAltitudes = array [0..3] of TSFloat;
	TSFTGVertexFunction = function(const VX, VY, VSize : TSLongWord; const VAltitude : TSFloat) : TSVector3f;
	TSFTGColorFunction = function(const VAltitude : TSFloat) : TSColor4f;
	TSFTGTerrain = packed array of packed array of TSFloat;
	TSFractalTerrainGenerator = class(TSNamed)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSString; override;
			protected
		FCornersAltitudes : TSFTGCornersAltitudes;
		FSize : TSLongInt;
		FAltitude : TSFloat;
			protected
		procedure SetSize(const VSize : TSLongInt);
			public
		function Generate3dObject(const VContext : ISContext; const VVertexFunction : TSFTGVertexFunction; const VColorFunction : TSFTGColorFunction = nil) : TS3DObject;
		function GenerateTerrain() : TSFTGTerrain;
			public
		property Altitude : TSFloat write FAltitude;
		property Size : TSLongInt write SetSize;
		property CornersAltitudes : TSFTGCornersAltitudes write FCornersAltitudes;
		end;

implementation

uses
	 SmoothCommon
	;

procedure TSFractalTerrainGenerator.SetSize(const VSize : TSLongInt);

function SizeRec(const VRecSize : TSLongInt) : TSLongInt;
begin
if VRecSize = 0 then
	Result := 0
else if VRecSize = 1 then
	Result := 1
else
	Result := 1 + SizeRec(VRecSize-1) * 2;
end;

begin
FSize := 2 + SizeRec(VSize - 1);
end;

function TSFractalTerrainGenerator.Generate3dObject(const VContext : ISContext; const VVertexFunction : TSFTGVertexFunction; const VColorFunction : TSFTGColorFunction = nil) : TS3DObject;
var
	Terrain : TSFTGTerrain = nil;

function CalcNormal(const VVector : TSVector3f; const VX, VY, VSize : TSLongInt):TSVector3f;
var
	Points : array [0..3] of TSVertex3f;
	PointsExists : array [0..3] of TSBoolean = (False, False, False, False);
	TotalExists : TSByte = 0;
	i, ii : TSLongInt;
begin
PointsExists[0] := (VX > 0) and (VY > 0);
if PointsExists[0] then
	Points[0] := VVertexFunction(VX - 1, VY - 1, FSize - 1, Terrain[VX - 1][VY - 1]);
PointsExists[1] := (VX < FSize - 1) and (VY > 0);
if PointsExists[1] then
	Points[1] := VVertexFunction(VX + 1, VY - 1, FSize - 1, Terrain[VX + 1][VY - 1]);
PointsExists[2] := (VX < FSize - 1) and (VY < FSize - 1);
if PointsExists[2] then
	Points[2] := VVertexFunction(VX + 1, VY + 1, FSize - 1, Terrain[VX + 1][VY + 1]);
PointsExists[3] := (VX > 0) and (VY < FSize - 1);
if PointsExists[3] then
	Points[3] := VVertexFunction(VX - 1, VY + 1, FSize - 1, Terrain[VX - 1][VY + 1]);
Result.Import(0,0,0);
for i := 0 to 3 do
	begin
	if i = 3 then
		ii := 0
	else
		ii := i + 1;
	if PointsExists[i] and PointsExists[ii] then
		begin
		Result += STriangleNormal(VVector, Points[ii], Points[i]);
		TotalExists += 1;
		end;
	end;

if 0 = TotalExists then
	Result.Import(0,1,0)
else
	Result := (Result / TotalExists).Normalized();
end;

var
	i, ii : TSLongInt;
	VertexColor : TSColor4f;
	Vector : TSVector3f;
begin
Terrain := GenerateTerrain();
Result := nil;
if Terrain <> nil then
	begin
	Result := TS3DObject.Create();
	Result.Context := VContext;
	Result.ObjectPoligonesType := SR_TRIANGLES;
	Result.HasNormals := True;
	Result.HasTexture := False;
	Result.HasColors  := VColorFunction <> nil;
	Result.EnableCullFace := False;
	Result.VertexType := S3dObjectVertexType3f;
	if Result.HasColors then
		Result.AutoSetColorType();
	Result.Vertexes := FSize * FSize;
	for i := 0 to FSize - 1 do
		for ii := 0 to FSize - 1 do
			begin
			Vector := VVertexFunction(i, ii, FSize - 1, Terrain[i][ii]);
			Result.ArVertex3f[i * FSize + ii]^ := Vector;
			Result.ArNormal[i * FSize + ii]^ := CalcNormal(Vector, i, ii, FSize - 1);
			end;
	if Result.HasColors then
		for i := 0 to FSize - 1 do
			for ii := 0 to FSize - 1 do
				begin
				VertexColor := VColorFunction(Terrain[i][ii]);
				Result.SetColor(i * FSize + ii, VertexColor.r, VertexColor.g, VertexColor.b, VertexColor.a);
				end;
	Result.AddFaceArray();
	Result.PoligonesType[0] := SR_TRIANGLES;
	Result.AutoSetIndexFormat(0, FSize * FSize);
	Result.Faces[0] := (FSize-1) * (FSize-1) * 2;
	for i := 0 to FSize - 2 do 
		for ii := 0 to FSize - 2 do
			begin
			Result.SetFaceTriangle
				(0,(i * (FSize - 1) + ii) * 2 + 0, i * FSize + ii, i * FSize + (ii+1), (i+1) * FSize + ii+1);
			Result.SetFaceTriangle
				(0,(i * (FSize - 1) + ii) * 2 + 1, i * FSize + ii, (i+1) * FSize + ii, (i+1) * FSize + ii+1);
			end;
	end;
end;

function TSFractalTerrainGenerator.GenerateTerrain() : TSFTGTerrain;
var
	i : TSLongInt;

procedure Rec(const VX, VY, VSize : TSLongInt; const VAltitude : TSFloat; const RecCount : TSLongInt);
var
	MX, MY : TSLongInt;
	VLSize : TSLongInt;
	VLSize2 : TSLongInt;

function RandomAltitudeShift() : TSFloat;
begin
Result := VAltitude * ((Random(1001) - 500)/ 500);
end;

procedure InitMiddlePointAltitude();
var
	VAverageAltitude : TSFloat;
begin
VAverageAltitude := 
	(Result[VX,         VY        ] + 
	 Result[VX + VSize, VY        ] + 
	 Result[VX + VSize, VY + VSize] + 
	 Result[VX,         VY + VSize] ) / 4;
Result[MX, MY] := VAverageAltitude + RandomAltitudeShift();
end;

procedure InitBorderPointAltitude(const VX, VY, VX1, VY1, VX2, VY2, VX3, VY3, VX4, VY4 : TSLongInt);overload;
begin
Result[VX, VY] := (Result[VX1, VY1] + Result[VX2, VY2] + Result[VX3, VY3] + Result[VX4, VY4] ) / 4 + RandomAltitudeShift();
end;

procedure InitBorderPointAltitude(const VX, VY, VX1, VY1, VX2, VY2, VX3, VY3 : TSLongInt);overload;
begin
Result[VX, VY] := (Result[VX1, VY1] + Result[VX2, VY2] + Result[VX3, VY3]) / 3 + RandomAltitudeShift();
end;

procedure InitBorderPointAltitude(const VX, VY, VX1, VY1, VX2, VY2 : TSLongInt);overload;
begin
Result[VX, VY] := (Result[VX1, VY1] + Result[VX2, VY2] ) / 2 + RandomAltitudeShift();
end;

function TestCoords(const X, Y : TSLongInt) : TSBool;
begin
Result := (X > 0) and (Y > 0) and (Y < FSize) and (X < FSize);
end;

procedure InitBorderPointAltitudeWithTest(const VX, VY, VX1, VY1, VX2, VY2, VX3, VY3, VX4, VY4 : TSLongInt);
begin
if TestCoords(VX4, VY4) then
	InitBorderPointAltitude(
		VX, VY, 
		VX1, VY1,
		VX2, VY2,
		VX3, VY3,
		VX4, VY4)
else
	InitBorderPointAltitude(
		VX, VY, 
		VX1, VY1,
		VX2, VY2,
		VX3, VY3);
end;

procedure InitBorderPointsAltitudes();
begin
InitBorderPointAltitudeWithTest(
	VX, VY + VLSize, 
	VX, VY,
	MX, MY,
	VX, VY + VSize,
	VX - VLSize2, VY + VLSize);
InitBorderPointAltitudeWithTest(
	VX + VSize, VY + VLSize, 
	VX + VSize, VY,
	MX, MY,
	VX + VSize, VY + VSize,
	VX + VSize + VLSize, VY + VLSize);
InitBorderPointAltitudeWithTest(
	VX + VLSize, VY, 
	VX,          VY,
	MX, MY,
	VX + VSize,  VY,
	VX + VLSize, VY - VLSize2);
InitBorderPointAltitudeWithTest(
	VX + VLSize, VY + VSize, 
	VX,          VY + VSize,
	MX, MY,
	VX + VSize,  VY + VSize,
	VX + VLSize, VY + VSize + VLSize);
end;

begin
if RecCount = 0 then
	Exit;
if VSize <= 1 then
	Exit;
VLSize := Trunc((VSize + 1) / 2);
VLSize2 := VSize - VLSize;
if VLSize + VLSize2 = 0 then
	Exit;
MX := VX + VLSize;
MY := VY + VLSize;
if RecCount = 1 then
	begin
	InitMiddlePointAltitude();
	InitBorderPointsAltitudes();
	end;
Rec(VX,          VY,          VLSize,  VAltitude / 2, RecCount - 1);
Rec(VX + VLSize, VY,          VLSize2, VAltitude / 2, RecCount - 1);
Rec(VX,          VY + VLSize, VLSize2, VAltitude / 2, RecCount - 1);
Rec(MX,          MY,          VLSize2, VAltitude / 2, RecCount - 1);
end;

function GetQuantityCounts(const VSize : TSLongInt) : TSLongInt;

function QuantRec(const VSize : TSLongInt) : TSLongInt;
var
	Chunk : TSLongInt;
begin
Result := 0;
if VSize <= 1 then
	Exit;
Chunk := Trunc((VSize + 1) / 2);
Result := Max(QuantRec(Chunk), QuantRec(VSize - Chunk)) + 1;
end;

begin
Result := QuantRec(VSize);
end;

begin
Result := nil;
SetLength(Result, FSize);
for i := 0 to FSize - 1 do
	begin
	SetLength(Result[i], FSize);
	fillchar(Result[i][0], SizeOf(Result[i][0]) * FSize, 0);
	end;

Result[0,         0        ] := FCornersAltitudes[0];
Result[FSize - 1, 0        ] := FCornersAltitudes[1];
Result[FSize - 1, FSize - 1] := FCornersAltitudes[2];
Result[0,         FSize - 1] := FCornersAltitudes[3];

for i := 1 to GetQuantityCounts(FSize) do
	Rec(0, 0, FSize - 1, FAltitude, i);
end;

constructor TSFractalTerrainGenerator.Create();
var
	i : TSLongInt;
begin
inherited;
Size := 7;
for i := 0 to 3 do
	FCornersAltitudes[i] := 0;
FAltitude := 0.4;
end;

destructor TSFractalTerrainGenerator.Destroy();
begin
inherited;
end;

class function TSFractalTerrainGenerator.ClassName() : TSString;
begin
Result := 'TSFractalTerrainGenerator';
end;

end.
