{$INCLUDE SaGe.inc}

{$DEFINE RELIEFDEBUG}

unit SaGeGasDiffusion;

interface
uses
	 Dos
	,SysUtils
	,Classes
	
	,SaGeBase
	,SaGeThreads
	,SaGeMesh
	,SaGeVertexObject
	,SaGeContext
	,SaGeContextClasses
	,SaGeContextInterface
	,SaGeRenderBase
	,SaGeCommonStructs
	,SaGeFont
	,SaGeImage
	,SaGeBitMap
	,SaGeGasDiffusionReliefRedactor
	,SaGeScreenBase
	,SaGeExtensionManager
	,SaGeFileUtils
	,SaGeCamera
	,SaGeScreenClasses
	;

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
		FColor           : TSGColor4f;
		FArParents       : array[0..1] of LongInt;
		FDinamicQuantity : LongWord;
		procedure Create(const r,g,b: Single;const a: Single = 1;const p1 : LongInt = -1; const p2: LongInt = -1);
		end;
	
	TSGSourseType = object
		FGazTypeIndex : TSGLongWord;
		FCoord        : TSGPoint3int32;
		FRadius       : TSGLongWord;
		end;
	
	TSGSubsidenceVertex = object
		FCount       : TSGLongWord;
		FCoords      : TSGPoint3int32;
		FVertexIndex : TSGLongWord;
		FRelief      : TSGLongWord;
		end;
	TSGSubsidenceVertexes = type packed array of TSGSubsidenceVertex;
	
	TSGGGDC = ^ TSGByte;
	TSGGasDiffusionCube = class(TSGPaintableObject)
			public
		constructor Create(const VContext : ISGContext);override;
		procedure Paint();override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			public
		procedure UpDateSourses();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure InitCube(const Edge : TSGLongWord; const VProgress : PSGScreenProgressBarFloat = nil);
		procedure UpDateCube();
		function  CalculateMesh(const VRelief : PSGGasDiffusionRelief = nil{$IFDEF RELIEFDEBUG};const FInReliafDebug : TSGLongWord = 0{$ENDIF}) : TSGCustomModel;
		procedure ClearGaz();
		procedure InitReliefIndexes(const VProgress : PSGScreenProgressBarFloat = nil);
			public
		function Cube (const x, y, z : Word) : TSGGGDC;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ReliefCubeIndex (const x,y,z : Word):TSGGGDC;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function Copy() : TSGGasDiffusionCube;
			public
		FCube       : TSGGGDC;						// ^byte - кубик
		FReliefCubeIndex : TSGGGDC;
		FCubeCoords : packed array of
			TSGVertex3f;							// 3хмерные координаты каждой точки из FCube
		FEdge       : TSGLongWord;					// размерность FCube (FEdge * FEdge * FEdge)
		FGazes      : packed array of TSGGazType;	// типы газа
		FSourses    : packed array of TSGSourseType;// источники газа
		FDinamicQuantityMoleculs : LongWord;		// количество точек газа на данный момент
		FFlag       : Boolean;						// флажок этапа итерации. этот алгоритм работает в 2 этапа
		FRelief     : PSGGasDiffusionRelief;
		FSubsidenceVertexes : TSGSubsidenceVertexes;
			public
		property Edge : TSGLongWord read FEdge;
		end;
type
	TSGGasDiffusion = class(TSGPaintableObject)
			public
		constructor Create(const VContext : ISGContext);override;
		procedure Paint();override;
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
			FNewScenePanel : TSGScreenPanel;				// панель нового проэкта
		
		FStartingProgressBar : TSGScreenProgressBar;
		FStartingThread      : TSGThread;
		FStartingFlag        : LongInt;
		
		// Перетаскивание источников
		FSourseChangeFlag    : TSGLongWord;                 //Number of sourse + 1
		FSourseChangeFlag2   : TSGLongWord;                 //Plane(0,1,2)
		
		//New Panel
		FEdgeEdit               : TSGScreenEdit;
		FNumberLabel            : TSGScreenLabel;
		FStartSceneButton,
		FBoundsTypeButton,
			FEnableLoadButton   : TSGScreenButton;
		FEnableOutputComboBox   : TSGScreenComboBox;
		
		//Load Panel
		FLoadComboBox      : TSGScreenComboBox;
		FBackButton, 
			FUpdateButton, 
			FLoadButton    : TSGScreenButton;
		
		//Экран
		FInfoLabel : TSGScreenLabel;
		
			(* Сечение *)
		
		FNewSecheniePanel, 						// Содержит кнопку и FPlaneComboBox
			FSecheniePanel : TSGScreenPanel;	// Cодержит картинку сечения
		FPlaneComboBox : TSGScreenComboBox;			// вычесление осей координат для FPointerSecheniePlace
		FPointerSecheniePlace : TSGSingle;		// (-1..1) значение места сечения
		FSechenieImage : TSGImage; 				// Картинка сечения
		FImageSechenieBounds : LongWord; 		// Действительное расширение картинки сечения
		FSechenieUnProjectVertex : TSGVertex3f; // For Un Project
		
		FUsrSechPanel  : TSGScreenPanel;
		FUsrSechImage : TSGImage;
		FUsrSechImageForThread : TSGImage;
		FUsrImageThread : TSGThread;
		FUsrRange: LongWord;
		FUsrSechThread : TSGThread;
		FCubeForUsr : TSGGasDiffusionCube;
		FUpdateUsrAfterThread : Boolean;
		
			(*Экран моделирования*)
		FConchLabels : packed array of
			TSGScreenLabel;
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
			FRedactorBackButton: TSGScreenButton;
		
		FAddNewSoursePanel : TSGScreenPanel;
		FAddNewGazPanel : TSGScreenPanel;
			(*Повтор*)
		
		//FFileStream  : TFileStream;
		//FFileName    : TSGString;
		FArCadrs       : packed array of TSGQuadWord;
		FNowCadr       : TSGLongWord;
		FMoviePlayed   : TSGBoolean;
		
		//Экран повтора
		FMoviePauseButton,
			FMovieBackToMenuButton,
			FMoviePlayButton : TSGScreenButton;
		
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

uses
	 SaGeStringUtils
	,SaGeLists
	,SaGeMathUtils
	,SaGeRenderInterface
	,SaGeMatrix
	,SaGeCommon
	,SaGeMeshSg3dm
	,SaGeContextUtils
	,SaGeScreen_Edit
	,SaGeRectangleWithRoundedCorners
	;

//Algorithm

procedure TSGGazType.Create(const r,g,b: Single;const a: Single = 1;const p1 : LongInt = -1; const p2: LongInt = -1);
begin
FColor.Import(r,g,b,a);
FArParents[0]:=p1;
FArParents[1]:=p2;
end;

constructor TSGGasDiffusionCube.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FEdge   := 0;
FCube   := nil;
FSourses:= nil;
FGazes  := nil;
FCubeCoords := nil;
FRelief := nil;
FSubsidenceVertexes := nil;
end;

procedure TSGGasDiffusionCube.Paint();
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
if FSubsidenceVertexes <> nil then
	SetLength(FSubsidenceVertexes, 0);
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

procedure TSGGasDiffusionCube.InitCube(const Edge : TSGLongWord; const VProgress : PSGScreenProgressBarFloat = nil);
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

procedure TSGGasDiffusionCube.InitReliefIndexes(const VProgress : PSGScreenProgressBarFloat = nil);

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


function PointToTriangleZ(const t1,t2,t3,v:TSGVertex3f;const b : Single):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(
	v.x, v.y, 
	ScalePointToTriangle3D(
		SGVertex2fImport(t1.x,t1.y),
		SGVertex2fImport(t2.x,t2.y),
		SGVertex2fImport(t3.x,t3.y),
		SGVertex2fImport(v.x,v.y),
		t1.z,t2.z,t3.z)
	);
end;

function PointToTriangleX(const t1,t2,t3,v:TSGVertex3f;const b : Single):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(
	ScalePointToTriangle3D(
			SGVertex2fImport(t1.z,t1.y),
			SGVertex2fImport(t2.z,t2.y),
			SGVertex2fImport(t3.z,t3.y),
			SGVertex2fImport(v.z,v.y),
			t1.x,t2.x,t3.x),
	v.y, v.z);
end;

function PointToTriangleY(const t1,t2,t3,v:TSGVertex3f;const b : Single):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin 
Result.Import( v.x,
	ScalePointToTriangle3D(
			SGVertex2fImport(t1.x,t1.z),
			SGVertex2fImport(t2.x,t2.z),
			SGVertex2fImport(t3.x,t3.z),
			SGVertex2fImport(v.x,v.z),
			t1.y,t2.y,t3.y),
	v.z);
end;

function PointToTriangle(const t1,t2,t3,v,n:TSGVertex3f):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (abs(n.x)<SGZero) and (abs(n.y)<SGZero) then
	Result := PointToTriangleZ(t1,t2,t3,v,n.z)
else if (abs(n.z)<SGZero) and (abs(n.y)<SGZero) then
	Result := PointToTriangleX(t1,t2,t3,v,n.x)
else if (abs(n.x)<SGZero) and (abs(n.z)<SGZero) then
	Result := PointToTriangleY(t1,t2,t3,v,n.y)
else
	Result.Import();
end;

function PointInPolygone(const sr : PSGGasDiffusionSingleRelief; const index : LongWord; const v : TSGVertex3f; const n : TSGVertex3f;const ReliefIndex : Byte):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : LongWord;
begin
Result := False;
for i := 1 to High(sr^.FPolygones[index]) - 1 do
	begin
	if PointInTriangle(
		sr^.FPoints[sr^.FPolygones[index][0]] * GetReliefMatrix(ReliefIndex) + n * 0.95,
		sr^.FPoints[sr^.FPolygones[index][i]] * GetReliefMatrix(ReliefIndex) + n * 0.95,
		sr^.FPoints[sr^.FPolygones[index][i+1]] * GetReliefMatrix(ReliefIndex) + n * 0.95,
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

function ProjectingPointToRelief(const v,n : TSGVertex3f;const sr : PSGGasDiffusionSingleRelief;const ReliefIndex : TSGLongWord):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, index : LongWord;
begin
Result.Import(0,0,0);
for index := 0 to High(sr^.FPolygones) do
	for i := 1 to High(sr^.FPolygones[index]) - 1 do
		begin
		if PointInTriangle(
			sr^.FPoints[sr^.FPolygones[index][0]]   * GetReliefMatrix(ReliefIndex) + n * 0.95,
			sr^.FPoints[sr^.FPolygones[index][i]]   * GetReliefMatrix(ReliefIndex) + n * 0.95,
			sr^.FPoints[sr^.FPolygones[index][i+1]] * GetReliefMatrix(ReliefIndex) + n * 0.95,
			v,n) then
				begin
				Result := PointToTriangle(
						sr^.FPoints[sr^.FPolygones[index][0]]   * GetReliefMatrix(ReliefIndex) + n * 0.95,
						sr^.FPoints[sr^.FPolygones[index][i]]   * GetReliefMatrix(ReliefIndex) + n * 0.95,
						sr^.FPoints[sr^.FPolygones[index][i+1]] * GetReliefMatrix(ReliefIndex) + n * 0.95,
						v,n);
				Break;
				end;
		end;
end;

function PostInvert(const index : TSGLongWord; const v : TSGVertex3f):TSGVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case index of
0,1:Result.Import(v.x,(-1)*v.y,(-1)*v.z);
2,3:Result.Import(v.x,v.y,v.z);
4,5:Result.Import(v.x,v.y,v.z);
end;
end;

var
	FRCI : TSGGGDC = nil;

function RCI (const x,y,z : Word):TSGGGDC;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=@FRCI[(x*FEdge+y)*FEdge+z];
end;

var
	i, j : TSGLongWord;
	i1, i2, i3, AllPolygoneSize, PolygoneIndex, ii : TSGLongWord;
	l, k : integer;
	a1,a2,a3 : byte;
begin
//Алгоритм разбивающий все точки пространства на 2 множества.
//По точкам одного множества газ может перемещаться, а по точкам другого множества - нет. 
if FRelief <> nil then
	begin
	PolygoneIndex := 0;
	AllPolygoneSize := 0; 
	for j := 0 to 5 do
		if FRelief^.FData[j].FEnabled then
			if FRelief^.FData[j].FPolygones <> nil then if Length(FRelief^.FData[j].FPolygones) <> 0 then
				AllPolygoneSize += Length(FRelief^.FData[j].FPolygones)*(1+Byte(FRelief^.FData[j].FType));
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
//Соседние точки тоже помещаем как негодные для перемещения газа.
FRCI := GetMem(Edge * Edge * Edge);
FillChar(FRCI^, Edge * Edge * Edge, 1);
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
			RCI(i1  ,i2  ,i3+1)^ := RCI(i1,i2,i3)^;
			RCI(i1+1,i2  ,i3+1)^ := RCI(i1,i2,i3)^;
			RCI(i1  ,i2+1,i3+1)^ := RCI(i1,i2,i3)^;
			RCI(i1+1,i2+1,i3+1)^ := RCI(i1,i2,i3)^;
			RCI(i1  ,i2  ,i3  )^ := RCI(i1,i2,i3)^;
			RCI(i1+1,i2  ,i3  )^ := RCI(i1,i2,i3)^;
			RCI(i1  ,i2+1,i3  )^ := RCI(i1,i2,i3)^;
			RCI(i1+1,i2+1,i3  )^ := RCI(i1,i2,i3)^;
			i3+=2;
			end;
		i2+=2;
		end;
	i1+=2;
	end;
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
			RCI(i1  ,i2  ,i3+1)^ := RCI(i1,i2,i3)^;
			RCI(i1+1,i2  ,i3+1)^ := RCI(i1,i2,i3)^;
			RCI(i1  ,i2+1,i3+1)^ := RCI(i1,i2,i3)^;
			RCI(i1+1,i2+1,i3+1)^ := RCI(i1,i2,i3)^;
			RCI(i1  ,i2  ,i3  )^ := RCI(i1,i2,i3)^;
			RCI(i1+1,i2  ,i3  )^ := RCI(i1,i2,i3)^;
			RCI(i1  ,i2+1,i3  )^ := RCI(i1,i2,i3)^;
			RCI(i1+1,i2+1,i3  )^ := RCI(i1,i2,i3)^;
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
// Алгоритм для оседающих граней
if FRelief <> nil then
	begin
	if (FSubsidenceVertexes <> nil) then
		SetLength(FSubsidenceVertexes, 0);
	FSubsidenceVertexes := nil;
	for j := 0 to 5 do
		begin
		if FRelief^.FData[j].FEnabled and FRelief^.FData[j].FType then
			begin
			
			FRelief^.FData[j].FMesh := TSG3DObject.Create();
			FRelief^.FData[j].FMesh.Context := Context;
			FRelief^.FData[j].FMesh.HasNormals := False;
			FRelief^.FData[j].FMesh.HasTexture := False;
			FRelief^.FData[j].FMesh.HasColors  := True;
			FRelief^.FData[j].FMesh.EnableCullFace := False;
			FRelief^.FData[j].FMesh.VertexType := SGMeshVertexType3f;
			FRelief^.FData[j].FMesh.SetColorType (SGMeshColorType4b);
			FRelief^.FData[j].FMesh.Vertexes   := Edge * Edge;
			FRelief^.FData[j].FMesh.AddFaceArray();
			FRelief^.FData[j].FMesh.PoligonesType[0] := SGR_TRIANGLES;
			
			FRelief^.FData[j].FMesh.Faces[0] := (Edge-1) * (Edge-1) * 2;
			for i := 0 to Edge - 2 do 
				for ii := 0 to Edge - 2 do
					begin
					FRelief^.FData[j].FMesh.SetFaceTriangle
						(0,(i * (Edge - 1) + ii) * 2 + 0, i * Edge + ii, i * Edge + (ii+1), (i+1) * Edge + ii+1);
					FRelief^.FData[j].FMesh.SetFaceTriangle
						(0,(i * (Edge - 1) + ii) * 2 + 1, i * Edge + ii, (i+1) * Edge + ii, (i+1) * Edge + ii+1);
					end;
			
			for i := 0 to Edge - 1 do 
				for ii := 0 to Edge - 1 do
					begin
					case j of
					0 : begin l:=0;      k:= 1;   a1:=0; a2:=1; a3:=0;   i1:=i; i2:=0;  i3:=ii; end;
					1 : begin l:=Edge-1; k:=-1;   a1:=0; a2:=1; a3:=0;   i1:=i; i2:=0;  i3:=ii; end;
					2 : begin l:=0;      k:= 1;   a1:=1; a2:=0; a3:=0;   i1:=0; i2:=i;  i3:=ii; end;
					3 : begin l:=Edge-1; k:=-1;   a1:=1; a2:=0; a3:=0;   i1:=0; i2:=i;  i3:=ii; end;
					4 : begin l:=0;      k:= 1;   a1:=0; a2:=0; a3:=1;   i1:=i; i2:=ii; i3:=0;  end;
					5 : begin l:=Edge-1; k:=-1;   a1:=0; a2:=0; a3:=1;   i1:=i; i2:=ii; i3:=0;  end;
					end;
					
					while (not TSGBoolean(ReliefCubeIndex(i1+a1*l, i2+a2*l, i3+a3*l))) and (l>=0) and (l<=Edge - 1) do
						l += k;
					
					FRelief^.FData[j].FMesh.ArVertex3f[i * Edge + ii]^ := PostInvert(j, ProjectingPointToRelief(
						SGVertex3fImport(
							(i1+a1*l)/(Edge-1)*2-1,
							(i2+a2*l)/(Edge-1)*2-1,
							(i3+a3*l)/(Edge-1)*2-1),
						VertexFromIndex(j),
						@FRelief^.FData[j],
						j));
					FRelief^.FData[j].FMesh.SetColor  (i * Edge + ii, 0, 0, 0, 0.6);
					
					if (l>=0) and (l<=Edge - 1) then
						begin
						if (FSubsidenceVertexes = nil) then
							SetLength(FSubsidenceVertexes, 1)
						else
							SetLength(FSubsidenceVertexes, Length(FSubsidenceVertexes) + 1);
						FSubsidenceVertexes[High(FSubsidenceVertexes)].FCount := 0;
						case j of
						0 : FSubsidenceVertexes[High(FSubsidenceVertexes)].FCoords.Import(i1 + a1 * l, i2 + a2 * l, i3 + a3 * l); //Up
						1 : FSubsidenceVertexes[High(FSubsidenceVertexes)].FCoords.Import(i1 + a1 * l, i2 + a2 * l, i3 + a3 * l); //Down
						2 : FSubsidenceVertexes[High(FSubsidenceVertexes)].FCoords.Import(i1 + a1 * l, i2 + a2 * l, i3 + a3 * l); 
						3 : FSubsidenceVertexes[High(FSubsidenceVertexes)].FCoords.Import(i1 + a1 * l, i2 + a2 * l, i3 + a3 * l);
						4 : FSubsidenceVertexes[High(FSubsidenceVertexes)].FCoords.Import(i1 + a1 * l, i2 + a2 * l, i3 + a3 * l);
						5 : FSubsidenceVertexes[High(FSubsidenceVertexes)].FCoords.Import(i1 + a1 * l, i2 + a2 * l, i3 + a3 * l);
						end;
						FSubsidenceVertexes[High(FSubsidenceVertexes)].FVertexIndex := i * Edge + ii;
						FSubsidenceVertexes[High(FSubsidenceVertexes)].FRelief := j;
						end;
					end;
			
			for i := 0 to FRelief^.FData[j].FMesh.Faces[0] - 1 do
				begin
				if (Abs(FRelief^.FData[j].FMesh.ArVertex3f[FRelief^.FData[j].FMesh.ArFacesTriangles(0,i).p0]^) < SGZero) or 
				   (Abs(FRelief^.FData[j].FMesh.ArVertex3f[FRelief^.FData[j].FMesh.ArFacesTriangles(0,i).p1]^) < SGZero) or 
				   (Abs(FRelief^.FData[j].FMesh.ArVertex3f[FRelief^.FData[j].FMesh.ArFacesTriangles(0,i).p2]^) < SGZero) then
						begin
						FRelief^.FData[j].FMesh.SetFaceTriangle(0,i,0,0,0);
						end;
				end;
			end;
		if VProgress <> nil then
			VProgress ^ := PolygoneIndex / AllPolygoneSize + ((AllPolygoneSize - PolygoneIndex) / AllPolygoneSize) * (j / 5);
		end;
	end;
end;

procedure TSGGasDiffusionCube.UpDateSourses();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function IsInRange(const i : integer):TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (i>=0) and (i<=Edge - 1);
end;
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
			if IsInRange(j1d) and IsInRange(j2d) and (IsInRange(j3d)) then
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
	i1, i2, i3 : TSGLongWord;
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

procedure UpDateSubsidenceRelief();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i, ii : TSGLongWord;
        c : TSGGGDC;
        col : TSGColor4f;
begin
if (FSubsidenceVertexes <> nil) and (Length(FSubsidenceVertexes)>0) then
   for i := 0 to High(FSubsidenceVertexes) do
       begin
       c := Cube(FSubsidenceVertexes[i].FCoords.x, FSubsidenceVertexes[i].FCoords.y, FSubsidenceVertexes[i].FCoords.z);
       if c^ <> 0 then
          begin
          col := FRelief^.FData[FSubsidenceVertexes[i].FRelief].FMesh.GetColor(FSubsidenceVertexes[i].FVertexIndex);
          col := (col * FSubsidenceVertexes[i].FCount + FGazes[c^ - 1].FColor) / (FSubsidenceVertexes[i].FCount + 1);
          FSubsidenceVertexes[i].FCount += 1;
          FRelief^.FData[FSubsidenceVertexes[i].FRelief].FMesh.SetColor(FSubsidenceVertexes[i].FVertexIndex, col.r, col.g, col.b, col.a);
          c^ := 0;
          end;
       end;
end;

procedure UpDateOpenBounds();
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
UpDateSubsidenceRelief();
UpDateOpenBounds();
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
		Result.LastObject().SetColor(i,$0A/256,$C7/256,$F5/256,1);
	end
else
	VRelief^.ExportToMesh(Result);
end;

// Release

procedure TSGGasDiffusion.SaveStageToStream();
begin
if FFileStream <> nil then
	TSGMeshSG3DMLoader.SaveModel(FMesh, FFileStream);
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
if FRelefRedactor <> nil then
	begin
	FRelefRedactor.Destroy();
	FRelefRedactor := nil;
	end;

if FRedactorBackButton <> nil then
	FRedactorBackButton.Destroy();
inherited;
end;

class function TSGGasDiffusion.ClassName():TSGString;
begin
Result := 'Моделирование диффузии газа';
end;

procedure mmmFBackToMenuButtonProcedure(Button:TSGScreenButton);
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
		(FSecheniePanel.LastChild as TSGScreenPicture).Image := nil;
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
procedure mmmFPauseDiffusionButtonProcedure(Button:TSGScreenButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FDiffusionRuned := False;
	Button.Active := False;
	FStopEmulatingButton.Active := True;
	FStartEmulatingButton.Active := True;
end; end;
procedure mmmFNewSecheniePanelButtonOnChange(Button:TSGScreenButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FAddNewSourseButton.Active := True;
	FAddNewGazButton.Active := True;
	FNewSecheniePanel.Visible := False;
	FAddSechSecondPanelButton.Active := True;
	FSaveImageButton.Active := True;
end; end;
procedure mmmFAddSechenieButtonProcedure(Button:TSGScreenButton);
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
	
	FNewSecheniePanel := SGCreatePanel(Screen, Render.Width-10-a,Render.Height-10-a,a,a, [SGAnchRight, SGAnchBottom], True, True, Button.UserPointer);
	
	FPlaneComboBox := TSGScreenComboBox.Create();
	FNewSecheniePanel.CreateChild(FPlaneComboBox);
	FNewSecheniePanel.LastChild.SetBounds(5,5,190,FTahomaFont.FontHeight+2);
	FNewSecheniePanel.LastChild.BoundsMakeReal();
	FNewSecheniePanel.LastChild.UserPointer:=Button.UserPointer;
	FNewSecheniePanel.LastChild.Visible:=True;
	FPlaneComboBox.CreateItem('XoY');
	FPlaneComboBox.CreateItem('XoZ');
	FPlaneComboBox.CreateItem('ZoY');
	FPlaneComboBox.SelectItem := 0;
	
	FNewSecheniePanel.CreateChild(TSGScreenButton.Create());
	FNewSecheniePanel.LastChild.SetBounds(5,FTahomaFont.FontHeight+10,190,FTahomaFont.FontHeight+2);
	FNewSecheniePanel.LastChild.BoundsMakeReal();
	FNewSecheniePanel.LastChild.UserPointer:=Button.UserPointer;
	FNewSecheniePanel.LastChild.Visible:=True;
	FNewSecheniePanel.LastChild.Caption := 'ОК';
	(FNewSecheniePanel.LastChild as TSGScreenButton).OnChange := TSGScreenComponentProcedure(@mmmFNewSecheniePanelButtonOnChange);
	
	a := (FCube.Edge+1)*2;
	
	FSecheniePanel := SGCreatePanel(Screen, 5,Render.Height-10-a,a,a, [SGAnchBottom], True, True, Button.UserPointer);
	
	FSechenieImage:=TSGImage.Create();
	FSechenieImage.Context := Context;
	FSechenieImage.Image.Clear();
	FSechenieImage.Width          := FImageSechenieBounds;
	FSechenieImage.Height         := FImageSechenieBounds;
	FSechenieImage.Image.Channels := 4;
	FSechenieImage.Image.BitDepth := 8;
	FSechenieImage.Image.BitMap   := GetMem(FCube.Edge*FCube.Edge*FSechenieImage.Image.Channels);
	FSechenieImage.Image.CreateTypes();
	
	SGCreatePicture(FSecheniePanel, 5,5,a-10,a-10, True, True);
	
	(FSecheniePanel.LastChild as TSGScreenPicture).Image       := FSechenieImage;
	(FSecheniePanel.LastChild as TSGScreenPicture).EnableLines := True;
	(FSecheniePanel.LastChild as TSGScreenPicture).SecondPoint.Import(
		FCube.Edge/FImageSechenieBounds,
		FCube.Edge/FImageSechenieBounds);
	
	UpDateSechenie();
end; end;
procedure mmmFDeleteSechenieButtonProcedure(Button:TSGScreenButton);
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
		(FSecheniePanel.LastChild as TSGScreenPicture).Image := nil;
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

Render.Color3f(1,1,1);
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

procedure mmmFStopDiffusionButtonProcedure(Button:TSGScreenButton);
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

procedure mmmFRunDiffusionButtonProcedure(Button:TSGScreenButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FDiffusionRuned := True;
	Button.Active := False;
	FStopEmulatingButton.Active := True;
	FPauseEmulatingButton.Active := True;
	if FEnableSaving and (FFileStream=nil) then
		begin
		FFileName   := SGFreeFileName(PredStr + Catalog + DirectorySeparator + 'Save.GDS', 'number');
		FFileStream := TFileStream.Create(FFileName, fmCreate);
		end;
end; end;

type
	TSGGDrawColor = class(TSGScreenComponent)
			public
		Color : TSGColor4f;
			public
		procedure Paint(); override;
		end;

procedure TSGGDrawColor.Paint();
begin
if (FVisible) or (FVisibleTimer>SGZero) then
	begin
	Color.a := FVisibleTimer;
	SGRoundQuad(Render,
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		5,10,
		Color,
		Color,
		not True,not False);
	end;
inherited;
end;

procedure UpdateNewGasPanel(Panel:TSGScreenComponent);
var
	g,i : LongWord;
begin with TSGGasDiffusion(Panel.UserPointer) do begin
if not ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
	begin
	g  := (Panel.Children[1] as TSGScreenComboBox).SelectItem;
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
	(Panel.Children[6] as TSGScreenComboBox).SelectItem := 0;
	Panel.Children[7].Caption := SGStr(FCube.FGazes[g].FArParents[0]+1);
	Panel.Children[8].Caption := SGStr(FCube.FGazes[g].FArParents[1]+1);
	Panel.Children[7].Active:=True;
	Panel.Children[8].Active:=True;
	end
else
	begin
	(Panel.Children[6] as TSGScreenComboBox).SelectItem := 1;
	Panel.Children[7].Active:=False;
	Panel.Children[8].Active:=False;
	Panel.Children[7].Caption := '';
	Panel.Children[8].Caption := '';
	end;
end;end;

procedure mmmGasCBProc(b,c : LongInt;a : TSGScreenComboBox);
begin
a.SelectItem := c;
UpdateNewGasPanel(a.Parent as TSGScreenComponent);
end;

procedure mmmFCloseAddNewGazButtonProcedure(Button:TSGScreenButton);
begin with TSGGasDiffusion(Button.Parent.UserPointer) do begin
FAddNewGazPanel.Visible := False;
FAddNewGazPanel.Active := False;
FAddNewSourseButton.Active := True;
FAddNewGazButton.Active := True;
FAddSechenieButton.Active := FSecheniePanel=nil;
FDeleteSechenieButton.Active := FSecheniePanel<>nil;
end; end;

procedure mmmGas123Proc(b,c : LongInt;a : TSGScreenComboBox);
begin with TSGGasDiffusion(a.Parent.UserPointer) do begin
a.Parent.Children[7].Active:=not Boolean(c);
a.Parent.Children[8].Active:=not Boolean(c);
a.Parent.Children[8].Caption := '';
a.Parent.Children[7].Caption := '';
(a.Parent.Children[7] as TSGScreenEdit).TextComplite := False;
(a.Parent.Children[8] as TSGScreenEdit).TextComplite := False;
end; end;

procedure mmmFAddAddNewGazButtonProcedure(Button:TSGScreenButton);
var
	i : LongWord;
begin with TSGGasDiffusion(Button.Parent.UserPointer) do begin
SetLength(FCube.FGazes,Length(FCube.FGazes)+1);
FCube.FGazes[High(FCube.FGazes)].Create(random,random,random,1,-1,-1);
(Button.Parent.Children[1] as TSGScreenComboBox).ClearItems();
for i := 0 to High(FCube.FGazes) do
	(Button.Parent.Children[1] as TSGScreenComboBox).CreateItem('Газ №'+SGStr(i+1));
(Button.Parent.Children[1] as TSGScreenComboBox).Active := True;
(Button.Parent.Children[1] as TSGScreenComboBox).SelectItem := High(FCube.FGazes);
UpdateNewGasPanel(Button.Parent as TSGScreenComponent);
end;end;

procedure mmmGas1234Proc(Button:TSGScreenButton);//Удаление
var
	i,ii,iii,j : LongWord;
begin with TSGGasDiffusion(Button.Parent.UserPointer) do begin
if ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
	Exit;
ii := (Button.Parent.Children[1] as TSGScreenComboBox).SelectItem;
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
(Button.Parent.Children[1] as TSGScreenComboBox).ClearItems();
if ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
	begin
	(Button.Parent.Children[1] as TSGScreenComboBox).CreateItem('Добавьте газы');
	(Button.Parent.Children[1] as TSGScreenComboBox).SelectItem := 0;
	(Button.Parent.Children[1] as TSGScreenComboBox).Active := False;
	end
else
	begin
	for i:=0 to High(FCube.FGazes) do
		(Button.Parent.Children[1] as TSGScreenComboBox).CreateItem('Газ №'+SGStr(i+1));
	(Button.Parent.Children[1] as TSGScreenComboBox).SelectItem := High(FCube.FGazes);
	end;
UpdateNewGasPanel(Button.Parent as TSGScreenComponent);
FMesh.Destroy();
FMesh:=FCube.CalculateMesh(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
end;end;

procedure mmmGasChangeProc(Button:TSGScreenButton);
var
	a,b,c : LongWord;
begin with TSGGasDiffusion(Button.Parent.UserPointer) do begin
if not Boolean((Button.Parent.Children[6] as TSGScreenComboBox).SelectItem) then
	begin
	a := SGVal(Button.Parent.Children[7].Caption);
	b := SGVal(Button.Parent.Children[8].Caption);
	if (a<>b) and (a>=1) and (a<=Length(FCube.FGazes)) and (b>=1) and (b<=Length(FCube.FGazes)) then
		begin
		c := (Button.Parent.Children[1] as TSGScreenComboBox).SelectItem;
		FCube.FGazes[c].FArParents[0]:=a-1;
		FCube.FGazes[c].FArParents[1]:=b-1;
		end;
	end
else
	begin
	c := (Button.Parent.Children[1] as TSGScreenComboBox).SelectItem;
	FCube.FGazes[c].FArParents[0]:=-1;
	FCube.FGazes[c].FArParents[1]:=-1;
	end;
end; end;

procedure mmmFAddNewGazButtonProcedure(Button:TSGScreenButton);
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
	FAddNewGazPanel := SGCreatePanel(Screen, Render.Width - pw - 10, Render.Height - ph - 10, pw, ph, [SGAnchRight,SGAnchBottom], True, True, Button.UserPointer);
	
	FAddNewGazPanel.CreateChild(TSGScreenComboBox.Create());//1
	FAddNewGazPanel.LastChild.SetBounds(0,4,pw - 10 - 25,18);
	FAddNewGazPanel.LastChild.BoundsMakeReal();
	if ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
		(FAddNewGazPanel.LastChild as TSGScreenComboBox).CreateItem('Добавьте газы')
	else
		for i:=0 to High(FCube.FGazes) do
			(FAddNewGazPanel.LastChild as TSGScreenComboBox).CreateItem('Газ №'+SGStr(i+1));
	(FAddNewGazPanel.LastChild as TSGScreenComboBox).SelectItem := 0;
	(FAddNewGazPanel.LastChild as TSGScreenComboBox).CallBackProcedure:=TSGScreenComboBoxProcedure(@mmmGasCBProc);
	(FAddNewGazPanel.LastChild as TSGScreenComboBox).MaxLines := 5;
	
	FAddNewGazPanel.CreateChild(TSGScreenButton.Create());//2
	FAddNewGazPanel.LastChild.SetBounds(5+pw - 10 - 25+2,4,20,18);
	FAddNewGazPanel.LastChild.BoundsMakeReal();
	FAddNewGazPanel.LastChild.Caption:='+';
	(FAddNewGazPanel.LastChild as TSGScreenButton).OnChange:=TSGScreenComponentProcedure(@mmmFAddAddNewGazButtonProcedure);
	
	SGCreateLabel(FAddNewGazPanel, 'Цвет:', 0,25,50,18, False, True);//3
	
	FAddNewGazPanel.CreateChild(TSGGDrawColor.Create());//4
	FAddNewGazPanel.LastChild.SetBounds(50,26,75,18);
	FAddNewGazPanel.LastChild.BoundsMakeReal();
	
	FAddNewGazPanel.CreateChild(TSGScreenButton.Create());//5
	FAddNewGazPanel.LastChild.SetBounds(5+pw - 10 - 25+2-40,25,60,18);
	FAddNewGazPanel.LastChild.BoundsMakeReal();
	FAddNewGazPanel.LastChild.Caption:='Править';
	
	FAddNewGazPanel.CreateChild(TSGScreenComboBox.Create());//6
	FAddNewGazPanel.LastChild.SetBounds(3,48,pw - 10,18);
	FAddNewGazPanel.LastChild.BoundsMakeReal();
	(FAddNewGazPanel.LastChild as TSGScreenComboBox).CreateItem('Образуется при контакте');
	(FAddNewGazPanel.LastChild as TSGScreenComboBox).CreateItem('Небудет получаться');
	(FAddNewGazPanel.LastChild as TSGScreenComboBox).SelectItem := 0;
	(FAddNewGazPanel.LastChild as TSGScreenComboBox).CallBackProcedure := TSGScreenComboBoxProcedure(@mmmGas123Proc);
	
	SGCreateEdit(FAddNewGazPanel, '', SGScreenEditTypeNumber, 3,69,(pw div 2) - 10,18, [], False, True);//7
	SGCreateEdit(FAddNewGazPanel, '', SGScreenEditTypeNumber, 3+(pw div 2)+3,69,(pw div 2) - 10,18, [], False, True);//8
	
	FAddNewGazPanel.CreateChild(TSGScreenButton.Create());//9
	FAddNewGazPanel.LastChild.SetBounds(3,90,pw - 10,18);
	FAddNewGazPanel.LastChild.BoundsMakeReal();
	FAddNewGazPanel.LastChild.Caption:='Удалить этот газ';
	(FAddNewGazPanel.LastChild as TSGScreenButton).OnChange:=TSGScreenComponentProcedure(@mmmGas1234Proc);
	
	FAddNewGazPanel.CreateChild(TSGScreenButton.Create());//10
	FAddNewGazPanel.LastChild.SetBounds(3,111+21,pw - 10,18);
	FAddNewGazPanel.LastChild.BoundsMakeReal();
	FAddNewGazPanel.LastChild.Caption:='Закрыть это окно';
	(FAddNewGazPanel.LastChild as TSGScreenButton).OnChange:=TSGScreenComponentProcedure(@mmmFCloseAddNewGazButtonProcedure);
	
	FAddNewGazPanel.CreateChild(TSGScreenButton.Create());//11
	FAddNewGazPanel.LastChild.SetBounds(3,111,pw - 10,18);
	FAddNewGazPanel.LastChild.BoundsMakeReal();
	FAddNewGazPanel.LastChild.Caption:='Применить';
	(FAddNewGazPanel.LastChild as TSGScreenButton).OnChange:=TSGScreenComponentProcedure(@mmmGasChangeProc);
	end;
FAddNewGazPanel.Visible := True;
FAddNewGazPanel.Active := True;

UpdateNewGasPanel(FAddNewGazPanel);
end; end;

procedure mmmFCloseAddNewSourseButtonProcedure(Button:TSGScreenButton);
begin with TSGGasDiffusion(Button.Parent.UserPointer) do begin
FAddNewSoursePanel.Visible := False;
FAddNewSoursePanel.Active := False;
FAddNewSourseButton.Active := True;
FAddNewGazButton.Active := True;
FAddSechenieButton.Active := FSecheniePanel=nil;
FDeleteSechenieButton.Active := FSecheniePanel<>nil;
end; end;

procedure mmmSourseChageGasProc(b,c : LongInt;a : TSGScreenComboBox);
var
	o,i : LongWord;
	j1,j2,j3 : LongInt;
begin with TSGGasDiffusion(a.Parent.UserPointer) do begin
if b = c then
	Exit;
a.SelectItem:=c;
i := (FAddNewSoursePanel.Children[1] as TSGScreenComboBox).SelectItem;
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

procedure mmmSourseChageSourseProc(b,c : LongInt;a : TSGScreenComboBox);
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
	(FAddNewSoursePanel.Children[3] as TSGScreenComboBox).SelectItem := 0;
	(FAddNewSoursePanel.Children[4] as TSGScreenEdit).Caption := '';
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
	s := (FAddNewSoursePanel.Children[1] as TSGScreenComboBox).SelectItem;
	(FAddNewSoursePanel.Children[3] as TSGScreenComboBox).SelectItem := FCube.FSourses[s].FGazTypeIndex;
	(FAddNewSoursePanel.Children[4] as TSGScreenEdit).Caption := SGStr(FCube.FSourses[s].FRadius);
	(FAddNewSoursePanel.Children[4] as TSGScreenEdit).TextComplite := True;
	end;
end;

procedure mmmFAddAddNewSourseButtonProcedure(Button:TSGScreenButton);
var
	i : LongWord;
	j1,j2,j3 : LongInt;
begin with TSGGasDiffusion(Button.Parent.UserPointer) do begin 
SetLength(FCube.FSourses,Length(FCube.FSourses)+1);
FCube.FSourses[High(FCube.FSourses)].FGazTypeIndex := random(Length(FCube.FGazes));
FCube.FSourses[High(FCube.FSourses)].FCoord.Import(random(FCube.Edge-10)+5,random(FCube.Edge-10)+5,random(FCube.Edge-10)+5);
FCube.FSourses[High(FCube.FSourses)].FRadius := random(3)+1;
(Button.Parent.Children[1] as TSGScreenComboBox).ClearItems();
for i:=0 to High(FCube.FSourses) do
	(Button.Parent.Children[1] as TSGScreenComboBox).CreateItem('Источник №'+SGStr(i+1));
i := High(FCube.FSourses);
(Button.Parent.Children[1] as TSGScreenComboBox).SelectItem := i;
FCube.UpDateSourses();
UpDateSoursePanel();
FMesh.Destroy();
FMesh:=FCube.CalculateMesh(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
end;end;

procedure mmmFDleteSourseAddNewSourseButtonProcedure(Button:TSGScreenButton);
var
	s : LongInt;
	i : LongWord;
	j1,j2,j3 : LongInt;
begin with TSGGasDiffusion(Button.Parent.UserPointer) do begin 
s := (Button.Parent.Children[1] as TSGScreenComboBox).SelectItem;

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

(Button.Parent.Children[1] as TSGScreenComboBox).ClearItems();
if Length(FCube.FSourses)=0 then
	begin
	(Button.Parent.Children[1] as TSGScreenComboBox).CreateItem('Нету источников');
	end
else
	begin
	for i:=0 to High(FCube.FSourses) do
		(Button.Parent.Children[1] as TSGScreenComboBox).CreateItem('Источник №'+SGStr(i+1));
	end;
(Button.Parent.Children[1] as TSGScreenComboBox).SelectItem := 0;

UpDateSoursePanel();
FMesh.Destroy();
FMesh:=FCube.CalculateMesh(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
end; end;

procedure FAddNewSourseButtonProcedure(Button:TSGScreenButton);
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
	FAddNewSoursePanel := SGCreatePanel(Screen, Render.Width - pw - 10,Render.Height - ph - 10, pw, ph, [SGAnchRight, SGAnchBottom], False, True, Button.UserPointer);
	
	FAddNewSoursePanel.CreateChild(TSGScreenComboBox.Create());//1
	FAddNewSoursePanel.LastChild.SetBounds(0,4,pw - 10 - 25,18);
	FAddNewSoursePanel.LastChild.BoundsMakeReal();
	if ((FCube.FSourses=nil) or (Length(FCube.FSourses)=0)) then
		(FAddNewSoursePanel.LastChild as TSGScreenComboBox).CreateItem('Нету источников')
	else
		for i:=0 to High(FCube.FSourses) do
			(FAddNewSoursePanel.LastChild as TSGScreenComboBox).CreateItem('Источник №'+SGStr(i+1));
	(FAddNewSoursePanel.LastChild as TSGScreenComboBox).SelectItem := 0;
	(FAddNewSoursePanel.LastChild as TSGScreenComboBox).CallBackProcedure:=TSGScreenComboBoxProcedure(@mmmSourseChageSourseProc);
	(FAddNewSoursePanel.LastChild as TSGScreenComboBox).MaxLines := 6;
	
	FAddNewSoursePanel.CreateChild(TSGScreenButton.Create());//2
	FAddNewSoursePanel.LastChild.SetBounds(5+pw - 10 - 25+2,4,20,18);
	FAddNewSoursePanel.LastChild.BoundsMakeReal();
	FAddNewSoursePanel.LastChild.Caption:='+';
	(FAddNewSoursePanel.LastChild as TSGScreenButton).OnChange:=TSGScreenComponentProcedure(@mmmFAddAddNewSourseButtonProcedure);
	
	FAddNewSoursePanel.CreateChild(TSGScreenComboBox.Create());//3
	FAddNewSoursePanel.LastChild.SetBounds(0,4+21,pw - 10,18);
	FAddNewSoursePanel.LastChild.BoundsMakeReal();
	if ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
		begin
		(FAddNewSoursePanel.LastChild as TSGScreenComboBox).CreateItem('Добавьте газы');
		end
	else
		for i:=0 to High(FCube.FGazes) do
			(FAddNewSoursePanel.LastChild as TSGScreenComboBox).CreateItem('Газ №'+SGStr(i+1));
	(FAddNewSoursePanel.LastChild as TSGScreenComboBox).SelectItem := 0;
	(FAddNewSoursePanel.LastChild as TSGScreenComboBox).CallBackProcedure :=TSGScreenComboBoxProcedure(@mmmSourseChageGasProc);
	
	SGCreateEdit(FAddNewSoursePanel, '', SGScreenEditTypeNumber, 3+(pw div 2)+3,69-21,(pw div 2) - 10,18, [], False, True);//4
	SGCreateLabel(FAddNewSoursePanel, 'Радиус:', 3,69-21,(pw div 2) - 10,18, False, True);//5
	
	FAddNewSoursePanel.CreateChild(TSGScreenButton.Create());//6
	FAddNewSoursePanel.LastChild.SetBounds(3,69+21,pw - 10,18);
	FAddNewSoursePanel.LastChild.BoundsMakeReal();
	FAddNewSoursePanel.LastChild.Caption:='Закрыть это окно';
	(FAddNewSoursePanel.LastChild as TSGScreenButton).OnChange:=TSGScreenComponentProcedure(@mmmFCloseAddNewSourseButtonProcedure);
	
	FAddNewSoursePanel.CreateChild(TSGScreenButton.Create());//7
	FAddNewSoursePanel.LastChild.SetBounds(3,69,pw - 10,18);
	FAddNewSoursePanel.LastChild.BoundsMakeReal();
	FAddNewSoursePanel.LastChild.Caption:='Удалить';
	(FAddNewSoursePanel.LastChild as TSGScreenButton).OnChange:=TSGScreenComponentProcedure(@mmmFDleteSourseAddNewSourseButtonProcedure);
	end;

FAddNewSoursePanel.Active  := True;
FAddNewSoursePanel.Visible := True;
UpDateSoursePanel();
end; end;

procedure mmmFSaveImageButtonProcedure(Button:TSGScreenButton);
procedure PutPixel(const p : TSGPixel4b; const Destination : PByte);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

SGMakeDirectory(PredStr + Catalog);
{$IFDEF WITHLIBPNG}
	Image.FileName := SGFreeFileName(PredStr + Catalog + DirectorySeparator + 'Image.png', 'number');
	Image.Saveing(SGI_PNG);
{$ELSE}
	Image.FileName := SGFreeFileName(PredStr + Catalog + DirectorySeparator + 'Image.jpg', 'number');
	Image.Saveing(SGI_JPEG);
	{$ENDIF}

FreeMem(Image.Image.BitMap);
Image.Image.BitMap := nil;
Image.Destroy();
end;end;

procedure mmmFAddSechSecondPanelButtonProcedure(Button:TSGScreenButton);
var
	a : LongWord;
begin with TSGGasDiffusion(Button.UserPointer) do begin
if FUsrSechPanel = nil then
	begin
	a := (FCube.Edge+1)*2;
	FUsrSechPanel := SGCreatePanel(Screen, a + 10,Render.Height - a - 10, a, a, [SGAnchBottom], True, True, Button.UserPointer);
	
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
	
	SGCreatePicture(FUsrSechPanel, 5,5,a-10,a-10, True, True);
	
	(FUsrSechPanel.LastChild as TSGScreenPicture).Image       := FUsrSechImage;
	(FUsrSechPanel.LastChild as TSGScreenPicture).EnableLines := True;
	(FUsrSechPanel.LastChild as TSGScreenPicture).SecondPoint.Import(
		FCube.Edge/FImageSechenieBounds,
		FCube.Edge/FImageSechenieBounds);
	
	FUsrSechPanel.CreateChild(TSGScreenProgressBar.Create());
	//FUsrSechPanel.LastChild.Font := FTahomaFont;
	FUsrSechPanel.LastChild.SetBounds(
		10,FUsrSechPanel.Height div 2 - (FUsrSechPanel.LastChild as TSGScreenComponent).Skin.Font.FontHeight div 2,
		FUsrSechPanel.Width - 30,(FUsrSechPanel.LastChild as TSGScreenComponent).Skin.Font.FontHeight);
	FUsrSechPanel.LastChild.BoundsMakeReal();
	(FUsrSechPanel.Children[2] as TSGScreenProgressBar).Visible := True;
	end;

UpDateUsrSech();
end; end;

procedure FUsrImageThreadProcedure(Klass : TSGGasDiffusion);
function InitPixel(const x,y,z : LongWord;const range : LongInt):TSGPixel4b;
var
	i, ii, iii, total, totalAlpha: LongInt;
	px, py, pz : LongInt;
	colorIndex : byte;
	color : TSGColor4f = ( x : 0; y : 0; z : 0; w : 0);
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
	Result := SGConvertPixelRGBToAlpha(Result);
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
	(FUsrSechPanel.Children[2] as TSGScreenProgressBar).Progress := i/(FCube.Edge - 1);
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
	(FUsrSechPanel.Children[2] as TSGScreenProgressBar).Visible := True;
	(FUsrSechPanel.Children[2] as TSGScreenProgressBar).ProgressTimer := 0;
	(FUsrSechPanel.Children[2] as TSGScreenProgressBar).Progress := 0;
	
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
	FBackToMenuButton:=TSGScreenButton.Create();
	Screen.CreateChild(FBackToMenuButton);
	FBackToMenuButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*0,W,FTahomaFont.FontHeight+2);
	FBackToMenuButton.BoundsMakeReal();
	FBackToMenuButton.Anchors:=[SGAnchRight];
	FBackToMenuButton.Visible := True;
	FBackToMenuButton.Active  := True;
	FBackToMenuButton.Skin := FBackToMenuButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FBackToMenuButton.Caption :='В главное меню';
	FBackToMenuButton.UserPointer:=Klass;
	FBackToMenuButton.OnChange:=TSGScreenComponentProcedure(@mmmFBackToMenuButtonProcedure);
	end
else
	begin
	FBackToMenuButton.Visible := True;
	FBackToMenuButton.Active  := True;
	end;

if FAddNewGazButton=nil then
	begin
	FAddNewGazButton:=TSGScreenButton.Create();
	Screen.CreateChild(FAddNewGazButton);
	FAddNewGazButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*1,W,FTahomaFont.FontHeight+2);
	FAddNewGazButton.BoundsMakeReal();
	FAddNewGazButton.Anchors:=[SGAnchRight];
	FAddNewGazButton.Visible:=True;
	FAddNewGazButton.Active  := True;
	FAddNewGazButton.Skin := FAddNewGazButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FAddNewGazButton.Caption:='Править типы газа';
	FAddNewGazButton.UserPointer:=Klass;
	FAddNewGazButton.OnChange:=TSGScreenComponentProcedure(@mmmFAddNewGazButtonProcedure);
	end
else
	begin
	FAddNewGazButton.Visible := True;
	FAddNewGazButton.Active  := True;
	end;

if FAddNewSourseButton = nil then
	begin
	FAddNewSourseButton:=TSGScreenButton.Create();
	Screen.CreateChild(FAddNewSourseButton);
	FAddNewSourseButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*2,W,FTahomaFont.FontHeight+2);
	FAddNewSourseButton.BoundsMakeReal();
	FAddNewSourseButton.Anchors:=[SGAnchRight];
	FAddNewSourseButton.Visible:=True;
	FAddNewSourseButton.Active  := True;
	FAddNewSourseButton.Skin := FAddNewSourseButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FAddNewSourseButton.Caption:='Править източники газа';
	FAddNewSourseButton.UserPointer:=Klass;
	FAddNewSourseButton.OnChange:=TSGScreenComponentProcedure(@FAddNewSourseButtonProcedure);
	end
else
	begin
	FAddNewSourseButton.Visible := True;
	FAddNewSourseButton.Active  := True;
	end;

if FStartEmulatingButton=nil then
	begin
	FStartEmulatingButton:=TSGScreenButton.Create();
	Screen.CreateChild(FStartEmulatingButton);
	FStartEmulatingButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*3,W,FTahomaFont.FontHeight+2);
	FStartEmulatingButton.BoundsMakeReal();
	FStartEmulatingButton.Anchors:=[SGAnchRight];
	FStartEmulatingButton.Visible:=True;
	FStartEmulatingButton.Active  := True;
	FStartEmulatingButton.Skin := FStartEmulatingButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FStartEmulatingButton.Caption:='Эмурировать';
	FStartEmulatingButton.UserPointer:=Klass;
	FStartEmulatingButton.OnChange:=TSGScreenComponentProcedure(@mmmFRunDiffusionButtonProcedure);
	end
else
	begin
	FStartEmulatingButton.Visible := True;
	FStartEmulatingButton.Active  := True;
	end;

if FPauseEmulatingButton = nil then
	begin
	FPauseEmulatingButton:=TSGScreenButton.Create();
	Screen.CreateChild(FPauseEmulatingButton);
	FPauseEmulatingButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*4,W,FTahomaFont.FontHeight+2);
	FPauseEmulatingButton.BoundsMakeReal();
	FPauseEmulatingButton.Anchors:=[SGAnchRight];
	FPauseEmulatingButton.Visible:=True;
	FPauseEmulatingButton.Active :=False;
	FPauseEmulatingButton.Skin := FPauseEmulatingButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FPauseEmulatingButton.Caption:='Приостановить эмуляцию';
	FPauseEmulatingButton.UserPointer:=Klass;
	FPauseEmulatingButton.OnChange:=TSGScreenComponentProcedure(@mmmFPauseDiffusionButtonProcedure);
	end
else
	begin
	FPauseEmulatingButton.Visible := True;
	FPauseEmulatingButton.Active  := False;
	end;

if FStopEmulatingButton = nil then
	begin
	FStopEmulatingButton:=TSGScreenButton.Create();
	Screen.CreateChild(FStopEmulatingButton);
	FStopEmulatingButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*5,W,FTahomaFont.FontHeight+2);
	FStopEmulatingButton.BoundsMakeReal();
	FStopEmulatingButton.Anchors:=[SGAnchRight];
	FStopEmulatingButton.Visible:=True;
	FStopEmulatingButton.Active :=False;
	FStopEmulatingButton.Skin := FStopEmulatingButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FStopEmulatingButton.Caption:='Ocтановить эмуляцию';
	FStopEmulatingButton.UserPointer:=Klass;
	FStopEmulatingButton.OnChange:=TSGScreenComponentProcedure(@mmmFStopDiffusionButtonProcedure);
	end
else
	begin
	FStopEmulatingButton.Visible := True;
	FStopEmulatingButton.Active  := False;
	end;

if FAddSechenieButton = nil then 
	begin
	FAddSechenieButton:=TSGScreenButton.Create();
	Screen.CreateChild(FAddSechenieButton);
	FAddSechenieButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*6,W,FTahomaFont.FontHeight+2);
	FAddSechenieButton.BoundsMakeReal();
	FAddSechenieButton.Anchors:=[SGAnchRight];
	FAddSechenieButton.Visible:=True;
	FAddSechenieButton.Active :=True;
	FAddSechenieButton.Skin := FAddSechenieButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FAddSechenieButton.Caption:='Рассмотреть сечение';
	FAddSechenieButton.UserPointer:=Klass;
	FAddSechenieButton.OnChange:=TSGScreenComponentProcedure(@mmmFAddSechenieButtonProcedure);
	end
else
	begin
	FAddSechenieButton.Visible := True;
	FAddSechenieButton.Active  := True;
	end;

if FDeleteSechenieButton = nil then
	begin
	FDeleteSechenieButton:=TSGScreenButton.Create();
	Screen.CreateChild(FDeleteSechenieButton);
	FDeleteSechenieButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*7,W,FTahomaFont.FontHeight+2);
	FDeleteSechenieButton.BoundsMakeReal();
	FDeleteSechenieButton.Anchors:=[SGAnchRight];
	FDeleteSechenieButton.Visible:=True;
	FDeleteSechenieButton.Active :=False;
	FDeleteSechenieButton.Skin := FDeleteSechenieButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FDeleteSechenieButton.Caption:='Не рассмотривать сечение';
	FDeleteSechenieButton.UserPointer:=Klass;
	FDeleteSechenieButton.OnChange:=TSGScreenComponentProcedure(@mmmFDeleteSechenieButtonProcedure);
	end
else
	begin
	FDeleteSechenieButton.Visible := True;
	FDeleteSechenieButton.Active  := False;
	end;

if FAddSechSecondPanelButton = nil then
	begin
	FAddSechSecondPanelButton:=TSGScreenButton.Create();
	Screen.CreateChild(FAddSechSecondPanelButton);
	FAddSechSecondPanelButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*8,W,FTahomaFont.FontHeight+2);
	FAddSechSecondPanelButton.BoundsMakeReal();
	FAddSechSecondPanelButton.Anchors:=[SGAnchRight];
	FAddSechSecondPanelButton.Visible:=True;
	FAddSechSecondPanelButton.Active :=False;
	FAddSechSecondPanelButton.Skin := FAddSechSecondPanelButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FAddSechSecondPanelButton.Caption:='Вычисление концентрации';
	FAddSechSecondPanelButton.UserPointer:=Klass;
	FAddSechSecondPanelButton.OnChange:=TSGScreenComponentProcedure(@mmmFAddSechSecondPanelButtonProcedure);
	end
else
	begin
	FAddSechSecondPanelButton.Visible := True;
	FAddSechSecondPanelButton.Active  := False;
	end;

if FSaveImageButton = nil then
	begin
	FSaveImageButton:=TSGScreenButton.Create();
	Screen.CreateChild(FSaveImageButton);
	FSaveImageButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*9,W,FTahomaFont.FontHeight+2);
	FSaveImageButton.BoundsMakeReal();
	FSaveImageButton.Anchors:=[SGAnchRight];
	FSaveImageButton.Visible:=True;
	FSaveImageButton.Active :=False;
	FSaveImageButton.Skin := FSaveImageButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FSaveImageButton.Caption:='Сoхранить картинку';
	FSaveImageButton.UserPointer:=Klass;
	FSaveImageButton.OnChange:=TSGScreenComponentProcedure(@mmmFSaveImageButtonProcedure);
	end
else
	begin
	FSaveImageButton.Visible := True;
	FSaveImageButton.Active  := False;
	end;
end;end;

procedure mmmFStartSceneButtonProcedure(Button:TSGScreenButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FStartingFlag := 1;
	FStartingThread := TSGThread.Create(TSGThreadProcedure(@mmmFStartingThreadProcedure),Button.UserPointer,True);
	FStartingProgressBar.Visible := True;
	FStartingProgressBar.ProgressTimer := 0;
	FStartingProgressBar.Progress := 0;
	FStartSceneButton.Active := False;
	FLoadButton.Active := False;
	
	FEdgeEdit .Active := False;
	FEnableLoadButton .Active := False;
	FEnableOutputComboBox.Active := False;
	FBoundsTypeButton.Active := False;
	end;
end;

procedure mmmFUpdateButtonProcedure(Button : TSGScreenButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	UpDateSavesComboBox();
end;end;

procedure mmmFMovieBackToMenuButtonProcedure(Button:TSGScreenButton);
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

procedure mmmFMoviePauseButtonProcedure(Button:TSGScreenButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FMoviePlayed := False;
	FMoviePauseButton.Active := False;
	FMoviePlayButton.Active := True;
end;end;

procedure mmmFMoviePlayButtonProcedure(Button:TSGScreenButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FMoviePlayed := True;
	FMoviePauseButton.Active := True;
	FMoviePlayButton.Active := False;
end;end;

procedure mmmFLoadButtonProcedure(Button:TSGScreenButton);
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
	TSGMeshSG3DMLoader.LoadModel(FMesh, FFileStream);
	FMesh.Destroy();
	FMesh:=nil;
	end;
FFileStream.Position := 0;
end; end;
const
	W = 200;
begin with TSGGasDiffusion(Button.UserPointer) do begin
	FLoadScenePanel.Visible := False;
	FFileName := FLoadComboBox.Items[FLoadComboBox.SelectItem].Caption;
	FFileName := PredStr+Catalog+DirectorySeparator+FFileName;
	FFileStream := TFileStream.Create(FFileName,fmOpenRead);
	FEnableSaving := False;
	ReadCadrs();
	FNowCadr:=0;
	FMoviePlayed:=True;
	
	FMesh:=TSGCustomModel.Create();
	FMesh.Context := Context;
	FFileStream.Position:=FArCadrs[FNowCadr];
	TSGMeshSG3DMLoader.LoadModel(FMesh, FFileStream);
	
	if FMovieBackToMenuButton = nil then
		begin
		FMovieBackToMenuButton:=TSGScreenButton.Create();
		Screen.CreateChild(FMovieBackToMenuButton);
		FMovieBackToMenuButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*0,W,FTahomaFont.FontHeight+2);
		FMovieBackToMenuButton.BoundsMakeReal();
		FMovieBackToMenuButton.Anchors:=[SGAnchRight];
		FMovieBackToMenuButton.Visible := True;
		FMovieBackToMenuButton.Active  := True;
		FMovieBackToMenuButton.Skin := FMovieBackToMenuButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
		FMovieBackToMenuButton.Caption :='В меню загрузок';
		FMovieBackToMenuButton.UserPointer:=Button.UserPointer;
		FMovieBackToMenuButton.OnChange:=TSGScreenComponentProcedure(@mmmFMovieBackToMenuButtonProcedure);
		end
	else
		begin
		FMovieBackToMenuButton.Visible := True;
		FMovieBackToMenuButton.Active  := True;
		end;
	
	if FMoviePlayButton = nil then
		begin
		FMoviePlayButton:=TSGScreenButton.Create();
		Screen.CreateChild(FMoviePlayButton);
		FMoviePlayButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*1,W,FTahomaFont.FontHeight+2);
		FMoviePlayButton.BoundsMakeReal();
		FMoviePlayButton.Anchors:=[SGAnchRight];
		FMoviePlayButton.Visible := True;
		FMoviePlayButton.Active  := False;
		FMoviePlayButton.Skin := FMoviePlayButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
		FMoviePlayButton.Caption :='Воспроизведение';
		FMoviePlayButton.UserPointer:=Button.UserPointer;
		FMoviePlayButton.OnChange:=TSGScreenComponentProcedure(@mmmFMoviePlayButtonProcedure);
		end
	else
		begin
		FMoviePlayButton.Visible := True;
		FMoviePlayButton.Active  := False;
		end;
	if FMoviePauseButton = nil then
		begin
		FMoviePauseButton:=TSGScreenButton.Create();
		Screen.CreateChild(FMoviePauseButton);
		FMoviePauseButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*2,W,FTahomaFont.FontHeight+2);
		FMoviePauseButton.BoundsMakeReal();
		FMoviePauseButton.Anchors:=[SGAnchRight];
		FMoviePauseButton.Visible := True;
		FMoviePauseButton.Active  := True;
		FMoviePauseButton.Skin := FMoviePauseButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
		FMoviePauseButton.Caption :='Пауза';
		FMoviePauseButton.UserPointer:=Button.UserPointer;
		FMoviePauseButton.OnChange:=TSGScreenComponentProcedure(@mmmFMoviePauseButtonProcedure);
		end
	else
		begin
		FMoviePauseButton.Visible := True;
		FMoviePauseButton.Active  := True;
		end;
end;end;
procedure mmmFEnableLoadButtonProcedure(Button:TSGScreenButton);
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
procedure mmmFRedactrReliefOpenFileButton(Button:TSGScreenButton);
var
	FileWay : String = '';
	IsInFullscreen : Boolean = False;
	T, E : TSGBoolean;
begin with TSGGasDiffusion(Button.UserPointer) do begin
IsInFullscreen := Context.Fullscreen;
if IsInFullscreen then
	begin
	Context.Fullscreen := False;
	Context.Messages(); //Обязательно 3 раза, иначе hWindow не обновляется
	Context.Messages();
	Context.Messages();
	end;
FileWay := Context.FileOpenDialog('Выберите файл рельефа','Файлы рельефа(*.sggdrf)'+#0+'*.sggdrf'+#0+'All files(*.*)'+#0+'*.*'+#0+#0);
if (FileWay <> '') and (SGFileExists(FileWay)) then
	begin
	T := FRelefRedactor.SingleRelief^.FType;
	E := FRelefRedactor.SingleRelief^.FEnabled;
	FRelefRedactor.SingleRelief^.Clear();
	FRelefRedactor.SingleRelief^.Load(FileWay);
	FRelefRedactor.SingleRelief^.FType := T;
	FRelefRedactor.SingleRelief^.FEnabled := E;
	FRelefOptionPanel.Children[1].Caption := 'Статус рельефа:Загружен('+SGFileName(FileWay)+'.'+SGDownCaseString(SGFileExpansion(FileWay))+')';
	(FRelefOptionPanel.Children[1] as TSGScreenLabel).TextColor := SGVertex4fImport(0,1,0,1);
	end;
if IsInFullscreen then
	Context.Fullscreen := True;
end; end;
procedure mmmFRedactrReliefSaveFileButton(Button:TSGScreenButton);
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
FileWay := Context.FileSaveDialog('Выберите имя файла для сохранения рельефа','Файлы рельефа(*.sggdrf)'+#0+'*.sggdrf'+#0+'All files(*.*)'+#0+'*.*'+#0+#0,'sggdrf');
WriteLn('FileWay=',FileWay);
if (FileWay <> '') then
	begin
	FRelefRedactor.SingleRelief^.Save(FileWay);
	end;
if IsInFullscreen then
	Context.Fullscreen := True;
end; end;
procedure mmmFRedactrReliefBackButton(Button:TSGScreenButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
FRelefRedactor.SetActiveSingleRelief();
FRelefOptionPanel.AddToLeft  (((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width) div 2) + 5);
FRelefOptionPanel.Visible := False;
FBoundsOptionsPanel.Active := True;
FNewScenePanel.AddToLeft     (((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width) div 2) + 5);
FBoundsOptionsPanel.AddToLeft(((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width) div 2) + 5);
end;end;

procedure mmmFRedactorBackButton(Button:TSGScreenButton);
begin with TSGGasDiffusion(Button.UserPointer) do begin
Button.Visible := False;
Button.Active := False;
if FRelefOptionPanel <> nil then
	begin
	FRelefOptionPanel.Children[1].Caption := 'Статус рельефа:теоритически изменен';
	(FRelefOptionPanel.Children[1] as TSGScreenLabel).TextColor := SGVertex4fImport(0,1,0,1);
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

procedure mmmFRedactrReliefRedactrReliefButton(Button:TSGScreenButton);
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

procedure mmmFRedactrRelief(Button:TSGScreenButton);
var
	FConstWidth : LongWOrd = 300;
begin with TSGGasDiffusion(Button.UserPointer) do begin
FRelefRedactor.SetActiveSingleRelief(Button.Parent.IndexOf(Button) - 6);
if (FRelefOptionPanel = nil) then
	begin
	FRelefOptionPanel := SGCreatePanel(Screen, FConstWidth,155, True, True, Button.UserPointer);
	FRelefOptionPanel.AddToLeft(((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width)div 2) + 5);
	FRelefOptionPanel.AddToTop(285);
	Screen.LastChild.BoundsMakeReal();
	FRelefOptionPanel.AddToLeft(- ((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width)div 2) - 5);
	Screen.LastChild.VisibleTimer := 0.3;
	
	SGCreateLabel(FRelefOptionPanel, 'Статус рельефа:Неопределен', 10,10,FRelefOptionPanel.Width - 30,19, FTahomaFont, True, True, Button.UserPointer);
	SGCreateButton(FRelefOptionPanel, 'Загрузить рельеф из файла', 10,10+(19+5)*1,FRelefOptionPanel.Width - 30,19, TSGScreenComponentProcedure(@mmmFRedactrReliefOpenFileButton),
		FTahomaFont, True, False, Button.UserPointer);
	SGCreateButton(FRelefOptionPanel, 'Сохранить рельеф в файл', 10,10+(19+5)*2,FRelefOptionPanel.Width - 30,19, TSGScreenComponentProcedure(@mmmFRedactrReliefSaveFileButton),
		FTahomaFont, True, False, Button.UserPointer);
	SGCreateButton(FRelefOptionPanel, 'Редактировать рельеф', 10,10+(19+5)*3,FRelefOptionPanel.Width - 30,19, TSGScreenComponentProcedure(@mmmFRedactrReliefRedactrReliefButton),
		FTahomaFont, True, False, Button.UserPointer).Active := {$IFDEF MOBILE}False{$ELSE}True{$ENDIF};
	SGCreateButton(FRelefOptionPanel, 'Назад', 10,10+(19+5)*4,FRelefOptionPanel.Width - 30,19, TSGScreenComponentProcedure(@mmmFRedactrReliefBackButton),
		FTahomaFont, True, False, Button.UserPointer);
	end
else
	begin
	FRelefOptionPanel.Visible := True;
	FRelefOptionPanel.Active := True;
	FRelefOptionPanel.AddToLeft(- ((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width)div 2) - 5);
	FRelefOptionPanel.VisibleTimer := 0.3;
	end;
(FRelefOptionPanel.Children[1] as TSGScreenLabel).TextColor := SGVertex4fImport(1,0,0,1);
FNewScenePanel.AddToLeft(- ((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width)div 2) - 5);
FBoundsOptionsPanel.AddToLeft(- ((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width)div 2) - 5);
FBoundsOptionsPanel.Active := False;
end; end;
procedure mmmChangeBoundTypeComboBoxProcedure(b,c : LongInt;a : TSGScreenComboBox);
var
	index : LongInt;
begin with TSGGasDiffusion(a.UserPointer) do begin
index := a.Parent.IndexOf(a);
if index <> -1 then
	begin
	(a.Parent.Children[index + 7] as TSGScreenButton).Active := c > 0;
	FRelief.FData[index].FEnabled := c > 0;
	FRelief.FData[index].FType := c > 1
	end;
end; end;
procedure mmmFBoundsBackButtonProcedure(Button:TSGScreenButton);
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

procedure mmmFBoundsTypeButtonProcedure(Button:TSGScreenButton);
var
	FConstWidth : LongWord = 500;
	FConstLoadMeshButtonWidth : LongWord = 120;
	FConstLabelsWidth : LongWOrd = 90;

procedure CreteCOmboBox(const vIndex : LongWord; const vPanel : TSGScreenPanel);
begin with TSGGasDiffusion(Button.UserPointer) do begin
with SGCreateComboBox(FBoundsOptionsPanel, 10 + FConstLabelsWidth + 10,5+(19+5)*vIndex,FConstWidth-50-FConstLoadMeshButtonWidth - FConstLabelsWidth,19,
	TSGScreenComboBoxProcedure(@mmmChangeBoundTypeComboBoxProcedure), FTahomaFont, True, True, Button.UserPointer) do
	begin
	CreateItem('Стенкa пропускают газ');
	CreateItem('Стенкa не пропускают газ');
	CreateItem('Газ липнет к стенкe');
	SelectItem := 0;
	end;
end;end;
procedure CreteLabel(const vIndex : LongWord; const vPanel : TSGScreenPanel);
var
	ScreenLabel : TSGScreenLabel;
begin with TSGGasDiffusion(Button.UserPointer) do begin
ScreenLabel := SGCreateLabel(FBoundsOptionsPanel, '', 10 ,5+(19+5)*vIndex,FConstLabelsWidth,19, FTahomaFont, True, True, Button.UserPointer);
case vIndex of
0 : ScreenLabel.Caption := 'Верхняя';
1 : ScreenLabel.Caption := 'Нижня';
2 : ScreenLabel.Caption := 'Левая';
3 : ScreenLabel.Caption := 'Правая';
4 : ScreenLabel.Caption := 'Задняя';
5 : ScreenLabel.Caption := 'Передняя';
end;
end;end;
procedure CreteLoadMeshButton(const vIndex : LongWord; const vPanel : TSGScreenPanel);
begin with TSGGasDiffusion(Button.UserPointer) do begin
SGCreateButton(FBoundsOptionsPanel, 'Настроить рельеф', FConstWidth - 20 - FConstLoadMeshButtonWidth,5+(19+5)*vIndex,FConstLoadMeshButtonWidth,19, 
	TSGScreenComponentProcedure(@mmmFRedactrRelief), FTahomaFont, True, True, Button.UserPointer).Active := False;
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
	FBoundsOptionsPanel := SGCreatePanel(Screen, FConstWidth,185, True, True, Button.UserPointer);
	FBoundsOptionsPanel.AddToLeft( FConstWidth + 5);
	FBoundsOptionsPanel.AddToTop( FConstHeight + 5);
	Screen.LastChild.BoundsMakeReal();
	FBoundsOptionsPanel.AddToLeft(- FConstWidth - 5);
	Screen.LastChild.VisibleTimer := 0.3;
	
	for i := 0 to 5 do
		CreteCOmboBox(i,FBoundsOptionsPanel);
	for i := 0 to 5 do
		CreteLoadMeshButton(i,FBoundsOptionsPanel);
	for i := 0 to 5 do
		CreteLabel(i,FBoundsOptionsPanel);
	
	SGCreateButton(FBoundsOptionsPanel, 'Назад', (FConstWidth - FConstLoadMeshButtonWidth )div 2,149,FConstLoadMeshButtonWidth,19,
		TSGScreenComponentProcedure(@mmmFBoundsBackButtonProcedure), FTahomaFont, True, True, Button.UserPointer);
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
procedure mmmFBackButtonProcedure(Button:TSGScreenButton);
begin
with TSGGasDiffusion(Button.UserPointer) do
	begin
	FLoadScenePanel.Visible := False;
	FNewScenePanel .Visible := True;
	end;
end;
procedure mmmFOpenSaveDir(Button:TSGScreenButton);
begin
{$IFDEF MSWINDOWS}
	Exec('explorer.exe','"'+PredStr+Catalog+'"');
	{$ENDIF}
end;

function mmmFEdgeEditTextTypeFunction(const Self : TSGScreenEdit) : TSGBoolean;
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
	ar : TSGStringList = nil;
	i : TSGLongWord;
	ExC : Boolean = False;
begin
FLoadComboBox.ClearItems();
ar := SGDirectoryFiles(PredStr + Catalog + '/', '*.GDS');
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
		FConchLabels[i] := SGCreateLabel(Screen, '', False, 5,50+i*22,400,20, FTahomaFont, True, True);
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

constructor TSGGasDiffusion.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
{$IFDEF RELIEFDEBUG}
	FInReliafDebug        := 0;
	{$ENDIF}
FSourseChangeFlag         := 0;
FSourseChangeFlag2        := 0;
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
FCamera.Zum := Render.Height/Render.Width;

FTahomaFont:=TSGFont.Create(SGFontDirectory + DirectorySeparator + {$IFDEF MOBILE}'Times New Roman.sgf'{$ELSE}'Tahoma.sgf'{$ENDIF});
FTahomaFont.SetContext(Context);
FTahomaFont.Loading();
FTahomaFont.ToTexture();

FStartingProgressBar := TSGScreenProgressBar.Create();
Screen.CreateChild(FStartingProgressBar);
Screen.LastChild.SetBounds(Render.Width div 2 - 151,Render.Height div 2 - 100, 300, 20);
Screen.LastChild.BoundsMakeReal();
Screen.LastChild.Visible:=False;
FStartingProgressBar.Progress := 0;

FRedactorBackButton := SGCreateButton(Screen, 'Назад', Render.Width div 2 - 75,5,130,20, TSGScreenComponentProcedure(@mmmFRedactorBackButton),
	FTahomaFont, False, True, Self);
FNewScenePanel := SGCreatePanel(Screen, 400,110+26, True, True, Self);
SGCreateLabel(FNewScenePanel, 'Создание новой сцены', 5,0,275+100,20, FTahomaFont, True, True);
SGCreateLabel(FNewScenePanel, 'Количество точек:', False, 5,19,280,20, FTahomaFont, True, True);
FNumberLabel := SGCreateLabel(FNewScenePanel, '', False, 170,19,180,20, FTahomaFont, True, True);
FStartSceneButton := SGCreateButton(FNewScenePanel, 'Старт', 10,44,80,20, TSGScreenComponentProcedure(@mmmFStartSceneButtonProcedure),
	FTahomaFont, True, True, Self);
FEdgeEdit := SGCreateEdit(FNewScenePanel, '75', TSGScreenEditTextTypeFunction(@mmmFEdgeEditTextTypeFunction), 118,19,50,20, FTahomaFont, True, True, Self);
FEnableLoadButton := SGCreateButton(FNewScenePanel, 'Загрузка сохраненной сцены/повтора', 100,44,278,20, TSGScreenComponentProcedure(@mmmFEnableLoadButtonProcedure),
	FTahomaFont, True, True, Self);

FEnableOutputComboBox := SGCreateComboBox(FNewScenePanel, 10,44+26,380-10,19, {TSGScreenComboBoxProcedure(@FEnableOutputComboBoxProcedure),} 
	FTahomaFont, True, True, Self);
FEnableOutputComboBox.CreateItem('Включить непрерывное сохранение эмуляции');
FEnableOutputComboBox.CreateItem('Не включать непрерывное сохранение эмуляции');
FEnableOutputComboBox.SelectItem := {$IFDEF RELIEFDEBUG}1{$ELSE}{$IFDEF MOBILE}1{$ELSE}0{$ENDIF}{$ENDIF};

FBoundsTypeButton := SGCreateButton(FNewScenePanel, 'Настроить поведение газа на границах',10,44+26+25,380-10,19,TSGScreenComponentProcedure(@mmmFBoundsTypeButtonProcedure),
	FTahomaFont, True, True, Self);
FLoadScenePanel := SGCreatePanel(Screen, 440,105, False, True,  Self);
SGCreateLabel(FLoadScenePanel, 'Загрузка сохраненной сцены/повтора', 5,0,275+140,20, FTahomaFont, False, True);

FLoadComboBox := SGCreateComboBox(FLoadScenePanel, 5,21,480-60,19, {TSGScreenComboBoxProcedure(@FLoadComboBoxProcedure),} FTahomaFont, False, True, Self);
FLoadComboBox.SelectItem := -1;

FBackButton := SGCreateButton(FLoadScenePanel, 'Назад', 10,44,130,20, TSGScreenComponentProcedure(@mmmFBackButtonProcedure),
	FTahomaFont, False, True, Self);
FUpdateButton := SGCreateButton(FLoadScenePanel, 'Обновить', 145,44,130,20, TSGScreenComponentProcedure(@mmmFUpdateButtonProcedure),
	FTahomaFont, False, True, Self);
FLoadButton := SGCreateButton(FLoadScenePanel, 'Загрузить', 145+135,44,130,20, TSGScreenComponentProcedure(@mmmFLoadButtonProcedure),
	FTahomaFont, False, True, Self);
SGCreateButton(FLoadScenePanel, 'Открыть папку с сохранениями', 5,44+24,420,20, TSGScreenComponentProcedure(@mmmFOpenSaveDir),
	FTahomaFont, False, True, Self);
FInfoLabel := SGCreateLabel(Screen, '', 5,Render.Height-25,Render.Width-10,20, FTahomaFont, [SGAnchBottom], True, True);
end;

procedure TSGGasDiffusion.UpDateChangeSourses();
var
	b, a : TSGVertex3f;
	s, Plane : TSGLongWord;
function Range(const i : TSGLongInt):TSGLongWord;
begin
if i >= FCube.Edge then
	Result := FCube.Edge - 1
else if i < 0 then
	Result := 0
else
	Result := i;
end;
begin
if ((FCube.FSourses=nil) or (Length(FCube.FSourses)=0)) then
	Exit;
s := (FAddNewSoursePanel.Children[1] as TSGScreenComboBox).SelectItem;
a.Import(2*FCube.FSourses[s].FCoord.z/FCube.Edge-1,
		 2*FCube.FSourses[s].FCoord.y/FCube.Edge-1,
		 2*FCube.FSourses[s].FCoord.x/FCube.Edge-1);
Render.Color3f(1,$A5/256,0);
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
	b := SGGetVertexUnderPixel(Render,Context.CursorPosition());
	if Abs(b) < 2 then
		begin
		if FSourseChangeFlag = 0 then
			begin
			Plane := Byte(Abs(a.y-b.y) < 0.11);
			if Plane=0 then
				Plane := Byte(Abs(a.z-b.z) < 0.11)*2;
			if Plane=0 then
				Plane := Byte(Abs(a.x-b.x) < 0.11)*3;
			if (Context.CursorKeyPressed() = SGLeftCursorButton) and (Context.CursorKeyPressedType() = SGDownKey) then
				begin
				if Plane <> 0 then
					begin
					FSourseChangeFlag := s + 1;
					FSourseChangeFlag2 := Plane - 1;
					end;
				end;
			end
		else if (Context.CursorKeyPressedType() <> SGUpKey) then
			begin
			case FSourseChangeFlag2 of
			0:FCube.FSourses[FSourseChangeFlag-1].FCoord.Import(
				FCube.FSourses[FSourseChangeFlag-1].FCoord.x,
				Range(Trunc((b.y+0.99)/2*FCube.Edge)),
				FCube.FSourses[FSourseChangeFlag-1].FCoord.z);
			1:FCube.FSourses[FSourseChangeFlag-1].FCoord.Import(
				Range(Trunc((b.z+0.99)/2*FCube.Edge)),
				FCube.FSourses[FSourseChangeFlag-1].FCoord.y,
				FCube.FSourses[FSourseChangeFlag-1].FCoord.z);
			2:FCube.FSourses[FSourseChangeFlag-1].FCoord.Import(
				FCube.FSourses[FSourseChangeFlag-1].FCoord.x,
				FCube.FSourses[FSourseChangeFlag-1].FCoord.y,
				Range(Trunc((b.x+0.99)/2*FCube.Edge)));
			end;
			FCube.UpDateSourses();
			FMesh.Destroy();
			FMesh:=FCube.CalculateMesh(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
			end
		else
			FSourseChangeFlag := 0;
		end
	else
		FSourseChangeFlag := 0;
	{$ENDIF}
Render.Color3f(1,1,1);
end;

procedure TSGGasDiffusion.Paint();
procedure DrawSechenie();
var
	a,b,c,d : TSGVertex3f;
procedure DrawQuadSec(const Primitive : TSGLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Render.BeginScene(Primitive);
Render.Vertex(a);
Render.Vertex(b);
Render.Vertex(c);
Render.Vertex(d);
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
(FUsrSechPanel.Children[2] as TSGScreenProgressBar).Visible := False;
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
	if FSourseChangeFlag=0 then
		FCamera.Change();
	FCamera.InitMatrix();
	FMesh.Paint();
	if (FSecheniePanel<>nil) then
		DrawSechenie();
	if FDiffusionRuned then
		begin
		if FEnableSaving then 
			begin
			if (Render.RenderType in [SGRenderDirectX9,SGRenderDirectX8]) then
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
		TSGMeshSG3DMLoader.LoadModel(FMesh, FFileStream);
		if (Render.RenderType in [SGRenderDirectX9,SGRenderDirectX8]) then
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

initialization
begin
SGRegisterDrawClass(TSGGasDiffusion);
end;

end.
