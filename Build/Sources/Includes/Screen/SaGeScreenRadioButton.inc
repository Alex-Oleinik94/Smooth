{$IFDEF SCREEN_INTERFACE}
type
	TSGRCButtonType = (SGNoneRadioCheckButton,SGRadioButton,SGCheckButton);
	TSGRadioButton = class;
	TSGRadioGroup = class
			public
		constructor Create();
		destructor Destroy();override;
			private
		FGroup : packed array of TSGRadioButton;
			public
		procedure Add(const RB : TSGRadioButton);
		procedure Del(const RB : TSGRadioButton);
		procedure KillChecked();
		function CheckedIndex() : LongInt;
		end;
	TSGRadioButton = class(TSGComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromDraw;override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
			private
		FChecked : TSGBoolean;
		FGroup : TSGRadioGroup;
		FType : TSGRCButtonType;
		FImage : TSGImage;
		FCursorOnButton : TSGBoolean;
			private
		procedure DrawImage(const x,y:TSGFloat);{$IFDEF SUPPORTINLINE}{$IFDEF SUPPORTINLINE}inline;{$ENDIF}{$ENDIF}
			public
		procedure SetChecked(const c : TSGBoolean;const WithRec : Boolean = True);
		procedure SetCheckedTrue(const c : TSGBoolean);
		procedure SetType(const t : TSGRCButtonType);
			public
		property Checked : TSGBoolean read FChecked write SetCheckedTrue;
		property Group : TSGRadioGroup read FGroup;
		property ButtonType : TSGRCButtonType read FType write SetType;
		end;
{$ENDIF}

{$IFDEF SCREEN_IMPLEMENTATION}

procedure TSGRadioGroup.KillChecked();
var
	i : LongWord;
begin
if FGroup <> nil then if Length(FGroup)<>0 then
	begin
	for i := 0 to High(FGroup) do
		FGroup[i].SetChecked(False,False);
	end;
end;

function TSGRadioGroup.CheckedIndex() : LongInt;
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

procedure TSGRadioButton.SetType(const t : TSGRCButtonType);
begin
if t <> FType then
	begin
	FType := t;
	if FImage <> nil then
		FImage.Destroy();
	FImage := TSGImage.Create();
	FImage.Context := Context;
	FImage.Way := '../Data/Textures/' + Iff(FType <> SGCheckButton ,'radiobox','checkbox') + '.sgia';
	FImage.Loading();
	FImage.ToTexture();
	end;
end;

procedure TSGRadioButton.SetCheckedTrue(const c : TSGBoolean);
begin
SetChecked(c,True);
end;

procedure TSGRadioButton.SetChecked(const c : TSGBoolean;const WithRec : Boolean = True);
begin
if (c) then if FGroup <> nil then if WithRec then
	FGroup.KillChecked();
FChecked := c;
end;

procedure TSGRadioGroup.Add(const RB : TSGRadioButton);
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

procedure TSGRadioGroup.Del(const RB : TSGRadioButton);
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

constructor TSGRadioGroup.Create();
begin
FGroup := nil;
end;

destructor TSGRadioGroup.Destroy();
begin
while FGroup <> nil do
	Del(FGroup[0]);
inherited;
end;

constructor TSGRadioButton.Create();
begin
inherited Create();
FLeftShiftForChilds:=0;
FTopShiftForChilds:=0;
FRightShiftForChilds:=0;
FBottomShiftForChilds:=0;
FCanHaveChildren:=False;
FGroup := nil;
FChecked := False;
FType := SGCheckButton;
FImage := nil;
FType := SGNoneRadioCheckButton;
FCursorOnButton := False;
end;

destructor TSGRadioButton.Destroy();
begin
if FGroup <> nil then
	FGroup.Del(Self);
if FImage <> nil then
	FImage.Destroy();
inherited;
end;

procedure TSGRadioButton.FromUpDate(var FCanChange:Boolean);
begin
inherited FromUpDate(FCanChange);
end;

procedure TSGRadioButton.DrawImage(const x,y:TSGFloat);{$IFDEF SUPPORTINLINE}{$IFDEF SUPPORTINLINE}inline;{$ENDIF}{$ENDIF}
begin
Render.Color4f(1,1,1,FVisibleTimer);
FImage.DrawImageFromTwoVertex2fWith2TexPoint(
	SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
	SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
	SGVertex2fImport(0,x),
	SGVertex2fImport(1,y),
	True,SG_2D);
end;

procedure TSGRadioButton.FromDraw();
begin
if (not Checked) and (FImage <> nil) then
	begin
	if not FCursorOnButton then
		begin
		DrawImage(Iff(FType = SGCheckButton,0.27,0.25),0.5);
		end
	else
		begin
		DrawImage(0,0.25);
		end;
	end
else
	begin
	if not FCursorOnButton then
		begin
		DrawImage(Iff(FType = SGCheckButton,0.77,0.75),1);
		end
	else
		begin
		DrawImage(0.5,0.75);
		end;
	end;
FCursorOnButton := False;
inherited FromDraw();
end;

procedure TSGRadioButton.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
if CursorInComponentNow then
	begin
	FCursorOnButton := True;
	if ((Context.CursorKeyPressed = SGLeftCursorButton) and (Context.CursorKeyPressedType = SGUpKey)) and CanRePleace then
		begin
		CanRePleace:=False;
		Context.SetCursorKey(SGNullKey, SGNullCursorButton);
		SetChecked(not Checked, True);
		end
	end;
inherited FromUpDateUnderCursor(CanRePleace,CursorInComponentNow);
end;
{$ENDIF}
