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
			public
		procedure UpDate();override;
		procedure Paint(); override;
			protected
		procedure Click(); virtual;
		end;

implementation

uses
	 SaGeMathUtils
	,SaGeCursor
	,SaGeContextUtils
	;

procedure TSGButton.Click();
begin
if (OnChange <> nil) then
	OnChange(Self);
end;

class function TSGButton.ClassName() : TSGString; 
begin
Result := 'TSGButton';
end;

procedure TSGButton.UpDate();
begin
if CursorOver and Active and Visible and ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) then
	begin
	Click();
	Context.SetCursorKey(SGNullKey, SGNullCursorButton);
	end;
if CursorOver and ReqursiveActive and Visible then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle <> SGC_HAND)) then
		Context.Cursor := TSGCursor.Create(SGC_HAND);
if PreviousCursorOver and (not CursorOver) then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle = SGC_HAND)) then
	Context.Cursor := TSGCursor.Create(SGC_NORMAL);
inherited;
end;

procedure TSGButton.Paint();
begin
if (FVisible) or (FVisibleTimer > SGZero) then
	FSkin.PaintButton(Self);
inherited;
end;

constructor TSGButton.Create();
begin
inherited;
FCanHaveChildren    := False;
end;

destructor TSGButton.Destroy();
begin
inherited Destroy();
end;

end.
