{$INCLUDE Smooth.inc}

unit SmoothFractalMinkowskiCurve;

interface

uses
	 SmoothBase
	,SmoothFractals
	,SmoothCommonStructs
	,SmoothContextInterface
	,SmoothScreen
	,SmoothScreenClasses
	;

type
	TSFractalMinkowskiCurve=class(TS3DFractal)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
			public
		procedure Calculate();override;
		procedure CalculateFromThread();
		procedure PushIndexes(var ObjectId : TSUInt32; const v : TSVertex2f; var FVertexIndex:TSUInt32); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			protected
		FLD, FLDC : TSScreenLabel;
		FBPD, FBMD : TSScreenButton;
			protected
		c17, c27, c37, c57 : TSFloat64;
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothRenderBase
	,SmoothVertexObject
	,SmoothScreenBase
	,SmoothMathUtils
	;

class function TSFractalMinkowskiCurve.ClassName():TSString;
begin
Result := 'Кривая Минковского';
end;

procedure TSFractalMinkowskiCurve.PushIndexes(var ObjectId:LongWord;const v:TSVertex2f;var FVertexIndex:LongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Render.RenderType in [SRenderDirectX9,SRenderDirectX8] then
	F3dObject.Objects[ObjectId].ArVertex3f[FVertexIndex]^.Import(v.x,v.y)
else
	F3dObject.Objects[ObjectId].ArVertex2f[FVertexIndex]^:=v;

FVertexIndex+=1;

AfterPushIndexes(ObjectId,FThreadsEnable,FVertexIndex);
end;

procedure TSFractalMinkowskiCurve.CalculateFromThread();
var
	ObjectId:LongWord;
	FVI:LongWord;

procedure Rec(const t1,t2:TSVertex2f;const NowDepth:LongWord);
var
	e1,e2,e3,v1,v2,v3,v4:TSVertex2f;
begin
if NowDepth>0 then
	begin
	e1:=SVertex2fImport(t2.y-t1.y,t1.x-t2.x)*0.25;
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
	PushIndexes(ObjectId,t2,FVI);
end;

begin
ObjectId:=0;
FVI:=0;
PushIndexes(ObjectId,SVertex2fImport(-6,-3.5),FVI);
Rec(SVertex2fImport(-6,-3.5),SVertex2fImport(6,3.5),Depth);
if FThreadsEnable then
	if (ObjectId>=0) and (ObjectId<=F3dObject.QuantityObjects-1) then
		if F3dObjectsInfo[ObjectId]=S_FALSE then
			F3dObjectsInfo[ObjectId]:=S_TRUE;
end;

procedure TSFractalMinkowskiCurve.Calculate();
var
	Quantity:TSMaxEnum;
begin
inherited;
Clear3dObject();
Quantity:=(8**FDepth)+1;
if Render.RenderType in [SRenderDirectX9,SRenderDirectX8] then 
	Calculate3dObjects(Quantity,SR_LINE_STRIP,S3dObjectVertexType3f)
else
	Calculate3dObjects(Quantity,SR_LINE_STRIP,S3dObjectVertexType2f);
if FThreadsEnable then
	begin
	FThreadsData[0].FFinished:=False;
	FThreadsData[0].FData:=nil;
	CalculateFromThread();
	end
else
	begin
	CalculateFromThread();
	if FEnableVBO and (not F3dObject.LastObject().EnableVBO) then
		F3dObject.LastObject().LoadToVBO();
	end;
end;

procedure MinkowskiCurveIncDepth(Button:TSScreenButton);
begin
with TSFractalMinkowskiCurve(Button.FUserPointer1) do
	begin
	FDepth+=1;
	Calculate();
	FLD.Caption:=SStringToPChar(SStr(Depth));
	FBMD.Active:=True;
	end;
end;


procedure MinkowskiCurveDecDepth(Button:TSScreenButton);
begin
with TSFractalMinkowskiCurve(Button.FUserPointer1) do
	begin
	if Depth>0 then
		begin
		FDepth-=1;
		Calculate();
		FLD.Caption:=SStringToPChar(SStr(Depth));
		if FDepth=0 then
			FBMD.Active:=False;
		end;
	end;
end;

constructor TSFractalMinkowskiCurve.Create(const VContext:ISContext);
begin
inherited;
c17:=1/7;
c27:=2/7;
c37:=3/7;
c57:=5/7;

EnableColors:=False;
EnableNormals:=False;
{$IFNDEF ANDROID}
	Threads:=1;
	{$ENDIF}
Depth:=3;
LightingEnable:=False;
HasIndexes := False;

InitProjectionComboBox(Render.Width-160,5,150,30,[SAnchRight]);
Screen.LastChild.BoundsMakeReal();

InitSizeLabel(5,Render.Height-25,Render.Width-20,20,[SAnchBottom]);
Screen.LastChild.BoundsMakeReal();

FLDC := SCreateLabel(Screen, 'Итерация:', Render.Width-160-90-125,5,115,30, [SAnchRight], True, True, Self);

FBPD:=TSScreenButton.Create();
Screen.CreateChild(FBPD);
Screen.LastChild.SetBounds(Render.Width-160-30,5,20,30);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='+';
Screen.LastChild.FUserPointer1:=Self;
FBPD.OnChange:=TSScreenComponentProcedure(@MinkowskiCurveIncDepth);
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FLD := SCreateLabel(Screen, '0', Render.Width-160-60,5,20,30, [SAnchRight], True, True, Self);

FBMD:=TSScreenButton.Create();
Screen.CreateChild(FBMD);
Screen.LastChild.SetBounds(Render.Width-160-90,5,20,30);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='-';
FBMD.OnChange:=TSScreenComponentProcedure(@MinkowskiCurveDecDepth);
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FLD.Caption:=SStringToPChar(SStr(Depth));

Calculate();
end;

destructor TSFractalMinkowskiCurve.Destroy();
begin
SKill(FBMD);
SKill(FLD);
SKill(FLDC);
SKill(FBPD);
inherited;
end;

end.
