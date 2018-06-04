{$INCLUDE SaGe.inc}

unit SaGeMaz1gWizardWindow;

interface

uses
	 SaGeBase
	,SaGeScreen
	,SaGeCommonClasses
	;

type
	TSGMaz1gWizardWindow = class(TSGScreenedDrawable)
			public
		constructor Create(const _Context : ISGContext); override;
		destructor Destroy(); override;
		procedure Paint(); override;
		end;

procedure SGKill(var Maz1gWizardWindow : TSGMaz1gWizardWindow); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

procedure TSGMaz1gWizardWindow.Paint();
begin

end;

constructor TSGMaz1gWizardWindow.Create(const _Context : ISGContext);
begin
inherited Create(_Context);

end;

destructor TSGMaz1gWizardWindow.Destroy();
begin
inherited;
end;

procedure SGKill(var Maz1gWizardWindow : TSGMaz1gWizardWindow); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if Maz1gWizardWindow <> nil then
	begin
	Maz1gWizardWindow.Destroy();
	Maz1gWizardWindow := nil;
	end;
end;

end.
