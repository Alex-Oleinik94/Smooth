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

implementation

uses
	 Registry
	
	,SaGeBaseUtils
	;

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
