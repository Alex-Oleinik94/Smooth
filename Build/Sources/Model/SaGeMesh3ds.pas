{$INCLUDE SaGe.inc}

unit SaGeMesh3ds;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeMesh
	,SaGeMeshLoader
	,SaGeCommonStructs
	
	,Classes
	;
const
	//>------ Главный Chunk, в начале каждого 3ds-файла
	MAIN3DS             =  $4D4D;

	//>------ Главнык Chunk-и
	EDIT3DS             =  $3D3D;			// Это предоставляет версию меша перед информацией об обьекте
	cVERSION            =  $0002;			// Предоставляет версию .3ds файла
	cEDITKEYFRAME  		=  $B000;			// Хидер для всей информации о кадрах

	//>------ под-дефайны OBJECTINFO
	cMATERIAL	  		=  $AFFF;		// Информация о текстурах
	EDIT_OBJECT			=  $4000;		// Полигоны, вершины, и т.д...

	//>------ под-дефайны для MATERIAL
	cMATNAME	   		=  $A000;			// Название материала
	cMATDIFFUSE   		=  $A020;			// Хранит цвет обьекта/материала
	cMATMAP				=  $A200;			// Хидер для нового материала
	cMATMAPFILE			=  $A300;			// Хранит имя файла текстуры

	OBJ_TRIMESH   		=  $4100;			// Даёт нам знать, что начинаем считывать новый обьект

	//>------ под-дефайны для OBJECT_MESH
	TRI_VERTEXLIST	 	=  $4110;	  // Вершины обьекта
	TRI_FACELIST		=  $4120;	  // Полигоны обьекта
	TRI_MATERIAL	 	=  $4130;	  // Дефайн находится, если обьект имеет материал, иначе цвет/текстура
	TRI_MAPPINGCOORS   	=  $4140;	  // UV текстурные координаты
	TRI_LOCAL 			=  $4160;

type
	TSGMesh3DSChunkPosition = TSGUInt32;
	TSGMesh3DSChunkIdentifier = TSGUInt16;
	TSGMesh3DSChunk = packed record
		ID     : TSGMesh3DSChunkIdentifier;
		Length : TSGMesh3DSChunkPosition;
		end;
	PSGMesh3DSChunk = ^ TSGMesh3DSChunk;

	TSGMesh3DSLoader = class(TSGMeshLoader)
			public
		constructor Create(); override; overload;
		constructor Create(const VStream : TFileStream); virtual; overload;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
		function Load() : TSGBoolean; override;
		function Import3DS(const AModel : TSGCustomModel; out Sucsses : TSGBoolean) : TSGMesh3DSLoader;
		function Import3DS() : TSGBoolean; 
		function SetFileName(const VFileName : TSGString) : TSGMesh3DSLoader;
		function SetStream(const VStream : TStream) : TSGMesh3DSLoader;
		function SetModel(const VModel : TSGCustomModel) : TSGMesh3DSLoader;
			private
		function FindChunk(const ChunkID : TSGMesh3DSChunkIdentifier; const IsParent : TSGBoolean = False) : TSGMesh3DSChunkPosition; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SkipHeader();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Skip(const VSize : TSGMaxEnum);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ReadAndSkipHeaderWithLength();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ReturnHeader();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ReadHeader() : TSGMesh3DSChunk;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ReadChunk() : TSGMesh3DSChunk;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ReadChunkIdentifier() : TSGMesh3DSChunkIdentifier;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure DestroyInput();
		procedure InitInput();
		
		procedure ComputeNormals();
		procedure ReadMaterials();
		procedure ReadMaterial();
		procedure ReadGeometry();
		procedure ReadObject();
			protected
		FFile : TStream;
		FObjectsCountBeforeImport : TSGUInt32;
		FChunkPositionEDIT3DS : TSGMesh3DSChunkPosition;
		end;

implementation

uses
	 SaGeCommon
	,SaGeRenderBase
	,SaGeStringUtils
	,SaGeFileUtils
	,SaGeLog
	,SaGeDateTime
	;

function TSGMesh3DSLoader.Load() : TSGBoolean;
begin
Result := Import3DS();
end;

function TSGMesh3DSLoader.SetModel(const VModel : TSGCustomModel) : TSGMesh3DSLoader;
begin
Model := VModel;
FObjectsCountBeforeImport := Model.QuantityObjects;
Result := Self;
end;

class function TSGMesh3DSLoader.ClassName() : TSGString;
begin
Result := 'TSGMesh3DSLoader';
end;

function TSGMesh3DSLoader.SetStream(const VStream : TStream) : TSGMesh3DSLoader;
begin
DestroyInput();
FFile      := VStream;
Result     := Self;
end;

function TSGMesh3DSLoader.SetFileName(const VFileName : TSGString) : TSGMesh3DSLoader;
begin
FileName := VFileName;
Result   := Self;
end;

constructor TSGMesh3DSLoader.Create();overload;
begin
inherited Create();
FFile := nil;
FChunkPositionEDIT3DS := 0;
end;

constructor TSGMesh3DSLoader.Create(const VStream : TFileStream);overload;
begin
Create();
FFile := VStream;
end;

procedure TSGMesh3DSLoader.DestroyInput();
begin
if (FFile <> nil) then
	begin
	FFile.Destroy();
	FFile := nil;
	end;
end;

destructor TSGMesh3DSLoader.Destroy;
begin
DestroyInput();
inherited Destroy();
end;

procedure TSGMesh3DSLoader.InitInput();
begin
if FFile = nil then
	begin
	try
	FFile := TFileStream.Create(FFileName, fmOpenRead);
	except
	SGLog.Source(['TSGMesh3DSLoader__InitInput : Fatal : Error while open file "', FFileName, '".']);
	FFile := nil;
	end;
	end;
end;

procedure TSGMesh3DSLoader.ReadMaterial();
var
	Chunk : TSGMesh3DSChunk;
	ChunkPosition : TSGMesh3DSChunkPosition;
	MaterialFileName : TSGString;
begin
FModel.AddMaterial();
ChunkPosition := FindChunk(cMATNAME, True);
SkipHeader();
FModel.LastMaterial().Name := SGReadStringFromStream(FFile);
SGLog.Source(['TSGMesh3DSLoader__ReadMaterial : Material: "', FModel.LastMaterial().Name, '".']);
ChunkPosition := FindChunk(cMATMAP, True);
Chunk := ReadHeader();
if Chunk.ID = cMATMAP then
	begin
	ChunkPosition := FindChunk(cMATMAPFILE, True);
	Chunk := ReadHeader();
	if Chunk.ID = cMATMAPFILE then
		begin
		SkipHeader();
		MaterialFileName := SGFilePath(FFileName) + SGReadStringFromStream(FFile);
		SGLog.Source(['TSGMesh3DSLoader__ReadMaterial : Material: "', FModel.LastMaterial().Name, '", File: "', MaterialFileName, '".']);
		FModel.LastMaterial().AddDiffuseMap(MaterialFileName);
		end;
	end;
end;

procedure TSGMesh3DSLoader.ReadMaterials();
var
	ListPosition : TSGMesh3DSChunkPosition;
	Chunk : TSGMesh3DSChunk;
	MaterialsCount : TSGUInt32 = 0;
begin
FFile.Position := FChunkPositionEDIT3DS;
ListPosition := FindChunk(cMATERIAL, True);
Chunk.ID := ReadChunkIdentifier();
while Chunk.ID = cMATERIAL do
	begin
	ReadMaterial();
	MaterialsCount += 1;
	
	//Ищем новый материал
	FFile.Position := ListPosition;
	ReadAndSkipHeaderWithLength();
	ListPosition := FFile.Position;
	if FFile.Position = FFile.Size then
		break;
	Chunk.ID := ReadChunkIdentifier();
	end;
SGLog.Source(['TSGMesh3DSLoader__ReadMaterials :  Materials Count = "', MaterialsCount, '".']);
end;

procedure TSGMesh3DSLoader.ReadObject();
var
	Chunk : TSGMesh3DSChunk;
	ChunkPositionOBJ_TRIMESH : TSGMesh3DSChunkPosition;
	ChPos,ObjectsPos:TSGLongWord;
	Local : array[0..11] of TSGFloat32;
	x0,x1,x2:TSGSingle;
	i:TSGWord;
	iii,t1,t2,t3:TSGWord;
begin
ObjectsPos := FFile.Position;
//Создаем объект в модели
FModel.AddObject();
FModel.LastObject().HasNormals := True;
FModel.LastObject().HasColors  := False;
FModel.LastObject().EnableCullFace:=True;
FModel.LastObject().ObjectPoligonesType:=SGR_TRIANGLES;
FModel.LastObject().VertexType:=SGMeshVertexType3f;
SkipHeader();
FModel.LastObject().Name := SGReadStringFromStream(FFile);
SGLog.Source(['TSGMesh3DSLoader__ReadObject : Object: "', FModel.LastObject().Name, '"']);
FFile.Position:=ObjectsPos;
//Находим блок сетки
ChPos := FindChunk(OBJ_TRIMESH, True);
ChunkPositionOBJ_TRIMESH := ChPos; //Запомним позицию блока для поиска подблоков

// Проверяем, есть ли у обьекта текстурные координаты 
// нужно проверить до того, как мы займем в оперативной памяти память на вeршины
FFile.Position := ChunkPositionOBJ_TRIMESH;
ChPos := FindChunk(TRI_MAPPINGCOORS, True);
SkipHeader();
FFile.Read(iii, 2);
FModel.LastObject().HasTexture := iii <> 0;

//Находим список вершин
FFile.Position := ChunkPositionOBJ_TRIMESH;
ChPos := FindChunk(TRI_VERTEXLIST, True);
with FModel.LastObject() do
	begin
	//считаем кол-во вертексов
	SkipHeader();
	FFile.Read(iii, 2);
	SetVertexLength(iii);
	for i:=0 to QuantityVertexes-1 do
		with ArVertex3f[i]^ do
			begin
			FFile.Read(x, SizeOf(TSGFloat32));
			FFile.Read(z, SizeOf(TSGFloat32));
			FFile.Read(y, SizeOf(TSGFloat32));
			end;
	
	//Перейдем к списку текстурных вершин
	FFile.Position := ChunkPositionOBJ_TRIMESH;
	ChPos:=FindChunk(TRI_MAPPINGCOORS,true);
	SkipHeader;
	FFile.Read(iii,2);
	if iii<>QuantityVertexes then
		begin
		SGLog.Source('TSGMesh3DSLoader__ReadObject : Fatal : Quantity Vrtexes <> Quantity Texture Vertexes!');
		FModel.Clear();
		Exit;
		end;
	for i:=0 to QuantityVertexes-1 do
		with ArTexVertex[i]^ do
			begin
			FFile.Read(x,SizeOf(TSGFloat32));
			FFile.Read(y,SizeOf(TSGFloat32));
			end;
	
	//перейдем к списку граней
	FFile.Position := ChunkPositionOBJ_TRIMESH;
	ChPos := FindChunk(TRI_FACELIST, True);
	SkipHeader();
	FFile.Read(iii, 2);
	AddFaceArray();
	AutoSetIndexFormat(0, Vertexes);
	SetFaceLength(0, iii);
	for i:=0 to Faces[0] - 1 do
		begin
		FFile.Read(t1, 2);
		FFile.Read(t2, 2);
		FFile.Read(t3, 2);
		FFile.Position := FFile.Position + 2;
		SetFaceTriangle(0,i,t1,t2,t3);
		end;
	
	//Дойдем к данным о локальной системе объекта
	FFile.Position:=ChunkPositionOBJ_TRIMESH;
	ChPos := FindChunk(TRI_LOCAL, True);
	SkipHeader();
	FFile.Read(Local, Sizeof(Local));
	//Совершаем преобразования
	for i:=0 to QuantityVertexes - 1 do
		begin
		ArVertex3f[i]^.x-=Local[9];
		ArVertex3f[i]^.z-=Local[10];
		ArVertex3f[i]^.y-=Local[11];
		x0:=ArVertex3f[i]^.x;
		x1:=ArVertex3f[i]^.y;
		x2:=ArVertex3f[i]^.z;
		ArVertex3f[i]^.x:=Local[0]*x0+Local[2]*x1+Local[1]*x2;
		ArVertex3f[i]^.z:=Local[3]*x0+Local[5]*x1+Local[4]*x2;
		ArVertex3f[i]^.y:=Local[6]*x0+Local[8]*x1+Local[7]*x2;
		end;
	FFile.Position:=ChunkPositionOBJ_TRIMESH;
	ChPos:=FindChunk(TRI_FACELIST, True);
	FFile.Position:=FFile.Position+2+6+Faces[0]*4*2;
	ChPos := FindChunk(TRI_MATERIAL, False);
	Chunk := ReadHeader();
	if Chunk.ID = TRI_MATERIAL then
		begin
		SkipHeader();
		FModel.CreateMaterialIDInLastObject(SGReadStringFromStream(FFile));
		end;
	end;
end;

procedure TSGMesh3DSLoader.ReadGeometry();
var
	ListPosition : TSGMesh3DSChunkPosition;
	Chunk : TSGMesh3DSChunk;
	ObjectsCount : TSGUInt32 = 0;
begin
FFile.Position := FChunkPositionEDIT3DS;
//Пропускаем все кроме блока объекта
ListPosition := FindChunk(EDIT_OBJECT, True);
Chunk.ID := ReadChunkIdentifier();
while Chunk.ID = EDIT_OBJECT do
	begin
	ReadObject();
	ObjectsCount += 1;
	
	FFile.Position := ListPosition;
	ReadAndSkipHeaderWithLength();
	ListPosition := FFile.Position;
	if FFile.Position = FFile.Size then
		break;
	Chunk.ID := ReadChunkIdentifier();
	end;
SGLog.Source(['TSGMesh3DSLoader__ReadGeometry :  Objects Count = "', ObjectsCount, '".']);
end;

function TSGMesh3DSLoader.Import3DS() : TSGBoolean;
var
	Chunk : TSGMesh3DSChunk;
begin
Result := False;
SGLog.Source(['TSGMesh3DSLoader__Import3DS : Loading "',FFileName,'".']);
InitInput();
if FFile = nil then
	begin
	SGLog.Source(['TSGMesh3DSLoader__Import3DS : Не удалось открыть файл "',FFileName,'".']);
	exit;
	end;
//Читаем заголовок
Chunk := ReadHeader();
if Chunk.ID <> MAIN3DS then
	begin
	SGLog.Source(['TSGMesh3DSLoader__Import3DS : Это не 3ds файл! "',FFileName,'".']);
	exit;
	end;
//находим блок редактора
FChunkPositionEDIT3DS := FindChunk(EDIT3DS, True);
SetProgress(0.05);
ReadMaterials();
SetProgress(0.1);
ReadGeometry();
SetProgress(0.15);
DestroyInput();
ComputeNormals();
SetProgress(1.001);
Result := True;
end;

function TSGMesh3DSLoader.Import3DS(const AModel : TSGCustomModel; out Sucsses : TSGBoolean): TSGMesh3DSLoader;
begin
Result := Self;
Sucsses := False;
SetModel(AModel);
Sucsses := Import3DS();
end;

function TSGMesh3DSLoader.FindChunk(const ChunkID : TSGMesh3DSChunkIdentifier;const IsParent : TSGBoolean = False) : TSGMesh3DSChunkPosition; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Chunk : TSGMesh3DSChunk;
begin
Result := 0;
if IsParent then
	begin
	Chunk := ReadChunk();
	//Если это блок объекта, то нужно пропустить строку имени объекта
	if Chunk.ID = EDIT_OBJECT then
		SGReadPCharFromStream(FFile);
	end;
//Начинаем поиск внутри родительского блока
repeat
Chunk := ReadChunk();
if Chunk.ID <> ChunkID then
	begin
	FFile.Position := FFile.Position + Chunk.Length - 6;
	end
else
	begin
	FFile.Position := FFile.Position - 6;
	Result := FFile.Position;
	break;
	end;
until FFile.Position >= FFile.Size;
end;

procedure TSGMesh3DSLoader.ComputeNormals();
var vVector1, vVector2, vNormal,vSum:TSGVertex3f;
	vPoly:array[0..2]of TSGVertex3f;
	pNormals, pTempNormals : packed array of TSGVertex3f;
	iObject,i,ii,shared:longword;

function Cross(const vVector1,vVector2:TSGVertex3f):TSGVertex3f;inline;
begin
	result.x:=((vVector1.y * vVector2.z) - (vVector1.z * vVector2.y));
	result.y:=((vVector1.z * vVector2.x) - (vVector1.x * vVector2.z));
	result.z:=((vVector1.x * vVector2.y) - (vVector1.y * vVector2.x));
end;

var
	DT, DT2 : TSGDateTime;
	ProcessObjectsCount : TSGUInt32 = 0;
	TotalProgressProportion : TSGFloat32 = 0;
	ObjectProgressProportion : TSGFloat32 = 0;
begin
if FModel.QuantityObjects > 0 then
	begin
	DT.Get();
	SGLog.Source('TSGMesh3DSLoader__ComputeNormals : Started');
	ProcessObjectsCount := FModel.QuantityObjects - FObjectsCountBeforeImport;
	TotalProgressProportion := 1.001 - 0.15;
	ObjectProgressProportion := TotalProgressProportion / ProcessObjectsCount;
	SetProgress(0.151);
	for iObject := FObjectsCountBeforeImport to FModel.QuantityObjects - 1 do
		begin
		with FModel.Objects[iObject] do
			begin
			SetLength(pNormals,     Faces[0]);
			SetLength(pTempNormals, Faces[0]);
			for i:=0 to Faces[0]-1 do
				begin
				vPoly[0]:=ArVertex3f[ArFacesTriangles(0,i).p0]^;
				vPoly[1]:=ArVertex3f[ArFacesTriangles(0,i).p1]^;
				vPoly[2]:=ArVertex3f[ArFacesTriangles(0,i).p2]^;
				
				vVector1:=vPoly[0]-vPoly[2];
				vVector2:=vPoly[1]-vPoly[2];
				
				vNormal:=Cross(vVector1,vVector2);
				pTempNormals[i]:=vNormal;
				vNormal := vNormal.Normalized();
				pNormals[i]:=vNormal;
				end;
			SetProgress(0.15 + (iObject - FObjectsCountBeforeImport + 0.2) * ObjectProgressProportion);
			vSum.Import();
			shared:=0;
			for i:=0 to QuantityVertexes-1 do
				begin
				for ii:=0 to Faces[0]-1 do
					begin
					if (ArFacesTriangles(0,ii).p0=i)or(ArFacesTriangles(0,ii).p1=i)or(ArFacesTriangles(0,ii).p2=i) then
						begin
						vSum+=pTempNormals[ii];
						shared+=1;
						end;
					end;
				ArNormal[i]^:=vSum/(-shared);
				ArNormal[i]^ := ArNormal[i]^.Normalized();
				vSum.Import();
				shared:=0;
				SetProgress(0.15 + (iObject - FObjectsCountBeforeImport + 0.2 + 0.8 * (i / (QuantityVertexes - 1))) * ObjectProgressProportion);
				end;
			SetProgress(0.15 + (iObject - FObjectsCountBeforeImport + 1) * ObjectProgressProportion);
			end;
		SetLength(pNormals,0);
		SetLength(pTempNormals,0);
		end;
	DT2.Get();
	SGLog.Source(
		'TSGMesh3DSLoader__ComputeNormals : End (' +
		SGSecondsToStringTime((DT2-DT).GetPastSeconds) +
		' ' + 
		SGStr((DT2-DT).GetPastMiliSeconds div 100) + 
		' милисек)');
	end;
end;

procedure TSGMesh3DSLoader.ReturnHeader();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FFile.Position := FFile.Position - SizeOf(TSGMesh3DSChunk);
end;

procedure TSGMesh3DSLoader.SkipHeader();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Skip(SizeOf(TSGMesh3DSChunk));
end;

function TSGMesh3DSLoader.ReadChunk() : TSGMesh3DSChunk;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FFile.Read(Result, SizeOf(Result));
end;

function TSGMesh3DSLoader.ReadHeader() : TSGMesh3DSChunk;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := ReadChunk();
ReturnHeader();
end;

procedure TSGMesh3DSLoader.ReadAndSkipHeaderWithLength();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Chunk : TSGMesh3DSChunk;
begin
Chunk := ReadHeader();
Skip(Chunk.Length);
end;

function TSGMesh3DSLoader.ReadChunkIdentifier() : TSGMesh3DSChunkIdentifier;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FFile.Read(Result, SizeOf(Result));
FFile.Position := FFile.Position - SizeOf(Result);
end;

procedure TSGMesh3DSLoader.Skip(const VSize : TSGMaxEnum);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FFile.Position := FFile.Position + VSize;
end;

end.
