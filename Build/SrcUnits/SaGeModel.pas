{$INCLUDE Includes\SaGe.inc}

unit SaGeModel;

interface
uses 
	  Classes
	, SaGeCommon
	, SaGeBase
	, SaGeBased
	, SaGeUtils
	, SaGeImages
	, SaGeRender
	, SaGeContext
	, SaGeMesh
	, SaGeGameMesh;
type
	TSGCustomPosition = record
		case byte of
		0: (FLocation : TSGVertex3f; FTurn   : TSGVertex3f);
		1: (X, Y, Z   : TSGSingle;   A, B, G : TSGSingle);
		end;
	
	TSGPosition = object
		FPosition : TSGCustomPosition;
		property x         : TSGSingle   read FPosition.x         write FPosition.x;
		property y         : TSGSingle   read FPosition.y         write FPosition.y;
		property z         : TSGSingle   read FPosition.z         write FPosition.z;
		property a         : TSGSingle   read FPosition.a         write FPosition.a;
		property b         : TSGSingle   read FPosition.b         write FPosition.b;
		property g         : TSGSingle   read FPosition.g         write FPosition.g;
		property Location  : TSGVertex3f read FPosition.FLocation write FPosition.FLocation;
		property Turn      : TSGVertex3f read FPosition.FTurn     write FPosition.FTurn;
		end;
	
	TSGModel=class(TSGDrawClass)
			public
		constructor Create();override;
		destructor Destroy(); override;
		class function ClassName():String;override;
			protected
		FMesh           : TSG3DObject;
		FColizableMesh  : TSG3DObject;
		FPosition       : TSGPosition;
		FCanMovement    : TSGBoolean;
		FPositionShift  : TSGPosition;
		FPhisicDistance : TSGSingle;
			public
		procedure Draw();override;
		end;

implementation

procedure TSGModel.Draw();
begin

end;

constructor TSGModel.Create();
begin
inherited;
FMesh:=nil;
FColizableMesh:=nil;
end;

destructor TSGModel.Destroy(); 
begin
inherited;
end;

class function TSGModel.ClassName():String;
begin
Result:='TSGModel';
end;

end.
