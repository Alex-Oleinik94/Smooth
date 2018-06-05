{$INCLUDE SaGe.inc}

unit SaGeSystemTrayIcon;

interface

uses
	 SaGeBase
	,SaGeClasses
	;

type
	TSGSystemTrayIcon = class(TSGNamed)
		
		end;
	TSGSystemTrayIconClass = class of TSGSystemTrayIcon;

function TSGCompatibleSystemTrayIcon() : TSGSystemTrayIconClass; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGKill(var SystemTrayIcon : TSGSystemTrayIcon); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeLog
	{$IFDEF MSWINDOWS}
		,SaGeSystemTrayIconWinAPI
		{$ENDIF}
	;

procedure SGKill(var SystemTrayIcon : TSGSystemTrayIcon); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if SystemTrayIcon <> nil then
	begin
	SystemTrayIcon.Destroy();
	SystemTrayIcon := nil;
	end;
end;

function TSGCompatibleSystemTrayIcon() : TSGSystemTrayIconClass; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := nil;
{$IFDEF MSWINDOWS}
	Result := TSGSystemTrayIconWinAPI;
	{$ENDIF}
end;

end.
