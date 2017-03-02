{$INCLUDE SaGe.inc}

unit SaGeTron;

interface

uses 
	 Crt
	,SysUtils
	
	,SaGeBase
	,SaGeCommonClasses
	,SaGeNet
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
	TSGGameTron=class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext); override;
		destructor Destroy(); override;
		procedure Paint(); override;
		class function ClassName() : TSGString; override;
			protected
		FScene      : TSGScene;
		FLoadThread : TSGThread;
		FLoadClass  : TSGLoading;
		FState      : TSGLongWord;
			private
		FProgressInterfaceLocked : TSGBoolean;
		FTotalProgress     : TSGFloat32;
		FSectionProgress   : TSGFloat32;
		FSectionProportion : TSGFloat32;
		FProgress          : TSGFloat32;
			private
		procedure Load();
		procedure UpdateProgress();
		procedure FinishLoadSection();
		function AddLoadSection(const Name : TSGString; const Proportion : TSGFloat32) : PSGFloat32;
		end;

implementation

uses
	 SaGeLog
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
begin
if (FLoadClass <> nil) then
	FLoadClass.Paint();
case FState of
SGTStateLoading : UpdateProgress();
SGTStateStarting :
	begin
	FScene.Start();
	FScene.ViewInfo('', [SGLogType]);
	FState := SGTStateViewing;
	SGLog.Source('TSGGameTron__Paint(). Starting...');
	end;
SGTStateViewing :
	if FScene <> nil then
		FScene.Paint();
end;
end;

procedure TSGGameTron.Load();

procedure Add3DSModel(const FileName : TSGString; const LoadProgressProportion : TSGFloat32);
var
	Model : TSGModel = nil;
begin
AddLoadSection('"' + FileName + '"', LoadProgressProportion);
Model := TSGModel.Create(Context);
Model.Mesh.Load3DSFromFile(FileName, @FSectionProgress);
FScene.AddNod(Model);
FinishLoadSection();
end;

begin
FTotalProgress := 0.04;
Add3DSModel('./../Data/Tron/motoBike.3ds', (1 - 0.04) * 0.9);
Add3DSModel('./../Data/Tron/Map.3ds', (1 - 0.04) * 0.1);
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

destructor TSGGameTron.Destroy();
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
if FScene<>nil then
	begin
	FScene.Destroy();
	FScene := nil;
	end;
inherited Destroy();
end;

end.
