{$INCLUDE SaGe.inc}

unit SaGeFractalTerrain;

interface
uses 
	 Classes

	,SaGeCommon
	,SaGeClasses
	,SaGeBase
	,SaGeBased
	,SaGeImages
	,SaGeCommonClasses
	,SaGeMesh
	;
type
	TSGFTGCornerVectors = array [0..3] of TSGVector3f;
	TSGFTGTerrain = packed array of packed array of TSGFloat;
	TSGFractalTerrainGenerator = class(TSGNamed)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
			protected
		FCornerVectors : TSGFTGCornerVectors;
		FUp : TSGVector3f;
		FEpsilon : TSGFloat;
		FSize : TSGLongWord;
			public
		function Generate() : TSG3DObject; overload;
		function Generate() : TSGFTGTerrain; overload;
			public
		property Up : TSGVector3f write FUp;
		property Epsilon : TSGFloat write FEpsilon;
		property Size : TSGLongWord write FSize;
		property CornerVectors : TSGFTGCornerVectors write FCornerVectors;
		end;

implementation

function TSGFractalTerrainGenerator.Generate() : TSG3DObject; overload;
begin
Result := nil;
end;

function TSGFractalTerrainGenerator.Generate() : TSGFTGTerrain; overload;
begin
Result := nil;
end;

constructor TSGFractalTerrainGenerator.Create();
begin
inherited;
end;

destructor TSGFractalTerrainGenerator.Destroy();
begin
inherited;
end;

class function TSGFractalTerrainGenerator.ClassName() : TSGString;
begin
Result := 'TSGFractalTerrainGenerator';
end;

end.
