{$INCLUDE Smooth.inc}

unit SmoothFractalMandelbrot;

interface

uses
	 SmoothBase
	,SmoothFractals
	,SmoothContextClasses
	,SmoothCommon
	,SmoothCommonStructs
	,SmoothImage
	,SmoothDateTime
	,SmoothFont
	,SmoothBezierCurve
	,SmoothComplex
	,SmoothContextInterface
	,SmoothScreenClasses
	;

type
	TSMandelbrotPixel = record
		r, g, b : TSByte;
		end;
	
	TSFractalMandelbrotThreadData = class;
	TSFractalMandelbrot = class(TSImageFractal)
			public
		constructor Create(const _Context : ISContext); override;
			public
		FZNumber      : TSComplexNumber;
		FZDegree      : LongInt;
		FZMand        : Boolean;
		FZQuantityRec : LongInt;
		FColorScheme  : TSByte;
		
		FAttitudeForThemeEnable : Boolean;
		FTheme1,FTheme2         : TSByte;
		FFAttitudeForTheme      : Real;
		
		FSmosh : Byte;
		procedure InitColor(const x,y:LongInt;const RecNumber:LongInt);override;
		function Rec(Number:TSComplexNumber):Word;inline;
		function MandelbrotRec(const Number:TSComplexNumber;const dx,dy:single):Word;inline;
			public
		function GetPixelColor(const VColorSceme:TSByte;const RecNumber:Word):TSMandelbrotPixel;inline;
		procedure CalculateFromThread(Data:TSFractalMandelbrotThreadData);
		procedure Calculate;override;
		procedure Paint();override;
		procedure AfterCalculate;override;
		procedure BeginCalculate;override;
		procedure BeginThread(const Number:LongInt;const Real:Pointer);
			public
		property ZNumber:TSComplexNumber read FZNumber write FZNumber;
		end;
	
	TSFractalMandelbrotThreadData=class(TSFractalData)
			public
		constructor Create(var Fractal:TSFractalMandelbrot;const h1,h2:LongInt;const Point:Pointer;const Number:LongInt = -1);
		destructor Destroy;override;
			public
		H1,H2:LongInt;
		
		FWait:Boolean;
		NowPos:LongWord;
		NewPos:LongWord;
		
		FPoint:Pointer;
		FNumber:LongInt;
		VBuffer:array[False..True]of PBoolean;
		
		FBeginData:TSDateTime;//время начала потока
		
		FHePr:LongWord;//Уже сделаный прогресс потока по Height
		end;

procedure TSFractalMandelbrotThreadProcedure(Data:TSFractalMandelbrotThreadData);

type
	TSFractalMandelbrotRelease=class(TSPaintableObject)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
		procedure Paint(); override;
			protected
		FNewPotokInit:Boolean;
		SelectPoint,SelectSecondPoint:TSPoint2int32;
		
		SelectPointEnabled:Boolean;
		Mandelbrot:TSFractalMandelbrot;
		
		QuantityThreads:LongInt;
		
		NowSave:Boolean;
		NowSaveLastView:TSScreenVertexes;
		
		SecondImage:TSImage;
		
		LabelProcent : TSScreenProgressBar;
		LblProcent : TSScreenLabel;
		LabelCoord : TSScreenLabel;
		ScreenshotPanel : TSScreenPanel;
		
		StartDepth:LongInt;
		ColorComboBox:TSScreenComboBox;
		TypeComboBox:TSScreenComboBox;
		ZumButton:TSScreenButton;
		StepenComboBox:TSScreenComboBox;
		QuantityRecComboBox:TSScreenComboBox;
		
		SelectZNimberFlag:Boolean;
		
		ButtonSelectZNumber:TSScreenButton;
		
		MandelbrotInitialized:Boolean;
		
		VideoPanel : TSScreenPanel;
		Changet : TSBoolean;
		
		FStartPanel : TSScreenPanel;
		VtxForZN : TSVertex2f;
		
		Procent : TSFloat64;
		iiiC : TSUInt32;
		ComplexNumber : TSComplexNumber;
		FArProgressBar:packed array of
			TSScreenProgressBar;
		
		//Time
		FDateTime : TSDateTime;
		FBeginCalc : TSDateTime;
		
		//Bezier Curve
		FEnablePictureStripPanel : TSBoolean;
		FBezierCurve : TSBezierCurve;
		
		FButtonEnableCurve : TSScreenButton;
		FBezierCurvePanel : TSScreenPanel;
		FBezierCurveEditKadr : TSScreenEdit;
		FBezierCurveLabelPoints : TSScreenLabel;
		FBezierCurveGoButton : TSScreenButton;
		
		FBezierCurveKadrProgressBar : TSScreenProgressBar;
		
		FEnablePictureStripAddingPoints : TSBoolean;
		FKomponentsNowOffOn : TSBoolean;
		FBezierNowSelectPoint : TSMaxEnum;
		FNowRenderitsiaVideo : TSBoolean;
		
		FVideoBuffer : TSString;
		
		FNowKadr : TSUInt64;
		FAllKadrs : TSUInt64;
		
		FCurveArPoints : packed array of TSUInt8;
		FCurveSelectPoint:Int64;
		
		FCurvePointPanel : TSScreenPanel;
		FCurvePCB : TSScreenComboBox;
		FCurveInfoLbl : TSScreenLabel;
		FCurveBeginDataTime : TSDateTime;
		
		FTNRF:TSFont;
		
		FOldView:TSScreenVertexes;
			public
		procedure UnDatePointCurvePanel();inline;
		procedure DrawBezierPoints();inline;
		procedure OffComponents();inline;
		procedure OnComponents();inline;
		procedure InitMandelbrot();inline;
		function GetPointOnPosOnMand(const Point:TSPoint2int32):TSComplexNumber;inline;
		procedure UpDateLabelCoordCaption();inline;
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothFileUtils
	,SmoothRenderBase
	,SmoothThreads
	,SmoothScreenBase
	,SmoothMathUtils
	,SmoothBitMap
	,SmoothSysUtils
	,SmoothBaseUtils
	,SmoothContextUtils
	,SmoothScreen_Edit
	,SmoothLists
	,SmoothImageFormatDeterminer
	
	,SysUtils
	;

procedure TSFractalMandelbrotRelease.UnDatePointCurvePanel();inline;
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

procedure TSFractalMandelbrotRelease.DrawBezierPoints();inline;
var
	A:TSVertex3f;
	i:TSMaxEnum;
	S:Extended;
	PC:TSVertex2f;
begin
if (FBezierCurve<>nil) and (FBezierCurve.VertexQuantity>0) then
	begin
	S:=Abs(Mandelbrot.FView.y1-Mandelbrot.FView.y2)/60;
	Render.Color4f(1,1,0,0.5);
	Render.BeginScene(SR_QUADS);
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
		if (Context.CursorKeyPressed=SLeftCursorButton) and (Context.CursorKeyPressedType=SDownKey) then
			begin
			PC:=GetPointOnPosOnMand(Context.CursorPosition(SNowCursorPosition));
			if (abs(PC.x-A.x)<(S)) and ((abs(PC.y-A.y)<(S))) and (FCurveSelectPoint<>i) then
				begin
				FCurveSelectPoint:=i;
				Context.SetCursorKey(SNullKey, SNullCursorButton);
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
		Render.BeginScene(SR_LINE_LOOP);
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

procedure TSFractalMandelbrotRelease.UpDateLabelCoordCaption();inline;
var
	Point: TSPoint2int32;
begin
Point:=Context.CursorPosition(SNowCursorPosition);
LabelCoord.Caption:=SStringToPChar('( '+SFloatToString(Mandelbrot.FZNumber.x,3)+' ; '+SFloatToString(Mandelbrot.FZNumber.y,3)+' ) , ( '+
	SFloatToString(GetPointOnPosOnMand(Point).x,7)+' ; '
	+SFloatToString(GetPointOnPosOnMand(Point).y,7)+' )');
end;


procedure TSFractalMandelbrotRelease.OffComponents();inline;
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

procedure TSFractalMandelbrotRelease.OnComponents();inline;
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

procedure SaveImage(Button:TSScreenButton);
begin
with TSFractalMandelbrotRelease(Button.FUserPointer1) do
	begin
	Mandelbrot.Width:=SVal((Button.Parent.LastChild.Caption));
	Mandelbrot.Height:=Trunc(SVal((Button.Parent.LastChild.Caption))*(Render.Height/Render.Width));
	Changet:=True;
	NowSave:=True;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	end;
end;

procedure CurveColorComboBoxProcedure(a,b:LongInt;Button:TSScreenComponent);
begin
with TSFractalMandelbrotRelease(Button.FUserPointer1) do
	begin
	if FCurveSelectPoint<>-1 then
		FCurveArPoints[FCurveSelectPoint]:=b;
	end;
end;


procedure ColorComboBoxProcedure(a,b:LongInt;Button:TSScreenComponent);
begin
with TSFractalMandelbrotRelease(Button.FUserPointer1) do
	begin
	Mandelbrot.FColorScheme:=b;
	if a<>b then
		begin
		Changet:=True;
		SelectPoint.Import;
		SelectSecondPoint.Import;
		end;
	end;
end;

procedure TypeComboBoxProcedure(a,b:LongInt;Button:TSScreenComponent);
begin
with TSFractalMandelbrotRelease(Button.FUserPointer1) do
	begin
	Mandelbrot.FZMand:=Boolean(b);
	if a<>b then
		begin
		Changet:=True;
		SelectPoint.Import();
		SelectSecondPoint.Import();
		end;
	end;
end;

procedure ZumButtonOnChange(Button:TSScreenButton);
begin
with TSFractalMandelbrotRelease(Button.FUserPointer1) do
	begin
	Mandelbrot.FView.Import(-2.5,-2.5*(Render.Height/Render.Width),2.5,2.5*(Render.Height/Render.Width));
	Changet:=True;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	FOldView:=Mandelbrot.FView;
	end;
end;

procedure ButtonSelectZNumberOnChange(Button:TSScreenButton);
begin
with TSFractalMandelbrotRelease(Button.FUserPointer1) do
	begin
	SelectZNimberFlag:=True;
	OffComponents();
	end;
end;

procedure QuantityRecComboBoxProcedure(a,b:LongInt;aaa:TSScreenComponent);
BEGIN
with TSFractalMandelbrotRelease(aaa.FUserPointer1) do
	begin
	Mandelbrot.FZQuantityRec:=QuantityRecComboBox.Items[b].Identifier;
	Changet:=True;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	end;
END;

procedure StepenComboBoxProcedure(a,b:LongInt;aaa:TSScreenComponent);
begin
with TSFractalMandelbrotRelease(aaa.FUserPointer1) do
	begin
	Mandelbrot.FZDegree:=StepenComboBox.Items[b].Identifier;
	Changet:=True;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	end;
end;

function MyMandNumberFucntion(Self : TSScreenEdit) : TSBoolean;
begin
Result := TSEditTextTypeFunctionNumber(Self);
if (Self.FUserPointer2 <> nil) then
	TSScreenComponent(Self.FUserPointer2).Active := Result;
end;

function MyMandNumberFucntionVideo(Self : TSScreenEdit) : TSBoolean;
begin
Result := TSEditTextTypeFunctionNumber(Self);
with TSFractalMandelbrotRelease(Self.FUserPointer1) do
if (Self.FUserPointer2 <> nil) then
	TSScreenComponent(Self.FUserPointer2).Active := Result and (FBezierCurve<>nil) and (FBezierCurve.VertexQuantity>=2);
end;

procedure bcpOnOffVideo(Button:TSScreenButton);
begin
with TSFractalMandelbrotRelease(Button.FUserPointer1) do
	begin
	FEnablePictureStripPanel:=not FEnablePictureStripPanel;
	OnComponents();
	if FEnablePictureStripPanel then
		begin
		Button.Caption:='Off видео панель';
		FBezierCurve:=TSBezierCurve.Create();
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

procedure bcpGoVideo(Button:TSScreenButton);
begin
with TSFractalMandelbrotRelease(Button.FUserPointer1) do
	begin
	OffComponents();
	FCurveInfoLbl.Visible:=True;
	FCurveInfoLbl.Caption:='Тут будет отображаться информация!!!';
	FBezierCurveKadrProgressBar.Visible:=True;
	FBezierCurveKadrProgressBar.Progress:=0;
	FNowKadr:=0;
	FAllKadrs:=SVal(FBezierCurveEditKadr.Caption);
	FNowRenderitsiaVideo:=True;
	Changet:=True;
	SelectPoint.Import();
	SelectSecondPoint.Import();
	Mandelbrot.FZMand:=False;
	FVideoBuffer:=SFreeDirectoryName(SImagesDirectory + DirectorySeparator + 'Mandelbrot Buffer', 'Part');
	SMakeDirectory(FVideoBuffer);
	Mandelbrot.Width:=1920;//*5;
	Mandelbrot.Height:=1080;//*5;
	FCurveBeginDataTime.Get();
	end;
end;

procedure bcpAddPoint(Button:TSScreenButton);
begin
with TSFractalMandelbrotRelease(Button.FUserPointer1) do
	begin
	FEnablePictureStripAddingPoints:= not FEnablePictureStripAddingPoints;
	if FEnablePictureStripAddingPoints then
		Button.Caption:='Off режим добавления точек'
	else
		Button.Caption:='On режим добавления точек';
	end;
end;

procedure TSFractalMandelbrotRelease.InitMandelbrot();inline;
var
	i:LongInt;
	ii:LongInt = 5;
	VNameThemes : TSStringList = nil;

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

Mandelbrot := TSFractalMandelbrot.Create(Context);
Mandelbrot.Width:=StartDepth;
Mandelbrot.Height:=StartDepth;
Mandelbrot.FZNumber.Import(-0.181,0.66);
Mandelbrot.FZMand:=False;
Mandelbrot.FZDegree:=2;
Mandelbrot.FView.Import(-2.5,-2.5*(Render.Height/Render.Width),2.5,2.5*(Render.Height/Render.Width));
Mandelbrot.CreateThreads(QuantityThreads);
Mandelbrot.BeginCalculate;
Mandelbrot.FImage.FileName:=SImagesDirectory+DirectorySeparator+'Mand New.jpg';

FBeginCalc.Get;
SetLength(FArProgressBar,QuantityThreads);
ii+={Context.TopShift+}40;
for i:=0 to QuantityThreads-1 do
	begin
	FArProgressBar[i]:=TSScreenProgressBar.Create;
	Screen.CreateChild(FArProgressBar[i]);
	FArProgressBar[i].ViewCaption := False;
	FArProgressBar[i].SetBounds(10,ii,300,20);
	FArProgressBar[i].BoundsMakeReal();
	ii+=23;
	FArProgressBar[i].Visible:=True;
	FArProgressBar[i].ViewProgress:=True;
	Mandelbrot.BeginThread(i, FArProgressBar[i]);
	end;

LblProcent := SCreateLabel(Screen, '', 10,ii,300,20, True, True, Self);

LabelProcent:=TSScreenProgressBar.Create;
Screen.CreateChild(LabelProcent);
LabelProcent.SetBounds(10,ii,300,20);
LabelProcent.Color2 := SVertex4fImport(1,0,0,0.8);
LabelProcent.Color1 := SVertex4fImport(0.5,0,0,0.8);
LabelProcent.Caption:='';
LabelProcent.ViewCaption := False;
LabelProcent.Visible:=True;
LabelProcent.FUserPointer1:=Self;

LabelCoord := SCreateLabel(Screen, '', False, 10,Render.Height-25,Render.Width div 2,20, [SAnchBottom], True, True, Self);
ScreenshotPanel := SCreatePanel(Screen, Render.Width-10-(130+140+10),Render.Height-30,130+140+10,25, [SAnchBottom, SAnchRight], False, True, Self);

Screen.LastChild.CreateChild(TSScreenButton.Create);
Screen.LastChild.LastChild.SetBounds(130,5,140,20);
Screen.LastChild.LastChild.Caption:='Сохранить';
Screen.LastChild.LastChild.BoundsMakeReal;
(Screen.LastChild.LastChild as TSScreenButton).OnChange:=TSScreenComponentProcedure(@SaveImage);
Screen.LastChild.LastChild.FUserPointer1:=Self;

SCreateEdit(Screen.LastChild, '4096', TSScreenEditTextTypeFunction(@MyMandNumberFucntion), 5,5,120,20, [], False, True, Self);
Screen.LastChild.LastChild.FUserPointer2:=Screen.LastChild.Children[Screen.LastChild.ChildCount()-1];

Screen.CreateChild(TSScreenComboBox.Create);
Screen.LastChild.SetBounds(Render.Width-50-125+45,5{+Context.TopShift},120,20);
Screen.LastChild.Anchors:=[SAnchRight];
for i:=0 to High(VNameThemes) do
	(Screen.LastChild as TSScreenComboBox).CreateItem(VNameThemes[i]);
(Screen.LastChild as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@ColorComboBoxProcedure);
(Screen.LastChild as TSScreenComboBox).SelectItem:=0;
ColorComboBox:=Screen.LastChild as TSScreenComboBox;
Screen.LastChild.FUserPointer1:=Self;

TypeComboBox:=TSScreenComboBox.Create;
Screen.CreateChild(TypeComboBox);
Screen.LastChild.SetBounds(Render.Width-50-125+45-185,5,180,20);
Screen.LastChild.Anchors:=[SAnchRight];
(Screen.LastChild as TSScreenComboBox).CreateItem('Множество Жюлиа');
(Screen.LastChild as TSScreenComboBox).CreateItem('Модель Мандельброта');
(Screen.LastChild as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@TypeComboBoxProcedure);
(Screen.LastChild as TSScreenComboBox).SelectItem:=0;
Screen.LastChild.FUserPointer1:=Self;

Screen.CreateChild(TSScreenButton.Create);
Screen.LastChild.SetBounds(Render.Width-50-125-185+45-105,5,100,20);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='Сброс зума';
ZumButton:=Screen.LastChild as TSScreenButton;
ZumButton.OnChange:=TSScreenComponentProcedure(@ZumButtonOnChange);
Screen.LastChild.FUserPointer1:=Self;

Screen.CreateChild(TSScreenButton.Create);
Screen.LastChild.SetBounds(Render.Width-50-125-185-105+45-125,5{+Context.TopShift},120,20);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='Установ. тчк.';
ButtonSelectZNumber:=Screen.LastChild as TSScreenButton;
ButtonSelectZNumber.OnChange:=TSScreenComponentProcedure(@ButtonSelectZNumberOnChange);
Screen.LastChild.FUserPointer1:=Self;

StepenComboBox:=TSScreenComboBox.Create;
Screen.CreateChild(StepenComboBox);
Screen.LastChild.SetBounds(Render.Width-50-125-185-105-125+45-105,5{+Context.TopShift},100,20);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='';
Screen.LastChild.BoundsMakeReal;
(Screen.LastChild as TSScreenComboBox).SelectItem:=1;
(Screen.LastChild as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@StepenComboBoxProcedure);
Screen.LastChild.FUserPointer1:=Self;
i:=1;
while i<=100 do
	begin
	(Screen.LastChild as TSScreenComboBox).CreateItem(SStringToPChar(SStr(i)),nil,i);
	i+=1;
	end;

QuantityRecComboBox:=TSScreenComboBox.Create;
Screen.CreateChild(QuantityRecComboBox);
Screen.LastChild.SetBounds(Render.Width-50-125-185-105-125-105+45-105,5{+Context.TopShift},100,20);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='';
Screen.LastChild.BoundsMakeReal;
(Screen.LastChild as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@QuantityRecComboBoxProcedure);
Screen.LastChild.FUserPointer1:=Self;
i:=6;
while i<=13 do
	begin
	(Screen.LastChild as TSScreenComboBox).CreateItem(SStringToPChar(SStr(2**i)),nil,2**i);
	if i=8 then
		begin
		(Screen.LastChild as TSScreenComboBox).SelectItem := QuantityRecComboBox.ItemsCount - 1;
		end;
	i+=1;
	end;

FCurveInfoLbl := SCreateLabel(Screen, '', Render.Width-10-(130+140+10)-150-5,Render.Height-30-25,-(-(130+140+10)-150-5),20, [SAnchRight, SAnchBottom]);

FBezierCurveKadrProgressBar:=TSScreenProgressBar.Create();
Screen.CreateChild(FBezierCurveKadrProgressBar);
Screen.LastChild.SetBounds(Render.Width-10-(130+140+10)-150-5,Render.Height-30,-(-(130+140+10)-150-5),20);
(Screen.LastChild as TSScreenProgressBar).ViewProgress:=True;
(Screen.LastChild as TSScreenProgressBar).Color1:=SVertex4fImport(1,1,0,0.7);
(Screen.LastChild as TSScreenProgressBar).Color2:=SVertex4fImport(1,1/3,0,0.9);
Screen.LastChild.Anchors:=[SAnchRight,SAnchBottom];

FButtonEnableCurve:=TSScreenButton.Create();
Screen.CreateChild(FButtonEnableCurve);
Screen.LastChild.SetBounds(Render.Width-10-(130+140+10)-150-5,Render.Height-30,150,20);
Screen.LastChild.Anchors:=[SAnchRight,SAnchBottom];
Screen.LastChild.Caption:='On видео панель';
FButtonEnableCurve.OnChange:=TSScreenComponentProcedure(@bcpOnOffVideo);
Screen.LastChild.FUserPointer1:=Self;

FCurvePointPanel := SCreatePanel(Screen, Render.Width-10-(140+10),Render.Height-130-130,140+10,125, [SAnchBottom, SAnchRight], False, True, Self);

FCurvePointPanel.CreateChild(TSScreenComboBox.Create);
FCurvePointPanel.LastChild.SetBounds(5,5,130,20);
for i:=0 to High(VNameThemes) do
	(FCurvePointPanel.LastChild as TSScreenComboBox).CreateItem(VNameThemes[i]);
(FCurvePointPanel.LastChild as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@CurveColorComboBoxProcedure);
(FCurvePointPanel.LastChild as TSScreenComboBox).SelectItem:=0;
(FCurvePointPanel.LastChild as TSScreenComboBox).MaxLines:=5;
FCurvePCB:=FCurvePointPanel.LastChild as TSScreenComboBox;
FCurvePointPanel.LastChild.FUserPointer1:=Self;

FBezierCurvePanel := SCreatePanel(Screen, Render.Width-10-(130+140+10),Render.Height-130,130+140+10,125, [SAnchBottom, SAnchRight], False, True, Self);

FBezierCurvePanel.CreateChild(TSScreenButton.Create());
FBezierCurvePanel.LastChild.Caption:='On режим добавления точек';
FBezierCurvePanel.LastChild.SetBounds(3,3,275,20);
(FBezierCurvePanel.LastChild as TSScreenButton).OnChange:=TSScreenComponentProcedure(@bcpAddPoint);
FBezierCurvePanel.LastChild.FUserPointer1:=Self;
FBezierCurvePanel.LastChild.BoundsMakeReal();

FBezierCurveLabelPoints := SCreateLabel(FBezierCurvePanel, 'Количество точек: 0', 3,47,137,20, False, True, Self);
SCreateLabel(FBezierCurvePanel, 'Количество кадров:', False, 3,25,275,20, False, True, Self);
FBezierCurveEditKadr := SCreateEdit(Screen.LastChild, '200', TSScreenEditTextTypeFunction(@MyMandNumberFucntionVideo), 123,27,137,20, [], False, True, Self);
SCreateLabel(FBezierCurvePanel, 'Примерно займет времени: дохрена!', 3,70,275,20, False, True, Self);

FBezierCurveGoButton:=TSScreenButton.Create();
FBezierCurvePanel.CreateChild(FBezierCurveGoButton);
(FBezierCurvePanel.LastChild as TSScreenButton).Caption:='Начать и пусть весь мир подождет';
(FBezierCurvePanel.LastChild as TSScreenButton).SetBounds(3,92,275,20);
(FBezierCurvePanel.LastChild as TSScreenButton).OnChange:=TSScreenComponentProcedure(@bcpGoVideo);
FBezierCurvePanel.LastChild.FUserPointer1:=Self;
FBezierCurvePanel.LastChild.BoundsMakeReal();
FBezierCurveEditKadr.FUserPointer2:=Pointer(FBezierCurvePanel.LastChild);

if VNameThemes<>nil then
	begin
	for i:=0 to High(VNameThemes) do
		VNameThemes[i]:='';
	SetLength(VNameThemes,0);
	end;
end;

procedure BeginInitMand(Button:TSScreenButton);
begin
with TSFractalMandelbrotRelease(Button.FUserPointer1) do
	begin
	Button.Parent.Visible:=(False);
	QuantityThreads:=SVal(((Button.Parent.Children[5] as TSScreenComboBox).Items[(Button.Parent.Children[5]as TSScreenComboBox).SelectItem].Caption));
	StartDepth:=SVal((Button.Parent.Children[4] as TSScreenComboBox).Items[(Button.Parent.Children[4] as TSScreenComboBox).SelectItem].Caption);
	InitMandelbrot;
	MandelbrotInitialized:=True;
	end;
end;


constructor TSFractalMandelbrotRelease.Create();
var
	i : TSByte;
begin
inherited;
FTNRF := nil;
FCurvePointPanel := nil;
FCurveSelectPoint := -1;
FCurveArPoints := nil;
FNowRenderitsiaVideo := False;
FBezierNowSelectPoint := 0;
FKomponentsNowOffOn := False;
FBezierCurveEditKadr := nil;
FEnablePictureStripAddingPoints := False;
FBezierCurvePanel := nil;
FButtonEnableCurve := nil;
FBezierCurve := nil;
FEnablePictureStripPanel := False;
FArProgressBar := nil;
Changet := False;
SelectPointEnabled := False;
Mandelbrot := nil;
QuantityThreads := 1;
NowSave := False;
SecondImage := nil;
LabelCoord := nil;
LabelProcent := nil;
ScreenshotPanel := nil;
StartDepth := 128;
ColorComboBox := nil;
TypeComboBox := nil;
ZumButton := nil;
StepenComboBox := nil;
QuantityRecComboBox := nil;
SelectZNimberFlag := False;
ButtonSelectZNumber := nil;
MandelbrotInitialized := False;
VideoPanel := nil;
FStartPanel := nil;
FCurveInfoLbl := nil;

FStartPanel := SCreatePanel(Screen, False, False, 300,Render.Height-200, True, True, Self);
SCreateLabel(FStartPanel, 'Количество потоков:', 5,5,Screen.LastChild.Width-10,20, True, True, Self);
SCreateLabel(FStartPanel, 'Количество потоков:', 5,55,Screen.LastChild.Width-10,20, True, True, Self);

Screen.LastChild.CreateChild(TSScreenButton.Create);
Screen.LastChild.LastChild.SetBounds(75,115,140,20);
Screen.LastChild.LastChild.Visible:=True;
Screen.LastChild.LastChild.Caption:='Запуск';
Screen.LastChild.LastChild.OnChange:=TSScreenComponentProcedure(@BeginInitMand);
Screen.LastChild.LastChild.BoundsMakeReal;
Screen.LastChild.LastChild.FUserPointer1:=Self;

Screen.LastChild.CreateChild(TSScreenComboBox.Create);
Screen.LastChild.LastChild.Visible:=True;
Screen.LastChild.LastChild.SetBounds(5,80,Screen.LastChild.Width-10,20);
(Screen.LastChild.LastChild as TSScreenComboBox).SelectItem:=4;
(Screen.LastChild.LastChild as TSScreenComboBox).CreateItem('64');
(Screen.LastChild.LastChild as TSScreenComboBox).CreateItem('128');
(Screen.LastChild.LastChild as TSScreenComboBox).CreateItem('256');
(Screen.LastChild.LastChild as TSScreenComboBox).CreateItem('512');
(Screen.LastChild.LastChild as TSScreenComboBox).CreateItem('1024');
(Screen.LastChild.LastChild as TSScreenComboBox).CreateItem('2048');
Screen.LastChild.LastChild.BoundsMakeReal;
Screen.LastChild.LastChild.FUserPointer1:=Self;

Screen.LastChild.CreateChild(TSScreenComboBox.Create);
Screen.LastChild.LastChild.Visible:=True;
Screen.LastChild.LastChild.SetBounds(5,30,Screen.LastChild.Width-10,20);
(Screen.LastChild.LastChild as TSScreenComboBox).CreateItem('1');
(Screen.LastChild.LastChild as TSScreenComboBox).CreateItem('2');
(Screen.LastChild.LastChild as TSScreenComboBox).CreateItem('3');
(Screen.LastChild.LastChild as TSScreenComboBox).CreateItem('4');
(Screen.LastChild.LastChild as TSScreenComboBox).CreateItem('6');
(Screen.LastChild.LastChild as TSScreenComboBox).CreateItem('8');
(Screen.LastChild.LastChild as TSScreenComboBox).CreateItem('10');
(Screen.LastChild.LastChild as TSScreenComboBox).CreateItem('12');
(Screen.LastChild.LastChild as TSScreenComboBox).CreateItem('16');
Screen.LastChild.LastChild.BoundsMakeReal();
Screen.LastChild.LastChild.FUserPointer1:=Self;
case SCoreCount() of 
2:(Screen.LastChild.LastChild as TSScreenComboBox).SelectItem:=1;
3:(Screen.LastChild.LastChild as TSScreenComboBox).SelectItem:=2;
4:(Screen.LastChild.LastChild as TSScreenComboBox).SelectItem:=3;
6:(Screen.LastChild.LastChild as TSScreenComboBox).SelectItem:=4;
8:(Screen.LastChild.LastChild as TSScreenComboBox).SelectItem:=5;
10:(Screen.LastChild.LastChild as TSScreenComboBox).SelectItem:=6;
12:(Screen.LastChild.LastChild as TSScreenComboBox).SelectItem:=7;
16:(Screen.LastChild.LastChild as TSScreenComboBox).SelectItem:=8;
else (Screen.LastChild.LastChild as TSScreenComboBox).SelectItem:=3;
end;

FTNRF := SCreateFontFromFile(Context, SFontDirectory+DirectorySeparator+'Times New Roman.sgf');
end;

destructor TSFractalMandelbrotRelease.Destroy();
var
	i:TSMaxEnum;
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
if FStartPanel<>nil then
	FStartPanel.Destroy;
FStartPanel:=nil;
if Mandelbrot<>nil then
	Mandelbrot.Destroy;
Mandelbrot:=nil;
if FArProgressBar<>nil then
	for i:=0 to High(FArProgressBar) do
		if FArProgressBar[i]<>nil then
			FArProgressBar[i].Destroy;
SetLength(FArProgressBar,0);
FArProgressBar:=nil;
inherited;
end;

class function TSFractalMandelbrotRelease.ClassName:string;
begin
Result:='Фрактал Мандельброда и тп';
end;

function TSFractalMandelbrotRelease.GetPointOnPosOnMand(const Point: TSPoint2int32):TSComplexNumber;inline;
begin
Result.Import(
	Mandelbrot.FView.x1+(Point.x/(Render.Width)*abs(Mandelbrot.FView.x1-Mandelbrot.FView.x2)),
	Mandelbrot.FView.y1+((Render.Height-Point.y)/(Render.Height)*abs(Mandelbrot.FView.y1-Mandelbrot.FView.y2))
	);
end;


procedure TSFractalMandelbrotRelease.Paint();

procedure UpdateFirstPoint();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (Context.CursorKeysPressed(SRightCursorButton))  then
	begin
	SelectPointEnabled:=True;
	SelectPoint:=Context.CursorPosition(SNowCursorPosition);
	end;
end;

var
	SelectSecondNormalPoint : TSPoint2int32;

procedure UpdateSecondPoint();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure QuadVertexes(const Point1, Point2 : TSPoint2int32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Render.Vertex(Point1);
Render.Vertex2f(Point1.x, Point2.y);
Render.Vertex(Point2);
Render.Vertex2f(Point2.x, Point1.y);
end;

procedure QuadVertexes(const VType : TSMaxEnum; const Point1, Point2 : TSPoint2int32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Render.BeginScene(VType);
QuadVertexes(Point1, Point2);
Render.EndScene();
end;

var
	Abss, RenderBounds : TSPoint2int32;

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
QuadVertexes(SR_QUADS, SelectPoint, SelectSecondPoint);
Render.Color4f(0,0.7,0.70,0.8);
QuadVertexes(SR_LINE_LOOP, SelectPoint, SelectSecondPoint);

Render.Color4f(0.6,0.5,0.30,0.6);
QuadVertexes(SR_QUADS, SelectPoint, SelectSecondNormalPoint);
Render.Color4f(1,0.9,0.20,0.8);
QuadVertexes(SR_LINE_LOOP, SelectPoint, SelectSecondNormalPoint);
end;

begin
if SelectPointEnabled then
	begin
	if Context.KeyPressedChar = #27 then
		SelectPointEnabled := False;
	
	SelectSecondPoint := Context.CursorPosition(SNowCursorPosition);
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
if SelectPointEnabled and (Context.CursorKeysPressed(SLeftCursorButton)) then
	begin
	SelectSecondPoint:=SelectSecondNormalPoint;
	
	SelectPointEnabled:=False;
	if SelectPoint.x>SelectSecondPoint.x then
		Swap(SelectPoint.x,SelectSecondPoint.x);
	if SelectPoint.y>SelectSecondPoint.y then
		Swap(SelectPoint.y,SelectSecondPoint.y);
	FOldView:=Mandelbrot.FView;
	Mandelbrot.FView.Import(
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
	TDT:TSDateTime;
begin
if MandelbrotInitialized then
	begin
	Render.InitMatrixMode(S_2D);
	
	if Mandelbrot.ThreadsReady  then
		begin
		Sleep(5);
		Mandelbrot.AfterCalculate();
		
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
		LblProcent.Caption:=SStringToPChar('100%, Прошло: '+
			(
			SSecondsToStringTime(
			(FDateTime-FBeginCalc).GetPastSeconds))+'.');
		
		if (not NowSave)  and (not FNowRenderitsiaVideo) then
			begin
			Mandelbrot.ToTexture();
			OnComponents();
			{if SecondImage<>nil then
				begin
				SecondImage.Destroy;
				SecondImage:=nil;
				end;}
			end
		else 
			if Mandelbrot.FImage<>nil then
				begin
				if not SExistsDirectory(SImagesDirectory) then
					SMakeDirectory(SImagesDirectory);
				if FNowRenderitsiaVideo then
					begin
					//Mandelbrot.FImage.Image.SetBounds(1920,1080);
					Mandelbrot.FImage.FileName:=FVideoBuffer+DirectorySeparator+
						//GetZeros(QuantityNumbers(FAllKadrs)-QuantityNumbers(FNowKadr))+
						SStr(FNowKadr)+'.jpg';
					end;
				FTNRF.AddWaterString('made by Smooth',Mandelbrot.FImage,0);
				Mandelbrot.FImage.Save(SImageFormatJpeg);
				if not FNowRenderitsiaVideo then
					begin
					Mandelbrot.Width:=StartDepth;
					Mandelbrot.Height:=StartDepth;
					end;
				Mandelbrot.FImage.Destroy();
				Mandelbrot.FImage:=nil;
				if not FNowRenderitsiaVideo then
					begin
					Mandelbrot.FImage:=SecondImage;
					SecondImage:=nil;
					end;
				if FNowRenderitsiaVideo then
					Changet:=True;
				NowSave:=False;
				end;
		end;
	
	UpDateLabelCoordCaption();
	
	if LabelProcent.Visible and ( not Mandelbrot.ThreadsReady) then
		begin
		Sleep(5);
		FNewPotokInit:=False;
		Procent:=0;
		for i:=0 to QuantityThreads-1 do
			begin
			Procent+=
				FArProgressBar[i].Progress*(
				(Mandelbrot.FThreadsData[i].FData as TSFractalMandelbrotThreadData).h2-
				(Mandelbrot.FThreadsData[i].FData as TSFractalMandelbrotThreadData).h1
				)+(Mandelbrot.FThreadsData[i].FData as TSFractalMandelbrotThreadData).FHePr;
			if Mandelbrot.FThreadsData[i].FFinished and (FArProgressBar[i].Visible) then
				begin
				//FArProgressBar[i].Visible:=False;
				for ii:=0 to Mandelbrot.Threads-1 do
					begin
					{if ii>=i+1 then
						FArProgressBar[ii].FNeedTop-=25;}
					FDateTime.Get;
					if (not FNewPotokInit) then
					if 
						(Mandelbrot.FThreadsData[ii].FData<>nil) and 
						(Mandelbrot.FThreadsData[ii].FFinished=False) and 
						(ii<>i) and 
						((Mandelbrot.FThreadsData[ii].FData as TSFractalMandelbrotThreadData).NewPos=0) and 
						(
						((Mandelbrot.FThreadsData[ii].FData as TSFractalMandelbrotThreadData).h2-
						(Mandelbrot.FThreadsData[ii].FData as TSFractalMandelbrotThreadData).NowPos)
						*Mandelbrot.Width>50000
						) and
						(
						(
						(FDateTime-
						(Mandelbrot.FThreadsData[ii].FData as TSFractalMandelbrotThreadData).FBeginData).GetPastMiliSeconds
						)/FArProgressBar[ii].Progress*(1 - FArProgressBar[ii].Progress)
						>150
						) then
						// i - Только что Завершивший свою работу поток
						//ii - Гасторбайтер, Незавершивший свою работу поток
						begin
						(Mandelbrot.FThreadsData[ii].FData as TSFractalMandelbrotThreadData).FWait:=True;
						
						if (Mandelbrot.FThreadsData[ii].FFinished=False) then
			begin
						
						FArProgressBar[ii].Color2:=(FArProgressBar[ii].Color2+SVertex4fImport(0.9,0.45,0,0.8))/2;
						FArProgressBar[ii].Color1:=(FArProgressBar[ii].Color1+SVertex4fImport(1,0.5,0,1))/2;
						FArProgressBar[i].Color2:=(FArProgressBar[i].Color2+SVertex4fImport(0.1,1,0.1,0.7))/2;
						FArProgressBar[i].Color1:=(FArProgressBar[i].Color1+SVertex4fImport(0,1,0,1))/2;
						
						iiiC:=0;
						if Mandelbrot.FThreadsData[i].FData<>nil then
							begin
							iiiC:=(Mandelbrot.FThreadsData[i].FData as TSFractalMandelbrotThreadData).h2-
									(Mandelbrot.FThreadsData[i].FData as TSFractalMandelbrotThreadData).h1+
									(Mandelbrot.FThreadsData[i].FData as TSFractalMandelbrotThreadData).FHePr;
							Mandelbrot.FThreadsData[i].FData.Destroy;
							Mandelbrot.FThreadsData[i].FData:=nil;
							end;
						
						if Mandelbrot.FThreadsData[i].FThread<>nil then
							begin
							Mandelbrot.FThreadsData[i].FThread.Destroy;
							Mandelbrot.FThreadsData[i].FThread:=nil;
							end;
						
						Mandelbrot.FThreadsData[i].FData:=TSFractalMandelbrotThreadData.Create(
							Mandelbrot,
							(Mandelbrot.FThreadsData[ii].FData as TSFractalMandelbrotThreadData).NowPos+
							(
							(
							(Mandelbrot.FThreadsData[ii].FData as TSFractalMandelbrotThreadData).h2-
							(Mandelbrot.FThreadsData[ii].FData as TSFractalMandelbrotThreadData).NowPos
							) div 2
							),
								
							(Mandelbrot.FThreadsData[ii].FData as TSFractalMandelbrotThreadData).h2,
							FArProgressBar[i].GetProgressPointer,i);

						(Mandelbrot.FThreadsData[i].FData as TSFractalMandelbrotThreadData).NewPos:=0;
						(Mandelbrot.FThreadsData[i].FData as TSFractalMandelbrotThreadData).NowPos:=0;
						(Mandelbrot.FThreadsData[i].FData as TSFractalMandelbrotThreadData).FWait:=False;
						Mandelbrot.FThreadsData[i].FFinished:=False;
						(Mandelbrot.FThreadsData[i].FData as TSFractalMandelbrotThreadData).FBeginData.Get;
						(Mandelbrot.FThreadsData[i].FData as TSFractalMandelbrotThreadData).FHePr:=iiiC;
						FArProgressBar[i].Progress:=0;
						FArProgressBar[i].ProgressTimer:=0;
						
						Mandelbrot.FThreadsData[i].FThread:=
							TSThread.Create(
								TSPointerProcedure(@TSFractalMandelbrotThreadProcedure),
								Mandelbrot.FThreadsData[i].FData);
						
						(Mandelbrot.FThreadsData[ii].FData as TSFractalMandelbrotThreadData).NewPos:=
							(Mandelbrot.FThreadsData[ii].FData as TSFractalMandelbrotThreadData).NowPos+
							(
							(
							(Mandelbrot.FThreadsData[ii].FData as TSFractalMandelbrotThreadData).h2-
							(Mandelbrot.FThreadsData[ii].FData as TSFractalMandelbrotThreadData).NowPos
							) div 2
							);
						FNewPotokInit:=True;
			end;
						end;
					end;
				//LabelProcent.FNeedTop-=25;
				end;
			end;
		Procent/=Mandelbrot.Height;
		LabelProcent.Progress:=Procent;
		FDateTime.Get;
		///FDateTime.ImportFromSeconds((FDateTime-FBeginCalc).GetPastSeconds);
		LblProcent.Caption:=SStringToPChar(SFloatToString(Procent*100,2)+'%,Прошло '+
			SSecondsToStringTime((FDateTime-FBeginCalc).GetPastSeconds)
			+','+'Осталось '+
			SSecondsToStringTime(Round((FDateTime-FBeginCalc).GetPastSeconds/Procent*(1-Procent)))
			+'.');
		LabelCoord.Caption:=SPCharNil;
		end;


	if (Mandelbrot.FImage<>nil) and Mandelbrot.FImage.Loaded then
		begin
		Render.Color3f(1,1,1);
		Mandelbrot.Paint();
		//if Mandelbrot.FView.VertexInView(Mandelbrot.FZNumber) then
			//begin
			VtxForZN.Import(
				abs(Mandelbrot.FZNumber.x-Min(Mandelbrot.FView.X1,Mandelbrot.FView.X2))/Mandelbrot.FView.AbsX*Render.Width,
				abs(Mandelbrot.FZNumber.Y-Max(Mandelbrot.FView.Y1,Mandelbrot.FView.Y2))/Mandelbrot.FView.AbsY*Render.Height
				);
			Render.Color3f(1,1,1);
			Render.BeginScene(SR_TRIANGLES);
			Render.Vertex2f(VtxForZN.x+5,VtxForZN.y);
			Render.Vertex2f(VtxForZN.x-2,VtxForZN.y-4);
			Render.Vertex2f(VtxForZN.x-2,VtxForZN.y+4);
			Render.EndScene();
			//end;
			{
		else
			Mandelbrot.FZNumber.WriteLn;}
		if (SelectZNimberFlag and ((Context.CursorKeysPressed(SLeftCursorButton)))) or (Context.CursorKeysPressed(SMiddleCursorButton)) then
			begin
			ComplexNumber:=GetPointOnPosOnMand(Context.CursorPosition(SNowCursorPosition));
			if Mandelbrot.FZNumber <> ComplexNumber then
				begin
				Mandelbrot.FZNumber:=ComplexNumber;
				SelectZNimberFlag:=False;
				OnComponents();
				Context.SetCursorKey(SUpKey,SLeftCursorButton);
				if not Mandelbrot.FZMand then
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
			if SecondImage.Loaded then
				SecondImage.DrawImageFromTwoPoint2int32(
					SVertex2int32Import(1,1),
					SVertex2int32Import(Render.Width,Render.Height),
					True,S_2D);
			
			Render.Color4f(0.1,0.7,0.20,0.6);
			Render.BeginScene(SR_QUADS);
			Render.Vertex(SelectPoint);
			Render.Vertex2f(SelectPoint.x,SelectSecondPoint.y);
			Render.Vertex(SelectSecondPoint);
			Render.Vertex2f(SelectSecondPoint.x,SelectPoint.y);
			Render.EndScene();
			
			Render.Color4f(0.05,0.9,0.10,0.8);
			Render.BeginScene(SR_LINE_LOOP);
			Render.Vertex(SelectPoint);
			Render.Vertex2f(SelectPoint.x,SelectSecondPoint.y);
			Render.Vertex(SelectSecondPoint);
			Render.Vertex2f(SelectSecondPoint.x,SelectPoint.y);
			Render.EndScene();
			end;
		end;
	
	if (not FNowRenderitsiaVideo) and LabelProcent.Visible and ( not Mandelbrot.ThreadsReady) then
	if (Context.KeyPressedByte=27) and 
		(Context.KeyPressedType=SUpKey) and (SecondImage<>nil) then
			begin
			for i:=0 to High(Mandelbrot.FThreadsData) do
				begin
				if Mandelbrot.FThreadsData[i].FThread<>nil then
					begin
					Mandelbrot.FThreadsData[i].FThread.Destroy;
					Mandelbrot.FThreadsData[i].FThread:=nil;
					end;
				if Mandelbrot.FThreadsData[i].FData<>nil then
					begin
					Mandelbrot.FThreadsData[i].FData.Destroy;
					Mandelbrot.FThreadsData[i].FData:=nil;
					end;
				Mandelbrot.FThreadsData[i].FFinished:=True;
				end;
			if Mandelbrot.FImage<>nil then
				Mandelbrot.FImage.Destroy();
			Mandelbrot.FImage:=SecondImage;
			SecondImage:=nil;
			Mandelbrot.FView := FOldView;
			end;
	
	if FEnablePictureStripAddingPoints  and 
		(Context.KeyPressedChar='A') and 
		(Context.KeyPressedType=SUpKey) then
		begin
		if FCurveArPoints=nil then
			SetLength(FCurveArPoints,1)
		else 
			SetLength(FCurveArPoints,Length(FCurveArPoints)+1);
		FCurveArPoints[High(FCurveArPoints)]:=Mandelbrot.FColorScheme;
		FBezierCurve.AddVertex(
			SVertex3fImport(
				GetPointOnPosOnMand(Context.CursorPosition(SNowCursorPosition)).x,
				GetPointOnPosOnMand(Context.CursorPosition(SNowCursorPosition)).y));
		FBezierCurve.Detalization:=FBezierCurve.VertexQuantity*10;
		FBezierCurve.Calculate();
		Context.SetKey(SNullKey, Context.KeyPressedByte());
		FBezierCurveLabelPoints.Caption:='Количество точек: '+SStr(FBezierCurve.VertexQuantity);
		FBezierCurveGoButton.Active:=(FBezierCurve.VertexQuantity>=2) and (TSEditTextTypeFunctionNumber(FBezierCurveEditKadr));
		end;
	
	if FNowRenderitsiaVideo or 
	(FEnablePictureStripPanel and FKomponentsNowOffOn)  then
		begin
		//Mandelbrot.FView.Write();
		Render.InitOrtho2d(Mandelbrot.FView.x1,Mandelbrot.FView.y1,Mandelbrot.FView.x2,Mandelbrot.FView.y2);
		if (FBezierCurve<>nil) then
			begin
			FBezierCurve.Paint();
			if FNowRenderitsiaVideo then
				begin
				Render.Color3f(1,0,1);
				Render.PointSize(5);
				Render.BeginScene(SR_POINTS);
				Render.Vertex(Mandelbrot.FZNumber);
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
				Mandelbrot.FImage:=SecondImage;
				SecondImage:=nil;
				FBezierCurveKadrProgressBar.Visible:=False;
				Mandelbrot.FAttitudeForThemeEnable:=False;
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
		if (not FNowRenderitsiaVideo) or (FNowRenderitsiaVideo and (Mandelbrot.FImage<>nil)) then
			begin
			SecondImage:=Mandelbrot.FImage;
			Mandelbrot.FImage:=nil;
			end;
		if FNowRenderitsiaVideo then
			begin
			Mandelbrot.FZNumber.x:=FBezierCurve.GetResultVertex(FNowKadr/FAllKadrs).x;
			Mandelbrot.FZNumber.y:=FBezierCurve.GetResultVertex(FNowKadr/FAllKadrs).y;
			Mandelbrot.FAttitudeForThemeEnable:=True;
			Mandelbrot.FFAttitudeForTheme:=FBezierCurve.LowAttitude;
			if FBezierCurve.LowIndex<>FBezierCurve.VertexQuantity-1 then
				begin
				Mandelbrot.FTheme1:=FCurveArPoints[FBezierCurve.LowIndex];
				Mandelbrot.FTheme2:=FCurveArPoints[FBezierCurve.LowIndex+1];
				end
			else
				begin
				Mandelbrot.FTheme1:=FCurveArPoints[FBezierCurve.LowIndex];
				Mandelbrot.FTheme2:=FCurveArPoints[FBezierCurve.LowIndex];
				end;
			TDT.Get();
			if FNowKadr<>1 then
				FCurveInfoLbl.Caption:='Прошло: '+
					SSecondsToStringTime((TDT-FCurveBeginDataTime).GetPastSeconds)
					+', Осталось: '+
					SSecondsToStringTime(Trunc(
					(TDT-FCurveBeginDataTime).GetPastSeconds/((FNowKadr-1)/FAllKadrs)*(1-(FNowKadr-1)/FAllKadrs)
					))
					+', FPS: '+SStrReal(FNowKadr/(TDT-FCurveBeginDataTime).GetPastSeconds,3)+' к/с';
			end;
		if (not FNowRenderitsiaVideo) and (not NowSave) then
			begin
			Mandelbrot.Width:=StartDepth;
			Mandelbrot.Height:=StartDepth;
			end;
		Mandelbrot.BeginCalculate();
		Mandelbrot.FImage.FileName := SFreeFileName(SImagesDirectory + DirectorySeparator + 'Mandelbrot.jpg');
		LabelProcent.Visible:=True;
		LblProcent.Visible:=True;
		ii:={Context.TopShift+}40;
		FBeginCalc.Get;
		Mandelbrot.ThreadsBoolean(False);
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
				Mandelbrot.BeginThread(i,GetProgressPointer());
				end;
			end;
		LabelProcent.Top:=ii;
		LblProcent.Top:=ii;
		end;
	Changet:=False;
	end;
end;


{Mandelbrot}
procedure TSFractalMandelbrotThreadProcedure(Data:TSFractalMandelbrotThreadData);
begin
with data do
	begin
	(FFractal as TSFractalMandelbrot).CalculateFromThread(Data);
	FFractal.FThreadsData[FNumber].FFinished:=True;
	end;
end;

destructor TSFractalMandelbrotThreadData.Destroy;
begin
FFractal:=nil;
FreeMem(VBuffer[True]);
FreeMem(VBuffer[not True]);
inherited;
end;

procedure TSFractalMandelbrot.BeginThread(const Number:LongInt;const Real:Pointer);
begin
FThreadsData[Number].FData:=TSFractalMandelbrotThreadData.Create(
	Self,
	Trunc( (Number)*(Height div Length(FThreadsData))),
	Trunc( (Number+1)*(Height div Length(FThreadsData)))-1,
	Real,Number);

(FThreadsData[Number].FData as TSFractalMandelbrotThreadData).NewPos:=0;
(FThreadsData[Number].FData as TSFractalMandelbrotThreadData).NowPos:=0;
(FThreadsData[Number].FData as TSFractalMandelbrotThreadData).FWait:=False;
(FThreadsData[Number].FData as TSFractalMandelbrotThreadData).FBeginData.Get;

FThreadsData[Number].FThread:=
	TSThread.Create(
		TSPointerProcedure(@TSFractalMandelbrotThreadProcedure),
		FThreadsData[Number].FData);
end;

procedure TSFractalMandelbrot.AfterCalculate;
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

procedure TSFractalMandelbrot.BeginCalculate;
begin
inherited;
end;


constructor TSFractalMandelbrotThreadData.Create(var Fractal:TSFractalMandelbrot;const h1,h2:LongInt;const Point:Pointer;const Number:LongInt = -1);
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

procedure TSFractalMandelbrot.Paint();
begin
inherited;
if FImage.Loaded then
	FImage.DrawImageFromTwoPoint2int32(
		SVertex2int32Import(1,1),
		SVertex2int32Import(Render.Width,Render.Height),
		False,S_3D);
end;


constructor TSFractalMandelbrot.Create(const _Context : ISContext);
begin
inherited;
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

function TSFractalMandelbrot.GetPixelColor(const VColorSceme:TSByte;const RecNumber:Word):TSMandelbrotPixel;inline;
var
	Color : TSLongWord;

function YellowPil():TSMandelbrotPixel;
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
		Result.g := (SizeOf(FImage.BitMap.Data) * Color) div 255;
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

procedure TSFractalMandelbrot.InitColor(const x,y:LongInt;const RecNumber:LongInt);inline;
var
	MandelbrotPixel1,MandelbrotPixel2:TSMandelbrotPixel;
begin
if FAttitudeForThemeEnable then
	begin
	MandelbrotPixel1:=GetPixelColor(FTheme1,RecNumber);
	MandelbrotPixel2:=GetPixelColor(FTheme2,RecNumber);
	MandelbrotPixel1.r:=Round(MandelbrotPixel1.r*(1-FFAttitudeForTheme)+FFAttitudeForTheme*MandelbrotPixel2.r);
	MandelbrotPixel1.g:=Round(MandelbrotPixel1.g*(1-FFAttitudeForTheme)+FFAttitudeForTheme*MandelbrotPixel2.g);
	MandelbrotPixel1.b:=Round(MandelbrotPixel1.b*(1-FFAttitudeForTheme)+FFAttitudeForTheme*MandelbrotPixel2.b);
	end
else
	begin
	MandelbrotPixel1:=GetPixelColor(FColorScheme,RecNumber);
	end;
FImage.BitMap.Data[(Y*Width+X)*3+0]:=MandelbrotPixel1.r;
FImage.BitMap.Data[(Y*Width+X)*3+1]:=MandelbrotPixel1.g;
FImage.BitMap.Data[(Y*Width+X)*3+2]:=MandelbrotPixel1.b;
end;

function TSFractalMandelbrot.MandelbrotRec(const Number:TSComplexNumber;const dx,dy:single):Word;inline;
var
	i,ii:Byte;
begin
Result:=0;
for i:=0 to FSmosh-1 do
	for ii:=0 to FSmosh-1 do
		Result+=Rec(SComplexNumberImport(Number.x+i*dx/FSmosh,Number.y+ii*dy/FSmosh));
Result:=Round(Result/sqr(FSmosh));
if Result>FZQuantityRec then
	Result:=FZQuantityRec;
end;

procedure TSFractalMandelbrot.CalculateFromThread(Data:TSFractalMandelbrotThreadData);
var
	i,ii:Word;
	rY,rX,dX,dY:System.Real;//По идее это Wight и Height
	
	VReady:Boolean = False;
	VBufferNow:Boolean = False;
	
	VKolRec:LongInt;
	IsComponent:Boolean = False;
begin
if Data.FPoint<>nil then
	IsComponent:=TSScreenComponent(Data.FPoint) is TSScreenProgressBar;
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
		VKolRec:=MandelbrotRec(SComplexNumberImport(FView.x1+dX*ii,FView.y1+dY*i),dx,dy);//(ii/FDepth)*r?
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
					MandelbrotRec(SComplexNumberImport(FView.x1+dX*ii,FView.y1+dY*(i-1)),dx,dy));
			end;
		ii+=2;
		end;
	
	VBufferNow:= not VBufferNow;
	if not VReady then
		VReady:=True;
	
	if PSDouble(Data.FPoint)<>nil then
		if IsComponent then
			TSScreenProgressBar(Data.FPoint).Progress:=(i-Data.h1)/(Data.h2-Data.h1)
		else
			PSDouble(Data.FPoint)^:=(i-Data.h1)/(Data.h2-Data.h1);
	
	while Data.FWait do
		begin
		if Data.NewPos<>0 then
			begin
			Data.h2:=Data.NewPos-1;
			Data.FWait:=False;
			Data.NewPos:=0;
			end;
		Sleep(5);
		end;
	if i+1>Data.h2 then
		Break;
	//Inc(i);
	end;
//until hh2<i;
ii:=Byte(VBufferNow);
while ii<Width do
	begin
	VKolRec:=Rec(SComplexNumberImport(FView.x1+dX*ii,FView.y1+dY*i));
	InitColor(ii,i,VKolRec);
	ii+=2;
	end;
end;

function TSFractalMandelbrot.Rec(Number:TSComplexNumber):Word;inline;
var 
	Depth2:Word = 0;
	Number2:TSComplexNumber;
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

procedure TSFractalMandelbrot.Calculate;
begin
inherited;
BeginCalculate();
CalculateFromThread(TSFractalMandelbrotThreadData.Create(Self,0,Depth-1,nil,-1));
ToTexture();
end;

end.
