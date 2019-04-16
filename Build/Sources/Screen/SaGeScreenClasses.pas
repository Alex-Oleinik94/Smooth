{$INCLUDE SaGe.inc}

unit SaGeScreenClasses;

interface

uses
	 SaGeBase
	,SaGeScreenBase
	,SaGeScreen
	,SaGeScreenSkin
	,SaGeFont
	
	// Screen components
	,SaGeScreenComponent
	,SaGeScreenCustomComponent
	,SaGeScreenComponentInterfaces
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
	TSGScreenComponentProcedure = TSGScreenCustomComponentProcedure;
	TSGScreenComboBoxProcedure = TSGComboBoxProcedure;
	PSGScreenProgressBarFloat = PSGProgressBarFloat;
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
function SGCreateButton(const Parent : TSGScreenCustomComponent; const Caption : TSGString; const X,Y,W,H : TSGScreenInt; const CallBack : TSGScreenComponentProcedure; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenButton; overload;
function SGCreateButton(const Parent : TSGScreenCustomComponent; const Caption : TSGString; const X,Y,W,H : TSGScreenInt; const CallBack : TSGScreenComponentProcedure; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenButton; overload;
function SGCreateButton(const Parent : TSGScreenCustomComponent; const Caption : TSGString; const CallBack : TSGScreenComponentProcedure; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenButton; overload;
function SGCreateButton(const Parent : TSGScreenCustomComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenButton; overload;
procedure SGKill(var _Button : TSGScreenButton); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

// ComboBox
function SGCreateComboBox(const Parent : TSGScreenCustomComponent; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
function SGCreateComboBox(const Parent : TSGScreenCustomComponent; const X,Y,W,H : TSGScreenInt; const CallBack : TSGScreenComboBoxProcedure; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
function SGCreateComboBox(const Parent : TSGScreenCustomComponent; const X,Y,W,H : TSGScreenInt; const CallBack : TSGScreenComboBoxProcedure; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
function SGCreateComboBox(const Parent : TSGScreenCustomComponent; const CallBack : TSGScreenComboBoxProcedure; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
function SGCreateComboBox(const Parent : TSGScreenCustomComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
procedure SGKill(var _ComboBox : TSGScreenComboBox); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

// Picture
function SGCreatePicture(const Parent : TSGScreenCustomComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPicture; overload;
function SGCreatePicture(const Parent : TSGScreenCustomComponent; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPicture; overload;
procedure SGKill(var _Picture : TSGScreenPicture); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

// Edit
function SGCreateEdit(const Parent : TSGScreenCustomComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
function SGCreateEdit(const Parent : TSGScreenCustomComponent; const EditText : TSGString; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
function SGCreateEdit(const Parent : TSGScreenCustomComponent; const EditText : TSGString; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
function SGCreateEdit(const Parent : TSGScreenCustomComponent; const EditText : TSGString; const TextTypeFunc : TSGScreenEditTextTypeFunction; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
function SGCreateEdit(const Parent : TSGScreenCustomComponent; const EditText : TSGString; const TextTypeFunc : TSGScreenEditTextTypeFunction; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
function SGCreateEdit(const Parent : TSGScreenCustomComponent; const EditText : TSGString; const TextType : TSGEditTextType; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
procedure SGKill(var _Edit : TSGScreenEdit); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

// Panel
function SGCreatePanel(const Parent : TSGScreenCustomComponent; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
function SGCreatePanel(const Parent : TSGScreenCustomComponent; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
function SGCreatePanel(const Parent : TSGScreenCustomComponent; const W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
function SGCreatePanel(const Parent : TSGScreenCustomComponent; const W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
function SGCreatePanel(const Parent : TSGScreenCustomComponent; const ViewLines, ViewQuad : TSGBoolean; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
function SGCreatePanel(const Parent : TSGScreenCustomComponent; const ViewLines, ViewQuad : TSGBoolean; const W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
function SGCreatePanel(const Parent : TSGScreenCustomComponent; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
function SGCreatePanel(const Parent : TSGScreenCustomComponent; const W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
function SGCreatePanel(const Parent : TSGScreenCustomComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
procedure SGKill(var _Panel : TSGScreenPanel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

// Label
function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const TextPositionCentered : TSGBoolean; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const TextPositionCentered : TSGBoolean; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const TextPositionCentered : TSGBoolean; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Skin : TSGScreenSkin; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
procedure SGKill(var _Label : TSGScreenLabel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

//##########
//# Button #
//##########

function SGCreateButton(const Parent : TSGScreenCustomComponent; const Caption : TSGString; const X,Y,W,H : TSGScreenInt; const CallBack : TSGScreenComponentProcedure; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenButton; overload;
begin
Result := SGCreateButton(Parent, Caption, X,Y,W,H, CallBack, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SGCreateButton(const Parent : TSGScreenCustomComponent; const Caption : TSGString; const X,Y,W,H : TSGScreenInt; const CallBack : TSGScreenComponentProcedure; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenButton; overload;
begin
Result := SGCreateButton(Parent, Caption, CallBack, IsVisible, InterfaceData);
Result.SetBounds(X, Y, W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SGCreateButton(const Parent : TSGScreenCustomComponent; const Caption : TSGString; const CallBack : TSGScreenComponentProcedure; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenButton; overload;
begin
Result := SGCreateButton(Parent, IsVisible, InterfaceData);
Result.Caption := Caption;
Result.OnChange := CallBack;
end;

function SGCreateButton(const Parent : TSGScreenCustomComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenButton; overload;
begin
Result := TSGScreenButton.Create();
if Parent <> nil then
	Parent.CreateChild(Result);
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

procedure SGKill(var _Button : TSGScreenButton); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if _Button <> nil then
	begin
	_Button.Destroy();
	_Button := nil;
	end;
end;

//############
//# ComboBox #
//############

function SGCreateComboBox(const Parent : TSGScreenCustomComponent; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
begin
Result := SGCreateComboBox(Parent, X, Y, W, H, nil, Font, IsVisible, IsBoundsReal, InterfaceData);
end;

function SGCreateComboBox(const Parent : TSGScreenCustomComponent; const X,Y,W,H : TSGScreenInt; const CallBack : TSGScreenComboBoxProcedure; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
begin
Result := SGCreateComboBox(Parent, X, Y, W, H, CallBack, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SGCreateComboBox(const Parent : TSGScreenCustomComponent; const X,Y,W,H : TSGScreenInt; const CallBack : TSGScreenComboBoxProcedure; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
begin
Result := SGCreateComboBox(Parent, CallBack, IsVisible, InterfaceData);
Result.SetBounds(X, Y, W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SGCreateComboBox(const Parent : TSGScreenCustomComponent; const CallBack : TSGScreenComboBoxProcedure; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
begin
Result := SGCreateComboBox(Parent, IsVisible, InterfaceData);
Result.CallBackProcedure := CallBack;
end;

function SGCreateComboBox(const Parent : TSGScreenCustomComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenComboBox; overload;
begin
Result := TSGScreenComboBox.Create();
if Parent <> nil then
	Parent.CreateChild(Result);
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

procedure SGKill(var _ComboBox : TSGScreenComboBox); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if _ComboBox <> nil then
	begin
	_ComboBox.Destroy();
	_ComboBox := nil;
	end;
end;

//###########
//# Picture #
//###########

function SGCreatePicture(const Parent : TSGScreenCustomComponent; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPicture; overload;
begin
Result := SGCreatePicture(Parent, IsVisible, InterfaceData);
Result.SetBounds(X, Y, W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SGCreatePicture(const Parent : TSGScreenCustomComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPicture; overload;
begin
Result := TSGScreenPicture.Create();
if (Parent <> nil) then
	Parent.CreateChild(Result);
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

procedure SGKill(var _Picture : TSGScreenPicture); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if _Picture <> nil then
	begin
	_Picture.Destroy();
	_Picture := nil;
	end;
end;

//########
//# Edit #
//########

function SGCreateEdit(const Parent : TSGScreenCustomComponent; const EditText : TSGString; const TextTypeFunc : TSGScreenEditTextTypeFunction; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
begin
Result := SGCreateEdit(Parent, EditText, TextTypeFunc, X,Y,W,H, SGDefaultAnchors, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SGCreateEdit(const Parent : TSGScreenCustomComponent; const EditText : TSGString; const TextTypeFunc : TSGScreenEditTextTypeFunction; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
begin
Result := SGCreateEdit(Parent, EditText, X,Y,W,H, Anchors, IsVisible, IsBoundsReal, InterfaceData);
Result.TextType := SGEditTypeUser;
Result.TextTypeFunction := TextTypeFunc;
Result.TextTypeEvent();
end;

function SGCreateEdit(const Parent : TSGScreenCustomComponent; const EditText : TSGString; const TextType : TSGEditTextType; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
begin
Result := SGCreateEdit(Parent, EditText, X,Y,W,H, Anchors, IsVisible, IsBoundsReal, InterfaceData);
Result.TextType := TextType;
if (TextType <> SGEditTypeUser) then
	Result.TextTypeEvent();
end;

function SGCreateEdit(const Parent : TSGScreenCustomComponent; const EditText : TSGString; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
begin
Result := SGCreateEdit(Parent, EditText, X,Y,W,H, IsVisible, IsBoundsReal, InterfaceData);
if Anchors <> [] then
	Result.Anchors := Anchors;
end;

function SGCreateEdit(const Parent : TSGScreenCustomComponent; const EditText : TSGString; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
begin
Result := SGCreateEdit(Parent, IsVisible, InterfaceData);
Result.Caption := EditText;
Result.SetBounds(X,Y,W,H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SGCreateEdit(const Parent : TSGScreenCustomComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenEdit; overload;
begin
Result := TSGScreenEdit.Create();
if (Parent <> nil) then
	Parent.CreateChild(Result);
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

procedure SGKill(var _Edit : TSGScreenEdit); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if _Edit <> nil then
	begin
	_Edit.Destroy();
	_Edit := nil;
	end;
end;

//#########
//# Panel #
//#########

function SGCreatePanel(const Parent : TSGScreenCustomComponent; const ViewLines, ViewQuad : TSGBoolean; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := SGCreatePanel(Parent, X, Y, W, H, IsVisible, IsBoundsReal, InterfaceData);
Result.ViewLines := ViewLines;
Result.ViewQuad := ViewQuad;
end;

function SGCreatePanel(const Parent : TSGScreenCustomComponent; const ViewLines, ViewQuad : TSGBoolean; const W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := SGCreatePanel(Parent, W, H, IsVisible, IsBoundsReal, InterfaceData);
Result.ViewLines := ViewLines;
Result.ViewQuad := ViewQuad;
end;

function SGCreatePanel(const Parent : TSGScreenCustomComponent; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := SGCreatePanel(Parent, X, Y, W, H, IsVisible, IsBoundsReal, InterfaceData);
if Anchors <> [] then
	Result.Anchors := Anchors;
end;

function SGCreatePanel(const Parent : TSGScreenCustomComponent; const W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := SGCreatePanel(Parent, W, H, IsVisible, IsBoundsReal, InterfaceData);
if Anchors <> [] then
	Result.Anchors := Anchors;
end;

function SGCreatePanel(const Parent : TSGScreenCustomComponent; const W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := SGCreatePanel(Parent, W, H, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SGCreatePanel(const Parent : TSGScreenCustomComponent; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := SGCreatePanel(Parent, X, Y, W, H, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SGCreatePanel(const Parent : TSGScreenCustomComponent; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := TSGScreenPanel.Create();
if Parent <> nil then
	Parent.CreateChild(Result);
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

function SGCreatePanel(const Parent : TSGScreenCustomComponent; const W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := SGCreatePanel(Parent, IsVisible, InterfaceData);
Result.SetMiddleBounds(W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SGCreatePanel(const Parent : TSGScreenCustomComponent; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenPanel; overload;
begin
Result := SGCreatePanel(Parent, IsVisible, InterfaceData);
Result.SetBounds(X, Y, W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

procedure SGKill(var _Panel : TSGScreenPanel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if _Panel <> nil then
	begin
	_Panel.Destroy();
	_Panel := nil;
	end;
end;

//#########
//# Label #
//#########

function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const TextPositionCentered : TSGBoolean; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, Font, SGDefaultAnchors, IsVisible, IsBoundsReal, InterfaceData);
Result.TextPosition := TextPositionCentered;
end;

function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, Font, SGDefaultAnchors, IsVisible, IsBoundsReal, InterfaceData);
end;

function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, Anchors, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Skin : TSGScreenSkin; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, Anchors, IsVisible, IsBoundsReal, InterfaceData);
if (Skin <> nil) then
	Result.Skin := Skin;
end;

function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const TextPositionCentered : TSGBoolean; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, IsVisible, IsBoundsReal, InterfaceData);
Result.TextPosition := TextPositionCentered;
end;

function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const TextPositionCentered : TSGBoolean; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, Anchors, IsVisible, IsBoundsReal, InterfaceData);
Result.TextPosition := TextPositionCentered;
end;

function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, IsVisible, IsBoundsReal, InterfaceData);
if Anchors <> [] then
	Result.Anchors := Anchors;
end;

function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const IsBoundsReal : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, IsVisible, InterfaceData);
Result.SetBounds(X, Y, W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SGCreateLabel(const Parent : TSGScreenCustomComponent; const LabelCaption : TSGString; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGScreenLabel; overload;
begin
Result := TSGScreenLabel.Create();
if Parent <> nil then
	Parent.CreateChild(Result);
Result.Caption := LabelCaption;
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

procedure SGKill(var _Label : TSGScreenLabel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if _Label <> nil then
	begin
	_Label.Destroy();
	_Label := nil;
	end;
end;

end.
