{$INCLUDE SaGe.inc}

unit SaGeImageFileOpener;

interface

uses
	 Classes
	
	,SaGeBase
	,SaGeLists
	,SaGeBaseClasses
	,SaGeFileOpener
	,SaGeContext
	,SaGeLoading
	,SaGeFont
	,SaGeContextClasses
	,SaGeContextInterface
	,SaGeCommonStructs
	,SaGeImage
	,SaGeThreads
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
		destructor Destroy();override;
		constructor Create(const VContext : ISGContext);override;
		class function ClassName() : TSGString; override;
		procedure DeleteRenderResources();override;
		procedure LoadRenderResources();override;
		procedure Paint();override;
		procedure Resize();override;
			private
		FBackgroundColor : TSGColor3f;
		FWaitAnimation : TSGWaiting;
		
		FBackgroundImage : TSGImage;
		FImage : TSGImage;
		FImageBackground : TSGImage;
		
		FLoadingThread : TSGThread;
		FFont : TSGFont;
		FLoadingDone : TSGBool;
			private
		FPosition, FSize, FRenderSize : TSGVector2f;
			private
		procedure InitImagePosition();
		procedure InitBackgroundImage();
		procedure RescaleImagePosition();
		procedure PaintImageInfo();
		procedure PaintHintAndLoadingAnimation();
		procedure ProccessMouseWheel(const VWheel : TSGBool);
		procedure ProccessContextKeys();
		procedure OpenFileDialog();
		procedure SaveFileDialog();
			public
		procedure LoadingFromThread();
		end;

implementation

uses
	 SaGeStringUtils
	{$IFDEF WITHLIBPNG}
		,SaGeImagePng
	{$ENDIF}
	,SaGeRender
	,SaGeRenderBase
	,SaGeFileUtils
	,SaGeContextUtils
	
	,SysUtils
	;

//================
//=TSGImageViewer=
//================

destructor TSGImageViewer.Destroy();
begin
SGKill(FWaitAnimation);
SGKill(FImageBackground);
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
FImageBackground := nil;
FLoadingDone := False;
FBackgroundColor := Context.GetDefaultWindowColor();
Render.ClearColor(FBackgroundColor.r, FBackgroundColor.g, FBackgroundColor.b, 1);
FWaitAnimation := TSGWaiting.Create(Context);
FFont := TSGFont.Create(SGFontDirectory + DirectorySeparator + 'Tahoma.sgf');
FFont.SetContext(Context);
FLoadingThread := TSGThread.Create(TSGThreadProcedure(@TSGImageViewer_LoadThreadProc), Self, True);
end;

class function TSGImageViewer.ClassName() : TSGString;
begin
Result := 'TSGImageViewer';
end;

procedure TSGImageViewer.LoadingFromThread();
begin
FFont.Loading();
while FImage = nil do
	Sleep(10);
FImage.Loading();
InitImagePosition();
if FImage.Image.Channels = 4 then
	InitBackgroundImage();
FLoadingDone := True;
end;

procedure TSGImageViewer.InitBackgroundImage();
begin
SGKill(FImageBackground);
FImageBackground := TSGImage.Create();

end;

procedure TSGImageViewer.Resize();
begin
RescaleImagePosition();
end;

procedure TSGImageViewer.DeleteRenderResources();
begin
if FImage <> nil then
	begin
	FImage.Destroy();
	FImage := nil;
	end;
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
Render.Color3f(0.5,0.5,0.5);
PaintString('FileName = ' + FImage.FileName);
PaintString('Width = ' + SGStr(FImage.Width));
PaintString('Height = ' + SGStr(FImage.Height));
PaintString('Channels = ' + SGStr(FImage.Channels));
PaintString('Bitmap Size = ' + SGGetSizeString(FImage.Width * FImage.Height * FImage.Channels,'EN'));
end;

procedure TSGImageViewer.ProccessMouseWheel(const VWheel : TSGBool);
var
	CursorPos : TSGPoint2int32;
	CursorPosF : TSGVector2f;

procedure ToVectors(out V1, V2 : TSGVector2f);
begin
V1 := FPosition - CursorPosF;
V2 := FPosition + FSize - CursorPosF;
end;

procedure FromVectors(const V1, V2 : TSGVector2f);
begin
FPosition := V1 + CursorPosF;
FSize := V2 + CursorPosF - FPosition;
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
CursorPos := Context.CursorPosition();
CursorPosF.Import(CursorPos.x, CursorPos.y);
if  (CursorPosF.x > FPosition.x) and
	(CursorPosF.y > FPosition.y) and
	(CursorPosF.x < FPosition.x + FSize.x) and
	(CursorPosF.y < FPosition.y + FSize.y) then
	begin
	ToVectors(V1, V2);
	if VWheel then
		begin
		MultVectors(V1, V2, WheelRank);
		end
	else
		begin
		MultVectors(V1, V2, 1 / WheelRank);
		end;
	FromVectors(V1, V2);
	RescaleImagePosition();
	end;
end;

procedure TSGImageViewer.ProccessContextKeys();
begin
if Context.CursorWheel() <> SGNullCursorWheel then
	ProccessMouseWheel(SGUpCursorWheel = Context.CursorWheel());
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
if (FImage <> nil) and (FImage.ReadyTexture() or FImage.ReadyToTexture) then
	begin
	Render.Color3f(1, 1, 1);
	if (FBackgroundImage <> nil) and (FImage.ReadyTexture() or FImage.ReadyToTexture) then
		FBackgroundImage.DrawImageFromTwoVertex2f(FPosition, FSize + FPosition, True, SG_2D);
	FImage.DrawImageFromTwoVertex2f(FPosition, FSize + FPosition, True, SG_2D);
	end;
PaintHintAndLoadingAnimation();
end;

procedure TSGImageViewer.PaintHintAndLoadingAnimation();
begin
if (FFont <> nil) and FFont.FontReady then
	if (FImage <> nil) and (FImage.ReadyTexture() or FImage.ReadyToTexture) then
		PaintImageInfo()
	else
		begin
		Render.Color3f(0.5, 0.5, 0.5);
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

function TSGImageFileOpener_GetAlwaysSuporedExpansions() : TSGStringList;
begin
Result := nil;
Result *= 'JPG';
Result *= 'JPEG';
Result *= 'BMP';
Result *= 'TGA';
Result *= 'SGIA';
end;

class function TSGImageFileOpener.GetExpansions() : TSGStringList;
begin
Result := nil;
if (TSGCompatibleContext <> nil) and (TSGCompatibleRender <> nil) then
	begin
	Result := TSGImageFileOpener_GetAlwaysSuporedExpansions();
	{$IFDEF WITHLIBPNG}
	if SupportedPNG() then
		Result *= 'PNG';
	{$ENDIF}
	end;
end;

class function TSGImageFileOpener.ExpansionsSupported(const VExpansions : TSGStringList) : TSGBool;
var
	ASE : TSGStringList = nil;
	PNGInExpansions : TSGBool = False;
	S : TSGString = '';
begin
Result := False;
ASE := TSGImageFileOpener_GetAlwaysSuporedExpansions();
Result := True;
for S in VExpansions do
	if not (S in ASE) then
		begin
		if S = 'PNG' then
			PNGInExpansions := True
		else
			begin
			Result := False;
			break;
			end;
		end;
{$IFDEF WITHLIBPNG}
if Result = True then
	if PNGInExpansions then
		Result := SupportedPNG();
{$ENDIF}
if Result then
	if (TSGCompatibleContext = nil) or (TSGCompatibleRender = nil) then
		Result := False;
end;

initialization
begin
SGRegistryFileOpener(TSGImageFileOpener);
end;

end.
