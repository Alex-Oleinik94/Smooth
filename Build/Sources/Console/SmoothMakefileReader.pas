{$INCLUDE Smooth.inc}

unit SmoothMakefileReader;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothMath
	,SmoothBaseClasses
	;

type
	TSMRIdentifier = object
		FAbsoluteIdentifier  : TSString;
		FDependentIdentifier : TSString;
		end;
	
	TSMRIdentifierList = packed array of TSMRIdentifier;
	
	TSMRIdentifierListEnumerator = class
			private
		FList : TSMRIdentifierList;
		FIndex : TSLongInt;
			public
		constructor Create(const List : TSMRIdentifierList);
		function GetCurrent(): TSMRIdentifier;
		function MoveNext(): TSBoolean;
		property Current : TSMRIdentifier read GetCurrent;
		end;
	
	TSMRConstant = object
		FName : TSString;
		FIdentifier : TSMRIdentifier;
		end;
	
	TSMRConstantList = packed array of TSMRConstant;
	
	TSMRConstantListEnumerator = class
			private
		FList : TSMRConstantList;
		FIndex : TSLongInt;
			public
		constructor Create(const List : TSMRConstantList);
		function GetCurrent(): TSMRConstant;
		function MoveNext(): TSBoolean;
		property Current : TSMRConstant read GetCurrent;
		end;
	
	TSMRTarget = object
		FNames : TSStringList;
		FComands : TSMRIdentifierList;
		end;
	
	TSMRTargetList = packed array of TSMRTarget;
	
	TSMRTargetListEnumerator = class
			private
		FList : TSMRTargetList;
		FIndex : TSLongInt;
			public
		constructor Create(const List : TSMRTargetList);
		function GetCurrent(): TSMRTarget;
		function MoveNext(): TSBoolean;
		property Current : TSMRTarget read GetCurrent;
		end;
	
	TSMRIdentifierType = (
		SMRIdentifierTypeAbsolute,
		SMRIdentifierTypeDependent);
	
	TSMakefileReader = class(TSNamed)
			public
		constructor Create(const VFileName : TSString);
		destructor Destroy();override;
			private
		FFileName  : TSString;
		FConstants : TSMRConstantList;
		FTargets   : TSMRTargetList;
			public
		property FileName : TSString read FFileName;
			private
		procedure Read();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ProcessString(const S : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function IndexOfTarget(const VName : TSString):TSLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		procedure RecombineIdentifiers();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetConstant(S : TSString;const IdentifierType : TSMRIdentifierType = SMRIdentifierTypeAbsolute): TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetConstant(const Name, Value : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetTarget(const VIndex : TSLongWord):TSMRTarget;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetTarget(const VName : TSString):TSMRTarget;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function TargetCount() : TSLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ConstantCount() : TSLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		procedure Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Execute(const VTarget : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

operator Enumerator(const List : TSMRIdentifierList): TSMRIdentifierListEnumerator;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator Enumerator(const List : TSMRConstantList): TSMRConstantListEnumerator;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
operator Enumerator(const List : TSMRTargetList): TSMRTargetListEnumerator;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothStringUtils
	,SmoothStreamUtils
	,SmoothFileUtils
	,SmoothSysUtils
	,SmoothVersion
	,SmoothResourceManager
	
	,StrMan
	
	,Crt
	,Classes
	,SysUtils
	;

function TSMakefileReader.GetTarget(const VIndex : TSLongWord):TSMRTarget;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.FNames := nil;
Result.FComands := nil;
if (VIndex < TargetCount()) and (VIndex >= 0) then
	Result := FTargets[VIndex];
end;

function TSMakefileReader.GetTarget(const VName : TSString):TSMRTarget;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Target : TSMRTarget;
	UpCasedName : TSString;
begin
Result.FNames := nil;
Result.FComands := nil;
UpCasedName := SUpCaseString(VName);
for Target in FTargets do
	if UpCasedName in Target.FNames then
		begin
		Result := Target;
		break;
		end;
end;

function TSMakefileReader.IndexOfTarget(const VName : TSString):TSLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSLongWord;
	UpCasedName : TSString;
begin
UpCasedName := SUpCaseString(VName);
Result := TargetCount();
if FTargets <> nil then
	for i := 0 to TargetCount() - 1 do
		if UpCasedName in FTargets[i].FNames then
			begin
			Result := i;
			break;
			end;
end;

operator Enumerator(const List : TSMRIdentifierList): TSMRIdentifierListEnumerator;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := TSMRIdentifierListEnumerator.Create(List);
end;

operator Enumerator(const List : TSMRConstantList): TSMRConstantListEnumerator;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := TSMRConstantListEnumerator.Create(List);
end;

operator Enumerator(const List : TSMRTargetList): TSMRTargetListEnumerator;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := TSMRTargetListEnumerator.Create(List);
end;

constructor TSMRTargetListEnumerator.Create(const List : TSMRTargetList);
begin
FList := List;
FIndex := -1;
end;

function TSMRTargetListEnumerator.GetCurrent(): TSMRTarget;
begin
Result := FList[FIndex];
end;

function TSMRTargetListEnumerator.MoveNext(): TSBoolean;
begin
FIndex += 1;
Result := (FList <> nil) and (Length(FList) > FIndex);
end;

constructor TSMRConstantListEnumerator.Create(const List : TSMRConstantList);
begin
FList := List;
FIndex := -1;
end;

function TSMRConstantListEnumerator.GetCurrent(): TSMRConstant;
begin
Result := FList[FIndex];
end;

function TSMRConstantListEnumerator.MoveNext(): TSBoolean;
begin
FIndex += 1;
Result := (FList <> nil) and (Length(FList) > FIndex);
end;

constructor TSMRIdentifierListEnumerator.Create(const List : TSMRIdentifierList);
begin
FList := List;
FIndex := -1;
end;

function TSMRIdentifierListEnumerator.GetCurrent(): TSMRIdentifier;
begin
Result := FList[FIndex];
end;

function TSMRIdentifierListEnumerator.MoveNext(): TSBoolean;
begin
FIndex += 1;
Result := (FList <> nil) and (Length(FList) > FIndex);
end;

procedure TSMakefileReader.Execute(const VTarget : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Target : TSString;
	i, ii : TSLongWord;
begin
RecombineIdentifiers();
Target := SUpCaseString(VTarget);
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
	SPrintEngineVersion();
	WriteLn('Error while make target "',VTarget,'"!');
	end
else if (FTargets[i].FComands <> nil) and (Length(FTargets[i].FComands) > 0) then
	begin
	for ii := 0 to High(FTargets[i].FComands) do
		//ExecuteProcess(SCheckDirectorySeparators(FTargets[i].FComands[ii].FAbsoluteIdentifier), []);
		SRunComand(SCheckDirectorySeparators(FTargets[i].FComands[ii].FAbsoluteIdentifier));
	end;
end;

function TSMakefileReader.TargetCount() : TSLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FTargets = nil then
	Result := 0
else
	Result := Length(FTargets);
end;

function TSMakefileReader.ConstantCount() : TSLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FConstants = nil then
	Result := 0
else
	Result := Length(FConstants);
end;

procedure TSMakefileReader.Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii : TSLongWord;
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
		System.WriteLn(' Target ', i + 1, ' : "', SStringFromStringList(FTargets[i].FNames,', '),'"');
		
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

procedure TSMakefileReader.SetConstant(const Name, Value : TSString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	UpCasedName : TSString;
	i : TSMaxEnum;
	ConstantAdded : TSBoolean;
begin
UpCasedName := SUpCaseString(Name);
if (FConstants <> nil) and (Length(FConstants) > 0) then
	begin
	ConstantAdded := False;
	for i := 0 to High(FConstants) do
		if FConstants[i].FName = UpCasedName then
			begin
			FConstants[i].FIdentifier.FDependentIdentifier := 
				Value;
			ConstantAdded := True;
			end;
	if not ConstantAdded then
		begin
		if ConstantCount() = 0 then
			SetLength(FConstants, 1)
		else
			SetLength(FConstants, Length(FConstants) + 1);
		FConstants[High(FConstants)].FName := UpCasedName;
		FConstants[High(FConstants)].FIdentifier.FDependentIdentifier := Value;
		FConstants[High(FConstants)].FIdentifier.FAbsoluteIdentifier := '';
		end;
	end;
end;

function TSMakefileReader.GetConstant(S : TSString;const IdentifierType : TSMRIdentifierType = SMRIdentifierTypeAbsolute): TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSLongWord;
begin
Result := '';
S := SUpCaseString(S);
if S = 'MAKE' then
	begin
	Result := '"' + SApplicationFileName() + '"' + ' --make';
	end
else if (FConstants <> nil) and (Length(FConstants)>0) then
	begin
	for i := 0 to High(FConstants) do
		if FConstants[i].FName = S then
			begin
			if IdentifierType = SMRIdentifierTypeAbsolute then
				Result := FConstants[i].FIdentifier.FAbsoluteIdentifier
			else
				Result := FConstants[i].FIdentifier.FDependentIdentifier;
			break;
			end;
	end;
end;

function TSMakefileReader.ProcessString(const S : TSString) : TSString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function ReadIdentifier(i : TSLongWord; out Identifier : TSString) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function IdentifierCharacter(C : TSChar) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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
	i : TSLongWord;
	Identifier : TSString;
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

procedure TSMakefileReader.RecombineIdentifiers();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii : TSUInt32;
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
							SDeleteExcessSpaces(ProcessString(FTargets[i].FComands[ii].FDependentIdentifier))
end;

procedure TSMakefileReader.Read();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream : TMemoryStream;
	S : TSString;
begin
Stream := TMemoryStream.Create();
SResourceFiles.LoadMemoryStreamFromFile(Stream, FFileName);
Stream.Position := 0;
while Stream.Position <> Stream.Size do
	begin
	S := SReadLnStringFromStream(Stream);
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
				FDependentIdentifier := StringTrimLeft(SDeleteExcessSpaces(S),'@');
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
			FName := SUpCaseString(StringWordGet(S,'=',1));
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
			FNames := SStringListFromString(SUpCaseString(StringWordGet(S,':',1)),', ');
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

constructor TSMakefileReader.Create(const VFileName : TSString);
begin
inherited Create();
FFileName := VFileName;
FConstants := nil;
FTargets := nil;
Read();
end;

destructor TSMakefileReader.Destroy();
begin
SetLength(FConstants, 0);
SetLength(FTargets, 0);
inherited;
end;

end.
