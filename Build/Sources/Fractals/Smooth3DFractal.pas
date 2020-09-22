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
	
	TS3DFractal=class (TSFractal)
			public
		constructor Create();override;
		destructor Destroy();override;
		class function ClassName():string;override;
			protected
		F3dObject       : TSCustomModel;
		F3dObjectsInfo  : TSUInt8List;
		F3dObjectsReady : TSBoolean;
		FPolygonsShift  : TSFractalIndexInt;
		
		FLightSource    : TSVertex3f;
		FLightSourceAbs : TSSingle;
		FLightSourceTrigonometry  : TSVector3d;
		FLightingEnable : TSBoolean;
		FCamera         : TSCamera;
		
		FEnableVBO      : TSBoolean;
		FClearVBOAfterLoad : TSBoolean;
		FEnableColors   : TSBoolean;
		FEnableNormals  : TSBoolean;
		FHasIndexes     : TSBoolean;
			protected
		function SizeLabelCaption() : TSString;
		procedure CkeckConstructedObjects();
		procedure PaintObject();
		procedure SaveObject();
		function CalculatePolygonsShift() : TSUInt64; virtual;
			public
		procedure DeleteRenderResources();override;
		procedure LoadRenderResources();override;
		procedure Paint();override;
		procedure Construct();override;
		procedure Set3dObjectArLength(const _ObjectNumber,LFaces,LVertices:int64);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure Construct3dObjects(NumberOfPolygons:Int64;const PoligoneType:LongWord;const VVertexType:TS3dObjectVertexType = S3dObjectVertexType3f;const VertexMultiplier : TSByte = 0);
		procedure Clear3dObject();{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		procedure AfterPushingPoligonData(var _ObjectNumber:TSFractalIndexInt;const _DoAtThreads:Boolean;var _VertexIndex, _FaceIndex:TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
		procedure AfterPushingPoligonData(var _ObjectNumber:TSFractalIndexInt;const _DoAtThreads:Boolean;var _VertexIndex:TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
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
		function InitProjectionComboBox(const a,b,c,d:LongWord;const Anch:TSSetOfByte = []) : TSScreenComboBox;
		function InitEffectsComboBox(const a,b,c,d:LongWord;const Anch:TSSetOfByte = []) : TSScreenComboBox;
		function InitSizeLabel(const a,b,c,d:LongWord;const Anch:TSSetOfByte = []) : TSScreenLabel;
		function InitSaveButton(const a,b,c,d:TSUInt32;const Anch:TSSetOfByte = []) : TSScreenButton;
		end;
	TSFractal3D = TS3DFractal;

implementation

uses
	 Smooth3dObjectS3DM
	,SmoothStringUtils
	,SmoothFileUtils
	;

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
if FEnableVBO then
	F3dObjectsReady:=False;
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
begin
TS3dObjectS3DMLoader.SaveModelToFile(F3dObject, 'Save ' + SFreeFileName(ClassName(), ''))
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

procedure TS3DFractal.AfterPushingPoligonData(var _ObjectNumber:TSFractalIndexInt;const _DoAtThreads:Boolean;var _VertexIndex:TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if ((HasIndexes) and ((_VertexIndex div F3dObject.Objects[_ObjectNumber].GetPoligoneInt(F3dObject.Objects[_ObjectNumber].PoligonesType[0]))>=FPolygonsShift))
or ((not HasIndexes) and ((_VertexIndex div F3dObject.Objects[_ObjectNumber].GetPoligoneInt(F3dObject.Objects[_ObjectNumber].ObjectPoligonesType))>=FPolygonsShift))
 then
	begin
	if (not _DoAtThreads) and FEnableVBO then
		begin
		F3dObject.Objects[_ObjectNumber].LoadToVBO(FClearVBOAfterLoad);
		end;
	if FThreadsEnable and (_ObjectNumber>=0) and (_ObjectNumber<=F3dObject.QuantityObjects-1) and (F3dObjectsInfo[_ObjectNumber]=S_FALSE) then
		F3dObjectsInfo[_ObjectNumber]:=S_TRUE;
	_ObjectNumber+=1;
	_VertexIndex:=0;
	if FEnableVBO and ((_ObjectNumber>=0) and (_ObjectNumber<=F3dObject.QuantityObjects-1)) and (F3dObjectsInfo[_ObjectNumber]=S_FALSE) and (F3dObject.Objects[_ObjectNumber].QuantityVertices=0) then
		begin
		Set3dObjectArLength(_ObjectNumber,FPolygonsShift,F3dObject.Objects[_ObjectNumber].GetFaceLength(FPolygonsShift));
		end;
	end;
end;

procedure TS3DFractal.AfterPushingPoligonData(var _ObjectNumber:TSFractalIndexInt;const _DoAtThreads:Boolean;var _VertexIndex,_FaceIndex:TSFractalIndexInt);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}overload;
begin
if _FaceIndex>=FPolygonsShift then
	begin
	if (not _DoAtThreads) and FEnableVBO then
		begin
		F3dObject.Objects[_ObjectNumber].LoadToVBO();
		end;
	if FThreadsEnable and (_ObjectNumber>=0) and (_ObjectNumber<=F3dObject.QuantityObjects-1) and (F3dObjectsInfo[_ObjectNumber]=S_FALSE) then
		F3dObjectsInfo[_ObjectNumber]:=S_TRUE;
	_ObjectNumber+=1;
	_VertexIndex:=0;
	_FaceIndex:=0;
	if FEnableVBO and ((_ObjectNumber>=0) and (_ObjectNumber<=F3dObject.QuantityObjects-1)) and (F3dObjectsInfo[_ObjectNumber]=S_FALSE) and (F3dObject.Objects[_ObjectNumber].QuantityVertices=0) then
		begin
		Set3dObjectArLength(_ObjectNumber,FPolygonsShift,F3dObject.Objects[_ObjectNumber].GetFaceLength(FPolygonsShift));
		end;
	end;
end;

procedure TS3DFractal.Construct3dObjects(NumberOfPolygons:Int64;const PoligoneType:LongWord;const VVertexType:TS3dObjectVertexType = S3dObjectVertexType3f;const VertexMultiplier : TSByte = 0);
// VertexMultiplier ?
begin
FPolygonsShift := CalculatePolygonsShift();
while NumberOfPolygons<>0 do
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
	if NumberOfPolygons<=FPolygonsShift then
		begin
		if (PoligoneType=SR_QUADS) and (Render.RenderType<>SRenderOpenGL) then
			if VertexMultiplier = 0 then
				Set3dObjectArLength(F3dObject.QuantityObjects-1,NumberOfPolygons*2,
					TS3DObject.GetFaceLength(NumberOfPolygons,SR_QUADS))
			else
				Set3dObjectArLength(F3dObject.QuantityObjects-1,NumberOfPolygons*2,
					NumberOfPolygons*VertexMultiplier)
		else
			if VertexMultiplier = 0 then
				Set3dObjectArLength(F3dObject.QuantityObjects-1,NumberOfPolygons,
					TS3DObject.GetFaceLength(NumberOfPolygons,F3dObject.Objects[F3dObject.QuantityObjects-1].ObjectPoligonesType))
			else
				Set3dObjectArLength(F3dObject.QuantityObjects-1,NumberOfPolygons,
					NumberOfPolygons*VertexMultiplier);
		NumberOfPolygons:=0;
		end
	else
		begin
		if (PoligoneType=SR_QUADS) and (Render.RenderType<>SRenderOpenGL) then
			if VertexMultiplier = 0 then
				Set3dObjectArLength(F3dObject.QuantityObjects-1,FPolygonsShift*2,
					TS3DObject.GetFaceLength(FPolygonsShift,SR_QUADS))
			else
				Set3dObjectArLength(F3dObject.QuantityObjects-1,FPolygonsShift*2,
					FPolygonsShift*VertexMultiplier)
		else
			if VertexMultiplier = 0 then
				Set3dObjectArLength(F3dObject.QuantityObjects-1,FPolygonsShift,
					TS3DObject.GetFaceLength(FPolygonsShift,F3dObject.Objects[F3dObject.QuantityObjects-1].ObjectPoligonesType))
			else
				Set3dObjectArLength(F3dObject.QuantityObjects-1,FPolygonsShift,
					FPolygonsShift*VertexMultiplier);
		NumberOfPolygons-=FPolygonsShift;
		end;
	end;
end;

procedure TS3DFractal.Set3dObjectArLength(const _ObjectNumber,LFaces,LVertices:int64);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if FHasIndexes then
	begin
	F3dObject.Objects[_ObjectNumber].AutoSetIndexFormat(0,LVertices);
	F3dObject.Objects[_ObjectNumber].SetFaceLength(0,LFaces);
	end;
F3dObject.Objects[_ObjectNumber].SetVertexLength(LVertices);
end;

function TS3DFractal.CalculatePolygonsShift() : TSUInt64;
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
FEnableVBO := Render.SupportedGraphicalBuffers();
FClearVBOAfterLoad := True;
FHasIndexes := True;
FPolygonsShift := CalculatePolygonsShift();
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
if FEnableVBO then
	begin
	Index2 := 1;
	for Index := 0 to High(F3dObjectsInfo) do
		if F3dObjectsInfo[Index] = S_TRUE then
			begin
			if F3dObject.Objects[Index].LoadToVBO(FClearVBOAfterLoad) then
				F3dObjectsInfo[Index] := S_UNKNOWN;
			end
		else if F3dObjectsInfo[Index] = S_FALSE then
			Index2 := 0;
	if Index2 = 1 then
		F3dObjectsReady := True;
	end
else if (not FEnableVBO) then
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
if FEnableVBO and FThreadsEnable and (F3dObject.QuantityObjects > 0) then
	begin
	for Index := 0 to F3dObject.QuantityObjects - 1 do
		if F3dObject.Objects[Index].EnableVBO then
			F3dObject.Objects[Index].Paint();
	end
else if (not FEnableVBO) and FThreadsEnable and (F3dObject.QuantityObjects > 0) then
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
end;

function TS3DFractal.SizeLabelCaption() : TSString;
var
	NumberObjects, Size, VerticesSize, FacesSize : TSUInt64;
	Index : TSMaxEnum;
begin
if (not FThreadsEnable) or (FThreadsEnable and F3dObjectsReady) then
	if HasIndexes then
		Result := 
			' Size: '+SMemorySizeToString(F3dObject.Size)+
			'; Faces: '+SMemorySizeToString(F3dObject.FacesSize)+
			', Vertices: '+SMemorySizeToString(F3dObject.VerticesSize)+
			'. Objects: '+SStr(F3dObject.QuantityObjects)+'.'
	else
		Result :=
			'Size of vertices: '+SMemorySizeToString(F3dObject.VerticesSize)+
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