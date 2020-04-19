{$INCLUDE Smooth.inc}

unit SmoothConsoleImageTools;

interface

uses
	 SmoothBase
	,SmoothConsoleHandler
	;

procedure SConsoleImageResizer                            (const VParams : TSConsoleHandlerParams = nil);
procedure SConsoleConvertImageToSmoothImageAlphaFormat    (const VParams : TSConsoleHandlerParams = nil);
procedure SConvertToSIA(const InFile, OutFile : TSString);

implementation

uses
	StrMan
	
	,SmoothVersion
	,SmoothResourceManager
	,SmoothImage
	,SmoothMultiImage
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothImageFormatDeterminer
	;

procedure SConvertToSIA(const InFile, OutFile : TSString);
var
	Image: TSImage = nil;
begin
Image := SCreateImageFromFile(nil, InFile); 
Image.FileName := OutFile;
Image.Save(SImageFormatSIA);
SKill(Image);
end;

procedure SConsoleConvertImageToSmoothImageAlphaFormat(const VParams : TSConsoleHandlerParams = nil);
begin
if (VParams <> nil) and (Length(VParams) = 1) and (
	(StringTrimLeft(SUpCaseString(VParams[0]), '-') = '?') or
	(StringTrimLeft(SUpCaseString(VParams[0]), '-') = 'H') or
	(StringTrimLeft(SUpCaseString(VParams[0]), '-') = 'HELP')) then
	begin
	SPrintEngineVersion();
	WriteLn('Convert image To Smooth Images Alpha format');
	WriteLn('Use "--CTSIA P1 P2"');
	WriteLn('   P1 - way to input file, for example "/images/qwerty/asdfgh.png"');
	WriteLn('   P2 - way to output file, for example "/images/qwerty/asdfgh.sgia"');
	end
else if (VParams = nil) or (Length(VParams)<2) then
	begin
	SPrintEngineVersion();
	WriteLn('Error count of parameters!');
	end
else if (VParams <> nil) and (Length(VParams) = 2) and SResourceFiles.FileExists(VParams[0]) then
	SConvertToSIA(VParams[0], VParams[1])
else
	begin
	SPrintEngineVersion();
	WriteLn('Error!');
	end;
end;

procedure SConsoleImageResizer(const VParams : TSConsoleHandlerParams = nil);
var
	Image : TSImage;
begin
if (SCountConsoleParams(VParams) = 3) and SResourceFiles.FileExists(VParams[0]) and (SVal(VParams[1]) > 0) and (SVal(VParams[2]) > 0)  then
	begin
	Image := SCreateImageFromFile(nil, VParams[0]);
	Image.BitMap.SetBounds(
		SVal(VParams[1]),
		SVal(VParams[2]));
	Image.FileName := SFreeFileName(Image.FileName);
	Image.Save();
	SKill(Image);
	end
else
	begin
	SPrintEngineVersion();
	WriteLn(SConsoleErrorString,'"@filename @new_width @new_height"!');
	end;
end;

end.
