{$INCLUDE Includes\SaGe.inc}

unit SaGePhisics;

interface

uses
	SaGeBase
	,SaGeBased
	,SaGeCommon
	,SaGeMesh
	,SaGeModel
	,SaGeGameBase
	;

type
	TSGCollidableModel=class(TSGNod)
		FColizableMesh  : TSG3DObject;
		FWeight         : TSGSingle;   // Масса 
		FFriction       : TSGSingle;   // Трение
		FPositionShift  : TSGPosition; // Изменение позиции с течением времени (скорость с ее направлением)
		FPhysicDistance : TSGSingle;   // Для не напрягания физики
		end;
	
	TSGPhisic = class(TSGMutator)
		end;

implementation

end.
