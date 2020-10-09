{$INCLUDE Smooth.inc}

unit SmoothCamera;

interface

uses
	 SmoothBase
	,SmoothCommonStructs
	,SmoothContextClasses
	,SmoothMatrix
	,SmoothMath
	,SmoothCasesOfPrint
	,SmoothContextInterface
	,SmoothCursor
	;
type
	TSCameraMatrixMode = TSUInt32;
	TSCameraViewMode = (SMotileObject, SMotileObjective);
	TSCameraFloat  = TSFloat32;
	TSCameraVector = TSVector3f;
	TSCamera = class(TSContextObject)
			public
		constructor Create();override;
		constructor Create(const _Context : ISContext; const _MatrixMode : TSCameraMatrixMode);
			private
		FMatrixMode: TSCameraMatrixMode; // S_3D, S_2D, S_ORTHO_3D
		FViewMode  : TSCameraViewMode; // SMotileObject, SMotileObjective
		FLocation, FView, FUp : TSCameraVector; // Location is point, View and Up is vectors
		FMotile : TSBoolean;
		FMouseClick : TSBoolean;
		FCursorDragAndDropPressed : TSCursor; // drag and drop cursor (pressed)
			protected
		procedure MoveMotileObjective();
		procedure MoveMotileObject();
		procedure Move(const Param : TSCameraFloat); overload;
		procedure MoveSidewards(const Param : TSCameraFloat);
		procedure MoveUp(const Param : TSCameraFloat);
		procedure Rotate(const x, y, z : TSCameraFloat);
		procedure SetMotile(const _Motile : TSBoolean);
		procedure SetViewMode(const _ViewMode : TSCameraViewMode);
		procedure SetLocation(const _Location : TSCameraVector);
			public
		procedure Move();{$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		procedure ViewInfo(const PredString : TSString = ''; const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure InitMatrix();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure InitMatrixAndMove();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ProjectionMatrix() : TSMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function ModelViewMatrix() : TSMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure InitViewModeComboBox();virtual;abstract;
			public
		property Up        : TSCameraVector read FUp         write FUp;
		property Location  : TSCameraVector read FLocation   write SetLocation;
		property View      : TSCameraVector read FView       write FView;
		property MatrixMode: TSCameraMatrixMode read FMatrixMode write FMatrixMode;
		property ViewMode  : TSCameraViewMode read FViewMode   write SetViewMode;
		property Motile    : TSBoolean  read FMotile     write SetMotile;
		end;

function SStrMatrixMode(const Mode : TSCameraMatrixMode) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SStrViewMode(const Mode : TSCameraViewMode) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SKill(var Camera : TSCamera); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothRenderBase
	,SmoothLog
	,SmoothContext
	,SmoothCommon
	,SmoothStringUtils
	,SmoothContextUtils
	,SmoothFileUtils
	;

procedure SKill(var Camera : TSCamera); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if Camera <> nil then
	begin
	Camera.Destroy();
	Camera := nil;
	end;
end;

function SStrMatrixMode(const Mode : TSCameraMatrixMode) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case Mode of
S_3D : Result := 'S_3D';
S_2D : Result := 'S_2D';
S_3D_ORTHO : Result := 'S_3D_ORTHO';
else Result := 'UNKNOWN(' + SStr(Mode) + ')';
end;
end;

function SStrViewMode(const Mode : TSCameraViewMode) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case Mode of
SMotileObject   : Result := 'SMotileObject';
SMotileObjective : Result := 'SMotileObjective';
else Result := 'UNKNOWN(' + SStr(TSMaxEnum(Mode)) + ')';
end;
end;

// TSCamera

procedure TSCamera.SetLocation(const _Location : TSCameraVector);
begin
FLocation := _Location;
if (FViewMode = SMotileObject) then
	FView := -FLocation.Normalized();
end;

procedure TSCamera.SetViewMode(const _ViewMode : TSCameraViewMode);
begin
FViewMode := _ViewMode;
if (FViewMode = SMotileObject) and (Abs(FLocation) + Abs(FView) + Abs(FUp) < 0.00001) then
	begin
	FLocation.Import(0, 0, 10);
	FUp.Import(0, 1, 0);
	FView.Import(0, 0, -1);
	end;
end;

procedure TSCamera.SetMotile(const _Motile : TSBoolean);
var
	TempBool : TSBoolean;
begin
FMotile := _Motile;
TempBool := (SMotileObjective = FViewMode) and FMotile;
Context.CursorCentered := TempBool;
Context.ShowCursor(not TempBool);
end;

procedure TSCamera.ViewInfo(const PredString : TSString = ''; const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SHint([PredString, 'TSCamera__ViewInfo(..).'], CasesOfPrint);
SHint([PredString,     '  MatrixMode     = "', SStrMatrixMode(FMatrixMode), '"'], CasesOfPrint);
SHint([PredString,     '  ViewMode       = "', SStrViewMode(FViewMode), '"'], CasesOfPrint);

SHint([PredString, '  Motile = "', FMotile, '"'], CasesOfPrint);
SHint([PredString, '  Location       = "', SStrVector3f(FLocation, 7), '"'], CasesOfPrint);
SHint([PredString, '  Up             = "', SStrVector3f(FUp, 7), '"'], CasesOfPrint);
SHint([PredString, '  View           = "', SStrVector3f(FView, 7), '"'], CasesOfPrint);
end;

function TSCamera.ProjectionMatrix() : TSMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Render.GetFloatv(SR_PROJECTION_MATRIX, @Result);
end;

function TSCamera.ModelViewMatrix() : TSMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Render.GetFloatv(SR_MODELVIEW_MATRIX, @Result);
end;

constructor TSCamera.Create(const _Context : ISContext; const _MatrixMode : TSCameraMatrixMode);
begin
Create();
Context := _Context;
MatrixMode := _MatrixMode;
end;

constructor TSCamera.Create();
begin
inherited;
FCursorDragAndDropPressed := SCreateCursorFromFile(SEngineDirectory + DirectorySeparator + 'drag and drop cursor (pressed).cur');
FMouseClick := False;
FMatrixMode := S_3D;
FMotile := True;
Clear();
ViewMode := SMotileObject;
end;

procedure TSCamera.MoveMotileObjective();
const
	RotateConst = 0.002;
var
	Q, E : TSBoolean;
	ElapsedTimeMiltiplier, MoveValue, RotateZ : TSFloat32;
begin
if FMotile then
	begin
	Q := Context.KeysPressed('Q');
	E := Context.KeysPressed('E');
	ElapsedTimeMiltiplier := 0.02 + 0.6*TSUInt8(not Context.KeysPressed(S_SHIFT_KEY)) + 0.07*TSUInt8(not Context.KeysPressed(S_CTRL_KEY));
	MoveValue := Context.ElapsedTime * ElapsedTimeMiltiplier;
	RotateZ :=  TSUInt8(Q xor E) * (TSUInt8(Q) * 2 - 1) * MoveValue * 4;
	Move(MoveValue * (TSUInt8(Context.KeysPressed('W')) - TSUInt8(Context.KeysPressed('S'))));
	MoveSidewards(MoveValue * (TSUInt8(Context.KeysPressed('D')) - TSUInt8(Context.KeysPressed('A'))));
	MoveUp(MoveValue * (TSUInt8(Context.KeysPressed(' ')) - TSUInt8(Context.KeysPressed('X'))));
	Rotate(
		Context.CursorPosition(SDeferenseCursorPosition).y*RotateConst,
		Context.CursorPosition(SDeferenseCursorPosition).x/Context.Width*Context.Height*RotateConst,
		RotateZ*RotateConst)
	//Rotate(0, 0, RotateZ*RotateConst);
	end;
end;

procedure TSCamera.MoveMotileObject();
const
	RotateConst = 0.005;
var
	Sidewards, LocationVector : TSCameraVector;
	LocationAbs, X, Y : TSFloat32;
begin
if FMotile then
	begin
	if Context.CursorWheel=SUpCursorWheel then
		FLocation*=0.9;
	if Context.CursorWheel=SDownCursorWheel then
		FLocation*=1/0.9;
	if (Context.KeyPressed and (Context.KeysPressed(char(17))) and (Context.KeyPressedChar=char(189)) and (Context.KeyPressedType=SDownKey)) then
		FLocation*=1/0.89;
	if (Context.KeyPressed and (Context.KeysPressed(char(17))) and (Context.KeyPressedByte=187) and (Context.KeyPressedType=SDownKey)) then
		FLocation*=0.89;
	if FMouseClick then
		begin
		X := -TSUInt8(Context.CursorKeysPressed(SLeftCursorButton)) * Context.CursorPosition(SDeferenseCursorPosition).y * RotateConst;
		Y := TSUInt8(Context.CursorKeysPressed(SLeftCursorButton)) * Context.CursorPosition(SDeferenseCursorPosition).x * RotateConst;
		if Abs(X) + Abs(Y) > 0.0001 then
			begin
			LocationAbs := Abs(FLocation);
			LocationVector := FLocation / LocationAbs;
			if x<>0 then
				begin
				Sidewards := (LocationVector * Up).Normalized();
				LocationVector := SRotatePoint(LocationVector, Sidewards, -X).Normalized();
				Up := (Sidewards * LocationVector).Normalized();
				end;
			if y<>0 then
				LocationVector := SRotatePoint(LocationVector, Up, -Y).Normalized();
			FLocation := LocationVector * LocationAbs;
			FView := -LocationVector;
			end;
		end
	else if (Context.CursorKeyPressed=SLeftCursorButton) and (Context.CursorKeyPressedType=SDownKey) then
		begin
		FMouseClick := True;
		Context.SetCursorKey(SNullKey, SNullCursorButton);
		Context.Cursor := TSCursor.Copy(FCursorDragAndDropPressed);
		end;
	if (not Context.CursorKeysPressed(SLeftCursorButton)) and FMouseClick then
		begin
		FMouseClick := False;
		Context.Cursor := TSCursor.Create(SC_NORMAL);
		end;
	end;
end;

procedure TSCamera.Move();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case FViewMode of
SMotileObjective: MoveMotileObjective();
SMotileObject: MoveMotileObject();
end;
end;

procedure TSCamera.InitMatrix(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Matrix : TSMatrix4x4;
begin
FUp := FUp.Normalized();
Render.InitMatrixMode(S_3D);
Matrix := SGetLookAtMatrix(FLocation, FView + FLocation, FUp);
Render.MultMatrixf(@Matrix);
end;

procedure TSCamera.Move(const Param : TSCameraFloat);
begin
FLocation := FLocation + FView * Param;
end;

procedure TSCamera.Rotate(const x, y, z : TSCameraFloat);
var
	Sidewards : TSCameraVector;
begin
if x<>0 then
	begin
	Sidewards := (View * Up).Normalized();
	View := SRotatePoint(View, Sidewards, -X).Normalized();
	Up := (Sidewards * View).Normalized();
	end;
if y<>0 then
	View := SRotatePoint(View, Up, -Y).Normalized();
if z<>0 then
	Up := SRotatePoint(Up, View, -Z).Normalized();
end;

procedure TSCamera.MoveUp(const Param : TSCameraFloat);
begin
FLocation := FLocation + FUp * Param;
end;

procedure TSCamera.MoveSidewards(const Param : TSCameraFloat);
begin
FLocation := FLocation + (FView * FUp).Normalized() * Param;
end;

procedure TSCamera.InitMatrixAndMove();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (Context.KeysPressed(S_SHIFT_KEY) and Context.KeysPressed('C') and 
   Context.KeyPressed and (Context.KeyPressedChar = 'W') and (Context.KeyPressedType = SDownKey)) then
	ViewInfo();

Move();
InitMatrix();
end;

procedure TSCamera.Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FLocation.Import(0,0,0);
FView.Import(0,0,0);
FUp.Import(0,0,0);
end;

end.
