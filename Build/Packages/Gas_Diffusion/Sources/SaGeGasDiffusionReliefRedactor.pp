{$INCLUDE SaGe.inc}

//{$DEFINE REDACTORDEBUG}

unit SaGeGasDiffusionReliefRedactor;

interface

uses
	 dos
	,crt
	,SaGeBase
	,Classes
	,SaGeBased
	,SaGeMesh
	,SaGeCommonClasses
	,SaGeRenderConstants
	,SaGeContext
	,SaGeCommon
	,SaGeUtils
	,SaGeScreen
	,SaGeImages
	,SaGeImagesBase;
type
	TSGGDRPrimetiveIndexes = packed array of TSGLongWord;
type
	TSGGasDiffusionSingleRelief = object
		FEnabled : TSGBoolean;
		FType : TSGBoolean;
		FPoints : packed array of TSGVertex3f;
		FPolygones : packed array of TSGGDRPrimetiveIndexes;
		
		FMesh : TSG3DObject;
		
		procedure Draw(const VRender : ISGRender);
		procedure DrawLines(const VRender : ISGRender);
		procedure DrawPolygones(const VRender : ISGRender);
		procedure ExportToMesh(const VMesh : TSGCustomModel;const index : byte = -1);
		procedure ExportToMeshLines(const VMesh : TSGCustomModel;const index : byte = -1;const WithVector : Boolean = False);
		procedure ExportToMeshPolygones(const VMesh : TSGCustomModel;const index : byte = -1);
		procedure Clear();
		procedure InitBase(const VEnabled : TSGBoolean = False);
		procedure Write(const s : TSGString = '';const b : TSGBoolean = False; const wp : TSGBoolean = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function Saved():TMemoryStream;
		procedure Load(const ms : TMemoryStream);overload;
		procedure Save(const VFileName : TSGString);overload;
		procedure Load(const VFileName : TSGString);overload;
		end;
type
	TSGGasDiffusionRelief = object
		FData : packed array [0..5] of TSGGasDiffusionSingleRelief;
		
		procedure Draw(const VRender : ISGRender);
		procedure Clear();
		procedure InitBase();
		procedure ExportToMesh(const VMesh : TSGCustomModel);
		function Saved():TMemoryStream;
		procedure Load(const ms : TMemoryStream);overload;
		procedure Save(const VFileName : TSGString);overload;
		procedure Load(const VFileName : TSGString);overload;
		end;
	PSGGasDiffusionSingleRelief = ^ TSGGasDiffusionSingleRelief;
	PSGGasDiffusionRelief = ^ TSGGasDiffusionRelief;
type
	TSGGDRRedactingType = (TSGGDRRedactingPoints,TSGGDRRedactingLines,TSGGDRRedactingPolygones);
	TSGGasDiffusionReliefRedactor = class(TSGScreenedDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		procedure Paint();override;
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
		class procedure TestPolygones(const v1, v2 : TSGVertex3f; var sr : TSGGasDiffusionSingleRelief);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function IncorrectPoint() : TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		class function IsPointCorrect(const p : TSGVertex3f):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		procedure SetActiveSingleRelief(const index : LongInt = -1);
		procedure StartRedactoring();
		procedure StopRedactoring();
			public
		property Relief : PSGGasDiffusionRelief read FRelief write FRelief;
		property SingleRelief : PSGGasDiffusionSingleRelief read FSingleRelief;
		end;

function GetReliefMatrix(const i : byte) : TSGMatrix4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

var
	Matrixes : array[-1..5] of TSGMatrix4;


function TSGGasDiffusionRelief.Saved():TMemoryStream;
var
	i : TSGLongWord;
	ms : TMemoryStream;
begin
Result := TMemoryStream.Create();
for i := 0 to 5 do
	begin
	ms := FData[i].Saved();
	ms.Position := 0;
	ms.SaveToStream(Result);
	ms.Destroy();
	end;
end;

procedure TSGGasDiffusionRelief.Load(const ms : TMemoryStream);overload;
var
	i : TSGLongWord;
begin
for i := 0 to 5 do
	FData[i].Load(ms);
end;

procedure TSGGasDiffusionRelief.Save(const VFileName : TSGString);overload;
var
	ms : TMemoryStream;
begin
ms := Saved();
ms.Position := 0;
ms.SaveToFile(VFileName);
ms.Destroy();
end;

procedure TSGGasDiffusionRelief.Load(const VFileName : TSGString);overload;
var
	ms : TMemoryStream;
begin
ms := TMemoryStream.Create();
ms.LoadFromFile(VFileName);
ms.Position := 0;
Load(ms);
ms.Destroy();
end;

procedure TSGGasDiffusionSingleRelief.Load(const VFileName : TSGString);overload;
var
	fs : TMemoryStream;
begin
fs := TMemoryStream.Create();
fs.LoadFromFile(VFileName);
fs.Position := 0;
Load(fs);
fs.Destroy();
end;

procedure TSGGasDiffusionSingleRelief.Load(const ms : TMemoryStream);overload;
var
	i, ii : TSGLongWord;
	B : TSGBoolean;
begin
if ms.Size <> ms.Position then
	begin
	ms.ReadBuffer(B,SizeOf(B));
	ms.ReadBuffer(B,SizeOf(B));
	ms.ReadBuffer(i,SizeOf(i));
	SetLength(FPoints,i);
	for i := 0 to High(FPoints) do
		ms.ReadBuffer(FPoints[i],SizeOf(FPoints[i]));
	ms.ReadBuffer(i,SizeOf(i));
	SetLength(FPolygones,i);
	for i := 0 to High(FPolygones) do
		begin
		ms.ReadBuffer(ii,SizeOf(ii));
		SetLength(FPolygones[i],ii);
		for ii := 0 to High(FPolygones[i]) do
			ms.ReadBuffer(FPolygones[i][ii],SizeOf(FPolygones[i][ii]));
		end;
	end;
end;

procedure TSGGasDiffusionSingleRelief.Save(const VFileName : TSGString);
var
	ms : TMemoryStream;
begin
ms := Saved();
ms.Position := 0;
ms.SaveToFile(VFileName);
ms.Destroy();
end;

function TSGGasDiffusionSingleRelief.Saved():TMemoryStream;
var
	i, ii : TSGLongWord;
begin
Result := TMemoryStream.Create();
Result.Position := 0;
Result.WriteBuffer(FType,SizeOf(FType));
Result.WriteBuffer(FEnabled,SizeOf(FEnabled));
i := Length(FPoints);
Result.WriteBuffer(i,SizeOf(i));
for i := 0 to High(FPoints) do
	Result.WriteBuffer(FPoints[i],SizeOf(FPoints[i]));
i := Length(FPolygones);
Result.WriteBuffer(i,SizeOf(i));
for i := 0 to High(FPolygones) do
	begin
	ii := Length(FPolygones[i]);
	Result.WriteBuffer(ii,SizeOf(ii));
	for ii := 0 to High(FPolygones[i]) do
		Result.WriteBuffer(FPolygones[i][ii],SizeOf(FPolygones[i][ii]));
	end;
end;

procedure TSGGasDiffusionSingleRelief.Write(const s : TSGString = '';const b : TSGBoolean = False; const wp : TSGBoolean = True);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
const
	PredSt = '   ';
var
	i, ii, iii, iiii : TSGLongWord;
begin
if S <> '' then
	begin
	TextColor(10);
	System.WriteLn(s);
	TextColor(7);
	end;
WriteLn('PSGGasDiffusionSingleRelief(',TSGLongWord(@Self),')^ = {');
WriteLn(PredSt,'FEnabled = ',FEnabled,',');
WriteLn(PredSt,'FType = ',FType,',');
iii := 0;
if FPoints <> nil then if Length(FPoints)<>0 then
	iii := Length(FPoints);
System.Write(PredSt,'FPoints[',iii,']');
if wp then
	begin
	WriteLn(' = [');
	if iii <> 0 then
		for i := 0 to iii - 1 do
			begin
			System.Write(PredSt,PredSt,'{x = ',FPoints[i].x:3:3,', y = ',FPoints[i].y:3:3,', z = ',FPoints[i].z:3:3,'}');
			if i = iii - 1 then
				System.Write(' ]');
			WriteLn(',');
			end;
	end
else
	begin
	WriteLn(',');
	end;
iii := 0;
if FPolygones <> nil then
	iii := Length(FPolygones);
WriteLn(PredSt,'FPolygones[',iii,'] = [');
if iii <> 0 then
	for i := 0 to iii - 1 do
		begin
		iiii := 0;
		if FPolygones[i] <> nil then
			iiii := Length(FPolygones[i]);
		System.Write(PredSt,PredSt,'[');
		for ii := 0 to iiii - 1 do
			begin
			System.Write(FPolygones[i][ii]:2);
			if ii <> iiii - 1 then
				System.Write(',');
			end;
		System.Write(']');
		if i = iii - 1 then
			System.Write(' ]')
		else
			System.Write(',');
		WriteLn();
		end;
WriteLn('}');
if b then
	begin
	TextColor(10);
	System.Write('PressEnter...');
	TextColor(7);
	ReadLn();
	end;
end;

class function TSGGasDiffusionReliefRedactor.IncorrectPoint() : TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(1000,1000,1000);
end;

class function TSGGasDiffusionReliefRedactor.IsPointCorrect(const p : TSGVertex3f):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := Abs(p) < 20;
end;

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
					Result[0] := sr.FPolygones[i][i1];
					Result[1] := sr.FPolygones[i][i2];
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
					Result[0] := sr.FPolygones[i][i1];
					Result[1] := sr.FPolygones[i][i2];
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
Result := IncorrectPoint();
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
			if ii = High(FSingleRelief^.FPolygones[i]) then
				i2 := 0
			else
				i2 := ii + 1;
			th := Abs(TriangleHeightVertex(
				FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][i1]],
				FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][i2]],
				v) - v);
			if  SGIsVertexOnLine(
					FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][i1]],
					FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][i2]],
					TriangleHeightVertex(
						FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][i1]],
						FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][i2]],
						v)
				) and (th < 0.3) and ((not b) or (b and (l > th))) and 
				((pv = nil) or ((pv <> nil) and (not SGIsVertexOnLine(
					FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][i1]],
					FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][i2]],
					pv^)))) then
				begin
				iii := i;
				b := True;
				l := th;
				ii1 := i1;
				ii2 := i2;
				end;
			end;
	if b then
		Result := TriangleHeightVertex(
			FSingleRelief^.FPoints[FSingleRelief^.FPolygones[iii][ii1]],
			FSingleRelief^.FPoints[FSingleRelief^.FPolygones[iii][ii2]],
			v);
	end;
end;

var
	pi : TSGGDRPrimetiveIndexes;
begin
case FCuttingIndex of
1 : 
	begin
	if (Context.CursorKeyPressed() = SGLeftCursorButton) and (Context.CursorKeyPressedType() = SGDownKey) then
		begin
		FCuttingVertex1 := PointNearly(Vertex);
		if IsPointCorrect(FCuttingVertex1) then
			FCuttingIndex := 2
		else
			FCuttingVertex1 := IncorrectPoint();
		end;
	end;
2 :
	begin
	if IsPointCorrect(Vertex) and IsPointCorrect(FCuttingVertex1) then
		begin
		FCuttingVertex2 := PointNearly(Vertex,@FCuttingVertex1);
		Render.BeginScene(SGR_LINES);
		if IsPointCorrect(FCuttingVertex2) then
			begin
			Render.Color3f(0,1,0);
			Render.Vertex(FCuttingVertex2);
			end
		else
			begin
			Render.Color3f(1,0,0);
			Render.Vertex(Vertex);
			end;
		Render.Vertex(FCuttingVertex1);
		Render.EndScene();
		end
	else
		FCuttingVertex2 := IncorrectPoint();
	if (Context.CursorKeyPressed() = SGLeftCursorButton) and (Context.CursorKeyPressedType() = SGUpKey) then
		begin
		if IsPointCorrect(FCuttingVertex2) and IsPointCorrect(FCuttingVertex1) then
			begin
			pi := PointsLineIndex(FCuttingVertex1,FCuttingVertex2,FSingleRelief^);
			if pi = nil then
				CutPolygone(FCuttingVertex1,FCuttingVertex2,FSingleRelief^)
			else
				SetLength(pi,0);
			end;
		FCuttingIndex := 1;
		FCuttingVertex1 := IncorrectPoint();
		FCuttingVertex2 := IncorrectPoint();
		end;
	end;
end;
if Context.KeyPressed() and (Context.KeyPressedByte() = SG_ESC_KEY) then
	begin
	FInCutting := False;
	FCuttingIndex := 0;
	FCutPolygoneButton.Active := True;
	FCuttingVertex1 := IncorrectPoint();
	FCuttingVertex2 := IncorrectPoint();
	end;
end;

class procedure TSGGasDiffusionReliefRedactor.TestPolygones(const v1, v2 : TSGVertex3f; var sr : TSGGasDiffusionSingleRelief);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function IsPointInLine(const i, i1, i2 : TSGLongWord; const v1, v2 : TSGVertex3f) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result :=   SGIsVertexOnLine(
				sr.FPoints[sr.FPolygones[i][i1]],
				sr.FPoints[sr.FPolygones[i][i2]],
				v1) and 
			(Abs(sr.FPoints[sr.FPolygones[i][i1]] - v1) > SGZero) and
			(Abs(sr.FPoints[sr.FPolygones[i][i2]] - v2) > SGZero) and
			(Abs(sr.FPoints[sr.FPolygones[i][i1]] - v2) > SGZero) and
			(Abs(sr.FPoints[sr.FPolygones[i][i2]] - v1) > SGZero);
end;

procedure InsertPointInLine(const i, li, vi : TSGLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	iii : TSGLongWord;
begin
SetLength(sr.FPolygones[i],Length(sr.FPolygones[i]) + 1);
if li <> High(sr.FPolygones[i]) then
	for iii :=  High(sr.FPolygones[i]) downto li + 2 do
		sr.FPolygones[i][iii] := sr.FPolygones[i][iii - 1];
sr.FPolygones[i][li + 1] := vi;
end;

var
	v1i, v2i, i, ii, i1, i2 : TSGLongWord;
begin
v1i := PointIndex(v1,sr);
v2i := PointIndex(v2,sr);
if (v1i <> Length(sr.FPoints)) and (v2i <> Length(sr.FPoints)) then
	for i := 0 to High(sr.FPolygones) do
		begin
		ii := 0;
		while (ii < Length(sr.FPolygones[i])) do
			begin
			i1 := ii;
			i2 := SGGetNextDynamicArrayIndex(i1,High(sr.FPolygones[i]));
			ii += 1;
			if IsPointInLine(i,i1,i2,v1,v2) then
				begin
				InsertPointInLine(i, i1, v1i);
				ii := 0;
				end;
			end;
		ii := 0;
		while (ii < Length(sr.FPolygones[i])) do
			begin
			i1 := ii;
			i2 := SGGetNextDynamicArrayIndex(i1,High(sr.FPolygones[i]));
			ii += 1;
			if IsPointInLine(i,i1,i2,v2,v1) then
				begin
				InsertPointInLine(i, i1, v2i);
				ii := 0;
				end;
			end;
		end;
end;

class procedure TSGGasDiffusionReliefRedactor.CutPolygone(const v1,v2 : TSGVertex3f; var sr : TSGGasDiffusionSingleRelief);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii, iii, i1, i2, i11,i12,i21,i22 : TSGLongWord;
	p1, p2 : TSGGDRPrimetiveIndexes;
begin
//определение полигона, который должен быть разрезан
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
//Если такой полигон существует, то
if iii <> Length(sr.FPolygones) then
	begin
	// определяем возможность совпадения точек с существующими точками в рельефе
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
	// если точка не совпала, то тогда нужно найти линию, на которой она лежит
	if i1 = Length(sr.FPolygones[iii]) then
		begin
		for i := 0 to High(sr.FPolygones[iii]) do
			if i = High(sr.FPolygones[iii]) then
				begin
				if SGIsVertexOnLine(
					sr.FPoints[sr.FPolygones[iii][i]],
					sr.FPoints[sr.FPolygones[iii][0]],
					v1) then
						begin
						i11 := i;
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
	// если точка не совпала, то тогда нужно найти линию, на которой она лежит
	if i2 = Length(sr.FPolygones[iii]) then
		begin
		for i := 0 to High(sr.FPolygones[iii]) do
			if i = High(sr.FPolygones[iii]) then
				begin
				if SGIsVertexOnLine(
					sr.FPoints[sr.FPolygones[iii][i]],
					sr.FPoints[sr.FPolygones[iii][0]],
					v2) then
						begin
						i21 := i;
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
	// если для разрезающей точки найдена линия, то добавляется точка в рельеф и созраняется ее индекс
	// ежели разезающая точка совподала с одной из точек полигона, то вычисляются ее предшествующий и послешедствующий индекс
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
			i12 := i1 + 1;
			end
		else
			begin
			i11 := i1 - 1;
			i12 := i1 + 1;
			end;
		i1 := sr.FPolygones[iii][i1];
		end;
	// если для разрезающей точки найдена линия, то добавляется точка в рельеф и созраняется ее индекс
	// ежели разезающая точка совподала с одной из точек полигона, то вычисляются ее предшествующий и послешедствующий индекс
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
			i22 := i2 + 1;
			end
		else
			begin
			i21 := i2 - 1;
			i22 := i2 + 1;
			end;
		i2 := sr.FPolygones[iii][i2];
		end;
	// сохранение полигона в память машины, вычисленного по вычисленным перед этим данным
	AddIndexInPrimetiveIndexes(p1,i1);
	AddIndexInPrimetiveIndexes(p1,sr.FPolygones[iii][i12]);
	i := i12;
	while (i <> i21) do
		begin
		if i = High(sr.FPolygones[iii]) then
			i := 0
		else
			i += 1;
		AddIndexInPrimetiveIndexes(p1,sr.FPolygones[iii][i]);
		end;
	AddIndexInPrimetiveIndexes(p1,i2);
	// сохранение полигона в память машины, вычисленного по вычисленным перед этим данным
	AddIndexInPrimetiveIndexes(p2,i2);
	AddIndexInPrimetiveIndexes(p2,sr.FPolygones[iii][i22]);
	i := i22;
	while (i <> i11) do
		begin
		if i = High(sr.FPolygones[iii]) then
			i := 0
		else
			i += 1;
		AddIndexInPrimetiveIndexes(p2,sr.FPolygones[iii][i]);
		end;
	AddIndexInPrimetiveIndexes(p2,i1);
	//удаление полигона с этими двумя точками
	SetLength(sr.FPolygones[iii],0);
	sr.FPolygones[iii] := nil;
	if iii <> High(sr.FPolygones) then
		for i := iii to High(sr.FPolygones) - 1 do
			sr.FPolygones[i] := sr.FPolygones[i+1];
	SetLength(sr.FPolygones,Length(sr.FPolygones)-1);
	//добавление вместо него двух полигонов
	SetLength(sr.FPolygones,Length(sr.FPolygones)+2);
	sr.FPolygones[High(sr.FPolygones)-0] := p1;
	sr.FPolygones[High(sr.FPolygones)-1] := p2;
	p1 := nil;
	p2 := nil;
	
	
	{$IFDEF REDACTORDEBUG}
		sr.Write('        In "CutPolygone" before "TestPolygones"',True,False);
		{$ENDIF}
	TestPolygones(v1,v2,sr);
	{$IFDEF REDACTORDEBUG}
		sr.Write('        In "CutPolygone" after "TestPolygones"',True,False);
		{$ENDIF}
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
	FCuttingVertex1 := IncorrectPoint();
	FCuttingVertex2 := IncorrectPoint();
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
	Screen.CreateChild(FPrimetiveTypeButtonPoints);
	FPrimetiveTypeButtonPoints.Caption := 'Управление точками';
	FPrimetiveTypeButtonPoints.SetBounds(Context.Width - a - 10, Context.Height div 2 + 0, a, 27);
	FPrimetiveTypeButtonPoints.BoundsToNeedBounds();
	//FPrimetiveTypeButtonPoints.Font := FFont;
	FPrimetiveTypeButtonPoints.OnChange := TSGComponentProcedure(@mmmFPrimetiveTypeButton);
	FPrimetiveTypeButtonPoints.UserPointer := Self;
	end;
FPrimetiveTypeButtonPoints.Visible := True;
FPrimetiveTypeButtonPoints.Active := False;
if FPrimetiveTypeButtonLines = nil then
	begin
	FPrimetiveTypeButtonLines := TSGButton.Create();
	Screen.CreateChild(FPrimetiveTypeButtonLines);
	FPrimetiveTypeButtonLines.Caption := 'Управление линиями';
	FPrimetiveTypeButtonLines.SetBounds(Context.Width - a - 10, Context.Height div 2 + 30, a, 27);
	FPrimetiveTypeButtonLines.BoundsToNeedBounds();
	//FPrimetiveTypeButtonLines.Font := FFont;
	FPrimetiveTypeButtonLines.OnChange := TSGComponentProcedure(@mmmFPrimetiveTypeButton);
	FPrimetiveTypeButtonLines.UserPointer := Self;
	end;
FPrimetiveTypeButtonLines.Visible := True;
FPrimetiveTypeButtonLines.Active := True;
if FPrimetiveTypeButtonPolygones = nil then
	begin
	FPrimetiveTypeButtonPolygones := TSGButton.Create();
	Screen.CreateChild(FPrimetiveTypeButtonPolygones);
	FPrimetiveTypeButtonPolygones.Caption := 'Управление полигонами';
	FPrimetiveTypeButtonPolygones.SetBounds(Context.Width - a - 10, Context.Height div 2 + 60, a, 27);
	FPrimetiveTypeButtonPolygones.BoundsToNeedBounds();
	//FPrimetiveTypeButtonPolygones.Font := FFont;
	FPrimetiveTypeButtonPolygones.OnChange := TSGComponentProcedure(@mmmFPrimetiveTypeButton);
	FPrimetiveTypeButtonPolygones.UserPointer := Self;
	end;
FPrimetiveTypeButtonPolygones.Visible := True;
FPrimetiveTypeButtonPolygones.Active := True;
if FCutPolygoneButton = nil then
	begin
	FCutPolygoneButton := TSGButton.Create();
	Screen.CreateChild(FCutPolygoneButton);
	FCutPolygoneButton.Caption := 'Разрезать полигон';
	FCutPolygoneButton.SetBounds(Context.Width - a - 10, Context.Height div 2 + 90, a, 27);
	FCutPolygoneButton.BoundsToNeedBounds();
	//FCutPolygoneButton.Font := FFont;
	FCutPolygoneButton.UserPointer := Self;
	FCutPolygoneButton.OnChange := TSGComponentProcedure(@mmmFPrimetiveTypeButton);
	end;
FCutPolygoneButton.Visible := True;
FCutPolygoneButton.Active := True;
FRedactingType := TSGGDRRedactingPoints;
FCuttingIndex := 0;
FCuttingVertex1 := IncorrectPoint();
FCuttingVertex2 := IncorrectPoint();
SetLength(FPixelPrimitives,0);
FPixelPrimitives := nil;
SetLength(FSelectedPrimetives,0);
FSelectedPrimetives := nil;
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
	LinesIndexes : packed array of
		packed record
			i1, i2 : TSGLongWord;
			end = nil;

procedure ConstructLinesIndexes();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function ExistsInLinesIndexes(const p1, p2 : TSGLongWord):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGLongWord;
begin
Result := False;
if LinesIndexes <> nil then if Length(LinesIndexes) > 0 then
	for i := 0 to High(LinesIndexes) do
		if ((p1 = LinesIndexes[i].i1) and (p2 = LinesIndexes[i].i2)) or
			((p2 = LinesIndexes[i].i1) and (p1 = LinesIndexes[i].i2))then
			begin
			Result := True;
			break;
			end;
end;

procedure AddToLinesIndexes(const p1, p2 : TSGLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if LinesIndexes = nil then
	SetLength(LinesIndexes,1)
else
	SetLength(LinesIndexes,Length(LinesIndexes)+1);
LinesIndexes[High(LinesIndexes)].i1 := p1;
LinesIndexes[High(LinesIndexes)].i2 := p2;
end;

var
	i, ii, i1, i2 : TSGLongWord;
begin
for i := 0 to High(FPolygones) do
	for ii := 0 to High(FPolygones[i]) do
		begin
		i1 := ii;
		if ii = High(FPolygones[i]) then
			i2 := 0
		else
			i2 := ii + 1;
		if not ExistsInLinesIndexes(FPolygones[i][i1],FPolygones[i][i2]) then
			AddToLinesIndexes(FPolygones[i][i1],FPolygones[i][i2]);
		end;
end;

var
	i : LongWord;
begin
if FPoints <> nil then if Length(FPoints) <> 0 then
	begin
	VMesh.AddObject();
	VMesh.LastObject().ObjectPoligonesType := SGR_LINES;
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
	
	ConstructLinesIndexes();
	
	VMesh.LastObject().AddFaceArray();
	VMesh.LastObject().PoligonesType[0] := SGR_LINES;
	VMesh.LastObject().Faces[0] := Length(LinesIndexes);
	for i := 0 to High(LinesIndexes) do
		VMesh.LastObject().SetFaceLine(0,i,LinesIndexes[i].i1,LinesIndexes[i].i2);
	
	SetLength(LinesIndexes,0);
	end;
end;

procedure TSGGasDiffusionSingleRelief.ExportToMeshPolygones(const VMesh : TSGCustomModel;const index : byte = -1);
var
	i,ii : LongWord;
begin
if (FMesh <> nil) and (FEnabled) and (FType) then
	FMesh.CopyTo(VMesh.AddObject())
else
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
end;

procedure TSGGasDiffusionSingleRelief.ExportToMesh(const VMesh : TSGCustomModel;const index : byte = -1);
begin
if FMesh = nil then
	ExportToMeshLines(VMesh,index,False);
ExportToMeshPolygones(VMesh,index);
end;

procedure TSGGasDiffusionSingleRelief.InitBase(const VEnabled : TSGBoolean = False);
begin
FEnabled := VEnabled;
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
FMesh := nil;
{$IFDEF REDACTORDEBUG}
	Write();
	{$ENDIF}
end;

procedure TSGGasDiffusionSingleRelief.Draw(const VRender : ISGRender);
begin
DrawLines(VRender);
DrawPolygones(VRender);
end;

procedure TSGGasDiffusionSingleRelief.DrawLines(const VRender : ISGRender);
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
			VRender.Vertex(FPoints[FPolygones[i][ii]]);
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

procedure TSGGasDiffusionSingleRelief.DrawPolygones(const VRender : ISGRender);
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
			VRender.Vertex(FPoints[FPolygones[i][ii]]);
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
			VRender.Vertex(FPoints[FPolygones[i][ii]]);
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
	if FData[i].FMesh = nil then
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

procedure TSGGasDiffusionRelief.Draw(const VRender : ISGRender);
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
if FMesh is TSG3DObject then
	FMesh.Destroy();
FMesh := nil;
SetLength(FPoints,0);
if FPolygones <> nil then if Length(FPolygones)<>0 then
	for i := 0 to High(FPolygones) do
		SetLength(FPolygones[i],0);
SetLength(FPolygones,0);
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

constructor TSGGasDiffusionReliefRedactor.Create(const VContext : ISGContext);
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
					Render.Color((SGVertex4fImport(1,0.3,0,1) + SGVertex4fImport(1,1,1,1) + SGVertex4fImport(0,0.5,1,1))/3)
				else
					Render.Color((SGVertex4fImport(1,1,1,1) + SGVertex4fImport(0,0.5,1,1))/2)
			else 
				if FCutPolygoneButton.Active and ExistsIndexInPrimetiveIndexes(FSelectedPrimetives,FSingleRelief^.FPolygones[i][ii]) then
					Render.Color((SGVertex4fImport(1,0.3,0,1) + SGVertex4fImport(0,0.5,1,1))/2)
				else
					Render.Color4f(0,0.5,1,1);
			Render.Vertex(FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][ii]]);
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
						Render.Color((SGVertex4fImport(1,0,0,0.3) + SGVertex4fImport(1,1,1,0.5) + SGVertex4fImport(0,1,1,0.2))/3)
					else
						Render.Color((SGVertex4fImport(1,0,0,0.3) + SGVertex4fImport(1,1,1,0.5) + SGVertex4fImport(0,0.5,1,0.2))/3)
				else
					if FSingleRelief^.FType then
						Render.Color((SGVertex4fImport(1,1,1,0.5) + SGVertex4fImport(0,1,1,0.2))/2)
					else
						Render.Color((SGVertex4fImport(1,1,1,0.5) + SGVertex4fImport(0,0.5,1,0.2))/2)
			else
				if FCutPolygoneButton.Active and ExistsIndexInPrimetiveIndexes(FSelectedPrimetives,FSingleRelief^.FPolygones[i][ii]) then
					if FSingleRelief^.FType then
						Render.Color((SGVertex4fImport(1,0,0,0.3) + SGVertex4fImport(0,1,1,0.2))/2)
					else
						Render.Color((SGVertex4fImport(1,0,0,0.3) + SGVertex4fImport(0,0.5,1,0.2))/2)
				else
					if FSingleRelief^.FType then
						Render.Color4f(0,1,1,0.2)
					else
						Render.Color4f(0,0.5,1,0.2);
			Render.Vertex(FSingleRelief^.FPoints[FSingleRelief^.FPolygones[i][ii]]);
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
	if (Context.KeyPressed() and (Context.KeyPressedType() = SGUpKey) and (Context.KeyPressedChar() = 'S')) then
		begin
		i := Byte(FSingleRelief^.FEnabled) + 2 * Byte(FSingleRelief^.FType);
		FSingleRelief^.Clear();
		FSingleRelief^.InitBase();
		FSingleRelief^.FEnabled := TSGBoolean(i mod 2);
		FSingleRelief^.FType := TSGBoolean((i div 2) mod 2);
		SetLength(FPixelPrimitives,0);
		FPixelPrimitives := nil;
		SetLength(FSelectedPrimetives,0);
		FSelectedPrimetives := nil;
		end;
	if (Context.KeyPressed() and (Context.KeyPressedType() = SGUpKey) and (Context.KeyPressedChar() = 'D')) then
		if FSelectedPrimetives <> nil then if Length(FSelectedPrimetives)<>0 then
			for i := 0 to High(FSelectedPrimetives) do
				FSingleRelief^.FPoints[FSelectedPrimetives[i]].z := 0;
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
if (Context.KeysPressed(SG_CTRL_KEY) and (Context.CursorWheel() <> SGNullCursorWheel)) then 
	if FSelectedPrimetives <> nil then
		if Length(FSelectedPrimetives)<>0 then
			begin
			for i := 0 to High(FSelectedPrimetives) do
				FSingleRelief^.FPoints[FSelectedPrimetives[i]] += SGZ((Byte(Context.CursorWheel() = SGUpCursorWheel)-0.5)*0.1);
			Context.SetCursorWheel(SGNullCursorWheel);
			end;
end;

procedure TSGGasDiffusionReliefRedactor.Paint();
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
Matrixes[0] := SGMultiplyPartMatrix(SGGetRotateMatrix(pi/2,SGVertex3fImport(1,0,0)),SGGetTranslateMatrix(SGVertex3fImport(0,0,-1)));
Matrixes[1] := SGMultiplyPartMatrix(SGGetRotateMatrix(pi/2,SGVertex3fImport(-1,0,0)) , SGGetTranslateMatrix(SGVertex3fImport(0,0,-1)));
Matrixes[2] := SGMultiplyPartMatrix(SGGetRotateMatrix(pi/2,SGVertex3fImport(0,1,0)) , SGGetTranslateMatrix(SGVertex3fImport(0,0,-1)));
Matrixes[3] := SGMultiplyPartMatrix(SGGetRotateMatrix(pi/2,SGVertex3fImport(0,-1,0)) , SGGetTranslateMatrix(SGVertex3fImport(0,0,-1)));
Matrixes[4] := SGMultiplyPartMatrix(SGGetRotateMatrix(pi/2,SGVertex3fImport(0,0,-1)) , SGGetTranslateMatrix(SGVertex3fImport(0,0,-1)));
Matrixes[5] := SGMultiplyPartMatrix(SGGetRotateMatrix(2*pi/2,SGVertex3fImport(1,0,0)) , SGGetTranslateMatrix(SGVertex3fImport(0,0,-1)));
end

finalization
begin

end;

end.
