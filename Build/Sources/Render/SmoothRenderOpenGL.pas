{$INCLUDE Smooth.inc}

{$IFDEF MOBILE}
	{$DEFINE SINTERPRITATEBEGINEND}
	//{$DEFINE SINTERPRITATEBEGINENDWITHVBO}
	{$ENDIF}
{$IFDEF ANDROID}
	{$DEFINE NEEDResourceS}
	{$ENDIF}
{$IFDEF DARWIN}
	{$DEFINE SHADERSISPOINTERS}
	{$ENDIF}
{$DEFINE INTERPRITATEROTATETRANSLATE}
{$IFNDEF MOBILE}
	//{$DEFINE RENDER_OGL_DEBUG_DYNLINK}
	//{$DEFINE USE_GLEXT}
{$ELSE}
	{$DEFINE USE_GLEXT}
	{$ENDIF}
//{$DEFINE RENDER_OGL_DEBUG}

unit SmoothRenderOpenGL;

interface

uses
	//* === Engine units ====
	 SmoothBase
	,SmoothRender
	,SmoothRenderBase
	,SmoothRenderInterface
	,SmoothBaseClasses
	,SmoothDllManager
	,SmoothMatrix
	,SmoothCommonStructs
	,SmoothBaseContextInterface
	
	//* === System units ===
	,DynLibs
	,SysUtils
	,Math
	,Classes
	
	//* === Operating system(OS) units === 
	{$IFDEF DARWIN}
		,AGL
		,MacOSAll
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
	{$IFDEF MSWINDOWS}
		,Windows
		{$ENDIF}
	{$IFDEF ANDROID}
		,egl
		,android_native_app_glue
		{$ENDIF}

	//* === OpenGL units ===
	{$IFNDEF MOBILE}
		{$IFDEF USE_GLEXT}
			,glext
			,gl
		{$ELSE}
			,dglOpenGL
		{$ENDIF}
	{$ELSE}
		,gles
		,gles11
		,gles20
		{$ENDIF}
	;

{$IFDEF NEEDResourceS}
	const
		TempDir = {$IFDEF ANDROID}'/sdcard/.Smooth/Temp'{$ELSE}'Temp'{$ENDIF};
	{$ENDIF}
type
	TSRenderOpenGLContext =
	{$IFDEF LINUX}     GLXContext  {$ELSE}
	{$IFDEF MSWINDOWS} HGLRC       {$ELSE}
	{$IFDEF ANDROID}   EGLContext  {$ELSE}
	{$IFDEF DARWIN}    TAGLContext {$ELSE}
	                   Pointer
	{$ENDIF}  {$ENDIF}  {$ENDIF} {$ENDIF};

	TSRenderOpenGL = class(TSRender)
			public
		constructor Create (); override;
		destructor  Destroy(); override;
		class function RenderName() : TSString; override;
			protected
		FContext : TSRenderOpenGLContext;
		{$IFDEF DARWIN}
			ogl_Format  : TAGLPixelFormat;
			{$ENDIF}
			public
		class function Supported() : TSBoolean;override;
		function SetPixelFormat():Boolean;override;overload;
		function CreateContext():Boolean;override;
		function MakeCurrent():Boolean;override;
		procedure ReleaseCurrent();override;
		procedure Init();override;
		procedure Kill();override;
		procedure Viewport(const a,b,c,d:TSAreaInt);override;
		procedure SwapBuffers();override;
		function SupportedGraphicalBuffers() : TSBoolean; override;
		function SupportedMemoryBuffers() : TSBoolean; override;
		class function ClassName() : TSString; override;
			public
		procedure InitOrtho2d(const x0,y0,x1,y1:TSSingle);override;
		procedure InitMatrixMode(const Mode:TSMatrixMode = S_3D; const dncht : TSFloat = 1);override;
		procedure LoadIdentity();override;
		procedure Perspective(const vAngle,vAspectRatio,vNear,vFar : TSFloat);override;
		procedure Vertex3f(const x,y,z:single);override;
		procedure BeginScene(const VPrimitiveType:TSPrimtiveType);override;
		procedure EndScene();override;
		// Сохранения ресурсов рендера и завершение функционирования рендера
		procedure LockResources();override;
		// Инициализация рендера и загрузка сохраненных ресурсов
		procedure UnLockResources();override;

		procedure Color3f(const r,g,b:single);override;
		procedure TexCoord2f(const x,y:single);override;
		procedure Vertex2f(const x,y:single);override;
		procedure Scale(const x,y,z : TSSingle);override;
		procedure Color4f(const r,g,b,a:single);override;
		procedure Normal3f(const x,y,z:single);override;
		procedure Translatef(const x,y,z:single);override;
		procedure Rotatef(const angle:single;const x,y,z:single);override;
		procedure Enable(VParam:Cardinal);override;
		procedure Disable(const VParam:Cardinal);override;
		procedure DeleteTextures(const VQuantity:Cardinal;const VTextures:PSRenderTexture);override;
		procedure Lightfv(const VLight,VParam:Cardinal;const VParam2:Pointer);override;
		procedure GenTextures(const VQuantity:Cardinal;const VTextures:PSRenderTexture);override;
		procedure BindTexture(const VParam:Cardinal;const VTexture:Cardinal);override;
		procedure TexParameteri(const VP1,VP2,VP3:Cardinal);override;
		procedure PixelStorei(const VParamName:Cardinal;const VParam:TSInt32);override;
		procedure TexEnvi(const VP1,VP2,VP3:Cardinal);override;
		procedure TexImage2D(const VTextureType:Cardinal;const VP1:TSCardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;VBitMap:Pointer);override;
		procedure ReadPixels(const x,y:Integer;const Vwidth,Vheight:TSInteger;const format, atype: TSCardinal;const pixels: Pointer);override;
		procedure CullFace(const VParam:Cardinal);override;
		procedure EnableClientState(const VParam:TSCardinal);override;
		procedure DisableClientState(const VParam:TSCardinal);override;
		procedure GenBuffersARB(const VQ:TSInteger;const PT:PCardinal);override;
		procedure DeleteBuffersARB(const VQuantity:LongWord;VPoint:TSPointer);override;
		procedure BindBufferARB(const VParam:TSCardinal;const VParam2:TSCardinal);override;
		procedure BufferDataARB(const VParam:TSCardinal;const VSize:TSInt64;VBuffer:Pointer;const VParam2:Cardinal;const VIndexPrimetiveType : TSLongWord = 0);override;
		procedure DrawElements(const VParam:TSCardinal;const VSize:TSInt64;const VParam2:Cardinal;VBuffer:Pointer);override;
		procedure ColorPointer(const VQChannels:TSLongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);override;
		procedure TexCoordPointer(const VQChannels:TSLongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);override;
		procedure NormalPointer(const VType:TSCardinal;const VSize:TSInt64;VBuffer:TSPointer);override;
		procedure VertexPointer(const VQChannels:TSLongWord;const VType:TSCardinal;const VSize:TSInt64;VBuffer:TSPointer);override;
		function IsEnabled(const VParam:TSCardinal):TSBoolean;override;
		procedure Clear(const VParam:TSCardinal);override;
		procedure ClearColor(const r,g,b,a : TSFloat);override;
		procedure LineWidth(const VLW:TSSingle);override;
		procedure PointSize(const PS:TSSingle);override;
		procedure PushMatrix();override;
		procedure PopMatrix();override;
		procedure DrawArrays(const VParam:TSCardinal;const VFirst,VCount:TSLongWord);override;
		procedure Vertex3fv(const Variable : TSPointer);override;
		procedure Normal3fv(const Variable : TSPointer);override;
		procedure MultMatrixf(const Matrix : PSMatrix4x4);override;
		procedure ColorMaterial(const r,g,b,a : TSSingle);override;
		procedure MatrixMode(const Par:TSLongWord);override;
		procedure LoadMatrixf(const Matrix : PSMatrix4x4);override;
		procedure ClientActiveTexture(const VTexture : TSLongWord);override;
		procedure ActiveTexture(const VTexture : TSLongWord);override;
		procedure ActiveTextureDiffuse();override;
		procedure ActiveTextureBump();override;
		procedure BeginBumpMapping(const Point : Pointer );override;
		procedure EndBumpMapping();override;
		procedure PolygonOffset(const VFactor, VUnits : TSFloat);override;
		{$IFDEF MOBILE}
			procedure GenerateMipmap(const Param : TSCardinal);override;
		{$ELSE}
			procedure GetVertexUnderPixel(const px, py : LongWord; out x, y, z : Real);override;
			{$ENDIF}

			(* Shaders *)
		function SupportedShaders() : TSBoolean;override;
		function CreateShader(const VShaderType : TSCardinal):TSLongWord;override;
		procedure ShaderSource(const VShader : TSLongWord; VSource : PChar; VSourceLength : integer);override;
		procedure CompileShader(const VShader : TSLongWord);override;
		procedure GetObjectParameteriv(const VObject : TSLongWord; const VParamName : TSCardinal; const VResult : TSRPInteger);override;
		procedure GetInfoLog(const VHandle : TSLongWord; const VMaxLength : TSInteger; var VLength : TSInteger; VLog : PChar);override;
		procedure DeleteShader(const VProgram : TSLongWord);override;

		function CreateShaderProgram() : TSLongWord;override;
		procedure AttachShader(const VProgram, VShader : TSLongWord);override;
		procedure LinkShaderProgram(const VProgram : TSLongWord);override;
		procedure DeleteShaderProgram(const VProgram : TSLongWord);override;
		function GetUniformLocation(const VProgram : TSLongWord; const VLocationName : PChar): TSLongWord;override;
		procedure UseProgram(const VProgram : TSLongWord);override;
		procedure UniformMatrix4fv(const VLocationName : TSLongWord; const VCount : TSLongWord; const VTranspose : TSBoolean; const VData : PSMatrix4x4);override;
		procedure Uniform3f(const VLocationName : TSLongWord; const VX,VY,VZ : TSFloat);override;
		procedure Uniform1f(const VLocationName : TSLongWord; const V : TSFloat);override;
		procedure Uniform1iv (const VLocationName: TSLongWord; const VCount: TSLongWord; const VValue: Pointer);override;
		procedure Uniform1uiv (const VLocationName: TSLongWord; const VCount: TSLongWord; const VValue: Pointer);override;
		procedure Uniform3fv (const VLocationName: TSLongWord; const VCount: TSLongWord; const VValue: Pointer);override;
		procedure Uniform1i(const VLocationName : TSLongWord; const VData:TSLongWord);override;

		function SupportedDepthTextures():TSBoolean;override;
		procedure BindFrameBuffer(const VType : TSCardinal; const VHandle : TSLongWord);override;
		procedure GenFrameBuffers(const VCount : TSLongWord;const VBuffers : PCardinal); override;
		procedure DrawBuffer(const VType : TSCardinal);override;
		procedure ReadBuffer(const VType : TSCardinal);override;
		procedure GenRenderBuffers(const VCount : TSLongWord;const VBuffers : PCardinal); override;
		procedure BindRenderBuffer(const VType : TSCardinal; const VHandle : TSLongWord);override;
		procedure FrameBufferTexture2D(const VTarget: TSCardinal; const VAttachment: TSCardinal; const VRenderbuffertarget: TSCardinal; const VRenderbuffer, VLevel: TSLongWord);override;
		procedure FrameBufferRenderBuffer(const VTarget: TSCardinal; const VAttachment: TSCardinal; const VRenderbuffertarget: TSCardinal; const VRenderbuffer: TSLongWord);override;
		procedure RenderBufferStorage(const VTarget, VAttachment: TSCardinal; const VWidth, VHeight: TSLongWord);override;
		procedure GetFloatv(const VType : TSCardinal; const VPointer : Pointer);override;
			private
			(* Multitexturing *)
		FNowActiveNumberTexture : TSLongWord;

			(* Bump Mapping *)
		FNowInBumpMapping       : TSBoolean;

		{$IFDEF SINTERPRITATEBEGINEND}
			(* GLES BeginScene\EndScene*)
		FNowPrimetiveType  : TSLongWord;
		FNowNormal         : TSVertex3f;
		FNowColor          : TSColor4b;
		FNowTexCoord       : TSVertex2f;

		FFragmentInfo      : TSByte;

		FMaxLengthArPoints : TSLongWord;
		FNowPosArPoints    : TSInteger;
		FArPoints : packed array of
			packed record
				FVertex   : TSVertex3f;
				FNormal   : TSVertex3f;
				FTexCoord : TSVertex2f;
				FColor    : TSColor4b;
				end;

		FLightingEnabled : TSBoolean;
		FTextureEnabled  : TSBoolean;
		{$ENDIF}

		{$IFDEF NEEDResourceS}
			FArTextures : packed array of
				packed record
					FSaved : Boolean;
					FTexture : TSUInt32;
					end;
			FBindedTexture : TSLongWord;

			FArBuffers : packed array of
				packed record
					FSaved : Boolean;
					FBuffer : TSUInt32;
					end;
			FVBOData:packed array [0..1] of TSLongWord;
			// FVBOData[0] - SR_ARRAY_BUFFER_ARB
			// FVBOData[1] - SR_ELEMENT_ARRAY_BUFFER_ARB
			{$ENDIF}
			protected
		{$IFDEF MSWINDOWS}
		function SetRenderPixelFormatWinAPI() : TSBoolean;
		{$ENDIF}
		end;

//Эта функция позволяет задавать текущую (В зависимости от выбранной матрици процедурой glMatrixMode) матрицу
//в соответствии с типом TSMatrix4.
procedure SRGLSetMatrix(vMatrix : TSMatrix4x4);inline;

//Это функция - собственная замена gluPerspective.
procedure SRGLPerspective(const vAngle, vAspectRatio, vNear, vFar : TSMatrix4x4Type);inline;

//Эта функция - собственная замена gluLookAt в движке.
procedure SRGLLookAt(const Eve, At, Up : TSVertex3f);inline;

procedure SRGLOrtho(const l,r,b,t,vNear,vFar:TSMatrix4x4Type);inline;

implementation

uses
	 SmoothStringUtils
	,SmoothLog
	,SmoothFileUtils
	,SmoothBaseUtils
	{$IFDEF NEEDResourceS}
	,SmoothLists
	{$ENDIF}
	;

class function TSRenderOpenGL.RenderName() : TSString;
begin
Result := 
	{$IFNDEF MOBILE}
		'OpenGL'
	{$ELSE}
		'GLES'
		{$ENDIF}
	;
end;

class function TSRenderOpenGL.ClassName() : TSString;
begin
Result := 'TSRenderOpenGL';
end;

{$IFDEF RENDER_OGL_DEBUG_DYNLINK}
procedure TSRenderOpenGL_DynLinkError(const FunctionName : TSString);
var
	ErStr : TSString;
begin
ErStr := 'TSRenderOpenGL_DynLinkError : Abstract function "'+FunctionName+'"';
{.$IFDEF RENDER_OGL_DEBUG}
	WriteLn(ErStr);
	{.$ENDIF}
SLog.Source(ErStr);
end;
{$ENDIF}

class function TSRenderOpenGL.Supported() : TSBoolean;
begin
Result :=
	{$IFDEF MOBILE}
		True
	{$ELSE}
		DllManager.Supported('OpenGL')
	{$ENDIF}
	;
end;

procedure TSRenderOpenGL.Uniform1iv (const VLocationName: TSLongWord; const VCount: TSLongWord; const VValue: Pointer);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glUniform1iv = nil then TSRenderOpenGL_DynLinkError('glUniform1iv');{$ENDIF}
{$IF defined(MOBILE)}glUniform1i(VLocationName,PSLongInt(VValue)^){$ELSE}glUniform1iv(VLocationName,VCount,VValue){$ENDIF};
end;

procedure TSRenderOpenGL.Uniform1uiv (const VLocationName: TSLongWord; const VCount: TSLongWord; const VValue: Pointer);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glUniform1uiv = nil then TSRenderOpenGL_DynLinkError('glUniform1uiv');{$ENDIF}
{$IF defined(MOBILE)}glUniform1i(VLocationName,PSLongWord(VValue)^){$ELSE}glUniform1uiv(VLocationName,VCount,VValue){$ENDIF};
end;

procedure TSRenderOpenGL.Uniform3fv (const VLocationName: TSLongWord; const VCount: TSLongWord; const VValue: Pointer);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glUniform3fv = nil then TSRenderOpenGL_DynLinkError('glUniform3fv');{$ENDIF}
glUniform3fv(VLocationName,VCount,VValue);
end;

procedure TSRenderOpenGL.Uniform1f(const VLocationName : TSLongWord; const V : TSFloat);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glUniform1f = nil then TSRenderOpenGL_DynLinkError('glUniform1f');{$ENDIF}
glUniform1f(VLocationName,V);
end;

procedure TSRenderOpenGL.Uniform3f(const VLocationName : TSLongWord; const VX,VY,VZ : TSFloat);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glUniform3f = nil then TSRenderOpenGL_DynLinkError('glUniform3f');{$ENDIF}
glUniform3f(VLocationName,VX,VY,VZ);
end;

procedure TSRenderOpenGL.PolygonOffset(const VFactor, VUnits : TSFloat);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glPolygonOffset = nil then TSRenderOpenGL_DynLinkError('glPolygonOffset');{$ENDIF}
glPolygonOffset(VFactor,VUnits);
end;

procedure TSRenderOpenGL.GetFloatv(const VType : TSCardinal; const VPointer : Pointer);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glGetFloatv = nil then TSRenderOpenGL_DynLinkError('glGetFloatv');{$ENDIF}
glGetFloatv(VType, VPointer);
end;

procedure TSRenderOpenGL.Perspective(const vAngle,vAspectRatio,vNear,vFar : TSFloat);
begin
SRGLPerspective(vAngle,vAspectRatio,vNear,vFar);
end;

procedure TSRenderOpenGL.ClearColor(const r,g,b,a : TSFloat);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glClearColor = nil then TSRenderOpenGL_DynLinkError('glClearColor');{$ENDIF}
glClearColor(r,g,b,a);
end;

function TSRenderOpenGL.SupportedDepthTextures():TSBoolean;
begin
Result := {$IFDEF MOBILE} False {$ELSE} dglOpenGL.GL_ARB_texture_rg {$ENDIF};
{$IFDEF RENDER_OGL_DEBUG}
	SLog.Source(['TSRenderOpenGL.SupportedDepthTextures : Result = ',Result]);
	{$ENDIF}
end;

procedure TSRenderOpenGL.BindFrameBuffer(const VType : TSCardinal; const VHandle : TSLongWord);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glBindFramebufferEXT = nil then TSRenderOpenGL_DynLinkError('glBindFramebufferEXT');{$ENDIF}
{$IFNDEF MOBILE} glBindFramebufferEXT(VType,VHandle);{$ENDIF}
end;

procedure TSRenderOpenGL.GenFrameBuffers(const VCount : TSLongWord;const VBuffers : PCardinal);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glGenFrameBuffersEXT = nil then TSRenderOpenGL_DynLinkError('glGenFrameBuffersEXT');{$ENDIF}
{$IFNDEF MOBILE} glGenFrameBuffersEXT(VCount,VBuffers);{$ENDIF}
end;

procedure TSRenderOpenGL.DrawBuffer(const VType : TSCardinal);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glDrawBuffer = nil then TSRenderOpenGL_DynLinkError('glDrawBuffer');{$ENDIF}
{$IFNDEF MOBILE}glDrawBuffer(VType);{$ENDIF}
end;

procedure TSRenderOpenGL.ReadBuffer(const VType : TSCardinal);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glReadBuffer = nil then TSRenderOpenGL_DynLinkError('glReadBuffer');{$ENDIF}
{$IFNDEF MOBILE}glReadBuffer(VType);{$ENDIF}
end;

procedure TSRenderOpenGL.GenRenderBuffers(const VCount : TSLongWord;const VBuffers : PCardinal);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glGenRenderBuffersEXT = nil then TSRenderOpenGL_DynLinkError('glGenRenderBuffersEXT');{$ENDIF}
{$IFNDEF MOBILE}glGenRenderBuffersEXT(VCount,VBuffers);{$ENDIF}
end;

procedure TSRenderOpenGL.BindRenderBuffer(const VType : TSCardinal; const VHandle : TSLongWord);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glBindRenderBufferEXT = nil then TSRenderOpenGL_DynLinkError('glBindRenderBufferEXT');{$ENDIF}
{$IFNDEF MOBILE}glBindRenderBufferEXT(VType,VHandle);{$ENDIF}
end;

procedure TSRenderOpenGL.FrameBufferTexture2D(const VTarget: TSCardinal; const VAttachment: TSCardinal; const VRenderbuffertarget: TSCardinal; const VRenderbuffer,VLevel: TSLongWord);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glFrameBufferTexture2DEXT = nil then TSRenderOpenGL_DynLinkError('glFrameBufferTexture2DEXT');{$ENDIF}
{$IFNDEF MOBILE}glFrameBufferTexture2DEXT(VTarget,VAttachment,VRenderbuffertarget,VRenderbuffer,VLevel);{$ENDIF}
end;

procedure TSRenderOpenGL.FrameBufferRenderBuffer(const VTarget: TSCardinal; const VAttachment: TSCardinal; const VRenderbuffertarget: TSCardinal; const VRenderbuffer: TSLongWord);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glFrameBufferRenderBufferEXT = nil then TSRenderOpenGL_DynLinkError('glFrameBufferRenderBufferEXT');{$ENDIF}
{$IFNDEF MOBILE}glFrameBufferRenderBufferEXT(VTarget,VAttachment,VRenderbuffertarget,VRenderbuffer);{$ENDIF}
end;

procedure TSRenderOpenGL.RenderBufferStorage(const VTarget, VAttachment: TSCardinal; const VWidth, VHeight: TSLongWord);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glRenderBufferStorageEXT = nil then TSRenderOpenGL_DynLinkError('glRenderBufferStorageEXT');{$ENDIF}
{$IFNDEF MOBILE}glRenderBufferStorageEXT(VTarget,VAttachment,VWidth,VHeight);{$ENDIF}
end;

procedure TSRenderOpenGL.Scale(const x,y,z : TSSingle);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glScalef = nil then TSRenderOpenGL_DynLinkError('glScalef');{$ENDIF}
glScalef(x,y,z);
end;

procedure TSRenderOpenGL.Uniform1i(const VLocationName : TSLongWord; const VData:TSLongWord);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glUniform1iARB = nil then TSRenderOpenGL_DynLinkError('glUniform1iARB');{$ENDIF}
{$IFDEF MOBILE}glUniform1i{$ELSE}glUniform1iARB{$ENDIF}(VLocationName,VData);
end;

procedure TSRenderOpenGL.UseProgram(const VProgram : TSLongWord);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glUseProgramObjectARB = nil then TSRenderOpenGL_DynLinkError('glUseProgramObjectARB');{$ENDIF}
{$IFDEF MOBILE}glUseProgram{$ELSE}glUseProgramObjectARB{$ENDIF}({$IFDEF SHADERSISPOINTERS}Pointer(VProgram){$ELSE}VProgram{$ENDIF});
end;

procedure TSRenderOpenGL.UniformMatrix4fv(const VLocationName : TSLongWord; const VCount : TSLongWord; const VTranspose : TSBoolean; const VData : PSMatrix4x4);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glUniformMatrix4fv = nil then TSRenderOpenGL_DynLinkError('glUniformMatrix4fv');{$ENDIF}
glUniformMatrix4fv(VLocationName,VCount,{$IFNDEF USE_GLEXT}ByteBool{$ELSE}Byte{$ENDIF}(VTranspose), PSFloat(VData));
end;

function TSRenderOpenGL.GetUniformLocation(const VProgram : TSLongWord; const VLocationName : PChar): TSLongWord;
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glGetUniformLocationARB = nil then TSRenderOpenGL_DynLinkError('glGetUniformLocationARB');{$ENDIF}
{$IFDEF MOBILE}glGetUniformLocation{$ELSE}glGetUniformLocationARB{$ENDIF}({$IFDEF SHADERSISPOINTERS}Pointer(VProgram){$ELSE}VProgram{$ENDIF},VLocationName);
end;

function TSRenderOpenGL.SupportedShaders() : TSBoolean;
begin
Result := {$IFDEF MOBILE}False{$ELSE}dglOpenGL.GL_ARB_shader_objects{$ENDIF};
{$IFDEF RENDER_OGL_DEBUG}
	SLog.Source(['TSRenderOpenGL.SupportedShaders : Result = ',Result]);
	{$ENDIF}
end;

function TSRenderOpenGL.CreateShader(const VShaderType : TSCardinal):TSLongWord;
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glCreateShaderObjectARB = nil then TSRenderOpenGL_DynLinkError('glCreateShaderObjectARB');{$ENDIF}
Result :=
{$IFDEF SHADERSISPOINTERS} TSMaxEnum( {$ENDIF}
	{$IFNDEF MOBILE}glCreateShaderObjectARB{$ELSE}glCreateShader{$ENDIF}(VShaderType)
{$IFDEF SHADERSISPOINTERS} ) {$ENDIF} ;
end;

procedure TSRenderOpenGL.ShaderSource(const VShader : TSLongWord; VSource : PChar; VSourceLength : integer);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glShaderSourceARB = nil then TSRenderOpenGL_DynLinkError('glShaderSourceARB');{$ENDIF}
{$IFDEF MOBILE}glShaderSource{$ELSE}glShaderSourceARB{$ENDIF}({$IFDEF SHADERSISPOINTERS}Pointer(VShader){$ELSE}VShader{$ENDIF},1,@VSource,@VSourceLength);
end;

procedure TSRenderOpenGL.CompileShader(const VShader : TSLongWord);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glCompileShaderARB = nil then TSRenderOpenGL_DynLinkError('glCompileShaderARB');{$ENDIF}
{$IFDEF MOBILE}glCompileShader{$ELSE}glCompileShaderARB{$ENDIF}({$IFDEF SHADERSISPOINTERS}Pointer(VShader){$ELSE}VShader{$ENDIF});
end;

procedure TSRenderOpenGL.GetObjectParameteriv(const VObject : TSLongWord; const VParamName : TSCardinal; const VResult : TSRPInteger);
begin
//glGetProgramiv - GLES
//glGetShaderiv - GLES
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glGetObjectParameterivARB = nil then TSRenderOpenGL_DynLinkError('glGetObjectParameterivARB');{$ENDIF}
{$IFNDEF MOBILE}glGetObjectParameterivARB({$IFDEF SHADERSISPOINTERS}Pointer(VObject){$ELSE}VObject{$ENDIF},VParamName,VResult);{$ENDIF}
end;

procedure TSRenderOpenGL.GetInfoLog(const VHandle : TSLongWord; const VMaxLength : TSInteger; var VLength : TSInteger; VLog : PChar);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glGetInfoLogARB = nil then TSRenderOpenGL_DynLinkError('glGetInfoLogARB');{$ENDIF}
//glGetShaderInfoLog - GLES
//glGetProgramInfoLog - GLES
{$IFNDEF MOBILE}glGetInfoLogARB({$IFDEF SHADERSISPOINTERS}Pointer(VHandle){$ELSE}VHandle{$ENDIF},VMaxLength,{$IFDEF USE_GLEXT}@{$ENDIF}VLength,VLog);{$ENDIF}
end;


function TSRenderOpenGL.CreateShaderProgram() : TSLongWord;
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glCreateProgramObjectARB = nil then TSRenderOpenGL_DynLinkError('glCreateProgramObjectARB');{$ENDIF}
Result :=
{$IFDEF SHADERSISPOINTERS} TSMaxEnum( {$ENDIF}
	{$IFDEF MOBILE}glCreateProgram{$ELSE}glCreateProgramObjectARB{$ENDIF}()
{$IFDEF SHADERSISPOINTERS} ) {$ENDIF} ;
end;

procedure TSRenderOpenGL.AttachShader(const VProgram, VShader : TSLongWord);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glAttachObjectARB = nil then TSRenderOpenGL_DynLinkError('glAttachObjectARB');{$ENDIF}
{$IFDEF MOBILE}glAttachShader{$ELSE}glAttachObjectARB{$ENDIF}({$IFDEF SHADERSISPOINTERS}Pointer(VProgram){$ELSE}VProgram{$ENDIF},{$IFDEF SHADERSISPOINTERS}Pointer(VShader){$ELSE}VShader{$ENDIF});
end;

procedure TSRenderOpenGL.LinkShaderProgram(const VProgram : TSLongWord);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glLinkProgramARB = nil then TSRenderOpenGL_DynLinkError('glLinkProgramARB');{$ENDIF}
{$IFNDEF MOBILE}glLinkProgramARB{$ELSE}glLinkProgram{$ENDIF}({$IFDEF SHADERSISPOINTERS}Pointer(VProgram){$ELSE}VProgram{$ENDIF});
end;

procedure TSRenderOpenGL.DeleteShader(const VProgram : TSLongWord);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glDeleteShader = nil then TSRenderOpenGL_DynLinkError('glDeleteShader');{$ENDIF}
glDeleteShader(VProgram);
end;

procedure TSRenderOpenGL.DeleteShaderProgram(const VProgram : TSLongWord);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glDeleteProgram = nil then TSRenderOpenGL_DynLinkError('glDeleteProgram');{$ENDIF}
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
procedure TSRenderOpenGL.GenerateMipmap(const Param : TSCardinal);
begin
//glGenerateMipmap(Param);
end;
{$ELSE}
procedure TSRenderOpenGL.GetVertexUnderPixel(const px,py : LongWord; out x,y,z : Real);
var
	depth:Single;
	viewportarray:array [0..3] of GLint;
	mv_matrix,proj_matrix:TGLMatrixd4;
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glGetIntegerv = nil then TSRenderOpenGL_DynLinkError('glGetIntegerv');{$ENDIF}
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glReadPixels = nil then TSRenderOpenGL_DynLinkError('glReadPixels');{$ENDIF}
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glGetDoublev = nil then TSRenderOpenGL_DynLinkError('glGetDoublev');{$ENDIF}
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if gluUnProject = nil then TSRenderOpenGL_DynLinkError('gluUnProject');{$ENDIF}
glGetIntegerv(GL_VIEWPORT,viewportarray);
glReadPixels(
	px,
	LongInt(Context.Width)-LongInt(py)-1,
	1,
	1,
	GL_DEPTH_COMPONENT,
	GL_FLOAT,
	@depth);
glGetDoublev(GL_MODELVIEW_MATRIX,@mv_matrix);
glGetDoublev(GL_PROJECTION_MATRIX,@proj_matrix);
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

procedure TSRenderOpenGL.EndBumpMapping();
begin
FNowInBumpMapping := False;
end;

procedure TSRenderOpenGL.BeginBumpMapping(const Point : Pointer );
var
	v : TSVertex3f;
begin
v:=TSVertex3f(Point^);
v := v.Normalized();
Color4f(
	v.x *0.5 + 0.5,
	v.y *0.5 + 0.5,
	v.z *0.5 + 0.5,1);
FNowInBumpMapping := True;
end;

procedure TSRenderOpenGL.ActiveTextureDiffuse();
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glTexEnvi = nil then TSRenderOpenGL_DynLinkError('glTexEnvi');{$ENDIF}
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

procedure TSRenderOpenGL.ActiveTextureBump();
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glTexEnvi = nil then TSRenderOpenGL_DynLinkError('glTexEnvi');{$ENDIF}
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

procedure TSRenderOpenGL.ActiveTexture(const VTexture : TSLongWord);
begin
FNowActiveNumberTexture := VTexture;
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glActiveTextureARB = nil then TSRenderOpenGL_DynLinkError('glActiveTextureARB');{$ENDIF}
{$IFDEF MOBILE}glActiveTexture{$ELSE}glActiveTextureARB{$ENDIF}(GL_TEXTURE0 + VTexture);
end;

procedure TSRenderOpenGL.ClientActiveTexture(const VTexture : TSLongWord);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glClientActiveTextureARB = nil then TSRenderOpenGL_DynLinkError('glClientActiveTextureARB');{$ENDIF}
{$IFDEF MOBILE}glClientActiveTexture{$ELSE}glClientActiveTextureARB{$ENDIF}(GL_TEXTURE0 + VTexture);
end;

procedure TSRenderOpenGL.ColorMaterial(const r,g,b,a : TSSingle);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glColor4f = nil then TSRenderOpenGL_DynLinkError('glColor4f');{$ENDIF}
glColor4f(r,g,b,a);
end;

procedure SRGLOrtho(const l,r,b,t,vNear,vFar:TSMatrix4x4Type);inline;
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glMatrixMode = nil then TSRenderOpenGL_DynLinkError('glMatrixMode');{$ENDIF}
glMatrixMode(GL_PROJECTION);
SRGLSetMatrix(SGetOrthoMatrix(l,r,b,t,vNear,vFar));
end;

procedure TSRenderOpenGL.Vertex3fv(const Variable : TSPointer);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glVertex3fv = nil then TSRenderOpenGL_DynLinkError('glVertex3fv');{$ENDIF}
{$IFNDEF MOBILE}
	glVertex3fv(Variable);
{$ELSE}
	Vertex3f(PSingle(Variable)[0],PSingle(Variable)[1],PSingle(Variable)[2]);
	{$ENDIF}
end;

procedure TSRenderOpenGL.Normal3fv(const Variable : TSPointer);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glNormal3fv = nil then TSRenderOpenGL_DynLinkError('glNormal3fv');{$ENDIF}
{$IFNDEF MOBILE}
	glNormal3fv(Variable);
{$ELSE}
	Normal3f(PSingle(Variable)[0],PSingle(Variable)[1],PSingle(Variable)[2]);
	{$ENDIF}
end;

procedure TSRenderOpenGL.LoadMatrixf(const Matrix : PSMatrix4x4);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glLoadMatrixf = nil then TSRenderOpenGL_DynLinkError('glLoadMatrixf');{$ENDIF}
glLoadMatrixf(PGLFloat(Matrix));
end;

procedure TSRenderOpenGL.MultMatrixf(const Matrix : PSMatrix4x4);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glMultMatrixf = nil then TSRenderOpenGL_DynLinkError('glMultMatrixf');{$ENDIF}
glMultMatrixf(PGLFloat(Matrix));
end;

procedure TSRenderOpenGL.PushMatrix();
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glPushMatrix = nil then TSRenderOpenGL_DynLinkError('glPushMatrix');{$ENDIF}
glPushMatrix();
end;

procedure TSRenderOpenGL.PopMatrix();
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glPopMatrix = nil then TSRenderOpenGL_DynLinkError('glPopMatrix');{$ENDIF}
glPopMatrix();
end;

procedure SRGLLookAt(const Eve,At,Up:TSVertex3f);inline;
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glMatrixMode = nil then TSRenderOpenGL_DynLinkError('glMatrixMode');{$ENDIF}
glMatrixMode(GL_PROJECTION);
SRGLSetMatrix(SGetLookAtMatrix(Eve,At,Up));
end;

procedure SRGLPerspective(const vAngle, vAspectRatio, vNear, vFar : TSMatrix4x4Type);inline;
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glMatrixMode = nil then TSRenderOpenGL_DynLinkError('glMatrixMode');{$ENDIF}
glMatrixMode(GL_PROJECTION);
SRGLSetMatrix(SGetPerspectiveMatrix(vAngle,vAspectRatio,vNear,vFar));
end;

procedure SRGLSetMatrix( vMatrix:TSMatrix4x4);inline;
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glLoadMatrixf = nil then TSRenderOpenGL_DynLinkError('glLoadMatrixf');{$ENDIF}
glLoadMatrixf(@vMatrix);
end;

procedure TSRenderOpenGL.DrawArrays(const VParam:TSCardinal;const VFirst,VCount:TSLongWord);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glDrawArrays = nil then TSRenderOpenGL_DynLinkError('glDrawArrays');{$ENDIF}
glDrawArrays(VParam,VFirst,VCount);
end;

procedure TSRenderOpenGL.SwapBuffers();
begin
{$IFDEF MSWINDOWS}
	Windows.SwapBuffers( TSMaxEnum(Context.Device) );
{$ELSE}
	{$IFDEF LINUX}
		glXSwapBuffers(
			PDisplay(Context.Device),
			TSMaxEnum(Context.Window));
	{$ELSE}
		{$IFDEF ANDROID}
			eglSwapBuffers(Context.Device,Context.GetOption('SURFACE'));
		{$ELSE}
			{$IFDEF DARWIN}
				aglSwapBuffers( FContext );
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
	{$ENDIF}
end;

function TSRenderOpenGL.SupportedMemoryBuffers() : TSBoolean;
begin
{$IFDEF MOBILE}
	Result := True;
{$ELSE}
	Result := dglOpenGL.GL_VERSION_1_1;
	{$ENDIF}
{$IFDEF RENDER_OGL_DEBUG}
	SLog.Source(['TSRenderOpenGL__SupportedMemoryBuffers : Result = ', Result]);
	{$ENDIF}
end;

function TSRenderOpenGL.SupportedGraphicalBuffers() : TSBoolean;
begin
{$IFDEF MOBILE}
	Result := True;
{$ELSE}
	Result := dglOpenGL.GL_ARB_vertex_buffer_object;
	{$ENDIF}
{$IFDEF RENDER_OGL_DEBUG}
	SLog.Source(['TSRenderOpenGL__SupportedGraphicalBuffers : Result = ', Result]);
	{$ENDIF}
end;

procedure TSRenderOpenGL.PointSize(const PS:Single);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glPointSize = nil then TSRenderOpenGL_DynLinkError('glPointSize');{$ENDIF}
glPointSize(PS);
end;

procedure TSRenderOpenGL.LineWidth(const VLW:Single);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glLineWidth = nil then TSRenderOpenGL_DynLinkError('glLineWidth');{$ENDIF}
glLineWidth(VLW);
end;

procedure TSRenderOpenGL.Vertex3f(const x,y,z:single);
begin
{$IF (not defined(MOBILE)) and (not defined(SINTERPRITATEBEGINEND))}
	{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glVertex3f = nil then TSRenderOpenGL_DynLinkError('glVertex3f');{$ENDIF}
	glVertex3f(x,y,z);
	{$ENDIF}
{$IFDEF SINTERPRITATEBEGINEND}
	{$IFDEF MOBILE}
	if (FNowPrimetiveType=SR_QUADS) and (FFragmentInfo=1) then
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
			if (FNowPrimetiveType = SR_QUADS) and (FNowPosArPoints mod 3 = 2) then
				begin
				FFragmentInfo := 1;
				end;
		end;
			{$ENDIF}
	{$ENDIF}
end;

procedure TSRenderOpenGL.Color3f(const r,g,b:single);
begin
{$IFNDEF SINTERPRITATEBEGINEND}
	{$IFNDEF MOBILE}
		if IsEnabled(GL_BLEND) then
			begin
			{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glColor4f = nil then TSRenderOpenGL_DynLinkError('glColor4f');{$ENDIF}
			glColor4f(r,g,b,1);
			end
		else
			begin
			{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glColor3f = nil then TSRenderOpenGL_DynLinkError('glColor3f');{$ENDIF}
			glColor3f(r,g,b);
			end;
	{$ELSE}
		glColor4f(r,g,b,1)
		{$ENDIF}
{$ELSE}
	Color4f(r,g,b,1);
	{$ENDIF}
end;

procedure TSRenderOpenGL.TexCoord2f(const x,y:single);
begin
{$IF (not defined(MOBILE)) and (not defined(SINTERPRITATEBEGINEND))}
	{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glTexCoord2f = nil then TSRenderOpenGL_DynLinkError('glTexCoord2f');{$ENDIF}
	glTexCoord2f(x,y);
	{$ENDIF}
{$IFDEF SINTERPRITATEBEGINEND}
	FNowTexCoord.Import(x,y);
	{$ENDIF}
end;

procedure TSRenderOpenGL.Vertex2f(const x,y:single);
begin
{$IF (not defined(MOBILE)) and (not defined(SINTERPRITATEBEGINEND))}
	{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glVertex2f = nil then TSRenderOpenGL_DynLinkError('glVertex2f');{$ENDIF}
	glVertex2f(x,y);
{$ELSE}
	Vertex3f(x,y,0);
	{$ENDIF}
end;

procedure TSRenderOpenGL.Color4f(const r,g,b,a:single);
begin
{$IF (not defined(MOBILE)) and (not defined(SINTERPRITATEBEGINEND))}
	{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glColor4f = nil then TSRenderOpenGL_DynLinkError('glColor4f');{$ENDIF}
	glColor4f(r,g,b,a);
	{$ENDIF}
{$IFDEF SINTERPRITATEBEGINEND}
	FNowColor.Import(
		Byte(b>=1)*255+Byte((b<1) and (b>0))*round(255*b),
		Byte(g>=1)*255+Byte((g<1) and (g>0))*round(255*g),
		Byte(r>=1)*255+Byte((r<1) and (r>0))*round(255*r),
		Byte(a>=1)*255+Byte((a<1) and (a>0))*round(255*a))
	{$ENDIF}
end;

procedure TSRenderOpenGL.Normal3f(const x,y,z:single);
begin
{$IF (not defined(MOBILE)) and (not defined(SINTERPRITATEBEGINEND))}
	{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glNormal3f = nil then TSRenderOpenGL_DynLinkError('glNormal3f');{$ENDIF}
	glNormal3f(x,y,z);
	{$ENDIF}
{$IFDEF SINTERPRITATEBEGINEND}
	FNowNormal.Import(x,y,z);
	{$ENDIF}
end;

procedure TSRenderOpenGL.BeginScene(const VPrimitiveType:TSPrimtiveType);
begin
{$IF (not defined(MOBILE)) and (not defined(SINTERPRITATEBEGINEND))}
	{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glBegin = nil then TSRenderOpenGL_DynLinkError('glBegin');{$ENDIF}
	glBegin(VPrimitiveType);
	{$ENDIF}
{$IFDEF SINTERPRITATEBEGINEND}
	FNowPrimetiveType := VPrimitiveType;
	FNowPosArPoints   := -1;
	FFragmentInfo     := 0;
	{$ENDIF}
end;

procedure TSRenderOpenGL.EndScene();
{$IF defined(SINTERPRITATEBEGINENDWITHVBO) and defined(SINTERPRITATEBEGINEND)}
	var
		FBuffer : TSLongWord;
	{$ENDIF}
begin
{$IF (not defined(MOBILE)) and (not defined(SINTERPRITATEBEGINEND))}
	{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glEnd = nil then TSRenderOpenGL_DynLinkError('glEnd');{$ENDIF}
	glEnd();
	{$ENDIF}
{$IFDEF SINTERPRITATEBEGINEND}
	{$IFDEF SINTERPRITATEBEGINENDWITHVBO}
		{$IFNDEF MOBILE}glGenBuffersARB{$ELSE}glGenBuffers{$ENDIF}(1,@FBuffer);
		{$IFNDEF MOBILE}glBindBufferARB{$ELSE}glBindBuffer{$ENDIF}(SR_ARRAY_BUFFER_ARB,FBuffer);
		{$IFNDEF MOBILE}glBufferDataARB{$ELSE}glBufferData{$ENDIF}(SR_ARRAY_BUFFER_ARB,SizeOf(FArPoints[0])*(FNowPosArPoints+1),@FArPoints[0], SR_STATIC_DRAW_ARB);
		{$IFNDEF MOBILE}glBindBufferARB{$ELSE}glBindBuffer{$ENDIF}(SR_ARRAY_BUFFER_ARB,FBuffer);
		{$ENDIF}
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_COLOR_ARRAY);
	if FLightingEnabled then
	glEnableClientState(GL_NORMAL_ARRAY);
	if FTextureEnabled then
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glVertexPointer  (3, GL_FLOAT,          SizeOf(FArPoints[0]),
		{$IFDEF SINTERPRITATEBEGINENDWITHVBO}nil{$ELSE}@FArPoints[0].FVertex{$ENDIF});
	glColorPointer   (4, GL_UNSIGNED_BYTE,  SizeOf(FArPoints[0]),
		{$IFDEF SINTERPRITATEBEGINENDWITHVBO}
			TSPointer(TSMaxEnum(@FArPoints[0].FColor)   -TSMaxEnum(@FArPoints[0].FVertex))
				{$ELSE}@FArPoints[0].FColor{$ENDIF});
	if FTextureEnabled then
	glTexCoordPointer(2, GL_FLOAT,          SizeOf(FArPoints[0]),
		{$IFDEF SINTERPRITATEBEGINENDWITHVBO}
			TSPointer(TSMaxEnum(@FArPoints[0].FTexCoord)-TSMaxEnum(@FArPoints[0].FVertex))
				{$ELSE}@FArPoints[0].FTexCoord{$ENDIF});
	if FLightingEnabled then
	glNormalPointer  (   GL_FLOAT,          SizeOf(FArPoints[0]),
		{$IFDEF SINTERPRITATEBEGINENDWITHVBO}
			TSPointer(TSMaxEnum(@FArPoints[0].FNormal) -TSMaxEnum(@FArPoints[0].FVertex))
				{$ELSE}@FArPoints[0].FNormal{$ENDIF});

	{$IFDEF MOBILE}
		if FNowPrimetiveType = SR_QUADS then
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
	{$IFDEF SINTERPRITATEBEGINENDWITHVBO}
		{$IFNDEF MOBILE}glDeleteBuffersARB{$ELSE}glDeleteBuffers{$ENDIF}(1, @FBuffer);
		{$IFNDEF MOBILE}glBindBufferARB{$ELSE}glBindBuffer{$ENDIF}(SR_ARRAY_BUFFER_ARB,0);
		{$ENDIF}
	{$ENDIF}
end;

procedure TSRenderOpenGL.Translatef(const x, y, z : TSSingle);
{$IF defined(INTERPRITATEROTATETRANSLATE)}
var
	Matrix : TSMatrix4x4;
{$ENDIF}
begin
{$IF not defined(INTERPRITATEROTATETRANSLATE)}
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glTranslatef = nil then TSRenderOpenGL_DynLinkError('glTranslatef');{$ENDIF}
glTranslatef(x, y, z);
{$ELSE}
Matrix := STranslateMatrix(SVertex3fImport(x, y, z));
MultMatrixf(@Matrix);
{$ENDIF}
end;

procedure TSRenderOpenGL.Rotatef(const Angle : TSSingle; const x, y, z : TSSingle);
{$IF defined(INTERPRITATEROTATETRANSLATE)}
const
	DEG2RAD = PI/180;
var
	Matrix : TSMatrix4x4;
{$ENDIF}
begin
{$IF not defined(INTERPRITATEROTATETRANSLATE)}
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glRotatef = nil then TSRenderOpenGL_DynLinkError('glRotatef');{$ENDIF}
glRotatef(angle,x,y,z);
{$ELSE}
Matrix := SRotateMatrix(Angle * DEG2RAD, SVertex3fImport(x, y, z));
MultMatrixf(@Matrix);
{$ENDIF}
end;

procedure TSRenderOpenGL.Enable(VParam:Cardinal);
begin
{$IFDEF SINTERPRITATEBEGINEND}
	case VParam of
	GL_LIGHTING   : FLightingEnabled := True;
	GL_TEXTURE_2D : FTextureEnabled := True;
	end;
	{$ENDIF}
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glEnable = nil then TSRenderOpenGL_DynLinkError('glEnable');{$ENDIF}
glEnable(VParam);
end;

procedure TSRenderOpenGL.Disable(const VParam:Cardinal);
begin
{$IFDEF SINTERPRITATEBEGINEND}
	case VParam of
	GL_LIGHTING   : FLightingEnabled := False;
	GL_TEXTURE_2D : FTextureEnabled := False;
	end;
	{$ENDIF}
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glDisable = nil then TSRenderOpenGL_DynLinkError('glDisable');{$ENDIF}
glDisable(VParam);
end;

procedure TSRenderOpenGL.DeleteTextures(const VQuantity:Cardinal;const VTextures:PSRenderTexture);
{$IFDEF NEEDResourceS}
var
	i : LongWord;
{$ENDIF}
begin
{$IFDEF NEEDResourceS}
for i:=0 to VQuantity-1 do
	begin
	if FArTextures[VTextures[i]-1].FSaved then
		begin
		if FileExists(TempDir+'/t'+SStr(VTextures[i]-1)) then
			DeleteFile(TempDir+'/t'+SStr(VTextures[i]-1));
		FArTextures[VTextures[i]-1].FSaved:=False;
		end;
	glDeleteTextures(1,@FArTextures[VTextures[i]-1].FTexture);
	FArTextures[VTextures[i]-1].FTexture:=0;
	end;
{$ELSE}
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glDeleteTextures = nil then TSRenderOpenGL_DynLinkError('glDeleteTextures');{$ENDIF}
glDeleteTextures(VQuantity,VTextures);
{$ENDIF}
end;

procedure TSRenderOpenGL.Lightfv(const VLight,VParam:Cardinal;const VParam2:Pointer);
type
	PSingle = ^ Single;
var
	Ar:TSPointer = nil;
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glLightfv = nil then TSRenderOpenGL_DynLinkError('glLightfv');{$ENDIF}
if VParam=SR_POSITION then
	begin
	System.GetMem(Ar,4*Sizeof(TSSingle));
	System.Move(VParam2^,Ar^,3*Sizeof(TSSingle));
	PSingle(Ar)[3]:=1;
	glLightfv(VLight,VParam,Ar);
	System.FreeMem(Ar,4*Sizeof(TSSingle));
	end
else
	glLightfv(VLight,VParam,VParam2);
end;

procedure TSRenderOpenGL.GenTextures(const VQuantity:Cardinal;const VTextures:PSRenderTexture);
{$IFDEF NEEDResourceS}
var
	i : TSMaxEnum;
	{$ENDIF}
begin
{$IFDEF NEEDResourceS}
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
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glGenTextures = nil then TSRenderOpenGL_DynLinkError('glGenTextures');{$ENDIF}
glGenTextures(VQuantity,VTextures);
{$ENDIF}
end;

procedure TSRenderOpenGL.BindTexture(const VParam:Cardinal;const VTexture:Cardinal);
begin
{$IFDEF NEEDResourceS}
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
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glBindTexture = nil then TSRenderOpenGL_DynLinkError('glBindTexture');{$ENDIF}
glBindTexture(VParam,VTexture);
{$ENDIF}
end;

procedure TSRenderOpenGL.TexParameteri(const VP1,VP2,VP3:Cardinal);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glTexParameteri = nil then TSRenderOpenGL_DynLinkError('glTexParameteri');{$ENDIF}
glTexParameteri(VP1,VP2,VP3);
end;

procedure TSRenderOpenGL.PixelStorei(const VParamName:Cardinal;const VParam:TSInt32);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glPixelStorei = nil then TSRenderOpenGL_DynLinkError('glPixelStorei');{$ENDIF}
glPixelStorei(VParamName,VParam);
end;

procedure TSRenderOpenGL.TexEnvi(const VP1,VP2,VP3:Cardinal);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glTexEnvi = nil then TSRenderOpenGL_DynLinkError('glTexEnvi');{$ENDIF}
glTexEnvi(VP1,VP2,VP3);
end;

procedure TSRenderOpenGL.TexImage2D(const VTextureType:Cardinal;const VP1:Cardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:Cardinal;VBitMap:Pointer);
{$IFDEF NEEDResourceS}
var
	FS : TFileStream = nil;
{$ENDIF}
begin
{$IFDEF NEEDResourceS}
FS := TFileStream.Create(TempDir+'/t'+SStr(FBindedTexture),fmCreate);
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
SLog.Source('TSRenderOpenGL__TexImage2D: Saved: "'+TempDir+'/t'+SStr(FBindedTexture)+'": W='+SStr(VWidth)+', H='+SStr(VHeight)+', C='+SStr(VChannels)+'.');
{$ENDIF}
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glTexImage2D = nil then TSRenderOpenGL_DynLinkError('glTexImage2D');{$ENDIF}
glTexImage2D(VTextureType,VP1,{$IFDEF MOBILE}VFormatType{$ELSE}VChannels{$ENDIF},VWidth,VHeight,VP2,VFormatType,VDataType,VBitMap);
end;

procedure TSRenderOpenGL.ReadPixels(const x,y:Integer;const Vwidth,Vheight:Integer;const format, atype: Cardinal;const pixels: Pointer);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glReadPixels = nil then TSRenderOpenGL_DynLinkError('glReadPixels');{$ENDIF}
glReadPixels(x,y,Vwidth,Vheight,format, atype,pixels);
end;

procedure TSRenderOpenGL.CullFace(const VParam:Cardinal);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glCullFace = nil then TSRenderOpenGL_DynLinkError('glCullFace');{$ENDIF}
glCullFace(VParam);
end;

procedure TSRenderOpenGL.EnableClientState(const VParam:Cardinal);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glEnableClientState = nil then TSRenderOpenGL_DynLinkError('glEnableClientState');{$ENDIF}
glEnableClientState(VParam);
end;

procedure TSRenderOpenGL.DisableClientState(const VParam:Cardinal);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glDisableClientState = nil then TSRenderOpenGL_DynLinkError('glDisableClientState');{$ENDIF}
glDisableClientState(VParam);
end;

procedure TSRenderOpenGL.GenBuffersARB(const VQ:Integer;const PT:PCardinal);
{$IFDEF NEEDResourceS}
var
	i : LongWord;
{$ENDIF}
begin
{$IFDEF NEEDResourceS}
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
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glGenBuffersARB = nil then TSRenderOpenGL_DynLinkError('glGenBuffersARB');{$ENDIF}
{$IFNDEF MOBILE}glGenBuffersARB{$ELSE}glGenBuffers{$ENDIF}(VQ,PT);
{$ENDIF}
end;

procedure TSRenderOpenGL.DeleteBuffersARB(const VQuantity:LongWord;VPoint:Pointer);
{$IFDEF NEEDResourceS}
var
	i : LongWord;
{$ENDIF}
begin
{$IFDEF NEEDResourceS}
for i:=0 to VQuantity-1 do
	begin
	{$IFNDEF MOBILE}glDeleteBuffersARB{$ELSE}glDeleteBuffers{$ENDIF}(1,@FArBuffers[PCardinal(VPoint)[i]-1].FBuffer);
	FArBuffers[PCardinal(VPoint)[i]-1].FBuffer:=0;
	if SFileExists(TempDir+'/b'+SStr(PCardinal(VPoint)[i]-1)) then
		DeleteFile (TempDir+'/b'+SStr(PCardinal(VPoint)[i]-1));
	FArBuffers[PCardinal(VPoint)[i]-1].FSaved:=False;
	end;
{$ELSE}
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glDeleteBuffersARB = nil then TSRenderOpenGL_DynLinkError('glDeleteBuffersARB');{$ENDIF}
{$IFNDEF MOBILE}glDeleteBuffersARB{$ELSE}glDeleteBuffers{$ENDIF}(VQuantity,VPoint);
{$ENDIF}
end;

procedure TSRenderOpenGL.BindBufferARB(const VParam:Cardinal;const VParam2:Cardinal);
begin
{$IFDEF NEEDResourceS}
case VParam of
SR_ARRAY_BUFFER_ARB : FVBOData[0] := VParam2-1;
SR_ELEMENT_ARRAY_BUFFER_ARB : FVBOData[1] := VParam2-1;
end;
if VParam2 = 0 then
	{$IFNDEF MOBILE}glBindBufferARB{$ELSE}glBindBuffer{$ENDIF}(VParam,0)
else
	{$IFNDEF MOBILE}glBindBufferARB{$ELSE}glBindBuffer{$ENDIF}(VParam,FArBuffers[VParam2-1].FBuffer);
{$ELSE}
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glBindBufferARB = nil then TSRenderOpenGL_DynLinkError('glBindBufferARB');{$ENDIF}
{$IFNDEF MOBILE}glBindBufferARB{$ELSE}glBindBuffer{$ENDIF}(VParam,VParam2);
{$ENDIF}
end;

procedure TSRenderOpenGL.BufferDataARB(const VParam:Cardinal;const VSize:int64;VBuffer:Pointer;const VParam2:Cardinal;const VIndexPrimetiveType : TSLongWord = 0);
{$IFDEF NEEDResourceS}
var
	FS : TFileStream = nil;
	i : Cardinal;
	ii : TSQuadWord;
{$ENDIF}
begin
{$IFDEF NEEDResourceS}
i := Byte(VParam = SR_ARRAY_BUFFER_ARB)*FVBOData[0]+Byte(VParam = SR_ELEMENT_ARRAY_BUFFER_ARB)*FVBOData[1];
FS := TFileStream.Create(TempDir+'/b'+SStr(i),fmCreate);
ii:= VParam;
FS.WriteBuffer(ii,SizeOf(ii));
ii := VSize;
FS.WriteBuffer(ii,SizeOf(ii));
ii := VParam2;
FS.WriteBuffer(ii,SizeOf(ii));
FS.WriteBuffer(VBuffer^,VSize);
FS.Destroy();
FArBuffers[i].FSaved := True;
SLog.Source('TSRenderOpenGL__BufferDataARB: Saved: "'+TempDir+'/b'+SStr(i)+'", Size='+SStr(VSize)+'.');
{$ENDIF}
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glBufferDataARB = nil then TSRenderOpenGL_DynLinkError('glBufferDataARB');{$ENDIF}
{$IFNDEF MOBILE}glBufferDataARB{$ELSE}glBufferData{$ENDIF}(VParam,VSize,VBuffer,VParam2);
end;

procedure TSRenderOpenGL.DrawElements(const VParam:TSCardinal;const VSize:TSInt64;const VParam2:Cardinal;VBuffer:Pointer);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glDrawElements = nil then TSRenderOpenGL_DynLinkError('glDrawElements');{$ENDIF}
glDrawElements(VParam,VSize,VParam2,VBuffer);
end;

procedure TSRenderOpenGL.ColorPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glColorPointer = nil then TSRenderOpenGL_DynLinkError('glColorPointer');{$ENDIF}
glColorPointer(VQChannels,VType,VSize,VBuffer);
end;

procedure TSRenderOpenGL.TexCoordPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glTexCoordPointer = nil then TSRenderOpenGL_DynLinkError('glTexCoordPointer');{$ENDIF}
glTexCoordPointer(VQChannels,VType,VSize,VBuffer);
end;

procedure TSRenderOpenGL.NormalPointer(const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glNormalPointer = nil then TSRenderOpenGL_DynLinkError('glNormalPointer');{$ENDIF}
glNormalPointer(VType,VSize,VBuffer);
end;

procedure TSRenderOpenGL.VertexPointer(const VQChannels:LongWord;const VType:Cardinal;const VSize:Int64;VBuffer:Pointer);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glVertexPointer = nil then TSRenderOpenGL_DynLinkError('glVertexPointer');{$ENDIF}
glVertexPointer(VQChannels,VType,VSize,VBuffer);
end;

function TSRenderOpenGL.IsEnabled(const VParam:Cardinal):Boolean;
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glIsEnabled = nil then TSRenderOpenGL_DynLinkError('glIsEnabled');{$ENDIF}
glIsEnabled(VParam);
end;

procedure TSRenderOpenGL.Clear(const VParam:Cardinal);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glClear = nil then TSRenderOpenGL_DynLinkError('glClear');{$ENDIF}
glClear(VParam);
end;

procedure TSRenderOpenGL.Init();
var
	AmbientLight : array[0..3] of glFloat = (0.5,0.5,0.5,1.0);
	DiffuseLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
	SpecularLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
	SpecularReflection : array[0..3] of glFloat = (0.4,0.4,0.4,1.0);
	TempLightPosition : array[0..3] of glFloat = (0,1,0,2);
	fogColor:array[0..3] of glFloat = (0,0,0,1);
begin
{$IFDEF RENDER_OGL_DEBUG}
	WriteLn(ClassName(), '__Init: Begining.');
	{$ENDIF}
FNowInBumpMapping:=False;

{$IFNDEF MOBILE}
{$IFDEF RENDER_OGL_DEBUG}
	WriteLn(ClassName(), '__Init: Begin ReadExtensions.');
	{$ENDIF}
if DllManager.Dll('OpenGL') <> nil then
	DllManager.Dll('OpenGL').ReadExtensions();
{$IFDEF RENDER_OGL_DEBUG}
	WriteLn(ClassName(), '__Init: End ReadExtensions.');
	{$ENDIF}
{$ENDIF}

{$IFDEF MSWINDOWS}
SLog.Source([ClassName(), '__Init: SetRenderPixelFormatWinAPI returned "', SetRenderPixelFormatWinAPI(), '".']);
{$ENDIF}

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

glClearColor(0, 0, 0, 0);
glEnable(GL_DEPTH_TEST);
{$IFNDEF MOBILE}glClearDepth{$ELSE}glClearDepthf{$ENDIF}(1.0);
glDepthFunc(GL_LESS);

//Если включить GL_LINE_SMOOTH в GLES без шeйдеров то линии отображаются, видимо, неправильно
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
glLightfv(GL_LIGHT0,GL_POSITION, @TempLightPosition);
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

{$IF defined(MSWINDOWS) and (defined(CPU32) or defined(CPU64))}
	if (dglOpenGL.wglSwapIntervalEXT <> nil) and (dglOpenGL.wglGetSwapIntervalEXT <> nil) then
		begin
		if dglOpenGL.wglGetSwapIntervalEXT() = 0 then
			dglOpenGL.wglSwapIntervalEXT(1);
		SLog.Source([ClassName(), '__Init: Vertical synchronization ', Iff(TSBoolean(dglOpenGL.wglGetSwapIntervalEXT()), 'enabled', 'disabled'), '.']);
		end;
	{$ENDIF}
{$IFDEF RENDER_OGL_DEBUG}
	WriteLn(ClassName(), '__Init: End.');
	{$ENDIF}
end;

constructor TSRenderOpenGL.Create();
{$IFDEF NEEDResourceS}
procedure FreeMemTemp();
var
	ar : TSStringList = nil;
	i : TSMaxEnum;
begin
ar := SDirectoryFiles(TempDir+'/','*');
if ar <> nil then
	for i:= 0 to High(ar) do
		if (ar[i]<>'.') and (ar[i]<>'..') then
			DeleteFile(TempDir + '/' + ar[i]);
SetLength(ar,0);
end;
{$ENDIF}
begin
inherited Create();
SetRenderType({$IFDEF MOBILE}SRenderGLES{$ELSE}SRenderOpenGL{$ENDIF});
{$IFDEF SINTERPRITATEBEGINEND}
	FNowPosArPoints:=-1;
	FMaxLengthArPoints:=0;
	FArPoints:=nil;
	FLightingEnabled := False;
	FTextureEnabled  := False;
	{$ENDIF}
{$IFDEF NEEDResourceS}
	FArTextures := nil;
	FBindedTexture := 0;
	FArBuffers :=nil;
	FVBOData[0]:=0;
	FVBOData[1]:=0;
	{$IFDEF ANDROID}
		SMakeDirectory('/sdcard/.Smooth');
		SMakeDirectory('/sdcard/.Smooth/Temp');
	{$ELSE}
		SMakeDirectory('Temp');
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

FNowInBumpMapping:=False;
{$IFDEF RENDER_OGL_DEBUG}
	WriteLn('TSRenderOpenGL__Create.');
	{$ENDIF}
end;

procedure TSRenderOpenGL.Kill();
{$IFDEF NEEDResourceS}
procedure FreeMemTemp();
var
	ar : TSStringList = nil;
	i : TSMaxEnum;
begin
ar := SDirectoryFiles(TempDir+'/','*');
if ar <> nil then
	for i:= 0 to High(ar) do
		if (ar[i]<>'.') and (ar[i]<>'..') then
			DeleteFile(TempDir + '/' + ar[i]);
SetLength(ar,0);
end;
{$ENDIF}
begin
{$IFDEF NEEDResourceS}
	SetLength(FArTextures,0);
	SetLength(FArBuffers,0);
	FreeMemTemp();
	{$ENDIF}
{$IFDEF LINUX}

{$ELSE}
	{$IFDEF MSWINDOWS}
		if (Context <> nil) and (dglOpenGL.wglMakeCurrent <> nil) then
			dglOpenGL.wglMakeCurrent(0, 0);
		if FContext <> 0 then
			begin
			dglOpenGL.wglDeleteContext( FContext );
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
{$IFDEF RENDER_OGL_DEBUG}
	WriteLn('TSRenderOpenGL__Kill');
	{$ENDIF}
end;

destructor TSRenderOpenGL.Destroy();
begin
Kill();
inherited;
{$IFDEF RENDER_OGL_DEBUG}
	WriteLn('TSRenderOpenGL__Destroy');
	{$ENDIF}
end;

procedure TSRenderOpenGL.MatrixMode(const Par:TSLongWord);
begin
glMatrixMode(Par);
end;

procedure TSRenderOpenGL.InitOrtho2d(const x0,y0,x1,y1:TSSingle);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glMatrixMode = nil then TSRenderOpenGL_DynLinkError('glMatrixMode');{$ENDIF}
glMatrixMode(GL_PROJECTION);
LoadIdentity();
SRGLOrtho(x0,x1,y0,y1,0,0.1);
glMatrixMode(GL_MODELVIEW);
LoadIdentity();
end;

procedure TSRenderOpenGL.InitMatrixMode(const Mode:TSMatrixMode = S_3D; const dncht : TSFloat = 1);
const
	glub = 500;
var
	CWidth, CHeight : TSLongWord;
begin
CWidth := Width;
CHeight := Height;
Viewport(0, 0, CWidth, CHeight);

glMatrixMode(GL_PROJECTION);
LoadIdentity();
if  Mode=S_2D then
	begin
	SRGLOrtho(0,CWidth,CHeight,0,0,1);
	Disable(SR_DEPTH_TEST);
	end
else
	if Mode = S_3D_ORTHO then
		begin
		SRGLOrtho
			(-(CWidth / (1/dncht*120)),CWidth / (1/dncht*120),-CHeight / (1/dncht*120),(CHeight / (1/dncht*120)),TSRenderNear,TSRenderFar);
		Enable(SR_DEPTH_TEST);
		end
	else
		begin
		{$IFNDEF MOBILE}gluPerspective{$ELSE}SRGLPerspective{$ENDIF}
			(45, CWidth / CHeight, TSRenderNear, TSRenderFar);
		Enable(SR_DEPTH_TEST);
		end;
glMatrixMode(GL_MODELVIEW);
LoadIdentity();
end;

procedure TSRenderOpenGL.Viewport(const a,b,c,d:TSAreaInt);
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glViewport = nil then TSRenderOpenGL_DynLinkError('glViewport');{$ENDIF}
glViewport(a,b,c,d);
end;

procedure TSRenderOpenGL.LoadIdentity();
begin
{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if glLoadIdentity = nil then TSRenderOpenGL_DynLinkError('glLoadIdentity');{$ENDIF}
glLoadIdentity();
end;

function TSRenderOpenGL.CreateContext():Boolean;
begin
Result:=False;
{$IFDEF LINUX}
	initGlx();
	FContext := glXCreateContext(
		PDisplay(Context.Device),
		PXVisualInfo(Context.GetOption('VISUAL INFO')),nil,true);
	if FContext = nil then
		begin
		SLog.Source('TSContextUnix__CreateWindow: Error: Could not create an OpenGL rendering context!');
		Exit;
		end;
	Result:=FContext<>nil;
{$ELSE}
	{$IFDEF MSWINDOWS}
		if SetPixelFormat() then
			begin
			{$IFDEF RENDER_OGL_DEBUG_DYNLINK} if dglOpenGL.wglCreateContext = nil then TSRenderOpenGL_DynLinkError('dglOpenGL__wglCreateContext');{$ENDIF}
			FContext := dglOpenGL.wglCreateContext( TSMaxEnum(Context.Device) );
			end;
		Result:=FContext<>0;
	{$ELSE}
		{$IFDEF ANDROID}
			FContext := eglCreateContext(Context.Device, Context.GetOption('VISUAL INFO'), nil, nil);
			SLog.Source('TSRenderOpenGL__CreateContext: Called "eglCreateContext"; Result = "' + SStr(TSMaxEnum(FContext)) + '".');
			Result:=TSMaxEnum(FContext)<>0;
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
	Result := MakeCurrent();
{$ENDIF}
{$IFDEF RENDER_OGL_DEBUG}
	WriteLn('TSRenderOpenGL__CreateContext returned "', Result, '".');
	{$ENDIF}
end;

procedure TSRenderOpenGL.ReleaseCurrent();
begin
{$IFDEF LINUX}
	if (Context <> nil) and (FContext <> nil) then
		glXMakeCurrent(
			PDisplay(Context.Device),
			TSMaxEnum(Context.Window),
			nil);
{$ELSE}
	{$IFDEF MSWINDOWS}
		if (Context <> nil)  then
			dglOpenGL.wglMakeCurrent( TSMaxEnum(Context.Device), 0 );
	{$ELSE}
		{$IFDEF ANDROID}

		{$ELSE}
			{$IFDEF DARWIN}
				aglSetDrawable( nil, Context.Device);
				{$ENDIF}
			{$ENDIF}
		{$ENDIF}
	{$ENDIF}
{$IFDEF RENDER_OGL_DEBUG}
	WriteLn('TSRenderOpenGL__ReleaseCurrent.');
	{$ENDIF}
end;

{$IFDEF MSWINDOWS}
function TSRenderOpenGL.SetRenderPixelFormatWinAPI() : TSBoolean;
var
	pixelFormat : TSInt32 = 0;
	numFormats : TSUInt32 = 0;
	iAttributes : array[0..99] of TSInt32;
	fAttributes : array[0..1] of TSFloat32 = (0, 0);
	Index : TSMaxEnum = 0;

procedure AddAtrib(const A : TSLongInt);overload;
begin
iAttributes[Index] := A;
Index += 1;
end;

procedure AddAtrib(const A, B : TSLongInt);overload;
begin
AddAtrib(A);
AddAtrib(B);
end;
procedure AddAtrib(const A : TSLongInt; const B : ByteBool);overload;
begin
AddAtrib(A);
AddAtrib(TSLongInt(B));
end;

procedure FinalizeAttrib();
begin
AddAtrib(0,0);
end;

begin
Result := False;
if ((dglOpenGL.wglChoosePixelFormatARB = nil) or (Context.Device = nil)) then
	exit;

Index := 0;
fillchar(pixelFormat, sizeof(pixelFormat), 0);
fillchar(iAttributes, sizeof(iAttributes), 0);

AddAtrib(WGL_DRAW_TO_WINDOW_ARB, GL_TRUE);
AddAtrib(WGL_SUPPORT_OPENGL_ARB, GL_TRUE);
AddAtrib(WGL_ACCELERATION_ARB,WGL_FULL_ACCELERATION_ARB);
AddAtrib(WGL_COLOR_BITS_ARB, 24);
AddAtrib(WGL_ALPHA_BITS_ARB, 8);
AddAtrib(WGL_DEPTH_BITS_ARB, 24);
AddAtrib(WGL_STENCIL_BITS_ARB, 8);
AddAtrib(WGL_DOUBLE_BUFFER_ARB, GL_TRUE);
//AddAtrib(WGL_SAMPLE_BUFFERS_ARB,GL_TRUE);
//AddAtrib(WGL_SAMPLES_ARB, 0);
FinalizeAttrib();

(*AddAtrib(WGL_SUPPORT_OPENGL_ARB, GL_TRUE);
AddAtrib(WGL_DRAW_TO_WINDOW_ARB, GL_TRUE);
AddAtrib(WGL_PIXEL_TYPE_ARB, WGL_TYPE_RGBA_ARB);
AddAtrib(WGL_RED_BITS_ARB, 8);
AddAtrib(WGL_GREEN_BITS_ARB, 8);
AddAtrib(WGL_BLUE_BITS_ARB, 8);
AddAtrib(WGL_ALPHA_BITS_ARB, 8);
AddAtrib(WGL_DOUBLE_BUFFER_ARB, GL_TRUE);
AddAtrib(WGL_COLOR_BITS_ARB, 32);
AddAtrib(WGL_DEPTH_BITS_ARB, 24);
AddAtrib(WGL_STENCIL_BITS_ARB, 8);
FinalizeAttrib();*)

Result := dglOpenGL.wglChoosePixelFormatARB(
	TSMaxEnum(Context.Device),
	@iAttributes[0],
	@fAttributes[0],
	1,
	@pixelFormat,
	@numFormats);

{if (Result and (numFormats >= 1)) then
	begin
	
	end;}

if (not Result) then
	SLog.Source([ClassName() + '__SetRenderPixelFormatWinAPI: Choosing of formats failed!'])
else
	SLog.Source([ClassName() + '__SetRenderPixelFormatWinAPI: Choosing finded ', numFormats, ' formats.']);
end;
{$ENDIF}

function TSRenderOpenGL.SetPixelFormat():Boolean;overload;
{$IFDEF MSWINDOWS}
function SetPixelFormatWinAPI() : TSBoolean;
var
	pfd : PIXELFORMATDESCRIPTOR;
	iFormat : integer;
begin
FillChar(pfd, sizeof(pfd), 0);
pfd.nSize         := sizeof(pfd);
pfd.nVersion      := 1;
pfd.dwFlags       := PFD_SUPPORT_OPENGL OR PFD_DRAW_TO_WINDOW OR PFD_DOUBLEBUFFER;
pfd.iPixelType    := PFD_TYPE_RGBA;
pfd.cColorBits    := 32;
pfd.cDepthBits    := 24;
pfd.iLayerType    := PFD_MAIN_PLANE;
iFormat := Windows.ChoosePixelFormat( TSMaxEnum(Context.Device), @pfd );
SLog.Source([ClassName(), '__SetPixelFormat: Choose returned "', iFormat, '".']);
Result := Windows.SetPixelFormat(TSMaxEnum(Context.Device), iFormat, @pfd);
SLog.Source([ClassName(),'__SetPixelFormat returned "', Result, '".']);
end;
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
	ogl_Format := aglChoosePixelFormat( nil, 0, @ogl_Attr[ 0 ]);
	Result := Assigned( ogl_Format );
	{$ENDIF}
{$IFDEF MSWINDOWS}
	Result := SetPixelFormatWinAPI();
	{$ENDIF}
{$IF defined(LINUX) or defined(ANDROID)}
	Result:=True;
	{$ENDIF}
{$IFDEF RENDER_OGL_DEBUG}
	WriteLn(ClassName(), '__SetPixelFormat returned  "', Result, '".');
	{$ENDIF}
end;

function TSRenderOpenGL.MakeCurrent():Boolean;
begin
{$IFDEF LINUX}
	if (Context <> nil) and (FContext <> nil) then
		begin
		glXMakeCurrent(
			PDisplay(Context.Device),
			TSMaxEnum(Context.Window),
			FContext);
		Result:=True;
		end
	else
		Result:=False;
{$ELSE}
	{$IFDEF MSWINDOWS}
		if (Context<>nil) and (FContext<>0) then
			begin
			dglOpenGL.wglMakeCurrent( TSMaxEnum(Context.Device), FContext );
			Result:=True;
			end
		else
			Result:=False;
	{$ELSE}
		{$IFDEF ANDROID}
			if (Context <> nil) and (FContext <> nil) then
				begin
				if eglMakeCurrent(
					Context.Device,
					Context.GetOption('SURFACE'),
					Context.GetOption('SURFACE'),
					FContext)  = EGL_FALSE then
						begin
						Result:=False;
						SLog.Source('TSRenderOpenGL__MakeCurrent: EGL Error : "'+SGetEGLError()+'"');
						end
				else
					Result:=True;
				SLog.Source('TSRenderOpenGL__MakeCurrent: Called "eglMakeCurrent"; Result="'+SStr(Result)+'".');
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
{$IFDEF RENDER_OGL_DEBUG}
	WriteLn('TSRenderOpenGL__MakeCurrent returned "', Result, '".');
	{$ENDIF}
end;

// Сохранения ресурсов рендера и убивание самого рендера
procedure TSRenderOpenGL.LockResources();
{$IFDEF NEEDResourceS}
var
	i : LongWord;
	{$ENDIF}
begin
{$IFDEF NEEDResourceS}
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
			SLog.Source('TSRenderOpenGL__LockResources: EGL Error: "'+SGetEGLError()+'"');
		FContext := EGL_NO_CONTEXT;
		end;
	{$ENDIF}
end;

// Инициализация рендера и загрузка сохраненных ресурсов
procedure TSRenderOpenGL.UnLockResources();
{$IFDEF NEEDResourceS}
procedure LoadTexture(const i : LongWord);
var
	VTextureType,VP1,VChannels,VWidth,VHeight,VFormatType,VDataType,VP2:Cardinal;
	VBitMap : Pointer = nil;
	FS : TFileStream = nil;
begin
FS := TFileStream.Create(TempDir+'/t'+SStr(i),fmOpenRead);
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

TexParameteri(VTextureType, SR_TEXTURE_MIN_FILTER, SR_LINEAR);
TexParameteri(VTextureType, SR_TEXTURE_MAG_FILTER, SR_NEAREST);
TexParameteri(VTextureType, SR_TEXTURE_WRAP_S, SR_REPEAT);
TexParameteri(VTextureType, SR_TEXTURE_WRAP_T, SR_REPEAT);

glTexImage2D(VTextureType,VP1,{$IFDEF MOBILE}VFormatType{$ELSE}VChannels{$ENDIF},VWidth,VHeight,VP2,VFormatType,VDataType,VBitMap);
glBindTexture(VTextureType,0);
glDisable(VTextureType);

FreeMem(VBitMap,VChannels*VWidth*VHeight);
SLog.Source('TSRenderOpenGL__UnLockResources: LoadTexture: "'+TempDir+'/t'+SStr(i)+'": W='+SStr(VWidth)+', H='+SStr(VHeight)+', C='+SStr(VChannels)+', T='+SStr(FArTextures[i].FTexture)+'.');
end;
procedure LoadBuffer(const i : LongWord);
var
	VBuffer : Pointer = nil;
	FS : TFileStream = nil;
	VType,VSize,VParam2 : TSQWord;
begin
FS := TFileStream.Create(TempDir+'/b'+SStr(i),fmOpenRead);
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
	FContext := eglCreateContext(Context.Device, Context.GetOption('VISUAL INFO'), nil, nil);
	if FContext = EGL_NO_CONTEXT then
		SLog.Source('TSRenderOpenGL__UnLockResources: EGL Error: "'+SGetEGLError()+'"');
	SLog.Source('TSRenderOpenGL__UnLockResources: Called "eglCreateContext"; Result="'+SStr(TSMaxEnum(FContext))+'"');
	if eglMakeCurrent(Context.Device,Context.GetOption('SURFACE'),Context.GetOption('SURFACE'),FContext)  = EGL_FALSE then
		begin
		SLog.Source('TSRenderOpenGL__UnLockResources: EGL Error: "'+SGetEGLError()+'"');
		SLog.Source('TSRenderOpenGL__UnLockResources: Called "eglMakeCurrent"; Result="FALSE".');
		end
	else
		SLog.Source('TSRenderOpenGL__UnLockResources: Called "eglMakeCurrent"; Result="TRUE".');
	{$ENDIF}
Init();
Clear(SR_COLOR_BUFFER_BIT OR SR_DEPTH_BUFFER_BIT);
SwapBuffers();
{$IFDEF NEEDResourceS}
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
