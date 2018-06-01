{$INCLUDE SaGe.inc}

unit SaGeFractalSierpinskiCarpet;

interface

uses
	 SaGeBase
	,SaGeFractals
	,SaGeScreen
	,SaGeCommonClasses
	,SaGeCommonStructs
	,SaGeScreenHelper
	;

type
	TSGFractalSierpinskiCarpet=class(TSG3DFractal)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			public
		function RecQuantity(const ThisDepth : TSGUInt64) : TSGUInt64;
		procedure Calculate();override;
		procedure CalculateFromThread();
		procedure PushIndexes(var MeshID:LongWord;const v1,v2,v3,v4:TSGVertex2f;var FVertexIndex,FFaceIndex:LongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			protected
		FLD, FLDC : TSGScreenLabel;
		FBPD, FBMD : TSGButton;
		end;

implementation

uses
	 SaGeVertexObject
	,SaGeScreenBase
	,SaGeRenderBase
	,SaGeStringUtils
	;

class function TSGFractalSierpinskiCarpet.ClassName():TSGString;
begin
Result := 'Ковёр (квадрат) Серпинского';
end;

procedure TSGFractalSierpinskiCarpet.PushIndexes(var MeshID:LongWord;const v1, v2, v3, v4 : TSGVertex2f;var FVertexIndex,FFaceIndex:LongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FVertexIndex+=4;
if not (Render.RenderType in [SGRenderDirectX9, SGRenderDirectX8]) then
	begin
	FMesh.Objects[MeshID].ArVertex2f[FVertexIndex-4]^:=v1;
	FMesh.Objects[MeshID].ArVertex2f[FVertexIndex-3]^:=v2;
	FMesh.Objects[MeshID].ArVertex2f[FVertexIndex-2]^:=v3;
	FMesh.Objects[MeshID].ArVertex2f[FVertexIndex-1]^:=v4;
	end
else
	begin
	FMesh.Objects[MeshID].ArVertex3f[FVertexIndex-4]^.Import(v1.x,v1.y);
	FMesh.Objects[MeshID].ArVertex3f[FVertexIndex-3]^.Import(v2.x,v2.y);
	FMesh.Objects[MeshID].ArVertex3f[FVertexIndex-2]^.Import(v3.x,v3.y);
	FMesh.Objects[MeshID].ArVertex3f[FVertexIndex-1]^.Import(v4.x,v4.y);
	end;

FMesh.Objects[MeshID].SetFaceQuad(0,FFaceIndex+0,FVertexIndex-1,FVertexIndex-2,FVertexIndex-3,FVertexIndex-4);
FFaceIndex+=1;

AfterPushIndexes(MeshID,FThreadsEnable,FVertexIndex,FFaceIndex);
end;

procedure TSGFractalSierpinskiCarpet.CalculateFromThread();
var
	MeshID:LongWord;
	FVertexIndex,FFaceIndex:LongWord;
procedure Rec(const t1,t2:TSGVertex3f;const NowDepth:LongWord);
var
	a : TSGFloat64;
begin
a := Abs(t1.x - t2.x) / 3;
if NowDepth = 0 then
	PushIndexes(
		MeshID,
		SGVertex3fImport(t1.x, t1.y),
		SGVertex3fImport(t1.x, t2.y),
		SGVertex3fImport(t2.x, t2.y),
		SGVertex3fImport(t2.x, t1.y),
		FVertexIndex, FFaceIndex)
else if NowDepth = 1 then
	begin
	PushIndexes(MeshID,
		SGVertex3fImport(t1.x, t1.y),
		SGVertex3fImport(t1.x + a, t1.y),
		SGVertex3fImport(t1.x + a, t1.y + 3 * a),
		SGVertex3fImport(t1.x, t1.y + 3 * a),
		FVertexIndex, FFaceIndex);
	PushIndexes(MeshID,
		SGVertex3fImport(t1.x + a * 2, t1.y),
		SGVertex3fImport(t1.x + a * 3, t1.y),
		SGVertex3fImport(t1.x + a * 3, t1.y + 3 * a),
		SGVertex3fImport(t1.x + a * 2, t1.y + 3 * a),
		FVertexIndex, FFaceIndex);
	PushIndexes(MeshID,
		SGVertex3fImport(t1.x, t1.y),
		SGVertex3fImport(t1.x + a * 3, t1.y),
		SGVertex3fImport(t1.x + a * 3, t1.y + a),
		SGVertex3fImport(t1.x, t1.y + a),
		FVertexIndex, FFaceIndex);
	PushIndexes(MeshID,
		SGVertex3fImport(t1.x, t1.y + a * 2),
		SGVertex3fImport(t1.x + a * 3, t1.y + a * 2),
		SGVertex3fImport(t1.x + a * 3, t1.y + a * 3),
		SGVertex3fImport(t1.x, t1.y + a * 3),
		FVertexIndex, FFaceIndex);
	end
else
	begin
	Rec(SGVertex3fImport(t1.x, t1.y),
		SGVertex3fImport(t1.x + a, t1.y + a),
		NowDepth - 1);
	Rec(SGVertex3fImport(t1.x + a, t1.y),
		SGVertex3fImport(t1.x + a + a, t1.y + a),
		NowDepth - 1);
	Rec(SGVertex3fImport(t1.x + a + a, t1.y),
		SGVertex3fImport(t1.x + a + a + a, t1.y + a),
		NowDepth - 1);
	Rec(SGVertex3fImport(t1.x + a + a, t1.y + a),
		SGVertex3fImport(t1.x + a + a + a, t1.y + a + a),
		NowDepth - 1);
	Rec(SGVertex3fImport(t1.x + a + a, t1.y + a + a),
		SGVertex3fImport(t1.x + a + a + a, t1.y + a + a + a),
		NowDepth - 1);
	Rec(SGVertex3fImport(t1.x + a, t1.y + a + a),
		SGVertex3fImport(t1.x + a + a, t1.y + a + a + a),
		NowDepth - 1);
	Rec(SGVertex3fImport(t1.x, t1.y + a + a),
		SGVertex3fImport(t1.x + a, t1.y + a + a + a),
		NowDepth - 1);
	Rec(SGVertex3fImport(t1.x, t1.y + a),
		SGVertex3fImport(t1.x + a, t1.y + a + a),
		NowDepth - 1);
	end;
end;

begin
MeshID := 0;
FFaceIndex := 0;
FVertexIndex := 0;
Rec(SGVertex3fImport(-1, -1) * 4,
	SGVertex3fImport( 1,  1) * 4,
	FDepth);
if FThreadsEnable then
	if (MeshID>=0) and (MeshID<=FMesh.QuantityObjects-1) then
		if FMeshesInfo[MeshID]=SG_FALSE then
			FMeshesInfo[MeshID]:=SG_TRUE;
end;

procedure NewMengerThread(Klass:TSGFractalData) ;
begin
(Klass.FFractal as TSGFractalSierpinskiCarpet).CalculateFromThread();
Klass.FFractal.FThreadsData[Klass.FThreadID].FFinished:=True;
Klass.FFractal.FThreadsData[Klass.FThreadID].FData:=nil;
Klass.Destroy;
end;

procedure TSGFractalSierpinskiCarpet.Calculate();
var
	Quantity : TSGUInt64;
begin
inherited;
ClearMesh;
Quantity := RecQuantity(FDepth);
if Render.RenderType in [SGRenderDirectX9, SGRenderDirectX8] then 
	CalculateMeshes(Quantity,SGR_QUADS,SGMeshVertexType3f)
else
	CalculateMeshes(Quantity,SGR_QUADS,SGMeshVertexType2f);
if FThreadsEnable then
	begin
	FThreadsData[0].FFinished:=False;
	FThreadsData[0].FData:=nil;
	CalculateFromThread;
	end
else
	begin
	CalculateFromThread;
	if FEnableVBO and (not FMesh.LastObject().EnableVBO) then
		FMesh.LastObject().LoadToVBO();
	end;
end;

function TSGFractalSierpinskiCarpet.RecQuantity(const ThisDepth : TSGUInt64):TSGUInt64;
begin
if ThisDepth = 0 then
	Result := 1
else if ThisDepth = 1 then
	Result := 4
else
	Result := 8 * RecQuantity(ThisDepth - 1);
end;

procedure mmmFButtonDepthPlusOnChangeKT(Button:TSGButton);
begin
with TSGFractalSierpinskiCarpet(Button.FUserPointer1) do
	begin
	FDepth+=1;
	Calculate();
	FLD.Caption:=SGStr(Depth);
	FBMD.Active:=True;
	end;
end;

procedure mmmFButtonDepthMinusOnChangeKT(Button:TSGButton);
begin
with TSGFractalSierpinskiCarpet(Button.FUserPointer1) do
	begin
	if Depth>0 then
		begin
		FDepth-=1;
		Calculate();
		FLD.Caption:=SGStr(Depth);
		if Depth=0 then
			FBMD.Active:=False;
		end;
	end;
end;

constructor TSGFractalSierpinskiCarpet.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FEnableColors  := False;
FEnableNormals := False;
{$IFNDEF ANDROID}
	Threads:=1;
	{$ENDIF}
Depth:=3;
FLightingEnable := False;

InitProjectionComboBox(Render.Width-160,5,150,30,[SGAnchRight]);
Screen.LastChild.BoundsToNeedBounds();

InitSizeLabel(5,Render.Height-25,Render.Width-20,20,[SGAnchBottom]);
Screen.LastChild.BoundsToNeedBounds();

FLDC := SGCreateLabel(Screen, 'Итерация:', Render.Width-160-90-125,5,115,30, [SGAnchRight], True, True, Self);

FBPD:=TSGButton.Create;
Screen.CreateChild(FBPD);
Screen.LastChild.SetBounds(Render.Width-160-30,5,20,30);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Caption:='+';
Screen.LastChild.FUserPointer1:=Self;
FBPD.OnChange:=TSGComponentProcedure(@mmmFButtonDepthPlusOnChangeKT);
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsToNeedBounds();

FLD := SGCreateLabel(Screen, '0', Render.Width-160-60,5,20,30, [SGAnchRight], True, True, Self);

FBMD:=TSGButton.Create;
Screen.CreateChild(FBMD);
Screen.LastChild.SetBounds(Render.Width-160-90,5,20,30);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Caption:='-';
FBMD.OnChange:=TSGComponentProcedure(@mmmFButtonDepthMinusOnChangeKT);
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsToNeedBounds();

FLD.Caption:=SGStringToPChar(SGStr(Depth));

Calculate;
end;

destructor TSGFractalSierpinskiCarpet.Destroy;
begin
FBMD.Destroy();
FLD.Destroy();
FLDC.Destroy();
FBPD.Destroy();
inherited;
end;

end.
