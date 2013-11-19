
{$IFDEF SGREADINTERFACE}
type
	TSGGraphViewer3D=class(TSG3DFractal)
			public
		constructor Create(const VContext:PSGContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
		procedure Draw();override;
			public
		Mesh:TSG3DObject;
		FFunction:string;
		FEF:TSGEdit;
		FCBF:TSGComboBox;
		FBF:TSGButton;
		procedure Calculate;override;
		end;
{$ENDIF}


{$IFDEF SGREADIMPLEMENTATION}
procedure TSGGraphViewer3D.Draw();
begin
FCamera.CallAction();
FSunTrigonometry[0]+=pi/90		/20;
FSunTrigonometry[1]-=pi/60		/20;
FSunTrigonometry[2]+=pi/180		/20;
FSun.Import(cos(FSunTrigonometry[0]),sin(FSunTrigonometry[1]),cos(FSunTrigonometry[2]));
FSun*=FSunAbs;
Render.Color3f(1,1,1);
Render.BeginScene(SGR_POINTS);
FSun.Vertex(Render);
Render.EndScene();
Render.Enable(SGR_LIGHTING);
Render.Enable(SGR_LIGHT0);
	FSun.LightPosition(Render);
if Mesh<>nil then
	Mesh.Draw();
Render.Disable(SGR_LIGHT0);
Render.Disable(SGR_LIGHTING);
end;

procedure TSGGraphViewer3D.Calculate;
begin
inherited;
end;

constructor TSGGraphViewer3D.Create(const VContext:PSGContext);
var
	Stream:TFileStream = nil;
begin
inherited Create(VContext);
FFunction:='x*y';
Mesh:=TSG3DObject.Create();
Mesh.SetContext(FContext);
//Mesh.LoadFromOBJ('./plants1.obj');
//Mesh.AddNormals();
//Stream:=TFileStream.Create('./plant4_j.sgof',fmCreate);//plant4_with_normals.sgof
//Stream:=TFileStream.Create('./plant4_with_normals.sgof',fmOpenRead);//fmCreate);plant4_with_normals.sgof
//Mesh.SaveToStream(Stream);
//Stream.Destroy();
Stream:=TFileStream.Create('./plant4.sgof',fmOpenRead);
Mesh.LoadFromStream(Stream);
Stream.Destroy();
Mesh.LoadToVBO();
//Calculate;
end;

destructor TSGGraphViewer3D.Destroy;
begin
inherited;
end;

class function TSGGraphViewer3D.ClassName:string;
begin
Result:='Graph Viewer 3D';
end;

{$ENDIF}


