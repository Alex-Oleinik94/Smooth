{$INCLUDE Smooth.inc}

unit SmoothFractalSierpinskiCarpet;

interface

uses
	 SmoothBase
	,SmoothFractal
	,Smooth3DFractal
	,SmoothScreen
	,SmoothContextInterface
	,SmoothCommonStructs
	,SmoothScreenClasses
	;

type
	TSFractalSierpinskiCarpet=class(TS3DFractal)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
			public
		class function CountingTheNumberOfPolygons(const ThisDepth : TSUInt64) : TSUInt64;
		procedure Construct();override;
		procedure PolygonsConstruction();
		procedure PushPolygonData(var ObjectId:TSFractalIndexInt;const v1,v2,v3,v4:TSVertex2f;var FVertexIndex,FFaceIndex:TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			protected
		FLD, FLDC : TSScreenLabel;
		FBPD, FBMD : TSScreenButton;
		end;

implementation

uses
	 SmoothVertexObject
	,SmoothScreenBase
	,SmoothRenderBase
	,SmoothStringUtils
	;

class function TSFractalSierpinskiCarpet.ClassName():TSString;
begin
Result := 'Ковёр (квадрат) Серпинского';
end;

procedure TSFractalSierpinskiCarpet.PushPolygonData(var ObjectId:TSFractalIndexInt;const v1, v2, v3, v4 : TSVertex2f;var FVertexIndex,FFaceIndex:TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FVertexIndex+=4;
F3dObject.Objects[ObjectId].SetVertex(FVertexIndex - 4, v1);
F3dObject.Objects[ObjectId].SetVertex(FVertexIndex - 3, v2);
F3dObject.Objects[ObjectId].SetVertex(FVertexIndex - 2, v3);
F3dObject.Objects[ObjectId].SetVertex(FVertexIndex - 1, v4);

F3dObject.Objects[ObjectId].SetFaceQuad(0,FFaceIndex+0,FVertexIndex-1,FVertexIndex-2,FVertexIndex-3,FVertexIndex-4);
FFaceIndex+=1;

AfterPushingPolygonData(ObjectId,FThreadsEnable,FVertexIndex,FFaceIndex);
end;

procedure TSFractalSierpinskiCarpet.PolygonsConstruction();
var
	ObjectId:TSFractalIndexInt;
	FVertexIndex,FFaceIndex:TSFractalIndexInt;

procedure Rec(const t1,t2:TSVertex3f;const NowDepth:LongWord);
var
	a : TSFloat64;
begin
a := Abs(t1.x - t2.x) / 3;
if NowDepth = 0 then
	PushPolygonData(
		ObjectId,
		SVertex3fImport(t1.x, t1.y),
		SVertex3fImport(t1.x, t2.y),
		SVertex3fImport(t2.x, t2.y),
		SVertex3fImport(t2.x, t1.y),
		FVertexIndex, FFaceIndex)
else if NowDepth = 1 then
	begin
	PushPolygonData(ObjectId,
		SVertex3fImport(t1.x, t1.y),
		SVertex3fImport(t1.x + a, t1.y),
		SVertex3fImport(t1.x + a, t1.y + 3 * a),
		SVertex3fImport(t1.x, t1.y + 3 * a),
		FVertexIndex, FFaceIndex);
	PushPolygonData(ObjectId,
		SVertex3fImport(t1.x + a * 2, t1.y),
		SVertex3fImport(t1.x + a * 3, t1.y),
		SVertex3fImport(t1.x + a * 3, t1.y + 3 * a),
		SVertex3fImport(t1.x + a * 2, t1.y + 3 * a),
		FVertexIndex, FFaceIndex);
	PushPolygonData(ObjectId,
		SVertex3fImport(t1.x, t1.y),
		SVertex3fImport(t1.x + a * 3, t1.y),
		SVertex3fImport(t1.x + a * 3, t1.y + a),
		SVertex3fImport(t1.x, t1.y + a),
		FVertexIndex, FFaceIndex);
	PushPolygonData(ObjectId,
		SVertex3fImport(t1.x, t1.y + a * 2),
		SVertex3fImport(t1.x + a * 3, t1.y + a * 2),
		SVertex3fImport(t1.x + a * 3, t1.y + a * 3),
		SVertex3fImport(t1.x, t1.y + a * 3),
		FVertexIndex, FFaceIndex);
	end
else
	begin
	Rec(SVertex3fImport(t1.x, t1.y),
		SVertex3fImport(t1.x + a, t1.y + a),
		NowDepth - 1);
	Rec(SVertex3fImport(t1.x + a, t1.y),
		SVertex3fImport(t1.x + a + a, t1.y + a),
		NowDepth - 1);
	Rec(SVertex3fImport(t1.x + a + a, t1.y),
		SVertex3fImport(t1.x + a + a + a, t1.y + a),
		NowDepth - 1);
	Rec(SVertex3fImport(t1.x + a + a, t1.y + a),
		SVertex3fImport(t1.x + a + a + a, t1.y + a + a),
		NowDepth - 1);
	Rec(SVertex3fImport(t1.x + a + a, t1.y + a + a),
		SVertex3fImport(t1.x + a + a + a, t1.y + a + a + a),
		NowDepth - 1);
	Rec(SVertex3fImport(t1.x + a, t1.y + a + a),
		SVertex3fImport(t1.x + a + a, t1.y + a + a + a),
		NowDepth - 1);
	Rec(SVertex3fImport(t1.x, t1.y + a + a),
		SVertex3fImport(t1.x + a, t1.y + a + a + a),
		NowDepth - 1);
	Rec(SVertex3fImport(t1.x, t1.y + a),
		SVertex3fImport(t1.x + a, t1.y + a + a),
		NowDepth - 1);
	end;
end;

begin
ObjectId := 0;
FFaceIndex := 0;
FVertexIndex := 0;
Rec(SVertex3fImport(-1, -1) * 4,
	SVertex3fImport( 1,  1) * 4,
	FDepth);
if FThreadsEnable then
	if (ObjectId>=0) and (ObjectId<=F3dObject.QuantityObjects-1) then
		if F3dObjectsInfo[ObjectId]=S_FALSE then
			F3dObjectsInfo[ObjectId]:=S_TRUE;
end;

procedure TSFractalSierpinskiCarpet_Thread(FractalThreadData:PSFractalThreadData);
begin
(FractalThreadData^.Fractal as TSFractalSierpinskiCarpet).PolygonsConstruction();
FractalThreadData^.Finished:=True;
FractalThreadData^.FreeMemData();
end;

procedure TSFractalSierpinskiCarpet.Construct();
var
	NumberOfPolygons : TSUInt64;
begin
inherited;
Clear3dObject;
NumberOfPolygons := CountingTheNumberOfPolygons(FDepth);
if Render.RenderType in [SRenderDirectX9, SRenderDirectX8] then 
	Construct3dObjects(NumberOfPolygons,SR_QUADS,S3dObjectVertexType3f)
else
	Construct3dObjects(NumberOfPolygons,SR_QUADS,S3dObjectVertexType2f);
if FThreadsEnable then
	begin
	FThreadsData[0].Clear(Self);
	PolygonsConstruction();
	end
else
	begin
	PolygonsConstruction();
	if FEnableVBO and (not F3dObject.LastObject().EnableVBO) then
		F3dObject.LastObject().LoadToVBO();
	end;
end;

class function TSFractalSierpinskiCarpet.CountingTheNumberOfPolygons(const ThisDepth : TSUInt64):TSUInt64;
begin
if ThisDepth = 0 then
	Result := 1
else if ThisDepth = 1 then
	Result := 4
else
	Result := 8 * CountingTheNumberOfPolygons(ThisDepth - 1);
end;

procedure FractalSierpinskiCarpetButtonDepthPlusOnChange(Button:TSScreenButton);
begin
with TSFractalSierpinskiCarpet(Button.FUserPointer1) do
	begin
	FDepth+=1;
	Construct();
	FLD.Caption:=SStr(Depth);
	FBMD.Active:=True;
	end;
end;

procedure FractalSierpinskiCarpetButtonDepthMinusOnChange(Button:TSScreenButton);
begin
with TSFractalSierpinskiCarpet(Button.FUserPointer1) do
	begin
	if Depth>0 then
		begin
		FDepth-=1;
		Construct();
		FLD.Caption:=SStr(Depth);
		if Depth=0 then
			FBMD.Active:=False;
		end;
	end;
end;

constructor TSFractalSierpinskiCarpet.Create(const VContext : ISContext);
begin
inherited;
FEnableColors  := False;
FEnableNormals := False;
Threads:={$IFDEF ANDROID}0{$ELSE}1{$ENDIF};
Depth:=3;
FLightingEnable := False;

InitProjectionComboBox(Render.Width-160, 5, 150, 30, [SAnchRight]).BoundsMakeReal();
InitSizeLabel(5, Render.Height-25, Render.Width-20, 20, [SAnchBottom]).BoundsMakeReal();
InitSaveButton(Render.Width - 160, 37, 150, 30, [SAnchRight]).BoundsMakeReal();

FLDC := SCreateLabel(Screen, 'Итерация:', Render.Width-160-90-125,5,115,30, [SAnchRight], True, True, Self);

FBPD:=TSScreenButton.Create;
Screen.CreateChild(FBPD);
Screen.LastChild.SetBounds(Render.Width-160-30,5,20,30);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='+';
Screen.LastChild.FUserPointer1:=Self;
FBPD.OnChange:=TSScreenComponentProcedure(@FractalSierpinskiCarpetButtonDepthPlusOnChange);
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FLD := SCreateLabel(Screen, '0', Render.Width-160-60,5,20,30, [SAnchRight], True, True, Self);

FBMD:=TSScreenButton.Create;
Screen.CreateChild(FBMD);
Screen.LastChild.SetBounds(Render.Width-160-90,5,20,30);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='-';
FBMD.OnChange:=TSScreenComponentProcedure(@FractalSierpinskiCarpetButtonDepthMinusOnChange);
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FLD.Caption:= SStr(Depth);

Construct;
end;

destructor TSFractalSierpinskiCarpet.Destroy;
begin
SKill(FBMD);
SKill(FLD);
SKill(FLDC);
SKill(FBPD);
inherited;
end;

end.
