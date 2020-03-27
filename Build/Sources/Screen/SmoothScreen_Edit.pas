{$INCLUDE Smooth.inc}

unit SmoothScreen_Edit;

interface

uses
	 SmoothBase
	,SmoothScreenBase
	,SmoothScreenCommonComponents
	,SmoothScreenComponentInterfaces
	;

type
	TSEdit = class;
	TSEditTextTypeFunction = function (const s:TSEdit) : TSBoolean;
const
	SEditTypeText    = 0;
	SEditTypeFloat   = 1;
	SEditTypeNumber  = 2;
	SEditTypeUser    = 3;
	SEditTypeInteger = 4;
	SEditTypePath    = 5;

function TSEditTextTypeFunctionNumber(const s:TSEdit) : TSBoolean;
function TSEditTextTypeFunctionInteger(const s:TSEdit) : TSBoolean;
function TSEditTextTypeFunctionWay(const s:TSEdit) : TSBoolean;
type
	TSEdit = class(TSOverComponent, ISEdit)
			public
		constructor Create;override;
		destructor Destroy;override;
		class function ClassName() : TSString; override;
			protected
		FCursorPosition         : TSInt32;
		FNowChanget             : TSBool;
		FNowChangetTimer        : TSScreenTimer;
		FTextType               : TSEditTextType;
		FTextTypeFunction       : TSEditTextTypeFunction;
		FTextComplite           : TSBool;
		FTextCompliteTimer      : TSScreenTimer;
		FDrawCursor             : TSBool;
		FDrawCursorTimer        : TSScreenTimer;
		FDrawCursorElapsedTime  : TSUInt32;
		FDrawCursorElapsedTimeChange : TSUInt32;
		FDrawCursorElapsedTimeDontChange : TSUInt32;
			public
		procedure Paint(); override;
		procedure UpDate();override;
		procedure TextTypeEvent;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			protected
		function GetCursorTimer() : TSScreenTimer; virtual;
		function GetTextCompliteTimer() : TSScreenTimer;
		function GetTextType() : TSEditTextType;
		function GetTextComplite() : TSBoolean;
		function GetCursorPosition() : TSInt32; virtual;
		procedure SetCaption(const NewCaption : TSCaption);override;
		procedure SetTextType(const NewTextType:TSEditTextType);virtual;
		function GetTextTypeAssigned() : TSBoolean;
		function GetNowEditing() : TSBool;virtual;
			public
		property TextType         : TSEditTextType         read GetTextType         write SetTextType;
		property TextComplite     : TSBoolean              read GetTextComplite     write FTextComplite;
		property TextTypeFunction : TSEditTextTypeFunction read FTextTypeFunction   write FTextTypeFunction;
		property CursorPosition   : TSInt32                read GetCursorPosition;
		end;

implementation

uses
	 SmoothMathUtils
	,SmoothContextUtils
	,SmoothCursor
	,SmoothStringUtils
	,SmoothEncodingUtils
	,SmoothResourceManager
	;

class function TSEdit.ClassName() : TSString; 
begin
Result := 'TSEdit';
end;

function TSEditTextTypeFunctionInteger(const s:TSEdit):boolean;
var
	i,ii:LongWord;
begin
if S.Caption='' then
	Result:=False
else
	begin
	Result:=True;
	i:=1;
	ii:=0;
	while {S.Caption[i]<>#0}(i<=Length(S.Caption)) do
		begin
		if (ii=1) and (S.Caption[i]=' ') then
			ii:=2;
		if (ii=0) and (S.Caption[i] in ['0'..'9','-']) then
				ii:=1;
		if not (((S.Caption[i] in ['0'..'9','-']) and (ii=1))
			or ((ii=0) and (S.Caption[i]=' ')) 
			or ((ii=2) and (S.Caption[i]=' '))) then
			begin
			Result:=False;
			Break;
			end;
		i+=1;
		end;
	end;
end;

function TSEditTextTypeFunctionNumber(const s:TSEdit):boolean;
var
	i,ii:LongWord;
begin
if S.Caption='' then
	Result:=False
else
	begin
	Result:=True;
	i:=1;
	ii:=0;
	while {S.Caption[i]<>#0} i<=Length(s.Caption) do
		begin
		if (ii=1) and (S.Caption[i]=' ') then
			ii:=2;
		if (ii=0) and (S.Caption[i] in ['0'..'9']) then
				ii:=1;
		if not (((S.Caption[i] in ['0'..'9']) and (ii=1))
			or ((ii=0) and (S.Caption[i]=' ')) 
			or ((ii=2) and (S.Caption[i]=' '))) then
			begin
			Result:=False;
			Break;
			end;
		i+=1;
		end;
	end;
end;

function TSEditTextTypeFunctionWay(const s:TSEdit):boolean;
begin
Result:=SResourceFiles.FileExists(s.Caption);
end;

function TSEdit.GetTextType() : TSEditTextType;
begin
Result := FTextType;
end;

function TSEdit.GetTextComplite() : TSBoolean;
begin
Result := FTextComplite;
end;

function TSEdit.GetCursorPosition() : TSInt32;
begin
Result := FCursorPosition;
end;

function TSEdit.GetNowEditing() : TSBool;
begin
Result := FNowChanget;
end;

function TSEdit.GetTextTypeAssigned() : TSBoolean;
begin
Result := FTextType <> 0;
end;

function TSEdit.GetCursorTimer() : TSScreenTimer;
begin
Result := FDrawCursorTimer;
end;

function TSEdit.GetTextCompliteTimer() : TSScreenTimer;
begin
Result := FTextCompliteTimer;
end;

procedure TSEdit.SetTextType(const NewTextType:TSEditTextType);
begin
FTextType:=NewTextType;
case FTextType of
SEditTypePath:
	FTextTypeFunction:=TSEditTextTypeFunction(@TSEditTextTypeFunctionWay);
SEditTypeFloat:
	begin
	
	end;
SEditTypeNumber:
	begin
	FTextTypeFunction:=TSEditTextTypeFunction(@TSEditTextTypeFunctionNumber);
	end;
SEditTypeText:
	begin
	FTextTypeFunction:=nil;
	end;
SEditTypeInteger:
	FTextTypeFunction:=TSEditTextTypeFunction(@TSEditTextTypeFunctionInteger);
end;
end;

procedure TSEdit.SetCaption(const NewCaption : TSCaption);
var
	CC:Boolean = False;
begin
CC:=NewCaption=FCaption;
FCursorPosition:=0;
if not CC then
	begin
	inherited SetCaption(NewCaption);
	TextTypeEvent();
	if OnChange<>nil then
		OnChange(Self);
	end;
end;

procedure TSEdit.TextTypeEvent(); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (FTextType <> SEditTypeText) and (FTextTypeFunction <> nil) then
	FTextComplite := FTextTypeFunction(Self);
end;

procedure TSEdit.Paint();
begin
if (FVisibleTimer > SZero) then
	FSkin.PaintEdit(Self);
inherited;
end;

procedure TSEdit.UpDate();
var
	CaptionCharget:Boolean = False;
	CursorChanget:Boolean = False;
begin
inherited;
if (not CursorOver) and ((Context.CursorKeyPressed <> SNullCursorButton)) then
	FNowChanget:=False
else if (CursorOver) and ((Context.CursorKeyPressed=SLeftCursorButton) and (Context.CursorKeyPressedType=SDownKey)) then
	begin
	FNowChanget:=True;
	FDrawCursor:=True;
	FDrawCursorTimer:=1;
	FDrawCursorElapsedTime:=0;
	FDrawCursorElapsedTimeDontChange:=30;
	Context.SetCursorKey(SNullKey, SNullCursorButton);
	end;
if FNowChanget then
	begin
	if Context.KeyPressedChar=#27 then
		FNowChanget:=False;
	end;
if FNowChanget and Context.KeyPressed and (Context.KeyPressedType=SDownKey) then
	begin
	case Context.KeyPressedChar of
	#39://ToRight (Arrow)
		begin
		if FCursorPosition<Length(Caption) then
			FCursorPosition+=1;
		CursorChanget:=True;
		end;
	#37://ToLeft (Arrow)
		begin
		if FCursorPosition>0 then
			FCursorPosition-=1;
		CursorChanget:=True;
		end;
	#13://Enter
		FNowChanget:=False;
	#46: //Delete
		begin  
		if FCursorPosition<Length(Caption) then
			begin
			FCaption:=SStringGetPart(FCaption,1,FCursorPosition)+
				SStringGetPart(FCaption,FCursorPosition+2,Length(FCaption));
			CaptionCharget:=True;
			end;
		end;
	#8: //BackSpase
		if FCursorPosition=1 then
			begin
			FCursorPosition:=0;
			FCaption:=SStringGetPart(FCaption,2,Length(FCaption));
			CaptionCharget:=True;
			end
		else if FCursorPosition<>0 then
			begin
			FCursorPosition-=1;
			FCaption:=SStringGetPart(FCaption,1,FCursorPosition)+
				SStringGetPart(FCaption,FCursorPosition+2,Length(FCaption));
			CaptionCharget:=True;
			end;
	Char(S_ALT_KEY),//Alt
	#17,//Ctrl
	#38,//UpKey(Arrow)
	#40,//DownKey(Arrow)
	#112..#120,///F1..F9
	#123,//F12
	#144,//NumLock
	#45,//Insert
	#27,//Escape
	#19,//Pause (or/and) Break
	#16,//Shift
	#9,//Tab
	#20,//Caps Lock
	#34,#33,//PageDown,PageUp
	#93,//Win Property  (Right Menu Key)
	#91,//Win Menu (Left Menu Key)
	#255,//Screen яркость(F11,F12 on my netbook)
	#233//Dinamics Volume (F7,F8,F9 on my netbook)
		:;// Do NoThink
	#35://  End
		begin
		FCursorPosition:=Length(Caption);
		CursorChanget:=True;
		end;
	#36:// Home 
		begin
		FCursorPosition:=0;
		CursorChanget:=True;
		end;
	else//Simbol
		begin
		if FCaption='' then
			begin
			FCaption:=
				SWhatIsTheSimbol(longint(Context.KeyPressedChar),
				Context.KeysPressed(16) , Context.KeysPressed(20));
			FCursorPosition:=1;
			CaptionCharget:=True;
			end
		else
			begin
			FCursorPosition+=1;
			FCaption:=
					SStringGetPart(FCaption,1,FCursorPosition-1)+
					SWhatIsTheSimbol(longint(Context.KeyPressedChar),
						Context.KeysPressed(16) , Context.KeysPressed(20))+
					SStringGetPart(FCaption,FCursorPosition,Length(FCaption));
			CaptionCharget:=True;
			end;
		end;
	end;
	end;
if CaptionCharget then
	begin
	TextTypeEvent();
	if OnChange <> nil then
		OnChange(Self);
	end;
if FNowChanget then
	begin
	if FDrawCursorElapsedTimeDontChange=0 then
		begin
		FDrawCursorElapsedTime+=Context.ElapsedTime;
		if FDrawCursorElapsedTime>=FDrawCursorElapsedTimeChange then
			begin
			FDrawCursor:= not FDrawCursor;
			FDrawCursorElapsedTime:= FDrawCursorElapsedTime mod FDrawCursorElapsedTimeChange;
			end;
		end
	else
		begin
		if FDrawCursorElapsedTimeDontChange<Context.ElapsedTime then
			begin
			FDrawCursorElapsedTime:=Context.ElapsedTime-FDrawCursorElapsedTimeDontChange;
			FDrawCursorElapsedTimeDontChange:=0;
			end
		else
			begin
			FDrawCursorElapsedTimeDontChange-=Context.ElapsedTime;
			end;
		end;
	end;
if CaptionCharget or CursorChanget then
	begin
	FDrawCursor:=True;
	FDrawCursorTimer:=1;
	FDrawCursorElapsedTime:=0;
	FDrawCursorElapsedTimeDontChange:=30;
	end;
if CursorOver and ReqursiveActive and Visible then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle <> SC_IBEAM)) then
		Context.Cursor := TSCursor.Create(SC_IBEAM);
if PreviousCursorOver and (not CursorOver) then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle = SC_IBEAM)) then
	Context.Cursor := TSCursor.Create(SC_NORMAL);
UpgradeTimer(FNowChanget,FNowChangetTimer,3);
UpgradeTimer(FTextComplite,FTextCompliteTimer,1);
UpgradeTimer(FDrawCursor,FDrawCursorTimer,4);
end;

constructor TSEdit.Create;
begin
inherited;
FCursorPosition        := 0;
FNowChanget            := False;
FNowChangetTimer       := 0;
FTextTypeFunction      := nil;
FTextType              := SEditTypeText;
FTextComplite          := True;
FDrawCursor            := True;
FDrawCursorTimer       := 1;
FDrawCursorElapsedTime := 0;
FDrawCursorElapsedTimeChange     := 50;
FDrawCursorElapsedTimeDontChange := 30;
end;

destructor TSEdit.Destroy;
begin
inherited;
end;

end.
