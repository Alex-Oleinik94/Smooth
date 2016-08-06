{$INCLUDE SaGe.inc}

unit SaGeScreenSkin;

interface

uses
	 Crt
	,SaGeCommon
	,SaGeBase
	,SaGeClasses
	,SaGeBased
	,SaGeImages
	,SaGeContext
	,SaGeUtils
	,SaGeRenderConstants
	,SaGeResourseManager
	,SaGeCommonClasses
	,SaGeScreenBase
	;

type
	TSGScreenSkinFrameColor = object
		FFirst  : TSGColor4f;
		FSecond : TSGColor4f;
		procedure Import(const VFirst, VSecond : TSGColor4f ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;
	
	TSGScreenSkinColors = object
		FNormal   : TSGScreenSkinFrameColor;
		FClick    : TSGScreenSkinFrameColor;
		FDisabled : TSGScreenSkinFrameColor;
		FOver     : TSGScreenSkinFrameColor;
		FText     : TSGScreenSkinFrameColor;
		procedure Import(const VNormal, VDisabled, VOver, VClick : TSGScreenSkinFrameColor);  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;
	
	TSGScreenSkin = class(TSGContextabled)
			public
		constructor Create(const VContext : ISGContext);override; 
		constructor Create(const VContext : ISGContext; const VColors : TSGScreenSkinColors);virtual;
		constructor CreateRandom(const VContext : ISGContext);virtual;
		destructor Destroy();override;
		class function ClassName() : TSGString;override;
		procedure IddleFunction(); virtual;
			private
		FColors : TSGScreenSkinColors;
			public
		property Colors : TSGScreenSkinColors read FColors write FColors;
			public
		procedure PaintButton(const VButton : ISGButton); virtual;
		end;

function SGScreenSkinColorsImport(const VNormal, VDisabled, VOver, VClick : TSGScreenSkinFrameColor) : TSGScreenSkinColors; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGScreenSkinFrameColorImport(const VFirst, VSecond : TSGColor4f ): TSGScreenSkinFrameColor; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStandartSkinColors() : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGenerateRandomSkinColors(const Colors : TSGScreenSkinColors) : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

function SGGenerateRandomSkinColors(const Colors : TSGScreenSkinColors) : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure SwapFloat(var a, b : TSGFloat);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	c : TSGFloat;
begin
c := a;
a := b;
b := c;
end;

begin
Result := Colors;
if Random(2) = 1 then
	begin
	SwapFloat(Result.FNormal.FFirst.x, Result.FNormal.FFirst.y);
	SwapFloat(Result.FNormal.FSecond.x, Result.FNormal.FSecond.y);
	
	SwapFloat(Result.FClick.FFirst.x, Result.FClick.FFirst.y);
	SwapFloat(Result.FClick.FSecond.x, Result.FClick.FSecond.y);
	
	SwapFloat(Result.FDisabled.FFirst.x, Result.FDisabled.FFirst.y);
	SwapFloat(Result.FDisabled.FSecond.x, Result.FDisabled.FSecond.y);
	
	SwapFloat(Result.FOver.FFirst.x, Result.FOver.FFirst.y);
	SwapFloat(Result.FOver.FSecond.x, Result.FOver.FSecond.y);
	end;
if Random(2) = 1 then
	begin
	SwapFloat(Result.FNormal.FFirst.x, Result.FNormal.FFirst.z);
	SwapFloat(Result.FNormal.FSecond.x, Result.FNormal.FSecond.z);
	
	SwapFloat(Result.FClick.FFirst.x, Result.FClick.FFirst.z);
	SwapFloat(Result.FClick.FSecond.x, Result.FClick.FSecond.z);
	
	SwapFloat(Result.FDisabled.FFirst.x, Result.FDisabled.FFirst.z);
	SwapFloat(Result.FDisabled.FSecond.x, Result.FDisabled.FSecond.z);
	
	SwapFloat(Result.FOver.FFirst.x, Result.FOver.FFirst.z);
	SwapFloat(Result.FOver.FSecond.x, Result.FOver.FSecond.z);
	end;
if Random(2) = 1 then
	begin
	SwapFloat(Result.FNormal.FFirst.z, Result.FNormal.FFirst.y);
	SwapFloat(Result.FNormal.FSecond.z, Result.FNormal.FSecond.y);
	
	SwapFloat(Result.FClick.FFirst.z, Result.FClick.FFirst.y);
	SwapFloat(Result.FClick.FSecond.z, Result.FClick.FSecond.y);
	
	SwapFloat(Result.FDisabled.FFirst.z, Result.FDisabled.FFirst.y);
	SwapFloat(Result.FDisabled.FSecond.z, Result.FDisabled.FSecond.y);
	
	SwapFloat(Result.FOver.FFirst.z, Result.FOver.FFirst.y);
	SwapFloat(Result.FOver.FSecond.z, Result.FOver.FSecond.y);
	end;
end;

procedure TSGScreenSkin.IddleFunction();
begin
end;

constructor TSGScreenSkin.CreateRandom(const VContext : ISGContext);
begin
Create(VContext, SGGenerateRandomSkinColors(SGStandartSkinColors()));
end;

function SGStandartSkinColors() : TSGScreenSkinColors;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.FNormal.FFirst.Import(0,1/2,1,1);
Result.FNormal.FSecond.Import(0,3/4,1,1);

Result.FClick.FFirst.Import(5/10,5/10,5/10,1);
Result.FClick.FSecond.Import(7/10,7/10,7/10,1);

Result.FDisabled.FFirst.Import(8/10,8/10,8/10,1);
Result.FDisabled.FSecond.Import(1,1,1,1);

Result.FOver.FFirst.Import(0,9/10,1,1);
Result.FOver.FSecond.Import(0,1,1,1);

Result.FText.FFirst.Import(1,1,1,1);
Result.FText.FSecond.Import(0,0,0,1);
end;

function SGScreenSkinColorsImport(const VNormal, VDisabled, VOver, VClick : TSGScreenSkinFrameColor) : TSGScreenSkinColors; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(VNormal, VDisabled, VOver, VClick);
end;

procedure TSGScreenSkinColors.Import(const VNormal, VDisabled, VOver, VClick : TSGScreenSkinFrameColor);  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FNormal   := VNormal;
FDisabled := VDisabled;
FOver     := VOver;
FClick    := VClick;
end;

function SGScreenSkinFrameColorImport(const VFirst, VSecond : TSGColor4f ):TSGScreenSkinFrameColor; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(VFirst, VSecond);
end;

procedure TSGScreenSkinFrameColor.Import(const VFirst, VSecond : TSGColor4f ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FFirst  := VFirst;
FSecond := FSecond;
end;

constructor TSGScreenSkin.Create(const VContext : ISGContext);
begin
Create(VContext, SGStandartSkinColors());
end;

constructor TSGScreenSkin.Create(const VContext : ISGContext; const VColors : TSGScreenSkinColors);
begin
inherited Create(VContext);
FColors := VColors;
end;

destructor TSGScreenSkin.Destroy();
begin
inherited;
end;

class function TSGScreenSkin.ClassName() : TSGString;
begin
Result := 'TSGScreenSkin';
end;

procedure TSGScreenSkin.PaintButton(const VButton : ISGButton);
begin

end;

end.
