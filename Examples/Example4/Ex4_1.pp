{$INCLUDE SaGe.inc}
program Example4_1;
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
		FBuffer : LongWord;
		end;

class function TSGExample.ClassName():TSGString;
begin
Result := '����� ���������������� �������� � VBO';
end;

constructor TSGExample.Create(const VContext : TSGContext);
var
	i:TSGByte;
	FArray  : packed array of 
		packed record
			FVertex:TSGVertex3f;
			FColor:TSGColor4b;
			end;
begin
inherited Create(VContext);
FCamera:=TSGCamera.Create();
FCamera.SetContext(Context);
FBuffer:=0;
SetLength(FArray,36);

// ������ �������, ��������� �� 2x �������������
i:=0;
FArray[i+0].FVertex.Import(1,1,1);
FArray[i+0].FColor .Import(255,255,255);
FArray[i+1].FVertex.Import(1,1,-1);
FArray[i+1].FColor .Import(255,255,0);
FArray[i+2].FVertex.Import(1,-1,-1);
FArray[i+2].FColor .Import(255,0,255);
FArray[i+3].FVertex.Import(1,-1,1);
FArray[i+3].FColor .Import(0,255,255);
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

// ������ �������
i+=6;
FArray[i+0]:=FArray[0];
FArray[i+1]:=FArray[3];
FArray[i+2].FVertex.Import(-1,-1,1);
FArray[i+2].FColor .Import(255,0,0);
FArray[i+3].FVertex.Import(-1,1,1);
FArray[i+3].FColor .Import(0,0,255);
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

// ������ �������
i+=6;
FArray[i+0]:=FArray[3];
FArray[i+1]:=FArray[2];
FArray[i+2].FVertex.Import(-1,-1,-1);
FArray[i+2].FColor .Import(0,0,0);
FArray[i+3]:=FArray[8];
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

// ��������� �������
i+=6;
FArray[i+0]:=FArray[0];
FArray[i+1]:=FArray[9];
FArray[i+2].FVertex.Import(-1,1,-1);
FArray[i+2].FColor .Import(0,255,0);
FArray[i+3]:=FArray[1];
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

// ����� �������
i+=6;
FArray[i+0]:=FArray[9];
FArray[i+1]:=FArray[3*6+2];
FArray[i+2]:=FArray[2*6+2];
FArray[i+3]:=FArray[8];
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

// ������ �������
i+=6;
FArray[i+0]:=FArray[1];
FArray[i+1]:=FArray[2];
FArray[i+2]:=FArray[2*6+2];
FArray[i+3]:=FArray[3*6+2];
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

// � ��� ��� � ��� ���������. 
// ���� � ���, ��� � DirectX ����� ������������ ����� � ������� UNSIGNED_BYTE ��� (b;g;r;a).
// � � OpenGL ����� ������������ ��� FLOAT (r;g;b) � (r;g;b;a), ��� � UNSIGNED_BYTE (r;g;b) � (r;g;b;a).
// � ����������, ��� ����� � ������� ����� �������� �������. ������� �� �� ������ �������.
// ��� ������� ���� �������� ���������� ����� TSGMesh, ������ ��� ������ ��� ��� ��������, 
//   � ������������ ������ � ������� ��������� ������ ����� ����������.
if Render.RenderType=SGRenderOpenGL then
	for i:=Low(FArray) to High(FArray) do
		FArray[i].FColor.ConvertType();

Render.GenBuffersARB(1,@FBuffer);
Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,FBuffer);
Render.BufferDataARB(SGR_ARRAY_BUFFER_ARB,Length(FArray)*(SizeOf(TSGVertex3f)+SizeOf(TSGColor4b)),@FArray[0], SGR_STATIC_DRAW_ARB);
Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,0);

SetLength(FArray,0);
end;

destructor TSGExample.Destroy();
begin
Render.DeleteBuffersARB(1,@FBuffer);
inherited;
end;

procedure TSGExample.Draw();
begin
FCamera.CallAction();

Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,FBuffer);

Render.EnableClientState(SGR_VERTEX_ARRAY);
Render.EnableClientState(SGR_COLOR_ARRAY);

Render.VertexPointer(3, SGR_FLOAT,         SizeOf(TSGVertex3f)+SizeOf(TSGColor4b), nil);
Render.ColorPointer (4, SGR_UNSIGNED_BYTE, SizeOf(TSGVertex3f)+SizeOf(TSGColor4b), Pointer(SizeOf(TSGVertex3f)));

Render.DrawArrays(SGR_TRIANGLES, 0, 36);

Render.DisableClientState(SGR_COLOR_ARRAY);
Render.DisableClientState(SGR_VERTEX_ARRAY);

Render.BindBufferARB(SGR_ARRAY_BUFFER_ARB,0);
end;

begin
ExampleClass := TSGExample;
RunApplication();
end.