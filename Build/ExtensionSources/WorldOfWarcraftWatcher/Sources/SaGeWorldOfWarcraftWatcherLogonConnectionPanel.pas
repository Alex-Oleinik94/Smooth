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
		FFont : TSGFont;
		FLabels : TSGScreenLabelList;
			protected
		procedure SetLogonConnection(const _LogonConnection : TSGWOWLogonConnection); virtual;
		procedure DestroyLabels();
		function GetLabelsCount() : TSGMaxEnum;
			public
		property LogonConnection : TSGWOWLogonConnection read FLogonConnection write SetLogonConnection;
		property LabelsCount : TSGMaxEnum read GetLabelsCount;
		property Font : TSGFont read FFont;
		end;

procedure SGKill(var WorldOfWarcraftWatcherLogonConnectionPanel : TSGWorldOfWarcraftWatcherLogonConnectionPanel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeStringUtils
	,SaGeFileUtils
	,SaGeLog
	,SaGeWorldOfWarcraftLogonStructs
	;

function TSGWorldOfWarcraftWatcherLogonConnectionPanel.GetLabelsCount() : TSGMaxEnum;
begin
if (FLabels = nil) then
	Result := 0
else
	Result := Length(FLabels);
end;

procedure TSGWorldOfWarcraftWatcherLogonConnectionPanel.SetLogonConnection(const _LogonConnection : TSGWOWLogonConnection);

procedure AddLabel(const Text : TSGString);
begin
FLabels += SGCreateLabel(Self, Text, 0, 5 + (FFont.FontHeight + 5) * LabelsCount, Width, FFont.FontHeight, FFont, True, True);
FLabels[High(FLabels)].TextPosition := False;
end;

begin
FLogonConnection := _LogonConnection;
DestroyLabels();
if (FFont = nil) then
	begin
	FFont := TSGFont.Create(SGFontDirectory + DirectorySeparator + 'Times New Roman.sgf');
	FFont.SetContext(Context);
	FFont.Loading();
	FFont.ToTexture();
	end;
AddLabel('Game:"' + SGStrSmallString(FLogonConnection.ClientALC.GameName) + '"');
AddLabel('Version:' + 
	SGStr(FLogonConnection.ClientALC.Version.FVersion[0]) + '.' + 
	SGStr(FLogonConnection.ClientALC.Version.FVersion[1]) + '.' + 
	SGStr(FLogonConnection.ClientALC.Version.FVersion[2]) + ' (' + 
	SGStr(FLogonConnection.ClientALC.Version.FBuildVersion) + ')');
AddLabel('Platform:"' + SGStrSmallString(FLogonConnection.ClientALC.Platform) + '"');
AddLabel('OperatingSystem:"' + SGStrSmallString(FLogonConnection.ClientALC.OperatingSystem) + '"');
AddLabel('Country:"' + SGStrSmallString(FLogonConnection.ClientALC.Country) + '"');
AddLabel('Login:"' + FLogonConnection.ClientALC.SRP_I + '"');
end;

class function TSGWorldOfWarcraftWatcherLogonConnectionPanel.ClassName() : TSGString;
begin
Result := 'World of Warcraft Watcher Logon Connection Panel';
end;

procedure TSGWorldOfWarcraftWatcherLogonConnectionPanel.Paint();
begin
inherited;
end;

constructor TSGWorldOfWarcraftWatcherLogonConnectionPanel.Create();
begin
inherited Create();
FLogonConnection := nil;
FLabels := nil;
FFont := nil;
ViewLines := False;
ViewQuad := False;
end;

procedure TSGWorldOfWarcraftWatcherLogonConnectionPanel.DestroyLabels();
var
	Index : TSGMaxEnum;
begin
if (LabelsCount > 0) then
	begin
	for Index := 0 to High(FLabels) do
		FLabels[Index].Destroy();
	SetLength(FLabels, 0);
	end;
end;

destructor TSGWorldOfWarcraftWatcherLogonConnectionPanel.Destroy();
begin
DestroyLabels();
SGKill(FFont);
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
