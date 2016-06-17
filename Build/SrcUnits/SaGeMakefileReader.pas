{$INCLUDE SaGe.inc}

unit SaGeMakefileReader;

interface

uses
	 Classes
	,SaGeMath
	,SaGeBase
	,SaGeBased
	,StrMan
	,crt
	,SaGeVersion
	;

type
	TSGMRIdentifier = object
		FAbsoluteIdentifier  : TSGString;
		FDependentIdentifier : TSGString;
		end;
	
	TSGMRIdentifierList = packed array of TSGMRIdentifier;
	
	TSGMRConstant = object
		FName : TSGString;
		FIdentifier : TSGMRIdentifier;
		end;
	
	TSGMRConstantList = packed array of TSGMRConstant;
	
	TSGMRTarget = object
		FName : TSGString;
		FComands : TSGMRIdentifierList;
		end;
	
	TSGMRTargetList = packed array of TSGMRTarget;
	
	TSGMakefileReader = class(TSGClass)
			public
		constructor Create(const VFileName : TSGString);
		destructor Destroy();override;
			private
		FFileName  : TSGString;
		FConstants : TSGMRConstantList;
		FTargets   : TSGMRTargetList;
			private
		procedure Read();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ProcessString(const S : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetConstant(S : TSGString): TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function TargetCount() : TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ConstantCount() : TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		procedure Write();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Execute(const VTarget : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

implementation

procedure TSGMakefileReader.Execute(const VTarget : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Target : TSGString;
	i, ii : TSGLongWord;
begin
Target := SGUpCaseString(VTarget);
i := TargetCount();
if VTarget = '' then
	i := 0
else if TargetCount() > 0 then
	for ii := 0 to TargetCount() - 1 do
		if Target = FTargets[ii].FName then
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
		System.WriteLn(' Target ', i + 1, ' : "', FTargets[i].FName,'"');
		
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

function TSGMakefileReader.GetConstant(S : TSGString): TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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
			Result := FConstants[i].FIdentifier.FAbsoluteIdentifier;
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

procedure TSGMakefileReader.Read();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream : TMemoryStream;
	S : TSGString;
begin
Stream := TMemoryStream.Create();
Stream.LoadFromFile(FFileName);
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
				FAbsoluteIdentifier := SGDeleteExcessSpaces(ProcessString(FDependentIdentifier));
				end;
			end;
		end
	else if (StringWordCount(S,'=') = 2) and (Length(StringTrimLeft(S,' 	')) = Length(S)) then
		begin
		if (FConstants = nil) then
			SetLength(FConstants, 1)
		else
			SetLength(FConstants, Length(FConstants) + 1);
		with FConstants[High(FConstants)] do
			begin
			FName := SGUpCaseString(StringWordGet(S,'=',1));
			FIdentifier.FDependentIdentifier := StringWordGet(S,'=',2);
			FIdentifier.FAbsoluteIdentifier := ProcessString(FIdentifier.FDependentIdentifier);
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
			FName := SGUpCaseString(StringWordGet(S,':',1));
			end;
		end
	else if StringTrimAll(S,' 	') = '' then
		begin
		end
	else
		begin
		WriteLn('Unknown string "',S,'"');
		ReadLn();
		end;
	end;
Stream.Destroy();
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
