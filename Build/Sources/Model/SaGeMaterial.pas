{$INCLUDE SaGe.inc}

unit SaGeMaterial;

interface

uses
	 SaGeBase
	,SaGeCommonClasses
	,SaGeCommonStructs
	,SaGeImage
	,SaGeLog
	;
type
	TSGMaterial    = class;
	TSGBumpFormat = (SGBumpFormatNone, SGBumpFormatCopyTexture2f, SGBumpFormatCubeMap3f, SGBumpFormat2f);
	ISGMaterial = interface
		['{8f43802e-2c32-482e-b38f-f07d00e8ac11}']
		procedure SetColorAmbient(const r,g,b : TSGSingle);
		procedure SetColorSpecular(const r,g,b : TSGSingle);
		procedure SetColorDiffuse(const r,g,b : TSGSingle);
		
		procedure AddDiffuseMap(const VFileName : TSGString);
		procedure AddBumpMap(const VFileName : TSGString);
		
		procedure Bind(const BumpFormat : TSGBumpFormat; const HasTexture : TSGBoolean);
		procedure UnBind(const BumpFormat : TSGBumpFormat; const HasTexture : TSGBoolean);
		
		function GetName() : TSGString;
		
		property Name : TSGString read GetName;
		end;
	
	TSGMaterial = class (TSGDrawable, ISGMaterial)
			public
		constructor Create(const VContext : ISGContext);override;
		class function ClassName() : TSGString; override;
		destructor Destroy();override;
		procedure SetContext(const VContext : ISGContext); override;
			private
		FColorDiffuse, FColorSpecular, FColorAmbient : TSGColor4f;
		FIllum, FNS : TSGSingle;
		FMapDiffuse, FMapBump, FMapOpacity, FMapSpecular, FMapAmbient : TSGImage;
		FName : TSGString;
		FEnableBump, FEnableTexture : TSGBoolean;
			private
		FBlendPushed : TSGBoolean;
		FBlend : TSGBoolean;
			protected
		procedure PushBlend(const CurrentBlend : TSGBoolean);
		procedure PopBlend();
		function GetName() : TSGString;
		procedure SetImageTexture(const Image : TSGImage);
		procedure SetImageBump(const Image : TSGImage);
			public
		procedure SetColorAmbient(const r,g,b : TSGSingle);
		procedure SetColorSpecular(const r,g,b : TSGSingle);
		procedure SetColorDiffuse(const r,g,b : TSGSingle);
		procedure AddDiffuseMap(const VFileName : TSGString);
		procedure AddBumpMap(const VFileName : TSGString);
		function MapDiffusePath():TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function MapBumpPath():TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		procedure WriteInfo(const PredStr : TSGString = ''; const ViewError : TSGViewErrorType = [SGPrintError, SGLogError]);
			public
		procedure Bind(const BumpFormat : TSGBumpFormat; const HasTexture : TSGBoolean);
		procedure UnBind(const BumpFormat : TSGBumpFormat; const HasTexture : TSGBoolean);
			public
		property Name          : TSGString  read GetName        write FName;
		property Illum         : TSGSingle  read FIllum         write FIllum;
		property Ns            : TSGSingle  read FNS            write FNS;
		property EnableBump    : TSGBoolean read FEnableBump    write FEnableBump;
		property EnableTexture : TSGBoolean read FEnableTexture write FEnableTexture;
		property ImageBump     : TSGImage   read FMapBump       write SetImageBump;
		property ImageTexture  : TSGImage   read FMapDiffuse    write SetImageTexture;
		end;

implementation

uses
	 SaGeStringUtils,
	 SaGeRenderBase
	;

procedure TSGMaterial.SetContext(const VContext : ISGContext);

procedure SetContextToImage(var Image : TSGImage);
begin
if Image <> nil then
	Image.Context := Context;
end;

begin
inherited SetContext(VContext);
SetContextToImage(FMapDiffuse);
SetContextToImage(FMapBump);
SetContextToImage(FMapOpacity);
SetContextToImage(FMapSpecular);
SetContextToImage(FMapAmbient);
end;

procedure TSGMaterial.SetImageTexture(const Image : TSGImage);
begin
FEnableTexture := True;
FMapDiffuse := Image;
end;

procedure TSGMaterial.SetImageBump(const Image : TSGImage);
begin
FEnableBump := True;
FMapBump := Image;
end;

function TSGMaterial.GetName() : TSGString;
begin
Result := FName;
end;

procedure TSGMaterial.WriteInfo(const PredStr : TSGString = ''; const ViewError : TSGViewErrorType = [SGPrintError, SGLogError]);

procedure WriteImageInfo(const Image : TSGImage; const ImagePredStr : TSGString);
begin
if Image <> nil then
	if Image.Image <> nil then
		Image.Image.WriteInfo(ImagePredStr, ViewError);
end;

begin
SGHint(PredStr + 'TSGMaterial__WriteInfo(..)', ViewError);
SGHint([PredStr,'  Name                = "', FName, '"'], ViewError);
SGHint([PredStr,'  EnableTexture       = "', EnableTexture, '"'], ViewError);
SGHint([PredStr,'  EnableBump          = "', FEnableBump, '"'], ViewError);
SGHint([PredStr,'  MapDiffuse          = "', SGAddrStr(FMapDiffuse), '"'], ViewError);
WriteImageInfo(FMapDiffuse,  PredStr + '   d) ');
SGHint([PredStr,'  MapBump             = "', SGAddrStr(FMapBump), '"'], ViewError);
WriteImageInfo(FMapBump,     PredStr + '   b) ');
SGHint([PredStr,'  MapOpacity          = "', SGAddrStr(FMapOpacity), '"'], ViewError);
WriteImageInfo(FMapOpacity,  PredStr + '   o) ');
SGHint([PredStr,'  MapSpecular         = "', SGAddrStr(FMapSpecular), '"'], ViewError);
WriteImageInfo(FMapSpecular, PredStr + '   s) ');
SGHint([PredStr,'  MapAmbient          = "', SGAddrStr(FMapAmbient), '"'], ViewError);
WriteImageInfo(FMapAmbient,  PredStr + '   a) ');
end;

procedure TSGMaterial.PushBlend(const CurrentBlend : TSGBoolean);
var
	BlendEnabled : TSGBoolean = False;
begin
if FBlendPushed then
	PopBlend();
BlendEnabled := Render.IsEnabled(SGR_BLEND);
if CurrentBlend <> BlendEnabled then
	begin
	FBlendPushed := True;
	FBlend := CurrentBlend;
	if CurrentBlend then
		Render.Enable(SGR_BLEND)
	else
		Render.Disable(SGR_BLEND);
	end;
end;

procedure TSGMaterial.PopBlend();
begin
if FBlendPushed then
	begin
	if FBlend then
		Render.Enable(SGR_BLEND)
	else
		Render.Disable(SGR_BLEND);
	FBlend := False;
	FBlendPushed := False;
	end;
end;

constructor TSGMaterial.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FColorAmbient.Import(0,0,0,0);
FColorDiffuse.Import(0,0,0,0);
FColorSpecular.Import(0,0,0,0);
FEnableBump:=False;
FEnableTexture:=False;
FNS:=0;
FIllum:=0;
FName:='';
FMapAmbient:=nil;
FMapBump:=nil;
FMapDiffuse:=nil;
FMapOpacity:=nil;
FMapSpecular:=nil;
FBlendPushed := False;
FBlend := False;
end;

class function TSGMaterial.ClassName() : TSGString;
begin
Result := 'TSGMaterial';
end;

destructor TSGMaterial.Destroy();
begin
SGKill(FMapDiffuse);
SGKill(FMapBump);
SGKill(FMapOpacity);
SGKill(FMapSpecular);
SGKill(FMapAmbient);
inherited;
end;

procedure TSGMaterial.AddDiffuseMap(const VFileName : TSGString);
begin
FMapDiffuse:=TSGImage.Create();
FMapDiffuse.Context := Context;
FMapDiffuse.FileName := VFileName;
FEnableTexture := FMapDiffuse.Loading();
end;

procedure TSGMaterial.AddBumpMap(const VFileName : TSGString);
begin
FMapBump:=TSGImage.Create();
FMapBump.Context := Context;
FMapBump.FileName := VFileName;
FEnableBump := FMapBump.Loading();
end;

procedure TSGMaterial.Bind(const BumpFormat : TSGBumpFormat; const HasTexture : TSGBoolean);
begin
if (BumpFormat = SGBumpFormatNone) and (HasTexture) then
	begin
	if FEnableTexture and (FMapDiffuse<>nil) then
		begin
		FMapDiffuse.TextureNumber := -1;
		FMapDiffuse.TextureType := SGITextureTypeTexture;
		PushBlend(FMapDiffuse.HasAlpha);
		FMapDiffuse.BindTexture();
		end;
	end
else if (BumpFormat = SGBumpFormatCopyTexture2f) and (HasTexture) then
	begin
	if FEnableBump and (FMapBump<>nil) then
		begin
		FMapBump.TextureNumber := 0;
		FMapBump.TextureType := SGITextureTypeBump;
		FMapBump.BindTexture();
		FMapBump.TextureNumber := -1;
		FMapBump.TextureType := SGITextureTypeTexture;
		end;
	if FEnableTexture and (FMapDiffuse<>nil) then
		begin
		FMapDiffuse.TextureNumber := 1;
		FMapDiffuse.TextureType := SGITextureTypeTexture;
		PushBlend(FMapDiffuse.HasAlpha);
		FMapDiffuse.BindTexture();
		FMapDiffuse.TextureNumber := -1;
		end;
	end;
end;

procedure TSGMaterial.UnBind(const BumpFormat : TSGBumpFormat; const HasTexture : TSGBoolean);
begin
if (BumpFormat = SGBumpFormatNone) and (HasTexture) then
	begin
	if FEnableTexture and (FMapDiffuse<>nil) then
		begin
		FMapDiffuse.TextureNumber := -1;
		FMapDiffuse.TextureType := SGITextureTypeTexture;
		FMapDiffuse.DisableTexture();
		PopBlend();
		end;
	end
else if (BumpFormat = SGBumpFormatCopyTexture2f) and (HasTexture) then
	begin
	if FEnableBump and (FMapBump<>nil) then
		begin
		FMapBump.TextureNumber := 0;
		FMapBump.TextureType := SGITextureTypeBump;
		FMapBump.DisableTexture();
		FMapBump.TextureNumber := -1;
		FMapBump.TextureType := SGITextureTypeTexture;
		end;
	if FEnableTexture and (FMapDiffuse<>nil) then
		begin
		FMapDiffuse.TextureNumber := 1;
		FMapDiffuse.TextureType := SGITextureTypeTexture;
		FMapDiffuse.DisableTexture();
		PopBlend();
		FMapDiffuse.TextureNumber := -1;
		end;
	end;
end;

function TSGMaterial.MapDiffusePath():TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if FMapDiffuse<>nil then
	Result := FMapDiffuse.FileName
else
	Result := '';
end;

function TSGMaterial.MapBumpPath():TSGString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if FMapBump<>nil then
	Result := FMapBump.FileName
else
	Result := '';
end;

procedure TSGMaterial.SetColorAmbient(const r,g,b :TSGSingle);
begin
FColorAmbient.Import(r,g,b);
end;

procedure TSGMaterial.SetColorSpecular(const r,g,b :TSGSingle);
begin
FColorSpecular.Import(r,g,b);
end;

procedure TSGMaterial.SetColorDiffuse(const r,g,b :TSGSingle);
begin
FColorDiffuse.Import(r,g,b);
end;

end.
