{$INCLUDE Smooth.inc}

unit SmoothContextHandler;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothContext
	,SmoothRender
	,SmoothCasesOfPrint
	,SmoothThreads
	,SmoothContextUtils
	{$IF defined(ANDROID)}
		,android_native_app_glue
		{$ENDIF}
	;

type
	TSContextHandler = class(TSNamed)
			public
		constructor Create(); override;
		destructor Destroy(); override;
			protected
		FContext : TSContext;
		FIContext : ISContext;
		FSettings : TSContextSettings;
		FPaintableSettings : TSPaintableSettings;
		FPlacement : TSContextWindowPlacement;
		FPaintableClass : TSPaintableObjectClass;
		FContextClass : TSContextClass;
		FRenderClass : TSRenderClass;
		FThread : TSThread;
			protected
		procedure CheckPlacement();
		function SetSettings() : TSContextSettings;
		function TryChangeContext() : TSBoolean;
		procedure PrintSettings(const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog]);
		function GetPaintableExemplar() : TSPaintableObject;
		procedure ViewRunParams();
			public
		property PaintableClass : TSPaintableObjectClass read FPaintableClass write FPaintableClass;
		property Context : TSContext read FContext;
		property PaintableExemplar : TSPaintableObject read GetPaintableExemplar;
			public
		procedure RegisterSettings(const _Settings : TSContextSettings);
		procedure RegisterClasses(const _ContextClass : TSContextClass; const _RenderClass : TSRenderClass; const _PaintableClass : TSPaintableObjectClass);
		procedure RegisterCompatibleClasses(const _PaintableClass : TSPaintableObjectClass);
		function Initialize() : TSBoolean;
		procedure Run();
		procedure Loop();
		procedure RunAnotherThread();
		procedure Kill();
		procedure LoopAndKill();
		end;

procedure SKill(var ContextHandler : TSContextHandler); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
procedure SRunPaintable(const _PaintableClass : TSPaintableObjectClass; const _ContextClass : TSContextClass; const _RenderClass : TSRenderClass; const _Settings : TSContextSettings = nil);
procedure SCompatibleRunPaintable(const _PaintableClass : TSPaintableObjectClass; const _Settings : TSContextSettings = nil);

implementation

uses
	 SmoothAudioRender
	,SmoothBaseUtils
	,SmoothLists
	,SmoothCursor
	,SmoothLog
	,SmoothStringUtils
	,SmoothTextMultiStream
	,SmoothTextLogStream
	{$IFDEF ANDROID}
		,SmoothContextAndroid
		{$ENDIF}
	{$IFDEF MSWINDOWS}
		,SmoothNvidiaOptimusEnablement
		,SmoothNvidiaDriverSettingsUtils
		{$ENDIF}
	;

procedure SRunPaintable(const _PaintableClass : TSPaintableObjectClass; const _ContextClass : TSContextClass; const _RenderClass : TSRenderClass; const _Settings : TSContextSettings = nil);
begin
with TSContextHandler.Create() do
	begin
	RegisterClasses(_ContextClass, _RenderClass, _PaintableClass);
	RegisterSettings(_Settings);
	Run();
	Destroy();
	end;
end;

procedure SCompatibleRunPaintable(const _PaintableClass : TSPaintableObjectClass; const _Settings : TSContextSettings = nil);
var
	Settings : TSContextSettings = nil;
begin
Settings := SContextSettingsCopy(_Settings);
if (not ('AUDIORENDER' in Settings)) and (TSCompatibleAudioRender <> nil) then
	Settings += SContextOptionAudioRender(TSCompatibleAudioRender);
SRunPaintable(_PaintableClass, TSCompatibleContext, TSCompatibleRender, Settings);
SetLength(Settings, 0);
end;

procedure SKill(var ContextHandler : TSContextHandler); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
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

function TSContextHandler.GetPaintableExemplar() : TSPaintableObject;
begin
Result := nil;
if (FContext <> nil) then
	Result := FContext.PaintableExemplar;
end;

procedure TSContextHandler_ThreadProcedure_Run(ContextHandler : TSContextHandler);
begin
ContextHandler.Run();
end;

procedure TSContextHandler.RunAnotherThread();
begin
SKill(FThread);
FThread := TSThread.Create(TSThreadProcedure(@TSContextHandler_ThreadProcedure_Run), Self, True);
end;

procedure TSContextHandler.LoopAndKill();
begin
Loop();
Kill();
end;

procedure TSContextHandler.PrintSettings(const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog]);

function WordName(const S : TSString) : TSString;
begin
Result := SDownCaseString(S);
if Length(Result) > 0 then
	Result[1] := UpCase(Result[1]);
end;

const
	DefaultColor = 7;
	PropertyNameColor = 15;
	ProperyValueColor = 10;
	PunctuationMarkColor = 14;
var
	TextStream : TSTextMultiStream = nil;
	O : TSContextOption;
	First : TSBoolean = True;
	StandartOptions : TSStringList = nil;
	i : TSUInt32;
begin
if (FSettings = nil) or (Length(FSettings) = 0) then
	exit;
TextStream := TSTextMultiStream.Create(SCasesOfPrintFull);
TextStream.Get(TSTextLogStream).Write(SLogDateTimeString());
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
	if (O.FName = 'FULLSCREEN') and (TSMaxEnum(O.FOption) = 0) then
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
		TextStream.Write(SStr(TSMaxEnum(O.FOption)));
		end
	else if O.FName = 'AUDIORENDER' then
		begin
		TextStream.TextColor(PunctuationMarkColor);
		TextStream.Write(': ');
		TextStream.TextColor(ProperyValueColor);
		TextStream.Write(TSAudioRenderClass(O.FOption).AudioRenderName());
		end
	else if O.FName = 'TITLE' then
		begin
		TextStream.TextColor(PunctuationMarkColor);
		TextStream.Write('=' + '''');
		TextStream.TextColor(ProperyValueColor);
		TextStream.Write(SPCharToString(PChar(O.FOption)));
		TextStream.TextColor(PunctuationMarkColor);
		TextStream.Write('''');
		end
	else if (O.FName = 'FILES TO OPEN') then
		begin
		TextStream.TextColor(PunctuationMarkColor);
		TextStream.Write('=[');
		if Length(TSStringList(O.FOption)) > 0 then
			for i := 0 to High(TSStringList(O.FOption)) do
				begin
				if i <> 0 then
					begin
					TextStream.TextColor(PunctuationMarkColor);
					TextStream.Write(', ');
					end;
				TextStream.TextColor(PunctuationMarkColor);
				TextStream.Write('`');
				TextStream.TextColor(ProperyValueColor);
				TextStream.Write(TSStringList(O.FOption)[i]);
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
		TextStream.Write(SAddrStr(O.FOption));
		end;
	end;
SetLength(StandartOptions, 0);
TextStream.TextColor(PunctuationMarkColor);
TextStream.Write(')');
TextStream.WriteLn();
TextStream.TextColor(DefaultColor);
SKill(TextStream);
end;

function TSContextHandler.TryChangeContext() : TSBoolean;
// Result = True : Continue loop
// Result = False : Exit loop
var
	NewContext : TSContext = nil;
	OldContextName : TSString = '';
begin
Result := False;
{$IFDEF CONTEXT_CHANGE_DEBUGING}
	SLog.Source(['STryChangeContextType(Context=',SAddrStr(FContext),', IContext=',SAddrStr(FIContext),'). Enter.']);
	{$ENDIF}
if (FContext.NewContext <> nil) and (FContext.Active or (not (FContext is FContext.NewContext))) then
	begin
	OldContextName := FContext.ContextName();
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SLog.Source(['STryChangeContextType(Context=',SAddrStr(FContext),', IContext=',SAddrStr(FIContext),'). Begin changing.']);
		SLog.Source(['STryChangeContextType(Context=',SAddrStr(FContext),', IContext=',SAddrStr(FIContext),'). Creating new context.']);
		{$ENDIF}
	NewContext := FContext.NewContext.Create();
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SLog.Source(['STryChangeContextType(Context=',SAddrStr(FContext),', IContext=',SAddrStr(FIContext),'). Delete old context device recources.']);
		{$ENDIF}
	FContext.DeleteRenderResources();
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SLog.Source(['STryChangeContextType(Context=',SAddrStr(FContext),', IContext=',SAddrStr(FIContext),'). Moving info.']);
		{$ENDIF}
	NewContext.MoveInfo(FContext);
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SLog.Source(['STryChangeContextType(Context=',SAddrStr(FContext),', IContext=',SAddrStr(FIContext),'). Change "IContext".']);
		{$ENDIF}
	FIContext := NewContext;
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SLog.Source(['STryChangeContextType(Context=',SAddrStr(FContext),', IContext=',SAddrStr(FIContext),'). Destroying old context.']);
		{$ENDIF}
	FContext.Destroy();
	{$IFDEF CONTEXT_CHANGE_DEBUGING}
		SLog.Source(['STryChangeContextType(Context=',SAddrStr(FContext),', IContext=',SAddrStr(FIContext),'). Initializing new context.']);
		{$ENDIF}
	FContext := NewContext;
	FContext.Initialize();
	FContext.LoadRenderResources();
	Result := FContext.Active;
	SHint(['Changing context (' + OldContextName + ' --> ' + FContext.ContextName() + ')' + Iff(Result, ' successfull.', ' failed!')]);
	end;
{$IFDEF CONTEXT_CHANGE_DEBUGING}
	SLog.Source(['STryChangeContextType(Context=',SAddrStr(FContext),', IContext=',SAddrStr(FIContext),'). Leave.']);
	{$ENDIF}
end;

procedure TSContextHandler.ViewRunParams();
const
	DefaultColor = 7;
	PropertyNameColor = 15;
	ProperyValueColor = 10;
	PunctuationMarkColor = 14;
var
	TextStream : TSTextMultiStream = nil;
begin
TextStream := TSTextMultiStream.Create(SCasesOfPrintFull);
TextStream.Get(TSTextLogStream).Write(SLogDateTimeString());
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
SKill(TextStream);
end;

function TSContextHandler.Initialize() : TSBoolean;
begin
Result := False;
ViewRunParams();
PrintSettings();
if not FRenderClass.Supported then
	begin
	SHint(FRenderClass.ClassName() + ' not suppored!');
	SetLength(FSettings, 0);
	end
else
	begin
	// NVidia enabling high perfomance
	{$IFDEF MSWINDOWS}
	//SNVidiaSetDriverOptimusMode(SNVidiaHighPerfomance);
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

procedure TSContextHandler.Loop();
begin
if FContext.Active then
	begin
	repeat
	FContext.Run();
	SHint([FContext.ClassName(), ' : Leaving from loop!'], [{$IFDEF CONTEXT_CHANGE_DEBUGING}SCasePrint,{$ENDIF}SCaseLog]);
	until not TryChangeContext();
	end;
end;

procedure TSContextHandler.Kill();
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

procedure TSContextHandler.Run();
begin
if Initialize() then
	LoopAndKill();
end;

function TSContextHandler.SetSettings() : TSContextSettings;
var
	O : TSContextOption;
begin
Result := nil;
for O in FSettings do
	begin
	if O.FName  = 'WIDTH' then
		FContext.Width := TSMaxEnum(O.FOption)
	else if O.FName  = 'HEIGHT' then
		FContext.Height := TSMaxEnum(O.FOption)
	else if O.FName  = 'LEFT' then
		FContext.Left := TSMaxEnum(O.FOption)
	else if O.FName  = 'TOP' then
		FContext.Top := TSMaxEnum(O.FOption)
	else if O.FName  = 'FULLSCREEN' then
		FContext.Fullscreen := TSBool(TSMaxEnum(O.FOption))
	else if O.FName  = 'CURSOR' then
		FContext.Cursor := TSCursor(O.FOption)
	else if O.FName  = 'TITLE' then
		begin
		FContext.Title := SPCharToString(PChar(O.FOption));
		FreeMem(O.FOption);
		end
	{$IFDEF ANDROID}
	else if (FContext is TSContextAndroid) and (O.FName = 'ANDROIDAPP') then
		(FContext as TSContextAndroid).AndroidApp := PAndroid_App(O.FOption)
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
	FContext.Cursor := TSCursor.Create(SC_NORMAL);
if not ('TITLE' in FSettings) then
	FContext.Title := 'Smooth Engine Window';
end;

procedure TSContextHandler.RegisterSettings(const _Settings : TSContextSettings);
begin
SKill(FSettings);
FSettings := _Settings;
end;

procedure TSContextHandler.RegisterClasses(const _ContextClass : TSContextClass; const _RenderClass : TSRenderClass; const _PaintableClass : TSPaintableObjectClass);
begin
FContextClass := _ContextClass;
FRenderClass := _RenderClass;
FPaintableClass := _PaintableClass;
end;

procedure TSContextHandler.RegisterCompatibleClasses(const _PaintableClass : TSPaintableObjectClass);
begin
FContextClass := TSCompatibleContext;
FRenderClass := TSCompatibleRender;
FPaintableClass := _PaintableClass;
end;

procedure TSContextHandler.CheckPlacement();
var
	MinExists, MaxExists : TSBool;
begin
MinExists := ('MIN' in FPaintableSettings);
MaxExists := ('MAX' in FPaintableSettings);
if MaxExists or MinExists then
	begin
	if MinExists xor MaxExists then
		begin
		FPaintableSettings -= (Iff(MinExists, 'MIN','') + Iff(MaxExists, 'MAX',''));
		if MaxExists then
			FPlacement := SPlacementMaximized
		else if MinExists then
			FPlacement := SPlacementMinimized;
		end
	else
		begin
		FPaintableSettings -= 'MAX';
		FPaintableSettings -= 'MIN';
		SHint('Run : warning : maximization and minimization are not available at the same time!', SCasesOfPrintFull, True);
		end;
	end;
end;

constructor TSContextHandler.Create();
begin
inherited;
FContext := nil;
FIContext := nil;
FSettings := nil;
FPaintableSettings := nil;
FPlacement := SPlacementNormal;
FPaintableClass := nil;
FContextClass := nil;
FRenderClass := nil;
FThread := nil;
end;

destructor TSContextHandler.Destroy();
begin
SKill(FThread);
inherited;
end;

end.
