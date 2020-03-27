{$INCLUDE Smooth.inc}

unit SmoothModelRedactor;

interface
uses
	 Crt
	,Classes
	,SysUtils
	
	,SmoothBase
	,SmoothCommonStructs
	,SmoothFont
	,SmoothRenderBase
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothContext
	,Smooth3dObject
	,SmoothResourceManager
	,SmoothCamera
	;
type
	TSModelRedactor = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
		procedure Paint();override;
			private
		FCamera      : TSCamera;
		FCustomModel : TSCustomModel;
		FSelect3dObject  : TSInt64;
		FLastColor3dObject : TSColor4f;
		
		FSun : TSVertex3f;
		FSunAngle : TSSingle;
			private
		procedure StartLoadForm();
			public
		function LoadFromStream(const Stream : TStream; const FileName : TSString = '') : TSBoolean;
		function LoadFromFile(const FileName : TSString) : TSBoolean;
		procedure LoadToVBO();
		end;

implementation

uses
	 SmoothFileUtils
	,SmoothSysUtils
	,SmoothLog
	,SmoothStringUtils
	,Smooth3dObjectLoader
	,SmoothContextUtils
	,SmoothScreenClasses
	;

procedure ModelRedactorButtonFormEsc(Button : TSScreenButton);
begin
with TSModelRedactor(Button.FUserPointer1) do
	begin
	Button.Parent.Visible:=False;
	Button.Parent.Active :=False;
	end;
end;

procedure ModelRedactorButtonFormGo(Button : TSScreenButton);
var
	Suc : TSBoolean = False;
begin
if not TSScreenEdit(Button.FUserPointer2).TextComplite then
	Exit;
with TSModelRedactor(Button.FUserPointer1) do
	begin
	Suc := LoadFromFile(TSScreenEdit(Button.FUserPointer2).Caption);
	
	if Suc then
		begin
		LoadToVBO();
		Button.Parent.Visible:=False;
		Button.Parent.Active :=False;
		end;
	end;
end;

procedure TSModelRedactor.LoadToVBO();
begin
try
FCustomModel.LoadToVBO();
except on e : Exception do
	SLogException('TSModelRedactor__LoadToVBO(). Raised exception', e);
end;
end;

function TSModelRedactor.LoadFromStream(const Stream : TStream; const FileName : TSString = '') : TSBoolean;

function ObjectCount() : TSUInt64;
begin
Result := FCustomModel.QuantityObjects + FCustomModel.QuantityMaterials;
end;

var
	Expansion : TSString = '';
	OldObjectsCount : TSUInt64 = 0;
begin
Result := False;
Expansion := SUpCaseString(SFileExpansion(FileName));
try
	if Expansion = '3DS' then
		Result := SLoad3dObject3DS(FCustomModel, Stream, FileName)
	else if Expansion = 'OBJ' then
		Result := SLoad3dObject3DS(FCustomModel, FileName)
	else
		begin
		OldObjectsCount := ObjectCount();
		SLoad3dObjectS3DM(FCustomModel, FileName);
		Result := ObjectCount() > OldObjectsCount;
		end;
except on e : Exception do
	SLogException('TSModelRedactor__LoadFromStream(). Raised exception', e);
end;
end;

function TSModelRedactor.LoadFromFile(const FileName : TSString) : TSBoolean;
var
	Stream : TMemoryStream = nil;
begin
Result := False;
try
	Stream := TMemoryStream.Create();
	SResourceFiles.LoadMemoryStreamFromFile(Stream, FileName);
	Stream.Position := 0;
	Result := LoadFromStream(Stream, FileName);
	Stream.Destroy();
except on e : Exception do
	SLogException('TSModelRedactor__LoadFromFile(). Raised exception', e);
end;
end;

procedure TSModelRedactor.StartLoadForm();
var
	Form : TSScreenForm;
	EscButton , GoButton : TSScreenButton;
	Edit : TSScreenEdit;
begin
Form := TSScreenForm.Create();
Screen.CreateChild(Form);
Form.SetBounds((Context.Width - 600 ) div 2, (Context.Height - 300) div 2,600,100);
Form.Caption := 'Загрузка обьекта';
Form.FUserPointer1:=Self;

Edit := SCreateEdit(Form, './../data\tron/motoBike.3ds' {SModelsDirectory+Slash}, SScreenEditTypePath,
	5,5,575,20, [], False, True, Self);
Edit.FUserPointer2:=Edit;

EscButton:=TSScreenButton.Create();
Form.CreateChild(EscButton);
EscButton.SetBounds(375,35,100,24);
EscButton.Caption:='Отмена';
EscButton.OnChange:=TSScreenComponentProcedure(@ModelRedactorButtonFormEsc);
EscButton.FUserPointer1:=Self;
EscButton.FUserPointer2:=Edit;

GoButton:=TSScreenButton.Create();
Form.CreateChild(GoButton);
GoButton.SetBounds(485,35,100,24);
GoButton.Caption:='Загрузить';
GoButton.OnChange:=TSScreenComponentProcedure(@ModelRedactorButtonFormGo);
GoButton.FUserPointer1:=Self;
GoButton.FUserPointer2:=Edit;

Form.Active:=True;
Form.Visible:=True;
end;

procedure OperCBP(a,b:LongInt;ComboBox:TSScreenComboBox);
begin
with TSModelRedactor(ComboBox.FUserPointer1) do
	begin
	end;
end;

constructor TSModelRedactor.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FSunAngle := 0;
FCustomModel := TSCustomModel.Create();
FCustomModel.Context := Context;
FCamera := TSCamera.Create();
FCamera.Context := Context;
FSelect3dObject := -1;
end;

destructor TSModelRedactor.Destroy();
begin
if FCustomModel<>nil then
	FCustomModel.Destroy();
if FCamera<>nil then
	FCamera.Destroy();
inherited;
end;

class function TSModelRedactor.ClassName():TSString;
begin
Result:='Редактор моделей';
end;

procedure TSModelRedactor.Paint();
var
	i : TSLongWord;
begin
if FCustomModel <> nil then
	begin
	FCamera.CallAction();
	
	FSunAngle += Context.ElapsedTime * 0.005;
	FSun.Import(cos(FSunAngle), sin(FSunAngle), cos(FSunAngle * 1.5));
	FSun *= 7;
	
	Render.Color3f(1, 1, 1);
	Render.BeginScene(SR_POINTS);
	Render.Vertex(FSun);
	Render.EndScene();
	
	Render.Disable(SR_BLEND);
	Render.Enable(SR_LIGHTING);
	Render.Enable(SR_LIGHT0);
	Render.Lightfv(SR_LIGHT0, SR_POSITION, @FSun);
	
	//Render.BeginBumpMapping(@FSun);
	Render.Color3f(1, 1, 1);
	
	FCustomModel.Paint();
	
	//Render.EndBumpMapping();
	
	Render.Enable(SR_BLEND);
	Render.Disable(SR_LIGHTING);
	Render.Disable(SR_LIGHT0);
	if FSelect3dObject<>-1 then
		begin
		Render.PushMatrix();
		Render.MultMatrixf(FCustomModel.ObjectMatrix[FSelect3dObject]);
		
		Render.PopMatrix();
		end;
	end;
if Context.KeyPressed and (Context.KeyPressedType=SDownKey) and Context.KeysPressed(S_CTRL_KEY) then
	begin
	case Context.KeyPressedByte of
	Byte('O') :
		StartLoadForm();
	Byte('1')..Byte('9'):
		begin
		if (FCustomModel.QuantityObjects-1 >= Context.KeyPressedByte-Byte('1')) then
			begin
			if FSelect3dObject<>-1 then
				begin
				FCustomModel.Objects[FSelect3dObject].ObjectColor:=FLastColor3dObject;
				end;
			FSelect3dObject := Context.KeyPressedByte-Byte('1');
			FLastColor3dObject:=FCustomModel.Objects[FSelect3dObject].ObjectColor;
			FCustomModel.Objects[FSelect3dObject].ObjectColor:=SVertex4fImport(0,1,0);
			end;
		end;
	Byte('D'): if FSelect3dObject<>-1 then
		begin
		FCustomModel.Dublicate(FSelect3dObject);
		end;
	Byte('X'): if FSelect3dObject<>-1 then
		begin
		if Context.KeysPressed(S_SHIFT_KEY) then
			FCustomModel.Translate(FSelect3dObject,SVertex3fImport(0.5,0,0))
		else
			FCustomModel.Translate(FSelect3dObject,SVertex3fImport(-0.5,0,0));
		end;
	Byte('Y'): if FSelect3dObject<>-1 then
		begin
		if Context.KeysPressed(S_SHIFT_KEY) then
			FCustomModel.Translate(FSelect3dObject,SVertex3fImport(0,0.5,0))
		else
			FCustomModel.Translate(FSelect3dObject,SVertex3fImport(0,-0.5,0));
		end;
	Byte('Z'): if FSelect3dObject<>-1 then
		begin
		if Context.KeysPressed(S_SHIFT_KEY) then
			FCustomModel.Translate(FSelect3dObject,SVertex3fImport(0,0,0.5))
		else
			FCustomModel.Translate(FSelect3dObject,SVertex3fImport(0,0,-0.5));
		end;
	Byte('I'): if FCustomModel<>nil then
		FCustomModel.WriteInfo();
	end;
	end;
end;

end.
