{$MODE OBJFPC}
library SaGeLib;
uses
	crt
	,SaGeBase
	,SaGeFractals
	,SaGeImages
	;

function TSGImage_Create:TSGImage;cdecl;
begin
Result:=TSGImage.Create;
end;

procedure TSGImage_SetWay(Image:TSGImage;NewWay:PChar);cdecl;
begin
Image.Way:=SGStringToPChar(NewWay);
end;

procedure TSGImage_Loading(Image:TSGImage);cdecl;
begin
Image.Loading;
end;

procedure TSGImage_Destroy(Image:TSGImage);cdecl;
begin
Image.Destroy;
Image:=nil;
end;

procedure TSGImage_BindTexture(Image:TSGImage);cdecl;
begin
Image.BindTexture;
end;

procedure TSGImage_DisableTexture(Image:TSGImage);cdecl;
begin
Image.DisableTexture;
end;

function TSGImage_Texture(Image:TSGImage):LongWord;cdecl;
begin
Result:=Image.Texture;
end;

exports
	TSGImage_Create index 1,
	TSGImage_SetWay index 2,
	TSGImage_Destroy index 3,
	TSGImage_Loading index 4,
	TSGImage_BindTexture index 5,
	TSGImage_DisableTexture index 6,
	TSGImage_Texture index 7
	;

end.
