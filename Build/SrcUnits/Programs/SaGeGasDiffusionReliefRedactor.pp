{$INCLUDE SaGe.inc}

unit SaGeGasDiffusionReliefRedactor;

interface

uses
	 dos
	,SaGeBase
	,Classes
	,SaGeBased
	,SaGeMesh
	,SaGeContext
	,SaGeRender
	,SaGeCommon
	,SaGeUtils
	,SaGeScreen
	,SaGeImages
	,SaGeImagesBase;
type
	TSGGasDiffusionSingleRelief = object
		FEnabled : Boolean;
		FType : Boolean;
		FPoints : packed array of TSGVertex;
		FPolygones : packed array of packed array of LongWord;
		
		procedure Draw(const VRender : TSGRender);
		procedure DrawLines(const VRender : TSGRender);
		procedure DrawPolygones(const VRender : TSGRender);
		procedure ExportToMesh(const VMesh : TSGCustomModel;const index : byte = -1);
		procedure ExportToMeshLines(const VMesh : TSGCustomModel;const index : byte = -1;const WithVector : Boolean = False);
		procedure ExportToMeshPolygones(const VMesh : TSGCustomModel;const index : byte = -1);
		procedure Clear();
		procedure InitBase();
		end;
type
	TSGGasDiffusionRelief = object
		FData : packed array [0..5] of TSGGasDiffusionSingleRelief;
		
		procedure Draw(const VRender : TSGRender);
		procedure Clear();
		procedure InitBase();
		procedure ExportToMesh(const VMesh : TSGCustomModel);
		end;
	PSGGasDiffusionSingleRelief = ^ TSGGasDiffusionSingleRelief;
	PSGGasDiffusionRelief = ^ TSGGasDiffusionRelief;
type
	TSGGDRRedactingType = (TSGGDRRedactingPoints,TSGGDRRedactingLines,TSGGDRRedactingPolygones);
	TSGGDRPrimetiveIndexes = packed array of TSGLongWord;
	TSGGasDiffusionReliefRedactor = class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		procedure Draw();override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		FRelief : PSGGasDiffusionRelief;
		FSingleRelief : PSGGasDiffusionSingleRelief;
		
		FPrimetiveTypeButtonPoints,
			FPrimetiveTypeButtonLines,
			FPrimetiveTypeButtonPolygones : TSGButton;
		FCutPolygoneButton : TSGButton;
		FFont : TSGFont;
		
		FRedactingType : TSGGDRRedactingType;
		FInRedactoring : TSGBoolean;
		FSelectedPrimetives : TSGGDRPrimetiveIndexes;
		FPixelPrimitives : TSGGDRPrimetiveIndexes;
		FInCutting : TSGBoolean;
			private
		procedure UpDate();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure UpDatePointsShifting();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure DrawRedactoringRelief();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ProcessPixelPrimitives();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SelectAllPrimetives();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			private
		class function ExistsIndexInPrimetiveIndexes(const VIndexes : TSGGDRPrimetiveIndexes; const VIndex : TSGLongWord):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure AddIndexInPrimetiveIndexes(var VIndexes : TSGGDRPrimetiveIndexes; const VIndex : TSGLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure DelIndexInPrimetiveIndexes(var VIndexes : TSGGDRPrimetiveIndexes; const VIndex : TSGLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		procedure SetActiveSingleRelief(const index : LongInt = -1);
		procedure StartRedactoring();
		procedure StopRedactoring();
			public
		property Relief : PSGGasDiffusionRelief read FRelief write FRelief;
		end;

function GetReliefMatrix(const i : byte) : TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

var
	Matrixes : array[-1..5] of TSGMatrix4;

class procedure TSGGasDiffusionReliefRedactor.DelIndexInPrimetiveIndexes(var VIndexes : TSGGDRPrimetiveIndexes; const VIndex : TSGLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii : LongWord;
begin
if VIndexes <> nil then if Length(VIndexes)>0 then
	begin
	ii := Length(VIndexes);
	for i := 0 to High(VIndexes) do
		if VIndexes[i] = VIndex then
			begin
			ii := i;
			break;
			end;
	if ii <> Length(VIndexes) then
		begin
		if ii <> High(VIndexes) then
			for i := ii to High(VIndexes)-1 do
				VIndexes[i] := VIndexes[i + 1];
		SetLength(VIndexes,Length(VIndexes)-1);
		if Length(VIndexes)=0 then
			VIndexes := nil;
		end;
	end;
end;

class procedure TSGGasDiffusionReliefRedactor.AddIndexInPrimetiveIndexes(var VIndexes : TSGGDRPrimetiveIndexes; const VIndex : TSGLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if VIndexes = nil then
	SetLength(VIndexes,1)
else
	SetLength(VIndexes,Length(VIndexes)+1);
VIndexes[High(VIndexes)] := VIndex;
end;

class function TSGGasDiffusionReliefRedactor.ExistsIndexInPrimetiveIndexes(const VIndexes : TSGGDRPrimetiveIndexes; const VIndex : TSGLongWord):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
Result := False;
if VIndexes <> nil then if (Length(VIndexes)>0) then
	for i := 0 to High(VIndexes) do
		if VIndexes[i] = VIndex then
			begin
			Result := True;
			break;
			end;
end;

procedure TSGGasDiffusionReliefRedactor.SelectAllPrimetives();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
SetLength(FPixelPrimitives,Length(FSingleRelief^.FPoints));
for i := 0 to High(FPixelPrimitives) do
	FPixelPrimitives[i] := i;
ProcessPixelPrimitives();
end;

function GetReliefMatrix(const i : byte) : TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Matrixes[i];
end;

procedure mmmFPrimetiveTypeButton(Button : TSGButton);
begin with TSGGasDiffusionReliefRedactor(Button.UserPointer) do begin
if Button = FPrimetiveTypeButtonPoints then
	begin
	FPrimetiveTypeButtonPoints.Active := False;
	FPrimetiveTypeButtonPolygones.Active := True;
	FPrimetiveTypeButtonLines.Active := True;
	FRedactingType := TSGGDRRedactingPoints;
	end
else if Button = FPrimetiveTypeButtonLines then
	begin
	FPrimetiveTypeButtonLines.Active := False;
	FPrimetiveTypeButtonPoints.Active := True;
	FPrimetiveTypeButtonPolygones.Active := True;
	FRedactingType := TSGGDRRedactingLines;
	end
else if Button = FPrimetiveTypeButtonPolygones then
	begin
	FPrimetiveTypeButtonLines.Active := True;
	FPrimetiveTypeButtonPoints.Active := True;
	FPrimetiveTypeButtonPolygones.Active := False;
	FRedactingType := TSGGDRRedactingPolygones;
	end
else if Button = FCutPolygoneButton then
	begin
	FCutPolygoneButton.Active := False;
	end;
end;end;

procedure TSGGasDiffusionReliefRedactor.StartRedactoring();
const
	a = 150;
begin
FInRedactoring := True;
if FFont = nil then
	begin
	FFont:=TSGFont.Create(SGFontDirectory+Slash+{$IFDEF MOBILE}'Times New Roman.sgf'{$ELSE}'Tahoma.sgf'{$ENDIF});
	FFont.SetContext(Context);
	FFont.Loading();
	FFont.ToTexture();
	end;
if FPrimetiveTypeButtonPoints = nil then
	begin
	FPrimetiveTypeButtonPoints := TSGButton.Create();
	SGScreen.CreateChild(FPrimetiveTypeButtonPoints);
	FPrimetiveTypeButtonPoints.Caption := 'Управление точками';
	FPrimetiveTypeButtonPoints.SetBounds(Context.Width - a - 10, Context.Height div 2 + 0, a, 27);
	FPrimetiveTypeButtonPoints.BoundsToNeedBounds();
	FPrimetiveTypeButtonPoints.Font := FFont;
	FPrimetiveTypeButtonPoints.OnChange := TSGComponentProcedure(@mmmFPrimetiveTypeButton);
	FPrimetiveTypeButtonPoints.UserPointer := Self;
	end;
FPrimetiveTypeButtonPoints.Visible := True;
FPrimetiveTypeButtonPoints.Active := False;
if FPrimetiveTypeButtonLines = nil then
	begin
	FPrimetiveTypeButtonLines := TSGButton.Create();
	SGScreen.CreateChild(FPrimetiveTypeButtonLines);
	FPrimetiveTypeButtonLines.Caption := 'Управление линиями';
	FPrimetiveTypeButtonLines.SetBounds(Context.Width - a - 10, Context.Height div 2 + 30, a, 27);
	FPrimetiveTypeButtonLines.BoundsToNeedBounds();
	FPrimetiveTypeButtonLines.Font := FFont;
	FPrimetiveTypeButtonLines.OnChange := TSGComponentProcedure(@mmmFPrimetiveTypeButton);
	FPrimetiveTypeButtonLines.UserPointer := Self;
	end;
FPrimetiveTypeButtonLines.Visible := True;
FPrimetiveTypeButtonLines.Active := True;
if FPrimetiveTypeButtonPolygones = nil then
	begin
	FPrimetiveTypeButtonPolygones := TSGButton.Create();
	SGScreen.CreateChild(FPrimetiveTypeButtonPolygones);
	FPrimetiveTypeButtonPolygones.Caption := 'Управление полигонами';
	FPrimetiveTypeButtonPolygones.SetBounds(Context.Width - a - 10, Context.Height div 2 + 60, a, 27);
	FPrimetiveTypeButtonPolygones.BoundsToNeedBounds();
	FPrimetiveTypeButtonPolygones.Font := FFont;
	FPrimetiveTypeButtonPolygones.OnChange := TSGComponentProcedure(@mmmFPrimetiveTypeButton);
	FPrimetiveTypeButtonPolygones.UserPointer := Self;
	end;
FPrimetiveTypeButtonPolygones.Visible := True;
FPrimetiveTypeButtonPolygones.Active := True;
if FCutPolygoneButton = nil then
	begin
	FCutPolygoneButton := TSGButton.Create();
	SGScreen.CreateChild(FCutPolygoneButton);
	FCutPolygoneButton.Caption := 'Разрезать полигон';
	FCutPolygoneButton.SetBounds(Context.Width - a - 10, Context.Height div 2 + 90, a, 27);
	FCutPolygoneButton.BoundsToNeedBounds();
	FCutPolygoneButton.Font := FFont;
	FCutPolygoneButton.UserPointer := Self;
	FCutPolygoneButton.OnChange := TSGComponentProcedure(@mmmFPrimetiveTypeButton);
	end;
FCutPolygoneButton.Visible := True;
FCutPolygoneButton.Active := True;
FRedactingType := TSGGDRRedactingPoints;
end;

procedure TSGGasDiffusionReliefRedactor.StopRedactoring();
begin
FInRedactoring := False;
if FPrimetiveTypeButtonPoints <> nil then
	FPrimetiveTypeButtonPoints.Visible := False;
if FPrimetiveTypeButtonLines <> nil then
	FPrimetiveTypeButtonLines.Visible := False;
if FPrimetiveTypeButtonPolygones <> nil then
	FPrimetiveTypeButtonPolygones.Visible := False;
if FCutPolygoneButton <> nil then
	FCutPolygoneButton.Visible := False;
end;


procedure TSGGasDiffusionSingleRelief.ExportToMeshLines(const VMesh : TSGCustomModel;const index : byte = -1;const WithVector : Boolean = False);
var
	i : LongWord;
begin
if FPoints <> nil then if Length(FPoints) <> 0 then
	begin
	VMesh.AddObject();
	VMesh.LastObject().ObjectPoligonesType := SGR_LINE_LOOP;
	VMesh.LastObject().HasNormals := False;
	VMesh.LastObject().HasTexture := False;
	VMesh.LastObject().HasColors  := True;
	VMesh.LastObject().EnableCullFace := False;
	VMesh.LastObject().VertexType := SGMeshVertexType3f;
	VMesh.LastObject().SetColorType(SGMeshColorType4b);
	VMesh.LastObject().Vertexes := Length(FPoints);
	VMesh.LastObject().ObjectMatrix := Matrixes[index];
	
	for i := 0 to High(FPoints) do
		begin
		VMesh.LastObject().ArVertex3f[i]^ := FPoints[i];
		VMesh.LastObject().SetColor(i,0,0.5,1,1);
		end;
	end;
end;

procedure TSGGasDiffusionSingleRelief.ExportToMeshPolygones(const VMesh : TSGCustomModel;const index : byte = -1);
var
	i,ii : LongWord;
begin
if FPoints <> nil then if Length(FPoints) <> 0 then
	begin	
	if FEnabled then if FPolygones <> nil then if Length(FPolygones) <> 0 then
		for i := 0 to High(FPolygones) do
			if FPolygones[i] <> nil then if Length(FPolygones[i]) <> 0 then
				begin
				VMesh.AddObject();
				VMesh.LastObject().ObjectPoligonesType := SGR_TRIANGLES;
				VMesh.LastObject().HasNormals := False;
				VMesh.LastObject().HasTexture := False;
				VMesh.LastObject().HasColors  := True;
				VMesh.LastObject().EnableCullFace := False;
				VMesh.LastObject().VertexType := SGMeshVertexType3f;
				VMesh.LastObject().SetColorType(SGMeshColorType4b);
				VMesh.LastObject().Vertexes := 3*(Length(FPolygones[i]) - 2);
				VMesh.LastObject().ObjectMatrix := Matrixes[index];
				
				for ii := 0 to Length(FPolygones[i])-3 do
					begin
					VMesh.LastObject().ArVertex3f[ii*3+0]^ := FPoints[FPolygones[i][0]];
					VMesh.LastObject().ArVertex3f[ii*3+1]^ := FPoints[FPolygones[i][ii+1]];
					VMesh.LastObject().ArVertex3f[ii*3+2]^ := FPoints[FPolygones[i][ii+2]];
					if FType then
						begin
						VMesh.LastObject().SetColor(ii*3+0,0,  1,1,0.2);
						VMesh.LastObject().SetColor(ii*3+1,0,  1,1,0.2);
						VMesh.LastObject().SetColor(ii*3+2,0,  1,1,0.2);
						end
					else
						begin
						VMesh.LastObject().SetColor(ii*3+0,0,0.5,1,0.2);
						VMesh.LastObject().SetColor(ii*3+1,0,0.5,1,0.2);
						VMesh.LastObject().SetColor(ii*3+2,0,0.5,1,0.2);
						end;
					end;
				end;
	end;
end;

procedure TSGGasDiffusionSingleRelief.ExportToMesh(const VMesh : TSGCustomModel;const index : byte = -1);
begin
ExportToMeshLines(VMesh,index,False);
ExportToMeshPolygones(VMesh,index);
end;

procedure TSGGasDiffusionSingleRelief.InitBase();
begin
FEnabled := False;
SetLength(FPoints,4);
SetLength(FPolygones,1);
SetLength(FPolygones[0],4);
FPoints[0].Import(1,1);
FPoints[1].Import(-1,1);
FPoints[2].Import(-1,-1);
FPoints[3].Import(1,-1);
FPolygones[0][0] := 0;
FPolygones[0][1] := 1;
FPolygones[0][2] := 2;
FPolygones[0][3] := 3;
end;

procedure TSGGasDiffusionSingleRelief.Draw(const VRender : TSGRender);
begin
DrawLines(VRender);
DrawPolygones(VRender);
end;

procedure TSGGasDiffusionSingleRelief.DrawLines(const VRender : TSGRender);
var
	i,ii:LongWord;
begin
if FPolygones <> nil then
	begin
	VRender.Color4f(0,0.5,1,1);
	for i := 0 to High(FPolygones) do
		begin
		VRender.BeginScene(SGR_LINE_LOOP);
		for ii := 0 to High(FPolygones[i]) do
			FPoints[FPolygones[i][ii]].Vertex(VRender);
		VRender.EndScene();
		end;
	if FEnabled then
		begin
		VRender.Color4f(1,1,1,0.7);
		VRender.BeginScene(SGR_LINES);
		VRender.Vertex3f(0,0,0);
		VRender.Vertex3f(0,0,0.8);
		VRender.EndScene();
		end;
	end;
end;

procedure TSGGasDiffusionSingleRelief.DrawPolygones(const VRender : TSGRender);
var
	i,ii:LongWord;
begin
if FPolygones <> nil then
	begin
	VRender.Color4f(0,0.5,1,1);
	for i := 0 to High(FPolygones) do
		begin
		VRender.BeginScene(SGR_LINE_LOOP);
		for ii := 0 to High(FPolygones[i]) do
			FPoints[FPolygones[i][ii]].Vertex(VRender);
		VRender.EndScene();
		end;
	if FEnabled then
		begin
		VRender.Color4f(1,1,1,0.7);
		VRender.BeginScene(SGR_LINES);
		VRender.Vertex3f(0,0,0);
		VRender.Vertex3f(0,0,0.8);
		VRender.EndScene();
		end;
	end;
if (FPolygones <> nil) and FEnabled then
	begin
	if FType then
		VRender.Color4f(0,1,1,0.2)
	else
		VRender.Color4f(0,0.5,1,0.2);
	for i := 0 to High(FPolygones) do
		begin
		VRender.BeginScene(SGR_POLYGON);
		for ii := 0 to High(FPolygones[i]) do
			FPoints[FPolygones[i][ii]].Vertex(VRender);
		VRender.EndScene();
		end;
	end;
end;

procedure TSGGasDiffusionRelief.ExportToMesh(const VMesh : TSGCustomModel);
var
	i : LongWord;
begin
for i := 0 to 5 do
	begin
	FData[i].ExportToMeshLines(VMesh,i,False);
	end;
for i := 0 to 5 do
	begin
	FData[i].ExportToMeshPolygones(VMesh,i);
	end;
end;

procedure TSGGasDiffusionRelief.InitBase();
var
	i : LongWord;
begin
for i := 0 to 5 do
	begin
	FData[i].InitBase();
	end;
end;

procedure TSGGasDiffusionRelief.Draw(const VRender : TSGRender);
var
	i : LongWord;
begin
for i := 0 to 5 do
	begin
	VRender.PushMatrix();
	VRender.MultMatrixf(@Matrixes[i]);
	FData[i].DrawLines(VRender);
	VRender.PopMatrix();
	end;
for i := 0 to 5 do
	begin
	VRender.PushMatrix();
	VRender.MultMatrixf(@Matrixes[i]);
	FData[i].DrawPolygones(VRender);
	VRender.PopMatrix();
	end;
end;

procedure TSGGasDiffusionSingleRelief.Clear();
var
	i : integer;
begin
SetLength(FPoints,0);
if FPolygones <> nil then
	for i := 0 to High(FPolygones) do
		SetLength(FPolygones[i],0);
SetLength(FPoints,0);
FEnabled := False;
FType := False;
end;

procedure TSGGasDiffusionRelief.Clear();
var
	i : Byte;
begin
for i := 0 to 5 do
	FData[i].Clear();
end;

procedure TSGGasDiffusionReliefRedactor.SetActiveSingleRelief(const index : LongInt = -1);
begin
if (index >= 0) and (index <= 5) then
	FSingleRelief := @FRelief^.FData[index]
else
	FSingleRelief := nil;
end;

constructor TSGGasDiffusionReliefRedactor.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FSelectedPrimetives := nil;
FPixelPrimitives := nil;
FCamera := TSGCamera.Create();
FCamera.Context := Context;
FSingleRelief := nil;
FRelief := nil;
FFont := nil;
FPrimetiveTypeButtonPoints := nil;
FPrimetiveTypeButtonLines := nil;
FPrimetiveTypeButtonPolygones := nil;
FCutPolygoneButton := nil;
FRedactingType := TSGGDRRedactingPoints;
end;

procedure TSGGasDiffusionReliefRedactor.DrawRedactoringRelief();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function ExistsInSelectedPrimetives(const i : TSGLongWord):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	ii : TSGLongWord;
begin
Result := False;
if FSelectedPrimetives <> nil then if Length(FSelectedPrimetives) <> 0 then
	for ii := 0 to High(FSelectedPrimetives) do
		if FSelectedPrimetives[ii] = i then
			begin
			Result := True;
			Break;
			end;
end;

var
	i, ii : LongWord;
begin
if FSingleRelief^.FPolygones <> nil then
	begin
	for i := 0 to High(FSingleRelief^.FPolygones) do
		begin
		Render.BeginScene(SGR_LINE_LOOP);
		for ii := 0 to High(FSingleRelief^.FPolygones[i]) do
			begin
			if ExistsIndexInPrimetiveIndexes(FPixelPrimitives,FSingleRelief^.FPolygones[i][ii]) then
				if ExistsIndexInPrimetiveIndexes(FSelectedPrimetives,FSingleRelief^.FPolygones[i][ii]) then
					((SGColorImport(1,0.3,0,1) + SGColorImport(1,1,1,1) + SGColorImport(0,0.5,1,1))/3).Color(Render)
				else
					((SGColorImport(1,1,1,1) + SGColorImport(0,0.5,1,1))/2).Color(Render)
			else 
				if ExistsIndexInPrimetiveIndexes(FSelectedPrimetives,FSingleRelief^.FPolygones[i][ii]) then
					((SGColorImport(1,0.3,0,1) + SGColorImport(0,0.5,1,1))/2).Color(Render)
				else
					Render.Color4f(0,0.5,1,1);
			FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][ii]].Vertex(Render);
			end;
		Render.EndScene();
		end;
	if FSingleRelief^.FEnabled then
		begin
		Render.Color4f(1,1,1,0.7);
		Render.BeginScene(SGR_LINES);
		Render.Vertex3f(0,0,0);
		Render.Vertex3f(0,0,0.8);
		Render.EndScene();
		end;
	end;
if (FSingleRelief^.FPolygones <> nil) and FSingleRelief^.FEnabled then
	begin
	for i := 0 to High(FSingleRelief^.FPolygones) do
		begin
		Render.BeginScene(SGR_POLYGON);
		for ii := 0 to High(FSingleRelief^.FPolygones[i]) do
			begin
			if ExistsIndexInPrimetiveIndexes(FPixelPrimitives,FSingleRelief^.FPolygones[i][ii]) then
				if ExistsIndexInPrimetiveIndexes(FSelectedPrimetives,FSingleRelief^.FPolygones[i][ii]) then
					if FSingleRelief^.FType then
						((SGColorImport(1,0,0,0.3) + SGColorImport(1,1,1,0.5) + SGColorImport(0,1,1,0.2))/3).Color(Render)
					else
						((SGColorImport(1,0,0,0.3) + SGColorImport(1,1,1,0.5) + SGColorImport(0,0.5,1,0.2))/3).Color(Render)
				else
					if FSingleRelief^.FType then
						((SGColorImport(1,1,1,0.5) + SGColorImport(0,1,1,0.2))/2).Color(Render)
					else
						((SGColorImport(1,1,1,0.5) + SGColorImport(0,0.5,1,0.2))/2).Color(Render)
			else
				if ExistsIndexInPrimetiveIndexes(FSelectedPrimetives,FSingleRelief^.FPolygones[i][ii]) then
					if FSingleRelief^.FType then
						((SGColorImport(1,0,0,0.3) + SGColorImport(0,1,1,0.2))/2).Color(Render)
					else
						((SGColorImport(1,0,0,0.3) + SGColorImport(0,0.5,1,0.2))/2).Color(Render)
				else
					if FSingleRelief^.FType then
						Render.Color4f(0,1,1,0.2)
					else
						Render.Color4f(0,0.5,1,0.2);
			FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][ii]].Vertex(Render);
			end;
		Render.EndScene();
		end;
	end;
end;

procedure TSGGasDiffusionReliefRedactor.UpDate();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function ProshTreug(const a, b, c : TSGFloat):TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	p : TSGFloat;
begin
p := (a + b + c) / 2;
Result := sqrt(p*(p-a)*(p-b)*(p-c));
end;

function PointInTriangle(const t1,t2,t3,v : TSGVertex3f) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	t1t2,t2t3,t3t1,t1v,t2v,t3v : TSGFloat;
begin
t1t2 := Abs(t1-t2);
t2t3 := Abs(t2-t3);
t3t1 := Abs(t3-t1);

t1v := Abs(t1-v);
t2v := Abs(t2-v);
t3v := Abs(t3-v);

Result := Abs(
	ProshTreug(t1t2,t2t3,t3t1)
	-ProshTreug(t1t2,t1v,t2v)
	-ProshTreug(t2v,t2t3,t3v)
	-ProshTreug(t3v,t1v,t3t1)) < SGZero * 5;
end;

function PointInLine(const t1,t2,v : TSGVertex3f) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	t1t2 : TSGFloat;
begin
t1t2 := Abs(t2-t1);
Result := ProshTreug(t1t2,Abs(t1-v),Abs(t2-v))/t1t2 < 0.1;
end;

var
	Vertex : TSGVertex3f;
	i, ii, iii : LongWord;
begin
Vertex {$IFNDEF MOBILE}:= SGGetVertexUnderPixel(Render,Context.CursorPosition()){$ELSE}.Import(){$ENDIF};
if FPixelPrimitives <> nil then
	begin
	SetLength(FPixelPrimitives,0);
	FPixelPrimitives := nil;
	end;
case FRedactingType of
TSGGDRRedactingLines :
	begin
	for i := 0 to High(FSingleRelief^.FPolygones) do
		begin
		for ii := 0 to High(FSingleRelief^.FPolygones[i]) do
			if ii = High(FSingleRelief^.FPolygones[i]) then
				begin
				if PointInLine(
					FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][0]],
					FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][ii]],
					Vertex) then
						begin
						SetLength(FPixelPrimitives,2);
						FPixelPrimitives[0] := FSingleRelief^.FPolygones[i][0];
						FPixelPrimitives[1] := FSingleRelief^.FPolygones[i][ii];
						break;
						end;
				end
			else
				if PointInLine(
					FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][ii]],
					FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][ii+1]],
					Vertex) then
						begin
						SetLength(FPixelPrimitives,2);
						FPixelPrimitives[0] := FSingleRelief^.FPolygones[i][ii];
						FPixelPrimitives[1] := FSingleRelief^.FPolygones[i][ii+1];
						break;
						end;
		if FPixelPrimitives <> nil then
			break;
		end;
	end;
TSGGDRRedactingPoints :
	begin
	if FSingleRelief^.FPoints <> nil then if Length(FSingleRelief^.FPoints) <> 0 then
		begin
		for i := 0 to High(FSingleRelief^.FPoints) do
			if Abs(Vertex - FSingleRelief^.FPoints[i]) < 0.1 then
				begin
				SetLength(FPixelPrimitives,1);
				FPixelPrimitives[0] := i;
				Break;
				end;
		end;
	end;
TSGGDRRedactingPolygones :
	begin
	for i := 0 to High(FSingleRelief^.FPolygones) do
		begin
		for ii := 1 to High(FSingleRelief^.FPolygones[i])-1 do
			if PointInTriangle(
				FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][0]],
				FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][ii]],
				FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][ii+1]],
				Vertex) then
					begin
					SetLength(FPixelPrimitives,Length(FSingleRelief^.FPolygones[i]));
					for iii := 0 to High(FSingleRelief^.FPolygones[i]) do
						FPixelPrimitives[iii] := FSingleRelief^.FPolygones[i][iii];
					break;
					end;
		if FPixelPrimitives <> nil then
			break;
		end;
	end;
end;
if (FPixelPrimitives <> nil) and (Context.CursorKeyPressedType() = SGUpKey) and (Context.CursorKeyPressed() = SGLeftCursorButton) then
	ProcessPixelPrimitives();
if (Context.KeyPressed() and (Context.KeyPressedType() = SGUpKey) and (Context.KeyPressedChar() = 'A')) then
	SelectAllPrimetives();
end;

procedure TSGGasDiffusionReliefRedactor.ProcessPixelPrimitives();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i,ii : LongWord;
begin
if FPixelPrimitives <> nil then if Length(FPixelPrimitives)>0 then
	begin
	ii := 0;
	for i := 0 to High(FPixelPrimitives) do
		if not ExistsIndexInPrimetiveIndexes(FSelectedPrimetives,FPixelPrimitives[i]) then
			ii := 1;
	if TSGBoolean(ii) then
		begin
		for i := 0 to High(FPixelPrimitives) do
			if not ExistsIndexInPrimetiveIndexes(FSelectedPrimetives,FPixelPrimitives[i]) then
				AddIndexInPrimetiveIndexes(FSelectedPrimetives,FPixelPrimitives[i]);
		end
	else
		begin
		for i := 0 to High(FPixelPrimitives) do
			if ExistsIndexInPrimetiveIndexes(FSelectedPrimetives,FPixelPrimitives[i]) then
				DelIndexInPrimetiveIndexes(FSelectedPrimetives,FPixelPrimitives[i]);
		end;
	end;
end;

procedure TSGGasDiffusionReliefRedactor.UpDatePointsShifting();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : LongWord;
begin
if (Context.KeysPressed(SG_CTRL_KEY) and (Context.CursorWheel() <> SGNoCursorWheel)) then 
	if FSelectedPrimetives <> nil then
		if Length(FSelectedPrimetives)<>0 then
			begin
			for i := 0 to High(FSelectedPrimetives) do
				FSingleRelief^.FPoints[FSelectedPrimetives[i]] += SGZ((Byte(Context.CursorWheel() = SGUpCursorWheel)-0.5)*0.1);
			Context.FCursorWheel := SGNoCursorWheel;
			end;
end;

procedure TSGGasDiffusionReliefRedactor.Draw();
begin
if FSingleRelief = nil then
	begin
	FCamera.CallAction();
	FRelief^.Draw(Render);
	end
else if FRelief <> nil then
	begin
	if FInRedactoring then
		begin
		UpDatePointsShifting();
		FCamera.CallAction();
		DrawRedactoringRelief();
		UpDate();
		end
	else
		begin
		FCamera.CallAction();
		FSingleRelief^.Draw(Render);
		end;
	end;
end;

destructor TSGGasDiffusionReliefRedactor.Destroy();
begin
if FPrimetiveTypeButtonPoints <> nil then
	FPrimetiveTypeButtonPoints.Destroy();
if FPrimetiveTypeButtonLines <> nil then
	FPrimetiveTypeButtonLines.Destroy();
if FPrimetiveTypeButtonPolygones <> nil then
	FPrimetiveTypeButtonPolygones.Destroy();
if FCutPolygoneButton <> nil then
	FCutPolygoneButton.Destroy();
if FFont <> nil then
	FFont.Destroy();
inherited;
end;

class function TSGGasDiffusionReliefRedactor.ClassName():TSGString;
begin
Result := 'TSGGasDiffusionReliefRedactor';
end;

initialization
begin
Matrixes[-1] := SGGetIdentityMatrix();
Matrixes[0] := SGMultiplyPartMatrix(SGGetRotateMatrix(pi/2,SGVertexImport(1,0,0)),SGGetTranslateMatrix(SGVertexImport(0,0,-1)));
Matrixes[1] := SGMultiplyPartMatrix(SGGetRotateMatrix(pi/2,SGVertexImport(-1,0,0)) , SGGetTranslateMatrix(SGVertexImport(0,0,-1)));
Matrixes[2] := SGMultiplyPartMatrix(SGGetRotateMatrix(pi/2,SGVertexImport(0,1,0)) , SGGetTranslateMatrix(SGVertexImport(0,0,-1)));
Matrixes[3] := SGMultiplyPartMatrix(SGGetRotateMatrix(pi/2,SGVertexImport(0,-1,0)) , SGGetTranslateMatrix(SGVertexImport(0,0,-1)));
Matrixes[4] := SGMultiplyPartMatrix(SGGetRotateMatrix(pi/2,SGVertexImport(0,0,-1)) , SGGetTranslateMatrix(SGVertexImport(0,0,-1)));
Matrixes[5] := SGMultiplyPartMatrix(SGGetRotateMatrix(2*pi/2,SGVertexImport(1,0,0)) , SGGetTranslateMatrix(SGVertexImport(0,0,-1)));
end

finalization
begin

end;

end.
