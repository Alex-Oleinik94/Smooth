{$IFDEF SCREEN_INTERFACE}
type
	TSGComponent = class;

	// for-in loop enumerator class
	TSGComponentEnumerator = class
			protected
		FComponent : TSGComponent;
		FCurrent   : TSGComponent;
		FIndex     : TSGMaxEnum;
			public
		constructor Create(const VComponent : TSGComponent); virtual;
		function MoveNext(): TSGBoolean; virtual;abstract;
		function GetEnumerator() : TSGComponentEnumerator;virtual;
		property Current: TSGComponent read FCurrent;
		end;
	TSGComponentEnumeratorNormal = class(TSGComponentEnumerator)
			public
		constructor Create(const VComponent : TSGComponent); override;
		function MoveNext(): TSGBoolean; override;
		end;
	TSGComponentEnumeratorReverse = class(TSGComponentEnumerator)
			public
		constructor Create(const VComponent : TSGComponent); override;
		function MoveNext(): TSGBoolean; override;
		end;

	PSGComponent          = ^ TSGComponent;
	TSGComponentList      = packed array of TSGComponent;
	TSGComponentListList  = packed array of TSGComponentList;
	TSGComponentProcedure = procedure ( Component : TSGComponent );
	TSGComponent          = class(TSGContextabled, ISGDeviceDependent, ISGComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
			public
			// for-in loop
		function GetEnumerator(): TSGComponentEnumerator;
		function GetReverseEnumerator: TSGComponentEnumerator;
			private
		function GetOption(const VName : TSGString) : TSGPointer;virtual;
		procedure SetOption(const VName : TSGString; const VValue : TSGPointer);virtual;
			public
			// ISGDeviceDependent declaration
		procedure Paint(); virtual;
		procedure DeleteDeviceResources();virtual;
		procedure Resize(); virtual;
		procedure LoadDeviceResources();virtual;
		function Suppored() : TSGBoolean;virtual;
			protected
			// Location
		FWidth  : TSGScreenInt;
		FHeight : TSGScreenInt;
		FLeft   : TSGScreenInt;
		FTop    : TSGScreenInt;

		FNoneTop    : TSGScreenInt;
		FNoneLeft   : TSGScreenInt;
		FNoneHeight : TSGScreenInt;
		FNoneWidth  : TSGScreenInt;

		FNeedLeft   : TSGScreenInt;
		FNeedTop    : TSGScreenInt;
		FNeedWidth  : TSGScreenInt;
		FNeedHeight : TSGScreenInt;

		FTopShiftForChilds    : TSGScreenInt;
		FLeftShiftForChilds   : TSGScreenInt;
		FRightShiftForChilds  : TSGScreenInt;
		FBottomShiftForChilds : TSGScreenInt;

		FRealLeft : TSGScreenInt;
		FRealTop  : TSGScreenInt;

		FUnLimited : TSGBoolean;
		FParent    : TSGComponent;

		procedure SetRight (NewRight  : TSGScreenInt);virtual;
		procedure SetBottom(NewBottom : TSGScreenInt);virtual;
		function GetRight()  : TSGScreenInt;virtual;
		function GetBottom() : TSGScreenInt;virtual;

		function  GetTitle() : TSGString;virtual;
		procedure SetTitle(const VTitle : TSGString);virtual;
		function  GetWidth() : TSGAreaInt;virtual;
		function  GetHeight() : TSGAreaInt;virtual;
		procedure SetWidth(const VWidth : TSGAreaInt);virtual;
		procedure SetHeight(const VHeight : TSGAreaInt);virtual;
		function  GetLeft() : TSGAreaInt;virtual;
		function  GetTop() : TSGAreaInt;virtual;
		procedure SetLeft(const VLeft : TSGAreaInt);virtual;
		procedure SetTop(const VTop : TSGAreaInt);virtual;

		function GetScreenWidth()  : TSGScreenInt;virtual;
		function GetScreenHeight() : TSGScreenInt;virtual;
		function GetLocation() : TSGComponentLocation;virtual;

		function UpDateObj(var Obj, NObj : TSGScreenInt) : TSGScreenInt;
		procedure UpDateObjects();virtual;
		procedure TestCoords();virtual;
			public
		property Width        : TSGAreaInt   read GetWidth write SetWidth;
		property Height       : TSGAreaInt   read GetHeight write SetHeight;
		property Left         : TSGAreaInt   read GetLeft write SetLeft;
		property Top          : TSGAreaInt   read GetTop write SetTop;
		property Parent       : TSGComponent read FParent write FParent;
		property Bottom       : TSGScreenInt read GetBottom write SetBottom;
		property Right        : TSGScreenInt read GetRight write SetRight;
		property ScreenWidth  : TSGScreenInt read GetScreenWidth;
		property ScreenHeight : TSGScreenInt read GetScreenHeight;
		property UnLimited    : TSGBoolean   read FUnLimited write FUnLimited;
			public
		procedure BoundsToNeedBounds();virtual;
		procedure SetShifts(const NL,NT,NR,NB:TSGScreenInt);virtual;
		procedure SetBounds(const NewLeft, NewTop, NewWidth, NewHeight : TSGScreenInt);virtual;
		procedure SetBoundsFloat(const NewLeft, NewTop, NewWidth, NewHeight : TSGScreenFloat);
		procedure SetMiddleBounds(const NewWidth, NewHeight : TSGScreenInt);virtual;
		procedure WriteBounds();
		class function RandomOne():TSGScreenInt;
		procedure AddToLeft(const Value:TSGScreenInt);
		procedure AddToWidth(const Value:TSGScreenInt);
		procedure AddToHeight(const Value:TSGScreenInt);
		procedure AddToTop(const Value:TSGScreenInt);
			protected
		FAlign:TSGByte;
		FAnchors:TSGSetOfByte;
		FAnchorsData:packed record
			FParentWidth,FParentHeight:TSGScreenInt;
			end;
		FVisible : TSGBoolean;
		FVisibleTimer : TSGScreenTimer;
		FActive : TSGBoolean;
		FActiveTimer  : TSGScreenTimer;

		FCaption : TSGCaption;
		FSkin    : TSGScreenSkin;

		procedure UpDateSkin();virtual;
		procedure UpgradeTimers();virtual;
		procedure UpgradeTimer(const  Flag:Boolean; var Timer : TSGScreenTimer; const Mnozhitel:TSGScreenInt = 1;const Mn2:single = 1);
		procedure FromDraw();virtual;
		procedure FromResize();virtual;
		procedure FromUpDate(var FCanChange:Boolean);virtual;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);virtual;
		procedure FromUpDateCaptionUnderCursor(var CanRePleace:Boolean);virtual;
			protected
		procedure SetVisible(const b:Boolean);virtual;
		procedure SetCaption(const NewCaption : TSGCaption);virtual;
			public
		function ReqursiveActive():Boolean;
		function NotVisible : TSGBoolean;virtual;
		function GetVisibleTimer() : TSGScreenTimer;virtual;
		function GetActiveTimer() : TSGScreenTimer;virtual;
		function GetActive() : TSGBoolean;
		function GetVisible() : TSGBoolean;
			public
		property VisibleTimer : TSGScreenTimer     read FVisibleTimer write FVisibleTimer;
		property ActiveTimer  : TSGScreenTimer     read FActiveTimer  write FActiveTimer;
		property Caption      : TSGCaption    read FCaption      write FCaption;
		property Text         : TSGCaption    read FCaption      write FCaption;
		property Skin         : TSGScreenSkin read FSkin         write FSkin;
		property Visible      : Boolean       read FVisible      write SetVisible;
		property Active       : Boolean       read FActive       write FActive         default False;
		property Anchors      : TSGSetOfByte  read FAnchors      write FAnchors;
			protected
		FChildren:TSGComponentList;
		FCursorOnComponent:Boolean;
		FCursorOnComponentCaption:Boolean;
		FCanHaveChildren:Boolean;
		FComponentProcedure:TSGComponentProcedure;
		FChildrenPriority : TSGMaxEnum;
		FMarkedForDestroy : TSGBoolean;
			public
		function HasChildren() : TSGBoolean;virtual;
		function ChildCount() : TSGUInt32;virtual;
		procedure ClearPriority();
		procedure MakePriority();
		function GetPriorityComponent() : TSGComponent;
		function CursorInComponent():TSGBoolean;virtual;
		function CursorInComponentCaption():boolean;virtual;
		function GetVertex(const THAT:TSGSetOfByte;const FOR_THAT:TSGByte): TSGPoint2int32;
		function BottomShift():TSGScreenInt;
		function RightShift():TSGScreenInt;
			public
		procedure ToFront();
		function MustDestroyed() : TSGBoolean;
		procedure MarkForDestroy();
		function GetChild(a:TSGInt32):TSGComponent;
		function CreateChild(const Child : TSGComponent) : TSGComponent;
		procedure CompleteChild(const VChild : TSGComponent);
		function LastChild():TSGComponent;
		procedure CreateAlign(const NewAllign:TSGByte);
		function CursorPosition(): TSGPoint2int32;
		procedure DestroyAlign();
		procedure DestroyParent();
		procedure DestroySkin();
		procedure KillChildren();
		procedure VisibleAll();
		function IndexOf(const VComponent : TSGComponent): TSGLongInt;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property Children[Index : TSGInt32 (* Indexing [1..Size] *)]:TSGComponent read GetChild;
		property MarkedForDestroy : TSGBoolean read FMarkedForDestroy;
		property Align : TSGByte read FAlign write CreateAlign;
		property ChildrenPriority : TSGMaxEnum write FChildrenPriority;
		property ComponentProcedure : TSGComponentProcedure read FComponentProcedure write FComponentProcedure;
		property CursorOnComponent : Boolean read FCursorOnComponent write FCursorOnComponent;
		property CursorOnComponentCaption : Boolean read FCursorOnComponentCaption write FCursorOnComponentCaption;
			public
		function AsButton:TSGButton;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AsForm:TSGForm;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AsProgressBar:TSGProgressBar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AsPanel:TSGPanel;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AsLabel:TSGLabel;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AsPicture:TSGPicture;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AsButtonMenu:TSGButtonMenu;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AsScrollBar:TSGScrollBar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AsComboBox:TSGComboBox;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AsGrid:TSGGrid;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AsButtonMenuButton:TSGButtonMenuButton;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AsEdit:TSGEdit;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		OnChange : TSGComponentProcedure ;
		FUserPointer1, FUserPointer2, FUserPointer3 : Pointer;
		FDrawClass:TSGDrawable;
			public
		property DrawClass : TSGDrawable read FDrawClass write FDrawClass;
			public
		procedure DrawDrawClasses();virtual;
			public
		property UserPointer : Pointer read FUserPointer1 write FUserPointer1;
		end;
{$ENDIF}

{$IFDEF SCREEN_IMPLEMENTATION}
class function TSGComponent.ClassName() : TSGString;
begin
Result := 'TSGComponent';
end;

procedure TSGComponent.UpDateSkin();
begin
if (FSkin <> nil) and ((FParent = nil) or ((FParent <> nil) and (FParent.Skin <> FSkin))) then
	Skin.IddleFunction();
end;

function TSGComponent.GetActive() : TSGBoolean;
begin
Result := FActive;
end;

function TSGComponent.GetVisible() : TSGBoolean;
begin
Result := FVisible;
end;

function TSGComponent.HasChildren() : TSGBoolean;
begin
Result := False;
if FChildren <> nil then
	if Length(FChildren) > 0 then
		Result := True;
end;

function TSGComponent.ChildCount() : TSGUInt32;
begin
if not HasChildren() then
	Result := 0
else
	Result := Length(FChildren);
end;

function TSGComponent.GetVisibleTimer() : TSGScreenTimer;
begin
Result := FVisibleTimer;
end;

function TSGComponent.GetActiveTimer() : TSGScreenTimer;
begin
Result := FActiveTimer;
end;

function  TSGComponent.GetTitle() : TSGString;
begin
Result := FCaption;
end;

procedure TSGComponent.SetTitle(const VTitle : TSGString);
begin
FCaption := VTitle;
end;

function  TSGComponent.GetWidth() : TSGAreaInt;
begin
Result := FNeedWidth;
end;

function  TSGComponent.GetHeight() : TSGAreaInt;
begin
Result := FNeedHeight;
end;

procedure TSGComponent.SetWidth(const VWidth : TSGAreaInt);
begin
FNeedWidth := VWidth;
end;

procedure TSGComponent.SetHeight(const VHeight : TSGAreaInt);
begin
FNeedHeight := VHeight;
end;

function  TSGComponent.GetLeft() : TSGAreaInt;
begin
Result := FNeedLeft;
end;

function  TSGComponent.GetTop() : TSGAreaInt;
begin
Result := FNeedTop;
end;

procedure TSGComponent.SetLeft(const VLeft : TSGAreaInt);
begin
FNeedLeft := VLeft;
end;

procedure TSGComponent.SetTop(const VTop : TSGAreaInt);
begin
FNeedTop := VTop;
end;

function TSGComponent.GetLocation() : TSGComponentLocation;
var
	Pos : TSGVector3f;
begin
Pos := SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT));
Result.Import(Pos, SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)) - Pos);
end;

procedure TSGComponent.ToFront();
var
	Index : TSGLongInt;
begin
if FParent <> nil then
	begin
	if FParent.FChildren <> nil then
		begin
		if Length(FParent.FChildren) > 1 then
			begin
			Index := FParent.IndexOf(Self);
			if Index <> -1 then
				begin
				if Index <> High(FParent.FChildren) then
					begin
					FParent.FChildren[Index] := FParent.FChildren[High(FParent.FChildren)];
					FParent.FChildren[High(FParent.FChildren)] := Self;
					end;
				end;
			end;
		end;
	end;
end;

procedure TSGComponent.Resize();
begin
FromResize();
end;

procedure TSGComponent.DrawDrawClasses();
var
	Component : TSGComponent;
begin
if FDrawClass <> nil then
	FDrawClass.Paint();
for Component in Self do
	Component.DrawDrawClasses();
end;

function TSGComponent.AsEdit:TSGEdit;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Self is TSGEdit then
	Result:=TSGEdit(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.NotVisible:boolean;
begin
Result:=FVisibleTimer<0.05;
end;

function TSGComponent.AsButtonMenuButton:TSGButtonMenuButton;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Self is TSGButtonMenuButton then
	Result:=TSGButtonMenuButton(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.AsGrid:TSGGrid;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Self is TSGGrid then
	Result:=TSGGrid(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.IndexOf(const VComponent : TSGComponent ): TSGLongInt;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : LongInt;
begin
Result := -1;
for i := 0 to High(FChildren) do
	if FChildren[i] = VComponent then
		begin
		Result := i;
		break;
		end;
end;

procedure TSGComponent.VisibleAll;
var
	Component : TSGComponent;
begin
FVisibleTimer := 1;
for Component in Self do
	Component.VisibleAll();
end;

procedure TSGComponent.KillChildren();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function ChildExists() : TSGBool;
begin
Result := False;
if FChildren <> nil then
	if Length(FChildren) > 0 then
		Result := True;
end;

begin
while ChildExists() do
	begin
	FChildren[0].Destroy();
	end;
end;

procedure TSGComponent.BoundsToNeedBounds;
begin
FWidth:=FNeedWidth;
FHeight:=FNeedHeight;
FLeft:=FNeedLeft;
FTop:=FNeedTop;
end;

function TSGComponent.AsComboBox:TSGComboBox;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Self is TSGComboBox then
	Result:=TSGComboBox(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.AsScrollBar:TSGScrollBar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Self is TSGScrollBar then
	Result:=TSGScrollBar(Pointer(Self))
else
	Result:=nil;
end;

procedure TSGComponent.WriteBounds;
begin
writeln('Left = ',Left);
writeln('Top = ',Top);
writeln('Width = ',Width);
writeln('Height = ',Height);
end;

procedure TSGComponent.SetMiddleBounds(const NewWidth,NewHeight:LongInt);
var
	PW, PH : TSGLongWord;
begin
FNeedHeight:=NewHeight;
FNeedWidth:=NewWidth;
if Parent <> nil then
	begin
	PW := Parent.Width;
	PH := Parent.Height;
	end
else
	begin
	PW := Render.Width;
	PH := Render.Height;
	end;
FNeedLeft:=Round((PW-NewWidth)/2);
FNeedTop:=Round((PH-NewHeight)/2);
end;

procedure TSGComponent.SetVisible(const b:Boolean);
var
	Component : TSGComponent;
begin
FVisible := b;
for Component in Self do
	Component.Visible := Visible;
end;

function TSGComponent.AsButtonMenu:TSGButtonMenu;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Self is TSGButtonMenu then
	Result:=TSGButtonMenu(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.AsPicture:TSGPicture;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Self is TSGPicture then
	Result:=TSGPicture(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.AsLabel:TSGLabel;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Self is TSGLabel then
	Result:=TSGLabel(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.GetChild(a:TSGInt32):TSGComponent;
begin
if (a-1 >= 0) and (a-1<=High(FChildren)) then
	Result:=FChildren[a-1]
else
	Result:=nil;
end;

function TSGComponent.AsPanel:TSGPanel;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Self is TSGPanel then
	Result:=TSGPanel(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.AsProgressBar:TSGProgressBar;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Self is TSGProgressBar then
	Result:=TSGProgressBar(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.AsButton:TSGButton;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Self is TSGButton then
	Result:=TSGButton(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.AsForm:TSGForm;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Self is TSGForm then
	Result:=TSGForm(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.GetScreenWidth : longint;
begin
if FParent<>nil then
	Result:=FParent.Width
else
	Result:=Render.Width;
end;

function TSGComponent.GetScreenHeight : longint;
begin
if FParent<>nil then
	Result:=FParent.Height
else
	Result:=Render.Height;
end;

procedure TSGComponent.SetRight(NewRight:TSGScreenInt);
begin
Left:=ScreenWidth-Width-NewRight;
end;

procedure TSGComponent.SetBottom(NewBottom:TSGScreenInt);
begin
Top:=ScreenHeight-Height-NewBottom;
end;

function TSGComponent.GetRight:TSGScreenInt;
begin
Result:=ScreenWidth-Width-Left;
end;

function TSGComponent.GetBottom : TSGScreenInt;
begin
Result:=ScreenHeight-Height-Top;
end;

function TSGComponent.BottomShift:TSGScreenInt;
begin
Result:=FTopShiftForChilds+FBottomShiftForChilds;
end;

function TSGComponent.RightShift:TSGScreenInt;
begin
Result:=FLeftShiftForChilds+FRightShiftForChilds;
end;

function TSGComponent.LastChild:TSGComponent;
begin
Result:=Nil;
if FChildren <> nil then
	Result := FChildren[High(FChildren)];
end;

function TSGComponent.UpDateObj(var Obj,NObj:TSGScreenInt):TSGScreenInt;
const
	Speed = 2;
var
	Value:LongInt = 0;
	OldObj:Longint;
begin
if Obj <> NObj then
	begin
	OldObj:=Obj;
	Value:=round((NObj * Context.ElapsedTime / Speed + Obj * 5) / (5 + Context.ElapsedTime / Speed));
	Result:=Value-Obj;
	Obj:=Value;
	if (Obj=OldObj) and (NObj<>Obj) then
		if NObj>Obj then
			Obj+=1
		else
			Obj-=1;
	end;
end;

procedure TSGComponent.SetBoundsFloat(const NewLeft, NewTop, NewWidth, NewHeight : TSGScreenFloat);
begin
SetBounds(Round(NewLeft), Round(NewTop), Round(NewWidth), Round(NewHeight));
end;

procedure TSGComponent.SetBounds(const NewLeft, NewTop, NewWidth, NewHeight : TSGScreenInt);
begin
Height:=NewHeight;
Left:=NewLeft;
Top:=NewTop;
Width:=NewWidth;

FNeedHeight:=NewHeight;
FNeedLeft:=NewLeft;
FNeedTop:=NewTop;
FNeedWidth:=NewWidth;

FNoneHeight:=NewHeight;
FNoneLeft:=NewLeft;
FNoneTop:=NewTop;
FNoneWidth:=NewWidth;

{if FParent=SGScreen then
	begin
	Top:=Top+Context.TopShift;
	FNeedTop+=Context.TopShift;
	FNoneTop+=Context.TopShift;
	end;}
end;

class function TSGComponent.RandomOne:LongInt;
begin
Result:=0;
While Result=0 do
	Result:=random(3)-1;
end;

procedure TSGComponent.UpgradeTimer(const  Flag:Boolean; var Timer : TSGScreenTimer; const Mnozhitel:LongInt = 1;const Mn2:single = 1);
begin
if Flag then
	begin
	Timer+=SGObjectTimerConst*Mn2*Mnozhitel*Context.ElapsedTime;
	if Timer>1 then
		Timer:=1;
	end
else
	begin
	Timer-=SGObjectTimerConst*(1/Mn2)*Mnozhitel*Context.ElapsedTime;
	if Timer<0 then
		Timer:=0;
	end;
end;

function TSGComponent.ReqursiveActive():Boolean;
begin
if (not FActive) or (FParent = nil) then
	Result := FActive
else
	Result := FParent.ReqursiveActive();
end;

procedure TSGComponent.UpgradeTimers;
begin
UpgradeTimer(FVisible,FVisibleTimer);
UpgradeTimer(FActive and ReqursiveActive, FActiveTimer);
end;

// Deleted self in parent
procedure TSGComponent.DestroyParent;
var
	ii, i : TSGLongInt;
begin
{$IFDEF SGMoreDebuging}
	if FParent<>nil then
		WriteLn('Begin of  "TSGComponent.DestroyParent" ( Length='+SGStr(Length(FParent.FChildren))+' ).')
	else
		WriteLn('Begin of  "TSGComponent.DestroyParent" ( Parent=nil ).');
	{$ENDIF}
if FParent<>nil then
	begin
	ii := FParent.IndexOf(Self);
	if ii <> -1 then
		begin
		if ii + 1 = FParent.FChildrenPriority then
			ClearPriority();
		{$IFDEF SGMoreDebuging}
			WriteLn('"TSGComponent.DestroyParent" :  Find Self on '+SGStr(ii+1)+' position .');
			{$ENDIF}
		if ii < High(FParent.FChildren) then
			for i:= ii to High(FParent.FChildren) - 1 do
				FParent.FChildren[i] := FParent.FChildren[i + 1];
		SetLength(FParent.FChildren, Length(FParent.FChildren) - 1);
		end;
	end;
{$IFDEF SGMoreDebuging}
	if FParent<>nil then
		WriteLn('End of  "TSGComponent.DestroyParent" ( Length='+SGStr(Length(FParent.FChildren))+' ).')
	else
		WriteLn('End of  "TSGComponent.DestroyParent" ( Parent=nil ).');
	{$ENDIF}
end;

procedure TSGComponent.DestroySkin();
begin
if FSkin <> nil then
	begin
	if (FParent = nil) or ((FParent <> nil) and (FParent.Skin <> FSkin)) then
		FSkin.Destroy();
	FSkin := nil;
	end;
end;

destructor TSGComponent.Destroy();
begin
if FDrawClass <> nil then
	begin
	FDrawClass.Destroy();
	FDrawClass := nil;
	end;
KillChildren();
DestroyParent();
DestroySkin();
inherited Destroy();
end;

function TSGComponent.GetVertex(const THAT:TSGSetOfByte;const FOR_THAT:TSGByte): TSGPoint2int32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (SGS_LEFT in THAT) and (SGS_TOP in THAT) then
	begin
	if FOR_THAT = SG_VERTEX_FOR_PARENT then
		Result.Import(FRealLeft,FRealTop)
	else
		if FOR_THAT = SG_VERTEX_FOR_CHILDREN then
			Result.Import(FRealLeft+FLeftShiftForChilds,FRealTop+FTopShiftForChilds)
		else
			Result.Import(0,0);
	end
else
	if (SGS_TOP in THAT) and (SGS_RIGHT in THAT) then
		begin
		if FOR_THAT = SG_VERTEX_FOR_PARENT then
			Result.Import(FRealLeft+FWidth,FRealTop)
		else
			if FOR_THAT = SG_VERTEX_FOR_CHILDREN then
				Result.Import(FRealLeft+FWidth-FRightShiftForChilds,FRealTop+FTopShiftForChilds)
			else
				Result.Import(0,0);
		end
	else
		if (SGS_BOTTOM in THAT) and (SGS_RIGHT in THAT) then
			begin
			if FOR_THAT = SG_VERTEX_FOR_PARENT then
				Result.Import(FRealLeft+FWidth,FRealTop+FHeight)
			else
				if FOR_THAT = SG_VERTEX_FOR_CHILDREN then
					Result.Import(FRealLeft+FWidth-FRightShiftForChilds,FRealTop+FHeight-FBottomShiftForChilds)
				else
					Result.Import(0,0);
			end
		else
			if (SGS_LEFT in THAT) and (SGS_BOTTOM in THAT) then
				begin
				if FOR_THAT = SG_VERTEX_FOR_PARENT then
					Result.Import(FRealLeft,FRealTop+FHeight)
				else
					if FOR_THAT = SG_VERTEX_FOR_CHILDREN then
						Result.Import(FRealLeft+FLeftShiftForChilds,FRealTop+FHeight-FBottomShiftForChilds)
					else
						Result.Import(0,0);
				end
			else
				Result.Import(0,0);
end;

procedure TSGComponent.CompleteChild(const VChild : TSGComponent);
var
	Component : TSGComponent;
begin
if ContextAssigned() then
	VChild.SetContext(Context);
if VChild.Parent = nil then
	VChild.Parent := Self;
if VChild.Skin = nil then
	VChild.Skin := Skin;
for Component in VChild do
	VChild.CompleteChild(Component);
end;

function TSGComponent.CreateChild(const Child : TSGComponent) : TSGComponent;
begin
Result := nil;
if (Child <> nil) and FCanHaveChildren then
	begin
	Result := Child;
	SetLength(FChildren, Length(FChildren) + 1);
	FChildren[High(FChildren)] := Result;
	CompleteChild(Result);
	end;
end;

procedure TSGComponent.AddToTop(const Value:LongInt);
begin
FNeedTop+=Value;
end;

procedure TSGComponent.AddToLeft(const Value:LongInt);
begin
FNeedLeft+=Value;
end;

procedure TSGComponent.AddToWidth(const Value:LongInt);
begin
FNeedWidth+=Value;
end;

procedure TSGComponent.AddToHeight(const Value:LongInt);
begin
FNeedHeight+=Value;
end;

function TSGComponent.CursorInComponent():boolean;
begin
Result:=
	(Context.CursorPosition(SGNowCursorPosition).x>=FRealLeft)and
	(Context.CursorPosition(SGNowCursorPosition).x<=FRealLeft+FWidth)and
	(Context.CursorPosition(SGNowCursorPosition).y>=FRealTop)and
	(Context.CursorPosition(SGNowCursorPosition).y<=FRealTop+FHeight);
FCursorOnComponent:=Result;
end;

procedure TSGComponent.FromUpDate(var FCanChange:Boolean);
var
	PriorityComponent, Component : TSGComponent;
	Index : TSGLongWord;
begin
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGComponent.FromUpDate(var FCanChange:Boolean = ', FCanChange, ') : Begining');
	{$ENDIF}

UpDateObjects();
UpgradeTimers();
UpDateSkin();

PriorityComponent := GetPriorityComponent();
if PriorityComponent <> nil then
	PriorityComponent.FromUpDate(FCanChange);

Index := 0;
while Index < Length(FChildren) do
	begin
	Component := FChildren[Index];
	if Component.MustDestroyed() then
		Component.Destroy()
	else
		begin
		if Component <> PriorityComponent then
			Component.FromUpDate(FCanChange);
		Index += 1;
		end;
	end;

if FComponentProcedure<>nil then
	FComponentProcedure(Self);
end;

procedure TSGComponent.DeleteDeviceResources();
var
	Component : TSGComponent;
begin
if FSkin <> nil then
	FSkin.DeleteDeviceResources();
if FDrawClass <> nil then
	FDrawClass.DeleteDeviceResources();
for Component in Self do
	Component.DeleteDeviceResources();
end;

procedure TSGComponent.LoadDeviceResources();
var
	Component : TSGComponent;
begin
if FSkin <> nil then
	FSkin.LoadDeviceResources();
if FDrawClass <> nil then
	FDrawClass.LoadDeviceResources();
for Component in Self do
	Component.LoadDeviceResources();
end;

function TSGComponent.GetOption(const VName : TSGString) : TSGPointer;
begin
Result := nil;
end;

procedure TSGComponent.SetOption(const VName : TSGString; const VValue : TSGPointer);
begin
end;

function TSGComponent.Suppored() : TSGBoolean;
begin
Result := True;
end;

function TSGComponent.GetEnumerator(): TSGComponentEnumerator;
begin
Result := TSGComponentEnumeratorNormal.Create(Self);
end;

function TSGComponent.GetReverseEnumerator(): TSGComponentEnumerator;
begin
Result := TSGComponentEnumeratorReverse.Create(Self);
end;

procedure TSGComponent.Paint();
begin
FromDraw();
end;

procedure TSGComponent.FromDraw();
var
	Component, PriorityComponent : TSGComponent;
begin
PriorityComponent := GetPriorityComponent();
if PriorityComponent = nil then
	for Component in Self do
		Component.FromDraw()
else
	begin
	for Component in Self do
		if Component <> PriorityComponent then
			Component.FromDraw();
	PriorityComponent.FromDraw();
	end;
end;

procedure TSGComponent.ClearPriority();
var
	ii : TSGMaxEnum;
begin
FChildrenPriority:=0;
if FParent<>nil then
	begin
	if FParent.FChildrenPriority <> 0 then
		begin
		ii := Parent.IndexOf(Self) + 1;
		if (ii = FParent.FChildrenPriority) then
			FParent.ClearPriority();
		end;
	end;
end;

function TSGComponent.MustDestroyed() : TSGBoolean;
begin
Result := FMarkedForDestroy;
if Result then
	Result := (FVisibleTimer + FActiveTimer) < SGZero;
end;

procedure TSGComponent.MakePriority();
var
	ii : TSGMaxEnum;
begin
if FParent<>nil then
	begin
	ii := Parent.IndexOf(Self) + 1;
	if ii <> 0 then
		begin
		FParent.FChildrenPriority := ii;
		FParent.MakePriority();
		end;
	end;
end;

procedure TSGComponent.MarkForDestroy();
begin
Active := False;
Visible := False;
FMarkedForDestroy := True;
end;

constructor TSGComponent.Create();
begin
inherited Create();
FMarkedForDestroy := False;
FChildrenPriority:=0;
FDrawClass:=nil;
FUnLimited:=False;
OnChange:=nil;
Width:=0;
Height:=0;
FParent:=nil;
Left:=0;
Top:=0;
FAlign:=SGAlignNone;
FAnchors:=[];
FVisible:=False;
FVisibleTimer:=0;
FActive:=True;
FActiveTimer:=0;
FCaption:='Caption';
FChildren:=nil;
FCursorOnComponent:=False;
FCursorOnComponentCaption:=False;
FLeftShiftForChilds:=5;
FTopShiftForChilds:=5;
FRightShiftForChilds:=5;
FBottomShiftForChilds:=5;
FRealTop:=0;
FRealLeft:=0;
FCanHaveChildren:=True;
ComponentProcedure:=nil;
FUserPointer1:=nil;
FUserPointer2:=nil;
FUserPointer3:=nil;
FAnchorsData.FParentHeight:=0;
FAnchorsData.FParentWidth:=0;
end;

procedure TSGComponent.SetShifts(const NL,NT,NR,NB:LongInt);
begin
FLeftShiftForChilds:=NL;
FTopShiftForChilds:=NT;
FRightShiftForChilds:=NR;
FBottomShiftForChilds:=NB;
end;

procedure TSGComponent.FromResize();
var
	I : TSGLongInt;
	Component : TSGComponent;
begin
if SGAnchBottom in FAnchors then
	begin
	if FAnchorsData.FParentHeight=0 then
		if FParent<>nil then
			FAnchorsData.FParentHeight:=FParent.Height
		else
	else
		if FParent<>nil then
			begin
			if FAnchorsData.FParentHeight<>FParent.Height then
				begin
				I := FAnchorsData.FParentHeight - FParent.Height;
				FNeedTop -= I;
				FAnchorsData.FParentHeight := FParent.Height;
				end;
			end;
	end;
if SGAnchRight in FAnchors then
	begin
	if FAnchorsData.FParentWidth=0 then
		if FParent<>nil then
			FAnchorsData.FParentWidth:=FParent.Width
		else
	else
		if FParent<>nil then
			begin
			if FAnchorsData.FParentWidth<>FParent.Width then
				begin
				I:=FAnchorsData.FParentWidth-FParent.Width;
				FNeedLeft-=I;
				FAnchorsData.FParentWidth:=FParent.Width;
				end;
			end;
	end;
BoundsToNeedBounds();
{CW:=FNeedWidth;
CH:=FNeedHeight;
case FAlign of
SGAlignRight:
	begin
	FNeedLeft+=Parent.Width-ParentWidth;
	end;
end;
if FAlign in [SGAlignClient] then
	begin
	for i:=0 to High(FChildren) do
		FChildren[i].FromResize(CW,CH);
	end;}
for Component in Self do
	Component.FromResize();
end;

function TSGComponent.GetPriorityComponent() : TSGComponent;
begin
Result := nil;
if (FChildrenPriority > 0) and (FChildren <> nil) then
	if FChildrenPriority <= Length(FChildren) then
		Result := FChildren[FChildrenPriority - 1];
end;

function TSGComponent.CursorInComponentCaption():boolean;
begin
Result:=False;
end;

procedure TSGComponent.FromUpDateCaptionUnderCursor(var CanRePleace:Boolean);
begin
end;

procedure TSGComponent.DestroyAlign;
begin
if FAlign=SGAlignTop then
	FNeedLeft:=FNoneLeft;
if FAlign=SGAlignLeft then
	FNeedTop:=FNoneTop;
if FAlign=SGAlignRight then
	FNeedTop:=FNoneTop;
if FAlign=SGAlignBottom then
	FNeedLeft:=FNoneLeft;
if FAlign=SGAlignClient then
	FNeedLeft:=FNoneLeft;
FAlign:=SGAlignNone;
FNeedHeight:=FNoneHeight;
FNeedWidth:=FNoneWidth;
end;

function TSGComponent.CursorPosition(): TSGPoint2int32;
begin
Result := Context.CursorPosition(SGNowCursorPosition);
end;

procedure TSGComponent.CreateAlign(const NewAllign:TSGByte);
begin
FAlign:=NewAllign;
end;

procedure TSGComponent.TestCoords;
begin
if (FParent<>nil) and (FParent.FParent<>nil) and (not FUnLimited) then
	begin
	if FHeight>FParent.FHeight-FParent.FTopShiftForChilds-FParent.FBottomShiftForChilds then
		FHeight:=FParent.FHeight-FParent.FTopShiftForChilds-FParent.FBottomShiftForChilds;
	if FWidth>FParent.FWidth-FParent.FLeftShiftForChilds-FParent.FRightShiftForChilds then
		FWidth:=FParent.FWidth-FParent.FLeftShiftForChilds-FParent.FRightShiftForChilds;
	if FTop<0 then
		FTop:=0;
	if FLeft<0 then
		FLeft:=0;
	if (FLeft+FWidth)>FParent.FWidth-FParent.RightShift then
		FLeft:=FParent.FWidth-FWidth-FParent.RightShift;
	if (FTop+FHeight)>FParent.FHeight-FParent.BottomShift then
		FTop:=FParent.FHeight-FHeight-FParent.BottomShift;
	if FNeedTop<0 then
		FNeedTop:=0;
	if FNeedLeft<0 then
		FNeedLeft:=0;
	if (FNeedLeft+FNeedWidth)>FParent.FNeedWidth-FParent.RightShift then
		FNeedLeft:=FParent.FNeedWidth-FNeedWidth-FParent.RightShift;
	if (FNeedTop+FNeedHeight)>FParent.FNeedHeight-FParent.BottomShift then
		FNeedTop:=FParent.FNeedHeight-FNeedHeight-FParent.BottomShift;
	end;
end;

procedure TSGComponent.SetCaption(const NewCaption : TSGCaption);
begin
FCaption := NewCaption;
end;

procedure TSGComponent.UpDateObjects();
var
	Component : TSGComponent;
	ValueHeight : TSGLongInt = 0;
	ValueWidth  : TSGLongInt = 0;
	ValueLeft   : TSGLongInt = 0;
	ValueTop    : TSGLongInt = 0;
begin
if FParent<>nil then
	case FAlign of
	SGAlignLeft:
		begin
		FNeedLeft:=0;
		FNeedTop:=0;
		FNeedHeight:=FParent.FHeight-FParent.FTopShiftForChilds-FParent.FBottomShiftForChilds;
		end;
	SGAlignTop:
		begin
		FNeedLeft:=0;
		FNeedTop:=0;
		FNeedWidth:=FParent.FWidth-FParent.FLeftShiftForChilds-FParent.FRightShiftForChilds;
		end;
	SGAlignRight:
		begin
		FNeedTop:=0;
		FNeedLeft:=FParent.FWidth-FParent.FLeftShiftForChilds-FParent.FRightShiftForChilds-FWidth;
		FNeedHeight:=FParent.FHeight-FParent.FTopShiftForChilds-FParent.FBottomShiftForChilds;
		end;
	SGAlignBottom:
		begin
		FNeedLeft:=0;
		FNeedWidth:=FParent.FWidth-FParent.FLeftShiftForChilds-FParent.FRightShiftForChilds;
		FNeedTop:=FParent.FHeight-FParent.FTopShiftForChilds-FParent.FBottomShiftForChilds-FHeight;
		end;
	SGAlignClient:
		begin
		FNeedTop:=0;
		FNeedLeft:=0;
		FNeedWidth:=FParent.FWidth-FParent.FLeftShiftForChilds-FParent.FRightShiftForChilds;
		FNeedHeight:=FParent.FHeight-FParent.FTopShiftForChilds-FParent.FBottomShiftForChilds;
		end;
	SGAlignNone: begin end;
	else begin end;
	end;
ValueTop    := FTop;
ValueHeight := FHeight;
ValueWidth  := FWidth;
ValueLeft   := FLeft;
UpDateObj(FHeight, FNeedHeight);
UpDateObj(FTop,    FNeedTop);
UpDateObj(FLeft,   FNeedLeft);
UpDateObj(FWidth,  FNeedWidth);
TestCoords();
ValueHeight := FHeight - ValueHeight;
ValueLeft   := FLeft   - ValueLeft;
ValueTop    := FTop    - ValueTop;
ValueWidth  := FWidth  - ValueWidth;
for Component in Self do
	begin
	Component.FTop    -= ValueTop;
	Component.FWidth  -= ValueWidth;
	Component.FHeight -= ValueHeight;
	Component.FLeft   -= ValueLeft;
	end;
if FParent<>nil then
	begin
	FRealLeft := FParent.FRealLeft + FLeft + FParent.FLeftShiftForChilds;
	FRealTop  := FParent.FRealTop  + FTop  + FParent.FTopShiftForChilds;
	end;
end;

procedure TSGComponent.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);

procedure PUpdateComponent(const Component : TSGComponent);
begin
Component.FromUpDateUnderCursor(CanRePleace, Component.CursorInComponent());
if Component.CursorInComponentCaption() then
	Component.FromUpDateCaptionUnderCursor(CanRePleace);
end;

var
	UnderCursorComponent, PriorityComponent, Component : TSGComponent;

begin
PriorityComponent := GetPriorityComponent();
if PriorityComponent <> nil then
	if not (PriorityComponent.Visible and PriorityComponent.Active) then
		PriorityComponent := nil;
if PriorityComponent <> nil then
	PUpdateComponent(PriorityComponent);

UnderCursorComponent := nil;
for Component in Self.GetReverseEnumerator() do
	if Component <> PriorityComponent then
		if Component.CursorInComponent() and Component.Visible and  Component.Active then
			begin
			UnderCursorComponent := Component;
			break;
			end;

if UnderCursorComponent <> nil then
	PUpdateComponent(UnderCursorComponent);
end;


constructor TSGComponentEnumerator.Create(const VComponent : TSGComponent);
begin
inherited Create();
FComponent := VComponent;
FCurrent := nil;
end;

function TSGComponentEnumerator.GetEnumerator() : TSGComponentEnumerator;
begin
Result := Self;
end;

constructor TSGComponentEnumeratorNormal.Create(const VComponent : TSGComponent);
begin
inherited Create(VComponent);
FIndex := 0;
end;

constructor TSGComponentEnumeratorReverse.Create(const VComponent : TSGComponent);
begin
inherited Create(VComponent);
FIndex := Length(VComponent.FChildren) + 1;
end;

function TSGComponentEnumeratorNormal.MoveNext(): TSGBoolean;
begin
FIndex += 1;
if (FIndex >= 1) and (FIndex <= Length(FComponent.FChildren)) then
	FCurrent := FComponent.Children[FIndex]
else
	FCurrent := nil;
Result := FCurrent <> nil;
end;

function TSGComponentEnumeratorReverse.MoveNext(): TSGBoolean;
begin
FIndex -= 1;
if (FIndex >= 1) and (FIndex <= Length(FComponent.FChildren)) then
	FCurrent := FComponent.Children[FIndex]
else
	FCurrent := nil;
Result := FCurrent <> nil;
end;
{$ENDIF}
