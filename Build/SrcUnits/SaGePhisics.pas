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
	,SaGeScene
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
		end;
type
	TSGPCollidableMember = packed record
		RIncluded : TSGBoolean;
		RCollidableModel    : TSGCollidableModel;
		RModel : TSGModel;
		end;
type
	TSGPCollidableGroup = packed array of TSGPCollidableMember;
type
	TSGCustomPhisics = class(TSGMutator)
			private
		procedure ProcessingCollidableGroup(const Player,QuantityCollidables:TSGLongWord;var CollidableGroup : TSGPCollidableGroup);virtual;abstract;
			public
		procedure UpDate();override;
		end;
type
	TSGPhisics2D = class(TSGCustomPhisics)
			private
		procedure ProcessingCollidableGroup(const Player,QuantityCollidables:TSGLongWord;var CollidableGroup : TSGPCollidableGroup);override;
		end;

// � ��� ����������� �������, ����� ������� � ������� ������������� ��������
function SGGetCollizionVertex2fGJK( const O1,O2:TSGCollidableModel; out CollizionVertex:TSGVertex3f; out CollidableDepth:TSGSingle):TSGBoolean;inline;

implementation

function SGGetCollizionVertex2fGJK( const O1,O2:TSGCollidableModel; out CollizionVertex:TSGVertex3f; out CollidableDepth:TSGSingle):TSGBoolean;inline;
//���� ������� ������������, �� Result = True, ���� ���, �� Result = false. 
//CollizionVertex - ��� ����� ������ ������������.
var
	ArMinkVertexes:packed array of TSGVertex2f;//�������� �����������...
	ArMinkConnect:
		packed array of 
			packed record
				p0,p1:LongWord;
				end;//��� ��� ������� ������� ������� �������� ����������� �� ���������, ��� � �� ���� �� ��������
	i,ii,iii:TSGMaxEnum;
	ArMinkIndexes:TSGArLongWord;//��� ������� ��������� ������ ����� �������� �����������
	R1,R2:Single;
begin
Result:=False;
CollizionVertex:=0;
SetLength(ArMinkVertexes,O1.Mesh.Vertexes*O2.Mesh.Vertexes);
SetLength(ArMinkConnect,O1.Mesh.Vertexes*O2.Mesh.Vertexes);
iii:=0;
for i:=0 to O1.Mesh.Vertexes-1 do
	for ii:=0 to O2.Mesh.Vertexes-1 do
		begin
		ArMinkVertexes[iii]:=O1.Mesh.ArVertex2f[i]^-O2.Mesh.ArVertex2f[ii]^;
		ArMinkConnect[iii].p0:=i;
		ArMinkConnect[iii].p1:=ii;
		iii+=1;
		end;
ArMinkIndexes:=SGGetPointsCirclePoints(ArMinkVertexes);
if not ((ArMinkIndexes=nil) or (Length(ArMinkIndexes)<3)) then
	begin
	ii:=0;
	R1:=Abs(ArMinkVertexes[ArMinkIndexes[0]]);
	for i:=1 to Length(ArMinkIndexes)-1 do//� ���� ����� �� ���� ����� ������������ � ������ ��������� �����
		begin
		R2:=Abs(ArMinkVertexes[ArMinkIndexes[i]]);
		if R1>R2 then
			begin
			R1:=R2;
			ii:=i;
			end;
		end;
	//���������� �������� ����� ��� ii-�� �����.
	if ii=0 then
		i:=Length(ArMinkIndexes)-1
	else
		i:=ii-1;
	if ii=Length(ArMinkIndexes)-1 then
		iii:=0
	else
		iii:=ii+1;
	// � ����� ��� ����� ��������
	// ........
	
	end;
if ArMinkIndexes<>nil then
	SetLength(ArMinkIndexes,0);
SetLength(ArMinkVertexes,0);
SetLength(ArMinkConnect,0);
end;

// Processing CollidableGroup which indexes of collidable models of scene
procedure TSGPhisics2D.ProcessingCollidableGroup(const Player,QuantityCollidables:TSGLongWord;var CollidableGroup : TSGPCollidableGroup);
begin

end;

procedure TSGCustomPhisics.UpDate();
var
	Scene:TSGScene = nil;
	Index : TSGLongWord;
	CollidableGroup : TSGPCollidableGroup = nil;
	PlayerCollidableModel, IndexCollidableModel : TSGCollidableModel;
	QuantityCollidables : TSGLongWord = 0;
begin
Scene := FParent as TSGScene;
if (Scene <> nil) and (Scene.Player <> -1) then
	begin
	PlayerCollidableModel := Scene.Models[Scene.Player].FindProperty(TSGCollidableModel) as TSGCollidableModel;
	if PlayerCollidableModel <>nil then
		begin
		SetLength(CollidableGroup,Scene.QuantityNods);
		FillChar(CollidableGroup[0],Scene.QuantityNods*SizeOf(CollidableGroup[0]),0);
		for Index := 0 to Scene.QuantityNods-1 do
			if (Scene.Models[Index] <> nil) and (Scene.Player <> Index) then
				begin
				IndexCollidableModel := Scene.Models[Index].FindProperty(TSGCollidableModel) as TSGCollidableModel;
				if IndexCollidableModel <> nil then
					begin
					if SGAbsTwoVertex(Scene.Models[Index].Position.Location, Scene.Models[Scene.Player].Position.Location) < 
						PlayerCollidableModel.PhysicDistance+IndexCollidableModel.PhysicDistance then
							begin
							CollidableGroup[Index].RIncluded := True;
							CollidableGroup[Index].RCollidableModel := IndexCollidableModel;
							CollidableGroup[Index].RModel := Scene.Models[Index];
							QuantityCollidables +=1;
							end;
					end;
				end;
		if QuantityCollidables<>0 then
			begin
			CollidableGroup[Scene.Player].RIncluded := False;
			CollidableGroup[Scene.Player].RCollidableModel := PlayerCollidableModel;
			CollidableGroup[Scene.Player].RModel := Scene.Models[Scene.Player];
			ProcessingCollidableGroup(Scene.Player,QuantityCollidables,CollidableGroup);
			end;
		SetLength(CollidableGroup,0);
		end;
	end;
end;

end.
