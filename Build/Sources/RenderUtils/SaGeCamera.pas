{$INCLUDE SaGe.inc}

unit SaGeCamera;

interface

uses
	 SaGeBase
	,SaGeCommonStructs
	,SaGeCommonClasses
	,SaGeMatrix
	,SaGeLog
	;

type
	TSGCamera = class;
const
	SG_VIEW_WATCH_OBJECT        = $001001;
	SG_VIEW_LOOK_AT_OBJECT      = $001002;
type
	TSGMode = TSGUInt32;
	TSGCamera = class(TSGContextabled)
			public
		constructor Create();override;
			private
		FMatrixMode: TSGMode; // SG_3D, SG_2D, SG_ORTHO_3D
		FViewMode  : TSGMode; // SG_VIEW_...
			// for SG_VIEW_WATCH_OBJECT
		FRotateX, FRotateY, FTranslateX, FTranslateY, FZum : TSGSingle;
			// for SG_VIEW_LOOK_AT_OBJECT
		FLocation : TSGVertex3f;
		FView   :TSGVertex3f;
		FUp : TSGVertex3f;
		FChangingLookAtObject : TSGBoolean;
			public
		procedure Change();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure ViewInfo(const PredString : TSGString = ''; const ViewCase : TSGViewType = [SGLogType, SGPrintType]); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure InitMatrix();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure CallAction();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetProjectionMatrix() : TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetModelViewMatrix() : TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		procedure InitViewModeComboBox();virtual;abstract;
		procedure Move(const Param : TSGSingle);
		procedure MoveSidewards(const Param : TSGSingle);
		procedure MoveUp(const Param : TSGSingle);
		procedure Rotate(const x, y, z : TSGSingle);
			public
		property RotateX : TSGFloat read FRotateX write FRotateX;
		property RotateY : TSGFloat read FRotateY write FRotateY;
		property TranslateX : TSGFloat read FTranslateX write FTranslateX;
		property TranslateY : TSGFloat read FTranslateY write FTranslateY;
		property Zum : TSGFloat read FZum write FZum;
			public
		property Up        : TSGVertex3f read FUp         write FUp;
		property Location  : TSGVertex3f read FLocation   write FLocation;
		property Position  : TSGVertex3f read FLocation   write FLocation;
		property View      : TSGVertex3f read FView       write FView;
		property MatrixMode: TSGMode     read FMatrixMode write FMatrixMode;
		property ViewMode  : TSGMode     read FViewMode   write FViewMode;
		property ChangingLookAtObject : TSGBoolean read FChangingLookAtObject write FChangingLookAtObject;
		end;

function SGStrMatrixMode(const Mode : TSGMode) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGStrViewMode(const Mode : TSGMode) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 SaGeRenderBase
	,SaGeContext
	,SaGeCommon
	,SaGeStringUtils
	;

function SGStrMatrixMode(const Mode : TSGMode) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case Mode of
SG_3D       : Result := 'SG_3D';
SG_2D       : Result := 'SG_2D';
SG_3D_ORTHO : Result := 'SG_3D_ORTHO';
else          Result := 'INVALID(' + SGStr(Mode) + ')';
end;
end;

function SGStrViewMode(const Mode : TSGMode) : TSGString; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
case Mode of
SG_VIEW_WATCH_OBJECT   : Result := 'SG_VIEW_WATCH_OBJECT';
SG_VIEW_LOOK_AT_OBJECT : Result := 'SG_VIEW_LOOK_AT_OBJECT';
else                     Result := 'INVALID(' + SGStr(Mode) + ')';
end;
end;

procedure TSGCamera.ViewInfo(const PredString : TSGString = ''; const ViewCase : TSGViewType = [SGLogType, SGPrintType]); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SGHint([PredString, 'TSGCamera__ViewInfo(..).'], ViewCase);
SGHint([PredString,     '  MatrixMode     = "', SGStrMatrixMode(FMatrixMode), '"'], ViewCase);
SGHint([PredString,     '  ViewMode       = "', SGStrViewMode(FViewMode), '"'], ViewCase);
case FViewMode of
SG_VIEW_LOOK_AT_OBJECT :
	begin
	SGHint([PredString, '  ChangingLookAt = "', FChangingLookAtObject, '"'], ViewCase);
	SGHint([PredString, '  Location       = "', SGStrVector3f(FLocation, 7), '"'], ViewCase);
	SGHint([PredString, '  Up             = "', SGStrVector3f(FUp, 7), '"'], ViewCase);
	SGHint([PredString, '  View           = "', SGStrVector3f(FView, 7), '"'], ViewCase);
	end;
SG_VIEW_WATCH_OBJECT :
	begin
	SGHint([PredString, '  Rotate.X       = "', SGStrReal(FRotateX, 7), '"'], ViewCase);
	SGHint([PredString, '  Rotate.Y       = "', SGStrReal(FRotateY, 7), '"'], ViewCase);
	SGHint([PredString, '  Translate.X    = "', SGStrReal(FTranslateX, 7), '"'], ViewCase);
	SGHint([PredString, '  Translate.Y    = "', SGStrReal(FTranslateY, 7), '"'], ViewCase);
	SGHint([PredString, '  Zum            = "', SGStrReal(FZum, 7), '"'], ViewCase);
	end;
end;
end;

function TSGCamera.GetProjectionMatrix() : TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Render.GetFloatv(SGR_PROJECTION_MATRIX, @Result);
end;

function TSGCamera.GetModelViewMatrix() : TSGMatrix4x4;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Render.GetFloatv(SGR_MODELVIEW_MATRIX, @Result);
end;

constructor TSGCamera.Create();
begin
inherited;
FMatrixMode := SG_3D;
FViewMode := SG_VIEW_WATCH_OBJECT;
FLocation.Import();
FView.Import();
FUp.Import(0,0,0);
Clear();
FChangingLookAtObject := False;
end;

procedure TSGCamera.Change();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
const
	RotateConst = 0.002;
var
	Q, E : TSGBoolean;
	RotateZ : TSGFloat = 0;
	o : TSGFloat;
begin
if (Context.KeysPressed(SG_SHIFT_KEY) and (Context.KeyPressed) and (Context.KeyPressedChar = 'W') and (Context.KeyPressedType = SGDownKey) and (Context.KeysPressed('C'))) then
	ViewInfo();
case FViewMode of
SG_VIEW_LOOK_AT_OBJECT: if FChangingLookAtObject then
	begin
	Q := Context.KeysPressed('Q');
	E := Context.KeysPressed('E');
	o := Byte(not Context.KeysPressed(SG_SHIFT_KEY))*0.6+0.02+0.07*Byte(not Context.KeysPressed(SG_CTRL_KEY));
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
	Rotate(Context.CursorPosition(SGDeferenseCursorPosition).y*RotateConst,Context.CursorPosition(SGDeferenseCursorPosition).x/Context.Width*Context.Height*RotateConst,RotateZ*RotateConst);
	end;
SG_VIEW_WATCH_OBJECT:
	begin
	if Context.CursorWheel=SGUpCursorWheel then
		begin
		FZum*=0.9;
		end;
	if Context.CursorWheel=SGDownCursorWheel then
		begin
		FZum*=1/0.9;
		end;
	if Context.CursorKeysPressed(SGLeftCursorButton) then
		begin
		FRotateY+=Context.CursorPosition(SGDeferenseCursorPosition).x/3;
		FRotateX+=Context.CursorPosition(SGDeferenseCursorPosition).y/3;
		end;
	if Context.CursorKeysPressed(SGRightCursorButton) then
		begin
		FTranslateY+=   (-Context.CursorPosition(SGDeferenseCursorPosition).y/100)*FZum;
		FTranslateX+=   ( Context.CursorPosition(SGDeferenseCursorPosition).x/100)*FZum;
		end;
	if (Context.KeyPressed and (Context.KeysPressed(char(17))) and (Context.KeyPressedChar=char(189)) and (Context.KeyPressedType=SGDownKey)) then
		begin
		FZum*=1/0.89;
		end;
	if  (Context.KeyPressed and (Context.KeysPressed(char(17))) and (Context.KeyPressedByte=187) and (Context.KeyPressedType=SGDownKey))  then
		begin
		FZum*=0.89;
		end;
	end;
end;
end;

procedure TSGCamera.InitMatrix(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

procedure InitLookAt();
var
	Matrix : TSGMatrix4x4;
begin
FUp := FUp.Normalized();
Render.InitMatrixMode(SG_3D);
Matrix := SGGetLookAtMatrix(FLocation, FView + FLocation, FUp);
Render.MultMatrixf(@Matrix);
end;

begin
case FViewMode of
SG_VIEW_WATCH_OBJECT :
	begin
	Render.InitMatrixMode(FMatrixMode, FZum);
	Render.Translatef(FTranslateX, FTranslateY, -10 * FZum);
	Render.Rotatef(FRotateX, 1, 0, 0);
	Render.Rotatef(FRotateY, 0, 1, 0);
	end;
SG_VIEW_LOOK_AT_OBJECT :
	InitLookAt();
end;
end;

procedure TSGCamera.Move(const Param : TSGSingle);
begin
Position := Position + FView * Param;
end;

procedure TSGCamera.Rotate(const x, y, z : TSGSingle);
var
	Sidewards : TSGVertex3f;
begin
if x<>0 then
	begin
	Sidewards := (View * Up).Normalized();
	View := SGRotatePoint(View, Sidewards, -X).Normalized();
	Up := (Sidewards * View).Normalized();
	end;
if y<>0 then
	View := SGRotatePoint(View, Up, -Y).Normalized();
if z<>0 then
	Up := SGRotatePoint(Up, View, -Z).Normalized();
end;

procedure TSGCamera.MoveUp(const Param : TSGSingle);
begin
Position := Position + Up * Param;
end;

procedure TSGCamera.MoveSidewards(const Param : TSGSingle);
begin
Position := Position + (View * Up).Normalized() * Param;
end;

procedure TSGCamera.CallAction();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Change();
InitMatrix();
end;

procedure TSGCamera.Clear();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FZum:=1;
FRotateX:=0;
FRotateY:=0;
FTranslateX:=0;
FTranslateY:=0;
end;

end.