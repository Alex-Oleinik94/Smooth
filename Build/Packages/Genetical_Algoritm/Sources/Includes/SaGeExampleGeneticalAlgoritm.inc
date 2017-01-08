
{$IFDEF SGREADINTERFACE}
type
	TSGGenAlg=class(TSGScreenedDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Paint();override;
			public
		FLMM,FL1,FL2,FL3,FL4,FL5,FL6,FL7,FL8,FL9,FXL,FLPoint:TSGLabel;
		FP1:TSGPanel;
		FB1:TSGButton;
		FE1,FE2,FE22,FE3,FE4:TSGEdit;
		FS1:TSGEdit;
		FCB1,FCBMM,FCB2,FCB4,FCB5,FCB3,FCB6,FCB7:TSGComboBox;
		FNB:TSGButton;
			public
		FG:TSGGraphic;
		FGA:TSGGA;
			public
		FFindPoint,a,b:TSGGAValueType;
		FResultFP:Extended;
		end;
{$ENDIF}


{$IFDEF SGREADIMPLEMENTATION}
procedure GA1MyNumberFucntion(const Self:TSGComponent);
var
	MyClass:TSGGenAlg;
begin
MyClass:=TSGGenAlg(Self.FUserPointer1);
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
		(SGVal((FE2.Caption))<=SGVal((FE22.Caption)));
	if FE2.TextComplite and 
		FE22.TextComplite and 
		(not(SGVal((FE2.Caption))<=SGVal((FE22.Caption)))) then
		begin
		FE2.TextComplite:=False;
		FE22.TextComplite:=False;
		end;
	end;
end;

procedure mmmFCB3OnChange(const Self:TSGComboBox);
begin
with TSGGenAlg(Self.FUserPointer1) do
if Self.SelectItem=1 then
	begin
	FL3.Caption:='�������������� �����, ��� ��������:';
	//Self.SetBounds(260+103,129,167,21);
	Self.Left:=260+103;
	Self.Width:=167;
	//FS1.SetBounds(260,129,99,21);
	FS1.Width:=99;
	FS1.Visible:=true;
	end
else
	begin
	FL3.Caption:='��� ��������:';
	//FS1.SetBounds(260,129,0,21);
	//Self.SetBounds(260,129,270,21);
	FS1.Width:=0;
	Self.Left:=260;
	Self.Width:=270;
	FS1.Visible:=False;
	end;
GA1MyNumberFucntion(Self);
end;

function MyTTFE(const s:TSGEdit):boolean;
var
	Ex:TSGExpression = nil;
begin
Result:=S.Caption='';//nil);
if not Result then
	begin
	Ex:=TSGExpression.Create;
	Ex.Expression:=SGStringToPChar(S.Caption);
	Ex.CanculateExpression();
	if (Ex.ErrorsQuantity=0) and (Length(Ex.Variables)<=1) then
		begin
		Ex.BeginCalculate;
		Ex.ChangeVariables(Ex.Variable,TSGExpressionChunkCreateReal(0));
		Ex.Calculate;
		end
	else
		if Length(Ex.Variables)<>1 then
			TSGGenAlg(S.FUserPointer1).FXl.Caption:=SGStringToPChar('f(?)=');
	if Length(Ex.Variables)=1 then
		TSGGenAlg(S.FUserPointer1).FXl.Caption:=SGStringToPChar('f('+SGPCharToString(Ex.Variable)+')=');
	Result:=(Ex.ErrorsQuantity=0) and (Length(Ex.Variables)<=1);
	Ex.Destroy;
	TSGGenAlg(S.FUserPointer1).FXl.Width:=TSGGenAlg(S.FUserPointer1).FXl.Skin.Font.StringLength(TSGGenAlg(S.FUserPointer1).FXl.Caption);
	TSGGenAlg(S.FUserPointer1).FXl.Left:=258-TSGGenAlg(S.FUserPointer1).FXl.Skin.Font.StringLength(TSGGenAlg(S.FUserPointer1).FXl.Caption);
	end
else
	begin
	Result:=False;
	TSGGenAlg(S.FUserPointer1).FXl.Caption:=SGStringToPChar('f(?)=');
	end;
end;

function Func123Haha(const x:TSGGAValueType;const Ex2:TSGExpression):TSGGAValueType;
begin
Ex2.BeginCalculate;
Ex2.ClearErrors;
Ex2.ChangeVariables(Ex2.Variable,TSGExpressionChunkCreateReal(x));
Ex2.Calculate;
if (Ex2.Resultat.Quantity>0) and (SGRealExists(Ex2.Resultat.FConst)) and (Ex2.ErrorsQuantity=0) then
	Result:=Ex2.Resultat.FConst
else
	Result:=Nan;
end;


procedure New1234543454354(Button:TSGComponent);
begin
with TSGGenAlg(Button.FUserPointer1) do
	begin
	FP1.Visible:=True;
	Button.Visible:=False;
	FS1.Visible:=FCB3.SelectItem=1;
	end;
end;

procedure GAFindMin(Button:TSGComponent);
var
	Min,Max:Extended;
	Ex:TSGExpression = nil;
begin
Button.Parent.Visible:=False;
with TSGGenAlg(Button.FUserPointer1) do
	begin
	a:=SGVal((FE2.Caption));
	b:=SGVal((FE22.Caption));
	
	Ex:=TSGExpression.Create;
	Ex.Expression:=SGStringToPChar((FE1.Caption));
	Ex.CanculateExpression;
	
	FGA:=TSGGA.Create;
	FGA.Interval.a:=a;
	FGA.Interval.b:=b;
	FGA.WhatFind:=Boolean(FCBMM.SelectItem);
	FGA.FQuantityPopulation:=SGVal((FE3.Caption));
	FGA.FQuantityIteration:=SGVal((FE4.Caption));
	FGA.FFunction:=TSGGAFunction(@Func123Haha);
	FGA.FunctionPointer:=Ex;
	FGA.Selection1Param:=SGVal((FS1.Caption));
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
	FG:=TSGGraphic.Create(Context);
	FG.MathGraphic.Expression:=SGStringToPChar(FE1.Caption);
	Max:=FResultFP+Abs(b-a)/2;
	Min:=FResultFP-Abs(b-a)/2;
	FG.View.Import(
		a-Abs(b-a)/2*(1/(Render.Height/Render.Width)),
		Min-Abs(b-a)/2,
		b+Abs(b-a)/2*(1/(Render.Height/Render.Width)),
		Max+Abs(b-a)/2);
	FG.Construct(True);
	
	FLPoint.Caption:=SGStringToPChar('('+SGStrReal(FFindPoint,5)+','+SGStrReal(FResultFP,5)+')');
	FNB.Visible:=True;
	FLPoint.SetBounds(
		Render.Width-5-FLPoint.Skin.Font.StringLength(FLPoint.Caption),
		Render.Height-25,
		FLPoint.Skin.Font.StringLength(FLPoint.Caption),
		21);
	FLPoint.Visible:=True;
	FLPoint.BoundsToNeedBounds;
	end;
end;

procedure TSGGenAlg.Paint();
var
	AbsX:Extended;
begin
if FG<>nil then
	begin
	FG.Messages;
	FG.Construct;
	
	Render.InitMatrixMode(SG_2D);
	Render.Color4f(0.3,0.3,1,0.5);
	Render.BeginScene(SGR_QUADS);
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
	Render.InitMatrixMode(SG_2D);
	Render.LineWidth(3);
	Render.BeginScene(SGR_LINES);
	Render.Color4f(1,1,0,1);
	FG.VertexOnScreen(SGVertex2fImport(FFindPoint,0));
	FG.VertexOnScreen(SGVertex2fImport(FFindPoint,FResultFP));
	FG.VertexOnScreen(SGVertex2fImport(0,FResultFP));
	FG.VertexOnScreen(SGVertex2fImport(FFindPoint,FResultFP));
	Render.EndScene();
	Render.LineWidth(1);
	Render.PointSize(5);
	Render.BeginScene(SGR_POINTS);
	Render.Color4f(1,0,0.5,1);
	FG.VertexOnScreen(SGVertex2fImport(FFindPoint,0));
	FG.VertexOnScreen(SGVertex2fImport(FFindPoint,FResultFP));
	FG.VertexOnScreen(SGVertex2fImport(0,FResultFP));
	Render.EndScene();
	Render.PointSize(1);
	end;
end;

constructor TSGGenAlg.Create(const VContext : ISGContext);
const
	QQQ=35;
begin
inherited Create(VContext);
FG:=nil;
a:=0;
b:=0;

FNB:=TSGButton.Create;
Screen.CreateChild(FNB);
Screen.LastChild.SetBounds(Render.Width-90,1 ,80,15);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Caption:='������';
Screen.LastChild.FUserPointer1:=Self;
FNB.OnChange:=TSGComponentProcedure(@New1234543454354);

FP1:=TSGPanel.Create;
Screen.CreateChild(FP1);
Screen.LastChild.SetMiddleBounds(550,378);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;

FP1.CreateChild(TSGLabel.Create);
FP1.LastChild.SetBounds(265,38,8,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='[';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGLabel).TextPosition:=False;

FP1.CreateChild(TSGLabel.Create);
FP1.LastChild.SetBounds(513,38,8,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:=']';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGLabel).TextPosition:=False;

FP1.CreateChild(TSGLabel.Create);
FP1.LastChild.SetBounds(390,38,8,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:=',';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGLabel).TextPosition:=False;

FE2:=TSGEdit.Create;
FP1.CreateChild(FE2);
FE2.OnChange:=TSGComponentProcedure(@GA1MyNumberFucntion);
FE2.TextType:=SGEditTypeInteger;
FP1.LastChild.SetBounds(275,39,110,21);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='3';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;

FE22:=TSGEdit.Create;
FP1.CreateChild(FE22);
FE22.OnChange:=TSGComponentProcedure(@GA1MyNumberFucntion);
FE22.TextType:=SGEditTypeInteger;
FP1.LastChild.SetBounds(400,39,110,21);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='7';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;

FLMM:=TSGLabel.Create;
FP1.CreateChild(FLMM);
FP1.LastChild.SetBounds(QQQ+280,338,80,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='�������.';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGLabel).TextPosition:=False;

FCBMM:=TSGComboBox.Create;
FP1.CreateChild(FCBMM);
FP1.LastChild.SetBounds(QQQ+205,338 ,70,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGComboBox).SelectItem:=0;
(FP1.LastChild as TSGComboBox).CreateItem('�������');
(FP1.LastChild as TSGComboBox).CreateItem('��������');

FB1:=TSGButton.Create;
FP1.CreateChild(FB1);
FP1.LastChild.SetBounds(QQQ+150,338 ,50,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='�����';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
FB1.OnChange:=TSGComponentProcedure(@GAFindMin);

FE4:=TSGEdit.Create;
FP1.CreateChild(FE4);
FP1.LastChild.SetBounds(260,309,270,21);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='10';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
FE4.OnChange:=TSGComponentProcedure(@GA1MyNumberFucntion);
FE4.TextType:=SGEditTypeNumber;

FE3:=TSGEdit.Create;
FP1.CreateChild(FE3);
FP1.LastChild.SetBounds(260,279,270,21);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='10';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
FE3.OnChange:=TSGComponentProcedure(@GA1MyNumberFucntion);
FE3.TextType:=SGEditTypeNumber;

FXL:=TSGLabel.Create;
FP1.CreateChild(FXl);
FP1.LastChild.SetBounds(260-20-5-5,9,28,21);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='f(x)=';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGLabel).TextPosition:=False;

FE1:=TSGEdit.Create;
FP1.CreateChild(FE1);
FP1.LastChild.SetBounds(260,9,270,21);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
FE1.TextType:=SGEditTypeUser;
FE1.OnChange:=TSGComponentProcedure(@GA1MyNumberFucntion);
FE1.TextTypeFunction:=TSGEditTextTypeFunction(@MyTTFE);
FP1.LastChild.Caption:='x^2-5*x+6';

FCB7:=TSGComboBox.Create;
FP1.CreateChild(FCB7);
FP1.LastChild.SetBounds(260,249,270,21);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
FP1.LastChild.Active:=False;
(FP1.LastChild as TSGComboBox).SelectItem:=0;
(FP1.LastChild as TSGComboBox).CreateItem('�������������');

FCB6:=TSGComboBox.Create;
FP1.CreateChild(FCB6);
FP1.LastChild.SetBounds(260,219,270,21);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
FP1.LastChild.Active:=False;
(FP1.LastChild as TSGComboBox).SelectItem:=0;
(FP1.LastChild as TSGComboBox).CreateItem('�������');

FCB5:=TSGComboBox.Create;
FP1.CreateChild(FCB5);
FP1.LastChild.SetBounds(260,189,270,21);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGComboBox).SelectItem:=0;
(FP1.LastChild as TSGComboBox).CreateItem('�������');
(FP1.LastChild as TSGComboBox).CreateItem('�������������');

FCB4:=TSGComboBox.Create;
FP1.CreateChild(FCB4);
FP1.LastChild.SetBounds(260,159,270,21);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGComboBox).SelectItem:=0;
(FP1.LastChild as TSGComboBox).CreateItem('����������� ������������');
(FP1.LastChild as TSGComboBox).CreateItem('�������� ��������������� ������������');
(FP1.LastChild as TSGComboBox).CreateItem('��������������� ������������');
(FP1.LastChild as TSGComboBox).CreateItem('H� ������ ��������� ��������');

FS1:=TSGEdit.Create;
FP1.CreateChild(FS1);
FS1.OnChange:=TSGComponentProcedure(@GA1MyNumberFucntion);
FS1.TextType:=SGEditTypeInteger;
FS1.TextComplite:=False;
FP1.LastChild.SetBounds(260,129,270,21);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=False;

FCB3:=TSGComboBox.Create;
FP1.CreateChild(FCB3);
FCB3.OnChange:=TSGComponentProcedure(@mmmFCB3OnChange);
FP1.LastChild.SetBounds(260,129,270,21);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGComboBox).SelectItem:=0;
(FP1.LastChild as TSGComboBox).CreateItem('���������');
(FP1.LastChild as TSGComboBox).CreateItem('�������� �� �������� �����');
(FP1.LastChild as TSGComboBox).CreateItem('����������');

FCB2:=TSGComboBox.Create;
FP1.CreateChild(FCB2);
FP1.LastChild.SetBounds(260,99,270,21);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGComboBox).SelectItem:=0;
(FP1.LastChild as TSGComboBox).CreateItem('��������� "������"');
(FP1.LastChild as TSGComboBox).CreateItem('��������� "���������"');

FCB1:=TSGComboBox.Create;
FP1.CreateChild(FCB1);
FP1.LastChild.SetBounds(260,69,270,21);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
FP1.LastChild.Active:=False;
(FP1.LastChild as TSGComboBox).SelectItem:=0;
(FP1.LastChild as TSGComboBox).CreateItem('��������');

FL8:=TSGLabel.Create;
FP1.CreateChild(FL8);
FP1.LastChild.SetBounds(5,5,200,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='�������:';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGLabel).TextPosition:=False;

FL9:=TSGLabel.Create;
FP1.CreateChild(FL9);
FP1.LastChild.SetBounds(5,35,200,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='�������:';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGLabel).TextPosition:=False;

FL1:=TSGLabel.Create;
FP1.CreateChild(FL1);
FP1.LastChild.SetBounds(5,65,200,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='����������� ��������:';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGLabel).TextPosition:=False;

FL2:=TSGLabel.Create;
FP1.CreateChild(FL2);
FP1.LastChild.SetBounds(5,95,260,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='��������� ������� ��������� ���������:';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGLabel).TextPosition:=False;

FL3:=TSGLabel.Create;
FP1.CreateChild(FL3);
FP1.LastChild.SetBounds(5,125,250,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='��� ��������:';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGLabel).TextPosition:=False;

FL4:=TSGLabel.Create;
FP1.CreateChild(FL4);
FP1.LastChild.SetBounds(5,155,200,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='��������� �������������:';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGLabel).TextPosition:=False;

FL5:=TSGLabel.Create;
FP1.CreateChild(FL5);
FP1.LastChild.SetBounds(5,185,200,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='��������� ������� � ��������:';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGLabel).TextPosition:=False;

FL6:=TSGLabel.Create;
FP1.CreateChild(FL6);
FP1.LastChild.SetBounds(5,215,200,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='�������� ������:';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGLabel).TextPosition:=False;

FL7:=TSGLabel.Create;
FP1.CreateChild(FL7);
FP1.LastChild.SetBounds(5,245,200,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='����� ��������:';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGLabel).TextPosition:=False;

FL8:=TSGLabel.Create;
FP1.CreateChild(FL8);
FP1.LastChild.SetBounds(5,275,200,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='������ ���������:';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGLabel).TextPosition:=False;

FL9:=TSGLabel.Create;
FP1.CreateChild(FL9);
FP1.LastChild.SetBounds(5,305,200,25);
FP1.LastChild.Anchors:=[SGAnchRight];
FP1.LastChild.Caption:='����� ���������:';
FP1.LastChild.FUserPointer1:=Self;
FP1.LastChild.Visible:=True;
(FP1.LastChild as TSGLabel).TextPosition:=False;

FLPoint:=TSGLabel.Create;
Screen.CreateChild(FLPoint);
Screen.LastChild.SetBounds(0,0,0,0);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Caption:='';
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=False;
(Screen.LastChild as TSGLabel).TextPosition:=False;

end;

destructor TSGGenAlg.Destroy;
begin
FP1.Destroy;
if FG<>nil then
	FG.Destroy;
FNB.Destroy;
FLPoint.Destroy;
inherited;
end;

class function TSGGenAlg.ClassName:string;
begin
Result:='������� ������������ ��������';
end;

{$ENDIF}

