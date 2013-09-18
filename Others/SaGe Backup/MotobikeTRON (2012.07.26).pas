{$MODE OBJFPC}
unit SGUser;
interface
uses 
	crt
	{$IFDEF MSWINDOWS}
		,windows
		{$ENDIF}
	{$IFDEF UNIX}
		,unix
		{$ENDIF}
	,SaGe
	,GL
	,SaGeCL
	,GLu
	,SaGeMath
	,SaGeBase
	,SaGeImagesBase
	,SysUtils
	,Classes
	,SaGeImagesPng
	,SaGeImagesBmp
	,SaGeFractals
	,SaGeMesh
	,SaGeGameLogic
	,SaGeNet
	;
var
	MainButtonMenu:TSGButtonMenu = nil;
	GameButtonMenu:TSGButtonMenu = nil;
	OptionButtonMenu:TSGButtonMenu = nil;
	ClientPanel:TSGPanel = nil;
	ServerPanel:TSGPanel = nil;
	LoadingProgressBar:TSGProgressBar = nil;
	
	FExit:boolean = False;
	Smeshenie1:longint = 400;
	
	Game:TSGGame = nil;

procedure UserOnBeginProgram;
procedure UserOnActivate;
procedure UserOnPaint;

implementation

procedure UserOnPaint; {DONT RENAME THIS PROCEDURE!!!!}
begin
if FExit and MainButtonMenu.NotVisible then
	SGCloseContext;
if Game<>nil then
	begin
	Game.Draw;
	end;
end;

procedure ChangeMainButtonMenu(a,b:LongInt);
begin
case MainButtonMenu.Children[b+1].AsButtonMenuButton.Identifity of
0:
	begin
	MainButtonMenu.Visible:=False;
	FExit:=True;
	end;
3:
	begin
	MainButtonMenu.AddToLeft(-Smeshenie1);
	GameButtonMenu.AddToLeft(-Smeshenie1);
	ServerPanel.AddToLeft(-Smeshenie1);
	ClientPanel.AddToLeft(-Smeshenie1);
	OptionButtonMenu.AddToLeft(-Smeshenie1);
	GameButtonMenu.Visible:=True;
	GameButtonMenu.DetectActiveButton;
	MainButtonMenu.Active:=False;
	end;
1:
	begin
	MainButtonMenu.AddToLeft(-Smeshenie1);
	GameButtonMenu.AddToLeft(-Smeshenie1);
	ServerPanel.AddToLeft(-Smeshenie1);
	ClientPanel.AddToLeft(-Smeshenie1);
	OptionButtonMenu.AddToLeft(-Smeshenie1);
	OptionButtonMenu.Visible:=True;
	OptionButtonMenu.DetectActiveButton;
	MainButtonMenu.Active:=False;
	end;
end;
end;

procedure ChangeGameButtonMenu(a,b:LongInt);
begin
case GameButtonMenu.Children[b+1].AsButtonMenuButton.Identifity of
0:
	begin
	GameButtonMenu.Visible:=False;
	MainButtonMenu.AddToLeft(Smeshenie1);
	GameButtonMenu.AddToLeft(Smeshenie1);
	ClientPanel.AddToLeft(Smeshenie1);
	ServerPanel.AddToLeft(Smeshenie1);
	OptionButtonMenu.AddToLeft(Smeshenie1);
	MainButtonMenu.DetectActiveButton;
	MainButtonMenu.Active:=True;
	end;
2,1:
	begin
	MainButtonMenu.AddToLeft(-Smeshenie1);
	GameButtonMenu.AddToLeft(-Smeshenie1);
	ServerPanel.AddToLeft(-Smeshenie1);
	ClientPanel.AddToLeft(-Smeshenie1);
	OptionButtonMenu.AddToLeft(-Smeshenie1);
	if GameButtonMenu.Children[b+1].AsButtonMenuButton.Identifity=1 then 
		ServerPanel.Visible:=True
	else
		ClientPanel.Visible:=True;
	GameButtonMenu.Active:=False;
	end;
end;
end;

procedure ChangeOptionButtonMenu(a,b:LongInt);
begin
case OptionButtonMenu.Children[b+1].AsButtonMenuButton.Identifity of
0://Back
	begin
	OptionButtonMenu.Visible:=False;
	MainButtonMenu.AddToLeft(Smeshenie1);
	GameButtonMenu.AddToLeft(Smeshenie1);
	ClientPanel.AddToLeft(Smeshenie1);
	ServerPanel.AddToLeft(Smeshenie1);
	OptionButtonMenu.AddToLeft(Smeshenie1);
	MainButtonMenu.DetectActiveButton;
	MainButtonMenu.Active:=True;
	end;
3:
	begin
	{MainButtonMenu.AddToLeft(-Smeshenie1);
	GameButtonMenu.AddToLeft(-Smeshenie1);
	ServerPanel.AddToLeft(-Smeshenie1);
	ClientPanel.AddToLeft(-Smeshenie1);
	OptionButtonMenu.AddToLeft(-Smeshenie1);
	if GameButtonMenu.Children[b+1].AsButtonMenuButton.Identifity=1 then 
		ServerPanel.Visible:=True
	else
		ClientPanel.Visible:=True;
	GameButtonMenu.Active:=False;}
	end;
end;
end;

procedure StartGame(const AConnectionMode:TSGConnectionMode;const APort:Word;const AAddress:string = 'localhost');inline;
begin
Game:=TSGGame.Create;
Game.AddMapMesh(TSGGameMesh,'models/Map.3ds');
Game.AddMainActor(TSGMotoBike.Create,'models/motoBike.3ds');
Game.ConnectionMode:=AConnectionMode;
Game.Connection.Host:=AAddress;
Game.Connection.Port:=APort;
Game.LoadingProgressBar:=LoadingProgressBar;
LoadingProgressBar.Visible:=True;
Game.StartThread;
end;

procedure StartClient(Component:TSGComponent);
begin
StartGame(TSGClientMode,SGVal(Component.Parent.Children[4].AsEdit.Caption),Component.Parent.Children[2].AsEdit.Caption);

GameButtonMenu.Visible:=False;
MainButtonMenu.Visible:=False;
ServerPanel.Visible:=False;
ClientPanel.Visible:=False;
end;

procedure StartServer(Component:TSGComponent);
begin
StartGame(TSGServerMode,SGVal(Component.Parent.Children[2].AsEdit.Caption));

GameButtonMenu.Visible:=False;
MainButtonMenu.Visible:=False;
ServerPanel.Visible:=False;
ClientPanel.Visible:=False;
end;

procedure BackInGameMenuFrames(Component:TSGComponent);
begin
Component.Parent.Visible:=False;
MainButtonMenu.AddToLeft(Smeshenie1);
GameButtonMenu.AddToLeft(Smeshenie1);
ClientPanel.AddToLeft(Smeshenie1);
ServerPanel.AddToLeft(Smeshenie1);
OptionButtonMenu.AddToLeft(Smeshenie1);
GameButtonMenu.Active:=True;
GameButtonMenu.DetectActiveButton;
end;

procedure UserOnActivate; {DONT RENAME THIS PROCEDURE!!!!}
begin
SGScreen.Font:=TSGGLFont.Create('Times New Roman.bmp');
SGScreen.Font.Loading;

MainButtonMenu:=TSGButtonMenu.Create;
SGScreen.CreateChild(MainButtonMenu);
SGScreen.LastChild.SetMiddleBounds(400,280);
SGScreen.LastChild.AsButtonMenu.FProcedure:=TSGButtonMenuProcedure(@ChangeMainButtonMenu);
SGScreen.LastChild.AsButtonMenu.ButtonTop:=50;
SGScreen.LastChild.AsButtonMenu.ActiveButtonTop:=100;
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.UnLimited:=True;

SGScreen.LastChild.AsButtonMenu.AddButton('Играть');
SGScreen.LastChild.LastChild.AsButtonMenuButton.Identifity:=3;
SGScreen.LastChild.AsButtonMenu.AddButton('Настройки');
SGScreen.LastChild.LastChild.AsButtonMenuButton.Identifity:=1;
SGScreen.LastChild.AsButtonMenu.AddButton('Выход');
SGScreen.LastChild.LastChild.AsButtonMenuButton.Identifity:=0;
SGScreen.LastChild.Visible:=True;


GameButtonMenu:=TSGButtonMenu.Create;
SGScreen.CreateChild(GameButtonMenu);
SGScreen.LastChild.SetMiddleBounds(200,190);
SGScreen.LastChild.AsButtonMenu.FProcedure:=TSGButtonMenuProcedure(@ChangeGameButtonMenu);
SGScreen.LastChild.AsButtonMenu.ButtonTop:=40;
SGScreen.LastChild.AsButtonMenu.ActiveButtonTop:=60;
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.AddToLeft(Smeshenie1);
SGScreen.LastChild.UnLimited:=True;

SGScreen.LastChild.AsButtonMenu.AddButton('Сервер');
SGScreen.LastChild.LastChild.AsButtonMenuButton.Identifity:=1;
SGScreen.LastChild.AsButtonMenu.AddButton('Клиент');
SGScreen.LastChild.LastChild.AsButtonMenuButton.Identifity:=2;
SGScreen.LastChild.AsButtonMenu.AddButton('Назад');
SGScreen.LastChild.LastChild.AsButtonMenuButton.Identifity:=0;
SGScreen.LastChild.Visible:=False;


OptionButtonMenu:=TSGButtonMenu.Create;
SGScreen.CreateChild(OptionButtonMenu);
SGScreen.LastChild.SetMiddleBounds(200,210);
SGScreen.LastChild.AsButtonMenu.FProcedure:=TSGButtonMenuProcedure(@ChangeOptionButtonMenu);
SGScreen.LastChild.AsButtonMenu.ButtonTop:=40;
SGScreen.LastChild.AsButtonMenu.ActiveButtonTop:=60;
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.AddToLeft(Smeshenie1);
SGScreen.LastChild.UnLimited:=True;

SGScreen.LastChild.AsButtonMenu.AddButton('Изображение');
SGScreen.LastChild.LastChild.AsButtonMenuButton.Identifity:=1;
SGScreen.LastChild.AsButtonMenu.AddButton('Звук');
SGScreen.LastChild.LastChild.AsButtonMenuButton.Identifity:=2;
SGScreen.LastChild.AsButtonMenu.AddButton('Мультиплэер');
SGScreen.LastChild.LastChild.AsButtonMenuButton.Identifity:=3;
SGScreen.LastChild.AsButtonMenu.AddButton('Назад');
SGScreen.LastChild.LastChild.AsButtonMenuButton.Identifity:=0;
SGScreen.LastChild.Visible:=False;

ServerPanel:=TSGPanel.Create;
SGScreen.CreateChild(ServerPanel);
SGScreen.LastChild.SetMiddleBounds(250,160);
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.AddToLeft(Smeshenie1);
SGScreen.LastChild.AddToLeft(Smeshenie1);
SGScreen.LastChild.UnLimited:=True;

SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.SetBounds(5,5,230,30);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.Caption:='Порт';

SGScreen.LastChild.CreateChild(TSGEdit.Create);
SGScreen.LastChild.LastChild.SetBounds(5,40,230,30);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.Caption:='5233';

SGScreen.LastChild.CreateChild(TSGButton.Create);
SGScreen.LastChild.LastChild.SetBounds(5,80,230,30);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.Caption:='Старт';
SGScreen.LastChild.LastChild.OnChange:=TSGComponentProcedure(@StartServer);

SGScreen.LastChild.CreateChild(TSGButton.Create);
SGScreen.LastChild.LastChild.SetBounds(5,115,230,30);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.Caption:='Отмена';
SGScreen.LastChild.LastChild.OnChange:=TSGComponentProcedure(@BackInGameMenuFrames);

ClientPanel:=TSGPanel.Create;
SGScreen.CreateChild(ClientPanel);
SGScreen.LastChild.SetMiddleBounds(250,230);
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.AddToLeft(Smeshenie1);
SGScreen.LastChild.AddToLeft(Smeshenie1);
SGScreen.LastChild.UnLimited:=True;

SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.SetBounds(5,5,230,30);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.Caption:='Хост\Адрес';

SGScreen.LastChild.CreateChild(TSGEdit.Create);
SGScreen.LastChild.LastChild.SetBounds(5,40,230,30);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.Caption:='localhost';

SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.SetBounds(5,75,230,30);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.Caption:='Порт';

SGScreen.LastChild.CreateChild(TSGEdit.Create);
SGScreen.LastChild.LastChild.SetBounds(5,110,230,30);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.Caption:='5233';

SGScreen.LastChild.CreateChild(TSGButton.Create);
SGScreen.LastChild.LastChild.SetBounds(5,150,230,30);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.Caption:='Старт';
SGScreen.LastChild.LastChild.OnChange:=TSGComponentProcedure(@StartClient);

SGScreen.LastChild.CreateChild(TSGButton.Create);
SGScreen.LastChild.LastChild.SetBounds(5,185,230,30);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.Caption:='Отмена';
SGScreen.LastChild.LastChild.OnChange:=TSGComponentProcedure(@BackInGameMenuFrames);

LoadingProgressBar:=TSGProgressBar.Create;
SGScreen.CreateChild(LoadingProgressBar);
SGScreen.LastChild.SetMiddleBounds(300,30);
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.UnLimited:=True;

end;

procedure UserOnBeginProgram; {DONT RENAME THIS PROCEDURE!!!!}
begin
end;

end.