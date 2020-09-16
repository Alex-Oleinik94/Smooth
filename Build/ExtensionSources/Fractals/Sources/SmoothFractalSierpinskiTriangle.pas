{$INCLUDE Smooth.inc}

unit SmoothFractalSierpinskiTriangle;

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
	TSFractalSierpinskiTriangle = class(TS3DFractal)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
			public
		function RecQuantity(const ThisDepth:Int64):Int64;
		procedure Calculate;override;
		procedure CalculateFromThread();
		procedure PushIndexes(var ObjectId:LongWord;const v1,v2,v3:TSVertex2f;var FVertexIndex,FFaceIndex:LongWord);Inline;
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

procedure TSFractalSierpinskiTriangle.PushIndexes(var ObjectId:LongWord;const v1,v2,v3:TSVertex2f;var FVertexIndex,FFaceIndex:LongWord);Inline;
begin
FVertexIndex+=3;
if not (Render.RenderType in [SRenderDirectX9,SRenderDirectX8]) then
	begin
	F3dObject.Objects[ObjectId].ArVertex2f[FVertexIndex-3]^:=v1;
	F3dObject.Objects[ObjectId].ArVertex2f[FVertexIndex-2]^:=v2;
	F3dObject.Objects[ObjectId].ArVertex2f[FVertexIndex-1]^:=v3;
	end
else
	begin
	F3dObject.Objects[ObjectId].ArVertex3f[FVertexIndex-3]^.Import(v1.x,v1.y);
	F3dObject.Objects[ObjectId].ArVertex3f[FVertexIndex-2]^.Import(v2.x,v2.y);
	F3dObject.Objects[ObjectId].ArVertex3f[FVertexIndex-1]^.Import(v3.x,v3.y);
	end;

F3dObject.Objects[ObjectId].SetFaceLine(0,FFaceIndex+0,FVertexIndex-1,FVertexIndex-2);
F3dObject.Objects[ObjectId].SetFaceLine(0,FFaceIndex+1,FVertexIndex-3,FVertexIndex-2);
F3dObject.Objects[ObjectId].SetFaceLine(0,FFaceIndex+2,FVertexIndex-1,FVertexIndex-3);
FFaceIndex+=3;

AfterPushIndexes(ObjectId,FThreadsEnable,FVertexIndex,FFaceIndex);
end;

procedure TSFractalSierpinskiTriangle.CalculateFromThread();
var
	ObjectId:LongWord;
	FVertexIndex,FFaceIndex:LongWord;
procedure Rec(const t1,t2,t3:TSVertex3f;const NowDepth:LongWord);
begin
PushIndexes(
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
PushIndexes(
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

procedure NewMengerThread(Klass:TSFractalData) ;
begin
(Klass.FFractal as TSFractalSierpinskiTriangle).CalculateFromThread();
Klass.FFractal.FThreadsData[Klass.FThreadID].FFinished:=True;
Klass.FFractal.FThreadsData[Klass.FThreadID].FData:=nil;
Klass.Destroy;
end;

procedure TSFractalSierpinskiTriangle.Calculate();
var
	Quantity:Int64;
begin
inherited;
Clear3dObject;
Quantity:=RecQuantity(FDepth);
if Render.RenderType in [SRenderDirectX9,SRenderDirectX8] then 
	Calculate3dObjects(Quantity,SR_LINES,S3dObjectVertexType3f,1)
else
	Calculate3dObjects(Quantity,SR_LINES,S3dObjectVertexType2f,1);
if FThreadsEnable then
	begin
	FThreadsData[0].FFinished:=False;
	FThreadsData[0].FData:=nil;
	CalculateFromThread;
	end
else
	begin
	CalculateFromThread;
	if FEnableVBO and (not F3dObject.LastObject().EnableVBO) then
		F3dObject.LastObject().LoadToVBO(ClearVBOAfterLoad);
	end;
end;

function TSFractalSierpinskiTriangle.RecQuantity(const ThisDepth:Int64):Int64;
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
	Calculate;
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
		Calculate;
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
{$IFNDEF ANDROID}
	Threads:=1;
	{$ENDIF}
Depth:=3;
FLightingEnable:=False;
ClearVBOAfterLoad := False;

InitProjectionComboBox(Render.Width-160,5,150,30,[SAnchRight]);
Screen.LastChild.BoundsMakeReal();

InitSizeLabel(5,Render.Height-25,Render.Width-20,20,[SAnchBottom]);
Screen.LastChild.BoundsMakeReal();
InitSaveButton(Render.Width - 160, 37, 150, 30, [SAnchRight]);

FLDC := SCreateLabel(Screen, '��������:', Render.Width-160-90-125,5,115,30, [SAnchRight], True, True, Self);

FBPD:=TSScreenButton.Create;
Screen.CreateChild(FBPD);
Screen.LastChild.SetBounds(Render.Width-160-30,5,20,30);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='+';
Screen.LastChild.FUserPointer1:=Self;
FBPD.OnChange:=TSScreenComponentProcedure(@SierpinskiTriangleButtonDepthPlusOnChangeKT);
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FLD := SCreateLabel(Screen, '0', Render.Width-160-60,5,20,30, [SAnchRight], True, True, Self);

FBMD:=TSScreenButton.Create;
Screen.CreateChild(FBMD);
Screen.LastChild.SetBounds(Render.Width-160-90,5,20,30);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='-';
FBMD.OnChange:=TSScreenComponentProcedure(@SierpinskiTriangleButtonDepthMinusOnChangeKT);
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FLD.Caption:=SStringToPChar(SStr(Depth));

Calculate;
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