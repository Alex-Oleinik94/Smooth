{$INCLUDE Smooth.inc}

unit SmoothAllFractals;

interface

uses
	 SmoothBase
	,SmoothContextClasses
	,SmoothPaintableObjectContainer
	;

type
	TSAllFractals = class(TSPaintableObject)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
			private
		FDrawClasses : TSPaintableObjectContainer;
			public
		procedure Paint();override;
		end;

implementation

uses
	 SmoothExtensionManager

	// Fractals
	,SmoothFractalSierpinskiTetrahedron
	,SmoothFractalLevyCurve
	,SmoothFractalMandelbrotGUI
	,SmoothFractalMinkowskiCurve
	,SmoothFractalSierpinskiCarpet
	,SmoothFractalSierpinskiTriangle
	,SmoothFractalMengerSponge
	,SmoothFractalSierpinskiCarpetSixAngle
	,SmoothFractalSierpinskiCarpet2
	,SmoothFractalMengerSponge2
	;

constructor TSAllFractals.Create();
begin
inherited;
FDrawClasses := TSPaintableObjectContainer.Create(Context);
FDrawClasses.Add(TSFractalMengerSpongeRelease);
FDrawClasses.Add(TSFractalMandelbrotGUI);
FDrawClasses.Add(TSFractalSierpinskiTriangle);
FDrawClasses.Add(TSFractalSierpinskiTetrahedron);
FDrawClasses.Add(TSFractalMinkowskiCurve);
FDrawClasses.Add(TSFractalLevyCurve);
FDrawClasses.Add(TSFractalSierpinskiCarpet);
FDrawClasses.Add(TSFractalSierpinskiCarpet2);
FDrawClasses.Add(TSFractalSierpinskiCarpetSixAngle);
FDrawClasses.Add(TSFractalMengerSponge2);
FDrawClasses.Initialize();
FDrawClasses.ComboBox.SetBounds(FDrawClasses.ComboBox.Left, 28, FDrawClasses.ComboBox.Width, FDrawClasses.ComboBox.Height);
FDrawClasses.ComboBox.CursorQuickSelect := True;
end;

destructor TSAllFractals.Destroy();
begin
SKill(FDrawClasses);
inherited;
end;

class function TSAllFractals.ClassName():TSString;
begin
Result := 'Фракталы';
end;

procedure TSAllFractals.Paint();
begin
if (FDrawClasses <> nil) then
	FDrawClasses.Paint();
end;

initialization
begin
SRegisterDrawClass(TSAllFractals, False);
end;

end.
