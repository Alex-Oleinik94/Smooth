{$INCLUDE SaGe.inc}

unit Ex15_Shadow;

interface

uses
	 SaGeCommonClasses
	,SaGeBase
	,SaGeRenderBase
	,SaGeCommonStructs
	,SaGeShaders
	,SaGeImage
	,SaGeMatrix
	
	,Crt
	
	,Ex5_Physics
	,Ex13_Model
	;

type
	TSGExample15_Shadow = class(TSGContextabled)
			public
		constructor Create(const VContext : ISGContext;const Lights : TSGLongWord = 1; const BonesCount : TSGLongWord = 32;const TextureBlock : TSGTextureBlock = nil);
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			public
		procedure BeginDrawToShadow(const LightIndex : TSGLongWord = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure EndDrawToShadow();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure BeginDrawScene();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure EndDrawScene();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure KeyboardCallback();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetCurrentShader():TSGShaderProgram;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure UniformScrene();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure CreateTextureAndFrame(var VTexture, VFrame : TSGLongWord;const TextureBlock : TSGTextureBlock; const VRenderBuffer : PSGLongWord = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			private
		FInDrawToShadow : TSGBoolean;
		FInDrawScene    : TSGBoolean;
		FLightsCount    : TSGLongWord;
		
		FLights : packed array of
			packed record
				FLightPos : TSGVertex3f;
				FLightEye : TSGVertex3f;
				FLightUp  : TSGVertex3f;
				FLightDir : TSGVertex3f;
				FLightAngle : TSGFloat;
				
				FTexDepth  : TSGLongWord;
				FTexDepth2 : TSGLongWord;
				
				FFrameBufferDepth, 
					FFrameBufferDepth2,
					FRenderBufferDepth : TSGLongWord;
				
				FLightProjectionMatrix,
					FLightModelViewMatrix,
					FLightMatrix : TSGMatrix4x4;
				
				FUniformShadowTex2D_shadowMap,
					FUniformShadowTex2D_lightMatrix,
					FUniformShadowTex2D_lightPos,
					FUniformShadowTex2D_lightDir,
					FUniformShadowShad2D_shadowMap,
					FUniformShadowShad2D_lightMatrix,
					FUniformShadowShad2D_lightPos,
					FUniformShadowShad2D_lightDir : TSGLongWord;
				
				FUniformShadow_lightDir    : TSGLongWord;
				FUniformShadow_lightMatrix : TSGLongWord;
				FUniformShadow_lightPos    : TSGLongWord;
				FUniformShadow_shadowMap   : TSGLongWord;
				end;
		
		FTexDepthSizeX, FTexDepthSizeY : TSGLongWord;
		// Шейдерные программы и uniform'ы
		FShaderDepthTex2D,
			FShaderDepthShad2D,
			FShaderShadowTex2D,
			FShaderShadowShad2D : TSGShaderProgram;
		
		// Матрицы
		FCameraProjectionMatrix,
			FCameraModelViewMatrix,
			FCameraInverseModelViewMatrix : TSGMatrix4x4;
		
		FShadowRenderType  : TSGBoolean;
		
		FShaderShadow : TSGShaderProgram;
			private
		function GetLightAngle(const index : TSGLongWord):TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetLightAngle(const index : TSGLongWord; const VAngle : TSGFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetLightModelViewMatrix(const index : TSGLongWord):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetLightPos(const index : TSGLongWord):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetLightPos(const index : TSGLongWord; const VPos : TSGVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetLightEye(const index : TSGLongWord; const VEye : TSGVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetLightUp(const index : TSGLongWord; const VUp : TSGVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetLightDir(const index : TSGLongWord):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property LightAngle [index : TSGLongWord]: TSGFloat read  GetLightAngle write SetLightAngle;
		property CameraProjectionMatrix : TSGMatrix4x4  write FCameraProjectionMatrix;
		property CameraModelViewMatrix  : TSGMatrix4x4  write FCameraModelViewMatrix;
		property LightModelViewMatrix [index : TSGLongWord] : TSGMatrix4x4  read  GetLightModelViewMatrix;
		property LightPos [index : TSGLongWord] : TSGVertex3f read  GetLightPos write SetLightPos;
		property LightEye [index : TSGLongWord] : TSGVertex3f write SetLightEye;
		property LightUp  [index : TSGLongWord] : TSGVertex3f write SetLightUp;
		property LightDir [index : TSGLongWord] : TSGVertex3f read  GetLightDir;
		property DrawingShadow          : TSGBoolean  read  FInDrawToShadow;
		property DrawingScene           : TSGBoolean  read  FInDrawScene;
		end;

implementation

uses
	 SaGeStringUtils
	,SaGeFileUtils
	;

function TSGExample15_Shadow.GetLightAngle(const index : TSGLongWord):TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FLights[index].FLightAngle;
end;

procedure TSGExample15_Shadow.SetLightAngle(const index : TSGLongWord; const VAngle : TSGFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FLights[index].FLightAngle := VAngle;
end;

function TSGExample15_Shadow.GetLightModelViewMatrix(const index : TSGLongWord):TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FLights[index].FLightModelViewMatrix;
end;

function TSGExample15_Shadow.GetLightPos(const index : TSGLongWord):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FLights[index].FLightPos;
end;

procedure TSGExample15_Shadow.SetLightPos(const index : TSGLongWord; const VPos : TSGVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FLights[index].FLightPos := VPos;
end;

procedure TSGExample15_Shadow.SetLightEye(const index : TSGLongWord; const VEye : TSGVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FLights[index].FLightEye := VEye;
end;

procedure TSGExample15_Shadow.SetLightUp(const index : TSGLongWord; const VUp : TSGVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FLights[index].FLightUp := VUp;
end;

function TSGExample15_Shadow.GetLightDir(const index : TSGLongWord):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FLights[index].FLightDir;
end;

function TSGExample15_Shadow.GetCurrentShader() : TSGShaderProgram; 
begin
if FInDrawScene then
	if FShadowRenderType then
		Result := FShaderShadowTex2D
	else
		Result := FShaderShadowShad2D
else if FInDrawToShadow then
	if FShadowRenderType then
		Result := FShaderDepthTex2D
	else
		Result := FShaderDepthShad2D
else
	Result := nil;
end;

procedure TSGExample15_Shadow.KeyboardCallback();
var
	i : TSGLongWord;
begin
if (Context.KeyPressed and (Context.KeyPressedType = SGUpKey)) then
	case Context.KeyPressedChar of
	'1' : FShadowRenderType := True;
	'2' : FShadowRenderType := False;
	'3' : 
		begin
		Render.Enable(SGR_TEXTURE_2D);
		for i := 0 to FLightsCount - 1 do
			begin
			Render.BindTexture(SGR_TEXTURE_2D,FLights[i].FTexDepth);
			Render.TexParameteri(SGR_TEXTURE_2D,SGR_TEXTURE_MAG_FILTER, SGR_LINEAR);
			Render.TexParameteri(SGR_TEXTURE_2D,SGR_TEXTURE_MIN_FILTER, SGR_LINEAR);
			Render.BindTexture(SGR_TEXTURE_2D,FLights[i].FTexDepth2);
			Render.TexParameteri(SGR_TEXTURE_2D,SGR_TEXTURE_MAG_FILTER, SGR_LINEAR);
			Render.TexParameteri(SGR_TEXTURE_2D,SGR_TEXTURE_MIN_FILTER, SGR_LINEAR);
			end;
		Render.BindTexture(SGR_TEXTURE_2D,0);
		Render.Disable(SGR_TEXTURE_2D);
		end;
	'4' : 
		begin
		Render.Enable(SGR_TEXTURE_2D);
		for i := 0 to FLightsCount - 1 do
			begin
			Render.BindTexture(SGR_TEXTURE_2D,FLights[i].FTexDepth);
			Render.TexParameteri(SGR_TEXTURE_2D,SGR_TEXTURE_MAG_FILTER, SGR_NEAREST);
			Render.TexParameteri(SGR_TEXTURE_2D,SGR_TEXTURE_MIN_FILTER, SGR_NEAREST);
			Render.BindTexture(SGR_TEXTURE_2D,FLights[i].FTexDepth2);
			Render.TexParameteri(SGR_TEXTURE_2D,SGR_TEXTURE_MAG_FILTER, SGR_NEAREST);
			Render.TexParameteri(SGR_TEXTURE_2D,SGR_TEXTURE_MIN_FILTER, SGR_NEAREST);
			end;
		Render.BindTexture(SGR_TEXTURE_2D,0);
		Render.Disable(SGR_TEXTURE_2D);
		end;
	end;
end;

procedure TSGExample15_Shadow.CreateTextureAndFrame(var VTexture, VFrame : TSGLongWord;const TextureBlock : TSGTextureBlock; const VRenderBuffer : PSGLongWord = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if TextureBlock = nil then
	Render.GenTextures(1, @VTexture)
else
	VTexture := TextureBlock.GetNextUnusebleTexture();
Render.BindTexture(SGR_TEXTURE_2D, VTexture);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_MIN_FILTER, SGR_NEAREST);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_MAG_FILTER, SGR_NEAREST);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_WRAP_S, SGR_CLAMP);
Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_WRAP_T, SGR_CLAMP);
if VRenderBuffer = nil then
	// Создаём текстуру - текстура прикреплённая как буффер глубины
	Render.TexImage2D(SGR_TEXTURE_2D, 0, SGR_DEPTH_COMPONENT24, FTexDepthSizeX, FTexDepthSizeY, 0, SGR_DEPTH_COMPONENT, SGR_UNSIGNED_SHORT, nil)
else
	// Создаём текстуру - текстура прикреплённая как буффер цвета, для теста глубины мы создадим рендербуффер
	if Render.SupporedDepthTextures() then
		Render.TexImage2D(SGR_TEXTURE_2D, 0, SGR_R16, FTexDepthSizeX, FTexDepthSizeY, 0, SGR_RED, SGR_UNSIGNED_SHORT, nil)
	else
		Render.TexImage2D(SGR_TEXTURE_2D, 0, SGR_RGBA16, FTexDepthSizeX, FTexDepthSizeY, 0, SGR_RGBA, SGR_UNSIGNED_SHORT, nil);
Render.BindTexture(SGR_TEXTURE_2D,0);
if VRenderBuffer <> nil then
	begin
	// Создаём рендербуффер глубины
	Render.GenRenderBuffers(1,VRenderBuffer);
	Render.BindRenderBuffer(SGR_RENDERBUFFER_EXT, VRenderBuffer^);
	Render.RenderBufferStorage(SGR_RENDERBUFFER_EXT, SGR_DEPTH_COMPONENT24, FTexDepthSizeX, FTexDepthSizeY);
	Render.BindRenderBuffer(SGR_RENDERBUFFER_EXT, 0);
	end;
// Создаём фреймбуффер
Render.GenFrameBuffers(1, @VFrame);
Render.BindFrameBuffer(SGR_FRAMEBUFFER_EXT, VFrame);
if VRenderBuffer = nil then
	begin
	Render.DrawBuffer(SGR_NONE);
	Render.ReadBuffer(SGR_NONE);
	Render.FrameBufferTexture2D(SGR_FRAMEBUFFER_EXT, SGR_DEPTH_ATTACHMENT_EXT, SGR_TEXTURE_2D, VTexture, 0);
	end
else
	begin
	Render.FrameBufferTexture2D(SGR_FRAMEBUFFER_EXT, SGR_COLOR_ATTACHMENT0_EXT, SGR_TEXTURE_2D, VTexture, 0);
	Render.FrameBufferRenderBuffer(SGR_FRAMEBUFFER_EXT,SGR_DEPTH_ATTACHMENT_EXT, SGR_RENDERBUFFER_EXT, VRenderBuffer^);
	end;
Render.BindFrameBuffer(SGR_FRAMEBUFFER_EXT, 0);
end;

constructor TSGExample15_Shadow.Create(const VContext : ISGContext;const Lights : TSGLongWord = 1; const BonesCount : TSGLongWord = 32; const TextureBlock : TSGTextureBlock = nil);
const
	TexSize = 4096;
	Example15Dir = SGExamplesDirectory + DirectorySeparator + '15' +DirectorySeparator;
var
	i : TSGLongWord;
begin
FLightsCount := 0;
inherited Create(VContext);
FInDrawToShadow := False;
FInDrawScene    := False;
FLightsCount := Lights;
FShadowRenderType  := False;

FShaderShadowShad2D := nil;
FShaderShadowTex2D  := nil;
FShaderDepthTex2D   := nil;
FShaderDepthShad2D  := nil;

FTexDepthSizeX := TexSize;
FTexDepthSizeY := TexSize;

SetLength(FLights,FLightsCount);

for i := 0 to FLightsCount - 1 do
	begin
	FLights[i].FTexDepth  := 0;
	FLights[i].FTexDepth2 := 0;
	FLights[i].FLightAngle := PI/2;
	FLights[i].FLightPos.Import(0,0,0);
	FLights[i].FLightUp.Import(0,1,0);
	FLights[i].FLightEye.Import(0,0,0);
	FLights[i].FFrameBufferDepth  := 0;
	FLights[i].FFrameBufferDepth2 := 0;
	FLights[i].FRenderBufferDepth := 0;
	
	FLights[i].FUniformShadowShad2D_lightDir    := 0;
	FLights[i].FUniformShadowShad2D_lightMatrix := 0;
	FLights[i].FUniformShadowShad2D_lightPos    := 0;
	FLights[i].FUniformShadowShad2D_shadowMap   := 0;
	FLights[i].FUniformShadowTex2D_lightDir     := 0;
	FLights[i].FUniformShadowTex2D_lightMatrix  := 0;
	FLights[i].FUniformShadowTex2D_lightPos     := 0;
	FLights[i].FUniformShadowTex2D_shadowMap    := 0;
	
	CreateTextureAndFrame(FLights[i].FTexDepth2,FLights[i].FFrameBufferDepth2,TextureBlock);
	CreateTextureAndFrame(FLights[i].FTexDepth,FLights[i].FFrameBufferDepth,TextureBlock,@FLights[i].FRenderBufferDepth);
	end;

FShaderDepthTex2D := SGCreateShaderProgramFromSources(Context,
	SGReadShaderSourceFromFile(Example15Dir + 'main_depth.vert',[BonesCount]),
	SGReadShaderSourceFromFile(Example15Dir + 'main_depth.frag',['texture']));
FShaderDepthShad2D := SGCreateShaderProgramFromSources(Context,
	SGReadShaderSourceFromFile(Example15Dir + 'main_depth.vert',[BonesCount]),
	SGReadShaderSourceFromFile(Example15Dir + 'main_depth.frag',['shadow']));
FShaderShadowTex2D := SGCreateShaderProgramFromSources(Context,
	SGReadShaderSourceFromFile(Example15Dir + 'main.vert',[FLightsCount, BonesCount]),
	SGReadShaderSourceFromFile(Example15Dir + 'main.frag',['texture', FLightsCount]));
FShaderShadowShad2D := SGCreateShaderProgramFromSources(Context,
	SGReadShaderSourceFromFile(Example15Dir + 'main.vert',[FLightsCount, BonesCount]),
	SGReadShaderSourceFromFile(Example15Dir + 'main.frag',['shadow', FLightsCount]));

//SGReadAndSaveShaderSourceFile(Example15Dir + 'main.vert','main_shadow.vert',[FLightsCount, BonesCount]);
//SGReadAndSaveShaderSourceFile(Example15Dir + 'main.frag','main_shadow.frag',['shadow', FLightsCount]);

for i := 0 to FLightsCount - 1 do
	begin
	FLights[i].FUniformShadowTex2D_shadowMap    := FShaderShadowTex2D.GetUniformLocation('shadowMap'+SGStr(i));
	FLights[i].FUniformShadowTex2D_lightMatrix  := FShaderShadowTex2D.GetUniformLocation('lightMatrix'+SGStr(i));
	FLights[i].FUniformShadowTex2D_lightPos     := FShaderShadowTex2D.GetUniformLocation('lightPos'+SGStr(i));
	FLights[i].FUniformShadowTex2D_lightDir     := FShaderShadowTex2D.GetUniformLocation('lightDir'+SGStr(i));

	FLights[i].FUniformShadowShad2D_shadowMap   := FShaderShadowShad2D.GetUniformLocation('shadowMap'+SGStr(i));
	FLights[i].FUniformShadowShad2D_lightMatrix := FShaderShadowShad2D.GetUniformLocation('lightMatrix'+SGStr(i));
	FLights[i].FUniformShadowShad2D_lightPos    := FShaderShadowShad2D.GetUniformLocation('lightPos'+SGStr(i));
	FLights[i].FUniformShadowShad2D_lightDir    := FShaderShadowShad2D.GetUniformLocation('lightDir'+SGStr(i));
	end;
end;

destructor TSGExample15_Shadow.Destroy();
var
	i : TSGLongWord;
begin
if (FLightsCount > 0) and (FLights <> nil) then
	for i :=0 to FLightsCount - 1 do
		if (i<=High(FLights)) then
			begin
			Render.DeleteTextures(1,@FLights[i].FTexDepth);
			Render.DeleteTextures(1,@FLights[i].FTexDepth2);
			end;
if FShaderDepthTex2D <> nil then
	FShaderDepthTex2D.Destroy();
if FShaderDepthShad2D <> nil then
	FShaderDepthShad2D.Destroy();
if FShaderShadowTex2D <> nil then
	FShaderShadowTex2D.Destroy();
if FShaderShadowShad2D <> nil then
	FShaderShadowShad2D.Destroy();
inherited;
end;

class function TSGExample15_Shadow.ClassName():TSGString;
begin
Result := 'TSGExample15_Shadow';
end;

procedure TSGExample15_Shadow.BeginDrawToShadow(const LightIndex : TSGLongWord = 0);
begin
Render.Viewport(0,0,FTexDepthSizeX,FTexDepthSizeY);
if (FShadowRenderType) then
	begin // Вариант #1
	Render.BindFrameBuffer(SGR_FRAMEBUFFER_EXT, FLights[LightIndex].FFrameBufferDepth);
	// Очищать текстуру нужно значением соответствующим дальней плоскости отсечения
	Render.ClearColor(1,1,1,1);
	Render.Clear(SGR_COLOR_BUFFER_BIT or SGR_DEPTH_BUFFER_BIT);
	end
else
	begin // Вариант #2
	Render.BindFrameBuffer(SGR_FRAMEBUFFER_EXT,FLights[LightIndex].FFrameBufferDepth2);
	// В этом случае у нас нет буфера цвета, поэтому очищать его не нужно
	Render.Clear(SGR_DEPTH_BUFFER_BIT);
	end;
// Сдвиг полигонов - нужен для того, чтобы не было z-fighting'а
Render.Enable(SGR_POLYGON_OFFSET_FILL);
Render.PolygonOffset ( 2, 500);

// Сохраняем эти матрицы, они нам понадобятся для расчёта матрицы света
FLights[LightIndex].FLightProjectionMatrix := SGGetPerspectiveMatrix(FLights[LightIndex].FLightAngle /PI * 180, 1.0, TSGRenderNear, TSGRenderFar);
FLights[LightIndex].FLightModelViewMatrix  := SGGetLookAtMatrix(FLights[LightIndex].FLightPos, FLights[LightIndex].FLightEye, FLights[LightIndex].FLightUp);

// Установить матрицы камеры света
Render.MatrixMode(SGR_PROJECTION);
Render.LoadIdentity();
Render.MultMatrixf(@FLights[LightIndex].FLightProjectionMatrix);
Render.MatrixMode(SGR_MODELVIEW);
Render.LoadIdentity();
Render.MultMatrixf(@FLights[LightIndex].FLightModelViewMatrix);

// Напомню, что в первом варианте нам нужен шейдер, чтобы сохранить глубину в текстуру, во втором это не к чему.
if FShadowRenderType then
	begin // Вариант #1
	FShaderDepthTex2D.Use();
	end
else
	FShaderDepthShad2D.Use();
FInDrawToShadow := True;
end;

procedure TSGExample15_Shadow.EndDrawToShadow();
begin
FInDrawToShadow := False;
// Напомню, что в первом варианте нам нужен шейдер, чтобы сохранить глубину в текстуру, во втором это не к чему.
//if FShadowRenderType then
	//begin // Вариант #1
	Render.UseProgram(0);
	//end;

Render.Disable(SGR_POLYGON_OFFSET_FILL);
Render.BindFrameBuffer(SGR_FRAMEBUFFER_EXT, 0);
end;

procedure TSGExample15_Shadow.UniformScrene();
var
	FMVLightPos : TSGVertex3f;
	i : TSGLongWord;
begin
// Сохраняем матрицы, они нам нужны для вычисления освещения
// Инвертированная матрица используется в расчёте матрицы источника света
{FCameraProjectionMatrix :=} (*import*) {;}
{FCameraModelViewMatrix  :=} (*import*) {;}
FCameraInverseModelViewMatrix := SGInverseMatrix(FCameraModelViewMatrix);

for i := 0 to FLightsCount - 1 do
	begin
	FLights[i].FLightMatrix := FCameraInverseModelViewMatrix *
		FLights[i].FLightModelViewMatrix * 
		FLights[i].FLightProjectionMatrix *
		SGScaleMatrix(SGVertex3fImport(0.5,0.5,0.5)) *
		SGTranslateMatrix(SGVertex3fImport(0.5,0.5,0.5));

	Render.Uniform1i(FLights[i].FUniformShadow_shadowMap, i + 7);
	Render.UniformMatrix4fv(FLights[i].FUniformShadow_lightMatrix, 1, False, @FLights[i].FLightMatrix );
	FMVLightPos := FLights[i].FLightPos * FCameraModelViewMatrix;
	Render.Uniform3f(FLights[i].FUniformShadow_lightPos, FLights[i].FLightPos.x, FLights[i].FLightPos.y, FLights[i].FLightPos.z);
	FLights[i].FLightDir := (FLights[i].FLightEye - FLights[i].FLightPos).Normalized();
	Render.Uniform3f(FLights[i].FUniformShadow_lightDir, FLights[i].FLightDir.x, FLights[i].FLightDir.y, FLights[i].FLightDir.z);
	end;
end;

procedure TSGExample15_Shadow.BeginDrawScene();
var
	ShaderShadow : TSGShaderProgram;
	i : TSGLongWord;
begin
Render.Viewport(0,0,Context.Width,Context.Height);

if FShadowRenderType then
	ShaderShadow := FShaderShadowTex2D
else
	ShaderShadow := FShaderShadowShad2D;

for i := 0 to FLightsCount - 1 do
	if FShadowRenderType then
		begin // Вариант #1
		Render.ActiveTexture(i + 7);
		//Render.Enable(SGR_TEXTURE_2D);
		Render.BindTexture(SGR_TEXTURE_2D, FLights[i].FTexDepth);
		
		FLights[i].FUniformShadow_lightDir    := FLights[i].FUniformShadowTex2D_lightDir;
		FLights[i].FUniformShadow_lightMatrix := FLights[i].FUniformShadowTex2D_lightMatrix;
		FLights[i].FUniformShadow_lightPos    := FLights[i].FUniformShadowTex2D_lightPos;
		FLights[i].FUniformShadow_shadowMap   := FLights[i].FUniformShadowTex2D_shadowMap;
		end
	else
		begin // Вариант #2
		Render.ActiveTexture(i + 7);
		//Render.Enable(SGR_TEXTURE_2D);
		Render.BindTexture(SGR_TEXTURE_2D, FLights[i].FTexDepth2);
		
		// Для второго варианта включаем режим сравнения текстуры
		Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_COMPARE_MODE, SGR_COMPARE_R_TO_TEXTURE);
		Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_COMPARE_FUNC, SGR_LEQUAL);
		
		FLights[i].FUniformShadow_lightDir    := FLights[i].FUniformShadowShad2D_lightDir;
		FLights[i].FUniformShadow_lightMatrix := FLights[i].FUniformShadowShad2D_lightMatrix;
		FLights[i].FUniformShadow_lightPos    := FLights[i].FUniformShadowShad2D_lightPos;
		FLights[i].FUniformShadow_shadowMap   := FLights[i].FUniformShadowShad2D_shadowMap;
		end;

FInDrawScene    := True;
UniformScrene();
Render.ActiveTexture(0);
ShaderShadow.Use();
end;

procedure TSGExample15_Shadow.EndDrawScene();
var
	i : TSGLongWord;
begin
FInDrawScene    := False;
Render.UseProgram(0);
for i := 0 to FLightsCount - 1 do
	begin
	Render.ActiveTexture(i + 7);

	if (not FShadowRenderType) then
		begin // Вариант #2
		// Не забываем выключать режим сравнения
		Render.TexParameteri(SGR_TEXTURE_2D, SGR_TEXTURE_COMPARE_MODE,SGR_NONE);
		end;
	Render.BindTexture(SGR_TEXTURE_2D, 0);
	//Render.Disable(SGR_TEXTURE_2D);
	end;

Render.ActiveTexture(0);
end;

end.
