{$INCLUDE SaGe.inc}

unit SaGePackages;

interface

uses
	SaGeBase
	,SaGeBased
	,SaGeResourceManager
	,SaGeCommonClasses
	,SaGeCommonUtils
	
	,Classes
	;

procedure SGClearFileRegistrationPackages(const FileRegistrationPackages : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SGRegisterDrawClass(const ClassType : TSGDrawableClass; const Drawable : TSGBool = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetRegisteredDrawClasses() : TSGDrawClassesObjectList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	crt
	{$INCLUDE SaGeFileRegistrationPackages.inc}
	;

var
	PackagesDrawClasses : TSGDrawClassesObjectList = nil;

function SGGetRegisteredDrawClasses() : TSGDrawClassesObjectList;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := PackagesDrawClasses;
end;

procedure SGRegisterDrawClass(const ClassType : TSGDrawableClass; const Drawable : TSGBool = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if PackagesDrawClasses = nil then
	SetLength(PackagesDrawClasses, 1)
else
	SetLength(PackagesDrawClasses, Length(PackagesDrawClasses) + 1);
PackagesDrawClasses[High(PackagesDrawClasses)].FClass := ClassType;
PackagesDrawClasses[High(PackagesDrawClasses)].FDrawable := Drawable;
end;

procedure SGClearFileRegistrationPackages(const FileRegistrationPackages : TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Stream : TFileStream = nil;
begin
Stream := TFileStream.Create(FileRegistrationPackages, fmCreate);
SGWriteStringToStream('(*This is part of SaGe Engine*)'+SGWinEoln,Stream,False);
SGWriteStringToStream('//File registration packages. Packages:'+SGWinEoln,Stream,False);
Stream.Destroy();
end;

initialization
begin

end;

end.
