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
	,SmoothArithmeticUtils
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
	ComponentOwnerBordersSize : TSComponentBordersSize;
	ComponentOwnerRealPosition : TSComponentLocationVectorInt;
	ComponentOwnerLocation : TSComponentLocation;
	CursorPosition : TSVector2int32;
begin
inherited;
if CursorOverComponent() and ((Context.CursorKeyPressed=SLeftCursorButton) and (Context.CursorKeyPressedType=SDownKey)) then
	FRePlace:=True;
if (FComponentOwner <> nil) and ((Context.CursorKeyPressed = SLeftCursorButton) and (Context.CursorKeyPressedType = SDownKey)) then
	FComponentOwner.InternalComponentToListEnd(Self);
if FRePlace then
	begin
	if Context.CursorKeysPressed(SRightCursorButton) then
		begin
		if FComponentOwner<>nil then
			begin
			ComponentOwnerBordersSize := FComponentOwner.BordersSize;
			ComponentOwnerRealPosition := FComponentOwner.RealPosition;
			ComponentOwnerLocation := FComponentOwner.Location;
			CursorPosition := Context.CursorPosition(SNowCursorPosition);
			if  (CursorPosition.x>ComponentOwnerRealPosition.x) and 
				(CursorPosition.x<ComponentOwnerRealPosition.x+ComponentOwnerBordersSize.Left+10) and 
				(CursorPosition.y>ComponentOwnerRealPosition.y+ComponentOwnerBordersSize.Top) and 
				(CursorPosition.y<ComponentOwnerRealPosition.y+ComponentOwnerBordersSize.Top+ComponentOwnerBordersSize.Bottom+ComponentOwnerLocation.Height) then
					begin
					if FAlign<>SAlignNone then
						DestroyAlign;
					FAlign:=SAlignLeft;
					end
			else if  (CursorPosition.x>ComponentOwnerRealPosition.x) and 
				(CursorPosition.x<ComponentOwnerRealPosition.x+ComponentOwnerLocation.Width) and 
				(CursorPosition.y>ComponentOwnerRealPosition.y) and 
				(CursorPosition.y<ComponentOwnerRealPosition.y+ComponentOwnerBordersSize.Top+10) then
					begin
					if FAlign<>SAlignNone then
						DestroyAlign;
					FAlign:=SAlignTop;
					end
			else if  (CursorPosition.x>ComponentOwnerRealPosition.x+ComponentOwnerLocation.Width-ComponentOwnerBordersSize.Right-10) and 
				(CursorPosition.x<ComponentOwnerRealPosition.x+ComponentOwnerLocation.Width) and 
				(CursorPosition.y>ComponentOwnerRealPosition.y+ComponentOwnerBordersSize.Top) and 
				(CursorPosition.y<ComponentOwnerRealPosition.y+ComponentOwnerLocation.Height-ComponentOwnerBordersSize.Bottom) then
					begin
					if FAlign<>SAlignNone then
						DestroyAlign;
					FAlign:=SAlignRight;
					end
			else if  (CursorPosition.x>ComponentOwnerRealPosition.x) and 
				(CursorPosition.x<ComponentOwnerRealPosition.x+ComponentOwnerLocation.Width) and 
				(CursorPosition.y>ComponentOwnerRealPosition.y+ComponentOwnerLocation.Height-ComponentOwnerBordersSize.Bottom-10) and 
				(CursorPosition.y<ComponentOwnerRealPosition.y+ComponentOwnerLocation.Height) then
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
