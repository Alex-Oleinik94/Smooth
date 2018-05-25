{$INCLUDE SaGe.inc}

unit SaGeCriticalSection;

interface

uses
	 SaGeClasses
	
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
InitCriticalSection(FCriticalSection)
end;

destructor TSGCriticalSection.Destroy();
begin
DoneCriticalSection(FCriticalSection);
inherited;
end;

procedure TSGCriticalSection.Enter();
begin
EnterCriticalSection(FCriticalSection);
end;

procedure TSGCriticalSection.Leave();
begin
LeaveCriticalSection(FCriticalSection);
end;

end.
