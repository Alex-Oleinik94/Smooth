{$INCLUDE Smooth.inc}

unit SmoothScreen_Form;

interface

uses
	 SmoothBase
	,SmoothScreenBase
	,SmoothScreen
	,SmoothScreenComponent
	,SmoothImage
	,SmoothScreenComponentInterfaces
	;

type
	PSForm = ^ TSForm;
	TSForm = class(TSComponent, ISForm)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			public
		FButtonsType : SFrameButtonsType;
		FIcon        : TSImage;
		FRePlace     : TSBoolean;
		procedure UpDate(); override;
		function CursorOverComponentTitle() : TSBoolean;
			public
		procedure Paint(); override;
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:TSScreenInt);override;
		end;

implementation

uses
	 SmoothContextUtils
	,SmoothMathUtils
	,SmoothCommonStructs
	,SmoothCommon
	,SmoothRectangleWithRoundedCorners
	;

class function TSForm.ClassName() : TSString; 
begin
Result := 'TSForm';
end;

procedure TSForm.UpDate();
var
	ParentBordersSize : TSComponentBordersSize;
	ParentRealPosition : TSComponentLocationVectorInt;
	ParentLocation : TSComponentLocation;
	CursorPosition : TSVector2int32;
begin
inherited;
if CursorOverComponent() and ((Context.CursorKeyPressed=SLeftCursorButton) and (Context.CursorKeyPressedType=SDownKey)) then
	FRePlace:=True;
if (FParent <> nil) and ((Context.CursorKeyPressed = SLeftCursorButton) and (Context.CursorKeyPressedType = SDownKey)) then
	FParent.ChildToListEnd(Self);
if FRePlace then
	begin
	if Context.CursorKeysPressed(SRightCursorButton) then
		begin
		if FParent<>nil then
			begin
			ParentBordersSize := FParent.BordersSize;
			ParentRealPosition := FParent.RealPosition;
			ParentLocation := FParent.Location;
			CursorPosition := Context.CursorPosition(SNowCursorPosition);
			if  (CursorPosition.x>ParentRealPosition.x) and 
				(CursorPosition.x<ParentRealPosition.x+ParentBordersSize.Left+10) and 
				(CursorPosition.y>ParentRealPosition.y+ParentBordersSize.Top) and 
				(CursorPosition.y<ParentRealPosition.y+ParentBordersSize.Top+ParentBordersSize.Bottom+ParentLocation.Height) then
					begin
					if FAlign<>SAlignNone then
						DestroyAlign;
					FAlign:=SAlignLeft;
					end
			else if  (CursorPosition.x>ParentRealPosition.x) and 
				(CursorPosition.x<ParentRealPosition.x+ParentLocation.Width) and 
				(CursorPosition.y>ParentRealPosition.y) and 
				(CursorPosition.y<ParentRealPosition.y+ParentBordersSize.Top+10) then
					begin
					if FAlign<>SAlignNone then
						DestroyAlign;
					FAlign:=SAlignTop;
					end
			else if  (CursorPosition.x>ParentRealPosition.x+ParentLocation.Width-ParentBordersSize.Right-10) and 
				(CursorPosition.x<ParentRealPosition.x+ParentLocation.Width) and 
				(CursorPosition.y>ParentRealPosition.y+ParentBordersSize.Top) and 
				(CursorPosition.y<ParentRealPosition.y+ParentLocation.Height-ParentBordersSize.Bottom) then
					begin
					if FAlign<>SAlignNone then
						DestroyAlign;
					FAlign:=SAlignRight;
					end
			else if  (CursorPosition.x>ParentRealPosition.x) and 
				(CursorPosition.x<ParentRealPosition.x+ParentLocation.Width) and 
				(CursorPosition.y>ParentRealPosition.y+ParentLocation.Height-ParentBordersSize.Bottom-10) and 
				(CursorPosition.y<ParentRealPosition.y+ParentLocation.Height) then
					begin
					if FAlign<>SAlignNone then
						DestroyAlign;
					FAlign:=SAlignBottom;
					end
			else
				begin
				if FAlign<>SAlignNone then
					DestroyAlign;
				end;
			end;
		AddToLeft(Context.CursorPosition(SDeferenseCursorPosition).x);
		AddToTop(Context.CursorPosition(SDeferenseCursorPosition).y);
		end
	else
		begin
		FRePlace:=False;
		if not (FAlign in [SAlignBottom, SAlignClient, SAlignLeft, SAlignRight, SAlignTop]) then
			FDefaultLocation := FLocation;
		end;
	end;
end;

procedure TSForm.Paint();
begin
if (FVisible) or (FVisibleTimer>SZero) then
	FSkin.PaintForm(Self);
inherited;
end;

constructor TSForm.Create();
begin
inherited Create;
FButtonsType := SFrameButtonsType0f;
FIcon := TSImage.Create();
SetBordersSize(5, 30, 5, 5);
end;

function TSForm.CursorOverComponentTitle():boolean;
begin
Result:=
	(Context.CursorPosition(SNowCursorPosition).x>=FRealPosition.x) and 
	(Context.CursorPosition(SNowCursorPosition).y>=FRealPosition.y) and 
	(Context.CursorPosition(SNowCursorPosition).y<=FRealPosition.y+FBordersSize.Top) and 
	(Context.CursorPosition(SNowCursorPosition).x<=FRealPosition.x+FRealLocation.Width);
end;

procedure TSForm.SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:LongInt);
begin
inherited SetBounds(NewLeft+6,NewTop+31,NewWidth,NewHeight);
Left:=Left+RandomOne*SFrameAnimationConst;
Top:=Top+RandomOne*SFrameAnimationConst;
//Width:=Width+RandomOne*SFrameAnimationConst;
//Height:=Height+RandomOne*SFrameAnimationConst;
end;

destructor TSForm.Destroy;
begin
FCaption:='';
FButtonsType:=SFrameButtonsTypeCleared;
SKIll(FIcon);
inherited Destroy;
end;

end.
