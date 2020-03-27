//Вероятно, такая анимаия может плохо действовать на пользователя.
//Даже если пользователь смотрел на такую анимацию недолго.

{$INCLUDE Smooth.inc}

unit SmoothLoadingFrame;

interface

uses
	 SmoothBase
	,SmoothRenderBase
	,SmoothContextClasses
	,SmoothContextInterface
	;

type
	TSLoadingFrame = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
		procedure Paint(); override;
		class function Supported(const _Context : ISContext) : TSBoolean; override;
			private
		FX, FY, FWidth, FHeight : TSLongWord;
		FTime : TSFloat;
		FActive : TSBool;
		FRealLength : TSFloat;
		FMoveTime : TSFloat;
		FVisibleTimer : TSFloat;
		procedure UpdateVisibleTimer();
			public
		function PaintAt(const VX, VY, VW, VH : TSLongWord; const VActive : TSBool = True) : TSBoolean;
		property VisibleTimer : TSFloat write FVisibleTimer;
		end;

procedure SKill(var Waiting : TSLoadingFrame); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothMathUtils
	;

procedure SKill(var Waiting : TSLoadingFrame); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if Waiting <> nil then
	begin
	Waiting.Destroy();
	Waiting := nil;
	end;
end;

class function TSLoadingFrame.Supported(const _Context : ISContext) : TSBoolean;
begin
Result := True;
end;

function TSLoadingFrame.PaintAt(const VX, VY, VW, VH : TSLongWord; const VActive : TSBool = True) : TSBool;
begin
Result := False;
FX := VX;
FWidth := VW;
FHeight := VH;
FY := VY;
FActive := VActive;
UpdateVisibleTimer();
if FVisibleTimer > SZero then
	begin
	Paint();
	Result := True;
	end;
end;

constructor TSLoadingFrame.Create(const VContext : ISContext);
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

destructor TSLoadingFrame.Destroy();
begin
inherited;
end;

class function TSLoadingFrame.ClassName():TSString;
begin
Result := 'TSLoadingFrame';
end;

procedure TSLoadingFrame.UpdateVisibleTimer();
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

procedure TSLoadingFrame.Paint();
const
	Elapse = 0.1;
	Length = PI * 12;
	LoopLength = PI * 8 * 2;
	FixLength = PI * 4;
	TimeLength = LoopLength + FixLength;
var
	Angle : TSFloat = 0;
	FWD2,
	FWDD,
	FHD2,
	FHDD,
	FMX,
	FMY,
	LLC,
	PIC,
	FET
		: TSFloat;
begin
FET := Context.GetElapsedTime() / 5;
FMoveTime -= FET / 4;
if FRealLength < Length then
	FRealLength +=  FET
else
	FTime += FET;
{Render.Color3f(0,1,0);
Render.BeginScene(SR_TRIANGLES);
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
Render.BeginScene(SR_LINE_STRIP);
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
