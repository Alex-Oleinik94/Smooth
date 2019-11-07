{$INCLUDE SaGe.inc}

unit SaGeLoadingFrame;

interface

uses
	 SaGeBase
	,SaGeRenderBase
	,SaGeContextClasses
	,SaGeContextInterface
	;

type
	TSGLoadingFrame = class(TSGPaintableObject)
			public
		constructor Create(const VContext : ISGContext); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
		procedure Paint(); override;
		class function Supported(const _Context : ISGContext) : TSGBoolean; override;
			private
		FX, FY, FWidth, FHeight : TSGLongWord;
		FTime : TSGFloat;
		FActive : TSGBool;
		FRealLength : TSGFloat;
		FMoveTime : TSGFloat;
		FVisibleTimer : TSGFloat;
		procedure UpdateVisibleTimer();
			public
		function PaintAt(const VX, VY, VW, VH : TSGLongWord; const VActive : TSGBool = True) : TSGBoolean;
		property VisibleTimer : TSGFloat write FVisibleTimer;
		end;

procedure SGKill(var Waiting : TSGLoadingFrame); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeMathUtils
	;

procedure SGKill(var Waiting : TSGLoadingFrame); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if Waiting <> nil then
	begin
	Waiting.Destroy();
	Waiting := nil;
	end;
end;

class function TSGLoadingFrame.Supported(const _Context : ISGContext) : TSGBoolean;
begin
Result := True;
end;

function TSGLoadingFrame.PaintAt(const VX, VY, VW, VH : TSGLongWord; const VActive : TSGBool = True) : TSGBool;
begin
Result := False;
FX := VX;
FWidth := VW;
FHeight := VH;
FY := VY;
FActive := VActive;
UpdateVisibleTimer();
if FVisibleTimer > SGZero then
	begin
	Paint();
	Result := True;
	end;
end;

constructor TSGLoadingFrame.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FTime := 0;
FX := 0;
FWidth := 0;
FHeight := 0;
FY := 0;
FRealLength := 0;
FVisibleTimer := 1;
end;

destructor TSGLoadingFrame.Destroy();
begin
inherited;
end;

class function TSGLoadingFrame.ClassName():TSGString;
begin
Result := 'TSGLoadingFrame';
end;

procedure TSGLoadingFrame.UpdateVisibleTimer();
begin
if FActive then
	begin
	if FVisibleTimer < 1 then
		FVisibleTimer += Context.ElapsedTime / 50;
	if FVisibleTimer > 1 then
		FVisibleTimer := 1;
	end
else
	begin
	if FVisibleTimer > 0 then
		FVisibleTimer -= Context.ElapsedTime / 50;
	if FVisibleTimer < 0 then
		FVisibleTimer := 0;
	end;
end;

procedure TSGLoadingFrame.Paint();
const
	Elapse = 0.1;
	Length = PI * 12;
	LoopLength = PI * 8 * 2;
	FixLength = PI * 4;
	TimeLength = LoopLength + FixLength;
var
	Angle : TSGFloat = 0;
	FWD2,
	FWDD,
	FHD2,
	FHDD,
	FMX,
	FMY,
	LLC,
	PIC,
	FET
		: TSGFloat;
begin
FET := Context.GetElapsedTime() / 5;
FMoveTime -= FET / 4;
if FRealLength < Length then
	FRealLength +=  FET
else
	FTime += FET;
{Render.Color3f(0,1,0);
Render.BeginScene(SGR_TRIANGLES);
Render.Vertex2f(FX, FY);
Render.Vertex2f(FX+FWidth, FY);
Render.Vertex2f(FX+FWidth, FY+FHeight);
Render.EndScene();}
FWD2 := FWidth / 2;
FHD2 := FHeight / 2;
FHDD := FHeight / 14;
FWDD := FWidth / 14;
FMX := FX + FWD2;
FMY := FY + FHD2;
PIC := (PI * 2) / 8;
LLC := (LoopLength / PIC);
Render.Color4f(0,0,0,FVisibleTimer);
Render.BeginScene(SGR_LINE_STRIP);
if FTime > TimeLength then
	begin
	FTime -= TimeLength;
	end;
Angle := FTime + FMoveTime;
while Angle - FMoveTime < FTime + FRealLength do
	begin
	if (Angle - FMoveTime > TimeLength) then
		Render.Vertex2f(
			FMX + cos(Angle) * (FWDD + (Angle - FMoveTime - TimeLength) / PIC), 
			FMY + sin(Angle) * (FHDD + (Angle - FMoveTime - TimeLength) / PIC))
	else if (Angle - FMoveTime> LoopLength) then
		begin
		Render.Vertex2f(
			FMX + cos(Angle) * (FWDD + ((FixLength - (Angle - FMoveTime - LoopLength)) / FixLength) * LLC), 
			FMY + sin(Angle) * (FHDD + ((FixLength - (Angle - FMoveTime - LoopLength)) / FixLength) * LLC));
		end
	else
		Render.Vertex2f(
			FMX + cos(Angle) * (FWDD + (Angle - FMoveTime) / PIC ), 
			FMY + sin(Angle) * (FHDD + (Angle - FMoveTime) / PIC ));
	Angle += Elapse;
	end;
Render.EndScene();
end;

end.
