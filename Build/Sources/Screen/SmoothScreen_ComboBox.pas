{$INCLUDE Smooth.inc}

unit SmoothScreen_ComboBox;

interface

uses
	 SmoothBase
	,SmoothScreenBase
	,SmoothScreenCommonComponents
	,SmoothCommonStructs
	,SmoothImage
	,SmoothScreenComponentInterfaces
	;

type
	TSComboBox = class;
	TSComboBoxProcedure = procedure (_OldIndex, _NewIndex : TSInt32; _ComboBox : TSComboBox);
	TSComboBox = class(TSOpenComponent, ISComboBox)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSString; override;
			protected
		FItems : TSComboBoxItemList;
		FProcedure : TSComboBoxProcedure;
		FMaxLines : TSUInt32;
		FSelectedItemIndex : TSInt32;
		FFirstScrollItem : TSInt32;
		FCursorOverThisItem : TSInt32;
		FScrollWidth : TSInt32;

		FTextColor : TSColor4f;
		FBodyColor : TSColor4f;
			protected
		procedure OverItem(const Index : TSUInt32); virtual;
		procedure SelectItemFromIndex(const Index : TSInt32); virtual;
		procedure SelectingItem(const ItemIndex : TSInt32); virtual;
			public
		procedure UpDate();override;
		procedure Paint(); override;
		function CursorOverComponent() : TSBoolean; override;
			public
		procedure CreateItem(const ItemCaption:TSCaption;const ItemImage:TSImage = nil;const FIdent:TSInt32 = -1; const VActive : TSBoolean = True);
		procedure ClearItems();
		function GetItems() : PSComboBoxItem;
		function GetItemsCount() : TSUInt32;
		function GetLinesCount() : TSUInt32;
		function GetSelectedItem() : PSComboBoxItem;
		function GetFirstItemIndex() : TSUInt32;
		procedure MouseWheelSelecting();
			public
		property SelectedItemIndex : LongInt  read FSelectedItemIndex write SelectItemFromIndex;
		property SelectItem        : LongInt  read FSelectedItemIndex write SelectItemFromIndex;
		property MaxLines          : LongWord read FMaxLines          write FMaxLines;

		property LinesCount        : TSUInt32 read GetLinesCount;
		property CallBackProcedure : TSComboBoxProcedure read FProcedure write FProcedure;

		property ItemsCount : TSUInt32 read GetItemsCount;
		property Items : PSComboBoxItem read GetItems;
		end;

implementation

uses
	 SmoothContextUtils
	,SmoothMathUtils
	;

class function TSComboBox.ClassName() : TSString;
begin
Result := 'TSComboBox';
end;

procedure TSComboBox.SelectItemFromIndex(const Index : TSInt32);
var
	i : TSUInt32;
begin
FSelectedItemIndex := Index;
if ItemsCount > 0 then
	for i := 0 to ItemsCount - 1 do
		FItems[i].Selected := Index = i;
end;

procedure TSComboBox.OverItem(const Index : TSUInt32);
var
	i : TSUInt32;
begin
if ItemsCount > 0 then
	for i := 0 to ItemsCount - 1 do
		FItems[i].Over := Index = i;
end;

function TSComboBox.GetItems() : PSComboBoxItem;
begin
Result := nil;
if FItems <> nil then
	Result := @FItems[0];
end;

function TSComboBox.GetItemsCount() : TSUInt32;
begin
if (FItems <> nil) then
	Result := Length(FItems)
else
	Result := 0;
end;

procedure TSComboBox.ClearItems();
begin
if (FItems <> nil) then
	SetLength(FItems, 0);
FItems := nil;
FSelectedItemIndex := -1;
end;

function TSComboBox.CursorOverComponent() : TSBoolean;
var
	CursorPosition : TSVector2int32;
begin
CursorPosition := Context.CursorPosition(SNowCursorPosition);
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

function TSComboBox.GetLinesCount() : TSUInt32;
begin
if FItems<>nil then
	if FMaxLines>Length(FItems) then
		Result:=Length(FItems)
	else
		Result:=FMaxLines
else
	Result:=0;
end;

procedure TSComboBox.SelectingItem(const ItemIndex : TSInt32);
begin
ClearPriority();
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSComboBox__SelectingItem() : Before calling "FProcedure(...)"');
	{$ENDIF}
if (FProcedure <> nil) then
	FProcedure(FSelectedItemIndex, ItemIndex, Self);
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSComboBox__SelectingItem() : After calling "FProcedure(...)"');
	{$ENDIF}
SelectedItemIndex := ItemIndex;
FTextColor:=SVertex4fImport();
FBodyColor:=SVertex4fImport();
if (OnChange <> nil) then
	OnChange(Self);
end;

procedure TSComboBox.MouseWheelSelecting();
var
	NewSelectedItemIndex : TSInt64 = -1;

procedure FindNewSelectedItem(const One : TSInt8);
var
	Index : TSInt64;
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
if (ItemsCount - 1 > FSelectedItemIndex) and (Context.CursorWheel = SUpCursorWheel) then
	FindNewSelectedItem(1)
else if (0 < FSelectedItemIndex) and (Context.CursorWheel = SDownCursorWheel) then
	FindNewSelectedItem(-1);
if (NewSelectedItemIndex <> -1) then
	SelectingItem(NewSelectedItemIndex);
end;

procedure TSComboBox.UpDate();
var
	i : TSMaxEnum;
begin
inherited;
{$IFDEF SCREEN_DEBUG}
WriteLn('TSComboBox__UpDate() : Begining');
	{$ENDIF}
if CursorOver and Active and Visible then
	begin
	if (not FOpen) then
		begin
		if ((Context.CursorKeyPressed=SLeftCursorButton) and (Context.CursorKeyPressedType=SUpKey)) then
			begin
			FOpen := True;
			Context.SetCursorKey(SNullKey, SNullCursorButton);
			MakePriority();
			end
		else
			FCursorOverThisItem := -1;
		if (Context.CursorWheel <> SNullCursorWheel) then
			begin
			MouseWheelSelecting();
			Context.SetCursorWheel(SNullCursorWheel);
			end;
		end
	else if (Context.CursorWheel<>SNullCursorWheel) then
		begin
		if Context.CursorWheel=SUpCursorWheel then
			begin
			if FFirstScrollItem <> 0 then
				FFirstScrollItem -= 1;
			end
		else
			begin
			if FFirstScrollItem + LinesCount - 1 <> High(FItems) then
				FFirstScrollItem += 1;
			end;
		Context.SetCursorWheel(SNullCursorWheel);
		end;
	end
else if FOpen and (((not CursorOver) and (Context.CursorKeyPressed <> SNullCursorButton)) or (not Active) or (not Visible))  then
	begin
	FOpen := False;
	ClearPriority();
	end;
if FOpen and CursorOver and Active and Visible then
	for i := 0 to LinesCount - 1 do
		if  (Context.CursorPosition(SNowCursorPosition).y>=FRealPosition.y+FRealLocation.Height*i*FOpenTimer) and
			(Context.CursorPosition(SNowCursorPosition).y<=FRealPosition.y+FRealLocation.Height*(i+1)*FOpenTimer) and
			(((FMaxLines < Length(FItems)) and
			(Context.CursorPosition(SNowCursorPosition).x<=FRealPosition.x+Width-FScrollWidth)) or (FMaxLines>=Length(FItems))) and
			FItems[i].Active then
				begin
				FCursorOverThisItem := FFirstScrollItem + i;
				OverItem(FCursorOverThisItem);
				if ((Context.CursorKeyPressed=SLeftCursorButton) and (Context.CursorKeyPressedType=SUpKey)) then
					begin
					FOpen := False;
					SelectingItem(FCursorOverThisItem);
					Context.SetCursorKey(SNullKey, SNullCursorButton);
					end;
				break;
				end
		else
			OverItem(ItemsCount)
else
	OverItem(ItemsCount);
{$IFDEF SCREEN_DEBUG}
WriteLn('TSComboBox__UpDate() : End');
	{$ENDIF}
end;

procedure TSComboBox.Paint();
begin
if not CursorOver then
	FCursorOverThisItem := -1;
if (FVisible) or (FVisibleTimer > SZero) then
	FSkin.PaintComboBox(Self);
inherited;
end;

function TSComboBox.GetFirstItemIndex() : TSUInt32;
begin
Result := FFirstScrollItem;
end;

function TSComboBox.GetSelectedItem() : PSComboBoxItem;
begin
Result := nil;
if FSelectedItemIndex <> -1 then
	begin
	Result := @FItems[FSelectedItemIndex];
	end;
end;

procedure TSComboBox.CreateItem(const ItemCaption:TSCaption;const ItemImage:TSImage = nil;const FIdent:TSInt32 = -1; const VActive : TSBoolean = True);
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

constructor TSComboBox.Create();
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

destructor TSComboBox.Destroy;
var
	i : TSUInt32;
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
