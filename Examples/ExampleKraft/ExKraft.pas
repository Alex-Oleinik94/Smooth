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
	,SaGeBase
	,SaGeUtils
	,SaGeRender
	,SaGeCommon
	,SaGeCommonClasses
	,SaGeClasses
	,SaGeScreen
	
	,Classes
	
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
	TSGKraftExamples = class;
	
	TCamera=object
			public
		LeftRight:TKraftScalar;
		UpDown:TKraftScalar;
		Position:TKraftVector3;
		Orientation:TKraftQuaternion;
		Matrix:TKraftMatrix4x4;
		FOV:TKraftScalar;
		procedure Reset;
		procedure MoveForwards(Speed:TKraftScalar);
		procedure MoveSidewards(Speed:TKraftScalar);
		procedure MoveUpwards(Speed:TKraftScalar);
		procedure RotateCamera(const x,y:TKraftScalar);
		procedure TestCamera;
		procedure Interpolate(const a,b:TCamera;const t:TKraftScalar);
		end;

	TThreadTimer=class(TThread)
			public
		FClass : TSGKraftExamples;
			private
		procedure Draw;
			protected
		procedure Execute; override;
			public
		constructor Create;
		destructor Destroy; override;
		end;
	
	TSGKraftExamples = class(TSGScreenedDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName() : TSGString;override;
		procedure Paint();override;
			public
		KraftPhysics : TKraft;
		DemoScene : TDemoScene;
		OpenGLInitialized:boolean;
		CurrentCamera,LastCamera,InterpolatedCamera:TCamera;
		LastTime, NowTime, DeltaTime, FST2, FET2, Frames : TSGInt64;
		FPS : TSGDouble;
		FloatDeltaTime : TSGDouble;
		TimeAccumulator : TSGDouble;
		LastMouseX, LastMouseY : TSGLongInt;
		Grabbing, Rotating : TSGBoolean;
		KeyLeft, KeyRight, KeyBackwards, KeyForwards, KeyUp, KeyDown : TSGBoolean;
		HighResolutionTimer : TKraftHighResolutionTimer;
		ThreadTimer:TThreadTimer;
			public
		procedure LoadScene(DemoSceneClass:TDemoSceneClass);
		procedure AddRigidBody(RigidBody:TKraftRigidBody);
		procedure AddConstraint(Constraint:TKraftConstraint);
		procedure SetObjectInspectorRoot(AObject: TPersistent);
		end;

{$IF defined(ENGINE)}
	implementation
	{$ENDIF}

constructor TThreadTimer.Create;
begin
 FreeOnTerminate:=false;
 inherited Create(true);
end;

destructor TThreadTimer.Destroy;
begin
 inherited Destroy;
end;

procedure TThreadTimer.Draw;
begin
 if assigned(FClass.KraftPhysics) then begin
  FClass.Paint;
 end;
end;

procedure TThreadTimer.Execute;
begin
 while not Terminated do begin
  Synchronize(@Draw);
  Sleep(0);
 end;
end;

var GrabRigidBody:TKraftRigidBody;
    GrabShape:TKraftShape;
    GrabDelta:TKraftVector3;
    GrabDistance:single;
//  GrabRigidBodyTransform:TKraftMatrix4x4;
//  GrabCameraTransform:TKraftMatrix4x4;
    GrabConstraint:TKraftConstraintJointGrab;

procedure TSGKraftExamples.SetObjectInspectorRoot(AObject: TPersistent);
var Selection: TPersistentSelectionList;
begin
 if assigned(AObject) then begin
  ThePropertyEditorHook.LookupRoot:=AObject;
  Selection:=TPersistentSelectionList.Create;
  try
   Selection.Add(AObject);
   //TheObjectInspector.Selection:=Selection;
   PropertyGrid.Selection:=Selection;
  finally
   Selection.Free;
  end;
 end else begin
  ThePropertyEditorHook.LookupRoot:=nil;
  Selection:=TPersistentSelectionList.Create;
  try
   //TheObjectInspector.Selection:=Selection;
   PropertyGrid.Selection:=Selection;
  finally
   Selection.Free;
  end;
 end;
end;

procedure TSGKraftExamples.AddConstraint(Constraint:TKraftConstraint);
var Index:longint;
    TreeNodeConstraint,TreeNodeRigidBody,TreeNodeRigidBodyShape:TTreeNode;
    RigidBody:TKraftRigidBody;
    Shape:TKraftShape;
begin
 //TreeNodeConstraint:=sTreeViewMain.Items.AddChildObject(TreeNodeKraftPhysics,Constraint.ClassName,Constraint);
 for Index:=0 to length(Constraint.RigidBodies)-1 do begin
  RigidBody:=Constraint.RigidBodies[Index];
  if assigned(RigidBody) then begin
   //TreeNodeRigidBody:=sTreeViewMain.Items.AddChildObject(TreeNodeConstraint,RigidBody.ClassName,RigidBody);
   Shape:=RigidBody.ShapeFirst;
   while assigned(Shape) do begin
    //TreeNodeRigidBodyShape:=sTreeViewMain.Items.AddChildObject(TreeNodeRigidBody,Shape.ClassName,Shape);
    if assigned(TreeNodeRigidBodyShape) then begin
    end;
    Shape:=Shape.ShapeNext;
   end;
  end;
 end;
end;

procedure TSGKraftExamples.AddRigidBody(RigidBody:TKraftRigidBody);
var TreeNodeRigidBody,TreeNodeRigidBodyShape:TTreeNode;
    Shape:TKraftShape;
begin
 //TreeNodeRigidBody:=sTreeViewMain.Items.AddChildObject(TreeNodeKraftPhysics,RigidBody.ClassName,RigidBody);
 Shape:=RigidBody.ShapeFirst;
 while assigned(Shape) do begin
  //TreeNodeRigidBodyShape:=sTreeViewMain.Items.AddChildObject(TreeNodeRigidBody,Shape.ClassName,Shape);
  if assigned(TreeNodeRigidBodyShape) then begin
  end;
  Shape:=Shape.ShapeNext;
 end;
end;

procedure TSGKraftExamples.LoadScene(DemoSceneClass:TDemoSceneClass);
var RigidBody:TKraftRigidBody;
    Constraint:TKraftConstraint;
begin

 //sTreeViewMain.Items.BeginUpdate;
 try

  //TreeNodeKraftPhysics:=nil;

  //SetObjectInspectorRoot(nil);
  //sTreeViewMain.Items.Clear;

  //FreeAndNil(DemoScene);

  DemoScene:=DemoSceneClass.Create(KraftPhysics);

  //TreeNodeKraftPhysics:=sTreeViewMain.Items.AddObjectFirst(nil,'TKraft',KraftPhysics);

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

  //sTreeViewMain.Selected:=TreeNodeKraftPhysics;
  TreeNodeKraftPhysics.Expand(true);
  SetObjectInspectorRoot(KraftPhysics);

  CurrentCamera.Reset;
  LastCamera:=CurrentCamera;

 finally
  //sTreeViewMain.Items.EndUpdate;
 end;

 KraftPhysics.StoreWorldTransforms;
 KraftPhysics.InterpolateWorldTransforms(0.0);

 LastTime:=HighResolutionTimer.GetTime;

end;

constructor TSGKraftExamples.Create(const VContext : ISGContext);
var Index:longint;
begin
inherited Create(VContext);

 ThePropertyEditorHook:=TPropertyEditorHook.Create(nil);

{TheObjectInspector:=TObjectInspectorDlg.Create(Application);
 TheObjectInspector.PropertyEditorHook:=ThePropertyEditorHook;
 TheObjectInspector.SetBounds(10,10,240,500);{}

 PropertyGrid:=TOIPropertyGrid.CreateWithParams(Self,ThePropertyEditorHook
      ,[tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat, tkSet{, tkMethod}
      , tkSString, tkLString, tkAString, tkWString, tkVariant
      , tkArray, tkRecord, tkInterface, tkClass, tkObject, tkWChar, tkBool
      , tkInt64, tkQWord],
      25);
 PropertyGrid.Name:='PropertyGrid';
 PropertyGrid.Parent:=sGroupBoxPropertyEditor;
 PropertyGrid.Align:=alClient;
 SetObjectInspectorRoot(nil);
 //TheObjectInspector.Show;

 DemoScene:=nil;

 OpenGLInitialized:=false;

 PasMPInstance:=TPasMP.Create(-1,0,false);

{$ifdef KraftPasMP}
 KraftPhysics:=TKraft.Create(PasMPInstance);
{$else}
 KraftPhysics:=TKraft.Create(-1);
{$endif}

 KraftPhysics.SetFrequency(120.0);

 KraftPhysics.VelocityIterations:=8;

 KraftPhysics.PositionIterations:=3;

 KraftPhysics.SpeculativeIterations:=8;

 KraftPhysics.TimeOfImpactIterations:=20;

 KraftPhysics.Gravity.y:=-9.81;
 
 ThreadTimer:=TThreadTimer.Create;

 KeyLeft:=false;
 KeyRight:=false;
 KeyBackwards:=false;
 KeyForwards:=false;
 KeyUp:=false;
 KeyDown:=false;

 //ReadyGL:=false;

 Grabbing:=false;

 Rotating:=false;

 CurrentCamera.Reset;
 LastCamera:=CurrentCamera;

 HighResolutionTimer:=TKraftHighResolutionTimer.Create(60);

 LastTime:=HighResolutionTimer.GetTime;

 FPS:=0.0;

 FST2:=LastTime;
 FET2:=LastTime;
 Frames:=0;

 TimeAccumulator:=0.0;

 //sTreeViewDemos.Items.BeginUpdate;
 try
  DemoScenes.Sort;
  //TreeNodeDemos:=sTreeViewDemos.Items.AddChildFirst(nil,'Demos');
  for Index:=0 to DemoScenes.Count-1 do begin
   //sTreeViewDemos.Items.AddChildObject(TreeNodeDemos,DemoScenes.Strings[Index],DemoScenes.Objects[Index]);
  end;
  TreeNodeDemoDefault:=TreeNodeDemos.GetFirstChild;
 finally
  //sTreeViewDemos.Items.EndUpdate;
 end;
 TreeNodeDemos.Expand(true);
end;

destructor TSGKraftExamples.Destroy();
begin
FreeAndNil(DemoScene);
FreeAndNil(KraftPhysics);
FreeAndNil(PasMPInstance);
ThreadTimer.Terminate;
if ThreadTimer.Suspended then
	begin
	ThreadTimer.Resume;
	end;
ThreadTimer.WaitFor;
ThreadTimer.Free;
HighResolutionTimer.Free;
ThePropertyEditorHook.Free;
inherited;
end;

class function TSGKraftExamples.ClassName() : TSGString;
begin
Result := 'Дэмо физического движка "Kraft"'; 
end;

procedure TSGKraftExamples.Paint();
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
