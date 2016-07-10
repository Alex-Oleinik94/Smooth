{$INCLUDE SaGe.inc}

unit SaGeFractalTerrain;

interface
uses 
	 Classes

	,SaGeCommon
	,SaGeClasses
	,SaGeBase
	,SaGeBased
	,SaGeImages
	,SaGeCommonClasses
	,SaGeMesh
	,SaGeRenderConstants
	;
type
	TSGFTGCornersAltitudes = array [0..3] of TSGFloat;
	TSGFTGVertexFunction = function(const VX, VY, VSize : TSGLongWord; const VAltitude : TSGFloat) : TSGVector3f;
	TSGFTGColorFunction = function(const VAltitude : TSGFloat) : TSGColor4f;
	TSGFTGTerrain = packed array of packed array of TSGFloat;
	TSGFractalTerrainGenerator = class(TSGNamed)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
			protected
		FCornersAltitudes : TSGFTGCornersAltitudes;
		FSize : TSGLongWord;
		FAltitude : TSGFloat;
			protected
		procedure SetSize(const VSize : TSGLongWord);
			public
		function GenerateMesh(const VContext : ISGContext; const VVertexFunction : TSGFTGVertexFunction; const VColorFunction : TSGFTGColorFunction = nil) : TSG3DObject;
		function GenerateTerrain() : TSGFTGTerrain;
			public
		property Altitude : TSGFloat write FAltitude;
		property Size : TSGLongWord write SetSize;
		property CornersAltitudes : TSGFTGCornersAltitudes write FCornersAltitudes;
		end;

implementation

procedure TSGFractalTerrainGenerator.SetSize(const VSize : TSGLongWord);

function SizeRec(const VRecSize : TSGLongWord) : TSGLongWord;
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

function TSGFractalTerrainGenerator.GenerateMesh(const VContext : ISGContext; const VVertexFunction : TSGFTGVertexFunction; const VColorFunction : TSGFTGColorFunction = nil) : TSG3DObject;
var
	Terrain : TSGFTGTerrain = nil;
	i, ii : TSGLongWord;
	VertexColor : TSGColor4f;
begin
Terrain := GenerateTerrain();
Result := nil;
if Terrain <> nil then
	begin
	Result := TSG3DObject.Create();
	Result.Context := VContext;
	Result.ObjectPoligonesType := SGR_TRIANGLES;
	Result.HasNormals := False;
	Result.HasTexture := False;
	Result.HasColors  := VColorFunction <> nil;
	Result.EnableCullFace := False;
	Result.VertexType := SGMeshVertexType3f;
	if Result.HasColors then
		Result.AutoSetColorType();
	Result.Vertexes := FSize * FSize;
	for i := 0 to FSize - 1 do
		for ii := 0 to FSize - 1 do
			Result.ArVertex3f[i * FSize + ii]^ := VVertexFunction(i, ii, FSize - 1, Terrain[i][ii]);
	if Result.HasColors then
		for i := 0 to FSize - 1 do
			for ii := 0 to FSize - 1 do
				begin
				VertexColor := VColorFunction(Terrain[i][ii]);
				Result.SetColor(i * FSize + ii, VertexColor.r, VertexColor.g, VertexColor.b, VertexColor.a);
				end;
	Result.AddFaceArray();
	Result.PoligonesType[0] := SGR_TRIANGLES;
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

function TSGFractalTerrainGenerator.GenerateTerrain() : TSGFTGTerrain;
var
	i : TSGLongWord;

procedure Rec(const VX, VY, VSize : TSGLongWord; const VAltitude : TSGFloat);
var
	MX, MY : TSGLongWord;
	VLSize : TSGLongWord;
	VLSize2 : TSGLongWord;

function RandomAltitudeShift() : TSGFloat;
begin
Result := VAltitude * ((Random(1001) - 500)/ 500);
end;

procedure InitMiddlePointAltitude();
var
	VAverageAltitude : TSGFloat;
begin
VAverageAltitude := 
	(Result[VX,         VY        ] + 
	 Result[VX + VSize, VY        ] + 
	 Result[VX + VSize, VY + VSize] + 
	 Result[VX,         VY + VSize] ) / 4;
Result[MX, MY] := VAverageAltitude + RandomAltitudeShift();
end;

procedure InitBorderPointAltitude(const VX, VY, VX1, VY1, VX2, VY2 : TSGLongWord);
begin
Result[VX, VY] := (Result[VX1, VY1] + Result[VX2, VY2] ) / 2 + RandomAltitudeShift();
end;

procedure InitBorderPointsAltitudes();
begin
InitBorderPointAltitude(
	VX, VY + VLSize, 
	VX, VY,
	VX, VY + VSize);
InitBorderPointAltitude(
	VX + VSize, VY + VLSize, 
	VX + VSize, VY,
	VX + VSize, VY + VSize);
InitBorderPointAltitude(
	VX + VLSize, VY, 
	VX,          VY,
	VX + VSize,  VY);
InitBorderPointAltitude(
	VX + VLSize, VY + VSize, 
	VX,          VY + VSize,
	VX + VSize,  VY + VSize);
end;

begin
if VSize <= 2 then
	Exit;
VLSize := Trunc((VSize + 1) / 2);
VLSize2 := VSize - VLSize;
//WriteLn(VSize,' ',VLSize,' ',VLSize2);
//ReadLn();
if VLSize + VLSize2 = 0 then
	Exit;
MX := VX + VLSize;
MY := VY + VLSize;
InitMiddlePointAltitude();
InitBorderPointsAltitudes();
Rec(VX,          VY,          VLSize,  VAltitude / 2);
Rec(VX + VLSize, VY,          VLSize2, VAltitude / 2);
Rec(VX,          VY + VLSize, VLSize2, VAltitude / 2);
Rec(MX,          MY,          VLSize2, VAltitude / 2);
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

Rec(0, 0, FSize - 1, FAltitude);
end;

constructor TSGFractalTerrainGenerator.Create();
var
	i : TSGLongWord;
begin
inherited;
Size := 8;
WriteLn(FSize);
for i := 0 to 3 do
	FCornersAltitudes[i] := 0;
FAltitude := 0.4;
end;

destructor TSGFractalTerrainGenerator.Destroy();
begin
inherited;
end;

class function TSGFractalTerrainGenerator.ClassName() : TSGString;
begin
Result := 'TSGFractalTerrainGenerator';
end;

end.
