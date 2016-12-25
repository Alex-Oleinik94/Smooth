{$INCLUDE SaGe.inc}

unit SaGeAllFractals;

interface

uses
	SaGeBase
	,SaGeBased
	,SaGeResourceManager
	,SaGeFractals
	,SaGePackages
	,SaGeCommonClasses
	,SaGeCommonUtils
	
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
			public
		FDrawClasses : TSGDrawClasses;
			public
		procedure Paint();override;
		end;

implementation

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
FDrawClasses.Initialize();
FDrawClasses.ComboBox.BoundsToNeedBounds();
FDrawClasses.ComboBox.SetBounds(5,5,SGDrawClassesComboBoxWidth,18);
FDrawClasses.ComboBox.BoundsToNeedBounds();
FDrawClasses.ComboBox.SetBounds(5,28,SGDrawClassesComboBoxWidth,18);
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
