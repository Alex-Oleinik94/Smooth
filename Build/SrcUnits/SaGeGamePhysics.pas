{$INCLUDE Includes\SaGe.inc}

unit SaGeGamePhysics;

interface

uses
	 SaGeBase
	,SaGeBased
	,SaGeCommon
	,SaGeMesh
	,SaGeModel
	,SaGeGameBase
	,SaGeScene
	,SaGePhysics
	;

type
	TSGCollidableModel=class(TSGNod)
			protected
		FCollidableMesh : TSG3DObject; // ���� ���� ����� �������������� ��� ���������� ������
		FFriction       : TSGSingle;   // ������
		FPhysicDistance : TSGSingle;   // ��� �� ���������� ������ (������������ ���������� ����� ������� � ��������)
			public
		property PhysicDistance : TSGSingle read FPhysicDistance;
		property Mesh : TSG3DObject read FCollidableMesh;
		end;
type
	TSGDinamycCollidableModel=class(TSGCollidableModel)
			protected
		FWeight         : TSGSingle;   // ����� 
		FPositionShift  : TSGPosition; // ��������� ������� � �������� ������� (�������� � �� ������������)
			public
		property PositionShift : TSGPosition read FPositionShift write FPositionShift;
		end;
type
	TSGCustomPhysics = class(TSGMutator)
		end;
type
	TSGPhysics3D = class(TSGCustomPhysics)
			public
		procedure UpDate();override;
		end;

implementation

procedure TSGPhysics3D.UpDate();
begin

end;

end.
