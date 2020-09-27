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
		class function CountingTheNumberOfPolygons(const _Depth : TSMaxEnum) : TSMaxEnum; virtual; abstract;
			protected
		FLabelDepth, FLabelDepthCaption : TSScreenLabel; // Label depth and caption of depth label "Итерация"
		FBPD, FBMD : TSScreenButton; // Buttons of change depth (plus and minus)
			protected
		FIs2D : TSBoolean;
		FPrimetiveType : TSUInt32; // SR_LINES, SR_QUADS ...
		FPrimetiveParam : TSUInt32;
		end;

procedure S3DFractalThreadCallback(FractalThreadData:PSFractalThreadData);

implementation

uses
	 SmoothStringUtils
	,SmoothRenderBase
	,SmoothVertexObject
	,SmoothScreenBase
	,SmoothThreads
	;

procedure TS3DFractalForm.SetDepth(const _Depth : LongInt);
begin
inherited;
if FLabelDepth <> nil then
	FLabelDepth.Caption := SStr(FDepth)
end;

procedure S3DFractalThreadCallback(FractalThreadData:PSFractalThreadData);
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
NumberOfPolygons := CountingTheNumberOfPolygons(FDepth);;
if (not FIs2D) or (FIs2D and (Render.RenderType in [SRenderDirectX9, SRenderDirectX8])) then 
	Construct3dObjects(NumberOfPolygons, FPrimetiveType, S3dObjectVertexType3f, FPrimetiveParam)
else
	Construct3dObjects(NumberOfPolygons, FPrimetiveType, S3dObjectVertexType2f, FPrimetiveParam);
if FThreadsEnable then
	begin
	ThreadData[0]^.KillThread();
	ThreadData[0]^.Finished := False;
	ThreadData[0]^.FreeMemData();
	ThreadData[0]^.Thread   := TSThread.Create(TSPointerProcedure(@S3DFractalThreadCallback), ThreadData[0]);
	//PolygonsConstruction();
	end
else
	begin
	PolygonsConstruction();
	if FEnableVBO and (not F3dObject.LastObject().EnableVBO) then
		F3dObject.LastObject().LoadToVBO();
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

procedure S3DFractalFormButtonDepthPlus(Button:TSScreenButton);
begin
with TS3DFractalForm(Button.FUserPointer1) do
	begin
	FDepth += 1;
	Construct();
	FLabelDepth.Caption := SStr(Depth);
	FBMD.Active := True;
	end;
end;

procedure S3DFractalFormButtonDepthMinus(Button:TSScreenButton);
begin
with TS3DFractalForm(Button.FUserPointer1) do
	begin
	if Depth > 0 then
		begin
		FDepth -= 1;
		Construct();
		FLabelDepth.Caption := SStr(Depth);
		if Depth = 0 then
			FBMD.Active:=False;
		end;
	end;
end;

constructor TS3DFractalForm.Create(const VContext : ISContext);
begin
inherited;
FLabelDepth  := nil;
FLabelDepthCaption := nil;
FBMD := nil;
FBPD := nil;

InitProjectionComboBox(Render.Width-160,5,150,30,[SAnchRight]).BoundsMakeReal();
InitSizeLabel(5,Render.Height-25,Render.Width-20,20,[SAnchBottom]).BoundsMakeReal();

FLabelDepthCaption := SCreateLabel(Screen, 'Итерация:', Render.Width-160-90-125,5,115,30, [SAnchRight], True, True, Self);

FBPD:=TSScreenButton.Create;
Screen.CreateInternalComponent(FBPD);
Screen.LastInternalComponent.SetBounds(Render.Width-160-30,5,20,30);
Screen.LastInternalComponent.Anchors:=[SAnchRight];
Screen.LastInternalComponent.Caption:='+';
Screen.LastInternalComponent.FUserPointer1:=Self;
FBPD.OnChange:=TSScreenComponentProcedure(@S3DFractalFormButtonDepthPlus);
Screen.LastInternalComponent.Visible:=True;
Screen.LastInternalComponent.BoundsMakeReal();

FLabelDepth := SCreateLabel(Screen, '0', Render.Width-160-60,5,20,30, [SAnchRight], True, True, Self);

FBMD:=TSScreenButton.Create;
Screen.CreateInternalComponent(FBMD);
Screen.LastInternalComponent.SetBounds(Render.Width-160-90,5,20,30);
Screen.LastInternalComponent.Anchors:=[SAnchRight];
Screen.LastInternalComponent.Caption:='-';
FBMD.OnChange:=TSScreenComponentProcedure(@S3DFractalFormButtonDepthMinus);
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
SKill(FBMD);
SKill(FLabelDepth);
SKill(FLabelDepthCaption);
SKill(FBPD);
inherited Destroy();
end;

class function TS3DFractalForm.ClassName():TSString;
begin
Result := 'TS3DFractalForm';
end;

end.
