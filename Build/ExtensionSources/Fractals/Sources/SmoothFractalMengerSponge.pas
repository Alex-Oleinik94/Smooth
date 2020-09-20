{$INCLUDE Smooth.inc}

unit SmoothFractalMengerSponge;

interface

uses
	 SmoothBase
	,SmoothFractal
	,Smooth3DFractal
	,SmoothCommon
	,SmoothCommonStructs
	,SmoothContextInterface
	,SmoothScreen
	,SmoothFont
	,SmoothScreenClasses
	;
type
	TSMengerSpongeBoolAr6=array[0..5] of TSBool;
	TSMengerType = (SMengerCube,SMengerStar,SMengerSnowflake);
const
	SDefaultMengerType = SMengerCube;
	TSMengerSpongeBoolAr6Null:TSMengerSpongeBoolAr6=(False,False,False,False,False,False);
	TSMengerSpongeBoolAr6True:TSMengerSpongeBoolAr6=(True,True,True,True,True,True);
type
	TSFractalMengerSponge=class(TS3DFractal)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
			public
		FFractalType:TSMengerType;
		Ar6Normals:packed array [0..5] of  TSVertex3f;
		FThreadsArray:packed array [0..19] of 
			record
			AllQ:TSFloat64;
			Q:TSFloat64;
			Arr6:TSMengerSpongeBoolAr6;
			Point:TSVertex3f;
			end;
		procedure ConstructArray();
		procedure Construct();override;
		procedure PolygonsConstruction(var ObjectId,ThreadArB,ThreadArE:TSFractalIndexInt);
		class function CountingTheNumberOfPolygons(const _FractalType : TSMengerType; const _BoolArray:TSMengerSpongeBoolAr6;const _Depth:TSInt32):TSInt64;
		class function ConstructBoolArray(const _FractalType : TSMengerType; const _PreviousBoolArray:TSMengerSpongeBoolAr6;const i,j,k: TSUInt8;const _Depth:TSUInt32 = 0):TSMengerSpongeBoolAr6;
		class function DoOrNotDo(const i,ii,iii:TSUInt8):TSBoolean;inline;
		class function DoOrNotDoPlus(const i,ii,iii:TSUInt8):TSBoolean;inline;
		procedure PushPoligonData(const i1,i2,i3,i4:TSVertex3f;const ai:TSUInt32;const AllQ:Real;var ObjectId, FVertexIndex,FFaceIndex:TSFractalIndexInt);inline;
		function DoAtThreads():TSBoolean;inline;
		end;
		
	TSMengerSpongeFractal=TSFractalMengerSponge;
	
	TSMengerSpongeFractalData=class(TSFractalData)
			public
		constructor Create(const a,b,c:TSFractalIndexInt;const d : TSFractalMengerSponge;const TID:TSUInt32);
			public
		a1,b1,c1:TSFractalIndexInt;
		end;
		
	TSFractalMengerSpongeRelease=class(TSFractalMengerSponge)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy;override;
			public
		FComboBox1, FComboBox2 : TSScreenComboBox;
		FButtonDepthPlus,FButtonDepthMinus:TSScreenButton;
		FLabelDepth, FLabelDepthCaption : TSScreenLabel;
		FFont1:TSFont;
		procedure Construct;override;
		procedure Paint();override;
		end;

implementation

uses
	 SmoothStringUtils
	,SmoothScreenBase
	,SmoothRenderBase
	,SmoothThreads
	,SmoothFileUtils
	;

{MENGER SPUNCH RELEASE}

procedure MengerSpongeButtonDepthPlusOnChange(VButton:TSScreenButton);
begin
with TSFractalMengerSpongeRelease(VButton.FUserPointer1) do
	begin
	if (not DoAtThreads) or (DoAtThreads and F3dObjectsReady) then
		begin
		FDepth+=1;
		Construct;
		FButtonDepthMinus.Active:=True;
		end;
	end;
end;

procedure MengerSpongeButtonDepthMinusOnChange(VButton:TSScreenButton);
begin
with TSFractalMengerSpongeRelease(VButton.FUserPointer1) do
	begin
	if (Depth>0) and (not DoAtThreads) or (DoAtThreads and F3dObjectsReady) then
		begin
		FDepth-=1;
		Construct;
		if Depth=0 then
			FButtonDepthMinus.Active:=False;
		end;
	end;
end;

procedure FractalMengerSpongeReleaseComboBoxProcedure(a,b:LongInt;VComboBox:TSScreenComboBox);
begin
with TSFractalMengerSpongeRelease(VComboBox.FUserPointer1) do
	begin
	if (not DoAtThreads) or (DoAtThreads and F3dObjectsReady) then
		begin
		if a<>b then
			begin
			case b of //because strange bug
			1:FFractalType:=SMengerCube;
			0:FFractalType:=SMengerStar;
			2:FFractalType:=SMengerSnowflake;
			end;
			Construct;
			end;
		end;
	end;
end;

procedure FractalMengerSpongeReleaseComboBoxProcedure2(a,b:LongInt;VComboBox:TSScreenComboBox);
begin
with TSFractalMengerSpongeRelease(VComboBox.FUserPointer1) do
	begin
	if (not DoAtThreads) or (DoAtThreads and F3dObjectsReady) then
		if a<>b then
			begin
			FEnableNormals:=(b=0) or (b=1);
			FEnableColors:=(b=0) or (b=2);
			FLightingEnable:=FEnableNormals;
			Construct;
			end;
	end;
end;

procedure TSFractalMengerSpongeRelease.Paint();
begin
inherited;
end;

procedure TSFractalMengerSpongeRelease.Construct;
begin
FLabelDepth.Caption:=SStringToPChar(SStr(FDepth));
inherited Construct;
FSizeLabelFlag := False;
end;

constructor TSFractalMengerSpongeRelease.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FFont1 := SCreateFontFromFile(Context, SDefaultFontFileName);

InitProjectionComboBox(Render.Width-250-90-125-155,5,150,30,[SAnchRight]).BoundsMakeReal();
InitSizeLabel(5,Render.Height-25,Render.Width-20,20,[SAnchBottom]).BoundsMakeReal();

FComboBox2:=TSScreenComboBox.Create;
Screen.CreateChild(FComboBox2);
Screen.LastChild.SetBounds(Render.Width-250,40,230,30);
Screen.LastChild.Anchors:=[SAnchRight];
(Screen.LastChild as TSScreenComboBox).CreateItem('Нормали и Цвета');
(Screen.LastChild as TSScreenComboBox).CreateItem('Только Нормали');
(Screen.LastChild as TSScreenComboBox).CreateItem('Только Цвета');
(Screen.LastChild as TSScreenComboBox).CreateItem('Ваще Ничего');
(Screen.LastChild as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@FractalMengerSpongeReleaseComboBoxProcedure2);
(Screen.LastChild as TSScreenComboBox).SelectItem:=0;
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FComboBox1:=TSScreenComboBox.Create();
Screen.CreateChild(FComboBox1);
Screen.LastChild.SetBounds(Render.Width-250,5,230,30);
Screen.LastChild.Anchors:=[SAnchRight];
(Screen.LastChild as TSScreenComboBox).CreateItem('Губка Менгера');
(Screen.LastChild as TSScreenComboBox).CreateItem('Звездочка');
(Screen.LastChild as TSScreenComboBox).CreateItem('Снежинка (beta)');
(Screen.LastChild as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@FractalMengerSpongeReleaseComboBoxProcedure);
(Screen.LastChild as TSScreenComboBox).SelectItem:=1; //because strange bug
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FButtonDepthPlus:=TSScreenButton.Create();
Screen.CreateChild(FButtonDepthPlus);
Screen.LastChild.SetBounds(Render.Width-250-30,5,20,30);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='+';
Screen.LastChild.FUserPointer1:=Self;
FButtonDepthPlus.OnChange:=TSScreenComponentProcedure(@MengerSpongeButtonDepthPlusOnChange);
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FLabelDepth := SCreateLabel(Screen, '0', Render.Width-250-60,5,20,30, [SAnchRight], True, True, Self);

FButtonDepthMinus:=TSScreenButton.Create();
Screen.CreateChild(FButtonDepthMinus);
Screen.LastChild.SetBounds(Render.Width-250-90,5,20,30);
Screen.LastChild.Anchors:=[SAnchRight];
Screen.LastChild.Caption:='-';
FButtonDepthMinus.OnChange:=TSScreenComponentProcedure(@MengerSpongeButtonDepthMinusOnChange);
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsMakeReal();

FLabelDepthCaption := SCreateLabel(Screen, 'Итерация:', Render.Width-250-90-125,5,115,30, [SAnchRight], True, True, Self);

Threads:={$IFDEF ANDROID}0{$ELSE}1{$ENDIF};
FFractalType := SDefaultMengerType;
Depth := 2;
Construct();
end;

destructor TSFractalMengerSpongeRelease.Destroy();
begin
SKill(FComboBox1);
SKill(FButtonDepthMinus);
SKill(FButtonDepthPlus);
SKill(FLabelDepth);
SKill(FComboBox2);
SKill(FFont1);
SKill(FLabelDepthCaption);
inherited;
end;

{MENGER SPUNCH}

destructor TSFractalMengerSponge.Destroy;
begin
inherited;
end;

constructor TSMengerSpongeFractalData.Create(const a,b,c:TSFractalIndexInt; const d:TSFractalMengerSponge;const TID:LongWord);
begin
inherited Create(d,TID);
a1:=a;
b1:=b;
c1:=c;
FFractal:=d;
FThreadID:=TID;
end;

procedure NewMengerThread(MengerSpongeFractalData:TSMengerSpongeFractalData);
begin
(MengerSpongeFractalData.FFractal as TSFractalMengerSponge).PolygonsConstruction(MengerSpongeFractalData.a1,MengerSpongeFractalData.b1,MengerSpongeFractalData.c1);
MengerSpongeFractalData.FFractal.FThreadsData[MengerSpongeFractalData.FThreadID].FFinished:=True;
MengerSpongeFractalData.FFractal.FThreadsData[MengerSpongeFractalData.FThreadID].FData:=nil;
MengerSpongeFractalData.Destroy();
end;

function TSFractalMengerSponge.DoAtThreads:boolean;inline;
begin
Result:=
	(FThreadsEnable) and 
	(Length(FThreadsData) > 0) and 
	(((20 mod Length(FThreadsData)) = 0) or (FFractalType <> SMengerCube)) and (FDepth<>0) and (FDepth<>1);
end;

class function TSFractalMengerSponge.DoOrNotDoPlus(const i,ii,iii:TSUInt8):TSBool;inline;
begin
Result:=((i=1) or (ii=1) or (iii=1)) and (not ((i=1) and (ii=1) and (iii=1)));
end;

class function TSFractalMengerSponge.ClassName:string;
begin
Result := 'Губка Менгера и подобное (beta)';
end;

procedure TSFractalMengerSponge.Construct;
var
	NumberOfPolygons : TSFractalIndexInt;
	Index, Index2 : TSMaxEnum;
	i, j, k : TSFractalIndexInt;
begin
Clear3dObject();
if DoAtThreads then
	begin
	if FFractalType = SMengerCube then
		begin
		F3dObjectsReady:=False;
		for Index:=0 to High(FThreadsData) do
			begin
			NumberOfPolygons:=0;
			for Index2:=Index*(20 div Length(FThreadsData)) to (Index+1)*(20 div (Length(FThreadsData)))-1 do
				begin
				NumberOfPolygons+=CountingTheNumberOfPolygons(FFractalType,FThreadsArray[Index2].Arr6,FDepth-1);
				end;
			k := F3dObject.QuantityObjects;
			Construct3dObjects(NumberOfPolygons,SR_QUADS);
			FThreadsData[Index].FData:=TSMengerSpongeFractalData.Create(k ,Index*(20 div Length(FThreadsData)),(Index+1)*(20 div Length(FThreadsData))-1,Self,Index);
			FThreadsData[Index].FFinished:=False;
			end;
		for Index:=0 to High(FThreadsData) do
			FThreadsData[Index].FThread:=TSThread.Create(TSPointerProcedure(@NewMengerThread),FThreadsData[Index].FData);
		end;
	if FFractalType <> SMengerCube then
		begin
		F3dObjectsReady:=False;
		for Index:=0 to High(FThreadsData) do
			begin
			FThreadsData[Index].FFinished:=True;
			FThreadsData[Index].FData:=nil;
			end;
		Construct3dObjects(CountingTheNumberOfPolygons(FFractalType,TSMengerSpongeBoolAr6True,FDepth),SR_QUADS);
		Index := 0;
		FThreadsData[Index].FFinished:=False;
		FThreadsData[Index].FData:=TSMengerSpongeFractalData.Create(0,0,0,Self,Index);
		FThreadsData[Index].FThread:=TSThread.Create(TSPointerProcedure(@NewMengerThread),FThreadsData[Index].FData);
		end;
	end
else
	begin
	NumberOfPolygons:=CountingTheNumberOfPolygons(FFractalType,TSMengerSpongeBoolAr6True,FDepth);
	Construct3dObjects(NumberOfPolygons,SR_QUADS);
	i:=0;j:=0;k:=0;
	PolygonsConstruction(i, j, k);
	end;
end;

constructor TSFractalMengerSponge.Create(const VContext : ISContext);
begin
inherited;
FFractalType:=SDefaultMengerType;
EnableColors:=True;
EnableNormals:=True;
if FEnableNormals then
	begin
	Ar6Normals[0].Import(0,1,0);
	Ar6Normals[0] := Ar6Normals[0].Normalized();
	Ar6Normals[1].Import(0,0,1);
	Ar6Normals[1] := Ar6Normals[1].Normalized();
	Ar6Normals[2].Import(-1,0,0);
	Ar6Normals[2] := Ar6Normals[2].Normalized();
	Ar6Normals[3].Import(0,0,-1);
	Ar6Normals[3] := Ar6Normals[3].Normalized();
	Ar6Normals[4].Import(1,0,0);
	Ar6Normals[4] := Ar6Normals[4].Normalized();
	Ar6Normals[5].Import(0,-1,0);
	Ar6Normals[5] := Ar6Normals[5].Normalized();
	end;
ConstructArray();
end;

procedure TSFractalMengerSponge.PolygonsConstruction(var ObjectId,ThreadArB,ThreadArE:TSFractalIndexInt);
var
	i:LongInt;
	ArVerts:packed array [1..8]of TSVertex3f;
	NOfV,NOfF:TSFractalIndexInt;// Индекс количества вершин и полигонов в 3D обьекте

procedure Rec(const ArTP:TSMengerSpongeBoolAr6;const T1:TSVertex3f;const NowQ:real; const AllQ:real;const NowDepth:LongInt);
var
	i,ii,iii:TSUInt8;
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
				PushPoligonData(ArVerts[1],ArVerts[2],ArVerts[3],ArVerts[4],i,AllQ,ObjectId,NOfV,NOfF);
			1:
				PushPoligonData(ArVerts[1],ArVerts[2],ArVerts[6],ArVerts[5],i,AllQ,ObjectId,NOfV,NOfF);
			2:
				PushPoligonData(ArVerts[2],ArVerts[3],ArVerts[7],ArVerts[6],i,AllQ,ObjectId,NOfV,NOfF);
			3:
				PushPoligonData(ArVerts[3],ArVerts[4],ArVerts[8],ArVerts[7],i,AllQ,ObjectId,NOfV,NOfF);
			4:
				PushPoligonData(ArVerts[4],ArVerts[1],ArVerts[5],ArVerts[8],i,AllQ,ObjectId,NOfV,NOfF);
			5:
				PushPoligonData(ArVerts[7],ArVerts[8],ArVerts[5],ArVerts[6],i,AllQ,ObjectId,NOfV,NOfF);
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
				if ((FFractalType = SMengerCube)      and (DoOrNotDo(i,ii,iii))) or
				   ((FFractalType = SMengerStar)      and (not DoOrNotDo(i,ii,iii))) or
				   ((FFractalType = SMengerSnowflake) and (DoOrNotDoPlus(i,ii,iii))) then
					begin
					Rec( 
						(ConstructBoolArray(FFractalType,ArTP,i,ii,iii,NowDepth-1)),
						(T1+SVertex3fImport(i*NewQ,ii*NewQ,iii*NewQ)),
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
	if FFractalType = SMengerCube then
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
			TSMengerSpongeBoolAr6True,
			SVertex3fImport(2.6,2.6,2.6),
			-5.2,-5.2,
			FDepth);
		end;
	//except 
	//end;
	if (ObjectId>=0) and (ObjectId<=F3dObject.QuantityObjects-1) then
		if F3dObjectsInfo[ObjectId]=S_FALSE then
			F3dObjectsInfo[ObjectId]:=S_TRUE;
	end
else
	begin
	Rec(
		TSMengerSpongeBoolAr6True,
		SVertex3fImport(2.6,2.6,2.6),
		-5.2,-5.2,
		FDepth);
	if FEnableVBO and (F3dObject<>nil) then
		F3dObject.LastObject().LoadToVBO();
	end;
end;

class function TSFractalMengerSponge.CountingTheNumberOfPolygons(const _FractalType : TSMengerType; const _BoolArray:TSMengerSpongeBoolAr6;const _Depth:TSInt32):TSInt64;
var
	i,j,k:TSUInt8;
begin
Result:=0;
if _Depth=0 then
	begin
	for i:=0 to 5 do
		begin
		if _BoolArray[i] then
			begin
			Result+=1;
			end;
		end;
	end
else
	begin
	for i:=0 to 2 do
		for j:=0 to 2 do
			for k:=0 to 2 do
				if ((_FractalType = SMengerCube) and (DoOrNotDo(i,j,k))) or
				((_FractalType = SMengerStar) and (not DoOrNotDo(i,j,k))) or
				((_FractalType = SMengerSnowflake) and (DoOrNotDoPlus(i,j,k))) then
					begin
					Result+=CountingTheNumberOfPolygons(_FractalType,
						(ConstructBoolArray(_FractalType,_BoolArray,i,j,k,_Depth-1)),
						_Depth-1);
					end;
	end;
end;

procedure TSFractalMengerSponge.ConstructArray;
var
	i,ii,iii,i4:Byte;
	NewQ:real = -5.2/3;
begin
i4:=0;
for i:=0 to 2 do
	for ii:=0 to 2 do
		for iii:=0 to 2 do
			if ((FFractalType = SMengerCube) and (DoOrNotDo(i,ii,iii))) or
				((FFractalType = SMengerStar) and (not DoOrNotDo(i,ii,iii))) or
				((FFractalType = SMengerSnowflake) and (DoOrNotDoPlus(i,ii,iii))) then
				begin
				FThreadsArray[i4].Arr6:=ConstructBoolArray(FFractalType,TSMengerSpongeBoolAr6True,i,ii,iii);
				FThreadsArray[i4].Point:=(SVertex3fImport(2.6,2.6,2.6)+SVertex3fImport(i*NewQ,ii*NewQ,iii*NewQ));
				FThreadsArray[i4].Q:=NewQ;
				FThreadsArray[i4].AllQ:=-5.2;
				i4+=1;
				end;
end;

class function TSFractalMengerSponge.DoOrNotDo(const i,ii,iii:Byte):boolean;
begin
Result:=((i=1) and (ii=1)) or ((i=1) and (iii=1)) or ((ii=1) and (iii=1));
end;

class function TSFractalMengerSponge.ConstructBoolArray(const _FractalType : TSMengerType; const _PreviousBoolArray:TSMengerSpongeBoolAr6;const i,j,k: TSUInt8;const _Depth:TSUInt32 = 0):TSMengerSpongeBoolAr6;
begin
Result:=_PreviousBoolArray;

if _FractalType = SMengerStar then
	begin
	if (i=1) or (j=1) or (k=1) then
		begin
		if i=1 then
			begin
			Result[2]:=False;
			Result[4]:=False;
			end;
		if j=1 then
			begin
			Result[0]:=False;
			Result[5]:=False;
			end;
		if k=1 then
			begin
			Result[1]:=False;
			Result[3]:=False;
			end;
		if j=0 then
			Result[5]:=True;
		if i=0 then
			Result[2]:=true;
		if k=0 then
			Result[3]:=True;
		if j=2 then
			Result[0]:=True;
		if i=2 then
			Result[4]:=True;
		if k=2 then
			Result[1]:=True;
		end
	else
		begin
		if i=0 then
			Result[2]:=False;
		if j=0 then
			Result[5]:=False;
		if k=0 then
			Result[3]:=False;
		if i=2 then
			Result[4]:=False;
		if j=2 then
			Result[0]:=False;
		if k=2 then
			Result[1]:=False;
		end;
	end;
if _FractalType = SMengerCube then
	begin
	if (j=1) and (k=1) and (i=1) then
		Result:=TSMengerSpongeBoolAr6Null
	else
		begin
		Result:=TSMengerSpongeBoolAr6True;
		if k=0 then
			begin
			Result[1]:=_PreviousBoolArray[1];
			Result[3]:=False;
			end;
		if k=2 then
			begin
			Result[3]:=_PreviousBoolArray[3];
			Result[1]:=False;
			end;
		if j=0 then
			begin
			Result[0]:=_PreviousBoolArray[0];
			Result[5]:=False;
			end;
		if j=2 then
			begin
			Result[5]:=_PreviousBoolArray[5];
			Result[0]:=False;
			end;
		if i=0 then
			begin
			Result[4]:=_PreviousBoolArray[4];
			Result[2]:=False;
			end;
		if i=2 then
			begin
			Result[2]:=_PreviousBoolArray[2];
			Result[4]:=False;
			end;
		end;
	end;
if _FractalType = SMengerSnowflake then
	begin
	if (i=0) and ((_Depth=0) or ((_Depth<>0) and (not ((k=1) and (j=1))))) then
		Result[2]:=False;
	if (i=2) and((_Depth=0) or ((_Depth<>0) and (not ((k=1) and (j=1))))) then
		Result[4]:=False;
	if (j=0) and((_Depth=0) or ((_Depth<>0) and (not ((k=1) and (i=1))))) then
		Result[5]:=False;
	if (j=2) and((_Depth=0) or ((_Depth<>0) and (not ((k=1) and (i=1))))) then
		Result[0]:=False;
	if (k=0) and((_Depth=0) or ((_Depth<>0) and (not ((i=1) and (j=1))))) then
		Result[3]:=False;
	if (k=2) and((_Depth=0) or ((_Depth<>0) and (not ((i=1) and (j=1))))) then
		Result[1]:=False;
	end;
end;

procedure TSFractalMengerSponge.PushPoligonData(const i1,i2,i3,i4:TSVertex3f;const ai:longword;const AllQ:real;var ObjectId, FVertexIndex,FFaceIndex:TSFractalIndexInt);inline;
//var
//abnu:	B:boolean = False;
begin
FVertexIndex+=4;
F3dObject.Objects[ObjectId].ArVertex3f[FVertexIndex-4]^:=i1;
F3dObject.Objects[ObjectId].ArVertex3f[FVertexIndex-3]^:=i2;
F3dObject.Objects[ObjectId].ArVertex3f[FVertexIndex-2]^:=i3;
F3dObject.Objects[ObjectId].ArVertex3f[FVertexIndex-1]^:=i4;

if FEnableColors then
	begin
	F3dObject.Objects[ObjectId].SetColor(FVertexIndex-4,abs((i1.x+AllQ/2)/AllQ),abs((i1.y+AllQ/2)/AllQ),abs((i1.z+AllQ/2)/AllQ));
	F3dObject.Objects[ObjectId].SetColor(FVertexIndex-3,abs((i2.x+AllQ/2)/AllQ),abs((i2.y+AllQ/2)/AllQ),abs((i2.z+AllQ/2)/AllQ));
	F3dObject.Objects[ObjectId].SetColor(FVertexIndex-2,abs((i3.x+AllQ/2)/AllQ),abs((i3.y+AllQ/2)/AllQ),abs((i3.z+AllQ/2)/AllQ));
	F3dObject.Objects[ObjectId].SetColor(FVertexIndex-1,abs((i4.x+AllQ/2)/AllQ),abs((i4.y+AllQ/2)/AllQ),abs((i4.z+AllQ/2)/AllQ));
	end;

if FEnableNormals then
	begin
	F3dObject.Objects[ObjectId].ArNormal[FVertexIndex-4]^:=Ar6Normals[ai];
	F3dObject.Objects[ObjectId].ArNormal[FVertexIndex-3]^:=Ar6Normals[ai];
	F3dObject.Objects[ObjectId].ArNormal[FVertexIndex-2]^:=Ar6Normals[ai];
	F3dObject.Objects[ObjectId].ArNormal[FVertexIndex-1]^:=Ar6Normals[ai];
	end;

F3dObject.Objects[ObjectId].SetFaceQuad(0,FFaceIndex,FVertexIndex-1,FVertexIndex-2,FVertexIndex-3,FVertexIndex-4);
FFaceIndex+=1;

AfterPushingPoligonData(ObjectId,DoAtThreads,FVertexIndex,FFaceIndex);
end;

end.
