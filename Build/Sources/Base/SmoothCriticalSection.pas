{$INCLUDE Smooth.inc}

unit SmoothCriticalSection;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	
	,SysUtils
	;

type
	TSCriticalSection = class (TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		procedure Enter(); virtual;
		procedure Leave(); virtual;
			private
		FCriticalSection : TRTLCriticalSection;
		FInside : TSBoolean;
			public
		property Inside : TSBoolean read FInside;
		end;

procedure SKill(var CriticalSection : TSCriticalSection); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

procedure SKill(var CriticalSection : TSCriticalSection); overload; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if CriticalSection <> nil then
	begin
	CriticalSection.Destroy();
	CriticalSection := nil;
	end;
end;

// =========================
// ===TSCriticalSection====
// =========================

constructor TSCriticalSection.Create();
begin
inherited;
InitCriticalSection(FCriticalSection);
FInside := False;
end;

destructor TSCriticalSection.Destroy();
begin
DoneCriticalSection(FCriticalSection);
inherited;
end;

procedure TSCriticalSection.Enter();
begin
EnterCriticalSection(FCriticalSection);
FInside := True;
end;

procedure TSCriticalSection.Leave();
begin
LeaveCriticalSection(FCriticalSection);
FInside := False;
end;

end.
