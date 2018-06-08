{$INCLUDE SaGe.inc}

unit SaGeMaz1gWizardPaintable;

interface

uses
	 SaGeBase
	,SaGeScreen
	,SaGeCommonClasses
	,SaGeWorldOfWarcraftConnectionHandler
	,SaGeScreenHelper
	;

type
	TSGMaz1gWizardPaintable = class(TSGScreenedDrawable)
			public
		constructor Create(const _Context : ISGContext); override;
		destructor Destroy(); override;
		procedure Paint(); override;
			protected
		FConnectionHandler : TSGWorldOfWarcraftConnectionHandler;
		FSizeLabel : TSGScreenLabel;
			public
		property ConnectionHandler : TSGWorldOfWarcraftConnectionHandler read FConnectionHandler write FConnectionHandler;
		end;

procedure SGKill(var Maz1gWizardPaintable : TSGMaz1gWizardPaintable); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeStringUtils
	;

procedure TSGMaz1gWizardPaintable.Paint();
begin
if (ConnectionHandler <> nil) then
	FSizeLabel.Caption := SGStr(FConnectionHandler.AllDataSize);
end;

constructor TSGMaz1gWizardPaintable.Create(const _Context : ISGContext);
begin
inherited Create(_Context);
FConnectionHandler := nil;
FSizeLabel := SGCreateLabel(Screen, '0', 100, 100, 500, 40, True);
end;

destructor TSGMaz1gWizardPaintable.Destroy();
begin
FConnectionHandler := nil;
inherited;
end;

procedure SGKill(var Maz1gWizardPaintable : TSGMaz1gWizardPaintable); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if Maz1gWizardPaintable <> nil then
	begin
	Maz1gWizardPaintable.Destroy();
	Maz1gWizardPaintable := nil;
	end;
end;

end.
