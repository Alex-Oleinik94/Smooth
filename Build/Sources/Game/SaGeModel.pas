{$INCLUDE SaGe.inc}

unit SaGeModel;

interface

uses 
	 Classes
	,SaGeCommon
	,SaGeBase
	,SaGeImage
	,SaGeRender
	,SaGeContextClasses
	,SaGeContextInterface
	,SaGeMesh
	,SaGeGameBase
	,SaGeMatrix
	;

type
	TSGModel = class(TSGNod)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy(); override;
		class function ClassName():TSGString;override;
			protected
		FMesh           : TSGCustomModel;
		FMatrix         : PSGMatrix4x4;
			public
		procedure Paint();override;
		procedure InitModelMatrix();
		function FindProperty(const PropertyClass : TSGNodClass):TSGNod;inline;
		procedure LoadToVBO();inline;
			public
		property Mesh   : TSGCustomModel read FMesh   write FMesh;
		property Matrix : PSGMatrix4x4   read FMatrix write FMatrix;
		end;

implementation

uses
	 SaGeLog
	;

procedure TSGModel.LoadToVBO();
begin
if FMesh <> nil then
	begin
	FMesh.Context := Context;
	FMesh.LoadToVBO();
	end;
end;

function TSGModel.FindProperty(const PropertyClass : TSGNodClass) : TSGNod;inline;
var
	Index : TSGLongWord;
begin
Result := nil;
if FNods <> nil then
	if QuantityNods <> 0 then
		for Index := 0 to QuantityNods - 1 do
			if Nods[Index] is PropertyClass then
				begin
				Result := Nods[Index];
				Break;
				end;
end;

procedure TSGModel.InitModelMatrix();
begin
if FMatrix <> nil then
	Render.MultMatrixf(FMatrix);
end;

procedure TSGModel.Paint();
begin
if FMesh <> nil then
	begin
	if FMatrix <> nil then
		begin
		Render.PushMatrix();
		InitModelMatrix();
		FMesh.Paint();
		Render.PopMatrix()
		end
	else
		FMesh.Paint();
	end;
end;

constructor TSGModel.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FMesh   := TSGCustomModel.Create();
FMatrix := nil;
FMesh.Context := Context;
end;

destructor TSGModel.Destroy(); 
begin
if FMesh <> nil then
	begin
	FMesh.Destroy();
	FMesh := nil;
	end;
inherited;
end;

class function TSGModel.ClassName():String;
begin
Result := 'TSGModel';
end;

end.
