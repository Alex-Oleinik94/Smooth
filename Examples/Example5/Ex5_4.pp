{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex5_4;
	interface
{$ELSE}
	program Example5_4;
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
	,SaGeBased
	,SaGeBase
	,SaGeUtils
	,SaGeRenderConstants
	,SaGeCommon
	,SaGePhysics
	,crt
	,SaGeScreen
	,SaGeMesh
	;
const
	QuantityObjects = 15;
	GravitationConst = 9.81*2.25;
type
	TSGExample5_4 = class(TSGScreenedDrawable)
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
		
		FBike             : TSGCustomModel;
		
		FGravitationFlag : TSGBoolean;
			private
		procedure KeyControl();
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSGExample5_4.ClassName():TSGString;
begin
Result := 'Пример физического движка №4';
end;

constructor TSGExample5_4.Create(const VContext : ISGContext);
const 
	EnableCullFaceInExample = True;
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
	FPhysics.LastObject().Mesh.ObjectColor:=SGVertex4fImport(0,1,0,1);
	FPhysics.LastObject().Mesh.EnableCullFace := EnableCullFaceInExample;
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
FBike := nil;
FGravitationFlag := False;

Context.CursorCentered := True;
Context.ShowCursor(False);

FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
FCamera.ViewMode := SG_VIEW_LOOK_AT_OBJECT;
FCamera.Up:=SGVertex3fImport(0,1,0);
FCamera.Location:=SGVertex3fImport(0,-50,-60);
FCamera.View:=SGVertex3fImport(0,0,1);

FPhysicsTimeCount:=Context.Width;
SetLength(FPhysicsTime,FPhysicsTimeCount);
FillChar(FPhysicsTime[0],FPhysicsTimeCount*SizeOf(FPhysicsTime[0]),0);
FPhysicsTimeIndex:=0;

FPhysics:=TSGPhysics.Create(Context);

FPhysics.AddObjectBegin(SGPBodySphere,True);
FPhysics.LastObject().InitSphere(8,16);
FPhysics.LastObject().SetVertex(0,-56,18);
FPhysics.LastObject().AddObjectEnd(50);
FPhysics.LastObject().Mesh.ObjectColor:=SGVertex4fImport(0.1,0.5,1,1);
FPhysics.LastObject().Mesh.EnableCullFace := EnableCullFaceInExample;

FPhysics.AddObjectBegin(SGPBodyCapsule,True);
FPhysics.LastObject().InitCapsule(4,2.5,24);
FPhysics.LastObject().SetVertex(0,-60,-18);
FPhysics.LastObject().RotateX(90);
FPhysics.LastObject().AddObjectEnd();
FPhysics.LastObject().Mesh.ObjectColor:=SGVertex4fImport(0.5,0.1,1,1);
FPhysics.LastObject().Mesh.EnableCullFace := EnableCullFaceInExample;

InitCubes();

FPhysics.AddObjectBegin(SGPBodyBox,False);
FPhysics.LastObject().InitBox(-140,-140,-140);
FPhysics.LastObject().AddObjectEnd();
FPhysics.LastObject().Mesh.ObjectColor:=SGVertex4fImport(1,1,1,0.7);
FPhysics.LastObject().Mesh.EnableCullFace := EnableCullFaceInExample;

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

FPhysics.SetGravitation(SGVertex3fImport(0,-GravitationConst,0));
FPhysics.Start();

FGravitationAngle:=pi;
FPhysics.AddLigth(SGR_LIGHT0,SGVertex3fImport(2,45,160));
end;

destructor TSGExample5_4.Destroy();
begin
if FBike <> nil then
	FBike.Destroy();
if FCamera <> nil then
	FCamera.Destroy();
if FPhysics<>nil then
	FPhysics.Destroy();
inherited;
end;

procedure TSGExample5_4.Paint();
var
	i,ii      : TSGLongWord;
	dt1,dt2   : TSGDataTime;
begin
FCamera.CallAction();
Render.Color3f(1,1,1);

if FPhysics<>nil then
	begin
	dt1.Get();
	FPhysics.UpDate();
	dt2.Get();
	FPhysics.Paint();
	end;

if (not FGravitationFlag) then
	begin
	FGravitationAngle += Context.ElapsedTime/100;
	if FGravitationAngle>2*pi then
		FGravitationAngle -= 2*pi;
	FPhysics.SetGravitation(SGVertex3fImport(
		GravitationConst*sin(FGravitationAngle),
		GravitationConst*cos(FGravitationAngle),
		GravitationConst*sin(FGravitationAngle*3)));
	end;

if FPhysics<>nil then
	begin
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
	Render.Color3f(1,0,1);
	Render.BeginScene(SGR_LINE_STRIP);
	Render.Vertex2f(5/1.5,Render.Height-30-5/1.5);
	Render.Vertex2f(5/1.5,Render.Height-5/1.5);
	Render.Vertex2f(10/1.5+FPhysicsTimeCount/1.5,Render.Height-5/1.5);
	Render.Vertex2f(10/1.5+FPhysicsTimeCount/1.5,Render.Height-30-5/1.5);
	Render.EndScene();
	Render.Color3f(1,1,0);
	Screen.Font.DrawFontFromTwoVertex2f('2ms',
		SGVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3,Render.Height-50-5/1.5-3),
		SGVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3+Screen.Font.StringLength('2ms'),Render.Height-50-5/1.5-3+Screen.Font.FontHeight));
	Screen.Font.DrawFontFromTwoVertex2f('0ms',
		SGVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3,Render.Height-10-5/1.5-3),
		SGVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3+Screen.Font.StringLength('0ms'),Render.Height-10-5/1.5-3+Screen.Font.FontHeight));
	Screen.Font.DrawFontFromTwoVertex2f('Physics Time',
		SGVertex2fImport(5/1.5,Render.Height-30-5/1.5-10),
		SGVertex2fImport(10/1.5+FPhysicsTimeCount/1.5,Render.Height-30-5/1.5+Screen.Font.FontHeight-10));
	end;

KeyControl();
end;

procedure TSGExample5_4.KeyControl();
const
	RotateConst = 0.002;
var
	Q, E : TSGBoolean;
	RotateZ : TSGFloat = 0;
begin
if (Context.KeyPressed and (Context.KeyPressedChar = #27) and (Context.KeyPressedType = SGUpKey)) then
	begin
	Context.CursorCentered := not Context.CursorCentered;
	Context.ShowCursor(not Context.CursorCentered);
	end;

Q := Context.KeysPressed('Q');
E := Context.KeysPressed('E');
if (Q xor E) then
	begin
	if Q then
		RotateZ := Context.ElapsedTime*2
	else
		RotateZ := -Context.ElapsedTime*2;
	end;

if (Context.KeysPressed('Z')) then
	begin
	FGravitationFlag := True;
	FPhysics.SetGravitation(SGVertex3fImport(0,-GravitationConst,0));
	end
else
	FGravitationFlag := False;
if (Context.KeysPressed('W')) then
	FCamera.Move(Context.ElapsedTime*0.7);
if (Context.KeysPressed('S')) then
	FCamera.Move(-Context.ElapsedTime*0.7);
if (Context.KeysPressed('A')) then
	FCamera.MoveSidewards(-Context.ElapsedTime*0.7);
if (Context.KeysPressed('D')) then
	FCamera.MoveSidewards(Context.ElapsedTime*0.7);
if (Context.KeysPressed(' ')) then
	FCamera.MoveUp(Context.ElapsedTime*0.7);
if (Context.KeysPressed('X')) then
	FCamera.MoveUp(-Context.ElapsedTime*0.7);
if Context.CursorCentered then
	FCamera.Rotate(Context.CursorPosition(SGDeferenseCursorPosition).y*RotateConst,Context.CursorPosition(SGDeferenseCursorPosition).x/Context.Width*Context.Height*RotateConst,RotateZ*RotateConst)
else
	FCamera.Rotate(0, 0, RotateZ*RotateConst);
end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample5_4;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
