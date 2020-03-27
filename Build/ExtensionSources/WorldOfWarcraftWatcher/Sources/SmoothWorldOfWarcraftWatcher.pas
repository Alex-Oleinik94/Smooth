{$INCLUDE Smooth.inc}

unit SmoothWorldOfWarcraftWatcher;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothConsoleCaller
	,SmoothWorldOfWarcraftConnectionHandler
	,SmoothWorldOfWarcraftWatcherPaintable
	,SmoothContextHandler
	,SmoothSystemTrayIcon
	,SmoothContextUtils
	,SmoothWorldOfWarcraftLogonConnection
	;
type
	TSWorldOfWarcraftWatcher = class(TSNamed, ISSystemTrayIconMouseButtonsCallBack, ISWorldOfWarcraftConnectionHandlerCallBacks)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		function Init(const _Params : TSConcoleCallerParams = nil) : TSBoolean;
		class function Initialize(const _Params : TSConcoleCallerParams = nil) : TSWorldOfWarcraftWatcher;
		procedure Loop();
			protected
		procedure IconMouseCallBack(const Button : TSCursorButton; const ButtonType : TSCursorButtonType);
		procedure LogonConnectionCallBack(const LogonConnection : TSWOWLogonConnection);
		procedure Iteration();
		procedure Start();
		procedure InitWindow();
		procedure ChangeWindowVisible();
		procedure InitializeIcon();
		function PaintableExemplar() : TSWorldOfWarcraftWatcherPaintable;
		procedure SetPaintableSettings();
			protected
		FHalt : TSBoolean;
		FEmbedded : TSBoolean;
		FConnectionHandler : TSWorldOfWarcraftConnectionHandler;
		FWindow : TSContextHandler;
		FIcon : TSSystemTrayIcon;
		end;

procedure SConsoleWorldOfWarcraftWatcher(const _Params : TSConcoleCallerParams = nil);
procedure SKill(var WorldOfWarcraftWatcher : TSWorldOfWarcraftWatcher); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothConsoleTools
	,SmoothLog
	,SmoothContext
	,SmoothLists
	,SmoothFileUtils
	
	,SysUtils
	,Crt
	//,SmoothGraphicViewer
	;

procedure TSWorldOfWarcraftWatcher.LogonConnectionCallBack(const LogonConnection : TSWOWLogonConnection);
begin
FIcon.Tip := FIcon.Tip + SWinEoln + LogonConnection.ClientALC.SRP_I;
end;

procedure TSWorldOfWarcraftWatcher.SetPaintableSettings();
var
	Paintable : TSWorldOfWarcraftWatcherPaintable;
begin
Paintable := PaintableExemplar();
if (Paintable <> nil) then
	begin
	if (Paintable.ConnectionHandler = nil) then
		Paintable.ConnectionHandler := FConnectionHandler;
	end;
end;

function TSWorldOfWarcraftWatcher.PaintableExemplar() : TSWorldOfWarcraftWatcherPaintable;
begin
Result := nil;
if (FWindow <> nil) and (FWindow.PaintableExemplar is TSWorldOfWarcraftWatcherPaintable) then
	Result := FWindow.PaintableExemplar as TSWorldOfWarcraftWatcherPaintable;
end;

procedure TSWorldOfWarcraftWatcher.IconMouseCallBack(const Button : TSCursorButton; const ButtonType : TSCursorButtonType);
begin
if (ButtonType = SUpKey) then
	ChangeWindowVisible();
end;

procedure TSWorldOfWarcraftWatcher.Iteration();
begin
SetPaintableSettings();
if (FIcon <> nil) then
	FIcon.Messages();
if KeyPressed and (ReadKey = #27) then
	FHalt := True;
end;

procedure TSWorldOfWarcraftWatcher.InitWindow();
begin
if (FWindow = nil) then
	begin
	FWindow := TSContextHandler.Create();
	FWindow.RegisterCompatibleClasses(TSWorldOfWarcraftWatcherPaintable);
	//FWindow.RegisterCompatibleClasses(TSGraphViewer);
	FWindow.RegisterSettings(SContextOptionMax() + SContextOptionTitle('World of Warcraft Watcher'));
	end;
FWindow.RunAnotherThread();
end;

procedure TSWorldOfWarcraftWatcher.ChangeWindowVisible();
begin
if (FWindow = nil) then
	InitWindow()
else if (FWindow.Context = nil) then
	FWindow.RunAnotherThread()
else
	begin
	FWindow.Context.Active := not FWindow.Context.Active; // For "World of Warcraft Watcher" no need to waste RAM on the initialized window
	{FWindow.Context.Visible := not FWindow.Context.Visible;
	if FWindow.Context.Visible then
		FWindow.Context.SetForeground();}
	end;
end;

procedure TSWorldOfWarcraftWatcher.InitializeIcon();
begin
SKill(FIcon);
if TSCompatibleSystemTrayIcon <> nil then
	FIcon := TSCompatibleSystemTrayIcon.Create();
if (FIcon <> nil) then
	begin
	FIcon.Tip := 'World of Warcraft Watcher';
	FIcon.ButtonsCallBack := Self;
	FIcon.Initialize();
	end;
end;

procedure TSWorldOfWarcraftWatcher.Start();
begin
InitializeIcon();
SKill(FConnectionHandler);
FConnectionHandler := TSWorldOfWarcraftConnectionHandler.Create();
FConnectionHandler.CallBacks := Self;
if not FEmbedded then
	ChangeWindowVisible();
end;

function TSWorldOfWarcraftWatcher.Init(const _Params : TSConcoleCallerParams = nil) : TSBoolean;

function ProccessEmbedded(const Comand : TSString) : TSBoolean;
begin
Result := True;
FEmbedded := True;
end;

begin
Result := True;
if (_Params <> nil) and (Length(_Params) > 0) then
	with TSConsoleCaller.Create(_Params) do
		begin
		Category('"World of Warcraft Watcher" help');
		AddComand(@ProccessEmbedded, ['e', 'embedded'],  'Runs embedded');
		Result := Execute();
		Destroy();
		end;
if Result then
	Start();
end;

procedure TSWorldOfWarcraftWatcher.Loop();
begin
while (not FHalt) do
	begin
	Iteration();
	Sleep(10);
	end;
end;

class function TSWorldOfWarcraftWatcher.Initialize(const _Params : TSConcoleCallerParams = nil) : TSWorldOfWarcraftWatcher;
begin
Result := TSWorldOfWarcraftWatcher.Create();
Result.Init(_Params);
end;

constructor TSWorldOfWarcraftWatcher.Create();
begin
inherited;
FWindow := nil;
FConnectionHandler := nil;
FHalt := False;
FEmbedded := False;
FIcon := nil;
end;

destructor TSWorldOfWarcraftWatcher.Destroy();
begin
SKill(FWindow);
SKill(FConnectionHandler);
SKill(FIcon);
inherited;
end;

var
	WorldOfWarcraftWatcher : TSWorldOfWarcraftWatcher = nil;

procedure SConsoleWorldOfWarcraftWatcher(const _Params : TSConcoleCallerParams = nil);
begin
if WorldOfWarcraftWatcher = nil then
	begin
	WorldOfWarcraftWatcher := TSWorldOfWarcraftWatcher.Create();
	if WorldOfWarcraftWatcher.Init(_Params) then
		WorldOfWarcraftWatcher.Loop();
	SKill(WorldOfWarcraftWatcher);
	end
else
	TSLog.Source('TSWorldOfWarcraftWatcher: Allready initialized!');
end;

procedure SKill(var WorldOfWarcraftWatcher : TSWorldOfWarcraftWatcher); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if WorldOfWarcraftWatcher <> nil then
	begin
	WorldOfWarcraftWatcher.Destroy();
	WorldOfWarcraftWatcher := nil;
	end;
end;

initialization
begin
SApplicationsConsoleCaller.AddComand(@SConsoleWorldOfWarcraftWatcher, ['woww'], 'World of Warcraft Watcher');
end;

end.
