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
	, SaGeGameBase
	;
type
	TSGModel=class(TSGNod)
			public
		constructor Create();override;
		destructor Destroy(); override;
		class function ClassName():String;override;
			protected
		FMesh           : TSG3DObject;
		FPosition       : TSGPosition;
			public
		procedure Draw();override;
		procedure InitMatrixForPosition();
		end;

implementation

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
