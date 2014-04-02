{$INCLUDE Includes\SaGe.inc}

unit SaGeModelRedactor;

interface
uses
	crt
	,Classes
	,SaGeBase
	,SaGeBased
	,SaGeCommon
	,SysUtils
	,SaGeUtils
	,SaGeRender
	,SaGeContext
	,SaGeMesh
	,SaGeScreen
	,SaGeResourseManager
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

procedure mmmButtonFormGo(Button:TSGButton);
var
	Stream : TMemoryStream = nil;
	Suc : TSGBoolean = False;
begin
if not TSGEdit(Button.FUserPointer2).TextComplite then
	Exit;
with TSGModelRedactor(Button.FUserPointer1) do
	begin
	Stream := TMemoryStream.Create();
	SGResourseFiles.LoadMemoryStreamFromFile(Stream,TSGEdit(Button.FUserPointer2).Caption);
	Stream.Position:=0;
	if SGGetFileExpansion(TSGEdit(Button.FUserPointer2).Caption)='3DS' then
		Suc:=FCustomModel.Load3DSFromStream(Stream,TSGEdit(Button.FUserPointer2).Caption)
	else
		begin
		FCustomModel.LoadFromSG3DM(Stream);
		Suc:=FCustomModel.QuantityObjects+FCustomModel.QuantityMaterials<>0;
		end;
	Stream.Destroy();
	
	if Suc then
		begin
		FCustomModel.LoadToVBO();
		Button.Parent.Visible:=False;
		Button.Parent.Active :=False;
		FOperatingComboCox.Active:=True;
		end;
	end;
end;

procedure OperCBP(a,b:LongInt;ComboBox:TSGComboBox);
var
	Form : TSGForm;
	EscButton , GoButton : TSGButton;
	Edit : TSGEdit;
begin
with TSGModelRedactor(ComboBox.FUserPointer1) do
	begin
	case b of
	1 : // Загрузка
		begin
		
		Form := TSGForm.Create();
		SGScreen.CreateChild(Form);
		Form.SetBounds((Context.Width - 600 ) div 2, (Context.Height - 300) div 2,600,100);
		Form.Caption := 'Загрузка обьекта';
		Form.FUserPointer1:=ComboBox.FUserPointer1;
		
		Edit := TSGEdit.Create();
		Form.CreateChild(Edit);
		Form.LastChild.SetBounds(5,5,575,20);
		Form.LastChild.BoundsToNeedBounds();
		Form.LastChild.FUserPointer1:=ComboBox.FUserPointer1;
		Form.LastChild.FUserPointer2:=Edit;
		(Form.LastChild as TSGEdit).TextType:=SGEditTypeWay;
		Form.LastChild.Caption:='../Temp\motobike.3dss';//SGModelsDirectory+Slash;
		//(Form.LastChild as TSGEdit).TextComplite:=False;
		
		EscButton:=TSGButton.Create();
		Form.CreateChild(EscButton);
		EscButton.SetBounds(375,35,100,24);
		EscButton.Caption:='Отмена';
		EscButton.OnChange:=TSGComponentProcedure(@mmmButtonFormEsc);
		EscButton.FUserPointer1:=ComboBox.FUserPointer1;
		EscButton.FUserPointer2:=Edit;
		
		GoButton:=TSGButton.Create();
		Form.CreateChild(GoButton);
		GoButton.SetBounds(485,35,100,24);
		GoButton.Caption:='Загрузить';
		GoButton.OnChange:=TSGComponentProcedure(@mmmButtonFormGo);
		GoButton.FUserPointer1:=ComboBox.FUserPointer1;
		GoButton.FUserPointer2:=Edit;
		
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
