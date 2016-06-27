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
	;

const
	SGDrawClassesComboBoxWidth = 300;
type
	TSGDrawClasses = class(TSGDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName() : TSGString;override;
		procedure DeleteDeviceResourses();override;
		procedure LoadDeviceResourses();override;
			public
		FNowDraw     : TSGDrawable;
		FNowDrawable : TSGBoolean;
		FArClasses:packed array of
			packed record 
				FClass    : TSGDrawableClass;
				FDrawable : TSGBoolean;
				end;
		FComboBox2:TSGComboBox;
			public
		procedure Paint();override;
		procedure Add(const NewClass:TSGDrawableClass; const Dravable : TSGBoolean = True);
		procedure Initialize();
		procedure SwitchTo(const Index : TSGLongWord);
			public
		property ComboBox : TSGComboBox read FComboBox2;
		end;

implementation

procedure TSGDrawClasses.DeleteDeviceResourses();
begin
if FComboBox2.Font.Texture <> 0 then
	FComboBox2.Font.DeleteDeviceResourses();
end;

procedure TSGDrawClasses.LoadDeviceResourses();
begin
if not (FComboBox2.Font.ReadyGoToTexture or (FComboBox2.Font.Texture <> 0)) then
	FComboBox2.Font.Loading();
end;

procedure TSGDrawClasses.SwitchTo(const Index : TSGLongWord);
begin
if FNowDraw <> nil then
	begin
	FNowDraw.DeleteDeviceResourses();
	FNowDraw.Destroy();
	FNowDraw := nil;
	end;
if FArClasses <> nil then
	if (Index >= 0) and (Index <= High(FArClasses)) then
		begin
		FNowDraw     := FArClasses[Index].FClass.Create(Context);
		FNowDrawable := FArClasses[Index].FDrawable;
		FComboBox2.Caption := FArClasses[Index].FClass.ClassName();
		end;
end;

procedure TSGDrawClasses_ComboBoxProcedure(a, b :LongInt;VComboBox:TSGComboBox);
begin
if a <> b then
	TSGDrawClasses(VComboBox.FUserPointer1).SwitchTo(b);
end;

procedure TSGDrawClasses.Initialize();
var
	i:LongWord;
begin
{$IFDEF SGMoreDebuging}
	SGLog.Sourse('Begin of  "TSGDrawClasses.Initialize" : "'+ClassName+'".');
	{$ENDIF}
FComboBox2:=TSGComboBox.Create();
SGScreen.CreateChild(FComboBox2);
FComboBox2.SetBounds(5,5,SGDrawClassesComboBoxWidth,18);
FComboBox2.SelectItem:=0;
FComboBox2.FUserPointer1:=Self;
FComboBox2.FProcedure:=TSGComboBoxProcedure(@TSGDrawClasses_ComboBoxProcedure);
FComboBox2.Visible:=True;
FComboBox2.Font:=TSGFont.Create(SGFontDirectory+Slash+'Tahoma.sgf');
FComboBox2.Font.SetContext(Context);
FComboBox2.Font.Loading();
FComboBox2.Active:=Length(FArClasses)>1;
FComboBox2.FDrawClass:=Self;
FComboBox2.BoundsToNeedBounds();
if (FArClasses <> nil) and (Length(FArClasses) > 0) then
	for i:=0 to High(FArClasses) do
		SGScreen.LastChild.AsComboBox.CreateItem(SGStringToPChar(FArClasses[i].FClass.ClassName));
if (FArClasses <> nil) and (Length(FArClasses) > 0) then
	begin
	FComboBox2.SelectItem := Random(Length(FArClasses));
	SwitchTo(FComboBox2.SelectItem);
	end;
{$IFDEF SGMoreDebuging}
	SGLog.Sourse('End of  "TSGDrawClasses.Initialize" : "'+ClassName+'".');
	{$ENDIF}
end;

class function TSGDrawClasses.ClassName():string;
begin
Result:='SaGe Draw Classes';
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

procedure TSGDrawClasses.Add(const NewClass:TSGDrawableClass; const Dravable : TSGBoolean = True);
begin
SetLength(FArClasses,Length(FArClasses)+1);
FArClasses[High(FArClasses)].FClass:=NewClass;
FArClasses[High(FArClasses)].FDrawable:=Dravable;
if FComboBox2 <> nil then
	FComboBox2.Active:=Length(FArClasses) > 1;
end;

constructor TSGDrawClasses.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FNowDraw   := nil;
FArClasses := nil;
FComboBox2 := nil;
end;

destructor TSGDrawClasses.Destroy;
begin
if FNowDraw <> nil then
	begin
	FNowDraw.Destroy();
	FNowDraw := nil;
	end;
if FComboBox2 <> nil then
	begin
	if FComboBox2.FDrawClass <> nil then
		FComboBox2.FDrawClass := nil;
	if FComboBox2.Font <> nil then
		begin
		FComboBox2.Font.Destroy();
		FComboBox2.Font := nil;
		end;
	FComboBox2.Destroy();
	FComboBox2 := nil;
	end;
if FArClasses <> nil then
	begin
	SetLength(FArClasses, 0);
	FArClasses := nil;
	end;
inherited;
end;


end.
