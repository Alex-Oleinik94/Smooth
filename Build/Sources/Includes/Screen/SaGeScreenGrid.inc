{$IFDEF SCREEN_INTERFACE}
type
	TSGGrid=class(TSGComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
			public
		FItems:TSGComponentListList;
		FSelectItems:
			record
				Point1: TSGPoint2int32;
				Point2: TSGPoint2int32;
				end;
		FQuantityXs,FQuantityYs:LongInt;
		FItemWidth,FItemHeight:LongInt;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromDraw;override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		procedure BoundsToNeedBounds;override;
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:TSGScreenInt);override;
			public
		procedure CreateItem(const ItemX,ItemY:LongInt;const ItemComponent:TSGComponent);
		function Items(const ItemX,ItemY:LongInt):TSGComponent;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetQuantityXs(const VQuantityXs:LongInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetQuantityYs(const VQuantityYs:LongInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		property QuantityXs:LongInt read FQuantityXs write SetQuantityXs;
		property QuantityYs:LongInt read FQuantityYs write SetQuantityYs;
		procedure SetViewPortSize(const VQuantityXs,VQuantityYs:LongInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;
{$ENDIF}

{$IFDEF SCREEN_IMPLEMENTATION}

class function TSGGrid.ClassName() : TSGString; 
begin
Result := 'TSGGrid';
end;

procedure TSGGrid.SetViewPortSize(const VQuantityXs,VQuantityYs:LongInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
QuantityXs:=VQuantityXs;
QuantityYs:=VQuantityYs;
end;

procedure TSGGrid.SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:TSGScreenInt);
begin
inherited;
QuantityXs:=QuantityXs;
QuantityYs:=QuantityYs;
end;

procedure TSGGrid.SetQuantityXs(const VQuantityXs:LongInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FQuantityXs:=VQuantityXs;
FItemWidth:=Round(FNeedWidth/FQuantityXs);
end;

procedure TSGGrid.SetQuantityYs(const VQuantityYs:LongInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FQuantityYs:=VQuantityYs;
FItemHeight:=Round(FNeedHeight/FQuantityYs);
end;

procedure TSGGrid.BoundsToNeedBounds;
var
	i,ii:LongInt;
begin
inherited;
for i:=0 to High(FItems) do
	if FItems[i]<>nil then
		for ii:=0 to High(FItems[i]) do
			if FItems[i][ii]<>nil then
				FItems[i][ii].BoundsToNeedBounds;
end;

procedure TSGGrid.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
var
	i,ii:LongInt;
begin
inherited FromUpDateUnderCursor(CanRePleace,CursorInComponentNow);
if CursorInComponentNow then
	for i:=High(FItems) downto Low(FItems) do
		if FItems[i]<>nil then
			for ii:=High(FItems[i]) downto Low(FItems[i]) do
				if FItems[i][ii]<>nil then
					if FItems[i][ii].CursorInComponent() and FItems[i][ii].FVisible and FItems[i][ii].Active then
						begin
						FItems[i][ii].FromUpDateUnderCursor(CanRePleace);
						if FItems[i][ii].CursorInComponentCaption() then
							begin
							FItems[i][ii].FromUpDateCaptionUnderCursor(CanRePleace);
							end;
						Break;
						end;
end;

procedure TSGGrid.FromUpDate(var FCanChange:Boolean);
var
	i,ii:LongInt;
begin
inherited;
for i:=0 to High(FItems) do
	if FItems[i]<>nil then
		for ii:=0 to High(FItems[i]) do
			if FItems[i][ii]<>nil then
				FItems[i][ii].FromUpDate(FCanChange);
end;

procedure TSGGrid.FromDraw;
var
	i,ii:LongInt;
begin
inherited;
for i:=0 to High(FItems) do
	if FItems[i]<>nil then
		for ii:=0 to High(FItems[i]) do
			if FItems[i][ii]<>nil then
				FItems[i][ii].FromDraw;
end;

procedure TSGGrid.CreateItem(const ItemX,ItemY:LongInt;const ItemComponent:TSGComponent);
var
	i,ii:LongInt;
begin
if ItemX>High(FItems) then
	begin
	ii:=High(FItems)+1;
	SetLength(FItems,ItemX+1);
	for i:=ii to High(FItems) do
		FItems[i]:=nil;
	end;
if ItemY>High(FItems[ItemX]) then
	begin
	ii:=High(FItems[ItemX])+1;
	SetLength(FItems[ItemX],ItemY+1);
	for i:=ii to High(FItems[ItemX]) do
		FItems[ItemX][i]:=nil;
	end;
FItems[ItemX][ItemY]:=ItemComponent;
ItemComponent.Parent:=Self;
end;

function TSGGrid.Items(const ItemX,ItemY:LongInt):TSGComponent;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (Length(FItems)<>0) and (ItemX<=High(FItems)) and (ItemX>=0) and (ItemY>=0) and (ItemY<=High(FItems[0])) then
	begin
	Result:=FItems[ItemX][ItemY];
	end
else
	begin
	Result:=nil;
	end;
end;

constructor TSGGrid.Create;
begin
inherited;
FItems:=nil;
QuantityXs:=5;
QuantityYs:=5;
end;

destructor TSGGrid.Destroy;
var
	ii,i:LongInt;
begin
for i:=0 to High(FItems) do
	for ii:=0 to High(FItems[i]) do
		if FItems[i][ii]<>nil then
			FItems[i][ii].Destroy;
inherited;
end;

{$ENDIF}
