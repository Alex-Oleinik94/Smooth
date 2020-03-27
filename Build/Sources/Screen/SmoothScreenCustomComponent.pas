{$INCLUDE Smooth.inc}

unit SmoothScreenCustomComponent;

interface

uses
	 SmoothBase
	,SmoothScreenBase
	,SmoothBaseClasses
	,SmoothCommonStructs
	,SmoothBaseContextInterface
	;
type
	TSScreenCustomComponent = class;
	
	// for-in loop enumerator class
	TSScreenCustomComponentEnumerator = class
			protected
		FComponent : TSScreenCustomComponent;
		FCurrent   : TSScreenCustomComponent;
		FIndex     : TSMaxEnum;
			public
		constructor Create(const VComponent : TSScreenCustomComponent); virtual;
		function MoveNext(): TSBoolean; virtual;abstract;
		function GetEnumerator() : TSScreenCustomComponentEnumerator;virtual;
		property Current: TSScreenCustomComponent read FCurrent;
		end;
	TSScreenCustomComponentEnumeratorNormal = class(TSScreenCustomComponentEnumerator)
			public
		constructor Create(const VComponent : TSScreenCustomComponent); override;
		function MoveNext(): TSBoolean; override;
		end;
	TSScreenCustomComponentEnumeratorReverse = class(TSScreenCustomComponentEnumerator)
			public
		constructor Create(const VComponent : TSScreenCustomComponent); override;
		function MoveNext(): TSBoolean; override;
		end;

	PSScreenCustomComponent = ^ TSScreenCustomComponent;
	TSScreenCustomComponentList      = packed array of TSScreenCustomComponent;
	TSScreenCustomComponentListList  = packed array of TSScreenCustomComponentList;
	TSScreenCustomComponentProcedure = procedure (Component : TSScreenCustomComponent);
	TSScreenCustomComponent          = class(TSOptionGetSeter, ISCustomComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSString; override;
			public
			// for-in loop
		function GetEnumerator(): TSScreenCustomComponentEnumerator;
		function GetReverseEnumerator: TSScreenCustomComponentEnumerator;
			public
		procedure DeleteRenderResources(); virtual;
		procedure LoadRenderResources(); virtual;
		function Suppored() : TSBoolean;virtual;
		procedure Paint(); virtual;
		procedure Resize(); virtual;
			protected
		FLocation : TSComponentLocation;
		FRealLocation : TSComponentLocation;
		FDefaultLocation : TSComponentLocation;
		FRealPosition : TSComponentLocationVectorInt;
		FBordersSize : TSComponentBordersSize;
		FUnLimited : TSBoolean;
		FParent    : TSScreenCustomComponent;
		
		procedure SetRight (NewRight  : TSScreenInt);virtual;
		procedure SetBottom(NewBottom : TSScreenInt);virtual;
		function GetRight()  : TSScreenInt;virtual;
		function GetBottom() : TSScreenInt;virtual;

		function  GetTitle() : TSString;virtual;
		procedure SetTitle(const VTitle : TSString);virtual;
		function  GetWidth() : TSAreaInt;virtual;
		function  GetHeight() : TSAreaInt;virtual;
		procedure SetWidth(const VWidth : TSAreaInt);virtual;
		procedure SetHeight(const VHeight : TSAreaInt);virtual;
		function  GetLeft() : TSAreaInt;virtual;
		function  GetTop() : TSAreaInt;virtual;
		procedure SetLeft(const VLeft : TSAreaInt);virtual;
		procedure SetTop(const VTop : TSAreaInt);virtual;
		
		function GetScreenWidth()  : TSScreenInt; virtual;
		function GetScreenHeight() : TSScreenInt; virtual;
		function GetLocation() : TSComponentLocation; virtual;
		function GetChildLocation() : TSComponentLocation; virtual;
		function GetBordersSize() : TSComponentBordersSize; virtual;
		
		procedure UpDateLocation(const ElapsedTime : TSTimerInt);
		function UpDateValue(var RealObj, Obj : TSComponentLocationInt; const ElapsedTime : TSTimerInt) : TSComponentLocationInt;
		procedure UpDateObjects();virtual;
		procedure TestCoords();virtual;
			public
		property Width        : TSAreaInt   read GetWidth write SetWidth;
		property Height       : TSAreaInt   read GetHeight write SetHeight;
		property Left         : TSAreaInt   read GetLeft write SetLeft;
		property Top          : TSAreaInt   read GetTop write SetTop;
		property Parent       : TSScreenCustomComponent read FParent write FParent;
		property Bottom       : TSScreenInt read GetBottom write SetBottom;
		property Right        : TSScreenInt read GetRight write SetRight;
		property ScreenWidth  : TSScreenInt read GetScreenWidth;
		property ScreenHeight : TSScreenInt read GetScreenHeight;
		property UnLimited    : TSBoolean   read FUnLimited write FUnLimited;
		property BordersSize  : TSComponentBordersSize read GetBordersSize;
		property RealPosition : TSComponentLocationVectorInt read FRealPosition;
		property Location     : TSComponentLocation read GetLocation;
		property ChildLocation: TSComponentLocation read GetChildLocation;
		property RealLocation : TSComponentLocation read FRealLocation write FRealLocation;
			public
		procedure BoundsMakeReal();virtual;
		procedure SetBordersSize(const _L, _T, _R, _B : TSScreenInt);virtual;
		procedure SetBounds(const NewLeft, NewTop, NewWidth, NewHeight : TSScreenInt);virtual;
		procedure SetBoundsFloat(const NewLeft, NewTop, NewWidth, NewHeight : TSScreenFloat);
		procedure SetMiddleBounds(const NewWidth, NewHeight : TSScreenInt);virtual;
		procedure WriteBounds();
		class function RandomOne() : TSInt8;
		procedure AddToLeft(const Value : TSScreenInt);
		procedure AddToWidth(const Value : TSScreenInt);
		procedure AddToHeight(const Value : TSScreenInt);
		procedure AddToTop(const Value : TSScreenInt);
			protected
		FAlign:TSByte;
		FAnchors:TSSetOfByte;
		FAnchorsData:packed record
			FParentWidth,FParentHeight:TSScreenInt;
			end;
		FVisible : TSBoolean;
		FVisibleTimer : TSScreenTimer;
		FActive : TSBoolean;
		FActiveTimer  : TSScreenTimer;
		FCaption : TSCaption;
		procedure UpgradeTimers(const ElapsedTime : TSTimerInt);virtual;
		procedure UpgradeTimer(const Flag : TSBoolean; var Timer : TSScreenTimer; const ElapsedTime : TSTimerInt; const Factor1 : TSInt16 = 1; const Factor2 : TSFloat32 = 1);
			protected
		procedure UpDate();virtual;
			protected
		procedure SetVisible(const b:Boolean);virtual;
		procedure SetCaption(const NewCaption : TSCaption);virtual;
			public
		function ReqursiveActive():Boolean;
		function NotVisible : TSBoolean;virtual;
		function GetVisibleTimer() : TSScreenTimer;virtual;
		function GetActiveTimer() : TSScreenTimer;virtual;
		function GetActive() : TSBoolean;
		function GetVisible() : TSBoolean;
			public
		property VisibleTimer : TSScreenTimer     read FVisibleTimer write FVisibleTimer;
		property ActiveTimer  : TSScreenTimer     read FActiveTimer  write FActiveTimer;
		property Caption      : TSCaption    read FCaption      write FCaption;
		property Text         : TSCaption    read FCaption      write FCaption;
		property Visible      : Boolean       read FVisible      write SetVisible;
		property Active       : Boolean       read FActive       write FActive default False;
		property Anchors      : TSSetOfByte  read FAnchors      write FAnchors;
			protected
		FChildren:TSScreenCustomComponentList;
		FCanHaveChildren:Boolean;
		FComponentProcedure:TSScreenCustomComponentProcedure;
		FChildrenPriority : TSMaxEnum;
		FMarkedForDestroy : TSBoolean;
			public
		function HasChildren() : TSBoolean;virtual;
		function ChildCount() : TSUInt32;virtual;
		procedure ClearPriority();
		procedure MakePriority();
		function GetPriorityComponent() : TSScreenCustomComponent;
		function CursorInComponentCaption():boolean;virtual;
		function GetVertex(const THAT:TSSetOfByte;const FOR_THAT:TSByte): TSPoint2int32;
		function BottomShift():TSScreenInt;
		function RightShift():TSScreenInt;
		procedure ChildToListEnd(const Index : TSMaxEnum);
		procedure ChildToListEnd(const Component : TSScreenCustomComponent);
			public
		procedure ToFront();
		function MustBeDestroyed() : TSBoolean;
		procedure MarkForDestroy();
		function GetChild(a:TSInt32):TSScreenCustomComponent;
		function CreateChild(const Child : TSScreenCustomComponent) : TSScreenCustomComponent;
		procedure CompleteChild(const VChild : TSScreenCustomComponent); virtual;
		function LastChild():TSScreenCustomComponent;
		procedure CreateAlign(const NewAllign:TSByte);
		procedure DestroyAlign();
		procedure DestroyParent();
		procedure KillChildren();
		procedure VisibleAll();
		function IndexOf(const VComponent : TSScreenCustomComponent): TSLongInt;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetChildrenCount() : TSUInt32;
			public
		property Children[Index : TSInt32 (* Indexing [1..Size] *)]:TSScreenCustomComponent read GetChild;
		property ChildrenCount : TSUInt32 read GetChildrenCount;
		property MarkedForDestroy : TSBoolean read FMarkedForDestroy;
		property Align : TSByte read FAlign write CreateAlign;
		property ChildrenPriority : TSMaxEnum write FChildrenPriority;
		property ComponentProcedure : TSScreenCustomComponentProcedure read FComponentProcedure write FComponentProcedure;
			public
		OnChange : TSScreenCustomComponentProcedure ;
		FUserPointer1, FUserPointer2, FUserPointer3 : Pointer;
			public
		property UserPointer : Pointer read FUserPointer1 write FUserPointer1;
		end;
	
	ISScreenObject = interface(ISInterface)
		['{bed22c55-1611-4358-bfab-9596302ee968}']
		function GetScreen() : TSScreenCustomComponent;
		
		property Screen : TSScreenCustomComponent read GetScreen;
		end;

implementation

uses
	 SmoothCommon
	,SmoothMathUtils
	,SmoothContextUtils
	;

function TSScreenCustomComponent.GetChildrenCount() : TSUInt32;
begin
Result := 0;
if (FChildren <> nil) then
	Result := Length(FChildren);
end;

class function TSScreenCustomComponent.ClassName() : TSString;
begin
Result := 'TSScreenCustomComponent';
end;

function TSScreenCustomComponent.GetActive() : TSBoolean;
begin
Result := FActive;
end;

function TSScreenCustomComponent.GetVisible() : TSBoolean;
begin
Result := FVisible;
end;

function TSScreenCustomComponent.HasChildren() : TSBoolean;
begin
Result := False;
if FChildren <> nil then
	if Length(FChildren) > 0 then
		Result := True;
end;

procedure TSScreenCustomComponent.ChildToListEnd(const Component : TSScreenCustomComponent);
var
	Index, i : TSMaxEnum;
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

procedure TSScreenCustomComponent.ChildToListEnd(const Index : TSMaxEnum);
var
	i : TSMaxEnum;
	Component : TSScreenCustomComponent;
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

function TSScreenCustomComponent.ChildCount() : TSUInt32;
begin
if not HasChildren() then
	Result := 0
else
	Result := Length(FChildren);
end;

function TSScreenCustomComponent.GetVisibleTimer() : TSScreenTimer;
begin
Result := FVisibleTimer;
end;

function TSScreenCustomComponent.GetActiveTimer() : TSScreenTimer;
begin
Result := FActiveTimer;
end;

function  TSScreenCustomComponent.GetTitle() : TSString;
begin
Result := FCaption;
end;

procedure TSScreenCustomComponent.SetTitle(const VTitle : TSString);
begin
FCaption := VTitle;
end;

function  TSScreenCustomComponent.GetWidth() : TSAreaInt;
begin
Result := FLocation.Size.x;
end;

function  TSScreenCustomComponent.GetHeight() : TSAreaInt;
begin
Result := FLocation.Size.y;
end;

procedure TSScreenCustomComponent.SetWidth(const VWidth : TSAreaInt);
begin
FLocation.Width := VWidth;
end;

procedure TSScreenCustomComponent.SetHeight(const VHeight : TSAreaInt);
begin
FLocation.Height := VHeight;
end;

function  TSScreenCustomComponent.GetLeft() : TSAreaInt;
begin
Result := FLocation.Position.x;
end;

function  TSScreenCustomComponent.GetTop() : TSAreaInt;
begin
Result := FLocation.Position.y;
end;

procedure TSScreenCustomComponent.SetLeft(const VLeft : TSAreaInt);
begin
FLocation.Left := VLeft;
end;

procedure TSScreenCustomComponent.SetTop(const VTop : TSAreaInt);
begin
FLocation.Top := VTop;
end;

function TSScreenCustomComponent.GetBordersSize() : TSComponentBordersSize;
begin
Result := FBordersSize;
end;

function TSScreenCustomComponent.GetChildLocation() : TSComponentLocation;
var
	Position, Size : TSVector2int32;
begin
Position := GetVertex([SS_LEFT, SS_TOP], S_VERTEX_FOR_CHILDREN);
Size := GetVertex([SS_RIGHT, SS_BOTTOM], S_VERTEX_FOR_CHILDREN);
Size -= Position;
Result.Import(
	TSComponentLocationVectorInt.Create(Position.x, Position.y),
	TSComponentLocationVectorInt.Create(Size.x, Size.y));
end;

function TSScreenCustomComponent.GetLocation() : TSComponentLocation;
var
	Position, Size : TSVector2int32;
begin
Position := GetVertex([SS_LEFT, SS_TOP], S_VERTEX_FOR_PARENT);
Size := GetVertex([SS_RIGHT, SS_BOTTOM], S_VERTEX_FOR_PARENT);
Size -= Position;
Result.Import(
	TSComponentLocationVectorInt.Create(Position.x, Position.y),
	TSComponentLocationVectorInt.Create(Size.x, Size.y));
end;

procedure TSScreenCustomComponent.ToFront();
var
	Index : TSLongInt;
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

procedure TSScreenCustomComponent.Resize();
var
	I : TSLongInt;
	Component : TSScreenCustomComponent;
begin
if SAnchBottom in FAnchors then
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
if SAnchRight in FAnchors then
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
SAlignRight:
	begin
	FLocation.Left+=Parent.Width-ParentWidth;
	end;
end;
if FAlign in [SAlignClient] then
	begin
	for i:=0 to High(FChildren) do
		FChildren[i].FromResize(CW,CH);
	end;}
for Component in Self do
	Component.Resize();
end;

function TSScreenCustomComponent.NotVisible:boolean;
begin
Result := FVisibleTimer < SZero;
end;

function TSScreenCustomComponent.IndexOf(const VComponent : TSScreenCustomComponent ): TSLongInt;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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

procedure TSScreenCustomComponent.VisibleAll;
var
	Component : TSScreenCustomComponent;
begin
FVisibleTimer := 1;
for Component in Self do
	Component.VisibleAll();
end;

procedure TSScreenCustomComponent.KillChildren();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function ChildExists() : TSBool;
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

procedure TSScreenCustomComponent.BoundsMakeReal;
begin
FRealLocation := FLocation;
end;

procedure TSScreenCustomComponent.WriteBounds;
begin
FLocation.Write('Location ');
end;

procedure TSScreenCustomComponent.SetMiddleBounds(const NewWidth,NewHeight:LongInt);
var
	PW, PH : TSLongWord;
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

procedure TSScreenCustomComponent.SetVisible(const b:Boolean);
var
	Component : TSScreenCustomComponent;
begin
FVisible := b;
for Component in Self do
	Component.Visible := Visible;
end;

function TSScreenCustomComponent.GetChild(a:TSInt32):TSScreenCustomComponent;
begin
if (a-1 >= 0) and (a-1<=High(FChildren)) then
	Result:=FChildren[a-1]
else
	Result:=nil;
end;

function TSScreenCustomComponent.GetScreenWidth : longint;
begin
if (FParent <> nil) then
	Result := FParent.Width
else
	Result := Width;
end;

function TSScreenCustomComponent.GetScreenHeight : longint;
begin
if (FParent <> nil) then
	Result := FParent.Height
else
	Result := Height;
end;

procedure TSScreenCustomComponent.SetRight(NewRight:TSScreenInt);
begin
Left:=ScreenWidth-Width-NewRight;
end;

procedure TSScreenCustomComponent.SetBottom(NewBottom:TSScreenInt);
begin
Top:=ScreenHeight-Height-NewBottom;
end;

function TSScreenCustomComponent.GetRight:TSScreenInt;
begin
Result:=ScreenWidth-Width-Left;
end;

function TSScreenCustomComponent.GetBottom : TSScreenInt;
begin
Result:=ScreenHeight-Height-Top;
end;

function TSScreenCustomComponent.BottomShift:TSScreenInt;
begin
Result := FBordersSize.Top + FBordersSize.Bottom;
end;

function TSScreenCustomComponent.RightShift:TSScreenInt;
begin
Result := FBordersSize.Left + FBordersSize.Right;
end;

function TSScreenCustomComponent.LastChild:TSScreenCustomComponent;
begin
Result:=Nil;
if FChildren <> nil then
	Result := FChildren[High(FChildren)];
end;

function TSScreenCustomComponent.UpDateValue(var RealObj, Obj : TSComponentLocationInt; const ElapsedTime : TSTimerInt) : TSComponentLocationInt;
const
	Speed = 2;
var
	Value : TSComponentLocationInt = 0;
	OldValue : TSComponentLocationInt;
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

procedure TSScreenCustomComponent.SetBoundsFloat(const NewLeft, NewTop, NewWidth, NewHeight : TSScreenFloat);
begin
SetBounds(Round(NewLeft), Round(NewTop), Round(NewWidth), Round(NewHeight));
end;

procedure TSScreenCustomComponent.SetBounds(const NewLeft, NewTop, NewWidth, NewHeight : TSScreenInt);
var
	IsLocationNull : TSBoolean;
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

class function TSScreenCustomComponent.RandomOne() : TSInt8;
begin
Result := 0;
Result := Random(2);
if (Result = 0) then
	Result := -1;
end;

procedure TSScreenCustomComponent.UpgradeTimer(const Flag : TSBoolean; var Timer : TSScreenTimer; const ElapsedTime : TSTimerInt; const Factor1 : TSInt16 = 1; const Factor2 : TSFloat32 = 1);
var
	GeneralFactor : TSFloat32;
begin
GeneralFactor := SObjectTimerConst * Factor1 * ElapsedTime;
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

function TSScreenCustomComponent.ReqursiveActive():Boolean;
begin
if (not FActive) or (FParent = nil) then
	Result := FActive
else
	Result := FParent.ReqursiveActive();
end;

procedure TSScreenCustomComponent.UpgradeTimers(const ElapsedTime : TSTimerInt);
begin
UpgradeTimer(FVisible, FVisibleTimer, ElapsedTime);
UpgradeTimer(FActive and ReqursiveActive, FActiveTimer, ElapsedTime);
end;

// Deleted self in parent
procedure TSScreenCustomComponent.DestroyParent;
var
	ii, i : TSLongInt;
begin
{$IFDEF SMoreDebuging}
	if FParent<>nil then
		WriteLn('Begin of  "TSScreenCustomComponent.DestroyParent" ( Length='+SStr(Length(FParent.FChildren))+' ).')
	else
		WriteLn('Begin of  "TSScreenCustomComponent.DestroyParent" ( Parent=nil ).');
	{$ENDIF}
if FParent<>nil then
	begin
	ii := FParent.IndexOf(Self);
	if ii <> -1 then
		begin
		if ii + 1 = FParent.FChildrenPriority then
			ClearPriority();
		{$IFDEF SMoreDebuging}
			WriteLn('"TSScreenCustomComponent.DestroyParent" :  Find Self on '+SStr(ii+1)+' position .');
			{$ENDIF}
		if ii < High(FParent.FChildren) then
			for i:= ii to High(FParent.FChildren) - 1 do
				FParent.FChildren[i] := FParent.FChildren[i + 1];
		SetLength(FParent.FChildren, Length(FParent.FChildren) - 1);
		end;
	end;
{$IFDEF SMoreDebuging}
	if FParent<>nil then
		WriteLn('End of  "TSScreenCustomComponent.DestroyParent" ( Length='+SStr(Length(FParent.FChildren))+' ).')
	else
		WriteLn('End of  "TSScreenCustomComponent.DestroyParent" ( Parent=nil ).');
	{$ENDIF}
end;

destructor TSScreenCustomComponent.Destroy();
begin
KillChildren();
DestroyParent();
inherited;
end;

function TSScreenCustomComponent.GetVertex(const THAT:TSSetOfByte;const FOR_THAT:TSByte): TSPoint2int32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (SS_LEFT in THAT) and (SS_TOP in THAT) then
	begin
	if FOR_THAT = S_VERTEX_FOR_PARENT then
		Result.Import(FRealPosition.x,FRealPosition.y)
	else if FOR_THAT = S_VERTEX_FOR_CHILDREN then
		Result.Import(FRealPosition.x + FBordersSize.Left, FRealPosition.y + FBordersSize.Top)
	else
		Result.Import(0,0);
	end
else if (SS_TOP in THAT) and (SS_RIGHT in THAT) then
	begin
	if FOR_THAT = S_VERTEX_FOR_PARENT then
		Result.Import(FRealPosition.x + FRealLocation.Width, FRealPosition.y)
	else if FOR_THAT = S_VERTEX_FOR_CHILDREN then
		Result.Import(FRealPosition.x + FRealLocation.Width - FBordersSize.Right, FRealPosition.y + FBordersSize.Top)
	else
		Result.Import(0,0);
	end
else if (SS_BOTTOM in THAT) and (SS_RIGHT in THAT) then
	begin
	if FOR_THAT = S_VERTEX_FOR_PARENT then
		Result.Import(FRealPosition.x + FRealLocation.Width, FRealPosition.y + FRealLocation.Height)
	else if FOR_THAT = S_VERTEX_FOR_CHILDREN then
		Result.Import(FRealPosition.x + FRealLocation.Width - FBordersSize.Right, FRealPosition.y + FRealLocation.Height - FBordersSize.Bottom)
	else
		Result.Import(0,0);
	end 
else if (SS_LEFT in THAT) and (SS_BOTTOM in THAT) then
	begin
	if FOR_THAT = S_VERTEX_FOR_PARENT then
		Result.Import(FRealPosition.x,FRealPosition.y + FRealLocation.Height)
	else if FOR_THAT = S_VERTEX_FOR_CHILDREN then
		Result.Import(FRealPosition.x + FBordersSize.Left, FRealPosition.y + FRealLocation.Height - FBordersSize.Bottom)
	else
		Result.Import(0,0);
	end
else
	Result.Import(0, 0);
end;

procedure TSScreenCustomComponent.CompleteChild(const VChild : TSScreenCustomComponent);
var
	Component : TSScreenCustomComponent;
begin
if VChild.Parent = nil then
	VChild.Parent := Self;
for Component in VChild do
	VChild.CompleteChild(Component);
end;

function TSScreenCustomComponent.CreateChild(const Child : TSScreenCustomComponent) : TSScreenCustomComponent;
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

procedure TSScreenCustomComponent.AddToTop(const Value : TSScreenInt);
begin
FLocation.Top := FLocation.Top + Value;
end;

procedure TSScreenCustomComponent.AddToLeft(const Value : TSScreenInt);
begin
FLocation.Left := FLocation.Left + Value;
end;

procedure TSScreenCustomComponent.AddToWidth(const Value : TSScreenInt);
begin
FLocation.Width := FLocation.Width + Value;
end;

procedure TSScreenCustomComponent.AddToHeight(const Value : TSScreenInt);
begin
FLocation.Height := FLocation.Height + Value;
end;

procedure TSScreenCustomComponent.UpDate();
var
	PriorityComponent, Component : TSScreenCustomComponent;
	Index : TSLongWord;
begin
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSScreenCustomComponent__UpDate: Begining');
	{$ENDIF}

UpDateObjects();

PriorityComponent := GetPriorityComponent();
if PriorityComponent <> nil then
	PriorityComponent.UpDate();

Index := 0;
while Index < Length(FChildren) do
	begin
	Component := FChildren[Index];
	if Component.MustBeDestroyed() then
		Component.Destroy()
	else
		begin
		if Component <> PriorityComponent then
			Component.UpDate();
		Index += 1;
		end;
	end;

if (FComponentProcedure <> nil) then
	FComponentProcedure(Self);
end;

procedure TSScreenCustomComponent.DeleteRenderResources();
var
	Component : TSScreenCustomComponent;
begin
for Component in Self do
	Component.DeleteRenderResources();
end;

procedure TSScreenCustomComponent.LoadRenderResources();
var
	Component : TSScreenCustomComponent;
begin
for Component in Self do
	Component.LoadRenderResources();
end;

function TSScreenCustomComponent.Suppored() : TSBoolean;
begin
Result := True;
end;

function TSScreenCustomComponent.GetEnumerator(): TSScreenCustomComponentEnumerator;
begin
Result := TSScreenCustomComponentEnumeratorNormal.Create(Self);
end;

function TSScreenCustomComponent.GetReverseEnumerator(): TSScreenCustomComponentEnumerator;
begin
Result := TSScreenCustomComponentEnumeratorReverse.Create(Self);
end;

procedure TSScreenCustomComponent.Paint();
var
	Component, PriorityComponent : TSScreenCustomComponent;
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

procedure TSScreenCustomComponent.ClearPriority();
var
	ii : TSMaxEnum;
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

function TSScreenCustomComponent.MustBeDestroyed() : TSBoolean;
begin
Result := FMarkedForDestroy and (FVisibleTimer < SZero) and (FActiveTimer < SZero);
end;

procedure TSScreenCustomComponent.MakePriority();
var
	ii : TSMaxEnum;
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

procedure TSScreenCustomComponent.MarkForDestroy();
begin
Active := False;
Visible := False;
FMarkedForDestroy := True;
end;

constructor TSScreenCustomComponent.Create();
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
FAlign:=SAlignNone;
FAnchors:=[];
FVisible:=False;
FVisibleTimer:=0;
FActive:=True;
FActiveTimer:=0;
FCaption:='';
FChildren:=nil;
FCanHaveChildren:=True;
ComponentProcedure:=nil;
FUserPointer1:=nil;
FUserPointer2:=nil;
FUserPointer3:=nil;
FAnchorsData.FParentHeight:=0;
FAnchorsData.FParentWidth:=0;
end;

procedure TSScreenCustomComponent.SetBordersSize(const _L, _T, _R, _B : TSScreenInt);
begin
FBordersSize.Left   := _L;
FBordersSize.Top    := _T;
FBordersSize.Right  := _R;
FBordersSize.Bottom := _B;
end;

function TSScreenCustomComponent.GetPriorityComponent() : TSScreenCustomComponent;
begin
Result := nil;
if (FChildrenPriority > 0) and (FChildren <> nil) then
	if FChildrenPriority <= Length(FChildren) then
		Result := FChildren[FChildrenPriority - 1];
end;

function TSScreenCustomComponent.CursorInComponentCaption():boolean;
begin
Result:=False;
end;

procedure TSScreenCustomComponent.DestroyAlign;
begin
if FAlign=SAlignTop then
	FLocation.Left := FDefaultLocation.Left;
if FAlign=SAlignLeft then
	FLocation.Top := FDefaultLocation.Top;
if FAlign=SAlignRight then
	FLocation.Top := FDefaultLocation.Top;
if FAlign=SAlignBottom then
	FLocation.Left := FDefaultLocation.Left;
if FAlign=SAlignClient then
	begin
	FLocation.Top  := FDefaultLocation.Top;
	FLocation.Left := FDefaultLocation.Left;
	end;
FAlign := SAlignNone;
FLocation.Height := FDefaultLocation.Height;
FLocation.Width  := FDefaultLocation.Width;
end;

procedure TSScreenCustomComponent.CreateAlign(const NewAllign:TSByte);
begin
FAlign:=NewAllign;
end;

procedure TSScreenCustomComponent.TestCoords;
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

procedure TSScreenCustomComponent.SetCaption(const NewCaption : TSCaption);
begin
FCaption := NewCaption;
end;

procedure TSScreenCustomComponent.UpDateLocation(const ElapsedTime : TSTimerInt);
var
	Value, RealValue : TSComponentLocationInt;
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

procedure TSScreenCustomComponent.UpDateObjects();
var
	Component : TSScreenCustomComponent;
	ValueHeight : TSScreenInt = 0;
	ValueWidth  : TSScreenInt = 0;
	ValueLeft   : TSScreenInt = 0;
	ValueTop    : TSScreenInt = 0;
begin
if (FParent <> nil) then
	case FAlign of
	SAlignLeft:
		begin
		FLocation.Position := TSComponentLocationVectorInt.Create();
		FLocation.Height:=FParent.FRealLocation.Height-FParent.FBordersSize.Top-FParent.FBordersSize.Bottom;
		end;
	SAlignTop:
		begin
		FLocation.Position := TSComponentLocationVectorInt.Create();
		FLocation.Width:=FParent.FRealLocation.Width-FParent.FBordersSize.Left-FParent.FBordersSize.Right;
		end;
	SAlignRight:
		begin
		FLocation.Top := 0;
		FLocation.Left:=FParent.FRealLocation.Width-FParent.FBordersSize.Left-FParent.FBordersSize.Right-FRealLocation.Width;
		FLocation.Height:=FParent.FRealLocation.Height-FParent.FBordersSize.Top-FParent.FBordersSize.Bottom;
		end;
	SAlignBottom:
		begin
		FLocation.Left := 0;
		FLocation.Width:=FParent.FRealLocation.Width-FParent.FBordersSize.Left-FParent.FBordersSize.Right;
		FLocation.Top:=FParent.FRealLocation.Height-FParent.FBordersSize.Top-FParent.FBordersSize.Bottom-FRealLocation.Height;
		end;
	SAlignClient:
		begin
		FLocation.Position := TSComponentLocationVectorInt.Create();
		FLocation.Width:=FParent.FRealLocation.Width-FParent.FBordersSize.Left-FParent.FBordersSize.Right;
		FLocation.Height:=FParent.FRealLocation.Height-FParent.FBordersSize.Top-FParent.FBordersSize.Bottom;
		end;
	SAlignNone: begin end;
	else begin end;
	end;
if (FParent <> nil) then
	FRealPosition := FParent.FRealPosition + FRealLocation.Position + TSComponentLocationVectorInt.Create(FParent.FBordersSize.Left, FParent.FBordersSize.Top);
end;

// ==========================
// =======Enumerators========
// ==========================

constructor TSScreenCustomComponentEnumerator.Create(const VComponent : TSScreenCustomComponent);
begin
inherited Create();
FComponent := VComponent;
FCurrent := nil;
end;

function TSScreenCustomComponentEnumerator.GetEnumerator() : TSScreenCustomComponentEnumerator;
begin
Result := Self;
end;

constructor TSScreenCustomComponentEnumeratorNormal.Create(const VComponent : TSScreenCustomComponent);
begin
inherited Create(VComponent);
FIndex := 0;
end;

constructor TSScreenCustomComponentEnumeratorReverse.Create(const VComponent : TSScreenCustomComponent);
begin
inherited Create(VComponent);
FIndex := Length(VComponent.FChildren) + 1;
end;

function TSScreenCustomComponentEnumeratorNormal.MoveNext(): TSBoolean;
begin
FIndex += 1;
if (FIndex >= 1) and (FIndex <= Length(FComponent.FChildren)) then
	FCurrent := FComponent.Children[FIndex]
else
	FCurrent := nil;
Result := FCurrent <> nil;
end;

function TSScreenCustomComponentEnumeratorReverse.MoveNext(): TSBoolean;
begin
FIndex -= 1;
if (FIndex >= 1) and (FIndex <= Length(FComponent.FChildren)) then
	FCurrent := FComponent.Children[FIndex]
else
	FCurrent := nil;
Result := FCurrent <> nil;
end;

end.
