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

  {RigidBody:=KraftPhysics.RigidBodyFirst;
  while assigned(RigidBody) do begin
   AddRigidBody(RigidBody);
   RigidBody:=RigidBody.RigidBodyNext;
  end;

  Constraint:=KraftPhysics.ConstraintFirst;
  while assigned(Constraint) do begin
   AddConstraint(Constraint);
   Constraint:=Constraint.Next;
  end;}

  //sTreeViewMain.Selected:=TreeNodeKraftPhysics;

  //s CurrentCamera.Reset;
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

{TheObjectInspector:=TObjectInspectorDlg.Create(Application);
 TheObjectInspector.PropertyEditorHook:=ThePropertyEditorHook;
 TheObjectInspector.SetBounds(10,10,240,500);}

 //SetObjectInspectorRoot(nil);
 //TheObjectInspector.Show;

 DemoScene:=nil;

 OpenGLInitialized:=false;


 KraftPhysics:=TKraft.Create(-1);

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

 //s CurrentCamera.Reset;
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
  
 finally
  //sTreeViewDemos.Items.EndUpdate;
 end;
end;

destructor TSGKraftExamples.Destroy();
begin
DemoScene.Free();
DemoScene := nil;
KraftPhysics.Free();
KraftPhysics := nil;
ThreadTimer.Terminate;
if ThreadTimer.Suspended then
	begin
	ThreadTimer.Resume;
	end;
ThreadTimer.WaitFor;
ThreadTimer.Free;
HighResolutionTimer.Free;
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
