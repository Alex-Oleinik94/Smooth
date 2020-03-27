{$INCLUDE Smooth.inc}

unit SmoothTron;

interface

uses 
	 Crt
	,SysUtils
	
	,SmoothBase
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothlNetBase
	,SmoothlNetUDPConnection
	,SmoothFullscreenLoading
	,SmoothFont
	,SmoothMesh
	,SmoothThreads
	,SmoothCamera
	,SmoothBaseClasses
	
	,SmoothModel
	,SmoothScene
	,SmoothGamePhysics
	,SmoothGameNet
	;

const
	STStateLoading  = $006001;
	STStateStarting = $006002;
	STStateViewing  = $006003;
type
	TSGameTron = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext); override;
		destructor Destroy(); override;
		procedure Paint(); override;
		class function ClassName() : TSString; override;
			protected
		FScene      : TSScene;
		FLoadThread : TSThread;
		FLoadClass  : TSLoading;
		FState      : TSUInt32;
			private
		FProgressInterfaceLocked : TSBoolean;
		FTotalProgress     : TSFloat32;
		FSectionProgress   : TSFloat32;
		FSectionProportion : TSFloat32;
		FProgress          : TSFloat32;
			private
		procedure KillLoad();
		procedure Load();
		procedure UpdateProgress();
		procedure FinishLoadSection();
		function AddLoadSection(const Name : TSString; const Proportion : TSFloat32) : PSFloat32;
		end;

implementation

uses
	 SmoothLog
	,SmoothCommonStructs
	,SmoothMathUtils
	,SmoothFileUtils
	,SmoothMeshLoader
	,SmoothMeshS3dm
	;

class function TSGameTron.ClassName() : TSString;
begin
Result := 'Трон';
end;

function TSGameTron.AddLoadSection(const Name : TSString; const Proportion : TSFloat32) : PSFloat32;
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

procedure TSGameTron.FinishLoadSection();
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

procedure TSGameTron.UpdateProgress();
begin
while FProgressInterfaceLocked do
	Sleep(2);
FProgress := FTotalProgress + FSectionProgress * FSectionProportion;
if FLoadClass <> nil then
	FLoadClass.Progress := FProgress;
end;

procedure TSGameTron.Paint();

procedure InitCamera();
begin
Context.CursorCentered := True;
Context.ShowCursor(False);
FScene.Camera.ViewMode := S_VIEW_LOOK_AT_OBJECT;
FScene.Camera.Up       := SVertex3fImport(0.0913988, 0.7369644, -0.6697236);
FScene.Camera.Location := SVertex3fImport(-2.0990655, 20.3042564, 22.1641521);
FScene.Camera.View     := SVertex3fImport(0.0729761, -0.6756871, -0.7335674);
FScene.Camera.ChangingLookAtObject := True;
end;

begin
case FState of
STStateLoading : 
	UpdateProgress();
STStateStarting :
	begin
	InitCamera();
	FScene.Start();
	FState := STStateViewing;
	SLog.Source('TSGameTron__Paint(). Starting...');
	end;
STStateViewing :
	begin
	if (FLoadClass <> nil) then
		if FLoadClass.Alpha < SZero then
			KillLoad();
	if FScene <> nil then
		FScene.Paint();
	end;
end;
if (FLoadClass <> nil) then
	FLoadClass.Paint();
end;

procedure TSGameTron.Load();

procedure Add3DSModel(FileName : TSString; const LoadProgressProportion : TSFloat32);
var
	Model : TSModel = nil;
begin
FileName := SCheckDirectorySeparators(FileName);
AddLoadSection('"' + FileName + '"', LoadProgressProportion);
Model := TSModel.Create(Context);

if SFileExists(FileName + '.S3dm') then
	TSMeshS3DMLoader.LoadModelFromFile(Model.Mesh, FileName + '.S3dm')
else
	begin
	SLoadMesh3DS(Model.Mesh, FileName, @FSectionProgress);
	TSMeshS3DMLoader.SaveModelToFile(Model.Mesh, FileName + '.S3dm');
	end;

FScene.AddNod(Model);
FinishLoadSection();
end;

begin
FTotalProgress := 0.04;
Add3DSModel('./../Data/Tron/Map.3ds', (1 - 0.04) * 0.1);
Add3DSModel('./../Data/Tron/motoBike.3ds', (1 - 0.04) * 0.9);
FLoadClass.Progress := 1.0001;
FState := STStateStarting;
end;

procedure LoadThread(VThronClass:TSGameTron);
begin
VThronClass.Load();
end;

constructor TSGameTron.Create(const VContext : ISContext);
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
FState      := STStateLoading;

FScene := TSScene.Create(Context);
FScene.Camera.ViewMode := S_VIEW_LOOK_AT_OBJECT;

FScene.AddMutator(TSPhysics3D);
(FScene.AddMutator(TSNet) as TSNet).ConnectionMode := SClientMode;

FLoadClass := TSLoading.Create(Context);
FLoadClass.Progress := 0;
FLoadThread := TSThread.Create(TSThreadProcedure(@LoadThread), Self, False);
FLoadThread.Start();
end;

procedure TSGameTron.KillLoad();
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

destructor TSGameTron.Destroy();
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
