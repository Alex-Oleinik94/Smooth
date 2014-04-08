
{$IFDEF SGREADINTERFACE}
type
	TSGGraphViewer3D=class(TSG3DFractal)
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		class function ClassName():string;override;
		procedure Draw();override;
			public
		FFunction:string;
		FExpression:TSGExpression;
		procedure Calculate();override;
		end;
{$ENDIF}


{$IFDEF SGREADIMPLEMENTATION}
procedure TSGGraphViewer3D.Draw();
begin
inherited;
end;

procedure TSGGraphViewer3D.Calculate();
var
	i,ii:LongWord;
	rx,ry,rd:single;
begin
inherited;
ClearMesh();
CalculateMeshes(Sqr(Depth),SGR_QUADS,SGMeshVertexType3f);
rx:=-4;
rd:=8/Depth;
for i:=0 to Depth-1 do
	begin
	ry:=-4;
	for ii:=0 to Depth-1 do
		begin
		FExpression.BeginCalculate();
		FExpression.ChangeVariables('x',TSGExpressionChunkCreateReal(rx));
		FExpression.ChangeVariables('y',TSGExpressionChunkCreateReal(ry));
		FExpression.Calculate();
		//FExpression.Resultat.FConst
		ry+=rd;
		end;
	rx+=rd;
	end;
end;

constructor TSGGraphViewer3D.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
Depth:=1000;
Threads:=0;
FEnableNormals:=True;
FEnableColors:=True;
FFunction:='x*y';
FExpression:=TSGExpression.Create();
FExpression.Expression:=SGStringToPChar(FFunction);
Calculate();
end;

destructor TSGGraphViewer3D.Destroy();
begin
inherited;
end;

class function TSGGraphViewer3D.ClassName():string;
begin
Result:='Graph Viewer 3D';
end;

{$ENDIF}


