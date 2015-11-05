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
		procedure AddModels(const VCount : TIndex);
			private
		FCamera : TSGCamera;
		FShaderProgram : TSGShaderProgram;
		FVertexShader, FFragmentShader : TSGShader;
		FRotateAngle : TSGFloat;
		
		F_ShaderBoneMat  : TSGLongWord;
		F_ShaderTextures : array[0..6] of TSGLongWord;
		
		FTexturesHandles : array[0..6] of TSGLongWord;
		
		// массив с меняющимися данными скелетной анимации
		// (сначала всего 21 персонаж)
		FAnimationStates  : array of TSkelAnimState;
		
		FModel : TModel;
		
		FQuantityModels : TSGLongWord;
		
		FP1Button, 
			FM1Button,
			FP5Button,
			FM5Button,
			FP15Button,
			FM15Button,
			FP100Button,
			FM100Button : TSGButton;
		FFont : TSGFont;
		FCountLabel : TSGLabel;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

procedure TSGExample13.AddModels(const VCount : TIndex);
var
	NewLength, i, Temp : TIndex;
begin
NewLength := FQuantityModels + VCount;
if NewLength < 1 then
	FQuantityModels := 1
else if FQuantityModels >= NewLength then
	FQuantityModels := NewLength
else if Length(FAnimationStates) < NewLength then
	begin
	Temp := FQuantityModels;
	FQuantityModels := NewLength;
	SetLength(FAnimationStates,FQuantityModels);
	for i := Temp to FQuantityModels - 1 do
		begin
		FAnimationStates[i].ResetState(FModel.Animation^.FNodesNum);
		FAnimationStates[i].FPrevFrame:=0;
		FAnimationStates[i].FNextFrame:=random(21);     // номер случайного кадра
		FAnimationStates[i].FPrevAction:=0;
		FAnimationStates[i].FNextAction:=0;
		FAnimationStates[i].FSkelTime:=random(100)/100; // случайный сдвиг анимации
		end;
	end
else if Length(FAnimationStates) >= NewLength then
	FQuantityModels := NewLength;
FCountLabel.Caption := 'Количество моделей: ' + SGStr(FQuantityModels);
end;

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
	i : TIndex;
	MinTextureHandle : TSGLongWord;
begin
Result := 
	'// Fragment Shader '+#13+#10;
for i := 0 to VTexturesCount - 1 do
	Result += 'uniform sampler2D myTexture'+SGStr(i)+'; '+#13+#10;
MinTextureHandle := FTexturesHandles[0];
for i := 1 to High(FTexturesHandles) do
	if FTexturesHandles[i] < MinTextureHandle then
		MinTextureHandle := FTexturesHandles[i];
Result += 
	'varying float texNum; '+#13+#10+
	'void main() '+#13+#10+
	'{ '+#13+#10+
	' float texNum2 = floor(texNum*255 - '+SGStr(MinTextureHandle)+'.0 + 0.001); '+#13+#10;
for i := 0 to VTexturesCount - 1 do
	begin
	if (i <> 0) then
		Result += ' else';
	if i <> VTexturesCount - 1 then
		Result += ' if (texNum2=='+SGStr(i)+'.0) '+#13+#10;
	Result += '  gl_FragColor = texture2D( myTexture'+SGStr(i)+', gl_TexCoord[0].st );  '+#13+#10;
	end;
Result += '}';
end;

class function TSGExample13.ClassName():TSGString;
begin
Result := 'Скелетная анимация';
end;

procedure mmmFP1ButtonProcedure(Button:TSGButton); begin TSGExample13(Button.UserPointer).AddModels(1); end;
procedure mmmFM1ButtonProcedure(Button:TSGButton); begin TSGExample13(Button.UserPointer).AddModels(-1); end;
procedure mmmFP5ButtonProcedure(Button:TSGButton); begin TSGExample13(Button.UserPointer).AddModels(5); end;
procedure mmmFM5ButtonProcedure(Button:TSGButton); begin TSGExample13(Button.UserPointer).AddModels(-5); end;
procedure mmmFP15ButtonProcedure(Button:TSGButton); begin TSGExample13(Button.UserPointer).AddModels(15); end;
procedure mmmFM15ButtonProcedure(Button:TSGButton); begin TSGExample13(Button.UserPointer).AddModels(-15); end;
procedure mmmFP100ButtonProcedure(Button:TSGButton); begin TSGExample13(Button.UserPointer).AddModels(100); end;
procedure mmmFM100ButtonProcedure(Button:TSGButton); begin TSGExample13(Button.UserPointer).AddModels(-100); end;

constructor TSGExample13.Create(const VContext : TSGContext);

procedure CreateButton(var VButton : TSGButton; const x, y : TSGLongWord; const VCaption : TSGString; const VProc : Pointer);inline;
begin
VButton := TSGButton.Create();
SGScreen.CreateChild(VButton);
SGScreen.LastChild.Font := FFont;
SGScreen.LastChild.SetBounds(x,y,100,FFont.FontHeight+3);
SGScreen.LastChild.BoundsToNeedBounds();
SGScreen.LastChild.UserPointer:=Self;
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.Caption := VCaption;
(SGScreen.LastChild as TSGButton).OnChange := TSGComponentProcedure(VProc);
end;

var
	i : TSGWord;
	TempPChar : PChar;
begin
inherited Create(VContext);
FRotateAngle := Random()*360;
FCamera := nil;
FVertexShader := nil;
FFragmentShader := nil;
FShaderProgram := nil;
FModel := nil;
FQuantityModels := 21;
FP1Button := nil;
FM1Button := nil;
FP5Button := nil;
FM5Button := nil;
FP15Button := nil;
FM15Button := nil;
FP100Button := nil;
FM100Button := nil;
FFont := nil;
FCountLabel := nil;

if Render.SupporedShaders() then
	begin
	FFont:=TSGFont.Create(SGFontDirectory+Slash+{$IFDEF MOBILE}'Times New Roman.sgf'{$ELSE}'Tahoma.sgf'{$ENDIF});
	FFont.SetContext(Context);
	FFont.Loading();
	FFont.ToTexture();
	
	FCamera:=TSGCamera.Create();
	FCamera.SetContext(Context);
	FCamera.ViewMode := SG_VIEW_LOOK_AT_OBJECT;
	FCamera.Up:=SGVertexImport(0,0,1);
	FCamera.Location:=SGVertexImport(0,-350,100);
	FCamera.View:=(SGVertexImport(0,0,0)-SGVertexImport(0,-350,100)).Normalized();
	FCamera.Location := FCamera.Location / ScaleForDepth;
	
	FModel := TModel.Create(Context);
	FModel.Load(SGExamplesDirectory + Slash + '13' + Slash + 'c_marine.smd');
	FModel.LoadAnimation(SGExamplesDirectory + Slash + '13' + Slash + 'run.smd');
	FModel.LoadTextures(SGExamplesDirectory + Slash + '13' + Slash);
	FModel.PrepareSkeletalAnimation();
	
	FTexturesHandles[0] := FModel.GetTextureHandle('SM_4B.jpg');
	FTexturesHandles[1] := FModel.GetTextureHandle('pants23.jpg');
	FTexturesHandles[2] := FModel.GetTextureHandle('SM_1pNEW.jpg');
	FTexturesHandles[3] := FModel.GetTextureHandle('body12.jpg');
	FTexturesHandles[4] := FModel.GetTextureHandle('accs.jpg');
	FTexturesHandles[5] := FModel.GetTextureHandle('face.jpg');
	FTexturesHandles[6] := FModel.GetTextureHandle('PC_soldier_beret_red.jpg');
	
	SetLength(FAnimationStates,FQuantityModels);
	// для каждого персонажа делаем случайный номер начального кадра
	for i := 0 to FQuantityModels - 1 do
		begin
		FAnimationStates[i].ResetState(FModel.Animation^.FNodesNum);
		FAnimationStates[i].FPrevFrame:=0;
		FAnimationStates[i].FNextFrame:=random(21);     // номер случайного кадра
		FAnimationStates[i].FPrevAction:=0;
		FAnimationStates[i].FNextAction:=0;
		FAnimationStates[i].FSkelTime:=random(100)/100; // случайный сдвиг анимации
		end;
	
	FModel.MakeMesh();
	
	FVertexShader := TSGShader.Create(Context,SGR_VERTEX_SHADER);
	FVertexShader.Sourse(GetVertexShaderSourse());
	if not FVertexShader.Compile() then
		FVertexShader.PrintInfoLog();

	FFragmentShader := TSGShader.Create(Context,SGR_FRAGMENT_SHADER);
	FFragmentShader.Sourse(GetFragmentShaderSourse(FModel.GetTexturesCount()));
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
	
	CreateButton(FP1Button,Context.Width - 220,10 + (FFont.FontHeight+7) * 0,'+1',@mmmFP1ButtonProcedure);
	CreateButton(FM1Button,Context.Width - 110,10 + (FFont.FontHeight+7) * 0,'-1',@mmmFM1ButtonProcedure);
	CreateButton(FP5Button,Context.Width - 220,10 + (FFont.FontHeight+7) * 1,'+5',@mmmFP5ButtonProcedure);
	CreateButton(FM5Button,Context.Width - 110,10 + (FFont.FontHeight+7) * 1,'-5',@mmmFM5ButtonProcedure);
	CreateButton(FP15Button,Context.Width - 220,10 + (FFont.FontHeight+7) * 2,'+15',@mmmFP15ButtonProcedure);
	CreateButton(FM15Button,Context.Width - 110,10 + (FFont.FontHeight+7) * 2,'-15',@mmmFM15ButtonProcedure);
	CreateButton(FP100Button,Context.Width - 220,10 + (FFont.FontHeight+7) * 3,'+100',@mmmFP100ButtonProcedure);
	CreateButton(FM100Button,Context.Width - 110,10 + (FFont.FontHeight+7) * 3,'-100',@mmmFM100ButtonProcedure);
	
	FCountLabel := TSGLabel.Create();
	SGScreen.CreateChild(FCountLabel);
	SGScreen.LastChild.Font := FFont;
	SGScreen.LastChild.Caption := 'Количество моделей: ' + SGStr(FQuantityModels);
	SGScreen.LastChild.SetBounds(Context.Width - 220,10 + (FFont.FontHeight+7) * 4,210,FFont.FontHeight+3);
	SGScreen.LastChild.BoundsToNeedBounds();
	SGScreen.LastChild.Visible := True;
	
	end;
end;

destructor TSGExample13.Destroy();
var
	i : TIndex;
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

for i := 0 to High(FAnimationStates) do
	FAnimationStates[i].ResetState(0);
SetLength(FAnimationStates,0);

Context.CursorInCenter := False;

if (FP1Button <> nil) then
	FP1Button.Destroy();
if (FM1Button <> nil) then
	FM1Button.Destroy();
if (FP5Button <> nil) then
	FP5Button.Destroy();
if (FM5Button <> nil) then
	FM5Button.Destroy();
if (FP15Button <> nil) then
	FP15Button.Destroy();
if (FM15Button <> nil) then
	FM15Button.Destroy();
if (FP100Button <> nil) then
	FP100Button.Destroy();
if (FM100Button <> nil) then
	FM100Button.Destroy();
if (FCountLabel <> nil) then
	FCountLabel.Destroy();

if FFont <> nil then
	FFont.Destroy();
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
		Render.ActiveTexture(i);
		Render.Enable(SGR_TEXTURE_2D);
		Render.BindTexture(SGR_TEXTURE_2D,FTexturesHandles[i]);
		Render.Uniform1i(F_ShaderTextures[i],i);
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
