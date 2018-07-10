{$INCLUDE SaGe.inc}

unit SaGeScreenCustomComponent;

interface

uses
	 SaGeBase
	,SaGeScreenBase
	,SaGeBaseClasses
	,SaGeCommonStructs
	,SaGeBaseContextInterface
	;
type
	TSGScreenCustomComponent = class;
	
	// for-in loop enumerator class
	TSGScreenCustomComponentEnumerator = class
			protected
		FComponent : TSGScreenCustomComponent;
		FCurrent   : TSGScreenCustomComponent;
		FIndex     : TSGMaxEnum;
			public
		constructor Create(const VComponent : TSGScreenCustomComponent); virtual;
		function MoveNext(): TSGBoolean; virtual;abstract;
		function GetEnumerator() : TSGScreenCustomComponentEnumerator;virtual;
		property Current: TSGScreenCustomComponent read FCurrent;
		end;
	TSGScreenCustomComponentEnumeratorNormal = class(TSGScreenCustomComponentEnumerator)
			public
		constructor Create(const VComponent : TSGScreenCustomComponent); override;
		function MoveNext(): TSGBoolean; override;
		end;
	TSGScreenCustomComponentEnumeratorReverse = class(TSGScreenCustomComponentEnumerator)
			public
		constructor Create(const VComponent : TSGScreenCustomComponent); override;
		function MoveNext(): TSGBoolean; override;
		end;

	PSGScreenCustomComponent = ^ TSGScreenCustomComponent;
	TSGScreenCustomComponentList      = packed array of TSGScreenCustomComponent;
	TSGScreenCustomComponentListList  = packed array of TSGScreenCustomComponentList;
	TSGScreenCustomComponentProcedure = procedure (Component : TSGScreenCustomComponent);
	TSGScreenCustomComponent          = class(TSGOptionGetSeter, ISGCustomComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
			public
			// for-in loop
		function GetEnumerator(): TSGScreenCustomComponentEnumerator;
		function GetReverseEnumerator: TSGScreenCustomComponentEnumerator;
			public
		procedure DeleteRenderResources(); virtual;
		procedure LoadRenderResources(); virtual;
		function Suppored() : TSGBoolean;virtual;
		procedure Paint(); virtual;
		procedure Resize(); virtual;
			protected
		FLocation : TSGComponentLocation;
		FRealLocation : TSGComponentLocation;
		FDefaultLocation : TSGComponentLocation;
		FRealPosition : TSGComponentLocationVectorInt;
		FBordersSize : TSGComponentBoundsSize;
		FUnLimited : TSGBoolean;
		FParent    : TSGScreenCustomComponent;
		
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
		
		procedure UpDateLocation(const ElapsedTime : TSGTimerInt);
		function UpDateValue(var RealObj, Obj : TSGComponentLocationInt; const ElapsedTime : TSGTimerInt) : TSGComponentLocationInt;
		procedure UpDateObjects();virtual;
		procedure TestCoords();virtual;
			public
		property Width        : TSGAreaInt   read GetWidth write SetWidth;
		property Height       : TSGAreaInt   read GetHeight write SetHeight;
		property Left         : TSGAreaInt   read GetLeft write SetLeft;
		property Top          : TSGAreaInt   read GetTop write SetTop;
		property Parent       : TSGScreenCustomComponent read FParent write FParent;
		property Bottom       : TSGScreenInt read GetBottom write SetBottom;
		property Right        : TSGScreenInt read GetRight write SetRight;
		property ScreenWidth  : TSGScreenInt read GetScreenWidth;
		property ScreenHeight : TSGScreenInt read GetScreenHeight;
		property UnLimited    : TSGBoolean   read FUnLimited write FUnLimited;
		property BoundsSize   : TSGComponentBoundsSize read FBordersSize;
		property RealPosition : TSGComponentLocationVectorInt read FRealPosition;
		property Location     : TSGComponentLocation read GetLocation;
		property RealLocation : TSGComponentLocation read FRealLocation write FRealLocation;
			public
		procedure BoundsMakeReal();virtual;
		procedure SetBordersSize(const _L, _T, _R, _B : TSGScreenInt);virtual;
		procedure SetBounds(const NewLeft, NewTop, NewWidth, NewHeight : TSGScreenInt);virtual;
		procedure SetBoundsFloat(const NewLeft, NewTop, NewWidth, NewHeight : TSGScreenFloat);
		procedure SetMiddleBounds(const NewWidth, NewHeight : TSGScreenInt);virtual;
		procedure WriteBounds();
		class function RandomOne() : TSGInt8;
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
		procedure UpgradeTimers(const ElapsedTime : TSGTimerInt);virtual;
		procedure UpgradeTimer(const Flag : TSGBoolean; var Timer : TSGScreenTimer; const ElapsedTime : TSGTimerInt; const Factor1 : TSGInt16 = 1; const Factor2 : TSGFloat32 = 1);
			protected
		procedure FromUpDate();virtual;
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
		property Visible      : Boolean       read FVisible      write SetVisible;
		property Active       : Boolean       read FActive       write FActive default False;
		property Anchors      : TSGSetOfByte  read FAnchors      write FAnchors;
			protected
		FChildren:TSGScreenCustomComponentList;
		FCursorOverComponent:Boolean;
		FCursorOverComponentCaption:Boolean;
		FCanHaveChildren:Boolean;
		FComponentProcedure:TSGScreenCustomComponentProcedure;
		FChildrenPriority : TSGMaxEnum;
		FMarkedForDestroy : TSGBoolean;
			public
		function HasChildren() : TSGBoolean;virtual;
		function ChildCount() : TSGUInt32;virtual;
		procedure ClearPriority();
		procedure MakePriority();
		function GetPriorityComponent() : TSGScreenCustomComponent;
		function CursorInComponentCaption():boolean;virtual;
		function GetVertex(const THAT:TSGSetOfByte;const FOR_THAT:TSGByte): TSGPoint2int32;
		function BottomShift():TSGScreenInt;
		function RightShift():TSGScreenInt;
		procedure ChildToListEnd(const Index : TSGMaxEnum);
		procedure ChildToListEnd(const Component : TSGScreenCustomComponent);
			public
		procedure ToFront();
		function MustBeDestroyed() : TSGBoolean;
		procedure MarkForDestroy();
		function GetChild(a:TSGInt32):TSGScreenCustomComponent;
		function CreateChild(const Child : TSGScreenCustomComponent) : TSGScreenCustomComponent;
		procedure CompleteChild(const VChild : TSGScreenCustomComponent); virtual;
		function LastChild():TSGScreenCustomComponent;
		procedure CreateAlign(const NewAllign:TSGByte);
		procedure DestroyAlign();
		procedure DestroyParent();
		procedure KillChildren();
		procedure VisibleAll();
		function IndexOf(const VComponent : TSGScreenCustomComponent): TSGLongInt;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetChildrenCount() : TSGUInt32;
			public
		property Children[Index : TSGInt32 (* Indexing [1..Size] *)]:TSGScreenCustomComponent read GetChild;
		property ChildrenCount : TSGUInt32 read GetChildrenCount;
		property MarkedForDestroy : TSGBoolean read FMarkedForDestroy;
		property Align : TSGByte read FAlign write CreateAlign;
		property ChildrenPriority : TSGMaxEnum write FChildrenPriority;
		property ComponentProcedure : TSGScreenCustomComponentProcedure read FComponentProcedure write FComponentProcedure;
		property CursorOnComponent : Boolean read FCursorOverComponent write FCursorOverComponent;
		property CursorOnComponentCaption : Boolean read FCursorOverComponentCaption write FCursorOverComponentCaption;
			public
		OnChange : TSGScreenCustomComponentProcedure ;
		FUserPointer1, FUserPointer2, FUserPointer3 : Pointer;
			public
		property UserPointer : Pointer read FUserPointer1 write FUserPointer1;
		end;
	
	ISGScreenObject = interface(ISGInterface)
		['{bed22c55-1611-4358-bfab-9596302ee968}']
		function GetScreen() : TSGScreenCustomComponent;
		
		property Screen : TSGScreenCustomComponent read GetScreen;
		end;

implementation

uses
	 SaGeCommon
	,SaGeMathUtils
	,SaGeContextUtils
	;

function TSGScreenCustomComponent.GetChildrenCount() : TSGUInt32;
begin
Result := 0;
if (FChildren <> nil) then
	Result := Length(FChildren);
end;

class function TSGScreenCustomComponent.ClassName() : TSGString;
begin
Result := 'TSGScreenCustomComponent';
end;

function TSGScreenCustomComponent.GetActive() : TSGBoolean;
begin
Result := FActive;
end;

function TSGScreenCustomComponent.GetVisible() : TSGBoolean;
begin
Result := FVisible;
end;

function TSGScreenCustomComponent.HasChildren() : TSGBoolean;
begin
Result := False;
if FChildren <> nil then
	if Length(FChildren) > 0 then
		Result := True;
end;

procedure TSGScreenCustomComponent.ChildToListEnd(const Component : TSGScreenCustomComponent);
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

procedure TSGScreenCustomComponent.ChildToListEnd(const Index : TSGMaxEnum);
var
	i : TSGMaxEnum;
	Component : TSGScreenCustomComponent;
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

function TSGScreenCustomComponent.ChildCount() : TSGUInt32;
begin
if not HasChildren() then
	Result := 0
else
	Result := Length(FChildren);
end;

function TSGScreenCustomComponent.GetVisibleTimer() : TSGScreenTimer;
begin
Result := FVisibleTimer;
end;

function TSGScreenCustomComponent.GetActiveTimer() : TSGScreenTimer;
begin
Result := FActiveTimer;
end;

function  TSGScreenCustomComponent.GetTitle() : TSGString;
begin
Result := FCaption;
end;

procedure TSGScreenCustomComponent.SetTitle(const VTitle : TSGString);
begin
FCaption := VTitle;
end;

function  TSGScreenCustomComponent.GetWidth() : TSGAreaInt;
begin
Result := FLocation.Size.x;
end;

function  TSGScreenCustomComponent.GetHeight() : TSGAreaInt;
begin
Result := FLocation.Size.y;
end;

procedure TSGScreenCustomComponent.SetWidth(const VWidth : TSGAreaInt);
begin
FLocation.Width := VWidth;
end;

procedure TSGScreenCustomComponent.SetHeight(const VHeight : TSGAreaInt);
begin
FLocation.Height := VHeight;
end;

function  TSGScreenCustomComponent.GetLeft() : TSGAreaInt;
begin
Result := FLocation.Position.x;
end;

function  TSGScreenCustomComponent.GetTop() : TSGAreaInt;
begin
Result := FLocation.Position.y;
end;

procedure TSGScreenCustomComponent.SetLeft(const VLeft : TSGAreaInt);
begin
FLocation.Left := VLeft;
end;

procedure TSGScreenCustomComponent.SetTop(const VTop : TSGAreaInt);
begin
FLocation.Top := VTop;
end;

function TSGScreenCustomComponent.GetLocation() : TSGComponentLocation;
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

procedure TSGScreenCustomComponent.ToFront();
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

procedure TSGScreenCustomComponent.Resize();
var
	I : TSGLongInt;
	Component : TSGScreenCustomComponent;
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
	Component.Resize();
end;

function TSGScreenCustomComponent.NotVisible:boolean;
begin
Result := FVisibleTimer < SGZero;
end;

function TSGScreenCustomComponent.IndexOf(const VComponent : TSGScreenCustomComponent ): TSGLongInt;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

procedure TSGScreenCustomComponent.VisibleAll;
var
	Component : TSGScreenCustomComponent;
begin
FVisibleTimer := 1;
for Component in Self do
	Component.VisibleAll();
end;

procedure TSGScreenCustomComponent.KillChildren();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

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

procedure TSGScreenCustomComponent.BoundsMakeReal;
begin
FRealLocation := FLocation;
end;

procedure TSGScreenCustomComponent.WriteBounds;
begin
FLocation.Write('Location ');
end;

procedure TSGScreenCustomComponent.SetMiddleBounds(const NewWidth,NewHeight:LongInt);
var
	PW, PH : TSGLongWord;
begin
FLocation.Height := NewHeight;
FLocation.Width  := NewWidth;
if (Parent <> nil) then
	begin
	PW := Parent.Width;
	PH := Parent.Height;
	FLocation.Left := Round((PW-NewWidth)/2);
	FLocation.Top  := Round((PH-NewHeight)/2);
	end
else
	begin
	FLocation.Left := 0;
	FLocation.Top := 0;
	end;
end;

procedure TSGScreenCustomComponent.SetVisible(const b:Boolean);
var
	Component : TSGScreenCustomComponent;
begin
FVisible := b;
for Component in Self do
	Component.Visible := Visible;
end;

function TSGScreenCustomComponent.GetChild(a:TSGInt32):TSGScreenCustomComponent;
begin
if (a-1 >= 0) and (a-1<=High(FChildren)) then
	Result:=FChildren[a-1]
else
	Result:=nil;
end;

function TSGScreenCustomComponent.GetScreenWidth : longint;
begin
if (FParent <> nil) then
	Result := FParent.Width
else
	Result := Width;
end;

function TSGScreenCustomComponent.GetScreenHeight : longint;
begin
if (FParent <> nil) then
	Result := FParent.Height
else
	Result := Height;
end;

procedure TSGScreenCustomComponent.SetRight(NewRight:TSGScreenInt);
begin
Left:=ScreenWidth-Width-NewRight;
end;

procedure TSGScreenCustomComponent.SetBottom(NewBottom:TSGScreenInt);
begin
Top:=ScreenHeight-Height-NewBottom;
end;

function TSGScreenCustomComponent.GetRight:TSGScreenInt;
begin
Result:=ScreenWidth-Width-Left;
end;

function TSGScreenCustomComponent.GetBottom : TSGScreenInt;
begin
Result:=ScreenHeight-Height-Top;
end;

function TSGScreenCustomComponent.BottomShift:TSGScreenInt;
begin
Result := FBordersSize.Top + FBordersSize.Bottom;
end;

function TSGScreenCustomComponent.RightShift:TSGScreenInt;
begin
Result := FBordersSize.Left + FBordersSize.Right;
end;

function TSGScreenCustomComponent.LastChild:TSGScreenCustomComponent;
begin
Result:=Nil;
if FChildren <> nil then
	Result := FChildren[High(FChildren)];
end;

function TSGScreenCustomComponent.UpDateValue(var RealObj, Obj : TSGComponentLocationInt; const ElapsedTime : TSGTimerInt) : TSGComponentLocationInt;
const
	Speed = 2;
var
	Value : TSGComponentLocationInt = 0;
	OldValue : TSGComponentLocationInt;
begin
if (RealObj <> Obj) then
	begin
	OldValue:=RealObj;
	Value:=Round((Obj * ElapsedTime / Speed + RealObj * 5) / (5 + ElapsedTime / Speed));
	Result:=Value-RealObj;
	RealObj:=Value;
	if (RealObj=OldValue) and (Obj<>RealObj) then
		if Obj>RealObj then
			RealObj+=1
		else
			RealObj-=1;
	end;
end;

procedure TSGScreenCustomComponent.SetBoundsFloat(const NewLeft, NewTop, NewWidth, NewHeight : TSGScreenFloat);
begin
SetBounds(Round(NewLeft), Round(NewTop), Round(NewWidth), Round(NewHeight));
end;

procedure TSGScreenCustomComponent.SetBounds(const NewLeft, NewTop, NewWidth, NewHeight : TSGScreenInt);
var
	IsLocationNull : TSGBoolean;
begin
IsLocationNull := (FLocation.Left = 0) and (FLocation.Top = 0) and (FLocation.Width = 0) and (FLocation.Height = 0);
FLocation.Left := NewLeft;
FLocation.Top := NewTop;
FLocation.Width := NewWidth;
FLocation.Height := NewHeight;
if IsLocationNull then
	FRealLocation := FLocation;
FDefaultLocation := FLocation;
end;

class function TSGScreenCustomComponent.RandomOne() : TSGInt8;
begin
Result := 0;
Result := Random(2);
if (Result = 0) then
	Result := -1;
end;

procedure TSGScreenCustomComponent.UpgradeTimer(const Flag : TSGBoolean; var Timer : TSGScreenTimer; const ElapsedTime : TSGTimerInt; const Factor1 : TSGInt16 = 1; const Factor2 : TSGFloat32 = 1);
var
	GeneralFactor : TSGFloat32;
begin
GeneralFactor := SGObjectTimerConst * Factor1 * ElapsedTime;
if Flag then
	begin
	Timer += GeneralFactor * Factor2;
	if (Timer > 1) then
		Timer := 1;
	end
else
	begin
	Timer -= GeneralFactor * (1 / Factor2);
	if (Timer < 0) then
		Timer := 0;
	end;
end;

function TSGScreenCustomComponent.ReqursiveActive():Boolean;
begin
if (not FActive) or (FParent = nil) then
	Result := FActive
else
	Result := FParent.ReqursiveActive();
end;

procedure TSGScreenCustomComponent.UpgradeTimers(const ElapsedTime : TSGTimerInt);
begin
UpgradeTimer(FVisible, FVisibleTimer, ElapsedTime);
UpgradeTimer(FActive and ReqursiveActive, FActiveTimer, ElapsedTime);
end;

// Deleted self in parent
procedure TSGScreenCustomComponent.DestroyParent;
var
	ii, i : TSGLongInt;
begin
{$IFDEF SGMoreDebuging}
	if FParent<>nil then
		WriteLn('Begin of  "TSGScreenCustomComponent.DestroyParent" ( Length='+SGStr(Length(FParent.FChildren))+' ).')
	else
		WriteLn('Begin of  "TSGScreenCustomComponent.DestroyParent" ( Parent=nil ).');
	{$ENDIF}
if FParent<>nil then
	begin
	ii := FParent.IndexOf(Self);
	if ii <> -1 then
		begin
		if ii + 1 = FParent.FChildrenPriority then
			ClearPriority();
		{$IFDEF SGMoreDebuging}
			WriteLn('"TSGScreenCustomComponent.DestroyParent" :  Find Self on '+SGStr(ii+1)+' position .');
			{$ENDIF}
		if ii < High(FParent.FChildren) then
			for i:= ii to High(FParent.FChildren) - 1 do
				FParent.FChildren[i] := FParent.FChildren[i + 1];
		SetLength(FParent.FChildren, Length(FParent.FChildren) - 1);
		end;
	end;
{$IFDEF SGMoreDebuging}
	if FParent<>nil then
		WriteLn('End of  "TSGScreenCustomComponent.DestroyParent" ( Length='+SGStr(Length(FParent.FChildren))+' ).')
	else
		WriteLn('End of  "TSGScreenCustomComponent.DestroyParent" ( Parent=nil ).');
	{$ENDIF}
end;

destructor TSGScreenCustomComponent.Destroy();
begin
KillChildren();
DestroyParent();
inherited;
end;

function TSGScreenCustomComponent.GetVertex(const THAT:TSGSetOfByte;const FOR_THAT:TSGByte): TSGPoint2int32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

procedure TSGScreenCustomComponent.CompleteChild(const VChild : TSGScreenCustomComponent);
var
	Component : TSGScreenCustomComponent;
begin
if VChild.Parent = nil then
	VChild.Parent := Self;
for Component in VChild do
	VChild.CompleteChild(Component);
end;

function TSGScreenCustomComponent.CreateChild(const Child : TSGScreenCustomComponent) : TSGScreenCustomComponent;
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

procedure TSGScreenCustomComponent.AddToTop(const Value : TSGScreenInt);
begin
FLocation.Top := FLocation.Top + Value;
end;

procedure TSGScreenCustomComponent.AddToLeft(const Value : TSGScreenInt);
begin
FLocation.Left := FLocation.Left + Value;
end;

procedure TSGScreenCustomComponent.AddToWidth(const Value : TSGScreenInt);
begin
FLocation.Width := FLocation.Width + Value;
end;

procedure TSGScreenCustomComponent.AddToHeight(const Value : TSGScreenInt);
begin
FLocation.Height := FLocation.Height + Value;
end;

procedure TSGScreenCustomComponent.FromUpDate();
var
	PriorityComponent, Component : TSGScreenCustomComponent;
	Index : TSGLongWord;
begin
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreenCustomComponent__FromUpDate: Begining');
	{$ENDIF}

UpDateObjects();

PriorityComponent := GetPriorityComponent();
if PriorityComponent <> nil then
	PriorityComponent.FromUpDate();

Index := 0;
while Index < Length(FChildren) do
	begin
	Component := FChildren[Index];
	if Component.MustBeDestroyed() then
		Component.Destroy()
	else
		begin
		if Component <> PriorityComponent then
			Component.FromUpDate();
		Index += 1;
		end;
	end;

if (FComponentProcedure <> nil) then
	FComponentProcedure(Self);
end;

procedure TSGScreenCustomComponent.DeleteRenderResources();
var
	Component : TSGScreenCustomComponent;
begin
for Component in Self do
	Component.DeleteRenderResources();
end;

procedure TSGScreenCustomComponent.LoadRenderResources();
var
	Component : TSGScreenCustomComponent;
begin
for Component in Self do
	Component.LoadRenderResources();
end;

function TSGScreenCustomComponent.Suppored() : TSGBoolean;
begin
Result := True;
end;

function TSGScreenCustomComponent.GetEnumerator(): TSGScreenCustomComponentEnumerator;
begin
Result := TSGScreenCustomComponentEnumeratorNormal.Create(Self);
end;

function TSGScreenCustomComponent.GetReverseEnumerator(): TSGScreenCustomComponentEnumerator;
begin
Result := TSGScreenCustomComponentEnumeratorReverse.Create(Self);
end;

procedure TSGScreenCustomComponent.Paint();
var
	Component, PriorityComponent : TSGScreenCustomComponent;
begin
PriorityComponent := GetPriorityComponent();
if PriorityComponent = nil then
	for Component in Self do
		Component.Paint()
else
	begin
	for Component in Self do
		if Component <> PriorityComponent then
			Component.Paint();
	PriorityComponent.Paint();
	end;
end;

procedure TSGScreenCustomComponent.ClearPriority();
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

function TSGScreenCustomComponent.MustBeDestroyed() : TSGBoolean;
begin
Result := FMarkedForDestroy and (FVisibleTimer < SGZero) and (FActiveTimer < SGZero);
end;

procedure TSGScreenCustomComponent.MakePriority();
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

procedure TSGScreenCustomComponent.MarkForDestroy();
begin
Active := False;
Visible := False;
FMarkedForDestroy := True;
end;

constructor TSGScreenCustomComponent.Create();
begin
inherited Create();
FMarkedForDestroy := False;
FChildrenPriority:=0;
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
FCursorOverComponent:=False;
FCursorOverComponentCaption:=False;
FCanHaveChildren:=True;
ComponentProcedure:=nil;
FUserPointer1:=nil;
FUserPointer2:=nil;
FUserPointer3:=nil;
FAnchorsData.FParentHeight:=0;
FAnchorsData.FParentWidth:=0;
end;

procedure TSGScreenCustomComponent.SetBordersSize(const _L, _T, _R, _B : TSGScreenInt);
begin
FBordersSize.Left   := _L;
FBordersSize.Top    := _T;
FBordersSize.Right  := _R;
FBordersSize.Bottom := _B;
end;

function TSGScreenCustomComponent.GetPriorityComponent() : TSGScreenCustomComponent;
begin
Result := nil;
if (FChildrenPriority > 0) and (FChildren <> nil) then
	if FChildrenPriority <= Length(FChildren) then
		Result := FChildren[FChildrenPriority - 1];
end;

function TSGScreenCustomComponent.CursorInComponentCaption():boolean;
begin
Result:=False;
end;

procedure TSGScreenCustomComponent.DestroyAlign;
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

procedure TSGScreenCustomComponent.CreateAlign(const NewAllign:TSGByte);
begin
FAlign:=NewAllign;
end;

procedure TSGScreenCustomComponent.TestCoords;
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

procedure TSGScreenCustomComponent.SetCaption(const NewCaption : TSGCaption);
begin
FCaption := NewCaption;
end;

procedure TSGScreenCustomComponent.UpDateLocation(const ElapsedTime : TSGTimerInt);
var
	Value, RealValue : TSGComponentLocationInt;
begin
Value := FLocation.Height;
RealValue := FRealLocation.Height;
UpDateValue(RealValue, Value, ElapsedTime);
FRealLocation.Height := RealValue;

Value := FLocation.Top;
RealValue := FRealLocation.Top;
UpDateValue(RealValue, Value, ElapsedTime);
FRealLocation.Top := RealValue;

Value := FLocation.Left;
RealValue := FRealLocation.Left;
UpDateValue(RealValue, Value, ElapsedTime);
FRealLocation.Left := RealValue;

Value := FLocation.Width;
RealValue := FRealLocation.Width;
UpDateValue(RealValue, Value, ElapsedTime);
FRealLocation.Width := RealValue;
end;

procedure TSGScreenCustomComponent.UpDateObjects();
var
	Component : TSGScreenCustomComponent;
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
if (FParent <> nil) then
	FRealPosition := FParent.FRealPosition + FRealLocation.Position + TSGComponentLocationVectorInt.Create(FParent.FBordersSize.Left, FParent.FBordersSize.Top);
end;

// ==========================
// =======Enumerators========
// ==========================

constructor TSGScreenCustomComponentEnumerator.Create(const VComponent : TSGScreenCustomComponent);
begin
inherited Create();
FComponent := VComponent;
FCurrent := nil;
end;

function TSGScreenCustomComponentEnumerator.GetEnumerator() : TSGScreenCustomComponentEnumerator;
begin
Result := Self;
end;

constructor TSGScreenCustomComponentEnumeratorNormal.Create(const VComponent : TSGScreenCustomComponent);
begin
inherited Create(VComponent);
FIndex := 0;
end;

constructor TSGScreenCustomComponentEnumeratorReverse.Create(const VComponent : TSGScreenCustomComponent);
begin
inherited Create(VComponent);
FIndex := Length(VComponent.FChildren) + 1;
end;

function TSGScreenCustomComponentEnumeratorNormal.MoveNext(): TSGBoolean;
begin
FIndex += 1;
if (FIndex >= 1) and (FIndex <= Length(FComponent.FChildren)) then
	FCurrent := FComponent.Children[FIndex]
else
	FCurrent := nil;
Result := FCurrent <> nil;
end;

function TSGScreenCustomComponentEnumeratorReverse.MoveNext(): TSGBoolean;
begin
FIndex -= 1;
if (FIndex >= 1) and (FIndex <= Length(FComponent.FChildren)) then
	FCurrent := FComponent.Children[FIndex]
else
	FCurrent := nil;
Result := FCurrent <> nil;
end;

end.
