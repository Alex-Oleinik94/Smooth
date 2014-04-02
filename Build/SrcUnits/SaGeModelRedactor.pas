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
		FSelectMesh  : TSGInteger;
		FLastColorMesh : TSGColor4f;
			private
		procedure StartLoadForm();
		end;

implementation

procedure mmmButtonFormEsc(Button:TSGButton);
begin
with TSGModelRedactor(Button.FUserPointer1) do
	begin
	Button.Parent.Visible:=False;
	Button.Parent.Active :=False;
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
		end;
	end;
end;

procedure TSGModelRedactor.StartLoadForm();
var
	Form : TSGForm;
	EscButton , GoButton : TSGButton;
	Edit : TSGEdit;
begin

Form := TSGForm.Create();
SGScreen.CreateChild(Form);
Form.SetBounds((Context.Width - 600 ) div 2, (Context.Height - 300) div 2,600,100);
Form.Caption := 'Загрузка обьекта';
Form.FUserPointer1:=Self;

Edit := TSGEdit.Create();
Form.CreateChild(Edit);
Form.LastChild.SetBounds(5,5,575,20);
Form.LastChild.BoundsToNeedBounds();
Form.LastChild.FUserPointer1:=Self;
Form.LastChild.FUserPointer2:=Edit;
(Form.LastChild as TSGEdit).TextType:=SGEditTypeWay;
Form.LastChild.Caption:='../Temp\motobike.3ds';//SGModelsDirectory+Slash;
//(Form.LastChild as TSGEdit).TextComplite:=False;

EscButton:=TSGButton.Create();
Form.CreateChild(EscButton);
EscButton.SetBounds(375,35,100,24);
EscButton.Caption:='Отмена';
EscButton.OnChange:=TSGComponentProcedure(@mmmButtonFormEsc);
EscButton.FUserPointer1:=Self;
EscButton.FUserPointer2:=Edit;

GoButton:=TSGButton.Create();
Form.CreateChild(GoButton);
GoButton.SetBounds(485,35,100,24);
GoButton.Caption:='Загрузить';
GoButton.OnChange:=TSGComponentProcedure(@mmmButtonFormGo);
GoButton.FUserPointer1:=Self;
GoButton.FUserPointer2:=Edit;

Form.Active:=True;
Form.Visible:=True;
end;

procedure OperCBP(a,b:LongInt;ComboBox:TSGComboBox);
begin
with TSGModelRedactor(ComboBox.FUserPointer1) do
	begin
	end;
end;

constructor TSGModelRedactor.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FCustomModel := TSGCustomModel.Create();
FCustomModel.Context := Context;
FCamera := TSGCamera.Create();
FCamera.Context := Context;
FSelectMesh:=-1;
end;

destructor TSGModelRedactor.Destroy();
begin
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
	if FSelectMesh<>-1 then
		begin
		
		end;
	end;
if Context.KeyPressed and (Context.KeyPressedType=SGDownKey) and Context.KeysPressed(SG_CTRL_KEY) then
	begin
	case Context.KeyPressedByte of
	76: 
		begin
		StartLoadForm();
		end;
	Byte('1')..Byte('9'):
		begin
		if (FCustomModel.QuantityObjects-1 >= Context.KeyPressedByte-Byte('1')) then
			begin
			if FSelectMesh<>-1 then
				begin
				FCustomModel.Objects[FSelectMesh].ObjectColor:=FLastColorMesh;
				end;
			FSelectMesh := Context.KeyPressedByte-Byte('1');
			FLastColorMesh:=FCustomModel.Objects[FSelectMesh].ObjectColor;
			FCustomModel.Objects[FSelectMesh].ObjectColor:=SGColorImport(0,1,0);
			end;
		end;
	Byte('D'): if FSelectMesh<>-1 then
		begin
		FCustomModel.Dublicate(FSelectMesh);
		end;
	Byte('X'): if FSelectMesh<>-1 then
		begin
		if Context.KeysPressed(SG_SHIFT_KEY) then
			FCustomModel.Translate(FSelectMesh,SGVertexImport(0.5,0,0))
		else
			FCustomModel.Translate(FSelectMesh,SGVertexImport(-0.5,0,0));
		end;
	Byte('Y'): if FSelectMesh<>-1 then
		begin
		if Context.KeysPressed(SG_SHIFT_KEY) then
			FCustomModel.Translate(FSelectMesh,SGVertexImport(0,0.5,0))
		else
			FCustomModel.Translate(FSelectMesh,SGVertexImport(0,-0.5,0));
		end;
	Byte('Z'): if FSelectMesh<>-1 then
		begin
		if Context.KeysPressed(SG_SHIFT_KEY) then
			FCustomModel.Translate(FSelectMesh,SGVertexImport(0,0,0.5))
		else
			FCustomModel.Translate(FSelectMesh,SGVertexImport(0,0,-0.5));
		end;
	end;
	end;
end;

end.
