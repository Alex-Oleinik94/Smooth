{$INCLUDE SaGe.inc}

unit SaGeFractalKohTriangle;

interface

uses
	 SaGeBase
	,SaGeFractals
	,SaGeCommonStructs
	,SaGeCommonClasses
	,SaGeScreen
	;

type
	TSGFractalKohTriangle = class(TSG3DFractal)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			public
		function RecQuantity(const ThisDepth:Int64):Int64;
		procedure Calculate;override;
		procedure CalculateFromThread();
		procedure PushIndexes(var MeshID:LongWord;const v1,v2,v3:TSGVertex2f;var FVertexIndex,FFaceIndex:LongWord);Inline;
			protected
		FLD,FLDC:TSGLabel;
		FBPD,FBMD:TSGButton;
		end;

implementation

uses
	 SaGeRenderBase
	,SaGeStringUtils
	,SaGeMesh
	,SaGeScreenBase
	;

class function TSGFractalKohTriangle.ClassName():TSGString;
begin
Result := 'Треугольник Серпинского';
end;

procedure TSGFractalKohTriangle.PushIndexes(var MeshID:LongWord;const v1,v2,v3:TSGVertex2f;var FVertexIndex,FFaceIndex:LongWord);Inline;
begin
FVertexIndex+=3;
if not (Render.RenderType in [SGRenderDirectX9,SGRenderDirectX8]) then
	begin
	FMesh.Objects[MeshID].ArVertex2f[FVertexIndex-3]^:=v1;
	FMesh.Objects[MeshID].ArVertex2f[FVertexIndex-2]^:=v2;
	FMesh.Objects[MeshID].ArVertex2f[FVertexIndex-1]^:=v3;
	end
else
	begin
	FMesh.Objects[MeshID].ArVertex3f[FVertexIndex-3]^.Import(v1.x,v1.y);
	FMesh.Objects[MeshID].ArVertex3f[FVertexIndex-2]^.Import(v2.x,v2.y);
	FMesh.Objects[MeshID].ArVertex3f[FVertexIndex-1]^.Import(v3.x,v3.y);
	end;

FMesh.Objects[MeshID].SetFaceLine(0,FFaceIndex+0,FVertexIndex-1,FVertexIndex-2);
FMesh.Objects[MeshID].SetFaceLine(0,FFaceIndex+1,FVertexIndex-3,FVertexIndex-2);
FMesh.Objects[MeshID].SetFaceLine(0,FFaceIndex+2,FVertexIndex-1,FVertexIndex-3);
FFaceIndex+=3;

AfterPushIndexes(MeshID,FThreadsEnable,FVertexIndex,FFaceIndex);
end;

procedure TSGFractalKohTriangle.CalculateFromThread();
var
	MeshID:LongWord;
	FVertexIndex,FFaceIndex:LongWord;
procedure Rec(const t1,t2,t3:TSGVertex3f;const NowDepth:LongWord);
begin
PushIndexes(
	MeshID,
	(t1+t2)/2,
	(t3+t2)/2,
	(t1+t3)/2,
	FVertexIndex,FFaceIndex);
if NowDepth>1 then
	begin
	Rec(t1,(t1+t2)/2,(t1+t3)/2,NowDepth-1);
	Rec(t2,(t1+t2)/2,(t2+t3)/2,NowDepth-1);
	Rec(t3,(t3+t2)/2,(t1+t3)/2,NowDepth-1);
	end;
end;

begin
MeshID:=0;
FFaceIndex:=0;
FVertexIndex:=0;
PushIndexes(
	MeshID,
	SGVertex3fImport(cos(pi/2),sin(pi/2))*4,
	SGVertex3fImport(cos(pi/2+2*pi/3),sin(pi/2+2*pi/3))*4,
	SGVertex3fImport(cos(pi/2+4*pi/3),sin(pi/2+4*pi/3))*4,
	FVertexIndex,FFaceIndex);
if FDepth>0 then
	begin
	Rec(
		SGVertex3fImport(cos(pi/2),sin(pi/2))*4,
		SGVertex3fImport(cos(pi/2+2*pi/3),sin(pi/2+2*pi/3))*4,
		SGVertex3fImport(cos(pi/2+4*pi/3),sin(pi/2+4*pi/3))*4,
		FDepth)
	end;
if FThreadsEnable then
	if (MeshID>=0) and (MeshID<=FMesh.QuantityObjects-1) then
		if FMeshesInfo[MeshID]=SG_FALSE then
			FMeshesInfo[MeshID]:=SG_TRUE;
end;

procedure NewMengerThread(Klass:TSGFractalData) ;
begin
(Klass.FFractal as TSGFractalKohTriangle).CalculateFromThread();
Klass.FFractal.FThreadsData[Klass.FThreadID].FFinished:=True;
Klass.FFractal.FThreadsData[Klass.FThreadID].FData:=nil;
Klass.Destroy;
end;

procedure TSGFractalKohTriangle.Calculate();
var
	Quantity:Int64;
begin
inherited;
ClearMesh;
Quantity:=RecQuantity(FDepth);
if Render.RenderType in [SGRenderDirectX9,SGRenderDirectX8] then 
	CalculateMeshes(Quantity,SGR_LINES,SGMeshVertexType3f,1)
else
	CalculateMeshes(Quantity,SGR_LINES,SGMeshVertexType2f,1);
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

function TSGFractalKohTriangle.RecQuantity(const ThisDepth:Int64):Int64;
var
	i,ii:LongWord;
begin
Result:=3;
ii:=1;
if ThisDepth>=1 then
	for i:=1 to ThisDepth do
		begin
		ii*=3;
		Result+=ii;
		end;
end;

procedure mmmFButtonDepthPlusOnChangeKT(Button:TSGButton);
begin
with TSGFractalKohTriangle(Button.FUserPointer1) do
	begin
	FDepth+=1;
	Calculate;
	FLD.Caption:=SGStringToPChar(SGStr(Depth));
	FBMD.Active:=True;
	end;
end;


procedure mmmFButtonDepthMinusOnChangeKT(Button:TSGButton);
begin
with TSGFractalKohTriangle(Button.FUserPointer1) do
	begin
	if Depth>0 then
		begin
		FDepth-=1;
		Calculate;
		FLD.Caption:=SGStringToPChar(SGStr(Depth));
		if Depth=0 then
			FBMD.Active:=False;
		end;
	end;
end;

constructor TSGFractalKohTriangle.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FEnableColors:=False;
FEnableNormals:=False;
{$IFNDEF ANDROID}
	Threads:=1;
	{$ENDIF}
Depth:=3;
FLightingEnable:=False;

InitProjectionComboBox(Render.Width-160,5,150,30,[SGAnchRight]);
Screen.LastChild.BoundsToNeedBounds();

InitSizeLabel(5,Render.Height-25,Render.Width-20,20,[SGAnchBottom]);
Screen.LastChild.BoundsToNeedBounds();

FLDC:=TSGLabel.Create;
Screen.CreateChild(FLDC);
Screen.LastChild.SetBounds(Render.Width-160-90-125,5,115,30);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Caption:='Итерация:';
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsToNeedBounds();

FBPD:=TSGButton.Create;
Screen.CreateChild(FBPD);
Screen.LastChild.SetBounds(Render.Width-160-30,5,20,30);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Caption:='+';
Screen.LastChild.FUserPointer1:=Self;
FBPD.OnChange:=TSGComponentProcedure(@mmmFButtonDepthPlusOnChangeKT);
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsToNeedBounds();

FLD:=TSGLabel.Create;
Screen.CreateChild(FLD);
Screen.LastChild.SetBounds(Render.Width-160-60,5,20,30);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Caption:='0';
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsToNeedBounds();

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

destructor TSGFractalKohTriangle.Destroy;
begin
FBMD.Destroy;
FLD.Destroy;
FLDC.Destroy;
FBPD.Destroy;
inherited;
end;

end.
