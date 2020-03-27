{$INCLUDE Smooth.inc}

unit SmoothGeneticalAlgoritmRelease;

interface

uses 
	 SmoothBase
	,SmoothGeneticalAlgoritm
	,SmoothScreenBase
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothGraphicViewer
	,SmoothMath
	,SmoothExtensionManager
	,SmoothRenderBase
	,SmoothCommonStructs
	,SmoothScreenClasses
	;

type
	TSGenAlg=class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Paint();override;
			public
		FLMM, FL1, FL2, FL3, FL4, FL5, FL6, FL7, FL8, FL9, FXL, FLPoint : TSScreenLabel;
		FP1 : TSScreenPanel;
		FB1:TSScreenButton;
		FE1, FE2, FE22, FE3, FE4 : TSScreenEdit;
		FS1 : TSScreenEdit;
		FCB1,FCBMM,FCB2,FCB4,FCB5,FCB3,FCB6,FCB7:TSScreenComboBox;
		FNB:TSScreenButton;
			public
		FG:TSGraphic;
		FGA:TSGA;
			public
		FFindPoint,a,b:TSGAValueType;
		FResultFP:Extended;
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothMathUtils
	;

procedure TSGenAlg_GenerateComponentActives(const Self : TSScreenComponent);
var
	MyClass:TSGenAlg;
begin
MyClass:=TSGenAlg(Self.FUserPointer1);
with MyClass do
	begin
	FE2.TextTypeEvent;
	FE22.TextTypeEvent;
	FB1.Active:=FE3.TextComplite and 
		FE1.TextComplite and 
		FE4.TextComplite and 
		FE2.TextComplite and 
		FE22.TextComplite and 
		(((FCB3.SelectItem = 1) and (FS1.TextComplite)) or ((FCB3.SelectItem<>1))) and
		(SVal((FE2.Caption))<=SVal((FE22.Caption)));
	if FE2.TextComplite and 
		FE22.TextComplite and 
		(not(SVal((FE2.Caption))<=SVal((FE22.Caption)))) then
		begin
		FE2.TextComplite:=False;
		FE22.TextComplite:=False;
		end;
	end;
end;

procedure mmmFCB3OnChange(const Self:TSScreenComboBox);
begin
with TSGenAlg(Self.FUserPointer1) do
if Self.SelectItem=1 then
	begin
	FL3.Caption:='Предпологаемая точка, вид селекции:';
	//Self.SetBounds(260+103,129,167,21);
	Self.Left:=260+103;
	Self.Width:=167;
	//FS1.SetBounds(260,129,99,21);
	FS1.Width:=99;
	FS1.Visible:=true;
	end
else
	begin
	FL3.Caption:='Вид селекции:';
	//FS1.SetBounds(260,129,0,21);
	//Self.SetBounds(260,129,270,21);
	FS1.Width:=0;
	Self.Left:=260;
	Self.Width:=270;
	FS1.Visible:=False;
	end;
TSGenAlg_GenerateComponentActives(Self);
end;

function MyTTFE(const s : TSScreenEdit):boolean;
var
	Ex:TSExpression = nil;
begin
Result:=S.Caption='';//nil);
if not Result then
	begin
	Ex:=TSExpression.Create;
	Ex.Expression:=SStringToPChar(S.Caption);
	Ex.CanculateExpression();
	if (Ex.ErrorsQuantity=0) and (Length(Ex.Variables)<=1) then
		begin
		Ex.BeginCalculate;
		Ex.ChangeVariables(Ex.Variable,TSExpressionChunkCreateReal(0));
		Ex.Calculate;
		end
	else
		if Length(Ex.Variables)<>1 then
			TSGenAlg(S.FUserPointer1).FXl.Caption:=SStringToPChar('f(?)=');
	if Length(Ex.Variables)=1 then
		TSGenAlg(S.FUserPointer1).FXl.Caption:=SStringToPChar('f('+SPCharToString(Ex.Variable)+')=');
	Result:=(Ex.ErrorsQuantity=0) and (Length(Ex.Variables)<=1);
	Ex.Destroy;
	TSGenAlg(S.FUserPointer1).FXl.Width:=TSGenAlg(S.FUserPointer1).FXl.Skin.Font.StringLength(TSGenAlg(S.FUserPointer1).FXl.Caption);
	TSGenAlg(S.FUserPointer1).FXl.Left:=258-TSGenAlg(S.FUserPointer1).FXl.Skin.Font.StringLength(TSGenAlg(S.FUserPointer1).FXl.Caption);
	end
else
	begin
	Result:=False;
	TSGenAlg(S.FUserPointer1).FXl.Caption:=SStringToPChar('f(?)=');
	end;
end;

function Func123Haha(const x:TSGAValueType;const Ex2:TSExpression):TSGAValueType;
begin
Ex2.BeginCalculate;
Ex2.ClearErrors;
Ex2.ChangeVariables(Ex2.Variable,TSExpressionChunkCreateReal(x));
Ex2.Calculate;
if (Ex2.Resultat.Quantity>0) and (SFloatExists(Ex2.Resultat.FConst)) and (Ex2.ErrorsQuantity=0) then
	Result:=Ex2.Resultat.FConst
else
	Result:=Nan;
end;


procedure New1234543454354(Button:TSScreenComponent);
begin
with TSGenAlg(Button.FUserPointer1) do
	begin
	FP1.Visible:=True;
	Button.Visible:=False;
	FS1.Visible:=FCB3.SelectItem=1;
	end;
end;

procedure GAFindMin(Button:TSScreenComponent);
var
	Min,Max:Extended;
	Ex:TSExpression = nil;
begin
Button.Parent.Visible:=False;
with TSGenAlg(Button.FUserPointer1) do
	begin
	a:=SVal((FE2.Caption));
	b:=SVal((FE22.Caption));
	
	Ex:=TSExpression.Create;
	Ex.Expression:=SStringToPChar((FE1.Caption));
	Ex.CanculateExpression;
	
	FGA:=TSGA.Create;
	FGA.Interval.a:=a;
	FGA.Interval.b:=b;
	FGA.WhatFind:=Boolean(FCBMM.SelectItem);
	FGA.FQuantityPopulation:=SVal((FE3.Caption));
	FGA.FQuantityIteration:=SVal((FE4.Caption));
	FGA.FFunction:=TSGAFunction(@Func123Haha);
	FGA.FunctionPointer:=Ex;
	FGA.Selection1Param:=SVal((FS1.Caption));
	FGA.MutationType:=FCB5.SelectItem;
	FGA.KrossingoverType:=FCB4.SelectItem;
	FGA.NewPopulation(FCB2.SelectItem);
	FGA.Calculate(FCB3.SelectItem);
	
	FFindPoint:=FGA.Resultat;
	FResultFP:=Func123Haha(FFindPoint,Ex);
	
	FGA.Destroy;
	Ex.Destroy;
	
	if FG<>nil then
		FG.Destroy;
	FG:=TSGraphic.Create(Context);
	FG.MathGraphic.Expression:=SStringToPChar(FE1.Caption);
	Max:=FResultFP+Abs(b-a)/2;
	Min:=FResultFP-Abs(b-a)/2;
	FG.View.Import(
		a-Abs(b-a)/2*(1/(Render.Height/Render.Width)),
		Min-Abs(b-a)/2,
		b+Abs(b-a)/2*(1/(Render.Height/Render.Width)),
		Max+Abs(b-a)/2);
	FG.Construct(True);
	
	FLPoint.Caption:=SStringToPChar('('+SStrReal(FFindPoint,5)+','+SStrReal(FResultFP,5)+')');
	FNB.Visible:=True;
	FLPoint.SetBounds(
		Render.Width-5-FLPoint.Skin.Font.StringLength(FLPoint.Caption),
		Render.Height-25,
		FLPoint.Skin.Font.StringLength(FLPoint.Caption),
		21);
	FLPoint.Visible:=True;
	FLPoint.BoundsMakeReal;
	end;
end;

procedure TSGenAlg.Paint();
var
	AbsX:Extended;
begin
if FG<>nil then
	begin
	FG.Messages;
	FG.Construct;
	
	Render.InitMatrixMode(S_2D);
	Render.Color4f(0.3,0.3,1,0.5);
	Render.BeginScene(SR_QUADS);
	with FG do
		begin
		AbsX:=Abs(View.x1-View.x2);
		Render.Vertex2f(Round((a-View.x1)/absx*Render.Width),0);
		Render.Vertex2f(Round((a-View.x1)/absx*Render.Width),Render.Height);
		Render.Vertex2f(Round((b-View.x1)/absx*Render.Width),Render.Height);
		Render.Vertex2f(Round((b-View.x1)/absx*Render.Width),0);
		end;
	Render.EndScene();
	FG.Paint();
	Render.InitMatrixMode(S_2D);
	Render.LineWidth(3);
	Render.BeginScene(SR_LINES);
	Render.Color4f(1,1,0,1);
	FG.VertexOnScreen(SVertex2fImport(FFindPoint,0));
	FG.VertexOnScreen(SVertex2fImport(FFindPoint,FResultFP));
	FG.VertexOnScreen(SVertex2fImport(0,FResultFP));
	FG.VertexOnScreen(SVertex2fImport(FFindPoint,FResultFP));
	Render.EndScene();
	Render.LineWidth(1);
	Render.PointSize(5);
	Render.BeginScene(SR_POINTS);
	Render.Color4f(1,0,0.5,1);
	FG.VertexOnScreen(SVertex2fImport(FFindPoint,0));
	FG.VertexOnScreen(SVertex2fImport(FFindPoint,FResultFP));
	FG.VertexOnScreen(SVertex2fImport(0,FResultFP));
	Render.EndScene();
	Render.PointSize(1);
	end;
end;

constructor TSGenAlg.Create(const VContext : ISContext);
const
	QQQ=35;
begin
inherited Create(VContext);
FG:=nil;
a:=0;
b:=0;

FNB:=TSScreenButton.Create;
Screen.CreateChild(FNB);
Screen.LastChild.SetBounds(Render.Width-90,1 ,80,15);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='Заного';
Screen.LastChild.FUserPointer1:=Self;
FNB.OnChange:=TSScreenComponentProcedure(@New1234543454354);

FP1 := SCreatePanel(Screen, 550,378, [SAnchRight], True, True, Self);
SCreateLabel(FP1, '[', False, 265,38,8,25, [SAnchRight], True, True, Self);
SCreateLabel(FP1, ']', False, 513,38,8,25, [SAnchRight], True, True, Self);
SCreateLabel(FP1, ',', False, 390,38,8,25, [SAnchRight], True, True, Self);
FE2 := SCreateEdit(FP1, '3', SScreenEditTypeInteger, 275,39,110,21, [SAnchRight], True, True, Self);
FE2.OnChange:=TSScreenComponentProcedure(@TSGenAlg_GenerateComponentActives);
FE22 := SCreateEdit(FP1, '7', SScreenEditTypeInteger, 400,39,110,21, [SAnchRight], True, True, Self);
FE22.OnChange := TSScreenComponentProcedure(@TSGenAlg_GenerateComponentActives);
FLMM := SCreateLabel(FP1, 'функции.', False, QQQ+280,338,80,25, [SAnchRight], True, True, Self);

FCBMM:=TSScreenComboBox.Create;
FP1.CreateChild(FCBMM);
FP1.LastChild.SetBounds(QQQ+205,338 ,70,25);
FP1.LastChild.Anchors:=[SAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSScreenComboBox).SelectItem:=0;
(FP1.LastChild as TSScreenComboBox).CreateItem('Минимум');
(FP1.LastChild as TSScreenComboBox).CreateItem('Максимум');

FB1:=TSScreenButton.Create;
FP1.CreateChild(FB1);
FP1.LastChild.SetBounds(QQQ+150,338 ,50,25);
FP1.LastChild.Anchors:=[SAnchRight];
FP1.LastChild.Caption:='Найти';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
FB1.OnChange:=TSScreenComponentProcedure(@GAFindMin);

FE4 := SCreateEdit(FP1, '10', SScreenEditTypeNumber, 260,309,270,21, [SAnchRight], True, True, Self);
FE4.OnChange := TSScreenComponentProcedure(@TSGenAlg_GenerateComponentActives);
FE3 := SCreateEdit(FP1, '10', SScreenEditTypeNumber, 260,279,270,21, [SAnchRight], True, True, Self);
FE3.OnChange := TSScreenComponentProcedure(@TSGenAlg_GenerateComponentActives);
FXL := SCreateLabel(FP1, 'f(x)=', False, 260-20-5-5,9,28,21, [SAnchRight], True, True, Self);
FE1 := SCreateEdit(FP1, 'x^2-5*x+6', TSScreenEditTextTypeFunction(@MyTTFE), 260,9,270,21, [SAnchRight], True, True, Self);
FE1.OnChange := TSScreenComponentProcedure(@TSGenAlg_GenerateComponentActives);

FCB7:=TSScreenComboBox.Create;
FP1.CreateChild(FCB7);
FP1.LastChild.SetBounds(260,249,270,21);
FP1.LastChild.Anchors:=[SAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
FP1.LastChild.Active:=False;
(FP1.LastChild as TSScreenComboBox).SelectItem:=0;
(FP1.LastChild as TSScreenComboBox).CreateItem('Микроэволюция');

FCB6:=TSScreenComboBox.Create;
FP1.CreateChild(FCB6);
FP1.LastChild.SetBounds(260,219,270,21);
FP1.LastChild.Anchors:=[SAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
FP1.LastChild.Active:=False;
(FP1.LastChild as TSScreenComboBox).SelectItem:=0;
(FP1.LastChild as TSScreenComboBox).CreateItem('Элитный');

FCB5:=TSScreenComboBox.Create;
FP1.CreateChild(FCB5);
FP1.LastChild.SetBounds(260,189,270,21);
FP1.LastChild.Anchors:=[SAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSScreenComboBox).SelectItem:=0;
(FP1.LastChild as TSScreenComboBox).CreateItem('Простые');
(FP1.LastChild as TSScreenComboBox).CreateItem('Транстпозиция');

FCB4:=TSScreenComboBox.Create;
FP1.CreateChild(FCB4);
FP1.LastChild.SetBounds(260,159,270,21);
FP1.LastChild.Anchors:=[SAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSScreenComboBox).SelectItem:=0;
(FP1.LastChild as TSScreenComboBox).CreateItem('Стандартный двуточечьный');
(FP1.LastChild as TSScreenComboBox).CreateItem('Частично соответствующий одноточечный');
(FP1.LastChild as TSScreenComboBox).CreateItem('Упорядочивающий одноточечный');
(FP1.LastChild as TSScreenComboBox).CreateItem('Hа основе «Золотого сечения»');

FS1 := SCreateEdit(FP1, '', SScreenEditTypeInteger, 260,129,270,21, [SAnchRight], False, True, Self);
FS1.OnChange := TSScreenComponentProcedure(@TSGenAlg_GenerateComponentActives);

FCB3:=TSScreenComboBox.Create;
FP1.CreateChild(FCB3);
FCB3.OnChange:=TSScreenComponentProcedure(@mmmFCB3OnChange);
FP1.LastChild.SetBounds(260,129,270,21);
FP1.LastChild.Anchors:=[SAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSScreenComboBox).SelectItem:=0;
(FP1.LastChild as TSScreenComboBox).CreateItem('Имбридинг');
(FP1.LastChild as TSScreenComboBox).CreateItem('Селекция по заданной шкале');
(FP1.LastChild as TSScreenComboBox).CreateItem('Аутбридинг');

FCB2:=TSScreenComboBox.Create;
FP1.CreateChild(FCB2);
FP1.LastChild.SetBounds(260,99,270,21);
FP1.LastChild.Anchors:=[SAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSScreenComboBox).SelectItem:=0;
(FP1.LastChild as TSScreenComboBox).CreateItem('Стратегия "Одеяла"');
(FP1.LastChild as TSScreenComboBox).CreateItem('Стратегия "Дробовика"');

FCB1:=TSScreenComboBox.Create;
FP1.CreateChild(FCB1);
FP1.LastChild.SetBounds(260,69,270,21);
FP1.LastChild.Anchors:=[SAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
FP1.LastChild.Active:=False;
(FP1.LastChild as TSScreenComboBox).SelectItem:=0;
(FP1.LastChild as TSScreenComboBox).CreateItem('Бинарное');

FL8 := SCreateLabel(FP1, 'Функция:', False, 5,5,200,25, [SAnchRight], True, True, Self);
FL9 := SCreateLabel(FP1, 'Отрезок:', False, 5,35,200,25, [SAnchRight], True, True, Self);
FL1 := SCreateLabel(FP1, 'Кодирование хромосом:', False, 5,65,200,25, [SAnchRight], True, True, Self);
FL2 := SCreateLabel(FP1, 'Стратегия задания начальной популяции:', False, 5,95,260,25, [SAnchRight], True, True, Self);
FL3 := SCreateLabel(FP1, 'Вид селекции:', False, 5,125,250,25, [SAnchRight], True, True, Self);
FL4 := SCreateLabel(FP1, 'Опрератор Кроссинговера:', False, 5,155,200,25, [SAnchRight], True, True, Self);
FL5 := SCreateLabel(FP1, 'Операторы мутации и инверсии:', False, 5,185,200,25, [SAnchRight], True, True, Self);
FL6 := SCreateLabel(FP1, 'Оператор отбора:', False, 5,215,200,25, [SAnchRight], True, True, Self);
FL7 := SCreateLabel(FP1, 'Схема Эволюции:', False, 5,245,200,25, [SAnchRight], True, True, Self);
FL8 := SCreateLabel(FP1, 'Размер популяции:', False, 5,275,200,25, [SAnchRight], True, True, Self);
FL9 := SCreateLabel(FP1, 'Число генераций:', False, 5,305,200,25, [SAnchRight], True, True, Self);
FLPoint := SCreateLabel(Screen, '', False, 0,0,0,0, [SAnchRight], False, True, Self);
end;

destructor TSGenAlg.Destroy;
begin
FP1.Destroy;
if FG<>nil then
	FG.Destroy;
FNB.Destroy;
FLPoint.Destroy;
inherited;
end;

class function TSGenAlg.ClassName() : TSString;
begin
Result := 'Простой генетический алгоритм';
end;

initialization
begin
SRegisterDrawClass(TSGenAlg);
end;

end.
