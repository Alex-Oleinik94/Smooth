{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex14;
	interface
{$ELSE}
	program Example14;
	{$ENDIF}
uses
	{$IFNDEF ENGINE}
		{$IFDEF UNIX}
			{$IFNDEF ANDROID}
				cthreads,
				{$ENDIF}
			{$ENDIF}
		SaGeBaseExample,
		{$ENDIF}
	SaGeContext
	,SaGeBased
	,SaGeBase
	,SaGeRender
	,SaGeUtils
	,SaGeScreen
	,SaGeMesh
	,SaGeCommon
	,Classes
	,SysUtils
	;
type
	TSGExample14 = class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		
		FModel : TSG3DObject;
		FModelBBoxMin,
			FModelBBoxMax,
			FModelCenter : TSGVertex3f;
			public
		procedure LoadModel(const FileName : TSGString);
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

procedure TSGExample14.LoadModel(const FileName : TSGString);
var
	Stream : TFileStream = nil;
	CountOfVertexes, CountOfIndexes : Integer;
	Indexes : packed array of packed array [0..2] of TSGLongWord;
	i : LongWord;
begin
FModel := TSG3DObject.Create();
FModel.Context := Context;
FModel.ObjectPoligonesType := SGR_TRIANGLES;
FModel.HasNormals := True;
FModel.SetColorType(SGMeshColorType4f);
FModel.HasTexture := False;
FModel.HasColors  := False;
FModel.EnableCullFace := False;
FModel.VertexType := SGMeshVertexType3f;
FModel.CountTextureFloatsInVertexArray := 4;

FModel.QuantityFaceArrays := 1;
FModel.PoligonesType[0] := FModel.ObjectPoligonesType;

Stream := TFileStream.Create(FileName,fmOpenRead);
Stream.ReadBuffer(FModelBBoxMin,SizeOf(FModelBBoxMin));
Stream.ReadBuffer(FModelBBoxMax,SizeOf(FModelBBoxMax));
FModelCenter := (FModelBBoxMax + FModelBBoxMin)/2;

FModelBBoxMin.WriteLn(); FModelBBoxMax.WriteLn(); FModelCenter.WriteLn(); 

Stream.ReadBuffer(CountOfIndexes,SizeOf(CountOfIndexes)); WriteLn(CountOfIndexes);
SetLength(Indexes,CountOfIndexes);
Stream.ReadBuffer(Indexes[0],(CountOfIndexes * SizeOf(Indexes[0])) div 3);

Stream.ReadBuffer(CountOfVertexes,SizeOf(CountOfVertexes));WriteLn(CountOfVertexes); WriteLn(' -- ',CountOfVertexes * (6 * SizeOf(SIngle)) + SizeOf(CountOfVertexes) + SizeOf(CountOfIndexes) + ((CountOfIndexes * SizeOf(Indexes[0])) div 3) + SizeOf(FModelBBoxMax)*2);
FModel.Vertexes   := CountOfVertexes;
Stream.ReadBuffer(FModel.GetArVertexes()^, CountOfVertexes * (6 * SizeOf(SIngle)));

Stream.Destroy();

FModel.AutoSetIndexFormat(0,CountOfVertexes);
FModel.SetFaceLength(0,CountOfIndexes div 3);
for i := 0 to (CountOfIndexes div 3) - 1 do
	FModel.SetFaceTriangle(0,i,Indexes[i][0],Indexes[i][1],Indexes[i][2]);
SetLength(Indexes, 0);

FModel.LoadToVBO();
end;

class function TSGExample14.ClassName():TSGString;
begin
Result := 'Shadow Mapping';
end;

constructor TSGExample14.Create(const VContext : TSGContext);
begin
inherited Create(VContext);
FCamera:=TSGCamera.Create();
FCamera.Context := Context;

LoadModel(SGExamplesDirectory + Slash + '14' + Slash + 'model.bin');
end;

destructor TSGExample14.Destroy();
begin
inherited;
end;

procedure TSGExample14.Draw();
begin
FCamera.CallAction();
Render.Color4f(1,1,1,1);
Render.PushMatrix();
Render.Scale(0.05,0.05,0.05);
FModel.Draw();
Render.PopMatrix();
end;

{$IFNDEF ENGINE}
	begin
	ExampleClass := TSGExample14;
	RunApplication();
	end.
{$ELSE}
	end.
	{$ENDIF}
