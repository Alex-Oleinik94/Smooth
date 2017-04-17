{$INCLUDE SaGe.inc}

unit SaGeVertexObject;

interface

uses
	 SaGeBase
	,SaGeRenderBase
	,SaGeCommonClasses
	,SaGeCommonStructs
	,SaGeMaterial
	,SaGeLog
	,SaGeMatrix
	;
type
	// Это тип типа хранения цветов в модели
	TSGMeshColorType = (SGMeshColorType3f, SGMeshColorType4f, SGMeshColorType3b, SGMeshColorType4b);
	TSGMeshIndexFormat = (SGMeshIndexFormat1b, SGMeshIndexFormat2b, SGMeshIndexFormat4b);
	// Это тип типа хранения вершин в модели
	TSGMeshVertexType = TSGVertexFormat;
const
	// Типы вершин
	SGMeshVertexType2f = SGVertexFormat2f;
	SGMeshVertexType3f = SGVertexFormat3f;
	SGMeshVertexType4f = SGVertexFormat4f;
type
	TSG3dObject = class;
	
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
	
type
	PSG3DObjectFace = ^ TSG3DObjectFace;
	TSG3DObjectFace = packed record 
		FIndexFormat      : TSGMeshIndexFormat;
		FPoligonesType    : TSGLongWord;
		FNOfFaces         : TSGQuadWord;
		// Указательл на первый элемент области памяти, где находятся индексы
		FArray            : TSGPointer;
		// Идентификатор материала
		FMaterial         : ISGMaterial;
		end;
	TSG3DObjectFacees = packed array of TSG3DObjectFace;
type
	TSG3DObjectBuffer = TSGUInt32;
	TSG3DObjectBufferList = TSGUInt32List;
    { TSG3dObject }
    // Моделька..
type
    TSG3DObject = class(TSGDrawable)
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
        FBumpFormat : TSGBumpFormat;
    protected
        // Тип полигонов в модельки (SGR_QUADS, SGR_TRIANGLES, SGR_LINES, SGR_LINE_LOOP ....)
        FObjectPoligonesType    : TSGLongWord;
        // Тип вершин в модельке
        FVertexType       : TSGMeshVertexType;
        // Тип хранение цветов
        FColorType        : TSGMeshColorType;
    private
		function GetSizeOfOneVertex():LongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		function GetSizeOfOneTextureCoord():TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetSizeOfOneVertexCoord():TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetSizeOfOneColorCoord():TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetSizeOfOneNormalCoord():TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		function GetCountOfOneTextureCoord():TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetCountOfOneVertexCoord():TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetCountOfOneColorCoord():TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetCountOfOneNormalCoord():TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		function GetVertexLength():QWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		procedure SetHasTexture(const VHasTexture:TSGBoolean); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetQuantityFaces(const Index : TSGLongWord):TSGQuadWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetPoligonesType(const ArIndex : TSGLongWord):TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		procedure SetPoligonesType(const ArIndex : TSGLongWord;const NewPoligonesType : TSGLongWord); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
	public
		procedure SetColorType(const VNewColorType:TSGMeshColorType);
		procedure SetVertexType(const VNewVertexType:TSGMeshVertexType);
		procedure ChangeMeshColorType4b();
    public
        // Эти свойства уже были прокоментированы выше (см на что эти свойства ссылаются)
        property CountTextureFloatsInVertexArray   : TSGLongWord       read FCountTextureFloatsInVertexArray write FCountTextureFloatsInVertexArray;
        property BumpFormat                        : TSGBumpFormat     read FBumpFormat          write FBumpFormat;
        property PoligonesType[Index:TSGLongWord]  : TSGLongWord       read GetPoligonesType     write SetPoligonesType;
		property QuantityVertexes                  : TSGQuadWord       read FNOfVerts;
		property HasTexture                        : TSGBoolean        read FHasTexture          write SetHasTexture;
		property HasColors                         : TSGBoolean        read FHasColors           write FHasColors;
		property HasNormals                        : TSGBoolean        read FHasNormals          write FHasNormals;
		property ColorType                         : TSGMeshColorType  read FColorType           write SetColorType;
		property VertexType                        : TSGMeshVertexType read FVertexType          write SetVertexType;
		property ObjectPoligonesType               : LongWord          read FObjectPoligonesType write FObjectPoligonesType;
    protected
        // Это массив индексов
		ArFaces : TSG3DObjectFacees;
	
		// Это массив самих вершин. 
		// Он в себе содерщит много всего, и обрабатывается соответствующе...
		//! B таком порядке записывается в памяти информация о вершине
		(* Vertex = [Vertex, Color, Normal, TexVertex] *)
		(* Array of Vertex *)
		ArVertex : TSGPointer;
	public
		// Возвращает указатель на первый элемент массива вершин
		function GetArVertexes():TSGPointer; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		// Возвращает указатель на первый элемент массива индексов
		function GetArFaces(const Index : LongWord = 0):TSGPointer; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
	private
		function GetVertex3f(const Index : TSGMaxEnum):PSGVertex3f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetVertex2f(const Index : TSGMaxEnum):PSGVertex2f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetVertex4f(const Index : TSGMaxEnum):PSGVertex4f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		function GetObjectFace(const Index : TSGMaxEnum = 0) : PSG3DObjectFace; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
	public
		// Эти совйтсва возвращают указатель на Index-ый элемент массива вершин 
		//! Это можно пользоваться только когда, когда VertexType = SGMeshVertexType3f, иначе Result = nil
		property ArVertex3f[Index : TSGMaxEnum]:PSGVertex3f read GetVertex3f;
		//! Это можно пользоваться только когда, когда VertexType = SGMeshVertexType2f, иначе Result = nil
		property ArVertex2f[Index : TSGMaxEnum]:PSGVertex2f read GetVertex2f;
		//! Это можно пользоваться только когда, когда VertexType = SGMeshVertexType4f, иначе Result = nil
		property ArVertex4f[Index : TSGMaxEnum]:PSGVertex4f read GetVertex4f;
		
		// Добавляет пустую(ые) вершины в массив вершин
		procedure AddVertex(const QuantityNewVertexes : LongWord = 1);
		
		procedure SetVertex(const VVertexIndex : TSGUInt32; const x, y : TSGFloat32; const z : TSGFloat32 = 0; const w : TSGFloat32 = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure SetVertex(const VVertexIndex : TSGUInt32; const v2 : TSGVector2f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		
		// Добавляет еще элемент(ы) в массив индексов
		procedure AddFace(const ArIndex:TSGLongWord;const FQuantityNewFaces:LongWord = 1);
		property ObjectFace[Index : TSGMaxEnum] : PSG3DObjectFace read GetObjectFace;
		function LastObjectFace() : PSG3DObjectFace; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
	private
		function GetColor3f(const Index:TSGMaxEnum):PSGColor3f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetColor4f(const Index:TSGMaxEnum):PSGColor4f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetColor3b(const Index:TSGMaxEnum):PSGColor3b; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetColor4b(const Index:TSGMaxEnum):PSGColor4b; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
	public
		// Возвращает указатель на структуру данных,
		// к которой хранится информация о цвете вершины с индексом Index
		// Каждую функцию можно использовать только когда установлен соответствующий тип формата цветов
		// Иначе Result = nil.
		(* Для установки цвета лучше использовать процедуру SetColor, описанную ниже *)
		property ArColor3f[Index : TSGMaxEnum]:PSGColor3f read GetColor3f;
		property ArColor4f[Index : TSGMaxEnum]:PSGColor4f read GetColor4f;
		property ArColor3b[Index : TSGMaxEnum]:PSGColor3b read GetColor3b;
		property ArColor4b[Index : TSGMaxEnum]:PSGColor4b read GetColor4b;
		
		// Эта процедура устанавливает цвет вершины. Работает для любого формата хранение цвета.
		procedure SetColor(const Index:TSGMaxEnum;const r,g,b:TSGSingle; const a:TSGSingle = 1); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetColor(const Index:TSGMaxEnum) : TSGColor4f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		// Автоматически определяет нужный формат хранения цветов. (В зависимости от рендера)
		procedure AutoSetColorType(const VWithAlpha:Boolean = False); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		procedure AutoSetIndexFormat(const ArIndex : TSGLongWord; const MaxVertexLength : TSGQuadWord );
	private
		function GetNormal(const Index:TSGMaxEnum):PSGVertex3f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
	
	public
		// Свойство для редактирования нормалей
		property ArNormal[Index : TSGMaxEnum]:PSGVertex3f read GetNormal;
		
	private
		function GetTexVertex(const Index : TSGMaxEnum): PSGVertex2f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetTexVertex3f(const Index : TSGMaxEnum): PSGVertex3f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetTexVertex4f(const Index : TSGMaxEnum): PSGVertex4f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
	public
		property ArTexVertex[Index : TSGMaxEnum] : PSGVertex2f read GetTexVertex;
		property ArTexVertex2f[Index : TSGMaxEnum] : PSGVertex2f read GetTexVertex;
		property ArTexVertex3f[Index : TSGMaxEnum] : PSGVertex3f read GetTexVertex3f;
		property ArTexVertex4f[Index : TSGMaxEnum] : PSGVertex4f read GetTexVertex4f;
		
		// Устанавливает количество вершин
		procedure SetVertexLength(const NewVertexLength:TSGQuadWord); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		// Возвращает сколько в байтах занимают массив вершин
		function GetVertexesSize():TSGMaxEnum;overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		// Эта процедура для DirectX. Дело в том, что там нету SGR_QUADS. Так что он разбивается на 2 треугольника.
		procedure SetFaceQuad(const ArIndex:TSGLongWord;const Index :TSGMaxEnum; const p0,p1,p2,p3:TSGLongWord);
		procedure SetFaceTriangle(const ArIndex:TSGLongWord;const Index :TSGMaxEnum; const p0,p1,p2:TSGLongWord);
		procedure SetFaceLine(const ArIndex:TSGLongWord;const Index :TSGMaxEnum; const p0,p1:TSGLongWord);
		procedure SetFacePoint(const ArIndex:TSGLongWord;const Index :TSGMaxEnum; const p0:TSGLongWord);
		
		// Возвращает индекс на первый элемент массива индексов. Не просто возвращает, а хитро возвращает.
		// Теперь эти функции можно использовать как массивы. Так что их очень просто использовать.
		// Но нужно соблюдать тип хранения индексов
		function ArFacesLines1b(const Index:TSGLongWord = 0)     : PTSGFaceLine1b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesQuads1b(const Index:TSGLongWord = 0)     : PTSGFaceQuad1b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesTriangles1b(const Index:TSGLongWord = 0) : PTSGFaceTriangle1b;  {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesPoints1b(const Index:TSGLongWord = 0)    : PTSGFacePoint1b;     {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		function ArFacesLines2b(const Index:TSGLongWord = 0)     : PTSGFaceLine2b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesQuads2b(const Index:TSGLongWord = 0)     : PTSGFaceQuad2b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesTriangles2b(const Index:TSGLongWord = 0) : PTSGFaceTriangle2b;  {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesPoints2b(const Index:TSGLongWord = 0)    : PTSGFacePoint2b;     {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		function ArFacesLines4b(const Index:TSGLongWord = 0)     : PTSGFaceLine4b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesQuads4b(const Index:TSGLongWord = 0)     : PTSGFaceQuad4b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesTriangles4b(const Index:TSGLongWord = 0) : PTSGFaceTriangle4b;  {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesPoints4b(const Index:TSGLongWord = 0)    : PTSGFacePoint4b;     {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		function ArFacesLines(const ArIndex:TSGLongWord = 0;const Index:TSGLongWord = 0)     : TSGFaceLine;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesQuads(const ArIndex:TSGLongWord = 0;const Index:TSGLongWord = 0)     : TSGFaceQuad;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesTriangles(const ArIndex:TSGLongWord = 0;const Index:TSGLongWord = 0) : TSGFaceTriangle;  {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesPoints(const ArIndex:TSGLongWord = 0;const Index:TSGLongWord = 0)    : TSGFacePoint;     {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		procedure SetFaceArLength(const NewArLength : TSGLongWord);
		procedure AddFaceArray(const QuantityNewArrays : TSGLongWord = 1);
		// Устанавливает длинну массива индексов
		procedure SetFaceLength(const ArIndex:TSGLongWord;const NewLength:TSGQuadWord); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		// Возвращает действительную длинну массива индексов
		function GetFaceLength(const Index:TSGLongWord):TSGQuadWord;overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		// Возвращает действительную длинну массива индексов в зависимости он их длинны и их типа, заданых параметрами
		class function GetFaceLength(const FaceLength:TSGQuadWord; const ThisPoligoneType:LongWord):TSGQuadWord;overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		// Возвращает, сколько в TSGFaceType*Result байтов занимает одна структура индексов. Очень прикольная функция.
		class function GetPoligoneInt(const ThisPoligoneType:LongWord):Byte; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		class function GetFaceInt(const ThisFaceFormat : TSGMeshIndexFormat):Byte; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
	public
		// Ствойства для получения и редактирования длинн массивов
		property QuantityFaceArrays       : TSGLongWord read FQuantityFaceArrays  write SetFaceArLength;
		property Faces[Index:TSGLongWord] : TSGQuadWord read GetQuantityFaces     write SetFaceLength;
		property Vertexes                 : TSGQuadWord read GetVertexLength      write SetVertexLength;
		property RealQuantityFaces[Index : TSGLongWord]: TSGQuadWord   read GetFaceLength;
    protected
		// Включено ли VBO
		// VBO - Vertex Buffer Object
		// Vertex Buffer Object - это технология, при которой можно отображать обьекты на экране, 
		//    держа все массивы в памяти видеокарте, а не в оперативной памяти
		// Если на вашем устройстве нету видеокарты (типо нетбук), то массивы будут копироваться в оперативку
		FEnableVBO      : TSGBoolean;
		
		// Идентификатор массива вершин в видюхе
        FVertexesBuffer    : TSG3DObjectBuffer;
        // Идентификатор массива индексов в видюхе
        FFacesBuffers      : TSG3DObjectBufferList;
        
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
        procedure Paint(); override;
        // Когда включен Cull Face, то Draw нужно делать 2 раза.
        // Так что вод тут делается Draw, а в Draw просто проверяется, включен или не  Cull Face, 
        //   и в зависимости от этого он вызывает эту процедуду 1 или 2 раза
        procedure InitAttributes();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
        procedure DisableAttributes();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
        procedure BasicDraw(); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
        procedure BasicDrawWithAttributes();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
        // Подгрузка массивов в память видеокарты
        procedure LoadToVBO();
        // Очищение памяти видеокарты от массивов этого класса
        procedure ClearVBO();
        // Процедурка очищает оперативную память от массивов этого класса
        procedure ClearArrays(const ClearN:Boolean = True);
			public
        // Эта процедурка автоматически выделяет память под нормали и вычесляет их, исходя из данных вершин
        procedure AddNormals();virtual;
        
        (* Я ж переписывал этот класс. Это то, что я не написал. *)
		//procedure Stripificate;overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		//procedure Stripificate(var VertexesAndTriangles:TSGArTSGArTSGFaceType;var OutputStrip:TSGArTSGFaceType);overload;
		
		// Выводит полную информацию о характеристиках модельки
		procedure WriteInfo(const PredStr : TSGString = ''; const ViewError : TSGViewErrorType = [SGPrintError, SGLogError]);
	public
		// Возвращает, сколько занимают байтов вершины
		function VertexesSize():QWord;Inline;
		// Возвращает, сколько занимают байтов индексы
		function FacesSize():QWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		// Возвращает, сколько занимают байтов вершины и индексы
		function Size():QWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
	protected 
		// Имя модельки
		FName : TSGString;
		FObjectMaterial : ISGMaterial;
		
		FEnableObjectMatrix : TSGBoolean;
		FObjectMatrix : TSGMatrix4x4;
	public
		property ObjectMatrixEnabled : TSGBoolean read FEnableObjectMatrix;
		procedure SetMatrix(const Matrix : TSGMatrix4x4);
	public
		// Свойство : Имя модельки
		property Name             : TSGString      read FName             write FName;
		// Свойство : Идентификатор материала
		property ObjectMaterial   : ISGMaterial    read FObjectMaterial   write FObjectMaterial;
		property ObjectMatrix     : TSGMatrix4x4   read FObjectMatrix     write SetMatrix;
	public
		procedure CopyTo(const Destination : TSG3dObject);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
    end;

    PSG3dObject = ^ TSG3dObject;

function SGStrMeshIndexFormat(const IndexFormat : TSGMeshIndexFormat) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStrMeshColorFormat(const ColorFormat : TSGMeshColorType) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGMeshToRenderIndexFormat(const IndexFormat : TSGMeshIndexFormat) : TSGUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGKill(var O : TSG3DObject); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeStringUtils
	,SaGeMathUtils
	,SaGeCommon
	,SaGeBaseUtils
	
	,Crt
	;

function SGMeshToRenderIndexFormat(const IndexFormat : TSGMeshIndexFormat) : TSGUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case IndexFormat of
SGMeshIndexFormat1b : Result := SGR_UNSIGNED_BYTE;
SGMeshIndexFormat2b : Result := SGR_UNSIGNED_SHORT;
SGMeshIndexFormat4b : Result := SGR_UNSIGNED_INT;
else                  Result := 0;
end;
end;

procedure SGKill(var O : TSG3DObject); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if O <> nil then
	begin
	O.Destroy();
	O := nil;
	end;
end;

function SGStrMeshColorFormat(const ColorFormat : TSGMeshColorType) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case ColorFormat of
SGMeshColorType3b : Result := 'SGMeshColorFormat3b';
SGMeshColorType4b : Result := 'SGMeshColorFormat4b';
SGMeshColorType3f : Result := 'SGMeshColorFormat3f';
SGMeshColorType4f : Result := 'SGMeshColorFormat4f';
else                Result := 'INVALID(' + SGStr(TSGByte(ColorFormat)) + ')';
end;
end;

function SGStrMeshIndexFormat(const IndexFormat : TSGMeshIndexFormat) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case IndexFormat of
SGMeshIndexFormat1b : Result := 'SGMeshIndexFormat1b';
SGMeshIndexFormat2b : Result := 'SGMeshIndexFormat2b';
SGMeshIndexFormat4b : Result := 'SGMeshIndexFormat4b';
else                  Result := 'INVALID(' + SGStr(TSGByte(IndexFormat)) + ')';
end;
end;

// Vertex Object

function TSG3DObject.ArFacesLines(const ArIndex:TSGLongWord = 0;const Index:TSGLongWord = 0)     : TSGFaceLine;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
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

function TSG3DObject.ArFacesQuads(const ArIndex:TSGLongWord = 0;const Index:TSGLongWord = 0)     : TSGFaceQuad;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
FillChar(Result, SizeOf(Result), 0);
if Render.RenderType <> SGRenderOpenGL then
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

function TSG3DObject.ArFacesTriangles(const ArIndex:TSGLongWord = 0;const Index:TSGLongWord = 0) : TSGFaceTriangle;  {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
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

function TSG3DObject.ArFacesPoints(const ArIndex:TSGLongWord = 0;const Index:TSGLongWord = 0)    : TSGFacePoint;     {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
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

procedure TSG3DObject.SetPoligonesType(const ArIndex : TSGLongWord;const NewPoligonesType : TSGLongWord); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
ArFaces[ArIndex].FPoligonesType:=NewPoligonesType;
end;

function TSG3DObject.GetPoligonesType(const ArIndex : TSGLongWord):TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=ArFaces[ArIndex].FPoligonesType;
end;

procedure TSG3DObject.AutoSetIndexFormat(const ArIndex : TSGLongWord; const MaxVertexLength : TSGQuadWord );
begin
if (MaxVertexLength<=255) and (Render.RenderType=SGRenderOpenGL) then
	ArFaces[ArIndex].FIndexFormat:=SGMeshIndexFormat1b
else if (MaxVertexLength<=255*255) or (Render.RenderType=SGRenderDirectX9) or (Render.RenderType=SGRenderDirectX8) then
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
if (FQuantityFaceArrays >= NewArLength) then
	Exit;
SetLength(ArFaces, NewArLength);
for Index := FQuantityFaceArrays to NewArLength - 1 do
	begin
	ArFaces[Index].FMaterial      := nil;
	ArFaces[Index].FIndexFormat   := SGMeshIndexFormat2b;
	ArFaces[Index].FPoligonesType := SGR_TRIANGLES;
	ArFaces[Index].FArray         := nil;
	ArFaces[Index].FNOfFaces      := 0;
	end;
FQuantityFaceArrays := NewArLength;
end;

procedure TSG3DObject.AddFaceArray(const QuantityNewArrays : TSGLongWord = 1);
begin
SetFaceArLength(FQuantityFaceArrays+QuantityNewArrays);
end;

class function  TSG3DObject.GetFaceInt(const ThisFaceFormat : TSGMeshIndexFormat):Byte; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=
	TSGByte(ThisFaceFormat=SGMeshIndexFormat1b)+
	TSGByte(ThisFaceFormat=SGMeshIndexFormat2b)*2+
	TSGByte(ThisFaceFormat=SGMeshIndexFormat4b)*4;
end;

function TSG3DObject.GetQuantityFaces(const Index : TSGLongWord):TSGQuadWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := ArFaces[Index].FNOfFaces;
end;

procedure TSG3DObject.SetHasTexture(const VHasTexture:TSGBoolean); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
FHasTexture:=VHasTexture;
end;

function TSG3DObject.GetVertexLength():QWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
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
	Plane:TSGPlane3D;
	Vertex:TSGVertex3f;
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
SetLength(ArPoligonesNormals,Faces[0]);
for i:=0 to Faces[0]-1 do
	begin
	Plane := SGPlane3DFrom3Points(
		ArVertex3f[ArFacesTriangles(0,i).p[0]]^,
		ArVertex3f[ArFacesTriangles(0,i).p[1]]^,
		ArVertex3f[ArFacesTriangles(0,i).p[2]]^);
	ArPoligonesNormals[i].Import(
		Plane.a, Plane.b, Plane.c);
	end;
for i:=0 to QuantityVertexes-1 do
	begin
	Vertex.Import(0,0,0);
	for ii:=0 to Faces[0]-1 do
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
	Vertex := Vertex.Normalized();
	ArNormal[i]^:= Vertex;
	end;
SetLength(ArPoligonesNormals,0);
end;

procedure TSG3DObject.AddFace(const ArIndex:TSGLongWord;const FQuantityNewFaces:LongWord = 1);
begin
SetFaceLength(ArIndex,Faces[ArIndex]+FQuantityNewFaces);
end;

procedure TSG3DObject.AddVertex(const QuantityNewVertexes : LongWord = 1);
begin
FNOfVerts += QuantityNewVertexes;
ReAllocMem(ArVertex, GetVertexesSize());
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

procedure TSG3DObject.AutoSetColorType(const VWithAlpha:Boolean = False); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
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

function TSG3DObject.GetColor(const Index:TSGMaxEnum) : TSGColor4f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result.Import();
if (FColorType=SGMeshColorType3f) then
	begin
	Result.Import(ArColor3f[Index]^.r, ArColor3f[Index]^.g, ArColor3f[Index]^.b, 1);
	end
else if (FColorType=SGMeshColorType4f) then
	begin
	Result.Import(ArColor4f[Index]^.r, ArColor4f[Index]^.g, ArColor4f[Index]^.b, ArColor4f[Index]^.a);
	end
else if (FColorType=SGMeshColorType3b) then
	begin
	Result.Import(ArColor3b[Index]^.r / 255, ArColor3b[Index]^.g / 255, ArColor3b[Index]^.b / 255, 1);
	end
else if (FColorType=SGMeshColorType4b) then
	begin
	if (Render.RenderType = SGRenderDirectX9) or (Render.RenderType = SGRenderDirectX8) then
		begin
		Result.Import(ArColor4b[Index]^.r / 255, ArColor4b[Index]^.g / 255, ArColor4b[Index]^.b / 255, ArColor4b[Index]^.a / 255);
		end
	else
		begin
		Result.Import(ArColor4b[Index]^.b / 255, ArColor4b[Index]^.g / 255, ArColor4b[Index]^.r / 255, ArColor4b[Index]^.a / 255);
		end;
	end;
end;

procedure TSG3DObject.SetVertex(const VVertexIndex : TSGUInt32; const v2 : TSGVector2f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if FVertexType = SGMeshVertexType2f then
	ArVertex2f[VVertexIndex]^ := v2
else if FVertexType = SGMeshVertexType3f then
	ArVertex3f[VVertexIndex]^.Import(v2.x, v2.y)
else if FVertexType = SGMeshVertexType4f then
	ArVertex4f[VVertexIndex]^.Import(v2.x, v2.y);
end;

procedure TSG3DObject.SetVertex(const VVertexIndex : TSGUInt32; const x, y : TSGFloat32; const z : TSGFloat32 = 0; const w : TSGFloat32 = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if FVertexType = SGMeshVertexType2f then
	ArVertex2f[VVertexIndex]^.Import(x, y)
else if FVertexType = SGMeshVertexType3f then
	ArVertex3f[VVertexIndex]^.Import(x, y, z)
else if FVertexType = SGMeshVertexType4f then
	ArVertex4f[VVertexIndex]^.Import(x, y, z, w);
end;

procedure TSG3DObject.SetColor(const Index:TSGMaxEnum;const r,g,b:Single; const a:Single = 1); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
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
	if (Render.RenderType = SGRenderDirectX9) or (Render.RenderType = SGRenderDirectX8) then
		begin
		ArColor4b[Index]^.b:=Byte(r>=1)*255+Byte((r<1) and (r>0))*round(255*r);
		ArColor4b[Index]^.r:=Byte(b>=1)*255+Byte((b<1) and (b>0))*round(255*b);
		end
	else
		begin
		ArColor4b[Index]^.r:=Byte(r>=1)*255+Byte((r<1) and (r>0))*round(255*r);
		ArColor4b[Index]^.b:=Byte(b>=1)*255+Byte((b<1) and (b>0))*round(255*b);
		end;
	ArColor4b[Index]^.g:=Byte(g>=1)*255+Byte((g<1) and (g>0))*round(255*g);
	ArColor4b[Index]^.a:=Byte(a>=1)*255+Byte((a<1) and (a>0))*round(255*a);
	end;
end;

function TSG3DObject.GetTexVertex3f(const Index : TSGMaxEnum): PSGVertex3f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSGVertex3f(
	TSGMaxEnum(ArVertex)
	+GetSizeOfOneVertex()*Index
	+GetSizeOfOneVertexCoord()
	+GetSizeOfOneColorCoord()
	+GetSizeOfOneNormalCoord());
end;

function TSG3DObject.GetTexVertex4f(const Index : TSGMaxEnum): PSGVertex4f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSGVertex4f(
	TSGMaxEnum(ArVertex)
	+GetSizeOfOneVertex()*Index
	+GetSizeOfOneVertexCoord()
	+GetSizeOfOneColorCoord()
	+GetSizeOfOneNormalCoord());
end;

function TSG3DObject.GetTexVertex(const Index : TSGMaxEnum): PSGVertex2f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSGVertex2f(
	TSGMaxEnum(ArVertex)
	+GetSizeOfOneVertex()*Index
	+GetSizeOfOneVertexCoord()
	+GetSizeOfOneColorCoord()
	+GetSizeOfOneNormalCoord());
end;

function TSG3DObject.GetNormal(const Index:TSGMaxEnum):PSGVertex3f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSGVertex3f( 
	TSGMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index
	+GetSizeOfOneVertexCoord()
	+GetSizeOfOneColorCoord());
end;

function TSG3DObject.GetColor4f(const Index:TSGMaxEnum):PSGColor4f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSGColor4f( 
	TSGMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	GetSizeOfOneVertexCoord());
end;

function TSG3DObject.GetColor3b(const Index:TSGMaxEnum):PSGColor3b; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSGColor3b( 
	TSGMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	GetSizeOfOneVertexCoord());
end;

function TSG3DObject.GetColor4b(const Index:TSGMaxEnum):PSGColor4b; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSGColor4b(Pointer(
	TSGMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	GetSizeOfOneVertexCoord()));
end;

function TSG3DObject.GetColor3f(const Index:TSGMaxEnum):PSGColor3f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSGColor3f( 
	TSGMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	GetSizeOfOneVertexCoord());
end;

function TSG3DObject.GetArFaces(const Index : LongWord = 0):Pointer; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if ArFaces=nil then
	Result:=nil
else
	Result:=@ArFaces[Index].FArray;
end;

function TSG3DObject.LastObjectFace() : PSG3DObjectFace; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces = nil) or (FQuantityFaceArrays = 0) then
	Result := nil
else
	Result := @ArFaces[FQuantityFaceArrays - 1];
end;

function TSG3DObject.GetObjectFace(const Index : TSGMaxEnum = 0) : PSG3DObjectFace; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces = nil) or (FQuantityFaceArrays = 0) then
	Result := nil
else
	Result := @ArFaces[Index];
end;

function TSG3DObject.GetArVertexes():Pointer; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := ArVertex;
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

procedure TSG3DObject.SetVertexLength(const NewVertexLength:QWord); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
FNOfVerts:=NewVertexLength;
if ArVertex = nil then
	GetMem(ArVertex,GetVertexesSize())
else
	ReallocMem(ArVertex,GetVertexesSize());
end;

function TSG3DObject.GetCountOfOneTextureCoord():TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := Byte(FHasTexture)*FCountTextureFloatsInVertexArray;
end;

function TSG3DObject.GetCountOfOneVertexCoord():TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := (2 + Byte(FVertexType=SGMeshVertexType3f) + 2 * Byte(FVertexType = SGMeshVertexType4f));
end;

function TSG3DObject.GetCountOfOneColorCoord():TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := Byte(FHasColors)*(3+byte((FColorType=SGMeshColorType4b) xor (FColorType=SGMeshColorType4f)));
end;

function TSG3DObject.GetCountOfOneNormalCoord():TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := Byte(FHasNormals)*3;
end;

function TSG3DObject.GetSizeOfOneTextureCoord():TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := GetCountOfOneTextureCoord()*SizeOf(Single);
end;

function TSG3DObject.GetSizeOfOneVertexCoord():TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := GetCountOfOneVertexCoord()*SizeOf(Single);
end;

function TSG3DObject.GetSizeOfOneColorCoord():TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := GetCountOfOneColorCoord() * (1 + byte((FColorType=SGMeshColorType3f) xor (FColorType=SGMeshColorType4f))*(SizeOf(TSGSingle)-1));
end;

function TSG3DObject.GetSizeOfOneNormalCoord():TSGLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := GetCountOfOneNormalCoord()*SizeOf(Single);
end;

function TSG3DObject.GetSizeOfOneVertex():LongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:= GetSizeOfOneVertexCoord() +
	GetSizeOfOneColorCoord() +
	GetSizeOfOneNormalCoord() +
	GetSizeOfOneTextureCoord();
end;

function TSG3DObject.GetVertexesSize():TSGMaxEnum;overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=FNOfVerts*GetSizeOfOneVertex();
end;

function TSG3DObject.GetVertex3f(const Index:TSGMaxEnum):PSGVertex3f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSGVertex3f(TSGMaxEnum(ArVertex)+Index*(GetSizeOfOneVertex()));
end;

function TSG3DObject.GetVertex4f(const Index : TSGMaxEnum):PSGVertex4f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSGVertex4f(TSGMaxEnum(ArVertex)+Index*(GetSizeOfOneVertex()));
end;

function TSG3DObject.GetVertex2f(const Index:TSGMaxEnum):PSGVertex2f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSGVertex2f(TSGMaxEnum(ArVertex)+Index*(GetSizeOfOneVertex()));
end;

class function TSG3DObject.GetFaceLength(const FaceLength:TSGQuadWord; const ThisPoligoneType:LongWord):TSGQuadWord;overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=FaceLength*GetPoligoneInt(ThisPoligoneType);
end;

class function TSG3DObject.ClassName:string;
begin
Result:='TSG3dObject';
end;

procedure TSG3DObject.WriteInfo(const PredStr : TSGString = ''; const ViewError : TSGViewErrorType = [SGPrintError, SGLogError]);

function LinksVBO() : TSGString;
var
	Index : TSGUInt32;
begin
Result := '';
if FFacesBuffers <> nil then
	for Index := 0 to High(FFacesBuffers) do
		begin
		Result += SGStr(FFacesBuffers[Index]);
		if Index <> High(FFacesBuffers) then
			Result += ',';
		end;
end;

procedure WriteFaceArray(const Index : TSGUInt32);
var
	FacePredString : TSGString = '';
begin
FacePredString := PredStr + '   ' + SGStr(Index + 1) + ') ';
SGHint([FacePredString,'Index           = "',Index,'"'], ViewError);
SGHint([FacePredString,'CountOfFaces    = "',ArFaces[Index].FNOfFaces,'"'], ViewError);
SGHint([FacePredString,'RealFaceLength  = "',GetFaceLength(Index),'"'], ViewError);
SGHint([FacePredString,'MaterialID      = "',ArFaces[Index].FMaterial,'"'], ViewError);
SGHint([FacePredString,'IndexFormat     = "'+SGStrMeshIndexFormat(ArFaces[Index].FIndexFormat)+'"'], ViewError);
SGHint([FacePredString,'PoligonesType   = "', SGStrPoligonesType(ArFaces[Index].FPoligonesType), '"'], ViewError);
TextColor(15);
SGHint([FacePredString,'FacesSize       = "',SGGetSizeString(GetFaceInt(ArFaces[Index].FIndexFormat) * GetFaceLength(Index),'EN'),'"'], ViewError);
TextColor(7);
end;

procedure WriteFaceArrays();
var
	Index : TSGUInt32;
begin
TextColor(7);
if FQuantityFaceArrays <> 0 then
	for Index:=0 to FQuantityFaceArrays - 1 do
		WriteFaceArray(Index);
end;

begin
TextColor(7);
SGHint(PredStr + 'TSG3DObject__WriteInfo(..)', ViewError);
SGHint([PredStr,'  Name                = "',FName,'"'], ViewError);
SGHint([PredStr,'  CountOfVertexes     = "',FNOfVerts,'"'], ViewError);
SGHint([PredStr,'  HasColors           = "',FHasColors,'"'], ViewError);
SGHint([PredStr,'  HasNormals          = "',FHasNormals,'"'], ViewError);
SGHint([PredStr,'  HasTexture          = "',FHasTexture,'"'], ViewError);
if FQuantityFaceArrays>0 then TextColor(10) else TextColor(12);
SGHint([PredStr,'  QuantityFaceArrays  = "',FQuantityFaceArrays,'"'], ViewError);
WriteFaceArrays();
SGHint([PredStr,'  ObjectPoligonesType = "', SGStrPoligonesType(FObjectPoligonesType), '"'], ViewError);
SGHint([PredStr,'  SizeOfOneVertex     = "',GetSizeOfOneVertex(),'"'], ViewError);
SGHint([PredStr,'  VertexFormat        = "', SGStrVertexFormat(FVertexType), '"'], ViewError);
SGHint([PredStr,'  CountTextureFloatsInVertexArray = "',FCountTextureFloatsInVertexArray,'"'], ViewError);
SGHint([PredStr,'  ColorType           = "' + SGStrMeshColorFormat(FColorType) + '"'], ViewError);
TextColor(15);
SGHint([PredStr,'  VertexesSize        = "',SGGetSizeString(VertexesSize(),'EN'),'"'], ViewError);
if FQuantityFaceArrays>0 then
	SGHint([PredStr,'  AllSize             = "',SGGetSizeString(Size(),'EN'),'"'], ViewError);
TextColor(7);
SGHint([PredStr,'  EnableVBO           = "',FEnableVBO,'"'], ViewError);
SGHint([PredStr,'  LinksVBO            = Vertex:',FVertexesBuffer,', Faces:(', Iff(LinksVBO() = '', 'nil', LinksVBO()), ')'], ViewError);
SGHint([PredStr,'  ObjectMaterialID    = "',FObjectMaterial,'"'], ViewError);
end;

function TSG3DObject.VertexesSize():TSGQuadWord;Inline;
begin
Result:=GetSizeOfOneVertex()*FNOfVerts;
end;

function TSG3DObject.FacesSize():TSGQuadWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	Index : TSGLongWord;
begin
Result:=0;
if FQuantityFaceArrays<>0 then
	for Index := 0 to FQuantityFaceArrays-1 do
		Result += GetFaceInt(ArFaces[Index].FIndexFormat)*GetFaceLength(Index);
end;

function TSG3DObject.Size():QWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=
	FacesSize()+
	VertexesSize();
end;

class function TSG3DObject.GetPoligoneInt(const ThisPoligoneType : LongWord):Byte; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
case ThisPoligoneType of
SGR_POINTS,
	SGR_TRIANGLE_STRIP,
	SGR_LINE_LOOP,
	SGR_LINE_STRIP : Result := 1;
SGR_QUADS          : Result := 4;
SGR_TRIANGLES      : Result := 3;
SGR_LINES          : Result := 2;
end;
end;

function TSG3DObject.GetFaceLength(const Index : TSGLongWord):TSGQuadWord;overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=GetFaceLength(ArFaces[Index].FNOfFaces,ArFaces[Index].FPoligonesType);
end;

procedure TSG3DObject.SetFaceLength(const ArIndex:TSGLongWord;const NewLength:TSGQuadWord); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces[ArIndex].FNOfFaces=0) or (ArFaces[ArIndex].FArray=nil) then
	GetMem(ArFaces[ArIndex].FArray,
		GetPoligoneInt(ArFaces[ArIndex].FPoligonesType)*GetFaceInt(ArFaces[ArIndex].FIndexFormat)*(NewLength))
else
	ReAllocMem(ArFaces[ArIndex].FArray,
		GetPoligoneInt(ArFaces[ArIndex].FPoligonesType)*GetFaceInt(ArFaces[ArIndex].FIndexFormat)*(NewLength));
ArFaces[ArIndex].FNOfFaces:=NewLength;
end;

function TSG3DObject.ArFacesLines1b(const Index:TSGLongWord = 0)     : PTSGFaceLine1b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceLine1b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesQuads1b(const Index:TSGLongWord = 0)     : PTSGFaceQuad1b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceQuad1b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesTriangles1b(const Index:TSGLongWord = 0) : PTSGFaceTriangle1b;  {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceTriangle1b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesPoints1b(const Index:TSGLongWord = 0)    : PTSGFacePoint1b;     {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFacePoint1b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesLines2b(const Index:TSGLongWord = 0)     : PTSGFaceLine2b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceLine2b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesQuads2b(const Index:TSGLongWord = 0)     : PTSGFaceQuad2b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceQuad2b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesTriangles2b(const Index:TSGLongWord = 0) : PTSGFaceTriangle2b;  {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceTriangle2b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesPoints2b(const Index:TSGLongWord = 0)    : PTSGFacePoint2b;     {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFacePoint2b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesLines4b(const Index:TSGLongWord = 0)     : PTSGFaceLine4b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceLine4b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesQuads4b(const Index:TSGLongWord = 0)     : PTSGFaceQuad4b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceQuad4b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesTriangles4b(const Index:TSGLongWord = 0) : PTSGFaceTriangle4b;  {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSGFaceTriangle4b(TSGPointer(ArFaces[Index].FArray));
end;

function TSG3DObject.ArFacesPoints4b(const Index:TSGLongWord = 0)    : PTSGFacePoint4b;     {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
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
FBumpFormat := SGBumpFormatNone;
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
FObjectMaterial := nil;
FObjectPoligonesType := SGR_TRIANGLES;
FColorType:=SGMeshColorType3b;
FVertexType:=SGMeshVertexType3f;
FEnableVBO:=False;
FVertexesBuffer := 0;
FFacesBuffers := nil;
FEnableObjectMatrix := False;
FObjectMatrix := SGIdentityMatrix();
end;

procedure TSG3dObject.SetMatrix(const Matrix : TSGMatrix4x4);
begin
FEnableObjectMatrix := Matrix <> SGIdentityMatrix();
FObjectMatrix := Matrix;
end;

destructor TSG3dObject.Destroy();
begin
ClearArrays();
ClearVBO();
inherited Destroy();
end;

procedure TSG3dObject.BasicDrawWithAttributes();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
InitAttributes();
BasicDraw();
DisableAttributes();
end;

procedure TSG3dObject.Paint();
begin
{$IFDEF SGMoreDebuging}
	WriteLn('Call "TSG3dObject.Draw" : "'+ClassName+'" is sucsesfull');
	{$ENDIF}
if FEnableCullFace then
	if (FEnableCullFaceBack or FEnableCullFaceFront) then
		begin
		InitAttributes();
		Render.Enable(SGR_CULL_FACE);
		if FEnableCullFaceBack then
			begin
			Render.CullFace(SGR_BACK);
			BasicDraw();
			end;
		if FEnableCullFaceFront then
			begin
			Render.CullFace(SGR_FRONT);
			BasicDraw();
			end;
		Render.Disable(SGR_CULL_FACE);
		DisableAttributes();
		end
	else
		SGLog.Source('TSG3dObject__Draw : "' + ClassName + '" - CullFace enabled, but Front and Back draw types disabled...')
else
	BasicDrawWithAttributes();
end;

procedure TSG3DObject.ClearArrays(const ClearN : boolean = True);
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

procedure TSG3DObject.CopyTo(const Destination : TSG3dObject); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i: TSGLongWord;
begin
Destination.Context := Context;
Destination.HasNormals := HasTexture;
Destination.HasColors := HasColors;
Destination.HasNormals := HasNormals;
Destination.ObjectPoligonesType := ObjectPoligonesType;
Destination.EnableCullFace := EnableCullFace;
Destination.VertexType := VertexType;
Destination.ColorType := ColorType;
Destination.ObjectMatrix := ObjectMatrix;
Destination.CountTextureFloatsInVertexArray := CountTextureFloatsInVertexArray;
Destination.BumpFormat := BumpFormat;
Destination.ObjectColor := ObjectColor;
Destination.EnableCullFaceFront := EnableCullFaceFront;
Destination.EnableCullFaceBack := EnableCullFaceBack;
Destination.Name := Name;
//Destination.Parent := Parent;
Destination.ObjectMaterial := ObjectMaterial;

Destination.Vertexes := Vertexes;
Move(ArVertex^,Destination.ArVertex^,VertexesSize());

if QuantityFaceArrays <> 0 then
	for i := 0 to QuantityFaceArrays - 1 do
		begin
		Destination.AddFaceArray();
		Destination.ArFaces[i].FIndexFormat := ArFaces[i].FIndexFormat;
		Destination.PoligonesType[i] := PoligonesType[i];
		Destination.Faces[i] := Faces[i];
		Destination.ArFaces[i].FMaterial := ArFaces[i].FMaterial;
		Move(
			ArFaces[i].FArray^,
			Destination.ArFaces[i].FArray^,
			GetFaceInt(ArFaces[i].FIndexFormat) * GetFaceLength(i) );
		end;
end;

procedure TSG3dObject.InitAttributes();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if FEnableObjectMatrix then
	begin
	Render.PushMatrix();
	Render.MultMatrixf(@FObjectMatrix);
	end;

if (FObjectMaterial = nil) and (FQuantityFaceArrays = 0) then
	Render.ColorMaterial(FObjectColor.r, FObjectColor.g, FObjectColor.b, FObjectColor.a);

Render.EnableClientState(SGR_VERTEX_ARRAY);
if FHasNormals then
	Render.EnableClientState(SGR_NORMAL_ARRAY);
if FHasTexture then
	begin
	if FBumpFormat = SGBumpFormatCopyTexture2f then
		Render.ClientActiveTexture(1);
	Render.EnableClientState(SGR_TEXTURE_COORD_ARRAY);
	if FBumpFormat = SGBumpFormatCopyTexture2f then
		Render.ClientActiveTexture(0);
	end;
if (FBumpFormat = SGBumpFormatCopyTexture2f) or (FBumpFormat = SGBumpFormat2f) then
	begin
	Render.EnableClientState(SGR_TEXTURE_COORD_ARRAY);
	end;
if FHasColors then
	Render.EnableClientState(SGR_COLOR_ARRAY);

if FEnableVBO then
	begin
	Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB, FVertexesBuffer);
	Render.VertexPointer(GetCountOfOneVertexCoord(), SGR_FLOAT, GetSizeOfOneVertex(), nil);
	
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
		if FBumpFormat = SGBumpFormatCopyTexture2f then
			Render.ClientActiveTexture(1);
		Render.TexCoordPointer(GetCountOfOneTextureCoord(), SGR_FLOAT, GetSizeOfOneVertex(),
			Pointer(
				GetSizeOfOneVertexCoord() +
				GetSizeOfOneColorCoord() +
				GetSizeOfOneNormalCoord()));
		if FBumpFormat = SGBumpFormatCopyTexture2f then
			Render.ClientActiveTexture(0);
		end;
	
	if (FBumpFormat = SGBumpFormatCopyTexture2f) or (FBumpFormat = SGBumpFormat2f) then
		begin
		Render.TexCoordPointer(GetCountOfOneTextureCoord(), SGR_FLOAT, GetSizeOfOneVertex(),
			Pointer(
				GetSizeOfOneVertexCoord()+
				GetSizeOfOneColorCoord()+
				GetSizeOfOneNormalCoord()));
		end;
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
		if FBumpFormat = SGBumpFormatCopyTexture2f then
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
		if FBumpFormat = SGBumpFormatCopyTexture2f then
			Render.ClientActiveTexture(0);
		end;
	
	if (FBumpFormat = SGBumpFormatCopyTexture2f) or (FBumpFormat = SGBumpFormat2f) then
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
	end;

if (FObjectMaterial <> nil) then
	FObjectMaterial.Bind(BumpFormat, HasTexture);
end;

procedure TSG3dObject.DisableAttributes();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (FObjectMaterial <> nil) then
	FObjectMaterial.UnBind(BumpFormat, HasTexture);

if FEnableVBO then
	begin
	Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB, 0);
	if FQuantityFaceArrays <> 0 then
		Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB, 0);
	end;
Render.DisableClientState(SGR_VERTEX_ARRAY);
if FHasNormals then
	Render.DisableClientState(SGR_NORMAL_ARRAY);
if FHasTexture then
	begin
	if FBumpFormat = SGBumpFormatCopyTexture2f then
		Render.ClientActiveTexture(1);
	Render.DisableClientState(SGR_TEXTURE_COORD_ARRAY);
	if FBumpFormat = SGBumpFormatCopyTexture2f then
		Render.ClientActiveTexture(0);
	end;
if (FBumpFormat = SGBumpFormatCopyTexture2f) or (FBumpFormat = SGBumpFormat2f) then
	begin
	Render.DisableClientState(SGR_TEXTURE_COORD_ARRAY);
	end;
if FHasColors then
	Render.DisableClientState(SGR_COLOR_ARRAY);

if (FObjectMaterial = nil) and (FQuantityFaceArrays = 0) then
	Render.ColorMaterial(1, 1, 1, 1);

if FEnableObjectMatrix then
	Render.PopMatrix();
end;

procedure TSG3dObject.BasicDraw(); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}

procedure InitFaceArrayMeterial(const Material : ISGMaterial); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (Material <> nil) then
	begin
	if FObjectMaterial <> nil then
		FObjectMaterial.UnBind(BumpFormat, HasTexture);
	Material.Bind(BumpFormat, HasTexture);
	end;
end;

procedure DisableFaceArrayMeterial(const Material : ISGMaterial); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (Material <> nil) then
	begin
	Material.UnBind(BumpFormat, HasTexture);
	if FObjectMaterial <> nil then
		FObjectMaterial.Bind(BumpFormat, HasTexture);
	end;
end;

var
	Index : TSGMaxEnum;
begin
if FEnableVBO then
	if FQuantityFaceArrays <> 0 then
		for Index := 0 to FQuantityFaceArrays-1 do
			begin
			InitFaceArrayMeterial(ArFaces[Index].FMaterial);
			Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB, FFacesBuffers[Index]);
			Render.DrawElements(ArFaces[Index].FPoligonesType, GetFaceLength(Index),
				SGMeshToRenderIndexFormat(ArFaces[Index].FIndexFormat), nil);
			DisableFaceArrayMeterial(ArFaces[Index].FMaterial);
			end
	else
		Render.DrawArrays(FObjectPoligonesType, 0, FNOfVerts)
else
	if FQuantityFaceArrays <> 0 then
		for Index := 0 to FQuantityFaceArrays - 1 do
			begin
			InitFaceArrayMeterial(ArFaces[Index].FMaterial);
			Render.DrawElements(ArFaces[Index].FPoligonesType, GetFaceLength(Index),
				SGMeshToRenderIndexFormat(ArFaces[Index].FIndexFormat),
				ArFaces[Index].FArray);
			DisableFaceArrayMeterial(ArFaces[Index].FMaterial);
			end
	else
		Render.DrawArrays(FObjectPoligonesType, 0, FNOfVerts);
end;

procedure TSG3dObject.LoadToVBO();
var
	Index : TSGMaxEnum;
begin
if Self = nil then
	begin
	SGLog.Source('TSG3dObject(nil)__LoadToVBO().');
	Exit;
	end;

if FEnableVBO then
	begin
	SGLog.Source('TSG3dObject__LoadToVBO : It is not possible to do this several counts!');
	Exit;
	end;

Render.GenBuffersARB(1, @FVertexesBuffer);
Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB, FVertexesBuffer);
Render.BufferDataARB(SGR_ARRAY_BUFFER_ARB, FNOfVerts * GetSizeOfOneVertex(), ArVertex, SGR_STATIC_DRAW_ARB);
Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB, 0);

if FQuantityFaceArrays <> 0 then
	begin
	SetLength(FFacesBuffers, FQuantityFaceArrays);
	for Index := 0 to FQuantityFaceArrays - 1 do
		begin
		Render.GenBuffersARB(1, @FFacesBuffers[Index]);
		Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB, FFacesBuffers[Index]);
		Render.BufferDataARB(SGR_ELEMENT_ARRAY_BUFFER_ARB,
			GetFaceLength(Index) * GetFaceInt(ArFaces[Index].FIndexFormat),
			ArFaces[Index].FArray,
			SGR_STATIC_DRAW_ARB,
			SGMeshToRenderIndexFormat(ArFaces[Index].FIndexFormat));
		end;
	Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB, 0);
	end;

ClearArrays(False);
FEnableVBO := True;
end;

procedure TSG3DObject.ClearVBO(); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	Index : TSGMaxEnum;
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

end.
