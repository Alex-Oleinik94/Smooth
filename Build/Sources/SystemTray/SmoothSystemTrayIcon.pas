{$INCLUDE Smooth.inc}

unit SmoothSystemTrayIcon;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothContextUtils
	;
type
	ISSystemTrayIconMouseButtonsCallBack = interface(ISInterface)
		['{2e7af402-da1b-4608-9f7d-95f247b3d6a5}']
		procedure IconMouseCallBack(const Button : TSCursorButton; const ButtonType : TSCursorButtonType);
		end;
	
	TSSystemTrayIcon = class(TSNamed)
			public
		constructor Create(); override;
			protected
		FInitialized : TSBoolean;
		FTip : TSString;
		FButtonsCallBack : ISSystemTrayIconMouseButtonsCallBack;
			protected
		procedure SetTip(const _Tip : TSString); virtual;
			public
		property Tip : TSString read FTip write SetTip;
		property ButtonsCallBack : ISSystemTrayIconMouseButtonsCallBack read FButtonsCallBack write FButtonsCallBack;
		property Initialized : TSBoolean read FInitialized;
			public
		procedure Messages(); virtual; abstract;
		procedure Initialize(); virtual;
		procedure Kill(); virtual; abstract;
		end;
	TSSystemTrayIconClass = class of TSSystemTrayIcon;

function TSCompatibleSystemTrayIcon() : TSSystemTrayIconClass; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SKill(var SystemTrayIcon : TSSystemTrayIcon); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothLog
	{$IFDEF MSWINDOWS}
		,SmoothSystemTrayIconWinAPI
		{$ENDIF}
	;

procedure TSSystemTrayIcon.Initialize();
begin
FInitialized := True;
end;

procedure TSSystemTrayIcon.SetTip(const _Tip : TSString);
begin
FTip := _Tip;
end;

constructor TSSystemTrayIcon.Create();
begin
inherited;
FInitialized := False;
FTip := '';
FButtonsCallBack := nil;
end;

procedure SKill(var SystemTrayIcon : TSSystemTrayIcon); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if SystemTrayIcon <> nil then
	begin
	SystemTrayIcon.Destroy();
	SystemTrayIcon := nil;
	end;
end;

function TSCompatibleSystemTrayIcon() : TSSystemTrayIconClass; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := nil;
{$IFDEF MSWINDOWS}
	Result := TSSystemTrayIconWinAPI;
	{$ENDIF}
end;

end.
