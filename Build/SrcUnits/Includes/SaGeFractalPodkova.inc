
{$IFDEF SGREADINTERFACE}
type
	TSGFractalPodkova=class(TSG3DFractal)
			public
		constructor Create;override;
		destructor Destroy;override;
		class function ClassName:string;override;
			public
		procedure Calculate;override;
		procedure CalculateFromThread();
		procedure PushIndexes(var MeshID:LongWord;const v:TSGVertex);Inline;
			public
		FLD,FLDC:TSGLabel;
		FBPD,FBMD:TSGButton;
		FTCB:TSGComboBox;
		end;
{$ENDIF}


{$IFDEF SGREADIMPLEMENTATION}

class function TSGFractalPodkova.ClassName:string;
begin
Result:='Рогатый дракон';
end;


procedure TSGFractalPodkova.PushIndexes(var MeshID:LongWord;const v:TSGVertex);Inline;
begin
FMesh.ArObjects[MeshID].FNOfVerts+=1;
FMesh.ArObjects[MeshID].ArVertexes[FMesh.ArObjects[MeshID].FNOfVerts-1]:=v;


FMesh.ArObjects[MeshID].ArFacesPoints[FMesh.ArObjects[MeshID].FNOfFaces+0].p[0]:=FMesh.ArObjects[MeshID].FNOfVerts-1;
FMesh.ArObjects[MeshID].FNOfFaces+=1;

AfterPushIndexes(MeshID,FThreadsEnable);
end;

procedure TSGFractalPodkova.CalculateFromThread();
var
	MeshID:LongWord;

procedure Rec(const t1,t2:TSGVertex;const NowDepth:LongWord;const b:integer = 1);
var
	V:TSGVertex3f;
	NewType:Byte;
begin
if NowDepth>0 then
	begin  
	V.Import(
		0.5*(b*t1.y-b*t2.y+t1.x+t2.x),
		0.5*(b*t2.x-b*t1.x+t1.y+t2.y));
	Rec(t1,v,NowDepth-1,1);
	if not Boolean(FTCB.FSelectItem) then
		Rec(v,t2,NowDepth-1,1)
	else
		Rec(v,t2,NowDepth-1,-1);
	end
else
	PushIndexes(MeshID,t2);
end;

begin
MeshID:=0;
PushIndexes(MeshID,SGVertexImport(-3,-2));
if FDepth=0 then
	begin
	PushIndexes(MeshID,SGVertexImport(3,-2));
	end;
if FDepth>0 then
	begin
	Rec(SGVertexImport(-3,-2),SGVertexImport(3,-2),FDepth)
	end;
if FThreadsEnable then
	if (MeshID>=0) and (MeshID<=FMesh.NOfObjects-1) then
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
CalculateMeshes(Quantity,SG_LINE_STRIP);
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

procedure PodkovammmFButtonDepthPlusOnChangeKT(Button:TSGButton);
begin
with TSGFractalPodkova(Button.FUserPointer1) do
	begin
	FDepth+=1;
	Calculate;
	FLD.Caption:=SGStringToPChar(SGStr(Depth));
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
		end;
	end;
end;

procedure fgsdfghjsafhjsdgjfgshdj(a,b:LongInt;Button:TSGComponent);
begin
with TSGFractalPodkova(Button.FUserPointer1) do
	begin
	if a<>b then
		begin
		FTCB.FSelectItem:=b;
		Calculate;
		end;
	end;
end;

constructor TSGFractalPodkova.Create;
begin
inherited;
FEnableColors:=False;
FEnableNormals:=False;
Threads:=1;
Depth:=3;
FLightingEnable:=False;

InitProjectionComboBox(Context.Width-160,5{+Context.TopShift},150,30,[SGAnchRight],true);

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
FBPD.OnChange:=TSGComponentProcedure(@PodkovammmFButtonDepthPlusOnChangeKT);
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
FBMD.OnChange:=TSGComponentProcedure(@PodkovammmFButtonDepthMinusOnChangeKT);
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FTCB:=TSGComboBox.Create;
SGScreen.CreateChild(FTCB);
SGScreen.LastChild.SetBounds(Context.Width-160-90-125-130,5,125,20);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.AsComboBox.CreateItem('Рога');
SGScreen.LastChild.AsComboBox.CreateItem('Дракон');
SGScreen.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@fgsdfghjsafhjsdgjfgshdj);
SGScreen.LastChild.AsComboBox.FSelectItem:=0;
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FLD.Caption:=SGStringToPChar(SGStr(Depth));

Calculate;
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

{$ENDIF}


