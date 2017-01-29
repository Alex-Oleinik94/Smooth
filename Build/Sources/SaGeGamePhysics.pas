{$INCLUDE SaGe.inc}

unit SaGeGamePhysics;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeCommon
	,SaGeMesh
	,SaGeModel
	,SaGeGameBase
	,SaGeScene
	,SaGeCommonClasses
	
	,SaGePhysics
	;

type
	TSGPhysicsModel=class(TSGNodProperty)
			public
		constructor Create(const VContext : ISGContext);override;
			private
		FPhysicsObject : TSGPhysicsObject;
			public
		property PhysicsObject : TSGPhysicsObject read FPhysicsObject write FPhysicsObject;
		end;
type
	TSGCustomPhysics = class(TSGMutator)
		end;
type
	TSGPhysics3D = class(TSGCustomPhysics)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
			private
		FPhysics : TSGPhysics;
			public
		procedure UpDate();override;
		procedure Start();override;
		procedure AddNodProperty(const NewParentNod:TSGNod);override;
		end;

implementation

constructor TSGPhysicsModel.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FPhysicsObject:=nil;
end;

procedure TSGPhysics3D.AddNodProperty(const NewParentNod:TSGNod);
begin
FLastNodProperty:=TSGPhysicsModel.Create(Context);
NewParentNod.AddNod(FLastNodProperty);
end;

procedure TSGPhysics3D.Start();
var
	i : TSGLongWord;
	m : TSGPhysicsModel;
begin
FPhysics.Start();
if FParent.QuantityNods <> 0 then
	for i:=0 to FParent.QuantityNods-1 do
		begin
		m:=((FParent.Nods[i] as TSGModel).FindProperty(TSGPhysicsModel)) as TSGPhysicsModel;
		if m<>nil then
			(FParent.Nods[i] as TSGModel).Matrix:=m.PhysicsObject.GetMatrix();
		end;
end;

constructor TSGPhysics3D.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FPhysics:=TSGPhysics.Create(Context);
FPhysics.Drawable:=False;
FLastNodProperty:=nil;
end;

destructor TSGPhysics3D.Destroy();
begin
FPhysics.Destroy();
inherited;
end;

procedure TSGPhysics3D.Paint();
begin
if FPhysics <> nil then
	FPhysics.Paint();
end;

procedure TSGPhysics3D.UpDate();
begin
if FPhysics <> nil then
	FPhysics.UpDate();
end;

end.
