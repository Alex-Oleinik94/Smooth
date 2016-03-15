{$INCLUDE SaGe.inc}

unit SaGeUserTesting;

interface

uses 
	 crt
	,SysUtils
	,SaGeBase
	,SaGeBased
	,SaGeContext
	,SaGeModel
	,SaGeScene
	,SaGeGamePhysics
	,SaGeGameNet
	,SaGeNet
	,SaGeLoading
	,SaGeUtils
	,SaGeMesh
	,SaGeScreen;
type
	TSGUserTesting=class(TSGDrawClass)
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():string;override;
			protected
		FRadioButton : TSGRadioButton;
		
			private
			
		end;

implementation

class function TSGUserTesting.ClassName():string;
begin
Result := 'TSGRadioButton';
end;

procedure TSGUserTesting.Draw();
begin

end;

constructor TSGUserTesting.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FRadioButton := TSGRadioButton.Create();
SGScreen.CreateChild(FRadioButton);
FRadioButton.SetBounds(200,200,40,40);
FRadioButton.BoundsToNeedBounds();
FRadioButton.Visible := True;
FRadioButton.ButtonType := SGRadioButton;
end;

destructor TSGUserTesting.Destroy();
begin
FRadioButton.Destroy();
inherited Destroy();
end;

end.
