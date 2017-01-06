{$i SaGe.inc}
unit SGUser;

interface

uses 
	{$I SaGeUnits.inc};

type
	TSGIdentifierButton=class(TSGButton)
		FID:Int64;
		end;

procedure UserOnBeginProgram;
procedure UserOnActivate;
procedure UserOnPaint;
procedure BuildingPanelUpDate( //Это полностью все...
	const Panel:TSGPanel; 
	const Documentation:TSGXNovaUnitsDocumentation;
	const World:TSGXNovaWorld;
	const User:String;
	const PlanetNumber:LongInt);
procedure ChangeBuildingComboBox(a,b:LongInt);
procedure OnUpdatePlanetPanel;
procedure BuildingWaitingPanelUpDate( //Это очередь построек..
	const Panel:TSGPanel; 
	const Documentation:TSGXNovaUnitsDocumentation;
	const BuildingWaiting:TSGXNovaBuildingsWaiting);
procedure UpDateWorld(const FileName:String);overload;
procedure UpDateWorld(const World:TSGXNovaWorld);overload;
procedure UpDateBuildPanel(//Это инфо о здании..
	const Panel:TSGPanel; 
	const Documentation:TSGXNovaUnitsDocumentation;
	const ID:Int;
	const Quantity:Int;
	const BuildingWaiting:TSGXNovaBuildingsWaiting);
procedure UpDateWorldWayComboBox;
procedure ResourcesPanelUpDate(
	const Panel:TSGPanel; 
	const Documentation:TSGXNovaUnitsDocumentation;
	const World:TSGXNovaWorld;
	const User:String;
	const PlanetNumber:LongInt);

implementation

var
	MenuPanel:TSGPanel = nil;
	
	LoginPanel:TSGPanel = nil;
		WorldWayEdit:TSGEdit = nil;
		UserEdit:TSGEdit = nil;
		PasswordEdit:TSGEdit = nil;
		WorldWayComboBox:TSGComboBox = nil;
		UserComboBox:TSGComboBox = nil;
		NewWorldButton:TSGButton = nil;
		NewPlayerButton:TSGButton = nil;
		LoginButton:TSGButton = nil;
	
	BildingsPanel:TSGPanel = nil;
	
	PlanetPanel:TSGPanel = nil;
	
	ResourcePanel:TSGPanel = nil;
var
	UnitsDocumentation:TSGXNovaUnitsDocumentation = nil;
	PlanetsPictures:packed array of TSGGLImage = nil;
	PlanetNumber:longint = 1;
	TahomaFont:TSGGLFont = nil;
	TimesNewRomanFont:TSGGLFont = nil;
var
	OnChangeDeleteBuildingFromWaitingButton:TSGIdentifierButton = nil;

{$NOTE Resources}

procedure ChangeResourceMenu(a,b:LongInt);
begin

end;

procedure ResourcesPanelUpDate(
	const Panel:TSGPanel; 
	const Documentation:TSGXNovaUnitsDocumentation;
	const World:TSGXNovaWorld;
	const User:String;
	const PlanetNumber:LongInt);
var
	Planet:TSGXNovaUserPlanet = nil;
	i:LongInt;
begin
Panel.KillChildren;

Panel.CreateChild(TSGButtonMenu.Create);
Panel.LastChild.SetBounds(3,3,Panel.Width div 4,Panel.Height-10);
Panel.LastChild.AsButtonMenu.FProcedure:=TSGButtonMenuProcedure(@ChangeResourceMenu);
Panel.LastChild.AsButtonMenu.ButtonTop:=20;
Panel.LastChild.AsButtonMenu.ActiveButtonTop:=40;
Panel.LastChild.AsButtonMenu.FMiddle:=True;
Panel.LastChild.AsButtonMenu.FSelectNotClick:=True;

Planet:=World.GetPlanet(SGPCharToString(UserEdit.Caption),PlanetNumber).GetUserPlanet(SGPCharToString(UserEdit.Caption));

Panel.LastChild.AsButtonMenu.AddButton('Общее');
Panel.LastChild.AsButtonMenu.SetButton(0);

for i:=0 to High(Planet.FUnits.FUnits) do
	begin
	if Documentation.FDocumentation[Planet.FUnits.FUnits[i].FIdentifity].FType = XNovaResource then
		begin
		Panel.LastChild.AsButtonMenu.AddButton(
			Documentation.FDocumentation[Planet.FUnits.FUnits[i].FIdentifity].FName+
			' ('+
			SGStr(Planet.FUnits.FUnits[i].FQuantity)+
			')');
		TSGIdentifierButton(Pointer(Panel.LastChild.LastChild)).FID:=i;
		end;
	end;

Panel.LastChild.Visible:=True;
Panel.LastChild.BoundsToNeedBounds;


Panel.CreateChild(TSGPanel.Create);
Panel.LastChild.SetBounds(Panel.Width div 4+5,3,(Panel.Width div 4)*3-20,Panel.Height-10);
Panel.LastChild.Visible:=True;
Panel.LastChild.BoundsToNeedBounds;

Panel.LastChild.CreateChild(TSGGrid.Create);
Panel.LastChild.LastChild.SetBounds(5,5,Panel.LastChild.Width-10,Panel.LastChild.Height-10);
Panel.LastChild.LastChild.Visible:=True;
Panel.LastChild.LastChild.BoundsToNeedBounds;

Panel.LastChild.LastChild.AsGrid.CreateItem(0,0,TSGButton.Create);
Panel.LastChild.LastChild.AsGrid.Items(0,0).AsButton.SetBounds(0,0,150,30);
Panel.LastChild.LastChild.AsGrid.Items(0,0).AsButton.Visible:=true;
end;

{$NOTE Buildings}

procedure DeleteWaitingBuild;
var
	World:TSGXNovaWorld = nil;
	Stream:TMemoryStream = nil;
	Waiting:TSGXNovaBuildingsWaiting = nil;
	i:LongInt;
begin
World:=TSGXNovaWorld.Create;
Stream:=TMemoryStream.Create;
Stream.LoadFromFile('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
World.Load(Stream);
Stream.Destroy;

UpDateWorld(World);

Waiting:=World.GetPlanet(SGPCharToString(UserEdit.Caption),PlanetNumber).GetUserPlanet(SGPCharToString(UserEdit.Caption)).FBildingsWaiting;
if OnChangeDeleteBuildingFromWaitingButton.FID<>0 then
	begin
	for i:=OnChangeDeleteBuildingFromWaitingButton.FID+1 to High(Waiting.FWaiting) do
		begin
		Waiting.FWaiting[i-1]:=Waiting.FWaiting[i];
		end;
	SetLength(Waiting.FWaiting,Length(Waiting.FWaiting)-1);
	end
else
	begin
	for i:=OnChangeDeleteBuildingFromWaitingButton.FID+1 to High(Waiting.FWaiting) do
		begin
		Waiting.FWaiting[i-1]:=Waiting.FWaiting[i];
		end;
	SetLength(Waiting.FWaiting,Length(Waiting.FWaiting)-1);
	if Length(Waiting.FWaiting)>=1 then
		begin
		Waiting.FSeconds:=
			Waiting.GetBuildTime(
				Waiting.FWaiting[0],
				Waiting.GetNextBuildingLevel(Waiting.FWaiting[0]),
				UnitsDocumentation);
		end;
	end;

BuildingWaitingPanelUpDate(OnChangeDeleteBuildingFromWaitingButton.Parent.Parent.AsPanel,UnitsDocumentation,Waiting);

Stream:=TMemoryStream.Create;
World.Save(Stream);
Stream.SaveToFile('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
Stream.Destroy;
World.Destroy;

OnChangeDeleteBuildingFromWaitingButton:=nil;
end;

procedure UserOnPaint; {DONT RENAME THIS PROCEDURE!!!!}
begin
if OnChangeDeleteBuildingFromWaitingButton<>nil then
	DeleteWaitingBuild;
end;

procedure UpDateWorld(const World:TSGXNovaWorld);overload;
var
	DataTime:TSGDateTime;
begin
DataTime.Get;
World.UpDate((DataTime-World.FDateTime).GetPastSeconds,UnitsDocumentation);
World.FDateTime:=DataTime;
end;

procedure UpDateWorld(const FileName:String);overload;
var
	World:TSGXNovaWorld = nil;
	Stream:TMemoryStream = nil;
begin
World:=TSGXNovaWorld.Create;
Stream:=TMemoryStream.Create;
Stream.LoadFromFile('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
World.Load(Stream);
Stream.Destroy;
UpDateWorld(World);
Stream:=TMemoryStream.Create;
World.Save(Stream);
if FileExists(FileName) then
	SysUtils.DeleteFile(FileName);
Stream.SaveToFile(FileName);
Stream.Destroy;
World.Destroy;
end;

procedure CreateOneBuilding(
	const Panel:TSGPanel; 
	const Documentation:TSGXNovaUnitsDocumentation;
	const ID:Int;
	const Quantity:Int);
var
	Caption:TSGCaption;
begin
Caption:=SGStringAsPChar(Documentation.FDocumentation[ID].FName);
Panel.LastChild.AsComboBox.CreateItem(
	Caption,
	Documentation.FDocumentation[ID].FPicture,
	ID);
end;


var
	OnUpdateBuildingWaitingPanelDataTime:TSGDateTime;
	OnUpdateBuildingWaitingPanelNowTime,
	OnUpdateBuildingWaitingPanelAllTime:Int;
	OnUpdateBuildingWaitingPanelTimeArray:packed array of Int64 = nil;
procedure OnUpdateBuildingWaitingPanel(const Panel:TSGPanel);
var
	DataTime:TSGDateTime;
	i,ii:LongInt;
var
	World:TSGXNovaWorld = nil;
	Stream:TMemoryStream = nil;
begin
if Panel.Visible<>True then
	begin
	Panel.OnChange:=nil;
	Exit;
	end;
DataTime.Get;
i:=(DataTime-OnUpdateBuildingWaitingPanelDataTime).GetPastSeconds;
if i>0 then
	begin
	if not ((Length(Panel.FChildren)=1) and (Panel.FChildren[0] is TSGLabel)) then
		begin
		
		OnUpdateBuildingWaitingPanelNowTime+=i;
		if OnUpdateBuildingWaitingPanelAllTime<=OnUpdateBuildingWaitingPanelNowTime then
			begin
			ii:=BildingsPanel.LastChild.AsComboBox.FSelectItem;
			
			World:=TSGXNovaWorld.Create;
			Stream:=TMemoryStream.Create;
			Stream.LoadFromFile('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
			World.Load(Stream);
			Stream.Destroy;
			
			UpDateWorld(World);
			
			BuildingPanelUpDate(
				Panel.Parent.AsPanel,
				UnitsDocumentation,
				World,
				SGPCharToString(UserEdit.Caption),
				PlanetNumber);
			
			Stream:=TMemoryStream.Create;
			World.Save(Stream);
			Stream.SaveToFile('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
			Stream.Destroy;
			World.Destroy;
			
			ChangeBuildingComboBox(0,ii);
			BildingsPanel.LastChild.AsComboBox.FSelectItem:=ii;
			BildingsPanel.Parent.BoundsToNeedBounds;
			for i:=0 to High(BildingsPanel.Parent.FChildren) do
				BildingsPanel.Parent.FChildren[i].BoundsToNeedBounds;
			
			OnUpdatePlanetPanel;
			
			Exit;
			end;
		Panel.FChildren[0].FChildren[1].AsProgressBar.FNeedProgress:=
			(OnUpdateBuildingWaitingPanelNowTime)/(OnUpdateBuildingWaitingPanelAllTime);
		Panel.FChildren[0].FChildren[2].Caption:=
			SGStringToPChar(
			'Прошло :'+SGSecondsToStringTime(OnUpdateBuildingWaitingPanelNowTime)+
			'. Осталось : '+SGSecondsToStringTime(OnUpdateBuildingWaitingPanelAllTime-OnUpdateBuildingWaitingPanelNowTime)+
			'. Всего : '+SGSecondsToStringTime(OnUpdateBuildingWaitingPanelAllTime)+'.');
		
		ii:=OnUpdateBuildingWaitingPanelAllTime-OnUpdateBuildingWaitingPanelNowTime;
		for i:=0 to High(OnUpdateBuildingWaitingPanelTimeArray) do
			begin
			ii+=OnUpdateBuildingWaitingPanelTimeArray[i];
			Panel.FChildren[i+1].FChildren[1].Caption:=
				SGStringToPChar(
					'Будет строиться: '+
					SGSecondsToStringTime(OnUpdateBuildingWaitingPanelTimeArray[i])+
					'. Построится через: '+
					SGSecondsToStringTime(ii)+'.');
			end;
		end;
	OnUpdateBuildingWaitingPanelDataTime.Get;
	end;
end;

procedure OnChangeDeleteBuildingFromWaiting(Button:TSGIdentifierButton);
begin
OnChangeDeleteBuildingFromWaitingButton:=Button;
end;

procedure BuildingWaitingPanelUpDate(
	const Panel:TSGPanel; 
	const Documentation:TSGXNovaUnitsDocumentation;
	const BuildingWaiting:TSGXNovaBuildingsWaiting);
var
	i,ii:LongInt;
begin
while Length(Panel.FChildren)>=1 do
	Panel.FChildren[0].Destroy;

if Length(BuildingWaiting.FWaiting)=0 then
	begin
	Panel.CreateChild(TSGLabel.Create);
	Panel.LastChild.SetMiddleBounds(Panel.Width,30);
	Panel.LastChild.Caption:='В очереди построек нет ни одной постройки.';
	Panel.LastChild.Visible:=True;
	Panel.LastChild.BoundsToNeedBounds;
	end
else
	begin
	Panel.CreateChild(TSGPanel.Create);
	Panel.LastChild.SetBounds(10,10,Panel.Width-20,25*3+5);
	Panel.LastChild.Visible:=True;
	Panel.LastChild.BoundsToNeedBounds;
	
	Panel.LastChild.CreateChild(TSGLabel.Create);
	Panel.LastChild.LastChild.SetBounds(60,5,Panel.LastChild.Width-75,20);
	Panel.LastChild.LastChild.Caption:=
		SGPCharTotal(
			'1. Идет строительство здания : "',
			SGStringToPChar(Documentation.FDocumentation[BuildingWaiting.FWaiting[0]].FName+'" ( Уровень '+
				SGStr(BuildingWaiting.FUnits.FindUnit(BuildingWaiting.FWaiting[0])+1)+' ).'));
	Panel.LastChild.LastChild.Visible:=True;
	Panel.LastChild.LastChild.BoundsToNeedBounds;
	
	
	Panel.LastChild.CreateChild(TSGProgressBar.Create);
	Panel.LastChild.LastChild.Caption:='Процесс постройки :';
	Panel.LastChild.LastChild.SetBounds(60,30,Panel.LastChild.Width-75,20);
	Panel.LastChild.LastChild.Visible:=True;
	Panel.LastChild.LastChild.AsProgressBar.FViewCaption:=True;
	Panel.LastChild.LastChild.AsProgressBar.FViewProgress:=True;
	
	OnUpdateBuildingWaitingPanelAllTime:=BuildingWaiting.GetBuildTime(
		BuildingWaiting.FWaiting[0],
		BuildingWaiting.GetNextBuildingLevel(BuildingWaiting.FWaiting[0]),
		Documentation);
	OnUpdateBuildingWaitingPanelNowTime:=OnUpdateBuildingWaitingPanelAllTime-BuildingWaiting.FSeconds;
	
	
	if OnUpdateBuildingWaitingPanelAllTime=0 then
		begin
		OnUpdateBuildingWaitingPanelAllTime:=1;
		OnUpdateBuildingWaitingPanelNowTime:=1;
		end;
	Panel.LastChild.LastChild.AsProgressBar.Progress:=
		(OnUpdateBuildingWaitingPanelNowTime)/
		OnUpdateBuildingWaitingPanelAllTime;

	Panel.LastChild.LastChild.BoundsToNeedBounds;
	Panel.LastChild.LastChild.AsProgressBar.FColor1:=SGGetColor4fFromLongWord($800000).WithAlpha(2);
	Panel.LastChild.LastChild.AsProgressBar.FColor2:=SGGetColor4fFromLongWord($FF0000).WithAlpha(2);
	
	Panel.LastChild.CreateChild(TSGLabel.Create);
	Panel.LastChild.LastChild.SetBounds(60,55,Panel.LastChild.Width-75,20);
	Panel.LastChild.LastChild.Caption:='';
	Panel.LastChild.LastChild.Visible:=True;
	Panel.LastChild.LastChild.BoundsToNeedBounds;
	
	Panel.LastChild.CreateChild(TSGPicture.Create);
	Panel.LastChild.LastChild.SetBounds(2,2,50,50);
	Panel.LastChild.LastChild.Visible:=True;
	Panel.LastChild.LastChild.BoundsToNeedBounds;
	Panel.LastChild.LastChild.AsPicture.FImage:=
		Documentation.FDocumentation[BuildingWaiting.FWaiting[0]].FPicture;
	
	Panel.LastChild.CreateChild(TSGIdentifierButton.Create);
	Panel.LastChild.LastChild.SetBounds(Panel.LastChild.Width-20,0,20,20);
	Panel.LastChild.LastChild.Caption:='X';
	Panel.LastChild.LastChild.Visible:=True;
	Panel.LastChild.LastChild.BoundsToNeedBounds;
	TSGIdentifierButton(Pointer(Panel.LastChild.LastChild)).FID:=0;
	Pointer(Panel.LastChild.LastChild.OnChange):=@OnChangeDeleteBuildingFromWaiting;
	
	SetLength(OnUpdateBuildingWaitingPanelTimeArray,0);
	
	i:=25*3+5+15;
	ii:=1;
	while (i+55<Panel.Height) and (ii<=High(BuildingWaiting.FWaiting)) do
		begin
		Panel.CreateChild(TSGPanel.Create);
		Panel.LastChild.SetBounds(10,i,Panel.Width-20,55);
		Panel.LastChild.Visible:=True;
		Panel.LastChild.BoundsToNeedBounds;
		
		Panel.LastChild.CreateChild(TSGLabel.Create);
		Panel.LastChild.LastChild.SetBounds(60,5,Panel.LastChild.Width-75,20);
		Panel.LastChild.LastChild.Caption:=
			SGPCharTotal(
				SGPCharTotal(SGStringToPChar(SGStr(ii+1)),
				'. Ожидание постройки здания : "'),
				SGStringToPChar(Documentation.FDocumentation[BuildingWaiting.FWaiting[ii]].FName+'" ( Уровень '+
					SGStr(BuildingWaiting.GetLvlWithWaiting(ii))+' ).'));
		Panel.LastChild.LastChild.Visible:=True;
		Panel.LastChild.LastChild.BoundsToNeedBounds;
		
		Panel.LastChild.CreateChild(TSGLabel.Create);
		Panel.LastChild.LastChild.SetBounds(60,30,Panel.LastChild.Width-75,20);
		Panel.LastChild.LastChild.Caption:='';
		Panel.LastChild.LastChild.Visible:=True;
		Panel.LastChild.LastChild.BoundsToNeedBounds;
		
		SetLength(OnUpdateBuildingWaitingPanelTimeArray,Length(OnUpdateBuildingWaitingPanelTimeArray)+1);
		OnUpdateBuildingWaitingPanelTimeArray[High(OnUpdateBuildingWaitingPanelTimeArray)]:=
			BuildingWaiting.GetBuildTime(
				BuildingWaiting.FWaiting[ii],
				BuildingWaiting.GetLvlWithWaiting(ii,BuildingWaiting.FWaiting[ii]),
				Documentation,
				ii);
		
		Panel.LastChild.CreateChild(TSGPicture.Create);
		Panel.LastChild.LastChild.SetBounds(2,2,50,50);
		Panel.LastChild.LastChild.Visible:=True;
		Panel.LastChild.LastChild.BoundsToNeedBounds;
		Panel.LastChild.LastChild.AsPicture.FImage:=
			Documentation.FDocumentation[BuildingWaiting.FWaiting[ii]].FPicture;
		
		Panel.LastChild.CreateChild(TSGIdentifierButton.Create);
		Panel.LastChild.LastChild.SetBounds(Panel.LastChild.Width-20,0,20,20);
		Panel.LastChild.LastChild.Caption:='X';
		Panel.LastChild.LastChild.Visible:=True;
		Panel.LastChild.LastChild.BoundsToNeedBounds;
		TSGIdentifierButton(Pointer(Panel.LastChild.LastChild)).FID:=ii;
		Pointer(Panel.LastChild.LastChild.OnChange):=@OnChangeDeleteBuildingFromWaiting;
		
		i+=60;
		ii+=1;
		end;
	
	Panel.FComponentProcedure:=TSGComponentProcedure(@OnUpdateBuildingWaitingPanel);
	OnUpdateBuildingWaitingPanelDataTime.Get;
	end;
end;

procedure Build(Button:TSGIdentifierButton);
var
	World:TSGXNovaWorld = nil;
	Stream:TMemoryStream = nil;
	Planet:TSGXNovaUserPlanet = nil;
begin
	UpDateWorld('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
	
	World:=TSGXNovaWorld.Create;
	Stream:=TMemoryStream.Create;
	Stream.LoadFromFile('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
	World.Load(Stream);
	Stream.Destroy;
	Stream:=TMemoryStream.Create;
	Planet:=World.GetPlanet(SGPCharToString(UserEdit.Caption),PlanetNumber).GetUserPlanet(SGPCharToString(UserEdit.Caption));
	Planet.FBildingsWaiting.NewBuilding(Button.FID,
		Planet.FBildingsWaiting.GetBuildTime(Button.FID,
			Planet.FBildingsWaiting.GetLvlWithWaiting(High(Planet.FBildingsWaiting.FWaiting),Button.FID)+1,
			UnitsDocumentation)
		);
	BuildingWaitingPanelUpDate(
		Button.FParent.FParent.FChildren[1].AsPanel,
		UnitsDocumentation,
		Planet.FBildingsWaiting);
	World.Save(Stream);
	Stream.SaveToFile('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
	Stream.Destroy;
	World.Destroy;
	
end;

procedure UpDateBuildPanel(
	const Panel:TSGPanel; 
	const Documentation:TSGXNovaUnitsDocumentation;
	const ID:Int;
	const Quantity:Int;
	const BuildingWaiting:TSGXNovaBuildingsWaiting);
begin
Panel.CreateChild(TSGPicture.Create);
Panel.LastChild.SetBounds(5,5,Panel.Width div 3,Panel.Width div 3 );
Panel.LastChild.Visible:=True;
Panel.LastChild.AsPicture.FImage:=Documentation.FDocumentation[ID].FPicture;
Panel.LastChild.BoundsToNeedBounds;

Panel.CreateChild(TSGLabel.Create);
Panel.LastChild.Font:=TimesNewRomanFont;
Panel.LastChild.SetBounds(10 + (Panel.Width div 3) ,5,(Panel.Width div 3)*2,30);
if Quantity=0 then
	Panel.LastChild.Caption:='Еще не построено.'
else
	Panel.LastChild.Caption:=
		SGPCharTotal(
			'Построен уровень ',
			SGStringToPChar(SGStr(Quantity)+'.'));
Panel.LastChild.Visible:=True;
Panel.LastChild.BoundsToNeedBounds;

Panel.CreateChild(TSGLabel.Create);
Panel.LastChild.SetBounds(10 + (Panel.Width div 3) ,40,(Panel.Width div 3)*2,30);
Panel.LastChild.Caption:=SGStringToPChar('Необходимо времени : '+SGSecondsToStringTime(
	BuildingWaiting.GetBuildTime(ID,BuildingWaiting.GetNextBuildingLevel(ID),Documentation)
	)+'.');
Panel.LastChild.Visible:=True;
Panel.LastChild.BoundsToNeedBounds;

Panel.CreateChild(TSGIdentifierButton.Create);
Panel.LastChild.Visible:=True;
Panel.LastChild.BoundsToNeedBounds;
Panel.LastChild.Caption:='Построить';
Panel.LastChild.SetBounds(Panel.Width div 2-5,Panel.Height-40,Panel.Width div 2-20,30);
TSGIdentifierButton(Pointer(Panel.LastChild)).FID:=ID;
Panel.LastChild.AsButton.OnChange:=TSGComponentProcedure(@Build);
Panel.LastChild.BoundsToNeedBounds;

Panel.CreateChild(TSGIdentifierButton.Create);
Panel.LastChild.Visible:=True;
Panel.LastChild.BoundsToNeedBounds;
Panel.LastChild.Caption:='Снести';
Panel.LastChild.SetBounds(5,Panel.Height-40,Panel.Width div 2-20,30);
TSGIdentifierButton(Pointer(Panel.LastChild)).FID:=ID;
Panel.LastChild.BoundsToNeedBounds;
Panel.LastChild.Active:=False;

end;

procedure ChangeBuildingComboBox(a,b:LongInt);
var
	FComboBox:TSGComboBox = nil;
	FBuildPanel:TSGPanel = nil;
var
	World:TSGXNovaWorld = nil;
	Stream:TMemoryStream = nil;
var
	Planet:TSGXNovaPlanet = nil;
	User:string = '';
	I:LongInt;
	UserPlanetID:LongInt = -1;
var
	IDB:LongInt = -1;
begin
FComboBox:=BildingsPanel.LastChild.AsComboBox;
IDB:=FComboBox.FItems[b].FID;
FBuildPanel:=BildingsPanel.Children[1].AsPanel;
while Length(FBuildPanel.FChildren)>0 do
	FBuildPanel.LastChild.Destroy;


World:=TSGXNovaWorld.Create;
Stream:=TMemoryStream.Create;
Stream.LoadFromFile('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
World.Load(Stream);
Stream.Destroy;

User:=SGPCharToString(UserEdit.Caption);
Planet:=World.GetPlanet(User,PlanetNumber);
if Planet<>nil then
	begin
	for i:=0 to High(Planet.FUserPlanets) do
		if Planet.FUserPlanets[i].FUser=User then
			begin
			UserPlanetID:=i;
			Break;
			end;
	if UserPlanetID<>-1 then
		begin
		UpDateBuildPanel(FBuildPanel,UnitsDocumentation,IDB,Planet.FUserPlanets[UserPlanetID].FUnits.FindUnit(IDB),
			Planet.FUserPlanets[UserPlanetID].FBildingsWaiting);
		end;
	end;

World.Destroy;
end;

procedure BuildingPanelUpDate(
	const Panel:TSGPanel; 
	const Documentation:TSGXNovaUnitsDocumentation;
	const World:TSGXNovaWorld;
	const User:String;
	const PlanetNumber:LongInt);
var
	Planet:TSGXNovaPlanet = nil;
	UserPlanetID:LongInt = -1;
	i:LongInt = 0;
	ii:LongInt = 0;
begin
while Length(Panel.FChildren)>=1 do
	Panel.FChildren[0].Destroy;

Panel.CreateChild(TSGPanel.Create);
Panel.LastChild.SetBounds(5,45,Panel.Width div 2 - 10,Panel.Height-50);
Panel.LastChild.Visible:=True;
Panel.LastChild.BoundsToNeedBounds;

Panel.CreateChild(TSGPanel.Create);
Panel.LastChild.SetBounds(Panel.Width div 2 +5,5,Panel.Width div 2 - 10,Panel.Height-10);
Panel.LastChild.Visible:=True;
Panel.LastChild.BoundsToNeedBounds;

Panel.CreateChild(TSGComboBox.Create);
Panel.LastChild.SetBounds(5,5,Panel.Width div 2 - 10,30);
Panel.LastChild.Visible:=True;
Panel.LastChild.AsComboBox.FSelectItem:=0;
Panel.LastChild.Font:=TimesNewRomanFont;
Panel.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@ChangeBuildingComboBox);
Panel.LastChild.BoundsToNeedBounds;

Planet:=World.GetPlanet(User,PlanetNumber);
if Planet<>nil then
	begin
	for i:=0 to High(Planet.FUserPlanets) do
		if Planet.FUserPlanets[i].FUser=User then
			begin
			UserPlanetID:=i;
			Break;
			end;
	if UserPlanetID<>-1 then
		begin
		for i:=0 to High(Documentation.FDocumentation) do
			begin
			if Documentation.FDocumentation[i].FType=XNovaBuilding then
				begin
				ii:=Planet.FUserPlanets[UserPlanetID].FUnits.FindUnit(i);
				CreateOneBuilding(Panel,Documentation,i,ii);
				end;
			end;
		end;
	end;
BuildingWaitingPanelUpDate(
	Panel.FChildren[1].AsPanel,
	Documentation,
	Planet.FUserPlanets[UserPlanetID].FBildingsWaiting);
ChangeBuildingComboBox(0,0);
end;

{$NOTE Overs}

procedure OnUpdatePlanetPanel;
var
	World:TSGXNovaWorld = nil;
	Stream:TMemoryStream = nil;
begin
World:=TSGXNovaWorld.Create;
Stream:=TMemoryStream.Create;
Stream.LoadFromFile('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
World.Load(Stream);
PlanetPanel.Children[1].AsPicture.FImage:=PlanetsPictures[World.GetPlanet(SGPCharToString(UserEdit.Caption),PlanetNumber).FNumberPicture-1];
PlanetPanel.Children[2].Caption:=SGPCharTotal(SGPCharTotal('Имя: "',SGStringToPChar(World.GetPlanet(SGPCharToString(UserEdit.Caption),PlanetNumber).FName)),'".');
PlanetPanel.Children[3].Caption:=SGPCharTotal(SGPCharTotal('Координаты:',World.GetPlanet(SGPCharToString(UserEdit.Caption),PlanetNumber).FCoord.ToPChar),'.');
PlanetPanel.Children[4].Caption:=SGPCharTotal(SGPCharTotal('Диаметр: ',SGStringToPChar(SGStr(World.GetPlanet(SGPCharToString(UserEdit.Caption),PlanetNumber).FDiametr))),' км.');
PlanetPanel.Children[5].Caption:=SGPCharTotal(SGPCharTotal('Поля: ',SGStringToPChar(SGStr(World.GetPlanet(SGPCharToString(UserEdit.Caption),PlanetNumber).FPolygones))),'.');
PlanetPanel.Children[6].Caption:=SGPCharTotal(SGPCharTotal('Занято полей: ',SGStringToPChar(SGStr(World.GetPlanet(SGPCharToString(UserEdit.Caption),PlanetNumber).BusyPoligones(UnitsDocumentation)))),'.');
PlanetPanel.Children[7].AsProgressBar.Progress:=
	(World.GetPlanet(SGPCharToString(UserEdit.Caption),PlanetNumber).BusyPoligones(UnitsDocumentation))/
	World.GetPlanet(SGPCharToString(UserEdit.Caption),PlanetNumber).FPolygones;
PlanetPanel.Children[8].AsProgressBar.Progress:=
	World.GetPlanet(SGPCharToString(UserEdit.Caption),PlanetNumber).FPolygones/
	TSGXNovaObject.GetPolygonesFromDiametr(World.GetPlanet(SGPCharToString(UserEdit.Caption),PlanetNumber).FDiametr);
Stream.Destroy;
World.Destroy;
end;

procedure ChangeButtonMenu(a,b:LongInt);
var
	World:TSGXNovaWorld = nil;
	Stream:TMemoryStream = nil;
begin
UpDateWorld('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
case a of
2:
	BildingsPanel.Visible:=False;
1:
	ResourcePanel.Visible:=False;
end;

case b of
1:
	begin
	ResourcePanel.Visible:=True;
	World:=TSGXNovaWorld.Create;
	World.Load('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
	ResourcesPanelUpDate(ResourcePanel,UnitsDocumentation,World,SGPCharToString(UserEdit.Caption),PlanetNumber);
	World.Destroy;
	end;
2:
	begin
	BildingsPanel.Visible:=True;
	World:=TSGXNovaWorld.Create;
	Stream:=TMemoryStream.Create;
	Stream.LoadFromFile('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
	World.Load(Stream);
	Stream.Destroy;
	BuildingPanelUpDate(BildingsPanel,UnitsDocumentation,World,SGPCharToString(UserEdit.Caption),PlanetNumber);
	World.Destroy;
	end;
6:
	begin
	MenuPanel.Visible:=False;
	PlanetPanel.Visible:=False;
	LoginPanel.Visible:=True;
	PasswordEdit.Caption:=SGPCharNil;
	
	UpDateWorldWayComboBox;
	end;
end;

if b<>6 then
	begin
	OnUpdatePlanetPanel;
	end;
end;

procedure EnterIntoWorld;
var
	World:TSGXNovaWorld = nil;
	Stream:TMemoryStream = nil;
begin
UpDateWorld('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
World:=TSGXNovaWorld.Create;
Stream:=TMemoryStream.Create;
Stream.LoadFromFile('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
World.Load(Stream);
Stream.Destroy;

if World.VerificationPassword(SGPCharToString(UserEdit.Caption),SGPCharToString(PasswordEdit.Caption)) then
	begin
	MenuPanel.Visible:=True;
	PlanetPanel.Visible:=True;
	LoginPanel.Visible:=False;
	BildingsPanel.Visible:=False;
	MenuPanel.LastChild.AsButtonMenu.SetButton(0);
	World.Destroy;
	end
else
	World.Destroy;
end;

procedure CreateNewWorld;
var
	World:TSGXNovaWorld = nil;
	Stream:TMemoryStream = nil;
begin
if (SGPCharToString(UserEdit.Caption)<>'') and (SGPCharToString(PasswordEdit.Caption)<>'') and (SGPCharToString(WorldWayEdit.Caption)<>'') then
	begin
	World:=TSGXNovaWorld.Create;
	World.CreateNewUser(SGPCharToString(UserEdit.Caption),SGPCharToString(PasswordEdit.Caption),UnitsDocumentation);
	Stream:=TMemoryStream.Create();
	World.Save(Stream);
	Stream.SaveToFile('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
	Stream.Destroy;
	World.Destroy;

	EnterIntoWorld;
	end
else
	begin
	
	end;
end;

procedure FromExit;
begin
Halt;
end;

procedure LoadPlanetsPictures;
var
	i:LongInt;
begin
SetLength(PlanetsPictures,59);
for i:=0 to High(PlanetsPictures) do
	begin
	PlanetsPictures[i]:=TSGGLImage.Create('XNova'+Slash+'Planets'+Slash+'planet ('+SGStr(i+1)+').png');
	PlanetsPictures[i].Loading;
	end;
end;

procedure NewPlayer;
var
	World:TSGXNovaWorld = nil;
	Stream:TMemoryStream = nil;
var
	Sucssesfull:Boolean = False;
begin
if (SGPCharToString(UserEdit.Caption)<>'') and (SGPCharToString(PasswordEdit.Caption)<>'') and (SGPCharToString(WorldWayEdit.Caption)<>'') then
	begin
	Stream:=TMemoryStream.Create();
	World:=TSGXNovaWorld.Create;
	Stream.LoadFromFile('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
	World.Load(Stream);
	
	Sucssesfull:=not World.UserExists(SGPCharToString(UserEdit.Caption));
	if Sucssesfull then
		World.CreateNewUser(SGPCharToString(UserEdit.Caption),SGPCharToString(PasswordEdit.Caption));
	Stream.Destroy;
	Stream:=TMemoryStream.Create();
	World.Save(Stream);
	Stream.SaveToFile('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
	Stream.Destroy;
	World.Destroy;
	
	if Sucssesfull then
		EnterIntoWorld;
	end
else
	begin
	
	end;
end;

procedure ChangeUserComboBox(a,b:LongInt);
begin
if UserComboBox.FItems[b].FID=0 then
	begin
	UserEdit.Caption:='';
	UserEdit.Active:=True;
	with UserComboBox do 
		NewPlayerButton.Active:=(FItems[FSelectItem].FID<>0);
	LoginButton.Active:=False;
	end
else
	begin
	UserEdit.Caption:=UserComboBox.FItems[b].FCaption;
	UserEdit.Active:=False;
	NewPlayerButton.Active:=False;
	LoginButton.Active:=True;
	end;
end;

procedure UpDateUserComboBox;
var
	World:TSGXNovaWorld = nil;
	i:LongInt;
begin
UserComboBox.FSelectItem:=0;
SetLength(UserComboBox.FItems,0);
if FileExists('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui') then
	begin
	World:=TSGXNovaWorld.Create;
	World.Load('Worlds'+Slash+SGPCharToString(WorldWayEdit.Caption)+'.xui');
	for i:=0 to High(World.FUsers.FUsers) do
		begin
		UserComboBox.CreateItem(SGStringToPChar(World.FUsers.FUsers[i][0]));
		end;
	end;
UserComboBox.CreateItem('Новый игрок.',nil,0);
ChangeUserComboBox(0,UserComboBox.FSelectItem);
end;

procedure ChangeWorldWayComboBox(a,b:LongInt);
begin
if WorldWayComboBox.FItems[b].FID=0 then
	begin
	WorldWayEdit.Caption:='';
	WorldWayEdit.Active:=True;
	NewWorldButton.Active:=True;
	LoginButton.Active:=False;
	end
else
	begin
	WorldWayEdit.Caption:=WorldWayComboBox.FItems[b].FCaption;
	WorldWayEdit.Active:=False;
	NewWorldButton.Active:=False;
	LoginButton.Active:=True;
	end;
UpDateUserComboBox;
end;

procedure UpDateWorldWayComboBox;
var
	Box:TSGComboBox = nil;
	ArString:TArString = nil;
	i:LongInt = 0;
begin
Box:=WorldWayComboBox;

ArString:=SGGetFileNames('Worlds'+Slash,'*.xui');

Box.FSelectItem:=0;

SetLength(Box.FItems,0);

for i:=0 to High(ArString) do
	Box.CreateItem(SGStringToPChar(SGGetFileNameWithoutExpansion(ArString[i])));
Box.CreateItem('Новый мир.',nil,0);

ChangeWorldWayComboBox(0,Box.FSelectItem);
end;

procedure UserOnActivate; {DONT RENAME THIS PROCEDURE}(*!!!!*){}
begin

TimesNewRomanFont:=TSGGLFont.Create('Times New Roman.bmp');
TimesNewRomanFont.Loading;

TahomaFont:=TSGGLFont.Create('Tahoma.bmp');
TahomaFont.Loading;

SGScreen.Font:=TahomaFont;

LoadPlanetsPictures;

SGScreen.CreateChild(TSGPanel.Create);
MenuPanel:=SGScreen.LastChild.AsPanel;
SGScreen.LastChild.SetBounds(3,345
	{$IFDEF MSWINDOWS}
	+Byte((SGMethodLoginToOpenGLType=SGMethodLoginToOpenGLWinAPI) and (not PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.Fullscreen))*30
		{$ENDIF}
	,200,305);

MenuPanel.CreateChild(TSGButtonMenu.Create);
MenuPanel.LastChild.SetBounds(3,3,190,MenuPanel.Height-10);
MenuPanel.LastChild.AsButtonMenu.FProcedure:=TSGButtonMenuProcedure(@ChangeButtonMenu);
MenuPanel.LastChild.AsButtonMenu.ButtonTop:=15;
MenuPanel.LastChild.AsButtonMenu.ActiveButtonTop:=35;

MenuPanel.LastChild.AsButtonMenu.AddButton('Обзор');
MenuPanel.LastChild.AsButtonMenu.AddButton('Сырьё');
MenuPanel.LastChild.AsButtonMenu.AddButton('Постройки');
MenuPanel.LastChild.AsButtonMenu.AddButton('Армия');
MenuPanel.LastChild.AsButtonMenu.AddButton('Оборона');
MenuPanel.LastChild.AsButtonMenu.AddButton('Флот');
MenuPanel.LastChild.AsButtonMenu.AddButton('Выход');

MenuPanel.LastChild.Height:=MenuPanel.LastChild.LastChild.FNeedHeight+MenuPanel.LastChild.LastChild.FNeedTop+30;
MenuPanel.Height:=MenuPanel.LastChild.FNeedTop+MenuPanel.LastChild.FNeedHeight+15;

PlanetPanel:=TSGPanel.Create;
SGScreen.CreateChild(PlanetPanel);
PlanetPanel.SetBounds(3,3
	{$IFDEF MSWINDOWS}
	+Byte((SGMethodLoginToOpenGLType=SGMethodLoginToOpenGLWinAPI) and (not PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.Fullscreen))*30
		{$ENDIF}
	,200,340);
PlanetPanel.Visible:=False;
PlanetPanel.Font:=TahomaFont;

SGScreen.LastChild.CreateChild(TSGPicture.Create);
SGScreen.LastChild.LastChild.SetBounds(5,5,180,180);
SGScreen.LastChild.LastChild.AsPicture.FImage:=nil;
SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.SetBounds(5,185,180,20);
SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.SetBounds(5,205,180,20);
SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.SetBounds(5,225,180,20);
SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.SetBounds(5,245,180,20);
SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.SetBounds(5,265,180,20);
SGScreen.LastChild.CreateChild(TSGProgressBar.Create);
SGScreen.LastChild.LastChild.SetBounds(5,285,180,20);
SGScreen.LastChild.LastChild.AsProgressBar.ViewProgress:=True;
SGScreen.LastChild.LastChild.AsProgressBar.ViewCaption:=True;
SGScreen.LastChild.LastChild.AsProgressBar.Caption:='Занято полей:';
SGScreen.LastChild.LastChild.AsProgressBar.FColor1.Import(0,0.75,0);
SGScreen.LastChild.LastChild.AsProgressBar.FColor2.Import(0,1,0);
SGScreen.LastChild.CreateChild(TSGProgressBar.Create);
SGScreen.LastChild.LastChild.SetBounds(5,310,180,20);
SGScreen.LastChild.LastChild.AsProgressBar.ViewProgress:=True;
SGScreen.LastChild.LastChild.AsProgressBar.ViewCaption:=True;
SGScreen.LastChild.LastChild.AsProgressBar.Caption:='Освоено:';
SGScreen.LastChild.LastChild.AsProgressBar.FColor1.Import(0,0.75,0);
SGScreen.LastChild.LastChild.AsProgressBar.FColor2.Import(0,1,0);

(*Building Panel*)
BildingsPanel:=TSGPanel.Create;
SGScreen.CreateChild(BildingsPanel);
SGScreen.LastChild.SetBounds(
	205,
	3
	{$IFDEF MSWINDOWS}
	+Byte((SGMethodLoginToOpenGLType=SGMethodLoginToOpenGLWinAPI) and (not PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.Fullscreen))*30
		{$ENDIF},
	ContextWidth - 205,
	ContextHeight-3
	{$IFDEF MSWINDOWS}
	-Byte((SGMethodLoginToOpenGLType=SGMethodLoginToOpenGLWinAPI) and (not PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.Fullscreen))*30
		{$ENDIF});
SGScreen.LastChild.BoundsToNeedBounds;

(*Money Panel*)
ResourcePanel:=TSGPanel.Create;
SGScreen.CreateChild(ResourcePanel);
SGScreen.LastChild.SetBounds(
	205,
	3
	{$IFDEF MSWINDOWS}
	+Byte((SGMethodLoginToOpenGLType=SGMethodLoginToOpenGLWinAPI) and (not PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.Fullscreen))*30
		{$ENDIF},
	ContextWidth - 205,
	ContextHeight-3
	{$IFDEF MSWINDOWS}
	-Byte((SGMethodLoginToOpenGLType=SGMethodLoginToOpenGLWinAPI) and (not PTSGMethodWinAPI(SGMethodLoginToOpenGL)^.Fullscreen))*30
		{$ENDIF});
SGScreen.LastChild.BoundsToNeedBounds;

(*Login Panel*)
LoginPanel:=TSGPanel.Create;
SGScreen.CreateChild(LoginPanel);
SGScreen.LastChild.SetMiddleBounds(300,340);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.BoundsToNeedBounds;

SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.SetBounds(5,5,295,30);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.Caption:='Мир:';
SGScreen.LastChild.LastChild.BoundsToNeedBounds;

WorldWayEdit:=TSGEdit.Create;
SGScreen.LastChild.CreateChild(WorldWayEdit);
SGScreen.LastChild.LastChild.SetBounds(155,35,140,30);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.Caption:='MyWorld';
SGScreen.LastChild.LastChild.BoundsToNeedBounds;


SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.SetBounds(5,65,295,30);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.Caption:='Правитель:';
SGScreen.LastChild.LastChild.BoundsToNeedBounds;

UserEdit:=TSGEdit.Create;
SGScreen.LastChild.CreateChild(UserEdit);
SGScreen.LastChild.LastChild.SetBounds(155,95,140,30);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.Caption:='';
SGScreen.LastChild.LastChild.BoundsToNeedBounds;

SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.SetBounds(5,125,295,30);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.Caption:='Пароль:';
SGScreen.LastChild.LastChild.BoundsToNeedBounds;

PasswordEdit:=TSGEdit.Create;
SGScreen.LastChild.CreateChild(PasswordEdit);
SGScreen.LastChild.LastChild.SetBounds(5,155,295,30);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.Caption:='';
SGScreen.LastChild.LastChild.BoundsToNeedBounds;

SGScreen.LastChild.CreateChild(TSGButton.Create);
SGScreen.LastChild.LastChild.SetBounds(85,225,130,30);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.Caption:='Создать Mир';
SGScreen.LastChild.LastChild.OnChange:=TSGComponentProcedure(@CreateNewWorld);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
NewWorldButton:=SGScreen.LastChild.LastChild.AsButton;

SGScreen.LastChild.CreateChild(TSGButton.Create);
SGScreen.LastChild.LastChild.SetBounds(85,190,130,30);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.Caption:='Войти';
SGScreen.LastChild.LastChild.OnChange:=TSGComponentProcedure(@EnterIntoWorld);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
LoginButton:=SGScreen.LastChild.LastChild.AsButton;

SGScreen.LastChild.CreateChild(TSGButton.Create);
SGScreen.LastChild.LastChild.SetBounds(85,260,130,30);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.Caption:='Новый Игрок';
SGScreen.LastChild.LastChild.OnChange:=TSGComponentProcedure(@NewPlayer);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
NewPlayerButton:=SGScreen.LastChild.LastChild.AsButton;

SGScreen.LastChild.CreateChild(TSGButton.Create);
SGScreen.LastChild.LastChild.SetBounds(85,295,130,30);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.Caption:='Выход';
SGScreen.LastChild.LastChild.OnChange:=TSGComponentProcedure(@FromExit);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;

UserComboBox:=TSGComboBox.Create;
SGScreen.LastChild.CreateChild(UserComboBox);
SGScreen.LastChild.LastChild.SetBounds(0,95,140,30);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@ChangeUserComboBox);

WorldWayComboBox:=TSGComboBox.Create;
SGScreen.LastChild.CreateChild(WorldWayComboBox);
SGScreen.LastChild.LastChild.SetBounds(0,35,140,30);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@ChangeWorldWayComboBox);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;

UpDateWorldWayComboBox;

(*End Login Panel*)

UnitsDocumentation.LoadImages;
end;

procedure UserOnBeginProgram; {DONT RENAME THIS PROCEDURE!!!!}
begin
if not DirectoryExists('Worlds') then
	MKDir('Worlds');
if not DirectoryExists('XNova') then
	MKDir('XNova');

UnitsDocumentation:=TSGXNovaUnitsDocumentation.Create;
if FileExists('XNova'+Slash+'Objects.cfg') then
	begin
	UnitsDocumentation.Load('XNova'+Slash+'Objects.cfg');
	end;
end;

end.
