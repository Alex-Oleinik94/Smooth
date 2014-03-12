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
	, SaGeContext
	, SaGeMesh
	, SaGeGameBase
	;
type
	TSGModel=class(TSGNod)
			public
		constructor Create();override;
		destructor Destroy(); override;
		class function ClassName():String;override;
			protected
		FMesh           : TSGCustomModel;
		FPosition       : TSGPosition;
			public
		procedure Draw();override;
		procedure InitMatrixForPosition();
		function FindProperty(const PropertyClass : TSGNodClass):TSGNod;inline;
			public
		property Position : TSGPosition read FPosition write FPosition;
		end;

implementation

function TSGModel.FindProperty(const PropertyClass : TSGNodClass):TSGNod;inline;
var
	Index : TSGLongWord;
begin
if FNods <> nil then
	begin
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

procedure TSGModel.InitMatrixForPosition();
begin

end;

procedure TSGModel.Draw();
begin
Render.PushMatrix();
InitMatrixForPosition();
if FMesh<>nil then
	FMesh.Draw();
Render.PopMatrix();
end;

constructor TSGModel.Create();
begin
inherited;
FMesh:=nil;
FillChar(FPosition,SizeOf(FPosition),0);
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
