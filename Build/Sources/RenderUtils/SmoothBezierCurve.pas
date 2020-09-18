{$INCLUDE Smooth.inc}

unit SmoothBezierCurve;

interface

uses
	 SmoothBase
	,SmoothCommonStructs
	,SmoothVertexObject
	,SmoothContextClasses
	;

type
	TSBezierCurve = class;
	TSBezierCurveType = (S_Bezier_Curve_High, S_Bezier_Curve_Low);
	TSBezierCurve = class(TSPaintableObject)
			public
		constructor Create();override;
		destructor Destroy();override;
			private
		FStartArray : TSVertex3fList;
		F3dObject : TS3DObject;
		FDetalization : TSUInt32;
		FType : TSBezierCurveType;
		FLowIndex : TSUInt32;
		FLowAttitude : TSFloat64;
		procedure SetVertex(const Index:TSMaxEnum;const VVertex:TSVertex3f);
		function GetVertex(const Index:TSMaxEnum):TSVertex3f;
		function GetResultVertex(const Attitude:real;const FArray:PSVertex3f;const VLength:TSMaxEnum):TSVertex3f;inline;overload;
		function GetLow(const R:Real):TSVertex3f;inline;
			public
		property LowAttitude:Real read FLowAttitude;
		property LowIndex:LongWord read FLowIndex;
		function GetResultVertex(const Attitude:real):TSVertex3f;inline;overload;
		procedure Construct();
		procedure AddVertex(const VVertex:TSVertex3f);
		property Vertexes[Index : TSMaxEnum]:TSVertex3f read GetVertex write SetVertex;
		property Detalization:LongWord read FDetalization write FDetalization;
		procedure Paint();override;
		function VertexQuantity:TSMaxEnum;inline;
		end;

procedure SKill(var _BezierCurve : TSBezierCurve); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothRenderBase
	,SmoothCommon
	;

procedure SKill(var _BezierCurve : TSBezierCurve); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if _BezierCurve <> nil then
	begin
	_BezierCurve.Destroy();
	_BezierCurve := nil;
	end;
end;

function TSBezierCurve.VertexQuantity:TSMaxEnum;inline;
begin
if FStartArray=nil then
	Result:=0
else
	Result:=Length(FStartArray);
end;

procedure TSBezierCurve.Paint();
begin
if F3dObject<>nil then
	F3dObject.Paint();
end;

function TSBezierCurve.GetResultVertex(const Attitude:real):TSVertex3f;inline;overload;
begin
if (FType = S_Bezier_Curve_High)or (Length(FStartArray)<3) then
	Result:=GetResultVertex(Attitude,@FStartArray[0],Length(FStartArray))
else
	Result:=GetLow(Attitude);
end;

function TSBezierCurve.GetResultVertex(const Attitude:real;const FArray:PSVertex3f;const VLength:TSMaxEnum):TSVertex3f;inline;overload;
var
	VArray:TSVertex3fList;
	i:TSMaxEnum;
begin
if VLength=1 then
	Result:=FArray[0]
else if VLength=2 then
	Result:=SVectorInAttitude(FArray[0],FArray[1],Attitude)
else
	begin
	SetLength(VArray,VLength-1);
	for i:=0 to High(VArray) do
		VArray[i]:=SVectorInAttitude(FArray[i],FArray[i+1],Attitude);
	Result:=GetResultVertex(Attitude,@VArray[0],VLength-1);
	SetLength(VArray,0);
	end;
end;

function TSBezierCurve.GetLow(const R:Real):TSVertex3f;inline;
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

procedure TSBezierCurve.Construct();
var
	i:TSMaxEnum;
begin
if F3dObject<>nil then
	F3dObject.Destroy();
F3dObject:=nil;
if (FStartArray=nil) or (Length(FStartArray)=0) then
	Exit;
F3dObject:=TS3DObject.Create();
F3dObject.SetContext(Context);
F3dObject.ObjectColor:=SColor4fFromUInt32($FFFFFF);
F3dObject.EnableCullFace:=False;
F3dObject.ObjectPoligonesType:=SR_LINE_STRIP;
F3dObject.VertexType := S3dObjectVertexType3f;
F3dObject.SetVertexLength(FDetalization);
for i:=0 to FDetalization-1 do
	begin
	F3dObject.ArVertex3f[i]^:=GetResultVertex(i/(Detalization-1));
	end;
F3dObject.LoadToVBO();
end;

procedure TSBezierCurve.SetVertex(const Index:TSMaxEnum;const VVertex:TSVertex3f);
begin
if FStartArray<>nil then
	FStartArray[Index]:=VVertex;
end;

function TSBezierCurve.GetVertex(const Index:TSMaxEnum):TSVertex3f;
begin
Result:=FStartArray[Index];
end;

procedure TSBezierCurve.AddVertex(const VVertex:TSVertex3f);
begin
if FStartArray=nil then
	SetLength(FStartArray,1)
else
	SetLength(FStartArray,Length(FStartArray)+1);
FStartArray[High(FStartArray)]:=VVertex;
end;

constructor TSBezierCurve.Create();
begin
inherited;
FStartArray:=nil;
F3dObject:=nil;
FDetalization:=50;
FType:=S_Bezier_Curve_Low;
end;

destructor TSBezierCurve.Destroy();
begin
if FStartArray<>nil then
	SetLength(FStartArray,0);
if F3dObject<>nil then
	F3dObject.Destroy();
inherited;
end;

end.
