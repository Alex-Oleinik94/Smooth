{$IFDEF SCREEN_INTERFACE}
type
	TSGLabel = class(TSGComponent, ISGLabel)
			protected
		FTextColorSeted : TSGBoolean;
		FTextColor      : TSGColor4f;
		FTextPosition   : TSGBoolean;
			public
		procedure FromDraw;override;
		constructor Create;override;
			protected
		function  GetTextPosition() : TSGBoolean; virtual;
		procedure SetTextPosition(const VTextPosition : TSGBoolean); virtual;
		function  GetTextColor() : TSGColor4f; virtual;
		procedure SetTextColor(const VTextColor : TSGColor4f); virtual;
		function  GetTextColorSeted() : TSGBoolean; virtual;
		procedure SetTextColorSeted(const VTextColorSeted : TSGBoolean); virtual;
			public
		property TextPosition   : TSGBoolean read GetTextPosition   write SetTextPosition;
		property TextColor      : TSGColor4f read GetTextColor      write SetTextColor;
		property TextColorSeted : TSGBoolean read GetTextColorSeted write SetTextColorSeted;
		end;
{$ENDIF}

{$IFDEF SCREEN_IMPLEMENTATION}

function  TSGLabel.GetTextColor() : TSGColor4f;
begin
Result := FTextColor;
end;

procedure TSGLabel.SetTextColor(const VTextColor : TSGColor4f);
begin
FTextColor      := VTextColor;
FTextColorSeted := True;
end;

function  TSGLabel.GetTextColorSeted() : TSGBoolean;
begin
Result := FTextColorSeted;
end;

procedure TSGLabel.SetTextColorSeted(const VTextColorSeted : TSGBoolean);
begin
FTextColorSeted := VTextColorSeted;
end;

constructor TSGLabel.Create();
begin
inherited;
FTextColor.Import(1, 1, 1, 1);
FTextPosition   := True;
FTextColorSeted := False;
end;

function TSGLabel.GetTextPosition() : TSGBoolean;
begin
Result := FTextPosition;
end;

procedure TSGLabel.SetTextPosition(const VTextPosition :TSGBoolean);
begin
FTextPosition := VTextPosition;
end;

procedure TSGLabel.FromDraw();
begin
if FVisibleTimer > SGZero then
	FSkin.PaintLabel(Self);
inherited;
end;
{$ENDIF}
