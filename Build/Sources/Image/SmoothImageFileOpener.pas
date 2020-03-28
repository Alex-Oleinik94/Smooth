{$INCLUDE Smooth.inc}

unit SmoothImageFileOpener;

interface

uses
		// System
	 Classes
		// Engine
	,SmoothBase
	,SmoothLists
	,SmoothBaseClasses
	,SmoothFileOpener
	,SmoothContext
	,SmoothLoadingFrame
	,SmoothFont
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothCommonStructs
	,SmoothImage
	,SmoothThreads
	,SmoothCursor
	;

type
	TSImageFileOpener = class(TSFileOpener)
			public
		class function ClassName() : TSString; override;
		class function GetExpansions() : TSStringList; override;
		class function GetDrawableClass() : TSFileOpenerDrawableClass; override;
		class function ExpansionsSupported(const VExpansions : TSStringList) : TSBool; override;
		end;
	
	TSImageViewer = class(TSFileOpenerDrawable)
			public
		destructor Destroy(); override;
		constructor Create(const VContext : ISContext); override;
		class function ClassName() : TSString; override;
		procedure DeleteRenderResources(); override;
		procedure LoadRenderResources(); override;
		procedure Paint(); override;
		procedure Resize(); override;
			private
		FBackgroundColor : TSColor3f;
		FWaitAnimation : TSLoadingFrame;
		
		FBackgroundImage : TSImage;
		FImage : TSImage;
		
		FLoadingThread : TSThread;
		FFont : TSFont;
		FLoadingDone : TSBool;
		
		FHintColor : TSColor3f;
		
		FPosition, FSize, FRenderSize : TSVector2f;
		FCursorOverImage : TSBoolean;
		
		FCursorDragAndDropPressed : TSCursor; // drag and drop cursor (pressed)
		FCursorDragAndDropNotPressed : TSCursor; // drag and drop cursor (not  pressed)
		FCursorType : TSUInt8; // 0 if standart; 1 if DragAndDropPressed; 2 if DragAndDropNotPressed
			private
		procedure InitImagePosition();
		procedure InitBackgroundImage();
		procedure FillBackgroundImage();
		procedure PrepareBackgroundImageMainThread();
		procedure RescaleImagePosition();
		procedure PaintImageInfo();
		procedure PaintImage();
		procedure PaintHintAndLoadingAnimation();
		procedure ProccessMouseWheel(const VWheel : TSBool);
		procedure ProccessContextKeys();
		procedure OpenFileDialog();
		procedure SaveFileDialog();
		function CursorOverImage(const _CursorPosition : PSVector2f = nil) : TSBoolean;
		procedure ProccessCursorIcon();
		procedure MakeAlphaChannel();
			public
		procedure LoadingFromThread();
		end;

implementation

uses
		// Engine
	 SmoothStringUtils
	,SmoothRender
	,SmoothRenderBase
	,SmoothFileUtils
	,SmoothContextUtils
	,SmoothCommon
	,SmoothResourceManager
	,SmoothImageFormatDeterminer
		// System
	,SysUtils
	;

//================
//=TSImageViewer=
//================

destructor TSImageViewer.Destroy();
begin
SKill(FCursorDragAndDropPressed);
SKill(FCursorDragAndDropNotPressed);
SKill(FLoadingThread);
SKill(FFont);
SKill(FWaitAnimation);
SKill(FBackgroundImage);
SKill(FImage);
inherited;
end;

procedure TSImageViewer_LoadThreadProc(const Viewer : TSImageViewer);
begin
Viewer.LoadingFromThread();
end;

constructor TSImageViewer.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FImage := nil;
FBackgroundImage := nil;
FLoadingDone := False;
FCursorOverImage := False;
FHintColor.Import(0, 0, 0);
FBackgroundColor := Context.GetDefaultWindowColor();
Render.ClearColor(FBackgroundColor.r, FBackgroundColor.g, FBackgroundColor.b, 1);
FWaitAnimation := TSLoadingFrame.Create(Context);
FFont := SCreateFontFromFile(Context, SDefaultFontFileName, True);
FCursorDragAndDropPressed := SCreateCursorFromFile(SEngineDirectory + DirectorySeparator + 'drag and drop cursor (pressed).cur');
FCursorDragAndDropNotPressed := SCreateCursorFromFile(SEngineDirectory + DirectorySeparator + 'drag and drop cursor (not  pressed).cur');
FCursorType := 0;
FLoadingThread := TSThread.Create(TSThreadProcedure(@TSImageViewer_LoadThreadProc), Self, True);
end;

class function TSImageViewer.ClassName() : TSString;
begin
Result := 'TSImageViewer';
end;

procedure TSImageViewer.LoadingFromThread();
begin
while (FImage = nil) do
	Sleep(10);
FImage.Load();
InitImagePosition();
FLoadingDone := True;
end;

procedure TSImageViewer.PrepareBackgroundImageMainThread();
begin
InitBackgroundImage();
FillBackgroundImage();
end;

procedure TSImageViewer.FillBackgroundImage();
const
	DefaultQuadSize   = 10;
	ColorThemesValues : array [0..1] of record FColor1, FColor2 : TSUInt8; end =
		((FColor1 : 255; FColor2 : 187), (FColor1 : 117; FColor2 : 143));
	DefaultColorIndex = 1;
var
	ColorThemes : packed array of record FColor1, FColor2 : TSVertex3uint8; end = nil;

procedure FillImage();
var
	OverageX, OverageY : TSMaxEnum;

function PixelColor(const _x, _y : TSMaxEnum) : TSVertex3uint8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
//todo
if ((((_x div DefaultQuadSize) + (_y div DefaultQuadSize)) mod 2) = 0) then
	Result := ColorThemes[DefaultColorIndex].FColor1
else
	Result := ColorThemes[DefaultColorIndex].FColor2;
end;

var
	Index, Index2 : TSMaxEnum;
begin
OverageX := FBackgroundImage.Width mod DefaultQuadSize;
OverageY := FBackgroundImage.Height mod DefaultQuadSize;
for Index := 0 to FBackgroundImage.Width - 1 do
	for Index2 := 0 to FBackgroundImage.Height - 1 do
		FBackgroundImage.BitMap.SetPixel(Index, Index2, PixelColor(Index, Index2));
end;

var
	Index : TSMaxEnum;
begin
if (FBackgroundImage = nil) then
	exit;
SetLength(ColorThemes, Length(ColorThemesValues));
for Index := 0 to High(ColorThemes) do
	begin
	ColorThemes[Index].FColor1 := SVertex3uint8Import(ColorThemesValues[Index].FColor1, ColorThemesValues[Index].FColor1, ColorThemesValues[Index].FColor1);
	ColorThemes[Index].FColor2 := SVertex3uint8Import(ColorThemesValues[Index].FColor2, ColorThemesValues[Index].FColor2, ColorThemesValues[Index].FColor2);
	end;
FillImage();
SetLength(ColorThemes, 0);
FBackgroundImage.LoadedIntoRAM := True;
end;

procedure TSImageViewer.InitBackgroundImage();
begin
SKill(FBackgroundImage);
FBackgroundImage := TSImage.Create();
FBackgroundImage.Context := Context;
FBackgroundImage.BitMap.Width := FImage.BitMap.Width;
FBackgroundImage.BitMap.Height := FImage.BitMap.Height;
FBackgroundImage.BitMap.Channels := 3;
FBackgroundImage.BitMap.ChannelSize := 8;
FBackgroundImage.BitMap.ReAllocateMemory();
end;

procedure TSImageViewer.Resize();
begin
RescaleImagePosition();
end;

procedure TSImageViewer.DeleteRenderResources();
begin
SKill(FImage);
SKill(FBackgroundImage);
end;

procedure TSImageViewer.PaintImageInfo();
var
	Iterator : TSVector2f;

procedure PaintString(const S : TSString);
begin
FFont.DrawFontFromTwoVertex2f(
	S,
	Iterator,
	SVertex2fImport(Iterator.x + FFont.StringLength(S),Iterator.y + FFont.FontHeight));
Iterator.y += FFont.FontHeight + 1;
end;

begin
Iterator.Import(5, FRenderSize.y - (FFont.FontHeight + 1) * 5 - 2);
Render.Color(FHintColor);
PaintString('width = ' + SStr(FImage.Width));
PaintString('height = ' + SStr(FImage.Height));
PaintString('channels = ' + SStr(FImage.BitMap.Channels));
PaintString('bitmap size = ' + SGetSizeString(FImage.BitMap.Width * FImage.BitMap.Height * FImage.BitMap.Channels,'EN'));
PaintString('filename = ' + FImage.FileName);
end;

function TSImageViewer.CursorOverImage(const _CursorPosition : PSVector2f = nil) : TSBoolean;
var
	CursorPosition : TSPoint2int32;
	CursorPositionFloat : TSVector2f;
begin
CursorPosition := Context.CursorPosition();
CursorPositionFloat.Import(CursorPosition.x, CursorPosition.y);
Result := 
	(CursorPositionFloat.x > FPosition.x) and
	(CursorPositionFloat.y > FPosition.y) and
	(CursorPositionFloat.x < FPosition.x + FSize.x) and
	(CursorPositionFloat.y < FPosition.y + FSize.y);
if (_CursorPosition <> nil) then
	_CursorPosition^ := CursorPositionFloat;
end;

procedure TSImageViewer.ProccessMouseWheel(const VWheel : TSBool);
var
	CursorPosition : TSVector2f;

procedure ToVectors(out V1, V2 : TSVector2f);
begin
V1 := FPosition - CursorPosition;
V2 := FPosition + FSize - CursorPosition;
end;

procedure FromVectors(const V1, V2 : TSVector2f);
begin
FPosition := V1 + CursorPosition;
FSize := V2 + CursorPosition - FPosition;
end;

procedure MultVectors(var V1, V2 : TSVector2f; const MN : TSFloat);
begin
V1 *= MN;
V2 *= MN;
end;

const
	WheelRank = 1.5;
var
	V1, V2 : TSVector2f;
begin
if CursorOverImage(@CursorPosition) then
	begin
	ToVectors(V1, V2);
	if VWheel then
		MultVectors(V1, V2, WheelRank)
	else
		MultVectors(V1, V2, 1 / WheelRank);
	FromVectors(V1, V2);
	RescaleImagePosition();
	end;
end;

procedure TSImageViewer.ProccessCursorIcon();
var
	_CursorOverImage : TSBoolean = False;
begin
if (FCursorType = 1) then
	FPosition += Context.CursorPosition(SDeferenseCursorPosition);
_CursorOverImage := CursorOverImage();
if FCursorOverImage and (not _CursorOverImage) and (FCursorType in [1, 2]) then
	begin
	Context.Cursor := TSCursor.Create(SC_NORMAL);
	FCursorType := 0;
	end;
if (FSize.x > Render.Width) or (FSize.y > Render.Height) then
	begin
	if _CursorOverImage and ((FCursorType = 0) or ((FCursorType = 1) and (not Context.CursorKeysPressed(SLeftCursorButton)))) then
		begin
		Context.Cursor := TSCursor.Copy(FCursorDragAndDropNotPressed);
		FCursorType := 2;
		end;
	if FCursorOverImage and (FCursorType = 2) and Context.CursorKeysPressed(SLeftCursorButton) and (Context.CursorKeyPressed = SLeftCursorButton) then
		begin
		Context.Cursor := TSCursor.Copy(FCursorDragAndDropPressed);
		FCursorType := 1;
		end;
	end
else if (FCursorType in [1, 2]) then
	begin
	Context.Cursor := TSCursor.Create(SC_NORMAL);
	FCursorType := 0;
	end;
FCursorOverImage := _CursorOverImage;
end;

procedure TSImageViewer.MakeAlphaChannel();
var
	NewImage : TSImage;

procedure ProcessPixel(const _x, _y : TSMaxEnum);
var
	PixelRGB : PSByte;
	PixelRGBA : PSByte;
	
	Sum : TSMaxEnum;
	Alpha : TSFloat64;

function ProcessByte(const B : TSByte) : TSByte;
begin
//Result := Trunc(B / Sum * 255);
Result := B {* 2};
end;

begin
PixelRGBA := @NewImage.BitMap.Data[(_x + _y * NewImage.BitMap.Width) * NewImage.BitMap.Channels];
PixelRGB  := @FImage.BitMap.Data[(_x + _y * FImage.BitMap.Width) * FImage.BitMap.Channels];

Sum := PixelRGB[0] + PixelRGB[1] + PixelRGB[2];
Alpha := Sum / (255 * 3);
PixelRGBA[3] := Trunc(Alpha * 255);
PixelRGBA[2] := ProcessByte(PixelRGB[2]);
PixelRGBA[1] := ProcessByte(PixelRGB[1]);
PixelRGBA[0] := ProcessByte(PixelRGB[0]);
end;

var
	x, y : TSMaxEnum;
begin
if (FBackgroundImage = nil) then
	PrepareBackgroundImageMainThread();
FImage.Load();
NewImage := TSImage.Create();
NewImage.Context := Context;
NewImage.FileName := SFreeFileName(FImage.FileName, '');
NewImage.BitMap.Width := FImage.BitMap.Width;
NewImage.BitMap.Height := FImage.BitMap.Height;
NewImage.BitMap.Channels := FImage.BitMap.Channels;
NewImage.BitMap.ChannelSize := FImage.BitMap.ChannelSize;
NewImage.BitMap.ReAllocateMemory();
for x := 0 to NewImage.BitMap.Width - 1 do
	for y := 0 to NewImage.BitMap.Height - 1 do
		ProcessPixel(x, y);
NewImage.Save(SImageFormatBMP);
//NewImage.Save(SImageFormatPNG);
NewImage.LoadTexture();
SKill(FImage);
FImage := NewImage;
NewImage := nil;
end;

procedure TSImageViewer.ProccessContextKeys();
begin
if Context.CursorWheel() <> SNullCursorWheel then
	ProccessMouseWheel(SUpCursorWheel = Context.CursorWheel());
ProccessCursorIcon();
if Context.KeyPressed and (Context.KeyPressedChar = 'S') and (Context.KeyPressedType = SUpKey) and Context.KeysPressed(S_CTRL_KEY) then
	SaveFileDialog();
if Context.KeyPressed and (Context.KeyPressedChar = 'O') and (Context.KeyPressedType = SUpKey) and Context.KeysPressed(S_CTRL_KEY) then
	OpenFileDialog();
if Context.KeyPressed and (Context.KeyPressedChar = 'A') and (Context.KeyPressedType = SUpKey) and Context.KeysPressed(S_CTRL_KEY) then
	MakeAlphaChannel();
end;

procedure TSImageViewer.OpenFileDialog();
begin

end;

procedure TSImageViewer.SaveFileDialog();
begin
{FileWay := Context.FileSaveDialog(
	'Куда сохранить то?!',
	'Файлы рельефа(*.sggdrf)'+#0+'*.sggdrf'+#0+
	'All files(*.*)'+#0+'*.*'+#0+
	#0,
	'sggdrf');}

FImage.Load();
//WriteLn(FImage.BitMap.HasData);
FImage.FileName := SFreeFileName(FImage.FileName, '');
FImage.Save(SImageFormatBMP);
end;

procedure TSImageViewer.Paint();
begin
ProccessContextKeys();
Render.InitMatrixMode(S_2D);
PaintImage();
PaintHintAndLoadingAnimation();
end;

procedure TSImageViewer.PaintImage();
begin
{Render.Color(FBackgroundColor);
with Render do
	begin
	BeginScene(SR_QUADS);
	Vertex2f(0,0);
	Vertex2f(Width,0);
	Vertex2f(Width,Height);
	Vertex2f(0,Height);
	EndScene();
	end;}
if (FImage <> nil) and (FImage.TextureLoaded() or FImage.LoadedIntoRAM) then
	begin
	if (FImage.BitMap.Channels = 4) and (FBackgroundImage = nil) then
		PrepareBackgroundImageMainThread();
	Render.Color3f(1, 1, 1);
	if (FBackgroundImage <> nil) and (FBackgroundImage.TextureLoaded() or FBackgroundImage.LoadedIntoRAM) then
		FBackgroundImage.DrawImageFromTwoVertex2f(FPosition, FSize + FPosition, True, S_2D);
	FImage.DrawImageFromTwoVertex2f(FPosition, FSize + FPosition, True, S_2D);
	end;
end;

procedure TSImageViewer.PaintHintAndLoadingAnimation();
begin
if (FFont <> nil) and FFont.FontLoaded then
	if (FImage <> nil) and (FImage.TextureLoaded() or FImage.LoadedIntoRAM) then
		PaintImageInfo()
	else
		begin
		if FLoadingThread.Crashed then
			FHintColor.Import(1, 0, 0);
		Render.Color(FHintColor);
		FFont.DrawFontFromTwoVertex2f(
			'Загрузка...',
			SVertex2fImport(5, FRenderSize.y - FFont.FontHeight - 5),
			SVertex2fImport(5 + FFont.StringLength('Загрузка...'), FRenderSize.y - 5));
		end;
FWaitAnimation.PaintAt(Render.Width - 200, 50, 150, 150, not FLoadingDone);
end;

procedure TSImageViewer.InitImagePosition();
begin
FRenderSize.Import(Render.Width, Render.Height);
if (FRenderSize.x < FImage.Width) or (FRenderSize.y < FImage.Height) then
	begin
	if FRenderSize.x / FRenderSize.y > FImage.Width / FImage.Height then
		begin
		FSize.Import(
			FRenderSize.x,
			FRenderSize.x * FImage.Height / FImage.Width);
		FPosition.Import(
			0,
			(FRenderSize.y - FSize.y) / 2);
		end
	else
		begin
		FSize.Import(
			FRenderSize.y * FImage.Width / FImage.Height,
			FRenderSize.y);
		FPosition.Import(
			(FRenderSize.x - FSize.x) / 0,
			0);
		end;
	end
else
	begin
	FSize.Import(FImage.Width, FImage.Height);
	FPosition := (FRenderSize - FSize) / 2;
	end;
end;

procedure TSImageViewer.RescaleImagePosition();
var
	RS : TSVector2f;
begin
RS.Import(Render.Width, Render.Height);
FPosition += (RS / 2) - (FRenderSize / 2);
FRenderSize := RS;
if (FRenderSize.x > FSize.x) and (FRenderSize.y > FSize.y) then
	if ((FRenderSize.x < FImage.Width) or (FRenderSize.y < FImage.Height)) then
		begin
		if FRenderSize.x / FRenderSize.y > FImage.Width / FImage.Height then
			begin
			FSize.Import(
				FRenderSize.x,
				FRenderSize.x * FImage.Height / FImage.Width);
			FPosition.Import(
				0,
				(FRenderSize.y - FSize.y) / 2);
			end
		else
			begin
			FSize.Import(
				FRenderSize.y * FImage.Width / FImage.Height,
				FRenderSize.y);
			FPosition.Import(
				(FRenderSize.x - FSize.x) / 0,
				0);
			end;
		end
	else
		begin
		if (FSize.x < FImage.Width) or (FSize.y < FImage.Height) then
			FSize.Import(FImage.Width, FImage.Height);
		FPosition := (FRenderSize - FSize) / 2;
		end;
end;

procedure TSImageViewer.LoadRenderResources();
begin
DeleteRenderResources();
FImage := TSImage.Create(FFiles[0]);
FImage.Context := Context;
end;

class function TSImageFileOpener.ClassName() : TSString;
begin
Result := 'TSImageFileOpener';
end;

//====================
//=TSImageFileOpener=
//====================

class function TSImageFileOpener.GetDrawableClass() : TSFileOpenerDrawableClass;
begin
Result := TSImageViewer;
end;

class function TSImageFileOpener.GetExpansions() : TSStringList;
begin
Result := nil;
if (TSCompatibleContext <> nil) and (TSCompatibleRender <> nil) then
	begin
	Result := nil;
	Result *= 'JPG';
	Result *= 'JPEG';
	Result *= 'BMP';
	Result *= 'TGA';
	Result *= 'SIA';
	Result *= 'ICO';
	Result *= 'CUR';
	if SResourceManager.LoadingIsSupported('PNG') then
		Result *= 'PNG';
	end;
end;

class function TSImageFileOpener.ExpansionsSupported(const VExpansions : TSStringList) : TSBool;
var
	SupportedExpansions : TSStringList = nil;
	S : TSString = '';
begin
SupportedExpansions := GetExpansions();
Result := (SupportedExpansions <> nil);
if Result then
	for S in VExpansions do
		if (not (S in SupportedExpansions)) then
			begin
			Result := False;
			break;
			end;
end;

initialization
begin
SRegistryFileOpener(TSImageFileOpener);
end;

end.
