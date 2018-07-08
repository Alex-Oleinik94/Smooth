{$INCLUDE SaGe.inc}

unit SaGeAllFractals;

interface

uses
	 SaGeBase
	,SaGeContextClasses
	,SaGePaintableObjectContainer
	;

type
	TSGAllFractals = class(TSGPaintableObject)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			private
		FDrawClasses : TSGPaintableObjectContainer;
			public
		procedure Paint();override;
		end;

implementation

uses
	 SaGePackages
	
	// Fractals
	,SageFractalTetraider
	,SaGeFractalPodkova
	,SaGeFractalMandelbrod
	,SaGeFractalLomanaya
	,SaGeFractalSierpinskiCarpet
	,SaGeFractalKohTriangle
	,SaGeFractalMengerSpunch
	,SaGeFractalSixAngle
	;

constructor TSGAllFractals.Create();
begin
inherited;
FDrawClasses := TSGPaintableObjectContainer.Create(Context);
FDrawClasses.Add(TSGFractalMengerSpunchRelease);
FDrawClasses.Add(TSGFractalMandelbrodRelease);
FDrawClasses.Add(TSGFractalKohTriangle);
FDrawClasses.Add(TSGFractalTetraider);
FDrawClasses.Add(TSGFractalLomanaya);
FDrawClasses.Add(TSGFractalPodkova);
FDrawClasses.Add(TSGFractalSierpinskiCarpet);
FDrawClasses.Add(TSGFractalSixAngle);
FDrawClasses.Initialize();
FDrawClasses.ComboBox.SetBounds(FDrawClasses.ComboBox.Left, 28, FDrawClasses.ComboBox.Width, FDrawClasses.ComboBox.Height);
end;

destructor TSGAllFractals.Destroy();
begin
FDrawClasses.Destroy();
FDrawClasses:=nil;
inherited;
end;

class function TSGAllFractals.ClassName():TSGString;
begin
Result := 'Фракталы';
end;

procedure TSGAllFractals.Paint();
begin
if (FDrawClasses <> nil) then
	FDrawClasses.Paint();
end;

initialization
begin
SGRegisterDrawClass(TSGAllFractals, False);
end;

end.
