{$INCLUDE Smooth.inc}

unit Smooth3DFractalForm;

interface

uses 
	 SmoothBase
	,SmoothFractal
	,Smooth3DFractal
	,SmoothScreen
	,SmoothContextInterface
	,SmoothScreenClasses
	;

type
	TS3DFractalForm = class(TS3DFractal)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		class function ClassName():TSString;override;
			public
		procedure Construct();override;
		procedure PolygonsConstruction(); virtual; // polygons construction
			protected
		procedure SetDepth(const _Depth : LongInt); override;
		procedure EndOfPolygonsConstruction(const ObjectId : TSUInt32); virtual;
		class function CountingTheNumberOfPolygons(const _Depth : TSMaxEnum) : TSMaxEnum; virtual;
		procedure ChangeDepth(const _IncrementOrDecrement : TSInt32);
			protected
		FLabelDepth, FLabelDepthCaption : TSScreenLabel; // Label depth and caption of depth label "��������"
		FButtonIncrementDepth, FButtonDecrementDepth : TSScreenButton; // Buttons of change depth (plus and minus)
			protected
		FIs2D : TSBoolean;
		FPrimetiveType : TSUInt32; // SR_LINES, SR_QUADS ...
		FPrimetiveParam : TSUInt32;
		procedure SetIs2D(const _Is2D : TSBoolean);
			public
		property Is2D : TSBoolean read FIs2D write SetIs2D;
		end;

procedure S3DFractalFormThreadCallback(FractalThreadData:PSFractalThreadData);

implementation

uses
	 SmoothStringUtils
	,SmoothRenderBase
	,SmoothVertexObject
	,SmoothScreenBase
	,SmoothThreads
	;

procedure TS3DFractalForm.SetIs2D(const _Is2D : TSBoolean);
begin
FIs2D := _Is2D;
if (not FIs2D) then
	InitEffectsComboBox(Render.Width - 160, 40, 150, 30, [SAnchRight]).BoundsMakeReal()
else
	SKill(FEffectsComboBox);
end;

class function TS3DFractalForm.CountingTheNumberOfPolygons(const _Depth : TSMaxEnum) : TSMaxEnum;
begin
Result := 0;
end;

procedure TS3DFractalForm.SetDepth(const _Depth : LongInt);
begin
inherited;
if FLabelDepth <> nil then
	FLabelDepth.Caption := SStr(FDepth)
end;

procedure S3DFractalFormThreadCallback(FractalThreadData:PSFractalThreadData);
begin
(FractalThreadData^.Fractal as TS3DFractalForm).PolygonsConstruction();
FractalThreadData^.Finished:=True;
FractalThreadData^.FreeMemData();
end;

procedure TS3DFractalForm.Construct();
var
	NumberOfPolygons : TSUInt64;
begin
inherited;
Clear3dObject();
NumberOfPolygons := CountingTheNumberOfPolygons(FDepth);
if (not FIs2D) or (FIs2D and (Render.RenderType in [SRenderDirectX9, SRenderDirectX8])) then 
	Construct3dObjects(NumberOfPolygons, FPrimetiveType, S3dObjectVertexType3f, FPrimetiveParam)
else
	Construct3dObjects(NumberOfPolygons, FPrimetiveType, S3dObjectVertexType2f, FPrimetiveParam);
if FThreadsEnable then
	ThreadData[0]^.StartThread(TSPointerProcedure(@S3DFractalFormThreadCallback), ThreadData[0]) //PolygonsConstruction();
else
	begin
	PolygonsConstruction();
	if (FMemoryDataType = SVRAM) and (not F3dObject.LastObject().EnableVBO) then
		F3dObject.LastObject().LoadToVBO(ClearRAMAfterLoadToVRAM);
	end;
end;

procedure TS3DFractalForm.PolygonsConstruction();
begin
end;

procedure TS3DFractalForm.EndOfPolygonsConstruction(const ObjectId : TSUInt32);
begin
if FThreadsEnable then
	if (ObjectId>=0) and (ObjectId<=F3dObject.QuantityObjects-1) then
		if F3dObjectsInfo[ObjectId]=S_FALSE then
			F3dObjectsInfo[ObjectId]:=S_TRUE;
end;

procedure TS3DFractalForm.ChangeDepth(const _IncrementOrDecrement : TSInt32);
var
	TempDepth : TSInt64;
begin
TempDepth := Depth;
TempDepth += _IncrementOrDecrement;
if TempDepth < 0 then
	TempDepth := 0;
FDepth := TempDepth;
Construct();
FLabelDepth.Caption := SStr(Depth);
FButtonDecrementDepth.Active := Depth <> 0;
end;

procedure S3DFractalFormButtonDepthPlus(Button:TSScreenButton);
begin
TS3DFractalForm(Button.FUserPointer1).ChangeDepth(1);
end;

procedure S3DFractalFormButtonDepthMinus(Button:TSScreenButton);
begin
TS3DFractalForm(Button.FUserPointer1).ChangeDepth(-1);
end;

constructor TS3DFractalForm.Create(const VContext : ISContext);
begin
inherited;
FLabelDepth  := nil;
FLabelDepthCaption := nil;
FButtonDecrementDepth := nil;
FButtonIncrementDepth := nil;

InitProjectionComboBox(Render.Width-160,5,150,30,[SAnchRight]).BoundsMakeReal();
InitSizeLabel(5,Render.Height-25,Render.Width-20,20,[SAnchBottom]).BoundsMakeReal();

FLabelDepthCaption := SCreateLabel(Screen, '��������:', Render.Width-160-90-125,5,115,30, [SAnchRight], True, True, Self);

FButtonIncrementDepth:=TSScreenButton.Create;
Screen.CreateInternalComponent(FButtonIncrementDepth);
Screen.LastInternalComponent.SetBounds(Render.Width-160-30,5,20,30);
Screen.LastInternalComponent.Anchors:=[SAnchRight];
Screen.LastInternalComponent.Caption:='+';
Screen.LastInternalComponent.FUserPointer1:=Self;
FButtonIncrementDepth.OnChange:=TSScreenComponentProcedure(@S3DFractalFormButtonDepthPlus);
Screen.LastInternalComponent.Visible:=True;
Screen.LastInternalComponent.BoundsMakeReal();

FLabelDepth := SCreateLabel(Screen, '0', Render.Width-160-60,5,20,30, [SAnchRight], True, True, Self);

FButtonDecrementDepth:=TSScreenButton.Create;
Screen.CreateInternalComponent(FButtonDecrementDepth);
Screen.LastInternalComponent.SetBounds(Render.Width-160-90,5,20,30);
Screen.LastInternalComponent.Anchors:=[SAnchRight];
Screen.LastInternalComponent.Caption:='-';
FButtonDecrementDepth.OnChange:=TSScreenComponentProcedure(@S3DFractalFormButtonDepthMinus);
Screen.LastInternalComponent.FUserPointer1:=Self;
Screen.LastInternalComponent.Visible:=True;
Screen.LastInternalComponent.BoundsMakeReal();

FIs2D := False;
FLightingEnable := False;
FPrimetiveType := SR_LINES;
FPrimetiveParam := 0;

FEnableColors  := False;
FEnableNormals := False;
Threads:={$IFDEF ANDROID}0{$ELSE}1{$ENDIF};
Depth:=3;
end;

destructor TS3DFractalForm.Destroy();
begin
SKill(FLabelDepth);
SKill(FLabelDepthCaption);
SKill(FButtonIncrementDepth);
SKill(FButtonDecrementDepth);
inherited Destroy();
end;

class function TS3DFractalForm.ClassName():TSString;
begin
Result := 'TS3DFractalForm';
end;

end.
