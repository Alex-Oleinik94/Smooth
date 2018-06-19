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
		procedure FromUpDate(var FCanChange:Boolean);override;
		procedure FromUpDateUnderCursor(var CanRePleace:Boolean;const CursorInComponentNow:Boolean = True);override;
		procedure FromUpDateCaptionUnderCursor(var CanRePleace:Boolean);override;
		function CursorInComponentCaption():boolean;override;
			public
		procedure FromDraw;override;
		procedure SetBounds(const NewLeft,NewTop,NewWidth,NewHeight:TSGScreenInt);override;
		end;

implementation

uses
	 SaGeContextUtils
	,SaGeMathUtils
	,SaGeCommonStructs
	,SaGeCommon
	;

class function TSGForm.ClassName() : TSGString; 
begin
Result := 'TSGForm';
end;

procedure TSGForm.FromUpDate(var FCanChange:Boolean);
var
	i : TSGLongInt;
begin
if (FParent <> nil) and ((Context.CursorKeyPressed = SGLeftCursorButton) and (Context.CursorKeyPressedType = SGDownKey)) then
	FParent.ChildToListEnd(Self);
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
		Skin.Font.DrawFontFromTwoVertex2f(FCaption,
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

end.
