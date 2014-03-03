{$INCLUDE Includes\SaGe.inc}
unit SaGePhisics;

interface

uses
	SaGeBase
	,SaGeBased
	,SaGeCommon
	,SaGeMesh
	,SaGeModel
	,SaGeUtils;

type
	TSGScene = class(TSGDrawClass)
		FCamera : TSGCamera; 
		FModels : packed array of 
			SaGeModel.TSGModel;
		end.
implementation

end.
