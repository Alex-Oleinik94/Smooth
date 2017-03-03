{$INCLUDE SaGe.inc}

unit SaGeFPSViewer;

interface

uses
	 SaGeBase
	,SaGeCommonClasses
	,SaGeFont
	;

type
	TSGFPSViewer = class;
	TSGFPSViewer = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
		procedure DeleteDeviceResources();override;
		procedure LoadDeviceResources();override;
			private
		FFont : TSGFont;
		FX, FY : TSGWord;
		FAlpha : TSGFloat32;

		FFrameArray : packed array of TSGWord;
		FFrameCount : TSGWord;
		FFrameIndex : TSGWord;
		FFrameReady : TSGBoolean;

		function FrameSum():TSGWord;inline;
			public
		property X : TSGWord read FX write FX;
		property Y : TSGWord read FY write FY;
		property Alpha : TSGFloat32 read FAlpha write FAlpha;
		end;

implementation

uses
	 SaGeFileUtils
	,SaGeRenderBase
	,SaGeStringUtils
	,SaGeCommonStructs
	;

function TSGFPSViewer.FrameSum():TSGWord;inline;
var
	i : TSGWord;
begin
Result := 0;
if FFrameCount <> 0 then
	begin
	if FFrameReady then
		for i := 0 to FFrameCount - 1 do
			Result += FFrameArray[i]
	else
		for i := 0 to FFrameIndex do
			Result += FFrameArray[i];
	end;
if Result = 0 then
	Result := 1;
end;

constructor TSGFPSViewer.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
LoadDeviceResources();
FFrameCount := 30;
SetLength(FFrameArray,FFrameCount);
FFrameIndex := 0;
FFrameReady := False;
FAlpha := 1;
end;

destructor TSGFPSViewer.Destroy();
begin
FFont.Destroy();
inherited;
end;

procedure TSGFPSViewer.DeleteDeviceResources();
begin
if FFont <> nil then
	begin
	FFont.Destroy();
	FFont := nil;
	end;
end;

procedure TSGFPSViewer.LoadDeviceResources();
begin
if FFont <> nil then
	begin
	FFont.Destroy();
	FFont := nil;
	end;
FFont := TSGFont.Create(SGFontDirectory + DirectorySeparator + {$IFDEF MOBILE}'Times New Roman.sgf'{$ELSE}'Tahoma.sgf'{$ENDIF});
FFont.Context := Context;
FFont.Loading();
end;

procedure TSGFPSViewer.Paint();
var
	FPSString : string = '';
	FPSValue : TSGReal = 0;
begin
FFrameArray[FFrameIndex] := Context.ElapsedTime;
FFrameIndex += 1;
if FFrameIndex = FFrameCount then
	begin
	FFrameIndex := 0;
	FFrameReady := True;
	end;
FPSValue := 100/(FrameSum()/(Real(FFrameCount)+0.01));
if FFrameReady or (FFrameIndex > 2) then
	FPSString := 'FPS ' + SGStrReal(FPSValue, 2)
else
	FPSString := 'FPS ?';
Render.InitMatrixMode(SG_2D);
if FPSValue >= 60 then
	Render.Color4f(0,1,0,FAlpha)
else
	Render.Color((60 - FPSValue) / 60 * SGVertex4fImport(1,0,0,FAlpha) + (FPSValue) / 60 * SGVertex4fImport(0,1,0,FAlpha));
FFont.DrawFontFromTwoVertex2f(FPSString,
	SGVertex2fImport(FX, FY),
	SGVertex2fImport(FX + FFont.StringLength(FPSString), FY + FFont.FontHeight),
	False, False);
end;

class function TSGFPSViewer.ClassName():TSGString;
begin
Result := 'FPS Viwer';
end;

end.
