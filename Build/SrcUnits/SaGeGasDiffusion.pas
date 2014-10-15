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
const
	PredStr = 
		{$IFDEF ANDROID}
			'sdcard/.SaGe/'
		{$ELSE}
			''
			{$ENDIF};
	Catalog = 'Gas Diffusion Saves';
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
		FCube       : TSGGGDC;
		FEdge       : TSGLongWord;
		FBoundsOpen : TSGBoolean;
		FGazes      : packed array of TSGGazType;
		FSourses    : packed array of TSGSourseType;
		end;
type
	TSGGasDiffusion=class(TSGDrawClass)
			public
		constructor Create(const VContext:TSGContext);override;
		procedure Draw();override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			private
		FCamera         : TSGCamera;
		FMesh           : TSGCustomModel;
		FCube           : TSGGasDiffusionCube;
		FFileName       : TSGString;
		FFileStream     : TFileStream;
		FDiffusionRuned : TSGBoolean;
		FEnableSaving   : TSGBoolean;
		
		//Панели,кнопки и т п
		FTahomaFont        : TSGFont;
		FLoadScenePanel,
			FNewScenePanel :TSGPanel;
		
		//New Pabel
		FEdgeEdit               : TSGEdit;
		FNumberLabel            : TSGLabel;
		FStartSceneButton,
			FEnableLoadButton   : TSGButton;
		FEnableOutputComboBox,
			FBoundsTypeComboBox : TSGComboBox;
		
		//Load Panel
		FLoadComboBox      : TSGComboBox;
		FBackButton, 
			FUpdateButton, 
			FLoadButton    : TSGButton;
		
		//Экран моделирования
		FAddNewSourseButton,
			FAddNewGazButton,
			FStartEmulatingButton,
			FPauseEmulatingButton,
			FDeleteSechenieButton,
			FAddSechenieButton,
			FBackToMenuButton,
			FStopEmulatingButton    : TSGButton;
		
			(*Повтор*)
		
		//FFileStream  : TFileStream;
		//FFileName    : TSGString;
		FArCadrs       : packed array of TSGQuadWord;
		FNowCadr       : TSGLongWord;
		FMoviePlayed   : TSGBoolean;
		
		//Экран повтора
		FMoviePauseButton,
			FMovieBackToMenuButton,
			FMoviePlayButton : TSGButton;
		
			private
		procedure ClearDisplayButtons();
		procedure SaveStageToStream();
		procedure UpDateSavesComboBox();
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
FBoundsOpen:=False;
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
procedure UpDateIfOpenBounds();
var
	i,ii:TSGLongWord;
begin
i := 0;
while i<FEdge do
	begin
	ii := 0;
	while ii<FEdge do
		begin
		Cube(i,ii,0)^:=0;
		Cube(i,ii,FEdge-1)^:=0;
		Cube(0,i,ii)^:=0;
		Cube(FEdge-1,i,ii)^:=0;
		Cube(i,0,ii)^:=0;
		Cube(i,FEdge-1,ii)^:=0;
		Inc(ii);
		end;
	Inc(i);
	end;
end;
begin
UpDateGaz();
UpDateSourses();
if FBoundsOpen then
	UpDateIfOpenBounds();
end;
function TSGGasDiffusionCube.CalculateMesh():TSGCustomModel;
var
	n : TSGQuadWord = 0;
	i : TSGLongWord;
	Smeshenie : TSGSingle;
begin
Smeshenie:=1/FEdge;

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
Result.LastObject().Vertexes   := 24;

Result.LastObject().ArVertex3f[0]^.Import(-1,-1,-1);
Result.LastObject().ArVertex3f[1]^.Import(1,-1,-1);

Result.LastObject().ArVertex3f[2]^.Import(-1,-1,1);
Result.LastObject().ArVertex3f[3]^.Import(1,-1,1);

Result.LastObject().ArVertex3f[4]^.Import(-1,1,1);
Result.LastObject().ArVertex3f[5]^.Import(1,1,1);

Result.LastObject().ArVertex3f[6]^.Import(-1,1,-1);
Result.LastObject().ArVertex3f[7]^.Import(1,1,-1);

Result.LastObject().ArVertex3f[8]^.Import(-1,-1,-1);
Result.LastObject().ArVertex3f[9]^.Import(-1,1,-1);

Result.LastObject().ArVertex3f[10]^.Import(-1,-1,-1);
Result.LastObject().ArVertex3f[11]^.Import(-1,-1,1);

Result.LastObject().ArVertex3f[12]^.Import(-1,-1,1);
Result.LastObject().ArVertex3f[13]^.Import(-1,1,1);

Result.LastObject().ArVertex3f[14]^.Import(-1,1,1);
Result.LastObject().ArVertex3f[15]^.Import(-1,1,-1);


Result.LastObject().ArVertex3f[16]^.Import(1,-1,-1);
Result.LastObject().ArVertex3f[17]^.Import(1,-1,1);

Result.LastObject().ArVertex3f[18]^.Import(1,-1,1);
Result.LastObject().ArVertex3f[19]^.Import(1,1,1);

Result.LastObject().ArVertex3f[20]^.Import(1,1,1);
Result.LastObject().ArVertex3f[21]^.Import(1,1,-1);

Result.LastObject().ArVertex3f[22]^.Import(1,1,-1);
Result.LastObject().ArVertex3f[23]^.Import(1,-1,-1);

for i:=0 to 23 do
	Result.LastObject().SetColor(i,$0A/256,$C7/256,$F5/256);

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
			Smeshenie+2*(i mod FEdge)/FEdge-1,
			Smeshenie+2*((i div FEdge) mod FEdge)/FEdge-1,
			Smeshenie+2*((i div FEdge) div FEdge)/FEdge-1);
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
if FMovieBackToMenuButton <> nil then
	begin
	FMovieBackToMenuButton.Destroy();
	FMovieBackToMenuButton:=nil;
	end;
if FMoviePlayButton <> nil then
	begin
	FMoviePlayButton.Destroy();
	FMoviePlayButton:=nil;
	end;
if FMoviePauseButton <> nil then
	begin
	FMoviePauseButton.Destroy();
	FMoviePauseButton:=nil;
	end;
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
if FMesh<>nil then
	FMesh.Destroy();
if FArCadrs <> nil then
	SetLength(FArCadrs,0);
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
Result := 'Диффузия в газах';
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
	if FFileStream<>nil then
		begin
		FFileStream.Destroy();
		FFileStream:=nil;
		end;
	FCube.ClearGaz();
	FMesh:=FCube.CalculateMesh();
end; end;

procedure mmmFRunDiffusionButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.FUserPointer1) do begin
	FDiffusionRuned := True;
	Button.Active := False;
	FStopEmulatingButton.Active := True;
	FPauseEmulatingButton.Active := True;
	if FEnableSaving and (FFileStream=nil) then
		begin
		FFileName   := SGGetFreeFileName(PredStr+Catalog+Slash+'Save.GDS','number');
		FFileStream := TFileStream.Create(FFileName,fmCreate);
		SaveStageToStream();
		end;
end; end;

procedure mmmFStartSceneButtonProcedure(Button:TSGButton);
const
	W = 200;
begin
with TSGGasDiffusion(Button.FUserPointer1) do
	begin
	FEnableSaving := not Boolean(FEnableOutputComboBox.SelectItem);
	
	FNewScenePanel.Visible := False;
	if FCube<>nil then
		begin
		FCube.Destroy();
		FCube:=nil;
		end;
	FCube:=TSGGasDiffusionCube.Create(Context);
	FCube.FBoundsOpen := Boolean(FBoundsTypeComboBox.SelectItem);
	FCube.InitCube(SGVal(FEdgeEdit.Caption));
	if FMesh<>nil then
		begin
		FMesh.Destroy();
		FMesh:=nil;
		end;
	FMesh:=FCube.CalculateMesh();
	
	if FEnableSaving then
		begin
		SGMakeDirectory(PredStr+Catalog);
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
		SGScreen.LastChild.Caption :='В главное меню';
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
		SGScreen.LastChild.Caption:='Добавить новый тип газа';
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
		SGScreen.LastChild.Caption:='Добавитьт источник газа';
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
		SGScreen.LastChild.Caption:='Эмурировать';
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
		SGScreen.LastChild.Caption:='Приостановить эмуляцию';
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
		SGScreen.LastChild.Caption:='Ocтановить эмуляцию';
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
		SGScreen.LastChild.Caption:='Рассмотреть сечение';
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
		SGScreen.LastChild.Caption:='Не рассмотривать сечение';
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
begin with TSGGasDiffusion(Button.FUserPointer1) do begin
	UpDateSavesComboBox();
end;end;

procedure mmmFMovieBackToMenuButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.FUserPointer1) do begin
	FMoviePlayed := False;
	FMovieBackToMenuButton.Visible:=False;
	FMoviePauseButton.Visible:=False;
	FMoviePlayButton.Visible:=False;
	FLoadScenePanel.Visible := True;
	if FMesh<>nil then
		begin
		FMesh.Destroy();
		FMesh:=nil;
		end;
	if FArCadrs<>nil then
		begin
		SetLength(FArCadrs,0);
		FArCadrs:=nil;
		end;
	if FFileStream<>nil then
		begin
		FFileStream.Destroy();
		FFileStream:=nil;
		end;
end;end;

procedure mmmFMoviePauseButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.FUserPointer1) do begin
	FMoviePlayed := False;
	FMoviePauseButton.Active := False;
	FMoviePlayButton.Active := True;
end;end;

procedure mmmFMoviePlayButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.FUserPointer1) do begin
	FMoviePlayed := True;
	FMoviePauseButton.Active := True;
	FMoviePlayButton.Active := False;
end;end;

procedure mmmFLoadButtonProcedure(Button:TSGButton);
procedure ReadCadrs();
begin with TSGGasDiffusion(Button.FUserPointer1) do begin
FFileStream.Position := 0;
SetLength(FArCadrs,0);
while FFileStream.Position<>FFileStream.Size do
	begin
	SetLength(FArCadrs,Length(FArCadrs)+1);
	FArCadrs[High(FArCadrs)]:=FFileStream.Position;
	
	FMesh:=TSGCustomModel.Create();
	FMesh.Context := Context;
	FMesh.LoadFromSG3DM(FFileStream);
	FMesh.Destroy();
	FMesh:=nil;
	end;
FFileStream.Position := 0;
end; end;
const
	W = 200;
begin with TSGGasDiffusion(Button.FUserPointer1) do begin
	FLoadScenePanel.Visible := False;
	FFileName := FLoadComboBox.Items(FLoadComboBox.SelectItem);
	FFileName := PredStr+Catalog+Slash+FFileName;
	FFileStream := TFileStream.Create(FFileName,fmOpenRead);
	FEnableSaving := False;
	ReadCadrs();
	FNowCadr:=0;
	FMoviePlayed:=True;
	
	FMesh:=TSGCustomModel.Create();
	FMesh.Context := Context;
	FFileStream.Position:=FArCadrs[FNowCadr];
	FMesh.LoadFromSG3DM(FFileStream);
	
	if FMovieBackToMenuButton = nil then
		begin
		FMovieBackToMenuButton:=TSGButton.Create();
		SGScreen.CreateChild(FMovieBackToMenuButton);
		SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+25*0,W,20);
		SGScreen.LastChild.BoundsToNeedBounds();
		SGScreen.LastChild.Visible := True;
		SGScreen.LastChild.Active  := True;
		SGScreen.LastChild.Font    := FTahomaFont;
		SGScreen.LastChild.Caption :='В меню загрузок';
		SGScreen.LastChild.FUserPointer1:=Button.FUserPointer1;
		FMovieBackToMenuButton.OnChange:=TSGComponentProcedure(@mmmFMovieBackToMenuButtonProcedure);
		end
	else
		begin
		FMovieBackToMenuButton.Visible := True;
		FMovieBackToMenuButton.Active  := True;
		end;
	
	if FMoviePlayButton = nil then
		begin
		FMoviePlayButton:=TSGButton.Create();
		SGScreen.CreateChild(FMoviePlayButton);
		SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+25*1,W,20);
		SGScreen.LastChild.BoundsToNeedBounds();
		SGScreen.LastChild.Visible := True;
		SGScreen.LastChild.Active  := False;
		SGScreen.LastChild.Font    := FTahomaFont;
		SGScreen.LastChild.Caption :='Воспроизведение';
		SGScreen.LastChild.FUserPointer1:=Button.FUserPointer1;
		FMoviePlayButton.OnChange:=TSGComponentProcedure(@mmmFMoviePlayButtonProcedure);
		end
	else
		begin
		FMoviePlayButton.Visible := True;
		FMoviePlayButton.Active  := False;
		end;
	if FMoviePauseButton = nil then
		begin
		FMoviePauseButton:=TSGButton.Create();
		SGScreen.CreateChild(FMoviePauseButton);
		SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+25*2,W,20);
		SGScreen.LastChild.BoundsToNeedBounds();
		SGScreen.LastChild.Visible := True;
		SGScreen.LastChild.Active  := True;
		SGScreen.LastChild.Font    := FTahomaFont;
		SGScreen.LastChild.Caption :='Пауза';
		SGScreen.LastChild.FUserPointer1:=Button.FUserPointer1;
		FMoviePauseButton.OnChange:=TSGComponentProcedure(@mmmFMoviePauseButtonProcedure);
		end
	else
		begin
		FMoviePauseButton.Visible := True;
		FMoviePauseButton.Active  := True;
		end;
	
end;end;

procedure mmmFEnableLoadButtonProcedure(Button:TSGButton);
begin
with TSGGasDiffusion(Button.FUserPointer1) do
	begin
	FLoadScenePanel.Visible := True;
	FNewScenePanel .Visible := False;
	UpDateSavesComboBox();
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
	FStartSceneButton.Active := Result;
	end;
end;

procedure TSGGasDiffusion.UpDateSavesComboBox();
var
	ar : TArString = nil;
	i : TSGLongWord;
	ExC : Boolean = False;
begin
FLoadComboBox.ClearItems();
ar := SGGetFileNames(PredStr+Catalog+'/','*.GDS');
if ar <> nil then
	begin
	for i:=0 to High(ar) do
		if (ar[i]<>'.') and (ar[i]<>'..') then
			begin
			FLoadComboBox.CreateItem(ar[i]);
			ExC := True;
			end;
	SetLength(ar,0);
	end;
if ExC then
	begin
	FLoadComboBox.SelectItem := 0;
	FLoadComboBox.Active := True;
	FLoadButton.Active   := True;
	end
else
	begin
	FLoadComboBox.Active := False;
	FLoadButton.Active   := False;
	FLoadComboBox.SelectItem := -1;
	end;
end;

constructor TSGGasDiffusion.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FMesh                 := nil;
FCube                 := nil;
FAddNewSourseButton   := nil;
FStartEmulatingButton := nil;
FAddNewGazButton      := nil;
FStopEmulatingButton  := nil;
FPauseEmulatingButton := nil;
FDeleteSechenieButton := nil;
FAddSechenieButton    := nil;
FBackToMenuButton     := nil;
FFileName             := '';
FFileStream           := nil;
FDiffusionRuned       := False;
FEnableSaving         := True;
FMoviePlayed          := False;
FArCadrs              := nil;
FNowCadr              := 0;
FMovieBackToMenuButton:= nil;
FMoviePlayButton      := nil;
FMoviePauseButton     := nil;

FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
FCamera.FZum := Context.Height/Context.Width;

FTahomaFont:=TSGFont.Create(SGFontDirectory+Slash+'Tahoma.sgf');
FTahomaFont.SetContext(Context);
FTahomaFont.Loading();
FTahomaFont.ToTexture();

FNewScenePanel:=TSGPanel.Create();
SGScreen.CreateChild(FNewScenePanel);
SGScreen.LastChild.SetMiddleBounds(400,110+26);
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

FStartSceneButton:=TSGButton.Create();
FNewScenePanel.CreateChild(FStartSceneButton);
FNewScenePanel.LastChild.SetBounds(10,44,80,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;
FNewScenePanel.LastChild.Caption:='Старт';
FNewScenePanel.LastChild.FUserPointer1:=Self;
FStartSceneButton.OnChange:=TSGComponentProcedure(@mmmFStartSceneButtonProcedure);

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
FNewScenePanel.LastChild.SetBounds(100,44,278,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;
FNewScenePanel.LastChild.Caption:='Загрузка сохраненной сцены/повтора';
FNewScenePanel.LastChild.FUserPointer1:=Self;
FEnableLoadButton.OnChange:=TSGComponentProcedure(@mmmFEnableLoadButtonProcedure);

FEnableOutputComboBox := TSGComboBox.Create();
FNewScenePanel.CreateChild(FEnableOutputComboBox);
FEnableOutputComboBox.SetBounds(10,44+26,380-10,19);
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Font := FTahomaFont;
FEnableOutputComboBox.CreateItem('Включить непрерывное сохранение эмуляции');
FEnableOutputComboBox.CreateItem('Не включать непрерывное сохранение эмуляции');
//FEnableOutputComboBox.FProcedure:=TSGComboBoxProcedure(@FEnableOutputComboBoxProcedure);
FEnableOutputComboBox.SelectItem:={$IFDEF MOBILE}1{$ELSE}0{$ENDIF};
FEnableOutputComboBox.FUserPointer1:=Self;

FBoundsTypeComboBox := TSGComboBox.Create();
FNewScenePanel.CreateChild(FBoundsTypeComboBox);
FBoundsTypeComboBox.SetBounds(10,44+26+25,380-10,19);
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Font := FTahomaFont;
FBoundsTypeComboBox.CreateItem('Замкнутое пространство');
FBoundsTypeComboBox.CreateItem(' Открытое пространство');
//FBoundsTypeComboBox.FProcedure:=TSGComboBoxProcedure(@FFBoundsTypeComboBoxProcedure);
FBoundsTypeComboBox.SelectItem:=0;
FBoundsTypeComboBox.FUserPointer1:=Self;

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
//FLoadComboBox.FProcedure:=TSGComboBoxProcedure(@FLoadComboBoxProcedure);
FLoadComboBox.SelectItem:=-1;
FLoadComboBox.FUserPointer1:=Self;


FBackButton:=TSGButton.Create();
FLoadScenePanel.CreateChild(FBackButton);
FLoadScenePanel.LastChild.SetBounds(10,44,130,20);
FLoadScenePanel.LastChild.BoundsToNeedBounds();
FLoadScenePanel.LastChild.Visible:=False;
FLoadScenePanel.LastChild.Font := FTahomaFont;
FLoadScenePanel.LastChild.Caption:='Назад';
FLoadScenePanel.LastChild.FUserPointer1:=Self;
FBackButton.OnChange:=TSGComponentProcedure(@mmmFBackButtonProcedure);

FUpdateButton:=TSGButton.Create();
FLoadScenePanel.CreateChild(FUpdateButton);
FLoadScenePanel.LastChild.SetBounds(145,44,130,20);
FLoadScenePanel.LastChild.BoundsToNeedBounds();
FLoadScenePanel.LastChild.Visible:=False;
FLoadScenePanel.LastChild.Font := FTahomaFont;
FLoadScenePanel.LastChild.Caption:='Обновить';
FLoadScenePanel.LastChild.FUserPointer1:=Self;
FUpdateButton.OnChange:=TSGComponentProcedure(@mmmFUpdateButtonProcedure);

FLoadButton:=TSGButton.Create();
FLoadScenePanel.CreateChild(FLoadButton);
FLoadScenePanel.LastChild.SetBounds(145+135,44,130,20);
FLoadScenePanel.LastChild.BoundsToNeedBounds();
FLoadScenePanel.LastChild.Visible:=False;
FLoadScenePanel.LastChild.Font := FTahomaFont;
FLoadScenePanel.LastChild.Caption:='Загрузить';
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
		FCube.UpDateCube();
		FMesh.Destroy();
		FMesh:=FCube.CalculateMesh();
		
		if FEnableSaving then 
			SaveStageToStream();
		end;
	if FMoviePlayed then
		begin
		if FMesh<>nil then
			FMesh.Destroy();
		FMesh:=TSGCustomModel.Create();
		FMesh.Context := Context;
		FNowCadr+=1;
		if FNowCadr > High(FArCadrs) then
			FNowCadr:=0;
		FFileStream.Position:=FArCadrs[FNowCadr];
		FMesh.LoadFromSG3DM(FFileStream);
		end;
	end;
end;

end.
