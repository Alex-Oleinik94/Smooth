{$IFDEF SCREEN_INTERFACE}
type
	TSGButtonMenuProcedure = procedure (a,b:LongInt;p:Pointer);
	TSGButtonMenuButton=class(TSGButton)
			public
		constructor Create;override;
		class function ClassName() : TSGString; override;
			public
		FIdentifity:Int64;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
			public
		property Identifity : int64 read FIdentifity write FIdentifity;
		end;
	TSGButtonMenu=class(TSGComponent)
			public
		constructor Create;override;
		class function ClassName() : TSGString; override;
			public
		FActiveButton:longint;
		FButtonTop:TSGScreenInt;
		FActiveButtonTop:TSGScreenInt;
		FLastActiveButton:LongInt;
		FProcedure:TSGButtonMenuProcedure;
		
		FMiddle:boolean;
		FMiddleTop:TSGScreenInt;
		
		FSelectNotClick:Boolean;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure BoundsToNeedBounds;override;
			public
		procedure AddButton(const s:string;const FFActive:boolean = False);
		procedure SetButton(const l:LongInt);
		procedure GetMiddleTop;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		property ButtonTop:TSGScreenInt read FButtonTop write FButtonTop;
		property ActiveButtonTop:TSGScreenInt read FActiveButtonTop write FActiveButtonTop;
		procedure DetectActiveButton;virtual;
		end;
{$ENDIF}

{$IFDEF SCREEN_IMPLEMENTATION}
class function TSGButtonMenuButton.ClassName() : TSGString; 
begin
Result := 'TSGButtonMenuButton';
end;

class function TSGButtonMenu.ClassName() : TSGString; 
begin
Result := 'TSGButtonMenu';
end;

procedure TSGButtonMenu.DetectActiveButton;
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

constructor TSGButtonMenuButton.Create;
begin
inherited;
FIdentifity:=-1;
end;

procedure TSGButtonMenu.BoundsToNeedBounds;
var
	i:LongInt;
begin
inherited;
for i:=0 to High(FChildren) do
	FChildren[i].BoundsToNeedBounds;
end;

procedure TSGButtonMenu.GetMiddleTop;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Length(FChildren)>0 then
	FMiddleTop:=Round((Height-(LastChild.Top+LastChild.Height-FChildren[0].Top))/2)
else
	FMiddleTop:=0;
end;

procedure TSGButtonMenuButton.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
var
	i,ii:LongInt;
begin
if CursorInComponentNow then
	begin
	if Active and (((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) or Parent.AsButtonMenu.FSelectNotClick) then
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

procedure TSGButtonMenu.SetButton(const l:LongInt);
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

procedure TSGButtonMenu.AddButton(const s:string;const FFActive:boolean = False);
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
CreateChild(TSGButtonMenuButton.Create);
LastChild.SetBounds(0,i,FNeedWidth,FButtonTop);
LastChild.Caption:=SGStringToPChar(s);
SetButton(FActiveButton);
end;

constructor TSGButtonMenu.Create;
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

procedure TSGButtonMenu.FromUpDate(var FCanChange:Boolean);
begin
if FActiveButton<>-1 then
	FChildren[FActiveButton].AsButton.FChangingButtonTimer:=1;
if FLastActiveButton<>FActiveButton then
	SetButton(FActiveButton);
inherited FromUpDate(FCanChange);
end;
{$ENDIF}
