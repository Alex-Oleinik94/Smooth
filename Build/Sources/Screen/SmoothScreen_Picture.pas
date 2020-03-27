{$INCLUDE Smooth.inc}

unit SmoothScreen_Picture;

interface

uses
	 SmoothBase
	,SmoothScreenBase
	,SmoothScreen
	,SmoothImage
	,SmoothCommonStructs
	,SmoothScreenComponent
	;

type
	TSPicture=class(TSComponent)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			private
		FImage       : TSImage;
		FEnableLines : TSBoolean;
		FLinesColor  : TSColor4f;
		FSecondPoint : TSVertex2f;
			public
		property Image       : TSImage read FImage write FImage;
		property Picture     : TSImage read FImage write FImage;
		property EnableLines : TSBoolean read FEnableLines write FEnableLines;
		property LinesColor  : TSColor4f read FLinesColor write FLinesColor;
		property SecondPoint : TSVertex2f read FSecondPoint write FSecondPoint;
			public
		procedure Paint(); override;
		end;

implementation

uses
	 SmoothMathUtils
	,SmoothRenderBase
	,SmoothCommon
	;

class function TSPicture.ClassName() : TSString; 
begin
Result := 'TSPicture';
end;

procedure TSPicture.Paint();
var
	a, b: TSVertex3f;
begin
if (FVisible or (FVisibleTimer > SZero)) and (FImage <> nil) then
	begin
	Render.Color4f(1, 1, 1, FVisibleTimer);
	a := SPoint2int32ToVertex3f(GetVertex([SS_LEFT,SS_TOP], S_VERTEX_FOR_PARENT));
	b := SPoint2int32ToVertex3f(GetVertex([SS_RIGHT,SS_BOTTOM], S_VERTEX_FOR_PARENT));
	FImage.DrawImageFromTwoVertex2fWithTexPoint(a, b, FSecondPoint, True, S_2D);
	if FEnableLines then
		begin
		Render.Color(FLinesColor);
		Render.BeginScene(SR_LINE_LOOP);
		Render.Vertex(a);
		Render.Vertex2f(a.x, b.y);
		Render.Vertex(b);
		Render.Vertex2f(b.x, a.y);
		Render.EndScene();
		end;
	end;
inherited;
end;

constructor TSPicture.Create;
begin
inherited;
FImage:=nil;
FEnableLines := False;
FLinesColor.Import(1,1,1,1);
FSecondPoint.Import(1,1);
end;

destructor TSPicture.Destroy;
begin
inherited;
end;

end.
