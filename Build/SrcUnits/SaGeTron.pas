{$INCLUDE Includes\SaGe.inc}

unit SaGeTron;

interface

uses 
	 crt
	,SaGeBase
	,SaGeContext
	,SaGeModel
	,SaGeScene
	,SaGeGamePhysics
	,SaGeGameNet
	,SaGeNet
	,SaGeLoading
	,SaGeUtils;

type
	TSGGameTron=class(TSGDrawClass)//Это класс самой игрухи
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():string;override;
			protected
		FScene: TSGScene;
		FLoadThread : TSGThread;
		FLoadClass  : TSGLoading;
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
if (FScene<>nil) then
	FScene.Draw();
end;

procedure TSGGameTron.Load();
begin
while FLoadClass.Progress < 1 do
	begin
	FLoadClass.Progress := FLoadClass.Progress + 0.01;
	Crt.Delay(1);
	end;
FLoadClass.Progress:=1.0001;
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
FScene := TSGScene.Create(VContext);
FScene.AddMutator(TSGPhysics3D);
(FScene.AddMutator(TSGNet) as TSGNet).ConnectionMode := SGClientMode;
FScene.Camera.ViewMode := SG_VIEW_FOLLOW_OBJECT;
FLoadClass := TSGLoading.Create(Context);
FLoadClass.Progress := 0;
FLoadThread := TSGThread.Create(TSGThreadProcedure(@LoadThread),Self,False);
FLoadThread.Start();
//Тут у нас начинается писец...
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
