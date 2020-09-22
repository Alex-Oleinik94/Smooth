{$INCLUDE Smooth.inc}
{$IFDEF ENGINE}
	unit Ex15;
	interface
{$ELSE}
	program Example15;
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
	,SmoothVertexObject
	,SmoothShaders
	,SmoothImage
	,SmoothScreenBase
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothFPSViewer
	,SmoothCamera
	,SmoothMatrix
	,SmoothScreenClasses
	,SmoothContextUtils
	{$IF not defined(ENGINE)}
		,SmoothConsolePaintableTools
		,SmoothConsoleHandler
		{$ENDIF}
	
	,Math
	,Crt
	
	,Ex5_Physics
	,Ex13_Model
	,Ex15_Shadow
	;

const
	ScaleForDepth = 12;

type
	TSExample15 = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
		class function Supported(const _Context : ISContext) : TSBoolean; override;
		procedure Paint();override;
			public
		procedure KeyControl();
		procedure AddModels(const VCount : TIndex);
			private
		FCamera : TSCamera;
		FFPS : TSFPSViewer;
		FRotateAngleCamera, FRotateAngleLight : TSFloat;
		FLigthCameraAngle : TSFloat;
		
		FLigthSphere: TS3DObject;
		
		FTexturesHandles : array[0..6] of TSLongWord;
		FStoneImageD,FStoneImageB : TSImage;
		
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
		FHelpLabel : TSScreenLabel;
		
		FLightsCount : TSLongWord;
		FLightsSettings : packed array of
			packed record
				FMn : TSFloat;
				end;
		FShadow : TSExample15_Shadow;
		FBigRad : TSFloat;
		
		FUseCameraAnimation,
			FUseLightAnimation,
			FUseSkeletonAnimation : TSBoolean;
			private
		procedure DrawPlane(const PlaneSize, PlaneHeight : TSFloat);
		procedure AnimateModels();
		procedure DrawModels();
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSExample15.Supported(const _Context : ISContext) : TSBoolean;
begin
Result := _Context.Render.SupportedShaders();
end;

procedure TSExample15.AddModels(const VCount : TIndex);
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
		FAnimationStates[i].Animate(FModel,0,1,False);
		FAnimationStates[i].CopyBonesForShader();
		end;
	end
else if Length(FAnimationStates) >= NewLength then
	FQuantityModels := NewLength;
FCountLabel.Caption := 'Количество моделей: ' + SStr(FQuantityModels);
FBigRad := (30+5*(FQuantityModels - 1)) / 12 + 10;
end;

class function TSExample15.ClassName():TSString;
begin
Result := 'Скелетная анимация, Shadow and Bump Mapping';
end;

procedure mmmFP1ButtonProcedure(Button:TSScreenButton); begin TSExample15(Button.UserPointer).AddModels(1); end;
procedure mmmFM1ButtonProcedure(Button:TSScreenButton); begin TSExample15(Button.UserPointer).AddModels(-1); end;
procedure mmmFP5ButtonProcedure(Button:TSScreenButton); begin TSExample15(Button.UserPointer).AddModels(5); end;
procedure mmmFM5ButtonProcedure(Button:TSScreenButton); begin TSExample15(Button.UserPointer).AddModels(-5); end;
procedure mmmFP15ButtonProcedure(Button:TSScreenButton); begin TSExample15(Button.UserPointer).AddModels(15); end;
procedure mmmFM15ButtonProcedure(Button:TSScreenButton); begin TSExample15(Button.UserPointer).AddModels(-15); end;
procedure mmmFP100ButtonProcedure(Button:TSScreenButton); begin TSExample15(Button.UserPointer).AddModels(100); end;
procedure mmmFM100ButtonProcedure(Button:TSScreenButton); begin TSExample15(Button.UserPointer).AddModels(-100); end;

procedure TSExample15.DrawPlane(const PlaneSize, PlaneHeight : TSFloat);
const
	NumTriangles = 100;
	TextureSize = 4.2;
var
	x,y,x0,y0,a : TSFloat;
	i : TSLongWord;
begin
Render.Color3f(0.4,0.6,0.3);

x0 := cos(0);
y0 := sin(0);
x := x0 * PlaneSize;
y := y0 * PlaneSize;
a := PI*2/50;
Render.BeginScene(SR_TRIANGLES);
Render.Normal(SVertex3fImport(0,0,1).Normalized());
for i := 0 to 49 do
	begin
	Render.TexCoord2f(x / TextureSize, y / TextureSize);
	Render.Vertex3f(x, y, -PlaneHeight);
	Render.TexCoord2f(0, 0);
	Render.Vertex3f(0, 0, -PlaneHeight);
	x0 := cos(a);
	y0 := sin(a);
	x := x0 * PlaneSize;
	y := y0 * PlaneSize;
	a += PI*2/50;
	Render.TexCoord2f(x / TextureSize, y / TextureSize);
	Render.Vertex3f(x, y, -PlaneHeight);
	end;
Render.EndScene();
end;

constructor TSExample15.Create(const VContext : ISContext);

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
FLigthSphere.ObjectColor:=TSVector4f.Create(1,1,1,1);
FLigthSphere.EnableCullFace := True;

FPhysics.Destroy();
end;

procedure CreateButton(var VButton : TSScreenButton; const x, y : TSLongWord; const VCaption : TSString; const VProc : Pointer);inline;
begin
VButton := TSScreenButton.Create();
Screen.CreateChild(VButton);
VButton.Skin := VButton.Skin.CreateDependentSkinWithAnotherFont(FFont);
VButton.SetBounds(x,y,100,FFont.FontHeight+3);
VButton.BoundsMakeReal();
VButton.UserPointer:=Self;
VButton.Anchors:=[SAnchRight];
VButton.Visible:=True;
VButton.Caption := VCaption;
VButton.OnChange := TSScreenComponentProcedure(VProc);
end;

var
	i : TSWord;
begin
inherited Create(VContext);
FStoneImageD := nil;
FStoneImageB := nil;
FRotateAngleCamera := Random()*360;
FRotateAngleLight := Random()*360;
FCamera := nil;
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
FUseCameraAnimation := True;
FUseLightAnimation := True;
FUseSkeletonAnimation := True;
FLigthCameraAngle := 50/180*PI;
FShadow := nil;
LoadLigthModel();
FLightsCount := 2;
FShadow := nil;

SetLength(FLightsSettings,FLightsCount);
if FLightsCount > 0 then
	for i := 0 to FLightsCount - 1 do
		begin
		FLightsSettings[i].FMn := Random(200)/60+1;
		if boolean(random(2)) then
			FLightsSettings[i].FMn *= -1;
		end;

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
	FCamera.Up       := SVertex3fImport(0,0,1);
	FCamera.Location := SVertex3fImport(0,-350,100);
	FCamera.View     := (SVertex3fImport(0,0,0)-FCamera.Location).Normalized();
	FCamera.Location := FCamera.Location / ScaleForDepth;
	
	FModel := TModel.Create(Context);
	FModel.Load(SExamplesDirectory + DirectorySeparator + '13' + DirectorySeparator + 'c_marine.smd');
	FModel.LoadAnimation(SExamplesDirectory + DirectorySeparator + '13' + DirectorySeparator + 'run.smd');
	FModel.LoadTextures(SExamplesDirectory + DirectorySeparator + '13' + DirectorySeparator, 2 * FLightsCount + 2);
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
		FAnimationStates[i].Animate(FModel,0,1,False);
		FAnimationStates[i].CopyBonesForShader();
		end;
	FBigRad := (30+5*(FQuantityModels - 1)) / 12 + 10;
	
	FModel.Make3dObject();
	
	FShadow := TSExample15_Shadow.Create(Context, FLightsCount, FModel.Animation^.FNodesNum, FModel.TexturesBlock);
	
	CreateButton(FP1Button,Render.Width - 220,10 + (FFont.FontHeight+7) * 0,'+1',@mmmFP1ButtonProcedure);
	CreateButton(FM1Button,Render.Width - 110,10 + (FFont.FontHeight+7) * 0,'-1',@mmmFM1ButtonProcedure);
	CreateButton(FP5Button,Render.Width - 220,10 + (FFont.FontHeight+7) * 1,'+5',@mmmFP5ButtonProcedure);
	CreateButton(FM5Button,Render.Width - 110,10 + (FFont.FontHeight+7) * 1,'-5',@mmmFM5ButtonProcedure);
	CreateButton(FP15Button,Render.Width - 220,10 + (FFont.FontHeight+7) * 2,'+15',@mmmFP15ButtonProcedure);
	CreateButton(FM15Button,Render.Width - 110,10 + (FFont.FontHeight+7) * 2,'-15',@mmmFM15ButtonProcedure);
	CreateButton(FP100Button,Render.Width - 220,10 + (FFont.FontHeight+7) * 3,'+100',@mmmFP100ButtonProcedure);
	CreateButton(FM100Button,Render.Width - 110,10 + (FFont.FontHeight+7) * 3,'-100',@mmmFM100ButtonProcedure);
	
	FCountLabel := SCreateLabel(
		Screen, 'Models count: ' + SStr(FQuantityModels), Render.Width - 220,10 + (FFont.FontHeight+7) * 4,210,FFont.FontHeight+3,
		FFont, [SAnchRight], True, True);
	FHelpLabel := SCreateLabel(Screen,
		'Press C to change camera mode;' + DefaultEndOfLine +
		'Use WASD to move camera;' + DefaultEndOfLine +
		'Use Mouse or QE to rotate camera;' + DefaultEndOfLine +
		'Use Space or X to move up or down.', 
		Render.Width - 250, Render.Height - (FFont.FontHeight + 2) * 4 - 10, 240, (FFont.FontHeight + 2) * 4,
		FFont, [SAnchRight, SAnchBottom], True, True);
	
	FStoneImageD := SCreateImageFromFile(Context, SExamplesDirectory + DirectorySeparator + '6' + DirectorySeparator + 'D.jpg');
	FStoneImageD.LoadTextureWithBlock(FModel.TexturesBlock);
	
	FStoneImageB := SCreateImageFromFile(Context, SExamplesDirectory + DirectorySeparator + '6' + DirectorySeparator + 'N.jpg');
	FStoneImageB.LoadTextureWithBlock(FModel.TexturesBlock);
	end;
end;

destructor TSExample15.Destroy();
var
	i : TIndex;
begin
SKill(FCamera);
if FModel <> nil then
	FModel.Destroy();
if FShadow <> nil then
	FShadow.Destroy();
if FLigthSphere <> nil then
	FLigthSphere.Destroy();
if FLightsSettings <> nil then
	SetLength(FLightsSettings,0);

for i := 0 to High(FAnimationStates) do
	FAnimationStates[i].ResetState(0);
SetLength(FAnimationStates,0);

Context.CursorCentered := False;

SKill(FP1Button);
SKill(FM1Button);
SKill(FP5Button);
SKill(FM5Button);
SKill(FP15Button);
SKill(FM15Button);
SKill(FP100Button);
SKill(FM100Button);
SKill(FCountLabel);
SKill(FHelpLabel);

SKill(FFont);
SKill(FFPS);
SKill(FStoneImageD);
SKill(FStoneImageB);
inherited;
end;

procedure TSExample15.AnimateModels();
var
	i : LongWord;
begin
for i := 0 to FQuantityModels - 1 do
	begin
	FAnimationStates[i].Animate(FModel,0,1,False);
	FAnimationStates[i].CopyBonesForShader();
	end;
end;

procedure TSExample15.DrawModels();
var
	i : LongWord;
	x, y, angle : TSFloat;
	F_ShaderBoneMat  : TSLongWord;
	F_ShaderTextures : array[0..6] of TSLongWord;
begin
F_ShaderBoneMat := FShadow.GetCurrentShader().GetUniformLocation('boneMat');
if FShadow.DrawingScene then
	for i := 0 to High(F_ShaderTextures) do
		begin
		F_ShaderTextures[i] := FShadow.GetCurrentShader().GetUniformLocation('myTexture'+SStr(i));
		end;

Render.Color3f(1,1,1);
Render.Disable(SR_BLEND);
Render.PushMatrix();
Render.Scale(1/ScaleForDepth,1/ScaleForDepth,1/ScaleForDepth);

if FShadow.DrawingScene then
	for i := 0 to High(F_ShaderTextures) do
		begin
		Render.ActiveTexture(i);
		Render.BindTexture(SR_TEXTURE_2D,FTexturesHandles[i]);
		Render.Uniform1i(F_ShaderTextures[i],i);
		end;

for i := 0 to FQuantityModels - 1 do
	begin
	Render.UniformMatrix4fv(F_ShaderBoneMat, 32, false, @FAnimationStates[i].FShaderAbsoluteMatrixes[0]);
	Render.PushMatrix();
	angle := (FQuantityModels+6.28)*i/FQuantityModels;
	x := (30+5*i)*sin(angle);
	y := (30+5*i)*cos(angle);
	FAnimationStates[i].FSpeed := (30+5*i) * 0.01;
	Render.Translatef(x,y,0);
	Render.Rotatef(-angle / PI * 180 + 90,0,0,1);
	FModel.Paint();
	Render.PopMatrix();
	end;

if FShadow.DrawingScene then
	for i := High(F_ShaderTextures) downto 0 do
		begin
		Render.ActiveTexture(i);
		Render.BindTexture(SR_TEXTURE_2D,0);
		end;

Render.PopMatrix();
Render.Enable(SR_BLEND);
end;

procedure TSExample15.Paint();
const
	WarningString1 : String = 'Вы не сможете просмотреть это пример!';
	WarningString2 : String = 'На вашем устройстве не поддерживаются шейдеры!';
var
	VStringLength, i : TSLongWord;
	FLightInverseModelViewMatrix : TSMatrix4x4;
begin
if Render.SupportedShaders() then
	begin
	if FUseLightAnimation then
		FRotateAngleLight += Context.ElapsedTime/10;
	if FUseSkeletonAnimation then
		AnimateModels();
	if FUseCameraAnimation then
		FRotateAngleCamera += Context.ElapsedTime/10;
	
	for i := 0 to FLightsCount - 1 do
		begin
		FShadow.LightPos[i]   := SVertex3fImport(
			cos(FLightsSettings[i].FMn*FRotateAngleLight/10)*FBigRad,
			sin(FLightsSettings[i].FMn*FRotateAngleLight/10)*FBigRad,
			FBigRad * 1.6);
		FShadow.LightUp[i]    := SVertex3fImport(0,0,1);
		FShadow.LightEye[i]   := SVertex3fImport(0,0,0) + SVertex3fImport(FShadow.LightPos[i].x,FShadow.LightPos[i].y,0)*0.2;
		FShadow.LightAngle[i] := FLigthCameraAngle;
		end;
	
	for i := 0 to FLightsCount - 1 do
		begin
		FShadow.BeginDrawToShadow(i);
		Render.Rotatef(-FRotateAngleCamera*5,0,0,1);
		DrawModels();
		FShadow.EndDrawToShadow();
		end;
	
	Render.ClearColor(0,0,0,0);
	if not FUseCameraAnimation then
		FCamera.Move();
	FCamera.InitMatrix();
	Render.Rotatef(-FRotateAngleCamera*5,0,0,1);
	FShadow.CameraProjectionMatrix := FCamera.ProjectionMatrix();
	FShadow.CameraModelViewMatrix  := FCamera.ModelViewMatrix();
	
	FShadow.BeginDrawScene();
	i := FShadow.GetCurrentShader().GetUniformLocation('renderType');
	Render.Uniform1i(i,0);
	DrawModels();
	Render.Uniform1i(i,2);
	
	FCamera.InitMatrix();
	FShadow.CameraProjectionMatrix := FCamera.ProjectionMatrix();
	FShadow.CameraModelViewMatrix  := FCamera.ModelViewMatrix();
	FShadow.UniformScrene();
	
	Render.ActiveTexture(0);
	Render.BindTexture(SR_TEXTURE_2D,FStoneImageD.Texture);
	Render.Uniform1i(FShadow.GetCurrentShader().GetUniformLocation('myTexture0'),0);
	Render.ActiveTexture(1);
	Render.BindTexture(SR_TEXTURE_2D,FStoneImageB.Texture);
	Render.Uniform1i(FShadow.GetCurrentShader().GetUniformLocation('myTexture1'),1);
	
	DrawPlane(FBigRad,3);
	
	Render.ActiveTexture(0);
	Render.BindTexture(SR_TEXTURE_2D,0);
	Render.ActiveTexture(1);
	Render.BindTexture(SR_TEXTURE_2D,0);
	
	FShadow.EndDrawScene();
	
	for i := 0 to FLightsCount - 1 do
		begin
		Render.PushMatrix();
		FLightInverseModelViewMatrix := SInverseMatrix(FShadow.LightModelViewMatrix[i]);
		Render.MultMatrixf(@FLightInverseModelViewMatrix);
		FLigthSphere.Paint();
		Render.PopMatrix();
		
		Render.BeginScene(SR_LINES);
		Render.Vertex(FShadow.LightPos[i]);
		Render.Vertex(FShadow.LightPos[i] + FShadow.LightDirection[i] * 10);
		Render.EndScene();
		end;
	
	FShadow.KeyboardCallback();
	KeyControl();
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

procedure TSExample15.KeyControl();
begin
if (Context.KeyPressed and (Context.KeyPressedChar = 'C') and (Context.KeyPressedType = SUpKey)) then
	begin
	FUseCameraAnimation := not FUseCameraAnimation;
	FCamera.Motile := not FUseCameraAnimation;
	if FUseCameraAnimation then
		begin
		FCamera.Up   := SVertex3fImport(0,0,1);
		FCamera.View := (-FCamera.Location).Normalized();
		end;
	end;
if (Context.KeyPressed and (Context.KeyPressedChar = 'L') and (Context.KeyPressedType = SUpKey)) then
	begin
	FUseLightAnimation := not FUseLightAnimation;
	end;
if (Context.KeyPressed and (Context.KeyPressedChar = 'K') and (Context.KeyPressedType = SUpKey)) then
	begin
	FUseSkeletonAnimation := not FUseSkeletonAnimation;
	end;
if Context.KeysPressed('T') then
	begin
	if (Context.CursorWheel() = SUpCursorWheel) then
		FLigthCameraAngle += 0.1
	else if (Context.CursorWheel() = SDownCursorWheel) then
		FLigthCameraAngle -= 0.1;
	if FLigthCameraAngle < 0.1 then
		FLigthCameraAngle := 0.1
	else if FLigthCameraAngle > PI then
		FLigthCameraAngle := PI*0.99;
	end;
end;

{$IFNDEF ENGINE}
	begin
	SConsoleRunPaintable(TSExample15, SSystemParamsToConsoleHandlerParams());
	{$ENDIF}
end.
