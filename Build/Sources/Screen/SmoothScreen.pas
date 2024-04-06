{$INCLUDE Smooth.inc}

//{$DEFINE SCREEN_DEBUG}

unit SmoothScreen;

interface

uses
	 SmoothBase
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothScreenBase
	,SmoothScreenComponent
	;

type
	ISScreen = interface(ISComponent)
		['{c3c6ea12-c4ff-41de-a250-1e4d856b3e59}']
		procedure Load(const VContext : ISContext);
		procedure CustomPaint();
		procedure UpDateScreen();
		end;
	
	TSScreen = class(TSComponent, ISScreen)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName() : TSString; override;
			private
		FInProcessing : TSBoolean;
			public
		procedure Load(const _Context : ISContext);
		procedure Paint();override;
		procedure CustomPaint();
		procedure UpDateScreen();
			public
		property InProcessing : TSBoolean read FInProcessing write FInProcessing;
		end;

procedure SKill(var Screen : TSScreen); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothLog
	,SmoothRenderBase
	,SmoothScreenSkin
	,SmoothContextUtils
	{$IFDEF ANDROID},SmoothStringUtils{$ENDIF}
	;

procedure SKill(var Screen : TSScreen); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if (Screen <> nil) then
	begin
	Screen.Destroy();
	Screen := nil;
	end;
end;

// =======================
// ====== TSScreen ======
// =======================

class function TSScreen.ClassName() : TSString;
begin
Result := 'TSScreen';
end;

constructor TSScreen.Create();
begin
inherited;
FInProcessing := False;
end;

destructor TSScreen.Destroy();
begin
FInProcessing := False;
inherited;
end;

procedure TSScreen.Load(const _Context : ISContext);
begin
{$IFDEF ANDROID}TSLog.Source('Enterind "SScreenLoad". Context="' + SAddrStr(_Context) + '"');{$ENDIF}
Context := _Context;
SKill(FSkin);
FSkin := TSScreenSkin.CreateRandom(Context);
Visible := True;
Resize();
{$IFDEF ANDROID}TSLog.Source('Leaving "SScreenLoad".');{$ENDIF}
end;

procedure TSScreen.CustomPaint();
begin
InProcessing := True;
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSScreen__Paint() : Before "DrawDrawClasses();"');
	{$ENDIF}
DrawDrawClasses();
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSScreen__Paint() : Before over updating');
	{$ENDIF}

Render.LineWidth(1);
Render.InitMatrixMode(S_2D);

{$IFDEF SCREEN_DEBUG}
	WriteLn('TSScreen__Paint() : Before drawing');
	{$ENDIF}

inherited Paint();
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSScreen__Paint() : Beining');
	{$ENDIF}
InProcessing := False;
end;

procedure TSScreen.UpDateScreen();
begin
InProcessing := True;
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSScreen__UpDateScreen() : Before "UpDate();"');
	{$ENDIF}
UpDate();
InProcessing := False;
end;

procedure TSScreen.Paint();
begin
{$IFDEF SCREEN_DEBUG}
	WriteLn('TSScreen__Paint() : Beining, before check ECP');
	{$ENDIF}

UpDateScreen();
Skin.UpDate();
CustomPaint();
end;

end.
