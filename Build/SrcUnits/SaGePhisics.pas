{$INCLUDE Includes\SaGe.inc}

unit SaGePhisics;

interface

uses
	SaGeBase
	,SaGeBased
	,SaGeCommon
	,SaGeMesh;

type
	TSGCollizable=class(TSG3DObject)
			public
		constructor Create();override;
		destructor Destroy();override;
			public
		function GetArVertexes2f():PTSGVertex2f;inline;
		function GetArVertexes3f():PTSGVertex3f;inline;
			protected
		FTurn:TSGVertex3f;				//������� � ������������
		FPosition:TSGVertex3f;			//������� � ������������
		FDistance:Single;				//���������, ����� ��� ����������� ������������ 
										//���������� ��������� ����� ���������
			public
		procedure TransfomMatrix();virtual;
		end;
	TSGCollizableStatic = TSGCollizable;
	
	TSGCollizableDunamic = class(TSGCollizableStatic)
			public
		constructor Create();override;
			protected
		FMassa:TSGSingle;				//����� �������
		FDirection:TSGVertex3f;			//����������� �������� (������ ��� ��������)
		FTurnDirection:TSGVertex3f;		//����������� ������������� � ������������ (������ ��� ��������)
		end;

function SGGetCollizionVertexGJK( const O1,O2:TSGCollizable; var CollizionVertex:TSGVertex3f):Boolean;inline;

implementation

function SGGetCollizionVertex2fGJK( const O1,O2:TSGCollizable; var CollizionVertex:TSGVertex3f):Boolean;inline;
//���� ������� ������������, �� Result = True, ���� ���, �� Result = false. 
//CollizionVertex - ��� ����� ������ ������������.
var
	O1Vertexes,O2Vertexes:PTSGVertex2f;
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
O1Vertexes:=O1.GetArVertexes2f();
O2Vertexes:=O2.GetArVertexes2f();
SetLength(ArMinkVertexes,O1.Vertexes*O2.Vertexes);
SetLength(ArMinkConnect,O1.Vertexes*O2.Vertexes);
iii:=0;
for i:=0 to O1.Vertexes-1 do
	for ii:=0 to O2.Vertexes-1 do
		begin
		ArMinkVertexes[iii]:=O1Vertexes[i]-O2Vertexes[ii];
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
	
	if ii=0 then
		i:=Length(ArMinkIndexes)-1
	else
		i:=ii-1;
	if ii=Length(ArMinkIndexes)-1 then
		iii:=0
	else
		iii:=ii+1;
	//� ���������� ��� ����� ���� 2� ���� � ��� i=ii. =) �� ��� ��� ���� ���� ��� ���.
	// � ����� ��� ����� ��������
	
	end;
if ArMinkIndexes<>nil then
	SetLength(ArMinkIndexes,0);
SetLength(ArMinkVertexes,0);
SetLength(ArMinkConnect,0);
end;

function SGGetCollizionVertex3fGJK( const O1,O2:TSGCollizable; var CollizionVertex:TSGVertex3f):Boolean;inline;
begin

end;

function SGGetCollizionVertexGJK( const O1,O2:TSGCollizable; var CollizionVertex:TSGVertex3f):Boolean;inline;
begin
if (O1.VertexType=SG_VERTEX_2F) and (O2.VertexType=SG_VERTEX_2F) then
	begin
	Result:=SGGetCollizionVertex2fGJK(O1,O2,CollizionVertex);
	end
else
	if (O1.VertexType=SG_VERTEX_3F) and (O2.VertexType=SG_VERTEX_3F) then
		begin
		Result:=SGGetCollizionVertex3fGJK(O1,O2,CollizionVertex);
		end
	else
		begin
		Result:=False;
		CollizionVertex:=0;
		end;
end;

(************************************************************************)
(*************************){TSGCollizableDunamic}(***********************)
(************************************************************************)


constructor TSGCollizableDunamic.Create();
begin
Inherited;
FMassa:=0;
FTurnDirection:=0;
FDirection:=0;
end;

(************************************************************************)
(*****************************){TSGCollizable}(**************************)
(************************************************************************)

procedure TSGCollizable.TransfomMatrix();
begin

end;

function TSGCollizable.GetArVertexes2f():PTSGVertex2f;inline;
begin
Result:=PTSGVertex2f(ArVertex);
end;

function TSGCollizable.GetArVertexes3f():PTSGVertex3f;inline;
begin
Result:=PTSGVertex3f(ArVertex);
end;

constructor TSGCollizable.Create();
begin
inherited;
FHasTexture:=False;
FHasNormals:=False;
FHasColors:=False;
FQuantityTextures:=0;
FPoligonesType:=0;
FVertexType:=SG_VERTEX_2F;
end;

destructor TSGCollizable.Destroy();
begin
inherited;
end;

end.
