{$IFDEF SMATHREADINTERFACE}

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
{$ENDIF}

{$IFDEF SMATHREADIMPLEMENTATION}
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
	Result:=TSExpressionChunkCreateNone;
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
Result:=TSExpressionChunkCreateNone;
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
Result:=TSExpressionChunkCreateNone;
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
Result:=TSExpressionChunkCreateNone;
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
	Result:=TSExpressionChunkCreateNone;
end;
end;


function OperatorMod(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNone;
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
Result:=TSExpressionChunkCreateNone;
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
Result:=TSExpressionChunkCreateNone;
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
Result:=TSExpressionChunkCreateNone;
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
Result:=TSExpressionChunkCreateNone;
case Chunk.FType of
S_NUMERIC,S_REAL:
	begin
	Result:=TSExpressionChunkCreateReal(sqrt(Chunk.FConst));
	end;
end;
end;

function OperatorStepen(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNone;
if (Chunk1.FType=S_NUMERIC) and (Chunk2.FType=S_NUMERIC) then
	begin
	Result.Create;  Result.Quantity:=1;
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
Result:=TSExpressionChunkCreateNone;
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
	Result:=TSExpressionChunkCreateNone;
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
	Result:=TSExpressionChunkCreateNone;
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
	Result:=TSExpressionChunkCreateNone;
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
	Result:=TSExpressionChunkCreateNone;
	end;
	end;
else
	Result:=TSExpressionChunkCreateNone;
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
	Result:=TSExpressionChunkCreateNone;
	end;
	end;
else
	Result:=TSExpressionChunkCreateNone;
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
	Result:=TSExpressionChunkCreateNone;
	end;
	end;
else
	Result:=TSExpressionChunkCreateNone;
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
	Result:=TSExpressionChunkCreateNone;
	end;
	end;
else
	Result:=TSExpressionChunkCreateNone;
end;
end;

function OperatorAnd(Chunk1,Chunk2:TSExpressionChunk):TSExpressionChunk;
begin
Result:=TSExpressionChunkCreateNone;
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
Result:=TSExpressionChunkCreateNone;
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
Result:=TSExpressionChunkCreateNone;
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
Result:=TSExpressionChunkCreateNone;
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
Result:=TSExpressionChunkCreateNone;
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
Result:=TSExpressionChunkCreateNone;
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
Result:=TSExpressionChunkCreateNone;
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


{$ENDIF}
