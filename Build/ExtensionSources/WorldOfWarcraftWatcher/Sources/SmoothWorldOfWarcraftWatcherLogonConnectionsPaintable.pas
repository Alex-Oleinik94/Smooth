//DEPRECATED

{$INCLUDE Smooth.inc}

unit SmoothWorldOfWarcraftWatcherLogonConnectionsPaintable;

interface

uses
	 SmoothBase
	,SmoothContextInterface
	,SmoothContextClasses
	,SmoothWorldOfWarcraftConnectionHandler
	,SmoothScreenClasses
	,SmoothFont
	,SmoothWorldOfWarcraftWatcherLogonConnectionPanel
	;

type
	TSWorldOfWarcraftWatcherLogonConnectionsPaintable = class(TSPaintableObject)
			public
		constructor Create(const _Context : ISContext; const WoWConnectionHandler : TSWorldOfWarcraftConnectionHandler); virtual;
		constructor Create(const _Context : ISContext); override;
		destructor Destroy(); override;
		procedure Paint(); override;
		class function ClassName() : TSString; override;
			protected
		FConnectionHandler : TSWorldOfWarcraftConnectionHandler;
			protected
		FFont : TSFont;
		FConnectionsInfoLabel : TSScreenLabel;
		FConnectionsIndex : TSMaxEnum;
		FLogonConnectionPanel : TSWorldOfWarcraftWatcherLogonConnectionPanel;
			protected
		procedure UpDateLogonPanel();
			public
		property ConnectionHandler : TSWorldOfWarcraftConnectionHandler read FConnectionHandler write FConnectionHandler;
		end;

procedure SKill(var WoWLogonConnectionsPaintable : TSWorldOfWarcraftWatcherLogonConnectionsPaintable); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothStringUtils
	,SmoothFileUtils
	,SmoothWorldOfWarcraftLogonStructs
	;

procedure TSWorldOfWarcraftWatcherLogonConnectionsPaintable.UpDateLogonPanel();
begin
if (FConnectionHandler = nil) then
	exit;
if (FConnectionHandler.LogonConnectionsNumber = 0) and (FLogonConnectionPanel <> nil) then
	begin
	FConnectionsIndex := 1;
	FConnectionsInfoLabel.Visible := True;
	SKill(FLogonConnectionPanel);
	end
else if (FConnectionHandler.LogonConnectionsNumber > 0) and (FLogonConnectionPanel = nil) then
	begin
	FLogonConnectionPanel := TSWorldOfWarcraftWatcherLogonConnectionPanel.Create();
	Screen.CreateInternalComponent(FLogonConnectionPanel);
	FLogonConnectionPanel.SetBounds(0, 0, Screen.Width, Screen.Height);
	FLogonConnectionPanel.BoundsMakeReal();
	FLogonConnectionPanel.Visible := True;
	FLogonConnectionPanel.UserPointer := Self;
	FLogonConnectionPanel.LogonConnection := FConnectionHandler.LogonConnections[FConnectionHandler.LogonConnectionsNumber - 1];
	
	FConnectionsInfoLabel.Visible := False;
	end
else if (FLogonConnectionPanel <> nil) then
	begin
	FLogonConnectionPanel.SetBounds(0, 0, Screen.Width, Screen.Height);
	end;
end;

class function TSWorldOfWarcraftWatcherLogonConnectionsPaintable.ClassName() : TSString;
begin
Result := 'World Of Warcraft Watcher Connections Paintable';
end;

procedure TSWorldOfWarcraftWatcherLogonConnectionsPaintable.Paint();
begin
UpDateLogonPanel();
end;

constructor TSWorldOfWarcraftWatcherLogonConnectionsPaintable.Create(const _Context : ISContext; const WoWConnectionHandler : TSWorldOfWarcraftConnectionHandler);
begin
inherited Create(_Context);
FConnectionHandler := WoWConnectionHandler;
FLogonConnectionPanel := nil;
FFont := SCreateFontFromFile(Context, SFontDirectory + DirectorySeparator + 'Times New Roman.sgf');
FConnectionsInfoLabel := SCreateLabel(Screen, 'Клиент WoW 3.3.5a не подключался к серверу входа в игровой мир.', 0, 0, Screen.Width, Screen.Height, FFont, True, True);
UpDateLogonPanel();
end;

constructor TSWorldOfWarcraftWatcherLogonConnectionsPaintable.Create(const _Context : ISContext);
begin
Create(_Context, nil);
end;

destructor TSWorldOfWarcraftWatcherLogonConnectionsPaintable.Destroy();
begin
FConnectionHandler := nil;
SKill(FLogonConnectionPanel);
SKill(FConnectionsInfoLabel);
SKill(FFont);
inherited;
end;

procedure SKill(var WoWLogonConnectionsPaintable : TSWorldOfWarcraftWatcherLogonConnectionsPaintable); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if WoWLogonConnectionsPaintable <> nil then
	begin
	WoWLogonConnectionsPaintable.Destroy();
	WoWLogonConnectionsPaintable := nil;
	end;
end;

end.
