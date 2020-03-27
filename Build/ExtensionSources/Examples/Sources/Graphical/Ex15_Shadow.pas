{$INCLUDE Smooth.inc}

unit Ex15_Shadow;

interface

uses
	 SmoothContextInterface
	,SmoothContextClasses
	,SmoothBase
	,SmoothRenderBase
	,SmoothCommonStructs
	,SmoothShaders
	,SmoothImage
	,SmoothMatrix
	,SmoothShaderReader
	
	,Crt
	
	,Ex5_Physics
	,Ex13_Model
	;

type
	TSExample15_Shadow = class(TSContextObject)
			public
		constructor Create(const VContext : ISContext;const Lights : TSLongWord = 1; const BonesCount : TSLongWord = 32;const TextureBlock : TSTextureBlock = nil);
		destructor Destroy();override;
		class function ClassName():TSString;override;
			public
		procedure BeginDrawToShadow(const LightIndex : TSLongWord = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure EndDrawToShadow();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure BeginDrawScene();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure EndDrawScene();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure KeyboardCallback();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetCurrentShader():TSShaderProgram;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure UniformScrene();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure CreateTextureAndFrame(var VTexture, VFrame : TSLongWord;const TextureBlock : TSTextureBlock; const VRenderBuffer : PSLongWord = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			private
		FInDrawToShadow : TSBoolean;
		FInDrawScene    : TSBoolean;
		FLightsCount    : TSLongWord;
		
		FLights : packed array of
			packed record
				FLightPos : TSVertex3f;
				FLightEye : TSVertex3f;
				FLightUp  : TSVertex3f;
				FLightDir : TSVertex3f;
				FLightAngle : TSFloat;
				
				FTexDepth  : TSLongWord;
				FTexDepth2 : TSLongWord;
				
				FFrameBufferDepth, 
					FFrameBufferDepth2,
					FRenderBufferDepth : TSLongWord;
				
				FLightProjectionMatrix,
					FLightModelViewMatrix,
					FLightMatrix : TSMatrix4x4;
				
				FUniformShadowTex2D_shadowMap,
					FUniformShadowTex2D_lightMatrix,
					FUniformShadowTex2D_lightPos,
					FUniformShadowTex2D_lightDir,
					FUniformShadowShad2D_shadowMap,
					FUniformShadowShad2D_lightMatrix,
					FUniformShadowShad2D_lightPos,
					FUniformShadowShad2D_lightDir : TSLongWord;
				
				FUniformShadow_lightDir    : TSLongWord;
				FUniformShadow_lightMatrix : TSLongWord;
				FUniformShadow_lightPos    : TSLongWord;
				FUniformShadow_shadowMap   : TSLongWord;
				end;
		
		FTexDepthSizeX, FTexDepthSizeY : TSLongWord;
		// Шейдерные программы и uniform'ы
		FShaderDepthTex2D,
			FShaderDepthShad2D,
			FShaderShadowTex2D,
			FShaderShadowShad2D : TSShaderProgram;
		
		// Матрицы
		FCameraProjectionMatrix,
			FCameraModelViewMatrix,
			FCameraInverseModelViewMatrix : TSMatrix4x4;
		
		FShadowRenderType  : TSBoolean;
		
		FShaderShadow : TSShaderProgram;
			private
		function GetLightAngle(const index : TSLongWord):TSFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetLightAngle(const index : TSLongWord; const VAngle : TSFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetLightModelViewMatrix(const index : TSLongWord):TSMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetLightPos(const index : TSLongWord):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetLightPos(const index : TSLongWord; const VPos : TSVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetLightEye(const index : TSLongWord; const VEye : TSVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetLightUp(const index : TSLongWord; const VUp : TSVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetLightDir(const index : TSLongWord):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property LightAngle [index : TSLongWord]: TSFloat read  GetLightAngle write SetLightAngle;
		property CameraProjectionMatrix : TSMatrix4x4  write FCameraProjectionMatrix;
		property CameraModelViewMatrix  : TSMatrix4x4  write FCameraModelViewMatrix;
		property LightModelViewMatrix [index : TSLongWord] : TSMatrix4x4  read  GetLightModelViewMatrix;
		property LightPos [index : TSLongWord] : TSVertex3f read  GetLightPos write SetLightPos;
		property LightEye [index : TSLongWord] : TSVertex3f write SetLightEye;
		property LightUp  [index : TSLongWord] : TSVertex3f write SetLightUp;
		property LightDir [index : TSLongWord] : TSVertex3f read  GetLightDir;
		property DrawingShadow          : TSBoolean  read  FInDrawToShadow;
		property DrawingScene           : TSBoolean  read  FInDrawScene;
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothFileUtils
	,SmoothContextUtils
	;

function TSExample15_Shadow.GetLightAngle(const index : TSLongWord):TSFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FLights[index].FLightAngle;
end;

procedure TSExample15_Shadow.SetLightAngle(const index : TSLongWord; const VAngle : TSFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FLights[index].FLightAngle := VAngle;
end;

function TSExample15_Shadow.GetLightModelViewMatrix(const index : TSLongWord):TSMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FLights[index].FLightModelViewMatrix;
end;

function TSExample15_Shadow.GetLightPos(const index : TSLongWord):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FLights[index].FLightPos;
end;

procedure TSExample15_Shadow.SetLightPos(const index : TSLongWord; const VPos : TSVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FLights[index].FLightPos := VPos;
end;

procedure TSExample15_Shadow.SetLightEye(const index : TSLongWord; const VEye : TSVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FLights[index].FLightEye := VEye;
end;

procedure TSExample15_Shadow.SetLightUp(const index : TSLongWord; const VUp : TSVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FLights[index].FLightUp := VUp;
end;

function TSExample15_Shadow.GetLightDir(const index : TSLongWord):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FLights[index].FLightDir;
end;

function TSExample15_Shadow.GetCurrentShader() : TSShaderProgram; 
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

procedure TSExample15_Shadow.KeyboardCallback();
var
	i : TSLongWord;
begin
if (Context.KeyPressed and (Context.KeyPressedType = SUpKey)) then
	case Context.KeyPressedChar of
	'1' : FShadowRenderType := True;
	'2' : FShadowRenderType := False;
	'3' : 
		begin
		Render.Enable(SR_TEXTURE_2D);
		for i := 0 to FLightsCount - 1 do
			begin
			Render.BindTexture(SR_TEXTURE_2D,FLights[i].FTexDepth);
			Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MAG_FILTER, SR_LINEAR);
			Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MIN_FILTER, SR_LINEAR);
			Render.BindTexture(SR_TEXTURE_2D,FLights[i].FTexDepth2);
			Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MAG_FILTER, SR_LINEAR);
			Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MIN_FILTER, SR_LINEAR);
			end;
		Render.BindTexture(SR_TEXTURE_2D,0);
		Render.Disable(SR_TEXTURE_2D);
		end;
	'4' : 
		begin
		Render.Enable(SR_TEXTURE_2D);
		for i := 0 to FLightsCount - 1 do
			begin
			Render.BindTexture(SR_TEXTURE_2D,FLights[i].FTexDepth);
			Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MAG_FILTER, SR_NEAREST);
			Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MIN_FILTER, SR_NEAREST);
			Render.BindTexture(SR_TEXTURE_2D,FLights[i].FTexDepth2);
			Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MAG_FILTER, SR_NEAREST);
			Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MIN_FILTER, SR_NEAREST);
			end;
		Render.BindTexture(SR_TEXTURE_2D,0);
		Render.Disable(SR_TEXTURE_2D);
		end;
	end;
end;

procedure TSExample15_Shadow.CreateTextureAndFrame(var VTexture, VFrame : TSLongWord;const TextureBlock : TSTextureBlock; const VRenderBuffer : PSLongWord = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if TextureBlock = nil then
	Render.GenTextures(1, @VTexture)
else
	VTexture := TextureBlock.GetNextUnusebleTexture();
Render.BindTexture(SR_TEXTURE_2D, VTexture);
Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_MIN_FILTER, SR_NEAREST);
Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_MAG_FILTER, SR_NEAREST);
Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_WRAP_S, SR_CLAMP);
Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_WRAP_T, SR_CLAMP);
if VRenderBuffer = nil then
	// Создаём текстуру - текстура прикреплённая как буффер глубины
	Render.TexImage2D(SR_TEXTURE_2D, 0, SR_DEPTH_COMPONENT24, FTexDepthSizeX, FTexDepthSizeY, 0, SR_DEPTH_COMPONENT, SR_UNSIGNED_SHORT, nil)
else
	// Создаём текстуру - текстура прикреплённая как буффер цвета, для теста глубины мы создадим рендербуффер
	if Render.SupportedDepthTextures() then
		Render.TexImage2D(SR_TEXTURE_2D, 0, SR_R16, FTexDepthSizeX, FTexDepthSizeY, 0, SR_RED, SR_UNSIGNED_SHORT, nil)
	else
		Render.TexImage2D(SR_TEXTURE_2D, 0, SR_RGBA16, FTexDepthSizeX, FTexDepthSizeY, 0, SR_RGBA, SR_UNSIGNED_SHORT, nil);
Render.BindTexture(SR_TEXTURE_2D,0);
if VRenderBuffer <> nil then
	begin
	// Создаём рендербуффер глубины
	Render.GenRenderBuffers(1,VRenderBuffer);
	Render.BindRenderBuffer(SR_RENDERBUFFER_EXT, VRenderBuffer^);
	Render.RenderBufferStorage(SR_RENDERBUFFER_EXT, SR_DEPTH_COMPONENT24, FTexDepthSizeX, FTexDepthSizeY);
	Render.BindRenderBuffer(SR_RENDERBUFFER_EXT, 0);
	end;
// Создаём фреймбуффер
Render.GenFrameBuffers(1, @VFrame);
Render.BindFrameBuffer(SR_FRAMEBUFFER_EXT, VFrame);
if VRenderBuffer = nil then
	begin
	Render.DrawBuffer(SR_NONE);
	Render.ReadBuffer(SR_NONE);
	Render.FrameBufferTexture2D(SR_FRAMEBUFFER_EXT, SR_DEPTH_ATTACHMENT_EXT, SR_TEXTURE_2D, VTexture, 0);
	end
else
	begin
	Render.FrameBufferTexture2D(SR_FRAMEBUFFER_EXT, SR_COLOR_ATTACHMENT0_EXT, SR_TEXTURE_2D, VTexture, 0);
	Render.FrameBufferRenderBuffer(SR_FRAMEBUFFER_EXT,SR_DEPTH_ATTACHMENT_EXT, SR_RENDERBUFFER_EXT, VRenderBuffer^);
	end;
Render.BindFrameBuffer(SR_FRAMEBUFFER_EXT, 0);
end;

constructor TSExample15_Shadow.Create(const VContext : ISContext;const Lights : TSLongWord = 1; const BonesCount : TSLongWord = 32; const TextureBlock : TSTextureBlock = nil);
const
	TexSize = 4096;
	Example15Dir = SExamplesDirectory + DirectorySeparator + '15' +DirectorySeparator;
var
	i : TSLongWord;
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

FShaderDepthTex2D := SCreateShaderProgramFromSources(Context,
	SReadShaderSourceFromFile(Example15Dir + 'main_depth.vert',[BonesCount]),
	SReadShaderSourceFromFile(Example15Dir + 'main_depth.frag',['texture']));
FShaderDepthShad2D := SCreateShaderProgramFromSources(Context,
	SReadShaderSourceFromFile(Example15Dir + 'main_depth.vert',[BonesCount]),
	SReadShaderSourceFromFile(Example15Dir + 'main_depth.frag',['shadow']));
FShaderShadowTex2D := SCreateShaderProgramFromSources(Context,
	SReadShaderSourceFromFile(Example15Dir + 'main.vert',[FLightsCount, BonesCount]),
	SReadShaderSourceFromFile(Example15Dir + 'main.frag',['texture', FLightsCount]));
FShaderShadowShad2D := SCreateShaderProgramFromSources(Context,
	SReadShaderSourceFromFile(Example15Dir + 'main.vert',[FLightsCount, BonesCount]),
	SReadShaderSourceFromFile(Example15Dir + 'main.frag',['shadow', FLightsCount]));

//SReadAndSaveShaderSourceFile(Example15Dir + 'main.vert','main_shadow.vert',[FLightsCount, BonesCount]);
//SReadAndSaveShaderSourceFile(Example15Dir + 'main.frag','main_shadow.frag',['shadow', FLightsCount]);

for i := 0 to FLightsCount - 1 do
	begin
	FLights[i].FUniformShadowTex2D_shadowMap    := FShaderShadowTex2D.GetUniformLocation('shadowMap'+SStr(i));
	FLights[i].FUniformShadowTex2D_lightMatrix  := FShaderShadowTex2D.GetUniformLocation('lightMatrix'+SStr(i));
	FLights[i].FUniformShadowTex2D_lightPos     := FShaderShadowTex2D.GetUniformLocation('lightPos'+SStr(i));
	FLights[i].FUniformShadowTex2D_lightDir     := FShaderShadowTex2D.GetUniformLocation('lightDir'+SStr(i));

	FLights[i].FUniformShadowShad2D_shadowMap   := FShaderShadowShad2D.GetUniformLocation('shadowMap'+SStr(i));
	FLights[i].FUniformShadowShad2D_lightMatrix := FShaderShadowShad2D.GetUniformLocation('lightMatrix'+SStr(i));
	FLights[i].FUniformShadowShad2D_lightPos    := FShaderShadowShad2D.GetUniformLocation('lightPos'+SStr(i));
	FLights[i].FUniformShadowShad2D_lightDir    := FShaderShadowShad2D.GetUniformLocation('lightDir'+SStr(i));
	end;
end;

destructor TSExample15_Shadow.Destroy();
var
	i : TSLongWord;
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

class function TSExample15_Shadow.ClassName():TSString;
begin
Result := 'TSExample15_Shadow';
end;

procedure TSExample15_Shadow.BeginDrawToShadow(const LightIndex : TSLongWord = 0);
begin
Render.Viewport(0,0,FTexDepthSizeX,FTexDepthSizeY);
if (FShadowRenderType) then
	begin // Вариант #1
	Render.BindFrameBuffer(SR_FRAMEBUFFER_EXT, FLights[LightIndex].FFrameBufferDepth);
	// Очищать текстуру нужно значением соответствующим дальней плоскости отсечения
	Render.ClearColor(1,1,1,1);
	Render.Clear(SR_COLOR_BUFFER_BIT or SR_DEPTH_BUFFER_BIT);
	end
else
	begin // Вариант #2
	Render.BindFrameBuffer(SR_FRAMEBUFFER_EXT,FLights[LightIndex].FFrameBufferDepth2);
	// В этом случае у нас нет буфера цвета, поэтому очищать его не нужно
	Render.Clear(SR_DEPTH_BUFFER_BIT);
	end;
// Сдвиг полигонов - нужен для того, чтобы не было z-fighting'а
Render.Enable(SR_POLYGON_OFFSET_FILL);
Render.PolygonOffset ( 2, 500);

// Сохраняем эти матрицы, они нам понадобятся для расчёта матрицы света
FLights[LightIndex].FLightProjectionMatrix := SGetPerspectiveMatrix(FLights[LightIndex].FLightAngle /PI * 180, 1.0, TSRenderNear, TSRenderFar);
FLights[LightIndex].FLightModelViewMatrix  := SGetLookAtMatrix(FLights[LightIndex].FLightPos, FLights[LightIndex].FLightEye, FLights[LightIndex].FLightUp);

// Установить матрицы камеры света
Render.MatrixMode(SR_PROJECTION);
Render.LoadIdentity();
Render.MultMatrixf(@FLights[LightIndex].FLightProjectionMatrix);
Render.MatrixMode(SR_MODELVIEW);
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

procedure TSExample15_Shadow.EndDrawToShadow();
begin
FInDrawToShadow := False;
// Напомню, что в первом варианте нам нужен шейдер, чтобы сохранить глубину в текстуру, во втором это не к чему.
//if FShadowRenderType then
	//begin // Вариант #1
	Render.UseProgram(0);
	//end;

Render.Disable(SR_POLYGON_OFFSET_FILL);
Render.BindFrameBuffer(SR_FRAMEBUFFER_EXT, 0);
end;

procedure TSExample15_Shadow.UniformScrene();
var
	FMVLightPos : TSVertex3f;
	i : TSLongWord;
begin
// Сохраняем матрицы, они нам нужны для вычисления освещения
// Инвертированная матрица используется в расчёте матрицы источника света
{FCameraProjectionMatrix :=} (*import*) {;}
{FCameraModelViewMatrix  :=} (*import*) {;}
FCameraInverseModelViewMatrix := SInverseMatrix(FCameraModelViewMatrix);

for i := 0 to FLightsCount - 1 do
	begin
	FLights[i].FLightMatrix := FCameraInverseModelViewMatrix *
		FLights[i].FLightModelViewMatrix * 
		FLights[i].FLightProjectionMatrix *
		SScaleMatrix(SVertex3fImport(0.5,0.5,0.5)) *
		STranslateMatrix(SVertex3fImport(0.5,0.5,0.5));

	Render.Uniform1i(FLights[i].FUniformShadow_shadowMap, i + 7);
	Render.UniformMatrix4fv(FLights[i].FUniformShadow_lightMatrix, 1, False, @FLights[i].FLightMatrix );
	FMVLightPos := FLights[i].FLightPos * FCameraModelViewMatrix;
	Render.Uniform3f(FLights[i].FUniformShadow_lightPos, FLights[i].FLightPos.x, FLights[i].FLightPos.y, FLights[i].FLightPos.z);
	FLights[i].FLightDir := (FLights[i].FLightEye - FLights[i].FLightPos).Normalized();
	Render.Uniform3f(FLights[i].FUniformShadow_lightDir, FLights[i].FLightDir.x, FLights[i].FLightDir.y, FLights[i].FLightDir.z);
	end;
end;

procedure TSExample15_Shadow.BeginDrawScene();
var
	ShaderShadow : TSShaderProgram;
	i : TSLongWord;
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
		//Render.Enable(SR_TEXTURE_2D);
		Render.BindTexture(SR_TEXTURE_2D, FLights[i].FTexDepth);
		
		FLights[i].FUniformShadow_lightDir    := FLights[i].FUniformShadowTex2D_lightDir;
		FLights[i].FUniformShadow_lightMatrix := FLights[i].FUniformShadowTex2D_lightMatrix;
		FLights[i].FUniformShadow_lightPos    := FLights[i].FUniformShadowTex2D_lightPos;
		FLights[i].FUniformShadow_shadowMap   := FLights[i].FUniformShadowTex2D_shadowMap;
		end
	else
		begin // Вариант #2
		Render.ActiveTexture(i + 7);
		//Render.Enable(SR_TEXTURE_2D);
		Render.BindTexture(SR_TEXTURE_2D, FLights[i].FTexDepth2);
		
		// Для второго варианта включаем режим сравнения текстуры
		Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_COMPARE_MODE, SR_COMPARE_R_TO_TEXTURE);
		Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_COMPARE_FUNC, SR_LEQUAL);
		
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

procedure TSExample15_Shadow.EndDrawScene();
var
	i : TSLongWord;
begin
FInDrawScene    := False;
Render.UseProgram(0);
for i := 0 to FLightsCount - 1 do
	begin
	Render.ActiveTexture(i + 7);

	if (not FShadowRenderType) then
		begin // Вариант #2
		// Не забываем выключать режим сравнения
		Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_COMPARE_MODE,SR_NONE);
		end;
	Render.BindTexture(SR_TEXTURE_2D, 0);
	//Render.Disable(SR_TEXTURE_2D);
	end;

Render.ActiveTexture(0);
end;

end.
