{$INCLUDE Smooth.inc}
library Smooth;
uses
	 Crt
	
	,SmoothBase
	,SmoothFractals
	,SmoothImages
	,SmoothConsoleTools
	,SmoothResourceManager
	;

function TSImage_Create:TSImage;cdecl;
begin
Result:=TSImage.Create;
end;

procedure TSImage_SetWay(Image:TSImage;NewWay:PChar);cdecl;
begin
Image.Way:=SStringToPChar(NewWay);
end;

procedure TSImage_Loading(Image:TSImage);cdecl;
begin
Image.Loading;
end;

procedure TSImage_Destroy(Image:TSImage);cdecl;
begin
Image.Destroy;
Image:=nil;
end;

procedure TSImage_BindTexture(Image:TSImage);cdecl;
begin
Image.BindTexture;
end;

procedure TSImage_DisableTexture(Image:TSImage);cdecl;
begin
Image.DisableTexture;
end;

function TSImage_Texture(Image:TSImage):LongWord;cdecl;
begin
Result:=Image.Texture;
end;

procedure SConcoleCaller(const VParams : TSConcoleCallerParams = nil);cdecl;
begin
SmoothConsoleTools.SConcoleCaller(VParams);
end;

exports
	TSImage_Create index 1,
	TSImage_SetWay index 2,
	TSImage_Destroy index 3,
	TSImage_Loading index 4,
	TSImage_BindTexture index 5,
	TSImage_DisableTexture index 6,
	TSImage_Texture index 7,
	SConcoleCaller
	;

initialization
begin

end;

finalization
begin

end;

end.
