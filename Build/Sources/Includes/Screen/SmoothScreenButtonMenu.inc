{$IFDEF SCREEN_INTERFACE}
type
	TSButtonMenuProcedure = procedure (a,b:LongInt;p:Pointer);
	TSButtonMenuButton=class(TSButton)
			public
		constructor Create;override;
		class function ClassName() : TSString; override;
			public
		FIdentifity:Int64;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
			public
		property Identifity : int64 read FIdentifity write FIdentifity;
		end;
	TSButtonMenu=class(TSComponent)
			public
		constructor Create;override;
		class function ClassName() : TSString; override;
			public
		FActiveButton:longint;
		FButtonTop:TSScreenInt;
		FActiveButtonTop:TSScreenInt;
		FLastActiveButton:LongInt;
		FProcedure:TSButtonMenuProcedure;
		
		FMiddle:boolean;
		FMiddleTop:TSScreenInt;
		
		FSelectNotClick:Boolean;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure BoundsToNeedBounds;override;
			public
		procedure AddButton(const s:string;const FFActive:boolean = False);
		procedure SetButton(const l:LongInt);
		procedure GetMiddleTop;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		property ButtonTop:TSScreenInt read FButtonTop write FButtonTop;
		property ActiveButtonTop:TSScreenInt read FActiveButtonTop write FActiveButtonTop;
		procedure DetectActiveButton;virtual;
		end;
{$ENDIF}

{$IFDEF SCREEN_IMPLEMENTATION}
class function TSButtonMenuButton.ClassName() : TSString; 
begin
Result := 'TSButtonMenuButton';
end;

class function TSButtonMenu.ClassName() : TSString; 
begin
Result := 'TSButtonMenu';
end;

procedure TSButtonMenu.DetectActiveButton;
var
	i,iii:Longint;
begin
FActiveButton:=-1;
FLastActiveButton:=-1;
iii:=5+FMiddleTop*Byte(FMiddle);
for i:=0 to High(FChildren) do
	begin
	FChildren[i].NeedTop:=iii;
	if FActiveButton=i then
		begin
		FChildren[i].FNeedHeight:=FActiveButtonTop;
		iii+=FActiveButtonTop+5;
		end
	else
		begin
		FChildren[i].FNeedHeight:=FButtonTop;
		iii+=FButtonTop+5;
		end;
	end;
end;

constructor TSButtonMenuButton.Create;
begin
inherited;
FIdentifity:=-1;
end;

procedure TSButtonMenu.BoundsToNeedBounds;
var
	i:LongInt;
begin
inherited;
for i:=0 to High(FChildren) do
	FChildren[i].BoundsToNeedBounds;
end;

procedure TSButtonMenu.GetMiddleTop;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Length(FChildren)>0 then
	FMiddleTop:=Round((Height-(LastChild.Top+LastChild.Height-FChildren[0].Top))/2)
else
	FMiddleTop:=0;
end;

procedure TSButtonMenuButton.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
var
	i,ii:LongInt;
begin
if CursorInComponentNow then
	begin
	if Active and (((Context.CursorKeyPressed=SLeftCursorButton) and (Context.CursorKeyPressedType=SUpKey)) or Parent.AsButtonMenu.FSelectNotClick) then
		begin
		ii:=-1;
		for i:=0 to High(FParent.FChildren) do
			if FParent.FChildren[i]=Self then
				begin
				ii:=i;
				Break;
				end;
		if FParent.AsButtonMenu.FActiveButton<>ii then
			FParent.AsButtonMenu.SetButton(ii);
		end;
	end;
inherited FromUpDateUnderCursor(CanRePleace,CursorInComponentNow);
end;

procedure TSButtonMenu.SetButton(const l:LongInt);
var 
	i,iii:LongInt;
begin
GetMiddleTop;
FActiveButton:=l;
if (FProcedure<>nil) and (FLastActiveButton<>FActiveButton) then
	begin
	FProcedure(FLastActiveButton,FActiveButton,Self);
	end;
FLastActiveButton:=FActiveButton;
iii:=5+FMiddleTop*Byte(FMiddle);
for i:=0 to High(FChildren) do
	begin
	FChildren[i].FNeedTop:=iii;
	if FActiveButton=i then
		begin
		FChildren[i].FNeedHeight:=FActiveButtonTop;
		iii+=FActiveButtonTop+5;
		end
	else
		begin
		FChildren[i].FNeedHeight:=FButtonTop;
		iii+=FButtonTop+5;
		end;
	end;
end;

procedure TSButtonMenu.AddButton(const s:string;const FFActive:boolean = False);
var
	i:LongInt = 5;
	ii:LongInt = 0;
begin
for ii:=0 to High(FChildren) do
	begin
	if ii=0 then
		begin
		if FActiveButton<>-1 then
			i+=5+FActiveButtonTop
		else
			i+=5+FButtonTop;
		end
	else
		i+=5+FButtonTop;
	end;
CreateChild(TSButtonMenuButton.Create);
LastChild.SetBounds(0,i,FNeedWidth,FButtonTop);
LastChild.Caption:=SStringToPChar(s);
SetButton(FActiveButton);
end;

constructor TSButtonMenu.Create;
begin
inherited;
FActiveButton:=-1;
FButtonTop:=30;
FActiveButtonTop:=60;
FProcedure:=nil;
FLastActiveButton:=-1;
FMiddle:=False;
FMiddleTop:=0;
FSelectNotClick:=False;
end;

procedure TSButtonMenu.FromUpDate(var FCanChange:Boolean);
begin
if FActiveButton<>-1 then
	FChildren[FActiveButton].AsButton.FChangingButtonTimer:=1;
if FLastActiveButton<>FActiveButton then
	SetButton(FActiveButton);
inherited FromUpDate(FCanChange);
end;
{$ENDIF}
