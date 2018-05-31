{$INCLUDE SaGe.inc}

unit SaGeFractalPodkova;

interface

uses
	 SaGeBase
	,SaGeFractals
	,SaGeCommonStructs
	,SaGeCommonClasses
	,SaGeScreen
	;

type
	TSGFractalPodkova=class(TSG3DFractal)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
			public
		procedure Calculate;override;
		procedure CalculateFromThread();
		procedure PushIndexes(var MeshID:LongWord;const v:TSGVertex2f;var FVertexIndex:LongWord);Inline;
			protected
		FLD,FLDC:TSGLabel;
		FBPD,FBMD:TSGButton;
		FTCB:TSGComboBox;
		end;

implementation

uses
	 SaGeRenderBase
	,SaGeMathUtils
	,SaGeScreenBase
	,SaGeStringUtils
	,SaGeVertexObject
	,SaGeScreenHelper
	;

class function TSGFractalPodkova.ClassName() : TSGString;
begin
Result := 'Кривая Леви/Дракон Хартера';
end;

procedure TSGFractalPodkova.PushIndexes(var MeshID:LongWord;const v:TSGVertex2f;var FVertexIndex:LongWord);Inline;
begin
if Render.RenderType in [SGRenderDirectX9,SGRenderDirectX8] then
	FMesh.Objects[MeshID].ArVertex3f[FVertexIndex]^.Import(v.x,v.y)
else
	FMesh.Objects[MeshID].ArVertex2f[FVertexIndex]^:=v;

FVertexIndex+=1;

AfterPushIndexes(MeshID,FThreadsEnable,FVertexIndex);
end;

procedure TSGFractalPodkova.CalculateFromThread();
var
	MeshID:LongWord;
	FVI:LongWord;

procedure Rec(const t1,t2:TSGVertex2f;const NowDepth:LongWord;const b:integer = 1);
var
	V:TSGVertex3f;
//nu:	NewType:Byte;
begin
if NowDepth>0 then
	begin  
	V.Import(
		0.5*(b*t1.y-b*t2.y+t1.x+t2.x),
		0.5*(b*t2.x-b*t1.x+t1.y+t2.y));
	Rec(t1,v,NowDepth-1,1);
	if not Boolean(FTCB.SelectItem) then
		Rec(v,t2,NowDepth-1,1)
	else
		Rec(v,t2,NowDepth-1,-1);
	end
else
	PushIndexes(MeshID,t2,FVI);
end;

begin
MeshID:=0;
FVI:=0;
PushIndexes(MeshID,SGVertex2fImport(-3,-2),FVI);
if FDepth=0 then
	begin
	PushIndexes(MeshID,SGVertex2fImport(3,-2),FVI);
	end;
if FDepth>0 then
	begin
	Rec(SGVertex2fImport(-3,-2),SGVertex2fImport(3,-2),FDepth)
	end;
if FThreadsEnable then
	if (MeshID>=0) and (MeshID<=FMesh.QuantityObjects-1) then
		if FMeshesInfo[MeshID]=SG_FALSE then
			FMeshesInfo[MeshID]:=SG_TRUE;
end;

procedure NewPodkovaThread(Klass:TSGFractalData) ;
begin
(Klass.FFractal as TSGFractalPodkova).CalculateFromThread();
Klass.FFractal.FThreadsData[Klass.FThreadID].FFinished:=True;
Klass.FFractal.FThreadsData[Klass.FThreadID].FData:=nil;
Klass.Destroy;
end;

procedure TSGFractalPodkova.Calculate;
var
	Quantity:Int64;
begin
inherited;
ClearMesh;
Quantity:=(2**FDepth)+1;
if Render.RenderType in [SGRenderDirectX9,SGRenderDirectX8] then 
	CalculateMeshes(Quantity,SGR_LINE_STRIP,SGMeshVertexType3f)
else
	CalculateMeshes(Quantity,SGR_LINE_STRIP,SGMeshVertexType2f);
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

procedure PodkovammmFButtonDepthPlusOnChangeKT(Button:TSGButton);
begin
with TSGFractalPodkova(Button.FUserPointer1) do
	begin
	FDepth+=1;
	Calculate;
	FLD.Caption:=SGStringToPChar(SGStr(Depth));
	FBMD.Active:=True;
	end;
end;


procedure PodkovammmFButtonDepthMinusOnChangeKT(Button:TSGButton);
begin
with TSGFractalPodkova(Button.FUserPointer1) do
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

procedure TSGFractalPodkova_CamboBox_CallBackProcedure(a,b:LongInt;Button:TSGComponent);
begin
with TSGFractalPodkova(Button.FUserPointer1) do
	begin
	if a<>b then
		begin
		FTCB.SelectItem:=b;
		Calculate;
		end;
	end;
end;

constructor TSGFractalPodkova.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FEnableColors:=False;
FEnableNormals:=False;
{$IFNDEF ANDROID}
	Threads:=1;
	{$ENDIF}
Depth:=3;
FLightingEnable:=False;
HasIndexes := False;

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
FBPD.OnChange:=TSGComponentProcedure(@PodkovammmFButtonDepthPlusOnChangeKT);
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsToNeedBounds();

FLD := SGCreateLabel(Screen, '0', Render.Width-160-60,5,20,30, [SGAnchRight], True, True, Self);

FBMD:=TSGButton.Create;
Screen.CreateChild(FBMD);
Screen.LastChild.SetBounds(Render.Width-160-90,5,20,30);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Caption:='-';
FBMD.OnChange:=TSGComponentProcedure(@PodkovammmFButtonDepthMinusOnChangeKT);
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsToNeedBounds();

FTCB:=TSGComboBox.Create;
Screen.CreateChild(FTCB);
Screen.LastChild.SetBounds(Render.Width-160-90-125-130-50,5,125+50,20);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.AsComboBox.CreateItem('Кривая Леви');
Screen.LastChild.AsComboBox.CreateItem('Дракон Хартера — Хейтуэя');
Screen.LastChild.AsComboBox.CallBackProcedure:=TSGComboBoxProcedure(@TSGFractalPodkova_CamboBox_CallBackProcedure);
Screen.LastChild.AsComboBox.SelectItem:=0;
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsToNeedBounds();

FLD.Caption:=SGStringToPChar(SGStr(Depth));

Calculate();
end;

destructor TSGFractalPodkova.Destroy;
begin
FBMD.Destroy;
FLD.Destroy;
FLDC.Destroy;
FBPD.Destroy;
FTCB.Destroy;
inherited;
end;

end.
