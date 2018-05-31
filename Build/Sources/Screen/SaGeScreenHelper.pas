{$INCLUDE SaGe.inc}

unit SaGeScreenHelper;

interface

uses
	 SaGeBase
	,SaGeScreenBase
	,SaGeScreen
	,SaGeScreenSkin
	,SaGeFont
	;

// Label
function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGLabel; overload;
function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const BTNB : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGLabel; overload;
function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const BTNB : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGLabel; overload;
function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const TextPositionCentered : TSGBoolean; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const BTNB : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGLabel; overload;
function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const TextPositionCentered : TSGBoolean; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const BTNB : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGLabel; overload;
function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Skin : TSGScreenSkin; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const BTNB : TSGBoolean = False) : TSGLabel; overload;
function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const BTNB : TSGBoolean = False) : TSGLabel; overload;

implementation

//#########
//# Label #
//#########

function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Font : TSGFont; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const BTNB : TSGBoolean = False) : TSGLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, Anchors, IsVisible, BTNB);
if Font <> nil then
	Result.Skin := Result.Skin.CreateDependentSkinWithAnotherFont(Font);
end;

function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Skin : TSGScreenSkin; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const BTNB : TSGBoolean = False) : TSGLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, Anchors, IsVisible, BTNB);
if Skin <> nil then
	Result.Skin := Skin;
end;

function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const TextPositionCentered : TSGBoolean; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const BTNB : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, IsVisible, BTNB, InterfaceData);
Result.TextPosition := TextPositionCentered;
end;

function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const TextPositionCentered : TSGBoolean; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const BTNB : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, Anchors, IsVisible, BTNB, InterfaceData);
Result.TextPosition := TextPositionCentered;
end;

function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const Anchors : TSGAnchors; const IsVisible : TSGBoolean = True; const BTNB : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, X,Y,W,H, IsVisible, BTNB, InterfaceData);
if Anchors <> [] then
	Result.Anchors := Anchors;
end;

function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const X,Y,W,H : TSGScreenInt; const IsVisible : TSGBoolean = True; const BTNB : TSGBoolean = False; const InterfaceData : TSGScreenInterfaceData = nil) : TSGLabel; overload;
begin
Result := SGCreateLabel(Parent, LabelCaption, IsVisible, InterfaceData);
Result.SetBounds(X, Y, W, H);
if BTNB then
	Result.BoundsToNeedBounds();
end;

function SGCreateLabel(const Parent : TSGComponent; const LabelCaption : TSGString; const IsVisible : TSGBoolean = True; const InterfaceData : TSGScreenInterfaceData = nil) : TSGLabel; overload;
begin
Result := TSGLabel.Create();
if Parent <> nil then
	Parent.CreateChild(Result);
Result.Caption := LabelCaption;
Result.Visible := IsVisible;
Result.UserPointer := InterfaceData;
end;

end.