{$INCLUDE Includes\SaGe.inc}

//{$DEFINE CLHINTS}
//{$DEFINE SCREEN_DEBUG}

unit SaGeScreen;

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
	TSGAnchors = type TSGExByte;
const
	SGAnchRight  : TSGAnchors =  $11;
	SGAnchLeft   : TSGAnchors =   $12;
	SGAnchTop    : TSGAnchors =    $13;
	SGAnchBottom :TSGAnchors = $14;
	
	SGS_LEFT   = 1;
	SGS_BOTTOM = 2;
	SGS_RIGHT  = 3;
	SGS_TOP    = 4;

type
	TSGSTimer = TSGFloat;

	TSGForm             = class;
	TSGButton           = class;
	TSGEdit             = class;
	TSGLabel            = class;
	TSGProgressBar      = class;
	TSGPanel            = class;
	TSGPicture          = class;
	TSGButtonMenu       = class;
	TSGScrollBar        = class;
	TSGComboBox         = class;
	TSGGrid             = class;
	TSGButtonMenuButton = class;
	TSGScreen           = class;
	
	TSGComponent          = class;
	
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
	
	PTSGComponent         = ^ TSGComponent;
	TSGArTSGComponent     = type packed array of TSGComponent;
	TArTSGComponent       = TSGArTSGComponent;
	TArTArTSGComponent    = type packed array of TArTSGComponent;
	TSGComponentProcedure = procedure ( Component : TSGComponent );
	TSGComponent = class(TSGContextabled, ISGDeviceDependent)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		// for-in loop
		function GetEnumerator(): TSGComponentEnumerator;
		function GetReverseEnumerator: TSGComponentEnumerator;
			private
		function GetOption(const VName : TSGString) : TSGPointer;virtual;abstract;
		procedure SetOption(const VName : TSGString; const VValue : TSGPointer);virtual;abstract;
			public
		procedure Paint();virtual;
		procedure DeleteDeviceResourses();virtual;
		procedure LoadDeviceResourses();virtual;
		function Suppored() : TSGBoolean;virtual;
			private
		FWidth:LongInt;
		FHeight:LongInt;
			public
		FParent:TSGComponent;
		FLeft:LongInt;
		FTop:LongInt;
			//Сохраненные координаты
		FNoneTop:LongInt;
		FNoneLeft:LongInt;
		FNoneHeight:LongInt;
		FNoneWidth:LongInt;
			//К чему стремиться[?]
		FNeedLeft:LongInt;
		FNeedTop:LongInt;
		FNeedWidth:LongInt;
		FNeedHeight:LongInt;
		
		FTopShiftForChilds:LongInt;
		FLeftShiftForChilds:LongInt;
		FRightShiftForChilds:LongInt;
		FBottomShiftForChilds:LongInt;
		
		FRealLeft:LongInt;
		FRealTop:LongInt;
		
		FUnLimited:Boolean;
		
		procedure SetRight(NewRight:LongInt);
		procedure SetBottom(NewBottom:LongInt);
		function GetRight:LongInt;
		function GetBottom : LongInt;
		function GetScreenWidth : longint;
		function GetScreenHeight : longint;
		function UpDateObj(var Obj,NObj:LongInt):Longint;
		procedure UpDateObjects;virtual;
		procedure TestCoords;virtual;
			public
		property Width : LongInt read FNeedWidth write FNeedWidth;
		property Height : LongInt read FNeedHeight write FNeedHeight;
		property Left : LongInt read FLeft write FLeft;
		property Top : LongInt read FTop write FNeedTop;
		property Parent : TSGComponent read FParent write FParent;
		property Bottom : longint read GetBottom write SetBottom;
		property Right : longint read GetRight write SetRight;
		property ScreenWidth : longint read GetScreenWidth;
		property ScreenHeight : longint read GetScreenHeight;
		property UnLimited : boolean read FUnLimited write fUnLimited;
			public
		procedure BoundsToNeedBounds();virtual;
		procedure SetShifts(const NL,NT,NR,NB:LongInt);virtual;
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:LongInt);virtual;
		procedure SetMiddleBounds(const NewWidth,NewHeight:LongInt);virtual;
		procedure WriteBounds();
		class function RandomOne():LongInt;
		procedure AddToLeft(const Value:LongInt);
		procedure AddToWidth(const Value:LongInt);
		procedure AddToHeight(const Value:LongInt);
		procedure AddToTop(const Value:LongInt);
			public
		FAlign:TSGExByte;
		FAnchors:TSGSetOfByte;
		FAnchorsData:packed record
			FParentWidth,FParentHeight:LongWord;
			end;
		FVisible : Boolean;
		FVisibleTimer : TSGSTimer;
		FActive : Boolean;
		FActiveTimer  : TSGSTimer;
		
		FCaption:SGCaption;
		FFont:TSGFont;
		
		procedure UpgradeTimers();virtual;
		procedure UpgradeTimer(const  Flag:Boolean; var Timer : TSGSTimer; const Mnozhitel:LongInt = 1;const Mn2:single = 1);
		procedure FromDraw();virtual;
		procedure FromResize();virtual;
		procedure FromUpDate(var FCanChange:Boolean);virtual;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);virtual;
		procedure FromUpDateCaptionUnderCursor(var CanRePleace:Boolean);virtual;
			protected
		procedure SetVisible(const b:Boolean);virtual;
		procedure SetCaption(const NewCaption:SGCaption);virtual;
			public
		function ReqursiveActive():Boolean;
			public
		property VisibleTimer : TSGSTimer read FVisibleTimer write FVisibleTimer;
		property ActiveTimer : TSGSTimer read FActiveTimer write FActiveTimer;
		property Caption : SGCaption read FCaption write FCaption;
		property FText : SGCaption read FCaption write FCaption;
		property Text : SGCaption read FCaption write FCaption;
		property Font: TSGFont read FFont write FFont;
		property Visible : Boolean read FVisible write SetVisible;
		property Active : Boolean read FActive write FActive default False;
		property Anchors : TSGSetOfByte read FAnchors write FAnchors;
		function NotVisible:boolean;virtual;
			public
		FChildren:TSGArTSGComponent;
		FCursorOnComponent:Boolean;
		FCursorOnComponentCaption:Boolean;
		FCanHaveChildren:Boolean;
		FComponentProcedure:TSGComponentProcedure;
		FChildrenPriority:TSGMaxEnum;
		FMarkedForDestroy : TSGBoolean;
		procedure ClearPriority();
		procedure MakePriority();
		function GetPriorityComponent() : TSGComponent;
		function CursorInComponent():boolean;virtual;
		function CursorInComponentCaption():boolean;virtual;
		function GetVertex(const THAT:TSGSetOfByte;const FOR_THAT:TSGExByte): TSGPoint2int32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function BottomShift():LongInt;
		function RightShift():LongInt;
			public
		procedure ToFront();
		property MarkedForDestroy : TSGBoolean read FMarkedForDestroy;
		function MustDestroyed() : TSGBoolean;
		procedure MarkForDestroy();
		property ChildrenPriority : TSGMaxEnum write FChildrenPriority;
		property ComponentProcedure : TSGComponentProcedure read FComponentProcedure write FComponentProcedure;
		property CursorOnComponent : Boolean read FCursorOnComponent write FCursorOnComponent;
		property CursorOnComponentCaption : Boolean read FCursorOnComponentCaption write FCursorOnComponentCaption;
		function GetChild(a:Int):TSGComponent;
		property Children[Index : Int (* Indexing [1..Size] *)]:TSGComponent read GetChild;
		function CreateChild(const Child : TSGComponent) : TSGComponent;
		procedure CompleteChild(const VChild : TSGComponent);
		function LastChild():TSGComponent;
		procedure CreateAlign(const NewAllign:TSGExByte);
		function CursorPosition(): TSGPoint2int32;
		procedure DestroyAlign();
		procedure DestroyParent();
		procedure KillChildren();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure VisibleAll();
		function IndexOf(const VComponent : TSGComponent): TSGLongInt;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property Align : TSGExByte read FAlign write CreateAlign;
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
		FUserPointer1,FUserPointer2,FUserPointer3:Pointer;
		FDrawClass:TSGDrawable;
			public
		property DrawClass : TSGDrawable read FDrawClass write FDrawClass;
			public
		procedure DrawDrawClasses();virtual;
			public
		property UserPointer : Pointer read FUserPointer1 write FUserPointer1;
		end;
	SGComponent = TSGComponent;
	PSGComponent = PTSGComponent;
	
	TSGScreen = class(TSGComponent)
			public
		constructor Create();
		destructor Destroy();override;
			private
		FInProcessing : TSGBoolean;
			public
		procedure Load(const VContext : ISGContext);
		procedure Resize();
		procedure Paint();override;
		procedure DeleteDeviceResourses();override;
		procedure LoadDeviceResourses();override;
		procedure CustomPaint(VCanReplace : TSGBool);
		function UpDateScreen() : TSGBoolean;
			public
		property InProcessing : TSGBoolean read FInProcessing write FInProcessing;
		end;
	
	PSGForm = ^ TSGForm;
	TSGForm = class(TSGComponent)
			public
		constructor Create;
		destructor Destroy;override;
			public
		FButtonsType : SGFrameButtonsType;
		FIcon        : TSGImage;
		FRePlace     : Boolean;
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		procedure FromUpDateCaptionUnderCursor(var CanRePleace:Boolean);override;
		function CursorInComponentCaption():boolean;override;
			public
		procedure FromDraw;override;
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:LongInt);override;
		end;
	
	TSGButton=class(TSGComponent)
			public
		constructor Create;override;
		destructor Destroy;override;
			public
		FCursorOnButtonTimer : TSGSTimer;
		FCursorOnButtonPrev  : TSGBoolean;
		FCursorOnButton      : TSGBoolean;
		FChangingButton      : TSGBoolean;
		FChangingButtonTimer : TSGSTimer;
		FViewImage1          : TSGImage;
		function CursorInComponentCaption():boolean;override;
		procedure FromUpDateCaptionUnderCursor(var CanRePleace:Boolean);override;
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		procedure FromDraw;override;
		end;
	
	TSGLabel=class(TSGComponent)
		FTextColor:TSGColor4f;
		FTextPosition:Int;
		procedure FromDraw;override;
		constructor Create;override;
			private
		function GetTextPosition : Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetTextPosition(const Pos:Boolean);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			public
		property TextPosition:boolean read GetTextPosition write SetTextPosition;
		property TextColor :TSGColor4f read FTextColor write FTextColor;
		end;
	
	TSGProgressBarFloat = real;
	PSGProgressBarFloat = ^ TSGProgressBarFloat;
	TSGProgressBar=class(TSGComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
			private
		FProgress:TSGProgressBarFloat;
		FNeedProgress:TSGProgressBarFloat;
		FViewProgress:Boolean;
		FColor1:TSGColor4f;
		FColor2:TSGColor4f;
		FViewCaption:Boolean;
			public
		procedure FromDraw();override;
			public
		property RealProgress:TSGProgressBarFloat read FProgress write FProgress;
		property Progress:TSGProgressBarFloat read FNeedProgress write FNeedProgress;
		property ViewProgress:Boolean read FViewProgress write FViewProgress;
		property ViewCaption:Boolean read FViewCaption write FViewCaption;
		property Color1:TSGColor4f read FColor1 write FColor1;
		property Color2:TSGColor4f read FColor2 write FColor2;
			public
		procedure DefaultColor();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetProgressPointer() : PSGProgressBarFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;
	
	TSGPanel=class(TSGComponent)
			public
		constructor Create;override;
		destructor Destroy;override;
			public
		FViewLines:Boolean;
		FViewQuad:Boolean;
			public
		procedure FromDraw;override;
			public
		property ViewQuad : Boolean read FViewQuad write FViewQuad;
		property ViewLines : Boolean read FViewLines write FViewLines;
		end;
	
	TSGPicture=class(TSGComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
			private
		FImage       : TSGImage;
		FEnableLines : TSGBoolean;
		FLinesColor  : TSGColor4f;
		FSecondPoint : TSGVertex2f;
			public
		property Image       : TSGImage read FImage write FImage;
		property Picture     : TSGImage read FImage write FImage;
		property EnableLines : TSGBoolean read FEnableLines write FEnableLines;
		property LinesColor  : TSGColor4f read FLinesColor write FLinesColor;
		property SecondPoint : TSGVertex2f read FSecondPoint write FSecondPoint;
			public
		procedure FromDraw();override;
		end;
	
	TSGEditTextType         = TSGExByte;
	TSGEditTextTypeFunction = function (const s:TSGEdit):boolean;
const
	SGEditTypeText    = 0;
	SGEditTypeSingle  = 1;
	SGEditTypeNumber  = 2;
	SGEditTypeUser    = 3;
	SGEditTypeInteger = 4;
	SGEditTypeWay     = 5;

function TSGEditTextTypeFunctionNumber(const s:TSGEdit):boolean;
function TSGEditTextTypeFunctionInteger(const s:TSGEdit):boolean;
function TSGEditTextTypeFunctionWay(const s:TSGEdit):boolean;
type
	TSGEdit=class(TSGComponent)
			public
		constructor Create;override;
		destructor Destroy;override;
			public
		FCursorOnComponentPrev : TSGBoolean;
		FCursorOnComponentTimer:TSGSTimer;
		FCursorPosition:LongInt;
		FNowChanget:Boolean;
		FNowChangetTimer:TSGSTimer;
		FTextType:TSGEditTextType;
		FTextTypeFunction:TSGEditTextTypeFunction;
		FTextComplite:Boolean;
		FTextCompliteTimer:TSGSTimer;
		FDrawCursor:Boolean;
		FDrawCursorTimer:TSGSTimer;
		FDrawCursorElapsedTime:LongWord;
		FDrawCursorElapsedTimeChange:LongWord;
		FDrawCursorElapsedTimeDontChange:LongWord;
			public
		procedure FromDraw;override;
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		procedure TextTypeEvent;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
			protected
		procedure SetCaption(const NewCaption:SGCaption);override;
		procedure SetTextType(const NewTextType:TSGEditTextType);virtual;
			public
		property TextType:TSGEditTextType read FTextType write SetTextType;
		property TextComplite:Boolean read FTextComplite write FTextComplite;
		property TextTypeFunction:TSGEditTextTypeFunction read FTextTypeFunction write FTextTypeFunction;
		end;
	
	TSGButtonMenuProcedure = procedure (a,b:LongInt;p:Pointer);
	TSGButtonMenuButton=class(TSGButton)
			public
		constructor Create;override;
			public
		FIdentifity:Int64;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
			public
		property Identifity : int64 read FIdentifity write FIdentifity;
		end;
	TSGButtonMenu=class(TSGComponent)
			public
		constructor Create;override;
			public
		FActiveButton:longint;
		FButtonTop:longint;
		FActiveButtonTop:longint;
		FLastActiveButton:LongInt;
		FProcedure:TSGButtonMenuProcedure;
		
		FMiddle:boolean;
		FMiddleTop:LongInt;
		
		FSelectNotClick:Boolean;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure BoundsToNeedBounds;override;
			public
		procedure AddButton(const s:string;const FFActive:boolean = False);
		procedure SetButton(const l:LongInt);
		procedure GetMiddleTop;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		property ButtonTop:LongInt read FButtonTop write FButtonTop;
		property ActiveButtonTop:LongInt read FActiveButtonTop write FActiveButtonTop;
		procedure DetectActiveButton;virtual;
		end;
const
	SGScrollBarHorizon =  $00000;
	SGScrollBarVertical = $00001;
type
	TSGScrollBarButton=class(TSGButton)
			public
		constructor Create;override;
		destructor Destroy;override;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		procedure FromDraw;override;
		end;
	TSGScrollBar=class(TSGComponent)
			public
		constructor Create(const NewType:TSGExByte  = SGScrollBarVertical);
		destructor Destroy;override;
			public
		FScrollMax:Int64;
		FScrollHigh:Int64;
		FScrollLow:Int64;
		FScroolType:TSGExByte;
		FBeginingPosition:Int64;
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:LongInt);override;
		procedure UpDateScrollBounds;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		end;
	
	TSGComboBoxProcedure = TSGButtonMenuProcedure;
	TSGComboBox=class(TSGComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		FBackLight:Boolean;
		FBackLightTimer : TSGSTimer;
		FOpenTimer      : TSGSTimer;
		FOpen:boolean;
		FItems:packed array of
			packed record
				FImage:TSGImage;
				FCaption:TSGCaption;
				FID:Int;
				FActive : TSGBoolean;
				end;
		FProcedure:TSGComboBoxProcedure;
		FMaxColumns:longWord;
		FSelectItem:LongInt;
		FFirstScrollItem:LongInt;
		FCursorOnThisItem:LongInt;
		FScrollWidth:LongInt;
		
		FTextColor:TSGColor4f;
		FBodyColor:TSGColor4f;
			public
		//This Oly For Optimizing Draw 
		FRCAr1,FRCAr2:TSGVertex3fList;
		FRCV1,FRCV2:TSGVertex3f;
		
		FClickOnOpenBox:Boolean;
			public
		procedure DrawItem(const Vertex1,Vertex3: TSGPoint2int32;const Color:TSGColor4f;const IDItem:LongInt = -1;const General:Boolean = False);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function Colums:LongInt;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromDraw;override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		function CursorInComponent():boolean;override;
			public
		procedure CreateItem(const ItemCaption:TSGCaption;const ItemImage:TSGImage = nil;const FIdent:Int = -1; const VActive : TSGBoolean = True);
		procedure ClearItems();
		function Items(const Index : TSGLongWord):TSGString;
			public
		property SelectItem : LongInt read FSelectItem write FSelectItem;
		property MaxLines   : LongWord read FMaxColumns write FMaxColumns;
		end;
	
	TSGGrid=class(TSGComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		FItems:TArTArTSGComponent;
		FSelectItems:
			record
				Point1: TSGPoint2int32;
				Point2: TSGPoint2int32;
				end;
		FQuantityXs,FQuantityYs:LongInt;
		FItemWidth,FItemHeight:LongInt;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromDraw;override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		procedure BoundsToNeedBounds;override;
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:LongInt);override;
			public
		procedure CreateItem(const ItemX,ItemY:LongInt;const ItemComponent:TSGComponent);
		function Items(const ItemX,ItemY:LongInt):TSGComponent;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetQuantityXs(const VQuantityXs:LongInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure SetQuantityYs(const VQuantityYs:LongInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		property QuantityXs:LongInt read FQuantityXs write SetQuantityXs;
		property QuantityYs:LongInt read FQuantityYs write SetQuantityYs;
		procedure SetViewPortSize(const VQuantityXs,VQuantityYs:LongInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;
		
	TSGRCButtonType = (SGNoneRadioCheckButton,SGRadioButton,SGCheckButton);
	TSGRadioButton = class;
	TSGRadioGroup = class
			public
		constructor Create();
		destructor Destroy();override;
			private
		FGroup : packed array of TSGRadioButton;
			public
		procedure Add(const RB : TSGRadioButton);
		procedure Del(const RB : TSGRadioButton);
		procedure KillChecked();
		function CheckedIndex() : LongInt;
		end;
	TSGRadioButton = class(TSGComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromDraw;override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
			private
		FChecked : TSGBoolean;
		FGroup : TSGRadioGroup;
		FType : TSGRCButtonType;
		FImage : TSGImage;
		FCursorOnButton : TSGBoolean;
			private
		procedure DrawImage(const x,y:TSGFloat);{$IFDEF SUPPORTINLINE}{$IFDEF SUPPORTINLINE}inline;{$ENDIF}{$ENDIF}
			public
		procedure SetChecked(const c : TSGBoolean;const WithRec : Boolean = True);
		procedure SetCheckedTrue(const c : TSGBoolean);
		procedure SetType(const t : TSGRCButtonType);
			public
		property Checked : TSGBoolean read FChecked write SetCheckedTrue;
		property Group : TSGRadioGroup read FGroup;
		property ButtonType : TSGRCButtonType read FType write SetType;
		end;
var
	SGScreen:TSGScreen = nil;

implementation

uses
	SaGeEngineConfigurationPanel;

var
	SGScreens:packed array of 
			packed record 
			FScreen:TSGScreen;
			FImage:TSGImage;
			end = nil;
	FOldPosition,FNewPosition:LongWord;
	FMoveProgress:Real = 0;
	FMoveVector:TSGVertex2f = (x:0;y:0);

{$IFDEF CLHINTS}
	{$NOTE RadioButton}
	{$ENDIF}

procedure TSGRadioGroup.KillChecked();
var
	i : LongWord;
begin
if FGroup <> nil then if Length(FGroup)<>0 then
	begin
	for i := 0 to High(FGroup) do
		FGroup[i].SetChecked(False,False);
	end;
end;

function TSGRadioGroup.CheckedIndex() : LongInt;
var
	i : LongWord;
begin
Result := -1;
if FGroup <> nil then if Length(FGroup) <> 0 then
	for i := 0 to High(FGroup) do
		if FGroup[i].Checked then
			begin
			Result := i;
			break;
			end;
end;

procedure TSGRadioButton.SetType(const t : TSGRCButtonType);
begin
if t <> FType then
	begin
	FType := t;
	if FImage <> nil then
		FImage.Destroy();
	FImage := TSGImage.Create();
	FImage.Context := Context;
	FImage.Way := '../Data/Textures/' + Iff(FType <> SGCheckButton ,'radiobox','checkbox') + '.sgia';
	FImage.Loading();
	FImage.ToTexture();
	end;
end;

procedure TSGRadioButton.SetCheckedTrue(const c : TSGBoolean);
begin
SetChecked(c,True);
end;

procedure TSGRadioButton.SetChecked(const c : TSGBoolean;const WithRec : Boolean = True);
begin
if (c) then if FGroup <> nil then if WithRec then
	FGroup.KillChecked();
FChecked := c;
end;

procedure TSGRadioGroup.Add(const RB : TSGRadioButton);
var
	i,ii : LongWord;
begin
if FGroup = nil then
	begin
	SetLength(FGroup,1);
	FGroup[0] := RB;
	end
else if Length(FGroup) = 0 then
	begin
	SetLength(FGroup,1);
	FGroup[0] := RB;
	end
else
	begin
	ii := Length(FGroup);
	for i := 0 to High(FGroup) do
		if FGroup[i] = RB then
			begin
			ii := i;
			break;
			end;
	if ii = Length(FGroup) then
		begin
		SetLength(FGroup,Length(FGroup)+1);
		FGroup[High(FGroup)] := RB;
		end;
	end;
end;

procedure TSGRadioGroup.Del(const RB : TSGRadioButton);
var
	i,ii : LongWord;
begin
if FGroup <> nil then if Length(FGroup)<>0 then
	begin
	ii := Length(FGroup);
	for i := 0 to High(FGroup) do
		begin
		if FGroup[i] = RB then
			begin
			ii := i;
			break;
			end;
		end;
	if ii <> Length(FGroup) then
		begin
		for i := ii to High(FGroup)-1 do
			FGroup[i] := FGroup[i+1];
		SetLength(FGroup,Length(FGroup)-1);
		if Length(FGroup) = 0 then
			FGroup := nil;
		end;
	end;
end;

constructor TSGRadioGroup.Create();
begin
FGroup := nil;
end;

destructor TSGRadioGroup.Destroy();
begin
while FGroup <> nil do
	Del(FGroup[0]);
inherited;
end;

constructor TSGRadioButton.Create();
begin
inherited Create();
FLeftShiftForChilds:=0;
FTopShiftForChilds:=0;
FRightShiftForChilds:=0;
FBottomShiftForChilds:=0;
FCanHaveChildren:=False;
FGroup := nil;
FChecked := False;
FType := SGCheckButton;
FImage := nil;
FType := SGNoneRadioCheckButton;
FCursorOnButton := False;
end;

destructor TSGRadioButton.Destroy();
begin
if FGroup <> nil then
	FGroup.Del(Self);
if FImage <> nil then
	FImage.Destroy();
inherited;
end;

procedure TSGRadioButton.FromUpDate(var FCanChange:Boolean);
begin
inherited FromUpDate(FCanChange);
end;

procedure TSGRadioButton.DrawImage(const x,y:TSGFloat);{$IFDEF SUPPORTINLINE}{$IFDEF SUPPORTINLINE}inline;{$ENDIF}{$ENDIF}
begin
Render.Color4f(1,1,1,FVisibleTimer);
FImage.DrawImageFromTwoVertex2fWith2TexPoint(
	SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
	SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
	SGVertex2fImport(0,x),
	SGVertex2fImport(1,y),
	True,SG_2D);
end;

procedure TSGRadioButton.FromDraw();
begin
if (not Checked) and (FImage <> nil) then
	begin
	if not FCursorOnButton then
		begin
		DrawImage(Iff(FType = SGCheckButton,0.27,0.25),0.5);
		end
	else
		begin
		DrawImage(0,0.25);
		end;
	end
else
	begin
	if not FCursorOnButton then
		begin
		DrawImage(Iff(FType = SGCheckButton,0.77,0.75),1);
		end
	else
		begin
		DrawImage(0.5,0.75);
		end;
	end;
FCursorOnButton := False;
inherited FromDraw();
end;

procedure TSGRadioButton.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
if CursorInComponentNow then
	begin
	FCursorOnButton := True;
	if ((Context.CursorKeyPressed = SGLeftCursorButton) and (Context.CursorKeyPressedType = SGUpKey)) and CanRePleace then
		begin
		CanRePleace:=False;
		Context.SetCursorKey(SGNullKey, SGNullCursorButton);
		SetChecked(not Checked, True);
		end
	end;
inherited FromUpDateUnderCursor(CanRePleace,CursorInComponentNow);
end;

{$IFDEF CLHINTS}
	{$NOTE Grid}
	{$ENDIF}

procedure TSGGrid.SetViewPortSize(const VQuantityXs,VQuantityYs:LongInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
QuantityXs:=VQuantityXs;
QuantityYs:=VQuantityYs;
end;

procedure TSGGrid.SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:LongInt);
begin
inherited;
QuantityXs:=QuantityXs;
QuantityYs:=QuantityYs;
end;

procedure TSGGrid.SetQuantityXs(const VQuantityXs:LongInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FQuantityXs:=VQuantityXs;
FItemWidth:=Round(FNeedWidth/FQuantityXs);
end;

procedure TSGGrid.SetQuantityYs(const VQuantityYs:LongInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FQuantityYs:=VQuantityYs;
FItemHeight:=Round(FNeedHeight/FQuantityYs);
end;

procedure TSGGrid.BoundsToNeedBounds;
var
	i,ii:LongInt;
begin
inherited;
for i:=0 to High(FItems) do
	if FItems[i]<>nil then
		for ii:=0 to High(FItems[i]) do
			if FItems[i][ii]<>nil then
				FItems[i][ii].BoundsToNeedBounds;
end;

procedure TSGGrid.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
var
	i,ii:LongInt;
begin
inherited FromUpDateUnderCursor(CanRePleace,CursorInComponentNow);
if CursorInComponentNow then
	for i:=High(FItems) downto Low(FItems) do
		if FItems[i]<>nil then
			for ii:=High(FItems[i]) downto Low(FItems[i]) do
				if FItems[i][ii]<>nil then
					if FItems[i][ii].CursorInComponent() and FItems[i][ii].FVisible and FItems[i][ii].Active then
						begin
						FItems[i][ii].FromUpDateUnderCursor(CanRePleace);
						if FItems[i][ii].CursorInComponentCaption() then
							begin
							FItems[i][ii].FromUpDateCaptionUnderCursor(CanRePleace);
							end;
						Break;
						end;
end;

procedure TSGGrid.FromUpDate(var FCanChange:Boolean);
var
	i,ii:LongInt;
begin
inherited;
for i:=0 to High(FItems) do
	if FItems[i]<>nil then
		for ii:=0 to High(FItems[i]) do
			if FItems[i][ii]<>nil then
				FItems[i][ii].FromUpDate(FCanChange);
end;

procedure TSGGrid.FromDraw;
var
	i,ii:LongInt;
begin
inherited;
for i:=0 to High(FItems) do
	if FItems[i]<>nil then
		for ii:=0 to High(FItems[i]) do
			if FItems[i][ii]<>nil then
				FItems[i][ii].FromDraw;
end;

procedure TSGGrid.CreateItem(const ItemX,ItemY:LongInt;const ItemComponent:TSGComponent);
var
	i,ii:LongInt;
begin
if ItemX>High(FItems) then
	begin
	ii:=High(FItems)+1;
	SetLength(FItems,ItemX+1);
	for i:=ii to High(FItems) do
		FItems[i]:=nil;
	end;
if ItemY>High(FItems[ItemX]) then
	begin
	ii:=High(FItems[ItemX])+1;
	SetLength(FItems[ItemX],ItemY+1);
	for i:=ii to High(FItems[ItemX]) do
		FItems[ItemX][i]:=nil;
	end;
FItems[ItemX][ItemY]:=ItemComponent;
ItemComponent.Parent:=Self;
end;

function TSGGrid.Items(const ItemX,ItemY:LongInt):TSGComponent;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (Length(FItems)<>0) and (ItemX<=High(FItems)) and (ItemX>=0) and (ItemY>=0) and (ItemY<=High(FItems[0])) then
	begin
	Result:=FItems[ItemX][ItemY];
	end
else
	begin
	Result:=nil;
	end;
end;

constructor TSGGrid.Create;
begin
inherited;
FItems:=nil;
QuantityXs:=5;
QuantityYs:=5;
end;

destructor TSGGrid.Destroy;
var
	ii,i:LongInt;
begin
for i:=0 to High(FItems) do
	for ii:=0 to High(FItems[i]) do
		if FItems[i][ii]<>nil then
			FItems[i][ii].Destroy;
inherited;
end;

{$IFDEF CLHINTS}
	{$NOTE ComboBox}
	{$ENDIF}
var
	ComboBoxImage:TSGImage = nil;

function TSGComboBox.Items(const Index : TSGLongWord):TSGString;
begin
if FItems<>nil then
	Result:=FItems[Index].FCaption
else
	Result:='';
end;

procedure TSGComboBox.ClearItems();
begin
SetLength(FItems,0);
FItems:=nil;
FSelectItem := -1;
end;

function TSGComboBox.CursorInComponent():boolean;
begin
Result:=
	(Context.CursorPosition(SGNowCursorPosition).x>=FRealLeft)and
	(Context.CursorPosition(SGNowCursorPosition).x<=FRealLeft+FWidth)and
	(Context.CursorPosition(SGNowCursorPosition).y>=FRealTop)and
	(
	(FOpen and 
		(
		(Context.CursorPosition(SGNowCursorPosition).y<=FRealTop+FHeight*Colums*FOpenTimer)
		or
		(Context.CursorPosition(SGNowCursorPosition).y<=FRealTop+FHeight)
		)
	)
	or
	((not FOpen) and (Context.CursorPosition(SGNowCursorPosition).y<=FRealTop+FHeight))
	);
FCursorOnComponent:=Result;
end;

function TSGComboBox.Colums():LongInt;
begin
if FItems<>nil then
	if FMaxColumns>Length(FItems) then
		Result:=Length(FItems)
	else
		Result:=FMaxColumns
else
	Result:=0;
end;

procedure TSGComboBox.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
{$IFDEF SCREEN_DEBUG}
WriteLn('TSGComboBox.FromUpDateUnderCursor() : Begining');
	{$ENDIF}
if CursorInComponentNow then
	begin
	FBackLight:=True;
	if ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) and (not FOpen) and CanRePleace then
		begin
		FOpen:=True;
		CanRePleace:=False;
		Context.SetCursorKey(SGNullKey, SGNullCursorButton);
		MakePriority();
		end
	else
		FCursorOnThisItem:=-1;
	if FOpen and CanRePleace then
		if ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) then
			begin
			CanRePleace:=False;
			FClickOnOpenBox:=True;
			Context.SetCursorKey(SGNullKey, SGNullCursorButton);
			end;
	if FOpen and (Context.CursorWheel<>SGNullCursorWheel) then
		begin
		if Context.CursorWheel=SGUpCursorWheel then
			begin
			if FFirstScrollItem<>0 then
				FFirstScrollItem-=1;
			end
		else
			begin
			if FFirstScrollItem+Colums-1<>High(FItems) then
				begin
				FFirstScrollItem+=1;
				end;
			end;
		Context.SetCursorWheel(SGNullCursorWheel);
		CanRePleace:=False;
		end;
	end;
inherited FromUpDateUnderCursor(CanRePleace,CursorInComponentNow);
{$IFDEF SCREEN_DEBUG}
WriteLn('TSGComboBox.FromUpDateUnderCursor() : End');
	{$ENDIF}
end;

procedure TSGComboBox.FromUpDate(var FCanChange:Boolean);
var
	i:TSGMaxEnum;
begin
{$IFDEF SCREEN_DEBUG}
WriteLn('TSGComboBox.FromUpDate() : Begining');
	{$ENDIF}
if FOpen and (not FBackLight) and ((not FCanChange) or (Context.CursorKeyPressed<>SGNullCursorButton)) then
	begin
	FOpen:=False;
	ClearPriority();
	end;
if  FOpen and (FCursorOnComponent) then
	begin
	for i:=0 to Colums-1 do
		begin
		if  (Context.CursorPosition(SGNowCursorPosition).y>=FRealTop+FHeight*i*FOpenTimer) and
			(Context.CursorPosition(SGNowCursorPosition).y<=FRealTop+FHeight*(i+1)*FOpenTimer) and
			(((FMaxColumns<Length(FItems)) and 
			(Context.CursorPosition(SGNowCursorPosition).x<=FRealLeft+Width-FScrollWidth)) or (FMaxColumns>=Length(FItems))) and
			FItems[i].FActive then
				begin
				FCursorOnThisItem := FFirstScrollItem + i;
				if FClickOnOpenBox then
					begin
					FCanChange:=False;
					FOpen:=False;
					ClearPriority();
					{$IFDEF SCREEN_DEBUG}
						WriteLn('TSGComboBox.FromUpDate() : Before calling "FProcedure(...)"');
						{$ENDIF}
					if FProcedure<>nil then
						FProcedure(FSelectItem,FCursorOnThisItem,Self);
					{$IFDEF SCREEN_DEBUG}
						WriteLn('TSGComboBox.FromUpDate() : After calling "FProcedure(...)"');
						{$ENDIF}
					FSelectItem:=FCursorOnThisItem;
					Context.SetCursorKey(SGNullKey, SGNullCursorButton);
					FTextColor:=SGVertex4fImport();
					FBodyColor:=SGVertex4fImport();
					if OnChange<>nil then
						OnChange(Self);
					FClickOnOpenBox:=False;
					end;
				Break;
				end;
		end;
	end;
UpgradeTimer(FOpen,FOpenTimer,5);
UpgradeTimer(FBackLight,FBackLightTimer,3,2);
inherited;
{$IFDEF SCREEN_DEBUG}
WriteLn('TSGComboBox.FromUpDate() : End');
	{$ENDIF}
end;

procedure TSGComboBox.DrawItem(const Vertex1,Vertex3: TSGPoint2int32;const Color:TSGColor4f;const IDItem:LongInt = -1;const General:Boolean = False);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if IDItem<>-1 then
	begin
	if FItems[IDItem].FImage<>nil then
		begin
		Render.Color4f(1,1,1,Color.a);
		FItems[IDItem].FImage.DrawImageFromTwoVertex2fAsRatio(
			SGPoint2int32ToVertex3f(Vertex1),
			SGPoint2int32ToVertex3f(SGVertex2int32Import(Vertex1.x+Height,Vertex3.y)),tRUE,0.85);
		Render.Color(Color);
		Font.DrawFontFromTwoVertex2f(
			FItems[IDItem].FCaption,
			SGPoint2int32ToVertex3f(SGVertex2int32Import(Vertex1.x+Height,Vertex1.y)),
			SGPoint2int32ToVertex3f(Vertex3));
		end
	else
		begin
		Render.Color(Color);
		Font.DrawFontFromTwoVertex2f(
			FItems[IDItem].FCaption,
			SGPoint2int32ToVertex3f(Vertex1),
			SGPoint2int32ToVertex3f(Vertex3));
		end;
	end;
if (ComboBoxImage<>nil) and General and (not FOpen) then
	begin
	Render.Color4f(1,1,1,Color.A*FVisibleTimer);
	ComboBoxImage.DrawImageFromTwoVertex2fAsRatio(
		SGVertex3fImport(Vertex3.x-Height,Vertex1.y),
		SGPoint2int32ToVertex3f(Vertex3),
		False,0.5);
	end;
end;

procedure TSGComboBox.FromDraw;
const
	QuikAnime = 15;
const
	FirsColor1:TSGColor4f = (x:0;y:0.5;z:1;w:1);
	FirsColor11:TSGColor4f = (x:0.65;y:0.65;z:0.65;w:1);
	SecondColor1:TSGColor4f = (x:0;y:0.9;z:1;w:1);
	ThreeColor1:TSGColor4f = (x:0.8;y:0.8;z:0.8;w:1);
	
	FirsColor2:TSGColor4f = (x:0;y:0.75;z:1;w:1);
	FirsColor21:TSGColor4f = (x:0.9;y:0.9;z:0.9;w:1);
	SecondColor2:TSGColor4f = (x:0;y:1;z:1;w:1);
	ThreeColor2:TSGColor4f = (x:1;y:1;z:1;w:1);
var
	i:LongInt;
	FScroll:byte = 0;
begin
FScroll:=Byte(FMaxColumns<Length(FItems));
if not CursorInComponent then
	FCursorOnThisItem:=-1;
if (FVisible) or (FVisibleTimer>SGZero) then
	begin
	if  (1-FBackLightTimer>SGZero) and 
		(1-FOpenTimer>SGZero)  then
	SGRoundQuad(Render, 
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		5,10,
		(FirsColor1*FActiveTimer+FirsColor11*(1-FActiveTimer)).WithAlpha(0.3*FVisibleTimer*(1-FBackLightTimer)*(1-FOpenTimer)),
		(FirsColor2*FActiveTimer+FirsColor21*(1-FActiveTimer)).WithAlpha(0.3*FVisibleTimer*(1-FBackLightTimer)*(1-FOpenTimer))*1.3,
		True);
	if  (FBackLightTimer>SGZero) and 
		(1-FOpenTimer>SGZero)  then
	SGRoundQuad(Render,
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		5,10,
		SecondColor1.WithAlpha(0.3*FVisibleTimer*FBackLightTimer*(1-FOpenTimer)),
		SecondColor2.WithAlpha(0.3*FVisibleTimer*FBackLightTimer*(1-FOpenTimer))*1.3,
		True);
	if  (FOpenTimer>SGZero) then
	SGRoundQuad(Render,
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGVertex3fImport(
			GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x,
			GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*Colums*FOpenTimer),
		5,10,
		FBodyColor.WithAlpha(FOpenTimer),
		FBodyColor.WithAlpha(FOpenTimer)*1.3,
		True);
	if FOpen then
		if FCursorOnComponent then
			begin
			FTextColor*=QuikAnime-1;
			FTextColor+=SGVertex4fImport(0,0,0,FVisibleTimer);
			FTextColor/=QuikAnime;
			
			FBodyColor*=QuikAnime-1;
			FBodyColor+=SGVertex4fImport(1,1,1,0.6*FVisibleTimer);
			FBodyColor/=QuikAnime;
			end
		else
			begin
			FTextColor*=QuikAnime-1;
			FTextColor+=SGVertex4fImport(1,1,1,FVisibleTimer);
			FTextColor/=QuikAnime;
			
			FBodyColor*=QuikAnime-1;
			FBodyColor+=ThreeColor1.WithAlpha(0.4*FVisibleTimer);
			FBodyColor/=QuikAnime;
			end
	else
		begin
		FBodyColor*=QuikAnime-1;
		FBodyColor+=ThreeColor1.WithAlpha(0.4*FVisibleTimer);
		FBodyColor/=QuikAnime;
		end;
	if Boolean(FScroll) then
		begin
		if  (FOpenTimer>SGZero)  then
		SGRoundQuad(Render,
			SGVertex3fImport(
				GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x-FScrollWidth,
				GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+FHeight*Colums*FOpenTimer*(FFirstScrollItem/High(FItems))
				),
			SGVertex3fImport(
				GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x,
				GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*Colums*FOpenTimer*((FFirstScrollItem+Colums-1)/High(FItems))),
			5,10,
			ThreeColor1.WithAlpha(0.4*FVisibleTimer*FOpenTimer),
			ThreeColor2.WithAlpha(0.3*FVisibleTimer*FOpenTimer)*1.3,
			True);
		end;
	if FOpen or (FOpenTimer>SGZero) then
		begin
		for i:=0 to Colums-1 do
			begin
			if (FSelectItem=FFirstScrollItem+i) and (FSelectItem<>FCursorOnThisItem) then if FItems[FFirstScrollItem+i].FActive then
				begin
				if  (FOpenTimer>SGZero)  then
				SGRoundQuad(Render,
					SGVertex3fImport(
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x,
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*i*FOpenTimer),
					SGVertex3fImport(
						GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x-FScroll*FScrollWidth,
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*(i+1)*FOpenTimer),
					5,10,
					SGGetColor4fFromLongWord($9740F7).WithAlpha(0.6*FVisibleTimer*FOpenTimer/2),
					SGGetColor4fFromLongWord($9740F7).WithAlpha(0.6*FVisibleTimer*FOpenTimer/2)*1.3,
					True);
				end;
			if (FCursorOnThisItem<>-1) and (FCursorOnThisItem=FFirstScrollItem+i) and (FSelectItem<>FCursorOnThisItem) then  if FItems[FFirstScrollItem+i].FActive then
				begin
				if  (FOpenTimer>SGZero)  then	
				SGRoundQuad(Render,
					SGVertex3fImport(
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x,
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*i*FOpenTimer),
					SGVertex3fImport(
						GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x-FScroll*FScrollWidth,
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*(i+1)*FOpenTimer),
					5,10,
					SGGetColor4fFromLongWord($00FF00).WithAlpha(0.6*FVisibleTimer*FOpenTimer/2),
					SGGetColor4fFromLongWord($00FF00).WithAlpha(0.6*FVisibleTimer*FOpenTimer/2)*1.3,
					True);
				end;
			if (FCursorOnThisItem<>-1) and (FCursorOnThisItem=FFirstScrollItem+i) and (FSelectItem=FCursorOnThisItem) then  if FItems[FFirstScrollItem+i].FActive then
				begin
				if  (FOpenTimer>SGZero) then
				SGRoundQuad(Render,
					SGVertex3fImport(
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x,
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*i*FOpenTimer),
					SGVertex3fImport(
						GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x-FScroll*FScrollWidth,
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*(i+1)*FOpenTimer),
					5,10,
					SGGetColor4fFromLongWord($FF8000).WithAlpha(0.6*FVisibleTimer*FOpenTimer/2),
					SGGetColor4fFromLongWord($FF8000).WithAlpha(0.6*FVisibleTimer*FOpenTimer/2)*1.3,
					True);
				end;
			if FOpenTimer>SGZero then
				begin
				if FItems[FFirstScrollItem+i].FActive then
					DrawItem(
						SGVertex2int32Import(
							Trunc(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x),
							Trunc(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y + Height*i*FOpenTimer)),
						SGVertex2int32Import(
							Trunc(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x-FScroll*FScrollWidth),
							Trunc(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*(i+1)*FOpenTimer)),
						FTextColor.WithAlpha(FOpenTimer),
						FFirstScrollItem+i)
				else
					DrawItem(
						SGVertex2int32Import(
							Trunc(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x),
							Trunc(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*i*FOpenTimer)),
						SGVertex2int32Import(
							Trunc(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x-FScroll*FScrollWidth),
							Trunc(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*(i+1)*FOpenTimer)),
						SGVertex4fImport(1,0,0,1).WithAlpha(FOpenTimer * FVisibleTimer),
						FFirstScrollItem+i);
				end;
			end;
		end;
	if  (1-FOpenTimer>SGZero) and
		(FVisibleTimer>SGZero) and 
		(FSelectItem>=0) and 
		(FSelectItem<=High(FItems)) then
	DrawItem(
		GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT),
		GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT),
		SGVertex4fImport(1,1,1,1-FOpenTimer).WithAlpha(FVisibleTimer),
		FSelectItem,True);
	end;
FBackLight:=False;
inherited;
end;

procedure TSGComboBox.CreateItem(const ItemCaption:TSGCaption;const ItemImage:TSGImage = nil;const FIdent:Int = -1; const VActive : TSGBoolean = True);
begin
if Self <> nil then
	begin
	SetLEngth(FItems, Length(FItems) + 1);
	FItems[High(FItems)].FCaption:= ItemCaption;
	FItems[High(FItems)].FImage  := ItemImage;
	FItems[High(FItems)].FID     := FIdent;
	FItems[High(FItems)].FActive := VActive;
	end;
end;

constructor TSGComboBox.Create();
begin
inherited;
FClickOnOpenBox:=False;
FOpenTimer:=0;
FOpen:=False;
FBackLight:=False;
FBackLightTimer:=0;
FMaxColumns:=30;
FSelectItem:=-1;
FFirstScrollItem:=0;
FCursorOnThisItem:=0;
FScrollWidth:=20;
FRCAr1:=nil;
FRCAr2:=nil;
FRCV1.Import();
FRCV2.Import();
end;

destructor TSGComboBox.Destroy;
begin
inherited;
end;

{$IFDEF CLHINTS}
	{$NOTE ScrollBar}
	{$ENDIF}


procedure TSGScrollBarButton.FromDraw;
var
	COB,CB:Boolean;
begin
COB:=FCursorOnButton;
CB:=FChangingButton;
inherited;
FCursorOnButton:=COB;
FChangingButton:=CB;
end;

procedure SGScrollBarToLow(Button:TSGScrollBarButton);
begin
if Button.Parent.AsScrollBar.FScrollLow<>0 then
	begin
	Button.Parent.AsScrollBar.FScrollLow-=1;
	Button.Parent.AsScrollBar.FScrollHigh-=1;
	end;
end;

procedure SGScrollBarToHigh(Button:TSGScrollBarButton);
begin
if Button.Parent.AsScrollBar.FScrollHigh<>Button.Parent.AsScrollBar.FScrollMax then
	begin
	Button.Parent.AsScrollBar.FScrollLow+=1;
	Button.Parent.AsScrollBar.FScrollHigh+=1;
	end;
end;

procedure TSGScrollBarButton.FromUpDate(var FCanChange:Boolean);
var
	i:LongInt = -1;
	ii:boolean = true;
begin
if FChangingButton and (not (Context.CursorKeysPressed(SGLeftCursorButton))) then
	begin
	FChangingButton:=False;
	end;
if FChangingButton then
	begin 
	while (ii) and (Abs(Parent.AsScrollBar.FBeginingPosition-Context.CursorPosition(SGNowCursorPosition).y)>((Parent.AsScrollBar.Height-2*Parent.AsScrollBar.Width-13)/Parent.AsScrollBar.FScrollMax)) do
		begin
		ii:=False;
		if Parent.AsScrollBar.FBeginingPosition-Context.CursorPosition(SGNowCursorPosition).y>0 then
			begin
			if Parent.AsScrollBar.FScrollLow<>0 then
				begin
				SGScrollBarToLow(Self);
				Parent.AsScrollBar.FBeginingPosition-=Round(((Parent.AsScrollBar.Height-2*Parent.AsScrollBar.Width-13)/Parent.AsScrollBar.FScrollMax));
				ii:=True;
				end;
			end
		else
			if Parent.AsScrollBar.FScrollHigh<>Parent.AsScrollBar.FScrollMax then
				begin
				SGScrollBarToHigh(Self);
				Parent.AsScrollBar.FBeginingPosition+=Round(((Parent.AsScrollBar.Height-2*Parent.AsScrollBar.Width-13)/Parent.AsScrollBar.FScrollMax));
				ii:=True;
				end;
		end;
	end;

UpgradeTimer(FCursorOnButton,FCursorOnButtonTimer,3,2);
UpgradeTimer(FChangingButton,FChangingButtonTimer,5,2);
UpDateObjects;
UpgradeTimers;
for i:=High(FChildren) downto Low(FChildren) do
	FChildren[i].FromUpDate(FCanChange);
if FComponentProcedure<>nil then
	FComponentProcedure(Self);

FCursorOnButton:=False;
end;

procedure TSGScrollBarButton.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
if CursorInComponentNow then
	begin
	FCursorOnButton:=True;
	{if SGMouseKeysDown[0] then
		FChangingButton:=True;}
	if Active and ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) then
		begin
		FChangingButtonTimer:=1;
		case Parent.AsScrollBar.FScroolType of
		SGScrollBarVertical:
			begin
			Parent.AsScrollBar.FBeginingPosition:=Context.CursorPosition(SGNowCursorPosition).y;
			end;
		SGScrollBarHorizon:
			Parent.AsScrollBar.FBeginingPosition:=Context.CursorPosition(SGNowCursorPosition).x;
		end;
		end;
	end;
end;

constructor TSGScrollBarButton.Create;
begin
inherited;
end;

destructor TSGScrollBarButton.Destroy;
begin
inherited;
end;

procedure TSGScrollBar.FromUpDate(var FCanChange:Boolean);
begin
UpDateScrollBounds;
inherited FromUpDate(FCanChange);
end;

procedure TSGScrollBar.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
inherited FromUpDateUnderCursor(CanRePleace,CursorInComponentNow);
end;

procedure TSGScrollBar.UpDateScrollBounds;
begin 
if FScroolType = SGScrollBarVertical then
	begin 
	LastChild.SetBounds(0
		,Width+2+Trunc((Height-2*Width-13)*(FScrollLow/FScrollMax))
		,Width
		,Width+2+Trunc((Height-2*Width-13)*(FScrollHigh/FScrollMax))-(2+Width+Trunc((Height-2*Width-13)*(FScrollLow/FScrollMax)))
		);
	end
else
	if FScroolType = SGScrollBarHorizon then
		begin
		
		end
	else
		begin
		
		end;
end;

procedure TSGScrollBar.SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:LongInt);
begin
inherited SetBounds(NewLeft,NewTop,NewWidth,NewHeight);
if FScroolType = SGScrollBarVertical then
	begin
	FChildren[0].SetBounds(0,0,NewWidth,NewWidth);
	FChildren[1].SetBounds(0,NewHeight-NewWidth,NewWidth,NewWidth);
	UpDateScrollBounds;
	end
else
	if FScroolType = SGScrollBarVertical then
		begin
		FChildren[0].SetBounds(0,0,NewHeight,NewHeight);
		FChildren[1].SetBounds(NewHeight-NewWidth,0,NewHeight,NewHeight);
		UpDateScrollBounds;
		end
	else
		begin
		
		end;
end;

destructor TSGScrollBar.Destroy;
begin
Inherited;
end;

constructor TSGScrollBar.Create(const NewType:TSGExByte  = SGScrollBarVertical);
begin
inherited Create;
FBeginingPosition:=0;
FScroolType:=NewType;
FScrollMax:=20;
FScrollHigh:=15;
FScrollLow:=10;
CreateChild(TSGButton.Create);
LastChild.Caption:='/\';
LastChild.Visible:=True;
LastChild.AsButton.OnChange:=TSGComponentProcedure(@SGScrollBarToLow);
CreateChild(TSGButton.Create);
LastChild.Caption:='\/';
LastChild.Visible:=True;
LastChild.AsButton.OnChange:=TSGComponentProcedure(@SGScrollBarToHigh);
CreateChild(TSGScrollBarButton.Create);
LastChild.Caption:='';
LastChild.Visible:=True;
end;


{$IFDEF CLHINTS}
	{$NOTE ButtonMenu}
	{$ENDIF}

procedure TSGButtonMenu.DetectActiveButton;
var
	i,iii:Longint;
begin
FActiveButton:=-1;
FLastActiveButton:=-1;
iii:=5+FMiddleTop*Byte(FMiddle);
for i:=0 to High(FChildren) do
	begin
	FChildren[i].FNeedTop:=iii;
	if FActiveButton=i then
		begin
		FChildren[i].FNeedHeight:=FActiveButtonTop;
		iii+=FActiveButtonTop+5;
		end
	else
		begin
		FChildren[i].FNeedHeight:=FButtonTop;
		iii+=FButtonTop+5;
		end;
	end;
end;

constructor TSGButtonMenuButton.Create;
begin
inherited;
FIdentifity:=-1;
end;

procedure TSGButtonMenu.BoundsToNeedBounds;
var
	i:LongInt;
begin
inherited;
for i:=0 to High(FChildren) do
	FChildren[i].BoundsToNeedBounds;
end;

procedure TSGButtonMenu.GetMiddleTop;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if Length(FChildren)>0 then
	FMiddleTop:=Round((Height-(LastChild.Top+LastChild.Height-FChildren[0].Top))/2)
else
	FMiddleTop:=0;
end;

procedure TSGButtonMenuButton.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
var
	i,ii:LongInt;
begin
if CursorInComponentNow then
	begin
	if Active and (((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) or Parent.AsButtonMenu.FSelectNotClick) then
		begin
		ii:=-1;
		for i:=0 to High(FParent.FChildren) do
			if FParent.FChildren[i]=Self then
				begin
				ii:=i;
				Break;
				end;
		if FParent.AsButtonMenu.FActiveButton<>ii then
			FParent.AsButtonMenu.SetButton(ii);
		end;
	end;
inherited FromUpDateUnderCursor(CanRePleace,CursorInComponentNow);
end;

procedure TSGButtonMenu.SetButton(const l:LongInt);
var 
	i,iii:LongInt;
begin
GetMiddleTop;
FActiveButton:=l;
if (FProcedure<>nil) and (FLastActiveButton<>FActiveButton) then
	begin
	FProcedure(FLastActiveButton,FActiveButton,Self);
	end;
FLastActiveButton:=FActiveButton;
iii:=5+FMiddleTop*Byte(FMiddle);
for i:=0 to High(FChildren) do
	begin
	FChildren[i].FNeedTop:=iii;
	if FActiveButton=i then
		begin
		FChildren[i].FNeedHeight:=FActiveButtonTop;
		iii+=FActiveButtonTop+5;
		end
	else
		begin
		FChildren[i].FNeedHeight:=FButtonTop;
		iii+=FButtonTop+5;
		end;
	end;
end;

procedure TSGButtonMenu.AddButton(const s:string;const FFActive:boolean = False);
var
	i:LongInt = 5;
	ii:LongInt = 0;
begin
for ii:=0 to High(FChildren) do
	begin
	if ii=0 then
		begin
		if FActiveButton<>-1 then
			i+=5+FActiveButtonTop
		else
			i+=5+FButtonTop;
		end
	else
		i+=5+FButtonTop;
	end;
CreateChild(TSGButtonMenuButton.Create);
LastChild.SetBounds(0,i,FNeedWidth,FButtonTop);
LastChild.Caption:=SGStringToPChar(s);
SetButton(FActiveButton);
end;

constructor TSGButtonMenu.Create;
begin
inherited;
FActiveButton:=-1;
FButtonTop:=30;
FActiveButtonTop:=60;
FProcedure:=nil;
FLastActiveButton:=-1;
FMiddle:=False;
FMiddleTop:=0;
FSelectNotClick:=False;
end;

procedure TSGButtonMenu.FromUpDate(var FCanChange:Boolean);
begin
if FActiveButton<>-1 then
	FChildren[FActiveButton].AsButton.FChangingButtonTimer:=1;
if FLastActiveButton<>FActiveButton then
	SetButton(FActiveButton);
inherited FromUpDate(FCanChange);
end;


{$IFDEF CLHINTS}
	{$NOTE Panel}
	{$ENDIF}

procedure TSGPanel.FromDraw;
var 
	Color2:TSGColor4f = (x:1;y:1;z:1;w:1);
	Color1:TSGColor4f = (x:0;y:0.5;z:1;w:1);
begin
if (FVisible) or (FVisibleTimer>SGZero) then
	begin
	SGRoundQuad(Render,
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		5,10,
		Color1.WithAlpha(0.3*FVisibleTimer),
		Color2.WithAlpha(0.3*FVisibleTimer),
		FViewLines,FViewQuad);
	end;
inherited;
end;

constructor TSGPanel.Create;
begin
inherited;
FViewLines:=True;
FViewQuad:=True;
end;

destructor TSGPanel.Destroy;
begin
inherited;
end;


{$IFDEF CLHINTS}
	{$NOTE Picture}
	{$ENDIF}

procedure TSGPicture.FromDraw;
var
	a,b: TSGVertex3f;
begin
if ((FVisible) or (FVisibleTimer>SGZero)) and (FImage<>nil) then
	begin
	Render.Color4f(1,1,1,FVisibleTimer);
	a := SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT));
	b := SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT));
	FImage.DrawImageFromTwoVertex2fWithTexPoint(a,b,FSecondPoint,True,SG_2D);
	if FEnableLines then
		begin
		Render.Color(FLinesColor);
		Render.BeginScene(SGR_LINE_LOOP);
		Render.Vertex(a);
		Render.Vertex2f(a.x,b.y);
		Render.Vertex(b);
		Render.Vertex2f(b.x,a.y);
		Render.EndScene();
		end;
	end;
inherited;
end;

constructor TSGPicture.Create;
begin
inherited;
FImage:=nil;
FEnableLines := False;
FLinesColor.Import(1,1,1,1);
FSecondPoint.Import(1,1);
end;

destructor TSGPicture.Destroy;
begin
inherited;
end;

{$IFDEF CLHINTS}
	{$NOTE ProgressBar}
	{$ENDIF}
procedure TSGProgressBar.FromDraw;
var 
	Color3:TSGColor4f = (x:1;y:1;z:1;w:1);
	Radius : TSGFloat = 5;
begin
if abs((GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x-GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x)*FProgress)<Radius then
	Radius:=abs((GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x-GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x)*FProgress)/2;
FProgress:=(FProgress*7+FNeedProgress)/8;
if (FVisible) or (FVisibleTimer>SGZero) then
	begin
	SGRoundQuad(Render,
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		Radius,10,
		SGVertex4fImport(0,0,0,0),
		Color3.WithAlpha(0.3*FVisibleTimer)*1.3,
		True,False);
	SGRoundQuad(Render,
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2int32ToVertex3f(
			SGVertex2int32Import(
					GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x +
					Trunc(
						(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x -
						 GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x) * FProgress),
				GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).y
				)
			),
		Radius,10,
		FColor1.WithAlpha(0.3*FVisibleTimer),
		FColor2.WithAlpha(0.3*FVisibleTimer),
		True,True);
	if FViewProgress then
		begin
		if (FFont<>nil) and (FFont.Ready) then
			begin
			Render.Color4f(1,1,1,FVisibleTimer);
			FFont.DrawFontFromTwoVertex2f(
				//SGPCharTotal(SGPCharTotal(SGPCharIf(FViewCaption,Caption),' '),SGPCharTotal(SGStringToPChar(SGFloatToString(100*FProgress,2)),'%')),
				SGStringIf(FViewCaption,Caption)+' '+SGFloatToString(100*FProgress,2)+'%',
				SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
				SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)));
			end;
		end;
	end;
inherited;
end;

function TSGProgressBar.GetProgressPointer() : PSGProgressBarFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := @FNeedProgress;
end;

procedure TSGProgressBar.DefaultColor;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FColor1.Import(0,0.5,1,1);
FColor2.Import(0,0.75,1,1);
end;

constructor TSGProgressBar.Create;
begin
inherited;
FProgress:=0;
FNeedProgress:=0;
FViewProgress:=False;
FViewCaption:=False;
DefaultColor;
end;

destructor TSGProgressBar.Destroy;
begin
inherited;
end;

{$IFDEF CLHINTS}
	{$NOTE Form}
	{$ENDIF}

procedure TSGForm.FromUpDate(var FCanChange:Boolean);
var
	I,Iam:LongInt;
	VPointer:TSGComponent;
begin
if (FParent<>nil) and ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGDownKey)) then
	begin
	Iam:=-1;
	for i:=Low(FParent.FChildren) to High(FParent.FChildren) do
		if FParent.FChildren[i]=Self then
			begin
			Iam:=i;
			VPointer:=FParent.FChildren[i];
			end;
	if Iam<>-1 then
		begin
		for i:=Iam to High(FParent.FChildren)-1 do
			FParent.FChildren[i]:=FParent.FChildren[i+1];
		FParent.FChildren[High(FParent.FChildren)]:=VPointer;
		end;
	end;
if FRePlace then
	begin
	if Context.CursorKeysPressed(SGRightCursorButton) then
		begin
		if FParent<>nil then
			begin
			if  (CursorPosition.x>FParent.FRealLeft) and 
				(CursorPosition.x<FParent.FRealLeft+FParent.FLeftShiftForChilds+10) and 
				(CursorPosition.y>FParent.FRealTop+FParent.FTopShiftForChilds) and 
				(CursorPosition.y<FParent.FRealTop+FParent.FTopShiftForChilds+FParent.FBottomShiftForChilds+FParent.FHeight) then
					begin
					if FAlign<>SGAlignNone then
						DestroyAlign;
					FAlign:=SGAlignLeft;
					end
				else
					if  (CursorPosition.x>FParent.FRealLeft) and 
						(CursorPosition.x<FParent.FRealLeft+FParent.FWidth) and 
						(CursorPosition.y>FParent.FRealTop) and 
						(CursorPosition.y<FParent.FRealTop+FParent.FTopShiftForChilds+10) then
							begin
							if FAlign<>SGAlignNone then
								DestroyAlign;
							FAlign:=SGAlignTop;
							end
						else
							if  (CursorPosition.x>FParent.FRealLeft+FParent.FWidth-FParent.FRightShiftForChilds-10) and 
								(CursorPosition.x<FParent.FRealLeft+FParent.FWidth) and 
								(CursorPosition.y>FParent.FRealTop+FParent.FTopShiftForChilds) and 
								(CursorPosition.y<FParent.FRealTop+FParent.FHeight-FParent.FBottomShiftForChilds) then
									begin
									if FAlign<>SGAlignNone then
										DestroyAlign;
									FAlign:=SGAlignRight;
									end
								else
									if  (CursorPosition.x>FParent.FRealLeft) and 
										(CursorPosition.x<FParent.FRealLeft+FParent.FWidth) and 
										(CursorPosition.y>FParent.FRealTop+FParent.FHeight-FParent.FBottomShiftForChilds-10) and 
										(CursorPosition.y<FParent.FRealTop+FParent.FHeight) then
											begin
											if FAlign<>SGAlignNone then
												DestroyAlign;
											FAlign:=SGAlignBottom;
											end
										else
											begin
											if FAlign<>SGAlignNone then
												DestroyAlign;
											end;
			end;
		AddToLeft(Context.CursorPosition(SGDeferenseCursorPosition).x);
		AddToTop(Context.CursorPosition(SGDeferenseCursorPosition).y);
		end
	else
		begin
		FRePlace:=False;
		if not (FAlign in [SGAlignBottom,SGAlignClient,SGAlignLeft,SGAlignRight,SGAlignTop]) then
			begin
			FNoneHeight:=FNeedHeight;
			FNoneLeft:=FNeedLeft;
			FNoneTop:=FNeedTop;
			FNoneWidth:=FNeedWidth;
			end;
		end;
	end;
inherited FromUpDate(FCanChange);
end;

procedure TSGForm.FromDraw;
begin
if (FVisible) or (FVisibleTimer>SGZero) then
	begin
	if FVisibleTimer>SGZero then
		begin
		SGRoundWindowQuad(Render,
			SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
			SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
			SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_CHILDREN)),
			SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_CHILDREN)),
			Abs(
				SGPoint2int32ToVertex3f(GetVertex([SGS_BOTTOM,SGS_RIGHT],SG_VERTEX_FOR_CHILDREN)) -
				SGPoint2int32ToVertex3f(GetVertex([SGS_BOTTOM,SGS_RIGHT],SG_VERTEX_FOR_PARENT))),
			Abs(
				SGPoint2int32ToVertex3f(GetVertex([SGS_BOTTOM,SGS_RIGHT],SG_VERTEX_FOR_CHILDREN)) -
				SGPoint2int32ToVertex3f(GetVertex([SGS_BOTTOM,SGS_RIGHT],SG_VERTEX_FOR_PARENT))),
			10,
			SGVertex4fImport(
				0,1,1,0.5*FVisibleTimer),
			SGVertex4fImport(
				1,1,1,0.3*FVisibleTimer),
			True,
			SGVertex4fImport(
				0,1,1,0.5*FVisibleTimer)*1.3,
			SGVertex4fImport(
				1,1,1,0.3*FVisibleTimer)*1.3);
		Render.Color4f(1,1,1,FVisibleTimer);
		Font.DrawFontFromTwoVertex2f(FCaption,
			SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
			SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_TOP],SG_VERTEX_FOR_CHILDREN)));
		end;
	end;
inherited FromDraw;
end;

constructor TSGForm.Create;
begin
inherited Create;
FButtonsType:=SGFrameButtonsType0f;
FIcon.Create;
FTopShiftForChilds:=30;
end;

procedure TSGForm.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
inherited FromUpDateUnderCursor(CanRePleace,CursorInComponentNow);
end;

procedure TSGForm.FromUpDateCaptionUnderCursor(var CanRePleace:Boolean);
begin
if ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGDownKey)) and CanRePleace then
	begin
	FRePlace:=True;
	CanRePleace:=False;
	end;
end;

function TSGForm.CursorInComponentCaption():boolean;
begin
Result:=
	(Context.CursorPosition(SGNowCursorPosition).x>=FRealLeft) and 
	(Context.CursorPosition(SGNowCursorPosition).y>=FRealTop) and 
	(Context.CursorPosition(SGNowCursorPosition).y<=FRealTop+FTopShiftForChilds) and 
	(Context.CursorPosition(SGNowCursorPosition).x<=FRealLeft+FWidth);
FCursorOnComponentCaption:=Result;
end;

procedure TSGForm.SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:LongInt);
begin
inherited SetBounds(NewLeft+6,NewTop+31,NewWidth,NewHeight);
Left:=Left+RandomOne*SGFrameAnimationConst;
Top:=Top+RandomOne*SGFrameAnimationConst;
//Width:=Width+RandomOne*SGFrameAnimationConst;
//Height:=Height+RandomOne*SGFrameAnimationConst;
end;

destructor TSGForm.Destroy;
begin
FCaption:='';
FButtonsType:=SGFrameButtonsTypeCleared;
inherited Destroy;
end;

{$IFDEF CLHINTS}
	{$NOTE ComponentEnumerator}
	{$ENDIF}

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

{$IFDEF CLHINTS}
	{$NOTE Component}
	{$ENDIF}

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

procedure TSGComponent.KillChildren;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
while Length(FChildren)>0 do
	begin
	FChildren[High(FChildren)].Destroy;
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

function TSGComponent.GetChild(a:Int):TSGComponent;
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

procedure TSGComponent.SetRight(NewRight:LongInt);
begin
Left:=ScreenWidth-Width-NewRight;
end;

procedure TSGComponent.SetBottom(NewBottom:LongInt);
begin
Top:=ScreenHeight-Height-NewBottom;
end;

function TSGComponent.GetRight:LongInt;
begin
Result:=ScreenWidth-Width-Left;
end;

function TSGComponent.GetBottom : LongInt;
begin
Result:=ScreenHeight-Height-Top;
end;

function TSGComponent.BottomShift:LongInt;
begin
Result:=FTopShiftForChilds+FBottomShiftForChilds;
end;

function TSGComponent.RightShift:LongInt;
begin
Result:=FLeftShiftForChilds+FRightShiftForChilds;
end;

function TSGComponent.LastChild:TSGComponent;
begin
Result:=Nil;
if FChildren <> nil then
	Result := FChildren[High(FChildren)];
end;

function TSGComponent.UpDateObj(var Obj,NObj:LongInt):LongInt;
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

procedure TSGComponent.SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:LongInt);
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

procedure TSGComponent.UpgradeTimer(const  Flag:Boolean; var Timer : TSGSTimer; const Mnozhitel:LongInt = 1;const Mn2:single = 1);
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
UpgradeTimer(FActive,FActiveTimer);
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

destructor TSGComponent.Destroy();
begin
if FDrawClass<>nil then
	FDrawClass.Destroy();
DestroyParent();
inherited Destroy();
end;

function TSGComponent.GetVertex(const THAT:TSGSetOfByte;const FOR_THAT:TSGExByte): TSGPoint2int32;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
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
if VChild.Font = nil then
	VChild.Font := Font;
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

procedure TSGComponent.DeleteDeviceResourses();
var
	Component : TSGComponent;
begin
if FDrawClass <> nil then
	FDrawClass.DeleteDeviceResourses();
for Component in Self do
	Component.DeleteDeviceResourses();
end;

procedure TSGComponent.LoadDeviceResourses();
var
	Component : TSGComponent;
begin
if FDrawClass <> nil then
	FDrawClass.LoadDeviceResourses();
for Component in Self do
	Component.LoadDeviceResourses();
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
	i,ii:TSGMaxEnum;
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
	i, ii : TSGMaxEnum;
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
FFont:=nil;
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

procedure TSGComponent.CreateAlign(const NewAllign:TSGExByte);
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

procedure TSGComponent.SetCaption(const NewCaption:SGCaption);
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

{$IFDEF CLHINTS}
	{$NOTE Edit}
	{$ENDIF}

function TSGEditTextTypeFunctionInteger(const s:TSGEdit):boolean;
var
	i,ii:LongWord;
begin
if S.Caption='' then
	Result:=False
else
	begin
	Result:=True;
	i:=1;
	ii:=0;
	while {S.Caption[i]<>#0}(i<=Length(S.Caption)) do
		begin
		if (ii=1) and (S.Caption[i]=' ') then
			ii:=2;
		if (ii=0) and (S.Caption[i] in ['0'..'9','-']) then
				ii:=1;
		if not (((S.Caption[i] in ['0'..'9','-']) and (ii=1))
			or ((ii=0) and (S.Caption[i]=' ')) 
			or ((ii=2) and (S.Caption[i]=' '))) then
			begin
			Result:=False;
			Break;
			end;
		i+=1;
		end;
	end;
end;

function TSGEditTextTypeFunctionNumber(const s:TSGEdit):boolean;
var
	i,ii:LongWord;
begin
if S.Caption='' then
	Result:=False
else
	begin
	Result:=True;
	i:=1;
	ii:=0;
	while {S.Caption[i]<>#0} i<=Length(s.Caption) do
		begin
		if (ii=1) and (S.Caption[i]=' ') then
			ii:=2;
		if (ii=0) and (S.Caption[i] in ['0'..'9']) then
				ii:=1;
		if not (((S.Caption[i] in ['0'..'9']) and (ii=1))
			or ((ii=0) and (S.Caption[i]=' ')) 
			or ((ii=2) and (S.Caption[i]=' '))) then
			begin
			Result:=False;
			Break;
			end;
		i+=1;
		end;
	end;
end;

function TSGEditTextTypeFunctionWay(const s:TSGEdit):boolean;
begin
Result:=SGResourseFiles.FileExists(s.Caption);
end;

procedure TSGEdit.SetTextType(const NewTextType:TSGEditTextType);
begin
FTextType:=NewTextType;
case FTextType of
SGEditTypeWay:
	FTextTypeFunction:=TSGEditTextTypeFunction(@TSGEditTextTypeFunctionWay);
SGEditTypeSingle:
	begin
	
	end;
SGEditTypeNumber:
	begin
	FTextTypeFunction:=TSGEditTextTypeFunction(@TSGEditTextTypeFunctionNumber);
	end;
SGEditTypeText:
	begin
	FTextTypeFunction:=nil;
	end;
SGEditTypeInteger:
	FTextTypeFunction:=TSGEditTextTypeFunction(@TSGEditTextTypeFunctionInteger);
end;
end;

procedure TSGEdit.SetCaption(const NewCaption:SGCaption);
var
	CC:Boolean = False;
begin
CC:=NewCaption=FCaption;
FCursorPosition:=0;
if not CC then
	begin
	inherited SetCaption(NewCaption);
	TextTypeEvent();
	if OnChange<>nil then
		OnChange(Self);
	end;
end;

procedure TSGEdit.TextTypeEvent;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (FTextType<>SGEditTypeText) and (FTextTypeFunction<>nil) then
	begin
	FTextComplite:=FTextTypeFunction(Self);
	end;
end;

procedure TSGEdit.FromDraw;
var
	FirsColor1:TSGColor4f = (x:0;y:0.5;z:1;w:1);
	SecondColor1:TSGColor4f = (x:0;y:0.9;z:1;w:1);
	ThreeColor1:TSGColor4f = (x:0.95;y:0.95;z:0.95;w:1);
	
	FirsColor2:TSGColor4f = (x:0;y:0.75;z:1;w:1);
	SecondColor2:TSGColor4f = (x:0;y:1;z:1;w:1);
	ThreeColor2:TSGColor4f = (x:1;y:1;z:1;w:1);
	
	FirsColor3:TSGColor4f = (x:0.8;y:0;z:0;w:0.8);
	SecondColor3:TSGColor4f = (x:0.8;y:0;z:0;w:1);
	
	FirsColor4:TSGColor4f = (x:0;y:0.8;z:0;w:0.8);
	SecondColor4:TSGColor4f = (x:0;y:0.8;z:0;w:1);
	
	ReqAct : Boolean = false;
	TempTimer : Real = 0;
begin
if (FVisible) or (FVisibleTimer>SGZero) then
	begin
	if ((not FActive) or (FActiveTimer<1-SGZero)) and (FVisibleTimer>SGZero) then
		begin
		SGRoundQuad(Render,
			SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
			SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
			2,
			10,
			SGVertex4fImport(0,0,0,0),
			ThreeColor2.WithAlpha(0.7*FVisibleTimer*(1-FActiveTimer)),
			True);
		end;
	ReqAct := ReqursiveActive();
	if (1-FNowChangetTimer>SGZero) then
			begin
			TempTimer := (1-FCursorOnComponentTimer)*(1-FNowChangetTimer);
			if not ReqAct then
				TempTimer := 1;
			SGRoundQuad(Render,
				SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
				SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
				2,10,
				((FirsColor1*Byte(FTextType=SGEditTypeText)+
					Byte(FTextType<>SGEditTypeText)*(FirsColor4*FTextCompliteTimer+FirsColor3*(1-FTextCompliteTimer))))
						.WithAlpha(0.3*FVisibleTimer*TempTimer*FActiveTimer),
				((FirsColor2*Byte(FTextType=SGEditTypeText)+
					Byte(FTextType<>SGEditTypeText)*(SecondColor4*FTextCompliteTimer+SecondColor3*(1-FTextCompliteTimer))))
						.WithAlpha(0.3*FVisibleTimer*TempTimer*FActiveTimer)*1.3,
				True);
			end;
	if ReqAct and (FVisibleTimer*FCursorOnComponentTimer*(1-FNowChangetTimer)*FActiveTimer>SGZero) then
	SGRoundQuad(Render,
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		2,10,
		((SecondColor1/1.3+1.3*Byte(FTextType<>SGEditTypeText)*(FirsColor4*FTextCompliteTimer+FirsColor3*(1-FTextCompliteTimer)))/(1+Byte(FTextType<>SGEditTypeText)))
			.WithAlpha(0.3/(1-0.4*(Byte(FTextType<>SGEditTypeText)))*FVisibleTimer*FCursorOnComponentTimer*(1-FNowChangetTimer)*FActiveTimer),
		(((SecondColor2/1.3+1.3*Byte(FTextType<>SGEditTypeText)*(SecondColor4*FTextCompliteTimer+SecondColor3*(1-FTextCompliteTimer))))/(1+Byte(FTextType<>SGEditTypeText)))
			.WithAlpha(0.3/(1-0.4*(Byte(FTextType<>SGEditTypeText)))*FVisibleTimer*FCursorOnComponentTimer*(1-FNowChangetTimer)*FActiveTimer)*1.3,
		True);
	if (FVisibleTimer*FNowChangetTimer*FActiveTimer>SGZero) then
	SGRoundQuad(Render,
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		2,10,
		((ThreeColor1*Byte(FTextType=SGEditTypeText)+
			Byte(FTextType<>SGEditTypeText)*(FirsColor4*FTextCompliteTimer+FirsColor3*(1-FTextCompliteTimer))))
			.WithAlpha(0.4*FVisibleTimer*FNowChangetTimer*FActiveTimer),
		((ThreeColor2*Byte(FTextType=SGEditTypeText)+
			Byte(FTextType<>SGEditTypeText)*(SecondColor4*FTextCompliteTimer+SecondColor3*(1-FTextCompliteTimer))*2))
			.WithAlpha(0.3*FVisibleTimer*FNowChangetTimer*FActiveTimer)*1.3,
		True);
	end;
if (Caption<>'') and (FFont<>nil) and (FFont.Ready) then
	begin
	Render.Color4f(1,1,1,FVisibleTimer);
	FFont.DrawFontFromTwoVertex2f(
		Caption,
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT))+SGX(3),
		SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT))-SGX(6),
		False);
	end;
if FNowChanget and (FDrawCursorTimer>SGZero)  and (FFont<>nil) and (FFont.Ready)then
	begin
	Render.Color4f(1,0.5,0,FVisibleTimer*FDrawCursorTimer);
	FFont.DrawCursorFromTwoVertex2f(
		Caption,FCursorPosition,
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT))+SGX(3),
		SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT))-SGX(6),
		False);
	end;
inherited;
end;

procedure TSGEdit.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin 
if CursorInComponentNow then
	if CanRePleace then
		begin
		if ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGDownKey)) then
			begin
			FNowChanget:=True;
			FDrawCursor:=True;
			FDrawCursorTimer:=1;
			FDrawCursorElapsedTime:=0;
			FDrawCursorElapsedTimeDontChange:=30;
			end;
		end
	else
		if FNowChanget then
			FNowChanget:=False;
inherited FromUpDateUnderCursor(CanRePleace,CursorInComponentNow);
end;

procedure TSGEdit.FromUpDate(var FCanChange:Boolean);
var
	CaptionCharget:Boolean = False;
	CursorChanget:Boolean = False;
begin
if FCanChange then
	begin
	if (not CursorInComponent) and ((Context.CursorKeyPressed <> SGNullCursorButton)) then
		FNowChanget:=False;
	if FNowChanget then
		begin
		if Context.KeyPressedChar=#27 then
			FNowChanget:=False;
		end;
	if FNowChanget and Context.KeyPressed and (Context.KeyPressedType=SGDownKey) then
		begin
		case Context.KeyPressedChar of
		#39://ToRight (Arrow)
			begin
			if FCursorPosition<Length(Caption) then
				FCursorPosition+=1;
			CursorChanget:=True;
			end;
		#37://ToLeft (Arrow)
			begin
			if FCursorPosition>0 then
				FCursorPosition-=1;
			CursorChanget:=True;
			end;
		#13://Enter
			FNowChanget:=False;
		#46: //Delete
			begin  
			if FCursorPosition<Length(Caption) then
				begin
				FCaption:=SGStringGetPart(FCaption,1,FCursorPosition)+
					SGStringGetPart(FCaption,FCursorPosition+2,Length(FCaption));
				CaptionCharget:=True;
				end;
			end;
		#8: //BackSpase
			if FCursorPosition=1 then
				begin
				FCursorPosition:=0;
				FCaption:=SGStringGetPart(FCaption,2,Length(FCaption));
				CaptionCharget:=True;
				end
			else if FCursorPosition<>0 then
				begin
				FCursorPosition-=1;
				FCaption:=SGStringGetPart(FCaption,1,FCursorPosition)+
					SGStringGetPart(FCaption,FCursorPosition+2,Length(FCaption));
				CaptionCharget:=True;
				end;
		Char(SG_ALT_KEY),//Alt
		#17,//Ctrl
		#38,//UpKey(Arrow)
		#40,//DownKey(Arrow)
		#112..#120,///F1..F9
		#123,//F12
		#144,//NumLock
		#45,//Insert
		#27,//Escape
		#19,//Pause (or/and) Break
		#16,//Shift
		#9,//Tab
		#20,//Caps Lock
		#34,#33,//PageDown,PageUp
		#93,//Win Property  (Right Menu Key)
		#91,//Win Menu (Left Menu Key)
		#255,//Screen Яркость(F11,F12 on my netbook)
		#233//Dinamics Volume (F7,F8,F9 on my netbook)
			:;// Do NoThink
		#35://  End
			begin
			FCursorPosition:=Length(Caption);
			CursorChanget:=True;
			end;
		#36:// Home 
			begin
			FCursorPosition:=0;
			CursorChanget:=True;
			end;
		else//Simbol
			begin
			if FCaption='' then
				begin
				FCaption:=
					SGWhatIsTheSimbol(longint(Context.KeyPressedChar),
					Context.KeysPressed(16) , Context.KeysPressed(20));
				FCursorPosition:=1;
				CaptionCharget:=True;
				end
			else
				begin
				FCursorPosition+=1;
				FCaption:=
						SGStringGetPart(FCaption,1,FCursorPosition-1)+
						SGWhatIsTheSimbol(longint(Context.KeyPressedChar),
							Context.KeysPressed(16) , Context.KeysPressed(20))+
						SGStringGetPart(FCaption,FCursorPosition,Length(FCaption));
				CaptionCharget:=True;
				end;
			end;
		end;
		end;
	end
else
	if FNowChanget then
		FNowChanget:=False;
if CaptionCharget then
	begin
	TextTypeEvent();
	if OnChange<>nil then
		OnChange(Self);
	end;
if FNowChanget then
	begin
	if FDrawCursorElapsedTimeDontChange=0 then
		begin
		FDrawCursorElapsedTime+=Context.ElapsedTime;
		if FDrawCursorElapsedTime>=FDrawCursorElapsedTimeChange then
			begin
			FDrawCursor:= not FDrawCursor;
			FDrawCursorElapsedTime:= FDrawCursorElapsedTime mod FDrawCursorElapsedTimeChange;
			end;
		end
	else
		begin
		if FDrawCursorElapsedTimeDontChange<Context.ElapsedTime then
			begin
			FDrawCursorElapsedTime:=Context.ElapsedTime-FDrawCursorElapsedTimeDontChange;
			FDrawCursorElapsedTimeDontChange:=0;
			end
		else
			begin
			FDrawCursorElapsedTimeDontChange-=Context.ElapsedTime;
			end;
		end;
	end;
if CaptionCharget or CursorChanget then
	begin
	FDrawCursor:=True;
	FDrawCursorTimer:=1;
	FDrawCursorElapsedTime:=0;
	FDrawCursorElapsedTimeDontChange:=30;
	end;
if FCursorOnComponent and Active and Visible then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle <> SGC_IBEAM)) then
		Context.Cursor := TSGCursor.Create(SGC_IBEAM);
if FCursorOnComponentPrev and (not FCursorOnComponent) then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle = SGC_IBEAM)) then
	Context.Cursor := TSGCursor.Create(SGC_NORMAL);
FCursorOnComponentPrev := FCursorOnComponent;
UpgradeTimer(FCursorOnComponent,FCursorOnComponentTimer,3);
UpgradeTimer(FNowChanget,FNowChangetTimer,3);
UpgradeTimer(FTextComplite,FTextCompliteTimer,1);
UpgradeTimer(FDrawCursor,FDrawCursorTimer,4);
inherited FromUpDate(FCanChange);
end;

constructor TSGEdit.Create;
begin
inherited;
FCursorOnComponentPrev := False;
FCursorOnComponent     := False;
FCursorPosition        := 0;
FNowChanget            := False;
FNowChangetTimer       := 0;
FTextTypeFunction      := nil;
FTextType              := SGEditTypeText;
FTextComplite          := True;
FDrawCursor            := True;
FDrawCursorTimer       := 1;
FDrawCursorElapsedTime := 0;
FDrawCursorElapsedTimeChange     := 50;
FDrawCursorElapsedTimeDontChange := 30;
end;

destructor TSGEdit.Destroy;
begin
inherited;
end;

{$IFDEF CLHINTS}
	{$NOTE Label}
	{$ENDIF}
constructor TSGLabel.Create;
begin
inherited;
FTextColor.r:=1;
FTextColor.g:=1;
FTextColor.b:=1;
FTextColor.a:=1;
FTextPosition:=1;
end;

function TSGLabel.GetTextPosition : Boolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result:=Boolean(FTextPosition);
end;

procedure TSGLabel.SetTextPosition(const Pos:Boolean);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FTextPosition:=Byte(Pos);
end;

procedure TSGLabel.FromDraw;
begin
if (Caption<>'') and (FFont<>nil) and (FFont.Ready) then
	begin
	Render.Color(FTextColor.WithAlpha(FVisibleTimer));
	FFont.DrawFontFromTwoVertex2f(
		Caption,
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		Boolean(FTextPosition));
	end;
inherited;
end;

{$IFDEF CLHINTS}
	{$NOTE Button}
	{$ENDIF}

procedure TSGButton.FromUpDate(var FCanChange:Boolean);
begin
if not Active then
	begin 
	FCursorOnComponent := False;
	FCursorOnButton    := False;
	FChangingButton    := False;
	end;
if FCursorOnButton and Active and Visible then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle <> SGC_HAND)) then
		Context.Cursor := TSGCursor.Create(SGC_HAND);
if FCursorOnButtonPrev and (not FCursorOnButton) then
	if (Context.Cursor = nil) or ((Context.Cursor <> nil) and (Context.Cursor.StandartHandle = SGC_HAND)) then
	Context.Cursor := TSGCursor.Create(SGC_NORMAL);
FCursorOnButtonPrev := FCursorOnComponent;
UpgradeTimer(FCursorOnButton,FCursorOnButtonTimer,3,2);
UpgradeTimer(FChangingButton,FChangingButtonTimer,5,2);
inherited FromUpDate(FCanChange);
end;

procedure TSGButton.FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);
begin
FCursorOnButton     := CursorInComponentNow;
if CursorInComponentNow then
	begin
	if (Context.CursorKeysPressed(SGLeftCursorButton)) then
		FChangingButton:=True;
	if Active and ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) then
		begin
		if (OnChange<>nil) then
			OnChange(Self);
		FChangingButtonTimer:=1;
		end;
	end;
inherited FromUpDateUnderCursor(CanRePleace,CursorInComponentNow);
end;

procedure TSGButton.FromDraw;
const 
	FirsColor1:TSGColor4f = (x:0;y:0.5;z:1;w:1);
	SecondColor1:TSGColor4f = (x:0;y:0.9;z:1;w:1);
	ThreeColor1:TSGColor4f = (x:0.8;y:0.8;z:0.8;w:1);
	
	FirsColor2:TSGColor4f = (x:0;y:0.75;z:1;w:1);
	SecondColor2:TSGColor4f = (x:0;y:1;z:1;w:1);
	ThreeColor2:TSGColor4f = (x:1;y:1;z:1;w:1);
begin
if (FVisible) or (FVisibleTimer>SGZero) then
	begin
	if FViewImage1<>nil then
		begin
		Render.Color4f(1,1,1,FVisibleTimer);
		FViewImage1.DrawImageFromTwoVertex2f(
			SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
			SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)));
		end;
	if (not Active) or (FActiveTimer<1-SGZero) then
		begin
		SGRoundQuad(Render,
			SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
			SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
			5,10,
			ThreeColor2.WithAlpha(0.7*FVisibleTimer*(1-FActiveTimer))*0.54,
			ThreeColor2.WithAlpha(0.7*FVisibleTimer*(1-FActiveTimer))*0.8,
			True);
		end;
	if  (FActiveTimer>SGZero) and 
		(1-FCursorOnButtonTimer>SGZero) and 
		(1-FChangingButtonTimer>SGZero) and
		(FVisibleTimer>SGZero) then
	SGRoundQuad(Render,
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		5,10,
		FirsColor1.WithAlpha(0.3*FVisibleTimer*(1-FCursorOnButtonTimer)*(1-FChangingButtonTimer)*FActiveTimer),
		FirsColor2.WithAlpha(0.3*FVisibleTimer*(1-FCursorOnButtonTimer)*(1-FChangingButtonTimer)*FActiveTimer)*1.3,
		True);
	if  (FActiveTimer>SGZero) and 
		(FCursorOnButtonTimer>SGZero) and 
		(1-FChangingButtonTimer>SGZero) and
		(FVisibleTimer>SGZero) then
	SGRoundQuad(Render,
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		5,10,
		SecondColor1.WithAlpha(0.3*FVisibleTimer*FCursorOnButtonTimer*(1-FChangingButtonTimer)*FActiveTimer),
		SecondColor2.WithAlpha(0.3*FVisibleTimer*FCursorOnButtonTimer*(1-FChangingButtonTimer)*FActiveTimer)*1.3,
		True);
	if  (FActiveTimer>SGZero) and 
		(FChangingButtonTimer>SGZero) and
		(FVisibleTimer>SGZero) then
	SGRoundQuad(Render,
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		5,
		10,
		ThreeColor1.WithAlpha(0.4*FVisibleTimer*FChangingButtonTimer*FActiveTimer),
		ThreeColor2.WithAlpha(0.3*FVisibleTimer*FChangingButtonTimer*FActiveTimer)*1.3,
		True);
	end;
if (Caption<>'') and (FFont<>nil) and (FFont.Ready) and (FVisibleTimer>SGZero) then
	begin
	Render.Color4f(1,1,1,FVisibleTimer);
	FFont.DrawFontFromTwoVertex2f(
		Caption,
		SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)));
	end;
FCursorOnButton:=False;
FChangingButton:=False;
inherited FromDraw;
end;

procedure TSGButton.FromUpDateCaptionUnderCursor(var CanRePleace:Boolean);
begin
end;

function TSGButton.CursorInComponentCaption():boolean;
begin
Result:=False;
end;

constructor TSGButton.Create();
begin
inherited Create();
FLeftShiftForChilds   := 0;
FTopShiftForChilds    := 0;
FRightShiftForChilds  := 0;
FBottomShiftForChilds := 0;
FCanHaveChildren      := False;
FViewImage1           := nil;
FCursorOnButtonPrev   := False;
FCursorOnButton       := False;
end;

destructor TSGButton.Destroy();
begin
inherited Destroy();
end;

procedure TSGScreen.DeleteDeviceResourses();

procedure PProcessImage(const VImage : TSGImage);
begin
if VImage.Texture <> 0 then
	VImage.DeleteDeviceResourses();
end;

begin 
PProcessImage(Font);
PProcessImage(ComboBoxImage);
inherited;
end;

procedure TSGScreen.LoadDeviceResourses();

procedure PProcessImage(const VImage : TSGImage);
begin
if not (VImage.ReadyGoToTexture or (VImage.Texture <> 0)) then
	VImage.Loading();
end;

begin
PProcessImage(Font);
PProcessImage(ComboBoxImage);
inherited;
end;

constructor TSGScreen.Create();
begin
inherited Create();
FInProcessing := False;
end;

destructor TSGScreen.Destroy();
begin
inherited;
end;

procedure TSGScreen.Load(const VContext : ISGContext);
begin
{$IFDEF ANDROID}SGLog.Sourse('Enterind "SGScreenLoad". Context="'+SGStr(TSGMaxEnum(Pointer(Context)))+'"');{$ENDIF}

SetContext(VContext);
SetShifts(0, 0, 0, 0);
Visible := True;
Resize();

Font := TSGFont.Create(SGFontDirectory + Slash + 'Tahoma.sgf');
Font.SetContext(VContext);
Font.Loading();

ComboBoxImage := TSGImage.Create(SGTextureDirectory + Slash + 'ComboBoxImage.sgia');
ComboBoxImage.SetContext(VContext);
ComboBoxImage.Loading();

{$IFDEF ANDROID}SGLog.Sourse('Leaving "SGScreenLoad".');{$ENDIF}
end;

procedure TSGScreen.Resize();
begin
if RenderAssigned() then if Render.Width <> 0 then if Render.Height <> 0 then
	begin
	SetBounds(0, 0, Render.Width, Render.Height);
	BoundsToNeedBounds();
	FromResize();
	end;
end;

procedure TSGScreen.CustomPaint(VCanReplace : TSGBool);
var
	i : TSGLongWord;
begin
InProcessing := True;
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Before "DrawDrawClasses();"');
	{$ENDIF}
DrawDrawClasses();
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Before over updating');
	{$ENDIF}

Render.LineWidth(1);
Render.InitMatrixMode(SG_2D);

VCanReplace:=False;
for i:=0 to High(SGScreens) do
	if (SGScreens[i].FScreen<>nil) and (SGScreens[i].FScreen<>Self) then
		SGScreens[i].FScreen.FromUpDate(VCanReplace);

{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Before drawing');
	{$ENDIF}

FromDraw();
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Beining');
	{$ENDIF}
InProcessing := False;
end;

function TSGScreen.UpDateScreen() : TSGBoolean;
begin
InProcessing := True;
Result := True;
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.UpDateScreen() : Before "FromUpDateUnderCursor(CanRePleace);"');
	{$ENDIF}
FromUpDateUnderCursor(Result);
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.UpDateScreen() : Before "FromUpDate(CanRePleace);"');
	{$ENDIF}
FromUpDate(Result);
InProcessing := False;
end;

procedure TSGScreen.Paint();
var
	CanRePleace : TSGBoolean;
begin
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Beining, before check ECP');
	{$ENDIF}

if (Context.KeysPressed(SG_CTRL_KEY)) and 
   (Context.KeysPressed(SG_ALT_KEY)) and 
   (Context.KeyPressedType = SGDownKey) and 
   (Context.KeyPressedChar = 'O') and 
   TSGEngineConfigurationPanel.CanCreate(Self) then
	begin
	CreateChild(TSGEngineConfigurationPanel.Create()).FromResize();
	Context.SetKey(SGNullKey,0);
	end;

CanRePleace := UpDateScreen();
CustomPaint(CanRePleace);
end;

initialization
begin
FNewPosition:=0;
FOldPosition:=0;

SGScreen := TSGScreen.Create();

SetLength(SGScreens,1);
SGScreens[Low(SGScreens)].FScreen := SGScreen;
SGScreens[Low(SGScreens)].FImage  := nil;
end;

finalization
begin
if SGScreen <> nil then
	SGScreen.Destroy();
SGScreen := nil;
end;

end.
