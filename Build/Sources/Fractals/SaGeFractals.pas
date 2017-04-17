{$INCLUDE SaGe.inc}

unit SaGeFractals;

interface

uses 
	 Crt
	,Classes
	,SysUtils
	
	,SaGeBase
	,SaGeCommon
	,SaGeCommonStructs
	,SaGeContext
	,SaGeMesh
	,SaGeVertexObject
	,SaGeScreen
	,SaGeFont
	,SaGeImage
	,SaGeBitMap
	,SaGeRender
	,SaGeRenderBase
	,SaGeCommonClasses
	,SaGeScreenBase
	,SaGeThreads
	,SaGeCamera
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
	
	TSGFractal = class(TSGScreenedDrawable)
			public
		constructor Create(const VContext : ISGContext);override;
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
		procedure Paint();override;
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
	
	TSG3DFractal=class (TSGFractal)
			public
		constructor Create(const VContext:ISGContext);override;
		destructor Destroy();override;
		class function ClassName():string;override;
			protected
		FMesh        : TSGCustomModel;
		FMeshesInfo  : packed array of TSGByte;
		FMeshesReady : TSGBoolean;
		FShift       : TSGInt64;
		
		FSun              : TSGVertex3f;
		FSunAbs           : TSGSingle;
		FSunTrigonometry  : packed array[0..2] of TSGSingle;
		FLightingEnable   : TSGBoolean;
		FCamera           : TSGCamera;
		
		FEnableVBO      : TSGBoolean;
		FEnableColors   : TSGBoolean;
		FEnableNormals  : TSGBoolean;
		FHasIndexes     : TSGBoolean;
			public
		procedure DeleteDeviceResources();override;
		procedure LoadDeviceResources();override;
		procedure Paint();override;
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
		procedure InitProjectionComboBox(const a,b,c,d:LongWord;const Anch:TSGSetOfByte = []);
		procedure InitEffectsComboBox(const a,b,c,d:LongWord;const Anch:TSGSetOfByte = []);
		procedure InitSizeLabel(const a,b,c,d:LongWord;const Anch:TSGSetOfByte = []);
		end;
	TSGFractal3D=TSG3DFractal;
	
	TSGImageFractal=class(TSGFractal)
			public
		constructor Create(const VContext:ISGContext);override;
		class function ClassName():string;override;
			protected
		FImage:TSGImage;
		FView:TSGScreenVertexes;
		FDepthHeight:LongWord;
			public
		procedure InitColor(const x,y:LongInt;const RecNumber:LongInt);virtual;
		class function GetColor(const a,b,color:LongInt):byte;inline;
		class function GetColorOne(const a,b,color:LongInt):byte;inline;
		procedure ToTexture();virtual;
		procedure BeginCalculate();override;
			public
		property Width:LongInt read FDepth write FDepth;
		property Height:LongWord read FDepthHeight write FDepthHeight;
		end;


implementation

uses
	 SaGeStringUtils
	;

procedure TSG3DFractal.DeleteDeviceResources();
begin
ClearMesh();
end;

procedure TSG3DFractal.LoadDeviceResources();
begin
Calculate();
end;

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

procedure TSG3DFractal.InitSizeLabel(const a,b,c,d:LongWord;const Anch:TSGSetOfByte = []);
begin
FSizeLabel:=TSGLabel.Create;
Screen.CreateChild(FSizeLabel);
Screen.LastChild.SetBounds(a,b,c,d);
Screen.LastChild.Anchors:=Anch;
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
FSizeLabel.TextPosition:=False;
end;

procedure TSG3DFractal.InitEffectsComboBox(const a,b,c,d:LongWord;const Anch:TSGSetOfByte = []);
begin
FEffectsComboBox:=TSGComboBox.Create;
Screen.CreateChild(FEffectsComboBox);
Screen.LastChild.SetBounds(a,b,c,d);
Screen.LastChild.Anchors:=Anch;
Screen.LastChild.AsComboBox.CreateItem('������� � �����');
Screen.LastChild.AsComboBox.CreateItem('������ �������');
Screen.LastChild.AsComboBox.CreateItem('������ �����');
Screen.LastChild.AsComboBox.CreateItem('������ ����');
Screen.LastChild.AsComboBox.CallBackProcedure:=TSGComboBoxProcedure(@mmmComboBoxEffProc);
Screen.LastChild.AsComboBox.SelectItem:=0;
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
end;

procedure TSG3DFractal.InitProjectionComboBox(const a,b,c,d:LongWord;const Anch:TSGSetOfByte = []);
begin
if FProjectionComboBox<>nil then
	Exit;
FProjectionComboBox:=TSGComboBox.Create;
Screen.CreateChild(FProjectionComboBox);
Screen.LastChild.SetBounds(a,b,c,d);
Screen.LastChild.Anchors:=Anch;
Screen.LastChild.AsComboBox.CreateItem('�����������');
Screen.LastChild.AsComboBox.CreateItem('���������');
Screen.LastChild.AsComboBox.CallBackProcedure:=TSGComboBoxProcedure(@mmmComboBoxProjProc);
Screen.LastChild.AsComboBox.SelectItem:=0;
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
end;

procedure TSG3DFractal.ClearMesh;inline;
begin
SetLength(FMeshesInfo, 0);
FMeshesReady := False;
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
if (Render = nil) or (Render.RenderType in [SGRenderDirectX9,SGRenderDirectX8]) then
	FShift := 4608*2
else
	FShift:=336384;
while Quantity<>0 do
	begin
	SetLength(FMeshesInfo,Length(FMeshesInfo)+1);
	FMeshesInfo[High(FMeshesInfo)]:=SG_FALSE;
	FMesh.AddObject();
	FMesh.LastObject().ObjectColor:=SGColor4fFromUInt32($FFFFFF);
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

constructor TSG3DFractal.Create(const VContext : ISGContext);
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
if (Render = nil) or (Render.RenderType in [SGRenderDirectX9,SGRenderDirectX8]) then
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

procedure TSG3DFractal.Paint();
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
	Render.Vertex(FSun);
	Render.EndScene();
	Render.Enable(SGR_LIGHTING);
	Render.Enable(SGR_LIGHT0);
	Render.LightPosition(FSun);
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
			FMesh.Objects[i].Paint();
		{$IFDEF SGMoreDebuging}
			WriteLn('FMesh.ArObjects[',i,'].FEnableVBO=',FMesh.Objects[i].EnableVBO);
			{$ENDIF}
		end;
	end
else
	if FMesh<>nil then
		begin
		FMesh.Paint();
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
			'��������... (NOfObjects='+SGStr(FMesh.QuantityObjects)+';Threads='+SGStr(Threads)
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

// $RANGECHECKS
{$IFOPT R+}
	{$DEFINE RANGECHECKS_OFFED}
	{$R-}
	{$ENDIF}

class function TSGImageFractal.GetColorOne(const a,b,color:LongInt):byte;inline;
var
	OutPut : TSGMaxEnum;
begin
if Color>=b then
	Result:=255
else
	if Color<=a then
		Result:=0
	else
		begin
		if color-a = 0 then
			Result := 0
		else
			begin
			OutPut := Trunc(((b-a)/(color-a))*255);
			if OutPut > 255 then
				Result := OutPut mod 256
			else
				Result := OutPut;
			end;
		end;
end;

{$IFDEF RANGECHECKS_OFFED}
	{$R+}
	{$UNDEFINE RANGECHECKS_OFFED}
	{$ENDIF}

constructor TSGImageFractal.Create(const VContext : ISGContext);
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
FImage.FImage.Channels:=3;
FImage.FImage.SizeChannel:=8;
FImage.FImage.ReAllocateMemory();
FImage.FImage.CreateTypes();
end;

procedure TSGImageFractal.ToTexture;
begin
FImage.ToTexture;
ThreadsBoolean(False);
end;

// $RANGECHECKS
{$IFOPT R+}
	{$DEFINE RANGECHECKS_OFFED}
	{$R-}
	{$ENDIF}

class function TSGImageFractal.GetColor(const a, b, Color : TSGLongInt) : TSGByte;inline;
var
	Middle, OutPut : TSGWord;
begin
Result:=0;
if (color>=a) and (color<=b) then
	begin
	Middle := round((a+b)/2);
	if color < Middle then
		OutPut := round((color - a) / (Middle - a) * 255)
	else
		OutPut := round((b - color) / (b - Middle) * 255);
	if OutPut > 255 then
		Result := OutPut mod 256
	else
		Result := OutPut;
	end;
end;

{$IFDEF RANGECHECKS_OFFED}
	{$R+}
	{$UNDEFINE RANGECHECKS_OFFED}
	{$ENDIF}

procedure TSGImageFractal.InitColor(const x,y:LongInt;const RecNumber:LongInt);inline;
begin
FImage.FImage.BitMap[((FDepth-Y)*FDepth+X)*3]:=trunc((RecNumber/15)*255);
end;

procedure TSGFractal.Paint();
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

constructor TSGFractal.Create(const VContext : ISGContext);
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