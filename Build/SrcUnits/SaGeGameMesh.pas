{$INCLUDE Includes\SaGe.inc}
unit SaGeGameMesh;
interface
uses 
	 SaGeBase
	,SaGeBased
	,SaGeMesh
	,SaGeContext
	,SaGeCommon;
type
	TSGGameMesh=class(TSGDrawClass)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		FMeshDraw,FMeshPhiscs:TSGModel;
		FTurn:TSGVertex3f;				//������� � ������������
		FPosition:TSGVertex3f;			//������� � ������������
		FDistance:Single;				//���������, ����� ��� ����������� ������������ 
										//���������� ��������� ����� ���������
			public
		procedure Draw();override;
		procedure TransfomMatrix();virtual;
		end;

	TSGGameActor=class(TSGGameMesh)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		FMassa:TSGSingle;				//����� �������
		FDirection:TSGVertex3f;			//����������� �������� (������ ��� ��������)
		FTurnDirection:TSGVertex3f;		//����������� ������������� � ������������ (������ ��� ��������)
		end;

implementation

///=============================================
///=================TSGGameActor================
///=============================================

constructor TSGGameActor.Create();
begin
inherited;
FMassa:=0;
FDirection:=0;
FTurnDirection:=0;
end;

destructor TSGGameActor.Destroy();
begin
inherited;
end;

///=============================================
///=================TSGGameMesh=================
///=============================================

procedure TSGGameMesh.TransfomMatrix();
begin

end;

procedure TSGGameMesh.Draw();
begin
if FMeshDraw<>nil then
	FMeshDraw.Draw()
else
	if FMeshPhiscs<>nil then
		FMeshPhiscs.Draw();
end;

constructor TSGGameMesh.Create();
begin
inherited;
FMeshDraw:=nil;
FMeshPhiscs:=nil;
FTurn:=0;
FPosition:=0;
FDistance:=0;
end;

destructor TSGGameMesh.Destroy();
begin
if FMeshDraw<>nil then
	FMeshDraw.Destroy();
if FMeshPhiscs<>nil then
	FMeshPhiscs.Destroy();
inherited;
end;

end.
