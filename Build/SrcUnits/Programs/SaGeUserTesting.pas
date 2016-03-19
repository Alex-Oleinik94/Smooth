{$INCLUDE SaGe.inc}

unit SaGeUserTesting;

interface

uses 
	 crt
	,SysUtils
	,SaGeBase
	,SaGeBased
	,SaGeContext
	,SaGeModel
	,SaGeScene
	,SaGeGamePhysics
	,SaGeGameNet
	,SaGeNet
	,SaGeLoading
	,SaGeUtils
	,SaGeMesh
	,SaGeScreen
	,SaGeRender
	,SaGeCommon;
type
	TSGUserTesting=class(TSGDrawClass)
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():string;override;
			protected
		FRadioButton : TSGRadioButton;
		
			private
			
		end;

implementation

class function TSGUserTesting.ClassName():string;
begin
Result := 'TSGRadioButton';
end;

procedure TSGUserTesting.Draw();
function PointInTriangle2D(const t1,t2,t3,v:TSGVertex2f):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	t1t2, t2t3, t3t1, vt1, vt2, vt3, s: TSGFloat;

function Prosh(const a, b, c : TSGFloat):TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	p : TSGFloat;
begin
p := (a + b + c) / 2;
Result := sqrt(p*(p-a)*(p-b)*(p-c));
end;

begin 
t1t2 := Abs(t1 - t2);
t2t3 := Abs(t2 - t3);
t3t1 := Abs(t3 - t1);

vt1 := Abs(v - t1);
vt2 := Abs(v - t2);
vt3 := Abs(v - t3);

s := Prosh(t1t2, t2t3, t3t1);

Result := Abs(
	  s
	- Prosh(t1t2, vt1, vt2)
	- Prosh(t2t3, vt3, vt2)
	- Prosh(t3t1, vt1, vt3)
		) < SGZero * s;
end;
begin
Render.InitMatrixMode(SG_2D);
Render.Color3f(1,0,0);
Render.BeginScene(SGR_LINE_LOOP);
Render.Vertex2f(200,200);
Render.Vertex2f(200,500);
Render.Vertex2f(500,200);
Render.EndScene();
FRadioButton.Checked := PointInTriangle2D(
	SGVertex2fImport(200,200),
	SGVertex2fImport(200,500),
	SGVertex2fImport(500,200),
	Context.CursorPosition());
end;

constructor TSGUserTesting.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FRadioButton := TSGRadioButton.Create();
SGScreen.CreateChild(FRadioButton);
FRadioButton.SetBounds(200,200,40,40);
FRadioButton.BoundsToNeedBounds();
FRadioButton.Visible := True;
FRadioButton.ButtonType := SGCheckButton;
end;

destructor TSGUserTesting.Destroy();
begin
FRadioButton.Destroy();
inherited Destroy();
end;

end.
