{$MODE OBJFPC}
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
var
	Changet:boolean = False;
begin

SGInitMatrixMode(SG_2D);

glBegin(GL_LINES);

glColor3f(0,1,0);
glVertex3f(0,View.y2/abs(View.y1-View.y2)*ContextHeight,0);
glVertex3f(ContextWidth,View.y2/abs(View.y1-View.y2)*ContextHeight,0);

glColor3f(1,0,0);
glVertex3f(ContextWidth-View.x2/abs(View.x1-View.x2)*ContextWidth,0,0);
glVertex3f(ContextWidth-View.x2/abs(View.x1-View.x2)*ContextWidth,ContextHeight,0);

glEnd;

glColor3f(1,1,1);
MathGraphic.Draw;

if SGIsMouseKeyDown(2)  then
	begin
	SelectPointEnabled:=True;
	SelectPoint:=SGGetCursorPositionForWindows;
	end;
if SelectPointEnabled then
	begin
	SelectSecondPoint:=SGGetCursorPositionForWindows;
	if Image.ReadyTexture then
		begin
		glColor4f(0,0.5,0.70,0.6);
		Image.DrawImageFromTwoPoint2f(SelectPoint,SelectSecondPoint,True,SG_2D)
		end
	else
		begin
		glColor4f(0,0.5,0.70,0.6);
		glBegin(GL_QUADS);
		SelectPoint.Vertex;
		glVertex2f(SelectPoint.x,SelectSecondPoint.y);
		SelectSecondPoint.Vertex;
		glVertex2f(SelectSecondPoint.x,SelectPoint.y);
		glEnd();
		end;
	end;
if SelectPointEnabled and (SGIsMouseKeyDown(1)) then
	begin
	SelectPointEnabled:=False;
	if SelectPoint.x>SelectSecondPoint.x then
		SGQuickRePlaceLongInt(SelectPoint.x,SelectSecondPoint.x);
	if SelectPoint.y>SelectSecondPoint.y then
		SGQuickRePlaceLongInt(SelectPoint.y,SelectSecondPoint.y);
	View.Import(
		View.x1+abs(View.x1-View.x2)*SelectPoint.x/ContextWidth,
		View.y1+abs(View.y1-View.y2)*(ContextHeight-SelectSecondPoint.y)/ContextHeight,
		View.x1+abs(View.x1-View.x2)*SelectSecondPoint.x/ContextWidth,
		View.y1+abs(View.y1-View.y2)*(ContextHeight-SelectPoint.y)/ContextHeight);
	Changet:=True;
	end;

if crt.keypressed and (crt.readkey=#13) then
	begin
	readln;
	MathGraphic.Expression:=SGPCharRead;
	View.Import(-5,-5*(ContextWidth/ContextHeight),5,5*(ContextWidth/ContextHeight));
	Changet:=True;
	end;

case SGMouseWheel of
-1:
	begin
	View*=0.9;
	Changet:=True;
	end;
1:
	begin
	View*=1.1;
	Changet:=True;
	end;
end;

if SGIsMouseKeyDown(1) then
	begin
	View.SumX:= -SGGetMousePosition(0).x/ContextWidth*abs(View.x1-View.x2);
	View.SumY:= SGGetMousePosition(0).y/ContextHeight*abs(View.y1-View.y2);
	Changet:=True;
	end;
if SaGe.SGContextResized then
   Changet:=True;
if Changet then
	begin
	MathGraphic.Construct(View.x1,View.x2);
	end;

if SGKeyPressedChar=#27 then
	if SelectPointEnabled then 
		SelectPointEnabled:=False;
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
