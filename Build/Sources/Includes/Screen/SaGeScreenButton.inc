{$IFDEF SCREEN_INTERFACE}
type
	TSGButton = class(TSGClickComponent, ISGButton)
			public
		constructor Create;override;
		destructor Destroy;override;
			protected
		FCursorOnButtonTimer : TSGScreenTimer;
		FCursorOnButtonPrev  : TSGBoolean;
		FCursorOnButton      : TSGBoolean;
		FChangingButton      : TSGBoolean;
		FChangingButtonTimer : TSGScreenTimer;
			public
		function CursorInComponentCaption():boolean;override;
		procedure FromUpDateCaptionUnderCursor(var CanRePleace:Boolean);override;
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		procedure FromDraw;override;
		end;
{$ENDIF}

{$IFDEF SCREEN_IMPLEMENTATION}

procedure TSGButton.FromUpDate(var FCanChange:Boolean);
begin
if not Active then
	begin 
	FCursorOnComponent := False;
	FCursorOnButton    := False;
	FChangingButton    := False;
	end;
if FCursorOnButton and ReqursiveActive and Visible then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle <> SGC_HAND)) then
		Context.Cursor := TSGCursor.Create(SGC_HAND);
if FCursorOnButtonPrev and (not FCursorOnButton) then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle = SGC_HAND)) then
	Context.Cursor := TSGCursor.Create(SGC_NORMAL);
FCursorOnButtonPrev := FCursorOnComponent;
UpgradeTimer(FCursorOnButton,FCursorOnButtonTimer,3,2);
UpgradeTimer(FChangingButton,FChangingButtonTimer,5,2);
inherited FromUpDate(FCanChange);
end;

procedure TSGButton.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
FCursorOnButton     := CursorInComponentNow;
if CursorInComponentNow then
	begin
	if Active and ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) then
		begin
		if (OnChange<>nil) then
			OnChange(Self);
		FChangingButtonTimer:=1;
		end;
	end;
inherited FromUpDateUnderCursor(CanRePleace,CursorInComponentNow);
end;

procedure TSGButton.FromDraw;
begin
if (FVisible) or (FVisibleTimer > SGZero) then
	begin
	FSkin.PaintButton(Self);
	end;
FCursorOnButton:=False;
FChangingButton:=False;
FClick := False;
inherited FromDraw;
end;

procedure TSGButton.FromUpDateCaptionUnderCursor(var CanRePleace:Boolean);
begin
end;

function TSGButton.CursorInComponentCaption():boolean;
begin
Result:=False;
end;

constructor TSGButton.Create();
begin
inherited Create();
FLeftShiftForChilds   := 0;
FTopShiftForChilds    := 0;
FRightShiftForChilds  := 0;
FBottomShiftForChilds := 0;
FCanHaveChildren      := False;
FCursorOnButtonPrev   := False;
FCursorOnButton       := False;
end;

destructor TSGButton.Destroy();
begin
inherited Destroy();
end;
{$ENDIF}
