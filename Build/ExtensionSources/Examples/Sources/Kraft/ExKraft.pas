{$INCLUDE Smooth.inc}
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
		SmoothBaseExample,
		{$ENDIF}
	 SmoothContext
	,SmoothBase
	,SmoothRender
	,SmoothCommon
	,SmoothContextInterface
	,SmoothContextClasses
	,SmoothBaseClasses
	
	,Classes
	,Kraft
	,KraftDemoScene
	// Demo scenes
	,KDSBoxOnPlane
	,KDSBoxPyramidStacking
	,KDSBoxStacking
	,KDSBrickWall
	,KDSBridge
	,KDSCar
	,KDSCarousel
	,KDSCatapult
	,KDSChain
	,KDSChairAndTable
	,KDSCombinedShapes
	,KDSConvexHull
	,KDSDomino
	,KDSRoundabout
	,KDSSandBox
	,KDSStrainedChain
	;

type
	TSKraftExamples = class;
	
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
		FClass : TSKraftExamples;
			private
		procedure Draw;
			protected
		procedure Execute; override;
			public
		constructor Create;
		destructor Destroy; override;
		end;
	
	TSKraftExamples = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName() : TSString;override;
		procedure Paint();override;
			public
		KraftPhysics : TKraft;
		DemoScene : TDemoScene;
		OpenGLInitialized:boolean;
		CurrentCamera,LastCamera,InterpolatedCamera:TCamera;
		LastTime, NowTime, DeltaTime, FST2, FET2, Frames : TSInt64;
		FPS : TSDouble;
		FloatDeltaTime : TSDouble;
		TimeAccumulator : TSDouble;
		LastMouseX, LastMouseY : TSLongInt;
		Grabbing, Rotating : TSBoolean;
		KeyLeft, KeyRight, KeyBackwards, KeyForwards, KeyUp, KeyDown : TSBoolean;
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

procedure TSKraftExamples.LoadScene(DemoSceneClass:TDemoSceneClass);
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

constructor TSKraftExamples.Create(const VContext : ISContext);
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

destructor TSKraftExamples.Destroy();
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

class function TSKraftExamples.ClassName() : TSString;
begin
Result := 'Дэмо физического движка Kraft'; 
end;

procedure TSKraftExamples.Paint();
begin

end;

{$IF not defined(ENGINE)}
	begin
	ExampleClass := TSKraftExamples;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
