{$INCLUDE SaGe.inc}

unit SaGeTron;

interface

uses 
	 Crt
	,SysUtils
	
	,SaGeBase
	,SaGeCommonClasses
	,SaGeModel
	,SaGeScene
	,SaGeGamePhysics
	,SaGeGameNet
	,SaGeNet
	,SaGeLoading
	,SaGeFont
	,SaGeMesh
	,SaGeThreads
	,SaGeCamera
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
		class function ClassName():string;override;
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

class function TSGGameTron.ClassName():string;
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
var
	Model : TSGCustomModel;
begin
Model:=TSGCustomModel.Create();

while FLoadClass.Progress < 1 do
	begin
	FLoadClass.Progress := FLoadClass.Progress + 0.01;
	Sleep(20);
	end;
FLoadClass.Progress:=1.0001;
FState:=SGTStateStarting;
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
FLoadThread := TSGThread.Create(TSGThreadProcedure(@LoadThread),Self,False);
FLoadThread.Start();
end;

destructor TSGGameTron.Destroy();
begin
if FLoadThread<>nil then
	FLoadThread.Destroy();
if FLoadClass<>nil then
	FLoadClass.Destroy();
if FScene<>nil then
	FScene.Destroy();
inherited Destroy();
end;

end.
