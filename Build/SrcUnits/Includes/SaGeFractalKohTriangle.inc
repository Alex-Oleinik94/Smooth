
{$IFDEF SGREADINTERFACE}
type
	TSGFractalKohTriangle=class(TSG3DFractal)
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
			public
		function RecQuantity(const ThisDepth:Int64):Int64;
		procedure Calculate;override;
		procedure CalculateFromThread();
		procedure PushIndexes(var MeshID:LongWord;const v1,v2,v3:TSGVertex2f;var FVertexIndex,FFaceIndex:LongWord);Inline;
			public
		FLD,FLDC:TSGLabel;
		FBPD,FBMD:TSGButton;
		end;
{$ENDIF}


{$IFDEF SGREADIMPLEMENTATION}

class function TSGFractalKohTriangle.ClassName:string;
begin
Result:='Треугольник Серпинского';
end;


procedure TSGFractalKohTriangle.PushIndexes(var MeshID:LongWord;const v1,v2,v3:TSGVertex2f;var FVertexIndex,FFaceIndex:LongWord);Inline;
begin
FVertexIndex+=3;
if Render.RenderType<>SGRenderDirectX then
	begin
	FMesh.ArObjects[MeshID].ArVertex2f[FVertexIndex-3]^:=v1;
	FMesh.ArObjects[MeshID].ArVertex2f[FVertexIndex-2]^:=v2;
	FMesh.ArObjects[MeshID].ArVertex2f[FVertexIndex-1]^:=v3;
	end
else
	begin
	FMesh.ArObjects[MeshID].ArVertex3f[FVertexIndex-3]^.Import(v1.x,v1.y);
	FMesh.ArObjects[MeshID].ArVertex3f[FVertexIndex-2]^.Import(v2.x,v2.y);
	FMesh.ArObjects[MeshID].ArVertex3f[FVertexIndex-1]^.Import(v3.x,v3.y);
	end;


FMesh.ArObjects[MeshID].ArFacesLines[FFaceIndex+0].p[0]:=FVertexIndex-1;
FMesh.ArObjects[MeshID].ArFacesLines[FFaceIndex+0].p[1]:=FVertexIndex-2;

FMesh.ArObjects[MeshID].ArFacesLines[FFaceIndex+1].p[0]:=FVertexIndex-3;
FMesh.ArObjects[MeshID].ArFacesLines[FFaceIndex+1].p[1]:=FVertexIndex-2;

FMesh.ArObjects[MeshID].ArFacesLines[FFaceIndex+2].p[0]:=FVertexIndex-1;
FMesh.ArObjects[MeshID].ArFacesLines[FFaceIndex+2].p[1]:=FVertexIndex-3;
FFaceIndex+=3;

AfterPushIndexes(MeshID,FThreadsEnable,FVertexIndex,FFaceIndex);
end;

procedure TSGFractalKohTriangle.CalculateFromThread();
var
	MeshID:LongWord;
	FVertexIndex,FFaceIndex:LongWord;
procedure Rec(const t1,t2,t3:TSGVertex;const NowDepth:LongWord);
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
	SGVertexImport(cos(pi/2),sin(pi/2))*4,
	SGVertexImport(cos(pi/2+2*pi/3),sin(pi/2+2*pi/3))*4,
	SGVertexImport(cos(pi/2+4*pi/3),sin(pi/2+4*pi/3))*4,
	FVertexIndex,FFaceIndex);
if FDepth>0 then
	begin
	Rec(
		SGVertexImport(cos(pi/2),sin(pi/2))*4,
		SGVertexImport(cos(pi/2+2*pi/3),sin(pi/2+2*pi/3))*4,
		SGVertexImport(cos(pi/2+4*pi/3),sin(pi/2+4*pi/3))*4,
		FDepth)
	end;
if FThreadsEnable then
	if (MeshID>=0) and (MeshID<=FMesh.NOfObjects-1) then
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
if Render.RenderType = SGRenderDirectX then 
	CalculateMeshes(Quantity,SGR_LINES,TSGMeshVertexType3f)
else
	CalculateMeshes(Quantity,SGR_LINES,TSGMeshVertexType2f);
if FThreadsEnable then
	begin
	FThreadsData[0].FFinished:=False;
	FThreadsData[0].FData:=nil;
	CalculateFromThread;
	end
else
	begin
	CalculateFromThread;
	if FEnableVBO and (not FMesh.ArObjects[FMesh.NOfObjects-1].FEnableVBO) then
		FMesh.ArObjects[FMesh.NOfObjects-1].LoadToVBO;
	end;
end;

function TSGFractalKohTriangle.RecQuantity(const ThisDepth:Int64):Int64;
var
	i,ii:LongWord;
begin
Result:=0;
ii:=3;
for i:=0 to ThisDepth do
	begin
	Result+=ii;
	ii*=3;
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

constructor TSGFractalKohTriangle.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FEnableColors:=False;
FEnableNormals:=False;
Threads:=1;
Depth:=3;
FLightingEnable:=False;

InitProjectionComboBox(Context.Width-160,5{+Context.TopShift},150,30,[SGAnchRight],true);
InitSizeLabel(5,Context.Height-25,Context.Width-20,20,[SGAnchBottom],False);

FLDC:=TSGLabel.Create;
SGScreen.CreateChild(FLDC);
SGScreen.LastChild.SetBounds(Context.Width-160-90-125,5{+Context.TopShift},115,30);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='Итерация:';
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;


FBPD:=TSGButton.Create;
SGScreen.CreateChild(FBPD);
SGScreen.LastChild.SetBounds(Context.Width-160-30,5{+Context.TopShift},20,30);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='+';
SGScreen.LastChild.FUserPointer1:=Self;
FBPD.OnChange:=TSGComponentProcedure(@mmmFButtonDepthPlusOnChangeKT);
SGScreen.LastChild.Visible:=True;

FLD:=TSGLabel.Create;
SGScreen.CreateChild(FLD);
SGScreen.LastChild.SetBounds(Context.Width-160-60,5{+Context.TopShift},20,30);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='0';
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FBMD:=TSGButton.Create;
SGScreen.CreateChild(FBMD);
SGScreen.LastChild.SetBounds(Context.Width-160-90,5{+Context.TopShift},20,30);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='-';
FBMD.OnChange:=TSGComponentProcedure(@mmmFButtonDepthMinusOnChangeKT);
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

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

{$ENDIF}


