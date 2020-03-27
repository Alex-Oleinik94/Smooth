{$INCLUDE Smooth.inc}

unit SmoothScreen_Panel;

interface

uses
	 SmoothBase
	,SmoothScreenBase
	,SmoothScreen
	,SmoothScreenComponent
	,SmoothScreenComponentInterfaces
	;

type
	TSPanel = class(TSComponent, ISPanel)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			protected
		FViewLines : TSBoolean;
		FViewQuad  : TSBoolean;
		function ViewingLines() : TSBoolean; virtual;
		function ViewingQuad()  : TSBoolean; virtual;
			public
		procedure Paint(); override;
			public
		property ViewLines : TSBoolean read ViewingLines write FViewLines;
		property ViewQuad  : TSBoolean read ViewingQuad  write FViewQuad;
		end;

implementation

uses
	 SmoothMathUtils
	;

class function TSPanel.ClassName() : TSString; 
begin
Result := 'TSPanel';
end;

function TSPanel.ViewingLines() : TSBoolean;
begin
Result := FViewLines;
end;

function TSPanel.ViewingQuad() : TSBoolean;
begin
Result := FViewQuad;
end;

procedure TSPanel.Paint();
begin
if (FVisible) or (FVisibleTimer > SZero) then
	FSkin.PaintPanel(Self);
inherited;
end;

constructor TSPanel.Create();
begin
inherited;
SetBordersSize(5, 5, 5, 5);
FViewLines := True;
FViewQuad  := True;
end;

destructor TSPanel.Destroy();
begin
inherited;
end;

end.
