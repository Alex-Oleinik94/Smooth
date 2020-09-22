{$INCLUDE Smooth.inc}

unit SmoothFPSViewer;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothFont
	;

type
	TSFPSViewer = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
		procedure DeleteRenderResources();override;
		procedure LoadRenderResources();override;
			private
		FFont : TSFont;
		FX, FY : TSUInt16;
		FAlpha : TSFloat32;

		FFrameArray : TSUInt16List;
		FFrameCount : TSUInt16;
		FFrameIndex : TSUInt16;
		FFrameReady : TSBoolean;

		function FrameSum():TSUInt16;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property X : TSUInt16 read FX write FX;
		property Y : TSUInt16 read FY write FY;
		property Alpha : TSFloat32 read FAlpha write FAlpha;
		end;

procedure SKill(var FPSViewer : TSFPSViewer); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothFileUtils
	,SmoothRenderBase
	,SmoothStringUtils
	,SmoothCommonStructs
	;

procedure SKill(var FPSViewer : TSFPSViewer); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (FPSViewer <> nil) then
	begin
	FPSViewer.Destroy();
	FPSViewer := nil;
	end;
end;

function TSFPSViewer.FrameSum():TSUInt16; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Index : TSUInt16;
begin
Result := 0;
if FFrameCount <> 0 then
	begin
	if FFrameReady then
		for Index := 0 to FFrameCount - 1 do
			Result += FFrameArray[Index]
	else
		for Index := 0 to FFrameIndex do
			Result += FFrameArray[Index];
	end;
if Result = 0 then
	Result := 1;
end;

constructor TSFPSViewer.Create(const VContext : ISContext);
begin
inherited Create(VContext);
LoadRenderResources();
FFrameCount := 30;
SetLength(FFrameArray,FFrameCount);
FFrameIndex := 0;
FFrameReady := False;
FAlpha := 1;
end;

destructor TSFPSViewer.Destroy();
begin
SKill(FFont);
inherited;
end;

procedure TSFPSViewer.DeleteRenderResources();
begin
if FFont <> nil then
	begin
	FFont.Destroy();
	FFont := nil;
	end;
end;

procedure TSFPSViewer.LoadRenderResources();
begin
if FFont <> nil then
	begin
	FFont.Destroy();
	FFont := nil;
	end;
FFont := SCreateFontFromFile(Context, SDefaultFontFileName);
end;

procedure TSFPSViewer.Paint();
var
	FPSString : string = '';
	FPSValue : TSReal = 0;
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
	FPSString := 'FPS ' + SStrReal(FPSValue, 2)
else
	FPSString := 'FPS ?';
Render.InitMatrixMode(S_2D);
if FPSValue >= 60 then
	Render.Color4f(0,1,0,FAlpha)
else
	Render.Color((60 - FPSValue) / 60 * SVertex4fImport(1,0,0,FAlpha) + (FPSValue) / 60 * SVertex4fImport(0,1,0,FAlpha));
FFont.DrawFontFromTwoVertex2f(FPSString,
	SVertex2fImport(FX, FY),
	SVertex2fImport(FX + FFont.StringLength(FPSString), FY + FFont.FontHeight),
	False, False);
end;

class function TSFPSViewer.ClassName():TSString;
begin
Result := 'FPS Viwer';
end;

end.
