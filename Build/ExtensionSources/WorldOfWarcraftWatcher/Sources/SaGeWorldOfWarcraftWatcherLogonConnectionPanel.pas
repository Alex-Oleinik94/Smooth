{$INCLUDE SaGe.inc}

unit SaGeWorldOfWarcraftWatcherLogonConnectionPanel;

interface

uses
	 SaGeBase
	,SaGeContextInterface
	,SaGeContextClasses
	,SaGeScreenClasses
	,SaGeFont
	,SaGeWorldOfWarcraftLogonConnection
	;

type
	TSGWorldOfWarcraftWatcherLogonConnectionPanel = class(TSGScreenPanel)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		procedure Paint(); override;
		class function ClassName() : TSGString; override;
			protected
		FLogonConnection : TSGWOWLogonConnection;
		
			public
		property LogonConnection : TSGWOWLogonConnection read FLogonConnection write FLogonConnection;
		end;

procedure SGKill(var WorldOfWarcraftWatcherLogonConnectionPanel : TSGWorldOfWarcraftWatcherLogonConnectionPanel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeStringUtils
	,SaGeFileUtils
	;

class function TSGWorldOfWarcraftWatcherLogonConnectionPanel.ClassName() : TSGString;
begin
Result := 'World of Warcraft Watcher';
end;

procedure TSGWorldOfWarcraftWatcherLogonConnectionPanel.Paint();
begin

end;

constructor TSGWorldOfWarcraftWatcherLogonConnectionPanel.Create();
begin
inherited Create();
FLogonConnection := nil;

end;

destructor TSGWorldOfWarcraftWatcherLogonConnectionPanel.Destroy();
begin
FLogonConnection := nil;
inherited;
end;

procedure SGKill(var WorldOfWarcraftWatcherLogonConnectionPanel : TSGWorldOfWarcraftWatcherLogonConnectionPanel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if WorldOfWarcraftWatcherLogonConnectionPanel <> nil then
	begin
	WorldOfWarcraftWatcherLogonConnectionPanel.Destroy();
	WorldOfWarcraftWatcherLogonConnectionPanel := nil;
	end;
end;

end.
