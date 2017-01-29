{$INCLUDE SaGe.inc}

unit SaGeCommon;

interface

uses
	 Crt
	,Math
	,Classes
	,SysUtils
	
	,SaGeBase
	,SaGeBased
	,SaGeRenderConstants
	,SaGeClasses
	;

{$DEFINE INC_PLACE_INTERFACE}
{$INCLUDE SaGeCommonStructs.inc}
{$UNDEF INC_PLACE_INTERFACE}

type
	ISGRender = interface;
	ISGAudioRender = interface;

	TSGVertexFormat = (SGVertexFormat2f,SGVertexFormat3f,SGVertexFormat4f);

	TSGComplexNumber = object(TSGVertex2f)
		end;

	TSGQuaternion = object(TSGVertex4f)
		procedure Inverse();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function Intersed():TSGQuaternion;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

	TSGArLongWord = type packed array of LongWord;
	TSGScreenVertexes=object
		Vertexes:array[0..1] of TSGVertex2f;
		procedure Import(const x1:real = 0;const y1:real = 0;const x2:real = 0;const y2:real = 0);
		procedure Write;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ProcSumX(r:Real);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ProcSumY(r:Real);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		property SumX:real write ProcSumX;
		property SumY:real write ProcSumY;
		property X1:TSGFloat32 read Vertexes[0].x write Vertexes[0].x;
		property Y1:TSGFloat32 read Vertexes[0].y write Vertexes[0].y;
		property X2:TSGFloat32 read Vertexes[1].x write Vertexes[1].x;
		property Y2:TSGFloat32 read Vertexes[1].y write Vertexes[1].y;
		function VertexInView(const Vertex:TSGVertex2f):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AbsX:TSGFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AbsY:TSGFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

	TSGVisibleVertex=object(TSGVertex3f)
		Visible:Boolean;
		end;
	SGVisibleVertex = TSGVisibleVertex;
	PSGVisibleVertex = ^SGVisibleVertex;
	TArSGVisibleVertex = type packed array of TSGVisibleVertex;
	TArTSGVisibleVertex = TArSGVisibleVertex;
	TSGVisibleVertexFunction = function (a:TSGVisibleVertex;CONST b:Pointer):TSGVisibleVertex;
	TSGPointerProcedure = procedure (a:Pointer);
	TSGProcedure = procedure;

	TSGCustomPosition = record
		case byte of
		0: (FLocation : TSGVertex3f; FTurn   : TSGVertex3f);
		1: (X, Y, Z   : TSGSingle;   A, B, G : TSGSingle);
		end;

	PSGPosition = ^ TSGPosition;
	TSGPosition = object
			protected
		FPosition : TSGCustomPosition;
			public
		property x         : TSGSingle         read FPosition.x         write FPosition.x;
		property y         : TSGSingle         read FPosition.y         write FPosition.y;
		property z         : TSGSingle         read FPosition.z         write FPosition.z;
		property a         : TSGSingle         read FPosition.a         write FPosition.a;
		property b         : TSGSingle         read FPosition.b         write FPosition.b;
		property g         : TSGSingle         read FPosition.g         write FPosition.g;
		property Location  : TSGVertex3f       read FPosition.FLocation write FPosition.FLocation;
		property Turn      : TSGVertex3f       read FPosition.FTurn     write FPosition.FTurn;
		property CustomPos : TSGCustomPosition read FPosition           write FPosition;
		end;

	TSGMatrix4Type = TSGFloat;

	TSGMatrix4 = array [0..3,0..3] of TSGMatrix4Type;

type
	ISGAudioRender = interface
		['{cb4d7649-16ee-44f6-b9f1-bf393f6bb18c}']
		procedure Initialize();
		procedure Init();
		function CreateDevice() : TSGBool;
		procedure Kill();
		end;

	ISGRender = interface(ISGRectangle)
		['{6d0d4eb0-4de7-4000-bf5d-52a069a776d1}']
		function GetRenderType() : TSGRenderType;
		function SetPixelFormat():TSGBoolean;
		function MakeCurrent():TSGBoolean;
		procedure ReleaseCurrent();
		function CreateContext():TSGBoolean;
		procedure Viewport(const a,b,c,d:TSGAreaInt);
		procedure Init();
		function SupporedVBOBuffers():TSGBoolean;
		procedure SwapBuffers();
		procedure LockResources();
		procedure UnLockResources();
		procedure SetContext(const VContext : ISGNearlyContext);
		function GetContext() : ISGNearlyContext;

		procedure InitOrtho2d(const x0,y0,x1,y1:TSGSingle);
		procedure InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht : TSGFloat = 1);
		procedure BeginScene(const VPrimitiveType:TSGPrimtiveType);
		procedure EndScene();
		procedure Perspective(const vAngle,vAspectRatio,vNear,vFar : TSGFloat);
		procedure LoadIdentity();
		procedure ClearColor(const r,g,b,a : TSGFloat);
		procedure Vertex3f(const x,y,z:TSGSingle);
		procedure Scale(const x,y,z : TSGSingle);
		procedure Color3f(const r,g,b:TSGSingle);
		procedure TexCoord2f(const x,y:TSGSingle);
		procedure Vertex2f(const x,y:TSGSingle);
		procedure Color4f(const r,g,b,a:TSGSingle);
		procedure Normal3f(const x,y,z:TSGSingle);
		procedure Translatef(const x,y,z:TSGSingle);
		procedure Rotatef(const angle:TSGSingle;const x,y,z:TSGSingle);
		procedure Enable(VParam:TSGCardinal);
		procedure Disable(const VParam:TSGCardinal);
		procedure DeleteTextures(const VQuantity:TSGCardinal;const VTextures:PSGUInt);
		procedure Lightfv(const VLight,VParam:TSGCardinal;const VParam2:TSGPointer);
		procedure GenTextures(const VQuantity:TSGCardinal;const VTextures:PSGUInt);
		procedure BindTexture(const VParam:TSGCardinal;const VTexture:TSGCardinal);
		procedure TexParameteri(const VP1,VP2,VP3:TSGCardinal);
		procedure PixelStorei(const VParamName:TSGCardinal;const VParam:SGInt);
		procedure TexEnvi(const VP1,VP2,VP3:TSGCardinal);
		procedure TexImage2D(const VTextureType:TSGCardinal;const VP1:TSGCardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:TSGCardinal;VBitMap:TSGPointer);
		procedure ReadPixels(const x,y:TSGInteger;const Vwidth,Vheight:TSGInteger;const format, atype: TSGCardinal;const pixels: TSGPointer);
		procedure CullFace(const VParam:TSGCardinal);
		procedure EnableClientState(const VParam:TSGCardinal);
		procedure DisableClientState(const VParam:TSGCardinal);
		procedure GenBuffersARB(const VQ:TSGInteger;const PT:PCardinal);
		procedure DeleteBuffersARB(const VQuantity:TSGLongWord;VPoint:TSGPointer);
		procedure BindBufferARB(const VParam:TSGCardinal;const VParam2:TSGCardinal);
		procedure BufferDataARB(const VParam:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer;const VParam2:TSGCardinal;const VIndexPrimetiveType : TSGLongWord = 0);
		procedure DrawElements(const VParam:TSGCardinal;const VSize:TSGInt64;const VParam2:TSGCardinal;VBuffer:TSGPointer);
		procedure ColorPointer(const VQChannels:TSGLongWord;const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);
		procedure TexCoordPointer(const VQChannels:TSGLongWord;const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);
		procedure NormalPointer(const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);
		procedure VertexPointer(const VQChannels:TSGLongWord;const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);
		function IsEnabled(const VParam:TSGCardinal):Boolean;
		procedure Clear(const VParam:TSGCardinal);
		procedure LineWidth(const VLW:TSGSingle);
		procedure PointSize(const PS:Single);
		procedure PopMatrix();
		procedure PushMatrix();
		procedure DrawArrays(const VParam:TSGCardinal;const VFirst,VCount:TSGLongWord);
		procedure Vertex3fv(const Variable : TSGPointer);
		procedure Normal3fv(const Variable : TSGPointer);
		procedure MultMatrixf(const Variable : TSGPointer);
		procedure ColorMaterial(const r,g,b,a:TSGSingle);
		procedure MatrixMode(const Par:TSGLongWord);
		procedure LoadMatrixf(const Variable : TSGPointer);
		procedure ClientActiveTexture(const VTexture : TSGLongWord);
		procedure ActiveTexture(const VTexture : TSGLongWord);
		procedure ActiveTextureDiffuse();
		procedure ActiveTextureBump();
		procedure BeginBumpMapping(const Point : Pointer );
		procedure EndBumpMapping();
		procedure PolygonOffset(const VFactor, VUnits : TSGFloat);
		{$IFDEF MOBILE}
			procedure GenerateMipmap(const Param : TSGCardinal);
		{$ELSE}
			procedure GetVertexUnderPixel(const px,py : LongWord; out x,y,z : Real);
			{$ENDIF}

			(* Shaders *)
		function SupporedShaders() : TSGBoolean;
		function CreateShader(const VShaderType : TSGCardinal):TSGLongWord;
		procedure ShaderSource(const VShader : TSGLongWord; VSourse : PChar; VSourseLength : integer);
		procedure CompileShader(const VShader : TSGLongWord);
		procedure GetObjectParameteriv(const VObject : TSGLongWord; const VParamName : TSGCardinal; const VResult : TSGRPInteger);
		procedure GetInfoLog(const VHandle : TSGLongWord; const VMaxLength : TSGInteger; var VLength : TSGInteger; VLog : PChar);
		procedure DeleteShader(const VProgram : TSGLongWord);

		function CreateShaderProgram() : TSGLongWord;
		procedure AttachShader(const VProgram, VShader : TSGLongWord);
		procedure LinkShaderProgram(const VProgram : TSGLongWord);
		procedure DeleteShaderProgram(const VProgram : TSGLongWord);

		function GetUniformLocation(const VProgram : TSGLongWord; const VLocationName : PChar): TSGLongWord;
		procedure Uniform1i(const VLocationName : TSGLongWord; const VData:TSGLongWord);
		procedure UseProgram(const VProgram : TSGLongWord);
		procedure UniformMatrix4fv(const VLocationName : TSGLongWord; const VCount : TSGLongWord; const VTranspose : TSGBoolean; const VData : TSGPointer);
		procedure Uniform3f(const VLocationName : TSGLongWord; const VX,VY,VZ : TSGFloat);
		procedure Uniform1f(const VLocationName : TSGLongWord; const V : TSGFloat);
		procedure Uniform1iv (const VLocationName: TSGLongWord; const VCount: TSGLongWord; const VValue: Pointer);
		procedure Uniform1uiv (const VLocationName: TSGLongWord; const VCount: TSGLongWord; const VValue: Pointer);
		procedure Uniform3fv (const VLocationName: TSGLongWord; const VCount: TSGLongWord; const VValue: Pointer);

		function SupporedDepthTextures():TSGBoolean;
		procedure BindFrameBuffer(const VType : TSGCardinal; const VHandle : TSGLongWord);
		procedure GenFrameBuffers(const VCount : TSGLongWord;const VBuffers : PCardinal);
		procedure DrawBuffer(const VType : TSGCardinal);
		procedure ReadBuffer(const VType : TSGCardinal);
		procedure GenRenderBuffers(const VCount : TSGLongWord;const VBuffers : PCardinal);
		procedure BindRenderBuffer(const VType : TSGCardinal; const VHandle : TSGLongWord);
		procedure FrameBufferTexture2D(const VTarget: TSGCardinal; const VAttachment: TSGCardinal; const VRenderbuffertarget: TSGCardinal; const VRenderbuffer, VLevel: TSGLongWord);
		procedure FrameBufferRenderBuffer(const VTarget: TSGCardinal; const VAttachment: TSGCardinal; const VRenderbuffertarget: TSGCardinal; const VRenderbuffer: TSGLongWord);
		procedure RenderBufferStorage(const VTarget, VAttachment: TSGCardinal; const VWidth, VHeight: TSGLongWord);
		procedure GetFloatv(const VType : TSGCardinal; const VPointer : Pointer);

		property Width : TSGAreaInt read GetWidth write SetWidth;
		property Height : TSGAreaInt read GetHeight write SetHeight;
		property Context : ISGNearlyContext read GetContext write SetContext;
		property RenderType : TSGRenderType read GetRenderType;

		{$DEFINE INC_PLACE_RENDER_INTERFACE}
		{$INCLUDE SaGeCommonStructs.inc}
		{$UNDEF INC_PLACE_RENDER_INTERFACE}
		end;

	ISGRendered = interface
		['{535e900f-03d6-47d1-b2e1-9eadadf877f3}']
		function GetRender() : ISGRender;
		function RenderAssigned() : TSGBoolean;

		property Render : ISGRender read GetRender;
		end;

operator + (const a,b:TSGComplexNumber):TSGComplexNumber;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (const a,b:TSGComplexNumber):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator - (const a,b:TSGComplexNumber):TSGComplexNumber;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator / (const a,b:TSGComplexNumber):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator ** (const a:TSGComplexNumber;const b:LongInt):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
operator = (const a,b:TSGComplexNumber):Boolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

operator * (const a:TSGScreenVertexes;const b:real):TSGScreenVertexes;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

operator + (const a,b:TSGPosition):TSGPosition;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator + (const a,b:TSGCustomPosition):TSGCustomPosition;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

//������������ ������ (����� ��� Rotate, Translate � Scale)
//��� �� ����� ��� LookAt ��� ��� ��� ����� ������ Translate.
operator * (const A,B:TSGMatrix4):TSGMatrix4;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator = (const A,B:TSGMatrix4):Boolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (const A:TSGVertex4f;const B:TSGMatrix4):TSGVertex4f;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (const A:TSGVertex3f;const B:TSGMatrix4):TSGVertex3f;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

// Quaternion
operator + (const A,B : TSGQuaternion):TSGQuaternion;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator - (const A   : TSGQuaternion):TSGQuaternion;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator - (const A,B : TSGQuaternion):TSGQuaternion;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (const A : TSGQuaternion;const B:TSGFloat32):TSGQuaternion;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (const A,B : TSGQuaternion):TSGFloat;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGGetVertexInAttitude(const t1,t2:TSGVertex3f; const r:real = 0.5):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGTSGVertex3fImport(const x:real = 0;const y:real = 0;const z:real = 0):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
//procedure SGQuad(const Vertex1: TSGVertex3f;const Vertex2: TSGVertex3f;const Vertex3: TSGVertex3f;const Vertex4: TSGVertex3f);
function SGVertexOnQuad(const Vertex: TSGVertex3f; const QuadVertex1: TSGVertex3f;const QuadVertex2: TSGVertex3f;const QuadVertex3: TSGVertex3f;const QuadVertex4: TSGVertex3f):boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGTreugPlosh(const a1,a2,a3: TSGVertex3f):real;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGVertexOnQuad(const Vertex: TSGVertex3f; const QuadVertex1: TSGVertex3f;const QuadVertex3: TSGVertex3f):boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetVertexOnIntersectionOfThreePlane(p1,p2,p3:SGPlane): TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetVertexWhichNormalFromThreeVertex(const p1,p2,p3: TSGVertex3f): TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetPlaneFromThreeVertex(const a1,a2,a3: TSGVertex3f):SGPlane;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetVertexOnIntersectionOfTwoLinesFromFourVertex(const q1,q2,w1,w2: TSGVertex3f): TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGRoundQuad(const VRender:ISGRender;const Vertex1,Vertex3: TSGVertex3f; const Radius:real; const Interval:LongInt;const QuadColor: TSGColor4f; const LinesColor: TSGColor4f; const WithLines:boolean = False;const WithQuad:boolean = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SGRoundQuad(const VRender:ISGRender;const Vertex12,Vertex32: TSGVertex2f; const Radius:real; const Interval:LongInt;const QuadColor: TSGColor4f; const LinesColor: TSGColor4f; const WithLines:boolean = False;const WithQuad:boolean = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGGetArrayOfRoundQuad(const Vertex1,Vertex3: TSGVertex3f; const Radius:real; const Interval:LongInt):TSGVertex3fList;
procedure SGRoundWindowQuad(const VRender:ISGRender;const Vertex11,Vertex13: TSGVertex3f;const Vertex21,Vertex23: TSGVertex3f;
	const Radius1:real;const Radius2:real; const Interval:LongInt;const QuadColor1: TSGColor4f;const QuadColor2: TSGColor4f;
	const WithLines:boolean; const LinesColor1: TSGColor4f; const LinesColor2: TSGColor4f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGConstructRoundQuad(const VRender:ISGRender;const ArVertex:TSGVertex3fList;const Interval:LongInt;const QuadColor: TSGColor4f; const LinesColor: TSGColor4f; const WithLines:boolean = False;const WithQuad:boolean = True);
procedure SGQuickRePlaceVertexType(var LongInt1,LongInt2:TSGFloat32); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGComplexNumberImport(const x:real = 0;const y:real = 0):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetColor4fFromLongWord(const LongWordColor:LongWord;const WithAlpha:Boolean = False): TSGColor4f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetPointsCirclePoints(const FPoints:TSGVertex2fList):TSGArLongWord;
function SGX(const v:Single):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGY(const v:Single):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGZ(const v:Single):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

(*��� �������� ��� ����, ����� ���������� gluLookAt � gluPerspective �� ��������� ���������� ���� Android ��� iOS*)
function SGMatrix4Import(const _0x0,_0x1,_0x2,_0x3,_1x0,_1x1,_1x2,_1x3,_2x0,_2x1,_2x2,_2x3,_3x0,_3x1,_3x2,_3x3:TSGMatrix4Type):TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetFrustumMatrix(const vleft,vright,vbottom,vtop,vnear,vfar:TSGMatrix4Type):TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetPerspectiveMatrix(const vAngle,vAspectRatio,vNear,vFar:TSGMatrix4Type):TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetLookAtMatrix(const Eve, At:TSGVertex3f;Up:TSGVertex3f):TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetOrthoMatrix(const l,r,b,t,vNear,vFar:TSGMatrix4Type):TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGWriteMatrix4(const P:TSGPointer);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetIdentityMatrix():TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetTranslateMatrix(const Vertex : TSGVertex3f):TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGTranslateMatrix(const VMatrix : TSGMatrix4; const VVertex : TSGVertex3f):TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGMultMatrixInRender(const VRender : ISGRender; Matrix : TSGMatrix4);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetRotateMatrix(const Angle:Single;const Axis:TSGVertex3f) : TSGMatrix4; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGRotatePoint(const Point : TSGVertex3f; const Os : TSGVertex3f; const Angle : TSGSingle):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetQuaternionFromAngleVector3f(const Angles : TSGVertex3f):TSGQuaternion;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGQuaternionSlerp(q1,q2:TSGQuaternion; interp:TSGFloat):TSGQuaternion;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGQuaternionLerp(q1,q2:TSGQuaternion; interp:TSGFloat):TSGQuaternion;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGSetMatrixRotation(var Matrix : TSGMatrix4;const Angles : TSGVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGSetMatrixRotationQuaternion(var Matrix : TSGMatrix4;const Quat : TSGQuaternion);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGSetMatrixTranslation(var Matrix : TSGMatrix4; const Trans : TSGVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGMultiplyPartMatrix(const m1:TSGMatrix4;const m2:TSGMatrix4):TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGRotateVectorInverse(const Matrix : TSGMatrix4;const Vec : TSGVertex3f):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGTranslateVectorInverse(const Matrix : TSGMatrix4;const Vec : TSGVertex3f):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGTransformVector(const Matrix : TSGMatrix4; const Vec : TSGVertex3f):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGInverseMatrix(const VSourseMatrix : TSGMatrix4) : TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetScaleMatrix(const VVertex : TSGVertex3f): TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$IFNDEF MOBILE}
function SGGetVertexUnderPixel(const VRender : ISGRender; const Pixel : TSGPoint2i32):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$ENDIF}
function SGTriangleSize(const a,b,c:TSGVertex3f):TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGTriangleSize(const a,b,c:TSGVertex2f):TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGTriangleSize(const a,b,c:TSGFloat)   :TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsVertexOnTriangle(const t1,t2,t3,v:TSGVertex2f; const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsVertexOnTriangle(const t1,t2,t3,v:TSGVertex3f; const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsVertexOnLine(const t1,t2,v : TSGVertex3f; const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsVertexOnLine(const t1,t2,v : TSGVertex2f; const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsVertexOnLine(const t1,t2,v : TSGFloat;    const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGGetNextDynamicArrayIndex(const Index, HighOfArray : TSGLongWord): TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGIsTriangleConvex(const v1,v2,v3:TSGVertex3f):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGIsTriangleConvex(const v1,v2,v3:TSGFloat):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

function SGGetAngleFromCosSin(const Coodrs : TSGVertex2f):TSGFloat; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGPoint2int32ToVertex3f(const P : TSGPoint2int32):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

{$DEFINE INC_PLACE_IMPLEMENTATION}
{$INCLUDE SaGeCommonStructs.inc}
{$UNDEF INC_PLACE_IMPLEMENTATION}

function SGPoint2int32ToVertex3f(const P : TSGPoint2int32):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(P.x, P.y);
end;

function SGGetAngleFromCosSin(const Coodrs : TSGVertex2f):TSGFloat; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Coodrs.x = -1 then
	Result := PI
else if Coodrs.x = 1 then
	Result := 0
else if Coodrs.y = -1 then
	Result := 3*PI/2
else if Coodrs.y = 1 then
	Result := PI/2
else if Coodrs.y > SGZero then
	Result := ArcCos(Coodrs.x)
else
	Result := ArcCos(-Coodrs.x) + PI;
end;

function SGIsTriangleConvex(const v1,v2,v3:TSGFloat):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	sv1, sv2, sv3 : TSGFloat;
begin
sv1 := Sqr(v1);
sv2 := Sqr(v2);
sv3 := Sqr(v3);
Result :=
	(sv1 < sv2 + sv3) and
	(sv2 < sv1 + sv3) and
	(sv3 < sv2 + sv1);
end;

function SGIsTriangleConvex(const v1,v2,v3:TSGVertex3f):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGIsTriangleConvex(Abs(v3-v2),Abs(v3-v1),Abs(v1-v2));
end;

function SGGetNextDynamicArrayIndex(const Index, HighOfArray : TSGLongWord): TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (Index + 1) * Byte(Index <> HighOfArray);
end;

function SGIsVertexOnLine(const t1,t2,v : TSGFloat;    const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	l : TSGFloat;
begin
l := Abs(t2-t1);
Result := Abs(l - Abs(t1-v) - Abs(t2-v)) < Zero * l;
end;

function SGIsVertexOnLine(const t1,t2,v : TSGVertex3f; const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	l : TSGFloat;
begin
l := Abs(t2-t1);
Result := Abs(l - Abs(t1-v) - Abs(t2-v)) < Zero * l;
end;

function SGIsVertexOnLine(const t1,t2,v : TSGVertex2f; const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	l : TSGFloat;
begin
l := Abs(t2-t1);
Result := Abs(l - Abs(t1-v) - Abs(t2-v)) < Zero * l;
end;

function SGIsVertexOnTriangle(const t1,t2,t3,v:TSGVertex2f; const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	t1t2, t2t3, t3t1, vt1, vt2, vt3, s: TSGFloat;
begin
Result := SGIsVertexOnLine(t1,t2,v) or SGIsVertexOnLine(t1,t3,v) or SGIsVertexOnLine(t3,t2,v);
if not Result then
	begin
	t1t2 := Abs(t1 - t2);
	t2t3 := Abs(t2 - t3);
	t3t1 := Abs(t3 - t1);

	vt1 := Abs(v - t1);
	vt2 := Abs(v - t2);
	vt3 := Abs(v - t3);

	s := SGTriangleSize(t1t2, t2t3, t3t1);

	Result := Abs(
		  s
		- SGTriangleSize(t1t2, vt1, vt2)
		- SGTriangleSize(t2t3, vt3, vt2)
		- SGTriangleSize(t3t1, vt1, vt3)
			) < Zero * s;
	end;
end;

function SGIsVertexOnTriangle(const t1,t2,t3,v:TSGVertex3f; const Zero : TSGFloat = SGZero):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	t1t2, t2t3, t3t1, vt1, vt2, vt3, s: TSGFloat;
begin
Result := SGIsVertexOnLine(t1,t2,v) or SGIsVertexOnLine(t1,t3,v) or SGIsVertexOnLine(t3,t2,v);
if not Result then
	begin
	t1t2 := Abs(t1 - t2);
	t2t3 := Abs(t2 - t3);
	t3t1 := Abs(t3 - t1);

	vt1 := Abs(v - t1);
	vt2 := Abs(v - t2);
	vt3 := Abs(v - t3);

	s := SGTriangleSize(t1t2, t2t3, t3t1);

	Result := Abs(
		  s
		- SGTriangleSize(t1t2, vt1, vt2)
		- SGTriangleSize(t2t3, vt3, vt2)
		- SGTriangleSize(t3t1, vt1, vt3)
			) < Zero * s;
	end;
end;

function SGTriangleSize(const a,b,c:TSGFloat)   :TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	p : TSGFloat;
begin
p := (a + b + c) / 2;
Result := sqrt(p*(p-a)*(p-b)*(p-c));
end;

function SGTriangleSize(const a,b,c:TSGVertex2f):TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGTriangleSize(Abs(a-c),Abs(c-b),Abs(b-a));
end;

function SGTriangleSize(const a,b,c:TSGVertex3f):TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGTriangleSize(Abs(a-c),Abs(c-b),Abs(b-a));
end;

{$IFNDEF MOBILE}
function SGGetVertexUnderPixel(const VRender : ISGRender; const Pixel : TSGPoint2i32):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	x,y,z : Real;
begin
VRender.GetVertexUnderPixel(Pixel.x,Pixel.y,x,y,z);
Result.Import(x,y,z);
end;
{$ENDIF}

operator = (const A,B:TSGMatrix4):Boolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i,ii : LongWord;
begin
Result := True;
for i := 0 to 3 do
	for ii := 0 to 3 do
		if A[i][ii] <> B[i][ii] then
			begin
			Result := False;
			break;
			end;
end;

function SGGetRotateMatrix(const Angle:Single;const Axis:TSGVertex3f) : TSGMatrix4; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
    CosinusAngle, SinusAngle : Single;
begin
 Result:=SGGetIdentityMatrix();
 CosinusAngle:=cos(Angle);
 SinusAngle:=sin(Angle);
 Result[0,0]:=CosinusAngle+((1-CosinusAngle)*Axis.x*Axis.x);
 Result[1,0]:=((1-CosinusAngle)*Axis.x*Axis.y)-(Axis.z*SinusAngle);
 Result[2,0]:=((1-CosinusAngle)*Axis.x*Axis.z)+(Axis.y*SinusAngle);
 Result[0,1]:=((1-CosinusAngle)*Axis.x*Axis.z)+(Axis.z*SinusAngle);
 Result[1,1]:=CosinusAngle+((1-CosinusAngle)*Axis.y*Axis.y);
 Result[2,1]:=((1-CosinusAngle)*Axis.y*Axis.z)-(Axis.x*SinusAngle);
 Result[0,2]:=((1-CosinusAngle)*Axis.x*Axis.z)-(Axis.y*SinusAngle);
 Result[1,2]:=((1-CosinusAngle)*Axis.y*Axis.z)+(Axis.x*SinusAngle);
 Result[2,2]:=CosinusAngle+((1-CosinusAngle)*Axis.z*Axis.z);
end;

function SGGetScaleMatrix(const VVertex : TSGVertex3f): TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGGetIdentityMatrix();
Result[0][0] := VVertex.x;
Result[1][1] := VVertex.y;
Result[2][2] := VVertex.z;
end;

// �������������� �������
function SGInverseMatrix(const VSourseMatrix : TSGMatrix4) : TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
type
	TMatrix = array [0..15] of TSGMatrix4Type;

function mat(const  i : Byte) : TSGFloat; inline;
begin
Result := TMatrix(VSourseMatrix)[i];
end;

procedure ret(const i : byte; const f : TSGFloat); inline; overload;
begin
TMatrix(Result)[i] := f;
end;

var
	det,idet : TSGFloat;
begin
det:=((((((((mat(0)*mat(5)*mat(10))+(mat(4)*mat(9)*mat(2))))+(mat(8)*mat(1)*mat(6)))-(mat(8)*mat(5)*mat(2))))-(mat(4)*mat(1)*mat(10)))-(mat(0)*mat(9)*mat(6)));
if abs(det) < 0.0000001 then
	Result := SGGetIdentityMatrix()
else
	begin
	idet := 1/det;
	ret(0,(mat(5)*mat(10)-mat(9)*mat(6))*idet);
	ret(1,-(mat(1)*mat(10)-mat(9)*mat(2))*idet);
	ret(2, (mat(1)*mat(6)-mat(5)*mat(2))*idet);
	ret(3,0.0);
	ret(4,-(mat(4)*mat(10)-mat(8)*mat(6))*idet);
	ret(5, (mat(0)*mat(10)-mat(8)*mat(2))*idet);
	ret(6,-(mat(0)*mat(6)-mat(4)*mat(2))*idet);
	ret(7,0.0);
	ret(8, (mat(4)*mat(9)-mat(8)*mat(5))*idet);
	ret(9,-(mat(0)*mat(9)-mat(8)*mat(1))*idet);
	ret(10, (mat(0)*mat(5)-mat(4)*mat(1))*idet);
	ret(11,0.0);
	ret(12,-(mat(12)*TMatrix(Result)[0]+mat(13)*TMatrix(Result)[4]+mat(14)*TMatrix(Result)[8]));
	ret(13,-(mat(12)*TMatrix(Result)[1]+mat(13)*TMatrix(Result)[5]+mat(14)*TMatrix(Result)[9]));
	ret(14,-(mat(12)*TMatrix(Result)[2]+mat(13)*TMatrix(Result)[6]+mat(14)*TMatrix(Result)[10]));
	ret(15,1.0);
	end;
end;

procedure SGMultMatrixInRender(const VRender : ISGRender; Matrix : TSGMatrix4);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
VRender.MultMatrixf(@Matrix);
end;

function SGQuaternionLerp(q1,q2:TSGQuaternion; interp:TSGFloat):TSGQuaternion;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if ((q1 * q2) < 0) then
	Result := (q1 - ((q2 + q1) * interp))
else
	Result := (q1 + ((q2 - q1) * interp));
end;

operator + (const A,B : TSGQuaternion):TSGQuaternion;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Data[0] := A.Data[0] + B.Data[0];
Result.Data[1] := A.Data[1] + B.Data[1];
Result.Data[2] := A.Data[2] + B.Data[2];
Result.Data[3] := A.Data[3] + B.Data[3];
end;

operator - (const A   : TSGQuaternion):TSGQuaternion;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Data[0] := - A.Data[0];
Result.Data[1] := - A.Data[1];
Result.Data[2] := - A.Data[2];
Result.Data[3] := - A.Data[3];
end;

operator - (const A,B : TSGQuaternion):TSGQuaternion;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Data[0] := A.Data[0] - B.Data[0];
Result.Data[1] := A.Data[1] - B.Data[1];
Result.Data[2] := A.Data[2] - B.Data[2];
Result.Data[3] := A.Data[3] - B.Data[3];
end;

operator * (const A : TSGQuaternion;const B:TSGFloat32):TSGQuaternion;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Data[0] := A.Data[0] * B;
Result.Data[1] := A.Data[1] * B;
Result.Data[2] := A.Data[2] * B;
Result.Data[3] := A.Data[3] * B;
end;

operator * (const A,B : TSGQuaternion):TSGFloat;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := A.Data[0] * B.Data[0] + A.Data[1] * B.Data[1] + A.Data[2] * B.Data[2] + A.Data[3] * B.Data[3];
end;

procedure SGSetMatrixRotationQuaternion(var Matrix : TSGMatrix4;const Quat : TSGQuaternion);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Matrix[0,0]:= ( 1.0 - 2.0*Quat.Data[1]*Quat.Data[1] - 2.0*Quat.Data[2]*Quat.Data[2]);
Matrix[0,1]:= ( 2.0*Quat.Data[0]*Quat.Data[1] + 2.0*Quat.Data[3]*Quat.Data[2] );
Matrix[0,2]:= ( 2.0*Quat.Data[0]*Quat.Data[2] - 2.0*Quat.Data[3]*Quat.Data[1] );

Matrix[1,0]:= ( 2.0*Quat.Data[0]*Quat.Data[1] - 2.0*Quat.Data[3]*Quat.Data[2] );
Matrix[1,1]:= ( 1.0 - 2.0*Quat.Data[0]*Quat.Data[0] - 2.0*Quat.Data[2]*Quat.Data[2] );
Matrix[1,2]:= ( 2.0*Quat.Data[1]*Quat.Data[2] + 2.0*Quat.Data[3]*Quat.Data[0] );

Matrix[2,0]:= ( 2.0*Quat.Data[0]*Quat.Data[2] + 2.0*Quat.Data[3]*Quat.Data[1] );
Matrix[2,1]:= ( 2.0*Quat.Data[1]*Quat.Data[2] - 2.0*Quat.Data[3]*Quat.Data[0] );
Matrix[2,2]:= ( 1.0 - 2.0*Quat.Data[0]*Quat.Data[0] - 2.0*Quat.Data[1]*Quat.Data[1] );
end;

function SGTransformVector(const Matrix : TSGMatrix4; const Vec : TSGVertex3f):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Data[0]:= Vec.Data[0]*Matrix[0,0]+Vec.Data[1]*Matrix[1,0]+Vec.Data[2]*Matrix[2,0]+Matrix[3,0];
Result.Data[1]:= Vec.Data[0]*Matrix[0,1]+Vec.Data[1]*Matrix[1,1]+Vec.Data[2]*Matrix[2,1]+Matrix[3,1];
Result.Data[2]:= Vec.Data[0]*Matrix[0,2]+Vec.Data[1]*Matrix[1,2]+Vec.Data[2]*Matrix[2,2]+Matrix[3,2];
end;

function SGTranslateVectorInverse(const Matrix : TSGMatrix4;const Vec : TSGVertex3f):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Data[0]:= Vec.Data[0]-Matrix[3,0];
Result.Data[1]:= Vec.Data[1]-Matrix[3,1];
Result.Data[2]:= Vec.Data[2]-Matrix[3,2];
end;

function SGRotateVectorInverse(const Matrix : TSGMatrix4;const Vec : TSGVertex3f):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Data[0]:= Vec.Data[0]*Matrix[0,0]+Vec.Data[1]*Matrix[0,1]+Vec.Data[2]*Matrix[0,2];
Result.Data[1]:= Vec.Data[0]*Matrix[1,0]+Vec.Data[1]*Matrix[1,1]+Vec.Data[2]*Matrix[1,2];
Result.Data[2]:= Vec.Data[0]*Matrix[2,0]+Vec.Data[1]*Matrix[2,1]+Vec.Data[2]*Matrix[2,2];
end;

function SGMultiplyPartMatrix(const m1:TSGMatrix4;const m2:TSGMatrix4):TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result[0,0]:= m1[0,0]*m2[0,0] + m1[1,0]*m2[0,1] + m1[2,0]*m2[0,2];
Result[0,1]:= m1[0,1]*m2[0,0] + m1[1,1]*m2[0,1] + m1[2,1]*m2[0,2];
Result[0,2]:= m1[0,2]*m2[0,0] + m1[1,2]*m2[0,1] + m1[2,2]*m2[0,2];
Result[0,3]:= 0;

Result[1,0]:= m1[0,0]*m2[1,0] + m1[1,0]*m2[1,1] + m1[2,0]*m2[1,2];
Result[1,1]:= m1[0,1]*m2[1,0] + m1[1,1]*m2[1,1] + m1[2,1]*m2[1,2];
Result[1,2]:= m1[0,2]*m2[1,0] + m1[1,2]*m2[1,1] + m1[2,2]*m2[1,2];
Result[1,3]:= 0;

Result[2,0]:= m1[0,0]*m2[2,0] + m1[1,0]*m2[2,1] + m1[2,0]*m2[2,2];
Result[2,1]:= m1[0,1]*m2[2,0] + m1[1,1]*m2[2,1] + m1[2,1]*m2[2,2];
Result[2,2]:= m1[0,2]*m2[2,0] + m1[1,2]*m2[2,1] + m1[2,2]*m2[2,2];
Result[2,3]:= 0;

Result[3,0]:= m1[0,0]*m2[3,0] + m1[1,0]*m2[3,1] + m1[2,0]*m2[3,2] + m1[3,0];
Result[3,1]:= m1[0,1]*m2[3,0] + m1[1,1]*m2[3,1] + m1[2,1]*m2[3,2] + m1[3,1];
Result[3,2]:= m1[0,2]*m2[3,0] + m1[1,2]*m2[3,1] + m1[2,2]*m2[3,2] + m1[3,2];
Result[3,3]:= 1;
end;

procedure SGSetMatrixRotation(var Matrix : TSGMatrix4;const Angles : TSGVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var cr,sr,cp,sp,cy,sy,
	srsp,crsp         : single;
begin
cr:= cos(angles.Data[0]);
sr:= sin(angles.Data[0]);
cp:= cos(angles.Data[1]);
sp:= sin(angles.Data[1]);
cy:= cos(angles.Data[2]);
sy:= sin(angles.Data[2]);

matrix[0][0]:=cp*cy;
matrix[0][1]:=cp*sy;
matrix[0][2]:=-sp;

srsp:= sr*sp;
crsp:= cr*sp;

matrix[1][0]:= srsp*cy-cr*sy;
matrix[1][1]:= srsp*sy+cr*cy;
matrix[1][2]:= sr*cp;

matrix[2][0]:= crsp*cy+sr*sy;
matrix[2][1]:= crsp*sy-sr*cy;
matrix[2][2]:= cr*cp;
end;

procedure SGSetMatrixTranslation(var Matrix : TSGMatrix4; const Trans : TSGVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
 matrix[3,0]:=trans.x;
 matrix[3,1]:=trans.y;
 matrix[3,2]:=trans.z;
end;

function SGQuaternionSlerp(q1,q2:TSGQuaternion; interp:TSGFloat):TSGQuaternion;
var i           : integer;
	a,b         : single;
	cosom       : single;
	sclq1,sclq2 : single;
	omega,sinom : single;

begin
a:=0;
b:=0;
for i:=0 to 3 do
	begin
	a:=a+( q1.Data[i]-q2.Data[i] )*( q1.Data[i]-q2.Data[i] );
	b:=b+( q1.Data[i]+q2.Data[i] )*( q1.Data[i]+q2.Data[i] );
	end;
if ( a > b ) then
	q2.Inverse();

cosom:=q1.Data[0]*q2.Data[0]+q1.Data[1]*q2.Data[1]
	+q1.Data[2]*q2.Data[2]+q1.Data[3]*q2.Data[3];

if (( 1.0+cosom ) > 0.00000001 ) then
	begin
	if (( 1.0-cosom ) > 0.00000001 ) then
		begin
		omega:= arccos( cosom );
		sinom:= sin( omega );
		sclq1:= sin(( 1.0-interp )*omega )/sinom;
		sclq2:= sin( interp*omega )/sinom;
		end
	else
		begin
		sclq1:= 1.0-interp;
		sclq2:= interp;
		end;
	for i:=0 to 3 do
		result.data[i]:=sclq1*q1.data[i]
			+sclq2*q2.data[i];
	end
else
	with result do
		begin
		data[0]:=-q1.data[1];
		data[1]:=q1.data[0];
		data[2]:=-q1.data[3];
		data[3]:=q1.data[2];
		sclq1:= sin(( 1.0-interp )*0.5*PI );
		sclq2:= sin( interp*0.5*PI );
		for i:=0 to 2 do
			data[i]:=sclq1*q1.data[i]
				+sclq2*data[i];
		end;
end;

function SGGetQuaternionFromAngleVector3f(const Angles : TSGVertex3f):TSGQuaternion;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var angle             : single;
    sr,sp,sy,cr,cp,cy : single;
    crcp,srsp         : single;
begin
angle:=angles.z*0.5;
sy:=sin( angle );
cy:=cos( angle );
angle:= angles.y*0.5;
sp:= sin( angle );
cp:= cos( angle );
angle:= angles.x*0.5;
sr:= sin( angle );
cr:= cos( angle );

crcp:= cr*cp;
srsp:= sr*sp;

Result.Import(
	sr*cp*cy-cr*sp*sy,
	cr*sp*cy+sr*cp*sy,
	crcp*sy -srsp*cy,
	crcp*cy +srsp*sy);
end;

procedure TSGQuaternion.Inverse();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
x := -x;
y := -y;
z := -z;
w := -w;
end;

function TSGQuaternion.Intersed():TSGQuaternion;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(-x,-y,-z,-w);
end;

function SGRotatePoint(const Point : TSGVertex3f; const Os : TSGVertex3f; const Angle : TSGSingle):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
Procedure RotatePoint(Var Xp, Yp, Zp: TSGSingle;const Xv, Yv, Zv, Angle: TSGSingle); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Temp, TempV, Nx, Ny, Nz: TSGSingle;
	C, S : TSGSingle;
Begin
C := Cos(Angle);
S := Sin(Angle);
Temp := 1.0 - C;

TempV := Temp * Xv;
Nx:=Xp * (Xv * TempV + C) +
	Yp * (Yv * TempV - S * Zv) +
	Zp * (Zv * TempV + S * Yv);

TempV := Temp * Yv;
Ny:=Xp * (Xv * TempV + S * Zv) +
	Yp * (Yv * TempV + C) +
	Zp * (Zv * TempV - S * Xv);

TempV := Temp * Zv;
Nz:=Xp * (Xv * TempV - S * Yv) +
	Yp * (Yv * TempV + S * Xv) +
	Zp * (Zv * TempV + C);

Xp:=Nx;
Yp:=Ny;
Zp:=Nz;
End;
begin
Result := Point;
RotatePoint (Result.x, Result.y, Result.z, Os.x, Os.y, Os.z, Angle);
end;

function SGGetTranslateMatrix(const Vertex : TSGVertex3f):TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGByte;
begin
FillChar(Result,SizeOf(Result),0);
for i:=0 to 3 do
	Result[i,i]:=1;
Result[3,0]:=Vertex.x;
Result[3,1]:=Vertex.y;
Result[3,2]:=Vertex.z;
end;

function SGGetIdentityMatrix():TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGByte;
begin
FillChar(Result,SizeOf(Result),0);
for i:=0 to 3 do
	Result[i,i]:=1;
end;

function SGGetOrthoMatrix(const l,r,b,t,vNear,vFar:TSGMatrix4Type):TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	m:TSGMatrix4;
	i,ii:byte;
begin
Result:=SGMatrix4Import(
	2/(r-l),0,0,-((r+l)/(r-l)),
	0,2/(t-b),0,-((t+b)/(t-b)),
	0,0,-2/(vFar-vNear),-((vFar+vNear)/(vFar-vNear)),
	0,0,0,1);
for i:=0 to 3 do
	for ii:=0 to 3 do
		m[i,ii]:=Result[ii,i];
Result:=m;
end;

procedure SGWriteMatrix4(const P:TSGPointer);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
type
	PTSGMatrix4Type=^TSGMatrix4Type;
var
	i : TSGByte;
begin
textcolor(10);
for i:=0 to 15 do
	begin
	Write(PTSGMatrix4Type(P)[i]:0:10,' ');
	if (i+1)mod 4 = 0 then
		WriteLn();
	end;
Textcolor(7);
end;

operator * (const A:TSGVertex3f;const B:TSGMatrix4):TSGVertex3f;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C:TSGVertex4f;
begin
C.Import(A.x,A.y,A.z,1);
Result:=C*B;
end;

operator * (const A:TSGVertex4f;const B:TSGMatrix4):TSGVertex4f;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
type
	PTSGFloat32 = ^ TSGFloat32;
var
	i,k:TSGWord;
begin
FillChar(Result,Sizeof(Result),0);
for i:=0 to 3 do
	for k:=0 to 3 do
		PTSGFloat32(@Result)[i]+=PTSGFloat32(@A)[k]*B[i,k];
end;

operator * (const A,B:TSGMatrix4):TSGMatrix4;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i,j,k:byte;
begin
FillChar(Result,Sizeof(Result),0);
for i:=0 to 3 do
	for j:=0 to 3 do
		for k:=0 to 3 do
			Result[i,j]+=A[i,k]*B[k,j];
end;

function SGMatrix4Import(const _0x0,_0x1,_0x2,_0x3,_1x0,_1x1,_1x2,_1x3,_2x0,_2x1,_2x2,_2x3,_3x0,_3x1,_3x2,_3x3:TSGMatrix4Type):TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result[0,0]:=_0x0;
Result[0,1]:=_0x1;
Result[0,2]:=_0x2;
Result[0,3]:=_0x3;
Result[1,0]:=_1x0;
Result[1,1]:=_1x1;
Result[1,2]:=_1x2;
Result[1,3]:=_1x3;
Result[2,0]:=_2x0;
Result[2,1]:=_2x1;
Result[2,2]:=_2x2;
Result[2,3]:=_2x3;
Result[3,0]:=_3x0;
Result[3,1]:=_3x1;
Result[3,2]:=_3x2;
Result[3,3]:=_3x3;
end;

function SGGetFrustumMatrix(const vleft,vright,vbottom,vtop,vnear,vfar:TSGMatrix4Type):TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=SGMatrix4Import(
	2.0 * vnear / (vright - vleft), 0, 0, 0,
	0, 2.0 * vnear / (vtop - vbottom), 0, 0,
	(vright + vleft) / (vright - vleft), (vtop + vbottom) / (vtop - vbottom), -(vfar + vnear) / (vfar - vnear), -1.0,
	0,0, -2.0 * vfar * vnear / (vfar - vnear), 0);
end;

function SGGetPerspectiveMatrix(const vAngle,vAspectRatio,vNear,vFar:TSGMatrix4Type):TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	vTop:Single;
begin
vTop := vNear * Math.tan(vAngle * 3.1415927 / 360.0);
Result:=SGGetFrustumMatrix(
	(-vTop)*vAspectRatio,vTop*vAspectRatio,-vTop,vTop,vNear,vFar);
end;

function SGTranslateMatrix(const VMatrix : TSGMatrix4; const VVertex : TSGVertex3f):TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := VMatrix;
Result[3,0]:=Result[0,0]*VVertex.x+Result[1,0]*VVertex.y+Result[2,0]*VVertex.z+Result[3,0];
Result[3,1]:=Result[0,1]*VVertex.x+Result[1,1]*VVertex.y+Result[2,1]*VVertex.z+Result[3,1];
Result[3,2]:=Result[0,2]*VVertex.x+Result[1,2]*VVertex.y+Result[2,2]*VVertex.z+Result[3,2];
Result[3,3]:=Result[0,3]*VVertex.x+Result[1,3]*VVertex.y+Result[2,3]*VVertex.z+Result[3,3];
end;

function SGGetLookAtMatrix(const Eve, At:TSGVertex3f;Up:TSGVertex3f):TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	vForward,vSide:TSGVertex3f;
begin
vForward :=   (Eve - At).Normalized();
vSide := (Up * vForward).Normalized();
Up := (vForward * vSide).Normalized();
Result := SGMatrix4Import(
	vside.x, up.x, vforward.x, 0,
	vside.y, up.y, vforward.y, 0,
	vside.z, up.z, vforward.z, 0,
	0, 0, 0, 1);
Result := SGTranslateMatrix(Result, -Eve);
end;

operator + (const a,b:TSGPosition):TSGPosition;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.CustomPos := a.CustomPos + b.CustomPos;
end;

operator + (const a,b:TSGCustomPosition):TSGCustomPosition;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.FLocation := a.FLocation + b.FLocation;
Result.FTurn := a.FTurn + b.FTurn;
end;

procedure TSGScreenVertexes.ProcSumX(r:Real);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Vertexes[0].x+=r;
Vertexes[1].x+=r;
end;

procedure TSGScreenVertexes.ProcSumY(r:Real);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Vertexes[0].y+=r;
Vertexes[1].y+=r;
end;

procedure TSGScreenVertexes.Write;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Vertexes[0].Write();
System.Write(' ');
Vertexes[1].WriteLn();
end;

operator * (const a:TSGScreenVertexes;const b:real):TSGScreenVertexes;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	x,y,x1,y1:real;
begin
x:=(a.x1+a.x2)/2;
y:=(a.y1+a.y2)/2;
x1:=abs(a.x1-x);
y1:=abs(a.y1-y);
x1*=b;
y1*=b;
Result.Import(
	x-x1,
	y-y1,
	x+x1,
	y+y1);
end;

procedure TSGScreenVertexes.Import(const x1:real = 0;const y1:real = 0;const x2:real = 0;const y2:real = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Vertexes[0].x:=x1;
Vertexes[0].y:=y1;
Vertexes[1].x:=x2;
Vertexes[1].y:=y2;
end;

procedure SGWndSomeQuad(const a,c: TSGVertex3f;const VRender:ISGRender);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	b,d: TSGVertex3f;
begin
b.Import(c.x,a.y,a.z);
d.Import(a.x,c.y,a.z);
VRender.BeginScene(SGR_QUADS);
VRender.TexCoord2f(0,1);VRender.Vertex(a);
VRender.TexCoord2f(1,1);VRender.Vertex(b);
VRender.TexCoord2f(1,0);VRender.Vertex(c);
VRender.TexCoord2f(0,0);VRender.Vertex(d);
VRender.EndScene();
end;

procedure SGSomeQuad(a,b,c,d: TSGVertex3f;vl,np:TSGPoint2int32;const VRender:ISGRender);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
VRender.BeginScene(SGR_QUADS);
VRender.TexCoord2f(vl.x, vl.y);
VRender.Vertex(a);
VRender.TexCoord2f(np.x, vl.y);
VRender.Vertex(b);
VRender.TexCoord2f(np.x, np.y);
VRender.Vertex(c);
VRender.TexCoord2f(vl.x, np.y);
VRender.Vertex(d);
VRender.EndScene();
end;

procedure SGRoundWindowQuad(const VRender:ISGRender;const Vertex11,Vertex13: TSGVertex3f;const Vertex21,Vertex23: TSGVertex3f;
	const Radius1:real;const Radius2:real; const Interval:LongInt;const QuadColor1: TSGColor4f;const QuadColor2: TSGColor4f;
	const WithLines:boolean; const LinesColor1: TSGColor4f; const LinesColor2: TSGColor4f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SGRoundQuad(VRender,Vertex11,Vertex13,Radius1,Interval,QuadColor1,LinesColor1,WithLines);
SGRoundQuad(VRender,Vertex21,Vertex23,Radius2,Interval,QuadColor2,LinesColor2,WithLines);
end;

procedure SGRoundQuad(
	const VRender:ISGRender;
	const Vertex12,Vertex32: TSGVertex2f;
	const Radius:real;
	const Interval:LongInt;
	const QuadColor: TSGColor4f;
	const LinesColor: TSGColor4f;
	const WithLines:boolean = False;
	const WithQuad:boolean = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	ArVertex : TSGVertex3fList = nil;
	Vertex1, Vertex3 : TSGVertex3f;
begin
Vertex1.Import(Vertex12.x, Vertex12.y);
Vertex3.Import(Vertex32.x, Vertex32.y);
ArVertex := SGGetArrayOfRoundQuad(Vertex1,Vertex3,Radius,Interval);
SGConstructRoundQuad(VRender,ArVertex,Interval,QuadColor,LinesColor,WithLines,WithQuad);
SetLength(ArVertex,0);
end;

procedure SGRoundQuad(
	const VRender:ISGRender;
	const Vertex1,Vertex3: TSGVertex3f;
	const Radius:real;
	const Interval:LongInt;
	const QuadColor: TSGColor4f;
	const LinesColor: TSGColor4f;
	const WithLines:boolean = False;
	const WithQuad:boolean = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	ArVertex : TSGVertex3fList = nil;
begin
ArVertex := SGGetArrayOfRoundQuad(Vertex1,Vertex3,Radius,Interval);
SGConstructRoundQuad(VRender,ArVertex,Interval,QuadColor,LinesColor,WithLines,WithQuad);
SetLength(ArVertex,0);
end;

function SGGetArrayOfRoundQuad(const Vertex1,Vertex3: TSGVertex3f; const Radius:real; const Interval:LongInt):TSGVertex3fList;
var
	Vertex2,Vertex4: TSGVertex3f;
	VertexR1,VertexR2,VertexR3,VertexR4: TSGVertex3f;
	I,ii:LongInt;
begin
Result:=nil;
Vertex2.Import(Vertex3.x,Vertex1.y,(Vertex1.z+Vertex3.z)/2);
Vertex4.Import(Vertex1.x,Vertex3.y,(Vertex1.z+Vertex3.z)/2);
VertexR1.Import(Vertex1.x+Radius,Vertex1.y-Radius,Vertex1.z);
VertexR2.Import(Vertex2.x-Radius,Vertex2.y-Radius,Vertex2.z);
VertexR3.Import(Vertex3.x-Radius,Vertex3.y+Radius,Vertex3.z);
VertexR4.Import(Vertex4.x+Radius,Vertex4.y+Radius,Vertex4.z);
SetLength(Result,Interval*4+4);
ii:=0;
For i:=0 to Interval do
	begin
	Result[ii].Import(VertexR2.x+cos((Pi/2)/(Interval)*i)*Radius,VertexR2.y+sin((Pi/2)/(Interval)*i+Pi)*Radius+2*Radius,VertexR2.z);
	ii+=1;
	end;
For i:=0 to Interval do
	begin
	Result[ii].Import(VertexR1.x+cos((Pi/2)*i/(Interval)+Pi/2)*Radius,VertexR1.y+sin((Pi/2)*i/(Interval)+3*Pi/2)*Radius+2*Radius,VertexR1.z);
	ii+=1;
	end;
For i:=0 to Interval do
	begin
	Result[ii].Import(VertexR4.x+cos((Pi/2)*i/Interval+Pi)*Radius,VertexR4.y+sin((Pi/2)*i/(Interval))*Radius-2*Radius,VertexR4.z);
	ii+=1;
	end;
For i:=0 to Interval do
	begin
	Result[ii].Import(VertexR3.x+cos((Pi/2)*i/(Interval)+3*Pi/2)*Radius,VertexR3.y+sin((Pi/2)*i/(Interval)+Pi/2)*Radius-2*Radius,VertexR3.z);
	ii+=1;
	end;
end;

procedure SGConstructRoundQuad(
	const VRender:ISGRender;
	const ArVertex:TSGVertex3fList;
	const Interval:LongInt;
	const QuadColor: TSGColor4f;
	const LinesColor: TSGColor4f;
	const WithLines:boolean = False;
	const WithQuad:boolean = True);
var
	I:LongInt;
begin
if WithQuad then
	begin
	VRender.Color(QuadColor);
	VRender.BeginScene(SGR_QUADS);
	for i:=0 to Interval-1 do
		begin
		VRender.Vertex(ArVertex[Interval-i]);
		VRender.Vertex(ArVertex[Interval+1+i]);
		VRender.Vertex(ArVertex[Interval+2+i]);
		VRender.Vertex(ArVertex[Interval-i-1]);
		end;
	VRender.Vertex(ArVertex[0]);
	VRender.Vertex(ArVertex[2*Interval+1]);
	VRender.Vertex(ArVertex[2*Interval+2]);
	VRender.Vertex(ArVertex[4*(Interval+1)-1]);
	for i:=0 to Interval-1 do
		begin
		VRender.Vertex(ArVertex[(Interval+1)*2+i]);
		VRender.Vertex(ArVertex[(Interval+1)*2+i+1]);
		VRender.Vertex(ArVertex[(Interval+1)*4-2-i]);
		VRender.Vertex(ArVertex[(Interval+1)*4-1-i]);
		end;
	VRender.EndScene();
	end;
if WithLines then
	begin
	VRender.Color(LinesColor);
	VRender.BeginScene(SGR_LINE_LOOP);
	for i:=Low(ArVertex) to High(ArVertex) do
		VRender.Vertex(ArVertex[i]);
	VRender.EndScene();
	end;
end;

function SGComplexNumberImport(const x:real = 0;const y:real = 0):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(x,y);
end;

function SGVertex2fImport(const x:real = 0;const y:real = 0):TSGVertex2f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(x,y);
end;

operator - (const a,b:TSGComplexNumber):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(a.x-b.x,a.y-b.y);
end;

operator / (const a,b:TSGComplexNumber):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(
	(a.x*b.x+a.y*b.y)/(b.x*b.x-b.y*b.y),
	(a.y*b.x-a.x*b.y)/(b.x*b.x-b.y*b.y));
end;

operator * (const a,b:TSGComplexNumber):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
result.Import(a.x*b.x-a.y*b.y,a.x*b.y+b.x*a.y);
end;

operator + (const a,b:TSGComplexNumber):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(a.x+b.x,a.y+b.y);
end;

procedure SGQuickRePlaceVertexType(var LongInt1,LongInt2:TSGFloat32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	a:TSGFloat32;
begin
a:=LongInt1;
LongInt1:=LongInt2;
LongInt2:=a;
end;

operator ** (const a:TSGComplexNumber;const b:LongInt):TSGComplexNumber;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	i:LongInt;
begin
Result.Import(1,0);
for i:=1 to b do
	Result*=a;
end;


function TSGScreenVertexes.AbsX:TSGFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=Abs(X1-X2);
end;

function TSGScreenVertexes.AbsY:TSGFloat32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=Abs(Y1-Y2);
end;

function TSGScreenVertexes.VertexInView(const Vertex:TSGVertex2f):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=(Vertex.x<SGMax(X1,X2)) and
	(Vertex.y<SGMax(Y1,Y2)) and
	(Vertex.x>SGMin(X1,X2)) and
	(Vertex.y>SGMin(Y1,Y2));
end;

function SGGetColor4fFromLongWord(const LongWordColor:LongWord;const WithAlpha:Boolean = False): TSGColor4f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
type
	LongWordByteArray = packed array [0..3] of byte;
begin
if WithAlpha then
	begin
	Result.Import(
		LongWordByteArray(LongWordColor)[3]/255,
		LongWordByteArray(LongWordColor)[2]/255,
		LongWordByteArray(LongWordColor)[1]/255,
		LongWordByteArray(LongWordColor)[0]/255);

	end
else
	begin
	Result.Import(
		LongWordByteArray(LongWordColor)[2]/255,
		LongWordByteArray(LongWordColor)[1]/255,
		LongWordByteArray(LongWordColor)[0]/255,
		1);
	end;
end;

operator = (const a,b:TSGComplexNumber):Boolean;overload;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=(a.x=b.x) and (b.y=a.y);
end;

function SGGetPointsCirclePoints(const FPoints:TSGVertex2fList):TSGArLongWord;

function GetNext(const p1,p2:LongWord):LongWord;
var
	a2,// квадрат альфа
	b2,//квадрат бетта
	TemCos,//Косиеус сейчас
	MinCos,//Охуенный косинус, который нада найти
	a:single;
	i:LongWord;

begin
MinCos:=1;
Result:=Length(FPoints);
a2:=(sqr(FPoints[p1].x-FPoints[p2].x)+sqr(FPoints[p1].y-FPoints[p2].y));
a:=sqrt(a2);
for i:=0 to High(FPoints) do
	if (i<>p1) and (i<>p2) then
		begin
		b2:=(sqr(FPoints[i].x-FPoints[p2].x)+sqr(FPoints[i].y-FPoints[p2].y));
		TemCos:=((sqr(FPoints[i].x-FPoints[p1].x)+sqr(FPoints[i].y-FPoints[p1].y))-a2-b2)/(-2*a*sqrt(b2));
		if (TemCos<MinCos) then
			begin
			Result:=i;
			MinCos:=TemCos;
			end;
		end;
if Result=Length(FPoints) then
	raise  Exception.Create('Ebat ti loh!!!');
end;

vAR
	I,ii:LongWord;
begin
SetLength(Result,2);
Result[0]:=0;
Result[1]:=1;
repeat
ii:=GetNext(Result[High(Result)-1],Result[High(Result)]);
SetLength(Result,Length(Result)+1);
Result[High(Result)]:=ii;
ii:=0;
for i:=1 to High(Result)-2 do
	begin
	if (Result[i]=Result[High(Result)])  and (Result[i-1]=Result[High(Result)-1])then
		begin
		ii:=1;
		break;
		end;
	end;
until (ii=1);
for ii:=i+1 to High(Result) do
	begin
	Result[ii-i-1]:=Result[ii];
	end;
SetLength(Result,Length(Result)-i-1);
end;

function SGTSGVertex3fImport(const x:real = 0;const y:real = 0;const z:real = 0):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.x:=x;
Result.y:=y;
Result.z:=z;
end;

function SGGetVertexInAttitude(const t1,t2:TSGVertex3f; const r:real = 0.5):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(
	-r*(t1.x-t2.x)+t1.x,
	-r*(t1.y-t2.y)+t1.y,
	-r*(t1.z-t2.z)+t1.z);
end;

function SGGetVertexOnIntersectionOfTwoLinesFromFourVertex(const q1,q2,w1,w2: TSGVertex3f): TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	q3: TSGVertex3f;
begin
q3:=q2;
q3+=SGGetVertexWhichNormalFromThreeVertex(q1,q2,w1);
Result:=SGGetVertexOnIntersectionOfThreePlane(
	SGGetPlaneFromThreeVertex(q1,q2,q3),
	SGGetPlaneFromThreeVertex(SGGetVertexInAttitude(q1,q2),w1,w2),
	SGGetPlaneFromThreeVertex(SGGetVertexInAttitude(q1,q3),w1,w2));
end;

function SGGetPlaneFromThreeVertex(const a1,a2,a3: TSGVertex3f):SGPlane;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=SGGetPlaneFromNineReals(a1.x,a1.y,a1.z,a2.x,a2.y,a2.z,a3.x,a3.y,a3.z);
end;

function SGGetVertexWhichNormalFromThreeVertex(const p1,p2,p3: TSGVertex3f): TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var a,b,c:real;
begin
a:=p1.y*(p2.z-p3.z)+p2.y*(p3.z-p1.z)+p3.y*(p1.z-p2.z);
b:=p1.z*(p2.x-p3.x)+p2.z*(p3.x-p1.x)+p3.z*(p1.x-p2.x);
c:=p1.x*(p2.y-p3.y)+p2.x*(p3.y-p1.y)+p3.x*(p1.y-p2.y);
Result.Import(a/(sqrt(a*a+b*b+c*c)),b/(sqrt(a*a+b*b+c*c)),c/(sqrt(a*a+b*b+c*c)));
end;

function SGTreugPlosh(const a1,a2,a3: TSGVertex3f):real;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	p:real;
begin
p:=(Abs(a1 - a2)+Abs(a1 - a3)+Abs(a3 - a2))/2;
SGTreugPlosh:=sqrt(p*(p-Abs(a1 - a2))*(p-Abs(a3 - a2))*(p-Abs(a1 - a3)));
end;

function SGVertexOnQuad(const Vertex: TSGVertex3f; const QuadVertex1: TSGVertex3f;const QuadVertex3: TSGVertex3f):boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=SGVertexOnQuad(
	Vertex,
	QuadVertex1,
	SGVertex3fImport(
		QuadVertex1.x,
		QuadVertex3.y,
		QuadVertex1.z),
	QuadVertex3,
	SGVertex3fImport(
		QuadVertex3.x,
		QuadVertex1.y,
		QuadVertex3.z));
end;

function SGVertexOnQuad(const Vertex: TSGVertex3f; const QuadVertex1: TSGVertex3f;const QuadVertex2: TSGVertex3f;const QuadVertex3: TSGVertex3f;const QuadVertex4: TSGVertex3f):boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if abs(
	(Abs(QuadVertex1 - QuadVertex2)*Abs(QuadVertex2 - QuadVertex3))
	-
	(
		SGTreugPlosh(Vertex,QuadVertex1,QuadVertex2)+
		SGTreugPlosh(Vertex,QuadVertex2,QuadVertex3)+
		SGTreugPlosh(Vertex,QuadVertex3,QuadVertex4)+
		SGTreugPlosh(Vertex,QuadVertex4,QuadVertex1))
	)>SGZero then
	Result:=False
else
	Result:=True;
end;

function SGGetVertexOnIntersectionOfThreePlane(p1,p2,p3:SGPlane): TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var de,de1,de2,de3:real;
begin
p1.d:=-1*(p1.d);
p2.d:=-1*(p2.d);
p3.d:=-1*(p3.d);
de:=SGGetMatrix3x3(p1.a,p1.b,p1.c,p2.a,p2.b,p2.c,p3.a,p3.b,p3.c);
de1:=SGGetMatrix3x3(p1.d,p1.b,p1.c,p2.d,p2.b,p2.c,p3.d,p3.b,p3.c);
de2:=SGGetMatrix3x3(p1.a,p1.d,p1.c,p2.a,p2.d,p2.c,p3.a,p3.d,p3.c);
de3:=SGGetMatrix3x3(p1.a,p1.b,p1.d,p2.a,p2.b,p2.d,p3.a,p3.b,p3.d);
Result.Import(de1/de,de2/de,de3/de);
end;

function SGX(const v:Single):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(v,0,0);
end;

function SGY(const v:Single):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(0,v,0);
end;

function SGZ(const v:Single):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(0,0,v);
end;

end.
