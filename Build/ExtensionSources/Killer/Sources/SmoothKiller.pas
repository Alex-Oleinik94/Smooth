{$INCLUDE Smooth.inc}

unit SmoothKiller;

interface

uses
	 SmoothCommonStructs
	,SmoothFont
	,SmoothBase
	,SmoothContext
	,SmoothImage
	,SmoothContextInterface
	,SmoothContextClasses
	,SmoothRenderBase
	,SmoothScreenBase
	,SmoothExtensionManager
	,SmoothDateTime
	,SmoothScreenClasses
	;

type
	TSKillerArrayType = packed record
		FType : TSUInt8;
		FWay  : TSUInt32;
		end;
	
	TSKillerArray = packed array of
		packed array of
			TSKillerArrayType;
const
	SKillerStringWin = 'Ты выиграл';
	SKillerStringLose = 'Ты проиграл';
type
	TSKiller=class(TSPaintableObject)
			public
		constructor Create(const VContext:ISContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Paint;override;
		procedure DeleteRenderResources();override;
		procedure LoadRenderResources();override;
			private
		FStartDeep,FStartDeepHeight:LongWord;
		FArray:TSKillerArray;
		FYou: TSPoint2int32;
		FZombies:packed array of
			packed record
			FPosition: TSPoint2int32;
			FActive:Boolean;
			FOldPosition: TSPoint2int32;
			FDieInterval:single;
			FNowPosition:TSVertex2f;
			end;
		FHowManyZombiesYouKill:LongWord;
		FMaxWay:LongWord;
		FR:TSVertex2f;
		FDataTime:TSDateTime;
		FInterval:LongWord;
		FForestWidth,FForestHeight:LongWord;
		FChanget:Boolean;
		FTimer:TSDateTime;
		FTimer2,FBulletDataTime1,FBulletDataTime2:TSDateTime;
		FActive:Boolean; //+
		FVictory:Boolean;//+
		FBullets:packed array of
			packed array[0..1] of
				TSVertex2f; //+
		FDTInterval:LongWord;
		FGroundInt1,FGroundInt2:LongWord; //+
		FRespamn:Boolean; //+
		FSkulls:packed array of 
			packed record 
			FPosition:TSVertex2f;
			FAlpha:LongWord;
			end; //+
		FQuantitySkulls:LongWord;  //+
		FSkullsNowPosition:LongWord; //+
		
		{FGun:
			packed record
			//FType:Byte;
			FTimeFire,FTimeRe,FPatrones,FPatronesAll,FPatronesNow:LongWord;
			end; //-}
		
		FBulletsGos:LongWord;
		{$IFDEF MOBILE}
			FWayShift : TSVertex2f;
			{$ENDIF}
			private
		procedure DoQuad(const i,ii:LongWord;const artype : TSKillerArrayType);inline;
		procedure GoZombies;
		function Proverka(const KPos: TSPoint2int32;const b:Byte):Boolean;inline;
		procedure Reset;inline;
		procedure FreeGame;
		procedure InitGame;
		function TamNetZombie(const MayBeZombie: TSPoint2int32):Boolean;
		procedure Calculate;
		procedure CreateZombi(const ZombieID:LongWord);
		procedure MayByVictory;
		procedure CreateZombies(const o:LongWord = 0);
		function IsBulletKillZombie(const Bullet:TSVertex2f;const Zombie:LongWord):Boolean;
		procedure InitImages(const VWidthHeight : TSLongWord; const VRadBool : TSBoolean);
			private
		FButtonReset:TSScreenButton;
		FQuantityComboBox, FComboBoxDeep, FDifficultyComboBox:TSScreenComboBox;
		FTimerLabel, FLabebYouLose : TSScreenLabel;
		FComboBoxRespamn,FGroundComboBox:TSScreenComboBox;
			private
		FImageZombi,FImagePlayer,FImageSkull,FImageBlock,FImageBullet:TSImage;
		FImagesSize : TSLongWord;
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothFileUtils
	,SmoothMathUtils
	,SmoothCommon
	,SmoothBaseUtils
	,SmoothContextUtils
	;

{$OVERFLOWCHECKS OFF}

procedure TSKiller.DeleteRenderResources();
begin
SKill(FImageSkull);
SKill(FImageBlock);
SKill(FImageBullet);
SKill(FImageZombi);
SKill(FImagePlayer);
end;

procedure TSKiller.LoadRenderResources();
begin
InitImages(FImagesSize, True);
end;

function TSKillerGetColor(const FWay:LongWord):TSColor4f;
var 
	i:Byte;
begin
Result.Import(FWay/100,FWay/40,FWay/15,1);
Result/=1.6;
for i:=0 to 3 do
	if PSingle(@Result)[i]>1 then
		PSingle(@Result)[i]:=1;
end;

procedure TSScreenButton_Reset_OnChange(Button:TSScreenButton);
begin
with TSKiller(Button.FUserPointer1) do
	begin
	Reset;
	end;
end;

procedure TSKiller.CreateZombi(const ZombieID:LongWord);
var
	i,ii:LongWord;
begin
if FSkulls=nil then
	begin
	SetLength(FSkulls,1);
	FSkulls[High(FSkulls)].FPosition:=FZombies[ZombieID].FNowPosition;
	FSkulls[High(FSkulls)].FAlpha:=FQuantitySkulls;
	end
else
	begin
	for i:=0 to High(FSkulls) do
		FSkulls[i].FAlpha-=1;
	if Length(FSkulls)<FQuantitySkulls then
		begin
		SetLength(FSkulls,Length(FSkulls)+1);
		FSkulls[High(FSkulls)].FPosition:=FZombies[ZombieID].FNowPosition;
		FSkulls[High(FSkulls)].FAlpha:=FQuantitySkulls;
		end
	else
		begin
		if FSkullsNowPosition>=FQuantitySkulls-1 then
			FSkullsNowPosition:=0
		else
			FSkullsNowPosition+=1;
		FSkulls[FSkullsNowPosition].FPosition:=FZombies[ZombieID].FNowPosition;
		FSkulls[FSkullsNowPosition].FAlpha:=FQuantitySkulls;
		end;
	end;
repeat
FZombies[ZombieID].FPosition.Import(Random(FForestWidth),Random(FForestHeight));
ii:=0;
for i:=0 to High(FZombies) do
	if FZombies[i].FActive then
		if FZombies[i].FPosition=FZombies[ZombieID].FPosition then
			begin
			ii:=1;
			Break;
			end;
//writeln(FMaxWay);
until (ii=0) and (FYou<>FZombies[ZombieID].FPosition) and 
	(FArray[FZombies[ZombieID].FPosition.x,FZombies[ZombieID].FPosition.y].FWay<>FForestHeight*FForestWidth) and
	(FArray[FZombies[ZombieID].FPosition.x,FZombies[ZombieID].FPosition.y].FWay>=2) and
	(FArray[FZombies[ZombieID].FPosition.x,FZombies[ZombieID].FPosition.y].FType<>1);
FZombies[ZombieID].FOldPosition:=FZombies[ZombieID].FPosition;
FZombies[ZombieID].FDieInterval:=0;
FZombies[ZombieID].FActive:=True;
FZombies[ZombieID].FNowPosition:=SVertex2fImport(FZombies[ZombieID].FPosition.x*FR.x,FZombies[ZombieID].FPosition.y*FR.y);
end;

function TSKiller.TamNetZombie(const MayBeZombie: TSPoint2int32):Boolean;
var
	i:LongInt;
begin
Result:=False;
for i:=0 to High(FZombies) do
	if (FZombies[i].FPosition=MayBeZombie) and (FZombies[i].FActive) then
		begin
		Result:=True;
		Break;
		end;
end;

procedure TSKiller.Reset;inline;
begin
FreeGame;
InitGame;
end;
function TSKillerGetDiffic(const b:LongWord):LongWord;
begin
case b of
0:Result:=90;
1:Result:=71;
2:Result:=52;
3:Result:=44;
4:Result:=36;
5:Result:=28;
6:Result:=20;
7:Result:=15;
8:Result:=9;
9:Result:=3;
end;
end;

procedure TSScreenComboBox_CountZombies_OnChange(a,b:LongInt;Button:TSScreenComponent);
begin
with TSKiller(Button.FUserPointer1) do
	begin
	if a<>b then
		begin
		FreeGame;
		FStartDeep:=2**(b+3);
		InitGame;
		end;
	end;
end;

procedure TSScreenComboBox_DeepZombies_OnChange(a,b:LongInt;Button:TSScreenComponent);
var
	i:LongWord;
begin
with TSKiller(Button.FUserPointer1) do
	begin
	if a<>b then
		begin
		if 2**b<=Length(FZombies) then
			SetLength(FZombies,2**b)
		else
			begin
			i:=Length(FZombies);
			SetLength(FZombies,2**b);
			CreateZombies(i);
			end;
		MayByVictory;
		end;
	end;
end;

procedure TSScreenComboBox_Difficulty_OnChange(a,b:LongInt;Button:TSScreenComponent);
begin
with TSKiller(Button.FUserPointer1) do
	begin
	if a<>b then
		begin
		FInterval:=TSKillerGetDiffic(b);
		end;
	end;
end;
procedure TSScreenComboBox_GroundZombies_OnChange(a,b:LongInt;Button:TSScreenComponent);
begin
with TSKiller(Button.FUserPointer1) do
	begin
	if a<>b then
		begin
		case b of
		0:begin FGroundInt1:=10;FGroundInt2:=10;end;
		1:begin FGroundInt1:=10;FGroundInt2:=8;end;
		2:begin FGroundInt1:=10;FGroundInt2:=7;end;
		3:begin FGroundInt1:=10;FGroundInt2:=6;end;
		4:begin FGroundInt1:=10;FGroundInt2:=5;end;
		5:begin FGroundInt1:=10;FGroundInt2:=4;end;
		end;
		Reset;
		end;
	end;
end;

procedure TSScreenComboBox_RespamnZombies_OnChange(a,b:LongInt;Button:TSScreenComponent);
begin
with TSKiller(Button.FUserPointer1) do
	begin
	if a<>b then
		begin
		FRespamn:=Boolean(b);
		end;
	end;
end;

constructor TSKiller.Create(const VContext:ISContext);
var
	i:LongWord;
begin
inherited Create (VContext);

{$IFDEF MOBILE}
	FWayShift.Import(0,0);
	{$ENDIF}

FStartDeep:=8;
FSkulls:=nil;
FRespamn:=True;
FGroundInt1:=10;
FGroundInt2:=7;
FQuantitySkulls:=450;

FImageBlock:=nil;
FImageSkull:=nil;
FImageZombi:=nil;
FImagePlayer:=nil;
FImageBullet:=nil;

{FImageBlock:=TSImage.Create;
FImageBlock.Way:=STextureDirectory+DirectorySeparator+'Killer'+DirectorySeparator+'KKK1.png';
FImageBlock.Loading;

FImageSkull:=TSImage.Create;
FImageSkull.Way:=STextureDirectory+DirectorySeparator+'Killer'+DirectorySeparator+'KKK4.png';
FImageSkull.Loading;

FImageZombi:=TSImage.Create;
FImageZombi.Way:=STextureDirectory+DirectorySeparator+'Killer'+DirectorySeparator+'KKK0.png';
FImageZombi.Loading;

FImagePlayer:=TSImage.Create;
FImagePlayer.Way:=STextureDirectory+DirectorySeparator+'Killer'+DirectorySeparator+'KKK2.png';
FImagePlayer.Loading;

FImageBullet:=TSImage.Create;
FImageBullet.Way:=STextureDirectory+DirectorySeparator+'Killer'+DirectorySeparator+'KKK3.png';
FImageBullet.Loading;}

SetLength(FZombies,1);
FButtonReset:=TSScreenButton.Create;
Screen.CreateChild(FButtonReset);
Screen.LastChild.SetBounds(Render.Width-50,5,40,20);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='Reset';
FButtonReset.OnChange:=TSScreenComponentProcedure(@TSScreenButton_Reset_OnChange);
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;

FDifficultyComboBox:=TSScreenComboBox.Create;
Screen.CreateChild(FDifficultyComboBox);
Screen.LastChild.SetBounds(Render.Width-50-125-145,5,118+145,20);
Screen.LastChild.Anchors:=[SAnchRight];
(Screen.LastChild as TSScreenComboBox).CreateItem('Очень очень сильно легко');
(Screen.LastChild as TSScreenComboBox).CreateItem('Очень сильно легко');
(Screen.LastChild as TSScreenComboBox).CreateItem('Очень легко');
(Screen.LastChild as TSScreenComboBox).CreateItem('Легко');
(Screen.LastChild as TSScreenComboBox).CreateItem('Нормально');
(Screen.LastChild as TSScreenComboBox).CreateItem('Ну так, ничё');
(Screen.LastChild as TSScreenComboBox).CreateItem('Сложно');
(Screen.LastChild as TSScreenComboBox).CreateItem('Очень сложно');
(Screen.LastChild as TSScreenComboBox).CreateItem('Тяжко!');
(Screen.LastChild as TSScreenComboBox).CreateItem('Очень тяжко!!');
(Screen.LastChild as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@TSScreenComboBox_Difficulty_OnChange);
(Screen.LastChild as TSScreenComboBox).SelectItem:=4;
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;

FQuantityComboBox:=TSScreenComboBox.Create;
Screen.CreateChild(FQuantityComboBox);
Screen.LastChild.SetBounds(Render.Width-50-125-145-60,5,55,20);
Screen.LastChild.Anchors:=[SAnchRight];
for i:=0 to 8 do
	(Screen.LastChild as TSScreenComboBox).CreateItem(SStringToPChar(SStr(2**i)));
(Screen.LastChild as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@TSScreenComboBox_DeepZombies_OnChange);
(Screen.LastChild as TSScreenComboBox).SelectItem:=0;
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;


FComboBoxDeep:=TSScreenComboBox.Create;
Screen.CreateChild(FComboBoxDeep);
Screen.LastChild.SetBounds(Render.Width-50-125-145-60-60,5,55,20);
Screen.LastChild.Anchors:=[SAnchRight];
for i:=3 to 8 do
	(Screen.LastChild as TSScreenComboBox).CreateItem(SStringToPChar(SStr(2**i)));
(Screen.LastChild as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@TSScreenComboBox_CountZombies_OnChange);
(Screen.LastChild as TSScreenComboBox).SelectItem:=0;
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;

FComboBoxRespamn:=TSScreenComboBox.Create;
Screen.CreateChild(FComboBoxRespamn);
Screen.LastChild.SetBounds(Render.Width-50-125-145-60-60-130,5,125,20);
Screen.LastChild.Anchors:=[SAnchRight];
(Screen.LastChild as TSScreenComboBox).CreateItem('Респамн Выключен');
(Screen.LastChild as TSScreenComboBox).CreateItem('Респамн Включeн');
(Screen.LastChild as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@TSScreenComboBox_RespamnZombies_OnChange);
(Screen.LastChild as TSScreenComboBox).SelectItem:=1;
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;

FGroundComboBox:=TSScreenComboBox.Create;
Screen.CreateChild(FGroundComboBox);
Screen.LastChild.SetBounds(Render.Width-50-125-145-60-60-130-140,5,135,20);
Screen.LastChild.Anchors:=[SAnchRight];
(Screen.LastChild as TSScreenComboBox).CreateItem('Стенок нету');
(Screen.LastChild as TSScreenComboBox).CreateItem('Стенок мало');
(Screen.LastChild as TSScreenComboBox).CreateItem('Стенок немного');
(Screen.LastChild as TSScreenComboBox).CreateItem('Стенок немало');
(Screen.LastChild as TSScreenComboBox).CreateItem('Стенок много');
(Screen.LastChild as TSScreenComboBox).CreateItem('Стенки везде');
(Screen.LastChild as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@TSScreenComboBox_GroundZombies_OnChange);
(Screen.LastChild as TSScreenComboBox).SelectItem:=2;
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;

FTimerLabel := SCreateLabel(Screen, '', False, 10,Render.Height-25,Render.Width div 2,20, [SAnchBottom], True);
FTimerLabel.FUserPointer1:=Self;
FTimerLabel.TextColor.Import(0,0,0,1);

FLabebYouLose := SCreateLabel(Screen, SKillerStringLose, 5,Render.Height div 2 - 15,Render.Width-10,30, [SAnchBottom], False);
FLabebYouLose.FUserPointer1:=Self;
FLabebYouLose.TextColor.Import(0,0,0,1);

InitGame;
end;

procedure TSKiller.FreeGame;
var
	i:LongWord;
begin
for i:=0 to  High(FArray) do
	SetLength(FArray[i],0);
SetLength(FArray,0);
SetLength(FBullets,0);
SetLength(FSkulls,0);
end;

procedure TSKiller.CreateZombies(const o:LongWord = 0);
var
	i,ii,iii:LongWord;
begin
for i:=o to High(FZombies) do
	begin
	repeat
	FZombies[i].FPosition.x:=Random(Length(FArray));
	FZombies[i].FPosition.y:=Random(Length(FArray[0]));
	iii:=0;
	ii:=0;
	while ii<=i-1 do
		begin
		if FZombies[ii].FPosition=FZombies[i].FPosition then
			begin
			iii:=1;
			Break;
			end;
		ii+=1;
		end;
	until (iii=0) 
		{and (FArray[FZombies[i].FPosition.x][FZombies[i].FPosition.y].FWay<>FForestHeight*FForestHeight)} 
		and (FArray[FZombies[i].FPosition.x][FZombies[i].FPosition.y].FType=0);
	FZombies[i].FActive:=True;
	FZombies[i].FOldPosition:=FZombies[i].FPosition;
	FZombies[i].FDieInterval:=0;
	FZombies[i].FNowPosition:=SVertex2fImport(FZombies[i].FPosition.x*FR.x,FZombies[i].FPosition.y*FR.y);
	end;
end;

procedure TSKiller.InitImages(const VWidthHeight : TSLongWord; const VRadBool : TSBoolean);

procedure ProcessImage(var Image : TSImage; const ImageFileName : TSString; const BoundsSize : TSUInt32);
begin
if (Image=nil) or VRadBool then
	begin
	SKill(Image);
	Image := SCreateImageFromFile(Context, ImageFileName);
	Image.BitMap.SetBounds(BoundsSize, BoundsSize);
	Image.LoadTexture();
	end;
end;

const
	KillerImagePredPath = STextureDirectory + DirectorySeparator + 'Killer' + DirectorySeparator;
begin
ProcessImage(FImageBlock,  KillerImagePredPath + 'Block.sia',  VWidthHeight);
ProcessImage(FImageBullet, KillerImagePredPath + 'Bullet.sia', Iff(VWidthHeight > 64, 64, VWidthHeight));
ProcessImage(FImageZombi,  KillerImagePredPath + 'Zombie.sia', VWidthHeight);
ProcessImage(FImagePlayer, KillerImagePredPath + 'Player.sia',    VWidthHeight);
ProcessImage(FImageSkull,  KillerImagePredPath + 'Skull.sia',  VWidthHeight);
end;

procedure TSKiller.InitGame;
var
	i,ii:LongWord;
	OldFR:TSVertex2f = (x:0;y:0);
begin
FChanget:=True;
FActive:=True;
FStartDeepHeight:=Trunc(((Render.Height/Render.Width)*FStartDeep))+1;
FSkullsNowPosition:=FQuantitySkulls;

FBulletsGos:=0;
FHowManyZombiesYouKill:=0;
FMaxWay:=0;
FBullets:=nil;
SetLength(FBullets,0);
FInterval:=TSKillerGetDiffic(FDifficultyComboBox.SelectItem);
SetLength(FArray,FStartDeep);
FForestWidth:=FStartDeep;
FForestHeight:=FStartDeepHeight;
for i:=0 to High(FArray) do
	begin
	SetLength(FArray[i],FStartDeepHeight);
	FillChar(FArray[i][0],Length(FArray[i])*Sizeof(FArray[0,0]),0);
	end;
for i:=0 to High(FArray) do
	for ii:=0 to High(FArray[i]) do
		begin
		FArray[i][ii].FType:=Random(FGroundInt1);
		if FArray[i][ii].FType>FGroundInt2 then
			FArray[i][ii].FType:=1
		else
			FArray[i][ii].FType:=0;
		end;
for i:=0 to High(FArray) do
	for ii:=0 to High(FArray[i]) do
		FArray[i][ii].FWay:=FForestHeight*FForestWidth;
CreateZombies;
repeat
FYou.x:=Random(Length(FArray));
FYou.y:=Random(Length(FArray[0]));
ii:=0;
for i:=0 to High(FZombies) do
	if FZombies[i].FPosition=FYou then
		begin
		ii:=1;
		Break;
		end;
until (FArray[FYou.x][FYou.y].FType=0) and (ii=0);

OldFR:=FR;
FR.Import(Render.Width/Length(FArray),Render.Height/Length(FArray[0]));

if FR.x>FR.y then
	i:=Trunc(FR.x)
else
	i:=Trunc(FR.y);
if i>127 then ii:=128
else if i>63 then ii:=64
else if i>31 then ii:=32
else if i>15 then ii:=16
else if i>7 then ii:=8
else ii:=4;

FImagesSize := ii;
InitImages(ii, Abs(Abs(OldFR)-Abs(FR))>SZero);

FDataTime.Get;
Calculate;
FTimer.Get;
FLabebYouLose.Visible:=False;
FLabebYouLose.VisibleTimer:=0;
FBulletDataTime2.Get;
FVictory:=False;

FLabebYouLose.Caption:=SKillerStringLose;
FTimerLabel.Caption:='0 сек';
MayByVictory;
FDTInterval:=0;
end;

destructor TSKiller.Destroy;
begin
FreeGame;
SetLength(FZombies,0);
FLabebYouLose.Destroy;
FDifficultyComboBox.Destroy;
FQuantityComboBox.Destroy;
FComboBoxDeep.Destroy;
FButtonReset.Destroy;
FComboBoxRespamn.Destroy;
FGroundComboBox.Destroy;
FTimerLabel.Destroy;

SKill(FImageSkull);
SKill(FImageBlock);
SKill(FImageBullet);
SKill(FImageZombi);
SKill(FImagePlayer);
inherited;
end;

class function TSKiller.ClassName:string;
begin
Result := 'Киллер';
end;

procedure TSKiller.DoQuad(const i,ii:LongWord;const artype : TSKillerArrayType);inline;
type
	TSKQuadArColor = packed array[0..3] of TSColor4f;

function GetColorArrayFrom(const x, y, thisway : TSLongWord):TSKQuadArColor;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure ProvOne(const One1 : TSBoolean;var One2 : TSBoolean; const One1W, One2W : TSLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if One2 and One1 then
	if One2W > One1W then
		One2 := False;
end;

var
	ThisColor, DecColor, IncColor : TSColor4f;
	CanMoveRight : TSBoolean = False;
	CanMoveUp : TSBoolean = False;
	CanMoveLeft : TSBoolean = False;
	CanMoveDown : TSBoolean = False;
	LeftDeep, RightDeep, UpDeep, DownDeep : TSLongWord;
begin
ThisColor := TSKillerGetColor(thisway);
CanMoveRight := (x < FStartDeep - 1) and (FArray[x+1][y].FType <> 1);
CanMoveLeft := (x > 0) and (FArray[x-1][y].FType <> 1);
CanMoveUp := (y > 0) and (FArray[x][y-1].FType <> 1);
CanMoveDown := (x < FStartDeepHeight - 1) and (FArray[x][y+1].FType <> 1);
if CanMoveRight then
	RightDeep := FArray[x+1][y].FWay;
if CanMoveLeft then
	LeftDeep := FArray[x-1][y].FWay;
if CanMoveUp then
	UpDeep := FArray[x][y-1].FWay;
if CanMoveDown then
	DownDeep := FArray[x][y+1].FWay;
DecColor := TSKillerGetColor(thisway - 1);
if CanMoveRight then
	begin
	ProvOne(CanMoveRight, CanMoveLeft, RightDeep, LeftDeep);
	ProvOne(CanMoveRight, CanMoveDown, RightDeep, DownDeep);
	ProvOne(CanMoveRight, CanMoveUp, RightDeep, UpDeep);
	end;
if CanMoveUp then
	begin
	ProvOne(CanMoveUp, CanMoveLeft,  UpDeep, LeftDeep);
	ProvOne(CanMoveUp, CanMoveDown,  UpDeep, DownDeep);
	ProvOne(CanMoveUp, CanMoveRight, UpDeep, RightDeep);
	end;
if CanMoveDown then
	begin
	ProvOne(CanMoveDown, CanMoveLeft,  DownDeep, LeftDeep);
	ProvOne(CanMoveDown, CanMoveUp,    DownDeep, UpDeep);
	ProvOne(CanMoveDown, CanMoveRight, DownDeep, RightDeep);
	end;
if CanMoveLeft then
	begin
	ProvOne(CanMoveLeft, CanMoveRight, LeftDeep, RightDeep);
	ProvOne(CanMoveLeft, CanMoveDown,  LeftDeep, DownDeep);
	ProvOne(CanMoveLeft, CanMoveUp,    LeftDeep, UpDeep);
	end;
if CanMoveRight and CanMoveDown then
	begin
	IncColor := ThisColor;
	Result[0] := IncColor;
	Result[1] := ThisColor;
	Result[2] := DecColor;
	Result[3] := ThisColor;
	end
else if CanMoveRight and CanMoveUp then
	begin
	IncColor := ThisColor;
	Result[0] := ThisColor;
	Result[1] := DecColor;
	Result[2] := ThisColor;
	Result[3] := IncColor;
	end
else if CanMoveLeft and CanMoveDown then
	begin
	IncColor := ThisColor;
	Result[0] := ThisColor;
	Result[1] := IncColor;
	Result[2] := ThisColor;
	Result[3] := DecColor;
	end
else if CanMoveLeft and CanMoveUp then
	begin
	IncColor := ThisColor;
	Result[0] := DecColor;
	Result[1] := ThisColor;
	Result[2] := IncColor;
	Result[3] := ThisColor;
	end
else
	begin
	if CanMoveRight then
		begin
		Result[0] := ThisColor;
		Result[1] := DecColor;
		Result[2] := DecColor;
		Result[3] := ThisColor;
		end
	else if CanMoveLeft then
		begin
		Result[0] := DecColor;
		Result[1] := ThisColor;
		Result[2] := ThisColor;
		Result[3] := DecColor;
		end
	else if CanMoveUp then
		begin
		Result[0] := DecColor;
		Result[1] := DecColor;
		Result[2] := ThisColor;
		Result[3] := ThisColor;
		end
	else if CanMoveDown then
		begin
		Result[0] := ThisColor;
		Result[1] := ThisColor;
		Result[2] := DecColor;
		Result[3] := DecColor;
		end
	else
		fillchar(Result,SizeOf(Result), 0);
	end;
end;

var
	NeedsExtension : TSBoolean = True;
	Colors : TSKQuadArColor;

begin
if artype.FType=2 then
	begin
	Render.Color4f(0.8,0,0.8,1);
	NeedsExtension := False;
	end
else if artype.FWay=FForestHeight*FForestWidth then
	begin
	Render.Color(SColor4fFromUInt32($FFFF00));
	NeedsExtension := False;
	end;
if not NeedsExtension then
	begin
	Render.Vertex2f(FR.x*i,FR.y*ii);
	Render.Vertex2f(FR.x*i,FR.y*(ii+1));
	Render.Vertex2f(FR.x*(i+1),FR.y*(ii+1));
	Render.Vertex2f(FR.x*(i+1),FR.y*ii);
	end
else
	begin
	if artype.FWay = 0 then
		fillchar(Colors, SizeOf(Colors), 0)
	else
		Colors := GetColorArrayFrom(i, ii, artype.FWay);
	Render.Color(Colors[0]);
	Render.Vertex2f(FR.x*i,FR.y*ii);
	Render.Color(Colors[1]);
	Render.Vertex2f(FR.x*(i+1),FR.y*ii);
	Render.Color(Colors[2]);
	Render.Vertex2f(FR.x*(i+1),FR.y*(ii+1));
	Render.Color(Colors[3]);
	Render.Vertex2f(FR.x*i,FR.y*(ii+1));
	end;
end;

function TSKiller.Proverka(const KPos: TSPoint2int32;const b:Byte):Boolean;inline;
begin
Result:=(KPos.x>=0)and
		(KPos.y>=0) and
		(KPos.x<FForestWidth) and 
		(KPos.y<FForestHeight) and
 (FArray[KPos.x,KPos.y].FType=b);
end;

procedure TSKiller.Calculate;
var
	i,ii,iii:LongWord;
procedure Rec(var FArray:TSKillerArray;NewMyPosition: TSPoint2int32;const Dlinna:LongWord );
begin
if Proverka(NewMyPosition,0) and (FArray[NewMyPosition.x,NewMyPosition.y].FWay>Dlinna) then
	begin
	if FMaxWay<Dlinna then
		FMaxWay:=Dlinna;
	FArray[NewMyPosition.x,NewMyPosition.y].FWay:=Dlinna;
	NewMyPosition.x+=1;
	Rec(FArray,NewMyPosition,Dlinna+1);
	NewMyPosition.x-=2;
	Rec(FArray,NewMyPosition,Dlinna+1);
	NewMyPosition.x+=1;
	NewMyPosition.y+=1;
	Rec(FArray,NewMyPosition,Dlinna+1);
	NewMyPosition.y-=2;
	Rec(FArray,NewMyPosition,Dlinna+1);
	NewMyPosition.y+=1;
	end;
end;
begin
FMaxWay:=0;
iii:=FForestHeight*FForestWidth;
for i:=0 to FForestWidth-1 do
	for ii:=0 to FForestHeight-1 do
		if (FArray[i][ii].FType=0) and (FArray[i][ii].FWay<iii) then
			FArray[i][ii].FWay+=1;
Rec(FArray,FYou,0);
FChanget:=False;
end;

procedure TSKiller.GoZombies;
var
	i,ii,iii,iiii,iiiii,iiiiii:LongWord;
	Any: TSPoint2int32;
begin
for i:=0 to High(FZombies) do
	if FZombies[i].FActive and (FZombies[i].FPosition=FYou) then
		begin
		FActive:=False;
		FZombies[i].FDieInterval:=FInterval;
		Exit;
		end;
Calculate;
for iiiiii:=0 to High(FZombies) do
	if FZombies[iiiiii].FActive then
	begin
	iii:=FForestHeight*FForestWidth;
	if not (FArray[FZombies[iiiiii].FPosition.x,FZombies[iiiiii].FPosition.y].FWay=iii) then
		begin
		for i:=0 to 2 do
			for ii:=0 to 2 do
				if ((i=1)or(ii=1)) then
					begin
					Any.Import(FZombies[iiiiii].FPosition.x+i-1,FZombies[iiiiii].FPosition.y+ii-1);
					if Proverka(Any,0) and (not TamNetZombie(Any)) then
						begin
						if FArray[Any.x][Any.y].FWay<iii then
							begin
							iii:=FArray[Any.x][Any.y].FWay;
							iiii:=Any.x;
							iiiii:=Any.y;
							end
						else
							if FArray[Any.x][Any.y].FWay=iii then
								if Boolean(random(2)) then
									begin
									iii:=FArray[Any.x][Any.y].FWay;
									iiii:=Any.x;
									iiiii:=Any.y;
									end;
						end;
					end;
		if (iii<>FForestHeight*FForestWidth) then
			begin
			FZombies[iiiiii].FOldPosition:=FZombies[iiiiii].FPosition;
			FZombies[iiiiii].FPosition.Import(iiii,iiiii);
			end;
		end;
	end;
end;

procedure TSKiller.MayByVictory;
var
	i:LongWord;
begin
if FVictory then
	Exit;
for i:=0 to High(FZombies) do
	begin
	if ((FZombies[i].FActive) and (not((FArray[FZombies[i].FPosition.x,FZombies[i].FPosition.y].FWay=FForestHeight*FForestWidth))))then 
		begin
		FVictory:=True;
		Break;
		end;
	end;
FVictory:= not FVictory;
if FVictory then
	FActive:=False;
if FVictory then
	FLabebYouLose.Caption:=SKillerStringWin;
end;

function TSKiller.IsBulletKillZombie(const Bullet:TSVertex2f;const Zombie:LongWord):Boolean;
begin
Result:=Abs(SVertex2fImport(Bullet.x*FR.x,Bullet.y*FR.y)-FZombies[Zombie].FNowPosition)<Abs(FR)/3.9;
end;

procedure TSKiller.Paint();
var
	i,ii,iii:LongWord;
	FDT:TSDateTime;
	Vtx1,Vtx2:TSVertex2f;
	Any : TSPoint2int32;
begin
if Context.KeyPressed and (Context.KeyPressedType=SDownKey) and (Context.KeyPressedByte=82) then	
	Reset;
if FActive then
	begin
	{$IFDEF MOBILE}
	if Context.CursorKeysPressed(SLeftCursorButton) then
		begin
		Any := Context.CursorPosition(SDeferenseCursorPosition);
		FWayShift.x += Any.x;
		FWayShift.y += Any.y;
		end;
	if FWayShift.x <= - FR.x then
		begin
		if FYou.x<>0 then
			if FArray[FYou.x-1,FYou.y].FType=0 then
				begin
				FChanget:=True;
				FYou.x-=1;
				end;
		FWayShift.x += FR.x;
		end;
	if FWayShift.y <= - FR.y then
		begin
		if FYou.y<>0 then
			if FArray[FYou.x,FYou.y-1].FType=0 then
				begin
				FYou.y-=1;
				FChanget:=True;
				end;
		FWayShift.y += FR.y;
		end;
	if FWayShift.x >=  FR.x then
		begin
		if FYou.x<>High(FArray) then
			if FArray[FYou.x+1,FYou.y].FType=0 then
				begin
				FYou.x+=1;
				FChanget:=True;
				end;
		FWayShift.x -= FR.x;
		end;
	if FWayShift.y >= FR.y then
		begin
		if FYou.y<>High(FArray[0]) then
			if FArray[FYou.x,FYou.y+1].FType=0 then
				begin
				FYou.y+=1;
				FChanget:=True;
				end;
		FWayShift.y -= FR.y;
		end;
	if (Context.CursorKeyPressed=SLeftCursorButton)and (Context.CursorKeyPressedType=SUpKey) then
		for i:=0 to 2 do
				for ii:=0 to 2 do
					if ((i=1) or (ii=1)) and (not ((i=1) and (ii=1))) then
						begin
						Any.Import(FYou.x+i-1,FYou.y+ii-1);
						if Proverka(Any,0) then
							begin
							FBulletsGos+=1;
							SetLength(FBullets,Length(FBullets)+1);
							FBullets[High(FBullets)][0].Import(Any.x,Any.y);
							FBullets[High(FBullets)][1].Import(i-1,ii-1);
							FBullets[High(FBullets)][0]-=FBullets[High(FBullets)][1]*0.3;
							end;
						end;
	{$ELSE}
	if Context.KeyPressed and (Context.KeyPressedType=SDownKey) then
		begin
		case Context.KeyPressedByte of
		37,65: if FYou.x<>0 then
			if FArray[FYou.x-1,FYou.y].FType=0 then
				FYou.x-=1;
		38,87: if FYou.y<>0 then
			if FArray[FYou.x,FYou.y-1].FType=0 then
				FYou.y-=1;
		39,68: if FYou.x<>High(FArray) then
			if FArray[FYou.x+1,FYou.y].FType=0 then
				FYou.x+=1;
		40,83: if FYou.y<>High(FArray[0]) then
			if FArray[FYou.x,FYou.y+1].FType=0 then
				FYou.y+=1;
		32://Spase
			begin
			for i:=0 to 2 do
				for ii:=0 to 2 do
					if ((i=1) or (ii=1)) and (not ((i=1) and (ii=1))) then
						begin
						Any.Import(FYou.x+i-1,FYou.y+ii-1);
						if Proverka(Any,0) then
							begin
							FBulletsGos+=1;
							SetLength(FBullets,Length(FBullets)+1);
							FBullets[High(FBullets)][0].Import(Any.x,Any.y);
							FBullets[High(FBullets)][1].Import(i-1,ii-1);
							FBullets[High(FBullets)][0]-=FBullets[High(FBullets)][1]*0.3;
							end;
						end;
			end;
		end;
		if Context.KeyPressedByte in [37,65,38,87,39,68,40,83] then
			FChanget:=True;
		end;
	{$ENDIF}
	
	if FChanget then
		Calculate;
	
	FDT.Get;
	FTimer2:=FDT;
	FDTInterval:=(FDT-FDataTime).GetPastMilliseconds;
	if FDTInterval>FInterval then
		begin
		GoZombies;
		FDT.Get;
		FDataTime:=FDT;
		FDTInterval:=0;
		end;
	
	FBulletDataTime1.Get;
	if Length(FBullets)>0 then
		begin
		ii:=(FBulletDataTime1-FBulletDataTime2).GetPastMilliseconds;
		for i:=0 to High(FBullets) do
			FBullets[i][0]+=FBullets[i][1]*ii/17;
		
		i:=0;
		while i<=High(FBullets) do
			begin
			Any.Import(Round(FBullets[i][0].x),Round(FBullets[i][0].y));
			if not Proverka(Any,0) then
				begin
				if i=High(FBullets) then
					SetLength(FBullets,Length(FBullets)-1)
				else
					begin
					for ii:=i+1 to High(FBullets) do
						FBullets[ii-1]:=FBullets[ii];
					SetLength(FBullets,Length(FBullets)-1);
					end;
				end;
			i+=1;
			end;
		
		if Length(FBullets)>0 then
			begin
			//for i:=0 to High(FBullets) do
			i:=0;
			while i<=High(FBullets) do
				begin
				//Any.Import(Round(FBullets[i][0].x),Round(FBullets[i][0].y));
				for ii:=0 to High(FZombies) do
					if FZombies[ii].FActive and IsBulletKillZombie(FBullets[i][0],ii) then//(Any=FZombies[ii].FPosition) then
						begin
						FZombies[ii].FActive:=False;
						FZombies[ii].FDieInterval:=FDTInterval;
						for iii:=i+1 to High(FBullets) do
							FBullets[iii-1]:=FBullets[iii];
						SetLength(FBullets,Length(FBullets)-1);
						i-=1;
						if FRespamn then
							CreateZombi(ii);
						FHowManyZombiesYouKill+=1;
						Break;
						end;
				i+=1;
				end;
			end;
		MayByVictory;
		end;
	FBulletDataTime2:=FBulletDataTime1;
	
	FTimerLabel.Caption:=
		SStringToPChar(SSecondsToStringTime((FTimer2-FTimer).GetPastSeconds)+', '+
		SStr(FHowManyZombiesYouKill)+' зомби убито, '+SStr(FBulletsGos)+' пуль выпущено');
	end
else
	begin
	FLabebYouLose.Visible:=True;
	//FDTInterval:=FInterval;
	end;

Render.InitMatrixMode(S_2D);
Render.BeginScene(SR_QUADS);
for i:=0 to High(FArray) do
	for ii:=0 to High(FArray[0]) do
		begin
		if FArray[i][ii].FType=1 then
			begin
			Render.EndScene;
			Render.Color3f(1,1,1);
			Vtx1.Import(i*FR.x,ii*FR.y);
			Vtx2.Import((i+1)*FR.x,(ii+1)*FR.y);
			FImageBlock.DrawImageFromTwoVertex2f(Vtx1,Vtx2,True,S_2D);
			Render.BeginScene(SR_QUADS);
			end
		else
			DoQuad(i,ii,FArray[i][ii]);
		end;
Render.EndScene;


if FSkulls<>nil then
	for i:=0 to High(FSkulls) do
		begin
		Render.Color4f(1,0.12,0.12,(FSkulls[i].FAlpha/FQuantitySkulls)*0.7);
		FImageSkull.DrawImageFromTwoVertex2f(FSkulls[i].FPosition,FSkulls[i].FPosition+FR,True,S_2D);
		end;

Render.Color4f(0.8,0.1,0.1,0.8);
for i:=0 to high(FZombies) do
	if not FZombies[i].FActive then
		FImageSkull.DrawImageFromTwoVertex2f(FZombies[i].FNowPosition,FZombies[i].FNowPosition+FR,True,S_2D);

Render.Color3f(1,1,1);
if FActive then
	for i:=0 to high(FZombies) do
		begin
		if FZombies[i].FActive then
			begin
			FZombies[i].FNowPosition.Import(
				FR.x * ((FZombies[i].FPosition.x-FZombies[i].FOldPosition.x)*(FDTInterval/FInterval)+FZombies[i].FOldPosition.x),
				FR.y * ((FZombies[i].FPosition.y-FZombies[i].FOldPosition.y)*(FDTInterval/FInterval)+FZombies[i].FOldPosition.y)
				);
			FImageZombi.DrawImageFromTwoVertex2f(FZombies[i].FNowPosition,FZombies[i].FNowPosition+FR,True,S_2D);
			end;
		end
else
	for i:=0 to high(FZombies) do
		if FZombies[i].FActive then
			begin
			FZombies[i].FNowPosition.Import(
				FR.x*FZombies[i].FPosition.x,
				FR.y*FZombies[i].FPosition.y);
			FImageZombi.DrawImageFromTwoVertex2f(FZombies[i].FNowPosition,FZombies[i].FNowPosition+FR,True,S_2D);
			end;

Vtx1.Import(FYou.x*FR.x,FYou.y*FR.y);
if (not FActive) and (not FVictory) then
	begin
	Render.Color3f(0.1,0.9,0.1);
	FImageSkull.DrawImageFromTwoVertex2f(Vtx1,Vtx1+FR,True,S_2D);
	end
else
	begin
	Render.Color3f(1,1,1);
	FImagePlayer.DrawImageFromTwoVertex2f(Vtx1,Vtx1+FR,True,S_2D);
	end;


Render.Color3f(1,1,1);
if (FBullets<>nil) and (Length(FBullets)>0) then
for i:=0 to High(FBullets) do
	begin
	Vtx1.Import(FBullets[i][0].x*FR.x,FBullets[i][0].y*FR.y);
	if FBullets[i][1].x>0 then
		FImageBullet.DrawImageFromTwoVertex2f(Vtx1,Vtx1+FR,True,S_2D)
	else
		if FBullets[i][1].x<0 then
			FImageBullet.DrawImageFromTwoVertex2f(Vtx1,Vtx1+FR,True,S_2D,2)
		else
			if FBullets[i][1].y>0 then
				FImageBullet.DrawImageFromTwoVertex2f(Vtx1,Vtx1+FR,True,S_2D,3)
			else
				FImageBullet.DrawImageFromTwoVertex2f(Vtx1,Vtx1+FR,True,S_2D,1);
	end;
	
if not FActive then
	begin
	Render.BeginScene(SR_QUADS);
	if FVictory then
		Render.Color4f(0,1,0,FLabebYouLose.VisibleTimer)
	else
		Render.Color4f(1,0,0,FLabebYouLose.VisibleTimer);
	
	Render.Vertex2f(Render.Width/2 - 300,Render.Height/2-100);
	Render.Vertex2f(Render.Width/2 + 300,Render.Height/2-100);
	Render.Vertex2f(Render.Width/2 + 300,Render.Height/2+100);
	Render.Vertex2f(Render.Width/2 - 300,Render.Height/2+100);

	Render.Vertex2f(0,Render.Height-25);
	Render.Vertex2f(Render.Width,Render.Height-25);
	Render.Vertex2f(Render.Width,Render.Height);
	Render.Vertex2f(0,Render.Height);
	Render.EndScene();
	end;
end;

initialization
begin
SRegisterDrawClass(TSKiller);
end;

end.
