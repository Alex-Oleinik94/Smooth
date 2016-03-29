{$INCLUDE SaGe.inc}

{$DEFINE RELIEFDEBUG}

unit SaGeGasDiffusion;

interface
uses
	 dos
	,SysUtils
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
	,SaGeImagesBase
	,SaGeGasDiffusionReliefRedactor;
const
	PredStr = 
		{$IFDEF ANDROID}
			'sdcard/.SaGe/'
		{$ELSE}
			''
			{$ENDIF};
	Catalog = 'Gas Diffusion Saves';
type
	TSGGazType = object
		FColor : TSGColor4f;
		FArParents: array[0..1] of LongInt;
		FDinamicQuantity : LongWord;
		procedure Create(const r,g,b: Single;const a: Single = 1;const p1 : LongInt = -1; const p2: LongInt = -1);
		end;
	TSGSourseType = object
		FGazTypeIndex : TSGLongWord;
		FCoord : TSGPoint3f;
		FRadius : TSGLongWord;
		end;
	TSGGGDC = ^byte;
	TSGGasDiffusionCube = class(TSGDrawClass)
			public
		constructor Create(const VContext:TSGContext);override;
		procedure Draw();override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			public
		procedure UpDateSourses();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure InitCube(const Edge : TSGLongWord; const VProgress : PSGProgressBarFloat = nil);
		procedure UpDateCube();
		function  CalculateMesh(const VRelief : PSGGasDiffusionRelief = nil{$IFDEF RELIEFDEBUG};const FInReliafDebug : TSGLongWord = 0{$ENDIF}) : TSGCustomModel;
		procedure ClearGaz();
		procedure InitReliefIndexes(const VProgress : PSGProgressBarFloat = nil);
			public
		function Cube (const x,y,z:Word):TSGGGDC;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ReliefCubeIndex (const x,y,z : Word):TSGGGDC;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function Copy() : TSGGasDiffusionCube;
			public
		FCube       : TSGGGDC;						// ^byte - кубик
		FReliefCubeIndex : TSGGGDC;
		FCubeCoords : packed array of
			TSGVertex3f;							// 3хмерные координаты каждой точки из FCube
		FEdge       : TSGLongWord;					// размерность FCube (FEdge * FEdge * FEdge)
		//FBoundsOpen : TSGBoolean;
		FGazes      : packed array of TSGGazType;	// типы газа
		FSourses    : packed array of TSGSourseType;// источники газа
		FDinamicQuantityMoleculs : LongWord;		// количество точек газа на данный момент
		FFlag       : Boolean;						// флажок этапа итерации. этот алгоритм работает в 2 этапа
		FRelief     : PSGGasDiffusionRelief;
			public
		property Edge : TSGLongWord read FEdge;
		end;
type
	TSGGasDiffusion=class(TSGDrawClass)
			public
		constructor Create(const VContext:TSGContext);override;
		procedure Draw();override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			private
		FCamera         : TSGCamera;
		FMesh           : TSGCustomModel;
		FCube           : TSGGasDiffusionCube;
		FFileName       : TSGString;
		FFileStream     : TFileStream;
		FDiffusionRuned : TSGBoolean;
		FEnableSaving   : TSGBoolean;
		FRelefRedactor  : TSGGasDiffusionReliefRedactor;
		FRelief         : TSGGasDiffusionRelief;
		
		//Панели, кнопки и т п
		FTahomaFont        : TSGFont; 						// шрифт
		FLoadScenePanel,									// панель загрузки повтора
		FBoundsOptionsPanel,								// панель опций границ
			FRelefOptionPanel,								// опции рельефа границы
			FNewScenePanel :TSGPanel;						// панель нового проэкта
		
		FStartingProgressBar : TSGProgressBar;
		FStartingThread      : TSGThread;
		FStartingFlag        : LongInt;
		
		//New Panel
		FEdgeEdit               : TSGEdit;
		FNumberLabel            : TSGLabel;
		FStartSceneButton,
		FBoundsTypeButton,
			FEnableLoadButton   : TSGButton;
		FEnableOutputComboBox   : TSGComboBox;
		
		//Load Panel
		FLoadComboBox      : TSGComboBox;
		FBackButton, 
			FUpdateButton, 
			FLoadButton    : TSGButton;
		
		//Экран
		FInfoLabel : TSGLabel;
		
			(* Сечение *)
		
		FNewSecheniePanel, 						// Содержит кнопку и FPlaneComboBox
			FSecheniePanel : TSGPanel;			// Cодержит картинку сечения
		FPlaneComboBox : TSGComboBox;			// вычесление осей координат для FPointerSecheniePlace
		FPointerSecheniePlace : TSGSingle;		// (-1..1) значение места сечения
		FSechenieImage : TSGImage; 				// Картинка сечения
		FImageSechenieBounds : LongWord; 		// Действительное расширение картинки сечения
		FSechenieUnProjectVertex : TSGVertex3f; // For Un Project
		
		FUsrSechPanel  : TSGPanel;
		FUsrSechImage : TSGImage;
		FUsrSechImageForThread : TSGImage;
		FUsrImageThread : TSGThread;
		FUsrRange: LongWord;
		FUsrSechThread : TSGThread;
		FCubeForUsr : TSGGasDiffusionCube;
		FUpdateUsrAfterThread : Boolean;
		
			(*Экран моделирования*)
		FConchLabels : packed array of
			TSGLabel;
		FAddNewSourseButton, 					// новый источник газа
			FAddNewGazButton,					// навый тип газа
			FStartEmulatingButton,				// пуск эмуляции
			FPauseEmulatingButton,				// пауза эмуляции
			FDeleteSechenieButton,				// отмена показа сечения
			FAddSechenieButton,					// начало показа сечения
			FBackToMenuButton,					// кнопка выхода (в меню)
			FStopEmulatingButton,				// остановка эмуляции
			FAddSechSecondPanelButton,			// включение отображение усредненного сечения
			FSaveImageButton,					// сохранить картинку сечения
			FRedactorBackButton: TSGButton;
		
		FAddNewSoursePanel : TSGPanel;
		FAddNewGazPanel : TSGPanel;
			(*Повтор*)
		
		//FFileStream  : TFileStream;
		//FFileName    : TSGString;
		FArCadrs       : packed array of TSGQuadWord;
		FNowCadr       : TSGLongWord;
		FMoviePlayed   : TSGBoolean;
		
		//Экран повтора
		FMoviePauseButton,
			FMovieBackToMenuButton,
			FMoviePlayButton : TSGButton;
		
		{$IFDEF RELIEFDEBUG}
			private
		FInReliafDebug : TSGLongWord;
		{$ENDIF}
		
			private
		procedure ClearDisplayButtons();
		procedure SaveStageToStream();
		procedure UpDateSavesComboBox();
		procedure UpDateInfoLabel();
		procedure UpDateSechenie();
		procedure UpDateChangeSourses();
		procedure DrawComplexCube();
		procedure UpDateSoursePanel();
		procedure UpDateConchLabels();
		procedure UpDateUsrSech();
		function GetPointColor( const i,ii,iii : LongWord):Byte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetPointColorCube( const i,ii,iii : LongWord; const VCube : TSGGasDiffusionCube):Byte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

implementation

//Algorithm

procedure TSGGazType.Create(const r,g,b: Single;const a: Single = 1;const p1 : LongInt = -1; const p2: LongInt = -1);
begin
FColor.Import(r,g,b,a);
FArParents[0]:=p1;
FArParents[1]:=p2;
end;

constructor TSGGasDiffusionCube.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FEdge   := 0;
FCube   := nil;
FSourses:= nil;
FGazes  := nil;
FCubeCoords := nil;
FRelief := nil;
end;

procedure TSGGasDiffusionCube.Draw();
begin

end;

function TSGGasDiffusionCube.Copy() : TSGGasDiffusionCube;
var
	i : LongWord;
begin
Result := TSGGasDiffusionCube.Create(Context);
Result.InitCube(Edge);
Move(FCube^,Result.FCube^,Edge * Edge * Edge);
if FGazes <> nil then
	begin
	SetLength(Result.FGazes,Length(FGazes));
	if Length(FGazes) > 0 then
		for i := 0 to High(FGazes) do
			Result.FGazes[i] := FGazes[i];
	end;
if FSourses <> nil then
	begin
	SetLength(Result.FSourses,Length(FSourses));
	if Length(FSourses) > 0 then
		for i := 0 to High(FSourses) do
			Result.FSourses[i] := FSourses[i];
	end;
end;

destructor TSGGasDiffusionCube.Destroy();
begin
if FCubeCoords<>nil then
	SetLength(FCubeCoords,0);
if FCube<>nil then
	begin
	FreeMem(FCube);
	FCube:=nil;
	end;
inherited;
end;

class function TSGGasDiffusionCube.ClassName():TSGString;
begin
Result:='TSGGasDiffusionCube';
end;

procedure TSGGasDiffusionCube.ClearGaz();
begin
FillChar(FCube^,FEdge*FEdge*FEdge,0);
UpDateCube();
end;

procedure TSGGasDiffusionCube.InitCube(const Edge : TSGLongWord; const VProgress : PSGProgressBarFloat = nil);
const
	o = 1.98;
var
	i : LongWord;
	Smeshenie : TSGSingle;
	FArRandomSm : array [0..9] of TSGVertex3f;
	Edge3 : LongWord;
begin
for i:=0 to 9 do
	FArRandomSm[i].Import(random*(0.99/Edge),random*(0.99/Edge),random*(0.99/Edge));
FFlag := True;
if FCube <> nil then
	begin
	FreeMem(FCube);
	FCube:=nil;
	end;

FEdge := Edge;
if FEdge mod 2 = 1 then
	FEdge +=1;
Smeshenie:= 1/FEdge;
Edge3 := FEdge * FEdge * FEdge;

GetMem(FCube, Edge3);
GetMem(FReliefCubeIndex, Edge3);
FillChar(FCube^, Edge3, 0);
FillChar(FReliefCubeIndex^, Edge3, 1);
SetLength(FCubeCoords, Edge3);

SetLength(FGazes,3);
FGazes[0].Create(0,1,0);
FGazes[1].Create(1,0,0);
FGazes[2].Create(1,1,1,1,0,1);
SetLength(FSourses,2);
FSourses[0].FGazTypeIndex:=0;
FSourses[0].FCoord.Import(FEdge div 2 + (FEdge div 8),FEdge div 2+ (FEdge div 8),FEdge div 2+ (FEdge div 8));
FSourses[0].FRadius:=1;
FSourses[1].FGazTypeIndex:=1;
FSourses[1].FCoord.Import(FEdge div 2 - (FEdge div 8),FEdge div 2 - (FEdge div 8),FEdge div 2 - (FEdge div 8));
FSourses[1].FRadius:=1;

for i := 0 to Edge3 - 1 do
	begin
	FCubeCoords[i].Import(
		Smeshenie + o*(i mod FEdge)/(FEdge - 1) - 1,
		Smeshenie + o*((i div FEdge) mod FEdge)/(FEdge - 1) - 1,
		Smeshenie + o*((i div FEdge) div FEdge)/(FEdge - 1) - 1);
	{$IFNDEF RELIEFDEBUG}
	FCubeCoords[i]+=
		FArRandomSm[Random(10)];
		{$ENDIF}
	end;

InitReliefIndexes(VProgress);

UpDateCube();
if VProgress <> nil then
	VProgress ^ := 1;
end;

function TSGGasDiffusionCube.ReliefCubeIndex (const x,y,z : Word):TSGGGDC;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=@FReliefCubeIndex[(x*FEdge+y)*FEdge+z];
end;

function TSGGasDiffusionCube.Cube (const x,y,z:Word):TSGGGDC;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=@FCube[(x*FEdge+y)*FEdge+z];
end;

procedure TSGGasDiffusionCube.InitReliefIndexes(const VProgress : PSGProgressBarFloat = nil);

function Invert(const i : LongWord; const Inverting : TSGBoolean = True) : TSGFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Inverting then
	Result := (FEdge - 1 - i)/(Edge-1)*2 - 1
else
	Result := i/(Edge-1)*2 - 1
end;

function CoordFromXYZ(const x,y,z : LongWord; const n : LongWord):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case n of
0,1: Result.Import(Invert(z,False),Invert(y),Invert(x));
2,3: Result.Import(Invert(z),Invert(y,False),Invert(x));
4: Result.Import(Invert(z),Invert(y),Invert(x,False));
5: Result.Import(Invert(z,False),Invert(y,False),Invert(x,False));
end;
end;

function PointBeetWeen(const a,b,p:Single):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	ab : TSGFloat;
begin
ab := Abs(b-a);
Result := Abs(Abs(p-a) + Abs(p-b) - ab) < ab * SGZero * 200;
end;

function ScalePointToTriangle3D(const t1,t2,t3,v:TSGVertex2f; const t1z,t2z,t3z : Single):Single;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	t1t2, t2t3, t3t1, vt1, vt2, vt3, s : TSGFloat;
begin
t1t2 := Abs(t1 - t2);
t2t3 := Abs(t2 - t3);
t3t1 := Abs(t3 - t1);

vt1 := Abs(v - t1);
vt2 := Abs(v - t2);
vt3 := Abs(v - t3);

s := SGTriangleSize(t1t2, t2t3, t3t1);

Result := 
	(SGTriangleSize(t2t3, vt3, vt2)/s)*t1z + 
	(SGTriangleSize(t3t1, vt1, vt3)/s)*t2z + 
	(SGTriangleSize(t1t2, vt1, vt2)/s)*t3z;
end;

function PointInTriangleZ(const t1,t2,t3,v:TSGVertex3f;const b : Single):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGIsVertexOnTriangle( 
	SGVertex2fImport(t1.x,t1.y),
	SGVertex2fImport(t2.x,t2.y),
	SGVertex2fImport(t3.x,t3.y),
	SGVertex2fImport(v.x,v.y));
if Result then
	Result := PointBeetWeen(
		b,
		ScalePointToTriangle3D(
			SGVertex2fImport(t1.x,t1.y),
			SGVertex2fImport(t2.x,t2.y),
			SGVertex2fImport(t3.x,t3.y),
			SGVertex2fImport(v.x,v.y),
			t1.z,t2.z,t3.z),
		v.z);
end;

function PointInTriangleX(const t1,t2,t3,v:TSGVertex3f;const b : Single):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SGIsVertexOnTriangle( 
	SGVertex2fImport(t1.z,t1.y),
	SGVertex2fImport(t2.z,t2.y),
	SGVertex2fImport(t3.z,t3.y),
	SGVertex2fImport(v.z,v.y));
if Result then
	Result := PointBeetWeen(
		b,
		ScalePointToTriangle3D(
			SGVertex2fImport(t1.z,t1.y),
			SGVertex2fImport(t2.z,t2.y),
			SGVertex2fImport(t3.z,t3.y),
			SGVertex2fImport(v.z,v.y),
			t1.x,t2.x,t3.x),
		v.x);
end;

function PointInTriangleY(const t1,t2,t3,v:TSGVertex3f;const b : Single):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin 
Result := SGIsVertexOnTriangle( 
	SGVertex2fImport(t1.x,t1.z),
	SGVertex2fImport(t2.x,t2.z),
	SGVertex2fImport(t3.x,t3.z),
	SGVertex2fImport(v.x,v.z));
if Result then
	Result := PointBeetWeen(
		b,
		ScalePointToTriangle3D(
			SGVertex2fImport(t1.x,t1.z),
			SGVertex2fImport(t2.x,t2.z),
			SGVertex2fImport(t3.x,t3.z),
			SGVertex2fImport(v.x,v.z),
			t1.y,t2.y,t3.y),
		v.y);
end;

function PointInTriangle(const t1,t2,t3,v,n:TSGVertex3f):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if SGIsVertexOnLine(t1,t2,v) or SGIsVertexOnLine(t1,t3,v) or SGIsVertexOnLine(t2,t3,v) then
	begin
	Result := True;
	Exit;
	end;
if (abs(n.x)<SGZero) and (abs(n.y)<SGZero) then
	Result := PointInTriangleZ(t1,t2,t3,v,n.z)
else if (abs(n.z)<SGZero) and (abs(n.y)<SGZero) then
	Result := PointInTriangleX(t1,t2,t3,v,n.x)
else if (abs(n.x)<SGZero) and (abs(n.z)<SGZero) then
	Result := PointInTriangleY(t1,t2,t3,v,n.y);
end;

function PointInPolygone(const sr : PSGGasDiffusionSingleRelief; const index : LongWord; const v : TSGVertex3f; const n : TSGVertex3f;const ReliefIndex : Byte):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
const
	o = 4;
var
	i : LongWord;
begin
Result := False;
for i := 1 to High(sr^.FPolygones[index]) - 1 do
	begin
	if PointInTriangle(
		sr^.FPoints[sr^.FPolygones[index][0]] * GetReliefMatrix(ReliefIndex) + n,
		sr^.FPoints[sr^.FPolygones[index][i]] * GetReliefMatrix(ReliefIndex) + n,
		sr^.FPoints[sr^.FPolygones[index][i+1]] * GetReliefMatrix(ReliefIndex) + n,
		v,n) then
			begin
			Result := True;
			Break;
			end;
	end;
end;

function VertexFromIndex(const index : LongWord):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case index of
0:Result.Import(0,-1,0);
1:Result.Import(0,1,0);
2:Result.Import(1,0,0);
3:Result.Import(-1,0,0);
4:Result.Import(0,0,-1);
5:Result.Import(0,0,1);
end;
end;

var
	FRCI : TSGGGDC = nil;

function RCI (const x,y,z : Word):TSGGGDC;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=@FRCI[(x*FEdge+y)*FEdge+z];
end;

var
	i, j : LongWord;
	i1, i2, i3, AllPolygoneSize, PolygoneIndex : LongWord;
begin
if FRelief <> nil then
	begin
	PolygoneIndex := 0;
	AllPolygoneSize := 0; 
	for j := 0 to 5 do
		if FRelief^.FData[j].FEnabled then
			if FRelief^.FData[j].FPolygones <> nil then if Length(FRelief^.FData[j].FPolygones) <> 0 then
				AllPolygoneSize += Length(FRelief^.FData[j].FPolygones);
	for j := 0 to 5 do
		begin
		if FRelief^.FData[j].FEnabled then
			begin
			if FRelief^.FData[j].FPolygones <> nil then if Length(FRelief^.FData[j].FPolygones) <> 0 then
				begin
				for i := 0 to High(FRelief^.FData[j].FPolygones) do
					begin
					for i2 := 0 to Edge - 1 do 
						begin
						for i1 := 0 to Edge - 1 do 
						for i3 := 0 to Edge - 1 do
							begin
							ReliefCubeIndex(i1,i2,i3)^ := 
								Byte(
									Boolean(ReliefCubeIndex(i1,i2,i3)^) and 
									(not PointInPolygone(
										@FRelief^.FData[j],
										i,
										CoordFromXYZ(i1,i2,i3,j),
										VertexFromIndex(j),
										j))
									);
							end;
						if VProgress <> nil then
							VProgress ^ := PolygoneIndex / AllPolygoneSize + (1 / AllPolygoneSize) * (i2 / (Edge - 1));
						end;
					PolygoneIndex += 1;
					end;
				end;
			end;
		end;
	end;
FRCI := GetMem(Edge * Edge * Edge);
FillChar(FRCI^, Edge * Edge * Edge, 1);
i1:=0;
while i1<FEdge do
	begin
	i2:=0;
	while i2<FEdge do
		begin
		i3:=0;
		while i3<FEdge do
			begin
			RCI(i1,i2,i3)^ := 
				Byte(
					Boolean(ReliefCubeIndex(i1,  i2+1,i3+1)^) and
					Boolean(ReliefCubeIndex(i1+1,i2+1,i3+1)^) and
					Boolean(ReliefCubeIndex(i1,  i2  ,i3+1)^) and
					Boolean(ReliefCubeIndex(i1+1,i2  ,i3+1)^) and
					Boolean(ReliefCubeIndex(i1,  i2+1,i3  )^) and
					Boolean(ReliefCubeIndex(i1+1,i2+1,i3  )^) and
					Boolean(ReliefCubeIndex(i1,  i2  ,i3  )^) and
					Boolean(ReliefCubeIndex(i1+1,i2  ,i3  )^)
				);
			i3+=2;
			end;
		i2+=2;
		end;
	i1+=2;
	end;
i1:=1;
while i1<FEdge-3 do
	begin
	i2:=1;
	while i2<FEdge-3 do
		begin
		i3:=1;
		while i3<FEdge-3 do
			begin
			RCI(i1,i2,i3)^ :=
				Byte(
					Boolean(ReliefCubeIndex(i1,  i2+1,i3+1)^) and
					Boolean(ReliefCubeIndex(i1+1,i2+1,i3+1)^) and
					Boolean(ReliefCubeIndex(i1,  i2  ,i3+1)^) and
					Boolean(ReliefCubeIndex(i1+1,i2  ,i3+1)^) and
					Boolean(ReliefCubeIndex(i1,  i2+1,i3  )^) and
					Boolean(ReliefCubeIndex(i1+1,i2+1,i3  )^) and
					Boolean(ReliefCubeIndex(i1,  i2  ,i3  )^) and
					Boolean(ReliefCubeIndex(i1+1,i2  ,i3  )^)
				);
			i3+=2;
			end;
		i2+=2;
		end;
	i1+=2;
	end;
for i := 0 to Edge * Edge * Edge - 1 do
	if (not TSGBoolean(FRCI[i])) then
		FReliefCubeIndex[i] := 0;
FreeMem(FRCI);
end;

procedure TSGGasDiffusionCube.UpDateSourses();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	I : TSGLongWord;
	j1,j2,j3,j1d,j2d,j3d : integer;
begin
if FSourses<>nil then
	for i:=0 to High(FSourses) do
		begin
		for j1:=-FSourses[i].FRadius to FSourses[i].FRadius do
		for j2:=-FSourses[i].FRadius to FSourses[i].FRadius do
		for j3:=-FSourses[i].FRadius to FSourses[i].FRadius do
			begin
			j1d := FSourses[i].FCoord.x+j1;
			j2d := FSourses[i].FCoord.y+j2;
			j3d := FSourses[i].FCoord.z+j3;
			if (Cube(j1d,j2d,j3d)^=0) and TSGBoolean(ReliefCubeIndex(j1d,j2d,j3d)) then
				Cube(j1d,j2d,j3d)^:=FSourses[i].FGazTypeIndex+1;
			end;
		end;
end;

procedure TSGGasDiffusionCube.UpDateCube();
procedure MoveGazInSmallCube(const i1,i2,i3:TSGLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure ProvSmesh(const a,b : TSGGGDC);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : LongWord;
begin
if (FGazes<>nil) and (not((a^=0) or (b^=0))) then
	for i:=0 to High(FGazes) do
		if (FGazes[i].FArParents[0]<>-1) and (FGazes[i].FArParents[1]<>-1) and 
			(((a^-1 = FGazes[i].FArParents[0]) and (b^-1 = FGazes[i].FArParents[1])) or 
			((b^-1 = FGazes[i].FArParents[0]) and (a^-1 = FGazes[i].FArParents[1]))) then
				begin
				a^ := i + 1;
				b^ := 0;
				Exit;
				end;
end;
procedure QuadricMove(const a,b,c,d : TSGGGDC);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var 
	eee : Byte;
begin
if not((a^=0) or (b^=0) or (c^=0) or (d^=0)) then
	Exit;
eee := a^;
a^ := b^;
b^ := c^;
c^ := d^;
d^ := eee;
ProvSmesh(a,b);
ProvSmesh(b,c);
ProvSmesh(c,d);
ProvSmesh(d,a);
end;
var
	b1,b2:Byte;
begin
case random(5) of
1,2://x
	begin
	if TSGBoolean(Random(2)) then
		begin// x 1
		QuadricMove(
			Cube(i1  ,i2  ,i3  ),
			Cube(i1  ,i2  ,i3+1),
			Cube(i1  ,i2+1,i3+1),
			Cube(i1  ,i2+1,i3  ));
		QuadricMove(
			Cube(i1+1,i2  ,i3  ),
			Cube(i1+1,i2  ,i3+1),
			Cube(i1+1,i2+1,i3+1),
			Cube(i1+1,i2+1,i3  ));
		end
	else
		begin// x 0
		QuadricMove(
			Cube(i1  ,i2  ,i3  ),
			Cube(i1  ,i2+1,i3  ),
			Cube(i1  ,i2+1,i3+1),
			Cube(i1  ,i2  ,i3+1));
		QuadricMove(
			Cube(i1+1,i2  ,i3  ),
			Cube(i1+1,i2+1,i3  ),
			Cube(i1+1,i2+1,i3+1),
			Cube(i1+1,i2  ,i3+1));
		end;
	end;
3,4://y
	begin
	if Boolean(Random(2)) then
		begin// y 1
		QuadricMove(
			Cube(i1  ,i2  ,i3  ),
			Cube(i1  ,i2  ,i3+1),
			Cube(i1+1,i2  ,i3+1),
			Cube(i1+1,i2  ,i3  ));
		QuadricMove(
			Cube(i1  ,i2+1,i3  ),
			Cube(i1  ,i2+1,i3+1),
			Cube(i1+1,i2+1,i3+1),
			Cube(i1+1,i2+1,i3  ));
		end
	else
		begin// y 0
		QuadricMove(
			Cube(i1  ,i2  ,i3  ),
			Cube(i1+1,i2  ,i3  ),
			Cube(i1+1,i2  ,i3+1),
			Cube(i1  ,i2  ,i3+1));
		QuadricMove(
			Cube(i1  ,i2+1,i3  ),
			Cube(i1+1,i2+1,i3  ),
			Cube(i1+1,i2+1,i3+1),
			Cube(i1  ,i2+1,i3+1));
		end;
	end;
0://z
	begin
	if Boolean(Random(2)) then
		begin// z 1
		QuadricMove(
			Cube(i1  ,i2  ,i3  ),
			Cube(i1  ,i2+1,i3  ),
			Cube(i1+1,i2+1,i3  ),
			Cube(i1+1,i2  ,i3  ));
		QuadricMove(
			Cube(i1  ,i2  ,i3+1),
			Cube(i1  ,i2+1,i3+1),
			Cube(i1+1,i2+1,i3+1),
			Cube(i1+1,i2  ,i3+1));
		end
	else
		begin//z 0
		QuadricMove(
			Cube(i1  ,i2  ,i3  ),
			Cube(i1+1,i2  ,i3  ),
			Cube(i1+1,i2+1,i3  ),
			Cube(i1  ,i2+1,i3  ));
		QuadricMove(
			Cube(i1  ,i2  ,i3+1),
			Cube(i1+1,i2  ,i3+1),
			Cube(i1+1,i2+1,i3+1),
			Cube(i1  ,i2+1,i3+1));
		end;
	end;
end;
end;

procedure UpDateGaz();
var
	i1,i2,i3:TSGLongWord;
begin
if FFlag then
	begin
	i1:=0;
	while i1<FEdge do
		begin
		i2:=0;
		while i2<FEdge do
			begin
			i3:=0;
			while i3<FEdge do
				begin
				if Boolean(ReliefCubeIndex(i1,i2,i3)^) then
					MoveGazInSmallCube(i1,i2,i3);
				i3+=2;
				end;
			i2+=2;
			end;
		i1+=2;
		end;
	end
else
	begin
	i1:=1;
	while i1<FEdge-1 do
		begin
		i2:=1;
		while i2<FEdge-1 do
			begin
			i3:=1;
			while i3<FEdge-1 do
				begin
				if Boolean(ReliefCubeIndex(i1,i2,i3)^) then
					MoveGazInSmallCube(i1,i2,i3);
				i3+=2;
				end;
			i2+=2;
			end;
		i1+=2;
		end;
	end;
FFlag := not FFlag;
end;
procedure UpDateIfOpenBounds();
var
	i,ii:TSGLongWord;
begin
i := 0;
while i<FEdge do
	begin
	ii := 0;
	while ii<FEdge do
		begin
		Cube(i,ii,0)^:=0;
		Cube(i,ii,FEdge-1)^:=0;
		Cube(0,i,ii)^:=0;
		Cube(FEdge-1,i,ii)^:=0;
		Cube(i,0,ii)^:=0;
		Cube(i,FEdge-1,ii)^:=0;
		Inc(ii);
		end;
	Inc(i);
	end;
end;
begin
UpDateGaz();
UpDateSourses();
UpDateIfOpenBounds();
end;

function TSGGasDiffusionCube.CalculateMesh(const VRelief : PSGGasDiffusionRelief = nil{$IFDEF RELIEFDEBUG};const FInReliafDebug : TSGLongWord = 0{$ENDIF}):TSGCustomModel;
var
	i : TSGLongWord;
begin
Result:=TSGCustomModel.Create();
Result.Context := Context;

FDinamicQuantityMoleculs := 0;
if FGazes<>nil then
	for i:= 0 to High(FGazes) do
		FGazes[i].FDinamicQuantity := 0;

{$IFDEF RELIEFDEBUG}
if FInReliafDebug<>0 then
	begin
	for i:=0 to FEdge * FEdge * FEdge -1 do
		begin
		if  ((FInReliafDebug=1) and (FReliefCubeIndex[i]=1)) or
			((FInReliafDebug=2) and (FReliefCubeIndex[i]=0)) then
			begin
			Inc(FDinamicQuantityMoleculs);
			end;
		end;
	
	if FDinamicQuantityMoleculs <> 0 then
		begin
		Result.AddObject();
		Result.LastObject().ObjectPoligonesType := SGR_POINTS;
		Result.LastObject().HasNormals := False;
		Result.LastObject().HasTexture := False;
		Result.LastObject().HasColors  := True;
		Result.LastObject().EnableCullFace := False;
		Result.LastObject().VertexType := SGMeshVertexType3f;
		Result.LastObject().SetColorType (SGMeshColorType4b);
		Result.LastObject().Vertexes   := FDinamicQuantityMoleculs;

		FDinamicQuantityMoleculs:=0;
		for i:=0 to FEdge*FEdge*FEdge -1 do
			begin
			if  ((FInReliafDebug=1) and (FReliefCubeIndex[i]=1)) or
				((FInReliafDebug=2) and (FReliefCubeIndex[i]=0)) then
				begin
				if (FInReliafDebug=2) then
					Result.LastObject().SetColor(FDinamicQuantityMoleculs,1,0,0)
				else
					Result.LastObject().SetColor(FDinamicQuantityMoleculs,0,1,0);
				Result.LastObject().ArVertex3f[FDinamicQuantityMoleculs]^:=
					FCubeCoords[i];
				Inc(FDinamicQuantityMoleculs);
				end;
			end;
		end;
	end
else
	begin
	{$ENDIF}
	for i:=0 to FEdge * FEdge * FEdge -1 do
		begin
		if FCube[i]<>0 then
			begin
			Inc(FGazes[FCube[i]-1].FDinamicQuantity);
			end;
		end;
	
	if FGazes<>nil then
		for i:= 0 to High(FGazes) do
			FDinamicQuantityMoleculs += FGazes[i].FDinamicQuantity;

	if FDinamicQuantityMoleculs <> 0 then
		begin
		Result.AddObject();
		Result.LastObject().ObjectPoligonesType := SGR_POINTS;
		Result.LastObject().HasNormals := False;
		Result.LastObject().HasTexture := False;
		Result.LastObject().HasColors  := True;
		Result.LastObject().EnableCullFace := False;
		Result.LastObject().VertexType := SGMeshVertexType3f;
		Result.LastObject().SetColorType (SGMeshColorType4b);



		Result.LastObject().Vertexes   := FDinamicQuantityMoleculs;

		FDinamicQuantityMoleculs:=0;
		for i:=0 to FEdge*FEdge*FEdge -1 do
			begin
			if FCube[i]<>0 then
				begin
				Result.LastObject().SetColor(FDinamicQuantityMoleculs,
					FGazes[FCube[i]-1].FColor.r,
					FGazes[FCube[i]-1].FColor.g,
					FGazes[FCube[i]-1].FColor.b);
				Result.LastObject().ArVertex3f[FDinamicQuantityMoleculs]^:=
					FCubeCoords[i];
				Inc(FDinamicQuantityMoleculs);
				end;
			end;
		end;
{$IFDEF RELIEFDEBUG}
	end;
{$ENDIF}

if VRelief = nil then
	begin
	Result.AddObject();
	Result.LastObject().ObjectPoligonesType := SGR_LINES;
	Result.LastObject().HasNormals := False;
	Result.LastObject().HasTexture := False;
	Result.LastObject().HasColors  := True;
	Result.LastObject().EnableCullFace := False;
	Result.LastObject().VertexType := SGMeshVertexType3f;
	Result.LastObject().SetColorType(SGMeshColorType4b);
	Result.LastObject().Vertexes := 28;

	Result.LastObject().ArVertex3f[0]^.Import(-1,-1,-1);
	Result.LastObject().ArVertex3f[1]^.Import(1,-1,-1);

	Result.LastObject().ArVertex3f[2]^.Import(-1,-1,1);
	Result.LastObject().ArVertex3f[3]^.Import(1,-1,1);

	Result.LastObject().ArVertex3f[4]^.Import(-1,1,1);
	Result.LastObject().ArVertex3f[5]^.Import(1,1,1);

	Result.LastObject().ArVertex3f[6]^.Import(-1,1,-1);
	Result.LastObject().ArVertex3f[7]^.Import(1,1,-1);

	Result.LastObject().ArVertex3f[8]^.Import(-1,-1,-1);
	Result.LastObject().ArVertex3f[9]^.Import(-1,1,-1);

	Result.LastObject().ArVertex3f[10]^.Import(-1,-1,-1);
	Result.LastObject().ArVertex3f[11]^.Import(-1,-1,1);

	Result.LastObject().ArVertex3f[12]^.Import(-1,-1,1);
	Result.LastObject().ArVertex3f[13]^.Import(-1,1,1);

	Result.LastObject().ArVertex3f[14]^.Import(-1,1,1);
	Result.LastObject().ArVertex3f[15]^.Import(-1,1,-1);


	Result.LastObject().ArVertex3f[16]^.Import(1,-1,-1);
	Result.LastObject().ArVertex3f[17]^.Import(1,-1,1);

	Result.LastObject().ArVertex3f[18]^.Import(1,-1,1);
	Result.LastObject().ArVertex3f[19]^.Import(1,1,1);

	Result.LastObject().ArVertex3f[20]^.Import(1,1,1);
	Result.LastObject().ArVertex3f[21]^.Import(1,1,-1);

	Result.LastObject().ArVertex3f[22]^.Import(1,1,-1);
	Result.LastObject().ArVertex3f[23]^.Import(1,-1,-1);

	Result.LastObject().ArVertex3f[24]^.Import(1,-1,1);
	Result.LastObject().ArVertex3f[25]^.Import(-1,-1,-1);

	Result.LastObject().ArVertex3f[26]^.Import(1,-1,-1);
	Result.LastObject().ArVertex3f[27]^.Import(-1,-1,1);
	
	for i:=0 to Result.LastObject().Vertexes - 1 do
		Result.LastObject().SetColor(i,$0A/256,$C7/256,$F5/256);
	end
else
	VRelief^.ExportToMesh(Result);
end;

// Release

procedure TSGGasDiffusion.SaveStageToStream();
begin
if FFileStream<>nil then
	begin
	FMesh.SaveToSG3DM(FFileStream);
	end;
end;

procedure TSGGasDiffusion.ClearDisplayButtons();
var
	i : LongWord;
begin
if FConchLabels<>nil then
	begin
	for i:=0 to High(FConchLabels) do
		FConchLabels[i].Destroy();
	SetLength(FConchLabels,0);
	end;
if FAddNewGazPanel <> nil then
	begin
	FAddNewGazPanel.Destroy();
	FAddNewGazPanel:=nil;
	end;
if FMovieBackToMenuButton <> nil then
	begin
	FMovieBackToMenuButton.Destroy();
	FMovieBackToMenuButton:=nil;
	end;
if FMoviePlayButton <> nil then
	begin
	FMoviePlayButton.Destroy();
	FMoviePlayButton:=nil;
	end;
if FMoviePauseButton <> nil then
	begin
	FMoviePauseButton.Destroy();
	FMoviePauseButton:=nil;
	end;

if FStartEmulatingButton<>nil then
	begin
	FStartEmulatingButton.Destroy();
	FStartEmulatingButton:=nil;
	end;
if FAddNewGazButton<>nil then
	begin
	FAddNewGazButton.Destroy();
	FAddNewGazButton:=nil;
	end;
if FAddNewSourseButton<>nil then
	begin
	FAddNewSourseButton.Destroy();
	FAddNewSourseButton:=nil;
	end;
if FPauseEmulatingButton<>nil then
	begin
	FPauseEmulatingButton.Destroy();
	FPauseEmulatingButton:=nil;
	end;
if FSaveImageButton<> nil then
	begin
	FSaveImageButton.Destroy();
	FSaveImageButton:=nil;
	end;
if FAddSechSecondPanelButton<>nil then
	begin
	FAddSechSecondPanelButton.Destroy();
	FAddSechSecondPanelButton:=nil;
	end;
if FStopEmulatingButton<>nil then
	begin
	FStopEmulatingButton.Destroy();
	FStopEmulatingButton:=nil;
	end;
if FDeleteSechenieButton<>nil then
	begin
	FDeleteSechenieButton.Destroy();
	FDeleteSechenieButton:=nil;
	end;
if FAddSechenieButton<>nil then
	begin
	FAddSechenieButton.Destroy();
	FAddSechenieButton:=nil;
	end;
if FBackToMenuButton<>nil then
	begin
	FBackToMenuButton.Destroy();
	FBackToMenuButton:=nil;
	end;
if FAddNewGazPanel <> nil then
	begin
	FAddNewGazPanel.Destroy();
	FAddNewGazPanel:=nil;
	end;
if FAddNewSoursePanel <> nil then
	begin
	FAddNewSoursePanel.Destroy();
	FAddNewSoursePanel:=nil;
	end;
if FAddNewGazPanel <> nil then
	begin
	FAddNewGazPanel.Destroy();
	FAddNewGazPanel:=nil;
	end;
if FSecheniePanel <> nil then
	begin
	FSecheniePanel.Destroy();
	FSecheniePanel:=nil;
	end;
if FNewSecheniePanel <> nil then
	begin
	FNewSecheniePanel.Destroy();
	FNewSecheniePanel:=nil;
	end;
if FAddNewGazPanel <> nil then
	begin
	FAddNewGazPanel.Destroy();
	FAddNewGazPanel := nil;
	end;
end;

destructor TSGGasDiffusion.Destroy();
begin
if FMesh<>nil then
	FMesh.Destroy();
if FArCadrs <> nil then
	SetLength(FArCadrs,0);
FNewScenePanel.Destroy();
FLoadScenePanel.Destroy();
FTahomaFont.Destroy();
if FCube<>nil then
	FCube.Destroy();
if FFileStream<>nil then
	FFileStream.Destroy();
ClearDisplayButtons();
if FInfoLabel<>nil then
	FInfoLabel.Destroy();
if FNewSecheniePanel<>nil then
	FNewSecheniePanel.Destroy();
if FSecheniePanel<>nil then
	FSecheniePanel.Destroy();
if FSechenieImage<>nil then
	FSechenieImage.Destroy();
if FBoundsOptionsPanel <> nil then
	FBoundsOptionsPanel.Destroy();

// allready in FBoundsOptionsPanel.Destroy();
//if FRelefRedactor <> nil then
//	FRelefRedactor.Destroy();

if FRedactorBackButton <> nil then
	FRedactorBackButton.Destroy();
inherited;
end;

class function TSGGasDiffusion.ClassName():TSGString;
begin
Result := 'Диффузия в газах';
end;

procedure mmmFBackToMenuButtonProcedure(Button:TSGButton);
var
	i : LongWord;
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FAddNewSourseButton.Visible := False;
	FAddNewGazButton.Visible := False;
	FStartEmulatingButton.Visible := False;
	FPauseEmulatingButton.Visible := False;
	FDeleteSechenieButton.Visible := False;
	FAddSechSecondPanelButton.Visible := False;
	FAddSechenieButton.Visible := False;
	FBackToMenuButton.Visible := False;
	FStopEmulatingButton.Visible := False;
	FSaveImageButton.Visible := False;
	FInfoLabel.Caption:='';
	if FCube <> nil then
		begin
		FCube.Destroy();
		FCube:=nil;
		end;
	if FFileStream <> nil then
		begin
		FFileStream.Destroy();
		FFileStream:=nil;
		end;
	if FMesh<>nil then
		begin
		FMesh.Destroy();
		FMesh:=nil;
		end;
	FDiffusionRuned := False;
	FNewScenePanel.Visible:=True;
	
	if FUsrSechPanel <> nil then
		begin
		FUsrSechPanel.Destroy();
		FUsrSechPanel := nil;
		end;
	if FAddNewGazPanel<>nil then
		begin
		FAddNewGazPanel.Destroy();
		FAddNewGazPanel:=nil;
		end;
	if FAddNewSoursePanel<>nil then
		begin
		FAddNewSoursePanel.Destroy();
		FAddNewSoursePanel:=nil;
		end;
	if FNewSecheniePanel<>nil then
		begin
		FNewSecheniePanel.Destroy();
		FNewSecheniePanel:=nil;
		FPlaneComboBox   :=nil;
		end;
	if FSecheniePanel<>nil then
		begin
		(FSecheniePanel.LastChild as TSGPicture).Image := nil;
		FSecheniePanel.Destroy();
		FSecheniePanel:=nil;
		end;
	if FSechenieImage<>nil then
		begin
		FSechenieImage.Destroy();
		FSechenieImage:=nil;
		end;
	for i:=0 to High(FConchLabels) do
		FConchLabels[i].Visible:=False;
end; end;
procedure mmmFPauseDiffusionButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FDiffusionRuned := False;
	Button.Active := False;
	FStopEmulatingButton.Active := True;
	FStartEmulatingButton.Active := True;
end; end;
procedure mmmFNewSecheniePanelButtonOnChange(Button:TSGButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FAddNewSourseButton.Active := True;
	FAddNewGazButton.Active := True;
	FNewSecheniePanel.Visible := False;
	FAddSechSecondPanelButton.Active := True;
	FSaveImageButton.Active := True;
end; end;
procedure mmmFAddSechenieButtonProcedure(Button:TSGButton);
var
	a : LongWord;
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FDeleteSechenieButton.Active:=True;
	Button.Active:=False;
	FAddNewSourseButton.Active := False;
	FAddNewGazButton.Active := False;
	
	FImageSechenieBounds :=1;
	while FImageSechenieBounds < FCube.Edge do
		FImageSechenieBounds *= 2;
	
	a := FTahomaFont.FontHeight*2 + 2*2 + 20;
	
	FNewSecheniePanel := TSGPanel.Create();
	SGScreen.CreateChild(FNewSecheniePanel);
	SGScreen.LastChild.SetBounds(Context.Width-10-a,Context.Height-10-a,a,a);
	SGScreen.LastChild.BoundsToNeedBounds();
	SGScreen.LastChild.Anchors:=[SGAnchRight,SGAnchBottom];
	SGScreen.LastChild.UserPointer:=Button.UserPointer;
	SGScreen.LastChild.Visible:=True;
	
	FPlaneComboBox := TSGComboBox.Create();
	FNewSecheniePanel.CreateChild(FPlaneComboBox);
	FNewSecheniePanel.LastChild.SetBounds(5,5,190,FTahomaFont.FontHeight+2);
	FNewSecheniePanel.LastChild.BoundsToNeedBounds();
	FNewSecheniePanel.LastChild.UserPointer:=Button.UserPointer;
	FNewSecheniePanel.LastChild.Visible:=True;
	FPlaneComboBox.CreateItem('XoY');
	FPlaneComboBox.CreateItem('XoZ');
	FPlaneComboBox.CreateItem('ZoY');
	FPlaneComboBox.SelectItem := 0;
	
	FNewSecheniePanel.CreateChild(TSGButton.Create());
	FNewSecheniePanel.LastChild.SetBounds(5,FTahomaFont.FontHeight+10,190,FTahomaFont.FontHeight+2);
	FNewSecheniePanel.LastChild.BoundsToNeedBounds();
	FNewSecheniePanel.LastChild.UserPointer:=Button.UserPointer;
	FNewSecheniePanel.LastChild.Visible:=True;
	FNewSecheniePanel.LastChild.Caption := 'ОК';
	(FNewSecheniePanel.LastChild as TSGButton).OnChange := TSGComponentProcedure(@mmmFNewSecheniePanelButtonOnChange);
	
	a := (FCube.Edge+1)*2;
	
	FSecheniePanel := TSGPanel.Create();
	SGScreen.CreateChild(FSecheniePanel);
	SGScreen.LastChild.SetBounds(5,Context.Height-10-a,a,a);
	SGScreen.LastChild.BoundsToNeedBounds();
	SGScreen.LastChild.Anchors:=[SGAnchBottom];
	SGScreen.LastChild.UserPointer:=Button.UserPointer;
	SGScreen.LastChild.Visible:=True;
	
	FSechenieImage:=TSGImage.Create();
	FSechenieImage.Context := Context;
	FSechenieImage.Image.Clear();
	FSechenieImage.Width          := FImageSechenieBounds;
	FSechenieImage.Height         := FImageSechenieBounds;
	FSechenieImage.Image.Channels := 4;
	FSechenieImage.Image.BitDepth := 8;
	FSechenieImage.Image.BitMap   := GetMem(FCube.Edge*FCube.Edge*FSechenieImage.Image.Channels);
	FSechenieImage.Image.CreateTypes();
	
	FSecheniePanel.CreateChild(TSGPicture.Create());
	FSecheniePanel.LastChild.SetBounds(5,5,a-10,a-10);
	FSecheniePanel.LastChild.BoundsToNeedBounds();
	FSecheniePanel.LastChild.Visible:=True;
	
	(FSecheniePanel.LastChild as TSGPicture).Image       := FSechenieImage;
	(FSecheniePanel.LastChild as TSGPicture).EnableLines := True;
	(FSecheniePanel.LastChild as TSGPicture).SecondPoint.Import(
		FCube.Edge/FImageSechenieBounds,
		FCube.Edge/FImageSechenieBounds);
	
	UpDateSechenie();
end; end;
procedure mmmFDeleteSechenieButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FAddSechSecondPanelButton.Active := False;
	FSaveImageButton.Active := False;
	if FUsrSechPanel <> nil then
		begin
		FUsrSechPanel.Destroy();
		FUsrSechPanel := nil;
		end;
	FAddSechenieButton.Active:= (FAddNewGazPanel=nil) or ((FAddNewGazPanel<>nil) and (FAddNewGazPanel.Visible = False));
	Button.Active:=False;
	
	if FNewSecheniePanel<>nil then
		begin
		FNewSecheniePanel.Destroy();
		FNewSecheniePanel:=nil;
		FPlaneComboBox   :=nil;
		end;
	if FSecheniePanel<>nil then
		begin
		(FSecheniePanel.LastChild as TSGPicture).Image := nil;
		FSecheniePanel.Destroy();
		FSecheniePanel:=nil;
		end;
	if FSechenieImage<>nil then
		begin
		FSechenieImage.Destroy();
		FSechenieImage:=nil;
		end;
end; end;

procedure TSGGasDiffusion.DrawComplexCube();
var
	FArray  : packed array[0..35] of 
			packed record
				FVertex:TSGVertex3f;
				FColor:TSGColor4b;
				end;
	I : Byte;
begin
Render.Color4f(0,0,0,0);
i:=0;
FArray[i+0].FVertex.Import(1,1,1);
FArray[i+0].FColor .Import(0,0,0,0);
FArray[i+1].FVertex.Import(1,1,-1);
FArray[i+1].FColor .Import(0,0,0,0);
FArray[i+2].FVertex.Import(1,-1,-1);
FArray[i+2].FColor .Import(0,0,0,0);
FArray[i+3].FVertex.Import(1,-1,1);
FArray[i+3].FColor .Import(0,0,0,0);
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

i+=6;
FArray[i+0]:=FArray[0];
FArray[i+1]:=FArray[3];
FArray[i+2].FVertex.Import(-1,-1,1);
FArray[i+2].FColor .Import(0,0,0,0);
FArray[i+3].FVertex.Import(-1,1,1);
FArray[i+3].FColor .Import(0,0,0,0);
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

i+=6;
FArray[i+0]:=FArray[3];
FArray[i+1]:=FArray[2];
FArray[i+2].FVertex.Import(-1,-1,-1);
FArray[i+2].FColor .Import(0,0,0,0);
FArray[i+3]:=FArray[8];
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

i+=6;
FArray[i+0]:=FArray[0];
FArray[i+1]:=FArray[9];
FArray[i+2].FVertex.Import(-1,1,-1);
FArray[i+2].FColor .Import(0,0,0,0);
FArray[i+3]:=FArray[1];
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

i+=6;
FArray[i+0]:=FArray[9];
FArray[i+1]:=FArray[3*6+2];
FArray[i+2]:=FArray[2*6+2];
FArray[i+3]:=FArray[8];
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

i+=6;
FArray[i+0]:=FArray[1];
FArray[i+1]:=FArray[2];
FArray[i+2]:=FArray[2*6+2];
FArray[i+3]:=FArray[3*6+2];
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

Render.EnableClientState(SGR_VERTEX_ARRAY);
Render.EnableClientState(SGR_COLOR_ARRAY);

Render.VertexPointer(3, SGR_FLOAT,         SizeOf(FArray[0]), @FArray[0].FVertex);
Render.ColorPointer (4, SGR_UNSIGNED_BYTE, SizeOf(FArray[0]), @FArray[0].FColor);

Render.DrawArrays(SGR_TRIANGLES, 0, Length(FArray));

Render.DisableClientState(SGR_COLOR_ARRAY);
Render.DisableClientState(SGR_VERTEX_ARRAY);
end;

function TSGGasDiffusion.GetPointColor( const i,ii,iii : LongWord):Byte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := GetPointColorCube(i,ii,iii,FCube);
end;

function TSGGasDiffusion.GetPointColorCube( const i,ii,iii : LongWord; const VCube : TSGGasDiffusionCube):Byte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case FPlaneComboBox.SelectItem of
1:Result := VCube.Cube(ii,i,iii)^;
0:Result := VCube.Cube(ii,iii,i)^;
2:Result := VCube.Cube(iii,i,ii)^;
end;
end;

procedure TSGGasDiffusion.UpDateSechenie();
var
	i,ii:LongWord;
var
	BitMap : PByte;
	iii : LongWord;
	iiii : byte;
	a : record x,y,z:Real; end;
	color : TSGColor4f;
begin
{$IFNDEF MOBILE}
if FNewSecheniePanel.Visible then
	begin
	DrawComplexCube();
	FSechenieUnProjectVertex := SGGetVertexUnderPixel(Render,Context.CursorPosition());
	if Abs(FSechenieUnProjectVertex) < 2 then
		begin
		case FPlaneComboBox.SelectItem of
		0: FPointerSecheniePlace := FSechenieUnProjectVertex.y;
		1: FPointerSecheniePlace := FSechenieUnProjectVertex.x;
		2: FPointerSecheniePlace := FSechenieUnProjectVertex.z;
		end;
		if FPointerSecheniePlace > 1 then
			FPointerSecheniePlace := 0.9999
		else if FPointerSecheniePlace < -1 then
			FPointerSecheniePlace := -0.9999;
		end;
	end;
	{$ENDIF}
iii := Trunc(((FPointerSecheniePlace+1)/2)*FCube.Edge);
FSechenieImage.FreeTexture();
FreeMem(FSechenieImage.Image.BitMap);
GetMem(BitMap,FImageSechenieBounds*FImageSechenieBounds*FSechenieImage.Image.Channels);
FSechenieImage.Image.BitMap := BitMap;
fillchar(BitMap^,FImageSechenieBounds*FImageSechenieBounds*FSechenieImage.Image.Channels,0);
for i:=0 to FCube.Edge - 1 do
	for ii:=0 to FCube.Edge - 1 do
		begin
		iiii := GetPointColor(i,ii,iii);
		if iiii <> 0 then
			begin
			color := FCube.FGazes[iiii-1].FColor;
			BitMap[(i*FImageSechenieBounds + ii)*FSechenieImage.Image.Channels+0]:=trunc(color.r*255);
			BitMap[(i*FImageSechenieBounds + ii)*FSechenieImage.Image.Channels+1]:=trunc(color.g*255);
			BitMap[(i*FImageSechenieBounds + ii)*FSechenieImage.Image.Channels+2]:=trunc(color.b*255);
			BitMap[(i*FImageSechenieBounds + ii)*FSechenieImage.Image.Channels+3]:=255;
			end
		else
			begin
			if iii>0 then
				iiii:=GetPointColor(i,ii,iii-1);
			if (iiii=0) and (iii<FCube.Edge-1) then
				iiii:=GetPointColor(i,ii,iii+1);
			if iiii<>0 then
				begin
				color := FCube.FGazes[iiii-1].FColor;
				BitMap[(i*FImageSechenieBounds + ii)*FSechenieImage.Image.Channels+0]:=trunc(color.r*255);
				BitMap[(i*FImageSechenieBounds + ii)*FSechenieImage.Image.Channels+1]:=trunc(color.g*255);
				BitMap[(i*FImageSechenieBounds + ii)*FSechenieImage.Image.Channels+2]:=trunc(color.b*255);
				BitMap[(i*FImageSechenieBounds + ii)*FSechenieImage.Image.Channels+3]:=127;
				end;
			end;
		end;
FSechenieImage.ToTexture();
end;

procedure mmmFStopDiffusionButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FDiffusionRuned := False;
	Button.Active := False;
	FStartEmulatingButton.Active := True;
	FPauseEmulatingButton.Active := False;
	if FFileStream<>nil then
		begin
		FFileStream.Destroy();
		FFileStream:=nil;
		end;
	FCube.ClearGaz();
	FMesh:=FCube.CalculateMesh(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
end; end;

procedure mmmFRunDiffusionButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FDiffusionRuned := True;
	Button.Active := False;
	FStopEmulatingButton.Active := True;
	FPauseEmulatingButton.Active := True;
	if FEnableSaving and (FFileStream=nil) then
		begin
		FFileName   := SGGetFreeFileName(PredStr+Catalog+Slash+'Save.GDS','number');
		FFileStream := TFileStream.Create(FFileName,fmCreate);
		end;
end; end;

type
	TSGGDrawColor=class(TSGComponent)
			public
		Color : TSGColor4f;
			public
		procedure FromDraw();override;
		end;

procedure TSGGDrawColor.FromDraw();
begin
if (FVisible) or (FVisibleTimer>SGZero) then
	begin
	Color.a := FVisibleTimer;
	SGRoundQuad(Render,
		SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		5,10,
		Color,
		Color,
		not True,not False);
	end;
inherited;
end;

procedure UpdateNewGasPanel(Panel:TSGComponent);
var
	g,i : LongWord;
begin with TSGGasDiffusion(Panel.UserPointer) do begin
if not ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
	begin
	g  := (Panel.Children[1] as TSGComboBox).SelectItem;
	(Panel.Children[4] as TSGGDrawColor).Color := FCube.FGazes[g].FColor;
	Panel.Children[1].Active := True;
	Panel.Children[5].Active := True;
	Panel.Children[6].Active := True;
	Panel.Children[7].Active := True;
	Panel.Children[11].Active := True;
	Panel.Children[9].Active := True;
	Panel.Children[4].Visible := True;
	end
else
	begin
	Panel.Children[1].Active := False;
	Panel.Children[5].Active := False;
	Panel.Children[6].Active := False;
	Panel.Children[7].Active := False;
	Panel.Children[11].Active := False;
	Panel.Children[9].Active := False;
	Panel.Children[4].Visible := False;
	end;
if (not ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0))) and ((FCube.FGazes[g].FArParents[0]<>-1) and (FCube.FGazes[g].FArParents[1]<>-1)) then
	begin
	(Panel.Children[6] as TSGComboBox).SelectItem := 0;
	Panel.Children[7].Caption := SGStr(FCube.FGazes[g].FArParents[0]+1);
	Panel.Children[8].Caption := SGStr(FCube.FGazes[g].FArParents[1]+1);
	Panel.Children[7].Active:=True;
	Panel.Children[8].Active:=True;
	end
else
	begin
	(Panel.Children[6] as TSGComboBox).SelectItem := 1;
	Panel.Children[7].Active:=False;
	Panel.Children[8].Active:=False;
	Panel.Children[7].Caption := '';
	Panel.Children[8].Caption := '';
	end;
end;end;

procedure mmmGasCBProc(b,c : LongInt;a : TSGComboBox);
begin
a.SelectItem := c;
UpdateNewGasPanel(a.Parent);
end;

procedure mmmFCloseAddNewGazButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.Parent.UserPointer) do begin
FAddNewGazPanel.Visible := False;
FAddNewGazPanel.Active := False;
FAddNewSourseButton.Active := True;
FAddNewGazButton.Active := True;
FAddSechenieButton.Active := FSecheniePanel=nil;
FDeleteSechenieButton.Active := FSecheniePanel<>nil;
end; end;

procedure mmmGas123Proc(b,c : LongInt;a : TSGComboBox);
begin with TSGGasDiffusion(a.Parent.UserPointer) do begin
a.Parent.Children[7].Active:=not Boolean(c);
a.Parent.Children[8].Active:=not Boolean(c);
a.Parent.Children[8].Caption := '';
a.Parent.Children[7].Caption := '';
(a.Parent.Children[7] as TSGEdit).TextComplite := False;
(a.Parent.Children[8] as TSGEdit).TextComplite := False;
end; end;

procedure mmmFAddAddNewGazButtonProcedure(Button:TSGButton);
var
	i : LongWord;
begin with TSGGasDiffusion(Button.Parent.UserPointer) do begin
SetLength(FCube.FGazes,Length(FCube.FGazes)+1);
FCube.FGazes[High(FCube.FGazes)].Create(random,random,random,1,-1,-1);
(Button.Parent.Children[1] as TSGComboBox).ClearItems();
for i := 0 to High(FCube.FGazes) do
	(Button.Parent.Children[1] as TSGComboBox).CreateItem('Газ №'+SGStr(i+1));
(Button.Parent.Children[1] as TSGComboBox).Active := True;
(Button.Parent.Children[1] as TSGComboBox).SelectItem := High(FCube.FGazes);
UpdateNewGasPanel(Button.Parent);
end;end;

procedure mmmGas1234Proc(Button:TSGButton);//Удаление
var
	i,ii,iii,j : LongWord;
begin with TSGGasDiffusion(Button.Parent.UserPointer) do begin
if ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
	Exit;
ii := (Button.Parent.Children[1] as TSGComboBox).SelectItem;
if Length(FCube.FGazes)<>1 then
	for i:= ii to High(FCube.FGazes)-1 do
		FCube.FGazes[i] := FCube.FGazes[i+1];
SetLength(FCube.FGazes,Length(FCube.FGazes)-1);
if Length(FCube.FGazes)=0 then
	FCube.FGazes := nil;
if ((FCube.FGazes<>nil) and (Length(FCube.FGazes)<>0)) then
	for i := 0 to High(FCube.FGazes) do
		begin
		if (FCube.FGazes[i].FArParents[0]=ii) or (FCube.FGazes[i].FArParents[1]=ii) then
			begin
			FCube.FGazes[i].FArParents[0]:=-1;
			FCube.FGazes[i].FArParents[1]:=-1;
			end
		else
			begin
			if FCube.FGazes[i].FArParents[0]>ii then
				FCube.FGazes[i].FArParents[0] -= 1;
			if FCube.FGazes[i].FArParents[1]>ii then
				FCube.FGazes[i].FArParents[1] -= 1;
			end;
		end;
for i:=0 to FCube.Edge*FCube.Edge*FCube.Edge-1 do
	if FCube.FCube[i]=ii+1 then
		FCube.FCube[i]:=0
	else if FCube.FCube[i]>ii+1 then
		FCube.FCube[i]-=1;
if ((FCube.FSourses<>nil) and (Length(FCube.FSourses)<>0)) then
	begin
	i := 0;
	while i<=High(FCube.FSourses) do
		begin
		if FCube.FSourses[i].FGazTypeIndex = ii then
			begin
			if Length(FCube.FSourses)>1 then
				for iii:=i to High(FCube.FSourses)-1 do
					FCube.FSourses[iii]:=FCube.FSourses[iii+1];
			SetLength(FCube.FSourses,Length(FCube.FSourses)-1);
			end
		else if FCube.FSourses[i].FGazTypeIndex > ii then
			begin
			FCube.FSourses[i].FGazTypeIndex -= 1;
			i +=1;
			end
		else
			i +=1;
		end;
	end;
(Button.Parent.Children[1] as TSGComboBox).ClearItems();
if ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
	begin
	(Button.Parent.Children[1] as TSGComboBox).CreateItem('Добавьте газы');
	(Button.Parent.Children[1] as TSGComboBox).SelectItem := 0;
	(Button.Parent.Children[1] as TSGComboBox).Active := False;
	end
else
	begin
	for i:=0 to High(FCube.FGazes) do
		(Button.Parent.Children[1] as TSGComboBox).CreateItem('Газ №'+SGStr(i+1));
	(Button.Parent.Children[1] as TSGComboBox).SelectItem := High(FCube.FGazes);
	end;
UpdateNewGasPanel(Button.Parent);
FMesh.Destroy();
FMesh:=FCube.CalculateMesh(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
end;end;

procedure mmmGasChangeProc(Button:TSGButton);
var
	a,b,c : LongWord;
begin with TSGGasDiffusion(Button.Parent.UserPointer) do begin
if not Boolean((Button.Parent.Children[6] as TSGComboBox).SelectItem) then
	begin
	a := SGVal(Button.Parent.Children[7].Caption);
	b := SGVal(Button.Parent.Children[8].Caption);
	if (a<>b) and (a>=1) and (a<=Length(FCube.FGazes)) and (b>=1) and (b<=Length(FCube.FGazes)) then
		begin
		c := (Button.Parent.Children[1] as TSGComboBox).SelectItem;
		FCube.FGazes[c].FArParents[0]:=a-1;
		FCube.FGazes[c].FArParents[1]:=b-1;
		end;
	end
else
	begin
	c := (Button.Parent.Children[1] as TSGComboBox).SelectItem;
	FCube.FGazes[c].FArParents[0]:=-1;
	FCube.FGazes[c].FArParents[1]:=-1;
	end;
end; end;

procedure mmmFAddNewGazButtonProcedure(Button:TSGButton);
const
	pw = 200;
	ph = 143+20;
var
	i : LongWord;
	Image:TSGImage = nil;
begin with TSGGasDiffusion(Button.UserPointer) do begin
Button.Active := False;
FAddNewSourseButton.Active := False;
FAddSechenieButton.Active := False;

if FAddNewGazPanel = nil then
	begin
	FAddNewGazPanel := TSGPanel.Create();
	SGScreen.CreateChild(FAddNewGazPanel);
	FAddNewGazPanel.SetBounds(Context.Width - pw - 10, Context.Height - ph - 10, pw, ph);
	FAddNewGazPanel.BoundsToNeedBounds();
	FAddNewGazPanel.Anchors:=[SGAnchRight,SGAnchBottom];
	FAddNewGazPanel.UserPointer := Button.UserPointer;
	FAddNewGazPanel.Visible := True;
	FAddNewGazPanel.Active := True;
	
	FAddNewGazPanel.CreateChild(TSGComboBox.Create());//1
	FAddNewGazPanel.LastChild.SetBounds(0,4,pw - 10 - 25,18);
	FAddNewGazPanel.LastChild.BoundsToNeedBounds();
	if ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
		(FAddNewGazPanel.LastChild as TSGComboBox).CreateItem('Добавьте газы')
	else
		for i:=0 to High(FCube.FGazes) do
			(FAddNewGazPanel.LastChild as TSGComboBox).CreateItem('Газ №'+SGStr(i+1));
	(FAddNewGazPanel.LastChild as TSGComboBox).SelectItem := 0;
	(FAddNewGazPanel.LastChild as TSGComboBox).FProcedure:=TSGComboBoxProcedure(@mmmGasCBProc);
	(FAddNewGazPanel.LastChild as TSGComboBox).FMaxColumns := 5;
	
	FAddNewGazPanel.CreateChild(TSGButton.Create());//2
	FAddNewGazPanel.LastChild.SetBounds(5+pw - 10 - 25+2,4,20,18);
	FAddNewGazPanel.LastChild.BoundsToNeedBounds();
	FAddNewGazPanel.LastChild.Caption:='+';
	(FAddNewGazPanel.LastChild as TSGButton).OnChange:=TSGComponentProcedure(@mmmFAddAddNewGazButtonProcedure);
	
	FAddNewGazPanel.CreateChild(TSGLabel.Create());//3
	FAddNewGazPanel.LastChild.SetBounds(0,25,50,18);
	FAddNewGazPanel.LastChild.BoundsToNeedBounds();
	FAddNewGazPanel.LastChild.Caption:='Цвет:';
	
	FAddNewGazPanel.CreateChild(TSGGDrawColor.Create());//4
	FAddNewGazPanel.LastChild.SetBounds(50,26,75,18);
	FAddNewGazPanel.LastChild.BoundsToNeedBounds();
	
	FAddNewGazPanel.CreateChild(TSGButton.Create());//5
	FAddNewGazPanel.LastChild.SetBounds(5+pw - 10 - 25+2-40,25,60,18);
	FAddNewGazPanel.LastChild.BoundsToNeedBounds();
	FAddNewGazPanel.LastChild.Caption:='Править';
	
	FAddNewGazPanel.CreateChild(TSGComboBox.Create());//6
	FAddNewGazPanel.LastChild.SetBounds(3,48,pw - 10,18);
	FAddNewGazPanel.LastChild.BoundsToNeedBounds();
	(FAddNewGazPanel.LastChild as TSGComboBox).CreateItem('Образуется при контакте');
	(FAddNewGazPanel.LastChild as TSGComboBox).CreateItem('Небудет получаться');
	(FAddNewGazPanel.LastChild as TSGComboBox).SelectItem := 0;
	(FAddNewGazPanel.LastChild as TSGComboBox).FProcedure:=TSGComboBoxProcedure(@mmmGas123Proc);
	
	FAddNewGazPanel.CreateChild(TSGEdit.Create());//7
	FAddNewGazPanel.LastChild.SetBounds(3,69,(pw div 2) - 10,18);
	FAddNewGazPanel.LastChild.BoundsToNeedBounds();
	(FAddNewGazPanel.LastChild as TSGEdit).TextType := SGEditTypeNumber;
	
	FAddNewGazPanel.CreateChild(TSGEdit.Create());//8
	FAddNewGazPanel.LastChild.SetBounds(3+(pw div 2)+3,69,(pw div 2) - 10,18);
	FAddNewGazPanel.LastChild.BoundsToNeedBounds();
	(FAddNewGazPanel.LastChild as TSGEdit).TextType := SGEditTypeNumber;
	
	FAddNewGazPanel.CreateChild(TSGButton.Create());//9
	FAddNewGazPanel.LastChild.SetBounds(3,90,pw - 10,18);
	FAddNewGazPanel.LastChild.BoundsToNeedBounds();
	FAddNewGazPanel.LastChild.Caption:='Удалить этот газ';
	(FAddNewGazPanel.LastChild as TSGButton).OnChange:=TSGComponentProcedure(@mmmGas1234Proc);
	
	FAddNewGazPanel.CreateChild(TSGButton.Create());//10
	FAddNewGazPanel.LastChild.SetBounds(3,111+21,pw - 10,18);
	FAddNewGazPanel.LastChild.BoundsToNeedBounds();
	FAddNewGazPanel.LastChild.Caption:='Закрыть это окно';
	(FAddNewGazPanel.LastChild as TSGButton).OnChange:=TSGComponentProcedure(@mmmFCloseAddNewGazButtonProcedure);
	
	FAddNewGazPanel.CreateChild(TSGButton.Create());//11
	FAddNewGazPanel.LastChild.SetBounds(3,111,pw - 10,18);
	FAddNewGazPanel.LastChild.BoundsToNeedBounds();
	FAddNewGazPanel.LastChild.Caption:='Применить';
	(FAddNewGazPanel.LastChild as TSGButton).OnChange:=TSGComponentProcedure(@mmmGasChangeProc);
	end;
FAddNewGazPanel.Visible := True;
FAddNewGazPanel.Active := True;

UpdateNewGasPanel(FAddNewGazPanel);
end; end;

procedure mmmFCloseAddNewSourseButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.Parent.UserPointer) do begin
FAddNewSoursePanel.Visible := False;
FAddNewSoursePanel.Active := False;
FAddNewSourseButton.Active := True;
FAddNewGazButton.Active := True;
FAddSechenieButton.Active := FSecheniePanel=nil;
FDeleteSechenieButton.Active := FSecheniePanel<>nil;
end; end;

procedure mmmSourseChageGasProc(b,c : LongInt;a : TSGComboBox);
var
	o,i : LongWord;
	j1,j2,j3 : LongInt;
begin with TSGGasDiffusion(a.Parent.UserPointer) do begin
if b = c then
	Exit;
a.SelectItem:=c;
i := (FAddNewSoursePanel.Children[1] as TSGComboBox).SelectItem;
o := FCube.FSourses[i].FGazTypeIndex;
FCube.FSourses[i].FGazTypeIndex := c;
for j1:=-FCube.FSourses[i].FRadius to FCube.FSourses[i].FRadius do
for j2:=-FCube.FSourses[i].FRadius to FCube.FSourses[i].FRadius do
for j3:=-FCube.FSourses[i].FRadius to FCube.FSourses[i].FRadius do
	if FCube.Cube(FCube.FSourses[i].FCoord.x+j1,FCube.FSourses[i].FCoord.y+j2,FCube.FSourses[i].FCoord.z+j3)^=o+1 then
		FCube.Cube(FCube.FSourses[i].FCoord.x+j1,FCube.FSourses[i].FCoord.y+j2,FCube.FSourses[i].FCoord.z+j3)^:=c+1;
FMesh.Destroy();
FMesh:=FCube.CalculateMesh(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
end; end;

procedure mmmSourseChageSourseProc(b,c : LongInt;a : TSGComboBox);
begin with TSGGasDiffusion(a.Parent.UserPointer) do begin
a.SelectItem:=c;
UpDateSoursePanel();
end;end;

procedure TSGGasDiffusion.UpDateSoursePanel();
var
	s : LongWord;
begin
if ((FCube.FSourses=nil) or (Length(FCube.FSourses)=0)) then
	begin
	(FAddNewSoursePanel.Children[1]).Active := False;
	(FAddNewSoursePanel.Children[3]).Active := False;
	(FAddNewSoursePanel.Children[4]).Active := False;
	(FAddNewSoursePanel.Children[5]).Active := False;
	(FAddNewSoursePanel.Children[7]).Active := False;
	(FAddNewSoursePanel.Children[3] as TSGComboBox).SelectItem := 0;
	(FAddNewSoursePanel.Children[4] as TSGEdit).Caption := '';
	if ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
		(FAddNewSoursePanel.Children[2]).Active := False;
	end
else
	begin
	(FAddNewSoursePanel.Children[1]).Active := True;
	(FAddNewSoursePanel.Children[3]).Active := True;
	(FAddNewSoursePanel.Children[4]).Active := True;
	(FAddNewSoursePanel.Children[5]).Active := True;
	(FAddNewSoursePanel.Children[7]).Active := True;
	(FAddNewSoursePanel.Children[2]).Active := True;
	s := (FAddNewSoursePanel.Children[1] as TSGComboBox).SelectItem;
	(FAddNewSoursePanel.Children[3] as TSGComboBox).SelectItem := FCube.FSourses[s].FGazTypeIndex;
	(FAddNewSoursePanel.Children[4] as TSGEdit).Caption := SGStr(FCube.FSourses[s].FRadius);
	(FAddNewSoursePanel.Children[4] as TSGEdit).TextComplite := True;
	end;
end;

procedure mmmFAddAddNewSourseButtonProcedure(Button:TSGButton);
var
	i : LongWord;
	j1,j2,j3 : LongInt;
begin with TSGGasDiffusion(Button.Parent.UserPointer) do begin 
SetLength(FCube.FSourses,Length(FCube.FSourses)+1);
FCube.FSourses[High(FCube.FSourses)].FGazTypeIndex := random(Length(FCube.FGazes));
FCube.FSourses[High(FCube.FSourses)].FCoord.Import(random(FCube.Edge-10)+5,random(FCube.Edge-10)+5,random(FCube.Edge-10)+5);
FCube.FSourses[High(FCube.FSourses)].FRadius := random(3)+1;
(Button.Parent.Children[1] as TSGComboBox).ClearItems();
for i:=0 to High(FCube.FSourses) do
	(Button.Parent.Children[1] as TSGComboBox).CreateItem('Источник №'+SGStr(i+1));
i := High(FCube.FSourses);
(Button.Parent.Children[1] as TSGComboBox).SelectItem := i;
FCube.UpDateSourses();
UpDateSoursePanel();
FMesh.Destroy();
FMesh:=FCube.CalculateMesh(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
end;end;

procedure mmmFDleteSourseAddNewSourseButtonProcedure(Button:TSGButton);
var
	s : LongInt;
	i : LongWord;
	j1,j2,j3 : LongInt;
begin with TSGGasDiffusion(Button.Parent.UserPointer) do begin 
s := (Button.Parent.Children[1] as TSGComboBox).SelectItem;

i := s;
for j1:=-FCube.FSourses[i].FRadius to FCube.FSourses[i].FRadius do
for j2:=-FCube.FSourses[i].FRadius to FCube.FSourses[i].FRadius do
for j3:=-FCube.FSourses[i].FRadius to FCube.FSourses[i].FRadius do
	if FCube.Cube(FCube.FSourses[i].FCoord.x+j1,FCube.FSourses[i].FCoord.y+j2,FCube.FSourses[i].FCoord.z+j3)^=FCube.FSourses[i].FGazTypeIndex +1 then
		FCube.Cube(FCube.FSourses[i].FCoord.x+j1,FCube.FSourses[i].FCoord.y+j2,FCube.FSourses[i].FCoord.z+j3)^:=0;

if Length(FCube.FSourses)<>1 then
	for i:=S to High(FCube.FSourses)-1 do
		FCube.FSourses[i] := FCube.FSourses[i+1];
SetLength(FCube.FSourses,Length(FCube.FSourses)-1);

(Button.Parent.Children[1] as TSGComboBox).ClearItems();
if Length(FCube.FSourses)=0 then
	begin
	(Button.Parent.Children[1] as TSGComboBox).CreateItem('Нету источников');
	end
else
	begin
	for i:=0 to High(FCube.FSourses) do
		(Button.Parent.Children[1] as TSGComboBox).CreateItem('Источник №'+SGStr(i+1));
	end;
(Button.Parent.Children[1] as TSGComboBox).SelectItem := 0;

UpDateSoursePanel();
FMesh.Destroy();
FMesh:=FCube.CalculateMesh(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
end; end;

procedure FAddNewSourseButtonProcedure(Button:TSGButton);
const
	pw = 200;
	ph = 69+21+5+21+2;
var
	i : LongWord;
begin with TSGGasDiffusion(Button.UserPointer) do begin
FAddSechenieButton.Active := False;
FAddNewSourseButton.Active:=False;
FAddNewGazButton.Active:=False;

if FAddNewSoursePanel = nil then
	begin
	FAddNewSoursePanel := TSGPanel.Create();
	SGScreen.CreateChild(FAddNewSoursePanel);
	FAddNewSoursePanel.SetBounds(Context.Width - pw - 10,Context.Height - ph - 10, pw, ph);
	FAddNewSoursePanel.BoundsToNeedBounds();
	FAddNewSoursePanel.Anchors:=[SGAnchRight,SGAnchBottom];
	FAddNewSoursePanel.UserPointer := Button.UserPointer;
	
	FAddNewSoursePanel.CreateChild(TSGComboBox.Create());//1
	FAddNewSoursePanel.LastChild.SetBounds(0,4,pw - 10 - 25,18);
	FAddNewSoursePanel.LastChild.BoundsToNeedBounds();
	if ((FCube.FSourses=nil) or (Length(FCube.FSourses)=0)) then
		(FAddNewSoursePanel.LastChild as TSGComboBox).CreateItem('Нету источников')
	else
		for i:=0 to High(FCube.FSourses) do
			(FAddNewSoursePanel.LastChild as TSGComboBox).CreateItem('Источник №'+SGStr(i+1));
	(FAddNewSoursePanel.LastChild as TSGComboBox).SelectItem := 0;
	(FAddNewSoursePanel.LastChild as TSGComboBox).FProcedure:=TSGComboBoxProcedure(@mmmSourseChageSourseProc);
	
	FAddNewSoursePanel.CreateChild(TSGButton.Create());//2
	FAddNewSoursePanel.LastChild.SetBounds(5+pw - 10 - 25+2,4,20,18);
	FAddNewSoursePanel.LastChild.BoundsToNeedBounds();
	FAddNewSoursePanel.LastChild.Caption:='+';
	(FAddNewSoursePanel.LastChild as TSGButton).OnChange:=TSGComponentProcedure(@mmmFAddAddNewSourseButtonProcedure);
	
	FAddNewSoursePanel.CreateChild(TSGComboBox.Create());//3
	FAddNewSoursePanel.LastChild.SetBounds(0,4+21,pw - 10,18);
	FAddNewSoursePanel.LastChild.BoundsToNeedBounds();
	if ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
		begin
		(FAddNewSoursePanel.LastChild as TSGComboBox).CreateItem('Добавьте газы');
		end
	else
		for i:=0 to High(FCube.FGazes) do
			(FAddNewSoursePanel.LastChild as TSGComboBox).CreateItem('Газ №'+SGStr(i+1));
	(FAddNewSoursePanel.LastChild as TSGComboBox).SelectItem := 0;
	(FAddNewSoursePanel.LastChild as TSGComboBox).FProcedure:=TSGComboBoxProcedure(@mmmSourseChageGasProc);
	
	FAddNewSoursePanel.CreateChild(TSGEdit.Create());//4
	FAddNewSoursePanel.LastChild.SetBounds(3+(pw div 2)+3,69-21,(pw div 2) - 10,18);
	FAddNewSoursePanel.LastChild.BoundsToNeedBounds();
	(FAddNewSoursePanel.LastChild as TSGEdit).TextType := SGEditTypeNumber;
	
	FAddNewSoursePanel.CreateChild(TSGLabel.Create());//5
	FAddNewSoursePanel.LastChild.SetBounds(3,69-21,(pw div 2) - 10,18);
	FAddNewSoursePanel.LastChild.BoundsToNeedBounds();
	FAddNewSoursePanel.LastChild.Caption:='Радиус:';
	
	FAddNewSoursePanel.CreateChild(TSGButton.Create());//6
	FAddNewSoursePanel.LastChild.SetBounds(3,69+21,pw - 10,18);
	FAddNewSoursePanel.LastChild.BoundsToNeedBounds();
	FAddNewSoursePanel.LastChild.Caption:='Закрыть это окно';
	(FAddNewSoursePanel.LastChild as TSGButton).OnChange:=TSGComponentProcedure(@mmmFCloseAddNewSourseButtonProcedure);
	
	FAddNewSoursePanel.CreateChild(TSGButton.Create());//7
	FAddNewSoursePanel.LastChild.SetBounds(3,69,pw - 10,18);
	FAddNewSoursePanel.LastChild.BoundsToNeedBounds();
	FAddNewSoursePanel.LastChild.Caption:='Удалить';
	(FAddNewSoursePanel.LastChild as TSGButton).OnChange:=TSGComponentProcedure(@mmmFDleteSourseAddNewSourseButtonProcedure);
	end;

FAddNewSoursePanel.Active  := True;
FAddNewSoursePanel.Visible := True;
UpDateSoursePanel();
end; end;

procedure mmmFSaveImageButtonProcedure(Button:TSGButton);
procedure PutPixel(const p : TSGPixel4b; const Destination : PByte);{$IFDEF SUPPORTINLINE}{$IFDEF SUPPORTINLINE}inline;{$ENDIF}{$ENDIF}
begin
{$IFDEF WITHLIBPNG}
	PSGPixel4b(Destination)^ := p;
{$ELSE}
	Destination[0] := trunc(p.a*p.r/255);
	Destination[1] := trunc(p.a*p.g/255);
	Destination[2] := trunc(p.a*p.b/255);
	{$ENDIF}
end;
var
	Image : TSGImage = nil;
	i, ii, d : LongWord;
	p : TSGPixel4b;
begin with TSGGasDiffusion(Button.UserPointer) do begin
if (FUsrSechPanel<>nil) and (FUsrSechPanel.Visible) then
	d := 2
else
	d := 1;
Image := TSGImage.Create();
Image.Context := Context;
Image.Image.Clear();
Image.Width          := FCube.Edge * d;
Image.Height         := FCube.Edge;
{$IFDEF WITHLIBPNG}
	Image.Image.Channels := 4;
{$ELSE}
	Image.Image.Channels := 3;
	{$ENDIF}
Image.Image.BitDepth := 8;
Image.Image.BitMap   := GetMem(FCube.Edge * FCube.Edge * Image.Image.Channels * d);
Image.Image.CreateTypes();
fillchar(Image.Image.BitMap^, FCube.Edge * FCube.Edge * Image.Image.Channels * d, 0);

for i := 0 to FCube.Edge-1 do
	for ii := 0 to FCube.Edge-1 do
		PutPixel(FSechenieImage.Image.PixelsRGBA(ii,FCube.Edge-i-1)^,@Image.Image.BitMap[(i*Image.Width+ii)*Image.Image.Channels]);

if d = 2 then
	for i := 0 to FCube.Edge-1 do
		for ii := 0 to FCube.Edge-1 do
			PutPixel(FUsrSechImage.Image.PixelsRGBA(ii,FCube.Edge-i-1)^,@Image.Image.BitMap[(i*Image.Width+ii+FCube.Edge)*Image.Image.Channels]);

SGMakeDirectory(PredStr+Catalog);
{$IFDEF WITHLIBPNG}
	Image.Way := SGGetFreeFileName(PredStr+Catalog+Slash+'Image.png','number');
	Image.Saveing(SGI_PNG);
{$ELSE}
	Image.Way := SGGetFreeFileName(PredStr+Catalog+Slash+'Image.jpg','number');
	Image.Saveing(SGI_JPEG);
	{$ENDIF}

FreeMem(Image.Image.BitMap);
Image.Image.BitMap := nil;
Image.Destroy();
end;end;

procedure mmmFAddSechSecondPanelButtonProcedure(Button:TSGButton);
var
	a : LongWord;
begin with TSGGasDiffusion(Button.UserPointer) do begin
if FUsrSechPanel = nil then
	begin
	a := (FCube.Edge+1)*2;
	FUsrSechPanel := TSGPanel.Create();
	SGScreen.CreateChild(FUsrSechPanel);
	FUsrSechPanel.SetBounds(a + 10,Context.Height - a - 10, a, a);
	FUsrSechPanel.BoundsToNeedBounds();
	FUsrSechPanel.Anchors:=[SGAnchBottom];
	FUsrSechPanel.UserPointer := Button.UserPointer;
	FUsrSechPanel.Visible := True;
	
	FUsrSechImage:=TSGImage.Create();
	FUsrSechImage.Context := Context;
	FUsrSechImage.Image.Clear();
	FUsrSechImage.Width          := FImageSechenieBounds;
	FUsrSechImage.Height         := FImageSechenieBounds;
	FUsrSechImage.Image.Channels := FSechenieImage.Image.Channels;
	FUsrSechImage.Image.BitDepth := 8;
	FUsrSechImage.Image.BitMap   := GetMem(FImageSechenieBounds*FImageSechenieBounds*FSechenieImage.Image.Channels);
	FUsrSechImage.Image.CreateTypes();
	fillchar(FUsrSechImage.Image.BitMap^,FImageSechenieBounds*FImageSechenieBounds*FSechenieImage.Image.Channels,0);
	FUsrSechImage.ToTexture();
	
	FUsrSechPanel.CreateChild(TSGPicture.Create());
	FUsrSechPanel.LastChild.SetBounds(5,5,a-10,a-10);
	FUsrSechPanel.LastChild.BoundsToNeedBounds();
	FUsrSechPanel.LastChild.Visible:=True;
	
	(FUsrSechPanel.LastChild as TSGPicture).Image       := FUsrSechImage;
	(FUsrSechPanel.LastChild as TSGPicture).EnableLines := True;
	(FUsrSechPanel.LastChild as TSGPicture).SecondPoint.Import(
		FCube.Edge/FImageSechenieBounds,
		FCube.Edge/FImageSechenieBounds);
	
	FUsrSechPanel.CreateChild(TSGProgressBar.Create());
	FUsrSechPanel.LastChild.Font := FTahomaFont;
	FUsrSechPanel.LastChild.SetBounds(
		10,FUsrSechPanel.Height div 2 - FUsrSechPanel.LastChild.Font.FontHeight div 2,
		FUsrSechPanel.Width - 30,FUsrSechPanel.LastChild.Font.FontHeight);
	FUsrSechPanel.LastChild.BoundsToNeedBounds();
	(FUsrSechPanel.Children[2] as TSGProgressBar).Visible := True;
	end;

UpDateUsrSech();
end; end;

procedure FUsrImageThreadProcedure(Klass : TSGGasDiffusion);
function InitPixel(const x,y,z : LongWord;const range : LongInt):TSGPixel4b;
var
	i, ii, iii, total, totalAlpha: LongInt;
	px, py, pz : LongInt;
	colorIndex : byte;
	color : TSGColor4f = ( r : 0; g : 0; b : 0; a : 0);
begin with Klass do begin 
total := 0;
totalAlpha := 0;
for i := -range to range do
	for ii := -range to range do
		for iii := -range to range do
			begin
			px := LongInt(x) + i;
			py := LongInt(y) + ii;
			pz := LongInt(z) + iii;
			if ((px >= 0) and (py >= 0) and (pz >= 0) and (px < FImageSechenieBounds) and ( py < FImageSechenieBounds) and ( pz < FImageSechenieBounds)) then
				begin
				colorIndex := GetPointColorCube(px,py,pz,FCubeForUsr);
				total += 1;
				if colorIndex <> 0 then
					begin
					color += FCubeForUsr.FGazes[colorIndex-1].FColor * 255;
					if (color.a>0) then
						totalAlpha += 1;
					end;
				end;
			end;
if (total = 0) then
	begin
	Result.a := 0;
	Result.r := 0;
	Result.g := 0;
	Result.b := 0;
	end
else
	begin
	Result.r := trunc(color.r/total);
	Result.g := trunc(color.g/total);
	Result.b := trunc(color.b/total);
	Result.a := 255;
	Result.RGBToAlpha();
	end;
end; end;
var
	i,ii,z,range : LongInt;
	BitMap : PByte;
begin with Klass do begin 
z := Trunc(((FPointerSecheniePlace+1)/2)*FCube.Edge);
range := FUsrRange;

i := 0;
while i < FCube.Edge do
	begin
	ii := 0;
	while ii < FCube.Edge do
		begin
		FUsrSechImageForThread.Image.PixelsRGBA(i,ii)^ := InitPixel(ii,i,z,range);
		ii += 1;
		end;
	i +=1;
	(FUsrSechPanel.Children[2] as TSGProgressBar).Progress := i/(FCube.Edge - 1);
	end;
FUpdateUsrAfterThread := True;
end; end;

procedure TSGGasDiffusion.UpDateUsrSech();
var
	BitMap : PByte = nil;
begin
if (FUsrSechThread = nil) and (not FUpdateUsrAfterThread) then
	begin
	if FUsrSechImageForThread <> nil then
		begin
		FUsrSechImageForThread.Destroy();
		FUsrSechImageForThread := nil;
		end;
	FUsrSechImageForThread:=TSGImage.Create();
	FUsrSechImageForThread.Context := Context;
	FUsrSechImageForThread.Image.Clear();
	FUsrSechImageForThread.Width          := FImageSechenieBounds;
	FUsrSechImageForThread.Height         := FImageSechenieBounds;
	FUsrSechImageForThread.Image.Channels := 4;
	FUsrSechImageForThread.Image.BitDepth := 8;
	GetMem(BitMap, FImageSechenieBounds * FImageSechenieBounds * FUsrSechImageForThread.Image.Channels);
	FUsrSechImageForThread.Image.BitMap   := BitMap;
	FUsrSechImageForThread.Image.CreateTypes();
	
	if FCubeForUsr <> nil then
		begin
		FCubeForUsr.Destroy();
		FCubeForUsr := nil;
		end;
	FCubeForUsr := FCube.Copy();
	FUsrSechThread := TSGThread.Create(TSGThreadProcedure(@FUsrImageThreadProcedure),Self);
	(FUsrSechPanel.Children[2] as TSGProgressBar).Visible := True;
	(FUsrSechPanel.Children[2] as TSGProgressBar).RealProgress := 0;
	(FUsrSechPanel.Children[2] as TSGProgressBar).Progress := 0;
	
	FAddSechSecondPanelButton.Active := False;
	end;
end;

procedure mmmFStartingThreadProcedure(Klass : TSGGasDiffusion);
begin with Klass do begin
FEnableSaving := not Boolean(FEnableOutputComboBox.SelectItem);
if FCube<>nil then
	begin
	FCube.Destroy();
	FCube:=nil;
	end;
FCube:=TSGGasDiffusionCube.Create(Context);
FCube.FRelief := @FRelief;
FCube.InitCube(SGVal(FEdgeEdit.Caption),FStartingProgressBar.GetProgressPointer());
if FMesh<>nil then
	begin
	FMesh.Destroy();
	FMesh:=nil;
	end;
FMesh := FCube.CalculateMesh(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
FNowCadr := 0;
if FEnableSaving then
	SGMakeDirectory(PredStr+Catalog);
FStartingFlag := 2;
end; end;

procedure mmmPostInitCubeProcedure(Klass : TSGGasDiffusion);
const
	W = 200;
var
	i : LongWord;
begin with Klass do begin
FEdgeEdit .Active := True;
FEnableLoadButton .Active := True;
FEnableOutputComboBox.Active := True;
FBoundsTypeButton.Active := True;
FStartSceneButton.Active := True;

FStartingProgressBar.Visible := False;

FNewScenePanel.Visible := False;
if FBackToMenuButton = nil then
	begin
	FBackToMenuButton:=TSGButton.Create();
	SGScreen.CreateChild(FBackToMenuButton);
	SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+(FTahomaFont.FontHeight+6)*0,W,FTahomaFont.FontHeight+2);
	SGScreen.LastChild.BoundsToNeedBounds();
	SGScreen.LastChild.AutoTopShift:=True;
	SGScreen.LastChild.Anchors:=[SGAnchRight];
	SGScreen.LastChild.Visible := True;
	SGScreen.LastChild.Active  := True;
	SGScreen.LastChild.Font    := FTahomaFont;
	SGScreen.LastChild.Caption :='В главное меню';
	SGScreen.LastChild.UserPointer:=Klass;
	FBackToMenuButton.OnChange:=TSGComponentProcedure(@mmmFBackToMenuButtonProcedure);
	end
else
	begin
	FBackToMenuButton.Visible := True;
	FBackToMenuButton.Active  := True;
	end;

if FAddNewGazButton=nil then
	begin
	FAddNewGazButton:=TSGButton.Create();
	SGScreen.CreateChild(FAddNewGazButton);
	SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+(FTahomaFont.FontHeight+6)*1,W,FTahomaFont.FontHeight+2);
	SGScreen.LastChild.BoundsToNeedBounds();
	SGScreen.LastChild.AutoTopShift:=True;
	SGScreen.LastChild.Anchors:=[SGAnchRight];
	SGScreen.LastChild.Visible:=True;
	FAddNewGazButton.Active  := True;
	SGScreen.LastChild.Font := FTahomaFont;
	SGScreen.LastChild.Caption:='Править типы газа';
	SGScreen.LastChild.UserPointer:=Klass;
	FAddNewGazButton.OnChange:=TSGComponentProcedure(@mmmFAddNewGazButtonProcedure);
	end
else
	begin
	FAddNewGazButton.Visible := True;
	FAddNewGazButton.Active  := True;
	end;

if FAddNewSourseButton = nil then
	begin
	FAddNewSourseButton:=TSGButton.Create();
	SGScreen.CreateChild(FAddNewSourseButton);
	SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+(FTahomaFont.FontHeight+6)*2,W,FTahomaFont.FontHeight+2);
	SGScreen.LastChild.BoundsToNeedBounds();
	SGScreen.LastChild.AutoTopShift:=True;
	SGScreen.LastChild.Anchors:=[SGAnchRight];
	SGScreen.LastChild.Visible:=True;
	FAddNewSourseButton.Active  := True;
	SGScreen.LastChild.Font := FTahomaFont;
	SGScreen.LastChild.Caption:='Править източники газа';
	SGScreen.LastChild.UserPointer:=Klass;
	FAddNewSourseButton.OnChange:=TSGComponentProcedure(@FAddNewSourseButtonProcedure);
	end
else
	begin
	FAddNewSourseButton.Visible := True;
	FAddNewSourseButton.Active  := True;
	end;

if FStartEmulatingButton=nil then
	begin
	FStartEmulatingButton:=TSGButton.Create();
	SGScreen.CreateChild(FStartEmulatingButton);
	SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+(FTahomaFont.FontHeight+6)*3,W,FTahomaFont.FontHeight+2);
	SGScreen.LastChild.BoundsToNeedBounds();
	SGScreen.LastChild.AutoTopShift:=True;
	SGScreen.LastChild.Anchors:=[SGAnchRight];
	SGScreen.LastChild.Visible:=True;
	FStartEmulatingButton.Active  := True;
	SGScreen.LastChild.Font := FTahomaFont;
	SGScreen.LastChild.Caption:='Эмурировать';
	SGScreen.LastChild.UserPointer:=Klass;
	FStartEmulatingButton.OnChange:=TSGComponentProcedure(@mmmFRunDiffusionButtonProcedure);
	end
else
	begin
	FStartEmulatingButton.Visible := True;
	FStartEmulatingButton.Active  := True;
	end;

if FPauseEmulatingButton = nil then
	begin
	FPauseEmulatingButton:=TSGButton.Create();
	SGScreen.CreateChild(FPauseEmulatingButton);
	SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+(FTahomaFont.FontHeight+6)*4,W,FTahomaFont.FontHeight+2);
	SGScreen.LastChild.BoundsToNeedBounds();
	SGScreen.LastChild.AutoTopShift:=True;
	SGScreen.LastChild.Anchors:=[SGAnchRight];
	SGScreen.LastChild.Visible:=True;
	SGScreen.LastChild.Active :=False;
	SGScreen.LastChild.Font := FTahomaFont;
	SGScreen.LastChild.Caption:='Приостановить эмуляцию';
	SGScreen.LastChild.UserPointer:=Klass;
	FPauseEmulatingButton.OnChange:=TSGComponentProcedure(@mmmFPauseDiffusionButtonProcedure);
	end
else
	begin
	FPauseEmulatingButton.Visible := True;
	FPauseEmulatingButton.Active  := False;
	end;

if FStopEmulatingButton = nil then
	begin
	FStopEmulatingButton:=TSGButton.Create();
	SGScreen.CreateChild(FStopEmulatingButton);
	SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+(FTahomaFont.FontHeight+6)*5,W,FTahomaFont.FontHeight+2);
	SGScreen.LastChild.BoundsToNeedBounds();
	SGScreen.LastChild.AutoTopShift:=True;
	SGScreen.LastChild.Anchors:=[SGAnchRight];
	SGScreen.LastChild.Visible:=True;
	SGScreen.LastChild.Active :=False;
	SGScreen.LastChild.Font := FTahomaFont;
	SGScreen.LastChild.Caption:='Ocтановить эмуляцию';
	SGScreen.LastChild.UserPointer:=Klass;
	FStopEmulatingButton.OnChange:=TSGComponentProcedure(@mmmFStopDiffusionButtonProcedure);
	end
else
	begin
	FStopEmulatingButton.Visible := True;
	FStopEmulatingButton.Active  := False;
	end;

if FAddSechenieButton = nil then 
	begin
	FAddSechenieButton:=TSGButton.Create();
	SGScreen.CreateChild(FAddSechenieButton);
	SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+(FTahomaFont.FontHeight+6)*6,W,FTahomaFont.FontHeight+2);
	SGScreen.LastChild.BoundsToNeedBounds();
	SGScreen.LastChild.AutoTopShift:=True;
	SGScreen.LastChild.Anchors:=[SGAnchRight];
	SGScreen.LastChild.Visible:=True;
	SGScreen.LastChild.Active :=True;
	SGScreen.LastChild.Font := FTahomaFont;
	SGScreen.LastChild.Caption:='Рассмотреть сечение';
	SGScreen.LastChild.UserPointer:=Klass;
	FAddSechenieButton.OnChange:=TSGComponentProcedure(@mmmFAddSechenieButtonProcedure);
	end
else
	begin
	FAddSechenieButton.Visible := True;
	FAddSechenieButton.Active  := True;
	end;

if FDeleteSechenieButton = nil then
	begin
	FDeleteSechenieButton:=TSGButton.Create();
	SGScreen.CreateChild(FDeleteSechenieButton);
	SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+(FTahomaFont.FontHeight+6)*7,W,FTahomaFont.FontHeight+2);
	SGScreen.LastChild.BoundsToNeedBounds();
	SGScreen.LastChild.AutoTopShift:=True;
	SGScreen.LastChild.Anchors:=[SGAnchRight];
	SGScreen.LastChild.Visible:=True;
	SGScreen.LastChild.Active :=False;
	SGScreen.LastChild.Font := FTahomaFont;
	SGScreen.LastChild.Caption:='Не рассмотривать сечение';
	SGScreen.LastChild.UserPointer:=Klass;
	FDeleteSechenieButton.OnChange:=TSGComponentProcedure(@mmmFDeleteSechenieButtonProcedure);
	end
else
	begin
	FDeleteSechenieButton.Visible := True;
	FDeleteSechenieButton.Active  := False;
	end;

if FAddSechSecondPanelButton = nil then
	begin
	FAddSechSecondPanelButton:=TSGButton.Create();
	SGScreen.CreateChild(FAddSechSecondPanelButton);
	SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+(FTahomaFont.FontHeight+6)*8,W,FTahomaFont.FontHeight+2);
	SGScreen.LastChild.BoundsToNeedBounds();
	SGScreen.LastChild.AutoTopShift:=True;
	SGScreen.LastChild.Anchors:=[SGAnchRight];
	SGScreen.LastChild.Visible:=True;
	SGScreen.LastChild.Active :=False;
	SGScreen.LastChild.Font := FTahomaFont;
	SGScreen.LastChild.Caption:='Вычисление концентрации';
	SGScreen.LastChild.UserPointer:=Klass;
	FAddSechSecondPanelButton.OnChange:=TSGComponentProcedure(@mmmFAddSechSecondPanelButtonProcedure);
	end
else
	begin
	FAddSechSecondPanelButton.Visible := True;
	FAddSechSecondPanelButton.Active  := False;
	end;

if FSaveImageButton = nil then
	begin
	FSaveImageButton:=TSGButton.Create();
	SGScreen.CreateChild(FSaveImageButton);
	SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+(FTahomaFont.FontHeight+6)*9,W,FTahomaFont.FontHeight+2);
	SGScreen.LastChild.BoundsToNeedBounds();
	SGScreen.LastChild.AutoTopShift:=True;
	SGScreen.LastChild.Anchors:=[SGAnchRight];
	SGScreen.LastChild.Visible:=True;
	SGScreen.LastChild.Active :=False;
	SGScreen.LastChild.Font := FTahomaFont;
	SGScreen.LastChild.Caption:='Сoхранить картинку';
	SGScreen.LastChild.UserPointer:=Klass;
	FSaveImageButton.OnChange:=TSGComponentProcedure(@mmmFSaveImageButtonProcedure);
	end
else
	begin
	FSaveImageButton.Visible := True;
	FSaveImageButton.Active  := False;
	end;
end;end;

procedure mmmFStartSceneButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FStartingFlag := 1;
	FStartingThread := TSGThread.Create(TSGThreadProcedure(@mmmFStartingThreadProcedure),Button.UserPointer,True);
	FStartingProgressBar.Visible := True;
	FStartingProgressBar.RealProgress := 0;
	FStartingProgressBar.Progress := 0;
	FStartSceneButton.Active := False;
	FLoadButton.Active := False;
	
	FEdgeEdit .Active := False;
	FEnableLoadButton .Active := False;
	FEnableOutputComboBox.Active := False;
	FBoundsTypeButton.Active := False;
	end;
end;

procedure mmmFUpdateButtonProcedure(Button : TSGButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	UpDateSavesComboBox();
end;end;

procedure mmmFMovieBackToMenuButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FMoviePlayed := False;
	FMovieBackToMenuButton.Visible:=False;
	FMoviePauseButton.Visible:=False;
	FMoviePlayButton.Visible:=False;
	FLoadScenePanel.Visible := True;
	FInfoLabel.Caption:='';
	if FMesh<>nil then
		begin
		FMesh.Destroy();
		FMesh:=nil;
		end;
	if FArCadrs<>nil then
		begin
		SetLength(FArCadrs,0);
		FArCadrs:=nil;
		end;
	if FFileStream<>nil then
		begin
		FFileStream.Destroy();
		FFileStream:=nil;
		end;
end;end;

procedure mmmFMoviePauseButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FMoviePlayed := False;
	FMoviePauseButton.Active := False;
	FMoviePlayButton.Active := True;
end;end;

procedure mmmFMoviePlayButtonProcedure(Button:TSGButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FMoviePlayed := True;
	FMoviePauseButton.Active := True;
	FMoviePlayButton.Active := False;
end;end;

procedure mmmFLoadButtonProcedure(Button:TSGButton);
procedure ReadCadrs();
begin with TSGGasDiffusion(Button.UserPointer) do begin
FFileStream.Position := 0;
SetLength(FArCadrs,0);
while FFileStream.Position<>FFileStream.Size do
	begin
	SetLength(FArCadrs,Length(FArCadrs)+1);
	FArCadrs[High(FArCadrs)]:=FFileStream.Position;
	
	FMesh:=TSGCustomModel.Create();
	FMesh.Context := Context;
	FMesh.LoadFromSG3DM(FFileStream);
	FMesh.Destroy();
	FMesh:=nil;
	end;
FFileStream.Position := 0;
end; end;
const
	W = 200;
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FLoadScenePanel.Visible := False;
	FFileName := FLoadComboBox.Items(FLoadComboBox.SelectItem);
	FFileName := PredStr+Catalog+Slash+FFileName;
	FFileStream := TFileStream.Create(FFileName,fmOpenRead);
	FEnableSaving := False;
	ReadCadrs();
	FNowCadr:=0;
	FMoviePlayed:=True;
	
	FMesh:=TSGCustomModel.Create();
	FMesh.Context := Context;
	FFileStream.Position:=FArCadrs[FNowCadr];
	FMesh.LoadFromSG3DM(FFileStream);
	
	if FMovieBackToMenuButton = nil then
		begin
		FMovieBackToMenuButton:=TSGButton.Create();
		SGScreen.CreateChild(FMovieBackToMenuButton);
		SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+(FTahomaFont.FontHeight+6)*0,W,FTahomaFont.FontHeight+2);
		SGScreen.LastChild.BoundsToNeedBounds();
		SGScreen.LastChild.AutoTopShift:=True;
		SGScreen.LastChild.Anchors:=[SGAnchRight];
		SGScreen.LastChild.Visible := True;
		SGScreen.LastChild.Active  := True;
		SGScreen.LastChild.Font    := FTahomaFont;
		SGScreen.LastChild.Caption :='В меню загрузок';
		SGScreen.LastChild.UserPointer:=Button.UserPointer;
		FMovieBackToMenuButton.OnChange:=TSGComponentProcedure(@mmmFMovieBackToMenuButtonProcedure);
		end
	else
		begin
		FMovieBackToMenuButton.Visible := True;
		FMovieBackToMenuButton.Active  := True;
		end;
	
	if FMoviePlayButton = nil then
		begin
		FMoviePlayButton:=TSGButton.Create();
		SGScreen.CreateChild(FMoviePlayButton);
		SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+(FTahomaFont.FontHeight+6)*1,W,FTahomaFont.FontHeight+2);
		SGScreen.LastChild.BoundsToNeedBounds();
		SGScreen.LastChild.AutoTopShift:=True;
		SGScreen.LastChild.Anchors:=[SGAnchRight];
		SGScreen.LastChild.Visible := True;
		SGScreen.LastChild.Active  := False;
		SGScreen.LastChild.Font    := FTahomaFont;
		SGScreen.LastChild.Caption :='Воспроизведение';
		SGScreen.LastChild.UserPointer:=Button.UserPointer;
		FMoviePlayButton.OnChange:=TSGComponentProcedure(@mmmFMoviePlayButtonProcedure);
		end
	else
		begin
		FMoviePlayButton.Visible := True;
		FMoviePlayButton.Active  := False;
		end;
	if FMoviePauseButton = nil then
		begin
		FMoviePauseButton:=TSGButton.Create();
		SGScreen.CreateChild(FMoviePauseButton);
		SGScreen.LastChild.SetBounds(SGScreen.Width-W-10,5+(FTahomaFont.FontHeight+6)*2,W,FTahomaFont.FontHeight+2);
		SGScreen.LastChild.BoundsToNeedBounds();
		SGScreen.LastChild.AutoTopShift:=True;
		SGScreen.LastChild.Anchors:=[SGAnchRight];
		SGScreen.LastChild.Visible := True;
		SGScreen.LastChild.Active  := True;
		SGScreen.LastChild.Font    := FTahomaFont;
		SGScreen.LastChild.Caption :='Пауза';
		SGScreen.LastChild.UserPointer:=Button.UserPointer;
		FMoviePauseButton.OnChange:=TSGComponentProcedure(@mmmFMoviePauseButtonProcedure);
		end
	else
		begin
		FMoviePauseButton.Visible := True;
		FMoviePauseButton.Active  := True;
		end;
end;end;
procedure mmmFEnableLoadButtonProcedure(Button:TSGButton);
begin
with TSGGasDiffusion(Button.UserPointer) do
	begin
	FLoadScenePanel.Visible := True;
	FNewScenePanel .Visible := False;
	UpDateSavesComboBox();
	end;
end;
// =====================================================================
// =====================================================================
// =====================================================================
procedure mmmFRedactrReliefOpenFileButton(Button:TSGButton);
var
	FileWay : String = '';
	IsInFullscreen : Boolean = False;
begin with TSGGasDiffusion(Button.UserPointer) do begin
IsInFullscreen := Context.Fullscreen;
if IsInFullscreen then
	begin
	Context.Fullscreen := False;
	Context.Messages(); //Обязательно 3 раза, иначе hWindow не обновляется
	Context.Messages();
	Context.Messages();
	end;
FileWay := Context.FileOpenDlg('Выберите файл рельефа','Файлы рельефа(*.sggdrf)'+#0+'*.sggdrf'+#0+'All files(*.*)'+#0+'*.*'+#0+#0);
if (FileWay <> '') and (SGFileExists(FileWay)) then
	begin
	FRelefRedactor.SingleRelief^.Clear();
	FRelefRedactor.SingleRelief^.Load(FileWay);
	FRelefOptionPanel.Children[1].Caption := 'Статус рельефа:Загружен('+SGGetFileName(FileWay)+'.'+SGDownCaseString(SGGetFileExpansion(FileWay))+')';
	(FRelefOptionPanel.Children[1] as TSGLabel).TextColor := SGColorImport(0,1,0,1);
	end;
if IsInFullscreen then
	Context.Fullscreen := True;
end; end;
procedure mmmFRedactrReliefSaveFileButton(Button:TSGButton);
var
	FileWay : String = '';
	IsInFullscreen : Boolean = False;
begin with TSGGasDiffusion(Button.UserPointer) do begin
IsInFullscreen := Context.Fullscreen;
if IsInFullscreen then
	begin
	Context.Fullscreen := False;
	Context.Messages(); //Обязательно 3 раза, иначе hWindow не обновляется
	Context.Messages();
	Context.Messages();
	end;
FileWay := Context.FileSaveDlg('Выберите имя файла для сохранения рельефа','Файлы рельефа(*.sggdrf)'+#0+'*.sggdrf'+#0+'All files(*.*)'+#0+'*.*'+#0+#0,'sggdrf');
WriteLn('FileWay=',FileWay);
if (FileWay <> '') then
	begin
	FRelefRedactor.SingleRelief^.Save(FileWay);
	end;
if IsInFullscreen then
	Context.Fullscreen := True;
end; end;
procedure mmmFRedactrReliefBackButton(Button:TSGButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
FRelefRedactor.SetActiveSingleRelief();
FRelefOptionPanel.AddToLeft  (((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width) div 2) + 5);
FRelefOptionPanel.Visible := False;
FBoundsOptionsPanel.Active := True;
FNewScenePanel.AddToLeft     (((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width) div 2) + 5);
FBoundsOptionsPanel.AddToLeft(((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width) div 2) + 5);
end;end;

procedure mmmFRedactorBackButton(Button:TSGButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
Button.Visible := False;
Button.Active := False;
if FRelefOptionPanel <> nil then
	begin
	FRelefOptionPanel.Children[1].Caption := 'Статус рельефа:теоритически изменен';
	(FRelefOptionPanel.Children[1] as TSGLabel).TextColor := SGColorImport(0,1,0,1);
	end;
if FRelefRedactor <> nil then
	FRelefRedactor.StopRedactoring();
if FRelefOptionPanel <> nil then
	begin
	FRelefOptionPanel.Visible := True;
	FRelefOptionPanel.AddToTop(-300);
	end;
if FBoundsOptionsPanel <> nil then
	begin
	FBoundsOptionsPanel.Visible := True;
	FBoundsOptionsPanel.AddToTop(-300);
	end;
if FNewScenePanel <> nil then
	begin
	FNewScenePanel.Visible := True;
	FNewScenePanel.AddToTop(-300);
	end;
end; end;

procedure mmmFRedactrReliefRedactrReliefButton(Button:TSGButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
FRedactorBackButton.Visible := True;
FRedactorBackButton.Active := True;
if FRelefRedactor <> nil then
	FRelefRedactor.StartRedactoring();
if FRelefOptionPanel <> nil then
	begin
	FRelefOptionPanel.Visible := False;
	FRelefOptionPanel.AddToTop(300);
	end;
if FBoundsOptionsPanel <> nil then
	begin
	FBoundsOptionsPanel.Visible := False;
	FBoundsOptionsPanel.AddToTop(300);
	end;
if FNewScenePanel <> nil then
	begin
	FNewScenePanel.Visible := False;
	FNewScenePanel.AddToTop(300);
	end;
end; end;

procedure mmmFRedactrRelief(Button:TSGButton);
var
	FConstWidth : LongWOrd = 300;
begin with TSGGasDiffusion(Button.UserPointer) do begin
FRelefRedactor.SetActiveSingleRelief(Button.Parent.IndexOf(Button) - 6);
if (FRelefOptionPanel = nil) then
	begin
	FRelefOptionPanel := TSGPanel.Create();
	SGScreen.CreateChild(FRelefOptionPanel);
	SGScreen.LastChild.SetMiddleBounds(FConstWidth,155);
	SGScreen.LastChild.BoundsToNeedBounds();
	FRelefOptionPanel.AddToLeft(((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width)div 2) + 5);
	FRelefOptionPanel.AddToTop(285);
	SGScreen.LastChild.BoundsToNeedBounds();
	FRelefOptionPanel.AddToLeft(- ((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width)div 2) - 5);
	SGScreen.LastChild.UserPointer:=Button.UserPointer;
	SGScreen.LastChild.Visible:=True;
	SGScreen.LastChild.VisibleTimer := 0.3;
	
	FRelefOptionPanel.CreateChild(TSGLabel.Create());
	FRelefOptionPanel.LastChild.Caption := 'Статус рельефа:Неопределен';
	FRelefOptionPanel.LastChild.Visible := True;
	FRelefOptionPanel.LastChild.SetBounds(10,10,FRelefOptionPanel.Width - 30,19);
	FRelefOptionPanel.LastChild.Font := FTahomaFont;
	FRelefOptionPanel.LastChild.UserPointer := Button.UserPointer;
	
	FRelefOptionPanel.CreateChild(TSGButton.Create());
	FRelefOptionPanel.LastChild.Caption := 'Загрузить рельеф из файла';
	FRelefOptionPanel.LastChild.Visible := True;
	FRelefOptionPanel.LastChild.SetBounds(10,10+(19+5)*1,FRelefOptionPanel.Width - 30,19);
	FRelefOptionPanel.LastChild.Font := FTahomaFont;
	FRelefOptionPanel.LastChild.UserPointer := Button.UserPointer;
	(FRelefOptionPanel.LastChild as TSGButton).OnChange := TSGComponentProcedure(@mmmFRedactrReliefOpenFileButton);
	
	FRelefOptionPanel.CreateChild(TSGButton.Create());
	FRelefOptionPanel.LastChild.Caption := 'Сохранить рельеф в файл';
	FRelefOptionPanel.LastChild.Visible := True;
	FRelefOptionPanel.LastChild.SetBounds(10,10+(19+5)*2,FRelefOptionPanel.Width - 30,19);
	FRelefOptionPanel.LastChild.Font := FTahomaFont;
	FRelefOptionPanel.LastChild.UserPointer := Button.UserPointer;
	(FRelefOptionPanel.LastChild as TSGButton).OnChange := TSGComponentProcedure(@mmmFRedactrReliefSaveFileButton);
	
	FRelefOptionPanel.CreateChild(TSGButton.Create());
	FRelefOptionPanel.LastChild.Caption := 'Редактировать рельеф';
	FRelefOptionPanel.LastChild.Visible := True;
	FRelefOptionPanel.LastChild.SetBounds(10,10+(19+5)*3,FRelefOptionPanel.Width - 30,19);
	FRelefOptionPanel.LastChild.Font := FTahomaFont;
	FRelefOptionPanel.LastChild.UserPointer := Button.UserPointer;
	(FRelefOptionPanel.LastChild as TSGButton).OnChange := TSGComponentProcedure(@mmmFRedactrReliefRedactrReliefButton);
	FRelefOptionPanel.LastChild.Active := {$IFDEF MOBILE}False{$ELSE}True{$ENDIF};
	
	FRelefOptionPanel.CreateChild(TSGButton.Create());
	FRelefOptionPanel.LastChild.Caption := 'Назад';
	FRelefOptionPanel.LastChild.Visible := True;
	FRelefOptionPanel.LastChild.SetBounds(10,10+(19+5)*4,FRelefOptionPanel.Width - 30,19);
	FRelefOptionPanel.LastChild.Font := FTahomaFont;
	FRelefOptionPanel.LastChild.UserPointer := Button.UserPointer;
	(FRelefOptionPanel.LastChild as TSGButton).OnChange := TSGComponentProcedure(@mmmFRedactrReliefBackButton);
	end
else
	begin
	FRelefOptionPanel.Visible := True;
	FRelefOptionPanel.Active := True;
	FRelefOptionPanel.AddToLeft(- ((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width)div 2) - 5);
	FRelefOptionPanel.VisibleTimer := 0.3;
	end;
(FRelefOptionPanel.Children[1] as TSGLabel).TextColor := SGColorImport(1,0,0,1);
FNewScenePanel.AddToLeft(- ((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width)div 2) - 5);
FBoundsOptionsPanel.AddToLeft(- ((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width)div 2) - 5);
FBoundsOptionsPanel.Active := False;
end; end;
procedure mmmChangeBoundTypeComboBoxProcedure(b,c : LongInt;a : TSGComboBox);
var
	index : LongInt;
begin with TSGGasDiffusion(a.UserPointer) do begin
index := a.Parent.IndexOf(a);
if index <> -1 then
	begin
	(a.Parent.Children[index + 7] as TSGButton).Active := c > 0;
	FRelief.FData[index].FEnabled := c > 0;
	FRelief.FData[index].FType := c > 1
	end;
end; end;
procedure mmmFBoundsBackButtonProcedure(Button:TSGButton);
const
	FConstHeight : LongWord = 280;
begin with TSGGasDiffusion(Button.UserPointer) do begin
FNewScenePanel.AddToLeft(((FNewScenePanel.Width + FBoundsOptionsPanel.Width)div 2) + 5);
FNewScenePanel.Active := True;
FNewScenePanel.AddToTop( - FConstHeight - 5);
FBoundsOptionsPanel.AddToLeft(((FNewScenePanel.Width + FBoundsOptionsPanel.Width)div 2) + 5);
FBoundsOptionsPanel.Active := False;
FBoundsOptionsPanel.Visible := False;
FBoundsOptionsPanel.VisibleTimer := 0.7;
FBoundsOptionsPanel.DrawClass := nil;
end; end;

procedure mmmFBoundsTypeButtonProcedure(Button:TSGButton);
var
	FConstWidth : LongWord = 500;
	FConstLoadMeshButtonWidth : LongWord = 120;
	FConstLabelsWidth : LongWOrd = 90;

procedure CreteCOmboBox(const vIndex : LongWord; const vPanel : TSGPanel);
begin with TSGGasDiffusion(Button.UserPointer) do begin
FBoundsOptionsPanel.CreateChild(TSGComboBox.Create());
FBoundsOptionsPanel.LastChild.SetBounds(10 + FConstLabelsWidth + 10,5+(19+5)*vIndex,FConstWidth-50-FConstLoadMeshButtonWidth - FConstLabelsWidth,19);
FBoundsOptionsPanel.LastChild.Visible:=True;
FBoundsOptionsPanel.LastChild.BoundsToNeedBounds();
FBoundsOptionsPanel.LastChild.Font := FTahomaFont;
(FBoundsOptionsPanel.LastChild as TSGComboBox).CreateItem('Стенкa пропускают газ');
(FBoundsOptionsPanel.LastChild as TSGComboBox).CreateItem('Стенкa не пропускают газ');
(FBoundsOptionsPanel.LastChild as TSGComboBox).CreateItem('Газ липнет к стенкe');
(FBoundsOptionsPanel.LastChild as TSGComboBox).FProcedure:=TSGComboBoxProcedure(@mmmChangeBoundTypeComboBoxProcedure);
(FBoundsOptionsPanel.LastChild as TSGComboBox).SelectItem:=0;
FBoundsOptionsPanel.LastChild.UserPointer:=Button.UserPointer;
end;end;
procedure CreteLabel(const vIndex : LongWord; const vPanel : TSGPanel);
begin with TSGGasDiffusion(Button.UserPointer) do begin
FBoundsOptionsPanel.CreateChild(TSGLabel.Create());
FBoundsOptionsPanel.LastChild.SetBounds(10 ,5+(19+5)*vIndex,FConstLabelsWidth,19);
FBoundsOptionsPanel.LastChild.Visible:=True;
FBoundsOptionsPanel.LastChild.BoundsToNeedBounds();
FBoundsOptionsPanel.LastChild.Font := FTahomaFont;
FBoundsOptionsPanel.LastChild.UserPointer:=Button.UserPointer;
case vIndex of
0 : FBoundsOptionsPanel.LastChild.Caption := 'Верхняя';
1 : FBoundsOptionsPanel.LastChild.Caption := 'Нижня';
2 : FBoundsOptionsPanel.LastChild.Caption := 'Левая';
3 : FBoundsOptionsPanel.LastChild.Caption := 'Правая';
4 : FBoundsOptionsPanel.LastChild.Caption := 'Задняя';
5 : FBoundsOptionsPanel.LastChild.Caption := 'Передняя';
end;
end;end;
procedure CreteLoadMeshButton(const vIndex : LongWord; const vPanel : TSGPanel);
begin with TSGGasDiffusion(Button.UserPointer) do begin
FBoundsOptionsPanel.CreateChild(TSGButton.Create());
FBoundsOptionsPanel.LastChild.SetBounds(FConstWidth - 20 - FConstLoadMeshButtonWidth,5+(19+5)*vIndex,FConstLoadMeshButtonWidth,19);
FBoundsOptionsPanel.LastChild.Visible:=True;
FBoundsOptionsPanel.LastChild.Active := False;
FBoundsOptionsPanel.LastChild.BoundsToNeedBounds();
FBoundsOptionsPanel.LastChild.Font := FTahomaFont;
FBoundsOptionsPanel.LastChild.UserPointer:=Button.UserPointer;
FBoundsOptionsPanel.LastChild.Caption := 'Настроить рельеф';
(FBoundsOptionsPanel.LastChild as TSGButton).OnChange := TSGComponentProcedure(@mmmFRedactrRelief);
end;end;
const
	FConstHeight : LongWord = 280;
var
	i : LongWord;
begin with TSGGasDiffusion(Button.UserPointer) do begin
FNewScenePanel.AddToLeft(- ((FNewScenePanel.Width + FConstWidth)div 2) - 5);
FNewScenePanel.AddToTop(FConstHeight + 5);
FNewScenePanel.Active := False;
if FBoundsOptionsPanel = nil then
	begin
	FBoundsOptionsPanel:=TSGPanel.Create();
	SGScreen.CreateChild(FBoundsOptionsPanel);
	SGScreen.LastChild.SetMiddleBounds(FConstWidth,185);
	SGScreen.LastChild.BoundsToNeedBounds();
	FBoundsOptionsPanel.AddToLeft( FConstWidth + 5);
	FBoundsOptionsPanel.AddToTop( FConstHeight + 5);
	SGScreen.LastChild.BoundsToNeedBounds();
	FBoundsOptionsPanel.AddToLeft(- FConstWidth - 5);
	SGScreen.LastChild.UserPointer:=Button.UserPointer;
	SGScreen.LastChild.Visible:=True;
	SGScreen.LastChild.VisibleTimer := 0.3;
	
	for i := 0 to 5 do
		CreteCOmboBox(i,FBoundsOptionsPanel);
	for i := 0 to 5 do
		CreteLoadMeshButton(i,FBoundsOptionsPanel);
	for i := 0 to 5 do
		CreteLabel(i,FBoundsOptionsPanel);
	
	FBoundsOptionsPanel.CreateChild(TSGButton.Create());
	FBoundsOptionsPanel.LastChild.SetBounds((FConstWidth - FConstLoadMeshButtonWidth )div 2,149,FConstLoadMeshButtonWidth,19);
	FBoundsOptionsPanel.LastChild.Visible:=True;
	FBoundsOptionsPanel.LastChild.Active := True;
	FBoundsOptionsPanel.LastChild.BoundsToNeedBounds();
	FBoundsOptionsPanel.LastChild.Font := FTahomaFont;
	FBoundsOptionsPanel.LastChild.UserPointer:=Button.UserPointer;
	FBoundsOptionsPanel.LastChild.Caption := 'Назад';
	(FBoundsOptionsPanel.LastChild as TSGButton).OnChange := TSGComponentProcedure(@mmmFBoundsBackButtonProcedure);
	end
else
	begin
	FBoundsOptionsPanel.Visible := True;
	FBoundsOptionsPanel.Active := True;
	FBoundsOptionsPanel.AddToLeft(- ((FNewScenePanel.Width + FBoundsOptionsPanel.Width)div 2) - 5);
	FBoundsOptionsPanel.VisibleTimer := 0.3;
	end;
FBoundsOptionsPanel.DrawClass := FRelefRedactor;

end; end;
procedure mmmFBackButtonProcedure(Button:TSGButton);
begin
with TSGGasDiffusion(Button.UserPointer) do
	begin
	FLoadScenePanel.Visible := False;
	FNewScenePanel .Visible := True;
	end;
end;
procedure mmmFOpenSaveDir(Button:TSGButton);
begin
{$IFDEF MSWINDOWS}
	Exec('explorer.exe','"'+PredStr+Catalog+'"');
	{$ENDIF}
end;

function mmmFEdgeEditTextTypeFunction(const Self:TSGEdit):TSGBoolean;
var
	i : TSGQuadWord;
begin
Result := TSGEditTextTypeFunctionNumber(Self);
with TSGGasDiffusion(Self.UserPointer) do
	begin
	if Result then
		begin
		i := SGVal(Self.Caption);
		if (i > 999999) or (i=0) then
			begin
			TSGGasDiffusion(Self.UserPointer).FNumberLabel.Caption:='^3= ...';
			Result:=False;
			end
		else
			TSGGasDiffusion(Self.UserPointer).FNumberLabel.Caption:='^3='+SGStr(i*i*i);
		end
	else
		begin
		TSGGasDiffusion(Self.UserPointer).FNumberLabel.Caption:='^3= ...';
		end;
	FStartSceneButton.Active := Result;
	end;
end;

procedure TSGGasDiffusion.UpDateSavesComboBox();
var
	ar : TArString = nil;
	i : TSGLongWord;
	ExC : Boolean = False;
begin
FLoadComboBox.ClearItems();
ar := SGGetFileNames(PredStr+Catalog+'/','*.GDS');
if ar <> nil then
	begin
	for i:=0 to High(ar) do
		if (ar[i]<>'.') and (ar[i]<>'..') then
			begin
			FLoadComboBox.CreateItem(ar[i]);
			ExC := True;
			end;
	SetLength(ar,0);
	end;
if ExC then
	begin
	FLoadComboBox.SelectItem := 0;
	FLoadComboBox.Active := True;
	FLoadButton.Active   := True;
	end
else
	begin
	FLoadComboBox.Active := False;
	FLoadButton.Active   := False;
	FLoadComboBox.SelectItem := -1;
	end;
end;

procedure TSGGasDiffusion.UpDateConchLabels();
function lghl : LongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (FConchLabels=nil) then
	Result:=0
else
	Result := Length(FConchLabels);
end;
function lghg : LongWord;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (FCube.FGazes=nil) then
	Result:=0
else
	Result := Length(FCube.FGazes);
end;
var
	i,j : LongWord;
begin
if FCube = nil then
	Exit;
if lghl < lghg + 1 then
	begin
	j := lghl;
	SetLength(FConchLabels,lghg + 1);
	for i := j to lghg do
		begin
		FConchLabels[i] := TSGLabel.Create();
		SGScreen.CreateChild(FConchLabels[i]);
		FConchLabels[i].SetBounds(5,50+i*22,400,20);
		FConchLabels[i].BoundsToNeedBounds();
		FConchLabels[i].Visible:=True;
		FConchLabels[i].Active:=True;
		FConchLabels[i].TextPosition := False;
		FConchLabels[i].Font := FTahomaFont;
		end;
	end
else while lghl > lghg + 1 do
	begin
	FConchLabels[High(FConchLabels)].Destroy();
	SetLength(FConchLabels,lghl-1);
	end;
j := FCube.Edge*FCube.Edge*FCube.Edge;
FConchLabels[0].Caption := 'Концентрация всех газов: '+SGStrReal(100*FCube.FDinamicQuantityMoleculs/j,4) + '%';
FConchLabels[0].Visible:=True;
for i:=1 to High(FConchLabels) do
	begin
	FConchLabels[i].Caption := 'Концентрация газа №'+SGStr(i)+': '+SGStrReal(100*FCube.FGazes[i-1].FDinamicQuantity/j,4) + '%';
	FConchLabels[i].Visible:=True;
	end;
end;

constructor TSGGasDiffusion.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
{$IFDEF RELIEFDEBUG}
	FInReliafDebug        := 0;
	{$ENDIF}
FStartingFlag             := 0;
FStartingThread           := nil;
FStartingProgressBar      := nil;
FSechenieImage            := nil;
FPointerSecheniePlace     := 0;
FPlaneComboBox            := nil;
FNewSecheniePanel         := nil;
FSecheniePanel            := nil;
FMesh                     := nil;
FCube                     := nil;
FAddNewSourseButton       := nil;
FStartEmulatingButton     := nil;
FAddNewGazButton          := nil;
FStopEmulatingButton      := nil;
FPauseEmulatingButton     := nil;
FDeleteSechenieButton     := nil;
FAddSechenieButton        := nil;
FBackToMenuButton         := nil;
FFileName                 := '';
FFileStream               := nil;
FDiffusionRuned           := False;
FEnableSaving             := True;
FMoviePlayed              := False;
FArCadrs                  := nil;
FNowCadr                  := 0;
FMovieBackToMenuButton    := nil;
FMoviePlayButton          := nil;
FMoviePauseButton         := nil;
FInfoLabel                := nil;
FAddNewGazPanel           := nil;
FConchLabels              := nil;
FAddSechSecondPanelButton := nil;
FBoundsOptionsPanel       := nil;
FUsrImageThread           := nil;
FUsrRange                 := 2;
FRelefOptionPanel         := nil;
FCubeForUsr               := nil;
FUpdateUsrAfterThread     := False;
FUsrSechImageForThread    := nil;
FRedactorBackButton       := nil;

FRelief.Clear();
FRelief.InitBase();
FRelefRedactor := TSGGasDiffusionReliefRedactor.Create(VContext);
FRelefRedactor.Relief := @FRelief;

FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
FCamera.FZum := Context.Height/Context.Width;

FTahomaFont:=TSGFont.Create(SGFontDirectory+Slash+{$IFDEF MOBILE}'Times New Roman.sgf'{$ELSE}'Tahoma.sgf'{$ENDIF});
FTahomaFont.SetContext(Context);
FTahomaFont.Loading();
FTahomaFont.ToTexture();

FStartingProgressBar := TSGProgressBar.Create();
SGScreen.CreateChild(FStartingProgressBar);
SGScreen.LastChild.SetBounds(Context.Width div 2 - 151,Context.Height div 2 - 100, 300, 20);
SGScreen.LastChild.BoundsToNeedBounds();
SGScreen.LastChild.Visible:=False;
FStartingProgressBar.Progress := 0;

FRedactorBackButton:=TSGButton.Create();
SGScreen.CreateChild(FRedactorBackButton);
SGScreen.LastChild.SetBounds(Context.Width div 2 - 75,5,130,20);
SGScreen.LastChild.BoundsToNeedBounds();
SGScreen.LastChild.Visible:=False;
SGScreen.LastChild.Font := FTahomaFont;
SGScreen.LastChild.Caption:='Назад';
SGScreen.LastChild.UserPointer:=Self;
FRedactorBackButton.OnChange:=TSGComponentProcedure(@mmmFRedactorBackButton);

FNewScenePanel:=TSGPanel.Create();
SGScreen.CreateChild(FNewScenePanel);
SGScreen.LastChild.SetMiddleBounds(400,110+26);
SGScreen.LastChild.BoundsToNeedBounds();
SGScreen.LastChild.UserPointer:=Self;
SGScreen.LastChild.Visible:=True;

FNewScenePanel.CreateChild(TSGLabel.Create());
FNewScenePanel.LastChild.Caption := 'Создание новой сцены';
FNewScenePanel.LastChild.SetBounds(5,0,275+100,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;

FNewScenePanel.CreateChild(TSGLabel.Create());
FNewScenePanel.LastChild.Caption := 'Количество точек:';
FNewScenePanel.LastChild.SetBounds(5,19,280,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;
FNewScenePanel.LastChild.AsLabel.FTextPosition:=0;

FNumberLabel:=TSGLabel.Create();
FNewScenePanel.CreateChild(FNumberLabel);
FNewScenePanel.LastChild.Caption:='';
FNewScenePanel.LastChild.SetBounds(170,19,180,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;
FNewScenePanel.LastChild.AsLabel.FTextPosition:=0;

FStartSceneButton:=TSGButton.Create();
FNewScenePanel.CreateChild(FStartSceneButton);
FNewScenePanel.LastChild.SetBounds(10,44,80,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;
FNewScenePanel.LastChild.Caption:='Старт';
FNewScenePanel.LastChild.UserPointer:=Self;
FStartSceneButton.OnChange:=TSGComponentProcedure(@mmmFStartSceneButtonProcedure);

FEdgeEdit:=TSGEdit.Create();
FNewScenePanel.CreateChild(FEdgeEdit);
FNewScenePanel.LastChild.SetBounds(118,19,50,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;
FNewScenePanel.LastChild.Caption:='75';
FNewScenePanel.LastChild.UserPointer:=Self;
FEdgeEdit.TextTypeFunction:=TSGEditTextTypeFunction(@mmmFEdgeEditTextTypeFunction);
FEdgeEdit.TextType:=SGEditTypeUser;
mmmFEdgeEditTextTypeFunction(FEdgeEdit);

FEnableLoadButton:=TSGButton.Create();
FNewScenePanel.CreateChild(FEnableLoadButton);
FNewScenePanel.LastChild.SetBounds(100,44,278,20);
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.Font := FTahomaFont;
FNewScenePanel.LastChild.Caption:='Загрузка сохраненной сцены/повтора';
FNewScenePanel.LastChild.UserPointer:=Self;
FEnableLoadButton.OnChange:=TSGComponentProcedure(@mmmFEnableLoadButtonProcedure);

FEnableOutputComboBox := TSGComboBox.Create();
FNewScenePanel.CreateChild(FEnableOutputComboBox);
FEnableOutputComboBox.SetBounds(10,44+26,380-10,19);
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Font := FTahomaFont;
FEnableOutputComboBox.CreateItem('Включить непрерывное сохранение эмуляции');
FEnableOutputComboBox.CreateItem('Не включать непрерывное сохранение эмуляции');
//FEnableOutputComboBox.FProcedure:=TSGComboBoxProcedure(@FEnableOutputComboBoxProcedure);
FEnableOutputComboBox.SelectItem:={$IFDEF RELIEFDEBUG}1{$ELSE}{$IFDEF MOBILE}1{$ELSE}0{$ENDIF}{$ENDIF};
FEnableOutputComboBox.UserPointer:=Self;

FBoundsTypeButton := TSGButton.Create();
FNewScenePanel.CreateChild(FBoundsTypeButton);
FBoundsTypeButton.SetBounds(10,44+26+25,380-10,19);
FNewScenePanel.LastChild.Visible:=True;
FNewScenePanel.LastChild.BoundsToNeedBounds();
FNewScenePanel.LastChild.Font := FTahomaFont;
FNewScenePanel.LastChild.Caption := 'Настроить поведение газа на границах';
FBoundsTypeButton.OnChange:=TSGComponentProcedure(@mmmFBoundsTypeButtonProcedure);
FBoundsTypeButton.UserPointer:=Self;

FLoadScenePanel:=TSGPanel.Create();
SGScreen.CreateChild(FLoadScenePanel);
SGScreen.LastChild.SetMiddleBounds(440,105);
SGScreen.LastChild.Visible:=False;
SGScreen.LastChild.BoundsToNeedBounds();
SGScreen.LastChild.UserPointer:=Self;

FLoadScenePanel.CreateChild(TSGLabel.Create());
FLoadScenePanel.LastChild.Caption := 'Загрузка сохраненной сцены/повтора';
FLoadScenePanel.LastChild.SetBounds(5,0,275+140,20);
FLoadScenePanel.LastChild.BoundsToNeedBounds();
FLoadScenePanel.LastChild.Visible:=False;
FLoadScenePanel.LastChild.Font := FTahomaFont;

FLoadComboBox := TSGComboBox.Create();
FLoadScenePanel.CreateChild(FLoadComboBox);
FLoadComboBox.SetBounds(5,21,480-60,19);
FLoadScenePanel.LastChild.Visible:=False;
FLoadScenePanel.LastChild.BoundsToNeedBounds();
FLoadScenePanel.LastChild.Font := FTahomaFont;
//FLoadComboBox.FProcedure:=TSGComboBoxProcedure(@FLoadComboBoxProcedure);
FLoadComboBox.SelectItem:=-1;
FLoadComboBox.UserPointer:=Self;

FBackButton:=TSGButton.Create();
FLoadScenePanel.CreateChild(FBackButton);
FLoadScenePanel.LastChild.SetBounds(10,44,130,20);
FLoadScenePanel.LastChild.BoundsToNeedBounds();
FLoadScenePanel.LastChild.Visible:=False;
FLoadScenePanel.LastChild.Font := FTahomaFont;
FLoadScenePanel.LastChild.Caption:='Назад';
FLoadScenePanel.LastChild.UserPointer:=Self;
FBackButton.OnChange:=TSGComponentProcedure(@mmmFBackButtonProcedure);

FUpdateButton:=TSGButton.Create();
FLoadScenePanel.CreateChild(FUpdateButton);
FLoadScenePanel.LastChild.SetBounds(145,44,130,20);
FLoadScenePanel.LastChild.BoundsToNeedBounds();
FLoadScenePanel.LastChild.Visible:=False;
FLoadScenePanel.LastChild.Font := FTahomaFont;
FLoadScenePanel.LastChild.Caption:='Обновить';
FLoadScenePanel.LastChild.UserPointer:=Self;
FUpdateButton.OnChange:=TSGComponentProcedure(@mmmFUpdateButtonProcedure);

FLoadButton:=TSGButton.Create();
FLoadScenePanel.CreateChild(FLoadButton);
FLoadScenePanel.LastChild.SetBounds(145+135,44,130,20);
FLoadScenePanel.LastChild.BoundsToNeedBounds();
FLoadScenePanel.LastChild.Visible:=False;
FLoadScenePanel.LastChild.Font := FTahomaFont;
FLoadScenePanel.LastChild.Caption:='Загрузить';
FLoadScenePanel.LastChild.UserPointer:=Self;
FLoadButton.OnChange:=TSGComponentProcedure(@mmmFLoadButtonProcedure);

FLoadScenePanel.CreateChild(TSGButton.Create());
FLoadScenePanel.LastChild.SetBounds(5,44+24,420,20);
FLoadScenePanel.LastChild.BoundsToNeedBounds();
FLoadScenePanel.LastChild.Visible:=False;
FLoadScenePanel.LastChild.Font := FTahomaFont;
FLoadScenePanel.LastChild.Caption:='Открыть папку с сохранениями';
FLoadScenePanel.LastChild.UserPointer:=Self;
(FLoadScenePanel.LastChild as TSGButton).OnChange:=TSGComponentProcedure(@mmmFOpenSaveDir);

FInfoLabel := TSGLabel.Create();
SGScreen.CreateChild(FInfoLabel);
SGScreen.LastChild.Caption := '';
SGScreen.LastChild.SetBounds(5,Context.Height-25,Context.Width-10,20);
SGScreen.LastChild.BoundsToNeedBounds();
SGScreen.LastChild.Visible:=True;
SGScreen.LastChild.Font := FTahomaFont;
end;

procedure TSGGasDiffusion.UpDateChangeSourses();
var
	a : record x,y,z:Real; end;
	b : TSGVertex3f;
	s : LongWord;
	c : TSGColor4f;
begin
if ((FCube.FSourses=nil) or (Length(FCube.FSourses)=0)) then
	Exit;
s := (FAddNewSoursePanel.Children[1] as TSGComboBox).SelectItem;
a.x :=2*FCube.FSourses[s].FCoord.z/FCube.Edge-1;
a.y :=2*FCube.FSourses[s].FCoord.y/FCube.Edge-1;
a.z :=2*FCube.FSourses[s].FCoord.x/FCube.Edge-1;
C.Import(1,$A5/256,0,1);
C.Color(Render);
Render.BeginScene(SGR_LINE_LOOP);
Render.Vertex3f(1,-1,a.z);
Render.Vertex3f(-1,-1,a.z);
Render.Vertex3f(-1,1,a.z);
Render.Vertex3f(1,1,a.z);
Render.EndScene();
Render.BeginScene(SGR_LINE_LOOP);
Render.Vertex3f(1,a.y,-1);
Render.Vertex3f(-1,a.y,-1);
Render.Vertex3f(-1,a.y,1);
Render.Vertex3f(1,a.y,1);
Render.EndScene();
Render.BeginScene(SGR_LINE_LOOP);
Render.Vertex3f(a.x,1,-1);
Render.Vertex3f(a.x,-1,-1);
Render.Vertex3f(a.x,-1,1);
Render.Vertex3f(a.x,1,1);
Render.EndScene();

{$IFNDEF MOBILE}
	DrawComplexCube();
	Render.GetVertexUnderPixel(Context.CursorPosition().x,Context.CursorPosition().y,a.x,a.y,a.z);
	b.Import(a.x,a.y,a.z);
	if Abs(b) <2 then
		begin
		
		end;
	{$ENDIF}
end;

procedure TSGGasDiffusion.Draw();
procedure DrawSechenie();
var
	a,b,c,d : TSGVertex3f;
procedure DrawQuadSec(const Primitive : TSGLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Render.BeginScene(Primitive);
a.Vertex(Render);
b.Vertex(Render);
c.Vertex(Render);
d.Vertex(Render);
Render.EndScene();
end;
begin
case FPlaneComboBox.SelectItem of
0:
	begin
	a.Import(1,FPointerSecheniePlace,1);
	b.Import(1,FPointerSecheniePlace,-1);
	c.Import(-1,FPointerSecheniePlace,-1);
	d.Import(-1,FPointerSecheniePlace,1);
	end;
1:
	begin
	a.Import(FPointerSecheniePlace,1,1);
	b.Import(FPointerSecheniePlace,1,-1);
	c.Import(FPointerSecheniePlace,-1,-1);
	d.Import(FPointerSecheniePlace,-1,1);
	end;
2:
	begin
	a.Import(1,1,FPointerSecheniePlace);
	b.Import(1,-1,FPointerSecheniePlace);
	c.Import(-1,-1,FPointerSecheniePlace);
	d.Import(-1,1,FPointerSecheniePlace);
	end;
end;
if (FNewSecheniePanel<>nil) and FNewSecheniePanel.Visible then
	begin
	Render.Color4f($80/255,0,$80/255,0.3);
	DrawQuadSec(SGR_QUADS);
	end;
Render.Color4f($80/255,0,$80/255,0.7);
DrawQuadSec(SGR_LINE_LOOP);
end;
procedure UpDateAfterUsrThread();
var
	BitMap : PByte;
begin
FUsrSechImage.FreeTexture();
FreeMem(FUsrSechImage.Image.BitMap);
GetMem(BitMap,FImageSechenieBounds*FImageSechenieBounds*FSechenieImage.Image.Channels);
FUsrSechImage.Image.BitMap := BitMap;
Move(FUsrSechImageForThread.Image.BitMap^,FUsrSechImage.Image.BitMap^, FUsrSechImage.Width * FUsrSechImage.Height * FUsrSechImage.Channels);
FUsrSechImage.ToTexture();
if FUsrSechImageForThread <> nil then
	begin
	FUsrSechImageForThread.Destroy();
	FUsrSechImageForThread := nil;
	end;
FUpdateUsrAfterThread := False;
if (FUsrSechThread <> nil) then
	begin
	FUsrSechThread.Destroy();
	FUsrSechThread := nil;
	end;
FAddSechSecondPanelButton.Active := True;
(FUsrSechPanel.Children[2] as TSGProgressBar).Visible := False;
end;
var
	i : LongWord;
begin
if FUpdateUsrAfterThread then
	UpDateAfterUsrThread();
if FStartingFlag = 2 then
	begin
	mmmPostInitCubeProcedure(Self);
	FStartingFlag := 0;
	end;
if FMesh <> nil then
	begin
	FCamera.CallAction();
	FMesh.Draw();
	if (FSecheniePanel<>nil) then
		DrawSechenie();
	if FDiffusionRuned then
		begin
		if FEnableSaving then 
			begin
			if (Render.RenderType = SGRenderDirectX) then
				if FMesh.QuantityObjects<>0 then
					for i := 0 to FMesh.QuantityObjects-1 do 
						FMesh.Objects[i].ChangeMeshColorType4b();
			SaveStageToStream();
			end;
		FMesh.Destroy();
		FCube.UpDateCube();
		FMesh:=FCube.CalculateMesh(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
		FNowCadr+=1;
		end;
	if (FSecheniePanel<>nil)  and (FSecheniePanel.Visible) then
		begin
		UpDateSechenie();
		end;
	if (FAddNewSoursePanel<>nil) and FAddNewSoursePanel.Visible then
		begin
		UpDateChangeSourses();
		end;
	if FMoviePlayed then
		begin
		if FMesh<>nil then
			FMesh.Destroy();
		FMesh:=TSGCustomModel.Create();
		FMesh.Context := Context;
		FNowCadr+=1;
		if FNowCadr > High(FArCadrs) then
			FNowCadr:=0;
		FFileStream.Position:=FArCadrs[FNowCadr];
		FMesh.LoadFromSG3DM(FFileStream);
		if (Render.RenderType=SGRenderDirectX) then
			if FMesh.QuantityObjects<>0 then
				for i := 0 to FMesh.QuantityObjects-1 do 
					FMesh.Objects[i].ChangeMeshColorType4b();
		end;
	if FDiffusionRuned or FMoviePlayed then
		UpDateInfoLabel();
	UpDateConchLabels();
	{$IFDEF RELIEFDEBUG}
		if Context.KeyPressed() and (Context.KeyPressedType() = SGUpKey) and (Context.KeyPressedChar() = 'D') then
			begin
			FInReliafDebug += 1;
			if FInReliafDebug = 3 then
				FInReliafDebug := 0;
			FMesh.Destroy();
			FMesh:=FCube.CalculateMesh(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
			end;
		{$ENDIF}
	end;
end;

procedure TSGGasDiffusion.UpDateInfoLabel();
begin
if FMoviePlayed then
	begin
	FInfoLabel.Caption:='Размер файла: "'+SGGetSizeString(FFileStream.Size,'RU')+'", Итераций: "'+SGStr(Length(FArCadrs))+'", Позиция: "'+SGStrReal(FNowCadr/Length(FArCadrs)*100,2)+'%"';
	end
else if FDiffusionRuned then
	begin
	FInfoLabel.Caption:='';
	if FEnableSaving and (FFileStream<>nil)then
		FInfoLabel.Caption:=FInfoLabel.Caption+'Размер файла: "'+SGGetSizeString(FFileStream.Size,'RU')+'", ';
	if (FMesh<>nil) and (FMesh.LastObject()<>nil) then
		FInfoLabel.Caption:=FInfoLabel.Caption+'Итерация: "'+SGStr(FNowCadr)+'", Количество точек: "'+SGStr(FCube.FDinamicQuantityMoleculs)+'"'
	end;
end;

end.
