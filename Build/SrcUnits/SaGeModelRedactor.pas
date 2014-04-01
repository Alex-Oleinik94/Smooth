{$INCLUDE Includes\SaGe.inc}

unit SaGeModelRedactor;

interface
uses
	crt
	,SaGeBase
	,SaGeBased
	,SaGeCommon
	,SysUtils
	,SaGeUtils
	,SaGeRender
	,SaGeContext
	,SaGeMesh
	,SaGeScreen
	;
type
	TSGModelRedactor=class(TSGDrawClass)
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
		procedure Draw();override;
			private
		FCamera      : TSGCamera;
		FCustomModel : TSGCustomModel;
		
		FOperatingComboCox : TSGComboBox;
		end;

implementation

procedure mmmButtonFormEsc(Button:TSGButton);
begin
with TSGModelRedactor(Button.FUserPointer1) do
	begin
	Button.Parent.Visible:=False;
	Button.Parent.Active :=False;
	FOperatingComboCox.Active:=True;
	end;
end;

procedure OperCBP(a,b:LongInt;ComboBox:TSGComboBox);
var
	Form : TSGForm;
	EscButton , GoButton : TSGButton;
begin
with TSGModelRedactor(ComboBox.FUserPointer1) do
	begin
	case b of
	1 : // Загрузка
		begin
		
		Form := TSGForm.Create();
		SGScreen.CreateChild(Form);
		Form.SetBounds((Context.Width - 600 ) div 2, (Context.Height - 300) div 2,600,300);
		Form.Caption := 'Загрузка обьекта';
		Form.FUserPointer1:=ComboBox.FUserPointer1;
		
		EscButton:=TSGButton.Create();
		Form.CreateChild(EscButton);
		EscButton.SetBounds(375,235,100,24);
		EscButton.Caption:='Отмена';
		EscButton.OnChange:=TSGComponentProcedure(@mmmButtonFormEsc);
		EscButton.FUserPointer1:=ComboBox.FUserPointer1;
		
		GoButton:=TSGButton.Create();
		Form.CreateChild(GoButton);
		GoButton.SetBounds(485,235,100,24);
		GoButton.Caption:='Загрузить';
		GoButton.FUserPointer1:=ComboBox.FUserPointer1;
		
		Form.Active:=True;
		Form.Visible:=True;
		
		ComboBox.Active:=False;
		end;
	end;
	end;
end;

constructor TSGModelRedactor.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FCustomModel := TSGCustomModel.Create();
FCustomModel.Context := Context;
FCamera := TSGCamera.Create();
FCamera.Context := Context;

FOperatingComboCox:=TSGComboBox.Create();
SGScreen.CreateChild(FOperatingComboCox);
SGScreen.LastChild.SetBounds(Context.Width-50-125+45-50,5,120+50,20);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.AsComboBox.CreateItem('Выберете что делать');
SGScreen.LastChild.AsComboBox.CreateItem('Загрузить');
SGScreen.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@OperCBP);
FOperatingComboCox.FSelectItem:=0;
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Active := True;
SGScreen.LastChild.Visible := True;
end;

destructor TSGModelRedactor.Destroy();
begin
if FOperatingComboCox<>nil then
	FOperatingComboCox.Destroy();
if FCustomModel<>nil then
	FCustomModel.Destroy();
if FCamera<>nil then
	FCamera.Destroy();
inherited;
end;

class function TSGModelRedactor.ClassName():TSGString;
begin
Result:='Редактор моделей';
end;

procedure TSGModelRedactor.Draw();
begin
if FCustomModel<>nil then
	begin
	FCamera.CallAction();
	FCustomModel.Draw();
	end;
if FOperatingComboCox<>nil then
	FOperatingComboCox.FSelectItem:=0;
end;

end.
