{$INCLUDE Smooth.inc}

unit SmoothPhysics;

interface

uses
	 SmoothBase
	,SmoothModel
	,SmoothGameBase
	,SmoothContext
	,SmoothContextClasses
	,SmoothContextInterface
	
	,kraft
	;

type
	TSPhysicsObject = class
		function GetMatrix() : TSPointer; virtual; abstract;
		end;
	TSPhysics = class(TSMutator)
			public
		constructor Create(const VContext : ISContext);override;
		class function ClassName() : TSString; override;
		procedure Start(); override;
		procedure Paint(); override;
		procedure UpDate(); override;
			protected
		DR : TSBool;
			public
		property Drawable : TSBool read DR write DR;
		end;

implementation

class function TSPhysics.ClassName() : TSString;
begin
Result := 'TSPhysics';
end;

constructor TSPhysics.Create(const VContext : ISContext);
begin
inherited;
DR := False;
end;

procedure TSPhysics.Start(); 
begin

end;

procedure TSPhysics.Paint(); 
begin

end;

procedure TSPhysics.UpDate();
begin

end;


end.
