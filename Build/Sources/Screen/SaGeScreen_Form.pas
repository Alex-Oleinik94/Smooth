{$INCLUDE SaGe.inc}

unit SaGeScreen_Form;

interface

uses
	 SaGeBase
	,SaGeScreenBase
	,SaGeScreen
	,SaGeScreenComponent
	,SaGeImage
	,SaGeScreenComponentInterfaces
	;

type
	PSGForm = ^ TSGForm;
	TSGForm = class(TSGComponent, ISGForm)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			public
		FButtonsType : SGFrameButtonsType;
		FIcon        : TSGImage;
		FRePlace     : TSGBoolean;
		procedure UpDate(); override;
		function CursorOverComponentTitle() : TSGBoolean;
			public
		procedure Paint(); override;
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:TSGScreenInt);override;
		end;

implementation

uses
	 SaGeContextUtils
	,SaGeMathUtils
	,SaGeCommonStructs
	,SaGeCommon
	,SaGeRectangleWithRoundedCorners
	;

class function TSGForm.ClassName() : TSGString; 
begin
Result := 'TSGForm';
end;

procedure TSGForm.UpDate();
var
	ParentBordersSize : TSGComponentBordersSize;
	ParentRealPosition : TSGComponentLocationVectorInt;
	ParentLocation : TSGComponentLocation;
	CursorPosition : TSGVector2int32;
begin
inherited;
if CursorOverComponent() and ((Context.CursorKeyPressed=SGLeftCursorButton) and (Context.CursorKeyPressedType=SGDownKey)) then
	FRePlace:=True;
if (FParent <> nil) and ((Context.CursorKeyPressed = SGLeftCursorButton) and (Context.CursorKeyPressedType = SGDownKey)) then
	FParent.ChildToListEnd(Self);
if FRePlace then
	begin
	if Context.CursorKeysPressed(SGRightCursorButton) then
		begin
		if FParent<>nil then
			begin
			ParentBordersSize := FParent.BordersSize;
			ParentRealPosition := FParent.RealPosition;
			ParentLocation := FParent.Location;
			CursorPosition := Context.CursorPosition(SGNowCursorPosition);
			if  (CursorPosition.x>ParentRealPosition.x) and 
				(CursorPosition.x<ParentRealPosition.x+ParentBordersSize.Left+10) and 
				(CursorPosition.y>ParentRealPosition.y+ParentBordersSize.Top) and 
				(CursorPosition.y<ParentRealPosition.y+ParentBordersSize.Top+ParentBordersSize.Bottom+ParentLocation.Height) then
					begin
					if FAlign<>SGAlignNone then
						DestroyAlign;
					FAlign:=SGAlignLeft;
					end
			else if  (CursorPosition.x>ParentRealPosition.x) and 
				(CursorPosition.x<ParentRealPosition.x+ParentLocation.Width) and 
				(CursorPosition.y>ParentRealPosition.y) and 
				(CursorPosition.y<ParentRealPosition.y+ParentBordersSize.Top+10) then
					begin
					if FAlign<>SGAlignNone then
						DestroyAlign;
					FAlign:=SGAlignTop;
					end
			else if  (CursorPosition.x>ParentRealPosition.x+ParentLocation.Width-ParentBordersSize.Right-10) and 
				(CursorPosition.x<ParentRealPosition.x+ParentLocation.Width) and 
				(CursorPosition.y>ParentRealPosition.y+ParentBordersSize.Top) and 
				(CursorPosition.y<ParentRealPosition.y+ParentLocation.Height-ParentBordersSize.Bottom) then
					begin
					if FAlign<>SGAlignNone then
						DestroyAlign;
					FAlign:=SGAlignRight;
					end
			else if  (CursorPosition.x>ParentRealPosition.x) and 
				(CursorPosition.x<ParentRealPosition.x+ParentLocation.Width) and 
				(CursorPosition.y>ParentRealPosition.y+ParentLocation.Height-ParentBordersSize.Bottom-10) and 
				(CursorPosition.y<ParentRealPosition.y+ParentLocation.Height) then
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
		if not (FAlign in [SGAlignBottom, SGAlignClient, SGAlignLeft, SGAlignRight, SGAlignTop]) then
			FDefaultLocation := FLocation;
		end;
	end;
end;

procedure TSGForm.Paint();
begin
if (FVisible) or (FVisibleTimer>SGZero) then
	FSkin.PaintForm(Self);
inherited;
end;

constructor TSGForm.Create();
begin
inherited Create;
FButtonsType := SGFrameButtonsType0f;
FIcon := TSGImage.Create();
SetBordersSize(5, 30, 5, 5);
end;

function TSGForm.CursorOverComponentTitle():boolean;
begin
Result:=
	(Context.CursorPosition(SGNowCursorPosition).x>=FRealPosition.x) and 
	(Context.CursorPosition(SGNowCursorPosition).y>=FRealPosition.y) and 
	(Context.CursorPosition(SGNowCursorPosition).y<=FRealPosition.y+FBordersSize.Top) and 
	(Context.CursorPosition(SGNowCursorPosition).x<=FRealPosition.x+FRealLocation.Width);
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
SGKIll(FIcon);
inherited Destroy;
end;

end.
