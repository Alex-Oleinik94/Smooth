{$INCLUDE Includes\SaGe.inc}

unit SaGeTron;

interface

uses 
	 SaGeBase
	,SaGeContext
	,SaGeModel
	,SaGeScene
	,SaGePhisics
	,SaGeGameNet
	,SaGeNet;

type
	TSGGameTron=class(TSGDrawClass)//Это класс самой игрухи
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():string;override;
			protected
		FScene: TSGScene;
		end;

implementation

class function TSGGameTron.ClassName():string;
begin
Result := 'Трон';
end;

procedure TSGGameTron.Draw();
begin

end;

constructor TSGGameTron.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FScene := TSGScene.Create(VContext);
FScene.AddMutator(TSGPhisics2D);
(FScene.AddMutator(TSGNet) as TSGNet).ConnectionMode := SGClientMode;
//Тут у нас начинается писец...
end;

destructor TSGGameTron.Destroy();
begin
inherited Destroy();
end;

end.
