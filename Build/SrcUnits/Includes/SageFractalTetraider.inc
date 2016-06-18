
{$IFDEF SGREADINTERFACE}
type
	TSGFractalTetraider=class(TSG3DFractal)
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
			public
		procedure Calculate;override;
		procedure CalculateFromThread();
		procedure PushIndexes(var MeshID:LongWord;const n,v0,v1,v2:TSGVertex3f;var FVertexIndex:LongWord);Inline;
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


procedure TSGFractalTetraider.PushIndexes(var MeshID:LongWord;const n,v0,v1,v2:TSGVertex3f;var FVertexIndex:LongWord);Inline;
var
	c:TSGColor3f;

function GetColor(const v : TSGVertex3f):TSGColor3f;
begin
Result:=c0*(SGAbsTwoVertex(v,bb0)/h)+
		c1*(SGAbsTwoVertex(v,bb1)/h)+
		c2*(SGAbsTwoVertex(v,bb2)/h)+
		c3*(SGAbsTwoVertex(v,bb3)/h);
end;

begin
FMesh.Objects[MeshID].ArVertex3f[FVertexIndex]^:=v0;
FMesh.Objects[MeshID].ArVertex3f[FVertexIndex+1]^:=v1;
FMesh.Objects[MeshID].ArVertex3f[FVertexIndex+2]^:=v2;
if FEnableColors then
	begin
	c:=GetColor(v0);
	C.Normalize();
	FMesh.Objects[MeshID].SetColor(FVertexIndex,
		c.r,c.g,c.b);
	C:=GetColor(v1);
	C.Normalize();
	FMesh.Objects[MeshID].SetColor(FVertexIndex+1,
		c.r,c.g,c.b);
	C:=GetColor(v2);
	C.Normalize();
	FMesh.Objects[MeshID].SetColor(FVertexIndex+2,
		c.r,c.g,c.b);
	end;
if FEnableNormals then
	begin
	FMesh.Objects[MeshID].ArNormal[FVertexIndex]^:=n;
	FMesh.Objects[MeshID].ArNormal[FVertexIndex+1]^:=n;
	FMesh.Objects[MeshID].ArNormal[FVertexIndex+2]^:=n;
	end;
FVertexIndex+=3;

AfterPushIndexes(MeshID,FThreadsEnable,FVertexIndex);
end;

procedure TSGFractalTetraider.CalculateFromThread();
var
	MeshID:LongWord;
	FVI:LongWord;

procedure Rec(const t0,t1,t2,t3:TSGVertex3f;const NowDepth:LongWord);

begin
if NowDepth=0 then
	begin
	PushIndexes(MeshID,FArNor[3],t0,t1,t2,FVI);
	PushIndexes(MeshID,FArNor[0],t0,t1,t3,FVI);
	PushIndexes(MeshID,FArNor[2],t0,t2,t3,FVI);
	PushIndexes(MeshID,FArNor[1],t1,t2,t3,FVI);
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
FVI:=0;
FArNor[0]:=SGGetVertexWhichNormalFromThreeVertex(bb0,bb1,bb3);
FArNor[1]:=SGGetVertexWhichNormalFromThreeVertex(bb1,bb2,bb3);
FArNor[2]:=SGGetVertexWhichNormalFromThreeVertex(bb2,bb0,bb3);
FArNor[3]:=SGGetVertexWhichNormalFromThreeVertex(bb0,bb2,bb1);
b:=(bb0+bb1+bb2+bb3)/4;
Rec(bb0-b,bb1-b,bb2-b,bb3-b,FDepth);
if FThreadsEnable then
	if (MeshID>=0) and (MeshID<=FMesh.QuantityObjects-1) then
		if FMeshesInfo[MeshID]=SG_FALSE then
			FMeshesInfo[MeshID]:=SG_TRUE;
end;

procedure TSGFractalTetraider.Calculate();
var
	Quantity:Int64;
begin
inherited;
ClearMesh();
Quantity:=(4**(1+FDepth));
CalculateMeshes(Quantity,SGR_TRIANGLES,SGMeshVertexType3f);
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

constructor TSGFractalTetraider.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
EnableColors   := True;
EnableNormals  := True;
LightingEnable := True;
HasIndexes     := False;
Threads:={$IFDEF ANDROID}0{$ELSE}1{$ENDIF};
Depth:=3;
Radius:=5;
h:=sqrt(3)*Radius/2;
c0:=SGGetColor4fFromLongWord($FF00FF);
c1:=SGGetColor4fFromLongWord($00FFFF);
c2:=SGGetColor4fFromLongWord($FFFF00);
c3:=SGGetColor4fFromLongWord($0080FF);

InitProjectionComboBox(Render.Width-160,5,150,30,[SGAnchRight]);
InitEffectsComboBox(Render.Width-160,40,150,30,[SGAnchRight]);
InitSizeLabel(5,Render.Height-25,Render.Width-20,20,[SGAnchBottom]);

FLDC:=TSGLabel.Create;
SGScreen.CreateChild(FLDC);
SGScreen.LastChild.SetBounds(Render.Width-160-90-125,5,115,30);
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='Итерация:';
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;


FBPD:=TSGButton.Create;
SGScreen.CreateChild(FBPD);
SGScreen.LastChild.SetBounds(Render.Width-160-30,5,20,30);
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='+';
SGScreen.LastChild.FUserPointer1:=Self;
FBPD.OnChange:=TSGComponentProcedure(@PodkovammmFButtonDepthPlusOnChangeKTTet);
SGScreen.LastChild.Visible:=True;

FLD:=TSGLabel.Create;
SGScreen.CreateChild(FLD);
SGScreen.LastChild.SetBounds(Render.Width-160-60,5,20,30);
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='0';
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FBMD:=TSGButton.Create;
SGScreen.CreateChild(FBMD);
SGScreen.LastChild.SetBounds(Render.Width-160-90,5,20,30);
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='-';
FBMD.OnChange:=TSGComponentProcedure(@PodkovammmFButtonDepthMinusOnChangeKTTet);
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FLD.Caption:=SGStringToPChar(SGStr(Depth));

Calculate();
end;

destructor TSGFractalTetraider.Destroy;
begin
FBMD.Destroy();
FLD.Destroy();
FLDC.Destroy();
FBPD.Destroy();
inherited;
end;

{$ENDIF}


