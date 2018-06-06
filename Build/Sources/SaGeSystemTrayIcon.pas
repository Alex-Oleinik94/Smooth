{$INCLUDE SaGe.inc}

unit SaGeSystemTrayIcon;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeContextUtils
	;
type
	ISGSystemTrayIconMouseButtonsCallBack = interface(ISGInterface)
		['{2e7af402-da1b-4608-9f7d-95f247b3d6a5}']
		procedure IconMouseCallBack(const Button : TSGCursorButton; const ButtonType : TSGCursorButtonType);
		end;
	
	TSGSystemTrayIcon = class(TSGNamed)
			public
		constructor Create(); override;
			protected
		FTip : TSGString;
		FButtonsCallBack : ISGSystemTrayIconMouseButtonsCallBack;
			public
		property Tip : TSGString read FTip write FTip;
		property ButtonsCallBack : ISGSystemTrayIconMouseButtonsCallBack read FButtonsCallBack write FButtonsCallBack;
			public
		procedure Messages(); virtual; abstract;
		procedure Initialize(); virtual; abstract;
		procedure Kill(); virtual; abstract;
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

constructor TSGSystemTrayIcon.Create();
begin
inherited;
FTip := '';
FButtonsCallBack := nil;
end;

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
