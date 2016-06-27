{$INCLUDE SaGe.inc}

{$IFDEF MOBILE}
	{$DEFINE SGINTERPRITATEBEGINEND}
	//{$DEFINE SGINTERPRITATEBEGINENDWITHVBO}
	{$ENDIF}
{$IFDEF ANDROID}
	{$DEFINE NEEDRESOURSES}
	{$ENDIF}
{$IFDEF DARWIN}
	{$DEFINE SHADERSISPOINTERS}
	{$ENDIF}
{$DEFINE INTERPRITATEROTATETRANSLATE}

{$DEFINE RENDER_OGL_DEBUG}

unit SaGeRenderOpenGL;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeRender
	,SaGeCommon
	,Math
	{$IFDEF ANDROID}
		,egl
		,android_native_app_glue
		{$ENDIF}
	{$IFNDEF MOBILE}
		,dglOpenGL
		,gl
		,glu
		,glext
	{$ELSE}
		,gles
		,gles11
		,gles20
		{$ENDIF}
	{$IFDEF MSWINDOWS}
		,windows
		{$ENDIF}
	{$IFDEF UNIX}
		,Dl
		,unix
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
	,SysUtils
	,Classes
	,SaGeRenderConstants
	;

{$IFDEF NEEDRESOURSES}
	const 
		TempDir = {$IFDEF ANDROID}'/sdcard/.SaGe/Temp'{$ELSE}'Temp'{$ENDIF};
	{$ENDIF}
type
	TSGRenderOpenGL=class(TSGRender)
			public
		constructor Create();override;
		destructor Destroy();override;
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
		{$INCLUDE SaGeRenderOpenGLLoadExtendeds.inc}
		{$UNDEF SG_RENDER_EIC}
			public
		function SetPixelFormat():Boolean;override;overload;
		function CreateContext():Boolean;override;
		function MakeCurrent():Boolean;override;
		procedure ReleaseCurrent();override;
		procedure Init();override;
		procedure Kill();override;
		procedure LoadExtendeds();
		procedure Viewport(const a,b,c,d:LongWord);override;
		procedure SwapBuffers();override;
		function SupporedVBOBuffers:Boolean;override;
			public
		procedure InitOrtho2d(const x0,y0,x1,y1:TSGSingle);override;
		procedure InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht:Real = 1);override;
		procedure LoadIdentity();override;
		procedure Perspective(const vAngle,vAspectRatio,vNear,vFar : TSGFloat);override;
		procedure Vertex3f(const x,y,z:single);override;
		procedure BeginScene(const VPrimitiveType:TSGPrimtiveType);override;
		procedure EndScene();override;
		// Сохранения ресурсов рендера и убивание самого рендера
		procedure LockResourses();override;
		// Инициализация рендера и загрузка сохраненных ресурсов
		procedure UnLockResourses();override;
		
		procedure Color3f(const r,g,b:single);override;
		procedure TexCoord2f(const x,y:single);override;
		procedure Vertex2f(const x,y:single);override;
		procedure Scale(const x,y,z : TSGSingle);override;
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
		procedure TexImage2D(const VTextureType:Cardinal;const VP1:TSGCardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;VBitMap:Pointer);override;
		procedure ReadPixels(const x,y:Integer;const Vwidth,Vheight:TSGInteger;const format, atype: TSGCardinal;const pixels: Pointer);override;
		procedure CullFace(const VParam:Cardinal);override;
		procedure EnableClientState(const VParam:TSGCardinal);override;
		procedure DisableClientState(const VParam:TSGCardinal);override;
		procedure GenBuffersARB(const VQ:TSGInteger;const PT:PCardinal);override;
		procedure DeleteBuffersARB(const VQuantity:LongWord;VPoint:TSGPointer);override;
		procedure BindBufferARB(const VParam:TSGCardinal;const VParam2:TSGCardinal);override;
		procedure BufferDataARB(const VParam:TSGCardinal;const VSize:TSGInt64;VBuffer:Pointer;const VParam2:Cardinal;const VIndexPrimetiveType : TSGLongWord = 0);override;
		procedure DrawElements(const VParam:TSGCardinal;const VSize:TSGInt64;const VParam2:Cardinal;VBuffer:Pointer);override;
		procedure ColorPointer(const VQChannels:TSGLongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);override;
		procedure TexCoordPointer(const VQChannels:TSGLongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);override;
		procedure NormalPointer(const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);override;
		procedure VertexPointer(const VQChannels:TSGLongWord;const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);override;
		function IsEnabled(const VParam:TSGCardinal):TSGBoolean;override;
		procedure Clear(const VParam:TSGCardinal);override;
		procedure ClearColor(const r,g,b,a : TSGFloat);override;
		procedure LineWidth(const VLW:TSGSingle);override;
		procedure PointSize(const PS:TSGSingle);override;
		procedure PushMatrix();override;
		procedure PopMatrix();override;
		procedure DrawArrays(const VParam:TSGCardinal;const VFirst,VCount:TSGLongWord);override;
		procedure Vertex3fv(const Variable : TSGPointer);override;
		procedure Normal3fv(const Variable : TSGPointer);override;
		procedure MultMatrixf(const Variable : TSGPointer);override;
		procedure ColorMaterial(const r,g,b,a : TSGSingle);override;
		procedure MatrixMode(const Par:TSGLongWord);override;
		procedure LoadMatrixf(const Variable : TSGPointer);override;
		procedure ClientActiveTexture(const VTexture : TSGLongWord);override;
		procedure ActiveTexture(const VTexture : TSGLongWord);override;
		procedure ActiveTextureDiffuse();override;
		procedure ActiveTextureBump();override;
		procedure BeginBumpMapping(const Point : Pointer );override;
		procedure EndBumpMapping();override;
		procedure PolygonOffset(const VFactor, VUnits : TSGFloat);override;
		{$IFDEF MOBILE}
			procedure GenerateMipmap(const Param : TSGCardinal);override;
		{$ELSE}
			procedure GetVertexUnderPixel(const px, py : LongWord; out x, y, z : Real);override;
			{$ENDIF}
		
			(* Shaders *)
		function SupporedShaders() : TSGBoolean;override;
		function CreateShader(const VShaderType : TSGCardinal):TSGLongWord;override;
		procedure ShaderSource(const VShader : TSGLongWord; VSourse : PChar; VSourseLength : integer);override;
		procedure CompileShader(const VShader : TSGLongWord);override;
		procedure GetObjectParameteriv(const VObject : TSGLongWord; const VParamName : TSGCardinal; const VResult : TSGRPInteger);override;
		procedure GetInfoLog(const VHandle : TSGLongWord; const VMaxLength : TSGInteger; var VLength : TSGInteger; VLog : PChar);override;
		procedure DeleteShader(const VProgram : TSGLongWord);override;
		
		function CreateShaderProgram() : TSGLongWord;override;
		procedure AttachShader(const VProgram, VShader : TSGLongWord);override;
		procedure LinkShaderProgram(const VProgram : TSGLongWord);override;
		procedure DeleteShaderProgram(const VProgram : TSGLongWord);override;
		function GetUniformLocation(const VProgram : TSGLongWord; const VLocationName : PChar): TSGLongWord;override;
		procedure UseProgram(const VProgram : TSGLongWord);override;
		procedure UniformMatrix4fv(const VLocationName : TSGLongWord; const VCount : TSGLongWord; const VTranspose : TSGBoolean; const VData : TSGPointer);override;
		procedure Uniform3f(const VLocationName : TSGLongWord; const VX,VY,VZ : TSGFloat);override;
		procedure Uniform1f(const VLocationName : TSGLongWord; const V : TSGFloat);override;
		procedure Uniform1iv (const VLocationName: TSGLongWord; const VCount: TSGLongWord; const VValue: Pointer);override;
		procedure Uniform1uiv (const VLocationName: TSGLongWord; const VCount: TSGLongWord; const VValue: Pointer);override;
		procedure Uniform3fv (const VLocationName: TSGLongWord; const VCount: TSGLongWord; const VValue: Pointer);override;
		procedure Uniform1i(const VLocationName : TSGLongWord; const VData:TSGLongWord);override;
		
		function SupporedDepthTextures():TSGBoolean;override;
		procedure BindFrameBuffer(const VType : TSGCardinal; const VHandle : TSGLongWord);override;
		procedure GenFrameBuffers(const VCount : TSGLongWord;const VBuffers : PCardinal); override;
		procedure DrawBuffer(const VType : TSGCardinal);override;
		procedure ReadBuffer(const VType : TSGCardinal);override;
		procedure GenRenderBuffers(const VCount : TSGLongWord;const VBuffers : PCardinal); override;
		procedure BindRenderBuffer(const VType : TSGCardinal; const VHandle : TSGLongWord);override;
		procedure FrameBufferTexture2D(const VTarget: TSGCardinal; const VAttachment: TSGCardinal; const VRenderbuffertarget: TSGCardinal; const VRenderbuffer, VLevel: TSGLongWord);override;
		procedure FrameBufferRenderBuffer(const VTarget: TSGCardinal; const VAttachment: TSGCardinal; const VRenderbuffertarget: TSGCardinal; const VRenderbuffer: TSGLongWord);override;
		procedure RenderBufferStorage(const VTarget, VAttachment: TSGCardinal; const VWidth, VHeight: TSGLongWord);override;
		procedure GetFloatv(const VType : TSGCardinal; const VPointer : Pointer);override;
			private
			(* Multitexturing *)
		FNowActiveNumberTexture : TSGLongWord;
		
			(* Bump Mapping *)
		FNowInBumpMapping       : TSGBoolean;
		
		{$IFDEF SGINTERPRITATEBEGINEND}
			(* GLES BeginScene\EndScene*)
		FNowPrimetiveType  : TSGLongWord;
		FNowNormal         : TSGVertex3f;
		FNowColor          : TSGColor4b;
		FNowTexCoord       : TSGVertex2f;
		
		FFragmentInfo      : TSGByte;
		
		FMaxLengthArPoints : TSGLongWord;
		FNowPosArPoints    : TSGInteger;
		FArPoints : packed array of 
			packed record
				FVertex   : TSGVertex3f;
				FNormal   : TSGVertex3f;
				FTexCoord : TSGVertex2f;
				FColor    : TSGColor4b;
				end;
		
		FLightingEnabled : TSGBoolean;
		FTextureEnabled  : TSGBoolean;
		{$ENDIF}
		
		{$IFDEF NEEDRESOURSES}
			FArTextures : packed array of
				packed record
					FSaved : Boolean;
					FTexture : SGUInt;
					end;
			FBindedTexture : TSGLongWord;
			
			FArBuffers : packed array of
				packed record
					FSaved : Boolean;
					FBuffer : SGUInt;
					end;
			FVBOData:packed array [0..1] of TSGLongWord;
			// FVBOData[0] - SGR_ARRAY_BUFFER_ARB
			// FVBOData[1] - SGR_ELEMENT_ARRAY_BUFFER_ARB
			{$ENDIF}
		end;

//Эта функция позволяет задавать текущую (В зависимости от выбранной матрици процедурой glMatrixMode) матрицу 
//в соответствии с типом TSGMatrix4.
procedure SGRGLSetMatrix( vMatrix:TSGMatrix4);inline;

//Это функция - собственная замена gluPerspective в движке.
procedure SGRGLPerspective(const vAngle,vAspectRatio,vNear,vFar:TSGMatrix4Type);inline;

//Эта функция - собственная замена gluLookAt в движке.
procedure SGRGLLookAt(const Eve,At,Up:TSGVertex3f);inline;

procedure SGRGLOrtho(const l,r,b,t,vNear,vFar:TSGMatrix4Type);inline;

implementation

procedure TSGRenderOpenGL.Uniform1iv (const VLocationName: TSGLongWord; const VCount: TSGLongWord; const VValue: Pointer);
begin
{$IF defined(MOBILE)}glUniform1i(VLocationName,PSGLongInt(VValue)^){$ELSE}glUniform1iv(VLocationName,VCount,VValue){$ENDIF};
end;

procedure TSGRenderOpenGL.Uniform1uiv (const VLocationName: TSGLongWord; const VCount: TSGLongWord; const VValue: Pointer); 
begin
{$IF defined(MOBILE)}glUniform1i(VLocationName,PSGLongWord(VValue)^){$ELSE}glUniform1uiv(VLocationName,VCount,VValue){$ENDIF};
end;

procedure TSGRenderOpenGL.Uniform3fv (const VLocationName: TSGLongWord; const VCount: TSGLongWord; const VValue: Pointer);
begin
glUniform3fv(VLocationName,VCount,VValue);
end;

procedure TSGRenderOpenGL.Uniform1f(const VLocationName : TSGLongWord; const V : TSGFloat);
begin
glUniform1f(VLocationName,V);
end;

procedure TSGRenderOpenGL.Uniform3f(const VLocationName : TSGLongWord; const VX,VY,VZ : TSGFloat);
begin
glUniform3f(VLocationName,VX,VY,VZ);
end;

procedure TSGRenderOpenGL.PolygonOffset(const VFactor, VUnits : TSGFloat);
begin
glPolygonOffset(VFactor,VUnits);
end;

procedure TSGRenderOpenGL.GetFloatv(const VType : TSGCardinal; const VPointer : Pointer);
begin
glGetFloatv(VType, VPointer);
end;

procedure TSGRenderOpenGL.Perspective(const vAngle,vAspectRatio,vNear,vFar : TSGFloat);
begin
SGRGLPerspective(vAngle,vAspectRatio,vNear,vFar);
end;

procedure TSGRenderOpenGL.ClearColor(const r,g,b,a : TSGFloat);
begin
glClearColor(r,g,b,a);
end;

function TSGRenderOpenGL.SupporedDepthTextures():TSGBoolean;
begin
Result := {$IFDEF MOBILE} False {$ELSE} dglOpenGL.GL_ARB_texture_rg {$ENDIF};
end;

procedure TSGRenderOpenGL.BindFrameBuffer(const VType : TSGCardinal; const VHandle : TSGLongWord);
begin
{$IFNDEF MOBILE} glBindFramebufferEXT(VType,VHandle);{$ENDIF}
end;

procedure TSGRenderOpenGL.GenFrameBuffers(const VCount : TSGLongWord;const VBuffers : PCardinal);
begin
{$IFNDEF MOBILE} glGenFrameBuffersEXT(VCount,VBuffers);{$ENDIF}
end;

procedure TSGRenderOpenGL.DrawBuffer(const VType : TSGCardinal);
begin
{$IFNDEF MOBILE}glDrawBuffer(VType);{$ENDIF}
end;

procedure TSGRenderOpenGL.ReadBuffer(const VType : TSGCardinal);
begin
{$IFNDEF MOBILE}glReadBuffer(VType);{$ENDIF}
end;

procedure TSGRenderOpenGL.GenRenderBuffers(const VCount : TSGLongWord;const VBuffers : PCardinal); 
begin
{$IFNDEF MOBILE}glGenRenderBuffersEXT(VCount,VBuffers);{$ENDIF}
end;

procedure TSGRenderOpenGL.BindRenderBuffer(const VType : TSGCardinal; const VHandle : TSGLongWord);
begin
{$IFNDEF MOBILE}glBindRenderBufferEXT(VType,VHandle);{$ENDIF}
end;

procedure TSGRenderOpenGL.FrameBufferTexture2D(const VTarget: TSGCardinal; const VAttachment: TSGCardinal; const VRenderbuffertarget: TSGCardinal; const VRenderbuffer,VLevel: TSGLongWord);
begin
{$IFNDEF MOBILE}glFrameBufferTexture2DEXT(VTarget,VAttachment,VRenderbuffertarget,VRenderbuffer,VLevel);{$ENDIF}
end;

procedure TSGRenderOpenGL.FrameBufferRenderBuffer(const VTarget: TSGCardinal; const VAttachment: TSGCardinal; const VRenderbuffertarget: TSGCardinal; const VRenderbuffer: TSGLongWord);
begin
{$IFNDEF MOBILE}glFrameBufferRenderBufferEXT(VTarget,VAttachment,VRenderbuffertarget,VRenderbuffer);{$ENDIF}
end;

procedure TSGRenderOpenGL.RenderBufferStorage(const VTarget, VAttachment: TSGCardinal; const VWidth, VHeight: TSGLongWord);
begin
{$IFNDEF MOBILE}glRenderBufferStorageEXT(VTarget,VAttachment,VWidth,VHeight);{$ENDIF}
end;

procedure TSGRenderOpenGL.Scale(const x,y,z : TSGSingle);
begin
glScalef(x,y,z);
end;

procedure TSGRenderOpenGL.Uniform1i(const VLocationName : TSGLongWord; const VData:TSGLongWord);
begin
{$IFDEF MOBILE}glUniform1i{$ELSE}glUniform1iARB{$ENDIF}(VLocationName,VData);
end;

procedure TSGRenderOpenGL.UseProgram(const VProgram : TSGLongWord);
begin
{$IFDEF MOBILE}glUseProgram{$ELSE}glUseProgramObjectARB{$ENDIF}({$IFDEF SHADERSISPOINTERS}Pointer(VProgram){$ELSE}VProgram{$ENDIF});
end;

procedure TSGRenderOpenGL.UniformMatrix4fv(const VLocationName : TSGLongWord; const VCount : TSGLongWord; const VTranspose : TSGBoolean; const VData : TSGPointer);
begin
glUniformMatrix4fv(VLocationName,VCount,Byte(VTranspose),VData);
end;

function TSGRenderOpenGL.GetUniformLocation(const VProgram : TSGLongWord; const VLocationName : PChar): TSGLongWord;
begin
{$IFDEF MOBILE}glGetUniformLocation{$ELSE}glGetUniformLocationARB{$ENDIF}({$IFDEF SHADERSISPOINTERS}Pointer(VProgram){$ELSE}VProgram{$ENDIF},VLocationName);
end;

function TSGRenderOpenGL.SupporedShaders() : TSGBoolean;
begin
Result := {$IFDEF MOBILE}False{$ELSE}SGIsSuppored_GL_ARB_shader_objects{$ENDIF};
end;

function TSGRenderOpenGL.CreateShader(const VShaderType : TSGCardinal):TSGLongWord;
begin
Result := 
{$IFDEF SHADERSISPOINTERS} TSGLongWord( {$ENDIF}
	{$IFNDEF MOBILE}glCreateShaderObjectARB{$ELSE}glCreateShader{$ENDIF}(VShaderType)
{$IFDEF SHADERSISPOINTERS} ) {$ENDIF} ;
end;

procedure TSGRenderOpenGL.ShaderSource(const VShader : TSGLongWord; VSourse : PChar; VSourseLength : integer);
begin
{$IFDEF MOBILE}glShaderSource{$ELSE}glShaderSourceARB{$ENDIF}({$IFDEF SHADERSISPOINTERS}Pointer(VShader){$ELSE}VShader{$ENDIF},1,@VSourse,@VSourseLength);
end;

procedure TSGRenderOpenGL.CompileShader(const VShader : TSGLongWord);
begin
{$IFDEF MOBILE}glCompileShader{$ELSE}glCompileShaderARB{$ENDIF}({$IFDEF SHADERSISPOINTERS}Pointer(VShader){$ELSE}VShader{$ENDIF});
end;

procedure TSGRenderOpenGL.GetObjectParameteriv(const VObject : TSGLongWord; const VParamName : TSGCardinal; const VResult : TSGRPInteger);
begin
//glGetProgramiv - GLES
//glGetShaderiv - GLES
{$IFNDEF MOBILE}glGetObjectParameterivARB({$IFDEF SHADERSISPOINTERS}Pointer(VObject){$ELSE}VObject{$ENDIF},VParamName,VResult);{$ENDIF}
end;

procedure TSGRenderOpenGL.GetInfoLog(const VHandle : TSGLongWord; const VMaxLength : TSGInteger; var VLength : TSGInteger; VLog : PChar);
begin
//glGetShaderInfoLog - GLES
//glGetProgramInfoLog - GLES
{$IFNDEF MOBILE}glGetInfoLogARB({$IFDEF SHADERSISPOINTERS}Pointer(VHandle){$ELSE}VHandle{$ENDIF},VMaxLength,@VLength,VLog);{$ENDIF}
end;


function TSGRenderOpenGL.CreateShaderProgram() : TSGLongWord;
begin
Result := 
{$IFDEF SHADERSISPOINTERS} TSGLongWord( {$ENDIF}
	{$IFDEF MOBILE}glCreateProgram{$ELSE}glCreateProgramObjectARB{$ENDIF}()
{$IFDEF SHADERSISPOINTERS} ) {$ENDIF} ;
end;

procedure TSGRenderOpenGL.AttachShader(const VProgram, VShader : TSGLongWord);
begin
{$IFDEF MOBILE}glAttachShader{$ELSE}glAttachObjectARB{$ENDIF}({$IFDEF SHADERSISPOINTERS}Pointer(VProgram){$ELSE}VProgram{$ENDIF},{$IFDEF SHADERSISPOINTERS}Pointer(VShader){$ELSE}VShader{$ENDIF});
end;

procedure TSGRenderOpenGL.LinkShaderProgram(const VProgram : TSGLongWord);
begin
{$IFNDEF MOBILE}glLinkProgramARB{$ELSE}glLinkProgram{$ENDIF}({$IFDEF SHADERSISPOINTERS}Pointer(VProgram){$ELSE}VProgram{$ENDIF});
end;

procedure TSGRenderOpenGL.DeleteShader(const VProgram : TSGLongWord);
begin
glDeleteShader(VProgram);
end;

procedure TSGRenderOpenGL.DeleteShaderProgram(const VProgram : TSGLongWord);
begin
glDeleteProgram(VProgram);
end;

{$IFDEF MOBILE}
	const
		GL_SOURCE0_RGB = GL_SRC0_RGB;
		GL_SOURCE1_RGB = GL_SRC1_RGB;
		GL_SOURCE2_RGB = GL_SRC2_RGB;
		GL_SOURCE0_ALPHA = GL_SRC0_ALPHA;
		GL_SOURCE1_ALPHA = GL_SRC1_ALPHA;
		GL_SOURCE2_ALPHA = GL_SRC2_ALPHA;
	{$ENDIF}

{$IFDEF MOBILE}
procedure TSGRenderOpenGL.GenerateMipmap(const Param : TSGCardinal);
begin
//glGenerateMipmap(Param);
end;
{$ELSE}
procedure TSGRenderOpenGL.GetVertexUnderPixel(const px,py : LongWord; out x,y,z : Real);
var
	depth:Single;
	viewportarray:TViewPortArray;
	mv_matrix,proj_matrix:T16DArray;
begin
glGetIntegerv(GL_VIEWPORT,viewportarray);
glReadPixels(
	px,
	LongInt(Context.Width)-LongInt(py)-1,
	1, 
	1, 
	GL_DEPTH_COMPONENT, 
	GL_FLOAT, 
	@depth);
glGetDoublev(GL_MODELVIEW_MATRIX,mv_matrix);
glGetDoublev(GL_PROJECTION_MATRIX,proj_matrix);
gluUnProject(
	px,
	LongInt(Context.Height)-LongInt(py)-1,
	depth,
	mv_matrix,
	proj_matrix,
	viewportarray,
	@x,
	@y,
	@z);
end;
{$ENDIF}

procedure TSGRenderOpenGL.EndBumpMapping();
begin
FNowInBumpMapping := False;
end;

procedure TSGRenderOpenGL.BeginBumpMapping(const Point : Pointer );
var
	v : TSGVertex3f;
begin
v:=TSGVertex3f(Point^);
v.Normalize();
Color4f(
	v.x *0.5 + 0.5,
	v.y *0.5 + 0.5,
	v.z *0.5 + 0.5,1);
FNowInBumpMapping := True;
end;

procedure TSGRenderOpenGL.ActiveTextureDiffuse();
begin
if FNowActiveNumberTexture = 0 then
	begin
	if FNowInBumpMapping then
		begin
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
		glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_REPLACE);

		glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_TEXTURE);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
		end
	else
		begin
		glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
		glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
		
		glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_TEXTURE);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
		
		glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_PRIMARY_COLOR);
		glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
		end; 	
	end
else if FNowActiveNumberTexture = 1 then
	begin
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);

	glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PREVIOUS);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);

	glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_TEXTURE);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
	end;
end;

procedure TSGRenderOpenGL.ActiveTextureBump();
begin
if FNowActiveNumberTexture = 0 then
	begin
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
	glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_DOT3_RGB);

	glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PRIMARY_COLOR);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);

	glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_TEXTURE);
	glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
	end;
end;

procedure TSGRenderOpenGL.ActiveTexture(const VTexture : TSGLongWord);
begin
FNowActiveNumberTexture := VTexture;
{$IFDEF MOBILE}glActiveTexture{$ELSE}glActiveTextureARB{$ENDIF}(GL_TEXTURE0 + VTexture);
end;

procedure TSGRenderOpenGL.ClientActiveTexture(const VTexture : TSGLongWord);
begin
{$IFDEF MOBILE}glClientActiveTexture{$ELSE}glClientActiveTextureARB{$ENDIF}(GL_TEXTURE0 + VTexture);
end;

procedure TSGRenderOpenGL.ColorMaterial(const r,g,b,a : TSGSingle);
begin
glColor4f(r,g,b,a);
end;

procedure SGRGLOrtho(const l,r,b,t,vNear,vFar:TSGMatrix4Type);inline;
begin
glMatrixMode(GL_PROJECTION);
SGRGLSetMatrix(SGGetOrthoMatrix(l,r,b,t,vNear,vFar));
end;

procedure TSGRenderOpenGL.Vertex3fv(const Variable : TSGPointer);
begin
{$IFNDEF MOBILE}
	glVertex3fv(Variable);
{$ELSE}
	Vertex3f(PSingle(Variable)[0],PSingle(Variable)[1],PSingle(Variable)[2]);
	{$ENDIF}
end;

procedure TSGRenderOpenGL.Normal3fv(const Variable : TSGPointer);
begin
{$IFNDEF MOBILE}
	glNormal3fv(Variable);
{$ELSE}
	Normal3f(PSingle(Variable)[0],PSingle(Variable)[1],PSingle(Variable)[2]);
	{$ENDIF}
end;

procedure TSGRenderOpenGL.LoadMatrixf(const Variable : TSGPointer);
begin
glLoadMatrixf(Variable);
end;

procedure TSGRenderOpenGL.MultMatrixf(const Variable : TSGPointer);
begin
glMultMatrixf(Variable);
end;

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
SGRGLSetMatrix(SGGetLookAtMatrix(Eve,At,Up));
end;

procedure SGRGLPerspective(const vAngle,vAspectRatio,vNear,vFar:TSGMatrix4Type);inline;
begin
glMatrixMode(GL_PROJECTION);
SGRGLSetMatrix(SGGetPerspectiveMatrix(vAngle,vAspectRatio,vNear,vFar));
end;

procedure SGRGLSetMatrix( vMatrix:TSGMatrix4);inline;
begin
glLoadMatrixf(@vMatrix);
end;

procedure TSGRenderOpenGL.DrawArrays(const VParam:TSGCardinal;const VFirst,VCount:TSGLongWord);
begin
glDrawArrays(VParam,VFirst,VCount);
end;

procedure TSGRenderOpenGL.SwapBuffers();
begin
{$IFDEF MSWINDOWS}
	Windows.SwapBuffers( LongWord(Context.Device) );
{$ELSE}
	{$IFDEF LINUX}
		glXSwapBuffers(
			PDisplay(Context.Device),
			LongWord(Context.Window));
	{$ELSE}
		{$IFDEF ANDROID}
			eglSwapBuffers(Context.Device,FWindow.Get('SURFACE'));
		{$ELSE}
			{$IFDEF DARWIN}
				aglSwapBuffers( FContext );
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
	{$ENDIF}
end;

function TSGRenderOpenGL.SupporedVBOBuffers():Boolean;
begin
{$IFDEF MOBILE}
	Result:=True;
{$ELSE}
	Result:=SGIsSuppored_GL_ARB_vertex_buffer_object;
	{$ENDIF}
end;

procedure TSGRenderOpenGL.PointSize(const PS:Single);
begin
glPointSize(PS);
end;

procedure TSGRenderOpenGL.LineWidth(const VLW:Single);
begin
glLineWidth(VLW);
end;

procedure TSGRenderOpenGL.Vertex3f(const x,y,z:single);
begin
{$IF (not defined(MOBILE)) and (not defined(SGINTERPRITATEBEGINEND))}
	glVertex3f(x,y,z);
	{$ENDIF}
{$IFDEF SGINTERPRITATEBEGINEND}
	{$IFDEF MOBILE}
	if (FNowPrimetiveType=SGR_QUADS) and (FFragmentInfo=1) then
		begin
		FNowPosArPoints += 3;
		if FNowPosArPoints >= FMaxLengthArPoints then
			begin
			FMaxLengthArPoints := FNowPosArPoints + 1;
			SetLength(FArPoints,FMaxLengthArPoints);
			end;
		
		FArPoints[FNowPosArPoints].FVertex.Import(x,y,z);
		FArPoints[FNowPosArPoints].FColor    := FNowColor;
		FArPoints[FNowPosArPoints].FNormal   := FNowNormal;
		FArPoints[FNowPosArPoints].FTexCoord := FNowTexCoord;
		
		FArPoints[FNowPosArPoints-1] := FArPoints[FNowPosArPoints-3];
		FArPoints[FNowPosArPoints-2] := FArPoints[FNowPosArPoints-5];
		
		FFragmentInfo := 0;
		end
	else
		begin
		{$ENDIF}
		FNowPosArPoints+=1;
		if FNowPosArPoints=FMaxLengthArPoints then
			begin
			FMaxLengthArPoints+=1;
			SetLength(FArPoints,FMaxLengthArPoints);
			end;
		FArPoints[FNowPosArPoints].FVertex.Import(x,y,z);
		FArPoints[FNowPosArPoints].FColor    := FNowColor;
		FArPoints[FNowPosArPoints].FNormal   := FNowNormal;
		FArPoints[FNowPosArPoints].FTexCoord := FNowTexCoord;
		{$IFDEF MOBILE}
			if (FNowPrimetiveType = SGR_QUADS) and (FNowPosArPoints mod 3 = 2) then
				begin
				FFragmentInfo := 1;
				end;
		end;
			{$ENDIF}
	{$ENDIF}
end;

procedure TSGRenderOpenGL.Color3f(const r,g,b:single);
begin
{$IFNDEF SGINTERPRITATEBEGINEND}
	{$IFNDEF MOBILE}
		if IsEnabled(GL_BLEND) then
			glColor4f(r,g,b,1)
		else
			glColor3f(r,g,b);
	{$ELSE}
		glColor4f(r,g,b,1)
		{$ENDIF}
{$ELSE}
	Color4f(r,g,b,1);
	{$ENDIF}
end;

procedure TSGRenderOpenGL.TexCoord2f(const x,y:single); 
begin 
{$IF (not defined(MOBILE)) and (not defined(SGINTERPRITATEBEGINEND))}
	glTexCoord2f(x,y);
	{$ENDIF}
{$IFDEF SGINTERPRITATEBEGINEND}
	FNowTexCoord.Import(x,y);
	{$ENDIF}
end;

procedure TSGRenderOpenGL.Vertex2f(const x,y:single); 
begin
{$IF (not defined(MOBILE)) and (not defined(SGINTERPRITATEBEGINEND))}
	glVertex2f(x,y);
{$ELSE}
	Vertex3f(x,y,0);
	{$ENDIF}
end;

procedure TSGRenderOpenGL.Color4f(const r,g,b,a:single); 
begin 
{$IF (not defined(MOBILE)) and (not defined(SGINTERPRITATEBEGINEND))}
	glColor4f(r,g,b,a);
	{$ENDIF}
{$IFDEF SGINTERPRITATEBEGINEND}
	FNowColor.Import(
		Byte(b>=1)*255+Byte((b<1) and (b>0))*round(255*b),
		Byte(g>=1)*255+Byte((g<1) and (g>0))*round(255*g),
		Byte(r>=1)*255+Byte((r<1) and (r>0))*round(255*r),
		Byte(a>=1)*255+Byte((a<1) and (a>0))*round(255*a))
	{$ENDIF}
end;

procedure TSGRenderOpenGL.Normal3f(const x,y,z:single); 
begin
{$IF (not defined(MOBILE)) and (not defined(SGINTERPRITATEBEGINEND))}
	glNormal3f(x,y,z);
	{$ENDIF}
{$IFDEF SGINTERPRITATEBEGINEND}
	FNowNormal.Import(x,y,z);
	{$ENDIF}
end;

procedure TSGRenderOpenGL.BeginScene(const VPrimitiveType:TSGPrimtiveType);
begin
{$IF (not defined(MOBILE)) and (not defined(SGINTERPRITATEBEGINEND))}
	glBegin(VPrimitiveType);
	{$ENDIF}
{$IFDEF SGINTERPRITATEBEGINEND}
	FNowPrimetiveType := VPrimitiveType;
	FNowPosArPoints   := -1;
	FFragmentInfo     := 0;
	{$ENDIF}
end;

procedure TSGRenderOpenGL.EndScene();
{$IF defined(SGINTERPRITATEBEGINENDWITHVBO) and defined(SGINTERPRITATEBEGINEND)}
	var
		FBuffer : TSGLongWord;
	{$ENDIF}
begin
{$IF (not defined(MOBILE)) and (not defined(SGINTERPRITATEBEGINEND))}
	glEnd();
	{$ENDIF}
{$IFDEF SGINTERPRITATEBEGINEND}
	{$IFDEF SGINTERPRITATEBEGINENDWITHVBO}
		{$IFNDEF MOBILE}glGenBuffersARB{$ELSE}glGenBuffers{$ENDIF}(1,@FBuffer);
		{$IFNDEF MOBILE}glBindBufferARB{$ELSE}glBindBuffer{$ENDIF}(SGR_ARRAY_BUFFER_ARB,FBuffer);
		{$IFNDEF MOBILE}glBufferDataARB{$ELSE}glBufferData{$ENDIF}(SGR_ARRAY_BUFFER_ARB,SizeOf(FArPoints[0])*(FNowPosArPoints+1),@FArPoints[0], SGR_STATIC_DRAW_ARB);
		{$IFNDEF MOBILE}glBindBufferARB{$ELSE}glBindBuffer{$ENDIF}(SGR_ARRAY_BUFFER_ARB,FBuffer);
		{$ENDIF}
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	if FLightingEnabled then
	glEnableClientState(GL_NORMAL_ARRAY);
	if FTextureEnabled then
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer  (3, GL_FLOAT,          SizeOf(FArPoints[0]), 
		{$IFDEF SGINTERPRITATEBEGINENDWITHVBO}nil{$ELSE}@FArPoints[0].FVertex{$ENDIF});
	glColorPointer   (4, GL_UNSIGNED_BYTE,  SizeOf(FArPoints[0]),
		{$IFDEF SGINTERPRITATEBEGINENDWITHVBO}
			TSGPointer(TSGMaxEnum(@FArPoints[0].FColor)   -TSGMaxEnum(@FArPoints[0].FVertex))
				{$ELSE}@FArPoints[0].FColor{$ENDIF});
	if FTextureEnabled then
	glTexCoordPointer(2, GL_FLOAT,          SizeOf(FArPoints[0]),
		{$IFDEF SGINTERPRITATEBEGINENDWITHVBO}
			TSGPointer(TSGMaxEnum(@FArPoints[0].FTexCoord)-TSGMaxEnum(@FArPoints[0].FVertex))
				{$ELSE}@FArPoints[0].FTexCoord{$ENDIF});
	if FLightingEnabled then
	glNormalPointer  (   GL_FLOAT,          SizeOf(FArPoints[0]), 
		{$IFDEF SGINTERPRITATEBEGINENDWITHVBO}
			TSGPointer(TSGMaxEnum(@FArPoints[0].FNormal) -TSGMaxEnum(@FArPoints[0].FVertex))
				{$ELSE}@FArPoints[0].FNormal{$ENDIF});
	
	{$IFDEF MOBILE}
		if FNowPrimetiveType = SGR_QUADS then
			glDrawArrays(GL_TRIANGLES, 0, FNowPosArPoints+1)
		else
		{$ENDIF}
			glDrawArrays(FNowPrimetiveType, 0, FNowPosArPoints+1);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	if FLightingEnabled then
	glDisableClientState(GL_NORMAL_ARRAY);
	if FTextureEnabled then
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	{$IFDEF SGINTERPRITATEBEGINENDWITHVBO}
		{$IFNDEF MOBILE}glDeleteBuffersARB{$ELSE}glDeleteBuffers{$ENDIF}(1, @FBuffer);
		{$IFNDEF MOBILE}glBindBufferARB{$ELSE}glBindBuffer{$ENDIF}(SGR_ARRAY_BUFFER_ARB,0);
		{$ENDIF}
	{$ENDIF}
end;

procedure TSGRenderOpenGL.Translatef(const x, y, z : TSGSingle);
{$IF defined(INTERPRITATEROTATETRANSLATE)}
var
	Matrix : TSGMatrix4;
{$ENDIF}
begin 
{$IF not defined(INTERPRITATEROTATETRANSLATE)}
glTranslatef(x,y,z);
{$ELSE}
Matrix := SGGetTranslateMatrix(SGVertexImport(x, y, z));
MultMatrixf(@Matrix);
{$ENDIF}
end;

procedure TSGRenderOpenGL.Rotatef(const Angle : TSGSingle; const x, y, z : TSGSingle); 
{$IF defined(INTERPRITATEROTATETRANSLATE)}
const
	DEG2RAD = PI/180;
var
	Matrix : TSGMatrix4;
{$ENDIF}
begin 
{$IF not defined(INTERPRITATEROTATETRANSLATE)}
glRotatef(angle,x,y,z);
{$ELSE}
Matrix := SGGetRotateMatrix(Angle * DEG2RAD, SGVertexImport(x, y, z));
MultMatrixf(@Matrix);
{$ENDIF}
end;

procedure TSGRenderOpenGL.Enable(VParam:Cardinal); 
begin
{$IFDEF SGINTERPRITATEBEGINEND}
	case VParam of
	GL_LIGHTING   : FLightingEnabled := True;
	GL_TEXTURE_2D : FTextureEnabled := True;
	end;
	{$ENDIF}
glEnable(VParam);
end;

procedure TSGRenderOpenGL.Disable(const VParam:Cardinal); 
begin
{$IFDEF SGINTERPRITATEBEGINEND}
	case VParam of
	GL_LIGHTING   : FLightingEnabled := False;
	GL_TEXTURE_2D : FTextureEnabled := False;
	end;
	{$ENDIF}
glDisable(VParam);
end;

procedure TSGRenderOpenGL.DeleteTextures(const VQuantity:Cardinal;const VTextures:PSGUInt); 
{$IFDEF NEEDRESOURSES}
var
	i : LongWord;
{$ENDIF}
begin 
{$IFDEF NEEDRESOURSES}
for i:=0 to VQuantity-1 do
	begin
	if FArTextures[VTextures[i]-1].FSaved then
		begin
		if FileExists(TempDir+'/t'+SGStr(VTextures[i]-1)) then
			DeleteFile(TempDir+'/t'+SGStr(VTextures[i]-1));
		FArTextures[VTextures[i]-1].FSaved:=False;
		end;
	glDeleteTextures(1,@FArTextures[VTextures[i]-1].FTexture);
	FArTextures[VTextures[i]-1].FTexture:=0;
	end;
{$ELSE}
glDeleteTextures(VQuantity,VTextures);
{$ENDIF}
end;

procedure TSGRenderOpenGL.Lightfv(const VLight,VParam:Cardinal;const VParam2:Pointer);
type
	PSingle = ^ Single;
var
	Ar:TSGPointer = nil;
begin 
if VParam=SGR_POSITION then
	begin
	System.GetMem(Ar,4*Sizeof(TSGSingle));
	System.Move(VParam2^,Ar^,3*Sizeof(TSGSingle));
	PSingle(Ar)[3]:=1;
	glLightfv(VLight,VParam,Ar);
	System.FreeMem(Ar,4*Sizeof(TSGSingle));
	end
else
	glLightfv(VLight,VParam,VParam2);
end;

procedure TSGRenderOpenGL.GenTextures(const VQuantity:Cardinal;const VTextures:PSGUInt); 
{$IFDEF NEEDRESOURSES}
var
	i : TSGMaxEnum;
	{$ENDIF}
begin 
{$IFDEF NEEDRESOURSES}
for i:=0 to VQuantity-1 do
	begin
	if FArTextures=nil then
		SetLength(FArTextures,1)
	else
		SetLength(FArTextures,Length(FArTextures)+1);
	FArTextures[High(FArTextures)].FTexture:=0;
	FArTextures[High(FArTextures)].FSaved:=False;
	glGenTextures(1,@FArTextures[High(FArTextures)].FTexture);
	VTextures[i]:=Length(FArTextures);
	end;
{$ELSE}
glGenTextures(VQuantity,VTextures);
{$ENDIF}
end;

procedure TSGRenderOpenGL.BindTexture(const VParam:Cardinal;const VTexture:Cardinal); 
begin 
{$IFDEF NEEDRESOURSES}
if VTexture = 0 then
	begin
	glBindTexture(VParam,0);
	FBindedTexture:=0;
	end
else
	begin
	FBindedTexture := VTexture-1;
	glBindTexture(VParam,FArTextures[FBindedTexture].FTexture);
	end;
{$ELSE}
glBindTexture(VParam,VTexture);
{$ENDIF}
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

procedure TSGRenderOpenGL.TexImage2D(const VTextureType:Cardinal;const VP1:Cardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;VBitMap:Pointer); 
{$IFDEF NEEDRESOURSES}
var
	FS : TFileStream = nil;
{$ENDIF}
begin
{$IFDEF NEEDRESOURSES}
FS := TFileStream.Create(TempDir+'/t'+SGStr(FBindedTexture),fmCreate);
FS.WriteBuffer(VTextureType,SizeOf(VTextureType));
FS.WriteBuffer(VP1,SizeOf(VP1));
FS.WriteBuffer(VChannels,SizeOf(VChannels));
FS.WriteBuffer(VWidth,SizeOf(VWidth));
FS.WriteBuffer(VHeight,SizeOf(VHeight));
FS.WriteBuffer(VP2,SizeOf(VP2));
FS.WriteBuffer(VFormatType,SizeOf(VFormatType));
FS.WriteBuffer(VDataType,SizeOf(VDataType));
FS.WriteBuffer(VBitMap^,VChannels*VWidth*VHeight);
FS.Destroy();
FArTextures[FBindedTexture].FSaved := True;
SGLog.Sourse('"TSGRenderOpenGL.TexImage2D" : Saved : "'+TempDir+'/t'+SGStr(FBindedTexture)+'": W='+SGStr(VWidth)+', H='+SGStr(VHeight)+', C='+SGStr(VChannels)+'.');
{$ENDIF}
glTexImage2D(VTextureType,VP1,{$IFDEF MOBILE}VFormatType{$ELSE}VChannels{$ENDIF},VWidth,VHeight,VP2,VFormatType,VDataType,VBitMap);
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
{$IFDEF NEEDRESOURSES}
var
	i : LongWord;
{$ENDIF}
begin
{$IFDEF NEEDRESOURSES}
for i:=0 to VQ-1 do
	begin
	if FArBuffers = nil then
		SetLength(FArBuffers,1)
	else
		SetLength(FArBuffers,Length(FArBuffers)+1);
	{$IFNDEF MOBILE}glGenBuffersARB{$ELSE}glGenBuffers{$ENDIF}(1,@FArBuffers[High(FArBuffers)].FBuffer);
	PT[i]:=Length(FArBuffers);
	end;
{$ELSE}
{$IFNDEF MOBILE}glGenBuffersARB{$ELSE}glGenBuffers{$ENDIF}(VQ,PT);
{$ENDIF}
end;

procedure TSGRenderOpenGL.DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer); 
{$IFDEF NEEDRESOURSES}
var
	i : LongWord;
{$ENDIF}
begin 
{$IFDEF NEEDRESOURSES}
for i:=0 to VQuantity-1 do
	begin
	{$IFNDEF MOBILE}glDeleteBuffersARB{$ELSE}glDeleteBuffers{$ENDIF}(1,@FArBuffers[PCardinal(VPoint)[i]-1].FBuffer);
	FArBuffers[PCardinal(VPoint)[i]-1].FBuffer:=0;
	if SGFileExists(TempDir+'/b'+SGStr(PCardinal(VPoint)[i]-1)) then
		DeleteFile (TempDir+'/b'+SGStr(PCardinal(VPoint)[i]-1));
	FArBuffers[PCardinal(VPoint)[i]-1].FSaved:=False;
	end;
{$ELSE}
{$IFNDEF MOBILE}glDeleteBuffersARB{$ELSE}glDeleteBuffers{$ENDIF}(VQuantity,VPoint);
{$ENDIF}
end;

procedure TSGRenderOpenGL.BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal); 
begin
{$IFDEF NEEDRESOURSES}
case VParam of
SGR_ARRAY_BUFFER_ARB : FVBOData[0] := VParam2-1;
SGR_ELEMENT_ARRAY_BUFFER_ARB : FVBOData[1] := VParam2-1;
end;
if VParam2 = 0 then
	{$IFNDEF MOBILE}glBindBufferARB{$ELSE}glBindBuffer{$ENDIF}(VParam,0)
else
	{$IFNDEF MOBILE}glBindBufferARB{$ELSE}glBindBuffer{$ENDIF}(VParam,FArBuffers[VParam2-1].FBuffer);
{$ELSE}
{$IFNDEF MOBILE}glBindBufferARB{$ELSE}glBindBuffer{$ENDIF}(VParam,VParam2);
{$ENDIF}
end;

procedure TSGRenderOpenGL.BufferDataARB(const VParam:Cardinal;const VSize:int64;VBuffer:Pointer;const VParam2:Cardinal;const VIndexPrimetiveType : TSGLongWord = 0); 
{$IFDEF NEEDRESOURSES}
var
	FS : TFileStream = nil;
	i : Cardinal;
	ii : TSGQuadWord;
{$ENDIF}
begin
{$IFDEF NEEDRESOURSES}
i := Byte(VParam = SGR_ARRAY_BUFFER_ARB)*FVBOData[0]+Byte(VParam = SGR_ELEMENT_ARRAY_BUFFER_ARB)*FVBOData[1];
FS := TFileStream.Create(TempDir+'/b'+SGStr(i),fmCreate);
ii:= VParam;
FS.WriteBuffer(ii,SizeOf(ii));
ii := VSize;
FS.WriteBuffer(ii,SizeOf(ii));
ii := VParam2;
FS.WriteBuffer(ii,SizeOf(ii));
FS.WriteBuffer(VBuffer^,VSize);
FS.Destroy();
FArBuffers[i].FSaved := True;
SGLog.Sourse('"TSGRenderOpenGL.BufferDataARB" : Saved : "'+TempDir+'/b'+SGStr(i)+'", Size='+SGStr(VSize)+'.');
{$ENDIF}
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
{$INCLUDE SaGeRenderOpenGLLoadExtendeds.inc}
{$UNDEF SG_RENDER_EP}

procedure TSGRenderOpenGL.Init();
var
	AmbientLight : array[0..3] of glFloat = (0.5,0.5,0.5,1.0);
	DiffuseLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
	SpecularLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
	SpecularReflection : array[0..3] of glFloat = (0.4,0.4,0.4,1.0);
	LightPosition : array[0..3] of glFloat = (0,1,0,2);
	fogColor:array[0..3] of glFloat = (0,0,0,1);
begin
FNowInBumpMapping:=False;
{$IFDEF MOBILE}
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);
	{$ENDIF}

glEnable(GL_FOG);
{$IFNDEF MOBILE} 
	glFogi(GL_FOG_MODE, GL_LINEAR);
	{$ENDIF}
glHint (GL_FOG_HINT, GL_NICEST);
//glHint(GL_FOG_HINT, GL_DONT_CARE);
glFogf (GL_FOG_START, 300);
glFogf (GL_FOG_END, 400);
glFogfv(GL_FOG_COLOR, @fogColor);
glFogf(GL_FOG_DENSITY, 0.55);

glDisable(GL_FOG);

glClearColor(0,0,0,0);
glEnable(GL_DEPTH_TEST);
{$IFNDEF MOBILE}glClearDepth{$ELSE}glClearDepthf{$ENDIF}(1.0);
glDepthFunc(GL_LESS);

//Если включить GL_LINE_SMOOTH в GLES без шeйдеров то линии криво отображаются
//glEnable (GL_POLYGON_SMOOTH);
{$IFNDEF MOBILE}
	glEnable(GL_LINE_SMOOTH);
	glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
	{$ENDIF}
glLineWidth (1.0);

glShadeModel(GL_SMOOTH);
glEnable (GL_BLEND);
glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

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
	{$ENDIF}
glMaterialfv(GL_FRONT, GL_SPECULAR, @SpecularReflection);
{$IFNDEF MOBILE}
	glMateriali(GL_FRONT,GL_SHININESS,100);
	{$ENDIF}

glDisable(GL_LIGHTING);

LoadExtendeds();

{$IFNDEF MOBILE}
	dglOpenGL.InitOpenGL();
	dglOpenGL.ReadExtensions();
	dglOpenGL.ReadImplementationProperties();
	{$ENDIF}

{$IF defined(MSWINDOWS) and defined(CPU32)}
	// Enable V-Sync
	// Включаем вертикальную синхронизацию кадров
	if SGIsSuppored_WGL_EXT_swap_control then
		begin
		if wglGetSwapIntervalEXT()=0 then
			wglSwapIntervalEXT(1);
		SGLog.Sourse(['TSGRenderOpenGL.Init - V-Sync is "',TSGBoolean(wglGetSwapIntervalEXT()),'"']);
		end;
	{$ENDIF}
end;

constructor TSGRenderOpenGL.Create();
{$IFDEF NEEDRESOURSES}
procedure FreeMemTemp();
var
	ar : TArString = nil;
	i : TSGMaxEnum;
begin
ar := SGGetFileNames(TempDir+'/','*');
if ar <> nil then
	for i:= 0 to High(ar) do
		if (ar[i]<>'.') and (ar[i]<>'..') then
			DeleteFile(TempDir + '/' + ar[i]);
SetLength(ar,0);
end;
{$ENDIF}
begin
inherited Create();
SetRenderType({$IFDEF MOBILE}SGRenderGLES{$ELSE}SGRenderOpenGL{$ENDIF});
{$IFDEF SGINTERPRITATEBEGINEND}
	FNowPosArPoints:=-1;
	FMaxLengthArPoints:=0;
	FArPoints:=nil;
	FLightingEnabled := False;
	FTextureEnabled  := False;
	{$ENDIF}
{$IFDEF NEEDRESOURSES}
	FArTextures := nil;
	FBindedTexture := 0;
	FArBuffers :=nil;
	FVBOData[0]:=0;
	FVBOData[1]:=0;
	{$IFDEF ANDROID}
		SGMakeDirectory('/sdcard/.SaGe');
		SGMakeDirectory('/sdcard/.SaGe/Temp');
	{$ELSE}
		SGMakeDirectory('Temp');
		{$ENDIF}
	FreeMemTemp();
	{$ENDIF}
{$IF defined(LINUX) or defined(ANDROID)}
	FContext:=nil;
{$ELSE}
	{$IFDEF MSWINDOWS}
		FContext:=0;
		{$ENDIF}
	{$ENDIF}

{$DEFINE SG_RENDER_EICR}
{$INCLUDE SaGeRenderOpenGLLoadExtendeds.inc}
{$UNDEF SG_RENDER_EICR}

FNowInBumpMapping:=False;
end;

procedure TSGRenderOpenGL.Kill();
{$IFDEF NEEDRESOURSES}
procedure FreeMemTemp();
var
	ar : TArString = nil;
	i : TSGMaxEnum;
begin
ar := SGGetFileNames(TempDir+'/','*');
if ar <> nil then
	for i:= 0 to High(ar) do
		if (ar[i]<>'.') and (ar[i]<>'..') then
			DeleteFile(TempDir + '/' + ar[i]);
SetLength(ar,0);
end;
{$ENDIF}
begin
{$IFDEF NEEDRESOURSES}
	SetLength(FArTextures,0);
	SetLength(FArBuffers,0);
	FreeMemTemp();
	{$ENDIF}
{$IFDEF LINUX}
	
{$ELSE}
	{$IFDEF MSWINDOWS}
		if Context <> nil then
			wglMakeCurrent( TSGLongWord(Context.Device), 0 );
		if FContext <> 0 then
			begin
			wglDeleteContext( FContext );
			CloseHandle(FContext);
			FContext := 0;
			end;
	{$ELSE}
		{$IFDEF ANDROID}
			if (FContext <> EGL_NO_CONTEXT) then
				begin
				eglDestroyContext(Context.Device, FContext);
				FContext := EGL_NO_CONTEXT;
				end;
		{$ELSE}
			{$IFDEF DARWIN}
				aglSetCurrentContext( nil );
				aglDestroyContext( FContext );
				FillChar(FContext,Sizeof(FContext),0);
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
	{$ENDIF}
end;

destructor TSGRenderOpenGL.Destroy();
begin
Kill();
inherited;
{$IFDEF RENDER_OGL_DEBUG}
	WriteLn('TSGRenderOpenGL.Destroy(): End');
	{$ENDIF}
end;

procedure TSGRenderOpenGL.MatrixMode(const Par:TSGLongWord);
begin
glMatrixMode(Par);
end;

procedure TSGRenderOpenGL.InitOrtho2d(const x0,y0,x1,y1:TSGSingle);
begin
glMatrixMode(GL_PROJECTION);
LoadIdentity();
SGRGLOrtho(x0,x1,y0,y1,0,0.1);
glMatrixMode(GL_MODELVIEW);
LoadIdentity();
end;

procedure TSGRenderOpenGL.InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht:Real = 1);
const
	glub = 500;
var
	CWidth, CHeight : TSGLongWord;
begin
CWidth := Width;
CHeight := Height;
Viewport(0, 0, CWidth, CHeight);

glMatrixMode(GL_PROJECTION);
LoadIdentity();
if  Mode=SG_2D then
	begin
	SGRGLOrtho(0,CWidth,CHeight,0,0,1);
	Disable(SGR_DEPTH_TEST);
	end
else
	if Mode = SG_3D_ORTHO then
		begin
		SGRGLOrtho
			(-(CWidth / (1/dncht*120)),CWidth / (1/dncht*120),-CHeight / (1/dncht*120),(CHeight / (1/dncht*120)),TSGRenderNear,TSGRenderFar);
		Enable(SGR_DEPTH_TEST);
		end
	else
		begin
		//Впринципе теперь можно всегда пользоваться SGRGLPerspective вместо gluPerspective, но я 
		//Думаю все таки надуюсь, что gluPerspective будет работать чуть чуть быстрее чем моя процедурка.
		{$IFNDEF MOBILE}gluPerspective{$ELSE}SGRGLPerspective{$ENDIF}
			(45, CWidth / CHeight, TSGRenderNear, TSGRenderFar);
		Enable(SGR_DEPTH_TEST);
		end;
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

function TSGRenderOpenGL.CreateContext():Boolean;
begin
Result:=False;
{$IFDEF LINUX}
	initGlx();
	FContext := glXCreateContext(
		PDisplay(Context.Device),
		PXVisualInfo(Context.GetOption('VISUAL INFO')),nil,true);
	if FContext = nil then
		begin
		SGLog.Sourse('TSGContextUnix__CreateWindow : Error : Could not create an OpenGL rendering context!');
		Exit;
		end;
	Result:=FContext<>nil;
{$ELSE}
	{$IFDEF MSWINDOWS}
		if SetPixelFormat() then
			FContext := wglCreateContext( TSGLongWord(Context.Device) );
		Result:=FContext<>0;
	{$ELSE}
		{$IFDEF ANDROID}
			FContext := eglCreateContext(Context.Device, FWindow.Get('VISUAL INFO'), nil, nil);
			SGLog.Sourse('"TSGRenderOpenGL.CreateContext" : Called "eglCreateContext". Result="'+SGStr(TSGMaxEnum(FContext))+'"');
			Result:=TSGMaxEnum(FContext)<>0;
		{$ELSE}
			{$IFDEF DARWIN}
				if SetPixelFormat() then begin
					FContext := aglCreateContext( ogl_Format, nil );
					Result:= Assigned( FContext );
				end;
				if Result then
					begin
					if aglSetDrawable( FContext, WindowRef(Context.Device)) = GL_TRUE Then
						begin
						if aglSetCurrentContext( FContext ) = GL_TRUE Then
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
{$IFNDEF DARWIN}
if Result then
	Result:=MakeCurrent();
{$ENDIF}
end;

procedure TSGRenderOpenGL.ReleaseCurrent();
begin
{$IFDEF LINUX}
	if (Context <> nil) and (FContext <> nil) then 
		glXMakeCurrent(
			PDisplay(Context.Device),
			LongWord(Context.Window),
			nil);
{$ELSE}
	{$IFDEF MSWINDOWS}
		if (Context <> nil)  then 
			wglMakeCurrent( TSGLongWord(Context.Device), 0 );
	{$ELSE}
		{$IFDEF ANDROID}
			
		{$ELSE}
			{$IFDEF DARWIN}
				aglSetDrawable( nil, Context.Device);
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
	ogl_Attr[ 4 ] := AGL_NONE;
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
	iFormat := Windows.ChoosePixelFormat( LongWord(Context.Device), @pfd );
	SGLog.Sourse(['TSGRenderOpenGL.SetPixelFormat - "iFormat" = "',iFormat,'"']);
	Result:=Windows.SetPixelFormat( LongWord(Context.Device), iFormat, @pfd );
	SGLog.Sourse(['TSGRenderOpenGL.SetPixelFormat - "Result" = "',Result,'"']);
	{$ENDIF}
{$IF defined(LINUX) or defined(ANDROID)}
	Result:=True;
	{$ENDIF}
end;

function TSGRenderOpenGL.MakeCurrent():Boolean;
begin
{$IFDEF LINUX}
	if (Context <> nil) and (FContext <> nil) then 
		begin
		glXMakeCurrent(
			PDisplay(Context.Device),
			LongWord(Context.Window),
			FContext);
		Result:=True;
		end
	else
		Result:=False;
{$ELSE}
	{$IFDEF MSWINDOWS}
		if (Context<>nil) and (FContext<>0) then 
			begin
			wglMakeCurrent( LongWord(Context.Device), FContext );
			Result:=True;
			end
		else
			Result:=False;
	{$ELSE}
		{$IFDEF ANDROID}
			if (FWindow<>nil) and (FContext<>nil) then 
				begin
				if eglMakeCurrent(
					Context.Device, 
					FWindow.Get('SURFACE'), 
					FWindow.Get('SURFACE'), 
					FContext)  = EGL_FALSE then
						begin
						Result:=False;
						SGLog.Sourse('"TSGRenderOpenGL.MakeCurrent" : EGL Error : "'+SGGetEGLError()+'"');
						end
				else
					Result:=True;
				SGLog.Sourse('"TSGRenderOpenGL.MakeCurrent" : Called "eglMakeCurrent". Result="'+SGStr(Result)+'"');
				end
			else
				Result:=False;
		{$ELSE}
			{$IFDEF DARWIN}
				//Result:=aglSetDrawable( FContext, Context.Device) <> GL_FALSE;
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
	{$ENDIF}
end;

// Сохранения ресурсов рендера и убивание самого рендера
procedure TSGRenderOpenGL.LockResourses();
{$IFDEF NEEDRESOURSES}
var
	i : LongWord;
	{$ENDIF}
begin
{$IFDEF NEEDRESOURSES}
	if FArTextures <> nil then
		for i:= 0 to High(FArTextures) do
			if (FArTextures[i].FTexture <> 0) and (FArTextures[i].FSaved) then
				begin
				glDeleteTextures(1,@FArTextures[i].FTexture);
				FArTextures[i].FTexture:=0;
				end;
	if FArBuffers <> nil then
		for i:= 0 to High(FArBuffers) do
			if (FArBuffers[i].FBuffer <> 0) and (FArBuffers[i].FSaved) then
				begin
				{$IFNDEF MOBILE}glDeleteBuffersARB{$ELSE}glDeleteBuffers{$ENDIF}(1,@FArBuffers[i].FBuffer);
				FArBuffers[i].FBuffer:=0;
				end;
	{$ENDIF}
{$IFDEF ANDROID}
	if (FContext <> EGL_NO_CONTEXT) then
		begin
		if eglDestroyContext(Context.Device, FContext) = EGL_FALSE then
			SGLog.Sourse('"TSGRenderOpenGL.LockResourses" : EGL Error : "'+SGGetEGLError()+'"');
		FContext := EGL_NO_CONTEXT;
		end;
	{$ENDIF}
end;

// Инициализация рендера и загрузка сохраненных ресурсов
procedure TSGRenderOpenGL.UnLockResourses();
{$IFDEF NEEDRESOURSES}
procedure LoadTexture(const i : LongWord);
var
	VTextureType,VP1,VChannels,VWidth,VHeight,VFormatType,VDataType,VP2:Cardinal;
	VBitMap : Pointer = nil;
	FS : TFileStream = nil;
begin
FS := TFileStream.Create(TempDir+'/t'+SGStr(i),fmOpenRead);
FS.ReadBuffer(VTextureType,SizeOf(VTextureType));
FS.ReadBuffer(VP1,SizeOf(VP1));
FS.ReadBuffer(VChannels,SizeOf(VChannels));
FS.ReadBuffer(VWidth,SizeOf(VWidth));
FS.ReadBuffer(VHeight,SizeOf(VHeight));
FS.ReadBuffer(VP2,SizeOf(VP2));
FS.ReadBuffer(VFormatType,SizeOf(VFormatType));
FS.ReadBuffer(VDataType,SizeOf(VDataType));
GetMem(VBitMap,VChannels*VWidth*VHeight);
FS.ReadBuffer(VBitMap^,VChannels*VWidth*VHeight);
FS.Destroy();

glEnable(VTextureType);
glGenTextures(1,@FArTextures[i].FTexture);
glBindTexture(VTextureType,FArTextures[i].FTexture);
ActiveTextureDiffuse();

TexParameteri(VTextureType, SGR_TEXTURE_MIN_FILTER, SGR_LINEAR);
TexParameteri(VTextureType, SGR_TEXTURE_MAG_FILTER, SGR_NEAREST);
TexParameteri(VTextureType, SGR_TEXTURE_WRAP_S, SGR_REPEAT);
TexParameteri(VTextureType, SGR_TEXTURE_WRAP_T, SGR_REPEAT);

glTexImage2D(VTextureType,VP1,{$IFDEF MOBILE}VFormatType{$ELSE}VChannels{$ENDIF},VWidth,VHeight,VP2,VFormatType,VDataType,VBitMap);
glBindTexture(VTextureType,0);
glDisable(VTextureType);

FreeMem(VBitMap,VChannels*VWidth*VHeight);
SGLog.Sourse('"TSGRenderOpenGL.UnLockResourses" : LoadTexture : "'+TempDir+'/t'+SGStr(i)+'": W='+SGStr(VWidth)+', H='+SGStr(VHeight)+', C='+SGStr(VChannels)+', T='+SGStr(FArTextures[i].FTexture)+'.');
end;
procedure LoadBuffer(const i : LongWord);
var
	VBuffer : Pointer = nil;
	FS : TFileStream = nil;
	VType,VSize,VParam2 : TSGQWord;
begin
FS := TFileStream.Create(TempDir+'/b'+SGStr(i),fmOpenRead);
FS.ReadBuffer(VType,SizeOf(VType));
FS.ReadBuffer(VSize,SizeOf(VSize));
FS.ReadBuffer(VParam2,SizeOf(VParam2));
GetMem(VBuffer,VSize);
FS.ReadBuffer(VBuffer^,VSize);
FS.Destroy();

FArBuffers[i].FBuffer:=0;
{$IFNDEF MOBILE}glGenBuffersARB{$ELSE}glGenBuffers{$ENDIF}(1,@FArBuffers[i].FBuffer);
{$IFNDEF MOBILE}glBindBufferARB{$ELSE}glBindBuffer{$ENDIF}(VType,FArBuffers[i].FBuffer);
{$IFNDEF MOBILE}glBufferDataARB{$ELSE}glBufferData{$ENDIF}(VType,VSize,VBuffer,VParam2);
{$IFNDEF MOBILE}glBindBufferARB{$ELSE}glBindBuffer{$ENDIF}(VType,0);

FreeMem(VBuffer,VSize);
end;
var
	i : LongWord;
{$ENDIF}
begin
{$IFDEF ANDROID}
	FContext := eglCreateContext(Context.Device, FWindow.Get('VISUAL INFO'), nil, nil);
	if FContext = EGL_NO_CONTEXT then
		SGLog.Sourse('"TSGRenderOpenGL.UnLockResourses" : EGL Error : "'+SGGetEGLError()+'"');
	SGLog.Sourse('"TSGRenderOpenGL.UnLockResourses" : Called "eglCreateContext". Result="'+SGStr(TSGMaxEnum(FContext))+'"');
	if eglMakeCurrent(Context.Device,FWindow.Get('SURFACE'),FWindow.Get('SURFACE'),FContext)  = EGL_FALSE then
		begin
		SGLog.Sourse('"TSGRenderOpenGL.UnLockResourses" : EGL Error : "'+SGGetEGLError()+'"');
		SGLog.Sourse('"TSGRenderOpenGL.UnLockResourses" : Called "eglMakeCurrent". Result="FALSE"');
		end
	else
		SGLog.Sourse('"TSGRenderOpenGL.UnLockResourses" : Called "eglMakeCurrent". Result="TRUE"');
	{$ENDIF}
Init();
Clear(SGR_COLOR_BUFFER_BIT OR SGR_DEPTH_BUFFER_BIT);
SwapBuffers();
{$IFDEF NEEDRESOURSES}
	if FArTextures<>nil then
		for i:=0 to High(FArTextures) do
			if FArTextures[i].FSaved then
				LoadTexture(i);
	if FArBuffers<>nil then
		for i:=0 to High(FArBuffers) do
			if FArBuffers[i].FSaved then
				LoadBuffer(i);
	{$ENDIF}
end;

end.
