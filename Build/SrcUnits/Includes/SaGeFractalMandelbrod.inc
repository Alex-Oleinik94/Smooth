{$IFDEF SGREADINTERFACE}
type
	TSGFractalMandelbrodThreadData=class;
	TSGFractalMandelbrod=class(TSGImageFractal)
			public
		constructor Create(const VContext:PSGContext);override;
		//destructor Destroy;override;
			public
		FZNumber:TSGComplexNumber;
		FZDegree:LongInt;
		FZMand:Boolean;
		FZQuantityRec:LongInt;
		FColorScheme:SGByte;
		procedure InitColor(x,y:LongInt;RecNumber:LongInt);override;
		function Rec(Number:TSGComplexNumber):LongInt;inline;
			public
		procedure CalculateFromThread(Data:TSGFractalMandelbrodThreadData);
		procedure Calculate;override;
		procedure Draw;override;
		procedure AfterCalculate;override;
		procedure BeginCalculate;override;
		procedure BeginThread(const Number:LongInt;const Real:Pointer);
			public
		property ZNumber:TSGComplexNumber read FZNumber write FZNumber;
		end;
	
	TSGFractalMandelbrodThreadData=class(TSGFractalData)
			public
		constructor Create(var Fractal:TSGFractalMandelbrod;const h1,h2:LongInt;const Point:Pointer;const Number:LongInt = -1);
		destructor Destroy;override;
			public
		H1,H2:LongInt;
		
		FWait:Boolean;
		NowPos:LongWord;
		NewPos:LongWord;
		
		FPoint:Pointer;
		FNumber:LongInt;
		VBuffer:array[False..True]of PBoolean;
		
		FBeginData:TSGDataTime;//время начала потока
		
		FHePr:LongWord;//Уже сделаный прогресс потока по Height
		end;

procedure TSGFractalMandelbrodThreadProcedure(Data:TSGFractalMandelbrodThreadData);


type
	TSGFractalMandelbrodRelease=class(TSGDrawClass)
			public
		constructor Create(const VContext:PSGContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Draw;override;
			protected
		FNewPotokInit:Boolean;
		SelectPoint,SelectSecondPoint,SelectSecondNormalPoint:SGPoint;
		
		SelectPointEnabled:Boolean;
		Manda:TSGFractalMandelbrod;
		
		QuantityThreads:LongInt;
		
		NowSave:Boolean;
		NowSaveLastView:TSGScreenVertexes;
		
		SecondImage:TSGGLImage;
		
		LabelProcent:TSGProgressBar;
		LblProcent:TSGLabel;
		LabelCoord:TSGLabel;
		ScreenshotPanel:TSGPanel;
		
		StartDepth:LongInt;
		ColorComboBox:TSGComboBox;
		TypeComboBox:TSGComboBox;
		ZumButton:TSGButton;
		StepenComboBox:TSGComboBox;
		QuantityRecComboBox:TSGComboBox;
		
		SelectZNimberFlag:Boolean;
		
		ButtonSelectZNumber:TSGButton;
		
		MandaInitialized:Boolean;
		
		VideoPanel:TSGPanel;
		Changet:boolean;
		
		fmStartPanel:TSGComponent;
		VtxForZN:TSGVertex2f;
		
		Procent:real;
		iiiC:LongWord;
		ComplexNumber:TSGComplexNumber;
		FArProgressBar:packed array of
			TSGProgressBar;
		
		FDateTime:TSGDateTime;
		FBeginCalc:TSGDateTime;
			public
		procedure OffComponents;inline;
		procedure OnComponents;inline;
		procedure InitManda;inline;
		function GetPointOnPosOnMand(const Point:SGPoint):TSGComplexNumber;inline;
		procedure UpDateLabelCoordCaption;inline;
		end;
{$ENDIF}

{$IFDEF SGREADIMPLEMENTATION}

procedure TSGFractalMandelbrodRelease.UpDateLabelCoordCaption;inline;
var
	Point:SGPoint;
begin
Point:=Context.CursorPosition(SGNowCursorPosition);
LabelCoord.Caption:=SGStringToPChar('( '+SGFloatToString(Manda.FZNumber.x,3)+' ; '+SGFloatToString(Manda.FZNumber.y,3)+' ) , ( '+
	SGFloatToString(GetPointOnPosOnMand(Point).x,7)+' ; '
	+SGFloatToString(GetPointOnPosOnMand(Point).y,7)+' )');
end;


procedure TSGFractalMandelbrodRelease.OffComponents;inline;
begin
ScreenshotPanel.Visible:=False;
ScreenshotPanel.Active:=False;
ColorComboBox.Visible:=False;
ColorComboBox.Active:=False;
TypeComboBox.Visible:=False;
TypeComboBox.Active:=False;
ZumButton.Visible:=False;
ZumButton.Active:=False;
ButtonSelectZNumber.Visible:=False;
ButtonSelectZNumber.Active:=False;

{VideoPanel.Visible:=False;
VideoPanel.Active:=False;}

StepenComboBox.Visible:=False;
StepenComboBox.Active:=False;
QuantityRecComboBox.Visible:=False;
QuantityRecComboBox.Active:=False;
end;

procedure TSGFractalMandelbrodRelease.OnComponents;inline;
begin
ScreenshotPanel.Visible:=True;
ScreenshotPanel.Active:=True;
ColorComboBox.Visible:=True;
ColorComboBox.Active:=True;
TypeComboBox.Visible:=True;
TypeComboBox.Active:=True;
ZumButton.Visible:=True;
ZumButton.Active:=True;
ButtonSelectZNumber.Visible:=True;
ButtonSelectZNumber.Active:=True;

{VideoPanel.Visible:=True;
VideoPanel.Active:=True;}

StepenComboBox.Visible:=True;
StepenComboBox.Active:=True;
QuantityRecComboBox.Visible:=True;
QuantityRecComboBox.Active:=True;
end;

procedure SaveImage(Button:TSGButton);
begin
with TSGFractalMandelbrodRelease(Button.FUserPointer1) do
	begin
	Manda.Width:=SGVal((Button.Parent.LastChild.Caption));
	Manda.Height:=Trunc(SGVal((Button.Parent.LastChild.Caption))*(Context.Height/Context.Width));
	Changet:=True;
	NowSave:=true;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	end;
end;

{procedure FromExit;
begin
Context.Close;
end;}

procedure ColorComboBoxProcedure(a,b:LongInt;Button:TSGComponent);
begin
with TSGFractalMandelbrodRelease(Button.FUserPointer1) do
	begin
	Manda.FColorScheme:=b;
	if a<>b then
		begin
		Changet:=True;
		SelectPoint.Import;
		SelectSecondPoint.Import;
		end;
	end;
end;

procedure TypeComboBoxProcedure(a,b:LongInt;Button:TSGComponent);
begin
with TSGFractalMandelbrodRelease(Button.FUserPointer1) do
	begin
	Manda.FZMand:=Boolean(b);
	if a<>b then
		begin
		Changet:=True;
		SelectPoint.Import;
		SelectSecondPoint.Import;
		end;
	end;
end;

procedure ZumButtonOnChange(Button:TSGButton);
begin
with TSGFractalMandelbrodRelease(Button.FUserPointer1) do
	begin
	Manda.FView.Import(-2.5,-2.5*(Context.Height/Context.Width),2.5,2.5*(Context.Height/Context.Width));
	Changet:=True;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	end;
end;

procedure ButtonSelectZNumberOnChange(Button:TSGButton);
begin
with TSGFractalMandelbrodRelease(Button.FUserPointer1) do
	SelectZNimberFlag:=True;
end;

procedure QuantityRecComboBoxProcedure(a,b:LongInt;aaa:TSGComponent);
BEGIN
with TSGFractalMandelbrodRelease(aaa.FUserPointer1) do
	begin
	Manda.FZQuantityRec:=QuantityRecComboBox.FItems[b].FId;
	Changet:=True;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	end;
END;

procedure StepenComboBoxProcedure(a,b:LongInt;aaa:TSGComponent);
begin
with TSGFractalMandelbrodRelease(aaa.FUserPointer1) do
	begin
	Manda.FZDegree:=StepenComboBox.FItems[b].FId;
	Changet:=True;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	end;
end;

function MyMandNumberFucntion(const Self:TSGEdit):boolean;
begin
Result:=TSGEditTextTypeFunctionNumber(Self);
TSGComponent(Self.FUserPointer2).Active:=Result;
end;

procedure TSGFractalMandelbrodRelease.InitManda;inline;
var
	i:LongInt;
	ii:LongInt = 5;
begin
Manda:=TSGFractalMandelbrod.Create(FContext);
Manda.Width:=StartDepth;
Manda.Height:=StartDepth;
Manda.FZNumber.Import(-0.181,0.66);
Manda.FZMand:=False;
Manda.FZDegree:=2;
Manda.FView.Import(-2.5,-2.5*(Context.Height/Context.Width),2.5,2.5*(Context.Height/Context.Width));
Manda.CreateThreads(QuantityThreads);
Manda.BeginCalculate;
Manda.FImage.Way:=DataDirectory+Slash+'Images'+Slash+'Mand New.png';

FBeginCalc.Get;
SetLength(FArProgressBar,QuantityThreads);
ii+={Context.TopShift+}40;
for i:=0 to QuantityThreads-1 do
	begin
	FArProgressBar[i]:=TSGProgressBar.Create;
	SGScreen.CreateChild(FArProgressBar[i]);
	SGScreen.LastChild.SetBounds(10,ii,300,20);
	FArProgressBar[i].AutoTopShift:=True;
	ii+=25;
	SGScreen.LastChild.Visible:=True;
	SGScreen.LastChild.AsProgressBar.ViewProgress:=True;
	Manda.BeginThread(i,FArProgressBar[i]);
	end;

LblProcent:=TSGLabel.Create;
SGScreen.CreateChild(LblProcent);
SGScreen.LastChild.AutoTopShift:=True;
LblProcent.SetBounds(10,ii,300,20);
LblProcent.Caption:='';
LblProcent.Visible:=True;
LblProcent.FUserPointer1:=Self;

LabelProcent:=TSGProgressBar.Create;
SGScreen.CreateChild(LabelProcent);
SGScreen.LastChild.AutoTopShift:=True;
LabelProcent.SetBounds(10,ii,300,20);
LabelProcent.FColor2.Import(1,0,0,0.8);
LabelProcent.FColor1.Import(0.5,0,0,0.8);
LabelProcent.Caption:='';
LabelProcent.Visible:=True;
LabelProcent.FUserPointer1:=Self;

LabelCoord:=TSGLabel.Create;
SGScreen.CreateChild(LabelCoord);
SGScreen.LastChild.SetBounds(10,Context.Height-25,Context.Width div 2,20);
SGScreen.LastChild.Anchors:=[SGAnchBottom];
SGScreen.LastChild.Caption:='';
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.AsLabel.FTextPosition:=0;
SGScreen.LastChild.FUserPointer1:=Self;

ScreenshotPanel:=TSGPanel.Create;
SGScreen.CreateChild(ScreenshotPanel);
SGScreen.LastChild.Caption:='';
SGScreen.LastChild.SetBounds(Context.Width-10-(130+140+10),Context.Height-30,130+140+10,25);
SGScreen.LastChild.Anchors:=[SGAnchBottom,SGAnchRight];
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.FUserPointer1:=Self;

SGScreen.LastChild.CreateChild(TSGButton.Create);
SGScreen.LastChild.LastChild.SetBounds(130,5,140,20);
SGScreen.LastChild.LastChild.Caption:='Сохранить';
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.AsButton.OnChange:=TSGComponentProcedure(@SaveImage);
SGScreen.LastChild.LastChild.FUserPointer1:=Self;

SGScreen.LastChild.CreateChild(TSGEdit.Create);
SGScreen.LastChild.LastChild.SetBounds(5,5,120,20);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.LastChild.FUserPointer2:=SGScreen.LastChild.FChildren[High(SGScreen.LastChild.FChildren)-1];
(SGScreen.LastChild.LastChild as TSGEdit).TextTypeFunction:=TSGEditTextTypeFunction(@MyMandNumberFucntion);
(SGScreen.LastChild.LastChild as TSGEdit).TextType:=SGEditTypeUser;
SGScreen.LastChild.LastChild.Caption:='4096';

SGScreen.CreateChild(TSGComboBox.Create);
SGScreen.LastChild.SetBounds(Context.Width-50-125+45,5{+Context.TopShift},120,20);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.AsComboBox.CreateItem('Цвет №1');
SGScreen.LastChild.AsComboBox.CreateItem('Цвет №2');
SGScreen.LastChild.AsComboBox.CreateItem('Цвет №3');
SGScreen.LastChild.AsComboBox.CreateItem('Монохромный');
SGScreen.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@ColorComboBoxProcedure);
SGScreen.LastChild.AsComboBox.FSelectItem:=0;
ColorComboBox:=SGScreen.LastChild.AsComboBox;
SGScreen.LastChild.FUserPointer1:=Self;

TypeComboBox:=TSGComboBox.Create;
SGScreen.CreateChild(TypeComboBox);
SGScreen.LastChild.SetBounds(Context.Width-50-125+45-185,5{+Context.TopShift},180,20);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.AsComboBox.CreateItem('Множество Жюлиа');
SGScreen.LastChild.AsComboBox.CreateItem('Модель Мандельброта');
SGScreen.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@TypeComboBoxProcedure);
SGScreen.LastChild.AsComboBox.FSelectItem:=0;
SGScreen.LastChild.FUserPointer1:=Self;

SGScreen.CreateChild(TSGButton.Create);
SGScreen.LastChild.SetBounds(Context.Width-50-125-185+45-105,5{+Context.TopShift},100,20);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='Сброс зума';
ZumButton:=SGScreen.LastChild.AsButton;
ZumButton.OnChange:=TSGComponentProcedure(@ZumButtonOnChange);
SGScreen.LastChild.FUserPointer1:=Self;

SGScreen.CreateChild(TSGButton.Create);
SGScreen.LastChild.SetBounds(Context.Width-50-125-185-105+45-125,5{+Context.TopShift},120,20);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='Установ. тчк.';
ButtonSelectZNumber:=SGScreen.LastChild.AsButton;
ButtonSelectZNumber.OnChange:=TSGComponentProcedure(@ButtonSelectZNumberOnChange);
SGScreen.LastChild.FUserPointer1:=Self;

StepenComboBox:=TSGComboBox.Create;
SGScreen.CreateChild(StepenComboBox);
SGScreen.LastChild.SetBounds(Context.Width-50-125-185-105-125+45-105,5{+Context.TopShift},100,20);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='';
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.AsComboBox.FSelectItem:=1;
SGScreen.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@StepenComboBoxProcedure);
SGScreen.LastChild.FUserPointer1:=Self;
i:=1;
while i<=100 do
	begin
	SGScreen.LastChild.AsComboBox.CreateItem(SGStringToPChar(SGStr(i)),nil,i);
	i+=1;
	end;

QuantityRecComboBox:=TSGComboBox.Create;
SGScreen.CreateChild(QuantityRecComboBox);
SGScreen.LastChild.SetBounds(Context.Width-50-125-185-105-125-105+45-105,5{+Context.TopShift},100,20);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='';
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@QuantityRecComboBoxProcedure);
SGScreen.LastChild.FUserPointer1:=Self;
i:=6;
while i<=13 do
	begin
	SGScreen.LastChild.AsComboBox.CreateItem(SGStringToPChar(SGStr(2**i)),nil,2**i);
	if i=8 then
		begin
		SGScreen.LastChild.AsComboBox.FSelectItem:=High(QuantityRecComboBox.FItems);
		end;
	i+=1;
	end;


VideoPanel:=TSGPanel.Create;
SGScreen.CreateChild(VideoPanel);
SGScreen.LastChild.Caption:=' ';
SGScreen.LastChild.SetBounds(Context.Width-500,Context.Height-30-30,400,25);
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.FUserPointer1:=Self;

VideoPanel.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.Caption:='Видео';
SGScreen.LastChild.LastChild.SetBounds(5,5,60,20);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.FUserPointer1:=Self;

end;

procedure BeginInitMand(Button:TSGButton);
begin
with TSGFractalMandelbrodRelease(Button.FUserPointer1) do
	begin
	Button.Parent.Visible:=(False);
	QuantityThreads:=SGVal((Button.Parent.FChildren[4].AsComboBox.FItems[Button.Parent.FChildren[4].AsComboBox.FSelectItem].FCaption));
	StartDepth:=SGVal(Button.Parent.FChildren[3].AsComboBox.FItems[Button.Parent.FChildren[3].AsComboBox.FSelectItem].FCaption);
	InitManda;
	MandaInitialized:=True;
	end;
end;


constructor TSGFractalMandelbrodRelease.Create(const VContext:PSGContext);
begin
inherited Create(VContext);
FArProgressBar:=nil;
Changet:=False;
SelectPointEnabled:=False;
Manda:=nil;
QuantityThreads:=1;
NowSave:=False;
SecondImage:=nil;
LabelCoord:=nil;
LabelProcent:=nil;
ScreenshotPanel:=nil;
StartDepth:=128;
ColorComboBox:=nil;
TypeComboBox:=nil;
ZumButton:=nil;
StepenComboBox:=nil;
QuantityRecComboBox:=nil;
SelectZNimberFlag:=False;
ButtonSelectZNumber:=nil;
MandaInitialized:=False;
VideoPanel:=nil;
fmStartPanel:=nil;

SGScreen.CreateChild(TSGPanel.Create);
SGScreen.LastChild.SetMiddleBounds(300,Context.Height-200);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.AsPanel.FViewLines:=False;
SGScreen.LastChild.AsPanel.FViewQuad:=False;
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.FUserPointer1:=Self;
fmStartPanel:=SGScreen.LastChild;

SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.Caption:='Количество потоков';
SGScreen.LastChild.LastChild.SetBounds(5,5,SGScreen.LastChild.Width-10,20);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.FUserPointer1:=Self;

SGScreen.LastChild.CreateChild(TSGLabel.Create);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.Caption:='Разрешение текстуры';
SGScreen.LastChild.LastChild.SetBounds(5,55,SGScreen.LastChild.Width-10,20);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.FUserPointer1:=Self;

SGScreen.LastChild.CreateChild(TSGButton.Create);
SGScreen.LastChild.LastChild.SetBounds(75,115,140,20);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.Caption:='Запуск';
SGScreen.LastChild.LastChild.OnChange:=TSGComponentProcedure(@BeginInitMand);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.FUserPointer1:=Self;

SGScreen.LastChild.CreateChild(TSGComboBox.Create);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.SetBounds(5,80,SGScreen.LastChild.Width-10,20);
SGScreen.LastChild.LastChild.AsComboBox.FSelectItem:=3;
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('64');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('128');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('256');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('512');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('1024');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('2048');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('4096');
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.FUserPointer1:=Self;

SGScreen.LastChild.CreateChild(TSGComboBox.Create);
SGScreen.LastChild.LastChild.Visible:=True;
SGScreen.LastChild.LastChild.SetBounds(5,30,SGScreen.LastChild.Width-10,20);
SGScreen.LastChild.LastChild.AsComboBox.FSelectItem:=3;
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('1');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('2');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('3');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('4');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('6');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('8');
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.FUserPointer1:=Self;
end;

destructor TSGFractalMandelbrodRelease.Destroy;
var
	i:LongWord;
begin
if SecondImage<>nil then
	SecondImage.Destroy;
SecondImage:=nil;
if LabelProcent<>nil then
	LabelProcent.Destroy;
LabelProcent:=nil;
if LblProcent<>nil then
	LblProcent.Destroy;
LblProcent:=nil;
if LabelCoord<>nil then
	LabelCoord.Destroy;
LabelCoord:=nil;
if ScreenshotPanel<>nil then
	ScreenshotPanel.Destroy;
ScreenshotPanel:=nil;
if ColorComboBox<>nil then
	ColorComboBox.Destroy;
ColorComboBox:=nil;
if TypeComboBox<>nil then
	TypeComboBox.Destroy;
TypeComboBox:=nil;
if ZumButton<>nil then
	ZumButton.Destroy;
ZumButton:=nil;
if StepenComboBox<>nil then
	StepenComboBox.Destroy;
StepenComboBox:=nil;
if QuantityRecComboBox<>nil then
	QuantityRecComboBox.Destroy;
QuantityRecComboBox:=nil;
if ButtonSelectZNumber<>nil then
	ButtonSelectZNumber.Destroy;
ButtonSelectZNumber:=nil;
if VideoPanel<>nil then
	VideoPanel.Destroy;
VideoPanel:=nil;
if fmStartPanel<>nil then
	fmStartPanel.Destroy;
fmStartPanel:=nil;
if Manda<>nil then
	Manda.Destroy;
Manda:=nil;
if FArProgressBar<>nil then
	for i:=0 to High(FArProgressBar) do
		if FArProgressBar[i]<>nil then
			FArProgressBar[i].Destroy;
SetLength(FArProgressBar,0);
FArProgressBar:=nil;
inherited;
end;

class function TSGFractalMandelbrodRelease.ClassName:string;
begin
Result:='Фрактал Мандельброда и тп';
end;

function TSGFractalMandelbrodRelease.GetPointOnPosOnMand(const Point:SGPoint):TSGComplexNumber;inline;
begin
Result.Import(
	Manda.FView.x1+(Point.x/(Context.Width)*abs(Manda.FView.x1-Manda.FView.x2)),
	Manda.FView.y1+((Context.Height-Point.y)/(Context.Height)*abs(Manda.FView.y1-Manda.FView.y2))
	);
end;

procedure TSGFractalMandelbrodRelease.Draw;
var
	i,ii:LongInt;
begin
if MandaInitialized then
	begin
	Render.InitMatrixMode(SG_2D);

	if Manda.ThreadsReady then
		begin
		Delay(5);
		Manda.AfterCalculate;
		
		for i:=0 to QuantityThreads-1 do
			begin
			FArProgressBar[i].Visible:=False;
			//SGScreen.Children[CID-QuantityThreads+i+2].AsProgressBar.Visible:=False;
			end;
		
		FDateTime.Get;
		LabelProcent.Visible:=False;
		LabelProcent.Caption:='100%';
		LblProcent.Visible:=False;
		LblProcent.Caption:=SGStringToPChar('100%, Прошло: '+
			(
			SGSecondsToStringTime(
			(FDateTime-FBeginCalc).GetPastSeconds))+'.');
		
		if not NowSave then
			begin
			Manda.ToTexture;
			OnComponents;
			{if SecondImage<>nil then
				begin
				SecondImage.Destroy;
				SecondImage:=nil;
				end;}
			end
		else
			begin
			if not DirectoryExists(DataDirectory+Slash+'Images') then
				MkDir(DataDirectory+Slash+'Images');
			Manda.FImage.Saveing(SGI_PNG);
			Manda.Width:=StartDepth;
			Manda.Height:=StartDepth;
			Manda.FImage.Destroy;
			Manda.FImage:=SecondImage;
			SecondImage:=nil;
			NowSave:=False;
			end;
		end;

	UpDateLabelCoordCaption;

	if LabelProcent.Visible and ( not Manda.ThreadsReady) then
		begin
		Delay(5);
		FNewPotokInit:=False;
		Procent:=0;
		for i:=0 to QuantityThreads-1 do
			begin
			Procent+=
				FArProgressBar[i].FNeedProgress*(
				(Manda.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).h2-
				(Manda.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).h1
				)+(Manda.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).FHePr;
			if Manda.FThreadsData[i].FFinished and (FArProgressBar[i].Visible) then
				begin
				//FArProgressBar[i].Visible:=False;
				for ii:=0 to Manda.Threads-1 do
					begin
					{if ii>=i+1 then
						FArProgressBar[ii].FNeedTop-=25;}
					FDateTime.Get;
					if (not FNewPotokInit) then
					if 
						(Manda.FThreadsData[ii].FData<>nil) and 
						(Manda.FThreadsData[ii].FFinished=False) and 
						(ii<>i) and 
						((Manda.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).NewPos=0) and 
						(
						((Manda.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).h2-
						(Manda.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).NowPos)
						*Manda.Width>50000
						) and
						(
						(
						FDateTime.GetPastMiliSeconds-
						(Manda.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).FBeginData.GetPastMiliSeconds
						)/FArProgressBar[ii].FNeedProgress*(1 - FArProgressBar[ii].FNeedProgress)
						>150
						) then
						// i - Только что Завершивший свою работу поток
						//ii - Гасторбайтер, Незавершивший свою работу поток
						begin
						(Manda.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).FWait:=True;
						
						if (Manda.FThreadsData[ii].FFinished=False) then
			begin
						
						FArProgressBar[ii].FColor2:=(FArProgressBar[ii].FColor2+SGColorImport(0.9,0.45,0,0.8))/2;
						FArProgressBar[ii].FColor1:=(FArProgressBar[ii].FColor1+SGColorImport(1,0.5,0,1))/2;
						FArProgressBar[i].FColor2:=(FArProgressBar[i].FColor2+SGColorImport(0.1,1,0.1,0.7))/2;
						FArProgressBar[i].FColor1:=(FArProgressBar[i].FColor1+SGColorImport(0,1,0,1))/2;
						
						iiiC:=0;
						if Manda.FThreadsData[i].FData<>nil then
							begin
							iiiC:=(Manda.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).h2-
									(Manda.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).h1+
									(Manda.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).FHePr;
							Manda.FThreadsData[i].FData.Destroy;
							Manda.FThreadsData[i].FData:=nil;
							end;
						
						if Manda.FThreadsData[i].FThread<>nil then
							begin
							Manda.FThreadsData[i].FThread.Destroy;
							Manda.FThreadsData[i].FThread:=nil;
							end;
						
						Manda.FThreadsData[i].FData:=TSGFractalMandelbrodThreadData.Create(
							Manda,
							(Manda.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).NowPos+
							(
							(
							(Manda.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).h2-
							(Manda.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).NowPos
							) div 2
							),
								
							(Manda.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).h2,
							@FArProgressBar[i].FNeedProgress,i);

						(Manda.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).NewPos:=0;
						(Manda.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).NowPos:=0;
						(Manda.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).FWait:=False;
						Manda.FThreadsData[i].FFinished:=False;
						(Manda.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).FBeginData.Get;
						(Manda.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).FHePr:=iiiC;
						FArProgressBar[i].FNeedProgress:=0;
						FArProgressBar[i].FProgress:=0;
						
						Manda.FThreadsData[i].FThread:=
							TSGThread.Create(
								TSGPointerProcedure(@TSGFractalMandelbrodThreadProcedure),
								Manda.FThreadsData[i].FData);
						
						(Manda.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).NewPos:=
							(Manda.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).NowPos+
							(
							(
							(Manda.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).h2-
							(Manda.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).NowPos
							) div 2
							);
						FNewPotokInit:=True;
			end;
						end;
					end;
				//LabelProcent.FNeedTop-=25;
				end;
			end;
		Procent/=Manda.Height;
		LabelProcent.FNeedProgress:=Procent;
		FDateTime.Get;
		///FDateTime.ImportFromSeconds((FDateTime-FBeginCalc).GetPastSeconds);
		LblProcent.Caption:=SGStringToPChar(SGFloatToString(Procent*100,2)+'%,Прошло '+
			SGSecondsToStringTime((FDateTime-FBeginCalc).GetPastSeconds)
			+','+'Осталось '+
			SGSecondsToStringTime(Round((FDateTime-FBeginCalc).GetPastSeconds/Procent*(1-Procent)))
			+'.');
		LabelCoord.Caption:=SGPCharNil;
		end;


	if Manda.FImage.Ready then
		begin
		Render.Color3f(1,1,1);
		Manda.Draw;
		//if Manda.FView.VertexInView(Manda.FZNumber) then
			//begin
			VtxForZN.Import(
				abs(Manda.FZNumber.x-SGMin(Manda.FView.X1,Manda.FView.X2))/Manda.FView.AbsX*Context.Width,
				abs(Manda.FZNumber.Y-SGMax(Manda.FView.Y1,Manda.FView.Y2))/Manda.FView.AbsY*Context.Height
				);
			Render.Color3f(1,1,1);
			Render.BeginScene(SGR_TRIANGLES);
			Render.Vertex2f(VtxForZN.x+5,VtxForZN.y);
			Render.Vertex2f(VtxForZN.x-2,VtxForZN.y-4);
			Render.Vertex2f(VtxForZN.x-2,VtxForZN.y+4);
			Render.EndScene();
			//end;
			{
		else
			Manda.FZNumber.WriteLn;}
		if (SelectZNimberFlag and ((Context.CursorKeysPressed(SGLeftCursorButton)))) or (Context.CursorKeysPressed(SGMiddleCursorButton)) then
			begin
			ComplexNumber:=GetPointOnPosOnMand(Context.CursorPosition(SGNowCursorPosition));
			if Manda.FZNumber <> ComplexNumber then
				begin
				Manda.FZNumber:=ComplexNumber;
				SelectZNimberFlag:=False;
				//SGSetMouseKeyUp(1);
				Context.SetCursorKey(SGUpKey,SGLeftCursorButton);
				if not Manda.FZMand then
					Changet:=True;
				SelectPoint.Import;
				SelectSecondPoint.Import;
				end;
			end;
		if (Context.CursorKeysPressed(SGRightCursorButton))  then
			begin
			SelectPointEnabled:=True;
			SelectPoint:=Context.CursorPosition(SGNowCursorPosition);
			end;
		if SelectPointEnabled then
			begin
			if Context.KeyPressedChar=#27 then
				SelectPointEnabled:=False;
			
			SelectSecondPoint:=Context.CursorPosition(SGNowCursorPosition);
			if abs(SelectPoint.x-SelectSecondPoint.x)/abs(SelectPoint.y-SelectSecondPoint.y)>Context.Width/Context.Height then
				begin
				SelectSecondNormalPoint.y:=SelectSecondPoint.y;
				if (SelectPoint.x<SelectSecondPoint.x)then
					SelectSecondNormalPoint.x:=SelectPoint.x+Round(abs(SelectSecondPoint.y-SelectPoint.y)/Context.Height*Context.Width)
				else
					SelectSecondNormalPoint.x:=SelectPoint.x-Round(abs(SelectSecondPoint.y-SelectPoint.y)/Context.Height*Context.Width);
				end
			else
				begin
				SelectSecondNormalPoint.x:=SelectSecondPoint.x;
				if SelectPoint.y<SelectSecondPoint.y then
					SelectSecondNormalPoint.y:=SelectPoint.y+Round(abs(SelectSecondPoint.x-SelectPoint.x)/Context.Width*Context.Height)
				else
					SelectSecondNormalPoint.y:=SelectPoint.y-Round(abs(SelectSecondPoint.x-SelectPoint.x)/Context.Width*Context.Height);
				end;
			
			Render.Color4f(0,0.5,0.70,0.6);
			Render.BeginScene(SGR_QUADS);
			SelectPoint.Vertex(Render);
			Render.Vertex2f(SelectPoint.x,SelectSecondPoint.y);
			SelectSecondPoint.Vertex(Render);
			Render.Vertex2f(SelectSecondPoint.x,SelectPoint.y);
			Render.EndScene();
			Render.Color4f(0,0.7,0.70,0.8);
			Render.BeginScene(SGR_LINE_LOOP);
			SelectPoint.Vertex(Render);
			Render.Vertex2f(SelectPoint.x,SelectSecondPoint.y);
			SelectSecondPoint.Vertex(Render);
			Render.Vertex2f(SelectSecondPoint.x,SelectPoint.y);
			Render.EndScene();
			
			Render.Color4f(0.6,0.5,0.30,0.6);
			Render.BeginScene(SGR_QUADS);
			SelectPoint.Vertex(Render);
			Render.Vertex2f(SelectPoint.x,SelectSecondNormalPoint.y);
			SelectSecondNormalPoint.Vertex(Render);
			Render.Vertex2f(SelectSecondNormalPoint.x,SelectPoint.y);
			Render.EndScene();
			Render.Color4f(1,0.9,0.20,0.8);
			Render.BeginScene(SGR_LINE_LOOP);
			SelectPoint.Vertex(Render);
			Render.Vertex2f(SelectPoint.x,SelectSecondNormalPoint.y);
			SelectSecondNormalPoint.Vertex(Render);
			Render.Vertex2f(SelectSecondNormalPoint.x,SelectPoint.y);
			Render.EndScene();
			end;
		if SelectPointEnabled and {(SGIsMouseKeyDown(1))} (Context.CursorKeysPressed(SGLeftCursorButton)) then
			begin
			//Тут херачится новый зум
			SelectSecondPoint:=SelectSecondNormalPoint;
			
			SelectPointEnabled:=False;
			if SelectPoint.x>SelectSecondPoint.x then
				SGQuickRePlaceLongInt(SelectPoint.x,SelectSecondPoint.x);
			if SelectPoint.y>SelectSecondPoint.y then
				SGQuickRePlaceLongInt(SelectPoint.y,SelectSecondPoint.y);
			{Manda.FView.Import(
				Manda.FView.x1+abs(Manda.FView.x1-Manda.FView.x2)*SelectPoint.x/Context.Width,
				Manda.FView.y1+abs(Manda.FView.y1-Manda.FView.y2)*(SelectPoint.y)/Context.Height,
				Manda.FView.x1+abs(Manda.FView.x1-Manda.FView.x2)*SelectSecondPoint.x/Context.Width,
				Manda.FView.y1+abs(Manda.FView.y1-Manda.FView.y2)*(SelectSecondPoint.y)/Context.Height);}
			Manda.FView.Import(
				GetPointOnPosOnMand(SelectPoint).x,
				GetPointOnPosOnMand(SelectPoint).y-abs(GetPointOnPosOnMand(SelectPoint).y-GetPointOnPosOnMand(SelectSecondPoint).y),
				GetPointOnPosOnMand(SelectSecondPoint).x,
				GetPointOnPosOnMand(SelectSecondPoint).y-abs(GetPointOnPosOnMand(SelectPoint).y-GetPointOnPosOnMand(SelectSecondPoint).y)
				);
			Changet:=True;
			end;
		end
	else
		begin
		if SecondImage<>nil then
			begin
			Render.Color3f(1,1,1);
			if SecondImage.Ready then
				SecondImage.DrawImageFromTwoPoint2f(
					SGPointImport(1,1),
					SGPointImport(Context.Width,Context.Height),
					True,SG_2D);
			
			Render.Color4f(0.1,0.7,0.20,0.6);
			Render.BeginScene(SGR_QUADS);
			SelectPoint.Vertex(Render);
			Render.Vertex2f(SelectPoint.x,SelectSecondPoint.y);
			SelectSecondPoint.Vertex(Render);
			Render.Vertex2f(SelectSecondPoint.x,SelectPoint.y);
			Render.EndScene();
			
			Render.Color4f(0.05,0.9,0.10,0.8);
			Render.BeginScene(SGR_LINE_LOOP);
			SelectPoint.Vertex(Render);
			Render.Vertex2f(SelectPoint.x,SelectSecondPoint.y);
			SelectSecondPoint.Vertex(Render);
			Render.Vertex2f(SelectSecondPoint.x,SelectPoint.y);
			Render.EndScene();
			end;
		end;

	if Changet then
		begin
		OffComponents;
		if SecondImage<>nil then
			SecondImage.Destroy;
		SecondImage:=Manda.FImage;
		Manda.FImage:=nil;
		Manda.BeginCalculate;
		Manda.FImage.Way:=SGGetFreeFileName(DataDirectory+Slash+'Images'+Slash+'Mand New.png');
		LabelProcent.Visible:=True;
		LblProcent.Visible:=True;
		ii:={Context.TopShift+}40;
		FBeginCalc.Get;
		for i:=0 to QuantityThreads-1 do
			begin
			with FArProgressBar[i] do
				begin
				FNeedProgress:=0;
				FProgress:=0;
				Visible:=true;
				AutoTopShift:=False;
				FNeedTop:=ii;
				AutoTopShift:=True;
				ii+=25;
				DefaultColor;
				Manda.BeginThread(i,@FNeedProgress);
				end;
			end;
		LabelProcent.AutoTopShift:=False;
		LblProcent.AutoTopShift:=False;
		LabelProcent.FNeedTop:=ii;
		LblProcent.FNeedTop:=ii;
		LabelProcent.AutoTopShift:=True;
		LblProcent.AutoTopShift:=True;
		end;
	Changet:=False;
	end;
end;


{MANDELBROD}
procedure TSGFractalMandelbrodThreadProcedure(Data:TSGFractalMandelbrodThreadData);
begin
with data do
	begin
	(FFractal as TSGFractalMandelbrod).CalculateFromThread(Data);
	FFractal.FThreadsData[FNumber].FFinished:=True;
	end;
end;

destructor TSGFractalMandelbrodThreadData.Destroy;
begin
FFractal:=nil;
FreeMem(VBuffer[True]);
FreeMem(VBuffer[not True]);
inherited;
end;

procedure TSGFractalMandelbrod.BeginThread(const Number:LongInt;const Real:Pointer);
begin
FThreadsData[Number].FData:=TSGFractalMandelbrodThreadData.Create(
	Self,
	Trunc( (Number)*(Height div Length(FThreadsData))),
	Trunc( (Number+1)*(Height div Length(FThreadsData)))-1,
	Real,Number);

(FThreadsData[Number].FData as TSGFractalMandelbrodThreadData).NewPos:=0;
(FThreadsData[Number].FData as TSGFractalMandelbrodThreadData).NowPos:=0;
(FThreadsData[Number].FData as TSGFractalMandelbrodThreadData).FWait:=False;
(FThreadsData[Number].FData as TSGFractalMandelbrodThreadData).FBeginData.Get;

FThreadsData[Number].FThread:=
	TSGThread.Create(
		TSGPointerProcedure(@TSGFractalMandelbrodThreadProcedure),
		FThreadsData[Number].FData);
end;

procedure TSGFractalMandelbrod.AfterCalculate;
var
	i:LongInt;
begin
for i:=0 to High(FThreadsData) do
	if FThreadsData[i].FFinished then
		begin
		if FThreadsData[i].FData<>nil then
			begin
			FThreadsData[i].FData.Destroy;
			FThreadsData[i].FData:=nil;
			end;
		if FThreadsData[i].FThread<>nil then
			begin
			FThreadsData[i].FThread.Destroy;
			FThreadsData[i].FThread:=nil;
			end;
		end;
inherited;
end;

procedure TSGFractalMandelbrod.BeginCalculate;
begin
inherited;
end;


constructor TSGFractalMandelbrodThreadData.Create(var Fractal:TSGFractalMandelbrod;const h1,h2:LongInt;const Point:Pointer;const Number:LongInt = -1);
begin
FFractal:=Fractal;
Self.h1:=h1;
Self.h2:=h2;
FPoint:=Point;
FNumber:=Number;
GetMem(VBuffer[True],trunc(FFractal.Depth/2)+1);
GetMem(VBuffer[False],trunc(FFractal.Depth/2)+1);
FHePr:=0;
end;

procedure TSGFractalMandelbrod.Draw;
begin
inherited;
if FImage.Ready then
	FImage.DrawImageFromTwoPoint2f(
		SGPointImport(1,1),
		SGPointImport(Context.Width,Context.Height),
		False,SG_3D);
end;


constructor TSGFractalMandelbrod.Create(const VContext:PSGContext);
begin
inherited Create(VContext);
FImage:=nil;
FZNumber.Import(0,0.65);
FView.Import(-1.5,-1.5*(Context.Height/Context.Width),1.5,1.5*(Context.Height/Context.Width));
FZMand:=False;
FZDegree:=2;
FZQuantityRec:=256;
FColorScheme:=0;
end;

procedure TSGFractalMandelbrod.InitColor(x,y:LongInt;RecNumber:LongInt);
var
	Color:Byte;
begin
Color:=Round((RecNumber/20)*255);
case FColorScheme of
1:
	begin
	FImage.FImage.FBitMap[(Y*Width+X)*3+0]:=GetColor(0,383,Color) div 2;
	FImage.FImage.FBitMap[(Y*Width+X)*3+1]:=GetColor(128,896,Color);
	FImage.FImage.FBitMap[(Y*Width+X)*3+2]:=GetColor(0,383,Color);
	end;
2:
	begin
	FImage.FImage.FBitMap[(Y*Width+X)*3+0]:=GetColorOne(FZQuantityRec div 4,FZQuantityRec,Color);
	FImage.FImage.FBitMap[(Y*Width+X)*3+1]:=GetColorOne(0,FZQuantityRec,Color);
	FImage.FImage.FBitMap[(Y*Width+X)*3+2]:=GetColorOne(FZQuantityRec div 2,FZQuantityRec,Color);
	end;
3:
	begin
	Color:=Trunc(RecNumber/FZQuantityRec*255);
	FImage.FImage.FBitMap[(Y*Width+X)*3+0]:=Color;
	FImage.FImage.FBitMap[(Y*Width+X)*3+1]:=Color;
	FImage.FImage.FBitMap[(Y*Width+X)*3+2]:=Color; 
	end;
else
	begin
	if RecNumber=FZQuantityRec then
		begin
		FImage.FImage.FBitMap[(Y*Width+X)*3+0]:=255;
		FImage.FImage.FBitMap[(Y*Width+X)*3+1]:=127;
		FImage.FImage.FBitMap[(Y*Width+X)*3+2]:=0;
		end
	else
		begin
		FImage.FImage.FBitMap[(Y*Width+X)*3+0]:=GetColor(200,400,Color);
		FImage.FImage.FBitMap[(Y*Width+X)*3+1]:=GetColor(0,200,Color);
		FImage.FImage.FBitMap[(Y*Width+X)*3+2]:=GetColor(100,300,Color);
		end;
	end;
end;
end;

procedure TSGFractalMandelbrod.CalculateFromThread(Data:TSGFractalMandelbrodThreadData);
var
	i,ii:Word;
	rY,rX:System.Real;//По идее это Wight и Height
	
	VReady:Boolean = False;
	VBufferNow:Boolean = False;
	
	VKolRec:LongInt;
	IsComponent:Boolean = False;
begin
if Data.FPoint<>nil then
	IsComponent:=TSGComponent(Data.FPoint) is TSGProgressBar;
rY:=abs(FView.y1-FView.y2);
rX:=abs(FView.x1-FView.x2);
//i:=Data.h1;
//От h1 горизонтальной линии пикселей до h2 делаем
for i:=Data.h1 to Data.h2 do
//while i<=Data.h2 do
//repeat
	begin
	Data.NowPos:=i;
	ii:=Byte(VBufferNow);
	while (ii<Width) do
		begin
		VKolRec:=Rec(SGComplexNumberImport(FView.x1+rX/Width*ii,FView.y1+rY/Height*i));//(ii/FDepth)*r?
		InitColor(ii,i,VKolRec);
		Data.VBuffer[VBufferNow][ii div 2]:=VKolRec=FZQuantityRec;
		if (VReady) then
			begin
			if (Data.VBuffer[VBufferNow][ii div 2]) and (Data.VBuffer[not VBufferNow][ii div 2]) and 
				(((not VBufferNow) and (ii<>0) and (Data.VBuffer[not VBufferNow][(ii-1) div 2])) 
				or 
				((VBufferNow) and (ii<>Width-1) and (Data.VBuffer[not VBufferNow][(ii+1) div 2]))) then
					InitColor(ii,i-1,FZQuantityRec)
			else
				InitColor(ii,i-1,
					Rec(SGComplexNumberImport(FView.x1+rX/Width*ii,FView.y1+rY/Height*(i-1))));
			end;
		ii+=2;
		end;
	
	VBufferNow:= not VBufferNow;
	if not VReady then
		VReady:=True;
	
	if PReal(Data.FPoint)<>nil then
		if IsComponent then
			TSGProgressBar(Data.FPoint).FNeedProgress:=(i-Data.h1)/(Data.h2-Data.h1)
		else
			PReal(Data.FPoint)^:=(i-Data.h1)/(Data.h2-Data.h1);
	
	while Data.FWait do
		begin
		if Data.NewPos<>0 then
			begin
			Data.h2:=Data.NewPos-1;
			Data.FWait:=False;
			Data.NewPos:=0;
			end;
		Delay(5);
		end;
	if i+1>Data.h2 then
		Break;
	//Inc(i);
	end;
//until hh2<i;
ii:=Byte(VBufferNow);
while ii<Width do
	begin
	VKolRec:=Rec(SGComplexNumberImport(FView.x1+rX/Width*ii,FView.y1+rY/Height*i));
	InitColor(ii,i,VKolRec);
	ii+=2;
	end;
end;

function TSGFractalMandelbrod.Rec(Number:TSGComplexNumber):LongInt;inline;
var 
	Depth2:longint = 0;
	Number2:TSGComplexNumber;
begin
Number2:=Number;
While (Depth2<FZQuantityRec) and(SGAbsTwoVertex2f(Number,SGVertex2fImport)<2) do
	begin
	Depth2+=1;
	Number:=Number**FZDegree;
	if FZMand then
		Number+=Number2
	else
		Number+=FZNumber;
	end;
Result:=Depth2;
end;

procedure TSGFractalMandelbrod.Calculate;
begin
inherited;
BeginCalculate;
CalculateFromThread(TSGFractalMandelbrodThreadData.Create(Self,0,Depth-1,nil,-1));
ToTexture;
end;


{$ENDIF}
