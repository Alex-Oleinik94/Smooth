{$INCLUDE SaGe.inc}

unit SaGeMaz1gWizard;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeConsoleCaller
	,SaGeWorldOfWarcraftConnectionHandler
	,SaGeMaz1gWizardWindow
	,SaGeContextHandler
	,SaGeSystemTrayIcon
	;
type
	TSGMaz1gWizard = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		function Init(const _Params : TSGConcoleCallerParams = nil) : TSGBoolean;
		class function Initialize(const _Params : TSGConcoleCallerParams = nil) : TSGMaz1gWizard;
		procedure Loop();
			protected
		procedure Iteration();
		procedure Start();
		procedure InitWindow();
		procedure ShowWindow();
		procedure InitializeIcon();
			protected
		FHalt : TSGBoolean;
		FEmbedded : TSGBoolean;
		FConnectionHandler : TSGWorldOfWarcraftConnectionHandler;
		FWindow : TSGContextHandler;
		FIcon : TSGSystemTrayIcon;
		end;

procedure SGConsoleMaz1gWizard(const _Params : TSGConcoleCallerParams = nil);
procedure SGKill(var Maz1gWizard : TSGMaz1gWizard); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeConsoleTools
	,SaGeLog
	,SaGeContext
	,SaGeLists
	,SaGeContextUtils
	
	,SysUtils
	;

procedure TSGMaz1gWizard.Iteration();
begin

end;

procedure TSGMaz1gWizard.InitWindow();
begin
SGKill(FWindow);
FWindow := 	TSGContextHandler.Create();
FWindow.RegisterCompatibleClasses(TSGMaz1gWizardWindow);
FWindow.RegisterSettings(SGContextOptionMax());
FWindow.RunAnotherThread();
end;

procedure TSGMaz1gWizard.ShowWindow();
begin
if FWindow = nil then
	InitWindow();

end;

procedure TSGMaz1gWizard.InitializeIcon();
begin
SGKill(FIcon);
if TSGCompatibleSystemTrayIcon <> nil then
	FIcon := TSGCompatibleSystemTrayIcon.Create();
if (FIcon <> nil) then
	begin
	
	end;
end;

procedure TSGMaz1gWizard.Start();
begin
InitializeIcon();
SGKill(FConnectionHandler);
FConnectionHandler := TSGWorldOfWarcraftConnectionHandler.Create();
if not FEmbedded then
	ShowWindow();
end;

function TSGMaz1gWizard.Init(const _Params : TSGConcoleCallerParams = nil) : TSGBoolean;

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

procedure TSGMaz1gWizard.Loop();
begin
while (not FHalt) do
	begin
	Iteration();
	Sleep(10);
	end;
end;

class function TSGMaz1gWizard.Initialize(const _Params : TSGConcoleCallerParams = nil) : TSGMaz1gWizard;
begin
Result := TSGMaz1gWizard.Create();
Result.Init(_Params);
end;

constructor TSGMaz1gWizard.Create();
begin
inherited;
FWindow := nil;
FConnectionHandler := nil;
FHalt := False;
FEmbedded := False;
FIcon := nil;
end;

destructor TSGMaz1gWizard.Destroy();
begin
SGKill(FWindow);
SGKill(FConnectionHandler);
SGKill(FIcon);
inherited;
end;

var
	Maz1gWizard : TSGMaz1gWizard = nil;

procedure SGConsoleMaz1gWizard(const _Params : TSGConcoleCallerParams = nil);
begin
if Maz1gWizard = nil then
	begin
	Maz1gWizard := TSGMaz1gWizard.Create();
	if Maz1gWizard.Init(_Params) then
		Maz1gWizard.Loop();
	SGKill(Maz1gWizard);
	end
else
	TSGLog.Source('TSGMaz1gWizard: Allready initialized!');
end;

procedure SGKill(var Maz1gWizard : TSGMaz1gWizard); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if Maz1gWizard <> nil then
	begin
	Maz1gWizard.Destroy();
	Maz1gWizard := nil;
	end;
end;

initialization
begin
SGApplicationsConsoleCaller.AddComand(@SGConsoleMaz1gWizard, ['mw'], 'Maz1g Wizard');
end;

end.
