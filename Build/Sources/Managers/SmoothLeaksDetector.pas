{$INCLUDE Smooth.inc}

unit SmoothLeaksDetector;

interface

uses
	 SmoothBase
	,SmoothLogStream
	
	,Classes
	;

type
	TSLeaksDetectorReference = object
			public
		FName : TSString;
		FCount : TSMaxEnum;
		FMaxCount : TSMaxEnum;
			public
		procedure CheckCount();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

	TSLeaksDetectorReferences = packed array of TSLeaksDetectorReference;

	TSLeaksDetector = class(TObject)
			public
		constructor Create();
		destructor Destroy(); override;
			protected
		FReferences : TSLeaksDetectorReferences;
			public
		procedure AddReference(const VName : TSString);
		procedure ReleaseReference(const VName : TSString);
		procedure WriteToLog();
		end;

var
	LeaksDetector : TSLeaksDetector = nil;

procedure SInitLeaksDetector();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SmoothStringUtils
	,SmoothLists
	,SmoothBaseUtils
	;

constructor TSLeaksDetector.Create();
begin
FReferences := nil;
end;

destructor TSLeaksDetector.Destroy();
begin
SetLength(FReferences, 0);
inherited;
end;

procedure TSLeaksDetectorReference.CheckCount();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FCount > FMaxCount then
	FMaxCount := FCount;
end;

procedure TSLeaksDetector.AddReference(const VName : TSString);

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
	f : TSBool = False;
	i : TSInt32;
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

procedure TSLeaksDetector.ReleaseReference(const VName : TSString);

procedure Error(const ErrorString : TSString);
begin
SLogWriteLn(SStr(['TSLeaksDetector : Error when releasing reference ''',VName,''' ',ErrorString]));
end;

var
	f : TSBool = False;
	i : TSInt32;
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

procedure TSLeaksDetector.WriteToLog();
var
	iii : TSInt32;

function ItemTitle(const IName : TSString):TSString;
var
	i : TSInt32;
begin
Result := IName;
for i := Length(IName) to iii do
	Result += ' ';
end;

var
	i, ii, {ln,} lc : TSInt32;
	SSS : TSStringList;
	SL : TSStringList;
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
			if Length(FReferences[i].FName + SStr(FReferences[i].FMaxCount)) + 2 > iii then
				iii := Length(FReferences[i].FName + SStr(FReferences[i].FMaxCount)) + 2;
			if FReferences[i].FCount <= 0 then
				SSS += FReferences[i].FName + '(' + SStr(FReferences[i].FMaxCount) + ')'
			else if Length(SStr(FReferences[i].FCount)) > lc then
				lc := Length(SStr(FReferences[i].FCount));
			end;
if ii = 0 then
	SLogWriteLn('TSLeaksDetector : Leaks not detected.')
else
	begin
	SLogWriteLn(SStr(['TSLeaksDetector : Total ', ii, ' leak', Iff(ii > 1, 's'), '.']));
	LogSignificant := True;
	SL := nil;
	if FReferences <> nil then
		if Length(FReferences) > 0 then
			for i := 0 to High(FReferences) do
				if FReferences[i].FCount > 0 then
					SL += (ItemTitle(FReferences[i].FName + '(' + SStr(FReferences[i].FMaxCount) + ')') + '- ' + SStr(FReferences[i].FCount));
	SLogWrite(SL, 'TSLeaksDetector : Leaks :');
	SetLength(SL, 0);
	end;
SLogWrite(SSS, 'TSLeaksDetector : Lines without references');
SetLength(SSS, 0);
end;

// ==================================
// ==================================
// ==================================

procedure SInitLeaksDetector();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if LeaksDetector = nil then
	LeaksDetector := TSLeaksDetector.Create();
end;

procedure SFinalizeLeaksDetector();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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
SInitLeaksDetector();
end;

finalization
begin
SFinalizeLeaksDetector();
end;

end.
