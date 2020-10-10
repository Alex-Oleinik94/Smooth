{$INCLUDE Smooth.inc}

unit SmoothComputableExpression;

interface

uses 

	SmoothBase
	,SmoothBaseClasses
	;

const
	S_VARIABLE =                        $00001B;
	S_CONST =                           $00001C;
	S_OPERATOR =                        $00001D;
	S_BOOLEAN =                         $00001E;
	S_REAL =                            $00001F;
	S_NUMERIC =                         $000020;
	S_OBJECT =                          $000021;
	S_NONE =                            $000022;
	S_NOTHINK = S_NONE;
	S_FUNCTION =                        $000023;
	
	S_ERROR =                           $000024;
	S_WARNING =                         $000025;
	S_NOTE =                            $000026;

type
	TSMathFloat = TSMaxFloat;
	
	TSExpressionError=class
			public
		constructor Create(const VPChar:PChar;const VType:TSByte = S_ERROR);
		destructor Destroy;override;
			public
		FType:TSByte;
		FPChar:PChar;
		end;
	TArTSExpressionError = type packed array of TSExpressionError;
	
	PTSExpressionChunk = ^TSExpressionChunk;
	TSExpressionChunk=object
		constructor Create;
			public
		destructor Destroy;
			public
		FType:TSByte;
		FConst:TSMathFloat;
		FVariable:PChar;
		FQuantity:Longint;
		Next:PTSExpressionChunk;
			public
		property Quantity:longint read FQuantity write FQuantity;
		procedure WriteConsole();
		procedure WriteLnConsole();
		procedure Test();
		end;
	TArTSExpressionChunk = type packed array of TSExpressionChunk;
	SExpressionChunk = TSExpressionChunk;
	SExpressionResult = TSExpressionChunk;
	TSExpressionResult = SExpressionResult;
	TArTArTSExpressionChunk = type packed array of TArTSExpressionChunk;
	
	TSExpressionFunc0f = function :TSExpressionChunk;
	TSExpressionFunc1f = function (Chunk:TSExpressionChunk):TSExpressionChunk;
	TSExpressionFuncf = TSExpressionFunc1f;
	TSExpressionFunc1 = TSExpressionFunc1f;
	TSExpressionFunc = TSExpressionFunc1f;
	TSExpressionFunc2f = function (Chunk1:TSExpressionChunk;Chunk2:TSExpressionChunk):TSExpressionChunk;
	TSExpressionFunc2 = TSExpressionFunc2f;
	TSExpressionFunc3f = function (Chunk1,Chunk2,Chunk3:TSExpressionChunk):TSExpressionChunk;
	TSExpressionFunc3 = TSExpressionFunc3f;
	
	TSExpressionObject = class(TSObject)
			public
		constructor Create(
			const That:TSByte = S_OPERATOR;
			const NewName:PChar = '';
			const NewParametrs:LongWord = 0;  
			const NewFunction:Pointer = nil;
			const NewPrioritete:LongWord = 0;
			const NewMove:Boolean = True);
		destructor Destroy;override;
			public
		FType:TSByte;
		FName:PChar;
		FParametrs:LongWord;
		FFunction:Pointer;
		FPrioritete:LongInt;
		FMoveEqualPrioritete:Boolean;
		end;
	TArTSExpressionObject = type packed array of TSExpressionObject;
	
	TSExpressionFuncChunck=object
		
		end;
	
	TSCalculateAlgoritmChunk=object
			public
		constructor Create();
			public
		FFunction : TSLongWord;
		FParametrs : packed array of TSLongWord;
		end;
	TSCalculateAlgoritm = packed array of TSCalculateAlgoritmChunk;
	
	PTSExpression = ^TSExpression;
	PSExpression = PTSExpression;
	TSExpression=class(TSObject)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		FExpression:PChar;
		FResultat:TArTArTSExpressionChunk;
		FCanculatedExpression:TArTSExpressionChunk;
		FOperators:TArTSExpressionObject;
		FNextMinPrioritete:LongWord;
		FDeBug:Boolean;
		FErrors:TArTSExpressionError;
		
		FCalculateForGraph:Boolean;
		FCalculateAlgoritm:TSCalculateAlgoritm;
		function GetResultFunction(const ArEC:TArTSExpressionChunk;const VFunction:LongWord;const VParams:packed array of LongWord):TSExpressionChunk;
		function IsOperator(var MayBeOperator:PChar):TSByte;
		function IdentityChunk( var VPChar:PChar; var Chunk:TSExpressionChunk;const State:TSByte;const VWasObject:Boolean):Boolean;
		procedure CanculateSteak(var OperatorsSteak:TArTSExpressionChunk;const Chunk:TSExpressionChunk );
		procedure AddExpressionChunk(const Chunk:TSExpressionChunk);
		procedure DebugSteak(const Steak:TArTSExpressionChunk;const Color:byte = 10;VChar:Char = '-');
		function GetVariables:TSPCharList;
		procedure AddError(const VPChar:PChar = 'Error';const VType:TSByte = S_ERROR);
		function GetType(const VType:TSByte ):PChar;
		function FindObject(const Chunk:TSExpressionChunk; const VType:TSByte):Boolean;
		function GetVariable:PChar;
			public
		function GetObjectPrioritete(const Chunk:TSExpressionChunk):LongInt;
		function GetObjectMoveEqual(const Chunk:TSExpressionChunk;const VType:TSByte = S_OBJECT):Boolean;
		function GetObjectParatemetrs(const VPChar:PChar;const VType:TSByte = S_OBJECT):LongInt;
		procedure NewObject(const VOperator:TSExpressionObject);
		procedure CanculateExpression;
		procedure BeginCalculate;
		procedure Calculate;
		procedure CalculateOld;
		procedure CalculateNew;
		procedure CanculateNextMinPrioritete;
		procedure ChangeVariables(const VPChar:PChar;const Chunk:TSExpressionChunk);
		procedure WriteErrors;
		procedure WriteAlgorithm;
		procedure ClearErrors;
		procedure CalculateExpressionForGraph;
			public
		function ResultatQuantity:LongInt;
		function Resultat(const Number:LongInt = 1):TSExpressionChunk;
		property Expression:PChar read FExpression write FExpression;
		property DeBug:Boolean read FDeBug write FDeBug;
		property Variables:TSPCharList read GetVariables;
		property Variable:PChar read GetVariable;
		function ErrorsQuantity:LongInt;
		function Errors(Index : LongInt):PChar;
		property QuickCalculation:Boolean read FCalculateForGraph write FCalculateForGraph;
		end;

function TSExpressionChunkCreateBoolean(const VBoolean:Boolean):TSExpressionChunk;
function TSExpressionChunkCreateNumeric(const VNumeric:LongInt):TSExpressionChunk;
function TSExpressionChunkCreateReal(const VReal:Real):TSExpressionChunk;
function TSExpressionChunkCreateNull:TSExpressionChunk;

function SCalculateExpression(const VExpression : TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SStrMathFloat(const Value : TSMathFloat; const SimbolsAfterPoint : TSUInt8 = 3) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

//operators
function OperatorAnd(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
function OperatorOr(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
function OperatorSfr(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
function OperatorUmnozhit(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
function OperatorPlus(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
function OperatorMinus(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
function OperatorDelenie(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
function OperatorEqual(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
function OperatorNotEqual(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
function OperatorMod(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
function OperatorDiv(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;

function OperatorStepen(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
function OperatorImp(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;

function FunctionNot(Chunk:TSExpressionChunk):TSExpressionChunk;
function FunctionCtg(Chunk:TSExpressionChunk):TSExpressionChunk;
function FunctionCos(Chunk:TSExpressionChunk):TSExpressionChunk;
function FunctionSin(Chunk:TSExpressionChunk):TSExpressionChunk;
function FunctionSign(Chunk:TSExpressionChunk):TSExpressionChunk;
function FunctionTg(Chunk:TSExpressionChunk):TSExpressionChunk;
function FunctionSqrt(Chunk:TSExpressionChunk):TSExpressionChunk;
function FunctionMinus(Chunk:TSExpressionChunk):TSExpressionChunk;
function FunctionSqr(Chunk:TSExpressionChunk):TSExpressionChunk;
function FunctionArcTg(Chunk:TSExpressionChunk):TSExpressionChunk;
function FunctionArcSin(Chunk:TSExpressionChunk):TSExpressionChunk;
function FunctionArcCos(Chunk:TSExpressionChunk):TSExpressionChunk;
function FunctionArcCtg(Chunk:TSExpressionChunk):TSExpressionChunk;
function FunctionAbs(Chunk:TSExpressionChunk):TSExpressionChunk;
function FunctionExp1(Chunk:TSExpressionChunk):TSExpressionChunk;
function FunctionLn(Chunk:TSExpressionChunk):TSExpressionChunk;
function FunctionLg(Chunk:TSExpressionChunk):TSExpressionChunk;

function FunctionPi:TSExpressionChunk;
function FunctionExp0:TSExpressionChunk;

function FunctionLog(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;

implementation

uses
	Crt //console runtime tools
	,Math
	
	,SmoothStringUtils
	,SmoothArithmeticUtils
	;

function SStrMathFloat(const Value : TSMathFloat; const SimbolsAfterPoint : TSUInt8 = 3) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result :=
{$IFNDEF WITHOUT_EXTENDED}
	SStrExtended
{$ELSE WITHOUT_EXTENDED}
	SStrReal
{$ENDIF WITHOUT_EXTENDED}
		(Value, SimbolsAfterPoint);
end;

function SCalculateExpression(const VExpression : TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Ex : TSExpression;
begin
Result := VExpression;
Ex := TSExpression.Create();
Ex.Expression := SStringToPChar(VExpression);
Ex.CanculateExpression();
if Ex.ErrorsQuantity=0 then
	begin
	Ex.BeginCalculate();
	Ex.Calculate();
	if Ex.ErrorsQuantity=0 then
		case Ex.Resultat.FType of
		S_REAL : 
			begin
			if Abs(Ex.Resultat.FConst - Round(Ex.Resultat.FConst)) < SZero then
				Result := SStr(Round(Ex.Resultat.FConst))
			else
				Result := SStrReal(Ex.Resultat.FConst, 7);
			end;
		S_BOOLEAN : Result := SStr(TSBoolean(Trunc(Ex.Resultat.FConst)));
		S_NUMERIC : Result := SStr(Round(Ex.Resultat.FConst));
		end;
	end;
Ex.Destroy();
end;

//operators

function FunctionSign(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
if Chunk.FConst>0 then
Result:=TSExpressionChunkCreateNumeric(1)
else
if Chunk.FConst<0 then
Result:=TSExpressionChunkCreateNumeric(-1)
else
Result:=TSExpressionChunkCreateNumeric(0);
end;

function FunctionLog(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
if  (Chunk1.FType in [S_NUMERIC,S_REAL]) and (Chunk2.FType in [S_NUMERIC,S_REAL]) then  
	begin
	Result:=TSExpressionChunkCreateReal(Log(Chunk1.FConst,Chunk2.FConst));
	end
else
	Result:=TSExpressionChunkCreateNull;
end;

function FunctionPi:TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateReal(Pi);
end;

function FunctionExp0:TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateReal(exp(1));
end;

function FunctionLn(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
case Chunk.FType of
S_NUMERIC,S_REAL:
	begin
	Result:=TSExpressionChunkCreateReal(Ln(Chunk.FConst));
	end;
else
	Result:=Chunk;
end;
end;

function FunctionLg(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
case Chunk.FType of
S_NUMERIC,S_REAL:
	begin
	Result:=TSExpressionChunkCreateReal(Log(10,Chunk.FConst));
	end;
else
	Result:=Chunk;
end;
end;

function FunctionExp1(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
case Chunk.FType of
S_NUMERIC,S_REAL:
	begin
	Result:=TSExpressionChunkCreateReal(Exp(Chunk.FConst));
	end;
else
	Result:=Chunk;
end;
end;

function OperatorXor(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
if (Chunk1.FType=S_BOOLEAN) and (Chunk2.FType=S_BOOLEAN) then
	begin
	Result.Create;  
	Result.Quantity:=1;
	Result.FType:=S_BOOLEAN;
	Result.FConst:= byte((boolean(trunc(Chunk1.FConst))) xor boolean(trunc(Chunk2.FConst)));
	end;
end;

function OperatorSfr(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
if (Chunk1.FType=S_BOOLEAN) and (Chunk2.FType=S_BOOLEAN) then
	begin
	Result.Create;  
	Result.Quantity:=1;
	Result.FType:=S_BOOLEAN;
	Result.FConst:= byte(not ((boolean(trunc(Chunk1.FConst))) and boolean(trunc(Chunk2.FConst))));
	end;

end;

function OperatorImp(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
if (Chunk1.FType=S_BOOLEAN) and (Chunk2.FType=S_BOOLEAN) then
	begin
	Result.Create;  
	Result.Quantity:=1;
	Result.FType:=S_BOOLEAN;
	Result.FConst:= byte((not boolean(trunc(Chunk1.FConst))) or boolean(trunc(Chunk2.FConst)));
	end;
end;

function FunctionAbs(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
case Chunk.FType of
S_NUMERIC,S_REAL:
	begin
	Result:=TSExpressionChunkCreateReal(abs(Chunk.FConst));
	end;
else
	Result:=Chunk;
end;
end;

function FunctionArcCtg(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
case Chunk.FType of
S_NUMERIC,S_REAL:
	begin
	Result:=TSExpressionChunkCreateReal(pi/2+arctan(-Chunk.FConst));
	end;
else
	Result:=TSExpressionChunkCreateNull;
end;
end;


function OperatorMod(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
if (Chunk1.FType=S_NUMERIC) and (Chunk2.FType=S_NUMERIC) then
	begin
	Result:=TSExpressionChunkCreateNumeric(trunc(Chunk1.FConst) mod trunc(Chunk2.FConst));
	end
else
	if(Chunk1.FType in [S_REAL,S_NUMERIC]) and (Chunk1.FType in [S_REAL,S_NUMERIC])then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=S_REAL;
		Result.FConst:=((Chunk1.FConst/Chunk2.FConst)-trunc(Chunk1.FConst/Chunk2.FConst))*Chunk2.FConst;
		end;
end;

function OperatorDiv(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
if (Chunk1.FType=S_NUMERIC) and (Chunk2.FType=S_NUMERIC) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=S_NUMERIC;
	Result.FConst:=trunc(Chunk1.FConst) div trunc(Chunk2.FConst);
	end
else
	if(Chunk1.FType in [S_REAL,S_NUMERIC]) and (Chunk1.FType in [S_REAL,S_NUMERIC])then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=S_REAL;
		Result.FConst:=trunc(Chunk1.FConst/Chunk2.FConst);
		end;
end;

function FunctionSqr(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
case Chunk.FType of
S_NUMERIC:
	begin
	Result:=TSExpressionChunkCreateReal(sqr(trunc(Chunk.FConst)));
	end;
S_REAL:
	begin
	Result:=TSExpressionChunkCreateReal(sqr(Chunk.FConst));
	end;
end;
end;

function FunctionMinus(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
case Chunk.FType of
S_NUMERIC:
	begin
	Result:=TSExpressionChunkCreateNumeric(-trunc(Chunk.FConst));
	end;
S_REAL:
	begin
	Result:=TSExpressionChunkCreateReal(-Chunk.FConst);
	end;
end;
end;

function FunctionSqrt(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
case Chunk.FType of
S_NUMERIC,S_REAL:
	begin
	Result:=TSExpressionChunkCreateReal(sqrt(Chunk.FConst));
	end;
end;
end;

function OperatorStepen(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
if (Chunk1.FType=S_NUMERIC) and (Chunk2.FType=S_NUMERIC) then
	begin
	Result.Create;
	Result.Quantity:=1;
	Result.FType:=S_NUMERIC;
	Result.FConst:=trunc(Chunk1.FConst)**trunc(Chunk2.FConst);
	end
else
	begin
	if(Chunk1.FType=S_BOOLEAN) and (Chunk2.FType=S_NUMERIC)then
		begin
		Result.Create;  
		Result.Quantity:=1;
		Result.FType:=S_BOOLEAN;
		Result.FConst:=Chunk1.FConst;
		end
	else
		if(Chunk1.FType in [S_REAL,S_NUMERIC]) and (Chunk2.FType in [S_NUMERIC]) then
			begin
			Result.Create;  Result.Quantity:=1;
			Result.FType:=S_REAL;
			Result.FConst:=Chunk1.FConst**Trunc(Chunk2.FConst);
			end
		else
			if(Chunk1.FType in [S_REAL,S_NUMERIC]) and (Chunk2.FType in [S_REAL,S_NUMERIC]) then
				begin
				Result.Create;  Result.Quantity:=1;
				Result.FType:=S_REAL;
				Result.FConst:=Chunk1.FConst**Chunk2.FConst;
				end;
	end;
end;


function FunctionNot(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
case Chunk.FType of
S_BOOLEAN:
	begin
	Result:=TSExpressionChunkCreateBoolean(not boolean(trunc(Chunk.FConst)));
	end;
S_NUMERIC:
	begin
	Result:=TSExpressionChunkCreateNumeric(not trunc(Chunk.FConst));
	end;
end;
end;

function FunctionTg(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
case Chunk.FType of
S_NUMERIC,S_REAL:
	begin
	Result:=TSExpressionChunkCreateReal(sin(Chunk.FConst)/cos(Chunk.FConst));
	end;
else
	Result:=TSExpressionChunkCreateNull;
end;
end;

function FunctionSin(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
case Chunk.FType of
S_NUMERIC,S_REAL:
	begin
	Result:=TSExpressionChunkCreateReal(sin(Chunk.FConst));
	end;
else
	Result:=TSExpressionChunkCreateNull;
end;
end;

function FunctionCos(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
case Chunk.FType of
S_NUMERIC,S_REAL:
	begin
	Result:=TSExpressionChunkCreateReal(cos(Chunk.FConst));
	end;
else
	Result:=TSExpressionChunkCreateNull;
end;
end;

function FunctionCtg(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
case Chunk.FType of
S_NUMERIC,S_REAL:
	begin
	try
	Result:=TSExpressionChunkCreateReal(cos(Chunk.FConst)/sin(Chunk.FConst));
	except
	Result:=TSExpressionChunkCreateNull;
	end;
	end;
else
	Result:=TSExpressionChunkCreateNull;
end;
end;

function FunctionArcTg(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
case Chunk.FType of
S_NUMERIC,S_REAL:
	begin
	try
	Result:=TSExpressionChunkCreateReal(arctan(Chunk.FConst));
	except
	Result:=TSExpressionChunkCreateNull;
	end;
	end;
else
	Result:=TSExpressionChunkCreateNull;
end;
end;

function FunctionArcSin(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
case Chunk.FType of
S_NUMERIC,S_REAL:
	begin
	try
	Result:=TSExpressionChunkCreateReal(arcsin(Chunk.FConst));
	except
	Result:=TSExpressionChunkCreateNull;
	end;
	end;
else
	Result:=TSExpressionChunkCreateNull;
end;
end;

function FunctionArcCos(Chunk:TSExpressionChunk):TSExpressionChunk;
begin
case Chunk.FType of
S_NUMERIC,S_REAL:
	begin
	try
	Result:=TSExpressionChunkCreateReal(arccos(Chunk.FConst));
	except
	Result:=TSExpressionChunkCreateNull;
	end;
	end;
else
	Result:=TSExpressionChunkCreateNull;
end;
end;

function OperatorAnd(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
if (Chunk1.FType=S_NUMERIC) and (Chunk2.FType=S_NUMERIC) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=S_NUMERIC;
	Result.FConst:=trunc(Chunk1.FConst) and trunc(Chunk2.FConst);
	end
else
	begin
	if(Chunk1.FType=S_BOOLEAN) and (Chunk2.FType=S_BOOLEAN)then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=S_BOOLEAN;
		Result.FConst:=Byte(Boolean(trunc(Chunk1.FConst)) and Boolean(trunc(Chunk2.FConst)));
		end;
	end;
end;

function OperatorOr(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
if (Chunk1.FType=S_NUMERIC) and (Chunk2.FType=S_NUMERIC) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=S_NUMERIC;
	Result.FConst:=trunc(Chunk1.FConst) or trunc(Chunk2.FConst);
	end
else
	begin
	if(Chunk1.FType=S_BOOLEAN) and (Chunk2.FType=S_BOOLEAN)then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=S_BOOLEAN;
		Result.FConst:=Byte(Boolean(trunc(Chunk1.FConst)) or Boolean(trunc(Chunk2.FConst)));
		end;
	end;
end;

function OperatorPlus(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
if (Chunk1.FType=S_NUMERIC) and (Chunk2.FType=S_NUMERIC) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=S_NUMERIC;
	Result.FConst:=trunc(Chunk1.FConst)+trunc(Chunk2.FConst);
	end
else
	begin
	if(Chunk1.FType=S_BOOLEAN) and (Chunk2.FType=S_BOOLEAN)then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=S_BOOLEAN;
		Result.FConst:=Byte(Boolean(trunc(Chunk1.FConst)) Xor Boolean(trunc(Chunk2.FConst)));
		end
	else
		if(Chunk1.FType in [S_REAL,S_NUMERIC]) and (Chunk2.FType in [S_REAL,S_NUMERIC])then
			begin
			Result.Create;  Result.Quantity:=1;
			Result.FType:=S_REAL;
			Result.FConst:=Chunk1.FConst+Chunk2.FConst;
			end;
	end;
end;

function OperatorMinus(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
if (Chunk1.FType=S_NUMERIC) and (Chunk2.FType=S_NUMERIC) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=S_NUMERIC;
	Result.FConst:=trunc(Chunk1.FConst)-trunc(Chunk2.FConst);
	end
else
	if(Chunk1.FType in [S_REAL,S_NUMERIC]) and (Chunk2.FType in [S_REAL,S_NUMERIC])then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=S_REAL;
		Result.FConst:=Chunk1.FConst-Chunk2.FConst;
		end;
end;

function OperatorNotEqual(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=OperatorEqual(Chunk1,Chunk2);
if Result.Quantity<>0 then
	Result.FConst:=byte(not boolean(trunc(Result.FConst)));
end;

function OperatorEqual(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
if (Chunk1.FType=S_NUMERIC) and (Chunk2.FType=S_NUMERIC) and (trunc(Chunk2.FConst)<>0) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=S_BOOLEAN;
	Result.FConst:=byte(trunc(Chunk1.FConst)=trunc(Chunk2.FConst));
	end
else
	begin
	if(Chunk1.FType=S_BOOLEAN) and (Chunk2.FType=S_BOOLEAN)then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=S_BOOLEAN;
		Result.FConst:=Byte(Boolean(trunc(Chunk1.FConst)) = ( Boolean(trunc(Chunk2.FConst))));
		end
	else
		if(Chunk1.FType in [S_REAL,S_NUMERIC]) and (Chunk2.FType in [S_REAL,S_NUMERIC])  and (Chunk2.FConst<>0)then
			begin
			Result.Create;  Result.Quantity:=1;
			Result.FType:=S_BOOLEAN;
			Result.FConst:=byte(Chunk1.FConst=Chunk2.FConst);
			end
		else
			if(Chunk1.FType=S_VARIABLE) and (Chunk2.FType=S_VARIABLE)then
				begin
				Result.Create;  Result.Quantity:=1;
				Result.FType:=S_BOOLEAN;
				Result.FConst:=byte(SPCharsEqual(Chunk1.FVariable,Chunk2.FVariable));
				end;
	end;
end;


function OperatorDelenie(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
if (Chunk1.FType=S_NUMERIC) and (Chunk2.FType=S_NUMERIC) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=S_REAL;
	Result.FConst:=trunc(Chunk1.FConst)/trunc(Chunk2.FConst);
	end
else
	if (Chunk1.FType in [S_REAL,S_NUMERIC]) and (Chunk2.FType in [S_REAL,S_NUMERIC])then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=S_REAL;
		Result.FConst:=Chunk1.FConst/Chunk2.FConst;
		end;
end;

function OperatorUmnozhit(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNull;
if (Chunk1.FType=S_NUMERIC) and (Chunk2.FType=S_NUMERIC) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=S_NUMERIC;
	Result.FConst:=trunc(Chunk1.FConst)*trunc(Chunk2.FConst);
	end
else
	begin
	if(Chunk1.FType=S_BOOLEAN) and (Chunk2.FType=S_BOOLEAN)then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=S_BOOLEAN;
		Result.FConst:=Byte(Boolean(trunc(Chunk1.FConst)) and Boolean(trunc(Chunk2.FConst)));
		end
	else
		if(Chunk1.FType in [S_REAL,S_NUMERIC]) and (Chunk2.FType in [S_REAL,S_NUMERIC])then
			begin
			Result.Create;  Result.Quantity:=1;
			Result.FType:=S_REAL;
			Result.FConst:=Chunk1.FConst*Chunk2.FConst;
			end;
	end;
end;

(*
==============================
====*){$NOTE Expression}(*====
==============================
*)

function TSExpressionChunkCreateNull:TSExpressionChunk;
begin
Result.Create;
Result.Quantity:=0;
end;

constructor TSCalculateAlgoritmChunk.Create;
begin
FFunction:=0;
FParametrs:=nil;
end;

procedure TSExpression.CalculateExpressionForGraph;
var
	CE:TArTSExpressionChunk;
	i:LongWord;
	ii:LongInt;
function NexFunction:LongInt;
var
	i:LongWord;
begin
Result:=-1;
for i:=0 to High(CE) do
	begin
	if (CE[i].FType = S_OPERATOR) or (CE[i].FType = S_FUNCTION) then
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
	if (CE[i].FType in [S_BOOLEAN,S_NUMERIC,S_REAL]) then
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
	if CE[i].FType=S_VARIABLE then
		begin
		CE[i].FType:=S_NUMERIC;
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
			(SPCharsEqual(FOperators[i].FName,CE[ii].FVariable)) then 
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

function TSExpression.GetResultFunction(const ArEC:TArTSExpressionChunk;const VFunction:LongWord;const VParams:packed array of LongWord):TSExpressionChunk;
begin
case FOperators[VFunction].FParametrs of
0:
	Result:=TSExpressionFunc0f(FOperators[VFunction].FFunction)();
1:
	Result:=TSExpressionFunc1f(FOperators[VFunction].FFunction)(ArEC[VParams[1]]);
2:
	Result:=TSExpressionFunc2f(FOperators[VFunction].FFunction)(ArEC[VParams[2]],ArEC[VParams[1]]);
3:
	Result:=TSExpressionFunc3f(FOperators[VFunction].FFunction)(ArEC[VParams[3]],ArEC[VParams[2]],ArEC[VParams[1]]);
else
	Result:=TSExpressionChunkCreateNull;
end;
end;

procedure TSExpression.WriteAlgorithm;
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

procedure TSExpression.ClearErrors;
begin
SetLength(FErrors,0);
end;

function TSExpression.GetVariable:PChar;
var
	ArPChar:TSPCharList = nil;
begin
ArPChar:=Variables;
if Length(ArPChar)>0 then
	Result:=ArPChar[0]
else
	Result:='';
SetLength(ArPChar,0);
end;

procedure TSExpressionChunk.Test();
begin
case FType of
S_REAL:
	begin
	if abs(trunc(FConst)-FConst)<SZero then
		FType:=S_NUMERIC;
	end;
end;
end;

procedure TSExpression.CalculateNew;
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

procedure TSExpression.Calculate;
begin
if FCalculateForGraph then
	CalculateNew
else
	CalculateOld;
end;

procedure TSExpression.CalculateOld;
label
	ExpressionError;
var
	Position:LongInt = 0;
	Number:LongInt = 0;
	I:LongInt = 0;
	II:LongInt = 0;
	FunctionResult:TSExpressionChunk;
	FResult2:TArTSExpressionChunk = nil;
begin
FunctionResult:=TSExpressionChunkCreateNull;
if FResultat=nil then
	BeginCalculate;
while (Length(FResultat[Number])>1) or ((Length(FResultat[Number])=1) and (FResultat[Number][0].FType in [S_FUNCTION,S_OPERATOR])) do
	begin
	while 
		((Position>=Low(FResultat[Number]))) and
		(Position<=High(FResultat[Number])) and
		(not (FResultat[Number][Position].FType in [S_OBJECT,S_OPERATOR,S_FUNCTION])) do
			Position+=1;
	if (Position>=Low(FResultat[Number]))and(Position<=High(FResultat[Number])) then
		begin
		case FResultat[Number][Position].FType of
		S_OPERATOR:
			begin
			if Position<2 then
				goto ExpressionError;
			For i:=0 to High(FOperators) do
				if SPCharsEqual(FOperators[i].FName,FResultat[Number][Position].FVariable) and 
					(FOperators[i].FFunction<>nil)and 
					(FOperators[i].FType=S_OPERATOR)then
					begin
					FunctionResult:=TSExpressionFunc2f(FOperators[i].FFunction)(FResultat[Number][Position-2],FResultat[Number][Position-1]);
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
				FunctionResult:=TSExpressionChunkCreateNull;
				end
			else
				begin 
				AddError(
					SPCharTotal('Can not find operator ',
						SPCharTotal(SPCharTotal('"',SPCharTotal(FResultat[Number][Position].FVariable,'"')),
							SPCharTotal(' ( ',
								SPCharTotal(GetType(FResultat[Number][Position-2].FType),
									SPCharTotal(' , ',
										SPCharTotal(GetType(FResultat[Number][Position-1].FType),' ).')
											)
										)
									)
								)
							)
						);
				FResultat[Number]:=nil;
				end;
			end;
		S_FUNCTION:
			begin
			For i:=0 to High(FOperators) do
				if SPCharsEqual(FOperators[i].FName,FResultat[Number][Position].FVariable) and 
					(FOperators[i].FFunction<>nil)and 
					(FOperators[i].FType=S_FUNCTION)then
					begin
					case FOperators[i].FParametrs of
					0:
						FunctionResult:=TSExpressionFunc0f(FOperators[i].FFunction)();
					1:
						if Position>0 then
							FunctionResult:=TSExpressionFunc1f(FOperators[i].FFunction)(FResultat[Number][Position-1]);
					2:
						if Position>1 then
							FunctionResult:=TSExpressionFunc2f(FOperators[i].FFunction)(FResultat[Number][Position-2],FResultat[Number][Position-1]);
					3:
						if Position>2 then 
							FunctionResult:=TSExpressionFunc3f(FOperators[i].FFunction)(FResultat[Number][Position-3],FResultat[Number][Position-2],FResultat[Number][Position-1]);
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
				FunctionResult:=TSExpressionChunkCreateNull;
				end
			else
				begin 
				AddError(SPCharTotal('Can not find function ',SPCharTotal('"',SPCharTotal(FResultat[Number][Position].FVariable,'".'))));
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

function TSExpression.GetObjectMoveEqual(const Chunk:TSExpressionChunk;const VType:TSByte = S_OBJECT):Boolean;
var
	I:LongInt;
begin
Result:=False;
for i:=0 to High(FOperators) do
	if (((VType in [S_OPERATOR,S_OBJECT]) and (FOperators[i].FType=S_OPERATOR)) or 
			((VType in [S_FUNCTION,S_OBJECT]) and (FOperators[i].FType=S_FUNCTION)))
			and SPCharsEqual(FOperators[i].FName,Chunk.FVariable) then
		begin
		Result:=FOperators[i].FMoveEqualPrioritete;
		Break;
		end;
end;

function TSExpressionChunkCreateNumeric(const VNumeric:LongInt):TSExpressionChunk;
begin
with Result do
	begin
	Create;
	FType:=S_NUMERIC;
	FConst:=VNumeric;
	Quantity:=1;
	end;
end;

function TSExpressionChunkCreateReal(const VReal:Real):TSExpressionChunk;
begin
with Result do
	begin
	Create;
	FType:=S_REAL;
	FConst:=VReal;
	Quantity:=1;
	end;
end;

function TSExpression.FindObject(const Chunk:TSExpressionChunk; const VType:TSByte):Boolean;
var
	I:LongInt;
begin
Result:=False;
for i:=0 to High(FOperators) do
	if (FOperators[i].FType=VType) and SPCharsEqual(Chunk.FVariable,FOperators[i].FName) then
		begin
		Result:=True;
		Break;
		end;
end;

constructor TSExpressionError.Create(const VPChar:PChar;const VType:TSByte = S_ERROR);
begin
inherited Create;
FPChar:=VPChar;
FType:=VType;
end;

destructor TSExpressionError.Destroy;
begin
inherited;
end;

function TSExpression.ErrorsQuantity:LongInt;
begin
Result:=Length(FErrors);
end;

function TSExpression.Errors(Index : LongInt):PChar;
begin
if Index-1 in [Low(FErrors)..High(FErrors)] then
	Result:=FErrors[Index-1].FPChar
else
	Result:='';
end;

procedure TSExpression.WriteErrors;
var
	i:LongInt = 0;
begin
for i:=0 to High(FErrors) do
	begin
	case FErrors[i].FType of
	S_ERROR:
		textcolor(12);
	S_WARNING:
		textcolor(14);
	S_NOTE:
		textcolor(6);
	end;
	Writeln(FErrors[i].FPChar);
	end;
textcolor(white);
end;

function TSExpression.GetType(const VType:TSByte ):PChar;
begin
case VType of
0:
	Result:='Is not assigned!';
S_OBJECT:
	Result:='OBJECT';
S_REAL:
	Result:='REAL';
S_OPERATOR:
	Result:='OPERATOR';
S_BOOLEAN:
	Result:='BOOLEAN';
S_NUMERIC:
	Result:='NUMERIC';
S_VARIABLE:
	Result:='VARIABLE';
S_FUNCTION:
	Result:='FUNCTION';
else
	Result:='';
END;
end;

procedure TSExpression.AddError(const VPChar:PChar = 'Error';const VType:TSByte = S_ERROR);
begin
SetLength(FErrors,Length(FErrors)+1);
FErrors[High(FErrors)]:=TSExpressionError.Create(VPChar,VType);;
end;

function TSExpression.ResultatQuantity:LongInt;
begin
if not FCalculateForGraph then
	Result:=Length(FResultat)
else
	Result:=1;
end;

function TSExpression.Resultat(const Number:LongInt = 1):TSExpressionChunk;
begin
if FCalculateForGraph then
	Result:=FResultat[0][High(FResultat[0])]
else
	if (Number-1>=Low(FResultat)) and (Number-1 <=High(FResultat)) and (Length(FResultat[Number-1])=1) then
		Result:=FResultat[Number-1][0]
	else
		begin
		Result:=TSExpressionChunkCreateNull;
		end;
end;

function TSExpressionChunkCreateBoolean(const VBoolean:Boolean):TSExpressionChunk;
begin
with Result do
	begin
	Create;
	FType:=S_BOOLEAN;
	FConst:=byte(VBoolean);
	Quantity:=1;
	end;
end;

function TSExpression.GetVariables:TSPCharList;
var
	I:LongInt = 0;
	II:LongInt = 0;
	Find:Boolean = False;
begin
Result:=nil;
for i:=0 to High(FCanculatedExpression) do
	if FCanculatedExpression[i].FType=S_VARIABLE then
		begin
		Find:=False;
		for ii:=0 to High(Result) do
			if SPCharsEqual(Result[ii],FCanculatedExpression[i].FVariable)then
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

procedure TSExpression.ChangeVariables(const VPChar:PChar;const Chunk:TSExpressionChunk);
var
	i:LongInt;
	ii:LongInt;
begin
if not FCalculateForGraph then
	begin
	for ii:=0 to High(FResultat) do
		for i:=0 to High(FResultat[ii]) do
			if (FResultat[ii][i].FType=S_VARIABLE) and (SPCharsEqual(FResultat[ii][i].FVariable,VPChar)) then
				FResultat[ii][i]:=Chunk;
	end
else
	begin
	if Length(FCanculatedExpression)=Length(FResultat[0]) then
	for i:=0 to High(FCanculatedExpression) do
		begin
		if (FCanculatedExpression[i].FType=S_VARIABLE) and (SPCharsEqual(FCanculatedExpression[i].FVariable,VPChar)) then
			begin
			FResultat[0][i]:=Chunk;
			end;
		end;
	end;
end;

procedure TSExpressionChunk.WriteLnConsole();
begin
WriteConsole();
writeln();
end;

procedure TSExpressionChunk.WriteConsole();
begin
textcolor(10);
case FType of
S_BOOLEAN:
	begin
	if boolean(trunc(FConst)) then
		TextColor(10)
	else
		TextColor(12);
	write(boolean(trunc(FConst)));
	end;
S_NUMERIC:
	write(trunc(FConst));
S_REAL:
	write(
	{$IFNDEF WITHOUT_EXTENDED}
		SStrExtended(FConst, 16)
	{$ELSE}
		SStrReal(FConst, 10)
	{$ENDIF}
		);
S_OPERATOR, S_OBJECT, S_FUNCTION, S_VARIABLE:
	write(FVariable);
end;
textcolor(White);
write(' ');
end;

procedure TSExpression.BeginCalculate;
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

procedure TSExpression.DebugSteak(const Steak:TArTSExpressionChunk;const Color:byte = 10;VChar:Char = '-');
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

function TSExpression.GetObjectParatemetrs(const VPChar:PChar;const VType:TSByte = S_OBJECT):LongInt;
var
	I:LongInt = 0;
begin
case VType of
S_OBJECT,S_OPERATOR,S_FUNCTION:
	begin
	for i:=0 to High(FOperators) do
		if ((VType in [S_OPERATOR,S_OBJECT]) and (FOperators[i].FType=S_OPERATOR)) or 
				((VType in [S_FUNCTION,S_OBJECT]) and (FOperators[i].FType=S_FUNCTION)) and
				SPCharsEqual(VPChar,FOperators[i].FName) then
			begin
			Result:=FOperators[i].FParametrs;
			Break;
			end;
	end;
else
	Result:=0;
end;
end;

procedure TSExpression.AddExpressionChunk(const Chunk:TSExpressionChunk);
begin
if Chunk.Quantity<>0 then
	begin
	SetLength(FCanculatedExpression,Length(FCanculatedExpression)+1);
	FCanculatedExpression[High(FCanculatedExpression)]:=Chunk;
	end;
end;

function TSExpression.GetObjectPrioritete(const Chunk:TSExpressionChunk):LongInt;
var
	I:LongInt = 0;
begin
Result:=0;
if SPCharsEqual(Chunk.FVariable,')') then
	Result:=0
else
	if SPCharsEqual(Chunk.FVariable,'(') then
		Result:=1
	else
		begin
		for i:=0 to High(FOperators) do
			if (((Chunk.FType in [S_OPERATOR,S_OBJECT]) and (FOperators[i].FType=S_OPERATOR)) or 
				((Chunk.FType in [S_FUNCTION,S_OBJECT]) and (FOperators[i].FType=S_FUNCTION))) and
				SPCharsEqual(FOperators[i].FName,Chunk.FVariable) then
				begin
				Result:=FOperators[i].FPrioritete;
				Exit;
				end;
		{Error}
		end;
end;

function TSExpression.IdentityChunk( var VPChar:PChar; var Chunk:TSExpressionChunk;const State:TSByte;const VWasObject:Boolean):Boolean;
var
	Points:LongWord = 0;
	PointPosition:LongInt = -1;
	Not0_9AndPoint:Boolean = False;
	I:LongWord = 0;
begin
Result:=False;
if (VPChar=nil) or (VPChar[0]=#0) then
	Exit;
Chunk:=TSExpressionChunkCreateNull;
if (State=1) or VWasObject or (SPCharsEqual(VPChar,')') or SPCharsEqual(VPChar,'('))then
	begin
	Chunk .Create; Chunk.Quantity:=1;
	Chunk.FType:=S_OBJECT;
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
		if SPCharsEqual('FALSE',SPCharUpCase(VPChar)) then
			begin
			Chunk .Create; Chunk.Quantity:=1;
			Chunk.FType:=S_BOOLEAN;
			Chunk.FConst:=0;
			Result:=True;
			end
		else
			if SPCharsEqual('TRUE',SPCharUpCase(VPChar)) then
				begin
				Chunk .Create; Chunk.Quantity:=1;
				Chunk.FType:=S_BOOLEAN;
				Chunk.FConst:=1;
				Result:=True;
				end
			else
				begin
				Chunk .Create; Chunk.Quantity:=1;
				Chunk.FType:=S_VARIABLE;
				Chunk.FVariable:=VPChar;
				Result:=True;
				end;
		end
	else
		begin
		If Points=0 then
			begin
			Chunk .Create; Chunk.Quantity:=1;
			Chunk.FType:=S_NUMERIC;
			Chunk.FConst:=Trunc(SValInt64(SPCharToString(VPChar)));
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
					Chunk.FType:=S_REAL;
					val(SPCharToString(VPChar),Chunk.FConst);
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

procedure TSExpression.CanculateNextMinPrioritete;
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

constructor TSExpressionObject.Create(
	const That:TSByte = S_OPERATOR;
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

procedure TSExpression.NewObject(const VOperator:TSExpressionObject);
begin
SetLength(FOperators,Length(FOperators)+1);
FOperators[High(FOperators)]:=VOperator;
end;

destructor TSExpressionObject.Destroy;
begin
inherited;
end;

function TSExpression.IsOperator(var MayBeOperator:PChar):TSByte;
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
if (SPCharsEqual(MayBeOperator,')')) or SPCharsEqual(MayBeOperator,'(') then
	Result:=1
else
	if MayBeOperator[SPCharHigh(MayBeOperator)] in [')','('] then
		Result:=3;
for I:=0 to High(FOperators) do
	begin
	VOperator:=FOperators[i].FName;
	if not (SPCharLength(MayBeOperator)>SPCharLength(VOperator)) then
		begin
		if (SPCharLength(MayBeOperator)=SPCharLength(VOperator)) then
			begin
			if SPCharsEqual(MayBeOperator,VOperator)  then
				Result:=1;
			end
		else
			begin
			MayBeSome:=True;
			for II:=0 To SPCharHigh(MayBeOperator) do
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
		if (FOperators[I].FType=S_OPERATOR) then
			begin
			MayBeSome:=True;
			for II:=SPCharHigh(MayBeOperator)-SPCharHigh(VOperator) To SPCharHigh(MayBeOperator) do
				begin
				if VOperator[ii+SPCharHigh(VOperator)-SPCharHigh(MayBeOperator)]<>MayBeOperator[ii] then
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

procedure TSExpression.CanculateExpression;
var
	Position:LongWord =0;
	OperatorsSteak:TArTSExpressionChunk;
	NewChunk:TSExpressionChunk;
	OldChunk:TSExpressionChunk;
	NewChunkString:PChar = '';
	ChunkState:TSByte = 0;
	I:LongInt = 0;
	IfStringWasObj:packed record
		Was:Boolean;
		Length:LongWord;
		ToExit:Boolean;
		end;
function ProvSk() : TSBoolean;
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
FExpression:=SPCharDeleteSpaces(FExpression);
if not ProvSk then
	begin
	AddError('Неправильно расставлены скобки');
	Exit;
	end;
NewChunk:=TSExpressionChunkCreateNull;
OldChunk:=TSExpressionChunkCreateNull;
OperatorsSteak:=nil;
FCanculatedExpression:=nil;
while FExpression[Position]<>#0 do
	begin
	NewChunkString:='';
	IfStringWasObj.Was:=False;
	IfStringWasObj.Length:=0;
	IfStringWasObj.ToExit:=False;
	repeat
	SPCharAddSimbol(NewChunkString,FExpression[Position]);
	Position+=1;
	ChunkState:=IsOperator(NewChunkString);
	if IfStringWasObj.Was and ((ChunkState=0)or(ChunkState>=3)) then
		begin
		I:=SPCharLength(NewChunkString)-IfStringWasObj.Length;
		Position-=I;
		SPCharDecFromEnd(NewChunkString,I);
		ChunkState:=1;
		IfStringWasObj.ToExit:=True;
		end;
	if (ChunkState=1) and (not IfStringWasObj.ToExit) then
		begin
		IfStringWasObj.Was:=True;
		IfStringWasObj.Length:=SPCharLength(NewChunkString);
		ChunkState:=2;
		end;
	if ChunkState>=3 then
		begin
		if ChunkState=3 then
			begin
			Position-=1;
			SPCharDecFromEnd(NewChunkString);
			end
		else
			begin
			I:=SPCharLength(FOperators[ChunkState-4].FName);
			SPCharDecFromEnd(NewChunkString,I);
			Position-=I;
			end;
		end;
	until (FExpression[Position]=#0) or (ChunkState=1) or (ChunkState>=3);
	//write(NewChunkString,' ');
	if SPCharLength(NewChunkString)>0 then
		begin
		NewChunk:=TSExpressionChunkCreateNull;
		IdentityChunk(NewChunkString,NewChunk,ChunkState,IfStringWasObj.Was and (IfStringWasObj.Length=SPCharLength(NewChunkString)));
		if NewChunk.Quantity<>0 then
			begin
			case NewChunk.FType of
			S_BOOLEAN,S_NUMERIC,S_REAL,S_VARIABLE:
				(* If that is a data *)(* If that is variable *)
				begin
				AddExpressionChunk(NewChunk);
				end;
			S_OBJECT,S_OPERATOR,S_FUNCTION:
				(* If that is operator or function *)
				begin
				SetLength(OperatorsSteak,Length(OperatorsSteak)+1);
				if not(SPCharsEqual(NewChunk.FVariable,')') and (SPCharsEqual(NewChunk.FVariable,'('))) then
					begin
					if (OldChunk.Quantity<>0)and
						(
							(OldChunk.FType in [S_BOOLEAN,S_NUMERIC,S_REAL,S_VARIABLE]) or 
							(SPCharsEqual(OldChunk.FVariable,')'))
						) then
						begin
						if FindObject(NewChunk,S_OPERATOR) then
							NewChunk.FType:=S_OPERATOR
						else
							if FindObject(NewChunk,S_FUNCTION) then
								NewChunk.FType:=S_FUNCTION;
						end
					else
						begin
						if FindObject(NewChunk,S_FUNCTION) then
							NewChunk.FType:=S_FUNCTION
						else
							if FindObject(NewChunk,S_OPERATOR) then
								NewChunk.FType:=S_OPERATOR;
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
CanculateSteak(OperatorsSteak,TSExpressionChunkCreateNull);
if DeBug then
	DebugSteak(FCanculatedExpression);
if FCalculateForGraph then
	CalculateExpressionForGraph;
end;

procedure TSExpression.CanculateSteak(var OperatorsSteak:TArTSExpressionChunk;const Chunk:TSExpressionChunk);
var
	I:LongInt = 0;
	II:LongInt = 0;
	HighOperator:TSExpressionChunk;

procedure AboutSkobki;
begin
if SPCharsEqual(OperatorsSteak[High(OperatorsSteak)].FVariable,')') and SPCharsEqual(OperatorsSteak[High(OperatorsSteak)-1].FVariable,'(') then
	SetLength(OperatorsSteak,Length(OperatorsSteak)-2);
end;

begin
HighOperator:=TSExpressionChunkCreateNull;
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
				AND (not SPCharsEqual(OperatorsSteak[High(OperatorsSteak)].FVariable,'(') )  then
			begin
			II:=0;
			I:=High(OperatorsSteak)-1;
			while 
				(I>=0) and 
				(not SPCharsEqual(OperatorsSteak[I].FVariable,'(')) and 
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

constructor TSExpressionChunk.Create;
begin
inherited;
FConst:=0;
FVariable:='';
end;

destructor TSExpressionChunk.Destroy;
begin
if FVariable<>nil then
	FreeMem(FVariable);
inherited;
end;

constructor TSExpression.Create;
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

NewObject(TSExpressionObject.Create(S_OPERATOR,'or',2,@OperatorOr,2));
NewObject(TSExpressionObject.Create(S_OPERATOR,'или',2,@OperatorOr,2));
NewObject(TSExpressionObject.Create(S_OPERATOR,'-',2,@OperatorMinus,2));
NewObject(TSExpressionObject.Create(S_OPERATOR,'+',2,@OperatorPlus,2));
NewObject(TSExpressionObject.Create(S_OPERATOR,'*',2,@OperatorUmnozhit,3));
NewObject(TSExpressionObject.Create(S_OPERATOR,'/',2,@OperatorDelenie,3));
NewObject(TSExpressionObject.Create(S_OPERATOR,':',2,@OperatorDelenie,3));
NewObject(TSExpressionObject.Create(S_OPERATOR,'&',2,@OperatorAnd,3));
NewObject(TSExpressionObject.Create(S_OPERATOR,'&&',2,@OperatorAnd,3));
NewObject(TSExpressionObject.Create(S_OPERATOR,'and',2,@OperatorAnd,3));
NewObject(TSExpressionObject.Create(S_OPERATOR,'и',2,@OperatorAnd,3));
NewObject(TSExpressionObject.Create(S_OPERATOR,'=',2,@OperatorEqual,2));
NewObject(TSExpressionObject.Create(S_OPERATOR,'==',2,@OperatorEqual,2));
NewObject(TSExpressionObject.Create(S_OPERATOR,'!=',2,@OperatorNotEqual,2));
NewObject(TSExpressionObject.Create(S_OPERATOR,'<>',2,@OperatorNotEqual,2));
NewObject(TSExpressionObject.Create(S_OPERATOR,'><',2,@OperatorNotEqual,2));

NewObject(TSExpressionObject.Create(S_OPERATOR,'**',2,@OperatorStepen,4,False));
NewObject(TSExpressionObject.Create(S_OPERATOR,'^',2,@OperatorStepen,4,False));
NewObject(TSExpressionObject.Create(S_OPERATOR,'imp',2,@OperatorImp,4,False));
NewObject(TSExpressionObject.Create(S_OPERATOR,'->',2,@OperatorImp,4,False));
NewObject(TSExpressionObject.Create(S_OPERATOR,'-->',2,@OperatorImp,4,False));
NewObject(TSExpressionObject.Create(S_OPERATOR,'xor',2,@OperatorXor,4,False));
NewObject(TSExpressionObject.Create(S_OPERATOR,'sfr',2,@OperatorSfr,4,False));

NewObject(TSExpressionObject.Create(S_OPERATOR,'div',2,@OperatorDiv,4,False));
NewObject(TSExpressionObject.Create(S_OPERATOR,'mod',2,@OperatorMod,4,False));

NewObject(TSExpressionObject.Create(S_FUNCTION,'pi',0,@FunctionPi,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'пи',0,@FunctionPi,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'e',0,@FunctionExp0,5,False));

NewObject(TSExpressionObject.Create(S_FUNCTION,'-',1,@FunctionMinus,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'not',1,@FunctionNot,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'не',1,@FunctionNot,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'!',1,@FunctionNot,5,False));

NewObject(TSExpressionObject.Create(S_FUNCTION,'tg',1,@FunctionTg,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'ctg',1,@FunctionCtg,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'cos',1,@FunctionCos,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'sin',1,@FunctionSin,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'sign',1,@FunctionSign,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'тангенс',1,@FunctionTg,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'котангенс',1,@FunctionCtg,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'косинус',1,@FunctionCos,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'синус',1,@FunctionSin,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'тг',1,@FunctionTg,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'ктг',1,@FunctionCtg,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'кос',1,@FunctionCos,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'син',1,@FunctionSin,5,False));

NewObject(TSExpressionObject.Create(S_FUNCTION,'exp',1,@FunctionExp1,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'ln',1,@FunctionLn,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'lg',1,@FunctionLg,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'log',2,@FunctionLog,5,False));

NewObject(TSExpressionObject.Create(S_FUNCTION,'sqrt',1,@FunctionSqrt,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'sqr',1,@FunctionSqr,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'abs',1,@FunctionAbs,5,False));

NewObject(TSExpressionObject.Create(S_FUNCTION,'arctg',1,@FunctionArcTg,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'arctan',1,@FunctionArcTg,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'arcctg',1,@FunctionArcCtg,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'arccos',1,@FunctionArcCos,5,False));
NewObject(TSExpressionObject.Create(S_FUNCTION,'arcsin',1,@FunctionArcSin,5,False));

CanculateNextMinPrioritete;
end;

destructor TSExpression.Destroy;
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