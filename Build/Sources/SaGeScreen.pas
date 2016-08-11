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
	,SaGeContext
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

var
	SGScreen:TSGScreen = nil;

implementation

uses
	SaGeEngineConfigurationPanel;

var
	SGScreens:packed array of 
			packed record 
			FScreen:TSGScreen;
			FImage:TSGImage;
			end = nil;
	FOldPosition,FNewPosition:LongWord;
	FMoveProgress:Real = 0;
	FMoveVector:TSGVertex2f = (x:0;y:0);

{$DEFINE SCREEN_IMPLEMENTATION}
{$INCLUDE SaGeScreenComponents.inc}
{$UNDEF  SCREEN_IMPLEMENTATION}

procedure TSGScreen.Load(const VContext : ISGContext);
begin
{$IFDEF ANDROID}SGLog.Sourse('Enterind "SGScreenLoad". Context="'+SGStr(TSGMaxEnum(Pointer(Context)))+'"');{$ENDIF}

SetContext(VContext);
FSkin := TSGScreenSkin.CreateRandom(Context);
SetShifts(0, 0, 0, 0);
Visible := True;
Resize();

Font := TSGFont.Create(SGFontDirectory + Slash + 'Tahoma.sgf');
Font.SetContext(VContext);
Font.Loading();

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
for i:=0 to High(SGScreens) do
	if (SGScreens[i].FScreen<>nil) and (SGScreens[i].FScreen<>Self) then
		SGScreens[i].FScreen.FromUpDate(VCanReplace);

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

initialization
begin
FNewPosition:=0;
FOldPosition:=0;

SGScreen := TSGScreen.Create();

SetLength(SGScreens,1);
SGScreens[Low(SGScreens)].FScreen := SGScreen;
SGScreens[Low(SGScreens)].FImage  := nil;
end;

finalization
begin
if SGScreen <> nil then
	SGScreen.Destroy();
SGScreen := nil;
end;

end.
