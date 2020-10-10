{$INCLUDE Smooth.inc}

unit SmoothScreen_ProgressBar;

interface

uses
	 SmoothBase
	,SmoothScreenBase
	,SmoothScreenComponent
	,SmoothCommonStructs
	,SmoothScreenComponentInterfaces
	;

type
	TSProgressBar = class(TSComponent, ISProgressBar)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSString; override;
			protected
		FProgress      : TSProgressBarFloat;
		FProgressTimer : TSProgressBarFloat;
		FViewProgress  : TSBool;
		FColor         : TSScreenSkinFrameColor;
		FViewCaption   : TSBool;
		FIsColorStatic : TSBool;
			public
		procedure Paint(); override;
			public
		function GetProgress() : TSProgressBarFloat;
		function GetColor() : TSScreenSkinFrameColor;
		function GetIsColorStatic() : TSBool;
		function GetProgressTimer() : TSProgressBarFloat;
		function GetViewCaption() : TSBool;
		function GetViewProgress() : TSBool;
			public
		property ProgressTimer : TSProgressBarFloat      read GetProgressTimer write FProgressTimer;
		property Progress      : TSProgressBarFloat      read GetProgress      write FProgress;
		property Color         : TSScreenSkinFrameColor  read GetColor         write FColor;
		property IsColorStatic : TSBool                  read GetIsColorStatic;
		property ViewProgress  : TSBool                  read GetViewProgress  write FViewProgress;
		property ViewCaption   : TSBool                  read GetViewCaption   write FViewCaption;
		property Color1        : TSColor4f               read FColor.FFirst    write FColor.FFirst;
		property Color2        : TSColor4f               read FColor.FSecond   write FColor.FSecond;
			public
		procedure DefaultColor();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function GetProgressPointer() : PSProgressBarFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		end;

implementation

uses
	 SmoothArithmeticUtils
	;

class function TSProgressBar.ClassName() : TSString; 
begin
Result := 'TSProgressBar';
end;

function  TSProgressBar.GetProgress() : TSProgressBarFloat;
begin
Result := FProgress;
end;

function  TSProgressBar.GetColor() : TSScreenSkinFrameColor;
begin
Result := FColor;
end;

function  TSProgressBar.GetIsColorStatic() : TSBool;
begin
Result := FIsColorStatic;
end;

function  TSProgressBar.GetProgressTimer() : TSProgressBarFloat;
begin
Result := FProgressTimer;
end;

function  TSProgressBar.GetViewCaption() : TSBool;
begin
Result := FViewCaption;
end;

function  TSProgressBar.GetViewProgress() : TSBool;
begin
Result := FViewProgress;
end;

procedure TSProgressBar.Paint();
begin
if FVisibleTimer > SZero then
	FSkin.PaintProgressBar(Self);
inherited;
end;

function TSProgressBar.GetProgressPointer() : PSProgressBarFloat;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
Result := @FProgress;
end;

procedure TSProgressBar.DefaultColor;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FColor.FFirst .Import(0.9, 0.9, 0.9, 1);
FColor.FSecond.Import(1,   1,   1,   1);
FIsColorStatic := True;
end;

constructor TSProgressBar.Create;
begin
inherited;
FProgress      := 0;
FProgressTimer := 0;
FViewProgress  := True;
FViewCaption   := True;
DefaultColor();
FIsColorStatic := False;
Caption := '';
end;

destructor TSProgressBar.Destroy;
begin
inherited;
end;

end.
