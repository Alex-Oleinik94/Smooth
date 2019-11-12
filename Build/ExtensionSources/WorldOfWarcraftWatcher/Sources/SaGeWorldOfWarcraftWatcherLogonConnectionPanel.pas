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
		FClientALC_Sets : TSGBoolean;
		FServerALC_Sets : TSGBoolean;
			protected
		procedure SetLogonConnection(const _LogonConnection : TSGWOWLogonConnection); virtual;
		procedure DestroyLabels();
		function GetLabelsCount() : TSGMaxEnum;
		procedure UpDateLabels();
		procedure AddNewLabel(const _Text : TSGString);
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

procedure TSGWorldOfWarcraftWatcherLogonConnectionPanel.AddNewLabel(const _Text : TSGString);
begin
FLabels += SGCreateLabel(Self, _Text, 0, 5 + (FFont.FontHeight + 5) * LabelsCount, Width, FFont.FontHeight, FFont, True, True);
FLabels[High(FLabels)].TextPosition := False;
end;

procedure TSGWorldOfWarcraftWatcherLogonConnectionPanel.UpDateLabels();
begin
if FLogonConnection.ClientALC_Sets and (not FClientALC_Sets) then
	begin
	AddNewLabel('Game:"' + SGStrSmallString(FLogonConnection.ClientALC.GameName) + '"');
	AddNewLabel('Version:' + 
		SGStr(FLogonConnection.ClientALC.Version.FVersion[0]) + '.' + 
		SGStr(FLogonConnection.ClientALC.Version.FVersion[1]) + '.' + 
		SGStr(FLogonConnection.ClientALC.Version.FVersion[2]) + ' (' + 
		SGStr(FLogonConnection.ClientALC.Version.FBuildVersion) + ')');
	AddNewLabel('Platform:"' + SGStrSmallString(FLogonConnection.ClientALC.Platform) + '"');
	AddNewLabel('OperatingSystem:"' + SGStrSmallString(FLogonConnection.ClientALC.OperatingSystem) + '"');
	AddNewLabel('Country:"' + SGStrSmallString(FLogonConnection.ClientALC.Country) + '"');
	AddNewLabel('Login:"' + FLogonConnection.ClientALC.SRP_I + '"');
	FClientALC_Sets := True;
	end;
if FLogonConnection.ServerALC_Sets and (not FServerALC_Sets) then
	begin 
	AddNewLabel('SRP_B[32]: 0x' + SGStrWoWArray(@FLogonConnection.ServerALC.SRP_B[0], 32));
	AddNewLabel('SRP_g[' + SGStr(FLogonConnection.ServerALC.SRP_g_length) + ']: 0x' + SGStrWoWArray(FLogonConnection.ServerALC.SRP_g, FLogonConnection.ServerALC.SRP_g_length));
	AddNewLabel('SRP_N[' + SGStr(FLogonConnection.ServerALC.SRP_N_length) + ']: 0x' + SGStrWoWArray(FLogonConnection.ServerALC.SRP_N, FLogonConnection.ServerALC.SRP_N_length));
	AddNewLabel('SRP_s[32]: 0x' + SGStrWoWArray(FLogonConnection.ServerALC.SRP_s, 32));
	AddNewLabel('SRP??[16]: 0x' + SGStrWoWArray(FLogonConnection.ServerALC.SRP_, 16));
	FServerALC_Sets := True;
	end;
end;

procedure TSGWorldOfWarcraftWatcherLogonConnectionPanel.SetLogonConnection(const _LogonConnection : TSGWOWLogonConnection);
begin
FLogonConnection := _LogonConnection;
DestroyLabels();
if (FFont = nil) then
	FFont := SGCreateFontFromFile(Context, SGFontDirectory + DirectorySeparator + 'Times New Roman.sgf');
UpDateLabels();
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
FClientALC_Sets := False;
FServerALC_Sets := False;
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
