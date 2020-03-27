{$INCLUDE Smooth.inc}

unit Smooth3dObject;

interface

uses
	 SmoothBase
	,SmoothDateTime
	,SmoothCommon
	,SmoothCommonStructs
	,SmoothImage
	,SmoothRender
	,SmoothRenderBase
	,SmoothContextClasses
	,SmoothContextInterface
	,SmoothMatrix
	,SmoothVertexObject
	,SmoothMaterial
	,SmoothCasesOfPrint
	
	,Classes
	,Crt
	;
type
	TSCustomModel = class;
    { TSCustomModel }
	TSModelLoadProgress = PSFloat32;
	
	PSCustom3dObject = ^ TSCustom3dObject;
	TSCustom3dObject = packed record
		F3dObject    : TS3DObject;
		FCopired : TSInt64;
		FMatrix  : TSMatrix4x4;
		end;
	
    TSCustomModel = class(TSPaintableObject)
    public
        constructor Create(); override;
        destructor Destroy(); override;
        class function ClassName() : TSString; override;
        procedure SetContext(const VContext : ISContext); override;
    protected
        FQuantityObjects   : TSUInt64;
        FQuantityMaterials : TSUInt64;
	
        FArMaterials : packed array of TSMaterial;
        FArObjects   : packed array of TSCustom3dObject;
    private
		function GetObject(const Index : TSMaxEnum):TS3dObject;
		function GetObjectMatrix(const Index : TSMaxEnum):PSMatrix4x4;
        procedure AddObjectColor(const ObjColor: TSColor4f);
        function GetMaterial(const Index : TSMaxEnum):TSMaterial;
        function Get3dObject(const Index : TSMaxEnum) : PSCustom3dObject;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
    public
		property QuantityMaterials : TSUInt64 read FQuantityMaterials;
		property QuantityObjects   : TSUInt64 read FQuantityObjects;
		property Objects[Index : TSMaxEnum]:TS3dObject read GetObject;
		property ObjectMatrix[Index : TSMaxEnum]:PSMatrix4x4 read GetObjectMatrix;
		property ObjectColor: TSColor4f write AddObjectColor;
		property Materials[Index : TSMaxEnum] : TSMaterial read GetMaterial;
		property ExtObjects[Index : TSMaxEnum] : PSCustom3dObject read Get3dObject;
    public
		function AddMaterial():TSMaterial;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function LastMaterial():TSMaterial;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function AddObject():TS3DObject;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function LastObject():TS3DObject;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
		function IdentifyMaterial(const MaterialName : TSString; var Material : ISMaterial) : TSBoolean; overload;
		function IdentifyMaterial(const MaterialName : TSString) : ISMaterial; overload;
		function IdentifyLastObjectMaterial(const MaterialName : TSString) : TSBoolean; overload;
    public
		procedure DrawObject(const Index : TSLongWord);
        procedure Paint(); override;
		procedure LoadToVBO();
        procedure WriteInfo(const PredString : TSString = ''; const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog]);
        procedure Clear(); virtual;
        // SR_TRIANGLES -> SR_TRIANGLE_STRIP
        procedure Stripificate();
    public
		procedure Dublicate(const Index:TSLongWord);
		procedure Translate(const Index:TSLongWord;const Vertex : TSVertex3f);
    public
		function VertexesSize():TSQWord;
		function FacesSize():TSQWord;
		function Size():TSQWord;
    end;
    PSCustomModel = ^ TSCustomModel;

procedure SKill(var M : TSCustomModel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;

implementation

uses
	 SmoothStringUtils
	,SmoothLog
	,SmoothFileUtils
	,SmoothMathUtils
	,SmoothSysUtils
	,SmoothBaseUtils
	,Smooth3dObjectLoader
	
	,SysUtils
	;

procedure SKill(var M : TSCustomModel); {$IFDEF SUPPORTINLINE}inline;{$ENDIF} overload;
begin
if M <> nil then
	begin
	M.Destroy();
	M := nil;
	end;
end;

// TSModel

procedure TSCustomModel.SetContext(const VContext : ISContext);
var
	Index : TSMaxEnum;
begin
inherited SetContext(VContext);
if FQuantityObjects > 0 then
	for Index :=0 to FQuantityObjects - 1 do
		if FArObjects[Index].F3dObject <> nil then
			FArObjects[Index].F3dObject.Context := Context;
if FQuantityMaterials > 0 then
	for Index := 0 to FQuantityMaterials - 1 do
		FArMaterials[Index].Context := Context;
end;

procedure TSCustomModel.Clear();
var
	Index : TSMaxEnum;
begin
if FQuantityObjects > 0 then
	begin
	for Index :=0 to FQuantityObjects - 1 do
		if FArObjects[Index].F3dObject <> nil then
			SKill(FArObjects[Index].F3dObject);
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

procedure TSCustomModel.LoadToVBO();
var	
	Index : TSUInt32;
begin
if FQuantityObjects > 0 then
	for Index := 0 to FQuantityObjects - 1 do
		if FArObjects[Index].F3dObject <> nil then
			FArObjects[Index].F3dObject.LoadToVBO();
end;

class function TSCustomModel.ClassName() : TSString;
begin
Result := 'TSCustomModel';
end;

procedure TSCustomModel.WriteInfo(const PredString : TSString = ''; const CasesOfPrint : TSCasesOfPrint = [SCasePrint, SCaseLog]);
var
	Index : TSMaxEnum;
begin
TextColor(7);
SHint(PredString + 'TSCustomModel__WriteInfo(..)', CasesOfPrint);
SHint([PredString, '  QuantityMaterials = ', FQuantityMaterials], CasesOfPrint);
SHint([PredString, '  QuantityObjects   = ', FQuantityObjects], CasesOfPrint);
if FQuantityMaterials <> 0 then
	for Index :=0 to FQuantityMaterials - 1 do
		FArMaterials[Index].WriteInfo(PredString + '  ' + SStr(Index + 1) + ') ', CasesOfPrint);
if FQuantityObjects <> 0 then
	for Index := 0 to FQuantityObjects - 1 do
		if FArObjects[Index].F3dObject <> nil then
			FArObjects[Index].F3dObject.WriteInfo(PredString + '  ' + SStr(Index + 1) + ') ', CasesOfPrint);
end;


procedure TSCustomModel.Stripificate();
var
	i : TSLongWord;
begin
for i:=0 to FQuantityObjects-1 do
	;//ArObjects[i].Stripificate;
end;

function TSCustomModel.VertexesSize():QWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	i : TSLongWord;
begin
Result:=0;
for i:=0 to FQuantityObjects-1 do
	Result+=FArObjects[i].F3dObject.VertexesSize();
end;

function TSCustomModel.FacesSize():TSQuadWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	i : TSLongWord;
begin
Result:=0;
if FQuantityObjects<>0 then
	for i:=0 to FQuantityObjects-1 do
		Result+=Objects[i].FacesSize();
end;

function TSCustomModel.Size():QWord; {$IFDEF SUPPORTINLINE} inline; {$ENDIF}
var
	i : TSLongWord;
begin
Result:=0;
for i:=0 to FQuantityObjects-1 do
	Result += FArObjects[i].F3dObject.Size();
end;

procedure TSCustomModel.AddObjectColor(const ObjColor: TSColor4f);
var
    i: TSLongWord;
begin
for i := 0 to High(FArObjects) do
	FArObjects[i].F3dObject.ObjectColor := ObjColor;
end;

constructor TSCustomModel.Create();
begin
inherited;
FQuantityMaterials := 0;
FQuantityObjects := 0;
FArMaterials := nil;
FArObjects := nil;
end;

destructor TSCustomModel.Destroy();
begin
Clear();
inherited;
end;

procedure TSCustomModel.DrawObject(const Index : TSLongWord);
var
    Current3dObject : TS3DObject;
begin
Current3dObject := Objects[Index];
if (Current3dObject <> nil) then
	begin
	Render.PushMatrix();
	Render.MultMatrixf(@FArObjects[Index].FMatrix);
	Current3dObject.Paint();
	Render.PopMatrix();
	end;
end;

procedure TSCustomModel.Paint();
var
    Index: TSLongWord;
begin
if FQuantityObjects <> 0 then
	for Index := 0 to FQuantityObjects - 1 do
		DrawObject(Index);
end;

function TSCustomModel.AddMaterial():TSMaterial;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FQuantityMaterials+=1;
SetLength(FArMaterials,FQuantityMaterials);
FArMaterials[FQuantityMaterials-1]:=TSMaterial.Create(Context);
Result:=FArMaterials[FQuantityMaterials-1];
end;

function TSCustomModel.LastMaterial():TSMaterial;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (FArMaterials=nil) or (FQuantityMaterials=0) then
	Result:=nil
else
	Result:=FArMaterials[FQuantityMaterials-1];
end;

function TSCustomModel.AddObject():TS3DObject;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
FQuantityObjects+=1;
SetLength(FArObjects,FQuantityObjects);
Result:=TS3DObject.Create();
Result.Context := Context;
FArObjects[FQuantityObjects-1].F3dObject    := Result;
FArObjects[FQuantityObjects-1].FCopired := -1;
FArObjects[FQuantityObjects-1].FMatrix  := SIdentityMatrix();
end;

function TSCustomModel.LastObject():TS3DObject;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (FQuantityObjects=0) or(FArObjects=nil) then
	Result:=nil
else
	Result:=FArObjects[FQuantityObjects-1].F3dObject;
end;

function TSCustomModel.IdentifyMaterial(const MaterialName : TSString) : ISMaterial; overload;
begin
IdentifyMaterial(MaterialName, Result);
end;

function TSCustomModel.IdentifyMaterial(const MaterialName : TSString; var Material : ISMaterial):TSBoolean; overload;
var
	Index : TSMaxEnum;
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

function TSCustomModel.IdentifyLastObjectMaterial(const MaterialName : TSString) : TSBoolean; overload;
var
	O : TS3DObject = nil;
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

function TSCustomModel.Get3dObject(const Index : TSMaxEnum) : PSCustom3dObject;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
if (Index >= 0) and (Index < QuantityObjects) then
	Result := @FArObjects[Index]
else
	Result := nil;
end;

function TSCustomModel.GetMaterial(const Index : TSMaxEnum):TSMaterial;
begin
Result:=FArMaterials[Index];
end;

function TSCustomModel.GetObject(const Index : TSMaxEnum):TS3dObject;

function FindIndex(const CurrentIndex : TSMaxEnum) : TSMaxEnum;
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
	ObjectIndex : TSMaxEnum;
begin
ObjectIndex := FindIndex(Index);
if ObjectIndex <> FQuantityObjects then
	Result := FArObjects[ObjectIndex].F3dObject
else
	Result := nil;
end;

procedure TSCustomModel.Dublicate(const Index:TSLongWord);
function FindIndex(const NowIndex : TSLongWord):TSLongWord;
begin
if FArObjects[NowIndex].FCopired<>-1 then
	Result:=FindIndex(FArObjects[NowIndex].FCopired)
else
	Result:=NowIndex;
end;
begin
FQuantityObjects+=1;
SetLength(FArObjects,FQuantityObjects);
FArObjects[FQuantityObjects-1].F3dObject:=nil;
FArObjects[FQuantityObjects-1].FCopired:=FindIndex(Index);
FArObjects[FQuantityObjects-1].FMatrix:=FArObjects[Index].FMatrix;
end;

procedure TSCustomModel.Translate(const Index:TSLongWord;const Vertex : TSVertex3f);
begin
FArObjects[Index].FMatrix:= FArObjects[Index].FMatrix * STranslateMatrix(Vertex);
end;

function TSCustomModel.GetObjectMatrix(const Index : TSMaxEnum):PSMatrix4x4;
begin
Result:=@FArObjects[Index].FMatrix;
end;

end.
