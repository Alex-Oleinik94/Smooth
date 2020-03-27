{$INCLUDE Smooth.inc}

unit Smooth3dObject3ds;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,Smooth3dObject
	,Smooth3dObjectLoader
	,SmoothCommonStructs
	,SmoothVertexObject
	
	,Classes
	;
const
	// https://gamedev.ru/code/articles/?id=4412
	// http://paulbourke.net/dataformats/3ds/

	MAIN_CHUNK          = $4D4D;
	VERSION             = $0002;
	EDIT3DS             = $3D3D;		// Блок редактора (this is the start of the editor config)
	EDIT_MATERIAL 	  	= $AFFF;		// Информация о текстурах
	EDIT_OBJECT			= $4000;		// Объект (вершины, полигоны, источник света, камера)

	MAT_NAME 	   		= $A000;		// Название материала
	MAT_DIFFUSE    		= $A020;		// Цвет обьекта/материала
	MAT_TEXTURE_MAP 	= $A200;		// Данные о текстуре материала
	MAT_TEXTURE_FILENAME= $A300;		// "Видимо, файл текстуры"
	OBJ_TRIMESH   		= $4100;		// "Сетка треугольников"

	TRI_VERTEXLIST	 	= $4110;		// Вершины обьекта
			(*TRI_VERTEXLIST (0x4110)
		unsigned short nVertexs; // Число вершин
		vector Vertexs[nVertexs]; // Координаты каждой вершины; vector=TPointR3= три float;*)
	TRI_FACELIST		= $4120; 		// Полигоны обьекта
			(*TRI_FACELIST (0x4120)
		unsigned short nTriangles; // Число треугольников
		struct {
			unsigned short v0; // Индекс первой вершины
			unsigned short v1; // Индекс второй вершины
			unsigned short v2; // Индекс третьей вершины
			unsigned short flags; // Флаги грани, которые мы смело будем игнорировать
		} Triangles[nTriangles]; // Список граней*)
	TRI_MATERIAL	 	= $4130;
			(*TRI_MATERIAL (0x4130)
		char[] Name; // Название материала - строка ASCIIZ
		unsigned short num; // Число граней использующих этот материал
		unsigned short face_mat[num]; // Список индексов граней*)
	TRI_MAPPINGCOORS   	= $4140;		 // UV текстурные координаты
			(*TRI_MAPPINGCOORS (0x4140)
		unsigned short nTexCoords; // Количество текстурных координат = количеству вершин
		struct {
			float u; // Текстурная координата по горизонтали
			float v; // Текстурная координата по вертикали
		} TexCoords[nTexCoords]; // Список текстурных координат*)
	TRI_LOCAL 			= $4160;
			(*TRI_LOCAL (0x4160)
		float[12]; // Сначала по рядках записана матрица поворота rot[3][3], 
		// а потом вектор переноса	(x, y, z). Всего 12 чисел с плавающей запятой*)

type
	TS3dObject3DSChunkPosition = TSUInt32;
	TS3dObject3DSChunkIdentifier = TSUInt16;
	TS3dObject3DSChunk = packed record
		ID     : TS3dObject3DSChunkIdentifier;
		Length : TS3dObject3DSChunkPosition;
		end;
	PS3dObject3DSChunk = ^ TS3dObject3DSChunk;

	TS3dObject3DSLoader = class(TS3dObjectLoader)
			public
		constructor Create(); override; overload;
		constructor Create(const VStream : TFileStream); virtual; overload;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
		function Load() : TSBoolean; override;
		function Import3DS(const AModel : TSCustomModel; out Sucsses : TSBoolean) : TS3dObject3DSLoader;
		function Import3DS() : TSBoolean; 
		procedure SetFileName(const VFileName : TSString); override;
		procedure SetModel(const VModel : TSCustomModel); override;
		procedure SetStream(const VStream : TStream);
			private
		function FindChunk(const ChunkID : TS3dObject3DSChunkIdentifier; const IsParent : TSBoolean = False) : TS3dObject3DSChunkPosition; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SkipHeader();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Skip(const VSize : TSMaxEnum);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ReadAndSkipHeaderWithLength();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ReturnHeader();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ReadHeader() : TS3dObject3DSChunk;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ReadChunk() : TS3dObject3DSChunk;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ReadChunkIdentifier() : TS3dObject3DSChunkIdentifier;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure DestroyInput();
		procedure InitInput();
		
		procedure ComputeNormals();
		procedure ReadMaterials();
		procedure ReadMaterial();
		procedure ReadGeometry();
		procedure ReadObject();
			protected
		FFile : TStream;
		FObjectsCountBeforeImport : TSUInt32;
		FChunkPositionEDIT3DS : TS3dObject3DSChunkPosition;
		end;

implementation

uses
	 SmoothCommon
	,SmoothRenderBase
	,SmoothStringUtils
	,SmoothStreamUtils
	,SmoothFileUtils
	,SmoothLog
	,SmoothDateTime
	;

function TS3dObject3DSLoader.Load() : TSBoolean;
begin
Result := Import3DS();
end;

procedure TS3dObject3DSLoader.SetModel(const VModel : TSCustomModel);
begin
FModel := VModel;
FObjectsCountBeforeImport := Model.QuantityObjects;
end;

class function TS3dObject3DSLoader.ClassName() : TSString;
begin
Result := 'TS3dObject3DSLoader';
end;

procedure TS3dObject3DSLoader.SetStream(const VStream : TStream);
begin
DestroyInput();
FFile      := VStream;
end;

procedure TS3dObject3DSLoader.SetFileName(const VFileName : TSString);
begin
FFileName := VFileName;
end;

constructor TS3dObject3DSLoader.Create();overload;
begin
inherited Create();
FFile := nil;
FChunkPositionEDIT3DS := 0;
end;

constructor TS3dObject3DSLoader.Create(const VStream : TFileStream);overload;
begin
Create();
FFile := VStream;
end;

procedure TS3dObject3DSLoader.DestroyInput();
begin
if (FFile <> nil) then
	begin
	FFile.Destroy();
	FFile := nil;
	end;
end;

destructor TS3dObject3DSLoader.Destroy;
begin
DestroyInput();
inherited Destroy();
end;

procedure TS3dObject3DSLoader.InitInput();
begin
if FFile = nil then
	begin
	try
	FFile := TFileStream.Create(FFileName, fmOpenRead);
	except
	SLog.Source(['TS3dObject3DSLoader__InitInput : Fatal : Error while open file "', FFileName, '".']);
	FFile := nil;
	end;
	end;
end;

procedure TS3dObject3DSLoader.ReadMaterial();
var
	Chunk : TS3dObject3DSChunk;
	ChunkPosition : TS3dObject3DSChunkPosition;
	MaterialFileName : TSString;
begin
FModel.AddMaterial();
ChunkPosition := FindChunk(MAT_NAME, True);
SkipHeader();
FModel.LastMaterial().Name := SReadStringFromStream(FFile);
SLog.Source(['TS3dObject3DSLoader__ReadMaterial : Material: "', FModel.LastMaterial().Name, '".']);
ChunkPosition := FindChunk(MAT_TEXTURE_MAP, True);
Chunk := ReadHeader();
if Chunk.ID = MAT_TEXTURE_MAP then
	begin
	ChunkPosition := FindChunk(MAT_TEXTURE_FILENAME, True);
	Chunk := ReadHeader();
	if Chunk.ID = MAT_TEXTURE_FILENAME then
		begin
		SkipHeader();
		MaterialFileName := SFilePath(FFileName) + SReadStringFromStream(FFile);
		SLog.Source(['TS3dObject3DSLoader__ReadMaterial : Material: "', FModel.LastMaterial().Name, '", File: "', MaterialFileName, '".']);
		FModel.LastMaterial().AddDiffuseMap(MaterialFileName);
		end;
	end;
end;

procedure TS3dObject3DSLoader.ReadMaterials();
var
	ListPosition : TS3dObject3DSChunkPosition;
	Chunk : TS3dObject3DSChunk;
	MaterialsCount : TSUInt32 = 0;
begin
FFile.Position := FChunkPositionEDIT3DS;
ListPosition := FindChunk(EDIT_MATERIAL, True);
Chunk.ID := ReadChunkIdentifier();
while Chunk.ID = EDIT_MATERIAL do
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
SLog.Source(['TS3dObject3DSLoader__ReadMaterials :  Materials Count = "', MaterialsCount, '".']);
end;

procedure TS3dObject3DSLoader.ReadObject();
var
	Chunk : TS3dObject3DSChunk;
	ChunkPositionOBJ_TRIMESH : TS3dObject3DSChunkPosition;
	ChPos,ObjectsPos:TSLongWord;
	Local : array[0..11] of TSFloat32;
	x0,x1,x2:TSSingle;
	i:TSWord;
	iii,t1,t2,t3:TSWord;
begin
ObjectsPos := FFile.Position;
//Создаем объект в модели
FModel.AddObject();
FModel.LastObject().HasNormals := True;
FModel.LastObject().HasColors  := False;
FModel.LastObject().EnableCullFace:=True;
FModel.LastObject().ObjectPoligonesType:=SR_TRIANGLES;
FModel.LastObject().VertexType:=S3dObjectVertexType3f;
SkipHeader();
FModel.LastObject().Name := SReadStringFromStream(FFile);
SLog.Source(['TS3dObject3DSLoader__ReadObject : Object: "', FModel.LastObject().Name, '"']);
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
			FFile.Read(x, SizeOf(TSFloat32));
			FFile.Read(z, SizeOf(TSFloat32));
			FFile.Read(y, SizeOf(TSFloat32));
			end;
	
	//Перейдем к списку текстурных вершин
	FFile.Position := ChunkPositionOBJ_TRIMESH;
	ChPos:=FindChunk(TRI_MAPPINGCOORS,true);
	SkipHeader;
	FFile.Read(iii,2);
	if iii<>QuantityVertexes then
		begin
		SLog.Source('TS3dObject3DSLoader__ReadObject : Fatal : Quantity Vrtexes <> Quantity Texture Vertexes!');
		FModel.Clear();
		Exit;
		end;
	for i:=0 to QuantityVertexes-1 do
		with ArTexVertex[i]^ do
			begin
			FFile.Read(x,SizeOf(TSFloat32));
			FFile.Read(y,SizeOf(TSFloat32));
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
		FModel.IdentifyLastObjectMaterial(SReadStringFromStream(FFile));
		end;
	end;
end;

procedure TS3dObject3DSLoader.ReadGeometry();
var
	ListPosition : TS3dObject3DSChunkPosition;
	Chunk : TS3dObject3DSChunk;
	ObjectsCount : TSUInt32 = 0;
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
SLog.Source(['TS3dObject3DSLoader__ReadGeometry :  Objects Count = "', ObjectsCount, '".']);
end;

function TS3dObject3DSLoader.Import3DS() : TSBoolean;
var
	Chunk : TS3dObject3DSChunk;
begin
Result := False;
SLog.Source(['TS3dObject3DSLoader__Import3DS : Loading "',FFileName,'".']);
InitInput();
if FFile = nil then
	begin
	SLog.Source(['TS3dObject3DSLoader__Import3DS : Не удалось открыть файл "',FFileName,'".']);
	exit;
	end;
//Читаем заголовок
Chunk := ReadHeader();
if Chunk.ID <> MAIN_CHUNK then
	begin
	SLog.Source(['TS3dObject3DSLoader__Import3DS : Это не 3ds файл! "',FFileName,'".']);
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

function TS3dObject3DSLoader.Import3DS(const AModel : TSCustomModel; out Sucsses : TSBoolean): TS3dObject3DSLoader;
begin
Result := Self;
Sucsses := False;
SetModel(AModel);
Sucsses := Import3DS();
end;

function TS3dObject3DSLoader.FindChunk(const ChunkID : TS3dObject3DSChunkIdentifier;const IsParent : TSBoolean = False) : TS3dObject3DSChunkPosition; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Chunk : TS3dObject3DSChunk;
begin
Result := 0;
if IsParent then
	begin
	Chunk := ReadChunk();
	//Если это блок объекта, то нужно пропустить строку имени объекта
	if Chunk.ID = EDIT_OBJECT then
		SReadPCharFromStream(FFile);
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

procedure TS3dObject3DSLoader.ComputeNormals();
var vVector1, vVector2, vNormal,vSum:TSVertex3f;
	vPoly:array[0..2]of TSVertex3f;
	pNormals, pTempNormals : packed array of TSVertex3f;
	iObject,i,ii,shared:longword;

function Cross(const vVector1,vVector2:TSVertex3f):TSVertex3f;inline;
begin
	result.x:=((vVector1.y * vVector2.z) - (vVector1.z * vVector2.y));
	result.y:=((vVector1.z * vVector2.x) - (vVector1.x * vVector2.z));
	result.z:=((vVector1.x * vVector2.y) - (vVector1.y * vVector2.x));
end;

var
	DT, DT2 : TSDateTime;
	ProcessObjectsCount : TSUInt32 = 0;
	TotalProgressProportion : TSFloat32 = 0;
	ObjectProgressProportion : TSFloat32 = 0;
begin
if FModel.QuantityObjects > 0 then
	begin
	DT.Get();
	SLog.Source('TS3dObject3DSLoader__ComputeNormals : Started');
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
	SLog.Source(
		'TS3dObject3DSLoader__ComputeNormals : End (' +
		SSecondsToStringTime((DT2-DT).GetPastSeconds) +
		' ' + 
		SStr((DT2-DT).GetPastMiliSeconds div 100) + 
		' милисек)');
	end;
end;

procedure TS3dObject3DSLoader.ReturnHeader();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FFile.Position := FFile.Position - SizeOf(TS3dObject3DSChunk);
end;

procedure TS3dObject3DSLoader.SkipHeader();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Skip(SizeOf(TS3dObject3DSChunk));
end;

function TS3dObject3DSLoader.ReadChunk() : TS3dObject3DSChunk;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FFile.Read(Result, SizeOf(Result));
end;

function TS3dObject3DSLoader.ReadHeader() : TS3dObject3DSChunk;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := ReadChunk();
ReturnHeader();
end;

procedure TS3dObject3DSLoader.ReadAndSkipHeaderWithLength();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Chunk : TS3dObject3DSChunk;
begin
Chunk := ReadHeader();
Skip(Chunk.Length);
end;

function TS3dObject3DSLoader.ReadChunkIdentifier() : TS3dObject3DSChunkIdentifier;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FFile.Read(Result, SizeOf(Result));
FFile.Position := FFile.Position - SizeOf(Result);
end;

procedure TS3dObject3DSLoader.Skip(const VSize : TSMaxEnum);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FFile.Position := FFile.Position + VSize;
end;

end.
