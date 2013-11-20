
{$IFDEF SGREADINTERFACE}
type
	TSGFractalTetraider=class(TSG3DFractal)
			public
		constructor Create(const VContext:PSGContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
			public
		procedure Calculate;override;
		procedure CalculateFromThread();
		procedure PushIndexes(var MeshID:LongWord;const n,v0,v1,v2:TSGVertex3f;var FVertexIndex,FFaceIndex:LongWord);Inline;
			public
		FLD,FLDC:TSGLabel;
		FBPD,FBMD:TSGButton;
		Radius:TSGSingle;
		FArNor:packed array[0..3] of TSGVertex3f;
		bb0,bb1,bb2,bb3:TSGVertex3f;
		h:single;
		c0,c1,c2,c3:TSGColor3f;
		end;
{$ENDIF}


{$IFDEF SGREADIMPLEMENTATION}

class function TSGFractalTetraider.ClassName:string;
begin
Result:='Тетраидер Серпинского';
end;


procedure TSGFractalTetraider.PushIndexes(var MeshID:LongWord;const n,v0,v1,v2:TSGVertex3f;var FVertexIndex,FFaceIndex:LongWord);Inline;
var
	c:TSGColor3f;
	v:TSGVertex3f;
begin
FMesh.ArObjects[MeshID].ArVertex3f[FVertexIndex]^:=v0;
FMesh.ArObjects[MeshID].ArVertex3f[FVertexIndex+1]^:=v1;
FMesh.ArObjects[MeshID].ArVertex3f[FVertexIndex+2]^:=v2;
if FEnableColors then
	begin
	v:=v0;
	C:=(c0*SGAbsTwoVertex(v,bb0)/h+
		c1*SGAbsTwoVertex(v,bb1)/h+
		c2*SGAbsTwoVertex(v,bb2)/h+
		c3*SGAbsTwoVertex(v,bb3)/h);
	C.Normalize();
	FMesh.ArObjects[MeshID].SetColor(FVertexIndex,
		c.r,c.g,c.b);
	v:=v1;
	C:=(c0*SGAbsTwoVertex(v,bb0)/h+
		c1*SGAbsTwoVertex(v,bb1)/h+
		c2*SGAbsTwoVertex(v,bb2)/h+
		c3*SGAbsTwoVertex(v,bb3)/h);
	C.Normalize();
	FMesh.ArObjects[MeshID].SetColor(FVertexIndex+1,
		c.r,c.g,c.b);
	v:=v2;
	C:=(c0*SGAbsTwoVertex(v,bb0)/h+
		c1*SGAbsTwoVertex(v,bb1)/h+
		c2*SGAbsTwoVertex(v,bb2)/h+
		c3*SGAbsTwoVertex(v,bb3)/h);
	C.Normalize();
	FMesh.ArObjects[MeshID].SetColor(FVertexIndex+2,
		c.r,c.g,c.b);
	end;
if FEnableNormals then
	begin
	FMesh.ArObjects[MeshID].ArNormal[FVertexIndex]^:=n;
	FMesh.ArObjects[MeshID].ArNormal[FVertexIndex+1]^:=n;
	FMesh.ArObjects[MeshID].ArNormal[FVertexIndex+2]^:=n;
	end;
FVertexIndex+=3;

FMesh.ArObjects[MeshID].ArFacesTriangles[FFaceIndex].p[0]:=FVertexIndex-1;
FMesh.ArObjects[MeshID].ArFacesTriangles[FFaceIndex].p[1]:=FVertexIndex-2;
FMesh.ArObjects[MeshID].ArFacesTriangles[FFaceIndex].p[2]:=FVertexIndex-3;
FFaceIndex+=1;

AfterPushIndexes(MeshID,FThreadsEnable,FVertexIndex,FFaceIndex);
end;

procedure TSGFractalTetraider.CalculateFromThread();
var
	MeshID:LongWord;
	FVI,FFI:LongWord;

procedure Rec(const t0,t1,t2,t3:TSGVertex3f;const NowDepth:LongWord);

begin
if NowDepth=0 then
	begin
	PushIndexes(MeshID,FArNor[3],t0,t1,t2,FVI,FFI);
	PushIndexes(MeshID,FArNor[0],t0,t1,t3,FVI,FFI);
	PushIndexes(MeshID,FArNor[2],t0,t2,t3,FVI,FFI);
	PushIndexes(MeshID,FArNor[1],t1,t2,t3,FVI,FFI);
	end
else
	begin
	Rec(t0,
		(t0+t1)/2,
		(t0+t2)/2,
		(t0+t3)/2,
		NowDepth-1);
	Rec((t0+t1)/2,
		t1,
		(t1+t2)/2,
		(t1+t3)/2,
		NowDepth-1);
	Rec((t0+t2)/2,
		(t1+t2)/2,
		t2,
		(t2+t3)/2,
		NowDepth-1);
	Rec((t0+t3)/2,
		(t3+t1)/2,
		(t2+t3)/2,
		t3,
		NowDepth-1);
	end;
end;

var
	b:TSGVertex3f;
begin
bb0:=SGVertexImport(cos(0)*Radius, sin(0)*Radius,-Radius*0.6);
bb1:=SGVertexImport(cos(2*pi/3)*Radius, sin(2*pi/3)*Radius,-Radius*0.6);
bb2:=SGVertexImport(cos(4*pi/3)*Radius, sin(4*pi/3)*Radius,-Radius*0.6);
bb3:=SGVertexImport(0, 0, Radius*0.6);
MeshID:=0;
FFI:=0;
FVI:=0;
FArNor[0]:=SGGetVertexWhichNormalFromThreeVertex(bb0,bb1,bb3);
FArNor[1]:=SGGetVertexWhichNormalFromThreeVertex(bb1,bb2,bb3);
FArNor[2]:=SGGetVertexWhichNormalFromThreeVertex(bb2,bb0,bb3);
FArNor[3]:=SGGetVertexWhichNormalFromThreeVertex(bb0,bb2,bb1);
b:=(bb0+bb1+bb2+bb3)/4;
Rec(bb0-b,bb1-b,bb2-b,bb3-b,FDepth);
if FThreadsEnable then
	if (MeshID>=0) and (MeshID<=FMesh.NOfObjects-1) then
		if FMeshesInfo[MeshID]=SG_FALSE then
			FMeshesInfo[MeshID]:=SG_TRUE;
end;

{procedure NewPodkovaThreadTet(Klass:TSGFractalData) ;
begin
(Klass.FFractal as TSGFractalTetraider).CalculateFromThread();
Klass.FFractal.FThreadsData[Klass.FThreadID].FFinished:=True;
Klass.FFractal.FThreadsData[Klass.FThreadID].FData:=nil;
Klass.Destroy;
end;}

procedure TSGFractalTetraider.Calculate;
var
	Quantity:Int64;
begin
inherited;
ClearMesh;
Quantity:=(4**(1+FDepth));
CalculateMeshes(Quantity,SGR_TRIANGLES,TSGMeshVertexType3f);
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
		FMesh.ArObjects[FMesh.NOfObjects-1].LoadToVBO;
	end;
end;

procedure PodkovammmFButtonDepthPlusOnChangeKTTet(Button:TSGButton);
begin
with TSGFractalTetraider(Button.FUserPointer1) do
	begin
	FDepth+=1;
	Calculate;
	FLD.Caption:=SGStringToPChar(SGStr(Depth));
	FBMD.Active:=True;
	end;
end;


procedure PodkovammmFButtonDepthMinusOnChangeKTTet(Button:TSGButton);
begin
with TSGFractalTetraider(Button.FUserPointer1) do
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

constructor TSGFractalTetraider.Create(const VContext:PSGContext);
begin
inherited Create(VContext);
FEnableColors:=True;
FEnableNormals:=True;
Threads:=1;
Depth:=3;
FLightingEnable:=True;
Radius:=5;
h:=sqrt(3)*Radius/2;
c0:=SGGetColor4fFromLongWord($FF00FF);
c1:=SGGetColor4fFromLongWord($00FFFF);
c2:=SGGetColor4fFromLongWord($FFFF00);
c3:=SGGetColor4fFromLongWord($0080FF);

InitProjectionComboBox(Context.Width-160,5,150,30,[SGAnchRight],True);
InitEffectsComboBox(Context.Width-160,40,150,30,[SGAnchRight],True);
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
FBPD.OnChange:=TSGComponentProcedure(@PodkovammmFButtonDepthPlusOnChangeKTTet);
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
FBMD.OnChange:=TSGComponentProcedure(@PodkovammmFButtonDepthMinusOnChangeKTTet);
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FLD.Caption:=SGStringToPChar(SGStr(Depth));

Calculate;
end;

destructor TSGFractalTetraider.Destroy;
begin
FBMD.Destroy;
FLD.Destroy;
FLDC.Destroy;
FBPD.Destroy;
inherited;
end;

{$ENDIF}


