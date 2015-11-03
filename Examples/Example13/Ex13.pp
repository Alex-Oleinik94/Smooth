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
	ScaleForDepth = 12;

type
	TSGExample13=class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
		procedure KeyControl();
		function GetVertexShaderSourse():TSGString;
		function GetFragmentShaderSourse(const VTexturesCount : TSGLongWord):TSGString;
			private
		FCamera : TSGCamera;
		FShaderProgram : TSGShaderProgram;
		FVertexShader, FFragmentShader : TSGShader;
		FRotateAngle : TSGFloat;
		
		F_ShaderBoneMat  : TSGLongWord;
		F_ShaderTextures : array[0..6] of TSGLongWord;
		
		FTexturesHandles : array[0..6] of TSGLongWord;
		
		// массив с меняющимися данными скелетной анимации
		// (в данном случае всего 21 персонаж)
		FAnimationStates  : array[0..20] of TSkelAnimState;
		
		FModel : TModel;
		
		FQuantityModels : TSGLongWord;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

function TSGExample13.GetVertexShaderSourse():TSGString;
begin
Result := '// Vertex Shader '+#13+#10+
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
end;

function TSGExample13.GetFragmentShaderSourse(const VTexturesCount : TSGLongWord):TSGString;
var
	i : TSGLongWord;
begin
Result := 
	'// Fragment Shader '+#13+#10;
for i := 0 to VTexturesCount - 1 do
	Result += 'uniform sampler2D myTexture'+SGStr(i)+'; '+#13+#10;
Result += 
	'varying float texNum; '+#13+#10+
	'void main() '+#13+#10+
	'{ '+#13+#10+
	' float texNum2 = floor(texNum*255.0-1.0+0.001); '+#13+#10;
for i := 0 to VTexturesCount - 1 do
	begin
	if (i <> 0) then
		Result += ' else';
	Result += ' if (texNum2=='+SGStr(i)+'.0) '+#13+#10;
	Result += '  gl_FragColor = texture2D( myTexture'+SGStr(i)+', gl_TexCoord[0].st );  '+#13+#10;
	end;
Result += '}';
end;

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
FQuantityModels := 21;

if Render.SupporedShaders() then
	begin
	FCamera:=TSGCamera.Create();
	FCamera.SetContext(Context);
	FCamera.ViewMode := SG_VIEW_LOOK_AT_OBJECT;
	FCamera.Up:=SGVertexImport(0,0,1);
	FCamera.Location:=SGVertexImport(0,-350,100);
	FCamera.View:=(SGVertexImport(0,0,0)-SGVertexImport(0,-350,100)).Normalized();
	FCamera.Location := FCamera.Location / ScaleForDepth;
	
	FVertexShader := TSGShader.Create(Context,SGR_VERTEX_SHADER);
	FVertexShader.Sourse(GetVertexShaderSourse());
	if not FVertexShader.Compile() then
		FVertexShader.PrintInfoLog();

	FFragmentShader := TSGShader.Create(Context,SGR_FRAGMENT_SHADER);
	FFragmentShader.Sourse(GetFragmentShaderSourse(7));
	if not FFragmentShader.Compile() then
		FFragmentShader.PrintInfoLog();

	FShaderProgram := TSGShaderProgram.Create(Context);
	FShaderProgram.Attach(FVertexShader);
	FShaderProgram.Attach(FFragmentShader);
	if not FShaderProgram.Link() then
		FShaderProgram.PrintInfoLog();

	F_ShaderBoneMat := Render.GetUniformLocation(FShaderProgram.Handle,'boneMat');
	for i := 0 to High(F_ShaderTextures) do
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
	
	FTexturesHandles[0] := FModel.GetTextureHandle('SM_4B.jpg');
	FTexturesHandles[1] := FModel.GetTextureHandle('pants23.jpg');
	FTexturesHandles[2] := FModel.GetTextureHandle('SM_1pNEW.jpg');
	FTexturesHandles[3] := FModel.GetTextureHandle('body12.jpg');
	FTexturesHandles[4] := FModel.GetTextureHandle('accs.jpg');
	FTexturesHandles[5] := FModel.GetTextureHandle('face.jpg');
	FTexturesHandles[6] := FModel.GetTextureHandle('PC_soldier_beret_red.jpg');
	
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

Context.CursorInCenter := False;

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
	FRotateAngle += Context.ElapsedTime/10;
	if (not Context.CursorInCenter) then
		Render.Rotatef(FRotateAngle,FCamera.Up.x,FCamera.Up.y,FCamera.Up.z);
	Render.Color3f(1,1,1);
	Render.Disable(SGR_BLEND);
	FShaderProgram.Use();
	Render.Scale(1/ScaleForDepth,1/ScaleForDepth,1/ScaleForDepth);
	
	for i := 0 to High(F_ShaderTextures) do
		begin
		Render.Uniform1i(F_ShaderTextures[i],i);
		Render.ActiveTexture(i);
		Render.Enable(SGR_TEXTURE_2D);
		Render.BindTexture(SGR_TEXTURE_2D,FTexturesHandles[i]);
		end;
	
	
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
	
	for i := High(F_ShaderTextures) downto 0 do
		begin
		Render.ActiveTexture(i);
		Render.BindTexture(SGR_TEXTURE_2D,0);
		Render.Disable(SGR_TEXTURE_2D);
		end;
	
	Render.Scale(1,1,1);
	Render.UseProgram(0);
	Render.Enable(SGR_BLEND);
	
	//KeyControl();
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

procedure TSGExample13.KeyControl();
const
	RotateConst = 0.002;
var
	Q, E : TSGBoolean;
	RotateZ : TSGFloat = 0;
begin
if (Context.KeyPressed and (Context.KeyPressedChar = #27) and (Context.KeyPressedType = SGUpKey)) then
	begin
	Context.CursorInCenter := not Context.CursorInCenter;
	Context.ShowCursor(not Context.CursorInCenter);
	end;

Q := Context.KeysPressed('Q');
E := Context.KeysPressed('E');
if (Q xor E) then
	begin
	if Q then
		RotateZ := Context.ElapsedTime*2
	else
		RotateZ := -Context.ElapsedTime*2;
	end;

if (Context.KeysPressed('W')) then
	FCamera.Move(Context.ElapsedTime*0.7);
if (Context.KeysPressed('S')) then
	FCamera.Move(-Context.ElapsedTime*0.7);
if (Context.KeysPressed('A')) then
	FCamera.MoveSidewards(-Context.ElapsedTime*0.7);
if (Context.KeysPressed('D')) then
	FCamera.MoveSidewards(Context.ElapsedTime*0.7);
if (Context.KeysPressed(' ')) then
	FCamera.MoveUp(Context.ElapsedTime*0.7);
if (Context.KeysPressed('X')) then
	FCamera.MoveUp(-Context.ElapsedTime*0.7);
if (Context.CursorInCenter) then
	FCamera.Rotate(Context.CursorPosition(SGDeferenseCursorPosition).y*RotateConst,Context.CursorPosition(SGDeferenseCursorPosition).x/Context.Width*Context.Height*RotateConst,RotateZ*RotateConst);
end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample13;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
