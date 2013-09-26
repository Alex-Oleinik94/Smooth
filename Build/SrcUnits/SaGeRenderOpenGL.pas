{$IFDEF UNIX}
{$ELSE}
	{$IFDEF MSWINDOW}
		{$ENDIF}
	{$ENDIF}
{$include Includes\SaGe.inc}
unit SaGeRenderOpenGL;
interface
uses
	SaGeBase
	,SaGeRender
	,gl
	,glu
	,glext
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
	,DynLibs
	;
type
	TSGRenderOpenGL=class(TSGRender)
			public
		constructor Create;override;
		destructor Destroy;override;
			protected
		FContext:
		{$IFDEF UNIX}
			GLXContext;
		{$ELSE}
			{$IFDEF MSWINDOWS}
				HGLRC;
			{$ELSE}
				{$ENDIF}
			 {$ENDIF}
			public
		{$DEFINE SG_RENDER_EIC}
		{$INCLUDE Includes\SaGeRenderOpenGLLoadExtendeds.inc}
		{$UNDEF SG_RENDER_EIC}
			public
		function CreateContext():Boolean;override;
		procedure MakeCurrent();override;
		procedure Init();override;
		procedure LoadExtendeds();
			public
		procedure InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht:Real = 120);override;
		procedure LoadIdentity();override;
		procedure Viewport(const a,b,c,d:LongWord);override;
		procedure Vertex3f(const x,y,z:single);override;
		procedure BeginScene(const VPrimitiveType:TSGPrimtiveType);override;
		procedure EndScene();override;
			public //Common variables for Begin/End
		FNowPrimitive:TSGPrimtiveType;
		FQuantityVertexes:LongWord;
		end;

implementation

{$DEFINE SG_RENDER_EP}
{$INCLUDE Includes\SaGeRenderOpenGLLoadExtendeds.inc}
{$UNDEF SG_RENDER_EP}

procedure TSGRenderOpenGL.BeginScene(const VPrimitiveType:TSGPrimtiveType);
begin
case VPrimitiveType of
SG_POINTS:glBegin(GL_POINTS);
SG_LINES:glBegin(GL_LINES);
SG_LINE_STRIP:glBegin(GL_LINE_STRIP);
SG_LINE_LOOP:glBegin(GL_LINE_LOOP);
SG_TRIANGLES:glBegin(GL_TRIANGLES);
SG_TRIANGLE_STRIP:glBegin(GL_TRIANGLE_STRIP);
SG_TRIANGLE_FAN:glBegin(GL_TRIANGLE_FAN);
SG_QUADS:glBegin(GL_QUADS);
SG_POLYGON:glBegin(GL_POLYGON)
end;
FQuantityVertexes:=0;
FNowPrimitive:=VPrimitiveType;
end;

procedure TSGRenderOpenGL.EndScene();
begin
if FNowPrimitive=SG_LINE_LOOP then
	
glEnd();
end;

procedure TSGRenderOpenGL.Init;
var
	AmbientLight : array[0..3] of glFloat = (0.5,0.5,0.5,1.0);
	DiffuseLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
	SpecularLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
	SpecularReflection : array[0..3] of glFloat = (0.4,0.4,0.4,1.0);
	LightPosition : array[0..3] of glFloat = (0,1,0,2);
	fogColor:array[0..3] of glFloat = (0,0,0,1);
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
glEnable(GL_DEPTH_TEST);
glClearDepth(1.0);
glDepthFunc(GL_LEQUAL);

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
//glEnable (GL_POLYGON_SMOOTH);

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

glDisable(GL_LIGHTING);

LoadExtendeds();
end;

constructor TSGRenderOpenGL.Create;
begin
inherited;
{$IFDEF UNIX}
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
{$IFDEF UNIX}
{$ELSE}
	{$IFDEF MSWINDOW}
		wglMakeCurrent( LongWord(FWindow.Get('WINDOW HANDLE')), 0 );
		if FContext<>0 then
			begin
			wglDeleteContext( FContext );
			CloseHandle(FContext);
			FContext:=0;
			end;
		{$ENDIF}
	{$ENDIF}
inherited;
end;

procedure TSGRenderOpenGL.InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht:Real = 120);
const
	glub = 500;
begin
Viewport(0, 0, LongWord(FWindow.Get('WIDTH')), LongWord(FWindow.Get('HEIGHT')));
glMatrixMode(GL_PROJECTION);
LoadIdentity();
if  Mode=SG_2D then
	glOrtho(0,LongWord(FWindow.Get('WIDTH')),LongWord(FWindow.Get('HEIGHT')),0,0,0.1)
else
	if Mode = SG_3D_ORTHO then
		begin
		glOrtho(-(LongWord(FWindow.Get('WIDTH')) / dncht),LongWord(FWindow.Get('WIDTH')) / dncht,-LongWord(FWindow.Get('HEIGHT')) / dncht,(LongWord(FWindow.Get('HEIGHT')) / dncht),0,500)
		end
	else
		gluPerspective(45, LongWord(FWindow.Get('WIDTH')) / LongWord(FWindow.Get('HEIGHT')), 0.0011, 500);
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
glVertex3f(x,y,z);
FQuantityVertexes+=1;
end;

function TSGRenderOpenGL.CreateContext():Boolean;
{$IFDEF UNIX}
	var
		FDisplay:PDisplay;
{$ELSE}
	{$IFDEF MSWINDOWS}
		var
			pfd : PIXELFORMATDESCRIPTOR;
			iFormat : integer;
		{$ENDIF}
	{$ENDIF}
begin
{$IFDEF UNIX}
	FDisplay:=XOpenDisplay(nil);
	
{$ELSE}
	{$IFDEF MSWINDOWS}
		FillChar(pfd, sizeof(pfd), 0);
		pfd.nSize         := sizeof(pfd);
		pfd.nVersion      := 1;
		pfd.dwFlags       := PFD_SUPPORT_OPENGL OR PFD_DRAW_TO_WINDOW OR PFD_DOUBLEBUFFER;
		pfd.iPixelType    := PFD_TYPE_RGBA;
		pfd.cColorBits    := 32;
		pfd.cDepthBits    := 24;
		pfd.iLayerType    := PFD_MAIN_PLANE;
		iFormat := ChoosePixelFormat( LongWord(FWindow.Get('WINDOW HANDLE')), @pfd );
		SetPixelFormat( LongWord(FWindow.Get('WINDOW HANDLE')), iFormat, @pfd );
		FContext := wglCreateContext( LongWord(FWindow.Get('WINDOW HANDLE')) );
		{$ENDIF}
	{$ENDIF}
MakeCurrent();
end;

procedure TSGRenderOpenGL.MakeCurrent();
begin
{$IFDEF UNIX}
	if (FWindow<>0) and (FContext<>nil) then 
		glXMakeCurrent(XOpenDisplay(nil),LongWord(FWindow.Get('WINDOW HANDLE')),FContext);
{$ELSE}
	{$IFDEF MSWINDOWS}
		if (FWindow<>nil) and (FContext<>0) then 
			wglMakeCurrent( LongWord(FWindow.Get('WINDOW HANDLE')), FContext );
		{$ENDIF}
	{$ENDIF}
end;

end.
