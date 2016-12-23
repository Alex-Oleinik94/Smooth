{$IFDEF SCREEN_INTERFACE}
type
	TSGEditTextTypeFunction = function (const s:TSGEdit):boolean;
const
	SGEditTypeText    = 0;
	SGEditTypeSingle  = 1;
	SGEditTypeNumber  = 2;
	SGEditTypeUser    = 3;
	SGEditTypeInteger = 4;
	SGEditTypeWay     = 5;

function TSGEditTextTypeFunctionNumber(const s:TSGEdit):boolean;
function TSGEditTextTypeFunctionInteger(const s:TSGEdit):boolean;
function TSGEditTextTypeFunctionWay(const s:TSGEdit):boolean;
type
	TSGEdit=class(TSGOverComponent, ISGEdit)
			public
		constructor Create;override;
		destructor Destroy;override;
		class function ClassName() : TSGString; override;
			protected
		FCursorOnComponentPrev : TSGBoolean;
		FCursorOnComponentTimer:TSGScreenTimer;
		FCursorPosition:LongInt;
		FNowChanget:Boolean;
		FNowChangetTimer:TSGScreenTimer;
		FTextType:TSGEditTextType;
		FTextTypeFunction:TSGEditTextTypeFunction;
		FTextComplite:Boolean;
		FTextCompliteTimer:TSGScreenTimer;
		FDrawCursor:Boolean;
		FDrawCursorTimer:TSGScreenTimer;
		FDrawCursorElapsedTime:LongWord;
		FDrawCursorElapsedTimeChange:LongWord;
		FDrawCursorElapsedTimeDontChange:LongWord;
			public
		procedure FromDraw;override;
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		procedure TextTypeEvent;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			protected
		function GetCursorTimer() : TSGScreenTimer;
		function GetTextCompliteTimer() : TSGScreenTimer;
		function GetTextType() : TSGEditTextType;
		function GetTextComplite() : TSGBoolean;
		function GetCursorPosition() : TSGInt32;
		procedure SetCaption(const NewCaption : TSGCaption);override;
		procedure SetTextType(const NewTextType:TSGEditTextType);virtual;
		function GetTextTypeAssigned() : TSGBoolean;
			public
		property TextType         : TSGEditTextType         read GetTextType         write SetTextType;
		property TextComplite     : TSGBoolean              read GetTextComplite     write FTextComplite;
		property TextTypeFunction : TSGEditTextTypeFunction read FTextTypeFunction   write FTextTypeFunction;
		property CursorPosition   : TSGInt32                read GetCursorPosition;
		end;
{$ENDIF}

{$IFDEF SCREEN_IMPLEMENTATION}
class function TSGEdit.ClassName() : TSGString; 
begin
Result := 'TSGEdit';
end;

function TSGEditTextTypeFunctionInteger(const s:TSGEdit):boolean;
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

function TSGEditTextTypeFunctionNumber(const s:TSGEdit):boolean;
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

function TSGEditTextTypeFunctionWay(const s:TSGEdit):boolean;
begin
Result:=SGResourceFiles.FileExists(s.Caption);
end;

function TSGEdit.GetTextType() : TSGEditTextType;
begin
Result := FTextType;
end;

function TSGEdit.GetTextComplite() : TSGBoolean;
begin
Result := FTextComplite;
end;

function TSGEdit.GetCursorPosition() : TSGInt32;
begin
Result := FCursorPosition;
end;

function TSGEdit.GetTextTypeAssigned() : TSGBoolean;
begin
Result := FTextType <> 0;
end;

function TSGEdit.GetCursorTimer() : TSGScreenTimer;
begin
Result := FDrawCursorTimer;
end;

function TSGEdit.GetTextCompliteTimer() : TSGScreenTimer;
begin
Result := FTextCompliteTimer;
end;

procedure TSGEdit.SetTextType(const NewTextType:TSGEditTextType);
begin
FTextType:=NewTextType;
case FTextType of
SGEditTypeWay:
	FTextTypeFunction:=TSGEditTextTypeFunction(@TSGEditTextTypeFunctionWay);
SGEditTypeSingle:
	begin
	
	end;
SGEditTypeNumber:
	begin
	FTextTypeFunction:=TSGEditTextTypeFunction(@TSGEditTextTypeFunctionNumber);
	end;
SGEditTypeText:
	begin
	FTextTypeFunction:=nil;
	end;
SGEditTypeInteger:
	FTextTypeFunction:=TSGEditTextTypeFunction(@TSGEditTextTypeFunctionInteger);
end;
end;

procedure TSGEdit.SetCaption(const NewCaption : TSGCaption);
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

procedure TSGEdit.TextTypeEvent;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (FTextType<>SGEditTypeText) and (FTextTypeFunction<>nil) then
	begin
	FTextComplite:=FTextTypeFunction(Self);
	end;
end;

procedure TSGEdit.FromDraw;
var
	FirsColor1:TSGColor4f = (x:0;y:0.5;z:1;w:1);
	SecondColor1:TSGColor4f = (x:0;y:0.9;z:1;w:1);
	ThreeColor1:TSGColor4f = (x:0.95;y:0.95;z:0.95;w:1);
	
	FirsColor2:TSGColor4f = (x:0;y:0.75;z:1;w:1);
	SecondColor2:TSGColor4f = (x:0;y:1;z:1;w:1);
	ThreeColor2:TSGColor4f = (x:1;y:1;z:1;w:1);
	
	FirsColor3:TSGColor4f = (x:0.8;y:0;z:0;w:0.8);
	SecondColor3:TSGColor4f = (x:0.8;y:0;z:0;w:1);
	
	FirsColor4:TSGColor4f = (x:0;y:0.8;z:0;w:0.8);
	SecondColor4:TSGColor4f = (x:0;y:0.8;z:0;w:1);
	
	ReqAct : Boolean = false;
	TempTimer : Real = 0;
begin
if (FVisibleTimer>SGZero) then
	begin
	FSkin.PaintEdit(Self);
	end;
inherited;
end;

procedure TSGEdit.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin 
if CursorInComponentNow then
	if CanRePleace then
		begin
		if ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGDownKey)) then
			begin
			FNowChanget:=True;
			FDrawCursor:=True;
			FDrawCursorTimer:=1;
			FDrawCursorElapsedTime:=0;
			FDrawCursorElapsedTimeDontChange:=30;
			end;
		end
	else
		if FNowChanget then
			FNowChanget:=False;
inherited FromUpDateUnderCursor(CanRePleace,CursorInComponentNow);
end;

procedure TSGEdit.FromUpDate(var FCanChange:Boolean);
var
	CaptionCharget:Boolean = False;
	CursorChanget:Boolean = False;
begin
if FCanChange then
	begin
	if (not CursorInComponent) and ((Context.CursorKeyPressed <> SGNullCursorButton)) then
		FNowChanget:=False;
	if FNowChanget then
		begin
		if Context.KeyPressedChar=#27 then
			FNowChanget:=False;
		end;
	if FNowChanget and Context.KeyPressed and (Context.KeyPressedType=SGDownKey) then
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
				FCaption:=SGStringGetPart(FCaption,1,FCursorPosition)+
					SGStringGetPart(FCaption,FCursorPosition+2,Length(FCaption));
				CaptionCharget:=True;
				end;
			end;
		#8: //BackSpase
			if FCursorPosition=1 then
				begin
				FCursorPosition:=0;
				FCaption:=SGStringGetPart(FCaption,2,Length(FCaption));
				CaptionCharget:=True;
				end
			else if FCursorPosition<>0 then
				begin
				FCursorPosition-=1;
				FCaption:=SGStringGetPart(FCaption,1,FCursorPosition)+
					SGStringGetPart(FCaption,FCursorPosition+2,Length(FCaption));
				CaptionCharget:=True;
				end;
		Char(SG_ALT_KEY),//Alt
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
					SGWhatIsTheSimbol(longint(Context.KeyPressedChar),
					Context.KeysPressed(16) , Context.KeysPressed(20));
				FCursorPosition:=1;
				CaptionCharget:=True;
				end
			else
				begin
				FCursorPosition+=1;
				FCaption:=
						SGStringGetPart(FCaption,1,FCursorPosition-1)+
						SGWhatIsTheSimbol(longint(Context.KeyPressedChar),
							Context.KeysPressed(16) , Context.KeysPressed(20))+
						SGStringGetPart(FCaption,FCursorPosition,Length(FCaption));
				CaptionCharget:=True;
				end;
			end;
		end;
		end;
	end
else
	if FNowChanget then
		FNowChanget:=False;
if CaptionCharget then
	begin
	TextTypeEvent();
	if OnChange<>nil then
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
if FCursorOnComponent and ReqursiveActive and Visible then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle <> SGC_IBEAM)) then
		Context.Cursor := TSGCursor.Create(SGC_IBEAM);
if FCursorOnComponentPrev and (not FCursorOnComponent) then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle = SGC_IBEAM)) then
	Context.Cursor := TSGCursor.Create(SGC_NORMAL);
FCursorOnComponentPrev := FCursorOnComponent;
UpgradeTimer(FCursorOnComponent,FCursorOnComponentTimer,3);
UpgradeTimer(FNowChanget,FNowChangetTimer,3);
UpgradeTimer(FTextComplite,FTextCompliteTimer,1);
UpgradeTimer(FDrawCursor,FDrawCursorTimer,4);
inherited FromUpDate(FCanChange);
end;

constructor TSGEdit.Create;
begin
inherited;
FCursorOnComponentPrev := False;
FCursorOnComponent     := False;
FCursorPosition        := 0;
FNowChanget            := False;
FNowChangetTimer       := 0;
FTextTypeFunction      := nil;
FTextType              := SGEditTypeText;
FTextComplite          := True;
FDrawCursor            := True;
FDrawCursorTimer       := 1;
FDrawCursorElapsedTime := 0;
FDrawCursorElapsedTimeChange     := 50;
FDrawCursorElapsedTimeDontChange := 30;
end;

destructor TSGEdit.Destroy;
begin
inherited;
end;
{$ENDIF}
