{$INCLUDE Includes\SaGe.inc}
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
	,SaGeTotal
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
		constructor Create(const VContext:TSGContext);override;
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
		function ThreadsReady():Boolean;virtual;
		procedure Calculate();virtual;
		procedure Draw();override;
		procedure CreateThreads(const a:Byte);virtual;
		procedure ThreadsBoolean(const b:boolean = false);virtual;
		procedure DestroyThreads();virtual;
		procedure AfterCalculate();virtual;
		procedure BeginCalculate();virtual;
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
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		class function ClassName():string;override;
			protected
		FMesh        : TSGCustomModel;
		FMeshesInfo  : packed array of TSGExBoolean;
		FMeshesReady : TSGBoolean;
		FShift       : TSGInt64;
		
		FSun              : TSGVertex;
		FSunAbs           : TSGSingle;
		FSunTrigonometry  : packed array[0..2] of TSGSingle;
		FLightingEnable   : TSGBoolean;
		FCamera           : TSGCamera;
		
		FEnableVBO      : TSGBoolean;
		FEnableColors   : TSGBoolean;
		FEnableNormals  : TSGBoolean;
		FHasIndexes     : TSGBoolean;
			public
		procedure Draw();override;
		procedure Calculate();override;
		procedure SetMeshArLength(const MID,LFaces,LVertexes:int64);inline;
		procedure CalculateMeshes(Quantity:Int64;const PoligoneType:LongWord;const VVertexType:TSGMeshVertexType = SGMeshVertexType3f;const VertexMn : TSGByte = 0);
		procedure ClearMesh();inline;
		procedure AfterPushIndexes(var MeshID:LongWord;const DoAtThreads:Boolean;var FVertexIndex,FFaceIndex:LongWord);inline;overload;
		procedure AfterPushIndexes(var MeshID:LongWord;const DoAtThreads:Boolean;var FVertexIndex:LongWord);inline;overload;
			public
		property LightingEnable : TSGBoolean read FLightingEnable write FLightingEnable;
		property HasIndexes     : TSGBoolean read FHasIndexes     write FHasIndexes;
		property EnableVBO      : TSGBoolean read FEnableVBO      write FEnableVBO;
		property EnableNormals  : TSGBoolean read FEnableNormals  write FEnableNormals;
		property EnableColors   : TSGBoolean read FEnableColors   write FEnableColors;
			public
		FProjectionComboBox,FEffectsComboBox:TSGComboBox;
		FSizeLabel:TSGLabel;
		FSizeLabelFlag:Boolean;
			public
		procedure InitProjectionComboBox(const a,b,c,d:LongWord;const Anch:TSGSetOfByte = [];const ATS:Boolean = True);
		procedure InitEffectsComboBox(const a,b,c,d:LongWord;const Anch:TSGSetOfByte = [];const ATS:Boolean = True);
		procedure InitSizeLabel(const a,b,c,d:LongWord;const Anch:TSGSetOfByte = [];const ATS:Boolean = True);
		end;
	TSGFractal3D=TSG3DFractal;
	
	TSGImageFractal=class(TSGFractal)
			public
		constructor Create(const VContext:TSGContext);override;
			public
		FImage:TSGImage;
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

type
	TSGAllFractals = class(TSGDrawClass)
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		class function ClassName():string;override;
			public
		FDrawClasses : TSGDrawClasses;
			public
		procedure Draw();override;
		end;

implementation


constructor TSGAllFractals.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FDrawClasses := TSGDrawClasses.Create(Context);
FDrawClasses.Add(TSGFractalMengerSpunchRelease);
FDrawClasses.Add(TSGFractalMandelbrodRelease);
FDrawClasses.Add(TSGFractalKohTriangle);
FDrawClasses.Add(TSGFractalTetraider);
FDrawClasses.Add(TSGFractalLomanaya);
FDrawClasses.Add(TSGFractalPodkova);
FDrawClasses.Initialize();
FDrawClasses.ComboBox.BoundsToNeedBounds();
FDrawClasses.ComboBox.SetBounds(5,5,SGDrawClassesComboBoxWidth,18);
FDrawClasses.ComboBox.BoundsToNeedBounds();
FDrawClasses.ComboBox.SetBounds(5,28,SGDrawClassesComboBoxWidth,18);
end;

destructor TSGAllFractals.Destroy();
begin
FDrawClasses.Destroy();
FDrawClasses:=nil;
inherited;
end;

class function TSGAllFractals.ClassName():string;
begin
Result := 'Фракталы';
end;

procedure TSGAllFractals.Draw();
begin
if FDrawClasses<>nil then
	FDrawClasses.Draw();
end;

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
FSizeLabelFlag:=False;
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
	0:FCamera.MatrixMode:=SG_3D;
	1:FCamera.MatrixMode:=SG_3D_ORTHO;
	end;
	end;
end;

procedure mmmComboBoxEffProc(a,b:LongInt;VComboBox:TSGComboBox);
begin
with TSG3DFractal(VComboBox.FUserPointer1) do
	begin
	if a<>b then
		begin
		FEnableColors:=(b=2) or (b=0);
		FEnableNormals:=(b=1) or (b=0);
		FLightingEnable:=FEnableNormals;
		Calculate();
		end;
	end;
end;

procedure TSG3DFractal.InitSizeLabel(const a,b,c,d:LongWord;const Anch:TSGSetOfByte = [];const ATS:Boolean = True);
begin
FSizeLabel:=TSGLabel.Create;
SGScreen.CreateChild(FSizeLabel);
SGScreen.LastChild.SetBounds(a,b,c,d);
SGScreen.LastChild.AutoTopShift:=ATS;
SGScreen.LastChild.Anchors:=Anch;
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;
FSizeLabel.FTextPosition:=0;
end;

procedure TSG3DFractal.InitEffectsComboBox(const a,b,c,d:LongWord;const Anch:TSGSetOfByte = [];const ATS:Boolean = True);
begin
FEffectsComboBox:=TSGComboBox.Create;
SGScreen.CreateChild(FEffectsComboBox);
SGScreen.LastChild.SetBounds(a,b,c,d);
SGScreen.LastChild.AutoTopShift:=ATS;
SGScreen.LastChild.Anchors:=Anch;
SGScreen.LastChild.AsComboBox.CreateItem('Нормали и цвета');
SGScreen.LastChild.AsComboBox.CreateItem('Только нормали');
SGScreen.LastChild.AsComboBox.CreateItem('Только цвета');
SGScreen.LastChild.AsComboBox.CreateItem('Ничего нету');
SGScreen.LastChild.AsComboBox.FProcedure:=TSGComboBoxProcedure(@mmmComboBoxEffProc);
SGScreen.LastChild.AsComboBox.FSelectItem:=0;
SGScreen.LastChild.FUserPointer1:=Self;
SGScreen.LastChild.Visible:=True;
end;

procedure TSG3DFractal.InitProjectionComboBox(const a,b,c,d:LongWord;const Anch:TSGSetOfByte = [];const ATS:Boolean = True);
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
	FMesh:=TSGCustomModel.Create();
	FMesh.SetContext(Context);
	end
else
	if FMesh.QuantityObjects>0 then
		begin
		SetLength(FMeshesInfo,0);
		FMesh.Clear();
		end;
end;

procedure TSG3DFractal.AfterPushIndexes(var MeshID:LongWord;const DoAtThreads:Boolean;var FVertexIndex:LongWord);inline;overload;
begin
if ((HasIndexes) and ((FVertexIndex div FMesh.Objects[MeshID].GetPoligoneInt(FMesh.Objects[MeshID].PoligonesType[0]))>=FShift))
or ((not HasIndexes) and ((FVertexIndex div FMesh.Objects[MeshID].GetPoligoneInt(FMesh.Objects[MeshID].ObjectPoligonesType))>=FShift))
 then
	begin
	if (not DoAtThreads) and FEnableVBO then
		begin
		FMesh.Objects[MeshID].LoadToVBO();
		end;
	if FThreadsEnable and (MeshID>=0) and (MeshID<=FMesh.QuantityObjects-1) and (FMeshesInfo[MeshID]=SG_FALSE) then
		FMeshesInfo[MeshID]:=SG_TRUE;
	MeshID+=1;
	FVertexIndex:=0;
	if FEnableVBO and ((MeshID>=0) and (MeshID<=FMesh.QuantityObjects-1)) and (FMeshesInfo[MeshID]=SG_FALSE) and (FMesh.Objects[MeshID].QuantityVertexes=0) then
		begin
		SetMeshArLength(MeshID,FShift,FMesh.Objects[MeshID].GetFaceLength(FShift));
		end;
	end;
end;

procedure TSG3DFractal.AfterPushIndexes(var MeshID:LongWord;const DoAtThreads:Boolean;var FVertexIndex,FFaceIndex:LongWord);inline;overload;
begin
if FFaceIndex>=FShift then
	begin
	if (not DoAtThreads) and FEnableVBO then
		begin
		FMesh.Objects[MeshID].LoadToVBO();
		end;
	if FThreadsEnable and (MeshID>=0) and (MeshID<=FMesh.QuantityObjects-1) and (FMeshesInfo[MeshID]=SG_FALSE) then
		FMeshesInfo[MeshID]:=SG_TRUE;
	MeshID+=1;
	FVertexIndex:=0;
	FFaceIndex:=0;
	if FEnableVBO and ((MeshID>=0) and (MeshID<=FMesh.QuantityObjects-1)) and (FMeshesInfo[MeshID]=SG_FALSE) and (FMesh.Objects[MeshID].QuantityVertexes=0) then
		begin
		SetMeshArLength(MeshID,FShift,FMesh.Objects[MeshID].GetFaceLength(FShift));
		end;
	end;
end;

procedure TSG3DFractal.CalculateMeshes(Quantity:Int64;const PoligoneType:LongWord;const VVertexType:TSGMeshVertexType = SGMeshVertexType3f;const VertexMn : TSGByte = 0);
begin
if (Render = nil) or (Render.RenderType = SGRenderDirectX) then
	FShift := 4608*2
else
	FShift:=336384;
while Quantity<>0 do
	begin
	SetLength(FMeshesInfo,Length(FMeshesInfo)+1);
	FMeshesInfo[High(FMeshesInfo)]:=SG_FALSE;
	FMesh.AddObject();
	FMesh.LastObject().ObjectColor:=SGGetColor4fFromLongWord($FFFFFF);
	FMesh.LastObject().EnableCullFace:=False;
	if (PoligoneType=SGR_QUADS) and (Render.RenderType<>SGRenderOpenGL) then
		FMesh.LastObject().ObjectPoligonesType:=SGR_TRIANGLES
	else
		FMesh.LastObject().ObjectPoligonesType:=PoligoneType;
	FMesh.LastObject().VertexType:=VVertexType;
	if FEnableColors then
		FMesh.LastObject().AutoSetColorType();
	if FEnableNormals then
		FMesh.LastObject().HasNormals:=True;
	FMesh.LastObject().QuantityFaceArrays := Byte(FHasIndexes);
	if FHasIndexes then
		begin
		FMesh.LastObject().PoligonesType[0]:=FMesh.LastObject().ObjectPoligonesType;
		end;
	if Quantity<=FShift then
		begin
		if (PoligoneType=SGR_QUADS) and (Render.RenderType<>SGRenderOpenGL) then
			if VertexMn = 0 then
				SetMeshArLength(FMesh.QuantityObjects-1,Quantity*2,
					TSG3DObject.GetFaceLength(Quantity,SGR_QUADS))
			else
				SetMeshArLength(FMesh.QuantityObjects-1,Quantity*2,
					Quantity*VertexMn)
		else
			if VertexMn = 0 then
				SetMeshArLength(FMesh.QuantityObjects-1,Quantity,
					TSG3DObject.GetFaceLength(Quantity,FMesh.Objects[FMesh.QuantityObjects-1].ObjectPoligonesType))
			else
				SetMeshArLength(FMesh.QuantityObjects-1,Quantity,
					Quantity*VertexMn);
		Quantity:=0;
		end
	else
		begin
		if (PoligoneType=SGR_QUADS) and (Render.RenderType<>SGRenderOpenGL) then
			if VertexMn = 0 then
				SetMeshArLength(FMesh.QuantityObjects-1,FShift*2,
					TSG3DObject.GetFaceLength(FShift,SGR_QUADS))
			else
				SetMeshArLength(FMesh.QuantityObjects-1,FShift*2,
					FShift*VertexMn)
		else
			if VertexMn = 0 then
				SetMeshArLength(FMesh.QuantityObjects-1,FShift,
					TSG3DObject.GetFaceLength(FShift,FMesh.Objects[FMesh.QuantityObjects-1].ObjectPoligonesType))
			else
				SetMeshArLength(FMesh.QuantityObjects-1,FShift,
					FShift*VertexMn);
		Quantity-=FShift;
		end;
	end;
end;

procedure TSG3DFractal.SetMeshArLength(const MID,LFaces,LVertexes:int64);inline;
begin
if FHasIndexes then
	begin
	FMesh.Objects[MID].AutoSetIndexFormat(0,LVertexes);
	FMesh.Objects[MID].SetFaceLength(0,LFaces);
	end;
FMesh.Objects[MID].SetVertexLength(LVertexes);
end;

constructor TSGFractalData.Create(const Fractal:TSGFractal; const ThreadID:LongWord);
begin
inherited Create();
FFractal:=Fractal;
FThreadID:=ThreadID;
end;

constructor TSG3DFractal.Create(const VContext:TSGContext);
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
FHasIndexes:=True;
if (Render = nil) or (Render.RenderType = SGRenderDirectX) then
	FShift := 4608*2
else
	FShift:=336384;
FMeshesInfo:=nil;
FMeshesReady:=True;
FEnableColors:=True;
FEnableNormals:=True;
FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
FCamera.MatrixMode:=SG_3D;
FProjectionComboBox:=nil;
FSizeLabel:=nil;
FEffectsComboBox:=Nil;
FSizeLabelFlag:=False;
end;

destructor TSG3DFractal.Destroy();
begin
if FCamera<>nil then
	FCamera.Destroy();
if FSizeLabel<>nil then
	FSizeLabel.Destroy();
if FProjectionComboBox<>nil then
	FProjectionComboBox.Destroy();
if FEffectsComboBox<>nil then
	FEffectsComboBox.Destroy();
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
FCamera.CallAction();
if (Not FMeshesReady) and FThreadsEnable and FEnableVBO then
	begin
	ii:=1;
	for i:=0 to High(FMeshesInfo) do
		if FMeshesInfo[i]=SG_TRUE then
			begin
			FMeshesInfo[i]:=SG_UNKNOWN;
			FMesh.Objects[i].LoadToVBO();
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
Render.Color4f(1,1,1,1);
Render.LineWidth(1);
if FEnableVBO then
	begin
	if (FMesh<>nil) and (FMesh.QuantityObjects<>0) then
	for i:=0 to FMesh.QuantityObjects-1 do
		begin
		if FMesh.Objects[i].EnableVBO then
			FMesh.Objects[i].Draw();
		{$IFDEF SGMoreDebuging}
			WriteLn('FMesh.ArObjects[',i,'].FEnableVBO=',FMesh.Objects[i].EnableVBO);
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
if (FSizeLabel<>nil) and (not FSizeLabelFlag)  and (FMesh<>nil) then
	if (not ((FThreadsEnable))) or (((FThreadsEnable)) and FMeshesReady) then
		begin
		if HasIndexes then
			FSizeLabel.Caption:=(
				'Size : All: '+SGGetSizeString(FMesh.Size)+
				' ;Face: '+SGGetSizeString(FMesh.FacesSize)+
				' ;Vert: '+SGGetSizeString(FMesh.VertexesSize)+
				' ;LenArObj: '+SGStr(FMesh.QuantityObjects)+'.'
				)
		else
			FSizeLabel.Caption:=(
				'Size : Vert: '+SGGetSizeString(FMesh.VertexesSize)+
				' ;LenArObj: '+SGStr(FMesh.QuantityObjects)+'.'
				);
		FSizeLabelFlag:=True;
		end
	else
		begin
		FSizeLabel.Caption:=SGStringToPChar(
			'Загрузка... (NOfObjects='+SGStr(FMesh.QuantityObjects)+';Threads='+SGStr(Threads)
			);
		FSizeLabel.Caption:=FSizeLabel.Caption+')';
		end;
{$IFDEF SGMoreDebuging}
	WriteLn('End of  "TSGFractal.Draw" : "'+ClassName+'"');
	{$ENDIF}
end;

procedure TSGFractal.AfterCalculate; 
begin 
end;

procedure TSGFractal.BeginCalculate(); 
begin 
end;

procedure TSGFractal.DestroyThreads();
var
	i:LongInt;
begin
for i:=0 to High(FThreadsData) do
	begin
	if FThreadsData[i].FData<>nil then
		begin
		FThreadsData[i].FData.Destroy();
		FThreadsData[i].FData:=nil;
		end;
	if FThreadsData[i].FThread<>nil then
		begin
		FThreadsData[i].FThread.Destroy();
		FThreadsData[i].FThread:=nil;
		end;
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


constructor TSGImageFractal.Create(const VContext:TSGContext);
begin
inherited Create(VContext);
FDepthHeight:=0;
FImage:=nil;
end;


procedure TSGImageFractal.BeginCalculate;
begin
inherited;
if FImage=nil then
	FImage:=TSGImage.Create
else
	FImage.FreeAll;
FImage.SetContext(Context);
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

constructor TSGFractal.Create(const VContext:TSGContext);
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
