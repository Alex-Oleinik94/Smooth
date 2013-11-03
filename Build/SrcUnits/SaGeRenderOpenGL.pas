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
		function SetPixelFormat():Boolean;override;overload;
		function CreateContext():Boolean;override;
		procedure MakeCurrent();override;
		procedure ReleaseCurrent();override;
		procedure Init();override;
		procedure LoadExtendeds();
		procedure Viewport(const a,b,c,d:LongWord);override;
			public
		procedure InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht:Real = 120);override;
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
		procedure BindTexture(const VParam:Cardinal;const VTexture:SGUInt);override;
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
		end;

implementation

procedure TSGRenderOpenGL.LineWidth(const VLW:Single);
begin
glLineWidth(VLW);
end;

procedure TSGRenderOpenGL.Color3f(const r,g,b:single);
begin
glColor3f(r,g,b);
end;

procedure TSGRenderOpenGL.TexCoord2f(const x,y:single); 
begin 
glTexCoord2f(x,y);
end;

procedure TSGRenderOpenGL.Vertex2f(const x,y:single); 
begin
glVertex2f(x,y);
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

procedure TSGRenderOpenGL.BindTexture(const VParam:Cardinal;const VTexture:SGUInt); 
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
glGenBuffersARB(VQ,PT);
end;

procedure TSGRenderOpenGL.DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer); 
begin 
glDeleteBuffersARB(VQuantity,VPoint);
end;

procedure TSGRenderOpenGL.BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal); 
begin 
glBindBufferARB(VParam,VParam2);
end;

procedure TSGRenderOpenGL.BufferDataARB(const VParam:Cardinal;const VSize:int64;VBuffer:Pointer;const VParam2:Cardinal); 
begin 
glBufferDataARB(VParam,VSize,VBuffer,VParam2);
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
glBegin(VPrimitiveType);
{case VPrimitiveType of
SG_POINTS:glBegin(GL_POINTS);
SG_LINES:glBegin(GL_LINES);
SG_LINE_STRIP:glBegin(GL_LINE_STRIP);
SG_LINE_LOOP:glBegin(GL_LINE_LOOP);
SG_TRIANGLES:glBegin(GL_TRIANGLES);
SG_TRIANGLE_STRIP:glBegin(GL_TRIANGLE_STRIP);
SG_TRIANGLE_FAN:glBegin(GL_TRIANGLE_FAN);
SG_QUADS:glBegin(GL_QUADS);
SG_POLYGON:glBegin(GL_POLYGON)
end;}
end;

procedure TSGRenderOpenGL.EndScene();
begin
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
	glOrtho(0,CWidth,CHeight,0,0,0.1);
	end
else
	if Mode = SG_3D_ORTHO then
		begin
		glOrtho(-(CWidth / dncht),CWidth / dncht,-CHeight / dncht,(CHeight / dncht),0,500)
		end
	else
		gluPerspective(45, CWidth / CHeight, 0.0011, 500);
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
glVertex3f(x,y,z);
end;

function TSGRenderOpenGL.CreateContext():Boolean;
{$IFDEF UNIX}
	var
		FDisplay:PDisplay;
{$ELSE}
	
	{$ENDIF}
begin
Result:=False;
{$IFDEF UNIX}
	FDisplay:=XOpenDisplay(nil);
	
{$ELSE}
	{$IFDEF MSWINDOWS}
		if SetPixelFormat() then
			FContext := wglCreateContext( LongWord(FWindow.Get('WINDOW HANDLE')) );
		Result:=FContext<>0;
		{$ENDIF}
	{$ENDIF}
if Result then
	MakeCurrent();
end;

procedure TSGRenderOpenGL.ReleaseCurrent();
begin
{$IFDEF UNIX}
	if (FWindow<>0) and (FContext<>nil) then 
		glXMakeCurrent(XOpenDisplay(nil),LongWord(FWindow.Get('WINDOW HANDLE')),nil);
{$ELSE}
	{$IFDEF MSWINDOWS}
		if (FWindow<>nil)  then 
			wglMakeCurrent( LongWord(FWindow.Get('WINDOW HANDLE')), 0 );
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
	iFormat := Windows.ChoosePixelFormat( LongWord(FWindow.Get('WINDOW HANDLE')), @pfd );
	Result:=Windows.SetPixelFormat( LongWord(FWindow.Get('WINDOW HANDLE')), iFormat, @pfd );
	{$ENDIF}
end;

procedure TSGRenderOpenGL.MakeCurrent();
begin
{$IFDEF UNIX}
	if (FWindow<>0) and (FContext<>nil) then 
		glXMakeCurrent(XOpenDisplay(nil),LongWord(FWindow.Get('WINDOW HANDLE')),FContext);
{$ELSE}
	{$IFDEF MSWINDOWS}
		SGLog.Sourse(['TSGRender__MakeCurrent() : Info : dcWnd=',LongWord(FWindow.Get('WINDOW HANDLE')),', FContext=',FContext,', @wglMakeCurrent=',LongWord(@wglMakeCurrent),'.']);
		if (FWindow<>nil) and (FContext<>0) then 
			wglMakeCurrent( LongWord(FWindow.Get('WINDOW HANDLE')), FContext );
		{$ENDIF}
	{$ENDIF}
end;

end.
