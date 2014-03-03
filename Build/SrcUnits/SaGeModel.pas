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
		0: (FVertex : TSGVertex3f; FAngles : TSGVertex3f);
		1: (X, Y, Z:TSGSingle; A, B, G : TSGSingle);
		end;
	
	TSGPosition = object
		FPosition : TSGCustomPosition;
		end;
	
	TSGModel=class(TSGDrawClass)
			public
		constructor Create();override;
		destructor Destroy(); override;
		class function ClassName():String;override;
			protected
		FMesh          : TSG3DObject;
		FColizableMesh : TSG3DObject;
		FPosition      : TSGPosition;
		FPositionShift : TSGPosition;
		FDistance      : TSGSingle;
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
