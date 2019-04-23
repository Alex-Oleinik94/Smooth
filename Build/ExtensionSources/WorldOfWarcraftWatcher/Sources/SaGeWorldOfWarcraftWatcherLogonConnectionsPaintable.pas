{$INCLUDE SaGe.inc}

unit SaGeWorldOfWarcraftWatcherLogonConnectionsPaintable;

interface

uses
	 SaGeBase
	,SaGeContextInterface
	,SaGeContextClasses
	,SaGeWorldOfWarcraftConnectionHandler
	,SaGeScreenClasses
	,SaGeFont
	,SaGeWorldOfWarcraftWatcherLogonConnectionPanel
	;

type
	TSGWorldOfWarcraftWatcherLogonConnectionsPaintable = class(TSGPaintableObject)
			public
		constructor Create(const _Context : ISGContext; const WoWConnectionHandler : TSGWorldOfWarcraftConnectionHandler); virtual;
		constructor Create(const _Context : ISGContext); override;
		destructor Destroy(); override;
		procedure Paint(); override;
		class function ClassName() : TSGString; override;
			protected
		FConnectionHandler : TSGWorldOfWarcraftConnectionHandler;
			protected
		FFont : TSGFont;
		FConnectionsInfoLabel : TSGScreenLabel;
		FConnectionsIndex : TSGMaxEnum;
		FLogonConnectionPanel : TSGWorldOfWarcraftWatcherLogonConnectionPanel;
			protected
		procedure UpDateLogonPanel();
			public
		property ConnectionHandler : TSGWorldOfWarcraftConnectionHandler read FConnectionHandler write FConnectionHandler;
		end;

procedure SGKill(var WoWLogonConnectionsPaintable : TSGWorldOfWarcraftWatcherLogonConnectionsPaintable); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeStringUtils
	,SaGeFileUtils
	,SaGeWorldOfWarcraftLogonStructs
	;

procedure TSGWorldOfWarcraftWatcherLogonConnectionsPaintable.UpDateLogonPanel();
begin
if (FConnectionHandler = nil) then
	exit;
if (FConnectionHandler.LogonConnectionsNumber = 0) and (FLogonConnectionPanel <> nil) then
	begin
	FConnectionsIndex := 1;
	FConnectionsInfoLabel.Visible := True;
	SGKill(FLogonConnectionPanel);
	end
else if (FConnectionHandler.LogonConnectionsNumber > 0) and (FLogonConnectionPanel = nil) then
	begin
	FLogonConnectionPanel := TSGWorldOfWarcraftWatcherLogonConnectionPanel.Create();
	Screen.CreateChild(FLogonConnectionPanel);
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

class function TSGWorldOfWarcraftWatcherLogonConnectionsPaintable.ClassName() : TSGString;
begin
Result := 'World Of Warcraft Watcher Connections Paintable';
end;

procedure TSGWorldOfWarcraftWatcherLogonConnectionsPaintable.Paint();
begin
UpDateLogonPanel();
end;

constructor TSGWorldOfWarcraftWatcherLogonConnectionsPaintable.Create(const _Context : ISGContext; const WoWConnectionHandler : TSGWorldOfWarcraftConnectionHandler);
begin
inherited Create(_Context);
FConnectionHandler := WoWConnectionHandler;
FLogonConnectionPanel := nil;

FFont := TSGFont.Create(SGFontDirectory + DirectorySeparator + 'Times New Roman.sgf');
FFont.SetContext(Context);
FFont.Loading();
FFont.ToTexture();

FConnectionsInfoLabel := SGCreateLabel(Screen, 'Клиент WoW 3.3.5a не подключался к серверу входа в игровой мир.', 0, 0, Screen.Width, Screen.Height, FFont, True, True);

UpDateLogonPanel();
end;

constructor TSGWorldOfWarcraftWatcherLogonConnectionsPaintable.Create(const _Context : ISGContext);
begin
Create(_Context, nil);
end;

destructor TSGWorldOfWarcraftWatcherLogonConnectionsPaintable.Destroy();
begin
FConnectionHandler := nil;
SGKill(FLogonConnectionPanel);
SGKill(FConnectionsInfoLabel);
SGKill(FFont);
inherited;
end;

procedure SGKill(var WoWLogonConnectionsPaintable : TSGWorldOfWarcraftWatcherLogonConnectionsPaintable); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if WoWLogonConnectionsPaintable <> nil then
	begin
	WoWLogonConnectionsPaintable.Destroy();
	WoWLogonConnectionsPaintable := nil;
	end;
end;

end.
