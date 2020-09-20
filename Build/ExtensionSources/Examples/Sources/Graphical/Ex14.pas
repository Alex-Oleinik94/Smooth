{$INCLUDE Smooth.inc}
{$IFDEF ENGINE}
	unit Ex14;
	interface
{$ELSE}
	program Example14;
	{$ENDIF}
uses
	{$IF defined(UNIX) and (not defined(ANDROID)) and (not defined(ENGINE))}
		cthreads,
		{$ENDIF}
	 SmoothContextInterface
	,SmoothContextClasses
	,SmoothBase
	,SmoothRenderBase
	,SmoothFont
	,SmoothScreen
	,SmoothVertexObject
	,SmoothCommonStructs
	,SmoothShaders
	,SmoothShaderReader
	,SmoothResourceManager
	,SmoothFileUtils
	,SmoothCamera
	,SmoothMatrix
	,SmoothContextUtils
	{$IF not defined(ENGINE)}
		,SmoothConsolePaintableTools
		,SmoothConsoleHandler
		{$ENDIF}
	
	,Classes
	,SysUtils
	
	,Ex5_Physics
	;

const
	TextureSize = 1024;
type
	TSExample14 = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext); override;
		destructor Destroy(); override;
		procedure Paint(); override;
		class function ClassName():TSString; override;
		class function Supported(const _Context : ISContext) : TSBoolean; override;
			private
		FCamera : TSCamera;
		
		FModel, FLigthSphere: TS3DObject;
		FModelBBoxMin,
			FModelBBoxMax,
			FModelCenter : TSVertex3f;
		
		FTexDepth  : TSLongWord;
		FTexDepth2 : TSLongWord;
		
		FLightAngle : TSFloat;
		FLightPos : TSVertex3f;
		FLightEye : TSVertex3f;
		FLightUp  : TSVertex3f;
		
		FTexDepthSizeX, FTexDepthSizeY : TSLongWord;
		FFrameBufferDepth, 
			FFrameBufferDepth2,
			FRenderBufferDepth : TSLongWord;
		// Шейдерные программы и uniform'ы
		FCurrentShader,
			FShaderDepth,
			FShaderShadowTex2D,
			FShaderShadowShad2D : TSShaderProgram;
		
		FUniformShadowTex2D_shadowMap,
			FUniformShadowTex2D_lightMatrix,
			FUniformShadowTex2D_lightPos,
			FUniformShadowTex2D_lightDir,
			FUniformShadowShad2D_shadowMap,
			FUniformShadowShad2D_lightMatrix,
			FUniformShadowShad2D_lightPos,
			FUniformShadowShad2D_lightDir : TSLongWord;
		
		// Матрицы
		FCameraProjectionMatrix,
			FCameraModelViewMatrix,
			FCameraInverseModelViewMatrix,
			FLightProjectionMatrix,
			FLightModelViewMatrix,
			FLightMatrix : TSMatrix4x4;
		
		FUseLightAnimation,
			FShadowRenderType,
			FShadowFilter : TSBoolean;
		
			private
		procedure LoadModel(const FileName : TSString);
		procedure RenderToShadowMap();
		procedure RenderShadowedScene();
		procedure DrawModel();
		procedure DrawPlane();
		procedure KeyboardUpCallback();
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}


class function TSExample14.Supported(const _Context : ISContext) : TSBoolean;
begin
Result := _Context.Render.SupportedShaders();
end;

procedure TSExample14.LoadModel(const FileName : TSString);
var
	Stream : TMemoryStream = nil;
	CountOfVertices, CountOfIndexes : Integer;
	Indexes : packed array of packed array [0..2] of TSLongWord;
	i : LongWord;
begin
FModel := TS3DObject.Create();
FModel.Context := Context;
FModel.CountTextureFloatsInVertexArray := 2;
FModel.ObjectPoligonesType := SR_TRIANGLES;
FModel.HasNormals := True;
FModel.SetColorType(S3dObjectColorType4f);
FModel.HasTexture := False;
FModel.HasColors  := False;
FModel.EnableCullFace := True;
FModel.EnableCullFaceFront := False;
FModel.EnableCullFaceBack := True;
FModel.VertexType := S3dObjectVertexType3f;

FModel.QuantityFaceArrays := 1;
FModel.PoligonesType[0] := FModel.ObjectPoligonesType;

Stream := TMemoryStream.Create();
SResourceFiles.LoadMemoryStreamFromFile(Stream,FileName);
Stream.ReadBuffer(FModelBBoxMin,SizeOf(FModelBBoxMin));
Stream.ReadBuffer(FModelBBoxMax,SizeOf(FModelBBoxMax));
FModelCenter := (FModelBBoxMax + FModelBBoxMin)/2;

Stream.ReadBuffer(CountOfIndexes,SizeOf(CountOfIndexes));
SetLength(Indexes,CountOfIndexes);
Stream.ReadBuffer(Indexes[0],(CountOfIndexes * SizeOf(Indexes[0])) div 3);

Stream.ReadBuffer(CountOfVertices,SizeOf(CountOfVertices));
FModel.Vertices   := CountOfVertices;
Stream.ReadBuffer(FModel.GetArVertices()^, CountOfVertices * (6 * SizeOf(SIngle)));

Stream.Destroy();

FModel.AutoSetIndexFormat(0,CountOfVertices);
FModel.SetFaceLength(0,CountOfIndexes div 3);
for i := 0 to (CountOfIndexes div 3) - 1 do
	FModel.SetFaceTriangle(0,i,Indexes[i][0],Indexes[i][1],Indexes[i][2]);
SetLength(Indexes, 0);

FModel.LoadToVBO();
end;

class function TSExample14.ClassName():TSString;
begin
Result := 'Shadow Mapping';
end;

constructor TSExample14.Create(const VContext : ISContext);

procedure LoadLigthModel();
var
	FPhysics : TSPhysics;
begin
FPhysics:=TSPhysics.Create(Context);

FPhysics.AddObjectBegin(SPBodySphere,True);
FPhysics.LastObject().InitSphere(1,30);
FPhysics.LastObject().SetVertex(0,-56,18);
FPhysics.LastObject().AddObjectEnd(50);

FLigthSphere := FPhysics.LastObject().Object3d;
FPhysics.LastObject().Object3d := nil;
FLigthSphere.ObjectColor:=SVertex4fImport(1,1,1,1);
FLigthSphere.EnableCullFace := True;

FPhysics.Destroy();
end;

begin
inherited Create(VContext);
FCamera:=TSCamera.Create();
FCamera.Context := Context;
FCamera.Zum := 10;
FCamera.RotateX := 50;

FLightPos.Import(0,0,0);
FLightUp.Import(0,1,0);
FLightEye.Import(0,0,0);
FLightAngle := 0;

FFrameBufferDepth  := 0;
FFrameBufferDepth2 := 0;
FRenderBufferDepth := 0;

FUseLightAnimation := True;
FShadowFilter      := False;
FShadowRenderType  := True;

FCurrentShader      := nil;
FShaderShadowShad2D := nil;
FShaderShadowTex2D  := nil;

FUniformShadowShad2D_lightDir    := 0;
FUniformShadowShad2D_lightMatrix := 0;
FUniformShadowShad2D_lightPos    := 0;
FUniformShadowShad2D_shadowMap   := 0;
FUniformShadowTex2D_lightDir     := 0;
FUniformShadowTex2D_lightMatrix  := 0;
FUniformShadowTex2D_lightPos     := 0;
FUniformShadowTex2D_shadowMap    := 0;

FTexDepthSizeX := TextureSize;
FTexDepthSizeY := TextureSize;
FTexDepth  := 0;
FTexDepth2 := 0;

// Создаём текстуру FTexDepth - текстура прикреплённая как буффер цвета, для теста глубины мы создадим рендербуффер
Render.GenTextures(1, @FTexDepth);
Render.BindTexture(SR_TEXTURE_2D, FTexDepth);
Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_MIN_FILTER, SR_NEAREST);
Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_MAG_FILTER, SR_NEAREST);
Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_WRAP_S, SR_CLAMP);
Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_WRAP_T, SR_CLAMP);
if Render.SupportedDepthTextures() then
	Render.TexImage2D(SR_TEXTURE_2D, 0, SR_R16, FTexDepthSizeX, FTexDepthSizeY, 0, SR_RED, SR_UNSIGNED_SHORT, nil)
else
	Render.TexImage2D(SR_TEXTURE_2D, 0, SR_RGBA16, FTexDepthSizeX, FTexDepthSizeY, 0, SR_RGBA, SR_UNSIGNED_SHORT, nil);
Render.BindTexture(SR_TEXTURE_2D,0);
// Создаём рендербуффер глубины
Render.GenRenderBuffers(1,@FRenderBufferDepth);
Render.BindRenderBuffer(SR_RENDERBUFFER_EXT, FRenderBufferDepth);
Render.RenderBufferStorage(SR_RENDERBUFFER_EXT, SR_DEPTH_COMPONENT24, FTexDepthSizeX, FTexDepthSizeY);
Render.BindRenderBuffer(SR_RENDERBUFFER_EXT, 0);
// Создаём фреймбуффер
Render.GenFrameBuffers(1, @FFrameBufferDepth);
Render.BindFrameBuffer(SR_FRAMEBUFFER_EXT, FFrameBufferDepth);
Render.FrameBufferTexture2D(SR_FRAMEBUFFER_EXT, SR_COLOR_ATTACHMENT0_EXT, SR_TEXTURE_2D, FTexDepth, 0);
Render.FrameBufferRenderBuffer(SR_FRAMEBUFFER_EXT,SR_DEPTH_ATTACHMENT_EXT, SR_RENDERBUFFER_EXT, FRenderBufferDepth);
Render.BindFrameBuffer(SR_FRAMEBUFFER_EXT, 0);
// Создаём текстуру FTexDepth2 - текстура прикреплённая как буффер глубины
Render.GenTextures(1, @FTexDepth2);
Render.BindTexture(SR_TEXTURE_2D, FTexDepth2);
Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_MIN_FILTER, SR_NEAREST);
Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_MAG_FILTER, SR_NEAREST);
Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_WRAP_S, SR_CLAMP);
Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_WRAP_T, SR_CLAMP);
Render.TexImage2D(SR_TEXTURE_2D, 0, SR_DEPTH_COMPONENT24, FTexDepthSizeX, FTexDepthSizeY, 0, SR_DEPTH_COMPONENT, SR_UNSIGNED_SHORT, nil);
Render.BindTexture(SR_TEXTURE_2D, 0);
// Создаём фреймбуффер
Render.GenFrameBuffers(1, @FFrameBufferDepth2);
Render.BindFrameBuffer(SR_FRAMEBUFFER_EXT, FFrameBufferDepth2);
Render.DrawBuffer(SR_NONE);
Render.ReadBuffer(SR_NONE);
Render.FrameBufferTexture2D(SR_FRAMEBUFFER_EXT, SR_DEPTH_ATTACHMENT_EXT, SR_TEXTURE_2D, FTexDepth2, 0);
Render.BindFrameBuffer(SR_FRAMEBUFFER_EXT, 0);

FShaderDepth := SCreateShaderProgramFromSources(Context,
	SReadShaderSourceFromFile(SExamplesDirectory + DirectorySeparator + '14' + DirectorySeparator + 'depth.vert'),
	SReadShaderSourceFromFile(SExamplesDirectory + DirectorySeparator + '14' + DirectorySeparator + 'depth.frag'));
FShaderShadowTex2D := SCreateShaderProgramFromSources(Context,
	SReadShaderSourceFromFile(SExamplesDirectory + DirectorySeparator + '14' + DirectorySeparator + 'shadow.vert'),
	SReadShaderSourceFromFile(SExamplesDirectory + DirectorySeparator + '14' + DirectorySeparator + 'shadow_tex2D.frag'));
FShaderShadowShad2D := SCreateShaderProgramFromSources(Context,
	SReadShaderSourceFromFile(SExamplesDirectory + DirectorySeparator + '14' + DirectorySeparator + 'shadow.vert'),
	SReadShaderSourceFromFile(SExamplesDirectory + DirectorySeparator + '14' + DirectorySeparator + 'shadow_shad2D.frag'));


FUniformShadowTex2D_shadowMap    := FShaderShadowTex2D.GetUniformLocation('shadowMap');
FUniformShadowTex2D_lightMatrix  := FShaderShadowTex2D.GetUniformLocation('lightMatrix');
FUniformShadowTex2D_lightPos     := FShaderShadowTex2D.GetUniformLocation('lightPos');
FUniformShadowTex2D_lightDir     := FShaderShadowTex2D.GetUniformLocation('lightDir');

FUniformShadowShad2D_shadowMap   := FShaderShadowShad2D.GetUniformLocation('shadowMap');
FUniformShadowShad2D_lightMatrix := FShaderShadowShad2D.GetUniformLocation('lightMatrix');
FUniformShadowShad2D_lightPos    := FShaderShadowShad2D.GetUniformLocation('lightPos');
FUniformShadowShad2D_lightDir    := FShaderShadowShad2D.GetUniformLocation('lightDir');

LoadModel(SExamplesDirectory + DirectorySeparator + '14' + DirectorySeparator + 'model.bin');
LoadLigthModel();
end;

destructor TSExample14.Destroy();
begin
Render.DeleteTextures(1,@FTexDepth);
Render.DeleteTextures(1,@FTexDepth2);
FShaderDepth.Destroy();
FShaderShadowTex2D.Destroy();
FShaderShadowShad2D.Destroy();
FModel.Destroy();
FCamera.Destroy();
inherited;
end;

procedure TSExample14.DrawPlane();
// Плоскость не отбрасывает тень, поэтому она не рендерится в текстуру глубины
const
	PlaneSize = 35.0;
	NumTriangles = 50;
var
	PlaneHeight : TSFloat;
	x,y,a : TSFloat;
	i : TSLongWord;
begin
PlaneHeight := FModelCenter.y * 0.005 + 4.36;
Render.Color3f(0.4,0.5,0.6);

x := sin(0) * PlaneSize;
y := cos(0) * PlaneSize;
a := PI*2/50;
Render.BeginScene(SR_TRIANGLES);
Render.Normal3f(0,1,0);
for i := 0 to 49 do
	begin
	Render.Vertex3f(x, -PlaneHeight,y);
	Render.Vertex3f(0, -PlaneHeight,0);
	x := sin(a) * PlaneSize;
	y := cos(a) * PlaneSize;
	a += PI*2/50;
	Render.Vertex3f(x, -PlaneHeight, y);
	end;
Render.EndScene();
end;

procedure TSExample14.RenderToShadowMap();
begin
Render.Viewport(0,0,FTexDepthSizeX,FTexDepthSizeY);
if (FShadowRenderType) then
	begin // Вариант #1
	Render.BindFrameBuffer(SR_FRAMEBUFFER_EXT, FFrameBufferDepth);
	// Очищать текстуру нужно значением соответствующим дальней плоскости отсечения
	Render.ClearColor(1,1,1,1);
	Render.Clear(SR_COLOR_BUFFER_BIT or SR_DEPTH_BUFFER_BIT);
	end
else
	begin // Вариант #2
	Render.BindFrameBuffer(SR_FRAMEBUFFER_EXT,FFrameBufferDepth2);
	// В этом случае у нас нет буфера цвета, поэтому очищать его не нужно
	Render.Clear(SR_DEPTH_BUFFER_BIT);
	end;
// Сдвиг полигонов - нужен для того, чтобы не было z-fighting'а
Render.Enable(SR_POLYGON_OFFSET_FILL);
Render.PolygonOffset ( 2, 500);

// Сохраняем эти матрицы, они нам понадобятся для расчёта матрицы света
FLightProjectionMatrix := SGetPerspectiveMatrix(50.0, 1.0, TSRenderNear, TSRenderFar);
FLightModelViewMatrix  := SGetLookAtMatrix(FLightPos, FLightEye, FLightUp);

// Установить матрицы камеры света
Render.MatrixMode(SR_PROJECTION);
Render.LoadIdentity();
Render.MultMatrixf(@FLightProjectionMatrix);
Render.MatrixMode(SR_MODELVIEW);
Render.LoadIdentity();
Render.MultMatrixf(@FLightModelViewMatrix);

// Напомню, что в первом варианте нам нужен шейдер, чтобы сохранить глубину в текстуру, во втором это не к чему.
if FShadowRenderType then
	begin // Вариант #1
	FShaderDepth.Use();
	DrawModel();
	Render.UseProgram(0);
	end
else
	begin // Вариант #2
	DrawModel();
	end;

Render.Disable(SR_POLYGON_OFFSET_FILL);
Render.BindFrameBuffer(SR_FRAMEBUFFER_EXT, 0);
end;

procedure TSExample14.DrawModel();
begin
Render.Color3f(0.9,0.9,0.9);
Render.PushMatrix();
Render.Scale(0.005,0.005,0.005);
Render.Translatef(-FModelCenter.x,-FModelCenter.y,-FModelCenter.z);
FModel.Paint();
Render.PopMatrix();
end;

procedure TSExample14.RenderShadowedScene();
var
	FShaderShadow : TSShaderProgram = nil;
	FUniformShadow_lightDir    : TSLongWord = 0;
	FUniformShadow_lightMatrix : TSLongWord = 0;
	FUniformShadow_lightPos    : TSLongWord = 0;
	FUniformShadow_shadowMap   : TSLongWord = 0;
	{FMVLightPos,} FLightDir     : TSVertex3f;
	FLightInverseModelViewMatrix : TSMatrix4x4;
begin
Render.Viewport(0,0,Context.Width,Context.Height);
Render.ClearColor(0,0,0,1);
Render.Clear(SR_COLOR_BUFFER_BIT or SR_DEPTH_BUFFER_BIT);

// Устанавливаем матрицы камеры
FCamera.CallAction();

// Сохраняем матрицы, они нам нужны для вычисления освещения
// Инвертированная матрица используется в расчёте матрицы источника света
FCameraProjectionMatrix := FCamera.GetProjectionMatrix();
FCameraModelViewMatrix := FCamera.GetModelViewMatrix();
FCameraInverseModelViewMatrix := SInverseMatrix(FCameraModelViewMatrix);

FLightMatrix := FCameraInverseModelViewMatrix *
	FLightModelViewMatrix * 
	FLightProjectionMatrix *
	SScaleMatrix(SVertex3fImport(0.5,0.5,0.5)) *
	STranslateMatrix(SVertex3fImport(0.5,0.5,0.5));

if FShadowRenderType then
	begin // Вариант #1
	Render.BindTexture(SR_TEXTURE_2D, FTexDepth);
	
	FShaderShadow := FShaderShadowTex2D;
	FUniformShadow_lightDir    := FUniformShadowTex2D_lightDir;
	FUniformShadow_lightMatrix := FUniformShadowTex2D_lightMatrix;
	FUniformShadow_lightPos    := FUniformShadowTex2D_lightPos;
	FUniformShadow_shadowMap   := FUniformShadowTex2D_shadowMap;
	end
else
	begin // Вариант #2
	Render.BindTexture(SR_TEXTURE_2D, FTexDepth2);
	
	// Для второго варианта включаем режим сравнения текстуры
	Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_COMPARE_MODE, SR_COMPARE_R_TO_TEXTURE);
	Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_COMPARE_FUNC, SR_LEQUAL);
	
	FShaderShadow := FShaderShadowShad2D;
	FUniformShadow_lightDir    := FUniformShadowShad2D_lightDir;
	FUniformShadow_lightMatrix := FUniformShadowShad2D_lightMatrix;
	FUniformShadow_lightPos    := FUniformShadowShad2D_lightPos;
	FUniformShadow_shadowMap   := FUniformShadowShad2D_shadowMap;
	end;

FShaderShadow.Use();
Render.Uniform1i(FUniformShadow_shadowMap, 0);
Render.UniformMatrix4fv(FUniformShadow_lightMatrix, 1, False, @FLightMatrix );
//FMVLightPos := FLightPos * FCameraModelViewMatrix;
Render.Uniform3f(FUniformShadow_lightPos, FLightPos.x, FLightPos.y, FLightPos.z);
FLightDir := (FLightEye - FLightPos).Normalized();
Render.Uniform3f(FUniformShadow_lightDir, FLightDir.x, FLightDir.y, FLightDir.z);

// Рисуем плоскость и модель
DrawPlane();
DrawModel();

Render.UseProgram(0);

if (not FShadowRenderType) then
	begin // Вариант #2
	// Не забываем выключать режим сравнения
	Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_COMPARE_MODE,SR_NONE);
	end;
Render.BindTexture(SR_TEXTURE_2D, 0);

// Отображаем положение источника света
Render.PushMatrix();
FLightInverseModelViewMatrix := SInverseMatrix(FLightModelViewMatrix);
Render.MultMatrixf(@FLightInverseModelViewMatrix);
FLigthSphere.Paint();
Render.PopMatrix();

{
Render.BeginScene(SR_LINES);
FLightPos.Vertex(Render);
(FLightPos + FLightDir * 10).Vertex(Render);
Render.EndScene();
}
end;

procedure TSExample14.Paint();
begin
FLightPos.Import(30 * cos (FLightAngle), 40, 30 * sin(FLightAngle));

// Рисование происходит в два этапа:
RenderToShadowMap();				// 1) Рисуем в текстуру глубины с позиции источника света
RenderShadowedScene();				// 2) Рисуем нашу сцену на экран

if (FUseLightAnimation) then
	FLightAngle += Context.ElapsedTime / 200;

KeyboardUpCallback();
end;

procedure TSExample14.KeyboardUpCallback();
begin
if (Context.KeyPressed and (Context.KeyPressedType = SUpKey)) then
	case Context.KeyPressedChar of
	' ' : FUseLightAnimation := not FUseLightAnimation;
	'1' : FShadowRenderType := True;
	'2' : FShadowRenderType := False;
	'3' : 
		begin
		Render.Enable(SR_TEXTURE_2D);
		Render.BindTexture(SR_TEXTURE_2D,FTexDepth);
		Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MAG_FILTER, SR_LINEAR);
		Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MIN_FILTER, SR_LINEAR);
		Render.BindTexture(SR_TEXTURE_2D,FTexDepth2);
		Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MAG_FILTER, SR_LINEAR);
		Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MIN_FILTER, SR_LINEAR);
		Render.BindTexture(SR_TEXTURE_2D,0);
		Render.Disable(SR_TEXTURE_2D);
		end;
	'4' : 
		begin
		Render.Enable(SR_TEXTURE_2D);
		Render.BindTexture(SR_TEXTURE_2D,FTexDepth);
		Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MAG_FILTER, SR_NEAREST);
		Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MIN_FILTER, SR_NEAREST);
		Render.BindTexture(SR_TEXTURE_2D,FTexDepth2);
		Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MAG_FILTER, SR_NEAREST);
		Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MIN_FILTER, SR_NEAREST);
		Render.BindTexture(SR_TEXTURE_2D,0);
		Render.Disable(SR_TEXTURE_2D);
		end;
	end;
end;

{$IFNDEF ENGINE}
	begin
	SConsoleRunPaintable(TSExample14, SSystemParamsToConsoleHandlerParams());
	{$ENDIF}
end.
