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
	
	TSGPhisics2D = class(TSGMutator)
		procedure UpDate();override;
		end;

implementation

procedure TSGPhisics2D.UpDate();
begin

end;

end.
