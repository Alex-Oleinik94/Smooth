{$INCLUDE SaGe.inc}

unit SaGeModelRedactor;

interface
uses
	 Crt
	,Classes
	,SysUtils
	
	,SaGeBase
	,SaGeCommon
	,SaGeFont
	,SaGeRenderBase
	,SaGeCommonClasses
	,SaGeContext
	,SaGeMesh
	,SaGeScreen
	,SaGeResourceManager
	,SaGeCamera
	;
type
	TSGModelRedactor=class(TSGScreenedDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
		procedure Paint();override;
			private
		FCamera      : TSGCamera;
		FCustomModel : TSGCustomModel;
		FSelectMesh  : TSGInteger;
		FLastColorMesh : TSGColor4f;
		
		FSun : TSGVertex3f;
		FSunAngle : TSGSingle;
			private
		procedure StartLoadForm();
		end;

implementation

uses
	 SaGeFileUtils
	;

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
	SGResourceFiles.LoadMemoryStreamFromFile(Stream,TSGEdit(Button.FUserPointer2).Caption);
	Stream.Position:=0;
	if SGFileExpansion(TSGEdit(Button.FUserPointer2).Caption)='3DS' then
		Suc:=FCustomModel.Load3DSFromStream(Stream,TSGEdit(Button.FUserPointer2).Caption)
	else
		if SGFileExpansion(TSGEdit(Button.FUserPointer2).Caption)='OBJ' then
			begin
			FCustomModel.AddObject().LoadFromOBJ(TSGEdit(Button.FUserPointer2).Caption);
			end
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
Screen.CreateChild(Form);
Form.SetBounds((Context.Width - 600 ) div 2, (Context.Height - 300) div 2,600,100);
Form.Caption := '�������� �������';
Form.FUserPointer1:=Self;

Edit := TSGEdit.Create();
Form.CreateChild(Edit);
Form.LastChild.SetBounds(5,5,575,20);
Form.LastChild.BoundsToNeedBounds();
Form.LastChild.FUserPointer1:=Self;
Form.LastChild.FUserPointer2:=Edit;
(Form.LastChild as TSGEdit).TextType:=SGEditTypePath;
Form.LastChild.Caption:='./../Temp/motoBike.3dss';//SGModelsDirectory+Slash;
(Form.LastChild as TSGEdit).TextComplite:=TSGEditTextTypeFunctionWay((Form.LastChild as TSGEdit));

EscButton:=TSGButton.Create();
Form.CreateChild(EscButton);
EscButton.SetBounds(375,35,100,24);
EscButton.Caption:='������';
EscButton.OnChange:=TSGComponentProcedure(@mmmButtonFormEsc);
EscButton.FUserPointer1:=Self;
EscButton.FUserPointer2:=Edit;

GoButton:=TSGButton.Create();
Form.CreateChild(GoButton);
GoButton.SetBounds(485,35,100,24);
GoButton.Caption:='���������';
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

constructor TSGModelRedactor.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FSunAngle := 0;
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
Result:='�������� �������';
end;

procedure TSGModelRedactor.Paint();
var
	i : TSGLongWord;
begin
if FCustomModel<>nil then
	begin
	FCamera.CallAction();
	
	FSunAngle += Context.ElapsedTime*0.005;
	FSun.Import(cos(FSunAngle),sin(FSunAngle),cos(FSunAngle*1.5));
	FSun *= 7;
	
	Render.Color3f(1,1,1);
	Render.BeginScene(SGR_POINTS);
	Render.Vertex(FSun);
	Render.EndScene();
	
	Render.Disable(SGR_BLEND);
	Render.Enable(SGR_LIGHTING);
	Render.Enable(SGR_LIGHT0);
	Render.Lightfv(SGR_LIGHT0,SGR_POSITION,@FSun);
	Render.BeginBumpMapping(@FSun);
	
	FCustomModel.Paint();
	
	Render.EndBumpMapping();
	Render.Enable(SGR_BLEND);
	Render.Disable(SGR_LIGHTING);
	Render.Disable(SGR_LIGHT0);
	if FSelectMesh<>-1 then
		begin
		Render.PushMatrix();
		Render.MultMatrixf(FCustomModel.ObjectMatrix[FSelectMesh]);
		
		Render.PopMatrix();
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
			FCustomModel.Objects[FSelectMesh].ObjectColor:=SGVertex4fImport(0,1,0);
			end;
		end;
	Byte('D'): if FSelectMesh<>-1 then
		begin
		FCustomModel.Dublicate(FSelectMesh);
		end;
	Byte('X'): if FSelectMesh<>-1 then
		begin
		if Context.KeysPressed(SG_SHIFT_KEY) then
			FCustomModel.Translate(FSelectMesh,SGVertex3fImport(0.5,0,0))
		else
			FCustomModel.Translate(FSelectMesh,SGVertex3fImport(-0.5,0,0));
		end;
	Byte('Y'): if FSelectMesh<>-1 then
		begin
		if Context.KeysPressed(SG_SHIFT_KEY) then
			FCustomModel.Translate(FSelectMesh,SGVertex3fImport(0,0.5,0))
		else
			FCustomModel.Translate(FSelectMesh,SGVertex3fImport(0,-0.5,0));
		end;
	Byte('Z'): if FSelectMesh<>-1 then
		begin
		if Context.KeysPressed(SG_SHIFT_KEY) then
			FCustomModel.Translate(FSelectMesh,SGVertex3fImport(0,0,0.5))
		else
			FCustomModel.Translate(FSelectMesh,SGVertex3fImport(0,0,-0.5));
		end;
	Byte('I'): if FCustomModel<>nil then
		FCustomModel.WriteInfo();
	end;
	end;
end;

end.
