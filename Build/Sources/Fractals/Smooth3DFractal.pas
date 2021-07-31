{$INCLUDE Smooth.inc}

unit Smooth3DFractal;

interface

uses
	 SmoothBase
	,SmoothLists
	,SmoothFractal
	,SmoothCommon
	,SmoothCommonStructs
	,SmoothCamera
	,Smooth3dObject
	,SmoothVertexObject
	,SmoothRenderBase
	,SmoothRender
	,SmoothScreenClasses
	;
type
	TSFractalIndexInt = TSUInt64;
	
	TS3DFractal = class(TSFractal)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName():string;override;
			protected
		F3dObject       : TSCustomModel;
		F3dObjectsInfo  : TSUInt8List;
		F3dObjectsReady : TSBoolean;
		FPolygonsLimit  : TSFractalIndexInt;
		
		FLightSource    : TSVertex3f;
		FLightSourceAbs : TSSingle;
		FLightSourceTrigonometry  : TSVector3d;
		FLightingEnable : TSBoolean;
		FCamera         : TSCamera;
		
		FMemoryDataType : TSMemoryDataType;
		FClearRAMAfterLoadToVRAM : TSBoolean;
		FEnableColors   : TSBoolean;
		FEnableNormals  : TSBoolean;
		FHasIndexes     : TSBoolean;
			protected
		function SizeLabelCaption() : TSString;
		procedure CkeckConstructedObjects();
		procedure PaintObject();
		procedure SaveObject(); // видимо, не всегда срабатывает из-за хранения данных в памяти видеокарты
		function CalculatePolygonsLimit() : TSUInt64; virtual;
		procedure SetMemoryDataType(const _MemoryDataType : TSMemoryDataType);
			public
		procedure DeleteRenderResources();override;
		procedure LoadRenderResources();override;
		procedure Paint();override;
		procedure Construct();override;
		procedure Set3dObjectBuffersSize(const _Object : TS3DObject; const LFaces, LVertices : TSUInt64);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Set3dObjectBuffers(const _Object : TS3DObject; const  _PolygonsCount, _VertexMultiplier : TSUInt64; const _PolygonType : TSUInt32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Construct3dObjects(NumberOfPolygons : TSUInt64; const PolygonType:LongWord;const VVertexType:TS3dObjectVertexType = S3dObjectVertexType3f;const VertexMultiplier : TSByte = 0);
		procedure Clear3dObject();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure AfterPushingPolygonData(var _ObjectNumber:TSFractalIndexInt;const _DoAtThreads:Boolean;var _VertexIndex, _FaceIndex:TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure AfterPushingPolygonData(var _ObjectNumber:TSFractalIndexInt;const _DoAtThreads:Boolean;var _VertexIndex:TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
			public
		property LightingEnable : TSBoolean read FLightingEnable write FLightingEnable;
		property HasIndexes     : TSBoolean read FHasIndexes     write FHasIndexes;
		property MemoryDataType : TSMemoryDataType read FMemoryDataType write SetMemoryDataType;
		property EnableNormals  : TSBoolean read FEnableNormals  write FEnableNormals;
		property EnableColors   : TSBoolean read FEnableColors   write FEnableColors;
		property ClearRAMAfterLoadToVRAM : TSBoolean read FClearRAMAfterLoadToVRAM   write FClearRAMAfterLoadToVRAM;
			protected
		FProjectionComboBox, FEffectsComboBox : TSScreenComboBox;
		FSizeLabel : TSScreenLabel;
		FSaveButton : TSScreenButton;
		FSizeLabelFlag : Boolean;
			public
		function InitProjectionComboBox(const a,b,c,d:LongWord;const Anch:TSSetOfByte = []) : TSScreenComboBox;
		function InitEffectsComboBox(const a,b,c,d:LongWord;const Anch:TSSetOfByte = []) : TSScreenComboBox;
		function InitSizeLabel(const a,b,c,d:LongWord;const Anch:TSSetOfByte = []) : TSScreenLabel;
		function InitSaveButton(const a,b,c,d:TSUInt32;const Anch:TSSetOfByte = []) : TSScreenButton;
		end;

implementation

uses
	 Smooth3dObjectS3DM
	,SmoothStringUtils
	,SmoothFileUtils
	,SmoothLog
	,SmoothBaseUtils
	,SmoothContextUtils
	;

procedure TS3DFractal.SetMemoryDataType(const _MemoryDataType : TSMemoryDataType);
begin
if (_MemoryDataType <> FMemoryDataType) then
	begin
	FMemoryDataType := _MemoryDataType;
	Construct();
	end;
end;

procedure TS3DFractal.DeleteRenderResources();
begin
Clear3dObject();
end;

procedure TS3DFractal.LoadRenderResources();
begin
Construct();
end;

procedure TS3DFractal.Construct();
begin
FSizeLabelFlag:=False;
inherited;
if FMemoryDataType = SVRAM then
	F3dObjectsReady := False;
end;

class function TS3DFractal.ClassName:string;
begin
Result := 'Smooth 3D fractal ';
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
		Construct();
		end;
	end;
end;

function TS3DFractal.InitSizeLabel(const a,b,c,d:LongWord;const Anch:TSSetOfByte = []) : TSScreenLabel;
begin
SKill(FSizeLabel);
FSizeLabel := SCreateLabel(Screen, '', False, a,b,c,d, Anch, True);
FSizeLabel.FUserPointer1:=Self;
Result := FSizeLabel;
end;

procedure TS3DFractal.SaveObject();
var
	ObjectFileName : TSString;
begin
ObjectFileName := 'Save object of 3D fractal ''' + ClassName() + ''', d=' + SStr(Depth) + '.s3dm';
if (FMemoryDataType = SRAM) then
	TS3dObjectS3DMLoader.SaveModelToFile(F3dObject, SFreeFileName(ObjectFileName, ''));
end;

procedure S3DFractalSaveButtonProcedure(Button : TSScreenButton);
begin
TS3DFractal(Button.FUserPointer1).SaveObject();
end; 

function TS3DFractal.InitSaveButton(const a, b, c, d : TSUInt32; const Anch : TSSetOfByte = []) : TSScreenButton;
begin
SKill(FSaveButton);
FSaveButton := SCreateButton(Screen, 'Сохранить 3D обьект', a,b,c,d, TSScreenComponentProcedure(@S3DFractalSaveButtonProcedure), Anch, True, True, Self);
Result := FSaveButton;
end;

function TS3DFractal.InitEffectsComboBox(const a,b,c,d:LongWord;const Anch:TSSetOfByte = []) : TSScreenComboBox;
begin
SKill(FEffectsComboBox);
FEffectsComboBox := SCreateComboBox(Screen, a,b,c,d, Anch, TSScreenComboBoxProcedure(@S3DFractalComboBoxEffProc), True, True, Self);
FEffectsComboBox.CreateItem('Нормали и цвета');
FEffectsComboBox.CreateItem('Только нормали');
FEffectsComboBox.CreateItem('Только цвета');
FEffectsComboBox.CreateItem('Без нормалей и цветов');
FEffectsComboBox.SelectItem := 0;
Result := FEffectsComboBox;
end;

function TS3DFractal.InitProjectionComboBox(const a,b,c,d:LongWord;const Anch:TSSetOfByte = []) : TSScreenComboBox;
begin
SKill(FProjectionComboBox);
FProjectionComboBox := SCreateComboBox(Screen, a,b,c,d, Anch, TSScreenComboBoxProcedure(@S3DFractalComboBoxProjProc), True, True, Self);
FProjectionComboBox.CreateItem('Перспективная проекция');
FProjectionComboBox.CreateItem('Ортогональная проекция');
FProjectionComboBox.SelectItem:=0;
Result := FProjectionComboBox;
end;

procedure TS3DFractal.Clear3dObject();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SetLength(F3dObjectsInfo, 0);
F3dObjectsReady := False;
if F3dObject=nil then
	begin
	F3dObject:=TSCustomModel.Create();
	F3dObject.SetContext(Context);
	end
else if F3dObject.QuantityObjects>0 then
	begin
	SetLength(F3dObjectsInfo,0);
	F3dObject.Clear();
	end;
end;

procedure TS3DFractal.AfterPushingPolygonData(var _ObjectNumber:TSFractalIndexInt;const _DoAtThreads:Boolean;var _VertexIndex:TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if ((HasIndexes) and ((_VertexIndex div F3dObject.Objects[_ObjectNumber].GetPolygonInt(F3dObject.Objects[_ObjectNumber].PolygonsType[0]))>=FPolygonsLimit))
   or ((not HasIndexes) and ((_VertexIndex div F3dObject.Objects[_ObjectNumber].GetPolygonInt(F3dObject.Objects[_ObjectNumber].ObjectPolygonsType))>=FPolygonsLimit)) then
	begin
	if (not _DoAtThreads) and (FMemoryDataType = SVRAM) then
		F3dObject.Objects[_ObjectNumber].LoadToVBO(FClearRAMAfterLoadToVRAM);
	if FThreadsEnable and (_ObjectNumber>=0) and (_ObjectNumber<=F3dObject.QuantityObjects-1) and (F3dObjectsInfo[_ObjectNumber]=S_FALSE) then
		F3dObjectsInfo[_ObjectNumber] := S_TRUE;
	_ObjectNumber += 1;
	_VertexIndex := 0;
	if (FMemoryDataType = SVRAM) and ((_ObjectNumber>=0) and (_ObjectNumber<=F3dObject.QuantityObjects-1)) and (F3dObjectsInfo[_ObjectNumber]=S_FALSE) and (F3dObject.Objects[_ObjectNumber].QuantityVertices=0) then
		Set3dObjectBuffersSize(F3dObject.Objects[_ObjectNumber], FPolygonsLimit,F3dObject.Objects[_ObjectNumber].GetFaceLength(FPolygonsLimit));
	end;
end;

procedure TS3DFractal.AfterPushingPolygonData(var _ObjectNumber:TSFractalIndexInt;const _DoAtThreads:Boolean;var _VertexIndex,_FaceIndex:TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if _FaceIndex>=FPolygonsLimit then
	begin
	if (not _DoAtThreads) and (FMemoryDataType = SVRAM) then
		begin
		F3dObject.Objects[_ObjectNumber].LoadToVBO();
		end;
	if FThreadsEnable and (_ObjectNumber>=0) and (_ObjectNumber<=F3dObject.QuantityObjects-1) and (F3dObjectsInfo[_ObjectNumber]=S_FALSE) then
		F3dObjectsInfo[_ObjectNumber]:=S_TRUE;
	_ObjectNumber+=1;
	_VertexIndex:=0;
	_FaceIndex:=0;
	if (FMemoryDataType = SVRAM) and ((_ObjectNumber>=0) and (_ObjectNumber<=F3dObject.QuantityObjects-1)) and (F3dObjectsInfo[_ObjectNumber]=S_FALSE) and (F3dObject.Objects[_ObjectNumber].QuantityVertices=0) then
		Set3dObjectBuffersSize(F3dObject.Objects[_ObjectNumber], FPolygonsLimit, F3dObject.Objects[_ObjectNumber].GetFaceLength(FPolygonsLimit));
	end;
end;

procedure TS3DFractal.Construct3dObjects(NumberOfPolygons : TSUInt64; const PolygonType:LongWord;const VVertexType:TS3dObjectVertexType = S3dObjectVertexType3f;const VertexMultiplier : TSByte = 0);
// VertexMultiplier ?
var
	AddedObject : TS3DObject;
begin
SLog.Source([NumberOfPolygons]);
while NumberOfPolygons<>0 do
	begin
	SetLength(F3dObjectsInfo,Length(F3dObjectsInfo)+1);
	F3dObjectsInfo[High(F3dObjectsInfo)]:=S_FALSE;
	AddedObject := F3dObject.AddObject();
	AddedObject.ObjectColor := SColor4fFromUInt32($FFFFFF);
	AddedObject.EnableCullFace := False;
	if (PolygonType=SR_QUADS) and (Render.RenderType <> SRenderOpenGL) then
		AddedObject.ObjectPolygonsType:=SR_TRIANGLES
	else
		AddedObject.ObjectPolygonsType:=PolygonType;
	AddedObject.VertexType:=VVertexType;
	if FEnableColors then
		AddedObject.AutoSetColorType();
	AddedObject.HasNormals := FEnableNormals;
	AddedObject.QuantityFaceArrays := TSUInt8(FHasIndexes);
	if FHasIndexes then
		AddedObject.PolygonsType[0] := AddedObject.ObjectPolygonsType;
	Set3dObjectBuffers(AddedObject, Iff(NumberOfPolygons <= FPolygonsLimit, NumberOfPolygons, FPolygonsLimit), VertexMultiplier, PolygonType);
	if NumberOfPolygons <= FPolygonsLimit then
		NumberOfPolygons := 0
	else
		NumberOfPolygons -= FPolygonsLimit;
	AddedObject := nil;
	end;
end;

procedure TS3DFractal.Set3dObjectBuffers(const _Object : TS3DObject; const _PolygonsCount, _VertexMultiplier : TSUInt64; const _PolygonType : TSUInt32);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (_PolygonType=SR_QUADS) and (Render.RenderType<>SRenderOpenGL) then
	if _VertexMultiplier = 0 then
		Set3dObjectBuffersSize(_Object, _PolygonsCount * 2, TS3DObject.GetFaceLength(_PolygonsCount, SR_QUADS))
	else
		Set3dObjectBuffersSize(_Object, _PolygonsCount * 2, _PolygonsCount * _VertexMultiplier)
else
	if _VertexMultiplier = 0 then
		Set3dObjectBuffersSize(_Object, _PolygonsCount, TS3DObject.GetFaceLength(_PolygonsCount, _Object.ObjectPolygonsType))
	else
		Set3dObjectBuffersSize(_Object, _PolygonsCount, _PolygonsCount * _VertexMultiplier);
end;

procedure TS3DFractal.Set3dObjectBuffersSize(const _Object : TS3DObject; const LFaces, LVertices : TSUInt64);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FHasIndexes then
	begin
	_Object.AutoSetIndexFormat(0,LVertices);
	_Object.SetFaceLength(0,LFaces);
	end;
_Object.SetVertexLength(LVertices);
end;

function TS3DFractal.CalculatePolygonsLimit() : TSUInt64;
begin
Result := 4608; // 2^9 • 3^2
if (Render = nil) or (Render.RenderType in [SRenderDirectX9, SRenderDirectX8]) then
	Result *= 2 // 2^10 • 3^2
else
	Result *= 73; // 2^9 • 3^2 • 73
end;

constructor TS3DFractal.Create();
begin
inherited;
FLightSourceAbs := 10;
FLightSource := TSVector3f.Create(0, 0, -FLightSourceAbs);
FLightSourceTrigonometry := TSVector3d.Create(pi / 2, 0, pi + pi);
FLightingEnable := True;
F3dObject := nil;
case Render.SupportedGraphicalBuffers() of
False : FMemoryDataType := SRAM;
True  : FMemoryDataType := SVRAM;
end;
FClearRAMAfterLoadToVRAM := True;
FHasIndexes := True;
FPolygonsLimit := CalculatePolygonsLimit();
F3dObjectsInfo := nil;
F3dObjectsReady := True;
FEnableColors := True;
FEnableNormals := True;
FCamera := TSCamera.Create(Context, S_3D);
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

procedure TS3DFractal.CkeckConstructedObjects();
var
	Index, Index2 : TSMaxEnum;
begin
if Length(F3dObjectsInfo) <> 0 then
	begin
	if (FMemoryDataType = SVRAM) then
		begin
		Index2 := 1;
		for Index := 0 to High(F3dObjectsInfo) do
			if F3dObjectsInfo[Index] = S_TRUE then
				begin
				if F3dObject.Objects[Index].LoadToVBO(FClearRAMAfterLoadToVRAM) then
					F3dObjectsInfo[Index] := S_UNKNOWN;
				end
			else if F3dObjectsInfo[Index] = S_FALSE then
				Index2 := 0;
		if Index2 = 1 then
			F3dObjectsReady := True;
		end
	else if (FMemoryDataType <> SVRAM) then
		begin
		Index2 := 1;
		for Index := 0 to High(F3dObjectsInfo) do
			if F3dObjectsInfo[Index] <> S_TRUE then
				begin
				Index2 := 0;
				Break;
				end;
		if Index2 = 1 then
			F3dObjectsReady := True;
		end;
	end;
end;

procedure TS3DFractal.PaintObject();
var
	Index : TSMaxEnum;
begin
if FLightingEnable then
	begin
	FLightSourceTrigonometry += TSVector3d.Create(pi/90, pi/60, pi/180)/20*Context.ElapsedTime;
	FLightSource := TSVector3f.Create(cos(FLightSourceTrigonometry.x), sin(FLightSourceTrigonometry.y), cos(FLightSourceTrigonometry.z)) * FLightSourceAbs;
	Render.BeginScene(SR_POINTS);
	Render.Vertex(FLightSource);
	Render.EndScene();
	Render.Enable(SR_LIGHTING);
	Render.Enable(SR_LIGHT0);
	Render.LightPosition(FLightSource);
	end
else if Render.IsEnabled(SR_LIGHTING) then
	Render.Disable(SR_LIGHTING);
Render.Color4f(1,1,1,1);
Render.LineWidth(1);
if (FMemoryDataType = SVRAM) and FThreadsEnable and (F3dObject.QuantityObjects > 0) then
	begin
	for Index := 0 to F3dObject.QuantityObjects - 1 do
		if F3dObject.Objects[Index].EnableVBO then
			F3dObject.Objects[Index].Paint();
	end
else if (FMemoryDataType <> SVRAM) and FThreadsEnable and (F3dObject.QuantityObjects > 0) then
	begin
	for Index := 0 to F3dObject.QuantityObjects - 1 do
		if F3dObjectsInfo[Index] = S_TRUE then
			F3dObject.Objects[Index].Paint();
	end
else 
	F3dObject.Paint();
if FLightingEnable then
	begin
	Render.Disable(SR_LIGHT0);
	Render.Disable(SR_LIGHTING);
	end;
end;

procedure TS3DFractal.Paint();
begin
FCamera.InitMatrixAndMove();
if (not F3dObjectsReady) and FThreadsEnable then
	CkeckConstructedObjects();
if (F3dObject <> nil) then
	begin
	inherited;
	PaintObject();
	end;
if (FSizeLabel <> nil) and (not FSizeLabelFlag)  and (F3dObject <> nil) then
	begin
	FSizeLabel.Caption := SizeLabelCaption();
	if (not FThreadsEnable) or (FThreadsEnable and F3dObjectsReady) then
		FSizeLabelFlag := True;
	end;
if (Context.KeyPressed and (Context.KeysPressed(Char(17))) and (Context.KeyPressedChar='V') and (Context.KeyPressedType=SUpKey)) then
	case MemoryDataType of
	SVRAM : MemoryDataType := SRAM;
	SRAM : MemoryDataType := SVRAM;
	end;
if (Context.KeyPressed and (Context.KeysPressed(Char(17))) and (Context.KeyPressedChar='S') and (Context.KeyPressedType=SUpKey)) then
	SaveObject();
end;

function TS3DFractal.SizeLabelCaption() : TSString;
var
	NumberObjects, Size, VerticesSize, FacesSize : TSUInt64;
	Index : TSMaxEnum;
begin
if (not FThreadsEnable) or (FThreadsEnable and F3dObjectsReady) then
	if HasIndexes then
		Result := Iff(FMemoryDataType = SVRAM, 'V', '') + 'RAM' + // VRAM is Video RAM
			' size: '+SMemorySizeToString(F3dObject.Size)+
			'; Faces: '+SMemorySizeToString(F3dObject.FacesSize)+
			', Vertices: '+SMemorySizeToString(F3dObject.VerticesSize)+
			'. Objects: '+SStr(F3dObject.QuantityObjects)+'.'
	else
		Result := Iff(FMemoryDataType = SVRAM, 'V', '') + 'RAM' +  // VRAM is Video RAM
			' size of vertices: '+SMemorySizeToString(F3dObject.VerticesSize)+
			'; Objects: '+SStr(F3dObject.QuantityObjects)+'.'
{else if (FThreadsEnable and (not F3dObjectsReady) and (F3dObject.QuantityObjects > 0)) then
	begin
	NumberObjects := 0;
	Size := 0;
	VerticesSize := 0;
	FacesSize := 0;
	for Index := 0 to F3dObject.QuantityObjects - 1 do
		if F3dObjectsInfo[Index] = S_TRUE then
			begin
			NumberObjects += 1;
			Size += F3dObject.Objects[Index].Size;
			VerticesSize += F3dObject.Objects[Index].VerticesSize;
			FacesSize += F3dObject.Objects[Index].FacesSize;
			end;
	Result := 
		'Загрузка... Objects = '+SStr(F3dObject.QuantityObjects)+'; Threads = '+SStr(Threads) + '... ' + 
		' Size: '+SMemorySizeToString(Size)+
		'; Faces: '+SMemorySizeToString(FacesSize)+
		', Vertices: '+SMemorySizeToString(VerticesSize)+
		'. Objects: '+SStr(NumberObjects)+'...';
	end}
else
	Result := 'Загрузка... Objects = '+SStr(F3dObject.QuantityObjects)+'; Threads = '+SStr(Threads) + '...';
end;

end.