{$INCLUDE SaGe.inc}
{$IF defined(ENGINE)}
	unit ExKraft;
	interface
{$ELSE}
	program ExampleKraft;
	{$ENDIF}
uses
	{$IF not defined(ENGINE)}
		{$IF defined(UNIX)}
			{$IF not defined(ANDROID)}
				cthreads,
				{$ENDIF}
			{$ENDIF}
		SaGeBaseExample,
		{$ENDIF}
	SaGeContext
	,SaGeBased
	,SaGeBase
	,SaGeUtils
	,SaGeRender
	,SaGeCommon
	
	,Kraft
	,UnitDemoScene
	,UnitDemoSceneBoxOnPlane
	,UnitDemoSceneBoxPyramidStacking
	,UnitDemoSceneBoxStacking
	,UnitDemoSceneBrickWall
	,UnitDemoSceneBridge
	,UnitDemoSceneCar
	,UnitDemoSceneCarousel
	,UnitDemoSceneCatapult
	,UnitDemoSceneChain
	,UnitDemoSceneChairAndTable
	,UnitDemoSceneCombinedShapes
	,UnitDemoSceneConvexHull
	,UnitDemoSceneDomino
	,UnitDemoSceneRoundabout
	,UnitDemoSceneSandBox
	,UnitDemoSceneStrainedChain
	;

type
	TSGKraftExamples = class(TSGDrawClass)
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		class function ClassName() : TSGString;override;
		procedure Draw();override;
			private
		KraftPhysics : TKraft;
		DemoScene : TDemoScene;
		LastTime, NowTime, DeltaTime, FST2, FET2, Frames : TSGInt64;
		FPS : TSGDouble;
		FloatDeltaTime : TSGDouble;
		TimeAccumulator : TSGDouble;
		LastMouseX, LastMouseY : TSGLongInt;
		Grabbing, Rotating : TSGBoolean;
		KeyLeft, KeyRight, KeyBackwards, KeyForwards, KeyUp, KeyDown : TSGBoolean;
		HighResolutionTimer : TKraftHighResolutionTimer;
			public
		procedure LoadScene(DemoSceneClass:TDemoSceneClass);
		end;

{$IF defined(ENGINE)}
	implementation
	{$ENDIF}

procedure TSGKraftExamples.LoadScene(DemoSceneClass:TDemoSceneClass);
var RigidBody:TKraftRigidBody;
    Constraint:TKraftConstraint;
begin

 sTreeViewMain.Items.BeginUpdate;
 try

  TreeNodeKraftPhysics:=nil;

  SetObjectInspectorRoot(nil);
  sTreeViewMain.Items.Clear;

  FreeAndNil(DemoScene);

  DemoScene:=DemoSceneClass.Create(KraftPhysics);

  TreeNodeKraftPhysics:=sTreeViewMain.Items.AddObjectFirst(nil,'TKraft',KraftPhysics);

  RigidBody:=KraftPhysics.RigidBodyFirst;
  while assigned(RigidBody) do begin
   AddRigidBody(RigidBody);
   RigidBody:=RigidBody.RigidBodyNext;
  end;

  Constraint:=KraftPhysics.ConstraintFirst;
  while assigned(Constraint) do begin
   AddConstraint(Constraint);
   Constraint:=Constraint.Next;
  end;

  sTreeViewMain.Selected:=TreeNodeKraftPhysics;
  TreeNodeKraftPhysics.Expand(true);
  SetObjectInspectorRoot(KraftPhysics);

  CurrentCamera.Reset;
  LastCamera:=CurrentCamera;

 finally
  sTreeViewMain.Items.EndUpdate;
 end;

 KraftPhysics.StoreWorldTransforms;
 KraftPhysics.InterpolateWorldTransforms(0.0);

 LastTime:=HighResolutionTimer.GetTime;

end;

constructor TSGKraftExamples.Create(const VContext : TSGContext);
begin
inherited Create(VContext);

end;

destructor TSGKraftExamples.Destroy();
begin
inherited;
end;

class function TSGKraftExamples.ClassName() : TSGString;
begin
Result := 'Дэмо физического движка "Kraft"'; 
end;

procedure TSGKraftExamples.Draw();
begin

end;


{$IF not defined(ENGINE)}
	begin
	ExampleClass := TSGKraftExamples;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
