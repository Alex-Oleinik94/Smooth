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
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():string;override;
			protected
		FModel:TSGGameModel;
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
FModel:=nil;
//Тут у нас начинается писец...
end;

destructor TSGGameTron.Destroy();
begin
if FModel<>nil then
	FModel.Destroy();
inherited Destroy();
end;

end.
