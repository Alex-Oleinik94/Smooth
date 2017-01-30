{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex14;
	interface
{$ELSE}
	program Example14;
	{$ENDIF}
uses
	{$IFNDEF ENGINE}
		{$IFDEF UNIX}
			{$IFNDEF ANDROID}
				cthreads,
				{$ENDIF}
			{$ENDIF}
		SaGeBaseExample,
		{$ENDIF}
	 SaGeCommonClasses
	,SaGeBased
	,SaGeBase
	,SaGeRenderConstants
	,SaGeUtils
	,SaGeScreen
	,SaGeMesh
	,SaGeCommon
	,SaGeShaders
	,SaGeResourceManager
	,SaGeFileUtils
	
	,Classes
	,SysUtils
	
	,Ex5_Physics
	;

const
	TextureSize = 1024;
type
	TSGExample14 = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		
		FModel, FLigthSphere: TSG3DObject;
		FModelBBoxMin,
			FModelBBoxMax,
			FModelCenter : TSGVertex3f;
		
		FTexDepth  : TSGLongWord;
		FTexDepth2 : TSGLongWord;
		
		FLightAngle : TSGFloat;
		FLightPos : TSGVertex3f;
		FLightEye : TSGVertex3f;
		FLightUp  : TSGVertex3f;
		
		FTexDepthSizeX, FTexDepthSizeY : TSGLongWord;
		FFrameBufferDepth, 
			FFrameBufferDepth2,
			FRenderBufferDepth : TSGLongWord;
		// Шейдерные программы и uniform'ы
		FCurrentShader,
			FShaderDepth,
			FShaderShadowTex2D,
			FShaderShadowShad2D : TSGShaderProgram;
		
		FUniformShadowTex2D_shadowMap,
			FUniformShadowTex2D_lightMatrix,
			FUniformShadowTex2D_lightPos,
			FUniformShadowTex2D_lightDir,
			FUniformShadowShad2D_shadowMap,
			FUniformShadowShad2D_lightMatrix,
			FUniformShadowShad2D_lightPos,
			FUniformShadowShad2D_lightDir : TSGLongWord;
		
		// Матрицы
		FCameraProjectionMatrix,
			FCameraModelViewMatrix,
			FCameraInverseModelViewMatrix,
			FLightProjectionMatrix,
			FLightModelViewMatrix,
			FLightMatrix : TSGMatrix4;
		
		FUseLightAnimation,
			FShadowRenderType,
			FShadowFilter : TSGBoolean;
		
			private
		procedure LoadModel(const FileName : TSGString);
		procedure RenderToShadowMap();
		procedure RenderShadowedScene();
		procedure DrawModel();
		procedure DrawPlane();
		procedure KeyboardUpCallback();
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

procedure TSGExample14.LoadModel(const FileName : TSGString);
var
	Stream : TMemoryStream = nil;
	CountOfVertexes, CountOfIndexes : Integer;
	Indexes : packed array of packed array [0..2] of TSGLongWord;
	i : LongWord;
begin
FModel := TSG3DObject.Create();
FModel.Context := Context;
FModel.CountTextureFloatsInVertexArray := 2;
FModel.ObjectPoligonesType := SGR_TRIANGLES;
FModel.HasNormals := True;
FModel.SetColorType(SGMeshColorType4f);
FModel.HasTexture := False;
FModel.HasColors  := False;
FModel.EnableCullFace := True;
FModel.EnableCullFaceFront := False;
FModel.EnableCullFaceBack := True;
FModel.VertexType := SGMeshVertexType3f;

FModel.QuantityFaceArrays := 1;
FModel.PoligonesType[0] := FModel.ObjectPoligonesType;

Stream := TMemoryStream.Create();
SGResourceFiles.LoadMemoryStreamFromFile(Stream,FileName);
Stream.ReadBuffer(FModelBBoxMin,SizeOf(FModelBBoxMin));
Stream.ReadBuffer(FModelBBoxMax,SizeOf(FModelBBoxMax));
FModelCenter := (FModelBBoxMax + FModelBBoxMin)/2;

Stream.ReadBuffer(CountOfIndexes,SizeOf(CountOfIndexes));
SetLength(Indexes,CountOfIndexes);
Stream.ReadBuffer(Indexes[0],(CountOfIndexes * SizeOf(Indexes[0])) div 3);

Stream.ReadBuffer(CountOfVertexes,SizeOf(CountOfVertexes));
FModel.Vertexes   := CountOfVertexes;
Stream.ReadBuffer(FModel.GetArVertexes()^, CountOfVertexes * (6 * SizeOf(SIngle)));

Stream.Destroy();

FModel.AutoSetIndexFormat(0,CountOfVertexes);
FModel.SetFaceLength(0,CountOfIndexes div 3);
for i := 0 to (CountOfIndexes div 3) - 1 do
	FModel.SetFaceTriangle(0,i,Indexes[i][0],Indexes[i][1],Indexes[i][2]);
SetLength(Indexes, 0);

FModel.LoadToVBO();
end;

class function TSGExample14.ClassName():TSGString;
begin
Result := 'Shadow Mapping';
end;

constructor TSGExample14.Create(const VContext : ISGContext);

procedure LoadLigthModel();
var
	FPhysics : TSGPhysics;
begin
FPhysics:=TSGPhysics.Create(Context);

FPhysics.AddObjectBegin(SGPBodySphere,True);
FPhysics.LastObject().InitSphere(1,30);
FPhysics.LastObject().SetVertex(0,-56,18);
FPhysics.LastObject().AddObjectEnd(50);

FLigthSphere := FPhysics.LastObject().Mesh;
FPhysics.LastObject().Mesh := nil;
FLigthSphere.ObjectColor:=SGVertex4fImport(1,1,1,1);
FLigthSphere.EnableCullFace := True;

FPhysics.Destroy();
end;

begin
inherited Create(VContext);
FCamera:=TSGCamera.Create();
FCamera.Context := Context;
FCamera.FZum := 10;
FCamera.FRotateX := 50;

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
Render.BindTexture(SGR_TEXTURE_2D, FTexDepth);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_MIN_FILTER, SGR_NEAREST);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_MAG_FILTER, SGR_NEAREST);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_WRAP_S, SGR_CLAMP);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_WRAP_T, SGR_CLAMP);
if Render.SupporedDepthTextures() then
	Render.TexImage2D(SGR_TEXTURE_2D, 0, SGR_R16, FTexDepthSizeX, FTexDepthSizeY, 0, SGR_RED, SGR_UNSIGNED_SHORT, nil)
else
	Render.TexImage2D(SGR_TEXTURE_2D, 0, SGR_RGBA16, FTexDepthSizeX, FTexDepthSizeY, 0, SGR_RGBA, SGR_UNSIGNED_SHORT, nil);
Render.BindTexture(SGR_TEXTURE_2D,0);
// Создаём рендербуффер глубины
Render.GenRenderBuffers(1,@FRenderBufferDepth);
Render.BindRenderBuffer(SGR_RENDERBUFFER_EXT, FRenderBufferDepth);
Render.RenderBufferStorage(SGR_RENDERBUFFER_EXT, SGR_DEPTH_COMPONENT24, FTexDepthSizeX, FTexDepthSizeY);
Render.BindRenderBuffer(SGR_RENDERBUFFER_EXT, 0);
// Создаём фреймбуффер
Render.GenFrameBuffers(1, @FFrameBufferDepth);
Render.BindFrameBuffer(SGR_FRAMEBUFFER_EXT, FFrameBufferDepth);
Render.FrameBufferTexture2D(SGR_FRAMEBUFFER_EXT, SGR_COLOR_ATTACHMENT0_EXT, SGR_TEXTURE_2D, FTexDepth, 0);
Render.FrameBufferRenderBuffer(SGR_FRAMEBUFFER_EXT,SGR_DEPTH_ATTACHMENT_EXT, SGR_RENDERBUFFER_EXT, FRenderBufferDepth);
Render.BindFrameBuffer(SGR_FRAMEBUFFER_EXT, 0);
// Создаём текстуру FTexDepth2 - текстура прикреплённая как буффер глубины
Render.GenTextures(1, @FTexDepth2);
Render.BindTexture(SGR_TEXTURE_2D, FTexDepth2);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_MIN_FILTER, SGR_NEAREST);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_MAG_FILTER, SGR_NEAREST);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_WRAP_S, SGR_CLAMP);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_WRAP_T, SGR_CLAMP);
Render.TexImage2D(SGR_TEXTURE_2D, 0, SGR_DEPTH_COMPONENT24, FTexDepthSizeX, FTexDepthSizeY, 0, SGR_DEPTH_COMPONENT, SGR_UNSIGNED_SHORT, nil);
Render.BindTexture(SGR_TEXTURE_2D, 0);
// Создаём фреймбуффер
Render.GenFrameBuffers(1, @FFrameBufferDepth2);
Render.BindFrameBuffer(SGR_FRAMEBUFFER_EXT, FFrameBufferDepth2);
Render.DrawBuffer(SGR_NONE);
Render.ReadBuffer(SGR_NONE);
Render.FrameBufferTexture2D(SGR_FRAMEBUFFER_EXT, SGR_DEPTH_ATTACHMENT_EXT, SGR_TEXTURE_2D, FTexDepth2, 0);
Render.BindFrameBuffer(SGR_FRAMEBUFFER_EXT, 0);

FShaderDepth := SGCreateShaderProgramFromSources(Context,
	SGReadShaderSourceFromFile(SGExamplesDirectory + DirectorySeparator + '14' + DirectorySeparator + 'depth.vert'),
	SGReadShaderSourceFromFile(SGExamplesDirectory + DirectorySeparator + '14' + DirectorySeparator + 'depth.frag'));
FShaderShadowTex2D := SGCreateShaderProgramFromSources(Context,
	SGReadShaderSourceFromFile(SGExamplesDirectory + DirectorySeparator + '14' + DirectorySeparator + 'shadow.vert'),
	SGReadShaderSourceFromFile(SGExamplesDirectory + DirectorySeparator + '14' + DirectorySeparator + 'shadow_tex2D.frag'));
FShaderShadowShad2D := SGCreateShaderProgramFromSources(Context,
	SGReadShaderSourceFromFile(SGExamplesDirectory + DirectorySeparator + '14' + DirectorySeparator + 'shadow.vert'),
	SGReadShaderSourceFromFile(SGExamplesDirectory + DirectorySeparator + '14' + DirectorySeparator + 'shadow_shad2D.frag'));


FUniformShadowTex2D_shadowMap    := FShaderShadowTex2D.GetUniformLocation('shadowMap');
FUniformShadowTex2D_lightMatrix  := FShaderShadowTex2D.GetUniformLocation('lightMatrix');
FUniformShadowTex2D_lightPos     := FShaderShadowTex2D.GetUniformLocation('lightPos');
FUniformShadowTex2D_lightDir     := FShaderShadowTex2D.GetUniformLocation('lightDir');

FUniformShadowShad2D_shadowMap   := FShaderShadowShad2D.GetUniformLocation('shadowMap');
FUniformShadowShad2D_lightMatrix := FShaderShadowShad2D.GetUniformLocation('lightMatrix');
FUniformShadowShad2D_lightPos    := FShaderShadowShad2D.GetUniformLocation('lightPos');
FUniformShadowShad2D_lightDir    := FShaderShadowShad2D.GetUniformLocation('lightDir');

LoadModel(SGExamplesDirectory + DirectorySeparator + '14' + DirectorySeparator + 'model.bin');
LoadLigthModel();
end;

destructor TSGExample14.Destroy();
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

procedure TSGExample14.DrawPlane();
// Плоскость не отбрасывает тень, поэтому она не рендерится в текстуру глубины
const
	PlaneSize = 35.0;
	NumTriangles = 50;
var
	PlaneHeight : TSGFloat;
	x,y,a : TSGFloat;
	i : TSGLongWord;
begin
PlaneHeight := FModelCenter.y * 0.005 + 4.36;
Render.Color3f(0.4,0.5,0.6);

x := sin(0) * PlaneSize;
y := cos(0) * PlaneSize;
a := PI*2/50;
Render.BeginScene(SGR_TRIANGLES);
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

procedure TSGExample14.RenderToShadowMap();
begin
Render.Viewport(0,0,FTexDepthSizeX,FTexDepthSizeY);
if (FShadowRenderType) then
	begin // Вариант #1
	Render.BindFrameBuffer(SGR_FRAMEBUFFER_EXT, FFrameBufferDepth);
	// Очищать текстуру нужно значением соответствующим дальней плоскости отсечения
	Render.ClearColor(1,1,1,1);
	Render.Clear(SGR_COLOR_BUFFER_BIT or SGR_DEPTH_BUFFER_BIT);
	end
else
	begin // Вариант #2
	Render.BindFrameBuffer(SGR_FRAMEBUFFER_EXT,FFrameBufferDepth2);
	// В этом случае у нас нет буфера цвета, поэтому очищать его не нужно
	Render.Clear(SGR_DEPTH_BUFFER_BIT);
	end;
// Сдвиг полигонов - нужен для того, чтобы не было z-fighting'а
Render.Enable(SGR_POLYGON_OFFSET_FILL);
Render.PolygonOffset ( 2, 500);

// Сохраняем эти матрицы, они нам понадобятся для расчёта матрицы света
FLightProjectionMatrix := SGGetPerspectiveMatrix(50.0, 1.0, TSGRenderNear, TSGRenderFar);
FLightModelViewMatrix  := SGGetLookAtMatrix(FLightPos, FLightEye, FLightUp);

// Установить матрицы камеры света
Render.MatrixMode(SGR_PROJECTION);
Render.LoadIdentity();
Render.MultMatrixf(@FLightProjectionMatrix);
Render.MatrixMode(SGR_MODELVIEW);
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

Render.Disable(SGR_POLYGON_OFFSET_FILL);
Render.BindFrameBuffer(SGR_FRAMEBUFFER_EXT, 0);
end;

procedure TSGExample14.DrawModel();
begin
Render.Color3f(0.9,0.9,0.9);
Render.PushMatrix();
Render.Scale(0.005,0.005,0.005);
Render.Translatef(-FModelCenter.x,-FModelCenter.y,-FModelCenter.z);
FModel.Paint();
Render.PopMatrix();
end;

procedure TSGExample14.RenderShadowedScene();
var
	FShaderShadow : TSGShaderProgram = nil;
	FUniformShadow_lightDir    : TSGLongWord = 0;
	FUniformShadow_lightMatrix : TSGLongWord = 0;
	FUniformShadow_lightPos    : TSGLongWord = 0;
	FUniformShadow_shadowMap   : TSGLongWord = 0;
	{FMVLightPos,} FLightDir     : TSGVertex3f;
	FLightInverseModelViewMatrix : TSGMatrix4;
begin
Render.Viewport(0,0,Context.Width,Context.Height);
Render.ClearColor(0,0,0,1);
Render.Clear(SGR_COLOR_BUFFER_BIT or SGR_DEPTH_BUFFER_BIT);

// Устанавливаем матрицы камеры
FCamera.CallAction();

// Сохраняем матрицы, они нам нужны для вычисления освещения
// Инвертированная матрица используется в расчёте матрицы источника света
FCameraProjectionMatrix := FCamera.GetProjectionMatrix();
FCameraModelViewMatrix := FCamera.GetModelViewMatrix();
FCameraInverseModelViewMatrix := SGInverseMatrix(FCameraModelViewMatrix);

FLightMatrix := FCameraInverseModelViewMatrix *
	FLightModelViewMatrix * 
	FLightProjectionMatrix *
	SGGetScaleMatrix(SGVertex3fImport(0.5,0.5,0.5)) *
	SGGetTranslateMatrix(SGVertex3fImport(0.5,0.5,0.5));

if FShadowRenderType then
	begin // Вариант #1
	Render.BindTexture(SGR_TEXTURE_2D, FTexDepth);
	
	FShaderShadow := FShaderShadowTex2D;
	FUniformShadow_lightDir    := FUniformShadowTex2D_lightDir;
	FUniformShadow_lightMatrix := FUniformShadowTex2D_lightMatrix;
	FUniformShadow_lightPos    := FUniformShadowTex2D_lightPos;
	FUniformShadow_shadowMap   := FUniformShadowTex2D_shadowMap;
	end
else
	begin // Вариант #2
	Render.BindTexture(SGR_TEXTURE_2D, FTexDepth2);
	
	// Для второго варианта включаем режим сравнения текстуры
	Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_COMPARE_MODE, SGR_COMPARE_R_TO_TEXTURE);
	Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_COMPARE_FUNC, SGR_LEQUAL);
	
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
	Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_COMPARE_MODE,SGR_NONE);
	end;
Render.BindTexture(SGR_TEXTURE_2D, 0);

// Отображаем положение источника света
Render.PushMatrix();
FLightInverseModelViewMatrix := SGInverseMatrix(FLightModelViewMatrix);
Render.MultMatrixf(@FLightInverseModelViewMatrix);
FLigthSphere.Paint();
Render.PopMatrix();

{
Render.BeginScene(SGR_LINES);
FLightPos.Vertex(Render);
(FLightPos + FLightDir * 10).Vertex(Render);
Render.EndScene();
}
end;

procedure TSGExample14.Paint();
begin
FLightPos.Import(30 * cos (FLightAngle), 40, 30 * sin(FLightAngle));

// Рисование происходит в два этапа:
RenderToShadowMap();				// 1) Рисуем в текстуру глубины с позиции источника света
RenderShadowedScene();				// 2) Рисуем нашу сцену на экран

if (FUseLightAnimation) then
	FLightAngle += Context.ElapsedTime / 200;

KeyboardUpCallback();
end;

procedure TSGExample14.KeyboardUpCallback();
begin
if (Context.KeyPressed and (Context.KeyPressedType = SGUpKey)) then
	case Context.KeyPressedChar of
	' ' : FUseLightAnimation := not FUseLightAnimation;
	'1' : FShadowRenderType := True;
	'2' : FShadowRenderType := False;
	'3' : 
		begin
		Render.Enable(SGR_TEXTURE_2D);
		Render.BindTexture(SGR_TEXTURE_2D,FTexDepth);
		Render.TexParameteri(SGR_TEXTURE_2D,SGR_TEXTURE_MAG_FILTER, SGR_LINEAR);
		Render.TexParameteri(SGR_TEXTURE_2D,SGR_TEXTURE_MIN_FILTER, SGR_LINEAR);
		Render.BindTexture(SGR_TEXTURE_2D,FTexDepth2);
		Render.TexParameteri(SGR_TEXTURE_2D,SGR_TEXTURE_MAG_FILTER, SGR_LINEAR);
		Render.TexParameteri(SGR_TEXTURE_2D,SGR_TEXTURE_MIN_FILTER, SGR_LINEAR);
		Render.BindTexture(SGR_TEXTURE_2D,0);
		Render.Disable(SGR_TEXTURE_2D);
		end;
	'4' : 
		begin
		Render.Enable(SGR_TEXTURE_2D);
		Render.BindTexture(SGR_TEXTURE_2D,FTexDepth);
		Render.TexParameteri(SGR_TEXTURE_2D,SGR_TEXTURE_MAG_FILTER, SGR_NEAREST);
		Render.TexParameteri(SGR_TEXTURE_2D,SGR_TEXTURE_MIN_FILTER, SGR_NEAREST);
		Render.BindTexture(SGR_TEXTURE_2D,FTexDepth2);
		Render.TexParameteri(SGR_TEXTURE_2D,SGR_TEXTURE_MAG_FILTER, SGR_NEAREST);
		Render.TexParameteri(SGR_TEXTURE_2D,SGR_TEXTURE_MIN_FILTER, SGR_NEAREST);
		Render.BindTexture(SGR_TEXTURE_2D,0);
		Render.Disable(SGR_TEXTURE_2D);
		end;
	end;
end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample14;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
