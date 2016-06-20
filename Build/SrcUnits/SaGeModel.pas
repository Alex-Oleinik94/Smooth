{$INCLUDE Includes\SaGe.inc}

unit SaGeModel;

interface
uses 
	  Classes
	, SaGeCommon
	, SaGeBase
	, SaGeBased
	, SaGeImages
	, SaGeRender
	, SaGeContextInterface
	, SaGeMesh
	, SaGeGameBase
	;
type
	TSGModel=class(TSGNod)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy(); override;
		class function ClassName():TSGString;override;
			protected
		FMesh           : TSGCustomModel;
		FMatrix         : TSGPointer;
			public
		procedure Paint();override;
		procedure InitModelMatrix();
		function FindProperty(const PropertyClass : TSGNodClass):TSGNod;inline;
		procedure LoadToVBO();inline;
			public
		property Mesh   : TSGCustomModel write FMesh;
		property Matrix : TSGPointer     write FMatrix;
		end;

implementation

procedure TSGModel.LoadToVBO();
begin
FMesh.LoadToVBO();
end;

function TSGModel.FindProperty(const PropertyClass : TSGNodClass):TSGNod;inline;
var
	Index : TSGLongWord;
begin
if FNods <> nil then
	begin
	if QuantityNods<>0 then
		for Index := 0 to QuantityNods-1 do
			if Nods[Index] is PropertyClass then
				begin
				Result:=Nods[Index];
				Break;
				end;
	end
else
	Result:=nil;
end;

procedure TSGModel.InitModelMatrix();
begin
if FMatrix<>nil then
	Render.MultMatrixf(FMatrix);
end;

procedure TSGModel.Paint();
begin
InitModelMatrix();
if FMesh<>nil then
	FMesh.Paint();
end;

constructor TSGModel.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FMesh:=nil;
FMatrix:=nil;
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
