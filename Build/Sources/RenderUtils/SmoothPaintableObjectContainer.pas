{$INCLUDE Smooth.inc}

//{$DEFINE SMoreDebuging}

unit SmoothPaintableObjectContainer;

interface

uses
	 SmoothCommon
	,Smooth3dObject
	,SmoothFont
	,SmoothBase
	,SmoothScreenClasses
	,SmoothRender
	,SmoothImage
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothRenderBase
	,SmoothScreenBase
	;

(*==============================================*)
(*=========TSPaintableObjectContainer==========*)
(*==============================================*)

type
	TSPaintableObjectContainerItem = object
			private
		FPaintableObjectClass : TSPaintableObjectClass;
		FIsDrawable           : TSBool;
			public
		property PaintableObjectClass : TSPaintableObjectClass read FPaintableObjectClass write FPaintableObjectClass;
		property IsDrawable : TSBool read FIsDrawable write FIsDrawable;
		end;

operator = (const Item1, Item2 : TSPaintableObjectContainerItem) : TSBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSPaintableObjectContainerItemListHelper}
{$DEFINE DATATYPE_LIST        := TSPaintableObjectContainerItemList}
{$DEFINE DATATYPE             := TSPaintableObjectContainerItem}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

type
	TSPaintableObjectContainer = class(TSPaintableObject)
			public
		constructor Create(const _Context : ISContext); override;
		destructor Destroy();override;
		class function ClassName() : TSString;override;
		procedure DeleteRenderResources();override;
		procedure LoadRenderResources();override;
			protected
		FNowDraw     : TSPaintableObject;
		FNowDrawable : TSBoolean;
		FArClasses   : packed array of
			packed record 
				FClass    : TSPaintableObjectClass;
				FDrawable : TSBoolean;
				end;
		FComboBox : TSScreenComboBox;
		FFont : TSFont;
			protected
		procedure RestoreActiveStatuses();
			public
		procedure Paint();override;
		procedure Add(const NewClasses:TSPaintableObjectContainerItemList);overload;
		procedure Add(const NewClass:TSPaintableObjectClass; const Drawable : TSBoolean = True);overload;
		procedure Initialize();overload;
		procedure Initialize(const Location : TSComponentLocation);overload;
		procedure Initialize(const L, T, W, H : TSScreenFloat);overload;
		procedure SwitchTo(const Index : TSLongWord);
			public
		property ComboBox : TSScreenComboBox read FComboBox;
		end;

procedure SKill(var PaintableObjectContainer : TSPaintableObjectContainer); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothStringUtils
	,SmoothFileUtils
	,SmoothLog
	;

operator = (const Item1, Item2 : TSPaintableObjectContainerItem) : TSBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := (Item1.IsDrawable = Item2.IsDrawable) and (Item1.PaintableObjectClass = Item2.PaintableObjectClass);
end;

procedure SKill(var PaintableObjectContainer : TSPaintableObjectContainer); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (PaintableObjectContainer <> nil) then
	begin
	PaintableObjectContainer.Destroy();
	PaintableObjectContainer := nil;
	end;
end;

(*==============================================*)
(*=========TSPaintableObjectContainer==========*)
(*==============================================*)

procedure TSPaintableObjectContainer.DeleteRenderResources();
begin
if FNowDrawable and (FNowDraw <> nil) then
	FNowDraw.DeleteRenderResources();
end;

procedure TSPaintableObjectContainer.RestoreActiveStatuses();
var
	Index : TSMaxEnum;
begin
if (FComboBox <> nil) then
	for Index := 0 to FComboBox.ItemsCount - 1 do
		FComboBox.Items[Index].Active := FArClasses[Index].FClass.Supported(Context);
end;

procedure TSPaintableObjectContainer.LoadRenderResources();
begin
RestoreActiveStatuses();
if FNowDrawable and (FNowDraw <> nil) then
	FNowDraw.LoadRenderResources();
end;

procedure TSPaintableObjectContainer.SwitchTo(const Index : TSLongWord);
begin
if FNowDraw <> nil then
	begin
	FNowDraw.DeleteRenderResources();
	FNowDraw.Destroy();
	FNowDraw := nil;
	end;
if FArClasses <> nil then
	if (Index >= 0) and (Index <= High(FArClasses)) then
		begin
		SLog.Source('TSPaintableObjectContainer(' + SAddrStr(Self) + ')__SwitchTo --> "' + FArClasses[Index].FClass.ClassName() + '".');
		FNowDraw     := FArClasses[Index].FClass.Create(Context);
		FNowDrawable := FArClasses[Index].FDrawable;
		FComboBox.Caption := FArClasses[Index].FClass.ClassName();
		end;
end;

procedure TSPaintableObjectContainer_ComboBoxProcedure(a, b :LongInt;VComboBox:TSScreenComboBox);
begin
if a <> b then
	TSPaintableObjectContainer(VComboBox.FUserPointer1).SwitchTo(b);
end;

procedure TSPaintableObjectContainer.Initialize();overload;
begin
Initialize(SComponentLocationImport(5, 5, 300, 18));
end;
procedure TSPaintableObjectContainer.Initialize(const L, T, W, H : TSScreenFloat);overload;
begin
Initialize(SComponentLocationImport(Round(L), Round(T), Round(W), Round(H)));
end;

procedure TSPaintableObjectContainer.Initialize(const Location : TSComponentLocation);overload;
var
	i : TSMaxEnum;
begin
{$IFDEF SMoreDebuging}
	TSLog.Source('Begin of  "TSPaintableObjectContainer__Initialize" : "'+ClassName+'".');
	{$ENDIF}

FComboBox := SCreateComboBox(Screen, Location.Left, Location.Top, Location.Width, Location.Height, TSScreenComboBoxProcedure(@TSPaintableObjectContainer_ComboBoxProcedure), FFont, True, True, Self);
FComboBox.SelectItem := 0;
FComboBox.Active := Length(FArClasses) > 1;
FComboBox.FDrawClass := Self;
if (FArClasses <> nil) and (Length(FArClasses) > 0) then
	for i:=0 to High(FArClasses) do
		FComboBox.CreateItem(FArClasses[i].FClass.ClassName, nil, -1, FArClasses[i].FClass.Supported(Context));
if (FArClasses <> nil) and (Length(FArClasses) > 0) then
	begin
	FComboBox.SelectItem := Random(Length(FArClasses));
	SwitchTo(FComboBox.SelectItem);
	end;
{$IFDEF SMoreDebuging}
	TSLog.Source('End of  "TSPaintableObjectContainer__Initialize" : "'+ClassName+'".');
	{$ENDIF}
end;

class function TSPaintableObjectContainer.ClassName() : TSString;
begin
Result := 'Smooth Draw Classes';
end;

procedure TSPaintableObjectContainer.Paint();
begin
{$IFDEF SMoreDebuging}
	TSLog.Source('Begin of  "TSPaintableObjectContainer__Draw" : "'+ClassName+'".');
	{$ENDIF}
if FNowDraw = nil then
	Initialize();
if FNowDrawable and (FNowDraw <> nil) then
	FNowDraw.Paint();
{$IFDEF SMoreDebuging}
	TSLog.Source('End of  "TSPaintableObjectContainer__Draw" : "'+ClassName+'".');
	{$ENDIF}
end;

procedure TSPaintableObjectContainer.Add(const NewClasses : TSPaintableObjectContainerItemList);overload;
var
	i : TSMaxEnum;
begin
if (NewClasses <> nil) and (Length(NewClasses) > 0) then 
	for i := 0 to High(NewClasses) do
		Add(NewClasses[i].PaintableObjectClass, NewClasses[i].IsDrawable);
end;

procedure TSPaintableObjectContainer.Add(const NewClass:TSPaintableObjectClass; const Drawable : TSBoolean = True);overload;
begin
SetLength(FArClasses, Length(FArClasses) + 1);
FArClasses[High(FArClasses)].FClass    := NewClass;
FArClasses[High(FArClasses)].FDrawable := Drawable;
if FComboBox <> nil then
	FComboBox.Active:=Length(FArClasses) > 1;
end;

constructor TSPaintableObjectContainer.Create(const _Context : ISContext);
begin
inherited;
FNowDraw   := nil;
FArClasses := nil;
FComboBox := nil;
FFont := SCreateFontFromFile(Context, SDefaultFontFileName);
end;

destructor TSPaintableObjectContainer.Destroy;
begin
if FNowDraw <> nil then
	begin
	FNowDraw.Destroy();
	FNowDraw := nil;
	FNowDrawable := False;
	end;
if FComboBox <> nil then
	begin
	FComboBox.FDrawClass := nil;
	FComboBox.Skin.Font := nil;
	FComboBox.MarkForDestroy();
	FComboBox := nil;
	end;
if FArClasses <> nil then
	begin
	SetLength(FArClasses, 0);
	FArClasses := nil;
	end;
SKill(FFont);
inherited;
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSPaintableObjectContainerItemListHelper}
{$DEFINE DATATYPE_LIST        := TSPaintableObjectContainerItemList}
{$DEFINE DATATYPE             := TSPaintableObjectContainerItem}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
