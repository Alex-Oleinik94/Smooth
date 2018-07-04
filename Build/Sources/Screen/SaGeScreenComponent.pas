{$INCLUDE SaGe.inc}

unit SaGeScreenComponent;

interface

uses
	 SaGeBase
	,SaGeScreenBase
	,SaGeClasses
	,SaGeCommonClasses
	,SaGeScreenSkin
	,SaGeCommonStructs
	;
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
	TSGComponentProcedure = procedure (Component : TSGComponent);
	TSGComponent          = class(TSGContextabled, ISGDeviceDependent, ISGComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
			public
			// for-in loop
		function GetEnumerator(): TSGComponentEnumerator;
		function GetReverseEnumerator: TSGComponentEnumerator;
			protected
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
		FLocation : TSGComponentLocation;
		FRealLocation : TSGComponentLocation;
		FDefaultLocation : TSGComponentLocation;
		FRealPosition : TSGComponentLocationVectorInt;
		FBordersSize : TSGComponentBoundsSize;
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
		
		procedure UpDateLocation();
		function UpDateValue(var RealObj, Obj : TSGComponentLocationInt) : TSGComponentLocationInt;
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
		property BoundsSize   : TSGComponentBoundsSize read FBordersSize;
		property RealPosition : TSGComponentLocationVectorInt read FRealPosition;
		property Location     : TSGComponentLocation read GetLocation;
			public
		procedure BoundsMakeReal();virtual;
		procedure SetBordersSize(const _L, _T, _R, _B : TSGScreenInt);virtual;
		procedure SetBounds(const NewLeft, NewTop, NewWidth, NewHeight : TSGScreenInt);virtual;
		procedure SetBoundsFloat(const NewLeft, NewTop, NewWidth, NewHeight : TSGScreenFloat);
		procedure SetMiddleBounds(const NewWidth, NewHeight : TSGScreenInt);virtual;
		procedure WriteBounds();
		class function RandomOne():TSGScreenInt;
		procedure AddToLeft(const Value : TSGScreenInt);
		procedure AddToWidth(const Value : TSGScreenInt);
		procedure AddToHeight(const Value : TSGScreenInt);
		procedure AddToTop(const Value : TSGScreenInt);
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
			public
		procedure FromResize();virtual;
			protected
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
		procedure ChildToListEnd(const Index : TSGMaxEnum);
		procedure ChildToListEnd(const Component : TSGComponent);
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
		function GetChildrenCount() : TSGUInt32;
			public
		property Children[Index : TSGInt32 (* Indexing [1..Size] *)]:TSGComponent read GetChild;
		property ChildrenCount : TSGUInt32 read GetChildrenCount;
		property MarkedForDestroy : TSGBoolean read FMarkedForDestroy;
		property Align : TSGByte read FAlign write CreateAlign;
		property ChildrenPriority : TSGMaxEnum write FChildrenPriority;
		property ComponentProcedure : TSGComponentProcedure read FComponentProcedure write FComponentProcedure;
		property CursorOnComponent : Boolean read FCursorOnComponent write FCursorOnComponent;
		property CursorOnComponentCaption : Boolean read FCursorOnComponentCaption write FCursorOnComponentCaption;
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


implementation

uses
	 SaGeCommon
	,SaGeMathUtils
	,SaGeContextUtils
	;

function TSGComponent.GetChildrenCount() : TSGUInt32;
begin
Result := 0;
if (FChildren <> nil) then
	Result := Length(FChildren);
end;

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

procedure TSGComponent.ChildToListEnd(const Component : TSGComponent);
var
	Index, i : TSGMaxEnum;
begin
Index := 0;
if (FChildren <> nil) and (Length(FChildren) > 0) then
	for i := 0 to High(FChildren) do
		if FChildren[i] = Component then
			begin
			Index := i + 1;
			break;
			end;
if (Index > 0) then
	ChildToListEnd(Index);
end;

procedure TSGComponent.ChildToListEnd(const Index : TSGMaxEnum);
var
	i : TSGMaxEnum;
	Component : TSGComponent;
begin
Component := nil;
if (Index > 0) and (Index <= ChildCount) then
	begin
	Component := FChildren[Index - 1];
	for i:= Index - 1 to ChildrenCount - 1 do
		FChildren[i] := FChildren[i + 1];
	FChildren[ChildrenCount - 1] := Component;
	end;
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
Result := FLocation.Size.x;
end;

function  TSGComponent.GetHeight() : TSGAreaInt;
begin
Result := FLocation.Size.y;
end;

procedure TSGComponent.SetWidth(const VWidth : TSGAreaInt);
begin
FLocation.Width := VWidth;
end;

procedure TSGComponent.SetHeight(const VHeight : TSGAreaInt);
begin
FLocation.Height := VHeight;
end;

function  TSGComponent.GetLeft() : TSGAreaInt;
begin
Result := FLocation.Position.x;
end;

function  TSGComponent.GetTop() : TSGAreaInt;
begin
Result := FLocation.Position.y;
end;

procedure TSGComponent.SetLeft(const VLeft : TSGAreaInt);
begin
FLocation.Left := VLeft;
end;

procedure TSGComponent.SetTop(const VTop : TSGAreaInt);
begin
FLocation.Top := VTop;
end;

function TSGComponent.GetLocation() : TSGComponentLocation;
var
	Position, Size : TSGVector2int32;
begin
Position := GetVertex([SGS_LEFT,SGS_TOP], SG_VERTEX_FOR_PARENT);
Size := GetVertex([SGS_RIGHT,SGS_BOTTOM], SG_VERTEX_FOR_PARENT);
Size -= Position;
Result.Import(
	TSGComponentLocationVectorInt.Create(Position.x, Position.y),
	TSGComponentLocationVectorInt.Create(Size.x, Size.y));
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

function TSGComponent.NotVisible:boolean;
begin
Result:=FVisibleTimer<0.05;
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

procedure TSGComponent.BoundsMakeReal;
begin
FRealLocation := FLocation;
end;

procedure TSGComponent.WriteBounds;
begin
FLocation.Write('Location ');
end;

procedure TSGComponent.SetMiddleBounds(const NewWidth,NewHeight:LongInt);
var
	PW, PH : TSGLongWord;
begin
FLocation.Height := NewHeight;
FLocation.Width  := NewWidth;
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
FLocation.Left := Round((PW-NewWidth)/2);
FLocation.Top  := Round((PH-NewHeight)/2);
end;

procedure TSGComponent.SetVisible(const b:Boolean);
var
	Component : TSGComponent;
begin
FVisible := b;
for Component in Self do
	Component.Visible := Visible;
end;

function TSGComponent.GetChild(a:TSGInt32):TSGComponent;
begin
if (a-1 >= 0) and (a-1<=High(FChildren)) then
	Result:=FChildren[a-1]
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
Result := FBordersSize.Top + FBordersSize.Bottom;
end;

function TSGComponent.RightShift:TSGScreenInt;
begin
Result := FBordersSize.Left + FBordersSize.Right;
end;

function TSGComponent.LastChild:TSGComponent;
begin
Result:=Nil;
if FChildren <> nil then
	Result := FChildren[High(FChildren)];
end;

function TSGComponent.UpDateValue(var RealObj, Obj : TSGComponentLocationInt) : TSGComponentLocationInt;
const
	Speed = 2;
var
	Value : TSGComponentLocationInt = 0;
	OldValue : TSGComponentLocationInt;
begin
if (RealObj <> Obj) then
	begin
	OldValue:=RealObj;
	Value:=Round((Obj * Context.ElapsedTime / Speed + RealObj * 5) / (5 + Context.ElapsedTime / Speed));
	Result:=Value-RealObj;
	RealObj:=Value;
	if (RealObj=OldValue) and (Obj<>RealObj) then
		if Obj>RealObj then
			RealObj+=1
		else
			RealObj-=1;
	end;
end;

procedure TSGComponent.SetBoundsFloat(const NewLeft, NewTop, NewWidth, NewHeight : TSGScreenFloat);
begin
SetBounds(Round(NewLeft), Round(NewTop), Round(NewWidth), Round(NewHeight));
end;

procedure TSGComponent.SetBounds(const NewLeft, NewTop, NewWidth, NewHeight : TSGScreenInt);
begin
FLocation.Left := NewLeft;
FLocation.Top := NewTop;
FLocation.Width := NewWidth;
FLocation.Height := NewHeight;
//FRealLocation := FLocation;
FDefaultLocation := FLocation;
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
		Result.Import(FRealPosition.x,FRealPosition.y)
	else if FOR_THAT = SG_VERTEX_FOR_CHILDREN then
		Result.Import(FRealPosition.x + FBordersSize.Left, FRealPosition.y + FBordersSize.Top)
	else
		Result.Import(0,0);
	end
else if (SGS_TOP in THAT) and (SGS_RIGHT in THAT) then
	begin
	if FOR_THAT = SG_VERTEX_FOR_PARENT then
		Result.Import(FRealPosition.x + FRealLocation.Width, FRealPosition.y)
	else if FOR_THAT = SG_VERTEX_FOR_CHILDREN then
		Result.Import(FRealPosition.x + FRealLocation.Width - FBordersSize.Right, FRealPosition.y + FBordersSize.Top)
	else
		Result.Import(0,0);
	end
else if (SGS_BOTTOM in THAT) and (SGS_RIGHT in THAT) then
	begin
	if FOR_THAT = SG_VERTEX_FOR_PARENT then
		Result.Import(FRealPosition.x + FRealLocation.Width, FRealPosition.y + FRealLocation.Height)
	else if FOR_THAT = SG_VERTEX_FOR_CHILDREN then
		Result.Import(FRealPosition.x + FRealLocation.Width - FBordersSize.Right, FRealPosition.y + FRealLocation.Height - FBordersSize.Bottom)
	else
		Result.Import(0,0);
	end 
else if (SGS_LEFT in THAT) and (SGS_BOTTOM in THAT) then
	begin
	if FOR_THAT = SG_VERTEX_FOR_PARENT then
		Result.Import(FRealPosition.x,FRealPosition.y + FRealLocation.Height)
	else if FOR_THAT = SG_VERTEX_FOR_CHILDREN then
		Result.Import(FRealPosition.x + FBordersSize.Left, FRealPosition.y + FRealLocation.Height - FBordersSize.Bottom)
	else
		Result.Import(0,0);
	end
else
	Result.Import(0, 0);
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

procedure TSGComponent.AddToTop(const Value : TSGScreenInt);
begin
FLocation.Top := FLocation.Top + Value;
end;

procedure TSGComponent.AddToLeft(const Value : TSGScreenInt);
begin
FLocation.Left := FLocation.Left + Value;
end;

procedure TSGComponent.AddToWidth(const Value : TSGScreenInt);
begin
FLocation.Width := FLocation.Width + Value;
end;

procedure TSGComponent.AddToHeight(const Value : TSGScreenInt);
begin
FLocation.Height := FLocation.Height + Value;
end;

function TSGComponent.CursorInComponent() : TSGBoolean;
begin
Result:=
	(Context.CursorPosition(SGNowCursorPosition).x>=FRealPosition.x)and
	(Context.CursorPosition(SGNowCursorPosition).x<=FRealPosition.x + FRealLocation.Width)and
	(Context.CursorPosition(SGNowCursorPosition).y>=FRealPosition.y)and
	(Context.CursorPosition(SGNowCursorPosition).y<=FRealPosition.y + FRealLocation.Height);
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
FParent:=nil;
FLocation.Import(0, 0, 0, 0);
FRealLocation := FLocation;
FDefaultLocation := FLocation;
FRealPosition.Import(0, 0);
SetBordersSize(0, 0, 0, 0);
FAlign:=SGAlignNone;
FAnchors:=[];
FVisible:=False;
FVisibleTimer:=0;
FActive:=True;
FActiveTimer:=0;
FCaption:='';
FChildren:=nil;
FCursorOnComponent:=False;
FCursorOnComponentCaption:=False;
FCanHaveChildren:=True;
ComponentProcedure:=nil;
FUserPointer1:=nil;
FUserPointer2:=nil;
FUserPointer3:=nil;
FAnchorsData.FParentHeight:=0;
FAnchorsData.FParentWidth:=0;
end;

procedure TSGComponent.SetBordersSize(const _L, _T, _R, _B : TSGScreenInt);
begin
FBordersSize.Left   := _L;
FBordersSize.Top    := _T;
FBordersSize.Right  := _R;
FBordersSize.Bottom := _B;
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
	else if FParent<>nil then
		begin
		if FAnchorsData.FParentHeight<>FParent.Height then
			begin
			I := FAnchorsData.FParentHeight - FParent.Height;
			FLocation.Top := FLocation.Top - I;
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
	else if FParent<>nil then
		begin
		if FAnchorsData.FParentWidth<>FParent.Width then
			begin
			I:=FAnchorsData.FParentWidth-FParent.Width;
			FLocation.Left := FLocation.Left - I;
			FAnchorsData.FParentWidth:=FParent.Width;
			end;
		end;
	end;
BoundsMakeReal();
{CW:=FLocation.Width;
CH:=FLocation.Height;
case FAlign of
SGAlignRight:
	begin
	FLocation.Left+=Parent.Width-ParentWidth;
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
	FLocation.Left := FDefaultLocation.Left;
if FAlign=SGAlignLeft then
	FLocation.Top := FDefaultLocation.Top;
if FAlign=SGAlignRight then
	FLocation.Top := FDefaultLocation.Top;
if FAlign=SGAlignBottom then
	FLocation.Left := FDefaultLocation.Left;
if FAlign=SGAlignClient then
	begin
	FLocation.Top  := FDefaultLocation.Top;
	FLocation.Left := FDefaultLocation.Left;
	end;
FAlign := SGAlignNone;
FLocation.Height := FDefaultLocation.Height;
FLocation.Width  := FDefaultLocation.Width;
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
	if FRealLocation.Height>FParent.FRealLocation.Height-FParent.FBordersSize.Top-FParent.FBordersSize.Bottom then
		FRealLocation.Height:=FParent.FRealLocation.Height-FParent.FBordersSize.Top-FParent.FBordersSize.Bottom;
	if FRealLocation.Width>FParent.FRealLocation.Width-FParent.FBordersSize.Left-FParent.FBordersSize.Right then
		FRealLocation.Width:=FParent.FRealLocation.Width-FParent.FBordersSize.Left-FParent.FBordersSize.Right;
	if FRealLocation.Top < 0 then
		FRealLocation.Top:=0;
	if FRealLocation.Left < 0 then
		FRealLocation.Left:=0;
	if (FRealLocation.Left+FRealLocation.Width)>FParent.FRealLocation.Width-FParent.RightShift then
		FRealLocation.Left:=FParent.FRealLocation.Width-FRealLocation.Width-FParent.RightShift;
	if (FRealLocation.Top+FRealLocation.Height)>FParent.FRealLocation.Height-FParent.BottomShift then
		FRealLocation.Top:=FParent.FRealLocation.Height-FRealLocation.Height-FParent.BottomShift;
	if FLocation.Top < 0 then
		FLocation.Top := 0;
	if FLocation.Left < 0 then
		FLocation.Left:=0;
	if (FLocation.Left+FLocation.Width)>FParent.FLocation.Width-FParent.RightShift then
		FLocation.Left:=FParent.FLocation.Width-FLocation.Width-FParent.RightShift;
	if (FLocation.Top+FLocation.Height)>FParent.FLocation.Height-FParent.BottomShift then
		FLocation.Top:=FParent.FLocation.Height-FLocation.Height-FParent.BottomShift;
	end;
end;

procedure TSGComponent.SetCaption(const NewCaption : TSGCaption);
begin
FCaption := NewCaption;
end;

procedure TSGComponent.UpDateLocation();
var
	Value, RealValue : TSGComponentLocationInt;
begin
Value := FLocation.Height;
RealValue := FRealLocation.Height;
UpDateValue(RealValue, Value);
FRealLocation.Height := RealValue;

Value := FLocation.Top;
RealValue := FRealLocation.Top;
UpDateValue(RealValue, Value);
FRealLocation.Top := RealValue;

Value := FLocation.Left;
RealValue := FRealLocation.Left;
UpDateValue(RealValue, Value);
FRealLocation.Left := RealValue;

Value := FLocation.Width;
RealValue := FRealLocation.Width;
UpDateValue(RealValue, Value);
FRealLocation.Width := RealValue;
end;

procedure TSGComponent.UpDateObjects();
var
	Component : TSGComponent;
	ValueHeight : TSGScreenInt = 0;
	ValueWidth  : TSGScreenInt = 0;
	ValueLeft   : TSGScreenInt = 0;
	ValueTop    : TSGScreenInt = 0;
begin
if (FParent <> nil) then
	case FAlign of
	SGAlignLeft:
		begin
		FLocation.Position := TSGComponentLocationVectorInt.Create();
		FLocation.Height:=FParent.FRealLocation.Height-FParent.FBordersSize.Top-FParent.FBordersSize.Bottom;
		end;
	SGAlignTop:
		begin
		FLocation.Position := TSGComponentLocationVectorInt.Create();
		FLocation.Width:=FParent.FRealLocation.Width-FParent.FBordersSize.Left-FParent.FBordersSize.Right;
		end;
	SGAlignRight:
		begin
		FLocation.Top := 0;
		FLocation.Left:=FParent.FRealLocation.Width-FParent.FBordersSize.Left-FParent.FBordersSize.Right-FRealLocation.Width;
		FLocation.Height:=FParent.FRealLocation.Height-FParent.FBordersSize.Top-FParent.FBordersSize.Bottom;
		end;
	SGAlignBottom:
		begin
		FLocation.Left := 0;
		FLocation.Width:=FParent.FRealLocation.Width-FParent.FBordersSize.Left-FParent.FBordersSize.Right;
		FLocation.Top:=FParent.FRealLocation.Height-FParent.FBordersSize.Top-FParent.FBordersSize.Bottom-FRealLocation.Height;
		end;
	SGAlignClient:
		begin
		FLocation.Position := TSGComponentLocationVectorInt.Create();
		FLocation.Width:=FParent.FRealLocation.Width-FParent.FBordersSize.Left-FParent.FBordersSize.Right;
		FLocation.Height:=FParent.FRealLocation.Height-FParent.FBordersSize.Top-FParent.FBordersSize.Bottom;
		end;
	SGAlignNone: begin end;
	else begin end;
	end;
ValueTop    := FRealLocation.Top;
ValueHeight := FRealLocation.Height;
ValueWidth  := FRealLocation.Width;
ValueLeft   := FRealLocation.Left;
UpDateLocation();
TestCoords();
ValueHeight := FRealLocation.Height - ValueHeight;
ValueLeft   := FRealLocation.Left   - ValueLeft;
ValueTop    := FRealLocation.Top    - ValueTop;
ValueWidth  := FRealLocation.Width  - ValueWidth;
for Component in Self do
	begin
	Component.FRealLocation.Top    := Component.FRealLocation.Top    - ValueTop;
	Component.FRealLocation.Width  := Component.FRealLocation.Width  - ValueWidth;
	Component.FRealLocation.Height := Component.FRealLocation.Height - ValueHeight;
	Component.FRealLocation.Left   := Component.FRealLocation.Left   - ValueLeft;
	end;
if (FParent <> nil) then
	FRealPosition := FParent.FRealPosition + FRealLocation.Position + TSGComponentLocationVectorInt.Create(FParent.FBordersSize.Left, FParent.FBordersSize.Top);
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

end.
