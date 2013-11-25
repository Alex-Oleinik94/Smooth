{$IFDEF SGREADINTERFACE}
type
	TSGMandaPixel=record
		r,g,b:Byte;
		end;
	
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
		
		FAttitudeForThemeEnable:Boolean;
		FTheme1,FTheme2:SGByte;
		FFAttitudeForTheme:Real;
		procedure InitColor(const x,y:LongInt;const RecNumber:LongInt);override;
		function Rec(Number:TSGComplexNumber):Word;inline;
			public
		function GetPixelColor(const VColorSceme:SGByte;const RecNumber:Word):TSGMandaPixel;inline;
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
		
		//Time
		FDateTime:TSGDateTime;
		FBeginCalc:TSGDateTime;
		
		//Bezier Curve
		FEnablePictureStripPanel:Boolean;
		FBezierCurve:TSGBezierCurve;
		
		FButtonEnableCurve:TSGButton;
		FBezierCurvePanel:TSGPanel;
		FBezierCurveEditKadr:TSGEdit;
		FBezierCurveLabelPoints:TSGLabel;
		FBezierCurveGoButton:TSGButton;
		
		FBezierCurveKadrProgressBar:TSGProgressBar;
		
		FEnablePictureStripAddingPoints:Boolean;
		FKomponentsNowOffOn:Boolean;
		FBezierNowSelectPoint:TSGMaxEnum;
		FNowRenderitsiaVideo:Boolean;
		
		FVideoBuffer:String;
		
		FNowKadr:QWord;
		FAllKadrs:QWOrd;
		
		FCurveArPoints:packed array of SGByte;
		FCurveSelectPoint:Int64;
		
		FCurvePointPanel:TSGPanel;
		FCurvePCB:TSGCOmboBox;
		FCurveInfoLbl:TSGLabel;
		FCurveBeginDataTime:TSGDataTime;
		
		FTNRF:TSGFont;
			public
		procedure UnDatePointCurvePanel();inline;
		procedure DrawBezierPoints();inline;
		procedure OffComponents();inline;
		procedure OnComponents();inline;
		procedure InitManda();inline;
		function GetPointOnPosOnMand(const Point:SGPoint):TSGComplexNumber;inline;
		procedure UpDateLabelCoordCaption();inline;
		end;
{$ENDIF}

{$IFDEF SGREADIMPLEMENTATION}

procedure TSGFractalMandelbrodRelease.UnDatePointCurvePanel();inline;
begin
if FCurveSelectPoint=-1 then
	begin
	FCurvePointPanel.Visible:=False;
	FCurvePointPanel.Active:=False;
	end
else
	begin
	FCurvePointPanel.Visible:=True;
	FCurvePointPanel.Active:=True;
	if (FCurvePCB<>nil) and (FCurveSelectPoint<>-1) then
		begin
		FCurvePCB.FSelectItem:=FCurveArPoints[FCurveSelectPoint];
		end;
	end;
end;

procedure TSGFractalMandelbrodRelease.DrawBezierPoints();inline;
var
	A:TSGVertex3f;
	i:TSGMaxEnum;
	S:Extended;
	PC:TSGVertex2f;
begin
if (FBezierCurve<>nil) and (FBezierCurve.VertexQuantity>0) then
	begin
	S:=Abs(Manda.FView.y1-Manda.FView.y2)/60;
	Render.Color4f(1,1,0,0.5);
	Render.BeginScene(SGR_QUADS);
	for i:=0 to FBezierCurve.VertexQuantity-1 do
		begin
		if i=FCurveSelectPoint then
			Render.Color4f(1,0.2,0,0.4);
		A:=FBezierCurve.Vertexes[i];
		Render.Vertex2f(A.x+S,A.y+S);
		Render.Vertex2f(A.x-S,A.y+S);
		Render.Vertex2f(A.x-S,A.y-S);
		Render.Vertex2f(A.x+S,A.y-S);
		if (Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGDownKey) then
			begin
			PC:=GetPointOnPosOnMand(Context.CursorPosition(SGNowCursorPosition));
			if (abs(PC.x-A.x)<(S)) and ((abs(PC.y-A.y)<(S))) and (FCurveSelectPoint<>i) then
				begin
				FCurveSelectPoint:=i;
				Context.FCursorKeyPressed:=SGNoCursorButton;
				UnDatePointCurvePanel();
				end;
			end;
		if i=FCurveSelectPoint then
			Render.Color4f(1,1,0,0.5);
		end;
	Render.EndScene();
	
	Render.Color4f(1,1,0,0.9);
	for i:=0 to FBezierCurve.VertexQuantity-1 do
		begin
		if i=FCurveSelectPoint then
			Render.Color4f(1,0.2,0,0.4);
		Render.BeginScene(SGR_LINE_LOOP);
		A:=FBezierCurve.Vertexes[i];
		Render.Vertex2f(A.x+S,A.y+S);
		Render.Vertex2f(A.x-S,A.y+S);
		Render.Vertex2f(A.x-S,A.y-S);
		Render.Vertex2f(A.x+S,A.y-S);
		Render.EndScene();
		if i=FCurveSelectPoint then
			Render.Color4f(1,1,0,0.9);
		end;
	end;
end;

procedure TSGFractalMandelbrodRelease.UpDateLabelCoordCaption();inline;
var
	Point:SGPoint;
begin
Point:=Context.CursorPosition(SGNowCursorPosition);
LabelCoord.Caption:=SGStringToPChar('( '+SGFloatToString(Manda.FZNumber.x,3)+' ; '+SGFloatToString(Manda.FZNumber.y,3)+' ) , ( '+
	SGFloatToString(GetPointOnPosOnMand(Point).x,7)+' ; '
	+SGFloatToString(GetPointOnPosOnMand(Point).y,7)+' )');
end;


procedure TSGFractalMandelbrodRelease.OffComponents();inline;
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
FButtonEnableCurve.Visible:=False;
FButtonEnableCurve.Active:=False;
StepenComboBox.Visible:=False;
StepenComboBox.Active:=False;
QuantityRecComboBox.Visible:=False;
QuantityRecComboBox.Active:=False;
FBezierCurvePanel.Active:=False;
FBezierCurvePanel.Visible:=False;
FKomponentsNowOffOn:=False;
FCurvePointPanel.Visible:=False;
FCurvePointPanel.Active:=False;
end;

procedure TSGFractalMandelbrodRelease.OnComponents();inline;
begin
FKomponentsNowOffOn:=True;
ScreenshotPanel.Visible:=not FEnablePictureStripPanel;
ScreenshotPanel.Active:=not FEnablePictureStripPanel;
FBezierCurvePanel.Active:=FEnablePictureStripPanel;
FBezierCurvePanel.Visible:=FEnablePictureStripPanel;
ColorComboBox.Visible:=True;
ColorComboBox.Active:=True;
TypeComboBox.Visible:=True;
TypeComboBox.Active:=True;
ZumButton.Visible:=True;
ZumButton.Active:=True;
ButtonSelectZNumber.Visible:=True;
ButtonSelectZNumber.Active:=True;
FButtonEnableCurve.Visible:=True;
FButtonEnableCurve.Active:=True;
StepenComboBox.Visible:=True;
StepenComboBox.Active:=True;
QuantityRecComboBox.Visible:=True;
QuantityRecComboBox.Active:=True;
FCurvePointPanel.Visible:=FEnablePictureStripPanel and (FCurveSelectPoint<>-1);
FCurvePointPanel.Active:=FCurvePointPanel.Visible;
end;

procedure SaveImage(Button:TSGButton);
begin
with TSGFractalMandelbrodRelease(Button.FUserPointer1) do
	begin
	Manda.Width:=SGVal((Button.Parent.LastChild.Caption));
	Manda.Height:=Trunc(SGVal((Button.Parent.LastChild.Caption))*(Context.Height/Context.Width));
	Changet:=True;
	NowSave:=True;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	end;
end;

procedure CurveColorComboBoxProcedure(a,b:LongInt;Button:TSGComponent);
begin
with TSGFractalMandelbrodRelease(Button.FUserPointer1) do
	begin
	if FCurveSelectPoint<>-1 then
		FCurveArPoints[FCurveSelectPoint]:=b;
	end;
end;


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
		SelectPoint.Import();
		SelectSecondPoint.Import();
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
	begin
	SelectZNimberFlag:=True;
	OffComponents();
	end;
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

function MyMandNumberFucntionVideo(const Self:TSGEdit):boolean;
begin
Result:=TSGEditTextTypeFunctionNumber(Self);
with TSGFractalMandelbrodRelease(Self.FUserPointer1) do
TSGComponent(Self.FUserPointer2).Active:=Result and (FBezierCurve<>nil) and (FBezierCurve.VertexQuantity>=2);
end;

procedure bcpOnOffVideo(Button:TSGButton);
begin
with TSGFractalMandelbrodRelease(Button.FUserPointer1) do
	begin
	FEnablePictureStripPanel:=not FEnablePictureStripPanel;
	OnComponents();
	if FEnablePictureStripPanel then
		begin
		Button.Caption:='Off видео панель';
		FBezierCurve:=TSGBezierCurve.Create();
		FBezierCurve.SetContext(FContext);
		FBezierCurveGoButton.Active:=False;
		end
	else
		begin
		Button.Caption:='On видео панель';
		if FBezierCurve<>nil then
			FBezierCurve.Destroy();
		FBezierCurve:=nil;
		if FCurveArPoints<>nil then
			SetLength(FCurveArPoints,0);
		FCurveSelectPoint:=-1;
		FCurvePointPanel.Visible:=False;
		FCurveArPoints:=nil;
		FEnablePictureStripAddingPoints:=False;
		FBezierCurvePanel.Children[1].Caption:='On режим добавления точек';
		FBezierCurveLabelPoints.Caption:='Количество точек: 0';
		end;
	end;
end;

procedure bcpGoVideo(Button:TSGButton);
begin
with TSGFractalMandelbrodRelease(Button.FUserPointer1) do
	begin
	OffComponents();
	FCurveInfoLbl.Visible:=True;
	FBezierCurveKadrProgressBar.Visible:=True;
	FBezierCurveKadrProgressBar.Progress:=0;
	FNowKadr:=0;
	FAllKadrs:=SGVal(FBezierCurveEditKadr.Caption);
	FNowRenderitsiaVideo:=True;
	Changet:=True;
	SelectPoint.Import();
	SelectSecondPoint.Import();
	Manda.FZMand:=False;
	FVideoBuffer:=SGGetFreeDirectoryName(DataDirectory+Slash+'Images'+Slash+'Manda Buffer','Part');
	SGMakeDirectory(FVideoBuffer);
	Manda.Width:=1920;
	Manda.Height:=1080;
	FCurveBeginDataTime.Get();
	end;
end;

procedure bcpAddPoint(Button:TSGButton);
begin
with TSGFractalMandelbrodRelease(Button.FUserPointer1) do
	begin
	FEnablePictureStripAddingPoints:= not FEnablePictureStripAddingPoints;
	if FEnablePictureStripAddingPoints then
		Button.Caption:='Off режим добавления точек'
	else
		Button.Caption:='On режим добавления точек';
	end;
end;

procedure TSGFractalMandelbrodRelease.InitManda();inline;
var
	i:LongInt;
	ii:LongInt = 5;
	VNameThemes:packed array of string = nil;

procedure AddNameTheme(const s:string);inline;
begin
if VNameThemes=nil then
	SetLength(VNameThemes,1)
else
	SetLength(VNameThemes,Length(VNameThemes)+1);
VNameThemes[High(VNameThemes)]:=s;
end;

begin
AddNameTheme('Стандартная');
AddNameTheme('Молнии');
AddNameTheme('Кучка гавна');
AddNameTheme('Монохромный');
AddNameTheme('Дьявол');
AddNameTheme('Желтая пыль');
AddNameTheme('Роза');
AddNameTheme('Плесень');
AddNameTheme('Медуза');
AddNameTheme('Грибок');
AddNameTheme('Амёба');
AddNameTheme('Сакура');
AddNameTheme('Голубая пыль');
AddNameTheme('Красная пыль');
AddNameTheme('Розовая пыль');
AddNameTheme('Зеленая пыль');
AddNameTheme('Оранжевая пыль');

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
	SGScreen.LastChild.BoundsToNeedBounds();
	FArProgressBar[i].AutoTopShift:=True;
	ii+=23;
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
for i:=0 to High(VNameThemes) do
	SGScreen.LastChild.AsComboBox.CreateItem(VNameThemes[i]);
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

FCurveInfoLbl:=TSGLabel.Create();
SGScreen.CreateChild(FCurveInfoLbl);
SGScreen.LastChild.SetBounds(Context.Width-10-(130+140+10)-150-5,Context.Height-30-25,-(-(130+140+10)-150-5),20);
SGScreen.LastChild.Anchors:=[SGAnchRight,SGAnchBottom];

FBezierCurveKadrProgressBar:=TSGProgressBar.Create();
SGScreen.CreateChild(FBezierCurveKadrProgressBar);
SGScreen.LastChild.SetBounds(Context.Width-10-(130+140+10)-150-5,Context.Height-30,-(-(130+140+10)-150-5),20);
SGScreen.LastChild.AsProgressBar.ViewProgress:=True;
SGScreen.LastChild.AsProgressBar.FColor1:=SGColorImport(1,1,0,0.7);
SGScreen.LastChild.AsProgressBar.FColor2:=SGColorImport(1,1/3,0,0.9);
SGScreen.LastChild.Anchors:=[SGAnchRight,SGAnchBottom];

FButtonEnableCurve:=TSGButton.Create();
SGScreen.CreateChild(FButtonEnableCurve);
SGScreen.LastChild.SetBounds(Context.Width-10-(130+140+10)-150-5,Context.Height-30,150,20);
SGScreen.LastChild.AutoTopShift:=False;
SGScreen.LastChild.Anchors:=[SGAnchRight,SGAnchBottom];
SGScreen.LastChild.Caption:='On видео панель';
FButtonEnableCurve.OnChange:=TSGComponentProcedure(@bcpOnOffVideo);
SGScreen.LastChild.FUserPointer1:=Self;

FCurvePointPanel:=TSGPanel.Create();
SGScreen.CreateChild(FCurvePointPanel);
SGScreen.LastChild.Caption:='';
SGScreen.LastChild.SetBounds(Context.Width-10-(140+10),Context.Height-130-130,140+10,125);
SGScreen.LastChild.Anchors:=[SGAnchBottom,SGAnchRight];
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.FUserPointer1:=Self;

FCurvePointPanel.CreateChild(TSGComboBox.Create);
FCurvePointPanel.LastChild.SetBounds(5,5,130,20);
for i:=0 to High(VNameThemes) do
	FCurvePointPanel.LastChild.AsComboBox.CreateItem(VNameThemes[i]);
FCurvePointPanel.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@CurveColorComboBoxProcedure);
FCurvePointPanel.LastChild.AsComboBox.SelectItem:=0;
FCurvePointPanel.LastChild.AsComboBox.MaxLines:=5;
FCurvePCB:=FCurvePointPanel.LastChild.AsComboBox;
FCurvePointPanel.LastChild.FUserPointer1:=Self;

FBezierCurvePanel:=TSGPanel.Create();
SGScreen.CreateChild(FBezierCurvePanel);
SGScreen.LastChild.Caption:='';
SGScreen.LastChild.SetBounds(Context.Width-10-(130+140+10),Context.Height-130,130+140+10,125);
SGScreen.LastChild.Anchors:=[SGAnchBottom,SGAnchRight];
SGScreen.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.FUserPointer1:=Self;

FBezierCurvePanel.CreateChild(TSGButton.Create());
FBezierCurvePanel.LastChild.AsButton.Caption:='On режим добавления точек';
FBezierCurvePanel.LastChild.AsButton.SetBounds(3,3,275,20);
FBezierCurvePanel.LastChild.AsButton.OnChange:=TSGComponentProcedure(@bcpAddPoint);
FBezierCurvePanel.LastChild.FUserPointer1:=Self;
FBezierCurvePanel.LastChild.BoundsToNeedBounds();


FBezierCurveLabelPoints:=TSGLabel.Create();
FBezierCurvePanel.CreateChild(FBezierCurveLabelPoints);
FBezierCurvePanel.LastChild.Caption:='Количество точек: 0';
FBezierCurvePanel.LastChild.SetBounds(3,25,275,20);
FBezierCurvePanel.LastChild.FUserPointer1:=Self;
FBezierCurvePanel.LastChild.BoundsToNeedBounds();

FBezierCurvePanel.CreateChild(TSGLabel.Create());
FBezierCurvePanel.LastChild.Caption:='Количество кадров:';
FBezierCurvePanel.LastChild.AsLabel.FTextPosition:=0;
FBezierCurvePanel.LastChild.SetBounds(3,47,137,20);
FBezierCurvePanel.LastChild.FUserPointer1:=Self;
FBezierCurvePanel.LastChild.BoundsToNeedBounds();

FBezierCurveEditKadr:=TSGEdit.Create();
SGScreen.LastChild.CreateChild(FBezierCurveEditKadr);
SGScreen.LastChild.LastChild.SetBounds(123,47,137,20);
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.FUserPointer1:=Self;
(SGScreen.LastChild.LastChild as TSGEdit).TextTypeFunction:=TSGEditTextTypeFunction(@MyMandNumberFucntionVideo);
(SGScreen.LastChild.LastChild as TSGEdit).TextType:=SGEditTypeUser;
SGScreen.LastChild.LastChild.Caption:='200';

FBezierCurvePanel.CreateChild(TSGLabel.Create());
FBezierCurvePanel.LastChild.Caption:='Примерно займет времени: дохрена!';
FBezierCurvePanel.LastChild.SetBounds(3,70,275,20);
FBezierCurvePanel.LastChild.FUserPointer1:=Self;
FBezierCurvePanel.LastChild.BoundsToNeedBounds();

FBezierCurveGoButton:=TSGButton.Create();
FBezierCurvePanel.CreateChild(FBezierCurveGoButton);
FBezierCurvePanel.LastChild.AsButton.Caption:='Начать и пусть весь мир подождет';
FBezierCurvePanel.LastChild.AsButton.SetBounds(3,92,275,20);
FBezierCurvePanel.LastChild.AsButton.OnChange:=TSGComponentProcedure(@bcpGoVideo);
FBezierCurvePanel.LastChild.FUserPointer1:=Self;
FBezierCurvePanel.LastChild.BoundsToNeedBounds();
FBezierCurveEditKadr.FUserPointer2:=Pointer(FBezierCurvePanel.LastChild);

if VNameThemes<>nil then
	begin
	for i:=0 to High(VNameThemes) do
		VNameThemes[i]:='';
	SetLength(VNameThemes,0);
	end;
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
FTNRF:=nil;
FCurvePointPanel:=nil;
FCurveSelectPoint:=-1;
FCurveArPoints:=nil;
FNowRenderitsiaVideo:=False;
FBezierNowSelectPoint:=0;
FKomponentsNowOffOn:=False;
FBezierCurveEditKadr:=nil;
FEnablePictureStripAddingPoints:=False;
FBezierCurvePanel:=nil;
FButtonEnableCurve:=nil;
FBezierCurve:=nil;
FEnablePictureStripPanel:=False;
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
FCurveInfoLbl:=nil;

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
SGScreen.LastChild.LastChild.AsComboBox.FSelectItem:=4;
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('64');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('128');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('256');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('512');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('1024');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('2048');
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
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('10');
SGScreen.LastChild.LastChild.AsComboBox.CreateItem('12');
SGScreen.LastChild.LastChild.BoundsToNeedBounds;
SGScreen.LastChild.LastChild.FUserPointer1:=Self;

FTNRF:=TSGFont.Create(SGGetCurrentDirectory()+'.'+Slash+'..'+Slash+'Data'+Slash+'Fonts'+Slash+'Times New Roman.bmp');
FTNRF.SetContext(FContext);
FTNRF.Loading;
end;

destructor TSGFractalMandelbrodRelease.Destroy();
var
	i:TSGMaxEnum;
begin
if FCurveInfoLbl<>nil then
	FCurveInfoLbl.Destroy();
if FTNRF<>nil then
	FTNRF.Destroy();
if FCurvePointPanel<>nil then
	FCurvePointPanel.Destroy();
if FCurveArPoints<>nil then
	SetLength(FCurveArPoints,0);
if FBezierCurveKadrProgressBar<> nil then
	FBezierCurveKadrProgressBar.Destroy();
if FBezierCurvePanel<>nil then
	FBezierCurvePanel.Destroy();
if FButtonEnableCurve<>nil then
	FButtonEnableCurve.Destroy();
if FBezierCurve<>nil then
	FBezierCurve.Destroy();
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

{function QuantityNumbers(a:TSGMaxEnum):byte;inline;
begin
Result:=0;
while a>0 do
	begin
	a:=a div 10;
	Inc(Result);
	end;
end;

function GetZeros(const QZ:byte):string;
var
	i:byte;
begin
Result:='';
for i:=1 to QZ do
	Result+='0';
end;}

procedure TSGFractalMandelbrodRelease.Draw();
var
	i,ii:LongInt;
	TDT:TSGDateTime;
begin
if MandaInitialized then
	begin
	Render.InitMatrixMode(SG_2D);
	
	if Manda.ThreadsReady  then
		begin
		Delay(5);
		Manda.AfterCalculate();
		
		for i:=0 to QuantityThreads-1 do
			begin
			FArProgressBar[i].Visible:=False;
			//SGScreen.Children[CID-QuantityThreads+i+2].AsProgressBar.Visible:=False;
			end;
		
		FDateTime.Get();
		if not FNowRenderitsiaVideo then
			begin
			LabelProcent.Visible:=False;
			LblProcent.Visible:=False;
			end;
		LabelProcent.Caption:='100%';
		LblProcent.Caption:=SGStringToPChar('100%, Прошло: '+
			(
			SGSecondsToStringTime(
			(FDateTime-FBeginCalc).GetPastSeconds))+'.');
		
		if (not NowSave)  and (not FNowRenderitsiaVideo) then
			begin
			Manda.ToTexture();
			OnComponents();
			{if SecondImage<>nil then
				begin
				SecondImage.Destroy;
				SecondImage:=nil;
				end;}
			end
		else 
			if Manda.FImage<>nil then
				begin
				if not DirectoryExists(DataDirectory+Slash+'Images') then
					MkDir(DataDirectory+Slash+'Images');
				if FNowRenderitsiaVideo then
					begin
					if not DirectoryExists(DataDirectory+Slash+'Videos') then
						MkDir(DataDirectory+Slash+'Videos');
					Manda.FImage.Way:=FVideoBuffer+Slash+
						//GetZeros(QuantityNumbers(FAllKadrs)-QuantityNumbers(FNowKadr))+
						SGStr(FNowKadr)+'.png';
					end;
				Manda.FImage.AddWaterString('made by SaGe',FTNRF,0);
				Manda.FImage.Saveing(SGI_PNG);
				if not FNowRenderitsiaVideo then
					begin
					Manda.Width:=StartDepth;
					Manda.Height:=StartDepth;
					end;
				Manda.FImage.Destroy();
				Manda.FImage:=nil;
				if not FNowRenderitsiaVideo then
					begin
					Manda.FImage:=SecondImage;
					SecondImage:=nil;
					end;
				if FNowRenderitsiaVideo then
					Changet:=True;
				NowSave:=False;
				end;
		end;
	
	UpDateLabelCoordCaption();
	
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


	if (Manda.FImage<>nil) and Manda.FImage.Ready then
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
				OnComponents();
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
		if SelectPointEnabled and (Context.CursorKeysPressed(SGLeftCursorButton)) then
			begin
			//Тут херачится новый зум
			SelectSecondPoint:=SelectSecondNormalPoint;
			
			SelectPointEnabled:=False;
			if SelectPoint.x>SelectSecondPoint.x then
				SGQuickRePlaceLongInt(SelectPoint.x,SelectSecondPoint.x);
			if SelectPoint.y>SelectSecondPoint.y then
				SGQuickRePlaceLongInt(SelectPoint.y,SelectSecondPoint.y);
			Manda.FView.Import(
				GetPointOnPosOnMand(SelectPoint).x,
				GetPointOnPosOnMand(SelectSecondPoint).y,
				GetPointOnPosOnMand(SelectSecondPoint).x,
				GetPointOnPosOnMand(SelectPoint).y
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
	
	if FEnablePictureStripAddingPoints  and 
		(Context.KeyPressedChar='A') and 
		(Context.KeyPressedType=SGUpKey) then
		begin
		if FCurveArPoints=nil then
			SetLength(FCurveArPoints,1)
		else 
			SetLength(FCurveArPoints,Length(FCurveArPoints)+1);
		FCurveArPoints[High(FCurveArPoints)]:=Manda.FColorScheme;
		FBezierCurve.AddVertex(
			SGVertexImport(
				GetPointOnPosOnMand(Context.CursorPosition(SGNowCursorPosition)).x,
				GetPointOnPosOnMand(Context.CursorPosition(SGNowCursorPosition)).y));
		FBezierCurve.Detalization:=FBezierCurve.VertexQuantity*10;
		FBezierCurve.Calculate();
		Context.FKeyPressed:=0;
		FBezierCurveLabelPoints.Caption:='Количество точек: '+SGStr(FBezierCurve.VertexQuantity);
		FBezierCurveGoButton.Active:=(FBezierCurve.VertexQuantity>=2) and (TSGEditTextTypeFunctionNumber(FBezierCurveEditKadr));
		end;
	
	if FEnablePictureStripPanel  then
		begin
		//Manda.FView.Write();
		Render.InitOrtho2d(Manda.FView.x1,Manda.FView.y1,Manda.FView.x2,Manda.FView.y2);
		if FBezierCurve<>nil then
			begin
			FBezierCurve.Draw();
			Render.Color3f(1,0,1);
			Render.PointSize(5);
			Render.BeginScene(SGR_POINTS);
			Manda.FZNumber.Vertex(Render);
			Render.EndScene();
			Render.PointSize(1);
			end;
		if FKomponentsNowOffOn then
			DrawBezierPoints();
		end;
	
	if Changet then
		begin
		if FNowRenderitsiaVideo then
			begin
			FNowKadr+=1;
			if FNowKadr>FAllKadrs then
				begin
				FNowRenderitsiaVideo:=False;
				Changet:=False;
				Manda.FImage:=SecondImage;
				SecondImage:=nil;
				FBezierCurveKadrProgressBar.Visible:=False;
				Manda.FAttitudeForThemeEnable:=False;
				FCurveInfoLbl.Visible:=False;
				Exit;
				end
			else
				FBezierCurveKadrProgressBar.Progress:=(FNowKadr-1)/FAllKadrs;
			end;
		OffComponents();
		if not FNowRenderitsiaVideo then
			if SecondImage<>nil then
				SecondImage.Destroy;
		if (not FNowRenderitsiaVideo) or (FNowRenderitsiaVideo and (Manda.FImage<>nil)) then
			begin
			SecondImage:=Manda.FImage;
			Manda.FImage:=nil;
			end;
		if FNowRenderitsiaVideo then
			begin
			Manda.FZNumber.x:=FBezierCurve.GetResultVertex(FNowKadr/FAllKadrs).x;
			Manda.FZNumber.y:=FBezierCurve.GetResultVertex(FNowKadr/FAllKadrs).y;
			Manda.FAttitudeForThemeEnable:=True;
			Manda.FFAttitudeForTheme:=FBezierCurve.LowAttitude;
			if FBezierCurve.LowIndex<>FBezierCurve.VertexQuantity-1 then
				begin
				Manda.FTheme1:=FCurveArPoints[FBezierCurve.LowIndex];
				Manda.FTheme2:=FCurveArPoints[FBezierCurve.LowIndex+1];
				end
			else
				begin
				Manda.FTheme1:=FCurveArPoints[FBezierCurve.LowIndex];
				Manda.FTheme2:=FCurveArPoints[FBezierCurve.LowIndex];
				end;
			TDT.Get();
			if FNowKadr<>1 then
				FCurveInfoLbl.Caption:='Прошло: '+
					SGSecondsToStringTime((TDT-FCurveBeginDataTime).GetPastSeconds)
					+', Осталось: '+
					SGSecondsToStringTime(Trunc(
					(TDT-FCurveBeginDataTime).GetPastSeconds/((FNowKadr-1)/FAllKadrs)*(1-(FNowKadr-1)/FAllKadrs)
					))
					+', FPS: '+SGStrReal(FNowKadr/(TDT-FCurveBeginDataTime).GetPastSeconds,3)+' к/с';
			end;
		if (not FNowRenderitsiaVideo) and (not NowSave) then
			begin
			Manda.Width:=StartDepth;
			Manda.Height:=StartDepth;
			end;
		Manda.BeginCalculate();
		Manda.FImage.Way:=SGGetFreeFileName(DataDirectory+Slash+'Images'+Slash+'Mand New.png');
		LabelProcent.Visible:=True;
		LblProcent.Visible:=True;
		ii:={Context.TopShift+}40;
		FBeginCalc.Get;
		Manda.ThreadsBoolean();
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
FTheme1:=0;
FTheme2:=0;
FFAttitudeForTheme:=0;
FAttitudeForThemeEnable:=False;
FImage:=nil;
FZNumber.Import(0,0.65);
FView.Import(-1.5,-1.5*(Context.Height/Context.Width),1.5,1.5*(Context.Height/Context.Width));
FZMand:=False;
FZDegree:=2;
FZQuantityRec:=256;
FColorScheme:=0;
end;

function TSGFractalMandelbrod.GetPixelColor(const VColorSceme:SGByte;const RecNumber:Word):TSGMandaPixel;inline;
var
	Color:Byte;

function YellowPil():TSGMandaPixel;
begin
	Result.r := trunc(abs(cos(Color) * Color));
	Result.g := GetColor(Color Div 2,Color ** 2,trunc(abs((cos(Color) ** 2) * Result.r)));
	if Color <> 0 then
		Result.b := GetColor(
			Result.g, 
			Result.r, 
			(sqr(Result.r)
		) DIV Color) DIV 128
	else
		Result.b := GetColor(
			Result.g, 
			Result.r, 
			(sqr(Result.r)
		) DIV 255) DIV 158;
end;

procedure SwapByte(var a,b:byte);inline;
var 
	c:byte;
begin
c:=a;
a:=b;
b:=c;
end;

begin
Color:=Round((RecNumber/20)*255);
case VColorSceme of
1:
	begin
	if RecNumber=FZQuantityRec then
		begin
		Result.r:=200;
		Result.g:=0;
		Result.b:=255;
		end
	else
		begin
		Result.r:=GetColor(0,383,Color) div 2;
		Result.g:=GetColor(128,896,Color);
		Result.b:=GetColor(0,383,Color);
		end;
	end;
2:
	begin
	Result.r:=GetColorOne(FZQuantityRec div 4,FZQuantityRec,Color);
	Result.g:=GetColorOne(0,FZQuantityRec,Color);
	Result.b:=GetColorOne(FZQuantityRec div 2,FZQuantityRec,Color);
	end;
3:
	begin
	Color:=Trunc(RecNumber/FZQuantityRec*255);
	Result.r:=Color;
	Result.g:=Color;
	Result.b:=Color; 
	end;

4:
	begin
		Result.r := Color;
		Result.g := (SizeOf(FImage.FImage.FBitMap) * Color) div 255;
		Result.b := 0;	// nil
	end;

5:
	begin
		Result:=YellowPil();
	end;

6:
	begin
		Result.r:= trunc(abs(sin(Color) * Color));
		Result.g := GetColor(
			128, 
			383, 
			trunc(abs(cos(Color) * Result.r))
		);
		if (Result.g < Result.r) then
			Result.b := 
				(sqr(Result.r)) DIV 255
		else
			Result.b := 
				(sqr(Result.g)) DIV 255;
	end;
7:
	begin
	Result.b:=GetColor(0,383,Color) div 2;
	Result.r:=GetColor(128,896,Color);
	Result.g:=GetColor(0,383,Color);
	end;
8:
	begin
	Result.g:=GetColor(0,383,Color) div 2;
	Result.r:=GetColor(128,896,Color);
	Result.b:=GetColor(0,383,Color);
	end;
9:
	begin
	Result.g:=GetColor(0,383,Color) div 2;
	Result.b:=GetColor(128,896,Color);
	Result.r:=GetColor(0,383,Color);
	end;
10:
	begin
	Result.r:=GetColor(0,383,Color) div 2;
	Result.b:=GetColor(128,896,Color);
	Result.g:=GetColor(0,383,Color);
	end;
11:
	begin
	Result.b:=GetColor(0,383,Color) div 2;
	Result.g:=GetColor(128,896,Color);
	Result.r:=GetColor(0,383,Color);
	end;
12:
	begin
		Result:=YellowPil();
		SwapByte(Result.r,Result.b);
	end;
13:
	begin
		Result:=YellowPil();
		SwapByte(Result.g,Result.b);
	end;
14:
	begin
		Result:=YellowPil();
		SwapByte(Result.r,Result.b);
		SwapByte(Result.g,Result.r);
	end;
15:
	begin
		Result:=YellowPil();
		SwapByte(Result.r,Result.b);
		SwapByte(Result.g,Result.b);
	end;
16:
	begin
		Result:=YellowPil();
		SwapByte(Result.r,Result.g);
	end;
else
	begin
	if RecNumber=FZQuantityRec then
		begin
		Result.r:=255;
		Result.g:=127;
		Result.b:=0;
		end
	else
		begin
		Result.r:=GetColor(200,400,Color);
		Result.g:=GetColor(0,200,Color);
		Result.b:=GetColor(100,300,Color);
		end;
	end;
end;
end;

procedure TSGFractalMandelbrod.InitColor(const x,y:LongInt;const RecNumber:LongInt);inline;
var
	MandaPixel1,MandaPixel2:TSGMandaPixel;
begin
if FAttitudeForThemeEnable then
	begin
	MandaPixel1:=GetPixelColor(FTheme1,RecNumber);
	MandaPixel2:=GetPixelColor(FTheme2,RecNumber);
	MandaPixel1.r:=Round(MandaPixel1.r*(1-FFAttitudeForTheme)+FFAttitudeForTheme*MandaPixel2.r);
	MandaPixel1.g:=Round(MandaPixel1.g*(1-FFAttitudeForTheme)+FFAttitudeForTheme*MandaPixel2.g);
	MandaPixel1.b:=Round(MandaPixel1.b*(1-FFAttitudeForTheme)+FFAttitudeForTheme*MandaPixel2.b);
	end
else
	begin
	MandaPixel1:=GetPixelColor(FColorScheme,RecNumber);
	end;
FImage.FImage.FBitMap[(Y*Width+X)*3+0]:=MandaPixel1.r;
FImage.FImage.FBitMap[(Y*Width+X)*3+1]:=MandaPixel1.g;
FImage.FImage.FBitMap[(Y*Width+X)*3+2]:=MandaPixel1.b;
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

function TSGFractalMandelbrod.Rec(Number:TSGComplexNumber):Word;inline;
var 
	Depth2:Word = 0;
	Number2:TSGComplexNumber;
begin
Number2:=Number;
While (Depth2<FZQuantityRec) and(sqrt(sqr(Number.x)+sqr(Number.y))<2) do
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
