{$IFDEF SGREADINTERFACE}

const
	//>------ ������� Chunk, � ������ ������� 3ds-�����
	MAIN3DS	   		=$4D4D;

	//>------ ������� Chunk-�
	EDIT3DS				=$3D3D;			// ��� ������������� ������ ���� ����� ����������� �� �������
	cVERSION	   		=$0002;			// ������������� ������ .3ds �����
	cEDITKEYFRAME  		=$B000;			// ����� ��� ���� ���������� � ������

	//>------ ���-������� OBJECTINFO
	cMATERIAL	  		=$AFFF;		// ���������� � ���������
	EDIT_OBJECT			=$4000;		// ��������, �������, � �.�...

	//>------ ���-������� ��� MATERIAL
	cMATNAME	   		=$A000;			// �������� ���������
	cMATDIFFUSE   		=$A020;			// ������ ���� �������/���������
	cMATMAP				=$A200;			// ����� ��� ������ ���������
	cMATMAPFILE			=$A300;			// ������ ��� ����� ��������

	OBJ_TRIMESH   		=$4100;			// ��� ��� �����, ��� �������� ��������� ����� ������

	//>------ ���-������� ��� OBJECT_MESH
	TRI_VERTEXLIST	 	=$4110;	  // ������� �������
	TRI_FACELIST		=$4120;	  // �������� �������
	TRI_MATERIAL	 	=$4130;	  // ������ ���������, ���� ������ ����� ��������, ����� ����/��������
	TRI_MAPPINGCOORS   	=$4140;	  // UV ���������� ����������
	TRI_LOCAL 			=$4160;

type 
	TSGChunk=record
		ID:word;
		Length:longword;
	end;
	PSGChunk=^TSGChunk;

	TSGLoad3DS = class
		public
			constructor Create( const VStream:TFileStream = nil);
			destructor Destroy(); override;
			function Import3DS(const AModel:TSGCustomModel;out Sucsses : TSGBoolean):TSGLoad3DS;
			function SetFileName(const VFileName : TSGString):TSGLoad3DS;
			function SetStream(const VStream : TStream):TSGLoad3DS;
		private
			function FindChunk(ID:word;IsParent:boolean=false):longword;
			procedure ComputeNormals(const AModel:TSGCustomModel);
			procedure SkipHeader;
			procedure ReadHeader(AC:PSGChunk);
		private
			TFile	 : TStream;
			FFileName : TSGString;
			StrimIsSet : TSGBoolean;
			FQO : TSGLongWord;
	end;
{$ENDIF}

{$IFDEF SGREADIMPLEMENTATION}

{ TSGLoad3DS }

function TSGLoad3DS.SetStream(const VStream : TStream):TSGLoad3DS;
begin
TFile := VStream;
Result:=Self;
StrimIsSet:=True;
end;

function TSGLoad3DS.SetFileName(const VFileName : TSGString):TSGLoad3DS;
begin
FFileName:=VFileName;
Result:=Self;
end;

constructor TSGLoad3DS.Create(const VStream:TFileStream = nil);
begin
TFile:=nil;
if VStream<>nil then
	begin
	if TFile<>nil then
		TFile.Destroy;
	TFile:=VStream;
	end;
StrimIsSet:=False;
end;

destructor TSGLoad3DS.Destroy;
begin
	if (Tfile<>nil) and (not StrimIsSet) then
		TFile.Destroy;
	inherited Destroy;
end;

function TSGLoad3DS.Import3DS(const AModel:TSGCustomModel;out Sucsses : TSGBoolean): TSGLoad3DS;
var Ch:TSGChunk;
	ChPos,TempPos,ObjectsPos,c3dPos:TSGLongWord;
	Local:array[0..11] of TSGSingle;
	x0,x1,x2:TSGSingle;
	i:TSGWord;
	iii,t1,t2,t3:TSGWord;
begin
Result:=Self;
FQO := AModel.QuantityObjects;
Sucsses:=False;
SGLog.Source(['TSGLoad3DS.Import3DS : Loading "',FFileName,'"']);
if TFile= nil then
	Tfile:=TFileStream.Create(FFileName,fmOpenRead);
if Tfile=nil then
	begin
	SGLog.Source(['TSGLoad3DS.Import3DS : �� ������� ������� ���� "',FFileName,'"']);
	exit;
	end;
//������ ���������
Tfile.Read(Ch.ID,2);
Tfile.Read(Ch.Length,4);
Tfile.Position:=Tfile.Position-6;
if Ch.ID<>MAIN3DS then
	begin
	SGLog.Source(['TSGLoad3DS.Import3DS : ��� �� 3d ����! "',FFileName,'"']);
	exit;
	end;
//������� ���� ���������
ChPos:=Self.FindChunk(EDIT3DS,true);
c3dPos:=ChPos;
//==================================================================
//========================������ ���������==========================
//==================================================================
//���� ���������
ChPos:=Self.FindChunk(cMATERIAL,true);
ObjectsPos:=ChPos;
Tfile.Read(Ch.ID,2); 
Tfile.Position:=Tfile.Position-2;
while Ch.ID=cMATERIAL do
	begin
	AModel.AddMaterial();
	TempPos:=ChPos;
	ChPos:=Self.FindChunk(cMATNAME,true);
	Tfile.Position:=Tfile.Position+6;
	AModel.LastMaterial().Name := SGReadStringFromStream(TFile);
	//Tfile.Position:=ObjectsPos;
	ChPos:=Self.FindChunk(cMATMAP,true);
	ReadHeader(@Ch);
	if Ch.ID=cMATMAP then
		begin
		ChPos:=Self.FindChunk(cMATMAPFILE,true);
		ReadHeader(@Ch);
		if Ch.ID=cMATMAPFILE then
			begin
			Tfile.Position:=Tfile.Position+6;
			AModel.LastMaterial().AddDiffuseMap(SGGetFileWay(FFileName) + SGReadStringFromStream(TFile));
			end;
		end;
	SGLog.Source(['TSGLoad3DS.Import3DS : Material: "',AModel.LastMaterial().Name,'.']);
	//���� ����� ��������
	Tfile.Position:=ObjectsPos;
	Tfile.Read(Ch.ID,2);
	Tfile.Read(Ch.Length,4);
	Tfile.Position:=Tfile.Position-6+Ch.Length;
	ObjectsPos:=Tfile.Position;
	if TFile.Position=Tfile.Size then break;
	Tfile.Read(Ch.ID,2);
	Tfile.Position:=ObjectsPos;
	end;
//==================================================================
//========================������ ���������==========================
//==================================================================
Tfile.Position:=c3dPos;
//���������� ��� ����� ����� �������
ChPos:=Self.FindChunk(EDIT_OBJECT,true);
ObjectsPos:=ChPos;
Tfile.Read(Ch.ID,2);
Tfile.Position:=Tfile.Position-2;
while Ch.ID=EDIT_OBJECT do
	begin
	//������� ������ � ������
	AModel.AddObject();
	AModel.LastObject().HasNormals := True;
	AModel.LastObject().HasColors  := False;
	AModel.LastObject().EnableCullFace:=True;
	AModel.LastObject().ObjectPoligonesType:=SGR_TRIANGLES;
	AModel.LastObject().VertexType:=SGMeshVertexType3f;
	Tfile.Position:=Tfile.Position+6;
	AModel.LastObject().Name := SGReadStringFromStream(TFile);
	SGLog.Source(['TSGLoad3DS.Import3DS : Object: "',AModel.LastObject().Name,'"']);
	Tfile.Position:=ObjectsPos;
	//������� ���� �����
	ChPos:=Self.FindChunk(OBJ_TRIMESH,true);
	TempPos:=ChPos; //�������� ������� ����� ��� ������ ���������
	
	// ���������, ���� �� � ������� ���������� ���������� 
	// ����� ��������� �� ����, ��� �� ������ � ����������� ������ ������ �� ������
	Tfile.Position:=TempPos;
	ChPos:=Self.FindChunk(TRI_MAPPINGCOORS,true);
	SkipHeader;
	TFile.Read(iii,2);
	AModel.LastObject().HasTexture := iii<>0;
	
	//������� ������ ������
	Tfile.Position:=TempPos;
	ChPos:=Self.FindChunk(TRI_VERTEXLIST,true);
	with AModel.LastObject() do
		begin
		//������� ���-�� ���������
		SkipHeader;
		TFile.Read(iii,2);
		SetVertexLength(iii);
		for i:=0 to QuantityVertexes-1 do
			with ArVertex3f[i]^ do
				begin
				Tfile.Read(x,4);
				Tfile.Read(z,4);
				Tfile.Read(y,4);
				end;
		
		//�������� � ������ ���������� ������
		Tfile.Position:=TempPos;
		ChPos:=Self.FindChunk(TRI_MAPPINGCOORS,true);
		SkipHeader;
		TFile.Read(iii,2);
		if iii<>QuantityVertexes then
			begin
			SGLog.Source('TSGLoad3DS.Import3DS : Fatal : Quantity Vrtexes <> Quantity Texture Vertexes!');
			AModel.Clear();
			Exit;
			end;
		for i:=0 to QuantityVertexes-1 do
			with ArTexVertex[i]^ do
				begin
				Tfile.Read(x,4);
				Tfile.Read(y,4);
				end;
		
		//�������� � ������ ������
		Tfile.Position:=TempPos;
		ChPos:=Self.FindChunk(TRI_FACELIST,true);
		SkipHeader;
		TFile.Read(iii,2);
		AddFaceArray();
		AutoSetIndexFormat(0,Vertexes);
		SetFaceLength(0,iii);
		for i:=0 to Faces[0]-1 do
			begin
			TFile.Read(t1,2);
			TFile.Read(t2,2);
			TFile.Read(t3,2);
			Tfile.Position:=Tfile.Position+2;
			SetFaceTriangle(0,i,t1,t2,t3);
			end;
		
		//������ � ������ � ��������� ������� �������
		Tfile.Position:=TempPos;
		ChPos:=Self.FindChunk(TRI_LOCAL,true);
		SkipHeader;
		TFile.Read(Local,sizeof(single)*12);
		//��������� ��������������
		for i:=0 to QuantityVertexes-1 do
			begin
			ArVertex3f[i]^.x-=Local[9];
			ArVertex3f[i]^.z-=Local[10];
			ArVertex3f[i]^.y-=Local[11];
			x0:=ArVertex3f[i]^.x;
			x1:=ArVertex3f[i]^.y;
			x2:=ArVertex3f[i]^.z;
			ArVertex3f[i]^.x:=Local[0]*x0+Local[2]*x1+Local[1]*x2;
			ArVertex3f[i]^.z:=Local[3]*x0+Local[5]*x1+Local[4]*x2;
			ArVertex3f[i]^.y:=Local[6]*x0+Local[8]*x1+Local[7]*x2;
			end;
		Tfile.Position:=TempPos;
		ChPos:=Self.FindChunk(TRI_FACELIST,true);
		Tfile.Position:=Tfile.Position+2+6+Faces[0]*4*2;
		ChPos:=Self.FindChunk(TRI_MATERIAL,false);
		ReadHeader(@Ch);
		if Ch.ID=TRI_MATERIAL then
			begin
			TFile.Position:=TFile.Position+6;
			AModel.CreateMaterialIDInLastObject(SGReadStringFromStream(TFile));
			end;
		end;
	Tfile.Position:=ObjectsPos;
	Tfile.Read(Ch.ID,2);
	Tfile.Read(Ch.Length,4);
	Tfile.Position:=Tfile.Position-6+Ch.Length;
	ObjectsPos:=Tfile.Position;
	if TFile.Position=Tfile.Size then break;
	Tfile.Read(Ch.ID,2);
	Tfile.Position:=ObjectsPos;
	end;
ComputeNormals(AModel);
Sucsses:=True;
end;

function TSGLoad3DS.FindChunk(ID: word; IsParent: boolean=false): longword;inline;

var CuCh:TSGChunk;
	c:char;
begin
	if IsParent then
	begin
		TFile.Read(CuCh.ID,2);
		Tfile.Read(CuCh.Length,4);
		//���� ��� ���� �������, �� ����� ���������� ������ ����� �������
		if CuCh.ID=EDIT_OBJECT then
		begin
			repeat
				TFile.Read(c,1);
			until c=#0;
		end;
	end;
	//�������� ����� ������ ������������� �����
	repeat
		TFile.Read(CuCh.ID,2);
		TFile.Read(CuCh.Length,4);
		if CuCh.ID<>ID then
		begin
			TFile.Position:=TFile.Position+CuCh.Length-6;
		end
		else
		begin
			Tfile.Position:=TFile.Position-6;
			result:=TFile.Position;
			exit;
		end;
	until TFile.Position>=Tfile.Size;
end;

procedure TSGLoad3DS.ComputeNormals(const AModel:TSGCustomModel);
var vVector1, vVector2, vNormal,vSum:TSGVertex3f;
	vPoly:array[0..2]of TSGVertex3f;
	pNormals,pTempNormals:array of TSGVertex3f;
	iObject,i,ii,shared:longword;

function Cross(const vVector1,vVector2:TSGVertex3f):TSGVertex3f;inline;
begin
	result.x:=((vVector1.y * vVector2.z) - (vVector1.z * vVector2.y));
	result.y:=((vVector1.z * vVector2.x) - (vVector1.x * vVector2.z));
	result.z:=((vVector1.x * vVector2.y) - (vVector1.y * vVector2.x));
end;
var
	DT,DT2:TSGDateTime;
begin
DT.Get();
SGLog.Source('TSGLoad3DS.ComputeNormals : Started');
if AModel.QuantityObjects>0 then
	begin
	for iObject:=FQO to AModel.QuantityObjects-1 do
		begin
		with AModel.Objects[iObject] do
			begin
			//SetLength(ArNormals,FNOfVerts);
			SetLength(pNormals,Faces[0]);
			SetLength(pTempNormals,Faces[0]);
			for i:=0 to Faces[0]-1 do
				begin
				vPoly[0]:=ArVertex3f[ArFacesTriangles(0,i).p0]^;
				vPoly[1]:=ArVertex3f[ArFacesTriangles(0,i).p1]^;
				vPoly[2]:=ArVertex3f[ArFacesTriangles(0,i).p2]^;
				
				vVector1:=vPoly[0]-vPoly[2];
				vVector2:=vPoly[1]-vPoly[2];
				
				vNormal:=Cross(vVector1,vVector2);
				pTempNormals[i]:=vNormal;
				vNormal := vNormal.Normalized();
				pNormals[i]:=vNormal;
				end;
			vSum.Import();
			shared:=0;
			for i:=0 to QuantityVertexes-1 do
				begin
				for ii:=0 to Faces[0]-1 do
					begin
					if (ArFacesTriangles(0,ii).p0=i)or(ArFacesTriangles(0,ii).p1=i)or(ArFacesTriangles(0,ii).p2=i) then
						begin
						vSum+=pTempNormals[ii];
						shared+=1;
						end;
					end;
				ArNormal[i]^:=vSum/(-shared);
				ArNormal[i]^ := ArNormal[i]^.Normalized();
				vSum.Import();
				shared:=0;
				end;
			end;
		SetLength(pNormals,0);
		SetLength(pTempNormals,0);
		end;
	end;
DT2.Get();
SGLog.Source('TSGLoad3DS.ComputeNormals : Endng ( '+
	SGSecondsToStringTime((DT2-DT).GetPastSeconds)+' '+SGStr((DT2-DT).GetPastMiliSeconds div 100)+' �������'+' )');
end;

procedure TSGLoad3DS.SkipHeader;inline;
begin
  Tfile.Position:=Tfile.Position+6;
end;

procedure TSGLoad3DS.ReadHeader(AC: PSGChunk);
begin
	Tfile.Read(AC^.ID,2);
	Tfile.Read(AC^.Length,4);
	Tfile.Position:=Tfile.Position-6;
end;


{$ENDIF}