{$INCLUDE SaGe.inc}
program Example1;
uses
	{$IFDEF UNIX}
		{$IFNDEF ANDROID}
			cthreads,
			{$ENDIF}
		{$ENDIF}
	SaGeContext
	,SaGeBased
	,SaGeBase
	,SaGeBaseExample
	,SaGeUtils
	,SaGeRender
	,PAPPE
	;
const
	QuantityObjects = 16;
type
	TSGExample5=class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			private
		FCamera           : TSGCamera;
		FGravitationAngle : TSGSingle;
		
		PhysicsTiks       : TSGSingle;
		Physics           : PAPPE.TPhysics;
		Collide           : PAPPE.TPhysicsCollide;
		
		Object0           : PAPPE.TPhysicsObject; // ������� ���
		Object1           : PAPPE.TPhysicsObject; // �����
		Object2           : PAPPE.TPhysicsObject; // �������
		Object2RigidBody  : PAPPE.TPhysicsRigidBody;
		Object1RigidBody  : PAPPE.TPhysicsRigidBody;
		Objects           : array[0..QuantityObjects-1] of PAPPE.TPhysicsObject;
		ObjectRigidBodies : array[0..QuantityObjects-1] of PAPPE.TPhysicsRigidBody;
		end;

class function TSGExample5.ClassName():TSGString;
begin
Result := '������ ����������� ������';
end;

constructor TSGExample5.Create(const VContext : TSGContext);
const
	cwChop : word = $F7B;
procedure InitCubes();
var
	i,j,r,x,k,y,kk:TSGLongWord;
	sx:TSGSingle;
begin
sx:=0;
x:=0;
y:=0;
j:=0;
kk:=9;
k:=kk;
r:=0;
for i:=0 to length(Objects)-1 do 
	begin
	PAPPE.PhysicsObjectInit         (Objects[i],PAPPE.BodyBox);
	PAPPE.PhysicsObjectAddMesh      (Objects[i]);
	PAPPE.PhysicsObjectMeshCreateBox(Objects[i].Meshs^[0]^,8,8,8);
	PAPPE.PhysicsObjectMeshSubdivide(Objects[i].Meshs^[0]^);
	PAPPE.PhysicsObjectFinish       (Objects[i]);
	PAPPE.PhysicsObjectSetVector    (Objects[i],PAPPE.Vector3((-(8.5*kk*0.5))+((x+sx)*8.5),-65+(y*8.5),0));
	PAPPE.PhysicsRigidBodyInit      (ObjectRigidBodies[i],@Objects[i],10,0.5,0.8);
	x:=x+1;
	inc(j);
	if j>k then
		begin
		inc(r);
		j:=0;
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
asm
FLDCW cwChop 
end;
FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
FCamera.FZum := 6;
FCamera.FRotateX := 90;

PAPPE.PhysicsInit(Physics);

PhysicsInstance:=@Physics;
Physics.SweepAndPruneWorkMode:=PAPPE.sapwmAXISAUTO;
Physics.VelocityMax:=240;
Physics.AngularVelocityMax:=pi*8;
PAPPE.PhysicsCollideInit(Collide);

PAPPE.PhysicsObjectInit         (Object0,PAPPE.BodyBox,PAPPE.BodyMesh);
PAPPE.PhysicsObjectAddMesh      (Object0);
PAPPE.PhysicsObjectMeshCreateBox(Object0.Meshs^[0]^,-140,-140,-140);
PAPPE.PhysicsObjectMeshSubdivide(Object0.Meshs^[0]^);
PAPPE.PhysicsObjectFinish       (Object0);

PAPPE.PhysicsObjectInit            (Object1,PAPPE.BodySphere);
PAPPE.PhysicsObjectAddMesh         (Object1);
PAPPE.PhysicsObjectMeshCreateSphere(Object1.Meshs^[0]^,8,16);
PAPPE.PhysicsObjectMeshSubdivide   (Object1.Meshs^[0]^);
PAPPE.PhysicsObjectFinish          (Object1);
PAPPE.PhysicsObjectSetVector       (Object1,PAPPE.Vector3(0,-56,18));
PAPPE.PhysicsRigidBodyInit         (Object1RigidBody,@Object1,50,0.5,0.8);

PAPPE.PhysicsObjectInit             (Object2,PAPPE.BodyCapsule);
PAPPE.PhysicsObjectAddMesh          (Object2);
PAPPE.PhysicsObjectMeshCreateCapsule(Object2.Meshs^[0]^,4,2.5,24);
PAPPE.PhysicsObjectMeshSubdivide    (Object2.Meshs^[0]^);
PAPPE.PhysicsObjectFinish           (Object2);
PAPPE.PhysicsObjectSetVector        (Object2,PAPPE.Vector3(0,-60,-18));
PAPPE.PhysicsObjectSetMatrix        (Object2,PAPPE.Matrix4x4TermMul(Object2.Transform,PAPPE.Matrix4x4RotateX(90*PAPPE.DEG2RAD)));
PAPPE.PhysicsRigidBodyInit          (Object2RigidBody,@Object2,10,0.5,0.8);

InitCubes();

Physics.Gravitation:=PAPPE.Vector3(0,-9.81*4,0);
PhysicsStart(Physics);

PhysicsTiks:=0;
FGravitationAngle:=pi;
end;

destructor TSGExample5.Destroy();
var
	i:TSGLongWord;
begin
PAPPE.PhysicsObjectDone   (Object0);
PAPPE.PhysicsObjectDone   (Object1);
PAPPE.PhysicsRigidBodyDone(Object1RigidBody);
PAPPE.PhysicsObjectDone   (Object2);
PAPPE.PhysicsRigidBodyDone(Object2RigidBody);
for i:=0 to Length(Objects)-1 do 
	begin
	PAPPE.PhysicsObjectDone   (Objects[i]);
	PAPPE.PhysicsRigidBodyDone(ObjectRigidBodies[i]);
	end;
PAPPE.PhysicsCollideDone(Collide);
PAPPE.PhysicsDone       (Physics);
inherited;
end;

procedure TSGExample5.Draw();
var
	i         : TSGLongWord;
	Licht0Pos : array[0..3] of TSGSingle = (0,160,160,1);

procedure DrawObjectMesh(var AObjectMesh: TPhysicsObjectMesh); register;
var
	I: integer;
	N: PAPPE.TPhysicsVector3;
begin
Render.BeginScene(SGR_TRIANGLES);
for I:=0 to AObjectMesh.NumMeshs-1 do
	DrawObjectMesh(AObjectMesh.Meshs^[i]^);
for I:=0 to AObjectMesh.NumTriangles-1 do
	begin
	N:=PAPPE.Vector3Norm(PAPPE.Vector3Cross(
		PAPPE.Vector3Sub(
			AObjectMesh.Triangles^[I].Vertices[1],
			AObjectMesh.Triangles^[I].Vertices[0]),
		PAPPE.Vector3Sub(
			AObjectMesh.Triangles^[I].Vertices[2],
			AObjectMesh.Triangles^[I].Vertices[0])));
	Render.Normal3fv(@N);
	Render.Vertex3fv(@AObjectMesh.Triangles^[I].Vertices[0]);
	Render.Vertex3fv(@AObjectMesh.Triangles^[I].Vertices[1]);
	Render.Vertex3fv(@AObjectMesh.Triangles^[I].Vertices[2]);
	end;
Render.EndScene();
end;

procedure DrawObject(var AObject: TPhysicsObject); register;
var
	I: TSGLongWord;
begin
Render.PushMatrix();
Render.MultMatrixf(@AObject.InterpolatedTransform);
for I:=0 to AObject.NumMeshs-1 do
	DrawObjectMesh(AObject.Meshs^[i]^);
Render.PopMatrix();
end;

begin
FGravitationAngle += Context.ElapsedTime;
if FGravitationAngle>2*pi then
	FGravitationAngle -= 2*pi;
Physics.Gravitation:=Vector3(
	9.81*9*sin(FGravitationAngle),
	9.81*9*cos(FGravitationAngle),
	9.81*9*sin(FGravitationAngle*3));

// ������ ������
PhysicsTiks += Context.ElapsedTime*0.003;
if PhysicsTiks > 0.25 then
	PhysicsTiks := 0.25;
while PhysicsTiks >= Physics.TimeStep do
	begin
	PhysicsTiks -= Physics.TimeStep;
	PAPPE.PhysicsStore(Physics);
	PAPPE.PhysicsUpdate(Physics,Physics.TimeStep);
	end;
PAPPE.PhysicsInterpolate(Physics,PhysicsTiks/Physics.TimeStep);

FCamera.CallAction();

Render.Enable (SGR_LIGHTING);
Render.Enable (SGR_LIGHT0);
Render.Lightfv(SGR_LIGHT0, SGR_POSITION, @Licht0Pos);

Render.Color4f(1,1,1,1);
DrawObject(Object0);

Render.Color4f(0,1,0,1);
for i:=0 to Length(Objects)-1 do
	DrawObject(Objects[i]);

Render.Color4f(0.1,0.5,1,1);
DrawObject(Object1);

Render.Color4f(0.5,0.1,1,1);
DrawObject(Object2);

Render.Disable(SGR_LIGHT0);
Render.Disable(SGR_LIGHTING);
end;

begin
ExampleClass := TSGExample5;
RunApplication();
end.
