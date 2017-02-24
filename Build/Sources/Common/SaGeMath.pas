{$INCLUDE SaGe.inc}

unit SaGeMath;

interface

uses 
	 Crt
	,Math
	,Classes
	
	,SaGeCommon
	,SaGeBase
	,SaGeRender
	,SaGeContext
	,SaGeClasses
	,SaGeCommonClasses
	,SaGeRenderConstants
	;

const
	SG_VARIABLE =                        $00001B;
	SG_CONST =                           $00001C;
	SG_OPERATOR =                        $00001D;
	SG_BOOLEAN =                         $00001E;
	SG_REAL =                            $00001F;
	SG_NUMERIC =                         $000020;
	SG_OBJECT =                          $000021;
	SG_NONE =                            $000022;
	SG_NOTHINK = SG_NONE;
	SG_FUNCTION =                        $000023;
	
	SG_ERROR =                           $000024;
	SG_WARNING =                         $000025;
	SG_NOTE =                            $000026;

type
	TSGMathFloat = TSGMaxFloat;
	
	TSGExpressionError=class
			public
		constructor Create(const VPChar:PChar;const VType:TSGByte = SG_ERROR);
		destructor Destroy;override;
			public
		FType:TSGByte;
		FPChar:PChar;
		end;
	TArTSGExpressionError = type packed array of TSGExpressionError;
	
	PTSGExpressionChunk = ^TSGExpressionChunk;
	TSGExpressionChunk=object
		constructor Create;
			public
		destructor Destroy;
			public
		FType:TSGByte;
		FConst:TSGMathFloat;
		FVariable:PChar;
		FQuantity:Longint;
		Next:PTSGExpressionChunk;
			public
		property Quantity:longint read FQuantity write FQuantity;
		procedure WriteConsole();
		procedure WriteLnConsole();
		procedure Test();
		end;
	TArTSGExpressionChunk = type packed array of TSGExpressionChunk;
	SGExpressionChunk = TSGExpressionChunk;
	SGExpressionResult = TSGExpressionChunk;
	TSGExpressionResult = SGExpressionResult;
	TArTArTSGExpressionChunk = type packed array of TArTSGExpressionChunk;
	
	TSGExpressionFunc0f = function :TSGExpressionChunk;
	TSGExpressionFunc1f = function (Chunk:TSGExpressionChunk):TSGExpressionChunk;
	TSGExpressionFuncf = TSGExpressionFunc1f;
	TSGExpressionFunc1 = TSGExpressionFunc1f;
	TSGExpressionFunc = TSGExpressionFunc1f;
	TSGExpressionFunc2f = function (Chunk1:TSGExpressionChunk;Chunk2:TSGExpressionChunk):TSGExpressionChunk;
	TSGExpressionFunc2 = TSGExpressionFunc2f;
	TSGExpressionFunc3f = function (Chunk1,Chunk2,Chunk3:TSGExpressionChunk):TSGExpressionChunk;
	TSGExpressionFunc3 = TSGExpressionFunc3f;
	
	TSGExpressionObject = class(TSGObject)
			public
		constructor Create(
			const That:TSGByte = SG_OPERATOR;
			const NewName:PChar = '';
			const NewParametrs:LongWord = 0;  
			const NewFunction:Pointer = nil;
			const NewPrioritete:LongWord = 0;
			const NewMove:Boolean = True);
		destructor Destroy;override;
			public
		FType:TSGByte;
		FName:PChar;
		FParametrs:LongWord;
		FFunction:Pointer;
		FPrioritete:LongInt;
		FMoveEqualPrioritete:Boolean;
		end;
	TArTSGExpressionObject = type packed array of TSGExpressionObject;
	
	TSGExpressionFuncChunck=object
		
		end;
	
	TSGCalculateAlgoritmChunk=object
			public
		constructor Create;
			public
		FFunction:LongWord;
		FParametrs:packed array of LongWord;
		end;
	TSGCalculateAlgoritm=packed array of TSGCalculateAlgoritmChunk;
	
	PTSGExpression = ^TSGExpression;
	PSGExpression = PTSGExpression;
	TSGExpression=class(TSGObject)
			public
		constructor Create;
		destructor Destroy;override;
			public
		FExpression:PChar;
		FResultat:TArTArTSGExpressionChunk;
		FCanculatedExpression:TArTSGExpressionChunk;
		FOperators:TArTSGExpressionObject;
		FNextMinPrioritete:LongWord;
		FDeBug:Boolean;
		FErrors:TArTSGExpressionError;
		
		FCalculateForGraph:Boolean;
		FCalculateAlgoritm:TSGCalculateAlgoritm;
		function GetResultFunction(const ArEC:TArTSGExpressionChunk;const VFunction:LongWord;const VParams:packed array of LongWord):TSGExpressionChunk;
		function IsOperator(var MayBeOperator:PChar):TSGByte;
		function IdentityChunk( var VPChar:PChar; var Chunk:TSGExpressionChunk;const State:TSGByte;const VWasObject:Boolean):Boolean;
		procedure CanculateSteak(var OperatorsSteak:TArTSGExpressionChunk;const Chunk:TSGExpressionChunk );
		procedure AddExpressionChunk(const Chunk:TSGExpressionChunk);
		procedure DebugSteak(const Steak:TArTSGExpressionChunk;const Color:byte = 10;VChar:Char = '-');
		function GetVariables:TSGPCharList;
		procedure AddError(const VPChar:PChar = 'Error';const VType:TSGByte = SG_ERROR);
		function GetType(const VType:TSGByte ):PChar;
		function FindObject(const Chunk:TSGExpressionChunk; const VType:TSGByte):Boolean;
		function GetVariable:PChar;
			public
		function GetObjectPrioritete(const Chunk:TSGExpressionChunk):LongInt;
		function GetObjectMoveEqual(const Chunk:TSGExpressionChunk;const VType:TSGByte = SG_OBJECT):Boolean;
		function GetObjectParatemetrs(const VPChar:PChar;const VType:TSGByte = SG_OBJECT):LongInt;
		procedure NewObject(const VOperator:TSGExpressionObject);
		procedure CanculateExpression;
		procedure BeginCalculate;
		procedure Calculate;
		procedure CalculateOld;
		procedure CalculateNew;
		procedure CanculateNextMinPrioritete;
		procedure ChangeVariables(const VPChar:PChar;const Chunk:TSGExpressionChunk);
		procedure WriteErrors;
		procedure WriteAlgorithm;
		procedure ClearErrors;
		procedure CalculateExpressionForGraph;
			public
		function ResultatQuantity:LongInt;
		function Resultat(const Number:LongInt = 1):TSGExpressionChunk;
		property Expression:PChar read FExpression write FExpression;
		property DeBug:Boolean read FDeBug write FDeBug;
		property Variables:TSGPCharList read GetVariables;
		property Variable:PChar read GetVariable;
		function ErrorsQuantity:LongInt;
		function Errors(Index : LongInt):PChar;
		property QuickCalculation:Boolean read FCalculateForGraph write FCalculateForGraph;
		end;
	
	TSGMathGraphicThread=class(TThread)
		constructor Create(const VClass:Pointer;const VBegin,VEnd:real;const VPosBegin,VPosEnd:LongWord);
		destructor Destroy;override;
		procedure Execute;override;
			private
		FEnd,FBegin:real;
		FClass:pointer;
		FPEnd,FPBegin:LongWord;
		end;
	

	TSGMathGraphic=class(TSGDrawable)
			public
		constructor Create();override;
		destructor Destroy;override;
		class function ClassName:string;override;
			protected
		FComplexity:LongInt;
		FExpression:TSGExpression;
		FVertexLength:LongInt;
		FThread:TSGMathGraphicThread;
		FVariable:PChar;
		FYShift:real;
		FArVertexes:TArSGVisibleVertex;
		FVertexFunction:TSGVisibleVertexFunction;
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
		property VertexFunction:TSGVisibleVertexFunction read FVertexFunction write FVertexFunction;
		property UseThread:boolean read FUseThread write FUseThread;
		function Assigned:Boolean;inline;
		end;

function TSGExpressionChunkCreateBoolean(const VBoolean:Boolean):TSGExpressionChunk;
function TSGExpressionChunkCreateNumeric(const VNumeric:LongInt):TSGExpressionChunk;
function TSGExpressionChunkCreateReal(const VReal:Real):TSGExpressionChunk;
function TSGExpressionChunkCreateNone:TSGExpressionChunk;

{$DEFINE SGMATHREADINTERFACE}
{$INCLUDE SaGeMathOperators.inc}
{$UNDEF SGMATHREADINTERFACE}

type 
	TSGLineSystemFloat = TSGMathFloat;
	TSGLineSystem = class
			public
		constructor Create(const nn : LongWord);
		destructor Destroy();override;
		procedure CalculateGauss();
		procedure CalculateRotate();
		procedure View();
			public
		a : array of array of TSGLineSystemFloat;
		b : array of TSGLineSystemFloat;
		n : LongWord;
		x : array of TSGLineSystemFloat;
		end;

function SGCalculateExpression(const VExpression : TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStrMathFloat(const Value : TSGMathFloat; const SimbolsAfterPoint : TSGUInt8 = 3) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeStringUtils
	,SaGeMathUtils
	;

function SGStrMathFloat(const Value : TSGMathFloat; const SimbolsAfterPoint : TSGUInt8 = 3) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result :=
{$IFNDEF WITHOUT_EXTENDED}
	SGStrExtended
{$ELSE WITHOUT_EXTENDED}
	SGStrReal
{$ENDIF WITHOUT_EXTENDED}
		(Value, SimbolsAfterPoint);
end;

function SGCalculateExpression(const VExpression : TSGString):TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Ex : TSGExpression;
begin
Result := VExpression;
Ex := TSGExpression.Create();
Ex.Expression := SGStringToPChar(VExpression);
Ex.CanculateExpression();
if Ex.ErrorsQuantity=0 then
	begin
	Ex.BeginCalculate();
	Ex.Calculate();
	if Ex.ErrorsQuantity=0 then
		case Ex.Resultat.FType of
		SG_REAL : 
			begin
			if Abs(Ex.Resultat.FConst - Round(Ex.Resultat.FConst)) < SGZero then
				Result := SGStr(Round(Ex.Resultat.FConst))
			else
				Result := SGStrReal(Ex.Resultat.FConst, 7);
			end;
		SG_BOOLEAN : Result := SGStr(TSGBoolean(Trunc(Ex.Resultat.FConst)));
		SG_NUMERIC : Result := SGStr(Round(Ex.Resultat.FConst));
		end;
	end;
Ex.Destroy();
end;

procedure TSGLineSystem.View();
var
	i,ii : LongWord;
begin
for i:=0 to n-1 do
	begin
	for ii:=0 to n-1 do
		Write(a[i,ii]:0:4,' ');
	WriteLn('| ',b[i]:0:4);
	end;
end;

procedure TSGLineSystem.CalculateRotate();
var
	i, ii, iii : LongWord;
	C, S, r, ai, aii : TSGLineSystemFloat;
begin
for i:=0 to n-2 do
	for ii:=i+1 to n-1 do
		begin
		C := a[i,i]/sqrt(sqr(a[ii,i])+sqr(a[i,i]));
		S := a[ii,i] /sqrt(sqr(a[ii,i])+sqr(a[i,i]));
		for iii := i to n - 1 do
			begin
			ai  := a[ i,iii];
			aii := a[ii,iii];
			a[i,iii]  := C*ai+S*aii;
			a[ii,iii] := -S*ai+C*aii;
			end;
		ai := b[i];
		aii := b[ii];
		b[i] := C*ai+S*aii;
		b[ii]:= -S*ai+C*aii;
		end;
for i:=n-1 downto 0 do
	begin
	r:=b[i];
	for ii:=n-1 downto i do
		r-=x[ii]*a[i,ii];
	x[i]:=r/a[i,i];
	end;
end;

constructor TSGLineSystem.Create(const nn : LongWord);
var
	i : LongWord;
begin
n := nn;
SetLength(b,n);
SetLength(x,n);
SetLength(a,n);
for i:=0 to n-1 do
	SetLength(a[i],n);
end;

destructor TSGLineSystem.Destroy();
var
	i : TSGUInt32;
begin
SetLength(b,0);
SetLength(x,0);
for i:=0 to n-1 do
	SetLength(a[i],0);
SetLength(a,0);
inherited;
end;

procedure TSGLineSystem.CalculateGauss();
var
	r : TSGLineSystemFloat;
	i, ii,iii:LongWord;
begin
for i:=1 to n-1 do
	begin
	for ii:=i to n-1 do
		begin
		r := -a[ii,i-1]/a[i-1,i-1];
		for iii:=0 to n-1 do
			a[ii,iii]+=r*a[i-1,iii];
		b[ii]+=r*b[i-1];
		end;
	end;
for i:=n-1 downto 0 do
	begin
	r:=b[i];
	for ii:=n-1 downto i do
		begin
		r-=x[ii]*a[i,ii];
		end;
	x[i]:=r/a[i,i];
	end;
end;

{$DEFINE SGMATHREADIMPLEMENTATION}
{$INCLUDE SaGeMathOperators.inc}
{$UNDEF SGMATHREADIMPLEMENTATION}

constructor TSGMathGraphicThread.Create(const VClass:Pointer;const VBegin,VEnd:real;const VPosBegin,VPosEnd:LongWord);
begin
FClass:=VClass;
FEnd:=VEnd;
FBegin:=VBegin;
FPBegin:=VPosBegin;
FPEnd:=VPosEnd;
inherited Create(False);
end;

destructor TSGMathGraphicThread.Destroy;
begin
inherited;
end;

procedure TSGMathGraphicThread.Execute;
begin
TSGMathGraphic(FClass).RealConstruct(FBegin,FEnd,FPBegin,FPEnd);
end;

class function TSGMathGraphic.ClassName:string;
begin
Result:='TSGMathGraphic';
end;

function TSGMathGraphic.Assigned:Boolean;inline;
begin
Result:=FAss;
end;

procedure TSGMathGraphic.ChangeConstruct(const VBegin,VEnd:real);
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

procedure TSGMathGraphic.Construct(const VBegin,VEnd:real);
begin
if FUseThread then
	begin
	if FThread<>nil then
		FThread.Destroy;
	FThread:=TSGMathGraphicThread.Create(Self,VBegin,VEnd,0,FComplexity-1);
	end
else
	RealConstruct(VBegin,VEnd,0,FComplexity-1);
end;

function TSGExpressionChunkCreateNone:TSGExpressionChunk;
begin
Result.Create;
Result.Quantity:=0;
end;

function TSGMathGraphic.MathExists(const I:LongInt):Boolean;
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

procedure TSGMathGraphic.Paint();
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
			Render.BeginScene(SGR_LINE_STRIP);
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

procedure TSGMathGraphic.RealConstruct(const VBegin,VEnd:real;const VPosBegin,VPosEnd:LongWord);
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
	if not SGPCharsEqual(FVariable,'') then
		FExpression.ChangeVariables(FVariable,TSGExpressionChunkCreateReal(Position));
	FExpression.Calculate;
	if (FExpression.Resultat.Quantity<>0) and (SGFloatExists(FExpression.Resultat.FConst))  then
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

procedure TSGMathGraphic.SetComplexity(VComplexity:LongInt);
begin
FComplexity:=VComplexity;
SetArraysLength;
end;

procedure TSGMathGraphic.SetArraysLength;
begin
SetLength(FArVertexes,FComplexity);
end;

function TSGMathGraphic.GetExpression:PChar;
begin
if FExpression=nil then
	Result:=''
else
	Result:=FExpression.Expression;
end;

procedure TSGMathGraphic.SetExpression(VPChar:PChar);
begin
if FExpression=nil then
	FExpression:=TSGExpression.Create;
FExpression.Expression:=VPChar;
FExpression.QuickCalculation:=True;
FExpression.CanculateExpression;
FVariable:=FExpression.Variable;
end;

constructor TSGMathGraphic.Create;
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

destructor TSGMathGraphic.Destroy;
begin
FExpression.Destroy;
SetLength(FArVertexes,0);
if (FThread<>nil) then 
	FThread.Destroy;
inherited;
end;

(*
==============================
====*){$NOTE Expression}(*====
==============================
*)

constructor TSGCalculateAlgoritmChunk.Create;
begin
FFunction:=0;
FParametrs:=nil;
end;

procedure TSGExpression.CalculateExpressionForGraph;
var
	CE:TArTSGExpressionChunk;
	i:LongWord;
	ii:LongInt;
function NexFunction:LongInt;
var
	i:LongWord;
begin
Result:=-1;
for i:=0 to High(CE) do
	begin
	if (CE[i].FType = SG_OPERATOR) or (CE[i].FType = SG_FUNCTION) then
		begin
		Result:=i;
		Break;
		end;
	end;
end;

function NexParam(const a:LongWord):LongInt;
var
	i:LongInt;
begin
i:=a;
while a<>-1 do
	begin
	if (CE[i].FType in [SG_BOOLEAN,SG_NUMERIC,SG_REAL]) then
		begin
		Result:=i;
		Break;
		end;
	i-=1;
	end;
end;

begin
//DebugSteak(FCanculatedExpression);
if not FCalculateForGraph then
	Exit;
SetLength(FCalculateAlgoritm,0);
SetLength(CE,Length(FCanculatedExpression));
for i:=0 to High(FCanculatedExpression) do
	begin
	CE[i]:=FCanculatedExpression[i];
	if CE[i].FType=SG_VARIABLE then
		begin
		CE[i].FType:=SG_NUMERIC;
		CE[i].FConst:=0;
		end;
	end;
repeat
ii:=NexFunction;
if ii<>-1 then
	begin
	SetLength(FCalculateAlgoritm,Length(FCalculateAlgoritm)+1);
	for i:=0 to High(FOperators) do
		if (FOperators[i].FFunction<>nil) and (FOperators[i].FType=CE[ii].FType) and 
			(SGPCharsEqual(FOperators[i].FName,CE[ii].FVariable)) then 
				begin
				FCalculateAlgoritm[High(FCalculateAlgoritm)].FFunction:=i;
				Break;
				end;
	SetLength(FCalculateAlgoritm[High(FCalculateAlgoritm)].FParametrs,
		FOperators[FCalculateAlgoritm[High(FCalculateAlgoritm)].FFunction].FParametrs+1);
	FCalculateAlgoritm[High(FCalculateAlgoritm)].FParametrs[0]:=ii;
	for i:=1 to High(FCalculateAlgoritm[High(FCalculateAlgoritm)].FParametrs) do
		begin
		FCalculateAlgoritm[High(FCalculateAlgoritm)].FParametrs[i]:=
			NexParam(FCalculateAlgoritm[High(FCalculateAlgoritm)].FParametrs[i-1]-1);
		end;
	CE[ii]:=GetResultFunction(CE,FCalculateAlgoritm[High(FCalculateAlgoritm)].FFunction,
	FCalculateAlgoritm[High(FCalculateAlgoritm)].FParametrs);
	for i:=1 to High(FCalculateAlgoritm[High(FCalculateAlgoritm)].FParametrs) do
		CE[FCalculateAlgoritm[High(FCalculateAlgoritm)].FParametrs[i]].FType:=0;
	{DebugSteak(CE);
	WriteAlgorithm;
	ReadLn;}
	end;
until ii=-1;
SetLength(CE,0);
SetLength(FResultat,1);
SetLength(FResultat[0],Length(FCanculatedExpression));
for I:=0 to High(FResultat[0]) do
	FResultat[0][i]:=FCanculatedExpression[i];
end;

function TSGExpression.GetResultFunction(const ArEC:TArTSGExpressionChunk;const VFunction:LongWord;const VParams:packed array of LongWord):TSGExpressionChunk;
begin
case FOperators[VFunction].FParametrs of
0:
	Result:=TSGExpressionFunc0f(FOperators[VFunction].FFunction)();
1:
	Result:=TSGExpressionFunc1f(FOperators[VFunction].FFunction)(ArEC[VParams[1]]);
2:
	Result:=TSGExpressionFunc2f(FOperators[VFunction].FFunction)(ArEC[VParams[2]],ArEC[VParams[1]]);
3:
	Result:=TSGExpressionFunc3f(FOperators[VFunction].FFunction)(ArEC[VParams[3]],ArEC[VParams[2]],ArEC[VParams[1]]);
else
	Result:=TSGExpressionChunkCreateNone;
end;
end;

procedure TSGExpression.WriteAlgorithm;
var
	i,ii:LongWord;
begin
for i:=0 to  High(FCalculateAlgoritm) do
	begin
	Write(i:2,'->','''',FCalculateAlgoritm[i].FFunction,''',[',FCalculateAlgoritm[i].FParametrs[0],']');
	for ii:=1 to High(FCalculateAlgoritm[i].FParametrs) do
		Write(',',FCalculateAlgoritm[i].FParametrs[ii]);
	WriteLn;
	end;
end;

procedure TSGExpression.ClearErrors;
begin
SetLength(FErrors,0);
end;

function TSGExpression.GetVariable:PChar;
var
	ArPChar:TSGPCharList = nil;
begin
ArPChar:=Variables;
if Length(ArPChar)>0 then
	Result:=ArPChar[0]
else
	Result:='';
SetLength(ArPChar,0);
end;

procedure TSGExpressionChunk.Test();
begin
case FType of
SG_REAL:
	begin
	if abs(trunc(FConst)-FConst)<SGZero then
		FType:=SG_NUMERIC;
	end;
end;
end;

procedure TSGExpression.CalculateNew;
var
	i:LongWord;
begin
if (FCalculateAlgoritm<>nil) and (Length(FCalculateAlgoritm)<>0) then
for i:=0 to High(FCalculateAlgoritm) do
	begin
	FResultat[0][FCalculateAlgoritm[i].FParametrs[0]]:=GetResultFunction(FResultat[0],
		FCalculateAlgoritm[i].FFunction,FCalculateAlgoritm[i].FParametrs);
	end
else
	AddError('Quick algorithm is not assigneed for calculate!');
//DebugSteak(FResultat[0]);
end;

procedure TSGExpression.Calculate;
begin
if FCalculateForGraph then
	CalculateNew
else
	CalculateOld;
end;

procedure TSGExpression.CalculateOld;
label
	ExpressionError;
var
	Position:LongInt = 0;
	Number:LongInt = 0;
	I:LongInt = 0;
	II:LongInt = 0;
	FunctionResult:TSGExpressionChunk;
	FResult2:TArTSGExpressionChunk = nil;
begin
FunctionResult:=TSGExpressionChunkCreateNone;
if FResultat=nil then
	BeginCalculate;
while (Length(FResultat[Number])>1) or ((Length(FResultat[Number])=1) and (FResultat[Number][0].FType in [SG_FUNCTION,SG_OPERATOR])) do
	begin
	while 
		((Position>=Low(FResultat[Number]))) and
		(Position<=High(FResultat[Number])) and
		(not (FResultat[Number][Position].FType in [SG_OBJECT,SG_OPERATOR,SG_FUNCTION])) do
			Position+=1;
	if (Position>=Low(FResultat[Number]))and(Position<=High(FResultat[Number])) then
		begin
		case FResultat[Number][Position].FType of
		SG_OPERATOR:
			begin
			if Position<2 then
				goto ExpressionError;
			For i:=0 to High(FOperators) do
				if SGPCharsEqual(FOperators[i].FName,FResultat[Number][Position].FVariable) and 
					(FOperators[i].FFunction<>nil)and 
					(FOperators[i].FType=SG_OPERATOR)then
					begin
					FunctionResult:=TSGExpressionFunc2f(FOperators[i].FFunction)(FResultat[Number][Position-2],FResultat[Number][Position-1]);
					if FunctionResult.Quantity<>0 then
						Break;
					end;
			if FunctionResult.Quantity<>0 then
				begin
				FunctionResult.Test;
				SetLength(FResult2,Length(FResultat[Number])-2);
				for i:=0 to Position-3 do
					FResult2[i]:=FResultat[Number][i];
				FResult2[Position-2]:=FunctionResult;
				for i:=Position-1 to High(FResultat[Number])-2 do
					FResult2[i]:=FResultat[Number][i+2];
				FResultat[Number]:=FResult2;
				FResult2:=nil;
				Position-=2;
				FunctionResult:=TSGExpressionChunkCreateNone;
				end
			else
				begin 
				AddError(
					SGPCharTotal('Can not find operator ',
						SGPCharTotal(SGPCharTotal('"',SGPCharTotal(FResultat[Number][Position].FVariable,'"')),
							SGPCharTotal(' ( ',
								SGPCharTotal(GetType(FResultat[Number][Position-2].FType),
									SGPCharTotal(' , ',
										SGPCharTotal(GetType(FResultat[Number][Position-1].FType),' ).')
											)
										)
									)
								)
							)
						);
				FResultat[Number]:=nil;
				end;
			end;
		SG_FUNCTION:
			begin
			For i:=0 to High(FOperators) do
				if SGPCharsEqual(FOperators[i].FName,FResultat[Number][Position].FVariable) and 
					(FOperators[i].FFunction<>nil)and 
					(FOperators[i].FType=SG_FUNCTION)then
					begin
					case FOperators[i].FParametrs of
					0:
						FunctionResult:=TSGExpressionFunc0f(FOperators[i].FFunction)();
					1:
						if Position>0 then
							FunctionResult:=TSGExpressionFunc1f(FOperators[i].FFunction)(FResultat[Number][Position-1]);
					2:
						if Position>1 then
							FunctionResult:=TSGExpressionFunc2f(FOperators[i].FFunction)(FResultat[Number][Position-2],FResultat[Number][Position-1]);
					3:
						if Position>2 then 
							FunctionResult:=TSGExpressionFunc3f(FOperators[i].FFunction)(FResultat[Number][Position-3],FResultat[Number][Position-2],FResultat[Number][Position-1]);
					end;
					if FunctionResult.Quantity<>0 then
						Break;
					end;
			if FunctionResult.Quantity<>0 then
				begin
				FunctionResult.Test;
				II:=FOperators[i].FParametrs;
				
				SetLength(FResult2,Length(FResultat[Number])-II);
				for i:=0 to Position-II-1 do
					FResult2[i]:=FResultat[Number][i];
				
				FResult2[Position-II]:=FunctionResult;
				
				for i:=Position-II+1 to High(FResultat[Number])-II do
					FResult2[i]:=FResultat[Number][i+II];
				FResultat[Number]:=FResult2;
				FResult2:=nil;
				Position-=II;
				FunctionResult:=TSGExpressionChunkCreateNone;
				end
			else
				begin 
				AddError(SGPCharTotal('Can not find function ',SGPCharTotal('"',SGPCharTotal(FResultat[Number][Position].FVariable,'".'))));
				FResultat[Number]:=nil;
				end;
			end;
		end;
		end
	else
		begin
		ExpressionError:
		AddError('Expression incorrectly composed!');
		FResultat[Number]:=nil;
		end;
	end;
end;

function TSGExpression.GetObjectMoveEqual(const Chunk:TSGExpressionChunk;const VType:TSGByte = SG_OBJECT):Boolean;
var
	I:LongInt;
begin
Result:=False;
for i:=0 to High(FOperators) do
	if (((VType in [SG_OPERATOR,SG_OBJECT]) and (FOperators[i].FType=SG_OPERATOR)) or 
			((VType in [SG_FUNCTION,SG_OBJECT]) and (FOperators[i].FType=SG_FUNCTION)))
			and SGPCharsEqual(FOperators[i].FName,Chunk.FVariable) then
		begin
		Result:=FOperators[i].FMoveEqualPrioritete;
		Break;
		end;
end;

function TSGExpressionChunkCreateNumeric(const VNumeric:LongInt):TSGExpressionChunk;
begin
with Result do
	begin
	Create;
	FType:=SG_NUMERIC;
	FConst:=VNumeric;
	Quantity:=1;
	end;
end;

function TSGExpressionChunkCreateReal(const VReal:Real):TSGExpressionChunk;
begin
with Result do
	begin
	Create;
	FType:=SG_REAL;
	FConst:=VReal;
	Quantity:=1;
	end;
end;

function TSGExpression.FindObject(const Chunk:TSGExpressionChunk; const VType:TSGByte):Boolean;
var
	I:LongInt;
begin
Result:=False;
for i:=0 to High(FOperators) do
	if (FOperators[i].FType=VType) and SGPCharsEqual(Chunk.FVariable,FOperators[i].FName) then
		begin
		Result:=True;
		Break;
		end;
end;

constructor TSGExpressionError.Create(const VPChar:PChar;const VType:TSGByte = SG_ERROR);
begin
inherited Create;
FPChar:=VPChar;
FType:=VType;
end;

destructor TSGExpressionError.Destroy;
begin
inherited;
end;

function TSGExpression.ErrorsQuantity:LongInt;
begin
Result:=Length(FErrors);
end;

function TSGExpression.Errors(Index : LongInt):PChar;
begin
if Index-1 in [Low(FErrors)..High(FErrors)] then
	Result:=FErrors[Index-1].FPChar
else
	Result:='';
end;

procedure TSGExpression.WriteErrors;
var
	i:LongInt = 0;
begin
for i:=0 to High(FErrors) do
	begin
	case FErrors[i].FType of
	SG_ERROR:
		textcolor(12);
	SG_WARNING:
		textcolor(14);
	SG_NOTE:
		textcolor(6);
	end;
	Writeln(FErrors[i].FPChar);
	end;
textcolor(white);
end;

function TSGExpression.GetType(const VType:TSGByte ):PChar;
begin
case VType of
0:
	Result:='Is not assigned!';
SG_OBJECT:
	Result:='OBJECT';
SG_REAL:
	Result:='REAL';
SG_OPERATOR:
	Result:='OPERATOR';
SG_BOOLEAN:
	Result:='BOOLEAN';
SG_NUMERIC:
	Result:='NUMERIC';
SG_VARIABLE:
	Result:='VARIABLE';
SG_FUNCTION:
	Result:='FUNCTION';
else
	Result:='';
END;
end;

procedure TSGExpression.AddError(const VPChar:PChar = 'Error';const VType:TSGByte = SG_ERROR);
begin
SetLength(FErrors,Length(FErrors)+1);
FErrors[High(FErrors)]:=TSGExpressionError.Create(VPChar,VType);;
end;

function TSGExpression.ResultatQuantity:LongInt;
begin
if not FCalculateForGraph then
	Result:=Length(FResultat)
else
	Result:=1;
end;

function TSGExpression.Resultat(const Number:LongInt = 1):TSGExpressionChunk;
begin
if FCalculateForGraph then
	Result:=FResultat[0][High(FResultat[0])]
else
	if (Number-1>=Low(FResultat)) and (Number-1 <=High(FResultat)) and (Length(FResultat[Number-1])=1) then
		Result:=FResultat[Number-1][0]
	else
		begin
		Result:=TSGExpressionChunkCreateNone;
		end;
end;

function TSGExpressionChunkCreateBoolean(const VBoolean:Boolean):TSGExpressionChunk;
begin
with Result do
	begin
	Create;
	FType:=SG_BOOLEAN;
	FConst:=byte(VBoolean);
	Quantity:=1;
	end;
end;

function TSGExpression.GetVariables:TSGPCharList;
var
	I:LongInt = 0;
	II:LongInt = 0;
	Find:Boolean = False;
begin
Result:=nil;
for i:=0 to High(FCanculatedExpression) do
	if FCanculatedExpression[i].FType=SG_VARIABLE then
		begin
		Find:=False;
		for ii:=0 to High(Result) do
			if SGPCharsEqual(Result[ii],FCanculatedExpression[i].FVariable)then
				begin
				Find:=True;
				Break;
				end;
		if Not Find then
			begin
			SetLength(Result,Length(Result)+1);
			Result[High(Result)]:=FCanculatedExpression[i].FVariable;
			end;
		end;
end;

procedure TSGExpression.ChangeVariables(const VPChar:PChar;const Chunk:TSGExpressionChunk);
var
	i:LongInt;
	ii:LongInt;
begin
if not FCalculateForGraph then
	begin
	for ii:=0 to High(FResultat) do
		for i:=0 to High(FResultat[ii]) do
			if (FResultat[ii][i].FType=SG_VARIABLE) and (SGPCharsEqual(FResultat[ii][i].FVariable,VPChar)) then
				FResultat[ii][i]:=Chunk;
	end
else
	begin
	if Length(FCanculatedExpression)=Length(FResultat[0]) then
	for i:=0 to High(FCanculatedExpression) do
		begin
		if (FCanculatedExpression[i].FType=SG_VARIABLE) and (SGPCharsEqual(FCanculatedExpression[i].FVariable,VPChar)) then
			begin
			FResultat[0][i]:=Chunk;
			end;
		end;
	end;
end;

procedure TSGExpressionChunk.WriteLnConsole();
begin
WriteConsole();
writeln();
end;

procedure TSGExpressionChunk.WriteConsole();
begin
textcolor(10);
case FType of
SG_BOOLEAN:
	begin
	if boolean(trunc(FConst)) then
		TextColor(10)
	else
		TextColor(12);
	write(boolean(trunc(FConst)));
	end;
SG_NUMERIC:
	write(trunc(FConst));
SG_REAL:
	write(
	{$IFNDEF WITHOUT_EXTENDED}
		SGStrExtended(FConst, 16)
	{$ELSE}
		SGStrReal(FConst, 10)
	{$ENDIF}
		);
SG_OPERATOR, SG_OBJECT, SG_FUNCTION, SG_VARIABLE:
	write(FVariable);
end;
textcolor(White);
write(' ');
end;

procedure TSGExpression.BeginCalculate;
var
	I:LongInt = 0;
begin
if not FCalculateForGraph then
	begin
	SetLength(FResultat,1);
	SetLength(FResultat[0],Length(FCanculatedExpression));
	for I:=0 to High(FResultat[0]) do
		FResultat[0][i]:=FCanculatedExpression[i];
	SetLength(FErrors,0);
	end;
end;

procedure TSGExpression.DebugSteak(const Steak:TArTSGExpressionChunk;const Color:byte = 10;VChar:Char = '-');
var
	I:LongInt = 0;
begin
textcolor(Color);
for i:=1 to 3 do 
	write(VChar);
write('> Begin DeBug <');
for i:=1 to 3 do 
	write(VChar);
writeln;
for i:=0 to High(Steak) do
	begin
	Steak[i].WriteConsole;
	write(' - ');
	write(GetType(Steak[i].FType));
	writeln;
	end;
textcolor(Color);
for i:=1 to 3 do 
	write(VChar);
write('> End DeBug <');
for i:=1 to 3 do 
	write(VChar);
textcolor(white);
writeln;
end;

function TSGExpression.GetObjectParatemetrs(const VPChar:PChar;const VType:TSGByte = SG_OBJECT):LongInt;
var
	I:LongInt = 0;
begin
case VType of
SG_OBJECT,SG_OPERATOR,SG_FUNCTION:
	begin
	for i:=0 to High(FOperators) do
		if ((VType in [SG_OPERATOR,SG_OBJECT]) and (FOperators[i].FType=SG_OPERATOR)) or 
				((VType in [SG_FUNCTION,SG_OBJECT]) and (FOperators[i].FType=SG_FUNCTION)) and
				SGPCharsEqual(VPChar,FOperators[i].FName) then
			begin
			Result:=FOperators[i].FParametrs;
			Break;
			end;
	end;
else
	Result:=0;
end;
end;

procedure TSGExpression.AddExpressionChunk(const Chunk:TSGExpressionChunk);
begin
if Chunk.Quantity<>0 then
	begin
	SetLength(FCanculatedExpression,Length(FCanculatedExpression)+1);
	FCanculatedExpression[High(FCanculatedExpression)]:=Chunk;
	end;
end;

function TSGExpression.GetObjectPrioritete(const Chunk:TSGExpressionChunk):LongInt;
var
	I:LongInt = 0;
begin
Result:=0;
if SGPCharsEqual(Chunk.FVariable,')') then
	Result:=0
else
	if SGPCharsEqual(Chunk.FVariable,'(') then
		Result:=1
	else
		begin
		for i:=0 to High(FOperators) do
			if (((Chunk.FType in [SG_OPERATOR,SG_OBJECT]) and (FOperators[i].FType=SG_OPERATOR)) or 
				((Chunk.FType in [SG_FUNCTION,SG_OBJECT]) and (FOperators[i].FType=SG_FUNCTION))) and
				SGPCharsEqual(FOperators[i].FName,Chunk.FVariable) then
				begin
				Result:=FOperators[i].FPrioritete;
				Exit;
				end;
		{Error}
		end;
end;

function TSGExpression.IdentityChunk( var VPChar:PChar; var Chunk:TSGExpressionChunk;const State:TSGByte;const VWasObject:Boolean):Boolean;
var
	Points:LongWord = 0;
	PointPosition:LongInt = -1;
	Not0_9AndPoint:Boolean = False;
	I:LongWord = 0;
begin
Result:=False;
if (VPChar=nil) or (VPChar[0]=#0) then
	Exit;
Chunk:=TSGExpressionChunkCreateNone;
if (State=1) or VWasObject or (SGPCharsEqual(VPChar,')') or SGPCharsEqual(VPChar,'('))then
	begin
	Chunk .Create; Chunk.Quantity:=1;
	Chunk.FType:=SG_OBJECT;
	Chunk.FVariable:=VPChar;
	VPChar:=nil;
	Result:=True;
	end
else
	begin
	while VPChar[I]<>#0 do
		begin
		if (not (VPChar[I] in ['0'..'9',',','.'])) then
			Not0_9AndPoint:=True;
		if (VPChar[I] in ['.',',']) then
			begin
			Points+=1;
			PointPosition:=I;
			end;
		I+=1;
		end;
	if Not0_9AndPoint then
		begin
		if SGPCharsEqual('FALSE',SGPCharUpCase(VPChar)) then
			begin
			Chunk .Create; Chunk.Quantity:=1;
			Chunk.FType:=SG_BOOLEAN;
			Chunk.FConst:=0;
			Result:=True;
			end
		else
			if SGPCharsEqual('TRUE',SGPCharUpCase(VPChar)) then
				begin
				Chunk .Create; Chunk.Quantity:=1;
				Chunk.FType:=SG_BOOLEAN;
				Chunk.FConst:=1;
				Result:=True;
				end
			else
				begin
				Chunk .Create; Chunk.Quantity:=1;
				Chunk.FType:=SG_VARIABLE;
				Chunk.FVariable:=VPChar;
				Result:=True;
				end;
		end
	else
		begin
		If Points=0 then
			begin
			Chunk .Create; Chunk.Quantity:=1;
			Chunk.FType:=SG_NUMERIC;
			Chunk.FConst:=Trunc(SGVal(SGPCharToString(VPChar)));
			Result:=True;
			end
		else
			begin
			if Points=1 then
				begin
				if (PointPosition=0) or (PointPosition=I-1) then
					begin
					end
				else
					begin
					Chunk .Create; Chunk.Quantity:=1; Chunk.Quantity:=1;
					Chunk.FType:=SG_REAL;
					val(SGPCharToString(VPChar),Chunk.FConst);
					Result:=True;
					end;
				end
			else
				begin
				end;
			end;
		end;
	end;
end;

procedure TSGExpression.CanculateNextMinPrioritete;
var
	I,II:LongInt;
begin
if (FOperators=nil) or (Length(FOperators)=0) then
	FNextMinPrioritete:=2
else
	begin
	II:=1;
	for I:=0 to High(FOperators) do
		if FOperators[i].FPrioritete>II then
			II:=FOperators[i].FPrioritete;
	FNextMinPrioritete:=II+1;
	end;
end;

constructor TSGExpressionObject.Create(
	const That:TSGByte = SG_OPERATOR;
	const NewName:PChar = '';
	const NewParametrs:LongWord = 0;  
	const NewFunction:Pointer = nil;
	const NewPrioritete:LongWord = 0;
	const NewMove:Boolean = True);
begin
inherited Create;
FName:=NewName;
FParametrs:=NewParametrs;
FFunction:=NewFunction;
FPrioritete:=NewPrioritete;
FType:=That;
FMoveEqualPrioritete:=NewMove;
end;

procedure TSGExpression.NewObject(const VOperator:TSGExpressionObject);
begin
SetLength(FOperators,Length(FOperators)+1);
FOperators[High(FOperators)]:=VOperator;
end;

destructor TSGExpressionObject.Destroy;
begin
inherited;
end;

function TSGExpression.IsOperator(var MayBeOperator:PChar):TSGByte;
(*
0 - Not operator
1 - Is operator
2 - Don`t now
3>= - On the end of string was operator
	IDOperator = Result - 3
*)
var
	I:LongInt = 0;
	II:LongInt = 0;
	VOperator:PChar = '';
	MayBeSome:Boolean = True;
begin
Result:=0;
if (SGPCharsEqual(MayBeOperator,')')) or SGPCharsEqual(MayBeOperator,'(') then
	Result:=1
else
	if MayBeOperator[SGPCharHigh(MayBeOperator)] in [')','('] then
		Result:=3;
for I:=0 to High(FOperators) do
	begin
	VOperator:=FOperators[i].FName;
	if not (SGPCharLength(MayBeOperator)>SGPCharLength(VOperator)) then
		begin
		if (SGPCharLength(MayBeOperator)=SGPCharLength(VOperator)) then
			begin
			if SGPCharsEqual(MayBeOperator,VOperator)  then
				Result:=1;
			end
		else
			begin
			MayBeSome:=True;
			for II:=0 To SGPCharHigh(MayBeOperator) do
				begin
				if VOperator[ii]<>MayBeOperator[ii] then
					MayBeSome:=False;
				if not MayBeSome then
					break;
				end;
			if MayBeSome and (Result<>1) then
				Result:=2;
			end;
		end
	else
		begin
		if (FOperators[I].FType=SG_OPERATOR) then
			begin
			MayBeSome:=True;
			for II:=SGPCharHigh(MayBeOperator)-SGPCharHigh(VOperator) To SGPCharHigh(MayBeOperator) do
				begin
				if VOperator[ii+SGPCharHigh(VOperator)-SGPCharHigh(MayBeOperator)]<>MayBeOperator[ii] then
					MayBeSome:=False;
				if not MayBeSome then
					break;
				end;
			if MayBeSome and (Result<>2) and (Result<>1) then
				Result:=4+i;
			end;
		end;
	end;
end;

procedure TSGExpression.CanculateExpression;
var
	Position:LongWord =0;
	OperatorsSteak:TArTSGExpressionChunk;
	NewChunk:TSGExpressionChunk;
	OldChunk:TSGExpressionChunk;
	NewChunkString:PChar = '';
	ChunkState:TSGByte = 0;
	I:LongInt = 0;
	IfStringWasObj:packed record
		Was:Boolean;
		Length:LongWord;
		ToExit:Boolean;
		end;
function ProvSk() : TSGBoolean;
var
	Ar:packed array of char;
begin
Result:=True;
i:=0;
SetLength(Ar,0);
while FExpression[i]<>#0 do
	begin
	case FExpression[i] of
	'(':
		begin
		SetLength(Ar,Length(Ar)+1);
		Ar[High(Ar)]:='(';
		end;
	')':
		begin
		if Length(Ar)=0 then
			begin
			Result:=False;
			Break;
			end;
		if Ar[High(Ar)]='(' then
			SetLength(Ar,Length(Ar)-1)
		else
			begin
			Result:=False;
			Break;
			end;
		end;
	end;
	i+=1;
	end;
if Length(Ar)>0 then
	Result:=False;
SetLength(Ar,0);
end;

begin
FExpression:=SGPCharDeleteSpaces(FExpression);
if not ProvSk then
	begin
	AddError('Неправильно расставлены скобки');
	Exit;
	end;
NewChunk:=TSGExpressionChunkCreateNone;
OldChunk:=TSGExpressionChunkCreateNone;
OperatorsSteak:=nil;
FCanculatedExpression:=nil;
while FExpression[Position]<>#0 do
	begin
	NewChunkString:='';
	IfStringWasObj.Was:=False;
	IfStringWasObj.Length:=0;
	IfStringWasObj.ToExit:=False;
	repeat
	SGPCharAddSimbol(NewChunkString,FExpression[Position]);
	Position+=1;
	ChunkState:=IsOperator(NewChunkString);
	if IfStringWasObj.Was and ((ChunkState=0)or(ChunkState>=3)) then
		begin
		I:=SGPCharLength(NewChunkString)-IfStringWasObj.Length;
		Position-=I;
		SGPCharDecFromEnd(NewChunkString,I);
		ChunkState:=1;
		IfStringWasObj.ToExit:=True;
		end;
	if (ChunkState=1) and (not IfStringWasObj.ToExit) then
		begin
		IfStringWasObj.Was:=True;
		IfStringWasObj.Length:=SGPCharLength(NewChunkString);
		ChunkState:=2;
		end;
	if ChunkState>=3 then
		begin
		if ChunkState=3 then
			begin
			Position-=1;
			SGPCharDecFromEnd(NewChunkString);
			end
		else
			begin
			I:=SGPCharLength(FOperators[ChunkState-4].FName);
			SGPCharDecFromEnd(NewChunkString,I);
			Position-=I;
			end;
		end;
	until (FExpression[Position]=#0) or (ChunkState=1) or (ChunkState>=3);
	//write(NewChunkString,' ');
	if SGPCharLength(NewChunkString)>0 then
		begin
		NewChunk:=TSGExpressionChunkCreateNone;
		IdentityChunk(NewChunkString,NewChunk,ChunkState,IfStringWasObj.Was and (IfStringWasObj.Length=SGPCharLength(NewChunkString)));
		if NewChunk.Quantity<>0 then
			begin
			case NewChunk.FType of
			SG_BOOLEAN,SG_NUMERIC,SG_REAL,SG_VARIABLE:
				(* If that is a data *)(* If that is variable *)
				begin
				AddExpressionChunk(NewChunk);
				end;
			SG_OBJECT,SG_OPERATOR,SG_FUNCTION:
				(* If that is operator or function *)
				begin
				SetLength(OperatorsSteak,Length(OperatorsSteak)+1);
				if not(SGPCharsEqual(NewChunk.FVariable,')') and (SGPCharsEqual(NewChunk.FVariable,'('))) then
					begin
					if (OldChunk.Quantity<>0)and
						(
							(OldChunk.FType in [SG_BOOLEAN,SG_NUMERIC,SG_REAL,SG_VARIABLE]) or 
							(SGPCharsEqual(OldChunk.FVariable,')'))
						) then
						begin
						if FindObject(NewChunk,SG_OPERATOR) then
							NewChunk.FType:=SG_OPERATOR
						else
							if FindObject(NewChunk,SG_FUNCTION) then
								NewChunk.FType:=SG_FUNCTION;
						end
					else
						begin
						if FindObject(NewChunk,SG_FUNCTION) then
							NewChunk.FType:=SG_FUNCTION
						else
							if FindObject(NewChunk,SG_OPERATOR) then
								NewChunk.FType:=SG_OPERATOR;
						end;
					end;
				OperatorsSteak[High(OperatorsSteak)]:=NewChunk;
				CanculateSteak(OperatorsSteak,NewChunk);
				end;
			end;
			OldChunk:=NewChunk;
			end;
		end;
	end;
CanculateSteak(OperatorsSteak,TSGExpressionChunkCreateNone);
if DeBug then
	DebugSteak(FCanculatedExpression);
if FCalculateForGraph then
	CalculateExpressionForGraph;
end;

procedure TSGExpression.CanculateSteak(var OperatorsSteak:TArTSGExpressionChunk;const Chunk:TSGExpressionChunk);
var
	I:LongInt = 0;
	II:LongInt = 0;
	HighOperator:TSGExpressionChunk;

procedure AboutSkobki;
begin
if SGPCharsEqual(OperatorsSteak[High(OperatorsSteak)].FVariable,')') and SGPCharsEqual(OperatorsSteak[High(OperatorsSteak)-1].FVariable,'(') then
	SetLength(OperatorsSteak,Length(OperatorsSteak)-2);
end;

begin
HighOperator:=TSGExpressionChunkCreateNone;
if Chunk.Quantity=0 then
	begin
	for i:=High(OperatorsSteak) DOWNto 0  do
			AddExpressionChunk(OperatorsSteak[i]);
	SetLength(OperatorsSteak,0);
	end
else
	begin
	if Length(OperatorsSteak)>1 then
		begin
		if
			((GetObjectPrioritete(OperatorsSteak[High(OperatorsSteak)-1])>GetObjectPrioritete(OperatorsSteak[High(OperatorsSteak)]))
			or
				((GetObjectPrioritete(OperatorsSteak[High(OperatorsSteak)-1])=GetObjectPrioritete(OperatorsSteak[High(OperatorsSteak)]))
				and GetObjectMoveEqual(Chunk,Chunk.FType)))
				AND (not SGPCharsEqual(OperatorsSteak[High(OperatorsSteak)].FVariable,'(') )  then
			begin
			II:=0;
			I:=High(OperatorsSteak)-1;
			while 
				(I>=0) and 
				(not SGPCharsEqual(OperatorsSteak[I].FVariable,'(')) and 
				(GetObjectPrioritete(OperatorsSteak[I])>=GetObjectPrioritete(OperatorsSteak[High(OperatorsSteak)])) do
				begin
				II+=1;
				I-=1;
				end;
			for I:=High(OperatorsSteak)-1 downto High(OperatorsSteak)-II do
					AddExpressionChunk(OperatorsSteak[i]);
			HighOperator:=OperatorsSteak[High(OperatorsSteak)];
			SetLength(OperatorsSteak,Length(OperatorsSteak)-II);
			OperatorsSteak[High(OperatorsSteak)]:=HighOperator;
			AboutSkobki;
			end;
		end;
	end;
end;

constructor TSGExpressionChunk.Create;
begin
inherited;
FConst:=0;
FVariable:='';
end;

destructor TSGExpressionChunk.Destroy;
begin
if FVariable<>nil then
	FreeMem(FVariable);
inherited;
end;

constructor TSGExpression.Create;
begin
inherited;
FCalculateAlgoritm:=nil;
FExpression:='';
FCanculatedExpression:=nil;
FNextMinPrioritete:=2;
FOperators:=nil;
FResultat:=nil;
FDeBug:=False;
FErrors:=nil;
FCalculateForGraph:=False;

NewObject(TSGExpressionObject.Create(SG_OPERATOR,'or',2,@OperatorOr,2));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'или',2,@OperatorOr,2));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'-',2,@OperatorMinus,2));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'+',2,@OperatorPlus,2));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'*',2,@OperatorUmnozhit,3));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'/',2,@OperatorDelenie,3));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,':',2,@OperatorDelenie,3));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'&',2,@OperatorAnd,3));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'&&',2,@OperatorAnd,3));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'and',2,@OperatorAnd,3));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'и',2,@OperatorAnd,3));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'=',2,@OperatorEqual,2));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'==',2,@OperatorEqual,2));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'!=',2,@OperatorNotEqual,2));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'<>',2,@OperatorNotEqual,2));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'><',2,@OperatorNotEqual,2));

NewObject(TSGExpressionObject.Create(SG_OPERATOR,'**',2,@OperatorStepen,4,False));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'^',2,@OperatorStepen,4,False));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'imp',2,@OperatorImp,4,False));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'->',2,@OperatorImp,4,False));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'-->',2,@OperatorImp,4,False));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'xor',2,@OperatorXor,4,False));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'sfr',2,@OperatorSfr,4,False));

NewObject(TSGExpressionObject.Create(SG_OPERATOR,'div',2,@OperatorDiv,4,False));
NewObject(TSGExpressionObject.Create(SG_OPERATOR,'mod',2,@OperatorMod,4,False));

NewObject(TSGExpressionObject.Create(SG_FUNCTION,'pi',0,@FunctionPi,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'пи',0,@FunctionPi,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'e',0,@FunctionExp0,5,False));

NewObject(TSGExpressionObject.Create(SG_FUNCTION,'-',1,@FunctionMinus,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'not',1,@FunctionNot,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'не',1,@FunctionNot,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'!',1,@FunctionNot,5,False));

NewObject(TSGExpressionObject.Create(SG_FUNCTION,'tg',1,@FunctionTg,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'ctg',1,@FunctionCtg,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'cos',1,@FunctionCos,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'sin',1,@FunctionSin,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'sign',1,@FunctionSign,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'тангенс',1,@FunctionTg,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'котангенс',1,@FunctionCtg,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'косинус',1,@FunctionCos,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'синус',1,@FunctionSin,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'тг',1,@FunctionTg,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'ктг',1,@FunctionCtg,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'кос',1,@FunctionCos,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'син',1,@FunctionSin,5,False));

NewObject(TSGExpressionObject.Create(SG_FUNCTION,'exp',1,@FunctionExp1,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'ln',1,@FunctionLn,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'lg',1,@FunctionLg,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'log',2,@FunctionLog,5,False));

NewObject(TSGExpressionObject.Create(SG_FUNCTION,'sqrt',1,@FunctionSqrt,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'sqr',1,@FunctionSqr,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'abs',1,@FunctionAbs,5,False));

NewObject(TSGExpressionObject.Create(SG_FUNCTION,'arctg',1,@FunctionArcTg,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'arctan',1,@FunctionArcTg,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'arcctg',1,@FunctionArcCtg,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'arccos',1,@FunctionArcCos,5,False));
NewObject(TSGExpressionObject.Create(SG_FUNCTION,'arcsin',1,@FunctionArcSin,5,False));

CanculateNextMinPrioritete;
end;

destructor TSGExpression.Destroy;
var
	i:LongWord;
begin
if FResultat<>nil then
	begin
	for i:=0 to High(FResultat) do
		SetLength(FResultat[i],0);
	SetLength(FResultat,0);
	end;
SetLength(FCanculatedExpression,0);
SetLength(FOperators,0);
SetLength(FErrors,0);
inherited;
end;


end.
