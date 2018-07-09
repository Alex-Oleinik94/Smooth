{$INCLUDE SaGe.inc}

unit SaGeScreen_Form;

interface

uses
	 SaGeBase
	,SaGeScreenBase
	,SaGeScreen
	,SaGeScreenComponent
	,SaGeImage
	;

type
	PSGForm = ^ TSGForm;
	TSGForm = class(TSGComponent)
			public
		constructor Create;override;
		destructor Destroy;override;
		class function ClassName() : TSGString; override;
			public
		FButtonsType : SGFrameButtonsType;
		FIcon        : TSGImage;
		FRePlace     : Boolean;
		procedure FromUpDate();override;
		function CursorOverComponentTitle():boolean;
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

procedure TSGForm.FromUpDate();
var
	ParentBoundsSize : TSGComponentBoundsSize;
	ParentRealPosition : TSGComponentLocationVectorInt;
	ParentLocation : TSGComponentLocation;
	CursorPosition : TSGVector2int32;
begin
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
			ParentBoundsSize := FParent.BoundsSize;
			ParentRealPosition := FParent.RealPosition;
			ParentLocation := FParent.Location;
			CursorPosition := Context.CursorPosition(SGNowCursorPosition);
			if  (CursorPosition.x>ParentRealPosition.x) and 
				(CursorPosition.x<ParentRealPosition.x+ParentBoundsSize.Left+10) and 
				(CursorPosition.y>ParentRealPosition.y+ParentBoundsSize.Top) and 
				(CursorPosition.y<ParentRealPosition.y+ParentBoundsSize.Top+ParentBoundsSize.Bottom+ParentLocation.Height) then
					begin
					if FAlign<>SGAlignNone then
						DestroyAlign;
					FAlign:=SGAlignLeft;
					end
			else if  (CursorPosition.x>ParentRealPosition.x) and 
				(CursorPosition.x<ParentRealPosition.x+ParentLocation.Width) and 
				(CursorPosition.y>ParentRealPosition.y) and 
				(CursorPosition.y<ParentRealPosition.y+ParentBoundsSize.Top+10) then
					begin
					if FAlign<>SGAlignNone then
						DestroyAlign;
					FAlign:=SGAlignTop;
					end
			else if  (CursorPosition.x>ParentRealPosition.x+ParentLocation.Width-ParentBoundsSize.Right-10) and 
				(CursorPosition.x<ParentRealPosition.x+ParentLocation.Width) and 
				(CursorPosition.y>ParentRealPosition.y+ParentBoundsSize.Top) and 
				(CursorPosition.y<ParentRealPosition.y+ParentLocation.Height-ParentBoundsSize.Bottom) then
					begin
					if FAlign<>SGAlignNone then
						DestroyAlign;
					FAlign:=SGAlignRight;
					end
			else if  (CursorPosition.x>ParentRealPosition.x) and 
				(CursorPosition.x<ParentRealPosition.x+ParentLocation.Width) and 
				(CursorPosition.y>ParentRealPosition.y+ParentLocation.Height-ParentBoundsSize.Bottom-10) and 
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
inherited FromUpDate();
end;

procedure TSGForm.Paint();
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
		Skin.Font.DrawFontFromTwoVertex2f(FCaption,
			SGPoint2int32ToVertex3f(GetVertex([SGS_LEFT,SGS_TOP],SG_VERTEX_FOR_PARENT)),
			SGPoint2int32ToVertex3f(GetVertex([SGS_RIGHT,SGS_TOP],SG_VERTEX_FOR_CHILDREN)));
		end;
	end;
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
FCursorOverComponentCaption:=Result;
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
