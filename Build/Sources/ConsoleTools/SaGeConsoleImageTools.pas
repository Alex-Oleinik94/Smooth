{$INCLUDE SaGe.inc}

unit SaGeConsoleImageTools;

interface

uses
	 SaGeBase
	,SaGeConsoleToolsBase
	;

procedure SGConsoleImageResizer                          (const VParams : TSGConcoleCallerParams = nil);
procedure SGConsoleConvertImageToSaGeImageAlphaFormat    (const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	StrMan
	
	,SaGeVersion
	,SaGeResourceManager
	,SaGeImage
	,SaGeMultiImage
	,SaGeStringUtils
	,SaGeFileUtils
	;

procedure SGConsoleConvertImageToSaGeImageAlphaFormat(const VParams : TSGConcoleCallerParams = nil);
begin
if (VParams <> nil) and (Length(VParams) = 1) and (
	(StringTrimLeft(SGUpCaseString(VParams[0]), '-') = '?') or
	(StringTrimLeft(SGUpCaseString(VParams[0]), '-') = 'H') or
	(StringTrimLeft(SGUpCaseString(VParams[0]), '-') = 'HELP')) then
	begin
	SGPrintEngineVersion();
	WriteLn('Convert image To SaGe Images Alpha format');
	WriteLn('Use "--CTSGIA P1 P2"');
	WriteLn('   P1 - way to input file, for example "/images/qwerty/asdfgh.png"');
	WriteLn('   P2 - way to output file, for example "/images/qwerty/asdfgh.sgia"');
	end
else if (VParams = nil) or (Length(VParams)<2) then
	begin
	SGPrintEngineVersion();
	WriteLn('Error count of parameters!');
	end
else if (VParams <> nil) and (Length(VParams) = 2) and SGResourceFiles.FileExists(VParams[0]) then
	SGConvertToSGIA(VParams[0], VParams[1])
else
	begin
	SGPrintEngineVersion();
	WriteLn('Error!');
	end;
end;

procedure SGConsoleImageResizer(const VParams : TSGConcoleCallerParams = nil);
var
	Image:TSGImage;
begin
if (SGCountConsoleParams(VParams) = 3) and SGResourceFiles.FileExists(VParams[0]) and (SGVal(VParams[1]) > 0) and (SGVal(VParams[2]) > 0)  then
	begin
	Image := TSGImage.Create();
	Image.Way := VParams[0];
	Image.Loading();
	Image.Image.SetBounds(
		SGVal(VParams[1]),
		SGVal(VParams[2]));
	Image.Way := SGFreeFileName(Image.Way);
	Image.Saveing();
	Image.Destroy();
	end
else
	begin
	SGPrintEngineVersion();
	WriteLn(SGConsoleErrorString,'"@filename @new_width @new_height"!');
	end;
end;

end.
