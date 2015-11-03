{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex13;
	interface
{$ELSE}
	program Example13;
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
	,SaGeUtils
	,SaGeRender
	,SaGeCommon
	,crt
	,SaGeScreen
	,SaGeMesh
	,SaGeShaders
	,Ex13_Model
	;

const
	VertexShaderSourse = '// Vertex Shader '+#13+#10+
		'uniform mat4 boneMat[32]; '+#13+#10+
		'varying float texNum; '+#13+#10+
		'void main() '+#13+#10+
		'{ '+#13+#10+
		'float boneIndex[3]; '+#13+#10+
		'float boneWeight[3]; '+#13+#10+
		'texNum = gl_Vertex[3]; '+#13+#10+
		'vec4 fixedTexCoord = gl_MultiTexCoord0; '+#13+#10+
		'vec4 fixedColor = gl_Color; '+#13+#10+
		'vec4 fixedVertex = gl_Vertex; '+#13+#10+
		'vec4 finalVertex = vec4(0,0,0,1); '+#13+#10+
		'boneIndex[0] = floor(fixedTexCoord[2]*255.0+0.001); '+#13+#10+
		'boneWeight[0] = fixedTexCoord[3]; '+#13+#10+
		'boneIndex[1] = floor(fixedColor[0]*255.0+0.001); '+#13+#10+
		'boneWeight[1] = fixedColor[1]; '+#13+#10+
		'boneIndex[2] = floor(fixedColor[2]*255.0+0.001); '+#13+#10+
		'boneWeight[2] = fixedColor[3]; '+#13+#10+
		'fixedTexCoord[2] = 0.0; '+#13+#10+
		'fixedTexCoord[3] = 1.0; '+#13+#10+
		'fixedColor[0] = 1.0; '+#13+#10+
		'fixedColor[1] = 1.0; '+#13+#10+
		'fixedColor[2] = 1.0; '+#13+#10+
		'fixedColor[3] = 1.0; '+#13+#10+
		'fixedVertex[3] = 1.0; '+#13+#10+
		'mat4 finalMatrix = mat4(0); '+#13+#10+
		'for (int i = 0; i < 3; i++) '+#13+#10+
			'finalMatrix += boneWeight[i]*boneMat[int(boneIndex[i])]; '+#13+#10+
		'finalVertex = finalMatrix*fixedVertex; '+#13+#10+
		'finalVertex[3] = 1.0; '+#13+#10+
		'gl_Position = gl_ModelViewProjectionMatrix * finalVertex; '+#13+#10+
		'gl_FrontColor = fixedColor; '+#13+#10+
		'gl_TexCoord[0] = fixedTexCoord; '+#13+#10+
		'}';
	FragmentShaderSourse = '// Fragment Shader '+#13+#10+
		'uniform sampler2D myTexture0; '+#13+#10+
		'uniform sampler2D myTexture1; '+#13+#10+
		'uniform sampler2D myTexture2; '+#13+#10+
		'uniform sampler2D myTexture3; '+#13+#10+
		'uniform sampler2D myTexture4; '+#13+#10+
		'uniform sampler2D myTexture5; '+#13+#10+
		'uniform sampler2D myTexture6; '+#13+#10+
		'uniform sampler2D myTexture7; '+#13+#10+
		'varying float texNum; '+#13+#10+
		'void main() '+#13+#10+
		'{ '+#13+#10+
		' float texNum2 = floor(texNum*255.0-1.0+0.001); '+#13+#10+
		' if (texNum2==0.0) '+#13+#10+
		'  gl_FragColor = texture2D( myTexture0, gl_TexCoord[0].st );  '+#13+#10+
		' else if (texNum2==1.0) '+#13+#10+
		'  gl_FragColor = texture2D( myTexture1, gl_TexCoord[0].st );  '+#13+#10+
		' else if (texNum2==2.0) '+#13+#10+
		'  gl_FragColor = texture2D( myTexture2, gl_TexCoord[0].st );  '+#13+#10+
		' else if (texNum2==3.0) '+#13+#10+
		'  gl_FragColor = texture2D( myTexture3, gl_TexCoord[0].st );  '+#13+#10+
		' else if (texNum2==4.0) '+#13+#10+
		'  gl_FragColor = texture2D( myTexture4, gl_TexCoord[0].st );  '+#13+#10+
		' else if (texNum2==5.0) '+#13+#10+
		'  gl_FragColor = texture2D( myTexture5, gl_TexCoord[0].st );  '+#13+#10+
		' else if (texNum2==6.0) '+#13+#10+
		'  gl_FragColor = texture2D( myTexture6, gl_TexCoord[0].st );  '+#13+#10+
		' else if (texNum2==7.0) '+#13+#10+
		'  gl_FragColor = texture2D( myTexture7, gl_TexCoord[0].st );  '+#13+#10+
		'}';

type
	TSGExample13=class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		FShaderProgram : TSGShaderProgram;
		FVertexShader, FFragmentShader : TSGShader;
		FRotateAngle : TSGFloat;
		
		F_ShaderBoneMat  : TSGLongWord;
		F_ShaderTextures : array[0..7] of TSGLongWord;
		
		// массив с меняющимися данными скелетной анимации
		// (в данном случае всего 21 персонаж)
		FAnimationStates  : array[0..300-1] of TSkelAnimState;
		
		FModel : TModel;
		
		FQuantityModels : TSGLongWord;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSGExample13.ClassName():TSGString;
begin
Result := 'Скелетная анимация';
end;

constructor TSGExample13.Create(const VContext : TSGContext);
var
	i : TSGWord;
	TempPChar : PChar;
begin
inherited Create(VContext);
FRotateAngle := 0;
FCamera := nil;
FVertexShader := nil;
FFragmentShader := nil;
FShaderProgram := nil;
FModel := nil;
FQuantityModels := 150;

if Render.SupporedShaders() then
	begin
	FCamera:=TSGCamera.Create();
	FCamera.SetContext(Context);
	FCamera.ViewMode := SG_VIEW_LOOK_AT_OBJECT;
	FCamera.Up:=SGVertexImport(0,0,1);
	FCamera.Location:=SGVertexImport(0,-350,100);
	FCamera.View:=(SGVertexImport(0,0,0)-SGVertexImport(0,-350,100)).Normalized();

	FVertexShader := TSGShader.Create(Context,SGR_VERTEX_SHADER);
	FVertexShader.Sourse(VertexShaderSourse);
	if not FVertexShader.Compile() then
		FVertexShader.PrintInfoLog();

	FFragmentShader := TSGShader.Create(Context,SGR_FRAGMENT_SHADER);
	FFragmentShader.Sourse(FragmentShaderSourse);
	if not FFragmentShader.Compile() then
		FFragmentShader.PrintInfoLog();

	FShaderProgram := TSGShaderProgram.Create(Context);
	FShaderProgram.Attach(FVertexShader);
	FShaderProgram.Attach(FFragmentShader);
	if not FShaderProgram.Link() then
		FShaderProgram.PrintInfoLog();

	F_ShaderBoneMat := Render.GetUniformLocation(FShaderProgram.Handle,'boneMat');
	for i := 0 to 7 do
		begin
		TempPChar := SGStringToPChar('myTexture'+SGStr(i));
		F_ShaderTextures[i] := Render.GetUniformLocation(FShaderProgram.Handle, TempPChar);
		FreeMem(TempPChar)
		end;
	
	FModel := TModel.Create(Context);
	FModel.Load('.\models\c_marine.smd');
	FModel.LoadAnimation('.\models\run.smd');
	FModel.LoadTextures('.\textures\');
	FModel.PrepareSkeletalAnimation();
	
	// для каждого персонажа делаем случайный номер начального кадра
	for i := 0 to length(FAnimationStates) - 1 do
		begin
		FAnimationStates[i].ResetState(FModel.Animation^.FNodesNum);
		FAnimationStates[i].FPrevFrame:=0;
		FAnimationStates[i].FNextFrame:=random(21);     // номер случайного кадра
		FAnimationStates[i].FPrevAction:=0;
		FAnimationStates[i].FNextAction:=0;
		FAnimationStates[i].FSkelTime:=random(100)/100; // случайный сдвиг анимации
		end;
	
	FModel.MakeMesh();
	end;
end;

destructor TSGExample13.Destroy();
begin
if FCamera <> nil then
	FCamera.Destroy();
if FShaderProgram <> nil then
	begin
	FShaderProgram.Destroy();
	Render.UseProgram(0);
	end;
if FModel <> nil then
	FModel.Destroy();

//    allready processed in TSGShaderProgram.Destroy()
//FVertexShader.Destroy();
//FFragmentShader.Destroy();

inherited;
end;

procedure TSGExample13.Draw();
const
	WarningString1 : String = 'Вы не сможете просмотреть это пример!';
	WarningString2 : String = 'На вашем устройстве не поддерживаются шейдеры!';
var
	VStringLength : TSGLongWord;
	i : LongWord;
begin
if Render.SupporedShaders() then
	begin
	FCamera.CallAction();
	FRotateAngle += Context.ElapsedTime/100;
	Render.Rotatef(FRotateAngle,FCamera.Up.x,FCamera.Up.y,FCamera.Up.z);
	Render.Color3f(1,1,1);
	Render.Enable(SGR_TEXTURE_2D);
	Render.Disable(SGR_BLEND);
	Render.Disable(SGR_COLOR_MATERIAL);
	
	for i := 0 to 7 do
		begin
		Render.Uniform1i(F_ShaderTextures[i],i);
		Render.ActiveTexture(i);
		Render.BindTexture(SGR_TEXTURE_2D,i+1);
		end;
	
	FShaderProgram.Use();
	
	for i := 0 to FQuantityModels - 1 do
		begin
		
		FAnimationStates[i].Animate(FModel,0,1,False);
		FAnimationStates[i].CopyBonesForShader();
		
		Render.UniformMatrix4fv(F_ShaderBoneMat, 32, false, @FAnimationStates[i].FShaderAbsoluteMatrixes[0]);
		Render.PushMatrix();
		Render.Translatef((30+5*i)*sin((FQuantityModels+6.28)*i/FQuantityModels),
						  (30+5*i)*cos((FQuantityModels+6.28)*i/FQuantityModels),0);
		FModel.Draw();
		Render.PopMatrix();
		end;
	
	for i := 7 downto 0 do
		begin
		Render.ActiveTexture(i);
		Render.BindTexture(SGR_TEXTURE_2D,0);
		end;
	Render.UseProgram(0);
	Render.Disable(SGR_TEXTURE_2D);
	Render.Enable(SGR_BLEND);
	
	end
else
	begin
	Render.InitMatrixMode(SG_2D);
	
	Render.Color3f(1,0,0);
	VStringLength := SGScreen.Font.StringLength(WarningString1);
	SGScreen.Font.DrawFontFromTwoVertex2f(WarningString1,
		SGVertex2fImport((Context.Width - VStringLength) div 2, (Context.Height - 20) div 2),
		SGVertex2fImport((Context.Width + VStringLength) div 2, (Context.Height + 00) div 2));
	VStringLength := SGScreen.Font.StringLength(WarningString2);
	SGScreen.Font.DrawFontFromTwoVertex2f(WarningString2,
		SGVertex2fImport((Context.Width - VStringLength) div 2, (Context.Height + 00) div 2),
		SGVertex2fImport((Context.Width + VStringLength) div 2, (Context.Height + 20) div 2));
	end;
end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample13;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
