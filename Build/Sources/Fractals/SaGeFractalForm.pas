{$INCLUDE SaGe.inc}

unit SaGeFractalForm;

interface

uses 
	 SaGeBase
	,SaGeFractals
	,SaGeScreen
	,SaGeCommonClasses
	;

type
	TSG3DFractalForm = class(TSG3DFractal)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		class function ClassName():TSGString;override;
			public
		procedure Calculate();override;
		procedure CalculateFromThread(); virtual;
			protected
		procedure FinalizeCalculateFromThread(const MeshID : TSGUInt32); virtual;
		function RecQuantity(const RecDepth : TSGMaxEnum) : TSGMaxEnum; virtual; abstract;
			protected
		FLD,FLDC:TSGLabel;
		FBPD,FBMD:TSGButton;
			protected
		FIs2D : TSGBoolean;
		FPrimetiveType : TSGUInt32;
		FPrimetiveParam : TSGUInt32;
		end;

implementation

uses
	 SaGeStringUtils
	,SaGeRenderBase
	,SaGeVertexObject
	,SaGeScreenBase
	,SaGeScreenHelper
	;

procedure TSG3DFractalForm.Calculate();
var
	Quantity : TSGUInt64;
begin
inherited;
ClearMesh();
Quantity := RecQuantity(FDepth);
if FIs2D then
	if (Render.RenderType in [SGRenderDirectX9, SGRenderDirectX8]) then 
		CalculateMeshes(Quantity, FPrimetiveType, SGMeshVertexType3f, FPrimetiveParam)
	else
		CalculateMeshes(Quantity, FPrimetiveType, SGMeshVertexType2f, FPrimetiveParam)
else
	CalculateMeshes(Quantity, FPrimetiveType, SGMeshVertexType3f, FPrimetiveParam);
if FThreadsEnable then
	begin
	FThreadsData[0].FFinished := False;
	FThreadsData[0].FData     := nil;
	CalculateFromThread();
	end
else
	begin
	CalculateFromThread();
	if FEnableVBO and (not FMesh.LastObject().EnableVBO) then
		FMesh.LastObject().LoadToVBO();
	end;
end;

procedure TSG3DFractalForm.CalculateFromThread();
begin

end;

procedure TSG3DFractalForm.FinalizeCalculateFromThread(const MeshID : TSGUInt32);
begin
if FThreadsEnable then
	if (MeshID>=0) and (MeshID<=FMesh.QuantityObjects-1) then
		if FMeshesInfo[MeshID]=SG_FALSE then
			FMeshesInfo[MeshID]:=SG_TRUE;
end;

procedure mmmFButtonDepthPlusOnChangeKT(Button:TSGButton);
begin
with TSG3DFractalForm(Button.FUserPointer1) do
	begin
	FDepth += 1;
	Calculate();
	FLD.Caption := SGStr(Depth);
	FBMD.Active := True;
	end;
end;

procedure mmmFButtonDepthMinusOnChangeKT(Button:TSGButton);
begin
with TSG3DFractalForm(Button.FUserPointer1) do
	begin
	if Depth > 0 then
		begin
		FDepth -= 1;
		Calculate();
		FLD.Caption := SGStr(Depth);
		if Depth = 0 then
			FBMD.Active:=False;
		end;
	end;
end;

constructor TSG3DFractalForm.Create(const VContext : ISGContext);
begin
inherited Create(VContext);
FEnableColors  := False;
FEnableNormals := False;
{$IFNDEF ANDROID}
	Threads:=1;
	{$ENDIF}
Depth:=3;
FLightingEnable := False;

FIs2D := False;
FPrimetiveType := SGR_LINES;
FPrimetiveParam := 0;

FLD  := nil;
FLDC := nil;
FBMD := nil;
FBPD := nil;

InitProjectionComboBox(Render.Width-160,5,150,30,[SGAnchRight]);
Screen.LastChild.BoundsToNeedBounds();

InitSizeLabel(5,Render.Height-25,Render.Width-20,20,[SGAnchBottom]);
Screen.LastChild.BoundsToNeedBounds();

FLDC := SGCreateLabel(Screen, 'Итерация:', Render.Width-160-90-125,5,115,30, [SGAnchRight], True, True, Self);

FBPD:=TSGButton.Create;
Screen.CreateChild(FBPD);
Screen.LastChild.SetBounds(Render.Width-160-30,5,20,30);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Caption:='+';
Screen.LastChild.FUserPointer1:=Self;
FBPD.OnChange:=TSGComponentProcedure(@mmmFButtonDepthPlusOnChangeKT);
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsToNeedBounds();

FLD := SGCreateLabel(Screen, '0', Render.Width-160-60,5,20,30, [SGAnchRight], True, True, Self);

FBMD:=TSGButton.Create;
Screen.CreateChild(FBMD);
Screen.LastChild.SetBounds(Render.Width-160-90,5,20,30);
Screen.LastChild.Anchors:=[SGAnchRight];
Screen.LastChild.Caption:='-';
FBMD.OnChange:=TSGComponentProcedure(@mmmFButtonDepthMinusOnChangeKT);
Screen.LastChild.FUserPointer1:=Self;
Screen.LastChild.Visible:=True;
Screen.LastChild.BoundsToNeedBounds();

FLD.Caption:=SGStringToPChar(SGStr(Depth));
end;

destructor TSG3DFractalForm.Destroy();
begin
FBMD.Destroy();
FLD.Destroy();
FLDC.Destroy();
FBPD.Destroy();
inherited Destroy();
end;

class function TSG3DFractalForm.ClassName():TSGString;
begin
Result := 'TSG3DFractalForm';
end;

end.
