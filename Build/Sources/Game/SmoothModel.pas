{$INCLUDE Smooth.inc}

unit SmoothModel;

interface

uses 
	 Classes
	,SmoothCommon
	,SmoothBase
	,SmoothImage
	,SmoothRender
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothMesh
	,SmoothGameBase
	,SmoothMatrix
	;

type
	TSModel = class(TSNod)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy(); override;
		class function ClassName():TSString;override;
			protected
		FMesh           : TSCustomModel;
		FMatrix         : PSMatrix4x4;
			public
		procedure Paint();override;
		procedure InitModelMatrix();
		function FindProperty(const PropertyClass : TSNodClass):TSNod;inline;
		procedure LoadToVBO();inline;
			public
		property Mesh   : TSCustomModel read FMesh   write FMesh;
		property Matrix : PSMatrix4x4   read FMatrix write FMatrix;
		end;

implementation

uses
	 SmoothLog
	;

procedure TSModel.LoadToVBO();
begin
if FMesh <> nil then
	begin
	FMesh.Context := Context;
	FMesh.LoadToVBO();
	end;
end;

function TSModel.FindProperty(const PropertyClass : TSNodClass) : TSNod;inline;
var
	Index : TSLongWord;
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

procedure TSModel.InitModelMatrix();
begin
if FMatrix <> nil then
	Render.MultMatrixf(FMatrix);
end;

procedure TSModel.Paint();
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

constructor TSModel.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FMesh   := TSCustomModel.Create();
FMatrix := nil;
FMesh.Context := Context;
end;

destructor TSModel.Destroy(); 
begin
if FMesh <> nil then
	begin
	FMesh.Destroy();
	FMesh := nil;
	end;
inherited;
end;

class function TSModel.ClassName():String;
begin
Result := 'TSModel';
end;

end.
