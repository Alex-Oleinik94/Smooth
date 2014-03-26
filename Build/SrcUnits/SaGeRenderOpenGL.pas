{$INCLUDE Includes\SaGe.inc}
unit SaGeRenderOpenGL;
interface
uses
	SaGeBase
	,SaGeBased
	,SaGeRender
	,SaGeCommon
	,Math
	{$IFNDEF MOBILE}
		,gl
		,glu
		,glext
	{$ELSE}
		,gles
		,egl
		,android_native_app_glue
		{$ENDIF}
	{$IFDEF MSWINDOWS}
		,windows
		{$ENDIF}
	{$IFDEF UNIX}
		,Dl
		,unix
		{$ENDIF}
	{$IFDEF ANDROID}
		{$ENDIF}
	{$IFDEF LINUX}
		,glx
		,x
		,xlib
		,xutil
		{$ENDIF}
	{$IFDEF DARWIN}
		,AGL
		,MacOSAll
		{$ENDIF}
	,DynLibs
	;
type
	TSGRenderOpenGL=class(TSGRender)
			public
		constructor Create;override;
		destructor Destroy;override;
			protected
		FContext:
		{$IFDEF LINUX}
			GLXContext
		{$ELSE}
			{$IFDEF MSWINDOWS}
				HGLRC
			{$ELSE}
				{$IFDEF ANDROID}
					EGLContext
				{$ELSE}
					{$IFDEF DARWIN}
						TAGLContext
					{$ELSE}
						Pointer
						{$ENDIF}
					{$ENDIF}
				{$ENDIF}
			 {$ENDIF};
		{$IFDEF DARWIN}
			ogl_Format  : TAGLPixelFormat;
			{$ENDIF}
			public
		{$DEFINE SG_RENDER_EIC}
		{$INCLUDE Includes\SaGeRenderOpenGLLoadExtendeds.inc}
		{$UNDEF SG_RENDER_EIC}
			public
		function SetPixelFormat():Boolean;override;overload;
		function CreateContext():Boolean;override;
		function MakeCurrent():Boolean;override;
		procedure ReleaseCurrent();override;
		procedure Init();override;
		procedure LoadExtendeds();
		procedure Viewport(const a,b,c,d:LongWord);override;
		procedure SwapBuffers();override;
		function TopShift(const VFullscreen:Boolean = False):LongWord;override;
		procedure MouseShift(var x,y:LongInt;const VFullscreen:Boolean = False);override;
		function SupporedVBOBuffers:Boolean;override;
			public
		procedure InitOrtho2d(const x0,y0,x1,y1:TSGSingle);override;
		procedure InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht:Real = 1);override;
		procedure LoadIdentity();override;
		procedure Vertex3f(const x,y,z:single);override;
		procedure BeginScene(const VPrimitiveType:TSGPrimtiveType);override;
		procedure EndScene();override;
		
		procedure Color3f(const r,g,b:single);override;
		procedure TexCoord2f(const x,y:single);override;
		procedure Vertex2f(const x,y:single);override;
		procedure Color4f(const r,g,b,a:single);override;
		procedure Normal3f(const x,y,z:single);override;
		procedure Translatef(const x,y,z:single);override;
		procedure Rotatef(const angle:single;const x,y,z:single);override;
		procedure Enable(VParam:Cardinal);override;
		procedure Disable(const VParam:Cardinal);override;
		procedure DeleteTextures(const VQuantity:Cardinal;const VTextures:PSGUInt);override;
		procedure Lightfv(const VLight,VParam:Cardinal;const VParam2:Pointer);override;
		procedure GenTextures(const VQuantity:Cardinal;const VTextures:PSGUInt);override;
		procedure BindTexture(const VParam:Cardinal;const VTexture:Cardinal);override;
		procedure TexParameteri(const VP1,VP2,VP3:Cardinal);override;
		procedure PixelStorei(const VParamName:Cardinal;const VParam:SGInt);override;
		procedure TexEnvi(const VP1,VP2,VP3:Cardinal);override;
		procedure TexImage2D(const VTextureType:Cardinal;const VP1:TSGCardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;var VBitMap:Pointer);override;
		procedure ReadPixels(const x,y:Integer;const Vwidth,Vheight:TSGInteger;const format, atype: TSGCardinal;const pixels: Pointer);override;
		procedure CullFace(const VParam:Cardinal);override;
		procedure EnableClientState(const VParam:TSGCardinal);override;
		procedure DisableClientState(const VParam:TSGCardinal);override;
		procedure GenBuffersARB(const VQ:TSGInteger;const PT:PCardinal);override;
		procedure DeleteBuffersARB(const VQuantity:LongWord;VPoint:TSGPointer);override;
		procedure BindBufferARB(const VParam:TSGCardinal;const VParam2:TSGCardinal);override;
		procedure BufferDataARB(const VParam:TSGCardinal;const VSize:TSGInt64;VBuffer:Pointer;const VParam2:Cardinal);override;
		procedure DrawElements(const VParam:TSGCardinal;const VSize:TSGInt64;const VParam2:Cardinal;VBuffer:Pointer);override;
		procedure ColorPointer(const VQChannels:TSGLongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);override;
		procedure TexCoordPointer(const VQChannels:TSGLongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);override;
		procedure NormalPointer(const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);override;
		procedure VertexPointer(const VQChannels:TSGLongWord;const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);override;
		function IsEnabled(const VParam:TSGCardinal):TSGBoolean;override;
		procedure Clear(const VParam:TSGCardinal);override;
		procedure LineWidth(const VLW:TSGSingle);override;
		procedure PointSize(const PS:TSGSingle);override;
		procedure PushMatrix();override;
		procedure PopMatrix();override;
		end;

//Я так понял, что на нормальном компьютере все матрици хранятся в Double, 
//	а в GL ES (На мобтльных устройствах) во Float.
//И если эти функции понадобятся не в GL ES, то нужно передефайнить тип элементов матрици.
type
	SGRGLMatrix4Type = {$IFDEF MOBILE} TSGSingle {$ELSE} TSGReal {$ENDIF};
type
	SGRGLMatrix4=array [0..3,0..3] of SGRGLMatrix4Type;

(*Эти функциии для того, чтобы определять gluLookAt и gluPerspective на мобильных платформах типа Android или iOS*)
function SGRGLMatrix4Import(const _0x0,_0x1,_0x2,_0x3,_1x0,_1x1,_1x2,_1x3,_2x0,_2x1,_2x2,_2x3,_3x0,_3x1,_3x2,_3x3:SGRGLMatrix4Type):SGRGLMatrix4;inline;
function SGRGLGetFrustumMatrix(const vleft,vright,vbottom,vtop,vnear,vfar:SGRGLMatrix4Type):SGRGLMatrix4;inline;
function SGRGLGetPerspectiveMatrix(const vAngle,vAspectRatio,vNear,vFar:SGRGLMatrix4Type):SGRGLMatrix4;inline;
function SGRGLGetLookAtMatrix(const Eve, At:TSGVertex3f;Up:TSGVertex3f):SGRGLMatrix4;inline;

//Эта функция позволяет задавать текущую (В зависимости от выбранной матрици процедурой glMatrixMode) матрицу 
//в соответствии с типом SGRGLMatrix4.
procedure SGRSetMatrix( vMatrix:SGRGLMatrix4);inline;

//Это функция - собственная замена gluPerspective в движке.
procedure SGRGLPerspective(const vAngle,vAspectRatio,vNear,vFar:SGRGLMatrix4Type);inline;

//Перемножение матриц (нужно для Rotate, Translate и Scale)
//Так же нужно для LookAt так как там нужно делать Translate.
operator * (A,B:SGRGLMatrix4):SGRGLMatrix4;overload;inline;

//Эта функция - собственная замена gluLookAt в движке.
procedure SGRGLLookAt(const Eve,At,Up:TSGVertex3f);inline;

implementation

procedure TSGRenderOpenGL.PushMatrix();
begin
glPushMatrix();
end;

procedure TSGRenderOpenGL.PopMatrix();
begin
glPopMatrix();
end;

procedure SGRGLLookAt(const Eve,At,Up:TSGVertex3f);inline;
begin
glMatrixMode(GL_PROJECTION);
SGRSetMatrix(SGRGLGetLookAtMatrix(Eve,At,Up));
end;

operator * (A,B:SGRGLMatrix4):SGRGLMatrix4;overload;inline;
var
	i,j,k:Word;
begin
FillChar(Result,Sizeof(Result),0);
for i:=0 to 3 do
	for j:=0 to 3 do
		for k:=0 to 3 do
			Result[i,j]+=A[i,k]*B[k,j];
end;

procedure SGRGLPerspective(const vAngle,vAspectRatio,vNear,vFar:SGRGLMatrix4Type);inline;
begin
glMatrixMode(GL_PROJECTION);
SGRSetMatrix(SGRGLGetPerspectiveMatrix(vAngle,vAspectRatio,vNear,vFar));
end;

procedure SGRSetMatrix( vMatrix:SGRGLMatrix4);inline;
begin
//Это потому что glLoadMatrixd нету в GL ES, и поэтому я думаю, что в GL ES все хранится во Float.
{$IFDEF MOBILE}glLoadMatrixf{$ELSE}glLoadMatrixd{$ENDIF}(@vMatrix);
end;

function SGRGLMatrix4Import(const _0x0,_0x1,_0x2,_0x3,_1x0,_1x1,_1x2,_1x3,_2x0,_2x1,_2x2,_2x3,_3x0,_3x1,_3x2,_3x3:SGRGLMatrix4Type):SGRGLMatrix4;inline;
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

function SGRGLGetFrustumMatrix(const vleft,vright,vbottom,vtop,vnear,vfar:SGRGLMatrix4Type):SGRGLMatrix4;inline;
begin
Result:=SGRGLMatrix4Import(
	2.0 * vnear / (vright - vleft), 0, 0, 0,
	0, 2.0 * vnear / (vtop - vbottom), 0, 0,
	(vright + vleft) / (vright - vleft), (vtop + vbottom) / (vtop - vbottom), -(vfar + vnear) / (vfar - vnear), -1.0,
	0,0, -2.0 * vfar * vnear / (vfar - vnear), 0);
end;

function SGRGLGetPerspectiveMatrix(const vAngle,vAspectRatio,vNear,vFar:SGRGLMatrix4Type):SGRGLMatrix4;inline;
var
	vTop:Single;
begin
vTop := vNear * Math.tan(vAngle * 3.1415927 / 360.0);
Result:=SGRGLGetFrustumMatrix(
	(-vTop)*vAspectRatio,vTop*vAspectRatio,-vTop,vTop,vNear,vFar);
end;

function SGRGLGetLookAtMatrix(const Eve, At:TSGVertex3f;Up:TSGVertex3f):SGRGLMatrix4;inline;
var
	vForward,vSide:TSGVertex3f;
begin
vForward := At - Eve;
vForward.Normalize();
vSide := vForward * Up;
vSide.Normalize();
Up := vSide * vForward;
Result := SGRGLMatrix4Import(
	vside.x, up.x, -vforward.x, 0,
	vside.y, up.y, -vforward.y, 0,
	vside.z, up.z, -vforward.z, 0,
	0, 0, 0, 1);
Result *= SGRGLMatrix4Import(
	1,0,0,-Eve.x,
	0,1,0,-Eve.y,
	0,0,1,-Eve.z,
	0,0,0,1);
end;

procedure TSGRenderOpenGL.MouseShift(var x,y:LongInt;const VFullscreen:Boolean = False);
begin
x:=0;
y:=0;
{$IFDEF MSWINDOWS}
	x:=-7*Byte(not VFullscreen);
	y:=5*Byte(not VFullscreen);
{$ELSE}
	{$IFDEF LINUX}
		{$ENDIF}
	{$ENDIF}
end;

function TSGRenderOpenGL.TopShift(const VFullscreen:Boolean = False):LongWord;
begin
Result:=0;
{$IFDEF MSWINDOWS}
	Result:=28*Byte(not VFullscreen);
{$ELSE}
	{$IFDEF LINUX}
		{$ENDIF}
	{$ENDIF}
end;

procedure TSGRenderOpenGL.SwapBuffers();
begin
{$IFDEF MSWINDOWS}
	Windows.SwapBuffers( LongWord(FWindow.Get('DESKTOP WINDOW HANDLE')) );
{$ELSE}
	{$IFDEF LINUX}
		glXSwapBuffers(
			PDisplay(FWindow.Get('DESKTOP WINDOW HANDLE')),
			LongWord(FWindow.Get('WINDOW HANDLE')));
	{$ELSE}
		{$IFDEF ANDROID}
			(*Already exists in SaGeContextAndroid*)
		{$ELSE}
			{$IFDEF DARWIN}
				aglSwapBuffers( FContext );
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
	{$ENDIF}
end;

function TSGRenderOpenGL.SupporedVBOBuffers:Boolean;
begin
Result:=SGIsSuppored_GL_ARB_vertex_buffer_object;
end;

procedure TSGRenderOpenGL.PointSize(const PS:Single);
begin
glPointSize(PS);
end;

procedure TSGRenderOpenGL.LineWidth(const VLW:Single);
begin
glLineWidth(VLW);
end;

procedure TSGRenderOpenGL.Color3f(const r,g,b:single);
begin
{$IFNDEF MOBILE}
	if IsEnabled(GL_BLEND) then
		glColor4f(r,g,b,1)
	else
		glColor3f(r,g,b);
{$ELSE}
	glColor4f(r,g,b,1)
	{$ENDIF}
end;

procedure TSGRenderOpenGL.TexCoord2f(const x,y:single); 
begin 
{$IFNDEF MOBILE}
	glTexCoord2f(x,y);
{$ELSE}
	//glTexCoord3f(x,y,0);
	//glTexCoord2f(x,y);
	//Ничего не хочет делаться на этом Gl ES... 
	{$ENDIF}
end;

procedure TSGRenderOpenGL.Vertex2f(const x,y:single); 
begin
{$IFNDEF MOBILE}
	glVertex2f(x,y);
{$ELSE}
	//glVertex3f(x,y,0);
	//glVertex2f(x,y);
	//Нифига...
	{$ENDIF}
end;

procedure TSGRenderOpenGL.Color4f(const r,g,b,a:single); 
begin 
glColor4f(r,g,b,a);
end;

procedure TSGRenderOpenGL.Normal3f(const x,y,z:single); 
begin 
glNormal3f(x,y,z);
end;

procedure TSGRenderOpenGL.Translatef(const x,y,z:single); 
begin 
glTranslatef(x,y,z);
end;

procedure TSGRenderOpenGL.Rotatef(const angle:single;const x,y,z:single); 
begin 
glRotatef(angle,x,y,z);
end;

procedure TSGRenderOpenGL.Enable(VParam:Cardinal); 
begin
glEnable(VParam);
end;

procedure TSGRenderOpenGL.Disable(const VParam:Cardinal); 
begin 
glDisable(VParam);
end;

procedure TSGRenderOpenGL.DeleteTextures(const VQuantity:Cardinal;const VTextures:PSGUInt); 
begin 
glDeleteTextures(VQuantity,VTextures);
end;

procedure TSGRenderOpenGL.Lightfv(const VLight,VParam:Cardinal;const VParam2:Pointer); 
begin 
glLightfv(VLight,VParam,VParam2);
end;

procedure TSGRenderOpenGL.GenTextures(const VQuantity:Cardinal;const VTextures:PSGUInt); 
begin 
glGenTextures(VQuantity,VTextures);
end;

procedure TSGRenderOpenGL.BindTexture(const VParam:Cardinal;const VTexture:Cardinal); 
begin 
glBindTexture(VParam,VTexture);
end;

procedure TSGRenderOpenGL.TexParameteri(const VP1,VP2,VP3:Cardinal); 
begin 
glTexParameteri(VP1,VP2,VP3);
end;

procedure TSGRenderOpenGL.PixelStorei(const VParamName:Cardinal;const VParam:SGInt); 
begin 
glPixelStorei(VParamName,VParam);
end;

procedure TSGRenderOpenGL.TexEnvi(const VP1,VP2,VP3:Cardinal); 
begin 
glTexEnvi(VP1,VP2,VP3);
end;

procedure TSGRenderOpenGL.TexImage2D(const VTextureType:Cardinal;const VP1:Cardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;var VBitMap:Pointer); 
begin 
glTexImage2D(VTextureType,VP1,VChannels,VWidth,VHeight,VP2,VFormatType,VDataType,VBitMap);
end;

procedure TSGRenderOpenGL.ReadPixels(const x,y:Integer;const Vwidth,Vheight:Integer;const format, atype: Cardinal;const pixels: Pointer); 
begin 
glReadPixels(x,y,Vwidth,Vheight,format, atype,pixels);
end;

procedure TSGRenderOpenGL.CullFace(const VParam:Cardinal); 
begin 
glCullFace(VParam);
end;

procedure TSGRenderOpenGL.EnableClientState(const VParam:Cardinal); 
begin 
glEnableClientState(VParam);
end;

procedure TSGRenderOpenGL.DisableClientState(const VParam:Cardinal); 
begin 
glDisableClientState(VParam);
end;

procedure TSGRenderOpenGL.GenBuffersARB(const VQ:Integer;const PT:PCardinal); 
begin 
{$IFNDEF MOBILE}glGenBuffersARB{$ELSE}glGenBuffers{$ENDIF}(VQ,PT);
end;

procedure TSGRenderOpenGL.DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer); 
begin 
{$IFNDEF MOBILE}glDeleteBuffersARB{$ELSE}glDeleteBuffers{$ENDIF}(VQuantity,VPoint);
end;

procedure TSGRenderOpenGL.BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal); 
begin 
{$IFNDEF MOBILE}glBindBufferARB{$ELSE}glBindBuffer{$ENDIF}(VParam,VParam2);
end;

procedure TSGRenderOpenGL.BufferDataARB(const VParam:Cardinal;const VSize:int64;VBuffer:Pointer;const VParam2:Cardinal); 
begin 
{$IFNDEF MOBILE}glBufferDataARB{$ELSE}glBufferData{$ENDIF}(VParam,VSize,VBuffer,VParam2);
end;

procedure TSGRenderOpenGL.DrawElements(const VParam:TSGCardinal;const VSize:TSGInt64;const VParam2:Cardinal;VBuffer:Pointer); 
begin 
glDrawElements(VParam,VSize,VParam2,VBuffer);
end;

procedure TSGRenderOpenGL.ColorPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 
glColorPointer(VQChannels,VType,VSize,VBuffer);
end;

procedure TSGRenderOpenGL.TexCoordPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 
glTexCoordPointer(VQChannels,VType,VSize,VBuffer);
end;

procedure TSGRenderOpenGL.NormalPointer(const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 
glNormalPointer(VType,VSize,VBuffer);
end;

procedure TSGRenderOpenGL.VertexPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer); 
begin 
glVertexPointer(VQChannels,VType,VSize,VBuffer);
end;

function TSGRenderOpenGL.IsEnabled(const VParam:Cardinal):Boolean; 
begin 
glIsEnabled(VParam);
end;

procedure TSGRenderOpenGL.Clear(const VParam:Cardinal); 
begin 
glClear(VParam);
end;

{$DEFINE SG_RENDER_EP}
{$INCLUDE Includes\SaGeRenderOpenGLLoadExtendeds.inc}
{$UNDEF SG_RENDER_EP}

procedure TSGRenderOpenGL.BeginScene(const VPrimitiveType:TSGPrimtiveType);
begin
{$IFNDEF MOBILE}
	glBegin(VPrimitiveType);
{$ELSE}
	//хз
	{$ENDIF}
end;

procedure TSGRenderOpenGL.EndScene();
begin
{$IFNDEF MOBILE}
	glEnd();
{$ELSE}
	//хз
	{$ENDIF}
end;

procedure TSGRenderOpenGL.Init();
var
	AmbientLight : array[0..3] of glFloat = (0.5,0.5,0.5,1.0);
	DiffuseLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
	SpecularLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
	SpecularReflection : array[0..3] of glFloat = (0.4,0.4,0.4,1.0);
	LightPosition : array[0..3] of glFloat = (0,1,0,2);
	fogColor:array[0..3] of glFloat = (0,0,0,1);
begin
{$IFDEF MOBILE}
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
	{$ENDIF}

glEnable(GL_FOG);
{$IFNDEF MOBILE} 
	glFogi(GL_FOG_MODE, GL_LINEAR);
{$ELSE} 
	{хз} 
	{$ENDIF}
glHint (GL_FOG_HINT, GL_NICEST);
//glHint(GL_FOG_HINT, GL_DONT_CARE);
glFogf (GL_FOG_START, 300);
glFogf (GL_FOG_END, 400);
glFogfv(GL_FOG_COLOR, @fogColor);
glFogf(GL_FOG_DENSITY, 0.55);

glClearColor(0,0,0,0);
glEnable(GL_DEPTH_TEST);
{$IFNDEF MOBILE}glClearDepth{$ELSE}glClearDepthf{$ENDIF}(1.0);
glDepthFunc(GL_LEQUAL);

glEnable(GL_LINE_SMOOTH);
{$IFNDEF MOBILE}
	glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
{$ELSE} 
	{хз} 
	{$ENDIF}
glLineWidth (1.0);

glShadeModel(GL_SMOOTH);
glEnable(GL_TEXTURE_2D);
glEnable(GL_TEXTURE);
glEnable (GL_BLEND);
glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA) ;
glEnable (GL_LINE_SMOOTH);
//glEnable (GL_POLYGON_SMOOTH);

glEnable(GL_LIGHTING);
glLightfv(GL_LIGHT0,GL_AMBIENT, @AmbientLight);
glLightfv(GL_LIGHT0,GL_DIFFUSE, @DiffuseLight);
glLightfv(GL_LIGHT0,GL_SPECULAR, @SpecularLight);
glEnable(GL_LIGHT0);
glLightfv(GL_LIGHT0,GL_POSITION,@LightPosition);
glDisable(GL_LIGHT0);

glEnable(GL_COLOR_MATERIAL);
{$IFNDEF MOBILE}
	glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
{$ELSE}
	{хз} 
	{$ENDIF}
glMaterialfv(GL_FRONT, GL_SPECULAR, @SpecularReflection);
{$IFNDEF MOBILE}
	glMateriali(GL_FRONT,GL_SHININESS,100);
{$ELSE} 
	{хз} 
	{$ENDIF}

glDisable(GL_LIGHTING);

LoadExtendeds();
end;

constructor TSGRenderOpenGL.Create();
begin
inherited Create();
FType:=SGRenderOpenGL;
{$IF defined(LINUX) or defined(ANDROID)}
	FContext:=nil;
{$ELSE}
	{$IFDEF MSWINDOWS}
		FContext:=0;
		{$ENDIF}
	{$ENDIF}
{$DEFINE SG_RENDER_EICR}
{$INCLUDE Includes\SaGeRenderOpenGLLoadExtendeds.inc}
{$UNDEF SG_RENDER_EICR}
end;

destructor TSGRenderOpenGL.Destroy;
begin
{$IFDEF LINUX}
	
{$ELSE}
	{$IFDEF MSWINDOWS}
		wglMakeCurrent( LongWord(FWindow.Get('DESKTOP WINDOW HANDLE')), 0 );
		if FContext<>0 then
			begin
			wglDeleteContext( FContext );
			CloseHandle(FContext);
			FContext:=0;
			end;
	{$ELSE}
		{$IFDEF ANDROID}
			if (FContext <> EGL_NO_CONTEXT) then
				eglDestroyContext(FWindow.Get('DESKTOP WINDOW HANDLE'), FContext);
		{$ELSE}
			{$IFDEF DARWIN}
				aglSetCurrentContext( nil );
				aglDestroyContext( FContext );
				FillChar(FContext,Sizeof(FContext),0);
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
	{$ENDIF}
inherited;
end;

procedure TSGRenderOpenGL.InitOrtho2d(const x0,y0,x1,y1:TSGSingle);
begin
glMatrixMode(GL_PROJECTION);
LoadIdentity();
{$IFNDEF MOBILE}glOrtho{$ELSE}glOrthof{$ENDIF}(x0,x1,y0,y1,0,0.1); 
glMatrixMode(GL_MODELVIEW);
LoadIdentity();
end;

procedure TSGRenderOpenGL.InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht:Real = 1);
const
	glub = 500;
var
	CWidth,CHeight:LongWord;
begin
CWidth:=LongWord(FWindow.Get('WIDTH'));
CHeight:=LongWord(FWindow.Get('HEIGHT'));
Viewport(0, 0, CWidth, CHeight);
glMatrixMode(GL_PROJECTION);
LoadIdentity();
if  Mode=SG_2D then
	begin
	{$IFNDEF MOBILE}glOrtho{$ELSE}glOrthox{$ENDIF}(0,CWidth,CHeight,0,0,1);
	end
else
	if Mode = SG_3D_ORTHO then
		begin
		{$IFNDEF MOBILE}glOrtho{$ELSE}glOrthof{$ENDIF}
			(-(CWidth / (1/dncht*120)),CWidth / (1/dncht*120),-CHeight / (1/dncht*120),(CHeight / (1/dncht*120)),0,500)
		end
	else
		//Впринципе теперь можно всегда пользоваться SGRGLPerspective вместо gluPerspective, но я 
		//Думаю все таки надуюсь, что gluPerspective будет работать чуть чуть быстрее чем моя процедурка.
		{$IFNDEF MOBILE}gluPerspective{$ELSE}SGRGLPerspective{$ENDIF}
			(45, CWidth / CHeight, 0.0011, 500);
glMatrixMode(GL_MODELVIEW);
LoadIdentity();
end;

procedure TSGRenderOpenGL.Viewport(const a,b,c,d:LongWord);
begin
glViewport(a,b,c,d);
end;

procedure TSGRenderOpenGL.LoadIdentity();
begin
glLoadIdentity();
end;

procedure TSGRenderOpenGL.Vertex3f(const x,y,z:single);
begin
{$IFNDEF MOBILE}
	glVertex3f(x,y,z);
{$ELSE} 
	{хз} 
	{$ENDIF}
end;

function TSGRenderOpenGL.CreateContext():Boolean;
begin
Result:=False;
{$IFDEF LINUX}
	initGlx();
	FContext := glXCreateContext(
		PDisplay(FWindow.Get('DESKTOP WINDOW HANDLE')),
		PXVisualInfo(FWindow.Get('VISUAL INFO')),nil,true);
	if FContext = nil then
		begin
		SGLog.Sourse('TSGContextUnix__CreateWindow : Error : Could not create an OpenGL rendering context!');
		Exit;
		end;
	Result:=FContext<>nil;
{$ELSE}
	{$IFDEF MSWINDOWS}
		if SetPixelFormat() then
			FContext := wglCreateContext( LongWord(FWindow.Get('DESKTOP WINDOW HANDLE')) );
		Result:=FContext<>0;
	{$ELSE}
		{$IFDEF ANDROID}
			FContext := eglCreateContext(FWindow.Get('DESKTOP WINDOW HANDLE'), FWindow.Get('VISUAL INFO'), nil, nil);
			SGLog.Sourse('"TSGRenderOpenGL.CreateContext" : Called "eglCreateContext". Result="'+SGStr(TSGMaxEnum(FContext))+'"');
		{$ELSE}
			{$IFDEF DARWIN}
				FContext := aglCreateContext( ogl_Format, nil );
				Result:= Assigned( FContext );
				if Result then
					begin
					if aglSetDrawable( FContext, WindowRef(FWindow.Get('DESKTOP WINDOW HANDLE'))) <> GL_FALSE Then
						begin
						if aglSetCurrentContext( FContext ) <> GL_FALSE Then
							begin
							aglDestroyPixelFormat( ogl_Format );
							FillChar(ogl_Format,Sizeof(ogl_Format),0);
							Result:=True;
							end;
						end;
					end;
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
	{$ENDIF}
if Result then
	Result:=MakeCurrent();
end;

procedure TSGRenderOpenGL.ReleaseCurrent();
begin
{$IFDEF LINUX}
	if (FWindow<>nil) and (FContext<>nil) then 
		glXMakeCurrent(
			PDisplay(FWindow.Get('DESKTOP WINDOW HANDLE')),
			LongWord(FWindow.Get('WINDOW HANDLE')),
			nil);
{$ELSE}
	{$IFDEF MSWINDOWS}
		if (FWindow<>nil)  then 
			wglMakeCurrent( LongWord(FWindow.Get('DESKTOP WINDOW HANDLE')), 0 );
	{$ELSE}
		{$IFDEF ANDROID}
			if FWindow<>nil then
				eglMakeCurrent(FWindow.Get('DESKTOP WINDOW HANDLE'), EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
		{$ELSE}
			{$IFDEF DARWIN}
				aglSetDrawable( nil, FWindow.Get('DESKTOP WINDOW HANDLE'));
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
	{$ENDIF}
end;

function TSGRenderOpenGL.SetPixelFormat():Boolean;overload;
{$IFDEF MSWINDOWS}
	var
		pfd : PIXELFORMATDESCRIPTOR;
		iFormat : integer;
	{$ENDIF}
{$IFDEF DARWIN}
	var
		ogl_Attr    : array[ 0..31 ] of DWORD;
	{$ENDIF}
begin
Result:=False;
{$IFDEF DARWIN}
	ogl_Attr[ 0 ] := AGL_RGBA;
	ogl_Attr[ 1 ] := AGL_DOUBLEBUFFER;
	ogl_Attr[ 2 ] := AGL_DEPTH_SIZE;
	ogl_Attr[ 3 ] := 24;
	ogl_Attr[ 6 ] := AGL_NONE;
	ogl_Format := aglChoosePixelFormat( nil, 0, @ogl_Attr[ 0 ] );
	Result:=Assigned( ogl_Format );
	{$ENDIF}
{$IFDEF MSWINDOWS}
	FillChar(pfd, sizeof(pfd), 0);
	pfd.nSize         := sizeof(pfd);
	pfd.nVersion      := 1;
	pfd.dwFlags       := PFD_SUPPORT_OPENGL OR PFD_DRAW_TO_WINDOW OR PFD_DOUBLEBUFFER;
	pfd.iPixelType    := PFD_TYPE_RGBA;
	pfd.cColorBits    := 32;
	pfd.cDepthBits    := 24;
	pfd.iLayerType    := PFD_MAIN_PLANE;
	iFormat := Windows.ChoosePixelFormat( LongWord(FWindow.Get('DESKTOP WINDOW HANDLE')), @pfd );
	Result:=Windows.SetPixelFormat( LongWord(FWindow.Get('DESKTOP WINDOW HANDLE')), iFormat, @pfd );
	{$ENDIF}
{$IF defined(LINUX) or defined(ANDROID)}
	Result:=True;
	{$ENDIF}
end;

function TSGRenderOpenGL.MakeCurrent():Boolean;
begin
{$IFDEF LINUX}
	if (FWindow<>nil) and (FContext<>nil) then 
		begin
		glXMakeCurrent(
			PDisplay(FWindow.Get('DESKTOP WINDOW HANDLE')),
			LongWord(FWindow.Get('WINDOW HANDLE')),
			FContext);
		Result:=True;
		end
	else
		Result:=False;
{$ELSE}
	{$IFDEF MSWINDOWS}
		if (FWindow<>nil) and (FContext<>0) then 
			begin
			wglMakeCurrent( LongWord(FWindow.Get('DESKTOP WINDOW HANDLE')), FContext );
			Result:=True;
			end
		else
			Result:=False;
	{$ELSE}
		{$IFDEF ANDROID}
			if (FWindow<>nil) and (FContext<>nil) then 
				if eglMakeCurrent(
					FWindow.Get('DESKTOP WINDOW HANDLE'), 
					FWindow.Get('SURFACE'), 
					FWindow.Get('SURFACE'), 
					FContext)  = EGL_FALSE then
					Result:=False
				else
					Result:=True
			else
				Result:=False;
			SGLog.Sourse('"TSGRenderOpenGL.MakeCurrent" : Called "eglMakeCurrent". Result="'+SGStr(Result)+'"');
		{$ELSE}
			{$IFDEF DARWIN}
				Result:=aglSetDrawable( FContext, FWindow.Get('DESKTOP WINDOW HANDLE')) <> GL_FALSE;
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
	{$ENDIF}
end;

end.
