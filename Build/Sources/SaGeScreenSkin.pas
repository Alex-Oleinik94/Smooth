{$INCLUDE SaGe.inc}

unit SaGeScreenSkin;

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
	,SaGeResourceManager
	,SaGeCommonClasses
	,SaGeScreenBase
	;

type
	TSGScreenSkin = class;
	
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
		procedure DeleteDeviceResources();override;
		procedure LoadDeviceResources();override;
			public
		procedure IddleFunction(); virtual;
		function CreateDependentSkinWithAnotherFont(const VFont : TSGFont; const VDestroyFontSupored : TSGBool = False) : TSGScreenSkin; overload;
		function CreateDependentSkinWithAnotherFont(const VFontFileName : TSGString) : TSGScreenSkin; overload;
			protected
		FOwner : TSGScreenSkin;
		procedure CopyColors(var VColors : TSGScreenSkinColors); virtual;
		property Owner : TSGScreenSkin read FOwner write FOwner;
			protected
		FColors      : TSGScreenSkinColors;
		FColorsTo    : TSGScreenSkinColors;
		FColorsFrom  : TSGScreenSkinColors;
		FColorsTimer : TSGScreenTimer;
			protected
		FFont : TSGFont;
		FDestroyFontSuppored : TSGBool;
		procedure CreateFont(); virtual;
		procedure DestroyFont(); virtual;
		function FontAssigned() : TSGBool; virtual;
		function FontReady() : TSGBool; virtual;
		function GetFont() : TSGFont;virtual;
		procedure SetFont(const VFont : TSGFont); virtual;
			public
		property DestroyFontSuppored : TSGBool read FDestroyFontSuppored write FDestroyFontSuppored;
		property Font : TSGFont read GetFont write SetFont;
			protected
		FComboBoxImage : TSGImage;
			public
		property Colors : TSGScreenSkinColors read FColors write FColors;
			protected
		procedure PaintQuad(const Location : TSGComponentLocation; const LinesColor, QuadColor : TSGVertex4f; const ViewingLines : TSGBool = True; const ViewingQuad : TSGBool = True;const Radius : TSGUInt8 = 5); virtual;
			public
		procedure PaintButton(constref Button : ISGButton); virtual;
		procedure PaintPanel(constref Panel : ISGPanel); virtual;
		procedure PaintComboBox(constref ComboBox : ISGComboBox); virtual;
		procedure PaintLabel(constref VLabel : ISGLabel); virtual;
		procedure PaintEdit(constref Edit : ISGEdit); virtual;
		procedure PaintProgressBar(constref ProgressBar : ISGProgressBar); virtual;
		end;
const
	SGScreenSkinDefaultFontFileName = SGFontDirectory + Slash + 'Tahoma.sgf';

function SGScreenSkinFrameColorImport(const VFirst, VSecond : TSGColor4f ): TSGScreenSkinFrameColor; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStandartSkinColors() : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGenerateRandomSkinColors(const Colors : TSGScreenSkinColors) : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGenerateUnequalRandomSkinColors(const Colors : TSGScreenSkinColors) : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

operator + (const A, B : TSGScreenSkinColors) : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (A : TSGScreenSkinColors; const B : TSGFloat) : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator = (A, B : TSGScreenSkinColors) : TSGBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

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

procedure TSGScreenSkin.IddleFunction();
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
	FOwner.CopyColors(FColors);
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

procedure TSGScreenSkin.CopyColors(var VColors : TSGScreenSkinColors); 
begin
VColors := FColors;
end;

function TSGScreenSkin.CreateDependentSkinWithAnotherFont(const VFont : TSGFont; const VDestroyFontSupored : TSGBool = False) : TSGScreenSkin; overload;
begin
Result := TSGScreenSkin.Create(Context);
Result.Font  := VFont;
Result.Owner := Self;
Result.DestroyFontSuppored := VDestroyFontSupored;
Result.IddleFunction();
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
FFont.DeleteDeviceResources();
FComboBoxImage.DeleteDeviceResources();
inherited;
end;

procedure TSGScreenSkin.LoadDeviceResources();
begin
FFont.LoadDeviceResources();
FComboBoxImage.LoadDeviceResources();
inherited;
end;

constructor TSGScreenSkin.Create(const VContext : ISGContext; const VColors : TSGScreenSkinColors);
begin
inherited Create(VContext);
FColors := VColors;
FColorsTimer := 0;
FColorsFrom := FColors;
FColorsTo := SGGenerateUnequalRandomSkinColors(FColorsFrom);

FComboBoxImage := TSGImage.Create(SGTextureDirectory + Slash + 'ComboBoxImage.sgia');
FComboBoxImage.SetContext(VContext);
FComboBoxImage.Loading();

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
if FDestroyFontSuppored and (FFont <> nil) then
	begin
	FFont.Destroy();
	FFont := nil;
	end;
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
SGKillImage(FComboBoxImage);
DestroyFont();
inherited;
end;

class function TSGScreenSkin.ClassName() : TSGString;
begin
Result := 'TSGScreenSkin';
end;

procedure TSGScreenSkin.PaintQuad(const Location : TSGComponentLocation; const LinesColor, QuadColor : TSGVertex4f; const ViewingLines : TSGBool = True; const ViewingQuad : TSGBool = True;const Radius : TSGUInt8 = 5);
begin
SGRoundQuad(Render, Location.Position, Location.Position + Location.Size, Radius, 10, LinesColor, QuadColor, ViewingLines, ViewingQuad);
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
	begin
	Render.Color(FColors.FText.FFirst.WithAlpha(VisibleTimer));
	Font.DrawFontFromTwoVertex2f(Button.Caption, Location.Position, Location.Position + Location.Size);
	end;
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

procedure SetSelectedTextColor(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	SelectedTextColor : TSGVertex4f;
begin
SelectedTextColor := FColors.FNormal.FFirst;
TSGColor3f(SelectedTextColor) := SelectedTextColor.Normalized();
SelectedTextColor.a := OpenTimer;
Render.Color(SelectedTextColor);
end;

begin
if Item.Over then
	begin
	PaintQuad(ItemLocation,
		FColors.FOver.FFirst .WithAlpha(0.3*OpenTimer)     * (1 - ClickTimer) + FColors.FClick.FFirst .WithAlpha(0.3*OpenTimer)     * ClickTimer,
		FColors.FOver.FSecond.WithAlpha(0.3*OpenTimer)*1.3 * (1 - ClickTimer) + FColors.FClick.FSecond.WithAlpha(0.3*OpenTimer)*1.3 * ClickTimer);
	end;

if Item.Selected and (not Item.Over) and Item.Active then
	SetSelectedTextColor()
else if Item.Selected and Item.Over and Item.Active then
	Render.Color(GetTextColor(1 - OverTimer))
else if Item.Active then
	Render.Color(TextColor)
else
	Render.Color(DisabledTextColor);
Font.DrawFontFromTwoVertex2f(Item.Caption, ItemLocation.Position, ItemLocation.Position + ItemLocation.Size);
end;

function GetScrollLocation() : TSGComponentLocation;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.SizeX := Location.SizeY;
Result.SizeY := OpenLocation.Size.Y * (ComboBox.Lines / ComboBox.ItemsCount);
Result.PositionX := OpenLocation.PositionX + OpenLocation.SizeX - Location.SizeY;
Result.PositionY := OpenLocation.PositionY + OpenLocation.Size.Y * (ComboBox.FirstItemIndex / ComboBox.ItemsCount);
end;

function GetItemLocation(const Index : TSGUInt32; const NeedPaintScroll : TSGBool = False):TSGComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := OpenLocation;
Result.SizeY := Result.SizeY / ComboBox.Lines;
Result.PositionY := Result.PositionY + Index * Result.SizeY;
if NeedPaintScroll then
	Result.SizeX := Result.SizeX - Location.SizeY;
end;

var
	NeedPaintScroll : TSGBool;
	BodyColor : TSGVertex4f;
	i : TSGUInt32;
begin
BodyColor := (FColors.FText.FSecond * (1 - OverTimer) + FColors.FText.FFirst * (OverTimer)) * 0.5 + 0.5 * FColors.FText.FFirst;
BodyColor *= 0.8;
TextColor := GetTextColor(OverTimer);
DisabledTextColor := FColors.FDisabled.FSecond * 0.1 + SGVertex4fImport(1,0,0,1) * 0.9;
DisabledTextColor.a := OpenTimer;

PaintQuad(OpenLocation,
	BodyColor.WithAlpha(OpenTimer),
	BodyColor.WithAlpha(OpenTimer)*1.3);

if ComboBox.Lines > 0 then
	begin
	NeedPaintScroll := ComboBox.ItemsCount > ComboBox.Lines;
	
	if NeedPaintScroll then
		PaintQuad(GetScrollLocation(),
			BodyColor.WithAlpha(OpenTimer),
			BodyColor.WithAlpha(OpenTimer)*1.3);
	
	for i := 0 to ComboBox.Lines - 1 do
		PaintItem(GetItemLocation(i, NeedPaintScroll), ComboBox.Items[i + ComboBox.FirstItemIndex]);
	end;
end;

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
	TextLocation.SizeY := TextLocation.SizeY * ( 1 + (ComboBox.Lines - 1) * OpenTimer);
	
	PaintOpened(TextLocation);
	end
else
	TextLocation := Location;

if 1 - OpenTimer > SGZero then
	begin
	if (FComboBoxImage<>nil) then
		begin
		Render.Color(FColors.FText.FFirst.WithAlpha(Sqr((1 - OpenTimer) * VisibleTimer)));
		
		FComboBoxImage.DrawImageFromTwoVertex2fAsRatio(
			TextLocation.Position + TextLocation.Size - SGVertex2fImport(Location.SizeY, TextLocation.SizeY),
			TextLocation.Position + TextLocation.Size,
			False,0.5);
		end;
	if ComboBox.GetSelectedItem() <> nil then
		begin
		Font.DrawFontFromTwoVertex2f(ComboBox.GetSelectedItem()^.Caption, TextLocation.Position, TextLocation.Position + TextLocation.Size);
		end;
	end;
end;

procedure TSGScreenSkin.PaintLabel(constref VLabel : ISGLabel); 
var
	Location : TSGComponentLocation;
begin
if (VLabel.Caption <> '') and FontReady then
	begin
	Location := VLabel.GetLocation();
	if VLabel.TextColorSeted then
		Render.Color(VLabel.TextColor.WithAlpha(VLabel.VisibleTimer))
	else
		Render.Color(FColors.FText.FFirst.WithAlpha(VLabel.VisibleTimer));
	Font.DrawFontFromTwoVertex2f(VLabel.Caption,
		Location.Position, Location.Position + Location.Size,
		VLabel.TextPosition);
	end;
end;

procedure TSGScreenSkin.PaintEdit(constref Edit : ISGEdit); 
var
	Location : TSGComponentLocation;
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
	Render.Color4f(1, 1, 1, VisibleTimer);
	Font.DrawFontFromTwoVertex2f(Edit.Caption, Location.Position + SGX(3), Location.Position + Location.Size - SGX(6), False);
	if (Edit.CursorTimer > 0) and Edit.NowEditing then
		begin
		Render.Color4f(1, 0.5, 0, VisibleTimer * Edit.CursorTimer);
		Font.DrawCursorFromTwoVertex2f(Edit.Caption, Edit.CursorPosition, Location.Position + SGX(3), Location.Position + Location.Size - SGX(6), False);
		end;
	end;
{if ((not FActive) or (FActiveTimer<1-SGZero)) and (FVisibleTimer>SGZero) then
	begin
	SGRoundQuad(Render,
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		2,
		10,
		SGVertex4fImport(0,0,0,0),
		ThreeColor2.WithAlpha(0.7*FVisibleTimer*(1-FActiveTimer)),
		True);
	end;
ReqAct := ReqursiveActive();
if (1-FNowChangetTimer>SGZero) then
		begin
		TempTimer := (1-FCursorOnComponentTimer)*(1-FNowChangetTimer);
		if not ReqAct then
			TempTimer := 1;
		SGRoundQuad(Render,
			SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
			SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
			2,10,
			((FirsColor1*Byte(FTextType=SGEditTypeText)+
				Byte(FTextType<>SGEditTypeText)*(FirsColor4*FTextCompliteTimer+FirsColor3*(1-FTextCompliteTimer))))
					.WithAlpha(0.3*FVisibleTimer*TempTimer*FActiveTimer),
			((FirsColor2*Byte(FTextType=SGEditTypeText)+
				Byte(FTextType<>SGEditTypeText)*(SecondColor4*FTextCompliteTimer+SecondColor3*(1-FTextCompliteTimer))))
					.WithAlpha(0.3*FVisibleTimer*TempTimer*FActiveTimer)*1.3,
			True);
		end;
if ReqAct and (FVisibleTimer*FCursorOnComponentTimer*(1-FNowChangetTimer)*FActiveTimer>SGZero) then
SGRoundQuad(Render,
	SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
	SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
	2,10,
	((SecondColor1/1.3+1.3*Byte(FTextType<>SGEditTypeText)*(FirsColor4*FTextCompliteTimer+FirsColor3*(1-FTextCompliteTimer)))/(1+Byte(FTextType<>SGEditTypeText)))
		.WithAlpha(0.3/(1-0.4*(Byte(FTextType<>SGEditTypeText)))*FVisibleTimer*FCursorOnComponentTimer*(1-FNowChangetTimer)*FActiveTimer),
	(((SecondColor2/1.3+1.3*Byte(FTextType<>SGEditTypeText)*(SecondColor4*FTextCompliteTimer+SecondColor3*(1-FTextCompliteTimer))))/(1+Byte(FTextType<>SGEditTypeText)))
		.WithAlpha(0.3/(1-0.4*(Byte(FTextType<>SGEditTypeText)))*FVisibleTimer*FCursorOnComponentTimer*(1-FNowChangetTimer)*FActiveTimer)*1.3,
	True);
if (FVisibleTimer*FNowChangetTimer*FActiveTimer>SGZero) then
SGRoundQuad(Render,
	SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
	SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
	2,10,
	((ThreeColor1*Byte(FTextType=SGEditTypeText)+
		Byte(FTextType<>SGEditTypeText)*(FirsColor4*FTextCompliteTimer+FirsColor3*(1-FTextCompliteTimer))))
		.WithAlpha(0.4*FVisibleTimer*FNowChangetTimer*FActiveTimer),
	((ThreeColor2*Byte(FTextType=SGEditTypeText)+
		Byte(FTextType<>SGEditTypeText)*(SecondColor4*FTextCompliteTimer+SecondColor3*(1-FTextCompliteTimer))*2))
		.WithAlpha(0.3*FVisibleTimer*FNowChangetTimer*FActiveTimer)*1.3,
	True);}
end;

procedure TSGScreenSkin.PaintProgressBar(constref ProgressBar : ISGProgressBar);
var
	Location, Location2 : TSGComponentLocation;
	Active, Visible : TSGBool;
	ActiveTimer, VisibleTimer : TSGScreenTimer;
	FrameColor : TSGScreenSkinFrameColor;
	Radius : TSGFloat = 2;
begin
Location := ProgressBar.GetLocation();

Active := ProgressBar.Active;
Visible := ProgressBar.Visible;

VisibleTimer := ProgressBar.VisibleTimer;
ActiveTimer := ProgressBar.ActiveTimer;

PaintQuad(Location,
	FColors.FOver.FFirst .WithAlpha(0.4 * VisibleTimer * ActiveTimer),
	FColors.FOver.FSecond.WithAlpha(0.3 * VisibleTimer * ActiveTimer) * 1.3,
	True, False, 5);

if ProgressBar.ViewProgress then
	begin
	Location2 := Location;
	Location2.SizeX := Location2.Size.X * ProgressBar.Progress;
	if Location2.Size.X < Radius then
		Radius := Location2.Size.X / 2.001;
	if ProgressBar.IsColorStatic then
		FrameColor := ProgressBar.Color
	else
		FrameColor := FColors.FNormal;
	PaintQuad(Location2,
		FrameColor.FFirst .WithAlpha(0.4 * VisibleTimer * ActiveTimer),
		FrameColor.FSecond.WithAlpha(0.3 * VisibleTimer * ActiveTimer) * 1.3,
		True, True, 5);
	end;

if FontReady and ProgressBar.ViewCaption then 
	begin
	Render.Color4f(1, 1, 1, VisibleTimer);
	Font.DrawFontFromTwoVertex2f(
		SGStringIf(ProgressBar.ViewCaption, ProgressBar.Caption + ' ') + SGFloatToString(100 * ProgressBar.Progress , 2) + '%',
		Location.Position, Location.Position + Location.Size);
	end;
end;

end.
