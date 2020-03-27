{$INCLUDE Smooth.inc}

unit SmoothMaterial;

interface

uses
	 SmoothBase
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothCommonStructs
	,SmoothImage
	,SmoothCasesOfPrint
	;
type
	TSMaterial    = class;
	TSBumpFormat = (SBumpFormatNone, SBumpFormatCopyTexture2f, SBumpFormatCubeMap3f, SBumpFormat2f);
	ISMaterial = interface
		['{8f43802e-2c32-482e-b38f-f07d00e8ac11}']
		procedure SetColorAmbient(const r,g,b : TSSingle);
		procedure SetColorSpecular(const r,g,b : TSSingle);
		procedure SetColorDiffuse(const r,g,b : TSSingle);
		
		procedure AddDiffuseMap(const VFileName : TSString);
		procedure AddBumpMap(const VFileName : TSString);
		
		procedure Bind(const BumpFormat : TSBumpFormat; const HasTexture : TSBoolean);
		procedure UnBind(const BumpFormat : TSBumpFormat; const HasTexture : TSBoolean);
		
		function GetName() : TSString;
		
		property Name : TSString read GetName;
		end;
	
	TSMaterial = class (TSContextObject, ISMaterial)
			public
		constructor Create(const VContext : ISContext);override;
		class function ClassName() : TSString; override;
		destructor Destroy();override;
		procedure SetContext(const VContext : ISContext); override;
			private
		FColorDiffuse, FColorSpecular, FColorAmbient : TSColor4f;
		FIllum, FNS : TSSingle;
		FMapDiffuse, FMapBump, FMapOpacity, FMapSpecular, FMapAmbient : TSImage;
		FName : TSString;
		FEnableBump, FEnableTexture : TSBoolean;
			private
		FBlendPushed : TSBoolean;
		FBlend : TSBoolean;
			protected
		procedure PushBlend(const CurrentBlend : TSBoolean);
		procedure PopBlend();
		function GetName() : TSString;
		procedure SetImageTexture(const Image : TSImage);
		procedure SetImageBump(const Image : TSImage);
			public
		procedure SetColorAmbient(const r,g,b : TSSingle);
		procedure SetColorSpecular(const r,g,b : TSSingle);
		procedure SetColorDiffuse(const r,g,b : TSSingle);
		procedure AddDiffuseMap(const VFileName : TSString);
		procedure AddBumpMap(const VFileName : TSString);
		function MapDiffusePath():TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		function MapBumpPath():TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
		procedure WriteInfo(const PredStr : TSString = ''; const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog]);
			public
		procedure Bind(const BumpFormat : TSBumpFormat; const HasTexture : TSBoolean);
		procedure UnBind(const BumpFormat : TSBumpFormat; const HasTexture : TSBoolean);
			public
		property Name          : TSString  read GetName        write FName;
		property Illum         : TSSingle  read FIllum         write FIllum;
		property Ns            : TSSingle  read FNS            write FNS;
		property EnableBump    : TSBoolean read FEnableBump    write FEnableBump;
		property EnableTexture : TSBoolean read FEnableTexture write FEnableTexture;
		property ImageBump     : TSImage   read FMapBump       write SetImageBump;
		property ImageTexture  : TSImage   read FMapDiffuse    write SetImageTexture;
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothRenderBase
	,SmoothLog
	;

procedure TSMaterial.SetContext(const VContext : ISContext);

procedure SetContextToImage(var Image : TSImage);
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

procedure TSMaterial.SetImageTexture(const Image : TSImage);
begin
FEnableTexture := True;
FMapDiffuse := Image;
end;

procedure TSMaterial.SetImageBump(const Image : TSImage);
begin
FEnableBump := True;
FMapBump := Image;
end;

function TSMaterial.GetName() : TSString;
begin
Result := FName;
end;

procedure TSMaterial.WriteInfo(const PredStr : TSString = ''; const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog]);

procedure WriteImageInfo(const Image : TSImage; const ImagePredStr : TSString);
begin
if Image <> nil then
	if (Image.BitMap <> nil) then
		Image.BitMap.WriteInfo(ImagePredStr, CasesOfPrint);
end;

begin
SHint(PredStr + 'TSMaterial__WriteInfo(..)', CasesOfPrint);
SHint([PredStr,'  Name                = "', FName, '"'], CasesOfPrint);
SHint([PredStr,'  EnableTexture       = "', EnableTexture, '"'], CasesOfPrint);
SHint([PredStr,'  EnableBump          = "', FEnableBump, '"'], CasesOfPrint);
SHint([PredStr,'  MapDiffuse          = "', SAddrStr(FMapDiffuse), '"'], CasesOfPrint);
WriteImageInfo(FMapDiffuse,  PredStr + '   d) ');
SHint([PredStr,'  MapBump             = "', SAddrStr(FMapBump), '"'], CasesOfPrint);
WriteImageInfo(FMapBump,     PredStr + '   b) ');
SHint([PredStr,'  MapOpacity          = "', SAddrStr(FMapOpacity), '"'], CasesOfPrint);
WriteImageInfo(FMapOpacity,  PredStr + '   o) ');
SHint([PredStr,'  MapSpecular         = "', SAddrStr(FMapSpecular), '"'], CasesOfPrint);
WriteImageInfo(FMapSpecular, PredStr + '   s) ');
SHint([PredStr,'  MapAmbient          = "', SAddrStr(FMapAmbient), '"'], CasesOfPrint);
WriteImageInfo(FMapAmbient,  PredStr + '   a) ');
end;

procedure TSMaterial.PushBlend(const CurrentBlend : TSBoolean);
var
	BlendEnabled : TSBoolean = False;
begin
if FBlendPushed then
	PopBlend();
BlendEnabled := Render.IsEnabled(SR_BLEND);
if CurrentBlend <> BlendEnabled then
	begin
	FBlendPushed := True;
	FBlend := CurrentBlend;
	if CurrentBlend then
		Render.Enable(SR_BLEND)
	else
		Render.Disable(SR_BLEND);
	end;
end;

procedure TSMaterial.PopBlend();
begin
if FBlendPushed then
	begin
	if FBlend then
		Render.Enable(SR_BLEND)
	else
		Render.Disable(SR_BLEND);
	FBlend := False;
	FBlendPushed := False;
	end;
end;

constructor TSMaterial.Create(const VContext : ISContext);
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

class function TSMaterial.ClassName() : TSString;
begin
Result := 'TSMaterial';
end;

destructor TSMaterial.Destroy();
begin
SKill(FMapDiffuse);
SKill(FMapBump);
SKill(FMapOpacity);
SKill(FMapSpecular);
SKill(FMapAmbient);
inherited;
end;

procedure TSMaterial.AddDiffuseMap(const VFileName : TSString);
begin
FMapDiffuse := SCreateImageFromFile(Context, VFileName, True);
FEnableTexture := FMapDiffuse.Loaded();
end;

procedure TSMaterial.AddBumpMap(const VFileName : TSString);
begin
FMapBump := SCreateImageFromFile(Context, VFileName, True);
FEnableBump := FMapBump.Loaded();
end;

procedure TSMaterial.Bind(const BumpFormat : TSBumpFormat; const HasTexture : TSBoolean);
begin
if (BumpFormat = SBumpFormatNone) and (HasTexture) then
	begin
	if FEnableTexture and (FMapDiffuse<>nil) then
		begin
		FMapDiffuse.TextureNumber := -1;
		FMapDiffuse.TextureType := SITextureTypeTexture;
		PushBlend(FMapDiffuse.HasAlpha);
		FMapDiffuse.BindTexture();
		end;
	end
else if (BumpFormat = SBumpFormatCopyTexture2f) and (HasTexture) then
	begin
	if FEnableBump and (FMapBump<>nil) then
		begin
		FMapBump.TextureNumber := 0;
		FMapBump.TextureType := SITextureTypeBump;
		FMapBump.BindTexture();
		FMapBump.TextureNumber := -1;
		FMapBump.TextureType := SITextureTypeTexture;
		end;
	if FEnableTexture and (FMapDiffuse<>nil) then
		begin
		FMapDiffuse.TextureNumber := 1;
		FMapDiffuse.TextureType := SITextureTypeTexture;
		PushBlend(FMapDiffuse.HasAlpha);
		FMapDiffuse.BindTexture();
		FMapDiffuse.TextureNumber := -1;
		end;
	end;
end;

procedure TSMaterial.UnBind(const BumpFormat : TSBumpFormat; const HasTexture : TSBoolean);
begin
if (BumpFormat = SBumpFormatNone) and (HasTexture) then
	begin
	if FEnableTexture and (FMapDiffuse<>nil) then
		begin
		FMapDiffuse.TextureNumber := -1;
		FMapDiffuse.TextureType := SITextureTypeTexture;
		FMapDiffuse.DisableTexture();
		PopBlend();
		end;
	end
else if (BumpFormat = SBumpFormatCopyTexture2f) and (HasTexture) then
	begin
	if FEnableBump and (FMapBump<>nil) then
		begin
		FMapBump.TextureNumber := 0;
		FMapBump.TextureType := SITextureTypeBump;
		FMapBump.DisableTexture();
		FMapBump.TextureNumber := -1;
		FMapBump.TextureType := SITextureTypeTexture;
		end;
	if FEnableTexture and (FMapDiffuse<>nil) then
		begin
		FMapDiffuse.TextureNumber := 1;
		FMapDiffuse.TextureType := SITextureTypeTexture;
		FMapDiffuse.DisableTexture();
		PopBlend();
		FMapDiffuse.TextureNumber := -1;
		end;
	end;
end;

function TSMaterial.MapDiffusePath():TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if FMapDiffuse<>nil then
	Result := FMapDiffuse.FileName
else
	Result := '';
end;

function TSMaterial.MapBumpPath():TSString; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
begin
if FMapBump<>nil then
	Result := FMapBump.FileName
else
	Result := '';
end;

procedure TSMaterial.SetColorAmbient(const r,g,b :TSSingle);
begin
FColorAmbient.Import(r,g,b);
end;

procedure TSMaterial.SetColorSpecular(const r,g,b :TSSingle);
begin
FColorSpecular.Import(r,g,b);
end;

procedure TSMaterial.SetColorDiffuse(const r,g,b :TSSingle);
begin
FColorDiffuse.Import(r,g,b);
end;

end.
