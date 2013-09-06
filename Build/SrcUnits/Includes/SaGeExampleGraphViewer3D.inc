
{$IFDEF SGREADINTERFACE}
type
	TSGGraphViewer3D=class(TSG3DFractal)
			public
		constructor Create;override;
		destructor Destroy;override;
		class function ClassName:string;override;
			public
		FFunction:string;
		FEF:TSGEdit;
		FCBF:TSGComboBox;
		FBF:TSGButton;
		procedure Calculate;override;
		end;
{$ENDIF}


{$IFDEF SGREADIMPLEMENTATION}

procedure TSGGraphViewer3D.Calculate;
begin
inherited;
end;

constructor TSGGraphViewer3D.Create;
begin
inherited;
FFunction:='x*y';

Calculate;
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


