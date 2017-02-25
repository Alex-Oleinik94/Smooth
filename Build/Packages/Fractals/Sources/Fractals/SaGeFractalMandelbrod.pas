{$INCLUDE SaGe.inc}

unit SaGeFractalMandelbrod;

interface

uses
	 SaGeBase
	,SaGeFractals
	,SaGeCommonClasses
	,SaGeScreen
	,SaGeCommon
	,SaGeImage
	,SaGeDateTime
	,SaGeFont
	,SaGeBezierCurve
	;

type
	TSGMandelbrodPixel = record
		r, g, b : TSGByte;
		end;
	
	TSGFractalMandelbrodThreadData = class;
	TSGFractalMandelbrod=class(TSGImageFractal)
			public
		constructor Create(const VContext : ISGContext);override;
		//destructor Destroy;override;
			public
		FZNumber      : TSGComplexNumber;
		FZDegree      : LongInt;
		FZMand        : Boolean;
		FZQuantityRec : LongInt;
		FColorScheme  : TSGByte;
		
		FAttitudeForThemeEnable : Boolean;
		FTheme1,FTheme2         : TSGByte;
		FFAttitudeForTheme      : Real;
		
		FSmosh : Byte;
		procedure InitColor(const x,y:LongInt;const RecNumber:LongInt);override;
		function Rec(Number:TSGComplexNumber):Word;inline;
		function MandelbrodRec(const Number:TSGComplexNumber;const dx,dy:single):Word;inline;
			public
		function GetPixelColor(const VColorSceme:TSGByte;const RecNumber:Word):TSGMandelbrodPixel;inline;
		procedure CalculateFromThread(Data:TSGFractalMandelbrodThreadData);
		procedure Calculate;override;
		procedure Paint();override;
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
		
		FBeginData:TSGDateTime;//время начала потока
		
		FHePr:LongWord;//Уже сделаный прогресс потока по Height
		end;

procedure TSGFractalMandelbrodThreadProcedure(Data:TSGFractalMandelbrodThreadData);

type
	TSGFractalMandelbrodRelease=class(TSGScreenedDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName() : TSGString;override;
		procedure Paint();override;
			protected
		FNewPotokInit:Boolean;
		SelectPoint,SelectSecondPoint:TSGPoint2int32;
		
		SelectPointEnabled:Boolean;
		Mandelbrod:TSGFractalMandelbrod;
		
		QuantityThreads:LongInt;
		
		NowSave:Boolean;
		NowSaveLastView:TSGScreenVertexes;
		
		SecondImage:TSGImage;
		
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
		
		MandelbrodInitialized:Boolean;
		
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
		
		FCurveArPoints:packed array of TSGByte;
		FCurveSelectPoint:Int64;
		
		FCurvePointPanel:TSGPanel;
		FCurvePCB:TSGCOmboBox;
		FCurveInfoLbl:TSGLabel;
		FCurveBeginDataTime:TSGDateTime;
		
		FTNRF:TSGFont;
		
		FOldView:TSGScreenVertexes;
			public
		procedure UnDatePointCurvePanel();inline;
		procedure DrawBezierPoints();inline;
		procedure OffComponents();inline;
		procedure OnComponents();inline;
		procedure InitMandelbrod();inline;
		function GetPointOnPosOnMand(const Point:TSGPoint2int32):TSGComplexNumber;inline;
		procedure UpDateLabelCoordCaption();inline;
		end;

implementation

uses
	 SaGeStringUtils
	,SaGeFileUtils
	,SaGeRenderBase
	,SaGeThreads
	,SaGeScreenBase
	,SaGeMathUtils
	,SaGeBitMap
	,SaGeSysUtils
	,SaGeBaseUtils
	
	,Crt
	;

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
		FCurvePCB.SelectItem:=FCurveArPoints[FCurveSelectPoint];
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
	S:=Abs(Mandelbrod.FView.y1-Mandelbrod.FView.y2)/60;
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
		if not FNowRenderitsiaVideo then
		if (Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGDownKey) then
			begin
			PC:=GetPointOnPosOnMand(Context.CursorPosition(SGNowCursorPosition));
			if (abs(PC.x-A.x)<(S)) and ((abs(PC.y-A.y)<(S))) and (FCurveSelectPoint<>i) then
				begin
				FCurveSelectPoint:=i;
				Context.SetCursorKey(SGNullKey, SGNullCursorButton);
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
	Point: TSGPoint2int32;
begin
Point:=Context.CursorPosition(SGNowCursorPosition);
LabelCoord.Caption:=SGStringToPChar('( '+SGFloatToString(Mandelbrod.FZNumber.x,3)+' ; '+SGFloatToString(Mandelbrod.FZNumber.y,3)+' ) , ( '+
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
	Mandelbrod.Width:=SGVal((Button.Parent.LastChild.Caption));
	Mandelbrod.Height:=Trunc(SGVal((Button.Parent.LastChild.Caption))*(Render.Height/Render.Width));
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
	Mandelbrod.FColorScheme:=b;
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
	Mandelbrod.FZMand:=Boolean(b);
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
	Mandelbrod.FView.Import(-2.5,-2.5*(Render.Height/Render.Width),2.5,2.5*(Render.Height/Render.Width));
	Changet:=True;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	FOldView:=Mandelbrod.FView;
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
	Mandelbrod.FZQuantityRec:=QuantityRecComboBox.Items[b].Identifier;
	Changet:=True;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	end;
END;

procedure StepenComboBoxProcedure(a,b:LongInt;aaa:TSGComponent);
begin
with TSGFractalMandelbrodRelease(aaa.FUserPointer1) do
	begin
	Mandelbrod.FZDegree:=StepenComboBox.Items[b].Identifier;
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
		FBezierCurve.SetContext(Context);
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
	FCurveInfoLbl.Caption:='Тут будет отображаться информация!!!';
	FBezierCurveKadrProgressBar.Visible:=True;
	FBezierCurveKadrProgressBar.Progress:=0;
	FNowKadr:=0;
	FAllKadrs:=SGVal(FBezierCurveEditKadr.Caption);
	FNowRenderitsiaVideo:=True;
	Changet:=True;
	SelectPoint.Import();
	SelectSecondPoint.Import();
	Mandelbrod.FZMand:=False;
	FVideoBuffer:=SGFreeDirectoryName(SGImagesDirectory + DirectorySeparator + 'Mandelbrod Buffer', 'Part');
	SGMakeDirectory(FVideoBuffer);
	Mandelbrod.Width:=1920;//*5;
	Mandelbrod.Height:=1080;//*5;
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

procedure TSGFractalMandelbrodRelease.InitMandelbrod();inline;
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

Mandelbrod:=TSGFractalMandelbrod.Create(Context);
Mandelbrod.Width:=StartDepth;
Mandelbrod.Height:=StartDepth;
Mandelbrod.FZNumber.Import(-0.181,0.66);
Mandelbrod.FZMand:=False;
Mandelbrod.FZDegree:=2;
Mandelbrod.FView.Import(-2.5,-2.5*(Render.Height/Render.Width),2.5,2.5*(Render.Height/Render.Width));
Mandelbrod.CreateThreads(QuantityThreads);
Mandelbrod.BeginCalculate;
Mandelbrod.FImage.Way:=SGImagesDirectory+DirectorySeparator+'Mand New.jpg';

FBeginCalc.Get;
SetLength(FArProgressBar,QuantityThreads);
ii+={Context.TopShift+}40;
for i:=0 to QuantityThreads-1 do
	begin
	FArProgressBar[i]:=TSGProgressBar.Create;
	Screen.CreateChild(FArProgressBar[i]);
	FArProgressBar[i].ViewCaption := False;
	Screen.LastChild.SetBounds(10,ii,300,20);
	Screen.LastChild.BoundsToNeedBounds();
	ii+=23;
	Screen.LastChild.Visible:=True;
	Screen.LastChild.AsProgressBar.ViewProgress:=True;
	Mandelbrod.BeginThread(i,FArProgressBar[i]);
	end;

LblProcent:=TSGLabel.Create;
Screen.CreateChild(LblProcent);
LblProcent.SetBounds(10,ii,300,20);
LblProcent.Caption:='';
LblProcent.Visible:=True;
LblProcent.FUserPointer1:=Self;

LabelProcent:=TSGProgressBar.Create;
Screen.CreateChild(LabelProcent);
LabelProcent.SetBounds(10,ii,300,20);
LabelProcent.Color2 := SGVertex4fImport(1,0,0,0.8);
LabelProcent.Color1 := SGVertex4fImport(0.5,0,0,0.8);
LabelProcent.Caption:='';
LabelProcent.ViewCaption := False;
LabelProcent.Visible:=True;
LabelProcent.FUserPointer1:=Self;

LabelCoord:=TSGLabel.Create;
Screen.CreateChild(LabelCoord);
Screen.LastChild.SetBounds(10,Render.Height-25,Render.Width div 2,20);
Screen.LastChild.Anchors:=[SGAnchBottom];
Screen.LastChild.Caption:='';
Screen.LastChild.Visible:=True;
Screen.LastChild.AsLabel.TextPosition:=False;
Screen.LastChild.FUserPointer1:=Self;

ScreenshotPanel:=TSGPanel.Create;
Screen.CreateChild(ScreenshotPanel);
Screen.LastChild.Caption:='';
Screen.LastChild.SetBounds(Render.Width-10-(130+140+10),Render.Height-30,130+140+10,25);
Screen.LastChild.Anchors:=[SGAnchBottom,SGAnchRight];
Screen.LastChild.BoundsToNeedBounds;
Screen.LastChild.FUserPointer1:=Self;

Screen.LastChild.CreateChild(TSGButton.Create);
Screen.LastChild.LastChild.SetBounds(130,5,140,20);
Screen.LastChild.LastChild.Caption:='Сохранить';
Screen.LastChild.LastChild.BoundsToNeedBounds;
Screen.LastChild.LastChild.AsButton.OnChange:=TSGComponentProcedure(@SaveImage);
Screen.LastChild.LastChild.FUserPointer1:=Self;

Screen.LastChild.CreateChild(TSGEdit.Create);
Screen.LastChild.LastChild.SetBounds(5,5,120,20);
Screen.LastChild.LastChild.BoundsToNeedBounds;
Screen.LastChild.LastChild.FUserPointer1:=Self;
Screen.LastChild.LastChild.FUserPointer2:=Screen.LastChild.Children[Screen.LastChild.ChildCount()-1];
(Screen.LastChild.LastChild as TSGEdit).TextTypeFunction:=TSGEditTextTypeFunction(@MyMandNumberFucntion);
(Screen.LastChild.LastChild as TSGEdit).TextType:=SGEditTypeUser;
Screen.LastChild.LastChild.Caption:='4096';

Screen.CreateChild(TSGComboBox.Create);
Screen.LastChild.SetBounds(Render.Width-50-125+45,5{+Context.TopShift},120,20);
Screen.LastChild.Anchors:=[SGAnchRight];
for i:=0 to High(VNameThemes) do
	Screen.LastChild.AsComboBox.CreateItem(VNameThemes[i]);
Screen.LastChild.AsComboBox.CallBackProcedure:=TSGComboBoxProcedure(@ColorComboBoxProcedure);
Screen.LastChild.AsComboBox.SelectItem:=0;
ColorComboBox:=Screen.LastChild.AsComboBox;
Screen.LastChild.FUserPointer1:=Self;

TypeComboBox:=TSGComboBox.Create;
Screen.CreateChild(TypeComboBox);
Screen.LastChild.SetBounds(Render.Width-50-125+45-185,5,180,20);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.AsComboBox.CreateItem('Множество Жюлиа');
Screen.LastChild.AsComboBox.CreateItem('Модель Мандельброта');
Screen.LastChild.AsComboBox.CallBackProcedure:=TSGComboBoxProcedure(@TypeComboBoxProcedure);
Screen.LastChild.AsComboBox.SelectItem:=0;
Screen.LastChild.FUserPointer1:=Self;

Screen.CreateChild(TSGButton.Create);
Screen.LastChild.SetBounds(Render.Width-50-125-185+45-105,5,100,20);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Caption:='Сброс зума';
ZumButton:=Screen.LastChild.AsButton;
ZumButton.OnChange:=TSGComponentProcedure(@ZumButtonOnChange);
Screen.LastChild.FUserPointer1:=Self;

Screen.CreateChild(TSGButton.Create);
Screen.LastChild.SetBounds(Render.Width-50-125-185-105+45-125,5{+Context.TopShift},120,20);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Caption:='Установ. тчк.';
ButtonSelectZNumber:=Screen.LastChild.AsButton;
ButtonSelectZNumber.OnChange:=TSGComponentProcedure(@ButtonSelectZNumberOnChange);
Screen.LastChild.FUserPointer1:=Self;

StepenComboBox:=TSGComboBox.Create;
Screen.CreateChild(StepenComboBox);
Screen.LastChild.SetBounds(Render.Width-50-125-185-105-125+45-105,5{+Context.TopShift},100,20);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Caption:='';
Screen.LastChild.BoundsToNeedBounds;
Screen.LastChild.AsComboBox.SelectItem:=1;
Screen.LastChild.AsComboBox.CallBackProcedure:=TSGComboBoxProcedure(@StepenComboBoxProcedure);
Screen.LastChild.FUserPointer1:=Self;
i:=1;
while i<=100 do
	begin
	Screen.LastChild.AsComboBox.CreateItem(SGStringToPChar(SGStr(i)),nil,i);
	i+=1;
	end;

QuantityRecComboBox:=TSGComboBox.Create;
Screen.CreateChild(QuantityRecComboBox);
Screen.LastChild.SetBounds(Render.Width-50-125-185-105-125-105+45-105,5{+Context.TopShift},100,20);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Caption:='';
Screen.LastChild.BoundsToNeedBounds;
Screen.LastChild.AsComboBox.CallBackProcedure:=TSGComboBoxProcedure(@QuantityRecComboBoxProcedure);
Screen.LastChild.FUserPointer1:=Self;
i:=6;
while i<=13 do
	begin
	Screen.LastChild.AsComboBox.CreateItem(SGStringToPChar(SGStr(2**i)),nil,2**i);
	if i=8 then
		begin
		Screen.LastChild.AsComboBox.SelectItem := QuantityRecComboBox.ItemsCount - 1;
		end;
	i+=1;
	end;

FCurveInfoLbl:=TSGLabel.Create();
Screen.CreateChild(FCurveInfoLbl);
Screen.LastChild.SetBounds(Render.Width-10-(130+140+10)-150-5,Render.Height-30-25,-(-(130+140+10)-150-5),20);
Screen.LastChild.Anchors:=[SGAnchRight,SGAnchBottom];

FBezierCurveKadrProgressBar:=TSGProgressBar.Create();
Screen.CreateChild(FBezierCurveKadrProgressBar);
Screen.LastChild.SetBounds(Render.Width-10-(130+140+10)-150-5,Render.Height-30,-(-(130+140+10)-150-5),20);
Screen.LastChild.AsProgressBar.ViewProgress:=True;
Screen.LastChild.AsProgressBar.Color1:=SGVertex4fImport(1,1,0,0.7);
Screen.LastChild.AsProgressBar.Color2:=SGVertex4fImport(1,1/3,0,0.9);
Screen.LastChild.Anchors:=[SGAnchRight,SGAnchBottom];

FButtonEnableCurve:=TSGButton.Create();
Screen.CreateChild(FButtonEnableCurve);
Screen.LastChild.SetBounds(Render.Width-10-(130+140+10)-150-5,Render.Height-30,150,20);
Screen.LastChild.Anchors:=[SGAnchRight,SGAnchBottom];
Screen.LastChild.Caption:='On видео панель';
FButtonEnableCurve.OnChange:=TSGComponentProcedure(@bcpOnOffVideo);
Screen.LastChild.FUserPointer1:=Self;

FCurvePointPanel:=TSGPanel.Create();
Screen.CreateChild(FCurvePointPanel);
Screen.LastChild.Caption:='';
Screen.LastChild.SetBounds(Render.Width-10-(140+10),Render.Height-130-130,140+10,125);
Screen.LastChild.Anchors:=[SGAnchBottom,SGAnchRight];
Screen.LastChild.BoundsToNeedBounds;
Screen.LastChild.FUserPointer1:=Self;

FCurvePointPanel.CreateChild(TSGComboBox.Create);
FCurvePointPanel.LastChild.SetBounds(5,5,130,20);
for i:=0 to High(VNameThemes) do
	FCurvePointPanel.LastChild.AsComboBox.CreateItem(VNameThemes[i]);
FCurvePointPanel.LastChild.AsComboBox.CallBackProcedure:=TSGComboBoxProcedure(@CurveColorComboBoxProcedure);
FCurvePointPanel.LastChild.AsComboBox.SelectItem:=0;
FCurvePointPanel.LastChild.AsComboBox.MaxLines:=5;
FCurvePCB:=FCurvePointPanel.LastChild.AsComboBox;
FCurvePointPanel.LastChild.FUserPointer1:=Self;

FBezierCurvePanel:=TSGPanel.Create();
Screen.CreateChild(FBezierCurvePanel);
Screen.LastChild.Caption:='';
Screen.LastChild.SetBounds(Render.Width-10-(130+140+10),Render.Height-130,130+140+10,125);
Screen.LastChild.Anchors:=[SGAnchBottom,SGAnchRight];
Screen.LastChild.BoundsToNeedBounds;
Screen.LastChild.FUserPointer1:=Self;

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
FBezierCurvePanel.LastChild.AsLabel.TextPosition:=False;
FBezierCurvePanel.LastChild.SetBounds(3,47,137,20);
FBezierCurvePanel.LastChild.FUserPointer1:=Self;
FBezierCurvePanel.LastChild.BoundsToNeedBounds();

FBezierCurveEditKadr:=TSGEdit.Create();
Screen.LastChild.CreateChild(FBezierCurveEditKadr);
Screen.LastChild.LastChild.SetBounds(123,47,137,20);
Screen.LastChild.LastChild.BoundsToNeedBounds;
Screen.LastChild.LastChild.FUserPointer1:=Self;
(Screen.LastChild.LastChild as TSGEdit).TextTypeFunction:=TSGEditTextTypeFunction(@MyMandNumberFucntionVideo);
(Screen.LastChild.LastChild as TSGEdit).TextType:=SGEditTypeUser;
Screen.LastChild.LastChild.Caption:='200';

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
	QuantityThreads:=SGVal((Button.Parent.Children[5].AsComboBox.Items[Button.Parent.Children[5].AsComboBox.SelectItem].Caption));
	StartDepth:=SGVal(Button.Parent.Children[4].AsComboBox.Items[Button.Parent.Children[4].AsComboBox.SelectItem].Caption);
	InitMandelbrod;
	MandelbrodInitialized:=True;
	end;
end;


constructor TSGFractalMandelbrodRelease.Create(const VContext:ISGContext);
var
	i:Byte;
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
Mandelbrod:=nil;
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
MandelbrodInitialized:=False;
VideoPanel:=nil;
fmStartPanel:=nil;
FCurveInfoLbl:=nil;

Screen.CreateChild(TSGPanel.Create);
Screen.LastChild.SetMiddleBounds(300,Render.Height-200);
Screen.LastChild.Visible:=True;
Screen.LastChild.AsPanel.ViewLines:=False;
Screen.LastChild.AsPanel.ViewQuad:=False;
Screen.LastChild.BoundsToNeedBounds;
Screen.LastChild.FUserPointer1:=Self;
fmStartPanel:=Screen.LastChild;

Screen.LastChild.CreateChild(TSGLabel.Create);
Screen.LastChild.LastChild.Visible:=True;
Screen.LastChild.LastChild.Caption:='Количество потоков:';
Screen.LastChild.LastChild.SetBounds(5,5,Screen.LastChild.Width-10,20);
Screen.LastChild.LastChild.BoundsToNeedBounds;
Screen.LastChild.LastChild.FUserPointer1:=Self;

Screen.LastChild.CreateChild(TSGLabel.Create);
Screen.LastChild.LastChild.Visible:=True;
Screen.LastChild.LastChild.Caption:='Разрешение текстуры:';
Screen.LastChild.LastChild.SetBounds(5,55,Screen.LastChild.Width-10,20);
Screen.LastChild.LastChild.BoundsToNeedBounds;
Screen.LastChild.LastChild.FUserPointer1:=Self;

Screen.LastChild.CreateChild(TSGButton.Create);
Screen.LastChild.LastChild.SetBounds(75,115,140,20);
Screen.LastChild.LastChild.Visible:=True;
Screen.LastChild.LastChild.Caption:='Запуск';
Screen.LastChild.LastChild.OnChange:=TSGComponentProcedure(@BeginInitMand);
Screen.LastChild.LastChild.BoundsToNeedBounds;
Screen.LastChild.LastChild.FUserPointer1:=Self;

Screen.LastChild.CreateChild(TSGComboBox.Create);
Screen.LastChild.LastChild.Visible:=True;
Screen.LastChild.LastChild.SetBounds(5,80,Screen.LastChild.Width-10,20);
Screen.LastChild.LastChild.AsComboBox.SelectItem:=4;
Screen.LastChild.LastChild.AsComboBox.CreateItem('64');
Screen.LastChild.LastChild.AsComboBox.CreateItem('128');
Screen.LastChild.LastChild.AsComboBox.CreateItem('256');
Screen.LastChild.LastChild.AsComboBox.CreateItem('512');
Screen.LastChild.LastChild.AsComboBox.CreateItem('1024');
Screen.LastChild.LastChild.AsComboBox.CreateItem('2048');
Screen.LastChild.LastChild.BoundsToNeedBounds;
Screen.LastChild.LastChild.FUserPointer1:=Self;

Screen.LastChild.CreateChild(TSGComboBox.Create);
Screen.LastChild.LastChild.Visible:=True;
Screen.LastChild.LastChild.SetBounds(5,30,Screen.LastChild.Width-10,20);
Screen.LastChild.LastChild.AsComboBox.CreateItem('1');
Screen.LastChild.LastChild.AsComboBox.CreateItem('2');
Screen.LastChild.LastChild.AsComboBox.CreateItem('3');
Screen.LastChild.LastChild.AsComboBox.CreateItem('4');
Screen.LastChild.LastChild.AsComboBox.CreateItem('6');
Screen.LastChild.LastChild.AsComboBox.CreateItem('8');
Screen.LastChild.LastChild.AsComboBox.CreateItem('10');
Screen.LastChild.LastChild.AsComboBox.CreateItem('12');
Screen.LastChild.LastChild.AsComboBox.CreateItem('16');
Screen.LastChild.LastChild.BoundsToNeedBounds();
Screen.LastChild.LastChild.FUserPointer1:=Self;
case SGCoreCount() of 
2:Screen.LastChild.LastChild.AsComboBox.SelectItem:=1;
3:Screen.LastChild.LastChild.AsComboBox.SelectItem:=2;
4:Screen.LastChild.LastChild.AsComboBox.SelectItem:=3;
6:Screen.LastChild.LastChild.AsComboBox.SelectItem:=4;
8:Screen.LastChild.LastChild.AsComboBox.SelectItem:=5;
10:Screen.LastChild.LastChild.AsComboBox.SelectItem:=6;
12:Screen.LastChild.LastChild.AsComboBox.SelectItem:=7;
16:Screen.LastChild.LastChild.AsComboBox.SelectItem:=8;
else Screen.LastChild.LastChild.AsComboBox.SelectItem:=3;
end;

FTNRF:=TSGFont.Create(SGFontDirectory+DirectorySeparator+'Times New Roman.sgf');
FTNRF.SetContext(Context);
FTNRF.Loading();
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
if Mandelbrod<>nil then
	Mandelbrod.Destroy;
Mandelbrod:=nil;
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

function TSGFractalMandelbrodRelease.GetPointOnPosOnMand(const Point: TSGPoint2int32):TSGComplexNumber;inline;
begin
Result.Import(
	Mandelbrod.FView.x1+(Point.x/(Render.Width)*abs(Mandelbrod.FView.x1-Mandelbrod.FView.x2)),
	Mandelbrod.FView.y1+((Render.Height-Point.y)/(Render.Height)*abs(Mandelbrod.FView.y1-Mandelbrod.FView.y2))
	);
end;


procedure TSGFractalMandelbrodRelease.Paint();

procedure UpdateFirstPoint();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (Context.CursorKeysPressed(SGRightCursorButton))  then
	begin
	SelectPointEnabled:=True;
	SelectPoint:=Context.CursorPosition(SGNowCursorPosition);
	end;
end;

var
	SelectSecondNormalPoint : TSGPoint2int32;

procedure UpdateSecondPoint();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure QuadVertexes(const Point1, Point2 : TSGPoint2int32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Render.Vertex(Point1);
Render.Vertex2f(Point1.x, Point2.y);
Render.Vertex(Point2);
Render.Vertex2f(Point2.x, Point1.y);
end;

procedure QuadVertexes(const VType : TSGMaxEnum; const Point1, Point2 : TSGPoint2int32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Render.BeginScene(VType);
QuadVertexes(Point1, Point2);
Render.EndScene();
end;

var
	Abss, RenderBounds : TSGPoint2int32;

procedure DrawQuads();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Abss.x / Abss.y > RenderBounds.x / RenderBounds.y then
	begin
	SelectSecondNormalPoint.y := SelectSecondPoint.y;
	if (SelectPoint.x < SelectSecondPoint.x) then
		SelectSecondNormalPoint.x := SelectPoint.x + Round(Abss.y / RenderBounds.y * RenderBounds.x)
	else
		SelectSecondNormalPoint.x := SelectPoint.x - Round(Abss.y / RenderBounds.y * RenderBounds.x);
	end
else
	begin
	SelectSecondNormalPoint.x := SelectSecondPoint.x;
	if SelectPoint.y < SelectSecondPoint.y then
		SelectSecondNormalPoint.y := SelectPoint.y + Round(Abss.x / RenderBounds.x * RenderBounds.y)
	else
		SelectSecondNormalPoint.y := SelectPoint.y - Round(Abss.x / RenderBounds.x * RenderBounds.y);
	end;

Render.Color4f(0,0.5,0.70,0.6);
QuadVertexes(SGR_QUADS, SelectPoint, SelectSecondPoint);
Render.Color4f(0,0.7,0.70,0.8);
QuadVertexes(SGR_LINE_LOOP, SelectPoint, SelectSecondPoint);

Render.Color4f(0.6,0.5,0.30,0.6);
QuadVertexes(SGR_QUADS, SelectPoint, SelectSecondNormalPoint);
Render.Color4f(1,0.9,0.20,0.8);
QuadVertexes(SGR_LINE_LOOP, SelectPoint, SelectSecondNormalPoint);
end;

begin
if SelectPointEnabled then
	begin
	if Context.KeyPressedChar = #27 then
		SelectPointEnabled := False;
	
	SelectSecondPoint := Context.CursorPosition(SGNowCursorPosition);
	Abss.Import(
		Abs(SelectPoint.x - SelectSecondPoint.x),
		Abs(SelectPoint.y - SelectSecondPoint.y));
	RenderBounds.Import(
		Render.Width,
		Render.Height);
	try
	DrawQuads();
	except
	end;
	end;
end;

procedure UpdateFinalPoint();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if SelectPointEnabled and (Context.CursorKeysPressed(SGLeftCursorButton)) then
	begin
	SelectSecondPoint:=SelectSecondNormalPoint;
	
	SelectPointEnabled:=False;
	if SelectPoint.x>SelectSecondPoint.x then
		Swap(SelectPoint.x,SelectSecondPoint.x);
	if SelectPoint.y>SelectSecondPoint.y then
		Swap(SelectPoint.y,SelectSecondPoint.y);
	FOldView:=Mandelbrod.FView;
	Mandelbrod.FView.Import(
		GetPointOnPosOnMand(SelectPoint).x,
		GetPointOnPosOnMand(SelectSecondPoint).y,
		GetPointOnPosOnMand(SelectSecondPoint).x,
		GetPointOnPosOnMand(SelectPoint).y
		);
	Changet:=True;
	end;
end;

var
	i,ii:LongInt;
	TDT:TSGDateTime;
begin
if MandelbrodInitialized then
	begin
	Render.InitMatrixMode(SG_2D);
	
	if Mandelbrod.ThreadsReady  then
		begin
		Delay(5);
		Mandelbrod.AfterCalculate();
		
		for i:=0 to QuantityThreads-1 do
			begin
			FArProgressBar[i].Visible:=False;
			//Screen.Children[CID-QuantityThreads+i+2].AsProgressBar.Visible:=False;
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
			Mandelbrod.ToTexture();
			OnComponents();
			{if SecondImage<>nil then
				begin
				SecondImage.Destroy;
				SecondImage:=nil;
				end;}
			end
		else 
			if Mandelbrod.FImage<>nil then
				begin
				if not SGExistsDirectory(SGImagesDirectory) then
					SGMakeDirectory(SGImagesDirectory);
				if FNowRenderitsiaVideo then
					begin
					//Mandelbrod.FImage.Image.SetBounds(1920,1080);
					Mandelbrod.FImage.Way:=FVideoBuffer+DirectorySeparator+
						//GetZeros(QuantityNumbers(FAllKadrs)-QuantityNumbers(FNowKadr))+
						SGStr(FNowKadr)+'.jpg';
					end;
				FTNRF.AddWaterString('made by SaGe',Mandelbrod.FImage,0);
				Mandelbrod.FImage.Saveing(SGI_JPEG);
				if not FNowRenderitsiaVideo then
					begin
					Mandelbrod.Width:=StartDepth;
					Mandelbrod.Height:=StartDepth;
					end;
				Mandelbrod.FImage.Destroy();
				Mandelbrod.FImage:=nil;
				if not FNowRenderitsiaVideo then
					begin
					Mandelbrod.FImage:=SecondImage;
					SecondImage:=nil;
					end;
				if FNowRenderitsiaVideo then
					Changet:=True;
				NowSave:=False;
				end;
		end;
	
	UpDateLabelCoordCaption();
	
	if LabelProcent.Visible and ( not Mandelbrod.ThreadsReady) then
		begin
		Delay(5);
		FNewPotokInit:=False;
		Procent:=0;
		for i:=0 to QuantityThreads-1 do
			begin
			Procent+=
				FArProgressBar[i].Progress*(
				(Mandelbrod.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).h2-
				(Mandelbrod.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).h1
				)+(Mandelbrod.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).FHePr;
			if Mandelbrod.FThreadsData[i].FFinished and (FArProgressBar[i].Visible) then
				begin
				//FArProgressBar[i].Visible:=False;
				for ii:=0 to Mandelbrod.Threads-1 do
					begin
					{if ii>=i+1 then
						FArProgressBar[ii].FNeedTop-=25;}
					FDateTime.Get;
					if (not FNewPotokInit) then
					if 
						(Mandelbrod.FThreadsData[ii].FData<>nil) and 
						(Mandelbrod.FThreadsData[ii].FFinished=False) and 
						(ii<>i) and 
						((Mandelbrod.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).NewPos=0) and 
						(
						((Mandelbrod.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).h2-
						(Mandelbrod.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).NowPos)
						*Mandelbrod.Width>50000
						) and
						(
						(
						(FDateTime-
						(Mandelbrod.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).FBeginData).GetPastMiliSeconds
						)/FArProgressBar[ii].Progress*(1 - FArProgressBar[ii].Progress)
						>150
						) then
						// i - Только что Завершивший свою работу поток
						//ii - Гасторбайтер, Незавершивший свою работу поток
						begin
						(Mandelbrod.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).FWait:=True;
						
						if (Mandelbrod.FThreadsData[ii].FFinished=False) then
			begin
						
						FArProgressBar[ii].Color2:=(FArProgressBar[ii].Color2+SGVertex4fImport(0.9,0.45,0,0.8))/2;
						FArProgressBar[ii].Color1:=(FArProgressBar[ii].Color1+SGVertex4fImport(1,0.5,0,1))/2;
						FArProgressBar[i].Color2:=(FArProgressBar[i].Color2+SGVertex4fImport(0.1,1,0.1,0.7))/2;
						FArProgressBar[i].Color1:=(FArProgressBar[i].Color1+SGVertex4fImport(0,1,0,1))/2;
						
						iiiC:=0;
						if Mandelbrod.FThreadsData[i].FData<>nil then
							begin
							iiiC:=(Mandelbrod.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).h2-
									(Mandelbrod.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).h1+
									(Mandelbrod.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).FHePr;
							Mandelbrod.FThreadsData[i].FData.Destroy;
							Mandelbrod.FThreadsData[i].FData:=nil;
							end;
						
						if Mandelbrod.FThreadsData[i].FThread<>nil then
							begin
							Mandelbrod.FThreadsData[i].FThread.Destroy;
							Mandelbrod.FThreadsData[i].FThread:=nil;
							end;
						
						Mandelbrod.FThreadsData[i].FData:=TSGFractalMandelbrodThreadData.Create(
							Mandelbrod,
							(Mandelbrod.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).NowPos+
							(
							(
							(Mandelbrod.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).h2-
							(Mandelbrod.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).NowPos
							) div 2
							),
								
							(Mandelbrod.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).h2,
							FArProgressBar[i].GetProgressPointer,i);

						(Mandelbrod.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).NewPos:=0;
						(Mandelbrod.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).NowPos:=0;
						(Mandelbrod.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).FWait:=False;
						Mandelbrod.FThreadsData[i].FFinished:=False;
						(Mandelbrod.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).FBeginData.Get;
						(Mandelbrod.FThreadsData[i].FData as TSGFractalMandelbrodThreadData).FHePr:=iiiC;
						FArProgressBar[i].Progress:=0;
						FArProgressBar[i].ProgressTimer:=0;
						
						Mandelbrod.FThreadsData[i].FThread:=
							TSGThread.Create(
								TSGPointerProcedure(@TSGFractalMandelbrodThreadProcedure),
								Mandelbrod.FThreadsData[i].FData);
						
						(Mandelbrod.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).NewPos:=
							(Mandelbrod.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).NowPos+
							(
							(
							(Mandelbrod.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).h2-
							(Mandelbrod.FThreadsData[ii].FData as TSGFractalMandelbrodThreadData).NowPos
							) div 2
							);
						FNewPotokInit:=True;
			end;
						end;
					end;
				//LabelProcent.FNeedTop-=25;
				end;
			end;
		Procent/=Mandelbrod.Height;
		LabelProcent.Progress:=Procent;
		FDateTime.Get;
		///FDateTime.ImportFromSeconds((FDateTime-FBeginCalc).GetPastSeconds);
		LblProcent.Caption:=SGStringToPChar(SGFloatToString(Procent*100,2)+'%,Прошло '+
			SGSecondsToStringTime((FDateTime-FBeginCalc).GetPastSeconds)
			+','+'Осталось '+
			SGSecondsToStringTime(Round((FDateTime-FBeginCalc).GetPastSeconds/Procent*(1-Procent)))
			+'.');
		LabelCoord.Caption:=SGPCharNil;
		end;


	if (Mandelbrod.FImage<>nil) and Mandelbrod.FImage.Ready then
		begin
		Render.Color3f(1,1,1);
		Mandelbrod.Paint();
		//if Mandelbrod.FView.VertexInView(Mandelbrod.FZNumber) then
			//begin
			VtxForZN.Import(
				abs(Mandelbrod.FZNumber.x-Min(Mandelbrod.FView.X1,Mandelbrod.FView.X2))/Mandelbrod.FView.AbsX*Render.Width,
				abs(Mandelbrod.FZNumber.Y-Max(Mandelbrod.FView.Y1,Mandelbrod.FView.Y2))/Mandelbrod.FView.AbsY*Render.Height
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
			Mandelbrod.FZNumber.WriteLn;}
		if (SelectZNimberFlag and ((Context.CursorKeysPressed(SGLeftCursorButton)))) or (Context.CursorKeysPressed(SGMiddleCursorButton)) then
			begin
			ComplexNumber:=GetPointOnPosOnMand(Context.CursorPosition(SGNowCursorPosition));
			if Mandelbrod.FZNumber <> ComplexNumber then
				begin
				Mandelbrod.FZNumber:=ComplexNumber;
				SelectZNimberFlag:=False;
				OnComponents();
				Context.SetCursorKey(SGUpKey,SGLeftCursorButton);
				if not Mandelbrod.FZMand then
					Changet:=True;
				SelectPoint.Import;
				SelectSecondPoint.Import;
				end;
			end;
		UpdateFirstPoint();
		UpdateSecondPoint();
		UpdateFinalPoint();
		end
	else
		begin
		if SecondImage<>nil then
			begin
			Render.Color3f(1,1,1);
			if SecondImage.Ready then
				SecondImage.DrawImageFromTwoPoint2int32(
					SGVertex2int32Import(1,1),
					SGVertex2int32Import(Render.Width,Render.Height),
					True,SG_2D);
			
			Render.Color4f(0.1,0.7,0.20,0.6);
			Render.BeginScene(SGR_QUADS);
			Render.Vertex(SelectPoint);
			Render.Vertex2f(SelectPoint.x,SelectSecondPoint.y);
			Render.Vertex(SelectSecondPoint);
			Render.Vertex2f(SelectSecondPoint.x,SelectPoint.y);
			Render.EndScene();
			
			Render.Color4f(0.05,0.9,0.10,0.8);
			Render.BeginScene(SGR_LINE_LOOP);
			Render.Vertex(SelectPoint);
			Render.Vertex2f(SelectPoint.x,SelectSecondPoint.y);
			Render.Vertex(SelectSecondPoint);
			Render.Vertex2f(SelectSecondPoint.x,SelectPoint.y);
			Render.EndScene();
			end;
		end;
	
	if (not FNowRenderitsiaVideo) and LabelProcent.Visible and ( not Mandelbrod.ThreadsReady) then
	if (Context.KeyPressedByte=27) and 
		(Context.KeyPressedType=SGUpKey) and (SecondImage<>nil) then
			begin
			for i:=0 to High(Mandelbrod.FThreadsData) do
				begin
				if Mandelbrod.FThreadsData[i].FThread<>nil then
					begin
					Mandelbrod.FThreadsData[i].FThread.Destroy;
					Mandelbrod.FThreadsData[i].FThread:=nil;
					end;
				if Mandelbrod.FThreadsData[i].FData<>nil then
					begin
					Mandelbrod.FThreadsData[i].FData.Destroy;
					Mandelbrod.FThreadsData[i].FData:=nil;
					end;
				Mandelbrod.FThreadsData[i].FFinished:=True;
				end;
			if Mandelbrod.FImage<>nil then
				Mandelbrod.FImage.Destroy();
			Mandelbrod.FImage:=SecondImage;
			SecondImage:=nil;
			Mandelbrod.FView := FOldView;
			end;
	
	if FEnablePictureStripAddingPoints  and 
		(Context.KeyPressedChar='A') and 
		(Context.KeyPressedType=SGUpKey) then
		begin
		if FCurveArPoints=nil then
			SetLength(FCurveArPoints,1)
		else 
			SetLength(FCurveArPoints,Length(FCurveArPoints)+1);
		FCurveArPoints[High(FCurveArPoints)]:=Mandelbrod.FColorScheme;
		FBezierCurve.AddVertex(
			SGVertex3fImport(
				GetPointOnPosOnMand(Context.CursorPosition(SGNowCursorPosition)).x,
				GetPointOnPosOnMand(Context.CursorPosition(SGNowCursorPosition)).y));
		FBezierCurve.Detalization:=FBezierCurve.VertexQuantity*10;
		FBezierCurve.Calculate();
		Context.SetKey(SGNullKey, Context.KeyPressedByte());
		FBezierCurveLabelPoints.Caption:='Количество точек: '+SGStr(FBezierCurve.VertexQuantity);
		FBezierCurveGoButton.Active:=(FBezierCurve.VertexQuantity>=2) and (TSGEditTextTypeFunctionNumber(FBezierCurveEditKadr));
		end;
	
	if FNowRenderitsiaVideo or 
	(FEnablePictureStripPanel and FKomponentsNowOffOn)  then
		begin
		//Mandelbrod.FView.Write();
		Render.InitOrtho2d(Mandelbrod.FView.x1,Mandelbrod.FView.y1,Mandelbrod.FView.x2,Mandelbrod.FView.y2);
		if (FBezierCurve<>nil) then
			begin
			FBezierCurve.Paint();
			if FNowRenderitsiaVideo then
				begin
				Render.Color3f(1,0,1);
				Render.PointSize(5);
				Render.BeginScene(SGR_POINTS);
				Render.Vertex(Mandelbrod.FZNumber);
				Render.EndScene();
				Render.PointSize(1);
				end;
			end;
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
				Mandelbrod.FImage:=SecondImage;
				SecondImage:=nil;
				FBezierCurveKadrProgressBar.Visible:=False;
				Mandelbrod.FAttitudeForThemeEnable:=False;
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
		if (not FNowRenderitsiaVideo) or (FNowRenderitsiaVideo and (Mandelbrod.FImage<>nil)) then
			begin
			SecondImage:=Mandelbrod.FImage;
			Mandelbrod.FImage:=nil;
			end;
		if FNowRenderitsiaVideo then
			begin
			Mandelbrod.FZNumber.x:=FBezierCurve.GetResultVertex(FNowKadr/FAllKadrs).x;
			Mandelbrod.FZNumber.y:=FBezierCurve.GetResultVertex(FNowKadr/FAllKadrs).y;
			Mandelbrod.FAttitudeForThemeEnable:=True;
			Mandelbrod.FFAttitudeForTheme:=FBezierCurve.LowAttitude;
			if FBezierCurve.LowIndex<>FBezierCurve.VertexQuantity-1 then
				begin
				Mandelbrod.FTheme1:=FCurveArPoints[FBezierCurve.LowIndex];
				Mandelbrod.FTheme2:=FCurveArPoints[FBezierCurve.LowIndex+1];
				end
			else
				begin
				Mandelbrod.FTheme1:=FCurveArPoints[FBezierCurve.LowIndex];
				Mandelbrod.FTheme2:=FCurveArPoints[FBezierCurve.LowIndex];
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
			Mandelbrod.Width:=StartDepth;
			Mandelbrod.Height:=StartDepth;
			end;
		Mandelbrod.BeginCalculate();
		Mandelbrod.FImage.Way := SGFreeFileName(SGImagesDirectory + DirectorySeparator + 'Mandelbrod.jpg');
		LabelProcent.Visible:=True;
		LblProcent.Visible:=True;
		ii:={Context.TopShift+}40;
		FBeginCalc.Get;
		Mandelbrod.ThreadsBoolean(False);
		for i:=0 to QuantityThreads-1 do
			begin
			with FArProgressBar[i] do
				begin
				Progress:=0;
				ProgressTimer:=0;
				Visible:=true;
				Top := ii;
				ii+=25;
				DefaultColor;
				Mandelbrod.BeginThread(i,GetProgressPointer());
				end;
			end;
		LabelProcent.Top:=ii;
		LblProcent.Top:=ii;
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

procedure TSGFractalMandelbrod.Paint();
begin
inherited;
if FImage.Ready then
	FImage.DrawImageFromTwoPoint2int32(
		SGVertex2int32Import(1,1),
		SGVertex2int32Import(Render.Width,Render.Height),
		False,SG_3D);
end;


constructor TSGFractalMandelbrod.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FTheme1:=0;
FTheme2:=0;
FFAttitudeForTheme:=0;
FAttitudeForThemeEnable:=False;
FImage:=nil;
FZNumber.Import(0,0.65);
FView.Import(-1.5,-1.5*(Render.Height/Render.Width),1.5,1.5*(Render.Height/Render.Width));
FZMand:=False;
FZDegree:=2;
FZQuantityRec:=256;
FColorScheme:=0;
FSmosh:=1;
end;

function TSGFractalMandelbrod.GetPixelColor(const VColorSceme:TSGByte;const RecNumber:Word):TSGMandelbrodPixel;inline;
var
	Color : TSGLongWord;

function YellowPil():TSGMandelbrodPixel;
begin
	Result.r := trunc(abs(cos(Color) * Color)) mod 255;
	Result.g := GetColor(Color Div 2,Color * Color,trunc(abs((cos(Color) * cos(Color)) * Result.r))mod 500);
	if Color <> 0 then
		Result.b := GetColor(
			Result.g, 
			Result.r, 
			(sqr(Result.r)
		) mod Color)
	else
		Result.b := GetColor(
			Result.g, 
			Result.r, 
			(sqr(Result.r)
		) mod 255);
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
Color := Round((RecNumber/20)*255);
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
		Result.r:=GetColor(0,383,Color mod 383) div 2;
		Result.g:=GetColor(128,896,Color  mod 896);
		Result.b:=GetColor(0,383,Color  mod 383);
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
		Result.r := Color mod 256;
		Result.g := (SizeOf(FImage.FImage.BitMap) * Color) div 255;
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
			(trunc(abs(cos(Color) * Result.r)) mod 383)
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
	Result.b:=GetColor(0,383,Color mod 383) div 2;
	Result.r:=GetColor(128,896,Color mod 896);
	Result.g:=GetColor(0,383,Color mod 383);
	end;
8:
	begin
	Result.g:=GetColor(0,383,Color mod 383) div 2;
	Result.r:=GetColor(128,896,Color mod 896);
	Result.b:=GetColor(0,383,Color mod 383);
	end;
9:
	begin
	Result.g:=GetColor(0,383,Color mod 383) div 2;
	Result.b:=GetColor(128,896,Color mod 896);
	Result.r:=GetColor(0,383,Color mod 383);
	end;
10:
	begin
	Result.r:=GetColor(0,383,Color mod 383) div 2;
	Result.b:=GetColor(128,896,Color mod 896);
	Result.g:=GetColor(0,383,Color mod 383);
	end;
11:
	begin
	Result.b:=GetColor(0,383,Color mod 383) div 2;
	Result.g:=GetColor(128,896,Color mod 896);
	Result.r:=GetColor(0,383,Color mod 383);
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
		Result.r:=GetColor(200,400,Color mod 400);
		Result.g:=GetColor(0,200,Color mod 200);
		Result.b:=GetColor(100,300,Color mod 300);
		end;
	end;
end;
end;

procedure TSGFractalMandelbrod.InitColor(const x,y:LongInt;const RecNumber:LongInt);inline;
var
	MandelbrodPixel1,MandelbrodPixel2:TSGMandelbrodPixel;
begin
if FAttitudeForThemeEnable then
	begin
	MandelbrodPixel1:=GetPixelColor(FTheme1,RecNumber);
	MandelbrodPixel2:=GetPixelColor(FTheme2,RecNumber);
	MandelbrodPixel1.r:=Round(MandelbrodPixel1.r*(1-FFAttitudeForTheme)+FFAttitudeForTheme*MandelbrodPixel2.r);
	MandelbrodPixel1.g:=Round(MandelbrodPixel1.g*(1-FFAttitudeForTheme)+FFAttitudeForTheme*MandelbrodPixel2.g);
	MandelbrodPixel1.b:=Round(MandelbrodPixel1.b*(1-FFAttitudeForTheme)+FFAttitudeForTheme*MandelbrodPixel2.b);
	end
else
	begin
	MandelbrodPixel1:=GetPixelColor(FColorScheme,RecNumber);
	end;
FImage.FImage.BitMap[(Y*Width+X)*3+0]:=MandelbrodPixel1.r;
FImage.FImage.BitMap[(Y*Width+X)*3+1]:=MandelbrodPixel1.g;
FImage.FImage.BitMap[(Y*Width+X)*3+2]:=MandelbrodPixel1.b;
end;

function TSGFractalMandelbrod.MandelbrodRec(const Number:TSGComplexNumber;const dx,dy:single):Word;inline;
var
	i,ii:Byte;
begin
Result:=0;
for i:=0 to FSmosh-1 do
	for ii:=0 to FSmosh-1 do
		Result+=Rec(SGComplexNumberImport(Number.x+i*dx/FSmosh,Number.y+ii*dy/FSmosh));
Result:=Round(Result/sqr(FSmosh));
if Result>FZQuantityRec then
	Result:=FZQuantityRec;
end;

procedure TSGFractalMandelbrod.CalculateFromThread(Data:TSGFractalMandelbrodThreadData);
var
	i,ii:Word;
	rY,rX,dX,dY:System.Real;//По идее это Wight и Height
	
	VReady:Boolean = False;
	VBufferNow:Boolean = False;
	
	VKolRec:LongInt;
	IsComponent:Boolean = False;
begin
if Data.FPoint<>nil then
	IsComponent:=TSGComponent(Data.FPoint) is TSGProgressBar;
rY:=abs(FView.y1-FView.y2);
rX:=abs(FView.x1-FView.x2);
dX:=rX/Width;
dY:=rY/Height;
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
		VKolRec:=MandelbrodRec(SGComplexNumberImport(FView.x1+dX*ii,FView.y1+dY*i),dx,dy);//(ii/FDepth)*r?
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
					MandelbrodRec(SGComplexNumberImport(FView.x1+dX*ii,FView.y1+dY*(i-1)),dx,dy));
			end;
		ii+=2;
		end;
	
	VBufferNow:= not VBufferNow;
	if not VReady then
		VReady:=True;
	
	if PSGDouble(Data.FPoint)<>nil then
		if IsComponent then
			TSGProgressBar(Data.FPoint).Progress:=(i-Data.h1)/(Data.h2-Data.h1)
		else
			PSGDouble(Data.FPoint)^:=(i-Data.h1)/(Data.h2-Data.h1);
	
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
	VKolRec:=Rec(SGComplexNumberImport(FView.x1+dX*ii,FView.y1+dY*i));
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
BeginCalculate();
CalculateFromThread(TSGFractalMandelbrodThreadData.Create(Self,0,Depth-1,nil,-1));
ToTexture();
end;

end.
