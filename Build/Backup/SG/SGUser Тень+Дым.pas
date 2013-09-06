{$MODE OBJFPC}
unit SGUser;
interface
uses 
	crt
	,SaGe
	,GL
	,SaGeCL
	,GLu
	,SaGeMath
	;
var
	Curve:TSGBezierCurve;
	IdentityObject:SGIdentityObject;
var
	MathGraphic:TSGMathGraphic = nil;
	View:TSGScreenVertexes;
	SelectPoint,SelectSecondPoint:SGPoint;
	SelectPointEnabled:Boolean = False;
	Image:TSGGLImage = nil;
	
	fogColor:SGColor4f = (r:0;g:0;b:0;a:1);
	
	Matrix:TSGGLMatrix;

procedure UserOnBeginProgram;
procedure UserOnActivate;
procedure UserOnPaint;

implementation

procedure UserOnPaint; {DONT RENAME THIS PROCEDURE!!!!}
var
	Changet:boolean = False;
begin
if SGKeyPressedChar=' ' then
	Curve.CalculateRandom(400,50,10);

SGInitMatrixMode(SG_3D);
IdentityObject.ChangeAndInit;


glEnable(GL_FOG);
glEnable(GL_DEPTH_TEST);

glPushMatrix;

glDisable (GL_LIGHT0);
glDisable (GL_LIGHTING);

glColor3f(0.8, 0.8, 1) ;
glBegin(GL_QUADS);
glVertex3f(-5, -5, 5); 
glVertex3f(5, -5, 5); 
glVertex3f(5, -5, -5); 
glVertex3f(-5, -5, -5); 
glEnd();

glEnable (GL_LIGHTING); 
glEnable (GL_LIGHT0);
 
glPopMatrix;
glPushMatrix;

glColor3f(1,1,1);
Curve.Init;

glPopMatrix;

glClear(GL_STENCIL_BUFFER_BIT); 
glEnable(GL_STENCIL_TEST);

glPushMatrix;

glColor4f(0, 0, 0, 0.3);
glTranslatef(0, -5, 0);
glMultMatrixf(@Matrix);
glDisable(GL_DEPTH_TEST);
Curve.Init;
glEnable(GL_DEPTH_TEST);
glPopMatrix; 
glDisable(GL_STENCIL_TEST);

glDisable(GL_FOG);
glDisable(GL_DEPTH_TEST);
{
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
}
end;

procedure FromExit;
begin
SGCloseContext;
end;

procedure UserOnActivate; {DONT RENAME THIS PROCEDURE!!!!}
begin
IdentityObject.Clear;
Curve.CalculateRandom(400,50,10);

glEnable(GL_FOG);
glFogi(GL_FOG_MODE, GL_LINEAR);
glHint (GL_FOG_HINT, GL_NICEST);
//glHint(GL_FOG_HINT, GL_DONT_CARE);
glFogf (GL_FOG_START, 0.2);
glFogf (GL_FOG_END, 30.0);
glFogfv(GL_FOG_COLOR, @fogColor);
glFogf(GL_FOG_DENSITY, 0.55);

glClearStencil(0);
glStencilOp(GL_INCR, GL_INCR, GL_INCR);
glStencilFunc(GL_EQUAL, 0, $FFFFFFF);

Matrix.Create;
Matrix.Add(0,0,1);
Matrix.Add(1,1,0);
Matrix.Add(2,2,1);
Matrix.Add(3,3,1);

glDepthFunc(GL_LESS); 
glEnable(GL_DEPTH_TEST);

Image:=TSGGLImage.Create('bg3.bmp');
Image.LoadIt;

View.Import(-5,-5*(ContextHeight/ContextWidth),5,5*(ContextHeight/ContextWidth));
MathGraphic.Construct(View.x1,View.x2);

SGScreen.Font:=TSGGLFont.Create('Times New Roman.bmp');
SGScreen.Font.LoadIt;

SGScreen.CreateChild(TSGButton.Create);
SGScreen.LastChild.SetBounds(ContextWidth-120,40,95,40);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.Caption:='Button(EXIT)';
SGScreen.LastChild.OnChange:=TSGComponentProcedure(@FromExit);
//SGScreen.LastChild.Align:=SGAlignRight;

SGScreen.CreateChild(TSGLabel.Create);
SGScreen.LastChild.SetBounds(120,40,90,40);
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.Caption:='Label';
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
MathGraphic.Expression:=SGPCharRead;
MathGraphic.Complexity:=10000;
MathGraphic.VertexFunction:=@VertexFunction;
//MathGraphic.UseThread:=True;
end;

end.
