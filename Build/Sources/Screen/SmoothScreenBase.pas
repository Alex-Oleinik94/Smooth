{$INCLUDE Smooth.inc}

unit SmoothScreenBase;

interface

uses
	 SmoothBase
	,SmoothCommonStructs
	,SmoothBaseContextInterface
	;
type
	SFrameButtonsType = type TSByte;
const
	SFrameAnimationConst = 200;
	SObjectTimerConst : TSFloat64 = 0.02;
	
	SFrameButtonsType0f =               $000003;
	SFrameButtonsTypeCleared = SFrameButtonsType0f;
	SFrameButtonsType1f =               $000004;
	SFrameButtonsType3f =               $000005;
const
	SAlignNone =                        $000006;
	SAlignLeft =                        $000007;
	SAlignRight =                       $000008;
	SAlignTop =                         $000009;
	SAlignBottom =                      $00000A;
	SAlignClient =                      $00000B;
	
	SAnchorRight =                      $00000D;
	SAnchorLeft =                       $00000E;
	SAnchorTop =                        $00000F;
	SAnchorBottom =                     $000010;
	
	S_VERTEX_FOR_CHILDREN =             $000013;
	S_VERTEX_FOR_PARENT =               $000014;
	
	S_LEFT =                            $000015;
	S_TOP =                             $000016;
	S_HEIGHT =                          $000017;
	S_WIDTH =                           $000018;
	S_RIGHT =                           $000019;
	S_BOTTOM =                          $00001A;
type
	TSCaption =  TSString;
	TSScreenFloat = TSFloat32;
	TSScreenTimer = TSScreenFloat;
	TSComponentLocationFloat = TSFloat32;
	TSComponentLocationInt   = TSInt16;
	TSComponentLocationVectorInt   = TSVector2int16;
	TSComponentLocationVectorFloat = TSVector2f;
	
	TSComponentLocation = object
			protected
		FPosition : TSComponentLocationVectorInt;
		FSize     : TSComponentLocationVectorInt;
			public
		procedure Import(const _Position, _Size : TSComponentLocationVectorInt); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		procedure Import(const _Left, _Top, _Width, _Height : TSComponentLocationInt); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		procedure Write(const VName : TSString = ''); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function FloatPosition() : TSComponentLocationVectorFloat;
		function FloatPositionAndSize() : TSComponentLocationVectorFloat;
			public
		property Size      : TSComponentLocationVectorInt read FSize     write FSize;
		property Position  : TSComponentLocationVectorInt read FPosition write FPosition;
		property SizeX     : TSComponentLocationInt read FSize.x     write FSize.x;
		property SizeY     : TSComponentLocationInt read FSize.y     write FSize.y;
		property PositionX : TSComponentLocationInt read FPosition.x write FPosition.x;
		property PositionY : TSComponentLocationInt read FPosition.y write FPosition.y;
		property Width     : TSComponentLocationInt read FSize.x     write FSize.x;
		property Height    : TSComponentLocationInt read FSize.y     write FSize.y;
		property Left      : TSComponentLocationInt read FPosition.x write FPosition.x;
		property Top       : TSComponentLocationInt read FPosition.y write FPosition.y;
		end;
	
	TSAnchor    = type TSByte;
	TSAnchors   = set of TSByte;
	TSScreenInt = TSAreaInt;
	TSScreenInterfaceData = TSPointer;
	
	TSComponentBordersSize = object
			protected
		FLeftSize   : TSScreenInt;
		FTopSize    : TSScreenInt;
		FRightSize  : TSScreenInt;
		FBottomSize : TSScreenInt;
			public
		property Left   : TSScreenInt read FLeftSize   write FLeftSize;
		property Top    : TSScreenInt read FTopSize    write FTopSize;
		property Right  : TSScreenInt read FRightSize  write FRightSize;
		property Bottom : TSScreenInt read FBottomSize write FBottomSize;
		end;
	
	TSScreenSkinFrameColor = object
			public
		FFirst  : TSColor4f;
		FSecond : TSColor4f;
			public
		procedure Import(const VFirst, VSecond : TSColor4f); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

const
	SAnchRight  : TSAnchor = $11;
	SAnchLeft   : TSAnchor = $12;
	SAnchTop    : TSAnchor = $13;
	SAnchBottom : TSAnchor = $14;

	SS_LEFT   = 1;
	SS_BOTTOM = 2;
	SS_RIGHT  = 3;
	SS_TOP    = 4;

type
	ISCustomComponent = interface(ISArea)
		['{6ee600fd-f8b3-40bc-bf8a-ec7693b21e96}']
		procedure SetRight (NewRight  : TSScreenInt);
		procedure SetBottom(NewBottom : TSScreenInt);
		function GetRight()  : TSScreenInt;
		function GetBottom() : TSScreenInt;

		function GetBordersSize() : TSComponentBordersSize;
		function GetScreenWidth()  : TSScreenInt;
		function GetScreenHeight() : TSScreenInt;
		function GetLocation() : TSComponentLocation;
		function GetChildLocation() : TSComponentLocation;
		
		procedure SetBordersSize(const _L, _T, _R, _B : TSScreenInt);
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:TSScreenInt);
		procedure SetMiddleBounds(const NewWidth,NewHeight:TSScreenInt);
		procedure BoundsMakeReal();

		procedure WriteBounds();

		procedure UpDateObjects();
		procedure TestCoords();
		procedure UpgradeTimers(const ElapsedTime : TSTimerInt);

		procedure AddToLeft(const Value:TSScreenInt);
		procedure AddToWidth(const Value:TSScreenInt);
		procedure AddToHeight(const Value:TSScreenInt);
		procedure AddToTop(const Value:TSScreenInt);

		procedure Paint();
		procedure Resize();
		procedure UpDate();

		procedure SetVisible(const b:TSBoolean);
		procedure SetCaption(const NewCaption : TSCaption);
		function ReqursiveActive():TSBoolean;
		function NotVisible : TSBoolean;

		procedure ClearPriority();
		procedure MakePriority();
		function CursorInComponentCaption():TSBoolean;
		function GetVertex(const THAT:TSSetOfByte;const FOR_THAT:TSByte): TSPoint2int32;
		function BottomShift():TSScreenInt;
		function RightShift():TSScreenInt;
		procedure ToFront();
		function MustBeDestroyed() : TSBoolean;
		procedure MarkForDestroy();
		procedure CreateAlign(const NewAllign:TSByte);
		procedure DestroyAlign();
		procedure DestroyParent();
		procedure KillChildren();
		procedure VisibleAll();

		function GetVisibleTimer() : TSScreenTimer;
		function GetActiveTimer() : TSScreenTimer;
		function GetActive() : TSBoolean;
		function GetVisible() : TSBoolean;

		function GetTitle() : TSString;
		
		property Caption : TSCaption read GetTitle;
		property Active : TSBoolean read GetActive;
		property Visible : TSBoolean read GetVisible;
		property VisibleTimer : TSScreenTimer read GetVisibleTimer;
		property ActiveTimer : TSScreenTimer read GetActiveTimer;
		property BordersSize : TSComponentBordersSize read GetBordersSize;
		property ChildLocation : TSComponentLocation read GetChildLocation;
		property Location : TSComponentLocation read GetLocation;
		end;

	ISComponent = interface(ISCustomComponent)
		['{4beeab5e-72bc-430e-81a7-f5b499143514}']
		function CursorOverComponent():TSBoolean;
		end;

function SComponentLocationImport(const VPosition, VSize : TSComponentLocationVectorInt) : TSComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SComponentLocationImport(const VLeft, VTop, VWidth, VHeight : TSComponentLocationInt) : TSComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

function TSComponentLocation.FloatPosition() : TSComponentLocationVectorFloat;
begin
Result.Import(Position.x, Position.y);
end;

function TSComponentLocation.FloatPositionAndSize() : TSComponentLocationVectorFloat;
begin
Result := FloatPosition + TSComponentLocationVectorFloat.Create(Size.x, Size.y);
end;

function SComponentLocationImport(const VLeft, VTop, VWidth, VHeight : TSComponentLocationInt) : TSComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SComponentLocationImport(TSComponentLocationVectorInt.Create(VLeft, VTop), TSComponentLocationVectorInt.Create(VWidth, VHeight));
end;

procedure TSScreenSkinFrameColor.Import(const VFirst, VSecond : TSColor4f ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FFirst  := VFirst;
FSecond := FSecond;
end;

procedure TSComponentLocation.Write(const VName : TSString = ''); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
WriteLn(VName,':');
FPosition.WriteLn();
FSize.WriteLn();
end;

function SComponentLocationImport(const VPosition, VSize : TSComponentLocationVectorInt) : TSComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(VPosition, VSize);
end;

procedure TSComponentLocation.Import(const _Left, _Top, _Width, _Height : TSComponentLocationInt); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Left   := _Left;
Top    := _Top;
Width  := _Width;
Height := _Height
end;

procedure TSComponentLocation.Import(const _Position, _Size : TSComponentLocationVectorInt); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FPosition := _Position;
FSize     := _Size;
end;

end.
