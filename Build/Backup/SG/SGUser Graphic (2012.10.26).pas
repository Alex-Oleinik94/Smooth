{$i SaGe.inc}
unit SGUser;
interface
uses 
	crt
	,SaGe
	,SaGeBase
	,GL
	,SaGeCL
	,GLu
	,SaGeMath
	;
var
	MathGraphic:TSGMathGraphic = nil;
	View:TSGScreenVertexes;
	SelectPoint,SelectSecondPoint:SGPoint;
	SelectPointEnabled:Boolean = False;
	Image:TSGGLImage = nil;
	
	EulatuonEdit:TSGEdit = nil;
	EulatuonLabel:TSGLabel = nil;
procedure UserOnBeginProgram;
procedure UserOnActivate;
procedure UserOnPaint;

implementation

procedure UserOnPaint; {DONT RENAME THIS PROCEDURE!!!!}

end;

procedure FromExit;
begin
SGCloseContext;
end;

procedure GoNewGrafic(Button:TSGComponent);
begin
MathGraphic.Expression:=EulatuonEdit.Caption;
View.Import(-5,-5*(ContextWidth/ContextHeight),5,5*(ContextWidth/ContextHeight));
MathGraphic.Construct(View.x1,View.x2);
EulatuonLabel.Caption:=EulatuonEdit.Caption;
EulatuonEdit.Caption:='';
end;

procedure UserOnActivate; {DONT RENAME THIS PROCEDURE!!!!}
begin
Image:=TSGGLImage.Create('Textures'+Slash+'IconArea-hover.png');
Image.Loading;

View.Import(-5,-5*(ContextHeight/ContextWidth),5,5*(ContextHeight/ContextWidth));
MathGraphic.Construct(View.x1,View.x2);

SGScreen.Font:=TSGGLFont.Create('Times New Roman.bmp');
SGScreen.Font.Loading;

SGScreen.CreateChild(TSGButton.Create);
SGScreen.LastChild.SetBounds(ContextWidth-120,40,95,30);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.Caption:='Выход';
SGScreen.LastChild.OnChange:=TSGComponentProcedure(@FromExit);

SGScreen.CreateChild(TSGButton.Create);
SGScreen.LastChild.SetBounds(ContextWidth-135,ContextHeight-50,125,30);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.Caption:='Построить';
SGScreen.LastChild.OnChange:=TSGComponentProcedure(@GoNewGrafic);

EulatuonLabel:=TSGLabel.Create;
SGScreen.CreateChild(EulatuonLabel);
SGScreen.LastChild.SetBounds(10,40,ContextWidth-200,30);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.Caption:='x^2';
EulatuonLabel.TextPosition:=False;
EulatuonLabel.TextColor.Import(1,1,0);

EulatuonEdit:=TSGEdit.Create;
SGScreen.CreateChild(EulatuonEdit);
SGScreen.LastChild.SetBounds(10,ContextHeight-50,ContextWidth-150,30);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.Caption:='';
end;

function VertexFunction(Vertex:TSGVisibleVertex):TSGVisibleVertex;
begin
Result.Import(
	((Vertex.x-View.x1)/abs(View.x1-View.x2))*ContextWidth,
	ContextHeight-((Vertex.y-View.y1)/abs(View.y1-View.y2))*ContextHeight);
Result.Visible:=Vertex.Visible;
end;

procedure UserOnBeginProgram; {DONT RENAME THIS PROCEDURE!!!!}
begin
MathGraphic:=TSGMathGraphic.Create;
MathGraphic.Expression:='x^2';
MathGraphic.Complexity:=10000;
MathGraphic.VertexFunction:=@VertexFunction;
//MathGraphic.UseThread:=True;
end;

end.
