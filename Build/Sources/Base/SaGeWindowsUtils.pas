{$INCLUDE SaGe.inc}

unit SaGeWindowsUtils;

interface

uses
	 Classes
	,SysUtils
	,Windows
	
	,SaGeBase
	;

function SGWindowsVersion(): TSGString;
function SGWindowsRegistryRead(const VRootKey : HKEY; const VKey : TSGString; const VStringName : TSGString = '') : TSGString;
function SGSystemKeyPressed(const Index : TSGByte) : TSGBool;
function SGWinAPIQueschion(const VQuestion, VCaption : TSGString):TSGBoolean;
function SGKeyboardLayout(): TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 Registry
	
	,SaGeBaseUtils
	,SaGeStringUtils
	;

function SGKeyboardLayout(): TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Layout : array [0..kl_namelength] of TSGChar;
begin
GetKeyboardLayoutName(Layout);
if layout = '00000409' then
	Result := 'EN'
else
	Result := 'RU';
end;

function SGWinAPIQueschion(const VQuestion, VCaption : TSGString):TSGBoolean;
var
	PQuestion, PCaption : PSGChar;
begin
PQuestion := SGStringToPChar(VQuestion);
PCaption := SGStringToPChar(VCaption);
Result := MessageBox(0, PQuestion, PCaption, MB_YESNO OR MB_ICONQUESTION) <> IDNO;
SGPCharFree(PCaption);
SGPCharFree(PQuestion);
end;

function SGSystemKeyPressed(const Index : TSGByte) : TSGBool;
const
	KeyboardStateLength = 256;
var
	KeyboardState : PSGByte;
begin
GetMem(KeyboardState, KeyboardStateLength);
if GetKeyboardState(KeyboardState) then
	Result := TSGBoolean(KeyboardState[Index])
else
	Result := False;
FreeMem(KeyboardState, KeyboardStateLength);
end;

function SGWindowsRegistryRead(const VRootKey : HKEY; const VKey : TSGString; const VStringName : TSGString = '') : TSGString;
begin
with TRegistry.Create() do
	begin
	try
		RootKey := VRootKey;
		if OpenKeyReadOnly(VKey) then
			Result := ReadString(VStringName);
	finally
		Free;
	end;
	end;
end;

function SGWindowsVersion(): TSGString;
const
	VersionKey = '\SOFTWARE\Microsoft\Windows NT\CurrentVersion';
var
	ProductName : TSGString = '';
	CSDVersion : TSGString = '';
	CurrentBuild : TSGString = '';
	CurrentVersion : TSGString = '';
begin
Result := '';
ProductName := SGWindowsRegistryRead(HKEY_LOCAL_MACHINE, VersionKey, 'ProductName');
CSDVersion := SGWindowsRegistryRead(HKEY_LOCAL_MACHINE, VersionKey, 'CSDVersion');
CurrentBuild := SGWindowsRegistryRead(HKEY_LOCAL_MACHINE, VersionKey, 'CurrentBuild');
CurrentVersion := SGWindowsRegistryRead(HKEY_LOCAL_MACHINE, VersionKey, 'CurrentVersion');
if ProductName = '' then
	begin
	if CurrentVersion <> '' then
		Result += Iff(Result <> '', ' ') + 'Version ' + CurrentVersion;
	if CurrentBuild <> '' then
		Result += Iff(Result <> '', ' ') + 'Build ' + CurrentBuild;
	end
else
	begin
	Result := ProductName;
	if CSDVersion <> '' then
		Result += ' ' + CSDVersion;
	if CurrentBuild + CurrentVersion <> '' then
		begin
		Result += ' (';
		if CurrentVersion <> '' then
			Result += 'Version ' + CurrentVersion;
		if CurrentBuild <> '' then
			Result += Iff(CurrentVersion <> '', ' ') + 'Build ' + CurrentBuild;
		Result += ')';
		end;
	end;
end;

end.
