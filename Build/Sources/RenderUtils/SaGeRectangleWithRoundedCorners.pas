{$INCLUDE SaGe.inc}

unit SaGeRectangleWithRoundedCorners;

interface

uses
	 SaGeBase
	,SaGeCommonStructs
	,SaGeRenderInterface
	;

type
	TSGRectangleWithRoundedCornersFloat   = TSGFloat32;
	TSGRectangleWithRoundedCornersVector2 = TSGVector2f;
	TSGRectangleWithRoundedCornersVector3 = TSGVector3f;

function SGRectangleWithRoundedCornersConstruct(const Vertex1,Vertex3: TSGVertex3f; const Radius:real; const Interval:LongInt):TSGVertex3fList;

procedure SGRoundQuad(const VRender:ISGRender;const Vertex1,Vertex3: TSGVertex3f; const Radius:real; const Interval:LongInt;const QuadColor: TSGColor4f; const LinesColor: TSGColor4f; const WithLines:boolean = False;const WithQuad:boolean = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SGRoundQuad(const VRender:ISGRender;const Vertex12,Vertex32: TSGVertex2f; const Radius:real; const Interval:LongInt;const QuadColor: TSGColor4f; const LinesColor: TSGColor4f; const WithLines:boolean = False;const WithQuad:boolean = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SGRoundWindowQuad(const VRender:ISGRender;const Vertex11,Vertex13: TSGVector2f;const Vertex21,Vertex23: TSGVector2f;
	const Radius1:real;const Radius2:real; const Interval:LongInt;const QuadColor1: TSGColor4f;const QuadColor2: TSGColor4f;
	const WithLines:boolean; const LinesColor1: TSGColor4f; const LinesColor2: TSGColor4f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGRectangleWithRoundedCornersDraw(const VRender:ISGRender;const ArVertex:TSGVertex3fList;const Interval:LongInt;const QuadColor: TSGColor4f; const LinesColor: TSGColor4f; const WithLines:boolean = False;const WithQuad:boolean = True);

implementation

uses
	 SaGeRenderBase
	,SaGeCommon
	;

procedure SGRoundWindowQuad(const VRender:ISGRender;const Vertex11,Vertex13: TSGVector2f;const Vertex21,Vertex23: TSGVector2f;
	const Radius1:real;const Radius2:real; const Interval:LongInt;const QuadColor1: TSGColor4f;const QuadColor2: TSGColor4f;
	const WithLines:boolean; const LinesColor1: TSGColor4f; const LinesColor2: TSGColor4f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SGRoundQuad(VRender,Vertex11,Vertex13,Radius1,Interval,QuadColor1,LinesColor1,WithLines);
SGRoundQuad(VRender,Vertex21,Vertex23,Radius2,Interval,QuadColor2,LinesColor2,WithLines);
end;

procedure SGRoundQuad(
	const VRender:ISGRender;
	const Vertex12,Vertex32: TSGVertex2f;
	const Radius:real;
	const Interval:LongInt;
	const QuadColor: TSGColor4f;
	const LinesColor: TSGColor4f;
	const WithLines:boolean = False;
	const WithQuad:boolean = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	ArVertex : TSGVertex3fList = nil;
	Vertex1, Vertex3 : TSGVertex3f;
begin
Vertex1.Import(Vertex12.x, Vertex12.y);
Vertex3.Import(Vertex32.x, Vertex32.y);
ArVertex := SGRectangleWithRoundedCornersConstruct(Vertex1,Vertex3,Radius,Interval);
SGRectangleWithRoundedCornersDraw(VRender,ArVertex,Interval,QuadColor,LinesColor,WithLines,WithQuad);
SetLength(ArVertex,0);
end;

procedure SGRoundQuad(
	const VRender:ISGRender;
	const Vertex1,Vertex3: TSGVertex3f;
	const Radius:real;
	const Interval:LongInt;
	const QuadColor: TSGColor4f;
	const LinesColor: TSGColor4f;
	const WithLines:boolean = False;
	const WithQuad:boolean = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	ArVertex : TSGVertex3fList = nil;
begin
ArVertex := SGRectangleWithRoundedCornersConstruct(Vertex1,Vertex3,Radius,Interval);
SGRectangleWithRoundedCornersDraw(VRender,ArVertex,Interval,QuadColor,LinesColor,WithLines,WithQuad);
SetLength(ArVertex,0);
end;

procedure SGRectangleWithRoundedCornersDraw(
	const VRender:ISGRender;
	const ArVertex:TSGVertex3fList;
	const Interval:LongInt;
	const QuadColor: TSGColor4f;
	const LinesColor: TSGColor4f;
	const WithLines:boolean = False;
	const WithQuad:boolean = True);
var
	I:LongInt;
begin
if WithQuad then
	begin
	VRender.Color(QuadColor);
	VRender.BeginScene(SGR_QUADS);
	for i:=0 to Interval-1 do
		begin
		VRender.Vertex(ArVertex[Interval-i]);
		VRender.Vertex(ArVertex[Interval+1+i]);
		VRender.Vertex(ArVertex[Interval+2+i]);
		VRender.Vertex(ArVertex[Interval-i-1]);
		end;
	VRender.Vertex(ArVertex[0]);
	VRender.Vertex(ArVertex[2*Interval+1]);
	VRender.Vertex(ArVertex[2*Interval+2]);
	VRender.Vertex(ArVertex[4*(Interval+1)-1]);
	for i:=0 to Interval-1 do
		begin
		VRender.Vertex(ArVertex[(Interval+1)*2+i]);
		VRender.Vertex(ArVertex[(Interval+1)*2+i+1]);
		VRender.Vertex(ArVertex[(Interval+1)*4-2-i]);
		VRender.Vertex(ArVertex[(Interval+1)*4-1-i]);
		end;
	VRender.EndScene();
	end;
if WithLines then
	begin
	VRender.Color(LinesColor);
	VRender.BeginScene(SGR_LINE_LOOP);
	for i:=Low(ArVertex) to High(ArVertex) do
		VRender.Vertex(ArVertex[i]);
	VRender.EndScene();
	end;
end;


function SGRectangleWithRoundedCornersConstruct(const Vertex1,Vertex3: TSGVertex3f; const Radius:real; const Interval:LongInt):TSGVertex3fList;
var
	Vertex2,Vertex4: TSGVertex3f;
	VertexR1,VertexR2,VertexR3,VertexR4: TSGVertex3f;
	I,ii:LongInt;
begin
Result:=nil;
Vertex2.Import(Vertex3.x,Vertex1.y,(Vertex1.z+Vertex3.z)/2);
Vertex4.Import(Vertex1.x,Vertex3.y,(Vertex1.z+Vertex3.z)/2);
VertexR1.Import(Vertex1.x+Radius,Vertex1.y-Radius,Vertex1.z);
VertexR2.Import(Vertex2.x-Radius,Vertex2.y-Radius,Vertex2.z);
VertexR3.Import(Vertex3.x-Radius,Vertex3.y+Radius,Vertex3.z);
VertexR4.Import(Vertex4.x+Radius,Vertex4.y+Radius,Vertex4.z);
SetLength(Result,Interval*4+4);
ii:=0;
For i:=0 to Interval do
	begin
	Result[ii].Import(VertexR2.x+cos((Pi/2)/(Interval)*i)*Radius,VertexR2.y+sin((Pi/2)/(Interval)*i+Pi)*Radius+2*Radius,VertexR2.z);
	ii+=1;
	end;
For i:=0 to Interval do
	begin
	Result[ii].Import(VertexR1.x+cos((Pi/2)*i/(Interval)+Pi/2)*Radius,VertexR1.y+sin((Pi/2)*i/(Interval)+3*Pi/2)*Radius+2*Radius,VertexR1.z);
	ii+=1;
	end;
For i:=0 to Interval do
	begin
	Result[ii].Import(VertexR4.x+cos((Pi/2)*i/Interval+Pi)*Radius,VertexR4.y+sin((Pi/2)*i/(Interval))*Radius-2*Radius,VertexR4.z);
	ii+=1;
	end;
For i:=0 to Interval do
	begin
	Result[ii].Import(VertexR3.x+cos((Pi/2)*i/(Interval)+3*Pi/2)*Radius,VertexR3.y+sin((Pi/2)*i/(Interval)+Pi/2)*Radius-2*Radius,VertexR3.z);
	ii+=1;
	end;
end;

end.
