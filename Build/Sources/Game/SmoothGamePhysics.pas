{$INCLUDE Smooth.inc}

unit SmoothGamePhysics;

interface

uses
	 SmoothBase
	,SmoothCommon
	,SmoothMesh
	,SmoothModel
	,SmoothGameBase
	,SmoothScene
	,SmoothContextClasses
	,SmoothContextInterface
	
	,SmoothPhysics
	;

type
	TSPhysicsModel=class(TSNodProperty)
			public
		constructor Create(const VContext : ISContext);override;
		class function ClassName() : TSString; override;
			private
		FPhysicsObject : TSPhysicsObject;
			public
		property PhysicsObject : TSPhysicsObject read FPhysicsObject write FPhysicsObject;
		end;
type
	TSCustomPhysics = class(TSMutator)
		end;
type
	TSPhysics3D = class(TSCustomPhysics)
			public
		constructor Create(const VContext : ISContext);override;
		class function ClassName() : TSString; override;
		destructor Destroy();override;
		procedure Paint();override;
			private
		FPhysics : TSPhysics;
			public
		procedure UpDate();override;
		procedure Start();override;
		procedure AddNodProperty(const NewParentNod:TSNod);override;
		end;

implementation

class function TSPhysicsModel.ClassName() : TSString;
begin
Result := 'TSPhysicsModel';
end;

constructor TSPhysicsModel.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FPhysicsObject:=nil;
end;

procedure TSPhysics3D.AddNodProperty(const NewParentNod:TSNod);
begin
FLastNodProperty:=TSPhysicsModel.Create(Context);
NewParentNod.AddNod(FLastNodProperty);
end;

class function TSPhysics3D.ClassName() : TSString;
begin
Result := 'TSPhysics3D';
end;

procedure TSPhysics3D.Start();
var
	i : TSLongWord;
	m : TSPhysicsModel;
begin
FPhysics.Start();
if FParent.QuantityNods <> 0 then
	for i:=0 to FParent.QuantityNods-1 do
		begin
		m := ((FParent.Nods[i] as TSModel).FindProperty(TSPhysicsModel)) as TSPhysicsModel;
		if m<>nil then
			(FParent.Nods[i] as TSModel).Matrix := m.PhysicsObject.GetMatrix();
		end;
end;

constructor TSPhysics3D.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FPhysics:=TSPhysics.Create(Context);
FPhysics.Drawable:=False;
FLastNodProperty:=nil;
end;

destructor TSPhysics3D.Destroy();
begin
FPhysics.Destroy();
inherited;
end;

procedure TSPhysics3D.Paint();
begin
if FPhysics <> nil then
	FPhysics.Paint();
end;

procedure TSPhysics3D.UpDate();
begin
if FPhysics <> nil then
	FPhysics.UpDate();
end;

end.
