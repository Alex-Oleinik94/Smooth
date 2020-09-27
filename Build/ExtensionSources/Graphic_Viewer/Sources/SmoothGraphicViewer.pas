{$INCLUDE Smooth.inc}

unit SmoothGraphicViewer;

interface

uses 
	 SmoothBase
	,SmoothContextClasses
	,SmoothScreenClasses
	,SmoothContextInterface
	,SmoothCommon
	,SmoothCommonStructs
	,SmoothMath
	,SmoothFont
	,SmoothImage
	,SmoothRenderBase
	;

type
	TSGraphic=class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Paint();override;
			public
		function GetFP(const p1,p2:Extended;const st:LongInt):Single;inline;
		function GetMSD(const r:Extended):LongInt;inline;
		procedure Construct(const VB:Boolean = False);
		function GraphicAssigned:Boolean;
		procedure VertexOnScreen(const Vertex:TSVertex2f);inline;
		procedure Messages(const VB123:Boolean = False);
			private
		FArMathGraphic : packed array of 
			TSMathGraphic;
		function Font() : TSFont;
			public
		View : TSScreenVertices;
		Changet : TSBoolean;
		NotUsedInGraphic : TSBoolean;
		Colors: packed array of
			TSColor4f;
			private
		function GetMathGraphic():TSMathGraphic;
		function GetArMathGraphic(Index : TSLongWord):TSMathGraphic;
		procedure SetLengthGraphics(Index : TSLongWord);
		function GetLengthGraphics():TSLongWord;
		procedure SetArMathGraphic(Index : TSLongWord;Gr : TSMathGraphic);
		procedure SetMathGraphic(Gr : TSMathGraphic);
			public
		property MathGraphic : TSMathGraphic read GetMathGraphic write SetMathGraphic;
		property ArMathGraphics [ Index : TSLongWord ] : TSMathGraphic read GetArMathGraphic write SetArMathGraphic;
		property MathGraphics : TSLongWord read GetLengthGraphics write SetLengthGraphics;
		end;
	
	//==============
	//TSGraphViewer
	//==============
	TSGraphViewer=class(TSGraphic)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Paint();override;
			public
		SelectPoint,SelectSecondPoint:TSPoint2int32;
		SelectPointEnabled : TSBoolean;
		Image:TSImage;
		
		FNewFunctionButton : TSScreenButton;
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothFileUtils
	,SmoothMathUtils
	,SmoothBaseUtils
	,SmoothContextUtils
	;

function VertexFunction(Vertex:TSVisibleVector;const p:Pointer):TSVisibleVector;
begin
with TSGraphViewer(p) do
	begin
	Result.Import(
		((Vertex.x-View.x1)/abs(View.x1-View.x2))*Render.Width,
		Render.Height-((Vertex.y-View.y1)/abs(View.y1-View.y2))*Render.Height);
	Result.Visible:=Vertex.Visible;
	end;
end;

procedure TSGraphic.VertexOnScreen(const Vertex:TSVertex2f);
begin
Render.Vertex2f(
		((Vertex.x-View.x1)/abs(View.x1-View.x2))*Render.Width,
		Render.Height-((Vertex.y-View.y1)/abs(View.y1-View.y2))*Render.Height);
end;

function TSGraphic.GraphicAssigned:Boolean;
begin
Result:=(MathGraphic<>nil) and(MathGraphic.Assigned); 
end;

function TSGraphic.GetMathGraphic():TSMathGraphic;
begin
Result:=FArMathGraphic[0];
end;

function TSGraphic.GetArMathGraphic(Index : TSLongWord):TSMathGraphic;
begin
Result:=FArMathGraphic[Index];
end;

procedure TSGraphic.SetLengthGraphics(Index : TSLongWord);
var
	i,ii : TSUInt32;
begin
ii := MathGraphics;
SetLength(FArMathGraphic,Index);
SetLength(Colors,Index);
if ii<MathGraphics then
	for i:=ii to MathGraphics-1 do
		begin
		Colors[i].Import(random,random,random,1);
		FArMathGraphic[i] := TSMathGraphic.Create();
		FArMathGraphic[i].SetContext(Context);
		FArMathGraphic[i].Expression := 'x*sin(x)';
		FArMathGraphic[i].Complexity:= Render.Width;
		FArMathGraphic[i].VertexFunction:=@VertexFunction;
		FArMathGraphic[i].VertexFunctionPointer:=Self;
		end;
end;

function TSGraphic.GetLengthGraphics():TSLongWord;
begin
if FArMathGraphic = nil then
	Result:=0
else
	Result := Length(FArMathGraphic);
end;

procedure TSGraphic.SetArMathGraphic(Index : TSLongWord;Gr : TSMathGraphic);
begin
FArMathGraphic[Index]:=Gr;
end;

procedure TSGraphic.SetMathGraphic(Gr : TSMathGraphic);
begin
FArMathGraphic[0]:=Gr;
end;

constructor TSGraphic.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FArMathGraphic:=nil;
NotUsedInGraphic:=True;

MathGraphics:=1;

View.Import(-15,-15*(Render.Height/Render.Width),15,15*(Render.Height/Render.Width));

Changet:=False;
end;

destructor TSGraphic.Destroy();
var
	i  : TSMaxEnum;
begin
for i:=0 to MathGraphics-1 do
	if ArMathGraphics[i] <> nil then
		ArMathGraphics[i].Destroy;
SetLength(Colors,0);
MathGraphics := 0;
inherited;
end;

class function TSGraphic.ClassName:string;
begin
Result:='Graphic';
end;

function TSGraphic.GetMSD(const r:Extended):LongInt;inline;
begin
Result:=1;
if r > 10 then
	begin
	while (10.0**Result)*2.4 <r do
		Result+=1;
	Result-=1;
	end
else
	begin
	while (10.0**Result)*2.4 > r do
		Result-=1;
	end;
end;

function TSGraphic.GetFP(const p1,p2:Extended;const st:LongInt):Single;inline;
var
	c:Extended;
begin
c:=(10.0**st);
Result:=Trunc(p1 / c)*(c);
if p1>0 then 
	Result+=c;
end;

procedure TSGraphic.Messages(const VB123:Boolean = False);
begin
if (VB123=False) and NotUsedInGraphic then
	NotUsedInGraphic:=False;
case Context.CursorWheel of
SDownCursorWheel:
	begin
	View*=0.9;
	Changet:=True;
	end;
SUpCursorWheel:
	begin
	View*=1.1;
	Changet:=True;
	end;
end;
if Context.CursorKeysPressed(SLeftCursorButton) then
	begin
	View.SumX:= -Context.CursorPosition(SDeferenseCursorPosition).x/Render.Width*abs(View.x1-View.x2);
	View.SumY:= Context.CursorPosition(SDeferenseCursorPosition).y/Render.Height*abs(View.y1-View.y2);
	Changet:=True;
	end;
end;

procedure TSGraphic.Construct(const VB:Boolean = False);
var
	i : TSMaxEnum;
begin
if Changet or VB then
	begin
	if MathGraphics<>0 then
		for i:=0 to MathGraphics-1 do
			if ArMathGraphics[i]<>nil then
				ArMathGraphics[i].Construct(View.x1,View.x2);
	Changet:=False;
	end;
end;

procedure TSGraphic.Paint();
var
	msd:LongInt;
	c,q,q1,q2:TSMathFloat;
	i:LongWord;
	Absx,Absy,k1,k2,k3:TSMathFloat;

function SStTen(const a:Int64):String;
var
	i:longint;
begin
if a=0 then
	Result:='1'
else if a>0 then
	begin
	Result:='1';
	for i:=1 to a do
		Result+='0';
	end
else
	begin
	Result:='0.';
	for i:=-2 downto a do
		Result+='0';
	Result+='1';
	end;
end;

begin
if NotUsedInGraphic then
	Messages(True);
if NotUsedInGraphic then
	Construct(not GraphicAssigned);

Render.InitMatrixMode(S_2D);
Render.BeginScene(SR_LINES);

AbsX:=abs(View.x1-View.x2);
AbsY:=abs(View.y1-View.y2);

msd:=Min(GetMSD(AbsX),GetMSD(AbsY));
k1:=Abs((View.x2/AbsX-1));
k2:=Abs(((View.x2-View.x1)/AbsX-1+View.x2/AbsX));
for i:=0 to 1 do
	begin
	q:=GetFP(View.y1,View.y2,msd-i);
	if i=1 then
		q1:=q;
	c:=(10.0**Real((msd-i)));
	while q < View.y2 do
		begin
		k3:=Abs(1-(q-View.y1)/AbsY-View.y2/AbsY);
		if View.x1<0 then
			begin
			Render.Color4f(
				k3/(k1+k3),
				k1/(k1+k3),
				0,(2-i)/2);
			Render.Vertex2f(0
				,Round(Render.Height-(q-View.y1)/AbsY*Render.Height));
			Render.Color4f(1,0,0,(2-i)/2);
			Render.Vertex2f(Round(Render.Width-View.x2/AbsX*Render.Width)
				,Round(Render.Height-(q-View.y1)/AbsY*Render.Height));
			end;
		if View.x2>0 then
			begin
			Render.Color4f(1,0,0,(2-i)/2);
			Render.Vertex2f(Round(Render.Width-View.x2/AbsX*Render.Width),Round(Render.Height-(q-View.y1)/AbsY*Render.Height));
			Render.Color4f(
				k3/(k2+k3),
				k2/(k2+k3),
				0,(2-i)/2);
			Render.Vertex2f( Render.Width,Round(Render.Height-(q-View.y1)/AbsY*Render.Height));
			end;
		q+=c;
		end;
	end;

k1:=Abs(1-(View.y2-View.y1)/AbsY-View.y2/AbsY);
k2:=Abs(1-View.y2/AbsY);
for i:=0 to 1 do
	begin
	q:=GetFP(View.x1,View.x2,msd-i);
	c:=(10.0**Real((msd-i)));
	if i=1 then
		q2:=q;
	while q < View.x2 do
		begin
		k3:=Abs((q-View.x1)/AbsX-1+View.x2/AbsX);
		if View.y2>0 then
			begin
			Render.Color4f(
				k1/(k1+k3),
				k3/(k1+k3),
				0,(2-i)/2);
			Render.Vertex2f(Round((q-View.x1)/absx*Render.Width),0);
			Render.Color4f(0,1,0,(2-i)/2);
			Render.Vertex2f(Round((q-View.x1)/absx*Render.Width),
				Round(View.y2/absy*Render.Height));
			end;
		if View.y1<0 then
			begin
			Render.Color4f(0,1,0,(2-i)/2);
			Render.Vertex2f(Round((q-View.x1)/AbsX*Render.Width),
				Round(View.y2/AbsY*Render.Height));
			Render.Color4f(k2/(k2+k3),k3/(k2+k3),0,(2-i)/2);
			Render.Vertex2f(Round((q-View.x1)/AbsX*Render.Width),Round(Render.Height));
			end;
		q+=c;
		end;
	end;
c:=(10.0**(msd));

Render.Color4f(0,1,0,1);
Render.Vertex3f(0,			   Round(View.y2/absy*Render.Height),0);
Render.Vertex3f(Render.Width,Round(View.y2/absy*Render.Height),0);
Render.Color4f(1,0,0,1);
Render.Vertex3f(Render.Width-Round(View.x2/absx*Render.Width),0,0);
Render.Vertex3f(Render.Width-Round(View.x2/absx*Render.Width),Render.Height,0);
Render.EndScene();

if MathGraphics<>0 then
	for i:=0 to MathGraphics-1 do
		if ArMathGraphics[i]<>nil then
			begin
			Render.Color(Colors[i]);
			ArMathGraphics[i].Paint();
			end;

if Abs(q1-View.y1)<c*0.2 then
	q1+=c*0.5;
if Abs(q2-View.x1)<c*0.2 then
	q2+=c*0.1;

Render.Color4f(0.5,0.5,1,1);
Render.LineWidth(3);
Render.BeginScene(SR_LINES);
Render.Vertex2f(		((q2-View.x1)/absx)*Render.Width,
				Render.Height-(q1-View.y1)/absy*Render.Height);
Render.Vertex2f(		(q2+c-View.x1)/absx*Render.Width,
				Render.Height-(q1-View.y1)/AbsY*Render.Height);
Render.EndScene();

Font.DrawFontFromTwoVertex2f(SStTen(msd),
	SVertex2fImport(1+(q2-View.x1)/absx*Render.Width,
				Render.Height-(q1-View.y1)/absy*Render.Height),
	SVertex2fImport((q2+c*3-View.x1)/AbsX*Render.Width,
				Font.FontHeight+Render.Height-(q1-View.y1)/AbsY*Render.Height),
				False,False);

q:=GetFP(View.x1,View.x2,msd);
while q < View.x2 do
	begin
	Font.DrawFontFromTwoVertex2f((SStrMathFloat(q, Abs(Min(0,msd)))),
		SVertex2fImport((q-View.x1)/absx*Render.Width+2
			,View.y2/absy*Render.Height),
		SVertex2fImport((q-View.x1)/absx*Render.Width+500
			,View.y2/absy*Render.Height+Font.FontHeight),
		False,False);
	q+=c;
	end;

q:=GetFP(View.y1,View.y2,msd);
while q < View.y2 do
	begin
	Font.DrawFontFromTwoVertex2f((SStrMathFloat(q, Abs(Min(0,msd)))),
		SVertex2fImport(Render.Width-View.x2/AbsX*Render.Width+2
			,Render.Height-(q-View.y1)/Absy*Render.Height),
		SVertex2fImport(Render.Width-View.x2/absx*Render.Width+500
			,Render.Height-(q-View.y1)/absy*Render.Height+Font.FontHeight),
		False,False);
	q+=c;
	end;
end;

function TSGraphic.Font() : TSFont;
begin
Result := (Screen as TSScreenComponent).Skin.Font
end;

//======================================================================================
//======================================================================================
//====================================TSGraphViewer====================================
//======================================================================================
//======================================================================================

procedure TSGraphViewer_FormClose(Button:TSScreenComponent);
begin
TSGraphViewer(Button.FUserPointer1).FNewFunctionButton.Active := True;
Button.ComponentOwner.MarkForDestroy();
end;

procedure GoNewGrafic2(Button:TSScreenComponent);
var
	EulatuonEdit2 : TSScreenEdit = nil;
begin
with TSGraphViewer(Button.FUserPointer1) do
	begin
	EulatuonEdit2 := (Button.ComponentOwner.InternalComponents[1] as TSScreenEdit);
	MathGraphics := MathGraphics + 1;
	ArMathGraphics[MathGraphics - 1].Expression := SStringToPChar(EulatuonEdit2.Caption);
	View.Import(-15,-15*(Render.Height/Render.Width),15,15*(Render.Height/Render.Width));
	MathGraphic.Construct(View.x1,View.x2);
	Changet := True;
	
	FNewFunctionButton.Active := True;
	Button.ComponentOwner.MarkForDestroy();
	end;
end;

procedure mmmComboBoxProcedure1234567(a,b:LongInt;VComboBox:TSScreenComboBox);
begin with TSGraphViewer(VComboBox.FUserPointer1) do begin
	(VComboBox.ComponentOwner.InternalComponents[3] as TSScreenEdit).Active := Boolean(b);
end; end;


procedure GoNewFunction(Button:TSScreenComponent);
var
	Form : TSScreenForm = nil;
begin
with TSGraphViewer(Button.FUserPointer1) do
	begin
	Button.Active := False;
	
	Form := TSScreenForm.Create();
	Screen.CreateInternalComponent(Form);
	Form.SetMiddleBounds(400,133);
	Form.BoundsMakeReal();
	Form.Visible := True;
	Form.Active := True;
	Form.Caption := 'Добавление функции';
	Form.FUserPointer1 := Button.FUserPointer1;
	
	SCreateEdit(Form, 'x*sin(x)', 5,5,380,25, True, True);
	
	Form.CreateInternalComponent(TSScreenComboBox.Create());
	Form.LastInternalComponent.SetBounds(5,35,300,25);
	Form.LastInternalComponent.Visible:=True;
	Form.LastInternalComponent.Active:=True;
	(Form.LastInternalComponent as TSScreenComboBox).CreateItem('Функция');
	(Form.LastInternalComponent as TSScreenComboBox).CreateItem('Производная функции');
	(Form.LastInternalComponent as TSScreenComboBox).SelectItem := 0;
	(Form.LastInternalComponent as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@mmmComboBoxProcedure1234567);
	Form.LastInternalComponent.FUserPointer1 := Button.FUserPointer1;
	
	SCreateEdit(Form, '0', SScreenEditTypeNumber, 310,35,75,25, [], True, True);
	Form.LastInternalComponent.Active:=False;
	
	Form.CreateInternalComponent(TSScreenButton.Create());
	Form.LastInternalComponent.SetBounds(5,65,188,25);
	Form.LastInternalComponent.Visible := True;
	Form.LastInternalComponent.Active  := True;
	Form.LastInternalComponent.Caption := 'Добавить';
	(Form.LastInternalComponent as TSScreenButton).OnChange := TSScreenComponentProcedure(@GoNewGrafic2);
	Form.LastInternalComponent.FUserPointer1 := Button.FUserPointer1;
	
	Form.CreateInternalComponent(TSScreenButton.Create());
	Form.LastInternalComponent.SetBounds(195,65,190,25);
	Form.LastInternalComponent.Visible := True;
	Form.LastInternalComponent.Active  := True;
	Form.LastInternalComponent.Caption := 'Отмена';
	Form.LastInternalComponent.FUserPointer1 := Button.FUserPointer1;
	(Form.LastInternalComponent as TSScreenButton).OnChange := TSScreenComponentProcedure(@TSGraphViewer_FormClose);
	end;
end;

constructor TSGraphViewer.Create(const VContext : ISContext);
begin
inherited Create(VContext);
SelectPointEnabled:=False;
Image := SCreateImageFromFile(Context, STextureDirectory + DirectorySeparator + 'IconArea-hover.png');

FNewFunctionButton:=TSScreenButton.Create;
Screen.CreateInternalComponent(FNewFunctionButton);
Screen.LastInternalComponent.SetBounds(Render.Width-140,Render.Height-28,130,23);
Screen.LastInternalComponent.Visible:=True;
Screen.LastInternalComponent.Caption:='Добавить функцию';
Screen.LastInternalComponent.OnChange:=TSScreenComponentProcedure(@GoNewFunction);
Screen.LastInternalComponent.FUserPointer1:=Self;
end;

destructor TSGraphViewer.Destroy;
begin
SKill(FNewFunctionButton);
SKill(Image);
inherited;
end;


class function TSGraphViewer.ClassName():TSString;
begin
Result:='Graphic Viewer';
end;

procedure TSGraphViewer.Paint();
var
	Changet2 : TSBoolean = False;
begin
inherited;

if Context.CursorKeysPressed(SRightCursorButton)  then
	begin
	SelectPointEnabled:=True;
	SelectPoint:=Context.CursorPosition;
	end;
if SelectPointEnabled then
	begin
	SelectSecondPoint:=Context.CursorPosition;
	if Image.TextureLoaded then
		begin
		Render.Color4f(0,0.5,0.70,0.6);
		Image.DrawImageFromTwoPoint2int32(SelectPoint,SelectSecondPoint,True,S_2D)
		end
	else
		begin
		Render.Color4f(0,0.5,0.70,0.6);
		Render.BeginScene(SR_QUADS);
		Render.Vertex(SelectPoint);
		Render.Vertex2f(SelectPoint.x,SelectSecondPoint.y);
		Render.Vertex(SelectSecondPoint);
		Render.Vertex2f(SelectSecondPoint.x,SelectPoint.y);
		Render.EndScene();
		end;
	end;
if SelectPointEnabled and (Context.CursorKeysPressed(SLeftCursorButton)) then
	begin
	SelectPointEnabled:=False;
	if SelectPoint.x>SelectSecondPoint.x then
		Swap(SelectPoint.x,SelectSecondPoint.x);
	if SelectPoint.y>SelectSecondPoint.y then
		Swap(SelectPoint.y,SelectSecondPoint.y);
	View.Import(
		View.x1+abs(View.x1-View.x2)*SelectPoint.x/Render.Width,
		View.y1+abs(View.y1-View.y2)*(Render.Height-SelectSecondPoint.y)/Render.Height,
		View.x1+abs(View.x1-View.x2)*SelectSecondPoint.x/Render.Width,
		View.y1+abs(View.y1-View.y2)*(Render.Height-SelectPoint.y)/Render.Height);
	Changet2:=True;
	end;

if Changet2 then
	begin
	MathGraphic.Construct(View.x1,View.x2);
	end;

if (Context.KeyPressedChar=#27) and (Context.KeyPressedType=SDownKey) then
	if SelectPointEnabled then 
		SelectPointEnabled:=False;
end;

end.
