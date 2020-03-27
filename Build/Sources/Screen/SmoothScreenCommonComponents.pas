{$INCLUDE Smooth.inc}

unit SmoothScreenCommonComponents;

interface

uses
	 SmoothBase
	,SmoothScreenBase
	,SmoothScreen
	,SmoothScreenComponent
	,SmoothScreenComponentInterfaces
	,SmoothBaseContextInterface
	;

type
	TSOverComponent = class(TSComponent, ISCursorOverComponent)
			public
		constructor Create();override;
		class function ClassName() : TSString; override;
			protected
		FPreviousCursorOver : TSBoolean;
		FCursorOver : TSBoolean;
		FCursorOverTimer : TSScreenTimer;
		procedure UpgradeTimers(const ElapsedTime : TSTimerInt);override;
			public 
		function GetCursorOverTimer() : TSScreenTimer; virtual;
		function GetCursorOver() : TSBool; virtual;
			public
		property PreviousCursorOver : TSBool read FPreviousCursorOver;
		property CursorOver : TSBool read FCursorOver;
		property CursorOverTimer : TSScreenTimer read FCursorOverTimer;
		end;
	
	TSClickComponent = class(TSOverComponent, ISMouseClickComponent)
			public
		constructor Create();override;
		class function ClassName() : TSString; override;
			protected
		FMouseClick      : TSBoolean;
		FMouseClickTimer : TSScreenTimer;
		procedure UpgradeTimers(const ElapsedTime : TSTimerInt);override;
			public
		function GetMouseClickTimer() : TSScreenTimer;virtual;
		function GetMouseClick() : TSBool;virtual;
		end;
	
	TSOpenComponent = class(TSClickComponent, ISOpenComponent)
			public
		constructor Create();override;
		class function ClassName() : TSString; override;
			protected
		FOpen      : TSBoolean;
		FOpenTimer : TSScreenTimer;
		procedure UpgradeTimers(const ElapsedTime : TSTimerInt);override;
			public
		function GetOpen() : TSBoolean;
		function GetOpenTimer() : TSScreenTimer;
			public
		property Open : TSBoolean read GetOpen write FOpen;
		property OpenTimer : TSScreenTimer read GetOpenTimer write FOpenTimer;
		end;

implementation

uses
	 SmoothContextUtils
	;

// TSOverComponent

class function TSOverComponent.ClassName() : TSString; 
begin
Result := 'TSOverComponent';
end;

function TSOverComponent.GetCursorOver() : TSBool;
begin
Result := FCursorOver;
end;

procedure TSOverComponent.UpgradeTimers(const ElapsedTime : TSTimerInt);
begin
inherited;
FPreviousCursorOver := FCursorOver;
FCursorOver := CursorOverComponent() and ReqursiveActive;
UpgradeTimer(FCursorOver, FCursorOverTimer, ElapsedTime, 3, 2);
end;

constructor TSOverComponent.Create();
begin
inherited;
FPreviousCursorOver := False;
FCursorOver := False;
FCursorOverTimer := 0;
end;

function TSOverComponent.GetCursorOverTimer() : TSScreenTimer;
begin
Result := FCursorOverTimer;
end;

// TSOpenComponent

class function TSOpenComponent.ClassName() : TSString; 
begin
Result := 'TSOpenComponent';
end;

function TSOpenComponent.GetOpen() : TSBool;
begin
Result := FOpen;
end;

procedure TSOpenComponent.UpgradeTimers(const ElapsedTime : TSTimerInt);
begin
inherited;
FOpen := FOpen and ReqursiveActive;
UpgradeTimer(FOpen, FOpenTimer, ElapsedTime, 3);
end;

constructor TSOpenComponent.Create();
begin
inherited;
FOpen := False;
FOpenTimer := 0;
end;

function TSOpenComponent.GetOpenTimer() : TSScreenTimer;
begin
Result := FOpenTimer;
end;

// TSClickComponent

class function TSClickComponent.ClassName() : TSString; 
begin
Result := 'TSClickComponent';
end;

function TSClickComponent.GetMouseClick() : TSBool;
begin
Result := FMouseClick;
end;

procedure TSClickComponent.UpgradeTimers(const ElapsedTime : TSTimerInt);
begin
inherited;
FMouseClick := FCursorOver and Context.CursorKeysPressed(SLeftCursorButton) and ReqursiveActive;
UpgradeTimer(FMouseClick, FMouseClickTimer, ElapsedTime, 4, 2);
end;

constructor TSClickComponent.Create();
begin
inherited;
FMouseClick := False;
FMouseClickTimer := 0;
end;

function TSClickComponent.GetMouseClickTimer() : TSScreenTimer;
begin
Result := FMouseClickTimer;
end;

end.
