{$IFDEF SCREEN_INTERFACE}
type
	TSGComboBoxProcedure = TSGButtonMenuProcedure;
	TSGComboBox = class(TSGOpenComponent, ISGComboBox)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
			protected
		FBackLight:Boolean;
		FBackLightTimer : TSGScreenTimer;
		FItems:TSGComboBoxItemList;
		FProcedure:TSGComboBoxProcedure;
		FMaxLines:longWord;
		FSelectedItemIndex:LongInt;
		FFirstScrollItem:LongInt;
		FCursorOnThisItem:LongInt;
		FScrollWidth:LongInt;

		FTextColor:TSGColor4f;
		FBodyColor:TSGColor4f;

		FClickOnOpenBox:Boolean;
			protected
		procedure OverItem(const Index : TSGUInt32); virtual;
		procedure SelectItemFromIndex(const Index : TSGInt32); virtual;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromDraw;override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		function CursorInComponent():boolean;override;
			public
		procedure CreateItem(const ItemCaption:TSGCaption;const ItemImage:TSGImage = nil;const FIdent:TSGInt32 = -1; const VActive : TSGBoolean = True);
		procedure ClearItems();
		function GetItems() : PSGComboBoxItem;
		function GetItemsCount() : TSGUInt32;
		function GetLines() : TSGUInt32;
		function GetSelectedItem() : PSGComboBoxItem;
		function GetFirstItemIndex() : TSGUInt32;
			public
		property SelectedItemIndex : LongInt  read FSelectedItemIndex write SelectItemFromIndex;
		property SelectItem        : LongInt  read FSelectedItemIndex write SelectItemFromIndex;
		property MaxLines          : LongWord read FMaxLines          write FMaxLines;

		property Lines      : TSGUInt32 read GetLines;
		property CallBackProcedure : TSGComboBoxProcedure read FProcedure write FProcedure;

		property ItemsCount : TSGUInt32 read GetItemsCount;
		property Items : PSGComboBoxItem read GetItems;
		end;
{$ENDIF}

{$IFDEF SCREEN_IMPLEMENTATION}
class function TSGComboBox.ClassName() : TSGString;
begin
Result := 'TSGComboBox';
end;

procedure TSGComboBox.SelectItemFromIndex(const Index : TSGInt32);
var
	i : TSGUInt32;
begin
FSelectedItemIndex := Index;
if ItemsCount > 0 then
	for i := 0 to ItemsCount - 1 do
		FItems[i].Selected := Index = i;
end;

procedure TSGComboBox.OverItem(const Index : TSGUInt32);
var
	i : TSGUInt32;
begin
if ItemsCount > 0 then
	for i := 0 to ItemsCount - 1 do
		FItems[i].Over := Index = i;
end;

function TSGComboBox.GetItems() : PSGComboBoxItem;
begin
Result := nil;
if FItems <> nil then
	Result := @FItems[0];
end;

function TSGComboBox.GetItemsCount() : TSGUInt32;
begin
Result := 0;
if FItems <> nil then
	Result := Length(FItems);
end;

procedure TSGComboBox.ClearItems();
begin
SetLength(FItems,0);
FItems:=nil;
FSelectedItemIndex := -1;
end;

function TSGComboBox.CursorInComponent():boolean;
begin
Result:=
	(Context.CursorPosition(SGNowCursorPosition).x>=FRealLeft)and
	(Context.CursorPosition(SGNowCursorPosition).x<=FRealLeft+FWidth)and
	(Context.CursorPosition(SGNowCursorPosition).y>=FRealTop)and
	(
	(FOpen and
		(
		(Context.CursorPosition(SGNowCursorPosition).y<=FRealTop+FHeight*Lines*FOpenTimer)
		or
		(Context.CursorPosition(SGNowCursorPosition).y<=FRealTop+FHeight)
		)
	)
	or
	((not FOpen) and (Context.CursorPosition(SGNowCursorPosition).y<=FRealTop+FHeight))
	);
FCursorOnComponent:=Result;
end;

function TSGComboBox.GetLines() : TSGUInt32;
begin
if FItems<>nil then
	if FMaxLines>Length(FItems) then
		Result:=Length(FItems)
	else
		Result:=FMaxLines
else
	Result:=0;
end;

procedure TSGComboBox.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);

procedure MoveUpOrDown();
var
	FNewSelectItemIndex : TSGUInt32 = 0;

procedure DoMove();
begin
CanRePleace:=False;
ClearPriority();
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGComboBox__FromUpDateUnderCursor() : Before calling "FProcedure(...)"');
	{$ENDIF}
if FProcedure<>nil then
	FProcedure(FSelectedItemIndex,FNewSelectItemIndex,Self);
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGComboBox__FromUpDateUnderCursor() : After calling "FProcedure(...)"');
	{$ENDIF}
SelectedItemIndex := FNewSelectItemIndex;
FTextColor:=SGVertex4fImport();
FBodyColor:=SGVertex4fImport();
if OnChange <> nil then
	OnChange(Self);
end;

begin
if (Lines - 1 > FSelectedItemIndex) and (Context.CursorWheel = SGUpCursorWheel) then
	begin
	Context.SetCursorWheel(SGNullCursorWheel);
	FNewSelectItemIndex := FSelectedItemIndex + 1;
	DoMove();
	end
else if (0 < FSelectedItemIndex) and (Context.CursorWheel = SGDownCursorWheel) then
	begin
	Context.SetCursorWheel(SGNullCursorWheel);
	FNewSelectItemIndex := FSelectedItemIndex - 1;
	DoMove();
	end;
end;

begin
{$IFDEF SCREEN_DEBUG}
WriteLn('TSGComboBox__FromUpDateUnderCursor() : Begining');
	{$ENDIF}
if CursorInComponentNow then
	begin
	FBackLight:=True;
	if ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) and (not FOpen) and CanRePleace then
		begin
		FOpen:=True;
		CanRePleace:=False;
		Context.SetCursorKey(SGNullKey, SGNullCursorButton);
		MakePriority();
		end
	else
		FCursorOnThisItem:=-1;
	if (not FOpen) and (Context.CursorWheel <> SGNullCursorWheel) then
		MoveUpOrDown();
	if FOpen and CanRePleace then
		if ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) then
			begin
			CanRePleace:=False;
			FClickOnOpenBox:=True;
			Context.SetCursorKey(SGNullKey, SGNullCursorButton);
			end;
	if FOpen and (Context.CursorWheel<>SGNullCursorWheel) then
		begin
		if Context.CursorWheel=SGUpCursorWheel then
			begin
			if FFirstScrollItem<>0 then
				FFirstScrollItem-=1;
			end
		else
			begin
			if FFirstScrollItem+Lines-1<>High(FItems) then
				begin
				FFirstScrollItem+=1;
				end;
			end;
		Context.SetCursorWheel(SGNullCursorWheel);
		CanRePleace:=False;
		end;
	end;
inherited FromUpDateUnderCursor(CanRePleace,CursorInComponentNow);
{$IFDEF SCREEN_DEBUG}
WriteLn('TSGComboBox__FromUpDateUnderCursor() : End');
	{$ENDIF}
end;

procedure TSGComboBox.FromUpDate(var FCanChange:Boolean);
var
	i:TSGMaxEnum;
begin
{$IFDEF SCREEN_DEBUG}
WriteLn('TSGComboBox.FromUpDate() : Begining');
	{$ENDIF}
if FOpen and (not FBackLight) and ((not FCanChange) or (Context.CursorKeyPressed<>SGNullCursorButton)) then
	begin
	FOpen:=False;
	ClearPriority();
	end;
if  FOpen and (FCursorOnComponent) then
	begin
	for i:=0 to Lines-1 do
		begin
		if  (Context.CursorPosition(SGNowCursorPosition).y>=FRealTop+FHeight*i*FOpenTimer) and
			(Context.CursorPosition(SGNowCursorPosition).y<=FRealTop+FHeight*(i+1)*FOpenTimer) and
			(((FMaxLines<Length(FItems)) and
			(Context.CursorPosition(SGNowCursorPosition).x<=FRealLeft+Width-FScrollWidth)) or (FMaxLines>=Length(FItems))) and
			FItems[i].Active then
				begin
				FCursorOnThisItem := FFirstScrollItem + i;
				OverItem(FCursorOnThisItem);
				if FClickOnOpenBox then
					begin
					FCanChange:=False;
					FOpen:=False;
					ClearPriority();
					{$IFDEF SCREEN_DEBUG}
						WriteLn('TSGComboBox__FromUpDate() : Before calling "FProcedure(...)"');
						{$ENDIF}
					if FProcedure<>nil then
						FProcedure(FSelectedItemIndex,FCursorOnThisItem,Self);
					{$IFDEF SCREEN_DEBUG}
						WriteLn('TSGComboBox__FromUpDate() : After calling "FProcedure(...)"');
						{$ENDIF}
					SelectedItemIndex:=FCursorOnThisItem;
					Context.SetCursorKey(SGNullKey, SGNullCursorButton);
					FTextColor:=SGVertex4fImport();
					FBodyColor:=SGVertex4fImport();
					if OnChange<>nil then
						OnChange(Self);
					FClickOnOpenBox:=False;
					end;
				Break;
				end
		else
			OverItem(ItemsCount);
		end;
	end
else
	OverItem(ItemsCount);
UpgradeTimer(FBackLight,FBackLightTimer,3,2);
inherited;
{$IFDEF SCREEN_DEBUG}
WriteLn('TSGComboBox.FromUpDate() : End');
	{$ENDIF}
end;

procedure TSGComboBox.FromDraw;
begin
if not CursorInComponent then
	FCursorOnThisItem:=-1;
if (FVisible) or (FVisibleTimer>SGZero) then
	begin
	FSkin.PaintComboBox(Self);
	end;
FBackLight:=False;
inherited;
end;

function TSGComboBox.GetFirstItemIndex() : TSGUInt32;
begin
Result := FFirstScrollItem;
end;

function TSGComboBox.GetSelectedItem() : PSGComboBoxItem;
begin
Result := nil;
if FSelectedItemIndex <> -1 then
	begin
	Result := @FItems[FSelectedItemIndex];
	end;
end;

procedure TSGComboBox.CreateItem(const ItemCaption:TSGCaption;const ItemImage:TSGImage = nil;const FIdent:TSGInt32 = -1; const VActive : TSGBoolean = True);
begin
if Self <> nil then
	begin
	SetLength(FItems, Length(FItems) + 1);
	FItems[High(FItems)].Clear();
	FItems[High(FItems)].Caption    := ItemCaption;
	FItems[High(FItems)].Image      := ItemImage;
	FItems[High(FItems)].Identifier := FIdent;
	FItems[High(FItems)].Active     := VActive;
	end;
end;

constructor TSGComboBox.Create();
begin
inherited;
FClickOnOpenBox:=False;
FOpenTimer:=0;
FOpen:=False;
FBackLight:=False;
FBackLightTimer:=0;
FMaxLines:=30;
FSelectedItemIndex:=-1;
FFirstScrollItem:=0;
FCursorOnThisItem:=0;
FScrollWidth:=20;
end;

destructor TSGComboBox.Destroy;
var
	i : TSGUInt32;
begin
if FItems <> nil then
	begin
	if Length(FItems) > 0 then
		begin
		for i := 0 to High(FItems) do
			FItems[i].Clear();
		SetLength(FItems, 0);
		end;
	FItems := nil;
	end;
inherited;
end;

{$ENDIF}
