{$INCLUDE SaGe.inc}
{$IFDEF ENGINE}
	unit Ex4_3;
	interface
{$ELSE}
	program Example4_3;
	{$ENDIF}
uses
	{$IF defined(UNIX) and (not defined(ANDROID)) and (not defined(ENGINE))}
		cthreads,
		{$ENDIF}
	 SaGeContextInterface
	,SaGeContextClasses
	,SaGeBase
	,SaGeRenderBase
	,SaGeFont
	,SaGeScreen
	,SaGeCommonStructs
	,SaGeCamera
	{$IF not defined(ENGINE)}
		,SaGeConsolePaintableTools
		,SaGeConsoleCaller
		{$ENDIF}
	;
type
	TSGExample4_3 = class(TSGPaintableObject)
			public
		constructor Create(const VContext : ISGContext);override;
		destructor Destroy();override;
		procedure Paint();override;
		class function ClassName():TSGString;override;
			private
		FCamera : TSGCamera;
		FBufferArray:LongWord;
		FBufferIndexes:LongWord;
		end;

{$IFDEF ENGINE}
	implementation
	{$ENDIF}

class function TSGExample4_3.ClassName():TSGString;
begin
Result := 'Вывод индексированым массивом с VBO';
end;

constructor TSGExample4_3.Create(const VContext : ISGContext);
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
FArray[0].FColor .Import(255,255,255,255);
FArray[1].FVertex.Import(1,1,-1);
FArray[1].FColor .Import(255,255,0,255);
FArray[2].FVertex.Import(1,-1,-1);
FArray[2].FColor .Import(255,0,255,255);
FArray[3].FVertex.Import(1,-1,1);
FArray[3].FColor .Import(0,255,255,255);
FArray[4].FVertex.Import(-1,-1,1);
FArray[4].FColor .Import(255,0,0,255);
FArray[5].FVertex.Import(-1,1,1);
FArray[5].FColor .Import(0,0,255,255);
FArray[6].FVertex.Import(-1,-1,-1);
FArray[6].FColor .Import(0,0,0,255);
FArray[7].FVertex.Import(-1,1,-1);
FArray[7].FColor .Import(0,255,0,255);

// Первый квадрат, состоящий из 2x треугольников
i:=0;
FIndexes[i+0]:=0;
FIndexes[i+1]:=1;
FIndexes[i+2]:=2;
FIndexes[i+3]:=3;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// Второй квадрат
i+=6;
FIndexes[i+0]:=0;
FIndexes[i+1]:=3;
FIndexes[i+2]:=4;
FIndexes[i+3]:=5;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// Третий квадрат
i+=6;
FIndexes[i+0]:=3;
FIndexes[i+1]:=2;
FIndexes[i+2]:=6;
FIndexes[i+3]:=4;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// Четвертый квадрат
i+=6;
FIndexes[i+0]:=0;
FIndexes[i+1]:=5;
FIndexes[i+2]:=7;
FIndexes[i+3]:=1;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// Пятый квадрат
i+=6;
FIndexes[i+0]:=5;
FIndexes[i+1]:=7;
FIndexes[i+2]:=6;
FIndexes[i+3]:=4;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// Шестой квадрат
i+=6;
FIndexes[i+0]:=1;
FIndexes[i+1]:=2;
FIndexes[i+2]:=6;
FIndexes[i+3]:=7;
FIndexes[i+4]:=FIndexes[i+0];
FIndexes[i+5]:=FIndexes[i+2];

// А вод тут у нас проблемка. 
// Дело в том, что в DirectX можно использовать цвета в формате UNSIGNED_BYTE как (b;g;r;a).
// А в OpenGL можно использовать как FLOAT (r;g;b) и (r;g;b;a), так и UNSIGNED_BYTE (r;g;b) и (r;g;b;a).
// И получается, что синий и красный цвета меняются местами. Поэтому мы их меняем обратно.
// Для решения этой проблемы реализован класс TSGMesh, которы сам делает все эти операции, 
//   и поддерживает работу с разными форматами цветов одной процедурой.
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

destructor TSGExample4_3.Destroy();
begin
Render.DeleteBuffersARB(1,@FBufferArray);
Render.DeleteBuffersARB(1,@FBufferIndexes);
inherited;
end;

procedure TSGExample4_3.Paint();
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

{$IFNDEF ENGINE}
	begin
	SGConsoleRunPaintable(TSGExample4_3, SGSystemParamsToConcoleCallerParams());
	{$ENDIF}
end.
