{$INCLUDE Smooth.inc}
{$IFDEF ENGINE}
	unit Ex4_1;
	interface
{$ELSE}
	program Example4_1;
	{$ENDIF}
uses
	{$IF defined(UNIX) and (not defined(ANDROID)) and (not defined(ENGINE))}
		cthreads,
		{$ENDIF}
	 SmoothContextInterface
	,SmoothContextClasses
	,SmoothBase
	,SmoothRenderBase
	,SmoothFont
	,SmoothScreen
	,SmoothCommonStructs
	,SmoothCamera
	{$IF not defined(ENGINE)}
		,SmoothConsolePaintableTools
		,SmoothConsoleHandler
		{$ENDIF}
	;
type
	TSExample4_1=class(TSPaintableObject)
			public
		constructor Create(const VContext : ISContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSString;override;
			private
		FCamera : TSCamera;
		FBuffer : LongWord;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSExample4_1.ClassName():TSString;
begin
Result := '����� ���������������� �������� � VBO';
end;

constructor TSExample4_1.Create(const VContext : ISContext);
var
	i:TSByte;
	FArray  : packed array of 
		packed record
			FVertex:TSVertex3f;
			FColor:TSColor4b;
			end;
begin
inherited Create(VContext);
FCamera:=TSCamera.Create();
FCamera.SetContext(Context);
FBuffer:=0;
SetLength(FArray,36);

// ������ �������, ��������� �� 2x �������������
i:=0;
FArray[i+0].FVertex.Import(1,1,1);
FArray[i+0].FColor .Import(255,255,255,255);
FArray[i+1].FVertex.Import(1,1,-1);
FArray[i+1].FColor .Import(255,255,0,255);
FArray[i+2].FVertex.Import(1,-1,-1);
FArray[i+2].FColor .Import(255,0,255,255);
FArray[i+3].FVertex.Import(1,-1,1);
FArray[i+3].FColor .Import(0,255,255,255);
FArray[i+4]:=FArray[i+0];
FArray[i+5]:=FArray[i+2];

// ������ �������
i+=6;
FArray[i+0]:=FArray[0];
FArray[i+1]:=FArray[3];
FArray[i+2].FVertex.Import(-1,-1,1);
FArray[i+2].FColor .Import(255,0,0,255);
FArray[i+3].FVertex.Import(-1,1,1);
FArray[i+3].FColor .Import(0,0,255,255);
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
FArray[i+2].FColor .Import(0,255,0,255);
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

// � DirectX ����� ������������ ����� � ������� UNSIGNED_BYTE ��� (b;g;r;a).
// � � OpenGL ����� ������������ ��� FLOAT (r;g;b) � (r;g;b;a), ��� � UNSIGNED_BYTE (r;g;b) � (r;g;b;a).
// � ����������, ��� ����� � ������� ����� �������� �������. ������� �� �� ������ �������.
// ��� ������� ���� �������� ���������� ����� TSMesh, ������ ��� ������ ��� ��� ��������, 
//   � ������������ ������ � ������� ��������� ������ ����� ����������.
if Render.RenderType=SRenderOpenGL then
	for i:=Low(FArray) to High(FArray) do
		FArray[i].FColor.ConvertType();

Render.GenBuffersARB(1,@FBuffer);
Render.BindBufferARB(SR_ARRAY_BUFFER_ARB,FBuffer);
Render.BufferDataARB(SR_ARRAY_BUFFER_ARB,Length(FArray)*(SizeOf(TSVertex3f)+SizeOf(TSColor4b)),@FArray[0], SR_STATIC_DRAW_ARB);
Render.BindBufferARB(SR_ARRAY_BUFFER_ARB,0);

SetLength(FArray,0);
end;

destructor TSExample4_1.Destroy();
begin
Render.DeleteBuffersARB(1,@FBuffer);
inherited;
end;

procedure TSExample4_1.Paint();
begin
FCamera.CallAction();

Render.BindBufferARB(SR_ARRAY_BUFFER_ARB,FBuffer);

Render.EnableClientState(SR_VERTEX_ARRAY);
Render.EnableClientState(SR_COLOR_ARRAY);

Render.VertexPointer(3, SR_FLOAT,         SizeOf(TSVertex3f)+SizeOf(TSColor4b), nil);
Render.ColorPointer (4, SR_UNSIGNED_BYTE, SizeOf(TSVertex3f)+SizeOf(TSColor4b), Pointer(SizeOf(TSVertex3f)));

Render.DrawArrays(SR_TRIANGLES, 0, 36);

Render.DisableClientState(SR_COLOR_ARRAY);
Render.DisableClientState(SR_VERTEX_ARRAY);

Render.BindBufferARB(SR_ARRAY_BUFFER_ARB,0);
end;

{$IFNDEF ENGINE}
	begin
	SConsoleRunPaintable(TSExample4_1, SSystemParamsToConsoleHandlerParams());
	{$ENDIF}
end.
