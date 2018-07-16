{$INCLUDE SaGe.inc}

unit SaGeContextHandler;

interface

uses
	 SaGeBase
	,SaGeBaseClasses
	,SaGeContextClasses
	,SaGeContextInterface
	,SaGeContext
	,SaGeRender
	,SaGeCasesOfPrint
	,SaGeThreads
	,SaGeContextUtils
	{$IF defined(ANDROID)}
		,android_native_app_glue
		{$ENDIF}
	;

type
	TSGContextHandler = class(TSGNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FContext : TSGContext;
		FIContext : ISGContext;
		FSettings : TSGContextSettings;
		FPaintableSettings : TSGPaintableSettings;
		FPlacement : TSGContextWindowPlacement;
		FPaintableClass : TSGPaintableObjectClass;
		FContextClass : TSGContextClass;
		FRenderClass : TSGRenderClass;
		FThread : TSGThread;
			protected
		procedure CheckPlacement();
		function SetSettings() : TSGContextSettings;
		function TryChangeContext() : TSGBoolean;
		procedure PrintSettings(const CasesOfPrint : TSGCasesOfPrint = [SGCasePrint, SGCaseLog]);
		function GetPaintableExemplar() : TSGPaintableObject;
		procedure ViewRunParams();
			public
		property PaintableClass : TSGPaintableObjectClass read FPaintableClass write FPaintableClass;
		property Context : TSGContext read FContext;
		property PaintableExemplar : TSGPaintableObject read GetPaintableExemplar;
			public
		procedure RegisterSettings(const _Settings : TSGContextSettings);
		procedure RegisterClasses(const _ContextClass : TSGContextClass; const _RenderClass : TSGRenderClass; const _PaintableClass : TSGPaintableObjectClass);
		procedure RegisterCompatibleClasses(const _PaintableClass : TSGPaintableObjectClass);
		function Initialize() : TSGBoolean;
		procedure Run();
		procedure Loop();
		procedure RunAnotherThread();
		procedure Kill();
		procedure LoopAndKill();
		end;

procedure SGKill(var ContextHandler : TSGContextHandler); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure SGRunPaintable(const _PaintableClass : TSGPaintableObjectClass; const _ContextClass : TSGContextClass; const _RenderClass : TSGRenderClass; const _Settings : TSGContextSettings = nil);
procedure SGCompatibleRunPaintable(const _PaintableClass : TSGPaintableObjectClass; const _Settings : TSGContextSettings = nil);

implementation

uses
	 SaGeAudioRender
	,SaGeBaseUtils
	,SaGeLists
	,SaGeCursor
	,SaGeLog
	,SaGeStringUtils
	,SaGeTextMultiStream
	,SaGeTextLogStream
	{$IFDEF ANDROID}
		,SaGeContextAndroid
		{$ENDIF}
	{$IFDEF MSWINDOWS}
		,SaGeNvidiaOptimusEnablement
		,SaGeNvidiaDriverSettingsUtils
		{$ENDIF}
	;

procedure SGRunPaintable(const _PaintableClass : TSGPaintableObjectClass; const _ContextClass : TSGContextClass; const _RenderClass : TSGRenderClass; const _Settings : TSGContextSettings = nil);
begin
with TSGContextHandler.Create() do
	begin
	RegisterClasses(_ContextClass, _RenderClass, _PaintableClass);
	RegisterSettings(_Settings);
	Run();
	Destroy();
	end;
end;

procedure SGCompatibleRunPaintable(const _PaintableClass : TSGPaintableObjectClass; const _Settings : TSGContextSettings = nil);
var
	Settings : TSGContextSettings = nil;
begin
Settings := SGContextSettingsCopy(_Settings);
if not ('AUDIORENDER' in Settings) then if TSGCompatibleAudioRender <> nil then
	Settings += SGContextOptionAudioRender(TSGCompatibleAudioRender);
SGRunPaintable(_PaintableClass, TSGCompatibleContext, TSGCompatibleRender, Settings);
SetLength(Settings, 0);
end;

procedure SGKill(var ContextHandler : TSGContextHandler); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (ContextHandler <> nil) then
	begin
	ContextHandler.Destroy();
	ContextHandler := nil;
	end;
end;

/////////////////////
// Context Handler //
/////////////////////

function TSGContextHandler.GetPaintableExemplar() : TSGPaintableObject;
begin
Result := nil;
if (FContext <> nil) then
	Result := FContext.PaintableExemplar;
end;

procedure TSGContextHandler_ThreadProcedure_Run(ContextHandler : TSGContextHandler);
begin
ContextHandler.Run();
end;

procedure TSGContextHandler.RunAnotherThread();
begin
SGKill(FThread);
FThread := TSGThread.Create(TSGThreadProcedure(@TSGContextHandler_ThreadProcedure_Run), Self, True);
end;

procedure TSGContextHandler.LoopAndKill();
begin
Loop();
Kill();
end;

procedure TSGContextHandler.PrintSettings(const CasesOfPrint : TSGCasesOfPrint = [SGCasePrint, SGCaseLog]);

function WordName(const S : TSGString) : TSGString;
begin
Result := SGDownCaseString(S);
if Length(Result) > 0 then
	Result[1] := UpCase(Result[1]);
end;

const
	DefaultColor = 7;
	PropertyNameColor = 15;
	ProperyValueColor = 10;
	PunctuationMarkColor = 14;
var
	TextStream : TSGTextMultiStream = nil;
	O : TSGContextOption;
	First : TSGBoolean = True;
	StandartOptions : TSGStringList = nil;
	i : TSGUInt32;
begin
if (FSettings = nil) or (Length(FSettings) = 0) then
	exit;
TextStream := TSGTextMultiStream.Create(SGCasesOfPrintFull);
TextStream.Get(TSGTextLogStream).Write(SGLogDateTimeString());
TextStream.TextColor(DefaultColor);
TextStream.Write('Options ');
TextStream.TextColor(PunctuationMarkColor);
TextStream.Write('(');
StandartOptions += 'WIDTH';
StandartOptions += 'HEIGHT';
StandartOptions += 'LEFT';
StandartOptions += 'TOP';
for O in FSettings do
	begin
	if First then
		First := False
	else
		begin
		TextStream.TextColor(PunctuationMarkColor);
		TextStream.Write(', ');
		end;
	if (O.FName = 'FULLSCREEN') and (TSGMaxEnum(O.FOption) = 0) then
		begin
		TextStream.TextColor(PunctuationMarkColor);
		TextStream.Write('!');
		end;
	if O.FName = 'AUDIORENDER' then
		begin
		TextStream.TextColor(PropertyNameColor);
		TextStream.Write('Audio');
		end
	else
		begin
		TextStream.TextColor(PropertyNameColor);
		TextStream.Write(WordName(O.FName));
		end;
	if O.FName in StandartOptions then
		begin
		TextStream.TextColor(PunctuationMarkColor);
		TextStream.Write('=');
		TextStream.TextColor(ProperyValueColor);
		TextStream.Write(SGStr(TSGMaxEnum(O.FOption)));
		end
	else if O.FName = 'AUDIORENDER' then
		begin
		TextStream.TextColor(PunctuationMarkColor);
		TextStream.Write(': ');
		TextStream.TextColor(ProperyValueColor);
		TextStream.Write(TSGAudioRenderClass(O.FOption).AudioRenderName());
		end
	else if O.FName = 'TITLE' then
		begin
		TextStream.TextColor(PunctuationMarkColor);
		TextStream.Write('=' + '''');
		TextStream.TextColor(ProperyValueColor);
		TextStream.Write(SGPCharToString(PChar(O.FOption)));
		TextStream.TextColor(PunctuationMarkColor);
		TextStream.Write('''');
		end
	else if (O.FName = 'FILES TO OPEN') then
		begin
		TextStream.TextColor(PunctuationMarkColor);
		TextStream.Write('=[');
		if Length(TSGStringList(O.FOption)) > 0 then
			for i := 0 to High(TSGStringList(O.FOption)) do
				begin
				if i <> 0 then
					begin
					TextStream.TextColor(PunctuationMarkColor);
					TextStream.Write(', ');
					end;
				TextStream.TextColor(PunctuationMarkColor);
				TextStream.Write('`');
				TextStream.TextColor(ProperyValueColor);
				TextStream.Write(TSGStringList(O.FOption)[i]);
				TextStream.TextColor(PunctuationMarkColor);
				TextStream.Write('`');
				end;
		TextStream.TextColor(PunctuationMarkColor);
		TextStream.Write(']');
		end
	else if (O.FName = 'MIN') or (O.FName = 'MAX') or (O.FName = 'FULLSCREEN') then
		begin end
	else
		begin
		TextStream.TextColor(PunctuationMarkColor);
		TextStream.Write('=');
		TextStream.TextColor(ProperyValueColor);
		TextStream.Write(SGAddrStr(O.FOption));
		end;
	end;
SetLength(StandartOptions, 0);
TextStream.TextColor(PunctuationMarkColor);
TextStream.Write(')');
TextStream.WriteLn();
TextStream.TextColor(DefaultColor);
SGKill(TextStream);
end;

function TSGContextHandler.TryChangeContext() : TSGBoolean;
// Result = True : Continue loop
// Result = False : Exit loop
var
	NewContext : TSGContext = nil;
	OldContextName : TSGString = '';
begin
Result := False;
{$IFDEF CONTEXT_CHANGE_DEBUGING}
	SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(FContext),', IContext=',SGAddrStr(FIContext),'). Enter.']);
	{$ENDIF}
if (FContext.NewContext <> nil) and (FContext.Active or (not (FContext is FContext.NewContext))) then
	begin
	OldContextName := FContext.ContextName();
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(FContext),', IContext=',SGAddrStr(FIContext),'). Begin changing.']);
		SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(FContext),', IContext=',SGAddrStr(FIContext),'). Creating new context.']);
		{$ENDIF}
	NewContext := FContext.NewContext.Create();
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(FContext),', IContext=',SGAddrStr(FIContext),'). Delete old context device recources.']);
		{$ENDIF}
	FContext.DeleteRenderResources();
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(FContext),', IContext=',SGAddrStr(FIContext),'). Moving info.']);
		{$ENDIF}
	NewContext.MoveInfo(FContext);
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(FContext),', IContext=',SGAddrStr(FIContext),'). Change "IContext".']);
		{$ENDIF}
	FIContext := NewContext;
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(FContext),', IContext=',SGAddrStr(FIContext),'). Destroying old context.']);
		{$ENDIF}
	FContext.Destroy();
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(FContext),', IContext=',SGAddrStr(FIContext),'). Initializing new context.']);
		{$ENDIF}
	FContext := NewContext;
	FContext.Initialize();
	FContext.LoadRenderResources();
	Result := FContext.Active;
	SGHint(['Changing context (' + OldContextName + ' --> ' + FContext.ContextName() + ')' + Iff(Result, ' successfull.', ' failed!')]);
	end;
{$IFDEF CONTEXT_CHANGE_DEBUGING}
	SGLog.Source(['SGTryChangeContextType(Context=',SGAddrStr(FContext),', IContext=',SGAddrStr(FIContext),'). Leave.']);
	{$ENDIF}
end;

procedure TSGContextHandler.ViewRunParams();
const
	DefaultColor = 7;
	PropertyNameColor = 15;
	ProperyValueColor = 10;
	PunctuationMarkColor = 14;
var
	TextStream : TSGTextMultiStream = nil;
begin
TextStream := TSGTextMultiStream.Create(SGCasesOfPrintFull);
TextStream.Get(TSGTextLogStream).Write(SGLogDateTimeString());
TextStream.TextColor(DefaultColor);
TextStream.Write('Run ');
TextStream.TextColor(PunctuationMarkColor);
TextStream.Write('(');
TextStream.TextColor(PropertyNameColor);
TextStream.Write('Class');
TextStream.TextColor(PunctuationMarkColor);
TextStream.Write(': ');
TextStream.TextColor(ProperyValueColor);
TextStream.Write(FPaintableClass.ClassName());
TextStream.TextColor(PunctuationMarkColor);
TextStream.Write(', ');
TextStream.TextColor(PropertyNameColor);
TextStream.Write('Context');
TextStream.TextColor(PunctuationMarkColor);
TextStream.Write(': ');
TextStream.TextColor(ProperyValueColor);
TextStream.Write(FContextClass.ContextName());
TextStream.TextColor(PunctuationMarkColor);
TextStream.Write(', ');
TextStream.TextColor(PropertyNameColor);
TextStream.Write('Render');
TextStream.TextColor(PunctuationMarkColor);
TextStream.Write(': ');
TextStream.TextColor(ProperyValueColor);
TextStream.Write(FRenderClass.RenderName());
TextStream.TextColor(PunctuationMarkColor);
TextStream.Write(')');
TextStream.WriteLn();
TextStream.TextColor(DefaultColor);
SGKill(TextStream);
end;

function TSGContextHandler.Initialize() : TSGBoolean;
begin
Result := False;
ViewRunParams();
PrintSettings();
if not FRenderClass.Supported then
	begin
	SGHint(FRenderClass.ClassName() + ' not suppored!');
	SetLength(FSettings, 0);
	end
else
	begin
	// NVidia enabling high perfomance
	{$IFDEF MSWINDOWS}
	//SGNVidiaSetDriverOptimusMode(SGNVidiaHighPerfomance);
	{$ENDIF}
	
	FContext := FContextClass.Create();
	FIContext := FContext;
	
	FPaintableSettings := SetSettings();
	CheckPlacement();
	FContext.PaintableSettings := FPaintableSettings;
	FContext.InterfaceLink := @FIContext;
	FContext.ExtendedLink := @FContext;
	FContext.RenderClass := FRenderClass;
	FContext.Paintable := FPaintableClass;
	
	FContext.Initialize(FPlacement);
	
	Result := FContext.Active;
	end;
end;

procedure TSGContextHandler.Loop();
begin
if FContext.Active then
	begin
	repeat
	FContext.Run();
	SGHint([FContext.ClassName(), ' : Leaving from loop!'], [{$IFDEF CONTEXT_CHANGE_DEBUGING}SGCasePrint,{$ENDIF}SGCaseLog]);
	until not TryChangeContext();
	end;
end;

procedure TSGContextHandler.Kill();
begin
if (FContext <> nil) then
	FContext.Kill();
FIContext := nil;
if (FContext <> nil) then
	FContext.Destroy();
FContext := nil;
if (FSettings <> nil) then
	begin
	if (Length(FSettings) > 0) then
		SetLength(FSettings, 0);
	FSettings := nil;
	end;
end;

procedure TSGContextHandler.Run();
begin
if Initialize() then
	LoopAndKill();
end;

function TSGContextHandler.SetSettings() : TSGContextSettings;
var
	O : TSGContextOption;
begin
Result := nil;
for O in FSettings do
	begin
	if O.FName  = 'WIDTH' then
		FContext.Width := TSGMaxEnum(O.FOption)
	else if O.FName  = 'HEIGHT' then
		FContext.Height := TSGMaxEnum(O.FOption)
	else if O.FName  = 'LEFT' then
		FContext.Left := TSGMaxEnum(O.FOption)
	else if O.FName  = 'TOP' then
		FContext.Top := TSGMaxEnum(O.FOption)
	else if O.FName  = 'FULLSCREEN' then
		FContext.Fullscreen := TSGBool(TSGMaxEnum(O.FOption))
	else if O.FName  = 'CURSOR' then
		FContext.Cursor := TSGCursor(O.FOption)
	else if O.FName  = 'TITLE' then
		begin
		FContext.Title := SGPCharToString(PChar(O.FOption));
		FreeMem(O.FOption);
		end
	{$IFDEF ANDROID}
	else if (FContext is TSGContextAndroid) and (O.FName = 'ANDROIDAPP') then
		(FContext as TSGContextAndroid).AndroidApp := PAndroid_App(O.FOption)
		{$ENDIF}
	else
		begin
		Result += O;
		end;
	end;
if not ('WIDTH' in FSettings) then
	FContext.Width  := FContext.GetScreenArea().x;
if not ('HEIGHT' in FSettings) then
	FContext.Height  := FContext.GetScreenArea().y;
if not ('FULLSCREEN' in FSettings) then
	FContext.Fullscreen := {$IFDEF ANDROID}True{$ELSE}False{$ENDIF};
if not ('CURSOR' in FSettings) then
	FContext.Cursor := TSGCursor.Create(SGC_NORMAL);
if not ('TITLE' in FSettings) then
	FContext.Title := 'SaGe Engine Window';
end;

procedure TSGContextHandler.RegisterSettings(const _Settings : TSGContextSettings);
begin
SGKill(FSettings);
FSettings := _Settings;
end;

procedure TSGContextHandler.RegisterClasses(const _ContextClass : TSGContextClass; const _RenderClass : TSGRenderClass; const _PaintableClass : TSGPaintableObjectClass);
begin
FContextClass := _ContextClass;
FRenderClass := _RenderClass;
FPaintableClass := _PaintableClass;
end;

procedure TSGContextHandler.RegisterCompatibleClasses(const _PaintableClass : TSGPaintableObjectClass);
begin
FContextClass := TSGCompatibleContext;
FRenderClass := TSGCompatibleRender;
FPaintableClass := _PaintableClass;
end;

procedure TSGContextHandler.CheckPlacement();
var
	MinExists, MaxExists : TSGBool;
begin
MinExists := ('MIN' in FPaintableSettings);
MaxExists := ('MAX' in FPaintableSettings);
if MaxExists or MinExists then
	begin
	if MinExists xor MaxExists then
		begin
		FPaintableSettings -= (Iff(MinExists, 'MIN','') + Iff(MaxExists, 'MAX',''));
		if MaxExists then
			FPlacement := SGPlacementMaximized
		else if MinExists then
			FPlacement := SGPlacementMinimized;
		end
	else
		begin
		FPaintableSettings -= 'MAX';
		FPaintableSettings -= 'MIN';
		SGHint('Run : warning : maximization and minimization are not available at the same time!', SGCasesOfPrintFull, True);
		end;
	end;
end;

constructor TSGContextHandler.Create();
begin
inherited;
FContext := nil;
FIContext := nil;
FSettings := nil;
FPaintableSettings := nil;
FPlacement := SGPlacementNormal;
FPaintableClass := nil;
FContextClass := nil;
FRenderClass := nil;
FThread := nil;
end;

destructor TSGContextHandler.Destroy();
begin
SGKill(FThread);
inherited;
end;

end.
