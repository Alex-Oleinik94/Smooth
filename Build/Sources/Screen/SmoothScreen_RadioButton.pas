{$INCLUDE Smooth.inc}

unit SmoothScreen_RadioButton;

interface

uses
	 SmoothBase
	,SmoothScreenBase
	,SmoothBaseClasses
	,SmoothScreen
	,SmoothImage
	,SmoothScreenComponent
	;

type
	TSRCButtonType = (SNoneRadioCheckButton,SRadioButton,SCheckButton);
	TSRadioButton = class;
	TSRadioGroup = class(TSNamed)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSString; override;
			private
		FGroup : packed array of TSRadioButton;
			public
		procedure Add(const RB : TSRadioButton);
		procedure Del(const RB : TSRadioButton);
		procedure KillChecked();
		function CheckedIndex() : LongInt;
		end;
	TSRadioButton = class(TSComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSString; override;
			public
		procedure UpDate();override;
		procedure Paint(); override;
			private
		FChecked : TSBoolean;
		FGroup : TSRadioGroup;
		FType : TSRCButtonType;
		FImage : TSImage;
		FCursorOverButton : TSBoolean;
			private
		procedure DrawImage(const x,y:TSFloat);{$IFDEF SUPPORTINLINE}{$IFDEF SUPPORTINLINE}inline;{$ENDIF}{$ENDIF}
			public
		procedure SetChecked(const c : TSBoolean;const WithRec : Boolean = True);
		procedure SetCheckedTrue(const c : TSBoolean);
		procedure SetType(const t : TSRCButtonType);
			public
		property Checked : TSBoolean read FChecked write SetCheckedTrue;
		property Group : TSRadioGroup read FGroup;
		property ButtonType : TSRCButtonType read FType write SetType;
		end;

implementation

uses
	 SmoothBaseUtils
	,SmoothRenderBase
	,SmoothCommonStructs
	,SmoothCommon
	,SmoothContextUtils
	;

class function TSRadioButton.ClassName() : TSString; 
begin
Result := 'TSRadioButton';
end;

class function TSRadioGroup.ClassName() : TSString; 
begin
Result := 'TSRadioGroup';
end;

procedure TSRadioGroup.KillChecked();
var
	i : LongWord;
begin
if FGroup <> nil then if Length(FGroup)<>0 then
	begin
	for i := 0 to High(FGroup) do
		FGroup[i].SetChecked(False,False);
	end;
end;

function TSRadioGroup.CheckedIndex() : LongInt;
var
	i : LongWord;
begin
Result := -1;
if FGroup <> nil then if Length(FGroup) <> 0 then
	for i := 0 to High(FGroup) do
		if FGroup[i].Checked then
			begin
			Result := i;
			break;
			end;
end;

procedure TSRadioButton.SetType(const t : TSRCButtonType);
begin
if t <> FType then
	begin
	FType := t;
	SKill(FImage);
	FImage := SCreateImageFromFile(Context, '../Data/Textures/' + Iff(FType <> SCheckButton ,'radiobox','checkbox') + '.Sia');
	end;
end;

procedure TSRadioButton.SetCheckedTrue(const c : TSBoolean);
begin
SetChecked(c,True);
end;

procedure TSRadioButton.SetChecked(const c : TSBoolean;const WithRec : Boolean = True);
begin
if (c) then if FGroup <> nil then if WithRec then
	FGroup.KillChecked();
FChecked := c;
end;

procedure TSRadioGroup.Add(const RB : TSRadioButton);
var
	i,ii : LongWord;
begin
if FGroup = nil then
	begin
	SetLength(FGroup,1);
	FGroup[0] := RB;
	end
else if Length(FGroup) = 0 then
	begin
	SetLength(FGroup,1);
	FGroup[0] := RB;
	end
else
	begin
	ii := Length(FGroup);
	for i := 0 to High(FGroup) do
		if FGroup[i] = RB then
			begin
			ii := i;
			break;
			end;
	if ii = Length(FGroup) then
		begin
		SetLength(FGroup,Length(FGroup)+1);
		FGroup[High(FGroup)] := RB;
		end;
	end;
end;

procedure TSRadioGroup.Del(const RB : TSRadioButton);
var
	i,ii : LongWord;
begin
if FGroup <> nil then if Length(FGroup)<>0 then
	begin
	ii := Length(FGroup);
	for i := 0 to High(FGroup) do
		begin
		if FGroup[i] = RB then
			begin
			ii := i;
			break;
			end;
		end;
	if ii <> Length(FGroup) then
		begin
		for i := ii to High(FGroup)-1 do
			FGroup[i] := FGroup[i+1];
		SetLength(FGroup,Length(FGroup)-1);
		if Length(FGroup) = 0 then
			FGroup := nil;
		end;
	end;
end;

constructor TSRadioGroup.Create();
begin
inherited;
FGroup := nil;
end;

destructor TSRadioGroup.Destroy();
begin
while FGroup <> nil do
	Del(FGroup[0]);
inherited;
end;

constructor TSRadioButton.Create();
begin
inherited Create();
FInternalComponentsAllowed:=False;
FGroup := nil;
FChecked := False;
FType := SCheckButton;
FImage := nil;
FType := SNoneRadioCheckButton;
FCursorOverButton := False;
end;

destructor TSRadioButton.Destroy();
begin
if FGroup <> nil then
	FGroup.Del(Self);
if FImage <> nil then
	FImage.Destroy();
inherited;
end;

procedure TSRadioButton.UpDate();
begin
inherited;
FCursorOverButton := CursorOverComponent();
if FCursorOverButton and ((Context.CursorKeyPressed = SLeftCursorButton) and (Context.CursorKeyPressedType = SUpKey)) then
	begin
	Context.SetCursorKey(SNullKey, SNullCursorButton);
	SetChecked(not Checked, True);
	end;
end;

procedure TSRadioButton.DrawImage(const x,y:TSFloat);{$IFDEF SUPPORTINLINE}{$IFDEF SUPPORTINLINE}inline;{$ENDIF}{$ENDIF}
begin
Render.Color4f(1,1,1,FVisibleTimer);
FImage.DrawImageFromTwoVertex2fWith2TexPoint(
	SPoint2int32ToVertex3f(GetVertex([SS_LEFT,SS_TOP],S_VERTEX_FOR_MainComponent)),
	SPoint2int32ToVertex3f(GetVertex([SS_RIGHT,SS_BOTTOM],S_VERTEX_FOR_MainComponent)),
	SVertex2fImport(0,x),
	SVertex2fImport(1,y),
	True,S_2D);
end;

procedure TSRadioButton.Paint();
begin
if (not Checked) and (FImage <> nil) then
	begin
	if not FCursorOverButton then
		begin
		DrawImage(Iff(FType = SCheckButton,0.27,0.25),0.5);
		end
	else
		begin
		DrawImage(0,0.25);
		end;
	end
else
	begin
	if not FCursorOverButton then
		begin
		DrawImage(Iff(FType = SCheckButton,0.77,0.75),1);
		end
	else
		begin
		DrawImage(0.5,0.75);
		end;
	end;
FCursorOverButton := False;
inherited;
end;

end.
