//DEPRECATED

{$INCLUDE Smooth.inc}

unit SmoothWorldOfWarcraftWatcherLogonConnectionPanel;

interface

uses
	 SmoothBase
	,SmoothContextInterface
	,SmoothContextClasses
	,SmoothScreenClasses
	,SmoothFont
	,SmoothWorldOfWarcraftLogonConnection
	;

type
	TSWorldOfWarcraftWatcherLogonConnectionPanel = class(TSScreenPanel)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		procedure Paint(); override;
		class function ClassName() : TSString; override;
			protected
		FLogonConnection : TSWOWLogonConnection;
		FFont : TSFont;
		FLabels : TSScreenLabelList;
		FClientALC_Sets : TSBoolean;
		FServerALC_Sets : TSBoolean;
			protected
		procedure SetLogonConnection(const _LogonConnection : TSWOWLogonConnection); virtual;
		procedure DestroyLabels();
		function GetLabelsCount() : TSMaxEnum;
		procedure UpDateLabels();
		procedure AddNewLabel(const _Text : TSString);
			public
		property LogonConnection : TSWOWLogonConnection read FLogonConnection write SetLogonConnection;
		property LabelsCount : TSMaxEnum read GetLabelsCount;
		property Font : TSFont read FFont;
		end;

procedure SKill(var WorldOfWarcraftWatcherLogonConnectionPanel : TSWorldOfWarcraftWatcherLogonConnectionPanel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothStringUtils
	,SmoothFileUtils
	,SmoothLog
	,SmoothWorldOfWarcraftLogonStructs
	;

function TSWorldOfWarcraftWatcherLogonConnectionPanel.GetLabelsCount() : TSMaxEnum;
begin
if (FLabels = nil) then
	Result := 0
else
	Result := Length(FLabels);
end;

procedure TSWorldOfWarcraftWatcherLogonConnectionPanel.AddNewLabel(const _Text : TSString);
begin
FLabels += SCreateLabel(Self, _Text, 0, 5 + (FFont.FontHeight + 5) * LabelsCount, Width, FFont.FontHeight, FFont, True, True);
FLabels[High(FLabels)].TextPosition := False;
end;

procedure TSWorldOfWarcraftWatcherLogonConnectionPanel.UpDateLabels();
begin
if FLogonConnection.ClientALC_Sets and (not FClientALC_Sets) then
	begin
	AddNewLabel('Game:"' + SStrSmallString(FLogonConnection.ClientALC.GameName) + '"');
	AddNewLabel('Version:' + 
		SStr(FLogonConnection.ClientALC.Version.FVersion[0]) + '.' + 
		SStr(FLogonConnection.ClientALC.Version.FVersion[1]) + '.' + 
		SStr(FLogonConnection.ClientALC.Version.FVersion[2]) + ' (' + 
		SStr(FLogonConnection.ClientALC.Version.FBuildVersion) + ')');
	AddNewLabel('Platform:"' + SStrSmallString(FLogonConnection.ClientALC.Platform) + '"');
	AddNewLabel('OperatingSystem:"' + SStrSmallString(FLogonConnection.ClientALC.OperatingSystem) + '"');
	AddNewLabel('Country:"' + SStrSmallString(FLogonConnection.ClientALC.Country) + '"');
	AddNewLabel('Login:"' + FLogonConnection.ClientALC.SRP_I + '"');
	FClientALC_Sets := True;
	end;
if FLogonConnection.ServerALC_Sets and (not FServerALC_Sets) then
	begin 
	AddNewLabel('SRP_B[32]: 0x' + SStrWoWArray(@FLogonConnection.ServerALC.SRP_B[0], 32));
	AddNewLabel('SRP_g[' + SStr(FLogonConnection.ServerALC.SRP_g_length) + ']: 0x' + SStrWoWArray(FLogonConnection.ServerALC.SRP_g, FLogonConnection.ServerALC.SRP_g_length));
	AddNewLabel('SRP_N[' + SStr(FLogonConnection.ServerALC.SRP_N_length) + ']: 0x' + SStrWoWArray(FLogonConnection.ServerALC.SRP_N, FLogonConnection.ServerALC.SRP_N_length));
	AddNewLabel('SRP_s[32]: 0x' + SStrWoWArray(FLogonConnection.ServerALC.SRP_s, 32));
	AddNewLabel('SRP??[16]: 0x' + SStrWoWArray(FLogonConnection.ServerALC.SRP_, 16));
	FServerALC_Sets := True;
	end;
end;

procedure TSWorldOfWarcraftWatcherLogonConnectionPanel.SetLogonConnection(const _LogonConnection : TSWOWLogonConnection);
begin
FLogonConnection := _LogonConnection;
DestroyLabels();
if (FFont = nil) then
	FFont := SCreateFontFromFile(Context, SFontDirectory + DirectorySeparator + 'Times New Roman.sgf');
UpDateLabels();
end;

class function TSWorldOfWarcraftWatcherLogonConnectionPanel.ClassName() : TSString;
begin
Result := 'World of Warcraft Watcher Logon Connection Panel';
end;

procedure TSWorldOfWarcraftWatcherLogonConnectionPanel.Paint();
begin
inherited;
end;

constructor TSWorldOfWarcraftWatcherLogonConnectionPanel.Create();
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

procedure TSWorldOfWarcraftWatcherLogonConnectionPanel.DestroyLabels();
var
	Index : TSMaxEnum;
begin
if (LabelsCount > 0) then
	begin
	for Index := 0 to High(FLabels) do
		FLabels[Index].Destroy();
	SetLength(FLabels, 0);
	end;
end;

destructor TSWorldOfWarcraftWatcherLogonConnectionPanel.Destroy();
begin
DestroyLabels();
SKill(FFont);
FLogonConnection := nil;
inherited;
end;

procedure SKill(var WorldOfWarcraftWatcherLogonConnectionPanel : TSWorldOfWarcraftWatcherLogonConnectionPanel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if WorldOfWarcraftWatcherLogonConnectionPanel <> nil then
	begin
	WorldOfWarcraftWatcherLogonConnectionPanel.Destroy();
	WorldOfWarcraftWatcherLogonConnectionPanel := nil;
	end;
end;

end.
