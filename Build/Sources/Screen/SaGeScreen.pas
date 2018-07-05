{$INCLUDE SaGe.inc}

//{$DEFINE SCREEN_DEBUG}

unit SaGeScreen;

interface

uses
	 SaGeBase
	,SaGeContextClasses
	,SaGeContextInterface
	,SaGeScreenBase
	,SaGeScreenComponent
	;

type
	TSGScreen = class(TSGComponent, ISGScreen)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
			private
		FInProcessing : TSGBoolean;
			public
		procedure Load(const VContext : ISGContext);
		procedure Resize();override;
		procedure Paint();override;
		procedure CustomPaint();
		procedure UpDateScreen();
			public
		property InProcessing : TSGBoolean read FInProcessing write FInProcessing;
		end;
type
	ISGScreened = interface(ISGContextabled)
		['{01b2e610-7d81-4db4-bece-19222fbffde9}']
		function GetScreen() : TSGScreen;
		function ScreenAssigned() : TSGBoolean;

		property Screen : TSGScreen read GetScreen;
		end;
type
	TSGScreened = class(TSGContextabled, ISGScreened)
			public
		class function ClassName() : TSGString; override;
			public
		function GetScreen() : TSGScreen; virtual;
		function ScreenAssigned() : TSGBoolean; virtual;
			public
		property Screen : TSGScreen read GetScreen;
		end;
type
	TSGScreenedDrawable = class(TSGDrawable, ISGScreened)
			public
		class function ClassName() : TSGString; override;
			public
		function GetScreen() : TSGScreen; virtual;
		function ScreenAssigned() : TSGBoolean; virtual;
			public
		property Screen : TSGScreen read GetScreen;
		end;

implementation

uses
	 SaGeEngineConfigurationPanel
	,SaGeLog
	,SaGeRenderBase
	,SaGeScreenSkin
	,SaGeContextUtils
	;

class function TSGScreened.ClassName() : TSGString;
begin
Result := 'TSGScreened';
end;

class function TSGScreen.ClassName() : TSGString;
begin
Result := 'TSGScreen';
end;

class function TSGScreenedDrawable.ClassName() : TSGString;
begin
Result := 'TSGScreenedDrawable';
end;

function TSGScreenedDrawable.ScreenAssigned() : TSGBoolean;
begin
Result := ContextAssigned();
if Result then
	Result := FContext^.Screen <> nil;
end;

function TSGScreenedDrawable.GetScreen() : TSGScreen;
begin
if ContextAssigned() then
	Result := TSGScreen(FContext^.Screen)
else
	Result := nil;
end;

function TSGScreened.ScreenAssigned() : TSGBoolean;
begin
Result := ContextAssigned();
if Result then
	Result := FContext^.Screen <> nil;
end;

function TSGScreened.GetScreen() : TSGScreen;
begin
if ContextAssigned() then
	Result := TSGScreen(FContext^.Screen)
else
	Result := nil;
end;

// =======================
// ====== TSGScreen ======
// =======================

constructor TSGScreen.Create();
begin
inherited Create();
FInProcessing := False;
end;

destructor TSGScreen.Destroy();
begin
FInProcessing := False;
inherited;
end;

procedure TSGScreen.Load(const VContext : ISGContext);
begin
{$IFDEF ANDROID}TSGLog.Source('Enterind "SGScreenLoad". Context="' + SGAddrStr(VContext) + '"');{$ENDIF}
Context := VContext;
SGKill(FSkin);
FSkin := TSGScreenSkin.CreateRandom(Context);
Visible := True;
Resize();
{$IFDEF ANDROID}TSGLog.Source('Leaving "SGScreenLoad".');{$ENDIF}
end;

procedure TSGScreen.Resize();
begin
if RenderAssigned() then if Render.Width <> 0 then if Render.Height <> 0 then
	begin
	SetBounds(0, 0, Render.Width, Render.Height);
	BoundsMakeReal();
	FromResize();
	end;
end;

procedure TSGScreen.CustomPaint();
begin
InProcessing := True;
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Before "DrawDrawClasses();"');
	{$ENDIF}
DrawDrawClasses();
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Before over updating');
	{$ENDIF}

Render.LineWidth(1);
Render.InitMatrixMode(SG_2D);

{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Before drawing');
	{$ENDIF}

FromDraw();
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Beining');
	{$ENDIF}
InProcessing := False;
end;

procedure TSGScreen.UpDateScreen();
begin
InProcessing := True;
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.UpDateScreen() : Before "FromUpDateUnderCursor(CanRePleace);"');
	{$ENDIF}
FromUpDateUnderCursor();
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.UpDateScreen() : Before "FromUpDate(CanRePleace);"');
	{$ENDIF}
FromUpDate();
InProcessing := False;
end;

procedure TSGScreen.Paint();
begin
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Beining, before check ECP');
	{$ENDIF}

if (Context.KeysPressed(SG_CTRL_KEY)) and
   (Context.KeysPressed(SG_ALT_KEY)) and
   (Context.KeyPressedType = SGDownKey) and
   (Context.KeyPressedChar = 'O') and
   TSGEngineConfigurationPanel.CanCreate(Self) then
	begin
	CreateChild(TSGEngineConfigurationPanel.Create()).FromResize();
	Context.SetKey(SGNullKey, 0);
	end;

UpDateScreen();
Skin.UpDate();
CustomPaint();
end;

end.
