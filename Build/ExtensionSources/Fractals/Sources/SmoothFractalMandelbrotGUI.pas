{$INCLUDE Smooth.inc}

unit SmoothFractalMandelbrotGUI;

interface

uses
	 SmoothBase
	,SmoothFractalMandelbrot
	,SmoothContextInterface
	,SmoothScreenClasses
	,SmoothBezierCurve
	,SmoothContextClasses
	,SmoothCommon
	,SmoothCommonStructs
	,SmoothImage
	,SmoothFont
	,SmoothComplex
	,SmoothDateTime
	,SmoothLists
	;

type
	TSFractalMandelbrotGUI=class(TSPaintableObject)
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
		NowSaveLastView:TSScreenVertices;
		
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
		
		ButtonSelectSingularPoint:TSScreenButton;
		
		MandelbrotInitialized:Boolean;
		
		VideoPanel : TSScreenPanel;
		Changet : TSBoolean;
		
		FStartPanel : TSScreenPanel;
		VectorBySingularPoint : TSVertex2f;
		
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
		FIsComponentsActive : TSBoolean;
		FBezierNowSelectPoint : TSMaxEnum;
		FRenderVideo : TSBoolean;
		
		FVideoBuffer : TSString;
		
		FNowKadr : TSUInt64;
		FAllKadrs : TSUInt64;
		
		FCurveArPoints : TSUInt8List;
		FCurveSelectPoint:Int64;
		
		FCurvePointPanel : TSScreenPanel;
		FCurvePCB : TSScreenComboBox;
		FCurveInfoLbl : TSScreenLabel;
		FCurveBeginDateTime : TSDateTime;
		
		FTNRF:TSFont;
		
		FOldView:TSScreenVertices;
			public
		procedure UnDatePointCurvePanel();inline;
		procedure DrawBezierPoints();inline;
		procedure OffComponents();inline;
		procedure OnComponents();inline;
		procedure InitMandelbrot();inline;
		function PointOfASetByCoordinates(const Point:TSPoint2int32):TSComplexNumber;inline;
		procedure UpDateLabelCoordCaption();inline;
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothFileUtils
	,SmoothScreenBase
	,SmoothMathUtils
	//,SmoothBitMap
	,SmoothSysUtils
	,SmoothBaseUtils
	,SmoothContextUtils
	,SmoothScreen_Edit
	,SmoothImageFormatDeterminer
	,SmoothBitMapUtils
	,SmoothRenderBase
	,SysUtils
	,SmoothThreads
	;

procedure TSFractalMandelbrotGUI.UnDatePointCurvePanel();inline;
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

procedure TSFractalMandelbrotGUI.DrawBezierPoints();inline;
var
	A:TSVertex3f;
	i:TSMaxEnum;
	S:Extended;
	PC:TSComplexNumber;
begin
if (FBezierCurve<>nil) and (FBezierCurve.VertexQuantity>0) then
	begin
	S:=Abs(Mandelbrot.View.y1-Mandelbrot.View.y2)/60;
	Render.Color4f(1,1,0,0.5);
	Render.BeginScene(SR_QUADS);
	for i:=0 to FBezierCurve.VertexQuantity-1 do
		begin
		if i=FCurveSelectPoint then
			Render.Color4f(1,0.2,0,0.4);
		A:=FBezierCurve.Vertices[i];
		Render.Vertex2f(A.x+S,A.y+S);
		Render.Vertex2f(A.x-S,A.y+S);
		Render.Vertex2f(A.x-S,A.y-S);
		Render.Vertex2f(A.x+S,A.y-S);
		if not FRenderVideo then
		if (Context.CursorKeyPressed=SLeftCursorButton) and (Context.CursorKeyPressedType=SDownKey) then
			begin
			PC:=PointOfASetByCoordinates(Context.CursorPosition(SNowCursorPosition));
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
		A:=FBezierCurve.Vertices[i];
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

procedure TSFractalMandelbrotGUI.UpDateLabelCoordCaption();inline;
var
	Point: TSPoint2int32;
begin
Point:=Context.CursorPosition(SNowCursorPosition);
LabelCoord.Caption:=SStringToPChar('( '+SFloatToString(Mandelbrot.SingularPoint.x,3)+' ; '+SFloatToString(Mandelbrot.SingularPoint.y,3)+' ) , ( '+
	SFloatToString(PointOfASetByCoordinates(Point).x,7)+' ; '
	+SFloatToString(PointOfASetByCoordinates(Point).y,7)+' )');
end;


procedure TSFractalMandelbrotGUI.OffComponents();inline;
begin
ScreenshotPanel.Visible:=False;
ScreenshotPanel.Active:=False;
ColorComboBox.Visible:=False;
ColorComboBox.Active:=False;
TypeComboBox.Visible:=False;
TypeComboBox.Active:=False;
ZumButton.Visible:=False;
ZumButton.Active:=False;
ButtonSelectSingularPoint.Visible:=False;
ButtonSelectSingularPoint.Active:=False;
FButtonEnableCurve.Visible:=False;
FButtonEnableCurve.Active:=False;
StepenComboBox.Visible:=False;
StepenComboBox.Active:=False;
QuantityRecComboBox.Visible:=False;
QuantityRecComboBox.Active:=False;
FBezierCurvePanel.Active:=False;
FBezierCurvePanel.Visible:=False;
FCurvePointPanel.Visible:=False;
FCurvePointPanel.Active:=False;
FIsComponentsActive:=False;
end;

procedure TSFractalMandelbrotGUI.OnComponents();inline;
begin
FIsComponentsActive:=True;
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
ButtonSelectSingularPoint.Visible:=True;
ButtonSelectSingularPoint.Active:=True;
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
with TSFractalMandelbrotGUI(Button.FUserPointer1) do
	begin
	Mandelbrot.Width:=SVal((Button.ComponentOwner.LastInternalComponent.Caption));
	Mandelbrot.Height:=Trunc(SVal((Button.ComponentOwner.LastInternalComponent.Caption))*(Render.Height/Render.Width));
	Changet:=True;
	NowSave:=True;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	end;
end;

procedure CurveColorComboBoxProcedure(a,b:LongInt;Button:TSScreenComponent);
begin
with TSFractalMandelbrotGUI(Button.FUserPointer1) do
	begin
	if FCurveSelectPoint<>-1 then
		FCurveArPoints[FCurveSelectPoint]:=b;
	end;
end;


procedure ColorComboBoxProcedure(a,b:LongInt;Button:TSScreenComponent);
begin
with TSFractalMandelbrotGUI(Button.FUserPointer1) do
	begin
	Mandelbrot.ColorScheme:=b;
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
with TSFractalMandelbrotGUI(Button.FUserPointer1) do
	begin
	case b of
	0 : Mandelbrot.FractalType := SJuliaSet;
	1 : Mandelbrot.FractalType := SMandelbrotSet;
	end;
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
with TSFractalMandelbrotGUI(Button.FUserPointer1) do
	begin
	Mandelbrot.View := TSScreenVertices.Create(-2.5,-2.5*(Render.Height/Render.Width),2.5,2.5*(Render.Height/Render.Width));
	Changet:=True;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	FOldView:=Mandelbrot.View;
	end;
end;

procedure ButtonSelectSingularPointOnChange(Button:TSScreenButton);
begin
with TSFractalMandelbrotGUI(Button.FUserPointer1) do
	begin
	SelectZNimberFlag:=True;
	OffComponents();
	end;
end;

procedure QuantityRecComboBoxProcedure(a,b:LongInt;aaa:TSScreenComponent);
BEGIN
with TSFractalMandelbrotGUI(aaa.FUserPointer1) do
	begin
	Mandelbrot.RecursionLimit:=QuantityRecComboBox.Items[b].Identifier;
	Changet:=True;
	SelectPoint.Import;
	SelectSecondPoint.Import;
	end;
END;

procedure StepenComboBoxProcedure(a,b:LongInt;aaa:TSScreenComponent);
begin
with TSFractalMandelbrotGUI(aaa.FUserPointer1) do
	begin
	Mandelbrot.DegreeOfAComplexNumber:=StepenComboBox.Items[b].Identifier;
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
with TSFractalMandelbrotGUI(Self.FUserPointer1) do
if (Self.FUserPointer2 <> nil) then
	TSScreenComponent(Self.FUserPointer2).Active := Result and (FBezierCurve<>nil) and (FBezierCurve.VertexQuantity>=2);
end;

procedure bcpOnOffVideo(Button:TSScreenButton);
begin
with TSFractalMandelbrotGUI(Button.FUserPointer1) do
	begin
	FEnablePictureStripPanel:=not FEnablePictureStripPanel;
	OnComponents();
	if FEnablePictureStripPanel then
		begin
		Button.Caption:='OFF видео панель';
		FBezierCurve:=TSBezierCurve.Create();
		FBezierCurve.SetContext(Context);
		FBezierCurveGoButton.Active:=False;
		end
	else
		begin
		Button.Caption:='ON видео панель';
		if FBezierCurve<>nil then
			FBezierCurve.Destroy();
		FBezierCurve:=nil;
		if FCurveArPoints<>nil then
			SetLength(FCurveArPoints,0);
		FCurveSelectPoint:=-1;
		FCurvePointPanel.Visible:=False;
		FCurveArPoints:=nil;
		FEnablePictureStripAddingPoints:=False;
		FBezierCurvePanel.InternalComponents[1].Caption:='ON режим добавления точек';
		FBezierCurveLabelPoints.Caption:='Количество точек: 0';
		end;
	end;
end;

procedure bcpGoVideo(Button:TSScreenButton);
begin
with TSFractalMandelbrotGUI(Button.FUserPointer1) do
	begin
	OffComponents();
	FCurveInfoLbl.Visible:=True;
	FCurveInfoLbl.Caption:='Здесь будет отображаться информация';
	FBezierCurveKadrProgressBar.Visible:=True;
	FBezierCurveKadrProgressBar.Progress:=0;
	FNowKadr:=0;
	FAllKadrs:=SVal(FBezierCurveEditKadr.Caption);
	FRenderVideo:=True;
	Changet:=True;
	SelectPoint.Import();
	SelectSecondPoint.Import();
	Mandelbrot.FractalType:=SJuliaSet;
	FVideoBuffer:=SFreeDirectoryName(SImagesDirectory + DirectorySeparator + 'Mandelbrot Buffer', 'Part');
	SMakeDirectory(FVideoBuffer);
	Mandelbrot.Width:=1920;//*5;
	Mandelbrot.Height:=1080;//*5;
	FCurveBeginDateTime.Get();
	end;
end;

procedure bcpAddPoint(Button:TSScreenButton);
begin
with TSFractalMandelbrotGUI(Button.FUserPointer1) do
	begin
	FEnablePictureStripAddingPoints:= not FEnablePictureStripAddingPoints;
	if FEnablePictureStripAddingPoints then
		Button.Caption:='OFF режим добавления точек'
	else
		Button.Caption:='ON режим добавления точек';
	end;
end;

procedure TSFractalMandelbrotGUI.InitMandelbrot();inline;
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
AddNameTheme('Странная');
AddNameTheme('Монохромная');
AddNameTheme('Красная');
AddNameTheme('Желтая пыль');
AddNameTheme('Розовая');
AddNameTheme('Зелёно-красная');
AddNameTheme('Сине-красная');
AddNameTheme('Жёлто-синяя');
AddNameTheme('Зелёно-синяя');
AddNameTheme('Розово-зелёная');
AddNameTheme('Голубая пыль');
AddNameTheme('Красная пыль');
AddNameTheme('Розовая пыль');
AddNameTheme('Зеленая пыль');
AddNameTheme('Оранжевая пыль');

Mandelbrot := TSFractalMandelbrot.Create(Context);
Mandelbrot.Width:=StartDepth;
Mandelbrot.Height:=StartDepth;
Mandelbrot.SingularPoint := TSComplexNumber.Create(-0.181,0.66);
Mandelbrot.FractalType:=SJuliaSet;
Mandelbrot.DegreeOfAComplexNumber:=2;
Mandelbrot.View := TSScreenVertices.Create(-2.5,-2.5*(Render.Height/Render.Width),2.5,2.5*(Render.Height/Render.Width));
Mandelbrot.CreateThreads(QuantityThreads);
Mandelbrot.BeginConstruct;
Mandelbrot.Image.FileName:=SImagesDirectory+DirectorySeparator+'Mandelbrot new.' + TSImageFormatDeterminer.DetermineFileExtensionFromFormat(SDefaultSaveImageFormat(3));

FBeginCalc.Get;
SetLength(FArProgressBar,QuantityThreads);
ii+={Context.TopShift+}40;
for i:=0 to QuantityThreads-1 do
	begin
	FArProgressBar[i]:=TSScreenProgressBar.Create;
	Screen.CreateInternalComponent(FArProgressBar[i]);
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
Screen.CreateInternalComponent(LabelProcent);
LabelProcent.SetBounds(10,ii,300,20);
LabelProcent.Color2 := SVertex4fImport(1,0,0,0.8);
LabelProcent.Color1 := SVertex4fImport(0.5,0,0,0.8);
LabelProcent.Caption:='';
LabelProcent.ViewCaption := False;
LabelProcent.Visible:=True;
LabelProcent.FUserPointer1:=Self;

LabelCoord := SCreateLabel(Screen, '', False, 10,Render.Height-25,Render.Width div 2,20, [SAnchBottom], True, True, Self);
ScreenshotPanel := SCreatePanel(Screen, Render.Width-10-(130+140+10),Render.Height-30,130+140+10,25, [SAnchBottom, SAnchRight], False, True, Self);

Screen.LastInternalComponent.CreateInternalComponent(TSScreenButton.Create);
Screen.LastInternalComponent.LastInternalComponent.SetBounds(130,5,140,20);
Screen.LastInternalComponent.LastInternalComponent.Caption:='Сохранить';
Screen.LastInternalComponent.LastInternalComponent.BoundsMakeReal;
(Screen.LastInternalComponent.LastInternalComponent as TSScreenButton).OnChange:=TSScreenComponentProcedure(@SaveImage);
Screen.LastInternalComponent.LastInternalComponent.FUserPointer1:=Self;

SCreateEdit(Screen.LastInternalComponent, '4096', TSScreenEditTextTypeFunction(@MyMandNumberFucntion), 5,5,120,20, [], False, True, Self);
Screen.LastInternalComponent.LastInternalComponent.FUserPointer2:=Screen.LastInternalComponent.InternalComponents[Screen.LastInternalComponent.InternalComponentCount()-1];

Screen.CreateInternalComponent(TSScreenComboBox.Create);
Screen.LastInternalComponent.SetBounds(Render.Width-50-125+45,5{+Context.TopShift},120,20);
Screen.LastInternalComponent.Anchors:=[SAnchRight];
for i:=0 to High(VNameThemes) do
	(Screen.LastInternalComponent as TSScreenComboBox).CreateItem(VNameThemes[i]);
(Screen.LastInternalComponent as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@ColorComboBoxProcedure);
(Screen.LastInternalComponent as TSScreenComboBox).SelectItem:=0;
ColorComboBox:=Screen.LastInternalComponent as TSScreenComboBox;
Screen.LastInternalComponent.FUserPointer1:=Self;

TypeComboBox:=TSScreenComboBox.Create;
Screen.CreateInternalComponent(TypeComboBox);
Screen.LastInternalComponent.SetBounds(Render.Width-50-125+45-185,5,180,20);
Screen.LastInternalComponent.Anchors:=[SAnchRight];
(Screen.LastInternalComponent as TSScreenComboBox).CreateItem('Множество Жюлиа');
(Screen.LastInternalComponent as TSScreenComboBox).CreateItem('Модель Мандельброта');
(Screen.LastInternalComponent as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@TypeComboBoxProcedure);
(Screen.LastInternalComponent as TSScreenComboBox).SelectItem:=0;
Screen.LastInternalComponent.FUserPointer1:=Self;

Screen.CreateInternalComponent(TSScreenButton.Create);
Screen.LastInternalComponent.SetBounds(Render.Width-50-125-185+45-105,5,100,20);
Screen.LastInternalComponent.Anchors:=[SAnchRight];
Screen.LastInternalComponent.Caption:='Сброс зума';
ZumButton:=Screen.LastInternalComponent as TSScreenButton;
ZumButton.OnChange:=TSScreenComponentProcedure(@ZumButtonOnChange);
Screen.LastInternalComponent.FUserPointer1:=Self;

Screen.CreateInternalComponent(TSScreenButton.Create);
Screen.LastInternalComponent.SetBounds(Render.Width-50-125-185-105+45-125,5{+Context.TopShift},120,20);
Screen.LastInternalComponent.Anchors:=[SAnchRight];
Screen.LastInternalComponent.Caption:='Установ. тчк.';
ButtonSelectSingularPoint:=Screen.LastInternalComponent as TSScreenButton;
ButtonSelectSingularPoint.OnChange:=TSScreenComponentProcedure(@ButtonSelectSingularPointOnChange);
Screen.LastInternalComponent.FUserPointer1:=Self;

StepenComboBox:=TSScreenComboBox.Create;
Screen.CreateInternalComponent(StepenComboBox);
Screen.LastInternalComponent.SetBounds(Render.Width-50-125-185-105-125+45-105,5{+Context.TopShift},100,20);
Screen.LastInternalComponent.Anchors:=[SAnchRight];
Screen.LastInternalComponent.Caption:='';
Screen.LastInternalComponent.BoundsMakeReal;
(Screen.LastInternalComponent as TSScreenComboBox).SelectItem:=1;
(Screen.LastInternalComponent as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@StepenComboBoxProcedure);
Screen.LastInternalComponent.FUserPointer1:=Self;
i:=1;
while i<=100 do
	begin
	(Screen.LastInternalComponent as TSScreenComboBox).CreateItem(SStringToPChar(SStr(i)),nil,i);
	i+=1;
	end;

QuantityRecComboBox:=TSScreenComboBox.Create;
Screen.CreateInternalComponent(QuantityRecComboBox);
Screen.LastInternalComponent.SetBounds(Render.Width-50-125-185-105-125-105+45-105,5{+Context.TopShift},100,20);
Screen.LastInternalComponent.Anchors:=[SAnchRight];
Screen.LastInternalComponent.Caption:='';
Screen.LastInternalComponent.BoundsMakeReal;
(Screen.LastInternalComponent as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@QuantityRecComboBoxProcedure);
Screen.LastInternalComponent.FUserPointer1:=Self;
i:=6;
while i<=13 do
	begin
	(Screen.LastInternalComponent as TSScreenComboBox).CreateItem(SStringToPChar(SStr(2**i)),nil,2**i);
	if i=8 then
		begin
		(Screen.LastInternalComponent as TSScreenComboBox).SelectItem := QuantityRecComboBox.ItemsCount - 1;
		end;
	i+=1;
	end;

FCurveInfoLbl := SCreateLabel(Screen, '', Render.Width-10-(130+140+10)-150-5,Render.Height-30-25,-(-(130+140+10)-150-5),20, [SAnchRight, SAnchBottom]);

FBezierCurveKadrProgressBar:=TSScreenProgressBar.Create();
Screen.CreateInternalComponent(FBezierCurveKadrProgressBar);
Screen.LastInternalComponent.SetBounds(Render.Width-10-(130+140+10)-150-5,Render.Height-30,-(-(130+140+10)-150-5),20);
(Screen.LastInternalComponent as TSScreenProgressBar).ViewProgress:=True;
(Screen.LastInternalComponent as TSScreenProgressBar).Color1:=SVertex4fImport(1,1,0,0.7);
(Screen.LastInternalComponent as TSScreenProgressBar).Color2:=SVertex4fImport(1,1/3,0,0.9);
Screen.LastInternalComponent.Anchors:=[SAnchRight,SAnchBottom];

FButtonEnableCurve:=TSScreenButton.Create();
Screen.CreateInternalComponent(FButtonEnableCurve);
Screen.LastInternalComponent.SetBounds(Render.Width-10-(130+140+10)-150-5,Render.Height-30,150,20);
Screen.LastInternalComponent.Anchors:=[SAnchRight,SAnchBottom];
Screen.LastInternalComponent.Caption:='On видео панель';
FButtonEnableCurve.OnChange:=TSScreenComponentProcedure(@bcpOnOffVideo);
Screen.LastInternalComponent.FUserPointer1:=Self;

FCurvePointPanel := SCreatePanel(Screen, Render.Width-10-(140+10),Render.Height-130-130,140+10,125, [SAnchBottom, SAnchRight], False, True, Self);

FCurvePointPanel.CreateInternalComponent(TSScreenComboBox.Create);
FCurvePointPanel.LastInternalComponent.SetBounds(5,5,130,20);
for i:=0 to High(VNameThemes) do
	(FCurvePointPanel.LastInternalComponent as TSScreenComboBox).CreateItem(VNameThemes[i]);
(FCurvePointPanel.LastInternalComponent as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@CurveColorComboBoxProcedure);
(FCurvePointPanel.LastInternalComponent as TSScreenComboBox).SelectItem:=0;
(FCurvePointPanel.LastInternalComponent as TSScreenComboBox).MaxLines:=5;
FCurvePCB:=FCurvePointPanel.LastInternalComponent as TSScreenComboBox;
FCurvePointPanel.LastInternalComponent.FUserPointer1:=Self;

FBezierCurvePanel := SCreatePanel(Screen, Render.Width-10-(130+140+10),Render.Height-130,130+140+10,125, [SAnchBottom, SAnchRight], False, True, Self);

FBezierCurvePanel.CreateInternalComponent(TSScreenButton.Create());
FBezierCurvePanel.LastInternalComponent.Caption:='ON режим добавления точек';
FBezierCurvePanel.LastInternalComponent.SetBounds(3,3,275,20);
(FBezierCurvePanel.LastInternalComponent as TSScreenButton).OnChange:=TSScreenComponentProcedure(@bcpAddPoint);
FBezierCurvePanel.LastInternalComponent.FUserPointer1:=Self;
FBezierCurvePanel.LastInternalComponent.BoundsMakeReal();

FBezierCurveLabelPoints := SCreateLabel(FBezierCurvePanel, 'Количество точек: 0', 3,47,137,20, False, True, Self);
SCreateLabel(FBezierCurvePanel, 'Количество кадров:', False, 3,25,275,20, False, True, Self);
FBezierCurveEditKadr := SCreateEdit(Screen.LastInternalComponent, '200', TSScreenEditTextTypeFunction(@MyMandNumberFucntionVideo), 123,27,137,20, [], False, True, Self);
SCreateLabel(FBezierCurvePanel, 'Примерно займет времени: много!', 3,70,275,20, False, True, Self);

FBezierCurveGoButton:=TSScreenButton.Create();
FBezierCurvePanel.CreateInternalComponent(FBezierCurveGoButton);
(FBezierCurvePanel.LastInternalComponent as TSScreenButton).Caption:='Начать (требуется много времени)';
(FBezierCurvePanel.LastInternalComponent as TSScreenButton).SetBounds(3,92,275,20);
(FBezierCurvePanel.LastInternalComponent as TSScreenButton).OnChange:=TSScreenComponentProcedure(@bcpGoVideo);
FBezierCurvePanel.LastInternalComponent.FUserPointer1:=Self;
FBezierCurvePanel.LastInternalComponent.BoundsMakeReal();
FBezierCurveEditKadr.FUserPointer2:=Pointer(FBezierCurvePanel.LastInternalComponent);

if VNameThemes<>nil then
	begin
	for i:=0 to High(VNameThemes) do
		VNameThemes[i]:='';
	SetLength(VNameThemes,0);
	end;
end;

procedure BeginInitMand(Button:TSScreenButton);
begin
with TSFractalMandelbrotGUI(Button.FUserPointer1) do
	begin
	Button.ComponentOwner.Visible:=(False);
	QuantityThreads:=SVal(((Button.ComponentOwner.InternalComponents[5] as TSScreenComboBox).Items[(Button.ComponentOwner.InternalComponents[5]as TSScreenComboBox).SelectItem].Caption));
	StartDepth:=SVal((Button.ComponentOwner.InternalComponents[4] as TSScreenComboBox).Items[(Button.ComponentOwner.InternalComponents[4] as TSScreenComboBox).SelectItem].Caption);
	InitMandelbrot;
	MandelbrotInitialized:=True;
	end;
end;


constructor TSFractalMandelbrotGUI.Create();
var
	i : TSByte;
begin
inherited;
FTNRF := nil;
FCurvePointPanel := nil;
FCurveSelectPoint := -1;
FCurveArPoints := nil;
FRenderVideo := False;
FBezierNowSelectPoint := 0;
FIsComponentsActive := False;
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
ButtonSelectSingularPoint := nil;
MandelbrotInitialized := False;
VideoPanel := nil;
FStartPanel := nil;
FCurveInfoLbl := nil;

FStartPanel := SCreatePanel(Screen, False, False, 300,Render.Height-200, True, True, Self);
SCreateLabel(FStartPanel, 'Количество потоков:', 5,5,Screen.LastInternalComponent.Width-10,20, True, True, Self);
SCreateLabel(FStartPanel, 'Количество потоков:', 5,55,Screen.LastInternalComponent.Width-10,20, True, True, Self);

Screen.LastInternalComponent.CreateInternalComponent(TSScreenButton.Create);
Screen.LastInternalComponent.LastInternalComponent.SetBounds(75,115,140,20);
Screen.LastInternalComponent.LastInternalComponent.Visible:=True;
Screen.LastInternalComponent.LastInternalComponent.Caption := 'Готово';
Screen.LastInternalComponent.LastInternalComponent.OnChange:=TSScreenComponentProcedure(@BeginInitMand);
Screen.LastInternalComponent.LastInternalComponent.BoundsMakeReal;
Screen.LastInternalComponent.LastInternalComponent.FUserPointer1:=Self;

Screen.LastInternalComponent.CreateInternalComponent(TSScreenComboBox.Create);
Screen.LastInternalComponent.LastInternalComponent.Visible:=True;
Screen.LastInternalComponent.LastInternalComponent.SetBounds(5,80,Screen.LastInternalComponent.Width-10,20);
(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).SelectItem:=4;
(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).CreateItem('64');
(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).CreateItem('128');
(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).CreateItem('256');
(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).CreateItem('512');
(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).CreateItem('1024');
(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).CreateItem('2048');
Screen.LastInternalComponent.LastInternalComponent.BoundsMakeReal;
Screen.LastInternalComponent.LastInternalComponent.FUserPointer1:=Self;

Screen.LastInternalComponent.CreateInternalComponent(TSScreenComboBox.Create);
Screen.LastInternalComponent.LastInternalComponent.Visible:=True;
Screen.LastInternalComponent.LastInternalComponent.SetBounds(5,30,Screen.LastInternalComponent.Width-10,20);
(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).CreateItem('1');
(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).CreateItem('2');
(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).CreateItem('3');
(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).CreateItem('4');
(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).CreateItem('6');
(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).CreateItem('8');
(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).CreateItem('10');
(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).CreateItem('12');
(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).CreateItem('16');
Screen.LastInternalComponent.LastInternalComponent.BoundsMakeReal();
Screen.LastInternalComponent.LastInternalComponent.FUserPointer1:=Self;
case SCoreCount() of 
2:(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).SelectItem:=1;
3:(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).SelectItem:=2;
4:(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).SelectItem:=3;
6:(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).SelectItem:=4;
8:(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).SelectItem:=5;
10:(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).SelectItem:=6;
12:(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).SelectItem:=7;
16:(Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).SelectItem:=8;
else (Screen.LastInternalComponent.LastInternalComponent as TSScreenComboBox).SelectItem:=3;
end;

FTNRF := SCreateFontFromFile(Context, SFontDirectory+DirectorySeparator+'Times New Roman.sf');
end;

destructor TSFractalMandelbrotGUI.Destroy();
var
	Index : TSMaxEnum;
begin
SKill(FCurveInfoLbl);
SKill(FTNRF);
SKill(FCurvePointPanel);
if FCurveArPoints<>nil then
	SetLength(FCurveArPoints,0);
SKill(FBezierCurveKadrProgressBar);
SKill(FBezierCurvePanel);
SKill(FButtonEnableCurve);
SKill(FBezierCurve);
SKill(SecondImage);
SKill(LabelProcent);
SKill(LblProcent);
SKill(LabelCoord);
SKill(ScreenshotPanel);
SKill(ColorComboBox);
SKill(TypeComboBox);
SKill(ZumButton);
SKill(StepenComboBox);
SKill(QuantityRecComboBox);
SKill(ButtonSelectSingularPoint);
SKill(VideoPanel);
SKill(FStartPanel);
if Mandelbrot<>nil then
	Mandelbrot.Destroy;
Mandelbrot:=nil;
if FArProgressBar<>nil then
	for Index := 0 to High(FArProgressBar) do
		SKill(FArProgressBar[Index]);
SetLength(FArProgressBar,0);
FArProgressBar:=nil;
inherited;
end;

class function TSFractalMandelbrotGUI.ClassName:string;
begin
Result := 'Множество Мандельброта и подобное';
end;

function TSFractalMandelbrotGUI.PointOfASetByCoordinates(const Point: TSPoint2int32):TSComplexNumber;inline;
begin
Result.Import(
	Mandelbrot.View.x1+(Point.x/(Render.Width)*abs(Mandelbrot.View.x1-Mandelbrot.View.x2)),
	Mandelbrot.View.y1+((Render.Height-Point.y)/(Render.Height)*abs(Mandelbrot.View.y1-Mandelbrot.View.y2))
	);
end;


procedure TSFractalMandelbrotGUI.Paint();

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

procedure QuadVertices(const Point1, Point2 : TSPoint2int32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Render.Vertex(Point1);
Render.Vertex2f(Point1.x, Point2.y);
Render.Vertex(Point2);
Render.Vertex2f(Point2.x, Point1.y);
end;

procedure QuadVertices(const VType : TSMaxEnum; const Point1, Point2 : TSPoint2int32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Render.BeginScene(VType);
QuadVertices(Point1, Point2);
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
QuadVertices(SR_QUADS, SelectPoint, SelectSecondPoint);
Render.Color4f(0,0.7,0.70,0.8);
QuadVertices(SR_LINE_LOOP, SelectPoint, SelectSecondPoint);

Render.Color4f(0.6,0.5,0.30,0.6);
QuadVertices(SR_QUADS, SelectPoint, SelectSecondNormalPoint);
Render.Color4f(1,0.9,0.20,0.8);
QuadVertices(SR_LINE_LOOP, SelectPoint, SelectSecondNormalPoint);
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
	FOldView:=Mandelbrot.View;
	Mandelbrot.View := TSScreenVertices.Create(
		PointOfASetByCoordinates(SelectPoint).x,
		PointOfASetByCoordinates(SelectSecondPoint).y,
		PointOfASetByCoordinates(SelectSecondPoint).x,
		PointOfASetByCoordinates(SelectPoint).y
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
		Mandelbrot.AfterConstruct();
		
		for i:=0 to QuantityThreads-1 do
			begin
			FArProgressBar[i].Visible:=False;
			//Screen.InternalComponents[CID-QuantityThreads+i+2].AsProgressBar.Visible:=False;
			end;
		
		FDateTime.Get();
		if not FRenderVideo then
			begin
			LabelProcent.Visible:=False;
			LblProcent.Visible:=False;
			end;
		LabelProcent.Caption:='100%';
		LblProcent.Caption:=SStringToPChar('100%, Прошло: '+
			(
			SSecondsToStringTime(
			(FDateTime-FBeginCalc).GetPastSeconds))+'.');
		
		if (not NowSave)  and (not FRenderVideo) then
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
			if Mandelbrot.Image<>nil then
				begin
				if not SExistsDirectory(SImagesDirectory) then
					SMakeDirectory(SImagesDirectory);
				if FRenderVideo then
					begin
					//Mandelbrot.FImage.Image.SetBounds(1920,1080);
					Mandelbrot.Image.FileName:=FVideoBuffer+DirectorySeparator+
						//GetZeros(QuantityNumbers(FAllKadrs)-QuantityNumbers(FNowKadr))+
						SStr(FNowKadr)+'.' + TSImageFormatDeterminer.DetermineFileExtensionFromFormat(SDefaultSaveImageFormat(3));
					end;
				FTNRF.AddWaterString('made by Smooth', Mandelbrot.Image,0);
				Mandelbrot.Image.Save(SDefaultSaveImageFormat(Mandelbrot.Image.BitMap.Channels));
				if not FRenderVideo then
					begin
					Mandelbrot.Width:=StartDepth;
					Mandelbrot.Height:=StartDepth;
					end;
				Mandelbrot.KillImage();
				if not FRenderVideo then
					begin
					Mandelbrot.Image:=SecondImage;
					SecondImage:=nil;
					end;
				if FRenderVideo then
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
				PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[i]^.Data)^.h2-
				PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[i]^.Data)^.h1)+
				PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[i]^.Data)^.FHePr;
			if Mandelbrot.ThreadData[i]^.Finished and (FArProgressBar[i].Visible) then
				begin
				//FArProgressBar[i].Visible:=False;
				for ii:=0 to Mandelbrot.Threads-1 do
					begin
					{if ii>=i+1 then
						FArProgressBar[ii].FNeedTop-=25;}
					FDateTime.Get;
					if (not FNewPotokInit) then
					if 
						(Mandelbrot.ThreadData[ii]^.Data<>nil) and 
						(Mandelbrot.ThreadData[ii]^.Finished=False) and 
						(ii<>i) and 
						(PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[ii]^.Data)^.NewPos=0) and 
						(
						(PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[ii]^.Data)^.h2-
						PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[ii]^.Data)^.NowPos)
						*Mandelbrot.Width>50000
						) and
						(
						(
						(FDateTime-
						PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[ii]^.Data)^.FBeginDate).GetPastMilliseconds
						)/FArProgressBar[ii].Progress*(1 - FArProgressBar[ii].Progress)
						>150
						) then
						// i - Только что Завершивший свою работу поток
						//ii - Свободный для вычислительной деятельности поток
						begin
						PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[ii]^.Data)^.FWait:=True;
						
						if (Mandelbrot.ThreadData[ii]^.Finished=False) then
			begin
						
						FArProgressBar[ii].Color2:=(FArProgressBar[ii].Color2+SVertex4fImport(0.9,0.45,0,0.8))/2;
						FArProgressBar[ii].Color1:=(FArProgressBar[ii].Color1+SVertex4fImport(1,0.5,0,1))/2;
						FArProgressBar[i].Color2:=(FArProgressBar[i].Color2+SVertex4fImport(0.1,1,0.1,0.7))/2;
						FArProgressBar[i].Color1:=(FArProgressBar[i].Color1+SVertex4fImport(0,1,0,1))/2;
						
						iiiC:=0;
						if Mandelbrot.ThreadData[i]^.Data<>nil then
							begin
							iiiC:=PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[i]^.Data)^.h2-
									PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[i]^.Data)^.h1+
									PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[i]^.Data)^.FHePr;
							Mandelbrot.ThreadData[i]^.FreeMemData();
							end;
						Mandelbrot.ThreadData[i]^.KillThread();
						
						Mandelbrot.ThreadData[i]^.Data:=TSFractalMandelbrotThreadData.Create(
							Mandelbrot.ThreadData[i],
							PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[ii]^.Data)^.NowPos+
							(
							(
							PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[ii]^.Data)^.h2-
							PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[ii]^.Data)^.NowPos
							) div 2
							),
								
							PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[ii]^.Data)^.h2,
							FArProgressBar[i].GetProgressPointer(),i);

						PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[i]^.Data)^.NewPos:=0;
						PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[i]^.Data)^.NowPos:=0;
						PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[i]^.Data)^.FWait:=False;
						Mandelbrot.ThreadData[i]^.Finished:=False;
						PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[i]^.Data)^.FBeginDate.Get;
						PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[i]^.Data)^.FHePr:=iiiC;
						FArProgressBar[i].Progress:=0;
						FArProgressBar[i].ProgressTimer:=0;
						
						Mandelbrot.ThreadData[i]^.Thread:=
							TSThread.Create(
								TSPointerProcedure(@TSFractalMandelbrotThreadProcedure),
								Mandelbrot.ThreadData[i]^.Data);
						
						PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[ii]^.Data)^.NewPos:=
							PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[ii]^.Data)^.NowPos+
							(
							(
							PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[ii]^.Data)^.h2-
							PSFractalMandelbrotThreadData(Mandelbrot.ThreadData[ii]^.Data)^.NowPos
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


	if (Mandelbrot.Image<>nil) and Mandelbrot.Image.Loaded then
		begin
		Render.Color3f(1,1,1);
		Mandelbrot.Paint();
		
		// PointOfAScreenByCoordinates (Coordinates is complex)
		VectorBySingularPoint.Import(
			abs(Mandelbrot.SingularPoint.x-Min(Mandelbrot.View.X1,Mandelbrot.View.X2))/Mandelbrot.View.AbsX*Render.Width,
			abs(Mandelbrot.SingularPoint.Y-Max(Mandelbrot.View.Y1,Mandelbrot.View.Y2))/Mandelbrot.View.AbsY*Render.Height
			);
		Render.Color3f(1,1,1);
		Render.BeginScene(SR_TRIANGLES);
		Render.Vertex2f(VectorBySingularPoint.x+5,VectorBySingularPoint.y);
		Render.Vertex2f(VectorBySingularPoint.x-2,VectorBySingularPoint.y-4);
		Render.Vertex2f(VectorBySingularPoint.x-2,VectorBySingularPoint.y+4);
		Render.EndScene();
			
		if (SelectZNimberFlag and ((Context.CursorKeysPressed(SLeftCursorButton)))) or (Context.CursorKeysPressed(SMiddleCursorButton)) then
			begin
			ComplexNumber:=PointOfASetByCoordinates(Context.CursorPosition(SNowCursorPosition));
			if Mandelbrot.SingularPoint <> ComplexNumber then
				begin
				Mandelbrot.SingularPoint:=ComplexNumber;
				SelectZNimberFlag:=False;
				OnComponents();
				Context.SetCursorKey(SUpKey,SLeftCursorButton);
				if Mandelbrot.FractalType = SJuliaSet then
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
	
	if (not FRenderVideo) and LabelProcent.Visible and ( not Mandelbrot.ThreadsReady) then
	if (Context.KeyPressedByte=27) and 
		(Context.KeyPressedType=SUpKey) and (SecondImage<>nil) then
			begin
			for i:=0 to Mandelbrot.Threads - 1 do
				begin
				Mandelbrot.ThreadData[i]^.KillThread();
				Mandelbrot.ThreadData[i]^.FreeMemData();
				Mandelbrot.ThreadData[i]^.Finished:=True;
				end;
			Mandelbrot.KillImage();
			Mandelbrot.Image:=SecondImage;
			SecondImage:=nil;
			Mandelbrot.View := FOldView;
			end;
	
	if FEnablePictureStripAddingPoints  and 
		(Context.KeyPressedChar='A') and 
		(Context.KeyPressedType=SUpKey) then
		begin
		if FCurveArPoints=nil then
			SetLength(FCurveArPoints,1)
		else 
			SetLength(FCurveArPoints,Length(FCurveArPoints)+1);
		FCurveArPoints[High(FCurveArPoints)]:=Mandelbrot.ColorScheme;
		FBezierCurve.AddVertex(
			SVertex3fImport(
				PointOfASetByCoordinates(Context.CursorPosition(SNowCursorPosition)).x,
				PointOfASetByCoordinates(Context.CursorPosition(SNowCursorPosition)).y));
		FBezierCurve.Detalization:=FBezierCurve.VertexQuantity*10;
		FBezierCurve.Construct();
		Context.SetKey(SNullKey, Context.KeyPressedByte());
		FBezierCurveLabelPoints.Caption:='Количество точек: '+SStr(FBezierCurve.VertexQuantity);
		FBezierCurveGoButton.Active:=(FBezierCurve.VertexQuantity>=2) and (TSEditTextTypeFunctionNumber(FBezierCurveEditKadr));
		end;
	
	if FRenderVideo or 
	(FEnablePictureStripPanel and FIsComponentsActive)  then
		begin
		//Mandelbrot.FView.Write();
		Render.InitOrtho2d(Mandelbrot.View.x1,Mandelbrot.View.y1,Mandelbrot.View.x2,Mandelbrot.View.y2);
		if (FBezierCurve<>nil) then
			begin
			FBezierCurve.Paint();
			if FRenderVideo then
				begin
				Render.Color3f(1,0,1);
				Render.PointSize(5);
				Render.BeginScene(SR_POINTS);
				Render.Vertex(Mandelbrot.SingularPoint);
				Render.EndScene();
				Render.PointSize(1);
				end;
			end;
		DrawBezierPoints();
		end;
	
	if Changet then
		begin
		if FRenderVideo then
			begin
			FNowKadr+=1;
			if FNowKadr>FAllKadrs then
				begin
				FRenderVideo:=False;
				Changet:=False;
				Mandelbrot.Image:=SecondImage;
				SecondImage:=nil;
				FBezierCurveKadrProgressBar.Visible:=False;
				Mandelbrot.AttitudeForThemeEnable:=False;
				FCurveInfoLbl.Visible:=False;
				Exit;
				end
			else
				FBezierCurveKadrProgressBar.Progress:=(FNowKadr-1)/FAllKadrs;
			end;
		OffComponents();
		if not FRenderVideo then
			if SecondImage<>nil then
				SecondImage.Destroy;
		if (not FRenderVideo) or (FRenderVideo and (Mandelbrot.Image<>nil)) then
			begin
			SecondImage:=Mandelbrot.Image;
			Mandelbrot.Image:=nil;
			end;
		if FRenderVideo then
			begin
			Mandelbrot.SingularPoint := TSComplexNumber.Create(FBezierCurve.GetResultVertex(FNowKadr/FAllKadrs).x, FBezierCurve.GetResultVertex(FNowKadr/FAllKadrs).y);
			Mandelbrot.AttitudeForThemeEnable:=True;
			Mandelbrot.AttitudeForTheme:=FBezierCurve.LowAttitude;
			if FBezierCurve.LowIndex<>FBezierCurve.VertexQuantity-1 then
				begin
				Mandelbrot.Theme1:=FCurveArPoints[FBezierCurve.LowIndex];
				Mandelbrot.Theme2:=FCurveArPoints[FBezierCurve.LowIndex+1];
				end
			else
				begin
				Mandelbrot.Theme1:=FCurveArPoints[FBezierCurve.LowIndex];
				Mandelbrot.Theme2:=FCurveArPoints[FBezierCurve.LowIndex];
				end;
			TDT.Get();
			if FNowKadr<>1 then
				FCurveInfoLbl.Caption:='Прошло: '+
					SSecondsToStringTime((TDT-FCurveBeginDateTime).GetPastSeconds)
					+', Осталось: '+
					SSecondsToStringTime(Trunc(
					(TDT-FCurveBeginDateTime).GetPastSeconds/((FNowKadr-1)/FAllKadrs)*(1-(FNowKadr-1)/FAllKadrs)
					))
					+', FPS: '+SStrReal(FNowKadr/(TDT-FCurveBeginDateTime).GetPastSeconds,3)+' к/с';
			end;
		if (not FRenderVideo) and (not NowSave) then
			begin
			Mandelbrot.Width:=StartDepth;
			Mandelbrot.Height:=StartDepth;
			end;
		Mandelbrot.BeginConstruct();
		Mandelbrot.Image.FileName := SFreeFileName(SImagesDirectory + DirectorySeparator + 'Mandelbrot.' + TSImageFormatDeterminer.DetermineFileExtensionFromFormat(SDefaultSaveImageFormat(3)));
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

end.