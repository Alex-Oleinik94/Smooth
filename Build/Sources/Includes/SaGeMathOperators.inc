{$IFDEF SGMATHREADINTERFACE}

function OperatorAnd(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
function OperatorOr(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
function OperatorSfr(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
function OperatorUmnozhit(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
function OperatorPlus(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
function OperatorMinus(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
function OperatorDelenie(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
function OperatorEqual(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
function OperatorNotEqual(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
function OperatorMod(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
function OperatorDiv(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;

function OperatorStepen(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
function OperatorImp(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;

function FunctionNot(Chunk:TSGExpressionChunk):TSGExpressionChunk;
function FunctionCtg(Chunk:TSGExpressionChunk):TSGExpressionChunk;
function FunctionCos(Chunk:TSGExpressionChunk):TSGExpressionChunk;
function FunctionSin(Chunk:TSGExpressionChunk):TSGExpressionChunk;
function FunctionSign(Chunk:TSGExpressionChunk):TSGExpressionChunk;
function FunctionTg(Chunk:TSGExpressionChunk):TSGExpressionChunk;
function FunctionSqrt(Chunk:TSGExpressionChunk):TSGExpressionChunk;
function FunctionMinus(Chunk:TSGExpressionChunk):TSGExpressionChunk;
function FunctionSqr(Chunk:TSGExpressionChunk):TSGExpressionChunk;
function FunctionArcTg(Chunk:TSGExpressionChunk):TSGExpressionChunk;
function FunctionArcSin(Chunk:TSGExpressionChunk):TSGExpressionChunk;
function FunctionArcCos(Chunk:TSGExpressionChunk):TSGExpressionChunk;
function FunctionArcCtg(Chunk:TSGExpressionChunk):TSGExpressionChunk;
function FunctionAbs(Chunk:TSGExpressionChunk):TSGExpressionChunk;
function FunctionExp1(Chunk:TSGExpressionChunk):TSGExpressionChunk;
function FunctionLn(Chunk:TSGExpressionChunk):TSGExpressionChunk;
function FunctionLg(Chunk:TSGExpressionChunk):TSGExpressionChunk;

function FunctionPi:TSGExpressionChunk;
function FunctionExp0:TSGExpressionChunk;

function FunctionLog(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
{$ENDIF}

{$IFDEF SGMATHREADIMPLEMENTATION}
function FunctionSign(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
if Chunk.FConst>0 then
Result:=TSGExpressionChunkCreateNumeric(1)
else
if Chunk.FConst<0 then
Result:=TSGExpressionChunkCreateNumeric(-1)
else
Result:=TSGExpressionChunkCreateNumeric(0);
end;

function FunctionLog(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
begin
if  (Chunk1.FType in [SG_NUMERIC,SG_REAL]) and (Chunk2.FType in [SG_NUMERIC,SG_REAL]) then  
	begin
	Result:=TSGExpressionChunkCreateReal(Log(Chunk1.FConst,Chunk2.FConst));
	end
else
	Result:=TSGExpressionChunkCreateNone;
end;

function FunctionPi:TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateReal(Pi);
end;

function FunctionExp0:TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateReal(exp(1));
end;

function FunctionLn(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
case Chunk.FType of
SG_NUMERIC,SG_REAL:
	begin
	Result:=TSGExpressionChunkCreateReal(Ln(Chunk.FConst));
	end;
else
	Result:=Chunk;
end;
end;

function FunctionLg(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
case Chunk.FType of
SG_NUMERIC,SG_REAL:
	begin
	Result:=TSGExpressionChunkCreateReal(Log(10,Chunk.FConst));
	end;
else
	Result:=Chunk;
end;
end;

function FunctionExp1(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
case Chunk.FType of
SG_NUMERIC,SG_REAL:
	begin
	Result:=TSGExpressionChunkCreateReal(Exp(Chunk.FConst));
	end;
else
	Result:=Chunk;
end;
end;

function OperatorXor(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
if (Chunk1.FType=SG_BOOLEAN) and (Chunk2.FType=SG_BOOLEAN) then
	begin
	Result.Create;  
	Result.Quantity:=1;
	Result.FType:=SG_BOOLEAN;
	Result.FConst:= byte((boolean(trunc(Chunk1.FConst))) xor boolean(trunc(Chunk2.FConst)));
	end;
end;

function OperatorSfr(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
if (Chunk1.FType=SG_BOOLEAN) and (Chunk2.FType=SG_BOOLEAN) then
	begin
	Result.Create;  
	Result.Quantity:=1;
	Result.FType:=SG_BOOLEAN;
	Result.FConst:= byte(not ((boolean(trunc(Chunk1.FConst))) and boolean(trunc(Chunk2.FConst))));
	end;

end;

function OperatorImp(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
if (Chunk1.FType=SG_BOOLEAN) and (Chunk2.FType=SG_BOOLEAN) then
	begin
	Result.Create;  
	Result.Quantity:=1;
	Result.FType:=SG_BOOLEAN;
	Result.FConst:= byte((not boolean(trunc(Chunk1.FConst))) or boolean(trunc(Chunk2.FConst)));
	end;
end;

function FunctionAbs(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
case Chunk.FType of
SG_NUMERIC,SG_REAL:
	begin
	Result:=TSGExpressionChunkCreateReal(abs(Chunk.FConst));
	end;
else
	Result:=Chunk;
end;
end;

function FunctionArcCtg(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
case Chunk.FType of
SG_NUMERIC,SG_REAL:
	begin
	Result:=TSGExpressionChunkCreateReal(pi/2+arctan(-Chunk.FConst));
	end;
else
	Result:=TSGExpressionChunkCreateNone;
end;
end;


function OperatorMod(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
if (Chunk1.FType=SG_NUMERIC) and (Chunk2.FType=SG_NUMERIC) then
	begin
	Result:=TSGExpressionChunkCreateNumeric(trunc(Chunk1.FConst) mod trunc(Chunk2.FConst));
	end
else
	if(Chunk1.FType in [SG_REAL,SG_NUMERIC]) and (Chunk1.FType in [SG_REAL,SG_NUMERIC])then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=SG_REAL;
		Result.FConst:=((Chunk1.FConst/Chunk2.FConst)-trunc(Chunk1.FConst/Chunk2.FConst))*Chunk2.FConst;
		end;
end;

function OperatorDiv(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
if (Chunk1.FType=SG_NUMERIC) and (Chunk2.FType=SG_NUMERIC) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=SG_NUMERIC;
	Result.FConst:=trunc(Chunk1.FConst) div trunc(Chunk2.FConst);
	end
else
	if(Chunk1.FType in [SG_REAL,SG_NUMERIC]) and (Chunk1.FType in [SG_REAL,SG_NUMERIC])then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=SG_REAL;
		Result.FConst:=trunc(Chunk1.FConst/Chunk2.FConst);
		end;
end;

function FunctionSqr(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
case Chunk.FType of
SG_NUMERIC:
	begin
	Result:=TSGExpressionChunkCreateReal(sqr(trunc(Chunk.FConst)));
	end;
SG_REAL:
	begin
	Result:=TSGExpressionChunkCreateReal(sqr(Chunk.FConst));
	end;
end;
end;

function FunctionMinus(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
case Chunk.FType of
SG_NUMERIC:
	begin
	Result:=TSGExpressionChunkCreateNumeric(-trunc(Chunk.FConst));
	end;
SG_REAL:
	begin
	Result:=TSGExpressionChunkCreateReal(-Chunk.FConst);
	end;
end;
end;

function FunctionSqrt(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
case Chunk.FType of
SG_NUMERIC,SG_REAL:
	begin
	Result:=TSGExpressionChunkCreateReal(sqrt(Chunk.FConst));
	end;
end;
end;

function OperatorStepen(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
if (Chunk1.FType=SG_NUMERIC) and (Chunk2.FType=SG_NUMERIC) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=SG_NUMERIC;
	Result.FConst:=trunc(Chunk1.FConst)**trunc(Chunk2.FConst);
	end
else
	begin
	if(Chunk1.FType=SG_BOOLEAN) and (Chunk2.FType=SG_NUMERIC)then
		begin
		Result.Create;  
		Result.Quantity:=1;
		Result.FType:=SG_BOOLEAN;
		Result.FConst:=Chunk1.FConst;
		end
	else
		if(Chunk1.FType in [SG_REAL,SG_NUMERIC]) and (Chunk2.FType in [SG_NUMERIC]) then
			begin
			Result.Create;  Result.Quantity:=1;
			Result.FType:=SG_REAL;
			Result.FConst:=Chunk1.FConst**Trunc(Chunk2.FConst);
			end
		else
			if(Chunk1.FType in [SG_REAL,SG_NUMERIC]) and (Chunk2.FType in [SG_REAL,SG_NUMERIC]) then
				begin
				Result.Create;  Result.Quantity:=1;
				Result.FType:=SG_REAL;
				Result.FConst:=Chunk1.FConst**Chunk2.FConst;
				end;
	end;
end;


function FunctionNot(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
case Chunk.FType of
SG_BOOLEAN:
	begin
	Result:=TSGExpressionChunkCreateBoolean(not boolean(trunc(Chunk.FConst)));
	end;
SG_NUMERIC:
	begin
	Result:=TSGExpressionChunkCreateNumeric(not trunc(Chunk.FConst));
	end;
end;
end;

function FunctionTg(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
case Chunk.FType of
SG_NUMERIC,SG_REAL:
	begin
	Result:=TSGExpressionChunkCreateReal(sin(Chunk.FConst)/cos(Chunk.FConst));
	end;
else
	Result:=TSGExpressionChunkCreateNone;
end;
end;

function FunctionSin(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
case Chunk.FType of
SG_NUMERIC,SG_REAL:
	begin
	Result:=TSGExpressionChunkCreateReal(sin(Chunk.FConst));
	end;
else
	Result:=TSGExpressionChunkCreateNone;
end;
end;

function FunctionCos(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
case Chunk.FType of
SG_NUMERIC,SG_REAL:
	begin
	Result:=TSGExpressionChunkCreateReal(cos(Chunk.FConst));
	end;
else
	Result:=TSGExpressionChunkCreateNone;
end;
end;

function FunctionCtg(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
case Chunk.FType of
SG_NUMERIC,SG_REAL:
	begin
	try
	Result:=TSGExpressionChunkCreateReal(cos(Chunk.FConst)/sin(Chunk.FConst));
	except
	Result:=TSGExpressionChunkCreateNone;
	end;
	end;
else
	Result:=TSGExpressionChunkCreateNone;
end;
end;

function FunctionArcTg(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
case Chunk.FType of
SG_NUMERIC,SG_REAL:
	begin
	try
	Result:=TSGExpressionChunkCreateReal(arctan(Chunk.FConst));
	except
	Result:=TSGExpressionChunkCreateNone;
	end;
	end;
else
	Result:=TSGExpressionChunkCreateNone;
end;
end;

function FunctionArcSin(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
case Chunk.FType of
SG_NUMERIC,SG_REAL:
	begin
	try
	Result:=TSGExpressionChunkCreateReal(arcsin(Chunk.FConst));
	except
	Result:=TSGExpressionChunkCreateNone;
	end;
	end;
else
	Result:=TSGExpressionChunkCreateNone;
end;
end;

function FunctionArcCos(Chunk:TSGExpressionChunk):TSGExpressionChunk;
begin
case Chunk.FType of
SG_NUMERIC,SG_REAL:
	begin
	try
	Result:=TSGExpressionChunkCreateReal(arccos(Chunk.FConst));
	except
	Result:=TSGExpressionChunkCreateNone;
	end;
	end;
else
	Result:=TSGExpressionChunkCreateNone;
end;
end;

function OperatorAnd(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
if (Chunk1.FType=SG_NUMERIC) and (Chunk2.FType=SG_NUMERIC) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=SG_NUMERIC;
	Result.FConst:=trunc(Chunk1.FConst) and trunc(Chunk2.FConst);
	end
else
	begin
	if(Chunk1.FType=SG_BOOLEAN) and (Chunk2.FType=SG_BOOLEAN)then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=SG_BOOLEAN;
		Result.FConst:=Byte(Boolean(trunc(Chunk1.FConst)) and Boolean(trunc(Chunk2.FConst)));
		end;
	end;
end;

function OperatorOr(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
if (Chunk1.FType=SG_NUMERIC) and (Chunk2.FType=SG_NUMERIC) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=SG_NUMERIC;
	Result.FConst:=trunc(Chunk1.FConst) or trunc(Chunk2.FConst);
	end
else
	begin
	if(Chunk1.FType=SG_BOOLEAN) and (Chunk2.FType=SG_BOOLEAN)then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=SG_BOOLEAN;
		Result.FConst:=Byte(Boolean(trunc(Chunk1.FConst)) or Boolean(trunc(Chunk2.FConst)));
		end;
	end;
end;

function OperatorPlus(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
if (Chunk1.FType=SG_NUMERIC) and (Chunk2.FType=SG_NUMERIC) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=SG_NUMERIC;
	Result.FConst:=trunc(Chunk1.FConst)+trunc(Chunk2.FConst);
	end
else
	begin
	if(Chunk1.FType=SG_BOOLEAN) and (Chunk2.FType=SG_BOOLEAN)then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=SG_BOOLEAN;
		Result.FConst:=Byte(Boolean(trunc(Chunk1.FConst)) Xor Boolean(trunc(Chunk2.FConst)));
		end
	else
		if(Chunk1.FType in [SG_REAL,SG_NUMERIC]) and (Chunk2.FType in [SG_REAL,SG_NUMERIC])then
			begin
			Result.Create;  Result.Quantity:=1;
			Result.FType:=SG_REAL;
			Result.FConst:=Chunk1.FConst+Chunk2.FConst;
			end;
	end;
end;

function OperatorMinus(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
if (Chunk1.FType=SG_NUMERIC) and (Chunk2.FType=SG_NUMERIC) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=SG_NUMERIC;
	Result.FConst:=trunc(Chunk1.FConst)-trunc(Chunk2.FConst);
	end
else
	if(Chunk1.FType in [SG_REAL,SG_NUMERIC]) and (Chunk2.FType in [SG_REAL,SG_NUMERIC])then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=SG_REAL;
		Result.FConst:=Chunk1.FConst-Chunk2.FConst;
		end;
end;

function OperatorNotEqual(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=OperatorEqual(Chunk1,Chunk2);
if Result.Quantity<>0 then
	Result.FConst:=byte(not boolean(trunc(Result.FConst)));
end;

function OperatorEqual(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
if (Chunk1.FType=SG_NUMERIC) and (Chunk2.FType=SG_NUMERIC) and (trunc(Chunk2.FConst)<>0) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=SG_BOOLEAN;
	Result.FConst:=byte(trunc(Chunk1.FConst)=trunc(Chunk2.FConst));
	end
else
	begin
	if(Chunk1.FType=SG_BOOLEAN) and (Chunk2.FType=SG_BOOLEAN)then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=SG_BOOLEAN;
		Result.FConst:=Byte(Boolean(trunc(Chunk1.FConst)) = ( Boolean(trunc(Chunk2.FConst))));
		end
	else
		if(Chunk1.FType in [SG_REAL,SG_NUMERIC]) and (Chunk2.FType in [SG_REAL,SG_NUMERIC])  and (Chunk2.FConst<>0)then
			begin
			Result.Create;  Result.Quantity:=1;
			Result.FType:=SG_BOOLEAN;
			Result.FConst:=byte(Chunk1.FConst=Chunk2.FConst);
			end
		else
			if(Chunk1.FType=SG_VARIABLE) and (Chunk2.FType=SG_VARIABLE)then
				begin
				Result.Create;  Result.Quantity:=1;
				Result.FType:=SG_BOOLEAN;
				Result.FConst:=byte(SGPCharsEqual(Chunk1.FVariable,Chunk2.FVariable));
				end;
	end;
end;


function OperatorDelenie(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
if (Chunk1.FType=SG_NUMERIC) and (Chunk2.FType=SG_NUMERIC) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=SG_REAL;
	Result.FConst:=trunc(Chunk1.FConst)/trunc(Chunk2.FConst);
	end
else
	if (Chunk1.FType in [SG_REAL,SG_NUMERIC]) and (Chunk2.FType in [SG_REAL,SG_NUMERIC])then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=SG_REAL;
		Result.FConst:=Chunk1.FConst/Chunk2.FConst;
		end;
end;

function OperatorUmnozhit(Chunk1,Chunk2:TSGExpressionChunk):TSGExpressionChunk;
begin
Result:=TSGExpressionChunkCreateNone;
if (Chunk1.FType=SG_NUMERIC) and (Chunk2.FType=SG_NUMERIC) then
	begin
	Result.Create;  Result.Quantity:=1;
	Result.FType:=SG_NUMERIC;
	Result.FConst:=trunc(Chunk1.FConst)*trunc(Chunk2.FConst);
	end
else
	begin
	if(Chunk1.FType=SG_BOOLEAN) and (Chunk2.FType=SG_BOOLEAN)then
		begin
		Result.Create;  Result.Quantity:=1;
		Result.FType:=SG_BOOLEAN;
		Result.FConst:=Byte(Boolean(trunc(Chunk1.FConst)) and Boolean(trunc(Chunk2.FConst)));
		end
	else
		if(Chunk1.FType in [SG_REAL,SG_NUMERIC]) and (Chunk2.FType in [SG_REAL,SG_NUMERIC])then
			begin
			Result.Create;  Result.Quantity:=1;
			Result.FType:=SG_REAL;
			Result.FConst:=Chunk1.FConst*Chunk2.FConst;
			end;
	end;
end;


{$ENDIF}
