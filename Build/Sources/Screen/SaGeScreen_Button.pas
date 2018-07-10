{$INCLUDE SaGe.inc}

unit SaGeScreen_Button;

interface

uses
	 SaGeBase
	,SaGeScreenBase
	,SaGeScreenCommonComponents
	,SaGeScreenComponentInterfaces
	;

type
	TSGButton = class(TSGClickComponent, ISGButton)
			public
		constructor Create;override;
		destructor Destroy;override;
		class function ClassName() : TSGString; override;
			protected
		FChangingButton      : TSGBoolean;
		FChangingButtonTimer : TSGScreenTimer;
			public
		procedure UpDate();override;
		procedure Paint(); override;
		end;

implementation

uses
	 SaGeMathUtils
	,SaGeCursor
	,SaGeContextUtils
	;

class function TSGButton.ClassName() : TSGString; 
begin
Result := 'TSGButton';
end;

procedure TSGButton.UpDate();
begin
inherited;
if CursorOver then
	begin
	if Active and ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) then
		begin
		if (OnChange<>nil) then
			OnChange(Self);
		FChangingButtonTimer:=1;
		end;
	end;
if not Active then
	FChangingButton    := False;
if CursorOver and ReqursiveActive and Visible then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle <> SGC_HAND)) then
		Context.Cursor := TSGCursor.Create(SGC_HAND);
if PreviousCursorOver and (not CursorOver) then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle = SGC_HAND)) then
	Context.Cursor := TSGCursor.Create(SGC_NORMAL);
UpgradeTimer(FChangingButton, FChangingButtonTimer, 5, 2);
end;

procedure TSGButton.Paint();
begin
if (FVisible) or (FVisibleTimer > SGZero) then
	FSkin.PaintButton(Self);
FChangingButton:=False;
FClick := False;
inherited;
end;

constructor TSGButton.Create();
begin
inherited Create();
FCanHaveChildren    := False;
end;

destructor TSGButton.Destroy();
begin
inherited Destroy();
end;

end.
