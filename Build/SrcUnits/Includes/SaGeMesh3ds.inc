{$IFDEF SGREADINTERFACE}

const
	//>------ Главный Chunk, в начале каждого 3ds-файла
	MAIN3DS	   		=$4D4D;

	//>------ Главнык Chunk-и
	EDIT3DS				=$3D3D;			// Это предоставляет версию меша перед информацией об обьекте
	cVERSION	   		=$0002;			// Предоставляет версию .3ds файла
	cEDITKEYFRAME  		=$B000;			// Хидер для всей информации о кадрах

	//>------ под-дефайны OBJECTINFO
	cMATERIAL	  		=$AFFF;		// Информация о текстурах
	EDIT_OBJECT			=$4000;		// Полигоны, вершины, и т.д...

	//>------ под-дефайны для MATERIAL
	cMATNAME	   		=$A000;			// Название материала
	cMATDIFFUSE   		=$A020;			// Хранит цвет обьекта/материала
	cMATMAP				=$A200;			// Хидер для нового материала
	cMATMAPFILE			=$A300;			// Хранит имя файла текстуры

	OBJ_TRIMESH   		=$4100;			// Даёт нам знать, что начинаем считывать новый обьект

	//>------ под-дефайны для OBJECT_MESH
	TRI_VERTEXLIST	 	=$4110;	  // Вершины обьекта
	TRI_FACELIST		=$4120;	  // Полигоны обьекта
	TRI_MATERIAL	 	=$4130;	  // Дефайн находится, если обьект имеет материал, иначе цвет/текстура
	TRI_MAPPINGCOORS   	=$4140;	  // UV текстурные координаты
	TRI_LOCAL 			=$4160;

type 
	TSGChunk=record
		ID:word;
		Length:longword;
	end;
	PSGChunk=^TSGChunk;

	TSGLoad3DS = class
		public
			constructor Create( const VStream:TFileStream = nil);
			destructor Destroy(); override;
			function Import3DS(const AModel:TSGCustomModel;out Sucsses : TSGBoolean):TSGLoad3DS;
			function SetFileName(const VFileName : TSGString):TSGLoad3DS;
		private
			function FindChunk(ID:word;IsParent:boolean=false):longword;
			procedure ComputeNormals(const AModel:TSGCustomModel);
			procedure SkipHeader;
			procedure ReadHeader(AC:PSGChunk);
		private
			TFile	 : TFileStream;
			FFileName : TSGString;
	end;
{$ENDIF}

{$IFDEF SGREADIMPLEMENTATION}

{ TSGLoad3DS }

function TSGLoad3DS.SetFileName(const VFileName : TSGString):TSGLoad3DS;
begin
FFileName:=VFileName;
Result:=Self;
end;

constructor TSGLoad3DS.Create(const VStream:TFileStream = nil);
begin
TFile:=nil;
if VStream<>nil then
	begin
	if TFile<>nil then
		TFile.Destroy;
	TFile:=VStream;
	end;
end;

destructor TSGLoad3DS.Destroy;
begin
	if Tfile<>nil then
		TFile.Destroy;
	inherited Destroy;
end;

function TSGLoad3DS.Import3DS(const AModel:TSGCustomModel;out Sucsses : TSGBoolean): TSGLoad3DS;
var Ch:TSGChunk;
	ChPos,TempPos,ObjectsPos,c3dPos:TSGLongWord;
	Local:array[0..11] of TSGSingle;
	x0,x1,x2:TSGSingle;
	i:TSGWord;
	iii:TSGWord;
begin
Result:=Self;
Sucsses:=False;
SGLog.Sourse(['TSGLoad3DS.Import3DS : Loading "',FFileName,'"']);
if TFile= nil then
	Tfile:=TFileStream.Create(FFileName,fmOpenRead);
if Tfile=nil then
	begin
	SGLog.Sourse(['TSGLoad3DS.Import3DS : Не удалось открыть файл "',FFileName,'"']);
	exit;
	end;
//Читаем заголовок
Tfile.Read(Ch.ID,2);
Tfile.Read(Ch.Length,4);
Tfile.Position:=Tfile.Position-6;
if Ch.ID<>MAIN3DS then
	begin
	SGLog.Sourse(['TSGLoad3DS.Import3DS : Это не 3d файл! "',FFileName,'"']);
	exit;
	end;
//находим блок редактора
ChPos:=Self.FindChunk(EDIT3DS,true);
c3dPos:=ChPos;
//==================================================================
//========================Читаем материалы==========================
//==================================================================
//Ищем материалы
ChPos:=Self.FindChunk(cMATERIAL,true);
ObjectsPos:=ChPos;
Tfile.Read(Ch.ID,2); 
Tfile.Position:=Tfile.Position-2;
while Ch.ID=cMATERIAL do
	begin
	AModel.AddMaterial();
	TempPos:=ChPos;
	ChPos:=Self.FindChunk(cMATNAME,true);
	Tfile.Position:=Tfile.Position+6;
	AModel.LastMaterial().Name := SGReadStringFromStream(TFile);
	//Tfile.Position:=ObjectsPos;
	ChPos:=Self.FindChunk(cMATMAP,true);
	ReadHeader(@Ch);
	if Ch.ID=cMATMAP then
		begin
		ChPos:=Self.FindChunk(cMATMAPFILE,true);
		ReadHeader(@Ch);
		if Ch.ID=cMATMAPFILE then
			begin
			Tfile.Position:=Tfile.Position+6;
			AModel.LastMaterial().Way := SGReadStringFromStream(TFile);
			AModel.LastMaterial().Way := SGGetFileWay(FFileName)+ AModel.LastMaterial().Way;
			AModel.LastMaterial().LoadToMemory();
			AModel.LastMaterial().LoadToBitMap();
			end;
		end;
	SGLog.Sourse(['TSGLoad3DS.Import3DS : Material: "',AModel.LastMaterial().Name,
				'"; In file: "',AModel.LastMaterial().Way,'"']);
	//Ищем новый материал
	Tfile.Position:=ObjectsPos;
	Tfile.Read(Ch.ID,2);
	Tfile.Read(Ch.Length,4);
	Tfile.Position:=Tfile.Position-6+Ch.Length;
	ObjectsPos:=Tfile.Position;
	if TFile.Position=Tfile.Size then break;
	Tfile.Read(Ch.ID,2);
	Tfile.Position:=ObjectsPos;
	end;
//==================================================================
//========================Читаем геометрию==========================
//==================================================================
Tfile.Position:=c3dPos;
//Пропускаем все кроме блока объекта
ChPos:=Self.FindChunk(EDIT_OBJECT,true);
ObjectsPos:=ChPos;
Tfile.Read(Ch.ID,2);
Tfile.Position:=Tfile.Position-2;
while Ch.ID=EDIT_OBJECT do
	begin
	//Создаем объект в модели
	AModel.AddObject();
	AModel.LastObject().HasNormals := True;
	AModel.LastObject().HasColors  := False;
	AModel.LastObject().EnableCullFace:=True;
	AModel.LastObject().PoligonesType:=SGR_TRIANGLES;
	AModel.LastObject().VertexType:=TSGMeshVertexType3f;
	Tfile.Position:=Tfile.Position+6;
	AModel.LastObject().Name := SGReadStringFromStream(TFile);
	SGLog.Sourse(['TSGLoad3DS.Import3DS : Object: "',AModel.LastObject().Name,'"']);
	Tfile.Position:=ObjectsPos;
	//Находим блок сетки
	ChPos:=Self.FindChunk(OBJ_TRIMESH,true);
	TempPos:=ChPos; //Запомним позицию блока для поиска подблоков
	
	// Проверяем, есть ли у обьекта текстурные координаты 
	// нужно проверить до того, как мы займем в оперативной памяти память на вршины
	Tfile.Position:=TempPos;
	ChPos:=Self.FindChunk(TRI_MAPPINGCOORS,true);
	SkipHeader;
	TFile.Read(iii,2);
	AModel.LastObject().HasTexture := iii<>0;
	
	//Находим список вершин
	Tfile.Position:=TempPos;
	ChPos:=Self.FindChunk(TRI_VERTEXLIST,true);
	with AModel.LastObject() do
		begin
		//считаем кол-во вертексов
		SkipHeader;
		TFile.Read(iii,2);
		SetVertexLength(iii);
		for i:=0 to QuantityVertexes-1 do
			with ArVertex3f[i]^ do
				begin
				Tfile.Read(x,4);
				Tfile.Read(z,4);
				Tfile.Read(y,4);
				end;
		
		//Перейдем к списку текстурных вершин
		Tfile.Position:=TempPos;
		ChPos:=Self.FindChunk(TRI_MAPPINGCOORS,true);
		SkipHeader;
		TFile.Read(iii,2);
		if iii<>QuantityVertexes then
			begin
			SGLog.Sourse('TSGLoad3DS.Import3DS : Fatal : Quantity Vrtexes <> Quantity Texture Vertexes!');
			AModel.Clear();
			Exit;
			end;
		for i:=0 to QuantityVertexes-1 do
			with ArTexVertex[i]^ do
				begin
				Tfile.Read(x,4);
				Tfile.Read(y,4);
				end;
		
		//перейдем к списку граней
		Tfile.Position:=TempPos;
		ChPos:=Self.FindChunk(TRI_FACELIST,true);
		SkipHeader;
		TFile.Read(iii,2);
		SetFaceLength(iii);
		for i:=0 to QuantityFaces-1 do
			with ArFacesTriangles()[i] do
				begin
				Tfile.Read(p0,2);
				Tfile.Read(p1,2);
				Tfile.Read(p2,2);
				Tfile.Position:=Tfile.Position+2;
				end;
		
		//Дойдем к данным о локальной системе объекта
		Tfile.Position:=TempPos;
		ChPos:=Self.FindChunk(TRI_LOCAL,true);
		SkipHeader;
		TFile.Read(Local,sizeof(single)*12);
		//Совершаем преобразования
		for i:=0 to QuantityVertexes-1 do
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
		Tfile.Position:=TempPos;
		ChPos:=Self.FindChunk(TRI_FACELIST,true);
		Tfile.Position:=Tfile.Position+2+6+QuantityFaces*4*2;
		ChPos:=Self.FindChunk(TRI_MATERIAL,false);
		ReadHeader(@Ch);
		if Ch.ID=TRI_MATERIAL then
			begin
			TFile.Position:=TFile.Position+6;
			AModel.CreateMaterialIDInLastObject(SGReadStringFromStream(TFile));
			end;
		end;
	Tfile.Position:=ObjectsPos;
	Tfile.Read(Ch.ID,2);
	Tfile.Read(Ch.Length,4);
	Tfile.Position:=Tfile.Position-6+Ch.Length;
	ObjectsPos:=Tfile.Position;
	if TFile.Position=Tfile.Size then break;
	Tfile.Read(Ch.ID,2);
	Tfile.Position:=ObjectsPos;
	end;
ComputeNormals(AModel);
Sucsses:=True;
end;

function TSGLoad3DS.FindChunk(ID: word; IsParent: boolean=false): longword;inline;

var CuCh:TSGChunk;
	c:char;
begin
	if IsParent then
	begin
		TFile.Read(CuCh.ID,2);
		Tfile.Read(CuCh.Length,4);
		//Если это блок объекта, то нужно пропустить строку имени объекта
		if CuCh.ID=EDIT_OBJECT then
		begin
			repeat
				TFile.Read(c,1);
			until c=#0;
		end;
	end;
	//Начинаем поиск внутри родительского блока
	repeat
		TFile.Read(CuCh.ID,2);
		TFile.Read(CuCh.Length,4);
		if CuCh.ID<>ID then
		begin
			TFile.Position:=TFile.Position+CuCh.Length-6;
		end
		else
		begin
			Tfile.Position:=TFile.Position-6;
			result:=TFile.Position;
			exit;
		end;
	until TFile.Position>=Tfile.Size;
end;

procedure TSGLoad3DS.ComputeNormals(const AModel:TSGCustomModel);
var vVector1, vVector2, vNormal,vSum:TSGVertex;
	vPoly:array[0..2]of TSGVertex;
	pNormals,pTempNormals:array of TSGVertex;
	iObject,i,ii,shared:longword;

function Cross(const vVector1,vVector2:TSGVertex):TSGVertex;inline;
begin
	result.x:=((vVector1.y * vVector2.z) - (vVector1.z * vVector2.y));
	result.y:=((vVector1.z * vVector2.x) - (vVector1.x * vVector2.z));
	result.z:=((vVector1.x * vVector2.y) - (vVector1.y * vVector2.x));
end;
var
	DT,DT2:TSGDateTime;
begin
DT.Get();
SGLog.Sourse('TSGLoad3DS.ComputeNormals : Started');
if AModel.QuantityObjects>0 then
	begin
	for iObject:=0 to AModel.QuantityObjects-1 do
		begin
		with AModel.Objects[iObject] do
			begin
			//SetLength(ArNormals,FNOfVerts);
			SetLength(pNormals,FNOfFaces);
			SetLength(pTempNormals,FNOfFaces);
			for i:=0 to QuantityFaces-1 do
				begin
				vPoly[0]:=ArVertex3f[ArFacesTriangles[i].p0]^;
				vPoly[1]:=ArVertex3f[ArFacesTriangles[i].p1]^;
				vPoly[2]:=ArVertex3f[ArFacesTriangles[i].p2]^;
				
				vVector1:=vPoly[0]-vPoly[2];
				vVector2:=vPoly[1]-vPoly[2];
				
				vNormal:=Cross(vVector1,vVector2);
				pTempNormals[i]:=vNormal;
				vNormal.Normalize;
				pNormals[i]:=vNormal;
				end;
			vSum.Import();
			shared:=0;
			for i:=0 to QuantityVertexes-1 do
				begin
				for ii:=0 to QuantityFaces-1 do
					begin
					if (ArFacesTriangles[ii].p0=i)or(ArFacesTriangles[ii].p1=i)or(ArFacesTriangles[ii].p2=i) then
						begin
						vSum+=pTempNormals[ii];
						shared+=1;
						end;
					end;
				ArNormal[i]^:=vSum/(-shared);
				ArNormal[i]^.Normalize();
				vSum.Import();
				shared:=0;
				end;
			end;
		SetLength(pNormals,0);
		SetLength(pTempNormals,0);
		end;
	end;
DT2.Get();
SGLog.Sourse('TSGLoad3DS.ComputeNormals : Endng ( '+
	SGSecondsToStringTime((DT2-DT).GetPastSeconds)+' '+SGStr((DT2-DT).GetPastMiliSeconds div 100)+' милисек'+' )');
end;

procedure TSGLoad3DS.SkipHeader;inline;
begin
  Tfile.Position:=Tfile.Position+6;
end;

procedure TSGLoad3DS.ReadHeader(AC: PSGChunk);
begin
	Tfile.Read(AC^.ID,2);
	Tfile.Read(AC^.Length,4);
	Tfile.Position:=Tfile.Position-6;
end;


{$ENDIF}
