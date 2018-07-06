{$INCLUDE SaGe.inc}

unit SaGeScreen_Panel;

interface

uses
	 SaGeBase
	,SaGeScreenBase
	,SaGeScreen
	,SaGeScreenComponent
	;

type
	TSGPanel = class(TSGComponent, ISGPanel)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSGString; override;
			protected
		FViewLines : TSGBoolean;
		FViewQuad  : TSGBoolean;
		function ViewingLines() : TSGBoolean; virtual;
		function ViewingQuad()  : TSGBoolean; virtual;
			public
		procedure Paint(); override;
			public
		property ViewLines : TSGBoolean read ViewingLines write FViewLines;
		property ViewQuad  : TSGBoolean read ViewingQuad  write FViewQuad;
		end;

implementation

uses
	 SaGeMathUtils
	;

class function TSGPanel.ClassName() : TSGString; 
begin
Result := 'TSGPanel';
end;

function TSGPanel.ViewingLines() : TSGBoolean;
begin
Result := FViewLines;
end;

function TSGPanel.ViewingQuad() : TSGBoolean;
begin
Result := FViewQuad;
end;

procedure TSGPanel.Paint();
begin
if (FVisible) or (FVisibleTimer > SGZero) then
	FSkin.PaintPanel(Self);
inherited;
end;

constructor TSGPanel.Create();
begin
inherited;
SetBordersSize(5, 5, 5, 5);
FViewLines := True;
FViewQuad  := True;
end;

destructor TSGPanel.Destroy();
begin
inherited;
end;

end.
