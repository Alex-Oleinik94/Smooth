{$INCLUDE SrcUnits\Includes\SaGe.inc}
{$IFNDEF ANDROID}
	{$APPTYPE CONSOLE}
	//{$APPTYPE GUI}
	program Main;
	{$ENDIF}
{$IFDEF ANDROID}
	library Main;
	{$ENDIF}
uses
	{$IFDEF UNIX}
		{$IFNDEF ANDROID}
			cthreads,
			SaGeContextUnix,
			Unix,
			{$ENDIF}
		{$ENDIF}
	crt
	{$IFDEF MSWINDOWS}
		,windows
		,SaGeRenderDirectX
		,SaGeContextWinAPI
		{$ENDIF}
	,dos
	,Classes
	,SysUtils
	,SaGeContext
	,SaGeCommon
	,SaGeBase
	,SaGeFractals
	,SaGeUtils
	,SaGeScreen
	,SaGeTotal
	,SaGeMesh
	,SaGeMath
	,SaGeExamples
	//,SaGeShaders
	,SaGeFPCToC
	,SaGeNet
	,SaGeGeneticalAlgoritm
	,SaGeRender
	,SaGeRenderOpenGL
	,SaGeModel
	,SaGeTron;
	//,SaGeX264Encoder;


procedure Draw(const Context:PSGContext);
begin
end;

procedure Init(const MyContext:PSGContext);
begin
SGScreen.Font:=TSGGLFont.Create(SGGetCurrentDirectory()+'.'+Slash+'..'+Slash+'Data'+Slash+'Fonts'+Slash+'Tahoma.bmp');
SGScreen.Font.SetContext(MyContext);
SGScreen.Font.Loading;

with TSGDrawClasses.Create(MyContext) do
	begin
	Add(TSGFractalMengerSpunchRelease);
	Add(TSGFractalMandelbrodRelease);
	Add(TSGFractalKohTriangle);//Треугольник Серпинского
	Add(TSGFractalTetraider);
	Add(TSGFractalLomanaya);
	Add(TSGFractalPodkova);
	Add(TSGGraphViewer);
	Add(TSGKillKostia);
	Add(TSGGenAlg);
	
	//Add(TSGGraphic);
	//Add(TSGGraphViewer3D);
	
	//Add(TSGMeshViever);
	//Add(TSGExampleShader);
	Add(TSGGameTron);
	
	Initialize();
	end;
end;

procedure GoGUI(const Prt:string = '');
var
	Context:TSGContext = nil;
var
	NewContext:TSGContext;
var //for cmd
	S:String;
	i:longWord;
	{$IFDEF MSWINDOWS}
		FRenderState:(SGBR_OPENGL,SGBR_DIRECTX,SGBR_UNKNOWN) = SGBR_OPENGL;
		{$ENDIF}
	FGoToExit:Boolean = False;
	VFullscreen:Boolean = 
		{$IFDEF ANDROID}
			True
			{$ENDIF}
		{$IFNDEF ANDROID}
			False
			{$ENDIF};
begin
{$IFNDEF ANDROID}
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
{$ENDIF}

Context:=
{$IFDEF ANDROID}
	TSGContextAndroid
{$ELSE}
	{$IFDEF LAZARUS}
		TSGContextLazarus
	{$ELSE}
		{$IFDEF GLUT}
			TSGContextGLUT
		{$ELSE}
			{$IFDEF MSWINDOWS}TSGContextWinAPI{$ENDIF}
			{$IFDEF UNIX}     TSGContextUnix   {$ENDIF}
			{$ENDIF}
		{$ENDIF}
	{$ENDIF}
		.Create;

with Context do
	begin
	Width:=GetScreenResolution.x;
	Height:=GetScreenResolution.y;
	Fullscreen:=VFullscreen;
	
	{$IFDEF MSWINDOWS}
		if FRenderState=SGBR_DIRECTX then
			Tittle:='SaGe DirectX Window'
		else
		{$ENDIF}
			Tittle:='SaGe OpenGL Window';
		
	DrawProcedure:=TSGContextProcedure(@Draw);
	InitializeProcedure:=TSGContextProcedure(@Init);
	
	IconIdentifier:=5;
	CursorIdentifier:=5;
	
	FSelfPoint:=@Context;
	{$IFDEF MSWINDOWS}
		if FRenderState=SGBR_DIRECTX then
			RenderClass:=TSGRenderDirectX
		else
		{$ENDIF}
			RenderClass:=TSGRenderOpenGL;
	end;

Context.Initialize;

repeat

Context.Run;

if Context.Active and (Context.FNewContextType<>nil) then
	begin
	NewContext:=Context.FNewContextType.Create;
	NewContext.CopyInfo(Context);
	NewContext.FCallInitialize:=nil;
	Pointer(Context.FRender):=nil;
	Context.Destroy;
	Context:=NewContext;
	NewContext:=nil;
	Context.Initialize;
	end;

until (Context.Active = False);

Context.Destroy;
end;

{$IFDEF ANDROID}
	exports
		//ANativeActivity_onCreate name 'ANativeActivity_onCreate'//On Activate
		;
	end.
{$ELSE}
	procedure FPCTCTransliater();
	var
		SGT:SGTranslater = nil;
	begin
	SGT:=SGTranslater.Create('cmd');
	SGT.GoTranslate;
	SGT.Destroy;
	end;

	procedure GoogleReNameCache();
	var 
		Cache:string = 'Cache';
	var
		sr:DOS.SearchRec;
		f:TFileStream;
		b:word;
		razr:string;

	function IsRazr(const a:string):Boolean;
	var
		i:LongWord;
	begin
	Result:=False;
	for i:=1 to Length(a) do
		if a[i]='.' then
			begin
			Result:=True;
			Break;
			end;
	end;

	begin
	if argc>2 then
		Cache:=SGGetComand(argv[2]);
	if not SGExistsDirectory('.'+Slash+Cache) then
		begin
		WriteLn('Cashe Directory is not exists: "','.\'+Slash+Cache,'".');
		Exit;
		end;
	SGMakeDirectory('.'+Slash+Cache+Slash+'Temp');
	SGMakeDirectory('.'+Slash+Cache+Slash+'Complited');
	DOS.findfirst('.'+Slash+Cache+Slash+'f_*',$3F,sr);
	While (dos.DosError<>18) do
		begin
		if not IsRazr(sr.name) then
			begin
			razr:='';
			F:=TFileStream.Create('.'+Slash+Cache+Slash+sr.Name,fmOpenRead);
			if F.Size >=2 then
			F.ReadBuffer(b,2);
			F.Destroy;
			case b of
			22339:;//хз
			0:
				begin
				F:=TFileStream.Create('.'+Slash+Cache+Slash+sr.Name,fmOpenRead);
				if F.Size >=4 then
				F.ReadBuffer(b,2);
				F.ReadBuffer(b,2);
				F.Destroy;
				if b = 8192 then
					razr:='wmv'
				else
					begin writeln('Unknown ',sr.Name,' 0, ',b,'.');  end;
				end;
			8508,29230,35615,10799,12079,28777,10250:razr:=' ';
			20617:razr:='png';
			55551:razr:='jpg';
			17481:razr:='mp3';
			18759:razr:='gif';
			else begin writeln('Unknown ',sr.Name,' ',b,'.');  end;
			end;
			if razr=' ' then
				begin
				{$IFDEF MSWINDOWS}MoveFile{$ELSE}RenameFile{$ENDIF}(SGStringToPChar('.'+Slash+Cache+Slash+sr.Name),SGStringToPChar('.'+Slash+Cache+Slash+'Temp'+Slash+sr.Name));
				end
			else
				if razr<>'' then
					{$IFDEF MSWINDOWS}MoveFile{$ELSE}RenameFile{$ENDIF}(SGStringToPChar('.'+Slash+Cache+Slash+sr.Name),SGStringToPChar('.'+Slash+Cache+Slash+'Complited'+Slash+sr.Name+'.'+razr));
			end;
		DOS.findnext(sr);
		end;
	DOS.findclose(sr);
	end;

	var
		ViewerImage:TSGGLImage = nil;
	procedure ViewerDraw(const Context:PSGContext);
	begin
	Context^.Render.InitMatrixMode(SG_2D);
	ViewerImage.DrawImageFromTwoVertex2f(
		SGVertex2fImport(0,0),
		SGVertex2fImport(Context^.Width,Context^.Height));
	end;


	procedure GoViewer(const FileWay:String);
	var
		Context:TSGContext = nil;
	begin
	if 
	(SGGetFileExpansion(FileWay)='PNG') or
	(SGGetFileExpansion(FileWay)='JPG') or 
	(SGGetFileExpansion(FileWay)='JPEG') or 
	(SGGetFileExpansion(FileWay)='BMP') or 
	(SGGetFileExpansion(FileWay)='TGA') then
		begin
		ViewerImage:=TSGGLImage.Create();
		ViewerImage.Way:=FileWay;
		ViewerImage.LoadToMemory();
		if ViewerImage.LoadToBitMap() then
			begin
			Context:=
				   {$IFDEF MSWINDOWS}TSGContextWinAPI{$ENDIF}
				   {$IFDEF UNIX}     TSGContextUnix   {$ENDIF}
					.Create();
			Context.Width:=ViewerImage.Width;
			Context.Height:=ViewerImage.Height;
			Context.Fullscreen:=False;
			Context.DrawProcedure:=TSGContextProcedure(@ViewerDraw);
			Context.Tittle:='"'+FileWay+'" - SaGe Image Viewer';
			Context.RenderClass:=
					//{$IFDEF MSWINDOWS}TSGRenderDirectX{$ENDIF}
					//{$IFDEF UNIX}     
					TSGRenderOpenGL;// {$ENDIF};
			Context.FSelfPoint:=@Context;
			Context.Initialize();
			ViewerImage.SetContext(@Context);
			ViewerImage.ToTexture();
			Context.Run();
			Context.Destroy();
			end
		else
			begin
			WriteLn('Error in loading to bit map!');
			end;
		ViewerImage.Destroy();
		end
	else
		WriteLn('Unknown expansion "',(SGGetFileExpansion(FileWay)),'"!');
	end;

	procedure DllScan();
	var
		FailWay:string;
		Lib:TSGLibrary;
		A:array [#0..#255] of Boolean;
		i,iii:TSGMaxEnum;
		S:STring;
		axtung:Boolean;
		Pc:PChar;

	procedure RecDll(const Depth:LongWord);
	var
		ii:Byte;
	begin
	for ii:=0 to 129 do
		if  A[char(ii)] then
		begin
		S+=Char(ii);
		if Depth=1 then
			begin
			Pc:=SGStringToPChar(S);
			iii:=0;
			try
			iii:=TSGMaxEnum(SaGeBase.GetProcAddress(Lib,Pc));
			except
			end;
			if iii<>0 then
				WriteLn('Result "',S,'"!!!');
			FreeMem(Pc);
			end
		else
			begin
			RecDll(Depth-1);
			end;
		SetLength(S,Length(S)-1);
		end;
	end;

	begin
	if argc<=2 then
		begin
		Writeln('Enter file please as paramrter!');
		Exit;
		end;
	FailWay:=argv[2];
	if not SGFileExists(FailWay) then
		begin
		Writeln('File must be exists!');
		Exit;
		end;
	Lib:=SaGeBase.LoadLibrary(SGStringToPChar(FailWay));
	WriteLn(Lib);
	if Lib=0 then
		begin
		Writeln('Load library failed!');
		Exit;
		end;
	FillChar(A[char(0)],256,0);
	for i:=0 to 255 do
		if char(i) in ['a'..'z','A'..'Z','_','0'..'9'] then
			A[char(i)]:=True;
	S:='';
	for i:=1 to 255 do
		begin
		Writeln('Scaning ',i,' simbol words..');
		RecDll(i);
		end;
	end;

	procedure ImageResizer();
	var
		Image:TSGImage;
	begin
	if (argc=5) and SGFileExists(argv[2]) and (SGVal(SGPCharToString(argv[3]))>0)and (SGVal(SGPCharToString(argv[4]))>0)  then
		begin
		Image:=TSGImage.Create();
		Image.Way:=argv[2];
		Image.LoadToMemory();
		Image.LoadToBitMap();
		Image.Image.SetBounds(
			SGVal(SGPCharToString(argv[3])),
			SGVal(SGPCharToString(argv[4])));
		Image.Way:=SGGetFreeFileName(Image.Way);
		Image.Saveing();
		Image.Destroy();
		end
	else
		WriteLn('Error in parameters You must rnter @filename, @new_width and @new_height!');
	end;

	var
		s:string;

	begin
	if (argc=2) and (SGFileExists(SGPCharToString(argv[1]))) and 
		(SGGetFileExpansion(argv[1])='PNG') then
		begin
		GoViewer(SGPCharToString(argv[1]));
		end
	else if argc>1 then
		begin
		//WriteLn('Entered ',argc-1,' parametrs.');
		s:=SGPCharToString(argv[1]);
		if s[1]='-' then
			begin
			s:=SGGetComand(s);
			if s='FPCTC' then
				begin
				//WriteLn('Beginning FPC to C transliater.');
				FPCTCTransliater;
				end
			else if s='FIP' then
				begin
				//WriteLn('Beginning Find in pas.');
				FindInPas(True);
				end
			else if s='IR' then
				ImageResizer()
			else if s='GUI' then
				begin
				//WriteLn('Beginning Grafical Interface.');
				GoGUI('CMD');
				end
			else if s='DLLSCAN' then
				begin
				DllScan();
				end
			else if s='GRNC' then
				begin
				//WriteLn('Beginning Google ReName Cashe.');
				GoogleReNameCache;
				end
			else if (s='H') or (s='HELP') then
				begin
				WriteLn('This is help for SaGe. You can use:');
				WriteLn('   -FIP                         : for run "Find in pas" program');
				WriteLn('   -FPCTC                       : for run "FPC to C converter" program');
				WriteLn('   -GRNC                        : for run "Google ReName Cashe" program');
				WriteLn('   -DLLSCAN                     : for run scanning dll for procedures');
				WriteLn('   -IR                          : for run image resizer');
				WriteLn('   -H;-HELP                     : for run help');
				WriteLn('   -GUI or don''t use parametrs  : for run Grafical Interface');
				end
			else
				WriteLn('Unknown command "',s,'".');
			end
		else
			WriteLn('Error sintexis command "',s,'". Befor cjmand must be simbol "''".');
		end
	else
		GoGUI();
	end.
	{$ENDIF}
