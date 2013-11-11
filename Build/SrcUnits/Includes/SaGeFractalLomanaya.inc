
{$IFDEF SGREADINTERFACE}
type
	TSGFractalLomanaya=class(TSG3DFractal)
			public
		constructor Create(const VContext:PSGContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
			public
		procedure Calculate;override;
		procedure CalculateFromThread();
		procedure PushIndexes(var MeshID:LongWord;const v:TSGVertex2f;var FVertexIndex,FFaceIndex:LongWord);Inline;
			public
		FLD,FLDC:TSGLabel;
		FBPD,FBMD:TSGButton;
			public
		c17,c27,c37,c57:real;
		end;
{$ENDIF}


{$IFDEF SGREADIMPLEMENTATION}

class function TSGFractalLomanaya.ClassName:string;
begin
Result:='Кривая Миньковского';
end;


procedure TSGFractalLomanaya.PushIndexes(var MeshID:LongWord;const v:TSGVertex2f;var FVertexIndex,FFaceIndex:LongWord);Inline;
begin
FMesh.ArObjects[MeshID].ArVertex2f[FVertexIndex]^:=v;
FMesh.ArObjects[MeshID].ArFacesPoints[FFaceIndex].p[0]:=FVertexIndex;

FFaceIndex+=1;
FVertexIndex+=1;

AfterPushIndexes(MeshID,FThreadsEnable,FVertexIndex,FFaceIndex);
end;

procedure TSGFractalLomanaya.CalculateFromThread();
var
	MeshID:LongWord;
	FVI,FFI:LongWord;

procedure Rec(const t1,t2:TSGVertex2f;const NowDepth:LongWord);
var
	e1,e2,e3,v1,v2,v3,v4:TSGVertex2f;
begin
if NowDepth>0 then
	begin
	e1:=SGVertexImport(t2.y-t1.y,t1.x-t2.x)*0.25;
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
	PushIndexes(MeshID,t2,FVI,FFI);
end;

begin
MeshID:=0;
FFI:=0;
FVI:=0;
PushIndexes(MeshID,SGVertex2fImport(-6,-3.5),FVI,FFI);
Rec(SGVertex2fImport(-6,-3.5),SGVertex2fImport(6,3.5),Depth);
if FThreadsEnable then
	if (MeshID>=0) and (MeshID<=FMesh.NOfObjects-1) then
		if FMeshesInfo[MeshID]=SG_FALSE then
			FMeshesInfo[MeshID]:=SG_TRUE;
end;

procedure TSGFractalLomanaya.Calculate();
var
	Quantity:Int64;
begin
inherited;
ClearMesh();
Quantity:=(9**FDepth)+1;
if Render.RenderType = SGRenderDirectX then 
	CalculateMeshes(Quantity,SGR_LINE_STRIP,TSGMeshVertexType3f)
else
	CalculateMeshes(Quantity,SGR_LINE_STRIP,TSGMeshVertexType2f);
if FThreadsEnable then
	begin
	FThreadsData[0].FFinished:=False;
	FThreadsData[0].FData:=nil;
	CalculateFromThread();
	end
else
	begin
	CalculateFromThread();
	if FEnableVBO and (not FMesh.ArObjects[FMesh.NOfObjects-1].FEnableVBO) then
		FMesh.ArObjects[FMesh.NOfObjects-1].LoadToVBO();
	end;
end;

procedure fgsdfghjsafhjsdgjfgshddsdsdaghfjdjshdrfjjssadjdsaqwrdcgaewdcfcafdcafewcwscdgdsf(Button:TSGButton);
begin
with TSGFractalLomanaya(Button.FUserPointer1) do
	begin
	FDepth+=1;
	Calculate();
	FLD.Caption:=SGStringToPChar(SGStr(Depth));
	FBMD.Active:=True;
	end;
end;


procedure fgsdfghjsafhjsdgjfgshddsdsdasadjdsaqwrdcgaewdcfcafdcafewcwscdgdsf(Button:TSGButton);
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

constructor TSGFractalLomanaya.Create(const VContext:PSGContext);
begin
inherited Create(VContext);
c17:=1/7;
c27:=2/7;
c37:=3/7;
c57:=5/7;

FEnableColors:=False;
FEnableNormals:=False;
Threads:=1;
Depth:=3;
FLightingEnable:=False;
InitProjectionComboBox(Context.Width-160,5{+Context.TopShift},150,30,[SGAnchRight],true);

FLDC:=TSGLabel.Create();
SGScreen.CreateChild(FLDC);
SGScreen.LastChild.SetBounds(Context.Width-160-90-125,5{+Context.TopShift},115,30);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='Итерация:';
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;


FBPD:=TSGButton.Create();
SGScreen.CreateChild(FBPD);
SGScreen.LastChild.SetBounds(Context.Width-160-30,5{+Context.TopShift},20,30);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='+';
SGScreen.LastChild.FUserPointer1:=Self;
FBPD.OnChange:=TSGComponentProcedure(@fgsdfghjsafhjsdgjfgshddsdsdaghfjdjshdrfjjssadjdsaqwrdcgaewdcfcafdcafewcwscdgdsf);
SGScreen.LastChild.Visible:=True;

FLD:=TSGLabel.Create();
SGScreen.CreateChild(FLD);
SGScreen.LastChild.SetBounds(Context.Width-160-60,5{+Context.TopShift},20,30);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='0';
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FBMD:=TSGButton.Create();
SGScreen.CreateChild(FBMD);
SGScreen.LastChild.SetBounds(Context.Width-160-90,5{+Context.TopShift},20,30);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='-';
FBMD.OnChange:=TSGComponentProcedure(@fgsdfghjsafhjsdgjfgshddsdsdasadjdsaqwrdcgaewdcfcafdcafewcwscdgdsf);
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FLD.Caption:=SGStringToPChar(SGStr(Depth));

Calculate();
end;

destructor TSGFractalLomanaya.Destroy();
begin
FBMD.Destroy;
FLD.Destroy;
FLDC.Destroy;
FBPD.Destroy;
inherited;
end;

{$ENDIF}


