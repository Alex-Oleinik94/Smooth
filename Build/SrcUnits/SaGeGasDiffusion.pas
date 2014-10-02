{$INCLUDE SaGe.inc}
unit SaGeGasDiffusion;

interface
uses
	 SaGeBase
	,SaGeBased
	,SaGeMesh
	,SaGeContext
	,SaGeRender
	,SaGeCommon
	,SaGeUtils
	,SaGeScreen;
type
	TSGGGDC = ^byte;
	TSGGasDiffusionCube = class(TSGDrawClass)
			public
		constructor Create(const VContext:TSGContext);override;
		procedure Draw();override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			public
		procedure InitCube(const Edge : TSGLongWord);
		procedure UpDateCube();
		function CalculateMesh():TSGCustomModel;
			public
		FCube : TSGGGDC;
		FEdge : TSGLongWord;
		end;
type
	TSGGasDiffusion=class(TSGDrawClass)
			public
		constructor Create(const VContext:TSGContext);override;
		procedure Draw();override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		FMesh   : TSGCustomModel;
		
		
		//Панели,кнопки и т п
		FTahomaFont : TSGFont;
		FLoadScenePanel,FNewScenePanel:TSGPanel;
		
		//New Pabel
		FEdgeEdit : TSGEdit;
		FNumberLabel : TSGLabel;
		FStartSceneNutton,FEnableLoadButton : TSGButton;
		
		//Load Panel
		FLoadComboBox : TSGComboBox;
		FBackButton, FUpdateButton, FLoadButton : TSGButton;
		
		FCube : TSGGasDiffusionCube;
		end;

implementation

//Algorithm

constructor TSGGasDiffusionCube.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FEdge:=0;
FCube:=nil;
end;

procedure TSGGasDiffusionCube.Draw();
begin

end;

destructor TSGGasDiffusionCube.Destroy();
begin
inherited;
end;

class function TSGGasDiffusionCube.ClassName():TSGString;
begin
Result:='TSGGasDiffusionCube';
end;

procedure TSGGasDiffusionCube.InitCube(const Edge : TSGLongWord);
begin
if FCube<>nil then
	begin
	FreeMem(FCube);
	FCube:=nil;
	end;
GetMem(FCube,Edge*Edge*Edge);
FEdge := Edge;
FillChar(FCube^,Edge*Edge*Edge,0);
FCube[167]:=1;
FCube[385]:=1;
FCube[165]:=1;
end;

procedure TSGGasDiffusionCube.UpDateCube();
begin

end;

function TSGGasDiffusionCube.CalculateMesh():TSGCustomModel;
var
	n : TSGQuadWord = 0;
	i : TSGLongWord;
begin
Result:=TSGCustomModel.Create();
Result.Context := Context;
Result.AddObject();
Result.LastObject().ObjectPoligonesType := SGR_LINES;
Result.LastObject().HasNormals := False;
Result.LastObject().HasTexture := False;
Result.LastObject().HasColors  := True;
Result.LastObject().EnableCullFace := False;
Result.LastObject().VertexType := SGMeshVertexType3f;
Result.LastObject().AutoSetColorType(False);
Result.LastObject().Vertexes   := 8;
Result.LastObject().ArVertex3f[0]^.Import(-1,-1,-1);
Result.LastObject().ArVertex3f[1]^.Import(-1,-1,1);
Result.LastObject().ArVertex3f[2]^.Import(-1,1,1);
Result.LastObject().ArVertex3f[3]^.Import(-1,1,-1);
Result.LastObject().ArVertex3f[4]^.Import(1,-1,-1);
Result.LastObject().ArVertex3f[5]^.Import(1,-1,1);
Result.LastObject().ArVertex3f[6]^.Import(1,1,1);
Result.LastObject().ArVertex3f[7]^.Import(1,1,-1);
Result.LastObject().SetColor(0,$0A/256,$C7/256,$F5/256);
Result.LastObject().SetColor(1,$0A/256,$C7/256,$F5/256);
Result.LastObject().SetColor(2,$0A/256,$C7/256,$F5/256);
Result.LastObject().SetColor(3,$0A/256,$C7/256,$F5/256);
Result.LastObject().SetColor(4,$0A/256,$C7/256,$F5/256);
Result.LastObject().SetColor(5,$0A/256,$C7/256,$F5/256);
Result.LastObject().SetColor(6,$0A/256,$C7/256,$F5/256);
Result.LastObject().SetColor(7,$0A/256,$C7/256,$F5/256);
Result.LastObject().AddFaceArray();
Result.LastObject().AutoSetIndexFormat(0,8);
Result.LastObject().PoligonesType[0] := SGR_LINES;
Result.LastObject().Faces        [0] := 12;
Result.LastObject().SetFaceLine(0,  0,  0,1);
Result.LastObject().SetFaceLine(0,  1,  1,2);
Result.LastObject().SetFaceLine(0,  2,  2,3);
Result.LastObject().SetFaceLine(0,  3,  3,0);

Result.LastObject().SetFaceLine(0,  4,  4,5);
Result.LastObject().SetFaceLine(0,  5,  5,6);
Result.LastObject().SetFaceLine(0,  6,  6,7);
Result.LastObject().SetFaceLine(0,  7,  7,4);

Result.LastObject().SetFaceLine(0,  8,  0,4);
Result.LastObject().SetFaceLine(0,  9,  1,5);
Result.LastObject().SetFaceLine(0,  10,  2,6);
Result.LastObject().SetFaceLine(0,  11,  3,7);

Result.AddObject();
Result.LastObject().ObjectPoligonesType := SGR_POINTS;
Result.LastObject().HasNormals := False;
Result.LastObject().HasTexture := False;
Result.LastObject().HasColors  := True;
Result.LastObject().EnableCullFace := False;
Result.LastObject().VertexType := SGMeshVertexType3f;
Result.LastObject().AutoSetColorType(False);

for i:=0 to FEdge*FEdge*FEdge -1 do
	begin
	if FCube[i]<>0 then
		Inc(n);
	end;

Result.LastObject().Vertexes   := n;

n:=0;
for i:=0 to FEdge*FEdge*FEdge -1 do
	begin
	if FCube[i]<>0 then
		begin
		Result.LastObject().SetColor(n,1,1,1);
		Result.LastObject().ArVertex3f[n]^.Import(
			2*(i mod FEdge)/FEdge-1,
			2*((i div FEdge) mod FEdge)/FEdge-1,
			2*((i div FEdge) div FEdge)/FEdge-1
			);
		{Result.LastObject().ArVertex3f[n]^.Write();
		WriteLn(
			' x:',i mod FEdge,
			' y:',(i div FEdge) mod FEdge,
			' z:',(i div FEdge) div FEdge,
			' ',i, ' ',n);}
		Inc(n);
		end;
	end;

Result.LoadToVBO();
end;

// Release

destructor TSGGasDiffusion.Destroy();
begin
FNewScenePanel.Destroy();
FLoadScenePanel.Destroy();
FTahomaFont.Destroy();
if FCube<>nil then
	FCube.Destroy();
inherited;
end;

class function TSGGasDiffusion.ClassName():TSGString;
begin
Result := 'Диффузия в газах';
end;

procedure FStartSceneNuttonProcedure(Button:TSGButton);
begin
with TSGGasDiffusion(Button.FUserPointer1) do
	begin
	FNewScenePanel.Visible := False;
	if FCube<>nil then
		begin
		FCube.Destroy();
		FCube:=nil;
		end;
	FCube:=TSGGasDiffusionCube.Create(Context);
	FCube.InitCube(SGVal(FEdgeEdit.Caption));
	if FMesh<>nil then
		begin
		FMesh.Destroy();
		FMesh:=nil;
		end;
	FMesh:=FCube.CalculateMesh();
	end;
end;

procedure FUpdateButtonProcedure(Button:TSGButton);
begin
with TSGGasDiffusion(Button.FUserPointer1) do
	begin
	
	end;
end;

procedure FLoadButtonProcedure(Button:TSGButton);
begin
with TSGGasDiffusion(Button.FUserPointer1) do
	begin
	
	end;
end;

procedure FEnableLoadButtonProcedure(Button:TSGButton);
begin
with TSGGasDiffusion(Button.FUserPointer1) do
	begin
	FLoadScenePanel.Visible := True;
	FNewScenePanel .Visible := False;
	end;
end;

procedure FBackButtonProcedure(Button:TSGButton);
begin
with TSGGasDiffusion(Button.FUserPointer1) do
	begin
	FLoadScenePanel.Visible := False;
	FNewScenePanel .Visible := True;
	end;
end;

function FEdgeEditTextTypeFunction(const Self:TSGEdit):TSGBoolean;
var
	i : TSGQuadWord;
begin
Result:=TSGEditTextTypeFunctionNumber(Self);
with TSGGasDiffusion(Self.FUserPointer1) do
	begin
	if Result then
		begin
		i := SGVal(Self.Caption);
		if (i > 999999) or (i=0) then
			begin
			TSGGasDiffusion(Self.FUserPointer1).FNumberLabel.Caption:='^3= ...';
			Result:=False;
			end
		else
			TSGGasDiffusion(Self.FUserPointer1).FNumberLabel.Caption:='^3='+SGStr(i*i*i);
		end
	else
		begin
		TSGGasDiffusion(Self.FUserPointer1).FNumberLabel.Caption:='^3= ...';
		end;
	FStartSceneNutton.Active := Result;
	end;
end;

constructor TSGGasDiffusion.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FMesh := nil;
FCube := nil;
FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);

FTahomaFont:=TSGFont.Create(SGFontDirectory+Slash+'Tahoma.sgf');
FTahomaFont.SetContext(Context);
FTahomaFont.Loading();
FTahomaFont.ToTexture();

FNewScenePanel:=TSGPanel.Create();
SGScreen.CreateChild(FNewScenePanel);
SGScreen.LastChild.SetMiddleBounds(400,80);
SGScreen.LastChild.BoundsToNeedBounds();
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FNewScenePanel.CreateChild(TSGLabel.Create());
FNewScenePanel.LastChild.Caption := 'Создание новой сцены';
FNewScenePanel.LastChild.SetBounds(5,0,275+100,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;

FNewScenePanel.CreateChild(TSGLabel.Create());
FNewScenePanel.LastChild.Caption := 'Количество точек:';
FNewScenePanel.LastChild.SetBounds(5,19,280,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;
FNewScenePanel.LastChild.AsLabel.FTextPosition:=0;

FNumberLabel:=TSGLabel.Create();
FNewScenePanel.CreateChild(FNumberLabel);
FNewScenePanel.LastChild.Caption:='';
FNewScenePanel.LastChild.SetBounds(170,19,180,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;
FNewScenePanel.LastChild.AsLabel.FTextPosition:=0;

FStartSceneNutton:=TSGButton.Create();
FNewScenePanel.CreateChild(FStartSceneNutton);
FNewScenePanel.LastChild.SetBounds(10,44,80,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;
FNewScenePanel.LastChild.Caption:='Старт';
FNewScenePanel.LastChild.FUserPointer1:=Self;
FStartSceneNutton.OnChange:=TSGComponentProcedure(@FStartSceneNuttonProcedure);

FEdgeEdit:=TSGEdit.Create();
FNewScenePanel.CreateChild(FEdgeEdit);
FNewScenePanel.LastChild.SetBounds(118,19,50,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;
FNewScenePanel.LastChild.Caption:='200';
FNewScenePanel.LastChild.FUserPointer1:=Self;
FEdgeEdit.TextTypeFunction:=TSGEditTextTypeFunction(@FEdgeEditTextTypeFunction);
FEdgeEdit.TextType:=SGEditTypeUser;
FEdgeEditTextTypeFunction(FEdgeEdit);

FEnableLoadButton:=TSGButton.Create();
FNewScenePanel.CreateChild(FEnableLoadButton);
FNewScenePanel.LastChild.SetBounds(100,44,270,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;
FNewScenePanel.LastChild.Caption:='Загрузка сохраненной сцены/повтора';
FNewScenePanel.LastChild.FUserPointer1:=Self;
FEnableLoadButton.OnChange:=TSGComponentProcedure(@FEnableLoadButtonProcedure);

FLoadScenePanel:=TSGPanel.Create();
SGScreen.CreateChild(FLoadScenePanel);
SGScreen.LastChild.SetMiddleBounds(440,80);
SGScreen.LastChild.Visible:=False;
SGScreen.LastChild.BoundsToNeedBounds();
SGScreen.LastChild.FUserPointer1:=Self;

FLoadScenePanel.CreateChild(TSGLabel.Create());
FLoadScenePanel.LastChild.Caption := 'Загрузка сохраненной сцены/повтора';
FLoadScenePanel.LastChild.SetBounds(5,0,275+140,20);
FLoadScenePanel.LastChild.BoundsToNeedBounds();
FLoadScenePanel.LastChild.Visible:=False;
FLoadScenePanel.LastChild.Font := FTahomaFont;

FLoadComboBox := TSGComboBox.Create();
FLoadScenePanel.CreateChild(FLoadComboBox);
FLoadComboBox.SetBounds(5,21,480-60,19);
FLoadScenePanel.LastChild.Visible:=False;
FLoadScenePanel.LastChild.BoundsToNeedBounds();
FLoadScenePanel.LastChild.Font := FTahomaFont;
FLoadComboBox.CreateItem('109');
FLoadComboBox.CreateItem('109');
FLoadComboBox.CreateItem('109');
//FLoadComboBox.FProcedure:=TSGComboBoxProcedure(@FLoadComboBoxProcedure);
FLoadComboBox.FSelectItem:=0;
FLoadComboBox.FUserPointer1:=Self;


FBackButton:=TSGButton.Create();
FLoadScenePanel.CreateChild(FBackButton);
FLoadScenePanel.LastChild.SetBounds(10,44,130,20);
FLoadScenePanel.LastChild.BoundsToNeedBounds();
FLoadScenePanel.LastChild.Visible:=False;
FLoadScenePanel.LastChild.Font := FTahomaFont;
FLoadScenePanel.LastChild.Caption:='Назад';
FLoadScenePanel.LastChild.FUserPointer1:=Self;
FBackButton.OnChange:=TSGComponentProcedure(@FBackButtonProcedure);

FUpdateButton:=TSGButton.Create();
FLoadScenePanel.CreateChild(FUpdateButton);
FLoadScenePanel.LastChild.SetBounds(145,44,130,20);
FLoadScenePanel.LastChild.BoundsToNeedBounds();
FLoadScenePanel.LastChild.Visible:=False;
FLoadScenePanel.LastChild.Font := FTahomaFont;
FLoadScenePanel.LastChild.Caption:='Обновить';
FLoadScenePanel.LastChild.FUserPointer1:=Self;
FUpdateButton.OnChange:=TSGComponentProcedure(@FUpdateButtonProcedure);

FLoadButton:=TSGButton.Create();
FLoadScenePanel.CreateChild(FLoadButton);
FLoadScenePanel.LastChild.SetBounds(145+135,44,130,20);
FLoadScenePanel.LastChild.BoundsToNeedBounds();
FLoadScenePanel.LastChild.Visible:=False;
FLoadScenePanel.LastChild.Font := FTahomaFont;
FLoadScenePanel.LastChild.Caption:='Загрузить';
FLoadScenePanel.LastChild.FUserPointer1:=Self;
FLoadButton.OnChange:=TSGComponentProcedure(@FLoadButtonProcedure);
end;

procedure TSGGasDiffusion.Draw();
begin
if FMesh <> nil then
	begin
	FCamera.CallAction();
	FMesh.Draw();
	end;
end;

end.
