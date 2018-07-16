{$INCLUDE SaGe.inc}

//{$DEFINE SGMoreDebuging}

unit SaGePaintableObjectContainer;

interface

uses
	 SaGeCommon
	,SaGeMesh
	,SaGeFont
	,SaGeBase
	,SaGeScreenClasses
	,SaGeRender
	,SaGeImage
	,SaGeContextClasses
	,SaGeContextInterface
	,SaGeRenderBase
	,SaGeScreenBase
	;

(*==============================================*)
(*=========TSGPaintableObjectContainer==========*)
(*==============================================*)

type
	TSGPaintableObjectContainerItem = object
			private
		FPaintableObjectClass : TSGPaintableObjectClass;
		FIsDrawable           : TSGBool;
			public
		property PaintableObjectClass : TSGPaintableObjectClass read FPaintableObjectClass write FPaintableObjectClass;
		property IsDrawable : TSGBool read FIsDrawable write FIsDrawable;
		end;

operator = (const Item1, Item2 : TSGPaintableObjectContainerItem) : TSGBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSGPaintableObjectContainerItemListHelper}
{$DEFINE DATATYPE_LIST        := TSGPaintableObjectContainerItemList}
{$DEFINE DATATYPE             := TSGPaintableObjectContainerItem}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

type
	TSGPaintableObjectContainer = class(TSGPaintableObject)
			public
		constructor Create(const _Context : ISGContext); override;
		destructor Destroy();override;
		class function ClassName() : TSGString;override;
		procedure DeleteRenderResources();override;
		procedure LoadRenderResources();override;
			protected
		FNowDraw     : TSGPaintableObject;
		FNowDrawable : TSGBoolean;
		FArClasses   : packed array of
			packed record 
				FClass    : TSGPaintableObjectClass;
				FDrawable : TSGBoolean;
				end;
		FComboBox : TSGScreenComboBox;
		FFont : TSGFont;
			protected
		procedure RestoreActiveStatuses();
			public
		procedure Paint();override;
		procedure Add(const NewClasses:TSGPaintableObjectContainerItemList);overload;
		procedure Add(const NewClass:TSGPaintableObjectClass; const Drawable : TSGBoolean = True);overload;
		procedure Initialize();overload;
		procedure Initialize(const Location : TSGComponentLocation);overload;
		procedure Initialize(const L, T, W, H : TSGScreenFloat);overload;
		procedure SwitchTo(const Index : TSGLongWord);
			public
		property ComboBox : TSGScreenComboBox read FComboBox;
		end;

procedure SGKill(var PaintableObjectContainer : TSGPaintableObjectContainer); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeStringUtils
	,SaGeFileUtils
	,SaGeLog
	;

operator = (const Item1, Item2 : TSGPaintableObjectContainerItem) : TSGBool; {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Result := (Item1.IsDrawable = Item2.IsDrawable) and (Item1.PaintableObjectClass = Item2.PaintableObjectClass);
end;

procedure SGKill(var PaintableObjectContainer : TSGPaintableObjectContainer); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (PaintableObjectContainer <> nil) then
	begin
	PaintableObjectContainer.Destroy();
	PaintableObjectContainer := nil;
	end;
end;

(*==============================================*)
(*=========TSGPaintableObjectContainer==========*)
(*==============================================*)

procedure TSGPaintableObjectContainer.DeleteRenderResources();
begin
if FNowDrawable and (FNowDraw <> nil) then
	FNowDraw.DeleteRenderResources();
end;

procedure TSGPaintableObjectContainer.RestoreActiveStatuses();
var
	Index : TSGMaxEnum;
begin
if (FComboBox <> nil) then
	for Index := 0 to FComboBox.ItemsCount - 1 do
		FComboBox.Items[Index].Active := FArClasses[Index].FClass.Supported(Context);
end;

procedure TSGPaintableObjectContainer.LoadRenderResources();
begin
RestoreActiveStatuses();
if FNowDrawable and (FNowDraw <> nil) then
	FNowDraw.LoadRenderResources();
end;

procedure TSGPaintableObjectContainer.SwitchTo(const Index : TSGLongWord);
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
		SGLog.Source('TSGPaintableObjectContainer(' + SGAddrStr(Self) + ')__SwitchTo --> "' + FArClasses[Index].FClass.ClassName() + '".');
		FNowDraw     := FArClasses[Index].FClass.Create(Context);
		FNowDrawable := FArClasses[Index].FDrawable;
		FComboBox.Caption := FArClasses[Index].FClass.ClassName();
		end;
end;

procedure TSGPaintableObjectContainer_ComboBoxProcedure(a, b :LongInt;VComboBox:TSGScreenComboBox);
begin
if a <> b then
	TSGPaintableObjectContainer(VComboBox.FUserPointer1).SwitchTo(b);
end;

procedure TSGPaintableObjectContainer.Initialize();overload;
begin
Initialize(SGComponentLocationImport(5, 5, 300, 18));
end;
procedure TSGPaintableObjectContainer.Initialize(const L, T, W, H : TSGScreenFloat);overload;
begin
Initialize(SGComponentLocationImport(Round(L), Round(T), Round(W), Round(H)));
end;

procedure TSGPaintableObjectContainer.Initialize(const Location : TSGComponentLocation);overload;
var
	i : TSGMaxEnum;
begin
{$IFDEF SGMoreDebuging}
	TSGLog.Source('Begin of  "TSGPaintableObjectContainer__Initialize" : "'+ClassName+'".');
	{$ENDIF}

FComboBox := SGCreateComboBox(Screen, Location.Left, Location.Top, Location.Width, Location.Height, TSGScreenComboBoxProcedure(@TSGPaintableObjectContainer_ComboBoxProcedure), FFont, True, True, Self);
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
{$IFDEF SGMoreDebuging}
	TSGLog.Source('End of  "TSGPaintableObjectContainer__Initialize" : "'+ClassName+'".');
	{$ENDIF}
end;

class function TSGPaintableObjectContainer.ClassName() : TSGString;
begin
Result := 'SaGe Draw Classes';
end;

procedure TSGPaintableObjectContainer.Paint();
begin
{$IFDEF SGMoreDebuging}
	TSGLog.Source('Begin of  "TSGPaintableObjectContainer__Draw" : "'+ClassName+'".');
	{$ENDIF}
if FNowDraw = nil then
	Initialize();
if FNowDrawable and (FNowDraw <> nil) then
	FNowDraw.Paint();
{$IFDEF SGMoreDebuging}
	TSGLog.Source('End of  "TSGPaintableObjectContainer__Draw" : "'+ClassName+'".');
	{$ENDIF}
end;

procedure TSGPaintableObjectContainer.Add(const NewClasses : TSGPaintableObjectContainerItemList);overload;
var
	i : TSGMaxEnum;
begin
if (NewClasses <> nil) and (Length(NewClasses) > 0) then 
	for i := 0 to High(NewClasses) do
		Add(NewClasses[i].PaintableObjectClass, NewClasses[i].IsDrawable);
end;

procedure TSGPaintableObjectContainer.Add(const NewClass:TSGPaintableObjectClass; const Drawable : TSGBoolean = True);overload;
begin
SetLength(FArClasses, Length(FArClasses) + 1);
FArClasses[High(FArClasses)].FClass    := NewClass;
FArClasses[High(FArClasses)].FDrawable := Drawable;
if FComboBox <> nil then
	FComboBox.Active:=Length(FArClasses) > 1;
end;

constructor TSGPaintableObjectContainer.Create(const _Context : ISGContext);
begin
inherited;
FNowDraw   := nil;
FArClasses := nil;
FComboBox := nil;

FFont := TSGFont.Create();
FFont.Context := Context;
FFont.FileName := SGFontDirectory + DirectorySeparator + 'Tahoma.sgf';
FFont.Loading();
end;

destructor TSGPaintableObjectContainer.Destroy;
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
SGKill(FFont);
inherited;
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSGPaintableObjectContainerItemListHelper}
{$DEFINE DATATYPE_LIST        := TSGPaintableObjectContainerItemList}
{$DEFINE DATATYPE             := TSGPaintableObjectContainerItem}
{$INCLUDE SaGeCommonList.inc}
{$INCLUDE SaGeCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
