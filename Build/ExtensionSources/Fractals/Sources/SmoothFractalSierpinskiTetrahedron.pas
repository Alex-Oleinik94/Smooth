{$INCLUDE Smooth.inc}

unit SmoothFractalSierpinskiTetrahedron;

interface

uses
	 SmoothBase
	,Smooth3DFractal
	,SmoothCommon
	,SmoothCommonStructs
	,SmoothScreen
	,SmoothScreenClasses
	;

type
	TSFractalSierpinskiTetrahedron=class(TS3DFractal)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			public
		procedure Construct();override;
		procedure PolygonsConstruction();
		procedure PushPolygonData(var ObjectId:TSFractalIndexInt;const n,v0,v1,v2:TSVertex3f;var FVertexIndex:TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			protected
		FLD, FLDC : TSScreenLabel;
		FBPD, FBMD : TSScreenButton;
		Radius:TSSingle;
		FArNor:packed array[0..3] of TSVertex3f;
		bb0,bb1,bb2,bb3:TSVertex3f;
		h:single;
		c0,c1,c2,c3:TSColor3f;
		end;

implementation

uses
	 SmoothRenderBase
	,SmoothMathUtils
	,SmoothVertexObject
	,SmoothScreenBase
	,SmoothStringUtils
	;

class function TSFractalSierpinskiTetrahedron.ClassName():TSString;
begin
Result:='Тетраэдр Серпинского';
end;

procedure TSFractalSierpinskiTetrahedron.PushPolygonData(var ObjectId:TSFractalIndexInt;const n,v0,v1,v2:TSVertex3f;var FVertexIndex:TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	c:TSColor3f;

function GetColor(const v : TSVertex3f):TSColor3f;
begin
Result:= c0*(Abs(v-bb0)/h)+
		 c1*(Abs(v-bb1)/h)+
		 c2*(Abs(v-bb2)/h)+
		 c3*(Abs(v-bb3)/h);
end;

begin
F3dObject.Objects[ObjectId].ArVertex3f[FVertexIndex]^:=v0;
F3dObject.Objects[ObjectId].ArVertex3f[FVertexIndex+1]^:=v1;
F3dObject.Objects[ObjectId].ArVertex3f[FVertexIndex+2]^:=v2;
if FEnableColors then
	begin
	F3dObject.Objects[ObjectId].SetColor(FVertexIndex, GetColor(v0).Normalized());
	F3dObject.Objects[ObjectId].SetColor(FVertexIndex+1, GetColor(v1).Normalized());
	F3dObject.Objects[ObjectId].SetColor(FVertexIndex+2, GetColor(v2).Normalized());
	end;
if FEnableNormals then
	begin
	F3dObject.Objects[ObjectId].ArNormal[FVertexIndex]^:=n;
	F3dObject.Objects[ObjectId].ArNormal[FVertexIndex+1]^:=n;
	F3dObject.Objects[ObjectId].ArNormal[FVertexIndex+2]^:=n;
	end;
FVertexIndex+=3;

AfterPushingPolygonData(ObjectId,FThreadsEnable,FVertexIndex);
end;

procedure TSFractalSierpinskiTetrahedron.PolygonsConstruction();
var
	ObjectId:TSFractalIndexInt;
	FVI:TSFractalIndexInt;

procedure Rec(const t0,t1,t2,t3:TSVertex3f;const NowDepth:LongWord);

begin
if NowDepth=0 then
	begin
	PushPolygonData(ObjectId,FArNor[3],t0,t1,t2,FVI);
	PushPolygonData(ObjectId,FArNor[0],t0,t1,t3,FVI);
	PushPolygonData(ObjectId,FArNor[2],t0,t2,t3,FVI);
	PushPolygonData(ObjectId,FArNor[1],t1,t2,t3,FVI);
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
	b:TSVertex3f;
begin
bb0:=SVertex3fImport(cos(0)*Radius, sin(0)*Radius,-Radius*0.6);
bb1:=SVertex3fImport(cos(2*pi/3)*Radius, sin(2*pi/3)*Radius,-Radius*0.6);
bb2:=SVertex3fImport(cos(4*pi/3)*Radius, sin(4*pi/3)*Radius,-Radius*0.6);
bb3:=SVertex3fImport(0, 0, Radius*0.6);
ObjectId:=0;
FVI:=0;
FArNor[0]:=STriangleNormal(bb0,bb1,bb3);
FArNor[1]:=STriangleNormal(bb1,bb2,bb3);
FArNor[2]:=STriangleNormal(bb2,bb0,bb3);
FArNor[3]:=STriangleNormal(bb0,bb2,bb1);
b:=(bb0+bb1+bb2+bb3)/4;
Rec(bb0-b,bb1-b,bb2-b,bb3-b,FDepth);
if FThreadsEnable then
	if (ObjectId>=0) and (ObjectId<=F3dObject.QuantityObjects-1) then
		if F3dObjectsInfo[ObjectId]=S_FALSE then
			F3dObjectsInfo[ObjectId]:=S_TRUE;
end;

procedure TSFractalSierpinskiTetrahedron.Construct();
var
	NumberOfPolygons:TSFractalIndexInt;
begin
inherited;
Clear3dObject();
NumberOfPolygons:=(4**(1+FDepth));
Construct3dObjects(NumberOfPolygons,SR_TRIANGLES,S3dObjectVertexType3f);
if FThreadsEnable then
	begin
	FThreadsData[0].Clear(Self);
	PolygonsConstruction();
	end
else
	begin
	PolygonsConstruction();
	if (FMemoryDataType = SVRAM) and (not F3dObject.LastObject().EnableVBO) then
		F3dObject.LastObject().LoadToVBO(ClearRAMAfterLoadToVRAM);
	end;
end;

procedure SierpinskiTetrahedronButtonDepthPlusOnChangeKTTet(Button:TSScreenButton);
begin
with TSFractalSierpinskiTetrahedron(Button.FUserPointer1) do
	begin
	FDepth+=1;
	Construct;
	FLD.Caption:=SStringToPChar(SStr(Depth));
	FBMD.Active:=True;
	end;
end;


procedure SierpinskiTetrahedronButtonDepthMinusOnChangeKTTet(Button:TSScreenButton);
begin
with TSFractalSierpinskiTetrahedron(Button.FUserPointer1) do
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

constructor TSFractalSierpinskiTetrahedron.Create();
begin
inherited;
HasIndexes     := False;
LightingEnable := True;
EnableColors   := True;
EnableNormals  := True;
Threads:={$IFDEF ANDROID}0{$ELSE}1{$ENDIF};
Depth:=3;
Radius:=5;
h:=sqrt(3)*Radius/2;
c0:=SColor4fFromUInt32($FF00FF);
c1:=SColor4fFromUInt32($00FFFF);
c2:=SColor4fFromUInt32($FFFF00);
c3:=SColor4fFromUInt32($0080FF);

InitProjectionComboBox(Render.Width-160,5,150,30,[SAnchRight]).BoundsMakeReal();
InitEffectsComboBox(Render.Width-160,40,150,30,[SAnchRight]).BoundsMakeReal();

InitSizeLabel(5,Render.Height-25,Render.Width-20,20,[SAnchBottom]);
Screen.LastInternalComponent.BoundsMakeReal();

FLDC := SCreateLabel(Screen, 'Итерация:', Render.Width-160-90-125,5,115,30, [SAnchRight], True, True, Self);

FBPD:=TSScreenButton.Create;
Screen.CreateInternalComponent(FBPD);
Screen.LastInternalComponent.SetBounds(Render.Width-160-30,5,20,30);
Screen.LastInternalComponent.Anchors:=[SAnchRight];
Screen.LastInternalComponent.Caption:='+';
Screen.LastInternalComponent.FUserPointer1:=Self;
FBPD.OnChange:=TSScreenComponentProcedure(@SierpinskiTetrahedronButtonDepthPlusOnChangeKTTet);
Screen.LastInternalComponent.Visible:=True;
Screen.LastInternalComponent.BoundsMakeReal();

FLD := SCreateLabel(Screen, '0', Render.Width-160-60,5,20,30, [SAnchRight], True, True, Self);

FBMD:=TSScreenButton.Create;
Screen.CreateInternalComponent(FBMD);
Screen.LastInternalComponent.SetBounds(Render.Width-160-90,5,20,30);
Screen.LastInternalComponent.Anchors:=[SAnchRight];
Screen.LastInternalComponent.Caption:='-';
FBMD.OnChange:=TSScreenComponentProcedure(@SierpinskiTetrahedronButtonDepthMinusOnChangeKTTet);
Screen.LastInternalComponent.FUserPointer1:=Self;
Screen.LastInternalComponent.Visible:=True;
Screen.LastInternalComponent.BoundsMakeReal();

FLD.Caption:=SStringToPChar(SStr(Depth));

Construct();
end;

destructor TSFractalSierpinskiTetrahedron.Destroy();
begin
SKill(FBMD);
SKill(FLD);
SKill(FLDC);
SKill(FBPD);
inherited;
end;

end.
