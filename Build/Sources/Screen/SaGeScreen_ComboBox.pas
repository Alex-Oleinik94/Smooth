{$INCLUDE SaGe.inc}

unit SaGeScreen_ComboBox;

interface

uses
	 SaGeBase
	,SaGeScreenBase
	,SaGeScreenCommonComponents
	,SaGeCommonStructs
	,SaGeImage
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
		procedure SelectingItem(const ItemIndex : TSGInt32); virtual;
			public
		procedure FromUpDate();override;
		procedure Paint(); override;
		procedure FromUpDateUnderCursor(const CursorInComponentNow:Boolean = True);override;
		function CursorInComponent():boolean;override;
			public
		procedure CreateItem(const ItemCaption:TSGCaption;const ItemImage:TSGImage = nil;const FIdent:TSGInt32 = -1; const VActive : TSGBoolean = True);
		procedure ClearItems();
		function GetItems() : PSGComboBoxItem;
		function GetItemsCount() : TSGUInt32;
		function GetLinesCount() : TSGUInt32;
		function GetSelectedItem() : PSGComboBoxItem;
		function GetFirstItemIndex() : TSGUInt32;
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
SetLength(FItems,0);
FItems:=nil;
FSelectedItemIndex := -1;
end;

function TSGComboBox.CursorInComponent() : TSGBoolean;
begin
Result:=
	(Context.CursorPosition(SGNowCursorPosition).x>=FRealPosition.x)and
	(Context.CursorPosition(SGNowCursorPosition).x<=FRealPosition.x+FRealLocation.Width)and
	(Context.CursorPosition(SGNowCursorPosition).y>=FRealPosition.y)and
	(
	(FOpen and
		(
		(Context.CursorPosition(SGNowCursorPosition).y<=FRealPosition.y+FRealLocation.Height * LinesCount * FOpenTimer)
		or
		(Context.CursorPosition(SGNowCursorPosition).y<=FRealPosition.y+FRealLocation.Height)
		)
	)
	or
	((not FOpen) and (Context.CursorPosition(SGNowCursorPosition).y<=FRealPosition.y+FRealLocation.Height))
	);
FCursorOnComponent:=Result;
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

procedure TSGComboBox.FromUpDateUnderCursor(const CursorInComponentNow:Boolean = True);
begin
{$IFDEF SCREEN_DEBUG}
WriteLn('TSGComboBox__FromUpDateUnderCursor() : Begining');
	{$ENDIF}
if CursorInComponentNow then
	begin
	FBackLight:=True;
	if ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) and (not FOpen) then
		begin
		FOpen:=True;
		Context.SetCursorKey(SGNullKey, SGNullCursorButton);
		MakePriority();
		end
	else
		FCursorOnThisItem:=-1;
	if (not FOpen) and (Context.CursorWheel <> SGNullCursorWheel) then
		begin
		if (ItemsCount - 1 > FSelectedItemIndex) and (Context.CursorWheel = SGUpCursorWheel) then
			SelectingItem(FSelectedItemIndex + 1)
		else if (0 < FSelectedItemIndex) and (Context.CursorWheel = SGDownCursorWheel) then
			SelectingItem(FSelectedItemIndex - 1);
		Context.SetCursorWheel(SGNullCursorWheel);
		end;
	if FOpen then
		if ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) then
			begin
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
			if FFirstScrollItem + LinesCount - 1 <> High(FItems) then
				begin
				FFirstScrollItem+=1;
				end;
			end;
		Context.SetCursorWheel(SGNullCursorWheel);
		end;
	end;
inherited FromUpDateUnderCursor(CursorInComponentNow);
{$IFDEF SCREEN_DEBUG}
WriteLn('TSGComboBox__FromUpDateUnderCursor() : End');
	{$ENDIF}
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

procedure TSGComboBox.FromUpDate();
var
	i:TSGMaxEnum;
begin
{$IFDEF SCREEN_DEBUG}
WriteLn('TSGComboBox.FromUpDate() : Begining');
	{$ENDIF}
if FOpen and (not FBackLight) and (Context.CursorKeyPressed<>SGNullCursorButton) then
	begin
	FOpen:=False;
	ClearPriority();
	end;
if  FOpen and (FCursorOnComponent) then
	begin
	for i := 0 to LinesCount - 1 do
		begin
		if  (Context.CursorPosition(SGNowCursorPosition).y>=FRealPosition.y+FRealLocation.Height*i*FOpenTimer) and
			(Context.CursorPosition(SGNowCursorPosition).y<=FRealPosition.y+FRealLocation.Height*(i+1)*FOpenTimer) and
			(((FMaxLines<Length(FItems)) and
			(Context.CursorPosition(SGNowCursorPosition).x<=FRealPosition.x+Width-FScrollWidth)) or (FMaxLines>=Length(FItems))) and
			FItems[i].Active then
				begin
				FCursorOnThisItem := FFirstScrollItem + i;
				OverItem(FCursorOnThisItem);
				if FClickOnOpenBox then
					begin
					FOpen:=False;
					SelectingItem(FCursorOnThisItem);
					Context.SetCursorKey(SGNullKey, SGNullCursorButton);
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

procedure TSGComboBox.Paint();
begin
if not CursorInComponent then
	FCursorOnThisItem:=-1;
if (FVisible) or (FVisibleTimer > SGZero) then
	FSkin.PaintComboBox(Self);
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

end.
