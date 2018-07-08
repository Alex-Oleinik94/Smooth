{$INCLUDE SaGe.inc}

unit SaGeSystemTrayIcon;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
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
		FInitialized : TSGBoolean;
		FTip : TSGString;
		FButtonsCallBack : ISGSystemTrayIconMouseButtonsCallBack;
			protected
		procedure SetTip(const _Tip : TSGString); virtual;
			public
		property Tip : TSGString read FTip write SetTip;
		property ButtonsCallBack : ISGSystemTrayIconMouseButtonsCallBack read FButtonsCallBack write FButtonsCallBack;
		property Initialized : TSGBoolean read FInitialized;
			public
		procedure Messages(); virtual; abstract;
		procedure Initialize(); virtual;
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

procedure TSGSystemTrayIcon.Initialize();
begin
FInitialized := True;
end;

procedure TSGSystemTrayIcon.SetTip(const _Tip : TSGString);
begin
FTip := _Tip;
end;

constructor TSGSystemTrayIcon.Create();
begin
inherited;
FInitialized := False;
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
