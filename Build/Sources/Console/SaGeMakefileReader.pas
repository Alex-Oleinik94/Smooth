{$INCLUDE SaGe.inc}

unit SaGeMakefileReader;

interface

uses
	 Classes
	,Crt
	,SysUtils
	
	,SaGeMath
	,SaGeBase
	,SaGeBased
	,StrMan
	,SaGeVersion
	,SaGeResourceManager
	;

type
	TSGMRIdentifier = object
		FAbsoluteIdentifier  : TSGString;
		FDependentIdentifier : TSGString;
		end;
	
	TSGMRIdentifierList = packed array of TSGMRIdentifier;
	
	TSGMRIdentifierListEnumerator = class
			private
		FList : TSGMRIdentifierList;
		FIndex : TSGLongInt;
			public
		constructor Create(const List : TSGMRIdentifierList);
		function GetCurrent(): TSGMRIdentifier;
		function MoveNext(): TSGBoolean;
		property Current : TSGMRIdentifier read GetCurrent;
		end;
	
	TSGMRConstant = object
		FName : TSGString;
		FIdentifier : TSGMRIdentifier;
		end;
	
	TSGMRConstantList = packed array of TSGMRConstant;
	
	TSGMRConstantListEnumerator = class
			private
		FList : TSGMRConstantList;
		FIndex : TSGLongInt;
			public
		constructor Create(const List : TSGMRConstantList);
		function GetCurrent(): TSGMRConstant;
		function MoveNext(): TSGBoolean;
		property Current : TSGMRConstant read GetCurrent;
		end;
	
	TSGMRTarget = object
		FNames : TSGStringList;
		FComands : TSGMRIdentifierList;
		end;
	
	TSGMRTargetList = packed array of TSGMRTarget;
	
	TSGMRTargetListEnumerator = class
			private
		FList : TSGMRTargetList;
		FIndex : TSGLongInt;
			public
		constructor Create(const List : TSGMRTargetList);
		function GetCurrent(): TSGMRTarget;
		function MoveNext(): TSGBoolean;
		property Current : TSGMRTarget read GetCurrent;
		end;
	
	TSGMRIdentifierType = (
		SGMRIdentifierTypeAbsolute,
		SGMRIdentifierTypeDependent);
	
	TSGMakefileReader = class(TSGClass)
			public
		constructor Create(const VFileName : TSGString);
		destructor Destroy();override;
			private
		FFileName  : TSGString;
		FConstants : TSGMRConstantList;
		FTargets   : TSGMRTargetList;
			public
		property FileName : TSGString read FFileName;
			private
		procedure Read();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ProcessString(const S : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function IndexOfTarget(const VName : TSGString):TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		procedure RecombineIdentifiers();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetConstant(S : TSGString;const IdentifierType : TSGMRIdentifierType = SGMRIdentifierTypeAbsolute): TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetConstant(const Name, Value : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetTarget(const VIndex : TSGLongWord):TSGMRTarget;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetTarget(const VName : TSGString):TSGMRTarget;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function TargetCount() : TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ConstantCount() : TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		procedure Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Execute(const VTarget : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

operator Enumerator(const List : TSGMRIdentifierList): TSGMRIdentifierListEnumerator;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator Enumerator(const List : TSGMRConstantList): TSGMRConstantListEnumerator;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator Enumerator(const List : TSGMRTargetList): TSGMRTargetListEnumerator;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeStringUtils
	;

function TSGMakefileReader.GetTarget(const VIndex : TSGLongWord):TSGMRTarget;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.FNames := nil;
Result.FComands := nil;
if (VIndex < TargetCount()) and (VIndex >= 0) then
	Result := FTargets[VIndex];
end;

function TSGMakefileReader.GetTarget(const VName : TSGString):TSGMRTarget;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Target : TSGMRTarget;
	UpCasedName : TSGString;
begin
Result.FNames := nil;
Result.FComands := nil;
UpCasedName := SGUpCaseString(VName);
for Target in FTargets do
	if UpCasedName in Target.FNames then
		begin
		Result := Target;
		break;
		end;
end;

function TSGMakefileReader.IndexOfTarget(const VName : TSGString):TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
	UpCasedName : TSGString;
begin
UpCasedName := SGUpCaseString(VName);
Result := TargetCount();
if FTargets <> nil then
	for i := 0 to TargetCount() - 1 do
		if UpCasedName in FTargets[i].FNames then
			begin
			Result := i;
			break;
			end;
end;

operator Enumerator(const List : TSGMRIdentifierList): TSGMRIdentifierListEnumerator;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := TSGMRIdentifierListEnumerator.Create(List);
end;

operator Enumerator(const List : TSGMRConstantList): TSGMRConstantListEnumerator;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := TSGMRConstantListEnumerator.Create(List);
end;

operator Enumerator(const List : TSGMRTargetList): TSGMRTargetListEnumerator;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := TSGMRTargetListEnumerator.Create(List);
end;

constructor TSGMRTargetListEnumerator.Create(const List : TSGMRTargetList);
begin
FList := List;
FIndex := -1;
end;

function TSGMRTargetListEnumerator.GetCurrent(): TSGMRTarget;
begin
Result := FList[FIndex];
end;

function TSGMRTargetListEnumerator.MoveNext(): TSGBoolean;
begin
FIndex += 1;
Result := (FList <> nil) and (Length(FList) > FIndex);
end;

constructor TSGMRConstantListEnumerator.Create(const List : TSGMRConstantList);
begin
FList := List;
FIndex := -1;
end;

function TSGMRConstantListEnumerator.GetCurrent(): TSGMRConstant;
begin
Result := FList[FIndex];
end;

function TSGMRConstantListEnumerator.MoveNext(): TSGBoolean;
begin
FIndex += 1;
Result := (FList <> nil) and (Length(FList) > FIndex);
end;

constructor TSGMRIdentifierListEnumerator.Create(const List : TSGMRIdentifierList);
begin
FList := List;
FIndex := -1;
end;

function TSGMRIdentifierListEnumerator.GetCurrent(): TSGMRIdentifier;
begin
Result := FList[FIndex];
end;

function TSGMRIdentifierListEnumerator.MoveNext(): TSGBoolean;
begin
FIndex += 1;
Result := (FList <> nil) and (Length(FList) > FIndex);
end;

procedure TSGMakefileReader.Execute(const VTarget : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Target : TSGString;
	i, ii : TSGLongWord;
begin
RecombineIdentifiers();
Target := SGUpCaseString(VTarget);
i := TargetCount();
if VTarget = '' then
	i := 0
else if TargetCount() > 0 then
	for ii := 0 to TargetCount() - 1 do
		if Target in FTargets[ii].FNames then
			begin
			i := ii;
			break;
			end;
if i = TargetCount() then
	begin
	SGPrintEngineVersion();
	WriteLn('Error while make target "',VTarget,'"!');
	end
else if (FTargets[i].FComands <> nil) and (Length(FTargets[i].FComands) > 0) then
	begin
	for ii := 0 to High(FTargets[i].FComands) do
		//ExecuteProcess(FTargets[i].FComands[ii].FAbsoluteIdentifier,[]);
		SGRunComand(FTargets[i].FComands[ii].FAbsoluteIdentifier);
	end;
end;

function TSGMakefileReader.TargetCount() : TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FTargets = nil then
	Result := 0
else
	Result := Length(FTargets);
end;

function TSGMakefileReader.ConstantCount() : TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FConstants = nil then
	Result := 0
else
	Result := Length(FConstants);
end;

procedure TSGMakefileReader.Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii : TSGLongWord;
begin
System.WriteLn('Makefile "',FFileName,'", ',ConstantCount(),' constants, ',TargetCount(),' targets');
if ConstantCount() > 0 then
	begin
	System.WriteLn('Constants:');
	for i := 0 to ConstantCount() - 1 do
		begin
		System.WriteLn(' Constant ', i + 1, ' : "', FConstants[i].FName,'"');
		TextColor(4);System.Write('  Dependent ');TextColor(12);System.WriteLn(FConstants[i].FIdentifier.FDependentIdentifier);TextColor(7);
		TextColor(2);System.Write('  Absolute ' );TextColor(10);System.Write  (FConstants[i].FIdentifier.FAbsoluteIdentifier );TextColor(7);
		ReadLn();
		end;
	end;
if TargetCount() > 0 then
	begin
	System.WriteLn('Targets:');
	for i := 0 to TargetCount() - 1 do
		begin
		System.WriteLn(' Target ', i + 1, ' : "', SGStringFromStringList(FTargets[i].FNames,', '),'"');
		
		TextColor(4);
		if (FTargets[i].FComands <> nil) and (Length(FTargets[i].FComands) > 0) then
			for ii := 0 to High(FTargets[i].FComands) do
				System.WriteLn('  ', FTargets[i].FComands[ii].FDependentIdentifier);
		ReadLn();
		
		TextColor(2);
		if (FTargets[i].FComands <> nil) and (Length(FTargets[i].FComands) > 0) then
			for ii := 0 to High(FTargets[i].FComands) do
				System.WriteLn('  ', FTargets[i].FComands[ii].FAbsoluteIdentifier);
		ReadLn();
		
		TextColor(7);
		end;
	end;
end;

procedure TSGMakefileReader.SetConstant(const Name, Value : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	UpCasedName : TSGString;
	i : TSGUInt32;
begin
UpCasedName := SGUpCaseString(Name);
if (FConstants <> nil) and (Length(FConstants)>0) then
	begin
	for i := 0 to High(FConstants) do
		if FConstants[i].FName = UpCasedName then
			begin
			FConstants[i].FIdentifier.FDependentIdentifier := 
				Value;
			break;
			end;
	end;
end;

function TSGMakefileReader.GetConstant(S : TSGString;const IdentifierType : TSGMRIdentifierType = SGMRIdentifierTypeAbsolute): TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
Result := '';
S := SGUpCaseString(S);
if S = 'MAKE' then
	begin
	Result := '"' + SGGetApplicationFileName() + '"' + ' --make';
	end
else if (FConstants <> nil) and (Length(FConstants)>0) then
	begin
	for i := 0 to High(FConstants) do
		if FConstants[i].FName = S then
			begin
			if IdentifierType = SGMRIdentifierTypeAbsolute then
				Result := FConstants[i].FIdentifier.FAbsoluteIdentifier
			else
				Result := FConstants[i].FIdentifier.FDependentIdentifier;
			break;
			end;
	end;
end;

function TSGMakefileReader.ProcessString(const S : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function ReadIdentifier(i : TSGLongWord; out Identifier : TSGString) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function IdentifierCharacter(C : TSGChar) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
C := UpCase(C);
Result := ((C >= 'A') and (C <= 'Z')) or ((C >= '0') and (C <= '9')) or (C in ['_']);
end;

begin
Result := False;
Identifier := '';
if (Length(S) > i + 4) and (S[i] = '$') and (S[i+1] = '(')  then
	begin
	i += 2;
	while (S[i] <> ')') and (i <= Length(S)) do
		begin
		if IdentifierCharacter(S[i]) then
			Identifier += S[i]
		else
			break;
		i += 1;
		end;
	if S[i] = ')' then
		Result := True;
	end;
if Result = False then
	Identifier := '';
end;

var
	i : TSGLongWord;
	Identifier : TSGString;
begin
Result := '';
i := 1;
while i <= Length(S) do
	begin
	if (S[i] = '$') and ReadIdentifier(i, Identifier) then
		begin
		i += 3 + Length(Identifier);
		Result += GetConstant(Identifier);
		end
	else
		begin
		Result += S[i];
		i += 1;
		end;
	end;
end;

procedure TSGMakefileReader.RecombineIdentifiers();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii : TSGUInt32;
begin
if FConstants <> nil then
	if Length(FConstants) > 0 then
		for i := 0 to High(FConstants) do
			FConstants[i].FIdentifier.FAbsoluteIdentifier := 
				ProcessString(FConstants[i].FIdentifier.FDependentIdentifier);
if FTargets <> nil then
	if Length(FTargets) > 0 then
		for i := 0 to High(FTargets) do
			if FTargets[i].FComands <> nil then
				if Length(FTargets[i].FComands) > 0 then
					for ii := 0 to High(FTargets[i].FComands) do
						FTargets[i].FComands[ii].FAbsoluteIdentifier :=
							SGDeleteExcessSpaces(ProcessString(FTargets[i].FComands[ii].FDependentIdentifier))
end;

procedure TSGMakefileReader.Read();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream : TMemoryStream;
	S : TSGString;
begin
Stream := TMemoryStream.Create();
SGResourceFiles.LoadMemoryStreamFromFile(Stream, FFileName);
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	begin
	S := SGReadLnStringFromStream(Stream);
	if (StringTrimAll(S,' 	') <> '') and (Length(StringTrimLeft(S,'	')) + 1 = Length(S)) and (FTargets <> nil) and (Length(FTargets) > 0) then
		begin
		S := StringTrimLeft(S,'	');
		with FTargets[High(FTargets)] do
			begin
			if FComands = nil then
				SetLength(FComands, 1)
			else
				SetLength(FComands, Length(FComands) + 1);
			with FComands[High(FComands)] do
				begin
				FDependentIdentifier := StringTrimLeft(SGDeleteExcessSpaces(S),'@');
				FAbsoluteIdentifier := '';
				end;
			end;
		end
	else if ((StringWordCount(S,'=') = 2) or (((StringWordCount(S,'=') = 1) and (StringTrimRight(S,'=') + '=' = S)))) and (Length(StringTrimLeft(S,' 	')) = Length(S)) then
		begin
		if (FConstants = nil) then
			SetLength(FConstants, 1)
		else
			SetLength(FConstants, Length(FConstants) + 1);
		with FConstants[High(FConstants)] do
			begin
			FName := SGUpCaseString(StringWordGet(S,'=',1));
			FIdentifier.FDependentIdentifier := StringWordGet(S,'=',2);
			FIdentifier.FAbsoluteIdentifier := '';
			end;
		end
	else if (Length(StringTrimLeft(S,' 	')) = Length(S)) and (S = StringWordGet(S,':',1) + ':') then
		begin
		if FTargets = nil then
			SetLength(FTargets, 1)
		else
			SetLength(FTargets, Length(FTargets) + 1);
		with FTargets[High(FTargets)] do
			begin
			FComands := nil;
			FNames := SGStringListFromString(SGUpCaseString(StringWordGet(S,':',1)),', ');
			end;
		end
	else if StringTrimAll(S,' 	') = '' then
		begin
		end
	else
		begin
		WriteLn('Unknown string "',S,'"');
		end;
	end;
Stream.Destroy();
RecombineIdentifiers();
end;

constructor TSGMakefileReader.Create(const VFileName : TSGString);
begin
inherited Create();
FFileName := VFileName;
FConstants := nil;
FTargets := nil;
Read();
end;

destructor TSGMakefileReader.Destroy();
begin
SetLength(FConstants, 0);
SetLength(FTargets, 0);
inherited;
end;

end.
