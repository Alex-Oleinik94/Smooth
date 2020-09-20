{$INCLUDE Smooth.inc}

unit SmoothCamera;

interface

uses
	 SmoothBase
	,SmoothCommonStructs
	,SmoothContextClasses
	,SmoothMatrix
	,SmoothCasesOfPrint
	,SmoothContextInterface
	;
const
	S_VIEW_WATCH_OBJECT        = $001001;
	S_VIEW_LOOK_AT_OBJECT      = $001002;
type
	TSMode = TSUInt32;
	TSCamera = class(TSContextObject)
			public
		constructor Create();override;
		constructor Create(const _Context : ISContext; const _MatrixMode : TSMode);
			private
		FMatrixMode: TSMode; // S_3D, S_2D, S_ORTHO_3D
		FViewMode  : TSMode; // S_VIEW_...
			// for S_VIEW_WATCH_OBJECT
		FRotateX, FRotateY, FTranslateX, FTranslateY, FZum : TSSingle;
			// for S_VIEW_LOOK_AT_OBJECT
		FLocation : TSVertex3f;
		FView   :TSVertex3f;
		FUp : TSVertex3f;
		FChangingLookAtObject : TSBoolean;
			public
		procedure Change();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ViewInfo(const PredString : TSString = ''; const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure InitMatrix();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure CallAction();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetProjectionMatrix() : TSMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetModelViewMatrix() : TSMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		procedure InitViewModeComboBox();virtual;abstract;
		procedure Move(const Param : TSSingle);
		procedure MoveSidewards(const Param : TSSingle);
		procedure MoveUp(const Param : TSSingle);
		procedure Rotate(const x, y, z : TSSingle);
			public
		property RotateX : TSFloat read FRotateX write FRotateX;
		property RotateY : TSFloat read FRotateY write FRotateY;
		property TranslateX : TSFloat read FTranslateX write FTranslateX;
		property TranslateY : TSFloat read FTranslateY write FTranslateY;
		property Zum : TSFloat read FZum write FZum;
			public
		property Up        : TSVertex3f read FUp         write FUp;
		property Location  : TSVertex3f read FLocation   write FLocation;
		property Position  : TSVertex3f read FLocation   write FLocation;
		property View      : TSVertex3f read FView       write FView;
		property MatrixMode: TSMode     read FMatrixMode write FMatrixMode;
		property ViewMode  : TSMode     read FViewMode   write FViewMode;
		property ChangingLookAtObject : TSBoolean read FChangingLookAtObject write FChangingLookAtObject;
		end;

function SStrMatrixMode(const Mode : TSMode) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SStrViewMode(const Mode : TSMode) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure SKill(var Camera : TSCamera); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothRenderBase
	,SmoothLog
	,SmoothContext
	,SmoothCommon
	,SmoothStringUtils
	,SmoothContextUtils
	;

procedure SKill(var Camera : TSCamera); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if Camera <> nil then
	begin
	Camera.Destroy();
	Camera := nil;
	end;
end;

function SStrMatrixMode(const Mode : TSMode) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case Mode of
S_3D       : Result := 'S_3D';
S_2D       : Result := 'S_2D';
S_3D_ORTHO : Result := 'S_3D_ORTHO';
else          Result := 'INVALID(' + SStr(Mode) + ')';
end;
end;

function SStrViewMode(const Mode : TSMode) : TSString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case Mode of
S_VIEW_WATCH_OBJECT   : Result := 'S_VIEW_WATCH_OBJECT';
S_VIEW_LOOK_AT_OBJECT : Result := 'S_VIEW_LOOK_AT_OBJECT';
else                     Result := 'INVALID(' + SStr(Mode) + ')';
end;
end;

procedure TSCamera.ViewInfo(const PredString : TSString = ''; const CasesOfPrint : TSCasesOfPrint = [SCaseLog, SCasePrint]); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SHint([PredString, 'TSCamera__ViewInfo(..).'], CasesOfPrint);
SHint([PredString,     '  MatrixMode     = "', SStrMatrixMode(FMatrixMode), '"'], CasesOfPrint);
SHint([PredString,     '  ViewMode       = "', SStrViewMode(FViewMode), '"'], CasesOfPrint);
case FViewMode of
S_VIEW_LOOK_AT_OBJECT :
	begin
	SHint([PredString, '  ChangingLookAt = "', FChangingLookAtObject, '"'], CasesOfPrint);
	SHint([PredString, '  Location       = "', SStrVector3f(FLocation, 7), '"'], CasesOfPrint);
	SHint([PredString, '  Up             = "', SStrVector3f(FUp, 7), '"'], CasesOfPrint);
	SHint([PredString, '  View           = "', SStrVector3f(FView, 7), '"'], CasesOfPrint);
	end;
S_VIEW_WATCH_OBJECT :
	begin
	SHint([PredString, '  Rotate.X       = "', SStrReal(FRotateX, 7), '"'], CasesOfPrint);
	SHint([PredString, '  Rotate.Y       = "', SStrReal(FRotateY, 7), '"'], CasesOfPrint);
	SHint([PredString, '  Translate.X    = "', SStrReal(FTranslateX, 7), '"'], CasesOfPrint);
	SHint([PredString, '  Translate.Y    = "', SStrReal(FTranslateY, 7), '"'], CasesOfPrint);
	SHint([PredString, '  Zum            = "', SStrReal(FZum, 7), '"'], CasesOfPrint);
	end;
end;
end;

function TSCamera.GetProjectionMatrix() : TSMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Render.GetFloatv(SR_PROJECTION_MATRIX, @Result);
end;

function TSCamera.GetModelViewMatrix() : TSMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Render.GetFloatv(SR_MODELVIEW_MATRIX, @Result);
end;

constructor TSCamera.Create(const _Context : ISContext; const _MatrixMode : TSMode);
begin
Create();
Context := _Context;
MatrixMode := _MatrixMode;
end;

constructor TSCamera.Create();
begin
inherited;
FMatrixMode := S_3D;
FViewMode := S_VIEW_WATCH_OBJECT;
FLocation.Import();
FView.Import();
FUp.Import(0,0,0);
Clear();
FChangingLookAtObject := False;
end;

procedure TSCamera.Change();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
const
	RotateConst = 0.002;
var
	Q, E : TSBoolean;
	RotateZ : TSFloat = 0;
	o : TSFloat;
begin
if (Context.KeysPressed(S_SHIFT_KEY) and (Context.KeyPressed) and (Context.KeyPressedChar = 'W') and (Context.KeyPressedType = SDownKey) and (Context.KeysPressed('C'))) then
	ViewInfo();
case FViewMode of
S_VIEW_LOOK_AT_OBJECT: if FChangingLookAtObject then
	begin
	Q := Context.KeysPressed('Q');
	E := Context.KeysPressed('E');
	o := Byte(not Context.KeysPressed(S_SHIFT_KEY))*0.6+0.02+0.07*Byte(not Context.KeysPressed(S_CTRL_KEY));
	if (Q xor E) then
		begin
		if Q then
			RotateZ := Context.ElapsedTime*o*4
		else
			RotateZ := -Context.ElapsedTime*o*4;
		end;

	if (Context.KeysPressed('W')) then
		Move(Context.ElapsedTime*o);
	if (Context.KeysPressed('S')) then
		Move(-Context.ElapsedTime*o);
	if (Context.KeysPressed('A')) then
		MoveSidewards(-Context.ElapsedTime*o);
	if (Context.KeysPressed('D')) then
		MoveSidewards(Context.ElapsedTime*o);
	if (Context.KeysPressed(' ')) then
		MoveUp(Context.ElapsedTime*o);
	if (Context.KeysPressed('X')) then
		MoveUp(-Context.ElapsedTime*o);
	Rotate(Context.CursorPosition(SDeferenseCursorPosition).y*RotateConst,Context.CursorPosition(SDeferenseCursorPosition).x/Context.Width*Context.Height*RotateConst,RotateZ*RotateConst);
	end;
S_VIEW_WATCH_OBJECT:
	begin
	if Context.CursorWheel=SUpCursorWheel then
		begin
		FZum*=0.9;
		end;
	if Context.CursorWheel=SDownCursorWheel then
		begin
		FZum*=1/0.9;
		end;
	if Context.CursorKeysPressed(SLeftCursorButton) then
		begin
		FRotateY+=Context.CursorPosition(SDeferenseCursorPosition).x/3;
		FRotateX+=Context.CursorPosition(SDeferenseCursorPosition).y/3;
		end;
	if Context.CursorKeysPressed(SRightCursorButton) then
		begin
		FTranslateY+=   (-Context.CursorPosition(SDeferenseCursorPosition).y/100)*FZum;
		FTranslateX+=   ( Context.CursorPosition(SDeferenseCursorPosition).x/100)*FZum;
		end;
	if (Context.KeyPressed and (Context.KeysPressed(char(17))) and (Context.KeyPressedChar=char(189)) and (Context.KeyPressedType=SDownKey)) then
		begin
		FZum*=1/0.89;
		end;
	if  (Context.KeyPressed and (Context.KeysPressed(char(17))) and (Context.KeyPressedByte=187) and (Context.KeyPressedType=SDownKey))  then
		begin
		FZum*=0.89;
		end;
	end;
end;
end;

procedure TSCamera.InitMatrix(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure InitLookAt();
var
	Matrix : TSMatrix4x4;
begin
FUp := FUp.Normalized();
Render.InitMatrixMode(S_3D);
Matrix := SGetLookAtMatrix(FLocation, FView + FLocation, FUp);
Render.MultMatrixf(@Matrix);
end;

begin
case FViewMode of
S_VIEW_WATCH_OBJECT :
	begin
	Render.InitMatrixMode(FMatrixMode, FZum);
	Render.Translatef(FTranslateX, FTranslateY, -10 * FZum);
	Render.Rotatef(FRotateX, 1, 0, 0);
	Render.Rotatef(FRotateY, 0, 1, 0);
	end;
S_VIEW_LOOK_AT_OBJECT :
	InitLookAt();
end;
end;

procedure TSCamera.Move(const Param : TSSingle);
begin
Position := Position + FView * Param;
end;

procedure TSCamera.Rotate(const x, y, z : TSSingle);
var
	Sidewards : TSVertex3f;
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

procedure TSCamera.MoveUp(const Param : TSSingle);
begin
Position := Position + Up * Param;
end;

procedure TSCamera.MoveSidewards(const Param : TSSingle);
begin
Position := Position + (View * Up).Normalized() * Param;
end;

procedure TSCamera.CallAction();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Change();
InitMatrix();
end;

procedure TSCamera.Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FZum:=1;
FRotateX:=0;
FRotateY:=0;
FTranslateX:=0;
FTranslateY:=0;
end;

end.
