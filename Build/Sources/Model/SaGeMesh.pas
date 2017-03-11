{$INCLUDE SaGe.inc}

unit SaGeMesh;

interface

uses
	 SaGeBase
	,SaGeDateTime
	,SaGeCommon
	,SaGeCommonStructs
	,SaGeImage
	,SaGeRender
	,SaGeRenderBase
	,SaGeCommonClasses
	,SaGeLog
	,SaGeMatrix
	,SaGeVertexObject
	,SaGeMaterial
	
	,Classes
	,Crt
	;
type
	TSGCustomModel = class;
    { TSGCustomModel }
	TSGModelLoadProgress = PSGFloat32;
	
	PSGCustomModelMesh = ^ TSGCustomModelMesh;
	TSGCustomModelMesh = packed record
		FMesh    : TSG3DObject;
		FCopired : TSGInt64;
		FMatrix  : TSGMatrix4x4;
		end;
	
    TSGCustomModel = class(TSGDrawable)
    public
        constructor Create(); override;
        destructor Destroy(); override;
        class function ClassName() : TSGString; override;
    protected
        FQuantityObjects   : TSGUInt64;
        FQuantityMaterials : TSGUInt64;
	
        FArMaterials : packed array of TSGMaterial;
        FArObjects   : packed array of TSGCustomModelMesh;
    private
		function GetObject(const Index : TSGMaxEnum):TSG3dObject;
		function GetObjectMatrix(const Index : TSGMaxEnum):PSGMatrix4x4;
        procedure AddObjectColor(const ObjColor: TSGColor4f);
        function GetMaterial(const Index : TSGMaxEnum):TSGMaterial;
        function GetModelMesh(const Index : TSGMaxEnum) : PSGCustomModelMesh;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
    public
		property QuantityMaterials : TSGUInt64 read FQuantityMaterials;
		property QuantityObjects   : TSGUInt64 read FQuantityObjects;
		property Objects[Index : TSGMaxEnum]:TSG3dObject read GetObject;
		property ObjectMatrix[Index : TSGMaxEnum]:PSGMatrix4x4 read GetObjectMatrix;
		property ObjectColor: TSGColor4f write AddObjectColor;
		property Materials[Index : TSGMaxEnum] : TSGMaterial read GetMaterial;
		property ModelMesh[Index : TSGMaxEnum] : PSGCustomModelMesh read GetModelMesh;
    public
		function AddMaterial():TSGMaterial;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function LastMaterial():TSGMaterial;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AddObject():TSG3DObject;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function LastObject():TSG3DObject;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function IdentifyMaterial(const MaterialName : TSGString; var Material : ISGMaterial) : TSGBoolean; overload;
		function IdentifyMaterial(const MaterialName : TSGString) : ISGMaterial; overload;
		function IdentifyLastObjectMaterial(const MaterialName : TSGString) : TSGBoolean; overload;
    public
		procedure DrawObject(const Index : TSGLongWord);
        procedure Paint(); override;
		procedure LoadToVBO();
        procedure WriteInfo(const PredString : TSGString = ''; const ViewError : TSGViewErrorType = [SGPrintError, SGLogError]);
        procedure Clear(); virtual;
        // SGR_TRIANGLES -> SGR_TRIANGLE_STRIP
        procedure Stripificate();
    public
		procedure Dublicate(const Index:TSGLongWord);
		procedure Translate(const Index:TSGLongWord;const Vertex : TSGVertex3f);
    public
		function VertexesSize():TSGQWord;
		function FacesSize():TSGQWord;
		function Size():TSGQWord;
    end;
    PSGCustomModel = ^ TSGCustomModel;

procedure SGKill(var M : TSGCustomModel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SaGeStringUtils
	,SaGeFileUtils
	,SaGeMathUtils
	,SaGeSysUtils
	,SaGeBaseUtils
	,SaGeMeshLoader
	
	,SysUtils
	;

procedure SGKill(var M : TSGCustomModel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if M <> nil then
	begin
	M.Destroy();
	M := nil;
	end;
end;

// TSGModel

procedure TSGCustomModel.Clear();
var
	Index : TSGMaxEnum;
begin
if FQuantityObjects > 0 then
	begin
	for Index :=0 to FQuantityObjects - 1 do
		if FArObjects[Index].FMesh <> nil then
			SGKill(FArObjects[Index].FMesh);
	SetLength(FArObjects, 0);
	FQuantityObjects := 0;
	end;
FArObjects := nil;
if FQuantityMaterials > 0 then
	begin
	for Index :=0 to FQuantityMaterials - 1 do
		FArMaterials[Index].Destroy;
	SetLength(FArMaterials, 0);
	FQuantityMaterials := 0;
	end;
FArMaterials := nil;
end;

procedure TSGCustomModel.LoadToVBO();
var	
	Index : TSGUInt32;
begin
if FQuantityObjects > 0 then
	for Index := 0 to FQuantityObjects - 1 do
		if FArObjects[Index].FMesh <> nil then
			FArObjects[Index].FMesh.LoadToVBO();
end;

class function TSGCustomModel.ClassName() : TSGString;
begin
Result := 'TSGCustomModel';
end;

procedure TSGCustomModel.WriteInfo(const PredString : TSGString = ''; const ViewError : TSGViewErrorType = [SGPrintError, SGLogError]);
var
	Index : TSGMaxEnum;
begin
TextColor(7);
SGHint(PredString + 'TSGCustomModel__WriteInfo(..)', ViewError);
SGHint([PredString, '  QuantityMaterials = ', FQuantityMaterials], ViewError);
SGHint([PredString, '  QuantityObjects   = ', FQuantityObjects], ViewError);
if FQuantityMaterials <> 0 then
	for Index :=0 to FQuantityMaterials - 1 do
		FArMaterials[Index].WriteInfo(PredString + '  ' + SGStr(Index + 1) + ') ', ViewError);
if FQuantityObjects <> 0 then
	for Index := 0 to FQuantityObjects - 1 do
		if FArObjects[Index].FMesh <> nil then
			FArObjects[Index].FMesh.WriteInfo(PredString + '  ' + SGStr(Index + 1) + ') ', ViewError);
end;


procedure TSGCustomModel.Stripificate();
var
	i : TSGLongWord;
begin
for i:=0 to FQuantityObjects-1 do
	;//ArObjects[i].Stripificate;
end;

function TSGCustomModel.VertexesSize():QWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	i : TSGLongWord;
begin
Result:=0;
for i:=0 to FQuantityObjects-1 do
	Result+=FArObjects[i].FMesh.VertexesSize();
end;

function TSGCustomModel.FacesSize():TSGQuadWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	i : TSGLongWord;
begin
Result:=0;
if FQuantityObjects<>0 then
	for i:=0 to FQuantityObjects-1 do
		Result+=Objects[i].FacesSize();
end;

function TSGCustomModel.Size():QWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	i : TSGLongWord;
begin
Result:=0;
for i:=0 to FQuantityObjects-1 do
	Result += FArObjects[i].FMesh.Size();
end;

procedure TSGCustomModel.AddObjectColor(const ObjColor: TSGColor4f);
var
    i: TSGLongWord;
begin
for i := 0 to High(FArObjects) do
	FArObjects[i].FMesh.ObjectColor := ObjColor;
end;

constructor TSGCustomModel.Create();
begin
inherited;
FQuantityMaterials := 0;
FQuantityObjects := 0;
FArMaterials := nil;
FArObjects := nil;
end;

destructor TSGCustomModel.Destroy();
begin
Clear();
inherited;
end;

procedure TSGCustomModel.DrawObject(const Index : TSGLongWord);
var
    CurrentMesh : TSG3DObject;
begin
CurrentMesh := Objects[Index];
if (CurrentMesh <> nil) then
	begin
	Render.PushMatrix();
	Render.MultMatrixf(@FArObjects[Index].FMatrix);
	CurrentMesh.Paint();
	Render.PopMatrix();
	end;
end;

procedure TSGCustomModel.Paint();
var
    Index: TSGLongWord;
begin
if FQuantityObjects <> 0 then
	for Index := 0 to FQuantityObjects - 1 do
		DrawObject(Index);
end;

function TSGCustomModel.AddMaterial():TSGMaterial;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FQuantityMaterials+=1;
SetLength(FArMaterials,FQuantityMaterials);
FArMaterials[FQuantityMaterials-1]:=TSGMaterial.Create(Context);
Result:=FArMaterials[FQuantityMaterials-1];
end;

function TSGCustomModel.LastMaterial():TSGMaterial;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (FArMaterials=nil) or (FQuantityMaterials=0) then
	Result:=nil
else
	Result:=FArMaterials[FQuantityMaterials-1];
end;

function TSGCustomModel.AddObject():TSG3DObject;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FQuantityObjects+=1;
SetLength(FArObjects,FQuantityObjects);
Result:=TSG3DObject.Create();
Result.Context := Context;
FArObjects[FQuantityObjects-1].FMesh    := Result;
FArObjects[FQuantityObjects-1].FCopired := -1;
FArObjects[FQuantityObjects-1].FMatrix  := SGIdentityMatrix();
end;

function TSGCustomModel.LastObject():TSG3DObject;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (FQuantityObjects=0) or(FArObjects=nil) then
	Result:=nil
else
	Result:=FArObjects[FQuantityObjects-1].FMesh;
end;

function TSGCustomModel.IdentifyMaterial(const MaterialName : TSGString) : ISGMaterial; overload;
begin
IdentifyMaterial(MaterialName, Result);
end;

function TSGCustomModel.IdentifyMaterial(const MaterialName : TSGString; var Material : ISGMaterial):TSGBoolean; overload;
var
	Index : TSGMaxEnum;
begin
Result := False;
Material := nil;
if FQuantityMaterials <> 0 then
	for Index := 0 to FQuantityMaterials - 1 do
		if FArMaterials[Index].Name = MaterialName then
			begin
			Material := FArMaterials[Index];
			Break;
			end;
Result := Material <> nil;
end;

function TSGCustomModel.IdentifyLastObjectMaterial(const MaterialName : TSGString) : TSGBoolean; overload;
var
	O : TSG3DObject = nil;
begin
Result := False;
O := LastObject();
if O <> nil then
	begin
	O.ObjectMaterial := IdentifyMaterial(MaterialName);
	O.HasTexture := O.ObjectMaterial <> nil;
	Result := O.HasTexture;
	end;
end;

function TSGCustomModel.GetModelMesh(const Index : TSGMaxEnum) : PSGCustomModelMesh;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (Index >= 0) and (Index < QuantityObjects) then
	Result := @FArObjects[Index]
else
	Result := nil;
end;

function TSGCustomModel.GetMaterial(const Index : TSGMaxEnum):TSGMaterial;
begin
Result:=FArMaterials[Index];
end;

function TSGCustomModel.GetObject(const Index : TSGMaxEnum):TSG3dObject;

function FindIndex(const CurrentIndex : TSGMaxEnum) : TSGMaxEnum;
begin
if (CurrentIndex >= 0) and (CurrentIndex < FQuantityObjects) then
	if FArObjects[CurrentIndex].FCopired <> -1 then
		Result := FindIndex(FArObjects[CurrentIndex].FCopired)
	else
		Result := CurrentIndex
else
	Result := FQuantityObjects;
end;

var
	MeshIndex : TSGMaxEnum;
begin
MeshIndex := FindIndex(Index);
if MeshIndex <> FQuantityObjects then
	Result := FArObjects[MeshIndex].FMesh
else
	Result := nil;
end;

procedure TSGCustomModel.Dublicate(const Index:TSGLongWord);
function FindIndex(const NowIndex : TSGLongWord):TSGLongWord;
begin
if FArObjects[NowIndex].FCopired<>-1 then
	Result:=FindIndex(FArObjects[NowIndex].FCopired)
else
	Result:=NowIndex;
end;
begin
FQuantityObjects+=1;
SetLength(FArObjects,FQuantityObjects);
FArObjects[FQuantityObjects-1].FMesh:=nil;
FArObjects[FQuantityObjects-1].FCopired:=FindIndex(Index);
FArObjects[FQuantityObjects-1].FMatrix:=FArObjects[Index].FMatrix;
end;

procedure TSGCustomModel.Translate(const Index:TSGLongWord;const Vertex : TSGVertex3f);
begin
FArObjects[Index].FMatrix:= FArObjects[Index].FMatrix * SGTranslateMatrix(Vertex);
end;

function TSGCustomModel.GetObjectMatrix(const Index : TSGMaxEnum):PSGMatrix4x4;
begin
Result:=@FArObjects[Index].FMatrix;
end;

end.
