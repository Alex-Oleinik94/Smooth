{$INCLUDE Smooth.inc}
{$IFDEF ENGINE}
	unit Ex13;
	interface
{$ELSE}
	program Example13;
	{$ENDIF}
uses
	{$IF defined(UNIX) and (not defined(ANDROID)) and (not defined(ENGINE))}
		cthreads,
		{$ENDIF}
	 SmoothContextInterface
	,SmoothContextClasses
	,SmoothBase
	,SmoothFont
	,SmoothRenderBase
	,SmoothCommonStructs
	,Smooth3dObject
	,SmoothShaders
	,SmoothScreenBase
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothFPSViewer
	,SmoothCamera
	,SmoothScreenClasses
	,SmoothContextUtils
	{$IF not defined(ENGINE)}
		,SmoothConsolePaintableTools
		,SmoothConsoleHandler
		{$ENDIF}
	
	,Ex13_Model
	
	,Crt
	;

const
	ScaleForDepth = 12;

type
	TSExample13=class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
		class function Supported(const _Context : ISContext) : TSBoolean; override;
			public
		function GetVertexShaderSource():TSString;
		function GetFragmentShaderSource(const VTexturesCount : TSLongWord):TSString;
		procedure AddModels(const VCount : TIndex);
			private
		FCamera : TSCamera;
		FFPS : TSFPSViewer;
		FShaderProgram : TSShaderProgram;
		FVertexShader, FFragmentShader : TSShader;
		FRotateAngle : TSFloat;
		
		F_ShaderBoneMat  : TSLongWord;
		F_ShaderTextures : array[0..6] of TSLongWord;
		
		FTexturesHandles : array[0..6] of TSLongWord;
		
		// массив с меняющимися данными скелетной анимации
		FAnimationStates  : array of TSkelAnimState;
		
		FModel : TModel;
		
		FQuantityModels : TSLongWord;
		
		FP1Button, 
			FM1Button,
			FP5Button,
			FM5Button,
			FP15Button,
			FM15Button,
			FP100Button,
			FM100Button : TSScreenButton;
		FFont : TSFont;
		FCountLabel : TSScreenLabel;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

procedure TSExample13.AddModels(const VCount : TIndex);
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
FCountLabel.Caption := 'Количество моделей: ' + SStr(FQuantityModels);
end;

function TSExample13.GetVertexShaderSource():TSString;
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

function TSExample13.GetFragmentShaderSource(const VTexturesCount : TSLongWord):TSString;
var
	i : TIndex;
begin
Result := 
	'// Fragment Shader '+#13+#10;
for i := 0 to VTexturesCount - 1 do
	Result += 'uniform sampler2D myTexture'+SStr(i)+'; '+#13+#10;
Result += 
	'varying float texNum; '+#13+#10+
	'void main() '+#13+#10+
	'{ '+#13+#10+
	' float texNum2 = floor(texNum*255 + 0.001); '+#13+#10;
for i := 0 to VTexturesCount - 1 do
	begin
	if (i <> 0) then
		Result += ' else';
	if i <> VTexturesCount - 1 then
		Result += ' if (texNum2=='+SStr(i)+'.0) '+#13+#10;
	Result += '  gl_FragColor = texture2D( myTexture'+SStr(i)+', gl_TexCoord[0].st );  '+#13+#10;
	end;
Result += '}';
end;

class function TSExample13.ClassName():TSString;
begin
Result := 'Скелетная анимация';
end;

procedure SExample13P1ButtonProcedure(Button:TSScreenButton); begin TSExample13(Button.UserPointer).AddModels(1); end;
procedure SExample13M1ButtonProcedure(Button:TSScreenButton); begin TSExample13(Button.UserPointer).AddModels(-1); end;
procedure SExample13P5ButtonProcedure(Button:TSScreenButton); begin TSExample13(Button.UserPointer).AddModels(5); end;
procedure SExample13M5ButtonProcedure(Button:TSScreenButton); begin TSExample13(Button.UserPointer).AddModels(-5); end;
procedure SExample13P15ButtonProcedure(Button:TSScreenButton); begin TSExample13(Button.UserPointer).AddModels(15); end;
procedure SExample13M15ButtonProcedure(Button:TSScreenButton); begin TSExample13(Button.UserPointer).AddModels(-15); end;
procedure SExample13P100ButtonProcedure(Button:TSScreenButton); begin TSExample13(Button.UserPointer).AddModels(100); end;
procedure SExample13M100ButtonProcedure(Button:TSScreenButton); begin TSExample13(Button.UserPointer).AddModels(-100); end;

constructor TSExample13.Create(const VContext : ISContext);

procedure CreateButton(var VButton : TSScreenButton; const x, y : TSLongWord; const VCaption : TSString; const VProc : Pointer);inline;
begin
VButton := TSScreenButton.Create();
Screen.CreateInternalComponent(VButton);
VButton.Skin := VButton.Skin.CreateDependentSkinWithAnotherFont(FFont);
VButton.SetBounds(x,y,100,FFont.FontHeight+3);
VButton.BoundsMakeReal();
VButton.UserPointer:=Self;
VButton.Visible:=True;
VButton.Caption := VCaption;
VButton.Anchors:=[SAnchRight];
VButton.OnChange := TSScreenComponentProcedure(VProc);
end;

var
	i : TSWord;
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

if Render.SupportedShaders() then
	begin
	FFont := SCreateFontFromFile(Context, SDefaultFontFileName, True);
	
	FFPS := TSFPSViewer.Create(Context);
	FFPS.X := Render.Width div 2;
	FFPS.Y := 5;
	
	FCamera:=TSCamera.Create();
	FCamera.SetContext(Context);
	FCamera.ViewMode := SMotileObjective;
	FCamera.Motile := False;
	FCamera.Up := SVertex3fImport(0,0,1);
	FCamera.Location:=SVertex3fImport(0,-350,100);
	FCamera.View:=(SVertex3fImport(0,0,0)-SVertex3fImport(0,-350,100)).Normalized();
	FCamera.Location := FCamera.Location / ScaleForDepth;
	
	FModel := TModel.Create(Context);
	FModel.Load(SExamplesDirectory + DirectorySeparator + '13' + DirectorySeparator + 'c_marine.smd');
	FModel.LoadAnimation(SExamplesDirectory + DirectorySeparator + '13' + DirectorySeparator + 'run.smd');
	FModel.LoadTextures(SExamplesDirectory + DirectorySeparator + '13' + DirectorySeparator);
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
	
	FModel.Make3dObject();
	
	FVertexShader := TSShader.Create(Context,SR_VERTEX_SHADER);
	FVertexShader.Source(GetVertexShaderSource());
	if not FVertexShader.Compile() then
		FVertexShader.PrintInfoLog();

	FFragmentShader := TSShader.Create(Context,SR_FRAGMENT_SHADER);
	FFragmentShader.Source(GetFragmentShaderSource(FModel.GetTexturesCount()));
	if not FFragmentShader.Compile() then
		FFragmentShader.PrintInfoLog();

	FShaderProgram := TSShaderProgram.Create(Context);
	FShaderProgram.Attach(FVertexShader);
	FShaderProgram.Attach(FFragmentShader);
	if not FShaderProgram.Link() then
		FShaderProgram.PrintInfoLog();

	F_ShaderBoneMat := Render.GetUniformLocation(FShaderProgram.Handle,'boneMat');
	for i := 0 to High(F_ShaderTextures) do
		begin
		TempPChar := SStringToPChar('myTexture'+SStr(i));
		F_ShaderTextures[i] := Render.GetUniformLocation(FShaderProgram.Handle, TempPChar);
		FreeMem(TempPChar)
		end;
	
	CreateButton(FP1Button,Render.Width - 220,10 + (FFont.FontHeight+7) * 0,'+1',@SExample13P1ButtonProcedure);
	CreateButton(FM1Button,Render.Width - 110,10 + (FFont.FontHeight+7) * 0,'-1',@SExample13M1ButtonProcedure);
	CreateButton(FP5Button,Render.Width - 220,10 + (FFont.FontHeight+7) * 1,'+5',@SExample13P5ButtonProcedure);
	CreateButton(FM5Button,Render.Width - 110,10 + (FFont.FontHeight+7) * 1,'-5',@SExample13M5ButtonProcedure);
	CreateButton(FP15Button,Render.Width - 220,10 + (FFont.FontHeight+7) * 2,'+15',@SExample13P15ButtonProcedure);
	CreateButton(FM15Button,Render.Width - 110,10 + (FFont.FontHeight+7) * 2,'-15',@SExample13M15ButtonProcedure);
	CreateButton(FP100Button,Render.Width - 220,10 + (FFont.FontHeight+7) * 3,'+100',@SExample13P100ButtonProcedure);
	CreateButton(FM100Button,Render.Width - 110,10 + (FFont.FontHeight+7) * 3,'-100',@SExample13M100ButtonProcedure);
	
	FCountLabel := SCreateLabel(
		Screen, 'Количество моделей: ' + SStr(FQuantityModels), Render.Width - 220,10 + (FFont.FontHeight+7) * 4,210,FFont.FontHeight+3,
		FFont, [SAnchRight], True, True);
	end;
end;

destructor TSExample13.Destroy();
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

Context.CursorCentered := False;

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
if FFPS <> nil then
	FFPS.Destroy();
//    allready processed in TSShaderProgram.Destroy()
//FVertexShader.Destroy();
//FFragmentShader.Destroy();
inherited;
end;

class function TSExample13.Supported(const _Context : ISContext) : TSBoolean;
begin
Result := _Context.Render.SupportedShaders();
end;

procedure TSExample13.Paint();
const
	WarningString1 : String = 'Вы не сможете просмотреть это пример!';
	WarningString2 : String = 'На вашем устройстве не поддерживаются шейдеры!';
var
	VStringLength : TSLongWord;
	i : LongWord;
begin
if Render.SupportedShaders() then
	begin
	FCamera.InitMatrixAndMove();
	FRotateAngle += Context.ElapsedTime/10;
	if (not Context.CursorCentered) then
		Render.Rotatef(FRotateAngle,FCamera.Up.x,FCamera.Up.y,FCamera.Up.z);
	Render.Color3f(1,1,1);
	Render.Disable(SR_BLEND);
	FShaderProgram.Use();
	Render.Scale(1/ScaleForDepth,1/ScaleForDepth,1/ScaleForDepth);
	
	for i := 0 to High(F_ShaderTextures) do
		begin
		Render.ActiveTexture(i);
		Render.Enable(SR_TEXTURE_2D);
		Render.BindTexture(SR_TEXTURE_2D,FTexturesHandles[i]);
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
		FModel.Paint();
		Render.PopMatrix();
		end;
	
	for i := High(F_ShaderTextures) downto 0 do
		begin
		Render.ActiveTexture(i);
		Render.BindTexture(SR_TEXTURE_2D,0);
		Render.Disable(SR_TEXTURE_2D);
		end;
	
	Render.Scale(1,1,1);
	Render.UseProgram(0);
	Render.Enable(SR_BLEND);
	
	FFPS.Paint();
	end
else
	begin
	Render.InitMatrixMode(S_2D);
	
	Render.Color3f(1,0,0);
	VStringLength := (Screen as TSScreenComponent).Skin.Font.StringLength(WarningString1);
	(Screen as TSScreenComponent).Skin.Font.DrawFontFromTwoVertex2f(WarningString1,
		SVertex2fImport((Render.Width - VStringLength) div 2, (Render.Height - 20) div 2),
		SVertex2fImport((Render.Width + VStringLength) div 2, (Render.Height + 00) div 2));
	VStringLength := (Screen as TSScreenComponent).Skin.Font.StringLength(WarningString2);
	(Screen as TSScreenComponent).Skin.Font.DrawFontFromTwoVertex2f(WarningString2,
		SVertex2fImport((Render.Width - VStringLength) div 2, (Render.Height + 00) div 2),
		SVertex2fImport((Render.Width + VStringLength) div 2, (Render.Height + 20) div 2));
	end;
end;

{$IFNDEF ENGINE}
	begin
	SConsoleRunPaintable(TSExample13, SSystemParamsToConsoleHandlerParams());
	{$ENDIF}
end.
