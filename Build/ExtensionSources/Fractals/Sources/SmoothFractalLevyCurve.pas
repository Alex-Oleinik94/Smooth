{$INCLUDE Smooth.inc}

unit SmoothFractalLevyCurve;

interface

uses
	 SmoothBase
	,SmoothFractal
	,Smooth3DFractal
	,SmoothCommonStructs
	,SmoothScreen
	,SmoothScreenClasses
	;

type
	TSFractalLevyCurve=class(TS3DFractal)
			public
		constructor Create(); override;
		destructor Destroy; override;
		class function ClassName() : TSString; override;
			public
		procedure Construct();override;
		procedure PolygonsConstruction();
		procedure PushPolygonData(var ObjectId:TSFractalIndexInt;const v:TSVertex2f;var FVertexIndex:TSFractalIndexInt);Inline;
			protected
		FLD, FLDC : TSScreenLabel;
		FBPD, FBMD : TSScreenButton;
		FTCB : TSScreenComboBox;
		end;

implementation

uses
	 SmoothRenderBase
	,SmoothMathUtils
	,SmoothScreenBase
	,SmoothStringUtils
	,SmoothVertexObject
	;

class function TSFractalLevyCurve.ClassName() : TSString;
begin
Result := 'Кривая Леви (дракон Хартера)';
end;

procedure TSFractalLevyCurve.PushPolygonData(var ObjectId:TSFractalIndexInt;const v:TSVertex2f;var FVertexIndex:TSFractalIndexInt);Inline;
begin
F3dObject.Objects[ObjectId].SetVertex(FVertexIndex, v);
FVertexIndex+=1;

AfterPushingPolygonData(ObjectId,FThreadsEnable,FVertexIndex);
end;

procedure TSFractalLevyCurve.PolygonsConstruction();
var
	ObjectId:TSFractalIndexInt;
	FVI:TSFractalIndexInt;

procedure Rec(const t1,t2:TSVertex2f;const NowDepth:LongWord;const b:integer = 1);
var
	V:TSVertex3f;
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
	PushPolygonData(ObjectId,t2,FVI);
end;

begin
ObjectId:=0;
FVI:=0;
PushPolygonData(ObjectId,SVertex2fImport(-3,-2),FVI);
if FDepth=0 then
	begin
	PushPolygonData(ObjectId,SVertex2fImport(3,-2),FVI);
	end;
if FDepth>0 then
	begin
	Rec(SVertex2fImport(-3,-2),SVertex2fImport(3,-2),FDepth)
	end;
if FThreadsEnable then
	if (ObjectId>=0) and (ObjectId<=F3dObject.QuantityObjects-1) then
		if F3dObjectsInfo[ObjectId]=S_FALSE then
			F3dObjectsInfo[ObjectId]:=S_TRUE;
end;

procedure NewLevyCurveThread(FractalThreadData:PSFractalThreadData);
begin
(FractalThreadData^.Fractal as TSFractalLevyCurve).PolygonsConstruction();
FractalThreadData^.Finished := True;
end;

procedure TSFractalLevyCurve.Construct;
var
	NumberOfPolygons : TSUInt64;
begin
inherited;
Clear3dObject;
NumberOfPolygons:=(2**FDepth)+1;
if Render.RenderType in [SRenderDirectX9,SRenderDirectX8] then 
	Construct3dObjects(NumberOfPolygons,SR_LINE_STRIP,S3dObjectVertexType3f)
else
	Construct3dObjects(NumberOfPolygons,SR_LINE_STRIP,S3dObjectVertexType2f);
if FThreadsEnable then
	begin
	FThreadsData[0].Clear(Self);
	PolygonsConstruction;
	end
else
	begin
	PolygonsConstruction();
	if (FMemoryDataType = SVRAM) and (not F3dObject.LastObject().EnableVBO) then
		F3dObject.LastObject().LoadToVBO(ClearRAMAfterLoadToVRAM);
	end;
end;

procedure SFractalLevyCurveButtonDepthPlusOnChange(Button:TSScreenButton);
begin
with TSFractalLevyCurve(Button.FUserPointer1) do
	begin
	FDepth+=1;
	Construct;
	FLD.Caption := SStr(Depth);
	FBMD.Active:=True;
	end;
end;


procedure SFractalLevyCurveButtonDepthMinusOnChange(Button:TSScreenButton);
begin
with TSFractalLevyCurve(Button.FUserPointer1) do
	begin
	if Depth>0 then
		begin
		FDepth-=1;
		Construct;
		FLD.Caption := SStr(Depth);
		if Depth=0 then
			FBMD.Active:=False;
		end;
	end;
end;

procedure SFractalLevyCurveComboBoxOnChange(a,b:LongInt;Button:TSScreenComponent);
begin
with TSFractalLevyCurve(Button.FUserPointer1) do
	begin
	if a<>b then
		begin
		FTCB.SelectItem:=b;
		Construct;
		end;
	end;
end;

constructor TSFractalLevyCurve.Create();
begin
inherited;
HasIndexes := False;
FLightingEnable:=False;
FEnableColors:=False;
FEnableNormals:=False;
Threads:={$IFDEF ANDROID}0{$ELSE}1{$ENDIF};
Depth:=3;

InitProjectionComboBox(Render.Width-160,5,150,30,[SAnchRight]).BoundsMakeReal();
InitSizeLabel(5,Render.Height-25,Render.Width-20,20,[SAnchBottom]).BoundsMakeReal();

FLDC := SCreateLabel(Screen, 'Итерация:', Render.Width-160-90-125,5,115,30, [SAnchRight], True, True, Self);

FBPD:=TSScreenButton.Create;
Screen.CreateInternalComponent(FBPD);
Screen.LastInternalComponent.SetBounds(Render.Width-160-30,5,20,30);
Screen.LastInternalComponent.Anchors:=[SAnchRight];
Screen.LastInternalComponent.Caption:='+';
Screen.LastInternalComponent.FUserPointer1:=Self;
FBPD.OnChange:=TSScreenComponentProcedure(@SFractalLevyCurveButtonDepthPlusOnChange);
Screen.LastInternalComponent.Visible:=True;
Screen.LastInternalComponent.BoundsMakeReal();

FLD := SCreateLabel(Screen, '0', Render.Width-160-60,5,20,30, [SAnchRight], True, True, Self);

FBMD:=TSScreenButton.Create;
Screen.CreateInternalComponent(FBMD);
Screen.LastInternalComponent.SetBounds(Render.Width-160-90,5,20,30);
Screen.LastInternalComponent.Anchors:=[SAnchRight];
Screen.LastInternalComponent.Caption:='-';
FBMD.OnChange:=TSScreenComponentProcedure(@SFractalLevyCurveButtonDepthMinusOnChange);
Screen.LastInternalComponent.FUserPointer1:=Self;
Screen.LastInternalComponent.Visible:=True;
Screen.LastInternalComponent.BoundsMakeReal();

FTCB:=TSScreenComboBox.Create;
Screen.CreateInternalComponent(FTCB);
FTCB.SetBounds(Render.Width-160-90-125-130-50,5,125+50,20);
FTCB.Anchors:=[SAnchRight];
FTCB.CreateItem('Кривая Леви');
FTCB.CreateItem('Дракон Хартера — Хейтуэя');
FTCB.CallBackProcedure:=TSScreenComboBoxProcedure(@SFractalLevyCurveComboBoxOnChange);
FTCB.SelectItem:=0;
FTCB.FUserPointer1:=Self;
FTCB.Visible:=True;
FTCB.BoundsMakeReal();

FLD.Caption := SStr(Depth);

Construct();
end;

destructor TSFractalLevyCurve.Destroy;
begin
SKill(FBMD);
SKill(FLD);
SKill(FLDC);
SKill(FBPD);
SKill(FTCB);
inherited;
end;

end.
