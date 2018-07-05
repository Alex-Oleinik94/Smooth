{$INCLUDE SaGe.inc}

unit SaGeScreenSkin;

interface

uses
	 Crt
	
	,SaGeBase
	,SaGeClasses
	,SaGeImage
	,SaGeFont
	,SaGeRenderBase
	,SaGeResourceManager
	,SaGeCommonClasses
	,SaGeScreenBase
	,SaGeFileUtils
	,SaGeCommonStructs
	;

type
	TSGScreenSkinColors = object
		FNormal   : TSGScreenSkinFrameColor;
		FClick    : TSGScreenSkinFrameColor;
		FDisabled : TSGScreenSkinFrameColor;
		FOver     : TSGScreenSkinFrameColor;
		FText     : TSGScreenSkinFrameColor;
		end;
	
	TSGScreenSkin = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override; 
		constructor Create(const VContext : ISGContext; const VColors : TSGScreenSkinColors);virtual;
		constructor CreateRandom(const VContext : ISGContext);virtual;
		destructor Destroy();override;
		class function ClassName() : TSGString;override;
			protected
		FDeviceResourcesDeleted : TSGBool;
			public
		procedure DeleteDeviceResources();override;
		procedure LoadDeviceResources();override;
			public
		procedure UpDate(); virtual;
		function CreateDependentSkinWithAnotherFont(const VFont : TSGFont; const VDestroyFontSupported : TSGBool = False) : TSGScreenSkin; overload;
		function CreateDependentSkinWithAnotherFont(const VFontFileName : TSGString) : TSGScreenSkin; overload; deprecated;
			protected
		FOwner       : TSGScreenSkin;
		FColors      : TSGScreenSkinColors;
		FColorsTo    : TSGScreenSkinColors;
		FColorsFrom  : TSGScreenSkinColors;
		FColorsTimer : TSGScreenTimer;
		FFont        : TSGFont;
		FDestroyFontSuppored : TSGBool;
		procedure CreateFont(); virtual;
		procedure DestroyFont(); virtual;
		function FontAssigned() : TSGBool; virtual;
		function FontReady() : TSGBool; virtual;
		function GetFont() : TSGFont;virtual;
		procedure SetFont(const VFont : TSGFont); virtual;
		property Owner : TSGScreenSkin read FOwner write FOwner;
			public
		property DestroyFontSuppored : TSGBool read FDestroyFontSuppored write FDestroyFontSuppored;
		property Font : TSGFont read GetFont write SetFont;
		property Colors : TSGScreenSkinColors read FColors write FColors;
			protected
		FComboBoxImage : TSGImage;
		FMemoryBuffersSuppored : TSGBoolean;
			protected
		procedure PaintQuad(const Location : TSGComponentLocation; const LinesColor, QuadColor : TSGVertex4f; const ViewingLines : TSGBool = True; const ViewingQuad : TSGBool = True;const Radius : TSGFloat = 5); virtual;
		procedure PaintText(const Text : TSGString; const Location : TSGComponentLocation; const Color : TSGColor4f; const WidthCentered : TSGBoolean = True; const HeightCentered : TSGBoolean = True); virtual;
			public
		procedure PaintButton(constref Button : ISGButton); virtual;
		procedure PaintPanel(constref Panel : ISGPanel); virtual;
		procedure PaintComboBox(constref ComboBox : ISGComboBox); virtual;
		procedure PaintLabel(constref VLabel : ISGLabel); virtual;
		procedure PaintEdit(constref Edit : ISGEdit); virtual;
		procedure PaintProgressBar(constref ProgressBar : ISGProgressBar); virtual;
		end;
	TSGScreenSkinClass = class of TSGScreenSkin;
const
	SGScreenSkinDefaultFontFileName = SGFontDirectory + DirectorySeparator + 'Tahoma.sgf';

procedure SGKill(var Skin : TSGScreenSkin); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

function SGScreenSkinFrameColorImport(const VFirst, VSecond : TSGColor4f ): TSGScreenSkinFrameColor; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStandartSkinColors() : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGenerateRandomSkinColors(const Colors : TSGScreenSkinColors) : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGenerateUnequalRandomSkinColors(const Colors : TSGScreenSkinColors) : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

operator + (const A, B : TSGScreenSkinColors) : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (A : TSGScreenSkinColors; const B : TSGFloat) : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator = (A, B : TSGScreenSkinColors) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeStringUtils
	,SaGeMathUtils
	,SaGeRenderInterface
	,SaGeCommon
	,SaGeTextVertexObject
	,SaGeRectangleWithRoundedCorners
	;

procedure SGKill(var Skin : TSGScreenSkin); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (Skin <> nil) then
	begin
	Skin.Destroy();
	Skin := nil;
	end;
end;

operator + (const A, B : TSGScreenSkinColors) : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.FNormal.FFirst  := A.FNormal.FFirst  + B.FNormal.FFirst;
Result.FNormal.FSecond := A.FNormal.FSecond + B.FNormal.FSecond;

Result.FDisabled.FFirst  := A.FDisabled.FFirst  + B.FDisabled.FFirst;
Result.FDisabled.FSecond := A.FDisabled.FSecond + B.FDisabled.FSecond;

Result.FOver.FFirst  := A.FOver.FFirst  + B.FOver.FFirst;
Result.FOver.FSecond := A.FOver.FSecond + B.FOver.FSecond;

Result.FClick.FFirst  := A.FClick.FFirst  + B.FClick.FFirst;
Result.FClick.FSecond := A.FClick.FSecond + B.FClick.FSecond;

Result.FText.FFirst  := A.FText.FFirst  + B.FText.FFirst;
Result.FText.FSecond := A.FText.FSecond + B.FText.FSecond;
end;

operator * (A : TSGScreenSkinColors; const B : TSGFloat) : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGUInt32;
begin
for i := 0 to (SizeOf(TSGScreenSkinColors) div SizeOf(TSGColor4f)) - 1 do
	begin
	PSGColor4f(@Result)[i] := PSGColor4f(@A)[i] * B;
	end;
end;

operator = (A, B : TSGScreenSkinColors) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGUInt32;
begin
Result := True;
for i := 0 to (SizeOf(TSGScreenSkinColors) div SizeOf(TSGColor4f)) - 1 do
	if PSGColor4f(@A)[i] <> PSGColor4f(@B)[i] then
		begin
		Result := False;
		break;
		end;
end;

function SGGenerateRandomSkinColors(const Colors : TSGScreenSkinColors) : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SwapFloat(var a, b : TSGFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	c : TSGFloat;
begin
c := a;
a := b;
b := c;
end;

begin
Result := Colors;
if Random(2) = 1 then
	begin
	SwapFloat(Result.FNormal.FFirst.x, Result.FNormal.FFirst.y);
	SwapFloat(Result.FNormal.FSecond.x, Result.FNormal.FSecond.y);
	
	SwapFloat(Result.FClick.FFirst.x, Result.FClick.FFirst.y);
	SwapFloat(Result.FClick.FSecond.x, Result.FClick.FSecond.y);
	
	SwapFloat(Result.FDisabled.FFirst.x, Result.FDisabled.FFirst.y);
	SwapFloat(Result.FDisabled.FSecond.x, Result.FDisabled.FSecond.y);
	
	SwapFloat(Result.FOver.FFirst.x, Result.FOver.FFirst.y);
	SwapFloat(Result.FOver.FSecond.x, Result.FOver.FSecond.y);
	end;
if Random(2) = 1 then
	begin
	SwapFloat(Result.FNormal.FFirst.x, Result.FNormal.FFirst.z);
	SwapFloat(Result.FNormal.FSecond.x, Result.FNormal.FSecond.z);
	
	SwapFloat(Result.FClick.FFirst.x, Result.FClick.FFirst.z);
	SwapFloat(Result.FClick.FSecond.x, Result.FClick.FSecond.z);
	
	SwapFloat(Result.FDisabled.FFirst.x, Result.FDisabled.FFirst.z);
	SwapFloat(Result.FDisabled.FSecond.x, Result.FDisabled.FSecond.z);
	
	SwapFloat(Result.FOver.FFirst.x, Result.FOver.FFirst.z);
	SwapFloat(Result.FOver.FSecond.x, Result.FOver.FSecond.z);
	end;
if Random(2) = 1 then
	begin
	SwapFloat(Result.FNormal.FFirst.z, Result.FNormal.FFirst.y);
	SwapFloat(Result.FNormal.FSecond.z, Result.FNormal.FSecond.y);
	
	SwapFloat(Result.FClick.FFirst.z, Result.FClick.FFirst.y);
	SwapFloat(Result.FClick.FSecond.z, Result.FClick.FSecond.y);
	
	SwapFloat(Result.FDisabled.FFirst.z, Result.FDisabled.FFirst.y);
	SwapFloat(Result.FDisabled.FSecond.z, Result.FDisabled.FSecond.y);
	
	SwapFloat(Result.FOver.FFirst.z, Result.FOver.FFirst.y);
	SwapFloat(Result.FOver.FSecond.z, Result.FOver.FSecond.y);
	end;
end;

procedure TSGScreenSkin.UpDate();
begin
if FOwner = nil then
	begin
	FColorsTimer += SGObjectTimerConst * Context.ElapsedTime / 3;
	if FColorsTimer > 1 then
		begin
		FColorsTimer := 0;
		FColorsFrom := FColorsTo;
		FColors := FColorsTo;
		FColorsTo := SGGenerateUnequalRandomSkinColors(FColorsFrom);
		end
	else
		FColors := FColorsFrom * (1 - FColorsTimer) + FColorsTo * FColorsTimer;
	end
else
	FColors := FOwner.Colors;
end;

constructor TSGScreenSkin.CreateRandom(const VContext : ISGContext);
begin
Create(VContext, SGGenerateRandomSkinColors(SGStandartSkinColors()));
end;

function SGStandartSkinColors() : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.FNormal.FFirst .Import(0,1/2,1,1);
Result.FNormal.FSecond.Import(0,3/4,1,1);

Result.FClick.FFirst .Import(1,1/2,0,1);
Result.FClick.FSecond.Import(1,1/4,0,1);
Result.FClick.FFirst  := Result.FClick.FFirst  * 1/2 + SGVertex4fImport(0.5,0.5,0.5,1) * 1/2;
Result.FClick.FSecond := Result.FClick.FSecond * 1/2 + SGVertex4fImport(0.7,0.7,0.7,1) * 1/2;

Result.FDisabled.FFirst .Import(8/10,8/10,8/10,1);
Result.FDisabled.FSecond.Import(1,1,1,1);

Result.FOver.FFirst .Import(0,9/10,1,1);
Result.FOver.FSecond.Import(0,1,1,1);

Result.FText.FFirst .Import(1,1,1,1);
Result.FText.FSecond.Import(0,0,0,1);
end;

function SGScreenSkinFrameColorImport(const VFirst, VSecond : TSGColor4f ):TSGScreenSkinFrameColor; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(VFirst, VSecond);
end;

function TSGScreenSkin.CreateDependentSkinWithAnotherFont(const VFont : TSGFont; const VDestroyFontSupported : TSGBool = False) : TSGScreenSkin; overload;
begin
Result := TSGScreenSkin.Create(Context);
Result.Font  := VFont;
Result.Owner := Self;
Result.DestroyFontSuppored := VDestroyFontSupported;
Result.UpDate();
end;

function TSGScreenSkin.CreateDependentSkinWithAnotherFont(const VFontFileName : TSGString) : TSGScreenSkin; overload;
var
	VFont : TSGFont;
begin
VFont := TSGFont.Create(VFontFileName);
VFont.Context := Context;
VFont.Loading();
Result := CreateDependentSkinWithAnotherFont(VFont, True);
end;

constructor TSGScreenSkin.Create(const VContext : ISGContext);
begin
Create(VContext, SGStandartSkinColors());
end;

function SGGenerateUnequalRandomSkinColors(const Colors : TSGScreenSkinColors) : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
repeat
Result := SGGenerateRandomSkinColors(Colors);
until Result <> Colors;
end;

procedure TSGScreenSkin.DeleteDeviceResources();
begin
if FDeviceResourcesDeleted then
	Exit;
FFont.DeleteDeviceResources();
FComboBoxImage.DeleteDeviceResources();
FDeviceResourcesDeleted := True;
inherited;
end;

procedure TSGScreenSkin.LoadDeviceResources();
begin
if not FDeviceResourcesDeleted then
	Exit;
FFont.LoadDeviceResources();
FComboBoxImage.LoadDeviceResources();
FDeviceResourcesDeleted := False;
inherited;
end;

constructor TSGScreenSkin.Create(const VContext : ISGContext; const VColors : TSGScreenSkinColors);
begin
inherited Create(VContext);
FColors := VColors;
FColorsTimer := 0;
FColorsFrom := FColors;
FColorsTo := SGGenerateUnequalRandomSkinColors(FColorsFrom);

FComboBoxImage := TSGImage.Create(SGTextureDirectory + DirectorySeparator + 'ComboBoxImage.sgia');
FComboBoxImage.SetContext(VContext);
FComboBoxImage.Loading();
FMemoryBuffersSuppored := Render.SupporedMemoryBuffers();

FDeviceResourcesDeleted := False;
FDestroyFontSuppored := True;
FFont := nil;

FOwner := nil;
end;

procedure TSGScreenSkin.CreateFont();
begin
DestroyFont();

FFont := TSGFont.Create(SGScreenSkinDefaultFontFileName);
FFont.Context := Context;
FFont.Loading();
end;

procedure TSGScreenSkin.DestroyFont();
begin
if FDestroyFontSuppored then
	SGKill(FFont)
else
	FFont := nil;
end;

function TSGScreenSkin.FontReady() : TSGBool;
begin
Result := FontAssigned;
if Result then
	Result := Font.Ready;
end;

function TSGScreenSkin.FontAssigned() : TSGBool;
begin
Result := FFont <> nil;
end;

procedure TSGScreenSkin.SetFont(const VFont : TSGFont); 
begin
if (FFont <> VFont) then
	DestroyFont();
FFont := VFont;
end;

function TSGScreenSkin.GetFont() : TSGFont;
begin
if not FontAssigned() then
	CreateFont();
Result := FFont;
end;

destructor TSGScreenSkin.Destroy();
begin
SGKill(FComboBoxImage);
DestroyFont();
inherited;
end;

class function TSGScreenSkin.ClassName() : TSGString;
begin
Result := 'TSGScreenSkin';
end;

procedure TSGScreenSkin.PaintQuad(const Location : TSGComponentLocation; const LinesColor, QuadColor : TSGVertex4f; const ViewingLines : TSGBool = True; const ViewingQuad : TSGBool = True;const Radius : TSGFloat = 5);
var
	Position, PositionAndSize : TSGRectangleWithRoundedCornersVector2;
begin
Position.Import(Location.Position.x, Location.Position.y);
PositionAndSize.Import(Location.Size.x, Location.Size.y);
PositionAndSize += Position;
SGRoundQuad(Render, Position, PositionAndSize, Radius, 10, LinesColor, QuadColor, ViewingLines, ViewingQuad);
end;

procedure TSGScreenSkin.PaintText(const Text : TSGString; const Location : TSGComponentLocation; const Color : TSGColor4f; const WidthCentered : TSGBoolean = True; const HeightCentered : TSGBoolean = True);
var
	Color4uint8 : TSGVector4uint8;
begin
if FMemoryBuffersSuppored then
	begin
	Color4uint8 := SGColor4fTo4uint8(Color);
	TSGTextVertexObject.Paint(Text, Render, Font, Color4uint8, Location.FloatPosition, Location.FloatPositionAndSize, WidthCentered, HeightCentered)
	end
else
	begin
	Render.Color(Color);
	Font.DrawFontFromTwoVertex2f(Text, Location.FloatPosition, Location.FloatPositionAndSize, WidthCentered, HeightCentered);
	end;
end;

procedure TSGScreenSkin.PaintPanel(constref Panel : ISGPanel);
var
	Location : TSGComponentLocation;
	ActiveTimer, VisibleTimer : TSGScreenTimer;
	ViewingQuad  : TSGBool;
	ViewingLines : TSGBool;
begin
ViewingLines := Panel.ViewingLines;
ViewingQuad := Panel.ViewingQuad;

if ViewingQuad or ViewingLines then
	begin
	Location := Panel.GetLocation();

	VisibleTimer := Panel.VisibleTimer;
	ActiveTimer := Panel.ActiveTimer;

	if (ActiveTimer < 1 - SGZero) then
		PaintQuad(Location,
			FColors.FDisabled.FFirst.WithAlpha(0.7*VisibleTimer*(1-ActiveTimer))*0.54,
			FColors.FDisabled.FSecond.WithAlpha(0.7*VisibleTimer*(1-ActiveTimer))*0.8,
			ViewingLines, ViewingQuad);

	if  (ActiveTimer > SGZero) and 
		(VisibleTimer > SGZero) then
		PaintQuad(Location,
			FColors.FNormal.FFirst.WithAlpha(0.3*VisibleTimer*ActiveTimer),
			FColors.FNormal.FSecond.WithAlpha(0.3*VisibleTimer*ActiveTimer)*1.3,
			ViewingLines, ViewingQuad);
	end;
end;

procedure TSGScreenSkin.PaintButton(constref Button : ISGButton);
var
	Location : TSGComponentLocation;
	Active, Visible : TSGBool;
	ActiveTimer, VisibleTimer, OverTimer, ClickTimer : TSGScreenTimer;
begin
Location := Button.GetLocation();

Active := Button.Active;
Visible := Button.Visible;

ClickTimer := Button.ClickTimer;
OverTimer := Button.OverTimer;
VisibleTimer := Button.VisibleTimer;
ActiveTimer := Button.ActiveTimer;

if (not Active) or (ActiveTimer < 1 - SGZero) then
	PaintQuad(Location,
		FColors.FDisabled.FFirst.WithAlpha(0.7*VisibleTimer*(1-ActiveTimer))*0.54,
		FColors.FDisabled.FSecond.WithAlpha(0.7*VisibleTimer*(1-ActiveTimer))*0.8,
		True);
if  (ActiveTimer > SGZero) and 
	(1-OverTimer>SGZero) and 
	(1-ClickTimer>SGZero) and
	(VisibleTimer>SGZero) then
	PaintQuad(Location,
		FColors.FNormal.FFirst.WithAlpha(0.3*VisibleTimer*(1-OverTimer)*(1-ClickTimer)*ActiveTimer),
		FColors.FNormal.FSecond.WithAlpha(0.3*VisibleTimer*(1-OverTimer)*(1-ClickTimer)*ActiveTimer)*1.3,
		True);
if  (ActiveTimer>SGZero) and 
	(OverTimer>SGZero) and 
	(1-ClickTimer>SGZero) and
	(VisibleTimer>SGZero) then
	PaintQuad(Location,
		FColors.FOver.FFirst.WithAlpha(0.5*VisibleTimer*OverTimer*(1-ClickTimer)*ActiveTimer),
		FColors.FOver.FSecond.WithAlpha(0.5*VisibleTimer*OverTimer*(1-ClickTimer)*ActiveTimer)*1.3,
		True);
if  (ActiveTimer>SGZero) and 
	(ClickTimer>SGZero) and
	(VisibleTimer>SGZero) then
	PaintQuad(Location,
		FColors.FClick.FFirst.WithAlpha(0.4*VisibleTimer*ClickTimer*ActiveTimer),
		FColors.FClick.FSecond.WithAlpha(0.3*VisibleTimer*ClickTimer*ActiveTimer)*1.3,
		True);
if (Button.Caption<>'') and FontReady and (VisibleTimer>SGZero) then
	PaintText(Button.Caption, Location, FColors.FText.FFirst.WithAlpha(VisibleTimer));
end;

procedure TSGScreenSkin.PaintComboBox(constref ComboBox : ISGComboBox);
var
	Location, TextLocation : TSGComponentLocation;
	ActiveTimer, VisibleTimer, OverTimer, ClickTimer, OpenTimer : TSGScreenTimer;

procedure PaintOpened(const OpenLocation : TSGComponentLocation); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function GetTextColor(const VOverTimer : TSGScreenTimer) : TSGVertex4f; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FColors.FText.FSecond * (VOverTimer) + FColors.FText.FFirst * (1 - VOverTimer);
Result.a := 0.9 * OpenTimer;
end;

var
	TextColor, DisabledTextColor : TSGVertex4f;

procedure PaintItem(const ItemLocation : TSGComponentLocation; var Item : TSGComboBoxItem); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function GetSelectedTextColor() : TSGVector4f; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FColors.FNormal.FFirst;
TSGColor3f(Result) := Result.Normalized();
Result.a := OpenTimer;
end;

var
	ItemTextColor : TSGVector4f;
begin
if Item.Over then
	begin
	PaintQuad(ItemLocation,
		FColors.FOver.FFirst .WithAlpha(0.3*OpenTimer)     * (1 - ClickTimer) + FColors.FClick.FFirst .WithAlpha(0.3*OpenTimer)     * ClickTimer,
		FColors.FOver.FSecond.WithAlpha(0.3*OpenTimer)*1.3 * (1 - ClickTimer) + FColors.FClick.FSecond.WithAlpha(0.3*OpenTimer)*1.3 * ClickTimer);
	end;
if Item.Selected and (not Item.Over) and Item.Active then
	ItemTextColor := GetSelectedTextColor()
else if Item.Selected and Item.Over and Item.Active then
	ItemTextColor := GetTextColor(1 - OverTimer)
else if Item.Active then
	ItemTextColor := TextColor
else
	ItemTextColor := DisabledTextColor;
PaintText(Item.Caption, ItemLocation,	 ItemTextColor);
end;

function GetScrollLocation() : TSGComponentLocation;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.SizeX := Location.SizeY;
Result.SizeY := Round(OpenLocation.Size.Y * (ComboBox.LinesCount / ComboBox.ItemsCount));
Result.PositionX := OpenLocation.PositionX + OpenLocation.SizeX - Location.SizeY;
Result.PositionY := Round(OpenLocation.PositionY + OpenLocation.Size.Y * (ComboBox.FirstItemIndex / ComboBox.ItemsCount));
end;

function GetItemLocation(const Index : TSGUInt32; const NeedPaintScroll : TSGBool = False):TSGComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := OpenLocation;
Result.SizeY := Round(Result.SizeY / ComboBox.LinesCount);
Result.PositionY := Result.PositionY + Index * Result.SizeY;
if NeedPaintScroll then
	Result.SizeX := Result.SizeX - Location.SizeY;
end;

var
	NeedPaintScroll : TSGBool;
	BodyColor : TSGVertex4f;
	Index : TSGMaxEnum;
begin
BodyColor := (FColors.FText.FSecond * (1 - OverTimer) + FColors.FText.FFirst * (OverTimer)) * 0.5 + 0.5 * FColors.FText.FFirst;
BodyColor *= 0.8;
TextColor := GetTextColor(OverTimer);
DisabledTextColor := FColors.FDisabled.FSecond * 0.1 + SGVertex4fImport(1,0,0,1) * 0.9;
DisabledTextColor.a := OpenTimer;

PaintQuad(OpenLocation,
	BodyColor.WithAlpha(OpenTimer),
	BodyColor.WithAlpha(OpenTimer)*1.3);

if ComboBox.LinesCount > 0 then
	begin
	NeedPaintScroll := ComboBox.ItemsCount > ComboBox.LinesCount;
	
	if NeedPaintScroll then
		PaintQuad(GetScrollLocation(),
			BodyColor.WithAlpha(OpenTimer),
			BodyColor.WithAlpha(OpenTimer)*1.3);
	
	for Index := 0 to ComboBox.LinesCount - 1 do
		PaintItem(GetItemLocation(Index, NeedPaintScroll), ComboBox.Items[Index + ComboBox.FirstItemIndex]);
	end;
end;

var
	MainItemColor : TSGVector4f;
begin
Location := ComboBox.GetLocation();

ClickTimer   := ComboBox.ClickTimer;
OverTimer    := ComboBox.OverTimer;
VisibleTimer := ComboBox.VisibleTimer;
ActiveTimer  := ComboBox.ActiveTimer;
OpenTimer    := ComboBox.OpenTimer;

if  (1 - OverTimer > SGZero) and 
	(1 - OpenTimer > SGZero)  then
	PaintQuad(Location,
		FColors.FNormal.FFirst.WithAlpha(0.3 * VisibleTimer * (1-OverTimer) * (1-ClickTimer) * ActiveTimer * (1 - OpenTimer)),
		FColors.FNormal.FSecond.WithAlpha(0.3 * VisibleTimer * (1-OverTimer) * (1-ClickTimer) * ActiveTimer * (1 - OpenTimer)) * 1.3);
if  (OverTimer > SGZero) and 
	(1-OpenTimer > SGZero)  then
	PaintQuad(Location,
		FColors.FOver.FFirst.WithAlpha(0.5 * VisibleTimer * OverTimer * (1-OpenTimer) * (1-ClickTimer) * ActiveTimer),
		FColors.FOver.FSecond.WithAlpha(0.5 * VisibleTimer * OverTimer * (1-OpenTimer) * (1-ClickTimer) * ActiveTimer) * 1.3);
if (ActiveTimer < 1 - SGZero) then
	PaintQuad(Location,
		FColors.FDisabled.FFirst.WithAlpha(0.7 * VisibleTimer * (1-ActiveTimer)) * 0.54,
		FColors.FDisabled.FSecond.WithAlpha(0.7 * VisibleTimer * (1-ActiveTimer)) * 0.8);
if  (ActiveTimer > SGZero) and 
	(ClickTimer > SGZero) and
	(OpenTimer < 1 - SGZero) and
	(VisibleTimer > SGZero) then
	PaintQuad(Location,
		FColors.FClick.FFirst.WithAlpha(0.4 * VisibleTimer * ClickTimer * (1-OpenTimer) * ActiveTimer),
		FColors.FClick.FSecond.WithAlpha(0.3 * VisibleTimer * ClickTimer * (1-OpenTimer) * ActiveTimer) * 1.3);

if OpenTimer > SGZero then
	begin
	TextLocation := Location;
	TextLocation.SizeY := Round(TextLocation.SizeY * ( 1 + (ComboBox.LinesCount - 1) * OpenTimer));
	
	PaintOpened(TextLocation);
	end
else
	TextLocation := Location;

if 1 - OpenTimer > SGZero then
	begin
	MainItemColor := FColors.FText.FFirst.WithAlpha(Sqr((1 - OpenTimer) * VisibleTimer));
	
	if (FComboBoxImage <> nil) then
		begin
		Render.Color(MainItemColor);
		
		FComboBoxImage.DrawImageFromTwoVertex2fAsRatio(
			TextLocation.FloatPositionAndSize - TSGComponentLocationVectorFloat.Create(Location.SizeY, TextLocation.SizeY),
			TextLocation.FloatPositionAndSize,
			False,0.5);
		end;
	
	if (ComboBox.GetSelectedItem() <> nil) then
		PaintText(ComboBox.GetSelectedItem()^.Caption, TextLocation, MainItemColor);
	end;
end;

procedure TSGScreenSkin.PaintLabel(constref VLabel : ISGLabel); 
var
	Location : TSGComponentLocation;
	Color4f     : TSGVector4f;
begin
if (VLabel.Caption <> '') and FontReady then
	begin
	Location := VLabel.GetLocation();
	if VLabel.TextColorSeted then
		Color4f := VLabel.TextColor.WithAlpha(VLabel.VisibleTimer)
	else
		Color4f := FColors.FText.FFirst.WithAlpha(VLabel.VisibleTimer);
	PaintText(VLabel.Caption, Location, Color4f, VLabel.TextPosition, True);
	end;
end;

procedure TSGScreenSkin.PaintEdit(constref Edit : ISGEdit); 
var
	TextLocation, Location : TSGComponentLocation;
	Active, Visible : TSGBool;
	ActiveTimer, VisibleTimer, OverTimer, TextCompliteTimer : TSGScreenTimer;
	
	NormalFirst, NormalSecond : TSGColor4f;
	RedColor  : TSGColor4f;
	GreenColor : TSGColor4f;
begin
Location := Edit.GetLocation();

Active := Edit.Active;
Visible := Edit.Visible;

OverTimer := Edit.OverTimer;
VisibleTimer := Edit.VisibleTimer;
ActiveTimer := Edit.ActiveTimer;

NormalFirst  := FColors.FNormal.FFirst;
NormalSecond := FColors.FNormal.FSecond;

if Edit.TextTypeAssigned then
	begin
	TextCompliteTimer := Edit.TextCompliteTimer;
	RedColor.Import(1, 0, 0, 1);
	GreenColor.Import(0, 1, 0, 1);
	
	NormalFirst := (TextCompliteTimer  * GreenColor + (1 - TextCompliteTimer) * RedColor) * 0.85;
	NormalSecond := TextCompliteTimer  * GreenColor + (1 - TextCompliteTimer) * RedColor;
	end;

if  (ActiveTimer>SGZero) and 
	(VisibleTimer>SGZero) then
	PaintQuad(Location,
		NormalFirst .WithAlpha(0.4 * VisibleTimer * ActiveTimer),
		NormalSecond.WithAlpha(0.3 * VisibleTimer * ActiveTimer) * 1.3,
		True, True, 2);

if FontReady and (Edit.Caption <> '') then
	begin
	TextLocation := Location;
	TextLocation.Left := TextLocation.Left + 3;
	TextLocation.Width := TextLocation.Width - 9;
	
	PaintText(Edit.Caption, TextLocation, TSGVector4f.Create(1, 1, 1, VisibleTimer), False);
	if (Edit.CursorTimer > 0) and Edit.NowEditing then
		begin
		Render.Color4f(1, 0.5, 0, VisibleTimer * Edit.CursorTimer);
		Font.DrawCursorFromTwoVertex2f(Edit.Caption, Edit.CursorPosition, TextLocation.FloatPosition, TextLocation.FloatPositionAndSize, False);
		end;
	end;
end;

procedure TSGScreenSkin.PaintProgressBar(constref ProgressBar : ISGProgressBar);
var
	Location, Location2 : TSGComponentLocation;
	Active, Visible : TSGBool;
	ActiveTimer, VisibleTimer : TSGScreenTimer;
	FrameColor : TSGScreenSkinFrameColor;
	Radius : TSGFloat;
begin
Radius := 5;
Location := ProgressBar.GetLocation();
Location2 := Location;
Location2.SizeX := Round(Location2.Size.X * ProgressBar.Progress);

Active := ProgressBar.Active;
Visible := ProgressBar.Visible;

VisibleTimer := ProgressBar.VisibleTimer;
ActiveTimer := ProgressBar.ActiveTimer;
if Location2.Size.X < Radius then
	Radius := Location2.Size.X / 2.001;

PaintQuad(Location,
	FColors.FOver.FFirst .WithAlpha(0.4 * VisibleTimer * ActiveTimer),
	FColors.FOver.FSecond.WithAlpha(0.3 * VisibleTimer * ActiveTimer) * 1.3,
	True, False, Radius);

if ProgressBar.ViewProgress then
	begin
	if ProgressBar.IsColorStatic then
		FrameColor := ProgressBar.Color
	else
		FrameColor := FColors.FNormal;
	PaintQuad(Location2,
		FrameColor.FFirst .WithAlpha(0.4 * VisibleTimer * ActiveTimer),
		FrameColor.FSecond.WithAlpha(0.3 * VisibleTimer * ActiveTimer) * 1.3,
		True, True, Radius);
	end;

if FontReady and ProgressBar.ViewCaption then 
	PaintText(SGStringIf(ProgressBar.ViewCaption, ProgressBar.Caption + ' ') + SGFloatToString(100 * ProgressBar.Progress , 2) + '%', 
		Location, TSGVector4f.Create(1, 1, 1, VisibleTimer));
end;

end.
