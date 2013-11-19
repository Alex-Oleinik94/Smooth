{$i Includes\SaGe.inc}
unit SaGeFractals;
interface
uses 
	crt
	,SaGeCommon
	,SaGeContext
	,SaGeBase
	,SaGeBased
	,Classes
	,SysUtils
	,SaGeMesh
	,SaGeScreen
	,SaGeUtils
	,SaGeImages
	,SaGeImagesBase
	,SaGeRender
	;
type
	TSGFractal = class;
	
	TSGFractalData = class
			public
		constructor Create(const Fractal:TSGFractal; const ThreadID:LongWord);
			public
		FThreadID:LongWord;
		FFractal:TSGFractal;
		end;
	
	TSGFractal = class(TSGDrawClass)
			public
		constructor Create(const VContext:PSGContext);override;
		destructor Destroy;override;
		class function ClassName:string;override;
			public
		FDepth:LongInt;
		
		FThreadsEnable:Boolean;
		
		FThreadsData:packed array of 
			packed record
				FFinished:Boolean;
				FData:TSGFractalData;
				FThread:TSGThread;
				end;
		
			public
		function ThreadsReady:Boolean;virtual;
		procedure Calculate;virtual;
		procedure Draw;override;
		procedure CreateThreads(const a:Byte);virtual;
		procedure ThreadsBoolean(const b:boolean = false);virtual;
		procedure DestroyThreads;virtual;
		procedure AfterCalculate;virtual;
		procedure BeginCalculate;virtual;
		procedure SetThreadsQuantity(NewQuantity:LongWord);
		function GetThreadsQuantity():LongWord;inline;
			public
		property Depth:LongInt read FDepth write FDepth;
		property ThreadsEnable:Boolean read FThreadsEnable write FThreadsEnable;
		property Threads:LongWord read GetThreadsQuantity write SetThreadsQuantity;
		end;
	SGFractal = TSGFractal;
	
	TSG3DFractal=class (TSGFractal)
			public
		constructor Create(const VContext:PSGContext);override;
		destructor Destroy();override;
		class function ClassName():string;override;
			public
		FMesh:TSGModel;
		FMeshesInfo:packed array of TSGBoolean;
		FMeshesReady:Boolean;
		FShift:int64;
		
		FSun:TSGVertex;
		FSunAbs:real;
		FSunTrigonometry:packed array[0..2] of real;
		FLightingEnable:Boolean;
		FIdentityObject:SGIdentityObject;
		FMatrixType:SGByte;
		
		FEnableVBO:Boolean;
		FEnableColors:boolean;
		FEnableNormals:Boolean;
		
			public
		procedure Draw();override;
		procedure Calculate();override;
		procedure SetMeshArLength(const MID,LFaces,LVertexes:int64);inline;
		procedure CalculateMeshes(Quantity:Int64;const PoligoneType:LongWord;const VVertexType:TSGMeshVertexType = TSGMeshVertexType3f);
		procedure ClearMesh();inline;
		procedure AfterPushIndexes(var MeshID:LongWord;const DoAtThreads:Boolean;var FVertexIndex,FFaceIndex:LongWord);inline;
			public
		property LightingEnable:Boolean read FLightingEnable write FLightingEnable;
			public
		FProjectionComboBox:TSGComboBox;
			public
		procedure InitProjectionComboBox(const a,b,c,d:LongWord;const Anch:SGSetOfByte = [];const ATS:Boolean = True);
		end;
	TSGFractal3D=TSG3DFractal;
	
	TSGImageFractal=class(TSGFractal)
			public
		constructor Create(const VContext:PSGContext);override;
			public
		FImage:TSGGLImage;
		FView:TSGScreenVertexes;
		FDepthHeight:LongWord;
		procedure InitColor(const x,y:LongInt;const RecNumber:LongInt);virtual;
		class function GetColor(const a,b,color:LongInt):byte;inline;
		class function GetColorOne(const a,b,color:LongInt):byte;inline;
		procedure ToTexture();virtual;
		procedure BeginCalculate();override;
		class function ClassName():string;override;
		property Width:LongInt read FDepth write FDepth;
		property Height:LongWord read FDepthHeight write FDepthHeight;
		end;

{$DEFINE SGREADINTERFACE}
{$i Includes\SaGeFractalMengerSpunch.inc}
{$i Includes\SaGeFractalMandelbrod.inc}
{$i Includes\SaGeFractalKohTriangle.inc}
{$i Includes\SaGeFractalPodkova.inc}
{$i Includes\SaGeFractalLomanaya.inc}
{$i Includes\SageFractalTetraider.inc}
{$UNDEF SGREADINTERFACE}

implementation

{$DEFINE SGREADIMPLEMENTATION}
{$i Includes\SaGeFractalMengerSpunch.inc}
{$i Includes\SaGeFractalMandelbrod.inc}
{$i Includes\SaGeFractalKohTriangle.inc}
{$i Includes\SaGeFractalPodkova.inc}
{$i Includes\SaGeFractalLomanaya.inc}
{$i Includes\SageFractalTetraider.inc}
{$UNDEF SGREADIMPLEMENTATION}

procedure TSG3DFractal.Calculate();
begin
inherited;
if FEnableVBO then
	FMeshesReady:=False;
end;

class function TSGFractal.ClassName:string;
begin
Result:='SaGe Fractal';
end;

class function TSG3DFractal.ClassName:string;
begin
Result:='SaGe 3D Fractal ';
end;

class function TSGImageFractal.ClassName:string;
begin
Result:='SaGe Image Fractal';
end;

procedure mmmComboBoxProjProc(a,b:LongInt;VComboBox:TSGComboBox);
begin
with TSG3DFractal(VComboBox.FUserPointer1) do
	begin
	case b of
	0:FMatrixType:=SG_3D;
	1:FMatrixType:=SG_3D_ORTHO;
	end;
	end;
end;

procedure TSG3DFractal.InitProjectionComboBox(const a,b,c,d:LongWord;const Anch:SGSetOfByte = [];const ATS:Boolean = True);
begin
if FProjectionComboBox<>nil then
	Exit;
FProjectionComboBox:=TSGComboBox.Create;
SGScreen.CreateChild(FProjectionComboBox);
SGScreen.LastChild.SetBounds(a,b,c,d);
SGScreen.LastChild.AutoTopShift:=ATS;
SGScreen.LastChild.Anchors:=Anch;
SGScreen.LastChild.AsComboBox.CreateItem('Перспектива');
SGScreen.LastChild.AsComboBox.CreateItem('Ортогонал');
SGScreen.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@mmmComboBoxProjProc);
SGScreen.LastChild.AsComboBox.FSelectItem:=0;
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;
end;

procedure TSG3DFractal.ClearMesh;inline;
var
	i:LongWord;
begin
if FMesh=nil then
	begin
	FMesh:=TSGModel.Create;
	FMesh.SetContext(FContext);
	end
else
	if FMesh.NOfObjects>0 then
		begin
		SetLength(FMeshesInfo,0);
		for i:=0 to FMesh.NOfObjects-1 do
			FMesh.ArObjects[i].Destroy;
		SetLEngth(FMesh.ArObjects,0);
		FMesh.NOfObjects:=0;
		end;
end;

procedure TSG3DFractal.AfterPushIndexes(var MeshID:LongWord;const DoAtThreads:Boolean;var FVertexIndex,FFaceIndex:LongWord);inline;
begin
if FFaceIndex>=FShift then
	begin
	if (not DoAtThreads) and FEnableVBO then
		begin
		FMesh.ArObjects[MeshID].LoadToVBO;
		end;
	if FThreadsEnable and (MeshID>=0) and (MeshID<=FMesh.NOfObjects-1) and (FMeshesInfo[MeshID]=SG_FALSE) then
		FMeshesInfo[MeshID]:=SG_TRUE;
	MeshID+=1;
	FVertexIndex:=0;
	FFaceIndex:=0;
	if FEnableVBO and ((MeshID>=0) and (MeshID<=FMesh.NOfObjects-1)) and (FMeshesInfo[MeshID]=SG_FALSE) and (FMesh.ArObjects[MeshID].QuantityVertexes=0) then
		begin
		{if DoAtThreads then
			begin
			while not b do
				begin
				b:=True;
				try
				while FMesh.RealSize>1024*1024*256 do
					Delay(1);
				except 
					B:=False;
					end;
				end;
			end;}
		SetMeshArLength(MeshID,FShift,FMesh.ArObjects[MeshID].GetFaceLength(FShift));
		end;
	end;
end;

procedure TSG3DFractal.CalculateMeshes(Quantity:Int64;const PoligoneType:LongWord;const VVertexType:TSGMeshVertexType = TSGMeshVertexType3f);
begin
while Quantity<>0 do
	begin
	SetLength(FMeshesInfo,Length(FMeshesInfo)+1);
	FMeshesInfo[High(FMeshesInfo)]:=SG_FALSE;
	SetLength(FMesh.ArObjects,FMesh.NOfObjects+1);
	FMesh.NOfObjects+=1;
	FMesh.ArObjects[FMesh.NOfObjects-1]:=TSG3DObject.Create;
	FMesh.ArObjects[FMesh.NOfObjects-1].SetContext(FContext);
	FMesh.ArObjects[FMesh.NOfObjects-1].FObjectColor:=SGGetColor4fFromLongWord($FF8000);
	FMesh.ArObjects[FMesh.NOfObjects-1].FEnableCullFace:=False;
	if (PoligoneType=SGR_QUADS) and (Render.RenderType=SGRenderDirectX) then
		FMesh.ArObjects[FMesh.NOfObjects-1].PoligonesType:=SGR_TRIANGLES
	else
		FMesh.ArObjects[FMesh.NOfObjects-1].PoligonesType:=PoligoneType;
	FMesh.ArObjects[FMesh.NOfObjects-1].VertexType:=VVertexType;
	if FEnableColors then
		FMesh.ArObjects[FMesh.NOfObjects-1].AutoSetColorType();
	if FEnableNormals then
		FMesh.ArObjects[FMesh.NOfObjects-1].HasNormals:=True;
	if Quantity<=FShift then
		begin
		if (PoligoneType=SGR_QUADS) and (Render.RenderType=SGRenderDirectX) then
			SetMeshArLength(FMesh.NOfObjects-1,Quantity*2,
				TSG3DObject.GetFaceLength(Quantity,SGR_QUADS))
		else
			SetMeshArLength(FMesh.NOfObjects-1,Quantity,
				TSG3DObject.GetFaceLength(Quantity,FMesh.ArObjects[FMesh.NOfObjects-1].PoligonesType));
		Quantity:=0;
		end
	else
		begin
		if (PoligoneType=SGR_QUADS) and (Render.RenderType=SGRenderDirectX) then
			SetMeshArLength(FMesh.NOfObjects-1,FShift*2,
				TSG3DObject.GetFaceLength(FShift,SGR_QUADS))
		else
			SetMeshArLength(FMesh.NOfObjects-1,FShift,
				TSG3DObject.GetFaceLength(FShift,FMesh.ArObjects[FMesh.NOfObjects-1].PoligonesType));
		Quantity-=FShift;
		end;
	end;
end;

procedure TSG3DFractal.SetMeshArLength(const MID,LFaces,LVertexes:int64);inline;
begin
FMesh.ArObjects[MID].SetFaceLength(LFaces);
FMesh.ArObjects[MID].SetVertexLength(LVertexes);
end;

constructor TSGFractalData.Create(const Fractal:TSGFractal; const ThreadID:LongWord);
begin
inherited Create();
FFractal:=Fractal;
FThreadID:=ThreadID;
end;

constructor TSG3DFractal.Create(const VContext:PSGContext);
begin
inherited Create(VContext);
FSunAbs:=10;
FSun.Import(0,0,-FSunAbs);
FSunTrigonometry[0]:=pi/2;
FSunTrigonometry[1]:=0;
FSunTrigonometry[2]:=pi+pi;
FLightingEnable:=True;
FMesh:=nil;
FEnableVBO:=Render.SupporedVBOBuffers();

//Размерность максимального сегмента данных мешей модели
FShift:=4608*2;
// 2 2 2 2 2 2 2 2 2 3 3 73
///336384; - былоа до того как я изметил тип индексов на word (норм для лонгворд)

FMeshesInfo:=nil;
FMeshesReady:=True;
FEnableColors:=True;
FEnableNormals:=True;
FIdentityObject.Clear;
FIdentityObject.Render:=Render;
FIdentityObject.Context:=FContext;
FMatrixType:=SG_3D;
end;

destructor TSG3DFractal.Destroy();
begin
if FProjectionComboBox<>nil then
	FProjectionComboBox.Destroy();
if FMesh<>nil then 
	FMesh.Destroy;
SetLength(FMeshesInfo,0);
inherited Destroy();
end;

procedure TSG3DFractal.Draw();
var
	i,ii:LongInt;
begin
{$IFDEF SGMoreDebuging}
	WriteLn('Begin of  "TSGFractal.Draw" : "'+ClassName+'"');
	WriteLn('Var: FMeshesReady=',FMeshesReady,'; FEnableVBO=',FEnableVBO,' .');
	{$ENDIF}
FIdentityObject.Go(FMatrixType);
if (Not FMeshesReady) and FThreadsEnable and FEnableVBO then
	begin
	ii:=1;
	for i:=0 to High(FMeshesInfo) do
		if FMeshesInfo[i]=SG_TRUE then
			begin
			FMeshesInfo[i]:=SG_UNKNOWN;
			FMesh.ArObjects[i].LoadToVBO();
			end
		else
			if FMeshesInfo[i]=SG_FALSE then
				ii:=0;
	if ii=1 then
		begin 
		FMeshesReady:=True;
		end;
	end
else
	if (Not FMeshesReady) and FThreadsEnable and (not FEnableVBO) then
		begin
		ii:=1;
		for i:=0 to High(FMeshesInfo) do
			if FMeshesInfo[i]<>SG_TRUE then
				begin
				ii:=0;
				Break;
				end;
		if ii=1 then
			FMeshesReady:=True;
		end;
if FLightingEnable then
	begin
	FSunTrigonometry[0]+=pi/90		/20*Context.ElapsedTime;
	FSunTrigonometry[1]-=pi/60		/20*Context.ElapsedTime;
	FSunTrigonometry[2]+=pi/180		/20*Context.ElapsedTime;
	FSun.Import(cos(FSunTrigonometry[0]),sin(FSunTrigonometry[1]),cos(FSunTrigonometry[2]));
	FSun*=FSunAbs;
	Render.Color3f(1,1,1);
	Render.BeginScene(SGR_POINTS);
	FSun.Vertex(Render);
	Render.EndScene();
	Render.Enable(SGR_LIGHTING);
	Render.Enable(SGR_LIGHT0);
	FSun.LightPosition(Render);
	end
else
	if Render.IsEnabled(SGR_LIGHTING) then
		Render.Disable(SGR_LIGHTING);
if FEnableVBO then
	begin
	if (FMesh<>nil) and (FMesh.NOfObjects<>0) then
	for i:=0 to FMesh.NOfObjects-1 do
		begin
		if FMesh.ArObjects[i].FEnableVBO then
			FMesh.ArObjects[i].Draw;
		{$IFDEF SGMoreDebuging}
			WriteLn('FMesh.ArObjects[',i,'].FEnableVBO=',FMesh.ArObjects[i].FEnableVBO);
			{$ENDIF}
		end;
	end
else
	if FMesh<>nil then
		begin
		FMesh.Draw();
		end;
if FLightingEnable then
	begin
	Render.Disable(SGR_LIGHT0);
	Render.Disable(SGR_LIGHTING);
	end;
{$IFDEF SGMoreDebuging}
	WriteLn('End of  "TSGFractal.Draw" : "'+ClassName+'"');
	{$ENDIF}
end;

procedure TSGFractal.AfterCalculate; 
begin 
end;

procedure TSGFractal.BeginCalculate; 
begin 
end;

procedure TSGFractal.DestroyThreads;
var
	i:LongInt;
begin
for i:=0 to High(FThreadsData) do
	begin
	if FThreadsData[i].FData<>nil then
		FThreadsData[i].FData.Destroy;
	if FThreadsData[i].FThread<>nil then
		FThreadsData[i].FThread.Destroy;
	end;
SetLength(FThreadsData,0);
FThreadsData:=nil;
end;

procedure TSGFractal.ThreadsBoolean(const b:boolean = false);
var
	i:LongInt;
begin
for i:=0 to High(FThreadsData) do
	begin
	FThreadsData[i].FFinished:=b;
	if FThreadsData[i].FData<>nil then
		begin
		FThreadsData[i].FData.Destroy;
		FThreadsData[i].FData:=Nil;
		end;
	FThreadsData[i].FFinished:=b;
	end;
end;

function TSGFractal.ThreadsReady:Boolean;
var
	i:LongInt;
begin
Result:=True;
for i:=0 to High(FThreadsData) do
	if FThreadsData[i].FFinished=False then
		begin
		Result:=False;
		Break;
		end;
end;

procedure TSGFractal.CreateThreads(const a:Byte);
var
	i:LongInt;
begin
SetLEngth(FThreadsData,a);
for i:=0 to High(FThreadsData) do
	FThreadsData[i].FData:=nil;
ThreadsBoolean(False);
end;

class function TSGImageFractal.GetColorOne(const a,b,color:LongInt):byte;inline;
begin
if Color>b then
	Result:=255
else
	if Color<a then
		Result:=0
	else
		Result:=Trunc(((b-a)/(color-a))*255);
end;


constructor TSGImageFractal.Create(const VContext:PSGContext);
begin
inherited Create(VContext);
FDepthHeight:=0;
FImage:=nil;
end;


procedure TSGImageFractal.BeginCalculate;
begin
inherited;
if FImage=nil then
	FImage:=TSGGLImage.Create
else
	FImage.FreeAll;
FImage.SetContext(FContext);
FImage.FImage.Clear;
FImage.Width:=FDepth;
FImage.Height:=FDepth*Byte(FDepthHeight=0)+FDepthHeight;
GetMem(FImage.FImage.FBitMap,FImage.Width*FImage.Height*3);
FImage.FImage.FChannels:=3;
FImage.FImage.FSizeChannel:=8;
FImage.FImage.CreateTypes;
end;

procedure TSGImageFractal.ToTexture;
begin
FImage.ToTexture;
ThreadsBoolean(False);
end;

class function TSGImageFractal.GetColor(const a,b,color:LongInt):byte;inline;
var
	SR:byte;
begin
Result:=0;
if (color>=a) and (color<=b) then
	begin
	sr:=round((a+b)/2);
	if color<sr then
		Result:=round((color-a)/(sr-a)*255)
	else
		Result:=round((b-color)/(b-sr)*255);
	end;
end;

procedure TSGImageFractal.InitColor(const x,y:LongInt;const RecNumber:LongInt);inline;
begin
FImage.FImage.FBitMap[((FDepth-Y)*FDepth+X)*3]:=trunc((RecNumber/15)*255);
end;

procedure TSGFractal.Draw;
begin
Render.Color3f(1,1,1);
end;

procedure TSGFractal.Calculate;
begin
end;

procedure TSGFractal.SetThreadsQuantity(NewQuantity:LongWord);inline;
begin
SetLength(FThreadsData,NewQuantity);
FThreadsEnable:=NewQuantity>0;
end;

function TSGFractal.GetThreadsQuantity():LongWord;inline;
begin
Result:=Length(FThreadsData);
end;

constructor TSGFractal.Create(const VContext:PSGContext);
begin
inherited Create(VContext);
FDepth:=3;
FThreadsEnable:=False;
FThreadsData:=nil;
end;

destructor TSGFractal.Destroy;
begin
DestroyThreads;
inherited;
end;

end.
