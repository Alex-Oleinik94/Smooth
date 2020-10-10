{$INCLUDE Smooth.inc}

unit SmoothScreenSkin;

interface

uses
	 SmoothBase
	,SmoothBaseClasses
	,SmoothImage
	,SmoothFont
	,SmoothRenderBase
	,SmoothResourceManager
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothScreenBase
	,SmoothFileUtils
	,SmoothCommonStructs
	,SmoothScreenComponentInterfaces
	,SmoothScreenSkinInterface
	;

type
	TSScreenSkinColors = object
			public
		FNormal   : TSScreenSkinFrameColor;
		FClick    : TSScreenSkinFrameColor; // dinamic change colour O_O
		FDisabled : TSScreenSkinFrameColor;
		FOver     : TSScreenSkinFrameColor;
		FText     : TSScreenSkinFrameColor;
		end;
	
	TSScreenSkin = class(TSContextObject, ISScreenSkin)
			public
		constructor Create(const VContext : ISContext);override; 
		constructor Create(const VContext : ISContext; const VColors : TSScreenSkinColors);virtual;
		constructor CreateRandom(const VContext : ISContext);virtual;
		destructor Destroy();override;
		class function ClassName() : TSString;override;
			protected
		FDeviceResourcesDeleted : TSBool;
			public
		procedure DeleteRenderResources();override;
		procedure LoadRenderResources();override;
			public
		procedure UpDate(); virtual;
		function CreateDependentSkinWithAnotherFont(const VFont : TSFont; const VDestroyFontSupported : TSBool = False) : TSScreenSkin; overload;
		function CreateDependentSkinWithAnotherFont(const VFontFileName : TSString) : TSScreenSkin; overload; deprecated;
			protected
		FOwner       : TSScreenSkin;
		FColors      : TSScreenSkinColors;
		FColorsTo    : TSScreenSkinColors;
		FColorsFrom  : TSScreenSkinColors;
		FColorsTimer : TSScreenTimer;
		FFont        : TSFont;
		FDestroyFontSupported : TSBool;
		procedure CreateFont(); virtual;
		procedure DestroyFont(); virtual;
		function FontAssigned() : TSBool; virtual;
		function FontReady() : TSBool; virtual;
		function GetFont() : TSFont;virtual;
		procedure SetFont(const VFont : TSFont); virtual;
		property Owner : TSScreenSkin read FOwner write FOwner;
			public
		property DestroyFontSupported : TSBool read FDestroyFontSupported write FDestroyFontSupported;
		property Font : TSFont read GetFont write SetFont;
		property Colors : TSScreenSkinColors read FColors write FColors;
			protected
		FComboBoxImage : TSImage;
			protected
		procedure PaintQuad(const Location : TSComponentLocation; const LinesColor, QuadColor : TSVertex4f; const ViewingLines : TSBool = True; const ViewingQuad : TSBool = True;const Radius : TSFloat = 5); virtual;
		procedure PaintText(const Text : TSString; const Location : TSComponentLocation; const Color : TSColor4f; const WidthCentered : TSBoolean = True; const HeightCentered : TSBoolean = True); virtual;
			public
		procedure PaintButton(constref Button : ISButton); virtual;
		procedure PaintPanel(constref Panel : ISPanel); virtual;
		procedure PaintComboBox(constref ComboBox : ISComboBox); virtual;
		procedure PaintLabel(constref VLabel : ISLabel); virtual;
		procedure PaintEdit(constref Edit : ISEdit); virtual;
		procedure PaintProgressBar(constref ProgressBar : ISProgressBar); virtual;
		procedure PaintForm(constref Form : ISForm); virtual;
		end;
	TSScreenSkinClass = class of TSScreenSkin;
const
	SScreenSkinDefaultFontFileName = SDefaultFontFileName;

procedure SKill(var Skin : TSScreenSkin); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

function SScreenSkinFrameColorImport(const VFirst, VSecond : TSColor4f ): TSScreenSkinFrameColor; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SStandartSkinColors() : TSScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGenerateRandomSkinColors(const Colors : TSScreenSkinColors) : TSScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGenerateUnequalRandomSkinColors(const Colors : TSScreenSkinColors) : TSScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

operator + (const A, B : TSScreenSkinColors) : TSScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator * (A : TSScreenSkinColors; const B : TSFloat) : TSScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator = (A, B : TSScreenSkinColors) : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothStringUtils
	,SmoothArithmeticUtils
	,SmoothRenderInterface
	,SmoothCommon
	,SmoothTextVertexObject
	,SmoothRectangleWithRoundedCorners
	;

procedure SKill(var Skin : TSScreenSkin); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (Skin <> nil) then
	begin
	Skin.Destroy();
	Skin := nil;
	end;
end;

operator + (const A, B : TSScreenSkinColors) : TSScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

operator * (A : TSScreenSkinColors; const B : TSFloat) : TSScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSUInt32;
begin
for i := 0 to (SizeOf(TSScreenSkinColors) div SizeOf(TSColor4f)) - 1 do
	begin
	PSColor4f(@Result)[i] := PSColor4f(@A)[i] * B;
	end;
end;

operator = (A, B : TSScreenSkinColors) : TSBool;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSUInt32;
begin
Result := True;
for i := 0 to (SizeOf(TSScreenSkinColors) div SizeOf(TSColor4f)) - 1 do
	if PSColor4f(@A)[i] <> PSColor4f(@B)[i] then
		begin
		Result := False;
		break;
		end;
end;

function SGenerateRandomSkinColors(const Colors : TSScreenSkinColors) : TSScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SwapFloat(var a, b : TSFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	c : TSFloat;
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

procedure TSScreenSkin.UpDate();
begin
if FOwner = nil then
	begin
	FColorsTimer += SObjectTimerConst * Context.ElapsedTime / 3;
	if FColorsTimer > 1 then
		begin
		FColorsTimer := 0;
		FColorsFrom := FColorsTo;
		FColors := FColorsTo;
		FColorsTo := SGenerateUnequalRandomSkinColors(FColorsFrom);
		end
	else
		FColors := FColorsFrom * (1 - FColorsTimer) + FColorsTo * FColorsTimer;
	end
else
	FColors := FOwner.Colors;
end;

constructor TSScreenSkin.CreateRandom(const VContext : ISContext);
begin
Create(VContext, SGenerateRandomSkinColors(SStandartSkinColors()));
end;

function SStandartSkinColors() : TSScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.FNormal.FFirst .Import(0,1/2,1,1);
Result.FNormal.FSecond.Import(0,3/4,1,1);

Result.FClick.FFirst .Import(1,1/2,0,1);
Result.FClick.FSecond.Import(1,1/4,0,1);
Result.FClick.FFirst  := Result.FClick.FFirst  * 1/2 + SVertex4fImport(0.5,0.5,0.5,1) * 1/2;
Result.FClick.FSecond := Result.FClick.FSecond * 1/2 + SVertex4fImport(0.7,0.7,0.7,1) * 1/2;

Result.FDisabled.FFirst .Import(8/10,8/10,8/10,1);
Result.FDisabled.FSecond.Import(1,1,1,1);

Result.FOver.FFirst .Import(0,9/10,1,1);
Result.FOver.FSecond.Import(0,1,1,1);

Result.FText.FFirst .Import(1,1,1,1);
Result.FText.FSecond.Import(0,0,0,1);
end;

function SScreenSkinFrameColorImport(const VFirst, VSecond : TSColor4f ):TSScreenSkinFrameColor; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(VFirst, VSecond);
end;

function TSScreenSkin.CreateDependentSkinWithAnotherFont(const VFont : TSFont; const VDestroyFontSupported : TSBool = False) : TSScreenSkin; overload;
begin
Result := TSScreenSkin.Create(Context);
Result.Font  := VFont;
Result.Owner := Self;
Result.DestroyFontSupported := VDestroyFontSupported;
Result.UpDate();
end;

function TSScreenSkin.CreateDependentSkinWithAnotherFont(const VFontFileName : TSString) : TSScreenSkin; overload;
var
	VFont : TSFont;
begin
VFont := SCreateFontFromFile(Context, VFontFileName);
Result := CreateDependentSkinWithAnotherFont(VFont, True);
end;

constructor TSScreenSkin.Create(const VContext : ISContext);
begin
Create(VContext, SStandartSkinColors());
end;

function SGenerateUnequalRandomSkinColors(const Colors : TSScreenSkinColors) : TSScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
repeat
Result := SGenerateRandomSkinColors(Colors);
until Result <> Colors;
end;

procedure TSScreenSkin.DeleteRenderResources();
begin
if FDeviceResourcesDeleted then
	Exit;
FFont.DeleteRenderResources();
FComboBoxImage.DeleteRenderResources();
FDeviceResourcesDeleted := True;
inherited;
end;

procedure TSScreenSkin.LoadRenderResources();
begin
if not FDeviceResourcesDeleted then
	Exit;
FFont.LoadRenderResources();
FComboBoxImage.LoadRenderResources();
FDeviceResourcesDeleted := False;
inherited;
end;

constructor TSScreenSkin.Create(const VContext : ISContext; const VColors : TSScreenSkinColors);
begin
inherited Create(VContext);
FColors := VColors;
FColorsTimer := 0;
FColorsFrom := FColors;
FColorsTo := SGenerateUnequalRandomSkinColors(FColorsFrom);

FComboBoxImage := SCreateImageFromFile(Context, STextureDirectory + DirectorySeparator + 'ComboBoxImage.Sia');

FDeviceResourcesDeleted := False;
FDestroyFontSupported := True;
FFont := nil;

FOwner := nil;
end;

procedure TSScreenSkin.CreateFont();
begin
DestroyFont();
FFont := SCreateFontFromFile(Context, SScreenSkinDefaultFontFileName);
end;

procedure TSScreenSkin.DestroyFont();
begin
if FDestroyFontSupported then
	SKill(FFont)
else
	FFont := nil;
end;

function TSScreenSkin.FontReady() : TSBool;
begin
Result := FontAssigned;
if Result then
	Result := Font.Loaded;
end;

function TSScreenSkin.FontAssigned() : TSBool;
begin
Result := FFont <> nil;
end;

procedure TSScreenSkin.SetFont(const VFont : TSFont); 
begin
if (FFont <> VFont) then
	DestroyFont();
FFont := VFont;
end;

function TSScreenSkin.GetFont() : TSFont;
begin
if not FontAssigned() then
	CreateFont();
Result := FFont;
end;

destructor TSScreenSkin.Destroy();
begin
SKill(FComboBoxImage);
DestroyFont();
inherited;
end;

class function TSScreenSkin.ClassName() : TSString;
begin
Result := 'TSScreenSkin';
end;

procedure TSScreenSkin.PaintQuad(const Location : TSComponentLocation; const LinesColor, QuadColor : TSVertex4f; const ViewingLines : TSBool = True; const ViewingQuad : TSBool = True;const Radius : TSFloat = 5);
begin
SRoundQuad(Render, Location.FloatPosition, Location.FloatPositionAndSize, Radius, 10, LinesColor, QuadColor, ViewingLines, ViewingQuad);
end;

procedure TSScreenSkin.PaintText(const Text : TSString; const Location : TSComponentLocation; const Color : TSColor4f; const WidthCentered : TSBoolean = True; const HeightCentered : TSBoolean = True);
var
	Color4uint8 : TSVector4uint8;
begin
if Render.SupportedMemoryBuffers() then
	begin
	Color4uint8 := SColor4fTo4uint8(Color);
	TSTextVertexObject.Paint(Text, Render, Font, Color4uint8, Location.FloatPosition, Location.FloatPositionAndSize, WidthCentered, HeightCentered)
	end
else
	begin
	Render.Color(Color);
	Font.DrawFontFromTwoVertex2f(Text, Location.FloatPosition, Location.FloatPositionAndSize, WidthCentered, HeightCentered);
	end;
end;

procedure TSScreenSkin.PaintPanel(constref Panel : ISPanel);
var
	Location : TSComponentLocation;
	ActiveTimer, VisibleTimer : TSScreenTimer;
	ViewingQuad  : TSBool;
	ViewingLines : TSBool;
begin
ViewingLines := Panel.ViewingLines;
ViewingQuad := Panel.ViewingQuad;

if ViewingQuad or ViewingLines then
	begin
	Location := Panel.GetLocation();

	VisibleTimer := Panel.VisibleTimer;
	ActiveTimer := Panel.ActiveTimer;

	if (ActiveTimer < 1 - SZero) then
		PaintQuad(Location,
			FColors.FDisabled.FFirst.WithAlpha(0.7*VisibleTimer*(1-ActiveTimer))*0.54,
			FColors.FDisabled.FSecond.WithAlpha(0.7*VisibleTimer*(1-ActiveTimer))*0.8,
			ViewingLines, ViewingQuad);

	if  (ActiveTimer > SZero) and 
		(VisibleTimer > SZero) then
		PaintQuad(Location,
			FColors.FNormal.FFirst.WithAlpha(0.3*VisibleTimer*ActiveTimer),
			FColors.FNormal.FSecond.WithAlpha(0.3*VisibleTimer*ActiveTimer)*1.3,
			ViewingLines, ViewingQuad);
	end;
end;

procedure TSScreenSkin.PaintButton(constref Button : ISButton);
var
	Location : TSComponentLocation;
	Active, Visible : TSBool;
	ActiveTimer, VisibleTimer, CursorOverTimer, ClickTimer : TSScreenTimer;
begin
Location := Button.GetLocation();

Active := Button.Active;
Visible := Button.Visible;

ClickTimer := Button.MouseClickTimer;
CursorOverTimer := Button.CursorOverTimer;
VisibleTimer := Button.VisibleTimer;
ActiveTimer := Button.ActiveTimer;

if (not Active) or (ActiveTimer < 1 - SZero) then
	PaintQuad(Location,
		FColors.FDisabled.FFirst.WithAlpha(0.7*VisibleTimer*(1-ActiveTimer))*0.54,
		FColors.FDisabled.FSecond.WithAlpha(0.7*VisibleTimer*(1-ActiveTimer))*0.8,
		True);
if  (ActiveTimer > SZero) and 
	(1-CursorOverTimer>SZero) and 
	(1-ClickTimer>SZero) and
	(VisibleTimer>SZero) then
	PaintQuad(Location,
		FColors.FNormal.FFirst.WithAlpha(0.3*VisibleTimer*(1-CursorOverTimer)*(1-ClickTimer)*ActiveTimer),
		FColors.FNormal.FSecond.WithAlpha(0.3*VisibleTimer*(1-CursorOverTimer)*(1-ClickTimer)*ActiveTimer)*1.3,
		True);
if  (ActiveTimer>SZero) and 
	(CursorOverTimer>SZero) and 
	(1-ClickTimer>SZero) and
	(VisibleTimer>SZero) then
	PaintQuad(Location,
		FColors.FOver.FFirst.WithAlpha(0.5*VisibleTimer*CursorOverTimer*(1-ClickTimer)*ActiveTimer),
		FColors.FOver.FSecond.WithAlpha(0.5*VisibleTimer*CursorOverTimer*(1-ClickTimer)*ActiveTimer)*1.3,
		True);
if  (ActiveTimer>SZero) and 
	(ClickTimer>SZero) and
	(VisibleTimer>SZero) then
	PaintQuad(Location,
		FColors.FClick.FFirst.WithAlpha(0.4*VisibleTimer*ClickTimer*ActiveTimer),
		FColors.FClick.FSecond.WithAlpha(0.3*VisibleTimer*ClickTimer*ActiveTimer)*1.3,
		True);
if (Button.Caption<>'') and FontReady and (VisibleTimer>SZero) then
	PaintText(Button.Caption, Location, FColors.FText.FFirst.WithAlpha(VisibleTimer));
end;

procedure TSScreenSkin.PaintComboBox(constref ComboBox : ISComboBox);
var
	Location, TextLocation : TSComponentLocation;
	ActiveTimer, VisibleTimer, CursorOverTimer, ClickTimer, OpenTimer : TSScreenTimer;

procedure PaintOpened(const OpenLocation : TSComponentLocation); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function GetTextColor(const VCursorOverTimer : TSScreenTimer) : TSVertex4f; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FColors.FText.FSecond * (VCursorOverTimer) + FColors.FText.FFirst * (1 - VCursorOverTimer);
Result.a := 0.9 * OpenTimer;
end;

var
	TextColor, DisabledTextColor : TSVertex4f;

procedure PaintItem(const ItemLocation : TSComponentLocation; var Item : TSComboBoxItem); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function GetSelectedTextColor() : TSVector4f; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := FColors.FNormal.FFirst;
TSColor3f(Result) := Result.Normalized();
Result.a := OpenTimer;
end;

var
	ItemTextColor : TSVector4f;
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
	ItemTextColor := GetTextColor(1 - CursorOverTimer)
else if Item.Active then
	ItemTextColor := TextColor
else
	ItemTextColor := DisabledTextColor;
PaintText(Item.Caption, ItemLocation,	 ItemTextColor);
end;

function GetScrollLocation() : TSComponentLocation;  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.SizeX := Location.SizeY;
Result.SizeY := Round(OpenLocation.Size.Y * (ComboBox.LinesCount / ComboBox.ItemsCount));
Result.PositionX := OpenLocation.PositionX + OpenLocation.SizeX - Location.SizeY;
Result.PositionY := Round(OpenLocation.PositionY + OpenLocation.Size.Y * (ComboBox.FirstItemIndex / ComboBox.ItemsCount));
end;

function GetItemLocation(const Index : TSUInt32; const NeedPaintScroll : TSBool = False):TSComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := OpenLocation;
Result.SizeY := Round(Result.SizeY / ComboBox.LinesCount);
Result.PositionY := Result.PositionY + Index * Result.SizeY;
if NeedPaintScroll then
	Result.SizeX := Result.SizeX - Location.SizeY;
end;

var
	NeedPaintScroll : TSBool;
	BodyColor : TSVertex4f;
	Index : TSMaxEnum;
begin
BodyColor := (FColors.FText.FSecond * (1 - CursorOverTimer) + FColors.FText.FFirst * (CursorOverTimer)) * 0.5 + 0.5 * FColors.FText.FFirst;
BodyColor *= 0.8;
TextColor := GetTextColor(CursorOverTimer);
DisabledTextColor := FColors.FDisabled.FSecond * 0.1 + SVertex4fImport(1,0,0,1) * 0.9;
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
	MainItemColor : TSVector4f;
begin
Location := ComboBox.GetLocation();

ClickTimer   := ComboBox.MouseClickTimer;
CursorOverTimer    := ComboBox.CursorOverTimer;
VisibleTimer := ComboBox.VisibleTimer;
ActiveTimer  := ComboBox.ActiveTimer;
OpenTimer    := ComboBox.OpenTimer;

if  (1 - CursorOverTimer > SZero) and 
	(1 - OpenTimer > SZero)  then
	PaintQuad(Location,
		FColors.FNormal.FFirst.WithAlpha(0.3 * VisibleTimer * (1-CursorOverTimer) * (1-ClickTimer) * ActiveTimer * (1 - OpenTimer)),
		FColors.FNormal.FSecond.WithAlpha(0.3 * VisibleTimer * (1-CursorOverTimer) * (1-ClickTimer) * ActiveTimer * (1 - OpenTimer)) * 1.3);
if  (CursorOverTimer > SZero) and 
	(1-OpenTimer > SZero)  then
	PaintQuad(Location,
		FColors.FOver.FFirst.WithAlpha(0.5 * VisibleTimer * CursorOverTimer * (1-OpenTimer) * (1-ClickTimer) * ActiveTimer),
		FColors.FOver.FSecond.WithAlpha(0.5 * VisibleTimer * CursorOverTimer * (1-OpenTimer) * (1-ClickTimer) * ActiveTimer) * 1.3);
if (ActiveTimer < 1 - SZero) then
	PaintQuad(Location,
		FColors.FDisabled.FFirst.WithAlpha(0.7 * VisibleTimer * (1-ActiveTimer)) * 0.54,
		FColors.FDisabled.FSecond.WithAlpha(0.7 * VisibleTimer * (1-ActiveTimer)) * 0.8);
if  (ActiveTimer > SZero) and 
	(ClickTimer > SZero) and
	(1 - OpenTimer > SZero) and
	(VisibleTimer > SZero) then
	PaintQuad(Location,
		FColors.FClick.FFirst.WithAlpha(0.4 * VisibleTimer * ClickTimer * (1-OpenTimer) * ActiveTimer),
		FColors.FClick.FSecond.WithAlpha(0.3 * VisibleTimer * ClickTimer * (1-OpenTimer) * ActiveTimer) * 1.3);

if OpenTimer > SZero then
	begin
	TextLocation := Location;
	TextLocation.SizeY := Round(TextLocation.SizeY * ( 1 + (ComboBox.LinesCount - 1) * OpenTimer));
	
	PaintOpened(TextLocation);
	end
else
	TextLocation := Location;

if 1 - OpenTimer > SZero then
	begin
	MainItemColor := FColors.FText.FFirst.WithAlpha(Sqr((1 - OpenTimer) * VisibleTimer));
	
	if (FComboBoxImage <> nil) then
		begin
		Render.Color(MainItemColor);
		
		FComboBoxImage.DrawImageFromTwoVertex2fAsRatio(
			TextLocation.FloatPositionAndSize - TSComponentLocationVectorFloat.Create(Location.SizeY, TextLocation.SizeY),
			TextLocation.FloatPositionAndSize,
			False,0.5);
		end;
	
	if (ComboBox.GetSelectedItem() <> nil) then
		PaintText(ComboBox.GetSelectedItem()^.Caption, TextLocation, MainItemColor);
	end;
end;

procedure TSScreenSkin.PaintLabel(constref VLabel : ISLabel); 
var
	Location : TSComponentLocation;
	Color4f     : TSVector4f;
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

procedure TSScreenSkin.PaintEdit(constref Edit : ISEdit); 
var
	TextLocation, Location : TSComponentLocation;
	Active, Visible : TSBool;
	ActiveTimer, VisibleTimer, CursorOverTimer, TextCompliteTimer : TSScreenTimer;
	
	NormalFirst, NormalSecond : TSColor4f;
	RedColor  : TSColor4f;
	GreenColor : TSColor4f;
begin
Location := Edit.GetLocation();

Active := Edit.Active;
Visible := Edit.Visible;

CursorOverTimer := Edit.CursorOverTimer;
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

if (not Active) or (ActiveTimer < 1 - SZero) then
	PaintQuad(Location,
		FColors.FDisabled.FFirst.WithAlpha(0.7*VisibleTimer*(1-ActiveTimer))*0.54,
		FColors.FDisabled.FSecond.WithAlpha(0.7*VisibleTimer*(1-ActiveTimer))*0.8,
		True, True, 2);
if  (ActiveTimer>SZero) and 
	(VisibleTimer>SZero) then
	PaintQuad(Location,
		NormalFirst .WithAlpha(0.4 * VisibleTimer * ActiveTimer),
		NormalSecond.WithAlpha(0.3 * VisibleTimer * ActiveTimer) * 1.3,
		True, True, 2);

if FontReady and (Edit.Caption <> '') then
	begin
	TextLocation := Location;
	TextLocation.Left := TextLocation.Left + 3;
	TextLocation.Width := TextLocation.Width - 9;
	
	PaintText(Edit.Caption, TextLocation, TSVector4f.Create(1, 1, 1, VisibleTimer), False);
	if (Edit.CursorTimer > 0) and Edit.NowEditing then
		begin
		Render.Color4f(1, 0.5, 0, VisibleTimer * Edit.CursorTimer);
		Font.DrawCursorFromTwoVertex2f(Edit.Caption, Edit.CursorPosition, TextLocation.FloatPosition, TextLocation.FloatPositionAndSize, False);
		end;
	end;
end;

procedure TSScreenSkin.PaintProgressBar(constref ProgressBar : ISProgressBar);
var
	Location, Location2 : TSComponentLocation;
	Active, Visible : TSBool;
	ActiveTimer, VisibleTimer : TSScreenTimer;
	FrameColor : TSScreenSkinFrameColor;
	Radius : TSFloat;
begin
Radius := 5;
Location := ProgressBar.Location;
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
	PaintText(SStringIf(ProgressBar.ViewCaption, ProgressBar.Caption + ' ') + SFloatToString(100 * ProgressBar.Progress , 2) + '%', 
		Location, TSVector4f.Create(1, 1, 1, VisibleTimer));
end;

procedure TSScreenSkin.PaintForm(constref Form : ISForm);
var
	Location, InternalComponentLocation, TextLocation : TSComponentLocation;
	Borders : TSComponentBordersSize;
	Active, Visible : TSBool;
	ActiveTimer, VisibleTimer : TSScreenTimer;
	FrameColor : TSScreenSkinFrameColor;
begin
Location := Form.Location;
InternalComponentLocation := Form.InternalComponentLocation;
Borders := Form.BordersSize;
TextLocation.Position := Location.Position;
TextLocation.Width := Location.Width;
TextLocation.Height := Borders.Top;
Active := Form.Active;
Visible := Form.Visible;
VisibleTimer := Form.VisibleTimer;
ActiveTimer := Form.ActiveTimer;
FrameColor := FColors.FNormal;

if (VisibleTimer > SZero) and (ActiveTimer > SZero) then
	SRoundWindowQuad(Render,
		Location.FloatPosition, Location.FloatPositionAndSize,
		InternalComponentLocation.FloatPosition, InternalComponentLocation.FloatPositionAndSize,
		Borders.Left, Borders.Left,
		10,
		FrameColor.FFirst .WithAlpha(0.4 * VisibleTimer * ActiveTimer),
		FrameColor.FSecond.WithAlpha(0.3 * VisibleTimer * ActiveTimer) * 1.3,
		True,
		FrameColor.FFirst .WithAlpha(0.4 * VisibleTimer * ActiveTimer),
		FrameColor.FSecond.WithAlpha(0.3 * VisibleTimer * ActiveTimer) * 1.3);

if FontReady and (VisibleTimer > SZero) then 
	PaintText(Form.Caption, TextLocation, TSVector4f.Create(1, 1, 1, VisibleTimer));
end;

end.
