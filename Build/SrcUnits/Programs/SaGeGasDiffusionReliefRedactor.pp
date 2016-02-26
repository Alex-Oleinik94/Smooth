{$INCLUDE SaGe.inc}

unit SaGeGasDiffusionReliefRedactor;

interface

uses
	 dos
	,SaGeBase
	,Classes
	,SaGeBased
	,SaGeMesh
	,SaGeContext
	,SaGeRender
	,SaGeCommon
	,SaGeUtils
	,SaGeScreen
	,SaGeImages
	,SaGeImagesBase;
type
	TSGGasDiffusionSingleRelief = object
		FEnabled : Boolean;
		FPoints : packed array of TSGVertex;
		FPolygones : packed array of packed array of LongWord;
		
		procedure Draw(const VRender : TSGRender);
		procedure DrawLines(const VRender : TSGRender);
		procedure DrawPolygones(const VRender : TSGRender);
		procedure Clear();
		procedure InitBase();
		end;
type
	TSGGasDiffusionRelief = object
		FData : packed array [0..5] of TSGGasDiffusionSingleRelief;
		
		procedure Draw(const VRender : TSGRender);
		procedure Clear();
		procedure InitBase();
		end;
	PSGGasDiffusionSingleRelief = ^ TSGGasDiffusionSingleRelief;
	PSGGasDiffusionRelief = ^ TSGGasDiffusionRelief;
type
	TSGGasDiffusionReliefRedactor = class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		procedure Draw();override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		FRelief : PSGGasDiffusionRelief;
		FSingleRelief : PSGGasDiffusionSingleRelief;
			public
		procedure SetActiveSingleRelief(const index : LongInt = -1);
			public
		property Relief : PSGGasDiffusionRelief read FRelief write FRelief;
		end;

implementation

procedure TSGGasDiffusionSingleRelief.InitBase();
begin
FEnabled := False;
SetLength(FPoints,4);
SetLength(FPolygones,1);
SetLength(FPolygones[0],4);
FPoints[0].Import(1,1);
FPoints[1].Import(-1,1);
FPoints[2].Import(-1,-1);
FPoints[3].Import(1,-1);
FPolygones[0][0] := 0;
FPolygones[0][1] := 1;
FPolygones[0][2] := 2;
FPolygones[0][3] := 3;
end;

procedure TSGGasDiffusionSingleRelief.Draw(const VRender : TSGRender);
begin
DrawLines(VRender);
DrawPolygones(VRender);
end;

procedure TSGGasDiffusionSingleRelief.DrawLines(const VRender : TSGRender);
var
	i,ii:LongWord;
begin
if FPolygones <> nil then
	begin
	VRender.Color4f(0,0.5,1,1);
	for i := 0 to High(FPolygones) do
		begin
		VRender.BeginScene(SGR_LINE_LOOP);
		for ii := 0 to High(FPolygones[i]) do
			FPoints[FPolygones[i][ii]].Vertex(VRender);
		VRender.EndScene();
		end;
	end;
end;

procedure TSGGasDiffusionSingleRelief.DrawPolygones(const VRender : TSGRender);
var
	i,ii:LongWord;
begin
if (FPolygones <> nil) and FEnabled then
	begin
	VRender.Color4f(0,0.5,1,0.2);
	for i := 0 to High(FPolygones) do
		begin
		VRender.BeginScene(SGR_POLYGON);
		for ii := 0 to High(FPolygones[i]) do
			FPoints[FPolygones[i][ii]].Vertex(VRender);
		VRender.EndScene();
		end;
	end;
end;

procedure TSGGasDiffusionRelief.InitBase();
var
	i : LongWord;
begin
for i := 0 to 5 do
	begin
	FData[i].InitBase();
	end;
end;

procedure TSGGasDiffusionRelief.Draw(const VRender : TSGRender);
procedure InitMatrix(const i : byte);
begin
case i of
0 :  // верх
	begin 
	VRender.Translatef(0,1,0);
	VRender.Rotatef(90,1,0,0);
	end;
1 : // низ
	begin
	VRender.Translatef(0,-1,0);
	VRender.Rotatef(90,-1,0,0);
	end;
2 : // лево
	begin
	VRender.Translatef(-1,0,0);
	VRender.Rotatef(90,0,1,0);
	end;
3 : // право
	begin
	VRender.Translatef(1,0,0);
	VRender.Rotatef(90,0,-1,0);
	end;
4 : // зад
	begin
	VRender.Translatef(0,0,-1);
	VRender.Rotatef(90,0,0,-1);
	end;
5 : // перед
	begin
	VRender.Translatef(0,0,1);
	VRender.Rotatef(90,0,0,1);
	end;
end;
end;
var
	i : LongWord;
begin
for i := 0 to 5 do
	begin
	VRender.PushMatrix();
	InitMatrix(i);
	FData[i].DrawLines(VRender);
	VRender.PopMatrix();
	end;
for i := 0 to 5 do
	begin
	VRender.PushMatrix();
	InitMatrix(i);
	FData[i].DrawPolygones(VRender);
	VRender.PopMatrix();
	end;
end;

procedure TSGGasDiffusionSingleRelief.Clear();
var
	i : integer;
begin
SetLength(FPoints,0);
if FPolygones <> nil then
	for i := 0 to High(FPolygones) do
		SetLength(FPolygones[i],0);
SetLength(FPoints,0);
FEnabled := False;
end;

procedure TSGGasDiffusionRelief.Clear();
var
	i : Byte;
begin
for i := 0 to 5 do
	FData[i].Clear();
end;

procedure TSGGasDiffusionReliefRedactor.SetActiveSingleRelief(const index : LongInt = -1);
begin
if (index >= 0) and (index <= 5) then
	FSingleRelief := @FRelief^.FData[index]
else
	FSingleRelief := nil;
end;

constructor TSGGasDiffusionReliefRedactor.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FCamera := TSGCamera.Create();
FCamera.Context := Context;
FSingleRelief := nil;
FRelief := nil;
end;

procedure TSGGasDiffusionReliefRedactor.Draw();
begin
FCamera.CallAction();
if FSingleRelief = nil then
	begin
	FRelief^.Draw(Render);
	end
else if FRelief <> nil then
	begin
	FSingleRelief^.Draw(Render);
	end;
end;

destructor TSGGasDiffusionReliefRedactor.Destroy();
begin
inherited;
end;

class function TSGGasDiffusionReliefRedactor.ClassName():TSGString;
begin
Result := 'TSGGasDiffusionReliefRedactor';
end;

end.
