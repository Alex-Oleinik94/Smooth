{$INCLUDE SaGe.inc}

unit SaGeLeaksDetector;

interface
uses
	SaGeBase
	,SaGeBased
	;
type
	TSGLeaksDetectorReference = object
			public
		FName : TSGString;
		FCount : TSGLongWord;
		end;

	TSGLeaksDetectorReferences = packed array of TSGLeaksDetectorReference;

	TSGLeaksDetector = class
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

implementation

constructor TSGLeaksDetector.Create();
begin
FReferences := nil;
end;

destructor TSGLeaksDetector.Destroy();
begin
SetLength(FReferences, 0);
inherited;
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
				f := True;
				break;
				end;
if not f then
	AddNew();
end;

procedure TSGLeaksDetector.ReleaseReference(const VName : TSGString);

procedure Error(const ErrorString : TSGString);
begin
SGLog.Sourse(['TSGLeaksDetector : Error when releasing reference ''',VName,''' ',ErrorString]);
end;

var
	f : TSGBool = False;
	i : TSGInt32;
begin
if VName = 'TSGDrawable' then
	SGPrintStackTrace();
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
Result := '"' + IName + '"';
for i := Length(IName) to iii do
	Result += ' ';
end;

var
	i, ii : TSGInt32;
	S : TSGString;
begin
S := '';
iii := 0;
ii := 0;
if FReferences <> nil then
	if Length(FReferences) > 0 then
		for i := 0 to High(FReferences) do
			begin
			ii += FReferences[i].FCount;
			if Length(FReferences[i].FName) > iii then
				iii := Length(FReferences[i].FName);
			if FReferences[i].FCount <= 0 then
				S += FReferences[i].FName + ';';
			end;
if ii = 0 then
	SGLog.Sourse(['TSGLeaksDetector : Leaks not detected.'])
else
	SGLog.Sourse(['TSGLeaksDetector : Total ',ii,' leaks.']);
if FReferences <> nil then
	if Length(FReferences) > 0 then
		for i := 0 to High(FReferences) do
			if FReferences[i].FCount > 0 then
				SGLog.Sourse(['   ',ItemTitle(FReferences[i].FName),' - ',FReferences[i].FCount,' references.']);
SGLog.Sourse(S,'TSGLeaksDetector : Lines without references',';');
S := '';
end;

initialization
begin
LeaksDetector := TSGLeaksDetector.Create();
end;

finalization
begin
LeaksDetector.WriteToLog();
LeaksDetector.Destroy();
LeaksDetector := nil;
end;

end.
