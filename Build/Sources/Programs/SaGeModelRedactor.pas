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
		FSelectMesh  : TSGInt64;
		FLastColorMesh : TSGColor4f;
		
		FSun : TSGVertex3f;
		FSunAngle : TSGSingle;
			private
		procedure StartLoadForm();
			public
		function LoadFromStream(const Stream : TStream; const FileName : TSGString = '') : TSGBoolean;
		function LoadFromFile(const FileName : TSGString) : TSGBoolean;
		procedure LoadToVBO();
		end;

implementation

uses
	 SaGeFileUtils
	,SaGeSysUtils
	,SaGeLog
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
	Suc : TSGBoolean = False;
begin
if not TSGEdit(Button.FUserPointer2).TextComplite then
	Exit;
with TSGModelRedactor(Button.FUserPointer1) do
	begin
	Suc := LoadFromFile(TSGEdit(Button.FUserPointer2).Caption);
	
	if Suc then
		begin
		LoadToVBO();
		Button.Parent.Visible:=False;
		Button.Parent.Active :=False;
		end;
	end;
end;

procedure TSGModelRedactor.LoadToVBO();
begin
try
FCustomModel.LoadToVBO();
except on e : Exception do
	SGLogException('TSGModelRedactor__LoadToVBO(). Raised exception', e);
end;
end;

function TSGModelRedactor.LoadFromStream(const Stream : TStream; const FileName : TSGString = '') : TSGBoolean;

function ObjectCount() : TSGUInt64;
begin
Result := FCustomModel.QuantityObjects + FCustomModel.QuantityMaterials;
end;

var
	OldObjectsCount : TSGUInt64 = 0;
begin
Result := False;
try
	if SGFileExpansion(FileName) = '3DS' then
		Result := FCustomModel.Load3DSFromStream(Stream, FileName)
	else if SGFileExpansion(FileName) = 'OBJ' then
		begin
		OldObjectsCount := ObjectCount();
		FCustomModel.AddObject().LoadFromOBJ(FileName);
		Result := ObjectCount() > OldObjectsCount;
		end
	else
		begin
		OldObjectsCount := ObjectCount();
		FCustomModel.LoadFromSG3DM(Stream);
		Result := ObjectCount() > OldObjectsCount;
		end;
except on e : Exception do
	SGLogException('TSGModelRedactor__LoadFromStream(). Raised exception', e);
end;
end;

function TSGModelRedactor.LoadFromFile(const FileName : TSGString) : TSGBoolean;
var
	Stream : TMemoryStream = nil;
begin
Result := False;
try
	Stream := TMemoryStream.Create();
	SGResourceFiles.LoadMemoryStreamFromFile(Stream, FileName);
	Stream.Position := 0;
	Result := LoadFromStream(Stream, FileName);
	Stream.Destroy();
except on e : Exception do
	SGLogException('TSGModelRedactor__LoadFromFile(). Raised exception', e);
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
Form.Caption := 'Загрузка обьекта';
Form.FUserPointer1:=Self;

Edit := TSGEdit.Create();
Form.CreateChild(Edit);
Form.LastChild.SetBounds(5,5,575,20);
Form.LastChild.BoundsToNeedBounds();
Form.LastChild.FUserPointer1:=Self;
Form.LastChild.FUserPointer2:=Edit;
(Form.LastChild as TSGEdit).TextType:=SGEditTypePath;
Form.LastChild.Caption:='./../data\tron/motoBike.3ds';//SGModelsDirectory+Slash;
(Form.LastChild as TSGEdit).TextComplite:=TSGEditTextTypeFunctionWay(Form.LastChild as TSGEdit);

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

constructor TSGModelRedactor.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FSunAngle := 0;
FCustomModel := TSGCustomModel.Create();
FCustomModel.Context := Context;
FCamera := TSGCamera.Create();
FCamera.Context := Context;
FSelectMesh := -1;
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

procedure TSGModelRedactor.Paint();
var
	i : TSGLongWord;
begin
if FCustomModel <> nil then
	begin
	FCamera.CallAction();
	
	FSunAngle += Context.ElapsedTime * 0.005;
	FSun.Import(cos(FSunAngle), sin(FSunAngle), cos(FSunAngle * 1.5));
	FSun *= 7;
	
	Render.Color3f(1, 1, 1);
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
	Byte('O') :
		StartLoadForm();
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
