{$INCLUDE SaGe.inc}

unit SaGeImageFileOpener;

interface
uses 
	  Classes
	, SaGeBase
	, SaGeBased
	, SaGeClasses
	, SaGeFileOpener
	;

type
	TSGImageFileOpener = class(TSGFileOpener)
			public
		class function ClassName() : TSGString; override;
		class function GetExpansions() : TSGStringList; override;
		class function GetDrawableClass() : TSGFileOpenerDrawableClass;override;
		end;

implementation

uses
{$IFDEF WITHLIBPNG}
	SaGeImagesPng,
{$ENDIF}
	SaGeContext,
	SaGeCommonClasses,
	SaGeRender,
	SaGeImages,
	SaGeCommon,
	SaGeRenderConstants
	;

class function TSGImageFileOpener.ClassName() : TSGString;
begin
Result := 'TSGImageFileOpener';
end;

type
	TSGImageViewer = class(TSGFileOpenerDrawable)
			public
		destructor Destroy();override;
		constructor Create(const VContext : ISGContext);override;
		class function ClassName() : TSGString; override;
		procedure DeleteDeviceResourses();override;
		procedure LoadDeviceResourses();override;
		procedure Paint();override;
			private
		FBackgroundColor : TSGColor3f;
		FImage : TSGImage;
		FBackgroundImage : TSGImage;
		end;

destructor TSGImageViewer.Destroy();
begin
if FImage <> nil then
	begin
	FImage.Destroy();
	FImage := nil;
	end;
inherited;
end;

constructor TSGImageViewer.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FImage := nil;
FBackgroundColor := Context.GetDefaultWindowColor();
Render.ClearColor(FBackgroundColor.r, FBackgroundColor.g, FBackgroundColor.b, 1);
Context.EndIncessantlyPainting();
end;

class function TSGImageViewer.ClassName() : TSGString; 
begin
Result := 'TSGImageViewer';
end;

procedure TSGImageViewer.DeleteDeviceResourses();
begin
if FImage <> nil then
	begin
	FImage.Destroy();
	FImage := nil;
	end;
end;

procedure TSGImageViewer.Paint();
begin
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
FImage.DrawImageFromTwoVertex2f(
	SGVertex2fImport(0,0),
	SGVertex2fImport(Render.Width,Render.Height),
	True,SG_2D);
end;

procedure TSGImageViewer.LoadDeviceResourses();
begin
DeleteDeviceResourses();
FImage := TSGImage.Create();
FImage.Context := Context;
FImage.Way := FFiles[0];
FImage.Loading();
FImage.ToTexture();
end;

class function TSGImageFileOpener.GetDrawableClass() : TSGFileOpenerDrawableClass;
begin
Result := TSGImageViewer;
end;

class function TSGImageFileOpener.GetExpansions() : TSGStringList; 
begin
Result := nil;
Result *= 'JPG';
Result *= 'JPEG';
Result *= 'BMP';
Result *= 'TGA';
Result *= 'SGIA';
{$IFDEF WITHLIBPNG}
if SupporedPNG() then
	Result *= 'PNG';
{$ENDIF}
end;

initialization
begin
SGRegistryFileOpener(TSGImageFileOpener);
end;

end.
