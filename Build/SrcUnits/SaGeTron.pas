{$INCLUDE Includes\SaGe.inc}
unit SaGeTron;
interface
uses 
	 SaGeBase
	,SaGeGameMesh
	,SaGeContext
	,SaGeModel;
type
	TSGGameTron=class(TSGDrawClass)//��� ����� ����� ������
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():string;override;
			protected
		end;
implementation

class function TSGGameTron.ClassName():string;
begin
Result := '����';
end;

procedure TSGGameTron.Draw();
begin

end;

constructor TSGGameTron.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
//��� � ��� ���������� �����...
end;

destructor TSGGameTron.Destroy();
begin
inherited Destroy();
end;

end.
