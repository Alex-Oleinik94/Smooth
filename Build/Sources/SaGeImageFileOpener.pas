{$INCLUDE SaGe.inc}

unit SaGeImageFileOpener;

interface
uses
	  Classes
	, SaGeBase
	, SaGeBased
	, SaGeClasses
	, SaGeFileOpener
	, SaGeContext
	, SaGeLoading
	, SaGeUtils
	, SaGeCommonClasses
	, SaGeCommon
	, SaGeImages
	;

type
	TSGImageFileOpener = class(TSGFileOpener)
			public
		class function ClassName() : TSGString; override;
		class function GetExpansions() : TSGStringList; override;
		class function GetDrawableClass() : TSGFileOpenerDrawableClass; override;
		class function ExpansionsSuppored(const VExpansions : TSGStringList) : TSGBool; override;
		end;

type
	TSGImageViewer = class(TSGFileOpenerDrawable)
			public
		destructor Destroy();override;
		constructor Create(const VContext : ISGContext);override;
		class function ClassName() : TSGString; override;
		procedure DeleteDeviceResources();override;
		procedure LoadDeviceResources();override;
		procedure Paint();override;
		procedure Resize();override;
			private
		FBackgroundColor : TSGColor3f;
		FWaitAnimation : TSGWaiting;

		FBackgroundImage : TSGImage;
		FImage : TSGImage;
		FLoadingThread : TSGThread;
		FFont : TSGFont;
		FLoadingDone : TSGBool;
			private
		FPosition, FSize, FRenderSize : TSGVector2f;
			private
		procedure InitImagePosition();
		procedure RescaleImagePosition();
		procedure PaintImageInfo();
		procedure ProccessMouseWheel(const VWheel : TSGBool);
		procedure OpenFileDialog();
		procedure SaveFileDialog();
			public
		procedure LoadingFromThread();
		end;

implementation

uses
{$IFDEF WITHLIBPNG}
	SaGeImagesPng,
{$ENDIF}
	SaGeRender,
	SaGeRenderConstants,
	SysUtils
	;

class function TSGImageFileOpener.ClassName() : TSGString;
begin
Result := 'TSGImageFileOpener';
end;

destructor TSGImageViewer.Destroy();
begin
if FWaitAnimation <> nil then
	begin
	FWaitAnimation.Destroy();
	FWaitAnimation := nil;
	end;
if FImage <> nil then
	begin
	FImage.Destroy();
	FImage := nil;
	end;
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
FLoadingDone := False;
FBackgroundColor := Context.GetDefaultWindowColor();
Render.ClearColor(FBackgroundColor.r, FBackgroundColor.g, FBackgroundColor.b, 1);
FWaitAnimation := TSGWaiting.Create(Context);
FFont := TSGFont.Create(SGFontDirectory + Slash + 'Tahoma.sgf');
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
FLoadingDone := True;
end;

procedure TSGImageViewer.Resize();
begin
RescaleImagePosition();
end;

procedure TSGImageViewer.DeleteDeviceResources();
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
PaintString('FileName = ' + FImage.Way);
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

procedure TSGImageViewer.OpenFileDialog();
begin

end;

procedure TSGImageViewer.SaveFileDialog();
begin
{FileWay := Context.FileSaveDialog(
	'���� ��������� ��?!',
	'����� �������(*.sggdrf)'+#0+'*.sggdrf'+#0+
	'All files(*.*)'+#0+'*.*'+#0+
	#0,
	'sggdrf');}
end;

procedure TSGImageViewer.Paint();
begin
if Context.CursorWheel() <> SGNullCursorWheel then
	ProccessMouseWheel(SGUpCursorWheel = Context.CursorWheel());
if Context.KeyPressed and (Context.KeyPressedChar = 'S') and Context.KeysPressed(SG_CTRL_KEY) then
	begin
	SaveFileDialog();
	end;
Render.InitMatrixMode(SG_2D);
Render.Color(FBackgroundColor);
with Render do
	begin
	BeginScene(SGR_QUADS);
	Vertex2f(0,0);
	Vertex2f(Width,0);
	Vertex2f(Width,Height);
	Vertex2f(0,Height);
	EndScene();
	Color3f(1,1,1);
	end;
if FImage <> nil then
	if FImage.ReadyTexture() or FImage.ReadyToTexture then
		FImage.DrawImageFromTwoVertex2f(
			FPosition,
			FSize + FPosition,
			True,SG_2D);
if FFont <> nil then
	if FFont.FontReady then
		begin
		if FImage.ReadyTexture() or FImage.ReadyToTexture then
			begin
			PaintImageInfo();
			end
		else
			begin
			Render.Color3f(0.5,0.5,0.5);
			FFont.DrawFontFromTwoVertex2f(
				'��������...',
				SGVertex2fImport(5,FRenderSize.y - FFont.FontHeight - 5),
				SGVertex2fImport(5 + FFont.StringLength('��������...'),FRenderSize.y - 5));
			end;
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

procedure TSGImageViewer.LoadDeviceResources();
begin
DeleteDeviceResources();
FImage := TSGImage.Create(FFiles[0]);
FImage.Context := Context;
end;

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
Result := TSGImageFileOpener_GetAlwaysSuporedExpansions();
{$IFDEF WITHLIBPNG}
if SupporedPNG() then
	Result *= 'PNG';
{$ENDIF}
end;

class function TSGImageFileOpener.ExpansionsSuppored(const VExpansions : TSGStringList) : TSGBool;
var
	ASE : TSGStringList = nil;
	PNGInExpansions : TSGBool = False;
	S : TSGString = '';
begin
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
		Result := SupporedPNG();
{$ENDIF}
end;

initialization
begin
SGRegistryFileOpener(TSGImageFileOpener);
end;

end.