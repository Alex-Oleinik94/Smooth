
{$IFDEF SGREADINTERFACE}
type
	TSGMengerSpunchBoolAr6=array[0..5] of boolean;
	TSGMengerType = (FMengerCube,FMengerStar,FMengerPlus,FMengerExtendedCube);
const 
	TSGMengerSpunchBoolAr6Null:TSGMengerSpunchBoolAr6=(False,False,False,False,False,False);
	TSGMengerSpunchBoolAr6True:TSGMengerSpunchBoolAr6=(True,True,True,True,True,True);
type
	TSGFractalMengerSpunch=class(TSG3DFractal)
			public
		constructor Create(const VContext:PSGContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
			public
		FDeep:TSGMengerType;
		Ar6Normals:packed array [0..5] of  TSGVertex;
		FThreadsArray:packed array [0..19] of 
			record
			AllQ:Real;
			Q:Real;
			Arr6:TSGMengerSpunchBoolAr6;
			Point:TSGVertex;
			end;
		procedure CalculateArray;
		procedure Calculate;override;
		procedure CalculateFromThread(var MeshID,ThreadArB,ThreadArE:LongWord);
		function RecQuantity(const ArTP:TSGMengerSpunchBoolAr6;const NowDepth:LongInt):int64;
		function GetArTP(const OldArTP:TSGMengerSpunchBoolAr6;const i,ii,iii: byte;const ThisDepth:LongWord = 0):TSGMengerSpunchBoolAr6;inline;
		class function DoOrNotDo(const i,ii,iii:Byte):boolean;inline;
		class function DoOrNotDoPlus(const i,ii,iii:Byte):boolean;inline;
		procedure PushIndexes(const i1,i2,i3,i4:TSGVertex;const ai:longword;const AllQ:real;var MeshID:LongWord;var FVertexIndex,FFaceIndex:LongWord);inline;
		function DoAtThreads:boolean;inline;
		end;
		
	TSGMengerSpunchFractal=TSGFractalMengerSpunch;
	
	TSGMengerSpunchFractalData=class(TSGFractalData)
			public
		constructor Create(const a,b,c:LongWord;const d : TSGFractalMengerSpunch;const TID:LongWord);
			public
		a1,b1,c1:LongWord;
		end;
		
	TSGFractalMengerSpunchRelease=class(TSGFractalMengerSpunch)
			public
		constructor Create(const VContext:PSGContext);override;
		destructor Destroy;override;
			public
		FComboBox1,FComboBox2:TSGComboBox;
		FButtonDepthPlus,FButtonDepthMinus:TSGButton;
		FLabelDepth,FLabelDepthCaption,FLabelSize:TSGLabel;
		FSizeWriteTrue:Boolean;
		FFont1:TSGGLFont;
		procedure Calculate;override;
		procedure WriteSize;inline;
		procedure Draw;override;
		end;
{$ENDIF}


{$IFDEF SGREADIMPLEMENTATION}
{MENGER SPUNCH RELEASE}

procedure mmmFButtonDepthPlusOnChange(VButton:TSGButton);
begin
with TSGFractalMengerSpunchRelease(VButton.FUserPointer1) do
	begin
	if (not DoAtThreads) or (DoAtThreads and FMeshesReady) then
		begin
		FDepth+=1;
		Calculate;
		FSizeWriteTrue:=False;
		WriteSize;
		FButtonDepthMinus.Active:=True;
		end;
	end;
end;

procedure mmmFButtonDepthMinusOnChange(VButton:TSGButton);
begin
with TSGFractalMengerSpunchRelease(VButton.FUserPointer1) do
	begin
	if (Depth>0) and (not DoAtThreads) or (DoAtThreads and FMeshesReady) then
		begin
		FDepth-=1;
		Calculate;
		FSizeWriteTrue:=False;
		WriteSize;
		if Depth=0 then
			FButtonDepthMinus.Active:=False;
		end;
	end;
end;



procedure mmmComboBoxProcedure(a,b:LongInt;VComboBox:TSGComboBox);
begin
with TSGFractalMengerSpunchRelease(VComboBox.FUserPointer1) do
	begin
	if (not DoAtThreads) or (DoAtThreads and FMeshesReady) then
		begin
		if a<>b then
			begin
			case b of
			0:FDeep:=FMengerCube;
			1:FDeep:=FMengerStar;
			2:FDeep:=FMengerPlus;
			3:FDeep:=FMengerExtendedCube;
			end;Calculate;
			FSizeWriteTrue:=False;
			WriteSize;
			end;
		end;
	end;
end;

procedure mmmComboBoxProcedure2(a,b:LongInt;VComboBox:TSGComboBox);
begin
with TSGFractalMengerSpunchRelease(VComboBox.FUserPointer1) do
	begin
	if (not DoAtThreads) or (DoAtThreads and FMeshesReady) then
		if a<>b then
			begin
			FEnableNormals:=(b=0) or (b=1);
			FEnableColors:=(b=0) or (b=2);
			FLightingEnable:=FEnableNormals;
			Calculate;
			FSizeWriteTrue:=False;
			WriteSize;
			end;
	end;
end;

procedure TSGFractalMengerSpunchRelease.Draw;
begin
inherited;
WriteSize;
end;

procedure TSGFractalMengerSpunchRelease.Calculate;
begin
FLabelDepth.Caption:=SGStringToPChar(SGStr(FDepth));
inherited Calculate;
WriteSize;
end;

constructor TSGFractalMengerSpunchRelease.Create(const VContext:PSGContext);
begin
inherited Create(VContext);
FSizeWriteTrue:=False;

FFont1:=TSGGLFont.Create('.'+Slash+'..'+Slash+'Data'+Slash+'Fonts'+Slash+'Tahoma.bmp');
FFont1.SetContext(FContext);
FFont1.Loading;

InitProjectionComboBox(Context.Width-250-90-125-155,5{+Context.TopShift},150,30,[SGAnchRight],true);

FComboBox2:=TSGComboBox.Create;
SGScreen.CreateChild(FComboBox2);
SGScreen.LastChild.SetBounds(Context.Width-250,40{+Context.TopShift},230,30);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.AsComboBox.CreateItem('Нормали и Цвета');
SGScreen.LastChild.AsComboBox.CreateItem('Только Нормали');
SGScreen.LastChild.AsComboBox.CreateItem('Только Цвета');
SGScreen.LastChild.AsComboBox.CreateItem('Ваще Ничего');
SGScreen.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@mmmComboBoxProcedure2);
SGScreen.LastChild.AsComboBox.FSelectItem:=0;
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FComboBox1:=TSGComboBox.Create();
SGScreen.CreateChild(FComboBox1);
SGScreen.LastChild.SetBounds(Context.Width-250,5{+Context.TopShift},230,30);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.AsComboBox.CreateItem('Звездочка');
SGScreen.LastChild.AsComboBox.CreateItem('Губка Менгера');
SGScreen.LastChild.AsComboBox.CreateItem('Снежинка (bug)');
//SGScreen.LastChild.AsComboBox.CreateItem('New Губка Менгера');
SGScreen.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@mmmComboBoxProcedure);
SGScreen.LastChild.AsComboBox.FSelectItem:=0;
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FButtonDepthPlus:=TSGButton.Create();
SGScreen.CreateChild(FButtonDepthPlus);
SGScreen.LastChild.SetBounds(Context.Width-250-30,5{+Context.TopShift},20,30);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='+';
SGScreen.LastChild.FUserPointer1:=Self;
FButtonDepthPlus.OnChange:=TSGComponentProcedure(@mmmFButtonDepthPlusOnChange);
SGScreen.LastChild.Visible:=True;

FLabelDepth:=TSGLabel.Create();
SGScreen.CreateChild(FLabelDepth);
SGScreen.LastChild.SetBounds(Context.Width-250-60,5{+Context.TopShift},20,30);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='0';
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FButtonDepthMinus:=TSGButton.Create();
SGScreen.CreateChild(FButtonDepthMinus);
SGScreen.LastChild.SetBounds(Context.Width-250-90,5{+Context.TopShift},20,30);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='-';
FButtonDepthMinus.OnChange:=TSGComponentProcedure(@mmmFButtonDepthMinusOnChange);
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FLabelDepthCaption:=TSGLabel.Create();
SGScreen.CreateChild(FLabelDepthCaption);
SGScreen.LastChild.SetBounds(Context.Width-250-90-125,5{+Context.TopShift},115,30);
SGScreen.LastChild.AutoTopShift:=True;
SGScreen.LastChild.Anchors:=[SGAnchRight];
SGScreen.LastChild.Caption:='Итерация:';
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;

FLabelSize:=TSGLabel.Create();
SGScreen.CreateChild(FLabelSize);
SGScreen.LastChild.SetBounds(5,Context.Height-25,Context.Width-20,20);
SGScreen.LastChild.Caption:='Загрузка...';
SGScreen.LastChild.Anchors:=[SGAnchBottom];
SGScreen.LastChild.FUserPointer1:=Self;
FLabelSize.FTextPosition:=0;
FLabelSize.Font:=FFont1;
SGScreen.LastChild.Visible:=True;

Depth:=2;
Threads:=1;
Calculate();
WriteSize();
end;

procedure TSGFractalMengerSpunchRelease.WriteSize;inline;
var
	I:LongWord;
begin
if (not FSizeWriteTrue) and (FMesh<>nil) then
	if (not DoAtThreads) or (DoAtThreads and FMeshesReady) then
		begin
		FLabelSize.Caption:=SGStringToPChar(
			'Size-(All: '+SGGetSizeString(FMesh.Size)+
			' ;Face: '+SGGetSizeString(FMesh.FacesSize)+
			' ;Vert: '+SGGetSizeString(FMesh.VertexesSize)+
			' );LenArObj='+SGStr(FMesh.NOfObjects)+'.'
			);
		FSizeWriteTrue:=True;
		end
	else
		begin
		FLabelSize.Caption:=SGStringToPChar(
			'Загрузка... (NOfObjects='+SGStr(Length(FMesh.ArObjects))+';Threads='+SGStr(Threads)
			);
		if DoAtThreads then
			begin
			for i:=0 to Threads-1 do
				begin
				if not FThreadsData[i].FFinished then
					begin
					//FLabelSize.Caption:=
						{SGPCharTotal(FLabelSize.Caption,
						SGStringToPChar(';Threads(MeshId'+SGStr(i)+'='+SGStr(TSGMengerSpunchFractalData(Pointer(FThreadsData[i].FData)).a1+1)+')')
						);}
					FLabelSize.Caption:=FLabelSize.Caption+';Threads(MeshId'+SGStr(i)+'='+SGStr(TSGMengerSpunchFractalData(Pointer(FThreadsData[i].FData)).a1+1)+')';
					end;
				end;
			end;
		//FLabelSize.Caption:=SGPCharTotal(FLabelSize.Caption,')');
		FLabelSize.Caption:=FLabelSize.Caption+')';
		end;
end;

destructor TSGFractalMengerSpunchRelease.Destroy;
begin
if FLabelSize<>nil then 
	FLabelSize.Font:=nil;
if FComboBox1<>nil then FComboBox1.Destroy;
if FButtonDepthMinus<>nil then FButtonDepthMinus.Destroy;
if FButtonDepthPlus<>nil then FButtonDepthPlus.Destroy;
if FLabelDepth<>nil then FLabelDepth.Destroy;
if FComboBox2<>nil then FComboBox2.Destroy;
if FFont1<>nil then FFont1.Destroy;
if FLabelDepthCaption<>nil then FLabelDepthCaption.Destroy;
if FLabelSize<>nil then FLabelSize.Destroy;
inherited;
end;

{MENGER SPUNCH}

destructor TSGFractalMengerSpunch.Destroy;
begin
inherited;
end;

constructor TSGMengerSpunchFractalData.Create(const a,b,c:LongWord; const d:TSGFractalMengerSpunch;const TID:LongWord);
begin
inherited Create(d,TID);
a1:=a;
b1:=b;
c1:=c;
FFractal:=d;
ThreadID:=TID;
end;

procedure NewMengerThread(Klass:TSGMengerSpunchFractalData) ;
begin
(Klass.FFractal as TSGFractalMengerSpunch).CalculateFromThread(Klass.a1,Klass.b1,Klass.c1);
Klass.FFractal.FThreadsData[Klass.FThreadID].FFinished:=True;
Klass.FFractal.FThreadsData[Klass.FThreadID].FData:=nil;
Klass.Destroy;
end;

function TSGFractalMengerSpunch.DoAtThreads:boolean;inline;
begin
Result:=
(FThreadsEnable) and 
(Length(FThreadsData)>0) and 
(((20 mod Length(FThreadsData))=0) or (FDeep<>FMengerCube)) and (FDepth<>0) and (FDepth<>1);
end;

class function TSGFractalMengerSpunch.DoOrNotDoPlus(const i,ii,iii:Byte):boolean;inline;
begin
Result:=((i=1) or (ii=1) or (iii=1)) and (not ((i=1) and (ii=1) and (iii=1)));
end;

class function TSGFractalMengerSpunch.ClassName:string;
begin
Result:='Губка Менгера и тп';
end;

procedure TSGFractalMengerSpunch.Calculate;
var
	Quantity:int64 = 0;
	i,ii,iii:LongWord;
begin
ClearMesh();
if DoAtThreads then
	begin
	if FDeep = FMengerCube then
		begin
		FMeshesReady:=False;
		for i:=0 to High(FThreadsData) do
			begin
			Quantity:=0;
			for ii:=i*(20 div Length(FThreadsData)) to (i+1)*(20 div (Length(FThreadsData)))-1 do
				begin
				Quantity+=RecQuantity(FThreadsArray[ii].Arr6,FDepth-1);
				end;
			iii:=Length(FMesh.ArObjects);
			CalculateMeshes(Quantity,SGR_QUADS);
			FThreadsData[i].FData:=TSGMengerSpunchFractalData.Create(iii,i*(20 div Length(FThreadsData)),(i+1)*(20 div Length(FThreadsData))-1,Self,i);
			FThreadsData[i].FFinished:=False;
			end;
		for i:=0 to High(FThreadsData) do
			FThreadsData[i].FThread:=TSGThread.Create(TSGPointerProcedure(@NewMengerThread),FThreadsData[i].FData);;
		end;
	if FDeep <> FMengerCube then
		begin
		FMeshesReady:=False;
		for i:=0 to High(FThreadsData) do
			begin
			FThreadsData[i].FFinished:=True;
			FThreadsData[i].FData:=nil;
			end;
		CalculateMeshes(RecQuantity(TSGMengerSpunchBoolAr6True,FDepth),SGR_QUADS);
		FThreadsData[0].FFinished:=False;
		FThreadsData[0].FData:=TSGMengerSpunchFractalData.Create(0,0,0,Self,0);
		FThreadsData[0].FThread:=TSGThread.Create(TSGPointerProcedure(@NewMengerThread),FThreadsData[0].FData);
		end;
	end
else
	begin
	Quantity:=RecQuantity(TSGMengerSpunchBoolAr6True,FDepth);
	CalculateMeshes(Quantity,SGR_QUADS);
	i:=0;
	CalculateFromThread(i,i,i);
	end;
end;

constructor TSGFractalMengerSpunch.Create(const VContext:PSGContext);
begin
inherited Create(VContext);
FDeep:=FMengerCube;
FEnableColors:=True;
FEnableNormals:=True;
if FEnableNormals then
	begin
	Ar6Normals[0].Import(0,1,0);
	Ar6Normals[0].Normalize;
	Ar6Normals[1].Import(0,0,1);
	Ar6Normals[1].Normalize;
	Ar6Normals[2].Import(-1,0,0);
	Ar6Normals[2].Normalize;
	Ar6Normals[3].Import(0,0,-1);
	Ar6Normals[3].Normalize;
	Ar6Normals[4].Import(1,0,0);
	Ar6Normals[4].Normalize;
	Ar6Normals[5].Import(0,-1,0);
	Ar6Normals[5].Normalize;
	end;
CalculateArray;
end;

procedure TSGFractalMengerSpunch.CalculateFromThread(var MeshID,ThreadArB,ThreadArE:LongWord);
var
	i:LongInt;
	ArVerts:packed array [1..8]of TSGVertex;
	NOfV,NOfF:LongWord;// Индекс вершин и полигонов в меше

procedure Rec(const ArTP:TSGMengerSpunchBoolAr6;const T1:TSGVertex;const NowQ:real; const AllQ:real;const NowDepth:LongInt);
var
	i,ii,iii:Byte;
	NewQ:Real;
begin
if NowDepth<=0 then
	begin
	NewQ:=NowQ;
	
	ArVerts[9-8]:=T1;
	ArVerts[9-7].Import(T1.x+NewQ		,T1.y			,T1.z);
	ArVerts[9-6].Import(T1.x+NewQ		,T1.y			,T1.z+NewQ);
	ArVerts[9-5].Import(T1.x			,T1.y			,T1.z+NewQ);
	
	ArVerts[9-4].Import(T1.x,			T1.y+NewQ,		T1.z);
	ArVerts[9-3].Import(T1.x+NewQ,		T1.y+NewQ,		T1.z);
	ArVerts[9-2].Import(T1.x+NewQ,		T1.y+NewQ,		T1.z+NewQ);
	ArVerts[9-1].Import(T1.x,			T1.y+NewQ,		T1.z+NewQ);
	//Delay(10);
	for i:=0 to 5 do
		begin
		if ArTP[i] then
			begin
			case i of
			0:
				PushIndexes(ArVerts[1],ArVerts[2],ArVerts[3],ArVerts[4],i,AllQ,MeshID,NOfV,NOfF);
			1:
				PushIndexes(ArVerts[1],ArVerts[2],ArVerts[6],ArVerts[5],i,AllQ,MeshID,NOfV,NOfF);
			2:
				PushIndexes(ArVerts[2],ArVerts[3],ArVerts[7],ArVerts[6],i,AllQ,MeshID,NOfV,NOfF);
			3:
				PushIndexes(ArVerts[3],ArVerts[4],ArVerts[8],ArVerts[7],i,AllQ,MeshID,NOfV,NOfF);
			4:
				PushIndexes(ArVerts[4],ArVerts[1],ArVerts[5],ArVerts[8],i,AllQ,MeshID,NOfV,NOfF);
			5:
				PushIndexes(ArVerts[7],ArVerts[8],ArVerts[5],ArVerts[6],i,AllQ,MeshID,NOfV,NOfF);
			end;
			end;
		end;
	end
else
	begin
	NewQ:=NowQ/3;
	for i:=0 to 2 do
		for ii:=0 to 2 do
			for iii:=0 to 2 do
				if ((FDeep = FMengerCube) and (DoOrNotDo(i,ii,iii))) or
				((FDeep = FMengerStar) and (not DoOrNotDo(i,ii,iii))) or
				((FDeep = FMengerPlus) and (DoOrNotDoPlus(i,ii,iii))) then
					begin
					Rec( 
						(GetArTP(ArTP,i,ii,iii,NowDepth-1)),
						(T1+SGVertexImport(i*NewQ,ii*NewQ,iii*NewQ)),
						NewQ,AllQ,
						NowDepth-1);
					end;
	end;
end;

begin
NOfF:=0;
NOfV:=0;
if DoAtThreads then
	begin
	//try
	if FDeep = FMengerCube then
		begin
		for i:=ThreadArB to ThreadArE do
			begin
			Rec(
				FThreadsArray[i].Arr6,
				FThreadsArray[i].Point,
				FThreadsArray[i].Q,
				FThreadsArray[i].AllQ,
				FDepth-1);
			end;
		end
	else
		begin
		Rec(
			TSGMengerSpunchBoolAr6True,
			SGVertexImport(2.6,2.6,2.6),
			-5.2,-5.2,
			FDepth);
		end;
	//except 
	//end;
	if (MeshID>=0) and (MeshID<=FMesh.NOfObjects-1) then
		if FMeshesInfo[MeshID]=SG_FALSE then
			FMeshesInfo[MeshID]:=SG_TRUE;
	end
else
	begin
	Rec(
		TSGMengerSpunchBoolAr6True,
		SGVertexImport(2.6,2.6,2.6),
		-5.2,-5.2,
		FDepth);
	if FEnableVBO and (FMesh<>nil) then
		FMesh.ArObjects[FMesh.NOfObjects-1].LoadToVBO();
	end;
end;

function TSGFractalMengerSpunch.RecQuantity(const ArTP:TSGMengerSpunchBoolAr6;const NowDepth:LongInt):int64;
var
	i,ii,iii:Byte;
begin
Result:=0;
if NowDepth=0 then
	begin
	for i:=0 to 5 do
		begin
		if ArTP[i] then
			begin
			Result+=1;
			end;
		end;
	end
else
	begin
	for i:=0 to 2 do
		for ii:=0 to 2 do
			for iii:=0 to 2 do
				if ((FDeep = FMengerCube) and (DoOrNotDo(i,ii,iii))) or
				((FDeep = FMengerStar) and (not DoOrNotDo(i,ii,iii))) or
				((FDeep = FMengerPlus) and (DoOrNotDoPlus(i,ii,iii))) then
					begin
					Result+=RecQuantity( 
						(GetArTP(ArTP,i,ii,iii,NowDepth-1)),
						NowDepth-1);
					end;
	end;
end;

procedure TSGFractalMengerSpunch.CalculateArray;
var
	i,ii,iii,i4:Byte;
	NewQ:real = -5.2/3;
begin
i4:=0;
for i:=0 to 2 do
	for ii:=0 to 2 do
		for iii:=0 to 2 do
			if ((FDeep = FMengerCube) and (DoOrNotDo(i,ii,iii))) or
				((FDeep = FMengerStar) and (not DoOrNotDo(i,ii,iii))) or
				((FDeep = FMengerPlus) and (DoOrNotDoPlus(i,ii,iii))) then
				begin
				FThreadsArray[i4].Arr6:=GetArTP(TSGMengerSpunchBoolAr6True,i,ii,iii);
				FThreadsArray[i4].Point:=(SGVertexImport(2.6,2.6,2.6)+SGVertexImport(i*NewQ,ii*NewQ,iii*NewQ));
				FThreadsArray[i4].Q:=NewQ;
				FThreadsArray[i4].AllQ:=-5.2;
				i4+=1;
				end;
end;

class function TSGFractalMengerSpunch.DoOrNotDo(const i,ii,iii:Byte):boolean;inline;
begin
Result:=((i=1) and (ii=1)) or ((i=1) and (iii=1)) or ((ii=1) and (iii=1));
end;

function TSGFractalMengerSpunch.GetArTP(const OldArTP:TSGMengerSpunchBoolAr6;const i,ii,iii: byte;const ThisDepth:LongWord = 0):TSGMengerSpunchBoolAr6;inline;
begin
Result:=OldArTP;

if FDeep = FMengerStar then
	begin
	if (i=1) or (ii=1) or (iii=1) then
		begin
		if i=1 then
			begin
			Result[2]:=False;
			Result[4]:=False;
			end;
		if ii=1 then
			begin
			Result[0]:=False;
			Result[5]:=False;
			end;
		if iii=1 then
			begin
			Result[1]:=False;
			Result[3]:=False;
			end;
		if ii=0 then
			Result[5]:=True;
		if i=0 then
			Result[2]:=true;
		if iii=0 then
			Result[3]:=True;
		if ii=2 then
			Result[0]:=true;
		if i=2 then
			Result[4]:=True;
		if iii=2 then
			Result[1]:=True;
		end
	else
		begin
		if i=0 then
			Result[2]:=False;
		if ii=0 then
			Result[5]:=False;
		if iii=0 then
			Result[3]:=False;
		if i=2 then
			Result[4]:=False;
		if ii=2 then
			Result[0]:=False;
		if iii=2 then
			Result[1]:=False;
		end;
	end;
if FDeep = FMengerCube then
	begin
	if (ii=1) and (iii=1) and (i=1) then
		Result:=TSGMengerSpunchBoolAr6Null
	else
		begin
		Result:=TSGMengerSpunchBoolAr6True;
		if iii=0 then
			begin
			Result[1]:=OldArTP[1];
			Result[3]:=False;
			end;
		if iii=2 then
			begin
			Result[3]:=OldArTP[3];
			Result[1]:=False;
			end;
		if ii=0 then
			begin
			Result[0]:=OldArTP[0];
			Result[5]:=False;
			end;
		if ii=2 then
			begin
			Result[5]:=OldArTP[5];
			Result[0]:=False;
			end;
		if i=0 then
			begin
			Result[4]:=OldArTP[4];
			Result[2]:=False;
			end;
		if i=2 then
			begin
			Result[2]:=OldArTP[2];
			Result[4]:=False;
			end;
		end;
	end;
if FDeep = FMengerPlus then
	begin
	if (i=0) and ((ThisDepth=0) or ((ThisDepth<>0) and (not ((iii=1) and (ii=1))))) then
		Result[2]:=False;
	if (i=2) and((ThisDepth=0) or ((ThisDepth<>0) and (not ((iii=1) and (ii=1))))) then
		Result[4]:=False;
	if (ii=0) and((ThisDepth=0) or ((ThisDepth<>0) and (not ((iii=1) and (i=1))))) then
		Result[5]:=False;
	if (ii=2) and((ThisDepth=0) or ((ThisDepth<>0) and (not ((iii=1) and (i=1))))) then
		Result[0]:=False;
	if (iii=0) and((ThisDepth=0) or ((ThisDepth<>0) and (not ((i=1) and (ii=1))))) then
		Result[3]:=False;
	if (iii=2) and((ThisDepth=0) or ((ThisDepth<>0) and (not ((i=1) and (ii=1))))) then
		Result[1]:=False;
	end;
end;

procedure TSGFractalMengerSpunch.PushIndexes(const i1,i2,i3,i4:TSGVertex;const ai:longword;const AllQ:real;var MeshID:LongWord;var FVertexIndex,FFaceIndex:LongWord);inline;
//var
//abnu:	B:boolean = False;
begin
FVertexIndex+=4;
FMesh.ArObjects[MeshID].ArVertex3f[FVertexIndex-4]^:=i1;
FMesh.ArObjects[MeshID].ArVertex3f[FVertexIndex-3]^:=i2;
FMesh.ArObjects[MeshID].ArVertex3f[FVertexIndex-2]^:=i3;
FMesh.ArObjects[MeshID].ArVertex3f[FVertexIndex-1]^:=i4;

if FEnableColors then
	begin
	FMesh.ArObjects[MeshID].SetColor(FVertexIndex-4,abs((i1.x+AllQ/2)/AllQ),abs((i1.y+AllQ/2)/AllQ),abs((i1.z+AllQ/2)/AllQ));
	FMesh.ArObjects[MeshID].SetColor(FVertexIndex-3,abs((i2.x+AllQ/2)/AllQ),abs((i2.y+AllQ/2)/AllQ),abs((i2.z+AllQ/2)/AllQ));
	FMesh.ArObjects[MeshID].SetColor(FVertexIndex-2,abs((i3.x+AllQ/2)/AllQ),abs((i3.y+AllQ/2)/AllQ),abs((i3.z+AllQ/2)/AllQ));
	FMesh.ArObjects[MeshID].SetColor(FVertexIndex-1,abs((i4.x+AllQ/2)/AllQ),abs((i4.y+AllQ/2)/AllQ),abs((i4.z+AllQ/2)/AllQ));
	end;

if FEnableNormals then
	begin
	FMesh.ArObjects[MeshID].ArNormal[FVertexIndex-4]^:=Ar6Normals[ai];
	FMesh.ArObjects[MeshID].ArNormal[FVertexIndex-3]^:=Ar6Normals[ai];
	FMesh.ArObjects[MeshID].ArNormal[FVertexIndex-2]^:=Ar6Normals[ai];
	FMesh.ArObjects[MeshID].ArNormal[FVertexIndex-1]^:=Ar6Normals[ai];
	end;

FMesh.ArObjects[MeshID].ArFacesQuads[FFaceIndex].p[0]:=FVertexIndex-1;
FMesh.ArObjects[MeshID].ArFacesQuads[FFaceIndex].p[1]:=FVertexIndex-2;
FMesh.ArObjects[MeshID].ArFacesQuads[FFaceIndex].p[2]:=FVertexIndex-3;
FMesh.ArObjects[MeshID].ArFacesQuads[FFaceIndex].p[3]:=FVertexIndex-4;
FFaceIndex+=1;

AfterPushIndexes(MeshID,DoAtThreads,FVertexIndex,FFaceIndex);
end;
{$ENDIF}


