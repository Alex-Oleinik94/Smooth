{$INCLUDE Smooth.inc}
unit Ex13_Model;

interface

uses
	 Classes
	,SysUtils
	
	,StrMan
	
	,SmoothContextInterface
	,SmoothContextClasses
	,SmoothBase
	,SmoothRenderBase
	,SmoothCommonStructs
	,SmoothScreen
	,SmoothVertexObject
	,SmoothImage
	,SmoothResourceManager
	,SmoothMatrix
	,SmoothQuaternion
	;

type
	TIndex = TSLongInt;
	TModel = class;
	
	// ����� ��� ������� .. ����� ������� (���) �������
	TWeight = record
		FBoneNum : TIndex;       // ����� �����
		FWeight  : TSFloat;     // ������� �������
		end;

	// ������� ����� ����������, ������� � ������ �
	// ������������ �������� �� �� ������
	TVertex = object
		FCoord   : TSVertex3f;              // ���������� �������
		FNorm    : TSVertex3f;              // �������, ��������� �� �������
		FParents : packed array  of TWeight; // ������ ������, �������� �� �������
		
		procedure Clear();
		end;

	// �������
	TPoligon = record
		FTextureName      : string;                      // ��� ����� � ���������
		FVertexCoordNum   : TIndex;                      // ���������� ������ (3 �� 4)
		FVertexIndexes    : array [0..3] of TIndex;      // ������ �� ������� ������� � ���������
		FTexCoord         : array [0..3] of TSVertex2f; // ������ � ����������� ������������
		FTexture          : TSLongWord;                 // OpenGL-������ ������������� ��������
		FHasTexture       : boolean;                     // ������� ������� ��������
		end;

	// ������ �������
	TNode = record
		FName   : string;     // �������� �����, ������� �������� � �������
		FParent : TIndex;     // ������ �����, � �������� ��������� ������
		end;

	// ����� ������� (������� ��������� �������)
	TBonePos = record
		FTrans : TSVertex3f;           // �����������
		FRot   : TSVertex3f;           // �������
		FAbsoluteMatrix : TSMatrix4x4; // ���������� ������� �����
		FRelativeMatrix : TSMatrix4x4; // ������������� ������� �����
		FQuat  : TSQuaternion;         // ���������� �����
		end;

	// ���� ��������
	TFrame = object
		FBones : packed array of TBonePos; // ������ � ��������� ������
		
		procedure Clear();
		end;

	// �������� ���������
	TAction = object
		FName        : string;                 // �������� �������� ��� ����� ��������
		FSpeed       : single;                 // �������� ��������
		FFramesCount : TIndex;                 // ���������� ������ ��������
		FFrames      : packed array of TFrame; // ������ � ������� ��������
		
		procedure Clear();
		end;

	// ��������� ��������
	TSkelAnimState = object
		FPrevFrame  : TIndex;  // ���������� ����
		FNextFrame  : TIndex;  // ��������� ����
		FPrevAction : TIndex;  // ���������� ��������
		FNextAction : TIndex;  // ��������� ��������
		FSkelTime   : single;  // ����� (�������� �� ���� �� ������� ����� ���������� � ��������� ������)
		FCurrentPos : TFrame;  // ������� ���� ��������� � ������ ������������ �� ������� skelTime
		FShaderAbsoluteMatrixes : packed array[0..31] of TSMatrix4x4; // ������ ���������� ������ ��� �������� � ������
		FSpeed      : TSFloat;
		
		procedure ResetState(const VNodesNum : TIndex);
		procedure Animate(var VModel : TModel;const VActionNum : TIndex;const VDelta : TIndex; const VPlayOnce : TSBoolean);
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
		procedure Clear();
		end;

	// ������ ��������� ������� ��:
	// - �������� �����
	// - ���������
	// - ������
	// - �������� ��������������� ������ ��������� ��������
	TModel = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
			public
		FFileName  : string;            // ��� �����
		FPoligons  : array of TPoligon; // ��������
		FVertices  : array of TVertex;  // �������
		FLocalized : array of TVertex;  // ���������� ������ (�������� ���������������)
		FAnimation : TSkelAnimation;    // ��������� �������� ������
		F3dObject      : TS3DObject;
		FTextures  : array of TSImage;
		FTexturesBlock :  TSTextureBlock;
			public
		procedure Make3dObject();
		procedure PrepareSkeletalAnimation();
		procedure LoadTextures(const VPath : TSString;const EnafTexCount : LongWord = 0);
		procedure Load(const VFileName : TSString);
		procedure LoadAnimation(const VFileName : TSString);
		function GetTextureHandle (const FileName : String):LongWord;
		function GetTexturesCount():TSLongWord;inline;
			private
		function GetAnimation():PTSkelAnimation;inline;
			public
		property TexturesBlock : TSTextureBlock read FTexturesBlock;
		property Animation : PTSkelAnimation read GetAnimation;
		end;

function GetValue(S1 : ShortString; const Index : TIndex):TSFloat;inline;

implementation

uses
	 SmoothStreamUtils
	,SmoothStringUtils
	;

function TModel.GetTexturesCount():TSLongWord;inline;
begin
if FTextures <> nil then
	Result := Length(FTextures)
else
	Result := 0;
end;

procedure TFrame.Clear();
begin
if FBones <> nil then
	SetLength(FBones,0);
end;

procedure TAction.Clear();
var
	i : TIndex;
begin
if FFrames <> nil then
	begin
	for i := 0 to High(FFrames) do
		FFrames[i].Clear();
	SetLength(FFrames,0);
	end;
FName := '';
FFramesCount := 0;
end;

procedure TSkelAnimation.Clear();
var
	i : TIndex;
begin
if FActions <> nil then
	begin
	for i := 0 to High(FActions) do
		FActions[i].Clear();
	SetLength(FActions,0);
	end;
if FNodes <> nil then
	SetLength(FNodes,0);
if FReferencePos <> nil then
	SetLength(FReferencePos,0);
FNodesNum := 0;
end;

destructor TModel.Destroy();
var
	i : TIndex;
begin
if F3dObject <> nil then
	F3dObject.Destroy();
if FVertices <> nil then
	begin
	for i := 0 to High(FVertices) do
		FVertices[i].Clear();
	SetLength(FVertices,0);
	end;
if FLocalized <> nil then
	begin
	for i := 0 to High(FLocalized) do
		FLocalized[i].Clear();
	SetLength(FLocalized,0);
	end;
if FTextures <> nil then
	begin
	for i := 0 to High(FTextures) do
		FTextures[i].Destroy();
	SetLength(FTextures,0);
	end;
if FPoligons <> nil then
	SetLength(FPoligons,0);
FAnimation.Clear();
if FTexturesBlock <> nil then
	FTexturesBlock.Destroy();
inherited;
end;

procedure TVertex.Clear();
begin
SetLength(FParents,0);
end;

function TModel.GetTextureHandle (const FileName : String):LongWord;
var
	i : TIndex;
begin
Result := 0;

if FTextures <> nil then
	for i := 0 to High(FTextures) do
		if FTextures[i].Name = FileName then
			begin
			Result := FTextures[i].Texture;
			break;
			end;
end;

function GetValue(S1 : ShortString; const Index : TIndex):TSFloat;inline;
var
	S : String;
begin
S := String(S1);
S := Trim(S);
S := StringWordGet(S,' ',Index);
Result := SValFloat(S);
end;

procedure TModel.Load(const VFileName : TSString);
var 
	Stream: TMemoryStream;
	s     : string;
	i,j,k : TIndex;
begin
Stream := TMemoryStream.Create();
SResourceFiles.LoadMemoryStreamFromFile(Stream,VFileName);
Stream.Position := 0;

while SReadLnStringFromStream(Stream) <> 'nodes' do ;

i:=0;
SetLength(FAnimation.FNodes,0);
repeat
	s := SReadLnStringFromStream(Stream);
	if s<>'end' then
		begin
		SetLength(FAnimation.FNodes, i+1);
		FAnimation.FNodes[i].FName   := StringWordGet(s, '"', 2);
		FAnimation.FNodes[i].FParent := StrToInt(StringWordGet(s, '"', 3));
		Inc(i);
		end;
until s='end';

FAnimation.FNodesNum :=Length(FAnimation.FNodes);
SetLength(FAnimation.FReferencePos,FAnimation.FNodesNum);

while SReadLnStringFromStream(Stream) <> 'time 0' do ;

i:=0;
repeat
	s := SReadLnStringFromStream(Stream);
	if s<>'end' then
	with FAnimation.FReferencePos[i] do
		begin
		FTrans.Import(
			GetValue(S,2),
			GetValue(S,3),
			GetValue(S,4));
		FRot.Import(
			GetValue(S,5),
			GetValue(S,6),
			GetValue(S,7));
		FQuat := SGetQuaternionFromAngleVector3f(FRot);
		Inc(i);
		end;
until s='end';

while SReadLnStringFromStream(Stream) <> 'triangles' do ;

i := 0;
SetLength(FPoligons,0);
SetLength(FVertices,0);
repeat
	s := SReadLnStringFromStream(Stream);
	if s<>'end' then
		begin
		SetLength(FPoligons,i+1);
		FPoligons[i].FTextureName := s;
		FPoligons[i].FVertexCoordNum := 3;
		for j:=0 to 2 do
			begin
			SetLength(FVertices,Length(FVertices)+1);
			k := High(FVertices);
			s := SReadLnStringFromStream(Stream);
			SetLength(FVertices[k].FParents,1);
			FVertices[k].FParents[0].FBoneNum := StrToInt(StringWordGet(Trim(s),' ',1));
			FVertices[k].FParents[0].FWeight  := 1;
			FVertices[k].FCoord.Import(
				GetValue(S,2),
				GetValue(S,3),
				GetValue(S,4));
			FVertices[k].FNorm.Import(
				GetValue(S,5),
				GetValue(S,6),
				GetValue(S,7));
			FPoligons[i].FTexCoord[j].Import(
				GetValue(S,8),
				GetValue(S,9));
			FPoligons[i].FVertexIndexes[j] := k;
			end;
		Inc(i);
		end;
until s='end';

Stream.Destroy();
end;

procedure TModel.LoadAnimation(const VFileName : TSString);
var Stream       : TMemoryStream;
    s            : string;
    i, j         : TIndex;
    ActionIndex  : TIndex;
begin
Stream := TMemoryStream.Create();
SResourceFiles.LoadMemoryStreamFromFile(Stream,VFileName);
Stream.Position := 0;

SetLength(FAnimation.FActions,Length(FAnimation.FActions)+1);
ActionIndex := High(FAnimation.FActions);

FAnimation.FActions[ActionIndex].FName  := VFileName;
FAnimation.FActions[ActionIndex].FSpeed := 15; //default

while SReadLnStringFromStream(Stream) <> 'skeleton' do ;

s:='';
i:=0;
j:=0;
repeat
	s := SReadLnStringFromStream(Stream);
	if s='end' then
		break;
	if StringWordGet (s, ' ', 1) = 'time' then
		begin
		i:=0;
		Inc(j);
		SetLength(FAnimation.FActions[ActionIndex].FFrames,j);
		end
	else
		begin
		Inc(i);
		SetLength(FAnimation.FActions[ActionIndex].FFrames[j - 1].FBones, i);
		with FAnimation.FActions[ActionIndex].FFrames[j - 1] do
			begin
			FBones[i - 1].FTrans.Import(
				GetValue(S,2),
				GetValue(S,3),
				GetValue(S,4));
				
			FBones[i - 1].FRot.Import(
				GetValue(S,5),
				GetValue(S,6),
				GetValue(S,7));
			FBones[i - 1].FQuat := SGetQuaternionFromAngleVector3f(FBones[i - 1].FRot);
			end;
		end;
	FAnimation.FActions[ActionIndex].FFramesCount := Length(FAnimation.FActions[ActionIndex].FFrames);
until False;

Stream.Destroy();
end;

procedure TModel.LoadTextures(const VPath : TSString;const EnafTexCount : LongWord = 0);
var
	i, j: TIndex;
	Loaded : TSBoolean;
begin
for i := 0 to High(FPoligons) do
	begin
	Loaded := False;
	if FTextures <> nil then
		for j := 0 to High(FTextures) do
			if FTextures[j].Name = FPoligons[i].FTextureName then
				begin
				Loaded := True;
				FPoligons[i].FTexture := FTextures[j].Texture;
				break
				end;
	if not Loaded then
		begin
		FPoligons[i].FHasTexture := FPoligons[i].FTextureName <> 'NOTEXTURE';
		if FPoligons[i].FHasTexture then
			begin
			if FTextures = nil then
				SetLength(FTextures,1)
			else
				SetLength(FTextures,Length(FTextures)+1);
			FTextures[High(FTextures)] := SCreateImageFromFile(Context, VPath+FPoligons[i].FTextureName);
			FTextures[High(FTextures)].Name := FPoligons[i].FTextureName;
			end;
		end;
	end;
FTexturesBlock := TSTextureBlock.Create(Context);
FTexturesBlock.Size := Length(FTextures) + EnafTexCount;
FTexturesBlock.Generate();
for i := 0 to High(FTextures) do
	FTextures[i].LoadTextureWithBlock(FTexturesBlock);
for i := 0 to High(FPoligons) do
	begin
	for j := 0 to High(FTextures) do
		if FTextures[j].FName = FPoligons[i].FTextureName then
			begin
			FPoligons[i].FTexture := FTextures[j].Texture;
			break;
			end;
	end;
end;

procedure TSkelAnimState.CopyBonesForShader();
var
	i : TIndex;
begin
for i := 0 to High(FCurrentPos.FBones) do
	FShaderAbsoluteMatrixes[i] := FCurrentPos.FBones[i].FAbsoluteMatrix;
end;

procedure TSkelAnimState.Animate(var VModel : TModel;const VActionNum : TIndex;const VDelta : TIndex; const VPlayOnce : TSBoolean);
var
	Delta : TSFloat;
	i : TIndex;
begin
if Length(FCurrentPos.FBones) = 0 then
	Exit;

if FPrevAction <> VActionNum then
	FNextFrame := 0;

FNextAction := VActionNum;
if FPrevAction = -1 then
	FPrevAction := VActionNum;

Delta := VModel.Context.ElapsedTime * VModel.FAnimation.FActions[FNextAction].FSpeed / 100 * FSpeed;
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
	FCurrentPos.FBones[i].FQuat := SQuaternionLerp(VModel.FAnimation.FActions[FPrevAction].FFrames[FPrevFrame].FBones[i].FQuat,
													VModel.FAnimation.FActions[FNextAction].FFrames[FNextFrame].FBones[i].FQuat,FSkelTime);
	SSetMatrixRotationQuaternion(FCurrentPos.FBones[i].FRelativeMatrix, FCurrentPos.FBones[i].FQuat);
	SSetMatrixTranslation(FCurrentPos.FBones[i].FRelativeMatrix,FCurrentPos.FBones[i].FTrans);
	if VModel.FAnimation.FNodes[i].FParent <> -1 then
		FCurrentPos.FBones[i].FAbsoluteMatrix := SMultiplyPartMatrix(FCurrentPos.FBones[VModel.FAnimation.FNodes[i].FParent].FAbsoluteMatrix,FCurrentPos.FBones[i].FRelativeMatrix)
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
	SSetMatrixRotation   (FReferencePos[i].FRelativeMatrix,FReferencePos[i].FRot);
	SSetMatrixTranslation(FReferencePos[i].FRelativeMatrix,FReferencePos[i].FTrans);
	FReferencePos[i].FQuat := SGetQuaternionFromAngleVector3f(FReferencePos[i].FRot);
	if FNodes[i].FParent <> -1 then
		FReferencePos[i].FAbsoluteMatrix := SMultiplyPartMatrix(FReferencePos[FNodes[i].FParent].FAbsoluteMatrix,FReferencePos[i].FRelativeMatrix)
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
			SSetMatrixRotation   (FActions[i].FFrames[j].FBones[k].FRelativeMatrix,FActions[i].FFrames[j].FBones[k].FRot);
			SSetMatrixTranslation(FActions[i].FFrames[j].FBones[k].FRelativeMatrix,FActions[i].FFrames[j].FBones[k].FTrans);
			FActions[i].FFrames[j].FBones[k].FQuat := SGetQuaternionFromAngleVector3f(FActions[i].FFrames[j].FBones[k].FRot);
			if FNodes[k].FParent <> -1 then
				FActions[i].FFrames[j].FBones[k].FAbsoluteMatrix := 
					SMultiplyPartMatrix(
						FActions[i].FFrames[j].FBones[FNodes[k].FParent].FAbsoluteMatrix,
						FActions[i].FFrames[j].FBones[k].FRelativeMatrix)
			else
				FActions[i].FFrames[j].FBones[k].FAbsoluteMatrix := FActions[i].FFrames[j].FBones[k].FRelativeMatrix;
			end;
end;

procedure TModel.PrepareSkeletalAnimation();
var
	i, k : TIndex;
	FinalVertex, FinalNormal, TempVertex : TSVertex3f;
	Matrix : TSMatrix4x4;
begin
FAnimation.MakeReferenceMatrixes();
FAnimation.MakeBoneMatrixes();

SetLength(FLocalized,Length(FVertices));
for i := 0 to High(FLocalized) do
	begin
	FLocalized[i] := FVertices[i];
	FinalVertex.Import();
	FinalNormal.Import();
	for k := 0 to High(FLocalized[i].FParents) do
		begin
		Matrix := FAnimation.FReferencePos[FVertices[i].FParents[k].FBoneNum].FAbsoluteMatrix;
		
		TempVertex  := STranslateVectorInverse(Matrix, FVertices[i].FCoord);
		TempVertex  := SRotateVectorInverse   (Matrix, TempVertex);
		FinalVertex += TempVertex * FLocalized[i].FParents[k].FWeight;
		
		FinalNormal += SRotateVectorInverse   (Matrix, FVertices[i].FNorm);
		end;
	FLocalized[i].FCoord := FinalVertex;
	FLocalized[i].FNorm  := FinalNormal;
	end;
end;

procedure TModel.Make3dObject();

function TexNum(const Texture : TSLongWord):TSLongWord;
var
	i : TSLongWord;
begin
Result := 0;
if (FTextures <> nil) and (Length(FTextures)>0) then
	for i := 0 to High(FTextures) do
		if FTextures[i].Texture = Texture then
			begin
			Result := i;
			break;
			end;
end;

var
	i, j : TIndex;
	TotalBones : TIndex;
begin
if F3dObject <> nil then
	F3dObject.Destroy();
F3dObject := TS3DObject.Create();
F3dObject.Context := Context;
F3dObject.ObjectPoligonesType := SR_TRIANGLES;
F3dObject.HasNormals := True;
F3dObject.HasTexture := True;
F3dObject.HasColors  := True;
F3dObject.EnableCullFace := False;
F3dObject.VertexType := S3dObjectVertexType4f;
F3dObject.SetColorType(S3dObjectColorType4f);
F3dObject.CountTextureFloatsInVertexArray := 4;
F3dObject.Vertices   := 3*Length(FPoligons);
for i := 0 to Length(FPoligons) - 1 do
	for j := 0 to 2 do
		begin
		TotalBones := Length(FVertices[FPoligons[i].FVertexIndexes[j]].FParents);
		F3dObject.ArVertex4f[3*i+j]^.Import(
			FLocalized[FPoligons[i].FVertexIndexes[j]].FCoord.x,
			FLocalized[FPoligons[i].FVertexIndexes[j]].FCoord.y,
			FLocalized[FPoligons[i].FVertexIndexes[j]].FCoord.z,
			TexNum(FPoligons[i].FTexture)/255);
		F3dObject.ArTexVertex4f[3*i+j]^.Import(
			FPoligons[i].FTexCoord[j].x,
			FPoligons[i].FTexCoord[j].y,
			FVertices[FPoligons[i].FVertexIndexes[j]].FParents[0].FBoneNum/255,
			FVertices[FPoligons[i].FVertexIndexes[j]].FParents[0].FWeight);
		F3dObject.ArNormal[3*i+j]^ := FVertices[FPoligons[i].FVertexIndexes[j]].FNorm;
		F3dObject.ArColor4f[3*i+j]^.Import(
			Byte(TotalBones>1)*FVertices[FPoligons[i].FVertexIndexes[j]].FParents[1].FBoneNum/255,
			Byte(TotalBones>1)*FVertices[FPoligons[i].FVertexIndexes[j]].FParents[1].FWeight,
			Byte(TotalBones>2)*FVertices[FPoligons[i].FVertexIndexes[j]].FParents[2].FBoneNum/255,
			Byte(TotalBones>2)*FVertices[FPoligons[i].FVertexIndexes[j]].FParents[2].FWeight);
		end;
F3dObject.LoadToVBO();
end;

procedure TSkelAnimState.ResetState(const VNodesNum : TIndex);
begin
FPrevAction := -1;
FNextAction := -1;
FSkelTime   := 0;
FPrevFrame  := 0;
FNextFrame  := 1;
FSpeed      := 1;
SetLength(FCurrentPos.FBones,VNodesNum);
end;

function TModel.GetAnimation():PTSkelAnimation;inline;
begin
Result := @FAnimation;
end;

constructor TModel.Create(const VContext : ISContext);
begin
inherited Create(VContext);
F3dObject := nil;
FTextures := nil;
FTexturesBlock := nil;
end;

procedure TModel.Paint();
begin
if F3dObject <> nil then
	F3dObject.Paint();
end;

class function TModel.ClassName():TSString;
begin
Result := 'Ex13_Model';
end;

end.
