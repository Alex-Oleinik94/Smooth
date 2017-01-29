{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex15;
	interface
{$ELSE}
	program Example15;
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
	,SaGeUtils
	,SaGeRenderConstants
	,SaGeCommon
	,SaGeScreen
	,SaGeMesh
	,SaGeShaders
	,SaGeImages
	,SaGeScreenBase
	
	,Math
	,crt
	
	,Ex5_Physics
	,Ex13_Model
	,Ex15_Shadow
	,Ex6_D
	,Ex6_N
	;

const
	ScaleForDepth = 12;

type
	TSGExample15=class(TSGScreenedDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
		procedure KeyControl();
		procedure AddModels(const VCount : TIndex);
			private
		FCamera : TSGCamera;
		FFPS : TSGFPSViewer;
		FRotateAngleCamera, FRotateAngleLight : TSGFloat;
		FLigthCameraAngle : TSGFloat;
		
		FLigthSphere: TSG3DObject;
		
		FTexturesHandles : array[0..6] of TSGLongWord;
		FStoneImageD,FStoneImageB : TSGImage;
		
		// массив с меняющимися данными скелетной анимации
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
		
		FLightsCount : TSGLongWord;
		FLightsSettings : packed array of
			packed record
				FMn : TSGFloat;
				end;
		FShadow : TSGExample15_Shadow;
		FBigRad : TSGFloat;
		
		FUseCameraAnimation,
			FUseLightAnimation,
			FUseSkeletonAnimation : TSGBoolean;
			private
		procedure DrawPlane(const PlaneSize, PlaneHeight : TSGFloat);
		procedure AnimateModels();
		procedure DrawModels();
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

procedure TSGExample15.AddModels(const VCount : TIndex);
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
FCountLabel.Caption := 'Количество моделей: ' + SGStr(FQuantityModels);
FBigRad := (30+5*(FQuantityModels - 1)) / 12 + 10;
end;

class function TSGExample15.ClassName():TSGString;
begin
Result := 'Скелетная анимация + Shadow & Bump Mapping';
end;

procedure mmmFP1ButtonProcedure(Button:TSGButton); begin TSGExample15(Button.UserPointer).AddModels(1); end;
procedure mmmFM1ButtonProcedure(Button:TSGButton); begin TSGExample15(Button.UserPointer).AddModels(-1); end;
procedure mmmFP5ButtonProcedure(Button:TSGButton); begin TSGExample15(Button.UserPointer).AddModels(5); end;
procedure mmmFM5ButtonProcedure(Button:TSGButton); begin TSGExample15(Button.UserPointer).AddModels(-5); end;
procedure mmmFP15ButtonProcedure(Button:TSGButton); begin TSGExample15(Button.UserPointer).AddModels(15); end;
procedure mmmFM15ButtonProcedure(Button:TSGButton); begin TSGExample15(Button.UserPointer).AddModels(-15); end;
procedure mmmFP100ButtonProcedure(Button:TSGButton); begin TSGExample15(Button.UserPointer).AddModels(100); end;
procedure mmmFM100ButtonProcedure(Button:TSGButton); begin TSGExample15(Button.UserPointer).AddModels(-100); end;

procedure TSGExample15.DrawPlane(const PlaneSize, PlaneHeight : TSGFloat);
const
	NumTriangles = 100;
	TextureSize = 4.2;
var
	x,y,x0,y0,a : TSGFloat;
	i : TSGLongWord;
begin
Render.Color3f(0.4,0.6,0.3);

x0 := cos(0);
y0 := sin(0);
x := x0 * PlaneSize;
y := y0 * PlaneSize;
a := PI*2/50;
Render.BeginScene(SGR_TRIANGLES);
Render.Normal(SGVertex3fImport(0,0,1).Normalized());
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

constructor TSGExample15.Create(const VContext : ISGContext);

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

procedure CreateButton(var VButton : TSGButton; const x, y : TSGLongWord; const VCaption : TSGString; const VProc : Pointer);inline;
begin
VButton := TSGButton.Create();
Screen.CreateChild(VButton);
Screen.LastChild.Skin := Screen.LastChild.Skin.CreateDependentSkinWithAnotherFont(FFont);
Screen.LastChild.SetBounds(x,y,100,FFont.FontHeight+3);
Screen.LastChild.BoundsToNeedBounds();
Screen.LastChild.UserPointer:=Self;
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Visible:=True;
Screen.LastChild.Caption := VCaption;
(Screen.LastChild as TSGButton).OnChange := TSGComponentProcedure(VProc);
end;

var
	i : TSGWord;
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

if Render.SupporedShaders() then
	begin
	FFont:=TSGFont.Create(SGFontDirectory+Slash+{$IFDEF MOBILE}'Times New Roman.sgf'{$ELSE}'Tahoma.sgf'{$ENDIF});
	FFont.SetContext(Context);
	FFont.Loading();
	FFont.ToTexture();
	
	FFPS := TSGFPSViewer.Create(Context);
	FFPS.X := Render.Width div 2;
	FFPS.Y := 5;
	
	FCamera:=TSGCamera.Create();
	FCamera.SetContext(Context);
	FCamera.ViewMode := SG_VIEW_LOOK_AT_OBJECT;
	FCamera.ChangingLookAtObject := False;
	FCamera.Up       := SGVertex3fImport(0,0,1);
	FCamera.Location := SGVertex3fImport(0,-350,100);
	FCamera.View     := (SGVertex3fImport(0,0,0)-FCamera.Location).Normalized();
	FCamera.Location := FCamera.Location / ScaleForDepth;
	
	FModel := TModel.Create(Context);
	FModel.Load(SGExamplesDirectory + Slash + '13' + Slash + 'c_marine.smd');
	FModel.LoadAnimation(SGExamplesDirectory + Slash + '13' + Slash + 'run.smd');
	FModel.LoadTextures(SGExamplesDirectory + Slash + '13' + Slash, 2 * FLightsCount + 2);
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
	
	FModel.MakeMesh();
	
	FShadow := TSGExample15_Shadow.Create(Context, FLightsCount, FModel.Animation^.FNodesNum, FModel.TexturesBlock);
	
	CreateButton(FP1Button,Render.Width - 220,10 + (FFont.FontHeight+7) * 0,'+1',@mmmFP1ButtonProcedure);
	CreateButton(FM1Button,Render.Width - 110,10 + (FFont.FontHeight+7) * 0,'-1',@mmmFM1ButtonProcedure);
	CreateButton(FP5Button,Render.Width - 220,10 + (FFont.FontHeight+7) * 1,'+5',@mmmFP5ButtonProcedure);
	CreateButton(FM5Button,Render.Width - 110,10 + (FFont.FontHeight+7) * 1,'-5',@mmmFM5ButtonProcedure);
	CreateButton(FP15Button,Render.Width - 220,10 + (FFont.FontHeight+7) * 2,'+15',@mmmFP15ButtonProcedure);
	CreateButton(FM15Button,Render.Width - 110,10 + (FFont.FontHeight+7) * 2,'-15',@mmmFM15ButtonProcedure);
	CreateButton(FP100Button,Render.Width - 220,10 + (FFont.FontHeight+7) * 3,'+100',@mmmFP100ButtonProcedure);
	CreateButton(FM100Button,Render.Width - 110,10 + (FFont.FontHeight+7) * 3,'-100',@mmmFM100ButtonProcedure);
	
	FCountLabel := TSGLabel.Create();
	Screen.CreateChild(FCountLabel);
	Screen.LastChild.Skin := Screen.LastChild.Skin.CreateDependentSkinWithAnotherFont(FFont);
	Screen.LastChild.Caption := 'Количество моделей: ' + SGStr(FQuantityModels);
	Screen.LastChild.SetBounds(Render.Width - 220,10 + (FFont.FontHeight+7) * 4,210,FFont.FontHeight+3);
	Screen.LastChild.BoundsToNeedBounds();
	Screen.LastChild.Anchors:=[SGAnchRight];
	Screen.LastChild.Visible := True;
	
	FStoneImageD := TSGImage.Create('Ex6_D.jpg');
	FStoneImageD.Context := Context;
	FStoneImageD.Loading();
	FStoneImageD.ToTextureWithBlock(FModel.TexturesBlock);
	
	FStoneImageB := TSGImage.Create('Ex6_N.jpg');
	FStoneImageB.Loading();
	FStoneImageB.Context := Context;
	FStoneImageB.ToTextureWithBlock(FModel.TexturesBlock);
	end;
end;

destructor TSGExample15.Destroy();
var
	i : TIndex;
begin
if FCamera <> nil then
	FCamera.Destroy();
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
if FStoneImageD <> nil then
	FStoneImageD.Destroy();
if FStoneImageB <> nil then
	FStoneImageB.Destroy();
inherited;
end;

procedure TSGExample15.AnimateModels();
var
	i : LongWord;
begin
for i := 0 to FQuantityModels - 1 do
	begin
	FAnimationStates[i].Animate(FModel,0,1,False);
	FAnimationStates[i].CopyBonesForShader();
	end;
end;

procedure TSGExample15.DrawModels();
var
	i : LongWord;
	x, y, angle : TSGFloat;
	F_ShaderBoneMat  : TSGLongWord;
	F_ShaderTextures : array[0..6] of TSGLongWord;
begin
F_ShaderBoneMat := FShadow.GetCurrentShader().GetUniformLocation('boneMat');
if FShadow.DrawingScene then
	for i := 0 to High(F_ShaderTextures) do
		begin
		F_ShaderTextures[i] := FShadow.GetCurrentShader().GetUniformLocation('myTexture'+SGStr(i));
		end;

Render.Color3f(1,1,1);
Render.Disable(SGR_BLEND);
Render.PushMatrix();
Render.Scale(1/ScaleForDepth,1/ScaleForDepth,1/ScaleForDepth);

if FShadow.DrawingScene then
	for i := 0 to High(F_ShaderTextures) do
		begin
		Render.ActiveTexture(i);
		Render.BindTexture(SGR_TEXTURE_2D,FTexturesHandles[i]);
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
		Render.BindTexture(SGR_TEXTURE_2D,0);
		end;

Render.PopMatrix();
Render.Enable(SGR_BLEND);
end;

procedure TSGExample15.Paint();
const
	WarningString1 : String = 'Вы не сможете просмотреть это пример!';
	WarningString2 : String = 'На вашем устройстве не поддерживаются шейдеры!';
var
	VStringLength, i : TSGLongWord;
	FLightInverseModelViewMatrix : TSGMatrix4;
begin
if Render.SupporedShaders() then
	begin
	if FUseLightAnimation then
		FRotateAngleLight += Context.ElapsedTime/10;
	if FUseSkeletonAnimation then
		AnimateModels();
	if FUseCameraAnimation then
		FRotateAngleCamera += Context.ElapsedTime/10;
	
	for i := 0 to FLightsCount - 1 do
		begin
		FShadow.LightPos[i]   := SGVertex3fImport(
			cos(FLightsSettings[i].FMn*FRotateAngleLight/10)*FBigRad,
			sin(FLightsSettings[i].FMn*FRotateAngleLight/10)*FBigRad,
			FBigRad * 1.6);
		FShadow.LightUp[i]    := SGVertex3fImport(0,0,1);
		FShadow.LightEye[i]   := SGVertex3fImport(0,0,0) + SGVertex3fImport(FShadow.LightPos[i].x,FShadow.LightPos[i].y,0)*0.2;
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
		FCamera.Change();
	FCamera.InitMatrix();
	Render.Rotatef(-FRotateAngleCamera*5,0,0,1);
	FShadow.CameraProjectionMatrix := FCamera.GetProjectionMatrix();
	FShadow.CameraModelViewMatrix  := FCamera.GetModelViewMatrix();
	
	FShadow.BeginDrawScene();
	i := FShadow.GetCurrentShader().GetUniformLocation('renderType');
	Render.Uniform1i(i,0);
	DrawModels();
	Render.Uniform1i(i,2);
	
	FCamera.InitMatrix();
	FShadow.CameraProjectionMatrix := FCamera.GetProjectionMatrix();
	FShadow.CameraModelViewMatrix  := FCamera.GetModelViewMatrix();
	FShadow.UniformScrene();
	
	Render.ActiveTexture(0);
	Render.BindTexture(SGR_TEXTURE_2D,FStoneImageD.Texture);
	Render.Uniform1i(FShadow.GetCurrentShader().GetUniformLocation('myTexture0'),0);
	Render.ActiveTexture(1);
	Render.BindTexture(SGR_TEXTURE_2D,FStoneImageB.Texture);
	Render.Uniform1i(FShadow.GetCurrentShader().GetUniformLocation('myTexture1'),1);
	
	DrawPlane(FBigRad,3);
	
	Render.ActiveTexture(0);
	Render.BindTexture(SGR_TEXTURE_2D,0);
	Render.ActiveTexture(1);
	Render.BindTexture(SGR_TEXTURE_2D,0);
	
	FShadow.EndDrawScene();
	
	for i := 0 to FLightsCount - 1 do
		begin
		Render.PushMatrix();
		FLightInverseModelViewMatrix := SGInverseMatrix(FShadow.LightModelViewMatrix[i]);
		Render.MultMatrixf(@FLightInverseModelViewMatrix);
		FLigthSphere.Paint();
		Render.PopMatrix();
		
		Render.BeginScene(SGR_LINES);
		Render.Vertex(FShadow.LightPos[i]);
		Render.Vertex(FShadow.LightPos[i] + FShadow.LightDir[i] * 10);
		Render.EndScene();
		end;
	
	FShadow.KeyboardCallback();
	KeyControl();
	FFPS.Paint();
	end
else
	begin
	Render.InitMatrixMode(SG_2D);
	
	Render.Color3f(1,0,0);
	VStringLength := Screen.Skin.Font.StringLength(WarningString1);
	Screen.Skin.Font.DrawFontFromTwoVertex2f(WarningString1,
		SGVertex2fImport((Render.Width - VStringLength) div 2, (Render.Height - 20) div 2),
		SGVertex2fImport((Render.Width + VStringLength) div 2, (Render.Height + 00) div 2));
	VStringLength := Screen.Skin.Font.StringLength(WarningString2);
	Screen.Skin.Font.DrawFontFromTwoVertex2f(WarningString2,
		SGVertex2fImport((Render.Width - VStringLength) div 2, (Render.Height + 00) div 2),
		SGVertex2fImport((Render.Width + VStringLength) div 2, (Render.Height + 20) div 2));
	end;
end;

procedure TSGExample15.KeyControl();
begin
if (Context.KeyPressed and (Context.KeyPressedChar = 'C') and (Context.KeyPressedType = SGUpKey)) then
	begin
	FUseCameraAnimation := not FUseCameraAnimation;
	FCamera.ChangingLookAtObject := not FUseCameraAnimation;
	Context.CursorCentered := not FUseCameraAnimation;
	Context.ShowCursor(not Context.CursorCentered);
	if FUseCameraAnimation then
		begin
		FCamera.Up   := SGVertex3fImport(0,0,1);
		FCamera.View := (-FCamera.Location).Normalized();
		end;
	end;
if (Context.KeyPressed and (Context.KeyPressedChar = 'L') and (Context.KeyPressedType = SGUpKey)) then
	begin
	FUseLightAnimation := not FUseLightAnimation;
	end;
if (Context.KeyPressed and (Context.KeyPressedChar = 'K') and (Context.KeyPressedType = SGUpKey)) then
	begin
	FUseSkeletonAnimation := not FUseSkeletonAnimation;
	end;
if Context.KeysPressed('T') then
	begin
	if (Context.CursorWheel() = SGUpCursorWheel) then
		FLigthCameraAngle += 0.1
	else if (Context.CursorWheel() = SGDownCursorWheel) then
		FLigthCameraAngle -= 0.1;
	if FLigthCameraAngle < 0.1 then
		FLigthCameraAngle := 0.1
	else if FLigthCameraAngle > PI then
		FLigthCameraAngle := PI*0.99;
	end;
end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample15;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
