{$INCLUDE SaGe.inc}

unit SaGeScreen_ComboBox;

interface

uses
	 SaGeBase
	,SaGeScreenBase
	,SaGeScreenCommonComponents
	,SaGeCommonStructs
	,SaGeImage
	,SaGeScreenComponentInterfaces
	;

type
	TSGComboBox = class;
	TSGComboBoxProcedure = procedure (_OldIndex, _NewIndex : TSGInt32; _ComboBox : TSGComboBox);
	TSGComboBox = class(TSGOpenComponent, ISGComboBox)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
			protected
		FItems : TSGComboBoxItemList;
		FProcedure : TSGComboBoxProcedure;
		FMaxLines : TSGUInt32;
		FSelectedItemIndex : TSGInt32;
		FFirstScrollItem : TSGInt32;
		FCursorOverThisItem : TSGInt32;
		FScrollWidth : TSGInt32;

		FTextColor : TSGColor4f;
		FBodyColor : TSGColor4f;
			protected
		procedure OverItem(const Index : TSGUInt32); virtual;
		procedure SelectItemFromIndex(const Index : TSGInt32); virtual;
		procedure SelectingItem(const ItemIndex : TSGInt32); virtual;
			public
		procedure UpDate();override;
		procedure Paint(); override;
		function CursorOverComponent() : TSGBoolean; override;
			public
		procedure CreateItem(const ItemCaption:TSGCaption;const ItemImage:TSGImage = nil;const FIdent:TSGInt32 = -1; const VActive : TSGBoolean = True);
		procedure ClearItems();
		function GetItems() : PSGComboBoxItem;
		function GetItemsCount() : TSGUInt32;
		function GetLinesCount() : TSGUInt32;
		function GetSelectedItem() : PSGComboBoxItem;
		function GetFirstItemIndex() : TSGUInt32;
		procedure MouseWheelSelecting();
			public
		property SelectedItemIndex : LongInt  read FSelectedItemIndex write SelectItemFromIndex;
		property SelectItem        : LongInt  read FSelectedItemIndex write SelectItemFromIndex;
		property MaxLines          : LongWord read FMaxLines          write FMaxLines;

		property LinesCount        : TSGUInt32 read GetLinesCount;
		property CallBackProcedure : TSGComboBoxProcedure read FProcedure write FProcedure;

		property ItemsCount : TSGUInt32 read GetItemsCount;
		property Items : PSGComboBoxItem read GetItems;
		end;

implementation

uses
	 SaGeContextUtils
	,SaGeMathUtils
	;

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
if (FItems <> nil) then
	Result := Length(FItems)
else
	Result := 0;
end;

procedure TSGComboBox.ClearItems();
begin
if (FItems <> nil) then
	SetLength(FItems, 0);
FItems := nil;
FSelectedItemIndex := -1;
end;

function TSGComboBox.CursorOverComponent() : TSGBoolean;
var
	CursorPosition : TSGVector2int32;
begin
CursorPosition := Context.CursorPosition(SGNowCursorPosition);
Result:=
	(CursorPosition.x >= FRealPosition.x)and
	(CursorPosition.x <= FRealPosition.x+FRealLocation.Width)and
	(CursorPosition.y >= FRealPosition.y)and
	((FOpen and
		((CursorPosition.y <= FRealPosition.y+FRealLocation.Height * LinesCount * FOpenTimer) or
		(CursorPosition.y <= FRealPosition.y+FRealLocation.Height))) or
	((not FOpen) and
		(CursorPosition.y <= FRealPosition.y+FRealLocation.Height)));
end;

function TSGComboBox.GetLinesCount() : TSGUInt32;
begin
if FItems<>nil then
	if FMaxLines>Length(FItems) then
		Result:=Length(FItems)
	else
		Result:=FMaxLines
else
	Result:=0;
end;

procedure TSGComboBox.SelectingItem(const ItemIndex : TSGInt32);
begin
ClearPriority();
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGComboBox__SelectingItem() : Before calling "FProcedure(...)"');
	{$ENDIF}
if (FProcedure <> nil) then
	FProcedure(FSelectedItemIndex, ItemIndex, Self);
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGComboBox__SelectingItem() : After calling "FProcedure(...)"');
	{$ENDIF}
SelectedItemIndex := ItemIndex;
FTextColor:=SGVertex4fImport();
FBodyColor:=SGVertex4fImport();
if (OnChange <> nil) then
	OnChange(Self);
end;

procedure TSGComboBox.MouseWheelSelecting();
var
	NewSelectedItemIndex : TSGInt64 = -1;

procedure FindNewSelectedItem(const One : TSGInt8);
var
	Index : TSGInt64;
begin
Index :=  FSelectedItemIndex;
while (Index >=0) and (Index < ItemsCount) do
	begin
	Index += One;
	if (Index >=0) and (Index < ItemsCount) and FItems[Index].Active then
		begin
		NewSelectedItemIndex := Index;
		break;
		end;
	end;
end;

begin
if (ItemsCount - 1 > FSelectedItemIndex) and (Context.CursorWheel = SGUpCursorWheel) then
	FindNewSelectedItem(1)
else if (0 < FSelectedItemIndex) and (Context.CursorWheel = SGDownCursorWheel) then
	FindNewSelectedItem(-1);
if (NewSelectedItemIndex <> -1) then
	SelectingItem(NewSelectedItemIndex);
end;

procedure TSGComboBox.UpDate();
var
	i : TSGMaxEnum;
begin
inherited;
{$IFDEF SCREEN_DEBUG}
WriteLn('TSGComboBox__UpDate() : Begining');
	{$ENDIF}
if CursorOver and Active and Visible then
	begin
	if (not FOpen) then
		begin
		if ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) then
			begin
			FOpen := True;
			Context.SetCursorKey(SGNullKey, SGNullCursorButton);
			MakePriority();
			end
		else
			FCursorOverThisItem := -1;
		if (Context.CursorWheel <> SGNullCursorWheel) then
			begin
			MouseWheelSelecting();
			Context.SetCursorWheel(SGNullCursorWheel);
			end;
		end
	else if (Context.CursorWheel<>SGNullCursorWheel) then
		begin
		if Context.CursorWheel=SGUpCursorWheel then
			begin
			if FFirstScrollItem <> 0 then
				FFirstScrollItem -= 1;
			end
		else
			begin
			if FFirstScrollItem + LinesCount - 1 <> High(FItems) then
				FFirstScrollItem += 1;
			end;
		Context.SetCursorWheel(SGNullCursorWheel);
		end;
	end
else if FOpen and (((not CursorOver) and (Context.CursorKeyPressed <> SGNullCursorButton)) or (not Active) or (not Visible))  then
	begin
	FOpen := False;
	ClearPriority();
	end;
if FOpen and CursorOver and Active and Visible then
	for i := 0 to LinesCount - 1 do
		if  (Context.CursorPosition(SGNowCursorPosition).y>=FRealPosition.y+FRealLocation.Height*i*FOpenTimer) and
			(Context.CursorPosition(SGNowCursorPosition).y<=FRealPosition.y+FRealLocation.Height*(i+1)*FOpenTimer) and
			(((FMaxLines < Length(FItems)) and
			(Context.CursorPosition(SGNowCursorPosition).x<=FRealPosition.x+Width-FScrollWidth)) or (FMaxLines>=Length(FItems))) and
			FItems[i].Active then
				begin
				FCursorOverThisItem := FFirstScrollItem + i;
				OverItem(FCursorOverThisItem);
				if ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) then
					begin
					FOpen := False;
					SelectingItem(FCursorOverThisItem);
					Context.SetCursorKey(SGNullKey, SGNullCursorButton);
					end;
				break;
				end
		else
			OverItem(ItemsCount)
else
	OverItem(ItemsCount);
{$IFDEF SCREEN_DEBUG}
WriteLn('TSGComboBox__UpDate() : End');
	{$ENDIF}
end;

procedure TSGComboBox.Paint();
begin
if not CursorOver then
	FCursorOverThisItem := -1;
if (FVisible) or (FVisibleTimer > SGZero) then
	FSkin.PaintComboBox(Self);
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
FOpenTimer:=0;
FOpen:=False;
FMaxLines:=30;
FSelectedItemIndex:=-1;
FFirstScrollItem:=0;
FCursorOverThisItem:=0;
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

end.
