// DEPRECATED EXAMPLE
{$INCLUDE Smooth.inc}
{$IFDEF ENGINE}
	unit Ex5;
	interface
{$ELSE}
	program Example5;
	{$ENDIF}
uses
	{$IF defined(UNIX) and (not defined(ANDROID)) and (not defined(ENGINE))}
		cthreads,
		{$ENDIF}
	 SmoothContextInterface
	,SmoothContextClasses
	,SmoothBase
	,SmoothFont
	,SmoothRenderBase
	,SmoothCommonStructs
	,SmoothDateTime
	,SmoothScreenClasses
	,SmoothCamera
	,SmoothMatrix	
	{$IF not defined(ENGINE)}
		,SmoothConsolePaintableTools
		,SmoothConsoleHandler
		{$ENDIF}
	
	,Crt
	,Ex5_PAPPE
	;
const
	QuantityObjects = 15;
type
	TSExample5=class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
			private
		FCamera           : TSCamera;
		FGravitationAngle : TSSingle;
		
		PhysicsTiks       : TSSingle;
		Physics           : Ex5_PAPPE.TPhysics;
		Collide           : Ex5_PAPPE.TPhysicsCollide;
		
		Object0           : Ex5_PAPPE.TPhysicsObject; // ������� ���
		Object1           : Ex5_PAPPE.TPhysicsObject; // �����
		Object2           : Ex5_PAPPE.TPhysicsObject; // �������
		Object2RigidBody  : Ex5_PAPPE.TPhysicsRigidBody;
		Object1RigidBody  : Ex5_PAPPE.TPhysicsRigidBody;
		Objects           : array[0..QuantityObjects-1] of Ex5_PAPPE.TPhysicsObject;
		ObjectRigidBodies : array[0..QuantityObjects-1] of Ex5_PAPPE.TPhysicsRigidBody;
		
		FPhysicsTime      : array of TSWord;
		FPhysicsTimeCount : TSLongWord;
		FPhysicsTimeIndex : TSLongWord;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSExample5.ClassName():TSString;
begin
Result := '������ ����������� ������ �1';
end;

constructor TSExample5.Create(const VContext : ISContext);
procedure InitCubes();
var
	i,j,r,x,k,y,kk:TSLongWord;
	sx:TSSingle;
begin
sx:=0;
x:=0;
y:=0;
j:=0;
kk:=4;
k:=kk;
r:=0;
for i:=0 to length(Objects)-1 do 
	begin
	Ex5_PAPPE.PhysicsObjectInit         (Objects[i],Ex5_PAPPE.BodyBox);
	Ex5_PAPPE.PhysicsObjectAddMesh      (Objects[i]);
	Ex5_PAPPE.PhysicsObjectMeshCreateBox(Objects[i].Meshs^[0]^,8,8,8);
	Ex5_PAPPE.PhysicsObjectMeshSubdivide(Objects[i].Meshs^[0]^);
	Ex5_PAPPE.PhysicsObjectFinish       (Objects[i]);
	Ex5_PAPPE.PhysicsObjectSetVector    (Objects[i],Ex5_PAPPE.Vector3((-(8.5*kk*0.5))+((x+sx)*8.5),-65+(y*8.5),0));
	Ex5_PAPPE.PhysicsRigidBodyInit      (ObjectRigidBodies[i],@Objects[i],10,0.5,0.8);
	x:=x+1;
	inc(j);
	if j>k then
		begin
		inc(r);
		j:=0;
		if k <> 0 then
			dec(k);
		x:=0;
		y:=y+1;
		sx:=sx+0.5;
		end;
	end;
k:=10;
end;

begin
inherited Create(VContext);
FCamera:=TSCamera.Create();
FCamera.SetContext(Context);
FCamera.Location := TSVector3f.Create(6, 6, -6) * 3.6;

FPhysicsTimeCount:=Context.Width;
SetLength(FPhysicsTime,FPhysicsTimeCount);
FillChar(FPhysicsTime[0],FPhysicsTimeCount*SizeOf(FPhysicsTime[0]),0);
FPhysicsTimeIndex:=0;

Ex5_PAPPE.PhysicsInit(Physics);

Ex5_PAPPE.PhysicsInstance:=@Physics;
Physics.SweepAndPruneWorkMode:=Ex5_PAPPE.sapwmAXISAUTO;
Physics.VelocityMax:=240;
Physics.AngularVelocityMax:=pi*8;
Ex5_PAPPE.PhysicsCollideInit(Collide);

Ex5_PAPPE.PhysicsObjectInit         (Object0,Ex5_PAPPE.BodyBox,Ex5_PAPPE.BodyMesh);
Ex5_PAPPE.PhysicsObjectAddMesh      (Object0);
Ex5_PAPPE.PhysicsObjectMeshCreateBox(Object0.Meshs^[0]^,-140,-140,-140);
Ex5_PAPPE.PhysicsObjectMeshSubdivide(Object0.Meshs^[0]^);
Ex5_PAPPE.PhysicsObjectFinish       (Object0);

Ex5_PAPPE.PhysicsObjectInit            (Object1,Ex5_PAPPE.BodySphere);
Ex5_PAPPE.PhysicsObjectAddMesh         (Object1);
Ex5_PAPPE.PhysicsObjectMeshCreateSphere(Object1.Meshs^[0]^,8,16);
Ex5_PAPPE.PhysicsObjectMeshSubdivide   (Object1.Meshs^[0]^);
Ex5_PAPPE.PhysicsObjectFinish          (Object1);
Ex5_PAPPE.PhysicsObjectSetVector       (Object1,Ex5_PAPPE.Vector3(0,-56,18));
Ex5_PAPPE.PhysicsRigidBodyInit         (Object1RigidBody,@Object1,50,0.5,0.8);

Ex5_PAPPE.PhysicsObjectInit             (Object2,Ex5_PAPPE.BodyCapsule);
Ex5_PAPPE.PhysicsObjectAddMesh          (Object2);
Ex5_PAPPE.PhysicsObjectMeshCreateCapsule(Object2.Meshs^[0]^,4,2.5,24);
Ex5_PAPPE.PhysicsObjectMeshSubdivide    (Object2.Meshs^[0]^);
Ex5_PAPPE.PhysicsObjectFinish           (Object2);
Ex5_PAPPE.PhysicsObjectSetVector        (Object2,Ex5_PAPPE.Vector3(0,-60,-18));
Ex5_PAPPE.PhysicsObjectSetMatrix        (Object2,Ex5_PAPPE.Matrix4x4TermMul(Object2.Transform,Ex5_PAPPE.Matrix4x4RotateX(90*Ex5_PAPPE.DEG2RAD)));
Ex5_PAPPE.PhysicsRigidBodyInit          (Object2RigidBody,@Object2,10,0.5,0.8);

InitCubes();

Physics.Gravitation:=Ex5_PAPPE.Vector3(0,-9.81*4,0);
Ex5_PAPPE.PhysicsStart(Physics);

PhysicsTiks:=0;
FGravitationAngle:=pi;
end;

destructor TSExample5.Destroy();
var
	i:TSLongWord;
begin
Ex5_PAPPE.PhysicsObjectDone   (Object0);
Ex5_PAPPE.PhysicsObjectDone   (Object1);
Ex5_PAPPE.PhysicsRigidBodyDone(Object1RigidBody);
Ex5_PAPPE.PhysicsObjectDone   (Object2);
Ex5_PAPPE.PhysicsRigidBodyDone(Object2RigidBody);
for i:=0 to Length(Objects)-1 do 
	begin
	Ex5_PAPPE.PhysicsObjectDone   (Objects[i]);
	Ex5_PAPPE.PhysicsRigidBodyDone(ObjectRigidBodies[i]);
	end;
Ex5_PAPPE.PhysicsCollideDone(Collide);
Ex5_PAPPE.PhysicsDone       (Physics);
inherited;
end;

procedure TSExample5.Paint();
var
	i,ii      : TSLongWord;
	Licht0Pos : TSVertex3f;
	dt1,dt2   : TSDateTime;

// $RANGECHECK
{$IFOPT R+}
	{$DEFINE RANGECHECKS_OFFED}
	{$R-}
	{$ENDIF}

procedure DrawObjectMesh(var AObjectMesh: TPhysicsObjectMesh); register;
var
	I : integer;
	N: Ex5_PAPPE.TPhysicsVector3;
begin
Render.BeginScene(SR_TRIANGLES);
for I:=0 to AObjectMesh.NumMeshs-1 do
	DrawObjectMesh(AObjectMesh.Meshs^[i]^);
for I:=0 to AObjectMesh.NumTriangles-1 do
	begin
	N:=Ex5_PAPPE.Vector3Norm(Ex5_PAPPE.Vector3Cross(
		Ex5_PAPPE.Vector3Sub(
			AObjectMesh.Triangles^[I].Vertices[1],
			AObjectMesh.Triangles^[I].Vertices[0]),
		Ex5_PAPPE.Vector3Sub(
			AObjectMesh.Triangles^[I].Vertices[2],
			AObjectMesh.Triangles^[I].Vertices[0])));
	Render.Normal3fv(@N);
	Render.Vertex3fv(@AObjectMesh.Triangles^[I].Vertices[0]);
	Render.Vertex3fv(@AObjectMesh.Triangles^[I].Vertices[1]);
	Render.Vertex3fv(@AObjectMesh.Triangles^[I].Vertices[2]);
	end;
Render.EndScene();
end;

{$IFDEF RANGECHECKS_OFFED}
	{$R+}
	{$UNDEFINE RANGECHECKS_OFFED}
	{$ENDIF}

procedure DrawObject(var AObject: TPhysicsObject); register;
var
	I: TSLongWord;
	FNowLightPos : TSVertex3f;
begin
Render.PushMatrix();
Render.MultMatrixf(@AObject.InterpolatedTransform);
FNowLightPos := Licht0Pos * TSMatrix4x4(AObject.InterpolatedTransform);
Render.Lightfv(SR_LIGHT0, SR_POSITION, @FNowLightPos);
for I:=0 to AObject.NumMeshs-1 do
	DrawObjectMesh(AObject.Meshs^[i]^);
Render.PopMatrix();
end;

begin
FGravitationAngle += Context.ElapsedTime/100;
if FGravitationAngle>2*pi then
	FGravitationAngle -= 2*pi;
Physics.Gravitation:=Vector3(
	9.81*9*sin(FGravitationAngle),
	9.81*9*cos(FGravitationAngle),
	9.81*9*sin(FGravitationAngle*3));

// ������ ������
dt1.Get();
PhysicsTiks += Context.ElapsedTime*0.003;
if PhysicsTiks > 0.25 then
	PhysicsTiks := 0.25;
while PhysicsTiks >= Physics.TimeStep do
	begin
	PhysicsTiks -= Physics.TimeStep;
	Ex5_PAPPE.PhysicsStore(Physics);
	Ex5_PAPPE.PhysicsUpdate(Physics,Physics.TimeStep);
	end;
Ex5_PAPPE.PhysicsInterpolate(Physics,PhysicsTiks/Physics.TimeStep);
dt2.Get();

FCamera.InitMatrixAndMove();

Licht0Pos.Import(2,45,160);

Render.Enable (SR_LIGHTING);
Render.Enable (SR_LIGHT0);

Render.Color4f(1,1,1,1);
DrawObject(Object0);

Render.Color4f(0,1,0,1);
for i:=0 to Length(Objects)-1 do
	DrawObject(Objects[i]);

Render.Color4f(0.1,0.5,1,1);
DrawObject(Object1);

Render.Color4f(0.5,0.1,1,1);
DrawObject(Object2);

Render.Disable(SR_LIGHT0);
Render.Disable(SR_LIGHTING);

Render.InitMatrixMode(S_2D);
FPhysicsTime[FPhysicsTimeIndex]:=(dt2-dt1).GetPastMilliseconds();
FPhysicsTimeIndex+=1;
if FPhysicsTimeIndex=FPhysicsTimeCount then
	FPhysicsTimeIndex:=0;
if FPhysicsTimeIndex=0 then
	i:=FPhysicsTimeCount-1
else
	i:=FPhysicsTimeIndex-1;
ii:=10;
Render.Color3f(1,0,0);
Render.BeginScene(SR_LINE_STRIP);
while i<>FPhysicsTimeIndex do
	begin
	Render.Vertex2f(ii/1.5,Render.Height-20*FPhysicsTime[i]-10/1.5);
	if i = 0 then
		i:= FPhysicsTimeCount -1
	else
		i-=1;
	ii+=1;
	end;
Render.EndScene();
Render.Color3f(0,0,0);
Render.BeginScene(SR_LINE_STRIP);
Render.Vertex2f(5/1.5,Render.Height-30-5/1.5);
Render.Vertex2f(5/1.5,Render.Height-5/1.5);
Render.Vertex2f(10/1.5+FPhysicsTimeCount/1.5,Render.Height-5/1.5);
Render.Vertex2f(10/1.5+FPhysicsTimeCount/1.5,Render.Height-30-5/1.5);
Render.EndScene();
Render.Color3f(0,0,0);
(Screen as TSScreenComponent).Skin.Font.DrawFontFromTwoVertex2f('2ms',
	SVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3,Render.Height-50-5/1.5-3),
	SVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3+(Screen as TSScreenComponent).Skin.Font.StringLength('2ms'),Render.Height-50-5/1.5-3+(Screen as TSScreenComponent).Skin.Font.FontHeight));
(Screen as TSScreenComponent).Skin.Font.DrawFontFromTwoVertex2f('0ms',
	SVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3,Render.Height-10-5/1.5-3),
	SVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3+(Screen as TSScreenComponent).Skin.Font.StringLength('0ms'),Render.Height-10-5/1.5-3+(Screen as TSScreenComponent).Skin.Font.FontHeight));
(Screen as TSScreenComponent).Skin.Font.DrawFontFromTwoVertex2f('Physics Time',
	SVertex2fImport(5/1.5,Render.Height-30-5/1.5-10),
	SVertex2fImport(10/1.5+FPhysicsTimeCount/1.5,Render.Height-30-5/1.5+(Screen as TSScreenComponent).Skin.Font.FontHeight-10));
	
end;

{$IFNDEF ENGINE}
	begin
	SConsoleRunPaintable(TSExample5, SSystemParamsToConsoleHandlerParams());
	{$ENDIF}
end.
