{$INCLUDE SaGe.inc}

unit SaGeCommonUtils;

interface

uses
	SaGeCommon
	,SaGeMesh
	,SaGeUtils
	,SaGeBase
	,SaGeBased
	,SaGeScreen
	,SaGeRender
	,SaGeImages
	,SaGeCommonClasses
	,SaGeRenderConstants
	,SaGeScreenBase
	;

(*=================================*)
(*=========TSGDrawClasses==========*)
(*=================================*)

type
	TSGDrawClassesObject = object
		public
		FClass : TSGDrawableClass;
		FDrawable : TSGBool;
		end;
	TSGDrawClassesObjectList = packed array of TSGDrawClassesObject;
	
	TSGDrawClasses = class(TSGScreenedDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName() : TSGString;override;
		procedure DeleteDeviceResources();override;
		procedure LoadDeviceResources();override;
			public
		FNowDraw     : TSGDrawable;
		FNowDrawable : TSGBoolean;
		FArClasses   : packed array of
			packed record 
				FClass    : TSGDrawableClass;
				FDrawable : TSGBoolean;
				end;
		FComboBox : TSGComboBox;
			public
		procedure Paint();override;
		procedure Add(const NewClasses:TSGDrawClassesObjectList);overload;
		procedure Add(const NewClass:TSGDrawableClass; const Drawable : TSGBoolean = True);overload;
		procedure Initialize();overload;
		procedure Initialize(const Location : TSGComponentLocation);overload;
		procedure Initialize(const L, T, W, H : TSGScreenFloat);overload;
		procedure SwitchTo(const Index : TSGLongWord);
			public
		property ComboBox : TSGComboBox read FComboBox;
		end;

implementation

(*=================================*)
(*=========TSGDrawClasses==========*)
(*=================================*)

procedure TSGDrawClasses.DeleteDeviceResources();
begin
if FNowDrawable and (FNowDraw <> nil) then
	FNowDraw.DeleteDeviceResources();
end;

procedure TSGDrawClasses.LoadDeviceResources();
begin
if FNowDrawable and (FNowDraw <> nil) then
	FNowDraw.LoadDeviceResources();
end;

procedure TSGDrawClasses.SwitchTo(const Index : TSGLongWord);
begin
if FNowDraw <> nil then
	begin
	FNowDraw.DeleteDeviceResources();
	FNowDraw.Destroy();
	FNowDraw := nil;
	end;
if FArClasses <> nil then
	if (Index >= 0) and (Index <= High(FArClasses)) then
		begin
		FNowDraw     := FArClasses[Index].FClass.Create(Context);
		FNowDrawable := FArClasses[Index].FDrawable;
		FComboBox.Caption := FArClasses[Index].FClass.ClassName();
		end;
end;

procedure TSGDrawClasses_ComboBoxProcedure(a, b :LongInt;VComboBox:TSGComboBox);
begin
if a <> b then
	TSGDrawClasses(VComboBox.FUserPointer1).SwitchTo(b);
end;

procedure TSGDrawClasses.Initialize();overload;
begin
Initialize(SGComponentLocationImport(5, 5, 300, 18));
end;
procedure TSGDrawClasses.Initialize(const L, T, W, H : TSGScreenFloat);overload;
begin
Initialize(SGComponentLocationImport(L, T, W, H));
end;

procedure TSGDrawClasses.Initialize(const Location : TSGComponentLocation);overload;
var
	i:LongWord;
begin
{$IFDEF SGMoreDebuging}
	SGLog.Sourse('Begin of  "TSGDrawClasses.Initialize" : "'+ClassName+'".');
	{$ENDIF}
FComboBox:=TSGComboBox.Create();
Screen.CreateChild(FComboBox);
FComboBox.SetBoundsFloat(Location.Position.X, Location.Position.Y, Location.Size.X, Round(Location.Size.Y));
FComboBox.SelectItem:=0;
FComboBox.FUserPointer1:=Self;
FComboBox.CallBackProcedure:=TSGComboBoxProcedure(@TSGDrawClasses_ComboBoxProcedure);
FComboBox.Visible:=True;
FComboBox.Skin := FComboBox.Skin.CreateDependentSkinWithAnotherFont(SGFontDirectory+Slash+'Tahoma.sgf');
FComboBox.Active:=Length(FArClasses)>1;
FComboBox.FDrawClass:=Self;
FComboBox.BoundsToNeedBounds();
if (FArClasses <> nil) and (Length(FArClasses) > 0) then
	for i:=0 to High(FArClasses) do
		Screen.LastChild.AsComboBox.CreateItem(SGStringToPChar(FArClasses[i].FClass.ClassName));
if (FArClasses <> nil) and (Length(FArClasses) > 0) then
	begin
	FComboBox.SelectItem := Random(Length(FArClasses));
	SwitchTo(FComboBox.SelectItem);
	end;
{$IFDEF SGMoreDebuging}
	SGLog.Sourse('End of  "TSGDrawClasses.Initialize" : "'+ClassName+'".');
	{$ENDIF}
end;

class function TSGDrawClasses.ClassName():string;
begin
Result := 'SaGe Draw Classes';
end;

procedure TSGDrawClasses.Paint();
begin
{$IFDEF SGMoreDebuging}
	SGLog.Sourse('Begin of  "TSGDrawClasses.Draw" : "'+ClassName+'".');
	{$ENDIF}
if FNowDraw = nil then
	begin
	Initialize();
	end;
if FNowDrawable then
	FNowDraw.Paint();
{$IFDEF SGMoreDebuging}
	SGLog.Sourse('End of  "TSGDrawClasses.Draw" : "'+ClassName+'".');
	{$ENDIF}
end;

procedure TSGDrawClasses.Add(const NewClasses:TSGDrawClassesObjectList);overload;
var
	i : TSGUInt32;
begin
if NewClasses <> nil then 
	if Length(NewClasses) > 0 then
		for i := 0 to High(NewClasses) do
			Add(NewClasses[i].FClass, NewClasses[i].FDrawable);
end;

procedure TSGDrawClasses.Add(const NewClass:TSGDrawableClass; const Drawable : TSGBoolean = True);overload;
begin
SetLength(FArClasses, Length(FArClasses) + 1);
FArClasses[High(FArClasses)].FClass    := NewClass;
FArClasses[High(FArClasses)].FDrawable := Drawable;
if FComboBox <> nil then
	FComboBox.Active:=Length(FArClasses) > 1;
end;

constructor TSGDrawClasses.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FNowDraw   := nil;
FArClasses := nil;
FComboBox := nil;
end;

destructor TSGDrawClasses.Destroy;
begin
if FNowDraw <> nil then
	begin
	FNowDraw.Destroy();
	FNowDraw := nil;
	end;
if FComboBox <> nil then
	begin
	FComboBox.FDrawClass := nil;
	FComboBox.MarkForDestroy();
	FComboBox := nil;
	end;
if FArClasses <> nil then
	begin
	SetLength(FArClasses, 0);
	FArClasses := nil;
	end;
inherited;
end;


end.
