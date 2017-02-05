{$INCLUDE SaGe.inc}

unit SaGeAllFractals;

interface

uses
	 SaGeBase
	,SaGeThreads
	,SaGeResourceManager
	,SaGeFractals
	,SaGePackages
	,SaGeCommonClasses
	,SaGeCommonUtils
	,SaGeScreen
	,SaGeCommon
	,SaGeUtils
	,SaGeImages
	,SaGeScreenBase
	,SaGeRender
	,SaGeRenderConstants
	,SaGeImagesBase
	,SaGeMesh
	,SaGeDateTime
	,SaGeSysUtils
	
	,Crt
	,Classes
	;

{$DEFINE SGREADINTERFACE}
{$INCLUDE SaGeFractalMengerSpunch.inc}
{$INCLUDE SaGeFractalMandelbrod.inc}
{$INCLUDE SaGeFractalKohTriangle.inc}
{$INCLUDE SaGeFractalPodkova.inc}
{$INCLUDE SaGeFractalLomanaya.inc}
{$INCLUDE SageFractalTetraider.inc}
{$UNDEF SGREADINTERFACE}

type
	TSGAllFractals = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName():string;override;
			private
		FDrawClasses : TSGDrawClasses;
			public
		procedure Paint();override;
		end;

implementation

uses
	 SaGeStringUtils
	,SaGeFileUtils
	,SaGeMathUtils
	,SaGeBaseUtils
	
	,SaGeFractalSierpinskiCarpet
	;

constructor TSGAllFractals.Create(const VContext:ISGContext);
begin
inherited Create(VContext);
FDrawClasses := TSGDrawClasses.Create(Context);
FDrawClasses.Add(TSGFractalMengerSpunchRelease);
FDrawClasses.Add(TSGFractalMandelbrodRelease);
FDrawClasses.Add(TSGFractalKohTriangle);
FDrawClasses.Add(TSGFractalTetraider);
FDrawClasses.Add(TSGFractalLomanaya);
FDrawClasses.Add(TSGFractalPodkova);
FDrawClasses.Add(TSGFractalSierpinskiCarpet);
FDrawClasses.Initialize();
FDrawClasses.ComboBox.SetBounds(FDrawClasses.ComboBox.Left, 28, FDrawClasses.ComboBox.Width, FDrawClasses.ComboBox.Height);
end;

destructor TSGAllFractals.Destroy();
begin
FDrawClasses.Destroy();
FDrawClasses:=nil;
inherited;
end;

class function TSGAllFractals.ClassName():string;
begin
Result := 'Фракталы';
end;

procedure TSGAllFractals.Paint();
begin
if FDrawClasses<>nil then
	FDrawClasses.Paint();
end;

{$DEFINE SGREADIMPLEMENTATION}
{$INCLUDE SaGeFractalMengerSpunch.inc}
{$INCLUDE SaGeFractalMandelbrod.inc}
{$INCLUDE SaGeFractalKohTriangle.inc}
{$INCLUDE SaGeFractalPodkova.inc}
{$INCLUDE SaGeFractalLomanaya.inc}
{$INCLUDE SageFractalTetraider.inc}
{$UNDEF SGREADIMPLEMENTATION}

initialization
begin
SGRegisterDrawClass(TSGAllFractals, False);
end;

end.
