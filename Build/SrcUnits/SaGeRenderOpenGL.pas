{$INCLUDE Includes\SaGe.inc}
unit SaGeRenderOpenGL;
interface
uses
	SaGeBase
	,SaGeBased
	,SaGeRender
	{$IFNDEF ANDROID}
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
					Pointer
					{$ENDIF}
				{$ENDIF}
			 {$ENDIF};
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
		procedure TexImage2D(const VTextureType:Cardinal;const VP1:Cardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;var VBitMap:Pointer);override;
		procedure ReadPixels(const x,y:Integer;const Vwidth,Vheight:Integer;const format, atype: Cardinal;const pixels: Pointer);override;
		procedure CullFace(const VParam:Cardinal);override;
		procedure EnableClientState(const VParam:Cardinal);override;
		procedure DisableClientState(const VParam:Cardinal);override;
		procedure GenBuffersARB(const VQ:Integer;const PT:PCardinal);override;
		procedure DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer);override;
		procedure BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal);override;
		procedure BufferDataARB(const VParam:Cardinal;const VSize:int64;VBuffer:Pointer;const VParam2:Cardinal);override;
		procedure DrawElements(const VParam:Cardinal;const VSize:int64;const VParam2:Cardinal;VBuffer:Pointer);override;
		procedure ColorPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);override;
		procedure TexCoordPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);override;
		procedure NormalPointer(const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);override;
		procedure VertexPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);override;
		function IsEnabled(const VParam:Cardinal):Boolean;override;
		procedure Clear(const VParam:Cardinal);override;
		procedure LineWidth(const VLW:Single);override;
		procedure PointSize(const PS:Single);override;
		end;

implementation

procedure TSGRenderOpenGL.MouseShift(var x,y:LongInt;const VFullscreen:Boolean = False);
begin
{$IFDEF MSWINDOWS}
	x:=-7*Byte(not VFullscreen);
	y:=5*Byte(not VFullscreen);
{$ELSE}
	{$IFDEF LINUX}
		x:=0;
		y:=0;
		{$ENDIF}
	{$ENDIF}
end;

function TSGRenderOpenGL.TopShift(const VFullscreen:Boolean = False):LongWord;
begin
{$IFDEF MSWINDOWS}
	Result:=28*Byte(not VFullscreen);
{$ELSE}
	{$IFDEF LINUX}
		Result:=0;
		{$ENDIF}
	{$ENDIF}
end;

procedure TSGRenderOpenGL.SwapBuffers();
begin
{$IFDEF MSWINDOWS}
	Windows.SwapBuffers( LongWord(FWindow.Get('DESCTOP WINDOW HANDLE')) );
{$ELSE}
	{$IFDEF LINUX}
		glXSwapBuffers(
			PDisplay(FWindow.Get('DESCTOP WINDOW HANDLE')),
			LongWord(FWindow.Get('WINDOW HANDLE')));
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
{$IFNDEF ANDROID}
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
{$IFNDEF ANDROID}
	glTexCoord2f(x,y);
{$ELSE}
	//glTexCoord3f(x,y,0);
	//glTexCoord2f(x,y);
	//Не так не так не хочет... странно, посмотрим потом как сделать..
	{$ENDIF}
end;

procedure TSGRenderOpenGL.Vertex2f(const x,y:single); 
begin
{$IFNDEF ANDROID}
	glVertex2f(x,y);
{$ELSE}
	//glVertex3f(x,y,0);
	//glVertex2f(x,y);
	//нихера...
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
{$IFNDEF ANDROID}
	glGenBuffersARB(VQ,PT);
{$ELSE}
	//їч
	{$ENDIF}
end;

procedure TSGRenderOpenGL.DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer); 
begin 
{$IFNDEF ANDROID}
	glDeleteBuffersARB(VQuantity,VPoint);
{$ELSE}
	//їч
	{$ENDIF}
end;

procedure TSGRenderOpenGL.BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal); 
begin 
{$IFNDEF ANDROID}
	glBindBufferARB(VParam,VParam2);
{$ELSE}
	//їч
	{$ENDIF}
end;

procedure TSGRenderOpenGL.BufferDataARB(const VParam:Cardinal;const VSize:int64;VBuffer:Pointer;const VParam2:Cardinal); 
begin 
{$IFNDEF ANDROID}
	glBufferDataARB(VParam,VSize,VBuffer,VParam2);
{$ELSE}
	//їч
	{$ENDIF}
end;

procedure TSGRenderOpenGL.DrawElements(const VParam:Cardinal;const VSize:int64;const VParam2:Cardinal;VBuffer:Pointer); 
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
{$IFNDEF ANDROID}
	glBegin(VPrimitiveType);
{$ELSE}
	//їч
	{$ENDIF}
end;

procedure TSGRenderOpenGL.EndScene();
begin
{$IFNDEF ANDROID}
	glEnd();
{$ELSE}
	//їч
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
glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);

glEnable(GL_FOG);
{$IFNDEF ANDROID} 
	glFogi(GL_FOG_MODE, GL_LINEAR);
{$ELSE} 
	{╒╟} 
	{$ENDIF}
glHint (GL_FOG_HINT, GL_NICEST);
//glHint(GL_FOG_HINT, GL_DONT_CARE);
glFogf (GL_FOG_START, 300);
glFogf (GL_FOG_END, 400);
glFogfv(GL_FOG_COLOR, @fogColor);
glFogf(GL_FOG_DENSITY, 0.55);

glClearColor(0,0,0,0);
{$IFNDEF LINUX}
	glEnable(GL_DEPTH_TEST);
	{$IFNDEF ANDROID} 
		glClearDepth(1.0);
	{$ELSE} 
		{їч} 
		{$ENDIF}
	glDepthFunc(GL_LEQUAL);
{$ENDIF}

glEnable(GL_LINE_SMOOTH);
{$IFNDEF ANDROID}
	glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
{$ELSE} 
	{їч} 
	{$ENDIF}
glLineWidth (1.0);

glShadeModel(GL_SMOOTH);
{$IFNDEF ANDROID}
	glEnable(GL_TEXTURE_1D);
{$ELSE} 
	{їч} 
	{$ENDIF}
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
{$IFNDEF ANDROID}
	glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
{$ELSE}
	{їч} 
	{$ENDIF}
glMaterialfv(GL_FRONT, GL_SPECULAR, @SpecularReflection);
{$IFNDEF ANDROID}
	glMateriali(GL_FRONT,GL_SHININESS,100);
{$ELSE} 
	{їч} 
	{$ENDIF}

glDisable(GL_LIGHTING);

LoadExtendeds();
end;

constructor TSGRenderOpenGL.Create();
begin
inherited Create();
FType:=SGRenderOpenGL;
{$IFDEF LINUX}
	FContext:=nil;
{$ELSE}
	{$IFDEF MSWINDOWS}
		FContext:=0;
	{$ELSE}
		{$IFDEF ANDROID}
			FContext:=nil;
			{$ENDIF}
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
		wglMakeCurrent( LongWord(FWindow.Get('DESCTOP WINDOW HANDLE')), 0 );
		if FContext<>0 then
			begin
			wglDeleteContext( FContext );
			CloseHandle(FContext);
			FContext:=0;
			end;
	{$ELSE}
		{$IFDEF ANDROID}
			if (FContext <> EGL_NO_CONTEXT) then
				eglDestroyContext(FWindow.Get('DESCTOP WINDOW HANDLE'), FContext);
			{$ENDIF}
		{$ENDIF}
	{$ENDIF}
inherited;
end;

procedure TSGRenderOpenGL.InitOrtho2d(const x0,y0,x1,y1:TSGSingle);
begin
glMatrixMode(GL_PROJECTION);
LoadIdentity();
{$IFNDEF ANDROID}glOrtho(x0,x1,y0,y1,0,0.1); {$ELSE} {їч} {$ENDIF}
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
	{$IFNDEF ANDROID}glOrtho(0,CWidth,CHeight,0,0,0.1);{$ELSE} {їч} {$ENDIF}
	end
else
	if Mode = SG_3D_ORTHO then
		begin
		{$IFNDEF ANDROID}glOrtho(-(CWidth / (1/dncht*120)),CWidth / (1/dncht*120),-CHeight / (1/dncht*120),(CHeight / (1/dncht*120)),0,500){$ELSE} {їч} {$ENDIF}
		end
	else
		{$IFNDEF ANDROID}gluPerspective(45, CWidth / CHeight, 0.0011, 500){$ELSE} {їч} {$ENDIF};
glMatrixMode(GL_MODELVIEW);
LoadIdentity();
end;

procedure TSGRenderOpenGL.Viewport(const a,b,c,d:LongWord);
begin
//SGLog.Sourse([a,',',b,',',c,',',d,'- VIEWPORT']);
glViewport(a,b,c,d);
end;

procedure TSGRenderOpenGL.LoadIdentity();
begin
glLoadIdentity();
end;

procedure TSGRenderOpenGL.Vertex3f(const x,y,z:single);
begin
{$IFNDEF ANDROID}
	glVertex3f(x,y,z);
{$ELSE} 
	{їч} 
	{$ENDIF}
end;

function TSGRenderOpenGL.CreateContext():Boolean;
begin
Result:=False;
{$IFDEF LINUX}
	initGlx();
	FContext := glXCreateContext(
		PDisplay(FWindow.Get('DESCTOP WINDOW HANDLE')),
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
			FContext := wglCreateContext( LongWord(FWindow.Get('DESCTOP WINDOW HANDLE')) );
		Result:=FContext<>0;
	{$ELSE}
		{$IFDEF ANDROID}
			FContext := eglCreateContext(FWindow.Get('DESCTOP WINDOW HANDLE'), FWindow.Get('VISUAL INFO'), nil, nil);
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
			PDisplay(FWindow.Get('DESCTOP WINDOW HANDLE')),
			LongWord(FWindow.Get('WINDOW HANDLE')),
			nil);
{$ELSE}
	{$IFDEF MSWINDOWS}
		if (FWindow<>nil)  then 
			wglMakeCurrent( LongWord(FWindow.Get('DESCTOP WINDOW HANDLE')), 0 );
	{$ELSE}
		{$IFDEF ANDROID}
			if FWindow<>nil then
				eglMakeCurrent(FWindow.Get('DESCTOP WINDOW HANDLE'), EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
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
begin
{$IFDEF MSWINDOWS}
	FillChar(pfd, sizeof(pfd), 0);
	pfd.nSize         := sizeof(pfd);
	pfd.nVersion      := 1;
	pfd.dwFlags       := PFD_SUPPORT_OPENGL OR PFD_DRAW_TO_WINDOW OR PFD_DOUBLEBUFFER;
	pfd.iPixelType    := PFD_TYPE_RGBA;
	pfd.cColorBits    := 32;
	pfd.cDepthBits    := 24;
	pfd.iLayerType    := PFD_MAIN_PLANE;
	iFormat := Windows.ChoosePixelFormat( LongWord(FWindow.Get('DESCTOP WINDOW HANDLE')), @pfd );
	Result:=Windows.SetPixelFormat( LongWord(FWindow.Get('DESCTOP WINDOW HANDLE')), iFormat, @pfd );
	{$ENDIF}
{$IFDEF LINUX}
	Result:=True;
	{$ENDIF}
{$IFDEF ANDROID}
	Result:=True;
	{$ENDIF}
end;

function TSGRenderOpenGL.MakeCurrent():Boolean;
begin
{$IFDEF LINUX}
	if (FWindow<>nil) and (FContext<>nil) then 
		begin
		glXMakeCurrent(
			PDisplay(FWindow.Get('DESCTOP WINDOW HANDLE')),
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
			wglMakeCurrent( LongWord(FWindow.Get('DESCTOP WINDOW HANDLE')), FContext );
			Result:=True;
			end
		else
			Result:=False;
	{$ELSE}
		{$IFDEF ANDROID}
			if (FWindow<>nil) and (FContext<>nil) then 
				if eglMakeCurrent(
					FWindow.Get('DESCTOP WINDOW HANDLE'), 
					FWindow.Get('SURFACE'), 
					FWindow.Get('SURFACE'), 
					FContext)  = EGL_FALSE then
					Result:=False
				else
					Result:=True
			else
				Result:=False;
			{$ENDIF}
		{$ENDIF}
	{$ENDIF}
end;

end.
