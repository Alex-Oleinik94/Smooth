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
	TSGGDRPrimetiveIndexes = packed array of TSGLongWord;
type
	TSGGasDiffusionSingleRelief = object
		FEnabled : Boolean;
		FType : Boolean;
		FPoints : packed array of TSGVertex;
		FPolygones : packed array of TSGGDRPrimetiveIndexes;
		
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
		FCuttingVertex1,FCuttingVertex2 : TSGVertex3f;
		FCuttingIndex : TSGLongWord;
			private
		procedure UpDate();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure UpDatePointsShifting();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure DrawRedactoringRelief();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ProcessPixelPrimitives();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SelectAllPrimetives();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure UpDateCutPolygone(const Vertex : TSGVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			private
		class function  ExistsIndexInPrimetiveIndexes(const VIndexes : TSGGDRPrimetiveIndexes; const VIndex : TSGLongWord):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure AddIndexInPrimetiveIndexes(var VIndexes : TSGGDRPrimetiveIndexes; const VIndex : TSGLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure DelIndexInPrimetiveIndexes(var VIndexes : TSGGDRPrimetiveIndexes; const VIndex : TSGLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class procedure CutPolygone(const v1, v2 : TSGVertex3f; var sr : TSGGasDiffusionSingleRelief);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  PointLineIndex(const v : TSGVertex3f; var sr : TSGGasDiffusionSingleRelief):TSGGDRPrimetiveIndexes;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  PointsLineIndex(const v1, v2 : TSGVertex3f; var sr : TSGGasDiffusionSingleRelief):TSGGDRPrimetiveIndexes;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  PointIndex(const v : TSGVertex3f; var sr : TSGGasDiffusionSingleRelief):TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function  PrimetiveIndexesEquals(const p1,p2:TSGGDRPrimetiveIndexes):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

class function  TSGGasDiffusionReliefRedactor.PointIndex(const v : TSGVertex3f; var sr : TSGGasDiffusionSingleRelief):TSGLongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
Result := Length(sr.FPoints);
for i := 0 to High(sr.FPoints) do
	if Abs(v - sr.FPoints[i]) < SGZero then
		begin
		Result := i;
		break;
		end;
end;

class function  TSGGasDiffusionReliefRedactor.PointsLineIndex(const v1, v2 : TSGVertex3f; var sr : TSGGasDiffusionSingleRelief):TSGGDRPrimetiveIndexes;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

var
	i, ii, i1, i2 : TSGLongWord;
begin
Result := nil;
for i := 0 to High(sr.FPolygones) do
	begin
	for ii := 0 to High(sr.FPolygones[i]) do
		begin
		i1 := ii;
		if ii = High(sr.FPolygones[i]) then
			i2 := 0
		else
			i2 := ii + 1;
		if  SGIsVertexOnLine(
				sr.FPoints[sr.FPolygones[i][i1]],
				sr.FPoints[sr.FPolygones[i][i2]],
				v1) and 
			SGIsVertexOnLine(
				sr.FPoints[sr.FPolygones[i][i1]],
				sr.FPoints[sr.FPolygones[i][i2]],
				v2) then
					begin
					SetLength(Result,2);
					Result[0] := i1;
					Result[1] := i2;
					break;
					end;
		end;
	if Result <> nil then
		break;
	end;
end;

class function  TSGGasDiffusionReliefRedactor.PointLineIndex(const v : TSGVertex3f; var sr : TSGGasDiffusionSingleRelief):TSGGDRPrimetiveIndexes;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii, i1, i2 : TSGLongWord;
begin
Result := nil;
for i := 0 to High(sr.FPolygones) do
	begin
	for ii := 0 to High(sr.FPolygones[i]) do
		begin
		i1 := ii;
		if ii = High(sr.FPolygones[i]) then
			i2 := 0
		else
			i2 := ii + 1;
		if  SGIsVertexOnLine(
				sr.FPoints[sr.FPolygones[i][i1]],
				sr.FPoints[sr.FPolygones[i][i2]],
				v) then
					begin
					SetLength(Result,2);
					Result[0] := i1;
					Result[1] := i2;
					break;
					end;
		end;
	if Result <> nil then
		break;
	end;
end;

class function  TSGGasDiffusionReliefRedactor.PrimetiveIndexesEquals(const p1,p2:TSGGDRPrimetiveIndexes):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii, iii : TSGLongWord;
begin
Result := True;
if p1 = nil then
	i := 0
else
	i := Length(p1);
if p2 = nil then
	i := 0
else
	i := Length(p2);
if i <> ii then
	Result := False
else if i <> 0 then
	begin
	for i := 0 to High(p1) do
		begin
		iii := 0;
		for ii := 0 to High(p2) do
			if p1[i] = p2[ii] then
				begin
				iii := 1;
				break;
				end;
		if iii = 0 then
			begin
			Result := False;
			break;
			end;
		end;
	end;
end;

procedure TSGGasDiffusionReliefRedactor.UpDateCutPolygone(const Vertex : TSGVertex3f);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function TriangleHeight(const t1,t2,v : TSGVertex3f):TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGTriangleSize(t1,t2,v) / Abs(t2 - t1) * 2;
end;

function TriangleHeightVertex(const t1,t2,v : TSGVertex3f):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	th,c  : TSGFloat;
begin
th := TriangleHeight(t1,t2,v);
c :=sqrt(sqr(Abs(v-t1)) - sqr(th));
Result := t1 + (t2 - t1) * (c / Abs(t1-t2));
end;

function PointNearly(const v  : TSGVertex3f; const pv : PSGVertex3f = nil):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii, iii, i1, i2, ii1, ii2 : TSGLongWord;
	b : TSGBoolean;
	l, th : TSGFloat;
	pi : TSGGDRPrimetiveIndexes;
begin
Result.Import(1000,1000,1000);
ii := Length(FSingleRelief^.FPoints);
for i := 0 to High(FSingleRelief^.FPoints) do
	if Abs(v - FSingleRelief^.FPoints[i]) < 0.1 then
		begin
		b := True;
		if pv <> nil then
			begin
			pi := PointsLineIndex(pv^,FSingleRelief^.FPoints[i],FSingleRelief^);
			if pi <> nil then
				begin
				b := False;
				SetLength(pi,0);
				end;
			end;
		if b then
			begin
			ii := i;
			break;
			end;
		end;
if ii <> Length(FSingleRelief^.FPoints) then
	Result := FSingleRelief^.FPoints[ii]
else
	begin
	l := 0;
	b := False;
	for i := 0 to High(FSingleRelief^.FPolygones) do
		for ii := 0 to High(FSingleRelief^.FPolygones[i]) do
			begin
			i1 := ii;
			if ii = High(FSingleRelief^.FPolygones) then
				i2 := 0
			else
				i2 := ii + 1;
			th := TriangleHeight(
				FSingleRelief^.FPoints[i1],
				FSingleRelief^.FPoints[i2],
				v);
			if (th < 0.3) and ((not b) or (b and (l > th))) and 
				((pv = nil) or ((pv <> nil) and (not SGIsVertexOnLine(
					FSingleRelief^.FPoints[i1],
					FSingleRelief^.FPoints[i2],
					pv^)))) then
				begin
				b := True;
				l := th;
				ii1 := i1;
				ii2 := i2;
				end;
			end;
	if b then
		Result := TriangleHeightVertex(
			FSingleRelief^.FPoints[i1],
			FSingleRelief^.FPoints[i2],
			v);
	end;
end;

var
	pi1, pi2 : TSGGDRPrimetiveIndexes;
begin
case FCuttingIndex of
1 : 
	begin
	if (Context.CursorKeyPressed() = SGLeftCursorButton) and (Context.CursorKeyPressedType() = SGDownKey) then
		begin
		FCuttingVertex1 := PointNearly(Vertex);
		if Abs(FCuttingVertex1) < 100 then
			FCuttingIndex := 2
		else
			FCuttingVertex1.Import();
		end;
	end;
2 :
	begin
	if (Abs(Vertex) < 100) and (Abs(FCuttingVertex1) < 100) then
		begin
		FCuttingVertex2 := PointNearly(Vertex,@FCuttingVertex1);
		Render.BeginScene(SGR_LINES);
		if Abs(FCuttingVertex2) < 100 then
			begin
			Render.Color3f(0,1,0);
			FCuttingVertex2.Vertex(Render);
			end
		else
			begin
			Render.Color3f(1,0,0);
			Vertex.Vertex(Render);
			end;
		FCuttingVertex1.Vertex(Render);
		Render.EndScene();
		end
	else
		FCuttingVertex2.Import(1000,1000,1000);
	if (Context.CursorKeyPressed() = SGLeftCursorButton) and (Context.CursorKeyPressedType() = SGUpKey) then
		begin
		if (Abs(FCuttingVertex1) < 100) and (Abs(FCuttingVertex2)<100) then
			begin
			pi1 := PointLineIndex(FCuttingVertex1,FSingleRelief^);
			pi2 := PointLineIndex(FCuttingVertex2,FSingleRelief^);
			if not PrimetiveIndexesEquals(pi1,pi2) then
				CutPolygone(FCuttingVertex1,FCuttingVertex2,FSingleRelief^);
			if pi1 <> nil then
				SetLength(pi1,0);
			if pi2 <> nil then
				SetLength(pi2,0);
			end;
		FCuttingIndex := 1;
		FCuttingVertex1.Import();
		FCuttingVertex2.Import();
		end;
	end;
end;
if Context.KeyPressed() and (Context.KeyPressedByte() = SG_ESC_KEY) then
	begin
	FInCutting := False;
	FCuttingIndex := 0;
	FCutPolygoneButton.Active := True;
	FCuttingVertex1.Import();
	FCuttingVertex2.Import();
	end;
end;

class procedure TSGGasDiffusionReliefRedactor.CutPolygone(const v1,v2 : TSGVertex3f; var sr : TSGGasDiffusionSingleRelief);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii, iii, i1, i2, i11,i12,i21,i22 : TSGLongWord;
	p1, p2 : TSGGDRPrimetiveIndexes;
begin
iii := Length(sr.FPolygones);
for i := 0 to High(sr.FPolygones) do
	begin
	i1 := Length(sr.FPolygones[i]);
	i2 := Length(sr.FPolygones[i]);
	for ii := 1 to High(sr.FPolygones[i])-1 do
		begin
		if  i1 = Length(sr.FPolygones[i]) then
			if  SGIsVertexOnTriangle(
					sr.FPoints[sr.FPolygones[i][0]],
					sr.FPoints[sr.FPolygones[i][ii]],
					sr.FPoints[sr.FPolygones[i][ii+1]],
					v1) then
						i1 := ii;
		if  i2 = Length(sr.FPolygones[i]) then
			if  SGIsVertexOnTriangle(
					sr.FPoints[sr.FPolygones[i][0]],
					sr.FPoints[sr.FPolygones[i][ii]],
					sr.FPoints[sr.FPolygones[i][ii+1]],
					v2) then
						i2 := ii;
		if (i1 <> Length(sr.FPolygones[i])) and (i2 <> Length(sr.FPolygones[i])) then
			break;
		end;
	if (i1 <> Length(sr.FPolygones[i])) and (i2 <> Length(sr.FPolygones[i])) then
		begin
		iii := i;
		break;
		end;
	end;
if iii <> Length(sr.FPolygones) then
	begin
	i1 := Length(sr.FPolygones[iii]);
	i2 := Length(sr.FPolygones[iii]);
	for i := 0 to High(sr.FPolygones[iii]) do
		if Abs(sr.FPoints[sr.FPolygones[iii][i]] - v1) < SGZero then
			begin
			i1 := i;
			break;
			end;
	for i := 0 to High(sr.FPolygones[iii]) do
		if Abs(sr.FPoints[sr.FPolygones[iii][i]] - v2) < SGZero then
			begin
			i2 := i;
			break;
			end;
	if i1 = Length(sr.FPolygones[iii]) then
		begin
		for i := 0 to High(sr.FPolygones[iii]) do
			if i = High(sr.FPolygones[iii]) then
				begin
				if SGIsVertexOnLine(
					sr.FPoints[sr.FPolygones[iii][0]],
					sr.FPoints[sr.FPolygones[iii][High(sr.FPolygones[iii])]],
					v1) then
						begin
						i11 := High(sr.FPolygones[iii]);
						i12 := 0;
						break;
						end;
				end
			else
				if SGIsVertexOnLine(
					sr.FPoints[sr.FPolygones[iii][i]],
					sr.FPoints[sr.FPolygones[iii][i+1]],
					v1) then
						begin
						i11 := i;
						i12 := i+1;
						break;
						end;
		end;
	if i2 = Length(sr.FPolygones[iii]) then
		begin
		for i := 0 to High(sr.FPolygones[iii]) do
			if i = High(sr.FPolygones[iii]) then
				begin
				if SGIsVertexOnLine(
					sr.FPoints[sr.FPolygones[iii][0]],
					sr.FPoints[sr.FPolygones[iii][High(sr.FPolygones[iii])]],
					v2) then
						begin
						i21 := High(sr.FPolygones[iii]);
						i22 := 0;
						break;
						end;
				end
			else
				if SGIsVertexOnLine(
					sr.FPoints[sr.FPolygones[iii][i]],
					sr.FPoints[sr.FPolygones[iii][i+1]],
					v2) then
						begin
						i21 := i;
						i22 := i+1;
						break;
						end;
		end;
	p1 := nil;
	if i1 = Length(sr.FPolygones[iii]) then
		begin
		SetLength(sr.FPoints,Length(sr.FPoints)+1);
		i1 := High(sr.FPoints);
		sr.FPoints[High(sr.FPoints)] := v1;
		end
	else
		begin
		if i1 = High(sr.FPolygones[iii]) then
			begin
			i11 := i1 - 1;
			i12 := 0;
			end
		else if i1 = 0 then
			begin
			i11 := High(sr.FPolygones[iii]);
			i12 := 1;
			end
		else
			begin
			i11 := i1 - 1;
			i12 := i1 + 1;
			end;
		end;
	p2 := nil;
	if i2 = Length(sr.FPolygones[iii]) then
		begin
		SetLength(sr.FPoints,Length(sr.FPoints)+1);
		i2 := High(sr.FPoints);
		sr.FPoints[High(sr.FPoints)] := v2;
		end
	else
		begin
		if i2 = High(sr.FPolygones[iii]) then
			begin
			i21 := i2 - 1;
			i22 := 0;
			end
		else if i2 = 0 then
			begin
			i21 := High(sr.FPolygones[iii]);
			i22 := 1;
			end
		else
			begin
			i21 := i2 - 1;
			i22 := i2 + 1;
			end;
		end;
	AddIndexInPrimetiveIndexes(p1,i1);
	AddIndexInPrimetiveIndexes(p1,i12);
	i := i12;
	while (i <> i21) do
		begin
		if i = High(sr.FPolygones[iii]) then
			i := 0
		else
			i += 1;
		AddIndexInPrimetiveIndexes(p1,i);
		end;
	AddIndexInPrimetiveIndexes(p1,i2);
	
	AddIndexInPrimetiveIndexes(p2,i2);
	AddIndexInPrimetiveIndexes(p2,i22);
	i := i22;
	while (i <> i11) do
		begin
		if i = High(sr.FPolygones[iii]) then
			i := 0
		else
			i += 1;
		AddIndexInPrimetiveIndexes(p2,i);
		end;
	AddIndexInPrimetiveIndexes(p2,i1);
	
	SetLength(sr.FPolygones[iii],0);
	if iii <> High(sr.FPolygones) then
		for i := iii to High(sr.FPolygones) - 1 do
			sr.FPolygones[i] := sr.FPolygones[i+1];
	SetLength(sr.FPolygones,Length(sr.FPolygones)-1);
	
	SetLength(sr.FPolygones,Length(sr.FPolygones)+2);
	sr.FPolygones[High(sr.FPolygones)-0] := p1;
	sr.FPolygones[High(sr.FPolygones)-1] := p2;
	p1 := nil;
	p2 := nil;
	end;
end;

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
	FCuttingIndex := 1;
	FCuttingVertex1 . Import();
	FCuttingVertex2 . Import();
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
FCuttingIndex := 0;
FCuttingVertex1.Import();
FCuttingVertex2.Import();
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
			if FCutPolygoneButton.Active and ExistsIndexInPrimetiveIndexes(FPixelPrimitives,FSingleRelief^.FPolygones[i][ii]) then
				if FCutPolygoneButton.Active and ExistsIndexInPrimetiveIndexes(FSelectedPrimetives,FSingleRelief^.FPolygones[i][ii]) then
					((SGColorImport(1,0.3,0,1) + SGColorImport(1,1,1,1) + SGColorImport(0,0.5,1,1))/3).Color(Render)
				else
					((SGColorImport(1,1,1,1) + SGColorImport(0,0.5,1,1))/2).Color(Render)
			else 
				if FCutPolygoneButton.Active and ExistsIndexInPrimetiveIndexes(FSelectedPrimetives,FSingleRelief^.FPolygones[i][ii]) then
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
			if FCutPolygoneButton.Active and ExistsIndexInPrimetiveIndexes(FPixelPrimitives,FSingleRelief^.FPolygones[i][ii]) then
				if FCutPolygoneButton.Active and ExistsIndexInPrimetiveIndexes(FSelectedPrimetives,FSingleRelief^.FPolygones[i][ii]) then
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
				if FCutPolygoneButton.Active and ExistsIndexInPrimetiveIndexes(FSelectedPrimetives,FSingleRelief^.FPolygones[i][ii]) then
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
var
	Vertex : TSGVertex3f;
	i, ii, iii : LongWord;
begin
Vertex {$IFNDEF MOBILE}:= SGGetVertexUnderPixel(Render,Context.CursorPosition()){$ELSE}.Import(){$ENDIF};
if FCutPolygoneButton.Active then
	begin
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
					if SGIsVertexOnLine(
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
					if SGIsVertexOnLine(
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
				if SGIsVertexOnTriangle(
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
	if (Context.KeyPressed() and (Context.KeyPressedType() = SGUpKey) and (Context.KeyPressedChar() = 'D')) then
		for i := 0 to High(FSingleRelief^.FPoints) do
			FSingleRelief^.FPoints[i].z := 0;
	end
else
	begin
	UpDateCutPolygone(Vertex);
	end;
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
		if FCutPolygoneButton.Active then
			FCamera.Change();
		FCamera.InitMatrix();
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
