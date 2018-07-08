{$INCLUDE SaGe.inc}

unit SaGeMaz1gWizardPaintable;

interface

uses
	 SaGeBase
	,SaGeScreen
	,SaGeContextInterface
	,SaGeContextClasses
	,SaGeWorldOfWarcraftConnectionHandler
	,SaGeScreenClasses
	;

type
	TSGMaz1gWizardPaintable = class(TSGScreenPaintableObject)
			public
		constructor Create(const _Context : ISGContext); override;
		destructor Destroy(); override;
		procedure Paint(); override;
		class function ClassName() : TSGString; override;
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

class function TSGMaz1gWizardPaintable.ClassName() : TSGString;
begin
Result := 'Maz1g Wizard';
end;

procedure TSGMaz1gWizardPaintable.Paint();
begin
Write('Paint');
if (ConnectionHandler <> nil) then
	FSizeLabel.Caption := SGStr(FConnectionHandler.AllDataSize);
end;

constructor TSGMaz1gWizardPaintable.Create(const _Context : ISGContext);
begin
inherited Create(_Context);
FConnectionHandler := nil;
FSizeLabel := SGCreateLabel(Screen, '0', 100, 100, 500, 40, True, True);
WriteLn('Create');
end;

destructor TSGMaz1gWizardPaintable.Destroy();
begin
WriteLn('Destroy');
FConnectionHandler := nil;
if (FSizeLabel <> nil) then
	begin
	FSizeLabel.Destroy();
	FSizeLabel := nil;
	end;
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
