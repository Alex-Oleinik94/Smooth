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
	,SaGeUtils
	,SaGeRenderConstants
	,SaGeResourceManager
	,SaGeCommonClasses
	;

type
	TSGCaption =  TSGString;
	TSGScreenFloat = TSGFloat;
	TSGScreenTimer = TSGScreenFloat;
	TSGComponentLocationType = TSGScreenFloat;
	TSGComponentLocationVectorType = TSGVector2f;

	TSGComponentLocation = object
			protected
		FPosition : TSGComponentLocationVectorType;
		FSize     : TSGComponentLocationVectorType;
			public
		procedure Import(const VPosition, VSize : TSGComponentLocationVectorType ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Write(const VName : TSGString = ''); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property Size      : TSGComponentLocationVectorType read FSize     write FSize;
		property Position  : TSGComponentLocationVectorType read FPosition write FPosition;
		property SizeX     : TSGComponentLocationType read FSize.x     write FSize.x;
		property SizeY     : TSGComponentLocationType read FSize.y     write FSize.y;
		property PositionX : TSGComponentLocationType read FPosition.x write FPosition.x;
		property PositionY : TSGComponentLocationType read FPosition.y write FPosition.y;
		end;

	TSGAnchors = type TSGExByte;
	TSGScreenInt    = TSGAreaInt;


	TSGScreenSkinFrameColor = object
			public
		FFirst  : TSGColor4f;
		FSecond : TSGColor4f;
			public
		procedure Import(const VFirst, VSecond : TSGColor4f ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

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

	ISGLabel = interface(ISGComponent)
		['{7f02dd71-b699-453f-aa8d-f41dd7d44bc6}']
		function  GetTextPosition() : TSGBoolean;
		procedure SetTextPosition(const Pos : TSGBoolean);
		function  GetTextColor() : TSGColor4f;
		procedure SetTextColor(const VTextColor : TSGColor4f);
		function  GetTextColorSeted() : TSGBoolean;
		procedure SetTextColorSeted(const VTextColorSeted : TSGBoolean);

		property TextPosition   : TSGBoolean read GetTextPosition   write SetTextPosition;
		property TextColor      : TSGColor4f read GetTextColor      write SetTextColor;
		property TextColorSeted : TSGBoolean read GetTextColorSeted write SetTextColorSeted;
		end;

	ISGButton = interface(ISGClickComponent)
		['{ec439dc0-edd6-42e2-af41-42e9805c2e77}']
		end;

	ISGPanel = interface(ISGComponent)
		['{41f51334-780b-444c-aa61-4c000759516b}']
		function ViewingLines() : TSGBoolean;
		function ViewingQuad()  : TSGBoolean;
		
		property ViewLines : TSGBool read ViewingLines;
		property ViewQuad : TSGBool read ViewingQuad;
		end;

	ISGOpenComponent = interface(ISGClickComponent)
		['{84a57b91-b224-45f1-a25d-938dbec2ad0f}']
		function GetOpen() : TSGBoolean;
		function GetOpenTimer() : TSGScreenTimer;

		property Open : TSGBoolean read GetOpen;
		property OpenTimer : TSGScreenTimer read GetOpenTimer;
		end;

	TSGComboBoxItemIdentifier = TSGInt64;
	PSGComboBoxItem = ^ TSGComboBoxItem;
	TSGComboBoxItem = object
			protected
		FImage      : TSGImage;
		FCaption    : TSGCaption;
		FIdentifier : TSGComboBoxItemIdentifier;
		FActive     : TSGBoolean;
		FSelected   : TSGBoolean;
		FOver       : TSGBoolean;
			public
		procedure Clear();
			public
		property Selected   : TSGBoolean                read FSelected   write FSelected;
		property Over       : TSGBoolean                read FOver       write FOver;
		property Active     : TSGBoolean                read FActive     write FActive;
		property Caption    : TSGCaption                read FCaption    write FCaption;
		property Text       : TSGCaption                read FCaption    write FCaption;
		property Identifier : TSGComboBoxItemIdentifier read FIdentifier write FIdentifier;
		property Image      : TSGImage                  read FImage      write FImage;
		end;

	TSGComboBoxItemList = packed array of TSGComboBoxItem;

	ISGComboBox = interface(ISGOpenComponent)
		['{5859810e-163e-4f5d-9622-7b574ebe07d5}']
		function GetItems() : PSGComboBoxItem;
		function GetItemsCount() : TSGUInt32;
		function GetLines() : TSGUInt32;
		function GetSelectedItem() : PSGComboBoxItem;
		function GetFirstItemIndex() : TSGUInt32;

		property FirstItemIndex : TSGUInt32 read GetFirstItemIndex;
		property Lines          : TSGUInt32 read GetLines;
		property ItemsCount     : TSGUInt32 read GetItemsCount;
		property Items          : PSGComboBoxItem read GetItems;
		end;

	TSGEditTextType         = TSGExByte;
	ISGEdit = interface(ISGOverComponent)
		['{468c7f6f-795a-48a1-b5be-615448c2dcbe}']
		function GetTextType() : TSGEditTextType;
		function GetTextComplite() : TSGBoolean;
		function GetCursorPosition() : TSGInt32;
		function GetTextTypeAssigned() : TSGBoolean;
		function GetCursorTimer() : TSGScreenTimer;
		function GetTextCompliteTimer() : TSGScreenTimer;
		function GetNowEditing() : TSGBool;
		
		property NowEditing        : TSGBool         read GetNowEditing;
		property TextCompliteTimer : TSGScreenTimer  read GetTextCompliteTimer;
		property CursorTimer       : TSGScreenTimer  read GetCursorTimer;
		property TextTypeAssigned  : TSGBoolean      read GetTextTypeAssigned;
		property TextType          : TSGEditTextType read GetTextType;
		property TextComplite      : TSGBoolean      read GetTextComplite;
		property CursorPosition    : TSGInt32        read GetCursorPosition;
		end;

	TSGProgressBarFloat = TSGFloat64;
	PSGProgressBarFloat = ^ TSGProgressBarFloat;
	ISGProgressBar = interface(ISGComponent)
		['{d3781f76-15e1-4537-9886-c6f98787cade}']
		function GetProgress() : TSGProgressBarFloat;
		function GetColor() : TSGScreenSkinFrameColor;
		function GetIsColorStatic() : TSGBool;
		function GetProgressTimer() : TSGProgressBarFloat;
		function GetViewCaption() : TSGBool;
		function GetViewProgress() : TSGBool;

		property ViewProgress  : TSGBool                 read GetViewProgress;
		property ViewCaption   : TSGBool                 read GetViewCaption;
		property ProgressTimer : TSGProgressBarFloat     read GetProgressTimer;
		property Progress      : TSGProgressBarFloat     read GetProgress;
		property Color         : TSGScreenSkinFrameColor read GetColor;
		property IsColorStatic : TSGBool                 read GetIsColorStatic;
		end;

function SGComponentLocationImport(const VPosition, VSize : TSGComponentLocationVectorType) : TSGComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
function SGComponentLocationImport(const VLeft, VTop, VWidth, VHeight : TSGComponentLocationType) : TSGComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;

implementation

function SGComponentLocationImport(const VLeft, VTop, VWidth, VHeight : TSGComponentLocationType) : TSGComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result := SGComponentLocationImport(SGVertex2fImport(VLeft, VTop), SGVertex2fImport(VWidth, VHeight));
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

procedure TSGComboBoxItem.Clear();
begin
if (FImage as TSGImage) <> nil then
	FImage.Destroy();
FImage      := nil;
FCaption    := '';
FIdentifier := 0;
FActive     := False;
FSelected   := False;
FOver       := False;
end;

function SGComponentLocationImport(const VPosition, VSize : TSGComponentLocationVectorType) : TSGComponentLocation; {$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
Result.Import(VPosition, VSize);
end;

procedure TSGComponentLocation.Import(const VPosition, VSize : TSGComponentLocationVectorType ); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FPosition := VPosition;
FSize     := VSize;
end;

end.
