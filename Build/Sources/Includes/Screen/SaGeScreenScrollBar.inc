{$IFDEF SCREEN_INTERFACE}
const
	SGScrollBarHorizon =  $00000;
	SGScrollBarVertical = $00001;
type
	TSGScrollBarButton=class(TSGButton)
			public
		constructor Create;override;
		destructor Destroy;override;
		class function ClassName() : TSGString; override;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		procedure FromDraw;override;
		end;
	TSGScrollBar=class(TSGComponent)
			public
		constructor Create(const NewType:TSGExByte  = SGScrollBarVertical);virtual;
		destructor Destroy;override;
		class function ClassName() : TSGString; override;
			public
		FScrollMax:Int64;
		FScrollHigh:Int64;
		FScrollLow:Int64;
		FScroolType:TSGExByte;
		FBeginingPosition:Int64;
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:TSGScreenInt);override;
		procedure UpDateScrollBounds;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		end;
{$ENDIF}

{$IFDEF SCREEN_IMPLEMENTATION}

class function TSGScrollBar.ClassName() : TSGString; 
begin
Result := 'TSGScrollBar';
end;

class function TSGScrollBarButton.ClassName() : TSGString; 
begin
Result := 'TSGScrollBarButton';
end;

procedure TSGScrollBarButton.FromDraw;
var
	COB,CB:Boolean;
begin
COB:=FCursorOnButton;
CB:=FChangingButton;
inherited;
FCursorOnButton:=COB;
FChangingButton:=CB;
end;

procedure SGScrollBarToLow(Button:TSGScrollBarButton);
begin
if Button.Parent.AsScrollBar.FScrollLow<>0 then
	begin
	Button.Parent.AsScrollBar.FScrollLow-=1;
	Button.Parent.AsScrollBar.FScrollHigh-=1;
	end;
end;

procedure SGScrollBarToHigh(Button:TSGScrollBarButton);
begin
if Button.Parent.AsScrollBar.FScrollHigh<>Button.Parent.AsScrollBar.FScrollMax then
	begin
	Button.Parent.AsScrollBar.FScrollLow+=1;
	Button.Parent.AsScrollBar.FScrollHigh+=1;
	end;
end;

procedure TSGScrollBarButton.FromUpDate(var FCanChange:Boolean);
var
	i:LongInt = -1;
	ii:boolean = true;
begin
if FChangingButton and (not (Context.CursorKeysPressed(SGLeftCursorButton))) then
	begin
	FChangingButton:=False;
	end;
if FChangingButton then
	begin 
	while (ii) and (Abs(Parent.AsScrollBar.FBeginingPosition-Context.CursorPosition(SGNowCursorPosition).y)>((Parent.AsScrollBar.Height-2*Parent.AsScrollBar.Width-13)/Parent.AsScrollBar.FScrollMax)) do
		begin
		ii:=False;
		if Parent.AsScrollBar.FBeginingPosition-Context.CursorPosition(SGNowCursorPosition).y>0 then
			begin
			if Parent.AsScrollBar.FScrollLow<>0 then
				begin
				SGScrollBarToLow(Self);
				Parent.AsScrollBar.FBeginingPosition-=Round(((Parent.AsScrollBar.Height-2*Parent.AsScrollBar.Width-13)/Parent.AsScrollBar.FScrollMax));
				ii:=True;
				end;
			end
		else
			if Parent.AsScrollBar.FScrollHigh<>Parent.AsScrollBar.FScrollMax then
				begin
				SGScrollBarToHigh(Self);
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

procedure TSGScrollBarButton.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
if CursorInComponentNow then
	begin
	FCursorOnButton:=True;
	{if SGMouseKeysDown[0] then
		FChangingButton:=True;}
	if Active and ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) then
		begin
		FChangingButtonTimer:=1;
		case Parent.AsScrollBar.FScroolType of
		SGScrollBarVertical:
			begin
			Parent.AsScrollBar.FBeginingPosition:=Context.CursorPosition(SGNowCursorPosition).y;
			end;
		SGScrollBarHorizon:
			Parent.AsScrollBar.FBeginingPosition:=Context.CursorPosition(SGNowCursorPosition).x;
		end;
		end;
	end;
end;

constructor TSGScrollBarButton.Create;
begin
inherited;
end;

destructor TSGScrollBarButton.Destroy;
begin
inherited;
end;

procedure TSGScrollBar.FromUpDate(var FCanChange:Boolean);
begin
UpDateScrollBounds;
inherited FromUpDate(FCanChange);
end;

procedure TSGScrollBar.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
inherited FromUpDateUnderCursor(CanRePleace,CursorInComponentNow);
end;

procedure TSGScrollBar.UpDateScrollBounds;
begin 
if FScroolType = SGScrollBarVertical then
	begin 
	LastChild.SetBounds(0
		,Width+2+Trunc((Height-2*Width-13)*(FScrollLow/FScrollMax))
		,Width
		,Width+2+Trunc((Height-2*Width-13)*(FScrollHigh/FScrollMax))-(2+Width+Trunc((Height-2*Width-13)*(FScrollLow/FScrollMax)))
		);
	end
else
	if FScroolType = SGScrollBarHorizon then
		begin
		
		end
	else
		begin
		
		end;
end;

procedure TSGScrollBar.SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:TSGScreenInt);
begin
inherited SetBounds(NewLeft,NewTop,NewWidth,NewHeight);
if FScroolType = SGScrollBarVertical then
	begin
	FChildren[0].SetBounds(0,0,NewWidth,NewWidth);
	FChildren[1].SetBounds(0,NewHeight-NewWidth,NewWidth,NewWidth);
	UpDateScrollBounds;
	end
else
	if FScroolType = SGScrollBarVertical then
		begin
		FChildren[0].SetBounds(0,0,NewHeight,NewHeight);
		FChildren[1].SetBounds(NewHeight-NewWidth,0,NewHeight,NewHeight);
		UpDateScrollBounds;
		end
	else
		begin
		
		end;
end;

destructor TSGScrollBar.Destroy;
begin
Inherited;
end;

constructor TSGScrollBar.Create(const NewType:TSGExByte  = SGScrollBarVertical);
begin
inherited Create;
FBeginingPosition:=0;
FScroolType:=NewType;
FScrollMax:=20;
FScrollHigh:=15;
FScrollLow:=10;
CreateChild(TSGButton.Create);
LastChild.Caption:='/\';
LastChild.Visible:=True;
LastChild.AsButton.OnChange:=TSGComponentProcedure(@SGScrollBarToLow);
CreateChild(TSGButton.Create);
LastChild.Caption:='\/';
LastChild.Visible:=True;
LastChild.AsButton.OnChange:=TSGComponentProcedure(@SGScrollBarToHigh);
CreateChild(TSGScrollBarButton.Create);
LastChild.Caption:='';
LastChild.Visible:=True;
end;

{$ENDIF}
