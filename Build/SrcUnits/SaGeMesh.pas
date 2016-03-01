{$INCLUDE Includes\SaGe.inc}

unit SaGeMesh;

interface

uses
      Classes
    , SaGeCommon
    , SaGeBase
    , SaGeBased
    , SaGeImages
    , SaGeRender
    , Crt
    , SaGeContext;
const
	SGMeshVersion : TSGQuadWord = 169;
type
	// Это тип типа хранения цветов в нашей модели
	TSGMeshColorType = (SGMeshColorType3f,SGMeshColorType4f,SGMeshColorType3b,SGMeshColorType4b);
	TSGMeshIndexFormat = (SGMeshIndexFormat1b,SGMeshIndexFormat2b,SGMeshIndexFormat4b);
	// Это тип типа хранения вершин в нашей модели
	TSGMeshVertexType = TSGVertexFormat;
	TSGMeshBumpType = (SGMeshBumpTypeNone,SGMeshBumpTypeCopyTexture2f,SGMeshBumpTypeCubeMap3f,SGMeshBumpType2f);
const
	// Типы вершин
	SGMeshVertexType2f = SGVertexFormat2f;
	SGMeshVertexType3f = SGVertexFormat3f;
	SGMeshVertexType4f = SGVertexFormat4f;
type
	TSGCustomModel = class;
	TSG3dObject    = class;
	TSGMaterial    = class;
	
	// ======== Дальше идут структуры индексов веpшин  ========
	
	(**=========================1b===========================**)
	
	TSGFaceLine1b = record
		case byte of
		0:  ( p0,p1: TSGByte );
		1:  ( p:packed array [0..1] of TSGByte );
		end;
	PTSGFaceLine1b = ^ TSGFaceLine1b;
	
    TSGFaceTriangle1b = record
	case byte of
	0: ( p0, p1, p2: TSGByte );
	1: ( p:packed array[0..2] of TSGByte );
	2: ( v:packed array[0..2] of TSGByte );
    end;
    PTSGFaceTriangle1b = ^ TSGFaceTriangle1b;
	
	TSGFaceQuad1b = record
	case byte of
	0: ( p0, p1, p2, p3: TSGByte );
	1: ( p : packed array[0..3] of TSGByte );
    end;
	PTSGFaceQuad1b = ^ TSGFaceQuad1b;
	
	TSGFacePoint1b = record
	case byte of
	0: ( p0: TSGByte );
	1: ( p : packed array[0..0] of TSGByte );
    end;
	PTSGFacePoint1b = ^ TSGFacePoint1b;
	
	(**=========================2b===========================**)
	
	TSGFaceLine2b = record
		case byte of
		0:  ( p0,p1: TSGWord );
		1:  ( p:packed array [0..1] of TSGWord );
		end;
	PTSGFaceLine2b = ^ TSGFaceLine2b;
	
    TSGFaceTriangle2b = record
	case byte of
	0: ( p0, p1, p2: TSGWord );
	1: ( p:packed array[0..2] of TSGWord );
	2: ( v:packed array[0..2] of TSGWord );
    end;
    PTSGFaceTriangle2b = ^ TSGFaceTriangle2b;
	
	TSGFaceQuad2b = record
	case byte of
	0: ( p0, p1, p2, p3: TSGWord );
	1: ( p : packed array[0..3] of TSGWord );
    end;
	PTSGFaceQuad2b = ^ TSGFaceQuad2b;
	
	TSGFacePoint2b = record
	case byte of
	0: ( p0: TSGWord );
	1: ( p : packed array[0..0] of TSGWord );
    end;
	PTSGFacePoint2b = ^ TSGFacePoint2b;
	
	(**=========================4b===========================**)
	
	TSGFaceLine4b = record
		case byte of
		0:  ( p0,p1: TSGLongWord );
		1:  ( p:packed array [0..1] of TSGLongWord );
		end;
	PTSGFaceLine4b = ^ TSGFaceLine4b;
	TSGFaceLine = TSGFaceLine4b;
	PTSGFaceLine = PTSGFaceLine4b;
	
    TSGFaceTriangle4b = record
	case byte of
	0: ( p0, p1, p2: TSGLongWord );
	1: ( p:packed array[0..2] of TSGLongWord );
	2: ( v:packed array[0..2] of TSGLongWord );
    end;
    PTSGFaceTriangle4b = ^ TSGFaceTriangle4b;
    TSGFaceTriangle = TSGFaceTriangle4b;
	PTSGFaceTriangle = PTSGFaceTriangle4b;
	
	TSGFaceQuad4b = record
	case byte of
	0: ( p0, p1, p2, p3: TSGLongWord );
	1: ( p : packed array[0..3] of TSGLongWord );
    end;
	PTSGFaceQuad4b = ^ TSGFaceQuad4b;
	TSGFaceQuad = TSGFaceQuad4b;
	PTSGFaceQuad = PTSGFaceQuad4b;
	
	TSGFacePoint4b = record
	case byte of
	0: ( p0: TSGLongWord );
	1: ( p : packed array[0..0] of TSGLongWord );
    end;
	PTSGFacePoint4b = ^ TSGFacePoint4b;
	TSGFacePoint = TSGFacePoint4b;
	PTSGFacePoint = PTSGFacePoint4b;
	
	TSGMaterial = class (TSGContextObject)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
			private
		FColorDiffuse, FColorSpecular, FColorAmbient : TSGColor4f;
		FIllum, FNS : TSGSingle;
		FMapDiffuse, FMapBump, FMapOpacity, FMapSpecular, FMapAmbient : TSGImage;
		FName : TSGString;
		FEnableBump, FEnableTexture : TSGBoolean;
			public
		procedure SetColorAmbient(const r,g,b :TSGSingle);
		procedure SetColorSpecular(const r,g,b :TSGSingle);
		procedure SetColorDiffuse(const r,g,b :TSGSingle);
		procedure AddDiffuseMap(const VFileName : TSGString);
		procedure AddBumpMap(const VFileName : TSGString);
		function MapDiffuseWay():TSGString;inline;
		function MapBumpWay():TSGString;inline;
			public
		procedure Bind(const VObject : TSG3DObject);
		procedure UnBind(const VObject : TSG3DObject);
			public
		property Name          : TSGString  read FName          write FName;
		property Illum         : TSGSingle  read FIllum         write FIllum;
		property Ns            : TSGSingle  read FNS            write FNS;
		property EnableBump    : TSGBoolean read FEnableBump    write FEnableBump;
		property EnableTexture : TSGBoolean read FEnableTexture write FEnableTexture;
		property ImageBump     : TSGImage   read FMapBump       write FMapBump;
		property ImageTexture  : TSGImage   read FMapDiffuse    write FMapDiffuse;
		end;
	
    { TSG3dObject }
    // Наша моделька..
type
    TSG3DObject = class(TSGDrawClass)
    public
        constructor Create(); override;
        destructor Destroy(); override;
        class function ClassName():string;override;
    protected
        // Количество вершин
        FNOfVerts : TSGQuadWord;
        
        // Есть ли у модельки текстурка
        FHasTexture : TSGBoolean;
        FCountTextureFloatsInVertexArray : TSGLongWord;
        // Есть ли нормали у модельки
        FHasNormals : TSGBoolean;
        // Есть ли у нее цвета
        FHasColors  : TSGBoolean;
        // Используется ли у нее индексированный рендеринг
        FQuantityFaceArrays : TSGLongWord;
        FBumpFormat : TSGMeshBumpType;
    protected
        // Тип полигонов в модельки (SGR_QUADS, SGR_TRIANGLES, SGR_LINES, SGR_LINE_LOOP ....)
        FObjectPoligonesType    : TSGLongWord;
        // Тип вершин в модельке
        FVertexType       : TSGMeshVertexType;
        // Тип хранение цветов
        FColorType        : TSGMeshColorType;
    private
		function GetSizeOfOneVertex():LongWord;inline;
		
		function GetSizeOfOneTextureCoord():TSGLongWord;inline;
		function GetSizeOfOneVertexCoord():TSGLongWord;inline;
		function GetSizeOfOneColorCoord():TSGLongWord;inline;
		function GetSizeOfOneNormalCoord():TSGLongWord;inline;
		
		function GetCountOfOneTextureCoord():TSGLongWord;inline;
		function GetCountOfOneVertexCoord():TSGLongWord;inline;
		function GetCountOfOneColorCoord():TSGLongWord;inline;
		function GetCountOfOneNormalCoord():TSGLongWord;inline;
		
		function GetVertexLength():QWord;inline;
		procedure SetHasTexture(const VHasTexture:TSGBoolean);inline;
		function GetQuantityFaces(const Index : TSGLongWord):TSGQuadWord;inline;
		function GetPoligonesType(const ArIndex : TSGLongWord):TSGLongWord;inline;
		procedure SetPoligonesType(const ArIndex : TSGLongWord;const NewPoligonesType : TSGLongWord);inline;
	public
		procedure SetColorType(const VNewColorType:TSGMeshColorType);
		procedure SetVertexType(const VNewVertexType:TSGMeshVertexType);
		procedure ChangeMeshColorType4b();
    public
        // Эти свойства уже были прокоментированы выше (см на что эти свойства ссылаются)
        property CountTextureFloatsInVertexArray   : TSGLongWord       read FCountTextureFloatsInVertexArray write FCountTextureFloatsInVertexArray;
        property BumpFormat                        : TSGMeshBumpType   read FBumpFormat          write FBumpFormat;
        property PoligonesType[Index:TSGLongWord]  : TSGLongWord       read GetPoligonesType     write SetPoligonesType;
		property QuantityVertexes                  : TSGQuadWord       read FNOfVerts;
		property QuantityFaces[Index : TSGLongWord]: TSGQuadWord       read GetQuantityFaces;
		property HasTexture                        : Boolean           read FHasTexture          write SetHasTexture;
		property HasColors                         : Boolean           read FHasColors           write FHasColors;
		property HasNormals                        : Boolean           read FHasNormals          write FHasNormals;
		property ColorType                         : TSGMeshColorType  read FColorType           write SetColorType;
		property VertexType                        : TSGMeshVertexType read FVertexType          write SetVertexType;
		property ObjectPoligonesType               : LongWord          read FObjectPoligonesType write FObjectPoligonesType;
    protected
        // А это у нас массив индексов
		ArFaces : packed array of 
			packed record 
				FIndexFormat      : TSGMeshIndexFormat;
				FPoligonesType    : TSGLongWord;
				FNOfFaces         : TSGQuadWord;
				// Указательл на первый элемент области памяти, где находятся наши индексы
				FArray            : TSGPointer;
				// Идентификатор материала
				FMaterialID       : TSGInt64;
				end;
		
		// А это у нас массив самих вершин. Его пришлось сделать таким. 
		// Не смотри что он такой ебанутый (TSGPointer). 
		// Он в себе содерщит пиздец сколько всего, но обрабатывается по другому...
		//! B каком порядке записывается в памяти информация о вершине
		(* Vertex = [Vertexes, Colors, Normals, TexVertexes] *)
		//! Что предстваляет из себя этот массив
		(* Array of Vertex *)
		ArVertex:TSGPointer;
	public
		// Возвращает указатель на первый элемент массива вершин
		function GetArVertexes():TSGPointer;inline;
		// Возвращает указатель на первый элемент массива индексов
		function GetArFaces(const Index : LongWord = 0):TSGPointer;inline;
		
	private
		function GetVertex3f(const Index : TSGMaxEnum):PTSGVertex3f;inline;
		function GetVertex2f(const Index : TSGMaxEnum):PTSGVertex2f;inline;
		function GetVertex4f(const Index : TSGMaxEnum):PTSGVertex4f;inline;
		
	public
		// Эти совйтсва возвращают указатель на Index-ый элемент массива вершин 
		//! Это можно пользоваться только когда, когда FVertexType = SGMeshVertexType3f, иначе Result = nil
		property ArVertex3f[Index : TSGMaxEnum]:PTSGVertex3f read GetVertex3f;
		//! Это можно пользоваться только когда, когда FVertexType = SGMeshVertexType2f, иначе Result = nil
		property ArVertex2f[Index : TSGMaxEnum]:PTSGVertex2f read GetVertex2f;
		//! Это можно пользоваться только когда, когда FVertexType = SGMeshVertexType4f, иначе Result = nil
		property ArVertex4f[Index : TSGMaxEnum]:PTSGVertex4f read GetVertex4f;
		
		// Добавляет пустую(ые) вершины в массив вершин
		procedure AddVertex(const FQuantityNewVertexes:LongWord = 1);
		// Добавляет еще элемент(ы) в массив индексов
		procedure AddFace(const ArIndex:TSGLongWord;const FQuantityNewFaces:LongWord = 1);
	
	private
		function GetColor3f(const Index:TSGMaxEnum):PTSGColor3f;inline;
		function GetColor4f(const Index:TSGMaxEnum):PTSGColor4f;inline;
		function GetColor3b(const Index:TSGMaxEnum):PTSGColor3b;inline;
		function GetColor4b(const Index:TSGMaxEnum):PTSGColor4b;inline;
		
	public
		// Возвращает указатель на структуру данных,
		// к которой хранится информация о цвете вершины с индексом Index
		// Каждую функцию можно использовать только когда установлен соответствующий тип формата цветов
		// Иначе Result = nil.
		(* Для установки цвета лучше использовать процедуру SetColor, описанную ниже *)
		property ArColor3f[Index : TSGMaxEnum]:PTSGColor3f read GetColor3f;
		property ArColor4f[Index : TSGMaxEnum]:PTSGColor4f read GetColor4f;
		property ArColor3b[Index : TSGMaxEnum]:PTSGColor3b read GetColor3b;
		property ArColor4b[Index : TSGMaxEnum]:PTSGColor4b read GetColor4b;
		
		// Эта процедура устанавливает цвет вершины. Работает для любого формата хранение цвета.
		procedure SetColor(const Index:TSGMaxEnum;const r,g,b:TSGSingle; const a:TSGSingle = 1);inline;
		// Автоматически определяет нужный формат хранения цветов. (В зависимости от рендера)
		procedure AutoSetColorType(const VWithAlpha:Boolean = False);inline;
		procedure AutoSetIndexFormat(const ArIndex : TSGLongWord; const MaxVertexLength : TSGQuadWord );
	private
		function GetNormal(const Index:TSGMaxEnum):PTSGVertex3f;inline;
	
	public
		// Свойства для редактирования нормалей
		property ArNormal[Index : TSGMaxEnum]:PTSGVertex3f read GetNormal;
		
	private
		function GetTexVertex(const Index : TSGMaxEnum): PTSGVertex2f;inline;
		function GetTexVertex3f(const Index : TSGMaxEnum): PTSGVertex3f;inline;
		function GetTexVertex4f(const Index : TSGMaxEnum): PTSGVertex4f;inline;
		
	public
		property ArTexVertex[Index : TSGMaxEnum] : PTSGVertex2f read GetTexVertex;
		property ArTexVertex2f[Index : TSGMaxEnum] : PTSGVertex2f read GetTexVertex;
		property ArTexVertex3f[Index : TSGMaxEnum] : PTSGVertex3f read GetTexVertex3f;
		property ArTexVertex4f[Index : TSGMaxEnum] : PTSGVertex4f read GetTexVertex4f;
		
		// Устанавливает количество вершин
		procedure SetVertexLength(const NewVertexLength:TSGQuadWord);inline;
		
		// Возвращает сколько в байтах занимают массив вершин
		function GetVertexesSize():TSGMaxEnum;overload;inline;
		
		// Эта процедура для DirectX. Дело в том, что там нету SGR_QUADS. Так что он разбивается на 2 треугольника.
		procedure SetFaceQuad(const ArIndex:TSGLongWord;const Index :TSGMaxEnum; const p0,p1,p2,p3:TSGLongWord);
		procedure SetFaceTriangle(const ArIndex:TSGLongWord;const Index :TSGMaxEnum; const p0,p1,p2:TSGLongWord);
		procedure SetFaceLine(const ArIndex:TSGLongWord;const Index :TSGMaxEnum; const p0,p1:TSGLongWord);
		procedure SetFacePoint(const ArIndex:TSGLongWord;const Index :TSGMaxEnum; const p0:TSGLongWord);
		
		// Возвращает индекс на первый элемент массива индексов. Не просто возвращает, а хитро возвращает.
		// Теперь эти функции можно использовать как массивы. Так что их очень просто использовать.
		// Но нужно соблюдать тип хранения индексов
		function ArFacesLines1b(const Index:TSGLongWord = 0)     : PTSGFaceLine1b;     inline;
		function ArFacesQuads1b(const Index:TSGLongWord = 0)     : PTSGFaceQuad1b;     inline;
		function ArFacesTriangles1b(const Index:TSGLongWord = 0) : PTSGFaceTriangle1b; inline;
		function ArFacesPoints1b(const Index:TSGLongWord = 0)    : PTSGFacePoint1b;    inline;
		
		function ArFacesLines2b(const Index:TSGLongWord = 0)     : PTSGFaceLine2b;     inline;
		function ArFacesQuads2b(const Index:TSGLongWord = 0)     : PTSGFaceQuad2b;     inline;
		function ArFacesTriangles2b(const Index:TSGLongWord = 0) : PTSGFaceTriangle2b; inline;
		function ArFacesPoints2b(const Index:TSGLongWord = 0)    : PTSGFacePoint2b;    inline;
		
		function ArFacesLines4b(const Index:TSGLongWord = 0)     : PTSGFaceLine4b;     inline;
		function ArFacesQuads4b(const Index:TSGLongWord = 0)     : PTSGFaceQuad4b;     inline;
		function ArFacesTriangles4b(const Index:TSGLongWord = 0) : PTSGFaceTriangle4b; inline;
		function ArFacesPoints4b(const Index:TSGLongWord = 0)    : PTSGFacePoint4b;    inline;
		
		function ArFacesLines(const ArIndex:TSGLongWord = 0;const Index:TSGLongWord = 0)     : TSGFaceLine;     inline;
		function ArFacesQuads(const ArIndex:TSGLongWord = 0;const Index:TSGLongWord = 0)     : TSGFaceQuad;     inline;
		function ArFacesTriangles(const ArIndex:TSGLongWord = 0;const Index:TSGLongWord = 0) : TSGFaceTriangle; inline;
		function ArFacesPoints(const ArIndex:TSGLongWord = 0;const Index:TSGLongWord = 0)    : TSGFacePoint;    inline;
		
		procedure CreateMaterialIDInLastFaceArray(const VMAterialName : TSGString);
		procedure SetFaceArLength(const NewArLength : TSGLongWord);
		procedure AddFaceArray(const QuantityNewArrays : TSGLongWord = 1);
		// Устанавливает длинну массива индексов
		procedure SetFaceLength(const ArIndex:TSGLongWord;const NewLength:TSGQuadWord);inline;
		// Возвращает действительную длинну массива индексов
		function GetFaceLength(const Index:TSGLongWord):TSGQuadWord;overload;inline;
		// Возвращает действительную длинну массива индексов в зависимости он их длинны и их типа, заданых параметрами
		class function GetFaceLength(const FaceLength:TSGQuadWord; const ThisPoligoneType:LongWord):TSGQuadWord;overload;inline;
		// Возвращает, сколько в TSGFaceType*Result байтов занимает одна структура индексов. Очень прикольная функция.
		class function GetPoligoneInt(const ThisPoligoneType:LongWord):Byte;inline;
		class function GetFaceInt(const ThisFaceFormat : TSGMeshIndexFormat):Byte;inline;
	public
		// Ствойства для получения и редактирования длинн массивов
		property QuantityFaceArrays       : TSGLongWord read FQuantityFaceArrays  write SetFaceArLength;
		property Faces[Index:TSGLongWord] : TSGQuadWord read GetFaceLength        write SetFaceLength;
		property Vertexes                 : TSGQuadWord read GetVertexLength      write SetVertexLength;
    protected
		// Вклбючено ли VBO
		// VBO - Vertex Buffer Object
		// Vertex Buffer Object - это такая технология, при которой можно рисовать, 
		//    держа все массивы в памяти видеокарте, а не в оперативной памяти
		// Если на вашем устройстве нету видеокарты (типо нетбук), то массивы будут копироваться в оперативку
		FEnableVBO      : TSGBoolean;
		
		// Идентификатор массива вершин в видюхе
        FVertexesBuffer    : TSGLongWord;
        // Идентификатор массива индексов в видюхе
        FFacesBuffers      : packed array of TSGLongWord;
        
		// Включен ли Cull Face
        FEnableCullFace : TSGBoolean;
        FEnableCullFaceFront, FEnableCullFaceBack : TSGBoolean;
        // Цвет обьекта
        FObjectColor    : TSGColor4f;
    public
		property EnableVBO      : TSGBoolean read FEnableVBO      write FEnableVBO;
		property ObjectColor    : TSGColor4f read FObjectColor    write FObjectColor;
		property EnableCullFace : TSGBoolean read FEnableCullFace write FEnableCullFace;
		property EnableCullFaceFront : TSGBoolean read FEnableCullFaceFront write FEnableCullFaceFront;
		property EnableCullFaceBack  : TSGBoolean read FEnableCullFaceBack  write FEnableCullFaceBack;
    public
        // Догадайся с 3х раз
        procedure Draw(); override;
        // Дело в том, что если включен Cull Face, то Draw нужно делать 2 раза.
        // Так что вод тут делается Draw, а в Draw просто проверяется, включен или не  Cull Face, 
        //   и в зависимости от этого он вызывает эту процедуду 1 или 2 раза
        procedure BasicDraw(); inline;
        // Подгрузка массивов в память видеокарты
        procedure LoadToVBO();
        // Очищение памяти видеокарты от массивов этого класса
        procedure ClearVBO();
        // Процедурка очищает оперативную память от массивов этого класса
        procedure ClearArrays(const ClearN:Boolean = True);
			public
        // Эта процедурка автоматически выделяет память под нормали и вычесляет их, исходя из данных вершин
        procedure AddNormals();virtual;
        
		procedure SaveToSG3DOFile(const FileWay:TSGString);
		procedure LoadFromSG3DOFile(const FileWay:TSGString);
		
		procedure SaveToSG3DO(const Stream:TStream);
		procedure LoadFromSG3DO(const Stream:TStream);
		
        (* Я ж переписывал этот класс. Это то, что я не написал. *)
		//procedure Stripificate;overload;inline;
		//procedure Stripificate(var VertexesAndTriangles:TSGArTSGArTSGFaceType;var OutputStrip:TSGArTSGFaceType);overload;
		
		// Выводит полную информацию о характеристиках модельки
		procedure WriteInfo(const PredStr:string = '');
		// Загрузка из файла
		procedure LoadFromFile(const FileWay:string);
		// Загрузка из текстовова формата файлов *.obj
		procedure LoadFromOBJ(const FFileName:string;const opf : PTextFile = nil);virtual;
	public
		// Возвращает, сколько занимают байтов вершины
		function VertexesSize():QWord;Inline;
		// Возвращает, сколько занимают байтов индексы
		function FacesSize():QWord;inline;
		// Возвращает, сколько занимают байтов вершины и индексы
		function Size():QWord;inline;
	protected 
		// Имя модельки
		FName : TSGString;
		FParent : TSGCustomModel;
		FObjectMaterialID : TSGInt64;
		
		FEnableObjectMatrix : Boolean;
		FObjectMatrix : TSGMatrix4;
	public
		procedure SetMatrix(const m : TSGMatrix4);
	public
		// Свойство : Имя модельки
		property Name             : TSGString      read FName             write FName;
		// Свойство : Идентификатор материала
		property ObjectMaterialID : TSGInt64       read FObjectMaterialID write FObjectMaterialID;
		property Parent           : TSGCustomModel read FParent           write FParent;
		property ObjectMatrix     : TSGMatrix4     read FObjectMatrix     write SetMatrix;
    end;

    PSG3dObject = ^TSG3dObject;

    { TSGCustomModel }
	TSGCustomModelMesh = record
		FMesh    : TSG3DObject;
		FCopired : TSGInt64;
		FMatrix  : TSGMatrix4;
		end;
	
    TSGCustomModel = class(TSGDrawClass)
    public
        constructor Create;override;
        destructor Destroy; override;
        class function ClassName:String;override;
    protected
        FQuantityObjects   : TSGQuadWord;
        FQuantityMaterials : TSGQuadWord;
	
        FArMaterials : packed array of TSGMaterial;
        FArObjects   : packed array of TSGCustomModelMesh;
    private
		function GetObject(const Index : TSGMaxEnum):TSG3dObject;
		function GetObjectMatrix(const Index : TSGMaxEnum):TSGPointer;
        procedure AddObjectColor(const ObjColor: TSGColor4f);
        function GetMaterial(const Index : TSGMaxEnum):TSGMaterial;
    public
		property QuantityMaterials : TSGQuadWord read FQuantityMaterials;
		property QuantityObjects   : TSGQuadWord read FQuantityObjects;
		property Objects[Index : TSGMaxEnum]:TSG3dObject read GetObject;
		property ObjectMatrix[Index : TSGMaxEnum]:TSGPointer read GetObjectMatrix;
		property ObjectColor: TSGColor4f write AddObjectColor;
		property Materials[Index : TSGMaxEnum] : TSGMaterial read GetMaterial;
    public
		function AddMaterial():TSGMaterial;inline;
		function LastMaterial():TSGMaterial;inline;
		function AddObject():TSG3DObject;inline;
		function LastObject():TSG3DObject;inline;
		function CreateMaterialIDInLastObject(const VMaterialName : TSGString):TSGBoolean;
    public
		procedure DrawObject(const Index : TSGLongWord);
        procedure Draw(); override;
		procedure LoadToVBO();
        procedure WriteInfo();
        procedure Clear();virtual;
        // SGR_TRIANGLES -> SGR_TRIANGLE_STRIP
        procedure Stripificate();
    public
		// Загрузка и соxранение
		procedure SaveToFile(const FileWay: TSGString);
        procedure LoadFromFile(const FileWay:TSGString);
    public
        procedure LoadFromSG3DMFile(const FileWay: TSGString);
        procedure SaveToSG3DMFile(const FileWay: TSGString);
        procedure LoadFromSG3DM(const Stream : TStream);
        procedure SaveToSG3DM(const Stream : TStream);
        // Загрузить формат 3DS-Max-а
        function Load3DSFromFile(const FileWay:TSGString):TSGBoolean;
        function Load3DSFromStream(const VStream:TStream;const VFileName:TSGString):TSGBoolean;
    public
		procedure Dublicate(const Index:TSGLongWord);
		procedure Translate(const Index:TSGLongWord;const Vertex : TSGVertex3f);
    public
		function VertexesSize():TSGQWord;
		function FacesSize():TSGQWord;
		function Size():TSGQWord;
    end;
    PSGCustomModel = ^TSGCustomModel;
    
{$DEFINE SGREADINTERFACE}      {$INCLUDE Includes\SaGeMesh3ds.inc} {$UNDEF SGREADINTERFACE}

implementation

{$DEFINE SGREADIMPLEMENTATION} {$INCLUDE Includes\SaGeMesh3ds.inc} {$UNDEF SGREADIMPLEMENTATION}
{$INCLUDE Includes\SaGeMeshObj.inc}

procedure TSG3DObject.CreateMaterialIDInLastFaceArray(const VMAterialName : TSGString);
var
	i : TSGLongWord;
begin
if (FParent<>nil) then
	begin
	if FParent.QuantityMaterials<>0 then
		for i := 0 to FParent.QuantityMaterials - 1 do
			if FParent.Materials[i].Name = VMAterialName then
				begin
				ArFaces[FQuantityFaceArrays - 1].FMaterialID := i;
				Break;
				end;
	end;
end;

function TSG3DObject.ArFacesLines(const ArIndex:TSGLongWord = 0;const Index:TSGLongWord = 0)     : TSGFaceLine;     inline;
begin
FillChar(Result,SizeOf(Result),0);
case ArFaces[ArIndex].FIndexFormat of
SGMeshIndexFormat1b: 
	begin
	Result.p0:=PTSGFaceLine1b(ArFaces[ArIndex].FArray)[Index].p0;
	Result.p1:=PTSGFaceLine1b(ArFaces[ArIndex].FArray)[Index].p1;
	end;
SGMeshIndexFormat2b: 
	begin
	Result.p0:=PTSGFaceLine2b(ArFaces[ArIndex].FArray)[Index].p0;
	Result.p1:=PTSGFaceLine2b(ArFaces[ArIndex].FArray)[Index].p1;
	end;
SGMeshIndexFormat4b: 
	begin
	Result.p0:=PTSGFaceLine4b(ArFaces[ArIndex].FArray)[Index].p0;
	Result.p1:=PTSGFaceLine4b(ArFaces[ArIndex].FArray)[Index].p1;
	end;
end;
end;

function TSG3DObject.ArFacesQuads(const ArIndex:TSGLongWord = 0;const Index:TSGLongWord = 0)     : TSGFaceQuad;     inline;
begin
FillChar(Result,SizeOf(Result),0);
if Render.RenderType<>SGRenderOpenGL then
	case ArFaces[ArIndex].FIndexFormat of
	SGMeshIndexFormat1b: 
		begin
		Result.p0:=ArFacesTriangles1b(ArIndex)[Index*2].p[0];
		Result.p1:=ArFacesTriangles1b(ArIndex)[Index*2].p[1];
		Result.p2:=ArFacesTriangles1b(ArIndex)[Index*2].p[2];
		Result.p3:=ArFacesTriangles1b(ArIndex)[Index*2+1].p[1];
		end;
	SGMeshIndexFormat2b: 
		begin
		Result.p0:=ArFacesTriangles2b(ArIndex)[Index*2].p[0];
		Result.p1:=ArFacesTriangles2b(ArIndex)[Index*2].p[1];
		Result.p2:=ArFacesTriangles2b(ArIndex)[Index*2].p[2];
		Result.p3:=ArFacesTriangles2b(ArIndex)[Index*2+1].p[1];
		end;
	SGMeshIndexFormat4b: 
		begin
		Result.p0:=ArFacesTriangles4b(ArIndex)[Index*2].p[0];
		Result.p1:=ArFacesTriangles4b(ArIndex)[Index*2].p[1];
		Result.p2:=ArFacesTriangles4b(ArIndex)[Index*2].p[2];
		Result.p3:=ArFacesTriangles4b(ArIndex)[Index*2+1].p[1];
		end;
	end
else
	case ArFaces[ArIndex].FIndexFormat of
	SGMeshIndexFormat1b: 
		begin
		Result.p0:=ArFacesQuads1b(ArIndex)[Index].p[0];
		Result.p1:=ArFacesQuads1b(ArIndex)[Index].p[1];
		Result.p2:=ArFacesQuads1b(ArIndex)[Index].p[2];
		Result.p3:=ArFacesQuads1b(ArIndex)[Index].p[3];
		end;
	SGMeshIndexFormat2b:
		begin
		Result.p0:=ArFacesQuads2b(ArIndex)[Index].p[0];
		Result.p1:=ArFacesQuads2b(ArIndex)[Index].p[1];
		Result.p2:=ArFacesQuads2b(ArIndex)[Index].p[2];
		Result.p3:=ArFacesQuads2b(ArIndex)[Index].p[3];
		end;
	SGMeshIndexFormat4b:
		begin
		Result.p0:=ArFacesQuads4b(ArIndex)[Index].p[0];
		Result.p1:=ArFacesQuads4b(ArIndex)[Index].p[1];
		Result.p2:=ArFacesQuads4b(ArIndex)[Index].p[2];
		Result.p3:=ArFacesQuads4b(ArIndex)[Index].p[3];
		end;
	end;
end;

function TSG3DObject.ArFacesTriangles(const ArIndex:TSGLongWord = 0;const Index:TSGLongWord = 0) : TSGFaceTriangle; inline;
begin
FillChar(Result,SizeOf(Result),0);
case ArFaces[ArIndex].FIndexFormat of
SGMeshIndexFormat1b: 
	begin
	Result.p0:=PTSGFaceTriangle1b(ArFaces[ArIndex].FArray)[Index].p0;
	Result.p1:=PTSGFaceTriangle1b(ArFaces[ArIndex].FArray)[Index].p1;
	Result.p2:=PTSGFaceTriangle1b(ArFaces[ArIndex].FArray)[Index].p2;
	end;
SGMeshIndexFormat2b: 
	begin
	Result.p0:=PTSGFaceTriangle2b(ArFaces[ArIndex].FArray)[Index].p0;
	Result.p1:=PTSGFaceTriangle2b(ArFaces[ArIndex].FArray)[Index].p1;
	Result.p2:=PTSGFaceTriangle2b(ArFaces[ArIndex].FArray)[Index].p2;
	end;
SGMeshIndexFormat4b: 
	begin
	Result.p0:=PTSGFaceTriangle4b(ArFaces[ArIndex].FArray)[Index].p0;
	Result.p1:=PTSGFaceTriangle4b(ArFaces[ArIndex].FArray)[Index].p1;
	Result.p2:=PTSGFaceTriangle4b(ArFaces[ArIndex].FArray)[Index].p2;
	end;
end;
end;

function TSG3DObject.ArFacesPoints(const ArIndex:TSGLongWord = 0;const Index:TSGLongWord = 0)    : TSGFacePoint;    inline;
begin
FillChar(Result,SizeOf(Result),0);
case ArFaces[ArIndex].FIndexFormat of
SGMeshIndexFormat1b:
	Result.p0:=PTSGFacePoint1b(ArFaces[ArIndex].FArray)[Index].p0;
SGMeshIndexFormat2b:
	Result.p0:=PTSGFacePoint2b(ArFaces[ArIndex].FArray)[Index].p0;
SGMeshIndexFormat4b:
	Result.p0:=PTSGFacePoint4b(ArFaces[ArIndex].FArray)[Index].p0;
end;
end;


procedure TSG3DObject.SetPoligonesType(const ArIndex : TSGLongWord;const NewPoligonesType : TSGLongWord);inline;
begin
ArFaces[ArIndex].FPoligonesType:=NewPoligonesType;
end;

function TSG3DObject.GetPoligonesType(const ArIndex : TSGLongWord):TSGLongWord;inline;
begin
Result:=ArFaces[ArIndex].FPoligonesType;
end;

procedure TSG3DObject.AutoSetIndexFormat(const ArIndex : TSGLongWord; const MaxVertexLength : TSGQuadWord );
begin
if (MaxVertexLength<=255) and (Render.RenderType=SGRenderOpenGL) then
	ArFaces[ArIndex].FIndexFormat:=SGMeshIndexFormat1b
else if (MaxVertexLength<=255*255) or (Render.RenderType=SGRenderDirectX) then
	ArFaces[ArIndex].FIndexFormat:=SGMeshIndexFormat2b
else 
	ArFaces[ArIndex].FIndexFormat:=SGMeshIndexFormat4b;
end;

procedure TSG3DObject.SetFaceTriangle(const ArIndex:TSGLongWord;const Index :TSGMaxEnum; const p0,p1,p2:TSGLongWord);
begin
case ArFaces[ArIndex].FIndexFormat of
SGMeshIndexFormat1b: 
	begin
	ArFacesTriangles1b(ArIndex)[Index].p[0]:=p0;
	ArFacesTriangles1b(ArIndex)[Index].p[1]:=p1;
	ArFacesTriangles1b(ArIndex)[Index].p[2]:=p2;
	end;
SGMeshIndexFormat2b: 
	begin
	ArFacesTriangles2b(ArIndex)[Index].p[0]:=p0;
	ArFacesTriangles2b(ArIndex)[Index].p[1]:=p1;
	ArFacesTriangles2b(ArIndex)[Index].p[2]:=p2;
	end;
SGMeshIndexFormat4b: 
	begin
	ArFacesTriangles4b(ArIndex)[Index].p[0]:=p0;
	ArFacesTriangles4b(ArIndex)[Index].p[1]:=p1;
	ArFacesTriangles4b(ArIndex)[Index].p[2]:=p2;
	end;
end;
end;

procedure TSG3DObject.SetFaceLine(const ArIndex:TSGLongWord;const Index :TSGMaxEnum; const p0,p1:TSGLongWord);
begin
case ArFaces[ArIndex].FIndexFormat of
SGMeshIndexFormat1b: 
	begin
	ArFacesLines1b(ArIndex)[Index].p[0]:=p0;
	ArFacesLines1b(ArIndex)[Index].p[1]:=p1;
	end;
SGMeshIndexFormat2b: 
	begin
	ArFacesLines2b(ArIndex)[Index].p[0]:=p0;
	ArFacesLines2b(ArIndex)[Index].p[1]:=p1;
	end;
SGMeshIndexFormat4b: 
	begin
	ArFacesLines4b(ArIndex)[Index].p[0]:=p0;
	ArFacesLines4b(ArIndex)[Index].p[1]:=p1;
	end;
end;
end;

procedure TSG3DObject.SetFacePoint(const ArIndex:TSGLongWord;const Index :TSGMaxEnum; const p0:TSGLongWord);
begin
case ArFaces[ArIndex].FIndexFormat of
SGMeshIndexFormat1b:
	ArFacesPoints1b(ArIndex)[Index].p[0]:=p0;
SGMeshIndexFormat2b:
	ArFacesPoints2b(ArIndex)[Index].p[0]:=p0;
SGMeshIndexFormat4b:
	ArFacesPoints4b(ArIndex)[Index].p[0]:=p0;
end;
end;

procedure TSG3DObject.SetFaceArLength(const NewArLength : TSGLongWord);
var
	Index : TSGLongWord;
begin
if (FQuantityFaceArrays>=NewArLength) then
	Exit;
SetLength(ArFaces,NewArLength);
for Index := FQuantityFaceArrays to NewArLength - 1 do
	begin
	ArFaces[Index].FMaterialID:=-1;
	ArFaces[Index].FIndexFormat:=SGMeshIndexFormat2b;
	ArFaces[Index].FPoligonesType:=SGR_TRIANGLES;
	ArFaces[Index].FArray:=nil;
	ArFaces[Index].FNOfFaces:=0;
	end;
FQuantityFaceArrays := NewArLength;
end;

procedure TSG3DObject.AddFaceArray(const QuantityNewArrays : TSGLongWord = 1);
begin
SetFaceArLength(FQuantityFaceArrays+QuantityNewArrays);
end;

class function  TSG3DObject.GetFaceInt(const ThisFaceFormat : TSGMeshIndexFormat):Byte;inline;
begin
Result:=
	TSGByte(ThisFaceFormat=SGMeshIndexFormat1b)+
	TSGByte(ThisFaceFormat=SGMeshIndexFormat2b)*2+
	TSGByte(ThisFaceFormat=SGMeshIndexFormat4b)*4;
end;

function TSG3DObject.GetQuantityFaces(const Index : TSGLongWord):TSGQuadWord;inline;
begin
Result := ArFaces[Index].FNOfFaces;
end;

procedure TSG3DObject.SetHasTexture(const VHasTexture:TSGBoolean);inline;
begin
FHasTexture:=VHasTexture;
end;

function TSG3DObject.GetVertexLength():QWord;inline;
begin
Result:=FNOfVerts;
end;

procedure TSG3DObject.SetFaceQuad(const ArIndex:TSGLongWord;const Index :TSGMaxEnum; const p0,p1,p2,p3:TSGLongWord);
begin
if Render.RenderType<>SGRenderOpenGL then
	begin
	case ArFaces[ArIndex].FIndexFormat of
	SGMeshIndexFormat1b:
		begin
		ArFacesTriangles1b(ArIndex)[Index*2].p[0]:=p0;
		ArFacesTriangles1b(ArIndex)[Index*2].p[1]:=p1;
		ArFacesTriangles1b(ArIndex)[Index*2].p[2]:=p2;
		ArFacesTriangles1b(ArIndex)[Index*2+1].p[0]:=p2;
		ArFacesTriangles1b(ArIndex)[Index*2+1].p[1]:=p3;
		ArFacesTriangles1b(ArIndex)[Index*2+1].p[2]:=p0;
		end;
	SGMeshIndexFormat2b:
		begin
		ArFacesTriangles2b(ArIndex)[Index*2].p[0]:=p0;
		ArFacesTriangles2b(ArIndex)[Index*2].p[1]:=p1;
		ArFacesTriangles2b(ArIndex)[Index*2].p[2]:=p2;
		ArFacesTriangles2b(ArIndex)[Index*2+1].p[0]:=p2;
		ArFacesTriangles2b(ArIndex)[Index*2+1].p[1]:=p3;
		ArFacesTriangles2b(ArIndex)[Index*2+1].p[2]:=p0;
		end;
	SGMeshIndexFormat4b:
		begin
		ArFacesTriangles4b(ArIndex)[Index*2].p[0]:=p0;
		ArFacesTriangles4b(ArIndex)[Index*2].p[1]:=p1;
		ArFacesTriangles4b(ArIndex)[Index*2].p[2]:=p2;
		ArFacesTriangles4b(ArIndex)[Index*2+1].p[0]:=p2;
		ArFacesTriangles4b(ArIndex)[Index*2+1].p[1]:=p3;
		ArFacesTriangles4b(ArIndex)[Index*2+1].p[2]:=p0;
		end;
	end;
	end
else
	begin
	case ArFaces[ArIndex].FIndexFormat of
	SGMeshIndexFormat1b:
		begin
		ArFacesQuads1b(ArIndex)[Index].p[0]:=p0;
		ArFacesQuads1b(ArIndex)[Index].p[1]:=p1;
		ArFacesQuads1b(ArIndex)[Index].p[2]:=p2;
		ArFacesQuads1b(ArIndex)[Index].p[3]:=p3;
		end;
	SGMeshIndexFormat2b:
		begin
		ArFacesQuads2b(ArIndex)[Index].p[0]:=p0;
		ArFacesQuads2b(ArIndex)[Index].p[1]:=p1;
		ArFacesQuads2b(ArIndex)[Index].p[2]:=p2;
		ArFacesQuads2b(ArIndex)[Index].p[3]:=p3;
		end;
	SGMeshIndexFormat4b:
		begin
		ArFacesQuads4b(ArIndex)[Index].p[0]:=p0;
		ArFacesQuads4b(ArIndex)[Index].p[1]:=p1;
		ArFacesQuads4b(ArIndex)[Index].p[2]:=p2;
		ArFacesQuads4b(ArIndex)[Index].p[3]:=p3;
		end;
	end;
	end;
end;

procedure TSG3DObject.AddNormals();
var
	SecondArVertex:Pointer = nil;
	i,ii,iiii,iii:TSGMaxEnum;
	ArPoligonesNormals:packed array of TSGVertex3f = nil;
	Plane:SGPlane;
	Vertex:TSGVertex;
begin
if (FObjectPoligonesType<>SGR_TRIANGLES) then
	Exit;
if FQuantityFaceArrays<>0 then
	for i := 0 to FQuantityFaceArrays - 1 do
		if ArFaces[i].FPoligonesType<>SGR_TRIANGLES then
			Exit;
if not FHasNormals then
	begin
	ii:=GetSizeOfOneVertex();
	iii:=ii+3*SizeOf(Single);
	GetMem(SecondArVertex,iii*FNOfVerts);
	for i:=0 to FNOfVerts-1 do
		begin
		Move(
			PByte(ArVertex)[i*ii],
			PByte(SecondArVertex)[i*iii],
			GetSizeOfOneVertexCoord() + 
				GetSizeOfOneColorCoord());
		if FHasTexture then
			Move(
				PByte(ArVertex)[i*ii+
					GetSizeOfOneVertexCoord() + 
					GetSizeOfOneColorCoord()],
				PByte(SecondArVertex)[i*iii+
					GetSizeOfOneVertexCoord() + 
					GetSizeOfOneColorCoord() +
					3*SizeOf(TSGSingle)],
				GetSizeOfOneTextureCoord());
		end;
	
	FreeMem(ArVertex);
	ArVertex:=SecondArVertex;
	SecondArVertex:=nil;
	FHasNormals:=True;
	end;
SetLength(ArPoligonesNormals,QuantityFaces[0]);
for i:=0 to QuantityFaces[0]-1 do
	begin
	Plane:=SGGetPlaneFromThreeVertex(
		ArVertex3f[ArFacesTriangles(0,i).p[0]]^,
		ArVertex3f[ArFacesTriangles(0,i).p[1]]^,
		ArVertex3f[ArFacesTriangles(0,i).p[2]]^);
	ArPoligonesNormals[i].Import(
		Plane.a,Plane.b,Plane.c);
	end;
for i:=0 to QuantityVertexes-1 do
	begin
	Vertex.Import(0,0,0);
	for ii:=0 to QuantityFaces[0]-1 do
		begin
		iii:=0;
		for iiii:=0 to 2 do
			if ArFacesTriangles(0,ii).p[iiii]=i then
				begin
				iii:=1;
				Break;
				end;
		if iii=1 then
			Vertex+=ArPoligonesNormals[ii];
		end;
	Vertex.Normalize();
	ArNormal[i]^:=Vertex;
	end;
SetLength(ArPoligonesNormals,0);
end;

procedure TSG3DObject.AddFace(const ArIndex:TSGLongWord;const FQuantityNewFaces:LongWord = 1);
begin
SetFaceLength(ArIndex,QuantityFaces[ArIndex]+FQuantityNewFaces);
end;

procedure TSG3DObject.AddVertex(const FQuantityNewVertexes:LongWord = 1);
begin
FNOfVerts+=FQuantityNewVertexes;
ReAllocMem(ArVertex,GetVertexesSize());
end;

procedure TSG3DObject.ChangeMeshColorType4b(); // BGRA to RGBA
var
	i : TSGMaxEnum;
	c : byte;
begin
for i:=0 to Vertexes - 1 do
	begin
	c:=ArColor4b[i]^.r;
	ArColor4b[i]^.r:=ArColor4b[i]^.b;
	ArColor4b[i]^.b:=c;
	end;
end;

procedure TSG3DObject.AutoSetColorType(const VWithAlpha:Boolean = False);inline;
begin
if Render<>nil then
	begin
	if Render.RenderType=SGRenderOpenGL then
		begin
		if VWithAlpha then
			SetColorType(SGMeshColorType4f)
		else
			SetColorType(SGMeshColorType3f);
		end
	else
		begin
		SetColorType(SGMeshColorType4b);
		end;
	end;
end;

procedure TSG3DObject.SetColor(const Index:TSGMaxEnum;const r,g,b:Single; const a:Single = 1);inline;
begin
if (FColorType=SGMeshColorType3f) then
	begin
	ArColor3f[Index]^.r:=r;
	ArColor3f[Index]^.g:=g;
	ArColor3f[Index]^.b:=b;
	end
else if (FColorType=SGMeshColorType4f) then
	begin
	ArColor4f[Index]^.r:=r;
	ArColor4f[Index]^.g:=g;
	ArColor4f[Index]^.b:=b;
	ArColor4f[Index]^.a:=a;
	end
else if (FColorType=SGMeshColorType3b) then
	begin
	ArColor3b[Index]^.r:=Byte(r>=1)*255+Byte((r<1) and (r>0))*round(255*r);
	ArColor3b[Index]^.g:=Byte(g>=1)*255+Byte((g<1) and (g>0))*round(255*g);
	ArColor3b[Index]^.b:=Byte(b>=1)*255+Byte((b<1) and (b>0))*round(255*b);
	end
else if (FColorType=SGMeshColorType4b) then
	begin
	if Render.RenderType = SGRenderDirectX then
		begin
		ArColor4b[Index]^.r:=Byte(r>=1)*255+Byte((r<1) and (r>0))*round(255*r);
		ArColor4b[Index]^.b:=Byte(b>=1)*255+Byte((b<1) and (b>0))*round(255*b);
		end
	else
		begin
		ArColor4b[Index]^.b:=Byte(r>=1)*255+Byte((r<1) and (r>0))*round(255*r);
		ArColor4b[Index]^.r:=Byte(b>=1)*255+Byte((b<1) and (b>0))*round(255*b);
		end;
	ArColor4b[Index]^.g:=Byte(g>=1)*255+Byte((g<1) and (g>0))*round(255*g);
	ArColor4b[Index]^.a:=Byte(a>=1)*255+Byte((a<1) and (a>0))*round(255*a);
	end;
end;

function TSG3DObject.GetTexVertex3f(const Index : TSGMaxEnum): PTSGVertex3f;inline;
begin
Result:=PTSGVertex3f(
	TSGMaxEnum(ArVertex)
	+GetSizeOfOneVertex()*Index
	+GetSizeOfOneVertexCoord()
	+GetSizeOfOneColorCoord()
	+GetSizeOfOneNormalCoord());
end;

function TSG3DObject.GetTexVertex4f(const Index : TSGMaxEnum): PTSGVertex4f;inline;
begin
Result:=PTSGVertex4f(
	TSGMaxEnum(ArVertex)
	+GetSizeOfOneVertex()*Index
	+GetSizeOfOneVertexCoord()
	+GetSizeOfOneColorCoord()
	+GetSizeOfOneNormalCoord());
end;

function TSG3DObject.GetTexVertex(const Index : TSGMaxEnum): PTSGVertex2f;inline;
begin
Result:=PTSGVertex2f(
	TSGMaxEnum(ArVertex)
	+GetSizeOfOneVertex()*Index
	+GetSizeOfOneVertexCoord()
	+GetSizeOfOneColorCoord()
	+GetSizeOfOneNormalCoord());
end;

function TSG3DObject.GetNormal(const Index:TSGMaxEnum):PTSGVertex3f;inline;
begin
Result:=PTSGVertex3f( 
	TSGMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index
	+GetSizeOfOneVertexCoord()
	+GetSizeOfOneColorCoord());
end;

function TSG3DObject.GetColor4f(const Index:TSGMaxEnum):PTSGColor4f;inline;
begin
Result:=PTSGColor4f( 
	TSGMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	GetSizeOfOneVertexCoord());
end;

function TSG3DObject.GetColor3b(const Index:TSGMaxEnum):PTSGColor3b;inline;
begin
Result:=PTSGColor3b( 
	TSGMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	GetSizeOfOneVertexCoord());
end;

function TSG3DObject.GetColor4b(const Index:TSGMaxEnum):PTSGColor4b;inline;
begin
Result:=PTSGColor4b(Pointer(
	TSGMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	GetSizeOfOneVertexCoord()));
end;

function TSG3DObject.GetColor3f(const Index:TSGMaxEnum):PTSGColor3f;inline;
begin
Result:=PTSGColor3f( 
	TSGMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	GetSizeOfOneVertexCoord());
end;

function TSG3DObject.GetArFaces(const Index : LongWord = 0):Pointer;inline;
begin
if ArFaces=nil then
	Result:=nil
else
	Result:=@ArFaces[Index].FArray;
end;

function TSG3DObject.GetArVertexes():Pointer;inline;
begin
Result:=ArVertex;
end;

procedure TSG3DObject.SetVertexType(const VNewVertexType:TSGMeshVertexType);
begin
FVertexType:=VNewVertexType;
end;

procedure TSG3DObject.SetColorType(const VNewColorType:TSGMeshColorType);
begin
FHasColors:=True;
FColorType:=VNewColorType;
end;

procedure TSG3DObject.SetVertexLength(const NewVertexLength:QWord);inline;
begin
FNOfVerts:=NewVertexLength;
if ArVertex = nil then
	GetMem(ArVertex,GetVertexesSize())
else
	ReallocMem(ArVertex,GetVertexesSize());
end;

function TSG3DObject.GetCountOfOneTextureCoord():TSGLongWord;inline;
begin
Result := Byte(FHasTexture)*FCountTextureFloatsInVertexArray;
end;

function TSG3DObject.GetCountOfOneVertexCoord():TSGLongWord;inline;
begin
Result := (2 + Byte(FVertexType=SGMeshVertexType3f) + 2 * Byte(FVertexType = SGMeshVertexType4f));
end;

function TSG3DObject.GetCountOfOneColorCoord():TSGLongWord;inline;
begin
Result := Byte(FHasColors)*(3+byte((FColorType=SGMeshColorType4b) xor (FColorType=SGMeshColorType4f)));
end;

function TSG3DObject.GetCountOfOneNormalCoord():TSGLongWord;inline;
begin
Result := Byte(FHasNormals)*3;
end;

function TSG3DObject.GetSizeOfOneTextureCoord():TSGLongWord;inline;
begin
Result := GetCountOfOneTextureCoord()*SizeOf(Single);
end;

function TSG3DObject.GetSizeOfOneVertexCoord():TSGLongWord;inline;
begin
Result := GetCountOfOneVertexCoord()*SizeOf(Single);
end;

function TSG3DObject.GetSizeOfOneColorCoord():TSGLongWord;inline;
begin
Result := GetCountOfOneColorCoord() * (1 + byte((FColorType=SGMeshColorType3f) xor (FColorType=SGMeshColorType4f))*(SizeOf(TSGSingle)-1));
end;

function TSG3DObject.GetSizeOfOneNormalCoord():TSGLongWord;inline;
begin
Result := GetCountOfOneNormalCoord()*SizeOf(Single);
end;

function TSG3DObject.GetSizeOfOneVertex():LongWord;
begin
Result:= GetSizeOfOneVertexCoord() +
	GetSizeOfOneColorCoord() +
	GetSizeOfOneNormalCoord() +
	GetSizeOfOneTextureCoord();
end;

function TSG3DObject.GetVertexesSize():TSGMaxEnum;overload;inline;
begin
Result:=FNOfVerts*GetSizeOfOneVertex();
end;

function TSG3DObject.GetVertex3f(const Index:TSGMaxEnum):PTSGVertex3f;inline;
begin
Result:=PTSGVertex3f(TSGMaxEnum(ArVertex)+Index*(GetSizeOfOneVertex()));
end;

function TSG3DObject.GetVertex4f(const Index : TSGMaxEnum):PTSGVertex4f;inline;
begin
Result:=PTSGVertex4f(TSGMaxEnum(ArVertex)+Index*(GetSizeOfOneVertex()));
end;

function TSG3DObject.GetVertex2f(const Index:TSGMaxEnum):PTSGVertex2f;inline;
begin
Result:=PTSGVertex2f(TSGMaxEnum(ArVertex)+Index*(GetSizeOfOneVertex()));
end;

procedure TSG3DObject.LoadFromFile(const FileWay:string);
begin
(**)
end;

class function TSG3DObject.GetFaceLength(const FaceLength:TSGQuadWord; const ThisPoligoneType:LongWord):TSGQuadWord;overload;inline;
begin
Result:=FaceLength*GetPoligoneInt(ThisPoligoneType);
end;

class function TSG3DObject.ClassName:string;
begin
Result:='TSG3dObject';
end;

procedure TSG3DObject.WriteInfo(const PredStr:string = '');
var
	Index : TSGLongWord;
begin
TextColor(7);
WriteLn('TSG3DObject__WriteInfo()');
WriteLn(PredStr,'NOfVerts            = "',FNOfVerts,'"');
WriteLn(PredStr,'HasColors           = "',FHasColors,'"');
WriteLn(PredStr,'HasNormals          = "',FHasNormals,'"');
WriteLn(PredStr,'HasTexture          = "',FHasTexture,'"');
if FQuantityFaceArrays>0 then TextColor(10) else TextColor(12);
WriteLn(PredStr,'QuantityFaceArrays  = "',FQuantityFaceArrays,'"');
TextColor(7);
if FQuantityFaceArrays<>0 then
	for Index:=0 to FQuantityFaceArrays-1 do
		begin
		WriteLn(PredStr,'  ',Index+1,')','Index           = "',Index,'"');
		WriteLn(PredStr,'  ',Index+1,')','NOfFaces        = "',ArFaces[Index].FNOfFaces,'"');
		WriteLn(PredStr,'  ',Index+1,')','RealFaceLength  = "',GetFaceLength(Index),'"');
		WriteLn(PredStr,'  ',Index+1,')','MaterialID      = "',ArFaces[Index].FMaterialID,'"');
		case ArFaces[Index].FIndexFormat of
		SGMeshIndexFormat1b: WriteLn(PredStr,'  ',Index+1,')','IndexFormat     = "SGMeshIndexFormat1b"');
		SGMeshIndexFormat2b: WriteLn(PredStr,'  ',Index+1,')','IndexFormat     = "SGMeshIndexFormat2b"');
		SGMeshIndexFormat4b: WriteLn(PredStr,'  ',Index+1,')','IndexFormat     = "SGMeshIndexFormat4b"');
		end;
		Write(PredStr,'  ',Index+1,')','PoligonesType   = ');
		case ArFaces[Index].FPoligonesType of
		SGR_LINES:WriteLn('"SGR_LINES"');
		SGR_TRIANGLES:WriteLn('"SGR_TRIANGLES"');
		SGR_QUADS:WriteLn('"SGR_QUADS"');
		SGR_POINTS:WriteLn('"SGR_POINTS"');
		SGR_LINE_STRIP:WriteLn('"SGR_LINE_STRIP"');
		SGR_LINE_LOOP:WriteLn('"SGR_LINE_LOOP"');
		else WriteLn('"SGR_INVALID"');
		end;
		TextColor(15);
		WriteLn(PredStr,'  ',Index+1,')','FacesSize       = "',SGGetSizeString(GetFaceInt(ArFaces[Index].FIndexFormat)*GetFaceLength(Index),'EN'),'"');
		TextColor(7);
		end;
Write(PredStr,'ObjectPoligonesType = ');
case FObjectPoligonesType of
SGR_LINES:WriteLn('"SGR_LINES"');
SGR_TRIANGLES:WriteLn('"SGR_TRIANGLES"');
SGR_QUADS:WriteLn('"SGR_QUADS"');
SGR_POINTS:WriteLn('"SGR_POINTS"');
SGR_LINE_STRIP:WriteLn('"SGR_LINE_STRIP"');
SGR_LINE_LOOP:WriteLn('"SGR_LINE_LOOP"');
else WriteLn('"SGR_INVALID"');
end;
WriteLn(PredStr,'GetSizeOfOneVertex  = "',GetSizeOfOneVertex(),'"');
Write(PredStr,'FVertexFormat       = ');
if FVertexType = SGMeshVertexType2f then
	WriteLn('"SGMeshVertexType2f"')
else if FVertexType = SGMeshVertexType3f then
	WriteLn('"SGMeshVertexType3f"')
else if FVertexType = SGMeshVertexType4f then
	WriteLn('"SGMeshVertexType4f"')
else
	WriteLn('Unknown! "',TSGMaxEnum(FVertexType),'"');
WriteLn(PredStr,'FCountTextureFloatsInVertexArray = "',FCountTextureFloatsInVertexArray,'"');
Write(PredStr,'FColorType          = ');
case FColorType of
SGMeshColorType3b:WriteLn('"SGMeshColorType3b"');
SGMeshColorType4b:WriteLn('"SGMeshColorType4b"');
SGMeshColorType3f:WriteLn('"SGMeshColorType3f"');
SGMeshColorType4f:WriteLn('"SGMeshColorType4f"');
end;
TextColor(15);
WriteLn(PredStr,'VertexesSize        = "',SGGetSizeString(VertexesSize(),'EN'),'"');
if FQuantityFaceArrays>0 then
	WriteLn(PredStr,'AllSize             = "',SGGetSizeString(Size(),'EN'),'"');
TextColor(7);
WriteLn(PredStr,'EnableVBO           = "',FEnableVBO,'"');
Write(PredStr,  'LinksVBO            = "',FVertexesBuffer,'", (');
if FFacesBuffers <> nil then
	for Index := 0 to High(FFacesBuffers) do
		begin
		Write(FFacesBuffers[Index]);
		if Index <> High(FFacesBuffers) then
			Write(',');
		end;
WriteLn(')');
WriteLn(PredStr,'ObjectMaterialID    = "',FObjectMaterialID,'"');
WriteLn(PredStr,'Name                = "',FName,'"');
TextColor(7);
end;

function TSG3DObject.VertexesSize():TSGQuadWord;Inline;
begin
Result:=GetSizeOfOneVertex()*FNOfVerts;
end;

function TSG3DObject.FacesSize():TSGQuadWord;inline;
var
	Index : TSGLongWord;
begin
Result:=0;
if FQuantityFaceArrays<>0 then
	for Index := 0 to FQuantityFaceArrays-1 do
		Result += GetFaceInt(ArFaces[Index].FIndexFormat)*GetFaceLength(Index);
end;

function TSG3DObject.Size():QWord;inline;
begin
Result:=
	FacesSize()+
	VertexesSize();
end;

class function TSG3DObject.GetPoligoneInt(const ThisPoligoneType:LongWord):Byte;inline;
begin
Result:=
	Byte(
		(ThisPoligoneType=SGR_POINTS) or
		(ThisPoligoneType=SGR_TRIANGLE_STRIP) or
		(ThisPoligoneType=SGR_LINE_LOOP) or
		(ThisPoligoneType=SGR_LINE_STRIP))
	+4*Byte( ThisPoligoneType = SGR_QUADS )
	+3*Byte( ThisPoligoneType = SGR_TRIANGLES )
	+2*Byte( ThisPoligoneType = SGR_LINES );
end;

function TSG3DObject.GetFaceLength(const Index : TSGLongWord):TSGQuadWord;overload;inline;
begin
Result:=GetFaceLength(ArFaces[Index].FNOfFaces,ArFaces[Index].FPoligonesType);
end;

procedure TSG3DObject.SetFaceLength(const ArIndex:TSGLongWord;const NewLength:TSGQuadWord);inline;
begin
if (ArFaces[ArIndex].FNOfFaces=0) or (ArFaces[ArIndex].FArray=nil) then
	GetMem(ArFaces[ArIndex].FArray,
		GetPoligoneInt(ArFaces[ArIndex].FPoligonesType)*GetFaceInt(ArFaces[ArIndex].FIndexFormat)*(NewLength))
else
	ReAllocMem(ArFaces[ArIndex].FArray,
		GetPoligoneInt(ArFaces[ArIndex].FPoligonesType)*GetFaceInt(ArFaces[ArIndex].FIndexFormat)*(NewLength));
ArFaces[ArIndex].FNOfFaces:=NewLength;
end;

function TSG3DObject.ArFacesLines1b(const Index:TSGLongWord = 0)     : PTSGFaceLine1b;     inline;
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceLine1b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesQuads1b(const Index:TSGLongWord = 0)     : PTSGFaceQuad1b;     inline;
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceQuad1b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesTriangles1b(const Index:TSGLongWord = 0) : PTSGFaceTriangle1b; inline;
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceTriangle1b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesPoints1b(const Index:TSGLongWord = 0)    : PTSGFacePoint1b;    inline;
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFacePoint1b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesLines2b(const Index:TSGLongWord = 0)     : PTSGFaceLine2b;     inline;
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceLine2b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesQuads2b(const Index:TSGLongWord = 0)     : PTSGFaceQuad2b;     inline;
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceQuad2b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesTriangles2b(const Index:TSGLongWord = 0) : PTSGFaceTriangle2b; inline;
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceTriangle2b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesPoints2b(const Index:TSGLongWord = 0)    : PTSGFacePoint2b;    inline;
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFacePoint2b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesLines4b(const Index:TSGLongWord = 0)     : PTSGFaceLine4b;     inline;
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceLine4b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesQuads4b(const Index:TSGLongWord = 0)     : PTSGFaceQuad4b;     inline;
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceQuad4b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesTriangles4b(const Index:TSGLongWord = 0) : PTSGFaceTriangle4b; inline;
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceTriangle4b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesPoints4b(const Index:TSGLongWord = 0)    : PTSGFacePoint4b;    inline;
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFacePoint4b(TSGPointer(ArFaces[Index].FArray));
end;


constructor TSG3dObject.Create();
begin
inherited Create();
FEnableCullFaceFront := True;
FEnableCullFaceBack  := True;
FCountTextureFloatsInVertexArray := 2;
FBumpFormat := SGMeshBumpTypeNone;
FName:='';
FEnableCullFace := False;
FObjectColor.Import(1, 1, 1, 1);
FHasTexture := False;
FHasNormals := False;
FHasColors  := False;
FQuantityFaceArrays := 0;
FNOfVerts := 0;
ArVertex := nil;
ArFaces := nil;
FObjectMaterialID := -1;
FObjectPoligonesType:=SGR_TRIANGLES;
FColorType:=SGMeshColorType3b;
FVertexType:=SGMeshVertexType3f;
FEnableVBO:=False;
FVertexesBuffer := 0;
FFacesBuffers := nil;
FEnableObjectMatrix := False;
FObjectMatrix := SGGetIdentityMatrix();
end;

procedure TSG3dObject.SetMatrix(const m : TSGMatrix4);
begin
FEnableObjectMatrix := m <> SGGetIdentityMatrix();
FObjectMatrix := m;
end;

destructor TSG3dObject.Destroy();
begin
ClearArrays();
ClearVBO();
inherited Destroy();
end;

procedure TSG3dObject.Draw(); inline;
begin
{$IFDEF SGMoreDebuging}
	WriteLn('Call "TSG3dObject.Draw" : "'+ClassName+'" is sucsesfull');
	{$ENDIF}
if FEnableObjectMatrix then
	begin
	Render.PushMatrix();
	Render.MultMatrixf(@FObjectMatrix);
	end;
if FEnableCullFace then
	begin
	if (FEnableCullFaceBack or FEnableCullFaceFront) then
		begin
		Render.Enable(SGR_CULL_FACE);
		if FEnableCullFaceBack then
			begin
			Render.CullFace(SGR_BACK);
			BasicDraw;
			end;
		if FEnableCullFaceFront then
			begin
			Render.CullFace(SGR_FRONT);
			BasicDraw();
			end;
		Render.Disable(SGR_CULL_FACE);
		end
	else
		begin
		{$IFDEF SGDebuging}
			WriteLn('"TSG3dObject.Draw" : "'+ClassName+'" - CullFace enabled, but Front and Back node disabled...');
			{$ENDIF}
		end;
	end
else
	BasicDraw();
if FEnableObjectMatrix then
	Render.PopMatrix();
end;

procedure TSG3DObject.ClearArrays(const ClearN:boolean = True);
var
	Index : TSGLongWord;
begin
if ArVertex<>nil then
	begin
	FreeMem(ArVertex);
	ArVertex:=nil;
	end;
if ArFaces<>nil then
	begin 
	if (ArFaces<>nil) and (Length(ArFaces)<>0) then
		for Index := 0 to High(ArFaces) do
			if (ArFaces[Index].FArray<>nil) then
				begin
				FreeMem(ArFaces[Index].FArray);
				ArFaces[Index].FArray:=nil;
				end;
	end;
if ClearN then
	begin
	FNOfVerts:=0;
	if (ArFaces<>nil) and (Length(ArFaces)<>0) then
		for Index := 0 to High(ArFaces) do
			ArFaces[Index].FNOfFaces:=0;
	end;
end;

procedure TSG3DObject.SaveToSG3DOFile(const FileWay:TSGString);
var
	Stream:TStream = nil;
begin
Stream:=TFileStream.Create(FileWay,fmCreate);
if Stream<>nil then
	begin
	SaveToSG3DO(Stream);
	Stream.Destroy();
	end;
end;

procedure TSG3DObject.LoadFromSG3DOFile(const FileWay:TSGString);
var
	Stream:TStream = nil;
begin
if SGFileExists(FileWay) then
	begin
	Stream:=TFileStream.Create(FileWay,fmOpenRead);
	if Stream<>nil then
		begin
		LoadFromSG3DO(Stream);
		Stream.Destroy();
		end;
	end;
end;

procedure TSG3DObject.SaveToSG3DO(const Stream:TStream);
var
	S:array[0..8] of TSGChar = 'SaGe3DObj';
	i : TSGLongWord;
begin
Stream.WriteBuffer(S[0],SizeOf(S[0])*9);
Stream.WriteBuffer(SGMeshVersion,SizeOf(SGMeshVersion));

Stream.WriteBuffer(FHasTexture,SizeOf(FHasTexture));
Stream.WriteBuffer(FHasColors,SizeOf(FHasColors));
Stream.WriteBuffer(FHasNormals,SizeOf(FHasNormals));
Stream.WriteBuffer(FQuantityFaceArrays,SizeOf(FQuantityFaceArrays));
Stream.WriteBuffer(FObjectPoligonesType,SizeOf(FObjectPoligonesType));
Stream.WriteBuffer(FVertexType,SizeOf(FVertexType));
Stream.WriteBuffer(FColorType,SizeOf(FColorType));
Stream.WriteBuffer(FObjectMaterialID,SizeOf(FObjectMaterialID));
Stream.WriteBuffer(FEnableCullFace,SizeOf(FEnableCullFace));
SGWriteStringToStream(FName,Stream);

Stream.WriteBuffer(FNOfVerts,SizeOf(FNOfVerts));
Stream.WriteBuffer(FQuantityFaceArrays,SizeOf(FQuantityFaceArrays));

if FQuantityFaceArrays<>0 then
	for i:=0 to FQuantityFaceArrays-1 do
		begin
		Stream.WriteBuffer(ArFaces[i].FPoligonesType,SizeOf(ArFaces[i].FPoligonesType));
		Stream.WriteBuffer(ArFaces[i].FIndexFormat,SizeOf(ArFaces[i].FIndexFormat));
		Stream.WriteBuffer(ArFaces[i].FNOfFaces,SizeOf(ArFaces[i].FNOfFaces));
		Stream.WriteBuffer(ArFaces[i].FMaterialID,SizeOf(ArFaces[i].FMaterialID));
		Stream.WriteBuffer(ArFaces[i].FArray^,GetFaceLength(i)*GetFaceInt(ArFaces[i].FIndexFormat));
		end;

Stream.WriteBuffer(ArVertex^,VertexesSize());
end;

procedure TSG3DObject.LoadFromSG3DO(const Stream:TStream);
var
	S,S2:array[0..8] of TSGChar;
	Version : TSGQuadWord = 0;
	i : TSGLongWord;
begin
S2:='SaGe3DObj';
Stream.ReadBuffer(S[0],SizeOf(S[0])*9);
if S<>S2 then
	begin
	SGLog.Sourse(['TSG3DObject.LoadFromSG3DO : Fatal : It is not "SaGe3DObj" file!']);
	Exit;
	end;
Stream.ReadBuffer(Version,SizeOf(Version));
if Version <> SGMeshVersion then
	begin
	SGLog.Sourse(['TSG3DObject.LoadFromSG3DO : Fatal : (Program.MeshVersion!=Mesh.MeshVersion)!']);
	Exit;
	end;
Stream.ReadBuffer(FHasTexture,SizeOf(FHasTexture));
Stream.ReadBuffer(FHasColors,SizeOf(FHasColors));
Stream.ReadBuffer(FHasNormals,SizeOf(FHasNormals));
Stream.ReadBuffer(FQuantityFaceArrays,SizeOf(FQuantityFaceArrays));
Stream.ReadBuffer(FObjectPoligonesType,SizeOf(FObjectPoligonesType));
Stream.ReadBuffer(FVertexType,SizeOf(FVertexType));
Stream.ReadBuffer(FColorType,SizeOf(FColorType));
Stream.ReadBuffer(FObjectMaterialID,SizeOf(FObjectMaterialID));
Stream.ReadBuffer(FEnableCullFace,SizeOf(FEnableCullFace));
FName := SGReadStringFromStream(Stream);

Stream.ReadBuffer(FNOfVerts,SizeOf(FNOfVerts));
Stream.ReadBuffer(FQuantityFaceArrays,SizeOf(FQuantityFaceArrays));

SetVertexLength(FNOfVerts);

if FQuantityFaceArrays<>0 then
	for i:=0 to FQuantityFaceArrays-1 do
		begin
		Stream.ReadBuffer(ArFaces[i].FPoligonesType,SizeOf(ArFaces[i].FPoligonesType));
		Stream.ReadBuffer(ArFaces[i].FIndexFormat,SizeOf(ArFaces[i].FIndexFormat));
		Stream.ReadBuffer(ArFaces[i].FNOfFaces,SizeOf(ArFaces[i].FNOfFaces));
		Stream.ReadBuffer(ArFaces[i].FMaterialID,SizeOf(ArFaces[i].FMaterialID));
		Stream.ReadBuffer(ArFaces[i].FArray^,GetFaceLength(i)*GetFaceInt(ArFaces[i].FIndexFormat));
		end;

Stream.ReadBuffer(ArVertex^,VertexesSize());
end;

procedure TSG3dObject.BasicDraw(); inline;
var
	Index : TSGLongWord;
begin
if (FObjectMaterialID=-1) and (FQuantityFaceArrays=0) then
	Render.ColorMaterial(FObjectColor.r,FObjectColor.g,FObjectColor.b,FObjectColor.a);

Render.EnableClientState(SGR_VERTEX_ARRAY);
if FHasNormals then
	Render.EnableClientState(SGR_NORMAL_ARRAY);
if FHasTexture then
	begin
	if FBumpFormat = SGMeshBumpTypeCopyTexture2f then
		Render.ClientActiveTexture(1);
	Render.EnableClientState(SGR_TEXTURE_COORD_ARRAY);
	if FBumpFormat = SGMeshBumpTypeCopyTexture2f then
		Render.ClientActiveTexture(0);
	end;
if (FBumpFormat = SGMeshBumpTypeCopyTexture2f) or (FBumpFormat = SGMeshBumpType2f) then
	begin
	Render.EnableClientState(SGR_TEXTURE_COORD_ARRAY);
	end;
if FHasColors then
	Render.EnableClientState(SGR_COLOR_ARRAY);

if FEnableVBO then
	begin
	Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,FVertexesBuffer);
	Render.VertexPointer(GetCountOfOneVertexCoord(),SGR_FLOAT,GetSizeOfOneVertex(),nil);
	
	if FHasColors then
		begin
		Render.ColorPointer(
			GetCountOfOneColorCoord(),
			SGR_FLOAT*Byte((FColorType = SGMeshColorType3f) or (FColorType = SGMeshColorType4f))+
				SGR_UNSIGNED_BYTE*Byte((FColorType = SGMeshColorType4b) or (FColorType = SGMeshColorType3b)),
			GetSizeOfOneVertex(),
			Pointer(GetSizeOfOneVertexCoord()));
		end;
	
	if FHasNormals then
		begin
		Render.NormalPointer(
			SGR_FLOAT,
			GetSizeOfOneVertex(),
			Pointer(
				GetSizeOfOneVertexCoord()+
				GetSizeOfOneColorCoord()));
		end;
	
	if FHasTexture then
		begin
		if FBumpFormat = SGMeshBumpTypeCopyTexture2f then
			Render.ClientActiveTexture(1);
		Render.TexCoordPointer(GetCountOfOneTextureCoord(), SGR_FLOAT, GetSizeOfOneVertex(),
			Pointer(
				GetSizeOfOneVertexCoord() +
				GetSizeOfOneColorCoord() +
				GetSizeOfOneNormalCoord()));
		if FBumpFormat = SGMeshBumpTypeCopyTexture2f then
			Render.ClientActiveTexture(0);
		end;
	
	if (FBumpFormat = SGMeshBumpTypeCopyTexture2f) or (FBumpFormat = SGMeshBumpType2f) then
		begin
		Render.TexCoordPointer(GetCountOfOneTextureCoord(), SGR_FLOAT, GetSizeOfOneVertex(),
			Pointer(
				GetSizeOfOneVertexCoord()+
				GetSizeOfOneColorCoord()+
				GetSizeOfOneNormalCoord()));
		end;
	
	if FQuantityFaceArrays<>0 then
		begin
		for Index := 0 to FQuantityFaceArrays-1 do
			begin
			if (FParent<>nil) then
				if (ArFaces[Index].FMaterialID <> -1) then
					FParent.Materials[ArFaces[Index].FMaterialID].Bind(Self)
				else if (FObjectMaterialID <> -1) then
					FParent.Materials[FObjectMaterialID].Bind(Self);
			Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB ,FFacesBuffers[Index]);
			Render.DrawElements(ArFaces[Index].FPoligonesType, GetFaceLength(Index) ,
				TSGByte(ArFaces[Index].FIndexFormat=SGMeshIndexFormat1b)*SGR_UNSIGNED_BYTE+
				TSGByte(ArFaces[Index].FIndexFormat=SGMeshIndexFormat2b)*SGR_UNSIGNED_SHORT+
				TSGByte(ArFaces[Index].FIndexFormat=SGMeshIndexFormat4b)*SGR_UNSIGNED_INT
				,nil);
			if (FParent<>nil) then
				if (ArFaces[Index].FMaterialID <> -1) then
					FParent.Materials[ArFaces[Index].FMaterialID].UnBind(Self)
				else if (FObjectMaterialID <> -1) then
					FParent.Materials[FObjectMaterialID].UnBind(Self);
			end;
		end
	else
		Render.DrawArrays(FObjectPoligonesType,0,FNOfVerts);
	
	Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,0);
	if FQuantityFaceArrays<>0 then
		Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB,0);
	end
else
	begin
    Render.VertexPointer(
		GetCountOfOneVertexCoord(),
		SGR_FLOAT, 
		GetSizeOfOneVertex(), 
		ArVertex);
    if FHasColors then
		Render.ColorPointer(
			GetCountOfOneColorCoord(),
			SGR_FLOAT*Byte((FColorType = SGMeshColorType3f) or (FColorType = SGMeshColorType4f))+
				SGR_UNSIGNED_BYTE*Byte((FColorType = SGMeshColorType4b) or (FColorType = SGMeshColorType3b)),
			GetSizeOfOneVertex(),
			Pointer(
				TSGMaxEnum(ArVertex)+
				GetSizeOfOneVertexCoord()));
	if FHasNormals then
		Render.NormalPointer(
			SGR_FLOAT, 
			GetSizeOfOneVertex(), 
			Pointer(
				TSGMaxEnum(ArVertex)+
				GetCountOfOneVertexCoord()+
				GetCountOfOneColorCoord()));
	
    if FHasTexture then
		begin
		if FBumpFormat = SGMeshBumpTypeCopyTexture2f then
			Render.ClientActiveTexture(1);
        Render.TexCoordPointer(
			GetCountOfOneTextureCoord(),
			SGR_FLOAT, 
			GetSizeOfOneVertex(), 
			Pointer(
				TSGMaxEnum(ArVertex)+
				GetCountOfOneVertexCoord()+
				GetCountOfOneColorCoord()+
				GetCountOfOneNormalCoord()));
		if FBumpFormat = SGMeshBumpTypeCopyTexture2f then
			Render.ClientActiveTexture(0);
		end;
	
	if (FBumpFormat = SGMeshBumpTypeCopyTexture2f) or (FBumpFormat = SGMeshBumpType2f) then
		begin
		Render.TexCoordPointer(
			GetCountOfOneTextureCoord(),
			SGR_FLOAT, 
			GetSizeOfOneVertex(), 
			Pointer(
				TSGMaxEnum(ArVertex)+
				GetCountOfOneVertexCoord()+
				GetCountOfOneColorCoord()+
				GetCountOfOneNormalCoord()));
		end;
	
	if FQuantityFaceArrays<>0 then
		for Index := 0 to FQuantityFaceArrays-1 do
			begin
			if (FParent<>nil) then
				if (ArFaces[Index].FMaterialID <> -1) then
					FParent.Materials[ArFaces[Index].FMaterialID].Bind(Self)
				else if (FObjectMaterialID <> -1) then
					FParent.Materials[FObjectMaterialID].Bind(Self);
			Render.DrawElements(ArFaces[Index].FPoligonesType, GetFaceLength(Index) , 
				TSGByte(ArFaces[Index].FIndexFormat=SGMeshIndexFormat1b)*SGR_UNSIGNED_BYTE+
				TSGByte(ArFaces[Index].FIndexFormat=SGMeshIndexFormat2b)*SGR_UNSIGNED_SHORT+
				TSGByte(ArFaces[Index].FIndexFormat=SGMeshIndexFormat4b)*SGR_UNSIGNED_INT, 
				ArFaces[Index].FArray);
			if (FParent<>nil) then
				if (ArFaces[Index].FMaterialID <> -1) then
					FParent.Materials[ArFaces[Index].FMaterialID].UnBind(Self)
				else if (FObjectMaterialID <> -1) then
					FParent.Materials[FObjectMaterialID].UnBind(Self);
			end
	else
		Render.DrawArrays(FObjectPoligonesType,0,FNOfVerts);
    end;
Render.DisableClientState(SGR_VERTEX_ARRAY);
if FHasNormals then
	Render.DisableClientState(SGR_NORMAL_ARRAY);
if FHasTexture then
	begin
	if FBumpFormat = SGMeshBumpTypeCopyTexture2f then
		Render.ClientActiveTexture(1);
	Render.DisableClientState(SGR_TEXTURE_COORD_ARRAY);
	if FBumpFormat = SGMeshBumpTypeCopyTexture2f then
		Render.ClientActiveTexture(0);
	end;
if (FBumpFormat = SGMeshBumpTypeCopyTexture2f) or (FBumpFormat = SGMeshBumpType2f) then
	begin
	Render.DisableClientState(SGR_TEXTURE_COORD_ARRAY);
	end;
if FHasColors then
	Render.DisableClientState(SGR_COLOR_ARRAY);

if (FObjectMaterialID=-1) and (FQuantityFaceArrays=0) then
	Render.ColorMaterial(1,1,1,1);
end;

procedure TSG3dObject.LoadToVBO();
var
	Index : TSGLongWord;
begin
if FEnableVBO then
	begin
	SGLog.Sourse('TSG3dObject__LoadToVBO : It is not possible to do this several counts!');
	Exit;
	end;
Render.GenBuffersARB(1, @FVertexesBuffer);
Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,FVertexesBuffer);
Render.BufferDataARB(SGR_ARRAY_BUFFER_ARB,FNOfVerts*GetSizeOfOneVertex(),ArVertex, SGR_STATIC_DRAW_ARB);
Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,0);

if FQuantityFaceArrays<>0 then
	begin
	SetLength(FFacesBuffers,FQuantityFaceArrays);
	for Index := 0 to FQuantityFaceArrays-1 do
		begin
		Render.GenBuffersARB(1, @FFacesBuffers[Index]);
		Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB,FFacesBuffers[Index]);
		Render.BufferDataARB(SGR_ELEMENT_ARRAY_BUFFER_ARB,
			GetFaceLength(Index)*GetFaceInt(ArFaces[Index].FIndexFormat),ArFaces[Index].FArray,
			SGR_STATIC_DRAW_ARB,
			TSGByte(ArFaces[Index].FIndexFormat=SGMeshIndexFormat1b)*SGR_UNSIGNED_BYTE+
			TSGByte(ArFaces[Index].FIndexFormat=SGMeshIndexFormat2b)*SGR_UNSIGNED_SHORT+
			TSGByte(ArFaces[Index].FIndexFormat=SGMeshIndexFormat4b)*SGR_UNSIGNED_INT);
		end;
	Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB,0);
	end;

ClearArrays(False);
FEnableVBO:=True;
end;

procedure TSG3DObject.ClearVBO();inline;
var
	Index : TSGLongWord;
begin
if FEnableVBO and (Render<>nil) then
	begin
	if FQuantityFaceArrays<>0 then
		for Index := 0 to FQuantityFaceArrays-1 do
			if FFacesBuffers[Index]<>0 then
				begin
				Render.DeleteBuffersARB(1,@FFacesBuffers[Index]);
				FFacesBuffers[Index]:=0;
				end;
	if FVertexesBuffer<>0 then
		Render.DeleteBuffersARB(1,@FVertexesBuffer);
	FVertexesBuffer:=0;
	FEnableVBO:=False;
	end;
end;

(************************************************************************************)
(************************************){TSGModel}(************************************)
(************************************************************************************)

procedure TSGCustomModel.LoadFromSG3DMFile(const FileWay: TSGString);
var
	Stream : TStream = nil;
begin
Stream := TFileStream.Create(FileWay,fmOpenRead);
if Stream<>nil then
	begin
	LoadFromSG3DM(Stream);
	Stream.Destroy();
	end;
end;

procedure TSGCustomModel.SaveToSG3DMFile(const FileWay: TSGString);
var
	Stream : TStream = nil;
begin
Stream := TFileStream.Create(FileWay,fmCreate);
if Stream<>nil then
	begin
	SaveToSG3DM(Stream);
	Stream.Destroy();
	end;
end;

procedure TSGCustomModel.LoadFromSG3DM(const Stream : TStream);
var
	i : TSGLongWord;
	QuantityO,QuantityM : TSGQuadWord;
begin
Stream.ReadBuffer(QuantityO,SizeOf(QuantityO));
Stream.ReadBuffer(QuantityM,SizeOf(QuantityM));
if QuantityO>0 then
	for i:=0 to QuantityO-1 do
		begin
		AddObject().Destroy();
		FArObjects[i].FMesh:=nil;
		Stream.ReadBuffer(FArObjects[i].FMatrix,SizeOf(FArObjects[i].FMatrix));
		Stream.ReadBuffer(FArObjects[i].FCopired,SizeOf(FArObjects[i].FCopired));
		if FArObjects[i].FCopired=-1 then
			begin
			FArObjects[i].FMesh:=TSG3DObject.Create();
			FArObjects[i].FMesh.Context := Context;
			FArObjects[i].FMesh.Parent := Self;
			Objects[i].LoadFromSG3DO(Stream);
			end;
		end;
if QuantityM>0 then
	for i:=0 to QuantityM-1 do
		begin
		AddMaterial().Name:=SGReadStringFromStream(Stream);
		LastMaterial().AddDiffuseMap(SGReadStringFromStream(Stream));
		end;
end;

procedure TSGCustomModel.SaveToSG3DM(const Stream : TStream);
var
	i : TSGLongWord;
begin
Stream.WriteBuffer(FQuantityObjects,SizeOf(FQuantityObjects));
Stream.WriteBuffer(FQuantityMaterials,SizeOf(FQuantityMaterials));
if FQuantityObjects>0 then
	for i:=0 to FQuantityObjects-1 do
		begin
		Stream.WriteBuffer(FArObjects[i].FMatrix,SizeOf(FArObjects[i].FMatrix));
		Stream.WriteBuffer(FArObjects[i].FCopired,SizeOf(FArObjects[i].FCopired));
		if FArObjects[i].FCopired=-1 then
			Objects[i].SaveToSG3DO(Stream);
		end;
if FQuantityMaterials>0 then
	for i:=0 to FQuantityMaterials-1 do
		begin
		SGWriteStringToStream(FArMaterials[i].MapDiffuseWay,Stream);
		SGWriteStringToStream(FArMaterials[i].Name,Stream);
		end;
end;

procedure TSGCustomModel.SaveToFile(const FileWay: string);
begin
SaveToSG3DMFile(FileWay);
end;

procedure TSGCustomModel.Clear();
var
	i : TSGLongWord;
begin
if FQuantityObjects>0 then
	begin
	for i:=0 to FQuantityObjects-1 do
		FArObjects[i].FMesh.Destroy();
	SetLength(FArObjects,0);
	FQuantityObjects:=0;
	end;
FArObjects:=nil;
if FQuantityMaterials>0 then
	begin
	for i:=0 to FQuantityMaterials-1 do
		FArMaterials[i].Destroy;
	SetLength(FArMaterials,0);
	FQuantityMaterials:=0;
	end;
FArMaterials:=nil;
end;

procedure TSGCustomModel.LoadToVBO();
var	
	i : TSGLongWord;
begin
for i:=0 to FQuantityObjects-1 do
	begin
	FArObjects[i].FMesh.LoadToVBO();
	end;
end;

procedure TSGCustomModel.LoadFromFile(const FileWay:string);
begin
if SGFileExists(FileWay) then
	begin
		if SGUpCaseString(SGGetFileExpansion(FileWay))='3DS' then
			begin
			Load3DSFromFile(FileWay);
			end
		else
			if SGUpCaseString(SGGetFileExpansion(FileWay))='OBJ' then
				begin
				AddObject().LoadFromOBJ(FileWay);
				end
			else
				begin
				LoadFromSG3DMFile(FileWay);
				end;
	end;
end;

class function TSGCustomModel.ClassName():String;
begin
Result:='TSGCustomModel';
end;

procedure TSGCustomModel.WriteInfo();
var
	i : TSGLongWord;
begin
TextColor(7);
WriteLn('TSGCustomModel__WriteInfo()');
WriteLn('  QuantityMaterials = ',FQuantityMaterials);
WriteLn('  QuantityObjects   = ',FQuantityObjects);
if FQuantityMaterials<>0 then
	for i:=0 to FQuantityMaterials-1 do
		;//FArMaterials[i].WriteInfo('  '+SGStr(i+1)+')');
if FQuantityObjects <> 0 then
	for i:=0 to FQuantityObjects-1 do
		FArObjects[i].FMesh.WriteInfo('  '+SGStr(i+1)+') ');
end;


procedure TSGCustomModel.Stripificate();
var
	i : TSGLongWord;
begin
for i:=0 to FQuantityObjects-1 do
	;//ArObjects[i].Stripificate;
end;

function TSGCustomModel.VertexesSize():QWord;Inline;
var
	i : TSGLongWord;
begin
Result:=0;
for i:=0 to FQuantityObjects-1 do
	Result+=FArObjects[i].FMesh.VertexesSize();
end;

function TSGCustomModel.FacesSize():TSGQuadWord;inline;
var
	i : TSGLongWord;
begin
Result:=0;
if FQuantityObjects<>0 then
	for i:=0 to FQuantityObjects-1 do
		Result+=Objects[i].FacesSize();
end;

function TSGCustomModel.Size():QWord;inline;
var
	i : TSGLongWord;
begin
Result:=0;
for i:=0 to FQuantityObjects-1 do
	Result+=FArObjects[i].FMesh.Size();
end;


procedure TSGCustomModel.AddObjectColor(const ObjColor: TSGColor4f);
var
    i: TSGLongWord;
begin
    for i := 0 to High(FArObjects) do
        FArObjects[i].FMesh.FObjectColor := ObjColor;
end;

function TSGCustomModel.Load3DSFromStream(const VStream:TStream;const VFileName:TSGString):TSGBoolean;
begin
TSGLoad3DS.Create().SetStream(VStream).SetFileName(VFileName).Import3DS(Self,Result).Destroy();
end;

function TSGCustomModel.Load3DSFromFile(const FileWay:TSGString):TSGBoolean;
begin
TSGLoad3DS.Create().SetFileName(FileWay).Import3DS(Self,Result).Destroy();
end;

constructor TSGCustomModel.Create();
begin
inherited;
FQuantityMaterials := 0;
FQuantityObjects := 0;
FArMaterials := nil;
FArObjects := nil;
end;

destructor TSGCustomModel.Destroy();
var
    i: TSGLongWord;
begin
Clear();
inherited;
end;

procedure TSGCustomModel.DrawObject(const Index : TSGLongWord);
var
    CurrentMesh : TSG3DObject;
begin
CurrentMesh:=FArObjects[Index].FMesh;
if (CurrentMesh<>nil) or (FArObjects[Index].FCopired<>-1) then
	begin
	if FArObjects[Index].FCopired<>-1 then
		CurrentMesh := FArObjects[FArObjects[Index].FCopired].FMesh;
	Render.PushMatrix();
	Render.MultMatrixf(@FArObjects[Index].FMatrix);
	CurrentMesh.Draw();
	Render.PopMatrix();
	end;
end;

procedure TSGCustomModel.Draw();
var
    i: TSGLongWord;
begin
if FQuantityObjects<>0 then
	for i := 0 to FQuantityObjects - 1 do
		DrawObject(i);
end;

function TSGCustomModel.AddMaterial():TSGMaterial;inline;
begin
FQuantityMaterials+=1;
SetLength(FArMaterials,FQuantityMaterials);
FArMaterials[FQuantityMaterials-1]:=TSGMaterial.Create(Context);
Result:=FArMaterials[FQuantityMaterials-1];
end;

function TSGCustomModel.LastMaterial():TSGMaterial;inline;
begin
if (FArMaterials=nil) or (FQuantityMaterials=0) then
	Result:=nil
else
	Result:=FArMaterials[FQuantityMaterials-1];
end;

function TSGCustomModel.AddObject():TSG3DObject;inline;
begin
FQuantityObjects+=1;
SetLength(FArObjects,FQuantityObjects);
Result:=TSG3DObject.Create();
Result.Context := Context;
Result.Parent := Self;
FArObjects[FQuantityObjects-1].FMesh:=Result;
FArObjects[FQuantityObjects-1].FCopired:=-1;
FArObjects[FQuantityObjects-1].FMatrix:=SGGetIdentityMatrix();
end;

function TSGCustomModel.LastObject():TSG3DObject;inline;
begin
if (FQuantityObjects=0) or(FArObjects=nil) then
	Result:=nil
else
	Result:=FArObjects[FQuantityObjects-1].FMesh;
end;

function TSGCustomModel.CreateMaterialIDInLastObject(const VMaterialName : TSGString):TSGBoolean;
var
	i : TSGLongWord;
begin
Result:=False;
for i := 0 to FQuantityMaterials - 1 do
	if FArMaterials[i].Name = VMaterialName then
		begin
		LastObject().ObjectMaterialID := i;
		LastObject().HasTexture := True;
		Result:=True;
		Break;
		end;
end;

function TSGCustomModel.GetMaterial(const Index : TSGMaxEnum):TSGMaterial;
begin
Result:=FArMaterials[Index];
end;

function TSGCustomModel.GetObject(const Index : TSGMaxEnum):TSG3dObject;
function FindIndex(const NowIndex : TSGLongWord):TSGLongWord;
begin
if FArObjects[NowIndex].FCopired<>-1 then
	Result:=FindIndex(FArObjects[NowIndex].FCopired)
else
	Result:=NowIndex;
end;
begin
Result:=FArObjects[FindIndex(Index)].FMesh;
end;

procedure TSGCustomModel.Dublicate(const Index:TSGLongWord);
function FindIndex(const NowIndex : TSGLongWord):TSGLongWord;
begin
if FArObjects[NowIndex].FCopired<>-1 then
	Result:=FindIndex(FArObjects[NowIndex].FCopired)
else
	Result:=NowIndex;
end;
begin
FQuantityObjects+=1;
SetLength(FArObjects,FQuantityObjects);
FArObjects[FQuantityObjects-1].FMesh:=nil;
FArObjects[FQuantityObjects-1].FCopired:=FindIndex(Index);
FArObjects[FQuantityObjects-1].FMatrix:=FArObjects[Index].FMatrix;
end;

procedure TSGCustomModel.Translate(const Index:TSGLongWord;const Vertex : TSGVertex3f);
begin
FArObjects[Index].FMatrix:= FArObjects[Index].FMatrix * SGGetTranslateMatrix(Vertex);
end;

function TSGCustomModel.GetObjectMatrix(const Index : TSGMaxEnum):TSGPointer;
begin
Result:=@FArObjects[Index].FMatrix;
end;

(************************************************************************************)
(*********************************){TSGMaterial}(************************************)
(************************************************************************************)

constructor TSGMaterial.Create(const VContext : TSGContext);
begin
inherited Create(VContext);
FColorAmbient.Import(0,0,0,0);
FColorDiffuse.Import(0,0,0,0);
FColorSpecular.Import(0,0,0,0);
FEnableBump:=False;
FEnableTexture:=False;
FNS:=0;
FIllum:=0;
FName:='';
FMapAmbient:=nil;
FMapBump:=nil;
FMapDiffuse:=nil;
FMapOpacity:=nil;
FMapSpecular:=nil;
end;

destructor TSGMaterial.Destroy();
begin
inherited;
end;

procedure TSGMaterial.AddDiffuseMap(const VFileName : TSGString);
begin
FMapDiffuse:=TSGImage.Create();
FMapDiffuse.Context := Context;
FMapDiffuse.Way := VFileName;
FEnableTexture := FMapDiffuse.Loading();
end;

procedure TSGMaterial.AddBumpMap(const VFileName : TSGString);
begin
FMapBump:=TSGImage.Create();
FMapBump.Context := Context;
FMapBump.Way := VFileName;
FEnableBump := FMapBump.Loading();
end;

procedure TSGMaterial.Bind(const VObject : TSG3DObject);
begin
if (VObject.BumpFormat = SGMeshBumpTypeNone) and (VObject.HasTexture) then
	begin
	if FEnableTexture and (FMapDiffuse<>nil) then
		begin
		FMapDiffuse.TextureNumber := -1;
		FMapDiffuse.TextureType := SGITextureTypeTexture;
		FMapDiffuse.BindTexture();
		end;
	end
else if (VObject.BumpFormat = SGMeshBumpTypeCopyTexture2f) and (VObject.HasTexture) then
	begin
	if FEnableBump and (FMapBump<>nil) then
		begin
		FMapBump.TextureNumber := 0;
		FMapBump.TextureType := SGITextureTypeBump;
		FMapBump.BindTexture();
		FMapBump.TextureNumber := -1;
		FMapBump.TextureType := SGITextureTypeTexture;
		end;
	if FEnableTexture and (FMapDiffuse<>nil) then
		begin
		FMapDiffuse.TextureNumber := 1;
		FMapDiffuse.TextureType := SGITextureTypeTexture;
		FMapDiffuse.BindTexture();
		FMapDiffuse.TextureNumber := -1;
		end;
	end;
end;

procedure TSGMaterial.UnBind(const VObject : TSG3DObject);
begin
if (VObject.BumpFormat = SGMeshBumpTypeNone) and (VObject.HasTexture) then
	begin
	if FEnableTexture and (FMapDiffuse<>nil) then
		begin
		FMapDiffuse.TextureNumber := -1;
		FMapDiffuse.TextureType := SGITextureTypeTexture;
		FMapDiffuse.DisableTexture();
		end;
	end
else if (VObject.BumpFormat = SGMeshBumpTypeCopyTexture2f) and (VObject.HasTexture) then
	begin
	if FEnableBump and (FMapBump<>nil) then
		begin
		FMapBump.TextureNumber := 0;
		FMapBump.TextureType := SGITextureTypeBump;
		FMapBump.DisableTexture();
		FMapBump.TextureNumber := -1;
		FMapBump.TextureType := SGITextureTypeTexture;
		end;
	if FEnableTexture and (FMapDiffuse<>nil) then
		begin
		FMapDiffuse.TextureNumber := 1;
		FMapDiffuse.TextureType := SGITextureTypeTexture;
		FMapDiffuse.DisableTexture();
		FMapDiffuse.TextureNumber := -1;
		end;
	end;
end;

function TSGMaterial.MapDiffuseWay():TSGString;inline;
begin
if FMapDiffuse<>nil then
	Result:=FMapDiffuse.Way
else
	Result:='';
end;

function TSGMaterial.MapBumpWay():TSGString;inline;
begin
if FMapBump<>nil then
	Result:=FMapBump.Way
else
	Result:='';
end;

procedure TSGMaterial.SetColorAmbient(const r,g,b :TSGSingle);
begin
FColorAmbient.Import(r,g,b);
end;

procedure TSGMaterial.SetColorSpecular(const r,g,b :TSGSingle);
begin
FColorSpecular.Import(r,g,b);
end;

procedure TSGMaterial.SetColorDiffuse(const r,g,b :TSGSingle);
begin
FColorDiffuse.Import(r,g,b);
end;


end.

