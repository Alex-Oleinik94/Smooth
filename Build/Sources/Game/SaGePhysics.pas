{$INCLUDE SaGe.inc}

unit SaGePhysics;

interface

uses
	 SaGeBase
	,SaGeModel
	,SaGeGameBase
	,SaGeContext
	,SaGeCommonClasses
	
	,kraft
	;

type
	TSGPhysicsObject = class
		function GetMatrix() : TSGPointer; virtual; abstract;
		end;
	TSGPhysics = class(TSGMutator)
			public
		constructor Create(const VContext : ISGContext);override;
		class function ClassName() : TSGString; override;
		procedure Start(); override;
		procedure Paint(); override;
		procedure UpDate(); override;
			protected
		DR : TSGBool;
			public
		property Drawable : TSGBool read DR write DR;
		end;

implementation

class function TSGPhysics.ClassName() : TSGString;
begin
Result := 'TSGPhysics';
end;

constructor TSGPhysics.Create(const VContext : ISGContext);
begin
inherited;
DR := False;
end;

procedure TSGPhysics.Start(); 
begin

end;

procedure TSGPhysics.Paint(); 
begin

end;

procedure TSGPhysics.UpDate();
begin

end;


end.
