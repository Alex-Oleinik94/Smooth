{$INCLUDE Smooth.inc}

{$DEFINE RELIEFDEBUG}

unit SmoothGasDiffusion;

interface
uses
	 Dos
	,SysUtils
	,Classes
	
	,SmoothBase
	,SmoothThreads
	,Smooth3dObject
	,SmoothVertexObject
	,SmoothContext
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothRenderBase
	,SmoothCommonStructs
	,SmoothFont
	,SmoothImage
	,SmoothBitMapBase
	,SmoothBitMap
	,SmoothGasDiffusionReliefRedactor
	,SmoothScreenBase
	,SmoothExtensionManager
	,SmoothFileUtils
	,SmoothCamera
	,SmoothScreenClasses
	;

const
	PredStr = 
		{$IFDEF ANDROID}
			'sdcard/.Smooth/'
		{$ELSE}
			''
			{$ENDIF};
	Catalog = 'Gas Diffusion Saves';
type
	TSGazType = object
		FColor           : TSColor4f;
		FArComponentOwners       : array[0..1] of LongInt;
		FDinamicQuantity : LongWord;
		procedure Create(const r,g,b: Single;const a: Single = 1;const p1 : LongInt = -1; const p2: LongInt = -1);
		end;
	
	TSSourseType = object
		FGazTypeIndex : TSLongWord;
		FCoord        : TSPoint3int32;
		FRadius       : TSLongWord;
		end;
	
	TSSubsidenceVertex = object
		FCount       : TSLongWord;
		FCoords      : TSPoint3int32;
		FVertexIndex : TSLongWord;
		FRelief      : TSLongWord;
		end;
	TSSubsidenceVertices = type packed array of TSSubsidenceVertex;
	
	TSGGDC = ^ TSByte;
	TSGasDiffusionCube = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		procedure Paint();override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
			public
		procedure UpDateSourses();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure InitCube(const Edge : TSLongWord; const VProgress : PSScreenProgressBarFloat = nil);
		procedure UpDateCube();
		function  Calculate3dObject(const VRelief : PSGasDiffusionRelief = nil{$IFDEF RELIEFDEBUG};const FInReliafDebug : TSLongWord = 0{$ENDIF}) : TSCustomModel;
		procedure ClearGaz();
		procedure InitReliefIndexes(const VProgress : PSScreenProgressBarFloat = nil);
			public
		function Cube (const x, y, z : Word) : TSGGDC;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ReliefCubeIndex (const x,y,z : Word):TSGGDC;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function Copy() : TSGasDiffusionCube;
			public
		FCube       : TSGGDC;						// ^byte - кубик
		FReliefCubeIndex : TSGGDC;
		FCubeCoords : packed array of
			TSVertex3f;							// 3хмерные координаты каждой точки из FCube
		FEdge       : TSLongWord;					// размерность FCube (FEdge * FEdge * FEdge)
		FGazes      : packed array of TSGazType;	// типы газа
		FSourses    : packed array of TSSourseType;// источники газа
		FDinamicQuantityMoleculs : LongWord;		// количество точек газа на данный момент
		FFlag       : Boolean;						// флажок этапа итерации. этот алгоритм работает в 2 этапа
		FRelief     : PSGasDiffusionRelief;
		FSubsidenceVertices : TSSubsidenceVertices;
			public
		property Edge : TSLongWord read FEdge;
		end;
type
	TSGasDiffusion = class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		procedure Paint();override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
			private
		FCamera         : TSCamera;
		F3dObject           : TSCustomModel;
		FCube           : TSGasDiffusionCube;
		FFileName       : TSString;
		FFileStream     : TFileStream;
		FDiffusionRuned : TSBoolean;
		FEnableSaving   : TSBoolean;
		FRelefRedactor  : TSGasDiffusionReliefRedactor;
		FRelief         : TSGasDiffusionRelief;
		
		//Панели, кнопки и т п
		FTahomaFont        : TSFont; 						// шрифт
		FLoadScenePanel,									// панель загрузки повтора
		FBoundsOptionsPanel,								// панель опций границ
			FRelefOptionPanel,								// опции рельефа границы
			FNewScenePanel : TSScreenPanel;				// панель нового проэкта
		
		FStartingProgressBar : TSScreenProgressBar;
		FStartingThread      : TSThread;
		FStartingFlag        : LongInt;
		
		// Перетаскивание источников
		FSourseChangeFlag    : TSLongWord;                 //Number of sourse + 1
		FSourseChangeFlag2   : TSLongWord;                 //Plane(0,1,2)
		
		//New Panel
		FEdgeEdit               : TSScreenEdit;
		FNumberLabel            : TSScreenLabel;
		FStartSceneButton,
		FBoundsTypeButton,
			FEnableLoadButton   : TSScreenButton;
		FEnableOutputComboBox   : TSScreenComboBox;
		
		//Load Panel
		FLoadComboBox      : TSScreenComboBox;
		FBackButton, 
			FUpdateButton, 
			FLoadButton    : TSScreenButton;
		
		//Экран
		FInfoLabel : TSScreenLabel;
		
			(* Сечение *)
		
		FNewSecheniePanel, 						// Содержит кнопку и FPlaneComboBox
			FSecheniePanel : TSScreenPanel;	// Cодержит картинку сечения
		FPlaneComboBox : TSScreenComboBox;			// вычесление осей координат для FPointerSecheniePlace
		FPointerSecheniePlace : TSSingle;		// (-1..1) значение места сечения
		FSechenieImage : TSImage; 				// Картинка сечения
		FImageSechenieBounds : LongWord; 		// Действительное расширение картинки сечения
		FSechenieUnProjectVertex : TSVertex3f; // For Un Project
		
		FUsrSechPanel  : TSScreenPanel;
		FUsrSechImage : TSImage;
		FUsrSechImageForThread : TSImage;
		FUsrImageThread : TSThread;
		FUsrRange: LongWord;
		FUsrSechThread : TSThread;
		FCubeForUsr : TSGasDiffusionCube;
		FUpdateUsrAfterThread : Boolean;
		
			(*Экран моделирования*)
		FConchLabels : packed array of
			TSScreenLabel;
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
			FRedactorBackButton: TSScreenButton;
		
		FAddNewSoursePanel : TSScreenPanel;
		FAddNewGazPanel : TSScreenPanel;
			(*Повтор*)
		
		//FFileStream  : TFileStream;
		//FFileName    : TSString;
		FArCadrs       : packed array of TSQuadWord;
		FNowCadr       : TSLongWord;
		FMoviePlayed   : TSBoolean;
		
		//Экран повтора
		FMoviePauseButton,
			FMovieBackToMenuButton,
			FMoviePlayButton : TSScreenButton;
		
		{$IFDEF RELIEFDEBUG}
			private
		FInReliafDebug : TSLongWord;
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
		function GetPointColorCube( const i,ii,iii : LongWord; const VCube : TSGasDiffusionCube):Byte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothLists
	,SmoothMathUtils
	,SmoothRenderInterface
	,SmoothMatrix
	,SmoothCommon
	,Smooth3dObjectS3dm
	,SmoothContextUtils
	,SmoothScreen_Edit
	,SmoothRectangleWithRoundedCorners
	,SmoothImageFormatDeterminer
	;

//Algorithm

procedure TSGazType.Create(const r,g,b: Single;const a: Single = 1;const p1 : LongInt = -1; const p2: LongInt = -1);
begin
FColor.Import(r,g,b,a);
FArComponentOwners[0]:=p1;
FArComponentOwners[1]:=p2;
end;

constructor TSGasDiffusionCube.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FEdge   := 0;
FCube   := nil;
FSourses:= nil;
FGazes  := nil;
FCubeCoords := nil;
FRelief := nil;
FSubsidenceVertices := nil;
end;

procedure TSGasDiffusionCube.Paint();
begin

end;

function TSGasDiffusionCube.Copy() : TSGasDiffusionCube;
var
	i : LongWord;
begin
Result := TSGasDiffusionCube.Create(Context);
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

destructor TSGasDiffusionCube.Destroy();
begin
if FCubeCoords<>nil then
	SetLength(FCubeCoords,0);
if FCube<>nil then
	begin
	FreeMem(FCube);
	FCube:=nil;
	end;
if FSubsidenceVertices <> nil then
	SetLength(FSubsidenceVertices, 0);
inherited;
end;

class function TSGasDiffusionCube.ClassName():TSString;
begin
Result:='TSGasDiffusionCube';
end;

procedure TSGasDiffusionCube.ClearGaz();
begin
FillChar(FCube^,FEdge*FEdge*FEdge,0);
UpDateCube();
end;

procedure TSGasDiffusionCube.InitCube(const Edge : TSLongWord; const VProgress : PSScreenProgressBarFloat = nil);
const
	o = 1.98;
var
	i : LongWord;
	S3dObjectenie : TSSingle;
	FArRandomSm : array [0..9] of TSVertex3f;
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
S3dObjectenie:= 1/FEdge;
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
		S3dObjectenie + o*(i mod FEdge)/(FEdge - 1) - 1,
		S3dObjectenie + o*((i div FEdge) mod FEdge)/(FEdge - 1) - 1,
		S3dObjectenie + o*((i div FEdge) div FEdge)/(FEdge - 1) - 1);
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

function TSGasDiffusionCube.ReliefCubeIndex (const x,y,z : Word):TSGGDC;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=@FReliefCubeIndex[(x*FEdge+y)*FEdge+z];
end;

function TSGasDiffusionCube.Cube (const x,y,z:Word):TSGGDC;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=@FCube[(x*FEdge+y)*FEdge+z];
end;

procedure TSGasDiffusionCube.InitReliefIndexes(const VProgress : PSScreenProgressBarFloat = nil);

function Invert(const i : LongWord; const Inverting : TSBoolean = True) : TSFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Inverting then
	Result := (FEdge - 1 - i)/(Edge-1)*2 - 1
else
	Result := i/(Edge-1)*2 - 1
end;

function CoordFromXYZ(const x,y,z : LongWord; const n : LongWord):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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
	ab : TSFloat;
begin
ab := Abs(b-a);
Result := Abs(Abs(p-a) + Abs(p-b) - ab) < ab * SZero * 200;
end;

function ScalePointToTriangle3D(const t1,t2,t3,v:TSVertex2f; const t1z,t2z,t3z : Single):Single;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	t1t2, t2t3, t3t1, vt1, vt2, vt3, s : TSFloat;
begin
t1t2 := Abs(t1 - t2);
t2t3 := Abs(t2 - t3);
t3t1 := Abs(t3 - t1);

vt1 := Abs(v - t1);
vt2 := Abs(v - t2);
vt3 := Abs(v - t3);

s := STriangleSize(t1t2, t2t3, t3t1);

Result := 
	(STriangleSize(t2t3, vt3, vt2)/s)*t1z + 
	(STriangleSize(t3t1, vt1, vt3)/s)*t2z + 
	(STriangleSize(t1t2, vt1, vt2)/s)*t3z;
end;

function PointInTriangleZ(const t1,t2,t3,v:TSVertex3f;const b : Single):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SIsVertexOnTriangle( 
	SVertex2fImport(t1.x,t1.y),
	SVertex2fImport(t2.x,t2.y),
	SVertex2fImport(t3.x,t3.y),
	SVertex2fImport(v.x,v.y));
if Result then
	Result := PointBeetWeen(
		b,
		ScalePointToTriangle3D(
			SVertex2fImport(t1.x,t1.y),
			SVertex2fImport(t2.x,t2.y),
			SVertex2fImport(t3.x,t3.y),
			SVertex2fImport(v.x,v.y),
			t1.z,t2.z,t3.z),
		v.z);
end;

function PointInTriangleX(const t1,t2,t3,v:TSVertex3f;const b : Single):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := SIsVertexOnTriangle( 
	SVertex2fImport(t1.z,t1.y),
	SVertex2fImport(t2.z,t2.y),
	SVertex2fImport(t3.z,t3.y),
	SVertex2fImport(v.z,v.y));
if Result then
	Result := PointBeetWeen(
		b,
		ScalePointToTriangle3D(
			SVertex2fImport(t1.z,t1.y),
			SVertex2fImport(t2.z,t2.y),
			SVertex2fImport(t3.z,t3.y),
			SVertex2fImport(v.z,v.y),
			t1.x,t2.x,t3.x),
		v.x);
end;

function PointInTriangleY(const t1,t2,t3,v:TSVertex3f;const b : Single):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin 
Result := SIsVertexOnTriangle( 
	SVertex2fImport(t1.x,t1.z),
	SVertex2fImport(t2.x,t2.z),
	SVertex2fImport(t3.x,t3.z),
	SVertex2fImport(v.x,v.z));
if Result then
	Result := PointBeetWeen(
		b,
		ScalePointToTriangle3D(
			SVertex2fImport(t1.x,t1.z),
			SVertex2fImport(t2.x,t2.z),
			SVertex2fImport(t3.x,t3.z),
			SVertex2fImport(v.x,v.z),
			t1.y,t2.y,t3.y),
		v.y);
end;

function PointInTriangle(const t1,t2,t3,v,n:TSVertex3f):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if SIsVertexOnLine(t1,t2,v) or SIsVertexOnLine(t1,t3,v) or SIsVertexOnLine(t2,t3,v) then
	begin
	Result := True;
	Exit;
	end;
if (abs(n.x)<SZero) and (abs(n.y)<SZero) then
	Result := PointInTriangleZ(t1,t2,t3,v,n.z)
else if (abs(n.z)<SZero) and (abs(n.y)<SZero) then
	Result := PointInTriangleX(t1,t2,t3,v,n.x)
else if (abs(n.x)<SZero) and (abs(n.z)<SZero) then
	Result := PointInTriangleY(t1,t2,t3,v,n.y);
end;


function PointToTriangleZ(const t1,t2,t3,v:TSVertex3f;const b : Single):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(
	v.x, v.y, 
	ScalePointToTriangle3D(
		SVertex2fImport(t1.x,t1.y),
		SVertex2fImport(t2.x,t2.y),
		SVertex2fImport(t3.x,t3.y),
		SVertex2fImport(v.x,v.y),
		t1.z,t2.z,t3.z)
	);
end;

function PointToTriangleX(const t1,t2,t3,v:TSVertex3f;const b : Single):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(
	ScalePointToTriangle3D(
			SVertex2fImport(t1.z,t1.y),
			SVertex2fImport(t2.z,t2.y),
			SVertex2fImport(t3.z,t3.y),
			SVertex2fImport(v.z,v.y),
			t1.x,t2.x,t3.x),
	v.y, v.z);
end;

function PointToTriangleY(const t1,t2,t3,v:TSVertex3f;const b : Single):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin 
Result.Import( v.x,
	ScalePointToTriangle3D(
			SVertex2fImport(t1.x,t1.z),
			SVertex2fImport(t2.x,t2.z),
			SVertex2fImport(t3.x,t3.z),
			SVertex2fImport(v.x,v.z),
			t1.y,t2.y,t3.y),
	v.z);
end;

function PointToTriangle(const t1,t2,t3,v,n:TSVertex3f):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (abs(n.x)<SZero) and (abs(n.y)<SZero) then
	Result := PointToTriangleZ(t1,t2,t3,v,n.z)
else if (abs(n.z)<SZero) and (abs(n.y)<SZero) then
	Result := PointToTriangleX(t1,t2,t3,v,n.x)
else if (abs(n.x)<SZero) and (abs(n.z)<SZero) then
	Result := PointToTriangleY(t1,t2,t3,v,n.y)
else
	Result.Import();
end;

function PointInPolygone(const sr : PSGasDiffusionSingleRelief; const index : LongWord; const v : TSVertex3f; const n : TSVertex3f;const ReliefIndex : Byte):Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

function VertexFromIndex(const index : LongWord):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

function ProjectingPointToRelief(const v,n : TSVertex3f;const sr : PSGasDiffusionSingleRelief;const ReliefIndex : TSLongWord):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

function PostInvert(const index : TSLongWord; const v : TSVertex3f):TSVertex3f;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case index of
0,1:Result.Import(v.x,(-1)*v.y,(-1)*v.z);
2,3:Result.Import(v.x,v.y,v.z);
4,5:Result.Import(v.x,v.y,v.z);
end;
end;

var
	FRCI : TSGGDC = nil;

function RCI (const x,y,z : Word):TSGGDC;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=@FRCI[(x*FEdge+y)*FEdge+z];
end;

var
	i, j : TSLongWord;
	i1, i2, i3, AllPolygoneSize, PolygoneIndex, ii : TSLongWord;
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
	if (not TSBoolean(FRCI[i])) then
		FReliefCubeIndex[i] := 0;
FreeMem(FRCI);
// Алгоритм для оседающих граней
if FRelief <> nil then
	begin
	if (FSubsidenceVertices <> nil) then
		SetLength(FSubsidenceVertices, 0);
	FSubsidenceVertices := nil;
	for j := 0 to 5 do
		begin
		if FRelief^.FData[j].FEnabled and FRelief^.FData[j].FType then
			begin
			
			FRelief^.FData[j].F3dObject := TS3DObject.Create();
			FRelief^.FData[j].F3dObject.Context := Context;
			FRelief^.FData[j].F3dObject.HasNormals := False;
			FRelief^.FData[j].F3dObject.HasTexture := False;
			FRelief^.FData[j].F3dObject.HasColors  := True;
			FRelief^.FData[j].F3dObject.EnableCullFace := False;
			FRelief^.FData[j].F3dObject.VertexType := S3dObjectVertexType3f;
			FRelief^.FData[j].F3dObject.SetColorType (S3dObjectColorType4b);
			FRelief^.FData[j].F3dObject.Vertices   := Edge * Edge;
			FRelief^.FData[j].F3dObject.AddFaceArray();
			FRelief^.FData[j].F3dObject.PolygonsType[0] := SR_TRIANGLES;
			
			FRelief^.FData[j].F3dObject.Faces[0] := (Edge-1) * (Edge-1) * 2;
			for i := 0 to Edge - 2 do 
				for ii := 0 to Edge - 2 do
					begin
					FRelief^.FData[j].F3dObject.SetFaceTriangle
						(0,(i * (Edge - 1) + ii) * 2 + 0, i * Edge + ii, i * Edge + (ii+1), (i+1) * Edge + ii+1);
					FRelief^.FData[j].F3dObject.SetFaceTriangle
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
					
					while (not TSBoolean(ReliefCubeIndex(i1+a1*l, i2+a2*l, i3+a3*l))) and (l>=0) and (l<=Edge - 1) do
						l += k;
					
					FRelief^.FData[j].F3dObject.ArVertex3f[i * Edge + ii]^ := PostInvert(j, ProjectingPointToRelief(
						SVertex3fImport(
							(i1+a1*l)/(Edge-1)*2-1,
							(i2+a2*l)/(Edge-1)*2-1,
							(i3+a3*l)/(Edge-1)*2-1),
						VertexFromIndex(j),
						@FRelief^.FData[j],
						j));
					FRelief^.FData[j].F3dObject.SetColor  (i * Edge + ii, 0, 0, 0, 0.6);
					
					if (l>=0) and (l<=Edge - 1) then
						begin
						if (FSubsidenceVertices = nil) then
							SetLength(FSubsidenceVertices, 1)
						else
							SetLength(FSubsidenceVertices, Length(FSubsidenceVertices) + 1);
						FSubsidenceVertices[High(FSubsidenceVertices)].FCount := 0;
						case j of
						0 : FSubsidenceVertices[High(FSubsidenceVertices)].FCoords.Import(i1 + a1 * l, i2 + a2 * l, i3 + a3 * l); //Up
						1 : FSubsidenceVertices[High(FSubsidenceVertices)].FCoords.Import(i1 + a1 * l, i2 + a2 * l, i3 + a3 * l); //Down
						2 : FSubsidenceVertices[High(FSubsidenceVertices)].FCoords.Import(i1 + a1 * l, i2 + a2 * l, i3 + a3 * l); 
						3 : FSubsidenceVertices[High(FSubsidenceVertices)].FCoords.Import(i1 + a1 * l, i2 + a2 * l, i3 + a3 * l);
						4 : FSubsidenceVertices[High(FSubsidenceVertices)].FCoords.Import(i1 + a1 * l, i2 + a2 * l, i3 + a3 * l);
						5 : FSubsidenceVertices[High(FSubsidenceVertices)].FCoords.Import(i1 + a1 * l, i2 + a2 * l, i3 + a3 * l);
						end;
						FSubsidenceVertices[High(FSubsidenceVertices)].FVertexIndex := i * Edge + ii;
						FSubsidenceVertices[High(FSubsidenceVertices)].FRelief := j;
						end;
					end;
			
			for i := 0 to FRelief^.FData[j].F3dObject.Faces[0] - 1 do
				begin
				if (Abs(FRelief^.FData[j].F3dObject.ArVertex3f[FRelief^.FData[j].F3dObject.ArFacesTriangles(0,i).p0]^) < SZero) or 
				   (Abs(FRelief^.FData[j].F3dObject.ArVertex3f[FRelief^.FData[j].F3dObject.ArFacesTriangles(0,i).p1]^) < SZero) or 
				   (Abs(FRelief^.FData[j].F3dObject.ArVertex3f[FRelief^.FData[j].F3dObject.ArFacesTriangles(0,i).p2]^) < SZero) then
						begin
						FRelief^.FData[j].F3dObject.SetFaceTriangle(0,i,0,0,0);
						end;
				end;
			end;
		if VProgress <> nil then
			VProgress ^ := PolygoneIndex / AllPolygoneSize + ((AllPolygoneSize - PolygoneIndex) / AllPolygoneSize) * (j / 5);
		end;
	end;
end;

procedure TSGasDiffusionCube.UpDateSourses();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function IsInRange(const i : integer):TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := (i>=0) and (i<=Edge - 1);
end;
var
	I : TSLongWord;
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
				if (Cube(j1d,j2d,j3d)^=0) and TSBoolean(ReliefCubeIndex(j1d,j2d,j3d)) then
					Cube(j1d,j2d,j3d)^:=FSourses[i].FGazTypeIndex+1;
			end;
		end;
end;

procedure TSGasDiffusionCube.UpDateCube();

procedure MoveGazInSmallCube(const i1,i2,i3:TSLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure ProvS3dObject(const a,b : TSGGDC);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : LongWord;
begin
if (FGazes<>nil) and (not((a^=0) or (b^=0))) then
	for i:=0 to High(FGazes) do
		if (FGazes[i].FArComponentOwners[0]<>-1) and (FGazes[i].FArComponentOwners[1]<>-1) and 
			(((a^-1 = FGazes[i].FArComponentOwners[0]) and (b^-1 = FGazes[i].FArComponentOwners[1])) or 
			((b^-1 = FGazes[i].FArComponentOwners[0]) and (a^-1 = FGazes[i].FArComponentOwners[1]))) then
				begin
				a^ := i + 1;
				b^ := 0;
				Exit;
				end;
end;

procedure QuadricMove(const a,b,c,d : TSGGDC);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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
ProvS3dObject(a,b);
ProvS3dObject(b,c);
ProvS3dObject(c,d);
ProvS3dObject(d,a);
end;

var
	b1,b2:Byte;
begin
case random(5) of
1,2://x
	begin
	if TSBoolean(Random(2)) then
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
	i1, i2, i3 : TSLongWord;
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
	i, ii : TSLongWord;
        c : TSGGDC;
        col : TSColor4f;
begin
if (FSubsidenceVertices <> nil) and (Length(FSubsidenceVertices)>0) then
   for i := 0 to High(FSubsidenceVertices) do
       begin
       c := Cube(FSubsidenceVertices[i].FCoords.x, FSubsidenceVertices[i].FCoords.y, FSubsidenceVertices[i].FCoords.z);
       if c^ <> 0 then
          begin
          col := FRelief^.FData[FSubsidenceVertices[i].FRelief].F3dObject.GetColor(FSubsidenceVertices[i].FVertexIndex);
          col := (col * FSubsidenceVertices[i].FCount + FGazes[c^ - 1].FColor) / (FSubsidenceVertices[i].FCount + 1);
          FSubsidenceVertices[i].FCount += 1;
          FRelief^.FData[FSubsidenceVertices[i].FRelief].F3dObject.SetColor(FSubsidenceVertices[i].FVertexIndex, col.r, col.g, col.b, col.a);
          c^ := 0;
          end;
       end;
end;

procedure UpDateOpenBounds();
var
	i,ii:TSLongWord;
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

function TSGasDiffusionCube.Calculate3dObject(const VRelief : PSGasDiffusionRelief = nil{$IFDEF RELIEFDEBUG};const FInReliafDebug : TSLongWord = 0{$ENDIF}):TSCustomModel;
var
	i : TSLongWord;
begin
Result:=TSCustomModel.Create();
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
		Result.LastObject().ObjectPolygonsType := SR_POINTS;
		Result.LastObject().HasNormals := False;
		Result.LastObject().HasTexture := False;
		Result.LastObject().HasColors  := True;
		Result.LastObject().EnableCullFace := False;
		Result.LastObject().VertexType := S3dObjectVertexType3f;
		Result.LastObject().SetColorType (S3dObjectColorType4b);
		Result.LastObject().Vertices   := FDinamicQuantityMoleculs;

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
		Result.LastObject().ObjectPolygonsType := SR_POINTS;
		Result.LastObject().HasNormals := False;
		Result.LastObject().HasTexture := False;
		Result.LastObject().HasColors  := True;
		Result.LastObject().EnableCullFace := False;
		Result.LastObject().VertexType := S3dObjectVertexType3f;
		Result.LastObject().SetColorType (S3dObjectColorType4b);



		Result.LastObject().Vertices   := FDinamicQuantityMoleculs;

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
	Result.LastObject().ObjectPolygonsType := SR_LINES;
	Result.LastObject().HasNormals := False;
	Result.LastObject().HasTexture := False;
	Result.LastObject().HasColors  := True;
	Result.LastObject().EnableCullFace := False;
	Result.LastObject().VertexType := S3dObjectVertexType3f;
	Result.LastObject().SetColorType(S3dObjectColorType4b);
	Result.LastObject().Vertices := 28;

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
	
	for i:=0 to Result.LastObject().Vertices - 1 do
		Result.LastObject().SetColor(i,$0A/256,$C7/256,$F5/256,1);
	end
else
	VRelief^.ExportTo3dObject(Result);
end;

// Release

procedure TSGasDiffusion.SaveStageToStream();
begin
if FFileStream <> nil then
	TS3dObjectS3DMLoader.SaveModel(F3dObject, FFileStream);
end;

procedure TSGasDiffusion.ClearDisplayButtons();
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

destructor TSGasDiffusion.Destroy();
begin
if F3dObject<>nil then
	F3dObject.Destroy();
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

class function TSGasDiffusion.ClassName():TSString;
begin
Result := 'Моделирование диффузии газа';
end;

procedure mmmFBackToMenuButtonProcedure(Button:TSScreenButton);
var
	i : LongWord;
begin with TSGasDiffusion(Button.UserPointer) do begin
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
	if F3dObject<>nil then
		begin
		F3dObject.Destroy();
		F3dObject:=nil;
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
		(FSecheniePanel.LastInternalComponent as TSScreenPicture).Image := nil;
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
procedure mmmFPauseDiffusionButtonProcedure(Button:TSScreenButton);
begin with TSGasDiffusion(Button.UserPointer) do begin
	FDiffusionRuned := False;
	Button.Active := False;
	FStopEmulatingButton.Active := True;
	FStartEmulatingButton.Active := True;
end; end;
procedure mmmFNewSecheniePanelButtonOnChange(Button:TSScreenButton);
begin with TSGasDiffusion(Button.UserPointer) do begin
	FAddNewSourseButton.Active := True;
	FAddNewGazButton.Active := True;
	FNewSecheniePanel.Visible := False;
	FAddSechSecondPanelButton.Active := True;
	FSaveImageButton.Active := True;
end; end;
procedure mmmFAddSechenieButtonProcedure(Button:TSScreenButton);
var
	a : LongWord;
begin with TSGasDiffusion(Button.UserPointer) do begin
	FDeleteSechenieButton.Active:=True;
	Button.Active:=False;
	FAddNewSourseButton.Active := False;
	FAddNewGazButton.Active := False;
	
	FImageSechenieBounds :=1;
	while FImageSechenieBounds < FCube.Edge do
		FImageSechenieBounds *= 2;
	
	a := FTahomaFont.FontHeight*2 + 2*2 + 20;
	
	FNewSecheniePanel := SCreatePanel(Screen, Render.Width-10-a,Render.Height-10-a,a,a, [SAnchRight, SAnchBottom], True, True, Button.UserPointer);
	
	FPlaneComboBox := TSScreenComboBox.Create();
	FNewSecheniePanel.CreateInternalComponent(FPlaneComboBox);
	FNewSecheniePanel.LastInternalComponent.SetBounds(5,5,190,FTahomaFont.FontHeight+2);
	FNewSecheniePanel.LastInternalComponent.BoundsMakeReal();
	FNewSecheniePanel.LastInternalComponent.UserPointer:=Button.UserPointer;
	FNewSecheniePanel.LastInternalComponent.Visible:=True;
	FPlaneComboBox.CreateItem('XoY');
	FPlaneComboBox.CreateItem('XoZ');
	FPlaneComboBox.CreateItem('ZoY');
	FPlaneComboBox.SelectItem := 0;
	
	FNewSecheniePanel.CreateInternalComponent(TSScreenButton.Create());
	FNewSecheniePanel.LastInternalComponent.SetBounds(5,FTahomaFont.FontHeight+10,190,FTahomaFont.FontHeight+2);
	FNewSecheniePanel.LastInternalComponent.BoundsMakeReal();
	FNewSecheniePanel.LastInternalComponent.UserPointer:=Button.UserPointer;
	FNewSecheniePanel.LastInternalComponent.Visible:=True;
	FNewSecheniePanel.LastInternalComponent.Caption := 'ОК';
	(FNewSecheniePanel.LastInternalComponent as TSScreenButton).OnChange := TSScreenComponentProcedure(@mmmFNewSecheniePanelButtonOnChange);
	
	a := (FCube.Edge+1)*2;
	
	FSecheniePanel := SCreatePanel(Screen, 5,Render.Height-10-a,a,a, [SAnchBottom], True, True, Button.UserPointer);
	
	FSechenieImage:=TSImage.Create();
	FSechenieImage.Context := Context;
	FSechenieImage.BitMap.Clear();
	FSechenieImage.BitMap.Width    := FImageSechenieBounds;
	FSechenieImage.BitMap.Height   := FImageSechenieBounds;
	FSechenieImage.BitMap.Channels := 4;
	FSechenieImage.BitMap.ChannelSize := 8;
	FSechenieImage.BitMap.ReAllocateMemory();
	
	SCreatePicture(FSecheniePanel, 5,5,a-10,a-10, True, True);
	
	(FSecheniePanel.LastInternalComponent as TSScreenPicture).Image       := FSechenieImage;
	(FSecheniePanel.LastInternalComponent as TSScreenPicture).EnableLines := True;
	(FSecheniePanel.LastInternalComponent as TSScreenPicture).SecondPoint.Import(
		FCube.Edge/FImageSechenieBounds,
		FCube.Edge/FImageSechenieBounds);
	
	UpDateSechenie();
end; end;
procedure mmmFDeleteSechenieButtonProcedure(Button:TSScreenButton);
begin with TSGasDiffusion(Button.UserPointer) do begin
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
		(FSecheniePanel.LastInternalComponent as TSScreenPicture).Image := nil;
		FSecheniePanel.Destroy();
		FSecheniePanel:=nil;
		end;
	if FSechenieImage<>nil then
		begin
		FSechenieImage.Destroy();
		FSechenieImage:=nil;
		end;
end; end;

procedure TSGasDiffusion.DrawComplexCube();
var
	FArray  : packed array[0..35] of 
			packed record
				FVertex:TSVertex3f;
				FColor:TSColor4b;
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

Render.EnableClientState(SR_VERTEX_ARRAY);
Render.EnableClientState(SR_COLOR_ARRAY);

Render.VertexPointer(3, SR_FLOAT,         SizeOf(FArray[0]), @FArray[0].FVertex);
Render.ColorPointer (4, SR_UNSIGNED_BYTE, SizeOf(FArray[0]), @FArray[0].FColor);

Render.DrawArrays(SR_TRIANGLES, 0, Length(FArray));

Render.DisableClientState(SR_COLOR_ARRAY);
Render.DisableClientState(SR_VERTEX_ARRAY);

Render.Color3f(1,1,1);
end;

function TSGasDiffusion.GetPointColor( const i,ii,iii : LongWord):Byte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := GetPointColorCube(i,ii,iii,FCube);
end;

function TSGasDiffusion.GetPointColorCube( const i,ii,iii : LongWord; const VCube : TSGasDiffusionCube):Byte;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case FPlaneComboBox.SelectItem of
1:Result := VCube.Cube(ii,i,iii)^;
0:Result := VCube.Cube(ii,iii,i)^;
2:Result := VCube.Cube(iii,i,ii)^;
end;
end;

procedure TSGasDiffusion.UpDateSechenie();
var
	i,ii:LongWord;
var
	BitMap : PByte;
	iii : LongWord;
	iiii : byte;
	a : record x,y,z:Real; end;
	color : TSColor4f;
begin
{$IFNDEF MOBILE}
if FNewSecheniePanel.Visible then
	begin
	DrawComplexCube();
	FSechenieUnProjectVertex := SGetVertexUnderPixel(Render,Context.CursorPosition());
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
FSechenieImage.BitMap.FreeData();
FSechenieImage.BitMap.ReAllocateMemory();
for i:=0 to FCube.Edge - 1 do
	for ii:=0 to FCube.Edge - 1 do
		begin
		iiii := GetPointColor(i,ii,iii);
		if iiii <> 0 then
			begin
			color := FCube.FGazes[iiii-1].FColor;
			FSechenieImage.BitMap.Data[(i*FImageSechenieBounds + ii)*FSechenieImage.BitMap.Channels+0]:=trunc(color.r*255);
			FSechenieImage.BitMap.Data[(i*FImageSechenieBounds + ii)*FSechenieImage.BitMap.Channels+1]:=trunc(color.g*255);
			FSechenieImage.BitMap.Data[(i*FImageSechenieBounds + ii)*FSechenieImage.BitMap.Channels+2]:=trunc(color.b*255);
			FSechenieImage.BitMap.Data[(i*FImageSechenieBounds + ii)*FSechenieImage.BitMap.Channels+3]:=255;
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
				FSechenieImage.BitMap.Data[(i*FImageSechenieBounds + ii)*FSechenieImage.BitMap.Channels+0]:=trunc(color.r*255);
				FSechenieImage.BitMap.Data[(i*FImageSechenieBounds + ii)*FSechenieImage.BitMap.Channels+1]:=trunc(color.g*255);
				FSechenieImage.BitMap.Data[(i*FImageSechenieBounds + ii)*FSechenieImage.BitMap.Channels+2]:=trunc(color.b*255);
				FSechenieImage.BitMap.Data[(i*FImageSechenieBounds + ii)*FSechenieImage.BitMap.Channels+3]:=127;
				end;
			end;
		end;
FSechenieImage.LoadTexture();
end;

procedure mmmFStopDiffusionButtonProcedure(Button:TSScreenButton);
begin with TSGasDiffusion(Button.UserPointer) do begin
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
	F3dObject:=FCube.Calculate3dObject(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
end; end;

procedure mmmFRunDiffusionButtonProcedure(Button:TSScreenButton);
begin with TSGasDiffusion(Button.UserPointer) do begin
	FDiffusionRuned := True;
	Button.Active := False;
	FStopEmulatingButton.Active := True;
	FPauseEmulatingButton.Active := True;
	if FEnableSaving and (FFileStream=nil) then
		begin
		FFileName   := SFreeFileName(PredStr + Catalog + DirectorySeparator + 'Save.GDS', 'number');
		FFileStream := TFileStream.Create(FFileName, fmCreate);
		end;
end; end;

type
	TSGDrawColor = class(TSScreenComponent)
			public
		Color : TSColor4f;
			public
		procedure Paint(); override;
		end;

procedure TSGDrawColor.Paint();
begin
if (FVisible) or (FVisibleTimer>SZero) then
	begin
	Color.a := FVisibleTimer;
	SRoundQuad(Render,
		SPoint2int32ToVertex3f(GetVertex([SS_LEFT,SS_TOP],S_VERTEX_FOR_MainComponent)),
		SPoint2int32ToVertex3f(GetVertex([SS_RIGHT,SS_BOTTOM],S_VERTEX_FOR_MainComponent)),
		5,10,
		Color,
		Color,
		not True,not False);
	end;
inherited;
end;

procedure UpdateNewGasPanel(Panel:TSScreenComponent);
var
	g,i : LongWord;
begin with TSGasDiffusion(Panel.UserPointer) do begin
if not ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
	begin
	g  := (Panel.InternalComponents[1] as TSScreenComboBox).SelectItem;
	(Panel.InternalComponents[4] as TSGDrawColor).Color := FCube.FGazes[g].FColor;
	Panel.InternalComponents[1].Active := True;
	Panel.InternalComponents[5].Active := True;
	Panel.InternalComponents[6].Active := True;
	Panel.InternalComponents[7].Active := True;
	Panel.InternalComponents[11].Active := True;
	Panel.InternalComponents[9].Active := True;
	Panel.InternalComponents[4].Visible := True;
	end
else
	begin
	Panel.InternalComponents[1].Active := False;
	Panel.InternalComponents[5].Active := False;
	Panel.InternalComponents[6].Active := False;
	Panel.InternalComponents[7].Active := False;
	Panel.InternalComponents[11].Active := False;
	Panel.InternalComponents[9].Active := False;
	Panel.InternalComponents[4].Visible := False;
	end;
if (not ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0))) and ((FCube.FGazes[g].FArComponentOwners[0]<>-1) and (FCube.FGazes[g].FArComponentOwners[1]<>-1)) then
	begin
	(Panel.InternalComponents[6] as TSScreenComboBox).SelectItem := 0;
	Panel.InternalComponents[7].Caption := SStr(FCube.FGazes[g].FArComponentOwners[0]+1);
	Panel.InternalComponents[8].Caption := SStr(FCube.FGazes[g].FArComponentOwners[1]+1);
	Panel.InternalComponents[7].Active:=True;
	Panel.InternalComponents[8].Active:=True;
	end
else
	begin
	(Panel.InternalComponents[6] as TSScreenComboBox).SelectItem := 1;
	Panel.InternalComponents[7].Active:=False;
	Panel.InternalComponents[8].Active:=False;
	Panel.InternalComponents[7].Caption := '';
	Panel.InternalComponents[8].Caption := '';
	end;
end;end;

procedure mmmGasCBProc(b,c : LongInt;a : TSScreenComboBox);
begin
a.SelectItem := c;
UpdateNewGasPanel(a.ComponentOwner as TSScreenComponent);
end;

procedure mmmFCloseAddNewGazButtonProcedure(Button:TSScreenButton);
begin with TSGasDiffusion(Button.ComponentOwner.UserPointer) do begin
FAddNewGazPanel.Visible := False;
FAddNewGazPanel.Active := False;
FAddNewSourseButton.Active := True;
FAddNewGazButton.Active := True;
FAddSechenieButton.Active := FSecheniePanel=nil;
FDeleteSechenieButton.Active := FSecheniePanel<>nil;
end; end;

procedure mmmGas123Proc(b,c : LongInt;a : TSScreenComboBox);
begin with TSGasDiffusion(a.ComponentOwner.UserPointer) do begin
a.ComponentOwner.InternalComponents[7].Active:=not Boolean(c);
a.ComponentOwner.InternalComponents[8].Active:=not Boolean(c);
a.ComponentOwner.InternalComponents[8].Caption := '';
a.ComponentOwner.InternalComponents[7].Caption := '';
(a.ComponentOwner.InternalComponents[7] as TSScreenEdit).TextComplite := False;
(a.ComponentOwner.InternalComponents[8] as TSScreenEdit).TextComplite := False;
end; end;

procedure mmmFAddAddNewGazButtonProcedure(Button:TSScreenButton);
var
	i : LongWord;
begin with TSGasDiffusion(Button.ComponentOwner.UserPointer) do begin
SetLength(FCube.FGazes,Length(FCube.FGazes)+1);
FCube.FGazes[High(FCube.FGazes)].Create(random,random,random,1,-1,-1);
(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).ClearItems();
for i := 0 to High(FCube.FGazes) do
	(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).CreateItem('Газ №'+SStr(i+1));
(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).Active := True;
(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).SelectItem := High(FCube.FGazes);
UpdateNewGasPanel(Button.ComponentOwner as TSScreenComponent);
end;end;

procedure mmmGas1234Proc(Button:TSScreenButton);//Удаление
var
	i,ii,iii,j : LongWord;
begin with TSGasDiffusion(Button.ComponentOwner.UserPointer) do begin
if ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
	Exit;
ii := (Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).SelectItem;
if Length(FCube.FGazes)<>1 then
	for i:= ii to High(FCube.FGazes)-1 do
		FCube.FGazes[i] := FCube.FGazes[i+1];
SetLength(FCube.FGazes,Length(FCube.FGazes)-1);
if Length(FCube.FGazes)=0 then
	FCube.FGazes := nil;
if ((FCube.FGazes<>nil) and (Length(FCube.FGazes)<>0)) then
	for i := 0 to High(FCube.FGazes) do
		begin
		if (FCube.FGazes[i].FArComponentOwners[0]=ii) or (FCube.FGazes[i].FArComponentOwners[1]=ii) then
			begin
			FCube.FGazes[i].FArComponentOwners[0]:=-1;
			FCube.FGazes[i].FArComponentOwners[1]:=-1;
			end
		else
			begin
			if FCube.FGazes[i].FArComponentOwners[0]>ii then
				FCube.FGazes[i].FArComponentOwners[0] -= 1;
			if FCube.FGazes[i].FArComponentOwners[1]>ii then
				FCube.FGazes[i].FArComponentOwners[1] -= 1;
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
(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).ClearItems();
if ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
	begin
	(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).CreateItem('Добавьте газы');
	(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).SelectItem := 0;
	(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).Active := False;
	end
else
	begin
	for i:=0 to High(FCube.FGazes) do
		(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).CreateItem('Газ №'+SStr(i+1));
	(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).SelectItem := High(FCube.FGazes);
	end;
UpdateNewGasPanel(Button.ComponentOwner as TSScreenComponent);
F3dObject.Destroy();
F3dObject:=FCube.Calculate3dObject(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
end;end;

procedure mmmGasChangeProc(Button:TSScreenButton);
var
	a,b,c : LongWord;
begin with TSGasDiffusion(Button.ComponentOwner.UserPointer) do begin
if not Boolean((Button.ComponentOwner.InternalComponents[6] as TSScreenComboBox).SelectItem) then
	begin
	a := SVal(Button.ComponentOwner.InternalComponents[7].Caption);
	b := SVal(Button.ComponentOwner.InternalComponents[8].Caption);
	if (a<>b) and (a>=1) and (a<=Length(FCube.FGazes)) and (b>=1) and (b<=Length(FCube.FGazes)) then
		begin
		c := (Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).SelectItem;
		FCube.FGazes[c].FArComponentOwners[0]:=a-1;
		FCube.FGazes[c].FArComponentOwners[1]:=b-1;
		end;
	end
else
	begin
	c := (Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).SelectItem;
	FCube.FGazes[c].FArComponentOwners[0]:=-1;
	FCube.FGazes[c].FArComponentOwners[1]:=-1;
	end;
end; end;

procedure mmmFAddNewGazButtonProcedure(Button:TSScreenButton);
const
	pw = 200;
	ph = 143+20;
var
	i : LongWord;
	Image:TSImage = nil;
begin with TSGasDiffusion(Button.UserPointer) do begin
Button.Active := False;
FAddNewSourseButton.Active := False;
FAddSechenieButton.Active := False;

if FAddNewGazPanel = nil then
	begin
	FAddNewGazPanel := SCreatePanel(Screen, Render.Width - pw - 10, Render.Height - ph - 10, pw, ph, [SAnchRight,SAnchBottom], True, True, Button.UserPointer);
	
	FAddNewGazPanel.CreateInternalComponent(TSScreenComboBox.Create());//1
	FAddNewGazPanel.LastInternalComponent.SetBounds(0,4,pw - 10 - 25,18);
	FAddNewGazPanel.LastInternalComponent.BoundsMakeReal();
	if ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
		(FAddNewGazPanel.LastInternalComponent as TSScreenComboBox).CreateItem('Добавьте газы')
	else
		for i:=0 to High(FCube.FGazes) do
			(FAddNewGazPanel.LastInternalComponent as TSScreenComboBox).CreateItem('Газ №'+SStr(i+1));
	(FAddNewGazPanel.LastInternalComponent as TSScreenComboBox).SelectItem := 0;
	(FAddNewGazPanel.LastInternalComponent as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@mmmGasCBProc);
	(FAddNewGazPanel.LastInternalComponent as TSScreenComboBox).MaxLines := 5;
	
	FAddNewGazPanel.CreateInternalComponent(TSScreenButton.Create());//2
	FAddNewGazPanel.LastInternalComponent.SetBounds(5+pw - 10 - 25+2,4,20,18);
	FAddNewGazPanel.LastInternalComponent.BoundsMakeReal();
	FAddNewGazPanel.LastInternalComponent.Caption:='+';
	(FAddNewGazPanel.LastInternalComponent as TSScreenButton).OnChange:=TSScreenComponentProcedure(@mmmFAddAddNewGazButtonProcedure);
	
	SCreateLabel(FAddNewGazPanel, 'Цвет:', 0,25,50,18, False, True);//3
	
	FAddNewGazPanel.CreateInternalComponent(TSGDrawColor.Create());//4
	FAddNewGazPanel.LastInternalComponent.SetBounds(50,26,75,18);
	FAddNewGazPanel.LastInternalComponent.BoundsMakeReal();
	
	FAddNewGazPanel.CreateInternalComponent(TSScreenButton.Create());//5
	FAddNewGazPanel.LastInternalComponent.SetBounds(5+pw - 10 - 25+2-40,25,60,18);
	FAddNewGazPanel.LastInternalComponent.BoundsMakeReal();
	FAddNewGazPanel.LastInternalComponent.Caption:='Править';
	
	FAddNewGazPanel.CreateInternalComponent(TSScreenComboBox.Create());//6
	FAddNewGazPanel.LastInternalComponent.SetBounds(3,48,pw - 10,18);
	FAddNewGazPanel.LastInternalComponent.BoundsMakeReal();
	(FAddNewGazPanel.LastInternalComponent as TSScreenComboBox).CreateItem('Образуется при контакте');
	(FAddNewGazPanel.LastInternalComponent as TSScreenComboBox).CreateItem('Небудет получаться');
	(FAddNewGazPanel.LastInternalComponent as TSScreenComboBox).SelectItem := 0;
	(FAddNewGazPanel.LastInternalComponent as TSScreenComboBox).CallBackProcedure := TSScreenComboBoxProcedure(@mmmGas123Proc);
	
	SCreateEdit(FAddNewGazPanel, '', SScreenEditTypeNumber, 3,69,(pw div 2) - 10,18, [], False, True);//7
	SCreateEdit(FAddNewGazPanel, '', SScreenEditTypeNumber, 3+(pw div 2)+3,69,(pw div 2) - 10,18, [], False, True);//8
	
	FAddNewGazPanel.CreateInternalComponent(TSScreenButton.Create());//9
	FAddNewGazPanel.LastInternalComponent.SetBounds(3,90,pw - 10,18);
	FAddNewGazPanel.LastInternalComponent.BoundsMakeReal();
	FAddNewGazPanel.LastInternalComponent.Caption:='Удалить этот газ';
	(FAddNewGazPanel.LastInternalComponent as TSScreenButton).OnChange:=TSScreenComponentProcedure(@mmmGas1234Proc);
	
	FAddNewGazPanel.CreateInternalComponent(TSScreenButton.Create());//10
	FAddNewGazPanel.LastInternalComponent.SetBounds(3,111+21,pw - 10,18);
	FAddNewGazPanel.LastInternalComponent.BoundsMakeReal();
	FAddNewGazPanel.LastInternalComponent.Caption:='Закрыть это окно';
	(FAddNewGazPanel.LastInternalComponent as TSScreenButton).OnChange:=TSScreenComponentProcedure(@mmmFCloseAddNewGazButtonProcedure);
	
	FAddNewGazPanel.CreateInternalComponent(TSScreenButton.Create());//11
	FAddNewGazPanel.LastInternalComponent.SetBounds(3,111,pw - 10,18);
	FAddNewGazPanel.LastInternalComponent.BoundsMakeReal();
	FAddNewGazPanel.LastInternalComponent.Caption:='Применить';
	(FAddNewGazPanel.LastInternalComponent as TSScreenButton).OnChange:=TSScreenComponentProcedure(@mmmGasChangeProc);
	end;
FAddNewGazPanel.Visible := True;
FAddNewGazPanel.Active := True;

UpdateNewGasPanel(FAddNewGazPanel);
end; end;

procedure mmmFCloseAddNewSourseButtonProcedure(Button:TSScreenButton);
begin with TSGasDiffusion(Button.ComponentOwner.UserPointer) do begin
FAddNewSoursePanel.Visible := False;
FAddNewSoursePanel.Active := False;
FAddNewSourseButton.Active := True;
FAddNewGazButton.Active := True;
FAddSechenieButton.Active := FSecheniePanel=nil;
FDeleteSechenieButton.Active := FSecheniePanel<>nil;
end; end;

procedure mmmSourseChageGasProc(b,c : LongInt;a : TSScreenComboBox);
var
	o,i : LongWord;
	j1,j2,j3 : LongInt;
begin with TSGasDiffusion(a.ComponentOwner.UserPointer) do begin
if b = c then
	Exit;
a.SelectItem:=c;
i := (FAddNewSoursePanel.InternalComponents[1] as TSScreenComboBox).SelectItem;
o := FCube.FSourses[i].FGazTypeIndex;
FCube.FSourses[i].FGazTypeIndex := c;
for j1:=-FCube.FSourses[i].FRadius to FCube.FSourses[i].FRadius do
for j2:=-FCube.FSourses[i].FRadius to FCube.FSourses[i].FRadius do
for j3:=-FCube.FSourses[i].FRadius to FCube.FSourses[i].FRadius do
	if FCube.Cube(FCube.FSourses[i].FCoord.x+j1,FCube.FSourses[i].FCoord.y+j2,FCube.FSourses[i].FCoord.z+j3)^=o+1 then
		FCube.Cube(FCube.FSourses[i].FCoord.x+j1,FCube.FSourses[i].FCoord.y+j2,FCube.FSourses[i].FCoord.z+j3)^:=c+1;
F3dObject.Destroy();
F3dObject:=FCube.Calculate3dObject(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
end; end;

procedure mmmSourseChageSourseProc(b,c : LongInt;a : TSScreenComboBox);
begin with TSGasDiffusion(a.ComponentOwner.UserPointer) do begin
a.SelectItem:=c;
UpDateSoursePanel();
end;end;

procedure TSGasDiffusion.UpDateSoursePanel();
var
	s : LongWord;
begin
if ((FCube.FSourses=nil) or (Length(FCube.FSourses)=0)) then
	begin
	(FAddNewSoursePanel.InternalComponents[1]).Active := False;
	(FAddNewSoursePanel.InternalComponents[3]).Active := False;
	(FAddNewSoursePanel.InternalComponents[4]).Active := False;
	(FAddNewSoursePanel.InternalComponents[5]).Active := False;
	(FAddNewSoursePanel.InternalComponents[7]).Active := False;
	(FAddNewSoursePanel.InternalComponents[3] as TSScreenComboBox).SelectItem := 0;
	(FAddNewSoursePanel.InternalComponents[4] as TSScreenEdit).Caption := '';
	if ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
		(FAddNewSoursePanel.InternalComponents[2]).Active := False;
	end
else
	begin
	(FAddNewSoursePanel.InternalComponents[1]).Active := True;
	(FAddNewSoursePanel.InternalComponents[3]).Active := True;
	(FAddNewSoursePanel.InternalComponents[4]).Active := True;
	(FAddNewSoursePanel.InternalComponents[5]).Active := True;
	(FAddNewSoursePanel.InternalComponents[7]).Active := True;
	(FAddNewSoursePanel.InternalComponents[2]).Active := True;
	s := (FAddNewSoursePanel.InternalComponents[1] as TSScreenComboBox).SelectItem;
	(FAddNewSoursePanel.InternalComponents[3] as TSScreenComboBox).SelectItem := FCube.FSourses[s].FGazTypeIndex;
	(FAddNewSoursePanel.InternalComponents[4] as TSScreenEdit).Caption := SStr(FCube.FSourses[s].FRadius);
	(FAddNewSoursePanel.InternalComponents[4] as TSScreenEdit).TextComplite := True;
	end;
end;

procedure mmmFAddAddNewSourseButtonProcedure(Button:TSScreenButton);
var
	i : LongWord;
	j1,j2,j3 : LongInt;
begin with TSGasDiffusion(Button.ComponentOwner.UserPointer) do begin 
SetLength(FCube.FSourses,Length(FCube.FSourses)+1);
FCube.FSourses[High(FCube.FSourses)].FGazTypeIndex := random(Length(FCube.FGazes));
FCube.FSourses[High(FCube.FSourses)].FCoord.Import(random(FCube.Edge-10)+5,random(FCube.Edge-10)+5,random(FCube.Edge-10)+5);
FCube.FSourses[High(FCube.FSourses)].FRadius := random(3)+1;
(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).ClearItems();
for i:=0 to High(FCube.FSourses) do
	(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).CreateItem('Источник №'+SStr(i+1));
i := High(FCube.FSourses);
(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).SelectItem := i;
FCube.UpDateSourses();
UpDateSoursePanel();
F3dObject.Destroy();
F3dObject:=FCube.Calculate3dObject(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
end;end;

procedure mmmFDleteSourseAddNewSourseButtonProcedure(Button:TSScreenButton);
var
	s : LongInt;
	i : LongWord;
	j1,j2,j3 : LongInt;
begin with TSGasDiffusion(Button.ComponentOwner.UserPointer) do begin 
s := (Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).SelectItem;

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

(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).ClearItems();
if Length(FCube.FSourses)=0 then
	begin
	(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).CreateItem('Нету источников');
	end
else
	begin
	for i:=0 to High(FCube.FSourses) do
		(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).CreateItem('Источник №'+SStr(i+1));
	end;
(Button.ComponentOwner.InternalComponents[1] as TSScreenComboBox).SelectItem := 0;

UpDateSoursePanel();
F3dObject.Destroy();
F3dObject:=FCube.Calculate3dObject(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
end; end;

procedure FAddNewSourseButtonProcedure(Button:TSScreenButton);
const
	pw = 200;
	ph = 69+21+5+21+2;
var
	i : LongWord;
begin with TSGasDiffusion(Button.UserPointer) do begin
FAddSechenieButton.Active := False;
FAddNewSourseButton.Active:=False;
FAddNewGazButton.Active:=False;

if FAddNewSoursePanel = nil then
	begin
	FAddNewSoursePanel := SCreatePanel(Screen, Render.Width - pw - 10,Render.Height - ph - 10, pw, ph, [SAnchRight, SAnchBottom], False, True, Button.UserPointer);
	
	FAddNewSoursePanel.CreateInternalComponent(TSScreenComboBox.Create());//1
	FAddNewSoursePanel.LastInternalComponent.SetBounds(0,4,pw - 10 - 25,18);
	FAddNewSoursePanel.LastInternalComponent.BoundsMakeReal();
	if ((FCube.FSourses=nil) or (Length(FCube.FSourses)=0)) then
		(FAddNewSoursePanel.LastInternalComponent as TSScreenComboBox).CreateItem('Нету источников')
	else
		for i:=0 to High(FCube.FSourses) do
			(FAddNewSoursePanel.LastInternalComponent as TSScreenComboBox).CreateItem('Источник №'+SStr(i+1));
	(FAddNewSoursePanel.LastInternalComponent as TSScreenComboBox).SelectItem := 0;
	(FAddNewSoursePanel.LastInternalComponent as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@mmmSourseChageSourseProc);
	(FAddNewSoursePanel.LastInternalComponent as TSScreenComboBox).MaxLines := 6;
	
	FAddNewSoursePanel.CreateInternalComponent(TSScreenButton.Create());//2
	FAddNewSoursePanel.LastInternalComponent.SetBounds(5+pw - 10 - 25+2,4,20,18);
	FAddNewSoursePanel.LastInternalComponent.BoundsMakeReal();
	FAddNewSoursePanel.LastInternalComponent.Caption:='+';
	(FAddNewSoursePanel.LastInternalComponent as TSScreenButton).OnChange:=TSScreenComponentProcedure(@mmmFAddAddNewSourseButtonProcedure);
	
	FAddNewSoursePanel.CreateInternalComponent(TSScreenComboBox.Create());//3
	FAddNewSoursePanel.LastInternalComponent.SetBounds(0,4+21,pw - 10,18);
	FAddNewSoursePanel.LastInternalComponent.BoundsMakeReal();
	if ((FCube.FGazes=nil) or (Length(FCube.FGazes)=0)) then
		begin
		(FAddNewSoursePanel.LastInternalComponent as TSScreenComboBox).CreateItem('Добавьте газы');
		end
	else
		for i:=0 to High(FCube.FGazes) do
			(FAddNewSoursePanel.LastInternalComponent as TSScreenComboBox).CreateItem('Газ №'+SStr(i+1));
	(FAddNewSoursePanel.LastInternalComponent as TSScreenComboBox).SelectItem := 0;
	(FAddNewSoursePanel.LastInternalComponent as TSScreenComboBox).CallBackProcedure :=TSScreenComboBoxProcedure(@mmmSourseChageGasProc);
	
	SCreateEdit(FAddNewSoursePanel, '', SScreenEditTypeNumber, 3+(pw div 2)+3,69-21,(pw div 2) - 10,18, [], False, True);//4
	SCreateLabel(FAddNewSoursePanel, 'Радиус:', 3,69-21,(pw div 2) - 10,18, False, True);//5
	
	FAddNewSoursePanel.CreateInternalComponent(TSScreenButton.Create());//6
	FAddNewSoursePanel.LastInternalComponent.SetBounds(3,69+21,pw - 10,18);
	FAddNewSoursePanel.LastInternalComponent.BoundsMakeReal();
	FAddNewSoursePanel.LastInternalComponent.Caption:='Закрыть это окно';
	(FAddNewSoursePanel.LastInternalComponent as TSScreenButton).OnChange:=TSScreenComponentProcedure(@mmmFCloseAddNewSourseButtonProcedure);
	
	FAddNewSoursePanel.CreateInternalComponent(TSScreenButton.Create());//7
	FAddNewSoursePanel.LastInternalComponent.SetBounds(3,69,pw - 10,18);
	FAddNewSoursePanel.LastInternalComponent.BoundsMakeReal();
	FAddNewSoursePanel.LastInternalComponent.Caption:='Удалить';
	(FAddNewSoursePanel.LastInternalComponent as TSScreenButton).OnChange:=TSScreenComponentProcedure(@mmmFDleteSourseAddNewSourseButtonProcedure);
	end;

FAddNewSoursePanel.Active  := True;
FAddNewSoursePanel.Visible := True;
UpDateSoursePanel();
end; end;

procedure mmmFSaveImageButtonProcedure(Button:TSScreenButton);
procedure PutPixel(const p : TSPixel4b; const Destination : PByte);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
{$IFDEF WITHLIBPNG}
	PSPixel4b(Destination)^ := p;
{$ELSE}
	Destination[0] := trunc(p.a*p.r/255);
	Destination[1] := trunc(p.a*p.g/255);
	Destination[2] := trunc(p.a*p.b/255);
	{$ENDIF}
end;
var
	Image : TSImage = nil;
	i, ii, d : TSUInt32;
	p : TSPixel4b;
begin with TSGasDiffusion(Button.UserPointer) do begin
if (FUsrSechPanel<>nil) and (FUsrSechPanel.Visible) then
	d := 2
else
	d := 1;
Image := TSImage.Create();
Image.Context := Context;
Image.BitMap.Clear();
Image.BitMap.Width  := FCube.Edge * d;
Image.BitMap.Height := FCube.Edge;
{$IFDEF WITHLIBPNG}
	Image.BitMap.Channels := 4;
{$ELSE}
	Image.BitMap.Channels := 3;
	{$ENDIF}
Image.BitMap.ChannelSize := 8;
Image.BitMap.ReAllocateMemory();

for i := 0 to FCube.Edge-1 do
	for ii := 0 to FCube.Edge-1 do
		PutPixel(FSechenieImage.BitMap.PixelRGBA32(ii,FCube.Edge-i-1),@Image.BitMap.Data[(i*Image.Width+ii)*Image.BitMap.Channels]);

if d = 2 then
	for i := 0 to FCube.Edge-1 do
		for ii := 0 to FCube.Edge-1 do
			PutPixel(FUsrSechImage.BitMap.PixelRGBA32(ii,FCube.Edge-i-1),@Image.BitMap.Data[(i*Image.Width+ii+FCube.Edge)*Image.BitMap.Channels]);

SMakeDirectory(PredStr + Catalog);
{$IFDEF WITHLIBPNG}
	Image.FileName := SFreeFileName(PredStr + Catalog + DirectorySeparator + 'Image.png', 'number');
	Image.Save(SImageFormatPNG);
{$ELSE}
	Image.FileName := SFreeFileName(PredStr + Catalog + DirectorySeparator + 'Image.jpg', 'number');
	Image.Save(SImageFormatJpeg);
	{$ENDIF}

SKill(Image);
end;end;

procedure mmmFAddSechSecondPanelButtonProcedure(Button:TSScreenButton);
var
	a : LongWord;
begin with TSGasDiffusion(Button.UserPointer) do begin
if FUsrSechPanel = nil then
	begin
	a := (FCube.Edge+1)*2;
	FUsrSechPanel := SCreatePanel(Screen, a + 10,Render.Height - a - 10, a, a, [SAnchBottom], True, True, Button.UserPointer);
	
	FUsrSechImage:=TSImage.Create();
	FUsrSechImage.Context := Context;
	FUsrSechImage.BitMap.Clear();
	FUsrSechImage.BitMap.Width       := FImageSechenieBounds;
	FUsrSechImage.BitMap.Height      := FImageSechenieBounds;
	FUsrSechImage.BitMap.Channels    := FSechenieImage.BitMap.Channels;
	FUsrSechImage.BitMap.ChannelSize := 8;
	FUsrSechImage.BitMap.ReAllocateMemory();
	FUsrSechImage.LoadTexture();
	
	SCreatePicture(FUsrSechPanel, 5,5,a-10,a-10, True, True);
	
	(FUsrSechPanel.LastInternalComponent as TSScreenPicture).Image       := FUsrSechImage;
	(FUsrSechPanel.LastInternalComponent as TSScreenPicture).EnableLines := True;
	(FUsrSechPanel.LastInternalComponent as TSScreenPicture).SecondPoint.Import(
		FCube.Edge/FImageSechenieBounds,
		FCube.Edge/FImageSechenieBounds);
	
	FUsrSechPanel.CreateInternalComponent(TSScreenProgressBar.Create());
	//FUsrSechPanel.LastInternalComponent.Font := FTahomaFont;
	FUsrSechPanel.LastInternalComponent.SetBounds(
		10,FUsrSechPanel.Height div 2 - (FUsrSechPanel.LastInternalComponent as TSScreenComponent).Skin.Font.FontHeight div 2,
		FUsrSechPanel.Width - 30,(FUsrSechPanel.LastInternalComponent as TSScreenComponent).Skin.Font.FontHeight);
	FUsrSechPanel.LastInternalComponent.BoundsMakeReal();
	(FUsrSechPanel.InternalComponents[2] as TSScreenProgressBar).Visible := True;
	end;

UpDateUsrSech();
end; end;

procedure FUsrImageThreadProcedure(Klass : TSGasDiffusion);
function InitPixel(const x,y,z : LongWord;const range : LongInt):TSPixel4b;
var
	i, ii, iii, total, totalAlpha: LongInt;
	px, py, pz : LongInt;
	colorIndex : byte;
	color : TSColor4f = ( x : 0; y : 0; z : 0; w : 0);
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
	Result := SConvertPixelRGBToAlpha(Result);
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
		FUsrSechImageForThread.BitMap.SetPixelRGBA32(i, ii, InitPixel(ii,i,z,range));
		ii += 1;
		end;
	i +=1;
	(FUsrSechPanel.InternalComponents[2] as TSScreenProgressBar).Progress := i/(FCube.Edge - 1);
	end;
FUpdateUsrAfterThread := True;
end; end;

procedure TSGasDiffusion.UpDateUsrSech();
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
	FUsrSechImageForThread:=TSImage.Create();
	FUsrSechImageForThread.Context := Context;
	FUsrSechImageForThread.BitMap.Clear();
	FUsrSechImageForThread.BitMap.Width       := FImageSechenieBounds;
	FUsrSechImageForThread.BitMap.Height      := FImageSechenieBounds;
	FUsrSechImageForThread.BitMap.Channels    := 4;
	FUsrSechImageForThread.BitMap.ChannelSize := 8;
	FUsrSechImageForThread.BitMap.ReAllocateMemory();
	
	if FCubeForUsr <> nil then
		begin
		FCubeForUsr.Destroy();
		FCubeForUsr := nil;
		end;
	FCubeForUsr := FCube.Copy();
	FUsrSechThread := TSThread.Create(TSThreadProcedure(@FUsrImageThreadProcedure),Self);
	(FUsrSechPanel.InternalComponents[2] as TSScreenProgressBar).Visible := True;
	(FUsrSechPanel.InternalComponents[2] as TSScreenProgressBar).ProgressTimer := 0;
	(FUsrSechPanel.InternalComponents[2] as TSScreenProgressBar).Progress := 0;
	
	FAddSechSecondPanelButton.Active := False;
	end;
end;

procedure mmmFStartingThreadProcedure(Klass : TSGasDiffusion);
begin with Klass do begin
FEnableSaving := not Boolean(FEnableOutputComboBox.SelectItem);
if FCube<>nil then
	begin
	FCube.Destroy();
	FCube:=nil;
	end;
FCube:=TSGasDiffusionCube.Create(Context);
FCube.FRelief := @FRelief;
FCube.InitCube(SVal(FEdgeEdit.Caption),FStartingProgressBar.GetProgressPointer());
if F3dObject<>nil then
	begin
	F3dObject.Destroy();
	F3dObject:=nil;
	end;
F3dObject := FCube.Calculate3dObject(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
FNowCadr := 0;
if FEnableSaving then
	SMakeDirectory(PredStr+Catalog);
FStartingFlag := 2;
end; end;

procedure mmmPostInitCubeProcedure(Klass : TSGasDiffusion);
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
	FBackToMenuButton:=TSScreenButton.Create();
	Screen.CreateInternalComponent(FBackToMenuButton);
	FBackToMenuButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*0,W,FTahomaFont.FontHeight+2);
	FBackToMenuButton.BoundsMakeReal();
	FBackToMenuButton.Anchors:=[SAnchRight];
	FBackToMenuButton.Visible := True;
	FBackToMenuButton.Active  := True;
	FBackToMenuButton.Skin := FBackToMenuButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FBackToMenuButton.Caption :='В главное меню';
	FBackToMenuButton.UserPointer:=Klass;
	FBackToMenuButton.OnChange:=TSScreenComponentProcedure(@mmmFBackToMenuButtonProcedure);
	end
else
	begin
	FBackToMenuButton.Visible := True;
	FBackToMenuButton.Active  := True;
	end;

if FAddNewGazButton=nil then
	begin
	FAddNewGazButton:=TSScreenButton.Create();
	Screen.CreateInternalComponent(FAddNewGazButton);
	FAddNewGazButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*1,W,FTahomaFont.FontHeight+2);
	FAddNewGazButton.BoundsMakeReal();
	FAddNewGazButton.Anchors:=[SAnchRight];
	FAddNewGazButton.Visible:=True;
	FAddNewGazButton.Active  := True;
	FAddNewGazButton.Skin := FAddNewGazButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FAddNewGazButton.Caption:='Править типы газа';
	FAddNewGazButton.UserPointer:=Klass;
	FAddNewGazButton.OnChange:=TSScreenComponentProcedure(@mmmFAddNewGazButtonProcedure);
	end
else
	begin
	FAddNewGazButton.Visible := True;
	FAddNewGazButton.Active  := True;
	end;

if FAddNewSourseButton = nil then
	begin
	FAddNewSourseButton:=TSScreenButton.Create();
	Screen.CreateInternalComponent(FAddNewSourseButton);
	FAddNewSourseButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*2,W,FTahomaFont.FontHeight+2);
	FAddNewSourseButton.BoundsMakeReal();
	FAddNewSourseButton.Anchors:=[SAnchRight];
	FAddNewSourseButton.Visible:=True;
	FAddNewSourseButton.Active  := True;
	FAddNewSourseButton.Skin := FAddNewSourseButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FAddNewSourseButton.Caption:='Править източники газа';
	FAddNewSourseButton.UserPointer:=Klass;
	FAddNewSourseButton.OnChange:=TSScreenComponentProcedure(@FAddNewSourseButtonProcedure);
	end
else
	begin
	FAddNewSourseButton.Visible := True;
	FAddNewSourseButton.Active  := True;
	end;

if FStartEmulatingButton=nil then
	begin
	FStartEmulatingButton:=TSScreenButton.Create();
	Screen.CreateInternalComponent(FStartEmulatingButton);
	FStartEmulatingButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*3,W,FTahomaFont.FontHeight+2);
	FStartEmulatingButton.BoundsMakeReal();
	FStartEmulatingButton.Anchors:=[SAnchRight];
	FStartEmulatingButton.Visible:=True;
	FStartEmulatingButton.Active  := True;
	FStartEmulatingButton.Skin := FStartEmulatingButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FStartEmulatingButton.Caption:='Эмурировать';
	FStartEmulatingButton.UserPointer:=Klass;
	FStartEmulatingButton.OnChange:=TSScreenComponentProcedure(@mmmFRunDiffusionButtonProcedure);
	end
else
	begin
	FStartEmulatingButton.Visible := True;
	FStartEmulatingButton.Active  := True;
	end;

if FPauseEmulatingButton = nil then
	begin
	FPauseEmulatingButton:=TSScreenButton.Create();
	Screen.CreateInternalComponent(FPauseEmulatingButton);
	FPauseEmulatingButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*4,W,FTahomaFont.FontHeight+2);
	FPauseEmulatingButton.BoundsMakeReal();
	FPauseEmulatingButton.Anchors:=[SAnchRight];
	FPauseEmulatingButton.Visible:=True;
	FPauseEmulatingButton.Active :=False;
	FPauseEmulatingButton.Skin := FPauseEmulatingButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FPauseEmulatingButton.Caption:='Приостановить эмуляцию';
	FPauseEmulatingButton.UserPointer:=Klass;
	FPauseEmulatingButton.OnChange:=TSScreenComponentProcedure(@mmmFPauseDiffusionButtonProcedure);
	end
else
	begin
	FPauseEmulatingButton.Visible := True;
	FPauseEmulatingButton.Active  := False;
	end;

if FStopEmulatingButton = nil then
	begin
	FStopEmulatingButton:=TSScreenButton.Create();
	Screen.CreateInternalComponent(FStopEmulatingButton);
	FStopEmulatingButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*5,W,FTahomaFont.FontHeight+2);
	FStopEmulatingButton.BoundsMakeReal();
	FStopEmulatingButton.Anchors:=[SAnchRight];
	FStopEmulatingButton.Visible:=True;
	FStopEmulatingButton.Active :=False;
	FStopEmulatingButton.Skin := FStopEmulatingButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FStopEmulatingButton.Caption:='Ocтановить эмуляцию';
	FStopEmulatingButton.UserPointer:=Klass;
	FStopEmulatingButton.OnChange:=TSScreenComponentProcedure(@mmmFStopDiffusionButtonProcedure);
	end
else
	begin
	FStopEmulatingButton.Visible := True;
	FStopEmulatingButton.Active  := False;
	end;

if FAddSechenieButton = nil then 
	begin
	FAddSechenieButton:=TSScreenButton.Create();
	Screen.CreateInternalComponent(FAddSechenieButton);
	FAddSechenieButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*6,W,FTahomaFont.FontHeight+2);
	FAddSechenieButton.BoundsMakeReal();
	FAddSechenieButton.Anchors:=[SAnchRight];
	FAddSechenieButton.Visible:=True;
	FAddSechenieButton.Active :=True;
	FAddSechenieButton.Skin := FAddSechenieButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FAddSechenieButton.Caption:='Рассмотреть сечение';
	FAddSechenieButton.UserPointer:=Klass;
	FAddSechenieButton.OnChange:=TSScreenComponentProcedure(@mmmFAddSechenieButtonProcedure);
	end
else
	begin
	FAddSechenieButton.Visible := True;
	FAddSechenieButton.Active  := True;
	end;

if FDeleteSechenieButton = nil then
	begin
	FDeleteSechenieButton:=TSScreenButton.Create();
	Screen.CreateInternalComponent(FDeleteSechenieButton);
	FDeleteSechenieButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*7,W,FTahomaFont.FontHeight+2);
	FDeleteSechenieButton.BoundsMakeReal();
	FDeleteSechenieButton.Anchors:=[SAnchRight];
	FDeleteSechenieButton.Visible:=True;
	FDeleteSechenieButton.Active :=False;
	FDeleteSechenieButton.Skin := FDeleteSechenieButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FDeleteSechenieButton.Caption:='Не рассмотривать сечение';
	FDeleteSechenieButton.UserPointer:=Klass;
	FDeleteSechenieButton.OnChange:=TSScreenComponentProcedure(@mmmFDeleteSechenieButtonProcedure);
	end
else
	begin
	FDeleteSechenieButton.Visible := True;
	FDeleteSechenieButton.Active  := False;
	end;

if FAddSechSecondPanelButton = nil then
	begin
	FAddSechSecondPanelButton:=TSScreenButton.Create();
	Screen.CreateInternalComponent(FAddSechSecondPanelButton);
	FAddSechSecondPanelButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*8,W,FTahomaFont.FontHeight+2);
	FAddSechSecondPanelButton.BoundsMakeReal();
	FAddSechSecondPanelButton.Anchors:=[SAnchRight];
	FAddSechSecondPanelButton.Visible:=True;
	FAddSechSecondPanelButton.Active :=False;
	FAddSechSecondPanelButton.Skin := FAddSechSecondPanelButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FAddSechSecondPanelButton.Caption:='Вычисление концентрации';
	FAddSechSecondPanelButton.UserPointer:=Klass;
	FAddSechSecondPanelButton.OnChange:=TSScreenComponentProcedure(@mmmFAddSechSecondPanelButtonProcedure);
	end
else
	begin
	FAddSechSecondPanelButton.Visible := True;
	FAddSechSecondPanelButton.Active  := False;
	end;

if FSaveImageButton = nil then
	begin
	FSaveImageButton:=TSScreenButton.Create();
	Screen.CreateInternalComponent(FSaveImageButton);
	FSaveImageButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*9,W,FTahomaFont.FontHeight+2);
	FSaveImageButton.BoundsMakeReal();
	FSaveImageButton.Anchors:=[SAnchRight];
	FSaveImageButton.Visible:=True;
	FSaveImageButton.Active :=False;
	FSaveImageButton.Skin := FSaveImageButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
	FSaveImageButton.Caption:='Сoхранить картинку';
	FSaveImageButton.UserPointer:=Klass;
	FSaveImageButton.OnChange:=TSScreenComponentProcedure(@mmmFSaveImageButtonProcedure);
	end
else
	begin
	FSaveImageButton.Visible := True;
	FSaveImageButton.Active  := False;
	end;
end;end;

procedure mmmFStartSceneButtonProcedure(Button:TSScreenButton);
begin with TSGasDiffusion(Button.UserPointer) do begin
	FStartingFlag := 1;
	FStartingThread := TSThread.Create(TSThreadProcedure(@mmmFStartingThreadProcedure),Button.UserPointer,True);
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

procedure mmmFUpdateButtonProcedure(Button : TSScreenButton);
begin with TSGasDiffusion(Button.UserPointer) do begin
	UpDateSavesComboBox();
end;end;

procedure mmmFMovieBackToMenuButtonProcedure(Button:TSScreenButton);
begin with TSGasDiffusion(Button.UserPointer) do begin
	FMoviePlayed := False;
	FMovieBackToMenuButton.Visible:=False;
	FMoviePauseButton.Visible:=False;
	FMoviePlayButton.Visible:=False;
	FLoadScenePanel.Visible := True;
	FInfoLabel.Caption:='';
	if F3dObject<>nil then
		begin
		F3dObject.Destroy();
		F3dObject:=nil;
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

procedure mmmFMoviePauseButtonProcedure(Button:TSScreenButton);
begin with TSGasDiffusion(Button.UserPointer) do begin
	FMoviePlayed := False;
	FMoviePauseButton.Active := False;
	FMoviePlayButton.Active := True;
end;end;

procedure mmmFMoviePlayButtonProcedure(Button:TSScreenButton);
begin with TSGasDiffusion(Button.UserPointer) do begin
	FMoviePlayed := True;
	FMoviePauseButton.Active := True;
	FMoviePlayButton.Active := False;
end;end;

procedure mmmFLoadButtonProcedure(Button:TSScreenButton);
procedure ReadCadrs();
begin with TSGasDiffusion(Button.UserPointer) do begin
FFileStream.Position := 0;
SetLength(FArCadrs,0);
while FFileStream.Position<>FFileStream.Size do
	begin
	SetLength(FArCadrs,Length(FArCadrs)+1);
	FArCadrs[High(FArCadrs)]:=FFileStream.Position;
	
	F3dObject:=TSCustomModel.Create();
	F3dObject.Context := Context;
	TS3dObjectS3DMLoader.LoadModel(F3dObject, FFileStream);
	F3dObject.Destroy();
	F3dObject:=nil;
	end;
FFileStream.Position := 0;
end; end;
const
	W = 200;
begin with TSGasDiffusion(Button.UserPointer) do begin
	FLoadScenePanel.Visible := False;
	FFileName := FLoadComboBox.Items[FLoadComboBox.SelectItem].Caption;
	FFileName := PredStr+Catalog+DirectorySeparator+FFileName;
	FFileStream := TFileStream.Create(FFileName,fmOpenRead);
	FEnableSaving := False;
	ReadCadrs();
	FNowCadr:=0;
	FMoviePlayed:=True;
	
	F3dObject:=TSCustomModel.Create();
	F3dObject.Context := Context;
	FFileStream.Position:=FArCadrs[FNowCadr];
	TS3dObjectS3DMLoader.LoadModel(F3dObject, FFileStream);
	
	if FMovieBackToMenuButton = nil then
		begin
		FMovieBackToMenuButton:=TSScreenButton.Create();
		Screen.CreateInternalComponent(FMovieBackToMenuButton);
		FMovieBackToMenuButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*0,W,FTahomaFont.FontHeight+2);
		FMovieBackToMenuButton.BoundsMakeReal();
		FMovieBackToMenuButton.Anchors:=[SAnchRight];
		FMovieBackToMenuButton.Visible := True;
		FMovieBackToMenuButton.Active  := True;
		FMovieBackToMenuButton.Skin := FMovieBackToMenuButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
		FMovieBackToMenuButton.Caption :='В меню загрузок';
		FMovieBackToMenuButton.UserPointer:=Button.UserPointer;
		FMovieBackToMenuButton.OnChange:=TSScreenComponentProcedure(@mmmFMovieBackToMenuButtonProcedure);
		end
	else
		begin
		FMovieBackToMenuButton.Visible := True;
		FMovieBackToMenuButton.Active  := True;
		end;
	
	if FMoviePlayButton = nil then
		begin
		FMoviePlayButton:=TSScreenButton.Create();
		Screen.CreateInternalComponent(FMoviePlayButton);
		FMoviePlayButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*1,W,FTahomaFont.FontHeight+2);
		FMoviePlayButton.BoundsMakeReal();
		FMoviePlayButton.Anchors:=[SAnchRight];
		FMoviePlayButton.Visible := True;
		FMoviePlayButton.Active  := False;
		FMoviePlayButton.Skin := FMoviePlayButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
		FMoviePlayButton.Caption :='Воспроизведение';
		FMoviePlayButton.UserPointer:=Button.UserPointer;
		FMoviePlayButton.OnChange:=TSScreenComponentProcedure(@mmmFMoviePlayButtonProcedure);
		end
	else
		begin
		FMoviePlayButton.Visible := True;
		FMoviePlayButton.Active  := False;
		end;
	if FMoviePauseButton = nil then
		begin
		FMoviePauseButton:=TSScreenButton.Create();
		Screen.CreateInternalComponent(FMoviePauseButton);
		FMoviePauseButton.SetBounds(Screen.Width-W-10,5+(FTahomaFont.FontHeight+6)*2,W,FTahomaFont.FontHeight+2);
		FMoviePauseButton.BoundsMakeReal();
		FMoviePauseButton.Anchors:=[SAnchRight];
		FMoviePauseButton.Visible := True;
		FMoviePauseButton.Active  := True;
		FMoviePauseButton.Skin := FMoviePauseButton.Skin.CreateDependentSkinWithAnotherFont(FTahomaFont);
		FMoviePauseButton.Caption :='Пауза';
		FMoviePauseButton.UserPointer:=Button.UserPointer;
		FMoviePauseButton.OnChange:=TSScreenComponentProcedure(@mmmFMoviePauseButtonProcedure);
		end
	else
		begin
		FMoviePauseButton.Visible := True;
		FMoviePauseButton.Active  := True;
		end;
end;end;
procedure mmmFEnableLoadButtonProcedure(Button:TSScreenButton);
begin
with TSGasDiffusion(Button.UserPointer) do
	begin
	FLoadScenePanel.Visible := True;
	FNewScenePanel .Visible := False;
	UpDateSavesComboBox();
	end;
end;
// =====================================================================
// =====================================================================
// =====================================================================
procedure mmmFRedactrReliefOpenFileButton(Button:TSScreenButton);
var
	FileWay : String = '';
	IsInFullscreen : Boolean = False;
	T, E : TSBoolean;
begin with TSGasDiffusion(Button.UserPointer) do begin
IsInFullscreen := Context.Fullscreen;
if IsInFullscreen then
	begin
	Context.Fullscreen := False;
	Context.Messages(); //Обязательно 3 раза, иначе hWindow не обновляется
	Context.Messages();
	Context.Messages();
	end;
FileWay := Context.FileOpenDialog('Выберите файл рельефа','Файлы рельефа(*.sggdrf)'+#0+'*.sggdrf'+#0+'All files(*.*)'+#0+'*.*'+#0+#0);
if (FileWay <> '') and (SFileExists(FileWay)) then
	begin
	T := FRelefRedactor.SingleRelief^.FType;
	E := FRelefRedactor.SingleRelief^.FEnabled;
	FRelefRedactor.SingleRelief^.Clear();
	FRelefRedactor.SingleRelief^.Load(FileWay);
	FRelefRedactor.SingleRelief^.FType := T;
	FRelefRedactor.SingleRelief^.FEnabled := E;
	FRelefOptionPanel.InternalComponents[1].Caption := 'Статус рельефа:Загружен('+SFileName(FileWay)+'.'+SDownCaseString(SFileExtension(FileWay))+')';
	(FRelefOptionPanel.InternalComponents[1] as TSScreenLabel).TextColor := SVertex4fImport(0,1,0,1);
	end;
if IsInFullscreen then
	Context.Fullscreen := True;
end; end;
procedure mmmFRedactrReliefSaveFileButton(Button:TSScreenButton);
var
	FileWay : String = '';
	IsInFullscreen : Boolean = False;
begin with TSGasDiffusion(Button.UserPointer) do begin
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
procedure mmmFRedactrReliefBackButton(Button:TSScreenButton);
begin with TSGasDiffusion(Button.UserPointer) do begin
FRelefRedactor.SetActiveSingleRelief();
FRelefOptionPanel.AddToLeft  (((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width) div 2) + 5);
FRelefOptionPanel.Visible := False;
FBoundsOptionsPanel.Active := True;
FNewScenePanel.AddToLeft     (((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width) div 2) + 5);
FBoundsOptionsPanel.AddToLeft(((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width) div 2) + 5);
end;end;

procedure mmmFRedactorBackButton(Button:TSScreenButton);
begin with TSGasDiffusion(Button.UserPointer) do begin
Button.Visible := False;
Button.Active := False;
if FRelefOptionPanel <> nil then
	begin
	FRelefOptionPanel.InternalComponents[1].Caption := 'Статус рельефа:теоритически изменен';
	(FRelefOptionPanel.InternalComponents[1] as TSScreenLabel).TextColor := SVertex4fImport(0,1,0,1);
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

procedure mmmFRedactrReliefRedactrReliefButton(Button:TSScreenButton);
begin with TSGasDiffusion(Button.UserPointer) do begin
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

procedure mmmFRedactrRelief(Button:TSScreenButton);
var
	FConstWidth : LongWOrd = 300;
begin with TSGasDiffusion(Button.UserPointer) do begin
FRelefRedactor.SetActiveSingleRelief(Button.ComponentOwner.IndexOf(Button) - 6);
if (FRelefOptionPanel = nil) then
	begin
	FRelefOptionPanel := SCreatePanel(Screen, FConstWidth,155, True, True, Button.UserPointer);
	FRelefOptionPanel.AddToLeft(((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width)div 2) + 5);
	FRelefOptionPanel.AddToTop(285);
	Screen.LastInternalComponent.BoundsMakeReal();
	FRelefOptionPanel.AddToLeft(- ((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width)div 2) - 5);
	Screen.LastInternalComponent.VisibleTimer := 0.3;
	
	SCreateLabel(FRelefOptionPanel, 'Статус рельефа:Неопределен', 10,10,FRelefOptionPanel.Width - 30,19, FTahomaFont, True, True, Button.UserPointer);
	SCreateButton(FRelefOptionPanel, 'Загрузить рельеф из файла', 10,10+(19+5)*1,FRelefOptionPanel.Width - 30,19, TSScreenComponentProcedure(@mmmFRedactrReliefOpenFileButton),
		FTahomaFont, True, False, Button.UserPointer);
	SCreateButton(FRelefOptionPanel, 'Сохранить рельеф в файл', 10,10+(19+5)*2,FRelefOptionPanel.Width - 30,19, TSScreenComponentProcedure(@mmmFRedactrReliefSaveFileButton),
		FTahomaFont, True, False, Button.UserPointer);
	SCreateButton(FRelefOptionPanel, 'Редактировать рельеф', 10,10+(19+5)*3,FRelefOptionPanel.Width - 30,19, TSScreenComponentProcedure(@mmmFRedactrReliefRedactrReliefButton),
		FTahomaFont, True, False, Button.UserPointer).Active := {$IFDEF MOBILE}False{$ELSE}True{$ENDIF};
	SCreateButton(FRelefOptionPanel, 'Назад', 10,10+(19+5)*4,FRelefOptionPanel.Width - 30,19, TSScreenComponentProcedure(@mmmFRedactrReliefBackButton),
		FTahomaFont, True, False, Button.UserPointer);
	end
else
	begin
	FRelefOptionPanel.Visible := True;
	FRelefOptionPanel.Active := True;
	FRelefOptionPanel.AddToLeft(- ((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width)div 2) - 5);
	FRelefOptionPanel.VisibleTimer := 0.3;
	end;
(FRelefOptionPanel.InternalComponents[1] as TSScreenLabel).TextColor := SVertex4fImport(1,0,0,1);
FNewScenePanel.AddToLeft(- ((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width)div 2) - 5);
FBoundsOptionsPanel.AddToLeft(- ((FRelefOptionPanel.Width + FBoundsOptionsPanel.Width)div 2) - 5);
FBoundsOptionsPanel.Active := False;
end; end;
procedure mmmChangeBoundTypeComboBoxProcedure(b,c : LongInt;a : TSScreenComboBox);
var
	index : LongInt;
begin with TSGasDiffusion(a.UserPointer) do begin
index := a.ComponentOwner.IndexOf(a);
if index <> -1 then
	begin
	(a.ComponentOwner.InternalComponents[index + 7] as TSScreenButton).Active := c > 0;
	FRelief.FData[index].FEnabled := c > 0;
	FRelief.FData[index].FType := c > 1
	end;
end; end;
procedure mmmFBoundsBackButtonProcedure(Button:TSScreenButton);
const
	FConstHeight : LongWord = 280;
begin with TSGasDiffusion(Button.UserPointer) do begin
FNewScenePanel.AddToLeft(((FNewScenePanel.Width + FBoundsOptionsPanel.Width)div 2) + 5);
FNewScenePanel.Active := True;
FNewScenePanel.AddToTop( - FConstHeight - 5);
FBoundsOptionsPanel.AddToLeft(((FNewScenePanel.Width + FBoundsOptionsPanel.Width)div 2) + 5);
FBoundsOptionsPanel.Active := False;
FBoundsOptionsPanel.Visible := False;
FBoundsOptionsPanel.VisibleTimer := 0.7;
FBoundsOptionsPanel.DrawClass := nil;
end; end;

procedure mmmFBoundsTypeButtonProcedure(Button:TSScreenButton);
var
	FConstWidth : LongWord = 500;
	FConstLoad3dObjectButtonWidth : LongWord = 120;
	FConstLabelsWidth : LongWOrd = 90;

procedure CreteCOmboBox(const vIndex : LongWord; const vPanel : TSScreenPanel);
begin with TSGasDiffusion(Button.UserPointer) do begin
with SCreateComboBox(FBoundsOptionsPanel, 10 + FConstLabelsWidth + 10,5+(19+5)*vIndex,FConstWidth-50-FConstLoad3dObjectButtonWidth - FConstLabelsWidth,19,
	TSScreenComboBoxProcedure(@mmmChangeBoundTypeComboBoxProcedure), FTahomaFont, True, True, Button.UserPointer) do
	begin
	CreateItem('Стенкa пропускают газ');
	CreateItem('Стенкa не пропускают газ');
	CreateItem('Газ липнет к стенкe');
	SelectItem := 0;
	end;
end;end;
procedure CreteLabel(const vIndex : LongWord; const vPanel : TSScreenPanel);
var
	ScreenLabel : TSScreenLabel;
begin with TSGasDiffusion(Button.UserPointer) do begin
ScreenLabel := SCreateLabel(FBoundsOptionsPanel, '', 10 ,5+(19+5)*vIndex,FConstLabelsWidth,19, FTahomaFont, True, True, Button.UserPointer);
case vIndex of
0 : ScreenLabel.Caption := 'Верхняя';
1 : ScreenLabel.Caption := 'Нижня';
2 : ScreenLabel.Caption := 'Левая';
3 : ScreenLabel.Caption := 'Правая';
4 : ScreenLabel.Caption := 'Задняя';
5 : ScreenLabel.Caption := 'Передняя';
end;
end;end;
procedure CreteLoad3dObjectButton(const vIndex : LongWord; const vPanel : TSScreenPanel);
begin with TSGasDiffusion(Button.UserPointer) do begin
SCreateButton(FBoundsOptionsPanel, 'Настроить рельеф', FConstWidth - 20 - FConstLoad3dObjectButtonWidth,5+(19+5)*vIndex,FConstLoad3dObjectButtonWidth,19, 
	TSScreenComponentProcedure(@mmmFRedactrRelief), FTahomaFont, True, True, Button.UserPointer).Active := False;
end;end;
const
	FConstHeight : LongWord = 280;
var
	i : LongWord;
begin with TSGasDiffusion(Button.UserPointer) do begin
FNewScenePanel.AddToLeft(- ((FNewScenePanel.Width + FConstWidth)div 2) - 5);
FNewScenePanel.AddToTop(FConstHeight + 5);
FNewScenePanel.Active := False;
if FBoundsOptionsPanel = nil then
	begin
	FBoundsOptionsPanel := SCreatePanel(Screen, FConstWidth,185, True, True, Button.UserPointer);
	FBoundsOptionsPanel.AddToLeft( FConstWidth + 5);
	FBoundsOptionsPanel.AddToTop( FConstHeight + 5);
	Screen.LastInternalComponent.BoundsMakeReal();
	FBoundsOptionsPanel.AddToLeft(- FConstWidth - 5);
	Screen.LastInternalComponent.VisibleTimer := 0.3;
	
	for i := 0 to 5 do
		CreteCOmboBox(i,FBoundsOptionsPanel);
	for i := 0 to 5 do
		CreteLoad3dObjectButton(i,FBoundsOptionsPanel);
	for i := 0 to 5 do
		CreteLabel(i,FBoundsOptionsPanel);
	
	SCreateButton(FBoundsOptionsPanel, 'Назад', (FConstWidth - FConstLoad3dObjectButtonWidth )div 2,149,FConstLoad3dObjectButtonWidth,19,
		TSScreenComponentProcedure(@mmmFBoundsBackButtonProcedure), FTahomaFont, True, True, Button.UserPointer);
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
procedure mmmFBackButtonProcedure(Button:TSScreenButton);
begin
with TSGasDiffusion(Button.UserPointer) do
	begin
	FLoadScenePanel.Visible := False;
	FNewScenePanel .Visible := True;
	end;
end;
procedure mmmFOpenSaveDir(Button:TSScreenButton);
begin
{$IFDEF MSWINDOWS}
	Exec('explorer.exe','"'+PredStr+Catalog+'"');
	{$ENDIF}
end;

function mmmFEdgeEditTextTypeFunction(const Self : TSScreenEdit) : TSBoolean;
var
	i : TSQuadWord;
begin
Result := TSEditTextTypeFunctionNumber(Self);
with TSGasDiffusion(Self.UserPointer) do
	begin
	if Result then
		begin
		i := SVal(Self.Caption);
		if (i > 999999) or (i=0) then
			begin
			TSGasDiffusion(Self.UserPointer).FNumberLabel.Caption:='^3= ...';
			Result:=False;
			end
		else
			TSGasDiffusion(Self.UserPointer).FNumberLabel.Caption:='^3='+SStr(i*i*i);
		end
	else
		begin
		TSGasDiffusion(Self.UserPointer).FNumberLabel.Caption:='^3= ...';
		end;
	FStartSceneButton.Active := Result;
	end;
end;

procedure TSGasDiffusion.UpDateSavesComboBox();
var
	ar : TSStringList = nil;
	i : TSLongWord;
	ExC : Boolean = False;
begin
FLoadComboBox.ClearItems();
ar := SDirectoryFiles(PredStr + Catalog + '/', '*.GDS');
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

procedure TSGasDiffusion.UpDateConchLabels();
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
		FConchLabels[i] := SCreateLabel(Screen, '', False, 5,50+i*22,400,20, FTahomaFont, True, True);
	end
else while lghl > lghg + 1 do
	begin
	FConchLabels[High(FConchLabels)].Destroy();
	SetLength(FConchLabels,lghl-1);
	end;
j := FCube.Edge*FCube.Edge*FCube.Edge;
FConchLabels[0].Caption := 'Концентрация всех газов: '+SStrReal(100*FCube.FDinamicQuantityMoleculs/j,4) + '%';
FConchLabels[0].Visible:=True;
for i:=1 to High(FConchLabels) do
	begin
	FConchLabels[i].Caption := 'Концентрация газа №'+SStr(i)+': '+SStrReal(100*FCube.FGazes[i-1].FDinamicQuantity/j,4) + '%';
	FConchLabels[i].Visible:=True;
	end;
end;

constructor TSGasDiffusion.Create(const VContext : ISContext);
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
F3dObject                     := nil;
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
FRelefRedactor := TSGasDiffusionReliefRedactor.Create(VContext);
FRelefRedactor.Relief := @FRelief;

FCamera:=TSCamera.Create();
FCamera.SetContext(Context);
//FCamera.Zum := Render.Height/Render.Width;

FTahomaFont := SCreateFontFromFile(Context, SDefaultFontFileName);

FStartingProgressBar := TSScreenProgressBar.Create();
Screen.CreateInternalComponent(FStartingProgressBar);
Screen.LastInternalComponent.SetBounds(Render.Width div 2 - 151,Render.Height div 2 - 100, 300, 20);
Screen.LastInternalComponent.BoundsMakeReal();
Screen.LastInternalComponent.Visible:=False;
FStartingProgressBar.Progress := 0;

FRedactorBackButton := SCreateButton(Screen, 'Назад', Render.Width div 2 - 75,5,130,20, TSScreenComponentProcedure(@mmmFRedactorBackButton),
	FTahomaFont, False, True, Self);
FNewScenePanel := SCreatePanel(Screen, 400,110+26, True, True, Self);
SCreateLabel(FNewScenePanel, 'Создание новой сцены', 5,0,275+100,20, FTahomaFont, True, True);
SCreateLabel(FNewScenePanel, 'Количество точек:', False, 5,19,280,20, FTahomaFont, True, True);
FNumberLabel := SCreateLabel(FNewScenePanel, '', False, 170,19,180,20, FTahomaFont, True, True);
FStartSceneButton := SCreateButton(FNewScenePanel, 'Старт', 10,44,80,20, TSScreenComponentProcedure(@mmmFStartSceneButtonProcedure),
	FTahomaFont, True, True, Self);
FEdgeEdit := SCreateEdit(FNewScenePanel, '75', TSScreenEditTextTypeFunction(@mmmFEdgeEditTextTypeFunction), 118,19,50,20, FTahomaFont, True, True, Self);
FEnableLoadButton := SCreateButton(FNewScenePanel, 'Загрузка сохраненной сцены/повтора', 100,44,278,20, TSScreenComponentProcedure(@mmmFEnableLoadButtonProcedure),
	FTahomaFont, True, True, Self);

FEnableOutputComboBox := SCreateComboBox(FNewScenePanel, 10,44+26,380-10,19, nil, {TSScreenComboBoxProcedure(@FEnableOutputComboBoxProcedure),} 
	FTahomaFont, True, True, Self);
FEnableOutputComboBox.CreateItem('Включить непрерывное сохранение эмуляции');
FEnableOutputComboBox.CreateItem('Не включать непрерывное сохранение эмуляции');
FEnableOutputComboBox.SelectItem := {$IFDEF RELIEFDEBUG}1{$ELSE}{$IFDEF MOBILE}1{$ELSE}0{$ENDIF}{$ENDIF};

FBoundsTypeButton := SCreateButton(FNewScenePanel, 'Настроить поведение газа на границах',10,44+26+25,380-10,19,TSScreenComponentProcedure(@mmmFBoundsTypeButtonProcedure),
	FTahomaFont, True, True, Self);
FLoadScenePanel := SCreatePanel(Screen, 440,105, False, True,  Self);
SCreateLabel(FLoadScenePanel, 'Загрузка сохраненной сцены/повтора', 5,0,275+140,20, FTahomaFont, False, True);

FLoadComboBox := SCreateComboBox(FLoadScenePanel, 5,21,480-60,19, nil, {TSScreenComboBoxProcedure(@FLoadComboBoxProcedure),} FTahomaFont, False, True, Self);
FLoadComboBox.SelectItem := -1;

FBackButton := SCreateButton(FLoadScenePanel, 'Назад', 10,44,130,20, TSScreenComponentProcedure(@mmmFBackButtonProcedure),
	FTahomaFont, False, True, Self);
FUpdateButton := SCreateButton(FLoadScenePanel, 'Обновить', 145,44,130,20, TSScreenComponentProcedure(@mmmFUpdateButtonProcedure),
	FTahomaFont, False, True, Self);
FLoadButton := SCreateButton(FLoadScenePanel, 'Загрузить', 145+135,44,130,20, TSScreenComponentProcedure(@mmmFLoadButtonProcedure),
	FTahomaFont, False, True, Self);
SCreateButton(FLoadScenePanel, 'Открыть папку с сохранениями', 5,44+24,420,20, TSScreenComponentProcedure(@mmmFOpenSaveDir),
	FTahomaFont, False, True, Self);
FInfoLabel := SCreateLabel(Screen, '', 5,Render.Height-25,Render.Width-10,20, FTahomaFont, [SAnchBottom], True, True);
end;

procedure TSGasDiffusion.UpDateChangeSourses();
var
	b, a : TSVertex3f;
	s, Plane : TSLongWord;
function Range(const i : TSLongInt):TSLongWord;
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
s := (FAddNewSoursePanel.InternalComponents[1] as TSScreenComboBox).SelectItem;
a.Import(2*FCube.FSourses[s].FCoord.z/FCube.Edge-1,
		 2*FCube.FSourses[s].FCoord.y/FCube.Edge-1,
		 2*FCube.FSourses[s].FCoord.x/FCube.Edge-1);
Render.Color3f(1,$A5/256,0);
Render.BeginScene(SR_LINE_LOOP);
Render.Vertex3f(1,-1,a.z);
Render.Vertex3f(-1,-1,a.z);
Render.Vertex3f(-1,1,a.z);
Render.Vertex3f(1,1,a.z);
Render.EndScene();
Render.BeginScene(SR_LINE_LOOP);
Render.Vertex3f(1,a.y,-1);
Render.Vertex3f(-1,a.y,-1);
Render.Vertex3f(-1,a.y,1);
Render.Vertex3f(1,a.y,1);
Render.EndScene();
Render.BeginScene(SR_LINE_LOOP);
Render.Vertex3f(a.x,1,-1);
Render.Vertex3f(a.x,-1,-1);
Render.Vertex3f(a.x,-1,1);
Render.Vertex3f(a.x,1,1);
Render.EndScene();

{$IFNDEF MOBILE}
	DrawComplexCube();
	b := SGetVertexUnderPixel(Render,Context.CursorPosition());
	if Abs(b) < 2 then
		begin
		if FSourseChangeFlag = 0 then
			begin
			Plane := Byte(Abs(a.y-b.y) < 0.11);
			if Plane=0 then
				Plane := Byte(Abs(a.z-b.z) < 0.11)*2;
			if Plane=0 then
				Plane := Byte(Abs(a.x-b.x) < 0.11)*3;
			if (Context.CursorKeyPressed() = SLeftCursorButton) and (Context.CursorKeyPressedType() = SDownKey) then
				begin
				if Plane <> 0 then
					begin
					FSourseChangeFlag := s + 1;
					FSourseChangeFlag2 := Plane - 1;
					end;
				end;
			end
		else if (Context.CursorKeyPressedType() <> SUpKey) then
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
			F3dObject.Destroy();
			F3dObject:=FCube.Calculate3dObject(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
			end
		else
			FSourseChangeFlag := 0;
		end
	else
		FSourseChangeFlag := 0;
	{$ENDIF}
Render.Color3f(1,1,1);
end;

procedure TSGasDiffusion.Paint();
procedure DrawSechenie();
var
	a,b,c,d : TSVertex3f;
procedure DrawQuadSec(const Primitive : TSLongWord);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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
	DrawQuadSec(SR_QUADS);
	end;
Render.Color4f($80/255,0,$80/255,0.7);
DrawQuadSec(SR_LINE_LOOP);
end;
procedure UpDateAfterUsrThread();
begin
FUsrSechImage.FreeTexture();
FUsrSechImage.BitMap.FreeData();
FUsrSechImage.BitMap.ReAllocateMemory();
Move(FUsrSechImageForThread.BitMap.Data^,FUsrSechImage.BitMap.Data^, FUsrSechImage.BitMap.DataSize);
FUsrSechImage.LoadTexture();
SKill(FUsrSechImageForThread);
FUpdateUsrAfterThread := False;
SKill(FUsrSechThread);
FAddSechSecondPanelButton.Active := True;
(FUsrSechPanel.InternalComponents[2] as TSScreenProgressBar).Visible := False;
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
if F3dObject <> nil then
	begin
	if FSourseChangeFlag=0 then
		FCamera.Move();
	FCamera.InitMatrix();
	F3dObject.Paint();
	if (FSecheniePanel<>nil) then
		DrawSechenie();
	if FDiffusionRuned then
		begin
		if FEnableSaving then 
			begin
			if (Render.RenderType in [SRenderDirectX9,SRenderDirectX8]) then
				if F3dObject.QuantityObjects<>0 then
					for i := 0 to F3dObject.QuantityObjects-1 do 
						F3dObject.Objects[i].Change3dObjectColorType4b();
			SaveStageToStream();
			end;
		F3dObject.Destroy();
		FCube.UpDateCube();
		F3dObject:=FCube.Calculate3dObject(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
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
		if F3dObject<>nil then
			F3dObject.Destroy();
		F3dObject:=TSCustomModel.Create();
		F3dObject.Context := Context;
		FNowCadr+=1;
		if FNowCadr > High(FArCadrs) then
			FNowCadr:=0;
		FFileStream.Position:=FArCadrs[FNowCadr];
		TS3dObjectS3DMLoader.LoadModel(F3dObject, FFileStream);
		if (Render.RenderType in [SRenderDirectX9,SRenderDirectX8]) then
			if F3dObject.QuantityObjects<>0 then
				for i := 0 to F3dObject.QuantityObjects-1 do 
					F3dObject.Objects[i].Change3dObjectColorType4b();
		end;
	if FDiffusionRuned or FMoviePlayed then
		UpDateInfoLabel();
	UpDateConchLabels();
	{$IFDEF RELIEFDEBUG}
		if Context.KeyPressed() and (Context.KeyPressedType() = SUpKey) and (Context.KeyPressedChar() = 'D') then
			begin
			FInReliafDebug += 1;
			if FInReliafDebug = 3 then
				FInReliafDebug := 0;
			F3dObject.Destroy();
			F3dObject:=FCube.Calculate3dObject(@FRelief{$IFDEF RELIEFDEBUG},FInReliafDebug{$ENDIF});
			end;
		{$ENDIF}
	end;
end;

procedure TSGasDiffusion.UpDateInfoLabel();
begin
if FMoviePlayed then
	begin
	FInfoLabel.Caption:='Размер файла: "'+SMemorySizeToString(FFileStream.Size,'RU')+'", Итераций: "'+SStr(Length(FArCadrs))+'", Позиция: "'+SStrReal(FNowCadr/Length(FArCadrs)*100,2)+'%"';
	end
else if FDiffusionRuned then
	begin
	FInfoLabel.Caption:='';
	if FEnableSaving and (FFileStream<>nil)then
		FInfoLabel.Caption:=FInfoLabel.Caption+'Размер файла: "'+SMemorySizeToString(FFileStream.Size,'RU')+'", ';
	if (F3dObject<>nil) and (F3dObject.LastObject()<>nil) then
		FInfoLabel.Caption:=FInfoLabel.Caption+'Итерация: "'+SStr(FNowCadr)+'", Количество точек: "'+SStr(FCube.FDinamicQuantityMoleculs)+'"'
	end;
end;

initialization
begin
SRegisterDrawClass(TSGasDiffusion);
end;

end.
