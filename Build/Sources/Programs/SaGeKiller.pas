{$INCLUDE SaGe.inc}

unit SaGeKiller;

interface

uses
	SaGeCommon
	,SaGeMesh
	,SaGeUtils
	,SaGeBase
	,SaGeBased
	,SaGeContext
	,SaGeScreen
	,SaGeRender
	,SaGeImages
	,SaGeCommonClasses
	,SaGeRenderConstants
	,SaGeScreenBase
	;

type
	TSGKillerArrayType = packed record
		FType:Byte;
		FWay:LongWord;
		end;
	
	TSGKillerArray = packed array of
		packed array of
			TSGKillerArrayType;
const
	TSGKillerStringWin = 'Ты выиграл!!!';
	TSGKillerStringLose = 'Ты проиграл...';
type
	TSGKiller=class(TSGDrawable)
			public
		constructor Create(const VContext:ISGContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Paint;override;
		procedure DeleteDeviceResourses();override;
		procedure LoadDeviceResourses();override;
			private
		FStartDeep,FStartDeepHeight:LongWord;
		FArray:TSGKillerArray;
		FYou: TSGPoint2int32;
		FZombies:packed array of
			packed record
			FPosition: TSGPoint2int32;
			FActive:Boolean;
			FOldPosition: TSGPoint2int32;
			FDieInterval:single;
			FNowPosition:TSGVertex2f;
			end;
		FHowManyZombiesYouKill:LongWord;
		FMaxWay:LongWord;
		FR:TSGVertex2f;
		FDataTime:TSGDataTime;
		FInterval:LongWord;
		FForestWidth,FForestHeight:LongWord;
		FChanget:Boolean;
		FTimer:TSGDataTime;
		FTimer2,FBulletDataTime1,FBulletDataTime2:TSGDataTime;
		FActive:Boolean; //+
		FVictory:Boolean;//+
		FBullets:packed array of
			packed array[0..1] of
				TSGVertex2f; //+
		FDTInterval:LongWord;
		FGroundInt1,FGroundInt2:LongWord; //+
		FRespamn:Boolean; //+
		FSkulls:packed array of 
			packed record 
			FPosition:TSGVertex2f;
			FAlpha:LongWord;
			end; //+
		FQuantitySkulls:LongWord;  //+
		FSkullsNowPosition:LongWord; //+
		
		FGun:
			packed record
			//FType:Byte;
			FTimeFire,FTimeRe,FPatrones,FPatronesAll,FPatronesNow:LongWord;
			end; //-
		
		FBulletsGos:LongWord;
		{$IFDEF MOBILE}
			FWayShift : TSGVertex2f;
			{$ENDIF}
			private
		procedure DoQuad(const i,ii:LongWord;const artype : TSGKillerArrayType);inline;
		procedure GoZombies;
		function Proverka(const KPos: TSGPoint2int32;const b:Byte):Boolean;inline;
		procedure Reset;inline;
		procedure FreeGame;
		procedure InitGame;
		function TamNetZombie(const MayBeZombie: TSGPoint2int32):Boolean;
		procedure Calculate;
		procedure CreateZombi(const ZombieID:LongWord);
		procedure MayByVictory;
		procedure CreateZombies(const o:LongWord = 0);
		function IsBulletKillZombie(const Bullet:TSGVertex2f;const Zombie:LongWord):Boolean;
		procedure InitImages(const VWidthHeight : TSGLongWord; const VRadBool : TSGBoolean);
			private
		FButtonReset:TSGButton;
		FQuantityComboBox,FComboBoxDeep,FDifficultyComboBox:TSGComboBox;
		FTimerLabel,FLabebYouLose:TSGLabel;
		FComboBoxRespamn,FGroundComboBox:TSGComboBox;
			private
		FImageZombi,FImageYou,FImageSkull,FImageBlock,FImageBullet:TSGImage;
		FImagesSize : TSGLongWord;
		end;

implementation

{$OVERFLOWCHECKS OFF}

procedure TSGKiller.DeleteDeviceResourses();
begin
SGKillImage(FImageSkull);
SGKillImage(FImageBlock);
SGKillImage(FImageBullet);
SGKillImage(FImageZombi);
SGKillImage(FImageYou);
end;

procedure TSGKiller.LoadDeviceResourses();
begin
InitImages(FImagesSize, True);
end;

function TSGKillerGetColor(const FWay:LongWord):TSGColor4f;
var 
	i:Byte;
begin
Result.Import(FWay/100,FWay/40,FWay/15,1);
Result/=1.6;
for i:=0 to 3 do
	if PSingle(@Result)[i]>1 then
		PSingle(@Result)[i]:=1;
end;

procedure TSGButton_Reset_OnChange(Button:TSGButton);
begin
with TSGKiller(Button.FUserPointer1) do
	begin
	Reset;
	end;
end;

procedure TSGKiller.CreateZombi(const ZombieID:LongWord);
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
FZombies[ZombieID].FNowPosition:=SGVertex2fImport(FZombies[ZombieID].FPosition.x*FR.x,FZombies[ZombieID].FPosition.y*FR.y);
end;

function TSGKiller.TamNetZombie(const MayBeZombie: TSGPoint2int32):Boolean;
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

procedure TSGKiller.Reset;inline;
begin
FreeGame;
InitGame;
end;
function TSGKillerGetDiffic(const b:LongWord):LongWord;
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

procedure TSGComboBox_CountZombies_OnChange(a,b:LongInt;Button:TSGComponent);
begin
with TSGKiller(Button.FUserPointer1) do
	begin
	if a<>b then
		begin
		FreeGame;
		FStartDeep:=2**(b+3);
		InitGame;
		end;
	end;
end;

procedure TSGComboBox_DeepZombies_OnChange(a,b:LongInt;Button:TSGComponent);
var
	i:LongWord;
begin
with TSGKiller(Button.FUserPointer1) do
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

procedure TSGComboBox_Difficulty_OnChange(a,b:LongInt;Button:TSGComponent);
begin
with TSGKiller(Button.FUserPointer1) do
	begin
	if a<>b then
		begin
		FInterval:=TSGKillerGetDiffic(b);
		end;
	end;
end;
procedure TSGComboBox_GroundZombies_OnChange(a,b:LongInt;Button:TSGComponent);
begin
with TSGKiller(Button.FUserPointer1) do
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

procedure TSGComboBox_RespamnZombies_OnChange(a,b:LongInt;Button:TSGComponent);
begin
with TSGKiller(Button.FUserPointer1) do
	begin
	if a<>b then
		begin
		FRespamn:=Boolean(b);
		end;
	end;
end;

constructor TSGKiller.Create(const VContext:ISGContext);
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
FImageYou:=nil;
FImageBullet:=nil;

{FImageBlock:=TSGImage.Create;
FImageBlock.Way:=SGTextureDirectory+Slash+'Killer'+Slash+'KKK1.png';
FImageBlock.Loading;

FImageSkull:=TSGImage.Create;
FImageSkull.Way:=SGTextureDirectory+Slash+'Killer'+Slash+'KKK4.png';
FImageSkull.Loading;

FImageZombi:=TSGImage.Create;
FImageZombi.Way:=SGTextureDirectory+Slash+'Killer'+Slash+'KKK0.png';
FImageZombi.Loading;

FImageYou:=TSGImage.Create;
FImageYou.Way:=SGTextureDirectory+Slash+'Killer'+Slash+'KKK2.png';
FImageYou.Loading;

FImageBullet:=TSGImage.Create;
FImageBullet.Way:=SGTextureDirectory+Slash+'Killer'+Slash+'KKK3.png';
FImageBullet.Loading;}

SetLength(FZombies,1);
FButtonReset:=TSGButton.Create;
SGScreen.CreateChild(FButtonReset);
SGScreen.LastChild.SetBounds(Context.Width-50,5,40,20);
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='Reset';
FButtonReset.OnChange:=TSGComponentProcedure(@TSGButton_Reset_OnChange);
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FDifficultyComboBox:=TSGComboBox.Create;
SGScreen.CreateChild(FDifficultyComboBox);
SGScreen.LastChild.SetBounds(Context.Width-50-125-145,5,118+145,20);
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.AsComboBox.CreateItem('Очень очень сильно легко');
SGScreen.LastChild.AsComboBox.CreateItem('Очень сильно легко');
SGScreen.LastChild.AsComboBox.CreateItem('Очень легко');
SGScreen.LastChild.AsComboBox.CreateItem('Легко');
SGScreen.LastChild.AsComboBox.CreateItem('Нормально');
SGScreen.LastChild.AsComboBox.CreateItem('Ну так, ничё');
SGScreen.LastChild.AsComboBox.CreateItem('Сложно');
SGScreen.LastChild.AsComboBox.CreateItem('Очень сложно');
SGScreen.LastChild.AsComboBox.CreateItem('Тяжко!');
SGScreen.LastChild.AsComboBox.CreateItem('Очень тяжко!!');
SGScreen.LastChild.AsComboBox.CallBackProcedure:=TSGComboBoxProcedure(@TSGComboBox_Difficulty_OnChange);
SGScreen.LastChild.AsComboBox.SelectItem:=4;
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FQuantityComboBox:=TSGComboBox.Create;
SGScreen.CreateChild(FQuantityComboBox);
SGScreen.LastChild.SetBounds(Context.Width-50-125-145-60,5,55,20);
SGScreen.LastChild.Anchors:=[SGAnchRight];
for i:=0 to 8 do
	SGScreen.LastChild.AsComboBox.CreateItem(SGStringToPChar(SGStr(2**i)));
SGScreen.LastChild.AsComboBox.CallBackProcedure:=TSGComboBoxProcedure(@TSGComboBox_DeepZombies_OnChange);
SGScreen.LastChild.AsComboBox.SelectItem:=0;
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;


FComboBoxDeep:=TSGComboBox.Create;
SGScreen.CreateChild(FComboBoxDeep);
SGScreen.LastChild.SetBounds(Context.Width-50-125-145-60-60,5,55,20);
SGScreen.LastChild.Anchors:=[SGAnchRight];
for i:=3 to 8 do
	SGScreen.LastChild.AsComboBox.CreateItem(SGStringToPChar(SGStr(2**i)));
SGScreen.LastChild.AsComboBox.CallBackProcedure:=TSGComboBoxProcedure(@TSGComboBox_CountZombies_OnChange);
SGScreen.LastChild.AsComboBox.SelectItem:=0;
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FComboBoxRespamn:=TSGComboBox.Create;
SGScreen.CreateChild(FComboBoxRespamn);
SGScreen.LastChild.SetBounds(Context.Width-50-125-145-60-60-130,5,125,20);
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.AsComboBox.CreateItem('Респамн Выключен');
SGScreen.LastChild.AsComboBox.CreateItem('Респамн Включeн');
SGScreen.LastChild.AsComboBox.CallBackProcedure:=TSGComboBoxProcedure(@TSGComboBox_RespamnZombies_OnChange);
SGScreen.LastChild.AsComboBox.SelectItem:=1;
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FGroundComboBox:=TSGComboBox.Create;
SGScreen.CreateChild(FGroundComboBox);
SGScreen.LastChild.SetBounds(Context.Width-50-125-145-60-60-130-140,5,135,20);
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.AsComboBox.CreateItem('Стенок нету');
SGScreen.LastChild.AsComboBox.CreateItem('Стенок мало');
SGScreen.LastChild.AsComboBox.CreateItem('Стенок немного');
SGScreen.LastChild.AsComboBox.CreateItem('Стенок немало');
SGScreen.LastChild.AsComboBox.CreateItem('Стенок много');
SGScreen.LastChild.AsComboBox.CreateItem('Стенки везде');
SGScreen.LastChild.AsComboBox.CallBackProcedure:=TSGComboBoxProcedure(@TSGComboBox_GroundZombies_OnChange);
SGScreen.LastChild.AsComboBox.SelectItem:=2;
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FTimerLabel:=TSGLabel.Create;
SGScreen.CreateChild(FTimerLabel);
SGScreen.LastChild.SetBounds(10,Context.Height-25,Context.Width div 2,20);
SGScreen.LastChild.Anchors:=[SGAnchBottom];
SGScreen.LastChild.Caption:='';
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.AsLabel.TextPosition:=False;
SGScreen.LastChild.FUserPointer1:=Self;
FTimerLabel.TextColor.Import(0,0,0,1);

FLabebYouLose:=TSGLabel.Create;
SGScreen.CreateChild(FLabebYouLose);
SGScreen.LastChild.SetBounds(5,Context.Height div 2 - 15,Context.Width-10,30);
SGScreen.LastChild.Anchors:=[SGAnchBottom];
SGScreen.LastChild.Caption:=TSGKillerStringLose;
SGScreen.LastChild.Visible:=False;
SGScreen.LastChild.FUserPointer1:=Self;
FLabebYouLose.TextColor.Import(0,0,0,1);

InitGame;
end;

procedure TSGKiller.FreeGame;
var
	i:LongWord;
begin
for i:=0 to  High(FArray) do
	SetLength(FArray[i],0);
SetLength(FArray,0);
SetLength(FBullets,0);
SetLength(FSkulls,0);
end;

procedure TSGKiller.CreateZombies(const o:LongWord = 0);
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
	FZombies[i].FNowPosition:=SGVertex2fImport(FZombies[i].FPosition.x*FR.x,FZombies[i].FPosition.y*FR.y);
	end;
end;

procedure TSGKiller.InitImages(const VWidthHeight : TSGLongWord; const VRadBool : TSGBoolean);
begin
if (FImageBlock=nil) or VRadBool then
	begin
	if FImageBlock<>nil then
		FImageBlock.Destroy;
	FImageBlock:=TSGImage.Create;
	FImageBlock.SetContext(Context);
	with FImageBlock do
		begin
		Way:=SGTextureDirectory+Slash+'Killer'+Slash+'Block.sgia';
		Loading();
		Image.SetBounds(VWidthHeight,VWidthHeight);
		ToTexture();
		end;
	end;

if (FImageBullet=nil) or VRadBool then
	begin
	if FImageBullet<>nil then
		FImageBullet.Destroy;
	FImageBullet:=TSGImage.Create;
	FImageBullet.SetContext(Context);
	with FImageBullet do
		begin
		Way:=SGTextureDirectory+Slash+'Killer'+Slash+'Bullet.sgia';
		Loading();
		if VWidthHeight>64 then
			Image.SetBounds(64,64)
		else
			Image.SetBounds(VWidthHeight,VWidthHeight);
		ToTexture();
		end;
	end;

if (FImageZombi=nil) or VRadBool then
	begin
	if FImageZombi<>nil then
		FImageZombi.Destroy;
	FImageZombi:=TSGImage.Create;
	FImageZombi.SetContext(Context);
	with FImageZombi do
		begin
		Way:=SGTextureDirectory+Slash+'Killer'+Slash+'Zombie.sgia';
		Loading();
		Image.SetBounds(VWidthHeight,VWidthHeight);
		ToTexture();
		end;
	end;

if (FImageYou=nil) or VRadBool then
	begin
	if FImageYou<>nil then
		FImageYou.Destroy;
	FImageYou:=TSGImage.Create;
	FImageYou.SetContext(Context);
	with FImageYou do
		begin
		Way:=SGTextureDirectory+Slash+'Killer'+Slash+'You.sgia';
		Loading();
		Image.SetBounds(VWidthHeight,VWidthHeight);
		ToTexture();
		end;
	end;
	
if (FImageSkull=nil) or VRadBool then
	begin
	if FImageSkull<>nil then
		FImageSkull.Destroy;
	FImageSkull:=TSGImage.Create;
	FImageSkull.SetContext(Context);
	with FImageSkull do
		begin
		Way:=SGTextureDirectory+Slash+'Killer'+Slash+'Skull.sgia';
		Loading();
		Image.SetBounds(VWidthHeight,VWidthHeight);
		ToTexture();
		end;
	end;
end;

procedure TSGKiller.InitGame;
var
	i,ii,iii:LongWord;
	OldFR:TSGVertex2f = (x:0;y:0);
begin
FChanget:=True;
FActive:=True;
FStartDeepHeight:=Trunc(((Context.Height/Context.Width)*FStartDeep))+1;
FSkullsNowPosition:=FQuantitySkulls;

FBulletsGos:=0;
FHowManyZombiesYouKill:=0;
FMaxWay:=0;
FBullets:=nil;
SetLength(FBullets,0);
FInterval:=TSGKillerGetDiffic(FDifficultyComboBox.SelectItem);
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
FR.Import(Context.Width/Length(FArray),Context.Height/Length(FArray[0]));

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
InitImages(ii, Abs(Abs(OldFR)-Abs(FR))>SGZero);

FDataTime.Get;
Calculate;
FTimer.Get;
FLabebYouLose.Visible:=False;
FLabebYouLose.VisibleTimer:=0;
FBulletDataTime2.Get;
FVictory:=False;

FLabebYouLose.Caption:=TSGKillerStringLose;
FTimerLabel.Caption:='0 сек';
MayByVictory;
FDTInterval:=0;
end;

destructor TSGKiller.Destroy;
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

SGKillImage(FImageSkull);
SGKillImage(FImageBlock);
SGKillImage(FImageBullet);
SGKillImage(FImageZombi);
SGKillImage(FImageYou);
inherited;
end;

class function TSGKiller.ClassName:string;
begin
Result := 'Киллер';
end;

procedure TSGKiller.DoQuad(const i,ii:LongWord;const artype : TSGKillerArrayType);inline;
type
	TSGKQuadArColor = packed array[0..3] of TSGColor4f;

function GetColorArrayFrom(const x, y, thisway : TSGLongWord):TSGKQuadArColor;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure ProvOne(const One1 : TSGBoolean;var One2 : TSGBoolean; const One1W, One2W : TSGLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if One2 and One1 then
	if One2W > One1W then
		One2 := False;
end;

var
	ThisColor, DecColor, IncColor : TSGColor4f;
	CanMoveRight : TSGBoolean = False;
	CanMoveUp : TSGBoolean = False;
	CanMoveLeft : TSGBoolean = False;
	CanMoveDown : TSGBoolean = False;
	LeftDeep, RightDeep, UpDeep, DownDeep : TSGLongWord;
begin
ThisColor := TSGKillerGetColor(thisway);
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
DecColor := TSGKillerGetColor(thisway - 1);
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
	NeedsExtension : TSGBoolean = True;
	Colors : TSGKQuadArColor;

begin
if artype.FType=2 then
	begin
	Render.Color4f(0.8,0,0.8,1);
	NeedsExtension := False;
	end
else if artype.FWay=FForestHeight*FForestWidth then
	begin
	Render.Color(SGGetColor4fFromLongWord($FFFF00));
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

function TSGKiller.Proverka(const KPos: TSGPoint2int32;const b:Byte):Boolean;inline;
begin
Result:=(KPos.x>=0)and
		(KPos.y>=0) and
		(KPos.x<FForestWidth) and 
		(KPos.y<FForestHeight) and
 (FArray[KPos.x,KPos.y].FType=b);
end;

procedure TSGKiller.Calculate;
var
	i,ii,iii:LongWord;
procedure Rec(var FArray:TSGKillerArray;NewMyPosition: TSGPoint2int32;const Dlinna:LongWord );
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

procedure TSGKiller.GoZombies;
var
	i,ii,iii,iiii,iiiii,iiiiii:LongWord;
	Any: TSGPoint2int32;
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

procedure TSGKiller.MayByVictory;
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
	FLabebYouLose.Caption:=TSGKillerStringWin;
end;

function TSGKiller.IsBulletKillZombie(const Bullet:TSGVertex2f;const Zombie:LongWord):Boolean;
begin
Result:=Abs(SGVertex2fImport(Bullet.x*FR.x,Bullet.y*FR.y)-FZombies[Zombie].FNowPosition)<Abs(FR)/3.9;
end;

procedure TSGKiller.Paint();
var
	i,ii,iii:LongWord;
	FDT:TSGDataTime;
	Vtx1,Vtx2:TSGVertex2f;
	Any,CP: TSGPoint2int32;
begin
if Context.KeyPressed and (Context.KeyPressedType=SGDownKey) and (Context.KeyPressedByte=82) then	
	Reset;
if FActive then
	begin
	{$IFDEF MOBILE}
	if Context.CursorKeysPressed(SGLeftCursorButton) then
		begin
		CP += Context.CursorPosition(SGDeferenseCursorPosition);
		FWayShift.x += CP.x;
		FWayShift.y += CP.y;
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
	if (Context.CursorKeyPressed=SGLeftCursorButton)and (Context.CursorKeyPressedType=SGUpKey) then
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
	if Context.KeyPressed and (Context.KeyPressedType=SGDownKey) then
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
	FDTInterval:=(FDT-FDataTime).GetPastMiliSeconds;
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
		ii:=(FBulletDataTime1-FBulletDataTime2).GetPastMiliSeconds;
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
		SGStringToPChar(SGSecondsToStringTime((FTimer2-FTimer).GetPastSeconds)+', '+
		SGStr(FHowManyZombiesYouKill)+' зомби убито, '+SGStr(FBulletsGos)+' пуль выпущено');
	end
else
	begin
	FLabebYouLose.Visible:=True;
	//FDTInterval:=FInterval;
	end;

Render.InitMatrixMode(SG_2D);
Render.BeginScene(SGR_QUADS);
for i:=0 to High(FArray) do
	for ii:=0 to High(FArray[0]) do
		begin
		if FArray[i][ii].FType=1 then
			begin
			Render.EndScene;
			Render.Color3f(1,1,1);
			Vtx1.Import(i*FR.x,ii*FR.y);
			Vtx2.Import((i+1)*FR.x,(ii+1)*FR.y);
			FImageBlock.DrawImageFromTwoVertex2f(Vtx1,Vtx2,True,SG_2D);
			Render.BeginScene(SGR_QUADS);
			end
		else
			DoQuad(i,ii,FArray[i][ii]);
		end;
Render.EndScene;


if FSkulls<>nil then
	for i:=0 to High(FSkulls) do
		begin
		Render.Color4f(1,0.12,0.12,(FSkulls[i].FAlpha/FQuantitySkulls)*0.7);
		FImageSkull.DrawImageFromTwoVertex2f(FSkulls[i].FPosition,FSkulls[i].FPosition+FR,True,SG_2D);
		end;

Render.Color4f(0.8,0.1,0.1,0.8);
for i:=0 to high(FZombies) do
	if not FZombies[i].FActive then
		FImageSkull.DrawImageFromTwoVertex2f(FZombies[i].FNowPosition,FZombies[i].FNowPosition+FR,True,SG_2D);

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
			FImageZombi.DrawImageFromTwoVertex2f(FZombies[i].FNowPosition,FZombies[i].FNowPosition+FR,True,SG_2D);
			end;
		end
else
	for i:=0 to high(FZombies) do
		if FZombies[i].FActive then
			begin
			FZombies[i].FNowPosition.Import(
				FR.x*FZombies[i].FPosition.x,
				FR.y*FZombies[i].FPosition.y);
			FImageZombi.DrawImageFromTwoVertex2f(FZombies[i].FNowPosition,FZombies[i].FNowPosition+FR,True,SG_2D);
			end;

Vtx1.Import(FYou.x*FR.x,FYou.y*FR.y);
if (not FActive) and (not FVictory) then
	begin
	Render.Color3f(0.1,0.9,0.1);
	FImageSkull.DrawImageFromTwoVertex2f(Vtx1,Vtx1+FR,True,SG_2D);
	end
else
	begin
	Render.Color3f(1,1,1);
	FImageYou.DrawImageFromTwoVertex2f(Vtx1,Vtx1+FR,True,SG_2D);
	end;


Render.Color3f(1,1,1);
if (FBullets<>nil) and (Length(FBullets)>0) then
for i:=0 to High(FBullets) do
	begin
	Vtx1.Import(FBullets[i][0].x*FR.x,FBullets[i][0].y*FR.y);
	if FBullets[i][1].x>0 then
		FImageBullet.DrawImageFromTwoVertex2f(Vtx1,Vtx1+FR,True,SG_2D)
	else
		if FBullets[i][1].x<0 then
			FImageBullet.DrawImageFromTwoVertex2f(Vtx1,Vtx1+FR,True,SG_2D,2)
		else
			if FBullets[i][1].y>0 then
				FImageBullet.DrawImageFromTwoVertex2f(Vtx1,Vtx1+FR,True,SG_2D,3)
			else
				FImageBullet.DrawImageFromTwoVertex2f(Vtx1,Vtx1+FR,True,SG_2D,1);
	end;
	
if not FActive then
	begin
	Render.BeginScene(SGR_QUADS);
	if FVictory then
		Render.Color4f(0,1,0,FLabebYouLose.VisibleTimer)
	else
		Render.Color4f(1,0,0,FLabebYouLose.VisibleTimer);
	
	Render.Vertex2f(Context.Width/2 - 300,Context.Height/2-100);
	Render.Vertex2f(Context.Width/2 + 300,Context.Height/2-100);
	Render.Vertex2f(Context.Width/2 + 300,Context.Height/2+100);
	Render.Vertex2f(Context.Width/2 - 300,Context.Height/2+100);

	Render.Vertex2f(0,Context.Height-25);
	Render.Vertex2f(Context.Width,Context.Height-25);
	Render.Vertex2f(Context.Width,Context.Height);
	Render.Vertex2f(0,Context.Height);
	Render.EndScene();
	end;
end;

end.
