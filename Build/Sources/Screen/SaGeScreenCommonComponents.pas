{$INCLUDE SaGe.inc}

unit SaGeScreenCommonComponents;

interface

uses
	 SaGeBase
	,SaGeScreenBase
	,SaGeScreen
	,SaGeScreenComponent
	,SaGeScreenComponentInterfaces
	,SaGeBaseContextInterface
	;

type
	TSGOverComponent = class(TSGComponent, ISGOverComponent)
			public
		constructor Create();override;
		class function ClassName() : TSGString; override;
			protected
		FPreviousCursorOver : TSGBoolean;
		FCursorOver : TSGBoolean;
		FCursorOverTimer : TSGScreenTimer;
		procedure UpgradeTimers(const ElapsedTime : TSGTimerInt);override;
			public 
		function GetCursorOverTimer() : TSGScreenTimer; virtual;
		function GetCursorOver() : TSGBool; virtual;
			public
		property PreviousCursorOver : TSGBool read FPreviousCursorOver;
		property CursorOver : TSGBool read FCursorOver;
		property CursorOverTimer : TSGScreenTimer read FCursorOverTimer;
		end;
	
	TSGClickComponent = class(TSGOverComponent, ISGClickComponent)
			public
		constructor Create();override;
		class function ClassName() : TSGString; override;
			protected
		FClick      : TSGBoolean;
		FClickTimer : TSGScreenTimer;
		procedure UpgradeTimers(const ElapsedTime : TSGTimerInt);override;
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
		procedure UpgradeTimers(const ElapsedTime : TSGTimerInt);override;
			public
		function GetOpen() : TSGBoolean;
		function GetOpenTimer() : TSGScreenTimer;
			public
		property Open : TSGBoolean read GetOpen write FOpen;
		property OpenTimer : TSGScreenTimer read GetOpenTimer write FOpenTimer;
		end;

implementation

uses
	 SaGeContextUtils
	;

// TSGOverComponent

class function TSGOverComponent.ClassName() : TSGString; 
begin
Result := 'TSGOverComponent';
end;

function TSGOverComponent.GetCursorOver() : TSGBool;
begin
Result := FCursorOver;
end;

procedure TSGOverComponent.UpgradeTimers(const ElapsedTime : TSGTimerInt);
begin
FPreviousCursorOver := FCursorOver;
FCursorOver := CursorOverComponent() and ReqursiveActive;
UpgradeTimer(FCursorOver, FCursorOverTimer, ElapsedTime, 3, 2);
inherited;
end;

constructor TSGOverComponent.Create();
begin
inherited;
FPreviousCursorOver := False;
FCursorOver := False;
FCursorOverTimer := 0;
end;

function TSGOverComponent.GetCursorOverTimer() : TSGScreenTimer;
begin
Result := FCursorOverTimer;
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

procedure TSGOpenComponent.UpgradeTimers(const ElapsedTime : TSGTimerInt);
begin
inherited;
FOpen := FOpen and ReqursiveActive;
UpgradeTimer(FOpen, FOpenTimer, ElapsedTime, 3);
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

procedure TSGClickComponent.UpgradeTimers(const ElapsedTime : TSGTimerInt);
begin
inherited;
FClick := FCursorOver and Context.CursorKeysPressed(SGLeftCursorButton) and ReqursiveActive;
UpgradeTimer(FClick, FClickTimer, ElapsedTime, 4, 2);
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

end.
