{$INCLUDE Smooth.inc}

unit SmoothVertexObject;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothRenderBase
	,SmoothContextClasses
	,SmoothCommonStructs
	,SmoothMaterial
	,SmoothMatrix
	,SmoothCasesOfPrint
	;
type
	// Это тип типа хранения цветов в модели
	TS3dObjectColorType = (S3dObjectColorType3f, S3dObjectColorType4f, S3dObjectColorType3b, S3dObjectColorType4b);
	TS3dObjectIndexFormat = (S3dObjectIndexFormat1b, S3dObjectIndexFormat2b, S3dObjectIndexFormat4b);
	// Это тип типа хранения вершин в модели
	TS3dObjectVertexType = TSVertexFormat;
const
	// Типы вершин
	S3dObjectVertexType2f = SVertexFormat2f;
	S3dObjectVertexType3f = SVertexFormat3f;
	S3dObjectVertexType4f = SVertexFormat4f;
type
	TS3dObject = class;
	
	(**=========================1b===========================**)
	
	TSFaceLine1b = record
		case byte of
		0:  ( p0,p1: TSByte );
		1:  ( p:packed array [0..1] of TSByte );
		end;
	PTSFaceLine1b = ^ TSFaceLine1b;
	
    TSFaceTriangle1b = record
	case byte of
	0: ( p0, p1, p2: TSByte );
	1: ( p:packed array[0..2] of TSByte );
	2: ( v:packed array[0..2] of TSByte );
    end;
    PTSFaceTriangle1b = ^ TSFaceTriangle1b;
	
	TSFaceQuad1b = record
	case byte of
	0: ( p0, p1, p2, p3: TSByte );
	1: ( p : packed array[0..3] of TSByte );
    end;
	PTSFaceQuad1b = ^ TSFaceQuad1b;
	
	TSFacePoint1b = record
	case byte of
	0: ( p0: TSByte );
	1: ( p : packed array[0..0] of TSByte );
    end;
	PTSFacePoint1b = ^ TSFacePoint1b;
	
	(**=========================2b===========================**)
	
	TSFaceLine2b = record
		case byte of
		0:  ( p0,p1: TSWord );
		1:  ( p:packed array [0..1] of TSWord );
		end;
	PTSFaceLine2b = ^ TSFaceLine2b;
	
    TSFaceTriangle2b = record
	case byte of
	0: ( p0, p1, p2: TSWord );
	1: ( p:packed array[0..2] of TSWord );
	2: ( v:packed array[0..2] of TSWord );
    end;
    PTSFaceTriangle2b = ^ TSFaceTriangle2b;
	
	TSFaceQuad2b = record
	case byte of
	0: ( p0, p1, p2, p3: TSWord );
	1: ( p : packed array[0..3] of TSWord );
    end;
	PTSFaceQuad2b = ^ TSFaceQuad2b;
	
	TSFacePoint2b = record
	case byte of
	0: ( p0: TSWord );
	1: ( p : packed array[0..0] of TSWord );
    end;
	PTSFacePoint2b = ^ TSFacePoint2b;
	
	(**=========================4b===========================**)
	
	TSFaceLine4b = record
		case byte of
		0:  ( p0,p1: TSLongWord );
		1:  ( p:packed array [0..1] of TSLongWord );
		end;
	PTSFaceLine4b = ^ TSFaceLine4b;
	TSFaceLine = TSFaceLine4b;
	PTSFaceLine = PTSFaceLine4b;
	
    TSFaceTriangle4b = record
	case byte of
	0: ( p0, p1, p2: TSLongWord );
	1: ( p:packed array[0..2] of TSLongWord );
	2: ( v:packed array[0..2] of TSLongWord );
    end;
    PTSFaceTriangle4b = ^ TSFaceTriangle4b;
    TSFaceTriangle = TSFaceTriangle4b;
	PTSFaceTriangle = PTSFaceTriangle4b;
	
	TSFaceQuad4b = record
	case byte of
	0: ( p0, p1, p2, p3: TSLongWord );
	1: ( p : packed array[0..3] of TSLongWord );
    end;
	PTSFaceQuad4b = ^ TSFaceQuad4b;
	TSFaceQuad = TSFaceQuad4b;
	PTSFaceQuad = PTSFaceQuad4b;
	
	TSFacePoint4b = record
	case byte of
	0: ( p0: TSLongWord );
	1: ( p : packed array[0..0] of TSLongWord );
    end;
	PTSFacePoint4b = ^ TSFacePoint4b;
	TSFacePoint = TSFacePoint4b;
	PTSFacePoint = PTSFacePoint4b;
	
type
	PS3DObjectFace = ^ TS3DObjectFace;
	TS3DObjectFace = packed record 
		FIndexFormat      : TS3dObjectIndexFormat;
		FPoligonesType    : TSLongWord;
		FNOfFaces         : TSQuadWord;
		// Указательл на первый элемент области памяти, где находятся индексы
		FArray            : TSPointer;
		// Идентификатор материала
		FMaterial         : ISMaterial;
		end;
	TS3DObjectFacees = packed array of TS3DObjectFace;
type
	TS3DObjectBuffer = TSUInt32;
	TS3DObjectBufferList = TSUInt32List;
    { TS3dObject }
    // Моделька..
type
    TS3DObject = class(TSPaintableObject)
    public
        constructor Create(); override;
        destructor Destroy(); override;
        class function ClassName() : TSString; override;
    protected
        // Количество вершин
        FNOfVerts : TSQuadWord;
        
        // Есть ли у модельки текстурка
        FHasTexture : TSBoolean;
        FCountTextureFloatsInVertexArray : TSLongWord;
        // Есть ли нормали у модельки
        FHasNormals : TSBoolean;
        // Есть ли у модели цвета
        FHasColors  : TSBoolean;
        // Используется ли у модели индексированный рендеринг
        FQuantityFaceArrays : TSLongWord;
        FBumpFormat : TSBumpFormat;
    protected
        // Тип полигонов в модельки (SR_QUADS, SR_TRIANGLES, SR_LINES, SR_LINE_LOOP ....)
        FObjectPoligonesType    : TSLongWord;
        // Тип вершин в модельке
        FVertexType       : TS3dObjectVertexType;
        // Тип хранение цветов
        FColorType        : TS3dObjectColorType;
    private
		function GetSizeOfOneVertex():LongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		function GetSizeOfOneTextureCoord():TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetSizeOfOneVertexCoord():TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetSizeOfOneColorCoord():TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetSizeOfOneNormalCoord():TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		function GetCountOfOneTextureCoord():TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetCountOfOneVertexCoord():TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetCountOfOneColorCoord():TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetCountOfOneNormalCoord():TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		function GetVertexLength():QWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		procedure SetHasTexture(const VHasTexture:TSBoolean); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetQuantityFaces(const Index : TSLongWord):TSQuadWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetPoligonesType(const ArIndex : TSLongWord):TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		procedure SetPoligonesType(const ArIndex : TSLongWord;const NewPoligonesType : TSLongWord); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
	public
		procedure SetColorType(const VNewColorType:TS3dObjectColorType);
		procedure SetVertexType(const VNewVertexType:TS3dObjectVertexType);
		procedure Change3dObjectColorType4b();
    public
        // Эти свойства уже были прокоментированы выше (см на что эти свойства ссылаются)
        property CountTextureFloatsInVertexArray   : TSLongWord       read FCountTextureFloatsInVertexArray write FCountTextureFloatsInVertexArray;
        property BumpFormat                        : TSBumpFormat     read FBumpFormat          write FBumpFormat;
        property PoligonesType[Index:TSLongWord]  : TSLongWord       read GetPoligonesType     write SetPoligonesType;
		property QuantityVertexes                  : TSQuadWord       read FNOfVerts;
		property HasTexture                        : TSBoolean        read FHasTexture          write SetHasTexture;
		property HasColors                         : TSBoolean        read FHasColors           write FHasColors;
		property HasNormals                        : TSBoolean        read FHasNormals          write FHasNormals;
		property ColorType                         : TS3dObjectColorType  read FColorType           write SetColorType;
		property VertexType                        : TS3dObjectVertexType read FVertexType          write SetVertexType;
		property ObjectPoligonesType               : LongWord          read FObjectPoligonesType write FObjectPoligonesType;
    protected
        // Это массив индексов
		ArFaces : TS3DObjectFacees;
	
		// Массив вершин содерщит вершины полигонов
		//! B этом порядке содержится в памяти информация о вершине
		(* Vertex = [Vertex, Color, Normal, TexVertex] *)
		(* Array of Vertex *)
		ArVertex : TSPointer;
	public
		// Возвращает указатель на первый элемент массива вершин
		function GetArVertexes():TSPointer; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		// Возвращает указатель на первый элемент массива индексов
		function GetArFaces(const Index : LongWord = 0):TSPointer; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
	private
		function GetVertex3f(const Index : TSMaxEnum):PSVertex3f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetVertex2f(const Index : TSMaxEnum):PSVertex2f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetVertex4f(const Index : TSMaxEnum):PSVertex4f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		function GetObjectFace(const Index : TSMaxEnum = 0) : PS3DObjectFace; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
	public
		// Эти совйтсва возвращают указатель на Index-ый элемент массива вершин 
		//! Это можно пользоваться только когда, когда VertexType = S3dObjectVertexType3f, иначе Result = nil
		property ArVertex3f[Index : TSMaxEnum]:PSVertex3f read GetVertex3f;
		//! Это можно пользоваться только когда, когда VertexType = S3dObjectVertexType2f, иначе Result = nil
		property ArVertex2f[Index : TSMaxEnum]:PSVertex2f read GetVertex2f;
		//! Это можно пользоваться только когда, когда VertexType = S3dObjectVertexType4f, иначе Result = nil
		property ArVertex4f[Index : TSMaxEnum]:PSVertex4f read GetVertex4f;
		
		// Добавляет пустую(ые) вершины в массив вершин
		procedure AddVertex(const QuantityNewVertexes : LongWord = 1);
		
		procedure SetVertex(const VVertexIndex : TSUInt32; const x, y : TSFloat32; const z : TSFloat32 = 0; const w : TSFloat32 = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure SetVertex(const VVertexIndex : TSUInt32; const v2 : TSVector2f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		
		// Добавляет еще элемент(ы) в массив индексов
		procedure AddFace(const ArIndex:TSLongWord;const FQuantityNewFaces:LongWord = 1);
		property ObjectFace[Index : TSMaxEnum] : PS3DObjectFace read GetObjectFace;
		function LastObjectFace() : PS3DObjectFace; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
	private
		function GetColor3f(const Index:TSMaxEnum):PSColor3f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetColor4f(const Index:TSMaxEnum):PSColor4f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetColor3b(const Index:TSMaxEnum):PSColor3b; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetColor4b(const Index:TSMaxEnum):PSColor4b; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
	public
		// Возвращает указатель на структуру данных,
		// к которой хранится информация о цвете вершины с индексом Index
		// Каждую функцию можно использовать только когда установлен соответствующий тип формата цветов
		// Иначе Result = nil.
		(* Для установки цвета лучше использовать процедуру SetColor, описанную ниже *)
		property ArColor3f[Index : TSMaxEnum]:PSColor3f read GetColor3f;
		property ArColor4f[Index : TSMaxEnum]:PSColor4f read GetColor4f;
		property ArColor3b[Index : TSMaxEnum]:PSColor3b read GetColor3b;
		property ArColor4b[Index : TSMaxEnum]:PSColor4b read GetColor4b;
		
		// Эта процедура устанавливает цвет вершины. Работает для любого формата хранение цвета.
		procedure SetColor(const Index:TSMaxEnum;const r,g,b:TSSingle; const a:TSSingle = 1); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;
		procedure SetColor(const Index:TSMaxEnum; const Color : TSVector3f); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;
		procedure SetColor(const Index:TSMaxEnum; const Color : TSVector4f); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;
		function GetColor(const Index:TSMaxEnum) : TSColor4f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		// Автоматически определяет нужный формат хранения цветов. (В зависимости от рендера)
		procedure AutoSetColorType(const VWithAlpha:Boolean = False); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		procedure AutoSetIndexFormat(const ArIndex : TSLongWord; const MaxVertexLength : TSQuadWord );
	private
		function GetNormal(const Index:TSMaxEnum):PSVertex3f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
	
	public
		// Свойство для редактирования нормалей
		property ArNormal[Index : TSMaxEnum]:PSVertex3f read GetNormal;
		
	private
		function GetTexVertex(const Index : TSMaxEnum): PSVertex2f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetTexVertex3f(const Index : TSMaxEnum): PSVertex3f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function GetTexVertex4f(const Index : TSMaxEnum): PSVertex4f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
	public
		property ArTexVertex[Index : TSMaxEnum] : PSVertex2f read GetTexVertex;
		property ArTexVertex2f[Index : TSMaxEnum] : PSVertex2f read GetTexVertex;
		property ArTexVertex3f[Index : TSMaxEnum] : PSVertex3f read GetTexVertex3f;
		property ArTexVertex4f[Index : TSMaxEnum] : PSVertex4f read GetTexVertex4f;
		
		// Устанавливает количество вершин
		procedure SetVertexLength(const NewVertexLength:TSQuadWord); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		// Возвращает сколько в байтах занимают массив вершин
		function GetVertexesSize():TSMaxEnum;overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		// Эта процедура для DirectX. Дело в том, что там нету SR_QUADS. Так что он разбивается на 2 треугольника.
		procedure SetFaceQuad(const ArIndex:TSLongWord;const Index :TSMaxEnum; const p0,p1,p2,p3:TSLongWord);
		procedure SetFaceTriangle(const ArIndex:TSLongWord;const Index :TSMaxEnum; const p0,p1,p2:TSLongWord);
		procedure SetFaceLine(const ArIndex:TSLongWord;const Index :TSMaxEnum; const p0,p1:TSLongWord);
		procedure SetFacePoint(const ArIndex:TSLongWord;const Index :TSMaxEnum; const p0:TSLongWord);
		
		// Возвращает индекс на первый элемент массива индексов. Не просто возвращает, а хитро возвращает.
		// Теперь эти функции можно использовать как массивы. Так что их очень просто использовать.
		// Но нужно соблюдать тип хранения индексов
		function ArFacesLines1b(const Index:TSLongWord = 0)     : PTSFaceLine1b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesQuads1b(const Index:TSLongWord = 0)     : PTSFaceQuad1b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesTriangles1b(const Index:TSLongWord = 0) : PTSFaceTriangle1b;  {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesPoints1b(const Index:TSLongWord = 0)    : PTSFacePoint1b;     {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		function ArFacesLines2b(const Index:TSLongWord = 0)     : PTSFaceLine2b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesQuads2b(const Index:TSLongWord = 0)     : PTSFaceQuad2b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesTriangles2b(const Index:TSLongWord = 0) : PTSFaceTriangle2b;  {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesPoints2b(const Index:TSLongWord = 0)    : PTSFacePoint2b;     {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		function ArFacesLines4b(const Index:TSLongWord = 0)     : PTSFaceLine4b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesQuads4b(const Index:TSLongWord = 0)     : PTSFaceQuad4b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesTriangles4b(const Index:TSLongWord = 0) : PTSFaceTriangle4b;  {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesPoints4b(const Index:TSLongWord = 0)    : PTSFacePoint4b;     {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		function ArFacesLines(const ArIndex:TSLongWord = 0;const Index:TSLongWord = 0)     : TSFaceLine;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesQuads(const ArIndex:TSLongWord = 0;const Index:TSLongWord = 0)     : TSFaceQuad;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesTriangles(const ArIndex:TSLongWord = 0;const Index:TSLongWord = 0) : TSFaceTriangle;  {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function ArFacesPoints(const ArIndex:TSLongWord = 0;const Index:TSLongWord = 0)    : TSFacePoint;     {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		
		procedure SetFaceArLength(const NewArLength : TSLongWord);
		procedure AddFaceArray(const QuantityNewArrays : TSLongWord = 1);
		// Устанавливает длинну массива индексов
		procedure SetFaceLength(const ArIndex:TSLongWord;const NewLength:TSQuadWord); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		// Возвращает действительную длинну массива индексов
		function GetFaceLength(const Index:TSLongWord):TSQuadWord;overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		// Возвращает действительную длинну массива индексов в зависимости он их длинны и их типа, заданых параметрами
		class function GetFaceLength(const FaceLength:TSQuadWord; const ThisPoligoneType:LongWord):TSQuadWord;overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		// Возвращает, сколько в TSFaceType*Result байтов занимает одна структура индексов. Очень прикольная функция.
		class function GetPoligoneInt(const ThisPoligoneType:LongWord):Byte; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		class function GetFaceInt(const ThisFaceFormat : TS3dObjectIndexFormat):Byte; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
	public
		// Ствойства для получения и редактирования длинн массивов
		property QuantityFaceArrays       : TSLongWord read FQuantityFaceArrays  write SetFaceArLength;
		property Faces[Index:TSLongWord] : TSQuadWord read GetQuantityFaces     write SetFaceLength;
		property Vertexes                 : TSQuadWord read GetVertexLength      write SetVertexLength;
		property RealQuantityFaces[Index : TSLongWord]: TSQuadWord   read GetFaceLength;
    protected
		// Задействован ли VBO
		// VBO - Vertex Buffer Object
		// Vertex Buffer Object - это технология, при которой можно отображать обьекты на экране, 
		//    держа все массивы в памяти видеокарты, а не в оперативной памяти
		// Если на вашем устройстве нет видеокарты ("нетбук" и прочее), то массивы будут "копироваться в оперативную память"
		FEnableVBO      : TSBoolean;
		
		// Идентификатор массива вершин в памяти видеокарты
        FVertexesBuffer    : TS3DObjectBuffer;
        // Идентификатор массива индексов в памяти видеокарты
        FFacesBuffers      : TS3DObjectBufferList;
        
		// Включен ли Cull Face
        FEnableCullFace : TSBoolean;
        FEnableCullFaceFront, FEnableCullFaceBack : TSBoolean;
        // Цвет обьекта
        FObjectColor    : TSColor4f;
    public
		property EnableVBO      : TSBoolean read FEnableVBO      write FEnableVBO;
		property ObjectColor    : TSColor4f read FObjectColor    write FObjectColor;
		property EnableCullFace : TSBoolean read FEnableCullFace write FEnableCullFace;
		property EnableCullFaceFront : TSBoolean read FEnableCullFaceFront write FEnableCullFaceFront;
		property EnableCullFaceBack  : TSBoolean read FEnableCullFaceBack  write FEnableCullFaceBack;
    public
        procedure Paint(); override;
        // Когда включен Cull Face, то Draw нужно делать 2 раза.
        // Так что вод тут делается Draw, а в Draw просто проверяется, включен или не  Cull Face, 
        //   и в зависимости от этого он вызывает эту процедуду 1 или 2 раза
        procedure InitAttributes();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
        procedure DisableAttributes();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
        procedure BasicDraw(); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
        procedure BasicDrawWithAttributes();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
        // Загрузка массивов в память видеокарты
        procedure LoadToVBO(const ClearAfterLoad : TSBoolean = True);
        // Очищение памяти видеокарты от массивов этого класса
        procedure ClearVBO();
        // Процедурка очищает оперативную память от массивов этого класса
        procedure ClearArrays(const ClearN:Boolean = True);
			public
        // Эта процедурка автоматически выделяет память под нормали и вычесляет их, исходя из данных вершин
        procedure AddNormals();virtual;
        
        (* Я ж переписывал этот класс. Это то, что я не написал. *)
		//procedure Stripificate;overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		//procedure Stripificate(var VertexesAndTriangles:TSArTSArTSFaceType;var OutputStrip:TSArTSFaceType);overload;
		
		// Выводит полную информацию о характеристиках модельки
		procedure WriteInfo(const PredStr : TSString = ''; const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog]);
	public
		// Возвращает, сколько занимают байтов вершины
		function VertexesSize():QWord;Inline;
		// Возвращает, сколько занимают байтов индексы
		function FacesSize():QWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		// Возвращает, сколько занимают байтов вершины и индексы
		function Size():QWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
	protected 
		// Имя модельки
		FName : TSString;
		FObjectMaterial : ISMaterial;
		
		FEnableObjectMatrix : TSBoolean;
		FObjectMatrix : TSMatrix4x4;
	public
		property ObjectMatrixEnabled : TSBoolean read FEnableObjectMatrix;
		procedure SetMatrix(const Matrix : TSMatrix4x4);
	public
		// Свойство : Имя модельки
		property Name             : TSString      read FName             write FName;
		// Свойство : Идентификатор материала
		property ObjectMaterial   : ISMaterial    read FObjectMaterial   write FObjectMaterial;
		property ObjectMatrix     : TSMatrix4x4   read FObjectMatrix     write SetMatrix;
	public
		procedure CopyTo(const Destination : TS3dObject);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
    end;

    PS3dObject = ^ TS3dObject;

function SStr3dObjectIndexFormat(const IndexFormat : TS3dObjectIndexFormat) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SStr3dObjectColorFormat(const ColorFormat : TS3dObjectColorType) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function S3dObjectToRenderIndexFormat(const IndexFormat : TS3dObjectIndexFormat) : TSUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SKill(var O : TS3DObject); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothStringUtils
	,SmoothLog
	,SmoothMathUtils
	,SmoothCommon
	,SmoothBaseUtils
	
	,Crt
	;

function S3dObjectToRenderIndexFormat(const IndexFormat : TS3dObjectIndexFormat) : TSUInt32; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case IndexFormat of
S3dObjectIndexFormat1b : Result := SR_UNSIGNED_BYTE;
S3dObjectIndexFormat2b : Result := SR_UNSIGNED_SHORT;
S3dObjectIndexFormat4b : Result := SR_UNSIGNED_INT;
else                  Result := 0;
end;
end;

procedure SKill(var O : TS3DObject); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if O <> nil then
	begin
	O.Destroy();
	O := nil;
	end;
end;

function SStr3dObjectColorFormat(const ColorFormat : TS3dObjectColorType) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case ColorFormat of
S3dObjectColorType3b : Result := 'S3dObjectColorFormat3b';
S3dObjectColorType4b : Result := 'S3dObjectColorFormat4b';
S3dObjectColorType3f : Result := 'S3dObjectColorFormat3f';
S3dObjectColorType4f : Result := 'S3dObjectColorFormat4f';
else                Result := 'INVALID(' + SStr(TSByte(ColorFormat)) + ')';
end;
end;

function SStr3dObjectIndexFormat(const IndexFormat : TS3dObjectIndexFormat) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case IndexFormat of
S3dObjectIndexFormat1b : Result := 'S3dObjectIndexFormat1b';
S3dObjectIndexFormat2b : Result := 'S3dObjectIndexFormat2b';
S3dObjectIndexFormat4b : Result := 'S3dObjectIndexFormat4b';
else                  Result := 'INVALID(' + SStr(TSByte(IndexFormat)) + ')';
end;
end;

// Vertex Object

function TS3DObject.ArFacesLines(const ArIndex:TSLongWord = 0;const Index:TSLongWord = 0)     : TSFaceLine;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
FillChar(Result,SizeOf(Result),0);
case ArFaces[ArIndex].FIndexFormat of
S3dObjectIndexFormat1b: 
	begin
	Result.p0:=PTSFaceLine1b(ArFaces[ArIndex].FArray)[Index].p0;
	Result.p1:=PTSFaceLine1b(ArFaces[ArIndex].FArray)[Index].p1;
	end;
S3dObjectIndexFormat2b: 
	begin
	Result.p0:=PTSFaceLine2b(ArFaces[ArIndex].FArray)[Index].p0;
	Result.p1:=PTSFaceLine2b(ArFaces[ArIndex].FArray)[Index].p1;
	end;
S3dObjectIndexFormat4b: 
	begin
	Result.p0:=PTSFaceLine4b(ArFaces[ArIndex].FArray)[Index].p0;
	Result.p1:=PTSFaceLine4b(ArFaces[ArIndex].FArray)[Index].p1;
	end;
end;
end;

function TS3DObject.ArFacesQuads(const ArIndex:TSLongWord = 0;const Index:TSLongWord = 0)     : TSFaceQuad;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
FillChar(Result, SizeOf(Result), 0);
if Render.RenderType <> SRenderOpenGL then
	case ArFaces[ArIndex].FIndexFormat of
	S3dObjectIndexFormat1b: 
		begin
		Result.p0:=ArFacesTriangles1b(ArIndex)[Index*2].p[0];
		Result.p1:=ArFacesTriangles1b(ArIndex)[Index*2].p[1];
		Result.p2:=ArFacesTriangles1b(ArIndex)[Index*2].p[2];
		Result.p3:=ArFacesTriangles1b(ArIndex)[Index*2+1].p[1];
		end;
	S3dObjectIndexFormat2b: 
		begin
		Result.p0:=ArFacesTriangles2b(ArIndex)[Index*2].p[0];
		Result.p1:=ArFacesTriangles2b(ArIndex)[Index*2].p[1];
		Result.p2:=ArFacesTriangles2b(ArIndex)[Index*2].p[2];
		Result.p3:=ArFacesTriangles2b(ArIndex)[Index*2+1].p[1];
		end;
	S3dObjectIndexFormat4b: 
		begin
		Result.p0:=ArFacesTriangles4b(ArIndex)[Index*2].p[0];
		Result.p1:=ArFacesTriangles4b(ArIndex)[Index*2].p[1];
		Result.p2:=ArFacesTriangles4b(ArIndex)[Index*2].p[2];
		Result.p3:=ArFacesTriangles4b(ArIndex)[Index*2+1].p[1];
		end;
	end
else
	case ArFaces[ArIndex].FIndexFormat of
	S3dObjectIndexFormat1b: 
		begin
		Result.p0:=ArFacesQuads1b(ArIndex)[Index].p[0];
		Result.p1:=ArFacesQuads1b(ArIndex)[Index].p[1];
		Result.p2:=ArFacesQuads1b(ArIndex)[Index].p[2];
		Result.p3:=ArFacesQuads1b(ArIndex)[Index].p[3];
		end;
	S3dObjectIndexFormat2b:
		begin
		Result.p0:=ArFacesQuads2b(ArIndex)[Index].p[0];
		Result.p1:=ArFacesQuads2b(ArIndex)[Index].p[1];
		Result.p2:=ArFacesQuads2b(ArIndex)[Index].p[2];
		Result.p3:=ArFacesQuads2b(ArIndex)[Index].p[3];
		end;
	S3dObjectIndexFormat4b:
		begin
		Result.p0:=ArFacesQuads4b(ArIndex)[Index].p[0];
		Result.p1:=ArFacesQuads4b(ArIndex)[Index].p[1];
		Result.p2:=ArFacesQuads4b(ArIndex)[Index].p[2];
		Result.p3:=ArFacesQuads4b(ArIndex)[Index].p[3];
		end;
	end;
end;

function TS3DObject.ArFacesTriangles(const ArIndex:TSLongWord = 0;const Index:TSLongWord = 0) : TSFaceTriangle;  {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
FillChar(Result,SizeOf(Result),0);
case ArFaces[ArIndex].FIndexFormat of
S3dObjectIndexFormat1b: 
	begin
	Result.p0:=PTSFaceTriangle1b(ArFaces[ArIndex].FArray)[Index].p0;
	Result.p1:=PTSFaceTriangle1b(ArFaces[ArIndex].FArray)[Index].p1;
	Result.p2:=PTSFaceTriangle1b(ArFaces[ArIndex].FArray)[Index].p2;
	end;
S3dObjectIndexFormat2b: 
	begin
	Result.p0:=PTSFaceTriangle2b(ArFaces[ArIndex].FArray)[Index].p0;
	Result.p1:=PTSFaceTriangle2b(ArFaces[ArIndex].FArray)[Index].p1;
	Result.p2:=PTSFaceTriangle2b(ArFaces[ArIndex].FArray)[Index].p2;
	end;
S3dObjectIndexFormat4b: 
	begin
	Result.p0:=PTSFaceTriangle4b(ArFaces[ArIndex].FArray)[Index].p0;
	Result.p1:=PTSFaceTriangle4b(ArFaces[ArIndex].FArray)[Index].p1;
	Result.p2:=PTSFaceTriangle4b(ArFaces[ArIndex].FArray)[Index].p2;
	end;
end;
end;

function TS3DObject.ArFacesPoints(const ArIndex:TSLongWord = 0;const Index:TSLongWord = 0)    : TSFacePoint;     {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
FillChar(Result,SizeOf(Result),0);
case ArFaces[ArIndex].FIndexFormat of
S3dObjectIndexFormat1b:
	Result.p0:=PTSFacePoint1b(ArFaces[ArIndex].FArray)[Index].p0;
S3dObjectIndexFormat2b:
	Result.p0:=PTSFacePoint2b(ArFaces[ArIndex].FArray)[Index].p0;
S3dObjectIndexFormat4b:
	Result.p0:=PTSFacePoint4b(ArFaces[ArIndex].FArray)[Index].p0;
end;
end;

procedure TS3DObject.SetPoligonesType(const ArIndex : TSLongWord;const NewPoligonesType : TSLongWord); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
ArFaces[ArIndex].FPoligonesType:=NewPoligonesType;
end;

function TS3DObject.GetPoligonesType(const ArIndex : TSLongWord):TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=ArFaces[ArIndex].FPoligonesType;
end;

procedure TS3DObject.AutoSetIndexFormat(const ArIndex : TSLongWord; const MaxVertexLength : TSQuadWord );
begin
if (MaxVertexLength<=255) and (Render.RenderType=SRenderOpenGL) then
	ArFaces[ArIndex].FIndexFormat:=S3dObjectIndexFormat1b
else if (MaxVertexLength<=255*255) or (Render.RenderType=SRenderDirectX9) or (Render.RenderType=SRenderDirectX8) then
	ArFaces[ArIndex].FIndexFormat:=S3dObjectIndexFormat2b
else 
	ArFaces[ArIndex].FIndexFormat:=S3dObjectIndexFormat4b;
end;

procedure TS3DObject.SetFaceTriangle(const ArIndex:TSLongWord;const Index :TSMaxEnum; const p0,p1,p2:TSLongWord);
begin
case ArFaces[ArIndex].FIndexFormat of
S3dObjectIndexFormat1b: 
	begin
	ArFacesTriangles1b(ArIndex)[Index].p[0]:=p0;
	ArFacesTriangles1b(ArIndex)[Index].p[1]:=p1;
	ArFacesTriangles1b(ArIndex)[Index].p[2]:=p2;
	end;
S3dObjectIndexFormat2b: 
	begin
	ArFacesTriangles2b(ArIndex)[Index].p[0]:=p0;
	ArFacesTriangles2b(ArIndex)[Index].p[1]:=p1;
	ArFacesTriangles2b(ArIndex)[Index].p[2]:=p2;
	end;
S3dObjectIndexFormat4b: 
	begin
	ArFacesTriangles4b(ArIndex)[Index].p[0]:=p0;
	ArFacesTriangles4b(ArIndex)[Index].p[1]:=p1;
	ArFacesTriangles4b(ArIndex)[Index].p[2]:=p2;
	end;
end;
end;

procedure TS3DObject.SetFaceLine(const ArIndex:TSLongWord;const Index :TSMaxEnum; const p0,p1:TSLongWord);
begin
case ArFaces[ArIndex].FIndexFormat of
S3dObjectIndexFormat1b: 
	begin
	ArFacesLines1b(ArIndex)[Index].p[0]:=p0;
	ArFacesLines1b(ArIndex)[Index].p[1]:=p1;
	end;
S3dObjectIndexFormat2b: 
	begin
	ArFacesLines2b(ArIndex)[Index].p[0]:=p0;
	ArFacesLines2b(ArIndex)[Index].p[1]:=p1;
	end;
S3dObjectIndexFormat4b: 
	begin
	ArFacesLines4b(ArIndex)[Index].p[0]:=p0;
	ArFacesLines4b(ArIndex)[Index].p[1]:=p1;
	end;
end;
end;

procedure TS3DObject.SetFacePoint(const ArIndex:TSLongWord;const Index :TSMaxEnum; const p0:TSLongWord);
begin
case ArFaces[ArIndex].FIndexFormat of
S3dObjectIndexFormat1b:
	ArFacesPoints1b(ArIndex)[Index].p[0]:=p0;
S3dObjectIndexFormat2b:
	ArFacesPoints2b(ArIndex)[Index].p[0]:=p0;
S3dObjectIndexFormat4b:
	ArFacesPoints4b(ArIndex)[Index].p[0]:=p0;
end;
end;

procedure TS3DObject.SetFaceArLength(const NewArLength : TSLongWord);
var
	Index : TSLongWord;
begin
if (FQuantityFaceArrays >= NewArLength) then
	Exit;
SetLength(ArFaces, NewArLength);
for Index := FQuantityFaceArrays to NewArLength - 1 do
	begin
	ArFaces[Index].FMaterial      := nil;
	ArFaces[Index].FIndexFormat   := S3dObjectIndexFormat2b;
	ArFaces[Index].FPoligonesType := SR_TRIANGLES;
	ArFaces[Index].FArray         := nil;
	ArFaces[Index].FNOfFaces      := 0;
	end;
FQuantityFaceArrays := NewArLength;
end;

procedure TS3DObject.AddFaceArray(const QuantityNewArrays : TSLongWord = 1);
begin
SetFaceArLength(FQuantityFaceArrays+QuantityNewArrays);
end;

class function  TS3DObject.GetFaceInt(const ThisFaceFormat : TS3dObjectIndexFormat):Byte; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=
	TSByte(ThisFaceFormat=S3dObjectIndexFormat1b)+
	TSByte(ThisFaceFormat=S3dObjectIndexFormat2b)*2+
	TSByte(ThisFaceFormat=S3dObjectIndexFormat4b)*4;
end;

function TS3DObject.GetQuantityFaces(const Index : TSLongWord):TSQuadWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := ArFaces[Index].FNOfFaces;
end;

procedure TS3DObject.SetHasTexture(const VHasTexture:TSBoolean); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
FHasTexture:=VHasTexture;
end;

function TS3DObject.GetVertexLength():QWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=FNOfVerts;
end;

procedure TS3DObject.SetFaceQuad(const ArIndex:TSLongWord;const Index :TSMaxEnum; const p0,p1,p2,p3:TSLongWord);
begin
if Render.RenderType<>SRenderOpenGL then
	begin
	case ArFaces[ArIndex].FIndexFormat of
	S3dObjectIndexFormat1b:
		begin
		ArFacesTriangles1b(ArIndex)[Index*2].p[0]:=p0;
		ArFacesTriangles1b(ArIndex)[Index*2].p[1]:=p1;
		ArFacesTriangles1b(ArIndex)[Index*2].p[2]:=p2;
		ArFacesTriangles1b(ArIndex)[Index*2+1].p[0]:=p2;
		ArFacesTriangles1b(ArIndex)[Index*2+1].p[1]:=p3;
		ArFacesTriangles1b(ArIndex)[Index*2+1].p[2]:=p0;
		end;
	S3dObjectIndexFormat2b:
		begin
		ArFacesTriangles2b(ArIndex)[Index*2].p[0]:=p0;
		ArFacesTriangles2b(ArIndex)[Index*2].p[1]:=p1;
		ArFacesTriangles2b(ArIndex)[Index*2].p[2]:=p2;
		ArFacesTriangles2b(ArIndex)[Index*2+1].p[0]:=p2;
		ArFacesTriangles2b(ArIndex)[Index*2+1].p[1]:=p3;
		ArFacesTriangles2b(ArIndex)[Index*2+1].p[2]:=p0;
		end;
	S3dObjectIndexFormat4b:
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
	S3dObjectIndexFormat1b:
		begin
		ArFacesQuads1b(ArIndex)[Index].p[0]:=p0;
		ArFacesQuads1b(ArIndex)[Index].p[1]:=p1;
		ArFacesQuads1b(ArIndex)[Index].p[2]:=p2;
		ArFacesQuads1b(ArIndex)[Index].p[3]:=p3;
		end;
	S3dObjectIndexFormat2b:
		begin
		ArFacesQuads2b(ArIndex)[Index].p[0]:=p0;
		ArFacesQuads2b(ArIndex)[Index].p[1]:=p1;
		ArFacesQuads2b(ArIndex)[Index].p[2]:=p2;
		ArFacesQuads2b(ArIndex)[Index].p[3]:=p3;
		end;
	S3dObjectIndexFormat4b:
		begin
		ArFacesQuads4b(ArIndex)[Index].p[0]:=p0;
		ArFacesQuads4b(ArIndex)[Index].p[1]:=p1;
		ArFacesQuads4b(ArIndex)[Index].p[2]:=p2;
		ArFacesQuads4b(ArIndex)[Index].p[3]:=p3;
		end;
	end;
	end;
end;

procedure TS3DObject.AddNormals();
var
	SecondArVertex:Pointer = nil;
	i,ii,iiii,iii:TSMaxEnum;
	ArPoligonesNormals:packed array of TSVertex3f = nil;
	Plane:TSPlane3D;
	Vertex:TSVertex3f;
begin
if (FObjectPoligonesType<>SR_TRIANGLES) then
	Exit;
if FQuantityFaceArrays<>0 then
	for i := 0 to FQuantityFaceArrays - 1 do
		if ArFaces[i].FPoligonesType<>SR_TRIANGLES then
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
					3*SizeOf(TSSingle)],
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
	Plane := SPlane3DFrom3Points(
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

procedure TS3DObject.AddFace(const ArIndex:TSLongWord;const FQuantityNewFaces:LongWord = 1);
begin
SetFaceLength(ArIndex,Faces[ArIndex]+FQuantityNewFaces);
end;

procedure TS3DObject.AddVertex(const QuantityNewVertexes : LongWord = 1);
begin
FNOfVerts += QuantityNewVertexes;
ReAllocMem(ArVertex, GetVertexesSize());
end;

procedure TS3DObject.Change3dObjectColorType4b(); // BGRA to RGBA
var
	i : TSMaxEnum;
	c : byte;
begin
for i:=0 to Vertexes - 1 do
	begin
	c:=ArColor4b[i]^.r;
	ArColor4b[i]^.r:=ArColor4b[i]^.b;
	ArColor4b[i]^.b:=c;
	end;
end;

procedure TS3DObject.AutoSetColorType(const VWithAlpha:Boolean = False); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if Render<>nil then
	begin
	if Render.RenderType=SRenderOpenGL then
		begin
		if VWithAlpha then
			SetColorType(S3dObjectColorType4f)
		else
			SetColorType(S3dObjectColorType3f);
		end
	else
		begin
		SetColorType(S3dObjectColorType4b);
		end;
	end;
end;

function TS3DObject.GetColor(const Index:TSMaxEnum) : TSColor4f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result.Import();
if (FColorType=S3dObjectColorType3f) then
	begin
	Result.Import(ArColor3f[Index]^.r, ArColor3f[Index]^.g, ArColor3f[Index]^.b, 1);
	end
else if (FColorType=S3dObjectColorType4f) then
	begin
	Result.Import(ArColor4f[Index]^.r, ArColor4f[Index]^.g, ArColor4f[Index]^.b, ArColor4f[Index]^.a);
	end
else if (FColorType=S3dObjectColorType3b) then
	begin
	Result.Import(ArColor3b[Index]^.r / 255, ArColor3b[Index]^.g / 255, ArColor3b[Index]^.b / 255, 1);
	end
else if (FColorType=S3dObjectColorType4b) then
	begin
	if (Render.RenderType = SRenderDirectX9) or (Render.RenderType = SRenderDirectX8) then
		begin
		Result.Import(ArColor4b[Index]^.r / 255, ArColor4b[Index]^.g / 255, ArColor4b[Index]^.b / 255, ArColor4b[Index]^.a / 255);
		end
	else
		begin
		Result.Import(ArColor4b[Index]^.b / 255, ArColor4b[Index]^.g / 255, ArColor4b[Index]^.r / 255, ArColor4b[Index]^.a / 255);
		end;
	end;
end;

procedure TS3DObject.SetVertex(const VVertexIndex : TSUInt32; const v2 : TSVector2f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if FVertexType = S3dObjectVertexType2f then
	ArVertex2f[VVertexIndex]^ := v2
else if FVertexType = S3dObjectVertexType3f then
	ArVertex3f[VVertexIndex]^.Import(v2.x, v2.y)
else if FVertexType = S3dObjectVertexType4f then
	ArVertex4f[VVertexIndex]^.Import(v2.x, v2.y);
end;

procedure TS3DObject.SetVertex(const VVertexIndex : TSUInt32; const x, y : TSFloat32; const z : TSFloat32 = 0; const w : TSFloat32 = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if FVertexType = S3dObjectVertexType2f then
	ArVertex2f[VVertexIndex]^.Import(x, y)
else if FVertexType = S3dObjectVertexType3f then
	ArVertex3f[VVertexIndex]^.Import(x, y, z)
else if FVertexType = S3dObjectVertexType4f then
	ArVertex4f[VVertexIndex]^.Import(x, y, z, w);
end;

procedure TS3DObject.SetColor(const Index:TSMaxEnum; const Color : TSVector3f); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;
begin
SetColor(Index, Color.r, Color.g, Color.b);
end;

procedure TS3DObject.SetColor(const Index:TSMaxEnum; const Color : TSVector4f); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;
begin
SetColor(Index, Color.r, Color.g, Color.b, Color.a);
end;

procedure TS3DObject.SetColor(const Index:TSMaxEnum;const r,g,b:Single; const a:Single = 1); {$IFDEF SUPPORTINLINE} inline; {$ENDIF} overload;

function Convert(const Value : TSFloat32) : TSByte; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (Value >= 1) then
	Result := 255
else if (Value > 0) then
	Result := Round(Value * 255)
else
	Result := 0;
end;

begin
if (FColorType=S3dObjectColorType3f) then
	begin
	ArColor3f[Index]^.r:=r;
	ArColor3f[Index]^.g:=g;
	ArColor3f[Index]^.b:=b;
	end
else if (FColorType=S3dObjectColorType4f) then
	begin
	ArColor4f[Index]^.r:=r;
	ArColor4f[Index]^.g:=g;
	ArColor4f[Index]^.b:=b;
	ArColor4f[Index]^.a:=a;
	end
else if (FColorType=S3dObjectColorType3b) then
	begin
	ArColor3b[Index]^.r := Convert(r);
	ArColor3b[Index]^.g := Convert(g);
	ArColor3b[Index]^.b := Convert(b);
	end
else if (FColorType=S3dObjectColorType4b) then
	begin 
	if (Render.RenderType = SRenderDirectX9) or (Render.RenderType = SRenderDirectX8) then
		begin
		ArColor4b[Index]^.b := Convert(r);
		ArColor4b[Index]^.r := Convert(b);
		end
	else
		begin
		ArColor4b[Index]^.r := Convert(r);
		ArColor4b[Index]^.b := Convert(b);
		end;
	ArColor4b[Index]^.g := Convert(g);
	ArColor4b[Index]^.a := Convert(a);
	end;
end;

function TS3DObject.GetTexVertex3f(const Index : TSMaxEnum): PSVertex3f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSVertex3f(
	TSMaxEnum(ArVertex)
	+GetSizeOfOneVertex()*Index
	+GetSizeOfOneVertexCoord()
	+GetSizeOfOneColorCoord()
	+GetSizeOfOneNormalCoord());
end;

function TS3DObject.GetTexVertex4f(const Index : TSMaxEnum): PSVertex4f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSVertex4f(
	TSMaxEnum(ArVertex)
	+GetSizeOfOneVertex()*Index
	+GetSizeOfOneVertexCoord()
	+GetSizeOfOneColorCoord()
	+GetSizeOfOneNormalCoord());
end;

function TS3DObject.GetTexVertex(const Index : TSMaxEnum): PSVertex2f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSVertex2f(
	TSMaxEnum(ArVertex)
	+GetSizeOfOneVertex()*Index
	+GetSizeOfOneVertexCoord()
	+GetSizeOfOneColorCoord()
	+GetSizeOfOneNormalCoord());
end;

function TS3DObject.GetNormal(const Index:TSMaxEnum):PSVertex3f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSVertex3f( 
	TSMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index
	+GetSizeOfOneVertexCoord()
	+GetSizeOfOneColorCoord());
end;

function TS3DObject.GetColor4f(const Index:TSMaxEnum):PSColor4f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSColor4f( 
	TSMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	GetSizeOfOneVertexCoord());
end;

function TS3DObject.GetColor3b(const Index:TSMaxEnum):PSColor3b; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSColor3b( 
	TSMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	GetSizeOfOneVertexCoord());
end;

function TS3DObject.GetColor4b(const Index:TSMaxEnum):PSColor4b; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSColor4b(Pointer(
	TSMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	GetSizeOfOneVertexCoord()));
end;

function TS3DObject.GetColor3f(const Index:TSMaxEnum):PSColor3f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSColor3f( 
	TSMaxEnum(ArVertex)+
	GetSizeOfOneVertex()*Index+
	GetSizeOfOneVertexCoord());
end;

function TS3DObject.GetArFaces(const Index : LongWord = 0):Pointer; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if ArFaces=nil then
	Result:=nil
else
	Result:=@ArFaces[Index].FArray;
end;

function TS3DObject.LastObjectFace() : PS3DObjectFace; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces = nil) or (FQuantityFaceArrays = 0) then
	Result := nil
else
	Result := @ArFaces[FQuantityFaceArrays - 1];
end;

function TS3DObject.GetObjectFace(const Index : TSMaxEnum = 0) : PS3DObjectFace; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces = nil) or (FQuantityFaceArrays = 0) then
	Result := nil
else
	Result := @ArFaces[Index];
end;

function TS3DObject.GetArVertexes():Pointer; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := ArVertex;
end;

procedure TS3DObject.SetVertexType(const VNewVertexType:TS3dObjectVertexType);
begin
FVertexType:=VNewVertexType;
end;

procedure TS3DObject.SetColorType(const VNewColorType:TS3dObjectColorType);
begin
FHasColors:=True;
FColorType:=VNewColorType;
end;

procedure TS3DObject.SetVertexLength(const NewVertexLength:QWord); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
FNOfVerts:=NewVertexLength;
if ArVertex = nil then
	GetMem(ArVertex,GetVertexesSize())
else
	ReallocMem(ArVertex,GetVertexesSize());
end;

function TS3DObject.GetCountOfOneTextureCoord():TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := Byte(FHasTexture)*FCountTextureFloatsInVertexArray;
end;

function TS3DObject.GetCountOfOneVertexCoord():TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := (2 + Byte(FVertexType=S3dObjectVertexType3f) + 2 * Byte(FVertexType = S3dObjectVertexType4f));
end;

function TS3DObject.GetCountOfOneColorCoord():TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := Byte(FHasColors)*(3+byte((FColorType=S3dObjectColorType4b) xor (FColorType=S3dObjectColorType4f)));
end;

function TS3DObject.GetCountOfOneNormalCoord():TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := Byte(FHasNormals)*3;
end;

function TS3DObject.GetSizeOfOneTextureCoord():TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := GetCountOfOneTextureCoord()*SizeOf(Single);
end;

function TS3DObject.GetSizeOfOneVertexCoord():TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := GetCountOfOneVertexCoord()*SizeOf(Single);
end;

function TS3DObject.GetSizeOfOneColorCoord():TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := GetCountOfOneColorCoord() * (1 + byte((FColorType=S3dObjectColorType3f) xor (FColorType=S3dObjectColorType4f))*(SizeOf(TSSingle)-1));
end;

function TS3DObject.GetSizeOfOneNormalCoord():TSLongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result := GetCountOfOneNormalCoord()*SizeOf(Single);
end;

function TS3DObject.GetSizeOfOneVertex():LongWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:= GetSizeOfOneVertexCoord() +
	GetSizeOfOneColorCoord() +
	GetSizeOfOneNormalCoord() +
	GetSizeOfOneTextureCoord();
end;

function TS3DObject.GetVertexesSize():TSMaxEnum;overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=FNOfVerts*GetSizeOfOneVertex();
end;

function TS3DObject.GetVertex3f(const Index:TSMaxEnum):PSVertex3f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSVertex3f(TSMaxEnum(ArVertex)+Index*(GetSizeOfOneVertex()));
end;

function TS3DObject.GetVertex4f(const Index : TSMaxEnum):PSVertex4f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSVertex4f(TSMaxEnum(ArVertex)+Index*(GetSizeOfOneVertex()));
end;

function TS3DObject.GetVertex2f(const Index:TSMaxEnum):PSVertex2f; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=PSVertex2f(TSMaxEnum(ArVertex)+Index*(GetSizeOfOneVertex()));
end;

class function TS3DObject.GetFaceLength(const FaceLength:TSQuadWord; const ThisPoligoneType:LongWord):TSQuadWord;overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=FaceLength*GetPoligoneInt(ThisPoligoneType);
end;

class function TS3DObject.ClassName:string;
begin
Result:='TS3dObject';
end;

procedure TS3DObject.WriteInfo(const PredStr : TSString = ''; const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog]);

function LinksVBO() : TSString;
var
	Index : TSUInt32;
begin
Result := '';
if FFacesBuffers <> nil then
	for Index := 0 to High(FFacesBuffers) do
		begin
		Result += SStr(FFacesBuffers[Index]);
		if Index <> High(FFacesBuffers) then
			Result += ',';
		end;
end;

procedure WriteFaceArray(const Index : TSUInt32);
var
	FacePredString : TSString = '';
begin
FacePredString := PredStr + '   ' + SStr(Index + 1) + ') ';
SHint([FacePredString,'Index           = "',Index,'"'], CasesOfPrint);
SHint([FacePredString,'CountOfFaces    = "',ArFaces[Index].FNOfFaces,'"'], CasesOfPrint);
SHint([FacePredString,'RealFaceLength  = "',GetFaceLength(Index),'"'], CasesOfPrint);
SHint([FacePredString,'MaterialID      = "',ArFaces[Index].FMaterial,'"'], CasesOfPrint);
SHint([FacePredString,'IndexFormat     = "'+SStr3dObjectIndexFormat(ArFaces[Index].FIndexFormat)+'"'], CasesOfPrint);
SHint([FacePredString,'PoligonesType   = "', SStrPoligonesType(ArFaces[Index].FPoligonesType), '"'], CasesOfPrint);
TextColor(15);
SHint([FacePredString,'FacesSize       = "',SMemorySizeToString(GetFaceInt(ArFaces[Index].FIndexFormat) * GetFaceLength(Index),'EN'),'"'], CasesOfPrint);
TextColor(7);
end;

procedure WriteFaceArrays();
var
	Index : TSUInt32;
begin
TextColor(7);
if FQuantityFaceArrays <> 0 then
	for Index:=0 to FQuantityFaceArrays - 1 do
		WriteFaceArray(Index);
end;

begin
TextColor(7);
SHint(PredStr + 'TS3DObject__WriteInfo(..)', CasesOfPrint);
SHint([PredStr,'  Name                = "',FName,'"'], CasesOfPrint);
SHint([PredStr,'  CountOfVertexes     = "',FNOfVerts,'"'], CasesOfPrint);
SHint([PredStr,'  HasColors           = "',FHasColors,'"'], CasesOfPrint);
SHint([PredStr,'  HasNormals          = "',FHasNormals,'"'], CasesOfPrint);
SHint([PredStr,'  HasTexture          = "',FHasTexture,'"'], CasesOfPrint);
if FQuantityFaceArrays>0 then TextColor(10) else TextColor(12);
SHint([PredStr,'  QuantityFaceArrays  = "',FQuantityFaceArrays,'"'], CasesOfPrint);
WriteFaceArrays();
SHint([PredStr,'  ObjectPoligonesType = "', SStrPoligonesType(FObjectPoligonesType), '"'], CasesOfPrint);
SHint([PredStr,'  SizeOfOneVertex     = "',GetSizeOfOneVertex(),'"'], CasesOfPrint);
SHint([PredStr,'  VertexFormat        = "', SStrVertexFormat(FVertexType), '"'], CasesOfPrint);
SHint([PredStr,'  CountTextureFloatsInVertexArray = "',FCountTextureFloatsInVertexArray,'"'], CasesOfPrint);
SHint([PredStr,'  ColorType           = "' + SStr3dObjectColorFormat(FColorType) + '"'], CasesOfPrint);
TextColor(15);
SHint([PredStr,'  VertexesSize        = "',SMemorySizeToString(VertexesSize(),'EN'),'"'], CasesOfPrint);
if FQuantityFaceArrays>0 then
	SHint([PredStr,'  AllSize             = "',SMemorySizeToString(Size(),'EN'),'"'], CasesOfPrint);
TextColor(7);
SHint([PredStr,'  EnableVBO           = "',FEnableVBO,'"'], CasesOfPrint);
SHint([PredStr,'  LinksVBO            = Vertex:',FVertexesBuffer,', Faces:(', Iff(LinksVBO() = '', 'nil', LinksVBO()), ')'], CasesOfPrint);
SHint([PredStr,'  ObjectMaterialID    = "',FObjectMaterial,'"'], CasesOfPrint);
end;

function TS3DObject.VertexesSize():TSQuadWord;Inline;
begin
Result:=GetSizeOfOneVertex()*FNOfVerts;
end;

function TS3DObject.FacesSize():TSQuadWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	Index : TSLongWord;
begin
Result:=0;
if FQuantityFaceArrays<>0 then
	for Index := 0 to FQuantityFaceArrays-1 do
		Result += GetFaceInt(ArFaces[Index].FIndexFormat)*GetFaceLength(Index);
end;

function TS3DObject.Size():QWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=
	FacesSize()+
	VertexesSize();
end;

class function TS3DObject.GetPoligoneInt(const ThisPoligoneType : LongWord):Byte; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
case ThisPoligoneType of
SR_POINTS,
	SR_TRIANGLE_STRIP,
	SR_LINE_LOOP,
	SR_LINE_STRIP : Result := 1;
SR_QUADS          : Result := 4;
SR_TRIANGLES      : Result := 3;
SR_LINES          : Result := 2;
end;
end;

function TS3DObject.GetFaceLength(const Index : TSLongWord):TSQuadWord;overload; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
Result:=GetFaceLength(ArFaces[Index].FNOfFaces,ArFaces[Index].FPoligonesType);
end;

procedure TS3DObject.SetFaceLength(const ArIndex:TSLongWord;const NewLength:TSQuadWord); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces[ArIndex].FNOfFaces=0) or (ArFaces[ArIndex].FArray=nil) then
	GetMem(ArFaces[ArIndex].FArray,
		GetPoligoneInt(ArFaces[ArIndex].FPoligonesType)*GetFaceInt(ArFaces[ArIndex].FIndexFormat)*(NewLength))
else
	ReAllocMem(ArFaces[ArIndex].FArray,
		GetPoligoneInt(ArFaces[ArIndex].FPoligonesType)*GetFaceInt(ArFaces[ArIndex].FIndexFormat)*(NewLength));
ArFaces[ArIndex].FNOfFaces:=NewLength;
end;

function TS3DObject.ArFacesLines1b(const Index:TSLongWord = 0)     : PTSFaceLine1b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSFaceLine1b(TSPointer(ArFaces[Index].FArray));
end;

function TS3DObject.ArFacesQuads1b(const Index:TSLongWord = 0)     : PTSFaceQuad1b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSFaceQuad1b(TSPointer(ArFaces[Index].FArray));
end;

function TS3DObject.ArFacesTriangles1b(const Index:TSLongWord = 0) : PTSFaceTriangle1b;  {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSFaceTriangle1b(TSPointer(ArFaces[Index].FArray));
end;

function TS3DObject.ArFacesPoints1b(const Index:TSLongWord = 0)    : PTSFacePoint1b;     {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSFacePoint1b(TSPointer(ArFaces[Index].FArray));
end;

function TS3DObject.ArFacesLines2b(const Index:TSLongWord = 0)     : PTSFaceLine2b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSFaceLine2b(TSPointer(ArFaces[Index].FArray));
end;

function TS3DObject.ArFacesQuads2b(const Index:TSLongWord = 0)     : PTSFaceQuad2b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSFaceQuad2b(TSPointer(ArFaces[Index].FArray));
end;

function TS3DObject.ArFacesTriangles2b(const Index:TSLongWord = 0) : PTSFaceTriangle2b;  {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSFaceTriangle2b(TSPointer(ArFaces[Index].FArray));
end;

function TS3DObject.ArFacesPoints2b(const Index:TSLongWord = 0)    : PTSFacePoint2b;     {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSFacePoint2b(TSPointer(ArFaces[Index].FArray));
end;

function TS3DObject.ArFacesLines4b(const Index:TSLongWord = 0)     : PTSFaceLine4b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSFaceLine4b(TSPointer(ArFaces[Index].FArray));
end;

function TS3DObject.ArFacesQuads4b(const Index:TSLongWord = 0)     : PTSFaceQuad4b;      {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSFaceQuad4b(TSPointer(ArFaces[Index].FArray));
end;

function TS3DObject.ArFacesTriangles4b(const Index:TSLongWord = 0) : PTSFaceTriangle4b;  {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSFaceTriangle4b(TSPointer(ArFaces[Index].FArray));
end;

function TS3DObject.ArFacesPoints4b(const Index:TSLongWord = 0)    : PTSFacePoint4b;     {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (ArFaces=nil) or (Length(ArFaces)=0) then
	Result:=nil
else
	Result:=PTSFacePoint4b(TSPointer(ArFaces[Index].FArray));
end;

constructor TS3dObject.Create();
begin
inherited Create();
FEnableCullFaceFront := True;
FEnableCullFaceBack  := True;
FCountTextureFloatsInVertexArray := 2;
FBumpFormat := SBumpFormatNone;
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
FObjectPoligonesType := SR_TRIANGLES;
FColorType:=S3dObjectColorType3b;
FVertexType:=S3dObjectVertexType3f;
FEnableVBO:=False;
FVertexesBuffer := 0;
FFacesBuffers := nil;
FEnableObjectMatrix := False;
FObjectMatrix := SIdentityMatrix();
end;

procedure TS3dObject.SetMatrix(const Matrix : TSMatrix4x4);
begin
FEnableObjectMatrix := Matrix <> SIdentityMatrix();
FObjectMatrix := Matrix;
end;

destructor TS3dObject.Destroy();
begin
ClearArrays();
ClearVBO();
inherited Destroy();
end;

procedure TS3dObject.BasicDrawWithAttributes();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
InitAttributes();
BasicDraw();
DisableAttributes();
end;

procedure TS3dObject.Paint();
begin
{$IFDEF SMoreDebuging}
	WriteLn('Call "TS3dObject.Draw" : "'+ClassName+'" is sucsesfull');
	{$ENDIF}
if FEnableCullFace then
	if (FEnableCullFaceBack or FEnableCullFaceFront) then
		begin
		InitAttributes();
		Render.Enable(SR_CULL_FACE);
		if FEnableCullFaceBack then
			begin
			Render.CullFace(SR_BACK);
			BasicDraw();
			end;
		if FEnableCullFaceFront then
			begin
			Render.CullFace(SR_FRONT);
			BasicDraw();
			end;
		Render.Disable(SR_CULL_FACE);
		DisableAttributes();
		end
	else
		SLog.Source('TS3dObject__Draw : "' + ClassName + '" - CullFace enabled, but Front and Back draw types disabled...')
else
	BasicDrawWithAttributes();
end;

procedure TS3DObject.ClearArrays(const ClearN : boolean = True);
var
	Index : TSLongWord;
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

procedure TS3DObject.CopyTo(const Destination : TS3dObject); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i: TSLongWord;
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

procedure TS3dObject.InitAttributes();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if FEnableObjectMatrix then
	begin
	Render.PushMatrix();
	Render.MultMatrixf(@FObjectMatrix);
	end;

if (FObjectMaterial = nil) and (FQuantityFaceArrays = 0) then
	Render.ColorMaterial(FObjectColor.r, FObjectColor.g, FObjectColor.b, FObjectColor.a);

Render.EnableClientState(SR_VERTEX_ARRAY);
if FHasNormals then
	Render.EnableClientState(SR_NORMAL_ARRAY);
if FHasTexture then
	begin
	if FBumpFormat = SBumpFormatCopyTexture2f then
		Render.ClientActiveTexture(1);
	Render.EnableClientState(SR_TEXTURE_COORD_ARRAY);
	if FBumpFormat = SBumpFormatCopyTexture2f then
		Render.ClientActiveTexture(0);
	end;
if (FBumpFormat = SBumpFormatCopyTexture2f) or (FBumpFormat = SBumpFormat2f) then
	begin
	Render.EnableClientState(SR_TEXTURE_COORD_ARRAY);
	end;
if FHasColors then
	Render.EnableClientState(SR_COLOR_ARRAY);

if FEnableVBO then
	begin
	Render.BindBufferARB(SR_ARRAY_BUFFER_ARB, FVertexesBuffer);
	Render.VertexPointer(GetCountOfOneVertexCoord(), SR_FLOAT, GetSizeOfOneVertex(), nil);
	
	if FHasColors then
		begin
		Render.ColorPointer(
			GetCountOfOneColorCoord(),
			SR_FLOAT*Byte((FColorType = S3dObjectColorType3f) or (FColorType = S3dObjectColorType4f))+
				SR_UNSIGNED_BYTE*Byte((FColorType = S3dObjectColorType4b) or (FColorType = S3dObjectColorType3b)),
			GetSizeOfOneVertex(),
			Pointer(GetSizeOfOneVertexCoord()));
		end;
	
	if FHasNormals then
		begin
		Render.NormalPointer(
			SR_FLOAT,
			GetSizeOfOneVertex(),
			Pointer(
				GetSizeOfOneVertexCoord()+
				GetSizeOfOneColorCoord()));
		end;
	
	if FHasTexture then
		begin
		if FBumpFormat = SBumpFormatCopyTexture2f then
			Render.ClientActiveTexture(1);
		Render.TexCoordPointer(GetCountOfOneTextureCoord(), SR_FLOAT, GetSizeOfOneVertex(),
			Pointer(
				GetSizeOfOneVertexCoord() +
				GetSizeOfOneColorCoord() +
				GetSizeOfOneNormalCoord()));
		if FBumpFormat = SBumpFormatCopyTexture2f then
			Render.ClientActiveTexture(0);
		end;
	
	if (FBumpFormat = SBumpFormatCopyTexture2f) or (FBumpFormat = SBumpFormat2f) then
		begin
		Render.TexCoordPointer(GetCountOfOneTextureCoord(), SR_FLOAT, GetSizeOfOneVertex(),
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
		SR_FLOAT, 
		GetSizeOfOneVertex(), 
		ArVertex);
    if FHasColors then
		Render.ColorPointer(
			GetCountOfOneColorCoord(),
			SR_FLOAT*Byte((FColorType = S3dObjectColorType3f) or (FColorType = S3dObjectColorType4f))+
				SR_UNSIGNED_BYTE*Byte((FColorType = S3dObjectColorType4b) or (FColorType = S3dObjectColorType3b)),
			GetSizeOfOneVertex(),
			Pointer(
				TSMaxEnum(ArVertex)+
				GetSizeOfOneVertexCoord()));
	if FHasNormals then
		Render.NormalPointer(
			SR_FLOAT, 
			GetSizeOfOneVertex(), 
			Pointer(
				TSMaxEnum(ArVertex)+
				GetSizeOfOneVertexCoord()+
				GetSizeOfOneColorCoord()));
	
    if FHasTexture then
		begin
		if FBumpFormat = SBumpFormatCopyTexture2f then
			Render.ClientActiveTexture(1);
        Render.TexCoordPointer(
			GetCountOfOneTextureCoord(),
			SR_FLOAT, 
			GetSizeOfOneVertex(), 
			Pointer(
				TSMaxEnum(ArVertex)+
				GetSizeOfOneVertexCoord()+
				GetSizeOfOneColorCoord()+
				GetSizeOfOneNormalCoord()));
		if FBumpFormat = SBumpFormatCopyTexture2f then
			Render.ClientActiveTexture(0);
		end;
	
	if (FBumpFormat = SBumpFormatCopyTexture2f) or (FBumpFormat = SBumpFormat2f) then
		begin
		Render.TexCoordPointer(
			GetCountOfOneTextureCoord(),
			SR_FLOAT, 
			GetSizeOfOneVertex(), 
			Pointer(
				TSMaxEnum(ArVertex)+
				GetSizeOfOneVertexCoord()+
				GetSizeOfOneColorCoord()+
				GetSizeOfOneNormalCoord()));
		end;
	end;

if (FObjectMaterial <> nil) then
	FObjectMaterial.Bind(BumpFormat, HasTexture);
end;

procedure TS3dObject.DisableAttributes();{$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (FObjectMaterial <> nil) then
	FObjectMaterial.UnBind(BumpFormat, HasTexture);

if FEnableVBO then
	begin
	Render.BindBufferARB(SR_ARRAY_BUFFER_ARB, 0);
	if FQuantityFaceArrays <> 0 then
		Render.BindBufferARB(SR_ELEMENT_ARRAY_BUFFER_ARB, 0);
	end;
Render.DisableClientState(SR_VERTEX_ARRAY);
if FHasNormals then
	Render.DisableClientState(SR_NORMAL_ARRAY);
if FHasTexture then
	begin
	if FBumpFormat = SBumpFormatCopyTexture2f then
		Render.ClientActiveTexture(1);
	Render.DisableClientState(SR_TEXTURE_COORD_ARRAY);
	if FBumpFormat = SBumpFormatCopyTexture2f then
		Render.ClientActiveTexture(0);
	end;
if (FBumpFormat = SBumpFormatCopyTexture2f) or (FBumpFormat = SBumpFormat2f) then
	begin
	Render.DisableClientState(SR_TEXTURE_COORD_ARRAY);
	end;
if FHasColors then
	Render.DisableClientState(SR_COLOR_ARRAY);

if (FObjectMaterial = nil) and (FQuantityFaceArrays = 0) then
	Render.ColorMaterial(1, 1, 1, 1);

if FEnableObjectMatrix then
	Render.PopMatrix();
end;

procedure TS3dObject.BasicDraw(); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}

procedure InitFaceArrayMeterial(const Material : ISMaterial); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (Material <> nil) then
	begin
	if FObjectMaterial <> nil then
		FObjectMaterial.UnBind(BumpFormat, HasTexture);
	Material.Bind(BumpFormat, HasTexture);
	end;
end;

procedure DisableFaceArrayMeterial(const Material : ISMaterial); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if (Material <> nil) then
	begin
	Material.UnBind(BumpFormat, HasTexture);
	if FObjectMaterial <> nil then
		FObjectMaterial.Bind(BumpFormat, HasTexture);
	end;
end;

var
	Index : TSMaxEnum;
begin
if FEnableVBO then
	if FQuantityFaceArrays <> 0 then
		for Index := 0 to FQuantityFaceArrays-1 do
			begin
			InitFaceArrayMeterial(ArFaces[Index].FMaterial);
			Render.BindBufferARB(SR_ELEMENT_ARRAY_BUFFER_ARB, FFacesBuffers[Index]);
			Render.DrawElements(ArFaces[Index].FPoligonesType, GetFaceLength(Index),
				S3dObjectToRenderIndexFormat(ArFaces[Index].FIndexFormat), nil);
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
				S3dObjectToRenderIndexFormat(ArFaces[Index].FIndexFormat),
				ArFaces[Index].FArray);
			DisableFaceArrayMeterial(ArFaces[Index].FMaterial);
			end
	else
		Render.DrawArrays(FObjectPoligonesType, 0, FNOfVerts);
end;

procedure TS3dObject.LoadToVBO(const ClearAfterLoad : TSBoolean = True);
var
	Index : TSMaxEnum;
begin
if Self = nil then
	begin
	SLog.Source('TS3dObject(nil)__LoadToVBO().');
	Exit;
	end;

if FEnableVBO then
	begin
	SLog.Source('TS3dObject__LoadToVBO : It is not possible to do this several counts!');
	Exit;
	end;

Render.GenBuffersARB(1, @FVertexesBuffer);
Render.BindBufferARB(SR_ARRAY_BUFFER_ARB, FVertexesBuffer);
Render.BufferDataARB(SR_ARRAY_BUFFER_ARB, FNOfVerts * GetSizeOfOneVertex(), ArVertex, SR_STATIC_DRAW_ARB);
Render.BindBufferARB(SR_ARRAY_BUFFER_ARB, 0);

if FQuantityFaceArrays <> 0 then
	begin
	SetLength(FFacesBuffers, FQuantityFaceArrays);
	for Index := 0 to FQuantityFaceArrays - 1 do
		begin
		Render.GenBuffersARB(1, @FFacesBuffers[Index]);
		Render.BindBufferARB(SR_ELEMENT_ARRAY_BUFFER_ARB, FFacesBuffers[Index]);
		Render.BufferDataARB(SR_ELEMENT_ARRAY_BUFFER_ARB,
			GetFaceLength(Index) * GetFaceInt(ArFaces[Index].FIndexFormat),
			ArFaces[Index].FArray,
			SR_STATIC_DRAW_ARB,
			S3dObjectToRenderIndexFormat(ArFaces[Index].FIndexFormat));
		end;
	Render.BindBufferARB(SR_ELEMENT_ARRAY_BUFFER_ARB, 0);
	end;

if ClearAfterLoad then
	ClearArrays(False);
FEnableVBO := True;
end;

procedure TS3DObject.ClearVBO(); {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	Index : TSMaxEnum;
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
