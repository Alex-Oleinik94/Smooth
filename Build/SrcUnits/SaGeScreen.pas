{$I Includes\SaGe.inc}
//{$DEFINE CLHINTS}
unit SaGeScreen;

interface

uses
	Crt
	,SaGeCommon
	,SaGeBase, SaGeBased
	,SaGeImages
	,SaGeContext
	,SaGeUtils
	,SaGeRender
	;

type
	TSGAnchors = type TSGByte;
const
	SGAnchRight :TSGAnchors =  $11;
	SGAnchLeft :TSGAnchors =   $12;
	SGAnchTop :TSGAnchors =    $13;
	SGAnchBottom :TSGAnchors = $14;
	
	SGS_LEFT = 1;
	SGS_BOTTOM = 2;
	SGS_RIGHT = 3;
	SGS_TOP = 4;
type
	TSGForm=class;
	
	TSGButton=class;
	TSGEdit=class;
	TSGLabel=class;
	TSGProgressBar=class;
	TSGPanel=class;
	TSGPicture=class;
	TSGButtonMenu=class;
	TSGScrollBar = class;
	TSGComboBox = class;
	TSGGrid=class;
	TSGButtonMenuButton=class;
	
	TSGComponent = class;
	PTSGComponent = ^ TSGComponent;
	TSGArTSGComponent =type packed array of TSGComponent;
	TArTSGComponent = TSGArTSGComponent;
	TArTArTSGComponent = type packed array of TArTSGComponent;
	TSGComponentProcedure = procedure ( Component : TSGComponent );
	TSGComponent=class(TSGContextObject)
			public
		constructor Create;
		destructor Destroy;override;
			private
		FWidth:LongInt;
		FHeight:LongInt;
			public
		FParent:TSGComponent;
		FLeft:LongInt;
		FTop:LongInt;
			//����������� ����������
		FNoneTop:LongInt;
		FNoneLeft:LongInt;
		FNoneHeight:LongInt;
		FNoneWidth:LongInt;
			//� ���� ����������[?]
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
		class function UpDateObj(var Obj,NObj:LongInt):Longint;
		procedure UpDateObjects;virtual;
		procedure TestCoords;virtual;
			public
		property Width : LongInt read FNeedWidth write FNeedWidth;
		property Height : LongInt read FNeedHeight write FNeedHeight;
		property Left : LongInt read FLeft write FLeft;
		property Top : LongInt read FTop write FTop;
		property Parent : TSGComponent read FParent write FParent;
		property Bottom : longint read GetBottom write SetBottom;
		property Right : longint read GetRight write SetRight;
		property ScreenWidth : longint read GetScreenWidth;
		property ScreenHeight : longint read GetScreenHeight;
		property UnLimited : boolean read FUnLimited write fUnLimited;
			public
		procedure BoundsToNeedBounds;virtual;
		procedure SetShifts(const NL,NT,NR,NB:LongInt);virtual;
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:LongInt);virtual;
		procedure SetMiddleBounds(const NewWidth,NewHeight:LongInt);virtual;
		procedure WriteBounds;
		class function RandomOne:LongInt;
		procedure AddToLeft(const Value:LongInt);
		procedure AddToWidth(const Value:LongInt);
		procedure AddToHeight(const Value:LongInt);
		procedure AddToTop(const Value:LongInt);
			public
		FAlign:SGByte;
		FAnchors:SGSetOfByte;
		FAnchorsData:packed record
			FParentWidth,FParentHeight:LongWord;
			end;
		FVisible : Boolean;
		FVisibleTimer : real;
		FActive : Boolean;
		FActiveTimer : real;
		
		FCaption:SGCaption;
		FFont:TSGGLFont;
		
		procedure UpgradeTimers;virtual;
		procedure UpgradeTimer(const Flag:Boolean; var Timer : real; const Mnozhitel:LongInt = 1;const Mn2:single = 1);
		procedure FromDraw;virtual;
		procedure FromResize();virtual;
		procedure FromUpDate(var FCanChange:Boolean);virtual;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean);virtual;
		procedure FromUpDateCaptionUnderCursor(var CanRePleace:Boolean);virtual;
			protected
		procedure SetVisible(const b:Boolean);virtual;
		procedure SetCaption(const NewCaption:SGCaption);virtual;
			public
		property Caption : SGCaption read FCaption write FCaption;
		property FText : SGCaption read FCaption write FCaption;
		property Text : SGCaption read FCaption write FCaption;
		property Font: TSGGLFont read FFont write FFont;
		property Visible : Boolean read FVisible write SetVisible;
		property Active : Boolean read FActive write FActive default False;
		property Anchors : SGSetOfByte read FAnchors write FAnchors;
		function NotVisible:boolean;virtual;
			public
		FChildren:TSGArTSGComponent;
		FCursorOnComponent:Boolean;
		FCursorOnComponentCaption:Boolean;
		FCanHaveChildren:Boolean;
		FComponentProcedure:TSGComponentProcedure;
		function CursorInComponent():boolean;virtual;
		function CursorInComponentCaption():boolean;virtual;
		function GetVertex(const THAT:SGSetOfByte;const FOR_THAT:SGByte):SGPoint;inline;
		function BottomShift:LongInt;
		function RightShift:LongInt;
			public
		property ComponentProcedure : TSGComponentProcedure read FComponentProcedure write FComponentProcedure;
		property CursorOnComponent : Boolean read FCursorOnComponent write FCursorOnComponent;
		property CursorOnComponentCaption : Boolean read FCursorOnComponentCaption write FCursorOnComponentCaption;
		function GetChild(a:Int):TSGComponent;
		property Children[Index : Int ]:TSGComponent read GetChild;
		procedure CreateChild(const Child:TSGComponent);
		function LastChild():TSGComponent;
		procedure CreateAlign(const NewAllign:SGByte);
		function CursorPosition():TSGPoint;
		procedure DestroyAlign();
		procedure DestroyParent;
		procedure KillChildren;inline;
		procedure VisibleAll;
			public
		property Align : SGByte read FAlign write CreateAlign;
			public
		function AsButton:TSGButton;inline;
		function AsForm:TSGForm;inline;
		function AsProgressBar:TSGProgressBar;inline;
		function AsPanel:TSGPanel;inline;
		function AsLabel:TSGLabel;inline;
		function AsPicture:TSGPicture;inline;
		function AsButtonMenu:TSGButtonMenu;inline;
		function AsScrollBar:TSGScrollBar;inline;
		function AsComboBox:TSGComboBox;inline;
		function AsGrid:TSGGrid;inline;
		function AsButtonMenuButton:TSGButtonMenuButton;inline;
		function AsEdit:TSGEdit;inline;
			public 
		OnChange : TSGComponentProcedure ;
		FUserPointer1,FUserPointer2,FUserPointer3:Pointer;
		FDrawClass:TSGDrawClass;
			public
		procedure DrawDrawClasses;virtual;
			public //��� ��� TopShift, ��� � �� ����������� �� ��
		FTopShiftStatus:Packed Record
			FEnable:Boolean;
			FNowTopShift:LongWord;
			end;
		procedure SetTopShiftStatus(const b:Boolean);
		property AutoTopShift:Boolean read FTopShiftStatus.FEnable write SetTopShiftStatus;
		end;
	SGComponent = TSGComponent;
	PSGComponent = PTSGComponent;
	
	PSGForm = ^ TSGForm;
	TSGForm=class(TSGComponent)
			public
		constructor Create;
		destructor Destroy;override;
			public
		FButtonsType:SGFrameButtonsType;
		FIcon:TSGGLImage;
		FRePlace:Boolean;
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean);override;
		procedure FromUpDateCaptionUnderCursor(var CanRePleace:Boolean);override;
		function CursorInComponentCaption():boolean;override;
			public
		procedure FromDraw;override;
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:LongInt);override;
		end;
	
	TSGButton=class(TSGComponent)
			public
		constructor Create;
		destructor Destroy;override;
			public
		FCursorOnButtonTimer:Real;
		FCursorOnButton:Boolean;
		FChangingButton:Boolean;
		FChangingButtonTimer:Real;
		FViewImage1:TSGGLImage;
		function CursorInComponentCaption():boolean;override;
		procedure FromUpDateCaptionUnderCursor(var CanRePleace:Boolean);override;
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean);override;
		procedure FromDraw;override;
		end;
	
	TSGLabel=class(TSGComponent)
		FTextColor:TSGColor4f;
		FTextPosition:Int;
		procedure FromDraw;override;
		constructor Create;
			private
		function GetTextPosition : Boolean;inline;
		procedure SetTextPosition(const Pos:Boolean);inline;
			public
		property TextPosition:boolean read GetTextPosition write SetTextPosition;
		property TextColor :TSGColor4f read FTextColor write FTextColor;
		end;
	
	TSGProgressBar=class(TSGComponent)
			public
		constructor Create;
		destructor Destroy;override;
			public
		FProgress:Real;
		FNeedProgress:Real;
		FViewProgress:Boolean;
		FColor1:TSGColor4f;
		FColor2:TSGColor4f;
		FViewCaption:Boolean;
			public
		procedure FromDraw;override;
			public
		property RealProgress:real read FProgress write FProgress;
		property Progress:real read FNeedProgress write FNeedProgress;
		property ViewProgress:Boolean read FViewProgress write FViewProgress;
		property ViewCaption:Boolean read FViewCaption write FViewCaption;
		property Color1:TSGColor4f read FColor1 write FColor1;
		property Color2:TSGColor4f read FColor2 write FColor2;
		procedure DefaultColor;inline;
		end;
	
	TSGPanel=class(TSGComponent)
			public
		constructor Create;
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
		constructor Create;
		destructor Destroy;override;
			public
		FImage:TSGGLImage;
			public
		procedure FromDraw;override;
		end;
	
	TSGEditTextType=TSGByte;
	TSGEditTextTypeFunction = function (const s:TSGEdit):boolean;
const
	SGEditTypeText = 0;
	SGEditTypeSingle = 1;
	SGEditTypeNumber = 2;
	SGEditTypeUser = 3;
	SGEditTypeInteger = 4;

function TSGEditTextTypeFunctionNumber(const s:TSGEdit):boolean;
function TSGEditTextTypeFunctionInteger(const s:TSGEdit):boolean;

type
	TSGEdit=class(TSGComponent)
			public
		constructor Create;
		destructor Destroy;override;
			public
		FCursorOnComponentTimer:Real;
		FCursorPosition:LongInt;
		FNowChanget:Boolean;
		FNowChangetTimer:real;
		FTextType:TSGEditTextType;
		FTextTypeFunction:TSGEditTextTypeFunction;
		FTextComplite:Boolean;
		FTextCompliteTimer:Real;
		FDrawCursor:Boolean;
		FDrawCursorTimer:Real;
		FDrawCursorElapsedTime:LongWord;
		FDrawCursorElapsedTimeChange:LongWord;
		FDrawCursorElapsedTimeDontChange:LongWord;
			public
		procedure FromDraw;override;
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean);override;
		procedure TextTypeEvent;inline;
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
		constructor Create;
			public
		FIdentifity:Int64;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean);override;
			public
		property Identifity : int64 read FIdentifity write FIdentifity;
		end;
	TSGButtonMenu=class(TSGComponent)
			public
		constructor Create;
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
		procedure GetMiddleTop;inline;
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
		constructor Create;
		destructor Destroy;override;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean);override;
		procedure FromDraw;override;
		end;
	TSGScrollBar=class(TSGComponent)
			public
		constructor Create(const NewType:SGByte  = SGScrollBarVertical);
		destructor Destroy;override;
			public
		FScrollMax:Int64;
		FScrollHigh:Int64;
		FScrollLow:Int64;
		FScroolType:SGByte;
		FBeginingPosition:Int64;
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:LongInt);override;
		procedure UpDateScrollBounds;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean);override;
		end;
	
	TSGComboBoxProcedure = TSGButtonMenuProcedure;
	TSGComboBox=class(TSGComponent)
			public
		constructor Create;
		destructor Destroy;override;
			public
		FBackLight:Boolean;
		FBackLightTimer:real;
		FOpenTimer:real;
		FOpen:boolean;
		FItems:packed array of
			packed record
				FImage:TSGGLImage;
				FCaption:TSGCaption;
				FID:Int;
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
		FRCAr1,FRCAr2:TSGArTSGVertex;
		FRCV1,FRCV2:TSGVertex;
			public
		procedure DrawItem(const Vertex1,Vertex3:TSGPoint2f;const Color:TSGColor4f;const IDItem:LongInt = -1;const General:Boolean = False);inline;
		function Colums:LongInt;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromDraw;override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean);override;
		function CursorInComponent():boolean;override;
			public
		procedure CreateItem(const ItemCaption:TSGCaption;const ItemImage:TSGGLImage = nil;const FIdent:Int = -1);
			public
		property SelectItem:LongInt read FSelectItem write FSelectItem;
		end;
	
	TSGGrid=class(TSGComponent)
			public
		constructor Create;
		destructor Destroy;override;
			public
		FItems:TArTArTSGComponent;
		FSelectItems:
			record
				Point1:TSGPoint2f;
				Point2:TSGPoint2f;
				end;
		FQuantityXs,FQuantityYs:LongInt;
		FItemWidth,FItemHeight:LongInt;
			public
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromDraw;override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean);override;
		procedure BoundsToNeedBounds;override;
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:LongInt);override;
			public
		procedure CreateItem(const ItemX,ItemY:LongInt;const ItemComponent:TSGComponent);
		function Items(const ItemX,ItemY:LongInt):TSGComponent;inline;
		procedure SetQuantityXs(const VQuantityXs:LongInt);inline;
		procedure SetQuantityYs(const VQuantityYs:LongInt);inline;
		property QuantityXs:LongInt read FQuantityXs write SetQuantityXs;
		property QuantityYs:LongInt read FQuantityYs write SetQuantityYs;
		procedure SetViewPortSize(const VQuantityXs,VQuantityYs:LongInt);inline;
		end;
var
	SGScreen:TSGComponent = nil;

procedure SGCLLoad(const Context:PSGCOntext);

implementation

var
	SGScreens:packed array of 
			packed record 
			FScreen:TSGComponent;
			FImage:TSGGLImage;
			end = nil;
	FOldPosition,FNewPosition:LongWord;
	FMoveProgress:Real = 0;
	FMoveVector:TSGVertex2f = (x:0;y:0);

{$IFDEF CLHINTS}
	{$NOTE Grid}
	{$ENDIF}

procedure TSGGrid.SetViewPortSize(const VQuantityXs,VQuantityYs:LongInt);inline;
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

procedure TSGGrid.SetQuantityXs(const VQuantityXs:LongInt);inline;
begin
FQuantityXs:=VQuantityXs;
FItemWidth:=Round(FNeedWidth/FQuantityXs);
end;

procedure TSGGrid.SetQuantityYs(const VQuantityYs:LongInt);inline;
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

procedure TSGGrid.FromUpDateUnderCursor(var CanRePleace:Boolean);
var
	i,ii:LongInt;
begin
inherited;
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

function TSGGrid.Items(const ItemX,ItemY:LongInt):TSGComponent;inline;
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
	ComboBoxImage:TSGGLImage = nil;

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

function TSGComboBox.Colums:LongInt;
begin
if FMaxColumns>Length(FItems) then
	Result:=Length(FItems)
else
	Result:=FMaxColumns;
end;

procedure TSGComboBox.FromUpDateUnderCursor(var CanRePleace:Boolean);
begin
FBackLight:=True;
if ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) and (not FOpen) then
	begin
	FOpen:=True;
	CanRePleace:=False;
	Context.FCursorKeyPressed:=SGNoCursorButton;
	end
else
	FCursorOnThisItem:=-1;
if FOpen and (Context.CursorWheel<>SGNoCursorWheel) then
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
	Context.FCursorWheel:=SGNoCursorWheel;
	CanRePleace:=False;
	end;
inherited;
end;

procedure TSGComboBox.FromUpDate(var FCanChange:Boolean);
var
	i:LongInt;
begin
if FOpen and (not FBackLight) and ((not FCanChange) or (Context.CursorKeyPressed<>SGNoCursorButton)) then
	FOpen:=False;
if FOpen and (FCursorOnComponent) then
	begin
	for i:=0 to Colums-1 do
		begin
		if 		(Context.CursorPosition(SGNowCursorPosition).y>=FRealTop+FHeight*i*FOpenTimer)
			and
				(Context.CursorPosition(SGNowCursorPosition).y<=FRealTop+FHeight*(i+1)*FOpenTimer)
			and
				(((FMaxColumns<Length(FItems)) and (Context.CursorPosition(SGNowCursorPosition).x<=FRealLeft+Width-FScrollWidth)) or (FMaxColumns>=Length(FItems))) then
					begin
					FCursorOnThisItem:=FFirstScrollItem+i;
					if ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) then
						begin
						FCanChange:=False;
						FOpen:=False;
						if FProcedure<>nil then
							FProcedure(FSelectItem,FCursorOnThisItem,Self);
						FSelectItem:=FCursorOnThisItem;
						Context.FCursorKeyPressed:=SGNoCursorButton;
						FTextColor:=SGColorImport();
						FBodyColor:=SGColorImport;
						if OnChange<>nil then
							OnChange(Self);
						end;
					Break;
					end;
		end;
	end;
UpgradeTimer(FOpen,FOpenTimer,5);
UpgradeTimer(FBackLight,FBackLightTimer,3,2);
inherited;
end;

procedure TSGComboBox.DrawItem(const Vertex1,Vertex3:TSGPoint2f;const Color:TSGColor4f;const IDItem:LongInt = -1;const General:Boolean = False);inline;
begin
if IDItem<>-1 then
	begin
	if FItems[IDItem].FImage<>nil then
		begin
		SGColorImport(1,1,1,Color.a).Color(Render);
		FItems[IDItem].FImage.DrawImageFromTwoVertex2fAsRatio(
			SGPoint2fToVertex3f(Vertex1),
			SGPoint2fToVertex3f(SGPoint2fImport(Vertex1.x+Height,Vertex3.y)),tRUE,0.85);
		Color.Color(Render);
		Font.DrawFontFromTwoVertex2f(
			FItems[IDItem].FCaption,
			SGPoint2fToVertex2f(SGPoint2fImport(Vertex1.x+Height,Vertex1.y)),
			SGPoint2fToVertex2f(Vertex3));
		end
	else
		begin
		Color.Color(Render);
		Font.DrawFontFromTwoVertex2f(
			FItems[IDItem].FCaption,
			SGPoint2fToVertex2f(Vertex1),
			SGPoint2fToVertex2f(Vertex3));
		end;
	end;
if (ComboBoxImage<>nil) and General and (not FOpen) then
	begin
	Render.Color4f(1,1,1,Color.A*FVisibleTimer);
	ComboBoxImage.DrawImageFromTwoVertex2fAsRatio(
		SGVertexImport(Vertex3.x-Height,Vertex1.y),
		SGPoint2fToVertex2f(Vertex3),
		False,0.5);
	end;
end;

procedure TSGComboBox.FromDraw;
const
	QuikAnime = 15;
const
	FirsColor1:TSGColor4f = (r:0;g:0.5;b:1;a:1);
	FirsColor11:TSGColor4f = (r:0.65;g:0.65;b:0.65;a:1);
	SecondColor1:TSGColor4f = (r:0;g:0.9;b:1;a:1);
	ThreeColor1:TSGColor4f = (r:0.8;g:0.8;b:0.8;a:1);
	
	FirsColor2:TSGColor4f = (r:0;g:0.75;b:1;a:1);
	FirsColor21:TSGColor4f = (r:0.9;g:0.9;b:0.9;a:1);
	SecondColor2:TSGColor4f = (r:0;g:1;b:1;a:1);
	ThreeColor2:TSGColor4f = (r:1;g:1;b:1;a:1);
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
		SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		5,10,
		(FirsColor1*FActiveTimer+FirsColor11*(1-FActiveTimer)).WithAlpha(0.3*FVisibleTimer*(1-FBackLightTimer)*(1-FOpenTimer)),
		(FirsColor2*FActiveTimer+FirsColor21*(1-FActiveTimer)).WithAlpha(0.3*FVisibleTimer*(1-FBackLightTimer)*(1-FOpenTimer))*1.3,
		True);
	if  (FBackLightTimer>SGZero) and 
		(1-FOpenTimer>SGZero)  then
	SGRoundQuad(Render,
		SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		5,10,
		SecondColor1.WithAlpha(0.3*FVisibleTimer*FBackLightTimer*(1-FOpenTimer)),
		SecondColor2.WithAlpha(0.3*FVisibleTimer*FBackLightTimer*(1-FOpenTimer))*1.3,
		True);
	if  (FOpenTimer>SGZero) then
	SGRoundQuad(Render,
		SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGVertexImport(
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
			FTextColor+=SGColorImport(0,0,0,FVisibleTimer);
			FTextColor/=QuikAnime;
			
			FBodyColor*=QuikAnime-1;
			FBodyColor+=SGColorImport(1,1,1,0.6*FVisibleTimer);
			FBodyColor/=QuikAnime;
			end
		else
			begin
			FTextColor*=QuikAnime-1;
			FTextColor+=SGColorImport(1,1,1,FVisibleTimer);
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
			SGVertexImport(
				GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x-FScrollWidth,
				GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+FHeight*Colums*FOpenTimer*(FFirstScrollItem/High(FItems))
				),
			SGVertexImport(
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
			if (FSelectItem=FFirstScrollItem+i) and (FSelectItem<>FCursorOnThisItem) then
				begin
				if  (FOpenTimer>SGZero)  then
				SGRoundQuad(Render,
					SGVertexImport(
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x,
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*i*FOpenTimer),
					SGVertexImport(
						GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x-FScroll*FScrollWidth,
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*(i+1)*FOpenTimer),
					5,10,
					SGGetColor4fFromLongWord($9740F7).WithAlpha(0.6*FVisibleTimer*FOpenTimer/2),
					SGGetColor4fFromLongWord($9740F7).WithAlpha(0.6*FVisibleTimer*FOpenTimer/2)*1.3,
					True);
				end;
			if (FCursorOnThisItem<>-1) and (FCursorOnThisItem=FFirstScrollItem+i) and (FSelectItem<>FCursorOnThisItem) then
				begin
				if  (FOpenTimer>SGZero)  then	
				SGRoundQuad(Render,
					SGVertexImport(
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x,
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*i*FOpenTimer),
					SGVertexImport(
						GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x-FScroll*FScrollWidth,
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*(i+1)*FOpenTimer),
					5,10,
					SGGetColor4fFromLongWord($00FF00).WithAlpha(0.6*FVisibleTimer*FOpenTimer/2),
					SGGetColor4fFromLongWord($00FF00).WithAlpha(0.6*FVisibleTimer*FOpenTimer/2)*1.3,
					True);
				end;
			if (FCursorOnThisItem<>-1) and (FCursorOnThisItem=FFirstScrollItem+i) and (FSelectItem=FCursorOnThisItem) then
				begin
				if  (FOpenTimer>SGZero) then
				SGRoundQuad(Render,
					SGVertexImport(
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x,
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*i*FOpenTimer),
					SGVertexImport(
						GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x-FScroll*FScrollWidth,
						GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*(i+1)*FOpenTimer),
					5,10,
					SGGetColor4fFromLongWord($FF8000).WithAlpha(0.6*FVisibleTimer*FOpenTimer/2),
					SGGetColor4fFromLongWord($FF8000).WithAlpha(0.6*FVisibleTimer*FOpenTimer/2)*1.3,
					True);
				end;
			if FOpenTimer>SGZero then
			DrawItem(
				SGPoint2fImport(
					GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x,
					GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*i*FOpenTimer),
				SGPoint2fImport(
					GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x-FScroll*FScrollWidth,
					GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).y+Height*(i+1)*FOpenTimer),
				FTextColor.WithAlpha(FOpenTimer),
				FFirstScrollItem+i);
			end;
		end;
	if  (1-FOpenTimer>SGZero) and
		(FVisibleTimer>SGZero) then
	DrawItem(
		GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT),
		GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT),
		SGColorImport(1,1,1,1-FOpenTimer).WithAlpha(FVisibleTimer),
		FSelectItem,True);
	end;
FBackLight:=False;
inherited;
end;

procedure TSGComboBox.CreateItem(const ItemCaption:TSGCaption;const ItemImage:TSGGLImage = nil;const FIdent:Int = -1);
begin
if Self<>nil then
	begin
	SetLEngth(FItems,Length(FItems)+1);
	FItems[High(FItems)].FCaption:=ItemCaption;
	FItems[High(FItems)].FImage:=ItemImage;
	FItems[High(FItems)].FID:=FIdent;
	end;
end;

constructor TSGComboBox.Create;
begin
inherited;
FOpenTimer:=0;
FOpen:=False;
FBackLight:=False;
FBackLightTimer:=0;
FMaxColumns:=10;
FSelectItem:=-1;
FFirstScrollItem:=0;
FCursorOnThisItem:=0;
FScrollWidth:=20;
FRCAr1:=nil;
FRCAr2:=nil;
FRCV1.Import;
FRCV2.Import;
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

procedure TSGScrollBarButton.FromUpDateUnderCursor(var CanRePleace:Boolean);
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

procedure TSGScrollBar.FromUpDateUnderCursor(var CanRePleace:Boolean);
begin
inherited FromUpDateUnderCursor(CanRePleace);
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

constructor TSGScrollBar.Create(const NewType:SGByte  = SGScrollBarVertical);
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

procedure TSGButtonMenu.GetMiddleTop;inline;
begin
if Length(FChildren)>0 then
	FMiddleTop:=Round((Height-(LastChild.Top+LastChild.Height-FChildren[0].Top))/2)
else
	FMiddleTop:=0;
end;

procedure TSGButtonMenuButton.FromUpDateUnderCursor(var CanRePleace:Boolean);
var
	i,ii:LongInt;
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
inherited FromUpDateUnderCursor(CanRePleace);
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
	Color2:TSGColor4f = (r:1;g:1;b:1;a:1);
	Color1:TSGColor4f = (r:0;g:0.5;b:1;a:1);
begin
if (FVisible) or (FVisibleTimer>SGZero) then
	begin
	SGRoundQuad(Render,
		SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		5,10,
		Color1.AddAlpha(0.3*FVisibleTimer),
		Color2.AddAlpha(0.3*FVisibleTimer),
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
begin
if ((FVisible) or (FVisibleTimer>SGZero)) and (FImage<>nil) then
	begin
	Render.Color4f(1,1,1,FVisibleTimer);
	FImage.DrawImageFromTwoVertex2f(
		SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)));
	end;
inherited;
end;

constructor TSGPicture.Create;
begin
inherited;
FImage:=nil;
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
	Color3:TSGColor4f = (r:1;g:1;b:1;a:1);
	Radius:real = 5;
begin
if abs((GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x-GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x)*FProgress)<Radius then
	Radius:=abs((GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x-GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x)*FProgress)/2;
FProgress:=(FProgress*7+FNeedProgress)/8;
if (FVisible) or (FVisibleTimer>SGZero) then
	begin
	SGRoundQuad(Render,
		SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		Radius,10,
		NilColor,
		Color3.WithAlpha(0.3*FVisibleTimer)*1.3,
		True,False);
	SGRoundQuad(Render,
		SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex3f(
			SGPointImport(
				GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x+
				(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT).x-GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT).x)*FProgress,
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
				SGPoint2fToVertex2f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
				SGPoint2fToVertex2f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)));
			end;
		end;
	end;
inherited;
end;

procedure TSGProgressBar.DefaultColor;inline;
begin
FColor1.SetVariables(0,0.5,1,1);
FColor2.SetVariables(0,0.75,1,1);
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
	SGRoundWindowQuad(Render,
		SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_CHILDREN)),
		SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_CHILDREN)),
		SGAbsTwoVertex(
			SGPoint2fToVertex3f(GetVertex([SGS_BOTTOM,SGS_RIGHT],SG_VERTEX_FOR_CHILDREN)),
			SGPoint2fToVertex3f(GetVertex([SGS_BOTTOM,SGS_RIGHT],SG_VERTEX_FOR_PARENT))),
		SGAbsTwoVertex(
			SGPoint2fToVertex3f(GetVertex([SGS_BOTTOM,SGS_RIGHT],SG_VERTEX_FOR_CHILDREN)),
			SGPoint2fToVertex3f(GetVertex([SGS_BOTTOM,SGS_RIGHT],SG_VERTEX_FOR_PARENT))),
		10,
		SGColorImport(
			1,1,1,0.5*FVisibleTimer),
		SGColorImport(
			0,1,1,0.3*FVisibleTimer),
		True,
		SGColorImport(
			1,1,1,0.5*FVisibleTimer)*1.3,
		SGColorImport(
			0,1,1,0.3*FVisibleTimer)*1.3);
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

procedure TSGForm.FromUpDateUnderCursor(var CanRePleace:Boolean);
begin
inherited FromUpDateUnderCursor(CanRePleace);
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
	{$NOTE Component}
	{$ENDIF}
procedure TSGComponent.DrawDrawClasses;
var
	i:LongWord;
begin
if FDrawClass<>nil then
	FDrawClass.Draw;
if FChildren<>nil then
	for i:=0 to  High(FChildren) do
		if FChildren[i]<>nil then
			FChildren[i].DrawDrawClasses;
end;


procedure TSGComponent.SetTopShiftStatus(const b:Boolean);
begin
FTopShiftStatus.FEnable:=b;
if not b then
	begin
	FNeedTop-=FTopShiftStatus.FNowTopShift;
	FTopShiftStatus.FNowTopShift:=0;
	end;
end;

function TSGComponent.AsEdit:TSGEdit;inline;
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

function TSGComponent.AsButtonMenuButton:TSGButtonMenuButton;inline;
begin
if Self is TSGButtonMenuButton then
	Result:=TSGButtonMenuButton(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.AsGrid:TSGGrid;inline;
begin
if Self is TSGGrid then
	Result:=TSGGrid(Pointer(Self))
else
	Result:=nil;
end;

procedure TSGComponent.VisibleAll;
var
	i:LongInt;
begin
FVisibleTimer:=1;
for i:=0 to High(FChildren) do
	FChildren[i].VisibleAll;
end;

procedure TSGComponent.KillChildren;inline;
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

function TSGComponent.AsComboBox:TSGComboBox;inline;
begin
if Self is TSGComboBox then
	Result:=TSGComboBox(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.AsScrollBar:TSGScrollBar;inline;
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
begin
FNeedHeight:=NewHeight;
FNeedWidth:=NewWidth;
FNeedLeft:=Round((Context.Width-NewWidth)/2);
FNeedTop:=Round((Context.Height-NewHeight)/2);
end;

procedure TSGComponent.SetVisible(const b:Boolean);
var i:Int = 0;
begin
FVisible:=b;
for i:=0 to High(FChildren) do
	FChildren[i].Visible:=b;
end;

function TSGComponent.AsButtonMenu:TSGButtonMenu;inline;
begin
if Self is TSGButtonMenu then
	Result:=TSGButtonMenu(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.AsPicture:TSGPicture;inline;
begin
if Self is TSGPicture then
	Result:=TSGPicture(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.AsLabel:TSGLabel;inline;
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

function TSGComponent.AsPanel:TSGPanel;inline;
begin
if Self is TSGPanel then
	Result:=TSGPanel(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.AsProgressBar:TSGProgressBar;inline;
begin
if Self is TSGProgressBar then
	Result:=TSGProgressBar(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.AsButton:TSGButton;inline;
begin
if Self is TSGButton then
	Result:=TSGButton(Pointer(Self))
else
	Result:=nil;
end;

function TSGComponent.AsForm:TSGForm;inline;
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
	Result:=Context.Width;
end;

function TSGComponent.GetScreenHeight : longint;
begin
if FParent<>nil then
	Result:=FParent.Height
else
	Result:=Context.Height;
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
if Length(FChildren)>0 then
	Result:=FChildren[High(FChildren)];
end;

class function TSGComponent.UpDateObj(var Obj,NObj:LongInt):LongInt;
var
	Value:LongInt = 0;
	OldObj:Longint;
begin
OldObj:=Obj;
Value+=Obj*SGFrameFObject;
Value+=NObj*SGFrameFNObject;
Value:=round(Value / (SGFrameFNObject+SGFrameFObject));
Result:=Value-Obj;
Obj:=Value;
if (Obj=OldObj) and (NObj<>Obj) then
	if NObj>Obj then
		Obj+=1
	else
		Obj-=1;
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

procedure TSGComponent.UpgradeTimer(const  Flag:Boolean; var Timer : real; const Mnozhitel:LongInt = 1;const Mn2:single = 1);
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

procedure TSGComponent.UpgradeTimers;
begin
UpgradeTimer(FVisible,FVisibleTimer);
UpgradeTimer(FActive,FActiveTimer);
end;

procedure TSGComponent.DestroyParent;
var
	ii,i:LongInt;
begin
{$IFDEF SGMoreDebuging}
	if FParent<>nil then
		WriteLn('Begin of  "TSGComponent.DestroyParent" ( Length='+SGStr(Length(FParent.FChildren))+' ).')
	else
		WriteLn('Begin of  "TSGComponent.DestroyParent" ( Parent=nil ).');
	{$ENDIF}
if FParent<>nil then
	begin
	ii:=-1;
	for i:=0 to High(FParent.FChildren) do
		begin
		if Pointer(FParent.FChildren[i])=Pointer(Self) then
			begin
			ii:=i;
			Break;
			end;
		end;
	if ii<>-1 then
		begin
		{$IFDEF SGMoreDebuging}
			WriteLn('"TSGComponent.DestroyParent" :  Find Self on '+SGStr(ii+1)+' position .');
			{$ENDIF}
		for i:=ii to High(FParent.FChildren)-1 do
			Pointer(FParent.FChildren[i]):=Pointer(FParent.FChildren[i+1]);
		SetLength(FParent.FChildren,Length(FParent.FChildren)-1);
		end;
	end;
{$IFDEF SGMoreDebuging}
	if FParent<>nil then
		WriteLn('End of  "TSGComponent.DestroyParent" ( Length='+SGStr(Length(FParent.FChildren))+' ).')
	else
		WriteLn('End of  "TSGComponent.DestroyParent" ( Parent=nil ).');
	{$ENDIF}
end;

destructor TSGComponent.Destroy;
begin
if FDrawClass<>nil then
	FDrawClass.Destroy;
DestroyParent;
inherited Destroy;
end;

function TSGComponent.GetVertex(const THAT:SGSetOfByte;const FOR_THAT:SGByte):SGPoint;inline;
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

procedure TSGComponent.CreateChild(const Child:TSGComponent);
begin
if (Child<>nil) and FCanHaveChildren then
	begin
	SetLength(FChildren,Length(FChildren)+1);
	FChildren[High(FChildren)]:=Child;
	Child.SetContext(FContext);
	Child.FParent:=Self;
	if Child.FFont=nil then
		Child.FFont:=FFont;
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
	i:LongInt = 0;
begin
UpDateObjects;
UpgradeTimers;

{for i:=Low(FChildren) to High(FChildren) do
	FChildren[i].FromUpDate(FCanChange);}

while (Length(FChildren)>0) and (i<=High(FChildren)) do
	begin
	FChildren[i].FromUpDate(FCanChange);
	i+=1;
	end;

if FTopShiftStatus.FEnable then
	begin
	if (Context.TopShift<>FTopShiftStatus.FNowTopShift)then
		begin
		FNeedTop-=FTopShiftStatus.FNowTopShift;
		FTopShiftStatus.FNowTopShift:=Context.TopShift();
		FNeedTop+=FTopShiftStatus.FNowTopShift;
		end;
	end;

if FComponentProcedure<>nil then
	FComponentProcedure(Self);
end;

procedure TSGComponent.FromDraw();
var
	i:longint;
begin
For i:=Low(FChildren) to High(FChildren) do
	FChildren[i].FromDraw();
end;


constructor TSGComponent.Create();
begin
inherited Create();
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
FTopShiftStatus.FEnable:=False;
FTopShiftStatus.FNowTopShift:=0;
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
	I:LongWord;
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
				I:=FAnchorsData.FParentHeight-FParent.Height;
				FNeedTop-=I;
				FAnchorsData.FParentHeight:=FParent.Height;
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
if FChildren<>nil then
	for i:=0 to High(FChildren) do
		if FChildren[i]<>nil then
			FChildren[i].FromResize;
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

function TSGComponent.CursorPosition:TSGPoint;
begin
Result:=Context.CursorPosition(SGNowCursorPosition);
end;

procedure TSGComponent.CreateAlign(const NewAllign:SGByte);
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
FCaption:=NewCaption;
end;

procedure TSGComponent.UpDateObjects;
var
	I:longint;
	ValueHeight:LOngInt = 0;
	ValueWidth:LOngInt = 0;
	ValueLeft:LOngInt = 0;
	ValueTop:LOngInt = 0;
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
ValueTop:=FTop;
ValueHeight:=FHeight;
ValueWidth:=FWidth;
ValueLeft:=FLeft;
UpDateObj(FHeight,FNeedHeight);
UpDateObj(FTop,FNeedTop);
UpDateObj(FLeft,FNeedLeft);
UpDateObj(FWidth,FNeedWidth);
TestCoords;
ValueHeight:=FHeight-ValueHeight;
ValueLeft:=FLeft-ValueLeft;
ValueTop:=FTop-ValueTop;
ValueWidth:=FWidth-ValueWidth;
for i:=Low(FChildren) to High(FChildren) do
	FChildren[i].FTop-=ValueTop;
for i:=Low(FChildren) to High(FChildren) do
	FChildren[i].FWidth-=ValueWidth;
for i:=Low(FChildren) to High(FChildren) do
	FChildren[i].FHeight-=ValueHeight;
for i:=Low(FChildren) to High(FChildren) do
	FChildren[i].FLeft-=ValueLeft;
if FParent<>nil then
	begin
	FRealLeft:=FParent.FRealLeft+FLeft+FParent.FLeftShiftForChilds;
	FRealTop:=FParent.FRealTop+FTop+FParent.FTopShiftForChilds;
	end;
end;

procedure TSGComponent.FromUpDateUnderCursor(var CanRePleace:Boolean);
var
	i:LongInt = -1;
	IDComponentUnderCursor:LongInt = -1;
begin
for i:=High(FChildren) downto Low(FChildren) do
	if FChildren[i].CursorInComponent() and FChildren[i].FVisible and FChildren[i].Active then
		begin
		IDComponentUnderCursor:=i;
		Break;
		end;
if (IDComponentUnderCursor>-1) then
	begin
	FChildren[IDComponentUnderCursor].FromUpDateUnderCursor(CanRePleace);
	if FChildren[IDComponentUnderCursor].CursorInComponentCaption() then
		begin
		FChildren[IDComponentUnderCursor].FromUpDateCaptionUnderCursor(CanRePleace);
		end;
	end;
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

procedure TSGEdit.SetTextType(const NewTextType:TSGEditTextType);
begin
FTextType:=NewTextType;
case FTextType of
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

procedure TSGEdit.TextTypeEvent;inline;
begin
if (FTextType<>SGEditTypeText) and (FTextTypeFunction<>nil) then
	begin
	FTextComplite:=FTextTypeFunction(Self);
	end;
end;

procedure TSGEdit.FromDraw;
var
	FirsColor1:TSGColor4f = (r:0;g:0.5;b:1;a:1);
	SecondColor1:TSGColor4f = (r:0;g:0.9;b:1;a:1);
	ThreeColor1:TSGColor4f = (r:0.95;g:0.95;b:0.95;a:1);
	
	FirsColor2:TSGColor4f = (r:0;g:0.75;b:1;a:1);
	SecondColor2:TSGColor4f = (r:0;g:1;b:1;a:1);
	ThreeColor2:TSGColor4f = (r:1;g:1;b:1;a:1);
	
	FirsColor3:TSGColor4f = (r:0.8;g:0;b:0;a:0.8);
	SecondColor3:TSGColor4f = (r:0.8;g:0;b:0;a:1);
	
	FirsColor4:TSGColor4f = (r:0;g:0.8;b:0;a:0.8);
	SecondColor4:TSGColor4f = (r:0;g:0.8;b:0;a:1);
begin
if (FVisible) or (FVisibleTimer>SGZero) then
	begin
	if ((not FActive) or (FActiveTimer<1-SGZero)) and (FVisibleTimer>SGZero) then
		begin
		SGRoundQuad(Render,
			SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
			SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
			2,
			10,
			NilColor,
			ThreeColor2.AddAlpha(0.7*FVisibleTimer*(1-FActiveTimer)),
			True);
		end;
	if (1-FCursorOnComponentTimer>SGZero) and 
		(1-FNowChangetTimer>SGZero) then
	SGRoundQuad(Render,
		SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		2,10,
		((FirsColor1*Byte(FTextType=SGEditTypeText)+
			Byte(FTextType<>SGEditTypeText)*(FirsColor4*FTextCompliteTimer+FirsColor3*(1-FTextCompliteTimer))))
				.AddAlpha(0.3*FVisibleTimer*(1-FCursorOnComponentTimer)*(1-FNowChangetTimer)*FActiveTimer),
		((FirsColor2*Byte(FTextType=SGEditTypeText)+
			Byte(FTextType<>SGEditTypeText)*(SecondColor4*FTextCompliteTimer+SecondColor3*(1-FTextCompliteTimer))))
				.AddAlpha(0.3*FVisibleTimer*(1-FCursorOnComponentTimer)*(1-FNowChangetTimer)*FActiveTimer)*1.3,
		True);
	if (FVisibleTimer*FCursorOnComponentTimer*(1-FNowChangetTimer)*FActiveTimer>SGZero) then
	SGRoundQuad(Render,
		SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		2,10,
		((SecondColor1/1.3+1.3*Byte(FTextType<>SGEditTypeText)*(FirsColor4*FTextCompliteTimer+FirsColor3*(1-FTextCompliteTimer)))/(1+Byte(FTextType<>SGEditTypeText)))
			.AddAlpha(0.3/(1-0.4*(Byte(FTextType<>SGEditTypeText)))*FVisibleTimer*FCursorOnComponentTimer*(1-FNowChangetTimer)*FActiveTimer),
		(((SecondColor2/1.3+1.3*Byte(FTextType<>SGEditTypeText)*(SecondColor4*FTextCompliteTimer+SecondColor3*(1-FTextCompliteTimer))))/(1+Byte(FTextType<>SGEditTypeText)))
			.AddAlpha(0.3/(1-0.4*(Byte(FTextType<>SGEditTypeText)))*FVisibleTimer*FCursorOnComponentTimer*(1-FNowChangetTimer)*FActiveTimer)*1.3,
		True);
	if (FVisibleTimer*FNowChangetTimer*FActiveTimer>SGZero) then
	SGRoundQuad(Render,
		SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		2,10,
		((ThreeColor1*Byte(FTextType=SGEditTypeText)+
			Byte(FTextType<>SGEditTypeText)*(FirsColor4*FTextCompliteTimer+FirsColor3*(1-FTextCompliteTimer))))
			.AddAlpha(0.4*FVisibleTimer*FNowChangetTimer*FActiveTimer),
		((ThreeColor2*Byte(FTextType=SGEditTypeText)+
			Byte(FTextType<>SGEditTypeText)*(SecondColor4*FTextCompliteTimer+SecondColor3*(1-FTextCompliteTimer))*2))
			.AddAlpha(0.3*FVisibleTimer*FNowChangetTimer*FActiveTimer)*1.3,
		True);
	end;
if (Caption<>'') and (FFont<>nil) and (FFont.Ready) then
	begin
	Render.Color4f(1,1,1,FVisibleTimer);
	FFont.DrawFontFromTwoVertex2f(
		Caption,
		SGPoint2fToVertex2f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT))+SGX(3),
		SGPoint2fToVertex2f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT))-SGX(6),
		False);
	end;
if FNowChanget and (FDrawCursorTimer>SGZero)  and (FFont<>nil) and (FFont.Ready)then
	begin
	Render.Color4f(1,0.5,0,FVisibleTimer*FDrawCursorTimer);
	FFont.DrawCursorFromTwoVertex2f(
		Caption,FCursorPosition,
		SGPoint2fToVertex2f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT))+SGX(3),
		SGPoint2fToVertex2f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT))-SGX(6),
		False);
	end;
inherited;
end;

procedure TSGEdit.FromUpDateUnderCursor(var CanRePleace:Boolean);
begin 
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
inherited FromUpDateUnderCursor(CanRePleace);
end;

procedure TSGEdit.FromUpDate(var FCanChange:Boolean);
var
	CaptionCharget:Boolean = False;
	CursorChanget:Boolean = False;
begin
if FCanChange then
	begin
	if (not CursorInComponent) and ((Context.CursorKeyPressed<>SGNoCursorButton)) then
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
		#255,//Screen �������(F11,F12 on my netbook)
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
				{FCaption:=SGStringToPChar(SGWhatIsTheSimbol(longint(Context.KeyPressedChar),
					Context.KeysPressed(16) , Context.KeysPressed(20)));}
				FCaption:=SGWhatIsTheSimbol(longint(Context.KeyPressedChar),
					Context.KeysPressed(16) , Context.KeysPressed(20));
				FCursorPosition:=1;
				CaptionCharget:=True;
				end
			else
				begin
				FCursorPosition+=1;
				FCaption:={SGPCharTotal(
					SGPCharGetPart(FCaption,0,FCursorPosition-2),
					SGPCharTotal(
						SGStringToPChar(SGWhatIsTheSimbol(longint(Context.KeyPressedChar),
							Context.KeysPressed(16) , Context.KeysPressed(20))),
						SGPCharGetPart(FCaption,FCursorPosition-1,SGPCharHigh(FCaption))));}
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
UpgradeTimer(FCursorOnComponent,FCursorOnComponentTimer,3);
UpgradeTimer(FNowChanget,FNowChangetTimer,3);
UpgradeTimer(FTextComplite,FTextCompliteTimer,1);
UpgradeTimer(FDrawCursor,FDrawCursorTimer,4);
inherited FromUpDate(FCanChange);
end;

constructor TSGEdit.Create;
begin
inherited;
FCursorPosition:=0;
FNowChanget:=False;
FNowChangetTimer:=0;
FTextTypeFunction:=nil;
FTextType:=SGEditTypeText;
FTextComplite:=True;
FDrawCursor:=True;
FDrawCursorTimer:=1;
FDrawCursorElapsedTime:=0;
FDrawCursorElapsedTimeChange:=50;
FDrawCursorElapsedTimeDontChange:=30;
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

function TSGLabel.GetTextPosition : Boolean;inline;
begin
Result:=Boolean(FTextPosition);
end;

procedure TSGLabel.SetTextPosition(const Pos:Boolean);inline;
begin
FTextPosition:=Byte(Pos);
end;

procedure TSGLabel.FromDraw;
begin
if (Caption<>'') and (FFont<>nil) and (FFont.Ready) then
	begin
	FTextColor.WithAlpha(FVisibleTimer).Color(Render);
	FFont.DrawFontFromTwoVertex2f(
		Caption,
		SGPoint2fToVertex2f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex2f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
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
	FCursorOnComponent:=False;
	FCursorOnButton:=False;
	FChangingButton:=False;
	end;
UpgradeTimer(FCursorOnButton,FCursorOnButtonTimer,3,2);
UpgradeTimer(FChangingButton,FChangingButtonTimer,5,2);
inherited FromUpDate(FCanChange);
end;

procedure TSGButton.FromUpDateUnderCursor(var CanRePleace:Boolean);
begin
FCursorOnButton:=True;
if (Context.CursorKeysPressed(SGLeftCursorButton)) then
	FChangingButton:=True;
if Active and ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGUpKey)) then
	begin
	if (OnChange<>nil) then
		OnChange(Self);
	FChangingButtonTimer:=1;
	end;
inherited FromUpDateUnderCursor(CanRePleace);
end;

procedure TSGButton.FromDraw;
const 
	FirsColor1:TSGColor4f = (r:0;g:0.5;b:1;a:1);
	SecondColor1:TSGColor4f = (r:0;g:0.9;b:1;a:1);
	ThreeColor1:TSGColor4f = (r:0.8;g:0.8;b:0.8;a:1);
	
	FirsColor2:TSGColor4f = (r:0;g:0.75;b:1;a:1);
	SecondColor2:TSGColor4f = (r:0;g:1;b:1;a:1);
	ThreeColor2:TSGColor4f = (r:1;g:1;b:1;a:1);
begin
if (FVisible) or (FVisibleTimer>SGZero) then
	begin
	if FViewImage1<>nil then
		begin
		Render.Color4f(1,1,1,FVisibleTimer);
		FViewImage1.DrawImageFromTwoVertex2f(
			SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
			SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)));
		end;
	if (not Active) or (FActiveTimer<1-SGZero) then
		begin
		SGRoundQuad(Render,
			SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
			SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
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
		SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		5,10,
		FirsColor1.WithAlpha(0.3*FVisibleTimer*(1-FCursorOnButtonTimer)*(1-FChangingButtonTimer)*FActiveTimer),
		FirsColor2.WithAlpha(0.3*FVisibleTimer*(1-FCursorOnButtonTimer)*(1-FChangingButtonTimer)*FActiveTimer)*1.3,
		True);
	if  (FActiveTimer>SGZero) and 
		(FCursorOnButtonTimer>SGZero) and 
		(1-FChangingButtonTimer>SGZero) and
		(FVisibleTimer>SGZero) then
	SGRoundQuad(Render,
		SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
		5,10,
		SecondColor1.WithAlpha(0.3*FVisibleTimer*FCursorOnButtonTimer*(1-FChangingButtonTimer)*FActiveTimer),
		SecondColor2.WithAlpha(0.3*FVisibleTimer*FCursorOnButtonTimer*(1-FChangingButtonTimer)*FActiveTimer)*1.3,
		True);
	if  (FActiveTimer>SGZero) and 
		(FChangingButtonTimer>SGZero) and
		(FVisibleTimer>SGZero) then
	SGRoundQuad(Render,
		SGPoint2fToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex3f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)),
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
		SGPoint2fToVertex2f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
		SGPoint2fToVertex2f(GetVertex([SGS_RIGHT,SGS_BOTTOM],SG_VERTEX_FOR_PARENT)));
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

constructor TSGButton.Create;
begin
inherited Create;
FLeftShiftForChilds:=0;
FTopShiftForChilds:=0;
FRightShiftForChilds:=0;
FBottomShiftForChilds:=0;
FCanHaveChildren:=False;
FViewImage1:=nil;
end;

procedure SGCLPaint(const FContext:PSGContext);
var
	CanRePleace:Boolean = True;
	i:LongWord;
	Render:TSGRender = nil;
	Context:TSGContext;
begin
Context:=FContext^;
Render:=Context.Render;
if FNewPosition<>FOldPosition then
	begin
	Render.Clear(SGR_COLOR_BUFFER_BIT OR SGR_DEPTH_BUFFER_BIT);
	Render.InitMatrixMode(SG_2D);
	Render.Color4f(1,1,1,1);
	
	SGScreen.UpgradeTimer(True,FMoveProgress);
	
	if Abs(1-FMoveProgress)<SGZero then
		begin
		FOldPosition:=FNewPosition;
		FMoveProgress:=0;
		end
	else
		begin
		Render.LineWidth(1);
		Render.InitMatrixMode(SG_2D);
		
		if SGScreens[FOldPosition].FImage <>nil then
			begin
			SGScreens[FOldPosition].FImage.DrawImageFromTwoVertex2f(
				SGVertex2fImport(0,0)+FMoveProgress*FMoveVector*SGVertex2fImport(Context.Width,Context.Height),
				SGVertex2fImport(Context.Width,Context.Height)+FMoveProgress*FMoveVector*SGVertex2fImport(Context.Width,Context.Height)
				,True,SG_2D);
			end;
		
		if SGScreens[FNewPosition].FImage <>nil then
			begin
			SGScreens[FNewPosition].FImage.DrawImageFromTwoVertex2f(
				(-1)*FMoveVector*SGVertex2fImport(Context.Width,Context.Height)+FMoveProgress*FMoveVector*SGVertex2fImport(Context.Width,Context.Height),
				(-1)*FMoveVector*SGVertex2fImport(Context.Width,Context.Height)+SGVertex2fImport(Context.Width,Context.Height)+FMoveProgress*FMoveVector*SGVertex2fImport(Context.Width,Context.Height)
				,True,SG_2D);
			end;
		
		end;
	end;
if FNewPosition=FOldPosition then
	begin
	if SGScreen<>nil then
		SGScreen.FromUpDateUnderCursor(CanRePleace);
	if SGScreen<>nil then
		SGScreen.FromUpDate(CanRePleace);
	
	if SGScreen<>nil then
		SGScreen.DrawDrawClasses;
	
	Render.LineWidth(1);
	Render.InitMatrixMode(SG_2D);

	CanRePleace:=False;
	for i:=0 to High(SGScreens) do
		if (SGScreens[i].FScreen<>nil) and (SGScreens[i].FScreen<>SGScreen) then
			SGScreen.FromUpDate(CanRePleace);

	if SGScreen<>nil then
		SGScreen.FromDraw(); // -- ��������� �����
	
	if (Context.KeysPressed(SG_CTRL_KEY)) and (Context.KeysPressed(SG_ALT_KEY)) and (Context.KeyPressedType=SGDownKey) then
		begin
		case Context.KeyPressedByte of
		87://Close
			begin
			SGScreens[FNewPosition].FScreen:=nil;
			if SGScreens[FNewPosition].FImage<>nil then
				SGScreens[FNewPosition].FImage.Destroy;
			SGScreens[FNewPosition].FImage:=TSGGLImage.Create;
			SGScreens[FNewPosition].FImage.ImportFromDispley(False);
			SGScreens[FNewPosition].FImage.ToTexture;
			if Length(SGScreens) = 1 then
				begin
				SetLength(SGScreens,2);
				FNewPosition:=1;
				case Random(4) of
				0:FMoveVector.Import(1,0);
				1:FMoveVector.Import(-1,0);
				2:FMoveVector.Import(0,1);
				3:FMoveVector.Import(0,-1);
				end;
				FMoveProgress:=0;
				SGScreen.Destroy;
				
				SGScreen:=SGComponent.Create;
				SGScreen.SetBounds(0,0,Context.Width,Context.Height);
				SGScreen.SetShifts(0,0,0,0);
				SGScreen.Visible:=True;
				SGScreen.BoundsToNeedBounds;
				
				SGScreens[1].FScreen:=SGScreen;
				SGScreens[1].FImage:=nil;
				end
			else
				begin
				
				end;
			end;
		78://New Screen
			begin
			SetLength(SGScreens,Length(SGScreens)+1);
			
			FNewPosition:=High(SGScreens);
			for i:=0 to High(SGScreens)-1 do
				if SGScreens[i].FScreen = SGScreen then
					begin
					FOldPosition:=i;
					Break;
					end;
			FMoveProgress:=0;
			
			SGScreen:=SGComponent.Create;
			SGScreen.SetBounds(0,0,Context.Width,Context.Height);
			SGScreen.SetShifts(0,0,0,0);
			SGScreen.Visible:=True;
			SGScreen.BoundsToNeedBounds;
			
			SGScreens[FNewPosition].FScreen:=SGScreen;
			SGScreens[FNewPosition].FImage:=nil;
			
			if SGScreens[FOldPosition].FImage<>nil then
				SGScreens[FOldPosition].FImage.Destroy;
			SGScreens[FOldPosition].FImage:=TSGGLImage.Create;
			SGScreens[FOldPosition].FImage.ImportFromDispley(False);
			SGScreens[FOldPosition].FImage.Image.SetBounds(1024,512);
			SGScreens[FOldPosition].FImage.ToTexture;
			
			case Random(4) of
			0:FMoveVector.Import(1,0);
			1:FMoveVector.Import(-1,0);
			2:FMoveVector.Import(0,1);
			3:FMoveVector.Import(0,-1);
			end;
			
			Context.InitializeProcedure(FContext);
			
			Render.Clear(SGR_COLOR_BUFFER_BIT OR SGR_DEPTH_BUFFER_BIT);
			Context.Render.InitMatrixMode(SG_3D);
			
			SGScreen.DrawDrawClasses;
			Context.Render.InitMatrixMode(SG_2D);
			SGScreen.FromDraw;
			
			SGScreens[FNewPosition].FImage:=TSGGLImage.Create;
			SGScreens[FNewPosition].FImage.ImportFromDispley(False);
			SGScreens[FNewPosition].FImage.Image.SetBounds(1024,512);
			SGScreens[FNewPosition].FImage.ToTexture;
			
			Render.Clear(SGR_COLOR_BUFFER_BIT OR SGR_DEPTH_BUFFER_BIT);
			Context.Render.InitMatrixMode(SG_2D);
			Render.Color4f(1,1,1,1);
			SGScreens[FOldPosition].FImage.DrawImageFromTwoVertex2f(
				SGVertex2fImport(0,0),SGVertex2fImport(Context.Width,Context.Height),True,SG_2D);
			end;
		end;
		end;
	end;
end;

destructor TSGButton.Destroy;
begin
inherited Destroy;
end;

procedure SGCLResizeScreen(const Context:PSGContext);
begin
if SGScreen<>nil then
	begin
	SGScreen.SetBounds(0,0,Context^.Width,Context^.Height);
	SGScreen.BoundsToNeedBounds;
	SGScreen.FromResize();
	end;
end;

procedure SGCLLoad(const Context:PSGContext);
begin
if SGScreen<>nil then
	Exit;

SGScreen:=SGComponent.Create;
SGScreen.SetContext(Context);
SGScreen.SetBounds(0,0,Context^.Width,Context^.Height);
SGScreen.SetShifts(0,0,0,0);
SGScreen.Visible:=True;
SGScreen.BoundsToNeedBounds;

SetLength(SGScreens,1);
SGScreens[Low(SGScreens)].FScreen:=SGScreen;
SGScreens[Low(SGScreens)].FImage:=nil;

ComboBoxImage:=TSGGLImage.Create(SGGetCurrentDirectory()+'.'+Slash+'..'+Slash+'Data'+Slash+'Textures'+Slash+'ComboBoxImage.png');
ComboBoxImage.SetContext(Context);
ComboBoxImage.Loading;
end;

initialization
begin
FNewPosition:=0;
FNewPosition:=0;
SGSetCLProcedure(@SGCLPaint);
SGSetCLLoadProcedure(@SGCLLoad);
SCSetCLScreenBounds(@SGCLResizeScreen);
end;

end.
