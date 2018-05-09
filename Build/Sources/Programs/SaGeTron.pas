{$INCLUDE SaGe.inc}

unit SaGeTron;

interface

uses 
	 Crt
	,SysUtils
	
	,SaGeBase
	,SaGeCommonClasses
	,SaGelNetBase
	,SaGelNetUDPConnection
	,SaGeLoading
	,SaGeFont
	,SaGeMesh
	,SaGeThreads
	,SaGeCamera
	,SaGeClasses
	
	,SaGeModel
	,SaGeScene
	,SaGeGamePhysics
	,SaGeGameNet
	;

const
	SGTStateLoading  = $006001;
	SGTStateStarting = $006002;
	SGTStateViewing  = $006003;
type
	TSGGameTron = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext); override;
		destructor Destroy(); override;
		procedure Paint(); override;
		class function ClassName() : TSGString; override;
			protected
		FScene      : TSGScene;
		FLoadThread : TSGThread;
		FLoadClass  : TSGLoading;
		FState      : TSGUInt32;
			private
		FProgressInterfaceLocked : TSGBoolean;
		FTotalProgress     : TSGFloat32;
		FSectionProgress   : TSGFloat32;
		FSectionProportion : TSGFloat32;
		FProgress          : TSGFloat32;
			private
		procedure KillLoad();
		procedure Load();
		procedure UpdateProgress();
		procedure FinishLoadSection();
		function AddLoadSection(const Name : TSGString; const Proportion : TSGFloat32) : PSGFloat32;
		end;

implementation

uses
	 SaGeLog
	,SaGeCommonStructs
	,SaGeMathUtils
	,SaGeFileUtils
	,SaGeMeshLoader
	,SaGeMeshSg3dm
	;

class function TSGGameTron.ClassName() : TSGString;
begin
Result := 'Трон';
end;

function TSGGameTron.AddLoadSection(const Name : TSGString; const Proportion : TSGFloat32) : PSGFloat32;
begin
while FProgressInterfaceLocked do
	Sleep(2);
FProgressInterfaceLocked := True;
FSectionProgress := 0;
FSectionProportion := Proportion;
FProgress := FTotalProgress;
FProgressInterfaceLocked := False;
Result := @FSectionProgress;
end;

procedure TSGGameTron.FinishLoadSection();
begin
while FProgressInterfaceLocked do
	Sleep(2);
FProgressInterfaceLocked := True;
FTotalProgress += FSectionProportion;
FProgress := FTotalProgress;
FSectionProportion := 0;
FSectionProgress := 0;
FProgressInterfaceLocked := False;
end;

procedure TSGGameTron.UpdateProgress();
begin
while FProgressInterfaceLocked do
	Sleep(2);
FProgress := FTotalProgress + FSectionProgress * FSectionProportion;
if FLoadClass <> nil then
	FLoadClass.Progress := FProgress;
end;

procedure TSGGameTron.Paint();

procedure InitCamera();
begin
Context.CursorCentered := True;
Context.ShowCursor(False);
FScene.Camera.ViewMode := SG_VIEW_LOOK_AT_OBJECT;
FScene.Camera.Up       := SGVertex3fImport(0.0913988, 0.7369644, -0.6697236);
FScene.Camera.Location := SGVertex3fImport(-2.0990655, 20.3042564, 22.1641521);
FScene.Camera.View     := SGVertex3fImport(0.0729761, -0.6756871, -0.7335674);
FScene.Camera.ChangingLookAtObject := True;
end;

begin
case FState of
SGTStateLoading : 
	UpdateProgress();
SGTStateStarting :
	begin
	InitCamera();
	FScene.Start();
	FState := SGTStateViewing;
	SGLog.Source('TSGGameTron__Paint(). Starting...');
	end;
SGTStateViewing :
	begin
	if (FLoadClass <> nil) then
		if FLoadClass.Alpha < SGZero then
			KillLoad();
	if FScene <> nil then
		FScene.Paint();
	end;
end;
if (FLoadClass <> nil) then
	FLoadClass.Paint();
end;

procedure TSGGameTron.Load();

procedure Add3DSModel(FileName : TSGString; const LoadProgressProportion : TSGFloat32);
var
	Model : TSGModel = nil;
begin
FileName := SGCheckDirectorySeparators(FileName);
AddLoadSection('"' + FileName + '"', LoadProgressProportion);
Model := TSGModel.Create(Context);

if SGFileExists(FileName + '.Sg3dm') then
	TSGMeshSG3DMLoader.LoadModelFromFile(Model.Mesh, FileName + '.Sg3dm')
else
	begin
	SGLoadMesh3DS(Model.Mesh, FileName, @FSectionProgress);
	TSGMeshSG3DMLoader.SaveModelToFile(Model.Mesh, FileName + '.Sg3dm');
	end;

FScene.AddNod(Model);
FinishLoadSection();
end;

begin
FTotalProgress := 0.04;
Add3DSModel('./../Data/Tron/Map.3ds', (1 - 0.04) * 0.1);
Add3DSModel('./../Data/Tron/motoBike.3ds', (1 - 0.04) * 0.9);
FLoadClass.Progress := 1.0001;
FState := SGTStateStarting;
end;

procedure LoadThread(VThronClass:TSGGameTron);
begin
VThronClass.Load();
end;

constructor TSGGameTron.Create(const VContext : ISGContext);
begin
inherited Create(VContext);

FProgressInterfaceLocked := False;
FTotalProgress     := 0;
FSectionProgress   := 0;
FSectionProportion := 0;
FProgress          := 0;

FScene      := nil;
FLoadClass  := nil;
FLoadThread := nil;
FState      := SGTStateLoading;

FScene := TSGScene.Create(Context);
FScene.Camera.ViewMode := SG_VIEW_LOOK_AT_OBJECT;

FScene.AddMutator(TSGPhysics3D);
(FScene.AddMutator(TSGNet) as TSGNet).ConnectionMode := SGClientMode;

FLoadClass := TSGLoading.Create(Context);
FLoadClass.Progress := 0;
FLoadThread := TSGThread.Create(TSGThreadProcedure(@LoadThread), Self, False);
FLoadThread.Start();
end;

procedure TSGGameTron.KillLoad();
begin
if FLoadThread<>nil then
	begin
	FLoadThread.Destroy();
	FLoadThread := nil;
	end;
if FLoadClass<>nil then
	begin
	FLoadClass.Destroy();
	FLoadClass := nil;
	end;
end;

destructor TSGGameTron.Destroy();
begin
KillLoad();
if FScene<>nil then
	begin
	FScene.Destroy();
	FScene := nil;
	end;
Context.CursorCentered := False;
Context.ShowCursor(True);
inherited Destroy();
end;

end.
