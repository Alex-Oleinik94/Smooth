{$INCLUDE Includes\SaGe.inc}
unit SaGeTron;
interface
uses 
	 SaGeBase
	,SaGeGameMesh
	,SaGeContext
	,SaGeModel;
type
	TSGGameTron=class(TSGDrawClass)//Это класс самой игрухи
			public
		constructor Create();override;
		destructor Destroy();override;
			protected
		FModel:TSGGameModel;
		end;
implementation

constructor TSGGameTron.Create();
begin
inherited;
//Тут у нас начинается писец...
end;

destructor TSGGameTron.Destroy();
begin
if FModel<>nil then
	FModel.Destroy();
inherited;
end;

end.
