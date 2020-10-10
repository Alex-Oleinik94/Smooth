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
		FComponentOwner    : TSScreenCustomComponent;
		
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
		function GetInternalComponentLocation() : TSComponentLocation; virtual;
		function GetBordersSize() : TSComponentBordersSize; virtual;
		
		procedure UpDateLocation(const ElapsedTime : TSTimerInt);
		function UpDateValue(var RealObj, Obj : TSComponentLocationInt; const ElapsedTime : TSTimerInt) : TSComponentLocationInt;
		function UpDateLocationValue(RealObj, Obj : TSComponentLocationInt; const ElapsedTime : TSTimerInt) : TSComponentLocationInt;
		procedure UpDateObjects();virtual;
		procedure TestCoords();virtual;
			public
		property Width        : TSAreaInt   read GetWidth write SetWidth;
		property Height       : TSAreaInt   read GetHeight write SetHeight;
		property Left         : TSAreaInt   read GetLeft write SetLeft;
		property Top          : TSAreaInt   read GetTop write SetTop;
		property ComponentOwner       : TSScreenCustomComponent read FComponentOwner write FComponentOwner;
		property Bottom       : TSScreenInt read GetBottom write SetBottom;
		property Right        : TSScreenInt read GetRight write SetRight;
		property ScreenWidth  : TSScreenInt read GetScreenWidth;
		property ScreenHeight : TSScreenInt read GetScreenHeight;
		property UnLimited    : TSBoolean   read FUnLimited write FUnLimited;
		property BordersSize  : TSComponentBordersSize read GetBordersSize;
		property RealPosition : TSComponentLocationVectorInt read FRealPosition;
		property Location     : TSComponentLocation read GetLocation;
		property InternalComponentLocation: TSComponentLocation read GetInternalComponentLocation;
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
			FComponentOwnerWidth,FComponentOwnerHeight:TSScreenInt;
			end;
		FVisible : TSBoolean;
		FVisibleTimer : TSScreenTimer;
		FActive : TSBoolean;
		FActiveTimer  : TSScreenTimer;
		FCaption : TSCaption;
		procedure UpdateTimers(const ElapsedTime : TSTimerInt);virtual;
		procedure UpdateTimer(const Flag : TSBoolean; var Timer : TSScreenTimer; const ElapsedTime : TSTimerInt; const Factor1 : TSInt16 = 1; const Factor2 : TSFloat32 = 1);
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
		FInternalComponents:TSScreenCustomComponentList;
		FInternalComponentsAllowed:Boolean;
		FComponentProcedure:TSScreenCustomComponentProcedure;
		FPriorityInternalComponent : TSMaxEnum;
		FMarkedForDestroy : TSBoolean;
			public
		function HasInternalComponents() : TSBoolean;virtual;
		function InternalComponentCount() : TSUInt32;virtual;
		procedure ClearPriority();
		procedure MakePriority();
		function GetPriorityComponent() : TSScreenCustomComponent;
		function CursorInComponentCaption():boolean;virtual;
		function GetVertex(const THAT:TSSetOfByte;const FOR_THAT:TSByte): TSPoint2int32;
		function BottomShift():TSScreenInt;
		function RightShift():TSScreenInt;
		procedure InternalComponentToListEnd(const Index : TSMaxEnum);
		procedure InternalComponentToListEnd(const Component : TSScreenCustomComponent);
			public
		procedure ToFront();
		function MustBeDestroyed() : TSBoolean;
		procedure MarkForDestroy();
		function GetInternalComponent(a:TSInt32):TSScreenCustomComponent;
		function CreateInternalComponent(const InternalComponent : TSScreenCustomComponent) : TSScreenCustomComponent;
		procedure CompleteInternalComponent(const VInternalComponent : TSScreenCustomComponent); virtual;
		function LastInternalComponent():TSScreenCustomComponent;
		procedure CreateAlign(const NewAllign:TSByte);
		procedure DestroyAlign();
		procedure DestroyComponentOwner();
		procedure KillInternalComponents();
		procedure VisibleAll();
		function IndexOf(const VComponent : TSScreenCustomComponent): TSLongInt;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetInternalComponentsCount() : TSUInt32;
			public
		property InternalComponents[Index : TSInt32 (* Indexing [1..Size] *)]:TSScreenCustomComponent read GetInternalComponent;
		property InternalComponentsCount : TSUInt32 read GetInternalComponentsCount;
		property MarkedForDestroy : TSBoolean read FMarkedForDestroy;
		property Align : TSByte read FAlign write CreateAlign;
		property PriorityInternalComponent : TSMaxEnum write FPriorityInternalComponent;
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
	,SmoothArithmeticUtils
	,SmoothContextUtils
	;

function TSScreenCustomComponent.GetInternalComponentsCount() : TSUInt32;
begin
Result := 0;
if (FInternalComponents <> nil) then
	Result := Length(FInternalComponents);
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

function TSScreenCustomComponent.HasInternalComponents() : TSBoolean;
begin
Result := False;
if FInternalComponents <> nil then
	if Length(FInternalComponents) > 0 then
		Result := True;
end;

procedure TSScreenCustomComponent.InternalComponentToListEnd(const Component : TSScreenCustomComponent);
var
	Index, i : TSMaxEnum;
begin
Index := 0;
if (FInternalComponents <> nil) and (Length(FInternalComponents) > 0) then
	for i := 0 to High(FInternalComponents) do
		if FInternalComponents[i] = Component then
			begin
			Index := i + 1;
			break;
			end;
if (Index > 0) then
	InternalComponentToListEnd(Index);
end;

procedure TSScreenCustomComponent.InternalComponentToListEnd(const Index : TSMaxEnum);
var
	i : TSMaxEnum;
	Component : TSScreenCustomComponent;
begin
Component := nil;
if (Index > 0) and (Index <= InternalComponentCount) then
	begin
	Component := FInternalComponents[Index - 1];
	for i:= Index - 1 to InternalComponentsCount - 1 do
		FInternalComponents[i] := FInternalComponents[i + 1];
	FInternalComponents[InternalComponentsCount - 1] := Component;
	end;
end;

function TSScreenCustomComponent.InternalComponentCount() : TSUInt32;
begin
if not HasInternalComponents() then
	Result := 0
else
	Result := Length(FInternalComponents);
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

function TSScreenCustomComponent.GetInternalComponentLocation() : TSComponentLocation;
var
	Position, Size : TSVector2int32;
begin
Position := GetVertex([SS_LEFT, SS_TOP], S_VERTEX_FOR_InternalComponent);
Size := GetVertex([SS_RIGHT, SS_BOTTOM], S_VERTEX_FOR_InternalComponent);
Size -= Position;
Result.Import(
	TSComponentLocationVectorInt.Create(Position.x, Position.y),
	TSComponentLocationVectorInt.Create(Size.x, Size.y));
end;

function TSScreenCustomComponent.GetLocation() : TSComponentLocation;
var
	Position, Size : TSVector2int32;
begin
Position := GetVertex([SS_LEFT, SS_TOP], S_VERTEX_FOR_MainComponent);
Size := GetVertex([SS_RIGHT, SS_BOTTOM], S_VERTEX_FOR_MainComponent);
Size -= Position;
Result.Import(
	TSComponentLocationVectorInt.Create(Position.x, Position.y),
	TSComponentLocationVectorInt.Create(Size.x, Size.y));
end;

procedure TSScreenCustomComponent.ToFront();
var
	Index : TSLongInt;
begin
if FComponentOwner <> nil then
	begin
	if FComponentOwner.FInternalComponents <> nil then
		begin
		if Length(FComponentOwner.FInternalComponents) > 1 then
			begin
			Index := FComponentOwner.IndexOf(Self);
			if Index <> -1 then
				begin
				if Index <> High(FComponentOwner.FInternalComponents) then
					begin
					FComponentOwner.FInternalComponents[Index] := FComponentOwner.FInternalComponents[High(FComponentOwner.FInternalComponents)];
					FComponentOwner.FInternalComponents[High(FComponentOwner.FInternalComponents)] := Self;
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
	if FAnchorsData.FComponentOwnerHeight=0 then
		if FComponentOwner<>nil then
			FAnchorsData.FComponentOwnerHeight:=FComponentOwner.Height
		else
	else if FComponentOwner<>nil then
		begin
		if FAnchorsData.FComponentOwnerHeight<>FComponentOwner.Height then
			begin
			I := FAnchorsData.FComponentOwnerHeight - FComponentOwner.Height;
			FLocation.Top := FLocation.Top - I;
			FAnchorsData.FComponentOwnerHeight := FComponentOwner.Height;
			end;
		end;
	end;
if SAnchRight in FAnchors then
	begin
	if FAnchorsData.FComponentOwnerWidth=0 then
		if FComponentOwner<>nil then
			FAnchorsData.FComponentOwnerWidth:=FComponentOwner.Width
		else
	else if FComponentOwner<>nil then
		begin
		if FAnchorsData.FComponentOwnerWidth<>FComponentOwner.Width then
			begin
			I:=FAnchorsData.FComponentOwnerWidth-FComponentOwner.Width;
			FLocation.Left := FLocation.Left - I;
			FAnchorsData.FComponentOwnerWidth:=FComponentOwner.Width;
			end;
		end;
	end;
BoundsMakeReal();
{CW:=FLocation.Width;
CH:=FLocation.Height;
case FAlign of
SAlignRight:
	begin
	FLocation.Left+=ComponentOwner.Width-ComponentOwnerWidth;
	end;
end;
if FAlign in [SAlignClient] then
	begin
	for i:=0 to High(FInternalComponents) do
		FInternalComponents[i].FromResize(CW,CH);
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
for i := 0 to High(FInternalComponents) do
	if FInternalComponents[i] = VComponent then
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

procedure TSScreenCustomComponent.KillInternalComponents();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function InternalComponentExists() : TSBool;
begin
Result := False;
if FInternalComponents <> nil then
	if Length(FInternalComponents) > 0 then
		Result := True;
end;

begin
while InternalComponentExists() do
	begin
	FInternalComponents[0].Destroy();
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
if (ComponentOwner <> nil) then
	begin
	PW := ComponentOwner.Width;
	PH := ComponentOwner.Height;
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

function TSScreenCustomComponent.GetInternalComponent(a:TSInt32):TSScreenCustomComponent;
begin
if (a-1 >= 0) and (a-1<=High(FInternalComponents)) then
	Result:=FInternalComponents[a-1]
else
	Result:=nil;
end;

function TSScreenCustomComponent.GetScreenWidth : longint;
begin
if (FComponentOwner <> nil) then
	Result := FComponentOwner.Width
else
	Result := Width;
end;

function TSScreenCustomComponent.GetScreenHeight : longint;
begin
if (FComponentOwner <> nil) then
	Result := FComponentOwner.Height
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

function TSScreenCustomComponent.LastInternalComponent:TSScreenCustomComponent;
begin
Result:=Nil;
if FInternalComponents <> nil then
	Result := FInternalComponents[High(FInternalComponents)];
end;


function TSScreenCustomComponent.UpDateLocationValue(RealObj, Obj : TSComponentLocationInt; const ElapsedTime : TSTimerInt) : TSComponentLocationInt;
begin
UpDateValue(RealObj, Obj, ElapsedTime);
Result := RealObj;
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

procedure TSScreenCustomComponent.UpdateTimer(const Flag : TSBoolean; var Timer : TSScreenTimer; const ElapsedTime : TSTimerInt; const Factor1 : TSInt16 = 1; const Factor2 : TSFloat32 = 1);
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
if (not FActive) or (FComponentOwner = nil) then
	Result := FActive
else
	Result := FComponentOwner.ReqursiveActive();
end;

procedure TSScreenCustomComponent.UpdateTimers(const ElapsedTime : TSTimerInt);
begin
UpdateTimer(FVisible, FVisibleTimer, ElapsedTime);
UpdateTimer(FActive and ReqursiveActive, FActiveTimer, ElapsedTime);
end;

// Deleted self in ComponentOwner
procedure TSScreenCustomComponent.DestroyComponentOwner;
var
	ii, i : TSLongInt;
begin
{$IFDEF SMoreDebuging}
	if FComponentOwner<>nil then
		WriteLn('Begin of  "TSScreenCustomComponent.DestroyComponentOwner" ( Length='+SStr(Length(FComponentOwner.FInternalComponents))+' ).')
	else
		WriteLn('Begin of  "TSScreenCustomComponent.DestroyComponentOwner" ( ComponentOwner=nil ).');
	{$ENDIF}
if FComponentOwner<>nil then
	begin
	ii := FComponentOwner.IndexOf(Self);
	if ii <> -1 then
		begin
		if ii + 1 = FComponentOwner.FPriorityInternalComponent then
			ClearPriority();
		{$IFDEF SMoreDebuging}
			WriteLn('"TSScreenCustomComponent.DestroyComponentOwner" :  Find Self on '+SStr(ii+1)+' position .');
			{$ENDIF}
		if ii < High(FComponentOwner.FInternalComponents) then
			for i:= ii to High(FComponentOwner.FInternalComponents) - 1 do
				FComponentOwner.FInternalComponents[i] := FComponentOwner.FInternalComponents[i + 1];
		SetLength(FComponentOwner.FInternalComponents, Length(FComponentOwner.FInternalComponents) - 1);
		end;
	end;
{$IFDEF SMoreDebuging}
	if FComponentOwner<>nil then
		WriteLn('End of  "TSScreenCustomComponent.DestroyComponentOwner" ( Length='+SStr(Length(FComponentOwner.FInternalComponents))+' ).')
	else
		WriteLn('End of  "TSScreenCustomComponent.DestroyComponentOwner" ( ComponentOwner=nil ).');
	{$ENDIF}
end;

destructor TSScreenCustomComponent.Destroy();
begin
KillInternalComponents();
DestroyComponentOwner();
inherited;
end;

function TSScreenCustomComponent.GetVertex(const THAT:TSSetOfByte;const FOR_THAT:TSByte): TSPoint2int32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (SS_LEFT in THAT) and (SS_TOP in THAT) then
	begin
	if FOR_THAT = S_VERTEX_FOR_MainComponent then
		Result.Import(FRealPosition.x,FRealPosition.y)
	else if FOR_THAT = S_VERTEX_FOR_InternalComponent then
		Result.Import(FRealPosition.x + FBordersSize.Left, FRealPosition.y + FBordersSize.Top)
	else
		Result.Import(0,0);
	end
else if (SS_TOP in THAT) and (SS_RIGHT in THAT) then
	begin
	if FOR_THAT = S_VERTEX_FOR_MainComponent then
		Result.Import(FRealPosition.x + FRealLocation.Width, FRealPosition.y)
	else if FOR_THAT = S_VERTEX_FOR_InternalComponent then
		Result.Import(FRealPosition.x + FRealLocation.Width - FBordersSize.Right, FRealPosition.y + FBordersSize.Top)
	else
		Result.Import(0,0);
	end
else if (SS_BOTTOM in THAT) and (SS_RIGHT in THAT) then
	begin
	if FOR_THAT = S_VERTEX_FOR_MainComponent then
		Result.Import(FRealPosition.x + FRealLocation.Width, FRealPosition.y + FRealLocation.Height)
	else if FOR_THAT = S_VERTEX_FOR_InternalComponent then
		Result.Import(FRealPosition.x + FRealLocation.Width - FBordersSize.Right, FRealPosition.y + FRealLocation.Height - FBordersSize.Bottom)
	else
		Result.Import(0,0);
	end 
else if (SS_LEFT in THAT) and (SS_BOTTOM in THAT) then
	begin
	if FOR_THAT = S_VERTEX_FOR_MainComponent then
		Result.Import(FRealPosition.x,FRealPosition.y + FRealLocation.Height)
	else if FOR_THAT = S_VERTEX_FOR_InternalComponent then
		Result.Import(FRealPosition.x + FBordersSize.Left, FRealPosition.y + FRealLocation.Height - FBordersSize.Bottom)
	else
		Result.Import(0,0);
	end
else
	Result.Import(0, 0);
end;

procedure TSScreenCustomComponent.CompleteInternalComponent(const VInternalComponent : TSScreenCustomComponent);
var
	Component : TSScreenCustomComponent;
begin
if VInternalComponent.ComponentOwner = nil then
	VInternalComponent.ComponentOwner := Self;
for Component in VInternalComponent do
	VInternalComponent.CompleteInternalComponent(Component);
end;

function TSScreenCustomComponent.CreateInternalComponent(const InternalComponent : TSScreenCustomComponent) : TSScreenCustomComponent;
begin
Result := nil;
if (InternalComponent <> nil) and FInternalComponentsAllowed then
	begin
	Result := InternalComponent;
	SetLength(FInternalComponents, Length(FInternalComponents) + 1);
	FInternalComponents[High(FInternalComponents)] := Result;
	CompleteInternalComponent(Result);
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
while Index < Length(FInternalComponents) do
	begin
	Component := FInternalComponents[Index];
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
FPriorityInternalComponent:=0;
if FComponentOwner<>nil then
	begin
	if FComponentOwner.FPriorityInternalComponent <> 0 then
		begin
		ii := ComponentOwner.IndexOf(Self) + 1;
		if (ii = FComponentOwner.FPriorityInternalComponent) then
			FComponentOwner.ClearPriority();
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
if FComponentOwner<>nil then
	begin
	ii := ComponentOwner.IndexOf(Self) + 1;
	if ii <> 0 then
		begin
		FComponentOwner.FPriorityInternalComponent := ii;
		FComponentOwner.MakePriority();
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
FPriorityInternalComponent:=0;
FUnLimited:=False;
OnChange:=nil;
FComponentOwner:=nil;
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
FInternalComponents:=nil;
FInternalComponentsAllowed:=True;
ComponentProcedure:=nil;
FUserPointer1:=nil;
FUserPointer2:=nil;
FUserPointer3:=nil;
FAnchorsData.FComponentOwnerHeight:=0;
FAnchorsData.FComponentOwnerWidth:=0;
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
if (FPriorityInternalComponent > 0) and (FInternalComponents <> nil) then
	if FPriorityInternalComponent <= Length(FInternalComponents) then
		Result := FInternalComponents[FPriorityInternalComponent - 1];
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
if (FComponentOwner<>nil) and (FComponentOwner.FComponentOwner<>nil) and (not FUnLimited) then
	begin
	if FRealLocation.Height>FComponentOwner.FRealLocation.Height-FComponentOwner.FBordersSize.Top-FComponentOwner.FBordersSize.Bottom then
		FRealLocation.Height:=FComponentOwner.FRealLocation.Height-FComponentOwner.FBordersSize.Top-FComponentOwner.FBordersSize.Bottom;
	if FRealLocation.Width>FComponentOwner.FRealLocation.Width-FComponentOwner.FBordersSize.Left-FComponentOwner.FBordersSize.Right then
		FRealLocation.Width:=FComponentOwner.FRealLocation.Width-FComponentOwner.FBordersSize.Left-FComponentOwner.FBordersSize.Right;
	if FRealLocation.Top < 0 then
		FRealLocation.Top:=0;
	if FRealLocation.Left < 0 then
		FRealLocation.Left:=0;
	if (FRealLocation.Left+FRealLocation.Width)>FComponentOwner.FRealLocation.Width-FComponentOwner.RightShift then
		FRealLocation.Left:=FComponentOwner.FRealLocation.Width-FRealLocation.Width-FComponentOwner.RightShift;
	if (FRealLocation.Top+FRealLocation.Height)>FComponentOwner.FRealLocation.Height-FComponentOwner.BottomShift then
		FRealLocation.Top:=FComponentOwner.FRealLocation.Height-FRealLocation.Height-FComponentOwner.BottomShift;
	if FLocation.Top < 0 then
		FLocation.Top := 0;
	if FLocation.Left < 0 then
		FLocation.Left:=0;
	if (FLocation.Left+FLocation.Width)>FComponentOwner.FLocation.Width-FComponentOwner.RightShift then
		FLocation.Left:=FComponentOwner.FLocation.Width-FLocation.Width-FComponentOwner.RightShift;
	if (FLocation.Top+FLocation.Height)>FComponentOwner.FLocation.Height-FComponentOwner.BottomShift then
		FLocation.Top:=FComponentOwner.FLocation.Height-FLocation.Height-FComponentOwner.BottomShift;
	end;
end;

procedure TSScreenCustomComponent.SetCaption(const NewCaption : TSCaption);
begin
FCaption := NewCaption;
end;

procedure TSScreenCustomComponent.UpDateLocation(const ElapsedTime : TSTimerInt);
begin
FRealLocation.Width := UpDateLocationValue(FRealLocation.Width, FLocation.Width, ElapsedTime);
FRealLocation.Height := UpDateLocationValue(FRealLocation.Height, FLocation.Height, ElapsedTime);
FRealLocation.Left := UpDateLocationValue(FRealLocation.Left, FLocation.Left, ElapsedTime);
FRealLocation.Top := UpDateLocationValue(FRealLocation.Top, FLocation.Top, ElapsedTime);
end;

procedure TSScreenCustomComponent.UpDateObjects();
var
	Component : TSScreenCustomComponent;
	ValueHeight : TSScreenInt = 0;
	ValueWidth  : TSScreenInt = 0;
	ValueLeft   : TSScreenInt = 0;
	ValueTop    : TSScreenInt = 0;
begin
if (FComponentOwner <> nil) then
	case FAlign of
	SAlignLeft:
		begin
		FLocation.Position := TSComponentLocationVectorInt.Create();
		FLocation.Height:=FComponentOwner.FRealLocation.Height-FComponentOwner.FBordersSize.Top-FComponentOwner.FBordersSize.Bottom;
		end;
	SAlignTop:
		begin
		FLocation.Position := TSComponentLocationVectorInt.Create();
		FLocation.Width:=FComponentOwner.FRealLocation.Width-FComponentOwner.FBordersSize.Left-FComponentOwner.FBordersSize.Right;
		end;
	SAlignRight:
		begin
		FLocation.Top := 0;
		FLocation.Left:=FComponentOwner.FRealLocation.Width-FComponentOwner.FBordersSize.Left-FComponentOwner.FBordersSize.Right-FRealLocation.Width;
		FLocation.Height:=FComponentOwner.FRealLocation.Height-FComponentOwner.FBordersSize.Top-FComponentOwner.FBordersSize.Bottom;
		end;
	SAlignBottom:
		begin
		FLocation.Left := 0;
		FLocation.Width:=FComponentOwner.FRealLocation.Width-FComponentOwner.FBordersSize.Left-FComponentOwner.FBordersSize.Right;
		FLocation.Top:=FComponentOwner.FRealLocation.Height-FComponentOwner.FBordersSize.Top-FComponentOwner.FBordersSize.Bottom-FRealLocation.Height;
		end;
	SAlignClient:
		begin
		FLocation.Position := TSComponentLocationVectorInt.Create();
		FLocation.Width:=FComponentOwner.FRealLocation.Width-FComponentOwner.FBordersSize.Left-FComponentOwner.FBordersSize.Right;
		FLocation.Height:=FComponentOwner.FRealLocation.Height-FComponentOwner.FBordersSize.Top-FComponentOwner.FBordersSize.Bottom;
		end;
	SAlignNone: begin end;
	else begin end;
	end;
if (FComponentOwner <> nil) then
	FRealPosition := FComponentOwner.FRealPosition + FRealLocation.Position + TSComponentLocationVectorInt.Create(FComponentOwner.FBordersSize.Left, FComponentOwner.FBordersSize.Top);
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
FIndex := Length(VComponent.FInternalComponents) + 1;
end;

function TSScreenCustomComponentEnumeratorNormal.MoveNext(): TSBoolean;
begin
FIndex += 1;
if (FIndex >= 1) and (FIndex <= Length(FComponent.FInternalComponents)) then
	FCurrent := FComponent.InternalComponents[FIndex]
else
	FCurrent := nil;
Result := FCurrent <> nil;
end;

function TSScreenCustomComponentEnumeratorReverse.MoveNext(): TSBoolean;
begin
FIndex -= 1;
if (FIndex >= 1) and (FIndex <= Length(FComponent.FInternalComponents)) then
	FCurrent := FComponent.InternalComponents[FIndex]
else
	FCurrent := nil;
Result := FCurrent <> nil;
end;

end.
