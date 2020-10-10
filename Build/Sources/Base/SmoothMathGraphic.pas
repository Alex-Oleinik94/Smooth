{$INCLUDE Smooth.inc}

unit SmoothMathGraphic;

interface

uses
	 Classes
	
	,SmoothBase
	,SmoothCommonStructs
	,SmoothContextClasses
	,SmoothComputableExpression
	;

type
	TSMathGraphicThread=class(TThread)
		constructor Create(const VClass:Pointer;const VBegin,VEnd:real;const VPosBegin,VPosEnd:LongWord);
		destructor Destroy;override;
		procedure Execute;override;
			private
		FEnd,FBegin:real;
		FClass:pointer;
		FPEnd,FPBegin:LongWord;
		end;
type
	TSVisibleVector = object(TSVector3f)
			public
		Visible : TSBoolean;
		end;
	TSVisibleVectorList = packed array of TSVisibleVector;
	TSVisibleVectorFunction = function (Vector : TSVisibleVector; const Void : TSPointer) : TSVisibleVector;
type
	TSMathGraphic=class(TSPaintableObject)
			public
		constructor Create();override;
		destructor Destroy;override;
		class function ClassName:string;override;
			protected
		FComplexity:LongInt;
		FExpression:TSExpression;
		FVertexLength:LongInt;
		FThread:TSMathGraphicThread;
		FVariable:PChar;
		FYShift:real;
		FArVertexes:TSVisibleVectorList;
		FVertexFunction:TSVisibleVectorFunction;
		FUseThread:boolean;
		FVertexFunctionPointer:Pointer;
		FAss:Boolean;
		FLastVBegin,FLastVEnd:Real;
		function GetExpression:PChar;
		procedure SetExpression(VPChar:PChar);
		procedure SetComplexity(VComplexity:LongInt);
		procedure SetArraysLength;
		function MathExists(const I:LongInt):Boolean;
		procedure RealConstruct(const VBegin,VEnd:real;const VPosBegin,VPosEnd:LongWord);
			public
		procedure Construct(const VBegin,VEnd:real);
		procedure Paint();override;
		procedure ChangeConstruct(const VBegin,VEnd:real);
			public
		property VertexFunctionPointer:Pointer read FVertexFunctionPointer write FVertexFunctionPointer;
		property Expression:PChar read GetExpression write SetExpression;
		property Complexity:LongInt read FComplexity write SetComplexity;
		property YShift:Real read FYShift write FYShift;
		property VertexFunction:TSVisibleVectorFunction read FVertexFunction write FVertexFunction;
		property UseThread:boolean read FUseThread write FUseThread;
		function Assigned:Boolean;inline;
		end;

implementation

uses
	 SmoothRenderBase
	,SmoothStringUtils
	,SmoothArithmeticUtils
	;

constructor TSMathGraphicThread.Create(const VClass:Pointer;const VBegin,VEnd:real;const VPosBegin,VPosEnd:LongWord);
begin
FClass:=VClass;
FEnd:=VEnd;
FBegin:=VBegin;
FPBegin:=VPosBegin;
FPEnd:=VPosEnd;
inherited Create(False);
end;

destructor TSMathGraphicThread.Destroy;
begin
inherited;
end;

procedure TSMathGraphicThread.Execute;
begin
TSMathGraphic(FClass).RealConstruct(FBegin,FEnd,FPBegin,FPEnd);
end;

class function TSMathGraphic.ClassName:string;
begin
Result:='TSMathGraphic';
end;

function TSMathGraphic.Assigned:Boolean;inline;
begin
Result:=FAss;
end;

procedure TSMathGraphic.ChangeConstruct(const VBegin,VEnd:real);
begin
if FLastVBegin>VBegin then
	begin
	RealConstruct(VBegin,FLastVBegin,0,Trunc(FComplexity*Abs(FLastVBegin-VBegin)/Abs(VEnd-VBegin))+1);
	end
else
	begin
	//RealConstruct(VBegin,FLastVBegin,0,Trunc(FComplexity*Abs(FLastVBegin-VBegin)/Abs(VEnd-VBegin))+1);
	end;
FLastVBegin:=VBegin;
FLastVEnd:=VEnd;
end;

procedure TSMathGraphic.Construct(const VBegin,VEnd:real);
begin
if FUseThread then
	begin
	if FThread<>nil then
		FThread.Destroy;
	FThread:=TSMathGraphicThread.Create(Self,VBegin,VEnd,0,FComplexity-1);
	end
else
	RealConstruct(VBegin,VEnd,0,FComplexity-1);
end;

function TSMathGraphic.MathExists(const I:LongInt):Boolean;
begin
Result:=True;
if  (i>=3)
	and
	FArVertexes[i].Visible and FArVertexes[i-1].Visible and FArVertexes[i-2].Visible and FArVertexes[i-3].Visible
	and
	(
	(abs(FArVertexes[i-1].y-FArVertexes[i].y)+abs(FArVertexes[i-3].y-FArVertexes[i-2].y)<(abs(FArVertexes[i-2].y-FArVertexes[i-1].y)))
	)
		then
			begin
			FArVertexes[i-1].Visible:=False;
			end;
end;

procedure TSMathGraphic.Paint();
var
	I:LongInt;
	Quantity:LongInt = 0;
	LastVertex:LongInt = -1;
begin
for i:=0 to FComplexity-1 do
	begin
	if FArVertexes[i].Visible then
		begin
		if Quantity=0 then
			Render.BeginScene(SR_LINE_STRIP);
		Quantity+=1;
		Render.Vertex(FArVertexes[i]);
		LastVertex:=i;
		end
	else
		begin
		if Quantity>0 then
			begin
			if (Quantity=1) and (LastVertex>=0) and (LastVertex<FComplexity) then
				Render.Vertex(FArVertexes[LastVertex]);
			Render.EndScene();
			Quantity:=0;
			end;
		end;
	end;
if Quantity>0 then
	begin
	if (Quantity=1) and (LastVertex>=0) and (LastVertex<FComplexity) then
		Render.Vertex(FArVertexes[LastVertex]);
	Render.EndScene();
	Quantity:=0;
	end;
end;

procedure TSMathGraphic.RealConstruct(const VBegin,VEnd:real;const VPosBegin,VPosEnd:LongWord);
var
	Step:real;
	I:LongInt;
	Position:real;
begin
FAss:=True;
Step:=(VEnd-VBegin)/(VPosEnd-VPosBegin+1);
Position:=VBegin-Step;
//FVertexLength:=0;
for i:=VPosBegin to VPosEnd do
	begin
	Position+=Step;
	FExpression.BeginCalculate;
	if not SPCharsEqual(FVariable,'') then
		FExpression.ChangeVariables(FVariable,TSExpressionChunkCreateReal(Position));
	FExpression.Calculate;
	if (FExpression.Resultat.Quantity<>0) and (SFloatExists(FExpression.Resultat.FConst))  then
		begin
		FArVertexes[i].Visible:=True;
		FArVertexes[i].Import(Position,FExpression.Resultat.FConst+FYShift);
		if FVertexFunction<>nil then
			begin
			FArVertexes[i]:=FVertexFunction(FArVertexes[i],FVertexFunctionPointer);
			end;
		MathExists(i);
		end
	else
		begin
		FArVertexes[i].Visible:=False;
		end;
	//FVertexLength:=i+1;
	end;
if not ((VPosBegin=0) and (VPosEnd=FComplexity-1)) then
	begin
	FLastVBegin:=VPosBegin;
	FLastVEnd:=VPosEnd;
	end;
end;

procedure TSMathGraphic.SetComplexity(VComplexity:LongInt);
begin
FComplexity:=VComplexity;
SetArraysLength;
end;

procedure TSMathGraphic.SetArraysLength;
begin
SetLength(FArVertexes,FComplexity);
end;

function TSMathGraphic.GetExpression:PChar;
begin
if FExpression=nil then
	Result:=''
else
	Result:=FExpression.Expression;
end;

procedure TSMathGraphic.SetExpression(VPChar:PChar);
begin
if FExpression=nil then
	FExpression:=TSExpression.Create;
FExpression.Expression:=VPChar;
FExpression.QuickCalculation:=True;
FExpression.CanculateExpression;
FVariable:=FExpression.Variable;
end;

constructor TSMathGraphic.Create;
begin
inherited Create;
FArVertexes:=nil;
//FVertexLength:=0;
FThread:=nil;
FExpression:=nil;
FComplexity:=2000;
FYShift:=0;
SetArraysLength;
FVertexFunction:=nil;
FUseThread:=False;
FAss:=False;
FLastVBegin:=0;
FLastVEnd:=0;
end;

destructor TSMathGraphic.Destroy;
begin
FExpression.Destroy;
SetLength(FArVertexes,0);
if (FThread<>nil) then 
	FThread.Destroy;
inherited;
end;

end.
