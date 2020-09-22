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
		constructor Create(const VContext : ISContext;const Lights : TSUInt32 = 1; const BonesCount : TSUInt32 = 32;const TextureBlock : TSTextureBlock = nil);
		destructor Destroy();override;
		class function ClassName():TSString;override;
			public
		procedure BeginDrawToShadow(const LightIndex : TSMaxEnum = 0);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure EndDrawToShadow();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure BeginDrawScene();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure EndDrawScene();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure KeyboardCallback();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetCurrentShader():TSShaderProgram;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure UniformScrene();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure CreateTextureAndFrame(var VTexture, VFrame : TSUInt32;const TextureBlock : TSTextureBlock; const VRenderBuffer : PSLongWord = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			private
		FInDrawToShadow : TSBoolean;
		FInDrawScene    : TSBoolean;
		FLightsCount    : TSUInt32;
		
		FLights : packed array of
			packed record
				FLightPos : TSVector3f;
				FLightEye : TSVector3f;
				FLightUp  : TSVector3f;
				FLightDirection : TSVector3f;
				FLightAngle : TSFloat;
				
				FTexDepth  : TSUInt32;
				FTexDepth2 : TSUInt32;
				
				FFrameBufferDepth, 
					FFrameBufferDepth2,
					FRenderBufferDepth : TSUInt32;
				
				FLightProjectionMatrix,
					FLightModelViewMatrix,
					FLightMatrix : TSMatrix4x4;
				
				FUniformShadowTex2D_shadowMap,
					FUniformShadowTex2D_lightMatrix,
					FUniformShadowTex2D_lightPos,
					FUniformShadowTex2D_LightDirection,
					FUniformShadowShad2D_shadowMap,
					FUniformShadowShad2D_lightMatrix,
					FUniformShadowShad2D_lightPos,
					FUniformShadowShad2D_LightDirection : TSUInt32;
				
				FUniformShadow_LightDirection    : TSUInt32;
				FUniformShadow_lightMatrix : TSUInt32;
				FUniformShadow_lightPos    : TSUInt32;
				FUniformShadow_shadowMap   : TSUInt32;
				end;
		
		FTexDepthSizeX, FTexDepthSizeY : TSUInt32;
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
		function GetLightAngle(const Index : TSMaxEnum):TSFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetLightAngle(const Index : TSMaxEnum; const VAngle : TSFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetLightModelViewMatrix(const Index : TSMaxEnum):TSMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetLightPos(const Index : TSMaxEnum):TSVector3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetLightPos(const Index : TSMaxEnum; const VPos : TSVector3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetLightEye(const Index : TSMaxEnum; const VEye : TSVector3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetLightUp(const Index : TSMaxEnum; const VUp : TSVector3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetLightDirection(const Index : TSMaxEnum):TSVector3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property LightAngle [Index : TSMaxEnum]: TSFloat read  GetLightAngle write SetLightAngle;
		property CameraProjectionMatrix : TSMatrix4x4  write FCameraProjectionMatrix;
		property CameraModelViewMatrix  : TSMatrix4x4  write FCameraModelViewMatrix;
		property LightModelViewMatrix [Index : TSMaxEnum] : TSMatrix4x4  read  GetLightModelViewMatrix;
		property LightPos [Index : TSMaxEnum] : TSVector3f read  GetLightPos write SetLightPos;
		property LightEye [Index : TSMaxEnum] : TSVector3f write SetLightEye;
		property LightUp  [Index : TSMaxEnum] : TSVector3f write SetLightUp;
		property LightDirection [Index : TSMaxEnum] : TSVector3f read  GetLightDirection;
		property DrawingShadow          : TSBoolean  read  FInDrawToShadow;
		property DrawingScene           : TSBoolean  read  FInDrawScene;
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothFileUtils
	,SmoothContextUtils
	;

function TSExample15_Shadow.GetLightAngle(const Index : TSMaxEnum):TSFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FLights[Index].FLightAngle;
end;

procedure TSExample15_Shadow.SetLightAngle(const Index : TSMaxEnum; const VAngle : TSFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FLights[Index].FLightAngle := VAngle;
end;

function TSExample15_Shadow.GetLightModelViewMatrix(const Index : TSMaxEnum):TSMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FLights[Index].FLightModelViewMatrix;
end;

function TSExample15_Shadow.GetLightPos(const Index : TSMaxEnum):TSVector3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FLights[Index].FLightPos;
end;

procedure TSExample15_Shadow.SetLightPos(const Index : TSMaxEnum; const VPos : TSVector3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FLights[Index].FLightPos := VPos;
end;

procedure TSExample15_Shadow.SetLightEye(const Index : TSMaxEnum; const VEye : TSVector3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FLights[Index].FLightEye := VEye;
end;

procedure TSExample15_Shadow.SetLightUp(const Index : TSMaxEnum; const VUp : TSVector3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FLights[Index].FLightUp := VUp;
end;

function TSExample15_Shadow.GetLightDirection(const Index : TSMaxEnum):TSVector3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FLights[Index].FLightDirection;
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
	Index : TSMaxEnum;
begin
if (Context.KeyPressed and (Context.KeyPressedType = SUpKey)) then
	case Context.KeyPressedChar of
	'1' : FShadowRenderType := True;
	'2' : FShadowRenderType := False;
	'3' : 
		begin
		Render.Enable(SR_TEXTURE_2D);
		for Index := 0 to FLightsCount - 1 do
			begin
			Render.BindTexture(SR_TEXTURE_2D,FLights[Index].FTexDepth);
			Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MAG_FILTER, SR_LINEAR);
			Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MIN_FILTER, SR_LINEAR);
			Render.BindTexture(SR_TEXTURE_2D,FLights[Index].FTexDepth2);
			Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MAG_FILTER, SR_LINEAR);
			Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MIN_FILTER, SR_LINEAR);
			end;
		Render.BindTexture(SR_TEXTURE_2D,0);
		Render.Disable(SR_TEXTURE_2D);
		end;
	'4' : 
		begin
		Render.Enable(SR_TEXTURE_2D);
		for Index := 0 to FLightsCount - 1 do
			begin
			Render.BindTexture(SR_TEXTURE_2D,FLights[Index].FTexDepth);
			Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MAG_FILTER, SR_NEAREST);
			Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MIN_FILTER, SR_NEAREST);
			Render.BindTexture(SR_TEXTURE_2D,FLights[Index].FTexDepth2);
			Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MAG_FILTER, SR_NEAREST);
			Render.TexParameteri(SR_TEXTURE_2D,SR_TEXTURE_MIN_FILTER, SR_NEAREST);
			end;
		Render.BindTexture(SR_TEXTURE_2D,0);
		Render.Disable(SR_TEXTURE_2D);
		end;
	end;
end;

procedure TSExample15_Shadow.CreateTextureAndFrame(var VTexture, VFrame : TSUInt32;const TextureBlock : TSTextureBlock; const VRenderBuffer : PSLongWord = nil);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

constructor TSExample15_Shadow.Create(const VContext : ISContext;const Lights : TSUInt32 = 1; const BonesCount : TSUInt32 = 32; const TextureBlock : TSTextureBlock = nil);
const
	TexSize = 4096;
	Example15Dir = SExamplesDirectory + DirectorySeparator + '15' +DirectorySeparator;
var
	Index : TSMaxEnum;
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

for Index := 0 to FLightsCount - 1 do
	begin
	FLights[Index].FTexDepth  := 0;
	FLights[Index].FTexDepth2 := 0;
	FLights[Index].FLightAngle := PI/2;
	FLights[Index].FLightPos.Import(0,0,0);
	FLights[Index].FLightUp.Import(0,1,0);
	FLights[Index].FLightEye.Import(0,0,0);
	FLights[Index].FFrameBufferDepth  := 0;
	FLights[Index].FFrameBufferDepth2 := 0;
	FLights[Index].FRenderBufferDepth := 0;
	
	FLights[Index].FUniformShadowShad2D_LightDirection    := 0;
	FLights[Index].FUniformShadowShad2D_lightMatrix := 0;
	FLights[Index].FUniformShadowShad2D_lightPos    := 0;
	FLights[Index].FUniformShadowShad2D_shadowMap   := 0;
	FLights[Index].FUniformShadowTex2D_LightDirection     := 0;
	FLights[Index].FUniformShadowTex2D_lightMatrix  := 0;
	FLights[Index].FUniformShadowTex2D_lightPos     := 0;
	FLights[Index].FUniformShadowTex2D_shadowMap    := 0;
	
	CreateTextureAndFrame(FLights[Index].FTexDepth2,FLights[Index].FFrameBufferDepth2,TextureBlock);
	CreateTextureAndFrame(FLights[Index].FTexDepth,FLights[Index].FFrameBufferDepth,TextureBlock,@FLights[Index].FRenderBufferDepth);
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

for Index := 0 to FLightsCount - 1 do
	begin
	FLights[Index].FUniformShadowTex2D_shadowMap    := FShaderShadowTex2D.GetUniformLocation('shadowMap'+SStr(Index));
	FLights[Index].FUniformShadowTex2D_lightMatrix  := FShaderShadowTex2D.GetUniformLocation('lightMatrix'+SStr(Index));
	FLights[Index].FUniformShadowTex2D_lightPos     := FShaderShadowTex2D.GetUniformLocation('lightPos'+SStr(Index));
	FLights[Index].FUniformShadowTex2D_LightDirection     := FShaderShadowTex2D.GetUniformLocation('LightDirection'+SStr(Index));

	FLights[Index].FUniformShadowShad2D_shadowMap   := FShaderShadowShad2D.GetUniformLocation('shadowMap'+SStr(Index));
	FLights[Index].FUniformShadowShad2D_lightMatrix := FShaderShadowShad2D.GetUniformLocation('lightMatrix'+SStr(Index));
	FLights[Index].FUniformShadowShad2D_lightPos    := FShaderShadowShad2D.GetUniformLocation('lightPos'+SStr(Index));
	FLights[Index].FUniformShadowShad2D_LightDirection    := FShaderShadowShad2D.GetUniformLocation('LightDirection'+SStr(Index));
	end;
end;

destructor TSExample15_Shadow.Destroy();
var
	Index : TSMaxEnum;
begin
if (FLightsCount > 0) and (FLights <> nil) then
	for Index :=0 to FLightsCount - 1 do
		if (Index<=High(FLights)) then
			begin
			Render.DeleteTextures(1,@FLights[Index].FTexDepth);
			Render.DeleteTextures(1,@FLights[Index].FTexDepth2);
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

procedure TSExample15_Shadow.BeginDrawToShadow(const LightIndex : TSMaxEnum = 0);
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
	FMVLightPos : TSVector3f;
	Index : TSMaxEnum;
begin
// Сохраняем матрицы, они нам нужны для вычисления освещения
// Инвертированная матрица используется в расчёте матрицы источника света
{FCameraProjectionMatrix :=} (*import*) {;}
{FCameraModelViewMatrix  :=} (*import*) {;}
FCameraInverseModelViewMatrix := SInverseMatrix(FCameraModelViewMatrix);

for Index := 0 to FLightsCount - 1 do
	begin
	FLights[Index].FLightMatrix := FCameraInverseModelViewMatrix *
		FLights[Index].FLightModelViewMatrix * 
		FLights[Index].FLightProjectionMatrix *
		SScaleMatrix(SVertex3fImport(0.5,0.5,0.5)) *
		STranslateMatrix(SVertex3fImport(0.5,0.5,0.5));

	Render.Uniform1i(FLights[Index].FUniformShadow_shadowMap, Index + 7);
	Render.UniformMatrix4fv(FLights[Index].FUniformShadow_lightMatrix, 1, False, @FLights[Index].FLightMatrix );
	FMVLightPos := FLights[Index].FLightPos * FCameraModelViewMatrix;
	Render.Uniform3f(FLights[Index].FUniformShadow_lightPos, FLights[Index].FLightPos.x, FLights[Index].FLightPos.y, FLights[Index].FLightPos.z);
	FLights[Index].FLightDirection := (FLights[Index].FLightEye - FLights[Index].FLightPos).Normalized();
	Render.Uniform3f(FLights[Index].FUniformShadow_LightDirection, FLights[Index].FLightDirection.x, FLights[Index].FLightDirection.y, FLights[Index].FLightDirection.z);
	end;
end;

procedure TSExample15_Shadow.BeginDrawScene();
var
	ShaderShadow : TSShaderProgram;
	Index : TSMaxEnum;
begin
Render.Viewport(0,0,Context.Width,Context.Height);

if FShadowRenderType then
	ShaderShadow := FShaderShadowTex2D
else
	ShaderShadow := FShaderShadowShad2D;

for Index := 0 to FLightsCount - 1 do
	if FShadowRenderType then
		begin // Вариант #1
		Render.ActiveTexture(Index + 7);
		//Render.Enable(SR_TEXTURE_2D);
		Render.BindTexture(SR_TEXTURE_2D, FLights[Index].FTexDepth);
		
		FLights[Index].FUniformShadow_LightDirection    := FLights[Index].FUniformShadowTex2D_LightDirection;
		FLights[Index].FUniformShadow_lightMatrix := FLights[Index].FUniformShadowTex2D_lightMatrix;
		FLights[Index].FUniformShadow_lightPos    := FLights[Index].FUniformShadowTex2D_lightPos;
		FLights[Index].FUniformShadow_shadowMap   := FLights[Index].FUniformShadowTex2D_shadowMap;
		end
	else
		begin // Вариант #2
		Render.ActiveTexture(Index + 7);
		//Render.Enable(SR_TEXTURE_2D);
		Render.BindTexture(SR_TEXTURE_2D, FLights[Index].FTexDepth2);
		
		// Для второго варианта включаем режим сравнения текстуры
		Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_COMPARE_MODE, SR_COMPARE_R_TO_TEXTURE);
		Render.TexParameteri(SR_TEXTURE_2D, SR_TEXTURE_COMPARE_FUNC, SR_LEQUAL);
		
		FLights[Index].FUniformShadow_LightDirection    := FLights[Index].FUniformShadowShad2D_LightDirection;
		FLights[Index].FUniformShadow_lightMatrix := FLights[Index].FUniformShadowShad2D_lightMatrix;
		FLights[Index].FUniformShadow_lightPos    := FLights[Index].FUniformShadowShad2D_lightPos;
		FLights[Index].FUniformShadow_shadowMap   := FLights[Index].FUniformShadowShad2D_shadowMap;
		end;

FInDrawScene    := True;
UniformScrene();
Render.ActiveTexture(0);
ShaderShadow.Use();
end;

procedure TSExample15_Shadow.EndDrawScene();
var
	Index : TSMaxEnum;
begin
FInDrawScene    := False;
Render.UseProgram(0);
for Index := 0 to FLightsCount - 1 do
	begin
	Render.ActiveTexture(Index + 7);

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
