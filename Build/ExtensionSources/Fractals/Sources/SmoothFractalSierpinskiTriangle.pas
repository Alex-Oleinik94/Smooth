{$INCLUDE Smooth.inc}

unit SmoothFractalSierpinskiTriangle;

interface

uses
	 SmoothBase
	,SmoothFractal
	,Smooth3DFractal
	,SmoothCommonStructs
	,SmoothContextInterface
	,SmoothScreen
	,SmoothScreenClasses
	;

type
	TSFractalSierpinskiTriangle = class(TS3DFractal)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
			public
		class function CountingTheNumberOfPolygons(const ThisDepth:Int64):Int64;
		procedure Construct();override;
		procedure PolygonsConstruction();
		procedure PushPolygonData(var ObjectId:TSFractalIndexInt;const v1,v2,v3:TSVertex2f;var FVertexIndex,FFaceIndex:TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			protected
		FLD, FLDC : TSScreenLabel;
		FBPD, FBMD : TSScreenButton;
		end;

implementation

uses
	 SmoothRenderBase
	,SmoothStringUtils
	,SmoothVertexObject
	,SmoothScreenBase
	;

class function TSFractalSierpinskiTriangle.ClassName():TSString;
begin
Result := '����������� �����������';
end;

procedure TSFractalSierpinskiTriangle.PushPolygonData(var ObjectId:TSFractalIndexInt;const v1,v2,v3:TSVertex2f;var FVertexIndex,FFaceIndex:TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FVertexIndex+=3;
F3dObject.Objects[ObjectId].SetVertex(FVertexIndex-3, v1);
F3dObject.Objects[ObjectId].SetVertex(FVertexIndex-2, v2);
F3dObject.Objects[ObjectId].SetVertex(FVertexIndex-1, v3);

F3dObject.Objects[ObjectId].SetFaceLine(0,FFaceIndex+0,FVertexIndex-1,FVertexIndex-2);
F3dObject.Objects[ObjectId].SetFaceLine(0,FFaceIndex+1,FVertexIndex-3,FVertexIndex-2);
F3dObject.Objects[ObjectId].SetFaceLine(0,FFaceIndex+2,FVertexIndex-1,FVertexIndex-3);
FFaceIndex+=3;

AfterPushingPolygonData(ObjectId,FThreadsEnable,FVertexIndex,FFaceIndex);
end;

procedure TSFractalSierpinskiTriangle.PolygonsConstruction();
var
	ObjectId:TSFractalIndexInt;
	FVertexIndex,FFaceIndex:TSFractalIndexInt;
procedure Rec(const t1,t2,t3:TSVertex3f;const NowDepth:LongWord);
begin
PushPolygonData(
	ObjectId,
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
ObjectId:=0;
FFaceIndex:=0;
FVertexIndex:=0;
PushPolygonData(
	ObjectId,
	SVertex3fImport(cos(pi/2),sin(pi/2))*4,
	SVertex3fImport(cos(pi/2+2*pi/3),sin(pi/2+2*pi/3))*4,
	SVertex3fImport(cos(pi/2+4*pi/3),sin(pi/2+4*pi/3))*4,
	FVertexIndex,FFaceIndex);
if FDepth>0 then
	begin
	Rec(
		SVertex3fImport(cos(pi/2),sin(pi/2))*4,
		SVertex3fImport(cos(pi/2+2*pi/3),sin(pi/2+2*pi/3))*4,
		SVertex3fImport(cos(pi/2+4*pi/3),sin(pi/2+4*pi/3))*4,
		FDepth)
	end;
if FThreadsEnable then
	if (ObjectId>=0) and (ObjectId<=F3dObject.QuantityObjects-1) then
		if F3dObjectsInfo[ObjectId]=S_FALSE then
			F3dObjectsInfo[ObjectId]:=S_TRUE;
end;

procedure TSFractalSierpinskiTriangle_Thread(FractalThreadData:PSFractalThreadData);
begin
(FractalThreadData^.Fractal as TSFractalSierpinskiTriangle).PolygonsConstruction();
FractalThreadData^.Finished:=True;
FractalThreadData^.FreeMemData();
end;

procedure TSFractalSierpinskiTriangle.Construct();
var
	NumberOfPolygons:Int64;
begin
inherited;
Clear3dObject;
NumberOfPolygons:=CountingTheNumberOfPolygons(FDepth);
if Render.RenderType in [SRenderDirectX9,SRenderDirectX8] then 
	Construct3dObjects(NumberOfPolygons,SR_LINES,S3dObjectVertexType3f,1)
else
	Construct3dObjects(NumberOfPolygons,SR_LINES,S3dObjectVertexType2f,1);
if FThreadsEnable then
	begin
	FThreadsData[0].Clear(Self);
	PolygonsConstruction;
	end
else
	begin
	PolygonsConstruction;
	if (FMemoryDataType = SVRAM) and (not F3dObject.LastObject().EnableVBO) then
		F3dObject.LastObject().LoadToVBO(ClearRAMAfterLoadToVRAM);
	end;
end;

class function TSFractalSierpinskiTriangle.CountingTheNumberOfPolygons(const ThisDepth:Int64):Int64;
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

procedure SierpinskiTriangleButtonDepthPlusOnChangeKT(Button:TSScreenButton);
begin
with TSFractalSierpinskiTriangle(Button.FUserPointer1) do
	begin
	FDepth+=1;
	Construct;
	FLD.Caption:=SStringToPChar(SStr(Depth));
	FBMD.Active:=True;
	end;
end;


procedure SierpinskiTriangleButtonDepthMinusOnChangeKT(Button:TSScreenButton);
begin
with TSFractalSierpinskiTriangle(Button.FUserPointer1) do
	begin
	if Depth>0 then
		begin
		FDepth-=1;
		Construct;
		FLD.Caption:=SStringToPChar(SStr(Depth));
		if Depth=0 then
			FBMD.Active:=False;
		end;
	end;
end;

constructor TSFractalSierpinskiTriangle.Create(const VContext : ISContext);
begin
inherited;
FEnableColors:=False;
FEnableNormals:=False;
Threads:={$IFDEF ANDROID}0{$ELSE}1{$ENDIF};
Depth:=3;
FLightingEnable:=False;
ClearRAMAfterLoadToVRAM := False;

InitProjectionComboBox(Render.Width-160,5,150,30,[SAnchRight]).BoundsMakeReal();
InitSizeLabel(5,Render.Height-25,Render.Width-20,20,[SAnchBottom]).BoundsMakeReal();
InitSaveButton(Render.Width - 160, 37, 150, 30, [SAnchRight]).BoundsMakeReal();

FLDC := SCreateLabel(Screen, '��������:', Render.Width-160-90-125,5,115,30, [SAnchRight], True, True, Self);

FBPD:=TSScreenButton.Create;
Screen.CreateInternalComponent(FBPD);
Screen.LastInternalComponent.SetBounds(Render.Width-160-30,5,20,30);
Screen.LastInternalComponent.Anchors:=[SAnchRight];
Screen.LastInternalComponent.Caption:='+';
Screen.LastInternalComponent.FUserPointer1:=Self;
FBPD.OnChange:=TSScreenComponentProcedure(@SierpinskiTriangleButtonDepthPlusOnChangeKT);
Screen.LastInternalComponent.Visible:=True;
Screen.LastInternalComponent.BoundsMakeReal();

FLD := SCreateLabel(Screen, '0', Render.Width-160-60,5,20,30, [SAnchRight], True, True, Self);

FBMD:=TSScreenButton.Create;
Screen.CreateInternalComponent(FBMD);
Screen.LastInternalComponent.SetBounds(Render.Width-160-90,5,20,30);
Screen.LastInternalComponent.Anchors:=[SAnchRight];
Screen.LastInternalComponent.Caption:='-';
FBMD.OnChange:=TSScreenComponentProcedure(@SierpinskiTriangleButtonDepthMinusOnChangeKT);
Screen.LastInternalComponent.FUserPointer1:=Self;
Screen.LastInternalComponent.Visible:=True;
Screen.LastInternalComponent.BoundsMakeReal();

FLD.Caption:=SStringToPChar(SStr(Depth));

Construct;
end;

destructor TSFractalSierpinskiTriangle.Destroy;
begin
SKill(FBMD);
SKill(FLD);
SKill(FLDC);
SKill(FBPD);
inherited;
end;

end.
