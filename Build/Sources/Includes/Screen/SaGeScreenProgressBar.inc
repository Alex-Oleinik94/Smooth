{$IFDEF SCREEN_INTERFACE}
type
	
	TSGProgressBar=class(TSGComponent, ISGProgressBar)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
			protected
		FProgress      : TSGProgressBarFloat;
		FProgressTimer : TSGProgressBarFloat;
		FViewProgress  : TSGBool;
		FColor         : TSGScreenSkinFrameColor;
		FViewCaption   : TSGBool;
		FIsColorStatic : TSGBool;
			public
		procedure FromDraw();override;
			public
		function GetProgress() : TSGProgressBarFloat;
		function GetColor() : TSGScreenSkinFrameColor;
		function GetIsColorStatic() : TSGBool;
		function GetProgressTimer() : TSGProgressBarFloat;
		function GetViewCaption() : TSGBool;
		function GetViewProgress() : TSGBool;
			public
		property ProgressTimer : TSGProgressBarFloat      read GetProgressTimer write FProgressTimer;
		property Progress      : TSGProgressBarFloat      read GetProgress      write FProgress;
		property Color         : TSGScreenSkinFrameColor  read GetColor         write FColor;
		property IsColorStatic : TSGBool                  read GetIsColorStatic;
		property ViewProgress  : TSGBool                  read GetViewProgress  write FViewProgress;
		property ViewCaption   : TSGBool                  read GetViewCaption   write FViewCaption;
		property Color1        : TSGColor4f               read FColor.FFirst    write FColor.FFirst;
		property Color2        : TSGColor4f               read FColor.FSecond   write FColor.FSecond;
			public
		procedure DefaultColor();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetProgressPointer() : PSGProgressBarFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;
{$ENDIF}

{$IFDEF SCREEN_IMPLEMENTATION}
class function TSGProgressBar.ClassName() : TSGString; 
begin
Result := 'TSGProgressBar';
end;

function  TSGProgressBar.GetProgress() : TSGProgressBarFloat;
begin
Result := FProgress;
end;

function  TSGProgressBar.GetColor() : TSGScreenSkinFrameColor;
begin
Result := FColor;
end;

function  TSGProgressBar.GetIsColorStatic() : TSGBool;
begin
Result := FIsColorStatic;
end;

function  TSGProgressBar.GetProgressTimer() : TSGProgressBarFloat;
begin
Result := FProgressTimer;
end;

function  TSGProgressBar.GetViewCaption() : TSGBool;
begin
Result := FViewCaption;
end;

function  TSGProgressBar.GetViewProgress() : TSGBool;
begin
Result := FViewProgress;
end;

procedure TSGProgressBar.FromDraw;
begin
if FVisibleTimer > SGZero then
	FSkin.PaintProgressBar(Self);
inherited;
end;

function TSGProgressBar.GetProgressPointer() : PSGProgressBarFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := @FProgress;
end;

procedure TSGProgressBar.DefaultColor;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FColor.FFirst .Import(0.9,0.9,0.9,1);
FColor.FSecond.Import(1,1,1,1);
FIsColorStatic := True;
end;

constructor TSGProgressBar.Create;
begin
inherited;
FProgress      := 0;
FProgressTimer := 0;
FViewProgress  := False;
FViewCaption   := False;
DefaultColor();
FIsColorStatic := False;
end;

destructor TSGProgressBar.Destroy;
begin
inherited;
end;
{$ENDIF}
