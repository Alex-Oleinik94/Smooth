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
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
			protected
		FScene      : TSGScene;
		FLoadThread : TSGThread;
		FLoadClass  : TSGLoading;
		FState      : TSGLongWord;
			private
		procedure Load();
		end;

implementation

uses
	 SaGeLog
	;

class function TSGGameTron.ClassName():TSGString;
begin
Result := 'Трон';
end;

procedure TSGGameTron.Paint();
begin
if (FLoadClass <> nil) then
	FLoadClass.Paint();
case FState of
SGTStateStarting:
	begin
	FScene.Start();
	FState:=SGTStateViewing;
	{$IFDEF ANDROID}SGLog.Source('SGTStateStarting');{$ENDIF}
	end;
SGTStateViewing:
	begin
	{$IFDEF ANDROID}SGLog.Source('SGTStateViewing');{$ENDIF}
	FScene.Paint();
	{$IFDEF ANDROID}SGLog.Source('SGTStateViewing');{$ENDIF}
	end;
end;
end;

procedure TSGGameTron.Load();

procedure Add3DSModel(const FileName : TSGString);
var
	Model : TSGModel = nil;
begin
Model := TSGModel.Create(Context);
Model.Mesh.Load3DSFromFile(FileName);
FScene.AddNod(Model);
end;

begin
FLoadClass.Progress := 0.04001;
Add3DSModel('./../Data/Tron/motoBike.3ds');
FLoadClass.Progress := 0.5001;
Add3DSModel('./../Data/Tron/Map.3ds');
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
FScene:=nil;
FLoadClass:=nil;
FLoadThread:=nil;
FState := SGTStateLoading;

FScene := TSGScene.Create(VContext);
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
