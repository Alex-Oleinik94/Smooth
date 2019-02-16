{$INCLUDE SaGe.inc}

unit SaGeWorldOfWarcraftWatcher;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	,SaGeConsoleCaller
	,SaGeWorldOfWarcraftConnectionHandler
	,SaGeWorldOfWarcraftWatcherPaintable
	,SaGeContextHandler
	,SaGeSystemTrayIcon
	,SaGeContextUtils
	,SaGeWorldOfWarcraftLogonConnection
	;
type
	TSGWorldOfWarcraftWatcher = class(TSGNamed, ISGSystemTrayIconMouseButtonsCallBack, ISGWorldOfWarcraftConnectionHandlerCallBacks)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		function Init(const _Params : TSGConcoleCallerParams = nil) : TSGBoolean;
		class function Initialize(const _Params : TSGConcoleCallerParams = nil) : TSGWorldOfWarcraftWatcher;
		procedure Loop();
			protected
		procedure IconMouseCallBack(const Button : TSGCursorButton; const ButtonType : TSGCursorButtonType);
		procedure LogonConnectionCallBack(const LogonConnection : TSGWOWLogonConnection);
		procedure Iteration();
		procedure Start();
		procedure InitWindow();
		procedure ChangeWindowVisible();
		procedure InitializeIcon();
		function PaintableExemplar() : TSGWorldOfWarcraftWatcherPaintable;
		procedure SetPaintableSettings();
			protected
		FHalt : TSGBoolean;
		FEmbedded : TSGBoolean;
		FConnectionHandler : TSGWorldOfWarcraftConnectionHandler;
		FWindow : TSGContextHandler;
		FIcon : TSGSystemTrayIcon;
		end;

procedure SGConsoleWorldOfWarcraftWatcher(const _Params : TSGConcoleCallerParams = nil);
procedure SGKill(var WorldOfWarcraftWatcher : TSGWorldOfWarcraftWatcher); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeConsoleTools
	,SaGeLog
	,SaGeContext
	,SaGeLists
	,SaGeFileUtils
	
	,SysUtils
	,Crt
	;

procedure TSGWorldOfWarcraftWatcher.LogonConnectionCallBack(const LogonConnection : TSGWOWLogonConnection);
begin
FIcon.Tip := FIcon.Tip + SGWinEoln + LogonConnection.ClientALC.SRP_I;
end;

procedure TSGWorldOfWarcraftWatcher.SetPaintableSettings();
var
	Paintable : TSGWorldOfWarcraftWatcherPaintable;
begin
Paintable := PaintableExemplar();
if (Paintable <> nil) then
	begin
	if (Paintable.ConnectionHandler = nil) then
		Paintable.ConnectionHandler := FConnectionHandler;
	end;
end;

function TSGWorldOfWarcraftWatcher.PaintableExemplar() : TSGWorldOfWarcraftWatcherPaintable;
begin
Result := nil;
if (FWindow <> nil) then
	Result := FWindow.PaintableExemplar as TSGWorldOfWarcraftWatcherPaintable;
end;

procedure TSGWorldOfWarcraftWatcher.IconMouseCallBack(const Button : TSGCursorButton; const ButtonType : TSGCursorButtonType);
begin
if (ButtonType = SGUpKey) then
	ChangeWindowVisible();
end;

procedure TSGWorldOfWarcraftWatcher.Iteration();
begin
SetPaintableSettings();
if (FIcon <> nil) then
	FIcon.Messages();
if KeyPressed and (ReadKey = #27) then
	FHalt := True;
end;

procedure TSGWorldOfWarcraftWatcher.InitWindow();
begin
if (FWindow = nil) then
	begin
	FWindow := TSGContextHandler.Create();
	FWindow.RegisterCompatibleClasses(TSGWorldOfWarcraftWatcherPaintable);
	FWindow.RegisterSettings(SGContextOptionMax() + SGContextOptionTitle('Maz1g Wizard'));
	end;
FWindow.RunAnotherThread();
end;

procedure TSGWorldOfWarcraftWatcher.ChangeWindowVisible();
begin
if (FWindow = nil) then
	InitWindow()
else if (FWindow.Context = nil) then
	FWindow.RunAnotherThread()
else
	begin
	FWindow.Context.Visible := not FWindow.Context.Visible;
	if FWindow.Context.Visible then
		FWindow.Context.SetForeground();
	end;
end;

procedure TSGWorldOfWarcraftWatcher.InitializeIcon();
begin
SGKill(FIcon);
if TSGCompatibleSystemTrayIcon <> nil then
	FIcon := TSGCompatibleSystemTrayIcon.Create();
if (FIcon <> nil) then
	begin
	FIcon.Tip := 'Mazig Wizard';
	FIcon.ButtonsCallBack := Self;
	FIcon.Initialize();
	end;
end;

procedure TSGWorldOfWarcraftWatcher.Start();
begin
InitializeIcon();
SGKill(FConnectionHandler);
FConnectionHandler := TSGWorldOfWarcraftConnectionHandler.Create();
FConnectionHandler.CallBacks := Self;
if not FEmbedded then
	ChangeWindowVisible();
end;

function TSGWorldOfWarcraftWatcher.Init(const _Params : TSGConcoleCallerParams = nil) : TSGBoolean;

function ProccessEmbedded(const Comand : TSGString) : TSGBoolean;
begin
Result := True;
FEmbedded := True;
end;

begin
Result := True;
if (_Params <> nil) and (Length(_Params) > 0) then
	with TSGConsoleCaller.Create(_Params) do
		begin
		Category('Maz1g Wizard help');
		AddComand(@ProccessEmbedded, ['e', 'embedded'],  'Runs embedded');
		Result := Execute();
		Destroy();
		end;
if Result then
	Start();
end;

procedure TSGWorldOfWarcraftWatcher.Loop();
begin
while (not FHalt) do
	begin
	Iteration();
	Sleep(10);
	end;
end;

class function TSGWorldOfWarcraftWatcher.Initialize(const _Params : TSGConcoleCallerParams = nil) : TSGWorldOfWarcraftWatcher;
begin
Result := TSGWorldOfWarcraftWatcher.Create();
Result.Init(_Params);
end;

constructor TSGWorldOfWarcraftWatcher.Create();
begin
inherited;
FWindow := nil;
FConnectionHandler := nil;
FHalt := False;
FEmbedded := False;
FIcon := nil;
end;

destructor TSGWorldOfWarcraftWatcher.Destroy();
begin
SGKill(FWindow);
SGKill(FConnectionHandler);
SGKill(FIcon);
inherited;
end;

var
	WorldOfWarcraftWatcher : TSGWorldOfWarcraftWatcher = nil;

procedure SGConsoleWorldOfWarcraftWatcher(const _Params : TSGConcoleCallerParams = nil);
begin
if WorldOfWarcraftWatcher = nil then
	begin
	WorldOfWarcraftWatcher := TSGWorldOfWarcraftWatcher.Create();
	if WorldOfWarcraftWatcher.Init(_Params) then
		WorldOfWarcraftWatcher.Loop();
	SGKill(WorldOfWarcraftWatcher);
	end
else
	TSGLog.Source('TSGWorldOfWarcraftWatcher: Allready initialized!');
end;

procedure SGKill(var WorldOfWarcraftWatcher : TSGWorldOfWarcraftWatcher); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if WorldOfWarcraftWatcher <> nil then
	begin
	WorldOfWarcraftWatcher.Destroy();
	WorldOfWarcraftWatcher := nil;
	end;
end;

initialization
begin
SGApplicationsConsoleCaller.AddComand(@SGConsoleWorldOfWarcraftWatcher, ['mw'], 'Maz1g Wizard');
end;

end.
