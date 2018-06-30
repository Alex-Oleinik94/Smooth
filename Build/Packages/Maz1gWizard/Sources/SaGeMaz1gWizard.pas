{$INCLUDE SaGe.inc}

unit SaGeMaz1gWizard;

interface

uses
	 SaGeBase
	,SaGeClasses
	,SaGeConsoleCaller
	,SaGeWorldOfWarcraftConnectionHandler
	,SaGeMaz1gWizardPaintable
	,SaGeContextHandler
	,SaGeSystemTrayIcon
	,SaGeContextUtils
	,SaGeWorldOfWarcraftLogonConnection
	;
type
	TSGMaz1gWizard = class(TSGNamed, ISGSystemTrayIconMouseButtonsCallBack, ISGWorldOfWarcraftConnectionHandlerCallBacks)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			public
		function Init(const _Params : TSGConcoleCallerParams = nil) : TSGBoolean;
		class function Initialize(const _Params : TSGConcoleCallerParams = nil) : TSGMaz1gWizard;
		procedure Loop();
			protected
		procedure IconMouseCallBack(const Button : TSGCursorButton; const ButtonType : TSGCursorButtonType);
		procedure LogonConnectionCallBack(const LogonConnection : TSGWOWLogonConnection);
		procedure Iteration();
		procedure Start();
		procedure InitWindow();
		procedure ChangeWindowVisible();
		procedure InitializeIcon();
		function PaintableExemplar() : TSGMaz1gWizardPaintable;
		procedure SetPaintableSettings();
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
	,SaGeFileUtils
	
	,SysUtils
	,Crt
	;

procedure TSGMaz1gWizard.LogonConnectionCallBack(const LogonConnection : TSGWOWLogonConnection);
begin
FIcon.Tip := FIcon.Tip + SGWinEoln + LogonConnection.ClientALC.SRP_I;
end;

procedure TSGMaz1gWizard.SetPaintableSettings();
var
	Paintable : TSGMaz1gWizardPaintable;
begin
Paintable := PaintableExemplar();
if (Paintable <> nil) then
	begin
	if (Paintable.ConnectionHandler = nil) then
		Paintable.ConnectionHandler := FConnectionHandler;
	end;
end;

function TSGMaz1gWizard.PaintableExemplar() : TSGMaz1gWizardPaintable;
begin
Result := nil;
if (FWindow <> nil) then
	Result := FWindow.PaintableExemplar as TSGMaz1gWizardPaintable;
end;

procedure TSGMaz1gWizard.IconMouseCallBack(const Button : TSGCursorButton; const ButtonType : TSGCursorButtonType);
begin
if (ButtonType = SGUpKey) then
	ChangeWindowVisible();
end;

procedure TSGMaz1gWizard.Iteration();
begin
SetPaintableSettings();
if (FIcon <> nil) then
	FIcon.Messages();
if KeyPressed and (ReadKey = #27) then
	FHalt := True;
end;

procedure TSGMaz1gWizard.InitWindow();
begin
if (FWindow = nil) then
	begin
	FWindow := TSGContextHandler.Create();
	FWindow.RegisterCompatibleClasses(TSGMaz1gWizardPaintable);
	FWindow.RegisterSettings(SGContextOptionMax() + SGContextOptionTitle('Maz1g Wizard'));
	end;
FWindow.RunAnotherThread();
end;

procedure TSGMaz1gWizard.ChangeWindowVisible();
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

procedure TSGMaz1gWizard.InitializeIcon();
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

procedure TSGMaz1gWizard.Start();
begin
InitializeIcon();
SGKill(FConnectionHandler);
FConnectionHandler := TSGWorldOfWarcraftConnectionHandler.Create();
FConnectionHandler.CallBacks := Self;
if not FEmbedded then
	ChangeWindowVisible();
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