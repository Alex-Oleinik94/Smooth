{$INCLUDE Smooth.inc}

unit SmoothFractalSierpinskiTetrahedron;

interface

uses
	 SmoothBase
	,SmoothFractals
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
		procedure Calculate;override;
		procedure CalculateFromThread();
		procedure PushIndexes(var ObjectId:LongWord;const n,v0,v1,v2:TSVertex3f;var FVertexIndex:LongWord);Inline;
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

procedure TSFractalSierpinskiTetrahedron.PushIndexes(var ObjectId:LongWord;const n,v0,v1,v2:TSVertex3f;var FVertexIndex:LongWord);Inline;
var
	c:TSColor3f;

function GetColor(const v : TSVertex3f):TSColor3f;
begin
Result:=c0*(Abs(v-bb0)/h)+
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
	c:=GetColor(v0);
	C := C.Normalized();
	F3dObject.Objects[ObjectId].SetColor(FVertexIndex,
		c.r,c.g,c.b);
	C:=GetColor(v1);
	C := C.Normalized();
	F3dObject.Objects[ObjectId].SetColor(FVertexIndex+1,
		c.r,c.g,c.b);
	C:=GetColor(v2);
	C := C.Normalized();
	F3dObject.Objects[ObjectId].SetColor(FVertexIndex+2,
		c.r,c.g,c.b);
	end;
if FEnableNormals then
	begin
	F3dObject.Objects[ObjectId].ArNormal[FVertexIndex]^:=n;
	F3dObject.Objects[ObjectId].ArNormal[FVertexIndex+1]^:=n;
	F3dObject.Objects[ObjectId].ArNormal[FVertexIndex+2]^:=n;
	end;
FVertexIndex+=3;

AfterPushIndexes(ObjectId,FThreadsEnable,FVertexIndex);
end;

procedure TSFractalSierpinskiTetrahedron.CalculateFromThread();
var
	ObjectId:LongWord;
	FVI:LongWord;

procedure Rec(const t0,t1,t2,t3:TSVertex3f;const NowDepth:LongWord);

begin
if NowDepth=0 then
	begin
	PushIndexes(ObjectId,FArNor[3],t0,t1,t2,FVI);
	PushIndexes(ObjectId,FArNor[0],t0,t1,t3,FVI);
	PushIndexes(ObjectId,FArNor[2],t0,t2,t3,FVI);
	PushIndexes(ObjectId,FArNor[1],t1,t2,t3,FVI);
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

procedure TSFractalSierpinskiTetrahedron.Calculate();
var
	Quantity:Int64;
begin
inherited;
Clear3dObject();
Quantity:=(4**(1+FDepth));
Calculate3dObjects(Quantity,SR_TRIANGLES,S3dObjectVertexType3f);
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

procedure SierpinskiTetrahedronButtonDepthPlusOnChangeKTTet(Button:TSScreenButton);
begin
with TSFractalSierpinskiTetrahedron(Button.FUserPointer1) do
	begin
	FDepth+=1;
	Calculate;
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
		Calculate;
		FLD.Caption:=SStringToPChar(SStr(Depth));
		if Depth=0 then
			FBMD.Active:=False;
		end;
	end;
end;

constructor TSFractalSierpinskiTetrahedron.Create();
begin
inherited;
EnableColors   := True;
EnableNormals  := True;
LightingEnable := True;
HasIndexes     := False;
Threads:={$IFDEF ANDROID}0{$ELSE}1{$ENDIF};
Depth:=3;
Radius:=5;
h:=sqrt(3)*Radius/2;
c0:=SColor4fFromUInt32($FF00FF);
c1:=SColor4fFromUInt32($00FFFF);
c2:=SColor4fFromUInt32($FFFF00);
c3:=SColor4fFromUInt32($0080FF);

InitProjectionComboBox(Render.Width-160,5,150,30,[SAnchRight]);
Screen.LastChild.BoundsMakeReal();

InitEffectsComboBox(Render.Width-160,40,150,30,[SAnchRight]);
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
FBPD.OnChange:=TSScreenComponentProcedure(@SierpinskiTetrahedronButtonDepthPlusOnChangeKTTet);
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FLD := SCreateLabel(Screen, '0', Render.Width-160-60,5,20,30, [SAnchRight], True, True, Self);

FBMD:=TSScreenButton.Create;
Screen.CreateChild(FBMD);
Screen.LastChild.SetBounds(Render.Width-160-90,5,20,30);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='-';
FBMD.OnChange:=TSScreenComponentProcedure(@SierpinskiTetrahedronButtonDepthMinusOnChangeKTTet);
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FLD.Caption:=SStringToPChar(SStr(Depth));

Calculate();
end;

destructor TSFractalSierpinskiTetrahedron.Destroy();
begin
FBMD.Destroy();
FLD.Destroy();
FLDC.Destroy();
FBPD.Destroy();
inherited;
end;

end.
