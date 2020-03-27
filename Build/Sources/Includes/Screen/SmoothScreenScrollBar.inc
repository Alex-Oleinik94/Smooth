{$IFDEF SCREEN_INTERFACE}
const
	SScrollBarHorizon =  $00000;
	SScrollBarVertical = $00001;
type
	TSScrollBarButton=class(TSButton)
			public
		constructor Create;override;
		destructor Destroy;override;
		class function ClassName() : TSString; override;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		procedure FromDraw;override;
		end;
	TSScrollBar=class(TSComponent)
			public
		constructor Create(const NewType:TSByte  = SScrollBarVertical);virtual;
		destructor Destroy;override;
		class function ClassName() : TSString; override;
			public
		FScrollMax:Int64;
		FScrollHigh:Int64;
		FScrollLow:Int64;
		FScroolType:TSByte;
		FBeginingPosition:Int64;
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:TSScreenInt);override;
		procedure UpDateScrollBounds;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		end;
{$ENDIF}

{$IFDEF SCREEN_IMPLEMENTATION}

class function TSScrollBar.ClassName() : TSString; 
begin
Result := 'TSScrollBar';
end;

class function TSScrollBarButton.ClassName() : TSString; 
begin
Result := 'TSScrollBarButton';
end;

procedure TSScrollBarButton.FromDraw;
var
	COB,CB:Boolean;
begin
COB:=FCursorOnButton;
CB:=FChangingButton;
inherited;
FCursorOnButton:=COB;
FChangingButton:=CB;
end;

procedure SScrollBarToLow(Button:TSScrollBarButton);
begin
if Button.Parent.AsScrollBar.FScrollLow<>0 then
	begin
	Button.Parent.AsScrollBar.FScrollLow-=1;
	Button.Parent.AsScrollBar.FScrollHigh-=1;
	end;
end;

procedure SScrollBarToHigh(Button:TSScrollBarButton);
begin
if Button.Parent.AsScrollBar.FScrollHigh<>Button.Parent.AsScrollBar.FScrollMax then
	begin
	Button.Parent.AsScrollBar.FScrollLow+=1;
	Button.Parent.AsScrollBar.FScrollHigh+=1;
	end;
end;

procedure TSScrollBarButton.FromUpDate(var FCanChange:Boolean);
var
	i:LongInt = -1;
	ii:boolean = true;
begin
if FChangingButton and (not (Context.CursorKeysPressed(SLeftCursorButton))) then
	begin
	FChangingButton:=False;
	end;
if FChangingButton then
	begin 
	while (ii) and (Abs(Parent.AsScrollBar.FBeginingPosition-Context.CursorPosition(SNowCursorPosition).y)>((Parent.AsScrollBar.Height-2*Parent.AsScrollBar.Width-13)/Parent.AsScrollBar.FScrollMax)) do
		begin
		ii:=False;
		if Parent.AsScrollBar.FBeginingPosition-Context.CursorPosition(SNowCursorPosition).y>0 then
			begin
			if Parent.AsScrollBar.FScrollLow<>0 then
				begin
				SScrollBarToLow(Self);
				Parent.AsScrollBar.FBeginingPosition-=Round(((Parent.AsScrollBar.Height-2*Parent.AsScrollBar.Width-13)/Parent.AsScrollBar.FScrollMax));
				ii:=True;
				end;
			end
		else
			if Parent.AsScrollBar.FScrollHigh<>Parent.AsScrollBar.FScrollMax then
				begin
				SScrollBarToHigh(Self);
				Parent.AsScrollBar.FBeginingPosition+=Round(((Parent.AsScrollBar.Height-2*Parent.AsScrollBar.Width-13)/Parent.AsScrollBar.FScrollMax));
				ii:=True;
				end;
		end;
	end;

UpgradeTimer(FCursorOnButton,FCursorOnButtonTimer,3,2);
UpgradeTimer(FChangingButton,FChangingButtonTimer,5,2);
UpDateObjects;
UpgradeTimers;
for i:=High(FChildren) downto Low(FChildren) do
	FChildren[i].FromUpDate(FCanChange);
if FComponentProcedure<>nil then
	FComponentProcedure(Self);

FCursorOnButton:=False;
end;

procedure TSScrollBarButton.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
if CursorInComponentNow then
	begin
	FCursorOnButton:=True;
	{if SMouseKeysDown[0] then
		FChangingButton:=True;}
	if Active and ((Context.CursorKeyPressed=SLeftCursorButton) and (Context.CursorKeyPressedType=SUpKey)) then
		begin
		FChangingButtonTimer:=1;
		case Parent.AsScrollBar.FScroolType of
		SScrollBarVertical:
			begin
			Parent.AsScrollBar.FBeginingPosition:=Context.CursorPosition(SNowCursorPosition).y;
			end;
		SScrollBarHorizon:
			Parent.AsScrollBar.FBeginingPosition:=Context.CursorPosition(SNowCursorPosition).x;
		end;
		end;
	end;
end;

constructor TSScrollBarButton.Create;
begin
inherited;
end;

destructor TSScrollBarButton.Destroy;
begin
inherited;
end;

procedure TSScrollBar.FromUpDate(var FCanChange:Boolean);
begin
UpDateScrollBounds;
inherited FromUpDate(FCanChange);
end;

procedure TSScrollBar.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
inherited FromUpDateUnderCursor(CanRePleace,CursorInComponentNow);
end;

procedure TSScrollBar.UpDateScrollBounds;
begin 
if FScroolType = SScrollBarVertical then
	begin 
	LastChild.SetBounds(0
		,Width+2+Trunc((Height-2*Width-13)*(FScrollLow/FScrollMax))
		,Width
		,Width+2+Trunc((Height-2*Width-13)*(FScrollHigh/FScrollMax))-(2+Width+Trunc((Height-2*Width-13)*(FScrollLow/FScrollMax)))
		);
	end
else
	if FScroolType = SScrollBarHorizon then
		begin
		
		end
	else
		begin
		
		end;
end;

procedure TSScrollBar.SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:TSScreenInt);
begin
inherited SetBounds(NewLeft,NewTop,NewWidth,NewHeight);
if FScroolType = SScrollBarVertical then
	begin
	FChildren[0].SetBounds(0,0,NewWidth,NewWidth);
	FChildren[1].SetBounds(0,NewHeight-NewWidth,NewWidth,NewWidth);
	UpDateScrollBounds;
	end
else
	if FScroolType = SScrollBarVertical then
		begin
		FChildren[0].SetBounds(0,0,NewHeight,NewHeight);
		FChildren[1].SetBounds(NewHeight-NewWidth,0,NewHeight,NewHeight);
		UpDateScrollBounds;
		end
	else
		begin
		
		end;
end;

destructor TSScrollBar.Destroy;
begin
Inherited;
end;

constructor TSScrollBar.Create(const NewType:TSByte  = SScrollBarVertical);
begin
inherited Create;
FBeginingPosition:=0;
FScroolType:=NewType;
FScrollMax:=20;
FScrollHigh:=15;
FScrollLow:=10;
CreateChild(TSButton.Create);
LastChild.Caption:='/\';
LastChild.Visible:=True;
LastChild.AsButton.OnChange:=TSComponentProcedure(@SScrollBarToLow);
CreateChild(TSButton.Create);
LastChild.Caption:='\/';
LastChild.Visible:=True;
LastChild.AsButton.OnChange:=TSComponentProcedure(@SScrollBarToHigh);
CreateChild(TSScrollBarButton.Create);
LastChild.Caption:='';
LastChild.Visible:=True;
end;

{$ENDIF}
