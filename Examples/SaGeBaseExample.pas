{$INCLUDE SaGe.inc}

unit SaGeBaseExample;

interface

uses
	crt
	,SaGeBase
	{$IFDEF MSWINDOWS}
		,Windows
		,SaGeRenderDirectX
		,SaGeContextWinAPI
	{$ENDIF}
	{$IFDEF LINUX}
		,SaGeContextLinux
		{$ENDIF}
	,dos
	,Classes
	,SysUtils
	,SaGeContext
	,SaGeCommon
	,SaGeFractals
	,SaGeUtils
	,SaGeScreen
	,SaGeCommonUtils
	,SaGeMesh
	,SaGeMath
	,SaGeExamples
	,SaGeFPCToC
	,SaGeNet
	,SaGeGeneticalAlgoritm
	,SaGeRender
	,SaGeRenderOpenGL
	,SaGeModel
	,SaGeTron
	,SaGeLoading
	,SaGeImages
	;

var
	ExampleClass : TSGDrawClassClass = nil;

procedure RunApplication();

implementation

var
	DrawClass : TSGDrawClass = nil;

procedure Draw(const Context:TSGContext);
begin
if DrawClass<>nil then
	DrawClass.Draw();
if Context.KeyPressed and (Context.KeyPressedChar=#27) then
	Context.Close();
end;

procedure Init(const MyContext:TSGContext);
begin
if ExampleClass<>nil then
	DrawClass:=ExampleClass.Create(MyContext);
end;

procedure GoGUI(const Prt:string = '');
var
	Context:TSGContext = nil;
var
	NewContext:TSGContext;
var //for cmd
	S:TSGString;
	i:TSGLongWord;
	{$IFDEF MSWINDOWS}
		FRenderState:(SGBR_OPENGL,SGBR_DIRECTX,SGBR_UNKNOWN) = SGBR_OPENGL;
		{$ENDIF}
	FGoToExit:TSGBoolean = False;
	VFullscreen:TSGBoolean = False;
begin
if (Prt='CMD') and (argc>2) then
	begin
	for i:=2 to argc-1 do
		if argv[i][0]='-' then
			begin
			S:=SGGetComand(SGStringToPChar(argv[i]));
			if (S='HELP') or (S='H') then
				begin
				WriteLn('Whis is help for funning GUI.');
				WriteLn('     -H; -HELP       : for run help');
				{$IFDEF MSWINDOWS}
					WriteLn('     -OPENGL         : for set prioritet render "OpenGL"');
					WriteLn('     -DIRECTX        : for set prioritet render "DirectX"');
					{$ENDIF}
				WriteLn('     -F; -FULLSCREEN : for change fullscreen');
				FGoToExit:=True;
				Break;
				end
			{$IFDEF MSWINDOWS}
				else if (S='OGL') or (S='OPENGL') then
					begin
					WriteLn('Set prioritet render : "OpenGL"');
					FRenderState:=SGBR_OPENGL;
					end
				else if (S='D3DX') or (S='DIRECT3D')or (S='DIRECTX')or (S='DIRECT3DX') then
					begin
					WriteLn('Set prioritet render : "DirectX"');
					FRenderState:=SGBR_DIRECTX;
					end
				{$ENDIF}
			else if (S='F') or (S='FULLSCREEN') then
				begin
				VFullscreen:=not VFullscreen;
				WriteLn('Set fullscreen : "',VFullscreen,'"');
				end
			else
				begin
				WriteLn('Unknown comand "',S,'"!');
				end;
			end
		else
			WriteLn('Unknown comand "',argv[i],'"!');
	end;

if FGoToExit then
	Exit;

Context:=
	{$IFDEF MSWINDOWS}TSGContextWinAPI {$ENDIF}
	{$IFDEF LINUX}    TSGContextLinux  {$ENDIF}
	.Create();
	
with Context do
	begin
	Width:=GetScreenResolution.x;
	Height:=GetScreenResolution.y;
	Fullscreen:=VFullscreen;
	
	if (ExampleClass = nil) or (ExampleClass.ClassName()=TSGDrawClass.ClassName()) then
		Tittle:='An Example'
	else
		Tittle:=ExampleClass.ClassName();
	
	DrawProcedure:=TSGContextProcedure(@Draw);
	InitializeProcedure:=TSGContextProcedure(@Init);
	
	IconIdentifier:=5;
	CursorIdentifier:=5;
	
	SelfPoint:=@Context;
	{$IFDEF MSWINDOWS}
		if FRenderState=SGBR_DIRECTX then
			RenderClass:=TSGRenderDirectX
		else
		{$ENDIF}
			RenderClass:=TSGRenderOpenGL;
	
	{$IFDEF MSWINDOWS}
		if FRenderState=SGBR_DIRECTX then
			Tittle := Tittle + ' - SaGe - Render "DirectX 9"'
		else
			{$ENDIF}
	Tittle := Tittle + ' - SaGe - Render "OpenGL"';
	end;

Context.Initialize();

repeat

Context.Run();

if Context.Active and (Context.FNewContextType<>nil) then
	begin
	NewContext:=Context.FNewContextType.Create();
	NewContext.CopyInfo(Context);
	NewContext.FCallInitialize:=nil;
	Pointer(Context.FRender):=nil;
	Context.Destroy();
	Context:=NewContext;
	NewContext:=nil;
	Context.Initialize();
	end;

until (Context.Active = False);

Context.Destroy();
end;

procedure RunApplication();
var
	s:string;
begin
if argc>1 then
	begin
	s:=SGPCharToString(argv[1]);
	s:=SGUpCaseString(s);
	if s[1]='-' then
		begin
		s:=SGGetComand(s);
		if s='GUI' then
			begin
			GoGUI('CMD');
			end
		else if (s='H') or (s='HELP') then
			begin
			WriteLn('This is help for SaGe. You can use:');
			WriteLn('   -GUI or don''t use parametrs  : for run Grafical Interface');
			end
		else
			begin
			WriteLn('Unknown command "',s,'".');
			WriteLn('Use "-help" for help!');
			end;
		end
	else
		begin
		WriteLn('Error sintexis command "',s,'". Befor cjmand must be simbol "-".');
		WriteLn('Use "-help" for help!');
		end;
	end
else
	GoGUI();
end;

end.
