{$INCLUDE SaGe.inc}

unit SaGeImageFileOpener;

interface

uses
		// System
	 Classes
		// Engine
	,SaGeBase
	,SaGeLists
	,SaGeBaseClasses
	,SaGeFileOpener
	,SaGeContext
	,SaGeLoadingFrame
	,SaGeFont
	,SaGeContextClasses
	,SaGeContextInterface
	,SaGeCommonStructs
	,SaGeImage
	,SaGeThreads
	,SaGeCursor
	;

type
	TSGImageFileOpener = class(TSGFileOpener)
			public
		class function ClassName() : TSGString; override;
		class function GetExpansions() : TSGStringList; override;
		class function GetDrawableClass() : TSGFileOpenerDrawableClass; override;
		class function ExpansionsSupported(const VExpansions : TSGStringList) : TSGBool; override;
		end;
	
	TSGImageViewer = class(TSGFileOpenerDrawable)
			public
		destructor Destroy(); override;
		constructor Create(const VContext : ISGContext); override;
		class function ClassName() : TSGString; override;
		procedure DeleteRenderResources(); override;
		procedure LoadRenderResources(); override;
		procedure Paint(); override;
		procedure Resize(); override;
			private
		FBackgroundColor : TSGColor3f;
		FWaitAnimation : TSGLoadingFrame;
		
		FBackgroundImage : TSGImage;
		FImage : TSGImage;
		
		FLoadingThread : TSGThread;
		FFont : TSGFont;
		FLoadingDone : TSGBool;
		
		FHintColor : TSGColor3f;
		
		FPosition, FSize, FRenderSize : TSGVector2f;
		FCursorOverImage : TSGBoolean;
		
		FCursorDragAndDropPressed : TSGCursor; // drag and drop cursor (pressed)
		FCursorDragAndDropNotPressed : TSGCursor; // drag and drop cursor (not  pressed)
		FCursorType : TSGUInt8; // 0 if standart; 1 if DragAndDropPressed; 2 if DragAndDropNotPressed
			private
		procedure InitImagePosition();
		procedure InitBackgroundImage();
		procedure FillBackgroundImage();
		procedure PrepareBackgroundImageMainThread();
		procedure RescaleImagePosition();
		procedure PaintImageInfo();
		procedure PaintImage();
		procedure PaintHintAndLoadingAnimation();
		procedure ProccessMouseWheel(const VWheel : TSGBool);
		procedure ProccessContextKeys();
		procedure OpenFileDialog();
		procedure SaveFileDialog();
		function CursorOverImage(const _CursorPosition : PSGVector2f = nil) : TSGBoolean;
		procedure ProccessCursorIcon();
			public
		procedure LoadingFromThread();
		end;

implementation

uses
		// Engine
	 SaGeStringUtils
	,SaGeRender
	,SaGeRenderBase
	,SaGeFileUtils
	,SaGeContextUtils
	,SaGeCommon
	,SaGeResourceManager
		// System
	,SysUtils
	;

//================
//=TSGImageViewer=
//================

destructor TSGImageViewer.Destroy();
begin
SGKill(FCursorDragAndDropPressed);
SGKill(FCursorDragAndDropNotPressed);
SGKill(FLoadingThread);
SGKill(FFont);
SGKill(FWaitAnimation);
SGKill(FBackgroundImage);
SGKill(FImage);
inherited;
end;

procedure TSGImageViewer_LoadThreadProc(const Viewer : TSGImageViewer);
begin
Viewer.LoadingFromThread();
end;

constructor TSGImageViewer.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FImage := nil;
FBackgroundImage := nil;
FLoadingDone := False;
FCursorOverImage := False;
FHintColor.Import(0, 0, 0);
FBackgroundColor := Context.GetDefaultWindowColor();
Render.ClearColor(FBackgroundColor.r, FBackgroundColor.g, FBackgroundColor.b, 1);
FWaitAnimation := TSGLoadingFrame.Create(Context);
FFont := SGCreateFontFromFile(Context, SGFontDirectory + DirectorySeparator + 'Tahoma.sgf', True);
FCursorDragAndDropPressed := SGCreateCursorFromFile(SGEngineDirectory + DirectorySeparator + 'drag and drop cursor (pressed).cur');
FCursorDragAndDropNotPressed := SGCreateCursorFromFile(SGEngineDirectory + DirectorySeparator + 'drag and drop cursor (not  pressed).cur');
FCursorType := 0;
FLoadingThread := TSGThread.Create(TSGThreadProcedure(@TSGImageViewer_LoadThreadProc), Self, True);
end;

class function TSGImageViewer.ClassName() : TSGString;
begin
Result := 'TSGImageViewer';
end;

procedure TSGImageViewer.LoadingFromThread();
begin
while (FImage = nil) do
	Sleep(10);
FImage.Load();
InitImagePosition();
FLoadingDone := True;
end;

procedure TSGImageViewer.PrepareBackgroundImageMainThread();
begin
InitBackgroundImage();
FillBackgroundImage();
end;

procedure TSGImageViewer.FillBackgroundImage();
const
	DefaultQuadSize   = 10;
	ColorThemesValues : array [0..1] of record FColor1, FColor2 : TSGUInt8; end =
		((FColor1 : 255; FColor2 : 187), (FColor1 : 117; FColor2 : 143));
	DefaultColorIndex = 1;
var
	ColorThemes : packed array of record FColor1, FColor2 : TSGVertex3uint8; end = nil;

procedure FillImage();
var
	OverageX, OverageY : TSGMaxEnum;

function PixelColor(const _x, _y : TSGMaxEnum) : TSGVertex3uint8; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
//todo
if ((((_x div DefaultQuadSize) + (_y div DefaultQuadSize)) mod 2) = 0) then
	Result := ColorThemes[DefaultColorIndex].FColor1
else
	Result := ColorThemes[DefaultColorIndex].FColor2;
end;

var
	Index, Index2 : TSGMaxEnum;
begin
OverageX := FBackgroundImage.Width mod DefaultQuadSize;
OverageY := FBackgroundImage.Height mod DefaultQuadSize;
for Index := 0 to FBackgroundImage.Width - 1 do
	for Index2 := 0 to FBackgroundImage.Height - 1 do
		FBackgroundImage.BitMap.SetPixel(Index, Index2, PixelColor(Index, Index2));
end;

var
	Index : TSGMaxEnum;
begin
if (FBackgroundImage = nil) then
	exit;
SetLength(ColorThemes, Length(ColorThemesValues));
for Index := 0 to High(ColorThemes) do
	begin
	ColorThemes[Index].FColor1 := SGVertex3uint8Import(ColorThemesValues[Index].FColor1, ColorThemesValues[Index].FColor1, ColorThemesValues[Index].FColor1);
	ColorThemes[Index].FColor2 := SGVertex3uint8Import(ColorThemesValues[Index].FColor2, ColorThemesValues[Index].FColor2, ColorThemesValues[Index].FColor2);
	end;
FillImage();
SetLength(ColorThemes, 0);
FBackgroundImage.LoadedIntoRAM := True;
end;

procedure TSGImageViewer.InitBackgroundImage();
begin
SGKill(FBackgroundImage);
FBackgroundImage := TSGImage.Create();
FBackgroundImage.Context := Context;
FBackgroundImage.BitMap.Width := FImage.BitMap.Width;
FBackgroundImage.BitMap.Height := FImage.BitMap.Height;
FBackgroundImage.BitMap.Channels := 3;
FBackgroundImage.BitMap.ChannelSize := 8;
FBackgroundImage.BitMap.ReAllocateMemory();
end;

procedure TSGImageViewer.Resize();
begin
RescaleImagePosition();
end;

procedure TSGImageViewer.DeleteRenderResources();
begin
SGKill(FImage);
SGKill(FBackgroundImage);
end;

procedure TSGImageViewer.PaintImageInfo();
var
	Iterator : TSGVector2f;

procedure PaintString(const S : TSGString);
begin
FFont.DrawFontFromTwoVertex2f(
	S,
	Iterator,
	SGVertex2fImport(Iterator.x + FFont.StringLength(S),Iterator.y + FFont.FontHeight));
Iterator.y += FFont.FontHeight + 1;
end;

begin
Iterator.Import(5, FRenderSize.y - (FFont.FontHeight + 1) * 5 - 2);
Render.Color(FHintColor);
PaintString('width = ' + SGStr(FImage.Width));
PaintString('height = ' + SGStr(FImage.Height));
PaintString('channels = ' + SGStr(FImage.BitMap.Channels));
PaintString('bitmap size = ' + SGGetSizeString(FImage.BitMap.Width * FImage.BitMap.Height * FImage.BitMap.Channels,'EN'));
PaintString('filename = ' + FImage.FileName);
end;

function TSGImageViewer.CursorOverImage(const _CursorPosition : PSGVector2f = nil) : TSGBoolean;
var
	CursorPosition : TSGPoint2int32;
	CursorPositionFloat : TSGVector2f;
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

procedure TSGImageViewer.ProccessMouseWheel(const VWheel : TSGBool);
var
	CursorPosition : TSGVector2f;

procedure ToVectors(out V1, V2 : TSGVector2f);
begin
V1 := FPosition - CursorPosition;
V2 := FPosition + FSize - CursorPosition;
end;

procedure FromVectors(const V1, V2 : TSGVector2f);
begin
FPosition := V1 + CursorPosition;
FSize := V2 + CursorPosition - FPosition;
end;

procedure MultVectors(var V1, V2 : TSGVector2f; const MN : TSGFloat);
begin
V1 *= MN;
V2 *= MN;
end;

const
	WheelRank = 1.5;
var
	V1, V2 : TSGVector2f;
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

procedure TSGImageViewer.ProccessCursorIcon();
var
	_CursorOverImage : TSGBoolean = False;
begin
if (FCursorType = 1) then
	FPosition += Context.CursorPosition(SGDeferenseCursorPosition);
_CursorOverImage := CursorOverImage();
if FCursorOverImage and (not _CursorOverImage) and (FCursorType in [1, 2]) then
	begin
	Context.Cursor := TSGCursor.Create(SGC_NORMAL);
	FCursorType := 0;
	end;
if (FSize.x > Render.Width) or (FSize.y > Render.Height) then
	begin
	if _CursorOverImage and ((FCursorType = 0) or ((FCursorType = 1) and (not Context.CursorKeysPressed(SGLeftCursorButton)))) then
		begin
		Context.Cursor := TSGCursor.Copy(FCursorDragAndDropNotPressed);
		FCursorType := 2;
		end;
	if FCursorOverImage and (FCursorType = 2) and Context.CursorKeysPressed(SGLeftCursorButton) and (Context.CursorKeyPressed = SGLeftCursorButton) then
		begin
		Context.Cursor := TSGCursor.Copy(FCursorDragAndDropPressed);
		FCursorType := 1;
		end;
	end
else if (FCursorType in [1, 2]) then
	begin
	Context.Cursor := TSGCursor.Create(SGC_NORMAL);
	FCursorType := 0;
	end;
FCursorOverImage := _CursorOverImage;
end;

procedure TSGImageViewer.ProccessContextKeys();
begin
if Context.CursorWheel() <> SGNullCursorWheel then
	ProccessMouseWheel(SGUpCursorWheel = Context.CursorWheel());
ProccessCursorIcon();
if Context.KeyPressed and (Context.KeyPressedChar = 'S') and Context.KeysPressed(SG_CTRL_KEY) then
	SaveFileDialog();
if Context.KeyPressed and (Context.KeyPressedChar = 'O') and Context.KeysPressed(SG_CTRL_KEY) then
	OpenFileDialog();
end;

procedure TSGImageViewer.OpenFileDialog();
begin

end;

procedure TSGImageViewer.SaveFileDialog();
begin
{FileWay := Context.FileSaveDialog(
	'Куда сохранить то?!',
	'Файлы рельефа(*.sggdrf)'+#0+'*.sggdrf'+#0+
	'All files(*.*)'+#0+'*.*'+#0+
	#0,
	'sggdrf');}
end;

procedure TSGImageViewer.Paint();
begin
ProccessContextKeys();
Render.InitMatrixMode(SG_2D);
PaintImage();
PaintHintAndLoadingAnimation();
end;

procedure TSGImageViewer.PaintImage();
begin
{Render.Color(FBackgroundColor);
with Render do
	begin
	BeginScene(SGR_QUADS);
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
		FBackgroundImage.DrawImageFromTwoVertex2f(FPosition, FSize + FPosition, True, SG_2D);
	FImage.DrawImageFromTwoVertex2f(FPosition, FSize + FPosition, True, SG_2D);
	end;
end;

procedure TSGImageViewer.PaintHintAndLoadingAnimation();
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
			SGVertex2fImport(5, FRenderSize.y - FFont.FontHeight - 5),
			SGVertex2fImport(5 + FFont.StringLength('Загрузка...'), FRenderSize.y - 5));
		end;
FWaitAnimation.PaintAt(Render.Width - 200, 50, 150, 150, not FLoadingDone);
end;

procedure TSGImageViewer.InitImagePosition();
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

procedure TSGImageViewer.RescaleImagePosition();
var
	RS : TSGVector2f;
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

procedure TSGImageViewer.LoadRenderResources();
begin
DeleteRenderResources();
FImage := TSGImage.Create(FFiles[0]);
FImage.Context := Context;
end;

class function TSGImageFileOpener.ClassName() : TSGString;
begin
Result := 'TSGImageFileOpener';
end;

//====================
//=TSGImageFileOpener=
//====================

class function TSGImageFileOpener.GetDrawableClass() : TSGFileOpenerDrawableClass;
begin
Result := TSGImageViewer;
end;

class function TSGImageFileOpener.GetExpansions() : TSGStringList;
begin
Result := nil;
if (TSGCompatibleContext <> nil) and (TSGCompatibleRender <> nil) then
	begin
	Result := nil;
	Result *= 'JPG';
	Result *= 'JPEG';
	Result *= 'BMP';
	Result *= 'TGA';
	Result *= 'SGIA';
	Result *= 'ICO';
	Result *= 'CUR';
	if SGResourceManager.LoadingIsSupported('PNG') then
		Result *= 'PNG';
	end;
end;

class function TSGImageFileOpener.ExpansionsSupported(const VExpansions : TSGStringList) : TSGBool;
var
	SupportedExpansions : TSGStringList = nil;
	S : TSGString = '';
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
SGRegistryFileOpener(TSGImageFileOpener);
end;

end.
