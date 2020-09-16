{$INCLUDE Smooth.inc}

unit SmoothScreenClasses;

interface

uses
	 SmoothBase
	,SmoothScreenBase
	,SmoothScreen
	,SmoothScreenSkin
	,SmoothFont
	
	// Screen components
	,SmoothScreenComponent
	,SmoothScreenCustomComponent
	,SmoothScreenComponentInterfaces
	,SmoothScreenCommonComponents
	,SmoothScreen_Panel
	,SmoothScreen_Label
	,SmoothScreen_Edit
	,SmoothScreen_Picture
	,SmoothScreen_RadioButton
	,SmoothScreen_Button
	,SmoothScreen_ComboBox
	,SmoothScreen_ProgressBar
	,SmoothScreen_Form
	;

// Base const & types
const
	SDefaultAnchors = [];
// Edit const & types
const
	SScreenEditTypeNumber  = SEditTypeNumber;
	SScreenEditTypeInteger = SEditTypeInteger;
	SScreenEditTypePath    = SEditTypePath;
	SScreenEditTypeFloat   = SEditTypeFloat;
type
	TSScreenEditTextTypeFunction = TSEditTextTypeFunction;
	TSScreenEditTextTypeFunc = TSScreenEditTextTypeFunction;
// Component types
type
	TSScreenComponentProcedure = TSScreenCustomComponentProcedure;
	TSScreenButtonProcedure = TSScreenCustomComponentProcedure;
	TSScreenComboBoxProcedure = TSComboBoxProcedure;
	PSScreenProgressBarFloat = PSProgressBarFloat;

// Components types
type
	TSScreenComponent   = TSComponent;
	TSScreenRadioButton = TSRadioButton;
	TSScreenLabel       = TSLabel;
	TSScreenPicture     = TSPicture;
	TSScreenPanel       = TSPanel;
	TSScreenEdit        = TSEdit;
	TSScreenComboBox    = TSComboBox;
	TSScreenButton      = TSButton;
	TSScreenForm        = TSForm;
	TSScreenProgressBar = TSProgressBar;

{$DEFINE  INC_PLACE_INTERFACE}
{$DEFINE DATATYPE_LIST_HELPER := TSScreenLabelListHelper}
{$DEFINE DATATYPE_LIST        := TSScreenLabelList}
{$DEFINE DATATYPE             := TSScreenLabel}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF   INC_PLACE_INTERFACE}

// Button
function SCreateButton(const Parent : TSScreenCustomComponent; const Caption : TSString; const X,Y,W,H : TSScreenInt; const CallBack : TSScreenComponentProcedure; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenButton; overload;
function SCreateButton(const Parent : TSScreenCustomComponent; const Caption : TSString; const X,Y,W,H : TSScreenInt; const CallBack : TSScreenComponentProcedure; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenButton; overload;
function SCreateButton(const Parent : TSScreenCustomComponent; const Caption : TSString; const X,Y,W,H : TSScreenInt; const CallBack : TSScreenComponentProcedure; const Font : TSFont; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenButton; overload;
function SCreateButton(const Parent : TSScreenCustomComponent; const Caption : TSString; const CallBack : TSScreenComponentProcedure; const IsVisible : TSBoolean = True; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenButton; overload;
function SCreateButton(const Parent : TSScreenCustomComponent; const IsVisible : TSBoolean = True; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenButton; overload;
procedure SKill(var _Button : TSScreenButton); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

// ComboBox
function SCreateComboBox(const Parent : TSScreenCustomComponent; const X,Y,W,H : TSScreenInt; const CallBack : TSScreenComboBoxProcedure; const Font : TSFont; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenComboBox; overload;
function SCreateComboBox(const Parent : TSScreenCustomComponent; const X,Y,W,H : TSScreenInt; const CallBack : TSScreenComboBoxProcedure; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenComboBox; overload;
function SCreateComboBox(const Parent : TSScreenCustomComponent; const X,Y,W,H : TSScreenInt; const Anchors : TSAnchors; const CallBack : TSScreenComboBoxProcedure; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenComboBox; overload;
function SCreateComboBox(const Parent : TSScreenCustomComponent; const CallBack : TSScreenComboBoxProcedure; const IsVisible : TSBoolean = True; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenComboBox; overload;
function SCreateComboBox(const Parent : TSScreenCustomComponent; const IsVisible : TSBoolean = True; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenComboBox; overload;
procedure SKill(var _ComboBox : TSScreenComboBox); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

// Picture
function SCreatePicture(const Parent : TSScreenCustomComponent; const IsVisible : TSBoolean = True; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPicture; overload;
function SCreatePicture(const Parent : TSScreenCustomComponent; const X,Y,W,H : TSScreenInt; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPicture; overload;
procedure SKill(var _Picture : TSScreenPicture); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

// Edit
function SCreateEdit(const Parent : TSScreenCustomComponent; const IsVisible : TSBoolean = True; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenEdit; overload;
function SCreateEdit(const Parent : TSScreenCustomComponent; const EditText : TSString; const X,Y,W,H : TSScreenInt; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenEdit; overload;
function SCreateEdit(const Parent : TSScreenCustomComponent; const EditText : TSString; const X,Y,W,H : TSScreenInt; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenEdit; overload;
function SCreateEdit(const Parent : TSScreenCustomComponent; const EditText : TSString; const TextTypeFunc : TSScreenEditTextTypeFunction; const X,Y,W,H : TSScreenInt; const Font : TSFont; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenEdit; overload;
function SCreateEdit(const Parent : TSScreenCustomComponent; const EditText : TSString; const TextTypeFunc : TSScreenEditTextTypeFunction; const X,Y,W,H : TSScreenInt; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenEdit; overload;
function SCreateEdit(const Parent : TSScreenCustomComponent; const EditText : TSString; const TextType : TSEditTextType; const X,Y,W,H : TSScreenInt; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenEdit; overload;
procedure SKill(var _Edit : TSScreenEdit); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

// Panel
function SCreatePanel(const Parent : TSScreenCustomComponent; const X,Y,W,H : TSScreenInt; const Font : TSFont; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
function SCreatePanel(const Parent : TSScreenCustomComponent; const X,Y,W,H : TSScreenInt; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
function SCreatePanel(const Parent : TSScreenCustomComponent; const W,H : TSScreenInt; const Font : TSFont; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
function SCreatePanel(const Parent : TSScreenCustomComponent; const W,H : TSScreenInt; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
function SCreatePanel(const Parent : TSScreenCustomComponent; const ViewLines, ViewQuad : TSBoolean; const X,Y,W,H : TSScreenInt; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
function SCreatePanel(const Parent : TSScreenCustomComponent; const ViewLines, ViewQuad : TSBoolean; const W,H : TSScreenInt; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
function SCreatePanel(const Parent : TSScreenCustomComponent; const X,Y,W,H : TSScreenInt; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
function SCreatePanel(const Parent : TSScreenCustomComponent; const W,H : TSScreenInt; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
function SCreatePanel(const Parent : TSScreenCustomComponent; const IsVisible : TSBoolean = True; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
procedure SKill(var _Panel : TSScreenPanel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

// Label
function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const IsVisible : TSBoolean = True; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const X,Y,W,H : TSScreenInt; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const X,Y,W,H : TSScreenInt; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const TextPositionCentered : TSBoolean; const X,Y,W,H : TSScreenInt; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const TextPositionCentered : TSBoolean; const X,Y,W,H : TSScreenInt; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const TextPositionCentered : TSBoolean; const X,Y,W,H : TSScreenInt; const Font : TSFont; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const X,Y,W,H : TSScreenInt; const Skin : TSScreenSkin; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const X,Y,W,H : TSScreenInt; const Font : TSFont; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const X,Y,W,H : TSScreenInt; const Font : TSFont; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
procedure SKill(var _Label : TSScreenLabel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

// Progress bar
procedure SKill(var _ProgressBar : TSProgressBar); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

procedure SKill(var _ProgressBar : TSProgressBar); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if _ProgressBar <> nil then
	begin
	_ProgressBar.Destroy();
	_ProgressBar := nil;
	end;
end;

//##########
//# Button #
//##########

function SCreateButton(const Parent : TSScreenCustomComponent; const Caption : TSString; const X,Y,W,H : TSScreenInt; const CallBack : TSScreenComponentProcedure; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenButton; overload;
begin
Result := SCreateButton(Parent, Caption, X,Y,W,H, CallBack, IsVisible, IsBoundsReal, InterfaceData);
if Anchors <> [] then
	Result.Anchors := Anchors;
end;


function SCreateButton(const Parent : TSScreenCustomComponent; const Caption : TSString; const X,Y,W,H : TSScreenInt; const CallBack : TSScreenComponentProcedure; const Font : TSFont; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenButton; overload;
begin
Result := SCreateButton(Parent, Caption, X,Y,W,H, CallBack, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SCreateButton(const Parent : TSScreenCustomComponent; const Caption : TSString; const X,Y,W,H : TSScreenInt; const CallBack : TSScreenComponentProcedure; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenButton; overload;
begin
Result := SCreateButton(Parent, Caption, CallBack, IsVisible, InterfaceData);
Result.SetBounds(X, Y, W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SCreateButton(const Parent : TSScreenCustomComponent; const Caption : TSString; const CallBack : TSScreenComponentProcedure; const IsVisible : TSBoolean = True; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenButton; overload;
begin
Result := SCreateButton(Parent, IsVisible, InterfaceData);
Result.Caption := Caption;
Result.OnChange := CallBack;
end;

function SCreateButton(const Parent : TSScreenCustomComponent; const IsVisible : TSBoolean = True; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenButton; overload;
begin
Result := TSScreenButton.Create();
if Parent <> nil then
	Parent.CreateChild(Result);
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

procedure SKill(var _Button : TSScreenButton); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
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

function SCreateComboBox(const Parent : TSScreenCustomComponent; const X,Y,W,H : TSScreenInt; const Anchors : TSAnchors; const CallBack : TSScreenComboBoxProcedure; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenComboBox; overload;
begin
Result := SCreateComboBox(Parent, X, Y, W, H, CallBack, nil, IsVisible, IsBoundsReal, InterfaceData);
if Anchors <> [] then
	Result.Anchors := Anchors;
end;

function SCreateComboBox(const Parent : TSScreenCustomComponent; const X,Y,W,H : TSScreenInt; const CallBack : TSScreenComboBoxProcedure; const Font : TSFont; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenComboBox; overload;
begin
Result := SCreateComboBox(Parent, X, Y, W, H, CallBack, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SCreateComboBox(const Parent : TSScreenCustomComponent; const X,Y,W,H : TSScreenInt; const CallBack : TSScreenComboBoxProcedure; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenComboBox; overload;
begin
Result := SCreateComboBox(Parent, CallBack, IsVisible, InterfaceData);
Result.SetBounds(X, Y, W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SCreateComboBox(const Parent : TSScreenCustomComponent; const CallBack : TSScreenComboBoxProcedure; const IsVisible : TSBoolean = True; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenComboBox; overload;
begin
Result := SCreateComboBox(Parent, IsVisible, InterfaceData);
Result.CallBackProcedure := CallBack;
end;

function SCreateComboBox(const Parent : TSScreenCustomComponent; const IsVisible : TSBoolean = True; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenComboBox; overload;
begin
Result := TSScreenComboBox.Create();
if Parent <> nil then
	Parent.CreateChild(Result);
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

procedure SKill(var _ComboBox : TSScreenComboBox); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
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

function SCreatePicture(const Parent : TSScreenCustomComponent; const X,Y,W,H : TSScreenInt; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPicture; overload;
begin
Result := SCreatePicture(Parent, IsVisible, InterfaceData);
Result.SetBounds(X, Y, W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SCreatePicture(const Parent : TSScreenCustomComponent; const IsVisible : TSBoolean = True; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPicture; overload;
begin
Result := TSScreenPicture.Create();
if (Parent <> nil) then
	Parent.CreateChild(Result);
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

procedure SKill(var _Picture : TSScreenPicture); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
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

function SCreateEdit(const Parent : TSScreenCustomComponent; const EditText : TSString; const TextTypeFunc : TSScreenEditTextTypeFunction; const X,Y,W,H : TSScreenInt; const Font : TSFont; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenEdit; overload;
begin
Result := SCreateEdit(Parent, EditText, TextTypeFunc, X,Y,W,H, SDefaultAnchors, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SCreateEdit(const Parent : TSScreenCustomComponent; const EditText : TSString; const TextTypeFunc : TSScreenEditTextTypeFunction; const X,Y,W,H : TSScreenInt; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenEdit; overload;
begin
Result := SCreateEdit(Parent, EditText, X,Y,W,H, Anchors, IsVisible, IsBoundsReal, InterfaceData);
Result.TextType := SEditTypeUser;
Result.TextTypeFunction := TextTypeFunc;
Result.TextTypeEvent();
end;

function SCreateEdit(const Parent : TSScreenCustomComponent; const EditText : TSString; const TextType : TSEditTextType; const X,Y,W,H : TSScreenInt; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenEdit; overload;
begin
Result := SCreateEdit(Parent, EditText, X,Y,W,H, Anchors, IsVisible, IsBoundsReal, InterfaceData);
Result.TextType := TextType;
if (TextType <> SEditTypeUser) then
	Result.TextTypeEvent();
end;

function SCreateEdit(const Parent : TSScreenCustomComponent; const EditText : TSString; const X,Y,W,H : TSScreenInt; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenEdit; overload;
begin
Result := SCreateEdit(Parent, EditText, X,Y,W,H, IsVisible, IsBoundsReal, InterfaceData);
if Anchors <> [] then
	Result.Anchors := Anchors;
end;

function SCreateEdit(const Parent : TSScreenCustomComponent; const EditText : TSString; const X,Y,W,H : TSScreenInt; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenEdit; overload;
begin
Result := SCreateEdit(Parent, IsVisible, InterfaceData);
Result.Caption := EditText;
Result.SetBounds(X,Y,W,H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SCreateEdit(const Parent : TSScreenCustomComponent; const IsVisible : TSBoolean = True; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenEdit; overload;
begin
Result := TSScreenEdit.Create();
if (Parent <> nil) then
	Parent.CreateChild(Result);
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

procedure SKill(var _Edit : TSScreenEdit); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
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

function SCreatePanel(const Parent : TSScreenCustomComponent; const ViewLines, ViewQuad : TSBoolean; const X,Y,W,H : TSScreenInt; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
begin
Result := SCreatePanel(Parent, X, Y, W, H, IsVisible, IsBoundsReal, InterfaceData);
Result.ViewLines := ViewLines;
Result.ViewQuad := ViewQuad;
end;

function SCreatePanel(const Parent : TSScreenCustomComponent; const ViewLines, ViewQuad : TSBoolean; const W,H : TSScreenInt; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
begin
Result := SCreatePanel(Parent, W, H, IsVisible, IsBoundsReal, InterfaceData);
Result.ViewLines := ViewLines;
Result.ViewQuad := ViewQuad;
end;

function SCreatePanel(const Parent : TSScreenCustomComponent; const X,Y,W,H : TSScreenInt; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
begin
Result := SCreatePanel(Parent, X, Y, W, H, IsVisible, IsBoundsReal, InterfaceData);
if Anchors <> [] then
	Result.Anchors := Anchors;
end;

function SCreatePanel(const Parent : TSScreenCustomComponent; const W,H : TSScreenInt; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
begin
Result := SCreatePanel(Parent, W, H, IsVisible, IsBoundsReal, InterfaceData);
if Anchors <> [] then
	Result.Anchors := Anchors;
end;

function SCreatePanel(const Parent : TSScreenCustomComponent; const W,H : TSScreenInt; const Font : TSFont; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
begin
Result := SCreatePanel(Parent, W, H, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SCreatePanel(const Parent : TSScreenCustomComponent; const X,Y,W,H : TSScreenInt; const Font : TSFont; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
begin
Result := SCreatePanel(Parent, X, Y, W, H, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SCreatePanel(const Parent : TSScreenCustomComponent; const IsVisible : TSBoolean = True; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
begin
Result := TSScreenPanel.Create();
if Parent <> nil then
	Parent.CreateChild(Result);
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

function SCreatePanel(const Parent : TSScreenCustomComponent; const W,H : TSScreenInt; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
begin
Result := SCreatePanel(Parent, IsVisible, InterfaceData);
Result.SetMiddleBounds(W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SCreatePanel(const Parent : TSScreenCustomComponent; const X,Y,W,H : TSScreenInt; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenPanel; overload;
begin
Result := SCreatePanel(Parent, IsVisible, InterfaceData);
Result.SetBounds(X, Y, W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

procedure SKill(var _Panel : TSScreenPanel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
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

function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const TextPositionCentered : TSBoolean; const X,Y,W,H : TSScreenInt; const Font : TSFont; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
begin
Result := SCreateLabel(Parent, LabelCaption, X,Y,W,H, Font, SDefaultAnchors, IsVisible, IsBoundsReal, InterfaceData);
Result.TextPosition := TextPositionCentered;
end;

function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const X,Y,W,H : TSScreenInt; const Font : TSFont; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
begin
Result := SCreateLabel(Parent, LabelCaption, X,Y,W,H, Font, SDefaultAnchors, IsVisible, IsBoundsReal, InterfaceData);
end;

function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const X,Y,W,H : TSScreenInt; const Font : TSFont; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
begin
Result := SCreateLabel(Parent, LabelCaption, X,Y,W,H, Anchors, IsVisible, IsBoundsReal, InterfaceData);
if (Font <> nil) then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const X,Y,W,H : TSScreenInt; const Skin : TSScreenSkin; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
begin
Result := SCreateLabel(Parent, LabelCaption, X,Y,W,H, Anchors, IsVisible, IsBoundsReal, InterfaceData);
if (Skin <> nil) then
	Result.Skin := Skin;
end;

function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const TextPositionCentered : TSBoolean; const X,Y,W,H : TSScreenInt; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
begin
Result := SCreateLabel(Parent, LabelCaption, X,Y,W,H, IsVisible, IsBoundsReal, InterfaceData);
Result.TextPosition := TextPositionCentered;
end;

function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const TextPositionCentered : TSBoolean; const X,Y,W,H : TSScreenInt; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
begin
Result := SCreateLabel(Parent, LabelCaption, X,Y,W,H, Anchors, IsVisible, IsBoundsReal, InterfaceData);
Result.TextPosition := TextPositionCentered;
end;

function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const X,Y,W,H : TSScreenInt; const Anchors : TSAnchors; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
begin
Result := SCreateLabel(Parent, LabelCaption, X,Y,W,H, IsVisible, IsBoundsReal, InterfaceData);
if Anchors <> [] then
	Result.Anchors := Anchors;
end;

function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const X,Y,W,H : TSScreenInt; const IsVisible : TSBoolean = True; const IsBoundsReal : TSBoolean = False; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
begin
Result := SCreateLabel(Parent, LabelCaption, IsVisible, InterfaceData);
Result.SetBounds(X, Y, W, H);
if IsBoundsReal then
	Result.BoundsMakeReal();
end;

function SCreateLabel(const Parent : TSScreenCustomComponent; const LabelCaption : TSString; const IsVisible : TSBoolean = True; const InterfaceData : TSScreenInterfaceData = nil) : TSScreenLabel; overload;
begin
Result := TSScreenLabel.Create();
if Parent <> nil then
	Parent.CreateChild(Result);
Result.Caption := LabelCaption;
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

procedure SKill(var _Label : TSScreenLabel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if _Label <> nil then
	begin
	_Label.Destroy();
	_Label := nil;
	end;
end;

{$DEFINE  INC_PLACE_IMPLEMENTATION}
{$DEFINE DATATYPE_LIST_HELPER := TSScreenLabelListHelper}
{$DEFINE DATATYPE_LIST        := TSScreenLabelList}
{$DEFINE DATATYPE             := TSScreenLabel}
{$INCLUDE SmoothCommonList.inc}
{$INCLUDE SmoothCommonListUndef.inc}
{$UNDEF   INC_PLACE_IMPLEMENTATION}

end.
