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
	TSGGazType = object
		FColor : TSGColor4f;
		end;
	TSGSourseType = object
		FGazTypeIndex : TSGLongWord;
		FCoord : TSGPoint3f;
		FRadius : TSGLongWord;
		end;
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
		function Cube (const x,y,z:TSGLongWord):TSGGGDC;
			public
		FCube : TSGGGDC;
		FEdge : TSGLongWord;
		FGazes : packed array of TSGGazType;
		FSourses : packed array of TSGSourseType;
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
		FCube : TSGGasDiffusionCube;
		
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
		
		//Экран
		FAddNewSourseButton,FAddNewGazButton,FStartEmulatingButton : TSGButton;
		end;

implementation

//Algorithm

constructor TSGGasDiffusionCube.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FEdge   := 0;
FCube   := nil;
FSourses:= nil;
FGazes  := nil;
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
FEdge := Edge;
if FEdge mod 2 = 1 then
	FEdge +=1;
GetMem(FCube,Edge*Edge*Edge);
FillChar(FCube^,Edge*Edge*Edge,0);

SetLength(FGazes,3);
FGazes[0].FColor.Import(0,1,0,0.5);
FGazes[1].FColor.Import(1,0,0,0.5);
FGazes[2].FColor.Import(1,1,0,0.5);
SetLength(FSourses,3);
FSourses[0].FGazTypeIndex:=0;
FSourses[0].FCoord.Import(FEdge div 2 + (FEdge div 4),FEdge div 2,FEdge div 2);
FSourses[0].FRadius:=1;
FSourses[1].FGazTypeIndex:=1;
FSourses[1].FCoord.Import(FEdge div 2 - (FEdge div 4),FEdge div 2,FEdge div 2);
FSourses[1].FRadius:=1;
FSourses[2].FGazTypeIndex:=2;
FSourses[2].FCoord.Import(FEdge div 2,FEdge div 2,FEdge div 2);
FSourses[2].FRadius:=1;

UpDateCube();
end;

function TSGGasDiffusionCube.Cube (const x,y,z:TSGLongWord):TSGGGDC;
begin
Result:=@FCube[x*FEdge*FEdge+y*FEdge+z];
end;

procedure TSGGasDiffusionCube.UpDateCube();
procedure UpDateSourses();
var
	I : TSGLongWord;
	j1,j2,j3 : integer;
begin
if FSourses<>nil then
	for i:=0 to High(FSourses) do
		begin
		for j1:=-FSourses[i].FRadius to FSourses[i].FRadius do
		for j2:=-FSourses[i].FRadius to FSourses[i].FRadius do
		for j3:=-FSourses[i].FRadius to FSourses[i].FRadius do
			if Cube(FSourses[i].FCoord.x+j1,FSourses[i].FCoord.y+j2,FSourses[i].FCoord.z+j3)^=0 then
				Cube(FSourses[i].FCoord.x+j1,FSourses[i].FCoord.y+j2,FSourses[i].FCoord.z+j3)^:=FSourses[i].FGazTypeIndex+1;
		end;
end;
procedure MoveGazInSmallCube(const i1,i2,i3:TSGLongWord);inline;
var
	b1,b2:Byte;
begin
case random(3) of
0://x
	begin
	if TSGBoolean(Random(2)) then
		begin// x 1
		b1 := Cube(i1+0,i2,i3)^;
		b2 := Cube(i1+1,i2,i3)^;
		Cube(i1+0,i2,i3)^ := Cube(i1+0,i2,i3+1)^;
		Cube(i1+1,i2,i3)^ := Cube(i1+1,i2,i3+1)^;
		Cube(i1+0,i2,i3+1)^ := Cube(i1+0,i2+1,i3+1)^; 
		Cube(i1+1,i2,i3+1)^ := Cube(i1+1,i2+1,i3+1)^;
		Cube(i1+0,i2+1,i3+1)^ := Cube(i1+0,i2+1,i3)^;
		Cube(i1+1,i2+1,i3+1)^ := Cube(i1+1,i2+1,i3)^;
		Cube(i1+0,i2+1,i3)^ := b1;
		Cube(i1+1,i2+1,i3)^ := b2;
		end
	else
		begin// x 0
		b1 := Cube(i1+0,i2,i3)^;
		b2 := Cube(i1+1,i2,i3)^;
		Cube(i1+0,i2,i3)^ := Cube(i1+0,i2+1,i3)^;
		Cube(i1+1,i2,i3)^ := Cube(i1+1,i2+1,i3)^;
		Cube(i1+0,i2+1,i3)^ := Cube(i1+0,i2+1,i3+1)^; 
		Cube(i1+1,i2+1,i3)^ := Cube(i1+1,i2+1,i3+1)^;
		Cube(i1+0,i2+1,i3+1)^ := Cube(i1+0,i2,i3+1)^;
		Cube(i1+1,i2+1,i3+1)^ := Cube(i1+1,i2,i3+1)^;
		Cube(i1+0,i2,i3+1)^ := b1;
		Cube(i1+1,i2,i3+1)^ := b2;
		end;
	end;
1://y
	begin
	if Boolean(Random(2)) then
		begin// y 1
		b1 := Cube(i1,i2+0,i3)^;
		b2 := Cube(i1,i2+1,i3)^;
		Cube(i1,i2+0,i3)^ := Cube(i1,i2+0,i3+1)^;
		Cube(i1,i2+1,i3)^ := Cube(i1,i2+1,i3+1)^;
		Cube(i1,i2+0,i3+1)^ := Cube(i1+1,i2+0,i3+1)^; 
		Cube(i1,i2+1,i3+1)^ := Cube(i1+1,i2+1,i3+1)^;
		Cube(i1+1,i2+0,i3+1)^ := Cube(i1+1,i2+0,i3)^;
		Cube(i1+1,i2+1,i3+1)^ := Cube(i1+1,i2+1,i3)^;
		Cube(i1+1,i2+0,i3)^ := b1;
		Cube(i1+1,i2+1,i3)^ := b2;
		end
	else
		begin// y 0
		b1 := Cube(i1,i2+0,i3)^;
		b2 := Cube(i1,i2+1,i3)^;
		Cube(i1,i2+0,i3)^ := Cube(i1+1,i2+0,i3)^;
		Cube(i1,i2+1,i3)^ := Cube(i1+1,i2+1,i3)^;
		Cube(i1+1,i2+0,i3)^ := Cube(i1+1,i2+0,i3+1)^; 
		Cube(i1+1,i2+1,i3)^ := Cube(i1+1,i2+1,i3+1)^;
		Cube(i1+1,i2+0,i3+1)^ := Cube(i1,i2+0,i3+1)^;
		Cube(i1+1,i2+1,i3+1)^ := Cube(i1,i2+1,i3+1)^;
		Cube(i1,i2+0,i3+1)^ := b1;
		Cube(i1,i2+1,i3+1)^ := b2;
		end;
	end;
2://z
	begin
	if Boolean(Random(2)) then
		begin// z 1
		b1 := Cube(i1,i2,i3+0)^;
		b2 := Cube(i1,i2,i3+1)^;
		Cube(i1,i2,i3+0)^ := Cube(i1,i2+1,i3+0)^;
		Cube(i1,i2,i3+1)^ := Cube(i1,i2+1,i3+1)^;
		Cube(i1,i2+1,i3+0)^ := Cube(i1+1,i2+1,i3+0)^; 
		Cube(i1,i2+1,i3+1)^ := Cube(i1+1,i2+1,i3+1)^;
		Cube(i1+1,i2+1,i3+0)^ := Cube(i1+1,i2,i3+0)^;
		Cube(i1+1,i2+1,i3+1)^ := Cube(i1+1,i2,i3+1)^;
		Cube(i1+1,i2,i3+0)^ := b1;
		Cube(i1+1,i2,i3+1)^ := b2;
		end
	else
		begin//z 0
		b1 := Cube(i1,i2,i3+0)^;
		b2 := Cube(i1,i2,i3+1)^;
		Cube(i1,i2,i3+0)^ := Cube(i1+1,i2,i3+0)^;
		Cube(i1,i2,i3+1)^ := Cube(i1+1,i2,i3+1)^;
		Cube(i1+1,i2,i3+0)^ := Cube(i1+1,i2+1,i3+0)^; 
		Cube(i1+1,i2,i3+1)^ := Cube(i1+1,i2+1,i3+1)^;
		Cube(i1+1,i2+1,i3+0)^ := Cube(i1,i2+1,i3+0)^;
		Cube(i1+1,i2+1,i3+1)^ := Cube(i1,i2+1,i3+1)^;
		Cube(i1,i2+1,i3+0)^ := b1;
		Cube(i1,i2+1,i3+1)^ := b2;
		end;
	end;
end;
end;
procedure UpDateGaz();
var
	i1,i2,i3:TSGLongWord;
begin
i1:=0;
while i1<FEdge do
	begin
	i2:=0;
	while i2<FEdge do
		begin
		i3:=0;
		while i3<FEdge do
			begin
			MoveGazInSmallCube(i1,i2,i3);
			i3+=2;
			end;
		i2+=2;
		end;
	i1+=2;
	end;
i1:=1;
while i1<FEdge-1 do
	begin
	i2:=1;
	while i2<FEdge-1 do
		begin
		i3:=1;
		while i3<FEdge-1 do
			begin
			MoveGazInSmallCube(i1,i2,i3);
			i3+=2;
			end;
		i2+=2;
		end;
	i1+=2;
	end;
end;
begin
UpDateGaz();
UpDateSourses();
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
		Result.LastObject().SetColor(n,
			FGazes[FCube[i]-1].FColor.r,
			FGazes[FCube[i]-1].FColor.g,
			FGazes[FCube[i]-1].FColor.b);
		Result.LastObject().ArVertex3f[n]^.Import(
			2*(i mod FEdge)/FEdge-1,
			2*((i div FEdge) mod FEdge)/FEdge-1,
			2*((i div FEdge) div FEdge)/FEdge-1);
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
if FStartEmulatingButton<>nil then
	FStartEmulatingButton.Destroy();
if FAddNewGazButton<>nil then
	FAddNewGazButton.Destroy();
if FAddNewSourseButton<>nil then
	FAddNewSourseButton.Destroy();
inherited;
end;

class function TSGGasDiffusion.ClassName():TSGString;
begin
Result := 'Диффузия в газах';
end;

procedure FStartSceneNuttonProcedure(Button:TSGButton);
const
	W = 200;
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
	
	FAddNewGazButton:=TSGButton.Create();
	SGScreen.CreateChild(FAddNewGazButton);
	SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5,W,20);
	SGScreen.LastChild.BoundsToNeedBounds();
	SGScreen.LastChild.Visible:=True;
	SGScreen.LastChild.Active :=False;
	SGScreen.LastChild.Font := FTahomaFont;
	SGScreen.LastChild.Caption:='Добавить новый тип газа';
	SGScreen.LastChild.FUserPointer1:=Button.FUserPointer1;
	FAddNewGazButton.OnChange:=TSGComponentProcedure(nil);
	
	FAddNewSourseButton:=TSGButton.Create();
	SGScreen.CreateChild(FAddNewSourseButton);
	SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,30,W,20);
	SGScreen.LastChild.BoundsToNeedBounds();
	SGScreen.LastChild.Visible:=True;
	SGScreen.LastChild.Active :=False;
	SGScreen.LastChild.Font := FTahomaFont;
	SGScreen.LastChild.Caption:='Добавитьт источник газа';
	SGScreen.LastChild.FUserPointer1:=Button.FUserPointer1;
	FAddNewSourseButton.OnChange:=TSGComponentProcedure(nil);
	
	FStartEmulatingButton:=TSGButton.Create();
	SGScreen.CreateChild(FStartEmulatingButton);
	SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,55,W,20);
	SGScreen.LastChild.BoundsToNeedBounds();
	SGScreen.LastChild.Visible:=True;
	SGScreen.LastChild.Font := FTahomaFont;
	SGScreen.LastChild.Caption:='Начать эмуляцию';
	SGScreen.LastChild.FUserPointer1:=Button.FUserPointer1;
	FStartEmulatingButton.OnChange:=TSGComponentProcedure(nil);
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
FAddNewSourseButton   := nil;
FStartEmulatingButton := nil;
FAddNewGazButton      := nil;

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
FNewScenePanel.LastChild.Caption:='70';
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
	
	//if random(5) = 0 then begin
		FCube.UpDateCube();
		FMesh.Destroy();
		FMesh:=FCube.CalculateMesh;
		//end;
	end;
end;

end.
