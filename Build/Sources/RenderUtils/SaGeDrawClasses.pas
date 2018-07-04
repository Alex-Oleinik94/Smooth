{$INCLUDE SaGe.inc}

//{$DEFINE SGMoreDebuging}

unit SaGeDrawClasses;

interface

uses
	 SaGeCommon
	,SaGeMesh
	,SaGeFont
	,SaGeBase
	,SaGeScreen
	,SaGeScreenHelper
	,SaGeRender
	,SaGeImage
	,SaGeCommonClasses
	,SaGeRenderBase
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
		FComboBox : TSGScreenComboBox;
		FFont : TSGFont;
			public
		procedure Paint();override;
		procedure Add(const NewClasses:TSGDrawClassesObjectList);overload;
		procedure Add(const NewClass:TSGDrawableClass; const Drawable : TSGBoolean = True);overload;
		procedure Initialize();overload;
		procedure Initialize(const Location : TSGComponentLocation);overload;
		procedure Initialize(const L, T, W, H : TSGScreenFloat);overload;
		procedure SwitchTo(const Index : TSGLongWord);
			public
		property ComboBox : TSGScreenComboBox read FComboBox;
		end;

implementation

uses
	 SaGeStringUtils
	,SaGeFileUtils
	,SaGeLog
	;

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
		SGLog.Source('TSGDrawClasses(' + SGAddrStr(Self) + ')__SwitchTo --> "' + FArClasses[Index].FClass.ClassName() + '".');
		FNowDraw     := FArClasses[Index].FClass.Create(Context);
		FNowDrawable := FArClasses[Index].FDrawable;
		FComboBox.Caption := FArClasses[Index].FClass.ClassName();
		end;
end;

procedure TSGDrawClasses_ComboBoxProcedure(a, b :LongInt;VComboBox:TSGScreenComboBox);
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
Initialize(SGComponentLocationImport(Round(L), Round(T), Round(W), Round(H)));
end;

procedure TSGDrawClasses.Initialize(const Location : TSGComponentLocation);overload;
var
	i:LongWord;
begin
{$IFDEF SGMoreDebuging}
	TSGLog.Source('Begin of  "TSGDrawClasses.Initialize" : "'+ClassName+'".');
	{$ENDIF}

FComboBox := SGCreateComboBox(Screen, Location.Left, Location.Top, Location.Width, Location.Height, TSGScreenComboBoxProcedure(@TSGDrawClasses_ComboBoxProcedure), FFont, True, True, Self);
FComboBox.SelectItem := 0;
FComboBox.Active := Length(FArClasses) > 1;
FComboBox.FDrawClass := Self;
if (FArClasses <> nil) and (Length(FArClasses) > 0) then
	for i:=0 to High(FArClasses) do
		FComboBox.CreateItem(SGStringToPChar(FArClasses[i].FClass.ClassName));
if (FArClasses <> nil) and (Length(FArClasses) > 0) then
	begin
	FComboBox.SelectItem := Random(Length(FArClasses));
	SwitchTo(FComboBox.SelectItem);
	end;
{$IFDEF SGMoreDebuging}
	TSGLog.Source('End of  "TSGDrawClasses.Initialize" : "'+ClassName+'".');
	{$ENDIF}
end;

class function TSGDrawClasses.ClassName():string;
begin
Result := 'SaGe Draw Classes';
end;

procedure TSGDrawClasses.Paint();
begin
{$IFDEF SGMoreDebuging}
	TSGLog.Source('Begin of  "TSGDrawClasses.Draw" : "'+ClassName+'".');
	{$ENDIF}
if FNowDraw = nil then
	Initialize();
if FNowDrawable and (FNowDraw <> nil) then
	FNowDraw.Paint();
{$IFDEF SGMoreDebuging}
	TSGLog.Source('End of  "TSGDrawClasses.Draw" : "'+ClassName+'".');
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

FFont := TSGFont.Create();
FFont.Context := Context;
FFont.FileName := SGFontDirectory + DirectorySeparator + 'Tahoma.sgf';
FFont.Loading();
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
SGKill(FFont);
inherited;
end;


end.
