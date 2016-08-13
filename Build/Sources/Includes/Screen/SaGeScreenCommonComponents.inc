{$IFDEF SCREEN_INTERFACE}
type
	TSGOverComponent = class(TSGComponent, ISGOverComponent)
			public
		constructor Create();override;
		class function ClassName() : TSGString; override;
			protected
		FOverPrev  : TSGBoolean;
		FOver      : TSGBoolean;
		FOverTimer : TSGScreenTimer;
		procedure UpgradeTimers();override;
			public 
		function GetOverTimer() : TSGScreenTimer;virtual;
		function GetOver() : TSGBool;
		end;
	
	TSGClickComponent = class(TSGOverComponent, ISGClickComponent)
			public
		constructor Create();override;
		class function ClassName() : TSGString; override;
			protected
		FClick      : TSGBoolean;
		FClickTimer : TSGScreenTimer;
		procedure UpgradeTimers();override;
			public
		function GetClickTimer() : TSGScreenTimer;virtual;
		function GetClick() : TSGBool;virtual;
		end;
	
	TSGOpenComponent = class(TSGClickComponent, ISGOpenComponent)
			public
		constructor Create();override;
		class function ClassName() : TSGString; override;
			protected
		FOpen      : TSGBoolean;
		FOpenTimer : TSGScreenTimer;
		procedure UpgradeTimers();override;
			public
		function GetOpen() : TSGBoolean;
		function GetOpenTimer() : TSGScreenTimer;
			public
		property Open : TSGBoolean read GetOpen write FOpen;
		property OpenTimer : TSGScreenTimer read GetOpenTimer write FOpenTimer;
		end;
{$ENDIF}

{$IFDEF SCREEN_IMPLEMENTATION}

// TSGOverComponent

class function TSGOverComponent.ClassName() : TSGString; 
begin
Result := 'TSGOverComponent';
end;

function TSGOverComponent.GetOver() : TSGBool;
begin
Result := FOver;
end;

procedure TSGOverComponent.UpgradeTimers();
begin
inherited;
FOverPrev := FOver;
FOver := CursorInComponent() and ReqursiveActive;
UpgradeTimer(FOver, FOverTimer, 3, 2);
end;

constructor TSGOverComponent.Create();
begin
inherited;
FOverPrev := False;
FOver := False;
FOverTimer := 0;
end;

function TSGOverComponent.GetOverTimer() : TSGScreenTimer;
begin
Result := FOverTimer;
end;

// TSGOpenComponent

class function TSGOpenComponent.ClassName() : TSGString; 
begin
Result := 'TSGOpenComponent';
end;

function TSGOpenComponent.GetOpen() : TSGBool;
begin
Result := FOpen;
end;

procedure TSGOpenComponent.UpgradeTimers();
begin
inherited;
FOpen := FOpen and ReqursiveActive;
UpgradeTimer(FOpen, FOpenTimer, 3);
end;

constructor TSGOpenComponent.Create();
begin
inherited;
FOpen := False;
FOpenTimer := 0;
end;

function TSGOpenComponent.GetOpenTimer() : TSGScreenTimer;
begin
Result := FOpenTimer;
end;

// TSGClickComponent

class function TSGClickComponent.ClassName() : TSGString; 
begin
Result := 'TSGClickComponent';
end;

function TSGClickComponent.GetClick() : TSGBool;
begin
Result := FClick;
end;

procedure TSGClickComponent.UpgradeTimers();
begin
inherited;
FClick := FOver and Context.CursorKeysPressed(SGLeftCursorButton) and ReqursiveActive;
UpgradeTimer(FClick, FClickTimer, 4, 2);
end;

constructor TSGClickComponent.Create();
begin
inherited;
FClick := False;
FClickTimer := 0;
end;

function TSGClickComponent.GetClickTimer() : TSGScreenTimer;
begin
Result := FClickTimer;
end;
{$ENDIF}
