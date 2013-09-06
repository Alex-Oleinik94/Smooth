{$i SaGe.inc}
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
	MultplayerPanel:TSGPanel = nil;
	
	EscButtonMenu:TSGButtonMenu = nil;
	
	ArComponents:packed array of TSGComponent = nil;
	
	LoadingProgressBar:TSGProgressBar = nil;
	
	FExit:boolean = False;
	Smeshenie1:longint = 400;
	
	Game:TSGGame = nil;
	
procedure UserOnBeginProgram;
procedure UserOnActivate;
procedure UserOnPaint;

implementation

procedure AddLeftToComponentArray(const Int:LongInt ); inline;
var
	i:LongInt;
begin
i:=0;
while i<=High(ArComponents) do
	begin
	ArComponents[i].AddToLeft(Int);
	i+=1;
	end;
end;

procedure AddComponentToArray(const Component:TSGComponent);inline;
begin
SetLength(ArComponents,Length(ArComponents)+1);
ArComponents[High(ArComponents)]:=Component;
end;

procedure UserOnPaint; {DONT RENAME THIS PROCEDURE!!!!}
begin
if FExit and MainButtonMenu.NotVisible then
	SGCloseContext;
if Game<>nil then
	begin
	Game.Draw;
	if not Game.FOnlyLoading then
		if (SGKeyPressedChar=#27) then
			begin
			EscButtonMenu.Visible:= not EscButtonMenu.Visible;
			EscButtonMenu.DetectActiveButton;
			end;
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
	AddLeftToComponentArray(-Smeshenie1);
	GameButtonMenu.Visible:=True;
	GameButtonMenu.DetectActiveButton;
	MainButtonMenu.Active:=False;
	end;
1:
	begin
	AddLeftToComponentArray(-Smeshenie1);
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
	AddLeftToComponentArray(Smeshenie1);
	MainButtonMenu.DetectActiveButton;
	MainButtonMenu.Active:=True;
	end;
2,1:
	begin
	AddLeftToComponentArray(-Smeshenie1);
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
0: //Back
	begin
	OptionButtonMenu.Visible:=False;
	AddLeftToComponentArray(Smeshenie1);
	MainButtonMenu.DetectActiveButton;
	MainButtonMenu.Active:=True;
	end;
3:
	begin
	AddLeftToComponentArray(-Smeshenie1);
	OptionButtonMenu.Active:=False;
	MultplayerPanel.Visible:=True;
	MultplayerPanel.Children[3].Caption:=SGStringToPChar(Game.FMainActor.FNickName);
	end;
end;
end;

procedure StartLoadGame;inline;
begin
Game:=TSGGame.Create;
Game.AddMapMesh(TSGGameMesh,'Models'+Slash+'World');
Game.AddMainActor(TSGMotoBike.Create,'Models'+Slash+'Bike');
Game.LoadingProgressBar:=LoadingProgressBar;
Game.OnlyLoading:=True;
LoadingProgressBar.Visible:=True;
Game.UseThread:=False;
Game.StartThread;
end;

procedure StartGame(const AConnectionMode:TSGConnectionMode;const APort:Word;const AAddress:string = 'localhost');inline;
begin
if Game<>nil then
	begin
	if Game.OnlyLoading then
		begin
		Game.ConnectionMode:=AConnectionMode;
		Game.Connection.Host:=AAddress;
		Game.Connection.Port:=APort;
		Game.StartGame;
		end;
	end
else
	begin
	Game:=TSGGame.Create;
	Game.AddMapMesh(TSGGameMesh,'Models'+Slash+'World');
	Game.AddMainActor(TSGMotoBike.Create,'Models'+Slash+'Bike');
	Game.ConnectionMode:=AConnectionMode;
	Game.Connection.Host:=AAddress;
	Game.Connection.Port:=APort;
	Game.LoadingProgressBar:=LoadingProgressBar;
	LoadingProgressBar.Visible:=True;
	Game.StartThread;
	Game.StartGame;
	end;
end;

procedure StartClient(Component:TSGComponent);
begin
GameButtonMenu.Visible:=False;
MainButtonMenu.Visible:=False;
ServerPanel.Visible:=False;
ClientPanel.Visible:=False;

StartGame(TSGClientMode,SGVal(Component.Parent.Children[4].AsEdit.Caption),Component.Parent.Children[2].AsEdit.Caption);
end;

procedure StartServer(Component:TSGComponent);
begin
GameButtonMenu.Visible:=False;
MainButtonMenu.Visible:=False;
ServerPanel.Visible:=False;
ClientPanel.Visible:=False;
Component.Parent.Active:=False;

StartGame(TSGServerMode,SGVal(Component.Parent.Children[2].AsEdit.Caption));
end;

procedure BackInGameMenuFrames(Component:TSGComponent);
begin
Component.Parent.Visible:=False;
AddLeftToComponentArray(Smeshenie1);
GameButtonMenu.Active:=True;
GameButtonMenu.DetectActiveButton;
end;

procedure OptionMultOK(Button:TSGButton);
begin
Button.Parent.Visible:=False;
AddLeftToComponentArray(Smeshenie1);
OptionButtonMenu.Active:=True;
OptionButtonMenu.DetectActiveButton;
Game.FMainActor.FNickName:=SGPCharToString(Button.Parent.Children[3].Caption);
Game.FMainActor.SavePlayerConfig;
end;

procedure ChangeEscBM(a,b:LongInt);
begin
EscButtonMenu.Visible:=False;
case EscButtonMenu.Children[b+1].AsButtonMenuButton.Identifity of
1:
	begin
	AddLeftToComponentArray(Smeshenie1*2);
	MainButtonMenu.Visible:=True;
	MainButtonMenu.Active:=True;
	MainButtonMenu.DetectActiveButton;
	GameButtonMenu.DetectActiveButton;
	GameButtonMenu.Active:=True;
	ClientPanel.Active:=True;
	ServerPanel.Active:=True;
	Game.FOnlyLoading:=True;
	Game.DestroyConnection;
	Game.CreateConnection;
	Game.DestroyNetPlayers;
	end;
end;
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

EscButtonMenu:=TSGButtonMenu.Create;
SGScreen.CreateChild(EscButtonMenu);
SGScreen.LastChild.SetBounds(50,50,200,100);
SGScreen.LastChild.AsButtonMenu.ButtonTop:=30;
SGScreen.LastChild.AsButtonMenu.ActiveButtonTop:=50;
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.AsButtonMenu.FProcedure:=TSGButtonMenuProcedure(@ChangeEscBM);
SGScreen.LastChild.UnLimited:=True;

SGScreen.LastChild.AsButtonMenu.AddButton('Назад в игру');
SGScreen.LastChild.LastChild.AsButtonMenuButton.Identifity:=0;

SGScreen.LastChild.AsButtonMenu.AddButton('В гавное меню');
SGScreen.LastChild.LastChild.AsButtonMenuButton.Identifity:=1;

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

MultplayerPanel:=TSGPanel.Create;
SGScreen.CreateChild(MultplayerPanel);
SGScreen.LastChild.SetMiddleBounds(400,75+35+35+35+35+40);
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.AddToLeft(Smeshenie1);
SGScreen.LastChild.AddToLeft(Smeshenie1);
SGScreen.LastChild.UnLimited:=True;

SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.SetBounds(5,5,390,30);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.Caption:='Ваш никнэйм';

SGScreen.LastChild.CreateChild(TSGButton.Create);
SGScreen.LastChild.LastChild.SetBounds(105,75+35+35+35+35,190,30);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.Caption:='Ok';
SGScreen.LastChild.LastChild.OnChange:=TSGComponentProcedure(@OptionMultOK);

SGScreen.LastChild.CreateChild(TSGEdit.Create);
SGScreen.LastChild.LastChild.SetBounds(5,40,390,30);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;

SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.SetBounds(5,75,390,30);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.Caption:='Цвет Вашего байка';

SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.SetBounds(5,75+35+35,390,30);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.Caption:='Цвет вашего "оружия"';

AddComponentToArray(MultplayerPanel);
AddComponentToArray(ServerPanel);
AddComponentToArray(ClientPanel);
AddComponentToArray(MainButtonMenu);
AddComponentToArray(GameButtonMenu);
AddComponentToArray(OptionButtonMenu);

LoadingProgressBar:=TSGProgressBar.Create;
SGScreen.CreateChild(LoadingProgressBar);
SGScreen.LastChild.SetMiddleBounds(300,30);
SGScreen.LastChild.SetBounds(
	( ContextWidth div 2) -150 ,
	( trunc ( ContextHeight * 19 / 20 ) ) - 30 ,
	300,
	30 );
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.UnLimited:=True;

StartLoadGame;
end;

procedure UserOnBeginProgram; {DONT RENAME THIS PROCEDURE!!!!}
begin
end;

end.