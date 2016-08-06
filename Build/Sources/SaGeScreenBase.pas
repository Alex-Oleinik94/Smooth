{$INCLUDE SaGe.inc}

unit SaGeScreenBase;

interface

uses 
	 Crt
	,SaGeCommon
	,SaGeBase
	,SaGeClasses
	,SaGeBased
	,SaGeImages
	,SaGeContext
	,SaGeUtils
	,SaGeRenderConstants
	,SaGeResourseManager
	,SaGeCommonClasses
	;

type
	TSGCaption =  TSGString;
	TSGScreenTimer = TSGFloat;
	TSGComponentLocationVectorType = TSGVector2f;
	
	TSGComponentLocation = object
		FPosition : TSGComponentLocationVectorType;
		FSize     : TSGComponentLocationVectorType;
		procedure Import(const VPosition, VSize : TSGComponentLocationVectorType ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		property Size : TSGComponentLocationVectorType read FSize;
		property Position : TSGComponentLocationVectorType read FPosition;
		end;
	
	TSGAnchors = type TSGExByte;
	TSGScreenInt    = TSGAreaInt;

const
	SGAnchRight  : TSGAnchors = $11;
	SGAnchLeft   : TSGAnchors = $12;
	SGAnchTop    : TSGAnchors = $13;
	SGAnchBottom : TSGAnchors = $14;
	
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
		
		procedure SetShifts(const NL,NT,NR,NB:TSGScreenInt);
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:TSGScreenInt);
		procedure SetMiddleBounds(const NewWidth,NewHeight:TSGScreenInt);
		procedure BoundsToNeedBounds();
		
		function UpDateObj(var Obj, NObj : TSGScreenInt) : TSGScreenInt;
		procedure WriteBounds();
		
		procedure UpDateObjects();
		procedure TestCoords();
		procedure UpgradeTimers();
		
		procedure AddToLeft(const Value:TSGScreenInt);
		procedure AddToWidth(const Value:TSGScreenInt);
		procedure AddToHeight(const Value:TSGScreenInt);
		procedure AddToTop(const Value:TSGScreenInt);
		
		procedure FromDraw();
		procedure FromResize();
		procedure FromUpDate(var FCanChange:Boolean);
		procedure FromUpDateUnderCursor(var CanRePleace:TSGBoolean;const CursorInComponentNow:TSGBoolean = True);
		procedure FromUpDateCaptionUnderCursor(var CanRePleace:TSGBoolean);
		
		procedure SetVisible(const b:TSGBoolean);
		procedure SetCaption(const NewCaption : TSGCaption);
		function ReqursiveActive():TSGBoolean;
		function NotVisible : TSGBoolean;
		
		procedure ClearPriority();
		procedure MakePriority();
		function CursorInComponent():TSGBoolean;
		function CursorInComponentCaption():TSGBoolean;
		function GetVertex(const THAT:TSGSetOfByte;const FOR_THAT:TSGExByte): TSGPoint2int32;
		function BottomShift():TSGScreenInt;
		function RightShift():TSGScreenInt;
		procedure ToFront();
		function MustDestroyed() : TSGBoolean;
		procedure MarkForDestroy();
		procedure CreateAlign(const NewAllign:TSGExByte);
		function CursorPosition(): TSGPoint2int32;
		procedure DestroyAlign();
		procedure DestroyParent();
		procedure KillChildren();
		procedure VisibleAll();
		
		function GetVisibleTimer() : TSGScreenTimer;
		function GetActiveTimer() : TSGScreenTimer;
		function GetActive() : TSGBoolean;
		function GetVisible() : TSGBoolean;
		function GetFont() : TSGFont;
		
		property Font : TSGFont read GetFont;
		property Caption : TSGCaption read GetTitle;
		property Active : TSGBoolean read GetActive;
		property Visible : TSGBoolean read GetVisible;
		property VisibleTimer : TSGScreenTimer read GetVisibleTimer;
		property ActiveTimer : TSGScreenTimer read GetActiveTimer;
		end;
	
	ISGScreen = interface(ISGComponent)
		['{c3c6ea12-c4ff-41de-a250-1e4d856b3e59}']
		procedure Load(const VContext : ISGContext);
		procedure CustomPaint(VCanReplace : TSGBool);
		function UpDateScreen() : TSGBoolean;
		end;
	
	ISGOverComponent = interface(ISGComponent)
		['{ac52a3a2-e62d-4473-a2b9-1d36f56389a9}']
		function GetOverTimer() : TSGScreenTimer;
		function GetOver() : TSGBool;
		
		property Over : TSGBoolean read GetOver;
		property OverTimer : TSGScreenTimer read GetOverTimer;
		end;
	
	ISGClickComponent = interface(ISGOverComponent)
		['{9b21d96d-b820-41cd-b18f-14ed09d5c218}']
		function GetClickTimer() : TSGScreenTimer;
		function GetClick() : TSGBool;
		
		property Click : TSGBoolean read GetOver;
		property ClickTimer : TSGScreenTimer read GetClickTimer;
		end;
	
	ISGButton = interface(ISGClickComponent)
		['{ec439dc0-edd6-42e2-af41-42e9805c2e77}']
		end;
	
	ISGPanel = interface(ISGComponent)
		['{41f51334-780b-444c-aa61-4c000759516b}']
		function ViewingLines() : TSGBoolean;
		function ViewingQuad() : TSGBoolean;
		end;

function SGComponentLocationImport(const VPosition, VSize : TSGComponentLocationVectorType) : TSGComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

function SGComponentLocationImport(const VPosition, VSize : TSGComponentLocationVectorType) : TSGComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result.Import(VPosition, VSize);
end;

procedure TSGComponentLocation.Import(const VPosition, VSize : TSGComponentLocationVectorType ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FPosition := VPosition;
FSize     := VSize;
end;

end.
