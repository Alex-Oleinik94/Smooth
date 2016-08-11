{$IFDEF SCREEN_INTERFACE}
type
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
{$ENDIF}

{$IFDEF SCREEN_IMPLEMENTATION}
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
{$ENDIF}
