{$INCLUDE Smooth.inc}

unit Ex5_Physics;

interface

uses 
	 SysUtils
	,Classes
	
	,SmoothBase
	,SmoothVertexObject
	,SmoothContextInterface
	,SmoothContextClasses
	,SmoothCommonStructs
	,SmoothRenderBase
	,SmoothImage
	,SmoothMatrix
	
	,Ex5_PAPPE
	;
const
	SPBodySphere  = Ex5_PAPPE.BodySphere;
	SPBodyBox     = Ex5_PAPPE.BodyBox;
	SPBodyCapsule = Ex5_PAPPE.BodyCapsule;
	SPBodyMesh    = Ex5_PAPPE.BodyMesh;
	SPBodyHeightMap = Ex5_PAPPE.BodyHeightMap;
type
	TSPhysics=class;
	
	PSPhysicsObject = ^ TSPhysicsObject;
	TSPhysicsObject=class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
			private
		FDynamic : TSBoolean;
		FObject : Ex5_PAPPE.TPhysicsObject;
		FRigidBody : Ex5_PAPPE.TPhysicsRigidBody;
		F3dObject : TS3DObject;
		FType : TSLongWord;
		FPhysicsClass : TSPhysics;
			public
		procedure InitBox ( const x,y,z : TSSingle );inline;
		procedure InitCapsule ( const x,y : TSSingle; const z: TSLongInt );inline;
		procedure InitSphere ( const x : TSSingle; const y : TSLongInt );inline;
		procedure InitMesh (const Mesh : TS3DObject);
		procedure InitHeightMapFromImage(const VFileName : TSString;const mt,md,llx,lly : TSSingle);
		procedure SetDrawableMesh(const Mesh : TS3DObject);
		procedure SetVertex( const x,y,z : TSFloat32 );inline;overload;
		procedure SetVertex( const v : TSVertex3f );inline;overload;
		procedure RotateX(const rx : TSFloat32 );inline;overload;
		procedure AddObjectEnd(const x : TSSingle = 10; const y :TSSingle = 0.5; const z : TSSingle = 0.8);inline;
		function GetMatrix():TSPointer;inline;
			public
		property Object3d : TS3dObject read F3dObject write F3dObject;
		property PhysicsObject : Ex5_PAPPE.TPhysicsObject read FObject;
		property PhysicsClass  : TSPhysics           read FPhysicsClass  write FPhysicsClass;
		end;
	
	TSPhysics=class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
		procedure Update();virtual;
			private
		FObjects : packed array of TSPhysicsObject;
		FPhysics : Ex5_PAPPE.TPhysics;
		FCollide : Ex5_PAPPE.TPhysicsCollide;
		FPhysicsTiks : TSSingle;
		FLigths  : packed array of 
			packed record
			FLocation : TSVertex3f;
			FNumber   : TSLongWord;
			end;
		FDrawable : TSBoolean;
			private
		function GetGravitation():TSVertex3f;inline;
		function GetObjectCount():TSLongWord;inline;
		function GetObject(const Index : TSLongWord):TSPhysicsObject;inline;
			public
		procedure AddObjectBegin(const VType : TSLongWord; const VDynamic: TSBoolean);
		function LastObject():TSPhysicsObject;inline;
		procedure Start();inline;
		procedure AddLigth(const VNumber : TSLongWord;const VLocation : TSVertex3f);inline;
		procedure SetGravitation(const v:TSVertex3f;const EraseFrozen : TSBoolean = False);inline;
			public
		property VelocityMax        : TSSingle   read FPhysics.VelocityMax        write FPhysics.VelocityMax;
		property AngularVelocityMax : TSSingle   read FPhysics.AngularVelocityMax write FPhysics.AngularVelocityMax;
		property Gravitation        : TSVertex3f read GetGravitation;
		property Drawable           : TSBoolean  read FDrawable                   write FDrawable;
		property Objects[Index : TSLongWord]:TSPhysicsObject read GetObject;
		property ObjectsCount       : TSLongWord read GetObjectCount;
		end;

implementation

uses
	 SmoothCommon
	,SmoothLog
	;

function TSPhysics.GetObjectCount():TSLongWord;inline;
begin
if FObjects<>nil then
	Result:=Length(FObjects)
else
	Result:=0;
end;

function TSPhysics.GetObject(const Index : TSLongWord):TSPhysicsObject;inline;
begin
Result:=FObjects[Index];
end;

procedure TSPhysics.AddLigth(const VNumber : TSLongWord;const VLocation : TSVertex3f);inline;
begin
if FLigths=nil then
	SetLength(FLigths,1)
else
	SetLength(FLigths,Length(FLigths)+1);
FLigths[High(FLigths)].FNumber   := VNumber;
FLigths[High(FLigths)].FLocation := VLocation;
end;

procedure TSPhysics.SetGravitation(const v:TSVertex3f;const EraseFrozen : TSBoolean = False);inline;
var
	i:TSLongWord;
begin
FPhysics.Gravitation:=Ex5_PAPPE.TPhysicsVector3(v*4);
if (FObjects<>nil) and EraseFrozen then
	for i:=0 to High(FObjects) do
		if FObjects[i].FDynamic then
			begin
			FObjects[i].FRigidBody.Frozen:=False;
			FObjects[i].FRigidBody.FrozenTime:=0;
			end;
end;

function TSPhysics.GetGravitation():TSVertex3f;inline;
begin
Result:=TSVertex3f(FPhysics.Gravitation)*0.25;
end;

procedure TSPhysics.Start();inline;
begin
Ex5_PAPPE.PhysicsInstance:=@FPhysics;
Ex5_PAPPE.PhysicsStart(FPhysics);
end;

function TSPhysics.LastObject():TSPhysicsObject;inline;
begin
if FObjects=nil then
	Result:=nil
else
	Result:=FObjects[High(FObjects)];
end;

procedure TSPhysics.AddObjectBegin(const VType : TSLongWord; const VDynamic: TSBoolean);
begin
Ex5_PAPPE.PhysicsInstance:=@FPhysics;
if FObjects=nil then
	SetLength(FObjects,1)
else
	SetLength(FObjects,Length(FObjects)+1);
FObjects[High(FObjects)]:=TSPhysicsObject.Create(Context);
FObjects[High(FObjects)].FDynamic := VDynamic;
FObjects[High(FObjects)].FType := VType;
FObjects[High(FObjects)].PhysicsClass:=Self;
if VDynamic or (VType=SPBodyHeightMap) then
	Ex5_PAPPE.PhysicsObjectInit(FObjects[High(FObjects)].FObject,VType)
else
	Ex5_PAPPE.PhysicsObjectInit(FObjects[High(FObjects)].FObject,VType,Ex5_PAPPE.BodyMesh);
end;

constructor TSPhysics.Create(const VContext : ISContext);
begin
inherited;
FLigths:=nil;
FObjects:=nil;
Ex5_PAPPE.PhysicsInit(FPhysics);
Ex5_PAPPE.PhysicsInstance:=@FPhysics;
FPhysics.SweepAndPruneWorkMode:=Ex5_PAPPE.sapwmAXISAUTO;
FPhysics.VelocityMax:=240;
FPhysics.AngularVelocityMax:=pi*8;
Ex5_PAPPE.PhysicsCollideInit(FCollide);
FPhysicsTiks:=0;
FDrawable:=True;
end;

destructor TSPhysics.Destroy();
var
	i : TSLongWord;
begin
Ex5_PAPPE.PhysicsInstance:=@FPhysics;
if FObjects<>nil then
	begin
	for i:=0 to High(FObjects) do
		begin
		FObjects[i].Destroy();
		end;
	end;
Ex5_PAPPE.PhysicsCollideDone(FCollide);
Ex5_PAPPE.PhysicsDone       (FPhysics);
inherited;
end;

procedure TSPhysics.Update();
begin
Ex5_PAPPE.PhysicsInstance:=@FPhysics;

FPhysicsTiks += Context.ElapsedTime*0.003;
if FPhysicsTiks > 0.25 then
	FPhysicsTiks := 0.25;
while FPhysicsTiks >= FPhysics.TimeStep do
	begin
	FPhysicsTiks -= FPhysics.TimeStep;
	Ex5_PAPPE.PhysicsStore(FPhysics);
	Ex5_PAPPE.PhysicsUpdate(FPhysics,FPhysics.TimeStep);
	end;
Ex5_PAPPE.PhysicsInterpolate(FPhysics,FPhysicsTiks/FPhysics.TimeStep);
end;

procedure TSPhysics.Paint();
var
	II : TSLongWord;
var
	I : TSLongWord;
	LigthPos : TSVertex3f;
begin
if FDrawable then
	begin
	if FLigths<>nil then
		begin
		Render.Enable(SR_LIGHTING);
		for i:=0 to High(FLigths) do
			Render.Enable(FLigths[i].FNumber);
		end;
	
	if FObjects<>nil then
		begin
		for i:=0 to High(FObjects) do
			begin
			Render.PushMatrix();
			Render.MultMatrixf(@FObjects[i].PhysicsObject.InterpolatedTransform);
			if FLigths<>nil then
				for ii:=0 to High(FLigths) do
					begin
					LigthPos := FLigths[ii].FLocation * TSMatrix4x4(FObjects[i].PhysicsObject.InterpolatedTransform);
					Render.Lightfv(FLigths[ii].FNumber, SR_POSITION, @LigthPos);
					end;
			FObjects[i].Paint();
			Render.PopMatrix();
			end;
		end;
	
	if FLigths<>nil then
		begin
		Render.Disable(SR_LIGHTING);
		for i:=0 to High(FLigths) do
			Render.Disable(FLigths[i].FNumber);
		end;
	end;
end;

class function TSPhysics.ClassName():TSString;
begin
Result:='TSPhysics';

end;

(* ======================TSPhysicsObject====================== *)

constructor TSPhysicsObject.Create(const VContext : ISContext);
begin
inherited Create(VContext);
F3dObject:=nil;
Fillchar(FObject,SizeOf(FObject),0);
Fillchar(FRigidBody,SizeOf(FRigidBody),0);
FDynamic:=False;
FType:=0;
end;

destructor TSPhysicsObject.Destroy();
begin
if F3dObject<>nil then
	F3dObject.Destroy();
if FType<>0 then
	begin
	Ex5_PAPPE.PhysicsObjectDone(FObject);
	if FDynamic then
		Ex5_PAPPE.PhysicsRigidBodyDone(FRigidBody);
	end;
inherited;
end;

procedure TSPhysicsObject.Paint();
begin
if F3dObject<>nil then
	begin
	F3dObject.Paint();
	end;
end;

procedure TSPhysicsObject.AddObjectEnd(const x : TSSingle = 10; const y :TSSingle = 0.5; const z : TSSingle = 0.8);inline;
var
	i,ii : TSLongWord;
procedure Calculate(var AObjectMesh: TPhysicsObjectMesh);
var
	j:TSLongWord;
begin
if AObjectMesh.NumMeshs<>0 then
	for j:=0 to AObjectMesh.NumMeshs-1 do
		begin
		Calculate(AObjectMesh.Meshs^[j]^);
		end;
ii+=AObjectMesh.NumTriangles;
end;

// $RANGECHECK
{$IFOPT R+}
	{$DEFINE RANGECHECKS_OFFED}
	{$R-}
	{$ENDIF}

procedure AddingTriangles(var AObjectMesh: TPhysicsObjectMesh);
var
	i:LongWord;
begin
if AObjectMesh.NumMeshs<>0 then
	for I:=0 to AObjectMesh.NumMeshs-1 do
		AddingTriangles(AObjectMesh.Meshs^[i]^);
if AObjectMesh.NumTriangles<>0 then
	for i:=0 to AObjectMesh.NumTriangles -1 do 
		begin
		F3dObject.ArNormal[ii*3+0]^:=TSVertex3f(Ex5_PAPPE.Vector3Norm(Ex5_PAPPE.Vector3Cross(
			Ex5_PAPPE.Vector3Sub(
				AObjectMesh.Triangles^[I].Vertices[1],
				AObjectMesh.Triangles^[I].Vertices[0]),
			Ex5_PAPPE.Vector3Sub(
				AObjectMesh.Triangles^[I].Vertices[2],
				AObjectMesh.Triangles^[I].Vertices[0]))));
		F3dObject.ArNormal[ii*3+1]^:=F3dObject.ArNormal[ii*3+0]^;
		F3dObject.ArNormal[ii*3+2]^:=F3dObject.ArNormal[ii*3+0]^;
		F3dObject.ArVertex3f[ii*3+0]^:=TSVertex3f(AObjectMesh.Triangles^[I].Vertices[0]);
		F3dObject.ArVertex3f[ii*3+1]^:=TSVertex3f(AObjectMesh.Triangles^[I].Vertices[1]);
		F3dObject.ArVertex3f[ii*3+2]^:=TSVertex3f(AObjectMesh.Triangles^[I].Vertices[2]);
		ii+=1;
		end;
end;

{$IFDEF RANGECHECKS_OFFED}
	{$R+}
	{$UNDEFINE RANGECHECKS_OFFED}
	{$ENDIF}

begin
if FDynamic then
	Ex5_PAPPE.PhysicsRigidBodyInit(FRigidBody,@FObject,x,y,z);
if (FPhysicsClass<>nil) and FPhysicsClass.Drawable then
	begin
	F3dObject := TS3DObject.Create();
	F3dObject.Context := Context;
	F3dObject.QuantityFaceArrays := 0;
	F3dObject.HasColors := False;
	F3dObject.ObjectPoligonesType:=SR_TRIANGLES;
	F3dObject.ObjectColor:=SColor4fFromUInt32($FFFFFF);
	F3dObject.EnableCullFace:=False;
	F3dObject.HasNormals:=True;
	ii:=0;
	if FObject.NumMeshs<>0 then
		for i:=0 to FObject.NumMeshs-1 do
			Calculate(FObject.Meshs^[i]^);
	F3dObject.SetVertexLength(ii*3);
	ii:=0;
	if FObject.NumMeshs<>0 then
		for i:=0 to FObject.NumMeshs-1 do
			AddingTriangles(FObject.Meshs^[i]^);
	if Render.SupportedGraphicalBuffers() then
		F3dObject.LoadToVBO();
	end;
end;

procedure TSPhysicsObject.RotateX(const rx : TSFloat32 );inline;overload;
begin
Ex5_PAPPE.PhysicsObjectSetMatrix(FObject,Ex5_PAPPE.Matrix4x4TermMul(FObject.Transform,Ex5_PAPPE.Matrix4x4RotateX(rx*Ex5_PAPPE.DEG2RAD)));
end;

procedure TSPhysicsObject.SetVertex( const x,y,z : TSFloat32 );inline;overload;
begin
Ex5_PAPPE.PhysicsObjectSetVector(FObject,Ex5_PAPPE.Vector3(x,y,z));
end;

procedure TSPhysicsObject.SetVertex( const v : TSVertex3f );inline;overload;
begin
Ex5_PAPPE.PhysicsObjectSetVector(FObject,Ex5_PAPPE.Vector3(v.x,v.y,v.z));
end;

procedure TSPhysicsObject.InitBox ( const x,y,z : TSSingle );inline;
begin
Ex5_PAPPE.PhysicsObjectAddMesh          (FObject);
Ex5_PAPPE.PhysicsObjectMeshCreateBox    (FObject.Meshs^[0]^,x,y,z);
Ex5_PAPPE.PhysicsObjectMeshSubdivide    (FObject.Meshs^[0]^);
Ex5_PAPPE.PhysicsObjectFinish           (FObject);
end;

procedure TSPhysicsObject.InitHeightMapFromImage(const VFileName : TSString;const mt,md,llx,lly : TSSingle);
var
	Image : TSImage = nil;
	i, ii, iii : TSMaxEnum;
	HMD : packed array of TSFloat32 = nil;
begin
Image := TSImage.Create();
Image .Context  := Context;
Image .FileName := VFileName;
if Image.Load() then
	begin
	Ex5_PAPPE.PhysicsObjectAddMesh(FObject);
	SetLength(HMD,Image.Width * Image.Height);
	for i := 0 to Image.Width * Image.Height - 1 do
		begin
		iii :=0;
		for ii := 0 to Image.BitMap.Channels - 1 do
			iii += Image.BitMap.Data[i * Image.BitMap.Channels + ii];
		HMD[i] := md + (iii/(Image.BitMap.Channels*255))*Abs(mt-md);
		end;
	Ex5_PAPPE.PhysicsObjectSetHeightMap(FObject,@HMD[0],Image.Width,Image.Height,llx,lly);
	Ex5_PAPPE.PhysicsObjectFinish(FObject);
	SetLength(HMD,0);
	end
else
	SLog.Source(['TSPhysicsObject__InitHeightMapFromImage(..). Error while open image file "', VFileName, '".']);
Image.Destroy();
end;

procedure TSPhysicsObject.InitCapsule ( const x,y : TSSingle; const z: TSLongInt );inline;
begin
Ex5_PAPPE.PhysicsObjectAddMesh          (FObject);
Ex5_PAPPE.PhysicsObjectMeshCreateCapsule(FObject.Meshs^[0]^,x,y,z);
Ex5_PAPPE.PhysicsObjectMeshSubdivide    (FObject.Meshs^[0]^);
Ex5_PAPPE.PhysicsObjectFinish           (FObject);
end;

procedure TSPhysicsObject.InitSphere ( const x : TSSingle; const y : TSLongInt );inline;
begin
Ex5_PAPPE.PhysicsObjectAddMesh          (FObject);
Ex5_PAPPE.PhysicsObjectMeshCreateSphere (FObject.Meshs^[0]^,x,y);
Ex5_PAPPE.PhysicsObjectMeshSubdivide    (FObject.Meshs^[0]^);
Ex5_PAPPE.PhysicsObjectFinish           (FObject);
end;

procedure TSPhysicsObject.InitMesh (const Mesh : TS3DObject);
var
	i, ii, iii: TSLongWord;
begin
ii:=Ex5_PAPPE.PhysicsObjectAddMesh(FObject);
if Mesh.QuantityFaceArrays<>0 then
	begin
	for iii:=0 to F3dObject.QuantityFaceArrays-1 do
		if Mesh.Faces[iii]<>0 then
			for i:=0 to Mesh.Faces[iii]-1 do
				Ex5_PAPPE.PhysicsObjectMeshAddTriangle(FObject.Meshs^[ii]^,
					TPhysicsVector3(Mesh.ArVertex3f[Mesh.ArFacesTriangles(iii,i).p[0]]^),
					TPhysicsVector3(Mesh.ArVertex3f[Mesh.ArFacesTriangles(iii,i).p[1]]^),
					TPhysicsVector3(Mesh.ArVertex3f[Mesh.ArFacesTriangles(iii,i).p[2]]^));
	end
else
	begin
	if Mesh.QuantityVertices<>0 then
		for i:=0 to Mesh.QuantityVertices-1 do
			if ((i+1) mod 3 = 0) then
				Ex5_PAPPE.PhysicsObjectMeshAddTriangle(FObject.Meshs^[ii]^,
					TPhysicsVector3(Mesh.ArVertex3f[i+0]^),
					TPhysicsVector3(Mesh.ArVertex3f[i+1]^),
					TPhysicsVector3(Mesh.ArVertex3f[i+2]^));
	end;
Ex5_PAPPE.PhysicsObjectMeshSubdivide    (FObject.Meshs^[ii]^);
Ex5_PAPPE.PhysicsObjectFinish           (FObject);
end;

function TSPhysicsObject.GetMatrix():TSPointer;inline;
begin
Result:=@FObject.InterpolatedTransform;
end;

procedure TSPhysicsObject.SetDrawableMesh(const Mesh : TS3DObject);
begin
if (F3dObject<>nil) and (F3dObject<>Mesh) then
	F3dObject.Destroy();
F3dObject:=Mesh;
end;

end.
