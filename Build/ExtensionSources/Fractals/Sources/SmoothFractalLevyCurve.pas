{$INCLUDE Smooth.inc}

unit SmoothFractalLevyCurve;

interface

uses
	 SmoothBase
	,SmoothFractals
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
		procedure PushPoligonData(var ObjectId:LongWord;const v:TSVertex2f;var FVertexIndex:LongWord);Inline;
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

procedure TSFractalLevyCurve.PushPoligonData(var ObjectId:LongWord;const v:TSVertex2f;var FVertexIndex:LongWord);Inline;
begin
if Render.RenderType in [SRenderDirectX9,SRenderDirectX8] then
	F3dObject.Objects[ObjectId].ArVertex3f[FVertexIndex]^.Import(v.x,v.y)
else
	F3dObject.Objects[ObjectId].ArVertex2f[FVertexIndex]^:=v;

FVertexIndex+=1;

AfterPushingPoligonData(ObjectId,FThreadsEnable,FVertexIndex);
end;

procedure TSFractalLevyCurve.PolygonsConstruction();
var
	ObjectId:LongWord;
	FVI:LongWord;

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
	PushPoligonData(ObjectId,t2,FVI);
end;

begin
ObjectId:=0;
FVI:=0;
PushPoligonData(ObjectId,SVertex2fImport(-3,-2),FVI);
if FDepth=0 then
	begin
	PushPoligonData(ObjectId,SVertex2fImport(3,-2),FVI);
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

procedure NewLevyCurveThread(Klass:TSFractalData) ;
begin
(Klass.FFractal as TSFractalLevyCurve).PolygonsConstruction();
Klass.FFractal.FThreadsData[Klass.FThreadID].FFinished:=True;
Klass.FFractal.FThreadsData[Klass.FThreadID].FData:=nil;
Klass.Destroy;
end;

procedure TSFractalLevyCurve.Construct;
var
	NumberOfPolygons:Int64;
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
	FThreadsData[0].FFinished:=False;
	FThreadsData[0].FData:=nil;
	PolygonsConstruction;
	end
else
	begin
	PolygonsConstruction;
	if FEnableVBO and (not F3dObject.LastObject().EnableVBO) then
		F3dObject.LastObject().LoadToVBO();
	end;
end;

procedure LevyCurveFButtonDepthPlusOnChangeKT(Button:TSScreenButton);
begin
with TSFractalLevyCurve(Button.FUserPointer1) do
	begin
	FDepth+=1;
	Construct;
	FLD.Caption:=SStringToPChar(SStr(Depth));
	FBMD.Active:=True;
	end;
end;


procedure LevyCurveFButtonDepthMinusOnChangeKT(Button:TSScreenButton);
begin
with TSFractalLevyCurve(Button.FUserPointer1) do
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

procedure TSFractalLevyCurve_CamboBox_CallBackProcedure(a,b:LongInt;Button:TSScreenComponent);
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
FEnableColors:=False;
FEnableNormals:=False;
{$IFNDEF ANDROID}
	Threads:=1;
	{$ENDIF}
Depth:=3;
FLightingEnable:=False;
HasIndexes := False;

InitProjectionComboBox(Render.Width-160,5,150,30,[SAnchRight]);
Screen.LastChild.BoundsMakeReal();

InitSizeLabel(5,Render.Height-25,Render.Width-20,20,[SAnchBottom]);
Screen.LastChild.BoundsMakeReal();

FLDC := SCreateLabel(Screen, 'Итерация:', Render.Width-160-90-125,5,115,30, [SAnchRight], True, True, Self);

FBPD:=TSScreenButton.Create;
Screen.CreateChild(FBPD);
Screen.LastChild.SetBounds(Render.Width-160-30,5,20,30);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='+';
Screen.LastChild.FUserPointer1:=Self;
FBPD.OnChange:=TSScreenComponentProcedure(@LevyCurveFButtonDepthPlusOnChangeKT);
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FLD := SCreateLabel(Screen, '0', Render.Width-160-60,5,20,30, [SAnchRight], True, True, Self);

FBMD:=TSScreenButton.Create;
Screen.CreateChild(FBMD);
Screen.LastChild.SetBounds(Render.Width-160-90,5,20,30);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='-';
FBMD.OnChange:=TSScreenComponentProcedure(@LevyCurveFButtonDepthMinusOnChangeKT);
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FTCB:=TSScreenComboBox.Create;
Screen.CreateChild(FTCB);
FTCB.SetBounds(Render.Width-160-90-125-130-50,5,125+50,20);
FTCB.Anchors:=[SAnchRight];
FTCB.CreateItem('Кривая Леви');
FTCB.CreateItem('Дракон Хартера — Хейтуэя');
FTCB.CallBackProcedure:=TSScreenComboBoxProcedure(@TSFractalLevyCurve_CamboBox_CallBackProcedure);
FTCB.SelectItem:=0;
FTCB.FUserPointer1:=Self;
FTCB.Visible:=True;
FTCB.BoundsMakeReal();

FLD.Caption:=SStringToPChar(SStr(Depth));

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
