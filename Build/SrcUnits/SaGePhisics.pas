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
	
	TSGPhisics2D = class(TSGMutator)
		procedure UpDate();override;
		end;

implementation

procedure TSGPhisics2D.UpDate();
begin

end;

end.
