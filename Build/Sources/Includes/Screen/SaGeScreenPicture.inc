{$IFDEF SCREEN_INTERFACE}
type
	TSGPicture=class(TSGComponent)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
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
{$ENDIF}

{$IFDEF SCREEN_IMPLEMENTATION}

class function TSGPicture.ClassName() : TSGString; 
begin
Result := 'TSGPicture';
end;

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
{$ENDIF}
