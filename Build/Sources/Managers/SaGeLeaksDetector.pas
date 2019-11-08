{$INCLUDE SaGe.inc}

unit SaGeLeaksDetector;

interface

uses
	 SaGeBase
	,SaGeLogStream
	
	,Classes
	;

type
	TSGLeaksDetectorReference = object
			public
		FName : TSGString;
		FCount : TSGMaxEnum;
		FMaxCount : TSGMaxEnum;
			public
		procedure CheckCount();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

	TSGLeaksDetectorReferences = packed array of TSGLeaksDetectorReference;

	TSGLeaksDetector = class(TObject)
			public
		constructor Create();
		destructor Destroy(); override;
			protected
		FReferences : TSGLeaksDetectorReferences;
			public
		procedure AddReference(const VName : TSGString);
		procedure ReleaseReference(const VName : TSGString);
		procedure WriteToLog();
		end;

var
	LeaksDetector : TSGLeaksDetector = nil;

procedure SGInitLeaksDetector();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeStringUtils
	,SaGeLists
	,SaGeBaseUtils
	;

constructor TSGLeaksDetector.Create();
begin
FReferences := nil;
end;

destructor TSGLeaksDetector.Destroy();
begin
SetLength(FReferences, 0);
inherited;
end;

procedure TSGLeaksDetectorReference.CheckCount();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FCount > FMaxCount then
	FMaxCount := FCount;
end;

procedure TSGLeaksDetector.AddReference(const VName : TSGString);

procedure AddNew();
begin
if FReferences = nil then
	SetLength(FReferences, 1)
else
	SetLength(FReferences, Length(FReferences) + 1);
FReferences[High(FReferences)].FName := VName;
FReferences[High(FReferences)].FCount := 1;
FReferences[High(FReferences)].FMaxCount := 1;
end;

var
	f : TSGBool = False;
	i : TSGInt32;
begin
f := False;
if FReferences <> nil then
	if Length(FReferences) > 0 then
		for i := 0 to High(FReferences) do
			if FReferences[i].FName = VName then
				begin
				FReferences[i].FCount += 1;
				FReferences[i].CheckCount();
				f := True;
				break;
				end;
if not f then
	AddNew();
end;

procedure TSGLeaksDetector.ReleaseReference(const VName : TSGString);

procedure Error(const ErrorString : TSGString);
begin
SGLogWriteLn(SGStr(['TSGLeaksDetector : Error when releasing reference ''',VName,''' ',ErrorString]));
end;

var
	f : TSGBool = False;
	i : TSGInt32;
begin
f := False;
if FReferences <> nil then
	if Length(FReferences) > 0 then
		for i := 0 to High(FReferences) do
			if FReferences[i].FName = VName then
				begin
				if FReferences[i].FCount > 0 then
					FReferences[i].FCount -= 1
				else
					Error(' - count not found!');
				f := True;
				break;
				end;
if not f then
	Error(' - line not found!');
end;

procedure TSGLeaksDetector.WriteToLog();
var
	iii : TSGInt32;

function ItemTitle(const IName : TSGString):TSGString;
var
	i : TSGInt32;
begin
Result := IName;
for i := Length(IName) to iii do
	Result += ' ';
end;

var
	i, ii, {ln,} lc : TSGInt32;
	SSS : TSGStringList;
	SL : TSGStringList;
begin
SSS := nil;
iii := 0;
ii := 0;
lc := 0;
if FReferences <> nil then
	if Length(FReferences) > 0 then
		for i := 0 to High(FReferences) do
			begin
			ii += FReferences[i].FCount;
			if Length(FReferences[i].FName + SGStr(FReferences[i].FMaxCount)) + 2 > iii then
				iii := Length(FReferences[i].FName + SGStr(FReferences[i].FMaxCount)) + 2;
			if FReferences[i].FCount <= 0 then
				SSS += FReferences[i].FName + '(' + SGStr(FReferences[i].FMaxCount) + ')'
			else if Length(SGStr(FReferences[i].FCount)) > lc then
				lc := Length(SGStr(FReferences[i].FCount));
			end;
if ii = 0 then
	SGLogWriteLn('TSGLeaksDetector : Leaks not detected.')
else
	begin
	SGLogWriteLn(SGStr(['TSGLeaksDetector : Total ', ii, ' leak', Iff(ii > 1, 's'), '.']));
	LogSignificant := True;
	SL := nil;
	if FReferences <> nil then
		if Length(FReferences) > 0 then
			for i := 0 to High(FReferences) do
				if FReferences[i].FCount > 0 then
					SL += (ItemTitle(FReferences[i].FName + '(' + SGStr(FReferences[i].FMaxCount) + ')') + '- ' + SGStr(FReferences[i].FCount));
	SGLogWrite(SL, 'TSGLeaksDetector : Leaks :');
	SetLength(SL, 0);
	end;
SGLogWrite(SSS, 'TSGLeaksDetector : Lines without references');
SetLength(SSS, 0);
end;

// ==================================
// ==================================
// ==================================

procedure SGInitLeaksDetector();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if LeaksDetector = nil then
	LeaksDetector := TSGLeaksDetector.Create();
end;

procedure SGFinalizeLeaksDetector();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if LeaksDetector <> nil then
	begin
	LeaksDetector.WriteToLog();
	LeaksDetector.Destroy();
	LeaksDetector := nil;
	end;
end;

initialization
begin
SGInitLeaksDetector();
end;

finalization
begin
SGFinalizeLeaksDetector();
end;

end.
