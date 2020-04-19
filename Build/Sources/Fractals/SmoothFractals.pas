{$INCLUDE Smooth.inc}

unit SmoothFractals;

interface

uses 
	 Classes
	,SysUtils
	
	,SmoothBase
	,SmoothCommon
	,SmoothCommonStructs
	,SmoothContext
	,Smooth3dObject
	,SmoothVertexObject
	,SmoothFont
	,SmoothImage
	,SmoothBitMap
	,SmoothRender
	,SmoothRenderBase
	,SmoothContextClasses
	,SmoothScreenBase
	,SmoothThreads
	,SmoothCamera
	,SmoothScreenClasses
	;
type
	TSFractal = class;
	
	TSFractalData = class
			public
		constructor Create(const Fractal:TSFractal; const ThreadID:LongWord);
			public
		FThreadID:LongWord;
		FFractal:TSFractal;
		end;
	
	TSFractal = class(TSPaintableObject)
			public
		constructor Create(); override;
		destructor Destroy(); override;
		class function ClassName() : TSString; override;
			public
		FDepth:LongInt;
		
		FThreadsEnable:Boolean;
		
		FThreadsData:packed array of 
			packed record
				FFinished:Boolean;
				FData:TSFractalData;
				FThread:TSThread;
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
	
	TS3DFractal=class (TSFractal)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName():string;override;
			protected
		F3dObject        : TSCustomModel;
		F3dObjectsInfo  : packed array of TSByte;
		F3dObjectsReady : TSBoolean;
		FShift       : TSInt64;
		
		FSun              : TSVertex3f;
		FSunAbs           : TSSingle;
		FSunTrigonometry  : packed array[0..2] of TSSingle;
		FLightingEnable   : TSBoolean;
		FCamera           : TSCamera;
		
		FEnableVBO      : TSBoolean;
		FClearVBOAfterLoad : TSBoolean;
		FEnableColors   : TSBoolean;
		FEnableNormals  : TSBoolean;
		FHasIndexes     : TSBoolean;
			public
		procedure DeleteRenderResources();override;
		procedure LoadRenderResources();override;
		procedure Paint();override;
		procedure Calculate();override;
		procedure Set3dObjectArLength(const MID,LFaces,LVertexes:int64);inline;
		procedure Calculate3dObjects(Quantity:Int64;const PoligoneType:LongWord;const VVertexType:TS3dObjectVertexType = S3dObjectVertexType3f;const VertexMn : TSByte = 0);
		procedure Clear3dObject();inline;
		procedure AfterPushIndexes(var ObjectID:LongWord;const DoAtThreads:Boolean;var FVertexIndex,FFaceIndex:LongWord);inline;overload;
		procedure AfterPushIndexes(var ObjectID:LongWord;const DoAtThreads:Boolean;var FVertexIndex:LongWord);inline;overload;
			public
		property LightingEnable : TSBoolean read FLightingEnable write FLightingEnable;
		property HasIndexes     : TSBoolean read FHasIndexes     write FHasIndexes;
		property EnableVBO      : TSBoolean read FEnableVBO      write FEnableVBO;
		property EnableNormals  : TSBoolean read FEnableNormals  write FEnableNormals;
		property EnableColors   : TSBoolean read FEnableColors   write FEnableColors;
		property ClearVBOAfterLoad : TSBoolean read FClearVBOAfterLoad   write FClearVBOAfterLoad;
			public
		FProjectionComboBox, FEffectsComboBox : TSScreenComboBox;
		FSizeLabel : TSScreenLabel;
		FSaveButton : TSScreenButton;
		FSizeLabelFlag : Boolean;
			public
		procedure InitProjectionComboBox(const a,b,c,d:LongWord;const Anch:TSSetOfByte = []);
		procedure InitEffectsComboBox(const a,b,c,d:LongWord;const Anch:TSSetOfByte = []);
		procedure InitSizeLabel(const a,b,c,d:LongWord;const Anch:TSSetOfByte = []);
		procedure InitSaveButton(const a,b,c,d:TSUInt32;const Anch:TSSetOfByte = []);
		end;
	TSFractal3D = TS3DFractal;
	
	TSImageFractal=class(TSFractal)
			public
		constructor Create();override;
		class function ClassName():string;override;
			protected
		FImage:TSImage;
		FView:TSScreenVertexes;
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
	 SmoothStringUtils
	,Smooth3dObjectS3DM
	,SmoothFileUtils
	;

procedure TS3DFractal.DeleteRenderResources();
begin
Clear3dObject();
end;

procedure TS3DFractal.LoadRenderResources();
begin
Calculate();
end;

procedure TS3DFractal.Calculate();
begin
FSizeLabelFlag:=False;
inherited;
if FEnableVBO then
	F3dObjectsReady:=False;
end;

class function TSFractal.ClassName:string;
begin
Result := 'Smooth fractal';
end;

class function TS3DFractal.ClassName:string;
begin
Result := 'Smooth 3D fractal ';
end;

class function TSImageFractal.ClassName:string;
begin
Result := 'Smooth image fractal';
end;

procedure S3DFractalComboBoxProjProc(a,b:LongInt;VComboBox:TSScreenComboBox);
begin
with TS3DFractal(VComboBox.FUserPointer1) do
	begin
	case b of
	0:FCamera.MatrixMode:=S_3D;
	1:FCamera.MatrixMode:=S_3D_ORTHO;
	end;
	end;
end;

procedure S3DFractalComboBoxEffProc(a,b:LongInt;VComboBox:TSScreenComboBox);
begin
with TS3DFractal(VComboBox.FUserPointer1) do
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

procedure TS3DFractal.InitSizeLabel(const a,b,c,d:LongWord;const Anch:TSSetOfByte = []);
begin
SKill(FSizeLabel);
FSizeLabel := SCreateLabel(Screen, '', False, a,b,c,d, Anch, True);
FSizeLabel.FUserPointer1:=Self;
end;

procedure S3DFractalSaveButtonProcedure(Button : TSScreenButton);
begin
with TS3DFractal(Button.FUserPointer1) do
	TS3dObjectS3DMLoader.SaveModelToFile(F3dObject, 'Save ' + SFreeFileName(ClassName(), ''));
end; 

procedure TS3DFractal.InitSaveButton(const a, b, c, d : TSUInt32; const Anch : TSSetOfByte = []);
begin
SKill(FSaveButton);
FSaveButton := SCreateButton(Screen, 'Сохранить 3D обьект', a,b,c,d, TSScreenComponentProcedure(@S3DFractalSaveButtonProcedure), Anch, True, True, Self);
end;

procedure TS3DFractal.InitEffectsComboBox(const a,b,c,d:LongWord;const Anch:TSSetOfByte = []);
begin
SKill(FEffectsComboBox);
FEffectsComboBox := SCreateComboBox(Screen, a,b,c,d, Anch, TSScreenComboBoxProcedure(@S3DFractalComboBoxEffProc), True, True, Self);
FEffectsComboBox.CreateItem('Нормали и цвета');
FEffectsComboBox.CreateItem('Только нормали');
FEffectsComboBox.CreateItem('Только цвета');
FEffectsComboBox.CreateItem('Без нормалей и цветов');
FEffectsComboBox.SelectItem := 0;
end;

procedure TS3DFractal.InitProjectionComboBox(const a,b,c,d:LongWord;const Anch:TSSetOfByte = []);
begin
if (FProjectionComboBox <> nil) then
	Exit;
FProjectionComboBox := SCreateComboBox(Screen, a,b,c,d, Anch, TSScreenComboBoxProcedure(@S3DFractalComboBoxProjProc), True, True, Self);
FProjectionComboBox.CreateItem('Перспективная проекция');
FProjectionComboBox.CreateItem('Ортогональная проекция');
FProjectionComboBox.SelectItem:=0;
end;

procedure TS3DFractal.Clear3dObject;inline;
begin
SetLength(F3dObjectsInfo, 0);
F3dObjectsReady := False;
if F3dObject=nil then
	begin
	F3dObject:=TSCustomModel.Create();
	F3dObject.SetContext(Context);
	end
else
	if F3dObject.QuantityObjects>0 then
		begin
		SetLength(F3dObjectsInfo,0);
		F3dObject.Clear();
		end;
end;

procedure TS3DFractal.AfterPushIndexes(var ObjectID:LongWord;const DoAtThreads:Boolean;var FVertexIndex:LongWord);inline;overload;
begin
if ((HasIndexes) and ((FVertexIndex div F3dObject.Objects[ObjectID].GetPoligoneInt(F3dObject.Objects[ObjectID].PoligonesType[0]))>=FShift))
or ((not HasIndexes) and ((FVertexIndex div F3dObject.Objects[ObjectID].GetPoligoneInt(F3dObject.Objects[ObjectID].ObjectPoligonesType))>=FShift))
 then
	begin
	if (not DoAtThreads) and FEnableVBO then
		begin
		F3dObject.Objects[ObjectID].LoadToVBO(FClearVBOAfterLoad);
		end;
	if FThreadsEnable and (ObjectID>=0) and (ObjectID<=F3dObject.QuantityObjects-1) and (F3dObjectsInfo[ObjectID]=S_FALSE) then
		F3dObjectsInfo[ObjectID]:=S_TRUE;
	ObjectID+=1;
	FVertexIndex:=0;
	if FEnableVBO and ((ObjectID>=0) and (ObjectID<=F3dObject.QuantityObjects-1)) and (F3dObjectsInfo[ObjectID]=S_FALSE) and (F3dObject.Objects[ObjectID].QuantityVertexes=0) then
		begin
		Set3dObjectArLength(ObjectID,FShift,F3dObject.Objects[ObjectID].GetFaceLength(FShift));
		end;
	end;
end;

procedure TS3DFractal.AfterPushIndexes(var ObjectID:LongWord;const DoAtThreads:Boolean;var FVertexIndex,FFaceIndex:LongWord);inline;overload;
begin
if FFaceIndex>=FShift then
	begin
	if (not DoAtThreads) and FEnableVBO then
		begin
		F3dObject.Objects[ObjectID].LoadToVBO();
		end;
	if FThreadsEnable and (ObjectID>=0) and (ObjectID<=F3dObject.QuantityObjects-1) and (F3dObjectsInfo[ObjectID]=S_FALSE) then
		F3dObjectsInfo[ObjectID]:=S_TRUE;
	ObjectID+=1;
	FVertexIndex:=0;
	FFaceIndex:=0;
	if FEnableVBO and ((ObjectID>=0) and (ObjectID<=F3dObject.QuantityObjects-1)) and (F3dObjectsInfo[ObjectID]=S_FALSE) and (F3dObject.Objects[ObjectID].QuantityVertexes=0) then
		begin
		Set3dObjectArLength(ObjectID,FShift,F3dObject.Objects[ObjectID].GetFaceLength(FShift));
		end;
	end;
end;

procedure TS3DFractal.Calculate3dObjects(Quantity:Int64;const PoligoneType:LongWord;const VVertexType:TS3dObjectVertexType = S3dObjectVertexType3f;const VertexMn : TSByte = 0);
begin
if (Render = nil) or (Render.RenderType in [SRenderDirectX9,SRenderDirectX8]) then
	FShift := 4608*2
else
	FShift:=336384;
while Quantity<>0 do
	begin
	SetLength(F3dObjectsInfo,Length(F3dObjectsInfo)+1);
	F3dObjectsInfo[High(F3dObjectsInfo)]:=S_FALSE;
	F3dObject.AddObject();
	F3dObject.LastObject().ObjectColor:=SColor4fFromUInt32($FFFFFF);
	F3dObject.LastObject().EnableCullFace:=False;
	if (PoligoneType=SR_QUADS) and (Render.RenderType<>SRenderOpenGL) then
		F3dObject.LastObject().ObjectPoligonesType:=SR_TRIANGLES
	else
		F3dObject.LastObject().ObjectPoligonesType:=PoligoneType;
	F3dObject.LastObject().VertexType:=VVertexType;
	if FEnableColors then
		F3dObject.LastObject().AutoSetColorType();
	if FEnableNormals then
		F3dObject.LastObject().HasNormals:=True;
	F3dObject.LastObject().QuantityFaceArrays := Byte(FHasIndexes);
	if FHasIndexes then
		begin
		F3dObject.LastObject().PoligonesType[0]:=F3dObject.LastObject().ObjectPoligonesType;
		end;
	if Quantity<=FShift then
		begin
		if (PoligoneType=SR_QUADS) and (Render.RenderType<>SRenderOpenGL) then
			if VertexMn = 0 then
				Set3dObjectArLength(F3dObject.QuantityObjects-1,Quantity*2,
					TS3DObject.GetFaceLength(Quantity,SR_QUADS))
			else
				Set3dObjectArLength(F3dObject.QuantityObjects-1,Quantity*2,
					Quantity*VertexMn)
		else
			if VertexMn = 0 then
				Set3dObjectArLength(F3dObject.QuantityObjects-1,Quantity,
					TS3DObject.GetFaceLength(Quantity,F3dObject.Objects[F3dObject.QuantityObjects-1].ObjectPoligonesType))
			else
				Set3dObjectArLength(F3dObject.QuantityObjects-1,Quantity,
					Quantity*VertexMn);
		Quantity:=0;
		end
	else
		begin
		if (PoligoneType=SR_QUADS) and (Render.RenderType<>SRenderOpenGL) then
			if VertexMn = 0 then
				Set3dObjectArLength(F3dObject.QuantityObjects-1,FShift*2,
					TS3DObject.GetFaceLength(FShift,SR_QUADS))
			else
				Set3dObjectArLength(F3dObject.QuantityObjects-1,FShift*2,
					FShift*VertexMn)
		else
			if VertexMn = 0 then
				Set3dObjectArLength(F3dObject.QuantityObjects-1,FShift,
					TS3DObject.GetFaceLength(FShift,F3dObject.Objects[F3dObject.QuantityObjects-1].ObjectPoligonesType))
			else
				Set3dObjectArLength(F3dObject.QuantityObjects-1,FShift,
					FShift*VertexMn);
		Quantity-=FShift;
		end;
	end;
end;

procedure TS3DFractal.Set3dObjectArLength(const MID,LFaces,LVertexes:int64);inline;
begin
if FHasIndexes then
	begin
	F3dObject.Objects[MID].AutoSetIndexFormat(0,LVertexes);
	F3dObject.Objects[MID].SetFaceLength(0,LFaces);
	end;
F3dObject.Objects[MID].SetVertexLength(LVertexes);
end;

constructor TSFractalData.Create(const Fractal:TSFractal; const ThreadID:LongWord);
begin
inherited Create();
FFractal:=Fractal;
FThreadID:=ThreadID;
end;

constructor TS3DFractal.Create();
begin
inherited;
FSunAbs := 10;
FSun.Import(0, 0, -FSunAbs);
FSunTrigonometry[0] := pi / 2;
FSunTrigonometry[1] := 0;
FSunTrigonometry[2] := pi + pi;
FLightingEnable := True;
F3dObject := nil;
FEnableVBO := Render.SupportedGraphicalBuffers();
FClearVBOAfterLoad := True;
FHasIndexes := True;
if (Render = nil) or (Render.RenderType in [SRenderDirectX9, SRenderDirectX8]) then
	FShift := 4608 * 2
else
	FShift := 336384;
F3dObjectsInfo := nil;
F3dObjectsReady := True;
FEnableColors := True;
FEnableNormals := True;
FCamera:=TSCamera.Create();
FCamera.SetContext(Context);
FCamera.MatrixMode := S_3D;
FProjectionComboBox := nil;
FSizeLabel := nil;
FEffectsComboBox := nil;
FSaveButton := nil;
FSizeLabelFlag := False;
end;

destructor TS3DFractal.Destroy();
begin
SKill(FSaveButton);
SKill(FCamera);
SKill(FSizeLabel);
SKill(FProjectionComboBox);
SKill(FEffectsComboBox);
SKill(F3dObject);
SetLength(F3dObjectsInfo, 0);
inherited;
end;

procedure TS3DFractal.Paint();
var
	i,ii:LongInt;
begin
{$IFDEF SMoreDebuging}
	WriteLn('Begin of  "TSFractal.Draw" : "'+ClassName+'"');
	WriteLn('Var: F3dObjectsReady=',F3dObjectsReady,'; FEnableVBO=',FEnableVBO,' .');
	{$ENDIF}
FCamera.CallAction();
if (Not F3dObjectsReady) and FThreadsEnable and FEnableVBO then
	begin
	ii:=1;
	for i:=0 to High(F3dObjectsInfo) do
		if F3dObjectsInfo[i]=S_TRUE then
			begin
			F3dObjectsInfo[i]:=S_UNKNOWN;
			F3dObject.Objects[i].LoadToVBO(FClearVBOAfterLoad);
			end
		else
			if F3dObjectsInfo[i]=S_FALSE then
				ii:=0;
	if ii=1 then
		begin 
		F3dObjectsReady:=True;
		end;
	end
else
	if (Not F3dObjectsReady) and FThreadsEnable and (not FEnableVBO) then
		begin
		ii:=1;
		for i:=0 to High(F3dObjectsInfo) do
			if F3dObjectsInfo[i]<>S_TRUE then
				begin
				ii:=0;
				Break;
				end;
		if ii=1 then
			F3dObjectsReady:=True;
		end;
if FLightingEnable then
	begin
	FSunTrigonometry[0]+=pi/90		/20*Context.ElapsedTime;
	FSunTrigonometry[1]-=pi/60		/20*Context.ElapsedTime;
	FSunTrigonometry[2]+=pi/180		/20*Context.ElapsedTime;
	FSun.Import(cos(FSunTrigonometry[0]),sin(FSunTrigonometry[1]),cos(FSunTrigonometry[2]));
	FSun*=FSunAbs;
	Render.Color3f(1,1,1);
	Render.BeginScene(SR_POINTS);
	Render.Vertex(FSun);
	Render.EndScene();
	Render.Enable(SR_LIGHTING);
	Render.Enable(SR_LIGHT0);
	Render.LightPosition(FSun);
	end
else
	if Render.IsEnabled(SR_LIGHTING) then
		Render.Disable(SR_LIGHTING);
Render.Color4f(1,1,1,1);
Render.LineWidth(1);
if FEnableVBO then
	begin
	if (F3dObject<>nil) and (F3dObject.QuantityObjects<>0) then
	for i:=0 to F3dObject.QuantityObjects-1 do
		begin
		if F3dObject.Objects[i].EnableVBO then
			F3dObject.Objects[i].Paint();
		{$IFDEF SMoreDebuging}
			WriteLn('F3dObject.ArObjects[',i,'].FEnableVBO=',F3dObject.Objects[i].EnableVBO);
			{$ENDIF}
		end;
	end
else
	if F3dObject<>nil then
		begin
		F3dObject.Paint();
		end;
if FLightingEnable then
	begin
	Render.Disable(SR_LIGHT0);
	Render.Disable(SR_LIGHTING);
	end;
if (FSizeLabel<>nil) and (not FSizeLabelFlag)  and (F3dObject<>nil) then
	if (not ((FThreadsEnable))) or (((FThreadsEnable)) and F3dObjectsReady) then
		begin
		if HasIndexes then
			FSizeLabel.Caption:=(
				'Size : All: '+SMemorySizeToString(F3dObject.Size)+
				' ;Face: '+SMemorySizeToString(F3dObject.FacesSize)+
				' ;Vert: '+SMemorySizeToString(F3dObject.VertexesSize)+
				' ;LenArObj: '+SStr(F3dObject.QuantityObjects)+'.'
				)
		else
			FSizeLabel.Caption:=(
				'Size : Vert: '+SMemorySizeToString(F3dObject.VertexesSize)+
				' ;LenArObj: '+SStr(F3dObject.QuantityObjects)+'.'
				);
		FSizeLabelFlag:=True;
		end
	else
		begin
		FSizeLabel.Caption:=SStringToPChar(
			'Загрузка... (NOfObjects='+SStr(F3dObject.QuantityObjects)+';Threads='+SStr(Threads)
			);
		FSizeLabel.Caption:=FSizeLabel.Caption+')';
		end;
{$IFDEF SMoreDebuging}
	WriteLn('End of  "TSFractal.Draw" : "'+ClassName+'"');
	{$ENDIF}
end;

procedure TSFractal.AfterCalculate; 
begin 
end;

procedure TSFractal.BeginCalculate(); 
begin 
end;

procedure TSFractal.DestroyThreads();
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

procedure TSFractal.ThreadsBoolean(const b:boolean = false);
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

function TSFractal.ThreadsReady:Boolean;
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

procedure TSFractal.CreateThreads(const a:Byte);
var
	i:LongInt;
begin
SetLEngth(FThreadsData,a);
for i:=0 to High(FThreadsData) do
	FThreadsData[i].FData:=nil;
ThreadsBoolean(False);
end;

// $RANGECHECK
{$IFOPT R+}
	{$DEFINE RANGECHECKS_OFFED}
	{$R-}
	{$ENDIF}

class function TSImageFractal.GetColorOne(const a,b,color:LongInt):byte;inline;
var
	OutPut : TSMaxEnum;
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

constructor TSImageFractal.Create();
begin
inherited;
FDepthHeight:=0;
FImage:=nil;
end;

procedure TSImageFractal.BeginCalculate;
begin
inherited;
if (FImage = nil) then FImage := TSImage.Create() else FImage.FreeAll();
FImage.Context := Context;
FImage.BitMap.Clear();
FImage.BitMap.Width:=FDepth;
FImage.BitMap.Height:=FDepth*Byte(FDepthHeight=0)+FDepthHeight;
FImage.BitMap.Channels:=3;
FImage.BitMap.ChannelSize:=8;
FImage.BitMap.ReAllocateMemory();
end;

procedure TSImageFractal.ToTexture;
begin
FImage.LoadTexture();
ThreadsBoolean(False);
end;

// $RANGECHECK
{$IFOPT R+}
	{$DEFINE RANGECHECKS_OFFED}
	{$R-}
	{$ENDIF}

class function TSImageFractal.GetColor(const a, b, Color : TSLongInt) : TSByte;inline;
var
	Middle, OutPut : TSWord;
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

procedure TSImageFractal.InitColor(const x,y:LongInt;const RecNumber:LongInt);inline;
begin
FImage.BitMap.Data[((FDepth-Y)*FDepth+X)*3]:=trunc((RecNumber/15)*255);
end;

procedure TSFractal.Paint();
begin
Render.Color3f(1,1,1);
end;

procedure TSFractal.Calculate;
begin
end;

procedure TSFractal.SetThreadsQuantity(NewQuantity:LongWord);inline;
begin
SetLength(FThreadsData,NewQuantity);
FThreadsEnable:=NewQuantity>0;
end;

function TSFractal.GetThreadsQuantity():LongWord;inline;
begin
Result:=Length(FThreadsData);
end;

constructor TSFractal.Create();
begin
inherited;
FDepth:=3;
FThreadsEnable:=False;
FThreadsData:=nil;
end;

destructor TSFractal.Destroy;
begin
DestroyThreads;
inherited;
end;

end.
