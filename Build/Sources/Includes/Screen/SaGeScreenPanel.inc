{$IFDEF SCREEN_INTERFACE}
type
	TSGPanel = class(TSGComponent, ISGPanel)
			public
		constructor Create;override;
		destructor Destroy;override;
			protected
		FViewLines : TSGBoolean;
		FViewQuad  : TSGBoolean;
		function ViewingLines() : TSGBoolean; virtual;
		function ViewingQuad()  : TSGBoolean;  virtual;
			public
		procedure FromDraw;override;
			public
		property ViewQuad  : TSGBoolean read ViewingQuad  write FViewQuad;
		property ViewLines : TSGBoolean read ViewingLines write FViewLines;
		end;
{$ENDIF}

{$IFDEF SCREEN_IMPLEMENTATION}
function TSGPanel.ViewingLines() : TSGBoolean;
begin
Result := ViewingLines;
end;

function TSGPanel.ViewingQuad() : TSGBoolean;
begin
Result := ViewingQuad;
end;

procedure TSGPanel.FromDraw;
begin
if (FVisible) or (FVisibleTimer > SGZero) then
	begin
	FSkin.PaintPanel(Self);
	end;
inherited;
end;

constructor TSGPanel.Create;
begin
inherited;
FViewLines := True;
FViewQuad  := True;
end;

destructor TSGPanel.Destroy;
begin
inherited;
end;
{$ENDIF}
