{$INCLUDE SaGe.inc}

unit SaGeWindowsUtils;

interface

uses
	 Classes
	,SysUtils
	,Windows
	
	,SaGeBase
	,SaGeLog
	;

function SGWindowsVersion(): TSGString;
function SGWindowsRegistryRead(const VRootKey : HKEY; const VKey : TSGString; const VStringName : TSGString = '') : TSGString;
function SGSystemKeyPressed(const Index : TSGByte) : TSGBool;
function SGWinAPIQueschion(const VQuestion, VCaption : TSGString):TSGBoolean;
function SGKeyboardLayout(): TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGViewVideoDevices(const ViewType : TSGViewErrorType = [SGLogType, SGPrintType]);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 Registry
	,multimon
	,StrMan
	
	,SaGeBaseUtils
	,SaGeStringUtils
	;

procedure SGViewVideoDevices(const ViewType : TSGViewErrorType = [SGLogType, SGPrintType]);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Names : TSGStringList = nil;
	Paths : TSGStringList = nil;

procedure ConstructLists();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	lpDisplayDevice : TDisplayDevice;
	dwFlags : TSGLongWord;
	cc : TSGLongWord;
begin
lpDisplayDevice.cb := sizeof(lpDisplayDevice);
dwFlags := 0;
cc := 0;
while (EnumDisplayDevices(nil, cc, @lpDisplayDevice, dwFlags)) do
	begin
	Names += lpDisplayDevice.DeviceString;
	Paths += lpDisplayDevice.DeviceName;
	cc := cc + 1;
	end;
end;

const
	QuoteChar : TSGChar = '"';
var
	i, ml0, ml1, ml2, h : TSGMaxEnum;
begin
ConstructLists();
h := Min(High(Names), High(Paths));
if h <> 0 then
	begin
	ml0 := 0;
	ml1 := 0;
	ml2 := 0;
	for i := 0 to h do
		begin
		if Length(SGStr(i)) > ml0 then
			ml0 := Length(SGStr(i));
		if Length(Names[i]) > ml1 then
			ml1 := Length(Names[i]);
		if Length(Paths[i]) > ml2 then
			ml2 := Length(Paths[i]);
		end;
	ml1 += 3;
	ml2 += 3;
	SGHint('Display devices: (' + SGStr(h + 1) + ') --->', ViewType, True);
	for i := 0 to h do
		SGHint([
				'	#', 
				StringJustifyRight(SGStr(i), ml0, ' '),
				' - Name : ',
				StringJustifyLeft(QuoteChar + Names[i] + QuoteChar + ',', ml1, ' '),
				' Path : ',
				StringTrimAll(StringJustifyLeft(QuoteChar + Paths[i] + QuoteChar + Iff(i = h, '.', ';'), ml2, ' '), ' ')
			], ViewType);
	end
else
	SGHint('Display devices are not found!', ViewType, True);
SGKill(Names);
SGKill(Paths);
end;

function SGKeyboardLayout(): TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Layout : array [0..kl_namelength] of TSGChar;
begin
GetKeyboardLayoutName(Layout);
// HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts
if Layout = '00000409' then
	Result := 'EN'
else if Layout = '00000419' then
	Result := 'RU'
else
	Result := 'Unknown';
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
