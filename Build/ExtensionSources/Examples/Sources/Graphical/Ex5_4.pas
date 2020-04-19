{$INCLUDE Smooth.inc}
{$IFDEF ENGINE}
	unit Ex5_4;
	interface
{$ELSE}
	program Example5_4;
	{$ENDIF}
uses
	{$IF defined(UNIX) and (not defined(ANDROID)) and (not defined(ENGINE))}
		cthreads,
		{$ENDIF}
	 SmoothContextInterface
	,SmoothContextClasses
	,SmoothBase
	,SmoothFileUtils
	,SmoothFont
	,SmoothRenderBase
	,SmoothCommonStructs
	,SmoothScreenBase
	,SmoothScreenClasses
	,Smooth3dObject
	,SmoothDateTime
	,SmoothCamera
	,SmoothContextUtils
	{$IF not defined(ENGINE)}
		,SmoothConsolePaintableTools
		,SmoothConsoleHandler
		{$ENDIF}
	
	,Crt
	
	,Ex5_Physics
	;
const
	QuantityObjects = 15;
	GravitationConst = 9.81*2.25;
type
	TSExample5_4 = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
			private
		FCamera           : TSCamera;
		FGravitationAngle : TSSingle;
		FPhysics          : TSPhysics;
		
		FPhysicsTime      : packed array of TSWord;
		FPhysicsTimeCount : TSLongWord;
		FPhysicsTimeIndex : TSLongWord;
		
		FBike             : TSCustomModel;
		
		FGravitationFlag : TSBoolean;
		
		FFont : TSFont;
		FHelpLabel : TSScreenLabel;
			private
		procedure KeyControl();
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSExample5_4.ClassName():TSString;
begin
Result := 'Пример физического движка PAPPE';
end;

constructor TSExample5_4.Create(const VContext : ISContext);
const 
	EnableCullFaceInExample = True;
procedure InitCubes();
var
	i,j,r,x,k,y,kk:TSLongWord;
	sx:TSSingle;
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
	FPhysics.AddObjectBegin(SPBodyBox,True);
	FPhysics.LastObject().InitBox(8,8,8);
	FPhysics.LastObject().SetVertex((-(8.5*kk*0.5))+((x+sx)*8.5),-65+(y*8.5),0);
	FPhysics.LastObject().AddObjectEnd();
	FPhysics.LastObject().Object3d.ObjectColor:=SVertex4fImport(0,1,0,1);
	FPhysics.LastObject().Object3d.EnableCullFace := EnableCullFaceInExample;
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

FCamera:=TSCamera.Create();
FCamera.SetContext(Context);
FCamera.ViewMode := S_VIEW_LOOK_AT_OBJECT;
FCamera.Up:=SVertex3fImport(0,1,0);
FCamera.Location:=SVertex3fImport(0,-50,-60);
FCamera.View:=SVertex3fImport(0,0,1);

FPhysicsTimeCount:=Context.Width;
SetLength(FPhysicsTime,FPhysicsTimeCount);
FillChar(FPhysicsTime[0],FPhysicsTimeCount*SizeOf(FPhysicsTime[0]),0);
FPhysicsTimeIndex:=0;

FPhysics:=TSPhysics.Create(Context);

FPhysics.AddObjectBegin(SPBodySphere,True);
FPhysics.LastObject().InitSphere(8,16);
FPhysics.LastObject().SetVertex(0,-56,18);
FPhysics.LastObject().AddObjectEnd(50);
FPhysics.LastObject().Object3d.ObjectColor:=SVertex4fImport(0.1,0.5,1,1);
FPhysics.LastObject().Object3d.EnableCullFace := EnableCullFaceInExample;

FPhysics.AddObjectBegin(SPBodyCapsule,True);
FPhysics.LastObject().InitCapsule(4,2.5,24);
FPhysics.LastObject().SetVertex(0,-60,-18);
FPhysics.LastObject().RotateX(90);
FPhysics.LastObject().AddObjectEnd();
FPhysics.LastObject().Object3d.ObjectColor:=SVertex4fImport(0.5,0.1,1,1);
FPhysics.LastObject().Object3d.EnableCullFace := EnableCullFaceInExample;

InitCubes();

FPhysics.AddObjectBegin(SPBodyBox,False);
FPhysics.LastObject().InitBox(-140,-140,-140);
FPhysics.LastObject().AddObjectEnd();
FPhysics.LastObject().Object3d.ObjectColor:=SVertex4fImport(1,1,1,0.7);
FPhysics.LastObject().Object3d.EnableCullFace := EnableCullFaceInExample;

(*
FBike:=TSCustomModel.Create();
FBike.Context:=Self.Context;
FBike.Load3DSFromFile(STempDirectory+Slash+'motoBike.3ds');
FBike.WriteInfo();
*)

(*
FPhysics.AddObjectBegin(SPBody3dObject,True);
FPhysics.LastObject().Init3dObject(FBike.Objects[0]);
FPhysics.LastObject().SetDrawable3dObject(FBike.Objects[0]);
FPhysics.LastObject().SetVertex(0,0,0);
FPhysics.LastObject().AddObjectEnd(10);
*)

FPhysics.SetGravitation(SVertex3fImport(0,-GravitationConst,0));
FPhysics.Start();

FGravitationAngle:=pi;
FPhysics.AddLigth(SR_LIGHT0,SVertex3fImport(2,45,160));

FFont := SCreateFontFromFile(Context, SDefaultFontFileName);

FHelpLabel := SCreateLabel(Screen,
	'Press C to change mouse mode;' + DefaultEndOfLine +
	'Use WASD to move camera;' + DefaultEndOfLine +
	'Use Mouse or QE to rotate camera;' + DefaultEndOfLine +
	'Use Space or X to move up or down.', 
	Render.Width - 250, Render.Height - (FFont.FontHeight + 2) * 4 - 10, 240, (FFont.FontHeight + 2) * 4,
	FFont, [SAnchRight, SAnchBottom], True, True);
end;

destructor TSExample5_4.Destroy();
begin
if FBike <> nil then
	FBike.Destroy();
if FCamera <> nil then
	FCamera.Destroy();
if FPhysics<>nil then
	FPhysics.Destroy();
if FHelpLabel<>nil then
	FHelpLabel.Destroy();
if FFont<>nil then
	FFont.Destroy();
inherited;
end;

procedure TSExample5_4.Paint();
var
	i,ii      : TSLongWord;
	dt1,dt2   : TSDateTime;
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
	FGravitationAngle += Context.ElapsedTime/500;
	if FGravitationAngle>2*pi then
		FGravitationAngle -= 2*pi;
	FPhysics.SetGravitation(SVertex3fImport(
		GravitationConst*sin(-FGravitationAngle),
		GravitationConst*cos(-FGravitationAngle),
		GravitationConst*sin(-FGravitationAngle*3)));
	end;

if FPhysics<>nil then
	begin
	Render.InitMatrixMode(S_2D);
	FPhysicsTime[FPhysicsTimeIndex]:=(dt2-dt1).GetPastMilliseconds();
	FPhysicsTimeIndex+=1;
	if FPhysicsTimeIndex=FPhysicsTimeCount then
		FPhysicsTimeIndex:=0;
	if FPhysicsTimeIndex=0 then
		i:=FPhysicsTimeCount-1
	else
		i:=FPhysicsTimeIndex-1;
	ii:=10;
	Render.Color3f(1,0,0);
	Render.BeginScene(SR_LINE_STRIP);
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
	Render.BeginScene(SR_LINE_STRIP);
	Render.Vertex2f(5/1.5,Render.Height-30-5/1.5);
	Render.Vertex2f(5/1.5,Render.Height-5/1.5);
	Render.Vertex2f(10/1.5+FPhysicsTimeCount/1.5,Render.Height-5/1.5);
	Render.Vertex2f(10/1.5+FPhysicsTimeCount/1.5,Render.Height-30-5/1.5);
	Render.EndScene();
	Render.Color3f(1,1,0);
	(Screen as TSScreenComponent).Skin.Font.DrawFontFromTwoVertex2f('2ms',
		SVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3,Render.Height-50-5/1.5-3),
		SVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3+(Screen as TSScreenComponent).Skin.Font.StringLength('2ms'),Render.Height-50-5/1.5-3+(Screen as TSScreenComponent).Skin.Font.FontHeight));
	(Screen as TSScreenComponent).Skin.Font.DrawFontFromTwoVertex2f('0ms',
		SVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3,Render.Height-10-5/1.5-3),
		SVertex2fImport(10/1.5+FPhysicsTimeCount/1.5+3+(Screen as TSScreenComponent).Skin.Font.StringLength('0ms'),Render.Height-10-5/1.5-3+(Screen as TSScreenComponent).Skin.Font.FontHeight));
	(Screen as TSScreenComponent).Skin.Font.DrawFontFromTwoVertex2f('Physics Time',
		SVertex2fImport(5/1.5,Render.Height-30-5/1.5-10),
		SVertex2fImport(10/1.5+FPhysicsTimeCount/1.5,Render.Height-30-5/1.5+(Screen as TSScreenComponent).Skin.Font.FontHeight-10));
	end;

KeyControl();
end;

procedure TSExample5_4.KeyControl();
const
	RotateConst = 0.002;
var
	Q, E : TSBoolean;
	RotateZ : TSFloat = 0;
begin
if (Context.KeyPressed and (Context.KeyPressedChar = 'C') and (Context.KeyPressedType = SUpKey)) then
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
	FPhysics.SetGravitation(SVertex3fImport(0,-GravitationConst,0));
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
	FCamera.Rotate(Context.CursorPosition(SDeferenseCursorPosition).y*RotateConst,Context.CursorPosition(SDeferenseCursorPosition).x/Context.Width*Context.Height*RotateConst,RotateZ*RotateConst)
else
	FCamera.Rotate(0, 0, RotateZ*RotateConst);
end;

{$IFNDEF ENGINE}
	begin
	SConsoleRunPaintable(TSExample5_4, SSystemParamsToConsoleHandlerParams());
	{$ENDIF}
end.
