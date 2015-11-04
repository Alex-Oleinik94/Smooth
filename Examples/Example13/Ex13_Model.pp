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
	,SaGeImages
	,Classes
	,SysUtils
	,StrMan
	;

type
	TIndex = TSGLongInt;
	TModel = class;
	
	// Кость под номером .. имеет степень (вес) влияния
	TWeight = record
		FBoneNum : TIndex;       // Номер кости
		FWeight  : TSGFloat;     // Степень слияния
		end;

	// Вершина имеет координату, нормаль и данные о
	// прикреплённых влияющих на неё костях
	TVertex = object
		FCoord   : TSGVertex3f;              // координата вершины
		FNorm    : TSGVertex3f;              // нормаль, выходящая из вершины
		FParents : packed array  of TWeight; // список костей, влияющих на вершину
		
		procedure Clear();
		end;

	// Полигон
	TPoligon = record
		FTextureName      : string;                      // имя файла с текстурой
		FVertexCoordNum   : TIndex;                      // количество вершин (3 ил 4)
		FVertexIndexes    : array [0..3] of TIndex;      // ссылки на индексы массива с вершинами
		FTexCoord         : array [0..3] of TSGVertex2f; // массив с текстурными координатами
		FTexture          : TSGLongWord;                 // OpenGL-евский идентификатор текстуры
		FHasTexture       : boolean;                     // признак наличия текстуры
		end;

	// Сустав скелета
	TNode = record
		FName   : string;     // название кости, которая крепится к суставу
		FParent : TIndex;     // индекс кости, к которому прикреплён сустав
		end;

	// Кость скелета (система координат сустава)
	TBonePos = record
		FTrans : TSGVertex3f;         // перемещение
		FRot   : TSGVertex3f;         // поворот
		FAbsoluteMatrix : TSGMatrix4; // абсолютная матрица кости
		FRelativeMatrix : TSGMatrix4; // относительная матрица кости
		FQuat  : TSGQuaternion;         // кватернион кости
		end;

	// Кадр анимации
	TFrame = object
		FBones : packed array of TBonePos; // массив с позициями костей
		
		procedure Clear();
		end;

	// Действие персонажа
	TAction = object
		FName        : string;                 // название анимации для этого действия
		FSpeed       : single;                 // скорость анимации
		FFramesCount : TIndex;                 // количество кадров анимации
		FFrames      : packed array of TFrame; // массив с кадрами анимации
		
		procedure Clear();
		end;

	// Состояние анимации
	TSkelAnimState = object
		FPrevFrame  : TIndex;  // предыдущий кадр
		FNextFrame  : TIndex;  // следующий кадр
		FPrevAction : TIndex;  // предыдущее действие
		FNextAction : TIndex;  // следующее действие
		FSkelTime   : single;  // время (меняется от нуля до единицы между предыдущим и следующим кадром)
		FCurrentPos : TFrame;  // текущая поза персонажа с учётом интерполяции по времени skelTime
		FShaderAbsoluteMatrixes : packed array[0..31] of TSGMatrix4; // массив абсолютных матриц для передачи в шейдер
		
		procedure ResetState(const VNodesNum : TIndex);
		procedure Animate(var VModel : TModel;const VActionNum : TIndex;const VDelta : TIndex; const VPlayOnce : TSGBoolean);
		procedure CopyBonesForShader();
		end;

	// Скелетная анимация персонажа
	PTSkelAnimation = ^ TSkelAnimation;
	TSkelAnimation = object
		FActions      : array of TAction;  // список действий, доступных персонажу
		FNodes        : array of TNode;    // описание взаимодействий суставов скелета (что к чему прикреплено)
		FNodesNum     : TIndex;            // количество суставов в скелете
		FReferencePos : array of TBonePos; // Reference-позиция скелета (поза недеформированной модели)
		
		procedure MakeReferenceMatrixes();
		procedure MakeBoneMatrixes();
		procedure Clear();
		end;

	// Модель персонажа состоит из:
	// - названия файла
	// - полигонов
	// - вершин
	// - инверсно преобразованной модели скелетной анимации
	TModel = class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			public
		FFileName  : string;            // имя файла
		FPoligons  : array of TPoligon; // полигоны
		FVertexes  : array of TVertex;  // вершины
		FLocalized : array of TVertex;  // вывернутая модель (инверсно преобразованная)
		FAnimation : TSkelAnimation;    // скелетная анимация модели
		FMesh      : TSG3DObject;
		FTextures  : array of TSGImage;
			public
		procedure MakeMesh();
		procedure PrepareSkeletalAnimation();
		procedure LoadTextures(const VPath : TSGString);
		procedure Load(const VFileName : TSGString);
		procedure LoadAnimation(const VFileName : TSGString);
		function GetTextureHandle (const FileName : String):LongWord;
			private
		function GetAnimation():PTSkelAnimation;inline;
			public
		property Animation : PTSkelAnimation read GetAnimation;
		end;

function GetValue(S1 : ShortString; const Index : TIndex):TSGFloat;inline;

implementation

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
if FMesh <> nil then
	FMesh.Destroy();
if FVertexes <> nil then
	begin
	for i := 0 to High(FVertexes) do
		FVertexes[i].Clear();
	SetLength(FVertexes,0);
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

function GetValue(S1 : ShortString; const Index : TIndex):TSGFloat;inline;
var
	S : String;
begin
S := String(S1);
S := Trim(S);
S := StringWordGet(S,' ',Index);
{$IFDEF FPC}
	S := StringReplace(S, '.', ',', [rfReplaceAll]);
	{$ENDIF}
Result := StrToFloatDef(S,0);
end;

procedure TModel.Load(const VFileName : TSGString);
var 
	f     : TextFile;
	s     : string;
	i,j,k : TIndex;
begin
Assign(f,VFileName);
Reset(f);

repeat
	ReadLn(f,s);
until s='nodes';

i:=0;
SetLength(FAnimation.FNodes,0);
repeat
	ReadLn(f,s);
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

repeat
	ReadLn(f,s);
until s='time 0';

i:=0;
repeat
	ReadLn(f,s);
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
		FQuat := SGGetQuaternionFromAngleVector3f(FRot);
		Inc(i);
		end;
until s='end';


repeat
ReadLn(f,s);
until s='triangles';

i := 0;
SetLength(FPoligons,0);
SetLength(FVertexes,0);
repeat
	ReadLn(f,s);
	if s<>'end' then
		begin
		SetLength(FPoligons,i+1);
		FPoligons[i].FTextureName := s;
		FPoligons[i].FVertexCoordNum := 3;
		for j:=0 to 2 do
			begin
			SetLength(FVertexes,Length(FVertexes)+1);
			k := High(FVertexes);
			ReadLn(f,s);
			SetLength(FVertexes[k].FParents,1);
			FVertexes[k].FParents[0].FBoneNum := StrToInt(StringWordGet(Trim(s),' ',1));
			FVertexes[k].FParents[0].FWeight  := 1;
			FVertexes[k].FCoord.Import(
				GetValue(S,2),
				GetValue(S,3),
				GetValue(S,4));
			FVertexes[k].FNorm.Import(
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

Close(f);
end;

procedure TModel.LoadAnimation(const VFileName : TSGString);
var f            : TextFile;
    s            : string;
    i, j         : TIndex;
    ActionIndex  : TIndex;
begin
Assign(f,VFileName);
Reset(f);
SetLength(FAnimation.FActions,Length(FAnimation.FActions)+1);
ActionIndex := High(FAnimation.FActions);

FAnimation.FActions[ActionIndex].FName  := VFileName;
FAnimation.FActions[ActionIndex].FSpeed := 15; //default

repeat
ReadLn(f,s);
until s='skeleton';

s:='';
i:=0;
j:=0;
repeat
	readln(f,s);
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
			FBones[i - 1].FQuat := SGGetQuaternionFromAngleVector3f(FBones[i - 1].FRot);
			end;
		end;
	FAnimation.FActions[ActionIndex].FFramesCount := Length(FAnimation.FActions[ActionIndex].FFrames);
until False;

Close(f);
end;

procedure TModel.LoadTextures(const VPath : TSGString);
var
	i, j: TIndex;
	Loaded : TSGBoolean;
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
			FTextures[High(FTextures)] := TSGImage.Create(VPath+FPoligons[i].FTextureName);
			FTextures[High(FTextures)].Context := Context;
			FTextures[High(FTextures)].Loading();
			FTextures[High(FTextures)].ToTexture();
			FTextures[High(FTextures)].Name := FPoligons[i].FTextureName;
			FPoligons[i].FTexture := FTextures[High(FTextures)].Texture;
			end;
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

Delta := VModel.Context.ElapsedTime * VModel.FAnimation.FActions[FNextAction].FSpeed / 100;
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
FMesh.LoadToVBO();
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
FTextures := nil;
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
