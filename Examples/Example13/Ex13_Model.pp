{$INCLUDE SaGe.inc}
unit Ex13_Model;

interface

uses
	SaGeContext
	,SaGeBased
	,SaGeBase
	,SaGeUtils
	,SaGeRender
	,SaGeCommon
	,SaGeScreen
	,SaGeMesh
	;

type
	TIndex = TSGLongInt;
	TModel = class;
	
	// ����� ��� ������� .. ����� ������� (���) �������
	TWeight = record
		FBoneNum : TIndex;       // ����� �����
		FWeight  : TSGFloat;     // ������� �������
		end;

	// ������� ����� ����������, ������� � ������ �
	// ������������ �������� �� �� ������
	TVertex = record
		FCoord   : TSGVertex3f;              // ���������� �������
		FNorm    : TSGVertex3f;              // �������, ��������� �� �������
		FParents : packed array  of TWeight; // ������ ������, �������� �� �������
		end;

	// �������
	TPoligon=record
		FTextureName      : string;                      // ��� ����� � ���������
		FVertexCoordNum   : TIndex;                      // ���������� ������ (3 �� 4)
		FVertexIndexes    : array [0..3] of TIndex;      // ������ �� ������� ������� � ���������
		FTexCoord         : array [0..3] of TSGVertex2f; // ������ � ����������� ������������
		FTexture          : TSGLongWord;                 // OpenGL-������ ������������� ��������
		FHasTexture       : boolean;                     // ������� ������� ��������
		end;

	// ������ �������
	TNode = record
		FName   : string;     // �������� �����, ������� �������� � �������
		FParent : TIndex;     // ������ �����, � �������� ��������� ������
		end;

	// ����� ������� (������� ��������� �������)
	TBonePos = record
		FTrans : TSGVertex3f;         // �����������
		FRot   : TSGVertex3f;         // �������
		FAbsoluteMatrix : TSGMatrix4; // ���������� ������� �����
		FRelativeMatrix : TSGMatrix4; // ������������� ������� �����
		FQuat  : TSGQuaternion;         // ���������� �����
		end;

	// ���� ��������
	TFrame = record
		FBones : packed array of TBonePos; // ������ � ��������� ������
		end;

	// �������� ���������
	TAction = record
		FName        : string;                 // �������� �������� ��� ����� ��������
		FSpeed       : single;                 // �������� ��������
		FFramesCount : TIndex;                 // ���������� ������ ��������
		FFrames      : packed array of TFrame; // ������ � ������� ��������
		end;

	// ��������� ��������
	TSkelAnimState = object
		FPrevFrame  : TIndex;  // ���������� ����
		FNextFrame  : TIndex;  // ��������� ����
		FPrevAction : TIndex;  // ���������� ��������
		FNextAction : TIndex;  // ��������� ��������
		FSkelTime   : single;  // ����� (�������� �� ���� �� ������� ����� ���������� � ��������� ������)
		FCurrentPos : TFrame;  // ������� ���� ��������� � ������ ������������ �� ������� skelTime
		FShaderAbsoluteMatrixes : packed array[0..31] of TSGMatrix4; // ������ ���������� ������ ��� �������� � ������
		
		procedure ResetState(const VNodesNum : TIndex);
		procedure Animate(var VModel : TModel;const VActionNum : TIndex;const VDelta : TIndex; const VPlayOnce : TSGBoolean);
		procedure CopyBonesForShader();
		end;

	// ��������� �������� ���������
	PTSkelAnimation = ^ TSkelAnimation;
	TSkelAnimation = object
		FActions      : array of TAction;  // ������ ��������, ��������� ���������
		FNodes        : array of TNode;    // �������� �������������� �������� ������� (��� � ���� �����������)
		FNodesNum     : TIndex;            // ���������� �������� � �������
		FReferencePos : array of TBonePos; // Reference-������� ������� (���� ����������������� ������)
		
		procedure MakeReferenceMatrixes();
		procedure MakeBoneMatrixes();
		end;

	// ������ ��������� ������� ��:
	// - �������� �����
	// - ���������
	// - ������
	// - �������� ��������������� ������ ��������� ��������
	TModel = class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			public
		FFileName  : string;            // ��� �����
		FPoligons  : array of TPoligon; // ��������
		FVertexes  : array of TVertex;  // �������
		FLocalized : array of TVertex;  // ���������� ������ (�������� ���������������)
		FAnimation : TSkelAnimation;    // ��������� �������� ������
		FMesh      : TSG3DObject;
			public
		procedure MakeMesh();
		procedure PrepareSkeletalAnimation();
			private
		function GetAnimation():PTSkelAnimation;inline;
			public
		property Animation : PTSkelAnimation read GetAnimation;
		end;

implementation

procedure TSkelAnimState.CopyBonesForShader();
var
	i : TIndex;
begin
for i := 0 to High(FCurrentPos.FBones) do
	FShaderAbsoluteMatrixes[i] := FCurrentPos.FBones[i].FAbsoluteMatrix;
end;

procedure TSkelAnimState.Animate(var VModel : TModel;const VActionNum : TIndex;const VDelta : TIndex; const VPlayOnce : TSGBoolean);
var
	Delta : TSGFloat;
	i, j, k : TIndex;
begin
if Length(FCurrentPos.FBones) = 0 then
	Exit;

if FPrevAction <> VActionNum then
	FNextFrame := 0;

FNextAction := VActionNum;
if FPrevAction = -1 then
	FPrevAction := VActionNum;

Delta := VModel.Context.ElapsedTime * VModel.FAnimation.FActions[FNextAction].FSpeed / 1000;
FSkelTime += Delta;

if FSkelTime > 1 then
	begin
	FSkelTime := 0;
	FPrevAction := FNextAction;
	FPrevFrame := FNextFrame;
	FNextFrame += VDelta;
	
	if FNextFrame > VModel.FAnimation.FActions[FNextAction].FFramesCount - 1 then
		if not VPlayOnce then
			begin
			FPrevAction := FNextAction;
			FNextFrame := 0;
			end
		else
			begin
			FNextAction := FPrevAction;
			FNextFrame  := FPrevFrame;
			end;
	if FNextFrame < 0 then
		begin
		FPrevAction := FNextAction;
		FNextFrame := VModel.FAnimation.FActions[FNextAction].FFramesCount - 1;
		end;
	end;

for i := 0 to VModel.FAnimation.FNodesNum - 1 do
	begin
	FCurrentPos.FBones[i].FTrans :=   VModel.FAnimation.FActions[FPrevAction].FFrames[FPrevFrame].FBones[i].FTrans +
									( VModel.FAnimation.FActions[FNextAction].FFrames[FNextFrame].FBones[i].FTrans -
									  VModel.FAnimation.FActions[FPrevAction].FFrames[FPrevFrame].FBones[i].FTrans ) * FSkelTime;
	FCurrentPos.FBones[i].FQuat := SGQuaternionLerp(VModel.FAnimation.FActions[FPrevAction].FFrames[FPrevFrame].FBones[i].FQuat,
													VModel.FAnimation.FActions[FNextAction].FFrames[FNextFrame].FBones[i].FQuat,FSkelTime);
	SGSetMatrixRotationQuaternion(FCurrentPos.FBones[i].FRelativeMatrix, FCurrentPos.FBones[i].FQuat);
	SGSetMatrixTranslation(FCurrentPos.FBones[i].FRelativeMatrix,FCurrentPos.FBones[i].FTrans);
	if VModel.FAnimation.FNodes[i].FParent <> -1 then
		FCurrentPos.FBones[i].FAbsoluteMatrix := SGMultiplyPartMatrix(FCurrentPos.FBones[VModel.FAnimation.FNodes[i].FParent].FAbsoluteMatrix,FCurrentPos.FBones[i].FRelativeMatrix)
	else
		FCurrentPos.FBones[i].FAbsoluteMatrix := FCurrentPos.FBones[i].FRelativeMatrix;
	end;
end;

procedure TSkelAnimation.MakeReferenceMatrixes();
var
	i : TIndex;
begin
for i := 0 to FNodesNum - 1 do
	begin
	SGSetMatrixRotation   (FReferencePos[i].FRelativeMatrix,FReferencePos[i].FRot);
	SGSetMatrixTranslation(FReferencePos[i].FRelativeMatrix,FReferencePos[i].FTrans);
	FReferencePos[i].FQuat := SGGetQuaternionFromAngleVector3f(FReferencePos[i].FRot);
	if FNodes[i].FParent <> -1 then
		FReferencePos[i].FAbsoluteMatrix := SGMultiplyPartMatrix(FReferencePos[FNodes[i].FParent].FAbsoluteMatrix,FReferencePos[i].FRelativeMatrix)
	else
		FReferencePos[i].FAbsoluteMatrix := FReferencePos[i].FRelativeMatrix;
	end;
end;

procedure TSkelAnimation.MakeBoneMatrixes();
var
	i, j, k : TIndex;
begin
for i:=0 to Length(FActions)-1 do
	for j:=0 to length(FActions[i].FFrames)-1 do
		for k:=0 to FNodesNum -1 do
			begin
			SGSetMatrixRotation   (FActions[i].FFrames[j].FBones[k].FRelativeMatrix,FActions[i].FFrames[j].FBones[k].FRot);
			SGSetMatrixTranslation(FActions[i].FFrames[j].FBones[k].FRelativeMatrix,FActions[i].FFrames[j].FBones[k].FTrans);
			FActions[i].FFrames[j].FBones[k].FQuat := SGGetQuaternionFromAngleVector3f(FActions[i].FFrames[j].FBones[k].FRot);
			if FNodes[k].FParent <> -1 then
				FActions[i].FFrames[j].FBones[k].FAbsoluteMatrix := 
					SGMultiplyPartMatrix(
						FActions[i].FFrames[j].FBones[FNodes[k].FParent].FAbsoluteMatrix,
						FActions[i].FFrames[j].FBones[k].FRelativeMatrix)
			else
				FActions[i].FFrames[j].FBones[k].FAbsoluteMatrix := FActions[i].FFrames[j].FBones[k].FRelativeMatrix;
			end;
end;

procedure TModel.PrepareSkeletalAnimation();
var
	i, k : TIndex;
	FinalVertex, TempVertex : TSGVertex3f;
	Matrix : TSGMatrix4;
begin
FAnimation.MakeReferenceMatrixes();
FAnimation.MakeBoneMatrixes();

SetLength(FLocalized,Length(FVertexes));
for i := 0 to High(FLocalized) do
	begin
	FLocalized[i] := FVertexes[i];
	FinalVertex.Import();
	for k := 0 to High(FLocalized[i].FParents) do
		begin
		TempVertex := FVertexes[i].FCoord;
		Matrix := FAnimation.FReferencePos[FVertexes[i].FParents[k].FBoneNum].FAbsoluteMatrix;
		TempVertex := SGTranslateVectorInverse(Matrix,TempVertex);
		TempVertex := SGRotateVectorInverse(Matrix, TempVertex);
		FinalVertex += TempVertex * FLocalized[i].FParents[k].FWeight;
		end;
	FLocalized[i].FCoord := FinalVertex;
	end;
end;

procedure TModel.MakeMesh();
var
	i, j : TIndex;
	TotalBones : TIndex;
begin
if FMesh <> nil then
	FMesh.Destroy();
FMesh := TSG3DObject.Create();
FMesh.Context := Context;
FMesh.ObjectPoligonesType := SGR_TRIANGLES;
FMesh.HasNormals := True;
FMesh.HasTexture := True;
FMesh.HasColors  := True;
FMesh.EnableCullFace := False;
FMesh.VertexType := SGMeshVertexType4f;
FMesh.SetColorType(SGMeshColorType4f);
FMesh.CountTextureFloatsInVertexArray := 4;
FMesh.Vertexes   := 3*Length(FPoligons);
for i := 0 to Length(FPoligons) - 1 do
	for j := 0 to 2 do
		begin
		TotalBones := Length(FVertexes[FPoligons[i].FVertexIndexes[j]].FParents);
		FMesh.ArVertex4f[3*i+j]^.Import(
			FLocalized[FPoligons[i].FVertexIndexes[j]].FCoord.x,
			FLocalized[FPoligons[i].FVertexIndexes[j]].FCoord.y,
			FLocalized[FPoligons[i].FVertexIndexes[j]].FCoord.z,
			FPoligons[i].FTexture/255);
		FMesh.ArTexVertex4f[3*i+j]^.Import(
			FPoligons[i].FTexCoord[j].x,
			FPoligons[i].FTexCoord[j].y,
			FVertexes[FPoligons[i].FVertexIndexes[j]].FParents[0].FBoneNum/255,
			FVertexes[FPoligons[i].FVertexIndexes[j]].FParents[0].FWeight);
		FMesh.ArNormal[3*i+j]^ := FVertexes[FPoligons[i].FVertexIndexes[j]].FNorm;
		FMesh.ArColor4f[3*i+j]^.Import(
			Byte(TotalBones>1)*FVertexes[FPoligons[i].FVertexIndexes[j]].FParents[1].FBoneNum/255,
			Byte(TotalBones>1)*FVertexes[FPoligons[i].FVertexIndexes[j]].FParents[1].FWeight,
			Byte(TotalBones>2)*FVertexes[FPoligons[i].FVertexIndexes[j]].FParents[2].FBoneNum/255,
			Byte(TotalBones>2)*FVertexes[FPoligons[i].FVertexIndexes[j]].FParents[2].FWeight);
		end;
end;

procedure TSkelAnimState.ResetState(const VNodesNum : TIndex);
begin
FPrevAction := -1;
FNextAction := -1;
FSkelTime   := 0;
FPrevFrame  := 0;
FNextFrame  := 1;
SetLength(FCurrentPos.FBones,VNodesNum);
end;

function TModel.GetAnimation():PTSkelAnimation;inline;
begin
Result := @FAnimation;
end;

constructor TModel.Create(const VContext : TSGContext);
begin
inherited Create(VContext);
FMesh := nil;
end;

destructor TModel.Destroy();
begin
inherited;
end;

procedure TModel.Draw();
begin
if FMesh <> nil then
	FMesh.Draw();
end;

class function TModel.ClassName():TSGString;
begin
Result := 'Ex13_Model';
end;

end.
