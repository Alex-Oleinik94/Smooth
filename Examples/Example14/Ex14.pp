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
	SaGeContext
	,SaGeBased
	,SaGeBase
	,SaGeRender
	,SaGeUtils
	,SaGeScreen
	,SaGeMesh
	,SaGeCommon
	,Classes
	,SysUtils
	,SaGeShaders
	;
type
	TSGExample14 = class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		
		FModel : TSG3DObject;
		FModelBBoxMin,
			FModelBBoxMax,
			FModelCenter : TSGVertex3f;
		
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
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

procedure TSGExample14.LoadModel(const FileName : TSGString);
var
	Stream : TFileStream = nil;
	CountOfVertexes, CountOfIndexes : Integer;
	Indexes : packed array of packed array [0..2] of TSGLongWord;
	i : LongWord;
begin
FModel := TSG3DObject.Create();
FModel.Context := Context;
FModel.ObjectPoligonesType := SGR_TRIANGLES;
FModel.HasNormals := True;
FModel.SetColorType(SGMeshColorType4f);
FModel.HasTexture := False;
FModel.HasColors  := False;
FModel.EnableCullFace := False;
FModel.VertexType := SGMeshVertexType3f;
FModel.CountTextureFloatsInVertexArray := 4;

FModel.QuantityFaceArrays := 1;
FModel.PoligonesType[0] := FModel.ObjectPoligonesType;

Stream := TFileStream.Create(FileName,fmOpenRead);
Stream.ReadBuffer(FModelBBoxMin,SizeOf(FModelBBoxMin));
Stream.ReadBuffer(FModelBBoxMax,SizeOf(FModelBBoxMax));
FModelCenter := (FModelBBoxMax + FModelBBoxMin)/2;

FModelBBoxMin.WriteLn(); FModelBBoxMax.WriteLn(); FModelCenter.WriteLn(); 

Stream.ReadBuffer(CountOfIndexes,SizeOf(CountOfIndexes)); WriteLn(CountOfIndexes);
SetLength(Indexes,CountOfIndexes);
Stream.ReadBuffer(Indexes[0],(CountOfIndexes * SizeOf(Indexes[0])) div 3);

Stream.ReadBuffer(CountOfVertexes,SizeOf(CountOfVertexes));WriteLn(CountOfVertexes); WriteLn(' -- ',CountOfVertexes * (6 * SizeOf(SIngle)) + SizeOf(CountOfVertexes) + SizeOf(CountOfIndexes) + ((CountOfIndexes * SizeOf(Indexes[0])) div 3) + SizeOf(FModelBBoxMax)*2);
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

constructor TSGExample14.Create(const VContext : TSGContext);
begin
inherited Create(VContext);
FCamera:=TSGCamera.Create();
FCamera.Context := Context;

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

FTexDepthSizeX := 1024;
FTexDepthSizeY := 1024;




FShaderDepth := SGCreateShaderProgramFromSourses(Context,
	SGReadShaderSourseFromFile(SGExamplesDirectory + Slash + '14' + Slash + 'depth.vert'),
	SGReadShaderSourseFromFile(SGExamplesDirectory + Slash + '14' + Slash + 'depth.frag'));
FShaderShadowTex2D := SGCreateShaderProgramFromSourses(Context,
	SGReadShaderSourseFromFile(SGExamplesDirectory + Slash + '14' + Slash + 'shadow.vert'),
	SGReadShaderSourseFromFile(SGExamplesDirectory + Slash + '14' + Slash + 'shadow_tex2D.frag'));
FShaderShadowShad2D := SGCreateShaderProgramFromSourses(Context,
	SGReadShaderSourseFromFile(SGExamplesDirectory + Slash + '14' + Slash + 'shadow.vert'),
	SGReadShaderSourseFromFile(SGExamplesDirectory + Slash + '14' + Slash + 'shadow_shad2D.frag'));

LoadModel(SGExamplesDirectory + Slash + '14' + Slash + 'model.bin');
end;

destructor TSGExample14.Destroy();
begin
FShaderDepth.Destroy();
FShaderShadowTex2D.Destroy();
FShaderShadowShad2D.Destroy();
FModel.Destroy();
FCamera.Destroy();
inherited;
end;

procedure TSGExample14.RenderToShadowMap();
begin
Render.Viewport(0,0,FTexDepthSizeX,FTexDepthSizeY);
if (FShadowRenderType) then
	begin // Вариант #1
	
	end
else
	begin // Вариант #2
	
	end;
end;

procedure TSGExample14.RenderShadowedScene();
begin

end;

procedure TSGExample14.Draw();
begin
FLightPos.Import(30 * cos (FLightAngle), 40, 30 * sin(FLightAngle));

FCamera.CallAction();

Render.Color4f(1,1,1,1);
Render.PushMatrix();
Render.Scale(0.005,0.005,0.005);
FModel.Draw();
Render.PopMatrix();

if (FUseLightAnimation) then
	FLightAngle += Context.ElapsedTime;
end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample14;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
