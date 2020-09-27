{$INCLUDE Smooth.inc}

unit SmoothScreen_Button;

interface

uses
	 SmoothBase
	,SmoothScreenBase
	,SmoothScreenCommonComponents
	,SmoothScreenComponentInterfaces
	;

type
	TSButton = class(TSClickComponent, ISButton)
			public
		constructor Create;override;
		destructor Destroy;override;
		class function ClassName() : TSString; override;
			public
		procedure UpDate();override;
		procedure Paint(); override;
			protected
		procedure StartCallBack(); virtual;
		end;

implementation

uses
	 SmoothMathUtils
	,SmoothCursor
	,SmoothContextUtils
	;

procedure TSButton.StartCallBack();
begin
if (OnChange <> nil) then
	OnChange(Self);
end;

class function TSButton.ClassName() : TSString; 
begin
Result := 'TSButton';
end;

procedure TSButton.UpDate();
begin
if UpdateAvailable() and (Context.CursorKeyPressed=SLeftCursorButton) then
	begin
	if (Context.CursorKeyPressedType=SDownKey) then
		begin
		FDownMouseClick := True;
		Context.SetCursorKey(SNullKey, SNullCursorButton);
		end
	else if (Context.CursorKeyPressedType=SUpKey) and FDownMouseClick then
		begin
		FDownMouseClick := False;
		Context.SetCursorKey(SNullKey, SNullCursorButton);
		StartCallBack();
		end;
	end
else if FDownMouseClick and ((not Active) or (not Visible) or (not (Context.CursorKeyPressed = SNullCursorButton))) then
	FDownMouseClick := False;
if CursorOver and ReqursiveActive and Visible then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle <> SC_HAND)) then
		Context.Cursor := TSCursor.Create(SC_HAND);
if PreviousCursorOver and (not CursorOver) then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle = SC_HAND)) then
		Context.Cursor := TSCursor.Create(SC_NORMAL);
inherited;
end;

procedure TSButton.Paint();
begin
if (FVisible) or (FVisibleTimer > SZero) then
	FSkin.PaintButton(Self);
inherited;
end;

constructor TSButton.Create();
begin
inherited;
FInternalComponentsAllowed    := False;
end;

destructor TSButton.Destroy();
begin
inherited Destroy();
end;

end.
