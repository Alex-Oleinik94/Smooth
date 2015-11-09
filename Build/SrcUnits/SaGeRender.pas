{$INCLUDE Includes\SaGe.inc}

unit SaGeRender;

interface

uses 
	 SaGeBase
	,SaGeBased;

// Это включаются в текст программы константы,типа SGR_TRIANGLES
{$INCLUDE Includes\SaGeRenderConstants.inc}

const
	TSGRenderFar = 10000;
	TSGRenderNear = 0.001;
type
	TSGRPInteger = ^ integer;
	
	TSGMatrixMode   = TSGLongWord;
	TSGPrimtiveType = TSGLongWord;
	// Это те виды рендеров, которые есть, точнее идентификаторы
	TSGRenderType   = (SGRenderNone,SGRenderOpenGL,SGRenderDirectX,SGRenderGLES);
	TSGRender       = class;
	// Тип класса рендера
	TSGRenderClass  = class of TSGRender;
	// Класс рендера
	TSGRender = class(TSGClass)
			public
		// Конструктор
		constructor Create();override;
		// Деструктор
		destructor Destroy();override;
		function Width():TSGLongWord;inline;
		function Height():TSGLongWord;inline;
			protected
		// Тут содержится инфа, что это за рендер такой..
		FType   : TSGRenderType;
		// Это наш экземпляр класса контекста
		FWindow : TSGClass;
			public
		// Возвращает тип рендера
		property RenderType : TSGRenderType read FType;
		// Эту процедурку вызывает экземпляр класса контерста при его инициазизации
		// Она устанавливает формат пикселов в окне для этого рендера
		function SetPixelFormat():TSGBoolean;virtual;abstract;overload;
		// Связывает окно с рендером OpenGL или DirectX
		function MakeCurrent():TSGBoolean;virtual;
		// Разрывается связь между окном и рендером OpenGL или DirectX
		procedure ReleaseCurrent();virtual;abstract;
		// Открывает контекст устройства. Возвращает удалось ли ему это сделать, или нет.
		function CreateContext():TSGBoolean;virtual;abstract;
		// Устанавливает граници рисования на окне
		procedure Viewport(const a,b,c,d:TSGLongWord);virtual;abstract;
		// Инициализирует рендер
		procedure Init();virtual;abstract;
		// Возвращает, можно ли отправить в видуху на хранение данные, которые нужно отобразить на экране
		function SupporedVBOBuffers():TSGBoolean;virtual;
		// Выводит на экран буфер
		procedure SwapBuffers();virtual;abstract;
		// Верхная граница отрисовывания может быть смещена вниз, по каким либо причинам. 
		// Эта функция возвращает на скользо пекселов она смещена.
		function TopShift(const VFullscreen:TSGBoolean = False):TSGLongWord;virtual;
		// Смещение указателя мышы от того, тна что она указывает на окне
		procedure MouseShift(Var x,y:TSGLongInt; const VFullscreen:TSGBoolean = False);virtual;
		// Сохранения ресурсов рендера и убивание самого рендера
		procedure LockResourses();virtual;
		// Инициализация рендера и загрузка сохраненных ресурсов
		procedure UnLockResourses();virtual;
			public
		// Устанавливает 2D отроганальную проэкцию между двумя точками экрана (нижней левой и верхней правой)
		procedure InitOrtho2d(const x0,y0,x1,y1:TSGSingle);virtual;abstract;
		// Устанавливает режим матрици проэкции
		procedure InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht:TSGReal = 1);virtual;abstract;
		//Это аналог glBegin\glEnd
		procedure BeginScene(const VPrimitiveType:TSGPrimtiveType);virtual;abstract;
		procedure EndScene();virtual;abstract;
		// Все остальные функции тут - аналоги своих функций в OpenGL, за исклбчением немногих.
		procedure Perspective(const vAngle,vAspectRatio,vNear,vFar : TSGFloat);virtual;abstract;
		procedure LoadIdentity();virtual;abstract;
		procedure ClearColor(const r,g,b,a : TSGFloat);virtual;abstract;
		procedure Vertex3f(const x,y,z:TSGSingle);virtual;abstract;
		procedure Scale(const x,y,z : TSGSingle);virtual;abstract;
		procedure Color3f(const r,g,b:TSGSingle);virtual;abstract;
		procedure TexCoord2f(const x,y:TSGSingle);virtual;abstract;
		procedure Vertex2f(const x,y:TSGSingle);virtual;abstract;
		procedure Color4f(const r,g,b,a:TSGSingle);virtual;abstract;
		procedure Normal3f(const x,y,z:TSGSingle);virtual;abstract;
		procedure Translatef(const x,y,z:TSGSingle);virtual;abstract;
		procedure Rotatef(const angle:TSGSingle;const x,y,z:TSGSingle);virtual;abstract;
		procedure Enable(VParam:TSGCardinal);virtual;
		procedure Disable(const VParam:TSGCardinal);virtual;abstract;
		procedure DeleteTextures(const VQuantity:TSGCardinal;const VTextures:PSGUInt);virtual;abstract;
		procedure Lightfv(const VLight,VParam:TSGCardinal;const VParam2:TSGPointer);virtual;abstract;
		procedure GenTextures(const VQuantity:TSGCardinal;const VTextures:PSGUInt);virtual;abstract;
		procedure BindTexture(const VParam:TSGCardinal;const VTexture:TSGCardinal);virtual;abstract;
		procedure TexParameteri(const VP1,VP2,VP3:TSGCardinal);virtual;abstract;
		procedure PixelStorei(const VParamName:TSGCardinal;const VParam:SGInt);virtual;abstract;
		procedure TexEnvi(const VP1,VP2,VP3:TSGCardinal);virtual;abstract;
		procedure TexImage2D(const VTextureType:TSGCardinal;const VP1:TSGCardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:TSGCardinal;VBitMap:TSGPointer);virtual;abstract;
		procedure ReadPixels(const x,y:TSGInteger;const Vwidth,Vheight:TSGInteger;const format, atype: TSGCardinal;const pixels: TSGPointer);virtual;abstract;
		procedure CullFace(const VParam:TSGCardinal);virtual;abstract;
		procedure EnableClientState(const VParam:TSGCardinal);virtual;abstract;
		procedure DisableClientState(const VParam:TSGCardinal);virtual;abstract;
		procedure GenBuffersARB(const VQ:TSGInteger;const PT:PCardinal);virtual;abstract;
		procedure DeleteBuffersARB(const VQuantity:TSGLongWord;VPoint:TSGPointer);virtual;abstract;
		procedure BindBufferARB(const VParam:TSGCardinal;const VParam2:TSGCardinal);virtual;abstract;
		procedure BufferDataARB(const VParam:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer;const VParam2:TSGCardinal;const VIndexPrimetiveType : TSGLongWord = 0);virtual;abstract;
		procedure DrawElements(const VParam:TSGCardinal;const VSize:TSGInt64;const VParam2:TSGCardinal;VBuffer:TSGPointer);virtual;abstract;
		procedure ColorPointer(const VQChannels:TSGLongWord;const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);virtual;abstract;
		procedure TexCoordPointer(const VQChannels:TSGLongWord;const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);virtual;abstract;
		procedure NormalPointer(const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);virtual;abstract;
		procedure VertexPointer(const VQChannels:TSGLongWord;const VType:TSGCardinal;const VSize:TSGInt64;VBuffer:TSGPointer);virtual;abstract;
		function IsEnabled(const VParam:TSGCardinal):Boolean;virtual;abstract;
		procedure Clear(const VParam:TSGCardinal);virtual;abstract;
		procedure LineWidth(const VLW:TSGSingle);virtual;abstract;
		procedure PointSize(const PS:Single);virtual;abstract;
		procedure PopMatrix();virtual;abstract;
		procedure PushMatrix();virtual;abstract;
		procedure DrawArrays(const VParam:TSGCardinal;const VFirst,VCount:TSGLongWord);virtual;abstract;
		procedure Vertex3fv(const Variable : TSGPointer);virtual;abstract;
		procedure Normal3fv(const Variable : TSGPointer);virtual;abstract;
		procedure MultMatrixf(const Variable : TSGPointer);virtual;abstract;
		procedure ColorMaterial(const r,g,b,a:TSGSingle);virtual;abstract;
		procedure MatrixMode(const Par:TSGLongWord);virtual;abstract;
		procedure LoadMatrixf(const Variable : TSGPointer);virtual;abstract;
		procedure ClientActiveTexture(const VTexture : TSGLongWord);virtual;abstract;
		procedure ActiveTexture(const VTexture : TSGLongWord);virtual;abstract;
		procedure ActiveTextureDiffuse();virtual;abstract;
		procedure ActiveTextureBump();virtual;abstract;
		procedure BeginBumpMapping(const Point : Pointer );virtual;abstract;
		procedure EndBumpMapping();virtual;abstract;
		{$IFDEF MOBILE}
			procedure GenerateMipmap(const Param : TSGCardinal);virtual;
		{$ELSE}
			procedure GetVertexUnderPixel(const px,py : LongWord; out x,y,z : Real);virtual;abstract;
			{$ENDIF}
		
			(* Shaders *)
		function SupporedShaders() : TSGBoolean;virtual;abstract;
		function CreateShader(const VShaderType : TSGCardinal):TSGLongWord;virtual;abstract;
		procedure ShaderSource(const VShader : TSGLongWord; VSourse : PChar; VSourseLength : integer);virtual;abstract;
		procedure CompileShader(const VShader : TSGLongWord);virtual;abstract;
		procedure GetObjectParameteriv(const VObject : TSGLongWord; const VParamName : TSGCardinal; const VResult : TSGRPInteger);virtual;abstract;
		procedure GetInfoLog(const VHandle : TSGLongWord; const VMaxLength : TSGInteger; var VLength : TSGInteger; VLog : PChar);virtual;abstract;
		procedure DeleteShader(const VProgram : TSGLongWord);virtual;abstract;
		
		function CreateShaderProgram() : TSGLongWord;virtual;abstract;
		procedure AttachShader(const VProgram, VShader : TSGLongWord);virtual;abstract;
		procedure LinkShaderProgram(const VProgram : TSGLongWord);virtual;abstract;
		procedure DeleteShaderProgram(const VProgram : TSGLongWord);virtual;abstract;
		
		function GetUniformLocation(const VProgram : TSGLongWord; const VLocationName : PChar): TSGLongWord;virtual;abstract;
		procedure Uniform1i(const VLocationName : TSGLongWord; const VData:TSGLongWord);virtual;abstract;
		procedure UseProgram(const VProgram : TSGLongWord);virtual;abstract;
		procedure UniformMatrix4fv(const VLocationName : TSGLongWord; const VCount : TSGLongWord; const VTranspose : TSGBoolean; const VData : TSGPointer);virtual;abstract;
		procedure Uniform3f(const VLocationName : TSGLongWord; const VX,VY,VZ : TSGFloat);virtual;abstract;
		
		function SupporedDepthTextures():TSGBoolean;virtual;
		procedure BindFrameBuffer(const VType : TSGCardinal; const VHandle : TSGLongWord);virtual;abstract;
		procedure GenFrameBuffers(const VCount : TSGLongWord;const VBuffers : PCardinal); virtual;abstract;
		procedure DrawBuffer(const VType : TSGCardinal);virtual;abstract;
		procedure ReadBuffer(const VType : TSGCardinal);virtual;abstract;
		procedure GenRenderBuffers(const VCount : TSGLongWord;const VBuffers : PCardinal); virtual;abstract;
		procedure BindRenderBuffer(const VType : TSGCardinal; const VHandle : TSGLongWord);virtual;abstract;
		procedure FrameBufferTexture2D(const VTarget: TSGCardinal; const VAttachment: TSGCardinal; const VRenderbuffertarget: TSGCardinal; const VRenderbuffer, VLevel: TSGLongWord);virtual;abstract;
		procedure FrameBufferRenderBuffer(const VTarget: TSGCardinal; const VAttachment: TSGCardinal; const VRenderbuffertarget: TSGCardinal; const VRenderbuffer: TSGLongWord);virtual;abstract;
		procedure RenderBufferStorage(const VTarget, VAttachment: TSGCardinal; const VWidth, VHeight: TSGLongWord);virtual;abstract;
		procedure GetFloatv(const VType : TSGCardinal; const VPointer : Pointer);virtual;abstract;
			public
		property Window : TSGClass read FWindow write FWindow;
		end;

implementation

function TSGRender.SupporedDepthTextures():TSGBoolean;
begin
Result := False;
end;

{$IFDEF MOBILE}
procedure TSGRender.GenerateMipmap(const Param : TSGCardinal);
begin
end;
{$ENDIF}

procedure TSGRender.UnLockResourses();
begin
end;

procedure TSGRender.LockResourses();
begin
end;

procedure TSGRender.MouseShift(Var x,y:LongInt; const VFullscreen:Boolean = False);
begin
x:=0;
y:=0;
end;

function TSGRender.TopShift(const VFullscreen:Boolean = False):LongWord;
begin
Result:=0;
end;

function TSGRender.MakeCurrent():Boolean;
begin
SGLog.Sourse('TSGRender__MakeCurrent() : Error : Call inherited method!!');
end;

procedure TSGRender.Enable(VParam:Cardinal);
begin 
SGLog.Sourse('TSGRender__Enable(Cardinal) : Error : Call inherited methad!!');
end;

function TSGRender.SupporedVBOBuffers():Boolean;
begin
Result:=False;
end;

constructor TSGRender.Create();
begin
inherited Create();
FWindow:=nil;
FType:=SGRenderNone;
end;

destructor TSGRender.Destroy();
begin
SGLog.Sourse(['TSGRender__Destroy()']);
inherited Destroy();
end;

function TSGRender.Width():LongWord;inline;
begin
Result:=LongWord(FWindow.Get('WIDTH'));
end;

function TSGRender.Height():LongWord;inline;
begin
Result:=LongWord(FWindow.Get('HEIGHT'));
end;

end.
