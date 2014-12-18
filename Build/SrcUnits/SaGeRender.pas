{$INCLUDE Includes\SaGe.inc}

unit SaGeRender;

interface

uses 
	 SaGeBase
	,SaGeBased;

// ��� ���������� � ����� ��������� ���������,���� SGR_TRIANGLES
{$INCLUDE Includes\SaGeRenderConstants.inc}

const
	TSGRenderFar = 10000;
	TSGRenderNear = 0.001;
type
	TSGMatrixMode   = TSGLongWord;
	TSGPrimtiveType = TSGLongWord;
	// ��� �� ���� ��������, ������� ����, ������ ��������������
	TSGRenderType   = (SGRenderNone,SGRenderOpenGL,SGRenderDirectX,SGRenderGLES);
	TSGRender       = class;
	// ��� ������ �������
	TSGRenderClass  = class of TSGRender;
	// ����� �������
	TSGRender = class(TSGClass)
			public
		// �����������
		constructor Create();override;
		// ����������
		destructor Destroy();override;
		function Width():TSGLongWord;inline;
		function Height():TSGLongWord;inline;
			protected
		// ��� ���������� ����, ��� ��� �� ������ �����..
		FType   : TSGRenderType;
		// ��� ��� ��������� ������ ���������
		FWindow : TSGClass;
			public
		// ���������� ��� �������
		property RenderType : TSGRenderType read FType;
		// ��� ���������� �������� ��������� ������ ��������� ��� ��� �������������
		// ��� ������������� ������ �������� � ���� ��� ����� �������
		function SetPixelFormat():TSGBoolean;virtual;abstract;overload;
		// ��������� ���� � �������� OpenGL ��� DirectX
		function MakeCurrent():TSGBoolean;virtual;
		// ����������� ����� ����� ����� � �������� OpenGL ��� DirectX
		procedure ReleaseCurrent();virtual;abstract;
		// ��������� �������� ����������. ���������� ������� �� ��� ��� �������, ��� ���.
		function CreateContext():TSGBoolean;virtual;abstract;
		// ������������� ������� ��������� �� ����
		procedure Viewport(const a,b,c,d:TSGLongWord);virtual;abstract;
		// �������������� ������
		procedure Init();virtual;abstract;
		// ����������, ����� �� ��������� � ������ �� �������� ������, ������� ����� ���������� �� ������
		function SupporedVBOBuffers():TSGBoolean;virtual;
		// ������� �� ����� �����
		procedure SwapBuffers();virtual;abstract;
		// ������� ������� ������������� ����� ���� ������� ����, �� ����� ���� ��������. 
		// ��� ������� ���������� �� ������� �������� ��� �������.
		function TopShift(const VFullscreen:TSGBoolean = False):TSGLongWord;virtual;
		// �������� ��������� ���� �� ����, ��� ��� ��� ��������� �� ����
		procedure MouseShift(Var x,y:TSGLongInt; const VFullscreen:TSGBoolean = False);virtual;
		// ���������� �������� ������� � �������� ������ �������
		procedure LockResourses();virtual;
		// ������������� ������� � �������� ����������� ��������
		procedure UnLockResourses();virtual;
			public
		// ������������� 2D ������������� �������� ����� ����� ������� ������ (������ ����� � ������� ������)
		procedure InitOrtho2d(const x0,y0,x1,y1:TSGSingle);virtual;abstract;
		// ������������� ����� ������� ��������
		procedure InitMatrixMode(const Mode:TSGMatrixMode = SG_3D; const dncht:TSGReal = 1);virtual;abstract;
		//��� ������ glBegin\glEnd
		procedure BeginScene(const VPrimitiveType:TSGPrimtiveType);virtual;abstract;
		procedure EndScene();virtual;abstract;
		// ��� ��������� ������� ��� - ������� ����� ������� � OpenGL, �� ����������� ��������.
		procedure LoadIdentity();virtual;abstract;
		procedure Vertex3f(const x,y,z:TSGSingle);virtual;abstract;
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
		procedure TexImage2D(const VTextureType:TSGCardinal;const VP1:TSGCardinal;const VChannels,VWidth,VHeight,VP2,VFormatType,VDataType:TSGCardinal;var VBitMap:TSGPointer);virtual;abstract;
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
			public
		property Window : TSGClass read FWindow write FWindow;
		end;

implementation

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
