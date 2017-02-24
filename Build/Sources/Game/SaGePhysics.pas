{$INCLUDE SaGe.inc}

unit SaGePhysics;

interface

uses
	 SaGeBase
	,SaGeModel
	,SaGeGameBase
	,SaGeNet
	,SaGeContext
	,SaGeCommonClasses
	
	,kraft
	;

type
	TSGPhysicsObject = class
		function GetMatrix() : TSGPointer; virtual; abstract;
		end;
	TSGPhysics = class
		DR : TSGBool;
		class function Create(const VContext : ISGContext) : TSGPhysics;virtual; abstract;
		procedure Start(); virtual; abstract;
		procedure Paint(); virtual; abstract;
		procedure UpDate(); virtual; abstract;
		property Drawable : TSGBool read DR write DR;
		end;

implementation

end.
