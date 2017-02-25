{$INCLUDE SaGe.inc}

unit SaGeBezierCurve;

interface

uses
	 SaGeBase
	,SaGeCommon
	,SaGeMesh
	,SaGeCommonClasses
	;

type
	TSGBezierCurve = class;
	TSGBezierCurveType = (SG_Bezier_Curve_High, SG_Bezier_Curve_Low);
	TSGBezierCurve = class(TSGDrawable)
			public
		constructor Create();override;
		destructor Destroy();override;
			private
		FStartArray : TSGVertex3fList;
		FMesh : TSG3DObject;
		FDetalization : TSGUInt32;
		FType : TSGBezierCurveType;
		FLowIndex : TSGUInt32;
		FLowAttitude : TSGFloat64;
		procedure SetVertex(const Index:TSGMaxEnum;const VVertex:TSGVertex3f);
		function GetVertex(const Index:TSGMaxEnum):TSGVertex3f;
		function GetResultVertex(const Attitude:real;const FArray:PSGVertex3f;const VLength:TSGMaxEnum):TSGVertex3f;inline;overload;
		function GetLow(const R:Real):TSGVertex3f;inline;
			public
		property LowAttitude:Real read FLowAttitude;
		property LowIndex:LongWord read FLowIndex;
		function GetResultVertex(const Attitude:real):TSGVertex3f;inline;overload;
		procedure Calculate();
		procedure AddVertex(const VVertex:TSGVertex3f);
		property Vertexes[Index : TSGMaxEnum]:TSGVertex3f read GetVertex write SetVertex;
		property Detalization:LongWord read FDetalization write FDetalization;
		procedure Paint();override;
		function VertexQuantity:TSGMaxEnum;inline;
		end;

implementation

uses
	 SaGeRenderConstants
	;

function TSGBezierCurve.VertexQuantity:TSGMaxEnum;inline;
begin
if FStartArray=nil then
	Result:=0
else
	Result:=Length(FStartArray);
end;

procedure TSGBezierCurve.Paint();
begin
if FMesh<>nil then
	FMesh.Paint();
end;

function TSGBezierCurve.GetResultVertex(const Attitude:real):TSGVertex3f;inline;overload;
begin
if (FType = SG_Bezier_Curve_High)or (Length(FStartArray)<3) then
	Result:=GetResultVertex(Attitude,@FStartArray[0],Length(FStartArray))
else
	Result:=GetLow(Attitude);
end;

function TSGBezierCurve.GetResultVertex(const Attitude:real;const FArray:PSGVertex3f;const VLength:TSGMaxEnum):TSGVertex3f;inline;overload;
var
	VArray:TSGVertex3fList;
	i:TSGMaxEnum;
begin
if VLength=1 then
	Result:=FArray[0]
else if VLength=2 then
	Result:=SGGetVertexInAttitude(FArray[0],FArray[1],Attitude)
else
	begin
	SetLength(VArray,VLength-1);
	for i:=0 to High(VArray) do
		VArray[i]:=SGGetVertexInAttitude(FArray[i],FArray[i+1],Attitude);
	Result:=GetResultVertex(Attitude,@VArray[0],VLength-1);
	SetLength(VArray,0);
	end;
end;

function TSGBezierCurve.GetLow(const R:Real):TSGVertex3f;inline;
var
	StN:Real;
begin
StN:=R*High(FStartArray);
FLowIndex:=trunc(StN);
FLowAttitude:=StN - FLowIndex;
if trunc(StN) = 0 then
	Result:=(
		GetResultVertex(StN,  @FStartArray[trunc(StN)],2)+
		GetResultVertex(StN/2,@FStartArray[trunc(StN)],3)
		)/2
else if trunc(StN) >= High(FStartArray)-1 then
	begin
	Result:=(
		GetResultVertex((StN-High(FStartArray)+2)/2	 		,@FStartArray[High(FStartArray)-2]		,3)+
		GetResultVertex((StN-(High(FStartArray)-1))			,@FStartArray[High(FStartArray)-1]		,2)
		)/2
	end
else
	Result:=(
		GetResultVertex((StN-(Trunc(StN)-1))/2		,@FStartArray[trunc(StN)-1]		,3)+
		GetResultVertex((StN-(Trunc(StN)))/2		,@FStartArray[trunc(StN)]		,3))/2;
end;

procedure TSGBezierCurve.Calculate();
var
	i:TSGMaxEnum;
begin
if FMesh<>nil then
	FMesh.Destroy();
FMesh:=nil;
if (FStartArray=nil) or (Length(FStartArray)=0) then
	Exit;
FMesh:=TSG3DObject.Create();
FMesh.SetContext(Context);
FMesh.ObjectColor:=SGGetColor4fFromLongWord($FFFFFF);
FMesh.EnableCullFace:=False;
FMesh.ObjectPoligonesType:=SGR_LINE_STRIP;
FMesh.VertexType := SGMeshVertexType3f;
FMesh.SetVertexLength(FDetalization);
for i:=0 to FDetalization-1 do
	begin
	FMesh.ArVertex3f[i]^:=GetResultVertex(i/(Detalization-1));
	end;
FMesh.LoadToVBO();
end;

procedure TSGBezierCurve.SetVertex(const Index:TSGMaxEnum;const VVertex:TSGVertex3f);
begin
if FStartArray<>nil then
	FStartArray[Index]:=VVertex;
end;

function TSGBezierCurve.GetVertex(const Index:TSGMaxEnum):TSGVertex3f;
begin
Result:=FStartArray[Index];
end;

procedure TSGBezierCurve.AddVertex(const VVertex:TSGVertex3f);
begin
if FStartArray=nil then
	SetLength(FStartArray,1)
else
	SetLength(FStartArray,Length(FStartArray)+1);
FStartArray[High(FStartArray)]:=VVertex;
end;

constructor TSGBezierCurve.Create();
begin
inherited;
FStartArray:=nil;
FMesh:=nil;
FDetalization:=50;
FType:=SG_Bezier_Curve_Low;
end;

destructor TSGBezierCurve.Destroy();
begin
if FStartArray<>nil then
	SetLength(FStartArray,0);
if FMesh<>nil then
	FMesh.Destroy();
inherited;
end;

end.
