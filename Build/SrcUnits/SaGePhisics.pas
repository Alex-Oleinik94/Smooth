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
		FWeight         : TSGSingle;   // ����� 
		FFriction       : TSGSingle;   // ������
		FPositionShift  : TSGPosition; // ��������� ������� � �������� ������� (�������� � �� ������������)
		FPhysicDistance : TSGSingle;   // ��� �� ���������� ������
		end;
	
	TSGPhisic = class(TSGMutator)
		end;

implementation

end.
