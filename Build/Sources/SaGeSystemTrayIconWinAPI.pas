{$INCLUDE SaGe.inc}

unit SaGeSystemTrayIconWinAPI;

interface

uses
	 SaGeBase
	,SaGeSystemTrayIcon
	
	,ShellAPI
	,Windows
	;

type
	TSGSystemTrayIconWinAPI = class(TSGSystemTrayIcon)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		
		end;

implementation

uses
	 SaGeLog
	;

procedure WindowsShellAddIcon(const IconRecourceIdentifier, IconIdentifier : TSGUInt32; const Tip : TSGString = '');
var
	IconData : TNotifyIconDataA;
	h : HANDLE;
begin
ZeroMemory(@IconData, sizeof(TNotifyIconDataA));
IconData.cbSize := sizeof(TNotifyIconDataA);
IconData.Wnd := 0;
IconData.uID := IconRecourceIdentifier;
IconData.uFlags := NIF_ICON or NIF_MESSAGE;
if Tip <> '' then
	IconData.uFlags := IconData.uFlags or NIF_TIP;
IconData.hIcon := LoadIcon(GetModuleHandle(nil), MAKEINTRESOURCE(IconIdentifier));
IconData.szTip := Tip;
IconData.uCallbackMessage := WM_USER;
if not Shell_NotifyIconA(NIM_ADD, @IconData) then
	TSGLog.Source(['WinAPI: Shell_NotifyIconA(..) returned error!']);
end;

constructor TSGSystemTrayIconWinAPI.Create();
begin
inherited;
WindowsShellAddIcon(123, 2, '123');
end;

destructor TSGSystemTrayIconWinAPI.Destroy();
begin
inherited;
end;

end.
