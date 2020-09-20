{$INCLUDE Smooth.inc}

unit SmoothFractalSierpinskiTrianglesHorizon;

interface

uses
	 SmoothBase
	,Smooth3DObject
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothCamera
	,SmoothCommonStructs
	;

const
	SFSPSideOfQuad = 0.38;
	SFSPHeight = 0.1;
	SFSPFractalSize = 17;
	SFSPMultiplier = 0.7;

type
	TSFractalSierpinskiTrianglesHorizon = class(TSPaintableObject)
	// TSFractalSpSialProjSt ???
	//   FractalSpecialProject
	// Замена "ec" на "S"...
			public
		constructor Create(const ContextInterface : ISContext); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
		procedure Paint(); override;
			private
		FObject : TSCustomModel;
		FCamera : TSCamera;
		FLinesCount : TSUInt32;
			public
		procedure PaintFractalPlaneAt(const FloatValue : TSFloat32);
		procedure PaintObject(const Position : TSVector3f; const Rotate : TSBoolean = False);
		end;

implementation

uses
	 Smooth3DObjectS3DM
	,SmoothRenderBase
	;

constructor TSFractalSierpinskiTrianglesHorizon.Create(const ContextInterface : ISContext);
begin
inherited Create(ContextInterface);
FLinesCount := 25;

FCamera := TSCamera.Create();
FCamera.Context := ContextInterface;
FCamera.ViewMode := S_VIEW_LOOK_AT_Object;
//FCamera.ViewMode := S_VIEW_WATCH_Object;
FCamera.ChangingLookAtObject := True;
FCamera.Up       := SVertex3fImport(0, 0, 1);
FCamera.Location := SVertex3fImport(0, 0, 0);
FCamera.View     := SVertex3fImport(0, 1, 0);

FObject := TSCustomModel.Create();
FObject.Context := ContextInterface;
TS3DObjectS3DMLoader.LoadModelFromFile(FObject, 'Save Треугольник Серпинского');
FObject.LoadToVBO();
//FObject.WriteInfo();
end;

destructor TSFractalSierpinskiTrianglesHorizon.Destroy();
begin
SKill(FCamera);
SKill(FObject);
inherited;
end;

class function TSFractalSierpinskiTrianglesHorizon.ClassName() : TSString;
begin
Result := 'TSFractalSierpinskiTrianglesHorizon';
end;

procedure TSFractalSierpinskiTrianglesHorizon.PaintObject(const Position : TSVector3f; const Rotate : TSBoolean = False);
begin
Render.PushMatrix();
Render.Translate(Position);
if Rotate then
	Render.RotateF(180, 0, 0, 1);
Render.Translate(SVertex3fImport(0, - SFSPFractalSize / 20, 0));
FObject.Paint();
Render.PopMatrix();
end;

procedure TSFractalSierpinskiTrianglesHorizon.PaintFractalPlaneAt(const FloatValue : TSFloat32);
var
	Position : TSVector3f;
	Position2 : TSVector3f;
	Index, Index2, Index3 : TSInt32;
begin
Position.Import(0, 0, FloatValue);
Index := 0; // += 1
Index2 := 1; // += 2
while (Index < FLinesCount) do
	begin
	Position2 := SVertex3fImport(0, SFSPSideOfQuad * SFSPFractalSize, 0) * Index + Position;
	Position2.Import(-(Index2 div 2) * SFSPSideOfQuad * SFSPFractalSize * SFSPMultiplier, Position2.y, Position2.z);
	for Index3 := 1 to Index2 do
		PaintObject(
			SVertex3fImport(Position2.x + SFSPSideOfQuad * Index3 * SFSPFractalSize * SFSPMultiplier, Position2.y, Position2.z),
			TSBoolean(((Index mod 2) + ((Index3 + 1 * (Index mod 2)) mod 2)) mod 2));
	Index += 1;
	Index2 += 2;
	end;
end;

procedure TSFractalSierpinskiTrianglesHorizon.Paint();
begin
Render.ClearColor(1,1,1,1);
Render.Color3f(0,0,0);
FCamera.CallAction();
Render.Disable(SR_BLEND);
Render.Disable(SR_LIGHTING);
//Render.Color3f(1, 1, 1);
//PaintObject(SVertex3fImport(0,0,0));
//FObject.Paint();
PaintFractalPlaneAt(-SFSPHeight * SFSPFractalSize);
PaintFractalPlaneAt( SFSPHeight * SFSPFractalSize);
Render.Enable(SR_BLEND);
end;

end.
