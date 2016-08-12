{$INCLUDE Includes\SaGe.inc}

//{$DEFINE CLHINTS}
//{$DEFINE SCREEN_DEBUG}

unit SaGeScreen;

interface

uses
	 Crt
	,SaGeCommon
	,SaGeBase
	,SaGeClasses
	,SaGeBased
	,SaGeImages
	,SaGeUtils
	,SaGeRenderConstants
	,SaGeResourseManager
	,SaGeCommonClasses
	,SaGeScreenBase
	,SaGeScreenSkin
	;

type
	TSGForm             = class;
	TSGButton           = class;
	TSGEdit             = class;
	TSGLabel            = class;
	TSGProgressBar      = class;
	TSGPanel            = class;
	TSGPicture          = class;
	TSGButtonMenu       = class;
	TSGScrollBar        = class;
	TSGComboBox         = class;
	TSGGrid             = class;
	TSGButtonMenuButton = class;
	TSGScreen           = class;

{$DEFINE SCREEN_INTERFACE}
{$INCLUDE SaGeScreenComponents.inc}
{$UNDEF  SCREEN_INTERFACE}

type
	TSGScreen = class(TSGComponent, ISGScreen)
			public
		constructor Create();override;
		destructor Destroy();override;
			private
		FInProcessing : TSGBoolean;
			public
		procedure Load(const VContext : ISGContext);
		procedure Resize();override;
		procedure Paint();override;
		procedure DeleteDeviceResourses();override;
		procedure LoadDeviceResourses();override;
		procedure CustomPaint(VCanReplace : TSGBool);
		function UpDateScreen() : TSGBoolean;
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
		function GetScreen() : TSGScreen; virtual;
		function ScreenAssigned() : TSGBoolean; virtual;
			public
		property Screen : TSGScreen read GetScreen;
		end;
type
	TSGScreenedDrawable = class(TSGDrawable, ISGScreened)
			public
		function GetScreen() : TSGScreen; virtual;
		function ScreenAssigned() : TSGBoolean; virtual;
			public
		property Screen : TSGScreen read GetScreen;
		end;

implementation

uses
	 SaGeEngineConfigurationPanel
	,SaGeContext
	;

{$DEFINE SCREEN_IMPLEMENTATION}
{$INCLUDE SaGeScreenComponents.inc}
{$UNDEF  SCREEN_IMPLEMENTATION}

function TSGScreenedDrawable.ScreenAssigned() : TSGBoolean;
begin
Result := ContextAssigned();
if Result then
	Result := FContext^.Screen <> nil;
end;

function TSGScreenedDrawable.GetScreen() : TSGScreen;
begin
if ContextAssigned() then
	Result := TSGScreen(FContext^.Screen);
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
	Result := TSGScreen(FContext^.Screen);
end;

// ====================================== TSGScreen

procedure TSGScreen.DeleteDeviceResourses();
begin 
FSkin.DeleteDeviceResourses();
inherited;
end;

procedure TSGScreen.LoadDeviceResourses();
begin
FSkin.LoadDeviceResourses();
inherited;
end;

constructor TSGScreen.Create();
begin
inherited Create();
FInProcessing := False;
end;

destructor TSGScreen.Destroy();
begin
inherited;
end;

procedure TSGScreen.Load(const VContext : ISGContext);
begin
{$IFDEF ANDROID}SGLog.Sourse('Enterind "SGScreenLoad". Context="'+SGStr(TSGMaxEnum(Pointer(Context)))+'"');{$ENDIF}
Context := VContext;
FSkin := TSGScreenSkin.CreateRandom(Context);
SetShifts(0, 0, 0, 0);
Visible := True;
Resize();
{$IFDEF ANDROID}SGLog.Sourse('Leaving "SGScreenLoad".');{$ENDIF}
end;

procedure TSGScreen.Resize();
begin
if RenderAssigned() then if Render.Width <> 0 then if Render.Height <> 0 then
	begin
	SetBounds(0, 0, Render.Width, Render.Height);
	BoundsToNeedBounds();
	FromResize();
	end;
end;

procedure TSGScreen.CustomPaint(VCanReplace : TSGBool);
var
	i : TSGLongWord;
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

VCanReplace:=False;

{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Before drawing');
	{$ENDIF}

FromDraw();
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Beining');
	{$ENDIF}
InProcessing := False;
end;

function TSGScreen.UpDateScreen() : TSGBoolean;
begin
InProcessing := True;
Result := True;
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.UpDateScreen() : Before "FromUpDateUnderCursor(CanRePleace);"');
	{$ENDIF}
FromUpDateUnderCursor(Result);
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.UpDateScreen() : Before "FromUpDate(CanRePleace);"');
	{$ENDIF}
FromUpDate(Result);
InProcessing := False;
end;

procedure TSGScreen.Paint();
var
	CanRePleace : TSGBoolean;
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
	Context.SetKey(SGNullKey,0);
	end;

CanRePleace := UpDateScreen();
Skin.IddleFunction();
CustomPaint(CanRePleace);
end;

end.
