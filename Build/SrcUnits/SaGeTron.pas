{$INCLUDE Includes\SaGe.inc}

unit SaGeTron;

interface

uses 
	 crt
	,SaGeBase
	,SaGeBased
	,SaGeContext
	,SaGeModel
	,SaGeScene
	,SaGeGamePhysics
	,SaGeGameNet
	,SaGeNet
	,SaGeLoading
	,SaGeUtils;

const
	SGTStateLoading  = $006001;
	SGTStateStarting = $006002;
	SGTStateViewing  = $006003;
type
	TSGGameTron=class(TSGDrawClass)//Это класс самой игрухи
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
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

class function TSGGameTron.ClassName():string;
begin
Result := 'Трон';
end;

procedure TSGGameTron.Draw();
begin
if (FLoadClass <> nil) then
	FLoadClass.Draw();
case FState of
SGTStateStarting:
	begin
	FScene.Start();
	FState:=SGTStateViewing;
	end;
SGTStateViewing:
	FScene.Draw();
end;
end;

procedure TSGGameTron.Load();
begin
while FLoadClass.Progress < 1 do
	begin
	FLoadClass.Progress := FLoadClass.Progress + 0.01;
	Crt.Delay(5);
	end;
FLoadClass.Progress:=1.0001;
FState:=SGTStateStarting;
end;

procedure LoadThread(VThronClass:TSGGameTron);
begin
VThronClass.Load();
end;

constructor TSGGameTron.Create(const VContext:TSGContext);
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
