{$INCLUDE SaGe.inc}

unit SaGeScreenBase;

interface

uses
	 SaGeBase
	,SaGeCommonStructs
	,SaGeBaseContextInterface
	;
type
	SGFrameButtonsType = type TSGByte;
const
	SGFrameAnimationConst = 200;
	SGObjectTimerConst : TSGFloat64 = 0.02;
	
	SGFrameButtonsType0f =               $000003;
	SGFrameButtonsTypeCleared = SGFrameButtonsType0f;
	SGFrameButtonsType1f =               $000004;
	SGFrameButtonsType3f =               $000005;
const
	SGAlignNone =                        $000006;
	SGAlignLeft =                        $000007;
	SGAlignRight =                       $000008;
	SGAlignTop =                         $000009;
	SGAlignBottom =                      $00000A;
	SGAlignClient =                      $00000B;
	
	SGAnchorRight =                      $00000D;
	SGAnchorLeft =                       $00000E;
	SGAnchorTop =                        $00000F;
	SGAnchorBottom =                     $000010;
	
	SG_VERTEX_FOR_CHILDREN =             $000013;
	SG_VERTEX_FOR_PARENT =               $000014;
	
	SG_LEFT =                            $000015;
	SG_TOP =                             $000016;
	SG_HEIGHT =                          $000017;
	SG_WIDTH =                           $000018;
	SG_RIGHT =                           $000019;
	SG_BOTTOM =                          $00001A;
type
	TSGCaption =  TSGString;
	TSGScreenFloat = TSGFloat32;
	TSGScreenTimer = TSGScreenFloat;
	TSGComponentLocationFloat = TSGFloat32;
	TSGComponentLocationInt   = TSGInt16;
	TSGComponentLocationVectorInt   = TSGVector2int16;
	TSGComponentLocationVectorFloat = TSGVector2f;
	
	TSGComponentLocation = object
			protected
		FPosition : TSGComponentLocationVectorInt;
		FSize     : TSGComponentLocationVectorInt;
			public
		procedure Import(const _Position, _Size : TSGComponentLocationVectorInt); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		procedure Import(const _Left, _Top, _Width, _Height : TSGComponentLocationInt); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
		procedure Write(const VName : TSGString = ''); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function FloatPosition() : TSGComponentLocationVectorFloat;
		function FloatPositionAndSize() : TSGComponentLocationVectorFloat;
			public
		property Size      : TSGComponentLocationVectorInt read FSize     write FSize;
		property Position  : TSGComponentLocationVectorInt read FPosition write FPosition;
		property SizeX     : TSGComponentLocationInt read FSize.x     write FSize.x;
		property SizeY     : TSGComponentLocationInt read FSize.y     write FSize.y;
		property PositionX : TSGComponentLocationInt read FPosition.x write FPosition.x;
		property PositionY : TSGComponentLocationInt read FPosition.y write FPosition.y;
		property Width     : TSGComponentLocationInt read FSize.x     write FSize.x;
		property Height    : TSGComponentLocationInt read FSize.y     write FSize.y;
		property Left      : TSGComponentLocationInt read FPosition.x write FPosition.x;
		property Top       : TSGComponentLocationInt read FPosition.y write FPosition.y;
		end;
	
	TSGAnchor    = type TSGByte;
	TSGAnchors   = set of TSGByte;
	TSGScreenInt = TSGAreaInt;
	TSGScreenInterfaceData = TSGPointer;
	
	TSGComponentBoundsSize = object
			protected
		FLeftSize   : TSGScreenInt;
		FTopSize    : TSGScreenInt;
		FRightSize  : TSGScreenInt;
		FBottomSize : TSGScreenInt;
			public
		property Left   : TSGScreenInt read FLeftSize   write FLeftSize;
		property Top    : TSGScreenInt read FTopSize    write FTopSize;
		property Right  : TSGScreenInt read FRightSize  write FRightSize;
		property Bottom : TSGScreenInt read FBottomSize write FBottomSize;
		end;
	
	TSGScreenSkinFrameColor = object
			public
		FFirst  : TSGColor4f;
		FSecond : TSGColor4f;
			public
		procedure Import(const VFirst, VSecond : TSGColor4f); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

const
	SGAnchRight  : TSGAnchor = $11;
	SGAnchLeft   : TSGAnchor = $12;
	SGAnchTop    : TSGAnchor = $13;
	SGAnchBottom : TSGAnchor = $14;

	SGS_LEFT   = 1;
	SGS_BOTTOM = 2;
	SGS_RIGHT  = 3;
	SGS_TOP    = 4;

type
	ISGComponent = interface(ISGArea)
		['{6ee600fd-f8b3-40bc-bf8a-ec7693b21e96}']
		procedure SetRight (NewRight  : TSGScreenInt);
		procedure SetBottom(NewBottom : TSGScreenInt);
		function GetRight()  : TSGScreenInt;
		function GetBottom() : TSGScreenInt;

		function GetScreenWidth()  : TSGScreenInt;
		function GetScreenHeight() : TSGScreenInt;
		function GetLocation() : TSGComponentLocation;

		procedure SetBordersSize(const _L, _T, _R, _B : TSGScreenInt);
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:TSGScreenInt);
		procedure SetMiddleBounds(const NewWidth,NewHeight:TSGScreenInt);
		procedure BoundsMakeReal();

		procedure WriteBounds();

		procedure UpDateObjects();
		procedure TestCoords();
		procedure UpgradeTimers(const ElapsedTime : TSGTimerInt);

		procedure AddToLeft(const Value:TSGScreenInt);
		procedure AddToWidth(const Value:TSGScreenInt);
		procedure AddToHeight(const Value:TSGScreenInt);
		procedure AddToTop(const Value:TSGScreenInt);

		procedure Paint();
		procedure Resize();
		procedure FromUpDate();
		procedure FromUpDateUnderCursor(const CursorInComponentNow:TSGBoolean = True);
		procedure FromUpDateCaptionUnderCursor();

		procedure SetVisible(const b:TSGBoolean);
		procedure SetCaption(const NewCaption : TSGCaption);
		function ReqursiveActive():TSGBoolean;
		function NotVisible : TSGBoolean;

		procedure ClearPriority();
		procedure MakePriority();
		function CursorOverComponent():TSGBoolean;
		function CursorInComponentCaption():TSGBoolean;
		function GetVertex(const THAT:TSGSetOfByte;const FOR_THAT:TSGByte): TSGPoint2int32;
		function BottomShift():TSGScreenInt;
		function RightShift():TSGScreenInt;
		procedure ToFront();
		function MustBeDestroyed() : TSGBoolean;
		procedure MarkForDestroy();
		procedure CreateAlign(const NewAllign:TSGByte);
		function CursorPositionAtTheMoment(): TSGPoint2int32;
		procedure DestroyAlign();
		procedure DestroyParent();
		procedure KillChildren();
		procedure VisibleAll();

		function GetVisibleTimer() : TSGScreenTimer;
		function GetActiveTimer() : TSGScreenTimer;
		function GetActive() : TSGBoolean;
		function GetVisible() : TSGBoolean;

		function GetTitle() : TSGString;
		
		property Caption : TSGCaption read GetTitle;
		property Active : TSGBoolean read GetActive;
		property Visible : TSGBoolean read GetVisible;
		property VisibleTimer : TSGScreenTimer read GetVisibleTimer;
		property ActiveTimer : TSGScreenTimer read GetActiveTimer;
		end;

function SGComponentLocationImport(const VPosition, VSize : TSGComponentLocationVectorInt) : TSGComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGComponentLocationImport(const VLeft, VTop, VWidth, VHeight : TSGComponentLocationInt) : TSGComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

function TSGComponentLocation.FloatPosition() : TSGComponentLocationVectorFloat;
begin
Result.Import(Position.x, Position.y);
end;

function TSGComponentLocation.FloatPositionAndSize() : TSGComponentLocationVectorFloat;
begin
Result := FloatPosition + TSGComponentLocationVectorFloat.Create(Size.x, Size.y);
end;

function SGComponentLocationImport(const VLeft, VTop, VWidth, VHeight : TSGComponentLocationInt) : TSGComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGComponentLocationImport(TSGComponentLocationVectorInt.Create(VLeft, VTop), TSGComponentLocationVectorInt.Create(VWidth, VHeight));
end;

procedure TSGScreenSkinFrameColor.Import(const VFirst, VSecond : TSGColor4f ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FFirst  := VFirst;
FSecond := FSecond;
end;

procedure TSGComponentLocation.Write(const VName : TSGString = ''); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
WriteLn(VName,':');
FPosition.WriteLn();
FSize.WriteLn();
end;

function SGComponentLocationImport(const VPosition, VSize : TSGComponentLocationVectorInt) : TSGComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(VPosition, VSize);
end;

procedure TSGComponentLocation.Import(const _Left, _Top, _Width, _Height : TSGComponentLocationInt); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
Left   := _Left;
Top    := _Top;
Width  := _Width;
Height := _Height
end;

procedure TSGComponentLocation.Import(const _Position, _Size : TSGComponentLocationVectorInt); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FPosition := _Position;
FSize     := _Size;
end;

end.
