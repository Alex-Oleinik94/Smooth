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
		procedure Click(); virtual;
		end;

implementation

uses
	 SmoothMathUtils
	,SmoothCursor
	,SmoothContextUtils
	;

procedure TSButton.Click();
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
if CursorOver and Active and Visible and ((Context.CursorKeyPressed=SLeftCursorButton) and (Context.CursorKeyPressedType=SUpKey)) then
	begin
	Click();
	Context.SetCursorKey(SNullKey, SNullCursorButton);
	end;
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
FCanHaveChildren    := False;
end;

destructor TSButton.Destroy();
begin
inherited Destroy();
end;

end.
