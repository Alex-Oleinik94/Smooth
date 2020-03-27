{$INCLUDE Smooth.inc}

unit SmoothShaderReader;

interface

uses
	 Classes
	
	,SmoothBase
	,SmoothLists
	,SmoothBaseClasses
	,SmoothResourceManager
	;
type
	TSShaderParams = TSStringList;
	TSShaderReader = class(TSNamed)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSString; override;
			private
		FStandartParams : packed array of
			packed record
				FNumber : TSLongWord;
				FParam  : TSString;
				end;
		FStream : TMemoryStream;
		FFileParams : TSShaderParams;
		FFileName : TSString;
			public
		function IdentifierValue(VString : TSString;const VAditionalParams : TSString = ''):TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ProcessString(const VString : TSString;const VAditionalParams : TSString = ''):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ProcessFor(const VVariable : TSString; const VBegin, VEnd : TSLongInt; const VString : TSString;const NeedEolns : TSBoolean = False;const VAditionalParams : TSString = ''):TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ProcessComand(const VComand : TSString; VParams : TSShaderParams;const Stream : TMemoryStream;const VAditionalParams : TSString = ''):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function FindComand(VString : TSString; out VParams : TSShaderParams; out ComandShift : TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ProcessCustomString(const S : TSString; const Stream : TMemoryStream; const VAditionalParams : TSString = '';const UseEoln : TSBoolean = True):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function Process():TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ProcessStrings(VString : TSString;const VAditionalParams : TSString = ''):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		
		function WithParam(const VAditionalParams : TSString; const VParam:TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		function WithParam(const VAditionalParams : TSString; const VParam, VValue:TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		function DelParam(const VAditionalParams : TSString; const VParam:TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetParam(const VAditionalParams : TSString; const VParam:TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ConqutinateParam(const VAditionalParams : TSString; const VParam, VConqutinateValue:TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		
		function WithComandShift(const VAditionalParams : TSString; const VShift:TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetComandShift(const VAditionalParams : TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property FileName : TSString write FFileName;
		property FileParams : TSShaderParams write FFileParams;
		end;

procedure SSaveShaderSourceToFile(const VFileName, VSource : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SReadShaderSourceFromFile(const VFileName : TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SReadShaderSourceFromFile(const VFileName : TSString; const VFileParams : TSStringList ):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SReadShaderSourceFromFile(const VFileName : TSString; const VFileParams : array of const):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SReadAndSaveShaderSourceFile(const VInFileName, VOutFileName : TSString; const VFileParams : TSStringList );{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
procedure SReadAndSaveShaderSourceFile(const VInFileName, VOutFileName : TSString; const VFileParams : array of const);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

uses
	 SmoothStreamUtils
	,SmoothStringUtils
	,SmoothLog
	,SmoothFileUtils
	,SmoothMath
	
	,StrMan
	;

function SReadShaderSourceFromFile(const VFileName : TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	VFileParams : TSShaderParams;
begin
Result := SReadShaderSourceFromFile(VFileName,VFileParams);
end;

function SReadShaderSourceFromFile(const VFileName : TSString; const VFileParams : TSShaderParams):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	Reader : TSShaderReader = nil;
begin
Reader := TSShaderReader.Create();
Reader.FileName := VFileName;
Reader.FileParams := VFileParams;
Result := Reader.Process();
Reader.Destroy();
end;

procedure SReadAndSaveShaderSourceFile(const VInFileName, VOutFileName : TSString; const VFileParams : TSStringList);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
SSaveShaderSourceToFile(VOutFileName,SReadShaderSourceFromFile(VInFileName,VFileParams));
end;

procedure SReadAndSaveShaderSourceFile(const VInFileName, VOutFileName : TSString; const VFileParams : array of const );{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
SSaveShaderSourceToFile(VOutFileName,SReadShaderSourceFromFile(VInFileName,VFileParams));
end;

function SReadShaderSourceFromFile(const VFileName : TSString; const VFileParams : array of const):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
var
	FileParams : TSShaderParams;
begin
Result:='';
FileParams := SConstArrayToStringList(VFileParams);
Result := SReadShaderSourceFromFile(VFileName,FileParams);
SetLength(FileParams,0);
end;

procedure SSaveShaderSourceToFile(const VFileName, VSource : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SExportStringToFile(VFileName, VSource);
end;

//===================================//
//==========TSShaderReader==========//
//===================================//

class function TSShaderReader.ClassName() : TSString;
begin
Result := 'TSShaderReader';
end;

function TSShaderReader.DelParam(const VAditionalParams : TSString; const VParam:TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSLongWord;
	S, P : TSString;
begin
Result := '';
for i := 1 to StringWordCount(VAditionalParams,',') do
	begin
	S := StringWordGet(VAditionalParams,',',i);
	P := StringWordGet(S,'=',1);
	if P <> VParam then
		begin
		if Result <> '' then
			Result += ',';
		Result += S;
		end;
	end;
end;

function TSShaderReader.GetParam(const VAditionalParams : TSString; const VParam:TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSLongWord;
	S, P : TSString;
	Pattern : TSBoolean;
begin
Result := '';
for i := 1 to StringWordCount(VAditionalParams,',') do
	begin
	S := StringWordGet(VAditionalParams,',',i);
	Pattern := StringMatching(S,'*=*');
	P := StringWordGet(S,'=',1);
	if (not Pattern) and (P=VParam) then
		begin
		Result := '1';
		break;
		end
	else if (Pattern) and (P=VParam) then
		begin
		Result := StringWordGet(S,'=',2);
		break;
		end;
	end;
end;

function TSShaderReader.WithComandShift(const VAditionalParams : TSString; const VShift:TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:= WithParam(VAditionalParams, 'ComandShift', SStringReplace(SStringReplace(GetComandShift(VAditionalParams) + VShift,' ','S'),'	','T'));
end;

function TSShaderReader.GetComandShift(const VAditionalParams : TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SStringReplace(SStringReplace(GetParam(VAditionalParams,'ComandShift'),'S',' '),'T','	');
end;

function TSShaderReader.ConqutinateParam(const VAditionalParams : TSString; const VParam, VConqutinateValue:TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := WithParam(VAditionalParams,VParam,GetParam(VAditionalParams,VParam) + VConqutinateValue);
end;

function TSShaderReader.WithParam(const VAditionalParams : TSString; const VParam, VValue:TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := WithParam(VAditionalParams,VParam + '=' + VValue);
end;

function TSShaderReader.WithParam(const VAditionalParams : TSString; const VParam:TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := DelParam(VAditionalParams,VParam);
if Result <> '' then
	Result += ',';
Result += VParam;
end;

constructor TSShaderReader.Create();
begin
inherited;
FStandartParams := nil;
end;

destructor TSShaderReader.Destroy();
begin
SetLength(FStandartParams,0);
SetLength(FFileParams,0);
inherited;
end;

function TSShaderReader.ProcessStrings(VString : TSString;const VAditionalParams : TSString = ''):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream : TMemoryStream;
	S : TSString;
begin
Result := '';
Stream := TMemoryStream.Create();
Stream.WriteBuffer(VString[1],Length(VString));
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	begin
	S := SReadLnStringFromStream(Stream);
	if Stream.Position = Stream.Size then
		Result += ProcessCustomString(S,Stream,VAditionalParams,False)
	else
		Result += ProcessCustomString(S,Stream,VAditionalParams,True);
	end;
Stream.Destroy();
end;

function TSShaderReader.IdentifierValue(VString : TSString;const VAditionalParams : TSString = ''):TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii, iii : TSLongWord;
	S : TSString;
begin
Result := VString;
if (Length(VString)>5) then
	begin
	VString := StringTrimAll(VString,' 	');
	VString := StringTrimAll(VString,'/');
	VString := StringTrimAll(VString,'*');
	VString := StringTrimLeft(VString,'#');
	VString := StringTrimAll(VString,' 	');
	i := SVal(VString);
	if (i<>0) or ((i=0) and (StringTrimAll(VString,'0') = '')) then
		begin
		if (FFileParams = nil) or (Length(FFileParams)<i+1) then
			begin
			if (FStandartParams<>nil) and (Length(FStandartParams)>0) then
				for ii := 0 to High(FStandartParams) do
					if FStandartParams[ii].FNumber = i then
						begin
						Result := FStandartParams[ii].FParam;
						break;
						end;
			end
		else
			Result := FFileParams[i];
		end
	else if 'RI' = SUpCaseString(VString) then
		begin
		Result := 'RandomIdentifier_';
		for i := 0 to random(10)+5 do
			begin
			ii := Random(3);
			if ii = 0 then
				Result += Char(Random(26)+Byte('a'))
			else if ii = 1 then
				Result += Char(Random(26)+Byte('A'))
			else
				Result += Char(Random(10)+Byte('0'));
			end;
		end
	else if SUpCaseString(VString) = 'EOLN' then
		begin
		Result := SWinEoln;
		end
	else if SUpCaseString(VString) = 'NOTHINK' then
		begin
		Result := '';
		end
	else
		begin
		iii := StringWordCount(VAditionalParams,',');
		if iii <> 0 then
			begin
			ii := 1;
			while (ii <= iii) do
				begin
				S := StringWordGet(VAditionalParams,',',ii);
				S := StringTrimAll(S,' 	');
				i := StringWordCount(S,'=');
				if i = 2 then
					begin
					if StringTrimAll(StringWordGet(S,'=',1),' 	') = VString then
						begin
						Result := StringTrimAll(StringWordGet(S,'=',2),' 	');
						break;
						end;
					end
				else
					begin
					end;
				ii += 1;
				end;
			end;
		end;
	end;
end;

function TSShaderReader.ProcessString(const VString : TSString;const VAditionalParams : TSString = ''):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii : TSLongWord;
	S : TSString;
begin
Result := '';
i := 1;
while i <= Length(VString) do
	begin
	if (VString[i]='/') and (i + 5 <= Length(VString)) and (VString[i+1]='*')and (VString[i+2]='#') then
		begin
		S := '/*#';
		ii := i+3;
		while (VString[ii] <> '*') and (VString[ii]<>'/') and (i <= Length(VString)) do
			begin
			S += VString[ii];
			ii += 1;
			end;
		if (VString[ii]='*') and (i+1<=Length(VString)) and (VString[ii+1]='/') then
			begin
			i := ii + 2;
			S += '*/';
			Result += IdentifierValue(S,VAditionalParams);
			end
		else
			begin
			Result += S;
			i := ii;
			end;
		end
	else
		begin
		Result += VString[i];
		i += 1;
		end;
	end;
end;

function TSShaderReader.ProcessFor(const VVariable : TSString; const VBegin, VEnd : TSLongInt; const VString : TSString;const NeedEolns : TSBoolean = False;const VAditionalParams : TSString = ''):TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSLongInt;
	S : TSString;
begin
Result := '';
if VString <> '' then
	for i := VBegin to VEnd do
		begin
		S := ProcessStrings(VString,WithParam(VAditionalParams,VVariable,SStr(i)));
		Result += S;
		if NeedEolns and (i <> VEnd) and (S <> SWinEoln) then
			Result += SWinEoln;
		end;
end;

function TSShaderReader.ProcessComand(const VComand : TSString; VParams : TSShaderParams;const Stream : TMemoryStream;const VAditionalParams : TSString = ''):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii, iii : LongWord;
	S, S1, S2, C, CS : TSString;
	CH : TSChar;
	Params : TSShaderParams;
begin
Result := '';
if VComand='IF' then
	begin
	S := '';
	iii := 0;
	if (VParams<>nil) and (Length(VParams)>0) then
		for i := 0 to High(VParams) do
			begin
			if i <> 0 then
				S += ' ';
			S += VParams[i];
			end;
	S := ProcessString(S, VAditionalParams);
	if StringWordCount(S,'==') = 2 then
		begin
		iii := Byte((StringTrimAll(StringWordGet(S,'==',1),' 	') = StringTrimAll(StringWordGet(S,'==',2),' 	')) and (StringTrimAll(StringWordGet(S,'==',1),' 	') <> ''));
		end
	else
		begin
		//TODO
		end;
	S := ''; S1 := ''; S2 := '';
	ii := 1;
	i := 1;
	while i <> 0 do
		begin
		S := SReadLnStringFromStream(Stream);
		C := SUpCaseString(FindComand(S,Params,CS));
		if C = 'IF' then
			i += 1
		else if C = 'ENDIF' then
			i -= 1;
		if (C='ELSE') and (i = 1) then
			ii := byte(not(boolean(ii)));
		if (C = '') or ((C <> '') and (
			(((C='IF') or (C='ENDIF')) and (i>=1)) or
			((C='ELSE') and (i>=2))
			)) then
			begin
			if ii = 1 then
				S1 += S
			else
				S2 += S;
			end;
		end;
	if boolean(iii) then
		begin
		if S1 <> '' then
			Result := ProcessStrings(S1,VAditionalParams);
		end
	else
		begin
		if S2 <> '' then
			Result := ProcessStrings(S2,VAditionalParams);
		end;
	end
else if VComand='FOR' then
	begin
	if (VParams=nil) or (Length(VParams)<3) then
		begin
		S := FFileName+'(for) Error: Syntax error count of params';
		{$IFNDEF RELEASE}
			WriteLn(S);
			{$ENDIF}
		SLog.Source(S);
		S := '';
		end
	else
		begin
		S := '';
		if Length(VParams)>3 then
			for i := 3 to High(VParams) do
				begin
				if i <> 3 then
					S += ' ';
				S += VParams[i];
				end;
		iii := 0;
		if S <> '' then
			for i := 1 to Length(S) do
				if S[i] = '{' then
					iii += 1
				else if S[i] = '}' then
					iii -= 1;
		if (Length(S)>0) and (S[Length(S)] <> '}') then
			S += SWinEoln;
		while (iii > 0) and (FStream.Position <> FStream.Size) do
			begin
			FStream.ReadBuffer(CH,1);
			if CH = '{' then
				iii += 1
			else if CH = '}' then
				iii -= 1;
			S += CH;
			end;
		ii := 0;
		if Length(S)>=2 then
			begin
			if (S[1] = '{') and (S[Length(S)] = '}') then
				begin
				S1 := '';
				for i := 2 to Length(S)-1 do
					S1 += S[i];
				S := S1;
				ii += 1;
				end;
			end;
		Result += ProcessFor(
			VParams[0],
			SVal(SCalculateExpression(ProcessString(VParams[1],VAditionalParams))),
			SVal(SCalculateExpression(ProcessString(VParams[2],VAditionalParams))),
			S,
			ii = 0,
			VAditionalParams);
		end;
	end
else if (VComand = SUpCaseString('standartparam')) or (VComand='SP') then
	begin
	i := 0;
	if FStandartParams <> nil then
		i := Length(FStandartParams);
	SetLength(FStandartParams, i + 1);
	FStandartParams[High(FStandartParams)].FNumber := SVal(SCalculateExpression(ProcessString(VParams[0])));
	FStandartParams[High(FStandartParams)].FParam  := SCalculateExpression(ProcessString(VParams[1]));
	end
else if (VComand='I') or (VComand='INC') or (VComand='INCLUDE') then
	begin
	S := '';
	if (VParams<> nil) and (Length(VParams)>0) then
		begin
		if (SResourceFiles.FileExists(SFilePath(FFileName) + VParams[0])) then
			S := SFilePath(FFileName) + VParams[0]
		else if SResourceFiles.FileExists(VParams[0]) then
			S := VParams[0]
		else
			begin
			S := FFileName+'(include) Error: Syntax error, filename expected but "identifier '+SUpCaseString(VParams[0])+'" found';
			{$IFNDEF RELEASE}
				WriteLn(S);
				{$ENDIF}
			SLog.Source(S);
			S := '';
			end;
		end
	else
		begin
		S := FFileName+'(include) Error: Syntax error, filename expected but nothink found';
		{$IFNDEF RELEASE}
			WriteLn(S);
			{$ENDIF}
		SLog.Source(S);
		S := '';
		end;
	if SResourceFiles.FileExists(S) then
		begin
		if (VParams <> nil) and (Length(VParams)>1) then
			for i := 1 to High(VParams) do
				VParams[i-1] := ProcessString(VParams[i],VAditionalParams);
		if (VParams <> nil) and (Length(VParams)>0) then
			SetLength(VParams,Length(VParams)-1);
		Result += SReadShaderSourceFromFile(S, VParams);
		end
	else
		begin
		S := FFileName+'(include) Fatal: Filename don''t found';
		{$IFNDEF RELEASE}
			WriteLn(S);
			{$ENDIF}
		SLog.Source(S);
		S := '';
		end;
	end
else
	begin
	Result += '#' + SDownCaseString(VComand);
	if (VParams <> nil) and (Length(VParams)<>0) then
		for i := 0 to High(VParams) do
			Result += ' ' + VParams[i];
	end;
end;

function TSShaderReader.FindComand(VString : TSString; out VParams : TSShaderParams; out ComandShift : TSString):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function IsBadSimbol(const Simbol : TSChar):TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (Simbol = ' ') or (Simbol = '	') or (Simbol = #27) or (Simbol = #13) or (Simbol = #10) or (Simbol = #0);
end;

function ReadParam(var i : TSLongWord):TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := '';
while (not IsBadSimbol(VString[i])) and (Length(VString)>=i) do
	begin
	Result += VString[i];
	i += 1;
	end;
end;

procedure FindParams(var i : TSLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetLength(VParams,0);
while i <= Length(VString) do
	begin
	while IsBadSimbol(VString[i]) and (Length(VString)>=i) do
		i += 1;
	if Length(VString)>=i then
		begin
		SetLength(VParams,Length(VParams)+1);
		VParams[High(VParams)] := ReadParam(i);
		end;
	end;
end;

var
	i : TSLongWord;

begin
Result := '';
ComandShift := '';
i := 1;
while (i <= Length(VString)) and (VString[i] <> '#') do
	begin
	ComandShift += VString[i];
	i += 1;
	end;
VString := StringTrimLeft(VString,' 	');
if Length(VString)>=2 then
	if VString[1] = '#' then
		begin
		i := 2;
		Result := ReadParam(i);
		FindParams(i);
		end
	else
		ComandShift := ''
else
	ComandShift := '';
end;

function TSShaderReader.ProcessCustomString(const S : TSString; const Stream : TMemoryStream;const VAditionalParams : TSString = '';const UseEoln : TSBoolean = True):TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	C, S1, CS : TSString;
	Params : TSShaderParams;
begin
Result := '';
C := FindComand(S,Params,CS);
if C='' then
	begin
	S1 := ProcessString(S,VAditionalParams);
	S1 := GetComandShift(VAditionalParams) + S1;
	if StringTrimAll(S1,' 	') <> '' then
		begin
		Result += S1;
		if UseEoln and (StringTrimAll(S1,' 	') <> SWinEoln) then
			Result += SWinEoln;
		end;
	end
else
	begin
	S1 := ProcessComand(SUpCaseString(C),Params,Stream,WithComandShift(VAditionalParams,CS));
	if StringTrimAll(S1,' 	') <> '' then
		Result += S1;
	if (StringTrimAll(S1,' 	') <> '') and UseEoln and (S1 <> SWinEoln) then
		Result += SWinEoln;
	SetLength(Params,0);
	end;
end;

function TSShaderReader.Process():TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := '';
FStream := TMemoryStream.Create();
if SResourceFiles.LoadMemoryStreamFromFile(FStream,FFileName) then
	begin
	FStream.Position := 0;
	while FStream.Position <> FStream.Size do
		Result += ProcessCustomString(SReadLnStringFromStream(FStream),FStream);
	end;
FStream.Destroy();
end;

end.
