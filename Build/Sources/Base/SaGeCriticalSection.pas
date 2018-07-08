{$INCLUDE SaGe.inc}

unit SaGeCriticalSection;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	
	,SysUtils
	;

type
	TSGCriticalSection = class (TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		procedure Enter(); virtual;
		procedure Leave(); virtual;
			private
		FCriticalSection : TRTLCriticalSection;
		FInside : TSGBoolean;
			public
		property Inside : TSGBoolean read FInside;
		end;

procedure SGKill(var CriticalSection : TSGCriticalSection); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

procedure SGKill(var CriticalSection : TSGCriticalSection); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if CriticalSection <> nil then
	begin
	CriticalSection.Destroy();
	CriticalSection := nil;
	end;
end;

// =========================
// ===TSGCriticalSection====
// =========================

constructor TSGCriticalSection.Create();
begin
inherited;
InitCriticalSection(FCriticalSection);
FInside := False;
end;

destructor TSGCriticalSection.Destroy();
begin
DoneCriticalSection(FCriticalSection);
inherited;
end;

procedure TSGCriticalSection.Enter();
begin
EnterCriticalSection(FCriticalSection);
FInside := True;
end;

procedure TSGCriticalSection.Leave();
begin
LeaveCriticalSection(FCriticalSection);
FInside := False;
end;

end.
