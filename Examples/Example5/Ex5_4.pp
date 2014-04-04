{$INCLUDE SaGe.inc}
program Example5_4;
uses
	{$IFDEF UNIX}
		{$IFNDEF ANDROID}
			cthreads,
			{$ENDIF}
		{$ENDIF}
	SaGeContext
	,SaGeBased
	,SaGeBase
	,SaGeBaseExample
	,SaGeUtils
	,SaGeRender
	,SaGeCommon
	,SaGePhysics
	,crt
	,SaGeScreen
	,SaGeMesh
	;
const
	QuantityObjects = 15;
type
	TSGExample5_4=class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			private
		FCamera           : TSGCamera;
		FGravitationAngle : TSGSingle;
		FPhysics          : TSGPhysics;
		
		FPhysicsTime      : packed array of TSGWord;
		FPhysicsTimeCount : TSGLongWord;
		FPhysicsTimeIndex : TSGLongWord;
		
		FBike             : TSGCustomModel;
		end;

class function TSGExample5_4.ClassName():TSGString;
begin
Result := '������ ����������� ������';
end;

constructor TSGExample5_4.Create(const VContext : TSGContext);
procedure InitCubes();
var
	i,j,r,x,k,y,kk:TSGLongWord;
	sx:TSGSingle;
begin
sx:=0;
x:=0;
y:=0;
j:=0;
kk:=4;
k:=kk;
r:=0;
for i:=0 to QuantityObjects-1 do 
	begin
	FPhysics.AddObjectBegin(SGPBodyBox,True);
	FPhysics.LastObject().InitBox(8,8,8);
	FPhysics.LastObject().SetVertex((-(8.5*kk*0.5))+((x+sx)*8.5),-65+(y*8.5),0);
	FPhysics.LastObject().AddObjectEnd();
	FPhysics.LastObject().Mesh.ObjectColor:=SGColorImport(0,1,0);
	x:=x+1;
	inc(j);
	if j>k then
		begin
		inc(r);
		j:=0;
		dec(k);
		x:=0;
		y:=y+1;
		sx:=sx+0.5;
		end;
	end;
k:=10;
end;

begin
inherited Create(VContext);
Context.ShowCursor(False);
Context.CursorInCenter:=True;

FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
FCamera.ViewMode := SG_VIEW_LOOK_AT_OBJECT;
FCamera.Up:=SGVertexImport(0,1,0);
FCamera.Location:=SGVertexImport(0,-50,-60);
FCamera.View:=SGVertexImport(0,-50,-59);

FPhysicsTimeCount:=Context.Width;
SetLength(FPhysicsTime,FPhysicsTimeCount);
FillChar(FPhysicsTime[0],FPhysicsTimeCount*SizeOf(FPhysicsTime[0]),0);
FPhysicsTimeIndex:=0;

FPhysics:=TSGPhysics.Create(Context);

FPhysics.AddObjectBegin(SGPBodyBox,False);
FPhysics.LastObject().InitBox(-140,-140,-140);
FPhysics.LastObject().AddObjectEnd();
FPhysics.LastObject().Mesh.ObjectColor:=SGColorImport(1,1,1);

FPhysics.AddObjectBegin(SGPBodySphere,True);
FPhysics.LastObject().InitSphere(8,16);
FPhysics.LastObject().SetVertex(0,-56,18);
FPhysics.LastObject().AddObjectEnd(50);
FPhysics.LastObject().Mesh.ObjectColor:=SGColorImport(0.1,0.5,1);

FPhysics.AddObjectBegin(SGPBodyCapsule,True);
FPhysics.LastObject().InitCapsule(4,2.5,24);
FPhysics.LastObject().SetVertex(0,-60,-18);
FPhysics.LastObject().RotateX(90);
FPhysics.LastObject().AddObjectEnd();
FPhysics.LastObject().Mesh.ObjectColor:=SGColorImport(0.5,0.1,1);

InitCubes();

(*
FBike:=TSGCustomModel.Create();
FBike.Context:=Self.Context;
FBike.Load3DSFromFile(SGTempDirectory+Slash+'motoBike.3ds');
FBike.WriteInfo();
*)

(*
FPhysics.AddObjectBegin(SGPBodyMesh,True);
FPhysics.LastObject().InitMesh(FBike.Objects[0]);
FPhysics.LastObject().SetDrawableMesh(FBike.Objects[0]);
FPhysics.LastObject().SetVertex(0,0,0);
FPhysics.LastObject().AddObjectEnd(10);
*)

FPhysics.SetGravitation(SGVertexImport(0,-9.81,0));
FPhysics.Start();

FGravitationAngle:=pi;
FPhysics.AddLigth(SGR_LIGHT0,SGVertexImport(2,45,160));
end;

destructor TSGExample5_4.Destroy();
begin
if FPhysics<>nil then
	FPhysics.Destroy();
inherited;
end;

procedure TSGExample5_4.Draw();
var
	i,ii      : TSGLongWord;
	dt1,dt2   : TSGDataTime;

begin
FCamera.CallAction();

dt1.Get();
if FPhysics<>nil then
	FPhysics.Draw();
dt2.Get();

FGravitationAngle += Context.ElapsedTime/100;
if FGravitationAngle>2*pi then
	FGravitationAngle -= 2*pi;
FPhysics.SetGravitation(SGVertexImport(
	9.81*2.25*sin(FGravitationAngle),
	9.81*2.25*cos(FGravitationAngle),
	9.81*2.25*sin(FGravitationAngle*3)));

Render.InitMatrixMode(SG_2D);
FPhysicsTime[FPhysicsTimeIndex]:=(dt2-dt1).GetPastMiliSeconds();
FPhysicsTimeIndex+=1;
if FPhysicsTimeIndex=FPhysicsTimeCount then
	FPhysicsTimeIndex:=0;
if FPhysicsTimeIndex=0 then
	i:=FPhysicsTimeCount-1
else
	i:=FPhysicsTimeIndex-1;
ii:=10;
Render.Color3f(1,0,0);
Render.BeginScene(SGR_LINE_STRIP);
while i<>FPhysicsTimeIndex do
	begin
	Render.Vertex2f(ii/1.5,Context.Height-20*FPhysicsTime[i]-10/1.5);
	if i = 0 then
		i:= FPhysicsTimeCount -1
	else
		i-=1;
	ii+=1;
	end;
Render.EndScene();
Render.Color3f(0,0,0);
Render.BeginScene(SGR_LINE_STRIP);
Render.Vertex2f(5/1.5,Context.Height-30-5/1.5);
Render.Vertex2f(5/1.5,Context.Height-5/1.5);
Render.Vertex2f(10/1.5+FPhysicsTimeCount/1.5,Context.Height-5/1.5);
Render.Vertex2f(10/1.5+FPhysicsTimeCount/1.5,Context.Height-30-5/1.5);
Render.EndScene();
Render.Color3f(0,0,0);
SGScreen.Font.DrawFontFromTwoVertex2f('2ms',
	SGVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3,Context.Height-50-5/1.5-3),
	SGVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3+SGScreen.Font.StringLength('2ms'),Context.Height-50-5/1.5-3+SGScreen.Font.FontHeight));
SGScreen.Font.DrawFontFromTwoVertex2f('0ms',
	SGVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3,Context.Height-10-5/1.5-3),
	SGVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3+SGScreen.Font.StringLength('0ms'),Context.Height-10-5/1.5-3+SGScreen.Font.FontHeight));
SGScreen.Font.DrawFontFromTwoVertex2f('Physics & Draw Time',
	SGVertex2fImport(5/1.5,Context.Height-30-5/1.5-10),
	SGVertex2fImport(10/1.5+FPhysicsTimeCount/1.5,Context.Height-30-5/1.5+SGScreen.Font.FontHeight-10));

if (Context.KeysPressed('W')) then
	FCamera.Move(-Context.ElapsedTime*0.7);
if (Context.KeysPressed('S')) then
	FCamera.Move(Context.ElapsedTime*0.7);
if (Context.KeysPressed('A')) then
	FCamera.MoveSidewards(-Context.ElapsedTime*0.7);
if (Context.KeysPressed('D')) then
	FCamera.MoveSidewards(Context.ElapsedTime*0.7);
FCamera.Rotate(Context.CursorPosition(SGDeferenseCursorPosition).y*0.003,Context.CursorPosition(SGDeferenseCursorPosition).x/Context.Width*Context.Height*0.003,0);
end;

begin
ExampleClass := TSGExample5_4;
RunApplication();
end.
