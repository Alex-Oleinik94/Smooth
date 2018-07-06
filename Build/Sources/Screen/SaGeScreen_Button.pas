{$INCLUDE SaGe.inc}

unit SaGeScreen_Button;

interface

uses
	 SaGeBase
	,SaGeScreenBase
	,SaGeScreenCommonComponents
	;

type
	TSGButton = class(TSGClickComponent, ISGButton)
			public
		constructor Create;override;
		destructor Destroy;override;
		class function ClassName() : TSGString; override;
			protected
		FCursorOnButtonTimer : TSGScreenTimer;
		FCursorOnButtonPrev  : TSGBoolean;
		FCursorOnButton      : TSGBoolean;
		FChangingButton      : TSGBoolean;
		FChangingButtonTimer : TSGScreenTimer;
			public
		function CursorInComponentCaption():boolean;override;
		procedure FromUpDateCaptionUnderCursor();override;
		procedure FromUpDate();override;
		procedure FromUpDateUnderCursor(const CursorInComponentNow:Boolean = True);override;
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

procedure TSGButton.FromUpDate();
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
inherited FromUpDate();
end;

procedure TSGButton.FromUpDateUnderCursor(const CursorInComponentNow:Boolean = True);
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
inherited FromUpDateUnderCursor(CursorInComponentNow);
end;

procedure TSGButton.Paint();
begin
if (FVisible) or (FVisibleTimer > SGZero) then
	FSkin.PaintButton(Self);
FCursorOnButton:=False;
FChangingButton:=False;
FClick := False;
inherited;
end;

procedure TSGButton.FromUpDateCaptionUnderCursor();
begin
end;

function TSGButton.CursorInComponentCaption():boolean;
begin
Result:=False;
end;

constructor TSGButton.Create();
begin
inherited Create();
FCanHaveChildren    := False;
FCursorOnButtonPrev := False;
FCursorOnButton     := False;
end;

destructor TSGButton.Destroy();
begin
inherited Destroy();
end;

end.
