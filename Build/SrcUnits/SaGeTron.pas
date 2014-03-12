{$INCLUDE Includes\SaGe.inc}

unit SaGeTron;

interface

uses 
	 crt
	 ,SaGeBase
	,SaGeContext
	,SaGeModel
	,SaGeScene
	,SaGePhisics
	,SaGeGameNet
	,SaGeNet
	,SaGeLoading
	,SaGeUtils;

type
	TSGGameTron=class(TSGDrawClass)//��� ����� ����� ������
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
Result := '����';
end;

procedure TSGGameTron.Draw();
begin
if (FLoadClass <> nil) and (FLoadClass.Progress<>1) then
	FLoadClass.Draw();
end;

procedure TSGGameTron.Load();
begin
while true do
	begin
	FLoadClass.Progress := FLoadClass.Progress + 0.01;
	Delay(1);
	end;
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
FScene.AddMutator(TSGPhisics2D);
(FScene.AddMutator(TSGNet) as TSGNet).ConnectionMode := SGClientMode;
FScene.Camera.ViewMode := SG_VIEW_FOLLOW_OBJECT;
FLoadClass := TSGLoading.Create(Context);
FLoadClass.Progress := 0;
FLoadThread := TSGThread.Create(TSGThreadProcedure(@LoadThread),Self,False);
FLoadThread.Start();
//��� � ��� ���������� �����...
end;

destructor TSGGameTron.Destroy();
begin
inherited Destroy();
end;

end.
