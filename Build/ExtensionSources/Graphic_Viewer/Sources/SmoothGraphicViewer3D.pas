{$INCLUDE Smooth.inc}

unit SmoothGraphicViewer3D;

interface

uses 
	 SmoothBase
	,SmoothContextInterface
	,Smooth3DFractal
	,SmoothComputableExpression
	,SmoothRenderBase
	;

type
	TSGraphViewer3D=class(TS3DFractal)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName():string;override;
		procedure Paint();override;
			public
		FFunction:string;
		FExpression:TSExpression;
		procedure Construct();override;
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothVertexObject
	;

procedure TSGraphViewer3D.Paint();
begin
inherited;
end;

procedure TSGraphViewer3D.Construct();
var
	i,ii:LongWord;
	rx,ry,rd:single;
begin
inherited;
Clear3dObject();
Construct3dObjects(Sqr(Depth),SR_QUADS,S3dObjectVertexType3f);
rx:=-4;
rd:=8/Depth;
for i:=0 to Depth-1 do
	begin
	ry:=-4;
	for ii:=0 to Depth-1 do
		begin
		FExpression.BeginCalculate();
		FExpression.ChangeVariables('x',TSExpressionChunkCreateReal(rx));
		FExpression.ChangeVariables('y',TSExpressionChunkCreateReal(ry));
		FExpression.Calculate();
		//FExpression.Resultat.FConst
		ry+=rd;
		end;
	rx+=rd;
	end;
end;

constructor TSGraphViewer3D.Create(const VContext : ISContext);
begin
inherited;
Depth:=1000;
Threads:=0;
FEnableNormals:=True;
FEnableColors:=True;
FFunction:='x*y';
FExpression:=TSExpression.Create();
FExpression.Expression:=SStringToPChar(FFunction);
Construct();
end;

destructor TSGraphViewer3D.Destroy();
begin
inherited;
end;

class function TSGraphViewer3D.ClassName():string;
begin
Result:='Graph Viewer 3D';
end;

end.
