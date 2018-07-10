{$INCLUDE SaGe.inc}

//{$DEFINE SCREEN_DEBUG}

unit SaGeScreen;

interface

uses
	 SaGeBase
	,SaGeContextClasses
	,SaGeContextInterface
	,SaGeScreenBase
	,SaGeScreenComponent
	;

type
	ISGScreen = interface(ISGComponent)
		['{c3c6ea12-c4ff-41de-a250-1e4d856b3e59}']
		procedure Load(const VContext : ISGContext);
		procedure CustomPaint();
		procedure UpDateScreen();
		end;
	
	TSGScreen = class(TSGComponent, ISGScreen)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSGString; override;
			private
		FInProcessing : TSGBoolean;
			public
		procedure Load(const _Context : ISGContext);
		procedure Paint();override;
		procedure CustomPaint();
		procedure UpDateScreen();
			public
		property InProcessing : TSGBoolean read FInProcessing write FInProcessing;
		end;

procedure SGKill(var Screen : TSGScreen); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeLog
	,SaGeRenderBase
	,SaGeScreenSkin
	,SaGeContextUtils
	;

procedure SGKill(var Screen : TSGScreen); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (Screen <> nil) then
	begin
	Screen.Destroy();
	Screen := nil;
	end;
end;

// =======================
// ====== TSGScreen ======
// =======================

class function TSGScreen.ClassName() : TSGString;
begin
Result := 'TSGScreen';
end;

constructor TSGScreen.Create();
begin
inherited;
FInProcessing := False;
end;

destructor TSGScreen.Destroy();
begin
FInProcessing := False;
inherited;
end;

procedure TSGScreen.Load(const _Context : ISGContext);
begin
{$IFDEF ANDROID}TSGLog.Source('Enterind "SGScreenLoad". Context="' + SGAddrStr(_Context) + '"');{$ENDIF}
Context := _Context;
SGKill(FSkin);
FSkin := TSGScreenSkin.CreateRandom(Context);
Visible := True;
Resize();
{$IFDEF ANDROID}TSGLog.Source('Leaving "SGScreenLoad".');{$ENDIF}
end;

procedure TSGScreen.CustomPaint();
begin
InProcessing := True;
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Before "DrawDrawClasses();"');
	{$ENDIF}
DrawDrawClasses();
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Before over updating');
	{$ENDIF}

Render.LineWidth(1);
Render.InitMatrixMode(SG_2D);

{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Before drawing');
	{$ENDIF}

inherited Paint();
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Beining');
	{$ENDIF}
InProcessing := False;
end;

procedure TSGScreen.UpDateScreen();
begin
InProcessing := True;
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.UpDateScreen() : Before "FromUpDate();"');
	{$ENDIF}
FromUpDate();
InProcessing := False;
end;

procedure TSGScreen.Paint();
begin
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSGScreen.Paint() : Beining, before check ECP');
	{$ENDIF}

UpDateScreen();
Skin.UpDate();
CustomPaint();
end;

end.
