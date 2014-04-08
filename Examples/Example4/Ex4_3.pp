{$INCLUDE SaGe.inc}
program Example4_3;
uses
	{$IFDEF UNIX}
		{$IFNDEF ANDROID}
			cthreads,
			{$ENDIF}
		{$ENDIF}
	SaGeContext
	,SaGeBased
	,SaGeBase
	,SaGeRender
	,SaGeBaseExample
	,SaGeUtils
	,SaGeScreen
	,SaGeCommon
	;
type
	TSGExample=class(TSGDrawClass)
			public
		constructor Create(const VContext : TSGContext);override;
		destructor Destroy();override;
		procedure Draw();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		FBufferArray:LongWord;
		FBufferIndexes:LongWord;
		end;

class function TSGExample.ClassName():TSGString;
begin
Result := '����� �������������� �������� � VBO';
end;

constructor TSGExample.Create(const VContext : TSGContext);
var
	FArray  : packed array of 
		packed record
			FVertex:TSGVertex3f;
			FColor:TSGColor4b;
			end;
	FIndexes:packed array of
		TSGWord;
	i : TSGByte;
begin
inherited Create(VContext);
FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);

FBufferArray:=0;
FBufferIndexes:=0;

SetLength(FArray,8);
SetLength(FIndexes,36);

FArray[0].FVertex.Import(1,1,1);
FArray[0].FColor .Import(255,255,255);
FArray[1].FVertex.Import(1,1,-1);
FArray[1].FColor .Import(255,255,0);
FArray[2].FVertex.Import(1,-1,-1);
FArray[2].FColor .Import(255,0,255);
FArray[3].FVertex.Import(1,-1,1);
FArray[3].FColor .Import(0,255,255);
FArray[4].FVertex.Import(-1,-1,1);
FArray[4].FColor .Import(255,0,0);
FArray[5].FVertex.Import(-1,1,1);
FArray[5].FColor .Import(0,0,255);
FArray[6].FVertex.Import(-1,-1,-1);
FArray[6].FColor .Import(0,0,0);
FArray[7].FVertex.Import(-1,1,-1);
FArray[7].FColor .Import(0,255,0);

// ������ �������, ��������� �� 2x �������������
i:=0;
FIndexes[i+0]:=0;
FIndexes[i+1]:=1;
FIndexes[i+2]:=2;
FIndexes[i+3]:=3;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// ������ �������
i+=6;
FIndexes[i+0]:=0;
FIndexes[i+1]:=3;
FIndexes[i+2]:=4;
FIndexes[i+3]:=5;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// ������ �������
i+=6;
FIndexes[i+0]:=3;
FIndexes[i+1]:=2;
FIndexes[i+2]:=6;
FIndexes[i+3]:=4;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// ��������� �������
i+=6;
FIndexes[i+0]:=0;
FIndexes[i+1]:=5;
FIndexes[i+2]:=7;
FIndexes[i+3]:=1;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// ����� �������
i+=6;
FIndexes[i+0]:=5;
FIndexes[i+1]:=7;
FIndexes[i+2]:=6;
FIndexes[i+3]:=4;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// ������ �������
i+=6;
FIndexes[i+0]:=1;
FIndexes[i+1]:=2;
FIndexes[i+2]:=6;
FIndexes[i+3]:=7;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// � ��� ��� � ��� ���������. 
// ���� � ���, ��� � DirectX ����� ������������ ����� � ������� UNSIGNED_BYTE ��� (b;g;r;a).
// � � OpenGL ����� ������������ ��� FLOAT (r;g;b) � (r;g;b;a), ��� � UNSIGNED_BYTE (r;g;b) � (r;g;b;a).
// � ����������, ��� ����� � ������� ����� �������� �������. ������� �� �� ������ �������.
// ��� ������� ���� �������� ���������� ����� TSGMesh, ������ ��� ������ ��� ��� ��������, 
//   � ������������ ������ � ������� ��������� ������ ����� ����������.
if Render.RenderType=SGRenderOpenGL then
	for i:=Low(FArray) to High(FArray) do
		FArray[i].FColor.ConvertType();

Render.GenBuffersARB(1,@FBufferArray);
Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,FBufferArray);
Render.BufferDataARB(SGR_ARRAY_BUFFER_ARB,Length(FArray)*(SizeOf(TSGVertex3f)+SizeOf(TSGColor4b)),@FArray[0], SGR_STATIC_DRAW_ARB);
Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,0);

Render.GenBuffersARB(1,@FBufferIndexes);
Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB,FBufferIndexes);
Render.BufferDataARB(SGR_ELEMENT_ARRAY_BUFFER_ARB,Length(FIndexes)*SizeOf(TSGWord),@FIndexes[0], SGR_STATIC_DRAW_ARB);
Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB,0);

SetLength(FIndexes,0);
SetLength(FArray,0);
end;

destructor TSGExample.Destroy();
begin
Render.DeleteBuffersARB(1,@FBufferArray);
Render.DeleteBuffersARB(1,@FBufferIndexes);
inherited;
end;

procedure TSGExample.Draw();
begin
FCamera.CallAction();

Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,FBufferArray);

Render.EnableClientState(SGR_VERTEX_ARRAY);
Render.EnableClientState(SGR_COLOR_ARRAY);

Render.VertexPointer(3, SGR_FLOAT,         SizeOf(TSGVertex3f)+SizeOf(TSGColor4b), Pointer(0));
Render.ColorPointer (4, SGR_UNSIGNED_BYTE, SizeOf(TSGVertex3f)+SizeOf(TSGColor4b), Pointer(SizeOf(TSGVertex3f)));

Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB,FBufferIndexes);
Render.DrawElements(SGR_TRIANGLES, 36, SGR_UNSIGNED_SHORT, nil);

Render.DisableClientState(SGR_COLOR_ARRAY);
Render.DisableClientState(SGR_VERTEX_ARRAY);

Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,         0);
Render.BindBufferARB(SGR_ELEMENT_ARRAY_BUFFER_ARB, 0);
end;

begin
ExampleClass := TSGExample;
RunApplication();
end.