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
	,SaGeContext
	,SaGeUtils
	,SaGeRenderConstants
	,SaGeResourseManager
	,SaGeCommonClasses
	,SaGeScreenBase
	;

type
	TSGScreenSkinFrameColor = object
			public
		FFirst  : TSGColor4f;
		FSecond : TSGColor4f;
			public
		procedure Import(const VFirst, VSecond : TSGColor4f ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;
	
	TSGScreenSkinColors = object
		FNormal   : TSGScreenSkinFrameColor;
		FClick    : TSGScreenSkinFrameColor;
		FDisabled : TSGScreenSkinFrameColor;
		FOver     : TSGScreenSkinFrameColor;
		FText     : TSGScreenSkinFrameColor;
		end;
	
	TSGScreenSkin = class(TSGContextabled)
			public
		constructor Create(const VContext : ISGContext);override; 
		constructor Create(const VContext : ISGContext; const VColors : TSGScreenSkinColors);virtual;
		constructor CreateRandom(const VContext : ISGContext);virtual;
		destructor Destroy();override;
		class function ClassName() : TSGString;override;
		procedure IddleFunction(); virtual;
			protected
		FColors      : TSGScreenSkinColors;
		FColorsTo    : TSGScreenSkinColors;
		FColorsFrom  : TSGScreenSkinColors;
		FColorsTimer : TSGScreenTimer;
			protected
		FComboBoxImage : TSGImage;
			public
		property Colors : TSGScreenSkinColors read FColors write FColors;
			protected
		procedure PaintQuad(const Location : TSGComponentLocation; const LinesColor, QuadColor : TSGVertex4f; const ViewingLines : TSGBool = True; const ViewingQuad : TSGBool = True); virtual;
			public
		procedure PaintButton(const Button : ISGButton); virtual;
		procedure PaintPanel(const Panel : ISGPanel); virtual;
		procedure PaintComboBox(const ComboBox : ISGComboBox); virtual;
		procedure PaintLabel(const VLabel : ISGLabel); virtual;
		end;

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
end;

constructor TSGScreenSkin.CreateRandom(const VContext : ISGContext);
begin
Create(VContext, SGGenerateRandomSkinColors(SGStandartSkinColors()));
end;

function SGStandartSkinColors() : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.FNormal.FFirst.Import(0,1/2,1,1);
Result.FNormal.FSecond.Import(0,3/4,1,1);

Result.FClick.FFirst.Import(5/10,5/10,5/10,1);
Result.FClick.FSecond.Import(7/10,7/10,7/10,1);

Result.FDisabled.FFirst.Import(8/10,8/10,8/10,1);
Result.FDisabled.FSecond.Import(1,1,1,1);

Result.FOver.FFirst.Import(0,9/10,1,1);
Result.FOver.FSecond.Import(0,1,1,1);

Result.FText.FFirst.Import(1,1,1,1);
Result.FText.FSecond.Import(0,0,0,1);
end;

function SGScreenSkinFrameColorImport(const VFirst, VSecond : TSGColor4f ):TSGScreenSkinFrameColor; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(VFirst, VSecond);
end;

procedure TSGScreenSkinFrameColor.Import(const VFirst, VSecond : TSGColor4f ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FFirst  := VFirst;
FSecond := FSecond;
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
end;

destructor TSGScreenSkin.Destroy();
begin
inherited;
end;

class function TSGScreenSkin.ClassName() : TSGString;
begin
Result := 'TSGScreenSkin';
end;

procedure TSGScreenSkin.PaintQuad(const Location : TSGComponentLocation; const LinesColor, QuadColor : TSGVertex4f; const ViewingLines : TSGBool = True; const ViewingQuad : TSGBool = True);
begin
SGRoundQuad(Render, Location.Position, Location.Position + Location.Size, 5, 10, LinesColor, QuadColor, ViewingLines, ViewingQuad);
end;

procedure TSGScreenSkin.PaintPanel(const Panel : ISGPanel);
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

procedure TSGScreenSkin.PaintButton(const Button : ISGButton);
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
if (Button.Caption<>'') and (Button.Font<>nil) and (Button.Font.Ready) and (VisibleTimer>SGZero) then
	begin
	Render.Color(FColors.FText.FFirst.WithAlpha(VisibleTimer));
	Button.Font.DrawFontFromTwoVertex2f(Button.Caption, Location.Position, Location.Position + Location.Size);
	end;
end;

procedure TSGScreenSkin.PaintComboBox(const ComboBox : ISGComboBox);
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
TSGVertex3f(SelectedTextColor) := SelectedTextColor.Normalized();
SelectedTextColor.a := OpenTimer;
Render.Color(SelectedTextColor);
end;

begin
if Item.Over then
	begin
	PaintQuad(ItemLocation,
		FColors.FOver.FFirst.WithAlpha(0.3*OpenTimer),
		FColors.FOver.FSecond.WithAlpha(0.3*OpenTimer)*1.3);
	end;

if Item.Selected and (not Item.Over) and Item.Active then
	SetSelectedTextColor()
else if Item.Selected and Item.Over and Item.Active then
	Render.Color(GetTextColor(1 - OverTimer))
else if Item.Active then
	Render.Color(TextColor)
else
	Render.Color(DisabledTextColor);
ComboBox.Font.DrawFontFromTwoVertex2f(Item.Caption, ItemLocation.Position, ItemLocation.Position + ItemLocation.Size);
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

if  (1 - OverTimer>SGZero) and 
	(1 - OpenTimer>SGZero)  then
	PaintQuad(Location,
		FColors.FNormal.FFirst.WithAlpha(0.3*VisibleTimer*(1-OverTimer)*(1-ClickTimer)*ActiveTimer*(1 - OpenTimer)),
		FColors.FNormal.FSecond.WithAlpha(0.3*VisibleTimer*(1-OverTimer)*(1-ClickTimer)*ActiveTimer*(1 - OpenTimer))*1.3);
if  (OverTimer>SGZero) and 
	(1-OpenTimer>SGZero)  then
	PaintQuad(Location,
		FColors.FOver.FFirst.WithAlpha(0.5*VisibleTimer*OverTimer*(1-OpenTimer)*(1-ClickTimer)*ActiveTimer),
		FColors.FOver.FSecond.WithAlpha(0.5*VisibleTimer*OverTimer*(1-OpenTimer)*(1-ClickTimer)*ActiveTimer)*1.3);
if (ActiveTimer < 1 - SGZero) then
	PaintQuad(Location,
		FColors.FDisabled.FFirst.WithAlpha(0.7*VisibleTimer*(1-ActiveTimer))*0.54,
		FColors.FDisabled.FSecond.WithAlpha(0.7*VisibleTimer*(1-ActiveTimer))*0.8);
if  (ActiveTimer>SGZero) and 
	(ClickTimer>SGZero) and
	(VisibleTimer>SGZero) then
	PaintQuad(Location,
		FColors.FClick.FFirst.WithAlpha(0.4*VisibleTimer*ClickTimer*ActiveTimer),
		FColors.FClick.FSecond.WithAlpha(0.3*VisibleTimer*ClickTimer*ActiveTimer)*1.3);

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
		ComboBox.Font.DrawFontFromTwoVertex2f(ComboBox.GetSelectedItem()^.Caption, TextLocation.Position, TextLocation.Position + TextLocation.Size);
		end;
	end;
end;

procedure TSGScreenSkin.PaintLabel(const VLabel : ISGLabel); 
var
	Location : TSGComponentLocation;
begin
if (VLabel.Caption<>'') and (VLabel.Font<>nil) and (VLabel.Font.Ready) then
	begin
	Location := VLabel.GetLocation();
	if VLabel.TextColorSeted then
		Render.Color(VLabel.TextColor.WithAlpha(VLabel.VisibleTimer))
	else
		Render.Color(FColors.FText.FFirst.WithAlpha(VLabel.VisibleTimer));
	VLabel.Font.DrawFontFromTwoVertex2f(VLabel.Caption,
		Location.Position, Location.Position + Location.Size,
		VLabel.TextPosition);
	end;
end;

end.
