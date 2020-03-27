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
	
	//,SmoothFractalSpecialProject //"deprecated"
	
	// Fractals
	,SmoothFractalSierpinskiTetrahedron
	,SmoothFractalLevyCurve
	,SmoothFractalMandelbrot
	,SmoothFractalMinkowskiCurve
	,SmoothFractalSierpinskiCarpet
	,SmoothFractalSierpinskiTriangle
	,SmoothFractalMengerSponge
	,SmoothFractalSierpinskiCarpetSixAngle
	;

constructor TSAllFractals.Create();
begin
inherited;
FDrawClasses := TSPaintableObjectContainer.Create(Context);
FDrawClasses.Add(TSFractalMengerSpongeRelease);
FDrawClasses.Add(TSFractalMandelbrotRelease);
FDrawClasses.Add(TSFractalSierpinskiTriangle);
FDrawClasses.Add(TSFractalSierpinskiTetrahedron);
FDrawClasses.Add(TSFractalMinkowskiCurve);
FDrawClasses.Add(TSFractalLevyCurve);
FDrawClasses.Add(TSFractalSierpinskiCarpet);
FDrawClasses.Add(TSFractalSierpinskiCarpetSixAngle);
FDrawClasses.Initialize();
FDrawClasses.ComboBox.SetBounds(FDrawClasses.ComboBox.Left, 28, FDrawClasses.ComboBox.Width, FDrawClasses.ComboBox.Height);
end;

destructor TSAllFractals.Destroy();
begin
FDrawClasses.Destroy();
FDrawClasses:=nil;
inherited;
end;

class function TSAllFractals.ClassName():TSString;
begin
Result := '��������';
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