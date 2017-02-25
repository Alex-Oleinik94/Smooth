{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex5_2;
	interface
{$ELSE}
	program Example5_2;
	{$ENDIF}
uses
	{$IFNDEF ENGINE}
		{$IFDEF UNIX}
			{$IFNDEF ANDROID}
				cthreads,
				{$ENDIF}
			{$ENDIF}
		SaGeBaseExample,
		{$ENDIF}
	 SaGeCommonClasses
	,SaGeBase
	,SaGeFont
	,SaGeRenderConstants
	,SaGeCommon
	,SaGeScreen
	,SaGeDateTime
	,SaGeCamera
	
	,Crt
	
	,Ex5_Physics
	;
const
	QuantityObjects = 60;
type
	TSGExample5_2 = class(TSGScreenedDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
			private
		FCamera           : TSGCamera;
		FGravitationAngle : TSGSingle;
		FPhysics          : TSGPhysics;
		
		FPhysicsTime      : packed array of TSGWord;
		FPhysicsTimeCount : TSGLongWord;
		FPhysicsTimeIndex : TSGLongWord;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSGExample5_2.ClassName():TSGString;
begin
Result := 'Пример физического движка №2';
end;

constructor TSGExample5_2.Create(const VContext : ISGContext);
procedure InitCubes();
var
	i,j,r,x,k,y,kk:TSGLongWord;
	sx:TSGSingle;
begin
kk:=1;
x:=1;
while kk+1+x<QuantityObjects do
	begin
	kk+=1;
	x+=kk;
	end;
sx:=0;
x:=0;
y:=0;
j:=0;
k:=kk;
r:=0;
for i:=0 to QuantityObjects-1 do 
	begin
	FPhysics.AddObjectBegin(SGPBodyBox,True);
	FPhysics.LastObject().InitBox(8,8,8);
	FPhysics.LastObject().SetVertex((-(8.5*kk*0.5))+((x+sx)*8.5),-65+(y*8.5),0);
	FPhysics.LastObject().AddObjectEnd();
	FPhysics.LastObject().Mesh.ObjectColor:=SGVertex4fImport(0,1,0,1);
	x:=x+1;
	inc(j);
	if j>k then
		begin
		inc(r);
		j:=0;
		if k > 0 then
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

FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
FCamera.FZum := 6;
FCamera.FRotateX := 90;

FPhysicsTimeCount:=Context.Width;
SetLength(FPhysicsTime,FPhysicsTimeCount);
FillChar(FPhysicsTime[0],FPhysicsTimeCount*SizeOf(FPhysicsTime[0]),0);
FPhysicsTimeIndex:=0;

FPhysics:=TSGPhysics.Create(Context);

FPhysics.AddObjectBegin(SGPBodyHeightMap,False);
FPhysics.LastObject().InitHeightMapFromImage('Map.jpg',50,0,1024,1024);
FPhysics.LastObject().AddObjectEnd();
FPhysics.LastObject().Mesh.ObjectColor:=SGVertex4fImport(1,1,1,1);

FPhysics.AddObjectBegin(SGPBodySphere,True);
FPhysics.LastObject().InitSphere(8,16);
FPhysics.LastObject().SetVertex(0,-56,18);
FPhysics.LastObject().AddObjectEnd(50);
FPhysics.LastObject().Mesh.ObjectColor:=SGVertex4fImport(0.1,0.5,1,1);

FPhysics.AddObjectBegin(SGPBodyCapsule,True);
FPhysics.LastObject().InitCapsule(4,2.5,24);
FPhysics.LastObject().SetVertex(0,-60,-18);
FPhysics.LastObject().RotateX(90);
FPhysics.LastObject().AddObjectEnd();
FPhysics.LastObject().Mesh.ObjectColor:=SGVertex4fImport(0.5,0.1,1,1);

InitCubes();

FPhysics.SetGravitation(SGVertex3fImport(0,-9.81,0));
FPhysics.Start();

FGravitationAngle:=pi;
FPhysics.AddLigth(SGR_LIGHT0,SGVertex3fImport(2,45,160));
end;

destructor TSGExample5_2.Destroy();
begin
if FPhysics<>nil then
	FPhysics.Destroy();
inherited;
end;

procedure TSGExample5_2.Paint();
var
	i,ii      : TSGLongWord;
	dt1,dt2   : TSGDateTime;

begin
FCamera.CallAction();
Render.Color3f(1,1,1);
dt1.Get();
if FPhysics<>nil then
	begin
	FPhysics.UpDate();
	FPhysics.Paint();
	end;
dt2.Get();

FGravitationAngle += Context.ElapsedTime/100;
if FGravitationAngle>2*pi then
	FGravitationAngle -= 2*pi;
FPhysics.SetGravitation(SGVertex3fImport(
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
	Render.Vertex2f(ii/1.5,Render.Height-20*FPhysicsTime[i]-10/1.5);
	if i = 0 then
		i:= FPhysicsTimeCount -1
	else
		i-=1;
	ii+=1;
	end;
Render.EndScene();
Render.Color3f(0,0,0);
Render.BeginScene(SGR_LINE_STRIP);
Render.Vertex2f(5/1.5,Render.Height-30-5/1.5);
Render.Vertex2f(5/1.5,Render.Height-5/1.5);
Render.Vertex2f(10/1.5+FPhysicsTimeCount/1.5,Render.Height-5/1.5);
Render.Vertex2f(10/1.5+FPhysicsTimeCount/1.5,Render.Height-30-5/1.5);
Render.EndScene();
Render.Color3f(0,0,0);
Screen.Skin.Font.DrawFontFromTwoVertex2f('2ms',
	SGVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3,Render.Height-50-5/1.5-3),
	SGVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3+Screen.Skin.Font.StringLength('2ms'),Render.Height-50-5/1.5-3+Screen.Skin.Font.FontHeight));
Screen.Skin.Font.DrawFontFromTwoVertex2f('0ms',
	SGVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3,Render.Height-10-5/1.5-3),
	SGVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3+Screen.Skin.Font.StringLength('0ms'),Render.Height-10-5/1.5-3+Screen.Skin.Font.FontHeight));
Screen.Skin.Font.DrawFontFromTwoVertex2f('Physics & Draw Time',
	SGVertex2fImport(5/1.5,Render.Height-30-5/1.5-10),
	SGVertex2fImport(10/1.5+FPhysicsTimeCount/1.5,Render.Height-30-5/1.5+Screen.Skin.Font.FontHeight-10));
end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample5_2;
	RunApplication();
	{$ENDIF}
end.
