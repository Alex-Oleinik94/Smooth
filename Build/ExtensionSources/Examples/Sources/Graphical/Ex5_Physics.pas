{$INCLUDE SaGe.inc}

unit Ex5_Physics;

interface

uses 
	 SysUtils
	,Classes
	
	,SaGeBase
	,SaGeVertexObject
	,SaGeContextInterface
	,SaGeContextClasses
	,SaGeCommonStructs
	,SaGeRenderBase
	,SaGeImage
	,SaGeMatrix
	
	,Ex5_PAPPE
	;
const
	SGPBodySphere  = Ex5_PAPPE.BodySphere;
	SGPBodyBox     = Ex5_PAPPE.BodyBox;
	SGPBodyCapsule = Ex5_PAPPE.BodyCapsule;
	SGPBodyMesh    = Ex5_PAPPE.BodyMesh;
	SGPBodyHeightMap = Ex5_PAPPE.BodyHeightMap;
type
	TSGPhysics=class;
	
	PSGPhysicsObject = ^ TSGPhysicsObject;
	TSGPhysicsObject=class(TSGPaintableObject)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
			private
		FDynamic : TSGBoolean;
		FObject : Ex5_PAPPE.TPhysicsObject;
		FRigidBody : Ex5_PAPPE.TPhysicsRigidBody;
		FMesh : TSG3DObject;
		FType : TSGLongWord;
		FPhysicsClass : TSGPhysics;
			public
		procedure InitBox ( const x,y,z : TSGSingle );inline;
		procedure InitCapsule ( const x,y : TSGSingle; const z: TSGLongInt );inline;
		procedure InitSphere ( const x : TSGSingle; const y : TSGLongInt );inline;
		procedure InitMesh (const Mesh : TSG3DObject);
		procedure InitHeightMapFromImage(const VFileName : TSGString;const mt,md,llx,lly : TSGSingle);
		procedure SetDrawableMesh(const Mesh : TSG3DObject);
		procedure SetVertex( const x,y,z : TSGFloat32 );inline;overload;
		procedure SetVertex( const v : TSGVertex3f );inline;overload;
		procedure RotateX(const rx : TSGFloat32 );inline;overload;
		procedure AddObjectEnd(const x : TSGSingle = 10; const y :TSGSingle = 0.5; const z : TSGSingle = 0.8);inline;
		function GetMatrix():TSGPointer;inline;
			public
		property Mesh : TSG3DObject read FMesh write FMesh;
		property PhysicsObject : Ex5_PAPPE.TPhysicsObject read FObject;
		property PhysicsClass  : TSGPhysics           read FPhysicsClass  write FPhysicsClass;
		end;
	
	TSGPhysics=class(TSGPaintableObject)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
		procedure Update();virtual;
			private
		FObjects : packed array of TSGPhysicsObject;
		FPhysics : Ex5_PAPPE.TPhysics;
		FCollide : Ex5_PAPPE.TPhysicsCollide;
		FPhysicsTiks : TSGSingle;
		FLigths  : packed array of 
			packed record
			FLocation : TSGVertex3f;
			FNumber   : TSGLongWord;
			end;
		FDrawable : TSGBoolean;
			private
		function GetGravitation():TSGVertex3f;inline;
		function GetObjectCount():TSGLongWord;inline;
		function GetObject(const Index : TSGLongWord):TSGPhysicsObject;inline;
			public
		procedure AddObjectBegin(const VType : TSGLongWord; const VDynamic: TSGBoolean);
		function LastObject():TSGPhysicsObject;inline;
		procedure Start();inline;
		procedure AddLigth(const VNumber : TSGLongWord;const VLocation : TSGVertex3f);inline;
		procedure SetGravitation(const v:TSGVertex3f;const EraseFrozen : TSGBoolean = False);inline;
			public
		property VelocityMax        : TSGSingle   read FPhysics.VelocityMax        write FPhysics.VelocityMax;
		property AngularVelocityMax : TSGSingle   read FPhysics.AngularVelocityMax write FPhysics.AngularVelocityMax;
		property Gravitation        : TSGVertex3f read GetGravitation;
		property Drawable           : TSGBoolean  read FDrawable                   write FDrawable;
		property Objects[Index : TSGLongWord]:TSGPhysicsObject read GetObject;
		property ObjectsCount       : TSGLongWord read GetObjectCount;
		end;

implementation

uses
	 SaGeCommon
	,SaGeLog
	;

function TSGPhysics.GetObjectCount():TSGLongWord;inline;
begin
if FObjects<>nil then
	Result:=Length(FObjects)
else
	Result:=0;
end;

function TSGPhysics.GetObject(const Index : TSGLongWord):TSGPhysicsObject;inline;
begin
Result:=FObjects[Index];
end;

procedure TSGPhysics.AddLigth(const VNumber : TSGLongWord;const VLocation : TSGVertex3f);inline;
begin
if FLigths=nil then
	SetLength(FLigths,1)
else
	SetLength(FLigths,Length(FLigths)+1);
FLigths[High(FLigths)].FNumber   := VNumber;
FLigths[High(FLigths)].FLocation := VLocation;
end;

procedure TSGPhysics.SetGravitation(const v:TSGVertex3f;const EraseFrozen : TSGBoolean = False);inline;
var
	i:TSGLongWord;
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

function TSGPhysics.GetGravitation():TSGVertex3f;inline;
begin
Result:=TSGVertex3f(FPhysics.Gravitation)*0.25;
end;

procedure TSGPhysics.Start();inline;
begin
Ex5_PAPPE.PhysicsInstance:=@FPhysics;
Ex5_PAPPE.PhysicsStart(FPhysics);
end;

function TSGPhysics.LastObject():TSGPhysicsObject;inline;
begin
if FObjects=nil then
	Result:=nil
else
	Result:=FObjects[High(FObjects)];
end;

procedure TSGPhysics.AddObjectBegin(const VType : TSGLongWord; const VDynamic: TSGBoolean);
begin
Ex5_PAPPE.PhysicsInstance:=@FPhysics;
if FObjects=nil then
	SetLength(FObjects,1)
else
	SetLength(FObjects,Length(FObjects)+1);
FObjects[High(FObjects)]:=TSGPhysicsObject.Create(Context);
FObjects[High(FObjects)].FDynamic := VDynamic;
FObjects[High(FObjects)].FType := VType;
FObjects[High(FObjects)].PhysicsClass:=Self;
if VDynamic or (VType=SGPBodyHeightMap) then
	Ex5_PAPPE.PhysicsObjectInit(FObjects[High(FObjects)].FObject,VType)
else
	Ex5_PAPPE.PhysicsObjectInit(FObjects[High(FObjects)].FObject,VType,Ex5_PAPPE.BodyMesh);
end;

constructor TSGPhysics.Create(const VContext : ISGContext);
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

destructor TSGPhysics.Destroy();
var
	i : TSGLongWord;
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

procedure TSGPhysics.Update();
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

procedure TSGPhysics.Paint();
var
	II : TSGLongWord;
var
	I : TSGLongWord;
	LigthPos : TSGVertex3f;
begin
if FDrawable then
	begin
	if FLigths<>nil then
		begin
		Render.Enable(SGR_LIGHTING);
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
					LigthPos := FLigths[ii].FLocation * TSGMatrix4x4(FObjects[i].PhysicsObject.InterpolatedTransform);
					Render.Lightfv(FLigths[ii].FNumber, SGR_POSITION, @LigthPos);
					end;
			FObjects[i].Paint();
			Render.PopMatrix();
			end;
		end;
	
	if FLigths<>nil then
		begin
		Render.Disable(SGR_LIGHTING);
		for i:=0 to High(FLigths) do
			Render.Disable(FLigths[i].FNumber);
		end;
	end;
end;

class function TSGPhysics.ClassName():TSGString;
begin
Result:='TSGPhysics';

end;

(* ======================TSGPhysicsObject====================== *)

constructor TSGPhysicsObject.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FMesh:=nil;
Fillchar(FObject,SizeOf(FObject),0);
Fillchar(FRigidBody,SizeOf(FRigidBody),0);
FDynamic:=False;
FType:=0;
end;

destructor TSGPhysicsObject.Destroy();
begin
if FMesh<>nil then
	FMesh.Destroy();
if FType<>0 then
	begin
	Ex5_PAPPE.PhysicsObjectDone(FObject);
	if FDynamic then
		Ex5_PAPPE.PhysicsRigidBodyDone(FRigidBody);
	end;
inherited;
end;

procedure TSGPhysicsObject.Paint();
begin
if FMesh<>nil then
	begin
	FMesh.Paint();
	end;
end;

procedure TSGPhysicsObject.AddObjectEnd(const x : TSGSingle = 10; const y :TSGSingle = 0.5; const z : TSGSingle = 0.8);inline;
var
	i,ii : TSGLongWord;
procedure Calculate(var AObjectMesh: TPhysicsObjectMesh);
var
	j:TSGLongWord;
begin
if AObjectMesh.NumMeshs<>0 then
	for j:=0 to AObjectMesh.NumMeshs-1 do
		begin
		Calculate(AObjectMesh.Meshs^[j]^);
		end;
ii+=AObjectMesh.NumTriangles;
end;

// $RANGECHECKS
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
		FMesh.ArNormal[ii*3+0]^:=TSGVertex3f(Ex5_PAPPE.Vector3Norm(Ex5_PAPPE.Vector3Cross(
			Ex5_PAPPE.Vector3Sub(
				AObjectMesh.Triangles^[I].Vertices[1],
				AObjectMesh.Triangles^[I].Vertices[0]),
			Ex5_PAPPE.Vector3Sub(
				AObjectMesh.Triangles^[I].Vertices[2],
				AObjectMesh.Triangles^[I].Vertices[0]))));
		FMesh.ArNormal[ii*3+1]^:=FMesh.ArNormal[ii*3+0]^;
		FMesh.ArNormal[ii*3+2]^:=FMesh.ArNormal[ii*3+0]^;
		FMesh.ArVertex3f[ii*3+0]^:=TSGVertex3f(AObjectMesh.Triangles^[I].Vertices[0]);
		FMesh.ArVertex3f[ii*3+1]^:=TSGVertex3f(AObjectMesh.Triangles^[I].Vertices[1]);
		FMesh.ArVertex3f[ii*3+2]^:=TSGVertex3f(AObjectMesh.Triangles^[I].Vertices[2]);
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
	FMesh := TSG3DObject.Create();
	FMesh.Context := Context;
	FMesh.QuantityFaceArrays := 0;
	FMesh.HasColors := False;
	FMesh.ObjectPoligonesType:=SGR_TRIANGLES;
	FMesh.ObjectColor:=SGColor4fFromUInt32($FFFFFF);
	FMesh.EnableCullFace:=False;
	FMesh.HasNormals:=True;
	ii:=0;
	if FObject.NumMeshs<>0 then
		for i:=0 to FObject.NumMeshs-1 do
			Calculate(FObject.Meshs^[i]^);
	FMesh.SetVertexLength(ii*3);
	ii:=0;
	if FObject.NumMeshs<>0 then
		for i:=0 to FObject.NumMeshs-1 do
			AddingTriangles(FObject.Meshs^[i]^);
	if Render.SupportedGraphicalBuffers() then
		FMesh.LoadToVBO();
	end;
end;

procedure TSGPhysicsObject.RotateX(const rx : TSGFloat32 );inline;overload;
begin
Ex5_PAPPE.PhysicsObjectSetMatrix(FObject,Ex5_PAPPE.Matrix4x4TermMul(FObject.Transform,Ex5_PAPPE.Matrix4x4RotateX(rx*Ex5_PAPPE.DEG2RAD)));
end;

procedure TSGPhysicsObject.SetVertex( const x,y,z : TSGFloat32 );inline;overload;
begin
Ex5_PAPPE.PhysicsObjectSetVector(FObject,Ex5_PAPPE.Vector3(x,y,z));
end;

procedure TSGPhysicsObject.SetVertex( const v : TSGVertex3f );inline;overload;
begin
Ex5_PAPPE.PhysicsObjectSetVector(FObject,Ex5_PAPPE.Vector3(v.x,v.y,v.z));
end;

procedure TSGPhysicsObject.InitBox ( const x,y,z : TSGSingle );inline;
begin
Ex5_PAPPE.PhysicsObjectAddMesh          (FObject);
Ex5_PAPPE.PhysicsObjectMeshCreateBox    (FObject.Meshs^[0]^,x,y,z);
Ex5_PAPPE.PhysicsObjectMeshSubdivide    (FObject.Meshs^[0]^);
Ex5_PAPPE.PhysicsObjectFinish           (FObject);
end;

procedure TSGPhysicsObject.InitHeightMapFromImage(const VFileName : TSGString;const mt,md,llx,lly : TSGSingle);
var
	Image : TSGImage = nil;
	i, ii, iii : TSGMaxEnum;
	HMD : packed array of TSGSingle = nil;
begin
Image := TSGImage.Create();
Image .Context  := Context;
Image .FileName := VFileName;
if Image.Loading() then
	begin
	Ex5_PAPPE.PhysicsObjectAddMesh(FObject);
	SetLength(HMD,Image.Width * Image.Height);
	for i := 0 to Image.Width * Image.Height - 1 do
		begin
		iii :=0;
		for ii := 0 to Image.Channels - 1 do
			iii += Image.Image.BitMap[i * Image.Channels + ii];
		HMD[i] := md + (iii/(Image.Channels*255))*Abs(mt-md);
		end;
	Ex5_PAPPE.PhysicsObjectSetHeightMap(FObject,@HMD[0],Image.Width,Image.Height,llx,lly);
	Ex5_PAPPE.PhysicsObjectFinish(FObject);
	SetLength(HMD,0);
	end
else
	SGLog.Source(['TSGPhysicsObject__InitHeightMapFromImage(..). Error while open image file "', VFileName, '".']);
Image.Destroy();
end;

procedure TSGPhysicsObject.InitCapsule ( const x,y : TSGSingle; const z: TSGLongInt );inline;
begin
Ex5_PAPPE.PhysicsObjectAddMesh          (FObject);
Ex5_PAPPE.PhysicsObjectMeshCreateCapsule(FObject.Meshs^[0]^,x,y,z);
Ex5_PAPPE.PhysicsObjectMeshSubdivide    (FObject.Meshs^[0]^);
Ex5_PAPPE.PhysicsObjectFinish           (FObject);
end;

procedure TSGPhysicsObject.InitSphere ( const x : TSGSingle; const y : TSGLongInt );inline;
begin
Ex5_PAPPE.PhysicsObjectAddMesh          (FObject);
Ex5_PAPPE.PhysicsObjectMeshCreateSphere (FObject.Meshs^[0]^,x,y);
Ex5_PAPPE.PhysicsObjectMeshSubdivide    (FObject.Meshs^[0]^);
Ex5_PAPPE.PhysicsObjectFinish           (FObject);
end;

procedure TSGPhysicsObject.InitMesh (const Mesh : TSG3DObject);
var
	i, ii, iii: TSGLongWord;
begin
ii:=Ex5_PAPPE.PhysicsObjectAddMesh(FObject);
if Mesh.QuantityFaceArrays<>0 then
	begin
	for iii:=0 to FMesh.QuantityFaceArrays-1 do
		if Mesh.Faces[iii]<>0 then
			for i:=0 to Mesh.Faces[iii]-1 do
				Ex5_PAPPE.PhysicsObjectMeshAddTriangle(FObject.Meshs^[ii]^,
					TPhysicsVector3(Mesh.ArVertex3f[Mesh.ArFacesTriangles(iii,i).p[0]]^),
					TPhysicsVector3(Mesh.ArVertex3f[Mesh.ArFacesTriangles(iii,i).p[1]]^),
					TPhysicsVector3(Mesh.ArVertex3f[Mesh.ArFacesTriangles(iii,i).p[2]]^));
	end
else
	begin
	if Mesh.QuantityVertexes<>0 then
		for i:=0 to Mesh.QuantityVertexes-1 do
			if ((i+1) mod 3 = 0) then
				Ex5_PAPPE.PhysicsObjectMeshAddTriangle(FObject.Meshs^[ii]^,
					TPhysicsVector3(Mesh.ArVertex3f[i+0]^),
					TPhysicsVector3(Mesh.ArVertex3f[i+1]^),
					TPhysicsVector3(Mesh.ArVertex3f[i+2]^));
	end;
Ex5_PAPPE.PhysicsObjectMeshSubdivide    (FObject.Meshs^[ii]^);
Ex5_PAPPE.PhysicsObjectFinish           (FObject);
end;

function TSGPhysicsObject.GetMatrix():TSGPointer;inline;
begin
Result:=@FObject.InterpolatedTransform;
end;

procedure TSGPhysicsObject.SetDrawableMesh(const Mesh : TSG3DObject);
begin
if (FMesh<>nil) and (FMesh<>Mesh) then
	FMesh.Destroy();
FMesh:=Mesh;
end;

end.