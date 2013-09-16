
{$IFDEF MSWINDOWS}
	{$R SaGe.res}
	{$ENDIF}

{$i SaGe.inc}

unit SaGe;

interface

uses 
	crt
	,gl
	,glu
	,glext
	,Classes
	,SysUtils
	{$IFDEF GLUT}
		,glut 
		{$ENDIF}
	,dos
	{$IFDEF MSWINDOWS}
		,windows
		{$ENDIF}
	{$IFDEF UNIX}
		,unix
		,Dl
		,x
		,xlib
		,xutil
		,glx
		{$ENDIF}
	{$IFDEF LAZARUS}
		,OpenGLContext
		,Forms
		,Controls
		{$ENDIF}
	,SaGeImages
	,SaGeBase
	,DynLibs
	;
const
	{$IFDEF GLUT}
		SGGLUTDLL = 
		{$IFDEF MSWINDOWS}
			'glut32.dll';
		{$ELSE}
			{$IFDEF darwin}
				'/System/Library/Frameworks/GLUT.framework/GLUT';
			{$ELSE}
				{$IFDEF MORPHOS}
					'libglut.so.3';
				{$ELSE}
					'';
					{$ENDIF}
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
	SGMethodLoginToOpenGLUnInstalled = 0;
	SGMethodLoginToOpenGLWinAPI =        $000001;
	SGMethodLoginToOpenGLLazarus =       $000002;
	SGMethodLoginToOpenGLGLUT =          $00000C;
	SGMethodLoginToOpenGLGLX =           $000027;
	SGMethodLoginToOpenGLUnix = SGMethodLoginToOpenGLGLX;
	SGMethodLoginToOpenGLLinux = SGMethodLoginToOpenGLUnix;
	
	SGFrameButtonsType0f =               $000003;
	SGFrameButtonsTypeCleared = SGFrameButtonsType0f;
	SGFrameButtonsType1f =               $000004;
	SGFrameButtonsType3f =               $000005;
	
	SGObjectTimerConst : real = 0.02;
	
	SGFrameAnimationConst = 200;
	SGFrameFObject = 5;
	SGFrameFNObject = 1;
	
	SGAlignNone =                        $000006;
	SGAlignLeft =                        $000007;
	SGAlignRight =                       $000008;
	SGAlignTop =                         $000009;
	SGAlignBottom =                      $00000A;
	SGAlignClient =                      $00000B;
	
	SGAnchorRight =                      $00000D;
	SGAnchorLeft =                       $00000E;
	SGAnchorTop =                        $00000F;
	SGAnchorBottom =                     $000010;
	
	SG_2D =                              $000011;
	SG_3D =                              $000012;
	
	SG_VERTEX_FOR_CHILDREN =             $000013;
	SG_VERTEX_FOR_PARENT =               $000014;
	
	SG_LEFT =                            $000015;
	SG_TOP =                             $000016;
	SG_HEIGHT =                          $000017;
	SG_WIDTH =                           $000018;
	SG_RIGHT =                           $000019;
	SG_BOTTOM =                          $00001A;
	
	SG_VARIABLE =                        $00001B;
	SG_CONST =                           $00001C;
	SG_OPERATOR =                        $00001D;
	SG_BOOLEAN =                         $00001E;
	SG_REAL =                            $00001F;
	SG_NUMERIC =                         $000020;
	SG_OBJECT =                          $000021;
	SG_NONE =                            $000022;
	SG_NOTHINC = SG_NONE;
	SG_NOTHINK = SG_NONE;
	SG_FUNCTION =                        $000023;
	
	SG_ERROR =                           $000024;
	SG_WARNING =                         $000025;
	SG_NOTE =                            $000026;
type
	{$IFDEF SGDebuging}
		(*$NOTE type*)
		{$ENDIF}
	
	TSGPoint2f=object
		x,y:longint;
		procedure Import(const x1:longint = 0; const y1:longint = 0);
		procedure Write;
		procedure Vertex;
		end;
	TSGPoint = TSGPoint2f;
	SGPoint = TSGPoint2f;
	SGPoint2f = TSGPoint2f;
	PSGPoint = ^ SGPoint;
	
	TSGPoint3f=object(SGPoint)
		z:longint;
		end;
	SGPoint3f = TSGPoint3f;
	PSGPoint3f = ^ SGPoint3f;
	
	TSGVertexType = type single;
	
	TSGVertex2f=object
		x,y:TSGVertexType;
		procedure Vertex;
		procedure TexCoord;
		procedure SetVariables(const x1:real = 0; const y1:real = 0);
		procedure Import(const x1:real = 0;const y1:real = 0);
		procedure Write;
		procedure WriteLn;
		procedure Round;overload;
		procedure Translate;
		end;
	PTSGVertex2f=^TSGVertex2f;
	TArTSGVertex2f = type packed array of TSGVertex2f;
	PTArTSGVertex2f = ^TArTSGVertex2f;
	SGVertex2f = TSGVertex2f;
	Vertex2f = TSGVertex2f;
	
	TSGComplexNumber = object(TSGVertex2f)
		end;
	
	TSGVertex3f=object(TSGVertex2f)
		z:TSGVertexType;
		procedure Vertex;inline;
		procedure SetVariables(const x1:real = 0; const y1:real = 0; const z1:real = 0);inline;
		procedure Import(const x1:real = 0; const y1:real = 0; const z1:real = 0);inline;
		procedure Normal;
		procedure LightPosition(const Ligth:LongInt = GL_LIGHT0);inline;
		procedure VertexPoint;
		procedure Write;inline;
		procedure WriteLn;inline;
		procedure Vertex(Const P:Pointer);inline;
		procedure Normalize;
		procedure ReadFromTextFile(const Fail:PTextFile);
		procedure ReadLnFromTextFile(const Fail:PTextFile);
		procedure Translate;inline;
		end;
	SGVertex3f=TSGVertex3f;
	SGVertex=SGVertex3f;
	TSGVertex=SGVertex;
	PTSGVertex3f=^TSGVertex3f;
	PSGVertex = PTSGVertex3f;
	PSGVertex3f = PTSGVertex3f;
	TArTSGVertex3f = type packed array of TSGVertex3f;
	ArrayOfTSGVertex3f = TArTSGVertex3f;
	TArTSGVertex = TArTSGVertex3f;
	TArSGVertex = TArTSGVertex3f;
	ArSGVertex = TArTSGVertex3f;
	TSGArTSGVertex = TArTSGVertex3f;
	TSGArSGVertex = TArTSGVertex3f;
	SGArTSGVertex = TArTSGVertex3f;
	SGArSGVertex = TArTSGVertex3f;
	SGArVertex = TArTSGVertex3f;
	ArVertex = TArTSGVertex3f;
	PTArTSGVertex3f = ^TArTSGVertex3f;
	TSGVertexFunction = function (a:SGVertex):SGVertex;
	
	TSGScreenVertexes=object
		Vertexes:array[0..1] of TSGVertex2f;
		procedure Import(const x1:real = 0;const y1:real = 0;const x2:real = 0;const y2:real = 0);
		procedure Write;
		procedure ProcSumX(r:Real);
		procedure ProcSumY(r:Real);
		property SumX:real write ProcSumX;
		property SumY:real write ProcSumY;
		property X1:TSGVertexType read Vertexes[0].x write Vertexes[0].x;
		property Y1:TSGVertexType read Vertexes[0].y write Vertexes[0].y;
		property X2:TSGVertexType read Vertexes[1].x write Vertexes[1].x;
		property Y2:TSGVertexType read Vertexes[1].y write Vertexes[1].y;
		function VertexInView(const Vertex:TSGVertex2f):Boolean;inline;
		function AbsX:SGReal;inline;
		function AbsY:SGReal;inline;
		end;
	
	TSGVisibleVertex=object(TSGVertex3f)
		Visible:Boolean;
		end;
	SGVisibleVertex = TSGVisibleVertex;
	PSGVisibleVertex = ^SGVisibleVertex;
	TArSGVisibleVertex = type packed array of TSGVisibleVertex;
	TArTSGVisibleVertex = TArSGVisibleVertex;
	TSGVisibleVertexFunction = function (a:TSGVisibleVertex):TSGVisibleVertex;
	TSGPointerProcedure = procedure (a:Pointer);
	TSGProcedure = procedure;
	
	PTSGColor3f=^TSGColor3f;

{ TSGColor3f }

TSGColor3f=object
		r,g,b:single;
		procedure Color;inline;
		procedure SetColor;inline;
		procedure Import(const r1:single = 0; const g1:single = 0; const b1:single = 0);
		procedure ReadFromStream(const Stream:TStream);inline;
		procedure WriteToStream(const Stream:TStream);inline;
		end;
	PTArTSGColor3f = ^TArTSGColor3f;
	TArTSGColor3f = array of TSGColor3f;
	
	PTSGColor4f = ^ TSGColor4f;
	TSGColor4f=object(TSGColor3f)
		a:single;
		procedure SetColor;
		procedure Color;
		procedure SetVariables(const r1:real = 0; const g1:real = 0; const b1:real = 0; const a1:real = 1);
		function AddAlpha(const NewAlpha:real = 1):TSGColor4f;
		function WithAlpha(const NewAlpha:real = 1):TSGColor4f;
		procedure Import(const r1:real = 0; const g1:real = 0; const b1:real = 0;const a1:real = 1);
		procedure ReadFromStream(const Stream:TStream);inline;
		procedure WriteToStream(const Stream:TStream);inline;
		end;
	SGColor4f = TSGColor4f;
	SGColor = TSGColor4f;
	PTArTSGColor4f = ^TArTSGColor4f;
	TArTSGColor4f =type packed array of TSGColor4f;
	TArSGColor4f = TArTSGColor4f;
	TArSGColor = TArTSGColor4f;
	TArColor = TArTSGColor4f;
	ArColor = TArTSGColor4f;
	ArSGColor = TArTSGColor4f;
	ArSGColor4f = TArSGColor4f;
	
	PTSGPlane = ^ TSGPlane;
	TSGPlane=object
		a,b,c,d:real;
		procedure Import(const a1:real = 0; const b1:real = 0; const c1:real = 0; const d1:real = 0);
		end;
	PSGPlane = PTSGPlane;
	SGPlane = TSGPlane;
	
	TSGThreadProcedure = SaGeBase.TSGThreadProcedure;
	TSGThread = SaGeBase.TSGThread;
	SGThread = SaGeBase.TSGThread;
	
	{$IFDEF MSWINDOWS}
		TSGMethodWinAPI=object
			msg:TMSG;
			hWindow:HWnd;
			dcWindow:hDc;
			rcWindow:HGLRC;
			width,height,bits:longint;
			fullscreen,active:boolean;
			IDCursor:longword;
			IDIcon:longword;
			procedure ThrowError(pcErrorMessage : pChar);
			function WindowRegister: Boolean;
			function WindowCreate(pcApplicationName : pChar): HWnd;
			function WindowInit(hParent : HWnd): Boolean;
			function CreateOGLWindow(pcApplicationName : pChar; iApplicationWidth, iApplicationHeight, iApplicationBits : longint; bApplicationFullscreen : boolean):Boolean;
			procedure KillOGLWindow();
			procedure OpenGL_Init;
			procedure Messages;
			procedure SwapBuffers;
			end;
		PTSGMethodWinAPI = ^TSGMethodWinAPI;
		{$ENDIF}
	
	{$IFDEF LAZARUS}
		OpenGLControl = TOpenGLControl;
		POpenGLControl = ^ OpenGLControl;
		PForm = ^ TForm;
		SGMethodLazarus=object
			Active:boolean;
			POpenGLControl:POpenGLControl;
			PForm:PForm;
			procedure OpenGL_Init;
			end;
		PSGMethodLazarus = ^SGMethodLazarus;
		{$ENDIF}
	
	{$IFDEF UNIX}
		SGMethodGLX=class
				public
			constructor Create;
				public
			winAttr: TXSetWindowAttributes;
			glXCont: GLXContext;
			dpy: PDisplay;
			win: TWindow;
			visinfo: PXVisualInfo;
			cm: TColormap;
			end;
		{$ENDIF}
	
	SGIdentityObject=object
		Rotate1:real;
		Rotate2:real;
		Rotate3:real;
		Zum:real;
		Left:real;
		Top:real;
		Changet:Boolean;
		procedure Clear;
		procedure Change;
		procedure Init;
		procedure ChangeAndInit;
		end;
	
	TSGBezierCurve =object
		StartArray : TArTSGVertex3f;
		EndArray : TArTSGVertex3f;
		Detalization:dword;
		procedure Clear;
		procedure InitVertex(const k:TSGVertex3f);
		procedure Calculate;
		procedure Init(const p:Pointer = nil);
		procedure SetArray(const a:TArTSGVertex3f);
		function SetDetalization(const l:dword):boolean;
		function GetDetalization:longword;
		procedure CalculateRandom(Detalization1,KolVertex,Diapazon:longint);
		end;
	SGBezierCurve = TSGBezierCurve;
	
	TSGArFor0To255OfBoolean = type packed array [0..255] of boolean;
	TSGArFor0To2OfBoolean = type packed array [0..2] of boolean;
	TSGArFor0To3OfSGPoint = type packed array [0..3]of SGPoint;
	TSGArFor1To4OfSGVertex = type packed array [1..4] of SGVertex;
	PTSGArFor1To4OfSGVertex = ^TSGArFor1To4OfSGVertex;
	PSGArFor1To4OfSGVertex = PTSGArFor1To4OfSGVertex;
	TSGArTObject = type packed array of TObject;
	
	PSGViewportObject = ^ TSGViewportObject;
	TSGViewportObject=class
			private
		FColor:TSGColor4f;
		x,y,z:GLDouble;
		depth:GLFloat;
		viewport:TViewPortArray;
		mv_matrix,proj_matrix:T16DArray;
		Point:SGPoint;
		function GetVertex:SGVertex;
			public
		procedure GetViewport;
		procedure SetPoint (NewPoint:SGPoint;const WithSmezhenie:boolean = True);
		procedure CanculateVertex;
		procedure CanculateColor;
		property Vertex : SGVertex read GetVertex;
		property Color : SGColor4f read FColor;
		class function Smezhenie:SGPoint;
		end;
	SGViewportObject = TSGViewportObject;
	PTSGViewportObject = PSGViewportObject;
	
	
	TSGGLMatrixArray = array [0..3,0..3] of GLFloat;
	TSGGLMatrix = object
			public
		constructor Create;
			public
		FMatrix:TSGGLMatrixArray;
		procedure Clear;
		procedure Add(const x:Int = 0; const y:Int = 0;const Param:GLFloat = 0);
		procedure LoadFromPlane(Plane:TSGPlane);
		procedure Init;
		procedure Load;
		procedure Write;
		end;

	SGGLMatrix = TSGGLMatrix;
	TSGMatrix = TSGGLMatrix;
	
	SGImage = SaGeImages.TSGImage;
	TSGImage = SaGeImages.TSGImage;
	
	TSGGLImage=class(TSGImage)
			public
		procedure DrawImageFromTwoVertex2f(Vertex1,Vertex2:SGVertex2f;const RePlace:Boolean = True;const RePlaceY:SGByte = SG_3D);
		procedure DrawImageFromTwoPoint2f(Vertex1,Vertex2:SGPoint2f;const RePlace:Boolean = True;const RePlaceY:SGByte = SG_3D);
		procedure ImportFromDispley(const Point1,Point2:SGPoint;const NeedAlpha:Boolean = True);
		procedure ImportFromDispley(const NeedAlpha:Boolean = True);
		class function UnProjectShift:TSGPoint2f;
		class function ReadPixelsShift:TSGPoint2f;
		procedure DrawImageFromTwoVertex2fAsRatio(Vertex1,Vertex2:TSGVertex2f;const RePlace:Boolean = True;const Ratio:real = 1);inline;
		procedure RePlacVertex(var Vertex1,Vertex2:SGVertex2f;const RePlaceY:SGByte = SG_3D);inline;
		end;
	
	TStringParams=packed array of packed array [0..1] of string;
	
	TSGSimbolParam=object
		X,Y,Width:LongInt;
		end;
	
	TSGFont=class(TSGGLImage)
			public
		constructor Create(const FileName:string = '');
		destructor Destroy;override;
			protected
		FSimbolParams:packed array[#0..#255] of TSGSimbolParam;
		FFontParams:TStringParams;
		FTextureParams:TStringParams;
		FFontReady:Boolean;
		FFontHeight:LongInt;
		procedure LoadFont(const FontWay:string);
		class function GetLongInt(var Params:TStringParams;const Param:string):LongInt;
			public
		procedure ToTexture;override;
		function StringLength(const S:SGCaption ):LongWord;
		property FontReady:Boolean read FFontReady;
		function Ready:Boolean;override;
		end;
	
	TSGGLFont=class(TSGFont)
		procedure DrawFontFromTwoVertex2f(const S:SGCaption;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);
		procedure DrawCursorFromTwoVertex2f(const S:SGCaption;const CursorPosition : LongInt;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);
		end;
	
	TSGSkin=class;
	TSGSkin=class(TObject)
		
		end;
	
	TSGShodowVertexProcedure=procedure (Param1,Param2,Param3:GLFloat);cdecl;
const
	SGClearIdentityObject:SGIdentityObject = (Rotate1:0;Rotate2:0;Rotate3:0;Zum:0;Left:0;Top:0);
var
	{$IFDEF SGDebuging}
		(*$NOTE var*)
		{$ENDIF}
	SGMethodLoginToOpenGLType:TSGIdentifier = SGMethodLoginToOpenGLUnInstalled;
	SGMethodLoginToOpenGL:pointer = nil;

	SGKeysDown:TSGArFor0To255OfBoolean = 
		(False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,
		 False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,
		 False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,
		 False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,
		 False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,
		 False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,
		 False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,
		 False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,
		 False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,
		 False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,
		 False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,
		 False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,
		 False,False,False,False,False,False,False,False,False,False,False,False,False,False,False,False);
	SGKeyPressedVariable:char = #0;

	SGMouseKeysDown:TSGArFor0To2OfBoolean = (False,False,False);
	SGMouseKeyPressedVariable:byte = 0;
	SGMouseWheelVariable:longint = 0;

	SGMouseCoords:TSGArFor0To3OfSGPoint = ((x:0;y:0),(x:0;y:0),(x:0;y:0),(x:0;y:0));
		// 0 - Разница между 1 и 2
		// 1 - Координаты курсора сейчас
		// 2 - Координаты в прошлый проход
		// 3 - Координаты курсора сейчас без отнимания SGGetWindowRect

	SGUserPaintProcedure : SGProcedure = nil;
	SGCLPaintProcedure : SGProcedure = nil;
	SGCLForReSizeScreenProcedure : SGProcedure = nil;
	SGCLLoadProcedure : SGProcedure = nil;
	
	SGContextResized:Boolean = False;

	SGZero:extended = 0.00001;
	
	{$IFDEF GLUT}
		SGGLUTSettings:packed record
			CursorPosition:SGPoint;
			end;
		{$ENDIF}
	{$IFDEF UNIX}
		SGGLXSettings:packed record
			WindowWidth:LongInt;
			WindowHeight:LongInt;
			
			CursorWidth:LongInt;
			CursorHeight:LongInt;
			end;
		{$ENDIF}
	Nan:real;
	Inf:real;
	
	NilVertex:SGVertex = (x:0;y:0;z:0);
	NilColor:SGColor = (r:0;g:0;b:0;a:0);

var
	SG_USE_VBO:boolean = False;

operator + (a,b:SGPoint):SGPoint;inline;overload;
operator - (a,b:SGPoint):SGPoint;inline;overload;
operator + (a,b:SGVertex):SGVertex;inline;overload;
operator - (a,b:SGVertex):SGVertex;inline;overload;
operator / (a:SGVertex;b:real):SGVertex;inline;overload;
operator * (a:SGVertex;b:real):SGVertex;inline;overload;
operator * (b:real;a:SGVertex):SGVertex;inline;overload;
operator * (a:SGColor;b:real):SGColor;inline;overload;
operator + (a:SGVertex;b:SGVertex2f):SGVertex;inline;overload;
operator + (a:SGVertex2f;b:SGVertex):SGVertex;inline;overload;
operator + (a,b:SGVertex2f):SGVertex2f;overload;inline;overload;
operator + (a,b:SGVertex2f):SGVertex;inline;overload;
operator ** (a:Real;b:LongInt):Real;overload;inline;overload;
operator ** (a:LongInt;b:LongInt):LongInt;overload;inline;overload;
operator * (a:TSGScreenVertexes;b:real):TSGScreenVertexes;inline;overload;
operator + (a,b:TSGComplexNumber):TSGComplexNumber;overload;inline;
operator * (a,b:TSGComplexNumber):TSGComplexNumber;inline;overload;
operator - (a,b:TSGComplexNumber):TSGComplexNumber;overload;inline;
operator / (a,b:TSGComplexNumber):TSGComplexNumber;inline;overload;
operator ** (a:TSGComplexNumber;b:LongInt):TSGComplexNumber;inline;overload;
operator + (a,b:SGColor):SGColor;inline;overload;
operator - (a,b:SGColor):SGColor;inline;overload;
operator / (a:SGColor;b:real):SGColor;inline;overload;
operator = (a,b:TSGComplexNumber):Boolean;overload;inline;
operator - (a:TSGVertex):TSGVertex;overload;inline;
operator / (a:SGPoint;b:Int64):SGPoint;overload;inline;
operator div (a:SGPoint;b:Int64):SGPoint;overload;inline;
{$IFDEF MSWINDOWS}
	function GLWndProc(Window: HWnd; AMessage, WParam, LParam: Longint): Longint; stdcall; export;
	procedure SGInitOpenGLWinAPIMethod( const Fullscreen:boolean = False; const Name:PChar = 'SG OpenGL Window'; Width:longint = -1; Height:longint = -1; const Bits:longint = 32;const IDIcon:longword = 5; const IDCursor:longword = 5);
	function SGFullscreenQueschionWinAPIMethod:boolean;
	{$ENDIF}
{$IFDEF LAZARUS}
	procedure SGInitOpenGLLazarusMethod(var Form:TForm; var OpenGLControl:TOpenGLControl);
	{$ENDIF}
{$IFDEF GLUT}
	procedure SGInitOpenGLGLUTMethod(const Fullscreen:boolean = False; const Name:PChar = 'SG OpenGL Window'; Width:longint = -1; Height:longint = -1);
	procedure SGInitOpenGLGLUTMethodStartPaint;
	{$ENDIF}
{$IFDEF UNIX}
	procedure SGInitOpenGLGLXMethod(const Fullscreen:boolean = False; const Name:PChar = 'SG OpenGL Window'; Width:longint = -1; Height:longint = -1);
	{$ENDIF}
procedure SGGetMessages;
procedure SGSwapBuffers;
procedure SGCrearOpenGL;
function SGGetVertexInAttitude(const t1,t2:TSGVertex3f; const r:real = 0.5):TSGVertex3f;
function SGTSGVertex3fImport(const x:real = 0;const y:real = 0;const z:real = 0):TSGVertex3f;
function SGContextActive:boolean;
procedure SGInitOpenGL;
procedure SGSetKeyDown(const c:char = ' ');
procedure SGSetKeyUp(const c:char = ' ');
procedure SGClearKey;
function SGKeyPressed:boolean;
function SGKeyPressedChar:char;
procedure SGSetKey(const c:char = #0);
function SGIsKeyDown(const c:char = #0):boolean;
function SGMouseWheel:longint;
procedure SGSetMouseWheel(const l:longint = 0);
procedure SGClearMouseWheel();
procedure SGClearMouseKey();
procedure SGSetMouseKey(const l:longint  = 0);
function SGMouseKeyPressed:boolean;
function SGGetMouseKeyPressed:byte;
function SGIsMouseKeyDown(const l:byte = 1):boolean;
procedure SGSetMouseKeyDown(const l:longint = 0);
procedure SGSetMouseKeyUp(const l:longint = 0);
procedure SGPaint;
procedure SGSetUserPaintProcedure(const p:pointer = nil);
function SGGetCursorPosition:SGPoint;
procedure SGSetCursorPosition(const Point :SGPoint);
function SGGetWindowRect:SGPoint;
function SGGetMousePosition(const ID:longint = 1):SGPoint;
function SGGetDeviceCaps:SGPoint;
procedure SGResizeContext;
function GetContextHeight:longint;
property ContextHeight:longint read GetContextHeight;
function GetContextWidth:longint;
property ContextWidth:longint read GetContextWidth;
function SGGetVertexFromPointOnScreen(const Point:SGPoint;const WithSmezhenie:boolean = True):SGVertex;
function SGVertexImport(const x:real = 0;const y:real = 0;const z:real = 0):TSGVertex3f;
function SGPointImport(const NewX:Real = 0; const NewY:Real = 0 ):SGPoint;
function SGPointImport(const NewX:LongInt = 0; const NewY:LongInt = 0 ):SGPoint;	
procedure SGQuad(const Vertex1:SGVertex;const Vertex2:SGVertex;const Vertex3:SGVertex;const Vertex4:SGVertex);
procedure SGLoadFrameIdentity;
function SGVertexOnQuad(const Vertex:SGVertex; const QuadVertex1:SGVertex;const QuadVertex2:SGVertex;const QuadVertex3:SGVertex;const QuadVertex4:SGVertex):boolean;
function SGAbsTwoVertex(const Vertex1:SGVertex;const Vertex2:SGVertex):real;
function SGTreugPlosh(const a1,a2,a3:SGVertex):real;
function SGVertexOnQuad(const Vertex:SGVertex; const QuadVertex1:SGVertex;const QuadVertex3:SGVertex):boolean;
function SGVal(const Text:string = '0'):longint;
function SGGetVertexUnderCursor(const WithSmezhenie:boolean = True):SGVertex;
procedure SGQuad(ArVertex:TSGArFor1To4OfSGVertex);
function SGGetMatrix2x2(a1,a2,a3,a4:real):real;
function SGGetMatrix3x3(a1,a2,a3,a4,a5,a6,a7,a8,a9:real):real;
function SGGetVertexOnIntersectionOfThreePlane(p1,p2,p3:SGPlane):SGVertex;
function SGGetVertexWhichNormalFromThreeVertex(const p1,p2,p3:SGVertex):SGVertex;
function SGGetPlaneFromThreeVertex(const a1,a2,a3:SGVertex):SGPlane;
function SGGetPlaneFromNineReals(const x1,y1,z1,x2,y2,z2,x0,y0,z0:real):SGPlane;
function SGGetVertexOnIntersectionOfTwoLinesFromFourVertex(const q1,q2,w1,w2:SGVertex):SGVertex;
function SGStringToPChar(const s:string):PCHAR;
procedure SGRoundQuad(const Vertex1,Vertex3:SGVertex; const Radius:real; const Interval:LongInt;const QuadColor:SGColor; const LinesColor:SGColor4f; const WithLines:boolean = False;const WithQuad:boolean = True);
function SGColorImport(const r1:real = 0;const g1:real = 0;const b1:real = 0;const a1:real = 1):SGColor;
procedure SGInitMatrixMode(const Mode:SGByte = SG_3D);inline;
procedure SGMatrixMode(const Mode:SGByte = SG_3D);inline;
function SGPoint2fToVertex2f(const Point:SGPoint):SGVertex2f;
function SGPoint2fToVertex3f(const Point:SGPoint):SGVertex3f;
function SGGetCursorPositionForWindows:SGPoint;
function SGGetArrayOfRoundQuad(const Vertex1,Vertex3:SGVertex; const Radius:real; const Interval:LongInt):SGArVertex;
procedure SGRoundWindowQuad(const Vertex11,Vertex13:SGVertex;const Vertex21,Vertex23:SGVertex; 
	const Radius1:real;const Radius2:real; const Interval:LongInt;const QuadColor1:SGColor;const QuadColor2:SGColor;
	const WithLines:boolean; const LinesColor1:SGColor4f; const LinesColor2:SGColor4f);
procedure SGConstructRoundQuad(const ArVertex:SGArSGVertex;const Interval:LongInt;const QuadColor:SGColor; const LinesColor:SGColor4f; const WithLines:boolean = False;const WithQuad:boolean = True);
function SGPCharToString(const VChar:PChar):string;
procedure SGSomeQuad(a,b,c,d:SGVertex;vl,np:SGPoint);
procedure SGWndSomeQuad(a,c:SGVertex);
procedure SGWriteTime;
procedure SGCloseContext;
function SGPCharAddSimbol(var VPChar:PChar; const VChar:Char):PChar;
function SGPCharsEqual(const PChar1,PChar2:PChar):Boolean;
function SGPCharHigh(const VPChar:PChar):LongInt;
function SGPCharLength(const VPChar:PChar):LongWord;
function SGPCharDecFromEnd(var VPChar:PChar; const Number:LongWord = 1):PChar;
function SGPCharUpCase(const VPChar:PChar):PChar;
function SGPCharRead:PChar;
function SGCharRead:Char;
function SGPCharDeleteSpaces(const VPChar:PCHAR):PChar;
function SGPCharTotal(const VPChar1,VPChar2:PChar):PChar;
function SGAbsTwoVertex2f(const Vertex1,Vertex2:SGVertex2f):real;inline;
function SGRealExists(const r:real):Boolean;
function SGRealsEqual(const r1,r2:real):Boolean;
procedure SGQuickRePlaceReals(var Real1,Real2:Real);
procedure SGQuickRePlaceLongInt(var LongInt1,LongInt2:LongInt);
procedure SGQuickRePlaceVertexType(var LongInt1,LongInt2:TSGVertexType);
function SGFileExists(const FileName:string = ''):boolean;
function SGVertex2fToPoint2f(const Vertex:TSGVertex2f):TSGPoint2f;
function SGVertex2fImport(const x:real = 0;const y:real = 0):TSGVertex2f;inline;
function SGComplexNumberImport(const x:real = 0;const y:real = 0):TSGComplexNumber;inline;
function SGRandomMinus:Int;
procedure SGSetCLProcedure(const p:Pointer = nil);
procedure SCSetCLScreenBounds(const p:Pointer = nil);
function SGReadLnString:String;
function SGReadLnByte:Byte;
procedure SGSetCLLoadProcedure(p:Pointer);
function SGGetFreeFileName(const Name:string):string;inline;
function SGGetFileNameWithoutExpansion(const FileName:string):string;inline;
function SGFloatToString(const R:Extended;const Zeros:LongInt = 0):string;inline;
function SGGetQuantitySimbolsInNumber(l:LongInt):LongInt;inline;
function SGPCharGetPart(const VPChar:PChar;const Position1,Position2:LongInt):PChar;
function SGPoint2fImport(const x1:int64 = 0; const y1:int64 = 0):TSGPoint2f;overload;inline;
function SGPoint2fImport(const x1:extended = 0; const y1:extended = 0):TSGPoint2f;overload;inline;
function SGGetColor4fFromLongWord(const LongWordColor:LongWord;const WithAlpha:Boolean = False):SGColor4f;inline;
function SGGetTopShiftOnWinAPIMethod:LongInt;inline;
function SGContextFullscreen:Boolean;
procedure SGLookAt(Mesh,Camera,CameraTop:SGVertex3f);
function SGX(const v:Single):TSGVertex3f;inline;
function SGY(const v:Single):TSGVertex3f;inline;
function SGZ(const v:Single):TSGVertex3f;inline;

implementation
{$IFDEF SGDebuging}
	(*$NOTE implementation*)
	{$ENDIF}

operator / (a:SGPoint;b:Int64):SGPoint;overload;inline;
begin
Result:=a div b;
end;

operator div (a:SGPoint;b:Int64):SGPoint;overload;inline;
begin
Result.x:=a.x div b;
Result.y:=a.y div b;
end;

procedure TSGColor3f.ReadFromStream(const Stream:TStream);inline;
begin
Stream.ReadBuffer(Self,SizeOf(r)*3);
end;

procedure TSGColor3f.WriteToStream(const Stream:TStream);inline;
begin
Stream.WriteBuffer(Self,SizeOf(r)*3);
end;

procedure TSGColor4f.ReadFromStream(const Stream:TStream);inline;
begin
Stream.ReadBuffer(Self,SizeOf(r)*4);
end;

procedure TSGColor4f.WriteToStream(const Stream:TStream);inline;
begin
Stream.WriteBuffer(Self,SizeOf(r)*4);
end;

operator - (a:TSGVertex):TSGVertex;overload;inline;
begin
Result.x:=-a.x;
Result.y:=-a.y;
Result.z:=-a.z;
end;

operator * (b:real;a:SGVertex):SGVertex;inline;overload;
begin
Result:=a*b;
end;

function SGX(const v:Single):TSGVertex3f;inline;
begin
Result.Import(v,0,0);
end;

function SGY(const v:Single):TSGVertex3f;inline;
begin
Result.Import(0,v,0);
end;

function SGZ(const v:Single):TSGVertex3f;inline;
begin
Result.Import(0,0,v);
end;

procedure TSGVertex3f.Translate;
begin
glTranslatef(x,y,z);
end;

procedure TSGVertex2f.Translate;
begin
glTranslatef(x,y,0);
end;

procedure SGLookAt(Mesh,Camera,CameraTop:SGVertex3f);
begin
gluLookAt(Mesh.x,Mesh.y,Mesh.z,Camera.x,Camera.y,Camera.z,CameraTop.x,CameraTop.y,CameraTop.z);
end;

procedure TSGVertex3f.ReadFromTextFile(const Fail:PTextFile);
begin
Read(Fail^,x,y,z);
end;

procedure TSGVertex3f.ReadLnFromTextFile(const Fail:PTextFile);
begin
ReadFromTextFile(Fail);
ReadLn(Fail^);
end;

operator = (a,b:TSGComplexNumber):Boolean;overload;inline;
begin
Result:=(a.x=b.x) and (b.y=a.y);
end;

function TSGScreenVertexes.AbsX:SGReal;inline;
begin
Result:=Abs(X1-X2);
end;

function TSGScreenVertexes.AbsY:SGReal;inline;
begin
Result:=Abs(Y1-Y2);
end;

function TSGScreenVertexes.VertexInView(const Vertex:TSGVertex2f):Boolean;inline;
begin
Result:=(Vertex.x<SGMax(X1,X2)) and 
	(Vertex.y<SGMax(Y1,Y2)) and 
	(Vertex.x>SGMin(X1,X2)) and 
	(Vertex.y>SGMin(Y1,Y2));
end;

function SGGetTopShiftOnWinAPIMethod:LongInt;inline;
begin
Result:=0
	{$IFDEF MSWINDOWS}
	+Byte((SGMethodLoginToOpenGLType=SGMethodLoginToOpenGLWinAPI) and (not PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.Fullscreen))*30
		{$ENDIF}
	;
end;

operator + (a,b:SGColor):SGColor;inline;
begin
Result.r:=a.r+b.r;
Result.g:=a.g+b.g;
Result.b:=a.b+b.b;
Result.a:=a.a+b.a;
end;

operator - (a,b:SGColor):SGColor;inline;
begin
Result.r:=a.r-b.r;
Result.g:=a.g-b.g;
Result.b:=a.b-b.b;
Result.a:=a.a-b.a;
end;

operator / (a:SGColor;b:real):SGColor;inline;
begin
Result.r:=a.r/b;
Result.g:=a.g/b;
Result.b:=a.b/b;
Result.a:=a.a/b;
end;

function SGGetColor4fFromLongWord(const LongWordColor:LongWord;const WithAlpha:Boolean = False):SGColor4f;inline;
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

function SGPoint2fImport(const x1:extended = 0; const y1:extended = 0):TSGPoint2f;overload;inline;
begin
Result.x:=Round(x1);
Result.y:=Round(y1);
end;

function SGPoint2fImport(const x1:int64 = 0; const y1:int64 = 0):TSGPoint2f;overload;inline;
begin
Result.x:=x1;
Result.y:=y1;
end;

procedure TSGVertex2f.Round;overload;
begin
x:=System.Round(x);
y:=System.Round(y);
end;

procedure TSGColor4f.Import(const r1:real = 0; const g1:real = 0; const b1:real = 0;const a1:real = 1);
begin
r:=r1;
b:=b1;
g:=g1;
a:=a1;
end;

function TSGColor4f.WithAlpha(const NewAlpha:real = 1):TSGColor4f;
begin
Result:=Self;
Result.a*=NewAlpha;
end;

function SGPCharGetPart(const VPChar:PChar;const Position1,Position2:LongInt):PChar;
var
	i:LongInt;
begin
Result:='';
i:=Position1;
while (VPChar[i]<>#0) and (i<>Position2+1) do
	begin
	SGPCharAddSimbol(Result,VPChar[i]);
	i+=1;
	end;
end;

function SGGetQuantitySimbolsInNumber(l:LongInt):LongInt;inline;
begin
Result:=0;
while l<>0 do
	begin
	Result+=1;
	l:=l div 10;
	end;
end;

function SGFloatToString(const R:Extended;const Zeros:LongInt = 0):string;inline;
var
	i:LongInt;
begin
Result:='';
if Trunc(R)=0 then
	begin
	if R<0 then
		Result+='-';
	Result+='0';
	end
else
	Result+=SGStr(Trunc(R));
if Zeros<>0 then
	begin
	if Abs(R-Trunc(R))*10**Zeros<>0 then
		begin
		i:=Zeros-SGGetQuantitySimbolsInNumber(Trunc(Abs(R-Trunc(R))*(10**Zeros)));
		Result+='.';
		while i>0 do
			begin
			i-=1;
			Result+='0';
			end;
		Result+=SGStr(Trunc(Abs(R-Trunc(R))*(10**Zeros)));
		while Result[Length(Result)]='0' do
			Byte(Result[0])-=1;
		if Result[Length(Result)]='.' then
			Byte(Result[0])-=1;
		end;
	end;
end;

function SGGetFileNameWithoutExpansion(const FileName:string):string;inline;
var
	i:LongInt;
	PointPosition:LongInt = 0;
begin
for i:=1 to Length(FileName) do
	begin
	if FileName[i]='.' then
		begin
		PointPosition:=i;
		end;
	end;
if (PointPosition=0) then
	Result:=FileName
else
	begin
	Result:='';
	for i:=1 to PointPosition-1 do
		Result+=FileName[i];
	end;
end;

function SGGetFreeFileName(const Name:string):string;inline;
var
	FileExpansion:String = '';
	FileName:string = '';
	Number:LongInt = 1;

begin
if FileExists(Name) then
	begin
	FileExpansion:=SGGetFileExpansion(Name);
	FileName:=SGGetFileNameWithoutExpansion(Name);
	while FileExists(FileName+' (Copy '+SGStr(Number)+').'+FileExpansion) do
		Number+=1;
	Result:=FileName+' (Copy '+SGStr(Number)+').'+FileExpansion;
	end
else
	Result:=Name;
end;

operator ** (a:TSGComplexNumber;b:LongInt):TSGComplexNumber;inline;
var
	i:LongInt;
begin
Result.Import(1,0);
for i:=1 to b do
	Result*=a;
end;

procedure TSGGLMatrix.Load;
begin
glMatrixMode(GL_PROJECTION);
glLoadMatrixf(@Self);
glMatrixMode(GL_MODELVIEW);
end;

procedure TSGGLMatrix.Init;
begin
glMatrixMode(GL_PROJECTION);
glMultMatrixf(@Self);
glMatrixMode(GL_MODELVIEW);
end;

procedure TSGGLMatrix.Write;
var
	i,ii:longint;
begin
for i:=0 to 3 do
	begin
	for ii:=0 to 3 do
		System.Write(FMatrix[i][ii]:0:4,' ');
	System.WriteLn;
	end;
WriteLn;
end;

procedure TSGGLMatrix.LoadFromPlane(Plane:TSGPlane);
begin
Clear;
Add(0,0,-Plane.d);
Add(1,1,-Plane.d);
Add(2,2,-Plane.d);
Add(0,3,Plane.a);
Add(1,3,Plane.b);
Add(2,3,Plane.c);
end;

procedure TSGGLImage.DrawImageFromTwoVertex2fAsRatio(Vertex1,Vertex2:TSGVertex2f;const RePlace:Boolean = True;const Ratio:real = 1);inline;
begin
if RePlace then
	RePlacVertex(Vertex1,Vertex2,SG_3D);
DrawImageFromTwoVertex2f(
	SGVertex2fImport(
		Vertex1.x+abs(Vertex1.x-Vertex2.x)*((1-Ratio)/2),
		Vertex1.y-abs(Vertex1.y-Vertex2.y)*((1-Ratio)/2)),
	SGVertex2fImport(
		Vertex2.x-abs(Vertex1.x-Vertex2.x)*((1-Ratio)/2),
		Vertex2.y+abs(Vertex1.y-Vertex2.y)*((1-Ratio)/2)),
	RePlace,SG_3D);
end;

procedure SGQuickRePlaceVertexType(var LongInt1,LongInt2:TSGVertexType);
var
	a:TSGVertexType;
begin
a:=LongInt1;
LongInt1:=LongInt2;
LongInt2:=LongInt1;
end;

procedure TSGGLImage.RePlacVertex(var Vertex1,Vertex2:SGVertex2f;const RePlaceY:SGByte = SG_3D);inline;
begin
if Vertex1.x>Vertex2.x then
	SGQuickRePlaceVertexType(Vertex1.x,Vertex2.x);
case RePlaceY of
SG_2D:
	begin
	if Vertex1.y>Vertex2.y then
		SGQuickRePlaceVertexType(Vertex1.y,Vertex2.y);
	end;
else
	begin
	if Vertex1.y<Vertex2.y then
		SGQuickRePlaceVertexType(Vertex1.y,Vertex2.y);
	end;
end;
end;

class function TSGGLImage.UnProjectShift:TSGPoint2f;
begin
Result:=TSGViewportObject.Smezhenie;
end;

procedure TSGGLImage.ImportFromDispley(const NeedAlpha:Boolean = True);
begin
ImportFromDispley(
	SGPointImport(1,1),
	SGPointImport(ContextWidth,ContextHeight),
	NeedAlpha);
end;

procedure TSGGLImage.ImportFromDispley(const Point1,Point2:SGPoint;const NeedAlpha:Boolean = True);
begin
if Self<>nil then
	FreeAll
else
	Self:=TSGGLImage.Create;
if NeedAlpha then
	begin
	GetMem(FImage.FBitMap,(Point2.x-Point1.x+1)*(Point2.y-Point1.y+1)*4);
	glReadPixels(
		Point1.x-1+ReadPixelsShift.x,
		Point1.y-1+ReadPixelsShift.y,
		Point2.x-Point1.x+1, 
		Point2.y-Point1.y+1, 
		GL_RGBA, 
		GL_UNSIGNED_BYTE, 
		FImage.FBitMap);
	Bits:=32;
	end
else
	begin
	GetMem(FImage.FBitMap,(Point2.x-Point1.x+1)*(Point2.y-Point1.y+1)*3);
	glReadPixels(
		Point1.x-1+ReadPixelsShift.x,
		Point1.y-1+ReadPixelsShift.y,
		Point2.x-Point1.x+1, 
		Point2.y-Point1.y+1, 
		GL_RGB, 
		GL_UNSIGNED_BYTE, 
		FImage.FBitMap);
	Bits:=24;
	end;
Height:=Point2.y-Point1.y+1;
Width:=Point2.x-Point1.x+1;
FReadyToGoToTexture:=True;
end;

procedure TSGGLFont.DrawCursorFromTwoVertex2f(const S:SGCaption;const CursorPosition : LongInt;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);
var
	i:LongInt = 0;
	StringWidth:LongInt = 0;
	Otstup:SGVertex2f = (x:0;y:0);
	ToExit:Boolean = False;
begin
if AutoXShift then
	begin
	Otstup.x:=(Abs(Vertex2.x-Vertex1.x)-StringWidth)/2;
	if Otstup.x<0 then
		Otstup.x:=0;
	end;
if AutoYShift then
	begin
	Otstup.y:=(Abs(Vertex2.y-Vertex1.y)-FFontHeight)/2;
	end;

while (s[i]<>#0) and (not ToExit) and (CursorPosition>i) do
	begin
	Otstup.x+=FSimbolParams[s[i]].Width;
	i+=1;
	end;
glBegin(GL_LINES);
(Vertex1+Otstup).Vertex;
glVertex2f(Otstup.x+Vertex1.x,Otstup.y+FFontHeight+Vertex1.y);
glEnd();
end;

procedure SGSetCLLoadProcedure(p:Pointer);
begin
SGCLLoadProcedure:=SGProcedure(p);
end;

function SGReadLnByte:Byte;
begin 
Readln(Result);
end;

function SGReadLnString:String;
begin
Readln(Result);
end;

procedure TSGVertex3f.Normalize;
var
	vabs:real;
begin
vabs:=SGAbsTwoVertex(Self,NilVertex);
x/=vabs;
y/=vabs;
z/=vabs;
end;

procedure TSGVertex3f.Vertex(Const P:Pointer);
begin
if p=nil then
	gl.glVertex3f(x,y,z)
else
	TSGShodowVertexProcedure(p)(x,y,z);
end;

procedure SGSetCLProcedure(const p:Pointer = nil);
begin
SGCLPaintProcedure:=SGProcedure(p);
end;

procedure SCSetCLScreenBounds(const p:Pointer = nil);
begin
SGCLForReSizeScreenProcedure:=SGProcedure(p);
end;

function SGRandomMinus:Int;
begin
if random(2)=0 then
	Result:=-1
else
	Result:=1;
end;

procedure TSGGLMatrix.Clear;
begin
FMatrix[0,0]:=0;FMatrix[0,1]:=0;FMatrix[0,2]:=0;FMatrix[0,3]:=0;
FMatrix[1,0]:=0;FMatrix[1,1]:=0;FMatrix[1,2]:=0;FMatrix[1,3]:=0;
FMatrix[2,0]:=0;FMatrix[2,1]:=0;FMatrix[2,2]:=0;FMatrix[2,3]:=0;
FMatrix[3,0]:=0;FMatrix[3,1]:=0;FMatrix[3,2]:=0;FMatrix[3,3]:=0;
end;

constructor TSGGLMatrix.Create;
begin
Clear;
end;

procedure TSGGLMatrix.Add(const x:Int = 0; const y:Int = 0;const Param:GLFloat = 0);
begin
if (x>=0) and (x<=3) and (y>=0) and (y<=3) then
	FMatrix[x,y]:=Param;
end;


function TSGColor4f.AddAlpha(const NewAlpha:real = 1):TSGColor4f;
begin
a*=NewAlpha;
Result:=Self;
end;

function SGComplexNumberImport(const x:real = 0;const y:real = 0):TSGComplexNumber;inline;
begin
Result.Import(x,y);
end;

function SGVertex2fImport(const x:real = 0;const y:real = 0):TSGVertex2f;inline;
begin
Result.Import(x,y);
end;

operator - (a,b:TSGComplexNumber):TSGComplexNumber;inline;
begin
Result.Import(a.x-b.x,a.y-b.y);
end;

operator / (a,b:TSGComplexNumber):TSGComplexNumber;inline;
begin
Result.Import(
	(a.x*b.x+a.y*b.y)/(b.x*b.x-b.y*b.y),
	(a.y*b.x-a.x*b.y)/(b.x*b.x-b.y*b.y));
end;

operator * (a,b:TSGComplexNumber):TSGComplexNumber;inline;
begin
result.Import(a.x*b.x-a.y*b.y,a.x*b.y+b.x*a.y);
end;

operator + (a,b:TSGComplexNumber):TSGComplexNumber;inline;
begin
Result.Import(a.x+b.x,a.y+b.y);
end;

function TSGFont.Ready:Boolean;
begin
Result:= (Inherited Ready) and FontReady;
end;

function SGVertex2fToPoint2f(const Vertex:TSGVertex2f):TSGPoint2f;
begin
Result.Import(
	Round(Vertex.X),
	Round(Vertex.Y));
end;

class function TSGFont.GetLongInt(var Params:TStringParams;const Param:string):LongInt;
var
	i:LongInt;
begin
Result:=0;
for i:=Low(Params) to High(Params) do
	begin
	if Params[i][0]=Param then
		begin
		Val(Params[i][1],Result);
		Break;
		end;
	end;
end;

procedure TSGFont.LoadFont(const FontWay:string);
var
	Fail:TextFile;
	Identificator:string = '';
	C:Char = ' ';
	C2:char = ' ';

procedure LoadParams(var Params:TStringParams);
begin
while not eoln(Fail) do
	begin
	SetLength(Params,Length(Params)+1);
	Params[High(Params)][0]:='';
	Params[High(Params)][1]:='';
	C:=' ';
	while C<>'=' do
		begin
		Read(Fail,C);
		if C<>'=' then
			begin
			Params[High(Params)][0]+=C;
			end;
		end;
	ReadLn(Fail,Params[High(Params)][1]);
	end;
end;

function GetString(const S:String;const P1,P2:LongInt):String;
var
	i:LongInt;
begin
Result:='';
for i:=P1 to P2 do
	Result+=S[i];
end;

procedure LoadSimbol(S:String;var Obj:TSGSimbolParam);
var
	LastPosition:LongInt = 1;
	Position:LongInt = 1;
	I:LongInt = 0;
begin
while (S[Position]<>',')and(Position<=Length(s)) do
	Position+=1;
Position-=1;
Val(GetString(S,LastPosition,Position),I);
Position:=Position+2;
LastPosition:=Position;
Obj.X:=i;

while (S[Position]<>',')and(Position<=Length(s)) do
	Position+=1;
Position-=1;
Val(GetString(S,LastPosition,Position),I);
Position:=Position+2;
LastPosition:=Position;
Obj.Y:=i;

while (S[Position]<>',')and(Position<Length(s)) do
	Position+=1;
Val(GetString(S,LastPosition,Position),I);
Obj.Width:=i;

end;

begin
Assign(Fail,FontWay);
Reset(Fail);
while not eof(Fail) do
	begin
	Read(Fail,C);
	Identificator:='';
	repeat
	if (c<>' ') and (c<>';') then
		begin
		Identificator+=UpCase(c);
		end;
	Read(Fail,C);
	until (c='(') or (c=':');
	ReadLn(Fail);
	if (Identificator='FONTPARAMS') then
		LoadParams(FFontParams);
	if (Identificator='TEXTUREPARAMS') then
		LoadParams(FTextureParams);
	if Identificator='SIMBOLPARAMS' then
		begin
		while not eoln(Fail) do
			begin
			Identificator:='';
			Read(Fail,C2);
			Read(Fail,C);
			ReadLn(Fail,Identificator);
			LoadSimbol(Identificator,FSimbolParams[C2]);
			end;
		Identificator:='';
		end;
	ReadLn(Fail);
	end;
Close(Fail);
FFontHeight:=GetLongInt(FFontParams,'Height');
FFontReady:=True;
end;

function SGFileExists(const FileName:string = ''):boolean;
begin
Result:=FileExists(FileName);
end;

procedure TSGFont.ToTexture;
var
	FontWay:string = '';
	i:LongInt = 0;
	ii:LongInt = 0;
begin
i:=Length(FWay);
while (FWay[i]<>'.')and(FWay[i]<>'/')and(i>0)do
	i-=1;
if (i>0)and (FWay[i]='.') then
	begin
	for ii:=1 to i do
		FontWay+=FWay[ii];
	FontWay+='txt';
	if SGFileExists(FontWay) then
		begin
		LoadFont(FontWay);
		end;
	end;
inherited;
end;

constructor TSGFont.Create(const FileName:string = '');
begin
inherited Create(FileName);
FFontReady:=False;
FFontParams:=nil;
FTextureParams:=nil;
end;

destructor TSGFont.Destroy;
begin
inherited;
end;

procedure TSGGLFont.DrawFontFromTwoVertex2f(const S:SGCaption;const Vertex1,Vertex2:SGVertex2f; const AutoXShift:Boolean = True; const AutoYShift:Boolean = True);
var
	i:LongInt = 0;
	StringWidth:LongInt = 0;
	Otstup:SGVertex2f = (x:0;y:0);
	ToExit:Boolean = False;
	SimbolWidth:LongWord = 0;
begin
BindTexture;
StringWidth:=StringLength(S);
if AutoXShift then
	begin
	Otstup.x:=(Abs(Vertex2.x-Vertex1.x)-StringWidth)/2;
	if Otstup.x<0 then
		Otstup.x:=0;
	end;
if AutoYShift then
	begin
	Otstup.y:=(Abs(Vertex2.y-Vertex1.y)-FFontHeight)/2;
	end;
Otstup.Round;
while (s[i]<>#0) and (not ToExit) do
	begin
	SimbolWidth:=FSimbolParams[s[i]].Width;
	if Otstup.x+FSimbolParams[s[i]].Width>Abs(Vertex2.x-Vertex1.x) then
		begin
		ToExit:=True;
		SimbolWidth:=Trunc(Abs(Vertex2.x-Vertex1.x)-Otstup.x);
		end;
	glBegin(GL_QUADS);
	glTexCoord2f(Self.FSimbolParams[s[i]].x/Self.Width,1-(Self.FSimbolParams[s[i]].y/Self.Height));
	glVertex2f(Otstup.x+Vertex1.x,Otstup.y+Vertex1.y);
	glTexCoord2f(
		(Self.FSimbolParams[s[i]].x+SimbolWidth)/Self.Width,
		1-(Self.FSimbolParams[s[i]].y/Self.Height));
	glVertex2f(Otstup.x+SimbolWidth+Vertex1.x,Otstup.y+Vertex1.y);
	glTexCoord2f(
		(Self.FSimbolParams[s[i]].x+SimbolWidth)/Self.Width,
		1-((Self.FSimbolParams[s[i]].y+FFontHeight)/Self.Height));
	glVertex2f(Otstup.x+SimbolWidth+Vertex1.x,Otstup.y+FFontHeight+Vertex1.y);
	glTexCoord2f(Self.FSimbolParams[s[i]].x/Self.Width,1-((Self.FSimbolParams[s[i]].y+FFontHeight)/Self.Height));
	glVertex2f(Otstup.x+Vertex1.x,Otstup.y+FFontHeight+Vertex1.y);
	glEnd();
	Otstup.x+=FSimbolParams[s[i]].Width;
	i+=1;
	end;
DisableTexture;
end;

function TSGFont.StringLength(const S:SGCaption ):LongWord;
var
	i:LongInt = 0;
begin
Result:=0;
while s[i]<>#0 do
	begin
	Result+=FSimbolParams[s[i]].Width;
	i+=1;
	end;
end;

procedure TSGGLImage.DrawImageFromTwoPoint2f(Vertex1,Vertex2:SGPoint2f;const RePlace:Boolean = True;const RePlaceY:SGByte = SG_3D);
begin
DrawImageFromTwoVertex2f(SGPoint2fToVertex2f(Vertex1),SGPoint2fToVertex2f(Vertex2),RePlace,RePlaceY);
end;

procedure TSGGLImage.DrawImageFromTwoVertex2f(Vertex1,Vertex2:SGVertex2f;const RePlace:Boolean = True;const RePlaceY:SGByte = SG_3D);
begin
if RePlace then
	begin
	RePlacVertex(Vertex1,Vertex2,rePlaceY);
	end;
BindTexture;
glBegin(GL_QUADS);
glTexCoord2f(0,0);
Vertex1.Vertex;
glTexCoord2f(1,0);
glVertex2f(Vertex2.x,Vertex1.y);
glTexCoord2f(1,1);
Vertex2.Vertex;
glTexCoord2f(0,1);
glVertex2f(Vertex1.x,Vertex2.y);
glEnd();
DisableTexture;
end;

procedure SGQuickRePlaceLongInt(var LongInt1,LongInt2:LongInt);
var
	LongInt3:LongInt;
begin
LongInt3:=LongInt1;
LongInt1:=LongInt2;
LongInt2:=LongInt3;
end;

procedure SGQuickRePlaceReals(var Real1,Real2:Real);
var
	Real3:Real;
begin
Real3:=Real1;
Real1:=Real2;
Real2:=Real3;
end;

procedure TSGScreenVertexes.ProcSumX(r:Real);
begin
Vertexes[0].x+=r;
Vertexes[1].x+=r;
end;

procedure TSGScreenVertexes.ProcSumY(r:Real);
begin
Vertexes[0].y+=r;
Vertexes[1].y+=r;
end;

procedure TSGVertex3f.WriteLn;
begin
Write;
System.WriteLn()
end;

procedure TSGVertex3f.Write;
begin
inherited Write;
System.Write(' ',z:0:10)
end;

procedure TSGVertex2f.Write;
begin
System.Write(x:0:10,' ',y:0:10);
end;

procedure TSGVertex2f.WriteLn;
begin
Write;
System.Writeln;
end;

procedure TSGScreenVertexes.Write;
begin
Vertexes[0].Write;
System.Write(' ');
Vertexes[1].WriteLn;
end;

operator * (a:TSGScreenVertexes;b:real):TSGScreenVertexes;inline;
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

procedure TSGScreenVertexes.Import(const x1:real = 0;const y1:real = 0;const x2:real = 0;const y2:real = 0);
begin
Vertexes[0].x:=x1;
Vertexes[0].y:=y1;
Vertexes[1].x:=x2;
Vertexes[1].y:=y2;
end;

function SGRealsEqual(const r1,r2:real):Boolean;
begin
Result:=abs(r1-r2)<=SGZero;
end;

function SGRealExists(const r:real):Boolean;
begin
Result:={(r<>Nan) and} (r<>Inf) and (r<>-Inf);
end;

function SGAbsTwoVertex2f(const Vertex1,Vertex2:SGVertex2f):real;inline;
begin
Result:=sqrt(sqr(Vertex1.x-Vertex2.x)+sqr(Vertex1.y-Vertex2.y));
end;

function SGPCharTotal(const VPChar1,VPChar2:PChar):PChar;
var
	Length1:LongInt = 0;
	Length2:LongInt = 0;
	I:LongInt = 0;
begin
Length1:=SGPCharLength(VPChar1);
Length2:=SGPCharLength(VPChar2);
Result:=nil;
GetMem(Result,Length1+Length2+1);
Result[Length1+Length2]:=#0;
for I:=0 to Length1-1 do
	Result[I]:=VPChar1[i];
for i:=Length1 to Length1+Length2-1 do
	Result[I]:=VPChar2[I-Length1];
end;

procedure TSGVertex3f.VertexPoint;
begin
glBegin(GL_POINTS);
Vertex;
glEnd();
end;

operator ** (a:LongInt;b:LongInt):LongInt;overload;inline;
var
	I:LongInt = 0;
begin
Result:=1;
for i:=1 to b do
	Result*=a;
end;

operator ** (a:Real;b:LongInt):Real;inline;
var
	I:LongInt = 0;
begin
Result:=1;
for i:=1 to b do
	Result*=a;
end;

procedure TSGVertex3f.LightPosition(const Ligth:LongInt = GL_LIGHT0);
var
	Light:array[0..3] of glFloat;
	AmbientLight : array[0..3] of glFloat = (0.5,0.5,0.5,1.0);
	DiffuseLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
	SpecularLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
begin
Light[0]:=x;
Light[1]:=y;
Light[2]:=z;
Light[3]:=2;
glEnable(Ligth);
glLightfv(Ligth,GL_POSITION,@Light);
glLightfv(Ligth,GL_AMBIENT, @AmbientLight);
glLightfv(Ligth,GL_DIFFUSE, @DiffuseLight);
glLightfv(Ligth,GL_SPECULAR, @SpecularLight);
end;

procedure TSGVertex3f.Normal;
begin
glNormal3f(x,y,z);
end;

function SGPCharDeleteSpaces(const VPChar:PCHAR):PChar;
var
	I:Longint = 0;
begin
GetMem(Result,1);
Result^:=#0;
while VPChar[i]<>#0 do
	begin
	if VPChar[i]<>' ' then
		SGPCharAddSimbol(Result,VPChar[i]);
	I+=1;
	end;
end;

function SGCharRead:Char;
begin
Read(Result);
end;

function SGPCharRead:PChar;
begin
GetMem(Result,1);
Result[0]:=#0;
while not eoln do
	begin
	SGPCharAddSimbol(Result,SGCharRead);
	end;
end;

function SGPCharUpCase(const VPChar:PChar):PChar;
var
	i:LongWord = 0;
begin
Result:=nil;
if (VPChar<>nil) then
	begin
	I:=SGPCharLength(VPChar);
	GetMem(Result,I+1);
	Result[I]:=#0;
	I:=0;
	while VPChar[i]<>#0 do
		begin
		Result[i]:=UpCase(VPChar[i]);
		I+=1;
		end;
	end;
end;

function SGPCharDecFromEnd(var VPChar:PChar; const Number:LongWord = 1):PChar;
var
	NewVPChar:PChar = nil;
	LengthOld:LongWord = 0;
	I:LongInt = 0;
begin
LengthOld:=SGPCharLength(VPChar);
GetMem(NewVPChar,LengthOld-Number+1);
for I:=0 to LengthOld-Number-1 do
	NewVPChar[i]:=VPChar[i];
NewVPChar[LengthOld-Number]:=#0;
VPChar:=NewVPChar;
Result:=NewVPChar;
end;

function SGPCharLength(const VPChar:PChar):LongWord;
begin
Result:=SGPCharHigh(VPChar)+1;
end;

function SGPCharHigh(const VPChar:PChar):LongInt;
begin
if (VPChar = nil) or (VPChar[0] = #0) then
	Result:=-1
else
	begin
	Result:=0;
	while VPChar[Result]<>#0 do
		Result+=1;
	Result-=1;
	end;
end;

function SGPCharsEqual(const PChar1,PChar2:PChar):Boolean;
var
	I:LongInt = 0;
	VExit:Boolean = False;
begin
Result:=True;
if not ((PChar1=nil) and (PChar2=nil)) then
	while Result and (not VExit) do
		begin
		if (PChar1=nil) or (PChar2=nil) or (PChar1[i]=#0) or (PChar2[i]=#0) then
			VExit:=True;
		if  ((PChar1=nil) and (PChar2<>nil) and (PChar2[i]<>#0)) or
			((PChar2=nil) and (PChar1<>nil) and (PChar1[i]<>#0))then
				Result:=False
		else
			if (PChar1<>nil) and (PChar2<>nil) and 
				(((PChar1[i]=#0) and (PChar2[i]<>#0)) or 
				 ((PChar2[i]=#0) and (PChar1[i]<>#0))) then
					Result:=False
			else
				if (PChar1<>nil) and (PChar2<>nil) and 
					(PChar1[i]<>#0) and (PChar2[i]<>#0) and 
					(PChar1[i]<>PChar2[i]) then
						Result:=False;					
		I+=1;
		end;
end;

function SGPCharAddSimbol(var VPChar:PChar; const VChar:Char):PChar;
var
	NewVPChar:PChar = nil;
	LengthOld:LongInt = 0;
	I:LongInt = 0;
begin
if VPChar<>nil then
	begin
	while (VPChar[LengthOld]<>#0) do
		LengthOld+=1;
	end;
GetMem(NewVPChar,LengthOld+2);
for I:=0 to LengthOld-1 do
	NewVPChar[i]:=VPChar[i];
NewVPChar[LengthOld]:=VChar;
NewVPChar[LengthOld+1]:=#0;
VPChar:=NewVPChar;
Result:=NewVPChar;
end;

procedure SGWriteTime;
var
	h,m,s,sec100:word;
begin
GetTime(h,m,s,sec100);
writeln(h,':Hours; ',m,':Minits; ',s,':Seconds; ',sec100,':Sec100.');
end;

procedure SGWndSomeQuad(a,c:SGVertex);
var
	b,d:SGVertex;
begin
b.Import(c.x,a.y,a.z);
d.Import(a.x,c.y,a.z);
glBegin(GL_QUADS);
glTexCoord2f(0,1);a.Vertex;
glTexCoord2f(1,1);b.Vertex;
glTexCoord2f(1,0);c.Vertex;
glTexCoord2f(0,0);d.Vertex;
glEnd;
end;

operator + (a:SGVertex;b:SGVertex2f):SGVertex;inline;
begin
Result.Import(a.x+b.x,a.y+b.y,a.z);
end;

operator + (a:SGVertex2f;b:SGVertex):SGVertex;inline;
begin
Result.Import(a.x+b.x,a.y+b.y,b.z);
end;

operator + (a,b:SGVertex2f):SGVertex2f;inline;
begin
Result.Import(a.x+b.x,a.y+b.y);
end;

operator + (a,b:SGVertex2f):SGVertex;inline;
begin
Result.Import(a.x+b.x,a.y+b.y);
end;

procedure SGSomeQuad(a,b,c,d:SGVertex;vl,np:SGPoint);
begin
glBegin(GL_QUADS);
glTexCoord2f(vl.x, vl.y);a.Vertex;
glTexCoord2f(np.x, vl.y);b.Vertex;
glTexCoord2f(np.x, np.y);c.Vertex;
glTexCoord2f(vl.x, np.y);d.Vertex;
glEnd;
end;

function SGPCharToString(const VChar:PChar):string;
var
	i:Longint = 0;
begin
try
	Result:='';
	while byte(VChar[i])<>0 do
		begin
		Result+=VChar[i];
		i+=1;
		end;
except
	Result:='';
	end;
end;

procedure SGRoundWindowQuad(const Vertex11,Vertex13:SGVertex;const Vertex21,Vertex23:SGVertex; 
	const Radius1:real;const Radius2:real; const Interval:LongInt;const QuadColor1:SGColor;const QuadColor2:SGColor;
	const WithLines:boolean; const LinesColor1:SGColor4f; const LinesColor2:SGColor4f);
begin
SGRoundQuad(Vertex11,Vertex13,Radius1,Interval,QuadColor1,LinesColor1,WithLines);
SGRoundQuad(Vertex21,Vertex23,Radius2,Interval,QuadColor2,LinesColor2,WithLines);
end;

procedure SGRoundQuad(
	const Vertex1,Vertex3:SGVertex; 
	const Radius:real; 
	const Interval:LongInt;
	const QuadColor:SGColor; 
	const LinesColor:SGColor4f; 
	const WithLines:boolean = False;
	const WithQuad:boolean = True);
var
	ArVertex:TSGArTSGVertex = nil;
begin
ArVertex:=SGGetArrayOfRoundQuad(Vertex1,Vertex3,Radius,Interval);
SGConstructRoundQuad(ArVertex,Interval,QuadColor,LinesColor,WithLines,WithQuad);
SetLength(ArVertex,0);
end;

function SGGetArrayOfRoundQuad(const Vertex1,Vertex3:SGVertex; const Radius:real; const Interval:LongInt):SGArVertex;
var
	Vertex2,Vertex4:SGVertex;
	VertexR1,VertexR2,VertexR3,VertexR4:SGVertex;
	I:LongInt;
begin
Result:=nil;
Vertex2.Import(Vertex3.x,Vertex1.y,(Vertex1.z+Vertex3.z)/2);
Vertex4.Import(Vertex1.x,Vertex3.y,(Vertex1.z+Vertex3.z)/2);
VertexR1.Import(Vertex1.x+Radius,Vertex1.y-Radius,Vertex1.z);
VertexR2.Import(Vertex2.x-Radius,Vertex2.y-Radius,Vertex2.z);
VertexR3.Import(Vertex3.x-Radius,Vertex3.y+Radius,Vertex3.z);
VertexR4.Import(Vertex4.x+Radius,Vertex4.y+Radius,Vertex4.z);
For i:=0 to Interval do
	begin SetLength(Result,Length(Result)+1);
	Result[High(Result)].Import(VertexR2.x+cos((Pi/2)/(Interval)*i)*Radius,VertexR2.y+sin((Pi/2)/(Interval)*i+Pi)*Radius+2*Radius,VertexR2.z); end;
For i:=0 to Interval do
	begin SetLength(Result,Length(Result)+1);
	Result[High(Result)].Import(VertexR1.x+cos((Pi/2)*i/(Interval)+Pi/2)*Radius,VertexR1.y+sin((Pi/2)*i/(Interval)+3*Pi/2)*Radius+2*Radius,VertexR1.z); end;
For i:=0 to Interval do
	begin SetLength(Result,Length(Result)+1);
	Result[High(Result)].Import(VertexR4.x+cos((Pi/2)*i/Interval+Pi)*Radius,VertexR4.y+sin((Pi/2)*i/(Interval))*Radius-2*Radius,VertexR4.z); end;
For i:=0 to Interval do
	begin SetLength(Result,Length(Result)+1);
	Result[High(Result)].Import(VertexR3.x+cos((Pi/2)*i/(Interval)+3*Pi/2)*Radius,VertexR3.y+sin((Pi/2)*i/(Interval)+Pi/2)*Radius-2*Radius,VertexR3.z); end;
end;

procedure SGConstructRoundQuad(
	const ArVertex:SGArSGVertex;
	const Interval:LongInt;
	const QuadColor:SGColor; 
	const LinesColor:SGColor4f; 
	const WithLines:boolean = False;
	const WithQuad:boolean = True);
var
	I:LongInt;
begin
if WithQuad then
	begin
	(QuadColor).Color;
	glBegin(GL_QUADS);
	for i:=0 to Interval-1 do
		begin
		ArVertex[Interval-i].Vertex;
		ArVertex[Interval+1+i].Vertex;
		ArVertex[Interval+2+i].Vertex;
		ArVertex[Interval-i-1].Vertex;
		end;
	ArVertex[0].Vertex;
	ArVertex[2*Interval+1].Vertex;
	ArVertex[2*Interval+2].Vertex;
	ArVertex[4*(Interval+1)-1].Vertex;
	for i:=0 to Interval-1 do
		begin
		ArVertex[(Interval+1)*2+i].Vertex;
		ArVertex[(Interval+1)*2+i+1].Vertex;
		ArVertex[(Interval+1)*4-2-i].Vertex;
		ArVertex[(Interval+1)*4-1-i].Vertex;
		end;
	glEnd();
	end;
if WithLines then
	begin
	LinesColor.Color;
	glBegin(GL_LINE_LOOP);
	for i:=Low(ArVertex) to High(ArVertex) do
		ArVertex[i].Vertex;
	glEnd();
	end;
end;

function SGGetCursorPositionForWindows:SGPoint;
begin
Result:=SGMouseCoords[1]+TSGViewportObject.Smezhenie;
end;

function SGPoint2fToVertex3f(const Point:SGPoint):SGVertex3f;
begin
Result.Import(Point.x,Point.y,0);
end;

procedure SGMatrixMode(const Mode:SGByte = SG_3D);inline;
begin
SGInitMatrixMode(Mode);
end;

procedure SGInitMatrixMode(const Mode:SGByte = SG_3D);inline;
begin
glViewport(0, 0, ContextWidth, ContextHeight);
glMatrixMode(GL_PROJECTION);
glLoadIdentity;
if  Mode=SG_2D then
	glOrtho(0,ContextWidth,ContextHeight,0,0,0.1)
else
	gluPerspective(45, ContextWidth / ContextHeight, 0.11, 1000);
glMatrixMode(GL_MODELVIEW);
glLoadIdentity;
end;

operator * (a:SGColor;b:real):SGColor;inline;
begin
Result.SetVariables(a.r*b,a.g*b,a.b*b,a.a*b);
end;

function SGColorImport(const r1:real = 0;const g1:real = 0;const b1:real = 0;const a1:real = 1):SGColor;
begin
Result.SetVariables(r1,g1,b1,a1);
end;

function SGStringToPChar(const s:string):PCHAR;
var
	i:longint;
begin
GetMem(Result,Length(s)+1);
for i:=1 to Length(s) do
	Result[i-1]:=s[i];
Result[i]:=#0;
end;

function SGPoint2fToVertex2f(const Point:SGPoint):SGVertex2f;
begin
Result.Import(Point.x,Point.y);
end;

procedure TSGVertex2f.Import(const x1:real = 0;const y1:real = 0);
begin
x:=x1;
y:=y1;
end;

procedure TSGPoint2f.Vertex;
begin
glVertex2f(x,y);
end;

function SGGetVertexOnIntersectionOfTwoLinesFromFourVertex(const q1,q2,w1,w2:SGVertex):SGVertex;
var
	q3:SGVertex;
begin
q3:=q2;
q3+=SGGetVertexWhichNormalFromThreeVertex(q1,q2,w1);
Result:=SGGetVertexOnIntersectionOfThreePlane(
	SGGetPlaneFromThreeVertex(q1,q2,q3),
	SGGetPlaneFromThreeVertex(SGGetVertexInAttitude(q1,q2),w1,w2),
	SGGetPlaneFromThreeVertex(SGGetVertexInAttitude(q1,q3),w1,w2));
end;

function SGGetPlaneFromNineReals(const x1,y1,z1,x2,y2,z2,x0,y0,z0:real):SGPlane;
begin
Result.Import(
	+SGGetMatrix2x2(y1-y0,z1-z0,y2-y0,z2-z0),
	-SGGetMatrix2x2(x1-x0,z1-z0,x2-x0,z2-z0),
	+SGGetMatrix2x2(x1-x0,y1-y0,x2-x0,y2-y0),
	-x0*SGGetMatrix2x2(y1-y0,z1-z0,y2-y0,z2-z0)
	+y0*SGGetMatrix2x2(x1-x0,z1-z0,x2-x0,z2-z0)
	-z0*SGGetMatrix2x2(x1-x0,y1-y0,x2-x0,y2-y0))
end;

function SGGetPlaneFromThreeVertex(const a1,a2,a3:SGVertex):SGPlane;
begin
Result:=SGGetPlaneFromNineReals(a1.x,a1.y,a1.z,a2.x,a2.y,a2.z,a3.x,a3.y,a3.z);
end;

function SGGetVertexWhichNormalFromThreeVertex(const p1,p2,p3:SGVertex):SGVertex;
var a,b,c:real;
begin
a:=p1.y*(p2.z-p3.z)+p2.y*(p3.z-p1.z)+p3.y*(p1.z-p2.z);
b:=p1.z*(p2.x-p3.x)+p2.z*(p3.x-p1.x)+p3.z*(p1.x-p2.x);
c:=p1.x*(p2.y-p3.y)+p2.x*(p3.y-p1.y)+p3.x*(p1.y-p2.y);
Result.Import(a/(sqrt(a*a+b*b+c*c)),b/(sqrt(a*a+b*b+c*c)),c/(sqrt(a*a+b*b+c*c)));
end;

function SGGetVertexOnIntersectionOfThreePlane(p1,p2,p3:SGPlane):SGVertex;
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

function SGGetMatrix3x3(a1,a2,a3,a4,a5,a6,a7,a8,a9:real):real;
begin
Result:=a1*SGGetMatrix2x2(a5,a6,a8,a9)-a2*SGGetMatrix2x2(a4,a6,a7,a9)+a3*SGGetMatrix2x2(a4,a5,a7,a8);
end;

function SGGetMatrix2x2(a1,a2,a3,a4:real):real;
begin
Result:=a1*a4-a2*a3;
end;

procedure TSGPlane.Import(const a1:real = 0; const b1:real = 0; const c1:real = 0; const d1:real = 0);
begin
a:=a1;
b:=b1;
c:=c1;
d:=d1;
end;

procedure TSGColor3f.Color;
begin
SetColor();
end;

procedure TSGColor3f.SetColor;
begin
glColor3f(r,g,b);
end;

procedure TSGColor3f.Import(const r1: single; const g1: single; const b1: single
  );
begin
  r:=r1;
  g:=g1;
  b:=b1;
end;

procedure SGQuad(ArVertex:TSGArFor1To4OfSGVertex);
begin
SGQuad(ArVertex[1],ArVertex[2],ArVertex[3],ArVertex[4])
end;

procedure SGViewportObject.CanculateColor;
begin
glReadPixels(
	Point.x,
	ContextHeight-Point.y-1,
	1, 
	1, 
	GL_RGBA, 
	GL_FLOAT, 
	@FColor);
end;

procedure SGViewportObject.CanculateVertex;{$}
begin
glReadPixels(
	Point.x,
	ContextHeight-Point.y-1,
	1, 
	1, 
	GL_DEPTH_COMPONENT, 
	GL_FLOAT, 
	@depth);
gluUnProject(
	Point.x,
	ContextHeight-Point.y-1,
	depth,
	mv_matrix,
	proj_matrix,
	viewport,
	@x,
	@y,
	@z);
end;

procedure SGViewportObject.SetPoint(NewPoint:SGPoint;const WithSmezhenie:boolean = True);
begin
Point:=NewPoint;
if WithSmezhenie then
	Point+=Smezhenie;
end;

function SGViewportObject.GetVertex:SGVertex;
begin
Result.Import(x,y,z);
end;

procedure SGViewportObject.GetViewport;
begin
glGetIntegerv(GL_VIEWPORT,viewport);
glGetDoublev(GL_MODELVIEW_MATRIX,mv_matrix);
glGetDoublev(GL_PROJECTION_MATRIX,proj_matrix);
end;

function SGGetVertexFromPointOnScreen(const Point:SGPoint;const WithSmezhenie:boolean = True):SGVertex;
var
	ViewportObj:SGViewportObject;
begin
ViewportObj:=TSGViewportObject.Create;
ViewportObj.GetViewport;
ViewportObj.SetPoint(Point,WithSmezhenie);
ViewportObj.CanculateVertex;
Result:=ViewportObj.Vertex;
ViewportObj.Destroy;
end;

function SGGetVertexUnderCursor(const WithSmezhenie:boolean = True):SGVertex;
begin
Result:=SGGetVertexFromPointOnScreen(SGMouseCoords[1],WithSmezhenie);
end;

procedure TSGPoint2f.Write;
begin
writeln(x,' ',y);
end;

function SGVal(const Text:string = '0'):longint;
begin
Val(Text,Result);
end;

function SGVertexOnQuad(const Vertex:SGVertex; const QuadVertex1:SGVertex;const QuadVertex3:SGVertex):boolean;
begin
Result:=SGVertexOnQuad(
	Vertex,
	QuadVertex1,
	SGVertexImport(
		QuadVertex1.x,
		QuadVertex3.y,
		QuadVertex1.z),
	QuadVertex3,
	SGVertexImport(
		QuadVertex3.x,
		QuadVertex1.y,
		QuadVertex3.z));
end;

function SGVertexOnQuad(const Vertex:SGVertex; const QuadVertex1:SGVertex;const QuadVertex2:SGVertex;const QuadVertex3:SGVertex;const QuadVertex4:SGVertex):boolean;
begin
if abs(
	(SGAbsTwoVertex(QuadVertex1,QuadVertex2)*SGAbsTwoVertex(QuadVertex2,QuadVertex3))
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

function SGTreugPlosh(const a1,a2,a3:SGVertex):real;
var
	p:real;
begin
p:=(SGAbsTwoVertex(a1,a2)+SGAbsTwoVertex(a1,a3)+SGAbsTwoVertex(a3,a2))/2;
SGTreugPlosh:=sqrt(p*(p-SGAbsTwoVertex(a1,a2))*(p-SGAbsTwoVertex(a3,a2))*(p-SGAbsTwoVertex(a1,a3)));
end;

function SGAbsTwoVertex(const Vertex1:SGVertex;const Vertex2:SGVertex):real;
begin
Result:=sqrt(sqr(Vertex1.x-Vertex2.x)+sqr(Vertex1.y-Vertex2.y)+sqr(Vertex1.z-Vertex2.z));
end;

procedure SGLoadFrameIdentity;
begin
glLoadIdentity;
glTranslatef(0,0,-6);
end;

procedure SGQuad(const Vertex1:SGVertex;const Vertex2:SGVertex;const Vertex3:SGVertex;const Vertex4:SGVertex);
begin
glBegin(GL_QUADS);
Vertex1.Vertex;
Vertex2.Vertex;
Vertex3.Vertex;
Vertex4.Vertex;
glEnd();
end;

function SGPointImport(const NewX:LongInt = 0; const NewY:LongInt = 0 ):SGPoint;
begin
Result.x:=NewX;
Result.y:=NewY;
end;

function SGPointImport(const NewX:Real = 0; const NewY:Real = 0 ):SGPoint;
begin
Result.x:=Round(NewX);
Result.y:=Round(NewY);
end;

procedure TSGVertex3f.Import(const x1:real = 0; const y1:real = 0; const z1:real = 0);
begin
x:=x1;
y:=y1;
z:=z1;
end;

function SGVertexImport(const x:real = 0;const y:real = 0;const z:real = 0):TSGVertex3f;
begin
Result.x:=x;
Result.y:=y;
Result.z:=z;
end;

operator / (a:SGVertex;b:real):SGVertex;inline;
begin
Result.x:=a.x/b;
Result.y:=a.y/b;
Result.z:=a.z/b;
end;

operator * (a:SGVertex;b:real):SGVertex;inline;
begin
Result.x:=a.x*b;
Result.y:=a.y*b;
Result.z:=a.z*b;
end;



operator - (a,b:SGVertex):SGVertex;inline;
begin
Result.x:=a.x-b.x;
Result.y:=a.y-b.y;
Result.z:=a.z-b.z;
end;

operator + (a,b:SGVertex):SGVertex;inline;
begin
Result.x:=a.x+b.x;
Result.y:=a.y+b.y;
Result.z:=a.z+b.z;
end;

procedure SGIdentityObject.ChangeAndInit;
begin
Change;
Init;
end;

procedure TSGBezierCurve.CalculateRandom(Detalization1,KolVertex,Diapazon:longint);
var
	i:longint;
begin
Clear;
SetDetalization(Detalization1);
for i:=1 to KolVertex do
	InitVertex(SGTSGVertex3fImport(
		SGRandomMinus*random(Diapazon)/(random(Diapazon)+1),
		SGRandomMinus*random(Diapazon)/(random(Diapazon)+1),
		SGRandomMinus*random(Diapazon)/(random(Diapazon)+1)));
Calculate;
end;

procedure SGIdentityObject.Init;
begin
glTranslatef(Left,Top,-10*Zum);
glRotatef(Rotate1,1,0,0);
glRotatef(Rotate2,0,1,0);
end;

procedure SGIdentityObject.Change;
var
	LastTop,LastLeft,LastR1,LastR2:real;
begin
Changet:=False;
LastLeft:=Left;
LastTop:=Top;
LastR1:=Rotate1;
LastR2:=Rotate2;
case SGMouseWheel of
-1:
	begin
	Zum*=0.9;
	Changet:=True;
	end;
1:
	begin
	Zum*=1.1;
	Changet:=True;
	end;
end;
if SGIsMouseKeyDown(1) then
	begin
	Rotate2+=SGGetMousePosition(0).x/3;
	Rotate1+=SGGetMousePosition(0).y/3;
	end;
if SGIsMouseKeyDown(2) then{$}
	begin
	Top+=    (-SGGetMousePosition(0).y/100)*Zum;
	Left+=   ( SGGetMousePosition(0).x/100)*Zum;
	end;
if (SGKeyPressed and (SGIsKeyDown(char(17))) and (SGKeyPressedChar=char(189))) then
	begin
	Zum*=1.1;
	Changet:=true;
	end;
if  (SGKeyPressed and (SGIsKeyDown(char(17))) and (SGKeyPressedChar=char(187)))  then
	begin
	Zum*=0.9;
	Changet:=true;
	end;
if (not Changet) and (not (SGRealsEqual(LastLeft,Left) and SGRealsEqual(LastR1,Rotate1) and SGRealsEqual(LastTop,Top) and SGRealsEqual(LastR2,Rotate2))) then
	Changet:=True;
end;

procedure SGIdentityObject.Clear;
begin
Rotate1:=0;
Rotate2:=0;
Rotate3:=0;
Top:=0;
Zum:=1;
Left:=0;
end;

function SGGetMousePosition(const ID:longint = 1):SGPoint;
begin
if ID in [Low(SGMouseCoords)..High(SGMouseCoords)] then
	begin
	Result:=SGMouseCoords[ID];
	end;
end;

procedure SGPoint.Import(const x1:longint = 0; const y1:longint = 0);
begin
x:=x1;
y:=y1;
end;

operator + (a,b:SGPoint):SGPoint;inline;
begin
Result.x:=a.x+b.x;
Result.y:=a.y+b.y;
end;

operator - (a,b:SGPoint):SGPoint;inline;
begin
Result.x:=a.x-b.x;
Result.y:=a.y-b.y;
end;

procedure SGSetUserPaintProcedure(const p:pointer = nil);
begin
SGUserPaintProcedure:=SGProcedure(p);
end;

procedure SGPaint;
begin
SGCrearOpenGL;
SGInitMatrixMode(SG_3D);
if SGUserPaintProcedure<>nil then
	begin
	SGUserPaintProcedure;
	end;
SGIIdleFunction;
if SGCLPaintProcedure<>nil then
	SGCLPaintProcedure;
SGSwapBuffers;
SGGetMessages;
end;

procedure SGSetMouseKeyDown(const l:longint = 0);
begin
if l in [1..3] then
	begin
	SGMouseKeysDown[l-1]:=True;
	end;
end;

procedure SGSetMouseKeyUp(const l:longint = 0);
begin
if l in [1..3] then
	begin
	SGMouseKeysDown[l-1]:=False;
	end;
end;

function SGIsMouseKeyDown(const l:byte = 1):boolean;
begin
if l in [1..3] then
	begin
	Result:=SGMouseKeysDown[l-1];
	end
else
	Result:=False;
end;

function SGMouseKeyPressed:boolean;
begin
Result:=SGMouseKeyPressedVariable<>0;
end;

function SGGetMouseKeyPressed:byte;
begin
Result:=SGMouseKeyPressedVariable;
end;

procedure SGSetMouseKey(const l:longint  = 0);
begin
SGMouseKeyPressedVariable:=l;
end;

procedure SGClearMouseKey();
begin
SGMouseKeyPressedVariable:=0;
end;

procedure SGClearMouseWheel();
begin
SGMouseWheelVariable:=0;
end;

procedure SGSetMouseWheel(const l:longint = 0);
begin
SGMouseWheelVariable:=l;
end;

function SGMouseWheel:longint;
begin
Result:=SGMouseWheelVariable;
end;

procedure SGSetKey(const c:char = #0);
begin
SGKeyPressedVariable:=c;
end;

function SGIsKeyDown(const c:char = #0):boolean;
begin
Result:=SGKeysDown[byte(c)];
end;

function SGKeyPressed:boolean;
begin
Result:=SGKeyPressedVariable <> #0;
end;

function SGKeyPressedChar:char;
begin
Result:=SGKeyPressedVariable;
end;

procedure SGClearKey;
begin
SGKeyPressedVariable:=#0;
end;

procedure SGSetKeyUp(const c:char = ' ');
begin
SGKeysDown[byte(c)]:=False;
end;

procedure SGSetKeyDown(const c:char = ' ');
begin
SGKeysDown[byte(c)]:=True;
end;

procedure SGInitOpenGL;
var
	AmbientLight : array[0..3] of glFloat = (0.5,0.5,0.5,1.0);
	DiffuseLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
	SpecularLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
	SpecularReflection : array[0..3] of glFloat = (0.4,0.4,0.4,1.0);
	LightPosition : array[0..3] of glFloat = (0,1,0,2);
	fogColor:SGColor4f = (r:0;g:0;b:0;a:1);
begin

glEnable(GL_FOG);
glFogi(GL_FOG_MODE, GL_LINEAR);
glHint (GL_FOG_HINT, GL_NICEST);
//glHint(GL_FOG_HINT, GL_DONT_CARE);
glFogf (GL_FOG_START, 300);
glFogf (GL_FOG_END, 400);
glFogfv(GL_FOG_COLOR, @fogColor);
glFogf(GL_FOG_DENSITY, 0.55);

glClearColor(0,0,0,0);
glClearDepth(1.0);
glDepthFunc(GL_LEQUAL);
glEnable(GL_DEPTH_TEST);

glEnable(GL_LINE_SMOOTH);
glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
glLineWidth (1.5);

glShadeModel(GL_SMOOTH);
glEnable(GL_TEXTURE_1D);
glEnable(GL_TEXTURE_2D);
glEnable(GL_TEXTURE);
glEnable (GL_BLEND);
glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA) ;
glEnable (GL_LINE_SMOOTH);
glEnable (GL_POLYGON_SMOOTH);
glShadeModel(GL_smooth);

glEnable(GL_LIGHTING);
glLightfv(GL_LIGHT0,GL_AMBIENT, @AmbientLight);
glLightfv(GL_LIGHT0,GL_DIFFUSE, @DiffuseLight);
glLightfv(GL_LIGHT0,GL_SPECULAR, @SpecularLight);
glEnable(GL_LIGHT0);

glLightfv(GL_LIGHT0,GL_POSITION,@LightPosition);

glEnable(GL_COLOR_MATERIAL);
glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
glMaterialfv(GL_FRONT, GL_SPECULAR, @SpecularReflection);
glMateriali(GL_FRONT,GL_SHININESS,100);

if SGCLLoadProcedure<>nil then
	SGCLLoadProcedure;

SG_USE_VBO:=Load_GL_ARB_vertex_buffer_object;
end;

function SGTSGVertex3fImport(const x:real = 0;const y:real = 0;const z:real = 0):TSGVertex3f;
begin
Result.x:=x;
Result.y:=y;
Result.z:=z;
end;

procedure SGCrearOpenGL;
begin
glClear(GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT);
glLoadIdentity();
glTranslatef(0,0,0);
glRotatef( 0,0,1,0);
end;

function TSGBezierCurve.GetDetalization:longword;
begin
GetDetalization:=Detalization;
end;

procedure TSGBezierCurve.SetArray(const a:TArTSGVertex3f);
begin
SetLength(StartArray,0);
StartArray:=a;
end;

function TSGBezierCurve.SetDetalization(const l:dword):boolean;
begin
if l>0 then
	begin
	SetDetalization:=true;
	Detalization:=l;
	end
else
	SetDetalization:=false;
end;

procedure TSGBezierCurve.Init(const p:Pointer = nil);
var	
	i:longint;
begin
GlBegin(GL_LINE_STRIP);
for i:=Low(EndArray) to High(EndArray) do
	begin
	EndArray[i].Vertex(p);
	end;
GlEnd();
end;

function SGGetVertexInAttitude(const t1,t2:TSGVertex3f; const r:real = 0.5):TSGVertex3f;
begin
Result.SetVariables(
	-r*(t1.x-t2.x)+t1.x,
	-r*(t1.y-t2.y)+t1.y,
	-r*(t1.z-t2.z)+t1.z);
end;

procedure TSGBezierCurve.Calculate;
var
	i:longword;

function GetKoor(const R:real;const A:TArTSGVertex3f):TSGVertex3f;
var
	A2:TArTSGVertex3f;
	i:longint;
begin
if Length(a)=2 then
	begin
	GetKoor:=SGGetVertexInAttitude(A[Low(A)],A[High(A)],r);
	end
else
	begin
	SetLength(A2,Length(A)-1);
	for i:=Low(A2) to High(A2) do
		A2[i]:=SGGetVertexInAttitude(A[i],A[i+1],r);
	GetKoor:=GetKoor(R,A2);
	SetLength(A2,0);
	end;
end;

begin
SetLength(EndArray,Detalization+1);
for i:=Low(EndArray) to High(EndArray) do
	begin
	EndArray[i]:=GetKoor(i/Detalization,StartArray);
	end;
end;

procedure TSGBezierCurve.InitVertex(const k:TSGVertex3f);
begin
SetLength(StartArray,Length(StartArray)+1);
StartArray[High(StartArray)]:=k;
end;

procedure TSGBezierCurve.Clear;
begin
SetLength(StartArray,0);
SetLength(EndArray,0);
SetDetalization(40);
end;


procedure TSGVertex2f.SetVariables(const x1:real = 0; const y1:real = 0);
begin
x:=x1;
y:=y1;
end;

procedure TSGVertex3f.SetVariables(const x1:real = 0; const y1:real = 0; const z1:real = 0);
begin
x:=x1;
y:=y1;
z:=z1;
end;

procedure TSGColor4f.SetVariables(const r1:real = 0; const g1:real = 0; const b1:real = 0; const a1:real = 1);
begin
r:=r1;
g:=g1;
b:=b1;
a:=a1;
end;

procedure TSGVertex2f.TexCoord;
begin
glTexCoord2f(x,y);
end;

procedure TSGColor4f.SetColor;
begin
Color;
end;

procedure TSGColor4f.Color;
begin
glColor4f(r,g,b,a);
end;

procedure TSGVertex2f.Vertex;
begin
glVertex2f(x,y);
end;

procedure TSGVertex3f.Vertex;
begin
glVertex3f(x,y,z);
end;

{$IFDEF SGDebuging}
	{$NOTE case SGMethodLoginToOpenGLType of}
	{$ENDIF}

function SGContextFullscreen:Boolean;
begin
case SGMethodLoginToOpenGLType of
SGMethodLoginToOpenGLUnInstalled:
	begin
	Result:=False;
	end;
{$IFDEF MSWINDOWS}
	SGMethodLoginToOpenGLWinAPI:
		begin
		Result:=PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.Fullscreen;
		end;
	{$ENDIF}
{$IFDEF LAZARUS}
	SGMethodLoginToOpenGLLazarus:
		begin
		Result:=False;
		end;
	{$ENDIF}
{$IFDEF GLUT}
	SGMethodLoginToOpenGLGLUT:
		begin
		Result:=LongBool(SGMethodLoginToOpenGL);
		end;
	{$ENDIF}
else
	begin
	Result:=False;
	end;
end;
end;

class function TSGGLImage.ReadPixelsShift:TSGPoint2f;
begin
Result.Import;
case SGMethodLoginToOpenGLType of
SGMethodLoginToOpenGLUnInstalled:
	begin
	
	end;
{$IFDEF MSWINDOWS}
	SGMethodLoginToOpenGLWinAPI:
		begin
		if not PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.Fullscreen then
			begin
			Result.Import(-3,-10);
			end;
		end;
	{$ENDIF}
{$IFDEF LAZARUS}
	SGMethodLoginToOpenGLLazarus:
		begin
		
		end;
	{$ENDIF}
{$IFDEF GLUT}
	SGMethodLoginToOpenGLGLUT:
		begin
		
		end;
	{$ENDIF}
else
	begin
	
	end;
end;
end;

procedure SGCloseContext;
begin
case SGMethodLoginToOpenGLType of
SGMethodLoginToOpenGLUnInstalled:
	begin
	
	end;
{$IFDEF MSWINDOWS}
	SGMethodLoginToOpenGLWinAPI:
		begin
		PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.KillOGLWindow;
		SGMethodLoginToOpenGL:=nil;
		SGMethodLoginToOpenGLType:=SGMethodLoginToOpenGLUnInstalled;
		end;
	{$ENDIF}
{$IFDEF LAZARUS}
	SGMethodLoginToOpenGLLazarus:
		begin
		SaGe.PSGMethodLazarus(SGMethodLoginToOpenGL)^.PForm^.Close;
		SaGe.PSGMethodLazarus(SGMethodLoginToOpenGL)^.PForm^.Destroying;
		SGMethodLoginToOpenGL:=nil;
		SGMethodLoginToOpenGLType:=SGMethodLoginToOpenGLUnInstalled;
		end;
	{$ENDIF}
{$IFDEF GLUT}
	SGMethodLoginToOpenGLGLUT:
		begin
		Halt;
		SGMethodLoginToOpenGL:=nil;
		SGMethodLoginToOpenGLType:=SGMethodLoginToOpenGLUnInstalled;
		end;
	{$ENDIF}
{$IFDEF UNIX}
	SGMethodLoginToOpenGLUnix:
		begin
		XCloseDisplay(SGMethodGLX(SGMethodLoginToOpenGL).dpy);
		SGMethodLoginToOpenGL:=nil;
		SGMethodLoginToOpenGLType:=SGMethodLoginToOpenGLUnInstalled;
		end;
	{$ENDIF}
else
	begin
	
	end;
end;
end;

class function SGViewportObject.Smezhenie:SGPoint;
begin
Result.Import;
case SGMethodLoginToOpenGLType of
SGMethodLoginToOpenGLUnInstalled:
	begin
	
	end;
{$IFDEF MSWINDOWS}
	SGMethodLoginToOpenGLWinAPI:
		begin
		if not PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.Fullscreen then
			begin
			Result.Import(-3,3);
			end;
		end;
	{$ENDIF}
{$IFDEF LAZARUS}
	SGMethodLoginToOpenGLLazarus:
		begin
		{$IFDEF MSWINDOWS}
			Result.Import(-7,-30);
			{$ENDIF}
		{$IFDEF UNIX}
			Result.Import(-3,-25);
			{$ENDIF}
		end;
	{$ENDIF}
{$IFDEF GLUT}
	SGMethodLoginToOpenGLGLUT:
		begin
		{$IFDEF MSWINDOWS}
			if SGContextFullscreen then
				Result.Import()
			else
				Result.Import(3,0);
			{$ENDIF}
		{$IFDEF UNIX}
			Result.Import(0,0);
			{$ENDIF}
		end;
	{$ENDIF}
else
	begin
	
	end;
end;
end;

function SGGetWindowRect:SGPoint;
{$IFDEF MSWINDOWS}
var
	Rec:TRect;
	{$ENDIF}
begin
Result.Import;
case SGMethodLoginToOpenGLType of
SGMethodLoginToOpenGLUnInstalled:
	begin
	
	end;
{$IFDEF MSWINDOWS}
	SGMethodLoginToOpenGLWinAPI:
		begin
		getWindowRect(PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.HWindow,Rec);
		Result.x:=Rec.Left;
		Result.y:=Rec.Top;
		end;
	{$ENDIF}
{$IFDEF LAZARUS}
	SGMethodLoginToOpenGLLazarus:
		begin
		Result.Import(
			PSGMethodLazarus(SGMethodLoginToOpenGL)^.PForm^.Left+PSGMethodLazarus(SGMethodLoginToOpenGL)^.POpenGLControl^.Left,
			PSGMethodLazarus(SGMethodLoginToOpenGL)^.PForm^.Top+PSGMethodLazarus(SGMethodLoginToOpenGL)^.POpenGLControl^.Top);
		end;
	{$ENDIF}
{$IFDEF GLUT}
	SGMethodLoginToOpenGLGLUT:
		begin
		{Result.Import(
			glutGet(GLUT_WINDOW_LEFT),
			glutGet(GLUT_WINDOW_TOP));}
		end;
	{$ENDIF}
else
	begin
	Result.Import();
	end;
end;
end;

procedure SGSetCursorPosition(const Point :SGPoint);
begin
{$IFDEF MSWINDOWS}
	SetCursorPos(Point.x,Point.y);
	{$ENDIF}
end;

function SGGetCursorPosition:SGPoint;
{$IFDEF MSWINDOWS}
var
	p:Tpoint;
	{$ENDIF}
begin
case SGMethodLoginToOpenGLType of
SGMethodLoginToOpenGLUnInstalled:
	begin
	Result.Import;
	end;
{$IFDEF MSWINDOWS}
	SGMethodLoginToOpenGLWinAPI:
		begin
		GetCursorPos(p);
		Result.x:=p.x;
		Result.y:=p.y;
		end;
	{$ENDIF}
{$IFDEF GLUT}
	SGMethodLoginToOpenGLGLUT:
		begin
		Result:=SGGLUTSettings.CursorPosition
		end;
	{$ENDIF}
{$IFDEF UNIX}
	SGMethodLoginToOpenGLUnix:
		begin
		Result.Import(SGGLXSettings.CursorWidth,SGGLXSettings.CursorHeight);
		end;
	{$ENDIF}
{$IFDEF LAZARUS}
	SGMethodLoginToOpenGLLazarus:
		begin
		if SGMethodLoginToOpenGLType = SGMethodLoginToOpenGLLazarus then
			begin
			Result.Import(
				Mouse.CursorPos.x,
				Mouse.CursorPos.y);
			end;
		end;
	{$ENDIF}
else
	begin
	Result.Import;
	end;
end;
end;

function SGGetDeviceCaps:SGPoint;
begin
case SGMethodLoginToOpenGLType of
{$IFDEF MSWINDOWS}
	SGMethodLoginToOpenGLWinAPI:
		begin
		Result.Import(
			GetDeviceCaps(GetDC(GetDesktopWindow),HORZRES),
			GetDeviceCaps(GetDC(GetDesktopWindow),VERTRES));
		end;
	{$ENDIF}
{$IFDEF GLUT}
	SGMethodLoginToOpenGLGLUT:
		begin
		Result.Import(
			glutGet(GLUT_SCREEN_WIDTH),
			glutGet(GLUT_SCREEN_HEIGHT));
		end;
	{$ENDIF}
{$IFDEF UNIX}
	SGMethodLoginToOpenGLUnix:
		begin
		Result.Import(
			XWidthOfScreen(XScreenOfDisplay(SGMethodGLX(SGMethodLoginToOpenGL).dpy,0)),
			XHeightOfScreen(XScreenOfDisplay(SGMethodGLX(SGMethodLoginToOpenGL).dpy,0)));
		end;
	{$ENDIF}
{$IFDEF LAZARUS}
        SGMethodLoginToOpenGLLazarus:
	{$IFDEF UNIX}
                Result.Import(
			XWidthOfScreen(XScreenOfDisplay(SGMethodGLX(SGMethodLoginToOpenGL).dpy,0)),
			XHeightOfScreen(XScreenOfDisplay(SGMethodGLX(SGMethodLoginToOpenGL).dpy,0)));
        {$ELSE}
               Result.Import(
			GetDeviceCaps(GetDC(GetDesktopWindow),HORZRES),
			GetDeviceCaps(GetDC(GetDesktopWindow),VERTRES));
               {$ENDIF}
	{$ENDIF}
else
	begin
        {$IFDEF MSWINDOWS}
		Result.Import(
			GetDeviceCaps(GetDC(GetDesktopWindow),HORZRES),
			GetDeviceCaps(GetDC(GetDesktopWindow),VERTRES));
	{$ELSE}

               {$ENDIF}
	end;
end;
end;

function GetContextHeight:longint;
begin
case SGMethodLoginToOpenGLType of
SGMethodLoginToOpenGLUnInstalled:
	begin
	Result:=0;
	end;
{$IFDEF MSWINDOWS}
	SGMethodLoginToOpenGLWinAPI:
		begin
		Result:=PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.Height;
		end;
	{$ENDIF}
{$IFDEF LAZARUS}
	SGMethodLoginToOpenGLLazarus:
		begin
		Result:=PSGMethodLazarus(SGMethodLoginToOpenGL)^.POpenGLControl^.Height;
		end;
	{$ENDIF}
{$IFDEF GLUT}
	SGMethodLoginToOpenGLGLUT:
		begin
		Result:=glutGet(GLUT_WINDOW_HEIGHT);
		end;
	{$ENDIF}
{$IFDEF UNIX}
	SGMethodLoginToOpenGLUnix:
		begin
		Result:=SGGLXSettings.WindowHeight;
		end;
	{$ENDIF}
else
	begin
	Result:=0;
	end;
end;
end;

function GetContextWidth:longint;
begin
case SGMethodLoginToOpenGLType of
SGMethodLoginToOpenGLUnInstalled:
	begin
	Result:=0;
	end;
{$IFDEF MSWINDOWS}
	SGMethodLoginToOpenGLWinAPI:
		begin
		Result:=PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.Width;
		end;
	{$ENDIF}
{$IFDEF LAZARUS}
	SGMethodLoginToOpenGLLazarus:
		begin
		Result:=PSGMethodLazarus(SGMethodLoginToOpenGL)^.POpenGLControl^.Width;
		end;
	{$ENDIF}
{$IFDEF GLUT}
	SGMethodLoginToOpenGLGLUT:
		begin
		Result:=glutGet(GLUT_WINDOW_WIDTH);
		end;
	{$ENDIF}
{$IFDEF UNIX}
	SGMethodLoginToOpenGLUnix:
		begin
		Result:=SGGLXSettings.WindowWidth;
		end;
	{$ENDIF}
else
	begin
	Result:=0;
	end;
end;
end;

procedure SGResizeContext;
begin
if SGCLForReSizeScreenProcedure<>nil then
	SGCLForReSizeScreenProcedure;
SaGe.SGContextResized:=True;
SaGe.SGInitMatrixMode(SG_3D);
case SGMethodLoginToOpenGLType of
SGMethodLoginToOpenGLUnInstalled:
	begin
	
	end;
{$IFDEF MSWINDOWS}
	SGMethodLoginToOpenGLWinAPI:
		begin

		end;
	{$ENDIF}
{$IFDEF LAZARUS}
	SGMethodLoginToOpenGLLazarus:
		begin
		
		end;
	{$ENDIF}
{$IFDEF GLUT}
	SGMethodLoginToOpenGLGLUT:
		begin
		
		end;
	{$ENDIF}
else
	begin
	
	end;
end;
end;

function One(Any:LongInt):LongInt;
begin
Result:=Any;
if Result>1 then
	Result:=1
else
	if Result<-1 then
		Result:=-1;
end;

procedure SGGetMessages;
{$IFDEF UNIX}
var 
	Event: TXEvent;
    KeySum:TKeySym;
    s:string[4];
	{$ENDIF}
begin
SGClearKey;
SGClearMouseWheel;
SGClearMouseKey;
SaGe.SGContextResized:=False;
case SGMethodLoginToOpenGLType of
SGMethodLoginToOpenGLUnInstalled:
	begin
	
	end;
{$IFDEF MSWINDOWS}
	SGMethodLoginToOpenGLWinAPI:
		begin
		PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.Messages;
		end;
	{$ENDIF}
{$IFDEF GLUT}
	SGMethodLoginToOpenGLGLUT:
		begin
		if SGIsMouseKeyDown(2) then
			SGMouseWheelVariable:=One(round(SGMouseCoords[0].y/2));
		end;
	{$ENDIF}
{$IFDEF UNIX}
	SGMethodLoginToOpenGLUnix:
		begin
		While XPending(SGMethodGLX(SGMethodLoginToOpenGL).dpy)<>0 do
			begin 
			XNextEvent(SGMethodGLX(SGMethodLoginToOpenGL).dpy,@event);
			case Event._Type of
			ConfigureNotify:
				begin
				SGGLXSettings.WindowWidth:=Event.XConfigure.Width;
				SGGLXSettings.WindowHeight:=Event.XConfigure.Height;
				SGResizeContext;
				end;
			MotionNotify:
				begin
				SGGLXSettings.CursorHeight:=Event.XButton.y;
				SGGLXSettings.CursorWidth:=Event.XButton.x;
				end;
			ButtonPress:
				begin
				if Event.XButton.Button in [4,5] then
					begin
					if Event.XButton.Button=4 then
						SGSetMouseWheel(-1)
					else
						SGSetMouseWheel(1);
					end
				else
					begin
					if Event.XButton.Button=1 then
						begin
						SGSetMouseKey(Event.XButton.Button);
						SGSetMouseKeyDown(Event.XButton.Button);
						end
					else
						begin
						SGSetMouseKey(2+Byte(not Boolean(Event.XButton.Button-2)));
						SGSetMouseKeyDown(2+Byte(not Boolean(Event.XButton.Button-2)));
						end;
					end;
				end;
			ButtonRelease:
				begin
				if Event.XButton.Button in [1..3] then
					begin
					if Event.XButton.Button=1 then
						begin
						SGSetMouseKey(Event.XButton.Button+3);
						SGSetMouseKeyUp(Event.XButton.Button);
						end
					else
						begin
						SGSetMouseKey(2+Byte(not Boolean(Event.XButton.Button-2))+3);
						SGSetMouseKeyUp(2+Byte(not Boolean(Event.XButton.Button-2)));
						end;
					end;
				end;
			KeyPress:
				begin
                XLookupString(@Event.Xkey,@s,sizeof(s),@KeySum,nil);
				SGSetKey(char(Keysum));
				SGSetKeyDown(char(Keysum));
				end;
			KeyRelease:
				begin
                XLookupString(@Event.Xkey,@s,sizeof(s),@KeySum,nil);
				SGSetKeyUp(char(Keysum));
				end;
			DestroyNotify:
				begin
				SGCloseContext();
				end;
			end;
			end;
		end;
	{$ENDIF}
else
	begin
	
	end;
end;
SGMouseCoords[3]:=SGGetCursorPosition;
SGMouseCoords[2]:=SGMouseCoords[1];
SGMouseCoords[1]:=SGMouseCoords[3]-SGGetWindowRect;
SGMouseCoords[0]:=SGMouseCoords[1]-SGMouseCoords[2];
end;

procedure SGSwapBuffers;
begin
case SGMethodLoginToOpenGLType of
SGMethodLoginToOpenGLUnInstalled:
	begin
	
	end;
{$IFDEF MSWINDOWS}
	SGMethodLoginToOpenGLWinAPI:
		begin
		PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.SwapBuffers;
		end;
	{$ENDIF}
{$IFDEF LAZARUS}
	SGMethodLoginToOpenGLLazarus:
		begin
		PSGMethodLazarus(SGMethodLoginToOpenGL)^.POpenGLControl^.SwapBuffers;
		end;
	{$ENDIF}
{$IFDEF GLUT}
	SGMethodLoginToOpenGLGLUT:
		begin
		glutSwapBuffers;
		end;
	{$ENDIF}
{$IFDEF UNIX}
	SGMethodLoginToOpenGLGLX:
		begin
		glXSwapBuffers(SGMethodGLX(SGMethodLoginToOpenGL).dpy, SGMethodGLX(SGMethodLoginToOpenGL).win)
		end;
	{$ENDIF}
else
	begin
	
	end;
end;
end;

function SGContextActive:boolean;
begin
case SGMethodLoginToOpenGLType of
SGMethodLoginToOpenGLUnInstalled:
	begin
	Result:=False;
	end;
{$IFDEF MSWINDOWS}
	SGMethodLoginToOpenGLWinAPI:
		begin
		Result:=PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.Active;
		end;
	{$ENDIF}
{$IFDEF LAZARUS}
	SGMethodLoginToOpenGLLazarus:
		begin
		Result:=PSGMethodLazarus(SGMethodLoginToOpenGL)^.Active;
		end;
	{$ENDIF}
{$IFDEF UNIX}
	SGMethodLoginToOpenGLGLX:
		begin
		Result:=True;
		end;
	{$ENDIF}
else
	begin
	Result:=False;
	end;
end;
end;

{$IFDEF SGDebuging}
	{$NOTE $IFDEF GLUT $IFDEF LAZARUS $IFDEF MSWINDOWS}
	{$ENDIF}

{$IFDEF UNIX}
	constructor SGMethodGLX.Create;
	begin
	inherited;
	dpy := nil; //Дисплей
	glXCont:=nil; //Context
	win:=0;//Window
	end;
	
	procedure SGInitOpenGLGLXMethod(const Fullscreen:boolean = False; const Name:PChar = 'SG OpenGL Window'; Width:longint = -1; Height:longint = -1);
	var
	  errorBase,eventBase: integer;
	  window_title_property: TXTextProperty;
	  attr: Array[0..8] of integer = (GLX_RGBA,GLX_RED_SIZE,1,GLX_GREEN_SIZE,1,GLX_BLUE_SIZE,1,GLX_DOUBLEBUFFER,none);
	begin
	initGlx;
	SGMethodLoginToOpenGLType:=SGMethodLoginToOpenGlUnix;
	SGMethodLoginToOpenGL:=SGMethodGLX.Create;
	with SGMethodGLX(SGMethodLoginToOpenGL) do
		begin
		dpy := XOpenDisplay(nil);
		
		if Width=-1 then
			Width:=SGGetDeviceCaps.x;
		if Height=-1 then
			Height:=SGGetDeviceCaps.y;	
		SGGLXSettings.WindowWidth:=Width;
		SGGLXSettings.WindowHeight:=Height;	
		
		if(dpy = nil) then
			writeLn('Error: Could not connect to X server');
		if not (glXQueryExtension(dpy,errorBase,eventBase)) then
			writeLn('Error: GLX extension not supported');
		visinfo := glXChooseVisual(dpy,DefaultScreen(dpy), Attr);
		if(visinfo = nil) then
			writeLn('Error: Could not find visual');
		cm := XCreateColormap(dpy,RootWindow(dpy,visinfo^.screen),visinfo^.visual,AllocNone);
		winAttr.colormap := cm;
		winAttr.border_pixel := 0;
		winAttr.background_pixel := 0;
		winAttr.event_mask := ExposureMask or PointerMotionMask or ButtonPressMask or ButtonReleaseMask or StructureNotifyMask or KeyPressMask or KeyReleaseMask;
		win := XCreateWindow(dpy,RootWindow(dpy,visinfo^.screen),0,0,Width,Height,0,visinfo^.depth,InputOutput,visinfo^.visual,CWBorderPixel or CWColormap or CWEventMask,@winAttr);
		XStringListToTextProperty(@Name,1,@window_title_property);
		XSetWMName(dpy,win,@window_title_property);
		glXCont := glXCreateContext(dpy,visinfo,nil,true);
		if(glXCont = nil) then
			writeLn('Error: Could not create an OpenGL rendering context');
		glXMakeCurrent(dpy,win,glXCont);
		XMapWindow(dpy,win);
		SGInitOpenGL;
		end;
	end;
	 
	{$ENDIF}

{$IFDEF GLUT}
	procedure glutInitPascal(ParseCmdLine: Boolean);
	var
		Cmd: array of PChar;
		CmdCount, I: Integer;
	 begin
	 if ParseCmdLine then
		CmdCount := ParamCount + 1
	else
		CmdCount := 1;
	SetLength(Cmd, CmdCount);
	for I := 0 to CmdCount - 1 do
		Cmd[I] := PChar(ParamStr(I));
	glutInit(@CmdCount, @Cmd);
	 end;
	
	procedure GLUTDrawGLScreen; cdecl;
	begin
	SGPaint;
	end;
	
	procedure GLUTIdle; cdecl;
	begin
	glutPostWindowRedisplay(glutGetWindow());
	end;
	
	procedure GLUTVisible(vis:integer); cdecl;
	begin
	glutIdleFunc(@GLUTIdle);
	end;
	
	procedure GLUTReSizeScreen(Width, Height: Integer); cdecl;
	begin
	if Height = 0 then
		Height := 1;
	SGResizeContext;
	end;
	
	procedure GLUTKeyboard(Key: Byte; X, Y: Longint); cdecl;
	begin
	SGSetKey(char(Key));
	end;
	
	procedure GLUTMouse(Button:integer; State:integer; x,y:integer);cdecl;
	begin
	case Button of
	GLUT_MIDDLE_BUTTON:
		begin
		if State = GLUT_DOWN then
			begin
			SGSetMouseKey(3);
			SGSetMouseKeyDown(3);
			end
		else
			begin
			SGSetMouseKeyUp(3);
			SGSetMouseKey(6);
			end;
		end;
	GLUT_RIGHT_BUTTON:
		begin
		if State = GLUT_DOWN then
			begin
			SGSetMouseKey(2);
			SGSetMouseKeyDown(2);
			end
		else
			begin
			SGSetMouseKey(5);
			SGSetMouseKeyUp(2);
			end;
		end;
	GLUT_LEFT_BUTTON:
		begin
		if State = GLUT_DOWN then
			begin
			SGSetMouseKey(1);
			SGSetMouseKeyDown(1);
			end
		else
			begin
			SGSetMouseKey(4);
			SGSetMouseKeyUp(1);
			end;
		end;
	end;
	end;
	
	procedure GLUTMotionPassive(x,y:longint);cdecl;
	begin
	SGGLUTSettings.CursorPosition.x:=x;
	SGGLUTSettings.CursorPosition.y:=y;
	SGMouseKeysDown[2]:=False;
	SGMouseKeysDown[1]:=False;
	SGMouseKeysDown[0]:=False;
	end;

	procedure GLUTMotion(x,y:longint);cdecl;
	begin
	SGGLUTSettings.CursorPosition.x:=x;
	SGGLUTSettings.CursorPosition.y:=y;
	end;
	
	procedure SGInitOpenGLGLUTMethod(const Fullscreen:boolean = False; const Name:PChar = 'SG OpenGL Window'; Width:longint = -1; Height:longint = -1);
	begin
	SGMethodLoginToOpenGLType:=SGMethodLoginToOpenGLGLUT;
	SGMethodLoginToOpenGL:=Pointer(LongBool(Fullscreen));
	glutInitPascal(True);
	glutInitDisplayMode(GLUT_DOUBLE or GLUT_RGB or GLUT_DEPTH);
	if ((Width=-1) or (Width in [0..1])) then
		Width:=SGGetDeviceCaps.x;
	if ((Height=-1) or (Height in [0..1])) then
		Height:=SGGetDeviceCaps.y;
	if Fullscreen then 
		begin
		glutGameModeString(SGStringToPChar(SGStr(Width)+'x'+SGStr(Height)+':32@60'));
		glutEnterGameMode();
		end
	else 
		begin
		glutInitWindowSize(Width, Height);
		glutInitWindowPosition((SGGetDeviceCaps.x - Width) div 2,(SGGetDeviceCaps.y - Height) div 2);
		glutCreateWindow(Name);
		end;
	glutSetCursor(GLUT_CURSOR_LEFT_ARROW);
	
	glutDisplayFunc(@GLUTDrawGLScreen);
	glutVisibilityFunc(@GLUTVisible);
	glutReshapeFunc(@GLUTReSizeScreen);
	glutKeyboardFunc(@GLUTKeyboard);
	glutMouseFunc(@GLUTMouse);
	glutMotionFunc(@GLUTMotion);
	glutPassiveMotionFunc(@GLUTMotionPassive);
	
	SGInitOpenGL;
	end;
	
	procedure SGInitOpenGLGLUTMethodStartPaint;
	begin
	glutMainLoop;
	end;
	{$ENDIF}
{$IFDEF LAZARUS}
	procedure SGInitOpenGLLazarusMethod(var Form:TForm; var OpenGLControl:TOpenGLControl);
	var
		OL:PSGMethodLazarus;
	begin
	New(Ol);
	SGMethodLoginToOpenGLType:=SGMethodLoginToOpenGLLazarus;
	SGMethodLoginToOpenGL:=OL;
	OL^.POpenGLControl:=@OpenGLControl;
	OL^.PForm:=@Form;
	OL^.POpenGLControl^.MakeCurrent;
	OL^.Active:=True;
	OL^.OpenGL_Init;
	end;
	
	procedure SGMethodLazarus.OpenGL_Init;
	begin
	SGInitMatrixMode(SG_3D);
	SGInitOpenGL;
	end;
	{$ENDIF}

{$IFDEF MSWINDOWS}
	function SGFullscreenQueschionWinAPIMethod:boolean;
	begin
	Result:=MessageBox(0,'Fullscreen Mode?', 'Question!',MB_YESNO OR MB_ICONQUESTION) <> IDNO;
	end;
	
	procedure TSGMethodWinAPI.SwapBuffers;
	begin
	Windows.SwapBuffers(  dcWindow  );
	end;
	
	procedure TSGMethodWinAPI.OpenGL_Init();
	begin
	SGInitMatrixMode(SG_3D);
	SGInitOpenGL;
	end;
	
	procedure TSGMethodWinAPI.Messages;
	begin
	if PeekMessage(@msg,0,0,0,0) = true then 
		begin
		GetMessage(@msg,0,0,0);
		TranslateMessage(msg);
		DispatchMessage(msg);
		end;
	end;
	
	procedure SGInitOpenGLWinAPIMethod( const Fullscreen:boolean = False; const Name:PChar = 'SG OpenGL Window'; Width:longint = -1; Height:longint = -1; const Bits:longint = 32;const IDIcon:longword = 5; const IDCursor:longword = 5);
	var
		PMethod:PTSGMethodWinAPI = nil;
	begin
	if (Width = -1) or (Width in [0..1]) then
		Width:=SGGetDeviceCaps.x;
	if (Height = -1) or (Height in [0..1]) then
		Height:=SGGetDeviceCaps.y;
	SGMethodLoginToOpenGLType:=SGMethodLoginToOpenGLWinAPI;
	New(PMethod);
	SGMethodLoginToOpenGL:=PMethod;
	PMethod^.IDCursor:=IDCursor;
	PMethod^.IDIcon:=IDIcon;
	PMethod^.CreateOGLWindow(Name,Width,Height,Bits,Fullscreen);
	PMethod^.OpenGL_Init
	end;
	
	procedure TSGMethodWinAPI.ThrowError(pcErrorMessage : pChar);
	begin
	MessageBox(0, pcErrorMessage, 'Error', MB_OK);
	Halt(0);
	end;

	function GLWndProc(Window: HWnd; AMessage, WParam, LParam: Longint): Longint; stdcall; export;
	begin 
	GLWndProc := 0;
	case AMessage of
	wm_create:
		begin
		PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.active := true;
		Exit;
		end;
	wm_paint:
		begin
		exit;
		end;
	wm_keydown:
		begin
		SGSetKey(char(WParam));
		SGSetKeyDown(char(WParam));
		end;
	wm_keyup:
		begin
		SGSetKeyUp(char(WParam));
		end;
	wm_mousewheel:
		begin
		if HiWord(WParam)-wheel_delta>0 then
			begin
			SGSetMouseWheel(1)
			end
		else
			SGSetMouseWheel(-1);
		end;
	wm_lbuttondown:
		begin
		SGSetMouseKey(1);
		SGSetMouseKeyDown(1);
		end;
	wm_rbuttondown:
		begin
		SGSetMouseKey(2);
		SGSetMouseKeyDown(2);
		end;
	wm_mbuttondown:
		begin
		SGSetMouseKey(3);
		SGSetMouseKeyDown(3);
		end;
	wm_lbuttonup:
		begin
		SGSetMouseKeyUp(1);
		SGSetMouseKey(4);
		end;
	wm_rbuttonup:
		begin
		SGSetMouseKeyUp(2);
		SGSetMouseKey(5);
		end;
	wm_mbuttonup:
		begin
		SGSetMouseKeyUp(3);
		SGSetMouseKey(6);
		end;
	wm_destroy:
		begin
		PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.active := false;
		PostQuitMessage(0);
		Exit;
		end;
	wm_syscommand:
		begin
		case (wParam) of
		SC_SCREENSAVE : begin
			GLWndProc := 0;
			end;
		SC_MONITORPOWER : begin
			GLWndProc := 0;
			end;
			end;
		end;
	end;
	GLWndProc := DefWindowProc(Window, AMessage, WParam, LParam);
	end;
	
	function TSGMethodWinAPI.WindowRegister: Boolean;
	var
	  WindowClass: WndClass;
	begin
	  WindowClass.Style := cs_hRedraw and cs_vRedraw;
	  WindowClass.lpfnWndProc := WndProc(@GLWndProc);
	  WindowClass.cbClsExtra := 0;
	  WindowClass.cbWndExtra := 0;
	  WindowClass.hInstance :=system.MainInstance;;
	  //WindowClass.hIcon := LoadIcon(0, idi_Application);
	  WindowClass.hIcon := LoadIcon(GetModuleHandle(nil),PCHAR(IDIcon));
	  //WindowClass.hCursor := LoadCursor(0, idc_Arrow);
	  WindowClass.hCursor := LoadCursor(GetModuleHandle(nil),PCHAR(IDCursor));
	  WindowClass.hbrBackground := GetStockObject(WHITE_BRUSH);
	  WindowClass.lpszMenuName := nil;
	  WindowClass.lpszClassName := 'GLWindow';
	  WindowRegister := RegisterClass(WindowClass) <> 0;
	end;

	function TSGMethodWinAPI.WindowCreate(pcApplicationName : pChar): HWnd;
	var
	  hWindow2: HWnd;
	  dmScreenSettings : DEVMODE;
	begin
	if fullscreen = false then 
		begin	
		hWindow2 := CreateWindow('GLWindow',
				  pcApplicationName,
				  WS_CAPTION OR WS_POPUPWINDOW OR WS_VISIBLE OR WS_CLIPSIBLINGS OR WS_CLIPCHILDREN,
				  cw_UseDefault,
				  cw_UseDefault,
				  width,
				  height,
				  0, 0,
				  system.MainInstance,
				  nil);
		end 
	else 
		begin
		dmScreenSettings.dmSize := sizeof(dmScreenSettings);
		dmScreenSettings.dmPelsWidth := width;
		dmScreenSettings.dmPelsHeight := height;
		dmScreenSettings.dmBitsPerPel := bits;
		dmScreenSettings.dmFields := DM_BITSPERPEL OR DM_PELSWIDTH OR DM_PELSHEIGHT;
		if ChangeDisplaySettings(@dmScreenSettings,CDS_FULLSCREEN) <> DISP_CHANGE_SUCCESSFUL then 
			begin
			ThrowError('Screen resolution is not supported by your gfx card!');
			WindowCreate := 0;
			Exit;
			end;
		hWindow2 := CreateWindowEx(WS_EX_APPWINDOW,
			'GLWindow',
			pcApplicationName,
			WS_POPUP OR WS_VISIBLE OR WS_CLIPSIBLINGS OR WS_CLIPCHILDREN,
			0, 0,
			width,
			height,
			0, 0,
			system.MainInstance,
			nil );
		ShowCursor(true);
		end;
	if hWindow2 <> 0 then 
		begin
		ShowWindow(hWindow2, CmdShow);
		UpdateWindow(hWindow2);
		end;
	WindowCreate := hWindow2;
	end;

	function TSGMethodWinAPI.WindowInit(hParent : HWnd): Boolean;
	var
		FunctionError : integer;
		pfd : PIXELFORMATDESCRIPTOR;
		iFormat : integer;
	begin
	 FunctionError := 0;
	dcWindow := GetDC( hParent );
	FillChar(pfd, sizeof(pfd), 0);
	pfd.nSize         := sizeof(pfd);
	pfd.nVersion      := 1;
	pfd.dwFlags       := PFD_SUPPORT_OPENGL OR PFD_DRAW_TO_WINDOW OR PFD_DOUBLEBUFFER;
	pfd.iPixelType    := PFD_TYPE_RGBA;
	pfd.cColorBits    := bits;
	pfd.cDepthBits    := 16;
	pfd.iLayerType    := PFD_MAIN_PLANE;
	iFormat := ChoosePixelFormat( dcWindow, @pfd );
	if (iFormat = 0) then FunctionError := 1;
	SetPixelFormat( dcWindow, iFormat, @pfd );
	rcWindow := wglCreateContext( dcWindow );
	if (rcWindow = 0) then FunctionError := 2;
	wglMakeCurrent( dcWindow, rcWindow );
	if FunctionError = 0 then WindowInit := true else WindowInit := false;
	end;

	function TSGMethodWinAPI.CreateOGLWindow(pcApplicationName : pChar; iApplicationWidth, iApplicationHeight, iApplicationBits : longint; bApplicationFullscreen : boolean):Boolean;
	begin
	width := iApplicationWidth;
	height := iApplicationHeight;
	bits := iApplicationBits;
	fullscreen := bApplicationFullscreen;
	if not WindowRegister then begin
		ThrowError('Could not register the Application Window!');
		WriteLn('Could not register the Application Window!');
		CreateOGLWindow := false;
		Exit;
		end;
	hWindow := WindowCreate(pcApplicationName);
	if longint(hWindow) = 0 then begin
		ThrowError('Could not create Application Window!');
		WriteLn('Could not create Application Window!');
		CreateOGLWindow := false;
		Exit;
		end;
	if not WindowInit(hWindow) then begin
		ThrowError('Could not initialise Application Window!');
		WriteLn('Could not initialise Application Window!');
		CreateOGLWindow := false;
		Exit;
		end;
	CreateOGLWindow := true;
	end;

	procedure TSGMethodWinAPI.KillOGLWindow();
	begin
	wglMakeCurrent( dcWindow, 0 );
	wglDeleteContext( rcWindow );
	ReleaseDC( hWindow, dcWindow );
	DestroyWindow( hWindow );
	end;

	{$ENDIF}

initialization

begin
Nan:=sqrt(-1);
Inf:=1/0;
RandomIze;
end;

end.