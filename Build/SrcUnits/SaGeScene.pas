{$INCLUDE Includes\SaGe.inc}
unit SaGeScene;

interface

uses
	SaGeBase
	,SaGeBased
	,SaGeCommon
	,SaGeContext
	,SaGeMesh
	,SaGeModel
	,SaGeUtils;

type
	TSGScene = class(TSGDrawClass)
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():string;override;
			private
		FCamera : TSGCamera; 
		FModels : packed array of 
			TSGModel;
		end;
implementation

constructor TSGScene.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FCamera := TSGCamera.Create();
FCamera.SetContext(Context);

end;

destructor TSGScene.Destroy();
begin
if FCamera<>nil then
	FCamera.Destroy();
inherited;
end;

procedure TSGScene.Draw();
begin

end;

class function TSGScene.ClassName():string;
begin
Result:='TSGScene';
end;

end.
