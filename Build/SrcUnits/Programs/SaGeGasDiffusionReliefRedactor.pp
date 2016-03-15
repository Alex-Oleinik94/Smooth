{$INCLUDE SaGe.inc}

unit SaGeGasDiffusionReliefRedactor;

interface

uses
	 dos
	,SaGeBase
	,Classes
	,SaGeBased
	,SaGeMesh
	,SaGeContext
	,SaGeRender
	,SaGeCommon
	,SaGeUtils
	,SaGeScreen
	,SaGeImages
	,SaGeImagesBase;
type
	TSGGasDiffusionSingleRelief = object
		FEnabled : Boolean;
		FType : Boolean;
		FPoints : packed array of TSGVertex;
		FPolygones : packed array of packed array of LongWord;
		
		procedure Draw(const VRender : TSGRender);
		procedure DrawLines(const VRender : TSGRender);
		procedure DrawPolygones(const VRender : TSGRender);
		procedure ExportToMesh(const VMesh : TSGCustomModel;const index : byte = -1);
		procedure ExportToMeshLines(const VMesh : TSGCustomModel;const index : byte = -1;const WithVector : Boolean = False);
		procedure ExportToMeshPolygones(const VMesh : TSGCustomModel;const index : byte = -1);
		procedure Clear();
		procedure InitBase();
		end;
type
	TSGGasDiffusionRelief = object
		FData : packed array [0..5] of TSGGasDiffusionSingleRelief;
		
		procedure Draw(const VRender : TSGRender);
		procedure Clear();
		procedure InitBase();
		procedure ExportToMesh(const VMesh : TSGCustomModel);
		end;
	PSGGasDiffusionSingleRelief = ^ TSGGasDiffusionSingleRelief;
	PSGGasDiffusionRelief = ^ TSGGasDiffusionRelief;
type
	TSGGasDiffusionReliefRedactor = class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		procedure Draw();override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		FRelief : PSGGasDiffusionRelief;
		FSingleRelief : PSGGasDiffusionSingleRelief;
			public
		procedure SetActiveSingleRelief(const index : LongInt = -1);
		procedure StartRedactoring();
		procedure StopRedactoring();
			public
		property Relief : PSGGasDiffusionRelief read FRelief write FRelief;
		end;

function GetReliefMatrix(const i : byte) : TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function GetReliefInversedMatrix(const i : byte) : TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

var
	Matrixes : array[-1..5] of TSGMatrix4;
	InversedMatrixes : array[-1..5] of TSGMatrix4;

function GetReliefInversedMatrix(const i : byte) : TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := InversedMatrixes[i];
end;

function GetReliefMatrix(const i : byte) : TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Matrixes[i];
end;

procedure TSGGasDiffusionReliefRedactor.StartRedactoring();
begin

end;

procedure TSGGasDiffusionReliefRedactor.StopRedactoring();
begin

end;


procedure TSGGasDiffusionSingleRelief.ExportToMeshLines(const VMesh : TSGCustomModel;const index : byte = -1;const WithVector : Boolean = False);
var
	i : LongWord;
begin
if FPoints <> nil then if Length(FPoints) <> 0 then
	begin
	VMesh.AddObject();
	VMesh.LastObject().ObjectPoligonesType := SGR_LINE_LOOP;
	VMesh.LastObject().HasNormals := False;
	VMesh.LastObject().HasTexture := False;
	VMesh.LastObject().HasColors  := True;
	VMesh.LastObject().EnableCullFace := False;
	VMesh.LastObject().VertexType := SGMeshVertexType3f;
	VMesh.LastObject().SetColorType(SGMeshColorType4b);
	VMesh.LastObject().Vertexes := Length(FPoints);
	VMesh.LastObject().ObjectMatrix := Matrixes[index];
	
	for i := 0 to High(FPoints) do
		begin
		VMesh.LastObject().ArVertex3f[i]^ := FPoints[i];
		VMesh.LastObject().SetColor(i,0,0.5,1,1);
		end;
	end;
end;

procedure TSGGasDiffusionSingleRelief.ExportToMeshPolygones(const VMesh : TSGCustomModel;const index : byte = -1);
var
	i,ii : LongWord;
begin
if FPoints <> nil then if Length(FPoints) <> 0 then
	begin	
	if FEnabled then if FPolygones <> nil then if Length(FPolygones) <> 0 then
		for i := 0 to High(FPolygones) do
			if FPolygones[i] <> nil then if Length(FPolygones[i]) <> 0 then
				begin
				VMesh.AddObject();
				VMesh.LastObject().ObjectPoligonesType := SGR_TRIANGLES;
				VMesh.LastObject().HasNormals := False;
				VMesh.LastObject().HasTexture := False;
				VMesh.LastObject().HasColors  := True;
				VMesh.LastObject().EnableCullFace := False;
				VMesh.LastObject().VertexType := SGMeshVertexType3f;
				VMesh.LastObject().SetColorType(SGMeshColorType4b);
				VMesh.LastObject().Vertexes := 3*(Length(FPolygones[i]) - 2);
				VMesh.LastObject().ObjectMatrix := Matrixes[index];
				
				for ii := 0 to Length(FPolygones[i])-3 do
					begin
					VMesh.LastObject().ArVertex3f[ii*3+0]^ := FPoints[FPolygones[i][0]];
					VMesh.LastObject().ArVertex3f[ii*3+1]^ := FPoints[FPolygones[i][ii+1]];
					VMesh.LastObject().ArVertex3f[ii*3+2]^ := FPoints[FPolygones[i][ii+2]];
					if FType then
						begin
						VMesh.LastObject().SetColor(ii*3+0,0,  1,1,0.2);
						VMesh.LastObject().SetColor(ii*3+1,0,  1,1,0.2);
						VMesh.LastObject().SetColor(ii*3+2,0,  1,1,0.2);
						end
					else
						begin
						VMesh.LastObject().SetColor(ii*3+0,0,0.5,1,0.2);
						VMesh.LastObject().SetColor(ii*3+1,0,0.5,1,0.2);
						VMesh.LastObject().SetColor(ii*3+2,0,0.5,1,0.2);
						end;
					end;
				end;
	end;
end;

procedure TSGGasDiffusionSingleRelief.ExportToMesh(const VMesh : TSGCustomModel;const index : byte = -1);
begin
ExportToMeshLines(VMesh,index,False);
ExportToMeshPolygones(VMesh,index);
end;

procedure TSGGasDiffusionSingleRelief.InitBase();
begin
FEnabled := False;
SetLength(FPoints,4);
SetLength(FPolygones,1);
SetLength(FPolygones[0],4);
FPoints[0].Import(1,1);
FPoints[1].Import(-1,1);
FPoints[2].Import(-1,-1);
FPoints[3].Import(1,-1);
FPolygones[0][0] := 0;
FPolygones[0][1] := 1;
FPolygones[0][2] := 2;
FPolygones[0][3] := 3;
end;

procedure TSGGasDiffusionSingleRelief.Draw(const VRender : TSGRender);
begin
DrawLines(VRender);
DrawPolygones(VRender);
end;

procedure TSGGasDiffusionSingleRelief.DrawLines(const VRender : TSGRender);
var
	i,ii:LongWord;
begin
if FPolygones <> nil then
	begin
	VRender.Color4f(0,0.5,1,1);
	for i := 0 to High(FPolygones) do
		begin
		VRender.BeginScene(SGR_LINE_LOOP);
		for ii := 0 to High(FPolygones[i]) do
			FPoints[FPolygones[i][ii]].Vertex(VRender);
		VRender.EndScene();
		end;
	if FEnabled then
		begin
		VRender.Color4f(1,1,1,0.7);
		VRender.BeginScene(SGR_LINES);
		VRender.Vertex3f(0,0,0);
		VRender.Vertex3f(0,0,0.8);
		VRender.EndScene();
		end;
	end;
end;

procedure TSGGasDiffusionSingleRelief.DrawPolygones(const VRender : TSGRender);
var
	i,ii:LongWord;
begin
if (FPolygones <> nil) and FEnabled then
	begin
	if FType then
		VRender.Color4f(0,1,1,0.2)
	else
		VRender.Color4f(0,0.5,1,0.2);
	for i := 0 to High(FPolygones) do
		begin
		VRender.BeginScene(SGR_POLYGON);
		for ii := 0 to High(FPolygones[i]) do
			FPoints[FPolygones[i][ii]].Vertex(VRender);
		VRender.EndScene();
		end;
	end;
end;

procedure TSGGasDiffusionRelief.ExportToMesh(const VMesh : TSGCustomModel);
var
	i : LongWord;
begin
for i := 0 to 5 do
	begin
	FData[i].ExportToMeshLines(VMesh,i,False);
	end;
for i := 0 to 5 do
	begin
	FData[i].ExportToMeshPolygones(VMesh,i);
	end;
end;

procedure TSGGasDiffusionRelief.InitBase();
var
	i : LongWord;
begin
for i := 0 to 5 do
	begin
	FData[i].InitBase();
	end;
end;

procedure TSGGasDiffusionRelief.Draw(const VRender : TSGRender);
var
	i : LongWord;
begin
for i := 0 to 5 do
	begin
	VRender.PushMatrix();
	VRender.MultMatrixf(@Matrixes[i]);
	FData[i].DrawLines(VRender);
	VRender.PopMatrix();
	end;
for i := 0 to 5 do
	begin
	VRender.PushMatrix();
	VRender.MultMatrixf(@Matrixes[i]);
	FData[i].DrawPolygones(VRender);
	VRender.PopMatrix();
	end;
end;

procedure TSGGasDiffusionSingleRelief.Clear();
var
	i : integer;
begin
SetLength(FPoints,0);
if FPolygones <> nil then
	for i := 0 to High(FPolygones) do
		SetLength(FPolygones[i],0);
SetLength(FPoints,0);
FEnabled := False;
FType := False;
end;

procedure TSGGasDiffusionRelief.Clear();
var
	i : Byte;
begin
for i := 0 to 5 do
	FData[i].Clear();
end;

procedure TSGGasDiffusionReliefRedactor.SetActiveSingleRelief(const index : LongInt = -1);
begin
if (index >= 0) and (index <= 5) then
	FSingleRelief := @FRelief^.FData[index]
else
	FSingleRelief := nil;
end;

constructor TSGGasDiffusionReliefRedactor.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FCamera := TSGCamera.Create();
FCamera.Context := Context;
FSingleRelief := nil;
FRelief := nil;
end;

procedure TSGGasDiffusionReliefRedactor.Draw();
begin
FCamera.CallAction();
if FSingleRelief = nil then
	begin
	FRelief^.Draw(Render);
	end
else if FRelief <> nil then
	begin
	FSingleRelief^.Draw(Render);
	end;
end;

destructor TSGGasDiffusionReliefRedactor.Destroy();
begin
inherited;
end;

class function TSGGasDiffusionReliefRedactor.ClassName():TSGString;
begin
Result := 'TSGGasDiffusionReliefRedactor';
end;

procedure InverseMtrixess();
var
	v : TSGVertex3f;
begin
InversedMatrixes[-1] := SGInverseMatrix(Matrixes[-1]);
InversedMatrixes[0] := SGInverseMatrix(Matrixes[0]);// SGSetMatrixTranslation(InversedMatrixes[0],SGVertexImport(0,-1,0));
// SGMultiplyPartMatrix(SGInverseMatrix(Matrixes[0]), SGGetTranslateMatrix(SGVertexImport(0,0,-1)));
// := SGInverseMatrix(SGMultiplyPartMatrix(SGGetTranslateMatrix(SGVertexImport(0,0,-1)),SGGetRotateMatrix(pi/2,SGVertexImport(1,0,0))));
InversedMatrixes[1] := SGInverseMatrix(SGMultiplyPartMatrix(SGGetTranslateMatrix(SGVertexImport(0,0,-1)),SGGetRotateMatrix(pi/2,SGVertexImport(-1,0,0))));
InversedMatrixes[2] := SGInverseMatrix(SGMultiplyPartMatrix(SGGetTranslateMatrix(SGVertexImport(0,0,-1)),SGGetRotateMatrix(pi/2,SGVertexImport(0,1,0))));
InversedMatrixes[3] := SGInverseMatrix(Matrixes[3]);
InversedMatrixes[4] := SGInverseMatrix(Matrixes[4]);
InversedMatrixes[5] := SGInverseMatrix(Matrixes[5]);
//SGWriteMatrix4(@Matrixes[0]);
end;

initialization
begin
Matrixes[-1] := SGGetIdentityMatrix();
Matrixes[0] := SGMultiplyPartMatrix(SGGetRotateMatrix(pi/2,SGVertexImport(1,0,0)),SGGetTranslateMatrix(SGVertexImport(0,0,-1)));
Matrixes[1] := SGMultiplyPartMatrix(SGGetRotateMatrix(pi/2,SGVertexImport(-1,0,0)) , SGGetTranslateMatrix(SGVertexImport(0,0,-1)));
Matrixes[2] := SGMultiplyPartMatrix(SGGetRotateMatrix(pi/2,SGVertexImport(0,1,0)) , SGGetTranslateMatrix(SGVertexImport(0,0,-1)));
Matrixes[3] := SGMultiplyPartMatrix(SGGetRotateMatrix(pi/2,SGVertexImport(0,-1,0)) , SGGetTranslateMatrix(SGVertexImport(0,0,-1)));
Matrixes[4] := SGMultiplyPartMatrix(SGGetRotateMatrix(pi/2,SGVertexImport(0,0,-1)) , SGGetTranslateMatrix(SGVertexImport(0,0,-1)));
Matrixes[5] := SGMultiplyPartMatrix(SGGetRotateMatrix(2*pi/2,SGVertexImport(1,0,0)) , SGGetTranslateMatrix(SGVertexImport(0,0,-1)));
InverseMtrixess();
end

finalization
begin

end;

end.
