{$INCLUDE SaGe.inc}
unit SaGeGasDiffusion;

interface
uses
	 SaGeBase
	,Classes
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
		procedure ClearGaz();
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
		FFileName : TSGString;
		FFileStream : TFileStream;
		FDiffusionRuned : TSGBoolean;
		FEnableSaving : TSGBoolean;
		
		//������,������ � � �
		FTahomaFont : TSGFont;
		FLoadScenePanel,FNewScenePanel:TSGPanel;
		
		//New Pabel
		FEdgeEdit : TSGEdit;
		FNumberLabel : TSGLabel;
		FStartSceneNutton,FEnableLoadButton : TSGButton;
		FEnableOutputComboBox : TSGComboBox;
		
		//Load Panel
		FLoadComboBox : TSGComboBox;
		FBackButton, FUpdateButton, FLoadButton : TSGButton;
		
		//�����
		FAddNewSourseButton,
			FAddNewGazButton,
			FStartEmulatingButton,
			FPauseEmulatingButton,
			FDeleteSechenieButton,
			FAddSechenieButton,
			FBackToMenuButton,
			FStopEmulatingButton : TSGButton;
			private
		procedure ClearDisplayButtons();
		procedure SaveStageToStream();
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

procedure TSGGasDiffusionCube.ClearGaz();
begin
FillChar(FCube^,FEdge*FEdge*FEdge,0);
UpDateCube();
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
GetMem(FCube,FEdge*FEdge*FEdge);
FillChar(FCube^,FEdge*FEdge*FEdge,0);

SetLength(FGazes,3);
FGazes[0].FColor.Import(0,1,0,1);
FGazes[1].FColor.Import(1,0,0,1);
FGazes[2].FColor.Import(1,1,0,1);
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
end;

// Release

procedure TSGGasDiffusion.SaveStageToStream();
begin
if FFileStream<>nil then
	FMesh.SaveToSG3DM(FFileStream);
end;

procedure TSGGasDiffusion.ClearDisplayButtons();
begin
if FStartEmulatingButton<>nil then
	begin
	FStartEmulatingButton.Destroy();
	FStartEmulatingButton:=nil;
	end;
if FAddNewGazButton<>nil then
	begin
	FAddNewGazButton.Destroy();
	FAddNewGazButton:=nil;
	end;
if FAddNewSourseButton<>nil then
	begin
	FAddNewSourseButton.Destroy();
	FAddNewSourseButton:=nil;
	end;
if FPauseEmulatingButton<>nil then
	begin
	FPauseEmulatingButton.Destroy();
	FPauseEmulatingButton:=nil;
	end;
if FStopEmulatingButton<>nil then
	begin
	FStopEmulatingButton.Destroy();
	FStopEmulatingButton:=nil;
	end;
if FDeleteSechenieButton<>nil then
	begin
	FDeleteSechenieButton.Destroy();
	FDeleteSechenieButton:=nil;
	end;
if FAddSechenieButton<>nil then
	begin
	FAddSechenieButton.Destroy();
	FAddSechenieButton:=nil;
	end;
if FBackToMenuButton<>nil then
	begin
	FBackToMenuButton.Destroy();
	FBackToMenuButton:=nil;
	end;
end;

destructor TSGGasDiffusion.Destroy();
begin
FNewScenePanel.Destroy();
FLoadScenePanel.Destroy();
FTahomaFont.Destroy();
if FCube<>nil then
	FCube.Destroy();
if FFileStream<>nil then
	FFileStream.Destroy();
ClearDisplayButtons();
inherited;
end;

class function TSGGasDiffusion.ClassName():TSGString;
begin
Result := '�������� � �����';
end;

procedure mmmFBackToMenuButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.FUserPointer1) do begin
	FAddNewSourseButton.Visible := False;
	FAddNewGazButton.Visible := False;
	FStartEmulatingButton.Visible := False;
	FPauseEmulatingButton.Visible := False;
	FDeleteSechenieButton.Visible := False;
	FAddSechenieButton.Visible := False;
	FBackToMenuButton.Visible := False;
	FStopEmulatingButton.Visible := False;
	
	if FCube<>nil then
		begin
		FCube.Destroy();
		FCube:=nil;
		end;
	if FFileStream<>nil then
		begin
		FFileStream.Destroy();
		FFileStream:=nil;
		end;
	if FMesh<>nil then
		begin
		FMesh.Destroy();
		FMesh:=nil;
		end;
	FDiffusionRuned := False;
	FNewScenePanel.Visible:=True;
end; end;
procedure mmmFPauseDiffusionButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.FUserPointer1) do begin
	FDiffusionRuned := False;
	Button.Active := False;
	FStopEmulatingButton.Active := True;
	FStartEmulatingButton.Active := True;
end; end;
procedure mmmFAddSechenieButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.FUserPointer1) do begin
	FDeleteSechenieButton.Active:=True;
	Button.Active:=False;
end; end;
procedure mmmFDeleteSechenieButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.FUserPointer1) do begin
	FAddSechenieButton.Active:=True;
	Button.Active:=False;
end; end;
procedure mmmFStopDiffusionButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.FUserPointer1) do begin
	FDiffusionRuned := False;
	Button.Active := False;
	FStartEmulatingButton.Active := True;
	FPauseEmulatingButton.Active := False;
	FCube.ClearGaz();
	FMesh:=FCube.CalculateMesh();
end; end;

procedure mmmFRunDiffusionButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.FUserPointer1) do begin
	FDiffusionRuned := True;
	Button.Active := False;
	FStopEmulatingButton.Active := True;
	FPauseEmulatingButton.Active := True;
end; end;

procedure mmmFStartSceneNuttonProcedure(Button:TSGButton);
const
	W = 200;
begin
with TSGGasDiffusion(Button.FUserPointer1) do
	begin
	FEnableSaving := not Boolean(FEnableOutputComboBox.FSelectItem);
	
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
	
	if FEnableSaving then
		begin
		SGMakeDirectory('Gaz Diffusion Saves');
		FFileName := SGGetFreeFileName('Gaz Diffusion Saves'+Slash+'Save.gds','number');
		FFileStream := TFileStream.Create(FFileName,fmCreate);
		
		//SaveStageToStream();
		end;
	
	if FBackToMenuButton = nil then
		begin
		FBackToMenuButton:=TSGButton.Create();
		SGScreen.CreateChild(FBackToMenuButton);
		SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+25*0,W,20);
		SGScreen.LastChild.BoundsToNeedBounds();
		SGScreen.LastChild.Visible := True;
		SGScreen.LastChild.Active  := True;
		SGScreen.LastChild.Font    := FTahomaFont;
		SGScreen.LastChild.Caption :='� "������� ����"';
		SGScreen.LastChild.FUserPointer1:=Button.FUserPointer1;
		FBackToMenuButton.OnChange:=TSGComponentProcedure(@mmmFBackToMenuButtonProcedure);
		end
	else
		begin
		FBackToMenuButton.Visible := True;
		FBackToMenuButton.Active  := True;
		end;
	
	if FAddNewGazButton=nil then
		begin
		FAddNewGazButton:=TSGButton.Create();
		SGScreen.CreateChild(FAddNewGazButton);
		SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+25*1,W,20);
		SGScreen.LastChild.BoundsToNeedBounds();
		SGScreen.LastChild.Visible:=True;
		FAddNewGazButton.Active  := True;
		SGScreen.LastChild.Font := FTahomaFont;
		SGScreen.LastChild.Caption:='�������� ����� ��� ����';
		SGScreen.LastChild.FUserPointer1:=Button.FUserPointer1;
		FAddNewGazButton.OnChange:=TSGComponentProcedure(nil);
		end
	else
		begin
		FAddNewGazButton.Visible := True;
		FAddNewGazButton.Active  := True;
		end;
	
	if FAddNewSourseButton = nil then
		begin
		FAddNewSourseButton:=TSGButton.Create();
		SGScreen.CreateChild(FAddNewSourseButton);
		SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+25*2,W,20);
		SGScreen.LastChild.BoundsToNeedBounds();
		SGScreen.LastChild.Visible:=True;
		FAddNewSourseButton.Active  := True;
		SGScreen.LastChild.Font := FTahomaFont;
		SGScreen.LastChild.Caption:='��������� �������� ����';
		SGScreen.LastChild.FUserPointer1:=Button.FUserPointer1;
		FAddNewSourseButton.OnChange:=TSGComponentProcedure(nil);
		end
	else
		begin
		FAddNewSourseButton.Visible := True;
		FAddNewSourseButton.Active  := True;
		end;
	
	if FStartEmulatingButton=nil then
		begin
		FStartEmulatingButton:=TSGButton.Create();
		SGScreen.CreateChild(FStartEmulatingButton);
		SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+25*3,W,20);
		SGScreen.LastChild.BoundsToNeedBounds();
		SGScreen.LastChild.Visible:=True;
		FStartEmulatingButton.Active  := True;
		SGScreen.LastChild.Font := FTahomaFont;
		SGScreen.LastChild.Caption:='�����������';
		SGScreen.LastChild.FUserPointer1:=Button.FUserPointer1;
		FStartEmulatingButton.OnChange:=TSGComponentProcedure(@mmmFRunDiffusionButtonProcedure);
		end
	else
		begin
		FStartEmulatingButton.Visible := True;
		FStartEmulatingButton.Active  := True;
		end;
	
	if FPauseEmulatingButton = nil then
		begin
		FPauseEmulatingButton:=TSGButton.Create();
		SGScreen.CreateChild(FPauseEmulatingButton);
		SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+25*4,W,20);
		SGScreen.LastChild.BoundsToNeedBounds();
		SGScreen.LastChild.Visible:=True;
		SGScreen.LastChild.Active :=False;
		SGScreen.LastChild.Font := FTahomaFont;
		SGScreen.LastChild.Caption:='������������� ��������';
		SGScreen.LastChild.FUserPointer1:=Button.FUserPointer1;
		FPauseEmulatingButton.OnChange:=TSGComponentProcedure(@mmmFPauseDiffusionButtonProcedure);
		end
	else
		begin
		FPauseEmulatingButton.Visible := True;
		FPauseEmulatingButton.Active  := False;
		end;
	
	if FStopEmulatingButton = nil then
		begin
		FStopEmulatingButton:=TSGButton.Create();
		SGScreen.CreateChild(FStopEmulatingButton);
		SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+25*5,W,20);
		SGScreen.LastChild.BoundsToNeedBounds();
		SGScreen.LastChild.Visible:=True;
		SGScreen.LastChild.Active :=False;
		SGScreen.LastChild.Font := FTahomaFont;
		SGScreen.LastChild.Caption:='Oc�������� ��������';
		SGScreen.LastChild.FUserPointer1:=Button.FUserPointer1;
		FStopEmulatingButton.OnChange:=TSGComponentProcedure(@mmmFStopDiffusionButtonProcedure);
		end
	else
		begin
		FStopEmulatingButton.Visible := True;
		FStopEmulatingButton.Active  := False;
		end;
	
	if FAddSechenieButton = nil then 
		begin
		FAddSechenieButton:=TSGButton.Create();
		SGScreen.CreateChild(FAddSechenieButton);
		SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+25*6,W,20);
		SGScreen.LastChild.BoundsToNeedBounds();
		SGScreen.LastChild.Visible:=True;
		SGScreen.LastChild.Active :=True;
		SGScreen.LastChild.Font := FTahomaFont;
		SGScreen.LastChild.Caption:='����������� �������';
		SGScreen.LastChild.FUserPointer1:=Button.FUserPointer1;
		FAddSechenieButton.OnChange:=TSGComponentProcedure(@mmmFAddSechenieButtonProcedure);
		end
	else
		begin
		FAddSechenieButton.Visible := True;
		FAddSechenieButton.Active  := True;
		end;
	
	if FDeleteSechenieButton = nil then
		begin
		FDeleteSechenieButton:=TSGButton.Create();
		SGScreen.CreateChild(FDeleteSechenieButton);
		SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+25*7,W,20);
		SGScreen.LastChild.BoundsToNeedBounds();
		SGScreen.LastChild.Visible:=True;
		SGScreen.LastChild.Active :=False;
		SGScreen.LastChild.Font := FTahomaFont;
		SGScreen.LastChild.Caption:='�� ������������� �������';
		SGScreen.LastChild.FUserPointer1:=Button.FUserPointer1;
		FDeleteSechenieButton.OnChange:=TSGComponentProcedure(@mmmFDeleteSechenieButtonProcedure);
		end
	else
		begin
		FDeleteSechenieButton.Visible := True;
		FDeleteSechenieButton.Active  := False;
		end;
	end;
end;

procedure mmmFUpdateButtonProcedure(Button:TSGButton);
begin
with TSGGasDiffusion(Button.FUserPointer1) do
	begin
	
	end;
end;

procedure mmmFLoadButtonProcedure(Button:TSGButton);
begin
with TSGGasDiffusion(Button.FUserPointer1) do
	begin
	
	end;
end;

procedure mmmFEnableLoadButtonProcedure(Button:TSGButton);
begin
with TSGGasDiffusion(Button.FUserPointer1) do
	begin
	FLoadScenePanel.Visible := True;
	FNewScenePanel .Visible := False;
	end;
end;

procedure mmmFBackButtonProcedure(Button:TSGButton);
begin
with TSGGasDiffusion(Button.FUserPointer1) do
	begin
	FLoadScenePanel.Visible := False;
	FNewScenePanel .Visible := True;
	end;
end;

function mmmFEdgeEditTextTypeFunction(const Self:TSGEdit):TSGBoolean;
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
FStopEmulatingButton  := nil;
FPauseEmulatingButton := nil;
FDeleteSechenieButton := nil;
FAddSechenieButton    := nil;
FBackToMenuButton     := nil;
FFileName:='';
FFileStream:=nil;
FDiffusionRuned:=False;
FEnableSaving := True;

FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
{$IFDEF ANDROID}
	FCamera.FZum := 0.45;
	{$ENDIF}

FTahomaFont:=TSGFont.Create(SGFontDirectory+Slash+'Tahoma.sgf');
FTahomaFont.SetContext(Context);
FTahomaFont.Loading();
FTahomaFont.ToTexture();

FNewScenePanel:=TSGPanel.Create();
SGScreen.CreateChild(FNewScenePanel);
SGScreen.LastChild.SetMiddleBounds(400,110);
SGScreen.LastChild.BoundsToNeedBounds();
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FNewScenePanel.CreateChild(TSGLabel.Create());
FNewScenePanel.LastChild.Caption := '�������� ����� �����';
FNewScenePanel.LastChild.SetBounds(5,0,275+100,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;

FNewScenePanel.CreateChild(TSGLabel.Create());
FNewScenePanel.LastChild.Caption := '���������� �����:';
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
FNewScenePanel.LastChild.Caption:='�����';
FNewScenePanel.LastChild.FUserPointer1:=Self;
FStartSceneNutton.OnChange:=TSGComponentProcedure(@mmmFStartSceneNuttonProcedure);

FEdgeEdit:=TSGEdit.Create();
FNewScenePanel.CreateChild(FEdgeEdit);
FNewScenePanel.LastChild.SetBounds(118,19,50,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;
FNewScenePanel.LastChild.Caption:='70';
FNewScenePanel.LastChild.FUserPointer1:=Self;
FEdgeEdit.TextTypeFunction:=TSGEditTextTypeFunction(@mmmFEdgeEditTextTypeFunction);
FEdgeEdit.TextType:=SGEditTypeUser;
mmmFEdgeEditTextTypeFunction(FEdgeEdit);

FEnableLoadButton:=TSGButton.Create();
FNewScenePanel.CreateChild(FEnableLoadButton);
FNewScenePanel.LastChild.SetBounds(100,44,270,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;
FNewScenePanel.LastChild.Caption:='�������� ����������� �����/�������';
FNewScenePanel.LastChild.FUserPointer1:=Self;
FEnableLoadButton.OnChange:=TSGComponentProcedure(@mmmFEnableLoadButtonProcedure);

FEnableOutputComboBox := TSGComboBox.Create();
FNewScenePanel.CreateChild(FEnableOutputComboBox);
FEnableOutputComboBox.SetBounds(5,44+26,380,19);
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Font := FTahomaFont;
FEnableOutputComboBox.CreateItem('�������� ����������� ���������� ��������');
FEnableOutputComboBox.CreateItem('�� �������� ����������� ���������� ��������');
//FEnableOutputComboBox.FProcedure:=TSGComboBoxProcedure(@FEnableOutputComboBoxProcedure);
FEnableOutputComboBox.FSelectItem:=0;
FEnableOutputComboBox.FUserPointer1:=Self;

FLoadScenePanel:=TSGPanel.Create();
SGScreen.CreateChild(FLoadScenePanel);
SGScreen.LastChild.SetMiddleBounds(440,80);
SGScreen.LastChild.Visible:=False;
SGScreen.LastChild.BoundsToNeedBounds();
SGScreen.LastChild.FUserPointer1:=Self;

FLoadScenePanel.CreateChild(TSGLabel.Create());
FLoadScenePanel.LastChild.Caption := '�������� ����������� �����/�������';
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
FLoadScenePanel.LastChild.Caption:='�����';
FLoadScenePanel.LastChild.FUserPointer1:=Self;
FBackButton.OnChange:=TSGComponentProcedure(@mmmFBackButtonProcedure);

FUpdateButton:=TSGButton.Create();
FLoadScenePanel.CreateChild(FUpdateButton);
FLoadScenePanel.LastChild.SetBounds(145,44,130,20);
FLoadScenePanel.LastChild.BoundsToNeedBounds();
FLoadScenePanel.LastChild.Visible:=False;
FLoadScenePanel.LastChild.Font := FTahomaFont;
FLoadScenePanel.LastChild.Caption:='��������';
FLoadScenePanel.LastChild.FUserPointer1:=Self;
FUpdateButton.OnChange:=TSGComponentProcedure(@mmmFUpdateButtonProcedure);

FLoadButton:=TSGButton.Create();
FLoadScenePanel.CreateChild(FLoadButton);
FLoadScenePanel.LastChild.SetBounds(145+135,44,130,20);
FLoadScenePanel.LastChild.BoundsToNeedBounds();
FLoadScenePanel.LastChild.Visible:=False;
FLoadScenePanel.LastChild.Font := FTahomaFont;
FLoadScenePanel.LastChild.Caption:='���������';
FLoadScenePanel.LastChild.FUserPointer1:=Self;
FLoadButton.OnChange:=TSGComponentProcedure(@mmmFLoadButtonProcedure);
end;

procedure TSGGasDiffusion.Draw();
begin
if FMesh <> nil then
	begin
	FCamera.CallAction();
	FMesh.Draw();
	if FDiffusionRuned then
		begin
		//if random(5) = 0 then begin
			FCube.UpDateCube();
			FMesh.Destroy();
			FMesh:=FCube.CalculateMesh();
			
			//if FEnableSaving then 
				//FESaveStageToStream();
			//end;
		end;
	end;
end;

end.
