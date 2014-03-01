{$INCLUDE Includes\SaGe.inc}
unit SaGeLoading;
interface
uses
	SaGeBase
	,SaGeBased
	,SaGeRender
	,SaGeContext
	,SaGeCommon
	,SaGeUtils
	;
type
	//Класс загрузки.
	TSGLoading=class(TSGDrawClass)
			public
		constructor Create(const VContext:TSGContext);override;
		destructor Destroy();override;
		class function ClassName():string;override;
		procedure Draw();override;
			private
		FProjectionAngle:TSGSingle;            //Угол поворота центра
		FProjectionAngleShift:TSGSingle;       //Скорость узманения угла поворота центра
		FAngle:TSGSingle;                      //Начальный угол поворота
		FAngleShift:TSGSingle;                 //Срорость кручения
		FProgress:TSGSingle;                   //[0..1]
		FCountLines:TSGLongWord;               //Количество разделений экранчика
		FFont:TSGFont;                         //Шрифт для надписи процентов
		FArrayOfLines:packed array of          //Массив дорожкок
			packed record
			FLengths:packed array of TSGSingle;//Длины кусочков дорожкок экрана
			FSpeed:TSGSingle;                  //Скорость убывания в середину экрана
			FWidth:TSGSingle;                  //Ширина дорожки в градусах
		    end;
		FProgressIsSet:Boolean;                //Если пользователь не устанавливал не разу прогресс, то
		                                       //Запускатеся режим, где просто показывается работа этой программы,
		                                       //Если установил, то отображается прогресс пользователя
		procedure CallAction();                //Тут обрабатываются дорожки, их кусочки и ширины
		procedure SetProgress(const NewProgress:TSGSingle);
			public
		property Progress:TSGSingle read FProgress write SetProgress;
		end;

implementation

procedure TSGLoading.SetProgress(const NewProgress:TSGSingle);
begin
if not FProgressIsSet then
	FProgressIsSet:=True;
FProgress:=NewProgress;
end;

procedure TSGLoading.CallAction();
var
	i,ii,iii :    TSGWord;
	iiii :        TSGSingle;
begin
for i:=0 to FCountLines-1 do
	begin
	if FArrayOfLines[i].FLengths<>nil then
		begin
		iiii:=FArrayOfLines[i].FSpeed*Context.ElapsedTime;
		while iiii<>0 do
			begin
			if FArrayOfLines[i].FLengths[0]>iiii then
				begin
				FArrayOfLines[i].FLengths[0]-=iiii;
				iiii:=0;
				end
			else
				begin
				iiii-=FArrayOfLines[i].FLengths[0];
				for iii:=0 to High(FArrayOfLines[i].FLengths)-1 do
					FArrayOfLines[i].FLengths[iii]:=FArrayOfLines[i].FLengths[iii+1];
				SetLength(FArrayOfLines[i].FLengths,Length(FArrayOfLines[i].FLengths)-1);
				end;
			end;
		end;
	iiii:=0;
	if FArrayOfLines[i].FLengths<>nil then
	for iii:=0 to High(FArrayOfLines[i].FLengths) do
		iiii+=FArrayOfLines[i].FLengths[iii];
	while iiii<300 do
		begin
		if FArrayOfLines[i].FLengths<>nil then
			SetLength(FArrayOfLines[i].FLengths,Length(FArrayOfLines[i].FLengths)+1)
		else
			SetLength(FArrayOfLines[i].FLengths,1);
		FArrayOfLines[i].FLengths[High(FArrayOfLines[i].FLengths)]:=Random(100)+6;
		iiii+=FArrayOfLines[i].FLengths[High(FArrayOfLines[i].FLengths)];
		end;
	if i mod 2 = 0 then
		begin
		iiii:=(Random(100)-49)/200;
		if not(((FArrayOfLines[i].FWidth+iiii)>2*300/FCountLines) or ((FArrayOfLines[i+1].FWidth-iiii)>2*300/FCountLines)) then
			begin
			FArrayOfLines[i].FWidth+=iiii;
			FArrayOfLines[i+1].FWidth-=iiii;
			end;
		end;
	end;
end;


constructor TSGLoading.Create(const VContext:TSGContext);
var
	i :    TSGLongWord;
begin
inherited Create(VContext);
FProgress:=0;
FCountLines:=18;
if FCountLines mod 2 = 1 then
	FCountLines+=1;
FAngle:=Random(360);
FProjectionAngle:=Random(360);
FProjectionAngleShift:=SGRandomMinus()*0.01; //Тут в радианах, поэтому так мало
FAngleShift:=SGRandomMinus()*0.7;            //А тут в градусах
SetLength(FArrayOfLines,FCountLines);
for i:=0 to FCountLines-1 do
	begin
	FArrayOfLines[i].FLengths:=nil;
	FArrayOfLines[i].FSpeed:=(Random(400)+100)/200;
	FArrayOfLines[i].FWidth:=360/FCountLines;
	end;
FFont:=TSGFont.Create(SGFontDirectory+Slash+'Times New Roman.bmp');
FFont.SetContext(Context);
FFont.Loading();
FProgressIsSet:=False;
end;


destructor TSGLoading.Destroy();
var
	i,ii : TSGWord;
begin
if FArrayOfLines<>nil then
	begin
	for i:=0 to High(FArrayOfLines) do
		if FArrayOfLines[i].FLengths<>nil then
			SetLength(FArrayOfLines[i].FLengths,0);
	SetLength(FArrayOfLines,0);
	end;
inherited Destroy();
end;

procedure TSGLoading.Draw();
var
	i,ii : TSGWord;
	iii  : TSGSingle;

function DrawFirst():Boolean;
begin
Result:=FArrayOfLines[i].FLengths[0]>6;
end;

var
	FCOlor:TSGColor4f;
begin
CallAction();

FCOlor:=(SGColorImport(1,0,0)*(1-FProgress)+SGColorImport(0,1,0)*FProgress);
FCOlor.Normalize();
FColor.Color(Render);

Render.InitOrtho2d(
	-Context.Width/2-sin(FProjectionAngle)*150,
	Context.Height/2+cos(FProjectionAngle)*150,
	Context.Width/2-sin(FProjectionAngle)*150,
	-Context.Height/2+cos(FProjectionAngle)*150);
FFont.DrawFontFromTwoVertex2f(SGStrReal(100*FProgress,1)+'%',
	SGVertex2fImport(-35,-FFont.FontHeight/2),
	SGVertex2fImport(35,FFont.FontHeight/2));

Render.InitOrtho2d(
	-Context.Width/2-sin(FProjectionAngle)*150,
	-Context.Height/2-cos(FProjectionAngle)*150,
	Context.Width/2-sin(FProjectionAngle)*150,
	Context.Height/2-cos(FProjectionAngle)*150);
Render.Rotatef(FAngle,0,0,1);
for i:=0 to FCountLines-1 do
	begin
	iii:=50+Byte(not DrawFirst())*FArrayOfLines[i].FLengths[0];
	for ii:=Byte(not DrawFirst()) to High(FArrayOfLines[i].FLengths) do
		begin
		Render.BeginScene(SGR_LINE_LOOP);
		Render.Vertex2f(iii,6);
		Render.Vertex2f(iii+FArrayOfLines[i].FLengths[ii]-6,6);
		Render.Vertex2f((iii+FArrayOfLines[i].FLengths[ii]-6)*cos(FArrayOfLines[i].FWidth/180*pi),
			(iii+FArrayOfLines[i].FLengths[ii]-6)*sin(FArrayOfLines[i].FWidth/180*pi));
		Render.Vertex2f(iii*cos(FArrayOfLines[i].FWidth/180*pi),iii*sin(FArrayOfLines[i].FWidth/180*pi));
		iii+=FArrayOfLines[i].FLengths[ii];
		Render.EndScene();
		end;
	Render.Rotatef(FArrayOfLines[i].FWidth,0,0,1);
	end;
FAngle+=FAngleShift*Context.ElapsedTime;
FProjectionAngle+=FProjectionAngleShift*Context.ElapsedTime;
if not FProgressIsSet then
	FProgress+=0.001; if FProgress>1 then FProgress:=0;
end;

class function TSGLoading.ClassName():string;
begin
Result:='Загрузка...';
end;

end.
