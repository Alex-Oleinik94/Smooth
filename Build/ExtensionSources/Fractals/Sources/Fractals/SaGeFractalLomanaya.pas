{$INCLUDE SaGe.inc}

unit SaGeFractalLomanaya;

interface

uses
	 SaGeBase
	,SaGeFractals
	,SaGeCommonStructs
	,SaGeContextInterface
	,SaGeScreen
	,SaGeScreenClasses
	;

type
	TSGFractalLomanaya=class(TSG3DFractal)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			public
		procedure Calculate();override;
		procedure CalculateFromThread();
		procedure PushIndexes(var MeshID : TSGUInt32;const v : TSGVertex2f;var FVertexIndex:TSGUInt32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			protected
		FLD, FLDC : TSGScreenLabel;
		FBPD, FBMD : TSGScreenButton;
			protected
		c17, c27, c37, c57 : TSGFloat64;
		end;

implementation

uses
	 SaGeStringUtils
	,SaGeRenderBase
	,SaGeVertexObject
	,SaGeScreenBase
	,SaGeMathUtils
	;

class function TSGFractalLomanaya.ClassName():TSGString;
begin
Result := '������ ������������';
end;

procedure TSGFractalLomanaya.PushIndexes(var MeshID:LongWord;const v:TSGVertex2f;var FVertexIndex:LongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Render.RenderType in [SGRenderDirectX9,SGRenderDirectX8] then
	FMesh.Objects[MeshID].ArVertex3f[FVertexIndex]^.Import(v.x,v.y)
else
	FMesh.Objects[MeshID].ArVertex2f[FVertexIndex]^:=v;

FVertexIndex+=1;

AfterPushIndexes(MeshID,FThreadsEnable,FVertexIndex);
end;

procedure TSGFractalLomanaya.CalculateFromThread();
var
	MeshID:LongWord;
	FVI:LongWord;

procedure Rec(const t1,t2:TSGVertex2f;const NowDepth:LongWord);
var
	e1,e2,e3,v1,v2,v3,v4:TSGVertex2f;
begin
if NowDepth>0 then
	begin
	e1:=SGVertex2fImport(t2.y-t1.y,t1.x-t2.x)*0.25;
	e2:=t1+(t2-t1)*1/4;
	e3:=t1+(t2-t1)*3/4;
	v1:=e2-e1;
	v2:=v1+(t2-t1)*0.25;
	v4:=e3+e1;
	v3:=v4-(t2-t1)*0.25;
	Rec(t1,e2,NowDepth-1);
	Rec(e2,v1,NowDepth-1);
	Rec(v1,v2,NowDepth-1);
	Rec(v2,v3/2+v2/2,NowDepth-1);
	Rec(v2/2+v3/2,v3,NowDepth-1);
	Rec(v3,v4,NowDepth-1);
	Rec(v4,e3,NowDepth-1);
	Rec(e3,t2,NowDepth-1);
	end
else
	PushIndexes(MeshID,t2,FVI);
end;

begin
MeshID:=0;
FVI:=0;
PushIndexes(MeshID,SGVertex2fImport(-6,-3.5),FVI);
Rec(SGVertex2fImport(-6,-3.5),SGVertex2fImport(6,3.5),Depth);
if FThreadsEnable then
	if (MeshID>=0) and (MeshID<=FMesh.QuantityObjects-1) then
		if FMeshesInfo[MeshID]=SG_FALSE then
			FMeshesInfo[MeshID]:=SG_TRUE;
end;

procedure TSGFractalLomanaya.Calculate();
var
	Quantity:TSGMaxEnum;
begin
inherited;
ClearMesh();
Quantity:=(8**FDepth)+1;
if Render.RenderType in [SGRenderDirectX9,SGRenderDirectX8] then 
	CalculateMeshes(Quantity,SGR_LINE_STRIP,SGMeshVertexType3f)
else
	CalculateMeshes(Quantity,SGR_LINE_STRIP,SGMeshVertexType2f);
if FThreadsEnable then
	begin
	FThreadsData[0].FFinished:=False;
	FThreadsData[0].FData:=nil;
	CalculateFromThread();
	end
else
	begin
	CalculateFromThread();
	if FEnableVBO and (not FMesh.LastObject().EnableVBO) then
		FMesh.LastObject().LoadToVBO();
	end;
end;

procedure fgsdfghjsafhjsdgjfgshddsdsdaghfjdjshdrfjjssadjdsaqwrdcgaewdcfcafdcafewcwscdgdsf(Button:TSGScreenButton);
begin
with TSGFractalLomanaya(Button.FUserPointer1) do
	begin
	FDepth+=1;
	Calculate();
	FLD.Caption:=SGStringToPChar(SGStr(Depth));
	FBMD.Active:=True;
	end;
end;


procedure fgsdfghjsafhjsdgjfgshddsdsdasadjdsaqwrdcgaewdcfcafdcafewcwscdgdsf(Button:TSGScreenButton);
begin
with TSGFractalLomanaya(Button.FUserPointer1) do
	begin
	if Depth>0 then
		begin
		FDepth-=1;
		Calculate();
		FLD.Caption:=SGStringToPChar(SGStr(Depth));
		if FDepth=0 then
			FBMD.Active:=False;
		end;
	end;
end;

constructor TSGFractalLomanaya.Create(const VContext:ISGContext);
begin
inherited;
c17:=1/7;
c27:=2/7;
c37:=3/7;
c57:=5/7;

EnableColors:=False;
EnableNormals:=False;
{$IFNDEF ANDROID}
	Threads:=1;
	{$ENDIF}
Depth:=3;
LightingEnable:=False;
HasIndexes := False;

InitProjectionComboBox(Render.Width-160,5,150,30,[SGAnchRight]);
Screen.LastChild.BoundsMakeReal();

InitSizeLabel(5,Render.Height-25,Render.Width-20,20,[SGAnchBottom]);
Screen.LastChild.BoundsMakeReal();

FLDC := SGCreateLabel(Screen, '��������:', Render.Width-160-90-125,5,115,30, [SGAnchRight], True, True, Self);

FBPD:=TSGScreenButton.Create();
Screen.CreateChild(FBPD);
Screen.LastChild.SetBounds(Render.Width-160-30,5,20,30);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Caption:='+';
Screen.LastChild.FUserPointer1:=Self;
FBPD.OnChange:=TSGScreenComponentProcedure(@fgsdfghjsafhjsdgjfgshddsdsdaghfjdjshdrfjjssadjdsaqwrdcgaewdcfcafdcafewcwscdgdsf);
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FLD := SGCreateLabel(Screen, '0', Render.Width-160-60,5,20,30, [SGAnchRight], True, True, Self);

FBMD:=TSGScreenButton.Create();
Screen.CreateChild(FBMD);
Screen.LastChild.SetBounds(Render.Width-160-90,5,20,30);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Caption:='-';
FBMD.OnChange:=TSGScreenComponentProcedure(@fgsdfghjsafhjsdgjfgshddsdsdasadjdsaqwrdcgaewdcfcafdcafewcwscdgdsf);
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FLD.Caption:=SGStringToPChar(SGStr(Depth));

Calculate();
end;

destructor TSGFractalLomanaya.Destroy();
begin
FBMD.Destroy();
FLD.Destroy();
FLDC.Destroy();
FBPD.Destroy();
inherited;
end;

end.