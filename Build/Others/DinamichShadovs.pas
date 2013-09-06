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
type
	TSGShadow=class;
	TSGShodowVertexProcedure=procedure (Param1,Param2,Param3:GLFloat);{$IFDEF MSWINDOWS}stdcall;{$ELSE} cdecl;{$ENDIF}
	TSGShodowProcedure=procedure (glVertex3f:TSGShodowVertexProcedure;ColorsEnabled:Boolean);
	TSGShadow=class
			public
		constructor Create;
		destructor Destroy;override;
			public
		FMatrix:TSGGLMatrix;
		FSun:TSGVertex3f;
		FDrawFloor:TSGShodowProcedure;
		FDrawObjects:TSGShodowProcedure;
			public
		property Sun:TSGVertex read FSun write FSun;
		property Matrix :TSGGLMatrix read FMatrix write FMatrix;
		procedure Draw;
		end;
var
	ShodowPoint:TSGShadow = nil;

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
	
	Shodow:TSGShadow = nil;

procedure UserOnBeginProgram;
procedure UserOnActivate;
procedure UserOnPaint;

implementation

procedure TSGShadowVertex(Param1,Param2,Param3:GLFloat);{$IFDEF MSWINDOWS}stdcall;{$ELSE} cdecl;{$ENDIF}
var
	Normal:TSGVertex3f;
begin
Normal:=ShodowPoint.FSun-SGVertexImport(Param1,Param2,Param3);
Normal.Normalize;
ShodowPoint.Matrix.Add(0,0,Normal.x);
//ShodowPoint.Matrix.Add(1,1,1-Normal.y);
ShodowPoint.Matrix.Add(2,2,Normal.z);
glMultMatrixf(@ShodowPoint.Matrix);
glVertex3f(Param1,Param2,Param3);
end;

procedure TSGShadow.Draw;
begin
ShodowPoint:=Self;

Sun.LightPosition;

glEnable(GL_FOG);
glEnable(GL_DEPTH_TEST);

glPushMatrix;

glDisable (GL_LIGHT0);
glDisable (GL_LIGHTING);

FDrawFloor(glVertex3f,True);

glEnable (GL_LIGHTING); 
glEnable (GL_LIGHT0);
 
glPopMatrix;
glPushMatrix;

FDrawObjects(glVertex3f,True);

glPopMatrix;

glClear(GL_STENCIL_BUFFER_BIT); 
glEnable(GL_STENCIL_TEST);

glPushMatrix;

glColor4f(0, 0, 0, 0.3);
glTranslatef(0, -5, 0);
glMultMatrixf(@Matrix);
glDisable(GL_DEPTH_TEST);
//FDrawObjects(@TSGShadowVertex,False);
FDrawObjects(glVertex3f,False);
glEnable(GL_DEPTH_TEST);
glPopMatrix; 
glDisable(GL_STENCIL_TEST);

glDisable(GL_FOG);
glDisable(GL_DEPTH_TEST);
end;

constructor TSGShadow.Create;
begin
inherited;
FMatrix.Create;
FSun.Import;
FDrawObjects:=nil;
FDrawFloor:=nil;
end;

destructor TSGShadow.Destroy;
begin
inherited;
end;

procedure DrawObjects(glVertex3f:TSGShodowVertexProcedure;ColorsEnabled:Boolean);
begin
if ColorsEnabled then
	glColor3f(1,1,1);
Curve.Init(glVertex3f);
end;

procedure DrawFloor(glVertex3f:TSGShodowVertexProcedure;ColorsEnabled:Boolean);
begin
if ColorsEnabled then
	glColor3f(0.8, 0.8, 1) ;
glBegin(GL_QUADS);
glVertex3f(-5, -5, 5); 
glVertex3f(5, -5, 5); 
glVertex3f(5, -5, -5); 
glVertex3f(-5, -5, -5); 
glEnd();
end;

procedure UserOnPaint; {DONT RENAME THIS PROCEDURE!!!!}
var
	Changet:boolean = False;
begin
if SGKeyPressedChar=' ' then
	Curve.CalculateRandom(400,50,10);

SGInitMatrixMode(SG_3D);
IdentityObject.ChangeAndInit;
glColor3f(1,1,1);
Shodow.Sun.VertexPoint;

Shodow.Draw;

if SGKeyPressedChar='1' then
	Shodow.Sun.y-=0.5;
if SGKeyPressedChar='2' then
	Shodow.Sun.y+=0.5;
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
Shodow:=TSGShadow.Create;
Shodow.Matrix.Create;
Shodow.Matrix.Add(0,0,1);
Shodow.Matrix.Add(1,1,0);
Shodow.Matrix.Add(2,2,1);
Shodow.Matrix.Add(3,3,1);
Shodow.FDrawObjects:=@DrawObjects;
Shodow.FDrawFloor:=@DrawFloor;
Shodow.Sun.Import(0,10,0);

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
