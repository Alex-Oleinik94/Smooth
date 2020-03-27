{$INCLUDE Smooth.inc}

unit SmoothFractalMengerSponge;

interface

uses
	 SmoothBase
	,SmoothFractals
	,SmoothCommon
	,SmoothCommonStructs
	,SmoothContextInterface
	,SmoothScreen
	,SmoothFont
	,SmoothScreenClasses
	;
type
	TSMengerSpongeBoolAr6=array[0..5] of TSBool;
	TSMengerType = (FMengerCube,FMengerStar,FMengerPlus,FMengerExtendedCube);
const 
	TSMengerSpongeBoolAr6Null:TSMengerSpongeBoolAr6=(False,False,False,False,False,False);
	TSMengerSpongeBoolAr6True:TSMengerSpongeBoolAr6=(True,True,True,True,True,True);
type
	TSFractalMengerSponge=class(TS3DFractal)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
			public
		FDeep:TSMengerType;
		Ar6Normals:packed array [0..5] of  TSVertex3f;
		FThreadsArray:packed array [0..19] of 
			record
			AllQ:Real;
			Q:Real;
			Arr6:TSMengerSpongeBoolAr6;
			Point:TSVertex3f;
			end;
		procedure CalculateArray();
		procedure Calculate();override;
		procedure CalculateFromThread(var ObjectId,ThreadArB,ThreadArE:LongWord);
		function RecQuantity(const ArTP:TSMengerSpongeBoolAr6;const NowDepth:LongInt):int64;
		function GetArTP(const OldArTP:TSMengerSpongeBoolAr6;const i,ii,iii: byte;const ThisDepth:LongWord = 0):TSMengerSpongeBoolAr6;inline;
		class function DoOrNotDo(const i,ii,iii:Byte):boolean;inline;
		class function DoOrNotDoPlus(const i,ii,iii:Byte):boolean;inline;
		procedure PushIndexes(const i1,i2,i3,i4:TSVertex3f;const ai:longword;const AllQ:real;var ObjectId:LongWord;var FVertexIndex,FFaceIndex:LongWord);inline;
		function DoAtThreads():boolean;inline;
		end;
		
	TSMengerSpongeFractal=TSFractalMengerSponge;
	
	TSMengerSpongeFractalData=class(TSFractalData)
			public
		constructor Create(const a,b,c:LongWord;const d : TSFractalMengerSponge;const TID:LongWord);
			public
		a1,b1,c1:LongWord;
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
		procedure Calculate;override;
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
		Calculate;
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
		Calculate;
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
			case b of
			0:FDeep:=FMengerCube;
			1:FDeep:=FMengerStar;
			2:FDeep:=FMengerPlus;
			3:FDeep:=FMengerExtendedCube;
			end;
			Calculate;
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
			Calculate;
			end;
	end;
end;

procedure TSFractalMengerSpongeRelease.Paint();
begin
inherited;
end;

procedure TSFractalMengerSpongeRelease.Calculate;
begin
FLabelDepth.Caption:=SStringToPChar(SStr(FDepth));
inherited Calculate;
FSizeLabelFlag := False;
end;

constructor TSFractalMengerSpongeRelease.Create(const VContext : ISContext);
begin
inherited Create(VContext);
FFont1 := SCreateFontFromFile(Context, SDefaultFontFileName);

InitProjectionComboBox(Render.Width-250-90-125-155,5,150,30,[SAnchRight]);
Screen.LastChild.BoundsMakeReal();

InitSizeLabel(5,Render.Height-25,Render.Width-20,20,[SAnchBottom]);
Screen.LastChild.BoundsMakeReal();

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
(Screen.LastChild as TSScreenComboBox).CreateItem('Звездочка');
(Screen.LastChild as TSScreenComboBox).CreateItem('Губка Менгера');
(Screen.LastChild as TSScreenComboBox).CreateItem('Снежинка (bug)');
//(Screen.LastChild as TSScreenComboBox).CreateItem('New Губка Менгера');
(Screen.LastChild as TSScreenComboBox).CallBackProcedure:=TSScreenComboBoxProcedure(@FractalMengerSpongeReleaseComboBoxProcedure);
(Screen.LastChild as TSScreenComboBox).SelectItem:=0;
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

Depth:=2;
{$IFNDEF ANDROID}
	Threads:=1;
	{$ENDIF}
Calculate();
end;

destructor TSFractalMengerSpongeRelease.Destroy();
begin
if FComboBox1<>nil then FComboBox1.Destroy;
if FButtonDepthMinus<>nil then FButtonDepthMinus.Destroy;
if FButtonDepthPlus<>nil then FButtonDepthPlus.Destroy;
if FLabelDepth<>nil then FLabelDepth.Destroy;
if FComboBox2<>nil then FComboBox2.Destroy;
if FFont1<>nil then FFont1.Destroy;
if FLabelDepthCaption<>nil then FLabelDepthCaption.Destroy;
inherited;
end;

{MENGER SPUNCH}

destructor TSFractalMengerSponge.Destroy;
begin
inherited;
end;

constructor TSMengerSpongeFractalData.Create(const a,b,c:LongWord; const d:TSFractalMengerSponge;const TID:LongWord);
begin
inherited Create(d,TID);
a1:=a;
b1:=b;
c1:=c;
FFractal:=d;
FThreadID:=TID;
end;

procedure NewMengerThread(Klass:TSMengerSpongeFractalData) ;
begin
(Klass.FFractal as TSFractalMengerSponge).CalculateFromThread(Klass.a1,Klass.b1,Klass.c1);
Klass.FFractal.FThreadsData[Klass.FThreadID].FFinished:=True;
Klass.FFractal.FThreadsData[Klass.FThreadID].FData:=nil;
Klass.Destroy();
end;

function TSFractalMengerSponge.DoAtThreads:boolean;inline;
begin
Result:=
(FThreadsEnable) and 
(Length(FThreadsData)>0) and 
(((20 mod Length(FThreadsData))=0) or (FDeep<>FMengerCube)) and (FDepth<>0) and (FDepth<>1);
end;

class function TSFractalMengerSponge.DoOrNotDoPlus(const i,ii,iii:Byte):boolean;inline;
begin
Result:=((i=1) or (ii=1) or (iii=1)) and (not ((i=1) and (ii=1) and (iii=1)));
end;

class function TSFractalMengerSponge.ClassName:string;
begin
Result:='Губка Менгера и тп';
end;

procedure TSFractalMengerSponge.Calculate;
var
	Quantity:int64 = 0;
	i,ii,iii:LongWord;
begin
Clear3dObject();
if DoAtThreads then
	begin
	if FDeep = FMengerCube then
		begin
		F3dObjectsReady:=False;
		for i:=0 to High(FThreadsData) do
			begin
			Quantity:=0;
			for ii:=i*(20 div Length(FThreadsData)) to (i+1)*(20 div (Length(FThreadsData)))-1 do
				begin
				Quantity+=RecQuantity(FThreadsArray[ii].Arr6,FDepth-1);
				end;
			iii:=F3dObject.QuantityObjects;
			Calculate3dObjects(Quantity,SR_QUADS);
			FThreadsData[i].FData:=TSMengerSpongeFractalData.Create(iii,i*(20 div Length(FThreadsData)),(i+1)*(20 div Length(FThreadsData))-1,Self,i);
			FThreadsData[i].FFinished:=False;
			end;
		for i:=0 to High(FThreadsData) do
			FThreadsData[i].FThread:=TSThread.Create(TSPointerProcedure(@NewMengerThread),FThreadsData[i].FData);;
		end;
	if FDeep <> FMengerCube then
		begin
		F3dObjectsReady:=False;
		for i:=0 to High(FThreadsData) do
			begin
			FThreadsData[i].FFinished:=True;
			FThreadsData[i].FData:=nil;
			end;
		Calculate3dObjects(RecQuantity(TSMengerSpongeBoolAr6True,FDepth),SR_QUADS);
		FThreadsData[0].FFinished:=False;
		FThreadsData[0].FData:=TSMengerSpongeFractalData.Create(0,0,0,Self,0);
		FThreadsData[0].FThread:=TSThread.Create(TSPointerProcedure(@NewMengerThread),FThreadsData[0].FData);
		end;
	end
else
	begin
	Quantity:=RecQuantity(TSMengerSpongeBoolAr6True,FDepth);
	Calculate3dObjects(Quantity,SR_QUADS);
	i:=0;ii:=0;iii:=0;
	CalculateFromThread(i,ii,iii);
	end;
end;

constructor TSFractalMengerSponge.Create(const VContext : ISContext);
begin
inherited;
FDeep:=FMengerCube;
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
CalculateArray();
end;

procedure TSFractalMengerSponge.CalculateFromThread(var ObjectId,ThreadArB,ThreadArE:LongWord);
var
	i:LongInt;
	ArVerts:packed array [1..8]of TSVertex3f;
	NOfV,NOfF:LongWord;// Индекс вершин и полигонов в меше

procedure Rec(const ArTP:TSMengerSpongeBoolAr6;const T1:TSVertex3f;const NowQ:real; const AllQ:real;const NowDepth:LongInt);
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
				PushIndexes(ArVerts[1],ArVerts[2],ArVerts[3],ArVerts[4],i,AllQ,ObjectId,NOfV,NOfF);
			1:
				PushIndexes(ArVerts[1],ArVerts[2],ArVerts[6],ArVerts[5],i,AllQ,ObjectId,NOfV,NOfF);
			2:
				PushIndexes(ArVerts[2],ArVerts[3],ArVerts[7],ArVerts[6],i,AllQ,ObjectId,NOfV,NOfF);
			3:
				PushIndexes(ArVerts[3],ArVerts[4],ArVerts[8],ArVerts[7],i,AllQ,ObjectId,NOfV,NOfF);
			4:
				PushIndexes(ArVerts[4],ArVerts[1],ArVerts[5],ArVerts[8],i,AllQ,ObjectId,NOfV,NOfF);
			5:
				PushIndexes(ArVerts[7],ArVerts[8],ArVerts[5],ArVerts[6],i,AllQ,ObjectId,NOfV,NOfF);
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

function TSFractalMengerSponge.RecQuantity(const ArTP:TSMengerSpongeBoolAr6;const NowDepth:LongInt):int64;
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

procedure TSFractalMengerSponge.CalculateArray;
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
				FThreadsArray[i4].Arr6:=GetArTP(TSMengerSpongeBoolAr6True,i,ii,iii);
				FThreadsArray[i4].Point:=(SVertex3fImport(2.6,2.6,2.6)+SVertex3fImport(i*NewQ,ii*NewQ,iii*NewQ));
				FThreadsArray[i4].Q:=NewQ;
				FThreadsArray[i4].AllQ:=-5.2;
				i4+=1;
				end;
end;

class function TSFractalMengerSponge.DoOrNotDo(const i,ii,iii:Byte):boolean;inline;
begin
Result:=((i=1) and (ii=1)) or ((i=1) and (iii=1)) or ((ii=1) and (iii=1));
end;

function TSFractalMengerSponge.GetArTP(const OldArTP:TSMengerSpongeBoolAr6;const i,ii,iii: byte;const ThisDepth:LongWord = 0):TSMengerSpongeBoolAr6;inline;
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
		Result:=TSMengerSpongeBoolAr6Null
	else
		begin
		Result:=TSMengerSpongeBoolAr6True;
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

procedure TSFractalMengerSponge.PushIndexes(const i1,i2,i3,i4:TSVertex3f;const ai:longword;const AllQ:real;var ObjectId:LongWord;var FVertexIndex,FFaceIndex:LongWord);inline;
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

AfterPushIndexes(ObjectId,DoAtThreads,FVertexIndex,FFaceIndex);
end;

end.
