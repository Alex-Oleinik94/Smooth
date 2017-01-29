{$INCLUDE SaGe.inc}

unit SaGeFileOpener;

interface
uses
	 Classes
	
	,SaGeBase
	,SaGeBased
	,SaGeClasses
	,SaGeCommonClasses
	,SaGeStringUtils
	;

type
	TSGFileOpenerDrawable = class;
	TSGFileOpenerDrawableClass = class of TSGFileOpenerDrawable;

	TSGFileOpener = class;
	TSGFileOpenerClass = class of TSGFileOpener;
	TSGFileOpener = class(TSGNamed)
			public
		class function ClassName() : TSGString; override;
		class function GetExpansions() : TSGStringList; virtual;
		class procedure Execute(const VFiles : TSGStringList);virtual;
		class function GetDrawableClass() : TSGFileOpenerDrawableClass;virtual;
		class function ExpansionsSuppored(const VExpansions : TSGStringList) : TSGBool; virtual;
		end;

	TSGFileOpenerDrawable = class (TSGDrawable)
			protected
		FFiles : TSGStringList;
			public
		destructor Destroy();override;
		constructor Create(const VContext : ISGContext);override;
		class function ClassName() : TSGString; override;
		procedure SetOption(const VName : TSGString; const VValue : TSGPointer);override;
		end;

procedure SGRegistryFileOpener(const VClass : TSGFileOpenerClass);
procedure SGTryOpenFiles(const VFiles : TSGStringList);
procedure SGWriteOpenableExpansions();

implementation

uses
	 SaGeVersion
	,SaGeContext
	,SaGeLog

	// Openers :
	,SaGeImageFileOpener
	,SaGeAudioFileOpener
	;

var
	SGFileOpeners : packed array of TSGFileOpenerClass = nil;

class function TSGFileOpener.ExpansionsSuppored(const VExpansions : TSGStringList) : TSGBool;
begin
Result := False;
end;

class function TSGFileOpener.GetDrawableClass() : TSGFileOpenerDrawableClass;
begin
Result := nil;
end;

procedure SGWriteOpenableExpansions();
var
	SL : TSGStringList = nil;
	SL2 : TSGStringList = nil;
	i, ii : TSGLongWord;

procedure Wrt(const S : TSGString);
begin
WriteLn('You may open files wich expansion(-s) is ',S,'.');
SGLog.Source(['Suppored to open files which expansion(-s) is ',S,'.']);
end;
begin
SGPrintEngineVersion();
if SGFileOpeners <> nil then if Length(SGFileOpeners) > 0 then
	for i := 0 to High(SGFileOpeners) do
		begin
		SL2 := SGFileOpeners[i].GetExpansions();
		if SL2 <> nil then if Length(SL2) > 0 then
			begin
			for ii := 0 to High(SL2) do
				SL *= SL2[ii];
			SetLength(SL2, 0);
			end;
		end;
Wrt(SGDownCaseString(SGStringFromStringList(SL,', ')));
end;

procedure TSGFileOpenerDrawable.SetOption(const VName : TSGString; const VValue : TSGPointer);
begin
if VName = 'FILES TO OPEN' then
	FFiles := TSGStringList(VValue)
else
	inherited;
end;

destructor TSGFileOpenerDrawable.Destroy();
begin
SetLength(FFiles, 0);
inherited;
end;

constructor TSGFileOpenerDrawable.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FFiles := nil;
end;

class function TSGFileOpenerDrawable.ClassName() : TSGString;
begin
Result := 'TSGFileOpenerDrawable';
end;

procedure SGTryOpenFiles(const VFiles : TSGStringList);
var
	C, EC : TSGFileOpenerClass;
	SL1 : TSGStringList;
	i : TSGLongWord;
	S : TSGString;

procedure Hint(const A : array of const);
var
	SL : TSGStringList;
	S : TSGString;
begin
SL := SGArConstToArString(A);
S := SGStringFromStringList(SL,'');
SGLog.Source(['SGTryOpenFiles returned hint:',SGWinEoln,S]);
WriteLn(S);
SetLength(SL, 0);
end;

begin
if VFiles = nil then
	Exit;
if Length(VFiles) = 0 then
	Exit;
EC := nil;
SL1 := nil;
for i := 0 to High(VFiles) do
	SL1 *= SGUpCaseString(SGGetFileExpansion(VFiles[i]));
for C in SGFileOpeners do
	if C.ExpansionsSuppored(SL1) then
		begin
		EC := C;
		break;
		end;
if EC <> nil then
	EC.Execute(VFiles)
else
	begin
	S := '';
	for i := 0 to High(VFiles) do
		begin
		S += '    ' + VFiles[i];
		if i <> High(VFiles) then
			S += SGWinEoln;
		end;
	Hint([
		'Can''t open file(-s):',SGWinEoln,S,SGWinEoln,
		'Which expansion(-s) is ',SGStringFromStringList(SL1,','),'.',SGWinEoln,
		'Error : Class which can open all of this expansions is missing!']);
	end;
SetLength(SL1, 0);
end;

procedure SGRegistryFileOpener(const VClass : TSGFileOpenerClass);
begin
if SGFileOpeners = nil then
	SetLength(SGFileOpeners, 1)
else
	SetLength(SGFileOpeners, Length(SGFileOpeners) + 1);
SGFileOpeners[High(SGFileOpeners)] := VClass;
end;

class function TSGFileOpener.ClassName() : TSGString;
begin
Result := 'TSGFileOpener';
end;

class procedure TSGFileOpener.Execute(const VFiles : TSGStringList);
begin
SGCompatibleRunPaintable(GetDrawableClass(), SGContextOptionImport('FILES TO OPEN', TSGPointer(VFiles)) + SGContextOptionMax());
end;

class function TSGFileOpener.GetExpansions() : TSGStringList;
begin
Result := nil;
end;

finalization
begin
SetLength(SGFileOpeners, 0);
end;
end.
