{$IFDEF SGREADINTERFACE}

const
	//>------ Главный Chunk, в начале каждого 3ds-файла
	MAIN3DS       		=$4D4D;

	//>------ Главнык Chunk-и
	EDIT3DS    			=$3D3D;            // Это предоставляет версию меша перед информацией об обьекте
	cVERSION       		=$0002;            // Предоставляет версию .3ds файла
	cEDITKEYFRAME  		=$B000;            // Хидер для всей информации о кадрах

	//>------ под-дефайны OBJECTINFO
	cMATERIAL      		=$AFFF;        // Информация о текстурах
	EDIT_OBJECT        	=$4000;        // Полигоны, вершины, и т.д...

	//>------ под-дефайны для MATERIAL
	cMATNAME       		=$A000;            // Название материала
	cMATDIFFUSE   		=$A020;            // Хранит цвет обьекта/материала
	cMATMAP        		=$A200;            // Хидер для нового материала
	cMATMAPFILE    		=$A300;            // Хранит имя файла текстуры

	OBJ_TRIMESH   		=$4100;            // Даёт нам знать, что начинаем считывать новый обьект

	//>------ под-дефайны для OBJECT_MESH
	TRI_VERTEXLIST     	=$4110;      // Вершины обьекта
	TRI_FACELIST        =$4120;      // Полигоны обьекта
	TRI_MATERIAL     	=$4130;      // Дефайн находится, если обьект имеет материал, иначе цвет/текстура
	TRI_MAPPINGCOORS   	=$4140;      // UV текстурные координаты
	TRI_LOCAL 			=$4160;

type 
    TSGChunk=record
        ID:word;
        Length:longword;
    end;
    PSGChunk=^TSGChunk;

    TSGLoad3DS=class
        public
            constructor Create( const VStream:TFileStream = nil);
            destructor Destroy; override;
            function Import3DS(AModel:PSGModel;FileName:string):boolean;
        private
            function FindChunk(ID:word;IsParent:boolean=false):longword;
            procedure ComputeNormals(AModel:PSGModel);
            procedure SkipHeader;
            procedure ReadHeader(AC:PSGChunk);
        private
            TFile:TFileStream;
    end;
{$ENDIF}

{$IFDEF SGREADIMPLEMENTATION}

{ TSGLoad3DS }

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

function TSGLoad3DS.Import3DS(AModel: PSGModel; FileName: string): boolean;
var Ch:TSGChunk;
    ChPos,TempPos,ObjectsPos,c3dPos:longword;
    Local:array[0..11] of single;
    x0,x1,x2:single;
    i:word;
    c:char;
    s:string = '';
    iii:word;
begin
	Result:=False;
	{$IFDEF SGDebuging}
		writeln('Loading "',FileName,'"');
		{$ENDIF}
	if TFile= nil then
		Tfile:=TFileStream.Create(FileName,fmOpenRead);
    if Tfile=nil then
    begin
        {$IFDEF SGDebuging}
			Writeln('Не удалось открыть файл "',FileName,'"');
			{$ENDIF}
        exit;
    end;
    //Читаем заголовок
    Tfile.Read(Ch.ID,2);
    Tfile.Read(Ch.Length,4);
    Tfile.Position:=Tfile.Position-6;
    if Ch.ID<>MAIN3DS then
    begin
        {$IFDEF SGDebuging}
			Writeln('Это не 3d файл! "',FileName,'"');
			{$ENDIF}
        exit;
    end;
    //находим блок редактора
    ChPos:=self.FindChunk(EDIT3DS,true);    
	//==================================================================
	//========================Читаем материалы==========================
	//==================================================================
    //Ищем материалы
    c3dPos:=ChPos;
    ChPos:=self.FindChunk(cMATERIAL,true);
    ObjectsPos:=ChPos;
    Tfile.Read(Ch.ID,2); 
    Tfile.Position:=Tfile.Position-2;
    while Ch.ID=cMATERIAL do
		begin
        SetLength(AModel^.ArMaterials,Length(AModel^.ArMaterials)+1);
        AModel^.NOfMaterials+=1;
        AModel^.ArMaterials[high(AModel^.ArMaterials)]:=TSGMaterialInfo.Create;
		TempPos:=ChPos;
		ChPos:=self.FindChunk(cMATNAME,true);
        Tfile.Position:=Tfile.Position+6;
        Tfile.Read(c,1);
		while c<>#0 do
        begin
            AModel^.ArMaterials[high(AModel^.ArMaterials)].strName+=c;
        	Tfile.Read(c,1);
        end;
        //Tfile.Position:=ObjectsPos;
        ChPos:=self.FindChunk(cMATMAP,true);
        ReadHeader(@Ch);
        if Ch.ID=cMATMAP then
        begin
			ChPos:=self.FindChunk(cMATMAPFILE,true);
			ReadHeader(@Ch);
			if Ch.ID=cMATMAPFILE then
			begin
				Tfile.Position:=Tfile.Position+6;
				Tfile.Read(c,1);
				while c<>#0 do
				begin
					AModel^.ArMaterials[high(AModel^.ArMaterials)].strFile+=c;
					Tfile.Read(c,1);
				end;
                AModel^.ArMaterials[high(AModel^.ArMaterials)].Way:='models/'+
                	AModel^.ArMaterials[high(AModel^.ArMaterials)].strFile;
                AModel^.ArMaterials[high(AModel^.ArMaterials)].LoadToMemory;
                AModel^.ArMaterials[high(AModel^.ArMaterials)].LoadToBitMap;
                AModel^.ArMaterials[high(AModel^.ArMaterials)].LoadTextureMainThread;
			end;
		end;
        {$IFDEF SGDebuging}
			writeln('Material: "',AModel^.ArMaterials[high(AModel^.ArMaterials)].strName,
					'"; In file: "',AModel^.ArMaterials[high(AModel^.ArMaterials)].Way,'"');
			{$ENDIF}
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
	ChPos:=self.FindChunk(EDIT_OBJECT,true);
    ObjectsPos:=ChPos;
    Tfile.Read(Ch.ID,2);
    Tfile.Position:=Tfile.Position-2;
    while Ch.ID=EDIT_OBJECT do
    begin
		//Создаем объект в модели
        SetLength(AModel^.ArObjects,Length(AModel^.ArObjects)+1);
		AModel^.NOfObjects+=1;
		AModel^.ArObjects[high(AModel^.ArObjects)]:=TSG3dObject.Create;
        Tfile.Position:=Tfile.Position+6;
        Tfile.Read(c,1);
		while c<>#0 do
        begin
            AModel^.ArObjects[high(AModel^.ArObjects)].FName+=c;
        	Tfile.Read(c,1);
        end;
        {$IFDEF SGDebuging}
			writeln('Object: "',AModel^.ArObjects[high(AModel^.ArObjects)].FName,'"');
			{$ENDIF}
        Tfile.Position:=ObjectsPos;
		//Находим блок сетки
		ChPos:=self.FindChunk(OBJ_TRIMESH,true);
		TempPos:=ChPos; //Запомним позицию блока для поиска подблоков
		//Находим список вершин
		ChPos:=self.FindChunk(TRI_VERTEXLIST,true);
		with AModel^.ArObjects[high(AModel^.ArObjects)] do
		begin
			//считаем кол-во вертексов
			SkipHeader;
			TFile.Read(iii,2);
			FNOfVerts:=iii;
			SetVertexLength(FNofVerts);
			for i:=0 to FNOfVerts-1 do
			begin
				Tfile.Read(ArVertexes[i].x,4);
				Tfile.Read(ArVertexes[i].z,4);
				Tfile.Read(ArVertexes[i].y,4);
			end;
			//Перейдем к списку текстурных вершин
			Tfile.Position:=TempPos;
			ChPos:=self.FindChunk(TRI_MAPPINGCOORS,true);
			SkipHeader;
			TFile.Read(iii,2);
			FNOfTexVertex:=iii;
			SetLength(ArTexVertexes,FNOfTexVertex);
			for i:=0 to FNOfTexVertex-1 do
			begin
				Tfile.Read(ArTexVertexes[i].x,4);
				Tfile.Read(ArTexVertexes[i].y,4);
			end;
			//перейдем к списку граней
			Tfile.Position:=TempPos;
			ChPos:=self.FindChunk(TRI_FACELIST,true);
			SkipHeader;
			TFile.Read(iii,2);
			FNOfFaces:=iii;
			//SetLength(ArFaces,FNOfFaces);
			SetFaceLength(FNOfFaces);
			for i:=0 to FNOfFaces-1 do
			begin
				Tfile.Read(ArFacesTriangles[i].p0,2);
				Tfile.Read(ArFacesTriangles[i].p1,2);
				Tfile.Read(ArFacesTriangles[i].p2,2);
				Tfile.Position:=Tfile.Position+2;
			end;
			//Дойдем к данным о локальной системе объекта
			Tfile.Position:=TempPos;
			ChPos:=self.FindChunk(TRI_LOCAL,true);
			SkipHeader;
			TFile.Read(Local,sizeof(single)*12);
			//Совершаем преобразования
			for i:=0 to FNofVerts-1 do
			begin
				ArVertexes[i].x-=Local[9];
				ArVertexes[i].z-=Local[10];
				ArVertexes[i].y-=Local[11];
				x0:=ArVertexes[i].x;
				x1:=ArVertexes[i].y;
				x2:=ArVertexes[i].z;
				ArVertexes[i].x:=Local[0]*x0+Local[2]*x1+Local[1]*x2;
				ArVertexes[i].z:=Local[3]*x0+Local[5]*x1+Local[4]*x2;
				ArVertexes[i].y:=Local[6]*x0+Local[8]*x1+Local[7]*x2;
			end;
            Tfile.Position:=TempPos;
			ChPos:=self.FindChunk(TRI_FACELIST,true);
            Tfile.Position:=Tfile.Position+2+6+FNOfFaces*4*2;
			ChPos:=self.FindChunk(TRI_MATERIAL,false);
			ReadHeader(@Ch);
            if Ch.ID=TRI_MATERIAL then
				begin
				TFile.Position:=TFile.Position+6;
            	Tfile.Read(c,1);
            	s:='';
				while c<>#0 do
					begin
           	 		s+=c;
        			Tfile.Read(c,1);
					end;
        		FMaterialID:=-1;
        		{$IFDEF SGDebuging}
					WriteLn('Find matelial - "',s,'" in ',high(AModel^.ArObjects));
					{$ENDIF}
          		for i:=0 to AModel^.NOfMaterials-1 do
            		if AModel^.ArMaterials[i].strName=s then
						begin
						FMaterialID:=i;
						break;
						end;
               	FHasTexture:=true;
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
	result:=true;
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

procedure TSGLoad3DS.ComputeNormals(AModel: PSGModel);
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

begin
    if AModel^.NOfObjects>0 then
    begin
        for iObject:=0 to AModel^.NOfObjects-1 do
        begin
            with AModel^.ArObjects[iObject] do
            begin
				SetLength(ArNormals,FNOfVerts);
				SetLength(pNormals,FNOfFaces);
				SetLength(pTempNormals,FNOfFaces);
				for i:=0 to FNOfFaces-1 do
				begin
					vPoly[0]:=ArVertexes[ArFacesTriangles[i].p0];
					vPoly[1]:=ArVertexes[ArFacesTriangles[i].p1];
					vPoly[2]:=ArVertexes[ArFacesTriangles[i].p2];
					
					vVector1:=vPoly[0]-vPoly[2];
					vVector2:=vPoly[1]-vPoly[2];
					
					vNormal:=Cross(vVector1,vVector2);
					pTempNormals[i]:=vNormal;
                    vNormal.Normalize;
                    pNormals[i]:=vNormal;
				end;
                vSum.Import();
                shared:=0;
                for i:=0 to FNOfVerts-1 do
                begin
                    for ii:=0 to FNOfFaces-1 do
                    begin
                        if (ArFacesTriangles[ii].p0=i)or(ArFacesTriangles[ii].p1=i)or(ArFacesTriangles[ii].p2=i) then
                        begin
                            vSum+=pTempNormals[ii];
                            shared+=1;
                        end;
                    end;
                    ArNormals[i]:=vSum/(-shared);
                    ArNormals[i].Normalize;
                    vSum.Import();
                    shared:=0;
                end;
			FHasNormals:=True;
            end;
            SetLength(pNormals,0);
			SetLength(pTempNormals,0);
        end;
    end;
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
