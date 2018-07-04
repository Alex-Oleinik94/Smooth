{$INCLUDE SaGe.inc}

unit SaGeScreenHelper;

interface

uses
	 SaGeBase
	,SaGeScreenBase
	,SaGeScreen
	,SaGeScreenSkin
	,SaGeFont
	
	// Screen components
	,SaGeScreenComponent
	,SaGeScreenCommonComponents
	,SaGeScreen_Panel
	,SaGeScreen_Label
	,SaGeScreen_Edit
	,SaGeScreen_Picture
	,SaGeScreen_RadioButton
	,SaGeScreen_Button
	,SaGeScreen_ComboBox
	,SaGeScreen_ProgressBar
	,SaGeScreen_Form
	;

// Base const & types
const
	SGDefaultAnchors = [];
// Edit const & types
const
	SGScreenEditTypeNumber  = SGEditTypeNumber;
	SGScreenEditTypeInteger = SGEditTypeInteger;
	SGScreenEditTypePath    = SGEditTypePath;
	SGScreenEditTypeFloat   = SGEditTypeFloat;
type
	TSGScreenEditTextTypeFunction = TSGEditTextTypeFunction;
	TSGScreenEditTextTypeFunc = TSGScreenEditTextTypeFunction;
// Component types
type
	TSGScreenComponentProcedure = TSGComponentProcedure;
	TSGScreenComboBoxProcedure = TSGComboBoxProcedure;
// Components types
type
	TSGScreenComponent   = TSGComponent;
	TSGScreenRadioButton = TSGRadioButton;
	TSGScreenLabel       = TSGLabel;
	TSGScreenPicture     = TSGPicture;
	TSGScreenPanel       = TSGPanel;
	TSGScreenEdit        = TSGEdit;
	TSGScreenComboBox    = TSGComboBox;
	TSGScreenButton      = TSGButton;
	TSGScreenForm        = TSGForm;
	TSGScreenProgressBar = TSGProgressBar;

// Button
function SGCreateButton(const Parent : TSGComponent; const Caption : TSGString; const CallBack : TSGScreenComponentProcedure; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenButton; overload;
function SGCreateButton(const Parent : TSGComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenButton; overload;

// ComboBox
function SGCreateComboBox(const Parent : TSGComponent; const X,Y,W,H : TSGScreenInt; const CallBack : TSGScreenComboBoxProcedure; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
function SGCreateComboBox(const Parent : TSGComponent; const X,Y,W,H : TSGScreenInt; const CallBack : TSGScreenComboBoxProcedure; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
function SGCreateComboBox(const Parent : TSGComponent; const CallBack : TSGScreenComboBoxProcedure; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
function SGCreateComboBox(const Parent : TSGComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;

// Picture
function SGCreatePicture(const Parent : TSGComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPicture; overload;
function SGCreatePicture(const Parent : TSGComponent; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPicture; overload;

// Edit
function SGCreateEdit(const Parent : TSGComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
function SGCreateEdit(const Parent : TSGComponent; const EditText : TSGString; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
function SGCreateEdit(const Parent : TSGComponent; const EditText : TSGString; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
function SGCreateEdit(const Parent : TSGComponent; const EditText : TSGString; const TextTypeFunc : TSGEditTextTypeFunction; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
function SGCreateEdit(const Parent : TSGComponent; const EditText : TSGString; const TextTypeFunc : TSGEditTextTypeFunction; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
function SGCreateEdit(const Parent : TSGComponent; const EditText : TSGString; const TextType : TSGEditTextType; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;

// Panel
function SGCreatePanel(const Parent : TSGComponent; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
function SGCreatePanel(const Parent : TSGComponent; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
function SGCreatePanel(const Parent : TSGComponent; const W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
function SGCreatePanel(const Parent : TSGComponent; const W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
function SGCreatePanel(const Parent : TSGComponent; const ViewLines, ViewQuad : TSGBoolean; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
function SGCreatePanel(const Parent : TSGComponent; const ViewLines, ViewQuad : TSGBoolean; const W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
function SGCreatePanel(const Parent : TSGComponent; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
function SGCreatePanel(const Parent : TSGComponent; const W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
function SGCreatePanel(const Parent : TSGComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;

// Label
function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const TextPositionCentered : TSGBoolean; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const TextPositionCentered : TSGBoolean; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const TextPositionCentered : TSGBoolean; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Skin : TSGScreenSkin; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;

implementation

//##########
//# Button #
//##########

function SGCreateButton(const Parent : TSGComponent; const Caption : TSGString; const CallBack : TSGScreenComponentProcedure; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenButton; overload;
begin
Result := SGCreateButton(Parent, IsVisible, InterfaceData);
Result.Caption := Caption;
Result.OnChange := CallBack;
end;

function SGCreateButton(const Parent : TSGComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenButton; overload;
begin
Result := TSGScreenButton.Create();
if Parent <> nil then
	Parent.CreateChild(Result);
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

//############
//# ComboBox #
//############

function SGCreateComboBox(const Parent : TSGComponent; const X,Y,W,H : TSGScreenInt; const CallBack : TSGScreenComboBoxProcedure; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
begin
Result := SGCreateComboBox(Parent, X, Y, W, H, CallBack, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SGCreateComboBox(const Parent : TSGComponent; const X,Y,W,H : TSGScreenInt; const CallBack : TSGScreenComboBoxProcedure; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
begin
Result := SGCreateComboBox(Parent, CallBack, IsVisible, InterfaceData);
Result.SetBounds(X, Y, W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SGCreateComboBox(const Parent : TSGComponent; const CallBack : TSGScreenComboBoxProcedure; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
begin
Result := SGCreateComboBox(Parent, IsVisible, InterfaceData);
Result.CallBackProcedure := CallBack;
end;

function SGCreateComboBox(const Parent : TSGComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
begin
Result := TSGScreenComboBox.Create();
if Parent <> nil then
	Parent.CreateChild(Result);
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

//###########
//# Picture #
//###########

function SGCreatePicture(const Parent : TSGComponent; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPicture; overload;
begin
Result := SGCreatePicture(Parent, IsVisible, InterfaceData);
Result.SetBounds(X, Y, W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SGCreatePicture(const Parent : TSGComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPicture; overload;
begin
Result := TSGScreenPicture.Create();
if (Parent <> nil) then
	Parent.CreateChild(Result);
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

//########
//# Edit #
//########

function SGCreateEdit(const Parent : TSGComponent; const EditText : TSGString; const TextTypeFunc : TSGEditTextTypeFunction; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
begin
Result := SGCreateEdit(Parent, EditText, TextTypeFunc, X,Y,W,H, SGDefaultAnchors, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SGCreateEdit(const Parent : TSGComponent; const EditText : TSGString; const TextTypeFunc : TSGEditTextTypeFunction; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
begin
Result := SGCreateEdit(Parent, EditText, X,Y,W,H, Anchors, IsVisible, IsBoundsReal, InterfaceData);
Result.TextType := SGEditTypeUser;
Result.TextTypeFunction := TextTypeFunc;
Result.TextTypeEvent();
end;

function SGCreateEdit(const Parent : TSGComponent; const EditText : TSGString; const TextType : TSGEditTextType; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
begin
Result := SGCreateEdit(Parent, EditText, X,Y,W,H, Anchors, IsVisible, IsBoundsReal, InterfaceData);
Result.TextType := TextType;
if (TextType <> SGEditTypeUser) then
	Result.TextTypeEvent();
end;

function SGCreateEdit(const Parent : TSGComponent; const EditText : TSGString; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
begin
Result := SGCreateEdit(Parent, EditText, X,Y,W,H, IsVisible, IsBoundsReal, InterfaceData);
if Anchors <> [] then
	Result.Anchors := Anchors;
end;

function SGCreateEdit(const Parent : TSGComponent; const EditText : TSGString; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
begin
Result := SGCreateEdit(Parent, IsVisible, InterfaceData);
Result.Caption := EditText;
Result.SetBounds(X,Y,W,H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SGCreateEdit(const Parent : TSGComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
begin
Result := TSGScreenEdit.Create();
if (Parent <> nil) then
	Parent.CreateChild(Result);
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

//#########
//# Label #
//#########

function SGCreatePanel(const Parent : TSGComponent; const ViewLines, ViewQuad : TSGBoolean; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := SGCreatePanel(Parent, X, Y, W, H, IsVisible, IsBoundsReal, InterfaceData);
Result.ViewLines := ViewLines;
Result.ViewQuad := ViewQuad;
end;

function SGCreatePanel(const Parent : TSGComponent; const ViewLines, ViewQuad : TSGBoolean; const W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := SGCreatePanel(Parent, W, H, IsVisible, IsBoundsReal, InterfaceData);
Result.ViewLines := ViewLines;
Result.ViewQuad := ViewQuad;
end;

function SGCreatePanel(const Parent : TSGComponent; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := SGCreatePanel(Parent, X, Y, W, H, IsVisible, IsBoundsReal, InterfaceData);
if Anchors <> [] then
	Result.Anchors := Anchors;
end;

function SGCreatePanel(const Parent : TSGComponent; const W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := SGCreatePanel(Parent, W, H, IsVisible, IsBoundsReal, InterfaceData);
if Anchors <> [] then
	Result.Anchors := Anchors;
end;

function SGCreatePanel(const Parent : TSGComponent; const W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := SGCreatePanel(Parent, W, H, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SGCreatePanel(const Parent : TSGComponent; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := SGCreatePanel(Parent, X, Y, W, H, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SGCreatePanel(const Parent : TSGComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := TSGScreenPanel.Create();
if Parent <> nil then
	Parent.CreateChild(Result);
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

function SGCreatePanel(const Parent : TSGComponent; const W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := SGCreatePanel(Parent, IsVisible, InterfaceData);
Result.SetMiddleBounds(W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SGCreatePanel(const Parent : TSGComponent; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := SGCreatePanel(Parent, IsVisible, InterfaceData);
Result.SetBounds(X, Y, W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

//#########
//# Label #
//#########

function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const TextPositionCentered : TSGBoolean; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, Font, SGDefaultAnchors, IsVisible, IsBoundsReal, InterfaceData);
Result.TextPosition := TextPositionCentered;
end;

function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, Font, SGDefaultAnchors, IsVisible, IsBoundsReal, InterfaceData);
end;

function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, Anchors, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Skin : TSGScreenSkin; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, Anchors, IsVisible, IsBoundsReal, InterfaceData);
if (Skin <> nil) then
	Result.Skin := Skin;
end;

function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const TextPositionCentered : TSGBoolean; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, IsVisible, IsBoundsReal, InterfaceData);
Result.TextPosition := TextPositionCentered;
end;

function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const TextPositionCentered : TSGBoolean; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, Anchors, IsVisible, IsBoundsReal, InterfaceData);
Result.TextPosition := TextPositionCentered;
end;

function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, IsVisible, IsBoundsReal, InterfaceData);
if Anchors <> [] then
	Result.Anchors := Anchors;
end;

function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, IsVisible, InterfaceData);
Result.SetBounds(X, Y, W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := TSGScreenLabel.Create();
if Parent <> nil then
	Parent.CreateChild(Result);
Result.Caption := LabelCaption;
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

end.
