{
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //.
//  OpenGL for FPC - Tutorial                      //
//                                                 //
//  This example is about perspective projection.  //
//  It's the example from last time with correct   //
//  projection.                                    //
//                                                 //
//  Works with FPC 2.4.0.                          //
//                                                 //
//  (c)2010-9999 Sanches Corporation.              //
//   delax@sundancerinc.de                         //
//                                                 //
//   www.friends-of-fpc.org                        //
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //'
WM_KEYDOWN
VK_SPACE
VK_TAB
VK_RETURN
VK_EURO_SIGN
WM_CHAR
VK_PRIOR
VK_NEXT
	001-Синий
	010-Зелёный
	100-Красный
	110-Жёлтый
	011-Голубой
	101-Розовый
16440
16384
256
При gltr... -6  : 5.89!!
WOW /e Тeкст
}
(*
Жора  +7-988-365-68-86
Киреева +7-918-113-55-22
*)
(*MORTAL KOMBAT*)
{
			[NOOB SAIBOOT]
Вниз + Вверх;
Подходишь к противнику вплотную и много раз нажимаешь 3;
К противнику + К противнику + 4;
Вниз + К противнику + 1;
			[KABAL]
От противника + От противника + 4;
От противника + От противника + От противника + 5;
От противника + К противнику + 3;
Вверх + От противника + От противника + 4;
			[SINDEL]
К противнику + К противнику + 1;
К противнику + К противнику + К противнику + 4;
			[SMOKE]
..Вверх+5;
К противнику + К противнику + 3;
От противника + От противника + 1;
\\BRUTALITY/// -> 	[ 
					  4 +
					  3 + 3 + 3 +
					  6 + 6 + 6 +
					  2 + 2 + 2 +
					  1 + 1 + 1 +
					  4 + 
					  2 + 2 + 2 
					]
			[MILEENA]
К противнику + К противнику + 3;
Лучше драться клавишей 4;
			[RAIN]
От противника + От противника + 4;
Вниз + Вперёд + 4;
Подходишь близко к противнику + От противника + 6;
			[CYRAX]
От противника + От противника + 3;
			[SHANG TSUNG]
От противника + От противника + 4;
К противнику + К противнику + 1;	=> [SMOKE]
От противника + К противнику + 2;
..Вверх+5; 	=> [NIGHTWOLF]
			[NIGHTWOLF]
К противнику + К противнику + 3;
От противника + От противника + От противника + 6;
Вниз + К противнику + 4;
Вниз + От противника + 1;
			[SEKTOR]
К противнику + К противнику + 1;
К противнику + К противнику + 3;
Вниз + От противника + 4;
			[SCORPION]
От противника + От противника + 1;
Лучше драться клавишей 4;
Вниз + От противника + 4;
			[LIU KANG]
К противнику + К противнику + 1;
К противнику + К противнику + 4;
К противнику + К противнику + 6;
Вверх + К противнику + К противнику + 4;
\\FATALITY/// -> 	[ 
					К противнику + К противнику +
					Вниз + Вниз +
					3
					]
			[JAX]
Подходишь к противнику вплотную + К противнику + К противнику + 1;
К противнику + К противнику + 6;
От противника + К противнику + 4;
			[SRYKER]
К противнику + К противнику + 6;
Вниз + От противника + 1;
К противнику + От противника + 1;
			[REPTILE]
К противнику + К противнику + 4;
			[JADE]
От противника + К противнику + 1;
От противника + К противнику + 3;
От противника + К противнику + 6;
			[SUB-ZERO]
Вниз + К противнику + 1;
Вниз + К противнику + 4;
Вниз + От противника + 1;
			[KUNG LAO]
От пртивника + К противнику + 1;
Вниз + Вверх;
			[KITANA]
От противника + От противника + От противника + 4;
			[SONYA]
К противнику + От противника + 4;
Вниз + К противнику + 1;
			[ERMAC]
Вниз + От противника + 1;
Вниз + От противника + 4;
			[SUB-ZERO] (NINZA)
Вниз + К противнику + 1;
Вниз + От противника + 3;
}
{$DEFINE WINDOWS7}
//{$DEFINE WINDOWSXP}
{$MODE OBJFPC}
{$S+}
{$IFOPT S+}
	//{$APPTYPE GUI}
	//{$MODE DELPHI}
	//{$MODE OBJFPC}
	//{$MODE TP}
	//{$MODE FPC}
	//{$MODE DEFAULT}
	//{$STATIC ON}
	{$SMARTLINK ON}
	{$NOTES ON}
	{$WARNINGS ON}
	//{$R SAN.RES}
	{$MEMORY	90000000000000000000000000000000000000000000000000000000000000000000000    ,
				90000000000000000000000000000000000000000000000000000000000000000000000    }
	(* Only for EXEs of DLLs
	{$IFDEF MSWINDOWS}
		{$VERSION 0.70}
		{$ENDIF}
	*)
	{$EXTENDEDSYNTAX ON}
	{$COPERATORS ON}
	{$HINTS OFF}
	{$GOTO ON}
	//{$LONGSTRINGS ON}
	{$INLINE ON}
	//{$LINKLIB OpenAL32.dll}
	{$MACRO ON}
	//{$MMX ON}
	{$OPENSTRINGS ON}
	{$SATURATION ON}
	//{$TYPEDADDRESS ON}
	{$ASMMODE INTEL}
	//{$CALLING STDCALL}
	//{$DEBUGINFO ON}
	{$ASSERTIONS ON}
	{$ENDIF}

unit san;
interface
	uses
		dos,crt,OpenAL,SysUtils,gl,glu,classes
		,SaGeBase, SaGeBased, SaGeCommon
		{$IFDEF MSWINDOWS}
			,graph,windows,MMSystem
		{$ELSE} {$IFDEF LINUX}
			,glx,xlib,unix,x,xutil
		{$ELSE}
			{$WARNING <<<<)(NE POPRET!)(>>>>}
		{$ENDIF}{$ENDIF}
			;
	const (*$NOTE >>|<           Begining    Const           >|<<*)
			SanStringXO='XO by MPSNP (Krestiki - Noliki) (Sanches Corporation OpenGl Application) ';
			GL_SAN_STRING=			1;
			GL_SAN_LONGINT=			2;
			GL_SAN_POINTER=			3;
			GL_SAN_CHAR=			4;
			GL_SAN_REAL=			5;
			GL_SAN_WORD=			6;
			Gl_SAN_EXTENDED=		7;
			GL_SAN_PCHAR=			8;
			GL_SAN_BYTE=			9;
			GL_SAN_DWORD=			10;
			GL_SAN_LONGWORD=GL_SAN_DWORD;

	const	GL_SAN_VIEW_FIRST=1001;
			GL_SAN_VIEW_SECOND=1002;
			GL_SAN_VIEW_1=GL_SAN_VIEW_FIRST;
			GL_SAN_VIEW_2=GL_SAN_VIEW_SECOND;
			GL_SAN_VIEW_ANY=GL_SAN_VIEW_2;
	const	GL_CONST_LO=1000000;
			GL_SAN_MENU_KOL=50;
			GlSanKolDelayArray=100;
			GlSanKeyRigth=39;
			GlSanKeyLeft=37;
			GlSanWAKolT=0;{WA Hiear <<<<<<<<<<<<<<<}
			GL_SAN_UNCNOWN_RAD_OKR = $DDDDDD;
			GL_SAN_CONTEXT_ENABLED_PROCEDURE   =   1;
			GL_SAN_CONTEXT_ENABLED_FUNCTION   =   3;
			GL_SAN_CONTEXT_DISABLED_PROCEDURE   =   4;
			GL_SAN_CONTEXT_DISABLED_FUNCTION   =   5;
	const 
		GL_SAN_TEXT=			$00000B;
		GL_SAN_ICONS=			$00000C;
		GL_SAN_ICONS_AND_TEXT=	$00000D;
		GL_SAN_ICON=GL_SAN_ICONS;
		GL_SAN_ICON_AND_TEXT=GL_SAN_ICONS_AND_TEXT;
		GL_SAN_TEXT_AND_ICONS=GL_SAN_ICONS_AND_TEXT;
					(*
					1 - Вниз Вправо
					2 - Вверх Влево
					3 - Вверх Вправо
					4 - Вниз Влево
					*)
		GL_SAN_CM_NP=1;
		GL_SAN_CM_VL=2;
		GL_SAN_CM_VP=3;
		GL_SAN_CM_NL=4;
		GSB_EDIT= 			$00000E;
		GSB_COMBOBOX=		$00000F;
		GSB_CHECKBOX=		$000010;
		GSB_BUTTON=			$000011;
		GSB_TEXT=			$000012;
		GSB_LISTBOX=		$000013;
		GSB_PROGRESSBAR=	$000014;
		GSB_BOOK=			$000015;
		
		GSB_MIDDLE_TEXT=		$000016;
		GSB_LEFT_TEXT=			$000017;
		GSB_CANCULATE_WIDTH=	$000018;
		GSB_CANCULATE_HEIGHT=	$000019;
		
		GSB_NILSTR='';
		GSB_INF_NOOTHING=	$00001A;
		GSB_INF_SOMETHING=	$00001B;
		GSB_INF_ALL=		$00001C;
	const 
		OpenALLibNameWin7='OpenAL32.dll';
		OpenALLibNameWinXP='wrap_oal.dll';
		{$IFDEF WINDOWS7}
			OpenALLibName=OpenALLibNameWin7;
			{$ENDIF}
		{$IFDEF WINDOWSXP}
			OpenALLibName=OpenALLibNameWinXP;
			{$ENDIF}
	type    array_XO=array[1..9] of longint;
	type
		GLUInt=gl.gluint;
		
		
	type	bait=byte;
			b=byte;
			GlSanParametr=longint;
			GlSanKoor=object
				x,y,z:real;
				procedure SanWrite;
				procedure SanWriteln;
				procedure Import(a,b,c:real);
				procedure SanSetColor;
				PROCEDURE SanSetColor(q:real);
				procedure Togever(q:GlSanKoor);
				procedure Zum(q:real);
				procedure Zum(ax,ay:real);
				procedure ReadFromFile(p:pointer);
				procedure Vertex;
				procedure WritelnToFile(p:pointer);
				procedure ReadlnFromFile(p:pointer);
				procedure ClearColor;
				end;
			GlSanKoor2f=object
				x,y:real;
				procedure sanwrite;
				procedure sanwriteln;
				procedure Import(a,b:real);
				function GSK3:GlSanKoor;
				procedure ReadFromFile(p:pointer);
				procedure Togever(const k:GlSanKoor2f);
				procedure Zum(const q:real);
				procedure ReadlnFromFile(const p:pointer);
				end;
			GlSanOtr=object
				a,b:GlSanKoor;
				procedure Import(v1,v2:GlSanKoor);
				function SrednZn:GlSanKoor;
				procedure SanWriteln;
				end;
			GlSanKoorPlosk=object
				a,b,c,d:real;
				procedure sanwrite;
				procedure sanwriteln;
				procedure SanSetColor;
				procedure SanSetColor3f;
				procedure Import(a1,a2,a3,a4:real);
				procedure SanSetColorA(const al:real);
				procedure Zum(const r:real);
				function Negative:GlSanKoorPlosk;
				procedure Color;
				procedure SetColor;
				procedure ReadlnFromFile(p:pointer);
				function PointOn(const P:GlSanKoor):boolean;
				procedure ClearColor;
				procedure TogeverColor(const _:GlSanKoorPlosk);
				end;
			GlSanKoorLine=object
				x1,x2,y1,y2,z1,z2:real;
				x3,y3,z3:real;
				procedure SanWriteln;
				procedure SanWrite;
				end;
			GlSanKoor3f=GlSanKoor;
			GlSanColor3f=GlSanKoor;
			GlSanColor4f=GlSanKoorPlosk;
			ar_m_b=array[1..10,1..10] of bait;
			war=array [1..10] of bait;
			ost_type=array[1..10000,1..6] of word;
			setka=array[1..1001,1..1001]of real;
			YacheikiZmei=array[1..2000,1..3] of real;
			GlSanChvObj=object
				TipZ:longint;{Тип заполнения, Gl_Line,Gl_FiLL и тд}
				Tip:longint;{1-простой цвет, 2-прозрачный цвет, 3-текстура,4-смешанная с цветом текстура, 5-прозрачная4}
				{1}_1:GlSanColor3f;
				{2}_2:GlSanColor4f;
				{3}_3:longint;
				end;
			GlSanFigObj=object
				Kol:longint;{Количество точек}
				Tip:longint;{Тип Gl_TRIANGLES, GL_LINES, GL_QUADS и тд}
				T:array[1..500] of longint;{Порядковые номера точек}
				end;
			GlSanKOBJ=array[1..500] of ^GlSanKoor;
			GlSanFOBJ=array[1..500] of ^GlSanFigObj;
			GlSanObject=object
				KolT:longint;
				Toch:GlSanKOBJ;
				KolF:longint;
				Chv:array[1..500] of ^GlSanChvObj;
				Fig:GlSanFOBJ;
				procedure New(KT,KF:longint);
				procedure Dispose;
				procedure ImportFromFile(s:string);
				procedure Init(x,y,z,r:real);
				procedure ExportFromFile(s:string);
				end;
			GlSanObj=GlSanObject;
			GlSanChvMesh=object
				TipZ:longint;
				Tip:longint;
				_1:GlSanColor3f;
				_2:GlSanColor4f;
				_3:GLUint;
				procedure Init;
				end;
			GlSanMesh=object
				KolT:longint;
				Toch:GlSanKOBJ;
				KolF:longint;
				Chv:array[1..500] of ^GlSanChvMesh;
				Fig:GlSanFOBJ;
				procedure Init(x,y,z,r:real);
				end;
			GlSanYT=object
				Tip:longint;
				R:pointer;
				end;
			GlSanUA2=object
				UA:array[1..1000] of ^GlSanYT;
				SL:^GlSanUA;
				end;
			GlSanUA=object
				UA:array[1..1000] of ^GlSanYT;
				SL:^GlSanUA2;
				end;
			GlSanArray=object
				DL:longint;
				YA:^GlSanUA;
				end;
			GlSanABCObj=object
				KolL:longword;
				L:array[1..2,1..20] of byte;
				procedure Init(TOC:GlSanKoor;r:real);
				procedure SmallInit(TOC:GlSanKoor;r:real);
				procedure Init(TOC:GlSanKoor;r:GlSanKoor2f);
				procedure SmallInit(TOC:GlSanKoor;r:GlSanKoor2f);
				end;
			GlSanAnyType=GlSanYT;
			GlSanF=object
				Kol:longint;
				N:array[1..10] of longint;
				procedure Import(a1,a2,a3,a4:longint);
				procedure Import(a1,a2,a3:longint);
				end;
			GlSanLightObject=object
				KolV:longint;
				KolF:longint;
				V:array[1..GL_CONST_LO] of ^GlSanKoor;
				F:array[1..GL_CONST_LO] of ^GlSanF;
				procedure ReadFromFile(s:string);
				procedure Init(k:GlSanKoor;s:real);
				procedure Dispose;
				end;
			GlSanLightObj=GlSanLightObject;
			GlSanListObjects=object
				kol:longint;
				L:array[1..GL_CONST_LO] of ^GlSanLightObject;
				C:array[1..GL_CONST_LO] of ^GlSanChvMesh;
				end;
			GlSanC=object
				S:string;
				Tip:longint;
				w1:GlSanColor4f;
				w2:gluint;
				end;
			GlSanBigF=object
				Kol:longint;
				n:array[1..10] of longint;
				t:array[1..10] of longint;
				end;
			GlSanMat=object
				N:longint;
				S:string;
				end;
			GlSanNormalF=object
				Tip:longint;
				q1:^GlSanF;
				q2:^GlSanMat;
				q3:^GlSanBigF;
				end;
			GlSanNormalObject=object
				KolV:longint;
				KolF:longint;
				KolVT:longint;
				KolC:longint;
				V:array[1..GL_CONST_LO] of ^GlSanKoor;
				F:array[1..GL_CONST_LO] of ^GlSanNormalF;
				VT:array[1..Gl_CONST_LO] of ^GlSanKoor2f;
				C:array[1..Gl_CONST_LO] of ^GlSanC;
				procedure ReadFromFile(p:string);
				procedure Init;
				end;
			LineObjOfDoska=object
				b1,b2:boolean;
				i1,i2:longint;
				end;
			PloskObjOfDoska=object
				b:boolean;
				i:longint;
				end;
			GlSanObj3=object
				V:array of GlSanKoor;
				F:array of array of word;
				procedure Init(const a:GlSanKoor;const r:real);
				procedure Init(const a:GlSanKoor;const r:GlSanKoor2f);
				procedure ReadFromFile(const s:string);
				procedure Dispose;
				procedure WritelnToFile(p:pointer);
				procedure ReadlnFromFile(p:pointer);
				procedure SerediniPoligonov;
				procedure WriteToFile(const s:string);
				end;
			DPoint=object
				ID:longint;
				i:longint;
				end;
			DDPoint=object
				ArLongint:array of longint;
				ArGlSanKoor:array of GlSanKoor;
				ArDPoint:array of DPoint;
				procedure Dispose;
				end;
			GlSanFriend=object
				FaceG:GLUint;
				FaceS:string;
				Name:string;
				Family:string;
				Namber:string;
				Addres:string;
				destructor Dispose;
				end;
			GlSanNormalObj=GlSanNormalObject;
			GlSanMenuArray=array[1..GL_SAN_MENU_KOL] of string;
			GlSanMenuColorArray=array[1..2] of GlSanColor4f;
			GlSanMenuColors=Array[1..6] of GlSanColor4f;
			GlSanWndColors=array[1..6] of GlSanColor4f;
			GlSanWndTextChv=array[1..2] of GlSanColor4f;
			GlSanWndProcedure=procedure(Wnd:pointer);
			GlSanContextProcedure=GlSanWndProcedure;
			GlSanContextFunction=function(Wnd:pointer):pointer;
			GlSanFunctionContext=GlSanContextFunction;
			GlSanWndHint=object
				STR:array of string;
				MaxLength:real;
				procedure Clear;
				procedure Add(s:string);
				end;
			GlSanWndText=object
				OVL:GlSanKoor2f;
				ONP:GlSAnKoor2f;
				Chv:GlSanWndTextChv;
				ParamS,ParamF:GlSanParametr;
				Text:string;
				procedure Init(const vl,np:GlSanKoor; const Verh:boolean; const _:real);
				end;
			GlSanWndButtonsChv=array[1..8] of GlSanColor4f;
			GlSanWndButton=object
				OVL:GlSanKoor2f;
				ONP:GlSAnKoor2f;
				Text:string;{Название}
				ProcB:pointer;{Процедура}
				Blan:boolean;
				SetOnOn:boolean;
				RadOkr:real;
				Hint:GlSanWndHint;
				CHV:GlSanWndButtonsChv;
				Tex:string;
				TexC:string;
				TexOn:string;
				procedure Init(const vl,np:GlSanKoor; const Verh:boolean; const _:real);
				procedure InitOn(const vl,np:GlSanKoor);
				procedure InitC(const vl,np:GlSanKoor);
				end;
			GlSanWndListBox=object
				OVL:GlSanKoor2f;
				ONP:GlSanKoor2f;
				RO,RO2:real;
					{Единичный радиус шрифта}
				Text:array of string;
					{Текст}
				TextChv:array of GlSanWndTextChv;
					{Цвет Текстa}
				MV:boolean;
					{Разрешение вибирать строку внутри}
				MVPos:longint;
					{Выбранная строка}
				Shrift:GlSanKoor2f;
					{Шрифт (Наверное)}
				PokQuad:boolean;
					{Показывать ли фон}
				Position:longint;
					{Прокрутка}
				Button:boolean;
					{Двойной щелчок на ListBox}
				ArButtons:array [1..3] of GlSanWndButton;
					{Кнопочки}
				PositionOn:longint;
					{Выделенная позиция на Лист-Боксе.
					Сделано для возможности инициализации контекстного меню
					от выделенной позиции}
				procedure Init(const vl,np:GlSanKoor; const Verh:boolean; const _:real);
				end;
			GlSanWndProgressBar=object
				OVL:GlSanKoor2f;
				ONP:GlSanKoor2f;
				Progress:real;
				Chv:GlSanColor4f;
				procedure Init(const vl,np:GlSanKoor; const Verh:boolean; const _:real);
				end;
			GlSanWndEdit=object
				OVL:GlSanKoor2f;
				ONP:GlSanKoor2f;
				Caption:string;
				LostCaption:string;
				procedure Init(const vl,np:GlSanKoor; const Verh:boolean; const _:real);
				procedure InitC(Const vl,np:GlSanKoor;const _:real;const l:longint;const cb,cr,ct,cc:GlSanColor4f);
				end;
			GlSanWndComboBox=object
				OVL:GlSanKoor2f;
				ONP:GlSanKoor2f;
				BNNP,BVL,BNP:GlSanKoor;
				Text:array of string;
				Position:longint;
				Open:boolean;
				OpenProgress:real;
				OpenPosition:longint;
				IO:real;
				procedure Init(const vl,np:GlSanKoor; const Verh:boolean; const _:real);
				procedure InitC(Const vl,np:GlSanKoor;const _:real;const l:longint;const cb,cr,ct,cc:GlSanColor4f);
				end;
			GlSanWndCheckBox=object
				OVL:GlSanKoor2f;
				ONP:GlSanKoor2f;
				Caption:boolean;
				procedure Init(const vl,np:GlSanKoor;const Verh:boolean;  const _:real);
				end;
			GlSanWndUserMemory=object
				ArLongint:array of longint;
				Ar2Longint:array of longint;
				ArPointer:array of pointer;
				ArString:array of string;
				Ar2String:array of string;
				ArGlSanColor4f:array of GlSanColor4f;
				ArGlSanObj3:array of GlSanObj3;
				ArArLongint:array of array of longint;
				ArGlSanKoor:array of GlSanKoor;
				ArBoolean:array of boolean;
				ArReal:array of real;
				Ar2Real:array of real;
				Pointer1:pointer;
				GlSanObj31:GlSanObj3;
				Rot1:real;Rot2:real;LZ:real;UZ:real;Zum:real;
				String1:string;
				ArDPoint:array of array[1..2] of DPoint;
				ArArDPoint:array of array of DPoint;
				Ar2DPoint:array of DPoint;
				ArDDPoint:array of DDPoint;
				Longint1:longint;
				ArGlSanFriend:array of GlSanFriend;
				procedure Dispose;
				end;
			GlSanWndBook =object
				OVL:GlSanKoor2f;
				ONP:GlSanKoor2f;
				ArStrings:
					array of packed record
						ArMem:
							array of packed record
								Name:string;
								Mem:
									array of DPoint;
								end;
						end;
				OtnAllTittle:real;
				ActS:longint;
				ActB:longint;
				end;
			GlSanWndImage=object
				OVL:GlSanKoor2f;
				ONP:GlSanKoor2f;
				IDTexture:GLUInt;
				procedure Init(const vl,np:GlSanKoor; const Verh:boolean; const _:real);
				end;
			GlSanWndConsole=object
					(* Для определения координат консоли от координат окна *)
				OVL:GlSanKoor2f;
				ONP:GlSanKoor2f;
					(* Показывать ли курсор, Insent курсор *)
				ShowCursor:boolean;
				BigCursor:boolean;
					(* Координаты курсора*)
				CursorX:longint;
				CursorY:longint;
					(* Установленные цвета текста и фона *)
				ColorText:GlSanColor4f;
				ColorBackGround:GlSanColor4f;
					(* Не пребует коментариев *)
				MaxX:longint;
				MaxY:longint;
					(* Позиция прокрутки *)
				MovePosition:longint;
					(* Основной массив *)
				Things:array of 
					array of 
						packed record
							(* Цвет этого участка консоли *)
							ColorText:GlSanColor4f;
							ColorBackGround:GlSanColor4f;
							(* Cимвол *)
							Char:char;
							end;
				procedure Init(const vl,np:GlSanKoor; const Verh:boolean; const _:real);
				end;
			GlSanWnd=object
				OVL:GlSanKoor2f;{Отношение kоординат верхнего левого угла окна к высоте и правоте*}
				ONP:GlSanKoor2f;{Отношение .....}
				ONZP:GlSanKoor2f;{Отношение .....}
				TVL,TNP,TNZP:GlSanKoor;{Koordinati}
				ProgramName:string;
				Tittle:string;{Заголовок окна, который будет отображаться в его заголовке}
				TittleSystem:string;{Заголовок окна, системный}
				Icon:string;
				ColorsF:GlSanWndColors;{Цвет всего при главном окне!}
				ColorsS:GlSanWndColors;{Цвет всего при второстепенном окне!}
				MTelo:boolean;{двИгать за всё тело}
				RadOkr:real;{радиус округления полигонов}
				WndUk:pointer;{Указфткль на указатель на это окно}
				ArText:array of GlSanWndText;
				ArButtons:array of GlSanWndButton;
				ArListBox:array of GlSanWndListBox;
				ArProgressBar:array of GlSanWndProgressBar;
				ArEdit:array of GlSanWndEdit;
				ArComboBox:array of GlSanWndComboBox;
				ArCheckBox:array of GlSanWndCheckBox;
				ArBook:ARRAY of GlSanWndBook;
				ArImage:array of GlSanWndImage;
				ArConsole:array of GlSanWndConsole;
				WndW,WndH:longint;{Wheit and heigth of Wnd}
				ZagP:boolean;{Показывать ли заголовок окна}
				TeloP:boolean;{Разрешить перетаскивание за тело}
				ExitP:boolean;{Подготовка на закрытие окна}
				ExitI:longint;{Счетчик выхода}
				Al:real;{Прозрачность}
				Proc:pointer;{Процедура ежетактная}
				InitProc:pointer;
				UserMemory:GlSanWndUserMemory;{Блок памяти программы}
				ArDependentWnd:array of pointer;{Массив Зависимых  окон}
				ReOutThisProc:boolean;
				InfWorld:longint;
				procedure Init(const z:longint);
				end;
			GlSanWindow=GlSanWnd;
			GlSanUWnd=^GlSanWnd;
			GlSanUUWnd=^GlSAnUWnd;
			GlSanPPWnd=GlSanUUWnd;
			PPGlSanWnd=GlSanPPWnd;
			PGlSanWnd=GlSanUWnd;
			GlSanPWnd=PGlSanWnd;
			GlSanSkin=object
				WindowTip:longint;
					(*
					0 - 9 Quads
					1 - 15 Quads
					2 - 1 Quad
					*)
				ButtonTip:longint;
					(*
					0 - 9 Quads
					1 - 1 Quad
					*)
				CheckBoxTip:longint;
				Name:string;
				ArTextures:array of GLUInt;
				ArRealWindow1:array of real;
				ArRealWindow2:array of real;
				ArRealWindow3:array of real;
				ArRealWindow4:array of real;
				WindowTexture1:longint;
				WindowTexture2:longint;
				WindowTexture3:longint;
				WindowTexture4:longint;
				ArWindowTextureColor:array [1..4] of GlSanColor4f;
				ArRealButton1:array of real;
				ArRealButton2:array of real;
				ArRealButton3:array of real;
				ArRealButton4:array of real;
				ButtonTexture1:longint;
				ButtonTexture2:longint;
				ButtonTexture3:longint;
				ButtonTexture4:longint;
				ArButtonTextureColor:array [1..4] of GlSanColor4f;
				HintTexture:longint;
				ArRealHint:array of real;
				ArHintTextureColor:array[1..2] of GlSancolor4f;
				CheckBoxTexture1:longint;
				CheckBoxTexture2:longint;
				CheckBoxTexture3:longint;
				CheckBoxTexture4:longint;
				ArCheckBoxKoorTextures:array of array[1..2] of GlSanKoor2f;
				ContextMenuTexture1:longint;
				ContextMenuTexture2:longint;
				ContextMenuTexture3:longint;
				ContextMenuTexture4:longint;
				ContextMenuTexture5:longint;
				ArRealContextMenu1:array of real;
				ArRealContextMenu2:array of real;
				ArRealContextMenu3:array of real;
				ArRealContextMenu5:array of real;
				ArContextMenuTextureColor:array[1..4] of GlSancolor4f;
				ComboBoxTexture1:longint;
				ComboBoxTexture2:longint;
				ComboBoxTexture3:longint;
				ComboBoxTexture4:longint;
				ComboBoxTexture5:longint;
				ArRealComboBox1:array of real;
				ArRealComboBox2:array of real;
				ArRealComboBox3:array of real;
				ArRealComboBox4:array of real;
				ArComboBoxTextureColor:array[1..5] of GlSancolor4f;
				end;
			CharFont=object
				x,y,width:longint;
				end;
			GlSanFont=object
				ArChar:array[1..256]of CharFont;
				ID:gluint;
				Height:byte;
				TW,TH:longint;
				Name:string;
				end;
			GlSanTexture=object
				ID:GLUint;
				Name:string;
				end;
			GlSanContextMenu=object
				Things:array of packed record
					Text:string;
					Ico:string;
					ZumIco:GlSanKoor2f;
					Tipe:longint;
						(*
						1 - Procedure Users
						2 - Open Dialog
						3 - Close Dialog
						*)
					Point:pointer;
					Dialog:Pointer;
					end;
				Open:boolean;
				OpenProgress:real;
				StartKoor:GlSanKoor;
				OpenTipe:longint;
					(*
					1 - Вниз Вправо
					2 - Вверх Влево
					3 - Вверх Вправо
					4 - Вниз Влево
					*)
				ViewTipe:longint;
				IconsZum:GlSanKoor2f;
				MaxLength:real;
				DependentWindow:PGlSanWnd;
				DependentProc:pointer;
				UserMemory:GlSanWndUserMemory;
				CoolStrings:boolean;
				ContextMenuIconZum:real;
				ContextMenuZum:real;
				procedure CloseContext;
				procedure KillContext;
				procedure Init;
				procedure ReInitMaxLength;
				function  InitKoor(const k:GlSanKoor):boolean;
				procedure ReKoor;
				procedure ReTipe;
				procedure ReTipeKoor(const IDWA:longint; const ML:real);
				procedure OutImage(const Koor:GlSanKoor;const ML:real;const n:longint);
				end;
			PGlSanContextMenu=^GlSanContextMenu;
const
	nilkoor:GlSanKoor = (x:0;y:0;z:0);
	GlSanWndStandardColorsGl:GlSanWndColors = ( (a:0;b:0.5;c:0;d:0.5),
												(a:0;b:0.9;c:0;d:0.7),
												(a:0.8;b:0.8;c:0.8;d:0.7),
												(a:1;b:1;c:1;d:0.8),
												(a:1;b:1;c:1;d:0.8),
												(a:0;b:1;c:1;d:0.5));
	GlSanWndStandardColorsNGL:GlSanWndColors = ((a:0;b:0;c:0.5;d:0.5/2),
												(a:0;b:0;c:0.9;d:0.7/2),
												(a:0.8;b:0.8;c:0.8;d:0.7/2),
												(a:1;b:1;c:1;d:0.8/2),
												(a:0.7;b:0.8;c:0.8;d:0.8/2),
												(a:0;b:1;c:1;d:0.5/2));
	GlSanWndButtonsChvStandard:GlSanWndButtonsChv =(
												(*Цвет Фона при Активном Окне*)
												(a:0;b:0.5;c:0;d:0.5),
												(*Цвет Огранки Окна при Активном Окне*)
												(a:0.9;b:0.9;c:0.9;d:0.7),
												(*Цвет Текста при Активном Окне*)
												(a:0.8;b:0.8;c:0.8;d:0.5),
												(*Цвет Фона при Пассивном Окне*)
												(a:0;b:0;c:0.5;d:0.5),
												(*Цвет Огранки Окна при Пассивном Окне*)
												(a:0.4;b:0.4;c:0.4;d:0.5),
												(*Цвет Текста при Пассивном Окне*)
												(a:0.55;b:0.55;c:0.55;d:0.66),
												(*Цвет кнопки, при наведении на неё*)
												(a:0;b:0.8;c:0.8;d:0.45),
												(*Цвет кнопки, при нажатии на неё*)
												(a:0.8;b:0.8;c:0.8;d:0.45));
	GlSanWndTextChvStandard:GlSanWndTextChv=((a:0.9;b:0.9;c:0.9;d:0.5),
												(a:0.9;b:0.9;c:0.9;d:0.3));
	ContextMenuStartKoor:GlSanKoor = (x:0; y:0; z:0);
var (*$NOTE >>|<            Begining     Var             >|<<*)
			{------------KolWA-----------}
			GlSanWAKol:longint=GlSanWAKolT;
			{------------KolWA-----------}
	SanShowCursor:boolean = true;{Показывать ли курсор}
	GlSanClearColor:GlSanColor4f;
	GlSanLineWidth,ZumT:real;{Толщина линий}
	GlMouseReadKey:longint;
	GlSanMouseClickConst:longint;
	NewWnd:^GlSanWindow;
	GlSanWinds:array of ^GlSanWnd;{---------=====@@@@@@====------------Окна------------========@@@@@@@@@@=====---------------}
	                              {---------=====@@@@@@====------------Окна------------========@@@@@@@@@@=====---------------}
	                              {---------=====@@@@@@====------------Окна------------========@@@@@@@@@@=====---------------}
	                              {---------=====@@@@@@====------------Окна------------========@@@@@@@@@@=====---------------}
			{-------------------------From MPSNP.ppu bEgIn-----------------------------}
	CNormal : array[1..3] of real;
	AmbientLight : array[0..3] of glFloat = (0.5,0.5,0.5,1.0);
	DiffuseLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
	SpecularLight : array[0..3] of glFloat = (1.0,1.0,1.0,1.0);
	SpecularReflection : array[0..3] of glFloat = (0.4,0.4,0.4,1.0);
	LightPosition : array[0..3] of glFloat = (0,1,0,2);
	viewport:tviewportarray;
	mv_matrix,proj_matrix:t16dArray;
	obx,oby,obz:glDouble;
			{---------------------------From MPSNP.ppu eNd-----------------------------}
	GlSanMin:real = 0.003;
	GlSanWndMin:real = 0.000002;
			{Delay Begin}
			GlSanD:longint = 0;{Delay of FPS}
			FPS:longint = 0;{Количество кадров в секунду}
			GlSanDON:boolean = true;{off=on Delay}
			FPSMoment:boolean=false;
			Time:packed record
				Hours:word;
				Minits:word;
				Seconds:word;
				Sec100:word;
				end;
			Date:packed record
				Year:word;
				Month:word;
				Day:word;
				Week:word;
				end;
			SecNow:word=0;
			FPSSled:word=0;
			FPSUser:boolean = false;
			{Delay End}
	GlSanWA:array [0..GlSanWAKolT] of array[1..4] of GlSanKoor;{Массив координат окон}
	GlSanWndKoor:array[1..4] of longint;{Координаты окна в системе}
	GlSanCursorInWindow:boolean = true;{Находится ли курсор внутри окна?}
	rz:longint = 1;{Единица, которая отнимается от У 1 и 2 точки rec-а...}
	rs1:longint = 1;{Единица, которая отнимается от У 3 и 4 "Вверх"}
	rs2:longint = 1;{Единица, которая отнимается от У 1 и 2 и 3 и 4 "Внутрь"}
		GlSanWndMove:boolean = false;{ Перетаскивание окна по экрану}
		GlSanWndMoveKoor:array [1..4] of GlSanKoor2f;{При перетаскивании окна 1-отношения ВЛ, 2-отн... НП, 3-отн... НЗП, 4-начальный курсор}
		GlSanWndMoveLengthGlSanWinds:longint;{Длинна массива окон при ...}
	Sphere:GlSanObj3;{ procedure GlSanSphere}
	Kub:GlSanObj3;
		GlSanWndListBoxMoveButton:boolean = false;{Перетаскивается ли в ЛистБоксе ли Правая Хрень)))}
		GlSanWndListBoxMoveButtonNumber:longint = 0;{Порядковый номер ЛистБокса при перетаскивании}
		GlSanWndListBoxMoveButtonVG:longint =0;{Верхняя граница}
		GlSanWndListBoxMoveButtonNG:longint =0;{Нижняя граница}
		GlSanWndListBoxMoveButtonPositionMinus:longint=0;{Отнимается от позиции вычисленного (Правой хрени)}
		GlSanWndListBoxMoveButtonLengthGlSanWinds:longint;{Длинна массива окон при ...}

		SanWndEditRedFl:boolean = false;{Производится ли ввод с клавиатуры в Edit}
		SanWndEditRedLostWnd:^GlSanWNd = nil;
		SanWndEditRedSimbol:longint = 0;
		SanWndEditRedI:longint = 0;{Прорядковый номер}

		SanWndComboBoxFl:boolean=false;
		SanWndComboBoxPWnd:^GlSanWnd;
		SanWndComboBoxI:longint;

	{------------------------------From RNR unit <BEGIN>------------------------------}
	RNRDevice: OpenAL.TALCdevice;
	RNRContext: TALCcontext;
	RNRBuffer: array of TALuint;
	RNRSource: array of TALuint;
	RNRNames:array of
		record
		Name:string;
		StName:string;
		end;

	RNRSourcePos: array of array [0..2] of TALfloat;
	RNRSourceVel: array of array [0..2] of TALfloat;

	RNRListenerPos: array [0..2] of TALfloat= ( 0.0, 0.0, 0.0);
	RNRListenerVel: array [0..2] of TALfloat= ( 0.0, 0.0, 0.0);
	RNRListenerOri: array [0..5] of TALfloat= ( 0.0, 0.0, -1.0, 0.0, 1.0, 0.0);

	RNRKolSounds:longint;
	{--------------------------------------<END>--------------------------------------}
	
	ArFonts:array of GlSanFont = nil;
	IDLoadFont:boolean = false;
	ActiveFont:longint = -1;
	BufferFont:longint = -1;
	CorrectFont:boolean = false;
	BufferCorrectFont:boolean = false;
	ArTextures:array of GlSanTexture = nil;
	ArSkins:array of GlSanSkin = nil;
	ActiveSkin:longint;
	CorrectIntoChar:longint = 2;
	
	SravnChar:char = 'W';
	
	HintZum:real = 0.0016;
	
	StandardContextMenuZum:real = 0.0021;
	ContextMenu:PGlSanContextMenu = nil;
	ContextMenuSled:PGlSanContextMenu = nil;
	ContextCloseID:boolean = false;
	
	NewContext:PGlSanContextMenu = nil;
	
	GlSanMaxMin:real = 0.02;
	
	IDReOut:PGlSanWnd = nil;
	
	StandardContextMenuIconZum:real = 1.7;
	
	ArPrograms:packed array of packed record
		Name:string;
		Icon:string;
		Proc:pointer;
		end = nil;
{property Width : longint read GetContextWidth;
property Height : longint read GetContextHeight;}
{--------------------------------------------------------------------------------------------------}
{**************************************************************************************************}
(*=====================*)(*$NOTE >>|<   Begining Procedure Variable   >|<<*)(*====================*)
{**************************************************************************************************}
{--------------------------------------------------------------------------------------------------}
operator +  (const a,b:GlSanKoor):GlSanKoor;
operator -  (const a,b:GlSanKoor):GlSanKoor;
operator =  (const a,b:GlSanKoor):boolean;
operator ** (const a,b:longint):longint;
operator ** (const a:real;const b:longint):real;
operator *  (const a:GlSanKoor;const b:real):GlSanKoor;
operator /  (const a:GlSanKoor;const b:real):GlSanKoor;
operator = (const a:GlSanKoorPlosk; const b:GlSanKoor):boolean;
operator << (const a:GlSanKoorPlosk; const b:GlSanKoor):real;
operator =  (const a,b:DPoint):boolean;
procedure initgraph;
procedure OpenGL_Init();
procedure GlSanSphere(x1,y1,z1,s:real);
procedure GlSanLineConst(k1,k2:GlSanKoor; n,k:longint);
procedure GlSanLineConst(x1,y1,z1,x2,y2,z2:real; n,k:longint);
procedure GlSanLineConst(x1,y1,z1,x2,y2,z2,p:real);
procedure SanGlMessage;
procedure SanGlLine(x1,y1,z1,x2,y2,z2:real);
procedure GlSanSphere(k:GlSanKoor;s:real);
function fail_est(st:string):boolean;
procedure GlSanLine(x1,y1,z1,x2,y2,z2:real);
procedure GlSanLine(a,b:GlSanKoor);
procedure GlSanQuad(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4:real);
procedure GlSanQuad(a,b,c,d:GlSanKoor);
function Matrix3x3(a1,a2,a3,a4,a5,a6,a7,a8,a9:real):real;
function Matrix2x2(a1,a2,a3,a4:real):real;
function GlSanPloskKoor(x1,y1,z1,x2,y2,z2,x0,y0,z0:real):GlSanKoorPlosk;
function GlSanTP3P(p1,p2,p3:GlSanKoorPlosk):GlSanKoor;
function GlSanPloskKoor(a1,a2,a3:GlSanKoor):GlSanKoorPlosk;
procedure GlSanVertex3f(a:GlSanKoor);
function GlSanLineKoor(a,b:GlSanKoor):GlSanKoorLine;
function GlSanKoorImport(a1,b1,c1:real):GlSanKoor;
function GlSanTP3PP6T(a1,a2,a3,b1,b2,b3,c1,c2,c3:GlSanKoor):GlSanKoor;
function GlSanMoveToch(T:GlSanKoor;P:GlSanKoorLine;NP:longint;R:real):GlSanKoor;
function Matrix4x4(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16:real):real;
function GlSanMoveToch2(T1,T2,T:GlSanKoor;NP:longint;R:real):GlSanKoor;
function RandomABC(Z:REAL):GlSanKoorPlosk;
function GlSanGMP:GlSanKoor2f;
function GlSanRastMinT(a1,a2,b:GlSanKoor):GlSanKoor;
procedure GlSanSwapBuffers;
procedure GlSanMessage;
procedure GlSanLine(q:GlSanOtr);
function GlSanTochkaInOtr(a1,a2,b:GlSanKoor):boolean;
function GlSanMTNP(q:GlSanKoor;NP:longint;R:real):GlSanKoor;
function GlSanTIO(a:GlSanOtr;b:GlSanKoor):boolean;
Function GlSanKeyPressed:boolean;
function GlSanReadKey:longint;
function GlSanStandardExit(q:longint):boolean;
function GlSanMouseReadKey:longint;
procedure GlSanColor(c:GlSanKoor; r:real);
{$IFDEF MSWINDOWS}
	procedure Texture_Init(NameResource:longint);
	{$ENDIF}
function GlSanObject_Quadros(sss:GlSancolor4f):GlSanObject;
function GlSanObject_Quadros(ss:longint):GlSanObject;
{$IFDEF MSWINDOWS}
	function GlSanLoadTexture(NameResource:longint; var x,y:longint):GlUint;
	{$ENDIF}
function GlSanTextureLoad(NameResource:longint):GlUint;
function GlSanLoadTexture(NameResource:longint):GlUint;
procedure InitRot(ob:GlSanObject;yg1,yg2,yg3:real;t:GlSanKoor;r:real);
procedure InitRot(ob:GlSanObject;os:longint;yg:real;t:GlSanKoor;r:real);
function GlSanAfterUntil(q:longint;L,o:boolean):boolean;
function GlSanMouseB(q:longint):boolean;
procedure XO(pp2:boolean);
procedure GlSanTextureActivate2D(a:GLUint);
procedure GlSanLogotip(t:longint;sz:pchar);
function GlSanConvertObjectToMesh(O:GlSanObj):GlSanMesh;
function GlSanMouseC(q:longint):boolean;
function GlSanMouseXY(q:longint):GlSanKoor2f;
procedure InitArray(YK:pointer; T,d:longint);
procedure ConstArray(YK:pointer;D,k:longint);
procedure PrisArray(YK:pointer;T:longint;L:pointer;TipYach:longint);
procedure GlSanClear;
procedure GlSanCircle(l:longint;q:real);
function maximum(q1,q2:real):real;
procedure GlSanSphere(t:glSanKoor;r:real;p1,p2:longint);
{$IFDEF MSWINDOWS}
	function GlSanLoadTexturePoint(n:dword):pointer;
	{$ENDIF}
procedure GlSanOutText(tochka:GlSanKoor;str:string;r:real);
function GlSanLoadBykv(c:char):GlSanABCObj;
function GlSanLoadABCToch(l:longword):GlSanKoor;
function GlSanSmallABC(c:char):boolean;
procedure GlSanSet(q,ya:pointer;TipY:longint);
procedure PA3(q,ya:pointer;TipY:longint);
function GlSanGet(q:pointer):pointer;
function GlSanGetReal(q:pointer):real;
function GlSanGetString(q:pointer):string;
function GlSanGetLongint(q:pointer):longint;
function GlSanGetPChar(q:pointer):pchar;
function GlSanGetChar(q:pointer):char;
function GlSanGetWord(q:pointer):word;
procedure GlSanRamka(t1,t3,t6:GlSanKoor;c1,c2:GlSanColor4f);
function GlSanColor4fImport(a1,a2,a3,a4:real):GlSanColor4f;
function GlSanReadABS(z:longint;k:GlSanKoor2f):real;
function GlSanReadKoor(z:longint;k:GlSanKoor2f):GlSanKoor;
function GlSanStr(a:real):string;
procedure FindNormal(v1x, v1y, v1z, v2x, v2y, v2z, v3x, v3y, v3z : real);
procedure FindNormal(v1,v2,v3:GlSanKoor);
procedure SetNormal();
procedure SetNormal(v1,v2,v3:GlSanKoor);
procedure Proga_Translyater;
procedure Proga_Zastavka1(o:GlSanLightObject);
function  ReadFromFileChar(p:pointer):char;
function ReadFromFileString(p:pointer):string;
function GlSanKoorRavno(a,b:GlSanKoor):boolean;
function GlSanPloskPoroleln(a,b:GlSankoorPlosk):boolean;
function GlSanPloskPrin(pl:GlSanKoorPlosk;a,b:GlSanKoor):boolean;
function GlSanPloskPrin(pl:GlSanKoorPlosk;a:GlSanKoor):boolean;
function GlSanTextLength(str:string;r:real):real;
procedure GlSanSetKey(o:longint);
function GlSanSqr(const Chislo:real;const Stepen:longint):real;
function GlSanMenu(const KolM:longint; const st:GlSanMenuArray; k:longint; const Color:GlSanMenuColors):longint;
procedure GlSanSechPuram4(a:boolean);
procedure GlSanDelay;
procedure GlSanRoundQuad(const T1,T3:GlSanKoor;const R:real;const Kol:longint);
function GlSanStr(const s:longint):string;
procedure GlSanRoundQuadLines(const T1,T3:GlSanKoor;const R:real;const Kol:longint);
function GlSanVal(const s:string):longint;
function GlSanKoor2fImport(const a,b:real):GlSanKoor2f;
function GlSanStrReal(r:real;const l:longint):string;
function GlSanReadMouseXYZ:GlSanKoor;
function GlSanReadCamRast(const r:GlSanKoor2f):real;
function GlSanReadCamXYZ(const r:GlSanKoor2f):GlSanKoor;
function GlSanRast(const a1,b:GlSanKoor):real;
function GlSanMXYZT(const k:GlSanKoor):boolean;
procedure GlSanWindows;
procedure GlSanConstWindows;
procedure Proga_Fracktal_Mandelborg(const boole:boolean;detail:integer);
function GlSanSredKoor(const a,b:GlSanKoor):GlSanKoor;
function GlSanCreateInSys:pointer;
procedure GlSanCircleConst(l:longint;r,s:real);
procedure Proga_Trig(const bool:boolean);
procedure GlSanKillWnd(const p:pointer);
function GlSanFindPredWnd(const p:pointer):pointer;
function GlSanTreugPlosh(const a1,a2,a3:GlSanKoor):real;
procedure Proga_Water(koef,vsplesk:longint);
function GlSanClickZagWnd(const Koor:GlSanKoor; const u:pointer; const z:longint):boolean;
function GlSanFindEndOfWnd():pointer;
function GlSanClickWnd(const Koor:GlSanKoor; const u:pointer; const z:longint):boolean;
procedure GlSanOutText(Koor:GlSanKoor; const s:string; r:GlSanKoor2f);
procedure GlSanOutTextS(Koor:GlSanKoor; const s :string; const r:GlSanKoor2f);
procedure GlSanOutTextS(Koor:GlSanKoor; const s :string; const r:real);
procedure GlSanWndNewButton(const p:pointer; const a,b:GlSanKoor2f; const s:string; const  pb:pointer);
procedure Proga_AnySech(const Kill:boolean; const PObj:pointer);
function GlSanCursorOnButton(const p:pointer; const k:GlSanKoor; const vl,np:GlSanKoor):boolean;
procedure GlSanWndFindKoor(const p:pointer;const z:longint;var t1,t3:GlSanKoor);
procedure GlSanWndSetNewTittleButton(const p:pointer; const l:longint; const NT:string);
procedure GlSanWndNewText(const p:pointer; const a,b:GlSanKoor2f; const s:string);
procedure GlSanLineDontSee(const a,b:GlSanKoor;const r:real);
function GlSanRastT(const a,b:GlSanKoor):GlSanKoor;
procedure GlSanCreateWnd(const  p:pointer;const  s:ansistring; const k2f:GlSanKoor2f);stdcall;
procedure Sphere2Obj3(var O:GlSanObj3);
procedure GlSanWndUserMove(const p:pointer;const l:longint;const a:GlSanKoor2f);
procedure GlSanWndNewButton(const p:pointer; const a,b:GlSanKoor2f; const s:string);
function GlSanWndClickButton(const p:pointer; l:longint):boolean;
procedure GlSanWndDontSeeTittle(const p:pointer);
procedure GlSanWndAllMove(const p:pointer);
procedure GlSanWndSetNewTittleText(const p:pointer; const l:longint; const NT:string);
procedure GlSanWndSetNewColorText(const p:pointer; const l:longint; const color:GlSanWndTextChv);
procedure GlSanWndNewListBox(const p:pointer; const a,b:GlSanKoor2f;  const shri:glsankoor2f; const bol:boolean);
procedure GlSanWndNewStringInLintBox(const p:pointer; const l:longint; const s:string);
procedure GlSanWndListBoxFindKoor(const p:pointer;const li:longint;var bvl,bnp:GlSanKoor);
procedure GlSanWndClearListBox(const p:pointer; const l:longint);
function GlSanWndListBoxFindKB(const p:pointer;const l:longint;const vl,np:GlSanKoor):GlSanKoor;
function GlSanDownKey(const l:longint):boolean;
procedure Proga_Fracktal_Koh3D(const bool:boolean);
procedure GlSanOutText(const bvl:GlSanKoor;bnp:GlSanKoor;const Text:string; const R:real);
function GlSanPrinKoor(const a,b,c:GlSanKoor):boolean;
procedure Proga_BOP(const bool:boolean);
procedure GlSanWndNewStringInLintBox(const p:pointer; const l:longint; const s:string; const Chv:GlSanWndTextChv);
function GlSanSRRF(const name:string;const a,b:string):boolean;
function GlSanWndGetListBoxMVPos(const p:pointer;const l:longint):string;
procedure GlSanWndDeleteListBoxMVPos(const p:pointer;const l:longint);
function GlSanLineCross(p1,p2,p3,p4:glSanKoor):glSanKoor;
procedure Proga_Koh_Cub(const bool:boolean);
procedure Proga_Koh_Kover(const bool:boolean);
procedure Proga_Koh_Puram4(const bool:boolean);
procedure GlSanWndKill(p:longint);
function GSK2(const a:GlSanKoor):GlSanKoor2f;
function GlSanKolChisel(l:longint):longint;
function GlSanRast(const a,b:GlSanKoor2f):real;
procedure Proga_Koh_5U(const bool:boolean);
function GlSanWndClickListBox(const p:pointer; const l:longint):boolean;
procedure GlSanWndSetProc(const p:pointer;const pr:pointer);
procedure GlSanWndDispose(const p:pointer);
procedure NewDelayWindow(Wnd:pointer);
procedure GlSanKillThisWindow(Wnd:pointer);
procedure GlSanWndTaskMsgProc(Wnd1:pointer);
procedure GlSanWndTaskMsgKill(Wnd:pointer);
procedure GlSanNewTaskMgrWnd(Wnd:pointer);
procedure GlSanWndNewProgressBar(const p:pointer; const a,b:GlSanKoor2f);
procedure GlSanWndSetProgressOnProgressBar(const p:pointer; const l:longint; const r:real);
function GlSanWndRunColorWnd4f(const p:pointer; const st:string;const wpr:pointer):pointer;
function GlSanWndGetPointerOfUserMemory(const p:pointer):pointer;
function  GlSanWndTranslentColor4fToColorText(color4f:GlSanColor4f):GlSanWndTextChv;
procedure GlSanWndNewEdit(const p:pointer;const a,b:GlSanKoor2f;const s:string);
procedure GlSanOutTextCursor(const bvl:GlSanKoor;bnp:GlSanKoor;const Text:string; const R:real; const l:longint);
procedure GlSanOutTextCursor(Koor:GlSanKoor; const s:string; const r:GlSanKoor2f; const lll:longint);
procedure GlSanOutTextCursorS(Koor:GlSanKoor; const s:string; const r:GlSanKoor2f; const l:longint);
function GlSanWhatIsTheSimbolRU(const l:longint):string;
procedure GlSanWndNewDependentWnd(const p:pointer;const w:pointer);
procedure GlSanWndOldDependentWnd(const p:pointer;const w:pointer);
{$IFDEF MSWINDOWS}
	function GlSanGetLanguage:String;
	{$ENDIF}
function GlSanWhatIsTheSimbol(const l:longint):string;
function GlSanWhatIsTheSimbolEN(const l:longint):string;
function GlSanPrinQuad(t1,t2,t3,t4:GlSanKoor;curkoor:glSanKoor):boolean;
function GlSanPrinTreug(t1,t2,t3:GlSanKoor;curkoor:glSanKoor):boolean;
function GlSanWndActive(const w:PPGlSanWnd):boolean;
{$IFDEF MSWINDOWS}
	function GlSanLoadStringFromResource(const l:longint):string;
	{$ENDIF}
function GlSanWndRunLoadFile(const tittle:String;const pr,w:pointer; const pa:pointer):pointer;
function GlSanWndGetCaptionFromEdit(const P:pointer;const l:longint):string;
procedure GlSanWndSetNewCaptoinInEdit(const p:pointer;const l:longint; const s:string);
function TranslateStringFromFS(s:string):string;
function TranslateCharFromFS(const c:char):char;
function GlSanWndGetListBoxActivePosition(const p:pointer; const l:longint):longint;
procedure GlSanCreateOKWnd(Wnd:pointer;Zag:string;Text:string);
procedure GlSanWndNewComboBox(const p:pointer; const a,b:GlSanKoor2f);
procedure GlSanWndFindKoorOfComboBox(const p:pointer;const l:longint; var bvl,bnp:GlSanKoor);
function GlSanIDKat(const l:longint):boolean;
function GlSanUpCaseString(s:string):string;
function GlSanRazrOfFile(const s:string):string;
procedure GlSanWndNewStringInComboBox(const p:pointer;const l:longint; const s:string);
function GlSanRandomString:string;
function GlSanWndGetPositionFromComboBox(const p:pointer; const l:longint):longint;
procedure GlSanWndSetPositionOnComboBox(const p:pointer; const l,pl:longint);
function GlSanPointOnPlosk(const P:GlSanKoor;const Pl:GlSanKoorPlosk):boolean;
procedure GlSanWndNewCheckBox(const p:pointer; const a,b:GlSanKoor2f;const bo:boolean);
function GlSanWndGetCaptionFromCheckBox(const p:pointer;const l:longint):boolean;
procedure CubObj3(var O:GlSanObj3);
procedure GlSanWndSetButtonOnClick(const p:pointer; const l:longint; const b:boolean);
procedure GlSanCircle(const k:GlSanKoor;const l:longint;const r:real);
procedure GlSanWndButtonHintAdd(const p:pointer;N:longint;s:string);
procedure GlSanWndSetLastButtonColor(const p:pointer;const l:longint; const c:GlSanColor4f);
function GlSanPrinCub(const kc,km:GlSanKoor;const r:real):boolean;
procedure RNROpenalInit;
procedure RNRImportAudio(Name:string;looping:boolean);
procedure RNRSourcePosImport(n:longint;k:GlSanKoor);
procedure RNRSourceVelImport(n:longint;k:GlSanKoor);
procedure RNRSourceImport(n:longint;Pos,Vel:GlSanKoor;looping:boolean);
procedure RNRListenerImport(Pos,Vel:GlSanKoor);
procedure RNRListenerPosImport(k:GlSanKoor);
procedure RNRListenerVelImport(k:GlSanKoor);
procedure RNRListenerOriImport(i,k:GlSanKoor);
procedure RNRListenerImport(Pos,Vel,OriT,OriV:GlSanKoor);
procedure RNRPlayAudio(n:longint);
procedure RNRClearExit;
procedure RNRSourceNewPosByVel(n:longint);
procedure RNRPlayAudio(s:string);
function GlSanCopy(const s:string;const l1,l2:longint):string;
procedure RNRPlayRamdomNo;
procedure GlSanWndSetTittleHeight( const p:pointer; const h:longint);
procedure RNRPlayRamdomYes;
procedure RNRSourceImport(n:string;Pos,Vel:GlSanKoor;looping:boolean);
procedure glLoadIdentity;
procedure glTranslatef(const i,ii,iii:real);
procedure glSanBindTexture(var q:GLUInt);
procedure SomeQuad(a,b,c,d:GlSanKoor;vl,np:GlSanKoor2f);
procedure GlSanPOPFont;
procedure GlSanPushFont;
procedure GlSanCorrectFont(const b:boolean);
function GlSanSetFont(const s:string):boolean;
function GlSanGetFontNumber(Name:string):longint;
function GlSanBindTexture( FileName:string):boolean;
procedure GlSanWndSetInitProc(const p:pointer;const pr:pointer);
function GlSanWndGetWndKoor(const p:PPGlSanWnd; const k2:GlSanKoor2f):GlSanKoor;
procedure WndSomeQuad(a,c:GlSanKoor);
procedure GlSanWndSetLastButtonTexture(const p:PPGlSanWnd;const s:string);
procedure GlSanWndSetLastButtonTextureClick(const p:PPGlSanWnd;const s:string);
procedure GlSanWndSetButtonTexture(const p:PPGlSanWnd;const idb:longint;const s:string);
procedure GlSanWndSetButtonTextureClick(const p:PPGlSanWnd;const idb:longint;const s:string);
procedure GlSanWndVertex(const PPW:PPGlSanWnd;K:GlSanKoor);
procedure GlSanDrawComponent9Button(const TVL,TNP:GlSanKoor; const r:real;const Tip:longint);
function PutPointToPolygone(p1,p2,p3,a:GlSanKoor):GlSanKoor;
function GetNormalVector(p1,p2,p3:GlSanKoor):GlSanKoor;
function  GlSanGetPerpedKoor(const t1,t2,t:GlSanKoor):GlSanKoor;
function GlSanPrinOtr(const t1,t2,t:GlSanKoor):boolean;
function GlSanGetPeresLines(const q1,q2,w1,w2:GlSanKoor):GlSanKoor;
procedure GlSanDrawComponent9(const TVL,TNP:GlSanKoor; const r:real; const ots1,ots2,ots3,ots4:real; const IDText:GLUInt);
procedure GlSanOutTextS(const bvl:GlSanKoor;bnp:GlSanKoor;const Text:string; const R:real);
function GlSanMinimum(const r1,r2:real):real;
function GlSanKoorOnLine(const t,t1,t2:GlSanKoor):boolean;
function GlSanRazn(const a,b:GlSanKoorPlosk):boolean;
procedure RNRPlayAudioNotError(s:string);
function GlSanGetOtn(const t,t1,t2:GlSanKoor):real;
function GlSanGetKoor(const t1,t2:GlSanKoor; const r:real):GlSanKoor;
function GetRadOkr( const bvl,bnp:GlSanKoor; const RadOkr:real):real;
function GlSanWndPrinKoor(const a,b,c:GlSanKoor):boolean;
procedure GlSanWndSetNewTittle(const p:PPGlSanWnd; const s:string);
procedure GlSanWndSetNewSystemTittle(const p:PPGlSanWnd; const s:string);
procedure GlSanWndSetButtonTextureOnClick(const p:PPGlSanWnd;const idb:longint;const s:string);
procedure GlSanWndSetLastButtonTextureOnClick(const p:PPGlSanWnd;const s:string);
procedure GlSanContextMenuMake(const p:PGlSanContextMenu; const w:PPGlSanWnd; const prc:pointer);
procedure GlSanContextMenuBeginning(var p:PGlSanContextMenu);
procedure GlSanContextMenuSetLength(const p:PGlSanContextMenu; const l:longint);
procedure GlSanContextMenuSetString(const p:PGlSanContextMenu; const s:longint; const l:string);
procedure GlSanContextMenuSetProcedure(const p:PGlSanContextMenu; const s:longint; const l:pointer);
procedure GlSanContextMenuSetIntoContextFunction(const p:PGlSanContextMenu; const s:longint; const l:pointer);
procedure GlSanContextMenuIntoMake(var p:PGlSanContextMenu; const w:PPGlSanWnd; const prc:pointer; var f:PGlSanContextMenu);
procedure GlSanSetReOut(const pp:PPGlSanWnd);
function GlSanGetReOut(const pp:PPGlSanWnd):boolean;
function GlSanFindTexture(const s:string):boolean;
procedure GlSanContextMenuSetIcon(var p:PGlSanContextMenu;const l:longint;const SIco:string;const z:GlSanKoor2f);
procedure GlSanContextMenuSetIcon(var p:PGlSanContextMenu;const l:longint;const SIco:string);
procedure WndSomeQuad(const a,c:GlSanKoor; const a1,c1:GlSanKoor2f; const IDt:GLUInt);
procedure WndSomeQuad(const a,c:GlSanKoor; const a1,c1:GlSanKoor2f);
procedure GlSanContextMenuAddString(const p:PGlSanContextMenu;const s:string; const v:longint; const p1:pointer);
procedure GlSanContextMenuSetIconToLast(var p:PGlSanContextMenu;const SIco:string;const z:GlSanKoor2f);
function GlSanLoadTexture(const fn:string):GLUInt;
procedure GlSanWndSetHeight(const wND:PPGlSanWnd; const h:real);
procedure ProcDelay(DelayWindow:pointer);
procedure GlSanKillContext(w:PGlSanWnd);
procedure Proverca;
procedure GlSanPack(const p:pointer;const sf:string);
function GlSanByteSize(const s:string):longint;
procedure GlSanUnPack(const sf,sfol:string);
procedure GlSanContextMenuSetViewType(const p:PGlSanContextMenu; const l:longint);
procedure GlSanContextMenuSetIconsZum(const p:PGlSanContextMenu; const c:GlSanKoor2f);
procedure GlSanDisableTexture;
procedure GlSanMultyTred;
procedure GlSanGoMultyTred(const p:pointer);
procedure Proga_TranslaterObj3(sf,sm,sp:string; const Vih:boolean);//(var O:GlSanObj3);
procedure DadekaedrObj3(var O:GlSanObj3); 
function IsContextFree:boolean;
procedure GlSanWndNewCloseButton(const w:PPGlSanWnd);
function GlSanWndGetOnPositionFromListBox(const w:PPGlSanWnd;const l:longint):longint;
procedure GlSanWndNewImage(const p:PPGlSanWnd;const a,b:GlSanKoor2f;const IDT:GLUInt);
procedure GlSanWNdSetImageTexture(const p:PPGlSanWnd;const l:longint;const IDT:GLUInt);
function GlSanGetGLUint(const s:string):GLUInt;
procedure ICOSphereObj3(var O:GlSanObj3); 
procedure IkosaedrObj3(var O:GlSanObj3);
procedure OktaedrObj3(var O:GlSanObj3); 
procedure ParalilepipedObj3(var O:GlSanObj3); 
procedure TruePrizma3Obj3(var O:GlSanObj3);
procedure TruePrizma6Obj3(var O:GlSanObj3); 
procedure FalseParalilepiped4Obj3(var O:GlSanObj3); 
function GlSanStartThread2(p:pointer):longint;stdcall;
function GlSanStartThread(p:pointer):THandle;
function GlSanLineToPlosk(const a1,a2,a3,q1,q2:GlSanKoor):GlSanKoor;
function GlSanWndGetWANumber(const i:longint):longint;
function GlSanMinimum(const a,b:longint):longint;
procedure WndSomeQuadNotTexture(const a,c:GlSanKoor);
procedure GlSanWndSetLastTextParametrs(const p:PPGlSanWnd;const PS,PF:GlSanParametr);
procedure GlSanWndSetTextParametrs(const p:PPGlSanWnd; const l:longint; const PS,PF:GlSanParametr);
function GlSanPrinPolygone(const pv,pf:pointer; const curkoor:glsankoor):boolean;
procedure NewReadKeyWnd(Wnd:pointer);
procedure NewTaskMgrSoundsWnd(wnd:pointer);
procedure StartTMFots(w:pointer);
procedure GlSanUpLoadTexture(var ID:GLUint);
procedure GlSanNewProgramInBuffer(const N,I:string;const p:pointer);
function GlSanWndGenInf(const l:longint):boolean;
procedure GlSanWndSetInf(const p:PPGlSanWnd; const l:longint);
procedure GlSanWndSetIcon(const p:PPGlSanWnd; const s:string);
procedure GlSanContextMenuSetIconsZum(const p:PGlSanContextMenu;const r:real);
procedure GlSanContextMenuSetZum(const p:PGlSanContextMenu;const r:real);
procedure GlSanWndSetProgramName(const p:PPGlSanWnd; const s:string);
procedure GlSanWndNewConsole(const p:PPGlSanWnd;const a,b:GlSanKoor2f;const XY:GlSanKoor2f);
procedure RemoveFileTree(const Path: string);
function GlSanStringToPChar(const s:string):PCHAR;

implementation 
{-------------------------------------------------}
{*************************************************}
{$NOTE >>|<   Begining    Implementation   >|<<}
{*************************************************}
{-------------------------------------------------}

function GlSanStringToPChar(const s:string):PCHAR;
var
	c:array of char;
	i:longint;
begin
SetLength(c,Length(s));
for i:=Low(c) to High(c) do
	c[i]:=s[i+1];
GlSanStringToPChar:=PChar(c);
end;
procedure RemoveFileTree(const Path: string);
var 
	Found: integer;
	SearchRec: TSearchRec;
	FileName: string;
begin
Found:= FindFirst(Path + '\*.*', faAnyFile, SearchRec);
while Found = 0 do
	begin
	if ((SearchRec.Attr and faDirectory) = faDirectory) then
		if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then 
			RemoveFileTree(Path+'\'+SearchRec.Name)
		else
			
	else
		begin
		FileName:= Path+'\'+SearchRec.Name+#0;
		DeleteFile(PChar(@FileName));
		end;
	Found:= FindNext(SearchRec);
	end;
SysUtils.FindClose(SearchRec);
RemoveDir(Path);
end;
procedure GlSanWndNewConsole(const p:PPGlSanWnd;const a,b:GlSanKoor2f;const XY:GlSanKoor2f);
var
	i,ii:longint;
begin
if (p<>nil) and (p^<>nil) then
	begin
	SetLength(p^^.ArConsole,Length(P^^.ArConsole)+1);
	P^^.ArConsole[High(P^^.ArConsole)].OVL.Import(a.x/p^^.WndW,a.y/p^^.WndH);
	P^^.ArConsole[High(P^^.ArConsole)].ONP.Import(b.x/p^^.WndW,b.y/p^^.WndH);
	P^^.ArConsole[High(P^^.ArConsole)].ShowCursor:=true;
	P^^.ArConsole[High(P^^.ArConsole)].BigCursor:=false;
	P^^.ArConsole[High(P^^.ArConsole)].CursorX:=1;
	P^^.ArConsole[High(P^^.ArConsole)].CursorY:=1;
	P^^.ArConsole[High(P^^.ArConsole)].ColorText:=GlSanColor4fImport(1,1,1,1);
	P^^.ArConsole[High(P^^.ArConsole)].ColorBackGround:=GlSanColor4fImport(0,0,0,1);
	P^^.ArConsole[High(P^^.ArConsole)].MovePosition:=1;
	P^^.ArConsole[High(P^^.ArConsole)].MaxX:=round(XY.X);
	P^^.ArConsole[High(P^^.ArConsole)].MaxY:=round(XY.Y);
	SetLength(P^^.ArConsole[High(P^^.ArConsole)].Things,P^^.ArConsole[High(P^^.ArConsole)].MaxY);
	for i:=Low(P^^.ArConsole[High(P^^.ArConsole)].Things) to High(P^^.ArConsole[High(P^^.ArConsole)].Things) do
		begin
		SetLength(P^^.ArConsole[High(P^^.ArConsole)].Things[i],P^^.ArConsole[High(P^^.ArConsole)].MaxX);
		for ii:=Low(P^^.ArConsole[High(P^^.ArConsole)].Things[i]) to High(P^^.ArConsole[High(P^^.ArConsole)].Things[i]) do
			begin
			P^^.ArConsole[High(P^^.ArConsole)].Things[i][ii].Char:=' ';
			P^^.ArConsole[High(P^^.ArConsole)].Things[i][ii].ColorText:=P^^.ArConsole[High(P^^.ArConsole)].ColorText;
			P^^.ArConsole[High(P^^.ArConsole)].Things[i][ii].ColorBackGround:=P^^.ArConsole[High(P^^.ArConsole)].ColorBackGround;
			end;
		end;
	end;
end;
procedure GlSanWndSetProgramName(const p:PPGlSanWnd; const s:string);
begin
if (p<>nil) and (p^<>nil) then
	begin
	p^^.ProgramName:=s;
	end;
end;
procedure GlSanContextMenuSetZum(const p:PGlSanContextMenu;const r:real);
begin
if (p<>nil) then
	p^.ContextMenuZum:=r*StandardContextMenuZum;
end;
procedure GlSanContextMenuSetIconsZum(const p:PGlSanContextMenu;const r:real);
begin
if (p<>nil) then
	p^.ContextMenuZum:=r*StandardContextMenuIconZum;
end;
procedure GlSanWndSetIcon(const p:PPGlSanWnd; const s:string);
begin
if (p<>nil) and (p^<>nil) and (GlSanFindTexture(s)) then
	p^^.Icon:=s;
end;
procedure GlSanWndSetInf(const p:PPGlSanWnd; const l:longint);
begin
if (p<>nil) and (p^<>nil) then
	p^^.InfWorld:=l;
end;
function GlSanWndGenInf(const l:longint):boolean;
var
	i:longint;
	a:packed array of string  = nil;
begin
GlSanWndGenInf:=TRUE;
CASE l of
GSB_INF_ALL:
	begin
	for i:=Low(GlSanWinds) to High(GlSanWinds) do
		if GlSanWinds[i]^.InfWorld in [GSB_INF_ALL,GSB_INF_SOMETHING] then
			begin
			GlSanWndGenInf:=false;
			SetLength(a,Length(a)+1);
			a[High(a)]:=GlSanWinds[i]^.Tittle+'  ('+GlSanWinds[i]^.ProgramName+')';
			end;
	end;
GSB_INF_SOMETHING:
	begin
	for i:=Low(GlSanWinds) to High(GlSanWinds) do
		if GlSanWinds[i]^.InfWorld in [GSB_INF_ALL] then
			begin
			GlSanWndGenInf:=false;
			SetLength(a,Length(a)+1);
			a[High(a)]:=GlSanWinds[i]^.Tittle+'  ('+GlSanWinds[i]^.ProgramName+')';
			end;
	end;
end;
if GlSanWndGenInf=false then
	begin
	GlSanCreateWnd(@NewWnd,'Предупреждение.',glSanKoor2fImport(300,150+25*Length(a)));
	GlSanWndNewText(@NewWnd,GlSanKoor2fImport(5,40),GlSanKoor2fImport(295,65),'Неудалось запустить программу.');
	GlSanWndNewText(@NewWnd,GlSanKoor2fImport(5,70),GlSanKoor2fImport(295,95),'Закройте следующие(-ю) программы(-у),');
	GlSanWndNewText(@NewWnd,GlSanKoor2fImport(5,100),GlSanKoor2fImport(195,125),'и повторите попытку...');
	for i:=Low(A) TO High(a) do
		begin
		GlSanWndNewText(@NewWnd,GlSanKoor2fImport(5,125+25*(i)),GlSanKoor2fImport(295,125+25*(i+1)-5),a[i]);
		GlSanWndSetLastTextParametrs(@NewWnd,GSB_LEFT_TEXT,GSB_CANCULATE_HEIGHT);
		GlSanWndSetNewColorText(@NewWnd,3+i+1,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(1,0.3,0.3,0.8)));
		end;
	GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(110,155+25*Length(a)-35),GlSanKoor2fImport(190,150+25*Length(a)-5),'Ок',@GlSanKillThisWindow);
	GlSanWndDispose(@NewWnd);
	end;
SetLength(a,0);
end;
procedure GlSanNewProgramInBuffer(const N,I:string;const p:pointer);
begin
SetLength(ArPrograms,Length(ArPrograms)+1);
ArPrograms[High(ArPrograms)].Name:=N;
ArPrograms[High(ArPrograms)].Icon:=i;
ArPrograms[High(ArPrograms)].Proc:=p;
end;
procedure GlSanUpLoadTexture(var ID:GLUint);
begin
glDeleteTextures(0,@ID);
end;
procedure CloseSystem(Wnd:pointer);
begin
SaGe.SGCloseContext;
end;

function ProgramsOfSystemStandard(W:PGlSanWnd):pointer;
begin
GlSanContextMenuBeginning(NewContext);
GlSanContextMenuSetViewType(NewContext,GL_SAN_TEXT_AND_ICONS);
GlSanContextMenuAddString(NewContext,'Выбор шрифтов',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@StartTMFots);
GlSanContextMenuSetIconToLast(NewContext,'SystemFontsMgr',GlSanKoor2fImport(4,2));
GlSanContextMenuAddString(NewContext,'Менеджер звуков',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@NewTaskMgrSoundsWnd);
GlSanContextMenuSetIconToLast(NewContext,'SystemSoundsMgr',GlSanKoor2fImport(4,2));
GlSanContextMenuAddString(NewContext,'Считыватель клавиш',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@NewReadKeyWnd);
GlSanContextMenuSetIconToLast(NewContext,'SystemReadKey',GlSanKoor2fImport(4,2));
GlSanContextMenuAddString(NewContext,'Диспетчер задач',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@GlSanNewTaskMgrWnd);
GlSanContextMenuSetIconToLast(NewContext,'SystemTaskMgr',GlSanKoor2fImport(4,2));
GlSanContextMenuIntoMake(NewContext,@w,nil,ProgramsOfSystemStandard);
end;
function ProgramsOfSystem(Wnd:pointer):pointer;
var
	i:longint;
begin
GlSanContextMenuBeginning(NewContext);
GlSanContextMenuSetViewType(NewContext,GL_SAN_TEXT_AND_ICONS);
for i:=Low(ArPrograms) to High(ArPrograms) do
	begin
	GlSanContextMenuAddString(NewContext,ArPrograms[i].Name,GL_SAN_CONTEXT_ENABLED_PROCEDURE,ArPrograms[i].Proc);
	GlSanContextMenuSetIconToLast(NewContext,ArPrograms[i].Icon,GlSanKoor2fImport(4,2));
	end;
GlSanContextMenuAddString(NewContext,'Cистемные',GL_SAN_CONTEXT_ENABLED_FUNCTION,@ProgramsOfSystemStandard);
GlSanContextMenuSetIconToLast(NewContext,'SystemDir',GlSanKoor2fImport(4,2));
GlSanContextMenuIntoMake(NewContext,@wnd,nil,ProgramsOfSystem);
end;
procedure MenuWindowProc(Wnd:pointer);
begin
GlSanWndUserMove(@Wnd,1,GlSanKoor2fImport(1,height-30));
if GlSanWndClickButton(@Wnd,1) then
	begin
	GlSanContextMenuBeginning(NewContext);
	GlSanContextMenuSetViewType(NewContext,GL_SAN_TEXT_AND_ICONS);
	GlSanContextMenuAddString(NewContext,'Программы',GL_SAN_CONTEXT_ENABLED_FUNCTION,@ProgramsOfSystem);
	GlSanContextMenuSetIconToLast(NewContext,'SystemApplications',GlSanKoor2fImport(4,2));
	GlSanContextMenuAddString(NewContext,'Выход',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@CloseSystem);
	GlSanContextMenuSetIconToLast(NewContext,'SystemOff',GlSanKoor2fImport(4,2));
	GlSanContextMenuMake(NewContext,@Wnd,nil);
	end;
end;
procedure NewMenuWindow;
begin
GlSanCreateWnd(@NewWnd,'SGMenu',glSanKoor2fImport(30,30));
GlSanWndSetProc(@NewWnd,@MenuWindowProc);
NewWnd^.ZagP:=false;
NewWnd^.TeloP:=false;
NewWnd^.TittleSystem:='System';
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(0,0),GlSanKoor2fImport(30,30),'');
GlSanWndUserMove(@NewWnd,1,GlSanKoor2fImport(width-30,1));
GlSanWndSetLastButtonTexture(@NewWnd,'SystemMenu1');
GlSanWndSetLastButtonTextureOnClick(@NewWnd,'SystemMenu2');
GlSanWndSetLastButtonTextureClick(@NewWnd,'SystemMenu3');
GlSanWndDispose(@NewWnd);
end;
operator = (const a:GlSanKoorPlosk; const b:GlSanKoor):boolean;
begin
result := abs(a<<b)<GlSanWndMin;
end;

function GlSanPrinPolygone(const pv,pf:pointer; const curkoor:glsankoor):boolean;
type
	ArV=array of glsankoor;
	ArF=array of longint;
var
	v:^ArV;
	f:^ArF;
	i:longint;
	Koor:glsankoor;
begin
v:=pv;
f:=pf;
GlSanPrinPolygone:=false;
Koor:=v^[f^[0]];
for i:=Low(f^)+1 to High(f^)-1 do
	if not GlSanPrinPolygone then
		begin
		if GlSanPrinTreug(Koor,v^[f^[i]],v^[f^[i+1]],curkoor) then
			GlSanPrinPolygone:=true;
		end;
end;
procedure WndSomeQuadNotTexture(const a,c:GlSanKoor);
var
	b,d:GlSanKoor;
begin
b.Import(c.x,a.y,a.z);
d.Import(a.x,c.y,a.z);
glBegin(GL_QUADS);
a.Vertex;
b.Vertex;
c.Vertex;
d.Vertex;
glEnd;
end;
function GlSanMinimum(const a,b:longint):longint;
begin
if a>b then
	GlSanMinimum:=b
else
	GlSanMinimum:=a;
end;

procedure GlSanWndConsole.Init(const vl,np:GlSanKoor; const Verh:boolean; const _:real);
var
	razn:GlSanKoor2f;
	bvl,bnp:GlSanKoor;
	x1,y1:real;
	i,ii:longint;
	k1,k2:GlSanKoor;
begin
Razn.Import(abs(vl.x-np.x),abs(vl.y-np.y));
bvl.Import(vl.x+razn.x*OVL.x,vl.y-razn.y*ovl.y,vl.z);
bnp.Import(vl.x+razn.x*onp.x,vl.y-razn.y*onp.y,np.z);
x1:=abs(bnp.x-bvl.x)/MaxX;
y1:=abs(bnp.y-bvl.y)/MaxY;
if MovePosition+MaxY>Length(Things) then
	begin
	MovePosition:=Length(Things)-MaxY;
	end;
for i:=MovePosition to GlSanMinimum(Length(Things),MovePosition+MaxY) do
	begin
	for ii:=Low(Things[i]) to High(Things[i]) do
		begin
		k1.Import(bvl.x+(i-MovePosition  )*x1,bvl.y-(i-MovePosition  )*y1,bvl.z);
		k2.Import(bvl.x+(i-MovePosition+1)*x1,bvl.y-(i-MovePosition+1)*y1,bvl.z);
		Things[i][ii].ColorBackGround.Color;
		WndSomeQuadNotTexture(k1,k2);
		end;
	end;
end;

function GlSanWndGetWANumber(const i:longint):longint;
begin
if i<0 then
	GlSanWndGetWANumber:=0
else
	GlSanWndGetWANumber:=i;
end;

function GlSanStartThread2(p:pointer):longint;stdcall;
var
	pr:TProcedure;
begin
GlSanStartThread2:=1;
pr:=TProcedure(p);
pr;
end;
function GlSanStartThread(p:pointer):THandle;
var
	IDT:longword;
begin
GlSanStartThread:=CreateThread(nil,1024*8*1024,@GlSanStartThread2,p,0,IDT);
end;
procedure FalseParalilepiped4Obj3(var O:GlSanObj3); 

procedure SetLengths;
begin
O.Dispose;
SetLength(O.V,8);
SetLength(O.F,6);
SetLength(O.F[0],4);
SetLength(O.F[1],4);
SetLength(O.F[2],4);
SetLength(O.F[3],4);
SetLength(O.F[4],4);
SetLength(O.F[5],4);
end;

begin
SetLengths;
O.V[0].Import(1.500000,1.000000,-1.000000);
O.V[1].Import(1.500000,-1.000000,-1.900000);
O.V[2].Import(-1.500000,-1.000000,-1.900000);
O.V[3].Import(-1.500000,1.000000,-1.000000);
O.V[4].Import(1.500000,0.999999,1.000000);
O.V[5].Import(1.499999,-1.000001,0.100000);
O.V[6].Import(-1.500000,-1.000000,0.100000);
O.V[7].Import(-1.500000,1.000000,1.000000);
O.F[0,0]:=3;
O.F[0,1]:=2;
O.F[0,2]:=1;
O.F[0,3]:=0;
O.F[1,0]:=5;
O.F[1,1]:=6;
O.F[1,2]:=7;
O.F[1,3]:=4;
O.F[2,0]:=1;
O.F[2,1]:=5;
O.F[2,2]:=4;
O.F[2,3]:=0;
O.F[3,0]:=2;
O.F[3,1]:=6;
O.F[3,2]:=5;
O.F[3,3]:=1;
O.F[4,0]:=3;
O.F[4,1]:=7;
O.F[4,2]:=6;
O.F[4,3]:=2;
O.F[5,0]:=7;
O.F[5,1]:=3;
O.F[5,2]:=0;
O.F[5,3]:=4;
end;
procedure TruePrizma6Obj3(var O:GlSanObj3); 

procedure SetLengths;
begin
O.Dispose;
SetLength(O.V,12);
SetLength(O.F,8);
SetLength(O.F[0],6);
SetLength(O.F[1],6);
SetLength(O.F[2],4);
SetLength(O.F[3],4);
SetLength(O.F[4],4);
SetLength(O.F[5],4);
SetLength(O.F[6],4);
SetLength(O.F[7],4);
end;

begin
SetLengths;
O.V[0].Import(0.707107,0.707107,-1.000000);
O.V[1].Import(0.965926,-0.258819,-1.000000);
O.V[2].Import(0.258819,-0.965926,-1.000000);
O.V[3].Import(-0.707107,-0.707107,-1.000000);
O.V[4].Import(-0.965926,0.258819,-1.000000);
O.V[5].Import(-0.258819,0.965926,-1.000000);
O.V[6].Import(0.707107,0.707107,1.000000);
O.V[7].Import(0.965926,-0.258819,1.000000);
O.V[8].Import(0.258819,-0.965926,1.000000);
O.V[9].Import(-0.707106,-0.707107,1.000000);
O.V[10].Import(-0.965926,0.258818,1.000000);
O.V[11].Import(-0.258820,0.965926,1.000000);
O.F[0,0]:=7;
O.F[0,1]:=6;
O.F[0,2]:=11;
O.F[0,3]:=10;
O.F[0,4]:=9;
O.F[0,5]:=8;
O.F[1,0]:=3;
O.F[1,1]:=4;
O.F[1,2]:=5;
O.F[1,3]:=0;
O.F[1,4]:=1;
O.F[1,5]:=2;
O.F[2,0]:=0;
O.F[2,1]:=6;
O.F[2,2]:=7;
O.F[2,3]:=1;
O.F[3,0]:=1;
O.F[3,1]:=7;
O.F[3,2]:=8;
O.F[3,3]:=2;
O.F[4,0]:=2;
O.F[4,1]:=8;
O.F[4,2]:=9;
O.F[4,3]:=3;
O.F[5,0]:=3;
O.F[5,1]:=9;
O.F[5,2]:=10;
O.F[5,3]:=4;
O.F[6,0]:=4;
O.F[6,1]:=10;
O.F[6,2]:=11;
O.F[6,3]:=5;
O.F[7,0]:=6;
O.F[7,1]:=0;
O.F[7,2]:=5;
O.F[7,3]:=11;
end;
procedure TruePrizma3Obj3(var O:GlSanObj3);

procedure SetLengths;
begin
O.Dispose;
SetLength(O.V,6);
SetLength(O.F,5);
SetLength(O.F[0],3);
SetLength(O.F[1],3);
SetLength(O.F[2],4);
SetLength(O.F[3],4);
SetLength(O.F[4],4);
end;

begin
SetLengths;
O.V[0].Import(0.707107,0.707107,-1.000000);
O.V[1].Import(0.258819,-0.965926,-1.000000);
O.V[2].Import(-0.965926,0.258819,-1.000000);
O.V[3].Import(0.707107,0.707106,1.000000);
O.V[4].Import(0.258819,-0.965926,1.000000);
O.V[5].Import(-0.965926,0.258819,1.000000);
O.F[0,0]:=0;
O.F[0,1]:=1;
O.F[0,2]:=2;
O.F[1,0]:=5;
O.F[1,1]:=4;
O.F[1,2]:=3;
O.F[2,0]:=0;
O.F[2,1]:=3;
O.F[2,2]:=4;
O.F[2,3]:=1;
O.F[3,0]:=1;
O.F[3,1]:=4;
O.F[3,2]:=5;
O.F[3,3]:=2;
O.F[4,0]:=3;
O.F[4,1]:=0;
O.F[4,2]:=2;
O.F[4,3]:=5;
end;

procedure ParalilepipedObj3(var O:GlSanObj3); 

procedure SetLengths;
begin
O.Dispose;
SetLength(O.V,8);
SetLength(O.F,6);
SetLength(O.F[0],4);
SetLength(O.F[1],4);
SetLength(O.F[2],4);
SetLength(O.F[3],4);
SetLength(O.F[4],4);
SetLength(O.F[5],4);
end;

begin
SetLengths;
O.V[0].Import(1.500000,1.000000,-1.000000);
O.V[1].Import(1.500000,-1.000000,-1.000000);
O.V[2].Import(-1.500000,-1.000000,-1.000000);
O.V[3].Import(-1.500000,1.000000,-1.000000);
O.V[4].Import(1.500000,0.999999,1.000000);
O.V[5].Import(1.499999,-1.000001,1.000000);
O.V[6].Import(-1.500000,-1.000000,1.000000);
O.V[7].Import(-1.500000,1.000000,1.000000);
O.F[0,0]:=3;
O.F[0,1]:=2;
O.F[0,2]:=1;
O.F[0,3]:=0;
O.F[1,0]:=5;
O.F[1,1]:=6;
O.F[1,2]:=7;
O.F[1,3]:=4;
O.F[2,0]:=1;
O.F[2,1]:=5;
O.F[2,2]:=4;
O.F[2,3]:=0;
O.F[3,0]:=2;
O.F[3,1]:=6;
O.F[3,2]:=5;
O.F[3,3]:=1;
O.F[4,0]:=3;
O.F[4,1]:=7;
O.F[4,2]:=6;
O.F[4,3]:=2;
O.F[5,0]:=7;
O.F[5,1]:=3;
O.F[5,2]:=0;
O.F[5,3]:=4;
end;
procedure OktaedrObj3(var O:GlSanObj3); 

procedure SetLengths;
begin
O.Dispose;
SetLength(O.V,6);
SetLength(O.F,8);
SetLength(O.F[0],3);
SetLength(O.F[1],3);
SetLength(O.F[2],3);
SetLength(O.F[3],3);
SetLength(O.F[4],3);
SetLength(O.F[5],3);
SetLength(O.F[6],3);
SetLength(O.F[7],3);
end;

begin
SetLengths;
O.V[0].Import(-1.000000,-1.000000,0.000000);
O.V[1].Import(1.000000,-1.000000,0.000000);
O.V[2].Import(1.000000,1.000000,0.000000);
O.V[3].Import(-1.000000,1.000000,0.000000);
O.V[4].Import(0.000000,0.000000,-1.000000);
O.V[5].Import(0.000000,0.000000,1.000000);
O.F[0,0]:=5;
O.F[0,1]:=0;
O.F[0,2]:=1;
O.F[1,0]:=5;
O.F[1,1]:=1;
O.F[1,2]:=2;
O.F[2,0]:=5;
O.F[2,1]:=2;
O.F[2,2]:=3;
O.F[3,0]:=5;
O.F[3,1]:=3;
O.F[3,2]:=0;
O.F[4,0]:=4;
O.F[4,1]:=0;
O.F[4,2]:=1;
O.F[5,0]:=4;
O.F[5,1]:=1;
O.F[5,2]:=2;
O.F[6,0]:=4;
O.F[6,1]:=2;
O.F[6,2]:=3;
O.F[7,0]:=4;
O.F[7,1]:=3;
O.F[7,2]:=0;
end;
procedure IkosaedrObj3(var O:GlSanObj3);

procedure SetLengths;
begin
O.Dispose;
SetLength(O.V,12);
SetLength(O.F,20);
SetLength(O.F[0],3);
SetLength(O.F[1],3);
SetLength(O.F[2],3);
SetLength(O.F[3],3);
SetLength(O.F[4],3);
SetLength(O.F[5],3);
SetLength(O.F[6],3);
SetLength(O.F[7],3);
SetLength(O.F[8],3);
SetLength(O.F[9],3);
SetLength(O.F[10],3);
SetLength(O.F[11],3);
SetLength(O.F[12],3);
SetLength(O.F[13],3);
SetLength(O.F[14],3);
SetLength(O.F[15],3);
SetLength(O.F[16],3);
SetLength(O.F[17],3);
SetLength(O.F[18],3);
SetLength(O.F[19],3);
end;

begin
SetLengths;
O.V[0].Import(0.000000,0.000000,-1.000000);
O.V[1].Import(0.723600,-0.525720,-0.447215);
O.V[2].Import(-0.276385,-0.850640,-0.447215);
O.V[3].Import(-0.894425,0.000000,-0.447215);
O.V[4].Import(-0.276385,0.850640,-0.447215);
O.V[5].Import(0.723600,0.525720,-0.447215);
O.V[6].Import(0.276385,-0.850640,0.447215);
O.V[7].Import(-0.723600,-0.525720,0.447215);
O.V[8].Import(-0.723600,0.525720,0.447215);
O.V[9].Import(0.276385,0.850640,0.447215);
O.V[10].Import(0.894425,0.000000,0.447215);
O.V[11].Import(0.000000,0.000000,1.000000);
O.F[0,0]:=2;
O.F[0,1]:=0;
O.F[0,2]:=1;
O.F[1,0]:=1;
O.F[1,1]:=0;
O.F[1,2]:=5;
O.F[2,0]:=3;
O.F[2,1]:=0;
O.F[2,2]:=2;
O.F[3,0]:=4;
O.F[3,1]:=0;
O.F[3,2]:=3;
O.F[4,0]:=5;
O.F[4,1]:=0;
O.F[4,2]:=4;
O.F[5,0]:=1;
O.F[5,1]:=5;
O.F[5,2]:=10;
O.F[6,0]:=2;
O.F[6,1]:=1;
O.F[6,2]:=6;
O.F[7,0]:=3;
O.F[7,1]:=2;
O.F[7,2]:=7;
O.F[8,0]:=4;
O.F[8,1]:=3;
O.F[8,2]:=8;
O.F[9,0]:=5;
O.F[9,1]:=4;
O.F[9,2]:=9;
O.F[10,0]:=10;
O.F[10,1]:=6;
O.F[10,2]:=1;
O.F[11,0]:=6;
O.F[11,1]:=7;
O.F[11,2]:=2;
O.F[12,0]:=7;
O.F[12,1]:=8;
O.F[12,2]:=3;
O.F[13,0]:=8;
O.F[13,1]:=9;
O.F[13,2]:=4;
O.F[14,0]:=9;
O.F[14,1]:=10;
O.F[14,2]:=5;
O.F[15,0]:=6;
O.F[15,1]:=10;
O.F[15,2]:=11;
O.F[16,0]:=7;
O.F[16,1]:=6;
O.F[16,2]:=11;
O.F[17,0]:=8;
O.F[17,1]:=7;
O.F[17,2]:=11;
O.F[18,0]:=9;
O.F[18,1]:=8;
O.F[18,2]:=11;
O.F[19,0]:=10;
O.F[19,1]:=9;
O.F[19,2]:=11;
end;
procedure ICOSphereObj3(var O:GlSanObj3); 

procedure SetLengths;
begin
O.Dispose;
SetLength(O.V,42);
SetLength(O.F,80);
SetLength(O.F[0],3);
SetLength(O.F[1],3);
SetLength(O.F[2],3);
SetLength(O.F[3],3);
SetLength(O.F[4],3);
SetLength(O.F[5],3);
SetLength(O.F[6],3);
SetLength(O.F[7],3);
SetLength(O.F[8],3);
SetLength(O.F[9],3);
SetLength(O.F[10],3);
SetLength(O.F[11],3);
SetLength(O.F[12],3);
SetLength(O.F[13],3);
SetLength(O.F[14],3);
SetLength(O.F[15],3);
SetLength(O.F[16],3);
SetLength(O.F[17],3);
SetLength(O.F[18],3);
SetLength(O.F[19],3);
SetLength(O.F[20],3);
SetLength(O.F[21],3);
SetLength(O.F[22],3);
SetLength(O.F[23],3);
SetLength(O.F[24],3);
SetLength(O.F[25],3);
SetLength(O.F[26],3);
SetLength(O.F[27],3);
SetLength(O.F[28],3);
SetLength(O.F[29],3);
SetLength(O.F[30],3);
SetLength(O.F[31],3);
SetLength(O.F[32],3);
SetLength(O.F[33],3);
SetLength(O.F[34],3);
SetLength(O.F[35],3);
SetLength(O.F[36],3);
SetLength(O.F[37],3);
SetLength(O.F[38],3);
SetLength(O.F[39],3);
SetLength(O.F[40],3);
SetLength(O.F[41],3);
SetLength(O.F[42],3);
SetLength(O.F[43],3);
SetLength(O.F[44],3);
SetLength(O.F[45],3);
SetLength(O.F[46],3);
SetLength(O.F[47],3);
SetLength(O.F[48],3);
SetLength(O.F[49],3);
SetLength(O.F[50],3);
SetLength(O.F[51],3);
SetLength(O.F[52],3);
SetLength(O.F[53],3);
SetLength(O.F[54],3);
SetLength(O.F[55],3);
SetLength(O.F[56],3);
SetLength(O.F[57],3);
SetLength(O.F[58],3);
SetLength(O.F[59],3);
SetLength(O.F[60],3);
SetLength(O.F[61],3);
SetLength(O.F[62],3);
SetLength(O.F[63],3);
SetLength(O.F[64],3);
SetLength(O.F[65],3);
SetLength(O.F[66],3);
SetLength(O.F[67],3);
SetLength(O.F[68],3);
SetLength(O.F[69],3);
SetLength(O.F[70],3);
SetLength(O.F[71],3);
SetLength(O.F[72],3);
SetLength(O.F[73],3);
SetLength(O.F[74],3);
SetLength(O.F[75],3);
SetLength(O.F[76],3);
SetLength(O.F[77],3);
SetLength(O.F[78],3);
SetLength(O.F[79],3);
end;

begin
SetLengths;
O.V[0].Import(0.000000,0.000000,-1.000000);
O.V[1].Import(0.723600,-0.525720,-0.447215);
O.V[2].Import(-0.276385,-0.850640,-0.447215);
O.V[3].Import(-0.894425,0.000000,-0.447215);
O.V[4].Import(-0.276385,0.850640,-0.447215);
O.V[5].Import(0.723600,0.525720,-0.447215);
O.V[6].Import(0.276385,-0.850640,0.447215);
O.V[7].Import(-0.723600,-0.525720,0.447215);
O.V[8].Import(-0.723600,0.525720,0.447215);
O.V[9].Import(0.276385,0.850640,0.447215);
O.V[10].Import(0.894425,0.000000,0.447215);
O.V[11].Import(0.000000,0.000000,1.000000);
O.V[12].Import(0.425323,-0.309011,-0.850654);
O.V[13].Import(-0.162456,-0.499995,-0.850654);
O.V[14].Import(0.262869,-0.809012,-0.525738);
O.V[15].Import(0.425323,0.309011,-0.850654);
O.V[16].Import(0.850648,0.000000,-0.525736);
O.V[17].Import(-0.525730,0.000000,-0.850652);
O.V[18].Import(-0.688189,-0.499997,-0.525736);
O.V[19].Import(-0.162456,0.499995,-0.850654);
O.V[20].Import(-0.688189,0.499997,-0.525736);
O.V[21].Import(0.262869,0.809012,-0.525738);
O.V[22].Import(0.951058,0.309013,0.000000);
O.V[23].Import(0.951058,-0.309013,0.000000);
O.V[24].Import(0.587786,-0.809017,0.000000);
O.V[25].Import(0.000000,-1.000000,0.000000);
O.V[26].Import(-0.587786,-0.809017,0.000000);
O.V[27].Import(-0.951058,-0.309013,0.000000);
O.V[28].Import(-0.951058,0.309013,0.000000);
O.V[29].Import(-0.587786,0.809017,0.000000);
O.V[30].Import(0.000000,1.000000,0.000000);
O.V[31].Import(0.587786,0.809017,0.000000);
O.V[32].Import(0.688189,-0.499997,0.525736);
O.V[33].Import(-0.262869,-0.809012,0.525738);
O.V[34].Import(-0.850648,0.000000,0.525736);
O.V[35].Import(-0.262869,0.809012,0.525738);
O.V[36].Import(0.688189,0.499997,0.525736);
O.V[37].Import(0.525730,0.000000,0.850652);
O.V[38].Import(0.162456,-0.499995,0.850654);
O.V[39].Import(-0.425323,-0.309011,0.850654);
O.V[40].Import(-0.425323,0.309011,0.850654);
O.V[41].Import(0.162456,0.499995,0.850654);
O.F[0,0]:=1;
O.F[0,1]:=12;
O.F[0,2]:=14;
O.F[1,0]:=13;
O.F[1,1]:=14;
O.F[1,2]:=12;
O.F[2,0]:=14;
O.F[2,1]:=13;
O.F[2,2]:=2;
O.F[3,0]:=12;
O.F[3,1]:=0;
O.F[3,2]:=13;
O.F[4,0]:=12;
O.F[4,1]:=1;
O.F[4,2]:=16;
O.F[5,0]:=16;
O.F[5,1]:=15;
O.F[5,2]:=12;
O.F[6,0]:=15;
O.F[6,1]:=16;
O.F[6,2]:=5;
O.F[7,0]:=15;
O.F[7,1]:=0;
O.F[7,2]:=12;
O.F[8,0]:=2;
O.F[8,1]:=13;
O.F[8,2]:=18;
O.F[9,0]:=17;
O.F[9,1]:=18;
O.F[9,2]:=13;
O.F[10,0]:=18;
O.F[10,1]:=17;
O.F[10,2]:=3;
O.F[11,0]:=13;
O.F[11,1]:=0;
O.F[11,2]:=17;
O.F[12,0]:=3;
O.F[12,1]:=17;
O.F[12,2]:=20;
O.F[13,0]:=19;
O.F[13,1]:=20;
O.F[13,2]:=17;
O.F[14,0]:=20;
O.F[14,1]:=19;
O.F[14,2]:=4;
O.F[15,0]:=17;
O.F[15,1]:=0;
O.F[15,2]:=19;
O.F[16,0]:=4;
O.F[16,1]:=19;
O.F[16,2]:=21;
O.F[17,0]:=15;
O.F[17,1]:=21;
O.F[17,2]:=19;
O.F[18,0]:=21;
O.F[18,1]:=15;
O.F[18,2]:=5;
O.F[19,0]:=19;
O.F[19,1]:=0;
O.F[19,2]:=15;
O.F[20,0]:=16;
O.F[20,1]:=1;
O.F[20,2]:=23;
O.F[21,0]:=23;
O.F[21,1]:=22;
O.F[21,2]:=16;
O.F[22,0]:=22;
O.F[22,1]:=23;
O.F[22,2]:=10;
O.F[23,0]:=5;
O.F[23,1]:=16;
O.F[23,2]:=22;
O.F[24,0]:=14;
O.F[24,1]:=2;
O.F[24,2]:=25;
O.F[25,0]:=25;
O.F[25,1]:=24;
O.F[25,2]:=14;
O.F[26,0]:=24;
O.F[26,1]:=25;
O.F[26,2]:=6;
O.F[27,0]:=1;
O.F[27,1]:=14;
O.F[27,2]:=24;
O.F[28,0]:=18;
O.F[28,1]:=3;
O.F[28,2]:=27;
O.F[29,0]:=27;
O.F[29,1]:=26;
O.F[29,2]:=18;
O.F[30,0]:=26;
O.F[30,1]:=27;
O.F[30,2]:=7;
O.F[31,0]:=2;
O.F[31,1]:=18;
O.F[31,2]:=26;
O.F[32,0]:=20;
O.F[32,1]:=4;
O.F[32,2]:=29;
O.F[33,0]:=29;
O.F[33,1]:=28;
O.F[33,2]:=20;
O.F[34,0]:=28;
O.F[34,1]:=29;
O.F[34,2]:=8;
O.F[35,0]:=3;
O.F[35,1]:=20;
O.F[35,2]:=28;
O.F[36,0]:=21;
O.F[36,1]:=5;
O.F[36,2]:=31;
O.F[37,0]:=31;
O.F[37,1]:=30;
O.F[37,2]:=21;
O.F[38,0]:=30;
O.F[38,1]:=31;
O.F[38,2]:=9;
O.F[39,0]:=4;
O.F[39,1]:=21;
O.F[39,2]:=30;
O.F[40,0]:=10;
O.F[40,1]:=23;
O.F[40,2]:=32;
O.F[41,0]:=24;
O.F[41,1]:=32;
O.F[41,2]:=23;
O.F[42,0]:=32;
O.F[42,1]:=24;
O.F[42,2]:=6;
O.F[43,0]:=23;
O.F[43,1]:=1;
O.F[43,2]:=24;
O.F[44,0]:=6;
O.F[44,1]:=25;
O.F[44,2]:=33;
O.F[45,0]:=26;
O.F[45,1]:=33;
O.F[45,2]:=25;
O.F[46,0]:=33;
O.F[46,1]:=26;
O.F[46,2]:=7;
O.F[47,0]:=25;
O.F[47,1]:=2;
O.F[47,2]:=26;
O.F[48,0]:=7;
O.F[48,1]:=27;
O.F[48,2]:=34;
O.F[49,0]:=28;
O.F[49,1]:=34;
O.F[49,2]:=27;
O.F[50,0]:=34;
O.F[50,1]:=28;
O.F[50,2]:=8;
O.F[51,0]:=27;
O.F[51,1]:=3;
O.F[51,2]:=28;
O.F[52,0]:=8;
O.F[52,1]:=29;
O.F[52,2]:=35;
O.F[53,0]:=30;
O.F[53,1]:=35;
O.F[53,2]:=29;
O.F[54,0]:=35;
O.F[54,1]:=30;
O.F[54,2]:=9;
O.F[55,0]:=29;
O.F[55,1]:=4;
O.F[55,2]:=30;
O.F[56,0]:=9;
O.F[56,1]:=31;
O.F[56,2]:=36;
O.F[57,0]:=22;
O.F[57,1]:=36;
O.F[57,2]:=31;
O.F[58,0]:=36;
O.F[58,1]:=22;
O.F[58,2]:=10;
O.F[59,0]:=31;
O.F[59,1]:=5;
O.F[59,2]:=22;
O.F[60,0]:=32;
O.F[60,1]:=6;
O.F[60,2]:=38;
O.F[61,0]:=38;
O.F[61,1]:=37;
O.F[61,2]:=32;
O.F[62,0]:=37;
O.F[62,1]:=38;
O.F[62,2]:=11;
O.F[63,0]:=10;
O.F[63,1]:=32;
O.F[63,2]:=37;
O.F[64,0]:=33;
O.F[64,1]:=7;
O.F[64,2]:=39;
O.F[65,0]:=39;
O.F[65,1]:=38;
O.F[65,2]:=33;
O.F[66,0]:=38;
O.F[66,1]:=39;
O.F[66,2]:=11;
O.F[67,0]:=6;
O.F[67,1]:=33;
O.F[67,2]:=38;
O.F[68,0]:=34;
O.F[68,1]:=8;
O.F[68,2]:=40;
O.F[69,0]:=40;
O.F[69,1]:=39;
O.F[69,2]:=34;
O.F[70,0]:=39;
O.F[70,1]:=40;
O.F[70,2]:=11;
O.F[71,0]:=7;
O.F[71,1]:=34;
O.F[71,2]:=39;
O.F[72,0]:=35;
O.F[72,1]:=9;
O.F[72,2]:=41;
O.F[73,0]:=41;
O.F[73,1]:=40;
O.F[73,2]:=35;
O.F[74,0]:=40;
O.F[74,1]:=41;
O.F[74,2]:=11;
O.F[75,0]:=8;
O.F[75,1]:=35;
O.F[75,2]:=40;
O.F[76,0]:=36;
O.F[76,1]:=10;
O.F[76,2]:=37;
O.F[77,0]:=37;
O.F[77,1]:=41;
O.F[77,2]:=36;
O.F[78,0]:=41;
O.F[78,1]:=37;
O.F[78,2]:=11;
O.F[79,0]:=9;
O.F[79,1]:=36;
O.F[79,2]:=41;
end;
function GlSanGetGLUint(const s:string):GLUInt;
var i,ii:longint;
begin
i:=low(ArTextures);
ii:=-1;
while (ii=-1)and(i<=high(ArTextures)) do
	begin
	if ArTextures[i].Name=s then ii:=i;
	i+=1;
	end;
if ii=-1 then
	begin
	GlSanGetGLUint:=0;
	end
else
	begin
	GlSanGetGLUint:=ArTextures[ii].ID;
	end;
end;

procedure GlSanWndSetImageTexture(const p:PPGlSanWnd;const l:longint;const IDT:GLUInt);
begin
if (p<>nil) and (p^<>nil) and (l-1 in [Low(p^^.ArImage)..High(p^^.ArImage)]) then
	begin
	p^^.ArImage[l-1].IDTexture:=IDT;
	end;
end;

procedure GlSanWndImage.Init(const vl,np:GlSanKoor; const Verh:boolean; const _:real);
var
	razn:GlSanKoor2f;
	bvl,bnp:GlSanKoor;
begin
if IDTexture<>0 then
	begin
	Razn.Import(abs(vl.x-np.x),abs(vl.y-np.y));
	bvl.Import(vl.x+razn.x*OVL.x,vl.y-razn.y*ovl.y,vl.z);
	bnp.Import(vl.x+razn.x*onp.x,vl.y-razn.y*onp.y,np.z);
	glcolor4f(1,1,1,_);
	WndSomeQuad(bvl,bnp,GlSanKoor2fImport(0,1),GlSanKoor2fImport(1,0),IDTexture);
	end;
end;

procedure GlSanWndNewImage(const p:PPGlSanWnd;const a,b:GlSanKoor2f;const IDT:GLUInt);

begin
if (p<>nil) and (p^<>nil) then
	begin
	SetLength(p^^.ArImage,Length(P^^.ArImage)+1);
	P^^.ArImage[High(P^^.ArImage)].IDTexture:=IDT;
	P^^.ArImage[High(P^^.ArImage)].OVL.Import(a.x/p^^.WndW,a.y/p^^.WndH);
	P^^.ArImage[High(P^^.ArImage)].ONP.Import(b.x/p^^.WndW,b.y/p^^.WndH);
	end;
end;

function GlSanWndGetOnPositionFromListBox(const w:PPGlSanWnd;const l:longint):longint;
begin
GlSanWndGetOnPositionFromListBox:=-1;
if (w<>nil)and(w^<>nil)and (l-1 in [Low(w^^.ArListBox)..High(w^^.ArListBox)]) then
	begin
	GlSanWndGetOnPositionFromListBox:=w^^.ArListBox[l-1].PositionOn+1;
	w^^.ArListBox[l-1].PositionOn:=-2;
	end;
end;

procedure GlSanWndNewCloseButton(const w:PPGlSanWnd);
begin
if (w<>nil) and (w^<>nil) then
	begin
	GlSanWndNewButton(W,GlSanKoor2fImport(w^^.WndW-35,5),GlSanKoor2fImport(w^^.WndW-5,35),'',@GlSanKillThisWindow);
	GlSanWndSetLastButtonTexture(W,'close');
	GlSanWndSetLastButtonTextureOnClick(W,'close2');
	GlSanWndSetLastButtonTextureClick(W,'close3');
	end;
end;
destructor GlSanFriend.Dispose;
begin
Namber:='';
Family:='';
Name:='';
Addres:='';
FaceS:='';
if FaceG<>0 then
	begin
	GlSanUpLoadTexture(FaceG);
	FaceG:=0;
	end;
end;

procedure GlSanObj3.WriteToFile(const s:string);
var
	fi:text;
begin
assign(fi,s);
rewrite(fi);
WritelnToFile(@fi);
close(fi);
end;

function IsContextFree:boolean;
begin
(*IsContextFree:=(ContextMenu=nil);*)
IsContextFree:=(ContextMenu=nil) or ((ContextMenu<>nil) and (ContextMenu^.Open=false));
end;

procedure DadekaedrObj3(var O:GlSanObj3); 
procedure SetLengths;
begin
O.Dispose;
SetLength(O.V,20);
SetLength(O.F,12);
SetLength(O.F[0],5);
SetLength(O.F[1],5);
SetLength(O.F[2],5);
SetLength(O.F[3],5);
SetLength(O.F[4],5);
SetLength(O.F[5],5);
SetLength(O.F[6],5);
SetLength(O.F[7],5);
SetLength(O.F[8],5);
SetLength(O.F[9],5);
SetLength(O.F[10],5);
SetLength(O.F[11],5);
end;
begin
SetLengths;
O.V[0].Import(0.149072,-0.458787,-0.631477);
O.V[1].Import(0.482400,0.000000,-0.631477);
O.V[2].Import(-0.390270,-0.283547,-0.631477);
O.V[3].Import(-0.390270,0.283547,-0.631477);
O.V[4].Import(0.149072,0.458787,-0.631477);
O.V[5].Import(0.780542,0.000000,-0.149072);
O.V[6].Import(0.241200,-0.742333,-0.149072);
O.V[7].Import(-0.631470,-0.458787,-0.149072);
O.V[8].Import(-0.631470,0.458787,-0.149072);
O.V[9].Import(0.241200,0.742333,-0.149072);
O.V[10].Import(0.631470,-0.458787,0.149072);
O.V[11].Import(-0.241200,-0.742333,0.149072);
O.V[12].Import(-0.780542,0.000000,0.149072);
O.V[13].Import(-0.241200,0.742333,0.149072);
O.V[14].Import(0.631470,0.458787,0.149072);
O.V[15].Import(0.390270,-0.283547,0.631477);
O.V[16].Import(-0.149072,-0.458787,0.631477);
O.V[17].Import(-0.482400,0.000000,0.631477);
O.V[18].Import(-0.149072,0.458787,0.631477);
O.V[19].Import(0.390270,0.283547,0.631477);
O.F[0,0]:=15;
O.F[0,1]:=16;
O.F[0,2]:=11;
O.F[0,3]:=6;
O.F[0,4]:=10;
O.F[1,0]:=5;
O.F[1,1]:=14;
O.F[1,2]:=19;
O.F[1,3]:=15;
O.F[1,4]:=10;
O.F[2,0]:=19;
O.F[2,1]:=18;
O.F[2,2]:=17;
O.F[2,3]:=16;
O.F[2,4]:=15;
O.F[3,0]:=19;
O.F[3,1]:=14;
O.F[3,2]:=9;
O.F[3,3]:=13;
O.F[3,4]:=18;
O.F[4,0]:=18;
O.F[4,1]:=13;
O.F[4,2]:=8;
O.F[4,3]:=12;
O.F[4,4]:=17;
O.F[5,0]:=9;
O.F[5,1]:=4;
O.F[5,2]:=3;
O.F[5,3]:=8;
O.F[5,4]:=13;
O.F[6,0]:=17;
O.F[6,1]:=12;
O.F[6,2]:=7;
O.F[6,3]:=11;
O.F[6,4]:=16;
O.F[7,0]:=8;
O.F[7,1]:=3;
O.F[7,2]:=2;
O.F[7,3]:=7;
O.F[7,4]:=12;
O.F[8,0]:=7;
O.F[8,1]:=2;
O.F[8,2]:=0;
O.F[8,3]:=6;
O.F[8,4]:=11;
O.F[9,0]:=3;
O.F[9,1]:=4;
O.F[9,2]:=1;
O.F[9,3]:=0;
O.F[9,4]:=2;
O.F[10,0]:=1;
O.F[10,1]:=5;
O.F[10,2]:=10;
O.F[10,3]:=6;
O.F[10,4]:=0;
O.F[11,0]:=4;
O.F[11,1]:=9;
O.F[11,2]:=14;
O.F[11,3]:=5;
O.F[11,4]:=1;
end;

procedure Proga_TranslaterObj3(sf,sm,sp:string; const Vih:boolean);//(var O:GlSanObj3);
var
	o:GlSanObj3;
	fin:text;
	i,ii:longint;
begin
Textcolor(10);
writeln('Это TranslaterObj3!');
Textcolor(15);
if sf='' then
	begin
	Writeln('Введите имя файла... [без разрешения!]');
	readln(sf);
	end;
sf:=sf+'.off';
writeln('Установлен Файл: "',sf,'"');
if not Fail_Est(sf) then exit;
O.ReadFromFile(sf);
if sm='' then
	begin
	writeln('Введите имя нового модуля [без разряшения] ...');
	writeln('Учтите, что это имя будет прописано в модуле...');
	readln(sm);
	end;
writeln('Установлено имя модууля и его файла: "',sm,'"');
assign(fin,sm+'.pas');
rewrite(fin);
writeln('Файл ',sm+'.pas',' успешно открыт:))...');
writeln(fin,'{----------------------------------------------------------------------}');
writeln(fin,'{------------------Sanches Corporation Present-------------------------}');
writeln(fin,'{------------------------=MPSNP FOREVER=-------------------------------}');
writeln(fin,'{----------- This Work MPSNP Program "TranslyaterObj3"-----------------}');
writeln(fin,'{-----------------------Import-from "',sf,'"---------------------------}');
writeln(fin,'{----------------------Work with san.ppu-------------------------------}');
writeln(fin,'{------------------"San.ppu" Work with "San.res"-----------------------}');
writeln(fin,'{----------------------------------------------------------------------}');
writeln(fin,'unit ',sm,'; {  Это название Модуля}');
writeln(fin,'interface  { Инициализируем интерфейсный раздел }');
writeln(fin,'uses san; { Перечисляем модули , которые использует Этот Модуль }');
if sp='' then
	begin
	writeln('Введите имя процедуры в модуле...');
	readln(sp);
	end;
writeln('Установлена Процедура: "',sp,'"');
writeln(fin,'procedure ',sp,'(var O:GlSanObj3);',' { Пишем заголовок процедуры } ');
writeln(fin,'implementation  { Инициализируем раздел интерпритации }');
writeln(fin,'procedure ',sp,'(var O:GlSanObj3);',' { Пишем заголовок процедуры } ');
writeln(fin,'');
writeln(fin,'procedure SetLengths;');
writeln(fin,'begin');
writeln(fin,'O.Dispose;');
writeln(fin,'SetLength(O.V,',Length(O.V),');');
writeln(fin,'SetLength(O.F,',Length(O.F),');');
for i:=Low(O.F) to High(O.F) do
	writeln(fin,'SetLength(O.F[',i,'],',Length(O.F[i]),');');
writeln(fin,'end;');
writeln(fin,'');
writeln(fin,'begin');
writeln(fin,'SetLengths;');
for i:=Low(O.V) to High(O.V) do
	writeln(fin,'O.V[',i,'].Import(',O.V[i].x:0:6,',',O.V[i].y:0:6,',',O.V[i].z:0:6,');');
for i:=Low(O.F) to High(o.F) do
	begin
	for ii:=Low(O.F[i]) to High(O.F[i]) do
		writeln(fin,'O.F[',i,',',ii,']:=',O.F[i,ii],';');
	end;
writeln(fin,'end;');
writeln(fin,'');
writeln(fin,'begin');
writeln(fin,'');
writeln(fin,'end.');
writeln('Вроде успешно...');
readln;
close(fin);
end;

operator << (const a:GlSanKoorPlosk; const b:GlSanKoor):real;
begin
result:=a.a*b.x+a.b*b.y+a.c*b.z+a.d;
end;

procedure GlSanObj3.SerediniPoligonov;
var
	a:array of GlSanKoor = nil;
	i,ii:longint;
	k:GlSanKoor;
begin
for i:=Low(f) to High(f) do
		begin
		SetLength(a,Length(a)+1);
		k.Import(0,0,0);
		for ii:=Low(f[i]) to high(f[i]) do
			k+=v[f[i,ii]];
		k/=Length(f[i]);
		a[High(a)]:=k;
		end;
Dispose;
SetLength(v,Length(a));
for i:=Low(v) to High(a) do
	v[i]:=a[i];
SetLength(a,0);
end;

procedure GlSanGoMultyTred(const p:pointer);
var
	f:file of longint;
begin
assign(f,'SMT.dat');
rewrite(f);
write(f,longint(p));
close(f);
exec('SMT.exe','');
end;

procedure GlSanMultyTred;
var
	f:file of longint;
	p:pointer;
	i:longint;
	pr:TProcedure;
begin
assign(f,'SMT.dat');
reset(f);
read(i);
close(f);
erase(f);
p:=Pointer(i);
pr:=TProcedure(p);
Pr;
end;

procedure GlSanDisableTexture;
begin
glDisable(GL_TEXTURE_2D);
end;

procedure GlSanContextMenuSetIconsZum(const p:PGlSanContextMenu; const c:GlSanKoor2f);
begin
if p<>nil then
	begin
	p^.IconsZum:=c;
	end;
end;

procedure GlSanContextMenuSetViewType(const p:PGlSanContextMenu; const l:longint);
begin
if p<>nil then
	begin
	p^.ViewTipe:=l;
	end;
end;

operator =  (const a,b:DPoint):boolean;
begin
result:=(a.id=b.id) and (a.i=b.i);
end;

procedure GlSanKoor2f.ReadlnFromFile(const p:pointer);
var
	f:^text;
begin
f:=p;
readln(f^,x,y);
end;

operator * (const a:GlSanKoor;const b:real):GlSanKoor;
begin
result.x:=a.x*b;
result.y:=a.y*b;
result.z:=a.z*b;
end;


operator / (const a:GlSanKoor;const b:real):GlSanKoor;
begin
result.x:=a.x/b;
result.y:=a.y/b;
result.z:=a.z/b;
end;

operator ** (const a:real;const b:longint):real;
var
	i:longint;
begin
result:=1;
for i:=1 to b do
	result*=a;
end;

operator ** (const a,b:longint):longint;
var
	i:longint;
begin
result:=1;
for i:=1 to b do
	result*=a;
end;

operator = (const a,b:GlSanKoor):boolean;
var
	r:real=0;
begin
r+=abs(a.x-b.x)+abs(a.z-b.z)+abs(a.y-b.y);
result:=r<GlSanMin;
end;

operator - (const a,b:GlSanKoor):GlSanKoor;
begin
result.x:=a.x-b.x;
result.y:=a.y-b.y;
result.z:=a.z-b.z;
end;

operator + (const a,b:GlSanKoor):GlSanKoor;
begin
result.x:=a.x+b.x;
result.y:=a.y+b.y;
result.z:=a.z+b.z;
end;

procedure GlSanUnPack(const sf,sfol:string);
var
	f,f2:file of byte;
	i,iii:longint;
	b1,b2:byte;
	s:string;
begin
assign(f,sf);
reset(f);
read(f,b1,b2);
if (b1<>83) or (b2<>80) then
	begin
	close(f);
	exit;
	end;
while not eof(f) do
	begin
	read(f,b1);
	s[0]:=char(b1);
	for i:=1 to b1 do
		begin
		read(f,b2);
		s[i]:=char(b2);
		end;
	iii:=0;
	b1:=0;
	while b1=0 do
		begin
		read(f,b2);
		if b2=255 then
			iii+=255
		else
			begin
			iii+=b2;
			b1:=1;
			end;
		end;
	assign(f2,sfol+s);
	rewrite(f2);
	for i:=1 to iii do
		begin
		read(f,b1);
		write(f2,b1);
		end;
	close(f2);
	end;
close(f);
end;
function GlSanNameAndRF(const s:string):string;
var
	i,ii:longint;
begin
ii:=-1;
for i:=1 to Length(s) do
	if s[i]='\' then
		ii:=i;
if ii=-1 then
	GlSanNameAndRF:=s
else
	begin
	GlSanNameAndRF:=GlSanCopy(s,ii+1,Length(s));
	end;
end;
procedure GlSanPack(const p:pointer;const sf:string);
type
	TArF=array of string;
	PArF=^TArF;
var
	ArF:PArF=nil;
	f,f2:file of byte;
	i,ii,iii:longint;
	b:byte;
begin
ArF:=p;
if Length(ArF^)>0 then
	begin
	assign(f,sf);
	rewrite(f);
	write(f,83,80);
	for i:=Low(ArF^) to High(ArF^) do
		begin
		for ii:=0 to Length(GlSanNameAndRF(ArF^[i])) do
			write(f,byte(GlSanNameAndRF(ArF^[i])[ii]));
		iii:=GlSanByteSize(ArF^[i]);
		while iii<>-1 do
			begin
			if iii>255 then
				begin
				iii-=255;
				write(f,255);
				end
			else
				if iii<255 then
					begin
					write(f,iii);
					iii:=-1;
					end
				else
					begin
					iii:=-1;
					write(f,255,0);
					end;
			end;
		assign(f2,ArF^[i]);
		reset(f2);
		while not eof(f2) do
			begin
			read(f2,b);
			write(f,b);
			end;
		close(f2);
		end;
	close(f);
	end;
end;
function GlSanByteSize(const s:string):longint;
var
	f:file of byte;
	b:byte;
begin
assign(f,s);
reset(f);
GlSanByteSize:=0;
while not eof(f) do
	begin
	read(f,b);
	GlSanByteSize+=1;
	end;
close(f);
end;

procedure Proverca;
var
	i:longint;
begin
i:=random(17);
textcolor(i);
writeln(i);
textcolor(15);
end;

procedure GlSanKillContext(w:PGlSanWnd);
begin
end;

procedure GlSanDelay;
begin
GetTime(Time.Hours,Time.Minits,Time.Seconds,Time.Sec100);
if Time.Seconds=SecNow then
	begin
	FPSSled+=1;
	if FPSMoment then
		FPSMoment:=false;
	end
else
	begin
	SecNow:=Time.Seconds;
	FPS:=FPSSled;
	FPSSled:=0;
	FPSMoment:=true;
	end;
if GlSanDON and (GlSanD>0) then
	Delay(GlSanD)
else
	begin
	if FPSUser then
		Delay(GlSanD);
	end;
if FPSMoment then
	begin
	GetDate(Date.Year,Date.Month,Date.Day,Date.Week);
	if GlSanDON and (not FPSUser ) then
		begin
		if (FPS in [55..75]) then
			begin
			end
		else
			begin
			if FPS>75 then
				begin
				GlSanD+=1;
				end
			else
				begin
				if GlSanD<>0 then
					GlSanD-=1;
				end
			end;
		end;
	end;
end;

procedure GlSanWndSetHeight(const wND:PPGlSanWnd; const h:real);
var
	i:longint;
begin
if (Wnd<>nil) and (Wnd^<>nil) then
	begin
	Wnd^^.ONP.y+=(h-Wnd^^.WndH)/height;
	for i:=Low(Wnd^^.ArButtons) to high(Wnd^^.ArButtons) do
		begin
		Wnd^^.ArButtons[i].OVL.y*=(Wnd^^.WndH/h);
		Wnd^^.ArButtons[i].ONP.y*=(Wnd^^.WndH/h);
		end;
	for i:=Low(Wnd^^.ArText) to high(Wnd^^.ArText) do
		begin
		Wnd^^.ArText[i].OVL.y*=(Wnd^^.WndH/h);
		Wnd^^.ArText[i].ONP.y*=(Wnd^^.WndH/h);
		end;
	for i:=Low(Wnd^^.ArListBox) to high(Wnd^^.ArListBox) do
		begin
		Wnd^^.ArListBox[i].OVL.y*=(Wnd^^.WndH/h);
		Wnd^^.ArListBox[i].ONP.y*=(Wnd^^.WndH/h);
		end;
	for i:=Low(Wnd^^.ArCheckBox) to high(Wnd^^.ArCheckBox) do
		begin
		Wnd^^.ArCheckBox[i].OVL.y*=(Wnd^^.WndH/h);
		Wnd^^.ArCheckBox[i].ONP.y*=(Wnd^^.WndH/h);
		end;
	for i:=Low(Wnd^^.ArComboBox) to high(Wnd^^.ArComboBox) do
		begin
		Wnd^^.ArComboBox[i].OVL.y*=(Wnd^^.WndH/h);
		Wnd^^.ArComboBox[i].ONP.y*=(Wnd^^.WndH/h);
		end;
	for i:=Low(Wnd^^.ArEdit) to high(Wnd^^.ArEdit) do
		begin
		Wnd^^.ArEdit[i].OVL.y*=(Wnd^^.WndH/h);
		Wnd^^.ArEdit[i].ONP.y*=(Wnd^^.WndH/h);
		end;
	for i:=Low(Wnd^^.ArProgressBar) to high(Wnd^^.ArProgressBar) do
		begin
		Wnd^^.ArProgressBar[i].OVL.y*=(Wnd^^.WndH/h);
		Wnd^^.ArProgressBar[i].ONP.y*=(Wnd^^.WndH/h);
		end;
	Wnd^^.WndH:=round(h);
	end;
end;

function GlSanLoadTexture(const fn:string):GLUInt;
begin
GlSanLoadTexture:=SGLoadGLTexture(fn);
end;

procedure GlSanContextMenuSetIconToLast(var p:PGlSanContextMenu;const SIco:string;const z:GlSanKoor2f);
begin
if p<>nil then
	begin
	p^.Things[High(p^.Things)].Ico:=SIco;
	p^.Things[High(p^.Things)].ZumIco:=z;
	end;
end;

procedure GlSanContextMenuAddString(const p:PGlSanContextMenu;const s:string; const v:longint; const p1:pointer);
begin
if p<>nil then
	begin
	SetLength(p^.Things,Length(p^.Things)+1);
	p^.Things[High(p^.Things)].Text:=s;
	p^.Things[High(p^.Things)].Ico:='';
	p^.Things[High(p^.Things)].ZumIco:=GlSanKoor2fImport(1,1);
	p^.Things[High(p^.Things)].Tipe:=v;
	p^.Things[High(p^.Things)].Point:=p1;
	p^.Things[High(p^.Things)].Dialog:=nil;
	end;
end;

procedure GlSanContextMenu.KillContext;
var
	i:longint;
	Into:PGlSanContextMenu;
begin
for i:=Low(Things) to High(Things) do
	begin
	if (Things[i].Point<>nil) and (Things[i].Tipe=2) and (Things[i].Dialog<>nil) then
		begin
		Into:=Things[i].Dialog;
		if INto^.Open then
			Into^.KillContext;
		end;
	end;
Open:=false;
end;

procedure GlSanContextMenuSetIcon(var p:PGlSanContextMenu;const l:longint;const SIco:string;const z:GlSanKoor2f);
begin
if p<>nil then
	begin
	if l-1 in [Low(p^.Things)..High(p^.Things)] then
		begin
		p^.Things[l-1].Ico:=SIco;
		p^.Things[l-1].ZumIco:=z;
		end;
	end;
end;
procedure GlSanContextMenuSetIcon(var p:PGlSanContextMenu;const l:longint;const SIco:string);
begin
if p<>nil then
	begin
	if l-1 in [Low(p^.Things)..High(p^.Things)] then
		begin
		p^.Things[l-1].Ico:=SIco;
		end;
	end;
end;

function GlSanFindTexture(const s:string):boolean;
var
	i:longint;
begin
if s='' then
	GlSanFindTexture:=false
else
	begin
	GlSanFindTexture:=false;
	for i:=Low(ArTextures) to High(ArTextures) do
		begin
		if ArTextures[i].Name=s then
			GlSanFindTexture:=true;
		end;
	end;
end;

function GlSanGetReOut(const pp:PPGlSanWnd):boolean;
begin
if (pp<>nil) and (pp^<>nil) then
	begin
	GlSanGetReOut:=pp^^.ReOutThisProc;
	end;
end;

procedure GlSanSetReOut(const pp:PPGlSanWnd);
begin
if (pp<>nil) and (pp^<>nil) then
	IDReOut:=pp^;
end;

procedure GlSanContextMenuIntoMake(var p:PGlSanContextMenu; const w:PPGlSanWnd; const prc:pointer; var f:PGlSanContextMenu);
begin
if Length(p^.Things)>0 then
	begin
	if w=nil then 
		p^.DependentWindow:=nil
	else
		p^.DependentWindow:=w^;
	p^.DependentProc:=prc;
	p^.OpenProgress:=0;
	p^.Open:=true;
	f:=p;
	p:=nil;
	end;
end;

procedure GlSanContextMenuSetIntoContextFunction(const p:PGlSanContextMenu; const s:longint; const l:pointer);
begin
if p<>nil then
	begin
	if s-1 in [Low(p^.Things)..High(p^.Things)] then
		begin
		p^.Things[s-1].Point:=l;
		p^.Things[s-1].Dialog:=nil;
		p^.Things[s-1].Tipe:=3;
		end;
	end;
end;

procedure GlSanContextMenuSetProcedure(const p:PGlSanContextMenu; const s:longint; const l:pointer);
begin
if p<>nil then
	begin
	if s-1 in [Low(p^.Things)..High(p^.Things)] then
		begin
		p^.Things[s-1].Point:=l;
		p^.Things[s-1].Dialog:=nil;
		p^.Things[s-1].Tipe:=1;
		end;
	end;
end;

procedure GlSanContextMenuSetString(const p:PGlSanContextMenu; const s:longint; const l:string);
begin
if p<>nil then
	begin
	if s-1 in [Low(p^.Things)..High(p^.Things)] then
		begin
		p^.Things[s-1].Text:=l;
		end;
	end;
end;

procedure GlSanContextMenuSetLength(const p:PGlSanContextMenu; const l:longint);
var
	i,ii:longint;
begin
if p<>nil then
	begin
	ii:=High(p^.Things)+1;
	SetLength(p^.Things,l);
	with p^ do
		begin
		for i:=ii to High(Things) do
			begin
			Things[i].Text:='';
			Things[i].Ico:='';
			Things[i].ZumIco:=GlSanKoor2fImport(1,1);;
			Things[i].Tipe:=0;
			Things[i].Point:=nil;
			Things[i].Dialog:=nil;
			end;
		end;
	end;
end;

procedure GlSanContextMenuBeginning(var p:PGlSanContextMenu);
begin
New(p);
SetLength(p^.Things,0);
p^.OpenProgress:=0;
p^.DependentProc:=nil;
p^.DependentWindow:=nil;
p^.OpenTipe:=0;
p^.MaxLength:=0;
p^.StartKoor:=GlSanKoorImport(0,0,0);
p^.UserMemory.Dispose;
p^.Open:=true;
p^.ViewTipe:=GL_SAN_TEXT;
p^.IconsZum.Import(4,1);
p^.CoolStrings:=false;
p^.ContextMenuIconZum:=StandardContextMenuIconZum;
p^.ContextMenuZum:=StandardContextMenuZum;
end;

procedure GlSanContextMenuMake(const p:PGlSanContextMenu; const w:PPGlSanWnd; const prc:pointer);
begin
if Length(p^.Things)>0 then
	begin
	if w=nil then 
		p^.DependentWindow:=nil
	else
		p^.DependentWindow:=w^;
	p^.DependentProc:=prc;
	ContextMenuSled:=p;
	end;
end;
procedure GlSanWndSetNewTittle(const p:PPGlSanWnd; const s:string);
begin
if (p<>nil) and (p^<>nil) then
	begin
	p^^.Tittle:=s;
	end;
end;

procedure GlSanWndSetNewSystemTittle(const p:PPGlSanWnd; const s:string);
begin
if (p<>nil) and (p^<>nil) then
	begin
	p^^.TittleSystem:=s;
	end;
end;
procedure GlSanContextMenu.ReTipeKoor(const IDWA:longint; const ML:real);
begin
					(*
					1 - Вниз Вправо
					2 - Вверх Влево
					3 - Вверх Вправо
					4 - Вниз Влево
					*)
case ViewTipe of
GL_SAN_TEXT:
	begin
	case OpenTipe of
	1:
		begin
		if StartKoor.y-Length(Things)*ContextMenuZum*2<GlSanWA[IDWA,3].y then
			begin
			if StartKoor.x+ML+MaxLength>GlSanWA[IDWA,3].x then
				begin
				OpenTipe:=2;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				oPENtIPE:=3;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end;
			end
		else
			begin
			if StartKoor.x+ML+MaxLength>GlSanWA[IDWA,3].x then
				begin
				OpenTipe:=4;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end;
			end;
		end;
	2:
		begin
		if StartKoor.y+Length(Things)*ContextMenuZum*2>GlSanWA[IDWA,1].y then
			begin
			if StartKoor.x-ML-MaxLength<GlSanWA[IDWA,1].x then
				begin
				OpenTipe:=1;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				oPENtIPE:=4;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end;
			end
		else
			begin
			if StartKoor.x-ML-MaxLength<GlSanWA[IDWA,1].x then
				begin
				OpenTipe:=3;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end;
			end;
		end;
	3:
		begin
		if StartKoor.y+Length(Things)*ContextMenuZum*2>GlSanWA[IDWA,2].y then
			begin
			if StartKoor.x+ML+MaxLength>GlSanWA[IDWA,2].x then
				begin
				OpenTipe:=4;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				oPENtIPE:=1;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end;
			end
		else
			begin
			if StartKoor.x+ML+MaxLength>GlSanWA[IDWA,2].x then
				begin
				OpenTipe:=2;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end;
			end;
		end;
	4:
		begin
		if StartKoor.y-Length(Things)*ContextMenuZum*2<GlSanWA[IDWA,4].y then
			begin
			if StartKoor.x-ML-MaxLength<GlSanWA[IDWA,4].x then
				begin
				OpenTipe:=3;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				oPENtIPE:=2;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end;
			end
		else
			begin
			if StartKoor.x-ML-MaxLength<GlSanWA[IDWA,4].x then
				begin
				OpenTipe:=1;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end;
			end;
		end;
	end;
	end;
GL_SAN_TEXT_AND_ICONS:
	begin
	case OpenTipe of
	1:
		begin
		if StartKoor.y-Length(Things)*ContextMenuZum*2*ContextMenuIconZum<GlSanWA[IDWA,3].y then
			begin
			if StartKoor.x+ML+MaxLength+2*ContextMenuIconZum*ContextMenuZum>GlSanWA[IDWA,3].x then
				begin
				OpenTipe:=2;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				oPENtIPE:=3;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end;
			end
		else
			begin
			if StartKoor.x+ML+MaxLength+2*ContextMenuIconZum*ContextMenuZum>GlSanWA[IDWA,3].x then
				begin
				OpenTipe:=4;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end;
			end;
		end;
	2:
		begin
		if StartKoor.y+Length(Things)*ContextMenuZum*2*ContextMenuIconZum>GlSanWA[IDWA,1].y then
			begin
			if StartKoor.x-ML-MaxLength-2*ContextMenuIconZum*ContextMenuZum<GlSanWA[IDWA,1].x then
				begin
				OpenTipe:=1;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				oPENtIPE:=4;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end;
			end
		else
			begin
			if StartKoor.x-ML-MaxLength-2*ContextMenuIconZum*ContextMenuZum<GlSanWA[IDWA,1].x then
				begin
				OpenTipe:=3;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end;
			end;
		end;
	3:
		begin
		if StartKoor.y+Length(Things)*ContextMenuZum*2*ContextMenuIconZum>GlSanWA[IDWA,2].y then
			begin
			if StartKoor.x+ML+MaxLength+2*ContextMenuIconZum*ContextMenuZum>GlSanWA[IDWA,2].x then
				begin
				OpenTipe:=4;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				oPENtIPE:=1;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end;
			end
		else
			begin
			if StartKoor.x+ML+MaxLength+2*ContextMenuIconZum*ContextMenuZum>GlSanWA[IDWA,2].x then
				begin
				OpenTipe:=2;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end;
			end;
		end;
	4:
		begin
		if StartKoor.y-Length(Things)*ContextMenuZum*2*ContextMenuIconZum<GlSanWA[IDWA,4].y then
			begin
			if StartKoor.x-ML-MaxLength-2*ContextMenuIconZum*ContextMenuZum<GlSanWA[IDWA,4].x then
				begin
				OpenTipe:=3;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				oPENtIPE:=2;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end;
			end
		else
			begin
			if StartKoor.x-ML-MaxLength-2*ContextMenuIconZum*ContextMenuZum<GlSanWA[IDWA,4].x then
				begin
				OpenTipe:=1;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end;
			end;
		end;
	end;
	end;
GL_SAN_ICONS:
	begin
	case OpenTipe of
	1:
		begin
		if StartKoor.y-Length(Things)*ContextMenuZum*2*IconsZum.y*ContextMenuIconZum<GlSanWA[IDWA,3].y then
			begin
			if StartKoor.x+ML+ContextMenuZum*IconsZum.x*ContextMenuIconZum>GlSanWA[IDWA,3].x then
				begin
				OpenTipe:=2;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				oPENtIPE:=3;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end;
			end
		else
			begin
			if StartKoor.x+ML+ContextMenuZum*IconsZum.x*ContextMenuIconZum>GlSanWA[IDWA,3].x then
				begin
				OpenTipe:=4;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end;
			end;
		end;
	2:
		begin
		if StartKoor.y+Length(Things)*ContextMenuZum*2*IconsZum.y*ContextMenuIconZum>GlSanWA[IDWA,1].y then
			begin
			if StartKoor.x-ML-ContextMenuZum*IconsZum.x*ContextMenuIconZum<GlSanWA[IDWA,1].x then
				begin
				OpenTipe:=1;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				oPENtIPE:=4;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end;
			end
		else
			begin
			if StartKoor.x-ML-ContextMenuZum*IconsZum.x*ContextMenuIconZum<GlSanWA[IDWA,1].x then
				begin
				OpenTipe:=3;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end;
			end;
		end;
	3:
		begin
		if StartKoor.y+Length(Things)*ContextMenuZum*2*IconsZum.y*ContextMenuIconZum>GlSanWA[IDWA,2].y then
			begin
			if StartKoor.x+ML+ContextMenuZum*IconsZum.x*ContextMenuIconZum>GlSanWA[IDWA,2].x then
				begin
				OpenTipe:=4;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				oPENtIPE:=1;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end;
			end
		else
			begin
			if StartKoor.x+ML+ContextMenuZum*IconsZum.x*ContextMenuIconZum>GlSanWA[IDWA,2].x then
				begin
				OpenTipe:=2;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end;
			end;
		end;
	4:
		begin
		if StartKoor.y-Length(Things)*ContextMenuZum*2*IconsZum.y*ContextMenuIconZum<GlSanWA[IDWA,4].y then
			begin
			if StartKoor.x-ML-ContextMenuZum*IconsZum.x*ContextMenuIconZum<GlSanWA[IDWA,4].x then
				begin
				OpenTipe:=3;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				oPENtIPE:=2;
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end;
			end
		else
			begin
			if StartKoor.x-ML-ContextMenuZum*IconsZum.x*ContextMenuIconZum<GlSanWA[IDWA,4].x then
				begin
				OpenTipe:=1;
				StartKoor.Import(StartKoor.x+ML,StartKoor.y,StartKoor.z)
				end
			else
				begin
				StartKoor.Import(StartKoor.x-ML,StartKoor.y,StartKoor.z)
				end;
			end;
		end;
	end;
	end;
end;
end;
procedure GlSanContextMenu.ReTipe;
var
	n:boolean=false;
	p:boolean=false;
begin
case ViewTipe of
GL_SAN_TEXT:
	begin
	n:=StartKoor.y-2*ContextMenuZum*Length(Things)<GlSanWA[0,3].y;
	p:=StartKoor.x+MaxLength>GlSanWA[0,3].x;
	end;
GL_SAN_TEXT_AND_ICONS:
	begin
	n:=StartKoor.y-2*ContextMenuZum*Length(Things)*ContextMenuIconZum<GlSanWA[0,3].y;
	p:=StartKoor.x+MaxLength+2*ContextMenuIconZum*ContextMenuZum>GlSanWA[0,3].x;
	end;
GL_SAN_ICONS:
	begin
	n:=StartKoor.y-2*ContextMenuZum*Length(Things)*ContextMenuIconZum*IconsZum.y<GlSanWA[0,3].y;
	p:=StartKoor.x+ContextMenuIconZum*ContextMenuZum*IconsZum.x>GlSanWA[0,3].x;
	end;
end;
if p=n then
	begin
	if p=false then
		begin
		OpenTipe:=1;
		end
	else
		begin
		OpenTipe:=GL_SAN_CM_VL;
		end;
	end
else
	begin
	if p=false then
		begin
		OpenTipe:=GL_SAN_CM_VP;
		end
	else
		begin
		OpenTipe:=GL_SAN_CM_NL;
		end;
	end;
end;

function GlSanWndPrinKoor(const a,b,c:GlSanKoor):boolean;
var
	pl1,pl2:real;
	t1,t2:GlSanKoor;
begin
t1:=GlSanKoorImport(a.x,b.y,a.z);
t2:=GlSanKoorImport(b.x,a.y,a.z);
Pl1:=GlSanRast(b,t1)*GlSanRast(b,t2);
Pl2:=GlSanTreugPlosh(a,c,t1)+GlSanTreugPlosh(b,c,t1)+
	GlSanTreugPlosh(a,c,t2)+GlSanTreugPlosh(b,c,t2);
if abs(Pl2-Pl1)<=(GlSanWndMin/1000) then
	GlSanWndPrinKoor:=true
else
	GlSanWndPrinKoor:=false;
end;

procedure GlSanContextMenu.ReKoor;
begin
case ViewTipe of
GL_SAN_TEXT:
	if OpenTipe<>1 then
		begin
		if (OpenTipe=2) or (OpenTipe=3) then
			begin
			StartKoor.y+=2*ContextMenuZum*Length(Things)*OpenProgress;
			end;
		if (OpenTipe=2) or (OpenTipe=4) then
			begin
			StartKoor.x-=MaxLength*OpenProgress;
			end;
		end;
GL_SAN_TEXT_AND_ICONS:
	begin
	if OpenTipe<>1 then
		begin
		if (OpenTipe=2) or (OpenTipe=3) then
			begin
			StartKoor.y+=2*ContextMenuZum*Length(Things)*OpenProgress*ContextMenuIconZum;
			end;
		if (OpenTipe=2) or (OpenTipe=4) then
			begin
			StartKoor.x-=MaxLength*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress;
			end;
		end;
	end;
GL_SAN_ICONS:
	begin
	if OpenTipe<>1 then
		begin
		if (OpenTipe=2) or (OpenTipe=3) then
			begin
			StartKoor.y+=2*ContextMenuZum*Length(Things)*OpenProgress*IconsZum.y*ContextMenuIconZum;
			end;
		if (OpenTipe=2) or (OpenTipe=4) then
			begin
			StartKoor.x-=OpenProgress*IconsZum.x*ContextMenuZum*ContextMenuIconZum;
			end;
		end;
	end;
end;
end;
function GlSanContextMenu.InitKoor(const k:GlSanKoor):boolean;
label
	NewInto;
var
	i,ii:longint;
	PD:PGlSanContextMenu;
	b:boolean=true;
	Proc:GlSanWndProcedure;
	Func:GlSanContextFunction;
begin
InitKoor:=false;
for i:=Low(Things) to High(Things) do
	if Things[i].Tipe = 2 then
		begin
		PD:=Things[i].Dialog;
		b:=PD^.InitKoor(k);
		if b then
			InitKoor:=b;
		end;
if Not InitKoor then
	begin
	case ViewTipe of
	GL_SAN_TEXT:
		begin
		if GlSanPrinKoor(StartKoor,GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*Length(Things)*OpenProgress,StartKoor.z),k) then
			InitKoor:=true;
		end;
	GL_SAN_TEXT_AND_ICONS:
		begin
		if GlSanPrinKoor(StartKoor,GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress*ContextMenuIconZum,
			StartKoor.y-ContextMenuZum*2*Length(Things)*OpenProgress*ContextMenuIconZum,StartKoor.z),k) then
				InitKoor:=true;
		end;
	GL_SAN_ICONS:
		begin
		if GlSanPrinKoor(StartKoor,GlSanKoorImport(StartKoor.x+OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum,
			StartKoor.y-ContextMenuZum*2*Length(Things)*OpenProgress*IconsZum.y*ContextMenuIconZum,StartKoor.z),k) then
				InitKoor:=true;
		end;
	end;
	if InitKoor and (OpenProgress>0.18) then
		begin
		b:=true;
		for i:=Low(Things) to High(Things) do
			if b and 
				(((ViewTipe=GL_SAN_TEXT)  and GlSanPrinKoor(
					GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress,StartKoor.z),
					GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress,StartKoor.z),k))
				or
				((ViewTipe=GL_SAN_TEXT_AND_ICONS)  and GlSanPrinKoor(
					GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum,StartKoor.z),
					GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*OpenProgress*ContextMenuZum*ContextMenuIconZum,
						StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum,StartKoor.z),k))
				or
				((ViewTipe=GL_SAN_ICONS)  and GlSanPrinKoor(
					GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*IconsZum.y*ContextMenuIconZum,StartKoor.z),
					GlSanKoorImport(StartKoor.x+OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum,
						StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*IconsZum.y*ContextMenuIconZum,StartKoor.z),k))
				)
				 then
					begin
					b:=false;
					if SGIsMouseKeyDown(1) then
						begin
						case ViewTipe of
						GL_SAN_TEXT:
							begin
							if (ActiveSkin=-1) or (ArSkins[ActiveSkin].ContextMenuTexture3=-1) then
								begin
								glcolor4f(0.1,0.2,0.9,0.67*OpenProgress);
								GlSanRoundQuad(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress,StartKoor.z),
									GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress,
									StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress,StartKoor.z),
										GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress,
										StartKoor.z),
									ContextMenuZum*OpenProgress),
									4);
								glcolor4f(0.2,0.6,1,0.67);
								GlSanRoundQuadLines(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress,StartKoor.z),
									GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress,
									StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress,StartKoor.z),
										GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress,
										StartKoor.z*OpenProgress),
									ContextMenuZum*OpenProgress),
									4);
								end
							else
								begin
								ArSkins[ActiveSkin].ArContextMenuTextureColor[3].SanSetColorA(OpenProgress);
								GlSanDrawComponent9(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress,StartKoor.z),
									GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress,StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress,StartKoor.z),
										GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress,
										StartKoor.z),
										ContextMenuZum*OpenProgress),
									ArSkins[ActiveSkin].ArRealContextMenu3[Low(ArSkins[ActiveSkin].ArRealContextMenu3)+0],
									ArSkins[ActiveSkin].ArRealContextMenu3[Low(ArSkins[ActiveSkin].ArRealContextMenu3)+1],
									ArSkins[ActiveSkin].ArRealContextMenu3[Low(ArSkins[ActiveSkin].ArRealContextMenu3)+2],
									ArSkins[ActiveSkin].ArRealContextMenu3[Low(ArSkins[ActiveSkin].ArRealContextMenu3)+3],
									ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ContextMenuTexture3]);
								end;
							end;
						GL_SAN_TEXT_AND_ICONS:
							begin
							if (ActiveSkin=-1) or (ArSkins[ActiveSkin].ContextMenuTexture3=-1) then
								begin
								glcolor4f(0.1,0.2,0.9,0.67*OpenProgress);
								GlSanRoundQuad(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum,StartKoor.z),
									GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*OpenProgress*ContextMenuIconZum*ContextMenuZum,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum,
									StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum,StartKoor.z),
										GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*OpenProgress*ContextMenuIconZum*ContextMenuZum,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum,
										StartKoor.z),
									ContextMenuZum*OpenProgress*ContextMenuIconZum),
									4);
								glcolor4f(0.2,0.6,1,0.67);
								GlSanRoundQuadLines(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum,StartKoor.z),
									GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*OpenProgress*ContextMenuIconZum*ContextMenuZum,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum,
									StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum,StartKoor.z),
										GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*OpenProgress*ContextMenuIconZum*ContextMenuZum,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum,
										StartKoor.z*OpenProgress),
									ContextMenuZum*OpenProgress*ContextMenuIconZum),
									4);
								end
							else
								begin
								ArSkins[ActiveSkin].ArContextMenuTextureColor[3].SanSetColorA(OpenProgress);
								GlSanDrawComponent9(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum,StartKoor.z),
									GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*OpenProgress*ContextMenuIconZum*ContextMenuZum,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum,StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum,StartKoor.z),
										GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*OpenProgress*ContextMenuIconZum*ContextMenuZum,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum,
										StartKoor.z),
										ContextMenuZum*OpenProgress*ContextMenuIconZum),
									ArSkins[ActiveSkin].ArRealContextMenu3[Low(ArSkins[ActiveSkin].ArRealContextMenu3)+0],
									ArSkins[ActiveSkin].ArRealContextMenu3[Low(ArSkins[ActiveSkin].ArRealContextMenu3)+1],
									ArSkins[ActiveSkin].ArRealContextMenu3[Low(ArSkins[ActiveSkin].ArRealContextMenu3)+2],
									ArSkins[ActiveSkin].ArRealContextMenu3[Low(ArSkins[ActiveSkin].ArRealContextMenu3)+3],
									ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ContextMenuTexture3]);
								end;
							end;
						GL_SAN_ICON:
							begin
							if (ActiveSkin=-1) or (ArSkins[ActiveSkin].ContextMenuTexture3=-1) then
								begin
								glcolor4f(0.1,0.2,0.9,0.67*OpenProgress);
								GlSanRoundQuad(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									GlSanKoorImport(StartKoor.x+OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum,
										StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
										GlSanKoorImport(StartKoor.x+OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum,
											StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									ContextMenuZum*OpenProgress),
									4);
								glcolor4f(0.2,0.6,1,0.67);
								GlSanRoundQuadLines(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									GlSanKoorImport(StartKoor.x+OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum,
										StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
										GlSanKoorImport(StartKoor.x+OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum,
											StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									ContextMenuZum*OpenProgress),
									4);
								end
							else
								begin
								ArSkins[ActiveSkin].ArContextMenuTextureColor[3].SanSetColorA(OpenProgress);
								GlSanDrawComponent9(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									GlSanKoorImport(StartKoor.x+OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum,
										StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
										GlSanKoorImport(StartKoor.x+OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum,
											StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									ContextMenuZum*OpenProgress),
									ArSkins[ActiveSkin].ArRealContextMenu3[Low(ArSkins[ActiveSkin].ArRealContextMenu3)+0],
									ArSkins[ActiveSkin].ArRealContextMenu3[Low(ArSkins[ActiveSkin].ArRealContextMenu3)+1],
									ArSkins[ActiveSkin].ArRealContextMenu3[Low(ArSkins[ActiveSkin].ArRealContextMenu3)+2],
									ArSkins[ActiveSkin].ArRealContextMenu3[Low(ArSkins[ActiveSkin].ArRealContextMenu3)+3],
									ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ContextMenuTexture3]);
								end;
							end;
						end;
						end
					else
						begin
						case ViewTipe of
						GL_SAN_TEXT:
							begin
							if (ActiveSkin=-1) or (ArSkins[ActiveSkin].ContextMenuTexture2=-1) then
								begin
								glcolor4f(0.2,0.9,0.1,0.67*OpenProgress);
								GlSanRoundQuad(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress,StartKoor.z),
									GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress,
									StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress,StartKoor.z),
										GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress,
										StartKoor.z),
									ContextMenuZum*OpenProgress),
									4);
								glcolor4f(0.6,1,0.3,0.67*OpenProgress);
								GlSanRoundQuadLines(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress,StartKoor.z),
									GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress,
									StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress,StartKoor.z),
										GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress,
										StartKoor.z),
										ContextMenuZum*OpenProgress),
									4);
								end
							else
								begin
								ArSkins[ActiveSkin].ArContextMenuTextureColor[2].SanSetColorA(OpenProgress);
								GlSanDrawComponent9(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress,StartKoor.z),
									GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress,StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress,StartKoor.z),
										GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress,
										StartKoor.z),
										ContextMenuZum*OpenProgress),
									ArSkins[ActiveSkin].ArRealContextMenu2[Low(ArSkins[ActiveSkin].ArRealContextMenu2)+0],
									ArSkins[ActiveSkin].ArRealContextMenu2[Low(ArSkins[ActiveSkin].ArRealContextMenu2)+1],
									ArSkins[ActiveSkin].ArRealContextMenu2[Low(ArSkins[ActiveSkin].ArRealContextMenu2)+2],
									ArSkins[ActiveSkin].ArRealContextMenu2[Low(ArSkins[ActiveSkin].ArRealContextMenu2)+3],
									ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ContextMenuTexture2]);
								end;
							end;
						GL_SAN_TEXT_AND_ICONS:
							begin
							if (ActiveSkin=-1) or (ArSkins[ActiveSkin].ContextMenuTexture3=-1) then
								begin
								glcolor4f(0.2,0.9,0.1,0.67*OpenProgress);
								GlSanRoundQuad(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum,StartKoor.z),
									GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*OpenProgress*ContextMenuIconZum*ContextMenuZum,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum,
									StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum,StartKoor.z),
										GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*OpenProgress*ContextMenuIconZum*ContextMenuZum,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum,
										StartKoor.z),
									ContextMenuZum*OpenProgress*ContextMenuIconZum),
									4);
								glcolor4f(0.6,1,0.3,0.67*OpenProgress);
								GlSanRoundQuadLines(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum,StartKoor.z),
									GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*OpenProgress*ContextMenuIconZum*ContextMenuZum,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum,
									StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum,StartKoor.z),
										GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*OpenProgress*ContextMenuIconZum*ContextMenuZum,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum,
										StartKoor.z*OpenProgress),
									ContextMenuZum*OpenProgress*ContextMenuIconZum),
									4);
								end
							else
								begin
								ArSkins[ActiveSkin].ArContextMenuTextureColor[2].SanSetColorA(OpenProgress);
								GlSanDrawComponent9(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum,StartKoor.z),
									GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*OpenProgress*ContextMenuIconZum*ContextMenuZum,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum,StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum,StartKoor.z),
										GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*OpenProgress*ContextMenuIconZum*ContextMenuZum,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum,
										StartKoor.z),
										ContextMenuZum*OpenProgress*ContextMenuIconZum),
									ArSkins[ActiveSkin].ArRealContextMenu2[Low(ArSkins[ActiveSkin].ArRealContextMenu2)+0],
									ArSkins[ActiveSkin].ArRealContextMenu2[Low(ArSkins[ActiveSkin].ArRealContextMenu2)+1],
									ArSkins[ActiveSkin].ArRealContextMenu2[Low(ArSkins[ActiveSkin].ArRealContextMenu2)+2],
									ArSkins[ActiveSkin].ArRealContextMenu2[Low(ArSkins[ActiveSkin].ArRealContextMenu2)+3],
									ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ContextMenuTexture2]);
								end;
							end;
						GL_SAN_ICON:
							begin
							if (ActiveSkin=-1) or (ArSkins[ActiveSkin].ContextMenuTexture3=-1) then
								begin
								glcolor4f(0.2,0.9,0.1,0.67*OpenProgress);
								GlSanRoundQuad(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									GlSanKoorImport(StartKoor.x+OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum,
										StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
										GlSanKoorImport(StartKoor.x+OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum,
											StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									ContextMenuZum*OpenProgress),
									4);
								glcolor4f(0.6,1,0.3,0.67*OpenProgress);
								GlSanRoundQuadLines(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									GlSanKoorImport(StartKoor.x+OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum,
										StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
										GlSanKoorImport(StartKoor.x+OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum,
											StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									ContextMenuZum*OpenProgress),
									4);
								end
							else
								begin
								ArSkins[ActiveSkin].ArContextMenuTextureColor[2].SanSetColorA(OpenProgress);
								GlSanDrawComponent9(
									GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									GlSanKoorImport(StartKoor.x+OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum,
										StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									GetRadOkr(
										GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
										GlSanKoorImport(StartKoor.x+OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum,
											StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
									ContextMenuZum*OpenProgress),
									ArSkins[ActiveSkin].ArRealContextMenu2[Low(ArSkins[ActiveSkin].ArRealContextMenu2)+0],
									ArSkins[ActiveSkin].ArRealContextMenu2[Low(ArSkins[ActiveSkin].ArRealContextMenu2)+1],
									ArSkins[ActiveSkin].ArRealContextMenu2[Low(ArSkins[ActiveSkin].ArRealContextMenu2)+2],
									ArSkins[ActiveSkin].ArRealContextMenu2[Low(ArSkins[ActiveSkin].ArRealContextMenu2)+3],
									ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ContextMenuTexture2]);
								end;
							end;
						end;
						end;
					if Open and (ViewTipe=GL_SAN_TEXT) then 
						OutImage(GlSanKoorImport(StartKoor.x+0.5*MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*i*OpenProgress-ContextMenuZum*OpenProgress,StartKoor.z),0.5*MaxLength*OpenProgress,i)
					else
						if Open and ((ViewTipe=GL_SAN_TEXT_AND_ICONS)) then
							begin
							if GlSanFindTexture(Things[i].Ico) then
								begin
								glcolor4f(1,1,1,0.9);
								GlSanBindTexture(Things[i].Ico);
								WndSomeQuad(
									GlSanKoorImport(StartKoor.x+ContextMenuIconZum*ContextMenuZum*OpenProgress/5,
										StartKoor.y-(i)*ContextMenuZum*2*OpenProgress*ContextMenuIconZum-ContextMenuIconZum*ContextMenuZum*OpenProgress/5,StartKoor.z),
									GlSanKoorImport(StartKoor.x+2*ContextMenuIconZum*ContextMenuZum*OpenProgress-ContextMenuIconZum*ContextMenuZum*OpenProgress/5,
										StartKoor.y-(i+1)*ContextMenuZum*2*OpenProgress*ContextMenuIconZum+ContextMenuIconZum*ContextMenuZum*OpenProgress/5,StartKoor.z));
								GlSanDisableTexture;
								end;
							end;
					if Things[i].Tipe in [4..5] then
						glcolor4f(0.4,0.4,0.4,0.85*OpenProgress)
					else
						glcolor4f(0.1,0.1,0.1,0.95*OpenProgress);
					case ViewTipe of
					GL_SAN_TEXT:
						GlSanOutText(
							GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress,StartKoor.z),
							GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress,StartKoor.z),
							Things[i].Text,
							ContextMenuZum*OpenProgress);
					GL_SAN_ICONS_AND_TEXT:
						GlSanOutText(
							GlSanKoorImport(StartKoor.x+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
								StartKoor.y-(i+0.5)*ContextMenuZum*2*OpenProgress*ContextMenuIconZum+ContextMenuZum*OpenProgress,StartKoor.z),
							GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
								StartKoor.y-(i+0.5)*ContextMenuZum*2*OpenProgress*ContextMenuIconZum-ContextMenuZum*OpenProgress,StartKoor.z),
							Things[i].Text,ContextMenuZum*OpenProgress);
					end;
					if GlMouseReadKey=4 then
						begin
						GlMouseReadKey:=0;
						for ii:=Low(Things) to High(Things) do
							if (Things[ii].Tipe = 2) and (ii<>i) then
								begin
								PD:=Things[ii].Dialog;
								if PD^.Open then
									PD^.KillContext;
								end;
						case Things[i].Tipe of
						1:
							begin
							Proc:=GlSanWndProcedure(Things[i].Point);
							Proc(DependentWindow);
							ContextCloseID:=true;
							Proc:=GlSanWndProcedure(nil);
							end;
						2:
							begin
							PD:=Things[i].Dialog;
							if PD^.Open then
								begin
								PD^.KillContext;
								end
							else
								begin
								PD^.Open:=true;
								end;
							end;
						3:
							begin
							NewInto:
							case ViewTipe of
							GL_SAN_TEXT:
								begin
								Things[i].Tipe:=2;
								Func:=GlSanContextFunction(Things[i].Point);
								Things[i].Dialog:=Func(DependentWindow);
								Func:=GlSanContextFunction(nil);
								PD:=Things[i].Dialog;
								PD^.UserMemory.Dispose;
								PD^.StartKoor:=GlSanKoorImport(StartKoor.x+0.5*MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*i*OpenProgress-ContextMenuZum*OpenProgress,StartKoor.z);
								PD^.ReInitMaxLength;
								PD^.OpenTipe:=OpenTipe;
								PD^.ReTipeKoor(0,MaxLength*0.5*OpenProgress);
								PD^.OpenProgress:=0;
								PD^.ReKoor;
								end;
							GL_SAN_ICON_AND_TEXT:
								begin
								Things[i].Tipe:=2;
								Func:=GlSanContextFunction(Things[i].Point);
								Things[i].Dialog:=Func(DependentWindow);
								Func:=GlSanContextFunction(nil);
								PD:=Things[i].Dialog;
								PD^.UserMemory.Dispose;
								PD^.StartKoor:=GlSanKoorImport(
									StartKoor.x+0.5*MaxLength*OpenProgress+ContextMenuZum*OpenProgress*ContextMenuIconZum,
									StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum-ContextMenuZum*OpenProgress*ContextMenuIconZum,
									StartKoor.z);
								PD^.ReInitMaxLength;
								PD^.OpenTipe:=OpenTipe;
								PD^.ReTipeKoor(0,MaxLength*0.5*OpenProgress+ContextMenuZum*OpenProgress*ContextMenuIconZum);
								PD^.OpenProgress:=0;
								PD^.ReKoor;
								end;
							GL_SAN_ICON:
								begin
								Things[i].Tipe:=2;
								Func:=GlSanContextFunction(Things[i].Point);
								Things[i].Dialog:=Func(DependentWindow);
								Func:=GlSanContextFunction(nil);
								PD:=Things[i].Dialog;
								PD^.UserMemory.Dispose;
								PD^.StartKoor.Import(StartKoor.x+0.5*OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum,
									StartKoor.y-ContextMenuZum*OpenProgress*ContextMenuIconZum*IconsZum.y-ContextMenuZum*OpenProgress*i*2*ContextMenuIconZum*IconsZum.y,StartKoor.z);
								PD^.ReInitMaxLength;
								PD^.OpenTipe:=OpenTipe;
								PD^.ReTipeKoor(0,0.5*OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum);
								PD^.OpenProgress:=0;
								PD^.ReKoor;
								end;
							end;
							end;
						end;
						end;
					end;
		end;
	end;
end;

					(*
					1 - Вниз Вправо
					2 - Вверх Влево
					3 - Вверх Вправо
					4 - Вниз Влево
					*)
procedure GlSanContextMenu.OutImage(const Koor:GlSanKoor;const ML:real;const n:longint);
const
	a1:GlSanKoor2f = (x:0;y:0);
	c1:GlSanKoor2f = (x:1;y:1);
var
	Koor2:GlSanKoor;
procedure Out;
begin
if (ActiveSkin=-1) or (ArSkins[ActiveSkin].ContextMenuTexture5=-1) then
	begin
	glcolor4f(1,1,1,0.7);
	GlSanRoundQuad(
		Koor2,
		GlSanKoorImport(Koor2.x+ContextMenuZum*2*Things[n].ZumIco.x,Koor2.y-ContextMenuZum*2*Things[n].ZumIco.y,Koor2.z),
		GlSanMinimum(+ContextMenuZum*2*Things[n].ZumIco.x,ContextMenuZum*2*Things[n].ZumIco.y)/10,
		4);
	glcolor4f(1,0.7,1,0.9);
	GlSanRoundQuadLines(
		Koor2,
		GlSanKoorImport(Koor2.x+ContextMenuZum*2*Things[n].ZumIco.x,Koor2.y-ContextMenuZum*2*Things[n].ZumIco.y,Koor2.z),
		GlSanMinimum(+ContextMenuZum*2*Things[n].ZumIco.x,ContextMenuZum*2*Things[n].ZumIco.y)/10,
		4);
	end
else
	begin
	glcolor4f(1,1,1,0.7);
	GlSanDrawComponent9(
		Koor2,
		GlSanKoorImport(Koor2.x+ContextMenuZum*2*Things[n].ZumIco.x,Koor2.y-ContextMenuZum*2*Things[n].ZumIco.y,Koor2.z),
		GlSanMinimum(+ContextMenuZum*2*Things[n].ZumIco.x,ContextMenuZum*2*Things[n].ZumIco.y)/10,
		ArSkins[ActiveSkin].ArRealContextMenu5[Low(ArSkins[ActiveSkin].ArRealContextMenu5)+0],
		ArSkins[ActiveSkin].ArRealContextMenu5[Low(ArSkins[ActiveSkin].ArRealContextMenu5)+1],
		ArSkins[ActiveSkin].ArRealContextMenu5[Low(ArSkins[ActiveSkin].ArRealContextMenu5)+2],
		ArSkins[ActiveSkin].ArRealContextMenu5[Low(ArSkins[ActiveSkin].ArRealContextMenu5)+3],
		ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ContextMenuTexture5]);
	end;
glcolor4f(1,1,1,0.8);
GlSanBindTexture(Things[n].Ico);
WndSomeQuad(
	GlSanKoorImport(Koor2.x+ContextMenuZum*2*Things[n].ZumIco.x*0.1,Koor2.y-ContextMenuZum*2*Things[n].ZumIco.y*0.1,Koor2.z),
	GlSanKoorImport(Koor2.x+ContextMenuZum*2*Things[n].ZumIco.x*0.9,Koor2.y-ContextMenuZum*2*Things[n].ZumIco.y*0.9,Koor2.z),
	a1,c1);
glDisable(GL_TEXTURE_2D);
end;
begin
if GlSanFindTexture(Things[n].Ico) then
	begin
	if Koor.y+ContextMenuZum*2*Things[n].ZumIco.y>GlSanWA[0,1].y then
		begin
		if Koor.x+ML+ContextMenuZum*2*Things[n].ZumIco.x>GlSanWA[0,2].x then
			begin
			Koor2.Import(Koor.x-ML-ContextMenuZum*2*Things[n].ZumIco.x,Koor.y,Koor.z);
			end
		else
			begin
			Koor2.Import(Koor.x+ML,Koor.y,Koor.z);
			end;
		end
	else
		begin
		if Koor.x+ML+ContextMenuZum*2*Things[n].ZumIco.x>GlSanWA[0,2].x then
			begin
			Koor2.Import(Koor.x-ML-ContextMenuZum*2*Things[n].ZumIco.x,Koor.y+ContextMenuZum*2*Things[n].ZumIco.y,Koor.z);
			end
		else
			begin
			Koor2.Import(Koor.x+ML,Koor.y+ContextMenuZum*2*Things[n].ZumIco.y,Koor.z);
			end;
		end;
	Out;
	end;
end;

procedure GlSanContextMenu.Init;
var
	i:longint;
	Proc:GlSanWndProcedure;
	PD:PGlSanContextMenu;
begin
if Open then
	begin
	OpenProgress*=6;
	OpenProgress+=1;
	OpenProgress/=7;
	end
else
	begin
	OpenProgress*=6;
	OpenProgress/=7;
	end;
ReInitMaxLength;
case ViewTipe of
GL_SAN_TEXT:
	begin
	if (ActiveSkin=-1) or (ArSkins[ActiveSkin].ContextMenuTexture4=-1) then
		begin
		for i:=Low(Things) to High(Things) do
			if Things[i].Tipe in [3,2] then
				begin
				glcolor4f(0.9,0.9,0.9,0.8*OpenProgress);
				GlSanRoundQuad(
					GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress-0.5*ContextMenuZum*OpenProgress,StartKoor.y-ContextMenuZum*2*i*OpenProgress-0.25*ContextMenuZum*OpenProgress,StartKoor.z),
					GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+0.5*ContextMenuZum*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress+0.25*ContextMenuZum*OpenProgress,StartKoor.z),
					GetRadOkr(
						GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress-0.5*ContextMenuZum*OpenProgress,StartKoor.y-ContextMenuZum*2*i*OpenProgress-0.25*ContextMenuZum*OpenProgress,StartKoor.z),
						GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+0.5*ContextMenuZum*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress+0.25*ContextMenuZum*OpenProgress,StartKoor.z),
						ContextMenuZum*OpenProgress),
					4);
				glcolor4f(0.6,0.9,0.9,0.95*OpenProgress);
				GlSanRoundQuadLines(
					GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress-0.5*ContextMenuZum*OpenProgress,StartKoor.y-ContextMenuZum*2*i*OpenProgress-0.25*ContextMenuZum*OpenProgress,StartKoor.z),
					GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+0.5*ContextMenuZum*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress+0.25*ContextMenuZum*OpenProgress,StartKoor.z),
					GetRadOkr(
						GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress-0.5*ContextMenuZum*OpenProgress,StartKoor.y-ContextMenuZum*2*i*OpenProgress-0.25*ContextMenuZum*OpenProgress,StartKoor.z),
						GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+0.5*ContextMenuZum*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress+0.25*ContextMenuZum*OpenProgress,StartKoor.z),
						ContextMenuZum*OpenProgress),
					4);
				end;
		end
	else
		begin
		for i:=Low(Things) to High(Things) do
			if Things[i].Tipe in [3,2,5] then
				begin
				ArSkins[ActiveSkin].ArContextMenuTextureColor[4].SanSetColorA(OpenProgress);
				glEnable(GL_TEXTURE_2D);
				glBindTexture(GL_TEXTURE_2D,ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ContextMenuTexture4]);
				WndSomeQuad(
					GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress-0.5*ContextMenuZum*OpenProgress,StartKoor.y-ContextMenuZum*2*i*OpenProgress-0.25*ContextMenuZum*OpenProgress,StartKoor.z),
					GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+0.5*ContextMenuZum*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress+0.25*ContextMenuZum*OpenProgress,StartKoor.z));
				glDisable(GL_TEXTURE_2D);
				end;
		end;
	if (ActiveSkin=-1) or (ArSkins[ActiveSkin].ContextMenuTexture1=-1) then
		begin
		glcolor4f(0.9,0.9,0.9,0.8*OpenProgress);
		GlSanRoundQuad(
			StartKoor,
			GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*Length(Things)*OpenProgress,StartKoor.z),
			GetRadOkr(
				StartKoor,
				GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*OpenProgress,StartKoor.z),
				ContextMenuZum*OpenProgress),
			4);
		glcolor4f(0.6,0.9,0.9,0.95*OpenProgress);
		GlSanRoundQuadLines(
			StartKoor,
			GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*Length(Things)*OpenProgress,StartKoor.z),
			GetRadOkr(
				StartKoor,
				GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*OpenProgress,StartKoor.z),
				ContextMenuZum*OpenProgress),
			4);
		end
	else
		begin
		ArSkins[ActiveSkin].ArContextMenuTextureColor[1].SanSetColorA(OpenProgress);
		GlSanDrawComponent9(
			StartKoor,
			GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*Length(Things)*OpenProgress,StartKoor.z),
			GetRadOkr(
				StartKoor,
				GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*OpenProgress,StartKoor.z),
				ContextMenuZum),
				ArSkins[ActiveSkin].ArRealContextMenu1[Low(ArSkins[ActiveSkin].ArRealContextMenu1)+0],
				ArSkins[ActiveSkin].ArRealContextMenu1[Low(ArSkins[ActiveSkin].ArRealContextMenu1)+1],
				ArSkins[ActiveSkin].ArRealContextMenu1[Low(ArSkins[ActiveSkin].ArRealContextMenu1)+2],
				ArSkins[ActiveSkin].ArRealContextMenu1[Low(ArSkins[ActiveSkin].ArRealContextMenu1)+3],
				ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ContextMenuTexture1]);
		end;
	glcolor4f(0.1,0.1,0.1,0.95*OpenProgress);
	for i:=Low(Things) to High(Things) do
		begin
		if Things[i].Tipe in [4..5] then
			glcolor4f(0.4,0.4,0.4,0.85*OpenProgress);
		GlSanOutText(
			GlSanKoorImport(StartKoor.x,StartKoor.y-ContextMenuZum*2*i*OpenProgress,StartKoor.z),
			GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress,StartKoor.z),
			Things[i].Text,ContextMenuZum*OpenProgress);
		if Things[i].Tipe in [4..5] then
			glcolor4f(0.1,0.1,0.1,0.95*OpenProgress);
		end;
	end;
GL_SAN_ICONS_AND_TEXT:
	begin
	if (ActiveSkin=-1) or (ArSkins[ActiveSkin].ContextMenuTexture4=-1) then
		begin
		for i:=Low(Things) to High(Things) do
			if Things[i].Tipe in [3,2] then
				begin
				glcolor4f(0.9,0.9,0.9,0.8*OpenProgress);
				GlSanRoundQuad(
					GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress-0.5*ContextMenuZum*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
						StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum-0.25*ContextMenuZum*OpenProgress,StartKoor.z),
					GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+0.5*ContextMenuZum*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
						StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum+0.25*ContextMenuZum*OpenProgress,StartKoor.z),
					GetRadOkr(
						GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress-0.5*ContextMenuZum*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
							StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum-0.25*ContextMenuZum*OpenProgress,StartKoor.z),
						GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+0.5*ContextMenuZum*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
							StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum+0.25*ContextMenuZum*OpenProgress,StartKoor.z),
						ContextMenuZum*OpenProgress),
					4);
				glcolor4f(0.6,0.9,0.9,0.95*OpenProgress);
				GlSanRoundQuadLines(
					GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress-0.5*ContextMenuZum*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
						StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum-0.25*ContextMenuZum*OpenProgress,StartKoor.z),
					GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+0.5*ContextMenuZum*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
						StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum+0.25*ContextMenuZum*OpenProgress,StartKoor.z),
					GetRadOkr(
						GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress-0.5*ContextMenuZum*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
							StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum-0.25*ContextMenuZum*OpenProgress,StartKoor.z),
						GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+0.5*ContextMenuZum*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
							StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum+0.25*ContextMenuZum*OpenProgress,StartKoor.z),
						ContextMenuZum*OpenProgress),
					4);
				end;
		end
	else
		begin
		for i:=Low(Things) to High(Things) do
			if Things[i].Tipe in [3,2,5] then
				begin
				ArSkins[ActiveSkin].ArContextMenuTextureColor[4].SanSetColorA(OpenProgress);
				glEnable(GL_TEXTURE_2D);
				glBindTexture(GL_TEXTURE_2D,ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ContextMenuTexture4]);
				WndSomeQuad(
					GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress-0.5*ContextMenuZum*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
						StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum-0.25*ContextMenuZum*OpenProgress,StartKoor.z),
					GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+0.5*ContextMenuZum*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
						StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum+0.25*ContextMenuZum*OpenProgress,StartKoor.z));
				glDisable(GL_TEXTURE_2D);
				end;
		end;
	if (ActiveSkin=-1) or (ArSkins[ActiveSkin].ContextMenuTexture1=-1) then
		begin
		glcolor4f(0.9,0.9,0.9,0.8*OpenProgress);
		GlSanRoundQuad(
			StartKoor,
			GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
				StartKoor.y-ContextMenuZum*2*Length(Things)*OpenProgress*ContextMenuIconZum,StartKoor.z),
			GetRadOkr(
				StartKoor,
				GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
					StartKoor.y-ContextMenuZum*2*OpenProgress*ContextMenuIconZum,StartKoor.z),
				ContextMenuZum*OpenProgress),
			4);
		glcolor4f(0.6,0.9,0.9,0.95*OpenProgress);
		GlSanRoundQuadLines(
			StartKoor,
			GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
				StartKoor.y-ContextMenuZum*2*Length(Things)*OpenProgress*ContextMenuIconZum,StartKoor.z),
			GetRadOkr(
				StartKoor,
				GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
					StartKoor.y-ContextMenuZum*2*OpenProgress*ContextMenuIconZum,StartKoor.z),
				ContextMenuZum*OpenProgress),
			4);
		end
	else
		begin
		ArSkins[ActiveSkin].ArContextMenuTextureColor[1].SanSetColorA(OpenProgress);
		GlSanDrawComponent9(
			StartKoor,
			GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
				StartKoor.y-ContextMenuZum*2*Length(Things)*OpenProgress*ContextMenuIconZum,StartKoor.z),
			GetRadOkr(
				StartKoor,
				GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
					StartKoor.y-ContextMenuZum*2*OpenProgress*ContextMenuIconZum,StartKoor.z),
				ContextMenuZum),
				ArSkins[ActiveSkin].ArRealContextMenu1[Low(ArSkins[ActiveSkin].ArRealContextMenu1)+0],
				ArSkins[ActiveSkin].ArRealContextMenu1[Low(ArSkins[ActiveSkin].ArRealContextMenu1)+1],
				ArSkins[ActiveSkin].ArRealContextMenu1[Low(ArSkins[ActiveSkin].ArRealContextMenu1)+2],
				ArSkins[ActiveSkin].ArRealContextMenu1[Low(ArSkins[ActiveSkin].ArRealContextMenu1)+3],
				ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ContextMenuTexture1]);
		end;
	glcolor4f(0.1,0.1,0.1,0.95*OpenProgress);
	for i:=Low(Things) to High(Things) do
		begin
		if Things[i].Tipe in [4..5] then
			glcolor4f(0.4,0.4,0.4,0.85*OpenProgress);
		GlSanOutText(
			GlSanKoorImport(StartKoor.x+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
				StartKoor.y-(i+0.5)*ContextMenuZum*2*OpenProgress*ContextMenuIconZum+ContextMenuZum*OpenProgress,StartKoor.z),
			GlSanKoorImport(StartKoor.x+MaxLength*OpenProgress+2*ContextMenuIconZum*ContextMenuZum*OpenProgress,
				StartKoor.y-(i+0.5)*ContextMenuZum*2*OpenProgress*ContextMenuIconZum-ContextMenuZum*OpenProgress,StartKoor.z),
			Things[i].Text,ContextMenuZum*OpenProgress);
		if Things[i].Tipe in [4..5] then
			glcolor4f(0.1,0.1,0.1,0.95*OpenProgress);
		end;
	{Initialization Icons}
	glcolor4f(1,1,1,0.9*OpenProgress);
	for i:=Low(Things) to High(Things) do
		if GlSanFindTexture(Things[i].Ico) then
			begin
			GlSanBindTexture(Things[i].Ico);
			WndSomeQuad(
				GlSanKoorImport(StartKoor.x+ContextMenuIconZum*ContextMenuZum*OpenProgress/5,
					StartKoor.y-(i)*ContextMenuZum*2*OpenProgress*ContextMenuIconZum-ContextMenuIconZum*ContextMenuZum*OpenProgress/5,StartKoor.z),
				GlSanKoorImport(StartKoor.x+2*ContextMenuIconZum*ContextMenuZum*OpenProgress-ContextMenuIconZum*ContextMenuZum*OpenProgress/5,
					StartKoor.y-(i+1)*ContextMenuZum*2*OpenProgress*ContextMenuIconZum+ContextMenuIconZum*ContextMenuZum*OpenProgress/5,StartKoor.z));
			GlSanDisableTexture;
			end;
	end;
GL_SAN_ICONS:
	begin
	if (ActiveSkin=-1) or (ArSkins[ActiveSkin].ContextMenuTexture4=-1) then
		begin
		for i:=Low(Things) to High(Things) do
			if Things[i].Tipe in [3,2] then
				begin
				glcolor4f(0.9,0.9,0.9,0.8*OpenProgress);
				GlSanRoundQuad(
					GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x-0.5*ContextMenuZum*OpenProgress*ContextMenuIconZum,
						StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y-0.25*ContextMenuZum*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
					GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x+0.5*ContextMenuZum*OpenProgress*ContextMenuIconZum,
						StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y+0.25*ContextMenuZum*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
					GetRadOkr(
						GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x-0.5*ContextMenuZum*OpenProgress*ContextMenuIconZum,
							StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y-0.25*ContextMenuZum*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
						GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x+0.5*ContextMenuZum*OpenProgress*ContextMenuIconZum,
							StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y+0.25*ContextMenuZum*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
						ContextMenuZum*OpenProgress),
					4);
				glcolor4f(0.6,0.9,0.9,0.95*OpenProgress);
				GlSanRoundQuadLines(
					GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x-0.5*ContextMenuZum*OpenProgress*ContextMenuIconZum,
						StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y-0.25*ContextMenuZum*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
					GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x+0.5*ContextMenuZum*OpenProgress*ContextMenuIconZum,
						StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y+0.25*ContextMenuZum*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
					GetRadOkr(
						GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x-0.5*ContextMenuZum*OpenProgress*ContextMenuIconZum,
							StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y-0.25*ContextMenuZum*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
						GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x+0.5*ContextMenuZum*OpenProgress*ContextMenuIconZum,
							StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y+0.25*ContextMenuZum*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
						ContextMenuZum*OpenProgress),
					4);
				end;
		end
	else
		begin
		for i:=Low(Things) to High(Things) do
			if Things[i].Tipe in [3,2,5] then
				begin
				ArSkins[ActiveSkin].ArContextMenuTextureColor[4].SanSetColorA(OpenProgress);
				glEnable(GL_TEXTURE_2D);
				glBindTexture(GL_TEXTURE_2D,ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ContextMenuTexture4]);
				WndSomeQuad(
					GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x-0.5*ContextMenuZum*OpenProgress*ContextMenuIconZum,
						StartKoor.y-ContextMenuZum*2*i*OpenProgress*ContextMenuIconZum*IconsZum.y-0.25*ContextMenuZum*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
					GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x+0.5*ContextMenuZum*OpenProgress*ContextMenuIconZum,
						StartKoor.y-ContextMenuZum*2*(i+1)*OpenProgress*ContextMenuIconZum*IconsZum.y+0.25*ContextMenuZum*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z));
				glDisable(GL_TEXTURE_2D);
				end;
		end;
	if (ActiveSkin=-1) or (ArSkins[ActiveSkin].ContextMenuTexture1=-1) then
		begin
		glcolor4f(0.9,0.9,0.9,0.8*OpenProgress);
		GlSanRoundQuad(
			StartKoor,
			GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x,
				StartKoor.y-ContextMenuZum*2*Length(Things)*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
			GetRadOkr(
				StartKoor,
				GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x,
					StartKoor.y-ContextMenuZum*2*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
				ContextMenuZum*OpenProgress),
			4);
		glcolor4f(0.6,0.9,0.9,0.95*OpenProgress);
		GlSanRoundQuadLines(
			StartKoor,
			GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x,
				StartKoor.y-ContextMenuZum*2*Length(Things)*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
			GetRadOkr(
				StartKoor,
				GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x,
					StartKoor.y-ContextMenuZum*2*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
				ContextMenuZum*OpenProgress),
			4);
		end
	else
		begin
		ArSkins[ActiveSkin].ArContextMenuTextureColor[1].SanSetColorA(OpenProgress);
		GlSanDrawComponent9(
			StartKoor,
			GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x,
				StartKoor.y-ContextMenuZum*2*Length(Things)*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
			GetRadOkr(
				StartKoor,
				GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x,
					StartKoor.y-ContextMenuZum*2*OpenProgress*ContextMenuIconZum*IconsZum.y,StartKoor.z),
				ContextMenuZum*OpenProgress),
				ArSkins[ActiveSkin].ArRealContextMenu1[Low(ArSkins[ActiveSkin].ArRealContextMenu1)+0],
				ArSkins[ActiveSkin].ArRealContextMenu1[Low(ArSkins[ActiveSkin].ArRealContextMenu1)+1],
				ArSkins[ActiveSkin].ArRealContextMenu1[Low(ArSkins[ActiveSkin].ArRealContextMenu1)+2],
				ArSkins[ActiveSkin].ArRealContextMenu1[Low(ArSkins[ActiveSkin].ArRealContextMenu1)+3],
				ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ContextMenuTexture1]);
		end;
	{Out Images}
	glcolor4f(1,1,1,0.9*OpenProgress);
	for i:=Low(Things) to High(Things) do
		if GlSanFindTexture(Things[i].Ico) then
			begin
			GlSanBindTexture(Things[i].Ico);
			WndSomeQuad(
				GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x/6,
					StartKoor.y-(i)*ContextMenuZum*2*OpenProgress*ContextMenuIconZum*IconsZum.y-OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.y/6,StartKoor.z),
				GlSanKoorImport(StartKoor.x+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x-OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.x/6,
					StartKoor.y-(i+1)*ContextMenuZum*2*OpenProgress*ContextMenuIconZum*IconsZum.y+OpenProgress*ContextMenuIconZum*ContextMenuZum*IconsZum.y/6,StartKoor.z));
			GlSanDisableTexture;
			end;
	end;
end;
for i:=Low(Things) to High(Things) do
	if Things[i].Tipe = 2 then
		begin
		PD:=Things[i].Dialog;
		if (PD^.Open=false) and (PD^.OpenProgress<0.01) then
			begin
			PD^.CloseContext;
			dispose(PD);
			Things[i].Tipe:=3;
			Things[i].Dialog:=nil;
			end
		else
			begin
			case ViewTipe of
			GL_SAN_TEXT:
				begin
				PD^.StartKoor.Import(StartKoor.x+0.5*MaxLength*OpenProgress,StartKoor.y-ContextMenuZum*OpenProgress-ContextMenuZum*OpenProgress*i*2,StartKoor.z);
				PD^.OpenTipe:=OpenTipe;
				PD^.ReTipeKoor(0,MaxLength*0.5*OpenProgress);
				PD^.ReKoor;
				PD^.Init;
				end;
			GL_SAN_TEXT_AND_ICONS:
				begin
				PD^.StartKoor.Import(StartKoor.x+0.5*MaxLength*OpenProgress+ContextMenuIconZum*ContextMenuZum*OpenProgress,
					StartKoor.y-ContextMenuIconZum*ContextMenuZum*OpenProgress-ContextMenuIconZum*ContextMenuZum*OpenProgress*i*2,StartKoor.z);
				PD^.OpenTipe:=OpenTipe;
				PD^.ReTipeKoor(0,MaxLength*0.5*OpenProgress+ContextMenuIconZum*ContextMenuZum*OpenProgress);
				PD^.ReKoor;
				PD^.Init;
				end;
			GL_SAN_ICONS:
				begin
				PD^.StartKoor.Import(StartKoor.x+0.5*OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum,
					StartKoor.y-ContextMenuZum*OpenProgress*ContextMenuIconZum*IconsZum.y-ContextMenuZum*OpenProgress*i*2*ContextMenuIconZum*IconsZum.y,StartKoor.z);
				PD^.OpenTipe:=OpenTipe;
				PD^.ReTipeKoor(0,0.5*OpenProgress*IconsZum.x*ContextMenuIconZum*ContextMenuZum);
				PD^.ReKoor;
				PD^.Init;
				end;
			end;
			end;
		end;
if DependentProc<>nil then
	begin
	Proc:=GlSanWndProcedure(DependentProc);
	Proc(DependentWindow);
	Proc:=GlSanWndProcedure(nil);
	end;
end;

procedure GlSanContextMenu.ReInitMaxLength;
var
	i,ii:longint;
begin
MaxLength:=0;
for i:=Low(Things) to High(Things) do
	if MaxLength<GlSanTextLength(Things[i].Text,ContextMenuZum) then
		MaxLength:=GlSanTextLength(Things[i].Text,ContextMenuZum);
if not CoolStrings then
	begin
	ii:=0;
	while ii<Length(Things) do
		begin
		ii:=0;
		for i:=Low(Things) to High(Things) do
			if (GlSanTextLength(Things[i].Text,ContextMenuZum)>abs(GlSanWA[0,1].x-GlSanWA[0,3].x)/3) and (Length(Things[i].Text)>4) then
				begin
				if (Things[i].Text[Length(Things[i].Text)-0]='.') and
					(Things[i].Text[Length(Things[i].Text)-1]='.') and
					(Things[i].Text[Length(Things[i].Text)-2]='.') then
						begin
						Things[i].Text[0]:=char(Length(Things[i].Text)-1);
						Things[i].Text[Length(Things[i].Text)-2]:='.';
						end
					else
						begin
						Things[i].Text[Length(Things[i].Text)-0]:='.';
						Things[i].Text[Length(Things[i].Text)-1]:='.';
						Things[i].Text[Length(Things[i].Text)-2]:='.';
						end;
				end
			else
				ii+=1;
		end;
	CoolStrings:=true;
	end;
end;
function GlSanGetKoor(const t1,t2:GlSanKoor; const r:real):GlSanKoor;
begin
GlSanGetKoor:=GlSanKoorImport(
	-r*(t1.x-t2.x)+t1.x,
	-r*(t1.y-t2.y)+t1.y,
	-r*(t1.z-t2.z)+t1.z);
end;

function GlSanGetOtn(const t,t1,t2:GlSanKoor):real;
begin
GlSanGetOtn:=GlSanRast(t,t1)/GlSanRast(t2,t1);
end;



procedure GlSanContextMenu.CloseContext;
var
	i:longint;
	Into:PGlSanContextMenu;
begin
for i:=Low(Things) to High(Things) do
	begin
	if (Things[i].Point<>nil) and (Things[i].Tipe=2) and (Things[i].Dialog<>nil) then
		begin
		Into:=Things[i].Dialog;
		Into^.CloseContext;
		Into^.UserMemory.Dispose;
		Dispose(Into);
		end;
	end;
SetLength(Things,0);
end;

function GlSanRazn(const a,b:GlSanKoorPlosk):boolean;
begin
if (abs(a.a-b.a)+abs(a.b-b.b)+abs(a.c-b.c)+abs(a.d-b.d))>GlSanMin then
	GlSanRazn:=true
else
	GlSanRazn:=false;
end;

procedure GlSanKoorPlosk.TogeverColor(const _:GlSanKoorPlosk);
begin
glcolor4f((a+_.a)/2,(b+_.b)/2,(c+_.c)/2,(d+_.d)/2);
end;

function GlSanKoorOnLine(const t,t1,t2:GlSanKoor):boolean;
var
	d:GlSanKoorPlosk;
begin
d:=GlSanPloskKoor(t,t1,t2);
if abs(d.a)+abs(d.b)+abs(d.c)+abs(d.d)>GlSanMin then
	GlSanKoorOnLine:=false
else
	GlSanKoorOnLine:=true;
end;

procedure GlSanOutTextS(const bvl:GlSanKoor;bnp:GlSanKoor;const Text:string; const R:real);
var
	Razn:GlSanKoor2f;
begin
Razn.x:=GlSanMinimum(abs(bvl.y-bnp.y),abs(bvl.x-bnp.x))*0.47;
Razn.y:=r;
GlSanOutTextS(GlSanSredKoor(bvl,bnp),Text,Razn);
end;

function GlSanGetPeresLines(const q1,q2,w1,w2:GlSanKoor):GlSanKoor;
var
	q3:GlSanKoor;
begin
q3:=q2;
q3.Togever(GetNormalVector(q1,q2,w1));
GlSanGetPeresLines:=GlSanTP3P(
	GlSanPloskKoor(q1,q2,q3),
	GlSanPloskKoor(GlSanSredKoor(q1,q2),w1,w2),
	GlSanPloskKoor(GlSanSredKoor(q1,q3),w1,w2)
	);
end;
function GlSanLineToPlosk(const a1,a2,a3,q1,q2:GlSanKoor):GlSanKoor;
begin
GlSanLineToPlosk:=GlSanTP3P(
	GlSanPloskKoor(a1,a2,a3),
	GlSanPloskKoor(GlSanSredKoor(a1,a2),q1,q2),
	GlSanPloskKoor(GlSanSredKoor(a1,a3),q1,q2)
	);
end;

function GlSanPrinOtr(const t1,t2,t:GlSanKoor):boolean;
begin
if abs(GlSanRast(t,t1)+GlSanRast(t,t2)-GlSanRast(t2,t1))<GlSanMin then
	GlSanPrinOtr:=true
else
	GlSanPrinOtr:=false;
end;

function  GlSanGetPerpedKoor(const t1,t2,t:GlSanKoor):GlSanKoor;
var
	t3:GlSanKoor;
begin
t3:=t2;
t3.Togever(GetNormalVector(t1,t2,t));
GlSanGetPerpedKoor:=PutPointToPolygone(t1,t2,t3,t);
end;

function GlSanMinimum(const r1,r2:real):real;
begin
if r1<r2 then GlSanMinimum:=r1 else GlSanMinimum:=r2;
end;

function GetRadOkr( const bvl,bnp:GlSanKoor; const RadOkr:real):real;
var
	MR:real;
begin
MR:=GlSanMinimum(abs(bvl.x-bnp.x),abs(bvl.y-bnp.y));
MR*=0.15;
if RadOkr<=MR then 
	GetRadOkr:=RadOkr
else
	GetRadOkr:=MR;
end;

function GetNormalVector(p1,p2,p3:GlSanKoor):GlSanKoor;
var a,b,c:real;
begin
a:=p1.y*(p2.z-p3.z)+p2.y*(p3.z-p1.z)+p3.y*(p1.z-p2.z);
b:=p1.z*(p2.x-p3.x)+p2.z*(p3.x-p1.x)+p3.z*(p1.x-p2.x);
c:=p1.x*(p2.y-p3.y)+p2.x*(p3.y-p1.y)+p3.x*(p1.y-p2.y);
GetNormalVector.Import(a/(sqrt(a*a+b*b+c*c)),b/(sqrt(a*a+b*b+c*c)),c/(sqrt(a*a+b*b+c*c)));
end;

function PutPointToPolygone(p1,p2,p3,a:GlSanKoor):GlSanKoor;
var Normal,b:GlSanKoor;
begin
	normal:=GetNormalVector(p1,p2,p3);
	b.Import(a.x+Normal.x,a.y+Normal.y,a.z+Normal.z);
	PutPointToPolygone:=GlSanTP3P(
					GlSanPloskKoor(p1,p2,p3),
					GlSanPloskKoor(GlSanSredKoor(p1,p2),a,b),
					GlSanPloskKoor(GlSanSredKoor(p1,p3),a,b)
					);
end;
	
procedure WndSomeQuad(const a,c:GlSanKoor; const a1,c1:GlSanKoor2f);
var
	b,d:GlSanKoor;
begin
b.Import(c.x,a.y,a.z);
d.Import(a.x,c.y,a.z);
glBegin(GL_QUADS);
glTexCoord2f(a1.x,1-a1.y);
	a.Vertex;
glTexCoord2f(c1.x,1- a1.y);
	b.Vertex;
glTexCoord2f(c1.x, 1-c1.y);
	c.Vertex;
glTexCoord2f(a1.x,1-c1.y);
	d.Vertex;
glEnd;
end;

procedure WndSomeQuad(const a,c:GlSanKoor; const a1,c1:GlSanKoor2f; const IDt:GLUInt);
var
	b,d:GlSanKoor;
begin
glEnable(GL_TEXTURE_2D);
glBindTexture(GL_TEXTURE_2D,IDt);
b.Import(c.x,a.y,a.z);
d.Import(a.x,c.y,a.z);
glBegin(GL_QUADS);
glTexCoord2f(a1.x,a1.y);
	a.Vertex;
glTexCoord2f(c1.x, a1.y);
	b.Vertex;
glTexCoord2f(c1.x, c1.y);
	c.Vertex;
glTexCoord2f(a1.x,c1.y);
	d.Vertex;
glEnd;
glDisable(GL_TEXTURE_2D);
end;

function GlSanFindDIR(const s:string):boolean;
var
	i:longint;
	Poz:longint=0;
	sr:DOS.SearchRec;
	N1,N2:string;
begin
GlSanFindDIR:=false;
for i:=1 to Length(s)-1 do
	if s[i]='\' then
		Poz:=i;
if Poz<1 then 
	exit;
N1:=GlSanCopy(s,1,i-1);
N2:=GlSanCopy(s,i+1,Length(s));
DOS.findfirst(n1+'*.*',$3F,sr);
While (dos.DosError<>18) do
	begin
	if (sr.Name=n2) then
		GlSanFindDIR:=true;
	DOS.findnext(sr);
	end;
DOS.findclose(sr);
end;

procedure GlSanWndVertex(const PPW:PPGlSanWnd;K:GlSanKoor);
begin
if ((PPW<>nil) and (PPW^<>nil)) then
	begin
	k.z:=ppw^^.TVL.z+0.001;
	k.x+=ppw^^.TVL.x;
	k.y+=ppw^^.TVL.y;
	K.Vertex;
	end;
end;

procedure GlSanWndSetButtonTexture(const p:PPGlSanWnd;const idb:longint;const s:string);
begin
if ((P<>nil) and (p^<>nil)) and (Length(p^^.ArButtons)<>0) and (idb-1 in [Low(p^^.ArButtons)..High(p^^.ArButtons)]) then
	begin
	p^^.ArButtons[idb-1].Tex:=s;
	end;
end;
procedure GlSanWndSetButtonTextureClick(const p:PPGlSanWnd;const idb:longint;const s:string);
begin
if ((P<>nil) and (p^<>nil)) and (Length(p^^.ArButtons)<>0) and (idb-1 in [Low(p^^.ArButtons)..High(p^^.ArButtons)]) then
	begin
	p^^.ArButtons[idb-1].TexC:=s;
	end;
end;
procedure GlSanWndSetButtonTextureOnClick(const p:PPGlSanWnd;const idb:longint;const s:string);
begin
if ((P<>nil) and (p^<>nil)) and (Length(p^^.ArButtons)<>0) and (idb-1 in [Low(p^^.ArButtons)..High(p^^.ArButtons)]) then
	begin
	p^^.ArButtons[idb-1].TexOn:=s;
	end;
end;
procedure GlSanWndSetLastButtonTexture(const p:PPGlSanWnd;const s:string);
begin
if ((P<>nil) and (p^<>nil)) and (Length(p^^.ArButtons)<>0) then
	begin
	p^^.ArButtons[High(p^^.ArButtons)].Tex:=s;
	end;
end;
procedure GlSanWndSetLastButtonTextureClick(const p:PPGlSanWnd;const s:string);
begin
if ((P<>nil) and (p^<>nil)) and (Length(p^^.ArButtons)<>0) then
	begin
	p^^.ArButtons[High(p^^.ArButtons)].TexC:=s;
	end;
end;
procedure GlSanWndSetLastButtonTextureOnClick(const p:PPGlSanWnd;const s:string);
begin
if ((P<>nil) and (p^<>nil)) and (Length(p^^.ArButtons)<>0) then
	begin
	p^^.ArButtons[High(p^^.ArButtons)].TexOn:=s;
	end;
end;

procedure WndSomeQuad(a,c:GlSanKoor);
var
	b,d:GlSanKoor;
begin
b.Import(c.x,a.y,a.z);
d.Import(a.x,c.y,a.z);
glBegin(GL_QUADS);
glTexCoord2f(0,1);a.Vertex;
glTexCoord2f(1, 1);b.Vertex;
glTexCoord2f(1, 0);c.Vertex;
glTexCoord2f(0,0);d.Vertex;
glEnd;
end;
function GlSanWndGetWndKoor(const p:PPGlSanWnd; const k2:GlSanKoor2f):GlSanKoor;
begin
if ((p<>nil ) and(p^<>nil)) then
	begin
	GlSanWndGetWndKoor:=GlSanKoorImport(
	abs((-p^^.TVL.x+p^^.TNP.x))*k2.x{+p^^.TVL.x},
	-abs((-p^^.TVL.y+p^^.TNP.y))*k2.y{+p^^.TVL.y},
	p^^.TVL.z);
	end;
end;

procedure GlSanWndSetInitProc(const p:pointer;const pr:pointer);
var
	W:GlSanUUWnd;
begin
w:=p;
if ((p<>nil) and (w^<>nil)) then
	begin
	w^^.InitProc:=pr;
	end;
end;
function GlSanBindTexture( FileName:string):boolean;
var i,ii:longint;
begin
i:=low(ArTextures);
ii:=-1;
while (ii=-1)and(i<=high(ArTextures)) do
	begin
	if ArTextures[i].Name=FileName then ii:=i;
	i+=1;
	end;
if ii=-1 then
	begin
	GlSanBindTexture:=false;
	end
else
	begin
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D,ArTextures[ii].ID);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	GlSanBindTexture:=true;
	end;
end;

function GlSanSetFont(const s:string):boolean;
begin
if GlSanGetFontNumber(s)=-1 then
	GlSanSetFont:=false
else
	begin
	ActiveFont:=GlSanGetFontNumber(s);
	GlSanSetFont:=true;
	end;
end;

procedure GlSanCorrectFont(const b:boolean);
begin
CorrectFont:=b;
end;

procedure GlSanPOPFont;
begin
ActiveFont:=BufferFont;
CorrectFont:=BufferCorrectFont;
end;
procedure GlSanPushFont;
begin
BufferFont:=ActiveFont;
BufferCorrectFont:=CorrectFont;
end;
procedure SomeQuad(a,b,c,d:GlSanKoor;vl,np:GlSanKoor2f);
begin
glBegin(GL_QUADS);
glTexCoord2f(vl.x, vl.y);a.Vertex;
glTexCoord2f(np.x, vl.y);b.Vertex;
glTexCoord2f(np.x, np.y);c.Vertex;
glTexCoord2f(vl.x, np.y);d.Vertex;
glEnd;
end;

procedure DDPoint.Dispose;
begin
SetLEngth(ArDPoint,0);
SetLEngth(ArLongint,0);
SetLEngth(ArGlSanKoor,0);
end;

procedure glSanBindTexture(var q:GLUInt);
begin
glEnable(GL_TEXTURE_2D);
glBindTexture(GL_TEXTURE_2D, q);
end;
procedure glTranslatef(const i,ii,iii:real);
begin
gl.glTranslatef(i,ii,iii);
end;

procedure glLoadIdentity;
begin
gl.glLoadIdentity;
end;

procedure RNRPlayRamdomYes;
var
	i:longint;
begin
i:=random(13)+1;
case GlSanKolChisel(i) of
1:
	begin
	RNRPlayAudioNotError('yes0'+GlSanStr(i));
	end;
2:
	begin
	RNRPlayAudioNotError('yes'+GlSanStr(i));
	end;
end;
end;

procedure GlSanWndSetTittleHeight( const p:pointer; const h:longint);
var
	w:PPGlSanWnd;
begin
w:=p;
if ((P<>nil) and (w^<>nil)) then
	begin
	w^^.ONZP.y:=w^^.OVL.y+abs(w^^.OVL.y-w^^.ONP.y)*(h/w^^.WndH);
	end;
end;
procedure RNRPlayRamdomNo;
var
	i:longint;
begin
i:=random(20);
i+=1;
case GlSanKolChisel(i) of
1:
	begin
	RNRPlayAudioNotError('no0'+GlSanStr(i));
	end;
2:
	begin
	RNRPlayAudioNotError('no'+GlSanStr(i));
	end;
end;
end;

function GlSanCopy(const s:string;const l1,l2:longint):string;
var
	i:longint;
begin
GlSanCopy:='';
for i:=l1 to l2 do
	GlSanCopy+=s[i];
end;

procedure RNRPlayAudio(s:string);
var
	i,ii:longint;
begin
	i:=Low(RNRNames);
	ii:=-1;
	for i:=0 to High(RNRNames) do
		if RNRNames[i].Name=s then
			begin
			ii:=i;
			break;
			end;
	if ii<>-1 then
		RNRPlayAudio(ii+1)
	else
		begin
		{$IF APPTYPE=GUI}
			GlSanCreateOKWnd( nil ,'Error (In RNR System)','Don`t may playing sound. ( '+s+' ) ');
		{$ELSE}
			GlSanCreateOKWnd( nil ,'Error (In RNR System)','Don`t may playing sound. ( '+s+' ) ');
			textcolor(12);
			write('Error ');
			textcolor(14);
			write('(In RNR System) ');
			textcolor(15);
			writeln('Don`t may playing sound. ( ',s,' ) ');
			{$ENDIF}
		end;
end;

procedure RNRPlayAudioNotError(s:string);
var
	i,ii:longint;
begin
	i:=Low(RNRNames);
	ii:=-1;
	for i:=0 to High(RNRNames) do
		if RNRNames[i].Name=s then
			begin
			ii:=i;
			break;
			end;
	if ii<>-1 then
		RNRPlayAudio(ii+1)
	else
		begin
		
		end;
end;

procedure RNRSourceNewPosByVel(n:longint);
begin
	RNRSourcePos[n,0]+=RNRSourceVel[n,0];
	RNRSourcePos[n,1]+=RNRSourceVel[n,1];
	RNRSourcePos[n,2]+=RNRSourceVel[n,2];
	alSourcefv(RNRSource[n], AL_POSITION, @RNRSourcePos[n]);

end;

procedure RNRListenerPosImport(k:GlSanKoor);
begin
	RNRListenerPos[0]:=k.x;
	RNRListenerPos[1]:=k.y;
	RNRListenerPos[2]:=k.z;
end;

procedure RNRListenerVelImport(k:GlSanKoor);
begin
	RNRListenerVel[0]:=k.x;
	RNRListenerVel[1]:=k.y;
	RNRListenerVel[2]:=k.z;
end;

procedure RNRListenerOriImport(i,k:GlSanKoor);
begin
	RNRListenerOri[0]:=i.x;
	RNRListenerOri[1]:=i.y;
	RNRListenerOri[2]:=i.z;
	RNRListenerOri[3]:=k.x;
	RNRListenerOri[4]:=k.y;
	RNRListenerOri[5]:=k.z;
end;

procedure RNRListenerImport(Pos,Vel:GlSanKoor);
begin
	RNRListenerVelImport(Vel);
	RNRListenerPosImport(Pos);
	alListenerfv(AL_POSITION,@RNRListenerPos);
	alListenerfv(AL_VELOCITY,@RNRListenerVel);
	alListenerfv(AL_ORIENTATION,@RNRListenerOri);
end;

procedure RNRListenerImport(Pos,Vel,OriT,OriV:GlSanKoor);
begin
	RNRListenerVelImport(Vel);
	RNRListenerPosImport(Pos);
	RNRListenerOriImport(OriT,OriV);
	alListenerfv(AL_POSITION,@RNRListenerPos);
	alListenerfv(AL_VELOCITY,@RNRListenerVel);
	alListenerfv(AL_ORIENTATION,@RNRListenerOri);
end;


procedure RNRSourcePosImport(n:string;k:GlSanKoor);
var
	i,ii:longint;
begin
ii:=-1;
for i:=low(RNRNames) to High(RNRNames) do
	if RNRNames[i].Name=n then
		ii:=i;
if ii=-1 then
	begin
	GlSanCreateOKWnd( nil ,'Error (In RNR System)','Don`t may import sourse position. ( '+n+' ) ');
	end
else
	begin
	RNRSourcePosImport(ii,k);
	end;
end;

procedure RNRSourcePosImport(n:longint;k:GlSanKoor);
begin
	RNRSourcePos[n,0]:=k.x;
	RNRSourcePos[n,1]:=k.y;
	RNRSourcePos[n,2]:=k.z;
	alSourcefv(RNRSource[n], AL_POSITION, @RNRSourcePos[n]);
end;

procedure RNRSourceVelImport(n:longint;k:GlSanKoor);
begin
	RNRSourceVel[n,0]:=k.x;
	RNRSourceVel[n,1]:=k.y;
	RNRSourceVel[n,2]:=k.z;
end;
procedure RNRSourceImport(n:string;Pos,Vel:GlSanKoor;looping:boolean);
var
	i,ii:longint;
begin
ii:=-1;
for i:=low(RNRNames) to High(RNRNames) do
	if RNRNames[i].Name=n then
		ii:=i;
if ii=-1 then
	begin
	GlSanCreateOKWnd( nil ,'Error (In RNR System)','Don`t may import sourse. ( '+n+' ) ');
	end
else
	begin
	RNRSourceImport(ii,Pos,Vel,looping);
	end;
end;

procedure RNRSourceImport(n:longint;Pos,Vel:GlSanKoor;looping:boolean);
begin
	RNRSourcePosImport(n,Pos);
	RNRSourceVelImport(n,Vel);

	alSourcei( RNRSource[n], AL_BUFFER, RNRBuffer[n]);
	alSourcefv(RNRSource[n], AL_POSITION, @RNRSourcePos[n]);
	alSourcefv(RNRSource[n], AL_VELOCITY, @RNRSourceVel[n]);
	if looping=true then
		alSourcei( RNRSource[n], AL_LOOPING, AL_TRUE)
	else
		alSourcei( RNRSource[n], AL_LOOPING, AL_FALSE);

end;

procedure RNROpenalInit;
begin
	InitOpenAL(OpenALLibName);
	RNRDevice := alcOpenDevice(nil);
	RNRContext := alcCreateContext(RNRDevice,nil);
	alcMakeContextCurrent(RNRContext);
	RNRKolSounds:=0;
	SetLength(RNRBuffer,0);
	SetLength(RNRSource,0);
	SetLength(RNRSourcePos,0);
	SetLength(RNRSourceVel,0);
	RNRListenerImport(GlSanKoorImport(0,0,0),GlSanKoorImport(0,0,0),GlSanKoorImport(0,0,-1),GlSanKoorImport(0,1,0))

end;

procedure RNRImportAudio(Name:string;looping:boolean);
var
	format: TALenum;
	data: TALvoid;
	size: TALsizei;
	freq: TALsizei;
	loop: TALint;
	i,ii:longint;
	bool:boolean = false;
begin
	SetLength(RNRBuffer,Length(RNRBuffer)+1);
	SetLength(RNRSource,Length(RNRSource)+1);
	SetLength(RNRNames,Length(RNRNames)+1);
	RNRNames[High(RNRNames)].StName:=Name;
	for i:=1 to Length(Name) do
		if Name[i]='\' then
			bool:=true;
	if bool then
		begin
		ii:=-1;
		for i:=1 to Length(Name) do
			if Name[i]='\' then
				ii:=i;
		if ii=-1 then
			RNRNames[High(RNRNames)].Name:=GlSanCopy(Name,1,Length(Name)-4)
		else
			begin
			RNRNames[High(RNRNames)].Name:=GlSanCopy(Name,ii+1,Length(Name)-4)
			end;
		end
	else
		RNRNames[High(RNRNames)].Name:=GlSanCopy(Name,1,Length(Name)-4);
	SetLength(RNRSourcePos,Length(RNRSourcePos)+1);
	SetLength(RNRSourceVel,Length(RNRSourceVel)+1);
	alGenBuffers(1, @RNRBuffer[High(RNRBuffer)]);
	alutLoadWAVFile(Name,format,data,size,freq,loop);
	alBufferData(RNRBuffer[High(RNRBuffer)],format,data,size,freq);
	alutUnloadWAV(format,data,size,freq);
	alGenSources(1,@RNRSource[High(RNRSource)]);
	RNRSourceImport(High(RNRSource),GlSanKoorImport(0,0,0),GlSanKoorImport(0,0,0),looping);
end;

procedure RNRPlayAudio(n:longint);
begin
	alSourcePlay(RNRSource[n-1]);
end;

procedure RNRClearExit;
begin
	alcMakeContextCurrent(nil);
	alcDestroyContext(RNRContext);
	alcCloseDevice(RNRDevice);
end;

function GlSanPrinCub(const kc,km:GlSanKoor;const r:real):boolean;
begin
if ((kc.x-r-GlSanMin*2<km.x) and (kc.x+r+GlSanMin*2>km.x)) and
	((kc.y-r-GlSanMin*2<km.y) and (kc.y+r+GlSanMin*2>km.y)) and
	((kc.z-r-GlSanMin*2<km.z) and (kc.z+r+GlSanMin*2>km.z))
	then
	GlSanPrinCub:=true
else
	GlSanPrinCub:=false;
end;

procedure GlSanWndSetLastButtonColor(const p:pointer;const l:longint; const c:GlSanColor4f);
var
	W:PPGlSanWnd;
begin
w:=p;
if ((p<>nil) and (w^<>nil)) and (Length(w^^.ArButtons)>0) then
	begin
	w^^.ArButtons[High(w^^.ArButtons)].Chv[l]:=c;
	end;
end;

procedure GlSanColor4f.ClearColor;
begin
glclearcolor(a,b,c,d);
end;

procedure GlSanKoor.ClearColor;
begin
glclearcolor(x,y,z,1);
end;

procedure GlSanWndButtonHintAdd(const p:pointer;N:longint;s:string);
var W:GlSanUUWnd;
begin
	w:=p;
	if ((p<>nil) and (w^<>nil)) then
		begin
		if n-1 in [Low(w^^.ArButtons)..High(w^^.ArButtons)] then
			w^^.ArButtons[n-1].Hint.Add(s);
		end;
end;

procedure GlSanWndHint.Add(s:string);
begin
SetLength(STR,Length(STR)+1);
STR[High(STR)]:=s;
if GlSanTextLength(s,HintZum)>MaxLength then
	MaxLength:=GlSanTextLength(s,HintZum);
end;

procedure GlSanWndHint.Clear;
begin
SetLength(STR,0);
MaxLength:=0;
end;

procedure GlSanCircle(const k:GlSanKoor;const l:longint;const r:real);
begin
glPushMatrix;
gltranslatef(k.x,k.y,k.z);
San.GlSanCircle(l,r);
glPopmatrix;
end;
procedure GlSanKoor.Zum(ax,ay:real);
begin
x*=ax;
y*=ay;
end;

procedure GlSanWndSetButtonOnClick(const p:pointer; const l:longint; const b:boolean);
var
	w:PPGlSanWnd;
begin
w:=p;
if ((p<>nil) and (w^<>nil)) then
	begin
	if l-1 in [Low(w^^.ArButtons)..High(w^^.ArButtons)] then
		begin
		w^^.ArButtons[l-1].SetOnOn:=b;
		end;
	end;
end;

procedure CubObj3(var O:GlSanObj3);
procedure SetLengths;
begin O.Dispose;
SetLength(O.V,8);SetLength(O.F,6);SetLength(O.F[0],4);SetLength(O.F[1],4);
SetLength(O.F[2],4);SetLength(O.F[3],4);SetLength(O.F[4],4);SetLength(O.F[5],4);
end;begin SetLengths;
O.V[0].Import(1.000000,1.000000,-1.000000);O.V[1].Import(1.000000,-1.000000,-1.000000);
O.V[2].Import(-1.000000,-1.000000,-1.000000);O.V[3].Import(-1.000000,1.000000,-1.000000);
O.V[4].Import(1.000000,1,1.000000);O.V[5].Import(1,-1.000000,1.000000);
O.V[6].Import(-1.000000,-1.000000,1.000000);O.V[7].Import(-1.000000,1.000000,1.000000);
O.F[0,0]:=3;O.F[0,1]:=2;O.F[0,2]:=1;O.F[0,3]:=0;
O.F[1,0]:=5;O.F[1,1]:=6;O.F[1,2]:=7;O.F[1,3]:=4;
O.F[2,0]:=1;O.F[2,1]:=5;O.F[2,2]:=4;O.F[2,3]:=0;
O.F[3,0]:=2;O.F[3,1]:=6;O.F[3,2]:=5;O.F[3,3]:=1;
O.F[4,0]:=3;O.F[4,1]:=7;O.F[4,2]:=6;O.F[4,3]:=2;
O.F[5,0]:=7;O.F[5,1]:=3;O.F[5,2]:=0;O.F[5,3]:=4;
end;

procedure GlSanWndFindKoorOfCheckBox(const p:pointer;const l:longint; var bvl,bnp:GlSanKoor);
var
	w:GlSanUWnd;
	razn:GlSanKoor2f;
begin
w:=p;
if (P<>nil) then
	begin
	Razn.Import(abs(w^.tvl.x-w^.tnp.x),abs(w^.tvl.y-w^.tnp.y));
	bvl.Import(w^.tvl.x+razn.x*w^.ArCheckBox[l].OVL.x,w^.tvl.y-razn.y*w^.ArCheckBox[l].ovl.y,w^.tvl.z);
	bnp.Import(w^.tvl.x+razn.x*w^.ArCheckBox[l].onp.x,w^.tvl.y-razn.y*w^.ArCheckBox[l].onp.y,w^.tnp.z);
	end;
end;

function GlSanWndGetCaptionFromCheckBox(const p:pointer;const l:longint):boolean;
var
	w:PPGlSanWnd;
begin
w:=p;
GlSanWndGetCaptionFromCheckBox:=false;
if ((P<>nil) and (w^<>nil)) then
	begin
	if l-1 in [Low(w^^.ArCheckBox)..High(w^^.ArCheckBox)] then
		begin
		GlSanWndGetCaptionFromCheckBox:=w^^.ArCheckBox[l-1].Caption;
		end;
	end;
end;

procedure GlSanWndNewCheckBox(const p:pointer; const a,b:GlSanKoor2f;const bo:boolean);
var
	w:GlSanUUWnd;
begin
w:=p;
if ((p<>nil) and (w^<>nil)) then
	begin
	SetLength(w^^.ArCheckBox,Length(w^^.ArCheckBox)+1);
	w^^.ArCheckBox[High(w^^.ArCheckBox)].OVL.Import(a.x/w^^.WndW,a.y/w^^.WndH);
	w^^.ArCheckBox[High(w^^.ArCheckBox)].ONP.Import(b.x/w^^.WndW,b.y/w^^.WndH);
	w^^.ArCheckBox[High(w^^.ArCheckBox)].Caption:=bo;
	end;
end;

procedure GlSanWndCheckBox.Init(const vl,np:GlSanKoor;const Verh:boolean;  const _:real);
var
	razn:GlSanKoor2f;
	bvl,bnp:GlSanKoor;
begin
Razn.Import(abs(vl.x-np.x),abs(vl.y-np.y));
bvl.Import(vl.x+razn.x*OVL.x,vl.y-razn.y*ovl.y,vl.z);
bnp.Import(vl.x+razn.x*onp.x,vl.y-razn.y*onp.y,np.z);
if (ActiveSkin=-1) or (ArSkins[ActiveSkin].CheckBoxTexture1=-1)or (ArSkins[ActiveSkin].CheckBoxTexture3=-1) then
	begin
	glcolor4f(0,0.6,0,0.6*_);
	GlSanRoundQuad(bvl,bnp,GlSanRast(bvl,bnp)/50,2);
	glcolor4f(1,1,1,0.6*_);
	GlSanRoundQuadLines(bvl,bnp,GlSanRast(bvl,bnp)/50,2);
	if Caption then
		begin
		glcolor4f(1,0,0,0.6*_);
		GlSanLine(bvl,bnp);
		GlSanLine(GlSanKoorImport(bvl.x,bnp.y,bvl.z),GlSanKoorImport(bnp.x,bvl.y,bnp.z));
		end;
	end
else
	begin
	glcolor4f(1,1,1,0.9*_);
	if Caption then
		begin
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D,ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].CheckBoxTexture1]);
		if Length(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)>0 then
			WndSomeQuad(bvl,bnp,
				ArSkins[ActiveSkin].ArCheckBoxKoorTextures[Low(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)][1],
				ArSkins[ActiveSkin].ArCheckBoxKoorTextures[Low(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)][2]
				)
		else
			WndSomeQuad(bvl,bnp);
		glDisable(GL_TEXTURE_2D);
		end
	else
		begin
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D,ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].CheckBoxTexture3]);
		if Length(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)>2 then
			WndSomeQuad(bvl,bnp,
				ArSkins[ActiveSkin].ArCheckBoxKoorTextures[Low(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)+2][1],
				ArSkins[ActiveSkin].ArCheckBoxKoorTextures[Low(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)+2][2]
				)
		else
			WndSomeQuad(bvl,bnp);
		glDisable(GL_TEXTURE_2D);
		end;
	end;
end;
function GlSanPointOnPlosk(const P:GlSanKoor;const Pl:GlSanKoorPlosk):boolean;
var
	r:real;
begin
r:=Pl.a*P.x+Pl.b*P.y+Pl.c*P.z+Pl.d;
r:=abs(r);
if r<GlSanMin then
	GlSanPointOnPlosk:=true
else
	GlSanPointOnPlosk:=false;
end;

function GlSanKoorPlosk.PointOn(const P:GlSanKoor):boolean;
var
	r:real;
begin
r:=a*P.x+b*P.y+c*P.z+d;
r:=abs(r);
if r<GlSanWndMin then
	PointOn:=true
else
	PointOn:=false;
end;

procedure GlSanWndSetPositionOnComboBox(const p:pointer; const l,pl:longint);
var
	w:PPGlSanWnd;
begin
w:=p;
if ((p<>nil) and (w^<>nil)) then
	begin
	if l-1 in [Low(w^^.ArComboBox)..High(w^^.ArComboBox)] then
		begin
		w^^.ArComboBox[l-1].Position:=pl-1;
		end;
	end;
end;
function GlSanWndGetPositionFromComboBox(const p:pointer; const l:longint):longint;
var
	w:PPGlSanWnd;
begin
w:=p;
GlSanWndGetPositionFromComboBox:=0;
if ((p<>nil) and (w^<>nil)) then
	begin
	if l-1 in [Low(w^^.ArComboBox)..High(w^^.ArComboBox)] then
		begin
		GlSanWndGetPositionFromComboBox:=w^^.ArComboBox[l-1].Position+1;
		end;
	end;
end;

function GlSanRandomString:string;
var
	i:longint;
	l:longint;
begin
l:=random(250)+2;
GlSanRandomString:='';
for i:=1 to l do
	GlSanRandomString+=chr(random(254)+1);
end;

procedure GlSanWndNewStringInComboBox(const p:pointer;const l:longint; const s:string);
var
	w:GlSanPPWnd;
begin
w:=p;
if ((p<>nil) and (w^<>nil)) then
	begin
	if l-1 in [Low(w^^.ArComboBox)..High(w^^.ArComboBox)] then
		begin
		SetLength(w^^.ArComboBox[l-1].Text,Length(w^^.ArComboBox[l-1].Text)+1);
		w^^.ArComboBox[l-1].Text[High(w^^.ArComboBox[l-1].Text)]:=s;
		end;
	end;
end;

function GlSanRazrOfFile(const s:string):string;
var
	i:longint;
	b:boolean = false;
	s2:string;
begin
for i:=1 to Length(s) do
	if s[i]='.' then b:=true;
if b then
	begin
	i:=length(s)+1;
	GlSanRazrOfFile:='';
	repeat
	i-=1;
	if s[i]<>'.' then
		GlSanRazrOfFile+=s[i];
	until s[i]='.';
	GlSanRazrOfFile:=GlSanUpCaseString(GlSanRazrOfFile);
	s2:=GlSanRazrOfFile;
	for i:=length(s2) downto 1 do
		GlSanRazrOfFile[length(s2)-i+1]:=s2[i];
	end
else
	GlSanRazrOfFile:='';
end;

function GlSanUpCaseString(s:string):string;
var
	i:longint;
begin
for i:=1 to Length(s) do
	s[i]:=UpCase(s[i]);
GlSanUpCaseString:=s;
end;

function GlSanIDKat(const l:longint):boolean;
begin
if l in [$10] then
	GlSanIDKat:=true
else
	GlSanIDKat:=false;
end;

procedure GlSanWndComboBox.InitC(Const vl,np:GlSanKoor;const _:real;const l:longint; const cb,cr,ct,cc:GlSanColor4f);
var
	bns,bvs:GlSanKoor;
	razn:GlSanKoor2f;
	Sh:real;
begin
Razn.Import(abs(vl.x-np.x),abs(vl.y-np.y));
bvl.Import(vl.x+razn.x*OVL.x,vl.y-razn.y*ovl.y,vl.z);
bnp.Import(vl.x+razn.x*onp.x,vl.y-razn.y*onp.y,np.z);
Sh:=GlSanMinimum(abs(bvl.y-bnp.y),abs(bvl.x-bnp.x))*0.45;
Bvs.Import(bnp.x-2.2*Sh,bvl.y,bvl.z);
Bns.Import(bnp.x-2.2*Sh,bnp.y,bvl.z);
cb.SanSetColorA(_*0.5);
GlSanRoundQuad(bvl,bnp,GetRadOkr(bvl,bnp,GlSanRast(bvl,bnp)/30),3);
cr.SanSetColorA(_*0.5);
GlSanRoundQuadLines(bvl,bnp,GetRadOkr(bvl,bnp,GlSanRast(bvl,bnp)/30),3);
ct.SanSetColorA(_);
GlSanRoundQuad(bvs,bnp,GetRadOkr(bvl,bnp,GlSanRast(bvl,bnp)/30),4);
cc.SanSetColorA(_);
GlSanRoundQuadLines(bvs,bnp,GetRadOkr(bvl,bnp,GlSanRast(bvl,bnp)/30),4);
end;

procedure GlSanWndFindKoorOfComboBox(const p:pointer;const l:longint; var bvl,bnp:GlSanKoor);
var
	w:GlSanUWnd;
	razn:GlSanKoor2f;
begin
w:=p;
if (P<>nil) then
	begin
	Razn.Import(abs(w^.tvl.x-w^.tnp.x),abs(w^.tvl.y-w^.tnp.y));
	bvl.Import(w^.tvl.x+razn.x*w^.ArComboBox[l].OVL.x,w^.tvl.y-razn.y*w^.ArComboBox[l].ovl.y,w^.tvl.z);
	bnp.Import(w^.tvl.x+razn.x*w^.ArComboBox[l].onp.x,w^.tvl.y-razn.y*w^.ArComboBox[l].onp.y,w^.tnp.z);
	end;
end;

procedure GlSanWndNewComboBox(const p:pointer; const a,b:GlSanKoor2f);
var
	w:GlSanUUWnd;
begin
w:=p;
if ((p<>nil) and (w^<>nil)) then
	begin
	SetLength(w^^.ArComboBox,Length(w^^.ArComboBox)+1);
	w^^.ArComboBox[High(w^^.ArComboBox)].OVL.Import(a.x/w^^.WndW,a.y/w^^.WndH);
	w^^.ArComboBox[High(w^^.ArComboBox)].ONP.Import(b.x/w^^.WndW,b.y/w^^.WndH);
	w^^.ArComboBox[High(w^^.ArComboBox)].Position:=-1;
	w^^.ArComboBox[High(w^^.ArComboBox)].Open:=false;
	w^^.ArComboBox[High(w^^.ArComboBox)].OpenProgress:=0;
	w^^.ArComboBox[High(w^^.ArComboBox)].IO:=0;
	end;
end;

procedure GlSanWndComboBox.Init(const vl,np:GlSanKoor; const Verh:boolean; const _:real);
var
	razn:GlSanKoor2f;
	Sh:real;
	bvs,bns:GlSanKoor;
	bnnpp,bvvll:GlSanKoor;
	i:longint;
	OpenProzr:real;
	Koor1,Koor2:GlSanKoor;
begin
Razn.Import(abs(vl.x-np.x),abs(vl.y-np.y));
bvl.Import(vl.x+razn.x*OVL.x,vl.y-razn.y*ovl.y,vl.z);
bnp.Import(vl.x+razn.x*onp.x,vl.y-razn.y*onp.y,np.z);
Sh:=GlSanMinimum(abs(bvl.y-bnp.y),abs(bvl.x-bnp.x))*0.45;
Bvs.Import(bnp.x-2.2*Sh,bvl.y,bvl.z);
Bns.Import(bnp.x-2.2*Sh,bnp.y,bvl.z);
if IO >= 9 then IO := 0 else IO += 0.2;
if Open then
	begin
	OpenProgress*=14;
	OpenProgress+=1;
	OpenProgress/=15;
	end
else
	begin
	OpenProgress*=14;
	OpenProgress+=1/Length(text);
	OpenProgress/=15;
	end;
if open then
	begin
	OpenProzr:=OpenProgress;
	end
else
	begin
	OpenProzr:=OpenProgress-1/Length(Text);
	if OpenProzr<=0 then OpenProzr:=0;
	end;
glcolor4f(1,1,1,0.6*_*(1-OpenProzr));
GlSanRoundQuadLines(bvl,bnp,GetRadOkr(bvl,bnp,GlSanRast(bvl,bnp)/30),4);
glcolor4f(0,1,0,0.15*_*(1-OpenProzr));
GlSanRoundQuad(bvl,bnp,GetRadOkr(bvl,bnp,GlSanRast(bvl,bnp)/30),4);
glcolor4f(1,1,1,0.6*_*(1-OpenProzr));
GlSanRoundQuadLines(bvs,bnp,GetRadOkr(bvl,bnp,GlSanRast(bvl,bnp)/30),4);
glcolor4f(0,1,0,0.12*_*(1-OpenProzr));
GlSanRoundQuad(bvs,bnp,GetRadOkr(bvl,bnp,GlSanRast(bvl,bnp)/30),4);
if Position>=0 then
	begin
	glcolor4f(1,1,1,0.7*_*(1-OpenProzr));
	GlSanOutText(bvl,bns,Text[Position],Sh);
	end;
if (ActiveSkin=-1) or (ArSkins[ActiveSkin].ComboBoxTexture5=-1) then
	begin
	glcolor4f(1,1,1,0.6*_*(1-OpenProzr));
	Koor1.Import(bvs.x+abs(bvs.x-bnp.x)/10,bvl.y-abs(bvl.y-bnp.y)*(IO/10),bnp.z);
	Koor2.Import(bnp.x-abs(bvs.x-bnp.x)/10,bvl.y-abs(bvl.y-bnp.y)*((IO+1)/10),bnp.z);
	GlSanRoundQuad(Koor1,Koor2,abs(koor1.y-koor2.y)/3,4);
	end
else
	begin
	ArSkins[ActiveSkin].ArComboBoxTextureColor[5].SanSetColorA(_*(1-OpenProzr));
	Koor1.Import(cos((IO/9)*2*pi)*(abs(bvs.x-bnp.x)/2),sin((IO/9)*2*pi)*(abs(bvs.x-bnp.x)/2),0);
	Koor2.Import(cos((IO/9)*2*pi+pi)*(abs(bvs.x-bnp.x)/2),sin((IO/9)*2*pi+pi)*(abs(bvs.x-bnp.x)/2),0);
	Koor1.Togever(GlSanSredKoor(bnp,bvs));
	Koor2.Togever(GlSanSredKoor(bnp,bvs));
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D,ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ComboBoxTexture5]);
	SomeQuad(
		Koor1,GlSanKoorImport(GlSanSredKoor(bnp,bvs).x+cos((IO/9)*2*pi+pi/2)*(abs(bvs.x-bnp.x)/2),GlSanSredKoor(bnp,bvs).y+sin((IO/9)*2*pi+pi/2)*(abs(bvs.x-bnp.x)/2),bnp.z),
		Koor2,GlSanKoorImport(GlSanSredKoor(bnp,bvs).x+cos((IO/9)*2*pi+3*pi/2)*(abs(bvs.x-bnp.x)/2),GlSanSredKoor(bnp,bvs).y+sin((IO/9)*2*pi+3*pi/2)*(abs(bvs.x-bnp.x)/2),bnp.z),
		GlSanKoor2fImport(1,1),
		GlSanKoor2fImport(0,0));
	glDisable(GL_TEXTURE_2D);
	end;
bnnp.Import(bnp.x,bvl.y-ABS(bvl.y-bnp.y)*Length(Text)*OpenProgress,bvl.z);
glcolor4f(1,1,1,0.9*_*OpenProzr);
GlSanRoundQuadLines(bvl,bnnp,GetRadOkr(bvl,bnp,GlSanRast(bvl,bnp)/30),4);
glcolor4f(1,1,1,0.7*_*OpenProzr);
GlSanRoundQuad(bvl,bnnp,GetRadOkr(bvl,bnp,GlSanRast(bvl,bnp)/30),4);
glcolor4f(0,0,0,0.7*_*OpenProzr);
if (Open) or (OpenProgress>=0.07) then
	for i:=Low(Text) to High(Text) do
		begin
		bnnpp.Import(bnp.x,bvl.y-ABS(bvl.y-bnp.y)*(i+1)*OpenProgress,bvl.z);
		bvvll.Import(bvl.x,bvl.y-ABS(bvl.y-bnp.y)*(i)*OpenProgress,bvl.z);
		GlSanOutText(bvvll,bnnpp,Text[i],Sh);
		if i=Position then
			begin
			glcolor4f(0,0,1,0.25*_*OpenProzr);
			GlSanRoundQuad(bvvll,bnnpp,GetRadOkr(bvl,bnp,GlSanRast(bvl,bnp)/30),4);
			glcolor4f(0,0,1,0.35*_*OpenProzr);
			GlSanRoundQuadLines(bvvll,bnnpp,GetRadOkr(bvl,bnp,GlSanRast(bvl,bnp)/30),4);
			glcolor4f(0,0,0,0.7*_*OpenProzr);
			end;
		end;
end;

procedure GlSanKillOKWnd(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	w:GlSanUWnd;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
if Length(UM^.ArPointer)>0 then
	begin
	w:=UM^.ArPointer[Low(UM^.ArPointer)];
	GlSanWndOldDependentWnd(@w,wnd);
	end;
GlSanKillWnd(@Wnd);
end;
procedure GlSanCreateOKWnd(Wnd:pointer;Zag:string;Text:string);
begin
GlSanCreateWnd(@NewWnd,Zag,glSanKoor2fImport(320,100));
SetLength(NewWnd^.UserMemory.ArPointer,1);
NewWnd^.UserMemory.ArPointer[Low(NewWnd^.UserMemory.ArPointer)]:=Wnd;
GlSanWndNewDependentWnd(@Wnd,NewWnd);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(5,45),GlSanKoor2fImport(315,65),Text);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(130,70),GlSanKoor2fImport(190,95),'ОK',@GlSanKillOKWnd);
GlSanWndDispose(@NewWnd);
end;
procedure GlSanKoor.ReadlnFromFile(p:pointer);
var
	f:^text;
begin
f:=p;
readln(f^,x,y,z);
end;

procedure GlSanObj3.ReadlnFromFile(p:pointer);
var
	fa:^text;
	lv,lf,i,ii:longint;
begin
fa:=p;
readln(fa^);
readln(fa^,lv,lf);
SetLength(v,lv);
SetLength(f,lf);
for i:=Low(V) to High(v) do
	V[i].ReadlnFromFile(p);
for i:=Low(F) to High(f) do
	begin
	read(fa^,ii);
	SetLength(F[i],ii);
	for ii:=Low(F[i]) to High(F[i]) do
		read(fa^,f[i,ii]);
	readln(fa^);
	end;
end;
procedure GlSanKoorPlosk.ReadlnFromFile(p:pointer);
var
	f:^text;
begin
f:=p;
readln(f^,a,b,c,d);
end;

function GlSanWndGetListBoxActivePosition(const p:pointer; const l:longint):longint;
var
	w:GLSAnuuwnd;
begin
w:=p;
GlSanWndGetListBoxActivePosition:=-1;
if ((P<>nil) and (W^<>niL)) then
	begin
	if l-1 in [Low(w^^.ArListBox)..High(w^^.ArListBox)] then
		begin
		if w^^.ArListBox[l-1].MV then GlSanWndGetListBoxActivePosition:=w^^.ArListBox[l-1].MVPos;
		end;
	end;
end;
function TranslateCharFromFS(const c:char):char;
begin
if ord(c)in [1..127] then
	TranslateCharFromFS:=c
else
	begin
	case ord(c) of
	168:TranslateCharFromFS:='Ё';
	184:TranslateCharFromFS:='ё';
	192:TranslateCharFromFS:='А';
	193:TranslateCharFromFS:='Б';
	194:TranslateCharFromFS:='В';
	195:TranslateCharFromFS:='Г';
	196:TranslateCharFromFS:='Д';
	197:TranslateCharFromFS:='Е';
	198:TranslateCharFromFS:='Ж';
	199:TranslateCharFromFS:='З';
	200:TranslateCharFromFS:='И';
	201:TranslateCharFromFS:='Й';
	202:TranslateCharFromFS:='К';
	203:TranslateCharFromFS:='Л';
	204:TranslateCharFromFS:='М';
	205:TranslateCharFromFS:='Н';
	206:TranslateCharFromFS:='О';
	207:TranslateCharFromFS:='П';
	208:TranslateCharFromFS:='Р';
	209:TranslateCharFromFS:='С';
	210:TranslateCharFromFS:='Т';
	211:TranslateCharFromFS:='У';
	212:TranslateCharFromFS:='Ф';
	213:TranslateCharFromFS:='Х';
	214:TranslateCharFromFS:='Ц';
	215:TranslateCharFromFS:='Ч';
	216:TranslateCharFromFS:='Ш';
	217:TranslateCharFromFS:='Щ';
	218:TranslateCharFromFS:='Ъ';
	219:TranslateCharFromFS:='Ы';
	220:TranslateCharFromFS:='Ь';
	221:TranslateCharFromFS:='Э';
	222:TranslateCharFromFS:='Ю';
	223:TranslateCharFromFS:='Я';
	224:TranslateCharFromFS:='а';
	225:TranslateCharFromFS:='б';
	226:TranslateCharFromFS:='в';
	227:TranslateCharFromFS:='г';
	228:TranslateCharFromFS:='д';
	229:TranslateCharFromFS:='е';
	230:TranslateCharFromFS:='ж';
	231:TranslateCharFromFS:='з';
	232:TranslateCharFromFS:='и';
	233:TranslateCharFromFS:='й';
	234:TranslateCharFromFS:='к';
	235:TranslateCharFromFS:='л';
	236:TranslateCharFromFS:='м';
	237:TranslateCharFromFS:='н';
	238:TranslateCharFromFS:='о';
	239:TranslateCharFromFS:='п';
	240:TranslateCharFromFS:='р';
	241:TranslateCharFromFS:='c';
	242:TranslateCharFromFS:='т';
	243:TranslateCharFromFS:='у';
	244:TranslateCharFromFS:='ф';
	245:TranslateCharFromFS:='х';
	246:TranslateCharFromFS:='ц';
	247:TranslateCharFromFS:='ч';
	248:TranslateCharFromFS:='ш';
	249:TranslateCharFromFS:='щ';
	250:TranslateCharFromFS:='ъ';
	251:TranslateCharFromFS:='ы';
	252:TranslateCharFromFS:='ь';
	253:TranslateCharFromFS:='э';
	254:TranslateCharFromFS:='ю';
	255:TranslateCharFromFS:='я';
	else TranslateCharFromFS:=c;
	end;
	end;
end;
function TranslateStringFromFS(s:string):string;
var
	i:longint;
begin
for i:=1 to Length(s) do
	s[i]:=TranslateCharFromFS(s[i]);
TranslateStringFromFS:=s;
end;
procedure GlSanWndSetNewCaptoinInEdit(const p:pointer;const l:longint; const s:string);
var
	w:GlSanUUWnd;
begin
w:=p;
if ((p<>nil) and (w^<>nil)) then
	begin
	if l-1 in [Low(w^^.ArEdit)..High(w^^.ArEdit)] then
		begin
		w^^.ArEdit[l-1].Caption:=s;
		end;
	end;
end;
function GlSanWndGetCaptionFromEdit(const P:pointer;const l:longint):string;
var
	w:GlSanUUWnd;
begin
w:=p;
GlSanWndGetCaptionFromEdit:='';
if ((p<>nil) and (w^<>nil)) then
	begin
	if l-1 in [Low(w^^.ArEdit)..High(w^^.ArEdit)] then
		begin
		GlSanWndGetCaptionFromEdit:=w^^.ArEdit[l-1].Caption;
		end;
	end;
end;

procedure GlSanObj3.WritelnToFile(p:pointer);
var
	fail:^text;
	i,ii:longint;
begin
fail:=p;
writeln(fail^,'OFF');
writeln(fail^,Length(V),' ',Length(F),' ',0);
for i:=Low(V) to High(V) do
	V[i].WritelnToFile(p);
for i:=Low(F) to High(F) do
	begin
	write(fail^,Length(F[i]),' ');
	for ii:=Low(F[i]) to High(F[i]) do
		write(fail^,f[i,ii],' ');
	writeln(fail^);
	end;
end;
procedure GlSanKoor.WritelnToFile(p:pointer);
var
	f:^Text;
begin
f:=p;
writeln(f^,x:0:6,' ',y:0:6,' ',z:0:6,' ');
end;
procedure GlSanWndKillLoadFile(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	W:^GlSanWnd;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
W:=UM^.ArPointer[Low(UM^.ArPointer)+1];
if W<>nil then
	GlSanWndOldDependentWnd(@W,Wnd);
GlSanKillWnd(@Wnd);
end;
procedure ReRunLoadFile(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	s:string;
	sr:dos.SearchRec;
	i,ii,iii:longint;
	b:boolean = false;
function GR(const s:string):boolean;
var
	i:longint;
begin
GR:=false;
for i:=Low(UM^.Ar2String) to High(UM^.Ar2String) do
	if s=UM^.Ar2String[i] then GR:=true;
end;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
s:=UM^.String1;
s:=fexpand(s);
GlSanWndDeleteListBoxMVPos(@Wnd,1);
GlSanWndSetNewCaptoinInEdit(@Wnd,1,s);
UM^.String1:=s;
SetLength(UM^.ArString,0);
SetLength(UM^.ArLongint,0);
dos.findfirst(s+'*.*',$3F,sr);
While dos.DosError<>18 do
	begin
	if (sr.name <> '.') and (sr.name<>'..') and ((UM^.Ar2Longint[Low(UM^.Ar2Longint)]=1) or GlSanIDKat(sr.attr) or
				((UM^.Ar2Longint[Low(UM^.Ar2Longint)]=2) and (GR(GlSanRazrOfFile(sr.name))))) then
		begin
		SetLength(UM^.ArString,Length(UM^.ArString)+1);
		SetLength(UM^.ArLongint,Length(UM^.ArLongint)+1);
		UM^.ArString[High(UM^.ArString)]:=sr.name;
		UM^.ArLongint[High(UM^.ArLongint)]:=sr.attr;
		end;
	DOS.findnext(sr);
	end;
DOS.FindClose(sr);
GlSanWndClearListBox(@Wnd,1);
for i:=Low(UM^.ArString) to High(UM^.ArString) do
	begin
	for ii:=Low(UM^.ArString) to High(UM^.ArString)-1 do
		begin
		if (GlSanIDKat(UM^.ArLongint[ii+1])) and (not GlSanIDKat(UM^.ArLongint[ii])) or
			((UM^.ArString[ii][1] in ['a'..'z','а'..'п','р'..'я','ё']) and (UM^.ArString[ii+1][1] in ['A'..'Z','А'..'Я']) and
					(not (GlSanIDKat(UM^.ArLongint[ii]))))
			then
			begin
			s:=UM^.ArString[ii];
			iii:=UM^.ArLongint[ii];
			UM^.ArString[ii]:=UM^.ArString[ii+1];
			UM^.ArLongint[ii]:=UM^.ArLongint[ii+1];
			UM^.ArString[ii+1]:=s;
			UM^.ArLongint[ii+1]:=iii;
			end;
		end;
	end;
for i:=Low(UM^.ArString) to High(UM^.ArString) do
	begin
	b:=false;
	for ii:=Low(UM^.Ar2String) to High(UM^.Ar2String) do
		if GlSanRazrOfFile(UM^.ArString[i])=UM^.Ar2String[ii] then b:=true;
	if b then
		GlSanWndNewStringInLintBox(@Wnd,1,UM^.ArString[i],GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(0,1,0,1)))
	else
		if GlSanIDKat(UM^.ArLongint[i]) then
			GlSanWndNewStringInLintBox(@Wnd,1,UM^.ArString[i],GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(1,1,0,1)))
		else
			GlSanWndNewStringInLintBox(@Wnd,1,UM^.ArString[i],GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(1,1,1,1)));
	end;
end;
procedure SelectLoadFile(Wnd:pointer);
type
	LoadProc=function(Str:string;w2:pointer;b:boolean):boolean;
var
	UM:^GlSanWndUserMemory;
	W:^GlSanWnd;
	Proc1:LoadProc;
	iii,i:longint;
	b:boolean;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
W:=UM^.ArPointer[Low(UM^.ArPointer)+1];
if UM^.ArPointer[Low(UM^.ArPointer)]<>nil then
	begin
	Proc1:=LoadProc(UM^.ArPointer[Low(UM^.ArPointer)]);
	iii:=GlSanWndGetListBoxActivePosition(@wnd,1);
	if iii>0 then
		begin
		if not GlSanIDKat(UM^.ArLongint[iii-1]) then
			begin
			b:=false;
			for i:=Low(UM^.Ar2String) to high(UM^.Ar2String) do
				if GlSanRazrOfFile(UM^.ArString[iii-1])=UM^.Ar2String[i] then b:=true;
			if b then
				begin
				if Proc1(UM^.String1+UM^.ArString[iii-1],w,true) then
					begin
					if w<>nil then
						GlSanWndOldDependentWnd(@W,Wnd);
					GlSanKillWnd(@Wnd);
					end;
				end
			else
				begin
				GlSanCreateOKWnd(Wnd,'Ошибка!','Несоответствующий тип файла!');
				end;
			end
		else
			begin
			UM^.String1+=UM^.ArString[iii-1]+'\';
			ReRunLoadFile(wnd);
			end;
		end;
	end;
end;
procedure ProcLoadFile(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	f:file;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
if GlSanWndClickButton(@Wnd,3) or (GlSanWndActive(@wnd) and (GlSanReadKey=8)) then
	begin
	UM^.String1+='..\';
	ReRunLoadFile(wnd);
	exit;
	end;
if (GlSanWndActive(@wnd) and (GlSanReadKey=13)) then
	begin
	SelectLoadFile(wnd);
	end;
if GlSanWndGetPositionFromComboBox(@Wnd,1)<>UM^.Ar2Longint[Low(UM^.Ar2Longint)] then
	begin
	UM^.Ar2Longint[Low(UM^.Ar2Longint)]:=GlSanWndGetPositionFromComboBox(@Wnd,1);
	ReRunLoadFile(wnd);
	exit;
	end;
if GlSanWndClickButton(@Wnd,4) then
	begin
	if (GlSanWndGetListBoxActivePosition(@Wnd,1)>=1) and (not GlSanIDKat(UM^.ArLongint[GlSanWndGetListBoxActivePosition(@Wnd,1)-1])) then
		begin
		assign(f,UM^.String1+UM^.ArString[GlSanWndGetListBoxActivePosition(@Wnd,1)-1]);
		erase(f);
		ReRunLoadFile(wnd);
		exit;
		end;
	end;
end;
function GlSanWndRunLoadFile(const tittle:String;const pr,w:pointer;const pa:pointer):pointer;
type
	ArSL=array of string;
var
	UM:^GlSanWndUserMemory;
	PArSL:^ArSL;
	i:longint;
begin
PArSL:=pa;
GlSanCreateWnd(@NewWnd,'Загрузка '+tittle,glSanKoor2fImport(640,480));
GlSanWndRunLoadFile:=NewWnd;
UM:=GlSanWndGetPointerOfUserMemory(@NewWnd);
SetLength(UM^.ArPointer,2);
UM^.ArPointer[Low(UM^.ArPointer)+0]:=pr;
UM^.ArPointer[Low(UM^.ArPointer)+1]:=w;
UM^.String1:='';
SetLength(UM^.Ar2String,Length(PArSL^));
for i:=Low(UM^.Ar2String) to High(UM^.Ar2String) do
	UM^.Ar2String[i]:=GlSanUpCaseString(PArSL^[i]);
SetLength(UM^.Ar2Longint,1);
UM^.Ar2Longint[Low(UM^.Ar2Longint)]:=1;
if w<>nil then
	GlSanWndNewDependentWnd(@w,NewWnd);
GlSanWndSetProc(@NewWnd,@ProcLoadFile);
GlSanWndNewEdit(@NewWnd,GlSanKoor2fImport(20,45),GlSanKoor2fImport(620,75),'');
GlSanWndNewListBox(@NewWnd,GlSanKoor2fImport(20,80),GlSanKoor2fImport(620,435),GlSanKoor2fImport(20,30),true);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(550,440),GlSanKoor2fImport(620,475),'Закрыть',@GlSanWndKillLoadFile);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(475,440),GlSanKoor2fImport(545,475),'Выбрать',@SelectLoadFile);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(400,440),GlSanKoor2fImport(470,475),'Вверх',nil);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(325,440),GlSanKoor2fImport(395,475),'Удалить',nil);
GlSanWndNewComboBox(@NewWnd,GlSanKoor2fImport(20,440),GlSanKoor2fImport(320,475));
GlSanWndNewStringInComboBox(@NewWnd,1,'Показывать все файлы');
GlSanWndNewStringInComboBox(@NewWnd,1,'Показывать нужные файлы');
GlSanWndSetPositionOnComboBox(@NewWnd,1,2);
ReRunLoadFile(NewWnd);
GlSanWndDispose(@NewWnd);
end;
procedure GlSanKoorPlosk.Color;
begin
glcolor4f(a,b,c,d);
end;

procedure GlSanKoorPlosk.SetColor;
begin
glcolor4f(a,b,c,d);
end;

function GlSanWndActive(const w:PPGlSanWnd):boolean;
begin
if (Length(GlSanWinds)>0)and (w<>nil) and (w^<>nil) then
	GlSanWndActive:=w^=GlSanWinds[High(GlSanWinds)];
end;
function GlSanPrinTreug(t1,t2,t3:GlSanKoor;curkoor:glSanKoor):boolean;
var
	P1,p2:real;
begin
p1:=0;p2:=0;
P1+=GlSanTreugPlosh(t1,t2,t3);
p2+=GlSanTreugPlosh(t1,t2,curkoor);
p2+=GlSanTreugPlosh(t2,t3,curkoor);
p2+=GlSanTreugPlosh(t3,t1,curkoor);
if abs(p1-p2)<GlSanMin then
	GlSanPrinTreug:=true
else
	GlSanPrinTreug:=false;
end;

function GlSanPrinQuad(t1,t2,t3,t4:GlSanKoor;curkoor:glSanKoor):boolean;
var
	P1,p2:real;
begin
p1:=0;p2:=0;
P1+=GlSanTreugPlosh(t1,t2,t3);
p1+=GlSanTreugPlosh(t3,t4,t1);
p2+=GlSanTreugPlosh(t1,t2,curkoor);
p2+=GlSanTreugPlosh(t2,t3,curkoor);
p2+=GlSanTreugPlosh(t3,t4,curkoor);
p2+=GlSanTreugPlosh(t4,t1,curkoor);
if abs(p1-p2)<GlSanMin then
	GlSanPrinQuad:=true
else
	GlSanPrinQuad:=false;
end;


function GlSanLoadStringFromResource(const l:longint):string;
var
	s:string;
begin
{$IFDEF MSWINDOWS}
	LoadString(0,l,@s,255);
{$ELSE}
	s:='';
	{$ENDIF}
GlSanLoadStringFromResource:=s;
end;

function GlSanWhatIsTheSimbolEN(const l:longint):string;
begin
GlSanWhatIsTheSimbolEN:='';
case l of
32:GlSanWhatIsTheSimbolEN:=' ';
48:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:=')' else GlSanWhatIsTheSimbolEN:='0';
49:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='!' else GlSanWhatIsTheSimbolEN:='1';
50:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='@' else GlSanWhatIsTheSimbolEN:='2';
51:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='#' else GlSanWhatIsTheSimbolEN:='3';
52:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='$' else GlSanWhatIsTheSimbolEN:='4';
53:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='%' else GlSanWhatIsTheSimbolEN:='5';
54:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='^' else GlSanWhatIsTheSimbolEN:='6';
55:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='&' else GlSanWhatIsTheSimbolEN:='7';
56:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='*' else GlSanWhatIsTheSimbolEN:='8';
57:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='(' else GlSanWhatIsTheSimbolEN:='9';
65:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='A' else GlSanWhatIsTheSimbolEN:='a';
66:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='B' else GlSanWhatIsTheSimbolEN:='b';
67:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='C' else GlSanWhatIsTheSimbolEN:='c';
68:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='D' else GlSanWhatIsTheSimbolEN:='d';
69:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='E' else GlSanWhatIsTheSimbolEN:='e';
70:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='F' else GlSanWhatIsTheSimbolEN:='f';
71:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='G' else GlSanWhatIsTheSimbolEN:='g';
72:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='H' else GlSanWhatIsTheSimbolEN:='h';
73:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='I' else GlSanWhatIsTheSimbolEN:='i';
74:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='G' else GlSanWhatIsTheSimbolEN:='g';
75:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='K' else GlSanWhatIsTheSimbolEN:='k';
76:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='L' else GlSanWhatIsTheSimbolEN:='l';
77:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='M' else GlSanWhatIsTheSimbolEN:='m';
78:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='N' else GlSanWhatIsTheSimbolEN:='n';
79:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='O' else GlSanWhatIsTheSimbolEN:='o';
80:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='P' else GlSanWhatIsTheSimbolEN:='p';
81:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='Q' else GlSanWhatIsTheSimbolEN:='q';
82:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='R' else GlSanWhatIsTheSimbolEN:='r';
83:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='S' else GlSanWhatIsTheSimbolEN:='s';
84:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='T' else GlSanWhatIsTheSimbolEN:='t';
85:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='U' else GlSanWhatIsTheSimbolEN:='u';
86:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='V' else GlSanWhatIsTheSimbolEN:='v';
87:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='W' else GlSanWhatIsTheSimbolEN:='w';
88:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='X' else GlSanWhatIsTheSimbolEN:='x';
89:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='Y' else GlSanWhatIsTheSimbolEN:='y';
90:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='Z' else GlSanWhatIsTheSimbolEN:='z';
186:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:=':' else GlSanWhatIsTheSimbolEN:=';';
187:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='+' else GlSanWhatIsTheSimbolEN:='=';
188:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='<' else GlSanWhatIsTheSimbolEN:=',';
189:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='_' else GlSanWhatIsTheSimbolEN:='-';
190:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='>' else GlSanWhatIsTheSimbolEN:='.';
191:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='?' else GlSanWhatIsTheSimbolEN:='/';
192:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='~' else GlSanWhatIsTheSimbolEN:='`';
219:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='{' else GlSanWhatIsTheSimbolEN:='[';
220:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='|' else GlSanWhatIsTheSimbolEN:='\';
221:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='}' else GlSanWhatIsTheSimbolEN:=']';
222:if GlSanDownKey(16) then GlSanWhatIsTheSimbolEN:='"' else GlSanWhatIsTheSimbolEN:='"';
end;
end;

function GlSanWhatIsTheSimbol(const l:longint):string;
begin
GlSanWhatIsTheSimbol:='';
{$IFDEF MSWINDOWS}
	if GlSanGetLanguage='EN' then
		begin
		GlSanWhatIsTheSimbol:=GlSanWhatIsTheSimbolEN(l);
		end
	else
		GlSanWhatIsTheSimbol:=GlSanWhatIsTheSimbolRU(l);
	end;
	function GlSanGetLanguage:String;
	var
		Layout:array [0..kl_namelength]of char;
	begin

	GetKeyboardLayoutname(Layout);
	if layout='00000409' then
		GlSanGetLanguage:='EN'
	else
		GlSanGetLanguage:='RU';
	{$ENDIF}
end;
procedure GlSanWndOldDependentWnd(const p:pointer;const w:pointer);
var
	w1:^GlSanUWnd;
	i,id:longint;
begin
w1:=p;
if ((P<>niL) and (w1^<>nil)) then
	begin
	id:=-1;
	for i:=Low(w1^^.ArDependentWnd) to High(w1^^.ArDependentWnd) do
		begin
		if w=w1^^.ArDependentWnd[i] then
			id:=i;
		end;
	if id<>-1 then
		begin
		for i:=id+1 to High(w1^^.ArDependentWnd) do
			w1^^.ArDependentWnd[i-1]:=w1^^.ArDependentWnd[i];
		SetLength(w1^^.ArDependentWnd,Length(w1^^.ArDependentWnd)-1);
		end;
	end;
end;

procedure GlSanWndNewDependentWnd(const p:pointer;const w:pointer);
var
	ww:GlSanUUWnd;
begin
ww:=p;
if ((P<>nil) and (Ww^<>nil)) then
	begin
	SetLength(ww^^.ArDependentWnd,Length(ww^^.ArDependentWnd)+1);
	ww^^.ArDependentWnd[High(ww^^.ArDependentWnd)]:=w;
	end;
end;

function GlSanWhatIsTheSimbolRU(const l:longint):string;
begin
GlSanWhatIsTheSimbolRU:='';
case l of
32:GlSanWhatIsTheSimbolRU:=' ';
48:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:=')' else GlSanWhatIsTheSimbolRU:='0';
49:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='!' else GlSanWhatIsTheSimbolRU:='1';
50:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='"' else GlSanWhatIsTheSimbolRU:='2';
51:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='№' else GlSanWhatIsTheSimbolRU:='3';
52:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:=';' else GlSanWhatIsTheSimbolRU:='4';
53:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='%' else GlSanWhatIsTheSimbolRU:='5';
54:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='^' else GlSanWhatIsTheSimbolRU:='6';
55:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='?' else GlSanWhatIsTheSimbolRU:='7';
56:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='*' else GlSanWhatIsTheSimbolRU:='8';
57:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='(' else GlSanWhatIsTheSimbolRU:='9';
65:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Ф' else GlSanWhatIsTheSimbolRU:='ф';
66:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='И' else GlSanWhatIsTheSimbolRU:='и';
67:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='С' else GlSanWhatIsTheSimbolRU:='с';
68:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='В' else GlSanWhatIsTheSimbolRU:='в';
69:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='У' else GlSanWhatIsTheSimbolRU:='у';
70:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='А' else GlSanWhatIsTheSimbolRU:='а';
71:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='П' else GlSanWhatIsTheSimbolRU:='п';
72:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Р' else GlSanWhatIsTheSimbolRU:='р';
73:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Ш' else GlSanWhatIsTheSimbolRU:='ш';
74:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='О' else GlSanWhatIsTheSimbolRU:='о';
75:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Л' else GlSanWhatIsTheSimbolRU:='л';
76:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Д' else GlSanWhatIsTheSimbolRU:='д';
77:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Ь' else GlSanWhatIsTheSimbolRU:='ь';
78:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Т' else GlSanWhatIsTheSimbolRU:='т';
79:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Щ' else GlSanWhatIsTheSimbolRU:='щ';
80:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='З' else GlSanWhatIsTheSimbolRU:='з';
81:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Й' else GlSanWhatIsTheSimbolRU:='й';
82:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='К' else GlSanWhatIsTheSimbolRU:='к';
83:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Ы' else GlSanWhatIsTheSimbolRU:='ы';
84:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Е' else GlSanWhatIsTheSimbolRU:='е';
85:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Г' else GlSanWhatIsTheSimbolRU:='г';
86:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='М' else GlSanWhatIsTheSimbolRU:='м';
87:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Ц' else GlSanWhatIsTheSimbolRU:='ц';
88:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Ч' else GlSanWhatIsTheSimbolRU:='ч';
89:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Н' else GlSanWhatIsTheSimbolRU:='н';
90:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Я' else GlSanWhatIsTheSimbolRU:='я';
186:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Ж' else GlSanWhatIsTheSimbolRU:='ж';
187:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='+' else GlSanWhatIsTheSimbolRU:='=';
188:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Б' else GlSanWhatIsTheSimbolRU:='б';
189:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='_' else GlSanWhatIsTheSimbolRU:='-';
190:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Ю' else GlSanWhatIsTheSimbolRU:='ю';
191:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:=',' else GlSanWhatIsTheSimbolRU:='.';
192:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Ё' else GlSanWhatIsTheSimbolRU:='ё';
219:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Х' else GlSanWhatIsTheSimbolRU:='х';
220:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='/' else GlSanWhatIsTheSimbolRU:='\';
221:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Ъ' else GlSanWhatIsTheSimbolRU:='ъ';
222:if GlSanDownKey(16) then GlSanWhatIsTheSimbolRU:='Э' else GlSanWhatIsTheSimbolRU:='э';
end;
end;

procedure GlSanOutTextCursor(Koor:GlSanKoor; const s:string; const r:GlSanKoor2f; const lll:longint);
var
	i:longint;
	ob:GlSanABCObj;
	sm:real;
	WO:word;
begin
if ActiveSkin<>-1 then
	r.Zum(0.87);
if ActiveFont=-1 then
	begin
	sm:=Koor.x;
	Koor.x:=Koor.y;
	Koor.y:=-sm;
	if ActiveSkin=-1 then
		sm:=2.05*r.y
	else
		sm:=2.35*r.y;
	IF Lll=0 THEN
		begin
		glpushmatrix;
		glrotatef(90,0,0,1);
		sm+=2.25*r.y;
		ob.Koll:=1;
		ob.l[1,1]:=1;
		ob.l[2,1]:=7;
		ob.Init(GlSanKoorImport(Koor.x,Koor.y-sm,Koor.z),r);
		glpopmatrix;
		end
	else
		for i:=1 to length(s) do
			begin
			ob:=GlSanLoadBykv(s[i]);
			glpushmatrix;
			glrotatef(90,0,0,1);
			if GlSanSmallABC(s[i]) then
				begin
				if ((i<>1) and (GlSanSmallABC(s[i-1])=false)) then
					sm+=1.95*r.y
				else
					sm+=1.6*r.y;
				end
			else
				begin
				if ((i<>1) and GlSanSmallABC(s[i-1])) then
					sm+=1.95*r.y
				else
					sm+=2.25*r.y;
				end;
			if i=lll then
				begin
				ob.Koll:=1;
				ob.l[1,1]:=3;
				ob.l[2,1]:=9;
				ob.Init(GlSanKoorImport(Koor.x,Koor.y-sm,Koor.z),r);
				end;
			glpopmatrix;
			end;
	end
else
	begin
	if ActiveSkin=-1 then
		sm:=2.05*r.y
	else
		sm:=2.65*r.y;
	if lll=0 then
		begin
		GlSanLine(
					GlSanKoorImport(Koor.x+sm,Koor.y+r.x,Koor.z),
					GlSanKoorImport(Koor.x+sm,Koor.y-r.x,Koor.z));
		end
	else
		begin
		WO:=ArFonts[ActiveFont].ArChar[ord(SravnChar)].Width;
		for i:=1 to Length(s) do
			begin
			if i = lll then
				begin
				GlSanLine(
					GlSanKoorImport(Koor.x+sm+2*r.y*(ArFonts[ActiveFont].ArChar[ord(s[i])].Width/wo),Koor.y+r.x,Koor.z),
					GlSanKoorImport(Koor.x+sm+2*r.y*(ArFonts[ActiveFont].ArChar[ord(s[i])].Width/wo),Koor.y-r.x,Koor.z));
				end
			else
				begin
				sm+=2*r.y*(ArFonts[ActiveFont].ArChar[ord(s[i])].Width/wo);
				end;
			end;
		end;
	end;
end;


procedure GlSanOutTextCursorS(Koor:GlSanKoor; const s :string; const r:GlSanKoor2f; const l:longint);
begin
GlSanOutTextCursor(GlSanKoorImport(-0.5*GlSanTextLength(s,r.y)+Koor.x-2*r.y,Koor.y,Koor.z),s,r,l);
end;

procedure GlSanOutTextCursor(const bvl:GlSanKoor;bnp:GlSanKoor;const Text:string; const R:real; const l:longint);
var
	Razn:GlSanKoor2f;
begin
Razn.x:=abs(bvl.y-bnp.y)*0.47;
if GlSanTextLength(Text,R)<=GlSanRast(bvl,GlSanKoorImport(bnp.x,bvl.y,bvl.z)) then
	begin
	Razn.y:=r;
	bnp.x:=(GlSanTextLength(Text,R)/GlSanRast(bvl,GlSanKoorImport(bnp.x,bvl.y,bvl.z))
				)*GlSanRast(bvl,GlSanKoorImport(bnp.x,bvl.y,bvl.z))+bvl.x;
	GlSanOutTextCursorS(GlSanSredKoor(bvl,bnp),Text,Razn,l);
	end
else
	begin
	Razn.y:=Razn.x*((GlSanRast(bvl,GlSanKoorImport(bnp.x,bvl.y,bnp.z))))/GlSanTextLength(Text,Razn.x);
	GlSanOutTextCursorS(GlSanSredKoor(bvl,bnp),Text,Razn,l);
	end;
end;

procedure GlSanWndFindKoorOfEdit(const p:pointer;const l:longint; var bvl,bnp:GlSanKoor);
var
	w:GlSanUWnd;
	razn:GlSanKoor2f;
begin
w:=p;
if (P<>nil) then
	begin
	Razn.Import(abs(w^.tvl.x-w^.tnp.x),abs(w^.tvl.y-w^.tnp.y));
	bvl.Import(w^.tvl.x+razn.x*w^.ArEdit[l].OVL.x,w^.tvl.y-razn.y*w^.ArEdit[l].ovl.y,w^.tvl.z);
	bnp.Import(w^.tvl.x+razn.x*w^.ArEdit[l].onp.x,w^.tvl.y-razn.y*w^.ArEdit[l].onp.y,w^.tnp.z);
	end;
end;

procedure GlSanWndEdit.InitC(Const vl,np:GlSanKoor;const _:real;const l:longint; const cb,cr,ct,cc:GlSanColor4f);
var
	bvl,bnp:GlSanKoor;
	razn:GlSanKoor2f;
begin
Razn.Import(abs(vl.x-np.x),abs(vl.y-np.y));
bvl.Import(vl.x+razn.x*OVL.x,vl.y-razn.y*ovl.y,vl.z);
bnp.Import(vl.x+razn.x*onp.x,vl.y-razn.y*onp.y,np.z);
cb.SanSetColorA(_);
GlSanRoundQuad(bvl,bnp,GlSanRast(bvl,bnp)/100,3);
cr.SanSetColorA(_);
GlSanRoundQuadLines(bvl,bnp,GlSanRast(bvl,bnp)/100,3);
ct.SanSetColorA(_);
GlSanOutText(bvl,bnp,Caption,GlSanMinimum(abs(bvl.y-bnp.y),abs(bvl.x-bnp.x))*0.45);
cc.SanSetColorA(_);
GlSanOutTextCursor(bvl,bnp,Caption,GlSanMinimum(abs(bvl.y-bnp.y),abs(bvl.x-bnp.x))*0.45,l);
end;

procedure GlSanWndNewEdit(const p:pointer;const a,b:GlSanKoor2f;const s:string);
var
	w:GlSanUUWnd;
begin
w:=p;
if ((p<>nil) and (w^<>nil)) then
	begin
	SetLength(w^^.ArEdit,Length(w^^.ArEdit)+1);
	w^^.ArEdit[High(w^^.ArEdit)].OVL.Import(a.x/w^^.WndW,a.y/w^^.WndH);
	w^^.ArEdit[High(w^^.ArEdit)].ONP.Import(b.x/w^^.WndW,b.y/w^^.WndH);
	w^^.ArEdit[High(w^^.ArEdit)].Caption:=s;
	end;
end;

procedure GlSanWndEdit.Init(const vl,np:GlSanKoor; const Verh:boolean; const _:real);
var
	bvl,bnp:GlSanKoor;
	razn:GlSanKoor2f;
begin
Razn.Import(abs(vl.x-np.x),abs(vl.y-np.y));
bvl.Import(vl.x+razn.x*OVL.x,vl.y-razn.y*ovl.y,vl.z);
bnp.Import(vl.x+razn.x*onp.x,vl.y-razn.y*onp.y,np.z);
glcolor4f(1,1,1,0.5*_);
GlSanRoundQuadLines(bvl,bnp,GlSanRast(bvl,bnp)/100,3);
GlSanOutText(bvl,bnp,Caption,GlSanMinimum(abs(bvl.y-bnp.y),abs(bvl.x-bnp.x))*0.45);
end;

procedure GlSanKoor.Vertex;
begin
glvertex3f(x,y,z);
end;

function  GlSanWndTranslentColor4fToColorText(color4f:GlSanColor4f):GlSanWndTextChv;
begin
GlSanWndTranslentColor4fToColorText[1]:=Color4f;
Color4f.Zum(0.8);
GlSanWndTranslentColor4fToColorText[2]:=Color4f;
end;
function GlSanKoorPlosk.Negative:GlSanKoorPlosk;
begin
Negative.a:=1-a;
Negative.b:=1-b;
Negative.c:=1-c;
//if d<0.5 then Negative.d:=1-d else Negative.d:=d;
Negative.d:=d;
end;

procedure GlSanWndSetNewColorOnProgressBar(CONST p:pointer; const l:longint; const c:GlSanColor4f);
var
	w:GlSanUUWnd;
begin
w:=p;
if ((P<>nil) and (w^<>nil)) then
	begin
	if l-1 in [Low(w^^.ArProgressBar)..High(w^^.ArProgressBar)] then
		begin
		w^^.ArProgressBar[l-1].Chv:=c;
		end;
	end;
end;

function GlSanWndGetPointerOfUserMemory(const p:pointer):pointer;
var
	w:GlSanUUWnd;
begin
w:=p;
if ((P<>nil) and (w^<>nil)) then
	begin
	GlSanWndGetPointerOfUserMemory:=@W^^.UserMemory;
	end;
end;
procedure ProcColorWnd(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
	ct:GlSanWndTextChv;
	color:GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
C:=UM^.ArPointer[Low(UM^.ArPointer)];
if c<>nil then
	begin
	c^:=UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
	GlSanWndSetProgressOnProgressBar(@Wnd,1,UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)].a);
	GlSanWndSetProgressOnProgressBar(@Wnd,2,UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)].b);
	GlSanWndSetProgressOnProgressBar(@Wnd,3,UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)].c);
	GlSanWndSetProgressOnProgressBar(@Wnd,4,UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)].d);
	GlSanWndSetNewColorOnProgressBar(@Wnd,1,GlSanColor4fImport(UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)].a,0,0,UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)].d));
	GlSanWndSetNewColorOnProgressBar(@Wnd,2,GlSanColor4fImport(0,UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)].b,0,UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)].d));
	GlSanWndSetNewColorOnProgressBar(@Wnd,3,GlSanColor4fImport(0,0,UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)].c,UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)].d));
	GlSanWndSetNewColorOnProgressBar(@Wnd,4,GlSanColor4fImport(1,1,1,UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)].d));
	GlSanWndSetNewColorOnProgressBar(@Wnd,8,UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)]);
	GlSanWndSetNewTittleText(@Wnd,1,'((R='+GlSanStrReal(UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)].a,3)+
									'),(G='+GlSanStrReal(UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)].b,3)+
									'),(B='+GlSanStrReal(UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)].c,3)+
									'),(A='+GlSanStrReal(UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)].d,3)+'))');
	color:=c^;ct[Low(ct)]:=Color.Negative;color.Zum(0.8);ct[Low(ct)+1]:=color.Negative;GlSanWndSetNewColorText(@Wnd,3,ct);
	end;
end;
procedure SelectColor(Wnd:pointer);
var
	c:^GlSanColor4f;
	UM:^GlSanWndUserMemory;
	w:^GlSanWnd;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=UM^.ArPointer[Low(UM^.ArPointer)];
c^:=UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
w:=UM^.ArPointer[Low(UM^.ArPointer)+1];
if w<>nil then GlSanWndOldDependentWnd(@w,wnd);
GlSankillWnd(@Wnd);
GlSanWndSetProc(@Wnd,nil);
end;
procedure CanselC(wnd:pointer);
var
	c:^GlSanColor4f;
	UM:^GlSanWndUserMemory;
	w:^GlSanWnd;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=UM^.ArPointer[Low(UM^.ArPointer)];
w:=UM^.ArPointer[Low(UM^.ArPointer)+1];
if w<>nil then GlSanWndOldDependentWnd(@w,wnd);
c^:=UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)+1];
GlSankillWnd(@Wnd);
GlSanWndSetProc(@Wnd,nil);
end;
procedure GlSanColorWndIncRed(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=@UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
if c^.a+0.005>1 then c^.a:=1 else c^.a+=0.005;
end;
procedure GlSanColorWndDecred(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=@UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
if c^.a-0.005<0 then c^.a:=0 else c^.a-=0.005;
end;
procedure GlSanColorWndIncGreen(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=@UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
if c^.b+0.005>1 then c^.b:=1 else c^.b+=0.005;
end;
procedure GlSanColorWndDecGreen(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=@UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
if c^.b-0.005<0 then c^.b:=0 else c^.b-=0.005;
end;
procedure GlSanColorWndIncBlue(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=@UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
if c^.c+0.005>1 then c^.c:=1 else c^.c+=0.005;
end;
procedure GlSanColorWndDecBlue(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=@UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
if c^.c-0.005<0 then c^.c:=0 else c^.c-=0.005;
end;
procedure GlSanColorWndIncAlpha(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=@UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
if c^.d+0.005>1 then c^.d:=1 else c^.d+=0.005;
end;
procedure GlSanColorWndDecAlpha(Wnd:pointer);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=@UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
if c^.d-0.005<0 then c^.d:=0 else c^.d-=0.005;
end;
procedure ColorCMWhite(Wnd:PGlSanWnd);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=@UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
c^.a:=1;
c^.b:=1;
c^.c:=1;
end;
procedure ColorCMRed(Wnd:PGlSanWnd);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=@UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
c^.a:=1;
c^.b:=0;
c^.c:=0;
end;
procedure ColorCMGreen(Wnd:PGlSanWnd);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=@UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
c^.a:=0;
c^.b:=1;
c^.c:=0;
end;
procedure ColorCMBlue(Wnd:PGlSanWnd);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=@UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
c^.a:=0;
c^.b:=0;
c^.c:=1;
end;
procedure ColorCMYellow(Wnd:PGlSanWnd);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=@UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
c^.a:=1;
c^.b:=1;
c^.c:=0;
end;
procedure ColorCMLB(Wnd:PGlSanWnd);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=@UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
c^.a:=0;
c^.b:=1;
c^.c:=1;
end;
procedure ColorCMLR(Wnd:PGlSanWnd);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=@UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
c^.a:=1;
c^.b:=0;
c^.c:=1;
end;
procedure ColorCM000(Wnd:PGlSanWnd);
var
	UM:^GlSanWndUserMemory;
	C:^GlSanColor4f;
begin
UM:=GlSanWndGetPointerOfUserMemory(@Wnd);
c:=@UM^.ArGlSanColor4f[Low(UM^.ArGlSanColor4f)];
c^.a:=0;
c^.b:=0;
c^.c:=0;
end;
procedure ColorEscho(Wnd:PGlSanWnd);
begin
GlSanContextMenuBeginning(NewContext);
GlSanContextMenuAddString(NewContext,'Белый',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@ColorCMWhite);
GlSanContextMenuAddString(NewContext,'Красный',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@ColorCMRed);
GlSanContextMenuAddString(NewContext,'Зелёный',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@ColorCMGreen);
GlSanContextMenuAddString(NewContext,'Синий',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@ColorCMBlue);
GlSanContextMenuAddString(NewContext,'Желтый',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@ColorCMYellow);
GlSanContextMenuAddString(NewContext,'Голубой',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@ColorCMLB);
GlSanContextMenuAddString(NewContext,'Розовый',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@ColorCMLR);
GlSanContextMenuAddString(NewContext,'Черный',GL_SAN_CONTEXT_ENABLED_PROCEDURE,@ColorCM000);
GlSanContextMenuMake(NewContext,@wnd,nil);
end;

function GlSanWndRunCOlorWnd4f(const p:pointer; const st:string;const wpr:pointer):pointer;
var
	i:longint;
	pb:GlSanKoor2f;
	c:^GlSanColor4f;
	ct:GlSanWndTextChv;
begin
pb.Import(100,-100);
GlSanCreateWnd(@NewWnd,'Выбор Цвета '+st,GlSanKoor2fImport(450,300));
GlSanWndSetProc(@NewWnd,@ProcColorWnd);
SetLength(NewWnd^.UserMemory.ArPointer,2);
NewWnd^.UserMemory.ArPointer[Low(NewWnd^.UserMemory.ArPointer)]:=p;
NewWnd^.UserMemory.ArPointer[Low(NewWnd^.UserMemory.ArPointer)+1]:=wpr;
if wpr<>nil then GlSanWndNewDependentWnd(@wpr,NewWnd);
SetLength(NewWnd^.UserMemory.ArGlSanColor4f,2);c:=p;
NewWnd^.UserMemory.ArGlSanColor4f[Low(NewWnd^.UserMemory.ArGlSanColor4f)]:=c^;
NewWnd^.UserMemory.ArGlSanColor4f[Low(NewWnd^.UserMemory.ArGlSanColor4f)+1]:=c^;
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(8,250),GlSanKoor2fImport(80,290),'Выбрать',@SelectColor);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(85,250),GlSanKoor2fImport(160,290),'Отмена',@CanselC);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(60+pb.x,150+pb.y),GlSanKoor2fImport(90+pb.x,190+pb.y),'-',@GlSanColorWndDecred);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(60+pb.x,200+pb.y),GlSanKoor2fImport(90+pb.x,240+pb.y),'-',@GlSanColorWndDecGreen);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(60+pb.x,250+pb.y),GlSanKoor2fImport(90+pb.x,290+pb.y),'-',@GlSanColorWnddecBlue);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(60+pb.x,300+pb.y),GlSanKoor2fImport(90+pb.x,340+pb.y),'-',@GlSanColorWndDecAlpha);
GlSanWndNewProgressBar(@NewWnd,GlSanKoor2fImport(100+pb.x,150+pb.y),GlSanKoor2fImport(190+pb.x,190+pb.y));
GlSanWndNewProgressBar(@NewWnd,GlSanKoor2fImport(100+pb.x,200+pb.y),GlSanKoor2fImport(190+pb.x,240+pb.y));
GlSanWndNewProgressBar(@NewWnd,GlSanKoor2fImport(100+pb.x,250+pb.y),GlSanKoor2fImport(190+pb.x,290+pb.y));
GlSanWndNewProgressBar(@NewWnd,GlSanKoor2fImport(100+pb.x,300+pb.y),GlSanKoor2fImport(190+pb.x,340+pb.y));
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(200+pb.x,150+pb.y),GlSanKoor2fImport(240+pb.x,190+pb.y),'+',@GlSanColorWndIncred);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(200+pb.x,200+pb.y),GlSanKoor2fImport(240+pb.x,240+pb.y),'+',@GlSanColorWndIncGreen);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(200+pb.x,250+pb.y),GlSanKoor2fImport(240+pb.x,290+pb.y),'+',@GlSanColorWndIncBlue);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(200+pb.x,300+pb.y),GlSanKoor2fImport(240+pb.x,340+pb.y),'+',@GlSanColorWndIncAlpha);
GlSanWndNewProgressBar(@NewWnd,GlSanKoor2fImport(8,45),GlSanKoor2fImport(142,140));
GlSanWndNewProgressBar(@NewWnd,GlSanKoor2fImport(8,45),GlSanKoor2fImport(142,140));
GlSanWndNewProgressBar(@NewWnd,GlSanKoor2fImport(8,150),GlSanKoor2fImport(142,242));
GlSanWndNewProgressBar(@NewWnd,GlSanKoor2fImport(8,150),GlSanKoor2fImport(142,242));
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(208,250),GlSanKoor2fImport(442,290),'');
GlSanWndSetProgressOnProgressBar(@NewWnd,5,1);GlSanWndSetProgressOnProgressBar(@NewWnd,6,1);
GlSanWndSetProgressOnProgressBar(@NewWnd,7,1);GlSanWndSetProgressOnProgressBar(@NewWnd,8,1);
GlSanWndSetNewColorOnProgressBar(@NewWnd,5,GlSanColor4fImport(0,0,0,1));
GlSanWndSetNewColorOnProgressBar(@NewWnd,6,c^);
GlSanWndSetNewColorOnProgressBar(@NewWnd,7,GlSanColor4fImport(0,0,0,1));
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(28,65),GlSanKoor2fImport(122,120),'До');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(28,170),GlSanKoor2fImport(122,222),'После');
ct[Low(ct)]:=c^.Negative;c^.Zum(0.8);ct[Low(ct)+1]:=c^.Negative;GlSanWndSetNewColorText(@NewWnd,2,ct);
for i:=2 to high(NewWnd^.ArButtons) do NewWnd^.ArButtons[i].SetOnOn:=true;
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(250+pb.x,150+pb.y),GlSanKoor2fImport(442,190+pb.y),'Красный');
GlSanWndSetNewColorText(@NewWnd,High(NewWnd^.ArText)+1,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(1,0,0,1)));
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(250+pb.x,200+pb.y),GlSanKoor2fImport(442,240+pb.y),'Зелёный');
GlSanWndSetNewColorText(@NewWnd,High(NewWnd^.ArText)+1,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(0,1,0,1)));
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(250+pb.x,250+pb.y),GlSanKoor2fImport(442,290+pb.y),'Синий');
GlSanWndSetNewColorText(@NewWnd,High(NewWnd^.ArText)+1,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(0,0,1,1)));
if random(2)= 0 then GlSanWndNewText(@NewWnd,GlSanKoor2fImport(250+pb.x,300+pb.y),GlSanKoor2fImport(442,340+pb.y),'Видимость')
else GlSanWndNewText(@NewWnd,GlSanKoor2fImport(250+pb.x,300+pb.y),GlSanKoor2fImport(442,340+pb.y),'Непрозрачность');
GlSanWndSetNewColorText(@NewWnd,High(NewWnd^.ArText)+1,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(1,1,1,1)));
GlSanWndRunCOlorWnd4f:=NewWnd;
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(165,250),GlSanKoor2fImport(200,290),'Ещё',@ColorEscho);
GlSanWndDispose(@NewWnd);
end;

procedure GlSanWndSetProgressOnProgressBar(const p:pointer; const l:longint; const r:real);
var
	w:GlSanUUWnd;
begin
w:=p;
if ((p<>nil) and (W^<>nil)) then
	begin
	if l-1 in [Low(w^^.ArProgressBar)..High(w^^.ArProgressBar)] then
		begin
		if r>1 then
			w^^.ArProgressBar[l-1].Progress:=1
		else
			w^^.ArProgressBar[l-1].Progress:=r;
		end;
	end;
end;

procedure GlSanWndNewProgressBar(const p:pointer; const a,b:GlSanKoor2f);
var
	W:GlSanUUWnd;
begin
w:=p;
if ((p<>nil) and (w^<>nil)) then
	begin
	SetLength(w^^.ArProgressBar,Length(w^^.ArProgressBar)+1);
	w^^.ArProgressBar[High(w^^.ArProgressBar)].OVL.Import(a.x/w^^.WndW,a.y/w^^.WndH);
	w^^.ArProgressBar[High(w^^.ArProgressBar)].ONP.Import(b.x/w^^.WndW,b.y/w^^.WndH);
	w^^.ArProgressBar[High(w^^.ArProgressBar)].Progress:=0;
	w^^.ArProgressBar[High(w^^.ArProgressBar)].Chv:=GlSanColor4fImport(0,0.7,0,0.7);
	end;
end;

procedure GlSanWndProgressBar.Init(const vl,np:GlSanKoor; const Verh:boolean; const _:real);
var
	bvl,bnp:GlSanKoor;
	razn:GlSanKoor2f;
	RadOkr:real;
	npp:GlSanKoor;
begin
Razn.Import(abs(vl.x-np.x),abs(vl.y-np.y));
bvl.Import(vl.x+razn.x*OVL.x,vl.y-razn.y*ovl.y,vl.z);
bnp.Import(vl.x+razn.x*onp.x,vl.y-razn.y*onp.y,np.z);
Npp.Import(bvl.x+abs(bvl.x-bnp.x)*Progress,bnp.y,bvl.z);
if abs(bvl.y-bnp.y)/4>(abs(bvl.x-npp.x)/2) then
	RadOkr:=abs(bvl.x-npp.x)/2
else
	RadOkr:=abs(bvl.y-bnp.y)/4;
glcolor4f(1,1,1,0.5*_);
GlSanRoundQuadLines(bvl,bnp,RadOkr,4);
GlSanRoundQuadLines(bvl,npp,RadOkr,4);
Chv.SanSetColorA(_);
GlSanRoundQuad(bvl,npp,RadOkr,4);
end;

procedure GlSanWndDispose(const p:pointer);
var
	Wnd:GlSanUUWnd;
begin
Wnd:=p;
if ((p<>nil) and (Wnd^<> nil )) then
	begin
	Wnd^^.WndUK:=nil;
	Wnd^:=nil;
	end;
end;

procedure GlSanWndSetProc(const p:pointer;const pr:pointer);
var
	W:GlSanUUWnd;
begin
w:=p;
if ((p<>nil) and (w^<>nil)) then
	begin
	w^^.Proc:=pr;
	end;
end;

function GlSanWndClickListBox(const p:pointer; const l:longint):boolean;
var
	w:GlSanUUWnd;
begin
w:=p;
GlSanWndClickListBox:=false;
if ((p<>nil) and (w^<>nil)) then
	begin
	if l-1 in [Low(w^^.ArListBox)..High(w^^.ArListBox)] then
		begin
		if w^^.ArListBox[l-1].MV then
			begin
			GlSanWndClickListBox:=w^^.ArListBox[l-1].Button;
			w^^.ArListBox[l-1].Button:=false;
			end;
		end;
	end;
end;

function GlSanRast(const a,b:GlSanKoor2f):real;
begin
GlSanRast:=sqrt(sqr(a.x-b.x)+sqr(a.y-b.y));
end;

procedure GlSanKoor2f.Togever(const k:GlSanKoor2f);
begin
x:=x+k.x;
y:=y+k.y;
end;

procedure GlSanKoor2f.Zum(const q:real);
begin
x:=x*q;
y:=y*q;
end;

function GlSanKolChisel(l:longint):longint;
begin
GlSanKolChisel:=0;
while l>0 do
	begin
	GlSanKolChisel+=1;
	l:=l div 10;
	end;
end;

function GSK2(const a:GlSanKoor):GlSanKoor2f;
begin
GSK2.y:=a.y;
GSK2.x:=a.x;
end;

procedure SanWndVsplitieNotExit;
var
	i:longint;
	b:boolean = false;
	Wnd:^GlSanWnd;
begin
if GlSanWndMove then GlSanWndMove:=false;
if GlSanWndListBoxMoveButton then GlSanWndListBoxMoveButton:=false;
i:=High(GlSanWinds);
repeat
Wnd:=GlSanWinds[i];
if not Wnd^.ExitP then
	begin
	b:=true;
	GlSanWinds[i]:=GlSanWinds[High(GlSanWinds)];
	GlSanWinds[High(GlSanWinds)]:=Wnd;
	end;
i:=i-1;
until b or (i<=Low(GlSanWinds)-1);
end;

procedure GlSanKillWnd(const p:pointer);
var
	w:^GlSanUWnd;
	a,b:GlSanKoor;
	I:longint;
	w1:^GLSANWND;
begin
w:=p;
if ((p<>nil) and (w^<>nil)) then
	begin
	for i:=Low(w^^.ArButtons) to High(w^^.ArButtons) do
		w^^.ArButtons[i].ProcB:=nil;
	w^^.ExitI:=0;
	w^^.Proc:=nil;
	w^^.ExitP:=true;
	w^^.WndUK:=nil;
	a:=w^^.OVL.GSK3;
	b:=w^^.ONP.GSK3;
	a.Togever(b);
	a.Zum(1/2);
	w^^.OVL:=GSK2(a);
	w^^.ONP:=GSK2(a);
	w^^.ONZP:=GSK2(a);
	for i:=Low(w^^.ArDependentWnd) to High(w^^.ArDependentWnd) do
		begin
		w1:=w^^.ArDependentWnd[i];
		if not w1^.ExitP then GlSanKillWnd(@w1);
		end;
	w^:=nil;
	SanWndVsplitieNotExit;
	end;
end;

procedure GlSanWndUserMemory.Dispose;
var
	i:longint;
begin
SetLength(ArLongint,0);
SetLength(Ar2Longint,0);
SetLength(ArPointer,0);
SetLength(ArString,0);
SetLength(ArGlSanColor4f,0);
for i:=Low(ArArLongint) to High(ArArLongint) do
	SetLength(ArArLongint[i],0);
SetLength(ArArLongint,0);
for i:=Low(ArGlSanObj3) to High(ArGlSanObj3) do
	ArGlSanObj3[i].Dispose;
SetLength(ArGlSanObj3,0);
SetLength(ArGlSanKoor,0);
SetLength(ArBoolean,0);
SetLength(ArReal,0);
SetLength(Ar2String,0);
SetLength(ArDPoint,0);
for i:=Low(ArDDPoint) to High(ArDDPoint) do
	ArDDPoint[i].Dispose;
SetLength(ArDDPoint,0);
SetLength(Ar2DPoint,0);
for i:=Low(ArArDPoint) to High(ArArDPoint) do
	SetLength(ArArDPoint[i],0);
SetLength(ArArDPoint,0);
GlSanObj31.Dispose;
Rot1:=0;
Rot2:=0;
Zum:=0;
Pointer1:=nil;
LZ:=0;
UZ:=0;
for i:=Low(ArGlSanFriend) to High(ArGlSanFriend) do
	ArGlSanFriend[i].Dispose;
SetLength(ArGlSanFriend,0);
end;
procedure GlSanWndKill(p:longint);
var
	i,iii,ii:longint;
	w:^GlSanWnd;
begin
{$NOTE GlSanWndKill}
if p in [Low(GlSanWinds)..High(GlSanWinds)] then
	begin
	w:=GlSanWinds[p];
	if Length(GlSanWinds)=1 then
		SetLength(GlSanWinds,0)
	else
		begin
		for i:=p+1 to High(GlSanWinds) do
			GlSanWinds[i-1]:=GlSanWinds[i];
		SetLength(GlSanWinds,Length(GlSanWinds)-1);
		end;
	{+++++++++}
	for i:=Low(w^.ArListBox) to High(w^.ArListBox)  do
		begin
		SetLength(w^.ArListBox[i].Text,0);
		SetLength(w^.ArListBox[i].TextChv,0);
		end;
	SetLength(w^.ArText,0);
	SetLength(w^.ArButtons,0);
	SetLength(w^.ArListBox,0);
	SetLength(w^.ArProgressBar,0);
	SetLength(w^.ArEdit,0);
	SetLength(w^.ArComboBox,0);
	SetLength(w^.ArCheckBox,0);
	for i:=Low(w^.ArBook) to High(w^.ArBook) do
		begin
		for ii:=Low(w^.ArBook[i].ArStrings) to High(w^.ArBook[i].ArStrings) do
			begin
			for iii:=Low(w^.ArBook[i].ArStrings[ii].ArMem) to High(w^.ArBook[i].ArStrings[ii].ArMem) do
				begin
				SetLength(w^.ArBook[i].ArStrings[ii].ArMem[iii].Mem,0);
				end;
			SetLength(w^.ArBook[i].ArStrings[ii].ArMem,0);
			end;
		SetLength(w^.ArBook[i].ArStrings,0);
		end;
	SetLength(w^.ArBook,0);
	SetLength(w^.ArImage,0);
	w^.UserMemory.Dispose;
	SetLength(W^.ArDependentWnd,0);
	{---------}
	Dispose(w);
	end;
end;

procedure GlSanCreateWnd(const p:pointer;const  s:ansistring; const k2f:GlSanKoor2f);stdcall;
var
	w:GlSanUUWnd;
	a,b:GlSanKoor2f;
	Wnd:^GlSanWnd;
begin
{$NOTE GlSanCreateWnd}
w:=p;
if w^=nil then
	begin
	a.Import((width/2)-k2f.x/2,(height/2)-k2f.y/2);
	b.Import((width/2)+k2f.x/2,(height/2)+k2f.y/2);
	Wnd:=GlSanCreateInSys;
	Wnd^.TittleSystem:='User';
	Wnd^.Tittle:=s;
	Wnd^.ProgramName:='Unknown Corporation & Program';
	Wnd^.Icon:=GSB_NILSTR;
	Wnd^.InfWorld:=GSB_INF_NOOTHING;
	Wnd^.ColorsF:=GlSanWndStandardColorsGl;
	Wnd^.ColorsS:=GlSanWndStandardColorsNGl;
	Wnd^.OVL.Import(a.x/width, a.y/height);
	Wnd^.ONP.Import(b.x/width, b.y/height);
	Wnd^.ONZP.Import(b.x/width,(a.y+40)/height);
	Wnd^.RadOkr:=0.01*GlSanMinimum(
		abs(GlSanWA[GlSanWAKol,1].y-GlSanWA[GlSanWAKol,3].y),
		abs(GlSanWA[GlSanWAKol,1].x-GlSanWA[GlSanWAKol,3].x));
	Wnd^.TVL.Import(0,0,0);
	Wnd^.TNP.Import(0,0,0);
	Wnd^.TNZP.Import(0,0,0);
	Wnd^.WndUK:=p;
	Wnd^.WndW:=round(k2f.x);
	Wnd^.WndH:=round(k2f.y);
	Wnd^.ZagP:=true;
	Wnd^.TeloP:=true;
	Wnd^.MTelo:=false;
	Wnd^.ExitP:=false;
	Wnd^.Proc:=nil;
	Wnd^.InitProc:=nil;
	Wnd^.ReOutThisProc:=false;
	SetLength(Wnd^.ArDependentWnd,0);
	Wnd^.UserMemory.Dispose;
	SetLength(Wnd^.ArText,0);
	SetLength(Wnd^.ArButtons,0);
	SetLength(Wnd^.ArListBox,0);
	SetLength(Wnd^.ArProgressBar,0);
	SetLength(Wnd^.ArEdit,0);
	SetLength(Wnd^.ArComboBox,0);
	SetLength(Wnd^.ArCheckBox,0);
	SetLength(Wnd^.ArBook,0);
	SetLength(Wnd^.ArImage,0);
	w^:=Wnd;
	end;
end;


procedure GlSanKoorPlosk.SanSetColor3f;
begin
glcolor3f(a,b,c);
end;

function GlSanLineCross(p1,p2,p3,p4:glSanKoor):glSanKoor;
var	e:glSanKoor;
	a1,a2,b1,b2,c1,c2:real;
	x1,x2,y1,y2:real;
	deter,deter1,deter2:real;
begin
x1:=p1.x;y1:=p1.y;
x2:=p2.x;y2:=p2.y;
a1:=(Y2-Y1)/(X2-X1);
b1:=1;
c1:=1*(y1-a1*x1);
x1:=p3.x;y1:=p3.y;
x2:=p4.x;y2:=p4.y;
a2:=(Y2-Y1)/(X2-X1);
b2:=1;
c2:=1*(y1-a2*x1);
deter:=a1*b2-a2*b1;
deter1:=c1*b2-c2*b1;
deter2:=a1*c2-a2*c1;
e.x:=ABS(deter1/deter); e.y:=abs(deter2/deter); e.z:=0;
GlSanLineCross:=e;
end;

procedure GlSanWndDeleteListBoxMVPos(const p:pointer;const l:longint);
var
	W:GlSanUUWnd;
begin
W:=p;
if ((p<>nil) and (w^<>nil)) then
	begin
	if ((l<1) or (l>Length(W^^.ArListBox))) then begin end else
		begin
		W^^.ArListBox[l-1].MVPos:=0;
		end;
	end;
end;

function GlSanWndGetListBoxMVPos(const p:pointer;const l:longint):string;
var
	W:GlSanUUWnd;
begin
W:=p;
GlSanWndGetListBoxMVPos:='';
if ((p<>nil) and (w^<>nil)) then
	begin
	if ((l<1) or (l>Length(W^^.ArListBox))or (W^^.ArListBox[l-1].MV=false) or (W^^.ArListBox[l-1].MVPos=0)) then
		begin

		end
	else
		begin
		GlSanWndGetListBoxMVPos:=W^^.ArListBox[l-1].Text[W^^.ArListBox[l-1].MVPos-1];
		end;
	end;
end;

function GlSanSRRF(const name:string;const a,b:string):boolean;
var
	razr,razr2:string;
	bo:boolean;
	i:longint;
begin
razr:='';
i:=Length(name);
bo:=false;
repeat
if name[i]='.' then
	bo:=true
else
	razr:=razr+name[i];
i:=i-1;
until bo or (i=0);
razr2:='';
for i:=Length(Razr) downto 1 do
	razr2:=razr2+razr[i];
razr:=razr2;
if Length(a)<>Length(Razr) then
	GlSanSRRF:=false
else
	begin
	bo:=true;
	for i:=1 to Length(Razr) do
		if Razr[i]=a[i] then
			begin
			end
		else
			if razr[i]=b[i] then
				begin
				end
			else
				bo:=false;
	GlSanSRRF:=bo;
	end;
end;

procedure GlSanWndNewStringInLintBox(const p:pointer; const l:longint; const s:string; const Chv:GlSanWndTextChv);
var
	WU:GlSanUUWnd;
	Wnd:^GlSanWnd;
begin
WU:=p;
if ((p<>nil) and (WU^<>nil)) then
	begin
	Wnd:=WU^;
	if (l>Length(Wnd^.ArListBox)) or (l<1) then exit;
	SetLength(Wnd^.ArListBox[l-1].Text,Length(Wnd^.ArListBox[l-1].Text)+1);
	SetLength(Wnd^.ArListBox[l-1].TextChv,Length(Wnd^.ArListBox[l-1].TextChv)+1);
	Wnd^.ArListBox[l-1].Text[High(Wnd^.ArListBox[l-1].Text)]:=s;
	Wnd^.ArListBox[l-1].TextChv[High(Wnd^.ArListBox[l-1].TextChv)]:=Chv;
	end;
end;

function GlSanPrinKoor(const a,b,c:GlSanKoor):boolean;
var
	pl1,pl2:real;
	t1,t2:GlSanKoor;
begin
t1:=GlSanKoorImport(a.x,b.y,a.z);
t2:=GlSanKoorImport(b.x,a.y,a.z);
Pl1:=GlSanRast(b,t1)*GlSanRast(b,t2);
Pl2:=GlSanTreugPlosh(a,c,t1)+GlSanTreugPlosh(b,c,t1)+
	GlSanTreugPlosh(a,c,t2)+GlSanTreugPlosh(b,c,t2);
if abs(Pl2-Pl1)<=GlSanWndMin then
	GlSanPrinKoor:=true
else
	GlSanPrinKoor:=false;
end;

procedure GlSanOutText(const bvl:GlSanKoor;bnp:GlSanKoor;const Text:string; const R:real);
var
	Razn:GlSanKoor2f;
begin
Razn.x:=abs(bvl.y-bnp.y)*0.47;
if GlSanTextLength(Text,R)<=GlSanRast(bvl,GlSanKoorImport(bnp.x,bvl.y,bvl.z)) then
	begin
	Razn.y:=r;
	bnp.x:=(GlSanTextLength(Text,R)/GlSanRast(bvl,GlSanKoorImport(bnp.x,bvl.y,bvl.z))
				)*GlSanRast(bvl,GlSanKoorImport(bnp.x,bvl.y,bvl.z))+bvl.x;
	GlSanOutTextS(GlSanSredKoor(bvl,bnp),Text,Razn);
	end
else
	begin
	Razn.y:=Razn.x*((GlSanRast(bvl,GlSanKoorImport(bnp.x,bvl.y,bnp.z))))/GlSanTextLength(Text,Razn.x);
	GlSanOutTextS(GlSanSredKoor(bvl,bnp),Text,Razn);
	end;
end;

function GlSanDownKey(const l:longint):boolean;
begin
GlSanDownKey:=SGKeysDown[l];
end;

function GlSanWndListBoxFindKB(const p:pointer;const l:longint;const vl,np:GlSanKoor):GlSanKoor;
var
	But:^GlSanWndButton;
	bvl,bnp:GlSanKoor;
	razn:GlSanKoor2f = (x:0; y:0);
	t2,t4:GlSanKoor;
begin
but:=p;
Razn.Import(abs(vl.x-np.x),abs(vl.y-np.y));
bvl.Import(vl.x+razn.x*But^.OVL.x,vl.y-razn.y*But^.ovl.y,vl.z);
bnp.Import(vl.x+razn.x*But^.onp.x,vl.y-razn.y*But^.onp.y,np.z);
T2.Import(bnp.x,bvl.y,bvl.z);
T4.Import(bvl.x,bnp.y,bnp.z);
case l of
1:GlSanWndListBoxFindKB:=bvl;
2:GlSanWndListBoxFindKB:=t2;
3:GlSanWndListBoxFindKB:=bnp;
4:GlSanWndListBoxFindKB:=t4;
else
	GlSanWndListBoxFindKB.Import(0,0,0);
end;
end;

procedure GlSanWndClearListBox(const p:pointer; const l:longint);
var
	Wnd:GlSanUUWnd;
begin
Wnd:=p;
if ((p<>nil) and (Wnd^<>nil)) then
	begin
	SetLength(Wnd^^.ArListBox[Low(Wnd^^.ArListBox)+l-1].Text,0);
	SetLength(Wnd^^.ArListBox[Low(Wnd^^.ArListBox)+l-1].TextChv,0);
	Wnd^^.ArListBox[Low(Wnd^^.ArListBox)+l-1].Position:=1;
	Wnd^^.ArListBox[Low(Wnd^^.ArListBox)+l-1].MVPos:=0;
	end;
end;

procedure GlSanWndListBoxFindKoor(const p:pointer;const li:longint;var bvl,bnp:GlSanKoor);
var
	Wnd:^GlSanWindow;
	Razn:GlSanKoor2f;
begin
Wnd:=p;
if ((p<>nil)) then
	begin
	Razn.Import(abs(Wnd^.tvl.x-Wnd^.tnp.x),abs(Wnd^.tvl.y-Wnd^.tnp.y));
	bvl.Import(Wnd^.tvl.x+razn.x*Wnd^.ArListBox[li].OVL.x,Wnd^.tvl.y-razn.y*Wnd^.ArListBox[li].ovl.y,Wnd^.tvl.z);
	bnp.Import(Wnd^.tvl.x+razn.x*Wnd^.ArListBox[li].onp.x,Wnd^.tvl.y-razn.y*Wnd^.ArListBox[li].onp.y,Wnd^.tnp.z);
	end;
end;

procedure GlSanWndNewStringInLintBox(const p:pointer; const l:longint; const s:string);
const
	Chv:GlSanWndTextChv = ((a:0.8;b:0.8;c:0.8;d:0.8),(a:0.45;b:0.45;c:0.45;d:0.45));
var
	WU:GlSanUUWnd;
	Wnd:^GlSanWnd;
begin
WU:=p;
if ((p<>nil) and (WU^<>nil)) then
	begin
	Wnd:=WU^;
	if (l>Length(Wnd^.ArListBox)) or (l<1) then exit;
	SetLength(Wnd^.ArListBox[l-1].Text,Length(Wnd^.ArListBox[l-1].Text)+1);
	SetLength(Wnd^.ArListBox[l-1].TextChv,Length(Wnd^.ArListBox[l-1].TextChv)+1);
	Wnd^.ArListBox[l-1].Text[High(Wnd^.ArListBox[l-1].Text)]:=s;
	Wnd^.ArListBox[l-1].TextChv[High(Wnd^.ArListBox[l-1].TextChv)]:=Chv;
	end;
end;

procedure GlSanWndListBox.Init(const vl,np:GlSanKoor; const Verh:boolean; const _:real);
const
	rt=0.8;
var
	bvl,bnp:GlSanKoor;
	razn:GlSanKoor2f;
	o1,o2,o:real;
	T1,T2,T3,t4,t5,tt1,tt2:GlSanKoor;
	i:longint;
begin
Razn.Import(abs(vl.x-np.x),abs(vl.y-np.y));
bvl.Import(vl.x+razn.x*OVL.x,vl.y-razn.y*ovl.y,vl.z);
bnp.Import(vl.x+razn.x*onp.x,vl.y-razn.y*onp.y,np.z);
RO:=(abs(bvl.y-bnp.y)/round(Shrift.x))/2;
RO2:=(abs(bvl.x-bnp.x)/round(Shrift.y))/2;
T1.Import(BNP.x-2*RO,BVL.y,BVL.z);
T2.Import(BNP.x,BVL.y-2*RO,BVL.z);
T3.Import(BNP.x-2*RO,BNP.y+2*RO,BVL.z);
T4.Import(BNP.x-2*RO,BVL.y-2*RO,BVL.z);
T5.Import(BNP.x,BNP.y+2*RO,BVL.z);
if PokQuad then
	begin
	glcolor4f(0,0.5,0,0.5*_);
	GlSanRoundQuad(BVL,BNP,RO,4);
	glcolor4f(0.7,0.7,0.7,1*_);
	GlSanRoundQuadLines(BVL,BNP,RO,4);
	end;
GlSanRoundQuadLines(T1,BNP,RO,4);
ArButtons[Low(ArButtons)].OVL.Import(abs(bvl.x-t1.x)/abs(bvl.x-bnp.x),abs(bvl.y-t1.y)/abs(bvl.y-bnp.y));
ArButtons[Low(ArButtons)].ONP.Import(abs(bvl.x-t2.x)/abs(bvl.x-bnp.x),abs(bvl.y-t2.y)/abs(bvl.y-bnp.y));
ArButtons[High(ArButtons)-1].OVL.Import(abs(bvl.x-t3.x)/abs(bvl.x-bnp.x),abs(bvl.y-t3.y)/abs(bvl.y-bnp.y));
ArButtons[High(ArButtons)-1].ONP.Import(1,1);
ArButtons[Low(ArButtons)].RadOkr:=RO;
ArButtons[High(ArButtons)-1].RadOkr:=RO;
ArButtons[High(ArButtons)].RadOkr:=RO;
if ArButtons[Low(ArButtons)].Blan then
	begin
	if Position>1 then
		Position:=Position-1;
	ArButtons[Low(ArButtons)].Blan:=false;
	end;
if ArButtons[High(ArButtons)-1].Blan then
	begin
	if Position-1<(Length(Text)-round(Shrift.x)) then
		Position:=Position+1;
	ArButtons[High(ArButtons)-1].Blan:=false;
	end;
if Length(Text)<round(Shrift.x) then
	begin
	Position:=1;
	ArButtons[High(ArButtons)].OVL.Import(abs(bvl.x-t4.x)/abs(bvl.x-bnp.x),abs(bvl.y-t4.y)/abs(bvl.y-bnp.y));
	ArButtons[High(ArButtons)].ONP.Import(abs(bvl.x-t5.x)/abs(bvl.x-bnp.x),abs(bvl.y-t5.y)/abs(bvl.y-bnp.y));
	tt1:=bvl;
	tt2.Import(bnp.x-2*RO,bvl.y-2*Ro,bvl.z);
	for i:=Low(Text) to High(Text) do
		begin
		if i+1=MVPos then
			begin
			glColor4f(0,0.5,0.8,0.6*_);
			GlSanRoundQuad(tt1,tt2,ro,4);
			GlSanRoundQuadLines(tt1,tt2,ro,4);
			end;
		if Verh then
			TextChv[i,1].SanSetColorA(_)
		else
			TextChv[i,2].SanSetColorA(_);
		GlSanOutText(tt1,tt2,Text[i],RO2);
		tt1.y-=2*ro;
		tt2.y-=2*RO;
		end;
	end
else
	begin
	o1:=abs(t4.y-t5.y);
	o2:=o1;
	o1:=((Position-1)/Length(text))*o1;
	o2:=((Position+round(Shrift.x)-1)/Length(Text))*o2;
	o:=T4.y;
	T4.Import(T4.x,o-o1,T1.z);
	T5.Import(T5.x,o-o2,T1.z);
	if abs(o2-o1)<2*ro then
	ArButtons[High(ArButtons)].RadOkr:=abs(o2-o1)/2;
	ArButtons[High(ArButtons)].OVL.Import(abs(bvl.x-t4.x)/abs(bvl.x-bnp.x),abs(bvl.y-t4.y)/abs(bvl.y-bnp.y));
	ArButtons[High(ArButtons)].ONP.Import(abs(bvl.x-t5.x)/abs(bvl.x-bnp.x),abs(bvl.y-t5.y)/abs(bvl.y-bnp.y));
	tt1:=bvl;
	tt2.Import(bnp.x-2*RO,bvl.y-2*Ro,bvl.z);
	for i:=Position-1 to Position+round(Shrift.x)-2 do
		begin
		if i+1=MVPos then
			begin
			glColor4f(0,0.5,0.8,0.6*_);
			GlSanRoundQuad(tt1,tt2,ro,4);
			GlSanRoundQuadLines(tt1,tt2,ro,4);
			end;
		if Verh then
			TextChv[i,1].SanSetColorA(_)
		else
			TextChv[i,2].SanSetColorA(_);
		GlSanOutText(tt1,tt2,Text[i],RO2);
		tt1.y-=2*ro;
		tt2.y-=2*RO;
		end;
	end;
for i:=Low(ArButtons) to high(ArButtons) do
    ArButtons[i].Init(BVl,bnp,Verh,_);
end;

procedure GlSanWndNewListBox(const p:pointer; const a,b:GlSanKoor2f;  const shri:glsankoor2f; const bol:boolean);
var
	WU:GlSanUUWnd;
	Wnd:^GlSanWnd;
begin
WU:=p;
if ((p<>nil) and (WU^<>nil)) then
	begin
	Wnd:=WU^;
	SetLength(Wnd^.ArListBox,Length(Wnd^.ArListBox)+1);
	Wnd^.ArListBox[High(Wnd^.ArListBox)].OVL.Import(a.x/Wnd^.WndW,a.y/Wnd^.WndH);
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ONP.Import(b.x/Wnd^.WndW,b.y/Wnd^.WndH);
	SetLength(Wnd^.ArListBox[High(Wnd^.ArListBox)].Text,0);
	SetLength(Wnd^.ArListBox[High(Wnd^.ArListBox)].TextChv,0);
	Wnd^.ArListBox[High(Wnd^.ArListBox)].MV:=bol;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].MVPos:=0;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].PokQuad:=true;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].Shrift:=shri;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].Position:=1;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].PositionOn:=-1;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].Button:=false;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[1].Chv:=GlSanWndButtonsChvStandard;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[2].Chv:=GlSanWndButtonsChvStandard;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[3].Chv:=GlSanWndButtonsChvStandard;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[1].Text:='Л';
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[2].Text:='V';
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[3].Text:='I';
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[1].Blan:=false;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[2].Blan:=false;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[3].Blan:=false;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[3].ProcB:=nil;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[2].ProcB:=nil;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[1].ProcB:=nil;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[1].OVL:=GlSanKoor2fimport(0,0);
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[1].Onp:=GlSanKoor2fimport(0,0);
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[2].OVL:=GlSanKoor2fimport(0,0);
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[2].Onp:=GlSanKoor2fimport(0,0);
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[3].OVL:=GlSanKoor2fimport(0,0);
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[3].Onp:=GlSanKoor2fimport(0,0);
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[3].RadOkr:=2/height;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[2].RadOkr:=2/height;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[1].RadOkr:=2/height;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[1].SetOnOn:=true;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[2].SetOnOn:=true;
	Wnd^.ArListBox[High(Wnd^.ArListBox)].ArButtons[3].SetOnOn:=true;
	end;
end;

procedure GlSanWndSetNewColorText(const p:pointer; const l:longint; const color:GlSanWndTextChv);
var
	Wnd:^GlSanUWnd;
	W:^GlSanWnd;
begin
Wnd:=p;
if Wnd^<>nil then
	begin
	if not ((High(Wnd^^.ArText)+1<l)or (Low(Wnd^^.ArText)+1>l)) then
		begin
		W:=Wnd^;
		W^.ArText[l-1].Chv:=color;
		end;
	end;
end;

procedure GlSanWndSetNewTittleText(const p:pointer; const l:longint; const NT:string);
var
	Wnd:^GlSanUWnd;
begin
Wnd:=p;
if Wnd^=nil then exit;
if (l-1>High(Wnd^^.ArText)) or (l-1<Low(Wnd^^.ArText)) then exit;
Wnd^^.ArText[l-1].Text:=nt;
end;

procedure GlSanWndDontSeeTittle(const p:pointer);
var
	Wnd:^GlSanWnd;
	W2:^GlSanUWnd;
begin
w2:=p;
if w2^<>nil then
	begin
	Wnd:=w2^;
	Wnd^.ZagP:=not Wnd^.ZagP;
	end;
end;

procedure GlSanWndAllMove(const p:pointer);
var
	Wnd:^GlSanWnd;
	W2:^GlSanUWnd;
begin
w2:=p;
if w2^<>nil then
	begin
	Wnd:=w2^;
	Wnd^.MTelo:=not Wnd^.MTelo;
	end;
end;

function GlSanWndClickButton(const p:pointer; l:longint):boolean;
var
	Wnd:^GlSanWnd;
	W2:^GlSanUWnd;
begin
w2:=p;
GlSanWndClickButton:=false;
if ((p<>nil) and (w2^<>nil)) then
	begin
	Wnd:=w2^;
	if l-1 in[Low(Wnd^.ArButtons)..High(Wnd^.ArButtons)] then
		begin
		GlSanWndClickButton:=Wnd^.ArButtons[l-1].Blan;
		Wnd^.ArButtons[l-1].Blan:=false;
		end;
	end;
end;

procedure GlSanWndNewButton(const p:pointer; const a,b:GlSanKoor2f; const s:string);
var
	Wnd:GlSanUUWnd;
begin
Wnd:=p;
if (a.x<b.x) and (a.y<b.y) then
	begin
	SetLength(Wnd^^.ArButtons,Length(Wnd^^.ArButtons)+1);
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].Blan:=false;
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].ProcB:=nil;
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].Text:=s;
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].OVL.Import(a.x/Wnd^^.WndW,a.y/Wnd^^.WndH);
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].ONP.Import(b.x/Wnd^^.WndW,b.y/Wnd^^.WndH);
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].Chv:=GlSanWndButtonsChvStandard;
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].RadOkr:=2/height;
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].SetOnOn:=false;
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].Tex:='';
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].TexC:='';
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].TexOn:='';
	end;
end;

procedure GlSanWndUserMove(const p:pointer;const l:longint;const a:GlSanKoor2f);
var
	Wnd:^GlSanWnd;
	UWnd:GlSanUUWnd;
	K1,k2,a2:GlSanKoor2f;
begin
UWnd:=p;
if UWnd^<>nil then
	begin
	Wnd:=UWnd^;
	case l of
	1:
		begin
		k1.x:=Wnd^.Ovl.x-Wnd^.Onp.x;
		k1.y:=Wnd^.Ovl.y-Wnd^.Onp.y;
		k2.x:=Wnd^.Ovl.x-Wnd^.ONZP.x;
		k2.y:=Wnd^.Ovl.y-Wnd^.ONZP.y;
		a2.x:=a.x/width;
		a2.y:=a.y/height;
		if a.x<>0 then Wnd^.Ovl.x:=a2.x;
		if a.y<>0 then Wnd^.Ovl.y:=a2.y;
		if a.x<>0 then Wnd^.Onp.x:=a2.x-k1.x;
		if a.y<>0 then Wnd^.Onp.y:=a2.y-k1.y;
		if a.x<>0 then Wnd^.ONZP.x:=a2.x-k2.x;
		if a.y<>0 then Wnd^.ONZP.y:=a2.y-k2.y;
		end;
	3:
		begin
		k1.x:=Wnd^.ONP.x-Wnd^.OVL.x;
		k1.y:=Wnd^.ONP.y-Wnd^.OVL.y;
		k2.x:=Wnd^.ONP.x-Wnd^.ONZP.x;
		k2.y:=Wnd^.ONP.y-Wnd^.ONZP.y;
		a2.x:=a.x/width;
		a2.y:=a.y/height;
		if a.x<>0 then Wnd^.ONP.x:=a2.x;
		if a.y<>0 then Wnd^.ONP.y:=a2.y;
		if a.x<>0 then Wnd^.OVL.x:=a2.x-k1.x;
		if a.y<>0 then Wnd^.OVL.y:=a2.y-k1.y;
		if a.x<>0 then Wnd^.ONZP.x:=a2.x-k2.x;
		if a.y<>0 then Wnd^.ONZP.y:=a2.y-k2.y;
		end;
	end;
	end;
end;

function GlSanRastT(const a,b:GlSanKoor):GlSanKoor;
begin
GlSanRastT.x:=a.x-b.x;
GlSanRastT.y:=a.y-b.y;
GlSanRastT.z:=a.z-b.z;
end;

procedure GlSanLineDontSee(const a,b:GlSanKoor;const r:real);
var
	Rast:real;
	Kol:longint;
	i:longint;
	TR:GlSanKoor;
	T1,T2,T3:GlSanKoor;
begin
Rast:=GlSanRast(a,b);
Kol:=trunc(Rast/r);
if Kol mod 2 = 1 then Kol+=1;
TR:=GlSanRastT(a,b);
for i:=0 to Kol-1 do
	begin
	if i mod 2 = 0 then
		begin
		T3:=Tr;
		T3.Zum(1/Kol);
		T3.Zum(i);
		T1:=b;
		T1.Togever(T3);
		T3:=Tr;
		T3.Zum(1/Kol);
		T3.Zum(i+1);
		T2:=b;
		T2.Togever(T3);
		GlSanLine(T1,T2);
		end;
	end;
end;

procedure GlSanWndText.Init(const vl,np:GlSanKoor; const Verh:boolean; const _:real);
const wa=1/3;
var
	bvl,bnp:GlSanKoor;
	razn:GlSanKoor2f;
begin
Razn.Import(abs(vl.x-np.x),abs(vl.y-np.y));
bvl.Import(vl.x+razn.x*OVL.x,vl.y-razn.y*ovl.y,vl.z);
bnp.Import(vl.x+razn.x*onp.x,vl.y-razn.y*onp.y,np.z);
case ParamS of
GSB_MIDDLE_TEXT:
	begin
	case ParamF of
	GSB_CANCULATE_HEIGHT:
		begin
		Razn.x:=abs(bvl.y-bnp.y)*0.48;
		Razn.y:=Razn.x*((GlSanRast(bvl,GlSanKoorImport(bnp.x,bvl.y,bnp.z))))/GlSanTextLength(Text,Razn.x);
		if Verh then Chv[1].SanSetColorA(_) else Chv[2].SanSetColorA(_);
		GlSanOutTextS(bvl,bnp,text,razn.x);
		end;
	GSB_CANCULATE_WIDTH:
		begin
		Razn.x:=abs(bvl.y-bnp.y)*0.48;
		Razn.y:=Razn.x*((GlSanRast(bvl,GlSanKoorImport(bnp.x,bvl.y,bnp.z))))/GlSanTextLength(Text,Razn.x);
		if Verh then Chv[1].SanSetColorA(_) else Chv[2].SanSetColorA(_);
		GlSanOutTextS(GlSanSredKoor(bvl,bnp),Text,Razn);
		end;
	end;
	end;
GSB_LEFT_TEXT:
	begin
	case ParamF of
	GSB_CANCULATE_HEIGHT:
		begin
		Razn.x:=abs(bvl.y-bnp.y)*0.48;
		Razn.y:=Razn.x*((GlSanRast(bvl,GlSanKoorImport(bnp.x,bvl.y,bnp.z))))/GlSanTextLength(Text,Razn.x);
		if Verh then Chv[1].SanSetColorA(_) else Chv[2].SanSetColorA(_);
		GlSanOutText(bvl,bnp,text,razn.x);
		end;
	GSB_CANCULATE_WIDTH:
		begin
		Razn.x:=abs(bvl.y-bnp.y)*0.48;
		Razn.y:=Razn.x*((GlSanRast(bvl,GlSanKoorImport(bnp.x,bvl.y,bnp.z))))/GlSanTextLength(Text,Razn.x);
		if Verh then Chv[1].SanSetColorA(_) else Chv[2].SanSetColorA(_);
		GlSanOutText(GlSanSredKoor(bvl,bnp),Text,Razn);
		end;
	end;
	end;
end;
end;
procedure GlSanWndSetLastTextParametrs(const p:PPGlSanWnd;const PS,PF:GlSanParametr);
begin
if (p<>nil) and (p^<>nil) then
	begin
	GlSanWndSetTextParametrs(p,Length(p^^.ArText),PS,PF);
	end;
end;
procedure GlSanWndSetTextParametrs(const p:PPGlSanWnd; const l:longint; const PS,PF:GlSanParametr);
begin
if (p<>nil) and (p^<>nil) and (l-1 in [Low(p^^.ArText)..High(p^^.ArText)]) then
	begin
	p^^.ArText[l-1].ParamF:=PF;
	p^^.ArText[l-1].ParamS:=PS;
	end;
end;

procedure GlSanWndNewText(const p:pointer; const a,b:GlSanKoor2f; const s:string);
var
	Wnd:^GlSanUWnd;
begin
Wnd:=p;
if Wnd^<>nil then
	begin
	SetLength(Wnd^^.ArText,High(Wnd^^.ArText)+2);
	Wnd^^.ArText[High(Wnd^^.ArText)].Text:=s;
	Wnd^^.ArText[High(Wnd^^.ArText)].OVL.Import(a.x/Wnd^^.WndW,a.y/Wnd^^.WndH);
	Wnd^^.ArText[High(Wnd^^.ArText)].ONP.Import(b.x/Wnd^^.WndW,b.y/Wnd^^.WndH);
	Wnd^^.ArText[High(Wnd^^.ArText)].Chv:=GlSanWndTextChvStandard;
	Wnd^^.ArText[High(Wnd^^.ArText)].ParamF:=GSB_CANCULATE_WIDTH;;
	Wnd^^.ArText[High(Wnd^^.ArText)].ParamS:=GSB_MIDDLE_TEXT;
	end;
end;

procedure GlSanObj3.Dispose;
var
	i:longint;
begin
SetLength(V,0);
For i:=Low(F) to High(F) do
	SetLength(F[i],0);
SetLength(F,0);
end;

procedure GlSanObj3.Init(const a:GlSanKoor;const r:real);
var
	i,ii:longint;
	K:GlSanKoor;
begin
GlEnable(GL_CULL_FACE);
GlCullFace(GL_BACK);
for i:=Low(f) to High(f) do
	begin
	glBegin(GL_POLYGON);
	for ii:=Low(F[i]) to High(F[i]) do
		begin
		K:=V[F[i,ii]];
		K.Zum(r);
		K.Togever(a);
		GlSanVertex3f(k);
		end;
	glEnd();
	end;
GlCullFace(GL_FRONT);
for i:=Low(f) to High(f) do
	begin
	glBegin(GL_POLYGON);
	for ii:=Low(F[i]) to High(F[i]) do
		begin
		K:=V[F[i,ii]];
		K.Zum(r);
		K.Togever(a);
		GlSanVertex3f(k);
		end;
	glEnd();
	end;
GLDisable(GL_CULL_FACE);
end;

procedure GlSanObj3.Init(const a:GlSanKoor;const r:GlSanKoor2f);
var
	i,ii:longint;
	K:GlSanKoor;
begin
for i:=Low(f) to High(f) do
	begin
	case Length(f[i]) of
	2:glBegin(GL_LINES);
	3:glBegin(GL_TRIANGLES);
	4:glBegin(GL_QUADS);
	end;
	for ii:=Low(F[i]) to High(F[i]) do
		begin
		K:=V[F[i,ii]];
		K.Zum(r.x,r.y);
		K.Togever(a);
		GlSanVertex3f(k);
		end;
	glEnd();
	end;
end;

procedure GlSanObj3.ReadFromFile(const s:string);
var
	fail:text;
	str:string;
	kV,kF,i,ii,kVF:longint;
begin
SetLength(v,0);
SetLength(f,0);
if fail_est(s) then
	begin
	assign(fail,s);
	reset(fail);
	readln(fail,str);
	if ((str[1] in ['o','O']) and (str[2] in ['f','F']) and (str[3] in ['f','F'])) then
		begin
		readln(fail,kv,kf);
		SetLength(V,kV);
		SetLength(f,kF);
		for i:=0 to kV-1 do
			begin
			readln(fail,V[i].x,V[i].y,V[i].z);
			end;
		for i:=0 to kF-1 do
			begin
			read(fail,kVF);
			SetLength(F[i],kVF);
			for ii:=0 to kVF-1 do
				begin
				read(fail,F[i,ii]);
				end;
			readln(fail);
			end;
		end
	else
		begin

		end;
	close(fail);
	end;
end;


procedure GlSanWndSetNewTittleButton(const p:pointer; const l:longint; const NT:string);
var
	Wnd:^GlSanUWnd;
begin
Wnd:=p;
if Wnd^=nil then exit;
if (l-1>High(Wnd^^.ArButtons)) or (l-1<Low(Wnd^^.ArButtons)) then exit;
Wnd^^.ArButtons[l-1].Text:=nt;
end;

procedure GlSanWndButton.InitC(const vl,np:GlSanKoor);
const
	ots=0.01;
var
	bvl,bnp:GlSanKoor;
	razn,RaznB:GlSanKoor2f;
	R1,R2:real;
begin
Razn.Import(abs(vl.x-np.x),abs(vl.y-np.y));
bvl.Import(vl.x+razn.x*OVL.x,vl.y-razn.y*ovl.y,vl.z);
bnp.Import(vl.x+razn.x*onp.x,vl.y-razn.y*onp.y,np.z);
RaznB.x:=abs(bvl.x-bnp.x);
RaznB.y:=abs(bvl.y-bnp.y);
R1:=OTS*RaznB.x;
R2:=OTS*RaznB.y;
if R1>R2 then
	begin
	R1:=R2;
	end
else
	begin
	R2:=R1;
	end;
BVL.x:=BVL.x+R1;
BVL.y:=BVL.y-R2;
Bnp.x:=Bnp.x-R1;
Bnp.y:=Bnp.y+R2;
if not GlSanFindTexture(TexC) then
	if (ActiveSkin=-1) or (ArSkins[ActiveSkin].ButtonTexture3=-1) then 
		if RaznB.y*0.4<RadOkr then
			begin
			Chv[8].SanSetColor;
			GlSanRoundQuad(bvl,bnp,RaznB.y*0.4,4);
			Chv[8].SanSetColorA(1.2);
			GlSanRoundQuadLines(bvl,bnp,RaznB.y*0.4,4);
			end
		else
			begin
			Chv[8].SanSetColor;
			GlSanRoundQuad(bvl,bnp,RadOkr,4);
			Chv[8].SanSetColorA(1.2);
			GlSanRoundQuadLines(bvl,bnp,RadOkr,4);
			end
	else
		begin
		case ArSkins[ActiveSkin].ButtonTip of
		0:
			begin
			if GlSanRazn(Chv[8],GlSanWndButtonsChvStandard[8]) then Chv[8].SanSetColor else ArSkins[ActiveSkin].ArButtonTextureColor[3].Color;
			GlSanDrawComponent9Button(bvl,bnp,GetRadOkr(bvl,bnp,RadOkr),3);
			ArSkins[ActiveSkin].ArButtonTextureColor[3].Negative.Color;
			Razn.x:=abs(bvl.y-bnp.y)*0.4;
			Razn.y:=Razn.x*((GlSanRast(bvl,GlSanKoorImport(bnp.x,bvl.y,bnp.z))))/GlSanTextLength(Text,Razn.x)*0.85;
			while GlSanTextLength(Text,Razn.y)*0.85>abs(bvl.x-bnp.x) do
				Razn.y-=0.01;
			GlSanOutTextS(GlSanSredKoor(bvl,bnp),Text,Razn);
			end;
		end;
		end
else
	begin
	glColor3f(1,1,1);
	if GlSanBindTexture(TexC) then
		begin
		WndSomeQuad(bvl,bnp);
		glDisable(GL_TEXTURE_2D);
		end;
	end;
end;

procedure GlSanWndButton.InitOn(const vl,np:GlSanKoor);
const
	ots=0.01;
var
	bvl,bnp:GlSanKoor;
	razn,RaznB:GlSanKoor2f;
	R1,R2:real;
begin
Razn.Import(abs(vl.x-np.x),abs(vl.y-np.y));
bvl.Import(vl.x+razn.x*OVL.x,vl.y-razn.y*ovl.y,vl.z);
bnp.Import(vl.x+razn.x*onp.x,vl.y-razn.y*onp.y,np.z);
RaznB.x:=abs(bvl.x-bnp.x);
RaznB.y:=abs(bvl.y-bnp.y);
R1:=OTS*RaznB.x;
R2:=OTS*RaznB.y;
if R1>R2 then
	begin
	R1:=R2;
	end
else
	begin
	R2:=R1;
	end;
BVL.x:=BVL.x+R1;
BVL.y:=BVL.y-R2;
Bnp.x:=Bnp.x-R1;
Bnp.y:=Bnp.y+R2;
if not GlSanFindTexture(TexOn) then
	if (ActiveSkin=-1) or (ArSkins[ActiveSkin].ButtonTexture2=-1) then 
		if RaznB.y*0.4<RadOkr then
			begin
			Chv[7].SanSetColor;
			GlSanRoundQuad(bvl,bnp,RaznB.y*0.4,4);
			Chv[7].SanSetColorA(1.2);
			GlSanRoundQuadLines(bvl,bnp,RaznB.y*0.4,4);
			end
		else
			begin
			Chv[7].SanSetColor;
			GlSanRoundQuad(bvl,bnp,RadOkr,4);
			Chv[7].SanSetColorA(1.2);
			GlSanRoundQuadLines(bvl,bnp,RadOkr,4);
			end
	else
		begin
		case ArSkins[ActiveSkin].ButtonTip of
		0:
			begin
			if GlSanRazn(Chv[7],GlSanWndButtonsChvStandard[7]) then Chv[7].SanSetColor else ArSkins[ActiveSkin].ArButtonTextureColor[2].Color;
			GlSanDrawComponent9Button(bvl,bnp,GetRadOkr(bvl,bnp,RadOkr),2);
			ArSkins[ActiveSkin].ArButtonTextureColor[2].Negative.Color;
			Razn.x:=abs(bvl.y-bnp.y)*0.4;
			Razn.y:=Razn.x*((GlSanRast(bvl,GlSanKoorImport(bnp.x,bvl.y,bnp.z))))/GlSanTextLength(Text,Razn.x)*0.85;
			while GlSanTextLength(Text,Razn.y)*0.85>abs(bvl.x-bnp.x) do
				Razn.y-=0.01;
			GlSanOutTextS(GlSanSredKoor(bvl,bnp),Text,Razn);
			end;
		end;
		end
else
	begin
	glColor4f(1,1,1,0.8);
	if GlSanBindTexture(TexOn) then 
		begin
		WndSomeQuad(bvl,bnp);
		glDisable(GL_TEXTURE_2D);
		end;
	end;
end;

function GlSanCursorOnButton(const p:pointer; const k:GlSanKoor; const vl,np:GlSanKoor):boolean;
var
	But:^GlSanWndButton;
	bvl,bnp:GlSanKoor;
	razn:GlSanKoor2f = (x:0; y:0);
	t2,t4:GlSanKoor;
	Pl1,Pl2:real;
begin
but:=p;
Razn.Import(abs(vl.x-np.x),abs(vl.y-np.y));
bvl.Import(vl.x+razn.x*But^.OVL.x,vl.y-razn.y*But^.ovl.y,vl.z);
bnp.Import(vl.x+razn.x*But^.onp.x,vl.y-razn.y*But^.onp.y,np.z);
T2.Import(bnp.x,bvl.y,bvl.z);
T4.Import(bvl.x,bnp.y,bnp.z);
Pl1:=GlSanRast(bvl,T2)*GlSanRast(bvl,T4);
Pl2:=GlSanTreugPlosh(K,bvl,T2)+GlSanTreugPlosh(K,T2,bnp)+GlSanTreugPlosh(K,bnp,T4)+GlSanTreugPlosh(K,bvl,T4);
if abs(Pl2-Pl1)<=(GlSanWndMin/1000) then
	GlSanCursorOnButton:=true
else
	GlSanCursorOnButton:=false;
end;

procedure GlSanWndFindKoor(const p:pointer;const z:longint;var t1,t3:GlSanKoor);
var
	wnd:^GlSanWnd;
begin
wnd:=p;
T1:=Wnd^.TVL;
T3:=Wnd^.TNP;
end;

procedure GlSanKoorPlosk.Zum(const r:real);
begin
a:=a*r;
b:=b*r;
c:=c*r;
d:=d*r;
end;

procedure GlSanDrawComponent9Button(const TVL,TNP:GlSanKoor; const r:real;const Tip:longint);
begin
{Включаем текстуры}
glEnable(GL_TEXTURE_2D);
{Устанавливаем активную текстуру}
case Tip of 
1:
	begin
	glBindTexture(GL_TEXTURE_2D,ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ButtonTexture1]);
	end;
2:
	begin
	glBindTexture(GL_TEXTURE_2D,ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ButtonTexture2]);
	end;
3:
	begin
	glBindTexture(GL_TEXTURE_2D,ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ButtonTexture3]);
	end;
4:
	begin
	glBindTexture(GL_TEXTURE_2D,ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].ButtonTexture4]);
	end;
end;
case Tip of
1:
	begin
	WndSomeQuad(TVL,
		GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
		GlSanKoor2fImport(0,0),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)],ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+1]));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y,TVL.z),
		GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)],0),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+2],ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+1]));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y,TVL.z),
		GlSanKoorImport(TNP.x,TVL.y-R,TVL.z),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+2],0),
		GlSanKoor2fImport(1,ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+1]));
	WndSomeQuad(GlSanKoorImport(TVL.x,TVL.y-R,TVL.z),
		GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
		GlSanKoor2fImport(0,ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+1]),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)],1-ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+3]));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
		GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)],ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+1]),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+2],1-ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+3]));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
		GlSanKoorImport(TNP.x,TNP.y+R,TVL.z),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+2],ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+1]),
		GlSanKoor2fImport(1,1-ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+3]));
	WndSomeQuad(GlSanKoorImport(TVL.x,TNP.y+R,TVL.z),
		GlSanKoorImport(TVL.x+r,TNP.y,TVL.z),
		GlSanKoor2fImport(0,1-ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+3]),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)],1));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
		GlSanKoorImport(TNP.x-r,TNP.y,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)],1-ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+3]),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+2],1));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
		TNP,
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+2],1-ArSkins[ActiveSkin].ArRealButton1[Low(ArSkins[ActiveSkin].ArRealButton1)+3]),
		GlSanKoor2fImport(1,1));
	end;
2:
	begin
	WndSomeQuad(TVL,
		GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
		GlSanKoor2fImport(0,0),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)],ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+1]));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y,TVL.z),
		GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)],0),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+2],ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+1]));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y,TVL.z),
		GlSanKoorImport(TNP.x,TVL.y-R,TVL.z),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+2],0),
		GlSanKoor2fImport(1,ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+1]));
	WndSomeQuad(GlSanKoorImport(TVL.x,TVL.y-R,TVL.z),
		GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
		GlSanKoor2fImport(0,ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+1]),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)],1-ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+3]));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
		GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)],ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+1]),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+2],1-ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+3]));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
		GlSanKoorImport(TNP.x,TNP.y+R,TVL.z),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+2],ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+1]),
		GlSanKoor2fImport(1,1-ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+3]));
	WndSomeQuad(GlSanKoorImport(TVL.x,TNP.y+R,TVL.z),
		GlSanKoorImport(TVL.x+r,TNP.y,TVL.z),
		GlSanKoor2fImport(0,1-ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+3]),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)],1));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
		GlSanKoorImport(TNP.x-r,TNP.y,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)],1-ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+3]),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+2],1));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
		TNP,
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+2],1-ArSkins[ActiveSkin].ArRealButton2[Low(ArSkins[ActiveSkin].ArRealButton2)+3]),
		GlSanKoor2fImport(1,1));
	end;
3:
	begin
	WndSomeQuad(TVL,
		GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
		GlSanKoor2fImport(0,0),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)],ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+1]));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y,TVL.z),
		GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)],0),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+2],ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+1]));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y,TVL.z),
		GlSanKoorImport(TNP.x,TVL.y-R,TVL.z),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+2],0),
		GlSanKoor2fImport(1,ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+1]));
	WndSomeQuad(GlSanKoorImport(TVL.x,TVL.y-R,TVL.z),
		GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
		GlSanKoor2fImport(0,ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+1]),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)],1-ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+3]));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
		GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)],ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+1]),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+2],1-ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+3]));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
		GlSanKoorImport(TNP.x,TNP.y+R,TVL.z),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+2],ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+1]),
		GlSanKoor2fImport(1,1-ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+3]));
	WndSomeQuad(GlSanKoorImport(TVL.x,TNP.y+R,TVL.z),
		GlSanKoorImport(TVL.x+r,TNP.y,TVL.z),
		GlSanKoor2fImport(0,1-ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+3]),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)],1));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
		GlSanKoorImport(TNP.x-r,TNP.y,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)],1-ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+3]),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+2],1));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
		TNP,
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+2],1-ArSkins[ActiveSkin].ArRealButton3[Low(ArSkins[ActiveSkin].ArRealButton3)+3]),
		GlSanKoor2fImport(1,1));
	end;
4:
	begin
	WndSomeQuad(TVL,
		GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
		GlSanKoor2fImport(0,0),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)],ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+1]));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y,TVL.z),
		GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)],0),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+2],ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+1]));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y,TVL.z),
		GlSanKoorImport(TNP.x,TVL.y-R,TVL.z),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+2],0),
		GlSanKoor2fImport(1,ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+1]));
	WndSomeQuad(GlSanKoorImport(TVL.x,TVL.y-R,TVL.z),
		GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
		GlSanKoor2fImport(0,ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+1]),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)],1-ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+3]));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
		GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)],ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+1]),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+2],1-ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+3]));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
		GlSanKoorImport(TNP.x,TNP.y+R,TVL.z),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+2],ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+1]),
		GlSanKoor2fImport(1,1-ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+3]));
	WndSomeQuad(GlSanKoorImport(TVL.x,TNP.y+R,TVL.z),
		GlSanKoorImport(TVL.x+r,TNP.y,TVL.z),
		GlSanKoor2fImport(0,1-ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+3]),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)],1));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
		GlSanKoorImport(TNP.x-r,TNP.y,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)],1-ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+3]),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+2],1));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
		TNP,
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+2],1-ArSkins[ActiveSkin].ArRealButton4[Low(ArSkins[ActiveSkin].ArRealButton4)+3]),
		GlSanKoor2fImport(1,1));
	end;
end;
{Отключаем текстуры}
glDisable(GL_TEXTURE_2D);
end;

procedure GlSanWndButton.Init(const vl,np:GlSanKoor; const Verh:boolean; const _:real);
const wa=1/3;
var
	bvl,bnp:GlSanKoor;
	razn:GlSanKoor2f;
begin
Razn.Import(abs(vl.x-np.x),abs(vl.y-np.y));
bvl.Import(vl.x+razn.x*OVL.x,vl.y-razn.y*ovl.y,vl.z);
bnp.Import(vl.x+razn.x*onp.x,vl.y-razn.y*onp.y,np.z);
if false=GlSanFindTexture(Tex) then
	if (ActiveSkin=-1) or (Verh and (ArSkins[ActiveSkin].ButtonTexture1=-1)) or ((not Verh) and (ArSkins[ActiveSkin].ButtonTexture4=-1)) then
		if abs(bvl.y-bnp.y)*0.4<RadOkr then
			begin
			if Verh then Chv[1].SanSetColorA(_) else Chv[4].SanSetColorA(_);
			GlSanRoundQuad(bvl,bnp,abs(bvl.y-bnp.y)*0.4,4);
			if Verh then Chv[2].SanSetColorA(_) else Chv[5].SanSetColorA(_);
			GlSanRoundQuadLines(bvl,bnp,abs(bvl.y-bnp.y)*0.4,4);
			end
		else
			begin
			if Verh then Chv[1].SanSetColorA(_) else Chv[4].SanSetColorA(_);
			GlSanRoundQuad(bvl,bnp,RadOkr,4);
			if Verh then Chv[2].SanSetColorA(_) else Chv[5].SanSetColorA(_);
			GlSanRoundQuadLines(bvl,bnp,RadOkr,4);
			end
	else
		begin
		if Verh then
			begin
			ArSkins[ActiveSkin].ArButtonTextureColor[1].SanSetColorA(_);
			GlSanDrawComponent9Button(bvl,bnp,GetRadOkr(bvl,bnp,RadOkr),1);
			end
		else
			begin
			ArSkins[ActiveSkin].ArButtonTextureColor[4].SanSetColorA(_);
			GlSanDrawComponent9Button(bvl,bnp,GetRadOkr(bvl,bnp,RadOkr),4);
			end;
		end
else
	begin
	glColor4f(1,1,1,_);
	if GlSanBindTexture(Tex) then 
		begin
		WndSomeQuad(bvl,bnp);
		glDisable(GL_TEXTURE_2D);
		end;
	end;
if not GlSanFindTexture(Tex) then
	begin
	if Verh then Chv[3].SanSetColorA(_) else Chv[6].SanSetColorA(_);
	Razn.x:=abs(bvl.y-bnp.y)*0.4;
	Razn.y:=Razn.x*((GlSanRast(bvl,GlSanKoorImport(bnp.x,bvl.y,bnp.z))))/GlSanTextLength(Text,Razn.x)*0.85;
	while GlSanTextLength(Text,Razn.y)*0.85>abs(bvl.x-bnp.x) do
		Razn.y-=0.01;
	GlSanOutTextS(GlSanSredKoor(bvl,bnp),Text,Razn);
	end;
end;

procedure GlSanWndNewButton(const p:pointer; const a,b:GlSanKoor2f; const s:string; const  pb:pointer);
var
	Wnd:GlSanUUWnd;
begin
Wnd:=p;
if (a.x<b.x) and (a.y<b.y) then
	begin
	SetLength(Wnd^^.ArButtons,Length(Wnd^^.ArButtons)+1);
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].Blan:=false;
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].Text:=s;
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].OVL.Import(a.x/Wnd^^.WndW,a.y/Wnd^^.WndH);
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].ONP.Import(b.x/Wnd^^.WndW,b.y/Wnd^^.WndH);
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].Chv:=GlSanWndButtonsChvStandard;
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].RadOkr:=2/height;
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].ProcB:=pb;
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].SetOnOn:=false;
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].Tex:='';
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].TexC:='';
	Wnd^^.ArButtons[High(Wnd^^.ArButtons)].TexOn:='';
	end;
end;

procedure GlSanKoorPlosk.SanSetColorA(const al:real);
begin
glcolor4f(a,b,c,d*al);
end;

procedure GlSanOutTextS(Koor:GlSanKoor; const s :string; const r:real);
begin
GlSanOutText(GlSanKoorImport(-0.5*GlSanTextLength(s,r)+Koor.x-r-r,Koor.y,Koor.z),s,r);
end;
procedure GlSanOutTextS(Koor:GlSanKoor; const s :string; const r:GlSanKoor2f);
begin
GlSanOutText(GlSanKoorImport(-0.5*GlSanTextLength(s,r.y)+Koor.x-2*r.y,Koor.y,Koor.z),s,r);
end;
procedure GlSanABCObj.SmallInit(TOC:GlSanKoor;r:GlSanKoor2f);
var
	i:longword;
	o1,o2:GlSanKoor;
begin
toc.import(toc.x-0.3*r.x,toc.y,toc.z);
r.x/=1.5;
r.y/=1.5;
for i:=1 to KolL do
	begin
	o1:=GlSanLoadABCToch(L[1,i]);
	o2:=GlSanLoadABCToch(L[2,i]);
	o1.x*=r.x;
	o1.y*=r.y;
	o2.x*=r.x;
	o2.y*=r.y;
	o1.Togever(toc);
	o2.Togever(toc);
	GlSanLine(o1,o2);
	end;
end;

procedure GlSanOutText(Koor:GlSanKoor; const s:string; r:GlSanKoor2f);
var
	i:longint;
	ob:GlSanABCObj;
	sm:real;
	q:real = 0;
	WO:word;
	o:longint;
begin
if ActiveSkin<>-1 then
	r.Zum(0.87);
if CorrectFont then
	begin
	if (r.x>r.y ) then
		r.x:=r.y
	else
		begin
		{q:=(r.y-r.x)*GlSanTextLength(s,r.y);
		r.y:=r.x;}
		end;
	end;
if ActiveFont=-1 then
	begin
	sm:=Koor.x;
	Koor.x:=Koor.y;
	Koor.y:=-sm;
	if ActiveSkin=-1 then
		sm:=2.05*r.y+q
	else
		sm:=2.35*r.y+q;
	for i:=1 to length(s) do
		begin
		ob:=GlSanLoadBykv(s[i]);
		glpushmatrix;
		glrotatef(90,0,0,1);
		if GlSanSmallABC(s[i]) then
			begin
			if ((i<>1) and (GlSanSmallABC(s[i-1])=false)) then
				sm+=1.95*r.y
			else
				sm+=1.6*r.y;
			ob.SmallInit(GlSanKoorImport(Koor.x,Koor.y-sm,Koor.z),r);
			end
		else
			begin
			if ((i<>1) and GlSanSmallABC(s[i-1])) then
				sm+=1.95*r.y
			else
				sm+=2.25*r.y;
			ob.Init(GlSanKoorImport(Koor.x,Koor.y-sm,Koor.z),r);
			end;
		glpopmatrix;
		end;
	end
else
	begin
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D,ArFonts[ActiveFont].ID);
	WO:=ArFonts[ActiveFont].ArChar[ord(SravnChar)].Width;
	if ActiveSkin=-1 then
		sm:=2.05*r.y+q
	else
		sm:=2.55*r.y+q;
	for i:=1 to Length(s) do
		begin
		o:=ord(s[i]);
		SomeQuad(
		GlSanKoorImport(Koor.x+sm,Koor.y+r.x,Koor.z),
		GlSanKoorImport(Koor.x+2*r.y*(ArFonts[ActiveFont].ArChar[o].width/WO)+sm,Koor.y+r.x,Koor.z),
		GlSanKoorImport(Koor.x+2*r.y*(ArFonts[ActiveFont].ArChar[o].width/WO)+sm,Koor.y-r.x,Koor.z),
		GlSanKoorImport(Koor.x+sm,Koor.y-r.x,Koor.z),
		GlSanKoor2fImport((ArFonts[ActiveFont].ArChar[o].x+CorrectIntoChar)/ArFonts[ActiveFont].TW,
										1-((ArFonts[ActiveFont].ArChar[o].y+CorrectIntoChar)/ArFonts[ActiveFont].TH)),
		GlSanKoor2fImport(
		(ArFonts[ActiveFont].ArChar[o].x+ArFonts[ActiveFont].ArChar[o].width-CorrectIntoChar)/ArFonts[ActiveFont].TW,
							1-((ArFonts[ActiveFont].ArChar[o].y+ArFonts[ActiveFont].Height-CorrectIntoChar)/ArFonts[ActiveFont].TH))
		);
		sm+=2*r.y*(ArFonts[ActiveFont].ArChar[o].width/WO);
		end;
	glDisable(GL_TEXTURE_2D);
	end;
end;

procedure GlSanABCObj.Init(TOC:GlSanKoor;r:GlSanKoor2f);
var
	i:longword;
	o1,o2:GlSanKoor;
begin
for i:=1 to KolL do
	begin
	o1:=GlSanLoadABCToch(L[1,i]);
	o2:=GlSanLoadABCToch(L[2,i]);
	o1.x*=r.x;
	o1.y*=r.y;
	o2.x*=r.x;
	o2.y*=r.y;
	o1.Togever(toc);
	o2.Togever(toc);
	GlSanLine(o1,o2);
	end;
end;

function GlSanClickWnd(const Koor:GlSanKoor; const u:pointer; const z:longint):boolean;
var
	Wnd:^GlSanWnd;
	Razn:GlSanKoor2f;
	Pl1,Pl2:real;
	T1,T2,T3,T4:GlSanKoor;
begin
Wnd:=u;
if GlSanWAKol-z+1<0 then
	begin
	razn.x:=abs((GlSanWA[0,1].x-GlSanWA[0,2].x));
	razn.y:=abs((GlSanWA[0,1].y-GlSanWA[0,3].y));
	T1.x:=GlSanWA[0,1].x+razn.x*Wnd^.OVL.x;
	T1.y:=GlSanWA[0,1].y-razn.y*Wnd^.OVL.y;
	T1.z:=GlSanWA[0,1].z;
	T3.x:=GlSanWA[0,1].x+razn.x*Wnd^.ONP.x;
	T3.y:=GlSanWA[0,1].y-razn.y*Wnd^.ONP.y;
	T3.z:=GlSanWA[0,1].z;
	end
else
	begin
	razn.x:=abs((GlSanWA[GlSanWAKol-z+1,1].x-GlSanWA[GlSanWAKol-z+1,2].x));
	razn.y:=abs((GlSanWA[GlSanWAKol-z+1,1].y-GlSanWA[GlSanWAKol-z+1,3].y));
	T1.x:=GlSanWA[GlSanWAKol-z+1,1].x+razn.x*Wnd^.OVL.x;
	T1.y:=GlSanWA[GlSanWAKol-z+1,1].y-razn.y*Wnd^.OVL.y;
	T1.z:=GlSanWA[GlSanWAKol-z+1,1].z;
	T3.x:=GlSanWA[GlSanWAKol-z+1,1].x+razn.x*Wnd^.ONP.x;
	T3.y:=GlSanWA[GlSanWAKol-z+1,1].y-razn.y*Wnd^.ONP.y;
	T3.z:=GlSanWA[GlSanWAKol-z+1,1].z;
	end;
T2.Import(T3.x,T1.y,T1.z);
T4.Import(T1.x,T3.y,T3.z);
Pl1:=GlSanRast(T1,T2)*GlSanRast(T1,T4);
Pl2:=GlSanTreugPlosh(Koor,T1,T2)+GlSanTreugPlosh(Koor,T2,T3)+GlSanTreugPlosh(Koor,T3,T4)+GlSanTreugPlosh(Koor,T1,T4);
if abs(Pl2-Pl1)<=GlSanWndMin then
	GlSanClickWnd:=true
else
	GlSanClickWnd:=false;
end;

function GlSanFindEndOfWnd():pointer;
begin
if Length(GlSanWinds)=0 then
	GlSanFindEndOfWnd:=nil
else
	GlSanFindEndOfWnd:=GlSanWinds[High(GlSanWinds)];
end;

function GlSanClickZagWnd(const Koor:GlSanKoor; const u:pointer; const z:longint):boolean;
var
	Wnd:^GlSanWnd;
	Razn:GlSanKoor2f;
	Pl1,Pl2:real;
	T1,T2,T3,T4:GlSanKoor;
begin
Wnd:=u;
if GlSanWAKol-z+1<0 then
	begin
	razn.x:=abs((GlSanWA[0,1].x-GlSanWA[0,2].x));
	razn.y:=abs((GlSanWA[0,1].y-GlSanWA[0,3].y));
	T1.x:=GlSanWA[0,1].x+razn.x*Wnd^.OVL.x;
	T1.y:=GlSanWA[0,1].y-razn.y*Wnd^.OVL.y;
	T1.z:=GlSanWA[0,1].z;
	T3.x:=GlSanWA[0,1].x+razn.x*Wnd^.ONP.x;
	T3.y:=GlSanWA[0,1].y-razn.y*Wnd^.ONP.y;
	T3.z:=GlSanWA[0,1].z;
	end
else
	begin
	razn.x:=abs((GlSanWA[GlSanWAKol-z+1,1].x-GlSanWA[GlSanWAKol-z+1,2].x));
	razn.y:=abs((GlSanWA[GlSanWAKol-z+1,1].y-GlSanWA[GlSanWAKol-z+1,3].y));
	T1.x:=GlSanWA[GlSanWAKol-z+1,1].x+razn.x*Wnd^.OVL.x;
	T1.y:=GlSanWA[GlSanWAKol-z+1,1].y-razn.y*Wnd^.OVL.y;
	T1.z:=GlSanWA[GlSanWAKol-z+1,1].z;
	T3.x:=GlSanWA[GlSanWAKol-z+1,1].x+razn.x*Wnd^.ONZP.x;
	T3.y:=GlSanWA[GlSanWAKol-z+1,1].y-razn.y*Wnd^.ONZP.y;
	T3.z:=GlSanWA[GlSanWAKol-z+1,1].z;
	end;
T2.Import(T3.x,T1.y,T1.z);
T4.Import(T1.x,T3.y,T3.z);
Pl1:=GlSanRast(T1,T2)*GlSanRast(T1,T4);
Pl2:=GlSanTreugPlosh(Koor,T1,T2)+GlSanTreugPlosh(Koor,T2,T3)+GlSanTreugPlosh(Koor,T3,T4)+GlSanTreugPlosh(Koor,T1,T4);
if abs(Pl2-Pl1)<=GlSanWndMin then
	GlSanClickZagWnd:=true
else
	GlSanClickZagWnd:=false;
end;

function GlSanTreugPlosh(const a1,a2,a3:GlSanKoor):real;
var
	p:real;
begin
p:=(GlSanRast(a1,a2)+GlSanRast(a1,a3)+GlSanRast(a3,a2))/2;
GlSanTreugPlosh:=sqrt(p*(p-GlSanRast(a1,a2))*(p-GlSanRast(a3,a2))*(p-GlSanRast(a1,a3)));
end;

function GlSanFindPredWnd(const p:pointer):pointer;
var
	i,ii:longint;
begin
if Length(GlSanWinds) in [1,0] then
	begin
	GlSanFindPredWnd:=nil;
	end
else
	begin
	for i:=Low(GlSanWinds) to High(GlSanWinds) do
		if GlSanWinds[i]=p then
			ii:=i;
	GlSanFindPredWnd:=GlSanWinds[ii-1];
	end;
end;



procedure GlSanCircleConst(l:longint;r,s:real);
	{Для тригонометрии + построение внутренности угла}
var
	_1,d:real;
	_2,o,k:GlSanKoor2f;
	i:longint;
begin
_1:=s/l;
d:=0;
_2.x:=1*r;
_2.y:=0;
k.X:=0;
K.y:=0;
for i:=1 to l do
	begin
	d+=_1;
	o.x:=cos(d)*r;
	o.y:=sin(d)*r;
	glbegin(GL_TRIANGLES);
	GlSanVertex3f(o.GSK3);
	GlSanVertex3f(_2.GSK3);
	GlSanVertex3f(K.gsk3);
	glend;
	_2:=o;
	end;
end;


function GlSanCreateInSys:pointer;
begin
SetLength(GlSanWinds,Length(GlSanWinds)+1);
New(GlSanWinds[High(GlSanWinds)]);
GlSanCreateInSys:=GlSanWinds[High(GlSanWinds)];
end;

procedure GlSanDrawComponent9(const TVL,TNP:GlSanKoor; const r:real; const ActiveWnd:boolean);
begin
{Включаем текстуры}
glEnable(GL_TEXTURE_2D);
{Устанавливаем активную текстуру}
if ActiveWnd then 
	begin
	glBindTexture(GL_TEXTURE_2D,ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].WindowTexture1]);
	WndSomeQuad(TVL,
		GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
		GlSanKoor2fImport(0,0),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)],ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+1]));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y,TVL.z),
		GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)],0),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+2],ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+1]));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y,TVL.z),
		GlSanKoorImport(TNP.x,TVL.y-R,TVL.z),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+2],0),
		GlSanKoor2fImport(1,ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+1]));
	WndSomeQuad(GlSanKoorImport(TVL.x,TVL.y-R,TVL.z),
		GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
		GlSanKoor2fImport(0,ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+1]),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)],1-ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+3]));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
		GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)],ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+1]),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+2],1-ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+3]));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
		GlSanKoorImport(TNP.x,TNP.y+R,TVL.z),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+2],ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+1]),
		GlSanKoor2fImport(1,1-ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+3]));
	WndSomeQuad(GlSanKoorImport(TVL.x,TNP.y+R,TVL.z),
		GlSanKoorImport(TVL.x+r,TNP.y,TVL.z),
		GlSanKoor2fImport(0,1-ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+3]),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)],1));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
		GlSanKoorImport(TNP.x-r,TNP.y,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)],1-ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+3]),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+2],1));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
		TNP,
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+2],1-ArSkins[ActiveSkin].ArRealWindow1[Low(ArSkins[ActiveSkin].ArRealWindow1)+3]),
		GlSanKoor2fImport(1,1));
	end
else 
	begin
	glBindTexture(GL_TEXTURE_2D,ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].WindowTexture2]);
	WndSomeQuad(TVL,
		GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
		GlSanKoor2fImport(0,0),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)],ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+1]));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y,TVL.z),
		GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)],0),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+2],ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+1]));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y,TVL.z),
		GlSanKoorImport(TNP.x,TVL.y-R,TVL.z),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+2],0),
		GlSanKoor2fImport(1,ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+1]));
	WndSomeQuad(GlSanKoorImport(TVL.x,TVL.y-R,TVL.z),
		GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
		GlSanKoor2fImport(0,ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+1]),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)],1-ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+3]));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
		GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)],ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+1]),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+2],1-ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+3]));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
		GlSanKoorImport(TNP.x,TNP.y+R,TVL.z),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+2],ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+1]),
		GlSanKoor2fImport(1,1-ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+3]));
	WndSomeQuad(GlSanKoorImport(TVL.x,TNP.y+R,TVL.z),
		GlSanKoorImport(TVL.x+r,TNP.y,TVL.z),
		GlSanKoor2fImport(0,1-ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+3]),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)],1));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
		GlSanKoorImport(TNP.x-r,TNP.y,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)],1-ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+3]),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+2],1));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
		TNP,
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+2],1-ArSkins[ActiveSkin].ArRealWindow2[Low(ArSkins[ActiveSkin].ArRealWindow2)+3]),
		GlSanKoor2fImport(1,1));
	end;

{Отключаем текстуры}
glDisable(GL_TEXTURE_2D);
end;

procedure GlSanDrawComponent9Tittle(const TVL,TNP:GlSanKoor; const r:real; const ActiveWnd:boolean);
begin
{Включаем текстуры}
glEnable(GL_TEXTURE_2D);
{Устанавливаем активную текстуру}
if ActiveWnd then 
	begin
	glBindTexture(GL_TEXTURE_2D,ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].WindowTexture3]);
	WndSomeQuad(TVL,
		GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
		GlSanKoor2fImport(0,0),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)],ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+1]));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y,TVL.z),
		GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)],0),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+2],ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+1]));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y,TVL.z),
		GlSanKoorImport(TNP.x,TVL.y-R,TVL.z),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+2],0),
		GlSanKoor2fImport(1,ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+1]));
	WndSomeQuad(GlSanKoorImport(TVL.x,TVL.y-R,TVL.z),
		GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
		GlSanKoor2fImport(0,ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+1]),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)],1-ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+3]));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
		GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)],ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+1]),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+2],1-ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+3]));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
		GlSanKoorImport(TNP.x,TNP.y+R,TVL.z),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+2],ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+1]),
		GlSanKoor2fImport(1,1-ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+3]));
	WndSomeQuad(GlSanKoorImport(TVL.x,TNP.y+R,TVL.z),
		GlSanKoorImport(TVL.x+r,TNP.y,TVL.z),
		GlSanKoor2fImport(0,1-ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+3]),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)],1));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
		GlSanKoorImport(TNP.x-r,TNP.y,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)],1-ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+3]),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+2],1));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
		TNP,
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+2],1-ArSkins[ActiveSkin].ArRealWindow3[Low(ArSkins[ActiveSkin].ArRealWindow3)+3]),
		GlSanKoor2fImport(1,1));
	end
else 
	begin
	glBindTexture(GL_TEXTURE_2D,ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].WindowTexture4]);
	WndSomeQuad(TVL,
		GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
		GlSanKoor2fImport(0,0),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)],ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+1]));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y,TVL.z),
		GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)],0),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+2],ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+1]));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y,TVL.z),
		GlSanKoorImport(TNP.x,TVL.y-R,TVL.z),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+2],0),
		GlSanKoor2fImport(1,ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+1]));
	WndSomeQuad(GlSanKoorImport(TVL.x,TVL.y-R,TVL.z),
		GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
		GlSanKoor2fImport(0,ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+1]),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)],1-ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+3]));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
		GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)],ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+1]),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+2],1-ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+3]));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
		GlSanKoorImport(TNP.x,TNP.y+R,TVL.z),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+2],ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+1]),
		GlSanKoor2fImport(1,1-ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+3]));
	WndSomeQuad(GlSanKoorImport(TVL.x,TNP.y+R,TVL.z),
		GlSanKoorImport(TVL.x+r,TNP.y,TVL.z),
		GlSanKoor2fImport(0,1-ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+3]),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)],1));
	WndSomeQuad(GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
		GlSanKoorImport(TNP.x-r,TNP.y,TVL.z),
		GlSanKoor2fImport(ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)],1-ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+3]),
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+2],1));
	WndSomeQuad(GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
		TNP,
		GlSanKoor2fImport(1-ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+2],1-ArSkins[ActiveSkin].ArRealWindow4[Low(ArSkins[ActiveSkin].ArRealWindow4)+3]),
		GlSanKoor2fImport(1,1));
	end;
{Отключаем текстуры}
glDisable(GL_TEXTURE_2D);
end;

procedure GlSanDrawComponent9(const TVL,TNP:GlSanKoor; const r:real; const ots1,ots2,ots3,ots4:real; const IDText:GLUInt);
begin
{Включаем текстуры}
glEnable(GL_TEXTURE_2D);
{Устанавливаем активную текстуру}
glBindTexture(GL_TEXTURE_2D,IDText);
WndSomeQuad(TVL,
	GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
	GlSanKoor2fImport(0,0),
	GlSanKoor2fImport(ots1,ots2));
WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y,TVL.z),
	GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
	GlSanKoor2fImport(ots1,0),
	GlSanKoor2fImport(1-ots3,ots2));
WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y,TVL.z),
	GlSanKoorImport(TNP.x,TVL.y-R,TVL.z),
	GlSanKoor2fImport(1-ots3,0),
	GlSanKoor2fImport(1,ots2));
WndSomeQuad(GlSanKoorImport(TVL.x,TVL.y-R,TVL.z),
	GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
	GlSanKoor2fImport(0,ots2),
	GlSanKoor2fImport(ots1,1-ots4));
WndSomeQuad(GlSanKoorImport(TVL.x+r,TVL.y-R,TVL.z),
	GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
	GlSanKoor2fImport(ots1,ots2),
	GlSanKoor2fImport(1-ots3,1-ots4));
WndSomeQuad(GlSanKoorImport(TNP.x-r,TVL.y-R,TVL.z),
	GlSanKoorImport(TNP.x,TNP.y+R,TVL.z),
	GlSanKoor2fImport(1-ots3,ots2),
	GlSanKoor2fImport(1,1-ots4));
WndSomeQuad(GlSanKoorImport(TVL.x,TNP.y+R,TVL.z),
	GlSanKoorImport(TVL.x+r,TNP.y,TVL.z),
	GlSanKoor2fImport(0,1-ots4),
	GlSanKoor2fImport(ots1,1));
WndSomeQuad(GlSanKoorImport(TVL.x+r,TNP.y+R,TVL.z),
	GlSanKoorImport(TNP.x-r,TNP.y,TVL.z),
	GlSanKoor2fImport(ots1,1-ots4),
	GlSanKoor2fImport(1-ots3,1));
WndSomeQuad(GlSanKoorImport(TNP.x-r,TNP.y+R,TVL.z),
	TNP,
	GlSanKoor2fImport(1-ots3,1-ots4),
	GlSanKoor2fImport(1,1));
{Отключаем текстуры}
glDisable(GL_TEXTURE_2D);
end;

procedure GlSanWnd.Init(const z:longint);
var
	razn:GlsanKoor2f;
	Koor:GlSanKoor;
	VL,NP,NZP:GlSanKoor;
	i:real;
	TextZum:real;
	ii:longint;
begin
{$NOTE GlSanWnd.Init}
{Извлечение координат окна...}
if GlSanWAKol-z+1<=0 then
	begin
	razn.x:=abs((GlSanWA[0,1].x-GlSanWA[0,2].x));
	razn.y:=abs((GlSanWA[0,1].y-GlSanWA[0,3].y));
	VL.x:=GlSanWA[0,1].x+razn.x*OVL.x;
	VL.y:=GlSanWA[0,1].y-razn.y*OVL.y;
	VL.z:=GlSanWA[0,1].z;
	NP.x:=GlSanWA[0,1].x+razn.x*ONP.x;
	NP.y:=GlSanWA[0,1].y-razn.y*ONP.y;
	NP.z:=GlSanWA[0,1].z;
	NZP.x:=GlSanWA[0,1].x+razn.x*ONZP.x;
	NZP.y:=GlSanWA[0,1].y-razn.y*ONZP.y;
	NZP.z:=GlSanWA[0,1].z;
	end
else
	begin
	razn.x:=abs((GlSanWA[GlSanWAKol-z+1,1].x-GlSanWA[GlSanWAKol-z+1,2].x));
	razn.y:=abs((GlSanWA[GlSanWAKol-z+1,1].y-GlSanWA[GlSanWAKol-z+1,3].y));
	VL.x:=GlSanWA[GlSanWAKol-z+1,1].x+razn.x*OVL.x;
	VL.y:=GlSanWA[GlSanWAKol-z+1,1].y-razn.y*OVL.y;
	VL.z:=GlSanWA[GlSanWAKol-z+1,1].z;
	NP.x:=GlSanWA[GlSanWAKol-z+1,1].x+razn.x*ONP.x;
	NP.y:=GlSanWA[GlSanWAKol-z+1,1].y-razn.y*ONP.y;
	NP.z:=GlSanWA[GlSanWAKol-z+1,1].z;
	NZP.x:=GlSanWA[GlSanWAKol-z+1,1].x+razn.x*ONZP.x;
	NZP.y:=GlSanWA[GlSanWAKol-z+1,1].y-razn.y*ONZP.y;
	NZP.z:=GlSanWA[GlSanWAKol-z+1,1].z;
	end;
TVL.Togever(TVL);TVL.Togever(TVL);TVL.Togever(TVL);TVL.Togever(VL);TVL.Zum(1/9);
TNP.Togever(TNP);TNP.Togever(TNP);TNP.Togever(TNP);TNP.Togever(NP);TNP.Zum(1/9);
TNZP.Togever(TNZP);TNZP.Togever(TNZP);TNZP.Togever(TNZP);TNZP.Togever(NZP);TNZP.Zum(1/9);
TNP.z:=NP.z;TVL.z:=VL.Z;TNZP.z:=NZP.z;
TextZum:=(GlSanRast(TNZP,GlSanKoorImport(TNZP.x,TVL.y,TVL.z))*0.65)/2;
{Если это окно было закрыто недавно, то...}
if ExitP then
	al:=al-1/10
else
	if 1/(sqr(GlSAnrast(TNZP,NZP)/(razn.y*0.25)))>1 then
		al:=1
	else
		al:=1/(sqr(GlSAnrast(TNZP,NZP)/(razn.y*0.25)));
if TeloP then
	begin
	if (ActiveSkin=-1) or ((z=Length(GlSanWinds)) and (ArSkins[ActiveSkin].WindowTexture1=-1)) or
		((z<>Length(GlSanWinds)) and (ArSkins[ActiveSkin].WindowTexture2=-1)) then 
		begin
		if z=Length(GlSanWinds) then ColorsF[1].SanSetColorA(al) else ColorsS[1].SanSetColorA(al);
		GlSanRoundQuad(TVL,TNP,RadOkr,8);
		end
	else
		begin
		case ArSkins[ActiveSkin].WindowTip of
		0:
			begin
			if z=Length(GlSanWinds) then ArSkins[ActiveSkin].ArWindowTextureColor[1].SanSetColorA(al)
			else ArSkins[ActiveSkin].ArWindowTextureColor[2].SanSetColorA(al);
			GlSanDrawComponent9(TVL,TNP,RadOkr,z=Length(GlSanWinds));
			end;
		end;
		end;
	end;
if ZagP then
	begin
	if (ActiveSkin=-1) or ((z=Length(GlSanWinds)) and (ArSkins[ActiveSkin].WindowTexture3=-1)) or 
		((z<>Length(GlSanWinds)) and (ArSkins[ActiveSkin].WindowTexture4=-1))then
		begin
		if z=Length(GlSanWinds) then ColorsF[2].SanSetColora(al) else ColorsS[2].SanSetColora(al);
		GlSanRoundQuad(TVL,TNZP,RadOkr,8);
		end
	else
		begin
		case ArSkins[ActiveSkin].WindowTip of
		0:
			begin
			if z=Length(GlSanWinds) then ArSkins[ActiveSkin].ArWindowTextureColor[3].SanSetColorA(al)
			else ArSkins[ActiveSkin].ArWindowTextureColor[4].SanSetColorA(al);
			GlSanDrawComponent9Tittle(TVL,TNZP,GetRadOkr(TVL,TNZP,RadOkr),z=Length(GlSanWinds));
			end;
		end;
		end;
	end;
if TeloP and ((ActiveSkin=-1) or ((z=Length(GlSanWinds)) and (ArSkins[ActiveSkin].WindowTexture1=-1)) or
		((z<>Length(GlSanWinds)) and (ArSkins[ActiveSkin].WindowTexture2=-1))) then
	begin
	if z=Length(GlSanWinds) then ColorsF[3].SanSetColora(al) else ColorsS[3].SanSetColora(al);
	GlSanRoundQuadLines(TVL,TNP,RadOkr,8);
	end;
if ZagP and ((ActiveSkin=-1) or ((z=Length(GlSanWinds)) and (ArSkins[ActiveSkin].WindowTexture3=-1)) or 
		((z<>Length(GlSanWinds)) and (ArSkins[ActiveSkin].WindowTexture4=-1))) then
	begin
	if z=Length(GlSanWinds) then ColorsF[4].SanSetColora(al) else ColorsS[4].SanSetColora(al);
	GlSanRoundQuadLines(TVL,TNZP,RadOkr,8);
	end;
if ZagP then
	begin
	if z=Length(GlSanWinds) then ColorsF[5].SanSetColora(al) else ColorsS[5].SanSetColora(al);
	Koor:=GlSanSredKoor(TVl,TNZP);
	if GlSanTextLength(Tittle,textZum)<GlSanRast(TVL,GlSanKoorImport(TNZP.x,TVL.y,TVL.z))*0.92 then i:=TextZum
	else i:=TextZum*(GlSanRast(TVL,GlSanKoorImport(TNZP.x,TVL.y,TVL.z))/GlSanTextLength(Tittle,textZum))*0.92;
	GlSanOutTextS(Koor,Tittle,GlSanKoor2fImport(TextZum,i));
	end;
for ii:=Low(ArImage) to High(ArImage) do
	ArImage[ii].Init(TVL,TNP,z=Length(GlSanWinds),al);
for ii:=Low(ArConsole) to High(ArConsole) do
	ArConsole[ii].Init(TVL,TNP,z=Length(GlSanWinds),al);
if z=Length(GlSanWinds) then ColorsF[6].SanSetColora(al) else ColorsS[6].SanSetColora(al);
for ii:=Low(ArButtons) to High(ArButtons) do
	if z=Length(GlSanWinds) then ArButtons[ii].Init(TVL,TNP,true,al) else ArButtons[ii].Init(TVL,TNP,false,al);
for ii:=low(ArListBox) to High(ArListBox) do
	if z=Length(GlSanWinds) then ArListBox[ii].Init(TVL,TNP,true,al) else ArListBox[ii].Init(TVL,TNP,false,al);
for ii:=low(ArProgressBar) to High(ArProgressBar) do
	if z=Length(GlSanWinds) then ArProgressBar[ii].Init(TVL,TNP,true,al) else ArProgressBar[ii].Init(TVL,TNP,false,al);
for ii:=Low(ArText) to High(ArText) do
	if z=Length(GlSanWinds) then ArText[ii].Init(TVL,TNP,true,al) else ArText[ii].Init(TVL,TNP,false,al);
for ii:=Low(ArEdit) to High(ArEdit) do
	ArEdit[ii].Init(TVL,TNP,z=Length(GlSanWinds),al);
for ii:=Low(ArCheckBox) to High(ArCheckBox) do
	ArCheckBox[ii].Init(TVL,TNP,z=Length(GlSanWinds),al);
for ii:=Low(ArComboBox) to High(ArComboBox) do
	ArComboBox[ii].Init(TVL,TNP,z=Length(GlSanWinds),al);
end;

function GlSanSredKoor(const a,b:GlSanKoor):GlSanKoor;
begin
GlSanSredKoor.x:=(a.x+b.x)/2;
GlSanSredKoor.y:=(a.y+b.y)/2;
GlSanSredKoor.z:=(a.z+b.z)/2;
end;
function GlSanGetFontNumber(Name:string):longint;
var i,ii:longint;
begin
Name:=Name;
i:=-1;
for ii:=Low(ArFonts) to High(ArFonts)do
	if (Name=ArFonts[ii].Name) then
		i:=ii;
GlSanGetFontNumber:=i;
end;
procedure GlSanLoadFont(Name:string);
var f:text;
	c:char;
	i:longint;
	NameWithoutIndex,number:string;
	IDT:GLUint;
begin
NameWithoutIndex:='';
for i:=1 to length(name)-4 do
	NameWithoutIndex+=Name[i];
if fail_est('Fonts\'+NameWithoutIndex+'.bmp') then
	IDT:=GlSanLoadTexture('Fonts\'+NameWithoutIndex+'.bmp')
else
	begin
	if fail_est('Fonts\'+NameWithoutIndex+'.tga') then
		begin
		IDT:=GlSanLoadTexture('Fonts\'+NameWithoutIndex+'.tga')
		end
	else
		begin
		if fail_est('Fonts\'+NameWithoutIndex+'.png') then
			begin
			IDT:=GlSanLoadTexture('Fonts\'+NameWithoutIndex+'.png');
			end
		else
			begin
			if fail_est('Fonts\'+NameWithoutIndex+'.jpg') then
				begin
				IDT:=GlSanLoadTexture('Fonts\'+NameWithoutIndex+'.jpg')
				end
			else
				begin
				if fail_est('Fonts\'+NameWithoutIndex+'.tif') then
					begin
					IDT:=GlSanLoadTexture('Fonts\'+NameWithoutIndex+'.tif')
					end
				else
					begin
					if fail_est('Fonts\'+NameWithoutIndex+'.tiff') then
						begin
						IDT:=GlSanLoadTexture('Fonts\'+NameWithoutIndex+'.tiff')
						end
					else
						begin
						writeln('Don`t may by install font "'+NameWithoutIndex+'"!');
						end;
					end;
				end;
			end;
		end;
	end;
SetLength(ArFonts,length(ArFonts)+1);
ArFonts[high(ArFonts)].ID:=IDT;
ArFonts[high(ArFonts)].Name:=NameWithoutIndex;
assign(f,'Fonts\'+NameWithoutIndex+'.ssf');
reset(f);
for i:=1 to 5 do
	readln(f);
read(f,c);
while c<>'='do
	read(f,c);
readln(f,ArFonts[high(ArFonts)].Height);
for i:=1 to 4 do
	readln(f);
read(f,c);
while c<>'='do
	read(f,c);
readln(f,ArFonts[high(ArFonts)].TW);
read(f,c);
while c<>'='do
	read(f,c);
readln(f,ArFonts[high(ArFonts)].TH);
for i:=1 to 4 do
	readln(f);
while not eof(f)do
	begin
	readln(f,NameWithoutIndex);
	c:=NameWithoutIndex[1];
	number:='';
	i:=3;
	while NameWithoutIndex[i]<>','do
		begin
		number+=NameWithoutIndex[i];
		i+=1;
		end;
	ArFonts[high(ArFonts)].ArChar[ord(c)].x:=StrToInt(number);
	number:='';
	i+=1;
	while NameWithoutIndex[i]<>','do
		begin
		number+=NameWithoutIndex[i];
		i+=1;
		end;
	ArFonts[high(ArFonts)].ArChar[ord(c)].y:=StrToInt(number);
	number:='';
	i+=1;
	while i<=length(NameWithoutIndex) do
		begin
		number+=NameWithoutIndex[i];
		i+=1;
		end;
	ArFonts[high(ArFonts)].ArChar[ord(c)].width:=StrToInt(number);
	end;
close(f);
end;
procedure GlSanInstallSkin(const way:string);
var
	f:text;
	str:string;
	c:char;
	endstr:boolean = false;
	i:longint = 0;
begin
if fail_est('Skins\'+way+'\config.cfg') then
	begin
	SetLength(ArSkins,Length(ArSkins)+1);
	ArSkins[High(ArSkins)].WindowTip:=-1;
	ArSkins[High(ArSkins)].ButtonTip:=-1;
	ArSkins[High(ArSkins)].Name:=way;
	SetLength(ArSkins[High(ArSkins)].ArTextures,0);
	SetLength(ArSkins[High(ArSkins)].ArRealWindow1,0);
	SetLength(ArSkins[High(ArSkins)].ArRealWindow2,0);
	SetLength(ArSkins[High(ArSkins)].ArRealWindow3,0);
	SetLength(ArSkins[High(ArSkins)].ArRealWindow4,0);
	SetLength(ArSkins[High(ArSkins)].ArRealButton1,0);
	SetLength(ArSkins[High(ArSkins)].ArRealButton2,0);
	SetLength(ArSkins[High(ArSkins)].ArRealButton3,0);
	SetLength(ArSkins[High(ArSkins)].ArRealButton4,0);
	SetLength(ArSkins[High(ArSkins)].ArRealHint,0);
	SetLength(ArSkins[High(ArSkins)].ArRealContextMenu1,0);
	SetLength(ArSkins[High(ArSkins)].ArRealContextMenu2,0);
	SetLength(ArSkins[High(ArSkins)].ArRealContextMenu3,0);
	SetLength(ArSkins[High(ArSkins)].ArRealContextMenu5,0);
	SetLength(ArSkins[High(ArSkins)].ArRealComboBox1,0);
	SetLength(ArSkins[High(ArSkins)].ArRealComboBox2,0);
	SetLength(ArSkins[High(ArSkins)].ArRealComboBox3,0);
	SetLength(ArSkins[High(ArSkins)].ArRealComboBox4,0);
	SetLength(ArSkins[High(ArSkins)].ArCheckBoxKoorTextures,0);
	ArSkins[High(ArSkins)].WindowTexture1:=-1;
	ArSkins[High(ArSkins)].WindowTexture2:=-1;
	ArSkins[High(ArSkins)].ButtonTexture1:=-1;
	ArSkins[High(ArSkins)].ButtonTexture2:=-1;
	ArSkins[High(ArSkins)].ButtonTexture3:=-1;
	ArSkins[High(ArSkins)].HintTexture:=-1;
	ArSkins[High(ArSkins)].ContextMenuTexture1:=-1;
	ArSkins[High(ArSkins)].ContextMenuTexture2:=-1;
	ArSkins[High(ArSkins)].ContextMenuTexture3:=-1;
	ArSkins[High(ArSkins)].ContextMenuTexture4:=-1;
	ArSkins[High(ArSkins)].ContextMenuTexture5:=-1;
	ArSkins[High(ArSkins)].CheckBoxTexture1:=-1;
	ArSkins[High(ArSkins)].CheckBoxTexture2:=-1;
	ArSkins[High(ArSkins)].CheckBoxTexture3:=-1;
	ArSkins[High(ArSkins)].CheckBoxTexture4:=-1;
	ArSkins[High(ArSkins)].ComboBoxTexture1:=-1;
	ArSkins[High(ArSkins)].ComboBoxTexture2:=-1;
	ArSkins[High(ArSkins)].ComboBoxTexture3:=-1;
	ArSkins[High(ArSkins)].ComboBoxTexture4:=-1;
	ArSkins[High(ArSkins)].ComboBoxTexture5:=-1;
	for i:=Low(ArSkins[High(ArSkins)].ArWindowTextureColor) to high(ArSkins[High(ArSkins)].ArWindowTextureColor) do
		ArSkins[High(ArSkins)].ArWindowTextureColor[i].Import(1,1,1,0.7);
	for i:=Low(ArSkins[High(ArSkins)].ArButtonTextureColor) to high(ArSkins[High(ArSkins)].ArButtonTextureColor) do
		ArSkins[High(ArSkins)].ArButtonTextureColor[i].Import(1,1,1,0.7);
	ArSkins[High(ArSkins)].ArHintTextureColor[1].Import(1,1,1,0.8);
	ArSkins[High(ArSkins)].ArHintTextureColor[2]:=ArSkins[High(ArSkins)].ArHintTextureColor[1].Negative;
	for i:=Low(ArSkins[High(ArSkins)].ArContextMenuTextureColor) to High(ArSkins[High(ArSkins)].ArContextMenuTextureColor) do
		ArSkins[High(ArSkins)].ArContextMenuTextureColor[i].Import(1,1,1,0.8);
	for i:=Low(ArSkins[High(ArSkins)].ArComboBoxTextureColor) to High(ArSkins[High(ArSkins)].ArComboBoxTextureColor) do
		ArSkins[High(ArSkins)].ArComboBoxTextureColor[i].Import(1,1,1,0.78);
	assign(f,'Skins\'+way+'\config.cfg');
	reset(f);
	while not seekeof(f) do
		begin
		EndStr:=false;
		read(f,c);
		while (c<>'[') and (not seekeoln(f)) do
			begin
			read(f,c);
			if seekeoln(f) then
				EndStr:=true;
			end;
		if not EndStr then
			begin
			Str:='';
			read(f,c);
			while (c<>']') and (not seekeoln(f)) do
				begin
				str+=c;
				read(f,c);
				if (c<>']') and seekeoln(f) then
					EndStr:=true;
				end;
			readln(f);
			if not EndStr then
				begin
				Str:=GlSanUpCaseString(Str);
				if (str='WINDOWTEXTURE1') or (str='WNDTEXTURE1') then
					begin
					readln(f,str);
					SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
					ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
						GlSanLoadTexture('Skins\'+way+'\'+str);
					ArSkins[High(ArSkins)].WindowTexture1:=High(ArSkins[High(ArSkins)].ArTextures);
					end
				else
					begin
					if (str='WINDOWTEXTURE2') or (str='WNDTEXTURE2') then
						begin
						readln(f,str);
						SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
						ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
							GlSanLoadTexture('Skins\'+way+'\'+str);
						ArSkins[High(ArSkins)].WindowTexture2:=High(ArSkins[High(ArSkins)].ArTextures);
						end
					else
						begin
						if (str='BUTTONTEXTURE1') or (str='BTNTEXTURE1') then
							begin
							readln(f,str);
							SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
							ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
								GlSanLoadTexture('Skins\'+way+'\'+str);
							ArSkins[High(ArSkins)].ButtonTexture1:=High(ArSkins[High(ArSkins)].ArTextures);
							end
						else
							begin
							if (str='TYPEWINDOWTEXTURE') or (str='TIPWINDOWTEXTURE') or (str='TIPWNDTEXTURE') or (str='TIPWNDTEXTURE') then
								begin
								readln(f,ArSkins[High(ArSkins)].WindowTip);
								end
							else
								begin
								if (str='ARREALWINDOW1') or (str='SETARREALWINDOW1') or (str='SETARREALMEMBERWINDOW1') or (str='WINDOWMEMBERARREAL') then
									begin
									while not seekeoln(f) do
										begin
										SetLength(ArSkins[High(ArSkins)].ArRealWindow1,Length(ArSkins[High(ArSkins)].ArRealWindow1)+1);
										read(f,ArSkins[High(ArSkins)].ArRealWindow1[High(ArSkins[High(ArSkins)].ArRealWindow1)]);
										end;
									readln(f);
									end
								else
									begin
									if (str='WINDOWTEXTURE3') or (str='WNDTEXTURE3') then
										begin
										readln(f,str);
										SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
										ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
											GlSanLoadTexture('Skins\'+way+'\'+str);
										ArSkins[High(ArSkins)].WindowTexture3:=High(ArSkins[High(ArSkins)].ArTextures);
										end
									else
										begin
										if (str='WINDOWTEXTURE4') or (str='WNDTEXTURE4') then
											begin
											readln(f,str);
											SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
											ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
												GlSanLoadTexture('Skins\'+way+'\'+str);
											ArSkins[High(ArSkins)].WindowTexture4:=High(ArSkins[High(ArSkins)].ArTextures);
											end
										else
											begin
											if (str='BUTTONTEXTURE4') or (str='BTNTEXTURE4') then
												begin
												readln(f,str);
												SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
												ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
													GlSanLoadTexture('Skins\'+way+'\'+str);
												ArSkins[High(ArSkins)].ButtonTexture4:=High(ArSkins[High(ArSkins)].ArTextures);
												end
											else
												begin
												if (str='BUTTONTEXTURE2') or (str='BTNTEXTURE2') then
													begin
													readln(f,str);
													SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
													ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
														GlSanLoadTexture('Skins\'+way+'\'+str);
													ArSkins[High(ArSkins)].ButtonTexture2:=High(ArSkins[High(ArSkins)].ArTextures);
													end
												else
													begin
													if (str='BUTTONTEXTURE3') or (str='BTNTEXTURE3') then
														begin
														readln(f,str);
														SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
														ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
															GlSanLoadTexture('Skins\'+way+'\'+str);
														ArSkins[High(ArSkins)].ButtonTexture3:=High(ArSkins[High(ArSkins)].ArTextures);
														end
													else
														begin
														if (str='ARREALWINDOW2') or (str='SETARREALWINDOW2') or (str='SETARREALMEMBERWINDOW2') or (str='WINDOW2MEMBERARREAL') then
															begin
															while not seekeoln(f) do
																begin
																SetLength(ArSkins[High(ArSkins)].ArRealWindow2,Length(ArSkins[High(ArSkins)].ArRealWindow2)+1);
																read(f,ArSkins[High(ArSkins)].ArRealWindow2[High(ArSkins[High(ArSkins)].ArRealWindow2)]);
																end;
															readln(f);
															end
														else
															begin
															if (str='ARREALWINDOW3') or (str='SETARREALWINDOW3') or (str='SETARREALMEMBERWINDOW3') or (str='WINDOW3MEMBERARREAL') then
																begin
																while not seekeoln(f) do
																	begin
																	SetLength(ArSkins[High(ArSkins)].ArRealWindow3,Length(ArSkins[High(ArSkins)].ArRealWindow3)+1);
																	read(f,ArSkins[High(ArSkins)].ArRealWindow3[High(ArSkins[High(ArSkins)].ArRealWindow3)]);
																	end;
																readln(f);
																end
															else
																begin
																if (str='ARREALWINDOW4') or (str='SETARREALWINDOW4') or (str='SETARREALMEMBERWINDOW4') or (str='WINDOW4MEMBERARREAL') then
																	begin
																	while not seekeoln(f) do
																		begin
																		SetLength(ArSkins[High(ArSkins)].ArRealWindow4,Length(ArSkins[High(ArSkins)].ArRealWindow4)+1);
																		read(f,ArSkins[High(ArSkins)].ArRealWindow4[High(ArSkins[High(ArSkins)].ArRealWindow4)]);
																		end;
																	readln(f);
																	end
																else
																	begin
																	if (str='ARREALBUTTON1') or (str='SETARREALBUTTON1') or (str='SETARREALMEMBERBUTTON1') or (str='BUTTON1MEMBERARREAL') then
																		begin
																		while not seekeoln(f) do
																			begin
																			SetLength(ArSkins[High(ArSkins)].ArRealButton1,Length(ArSkins[High(ArSkins)].ArRealButton1)+1);
																			read(f,ArSkins[High(ArSkins)].ArRealButton1[High(ArSkins[High(ArSkins)].ArRealButton1)]);
																			end;
																		readln(f);
																		end
																	else
																		begin
																		if (str='ARREALBUTTON2') or (str='SETARREALBUTTON2') or (str='SETARREALMEMBERBUTTON2') or (str='BUTTON2MEMBERARREAL') then
																			begin
																			while not seekeoln(f) do
																				begin
																				SetLength(ArSkins[High(ArSkins)].ArRealButton2,Length(ArSkins[High(ArSkins)].ArRealButton2)+1);
																				read(f,ArSkins[High(ArSkins)].ArRealButton2[High(ArSkins[High(ArSkins)].ArRealButton2)]);
																				end;
																			readln(f);
																			end
																		else
																			begin
																			if (str='ARREALBUTTON3') or (str='SETARREALBUTTON3') or (str='SETARREALMEMBERBUTTON3') or (str='BUTTON3MEMBERARREAL') then
																				begin
																				while not seekeoln(f) do
																					begin
																					SetLength(ArSkins[High(ArSkins)].ArRealButton3,Length(ArSkins[High(ArSkins)].ArRealButton3)+1);
																					read(f,ArSkins[High(ArSkins)].ArRealButton3[High(ArSkins[High(ArSkins)].ArRealButton3)]);
																					end;
																				readln(f);
																				end
																			else
																				begin
																				if (str='ARREALBUTTON4') or (str='SETARREALBUTTON4') or (str='SETARREALMEMBERBUTTON4') or (str='BUTTON4MEMBERARREAL') then
																					begin
																					while not seekeoln(f) do
																						begin
																						SetLength(ArSkins[High(ArSkins)].ArRealButton4,Length(ArSkins[High(ArSkins)].ArRealButton4)+1);
																						read(f,ArSkins[High(ArSkins)].ArRealButton4[High(ArSkins[High(ArSkins)].ArRealButton4)]);
																						end;
																					readln(f);
																					end
																				else
																					begin
																					if (str='TYPEBUTTONTEXTURE') or (str='TIPBUTTONTEXTURE') or (str='TIPWNDTEXTURE') or (str='TIPWNDTEXTURE') then
																						begin
																						readln(f,ArSkins[High(ArSkins)].ButtonTip);
																						end
																					else
																						begin
																						if (str='SETCOLORBUTTONTEXTURE3') or (str='COLORBUTTONTEXTURE3') then
																							begin
																							ArSkins[High(ArSkins)].ArButtonTextureColor[3].ReadlnFromFile(@f);
																							end
																						else
																							begin
																							if (str='SETCOLORBUTTONTEXTURE1') or (str='COLORBUTTONTEXTURE1') then
																								begin
																								ArSkins[High(ArSkins)].ArButtonTextureColor[1].ReadlnFromFile(@f);
																								end
																							else
																								begin
																								if (str='SETCOLORBUTTONTEXTURE2') or (str='COLORBUTTONTEXTURE2') then
																									begin
																									ArSkins[High(ArSkins)].ArButtonTextureColor[2].ReadlnFromFile(@f);
																									end
																								else
																									begin
																									if (str='SETCOLORBUTTONTEXTURE4') or (str='COLORBUTTONTEXTURE4') then
																										begin
																										ArSkins[High(ArSkins)].ArButtonTextureColor[4].ReadlnFromFile(@f);
																										end
																									else
																										begin
																										if (str='SETCOLORWINDOWTEXTURE4') or (str='COLORWINDOWTEXTURE4') then
																											begin
																											ArSkins[High(ArSkins)].ArWindowTextureColor[4].ReadlnFromFile(@f);
																											end
																										else
																											begin
																											if (str='SETCOLORWINDOWTEXTURE1') or (str='COLORWINDOWTEXTURE1') then
																												begin
																												ArSkins[High(ArSkins)].ArWindowTextureColor[1].ReadlnFromFile(@f);
																												end
																											else
																												begin
																												if (str='SETCOLORWINDOWTEXTURE2') or (str='COLORWINDOWTEXTURE2') then
																													begin
																													ArSkins[High(ArSkins)].ArWindowTextureColor[2].ReadlnFromFile(@f);
																													end
																												else
																													begin
																													if (str='SETCOLORWINDOWTEXTURE3') or (str='COLORWINDOWTEXTURE3') then
																														begin
																														ArSkins[High(ArSkins)].ArWindowTextureColor[3].ReadlnFromFile(@f);
																														end
																													else
																														begin
																														if (str='SETCOLORHINTTEXTURE1') or (str='COLORHINTTEXTURE1') then
																															begin
																															ArSkins[High(ArSkins)].ArHintTextureColor[1].ReadlnFromFile(@f);
																															end
																														else
																															begin
																															if (str='SETCOLORHINTTEXTURE2') or (str='COLORHINTTEXTURE2') then
																																begin
																																ArSkins[High(ArSkins)].ArHintTextureColor[2].ReadlnFromFile(@f);
																																end
																															else
																																begin
																																if (str='HINTTEXTURE') or (str='SETHINTTEXTURE') or (str='HTEXTURE') then
																																	begin
																																	readln(f,str);
																																	SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
																																	ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
																																		GlSanLoadTexture('Skins\'+way+'\'+str);
																																	ArSkins[High(ArSkins)].HintTexture:=High(ArSkins[High(ArSkins)].ArTextures);
																																	end
																																else
																																	begin
																																	if (str='ARREALHINT') or (str='SETARREALHINT') or (str='SETARREALMEMBERHINT') or (str='HINTMEMBERARREAL') then
																																		begin
																																		while not seekeoln(f) do
																																			begin
																																			SetLength(ArSkins[High(ArSkins)].ArRealHint,Length(ArSkins[High(ArSkins)].ArRealHint)+1);
																																			read(f,ArSkins[High(ArSkins)].ArRealHint[High(ArSkins[High(ArSkins)].ArRealHint)]);
																																			end;
																																		readln(f);
																																		end
																																	else
																																		begin
																																		if (str='ARREALCONTEXTMENU1') or (str='SETARREALCONTEXTMENU1') or (str='SETARREALMEMBERCONTEXTMENU1') or (str='CONTEXTMENU1MEMBERARREAL') then
																																			begin
																																			while not seekeoln(f) do
																																				begin
																																				SetLength(ArSkins[High(ArSkins)].ArRealContextMenu1,Length(ArSkins[High(ArSkins)].ArRealContextMenu1)+1);
																																				read(f,ArSkins[High(ArSkins)].ArRealContextMenu1[High(ArSkins[High(ArSkins)].ArRealContextMenu1)]);
																																				end;
																																			readln(f);
																																			end
																																		else
																																			begin
																																			if (str='CONTEXTMENUTEXTURE1') or (str='SETCONTEXTMENUTEXTURE1') or (str='CONTEXTMENUTEXTURE1') then
																																				begin
																																				readln(f,str);
																																				SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
																																				ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
																																					GlSanLoadTexture('Skins\'+way+'\'+str);
																																				ArSkins[High(ArSkins)].ContextMenuTexture1:=High(ArSkins[High(ArSkins)].ArTextures);
																																				end
																																			else
																																				begin
																																				if (str='CHECKBOXTEXTURE1') or (str='SETCHECKBOXTEXTURE1') or (str='CHECKBOXTEXTURE1') then
																																					begin
																																					readln(f,str);
																																					SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
																																					ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
																																						GlSanLoadTexture('Skins\'+way+'\'+str);
																																					ArSkins[High(ArSkins)].CheckBoxTexture1:=High(ArSkins[High(ArSkins)].ArTextures);
																																					end
																																				else
																																					begin
																																					if (str='CHECKBOXTEXTURE2') or (str='SETCHECKBOXTEXTURE2') or (str='CHECKBOXTEXTURE2') then
																																						begin
																																						readln(f,str);
																																						SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
																																						ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
																																							GlSanLoadTexture('Skins\'+way+'\'+str);
																																						ArSkins[High(ArSkins)].CheckBoxTexture2:=High(ArSkins[High(ArSkins)].ArTextures);
																																						end
																																					else
																																						begin
																																						if (str='ARREALCONTEXTMENU2') or (str='SETARREALCONTEXTMENU2') or (str='SETARREALMEMBERCONTEXTMENU2') or (str='CONTEXTMENU2MEMBERARREAL') then
																																							begin
																																							while not seekeoln(f) do
																																								begin
																																								SetLength(ArSkins[High(ArSkins)].ArRealContextMenu2,Length(ArSkins[High(ArSkins)].ArRealContextMenu2)+1);
																																								read(f,ArSkins[High(ArSkins)].ArRealContextMenu2[High(ArSkins[High(ArSkins)].ArRealContextMenu2)]);
																																								end;
																																							readln(f);
																																							end
																																						else
																																							begin
																																							if (str='CONTEXTMENUTEXTURE2') or (str='SETCONTEXTMENUTEXTURE2') or (str='CONTEXTMENUTEXTURE2') then
																																								begin
																																								readln(f,str);
																																								SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
																																								ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
																																									GlSanLoadTexture('Skins\'+way+'\'+str);
																																								ArSkins[High(ArSkins)].ContextMenuTexture2:=High(ArSkins[High(ArSkins)].ArTextures);
																																								end
																																							else
																																								begin
																																								if (str='ARREALCONTEXTMENU3') or (str='SETARREALCONTEXTMENU3') or (str='SETARREALMEMBERCONTEXTMENU3') or (str='CONTEXTMENU3MEMBERARREAL') then
																																									begin
																																									while not seekeoln(f) do
																																										begin
																																										SetLength(ArSkins[High(ArSkins)].ArRealContextMenu3,Length(ArSkins[High(ArSkins)].ArRealContextMenu3)+1);
																																										read(f,ArSkins[High(ArSkins)].ArRealContextMenu3[High(ArSkins[High(ArSkins)].ArRealContextMenu3)]);
																																										end;
																																									readln(f);
																																									end
																																								else
																																									begin
																																									if (str='CONTEXTMENUTEXTURE3') or (str='SETCONTEXTMENUTEXTURE3') or (str='CONTEXTMENUTEXTURE3') then
																																										begin
																																										readln(f,str);
																																										SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
																																										ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
																																											GlSanLoadTexture('Skins\'+way+'\'+str);
																																										ArSkins[High(ArSkins)].ContextMenuTexture3:=High(ArSkins[High(ArSkins)].ArTextures);
																																										end
																																									else
																																										begin
																																										if (str='CONTEXTMENUTEXTURE4') or (str='SETCONTEXTMENUTEXTURE4') or (str='CONTEXTMENUTEXTURE4') then
																																											begin
																																											readln(f,str);
																																											SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
																																											ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
																																												GlSanLoadTexture('Skins\'+way+'\'+str);
																																											ArSkins[High(ArSkins)].ContextMenuTexture4:=High(ArSkins[High(ArSkins)].ArTextures);
																																											end
																																										else
																																											begin
																																											if (str='SETCOLORCONTEXTMENUTEXTURE1') or (str='COLORCONTEXTMENUTEXTURE1') then
																																												begin
																																												ArSkins[High(ArSkins)].ArContextMenuTextureColor[1].ReadlnFromFile(@f);
																																												end
																																											else
																																												begin
																																												if (str='SETCOLORCONTEXTMENUTEXTURE2') or (str='COLORCONTEXTMENUTEXTURE2') then
																																													begin
																																													ArSkins[High(ArSkins)].ArContextMenuTextureColor[2].ReadlnFromFile(@f);
																																													end
																																												else
																																													begin
																																													if (str='SETCOLORCONTEXTMENUTEXTURE3') or (str='COLORCONTEXTMENUTEXTURE3') then
																																														begin
																																														ArSkins[High(ArSkins)].ArContextMenuTextureColor[3].ReadlnFromFile(@f);
																																														end
																																													else
																																														begin
																																														if (str='SETCOLORCONTEXTMENUTEXTURE4') or (str='COLORCONTEXTMENUTEXTURE4') then
																																															begin
																																															ArSkins[High(ArSkins)].ArContextMenuTextureColor[4].ReadlnFromFile(@f);
																																															end
																																														else
																																															begin
																																															if (str='COMBOBOXTEXTURE1') or (str='SETCOMBOBOXTEXTURE1') or (str='COMBOBOXTEXTURE1') then
																																																begin
																																																readln(f,str);
																																																SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
																																																ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
																																																	GlSanLoadTexture('Skins\'+way+'\'+str);
																																																ArSkins[High(ArSkins)].ComboBoxTexture1:=High(ArSkins[High(ArSkins)].ArTextures);
																																																end
																																															else
																																																begin
																																																if (str='COMBOBOXTEXTURE2') or (str='SETCOMBOBOXTEXTURE2') or (str='COMBOBOXTEXTURE2') then
																																																	begin
																																																	readln(f,str);
																																																	SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
																																																	ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
																																																		GlSanLoadTexture('Skins\'+way+'\'+str);
																																																	ArSkins[High(ArSkins)].ComboBoxTexture2:=High(ArSkins[High(ArSkins)].ArTextures);
																																																	end
																																																else
																																																	begin
																																																	if (str='COMBOBOXTEXTURE3') or (str='SETCOMBOBOXTEXTURE3') or (str='COMBOBOXTEXTURE3') then
																																																		begin
																																																		readln(f,str);
																																																		SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
																																																		ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
																																																			GlSanLoadTexture('Skins\'+way+'\'+str);
																																																		ArSkins[High(ArSkins)].ComboBoxTexture3:=High(ArSkins[High(ArSkins)].ArTextures);
																																																		end
																																																	else
																																																		begin
																																																		if (str='COMBOBOXTEXTURE4') or (str='SETCOMBOBOXTEXTURE4') or (str='COMBOBOXTEXTURE4') then
																																																			begin
																																																			readln(f,str);
																																																			SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
																																																			ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
																																																				GlSanLoadTexture('Skins\'+way+'\'+str);
																																																			ArSkins[High(ArSkins)].ComboBoxTexture4:=High(ArSkins[High(ArSkins)].ArTextures);
																																																			end
																																																		else
																																																			begin
																																																			if (str='COMBOBOXTEXTURE5') or (str='SETCOMBOBOXTEXTURE5') or (str='COMBOBOXTEXTURE5') then
																																																				begin
																																																				readln(f,str);
																																																				SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
																																																				ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
																																																					GlSanLoadTexture('Skins\'+way+'\'+str);
																																																				ArSkins[High(ArSkins)].ComboBoxTexture5:=High(ArSkins[High(ArSkins)].ArTextures);
																																																				end
																																																			else
																																																				begin
																																																				if (str='CONTEXTMENUTEXTURE5') or (str='SETCONTEXTMENUTEXTURE5') or (str='CONTEXTMENUTEXTURE5') then
																																																					begin
																																																					readln(f,str);
																																																					SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
																																																					ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
																																																						GlSanLoadTexture('Skins\'+way+'\'+str);
																																																					ArSkins[High(ArSkins)].ContextMenuTexture5:=High(ArSkins[High(ArSkins)].ArTextures);
																																																					end
																																																				else
																																																					begin
																																																					if (str='ARREALCONTEXTMENU5') or (str='SETARREALCONTEXTMENU5') or (str='SETARREALMEMBERCONTEXTMENU5') or (str='CONTEXTMENU5MEMBERARREAL') then
																																																						begin
																																																						while not seekeoln(f) do
																																																							begin
																																																							SetLength(ArSkins[High(ArSkins)].ArRealContextMenu5,Length(ArSkins[High(ArSkins)].ArRealContextMenu5)+1);
																																																							read(f,ArSkins[High(ArSkins)].ArRealContextMenu5[High(ArSkins[High(ArSkins)].ArRealContextMenu5)]);
																																																							end;
																																																						readln(f);
																																																						end
																																																					else
																																																						begin
																																																						if (str='CHECKBOXTEXTURE3') or (str='SETCHECKBOXTEXTURE3') or (str='CHECKBOXTEXTURE3') then
																																																							begin
																																																							readln(f,str);
																																																							SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
																																																							ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
																																																								GlSanLoadTexture('Skins\'+way+'\'+str);
																																																							ArSkins[High(ArSkins)].CheckBoxTexture3:=High(ArSkins[High(ArSkins)].ArTextures);
																																																							end
																																																						else
																																																							begin
																																																							if (str='CHECKBOXTEXTURE4') or (str='SETCHECKBOXTEXTURE4') or (str='CHECKBOXTEXTURE4') then
																																																								begin
																																																								readln(f,str);
																																																								SetLength(ArSkins[High(ArSkins)].ArTextures,Length(ArSkins[High(ArSkins)].ArTextures)+1);
																																																								ArSkins[High(ArSkins)].ArTextures[High(ArSkins[High(ArSkins)].ArTextures)]:=
																																																									GlSanLoadTexture('Skins\'+way+'\'+str);
																																																								ArSkins[High(ArSkins)].CheckBoxTexture4:=High(ArSkins[High(ArSkins)].ArTextures);
																																																								end
																																																							else
																																																								begin
																																																								if (str='ARREALTEXTURESKOORCHECKBOX') or (str='SETARREALTEXTURESKOORCHECKBOX') or (str='SETARREALMEMBERTEXTURESKOORCHECKBOX') or (str='TEXTURESKOORCHECKBOXMEMBERARREAL') then
																																																									begin
																																																									while not seekeoln(f) do
																																																										begin
																																																										SetLength(ArSkins[High(ArSkins)].ArCheckBoxKoorTextures,Length(ArSkins[High(ArSkins)].ArCheckBoxKoorTextures)+1);
																																																										ArSkins[High(ArSkins)].ArCheckBoxKoorTextures[High(ArSkins[High(ArSkins)].ArCheckBoxKoorTextures)][1].ReadFromFile(@f);
																																																										ArSkins[High(ArSkins)].ArCheckBoxKoorTextures[High(ArSkins[High(ArSkins)].ArCheckBoxKoorTextures)][2].ReadFromFile(@f);
																																																										end;
																																																									readln(f);
																																																									end
																																																								else
																																																									begin
																																																									
																																																									end;
																																																								end;
																																																							end;
																																																						end;
																																																					end;
																																																				end;
																																																			end;
																																																		end;
																																																	end;
																																																end;
																																															end;
																																														end;
																																													end;
																																												end;
																																											end;
																																										end;
																																									end;
																																								end;
																																							end;
																																						end;
																																					end;
																																				end;
																																			end;
																																		end;
																																	end;
																																end;
																															end;
																														end;
																													end;
																												end;
																											end;
																										end;
																									end;
																								end;
																							end;
																						end;
																					end;
																				end;
																			end;
																		end;
																	end;
																end;
															end;
														end;
													end;
												end;
											end;
										end;
									end;
								end;
							end;
						end;
					end;
				end;
			end
		else//writeln('Unknown command "'+str+'" in load skin "'+way+'" !'); 
			readln(f);
		end;
	close(f);
	end;
end;
procedure LoadFonts;
var
	f:text;
	sr:DOS.SearchRec;
	bool:boolean = false;
	str:string;
begin
bool:=false;
DOS.findfirst('*.*',$3F,sr);
While (dos.DosError<>18) and (bool=false) do
	begin
	if sr.Name='Buffer' then
		bool:=true;
	DOS.findnext(sr);
	end;
if not bool then
	begin
	MKDIR('Buffer');
	end;
bool:=false;
DOS.findfirst('*.*',$3F,sr);
While (dos.DosError<>18) and (bool=false) do
	begin
	if sr.Name='Fonts' then
		bool:=true;
	DOS.findnext(sr);
	end;
if bool then
	begin
	DOS.findfirst('Fonts\*.txt',$3F,sr);
	While (dos.DosError<>18) do
		begin
		assign(f,'Fonts\'+SR.Name);
		rename(f,'Fonts\'+GlSanCopy(SR.Name,1,Length(sr.Name)-4)+'.ssf');
		DOS.findnext(sr);
		end;
	DOS.findfirst('Fonts\*.ssf',$3F,sr);
	While (dos.DosError<>18) do
		begin
			begin
			if fail_est('Fonts\'+sr.name) then
				GlSanLoadFont(sr.name);
			glDisable(GL_TEXTURE_2D);
			end;
		DOS.findnext(sr);
		end;
	if fail_est('Fonts\Default.cfg') then
		begin
		assign(f,'Fonts\Default.cfg');
		reset(f);
		readln(f,str);
		ActiveFont:=GlSanGetFontNumber(Str);
		readln(f,str);
		if str='+' then
			CorrectFont:=true
		else
			CorrectFont:=false;
		readln(f,CorrectIntoChar);
		close(f);
		end;
	end
else
	MKDIR('Fonts');
DOS.findclose(sr);
end;

procedure LoadSounds;
var
	i:longint;
	NAr:array of string = nil;
	bool:boolean = false;
	sr:Dos.SearchRec;
begin
RNROpenalInit;
bool:=false;
DOS.findfirst('*.*',$3F,sr);
While (dos.DosError<>18) and (bool=false) do
	begin
	if sr.Name='Sounds' then
		bool:=true;
	DOS.findnext(sr);
	end;
if bool then
	begin
	SetLength(NAr,0);
	dos.findfirst('Sounds\*.wav',$3F,sr);
	While dos.DosError<>18 do
		begin
		SetLength(NAr,Length(NAr)+1);
		NAr[High(NAr)]:=sr.name;
		DOS.findnext(sr);
		end;
	for i:=0 to High(NAr) do
		begin
		RNRImportAudio('Sounds\'+NAr[i],false);
		end;
	SetLength(NAr,0);
	RNRPlayAudioNotError('SystemWelcom2');
	end
else
	begin
	MKDIR('Sounds');
	end;
end;

procedure GlSanConstWindows;
var
	i,ii,iii:longint;
	k:array[1..4] of GlSanKoor;
	z:real = 5.891;
	Koor:GlSanKoor;
	Koor1:GlSanKoor = (x:-2;y:1;z:0);
	Koor2:GlSanKoor = (x:2;y:-1;z:0);
	Koor3:GlSanKoor;
	sr:DOS.SearchRec;
	bool:boolean;
	NAr:array of string;
	TotalProgress:real = 0.25/2;
	TotalStageKol:longint = 4;
	F:text;
	Str:string;
	zzzzz:real = 5.892;
begin
{$NOTE GlSanConstWindows}
Koor3:=Koor2;
k[1]:=GlSanKoorImport(-50,50,z);
k[2].Import(50,50,z);
k[3].Import(50,-50,z);
k[4].Import(-50,-50,z);
iii:=1; {rs2}
ii:=1; {rs1}
i:=1;{rz}
rz:=26; {rz}
repeat
GlSanClear;
Gltranslatef(0,0,-6);
GlSanQuad(k[1],k[2],k[3],k[4]);
if i =1 then
	begin
	Koor:=GlSanKoor(SGGetVertexFromPointOnScreen(SGVertex2fToPoint2f(TSGVertex2f(GlSanKoor2fImport(width/2,rz)))));
	Koor.SanWriteLn;readln;
	if Koor.z<zzzzz then
		i:=2
	else
		begin
		rz+=1;
		end;
	end;
if ii=1 then
	begin
	Koor:=GlSanKoor(SGGetVertexFromPointOnScreen(SGVertex2fToPoint2f(TSGVertex2f(GlSanKoor2fImport(rs2,height/2)))));
	Koor.SanWriteLn;readln;
	if Koor.z<zzzzz then
		ii:=2
	else
		begin
		rs2+=1;
		end;
	end;
if iii=1 then
	begin
	Koor:=GlSanKoor(SGGetVertexFromPointOnScreen(SGVertex2fToPoint2f(TSGVertex2f(GlSanKoor2fImport(width/2,height-rs1)))));
	Koor.SanWriteLn;readln;
	if Koor.z<zzzzz then
		iii:=2
	else
		begin
		rs1+=1;
		end;
	end;
if GlSanWAKol>0 then
	begin
	GlSanClear;
	Gltranslatef(0,0,-6);
	glColor4f(1,1,1,0.8);
	GlSanOutTextS(GlSanKoorImport(0,0,0),'Подготовка к Инициализации Окон',0.1);
	glColor4f(1,1,1,0.4);
	GlSanOutTextS(GlSanKoorImport(0,-0.27,0),'( '+GlSanStr(rz)+' , '+GlSanStr(rs1)+' , '+GlSanStr(rs2)+' )',0.07);
	glColor4f(1,1,1,0.6);
	GlSanOutTextS(GlSanKoorImport(0,2.2,0),'Total',0.08);
	TotalProgress:=(rz/34)/4;
	GlSanRoundQuadLines(GlSanKoorImport(-1.2,2.4,0),GlSanKoorImport(1.2,1.7,0),0.05,5);
	GlSanRoundQuadLines(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(1,1.93,0),0.05,5);
	glColor4f(1-TotalProgress,TotalProgress,0,0.6);
	GlSanRoundQuad(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(-1+2*TotalProgress,1.93,0),0.05,5);
	GlSanSwapBuffers;
	end;
GlSanMessage;
until ((ii=2) and (i=2) and (iii=2));
for i:=0 to GlSanWAKol do
	begin
	GlSanClear;
	Gltranslatef(0,0,-6);
	GlSanQuad(k[1],k[2],k[3],k[4]);
	GlSanWA[i,1]:=GlSanReadCamXYZ(GlSanKoor2fImport(rs2,rz));
	GlSanWA[i,2]:=GlSanReadCamXYZ(GlSanKoor2fImport(width-rs2,rz));
	GlSanWA[i,3]:=GlSanReadCamXYZ(GlSanKoor2fImport(width-rs2,height-rs1));
	GlSanWA[i,4]:=GlSanReadCamXYZ(GlSanKoor2fImport(rs2,height-rs1));
	for ii:=1 to 4 do
		begin
		K[ii].z:=K[ii].z-GlSanWndMin;
		end;
	if GlSanWAKol>0 then
		begin
		GlSanClear;
		Gltranslatef(0,0,-6);
		glColor4f(1,1,1,0.6);
		GlSanOutTextS(GlSanKoorImport(0,2.2,0),'Total',0.08);
		GlSanRoundQuadLines(GlSanKoorImport(-1.2,2.4,0),GlSanKoorImport(1.2,1.7,0),0.05,5);
		GlSanRoundQuadLines(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(1,1.93,0),0.05,5);
		glColor4f(1-TotalProgress,TotalProgress,0,0.6);
		GlSanRoundQuad(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(-1+2*TotalProgress,1.93,0),0.05,5);
		glColor4f(1,1,1,0.8);
		GlSanOutTextS(GlSanKoorImport(0,1.2,0),'Инициализация Окон',0.1);
		GlSanOutTextS(GlSanKoorImport(0,-1.2,0),GlSanStrReal(100*i/GlSanWAKol,2)+'% ( '+GlSanStr(i)+'/'+GlSanStr(GlSanWAKol)+' )',0.08);
		glColor4f(0,1,0,i/GlSanWAKol);
		Koor3.x:=abs(Koor1.x-Koor2.x)*(i/GlSanWAKol)+Koor1.x;
		GlSanRoundQuad(Koor1,Koor3,0.1,7);
		glColor4f(1,1,1,1);
		GlSanRoundQuadLines(Koor1,Koor2,0.1,7);
		TotalProgress:=0.25+0.25*(i/GlSanWAKol);
		GlSanMessage;
		GlSanSwapBuffers;
		end;
	end;
{Задаем размер символа контекстного меню...}
StandardContextMenuZum:=GlSanMinimum(abs(GlSanWA[0,1].x-GlSanWA[0,3].x),abs(GlSanWA[0,1].y-GlSanWA[0,3].y))/70;
(*----------------------------*)
(*-------грузим шрифты--------*)
(*----------------------------*)
//LoadFonts;
//GlSanStartThread(@LoadFonts);
GlSanClear;
Gltranslatef(0,0,-6);
glColor4f(1,1,1,0.6);
GlSanOutTextS(GlSanKoorImport(0,2.2,0),'Total',0.08);
GlSanRoundQuadLines(GlSanKoorImport(-1.2,2.4,0),GlSanKoorImport(1.2,1.7,0),0.05,5);
GlSanRoundQuadLines(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(1,1.93,0),0.05,5);
glColor4f(1-TotalProgress,TotalProgress,0,0.6);
GlSanRoundQuad(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(-1+2*TotalProgress,1.93,0),0.05,5);
TotalProgress:=2/TotalStageKol+1/TotalStageKol/2;
glColor4f(1,1,1,0.8);
GlSanOutTextS(GlSanKoorImport(0,0,0),'Инициализация Загрузки Шрифтов',0.1);
GlSanMessage;
GlSanSwapBuffers;
bool:=false;
DOS.findfirst('*.*',$3F,sr);
While (dos.DosError<>18) and (bool=false) do
	begin
	if sr.Name='Buffer' then
		bool:=true;
	DOS.findnext(sr);
	end;
if not bool then
	begin
	MKDIR('Buffer');
	end;
bool:=false;
DOS.findfirst('*.*',$3F,sr);
While (dos.DosError<>18) and (bool=false) do
	begin
	if sr.Name='Fonts' then
		bool:=true;
	DOS.findnext(sr);
	end;
if bool then
	begin
	DOS.findfirst('Fonts\*.txt',$3F,sr);
	While (dos.DosError<>18) do
		begin
		assign(f,'Fonts\'+SR.Name);
		rename(f,'Fonts\'+GlSanCopy(SR.Name,1,Length(sr.Name)-4)+'.ssf');
		DOS.findnext(sr);
		end;
	DOS.findfirst('Fonts\*.ssf',$3F,sr);
	While (dos.DosError<>18) do
		begin
			begin
			if fail_est('Fonts\'+sr.name) then
				GlSanLoadFont(sr.name);
			glDisable(GL_TEXTURE_2D);
			end;
		DOS.findnext(sr);
		GlSanClear;
		Gltranslatef(0,0,-6);
		glColor4f(1,1,1,0.6);
		GlSanOutTextS(GlSanKoorImport(0,2.2,0),'Total',0.08);
		GlSanRoundQuadLines(GlSanKoorImport(-1.2,2.4,0),GlSanKoorImport(1.2,1.7,0),0.05,5);
		GlSanRoundQuadLines(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(1,1.93,0),0.05,5);
		glColor4f(1-TotalProgress,TotalProgress,0,0.6);
		GlSanRoundQuad(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(-1+2*TotalProgress,1.93,0),0.05,5);
		TotalProgress:=2/TotalStageKol+1/TotalStageKol/2;
		glColor4f(1,1,1,0.8);
		GlSanOutTextS(GlSanKoorImport(0,0,0),'Загрузка Шрифтов',0.1);
		glColor4f(1,1,1,0.5);
		GlSanOutTextS(GlSanKoorImport(0,-0.4,0),GlSanCopy(sr.name,1,Length(sr.name)-4),0.06);
		GlSanMessage;
		GlSanSwapBuffers;
		end;
	if fail_est('Fonts\Default.cfg') then
		begin
		assign(f,'Fonts\Default.cfg');
		reset(f);
		readln(f,str);
		ActiveFont:=GlSanGetFontNumber(Str);
		readln(f,str);
		if str='+' then
			CorrectFont:=true
		else
			CorrectFont:=false;
		readln(f,CorrectIntoChar);
		close(f);
		end;
	end
else
	MKDIR('Fonts');
GlSanClear;
Gltranslatef(0,0,-6);
glColor4f(1,1,1,0.6);
GlSanOutTextS(GlSanKoorImport(0,2.2,0),'Total',0.08);
GlSanRoundQuadLines(GlSanKoorImport(-1.2,2.4,0),GlSanKoorImport(1.2,1.7,0),0.05,5);
GlSanRoundQuadLines(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(1,1.93,0),0.05,5);
glColor4f(1-TotalProgress,TotalProgress,0,0.6);
GlSanRoundQuad(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(-1+2*TotalProgress,1.93,0),0.05,5);
TotalProgress:=2/TotalStageKol+1/TotalStageKol/2;
glColor4f(1,1,1,0.8);
GlSanOutTextS(GlSanKoorImport(0,0,0),'Загрузка Текстур',0.1);
GlSanMessage;
GlSanSwapBuffers;
DOS.findfirst('*.*',$3F,sr);
bool:=false;
While (dos.DosError<>18) and (bool=false) do
	begin
	if sr.Name='Textures' then
		bool:=true;
	DOS.findnext(sr);
	end;
if bool then
	begin
	DOS.findfirst('Textures\*.bmp',$3F,sr);
	While (dos.DosError<>18) do
		begin
		SetLength(ArTextures,Length(ArTextures)+1);
		ArTextures[High(ArTextures)].Name:=GlSanCopy(sr.name,1,Length(sr.name)-4);
		ArTextures[High(ArTextures)].ID:=GlSanLoadTexture('Textures\'+sr.name);
		DOS.findnext(sr);
		end;
	DOS.findfirst('Textures\*.png',$3F,sr);
	While (dos.DosError<>18) do
		begin
		SetLength(ArTextures,Length(ArTextures)+1);
		ArTextures[High(ArTextures)].Name:=GlSanCopy(sr.name,1,Length(sr.name)-4);
		ArTextures[High(ArTextures)].ID:=GlSanLoadTexture('Textures\'+sr.name);
		DOS.findnext(sr);
		end;
	DOS.findfirst('Textures\*.jpg',$3F,sr);
	While (dos.DosError<>18) do
		begin
		SetLength(ArTextures,Length(ArTextures)+1);
		ArTextures[High(ArTextures)].Name:=GlSanCopy(sr.name,1,Length(sr.name)-4);
		ArTextures[High(ArTextures)].ID:=GlSanLoadTexture('Textures\'+sr.name);
		DOS.findnext(sr);
		end;
	end
else
	MKDIR('Textures');
glDisable(GL_TEXTURE_2D);
GlSanClear;
Gltranslatef(0,0,-6);
glColor4f(1,1,1,0.6);
GlSanOutTextS(GlSanKoorImport(0,2.2,0),'Total',0.08);
GlSanRoundQuadLines(GlSanKoorImport(-1.2,2.4,0),GlSanKoorImport(1.2,1.7,0),0.05,5);
GlSanRoundQuadLines(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(1,1.93,0),0.05,5);
glColor4f(1-TotalProgress,TotalProgress,0,0.6);
GlSanRoundQuad(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(-1+2*TotalProgress,1.93,0),0.05,5);
TotalProgress:=2/TotalStageKol+1/TotalStageKol/2;
glColor4f(1,1,1,0.8);
GlSanOutTextS(GlSanKoorImport(0,0,0),'Загрузка Тем',0.1);
GlSanMessage;
GlSanSwapBuffers;
(*=======Skins installing============*)
DOS.findfirst('*.*',$3F,sr);
bool:=false;
ActiveSkin:=-1;
While (dos.DosError<>18) and (bool=false) do
	begin
	if sr.Name='Skins' then
		bool:=true;
	DOS.findnext(sr);
	end;
if bool then
	begin
	DOS.findfirst('Skins\*.*',$3F,sr);
	While (dos.DosError<>18) do
		begin
		if GlSanIDKat(sr.attr) and (sr.name<>'.') and (sr.name<>'..') then
			begin
			GlSanInstallSkin(sr.name);
			end;
		DOS.findnext(sr);
		end;
	if fail_est('Skins\Defaulf.cfg') then
		begin
		assign(f,'Skins\Defaulf.cfg');
		reset(f);
		readln(f,str);
		close(f);
		Str:=GlSanUpCaseString(str);
		for i:=LOw(ArSkins) to High(ArSkins) do
			if GlSanUpCaseString(ArSkins[i].Name) = str then
				ActiveSkin:=i;
		end;
	end
else
	begin
	MKDIR('Skins');
	end;
if GlSanStartThread(@LoadSounds) = 0  then
	begin
	glDisable(GL_TEXTURE_2D);
	GlSanClear;
	Gltranslatef(0,0,-6);
	glColor4f(1,1,1,0.6);
	GlSanOutTextS(GlSanKoorImport(0,2.2,0),'Total',0.08);
	GlSanRoundQuadLines(GlSanKoorImport(-1.2,2.4,0),GlSanKoorImport(1.2,1.7,0),0.05,5);
	GlSanRoundQuadLines(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(1,1.93,0),0.05,5);
	glColor4f(1-TotalProgress,TotalProgress,0,0.6);
	GlSanRoundQuad(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(-1+2*TotalProgress,1.93,0),0.05,5);
	TotalProgress:=2/TotalStageKol+1/TotalStageKol/2;
	glColor4f(1,1,1,0.8);
	GlSanOutTextS(GlSanKoorImport(0,0,0),'Инициализация Загрузки Звуков',0.1);
	GlSanMessage;
	GlSanSwapBuffers;
	GlSanClear;
	RNROpenalInit;
	bool:=false;
		GlSanClear;
		Gltranslatef(0,0,-6);
		glColor4f(1,1,1,0.6);
		GlSanOutTextS(GlSanKoorImport(0,2.2,0),'Total',0.08);
		GlSanRoundQuadLines(GlSanKoorImport(-1.2,2.4,0),GlSanKoorImport(1.2,1.7,0),0.05,5);
		GlSanRoundQuadLines(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(1,1.93,0),0.05,5);
		glColor4f(1-TotalProgress,TotalProgress,0,0.6);
		GlSanRoundQuad(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(-1+2*TotalProgress,1.93,0),0.05,5);
		TotalProgress:=2/TotalStageKol+1/TotalStageKol/3*2;
		glColor4f(1,1,1,0.8);
		GlSanOutTextS(GlSanKoorImport(0,0,0),'Инициализация Загрузки Звуков',0.1);
		glColor4f(1,1,1,0.5);
		GlSanOutTextS(GlSanKoorImport(0,-0.4,0),'Поиск папки "Sounds"',0.06);
		GlSanMessage;
		GlSanSwapBuffers;
	DOS.findfirst('*.*',$3F,sr);
	While (dos.DosError<>18) and (bool=false) do
		begin
		if sr.Name='Sounds' then
			bool:=true;
		DOS.findnext(sr);
		end;
	GlSanClear;
	Gltranslatef(0,0,-6);
	glColor4f(1,1,1,0.6);
	GlSanOutTextS(GlSanKoorImport(0,2.2,0),'Total',0.08);
	GlSanRoundQuadLines(GlSanKoorImport(-1.2,2.4,0),GlSanKoorImport(1.2,1.7,0),0.05,5);
	GlSanRoundQuadLines(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(1,1.93,0),0.05,5);
	glColor4f(1-TotalProgress,TotalProgress,0,0.6);
	GlSanRoundQuad(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(-1+2*TotalProgress,1.93,0),0.05,5);
	TotalProgress:=2/TotalStageKol+1/TotalStageKol;
	glColor4f(1,1,1,0.8);
	GlSanOutTextS(GlSanKoorImport(0,0,0),'Инициализация Загрузки Звуков',0.1);
	glColor4f(1,1,1,0.6);
	GlSanOutTextS(GlSanKoorImport(0,-0.3,0),'Поиск звуков',0.08);
	GlSanMessage;
	GlSanSwapBuffers;
	if bool then
		begin
		SetLength(NAr,0);
		dos.findfirst('Sounds\*.wav',$3F,sr);
		While dos.DosError<>18 do
			begin
			SetLength(NAr,Length(NAr)+1);
			NAr[High(NAr)]:=sr.name;
			DOS.findnext(sr);
			end;
		for i:=0 to High(NAr) do
			begin
			RNRImportAudio('Sounds\'+NAr[i],false);
			GlSanClear;
			Gltranslatef(0,0,-6);
			glColor4f(0,1,0,i/High(NAr));
			Koor3.x:=abs(Koor1.x-Koor2.x)*(i/High(NAr))+Koor1.x;
			GlSanRoundQuad(Koor1,Koor3,0.1,7);
			glColor4f(1,1,1,1);
			GlSanRoundQuadLines(Koor1,Koor2,0.1,7);
			glColor4f(1,1,1,0.8);
			GlSanOutTextS(GlSanKoorImport(0,1.2,0),'Загрузка Звуков',0.1);
			GlSanOutTextS(GlSanKoorImport(0,-1.2,0),GlSanStrReal(100*i/(High(NAr)),2)+'% ( '+GlSanStr(i)+'/'+GlSanStr(High(NAr))+' )',0.08);
			glColor4f(1,1,1,0.5);
			GlSanOutTextS(GlSanKoorImport(0,-1.4,0),'" Sounds\'+NAr[i]+' "',0.06);
			glColor4f(1,1,1,0.6);
			GlSanOutTextS(GlSanKoorImport(0,2.2,0),'Total',0.08);
			GlSanRoundQuadLines(GlSanKoorImport(-1.2,2.4,0),GlSanKoorImport(1.2,1.7,0),0.05,5);
			GlSanRoundQuadLines(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(1,1.93,0),0.05,5);
			glColor4f(1-TotalProgress,TotalProgress,0,0.6);
			GlSanRoundQuad(GlSanKoorImport(-1,2.07,0),GlSanKoorImport(-1+2*TotalProgress,1.93,0),0.05,5);
			TotalProgress:=3/TotalStageKol+1/TotalStageKol*(i/(High(NAr)));
			GlSanMessage;
			GlSanSwapBuffers;
			end;
		GlSanClear;
		GlSanSwapBuffers;
		SetLength(NAr,0);
		RNRPlayAudioNotError('SystemWelcom2');
		//RNRSourceImport('SystemClickWindow',GlSanKoorImport(0,0,0),GlSanKoorImport(-0.1,0,0),false);
		//RNRSourcePosImport('SystemClickWindow',GlSanKoorImport(3,0,0));
		end
	else
		begin
		MKDIR('Sounds');
		end;
	end;
{NewDelayWindow(nil);
NewMenuWindow;}
end;

procedure GlSanWndTaskMsgProc(Wnd1:pointer);
var
	W,Wnd:^GlSanWnd;
	i:longint;
begin
Wnd:=Wnd1;
if (GlSanReadKey=46) and (Wnd1=GlSanWinds[High(GlSanWinds)]) then
	begin
	GlSanSetKey(0);
	GlSanWndTaskMsgKill(Wnd1);
	end;
if Length(GlSanWinds)<>(Wnd^.UserMemory.ArLongint[Low(Wnd^.UserMemory.ArLongint)]) then
	begin
	GlSanWndClearListBox(@Wnd,1);
	SetLength(Wnd^.UserMemory.ArPointer,Length(GlSanWinds));
	for i:=Low(GlSanWinds) to High(GlSanWinds) do
		begin
		w:=GlSanWinds[i];
		GlSanWndNewStringInLintBox(@Wnd,1,w^.Tittle+'    <'+w^.TittleSystem+'>');
		Wnd^.UserMemory.ArPointer[i]:=w;
		end;
	Wnd^.UserMemory.ArLongint[Low(Wnd^.UserMemory.ArLongint)]:=Length(GlSanWinds);
	GlSanWndSetNewTittleText(@Wnd1,1,'Окон: '+GlSanStr(Length(GlSanWinds)));
	end;
end;

procedure GlSanWndTaskMsgKill(Wnd:pointer);
var
	W,W1:^GlSanWnd;
begin
w:=wnd;
if w^.ArListBox[Low(w^.ArListBox)].MVPos>0 then
	begin
	W1:=W^.UserMemory.ArPointer[w^.ArListBox[Low(w^.ArListBox)].MVPos-1];
	GlSanKillWnd(@W1);
	GlSanWndTaskMsgProc(wnd);
	end;
end;
procedure GlSanWndTaskMsgKillAll(Wnd:pointer);
var
	W,W1:^GlSanWnd;
	i:longint;
begin
w:=wnd;
for i:=Low(w^.UserMemory.ArPointer) to High(w^.UserMemory.ArPointer) do
	begin
	W1:=W^.UserMemory.ArPointer[i];
	GlSanKillWnd(@W1);
	end;
end;
procedure GlSanNewTaskMgrWnd(Wnd:pointer);
var
	i:longint;
	W:^GlSanWindow;
begin
GlSanCreateWnd(@NewWnd,'Диспетчер Задач',GlSanKoor2fImport(320,680));
GlSanWndSetProc(@NewWnd,@GlSanWndTaskMsgProc);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(240,600),GlSanKoor2fImport(310,630),'Закрыть',@GlSanKillThisWindow);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(160,600),GlSanKoor2fImport(230,630),'Обновить',@GlSanWndTaskMsgProc);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(80,600),GlSanKoor2fImport(150,630),'Выгрузить',@GlSanWndTaskMsgKill);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(80,640),GlSanKoor2fImport(150,670),'Выгрузить Все',@GlSanWndTaskMsgKillAll);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(160,640),GlSanKoor2fImport(230,670),'Run Delay',@NewDelayWindow);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(1,600),GlSanKoor2fImport(70,630),'Окон: '+GlSanStr(Length(GlSanWinds)));
GlSanWndNewListBox(@NewWnd,GlSanKoor2fImport(10,50),GlSanKoor2fImport(310,590),
	GlSanKoor2fImport(30,20),true);
SetLength(NewWnd^.UserMemory.ArPointer,Length(GlSanWinds));
SetLength(NewWnd^.UserMemory.ArLongint,1);
NewWnd^.UserMemory.ArLongint[Low(NewWnd^.UserMemory.ArLongint)]:=Length(GlSanWinds);
for i:=Low(GlSanWinds) to High(GlSanWinds) do
	begin
	w:=GlSanWinds[i];
	NewWnd^.UserMemory.ArPointer[i]:=w;
	GlSanWndNewStringInLintBox(@NewWnd,1,w^.Tittle+'    <'+w^.TittleSystem+'>');
	end;
GlSanWndDispose(@NewWnd);
end;
procedure ReadKeyWndProc(Wnd:pointer);
begin
if GlSanKeyPressed then
	begin
	GlSanWndSetNewTittleText(@Wnd,1,'Вы нажали "'+GlSanWhatIsTheSimbol(LongInt(SGKeyPressedVariable))+'" ReadKey ='+GlSanStr(GlSanReadKey)+'.');
	end;
end;

procedure NewReadKeyWnd(Wnd:pointer);
begin
GlSanCreateWnd(@NewWnd,'Диспетчер Read Key-a',GlSanKoor2fImport(300,80));
GlSanWndSetProc(@NewWnd,@ReadKeyWndProc);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(240,45),GlSanKoor2fImport(295,75),'Закрыть',@GlSanKillThisWindow);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(5,45),GlSanKoor2fImport(235,75),'Нажмите что-нибудь');
GlSanWndDispose(@NewWnd);
end;

procedure TaskMgrSoundsProc(wnd:pointer);
begin
if (GlSanWndClickButton(@Wnd,2) or (GlSanReadKey=13)) then
	begin
	if (GlSanWndGetListBoxActivePosition(@Wnd,1)>0) then
		RNRPlayAudio(GlSanWndGetListBoxMVPos(@Wnd,1))
	else
		RNRPlayRamdomNo;
	end;
end;

procedure NewTaskMgrSoundsWnd(wnd:pointer);
var
	i:longint;
begin
GlSanCreateWnd(@NewWnd,'Диспетчер Звуков',GlSanKoor2fImport(480,640));
GlSanWndSetProc(@NewWnd,@TaskMgrSoundsProc);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(405,605),GlSanKoor2fImport(475,635),'Закрыть',@GlSanKillThisWindow);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(300,605),GlSanKoor2fImport(400,635),'Воспроизвести',nil);
GlSanWndNewListBox(@NewWnd,GlSanKoor2fImport(10,50),GlSanKoor2fImport(470,595),
	GlSanKoor2fImport(30,20),true);
for i:=0 to High(RNRNames) do
	GlSanWndNewStringInLintBox(@NewWnd,1,RNRNames[i].Name,GlSanWndTranslentColor4fToColorText(GlSanColor4fImport(1,1,1,0.8)));
GlSanWndDispose(@NewWnd);
end;
procedure ProcTMFonts(Wnd:PGlSanWnd);
var
	c:boolean = false;
begin
if GlSanWndClickButton(@Wnd,1) then
	if ActiveFont<>-1 then
		begin
		ActiveFont-=1;
		c:=true;
		end;
if GlSanWndClickButton(@Wnd,2) then
	if ActiveFont<>High(ArFonts) then
		begin
		ActiveFont+=1;
		c:=true;
		end;
if c then
	begin
	if ActiveFont=-1 then
		GlSanWndSetButtonTexture(@Wnd,1,'l1')
	else
		GlSanWndSetButtonTexture(@Wnd,1,'l2');
	if ActiveFont=High(ArFonts) then
		GlSanWndSetButtonTexture(@Wnd,2,'p1')
	else
		GlSanWndSetButtonTexture(@Wnd,2,'p2');
	if ActiveFont=-1 then 
		GlSanWndSetNewTittleText(@wnd,1,'Тип : Программный')
	else
		GlSanWndSetNewTittleText(@wnd,1,'Тип : Растровый');
	if ActiveFont=-1 then 
		GlSanWndSetNewTittleText(@wnd,2,'Имя : GlSanFont1')
	else
		GlSanWndSetNewTittleText(@wnd,2,'Имя : '+ArFonts[ActiveFont].Name);
	end;
CorrectFont:=GlSanWndGetCaptionFromCheckBox(@Wnd,1);
GlSanWndSetNewTittle(@Wnd,'Выбор Шрифта ('+GlSanStr(ActiveFont+2)+'/'+GlSanStr(High(ArFonts)+2)+').');
end;
procedure SohrFont(Wnd:pointer);
var
	f:text;
begin
assign(f,'Fonts\Default.cfg');
rewrite(f);
if ActiveFont=-1 then writeln(f) else writeln(f,ArFonts[ActiveFont].Name);
if CorrectFont then writeln(f,'+') else writeln(f,'-');
writeln(f,CorrectIntoChar);
close(f);
end;
procedure CorrectIntoCharM(Wnd:PGlSanWnd);
begin
CorrectIntoChar-=1;
GlSanWndSetNewTittleText(@Wnd,5,GlSanStr(CorrectIntoChar));
end;
procedure CorrectIntoCharP(Wnd:PGlSanWnd);
begin
CorrectIntoChar+=1;
GlSanWndSetNewTittleText(@Wnd,5,GlSanStr(CorrectIntoChar));
end;
procedure StartTMFots(w:pointer);
begin
GlSanCreateWnd(@NewWnd,'Выбор шрифта',glSanKoor2fImport(640,208));
GlSanWndSetInitProc(@NewWnd,@ProcTMFonts);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(8,45),GlSanKoor2fImport(100,200),'');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(530,45),GlSanKoor2fImport(632,200),'');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(605,5),GlSanKoor2fImport(635,35),'',@GlSanKillThisWindow);
GlSanWndSetLastButtonTexture(@NewWnd,'close');
GlSanWndSetLastButtonTextureOnClick(@NewWnd,'close2');
GlSanWndSetLastButtonTextureClick(@NewWnd,'close3');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(110,45),GlSanKoor2fImport(520,75),'');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(110,80),GlSanKoor2fImport(520,110),'');
GlSanWndNewCheckBox(@NewWnd,GlSanKoor2fImport(110,115),GlSanKoor2fImport(130,135),CorrectFont);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(135,110),GlSanKoor2fImport(520,140),'Подгонять высоту текста под длинну');
	if ActiveFont=-1 then
		GlSanWndSetButtonTexture(@NewWnd,1,'l1')
	else
		GlSanWndSetButtonTexture(@NewWnd,1,'l2');
	if ActiveFont=High(ArFonts) then
		GlSanWndSetButtonTexture(@NewWnd,2,'p1')
	else
		GlSanWndSetButtonTexture(@NewWnd,2,'p2');
	if ActiveFont=-1 then 
		GlSanWndSetNewTittleText(@NewWnd,1,'Тип : Программный')
	else
		GlSanWndSetNewTittleText(@NewWnd,1,'Тип : Растровый');
	if ActiveFont=-1 then 
		GlSanWndSetNewTittleText(@NewWnd,2,'Имя : GlSanFont1')
	else
		GlSanWndSetNewTittleText(@NewWnd,2,'Имя : '+ArFonts[ActiveFont].Name);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(110,140),GlSanKoor2fImport(520,170),'Загружать его так с запуском программы',@SohrFont);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(110,173),GlSanKoor2fImport(400,200),'Отступы c границ внутрь буквы (для растровой) :');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(448,173),GlSanKoor2fImport(480,200),GlSanStr(CorrectIntoChar));
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(408,173),GlSanKoor2fImport(440,200),'-',@CorrectIntoCharM);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(490,173),GlSanKoor2fImport(520,200),'+',@CorrectIntoCharP);
GlSanWndDispose(@NewWnd);
end;

procedure GlSanWindows;{----------------------------------GlSanWindows-----------------------}
{$NOTE GlSanWindows ( Begining )}
var
	CurKoor:GlSanKoor;
	wck,wck2:^GlSanWnd;
	UsheVib:boolean = false;
	UsheVibMove:boolean = false;
	MoveKoor2f,OtnMK2F:GlSanKoor2f;
	i,ii,j:longint;{Счётчик}
	WVL,WNP:GlSanKoor;
	ZWindow:longint=1;
	GSWBP:GlSanWndProcedure;
	IB:boolean = false;
	IR:real = 0;

procedure GlSanAltTab;
var
	{State : TKeyboardState;}
	w:PGlSanWnd;
	i:longint;
begin
{GetKeyboardState(State);
if ((State[vk_Menu] and 128) <> 0) and (((State[9] and 128) <> 0)) then
	begin
	State[vk_Menu]:=128 and 0;
	State[9]:=128 and 0;
	SetKeyboardState(State);
	end;}
if (GlSanDownKey(vk_Control)) and (GlSanReadKey=9) then
	begin
	w:=GlSanWinds[High(GlSanWinds)];
	for i:=High(GlSanWinds)-1 downto Low(GlSanWinds) do
		GlSanWinds[i+1]:=GlSanWinds[i];
	GlSanWinds[Low(GlSanWinds)]:=w;
	end;
end;

function GSPBM(const p:pointer):boolean;
var
	b:boolean;
	w:^GlSanWnd;
	i:longint;

begin
w:=p;
GSPBM:=false;
if w<>nil then
	begin
	b:=true;
	for i:=Low(W^.ArButtons) to High(W^.ArButtons) do
		begin
		if GlSanCursorOnButton(@W^.ArButtons[i],CurKoor,W^.TVL,W^.TNP) then
			b:=false;
		end;
	GSPBM:= b;
	end;
end;

begin
if GlSanDownKey(17) and  (GlSanReadKey=77) then NewMenuWindow;
if Length(GlSanWinds)>0 then
	begin
	{Special Functions}
	GlSanAltTab;
	{Выпоснение процедур окон}
	for i:=Low(GlSanWinds) to High(GlSanWinds) do
		begin
		Wck:=GlSanWinds[i];
		if Wck^.Proc<>nil then
			begin
			GSWBP:=GlSanWndProcedure(Wck^.Proc);
			GSWBP(Wck);
			end;
		end;
	if IDReOut<>nil then
		begin
		i:=Low(GlSanWinds);
		while (i<=High(GlSanWinds)) and (not (GlSanWinds[i]=IDReOut)) do
			begin
			wck:=GlSanWinds[i];
			if wck^.Proc<>nil then
				begin
				wck^.ReOutThisProc:=true;
				GSWBP:=GlSanWndProcedure(wck^.Proc);
				GSWBP(wck);
				wck^.ReOutThisProc:=false;
				end;
			i+=1;
			end;
		IDReOut:=nil;
		end;
	{==-==Вывод окон==-==}
	glloadidentity;
	gltranslatef(0,0,-6);
	glLineWidth (1.5);
	glEnable (GL_LINE_SMOOTH);
	glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
	glDisable(GL_LIGHTING);
	for i:=Low(GlSanWinds) to High(GlSanWinds) do
		begin
		GlSanWinds[i]^.Init(i+1);
		if GlSanWinds[i]^.InitProc<>nil then
			begin
			GSWBP:=GlSanWndProcedure(GlSanWinds[i]^.InitProc);
			GSWBP(GlSanWinds[i]);
			end;
		end;
	ZWindow:=i+1;
	{Out Context Menu}
	if ContextMenu<>nil then
		begin
		ContextMenu^.StartKoor:=ContextMenuStartKoor;
		ContextMenu^.ReKoor;
		ContextMenu^.Init;
		CurKoor:=GlSanReadMouseXYZ;
		if (not ContextMenu^.InitKoor(CurKoor)) and ((GlSanMouseReadKey in [1..3]))  then
				ContextMenu^.KillContext;
		if ContextCloseID or (GlSanKeyPressed and (GlSanReadKey=27)) then
			begin
			ContextCloseID:=false;
			ContextMenu^.KillContext;
			if (GlSanKeyPressed and (GlSanReadKey=27)) then
				GlSanSetKey(0);
			end;
		if (ContextMenu^.OpenProgress<0.1) and (not ContextMenu^.Open) then
			begin
			ContextMenu^.CloseContext;
			ContextMenu:=nil
			end;
		end;
	{Получение вертекса под указателем мыши...}
	CurKoor:=GlSanReadMouseXYZ;
	{Всплытие окна на 1-едний план}
	if (GlSanMouseReadKey=1) AND (IsContextFree) then
		begin
		i:=High(GlSanWinds);
		repeat
		Wck:=GlSanWinds[i];
		if GlSanWndPrinKoor(wck^.TVL,wck^.TNP,CurKoor) then
			begin
			if i<>High(GlSanWinds) then
				RNRPlayAudioNotError('SystemClickWindow');
			Wck2:=GlSanWinds[i];
			for ii:=i+1 to High(GlSanWinds) do
				GlSanWinds[ii-1]:=GlSanWinds[ii];
			GlSanWinds[High(GlSanWinds)]:=Wck2;
			UsheVib:=true;
			if Wck^.MTelo and GSPBM(Wck) then
				begin
				UsheVibMove:=true;
				end
			else
				begin
				if GlSanWndPrinKoor(wck^.TVL,wck^.TNZP,CurKoor) and GSPBM(Wck)  then
					UsheVibMove:=true;
				end;
			end;
		i-=1;
		until UsheVib or (i<Low(GlSanWinds));
		end;
	{Перемещение окон}
	if GlSanWndMove then
		begin
		if ((SGIsMouseKeyDown(1)=false) or (Length(GlSanWinds)<>GlSanWndMoveLengthGlSanWinds)) then
			begin
			GlSanWndMove:=false;
			fillchar(GlSanWndMoveKoor,sizeof(GlSanWndMoveKoor),0);
			end
		else
			begin
			if GlSanReadKey=27 then
				begin
				wck:=GlSanFindEndOfWnd;
				Wck^.Ovl:=GlSanWndMoveKoor[1];
				Wck^.ONP:=GlSanWndMoveKoor[2];
				Wck^.ONZP:=GlSanWndMoveKoor[3];
				GlSanWndMove:=false;
				GlSanSetKey(0);
				end
			else
				begin
				wck:=GlSanFindEndOfWnd;
				MoveKoor2f:=GlSanMouseXY(2);
				OtnMK2F.x:=MoveKoor2f.x-GlSanWndMoveKoor[4].x;
				OtnMK2f.y:=MoveKoor2f.y-GlSanWndMoveKoor[4].y;
				OtnMK2F.x/=width-2*rs2;
				OtnMK2F.y/=height-rz-rs1;
				Wck^.OVL.x:=GlSanWndMoveKoor[1].x+OtnMK2F.x;
				Wck^.OVL.y:=GlSanWndMoveKoor[1].y+OtnMK2F.y;
				Wck^.ONP.x:=GlSanWndMoveKoor[2].x+OtnMK2F.x;
				Wck^.ONP.y:=GlSanWndMoveKoor[2].y+OtnMK2F.y;
				Wck^.ONZP.x:=GlSanWndMoveKoor[3].x+OtnMK2F.x;
				Wck^.ONZP.y:=GlSanWndMoveKoor[3].y+OtnMK2F.y;
				end;
			end;
		SGMouseCoords[0].Import(0,0);
		end
	else
		if UsheVibMove then
			begin
			GlSanWndMove:=true;
			wck:=GlSanFindEndOfWnd;
			GlSanWndMoveKoor[1]:=Wck^.OVL;
			GlSanWndMoveKoor[2]:=Wck^.ONP;
			GlSanWndMoveKoor[3]:=Wck^.ONZP;
			GlSanWndMoveKoor[4]:=GlSanMouseXY(2);
			GlSanWndMoveLengthGlSanWinds:=Length(GlSanWinds);
			SanWndEditRedFl:=false;
			end;
	{Подсветка и вход в GlSanWndComboBox}
	if IsContextFree then
		begin
		Wck:=GlSanFindEndOfWnd;
		for i:=Low(Wck^.ArComboBox) to High(Wck^.ArComboBox) do
			begin
			GlSanWndFindKoorOfComboBox(Wck,i,wvl,wnp);
			if GlSanWndPrinKoor(WVL,WNP,CurKoor) then
				begin
				if (SanWndComboBoxFl and (SanWndComboBoxPWnd<>Wck) and (SanWndComboBoxI<>i)) or (not SanWndComboBoxFl) then
					if SGIsMouseKeyDown(1) then
						Wck^.ArComboBox[i].InitC(Wck^.TVL,Wck^.TNP,Wck^.Al,1,
								GlSanColor4fImport(1,1,1,0.5),
								GlSanColor4fImport(1,1,1,0.6),
								GlSanColor4fImport(1,1,1,0.30),
								GlSanColor4fImport(1,1,1,0.40))
					else
						Wck^.ArComboBox[i].InitC(Wck^.TVL,Wck^.TNP,Wck^.Al,1,
								GlSanColor4fImport(0,1,1,0.5),
								GlSanColor4fImport(0,1,1,0.6),
								GlSanColor4fImport(0,1,1,0.30),
								GlSanColor4fImport(0,1,1,0.40));
				if (GlMouseReadKey=4) then
					begin
					if not (SanWndComboBoxFl and (SanWndComboBoxPWnd=Wck) and (SanWndComboBoxI=i)) then
						begin
						RNRPlayAudioNotError('SystemButton2');
						GlMouseReadKey:=0;
						if SanWndComboBoxFl then
							begin
							SanWndComboBoxPWnd^.ArComboBox[SanWndComboBoxI].Open:=false;
							SanWndComboBoxFl:=false;
							SanWndComboBoxPWnd:=nil;
							SanWndComboBoxI:=-1;
							end;
						SanWndComboBoxFl:=true;
						SanWndComboBoxPWnd:=Wck;
						SanWndComboBoxI:=i;
						Wck^.ArComboBox[i].Open:=true;
						end
					else;
					end;
				end;
			end;
		end;
	{Обработка GlSanWndComboBox}
	if SanWndComboBoxFl then
		begin
		Wck:=GlSanFindEndOfWnd;
		if (Wck<>SanWndComboBoxPWnd)or(GlSanReadKey=27)or(SanWndEditRedFl)or(GlSanWndListBoxMoveButton)or(GlSanWndMove)
			or ((GlMouseReadKey in [1..3])and(not (GlSanWndPrinKoor(
				Wck^.ArComboBox[SanWndComboBoxI].bvl,Wck^.ArComboBox[SanWndComboBoxI].bnnp,CurKoor))))then
			begin
			if GlSanReadKey=27 then GlSanSetKey(0);
			SanWndComboBoxPWnd^.ArComboBox[SanWndComboBoxI].Open:=false;
			SanWndComboBoxFl:=false;
			SanWndComboBoxPWnd:=nil;
			SanWndComboBoxI:=-1;
			end
		else
			begin
			if GlSanWndPrinKoor(Wck^.ArComboBox[SanWndComboBoxI].bvl,Wck^.ArComboBox[SanWndComboBoxI].bnnp,CurKoor) then
				begin
				i:=1;
				IB:=false;
				IR:=abs(Wck^.ArComboBox[SanWndComboBoxI].bvl.y-Wck^.ArComboBox[SanWndComboBoxI].bnnp.y)/Length(Wck^.ArComboBox[SanWndComboBoxI].Text);
				while (i<>Length(wck^.ArComboBox[SanWndComboBoxI].Text)+1) and (not IB) do
					begin
					wvl.Import(Wck^.ArComboBox[SanWndComboBoxI].BVL.x,
						Wck^.ArComboBox[SanWndComboBoxI].BVL.y-(IR*(i-1)),
						Wck^.ArComboBox[SanWndComboBoxI].BVL.z);
					wnp.Import(Wck^.ArComboBox[SanWndComboBoxI].BNP.x,
						Wck^.ArComboBox[SanWndComboBoxI].BVL.y-(IR*I),
						Wck^.ArComboBox[SanWndComboBoxI].BVL.z);
					if GlSanWndPrinKoor(wvl,wnp,CurKoor) then
						begin
						IB:=true;
						end;
					i+=1;
					end;
				if SGIsMouseKeyDown(1) then
					begin
					glcolor4f(0,0.5,0.25,0.17);
					GlSanRoundQuad(wvl,wnp,GetRadOkr(wvl,wnp,GlSanRast(wvl,wnp)/30),4);
					glcolor4f(0,0.5,0.25,0.24);
					GlSanRoundQuadLines(wvl,wnp,GetRadOkr(wvl,wnp,GlSanRast(wvl,wnp)/30),4);
					end
				else
					begin
					glcolor4f(1,0,1,0.17);
					GlSanRoundQuad(wvl,wnp,GetRadOkr(wvl,wnp,GlSanRast(wvl,wnp)/30),4);
					glcolor4f(1,0,1,0.24);
					GlSanRoundQuadLines(wvl,wnp,GetRadOkr(wvl,wnp,GlSanRast(wvl,wnp)/30),4);
					end;
				if GlMouseReadKey=4 then
					begin
					RNRPlayAudioNotError('SystemButton4');
					GlMouseReadKey:=0;
					SGMouseKeysDown[1]:=false;
					SanWndComboBoxPWnd^.ArComboBox[SanWndComboBoxI].Open:=false;
					SanWndComboBoxPWnd^.ArComboBox[SanWndComboBoxI].Position:=i-2;
					SanWndComboBoxFl:=false;
					SanWndComboBoxPWnd:=nil;
					SanWndComboBoxI:=-1;
					end;
				CurKoor.Import(0,0,0);
				end;
			end;
		end;
	{Обработка нажатий на кнопки окон и подсветка окон при этом}
	if IsContextFree then
		begin
		wck:=GlSanFindEndOfWnd;
		if ((Wck^.MTelo) or (not GlSanWndMove)) then
			begin
			if Length(Wck^.ArButtons)>0 then
				begin
				GlSanWndFindKoor(Wck,ZWindow,WVL,WnP);
				For i:=Low(Wck^.ArButtons) to High(Wck^.ArButtons) do
					begin
					if GlSanCursorOnButton(@Wck^.ArButtons[i],CurKoor,WVL,WNP) then
						begin
						if GlSanMouseB(1) then
							begin
							Wck^.ArButtons[i].InitC(WVL,WNP);
							if Wck^.ArButtons[i].SetOnOn then
								begin
								if Wck^.ArButtons[i].ProcB=nil then
									Wck^.ArButtons[i].Blan:=true
								else
									begin
									GSWBP:=GlSanWndProcedure(Wck^.ArButtons[i].ProcB);
									GSWBP(Wck);
									end;
								end;
							end
						else
							begin
							Wck^.ArButtons[i].InitOn(WVL,WNP);
							end;
						if GlSanMouseReadKey=4 then
							if Wck^.ArButtons[i].ProcB=nil then
									Wck^.ArButtons[i].Blan:=true
								else
									begin
									RNRPlayAudioNotError('SystemButton3');
									GSWBP:=GlSanWndProcedure(Wck^.ArButtons[i].ProcB);
									GSWBP(Wck);
									end;
						if Length(Wck^.ArButtons[i].Hint.STR)<>0 then
							begin
							{Hints}
							Wck^.ArButtons[i].Hint.MaxLength:=0;
							for ii:=Low(Wck^.ArButtons[i].Hint.str) to High(Wck^.ArButtons[i].Hint.str) do
								if GlSanTextLength(Wck^.ArButtons[i].Hint.str[ii],HintZum)>Wck^.ArButtons[i].Hint.MaxLength then
									Wck^.ArButtons[i].Hint.MaxLength:=GlSanTextLength(Wck^.ArButtons[i].Hint.str[ii],HintZum);
							if (ActiveSkin=-1) or (ArSkins[ActiveSkin].HintTexture=-1) then
								begin
								if GlSanMouseXY(2).x<width/2 then
									begin
									Glcolor4f(1,1,0,0.8);
									GlSanRoundQuad(
										GlSanKoorImport(CurKoor.x+0.004,CurKoor.y,CurKoor.z),
										GlSanKoorImport(CurKoor.x+Wck^.ArButtons[i].Hint.MaxLength+0.004,
											CurKoor.y-2*HintZum*Length(Wck^.ArButtons[i].Hint.str),CurKoor.z),
										GetRadOkr(
											GlSanKoorImport(CurKoor.x+0.004,CurKoor.y,CurKoor.z),
											GlSanKoorImport(CurKoor.x+Wck^.ArButtons[i].Hint.MaxLength+0.004,CurKoor.y-2*HintZum,CurKoor.z),
											HintZum),4);
									Glcolor4f(0,1,0,0.8);
									GlSanRoundQuadLines(
										GlSanKoorImport(CurKoor.x+0.004,CurKoor.y,CurKoor.z),
										GlSanKoorImport(CurKoor.x+Wck^.ArButtons[i].Hint.MaxLength+0.004,
											CurKoor.y-2*HintZum*Length(Wck^.ArButtons[i].Hint.str),CurKoor.z),
										GetRadOkr(
											GlSanKoorImport(CurKoor.x+0.004,CurKoor.y,CurKoor.z),
											GlSanKoorImport(CurKoor.x+Wck^.ArButtons[i].Hint.MaxLength+0.004,CurKoor.y-2*HintZum,CurKoor.z),
											HintZum),4);
									Glcolor4f(0,0,0,0.8);
									for ii:=Low(Wck^.ArButtons[i].Hint.str) to High(Wck^.ArButtons[i].Hint.str) do
										GlSanOutTextS(
											GlSanKoorImport(CurKoor.x+0.004,
												CurKoor.y-2*HintZum*ii,CurKoor.z),
											GlSanKoorImport(CurKoor.x+0.004+Wck^.ArButtons[i].Hint.MaxLength,
												CurKoor.y-2*HintZum*(ii+1),CurKoor.z),
											Wck^.ArButtons[i].Hint.str[ii],
											HintZum);
									end
								else
									begin
									Glcolor4f(1,1,0,0.8);
									GlSanRoundQuad(
										GlSanKoorImport(CurKoor.x-Wck^.ArButtons[i].Hint.MaxLength-0.004,
											CurKoor.y,CurKoor.z),
										GlSanKoorImport(CurKoor.x-0.004,CurKoor.y-2*HintZum*Length(Wck^.ArButtons[i].Hint.str),CurKoor.z),
										GetRadOkr(
											GlSanKoorImport(CurKoor.x-Wck^.ArButtons[i].Hint.MaxLength-0.004,CurKoor.y,CurKoor.z),
											GlSanKoorImport(CurKoor.x-0.004,CurKoor.y-2*HintZum,CurKoor.z),
											HintZum),4);
									Glcolor4f(0,1,0,0.8);
									GlSanRoundQuadLines(
										GlSanKoorImport(CurKoor.x-Wck^.ArButtons[i].Hint.MaxLength-0.004,
											CurKoor.y,CurKoor.z),
										GlSanKoorImport(CurKoor.x-0.004,CurKoor.y-2*HintZum*Length(Wck^.ArButtons[i].Hint.str),CurKoor.z),
										GetRadOkr(
											GlSanKoorImport(CurKoor.x-Wck^.ArButtons[i].Hint.MaxLength-0.004,CurKoor.y,CurKoor.z),
											GlSanKoorImport(CurKoor.x-0.004,CurKoor.y-2*HintZum,CurKoor.z),
											HintZum),4);
									Glcolor4f(0,0,0,0.8);
									for ii:=Low(Wck^.ArButtons[i].Hint.str) to High(Wck^.ArButtons[i].Hint.str) do
										GlSanOutTextS(
											GlSanKoorImport(CurKoor.x-0.004,
												CurKoor.y-2*HintZum*ii,CurKoor.z),
											GlSanKoorImport(CurKoor.x-0.004-Wck^.ArButtons[i].Hint.MaxLength,
												CurKoor.y-2*HintZum*(ii+1),CurKoor.z),
											Wck^.ArButtons[i].Hint.str[ii],
											HintZum);
									end;
								end
							else
								begin
								if GlSanMouseXY(2).x<width/2 then
									begin
									ArSkins[ActiveSkin].ArHintTextureColor[1].Color;
									GlSanDrawComponent9(
										GlSanKoorImport(CurKoor.x+0.004,CurKoor.y,CurKoor.z),
										GlSanKoorImport(CurKoor.x+Wck^.ArButtons[i].Hint.MaxLength+0.004,
											CurKoor.y-2*HintZum*Length(Wck^.ArButtons[i].Hint.str),CurKoor.z),
										GetRadOkr(
											GlSanKoorImport(CurKoor.x+0.004,CurKoor.y,CurKoor.z),
											GlSanKoorImport(CurKoor.x+Wck^.ArButtons[i].Hint.MaxLength+0.004,CurKoor.y-2*HintZum,CurKoor.z),
											HintZum),
										ArSkins[ActiveSkin].ArRealHint[Low(ArSkins[ActiveSkin].ArRealHint)+0],
										ArSkins[ActiveSkin].ArRealHint[Low(ArSkins[ActiveSkin].ArRealHint)+1],
										ArSkins[ActiveSkin].ArRealHint[Low(ArSkins[ActiveSkin].ArRealHint)+2],
										ArSkins[ActiveSkin].ArRealHint[Low(ArSkins[ActiveSkin].ArRealHint)+3],
										ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].HintTexture]);
									ArSkins[ActiveSkin].ArHintTextureColor[2].Color;
									for ii:=Low(Wck^.ArButtons[i].Hint.str) to High(Wck^.ArButtons[i].Hint.str) do
										GlSanOutTextS(
											GlSanKoorImport(CurKoor.x+0.004,
												CurKoor.y-2*HintZum*ii,CurKoor.z),
											GlSanKoorImport(CurKoor.x+0.004+Wck^.ArButtons[i].Hint.MaxLength,
												CurKoor.y-2*HintZum*(ii+1),CurKoor.z),
											Wck^.ArButtons[i].Hint.str[ii],
											HintZum);
									end
								else
									begin
									ArSkins[ActiveSkin].ArHintTextureColor[1].Color;
									GlSanDrawComponent9(
										GlSanKoorImport(CurKoor.x-Wck^.ArButtons[i].Hint.MaxLength-0.004,
											CurKoor.y,CurKoor.z),
										GlSanKoorImport(CurKoor.x-0.004,CurKoor.y-2*HintZum*Length(Wck^.ArButtons[i].Hint.str),CurKoor.z),
										GetRadOkr(
											GlSanKoorImport(CurKoor.x-Wck^.ArButtons[i].Hint.MaxLength-0.004,CurKoor.y,CurKoor.z),
											GlSanKoorImport(CurKoor.x-0.004,CurKoor.y-2*HintZum,CurKoor.z),
											HintZum),
										ArSkins[ActiveSkin].ArRealHint[Low(ArSkins[ActiveSkin].ArRealHint)+0],
										ArSkins[ActiveSkin].ArRealHint[Low(ArSkins[ActiveSkin].ArRealHint)+1],
										ArSkins[ActiveSkin].ArRealHint[Low(ArSkins[ActiveSkin].ArRealHint)+2],
										ArSkins[ActiveSkin].ArRealHint[Low(ArSkins[ActiveSkin].ArRealHint)+3],
										ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].HintTexture]);
									ArSkins[ActiveSkin].ArHintTextureColor[2].Color;
									for ii:=Low(Wck^.ArButtons[i].Hint.str) to High(Wck^.ArButtons[i].Hint.str) do
										GlSanOutTextS(
											GlSanKoorImport(CurKoor.x-0.004,
												CurKoor.y-2*HintZum*ii,CurKoor.z),
											GlSanKoorImport(CurKoor.x-0.004-Wck^.ArButtons[i].Hint.MaxLength,
												CurKoor.y-2*HintZum*(ii+1),CurKoor.z),
											Wck^.ArButtons[i].Hint.str[ii],
											HintZum);
									end;
								end;
							end;
						end;
					end;
				end;
			end;
		end;
	{Обработка GlSanWndListBox и иго кнопок}
	if IsContextFree then
		begin
		wck:=GlSanFindEndOfWnd;
		for i:=Low(Wck^.ArListBox) to High(Wck^.ArListBox) do
			begin
			GlSanWndListBoxFindKoor(Wck,i,WVL,WnP);
			for ii:=Low(Wck^.ArListBox[i].ArButtons) to High(Wck^.ArListBox[i].ArButtons) do
				begin
				if GlSanCursorOnButton(@Wck^.ArListBox[i].ArButtons[ii],CurKoor,WVL,WNP) then
					begin
					if SGIsMouseKeyDown(1) then
						begin
						if ii<>3 then Wck^.ArListBox[i].ArButtons[ii].InitC(WVL,WNP);
						if Wck^.ArListBox[i].ArButtons[ii].SetOnOn then
							Wck^.ArListBox[i].ArButtons[ii].Blan:=true;
						if ((ii=3) and (GlSanWndListBoxMoveButton=false) and (GlSanMouseReadKey=1)) then
							begin
							GlSanWndListBoxMoveButton:=true;
							GlSanWndListBoxMoveButtonLengthGlSanWinds:=Length(GlSanWinds);
							GlSanWndListBoxMoveButtonNumber:=i;
							GlSanWndListBoxMoveButtonVG:=round(
								(abs(GlSanWndListBoxFindKB(@Wck^.ArListBox[i].ArButtons[1],3,WVL,WNP).y-GlSanWA[GlSanWndGetWANumber(GlSanWAKol-ZWindow+1),1].y)/
								abs(GlSanWA[GlSanWAKol-ZWindow+1,1].y-GlSanWA[GlSanWAKol-ZWindow+1,3].y))*san.height);
							GlSanWndListBoxMoveButtonNG:=round(
								(abs(GlSanWndListBoxFindKB(@Wck^.ArListBox[i].ArButtons[2],1,WVL,WNP).y-GlSanWA[GlSanWndGetWANumber(GlSanWAKol-ZWindow+1),1].y)/
								abs(GlSanWA[GlSanWndGetWANumber(GlSanWAKol-ZWindow+1),1].y-GlSanWA[GlSanWndGetWANumber(GlSanWAKol-ZWindow+1),3].y))*san.height);
							GlSanWndListBoxMoveButtonVG+=19;
							GlSanWndListBoxMoveButtonNG+=8;
							j:=Wck^.ArListBox[i].Position;
							{0000000000000000000000000000000000000000000}
							if GlSanWndListBoxMoveButtonNG<GlSanMouseXY(2).y then
								Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Position:=
									Length(Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Text)
									-round(Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Shrift.x)+1
							else
								begin
								Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Position:=round(
									(abs(GlSanWndListBoxMoveButtonVG-GlSanMouseXY(2).y)/
									abs(GlSanWndListBoxMoveButtonVG-GlSanWndListBoxMoveButtonNG))
									*Length(Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Text));
								if Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Position+
									round(Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Shrift.x)>
									Length(Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Text) then
										Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Position:=
											Length(Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Text)-
											round(Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Shrift.x)+1;
								if Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Position=0 then
									Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Position:=1;
								END;
							{1111111111111111111111111111111111111111111}
							GlSanWndListBoxMoveButtonPositionMinus:=
								abs(j-Wck^.ArListBox[i].Position);
							{==writeln(GlSanWndListBoxMoveButtonVG,' ',GlSanWndListBoxMoveButtonNG,' ',GlSanMouseXY(2).y:0:5);}
							end;
						end
					else
						begin
						Wck^.ArListBox[i].ArButtons[ii].InitOn(WVL,WNP);
						end;
					if GlSanMouseReadKey=4 then
						Wck^.ArListBox[i].ArButtons[ii].Blan:=true;
					end;
				end;
			end;
		end;
	{Обработка правой хрени на ListBoxe}
	if GlSanWndListBoxMoveButton then
		begin
		wck:=GlSanFindEndOfWnd;
		GlSanWndListBoxFindKoor(Wck,GlSanWndListBoxMoveButtonNumber,WVL,WnP);
		Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].ArButtons[3].InitC(WVL,WNP);
		if SGIsMouseKeyDown(1) and (GlSanWndListBoxMoveButtonLengthGlSanWinds=Length(GlSanWinds)) then
			begin
			if GlSanMouseXY(2).y<GlSanWndListBoxMoveButtonVG then
				Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Position:=1
			else
				begin
				if GlSanWndListBoxMoveButtonNG<GlSanMouseXY(2).y then
					Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Position:=
						Length(Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Text)
						-round(Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Shrift.x)+1
				else
					begin
					Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Position:=round(
						(abs(GlSanWndListBoxMoveButtonVG-GlSanMouseXY(2).y)/
						abs(GlSanWndListBoxMoveButtonVG-GlSanWndListBoxMoveButtonNG))
						*Length(Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Text))
						-GlSanWndListBoxMoveButtonPositionMinus;
					if Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Position+
						round(Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Shrift.x)>
						Length(Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Text) then
							Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Position:=
								Length(Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Text)-
								round(Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Shrift.x)+1;
					if Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Position<1 then
						Wck^.ArListBox[GlSanWndListBoxMoveButtonNumber].Position:=1;
					end;
				end;
			end
		else
			begin
			GlSanWndListBoxMoveButton:=false;
			GlSanWndListBoxMoveButtonNumber:=0;
			GlSanWndListBoxMoveButtonVG:=0;
			GlSanWndListBoxMoveButtonNG:=0;
			GlSanWndListBoxMoveButtonPositionMinus:=0;
			GlSanWndListBoxMoveButtonLengthGlSanWinds:=0;
			end;
		SGMouseCoords[0].Import(0,0);
		end;
	{Колёсико в GlSasnWndListBox}
	if ((LongInt(SGMouseWheelVariable)<>0) and (GlSanMXYZT(CurKoor))) and (IsContextFree) then
		begin
		wck:=GlSanFindEndOfWnd;
		for i:=Low(Wck^.ArListBox) to High(Wck^.ArListBox) do
			begin
			GlSanWndListBoxFindKoor(Wck,i,WVL,WnP);
			if GlSanWndPrinKoor(WVL,WNP,CurKoor) then
				begin
				case LongInt(SGMouseWheelVariable) of
				-1:Wck^.ArListBox[i].Position:=Wck^.ArListBox[i].Position-1;
				1:Wck^.ArListBox[i].Position:=Wck^.ArListBox[i].Position+1;
				end;
				if Wck^.ArListBox[i].Position<1 then
					Wck^.ArListBox[i].Position:=1
				else
					if Wck^.ArListBox[i].Position+round(Wck^.ArListBox[i].Shrift.x)>Length(Wck^.ArListBox[i].Text) then
						Wck^.ArListBox[i].Position:=Length(Wck^.ArListBox[i].Text)-round(Wck^.ArListBox[i].Shrift.x)+1;
				SGSetMouseWheel(0);
				end;
			end;
		end;
	{Выбор пункта в GlSanWndListBox}
	if IsContextFree then
		begin
		wck:=GlSanFindEndOfWnd;
		for i:=low(Wck^.ArListBox) to high(Wck^.ArListBox) do
			begin
			GlSanWndListBoxFindKoor(Wck,i,WVL,WnP);
			WNP.x:=Wnp.x-2*Wck^.ArListBox[i].Ro;
			Wck^.ArListBox[i].PositionOn:=-2;
			if Wck^.ArListBox[i].MV and GlSanWndPrinKoor(WVL,WNP,CurKoor) then
				begin
				ii:=0;
				Wck^.ArListBox[i].PositionOn:=-1;
				while WVL.y>=CurKoor.y do
					begin
					WVL.y:=WVL.y-2*(Wck^.ArListBox[i].Ro+0.000001);
					ii:=ii+1;
					end;
				WNP.y:=WVL.y;
				WVL.y:=WVL.y+2*Wck^.ArListBox[i].Ro;
				if ((ii+Wck^.ArListBox[i].Position-2>=Low(Wck^.ArListBox[i].Text)) and (ii+Wck^.ArListBox[i].Position-2<=High(Wck^.ArListBox[i].Text))) then
					begin
					glcolor4f(0.8,0.8,0,0.2);
					GlSanRoundQuad(WVL,WNP,Wck^.ArListBox[i].Ro,4);
					GlSanRoundQuadLines(WVL,WNP,Wck^.ArListBox[i].Ro,4);
					Wck^.ArListBox[i].PositionOn:=ii;
					end;
				if (GlSanMouseReadKey=1)or(GlSanMouseReadKey=2) then
					begin
					if ((ii+Wck^.ArListBox[i].Position-2>=Low(Wck^.ArListBox[i].Text)) and (ii+Wck^.ArListBox[i].Position-2<=High(Wck^.ArListBox[i].Text))) then
						begin
						if Wck^.ArListBox[i].MVPos<>ii+Wck^.ArListBox[i].Position-1 then
							RNRPlayAudioNotError('SystemButton2');
						Wck^.ArListBox[i].MVPos:=ii+Wck^.ArListBox[i].Position-1;
						if (GlSanMouseReadKey=1) then begin SGMouseKeysDown[1]:=false;GlMouseReadKey:=0;end;
						if (GlSanMouseReadKey=2) then begin SGMouseKeysDown[2]:=false;GlMouseReadKey:=0;end;
						end;
					end;
				if (GlSanReadKey=13)then
					Wck^.ArListBox[i].Button:=true;
				end;
			end;
		end
	else
		begin
		wck:=GlSanFindEndOfWnd;
		for i:=low(Wck^.ArListBox) to high(Wck^.ArListBox) do
			Wck^.ArListBox[i].PositionOn:=-2;
		end;
	{Обработка Edit-a}
	if (SanWndEditRedFl=false) and IsContextFree then
		begin
		wck:=GlSanFindEndOfWnd;
		for i:=Low(wck^.ArEdit) to High(wck^.ArEdit) do
			begin
			GlSanWndFindKoorOfEdit(Wck,i,wvl,wnp);
			if GlSanWndPrinKoor(WVL,WNP,CurKoor) then
				begin
				wck^.ArEdit[i].InitC(wck^.tvl,wck^.tnp,wck^.al,-1,
					GlSanColor4fImport(0,1,1,0.2),
					GlSanColor4fImport(0,1,1,0.1),
					GlSanColor4fImport(0,1,1,0.1),
					GlSanColor4fImport(1,0,0,0.6));
				if GlSanMouseReadKey=1 then
					begin
					RNRPlayAudioNotError('SystemButton2');
					SanWndEditRedFl:=true;
					SanWndEditRedLostWnd:=Wck;
					SanWndEditRedSimbol:=Length(wck^.ArEdit[i].Caption);
					SanWndEditRedI:=i;
					wck^.ArEdit[i].LostCaption:=wck^.ArEdit[i].Caption;
					end;
				end;
			end;
		end;
	{Ввод тккста в Edit}
	if SanWndEditRedFl then
		begin
		wck:=GlSanFindEndOfWnd;
		if Wck=SanWndEditRedLostWnd then
			begin
			wck^.ArEdit[SanWndEditRedI].InitC(wck^.tvl,wck^.tnp,wck^.al,SanWndEditRedSimbol,
				GlSanColor4fImport(1,1,1,0.5),
				GlSanColor4fImport(1,1,1,1),
				GlSanColor4fImport(0,0,0,1),
				GlSanColor4fImport(1,0,0,1));
			if GlSanKeyPressed then
				begin
				if not (GlSanReadKey in [8,13,27,39,37,46,36,35,16,17,9]) then
					begin
					wck^.ArEdit[SanWndEditRedI].Caption:=
						system.copy(wck^.ArEdit[SanWndEditRedI].Caption,1,SanWndEditRedSimbol)
						+GlSanWhatIsTheSimbol(LongInt(SGKeyPressedVariable))
						+copy(wck^.ArEdit[SanWndEditRedI].Caption,SanWndEditRedSimbol+1,length(wck^.ArEdit[SanWndEditRedI].Caption));
					if Length(GlSanWhatIsTheSimbol(LongInt(SGKeyPressedVariable)))>0 then
						SanWndEditRedSimbol+=Length(GlSanWhatIsTheSimbol(LongInt(SGKeyPressedVariable)))
					else
						RNRPlayRamdomNo;
					end
				else
					begin
					case GlSanReadKey of
					13:begin SanWndEditRedFl:=false; GlSanSetKey(0); end;
					27:
						begin
						SanWndEditRedFl:=false;
						GlSanSetKey(0);
						wck^.ArEdit[SanWndEditRedI].Caption:=wck^.ArEdit[SanWndEditRedI].LostCaption;
						end;
					8:if SanWndEditRedSimbol<>0 then
						begin
						wck^.ArEdit[SanWndEditRedI].Caption:=
							system.copy(wck^.ArEdit[SanWndEditRedI].Caption,1,SanWndEditRedSimbol-1)
							+copy(wck^.ArEdit[SanWndEditRedI].Caption,SanWndEditRedSimbol+1,length(wck^.ArEdit[SanWndEditRedI].Caption));
						SanWndEditRedSimbol-=1;
						end;
					37:if SanWndEditRedSimbol<>0 then
						SanWndEditRedSimbol-=1;
					39:if SanWndEditRedSimbol<>Length(wck^.ArEdit[SanWndEditRedI].Caption) then
						SanWndEditRedSimbol+=1;
					46:if SanWndEditRedSimbol<>Length(wck^.ArEdit[SanWndEditRedI].Caption) then
						begin
						wck^.ArEdit[SanWndEditRedI].Caption:=
							system.copy(wck^.ArEdit[SanWndEditRedI].Caption,1,SanWndEditRedSimbol)
							+copy(wck^.ArEdit[SanWndEditRedI].Caption,SanWndEditRedSimbol+2,length(wck^.ArEdit[SanWndEditRedI].Caption));
						end;
					36:SanWndEditRedSimbol:=0;
					35:SanWndEditRedSimbol:=Length(wck^.ArEdit[SanWndEditRedI].Caption);
					end;
					end;
				end;
			GlSanWndFindKoorOfEdit(Wck,SanWndEditRedI,wvl,wnp);
			if (GlSanMouseReadKey in [1..3] ) and (not (GlSanWndPrinKoor(WVL,WNP,CurKoor)))  then
				begin
				SanWndEditRedFl:=false;
				end;
			end
		else
			begin
			SanWndEditRedFl:=false;
			end;
		end;
	{Обработка CheckBox}
	if IsContextFree then
		begin
		wck:=GlSanFindEndOfWnd;
		for i:=Low(Wck^.ArCheckBox) to High(wck^.ArCheckBox) do
			begin
			GlSanWndFindKoorOfCheckBox(wck,i,wvl,wnp);
			if GlSanWndPrinKoor(WVL,WNP,CurKoor) then
				begin
				if SGIsMouseKeyDown(1) then
					begin
					if (ActiveSkin=-1) or ((ArSkins[ActiveSkin].CheckBoxTexture2=-1)and Wck^.ArCheckBox[i].Caption) or 
						((ArSkins[ActiveSkin].CheckBoxTexture4=-1)and (not Wck^.ArCheckBox[i].Caption)) then
						begin
						glcolor4f(1,1,1,0.3);
						GlSanRoundQuad(wvl,wnp,GlSanRast(wvl,wnp)/50,2);
						glcolor4f(1,1,1,0.8);
						GlSanRoundQuadLines(wvl,wnp,GlSanRast(wvl,wnp)/50,2);
						end
					else
						begin
						glcolor4f(0.5,1,0.5,1);
						glEnable(GL_TEXTURE_2D);
						if Wck^.ArCheckBox[i].Caption then 
							begin
							GlSanBindTexture(ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].CheckBoxTexture2]);
							if Length(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)>1 then
								WndSomeQuad(wvl,wnp,
									ArSkins[ActiveSkin].ArCheckBoxKoorTextures[Low(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)+1][1],
									ArSkins[ActiveSkin].ArCheckBoxKoorTextures[Low(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)+1][2])
							else
								WndSomeQuad(wvl,wnp);
							end
						else
							begin
							GlSanBindTexture(ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].CheckBoxTexture4]);
							if Length(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)>3 then
								WndSomeQuad(wvl,wnp,
									ArSkins[ActiveSkin].ArCheckBoxKoorTextures[Low(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)+3][1],
									ArSkins[ActiveSkin].ArCheckBoxKoorTextures[Low(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)+3][2])
							else
								WndSomeQuad(wvl,wnp);
							end;
						glDisable(GL_TEXTURE_2D);
						end;
					end
				else
					begin
					if (ActiveSkin=-1) or ((ArSkins[ActiveSkin].CheckBoxTexture2=-1)and Wck^.ArCheckBox[i].Caption) or 
						((ArSkins[ActiveSkin].CheckBoxTexture4=-1)and (not Wck^.ArCheckBox[i].Caption)) then
						begin
						glcolor4f(0,1,1,0.3);
						GlSanRoundQuad(wvl,wnp,GlSanRast(wvl,wnp)/50,2);
						glcolor4f(0,1,1,0.8);
						GlSanRoundQuadLines(wvl,wnp,GlSanRast(wvl,wnp)/50,2);
						end
					else
						begin
						glcolor4f(1,1,1,1);
						glEnable(GL_TEXTURE_2D);
						if Wck^.ArCheckBox[i].Caption then 
							begin
							GlSanBindTexture(ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].CheckBoxTexture2]);
							if Length(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)>1 then
								WndSomeQuad(wvl,wnp,
									ArSkins[ActiveSkin].ArCheckBoxKoorTextures[Low(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)+1][1],
									ArSkins[ActiveSkin].ArCheckBoxKoorTextures[Low(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)+1][2])
							else
								WndSomeQuad(wvl,wnp);
							end
						else
							begin
							GlSanBindTexture(ArSkins[ActiveSkin].ArTextures[ArSkins[ActiveSkin].CheckBoxTexture4]);
							if Length(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)>3 then
								WndSomeQuad(wvl,wnp,
									ArSkins[ActiveSkin].ArCheckBoxKoorTextures[Low(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)+3][1],
									ArSkins[ActiveSkin].ArCheckBoxKoorTextures[Low(ArSkins[ActiveSkin].ArCheckBoxKoorTextures)+3][2])
							else
								WndSomeQuad(wvl,wnp);
							end;
						glDisable(GL_TEXTURE_2D);
						end;
					end;
				if GlMouseReadKey=4 then
					begin
					RNRPlayAudioNotError('SystemButton2');
					wck^.ArCheckBox[i].Caption:=not wck^.ArCheckBox[i].Caption;
					end;
				end;
			end;
		end;
	{$NOTE GlSanWindows ( End )}
	{Окончательное закрытие окон}
	i:=Low(GlSanWinds);
	repeat
	wck:=GlSanWinds[i];
	if (Wck^.ExitP) then
		begin
		wck^.ExitI+=1;
		if wck^.ExitI>25 then
			begin
			GlSanWndKill(i);
			end
		else
			i+=1;
		end
	else
		begin
		i+=1;
		end;
	until (i>=High(GlSanWinds)+1);
	{КоНеЦ}
	glEnable(GL_LIGHTING);
	end;
{Processing GlSanContextMenu}
if ContextMenuSled<>nil then
	begin
	if ContextMenu<>nil then
		ContextMenu^.CloseContext;
	ContextMenu:=ContextMenuSled;
	ContextMenuSled:=nil;
	glcolor4f(0,0,0,0);
	GLBEGIN(GL_QUADS);
	GlSanWA[0,1].Vertex;
	GlSanWA[0,2].Vertex;
	GlSanWA[0,3].Vertex;
	GlSanWA[0,4].Vertex;
	GLEND();
	CurKoor:=GlSanReadMouseXYZ;
	ContextMenuStartKoor:=CurKoor;
	ContextMenu^.StartKoor:=CurKoor;
	ContextMenu^.OpenTipe:=1;
	ContextMenu^.OpenProgress:=0;
	ContextMenu^.ReInitMaxLength;
	ContextMenu^.ReTipe;
	ContextMenu^.ReKoor;
	end;
GlLoadIdentity;
end;

function GlSanMXYZT(const k:GlSanKoor):boolean;
begin
GlSanMXYZT:=true;
if (abs(k.x)>1000) or (abs(k.y)>1000) or (abs(k.z)>1000) then
	GlSanMXYZT:=false;
end;

function GlSanRast(const a1,b:GlSanKoor):real;
begin
GlSanRast:=sqrt(sqr(a1.x-b.x)+sqr(a1.y-b.y)+sqr(a1.z-b.z));
end;

function GlSanReadCamXYZ(const r:GlSanKoor2f):GlSanKoor;
begin
GlSanReadCamXYZ:=GlSanReadKoor(Gl_SAN_VIEW_FIRST,r);
end;

function GlSanReadCamRast(const r:GlSanKoor2f):real;
begin
GlSanReadCamRast:=GlSanReadABS(Gl_SAN_VIEW_FIRST,r);
end;

function GlSanReadMouseXYZ:GlSanKoor;
begin
GlSanReadMouseXYZ:=GlSanReadKoor(Gl_SAN_VIEW_FIRST,GlSanKoor2fImport(GlSanMouseXY(2).x,GlSanMouseXY(2).y))
end;

function GlSanStrReal(r:real;const l:longint):string;
label 1;
var
	i:longint;
	st:string;
begin
if r<0 then  st:='-' else st:='';
r:=abs(r);
if r=0 then goto 1;
st+=GlSanStr(trunc(r));
if r=0 then goto 1;
r-=trunc(r);
r:=abs(r);
if r=0 then goto 1;
st+='.';
for i:=1 to l do
	begin
	if r=0 then goto 1;
	r*=10;
	st+=GlSanStr(trunc(r));
	r-=trunc(r);
	end;
1:
if st='' then st:='0';
GlSanStrReal:=st;
end;

function GlSanKoor2fImport(const a,b:real):GlSanKoor2f;
begin
GlSanKoor2fImport.x:=a;
GlSanKoor2fImport.y:=b;
end;

procedure ONOFFDELAY(Wnd:pointer);
begin
if FPSUser then
	FPSUser:=false
else
	if glSanDON then
		glSanDON:=false
	else
		glSanDON:=true;
end;
procedure GlSanKillThisWindow(Wnd:pointer);
begin
GlSanKillWnd(@Wnd);
end;
procedure ProcKD(DelayWindow:pointer);
const
	ar:array[1..5] of GlSanWndTextChv = (((a:0;b:0.8;c:0;d:0.8),(a:0;b:0.5;c:0;d:0.5)),
								((a:0.8;b:0.8;c:0;d:0.8),(a:0.5;b:0.5;c:0;d:0.5)),
								((a:0.8;b:0;c:0;d:0.8),(a:0.5;b:0;c:0;d:0.5)),
								((a:0.8;b:0;c:0.8;d:0.8),(a:0.5;b:0;c:0.5;d:0.5)),
								((a:0.4;b:0;c:0.8;d:0.8),(a:0.25;b:0;c:0.5;d:0.5)));
var
	UM:^GlSanWndUserMemory;
	s:string;
	i:longint;
	b:boolean=false;
begin
UM:=GlSanWndGetPointerOfUserMemory(@DelayWindow);
if GlSanWndGetPositionFromComboBox(@DelayWindow,1)<>UM^.ArLongint[0] then
	begin
	UM^.ArLongint[0]:=GlSanWndGetPositionFromComboBox(@DelayWindow,1);
	case GlSanWndGetPositionFromComboBox(@DelayWindow,1) of
	1:
		begin
		GlSanDON:=true;
		FPSUser:=false;
		end;
	2:
		begin
		GlSanDON:=false;
		FPSUser:=false;
		end;
	3:
		FPSUser:=true;
	end;
	end;
if GlSanDON and (UM^.ArLongint[0]<>1) then
	begin
	UM^.ArLongint[0]:=1;
	GlSanWndSetPositionOnComboBox(@DelayWindow,1,1);
	end;
if (not GlSanDON) and (UM^.ArLongint[0]<>2) then
	begin
	UM^.ArLongint[0]:=2;
	GlSanWndSetPositionOnComboBox(@DelayWindow,1,2);
	end;
if FPSUser and ((UM^.ArLongint[0]<>3)) then
	begin
	UM^.ArLongint[0]:=3;
	GlSanWndSetPositionOnComboBox(@DelayWindow,1,3);
	end;
if FPSUser and GlSanWndActive(@DelayWindow) then
	begin
	s:=GlSanWndGetCaptionFromEdit(@DelayWindow,1);
	b:=true;
	for i:=1 to Length(S) do
		if not (s[i] in ['0'..'9']) then
			b:=false;
	if b then
		begin
		GlSanD:=GlSanVal(s);
		end;
	end;
if FPSMoment or b then
	begin
	GlSanWndSetNewTittleText(@DelayWindow,3,GlSanStr(FPS));
	if (FPS in [55..75]) then
			begin
			GlSanWndSetNewColorText(@DelayWindow,3,ar[1])
			end
		else
			begin
			if FPS>75 then
				begin
				if FPS>90 then
					GlSanWndSetNewColorText(@DelayWindow,3,ar[5])
				else
					GlSanWndSetNewColorText(@DelayWindow,3,ar[4])
				end
			else
				begin
				if FPS<40 then
					GlSanWndSetNewColorText(@DelayWindow,3,ar[3])
				else
					GlSanWndSetNewColorText(@DelayWindow,3,ar[2])
				end
			end;
	if FPSUser then
		GlSanWndSetNewTittleText(@DelayWindow,4,'Осуществляумая задержка - '+GlSanStr(GlSanD))
	else
		if GlSanDON and (GlSanD>0) then
			GlSanWndSetNewTittleText(@DelayWindow,4,'Осуществляумая задержка - '+GlSanStr(GlSanD))
		else
			GlSanWndSetNewTittleText(@DelayWindow,4,'Задержка не осуществляется');
	end;
end;
procedure NewConfigDelayWnd(Wnd:pointer);
var
	i:longint;
begin
GlSanCreateWnd(@NewWnd,'Конфигурация Автоматической Задержки',GlSanKoor2fImport(640,200));
GlSanWndSetProc(@NewWnd,@ProcKD);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(550,160),GlSanKoor2fImport(630,190),'Закрыть',@GlSanKillThisWindow);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(5,50),GlSanKoor2fImport(250,80),'Состояние -');
GlSanWndNewComboBox(@NewWnd,GlSanKoor2fImport(260,50),GlSanKoor2fImport(630,80));
GlSanWndNewStringInComboBox(@NewWnd,1,'Автомат');
GlSanWndNewStringInComboBox(@NewWnd,1,'Отключена');
GlSanWndNewStringInComboBox(@NewWnd,1,'Установлена пользователем');
if FPSUser then
	GlSanWndSetPositionOnComboBox(@NewWnd,1,3)
else
	if GlSanDON then
		GlSanWndSetPositionOnComboBox(@NewWnd,1,1)
	else
		GlSanWndSetPositionOnComboBox(@NewWnd,1,2);
SetLength(NewWnd^.UserMemory.ArLongint,1);
NewWnd^.UserMemory.ArLongint[0]:=GlSanWndGetPositionFromComboBox(@NewWnd,1);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,90),GlSanKoor2fImport(500,120),'Количество кадров в секунду (FPS) -');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(510,90),GlSanKoor2fImport(600,120),GlSanStr(FPS));
if FPSUser then
	GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,125),GlSanKoor2fImport(630,155),'Осуществляумая задержка - '+GlSanStr(GlSanD))
else
	if GlSanDON  and (GlSanD>0) then
		GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,125),GlSanKoor2fImport(630,155),'Осуществляумая задержка - '+GlSanStr(GlSanD))
	else
		GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,125),GlSanKoor2fImport(630,155),'Задержка не осуществляется');
for i:=1 to 35 do
	GlSanWndNewStringInLintBox(@NewWnd,1,GlSanStr(i));
if FPSUser then
	GlSanWndNewEdit(@NewWnd,GlSanKoor2fImport(310,160),GlSanKoor2fImport(540,190),GlSanStr(GlSanD))
else
	GlSanWndNewEdit(@NewWnd,GlSanKoor2fImport(310,160),GlSanKoor2fImport(540,190),'Введите задержку');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(10,160),GlSanKoor2fImport(300,190),'Пользовательские установки -');
GlSanWndDispose(@NewWnd);
end;
procedure NewDelayWindow(Wnd:pointer);
begin
GlSanCreateWnd(@NewWnd,'Delay',GlSanKoor2fImport(200,100));
NewWnd^.ZagP:=false;
NewWnd^.MTelo:=true;
GlSanWndSetProc(@NewWnd,@ProcDelay);
NewWnd^.TittleSystem:='System';
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(110,10),GlSanKoor2fImport(167,35),'Откл/Вкл',@ONOFFDELAY);
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(155,42),GlSanKoor2fImport(196,62),'Config',@NewConfigDelayWnd);
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(6,14),GlSanKoor2fImport(60,31),'FPS');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(6,44),GlSanKoor2fImport(100,60),'Delay :');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(6,73),GlSanKoor2fImport(194,90),' ');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(64,13),GlSanKoor2fImport(104,32),' ');
GlSanWndNewText(@NewWnd,GlSanKoor2fImport(104,44),GlSanKoor2fImport(150,60),' ');
GlSanWndNewButton(@NewWnd,GlSanKoor2fImport(173,10),GlSanKoor2fImport(194,35),'',@GlSanKillThisWindow);
GlSanWndSetLastButtonTexture(@NewWnd,'close');
GlSanWndSetLastButtonTextureOnClick(@NewWnd,'close2');
GlSanWndSetLastButtonTextureClick(@NewWnd,'close3');
GlSanWndButtonHintAdd(@NewWnd,1,' Включение\Отклбчение  попытки ');
GlSanWndButtonHintAdd(@NewWnd,1,'проведения синхронизации кадров');
GlSanWndButtonHintAdd(@NewWnd,2,'Детальный просмотр информации');
GlSanWndButtonHintAdd(@NewWnd,3,'Закрытие этого окна без отключения его функций');
GlSanWndUserMove(@NewWnd,3,GlSanKoor2fImport(ContextWidth-10,ContextHeight-10));
GlSanWndDispose(@NewWnd);
end;

procedure ProcDelay(DelayWindow:pointer);{DDDDDDDDDDDDDEEEEEEEEEEEEEELLLLLLLLAAAAAAYYYYYYYYYYYYY}
const
	ar:array[1..5] of GlSanWndTextChv = (((a:0;b:0.8;c:0;d:0.8),(a:0;b:0.5;c:0;d:0.5)),
								((a:0.8;b:0.8;c:0;d:0.8),(a:0.5;b:0.5;c:0;d:0.5)),
								((a:0.8;b:0;c:0;d:0.8),(a:0.5;b:0;c:0;d:0.5)),
								((a:0.8;b:0;c:0.8;d:0.8),(a:0.5;b:0;c:0.5;d:0.5)),
								((a:0.4;b:0;c:0.8;d:0.8),(a:0.25;b:0;c:0.5;d:0.5)));
begin
{$NOTE GlSanDelay}
if FPSMoment then
	begin
	if (FPS in [55..75]) then
		begin
		GlSanWndSetNewColorText(@DelayWindow,4,ar[1])
		end
	else
		begin
		if FPS>75 then
			begin
			if FPS>90 then
				GlSanWndSetNewColorText(@DelayWindow,4,ar[5])
			else
				GlSanWndSetNewColorText(@DelayWindow,4,ar[4])
			end
		else
			begin
			if FPS<40 then
				GlSanWndSetNewColorText(@DelayWindow,4,ar[3])
			else
				GlSanWndSetNewColorText(@DelayWindow,4,ar[2])
			end
		end;
	if FPSUser then
		GlSanWndSetNewTittleText(@DelayWindow,5,GlSanStr(GlSanD))
	else
		if GlSanDON then
			begin
			if GlSanD=0 then 
				GlSanWndSetNewTittleText(@DelayWindow,5,'On')
			else 
				GlSanWndSetNewTittleText(@DelayWindow,5,GlSanStr(GlSanD));
			end
		else 
			GlSanWndSetNewTittleText(@DelayWindow,5,'Off');
	GlSanWndSetNewTittleText(@DelayWindow,4,GlSanStr(FPS));
	end;
GlSanWndSetNewTittleText(@DelayWindow,3,glsanstr(Time.Hours)+':'+glsanstr(Time.Minits)+':'+glsanstr(Time.Seconds)+':'+glsanstr(Time.Sec100));
end;


function GlSanVal(const s:string):longint;
var
	e:longint;
begin
val(s,e);
GlSanVal:=e;
end;

procedure GlSanRoundQuadLines(const T1,T3:GlSanKoor;const R:real;const Kol:longint);
var
	T2,T4:GlSanKoor;
	ar1,ar2:array[1..50] of GlSanKoor;
	w,wp:real;
	T5,T6,T7,T8:GlSanKoor;
	i:longint = 0;{Счётчик}
	s1:longint = 0;{Счётчик 1-го массива}
	s2:longint = 0;{Счётчик 2-го массива}
begin
fillchar(ar1,sizeof(ar1),0);fillchar(ar2,sizeof(ar2),0);
wp:=(pi/2)/kol;
T2.Import(T3.x,T1.y,T1.z);T4.Import(T1.x,T3.y,T3.z);
T5.Import(T1.x+r,T1.y-r,t1.z);T6.Import(T2.x-r,T2.y-r,t2.z);
T7.Import(T3.x-r,T3.y+r,t3.z);T8.Import(T4.x+r,T4.y+r,t4.z);
w:=pi/2;repeat inc(s1);ar1[s1].Import(cos(w)*r+T5.x,sin(w)*r+t5.y,T5.z);w+=wp;until s1=kol;
w:=pi/2;repeat inc(s2);ar2[s2].Import(cos(w)*r+T6.x,sin(w)*r+t6.y,T6.z);w-=wp;until s2=kol;
w:=2*pi;repeat inc(s2);ar2[s2].Import(cos(w)*r+T7.x,sin(w)*r+t7.y,T7.z);w-=wp;until s2=2*kol;
w:=2*pi;repeat inc(s1);ar1[s1].Import(-cos(w)*r+T8.x,-sin(w)*r+t8.y,T8.z);w+=wp;until s1=2*kol;
for i:=2 to 2*kol do
	begin
	GlSanLine(ar1[i],ar1[i-1]);
	GlSanLine(ar2[i-1],ar2[i]);
	end;
GlSanLine(ar1[1],ar2[1]);
GlSanLine(ar1[2*kol],ar2[2*kol]);
end;

function GlSanStr(const s:longint):string;
var
	ss:string;
begin
str(s,ss);
GlSanStr:=ss;
end;

procedure GlSanRoundQuad(const T1,T3:GlSanKoor;const R:real;const Kol:longint);
var
	T2,T4:GlSanKoor;
	ar1,ar2:array[1..50] of GlSanKoor;
	w,wp:real;
	T5,T6,T7,T8:GlSanKoor;
	i:longint = 0;{Счётчик}
	s1:longint = 0;{Счётчик 1-го массива}
	s2:longint = 0;{Счётчик 2-го массива}
begin
fillchar(ar1,sizeof(ar1),0);fillchar(ar2,sizeof(ar2),0);
wp:=(pi/2)/kol;
T2.Import(T3.x,T1.y,T1.z);T4.Import(T1.x,T3.y,T3.z);
T5.Import(T1.x+r,T1.y-r,t1.z);T6.Import(T2.x-r,T2.y-r,t2.z);
T7.Import(T3.x-r,T3.y+r,t3.z);T8.Import(T4.x+r,T4.y+r,t4.z);
w:=pi/2;repeat inc(s1);ar1[s1].Import(cos(w)*r+T5.x,sin(w)*r+t5.y,T5.z);w+=wp;until s1=kol;
w:=pi/2;repeat inc(s2);ar2[s2].Import(cos(w)*r+T6.x,sin(w)*r+t6.y,T6.z);w-=wp;until s2=kol;
w:=2*pi;repeat inc(s2);ar2[s2].Import(cos(w)*r+T7.x,sin(w)*r+t7.y,T7.z);w-=wp;until s2=2*kol;
w:=2*pi;repeat inc(s1);ar1[s1].Import(-cos(w)*r+T8.x,-sin(w)*r+t8.y,T8.z);w+=wp;until s1=2*kol;
for i:=2 to 2*kol do
	GlSanQuad(ar1[i],ar1[i-1],ar2[i-1],ar2[i]);
end;

function GlSanMenu(const KolM:longint; const st:GlSanMenuArray; k:longint; const Color:GlSanMenuColors):longint;
const
	Big:real = 0.30;
	Dv:real = 0.004;
	Raz:real = 3/4;
	Sm:real = 2;
	CPR:real = 1/0.3;
type
	AR1_4GSK=array[1..4] of glsankoor;
var
	k1:longint;{Для случайных нужд}
	rar:array[1..GL_SAN_MENU_KOL] of real;{Массив размеров строк текста}
	Koor:GlSanKoor = (x:0; y:0; z:0);{Точка вывода cтрок текста текста}
	Vihod:boolean = false;{Наверное флажок выхода}
	Vis:real = 0;{По игрику(y) смещение}
	Rp:real = 90;{Анимация поворота(Градусы)}
	StRp:longint = 1;{Статус Анимации поворота}
	Pr:real = 0; {Анимация прозрвчности}
	KoorTek:AR1_4GSK;{Координатa, к которым стремится указатель}
	KoorYk:AR1_4GSK;{указатель}
	ChvOgr:longint;{Проядковый номер цвета огранки Quad a}
	ChvZag:longint;{Проядковый номер цвета Заголовка}
	i:longint;
	r1,r2,zum:real;
procedure KE;
begin
GlSanMenu:=k;
StRp:=3;
GlSanSetKey(0);
Rp:=-1;
end;
procedure KD;
begin
if k<>KolM then
		begin
		k1:=k;
		k+=1;
		Vis-=rar[k]+rar[k1];
		end;
end;
procedure KU;
begin
if k<>1 then
		begin
		k1:=k;
		k-=1;
		Vis+=rar[k]+rar[k1];
		end;
end;
begin
zum:=1;
r1:=0;
r2:=0;
if St[GL_SAN_MENU_KOL][1]='+' then
	ChvOgr:=GlSanVal(St[GL_SAN_MENU_KOL][2]);
if st[GL_SAN_MENU_KOL-2][1]='+' then
	ChvZag:=GlSanVal(St[GL_SAN_MENU_KOL-2][2]);
fillchar(KoorTek,sizeof(koorTek),0);
fillchar(KoorYk,sizeof(koorYk),0);
for i:=1 to KolM do
	rar[i]:=0.3;
if St[GL_SAN_MENU_KOL][1]='+' then
	begin
	KoorTek[1].Import(-0.5*GlSanTextLength(st[k],rar[k])+Sm*rar[k]-2*rar[k],-(vis+rar[k]),-0.02);
	KoorTek[2].Import(0.5*GlSanTextLength(st[k],rar[k])+Sm*rar[k]-2*rar[k],-(vis+rar[k]),-0.02);
	KoorTek[3].Import(0.5*GlSanTextLength(st[k],rar[k])+Sm*rar[k]-2*rar[k],-(vis-rar[k]),-0.02);
	KoorTek[4].Import(-0.5*GlSanTextLength(st[k],rar[k])+Sm*rar[k]-2*rar[k],-(vis-rar[k]),-0.02);
	end;
KoorYk:=KoorTek;
repeat
gltranslatef(0,0,-10*zum);
glrotatef(Rp,1,0,0);
glrotatef(R1,0,1,0);
glrotatef(R2,1,0,0);
case StRp of
1:if Rp<0.5 then StRp:=2 else Rp*=0.94;
3:if Rp<-90 then StRp:=4 else if Rp<-30 then Rp*=1.06 else Rp*=2;
end;
case StRp of
1:if Pr<1 then Pr+=0.04;
2:if Pr<>1 then Pr:=1;
3:if Pr>0 then Pr-=0.04;
end;
k1:=0;
for i:=k+1 to KolM do
	begin
	k1+=1;
	if (rar[i]>GlSanSqr(Raz,k1)*Big) then
		rar[i]-=dv;
	if (rar[i]<GlSanSqr(Raz,k1)*Big) then
		rar[i]+=dv;
	end;
k1:=0;
for i:=k-1 downto 1 do
	begin
	k1+=1;
	if (rar[i]>GlSanSqr(Raz,k1)*Big) then
		rar[i]-=dv;
	if (rar[i]<GlSanSqr(Raz,k1)*Big) then
		rar[i]+=dv;
	end;
if (rar[k]<Big) then
		rar[k]+=Dv;
if abs(vis)<0.01 then Vis:=0 else
Vis*=0.85;
if st[GL_SAN_MENU_KOL-2][1]='+' then
	begin
	glcolor4f(Color[ChvZag].a,Color[ChvZag].b,Color[ChvZag].c,Color[ChvZag].d*Pr*Pr);
	GlSanOutText(GlSanKoorImport(-0.5*GlSanTextLength(st[GL_SAN_MENU_KOL-1],1.2*Big)-1.2*Big,3,0),st[GL_SAN_MENU_KOL-1],1.2*Big);
	end;
if St[GL_SAN_MENU_KOL][1]='+' then
	begin
	KoorTek[1].Import(-0.5*GlSanTextLength(st[k],rar[k])+Sm*rar[k]-2*rar[k],-(vis+rar[k]),-0.02);
	KoorTek[2].Import(0.5*GlSanTextLength(st[k],rar[k])+Sm*rar[k]-2*rar[k],-(vis+rar[k]),-0.02);
	KoorTek[3].Import(0.5*GlSanTextLength(st[k],rar[k])+Sm*rar[k]-2*rar[k],-(vis-rar[k]),-0.02);
	KoorTek[4].Import(-0.5*GlSanTextLength(st[k],rar[k])+Sm*rar[k]-2*rar[k],-(vis-rar[k]),-0.02);
	for i:=1 to 4 do
		begin
		KoorYk[i].Togever(KoorYk[i]);
		KoorYk[i].Togever(KoorYk[i]);
		KoorYk[i].Togever(koorTek[i]);
		KoorYk[i].Zum(1/5);
		end;
	glcolor4f(Color[3].a,Color[3].b,Color[3].c,Color[3].d*Pr*Pr*Pr);
	GlSanRoundQuad(KoorYk[4],KoorYk[2],abs(KoorYk[4].y-KoorYk[2].y)/2,8);
	glcolor4f(Color[ChvOgr].a,Color[ChvOgr].b,Color[ChvOgr].c,Color[ChvOgr].d*Pr*Pr);
	GlSanRoundQuadLines(GlSanKoorImport(KoorYk[4].x,KoorYk[4].y,-0.01),GlSanKoorImport(KoorYk[2].x,KoorYk[2].y,-0.01),abs(KoorYk[4].y-KoorYk[2].y)/2,8);
	end;
Koor.Import(Koor.x,-(rar[k+1]+rar[k]),Koor.z);
for i:=k+1 to KolM do
	begin
	glcolor4f(Color[1].a,Color[1].b,Color[1].c,Color[1].d*Pr*rar[i]*Cpr);
	GlSanOutText(GlSanKoorImport(-0.5*GlSanTextLength(st[i],rar[i])-2*rar[i],koor.y+vis,0),st[i],rar[i]);
	koor.y-=rar[i]+rar[i-1];
	end;
Koor.Import(Koor.x,(rar[k-1]+rar[k]),Koor.z);
for i:=k-1 downto 1 do
	begin
	glcolor4f(Color[1].a,Color[1].b,Color[1].c,Color[1].d*Pr*rar[i]*Cpr);
	GlSanOutText(GlSanKoorImport(-0.5*GlSanTextLength(st[i],rar[i])-2*rar[i],koor.y+vis,0),st[i],rar[i]);
	koor.y+=rar[i]+rar[i+1];
	end;
glcolor4f(Color[2].a,Color[2].b,Color[2].c,Pr*Pr*Color[2].d);
Koor.Import(Koor.x,0,Koor.z);
GlSanOutText(GlSanKoorImport(-0.5*GlSanTextLength(st[k],rar[k])-2*rar[k],koor.y+vis,0),st[k],rar[k]);
case LongInt(SGMouseWheelVariable) of
1:KD;
-1:KU;
end;
if GlSanKeypressed and (StRp<3) then
case GlSanReadKey of
40:{Down}KD;
38:{Up}KU;
13:{Enter}KE;
end;
if GlSanMouseC(1) then KE;
if StRp=4 then
	begin
	Vihod:=true;
	GlSanSetKey(0);
	end;
if GlSanMouseB(3) then
	begin
	R1-=GlSanMouseXY(1).x/3;
	R2-=GlSanMouseXY(1).y/3;
	end
else
	begin
	R1*=0.9;
	R2*=0.9;
	end;
until GlSanAfterUntil(0,Vihod,false);
end;

function GlSanSqr(const Chislo:real;const Stepen:longint):real;
var
	i:longint;
begin
GlSanSqr:=1;
for i:=1 to Stepen do
	GlSanSqr*=Chislo;
end;

procedure GlSanSetKey(o:longint);
begin
if o=0 then
	begin
	byte(SGKeyPressedVariable):=o;
	end
else
	begin
	byte(SGKeyPressedVariable):=o;
	end;
end;

function GlSanTextLength(str:string;r:real):real;
var
	i:longint;
	sm:real;
	WO:word;
begin
if ActiveSkin<>-1 then 
	r*=0.88;
if ActiveFont=-1 then
	begin
	if ActiveSkin=-1 then
		sm:=2.45*r
	else
		sm:=2.35*r;
	for i:=1 to length(str) do
		begin
		if GlSanSmallABC(str[i]) then
			begin
			if ((i<>1) and (GlSanSmallABC(str[i-1])=false)) then
				sm+=1.95*r
			else
				sm+=1.6*r;
			end
		else
			begin
			if ((i<>1) and GlSanSmallABC(str[i-1])) then
				sm+=1.95*r
			else
				sm+=2.25*r;
			end;
		end;
	GlSanTextLength:=sm;
	end
else
	begin
	WO:=ArFonts[ActiveFont].ArChar[ord(SravnChar)].Width;
	if ActiveSkin=-1 then
		sm:=0.45*r
	else
		sm:=0.35*r;
	for i:=1 to Length(str) do
		begin
		sm+=(ArFonts[ActiveFont].ArChar[ord(str[i])].width/WO)*r*2;
		end;
	GlSanTextLength:=sm;
	end;
end;


function GlSanPloskPrin(pl:GlSanKoorPlosk;a:GlSanKoor):boolean;
begin
if abs(pl.a*a.x+pl.b*a.y+pl.c*a.z+pl.d)<GlSanMin then GlSanPloskPrin:=true else GlSanPloskPrin:=false;
end;

function GlSanPloskPrin(pl:GlSanKoorPlosk;a,b:GlSanKoor):boolean;
begin
if GlSanPloskPrin(pl,a) and GlSanPloskPrin(pl,b) then GlSanPloskPrin:=true else GlSanPloskPrin:=false;
end;

function GlSanPloskPoroleln(a,b:GlSankoorPlosk):boolean;
begin
GlSanPloskPoroleln:=false;
if (a.a*b.b=b.a*a.b) and (a.a*b.c=b.c*a.b)then GlSanPloskPoroleln:=true;
end;

function GlSanKoorRavno(a,b:GlSanKoor):boolean;
begin
if (((a.x>=0) and (b.x<=0)) or ((a.x<=0) and (b.x>=0)) or ((a.y>=0) and (b.y<=0)) or ((a.y<=0) and (b.y>=0)) or ((a.z>=0) and (b.z<=0)) or ((a.z<=0) and (b.z>=0))) then GlSanKoorRavno:=false else
begin if (abs(a.x)-abs(b.x)<GlSanMin) and (abs(a.y)-abs(b.y)<GlSanMin) and (abs(a.z)-abs(b.z)<GlSanMin) then GlSanKoorRavno:=true else GlSanKoorRavno:=false; end;
end;

procedure GlSanNormalObject.Init;
begin

end;

function  ReadFromFileChar(p:pointer):char;
var
	f:^text;
	c:char;
begin
f:=p;
read(f^,c);
ReadFromFileChar:=c;
end;

procedure GlSanKoor.ReadFromFile(p:pointer);
var
	f:^text;
begin
f:=p;
read(f^,x,y,z);
end;

procedure GlSanKoor2f.ReadFromFile(p:pointer);
var
	f:^text;
begin
f:=p;
read(f^,x,y);
end;

function ReadFromFileString(p:pointer):string;
var
	f:^text;
	s:string;
	t:boolean = true ;
	c:char;
begin
s:='';
f:=p;
while t do
	begin
	c:=ReadFromFileChar(f);
	if not (c in [' ']) then
		s+=c
	else
		t:=false;
	end;
ReadFromFileString:=s;
end;

procedure GlSanNormalObject.ReadFromFile(p:string);
var
	fi:^text;
	po,s:string;

begin
po:=p+'.obj';
new(fi);
assign(fi^,po);
reset(fi^);
kolv:=0;
kolf:=0;
kolvt:=0;
kolc:=0;
while not eoln(fi^) do
	begin
	case ReadFromFileChar(fi) of
	'#':readln(fi^);
	's','S':Readln(fi^);
	'u','U':
		if ((not eoln(fi^))) then
			case ReadFromFileChar(fi) of
			's','S':
				if ((not eoln(fi^))) then
					case ReadFromFileChar(fi) of
					'e','E':
						if ((not eoln(fi^))) then
							case ReadFromFileChar(fi) of
							'm','M':
								if ((not eoln(fi^))) then
									case ReadFromFileChar(fi) of
									't','T':
										if ((not eoln(fi^))) then
											case ReadFromFileChar(fi) of
											'l','L':
												if ((not eoln(fi^))) then
													case ReadFromFileChar(fi) of
													' ':
														if ((not eoln(fi^))) then
															begin
															inc(kolf);
															new(F[KolF]);
															F[KolF]^.Tip:=2;
															system.new(F[KolF]^.q2);
															F[KolF]^.q2^.n:=null;
															readln(fi^,F[KolF]^.q2^.s);
															end;
													else readln(fi^);
													end;
											else readln(fi^);
											end;
									else readln(Fi^);
									end;
							else readln(fi^);
							end;
					else readln(fi^);
					end;
			else readln(fi^);
			end;
	'v','V':
		if ((not eoln(fi^))) then
			case ReadFromFileChar(fi) of
			' ':
				begin
				inc(kolv);
				new(V[kolv]);
				V[kolv]^.ReadFromFile(fi);
				readln(fi^);
				end;
			't','T':
				begin
				inc(kolvt);
				new(vt[kolvt]);
				VT[kolVt]^.ReadFromFile(fi);
				readln(fi^);
				end;
			end;
	'f','F':
		if not eoln(fi^) then
			begin
			inc(KolF);
			F[KolF]^.Tip:=1;
			new(F[KolF]^.q1);
			F[KolF]^.q2:=nil;
			F[KolF]^.q3:=nil;
			read(fi^,F[KolF]^.q1^.n[1],F[KolF]^.q1^.n[2]);
			if Not eoln(fi^) then
				begin
				read(fi^,F[KolF]^.q1^.n[3]);
				if not eoln(fi^) then
					begin
					read(fi^,F[KolF]^.q1^.n[4]);
					F[KolF]^.q1^.kol:=4;
					end
				else
					F[KolF]^.q1^.kol:=3;
				end
			else
				F[KolF]^.q1^.kol:=2;
			readln(fi^);
			end;
	'm','M':
		begin
		if ReadFromFileString(fi)='tllib' then
			begin
			read(fi^,s);

			end;
		readln(fi^);
		end;
	else readln(fi^);
	end;

	end;

close(fi^);
dispose(fi);
end;

procedure Proga_Zastavka1(o:GlSanLightObject);
var
	r1,r2,r3,q1,q2,q3:real;
	i,ii:longint;
	upzum,leftzum,zym:real;
begin
randomize;
r1:=random(360);
r2:=random(360);
r3:=random(360);
q1:=random(360)/180;
q2:=random(360)/180;
q3:=random(360)/180;
i:=1;
ii:=500;
//if not SGContextActive then GlSanCOGWAIOG('MPSNP Program)',false);
zym:=1;
r1:=6;
r2:=0;
leftzum:=0;
upzum:=0;
zym:=1;
repeat
inc(i);
gltranslatef(leftzum,upzum,-9*zym);
glrotatef(r1,1,0,0);
glrotatef(r2,0,1,0);
glrotatef(r3,0,0,1);
o.Init(GlSanKoorImport(0,0,0),3.4);
r1+=q1;
r2+=q2;
r3+=q3;
until GlSanAfterUntil(0,i=ii,true);
o.dispose;
end;


procedure GlSanChvMesh.Init;
begin
glPolygonMode (GL_FRONT_AND_BACK, tipZ);
case Tip of
1:_1.SanSetColor;
2:_2.SanSetColor;
3:
	begin
	glcolor3f(1,1,1);
	GlSanTextureActivate2D(_3);
	end;
4:
	begin
	_1.SanSetColor;
	GlSanTextureActivate2D(_3);
	end;
5:
	begin
	_2.SanSetColor;
	GlSanTextureActivate2D(_3);
	end;
end;
end;

procedure GlSanLightObject.Dispose;
var
	i:longint;
begin
for i:=1 to kolv do
	system.dispose(v[i]);
for i:=1 to kolf do
	system.dispose(f[i]);
kolv:=0;
kolf:=0;
end;

procedure GlSanF.Import(a1,a2,a3:longint);
begin
kol:=3;
n[1]:=a1;
n[2]:=a2;
n[3]:=a3;
end;


procedure GlSanF.Import(a1,a2,a3,a4:longint);
begin
kol:=4;
n[1]:=a1;
n[2]:=a2;
n[3]:=a3;
n[4]:=a4;
end;

procedure Proga_Translyater;
const maxp=1000000;
var
	s:array[1..4]of string;
	o:GlSanLightObject;
	fin:text;
	i,ii,kolp:longint;
begin
randomize;
textcolor(14);
writeln('Привет! Это "Translyater" (MPSNP Program)...');
textcolor(15);
writeln('Введите имя файла [без разряшения [ .off ]  ] ...');
textcolor(11);
readln(s[1]);
s[1]+='.off';
o.ReadFromFile(s[1]);
if ((o.kolv=0) and (o.kolf=0)) then
	begin
	textcolor(12);
	writeln('Неудалось загрузить обьект...');
	readln;
	halt(0);
	end
else
	begin
	textcolor(10);
	writeln('Обьект успешно загружен!:)...');
	end;
textcolor(15);
writeln('Введите имя нового модуля [без разряшения [ .pas , .pp ]  ] ...');
writeln('Учтите, что это имя будет прописано в модуле...');
textcolor(11);
readln(s[2]);
s[4]:=s[2];
case random(2) of
0:s[2]+='.pas';
1:s[2]+='.pp';
end;
assign(fin,s[2]);
rewrite(fin);
textcolor(10);
writeln('Файл ',s[2],' успешно открыт:))...');
textcolor(15);
writeln(fin,'{----------------------------------------------------------------------}');
writeln(fin,'{------------------Sanches Corporation Present-------------------------}');
writeln(fin,'{------------------------=MPSNP FOREVER=-------------------------------}');
writeln(fin,'{----------- - This Work MPSNP Program "Translyater"-------------------}');
writeln(fin,'{-----------------------Import-from "*.off"----------------------------}');
writeln(fin,'{----------------------Work with san.ppu-------------------------------}');
writeln(fin,'{------------------"San.ppu" Work with "San.res"-----------------------}');
writeln(fin,'{----------------------------------------------------------------------}');
writeln(fin,'unit ',s[4],'; {  Это название Модуля}');
writeln(fin,'interface  { Инициализируем интерфейсный раздел }');
writeln(fin,'uses san; { Перечисляем модули , которые использует Этот Модуль }');
writeln('Введите имя функции в модуле...');
textcolor(11);
readln(s[3]);
writeln(fin,'function ',s[3],':GlSanLightObj; { Пишем заголовок функции } ');
writeln(fin,'implementation  { Инициализируем раздел интерпритации }');
writeln(fin,'function ',s[3],':GlSanLightObj; { Ещё раз пишем заголовок функции } ');
writeln(fin,'var');
writeln(fin,'   i:longint; { Счетчик }  ');
kolp:=0;
for i:=1 to trunc(o.kolv/5000)+1 do
	begin
	inc(kolp);
	writeln(fin,'procedure Proc',kolp,';');
	writeln(fin,'begin');
	if  i=trunc(o.kolv/5000)+1 then
		begin
		for ii:=(i-1)*5000+1 to o.kolv do
			writeln(fin,s[3],'.v[',ii,']^.Import(',o.v[ii]^.x:0:6,',',o.v[ii]^.y:0:6,',',o.v[ii]^.z:0:6,');');
		end
	else
		begin
		for ii:=(i-1)*5000+1 to i*5000 do
			writeln(fin,s[3],'.v[',ii,']^.Import(',o.v[ii]^.x:0:6,',',o.v[ii]^.y:0:6,',',o.v[ii]^.z:0:6,');');
		end;
	writeln(fin,'end;');
	writeln(fin);
	end;
for i:=1 to trunc(o.kolf/5000)+1 do
	begin
	inc(kolp);
	writeln(fin,'procedure Proc',kolp,';');
	writeln(fin,'begin');
	if  i=trunc(o.kolf/5000)+1 then
		begin
		for ii:=(i-1)*5000+1 to o.kolf do
			if o.f[ii]^.kol=3 then
				writeln(fin,s[3],'.f[',ii,']^.Import(',o.f[ii]^.n[1],',',o.f[ii]^.n[2],',',o.f[ii]^.n[3],');')
			else
				writeln(fin,s[3],'.f[',ii,']^.Import(',o.f[ii]^.n[1],',',o.f[ii]^.n[2],',',o.f[ii]^.n[3],',',o.f[ii]^.n[4],');');
		end
	else
		begin
		for ii:=(i-1)*5000+1 to i*5000 do
			if o.f[ii]^.kol=3 then
				writeln(fin,s[3],'.f[',ii,']^.Import(',o.f[ii]^.n[1],',',o.f[ii]^.n[2],',',o.f[ii]^.n[3],');')
			else
				writeln(fin,s[3],'.f[',ii,']^.Import(',o.f[ii]^.n[1],',',o.f[ii]^.n[2],',',o.f[ii]^.n[3],',',o.f[ii]^.n[4],');');
		end;
	writeln(fin,'end;');
	writeln(fin);
	end;
writeln(fin,'begin');
writeln(fin,s[3],'.kolv:=',o.kolv,';');
writeln(fin,s[3],'.kolf:=',o.kolf,';');
writeln(fin,'for i:=',s[3],'.kolv+1 to GL_CONST_LO do');
writeln(fin,'   ',s[3],'.v[i]:=nil;');
writeln(fin,'for i:=',s[3],'.kolf+1 to GL_CONST_LO do');
writeln(fin,'   ',s[3],'.f[i]:=nil;');
writeln(fin,'for i:=1 to ',s[3],'.kolv do');
writeln(fin,'   system.new(',s[3],'.v[i]);');
writeln(fin,'for i:=1 to ',s[3],'.kolf do');
writeln(fin,'   system.new(',s[3],'.f[i]);');
for i:=1 to kolp do
	writeln(fin,'Proc',i,';');
writeln(fin,'end;');
writeln(fin,'');
writeln(fin,'begin');
writeln(fin,'end.');
close(fin);
textcolor(10);
writeln('Удалосъ:)))...');
readln;
end;

procedure SetNormal(v1,v2,v3:GlSanKoor);
begin
FindNormal(v1,v2,v3);
SetNormal;
end;

procedure SetNormal();
begin
glNormal3f(CNormal[1], CNormal[2], CNormal[3]);
end;

procedure FindNormal(v1,v2,v3:GlSanKoor);
begin
FindNormal(v1.x,v1.y,v1.z,v2.x,v2.y,v2.z,v3.x,v3.y,v3.z);
end;

procedure FindNormal(v1x, v1y, v1z, v2x, v2y, v2z, v3x, v3y, v3z : real);
const	x = 1;
	y = 2;
	z = 3;
var	temp_v1, temp_v2 : array[1..3] of real;
	temp_lenght : real;
begin

temp_v1[x] := v1x - v2x;
temp_v1[y] := v1y - v2y;
temp_v1[z] := v1z - v2z;

temp_v2[x] := v2x - v3x;
temp_v2[y] := v2y - v3y;
temp_v2[z] := v2z - v3z;

// calculate cross product
CNormal[x] := temp_v1[y]*temp_v2[z] - temp_v1[z]*temp_v2[y];
CNormal[y] := temp_v1[z]*temp_v2[x] - temp_v1[x]*temp_v2[z];
CNormal[z] := temp_v1[x]*temp_v2[y] - temp_v1[y]*temp_v2[x];

// normalize normal
temp_lenght :=	(CNormal[x]*CNormal[x])+
		(CNormal[y]*CNormal[y])+
		(CNormal[z]*CNormal[z]);

temp_lenght := sqrt(temp_lenght);

// prevent n/0
if temp_lenght = 0 then temp_lenght := 1;

CNormal[x] /= temp_lenght;
CNormal[y] /= temp_lenght;
CNormal[z] /= temp_lenght;

end;

procedure GlSanLightObject.Init(k:GlSanKoor;s:real);
var i:longint;
	p:array[1..4] of glsankoor;
begin
for i:=1 to kolf do
	begin
	case f[i]^.kol of
	2:
		begin
		p[1]:=v[f[i]^.n[1]]^;
		p[2]:=v[f[i]^.n[2]]^;
		p[1].Zum(s);
		p[2].Zum(s);
		p[1].Togever(k);
		p[2].Togever(k);
		glbegin(GL_Lines);
		GlSanVertex3f(p[1]);
		GlSanVertex3f(p[2]);
		glend;
		end;
	3:
		begin
		p[1]:=v[f[i]^.n[1]]^;
		p[2]:=v[f[i]^.n[2]]^;
		p[3]:=v[f[i]^.n[3]]^;
		p[1].Zum(s);
		p[2].Zum(s);
		p[3].Zum(s);
		p[1].Togever(k);
		p[2].Togever(k);
		p[3].Togever(k);
		SetNormal(p[1],p[2],p[3]);
		glbegin(GL_triangles);
		GlSanVertex3f(p[1]);
		GlSanVertex3f(p[2]);
		GlSanVertex3f(p[3]);
		glend;
		end;
	4:
		begin
		p[1]:=v[f[i]^.n[1]]^;
		p[2]:=v[f[i]^.n[2]]^;
		p[3]:=v[f[i]^.n[3]]^;
		p[4]:=v[f[i]^.n[4]]^;
		p[1].Zum(s);
		p[2].Zum(s);
		p[3].Zum(s);
		p[4].Zum(s);
		p[1].Togever(k);
		p[2].Togever(k);
		p[3].Togever(k);
		p[4].Togever(k);
		SetNormal(p[1],p[2],p[3]);
		GlSanQuad(p[1],p[2],p[3],p[4]);
		end;
	end;
	end;
end;

procedure GlSanLightObject.ReadFromFile(s:string);
var
	fin:text;
	i,ii:longint;
begin
if fail_est(s) then
	begin
	assign(fin,s);
	reset(fin);
	readln(fin);
	readln(fin,kolv,kolf);
	for i:=kolv+1 to GL_CONST_LO do
		v[i]:=nil;
	for i:=kolf+1 to GL_CONST_LO do
		f[i]:=nil;
	for i:=1 to kolv do
		system.new(v[i]);
	for i:=1 to kolf do
		system.new(f[i]);
	for i:=1 to kolv do
		readln(fin,v[i]^.x,v[i]^.y,v[i]^.z);
	for i:=1 to kolf do
		begin
		read(fin,f[i]^.kol);
		for ii:=1 to f[i]^.kol do
			read(fin,f[i]^.n[ii]);
		for ii:=1 to f[i]^.kol do
			f[i]^.n[ii]+=1;
		readln(fin);
		end;
	close(fin);
	end
else
	begin
	KolV:=0;
	KolF:=0;
	{$IFDEF MSWINDOWS}MessageBox(0, 'File not found!', 'Error', MB_OK);{$ENDIF}
	end;
end;

function GlSanStr(a:real):string;
var
	s:string;
begin
str(a,s);
GlSanStr:=s;
end;

function GlSanReadKoor(z:longint;k:GlSanKoor2f):GlSanKoor;
var
	a1,a2,a3:gldouble;
	a:GlSanKoor;
	depth:glfloat;
begin
if z=GL_SAN_VIEW_FIRST then
	begin
	glGetIntegerv(GL_VIEWPORT,viewport);
	glGetDoublev(GL_MODELVIEW_MATRIX,mv_matrix);
	glGetDoublev(GL_PROJECTION_MATRIX,proj_matrix);
	end;
glReadPixels(round(k.x),height-round(k.y)-1, 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, @depth);
gluUnProject(round(k.x),height-round(k.y)-1,depth,mv_matrix,proj_matrix,viewport,@a1,@a2,@a3);
a.x:=a1;
a.y:=a2;
a.z:=a3;
GlSanReadKoor:=a;
end;

function GlSanReadABS(z:longint;k:GlSanKoor2f):real;
var
	depth:glfloat;
begin
if z=GL_SAN_VIEW_FIRST then
	begin
	glGetIntegerv(GL_VIEWPORT,viewport);
	glGetDoublev(GL_MODELVIEW_MATRIX,mv_matrix);
	glGetDoublev(GL_PROJECTION_MATRIX,proj_matrix);
	end;
glReadPixels(round(k.x),height-round(k.y)-1, 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, @depth);
GlSanReadABS:=depth;
end;

function GlSanColor4fImport(a1,a2,a3,a4:real):GlSanColor4f;
var
	a:GlSanColor4f;
begin
a.a:=a1;
a.b:=a2;
a.c:=a3;
a.d:=a4;
GlSanColor4fImport:=a;
end;

procedure GlSanRamka(t1,t3,t6:GlSanKoor;c1,c2:GlSanColor4f);
var
	t2,t4,t5:GlSanKoor;
begin
t2:=t1;
t2.x:=t6.x;
t4:=t3;
t4.x:=t6.x;
t5:=t6;
t5.x:=t1.x;
c1.sansetcolor;
GlSanQuad(t1,t2,t4,t3);
c2.SanSetColor;
GlSanQuad(t3,t4,t6,t5);
end;

function GlSanGetWord(q:pointer):word;
var
	e:^GlSanAnyType;
	_1:^word;
begin
e:=q;
if e^.Tip=GL_SAN_WORD then
	begin
	_1:=e^.r;
	GlSanGetWord:=_1^;
	end
else
	begin
	GlSanGetWord:=0;
	{$IFDEF MSWINDOWS}MessageBox(0, 'Error get of "GlSanAnyType" Type. Hea not WORD type!', 'Error', MB_OK);{$ENDIF}
	end;
end;


function GlSanGetChar(q:pointer):char;
var
	e:^GlSanAnyType;
	_1:^char;
begin
e:=q;
if e^.Tip=GL_SAN_CHAR then
	begin
	_1:=e^.r;
	GlSanGetChar:=_1^;
	end
else
	begin
	GlSanGetChar:=#0;
	{$IFDEF MSWINDOWS}MessageBox(0, 'Error get of "GlSanAnyType" Type. Hea not CHAR type!', 'Error', MB_OK);{$ENDIF}
	end;
end;

function GlSanGetPChar(q:pointer):pchar;
var
	e:^GlSanAnyType;
	_1:^pchar;
begin
e:=q;
if e^.Tip=GL_SAN_PCHAR then
	begin
	_1:=e^.r;
	GlSanGetPChar:=_1^;
	end
else
	begin
	GlSanGetPChar:='';
	{$IFDEF MSWINDOWS}MessageBox(0, 'Error get of "GlSanAnyType" Type. Hea not PCHAR type!', 'Error', MB_OK);{$ENDIF}
	end;
end;

function GlSanGetLongint(q:pointer):longint;
var
	e:^GlSanAnyType;
	_1:^longint;
begin
e:=q;
if e^.Tip=GL_SAN_LONGINT then
	begin
	_1:=e^.r;
	GlSanGetLongint:=_1^;
	end
else
	begin
	GlSanGetLongint:=0;
	{$IFDEF MSWINDOWS}MessageBox(0, 'Error get of "GlSanAnyType" Type. Hea not LONGINT type!', 'Error', MB_OK);{$ENDIF}
	end;
end;

function GlSanGetString(q:pointer):string;
var
	e:^GlSanAnyType;
	_1:^string;
begin
e:=q;
if e^.Tip=GL_SAN_STRING then
	begin
	_1:=e^.r;
	GlSanGetString:=_1^;
	end
else
	begin
	GlSanGetString:='';
	{$IFDEF MSWINDOWS}MessageBox(0, 'Error get of "GlSanAnyType" Type. Hea not STRING type!', 'Error', MB_OK);{$ENDIF}
	end;
end;

function GlSanGetReal(q:pointer):real;
var
	e:^GlSanAnyType;
	_5:^real;
begin
e:=q;
if e^.Tip=GL_SAN_REAL then
	begin
	_5:=e^.r;
	GlSanGetReal:=_5^;
	end
else
	begin
	GlSanGetReal:=0;
	{$IFDEF MSWINDOWS}MessageBox(0, 'Error get of "GlSanAnyType" Type. Hea not REAL type!', 'Error', MB_OK);{$ENDIF}
	end;
end;

function GlSanGet(q:pointer):pointer;
var
	e:^GlSanAnyType;
begin
e:=q;
GlSanGet:=e^.r;
end;

procedure GlSanSet(q,ya:pointer;TipY:longint);
begin
PA3(q,ya,TipY);
end;

function GlSanSmallABC(c:char):boolean;
begin
(*CP866*)
{if (c in [#97..#122,#160..#175,#224..#239,#241]) then
	GlSanSmallABC:=true else GlSanSmallABC:=false;}
(*Windows-1251*)
if (c in ['ё','а'..'я','a'..'z']) then
	GlSanSmallABC:=true else GlSanSmallABC:=false;
end;

procedure GlSanABCObj.SmallInit(TOC:GlSanKoor;r:real);
var
	i:longword;
	o1,o2:GlSanKoor;
begin
toc.import(toc.x-0.3*r,toc.y,toc.z);
r/=1.5;
for i:=1 to KolL do
	begin
	o1:=GlSanLoadABCToch(L[1,i]);
	o2:=GlSanLoadABCToch(L[2,i]);
	o1.Zum(r);
	o2.Zum(r);
	o1.Togever(toc);
	o2.Togever(toc);
	GlSanLine(o1,o2);
	end;
end;

procedure GlSanKoor.Zum(q:real);
begin
x*=q;
y*=q;
z*=q;
end;

procedure GlSanKoor.Togever(q:GlSanKoor);
begin
x+=q.x;
y+=q.y;
z+=q.z;
end;

function GlSanLoadABCToch(l:longword):GlSanKoor;
begin
case l of
1:GlSanLoadABCToch:=GlSanKoorImport(0.9,0.9,0);
2:GlSanLoadABCToch:=GlSanKoorImport(0.9,0,0);
3:GlSanLoadABCToch:=GlSanKoorImport(0.9,-0.9,0);
4:GlSanLoadABCToch:=GlSanKoorImport(0,0.9,0);
5:GlSanLoadABCToch:=GlSanKoorImport(0,0,0);
6:GlSanLoadABCToch:=GlSanKoorImport(0,-0.9,0);
7:GlSanLoadABCToch:=GlSanKoorImport(-0.9,0.9,0);
8:GlSanLoadABCToch:=GlSanKoorImport(-0.9,0,0);
9:GlSanLoadABCToch:=GlSanKoorImport(-0.9,-0.9,0);
10:GlSanLoadABCToch:=GlSanKoorImport(0.9,0.45,0);
11:GlSanLoadABCToch:=GlSanKoorImport(0.9,-0.45,0);
12:GlSanLoadABCToch:=GlSanKoorImport(0,0.45,0);
13:GlSanLoadABCToch:=GlSanKoorImport(0,-0.45,0);
14:GlSanLoadABCToch:=GlSanKoorImport(-0.9,0.45,0);
15:GlSanLoadABCToch:=GlSanKoorImport(-0.9,-0.45,0);
16:GlSanLoadABCToch:=GlSanKoorImport(0.45,0.9,0);
17:GlSanLoadABCToch:=GlSanKoorImport(0.45,0,0);
18:GlSanLoadABCToch:=GlSanKoorImport(0.45,-0.9,0);
19:GlSanLoadABCToch:=GlSanKoorImport(-0.45,0.9,0);
20:GlSanLoadABCToch:=GlSanKoorImport(-0.45,0,0);
21:GlSanLoadABCToch:=GlSanKoorImport(-0.45,-0.9,0);
22:GlSanLoadABCToch:=GlSanKoorImport(0.45,0.45,0);
23:GlSanLoadABCToch:=GlSanKoorImport(0.45,-0.45,0);
24:GlSanLoadABCToch:=GlSanKoorImport(-0.45,0.45,0);
25:GlSanLoadABCToch:=GlSanKoorImport(-0.45,-0.45,0);
26:GlSanLoadABCToch:=GlSanKoorImport(1,1,0);
27:GlSanLoadABCToch:=GlSanKoorImport(1,-1,0);
28:GlSanLoadABCToch:=GlSanKoorImport(-1,1,0);
29:GlSanLoadABCToch:=GlSanKoorImport(-1,-1,0);
30:GlSanLoadABCToch:=GlSanKoorImport(1,0.9,0);
31:GlSanLoadABCToch:=GlSanKoorImport(0.9,-1,0);
32:GlSanLoadABCToch:=GlSanKoorImport(-1,-0.9,0);
33:GlSanLoadABCToch:=GlSanKoorImport(-0.9,1,0);
34:GlSanLoadABCToch:=GlSanKoorImport(0.9,1,0);
35:GlSanLoadABCToch:=GlSanKoorImport(1,-0.9,0);
36:GlSanLoadABCToch:=GlSanKoorImport(-0.9,-1,0);
37:GlSanLoadABCToch:=GlSanKoorImport(-1,0.9,0);
38:GlSanLoadABCToch:=GlSanKoorImport(0.9,0.225,0);
39:GlSanLoadABCToch:=GlSanKoorImport(-0.45,0.225,0);
40:GlSanLoadABCToch:=GlSanKoorImport(0.9,-0.225,0);
41:GlSanLoadABCToch:=GlSanKoorImport(-1.1,0.45,0);
42:GlSanLoadABCToch:=GlSanKoorImport(-0.8,0,0);
43:GlSanLoadABCToch:=GlSanKoorImport(0.8,0,0);
44:GlSanLoadABCToch:=GlSanKoorImport(1.1,0,0);
45:GlSanLoadABCToch:=GlSanKoorImport(-1.1,0,0);
46:GlSanLoadABCToch:=GlSanKoorImport(1,-0.45,0);
47:GlSanLoadABCToch:=GlSanKoorImport(1,0.45,0);
else GlSanLoadABCToch:=GlSanKoorImport(0,0,0);
end;
end;

function GlSanLoadBykv(c:char):GlSanABCObj;
var o:GlSanABCObj;
begin
case c of
'A','А','a','а':
	begin
	o.koll:=6;
	o.l[1,1]:=10;
	o.l[2,1]:=11;
	o.l[1,2]:=16;
	o.l[2,2]:=7;
	o.l[1,4]:=4;
	o.l[2,4]:=6;
	o.l[1,3]:=18;
	o.l[2,3]:=9;
	o.l[1,5]:=16;
	o.l[2,5]:=10;
	o.l[1,6]:=18;
	o.l[2,6]:=11;
	end;
'Б','6','б':
	begin
	o.koll:=5;
	o.l[1,1]:=1;
	o.l[2,1]:=3;
	o.l[1,2]:=1;
	o.l[2,2]:=7;
	o.l[1,4]:=4;
	o.l[2,4]:=6;
	o.l[1,3]:=7;
	o.l[2,3]:=9;
	o.l[1,5]:=6;
	o.l[2,5]:=9;
	end;
'В','в','B','b':
	begin
	o.koll:=8;
	o.l[1,1]:=1;
	o.l[2,1]:=7;
	o.l[1,2]:=4;
	o.l[2,2]:=13;
	o.l[1,3]:=11;
	o.l[2,3]:=1;
	o.l[1,4]:=15;
	o.l[2,4]:=7;
	o.l[1,5]:=15;
	o.l[2,5]:=21;
	o.l[1,6]:=21;
	o.l[2,6]:=13;
	o.l[1,7]:=18;
	o.l[2,7]:=13;
	o.l[1,8]:=11;
	o.l[2,8]:=18;
	end;
'8':
	begin
	o.koll:=5;
	o.l[1,1]:=1;
	o.l[2,1]:=3;
	o.l[1,2]:=1;
	o.l[2,2]:=7;
	o.l[1,4]:=4;
	o.l[2,4]:=6;
	o.l[1,3]:=7;
	o.l[2,3]:=9;
	o.l[1,5]:=3;
	o.l[2,5]:=9;
	end;
'Г','г':
	begin
	o.koll:=3;
	o.l[1,1]:=1;
	o.l[2,1]:=3;
	o.l[1,2]:=1;
	o.l[2,2]:=7;
	o.l[1,3]:=3;
	o.l[2,3]:=18;
	end;
'Д','д':
	begin
	o.koll:=7;
	o.l[1,1]:=19;
	o.l[2,1]:=7;
	o.l[1,2]:=19;
	o.l[2,2]:=21;
	o.l[1,3]:=21;
	o.l[2,3]:=9;
	o.l[1,4]:=24;
	o.l[2,4]:=22;
	o.l[1,5]:=25;
	o.l[2,5]:=23;
	o.l[1,6]:=22;
	o.l[2,6]:=2;
	o.l[1,7]:=23;
	o.l[2,7]:=2;
	end;
'Е','е','E','e','ё','Ё':
	begin
	o.koll:=4;
	o.l[1,1]:=1;
	o.l[2,1]:=3;
	o.l[1,2]:=1;
	o.l[2,2]:=7;
	o.l[1,4]:=4;
	o.l[2,4]:=6;
	o.l[1,3]:=7;
	o.l[2,3]:=9;
	if (c in ['ё','Ё']) then
		begin
		o.koll+=2;
		o.l[1,5]:=46;
		o.l[2,5]:=35;
		o.l[1,6]:=47;
		o.l[2,6]:=30;
		end;
	end;
'ж','Ж':
	begin
	o.koll:=3;
	o.l[1,1]:=1;
	o.l[2,1]:=9;
	o.l[1,2]:=3;
	o.l[2,2]:=7;
	o.l[1,3]:=2;
	o.l[2,3]:=8;
	end;
'З','з','3':
	begin
	o.koll:=9;
	o.l[1,1]:=16;
	o.l[2,1]:=10;
	o.l[1,2]:=10;
	o.l[2,2]:=11;
	o.l[1,3]:=11;
	o.l[2,3]:=18;
	o.l[1,4]:=18;
	o.l[2,4]:=13;
	o.l[1,5]:=13;
	o.l[2,5]:=5;
	o.l[1,6]:=13;
	o.l[2,6]:=21;
	o.l[1,7]:=21;
	o.l[2,7]:=15;
	o.l[1,8]:=15;
	o.l[2,8]:=14;
	o.l[1,9]:=14;
	o.l[2,9]:=19;
	end;
'И','и','й','Й':
	begin
	o.koll:=3;
	o.l[1,1]:=1;
	o.l[2,1]:=7;
	o.l[1,2]:=3;
	o.l[2,2]:=7;
	o.l[1,3]:=3;
	o.l[2,3]:=9;
	if (c in['й','Й']) then
		begin
		o.koll+=1;
		o.l[1,4]:=38;
		o.l[2,4]:=40;
		end;
	end;
'к','К','k','K':
	begin
	o.koll:=3;
	o.l[1,1]:=1;
	o.l[2,1]:=7;
	o.l[1,2]:=3;
	o.l[2,2]:=4;
	o.l[1,3]:=4;
	o.l[2,3]:=9;
	end;
'л','Л':
	begin
	o.koll:=2;
	o.l[1,1]:=2;
	o.l[2,1]:=9;
	o.l[1,2]:=2;
	o.l[2,2]:=7;
	end;
'м','М','m','M':
	begin
	o.koll:=4;
	o.l[1,1]:=7;
	o.l[2,1]:=10;
	o.l[1,2]:=10;
	o.l[2,2]:=5;
	o.l[1,3]:=5;
	o.l[2,3]:=11;
	o.l[1,4]:=11;
	o.l[2,4]:=9;
	end;
'н','Н','h','H':
	begin
	o.koll:=3;
	o.l[1,1]:=3;
	o.l[2,1]:=9;
	o.l[1,2]:=1;
	o.l[2,2]:=7;
	o.l[1,3]:=4;
	o.l[2,3]:=6;
	end;
'О','о','O','o':
	begin
	o.koll:=8;
	o.l[1,1]:=16;
	o.l[2,1]:=10;
	o.l[1,2]:=10;
	o.l[2,2]:=11;
	o.l[1,3]:=11;
	o.l[2,3]:=18;
	o.l[1,4]:=18;
	o.l[2,4]:=21;
	o.l[1,5]:=16;
	o.l[2,5]:=19;
	o.l[1,6]:=19;
	o.l[2,6]:=14;
	o.l[1,7]:=21;
	o.l[2,7]:=15;
	o.l[1,8]:=15;
	o.l[2,8]:=14;
	end;
'0':
	begin
	o.koll:=4;
	o.l[1,1]:=1;
	o.l[2,1]:=3;
	o.l[1,2]:=3;
	o.l[2,2]:=9;
	o.l[1,3]:=7;
	o.l[2,3]:=9;
	o.l[1,4]:=7;
	o.l[2,4]:=1;
	end;
'П','п':
	begin
	o.l[1,1]:=1;
	o.l[2,1]:=3;
	o.l[1,2]:=1;
	o.l[2,2]:=7;
	o.l[1,3]:=3;
	o.l[2,3]:=9;
	o.koll:=3;
	end;
'р','Р','p','P':
	begin
	o.koll:=5;
	o.l[1,1]:=1;
	o.l[2,1]:=7;
	o.l[1,2]:=1;
	o.l[2,2]:=11;
	o.l[1,3]:=4;
	o.l[2,3]:=13;
	o.l[1,4]:=18;
	o.l[2,4]:=11;
	o.l[1,5]:=13;
	o.l[2,5]:=18;
	end;
'С','с','c','C':
	begin
	o.koll:=7;
	o.l[1,1]:=16;
	o.l[2,1]:=10;
	o.l[1,2]:=10;
	o.l[2,2]:=11;
	o.l[1,3]:=11;
	o.l[2,3]:=18;
	o.l[1,5]:=16;
	o.l[2,5]:=19;
	o.l[1,6]:=19;
	o.l[2,6]:=14;
	o.l[1,7]:=21;
	o.l[2,7]:=15;
	o.l[1,4]:=15;
	o.l[2,4]:=14;
	end;
'Т','т','t','T':
	begin
	o.koll:=4;
	o.l[1,1]:=1;
	o.l[2,1]:=3;
	o.l[1,2]:=2;
	o.l[2,2]:=8;
	o.l[1,3]:=1;
	o.l[2,3]:=16;
	o.l[1,4]:=18;
	o.l[2,4]:=3;
	end;
'У','у':
	begin
	o.koll:=2;
	o.l[1,1]:=1;
	o.l[2,1]:=5;
	o.l[1,2]:=7;
	o.l[2,2]:=3;
	end;
'ф','Ф':
	begin
	o.koll:=5;
	o.l[1,1]:=1;
	o.l[2,1]:=3;
	o.l[1,2]:=1;
	o.l[2,2]:=4;
	o.l[1,3]:=3;
	o.l[2,3]:=6;
	o.l[1,4]:=4;
	o.l[2,4]:=6;
	o.l[1,5]:=2;
	o.l[2,5]:=8;
	end;
'x','X','х','Х':
	begin
	o.koll:=2;
	o.l[1,1]:=1;
	o.l[2,1]:=9;
	o.l[2,2]:=3;
	o.l[1,2]:=7;
	end;
'Ц','ц':
	begin
	o.koll:=4;
	o.l[1,1]:=1;
	o.l[2,1]:=19;
	o.l[1,2]:=11;
	o.l[2,2]:=25;
	o.l[1,3]:=19;
	o.l[2,3]:=21;
	o.l[1,4]:=21;
	o.l[2,4]:=32;
	end;
'ч','Ч':
	begin
	o.koll:=3;
	o.l[1,1]:=1;
	o.l[2,1]:=4;
	o.l[1,2]:=3;
	o.l[2,2]:=9;
	o.l[1,3]:=4;
	o.l[2,3]:=6;
	end;
'ш','Ш':
	begin
	o.koll:=4;
	o.l[1,1]:=1;
	o.l[2,1]:=7;
	o.l[1,2]:=3;
	o.l[2,2]:=9;
	o.l[1,3]:=7;
	o.l[2,3]:=9;
	o.l[1,4]:=2;
	o.l[2,4]:=8;
	end;
'ы','Ы':
	begin
	o.koll:=5;
	o.l[1,1]:=1;
	o.l[2,1]:=7;
	o.l[1,2]:=13;
	o.l[2,2]:=15;
	o.l[1,3]:=4;
	o.l[2,3]:=13;
	o.l[1,4]:=7;
	o.l[2,4]:=15;
	o.l[1,5]:=3;
	o.l[2,5]:=9;
	end;
'_':
	begin
	o.koll:=1;
	o.l[1,1]:=28;
	o.l[2,1]:=29;
	end;
'+':
	begin
	o.koll:=2;
	o.l[1,1]:=17;
	o.l[2,1]:=20;
	o.l[1,2]:=13;
	o.l[2,2]:=12;
	end;
'-':
	begin
	o.koll:=1;
	o.l[1,1]:=13;
	o.l[2,1]:=12;
	end;
'=':
	begin
	o.koll:=2;
	o.l[1,1]:=22;
	o.l[2,1]:=23;
	o.l[1,2]:=24;
	o.l[2,2]:=25;
	end;
'^':
	begin
	o.koll:=2;
	o.l[1,1]:=2;
	o.l[2,1]:=22;
	o.l[1,2]:=2;
	o.l[2,2]:=23;
	end;
'!':
	begin
	o.koll:=2;
	o.l[1,1]:=2;
	o.l[2,1]:=5;
	o.l[1,2]:=42;
	o.l[2,2]:=8;
	end;
'[',']':
	begin
	o.l[1,1]:=11;
	o.l[2,1]:=10;
	o.l[1,2]:=14;
	o.l[2,2]:=15;
	case c of
	'[':begin
		o.l[1,3]:=10;
		o.l[2,3]:=14;
		end;
	']':begin
		o.l[1,3]:=11;
		o.l[2,3]:=15;
		end;
	end;
	o.koll:=3;
	end;
'ь','Ь':
	begin
	o.koll:=4;
	o.l[1,1]:=1;
	o.l[2,1]:=7;
	o.l[1,2]:=9;
	o.l[2,2]:=6;
	o.l[1,3]:=4;
	o.l[2,3]:=6;
	o.l[1,4]:=7;
	o.l[2,4]:=9;
	end;
'1':
	begin
	o.koll:=2;
	o.l[1,1]:=4;
	o.l[2,1]:=3;
	o.l[1,2]:=3;
	o.l[2,2]:=9;
	end;
'2':
	begin
	o.koll:=8;
	o.l[1,1]:=16;
	o.l[2,1]:=10;
	o.l[1,2]:=10;
	o.l[2,2]:=11;
	o.l[1,3]:=11;
	o.l[2,3]:=18;
	o.l[1,4]:=18;
	o.l[2,4]:=6;
	o.l[1,5]:=6;
	o.l[2,5]:=25;
	o.l[1,6]:=25;
	o.l[2,6]:=24;
	o.l[1,7]:=24;
	o.l[2,7]:=7;
	o.l[1,8]:=7;
	o.l[2,8]:=9;
	end;
'4':
	begin
	o.koll:=3;
	o.l[1,1]:=11;
	o.l[2,1]:=15;
	o.l[1,2]:=19;
	o.l[2,2]:=21;
	o.l[1,3]:=11;
	o.l[2,3]:=19;
	end;
'5':
	begin
	o.koll:=6;
	o.l[1,1]:=1;
	o.l[2,1]:=3;
	o.l[1,2]:=1;
	o.l[2,2]:=4;
	o.l[1,3]:=4;
	o.l[2,3]:=13;
	o.l[1,4]:=13;
	o.l[2,4]:=21;
	o.l[1,5]:=21;
	o.l[2,5]:=15;
	o.l[1,6]:=15;
	o.l[2,6]:=7;
	end;
'э','Э':
	begin
	o.koll:=8;
	o.l[1,1]:=16;
	o.l[2,1]:=10;
	o.l[1,2]:=10;
	o.l[2,2]:=11;
	o.l[1,3]:=11;
	o.l[2,3]:=18;
	o.l[1,4]:=18;
	o.l[2,4]:=21;
	o.l[1,5]:=6;
	o.l[2,5]:=5;
	o.l[1,6]:=19;
	o.l[2,6]:=14;
	o.l[1,7]:=21;
	o.l[2,7]:=15;
	o.l[1,8]:=15;
	o.l[2,8]:=14;
	end;
'Ю','ю':
	begin
	o.koll:=8;
	o.l[1,1]:=1;
	o.l[2,1]:=7;
	o.l[1,2]:=4;
	o.l[2,2]:=5;
	o.l[1,3]:=17;
	o.l[2,3]:=20;
	o.l[1,4]:=11;
	o.l[2,4]:=17;
	o.l[1,5]:=20;
	o.l[2,5]:=15;
	o.l[1,6]:=11;
	o.l[2,6]:=18;
	o.l[1,7]:=15;
	o.l[2,7]:=21;
	o.l[1,8]:=18;
	o.l[2,8]:=21;
	end;
'Я','я':
	begin
	o.koll:=6;
	o.l[1,1]:=16;
	o.l[2,1]:=10;
	o.l[1,2]:=16;
	o.l[2,2]:=12;
	o.l[1,3]:=12;
	o.l[2,3]:=6;
	o.l[1,4]:=10;
	o.l[2,4]:=3;
	o.l[1,5]:=3;
	o.l[2,5]:=9;
	o.l[1,6]:=5;
	o.l[2,6]:=7;
	end;
'@':
	begin
	o.koll:=8;
	o.l[1,1]:=22;
	o.l[2,1]:=23;
	o.l[1,2]:=23;
	o.l[2,2]:=25;
	o.l[1,3]:=24;
	o.l[2,3]:=21;
	o.l[1,4]:=24;
	o.l[2,4]:=22;
	o.l[1,5]:=1;
	o.l[2,5]:=7;
	o.l[1,6]:=1;
	o.l[2,6]:=3;
	o.l[1,7]:=3;
	o.l[2,7]:=21;
	o.l[1,8]:=7;
	o.l[2,8]:=9;
	end;
'щ','Щ':
	begin
	o.koll:=5;
	o.l[1,1]:=1;
	o.l[2,1]:=19;
	o.l[1,2]:=38;
	o.l[2,2]:=39;
	o.l[1,3]:=11;
	o.l[2,3]:=25;
	o.l[1,4]:=19;
	o.l[2,4]:=21;
	o.l[1,5]:=21;
	o.l[2,5]:=9;
	end;
'Ъ','ъ':
	begin
	o.koll:=6;
	o.l[1,1]:=16;
	o.l[2,1]:=1;
	o.l[1,2]:=1;
	o.l[2,2]:=10;
	o.l[1,3]:=10;
	o.l[2,3]:=14;
	o.l[1,4]:=14;
	o.l[2,4]:=9;
	o.l[1,5]:=9;
	o.l[2,5]:=6;
	o.l[1,6]:=6;
	o.l[2,6]:=12;
	end;
'7':
	begin
	o.koll:=2;
	o.l[1,1]:=3;
	o.l[2,1]:=1;
	o.l[1,2]:=3;
	o.l[2,2]:=14;
	end;
'D','d':
	begin
	o.koll:=6;
	o.l[1,1]:=7;
	o.l[2,1]:=1;
	o.l[1,2]:=1;
	o.l[2,2]:=11;
	o.l[1,3]:=7;
	o.l[2,3]:=15;
	o.l[1,4]:=15;
	o.l[2,4]:=21;
	o.l[1,5]:=11;
	o.l[2,5]:=18;
	o.l[1,6]:=18;
	o.l[2,6]:=21;
	end;
'f','F':
	begin
	o.koll:=3;
	o.l[1,1]:=7;
	o.l[2,1]:=1;
	o.l[1,2]:=1;
	o.l[2,2]:=3;
	o.l[1,3]:=4;
	o.l[2,3]:=5;
	end;
'z','Z':
	begin
	o.koll:=3;
	o.l[1,1]:=7;
	o.l[2,1]:=3;
	o.l[1,2]:=1;
	o.l[2,2]:=3;
	o.l[1,3]:=9;
	o.l[2,3]:=7;
	end;
'9':
	begin
	o.koll:=5;
	o.l[1,1]:=4;
	o.l[2,1]:=1;
	o.l[1,2]:=3;
	o.l[2,2]:=9;
	o.l[1,3]:=1;
	o.l[2,3]:=3;
	o.l[1,4]:=4;
	o.l[2,4]:=6;
	o.l[1,5]:=7;
	o.l[2,5]:=9;
	end;
'G','g':
	begin
	o.koll:=9;
	o.l[1,1]:=16;
	o.l[2,1]:=10;
	o.l[1,2]:=10;
	o.l[2,2]:=11;
	o.l[1,3]:=11;
	o.l[2,3]:=18;
	o.l[1,5]:=16;
	o.l[2,5]:=19;
	o.l[1,6]:=19;
	o.l[2,6]:=14;
	o.l[1,7]:=21;
	o.l[2,7]:=15;
	o.l[1,4]:=15;
	o.l[2,4]:=14;
	o.l[1,9]:=6;
	o.l[2,9]:=21;
	o.l[1,8]:=6;
	o.l[2,8]:=5;
	end;
'I','i':
	begin
	o.koll:=3;
	o.l[1,1]:=11;
	o.l[2,1]:=10;
	o.l[1,2]:=14;
	o.l[2,2]:=15;
	o.l[1,3]:=2;
	o.l[2,3]:=8;
	end;
'J','j':
	begin
	o.koll:=6;
	o.l[1,1]:=2;
	o.l[2,1]:=11;
	o.l[1,2]:=25;
	o.l[2,2]:=11;
	o.l[1,3]:=25;
	o.l[2,3]:=8;
	o.l[1,5]:=14;
	o.l[2,5]:=8;
	o.l[1,6]:=19;
	o.l[2,6]:=14;
	o.l[1,4]:=4;
	o.l[2,4]:=19;
	end;
'l','L':
	begin
	o.koll:=3;
	o.l[1,1]:=1;
	o.l[2,1]:=7;
	o.l[1,2]:=7;
	o.l[2,2]:=9;
	o.l[1,3]:=9;
	o.l[2,3]:=21;
	end;
'\':
	begin
	o.koll:=1;
	o.l[1,1]:=10;
	o.l[2,1]:=15;
	end;
'/':
	begin
	o.koll:=1;
	o.l[1,1]:=11;
	o.l[2,1]:=14;
	end;
'*':
	begin
	o.koll:=4;
	o.l[1,1]:=17;
	o.l[2,1]:=20;
	o.l[1,2]:=12;
	o.l[2,2]:=13;
	o.l[1,3]:=25;
	o.l[2,3]:=22;
	o.l[1,4]:=24;
	o.l[2,4]:=23;
	end;
'(':
	begin
	o.koll:=5;
	o.l[1,1]:=11;
	o.l[2,1]:=2;
	o.l[1,2]:=2;
	o.l[2,2]:=22;
	o.l[1,3]:=22;
	o.l[2,3]:=24;
	o.l[1,4]:=24;
	o.l[2,4]:=8;
	o.l[1,5]:=8;
	o.l[2,5]:=15;
	end;
')':
	begin
	o.koll:=5;
	o.l[1,1]:=10;
	o.l[2,1]:=2;
	o.l[1,2]:=2;
	o.l[2,2]:=23;
	o.l[1,3]:=23;
	o.l[2,3]:=25;
	o.l[1,4]:=25;
	o.l[2,4]:=8;
	o.l[1,5]:=8;
	o.l[2,5]:=14;
	end;
'}':
	begin
	o.koll:=6;
	o.l[1,1]:=10;
	o.l[2,1]:=2;
	o.l[1,2]:=2;
	o.l[2,2]:=17;
	o.l[1,3]:=17;
	o.l[2,3]:=13;
	o.l[1,5]:=13;
	o.l[2,5]:=20;
	o.l[1,6]:=20;
	o.l[2,6]:=8;
	o.l[1,4]:=14;
	o.l[2,4]:=8;
	end;
'{':
	begin
	o.koll:=6;
	o.l[1,1]:=2;
	o.l[2,1]:=11;
	o.l[1,2]:=2;
	o.l[2,2]:=17;
	o.l[1,3]:=17;
	o.l[2,3]:=12;
	o.l[1,5]:=12;
	o.l[2,5]:=20;
	o.l[1,6]:=20;
	o.l[2,6]:=8;
	o.l[1,4]:=8;
	o.l[2,4]:=15;
	end;
'n','N':
	begin
	o.koll:=3;
	o.l[1,1]:=1;
	o.l[2,1]:=7;
	o.l[1,2]:=3;
	o.l[2,2]:=9;
	o.l[1,3]:=1;
	o.l[2,3]:=9;
	end;
'Q','q':
	begin
	o.koll:=10;
	o.l[1,1]:=16;
	o.l[2,1]:=10;
	o.l[1,2]:=10;
	o.l[2,2]:=11;
	o.l[1,3]:=11;
	o.l[2,3]:=18;
	o.l[1,4]:=18;
	o.l[2,4]:=21;
	o.l[1,5]:=16;
	o.l[2,5]:=19;
	o.l[1,6]:=19;
	o.l[2,6]:=14;
	o.l[1,7]:=21;
	o.l[2,7]:=15;
	o.l[1,8]:=15;
	o.l[2,8]:=14;
	o.l[1,9]:=15;
	o.l[2,9]:=20;
	o.l[1,10]:=15;
	o.l[2,10]:=32;
	end;
'#':
	begin
	o.koll:=4;
	o.l[1,1]:=16;
	o.l[2,1]:=18;
	o.l[1,2]:=19;
	o.l[2,2]:=21;
	o.l[1,3]:=10;
	o.l[2,3]:=14;
	o.l[1,4]:=11;
	o.l[2,4]:=15;
	end;
'%':
	begin
	o.koll:=9;
	o.l[1,1]:=3;
	o.l[2,1]:=7;
	o.l[1,2]:=10;
	o.l[2,2]:=22;
	o.l[1,3]:=22;
	o.l[2,3]:=16;
	o.l[1,4]:=16;
	o.l[2,4]:=1;
	o.l[1,5]:=1;
	o.l[2,5]:=10;
	o.l[1,6]:=9;
	o.l[2,6]:=21;
	o.l[1,7]:=21;
	o.l[2,7]:=25;
	o.l[1,8]:=25;
	o.l[2,8]:=15;
	o.l[1,9]:=15;
	o.l[2,9]:=9;
	end;
'y','Y':
	begin
	o.koll:=3;
	o.l[1,1]:=3;
	o.l[2,1]:=5;
	o.l[1,2]:=1;
	o.l[2,2]:=5;
	o.l[1,3]:=5;
	o.l[2,3]:=8;
	end;
'№':
	begin
	o.koll:=8;
	o.l[1,1]:=1;
	o.l[2,1]:=7;
	o.l[1,2]:=1;
	o.l[2,2]:=8;
	o.l[1,3]:=2;
	o.l[2,3]:=8;
	o.l[1,4]:=18;
	o.l[2,4]:=23;
	o.l[1,5]:=23;
	o.l[2,5]:=13;
	o.l[1,6]:=13;
	o.l[2,6]:=6;
	o.l[1,7]:=6;
	o.l[2,7]:=18;
	o.l[1,8]:=25;
	o.l[2,8]:=21;
	end;
'r','R':
	begin
	o.koll:=6;
	o.l[1,1]:=1;
	o.l[2,1]:=7;
	o.l[1,2]:=1;
	o.l[2,2]:=11;
	o.l[1,3]:=11;
	o.l[2,3]:=18;
	o.l[1,4]:=18;
	o.l[2,4]:=13;
	o.l[1,5]:=13;
	o.l[2,5]:=4;
	o.l[1,6]:=5;
	o.l[2,6]:=9;
	end;
',':
	begin
	o.koll:=1;
	o.l[1,1]:=41;
	o.l[2,1]:=42;
	end;
's','S':
	begin
	o.koll:=9;
	o.l[1,1]:=18;
	o.l[2,1]:=11;
	o.l[1,2]:=10;
	o.l[2,2]:=11;
	o.l[1,3]:=10;
	o.l[2,3]:=16;
	o.l[1,4]:=16;
	o.l[2,4]:=12;
	o.l[1,5]:=12;
	o.l[2,5]:=13;
	o.l[1,6]:=13;
	o.l[2,6]:=21;
	o.l[1,7]:=21;
	o.l[2,7]:=15;
	o.l[1,8]:=14;
	o.l[2,8]:=15;
	o.l[1,9]:=19;
	o.l[2,9]:=14;
	end;
'u','U':
	begin
	o.koll:=5;
	o.l[1,1]:=1;
	o.l[2,1]:=19;
	o.l[1,2]:=19;
	o.l[2,2]:=14;
	o.l[1,3]:=14;
	o.l[2,3]:=15;
	o.l[1,4]:=15;
	o.l[2,4]:=21;
	o.l[1,5]:=21;
	o.l[2,5]:=3;
	end;
'v','V':
	begin
	o.koll:=2;
	o.l[1,1]:=1;
	o.l[2,1]:=8;
	o.l[1,2]:=8;
	o.l[2,2]:=3;
	end;
'w','W':
	begin
	o.koll:=4;
	o.l[1,1]:=1;
	o.l[2,1]:=14;
	o.l[1,2]:=14;
	o.l[2,2]:=5;
	o.l[1,3]:=5;
	o.l[2,3]:=15;
	o.l[1,4]:=15;
	o.l[2,4]:=3;
	end;
'>':
	begin
	o.koll:=2;
	o.l[1,1]:=10;
	o.l[2,1]:=6;
	o.l[1,2]:=6;
	o.l[2,2]:=14;
	end;
'<':
	begin
	o.koll:=2;
	o.l[1,1]:=11;
	o.l[2,1]:=4;
	o.l[1,2]:=4;
	o.l[2,2]:=15;
	end;
'.':
	begin
	o.koll:=1;
	o.l[1,1]:=42;
	o.l[2,1]:=8;
	end;
':':
	begin
	o.koll:=2;
	o.l[1,1]:=43;
	o.l[2,1]:=2;
	o.l[1,2]:=8;
	o.l[2,2]:=42;
	end;
';':
	begin
	o.koll:=2;
	o.l[1,1]:=43;
	o.l[2,1]:=2;
	o.l[1,2]:=42;
	o.l[2,2]:=41;
	end;
'$':
	begin
	o.koll:=10;
	o.l[1,1]:=18;
	o.l[2,1]:=11;
	o.l[1,2]:=10;
	o.l[2,2]:=11;
	o.l[1,3]:=10;
	o.l[2,3]:=16;
	o.l[1,4]:=16;
	o.l[2,4]:=12;
	o.l[1,5]:=12;
	o.l[2,5]:=13;
	o.l[1,6]:=13;
	o.l[2,6]:=21;
	o.l[1,7]:=21;
	o.l[2,7]:=15;
	o.l[1,8]:=14;
	o.l[2,8]:=15;
	o.l[1,9]:=19;
	o.l[2,9]:=14;
	o.l[1,10]:=44;
	o.l[2,10]:=45;
	end;
'"':
	begin
	o.koll:=2;
	o.l[1,1]:=10;
	o.l[2,1]:=22;
	o.l[1,2]:=11;
	o.l[2,2]:=23;
	end;
'~':
	begin
	o.koll:=3;
	o.l[1,1]:=4;
	o.l[2,1]:=22;
	o.l[1,2]:=22;
	o.l[2,2]:=25;
	o.l[1,3]:=6;
	o.l[2,3]:=25;
	end;
'`':
	begin
	o.koll:=1;
	o.l[1,1]:=2;
	o.l[2,1]:=23;
	end;
'?':
	begin
	o.koll:=5;
	o.l[1,1]:=16;
	o.l[2,1]:=10;
	o.l[1,2]:=10;
	o.l[2,2]:=11;
	o.l[1,3]:=11;
	o.l[2,3]:=18;
	o.l[1,4]:=18;
	o.l[2,4]:=20;
	o.l[1,5]:=42;
	o.l[2,5]:=8;
	end;
'|':
	begin
	o.koll:=1;
	o.l[1,1]:=2;
	o.l[2,1]:=8;
	end;
else
	begin
	o.koll:=0;
	end;
end;
GlSanLoadBykv:=o;
end;

procedure GlSanOutText(tochka:GlSanKoor;str:string;r:real);
begin
GlSanOutText(tochka,str,GlSanKoor2fImport(r,r));
end;

procedure GlSanABCObj.Init(toC:GlSanKoor;r:real);
var
	i:longword;
	o1,o2:GlSanKoor;
begin
for i:=1 to KolL do
	begin
	o1:=GlSanLoadABCToch(L[1,i]);
	o2:=GlSanLoadABCToch(L[2,i]);
	o1.Zum(r);
	o2.Zum(r);
	o1.Togever(toc);
	o2.Togever(toc);
	GlSanLine(o1,o2);
	end;
end;
{$IFDEF MSWINDOWS}
	function GlSanLoadTexturePoint(n:dword):pointer;
	var
	  gBitmap : hBitmap;
	  sBitmap : Bitmap;
		TextureID:^GLuint;
	begin
	 gbitmap := Windows.LoadImage(GetModuleHandle(NIL), MAKEINTRESOURCE(N), IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION);
	 GetObject(gbitmap, sizeof(sbitmap), @sbitmap);

	  new(TextureID);
	  glGenTextures(1, TextureID  );//Присвоение TextureID значения
	  glBindTexture(GL_TEXTURE_2D, TextureID^);
	  glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
	  glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	  glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
	  glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);

	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

	  glTexImage2D(GL_TEXTURE_2D, 0, 3, sbitmap.bmWidth, sbitmap.bmHeight, 0, GL_BGR_EXT, GL_UNSIGNED_BYTE, sbitmap.bmBits);

	 glBindTexture(GL_TEXTURE_2D, TextureID^);
	GlSanLoadTexturePoint:=TextureID;
	end;
	{$ENDIF}

procedure GlSanSphere(t:glSanKoor;r:real;p1,p2:longint);
begin
Sphere.Init(t,r);
end;
function maximum(q1,q2:real):real;
begin
if q1>q2 then maximum:=q1 else maximum:=q2;
end;

procedure GlSanCircle(l:longint;q:real);
var
	_1,d:real;
	_2,o:GlSanKoor2f;
	i:longint;
begin
_1:=(2*pi)/l;
d:=0;
_2.x:=1*q;
_2.y:=0;
for i:=1 to l do
	begin
	d+=_1;
	o.x:=cos(d)*q;
	o.y:=sin(d)*q;
	glSanLine(O.GSK3,_2.GSK3);
	_2:=o;
	end;
end;


procedure GlSanClear;
begin
glClear(GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT);
glLoadIdentity();
glTranslatef(0,0,0);
glRotatef( 0,0,1,0);
end;

procedure PA3(q,ya:pointer;TipY:longint);
var
	_1:^string;					__1:^string;
	_2:^longint;				__2:^longint;
	_3:^pointer;				__3:^pointer;
	_4:^char;					__4:^char;
	_5:^real;					__5:^real;
	_6:^word;					__6:^word;
	_7:^extended;				__7:^extended;
	_8:^pchar;					__8:^pchar;
	_9:^byte;					__9:^byte;
	_10:^longword;				__10:^longword;
	yas:^GlSanYT;
begin
yas:=q;
yas^.Tip:=TipY;
case TipY of
Gl_SAN_STRING:
	begin
	{$IFDEF MSWINDOWS}MessageBox(0, '"GlSanAnyType" Type of AnsiString is not Going!', 'Error', MB_OK);{$ENDIF}
	//new(_1);
	__1:=nil;//__1:=ya;
	_1:=__1;
	Yas^.r:=_1;
	end;
GL_SAN_LONGINT:
	begin
	new(_2);
	__2:=ya;
	_2^:=__2^;
	Yas^.r:=_2;
	end;
GL_SAN_POINTER:
	begin
	new(_3);
	__3:=ya;
	_3^:=__3^;
	Yas^.r:=_3;
	end;
GL_SAN_CHAR:
	begin
	new(_4);
	__4:=ya;
	_4^:=__4^;
	Yas^.r:=_4;
	end;
GL_SAN_REAL:
	begin
	new(_5);
	__5:=ya;
	_5^:=__5^;
	Yas^.r:=_5;
	end;
GL_SAN_WORD:
	begin
	new(_6);
	__6:=ya;
	_6^:=__6^;
	Yas^.r:=_6;
	end;
GL_SAN_EXTENDED:
	begin
	new(_7);
	__7:=ya;
	_7^:=__7^;
	Yas^.r:=_7;
	end;
GL_SAN_PCHAR:
	begin
	new(_8);
	__8:=ya;
	_8^:=__8^;
	Yas^.r:=_8;
	end;
GL_SAN_BYTE:
	begin
	new(_9);
	__9:=ya;
	_9^:=__9^;
	Yas^.r:=_9;
	end;
GL_SAN_DWORD:
	begin
	new(_10);
	__10:=ya;
	_10^:=__10^;
	Yas^.r:=_10;
	end;
end;
end;

procedure PrisArray(YK:pointer;T{DLINNA}:longint;L:pointer;TipYach:longint);
var
	Y:^GlSanArray;
procedure PA2(q:pointer;d:longint;l:pointer;t,TipYacheiki:longint);
var
	g:^GlSanUA;
	g2:^GlSanUA2;
begin
g:=q;
g2:=q;
if d>1000 then
	begin
	case t of
	1:PA2(g^.sl,d-1000,l,2,TipYacheiki);
	2:PA2(g2^.sl,d-1000,l,1,TipYacheiki);
	end;
	end
else
	begin
	PA3(g^.UA[d],l,TipYacheiki);
	end;
end;
begin
Y:=YK;
PA2(Y^.YA	,T	,l,1,TipYach);
end;

procedure ConstArray(YK:pointer;D,K:longint);
var
	Y:^GlSanUA;
	Y2:^GlSanUA2;
	i,ii:longint;
begin
case k of
1:
	begin
	Y:=YK;
	system.new(y);
	if d>1000 then
		ii:=1000
	else
		ii:=d;
	for i:=1 to ii do
		system.new(Y^.UA[i]);
	if d>1000 then
		begin
		ConstArray(Y^.SL,d-1000,2);
		end;
	end;
2:
	begin
	Y2:=YK;
	system.new(y2);
	if d>1000 then
		ii:=1000
	else
		ii:=d;
	for i:=1 to ii do
		system.new(Y2^.UA[i]);
	if d>1000 then
		begin
		ConstArray(Y2^.SL,d-1000,1);
		end;
	end;
end;
end;

procedure InitArray(YK:pointer; T:longint; d:longint);
var
	Y:^GlSanArray;
begin
Y:=YK;
Y^.DL:=D;
ConstArray(Y^.YA,d,1);
end;


function GlSanMouseXY(q:longint):GlSanKoor2f;
begin
GlSanMouseXY.x:=Trunc(SGMouseCoords[q-1].x);
GlSanMouseXY.y:=Trunc(SGMouseCoords[q-1].y);
end;

function GlSanMouseC(q:longint):boolean;
begin
GlSanMouseC:=SGMouseKeysDown[q-1];
end;

function GlSanConvertObjectToMesh(O:GlSanObj):GlSanMesh;
var M:GlSanMesh;
	i:longint;
begin
M.KolT:=O.KolT;
M.Toch:=O.Toch;
M.KolF:=O.KolF;
M.Fig:=O.Fig;
for i:=1 to 500 do
	M.Chv[i]:=nil;
for i:=1 to M.KolF do
	begin
	system.new(M.Chv[i]);
	M.Chv[i]^.TipZ:=O.Chv[i]^.TipZ;
	M.Chv[i]^.Tip:=O.Chv[i]^.Tip;
	M.Chv[i]^._1:=O.Chv[i]^._1;
	M.Chv[i]^._2:=O.Chv[i]^._2;
	if (M.Chv[i]^.Tip in [3,4,5]) then
		M.Chv[i]^._3:=GlSanLoadTexture(O.Chv[i]^._3);
	end;
GlSanConvertObjectToMesh:=M;
end;

procedure GlSanMesh.Init(x,y,z,r:real);
var i,ii:longint;
begin
for i:=1 to KolF do
	begin
	glPolygonMode (GL_FRONT_AND_BACK,Chv[i]^.TipZ);
	glColor3f(1,1,1);
	case Chv[i]^.Tip of
	1:Chv[i]^._1.SanSetColor;
	2:Chv[i]^._2.SanSetColor;
	3:
		begin
		GlSanTextureActivate2D(Chv[i]^._3);
		end;
	4:begin
		Chv[i]^._1.SanSetColor;
		GlSanTextureActivate2D(Chv[i]^._3);
		end;
	5:
		begin
		Chv[i]^._2.SanSetColor;
		GlSanTextureActivate2D(Chv[i]^._3);
		end;
	end;
	glBegin(Fig[i]^.Tip);
	for ii:=1 to Fig[i]^.Kol do
		begin
		if (Chv[i]^.Tip in [3,4,5]) then
			case ii of
			1:glTexCoord2f(0.0, 0.0);
			2:glTexCoord2f(1.0, 0.0);
			3:glTexCoord2f(1.0, 1.0);
			4:glTexCoord2f(0.0, 1.0);
			end;
		glVertex3f(
			Toch[Fig[i]^.T[ii]]^.x*r+x,
			Toch[Fig[i]^.T[ii]]^.y*r+y,
			Toch[Fig[i]^.T[ii]]^.z*r+z
			);
		end;
	glEnd;
	end;
end;

function GlSanLoadTexture(NameResource:longint):GlUint;
begin
GlSanLoadTexture:=GlSanTextureLoad(NameResource);
end;

function GlSanTextureLoad(NameResource:longint):GlUint;
{$IFDEF MSWINDOWS}
	var x,y:longint;
		g:gluint;
	{$ENDIF}
begin
{$IFDEF MSWINDOWS}
	g:=GlSanLoadTexture(NameResource, x , y);
	GlSanTextureLoad:=g;
{$ELSE}
	GlSanTextureLoad:=0;
	{$ENDIF}
end;

procedure GlSanLogotip(t:longint;sz:pchar);
var
	i , x , y:longint;
	{$IFDEF MSWINDOWS}
		q2:GLUint;
		{$ENDIF}
	z, zz, z1, p,yx:real;
begin
glEnable(GL_TEXTURE_2D);
{$IFDEF MSWINDOWS}
	q2:=GlSanLoadTexture(t,x,y);
{$ELSE}
	x:=128;
	y:=128;
	{$ENDIF}
glPolygonMode (GL_FRONT_AND_BACK, GL_fill);
z:=-8.8;
z1:=-3.2;
i:=1;
zz:=(z1-z)/100;
p:=0.1;
yx:=y/x;
repeat
inc(i);
z+=zz;
if i<80 then
	begin
	p+=0.9/100;
	end
else
	begin
	p-=2/100;
	end;
glClear(GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT);
glLoadIdentity();
glTranslatef(0,0,z);
glcolor4f(1,1,1,p);
{$IFDEF MSWINDOWS}
	GlSanTextureActivate2D(q2);
	{$ENDIF}
glBegin(GL_quads);
					glTexCoord2f(0, 0);
 glVertex3f(-1,-1*yx+0.25*yx,0);
					glTexCoord2f(0, 1);
 glVertex3f(-1,1+0.25*yx,0);
					glTexCoord2f(1, 1);
 glVertex3f(1,1+0.25*yx,0);
					glTexCoord2f(1, 0);
 glVertex3f(1,-1*yx+0.25*yx,0);
 glEnd;
until GlSanAfterUntil(0, i=110 , false);
glcolor4f(1,1,1,1);
end;


procedure GlSanTextureActivate2D(a:GLUint);
begin
glBindTexture(GL_TEXTURE_2D,a);
end;

function GlSanMouseB(q:longint):boolean;
begin
case q of
1:GlSanMouseB:=SGIsMouseKeyDown(1);
2:GlSanMouseB:=SGMouseKeysDown[2];
3:GlSanMouseB:=SGMouseKeysDown[2];
end;
if (q=1) and (GlSanWndMove or GlSanWndListBoxMoveButton) then GlSanMouseB:=false;
end;

function GlSanAfterUntil(q:longint;l,o:boolean):boolean;
var i:longint;
{$IFDEF MSWINDOWS}
	rec:trect;
	{$ENDIF}
begin
GlSanDelay;
GlSanWindows;
case q of
0:
	begin
	if ((SGContextActive=false) or (l=true)) then
		begin
		GlSanAfterUntil:=true;
		if o then SGCloseContext;
		end
	else
		begin
		end;
	end
else
	begin
	if ((GlSanReadKey=q) or (SGContextActive=false)or (l=true)) then
		begin
		GlSanAfterUntil:=true;
		if o then SGCloseContext;
		end
	else
		begin
		end;
	end;
	end;
end;

procedure InitRot(ob:GlSanObject;os:longint;yg:real;t:GlSanKoor;r:real);
begin
glPushMatrix;
glTranslatef(t.x,t.y,t.z);
case os of
1:glRotatef( yg, 1, 0, 0);
2:glRotatef( yg, 0, 1, 0);
3:glRotatef( yg, 0, 0, 1);
end;
ob.Init(0,0,0,r);
glPopMatrix;
end;

procedure InitRot(ob:GlSanObject;yg1,yg2,yg3:real;t:GlSanKoor;r:real);
begin
glPushMatrix;
glTranslatef(t.x,t.y,t.z);
glRotatef( yg1, 1, 0, 0);
glRotatef( yg2, 0, 1, 0);
glRotatef( yg3, 0, 0, 1);
ob.Init(0,0,0,r);
glPopMatrix;
end;

function GlSanKoor2f.GSK3:GlSanKoor;
begin
GSK3.x:=x;
GSK3.y:=y;
GSK3.z:=0;
end;

procedure GlSanKoor2f.Import(a,b:real);
begin
x:=a;
y:=b;
end;

function GlSanObject_Quadros(ss:longint):GlSanObject;
var
	i:longint;
	o:GlSanObject;
	ch:GlSanChvObj;
	fg:GlSanFigObj;
begin
Ch.TipZ:=Gl_FILL;
Ch.Tip:=5;
Ch._3:=ss;
Ch._1.Import(1,1,1);
Ch._2.Import(1,0,1,0.2);
O.New(8,6);
O.Toch[1]^.Import(-1,-1,1);
O.Toch[2]^.Import(-1,1,1);
O.Toch[3]^.Import(-1,1,-1);
O.Toch[4]^.Import(-1,-1,-1);
O.Toch[5]^.Import(1,1,-1);
O.Toch[6]^.Import(1,1,1);
O.Toch[7]^.Import(1,-1,1);
O.Toch[8]^.Import(1,-1,-1);
for i:=1 to 6 do
	O.Chv[i]^:=Ch;
Fg.Kol:=4;
Fg.Tip:=Gl_Quads;
for i:=1 to 6 do
	O.Fig[i]^:=Fg;
	O.Fig[1]^.T[1]:=4;
	O.Fig[1]^.T[2]:=3;
	O.Fig[1]^.T[3]:=2;
	O.Fig[1]^.T[4]:=1;
O.Fig[2]^.T[1]:=3;
O.Fig[2]^.T[2]:=5;
O.Fig[2]^.T[3]:=6;
O.Fig[2]^.T[4]:=2;
	O.Fig[3]^.T[1]:=1;
	O.Fig[3]^.T[2]:=2;
	O.Fig[3]^.T[3]:=6;
	O.Fig[3]^.T[4]:=7;
O.Fig[4]^.T[1]:=5;
O.Fig[4]^.T[2]:=3;
O.Fig[4]^.T[3]:=4;
O.Fig[4]^.T[4]:=8;
	O.Fig[5]^.T[1]:=6;
	O.Fig[5]^.T[2]:=5;
	O.Fig[5]^.T[3]:=8;
	O.Fig[5]^.T[4]:=7;
O.Fig[6]^.T[1]:=4;
O.Fig[6]^.T[2]:=1;
O.Fig[6]^.T[3]:=7;
O.Fig[6]^.T[4]:=8;
GlSanObject_Quadros:=O;
end;

function GlSanObject_Quadros(sss:GlSancolor4f):GlSanObject;
var
	i:longint;
	o:GlSanObject;
	ch:GlSanChvObj;
	fg:GlSanFigObj;
begin
Ch.TipZ:=Gl_FILL;
Ch.Tip:=2;
Ch._2:=sss;
O.New(8,6);
O.Toch[1]^.Import(-1,-1,1);
O.Toch[2]^.Import(-1,1,1);
O.Toch[3]^.Import(-1,1,-1);
O.Toch[4]^.Import(-1,-1,-1);
O.Toch[5]^.Import(1,1,-1);
O.Toch[6]^.Import(1,1,1);
O.Toch[7]^.Import(1,-1,1);
O.Toch[8]^.Import(1,-1,-1);
for i:=1 to 6 do
	O.Chv[i]^:=Ch;
Fg.Kol:=4;
Fg.Tip:=Gl_Quads;
for i:=1 to 6 do
	O.Fig[i]^:=Fg;
	O.Fig[1]^.T[1]:=4;
	O.Fig[1]^.T[2]:=3;
	O.Fig[1]^.T[3]:=2;
	O.Fig[1]^.T[4]:=1;
O.Fig[2]^.T[1]:=3;
O.Fig[2]^.T[2]:=5;
O.Fig[2]^.T[3]:=6;
O.Fig[2]^.T[4]:=2;
	O.Fig[3]^.T[1]:=1;
	O.Fig[3]^.T[2]:=2;
	O.Fig[3]^.T[3]:=6;
	O.Fig[3]^.T[4]:=7;
O.Fig[4]^.T[1]:=5;
O.Fig[4]^.T[2]:=3;
O.Fig[4]^.T[3]:=4;
O.Fig[4]^.T[4]:=8;
	O.Fig[5]^.T[1]:=6;
	O.Fig[5]^.T[2]:=5;
	O.Fig[5]^.T[3]:=8;
	O.Fig[5]^.T[4]:=7;
O.Fig[6]^.T[1]:=4;
O.Fig[6]^.T[2]:=1;
O.Fig[6]^.T[3]:=7;
O.Fig[6]^.T[4]:=8;
GlSanObject_Quadros:=O;
end;
procedure GlSanObject.ExportFromFile(s:string);
var
	f:text;
	i,ii:longint;
begin
assign(f,s);
rewrite(f);
writeln(f,'    GlSanObgect  (   Sanches Corporation OpenGL Application   )');
writeln(f,KolT);
for i:=1 to KolT do
	begin
	writeln(f,Toch[i]^.x);
	writeln(f,Toch[i]^.y);
	writeln(f,Toch[i]^.z);
	end;
writeln(f,KolF);
for i:=1 to KolF do
	begin
	writeln(f,Chv[i]^.TipZ);
	writeln(f,Chv[i]^.Tip);
	case Chv[i]^.Tip of
	1:
		begin
		writeln(f,Chv[i]^._1.x);
		writeln(f,Chv[i]^._1.y);
		writeln(f,Chv[i]^._1.z);
		end;
	2:
		begin
		writeln(f,Chv[i]^._2.a);
		writeln(f,Chv[i]^._2.b);
		writeln(f,Chv[i]^._2.c);
		writeln(f,Chv[i]^._2.d);
		end;
	3:writeln(f,Chv[i]^._3);
	end;
	writeln(f,Fig[i]^.Kol);
	writeln(f,Fig[i]^.Tip);
	for ii:=1 to Fig[i]^.Kol do
		writeln(f,Fig[i]^.T[ii]);
	end;
close(f);
end;

procedure GlSanObject.Init(x,y,z,r:real);
var ii,i:longint;
begin
for i:=1 to KolF do
	begin
	//glPolygonMode (GL_FRONT_AND_BACK,Chv[i]^.TipZ);
	glColor3f(1,1,1);
	case Chv[i]^.Tip of
	1:Chv[i]^._1.SanSetColor;
	2:Chv[i]^._2.SanSetColor;
	3:
		begin
		glEnable(GL_TEXTURE_2D);
		{$IFDEF MSWINDOWS}
			Texture_Init(Chv[i]^._3);
			{$ENDIF}
		end;
	4:begin
		glEnable(GL_TEXTURE_2D);
		Chv[i]^._1.SanSetColor;
		{$IFDEF MSWINDOWS}
			Texture_Init(Chv[i]^._3);
			{$ENDIF}
		end;
	5:
		begin
		glEnable(GL_TEXTURE_2D);
		Chv[i]^._2.SanSetColor;
		{$IFDEF MSWINDOWS}
			Texture_Init(Chv[i]^._3);
			{$ENDIF}
		end;
	end;
	glBegin(Fig[i]^.Tip);
	for ii:=1 to Fig[i]^.Kol do
		begin
		if (Chv[i]^.Tip in [3,4,5]) then
			case ii of
			1:glTexCoord2f(0.0, 0.0);
			2:glTexCoord2f(1.0, 0.0);
			3:glTexCoord2f(1.0, 1.0);
			4:glTexCoord2f(0.0, 1.0);
			end;
		glVertex3f(
			Toch[Fig[i]^.T[ii]]^.x*r+x,
			Toch[Fig[i]^.T[ii]]^.y*r+y,
			Toch[Fig[i]^.T[ii]]^.z*r+z
			);
		end;
	glEnd;
	glDisable(GL_TEXTURE_2D);
	end;
end;
{$IFDEF MSWINDOWS}
	procedure Texture_Init(NameResource:longint);
	var
	  gBitmap : hBitmap;
	  sBitmap : Bitmap;
		TextureID:GLuint;
	begin
	 gbitmap := Windows.LoadImage(GetModuleHandle(NIL), MAKEINTRESOURCE(NameResource), IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION);
	 GetObject(gbitmap, sizeof(sbitmap), @sbitmap);


	  glGenTextures(1, @TextureID);//Присвоение TextureID значения
	  glBindTexture(GL_TEXTURE_2D, TextureID);
	  glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
	  glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	  glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
	  glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);

	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

	  glTexImage2D(GL_TEXTURE_2D, 0, 3, sbitmap.bmWidth, sbitmap.bmHeight, 0, GL_BGR_EXT, GL_UNSIGNED_BYTE, sbitmap.bmBits);

	 glBindTexture(GL_TEXTURE_2D, TextureID);

	end;

	function GlSanLoadTexture(NameResource:longint; var x,y:longint):GlUint;
	var
	  gBitmap : hBitmap;
	  sBitmap : Bitmap;
		TextureID:GLuint;
	begin
	 gbitmap := Windows.LoadImage(GetModuleHandle(NIL), MAKEINTRESOURCE(NameResource), IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION);
	 GetObject(gbitmap, sizeof(sbitmap), @sbitmap);


	  glGenTextures(1, @TextureID);
	  glBindTexture(GL_TEXTURE_2D, TextureID);

	  glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
	  glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	  glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
	  glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);

	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	x:=sbitmap.bmWidth;
	y:=sbitmap.bmHeight;
	  glTexImage2D(GL_TEXTURE_2D, 0, 3, sbitmap.bmWidth, sbitmap.bmHeight, 0, GL_BGR_EXT, GL_UNSIGNED_BYTE, sbitmap.bmBits);

	 glBindTexture(GL_TEXTURE_2D, TextureID);
	GlSanLoadTexture:=TextureID;
	end;
	{$ENDIF}




procedure GlSanObject.ImportFromFile(s:string);
var
	i,ii:longint;
	f:text;
begin
assign(f,s);
reset(f);
readln(f);
readln(f,KolT);
for i:=1 to KolT do
	begin
	system.new(Toch[i]);
	readln(f,Toch[i]^.x);
	readln(f,Toch[i]^.y);
	readln(f,Toch[i]^.z);
	end;
for i:=KolT+1 to 500 do Toch[i]:=nil;
readln(f,KolF);
for i:=KolF+1 to 500 do
	begin
	Fig[i]:=nil;
	Chv[i]:=nil;
	end;
for i:=1 to KolF do
	begin
	readln(f,Chv[i]^.TipZ);
	readln(f,Chv[i]^.Tip);
	case Chv[i]^.Tip of
	1:
		begin
		readln(f,Chv[i]^._1.x);
		readln(f,Chv[i]^._1.y);
		readln(f,Chv[i]^._1.z);
		end;
	2:
		begin
		readln(f,Chv[i]^._2.a);
		readln(f,Chv[i]^._2.b);
		readln(f,Chv[i]^._2.c);
		readln(f,Chv[i]^._2.d);
		end;
	3:
		begin
		readln(f,Chv[i]^._3);
		end;
	end;
	readln(f,Fig[i]^.Kol);
	readln(f,Fig[i]^.Tip);
	for ii:=1 to Fig[i]^.Kol do
		readln(Fig[i]^.T[i]);
	end;
close(f);
end;

procedure GlSanObject.Dispose;
var i:longint;
begin
for i:=1 to KolT do
	system.dispose(Toch[i]);
for i:=1 to KolF do
	system.dispose(Fig[i]);
KolF:=0;
KolT:=0;
end;

procedure GlSanObject.New(KT,KF:longint);
var i:longint;
begin
KolT:=KT;
for i:=1 to KT do
	system.new(Toch[i]);
for i:=KT+1 to 500 do
	Toch[i]:=nil;
KolF:=KF;
for i:=1 to KF do
	begin
	system.new(CHV[i]);
	system.new(Fig[i]);
	end;
for i:=KF+1 to 500 do
	begin
	Chv[i]:=nil;
	Fig[i]:=nil;
	end;
end;

procedure GlSanColor(c:GlSanKoor; r:real);
begin
glcolor4f(c.x,c.y,c.z,r);
end;

function GlSanMouseReadKey:longint;
begin
GlSanMouseReadKey:=GlMouseReadKey;
end;

procedure GlSanOtr.SanWriteln;
begin
a.SanWrite;write(' ');b.SanWriteln;
end;

function GlSanStandardExit(q:longint):boolean;
begin
GlSanStandardExit:=false;
if ((SGKeyPressedVariable<>#0) and (LongInt(SGKeyPressedVariable)=q))or (SGContextActive=false) then GlSanStandardExit:=true;
end;

function GlSanReadKey:longint;
begin
GlSanReadKey:=LongInt(SGKeyPressedVariable);
end;

Function GlSanKeyPressed:boolean;
begin
GlSanKeyPressed:=(SGKeyPressedVariable<>#0);
end;

function GlSanTIO(a:GlSanOtr;b:GlSanKoor):boolean;
begin
GlSanTIO:=GlSanTochkaInOtr(a.a,a.b,b);
end;

function GlSanMTNP(q:GlSanKoor;NP:longint;R:real):GlSanKoor;
begin
case NP of
1:q.x+=r;
2:q.y+=r;
3:q.z+=r;
end;
GlSanMTNP:=q;
end;

function GlSanTochkaInOtr(a1,a2,b:GlSanKoor):boolean;
begin
GlSanTochkaInOtr:=false;
if abs(sqrt(sqr(a1.x-b.x)+sqr(a1.y-b.y)+sqr(a1.z-b.z))+sqrt(sqr(a2.x-b.x)+sqr(a2.y-b.y)+sqr(a2.z-b.z))-sqrt(sqr(a2.x-a1.x)+sqr(a2.y-a1.y)+sqr(a2.z-a1.z)))<0.001
	then GlSanTochkaInOtr:=true;
end;

PROCEDURE GlSanKoor.SanSetColor(q:real);
begin
glcolor4f(x,y,z,q);
end;

function GlSanOtr.SrednZn:GlSanKoor;
begin
SrednZn.x:=(a.x+b.x)/2;
SrednZn.y:=(a.y+b.y)/2;
SrednZn.z:=(a.z+b.z)/2;
end;

procedure GlSanLine(q:GlSanOtr);
begin
SanGlLine(q.a.x,q.a.y,q.a.z,q.b.x,q.b.y,q.b.z);
end;

procedure GlSanOtr.Import(v1,v2:GlSanKoor);
begin
a:=v1;
b:=v2;
end;

procedure GlSanMessage;
begin
SanGlMessage;
end;

procedure GlSanSwapBuffers;
begin
SGSwapBuffers;
end;

function GlSanRastMinT(a1,a2,b:GlSanKoor):GlSanKoor;
var c1,c2:real;
begin
c1:=sqrt(sqr(a1.x-b.x)+sqr(a1.y-b.y)+sqr(a1.z-b.z));
c2:=sqrt(sqr(a2.x-b.x)+sqr(a2.y-b.y)+sqr(a2.z-b.z));
if c1<c2 then GlSanRastMinT:=a1 else GlSanRastMinT:=a2;
end;

function GlSanGMP:GlSanKoor2f;
{$IFDEF MSWINDOWS}
	var p:Tpoint;
	{$ENDIF}
begin
{$IFDEF MSWINDOWS}
	GetCursorPos(p);
	GlSanGMP.x:=p.x;
	GlSanGMP.y:=p.y;
{$ELSE}
	GlSanGMP.Import(0,0);
	{$ENDIF}
end;

{procedure GlSanEnableFog;
var
	fogColor : array[0..3] of GLfloat = (0.5, 0.5, 0.5, 1.0);
begin
glEnable(GL_FOG); // включаем режим тумана
fogMode := GL_EXP; // переменная, хранящая режим тумана
glFogi(GL_FOG_MODE, fogMode); // задаем закон смешения тумана
glFogfv(GL_FOG_COLOR, fogColor); // цвет дымки
glFogf(GL_FOG_DENSITY, 0.35); // плотность тумана
glHint(GL_FOG_HINT, GL_DONT_CARE);// предпочтений к работе тумана нет
end;}

Function RandomABC(z:real):GlSanKoorPlosk;
var v:GlSanKoorPlosk;
begin
v.a:=random(2)+1;
v.b:=random(2)+1;
v.c:=random(2)+1;
v.d:=z;
if v.a=2 then v.a:=1;
if v.b=2 then v.b:=1;
if v.c=2 then v.c:=1;
RandomABC:=v;
end;

function GlSanMoveToch2(T1,T2,T:GlSanKoor;NP:longint;R:real):GlSanKoor;
var
	D1,D2,D3,P1:GlSanKoor;

function Prov:boolean;
var MIN,MAX:real;
begin
prov:=false;
case NP of
1:
	begin
	if T1.x<T2.x then
		begin
		MIN:=T1.x;
		MAX:=T2.x;
		D1.Import(T2.x-T1.x,T2.y-T1.y,T2.z-T1.z);
		D3.Import(T2.x-D1.x,T2.y-D1.y,T2.z-D1.z);
		end
	else
		begin
		MIN:=T2.x;
		MAX:=T1.x;
		D1.Import(T1.x-T2.x,T1.y-T2.y,T1.z-T2.z);
		D3.Import(T1.x-D1.x,T1.y-D1.y,T1.z-D1.z);
		end;
	if ((T.x+R<MAX) and (T.x+R>MIN)) then prov:=true;
	end;
2:
	begin
	if T1.y<T2.y then
		begin
		MIN:=T1.y;
		MAX:=T2.y;
		D1.Import(T2.x-T1.x,T2.y-T1.y,T2.z-T1.z);
		D3.Import(T2.x-D1.x,T2.y-D1.y,T2.z-D1.z);
		end
	else
		begin
		MIN:=T2.y;
		MAX:=T1.y;
		D1.Import(T1.x-T2.x,T1.y-T2.y,T1.z-T2.z);
		D3.Import(T1.x-D1.x,T1.y-D1.y,T1.z-D1.z);
		end;
	if ((T.y+R<MAX) and (T.y+R>MIN)) then prov:=true;
	end;
3:
	begin
	if T1.z<T2.z then
		begin
		MIN:=T1.z;
		MAX:=T2.z;
		D1.Import(T2.x-T1.x,T2.y-T1.y,T2.z-T1.z);
		D3.Import(T2.x-D1.x,T2.y-D1.y,T2.z-D1.z);
		end
	else
		begin
		MIN:=T2.z;
		MAX:=T1.z;
		D1.Import(T1.x-T2.x,T1.y-T2.y,T1.z-T2.z);
		D3.Import(T1.x-D1.x,T1.y-D1.y,T1.z-D1.z);
		end;
	if ((T.z+R<MAX) and (T.z+R>MIN)) then prov:=true;
	end;
end;
end;

BEGIN
D2:=T;
if prov then
	begin
	P1.Import(D1.x/100,D1.y/100,D1.z/100);
	case NP of
	1:
		begin
		D2.x+=R;
		end;
	2:
		begin
		D2.y+=R;
		end;
	3:
		begin
		D2.z+=R;
		end;
	end;
	end;
GlSanMoveToch2:=D2;
END;

procedure GlSanKoorPlosk.SanSetColor;
begin
glColor4f(a,b,c,d);
end;

procedure GlSanKoor.SanSetColor;
begin
glColor3f(x,y,z);
end;

procedure GlSanKoorPlosk.Import(a1,a2,a3,a4:real);
begin
a:=a1;
b:=a2;
c:=a3;
d:=a4;
end;

function Matrix4x4(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16:real):real;
begin
Matrix4x4:=
	+a1*Matrix3x3(a6,a7,a8,a10,a11,a12,a14,a15,a16)
	-a2*Matrix3x3(a5,a7,a8,a9,a11,a12,a13,a15,a16)
	+a3*Matrix3x3(a5,a6,a8,a9,a10,a12,a13,a14,a16)
	-a4*Matrix3x3(a5,a6,a7,a9,a10,a11,a13,a14,a15);
end;

procedure GlSanKoor.Import(a,b,c:real);
begin
x:=a;
y:=b;
z:=c;
end;

procedure GlSanKoor.SanWrite;
begin
write(x:0:7,' ',y:0:7,' ',z:0:7);
end;

procedure GlSanKoor.SanWriteln;
begin
writeln(x:0:10,' ',y:0:10,' ',z:0:10);
end;

function GlSanMoveToch(T:GlSanKoor;P:GlSanKoorLine;NP:longint;R:real):GlSanKoor;
var T1:GlSanKoor;
begin
case NP of
1:{a*x+b=c*y+d}{a*x-d+b=c*y}{(a*x-d+b)/c=y}
	begin
	T1:=GlSanKoorImport(T.x+r,0,0);
	if ((P.y1=0) and (P.y2=0)) then
		T1.y:=P.y3
	else
		T1.y:=(P.x1*T1.x-P.y2+P.x2)/P.y1;
	if ((P.z1=0) and (P.z2=0)) then
		T1.z:=P.z3
	else
		T1.z:=(P.x1*T1.x-P.z2+P.x2)/P.z1;
	end;
2:
	begin
	T1:=GlSanKoorImport(0,T.y+R,0);
	if (P.x1<>0)and(P.x2<>0) then T1.x:=(P.y1*T1.y-P.x2+P.y2)/P.x1 else T1.x:=P.x3;
	if (P.z1<>0)and(P.z2<>0) then  T1.z:=(P.x1*T1.x-P.z2+P.x2)/P.z1 else T.z:=P.z3;
	end;
3:
	begin
	if ((P.z1=0) and (P.z2=0)) then T1:=GlSanKoorImport(0,0,P.z3) else T1:=GlSanKoorImport(0,0,T.z+R);
	if (P.x1<>0)and(P.x2<>0) then T1.x:=(P.z1*T1.z-P.x2+P.z2)/P.x1 else T1.x:=P.x3;
	if (P.y1<>0)and(P.y2<>0) then  T1.y:=(P.x1*T1.x-P.y2+P.x2)/P.y1 else T.y:=P.y3;
	end;
end;
GlSanMoveToch:=T1;
end;

function GlSanTP3PP6T(a1,a2,a3,b1,b2,b3,c1,c2,c3:GlSanKoor):GlSanKoor;
begin
GlSanTP3PP6T:=GlSanTP3P(GlSanPloskKoor(a1,a2,a3),GlSanPloskKoor(b1,b2,b3),GlSanPloskKoor(c1,c2,c3));
end;

function GlSanKoorImport(a1,b1,c1:real):GlSanKoor;
begin
GlSanKoorImport.x:=a1;
GlSanKoorImport.y:=b1;
GlSanKoorImport.z:=c1;
end;

procedure GlSanKoorLine.SanWrite;
begin
writeln(x1:0:7,' ',x2:0:7,' ',y1:0:7,' ',y2:0:7,' ',z1:0:7,' ',z2:0:7);
Write(x3:0:7,' ',y3:0:7,' ',z3:0:7);
end;

procedure GlSanKoorLine.SanWriteln;
begin
writeln(x1:0:7,' ',x2:0:7,' ',y1:0:7,' ',y2:0:7,' ',z1:0:7,' ',z2:0:7);
Writeln(x3:0:7,' ',y3:0:7,' ',z3:0:7);
end;

function GlSanLineKoor(a,b:GlSanKoor):GlSanKoorLine;
begin
if a.x-b.x=0 then
	begin
	GlSanLineKoor.x2:=0;
	GlSanLineKoor.x1:=0;
	GlSanLineKoor.x3:=a.x;
	end
else
	begin
	GlSanLineKoor.x2:=-b.x/(a.x-b.x);
	GlSanLineKoor.x1:=1/(a.x-b.x);
	GlSanLineKoor.x3:=0;
	end;
if a.y-b.y=0 then
	begin
	GlSanLineKoor.y1:=0;
	GlSanLineKoor.y2:=0;
	GlSanLineKoor.y3:=a.y;
	end
else
	begin
	GlSanLineKoor.y1:=1/(a.y-b.y);
	GlSanLineKoor.y2:=-b.y/(a.y-b.y);
	GlSanLineKoor.y3:=0;
	end;
if a.z-b.z=0 then
	begin
	GlSanLineKoor.z1:=0;
	GlSanLineKoor.z2:=0;
	GlSanLineKoor.z3:=a.z;
	end
else
	begin
	GlSanLineKoor.z1:=1/(a.z-b.z);
	GlSanLineKoor.z2:=-b.z/(a.z-b.z);
	GlSanLineKoor.z3:=0;
	end;
end;

procedure GlSanVertex3f(a:GlSanKoor);
begin
glVertex3f(a.x,a.y,a.z);
end;

function GlSanPloskKoor(a1,a2,a3:GlSanKoor):GlSanKoorPlosk;
begin
GlSanPloskKoor:=GlSanPloskKoor(a1.x,a1.y,a1.z,a2.x,a2.y,a2.z,a3.x,a3.y,a3.z);
end;

function GlSanTP3P(p1,p2,p3:GlSanKoorPlosk):GlSanKoor;
var de,de1,de2,de3:real;
begin
p1.d:=-1*(p1.d);
p2.d:=-1*(p2.d);
p3.d:=-1*(p3.d);
de:=Matrix3x3(p1.a,p1.b,p1.c,p2.a,p2.b,p2.c,p3.a,p3.b,p3.c);
de1:=Matrix3x3(p1.d,p1.b,p1.c,p2.d,p2.b,p2.c,p3.d,p3.b,p3.c);
de2:=Matrix3x3(p1.a,p1.d,p1.c,p2.a,p2.d,p2.c,p3.a,p3.d,p3.c);
de3:=Matrix3x3(p1.a,p1.b,p1.d,p2.a,p2.b,p2.d,p3.a,p3.b,p3.d);
GlSanTP3P.x:=de1/de;
GlSanTP3P.y:=de2/de;
GlSanTP3P.z:=de3/de;
end;

procedure GlSanKoorPlosk.sanwriteln;
begin
writeln(a:0:10,'  ',b:0:10,'  ',c:0:10,'  ',d:0:10);
end;

procedure GlSanKoorPlosk.sanwrite;
begin
write(a:0:10,'  ',b:0:10,'  ',c:0:10,'  ',d:0:10);
end;

function GlSanPloskKoor(x1,y1,z1,x2,y2,z2,x0,y0,z0:real):GlSanKoorPlosk;
begin
GlSanPloskKoor.a:=Matrix2x2(y1-y0,z1-z0,y2-y0,z2-z0);
GlSanPloskKoor.b:=-Matrix2x2(x1-x0,z1-z0,x2-x0,z2-z0);
GlSanPloskKoor.c:=Matrix2x2(x1-x0,y1-y0,x2-x0,y2-y0);
GlSanPloskKoor.d:=
	-x0*Matrix2x2(y1-y0,z1-z0,y2-y0,z2-z0)
	+y0*Matrix2x2(x1-x0,z1-z0,x2-x0,z2-z0)
	-z0*Matrix2x2(x1-x0,y1-y0,x2-x0,y2-y0) ;
end;


function Matrix3x3(a1,a2,a3,a4,a5,a6,a7,a8,a9:real):real;
begin
Matrix3x3:=a1*Matrix2x2(a5,a6,a8,a9)-a2*Matrix2x2(a4,a6,a7,a9)+a3*Matrix2x2(a4,a5,a7,a8);
end;

function Matrix2x2(a1,a2,a3,a4:real):real;
begin
Matrix2x2:=a1*a4-a2*a3;
end;

procedure GlSanQuad(a,b,c,d:GlSanKoor);
begin
glBegin(GL_QUADS);
glVertex3f(a.x,a.y,a.z);
glVertex3f(b.x,b.y,b.z);
glVertex3f(c.x,c.y,c.z);
glVertex3f(d.x,d.y,d.z);
glEnd;
end;

procedure GlSanQuad(x1,y1,z1,x2,y2,z2,x3,y3,z3,x4,y4,z4:real);
var a,b,c,d:GlSanKoor;
begin
a.x:=x1;
a.y:=y1;
a.z:=z1;
b.x:=x2;
b.y:=y2;
b.z:=z2;
c.x:=x3;
c.y:=y3;
c.z:=z3;
d.x:=x4;
d.y:=y4;
d.z:=z4;
GlSanQuad(a,b,c,d);
end;

procedure GlSanLine(a,b:GlSanKoor);
begin
glBegin(GL_LINES);
glVertex3f(a.x,a.y,a.z);
glVertex3f(b.x,b.y,b.z);
glEnd;
end;

procedure GlSanLine(x1,y1,z1,x2,y2,z2:real);
var a,b:GlSanKoor;
begin
a.x:=x1;
a.y:=y1;
a.z:=z1;
b.x:=x2;
b.y:=y2;
b.z:=z2;
GlSanLine(a,b);
end;

{procedure SanBmpTexture(s:string);
var
	Bitmap: TBitmap;
	Bits: Array [0..63, 0..63, 0..2] of GLubyte; // массив образа, 64x64
	i, j: Integer;
begin
Bitmap := TBitmap.Create;
Bitmap.LoadFromFile(s); // загрузка текстуры из файла
//---заполнение битового массива---
For i := 0 to 63 do
	For j := 0 to 63 do
		begin
		bits [i, j, 0] := GetRValue(Bitmap.Canvas.Pixels [1,3]);
		bits [i , j, 1] := GetGValue(Bitmap.Canvas.Pixels[1,3]);
		bits [i, j, 2] := GetBValue(Bitmap.Canvas.Pixels[1,3]);
		end;
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL.NEAREST);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL.NEAREST);
glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,64, 64,
// здесь задается размер текстуры
О, GL_RGB, GL_UNSIGNED_BYTE, @Bits); // чтобы цвет объекта не влиял на текстуру
glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL);
glEnable (GL_TEXTURE_2D) ;
Bitmap.Free;
end;}


{
procedure SanGlCreateRazrGraph(a:pChar);
begin
if MessageBox(0,'Fullscreen Mode?', 'Question!',MB_YESNO OR MB_ICONQUESTION) = IDNO then
	fullscreen := false else fullscreen := true;
SanGlCreateRazrGraph(a,fullscreen);
end;
}
{procedure SanGlCreateRazrGraph(a:pChar; l:boolean);
var x,y:longint;
begin
initgraph;
x:=GetMaxX;
y:=GetMaxY;
closegraph;
if l=false then
	CreateOGLWindow(a,x,y,32,false)
else
	begin
	case x of
	1441..1600:x:=1600;
	1361..1440:x:=1440;
	1281..1360:x:=1360;
	1153..1280:x:=1280;
	1025..1152:x:=1152;
	801..1024:x:=1024;
	641..800:x:=800;
	321..640:x:=640;
	1..320:x:=320;
	end;
	case y of
	1..240:y:=240;
	241..480:y:=480;
	481..600:y:=600;
	601..720:y:=720;
	721..768:y:=768;
	769..800:y:=800;
	801..864:y:=864;
	865..900:y:=900;
	901..960:y:=960;
	961..1024:y:=1024;
	1025..1200:y:=1200;
	end;
	case x of
	1600:Y:=1200;
	1440:y:=900;
	1360:y:=768;
	1280:
		case y of
		1..768:y:=800;
		else y:=1024;
		end;
	1152:y:=864;
	1024:
		case y of
		1..600:y:=600;
		601..786:y:=768;
		end;
	800:y:=600;
	640:y:=480;
	320:y:=240;
	end;
	GlSanGraphX:=x;
	GlSanGraphY:=y;
	CreateOGLWindow(a,x,y,32,true);
	end;
end;}



procedure GlSanKoor2f.sanwrite;
begin
system.write(x:0:7,' ',y:0:7);
end;

procedure GlSanKoor2f.sanwriteln;
begin
system.writeln(x:0:7,' ',y:0:7);
end;

procedure GlSanSphere(k:GlSanKoor;s:real);
{var
	quadObj:pGLUquadric;}
begin
//glPushMatrix;
//glTranslatef(k.x,k.y,k.z);
//glRotatef( 90, 1, 0, 0);
//quadObj:=gluNewQuadric;
//gluSphere (quadObj, s, 20, 20);
Sphere.Init(k,s);
//glPopMatrix;
end;

procedure SanGlLine(x1,y1,z1,x2,y2,z2:real);
begin
glBegin(GL_LINES);
glVertex3f(x1,y1,z1);
glVertex3f(x2,y2,z2);
glEnd;
end;

function fail_est(st:string):boolean;
var f:text;
begin
assign(f,st);
{$I-}
reset(f);
case IOResult of
0:
        begin
        fail_est:=true;
        close(f);
        end
        else fail_est:=false;
        end;
{$I+}
end;

procedure SanGlMessage;
begin
end;
{
procedure SanCreateOGLWindow(pcApplicationName : pChar);
begin
if MessageBox(0,'Fullscreen Mode?', 'Question!',MB_YESNO OR MB_ICONQUESTION) = IDNO then
	fullscreen := false else fullscreen := true;
if fullscreen then
	CreateOGLWindow(pcApplicationName,1440, 900, 32, fullscreen)
else
	CreateOGLWindow(pcApplicationName, 1439, 848, 32, fullscreen);
end;}
{
procedure SanCreateOGLWindow2f(pcApplicationName : pChar; x,y:longint);
begin
CreateOGLWindow(pcApplicationName,x,y, 32,false);
end;
}

procedure GlSanLineConst(x1,y1,z1,x2,y2,z2,p:real);
var dop,vs,k1,k2:GlSanKoor;
begin
k1.x:=x1;
k1.y:=y1;
k1.z:=z1;
k2.x:=x2;
k2.y:=y2;
k2.z:=z2;
vs.x:=k1.x-k2.x;
vs.y:=k1.y-k2.y;
vs.z:=k1.z-k2.z;
dop.x:=k1.x-vs.x;
dop.y:=k1.y-vs.y;
dop.z:=k1.z-vs.z;
glBegin( GL_LINES);
glVertex3f(k2.x,k2.y,k2.z);
glVertex3f(dop.x+vs.x*p,dop.y+vs.y*p,dop.z+vs.z*p);
glEnd;
end;

procedure GlSanLineConst(x1,y1,z1,x2,y2,z2:real; n,k:longint);
var q1,q2:GlSanKoor;
begin
q1.x:=x1;
q1.y:=y1;
q1.z:=z1;
q2.x:=x2;
q2.y:=y2;
q2.z:=z2;
GlSanLineConst(q1,q2,n,k);
end;

procedure GlSanLineConst(k1,k2:GlSanKoor; n,k:longint);
var dop,vs:GlSanKoor; a:real;
begin
a:=n/k;
vs.x:=k1.x-k2.x;
vs.y:=k1.y-k2.y;
vs.z:=k1.z-k2.z;
dop.x:=k1.x-vs.x;
dop.y:=k1.y-vs.y;
dop.z:=k1.z-vs.z;
glBegin( GL_LINES);
glVertex3f(k2.x,k2.y,k2.z);
glVertex3f(dop.x+vs.x*a,dop.y+vs.y*a,dop.z+vs.z*a);
glEnd;
end;

procedure GlSanSphere(x1,y1,z1,s:real);
{var
	quadObj:pGLUquadric;}
begin
//glPushMatrix;
//glTranslatef(x1,y1,z1);
//glRotatef( 90, 1, 0, 0);
//quadObj:=gluNewQuadric;
//gluSphere (quadObj, s, 20, 20);
Sphere.Init(GlSanKoorImport(x1,y1,z1),s);
//glPopMatrix;
end;

procedure initgraph;
{$IFDEF MSWINDOWS}
	var a,b:smallint;
	{$ENDIF}
begin
{$IFDEF MSWINDOWS}
	a:=detect;
	graph.initgraph(a,b,'')
	{$ENDIF}
end;

// OGL initialisations //1
procedure OpenGL_Init();
var
	i:longint;
begin

  glClearColor( GlSanClearColor.a,GlSanClearColor.b , GlSanClearColor.c, GlSanClearColor.d );

  glViewport( 0, 0, width, height );
  glMatrixMode( GL_PROJECTION );
  glLoadIdentity();

  gluPerspective(60.0,width/height,0.1,10000.0);

  glMatrixMode( GL_MODELVIEW );
  glLoadIdentity();

  glClearDepth(1.0);                  // Depth Buffer Setup
  glEnable(GL_DEPTH_TEST);            // Enables Depth Testing
  glDepthFunc(GL_LEQUAL);             // The Type Of Depth Test To Do

  //glEnable(GL_CULL_FACE);          // Enable Hidden Surface Removal
  //glCullFace(GL_BACK);             // Set to Back
  //glFrontFace(GL_CCW);             // Draw all surfaces CCW

	glShadeModel(GL_SMOOTH);         // Set shading model
	glEnable(GL_TEXTURE_1D);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_TEXTURE);
	glEnable (GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA) ;
	glEnable (GL_LINE_SMOOTH);
	glEnable (GL_POLYGON_SMOOTH);
	//glEnable (GL_LINE_SMOOTH_HINT);
	//glEnable(GL_RED_BITS);
	
	 glShadeModel(GL_smooth);         // Set shading model

  glEnable(GL_LIGHTING);                            // Enable Lighting
  glLightfv(GL_LIGHT0,GL_AMBIENT, @AmbientLight);   // Enable Ambient Light
  glLightfv(GL_LIGHT0,GL_DIFFUSE, @DiffuseLight);   // Enable Diffuse Light
  glLightfv(GL_LIGHT0,GL_SPECULAR, @SpecularLight); // Enable Specular Light
  glEnable(GL_LIGHT0);                              // Enable Light0

  glLightfv(GL_LIGHT0,GL_POSITION,@LightPosition);   // Set our Light Position

  glEnable(GL_COLOR_MATERIAL);                       // Enable material colors
  glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE); // Set to front for Ambient and Diffuse Light
  glMaterialfv(GL_FRONT, GL_SPECULAR, @SpecularReflection); // Set reflection
  glMateriali(GL_FRONT,GL_SHININESS,100);

GlSanMouseClickConst:=11;
glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
GlSanConstWindows;
Sphere2Obj3(Sphere);
CubObj3(Kub);

end;

procedure XO(pp2:boolean);
var T:array[1..4] of GlSanKoor2f;
	c:array[1..6] of GlSanColor4f;
	k,ch,ono,prot,prich_viig,v:longint;
	pole:array_XO;
	Tochka:GlSanKoor2f;
	Kv,Kv1:GlSanObject;
	r1,r2,z:real;
	r3:array[1..9,1..6] of real;
	Bool:boolean = false;
	i,j:longint;
	leftzum,upzum:real;

function hod_protivnika(pole:array_XO):ShortInt;
label 5;
var     j,uv,hod_protivnikaa:longint;
begin
if ono>prot then
        begin
        j:=1;
        uv:=1;
        end
else
        begin
        j:=2;
        uv:=-1;
        end;
while j in [1,2] do
begin
if ((pole[1]=j) and (pole[2]=j) and (pole[3]=3)) then
        begin
        hod_protivnikaa:=3;
        goto 5;
        end;
if ((pole[2]=j) and (pole[3]=j) and (pole[1]=3)) then
        begin
        hod_protivnikaa:=1;
        goto 5;
        end;
if ((pole[1]=j) and (pole[3]=j) and (pole[2]=3)) then
        begin
        hod_protivnikaa:=2;
        goto 5;
        end;
if ((pole[4]=j) and (pole[5]=j) and (pole[6]=3)) then
        begin
        hod_protivnikaa:=6;
        goto 5;
        end;
if ((pole[6]=j) and (pole[5]=j) and (pole[4]=3)) then
        begin
        hod_protivnikaa:=4;
        goto 5;
        end;
if ((pole[6]=j) and (pole[4]=j) and (pole[5]=3)) then
        begin
        hod_protivnikaa:=5;
        goto 5;
        end;
if ((pole[7]=j) and (pole[8]=j) and (pole[9]=3)) then
        begin
        hod_protivnikaa:=9;
        goto 5;
        end;
if ((pole[9]=j) and (pole[7]=j) and (pole[8]=3)) then
        begin
        hod_protivnikaa:=8;
        goto 5;
        end;
if ((pole[9]=j) and (pole[8]=j) and (pole[7]=3)) then
        begin
        hod_protivnikaa:=7;
        goto 5;
        end;
if ((pole[1]=j) and (pole[4]=j) and (pole[7]=3)) then
        begin
        hod_protivnikaa:=7;
        goto 5;
        end;
if ((pole[1]=j) and (pole[7]=j) and (pole[4]=3)) then
        begin
        hod_protivnikaa:=4;
        goto 5;
        end;
if ((pole[7]=j) and (pole[4]=j) and (pole[1]=3)) then
        begin
        hod_protivnikaa:=1;
        goto 5;
        end;
if ((pole[2]=j) and (pole[5]=j) and (pole[8]=3)) then
        begin
        hod_protivnikaa:=8;
        goto 5;
        end;
if ((pole[8]=j) and (pole[5]=j) and (pole[2]=3)) then
        begin
        hod_protivnikaa:=2;
        goto 5;
        end;
if ((pole[2]=j) and (pole[8]=j) and (pole[5]=3)) then
        begin
        hod_protivnikaa:=5;
        goto 5;
        end;
if ((pole[3]=j) and (pole[6]=j) and (pole[9]=3)) then
        begin
        hod_protivnikaa:=9;
        goto 5;
        end;
if ((pole[9]=j) and (pole[6]=j) and (pole[3]=3)) then
        begin
        hod_protivnikaa:=3;
        goto 5;
        end;
if ((pole[3]=j) and (pole[9]=j) and (pole[6]=3)) then
        begin
        hod_protivnikaa:=6;
        goto 5;
        end;
if ((pole[1]=j) and (pole[5]=j) and (pole[9]=3)) then
        begin
        hod_protivnikaa:=9;
        goto 5;
        end;
if ((pole[9]=j) and (pole[5]=j) and (pole[1]=3)) then
        begin
        hod_protivnikaa:=1;
        goto 5;
        end;
if ((pole[1]=j) and (pole[9]=j) and (pole[5]=3)) then
        begin
        hod_protivnikaa:=5;
        goto 5;
        end;
if ((pole[3]=j) and (pole[5]=j) and (pole[7]=3)) then
        begin
        hod_protivnikaa:=7;
        goto 5;
        end;
if ((pole[7]=j) and (pole[5]=j) and (pole[3]=3)) then
        begin
        hod_protivnikaa:=3;
        goto 5;
        end;
if ((pole[7]=j) and (pole[3]=j) and (pole[5]=3)) then
        begin
        hod_protivnikaa:=5;
        goto 5;
        end;
inc(j,uv);
end;
if pole[5]=3 then
        begin
        hod_protivnikaa:=5;
        goto 5;
        end;
hod_protivnika:=random(10)+1;
while  ((pole[hod_protivnikaa]<>3)) do
	hod_protivnikaa:=random(10)+1;
5:
hod_protivnika:=hod_protivnikaa;
end;

function  viig(pole:array_XO):longint;
var i,t,viiig:longint;
begin
prich_viig:=0;
viiig:=0;
if ((pole[1]=pole[2]) and (pole[2]=pole[3]) and (pole[3]<>3))
        then
        begin
        prich_viig:=1;
        viiig:=1;
        end;
if ((pole[1]=pole[4]) and (pole[4]=pole[7]) and (pole[7]<>3))
        then
        begin
        prich_viig:=4;
        viiig:=1;
        end;
if ((pole[4]=pole[5]) and (pole[5]=pole[6]) and (pole[6]<>3))
        then
        begin
        prich_viig:=2;
        viiig:=1;
        end;
if ((pole[7]=pole[8]) and (pole[8]=pole[9]) and (pole[9]<>3))
        then
        begin
        prich_viig:=3;
        viiig:=1;
        end;
if ((pole[2]=pole[5]) and (pole[5]=pole[8]) and (pole[8]<>3))
        then
        begin
        prich_viig:=5;
        viiig:=1;
        end;
if ((pole[3]=pole[6]) and (pole[6]=pole[9]) and (pole[9]<>3))
        then
        begin
        prich_viig:=6;
        viiig:=1;
        end;
if ((pole[1]=pole[5]) and (pole[5]=pole[9]) and (pole[9]<>3))
        then
        begin
        prich_viig:=7;
        viiig:=1;
        end;
if ((pole[3]=pole[5]) and (pole[7]=pole[3]) and (pole[3]<>3))
        then
        begin
        prich_viig:=8;
        viiig:=1;
        end;
if viiig=0 then
   begin
   t:=0;
   for i:=1 to 9 do if pole[i]=3 then inc(t);
   if t=0 then viiig:=2;
   end;
viig:=viiig;
end;

procedure pok_viig;
begin
C[4].SanSetColor;
if prich_viig in [1,4,7]   then GlSanSphere(GlSanKoorImport(4/9-2,-4/9+2,0),0.7);
if prich_viig in [1,5]     then GlSanSphere(GlSanKoorImport(0,-4/9+2,0),0.7);
if prich_viig in [1,6,8]   then GlSanSphere(GlSanKoorImport(-4/9+2,-4/9+2,0),0.7);
if prich_viig in [2,4]     then GlSanSphere(GlSanKoorImport(4/9-2,0,0),0.7);
if prich_viig in [2,5,7,8] then GlSanSphere(GlSanKoorImport(0,0,0),0.7);
if prich_viig in [2,6]     then GlSanSphere(GlSanKoorImport(-4/9+2,0,0),0.7);
if prich_viig in [3,4,8]   then GlSanSphere(GlSanKoorImport(4/9-2,4/9-2,0),0.7);
if prich_viig in [3,5]     then GlSanSphere(GlSanKoorImport(0,4/9-2,0),0.7);
if prich_viig in [3,6,7]   then GlSanSphere(GlSanKoorImport(-4/9+2,4/9-2,0),0.7);
end;
procedure rr3;
var t,i:longint;
begin
for t:=1 to 3 do
for i:=1 to 9 do r3[i,t]:=random(360);
for t:=4 to 6 do
for i:=1 to 9 do
	begin
	if random(2)=0 then
	r3[i,t]:=(random(10)/3)
	else
	r3[i,t]:=-(random(10)/3)
	end;
end;
begin
SanShowCursor:=true;
r1:=0;
r2:=0;
rr3;
v:=0;
prich_viig:=0;
randomize;
case random(2) of
0:begin
  ono:=1;
  prot:=2;
  end;
1:begin
  ono:=2;
  prot:=1;
  end;
end;
for i:=1 to 9 do
	pole[i]:=3;
k:=5;
Fillchar(t,Sizeof(t),0);
Fillchar(c,Sizeof(c),0);
T[1].Import(2,-2);
T[2].Import(2,2);
T[3].Import(-2,2);
T[4].Import(-2,-2);
C[4].Import(1,1,0,0.1);
C[1].Import(1,1,0,0.7);
C[2].Import(0,1,0,0.1);
C[3].Import(0,1,1,0.1);
C[5].Import(0,1,0,0.1);
C[6].Import(1,0,0,0.1);
CH:=random(2)+1;
z:=1;
Kv:=GlSanObject_Quadros(c[2]);
Kv1:=GlSanObject_Quadros(c[6]);
leftzum:=0;
upzum:=0;
repeat
	if C[1].d>0 then C[1].d-=0.002;
	for j:=1 to 3 do
		for i:=1 to 9 do
			r3[i,j]+=r3[i,j+3];
	glClear(GL_COLOR_BUFFER_BIT OR GL_DEPTH_BUFFER_BIT);
	glLoadIdentity();
	glPolygonMode (GL_FRONT_AND_BACK, GL_LINE);
	glTranslatef(LeftZum,Upzum,-6.0*z);
	glRotatef( r1,0,1,0);
	glRotatef( r2,1,0,0);
	C[1].SanSetColor;
	if C[1].d>0 then
	begin
	GlSanQuad(T[1].GSK3,T[2].GSK3,T[3].GSK3,T[4].GSK3);
	GlSanLine(2,3/4,0,-2,3/4,0);
	GlSanLine(2,-3/4,0,-2,-3/4,0);
	GlSanLine(3/4,2,0,3/4,-2,0);
	GlSanLine(-3/4,2,0,-3/4,-2,0);
	end;
	glPolygonMode (GL_FRONT_AND_BACK, GL_fill);
	for i:=1 to 9 do
		if pole[i]<>3 then
			begin
			case i of
			7:Tochka.Import(4/9-2,4/9-2);
			3:Tochka.Import(-4/9+2,-4/9+2);
			1:Tochka.Import(4/9-2,-4/9+2);
			9:Tochka.Import(-4/9+2,4/9-2);
			5:Tochka.Import(0,0);
			6:Tochka.Import(-4/9+2,0);
			4:Tochka.Import(4/9-2,0);
			2:Tochka.Import(0,-4/9+2);
			8:Tochka.Import(0,4/9-2);
			end;
			if (pole[i]=ono) then
				C[5].SanSetColor
			else
				C[6].SanSetColor;
			if pole[i]=1 then GlSanSphere(Tochka.GSK3,0.4)
				else
				if pole[i]=ono then
					InitRot(Kv,r3[i,1],r3[i,2],r3[i,3],Tochka.GSK3,0.4)
					else InitRot(Kv1,r3[i,1],r3[i,2],r3[i,3],Tochka.GSK3,0.4)
			end;
	if ((prich_viig<>0) or (v=1)) then
		pok_viig;
	if v=0 then
	begin
	case k of
	7:Tochka.Import(4/9-2,4/9-2);
	3:Tochka.Import(-4/9+2,-4/9+2);
	1:Tochka.Import(4/9-2,-4/9+2);
	9:Tochka.Import(-4/9+2,4/9-2);
	5:Tochka.Import(0,0);
	6:Tochka.Import(-4/9+2,0);
	4:Tochka.Import(4/9-2,0);
	2:Tochka.Import(0,-4/9+2);
	8:Tochka.Import(0,4/9-2);
	end;
	C[3].SanSetColor;
	GlSanSphere(Tochka.GSK3,0.8);
	end;
	if (SGKeyPressedVariable<>#0) then
		case GlSanReadKey of
		68:r1-=2.7;
		65:r1+=2.7;
		87:r2+=2.7;
		83:r2-=2.7;
		189:z+=0.1;
		187:z-=0.1;
		116:
			begin
			for i:=1 to 9 do pole[i]:=3;
			prich_viig:=0;
			v:=0;
			rr3;
			C[1].d:=0.3;
			case random(2) of
			0:	begin
				ono:=1;
				prot:=2;
				end;
			1:begin
				ono:=2;
				prot:=1;
				end;
			end;
			end;
		37..40:if v=0 then
		begin
		case GlSanReadKey of
		37:if not (k in [1,4,7]) then dec(k,1);
		38:if not (k in [1,2,3]) then dec(k,3);
		39:if not (k in [3,6,9]) then inc(k,1);
		40:if not (k in [7,8,9]) then inc(k,3);
		end;
		C[1].d:=0.3;
		end;
		13:
			begin
				if pole[k]=3 then
					if v=0 then
					begin
					pole[k]:=ono;
					Ch:=prot;
					v:=viig(pole);
					end;
			end;
		end;
case LongInt(SGMouseWheelVariable) of
1:begin z+=0.1; C[1].d:=0.3; end;
-1:begin z-=0.1; C[1].d:=0.3; end;
end;
	if v=0 then
	IF Ch=prot then
		begin
		pole[hod_protivnika(pole)]:=prot;
		Ch:=ono;
		v:=viig(pole);
		end;
if GlSanMouseB(3) then
	begin
	C[1].d:=0.3;
	R1-=GlSanMouseXY(1).x/3;
	R2-=GlSanMouseXY(1).y/3;
	end;
if GlSanMouseB(1) then
	begin
	C[1].d:=0.3;
	UpZum+=GlSanMouseXY(1).y/(170);
	LeftZum-=GlSanMouseXY(1).x/(170);
	end;
if GlSanMouseReadKey=2 then
	begin
	r1:=0;
	r2:=0;
	z:=1;
	LeftZum:=0;
	UpZum:=0;
	end;
if SGMouseKeysDown[0] then
	if pole[k]=3 then
					if v=0 then
					begin
					pole[k]:=ono;
					Ch:=prot;
					v:=viig(pole);
					end;
{if ((GlSanMouseB(1)=false) and (GlSanMouseB(2)=false) and (GlSanMouseB(3)=false) and (v=0))  then
		begin
		if GlSanMouseXY(1).y<>0 then
		if (GlSanMouseXY(1).y>(100)) then
			begin
			if (not (k in [1,2,3])) then inc(k,3);
			end
		else
			begin
			if (GlSanMouseXY(1).y<100) then
				begin
				if (not (k in [7,8,9])) then dec(k,3);
				end;
			end;
		if GlSanMouseXY(1).x<>0 then
		if (GlSanMouseXY(1).x>100) then
			begin
			if (not (k in [3,6,9])) then dec(k,1) ;
			end
		else
			begin
			if (GlSanMouseXY(1).x<100) then
				begin
				if (not (k in [1,4,7])) then inc(k,1);
				end;
			end;
		end;
writeln(k);
writeln(GlSanMouseXY(1).y,' ',GlSanMouseXY(1).x);
}
if GlSanReadKey=27 then
	begin
	Bool:=true;
	byte(SGKeyPressedVariable):=0;
	end;
until GlSanAfterUntil(0,bool,pp2);
end;

procedure GlSanSechPuram4(a:boolean);
const h=80;
var
	i,nap,KursorSI,YvI:longint;
	Toc1,Toc2,Toc3,Mn1,Mn2,Mn3,Mn4,Mn5,Dt1,Dt2,Dt3,Dt4:GlSanKoor;
	Pl1,Pl2:GlSanKoorLine;
	SIRS,RTN,ProzrS,rot:real;
	SechIzm:boolean;
	ColorMn,ColorSech,ColorDL,ColorT:GlSanColor3f;
	ColorPS,ColorTSech:GlSanColor4f;
	fullscreen:boolean;
	upzum,leftzum,zym,rotation:real;


procedure OpenGL_Draw();
begin
GlSanClear;
glPolygonMode (GL_FRONT_AND_BACK, GL_LINE);
glLineWidth (GlSanLineWidth);
glTranslatef(0.0*zym+LeftZum,-0.36*zym+UpZum,-6.0*zym);
glRotatef( rot,1,0,0);
glRotatef( rotation, 0.0, 1.0, 0.0);
ColorMn.SanSetColor;
if i>2*h then
	begin
	glBegin( GL_TRIANGLES );
	GlSanVertex3f( Mn1);
	glSanVertex3f(Mn2);
	glSanVertex3f( Mn3);

	glsanVertex3f( Mn1);
	glSanVertex3f( Mn3);
	glSanVertex3f( Mn4);

	glsanVertex3f( Mn1);
	glSanVertex3f( Mn4);
	glSanVertex3f(Mn5);

	glsanVertex3f( Mn1);
	glSanVertex3f(Mn5);
	glSanVertex3f(Mn2);
	glEnd();
	end
else
	begin
	if i<h then
		begin
		GlSanLineConst(Mn2,Mn1,i,h);
		GlSanLineConst(Mn3,Mn1,i,h);
		GlSanLineConst(Mn4,Mn1,i,h);
		GlSanLineConst(Mn5,Mn1,i,h);
		end
	else
		begin
		glBegin(GL_LINES);
		glsanVertex3f( Mn1);
		glSanVertex3f(Mn2);
		glSanVertex3f( Mn1);
		glSanVertex3f( Mn3);
		glSanVertex3f( Mn1);
		glSanVertex3f( Mn4);
		glSanVertex3f( Mn1);
		glSanVertex3f(Mn5);
		glEnd;
		end;
	if i>h then
		begin
		GlSanLineConst(Mn2,Mn3,(i-h),h);
		GlSanLineConst(Mn3,Mn4,(i-h),h);
		GlSanLineConst(Mn4,Mn5,(i-h),h);
		GlSanLineConst(Mn5,Mn2,(i-h),h);
		end;
	end;
{УСТАНАВЛИВАЮТСЯ 3 ТОЧКИ}
if i>2*h then
	begin
	glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
	ColorT.SanSetColor;
	if ((i>2*h) and (i<3*h) and ((0.5-(i-2*h)/h)/2>ZumT)) then GlSanSphere ( Toc1,(0.5-(i-2*h)/h)/2) else GlSanSphere ( Toc1 ,ZumT);
	end;
if i>3*h then if ((i<4*h) and ((0.5-(i-3*h)/h)/2>ZumT)) then GlSanSphere( Toc2,  (0.5-(i-h*3)/h)/2) else GlSanSphere( Toc2,ZumT);
if i>4*h then if ((i<5*h) and ((0.5-(i-4*h)/h)/2>ZumT)) then GlSanSphere ( Toc3,  (0.5-(i-h*4)/h)/2 ) else GlSanSphere ( Toc3,ZumT);
{СТРОИТСЯ ПЕРВАЯ ЛИНИЯ}
if i>5*h then
	begin
	ColorSech.SanSetColor;
	if i>6*h then
		begin
		glBegin( GL_lines );
		glsanVertex3f( Toc1);
		GlSanVertex3f(Toc3);
		glEnd;
		end
	else
		GlSanLineConst(Toc1,Toc3,i-5*h,h);
	end;
{ПЕРВЫЕ ДОПОЛНИТЕЛЬНЫЕ ЛИНИИ}
if i>7*h then
	begin
	ColorDL.SanSetColor;
	if i<8*h then
		begin
		GlSanLineConst(Dt1,GlSanRastMinT(Toc3,Toc1,Dt1),(i-7*h),h);
		GlSanLineConst(Dt1,GlSanRastMinT(Mn1,Mn4,Dt1),(i-7*h),h);
		end
	else
		begin
		GlSanLine(Dt1,GlSanRastMinT(Toc3,Toc1,Dt1));
		GlSanLine(Dt1,GlSanRastMinT(Mn1,Mn4,Dt1));
		end;
	end;
{СТРОИТСЯ ДОПОЛНИТЕЛЬНАЯ ТОЧКА НОМЕР ОДИН}
if i>8*h then
	begin
	ColorT.SanSetColor;
	if ((i<9*h) and ((0.5-(i-8*h)/h)/2>ZumT)) then GlSanSphere ( Dt1,  (0.5-(i-h*8)/h)/2 ) else GlSanSphere ( Dt1,ZumT);
	end;
{ЕЩЁ ДОП. ЛИНИЯ}
if i>9*h then
	begin
	ColorDL.SanSetColor;
	if i<10*h then
		GlSanLineConst(Toc2,Dt1,(i-9*h),h)
	else
			begin
			GlSanLine(GlSanRastMinT(Dt2,Toc2,Dt1),Dt1);
			glColor3f(0,1,0);
			GlSanLine(Dt2,Toc2);
			end;
	end;
if i>10*h then
	begin
	ColorT.SanSetColor;
	if ((i<11*h) and ((0.5-(i-10*h)/h)/2>ZumT)) then GlSanSphere ( Dt2,  (0.5-(i-h*10)/h)/2 ) else GlSanSphere ( Dt2,ZumT);
	end;
if i>11*h then
	begin
	ColorSech.SanSetColor;
	if i<12*h then
		GlSanLineConst(Toc3,Dt2,(i-11*h),h)
	else
		GlSanLine(Dt2,Toc3);
	end;
if i>12*h then
	begin
	ColorDL.SanSetColor;
	if i<13*h then
		begin
		GlSanLineConst(Dt3,Dt2,(i-12*h),h);
		GlSanLineConst(Dt3,Mn5,(i-12*h),h);
		end
	else
		begin
		GlSanLine(Dt2,Dt3);
		GlSanLine(Mn5,Dt3);
		end;
	end;
if i>13*h then
	begin
	ColorT.SanSetColor;
	if ((i<14*h) and ((0.5-(i-13*h)/h)/2>ZumT)) then GlSanSphere ( Dt3,  (0.5-(i-h*13)/h)/2 ) else GlSanSphere ( Dt3,ZumT);
	end;
if i>14*h then
	begin
	ColorDL.SanSetColor;
	if i<15*h then
		GlSanLineConst(Dt4,Dt3,(i-14*h),h)
	else
		begin
		GlSanLine(Toc2,Dt3);
		ColorSech.SanSetColor;
		GlSanLine(Dt4,Toc2);
		end;
	end;
if i>h*15 then
	begin
	ColorT.SanSetColor;
	if ((i<16*h) and ((0.5-(i-15*h)/h)/2>ZumT)) then GlSanSphere ( Dt4,  (0.5-(i-h*15)/h)/2 ) else GlSanSphere ( Dt4,ZumT);
	end;
if i>16*h then
	begin
	ColorSech.SanSetColor;
	if i<17*h then
		GlSanLineConst(Toc1,Dt4,(i-16*h),h)
	else
		GlSanLine(Dt4,Toc1);
	end;
{=============================================================================================================}
if SechIzm then
	begin
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA) ;
	glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
	ColorTSech.SanSetColor;
	case KursorSI of
	1:GlSanSphere(Toc1,SIRS);
	2:GlSanSphere(Toc2,SIRS);
	3:GlSanSphere(Toc3,SIRS);
	end;
	end;
{------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------}
if i>17*h then
	begin
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA) ;
	glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
	if ((i<18*h) or ((i-h*17)/(4*h)<ProzrS)) then ColorPS.Import(1/2,1/2,1,(i-h*17)/(4*h)) else ColorPS.Import(1/2,1/2,1,ProzrS);
	ColorPS.SanSetColor;
	glBegin( GL_TRIANGLES );
	glSanVertex3f(Dt2);
	GlSanVertex3f(Toc2);
	GlSanVertex3f(Toc3);

	GlSanVertex3f(Dt4);
	GlSanVertex3f(Toc1);
	GlSanVertex3f(Toc2);

	GlSanVertex3f(Toc1);
	GlSanVertex3f(Toc2);
	GlSanVertex3f(Toc3);
	glEnd;
	end;
if i>2*h then
begin
glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
GlSanColor(ColorMn,0.03);
glBegin( GL_TRIANGLES );
	GlSanVertex3f( Mn1);
	glSanVertex3f(Mn2);
	glSanVertex3f( Mn3);

	glsanVertex3f( Mn1);
	glSanVertex3f( Mn3);
	glSanVertex3f( Mn4);

	glsanVertex3f( Mn1);
	glSanVertex3f( Mn4);
	glSanVertex3f(Mn5);

	glsanVertex3f( Mn1);
	glSanVertex3f(Mn5);
	glSanVertex3f(Mn2);
	glEnd();
	GlSanQuad(Mn2,Mn3,Mn4,Mn5);
end;
end;


begin
glLineWidth (1.5);
randomize;
GlSanClearColor.Import(0,0,0,0);
SanShowCursor:=true;
GlSanLineWidth:=1.2;
glLineWidth (GlSanLineWidth);
rotation := random(358)+1;
nap:=random(2);
if nap=0 then nap:=-1;
i:=0;
Zym:=0.8;
SIRS:=0.19;
ZumT:=0.012;
KursorSI:=0;
RTN:=0.8;
ProzrS:=0.65;
YvI:=1;
Rot:=0;
{++++}
ColorMn.Import(1,0,0);
ColorSech.Import(0,1,0);
ColorT.Import(1,1,1);
ColorDL.Import(1,1,0);
ColorPS.Import(0.5,0.5,1,ProzrS);
ColorTSech.Import(0,0,1,0.3);
{--------}
Toc1.Import(2/3,0,2/3);
Toc2.Import(-3/4,3/4-1,-3/4);
Toc3.Import(1,-1,-0.47);
Mn1.Import(0,2,0);
Mn2.Import(-1,-1,1);
Mn3.Import(1,-1,1);
Mn4.Import(1,-1,-1);
Mn5.Import(-1,-1,-1);
{=========}
fullscreen:=true;
SechIzm:=false;
UpZum:=0;
LeftZum:=0;
Dt1:=GlSanTP3P(GlSanPloskKoor(Toc1,Toc2,Toc3),GlSanPloskKoor(Mn1,Mn3,Mn4),GlSanPloskKoor(Mn1,Mn4,Mn5));
Dt2:=GlSanTP3P(GlSanPloskKoor(Toc1,Toc2,Toc3),GlSanPloskKoor(Mn2,Mn3,Mn4),GlSanPloskKoor(Mn1,Mn4,Mn5));
Dt3:=GlSanTP3P(GlSanPloskKoor(Toc1,Toc2,Toc3),GlSanPloskKoor(Mn2,Mn3,Mn4),GlSanPloskKoor(Mn1,Mn2,Mn5));
Dt4:=GlSanTP3P(GlSanPloskKoor(Toc1,Toc2,Toc3),GlSanPloskKoor(Mn2,Mn3,Mn1),GlSanPloskKoor(Mn1,Mn2,Mn5));
Pl1:=GlSanLineKoor(Mn1,Mn3);
Pl2:=GlSanLineKoor(Mn1,Mn5);
glEnable (GL_BLEND);
{=====}REPEAT
if GlSanKeyPressed then
	case LongInt(SGKeyPressedVariable) of
	118,119:
		begin
		case GlSanReadKey of
		118:GlSanLineWidth-=0.3;
		119:GlSanLineWidth+=0.3;
		end;
		glLineWidth (GlSanLineWidth);
		ZumT:=0.012*GlSanLineWidth;
		end;
	116:RTN-=0.035;
	117:RTN+=0.035;
	123:inc(YvI);
	122:dec(YvI);
	32{Space}:
		if fullscreen=true then
			fullscreen:=false
		else
			fullscreen:=true;
	37,39,40,38:
		if not SechIzm then
			case LongInt(SGKeyPressedVariable) of
			37:LeftZum:=LeftZum-0.03;
			39:LeftZum+=0.03;
			40:UpZum:=UpZum-0.03;
			38:UpZum+=0.03;
			end
		else
			begin
			case KursorSI of
			1,2:
				case GlSanReadKey of
				37:LeftZum:=LeftZum-0.03;
				39:LeftZum+=0.03;
				else
					begin
					case KursorSI of
					1:
						begin
						case GlSanReadKey of
						38:if Mn1.y>Toc1.y+0.01 then Toc1:=GlSanMoveToch(Toc1,Pl1,2,0.01);
						40:if Mn2.y<Toc1.y-0.01 then Toc1:=GlSanMoveToch(Toc1,Pl1,2,-0.01);
						end;
						end;
					2:
						begin
						case LongInt(SGKeyPressedVariable) of
						38:if Mn1.y>Toc2.y+0.01 then Toc2:=GlSanMoveToch(Toc2,Pl2,2,0.01);
						40:if Mn2.y<Toc2.y-0.01 then Toc2:=GlSanMoveToch(Toc2,Pl2,2,-0.01);
						end;
						end;
					end;
					Dt1:=GlSanTP3P(GlSanPloskKoor(Toc1,Toc2,Toc3),GlSanPloskKoor(Mn1,Mn3,Mn4),GlSanPloskKoor(Mn1,Mn4,Mn5));
					Dt2:=GlSanTP3P(GlSanPloskKoor(Toc1,Toc2,Toc3),GlSanPloskKoor(Mn2,Mn3,Mn4),GlSanPloskKoor(Mn1,Mn4,Mn5));
					Dt3:=GlSanTP3P(GlSanPloskKoor(Toc1,Toc2,Toc3),GlSanPloskKoor(Mn2,Mn3,Mn4),GlSanPloskKoor(Mn1,Mn2,Mn5));
					Dt4:=GlSanTP3P(GlSanPloskKoor(Toc1,Toc2,Toc3),GlSanPloskKoor(Mn2,Mn3,Mn1),GlSanPloskKoor(Mn1,Mn2,Mn5));
					end;
				end;
			3:
				case GlSanReadKey of
				40:UpZum:=UpZum-0.03;
				38:UpZum+=0.03;
				else
					begin
					case GlSanReadKey of
					37:Toc3:=GlSanMoveToch2(Mn3,Mn4,Toc3,3,0.01);
					39:Toc3:=GlSanMoveToch2(Mn3,Mn4,Toc3,3,-0.01);
					end;
					Dt1:=GlSanTP3P(GlSanPloskKoor(Toc1,Toc2,Toc3),GlSanPloskKoor(Mn1,Mn3,Mn4),GlSanPloskKoor(Mn1,Mn4,Mn5));
					Dt2:=GlSanTP3P(GlSanPloskKoor(Toc1,Toc2,Toc3),GlSanPloskKoor(Mn2,Mn3,Mn4),GlSanPloskKoor(Mn1,Mn4,Mn5));
					Dt3:=GlSanTP3P(GlSanPloskKoor(Toc1,Toc2,Toc3),GlSanPloskKoor(Mn2,Mn3,Mn4),GlSanPloskKoor(Mn1,Mn2,Mn5));
					Dt4:=GlSanTP3P(GlSanPloskKoor(Toc1,Toc2,Toc3),GlSanPloskKoor(Mn2,Mn3,Mn1),GlSanPloskKoor(Mn1,Mn2,Mn5));
					end;
				end;
			end;
			end;
	109,189{+,=,Num+}:Zym+=0.03;
	107,187{-,_,Num-}:Zym-=0.03;
	12:{Num5}
		begin
		Zym:=0.8;
		LeftZum:=0;
		UpZum:=0;
		YvI:=1;
		RTN:=0.8;
		Rot:=0;
		YvI:=1;
		GlSanLineWidth:=1.2;
		ZumT:=0.012;
		glLineWidth (GlSanLineWidth);
		end;
	8{BackSpace}:i:=0;
	13:i:=18*h;
	9:
		begin
		case KursorSI of
		0..2:
			begin
			SechIzm:=true;
			inc(KursorSI);
			end;
		3:
			begin
			KursorSI:=0;
			SechIzm:=false;
			end;
		end;
		end;
	end;
if GlSanMouseB(3) then
	begin
	Rotation-=GlSanMouseXY(1).x/3;
	Rot-=GlSanMouseXY(1).y/3;
	end;
if GlSanMouseB(1) then
	begin
	UpZum+=GlSanMouseXY(1).y/(170/Zym);
	LeftZum-=GlSanMouseXY(1).x/(170/Zym);
	end;
case LongInt(SGMouseWheelVariable) of
1:Zym+=0.05;
-1:Zym-=0.05;
end;
if GlSanMouseReadKey=2 then
	begin
	Zym:=0.8;
	LeftZum:=0;
	UpZum:=0;
	YvI:=1;
	RTN:=0.8;
	Rot:=0;
	YvI:=1;
	GlSanLineWidth:=1.2;
	ZumT:=0.012;
	glLineWidth (GlSanLineWidth);
	end;
if i+YvI>=0 then inc(i,YvI) else i:=0;
zym:=zym+0.00001;
OpenGL_Draw;
if fullscreen then rotation :=rotation+RTN;
UNTIL GlSanAfterUntil(27,false,a);
glPolygonMode (GL_FRONT_AND_BACK, GL_fill);
glLineWidth (1.7);
end;

procedure Proga_Fracktal_Mandelborg(const boole:boolean;detail:integer);
var n,ogran,red,green,blue,clr : integer;
	xmas,ymas:integer;
	x,y,bx,by,ix,iy,mx,my:real;
	xl,xh,yl,yh,shagx,shagy:real;
	a:array[1..1000,1..1000]of integer;
	Zum:real = 1;
	r1:real = 0;
	r2:real = 0;
	SanDON:boolean;
	leftzum,upzum:real;
BEGin
	ogran:=256;
	SanDon:=GlSanDON;
	GlSanDON:=false;
	xl:=-1.8;
	yl:=-1.3;
	xh:=1;
	yh:=1.3;
	shagx:=(xh-xl)/detail;
	shagy:=(yh-yl)/detail;
	xmas:=0;
	x:=xl;
	leftzum:=0;
	upzum:=0;
	while x<xh do
		begin
		x+=shagx;
		xmas+=1;
		y:=yl;
		ymas:=0;
		while y<yh do
			begin
			y+=shagy;
			ymas+=1;
			mx:=x;
			my:=y;
			bx:=x;
			by:=y;
			ix:=0;
			iy:=0;
			n:=0;
			while((ix*ix+iy*iy<2)and(n<ogran))do
				begin
				ix:=bx*bx-by*by+mx;
				iy:=2*bx*by+my;
				bx:=ix;
				by:=iy;
				n+=1;
				end;
			a[xmas,ymas]:=n;
			end;
		end;
	GlSanClear;
	repeat
	glTranslatef(LeftZum+0.5,Upzum,-2.0*zum);
	glrotatef(R2,1,0,0);
	glrotatef(R1,0,1,0);
	x:=xl;
	xmas:=1;
	while x<xh do
		begin
		x+=shagx;
		xmas+=1;
		y:=yl;
		ymas:=0;
		while y<yh do
			begin
			y+=shagy;
			ymas+=1;
			clr:=a[xmas,ymas];
			green:=clr;
			clr-=85;
			blue:=clr;
			clr-=85;
			red:=clr;

			glcolor3f(red/85,green/85,blue/85);
			glbegin(gl_triangles);
			glvertex3f(x,y,0);

			clr:=a[xmas-1,ymas];
			green:=clr;
			clr-=85;
			blue:=clr;
			clr-=85;
			red:=clr;

			glcolor3f(red/85,green/85,blue/85);
			glvertex3f(x-shagx,y,0);

			clr:=a[xmas,ymas-1];
			green:=clr;
			clr-=85;
			blue:=clr;
			clr-=85;
			red:=clr;

			glcolor3f(red/85,green/85,blue/85);
			glvertex3f(x,y-shagy,0);

			clr:=a[xmas-1,ymas];
			green:=clr;
			clr-=85;
			blue:=clr;
			clr-=85;
			red:=clr;

			glcolor3f(red/85,green/85,blue/85);
			glvertex3f(x-shagx,y,0);

			clr:=a[xmas,ymas-1];
			green:=clr;
			clr-=85;
			blue:=clr;
			clr-=85;
			red:=clr;

			glcolor3f(red/85,green/85,blue/85);
			glvertex3f(x,y-shagy,0);

			clr:=a[xmas-1,ymas-1];
			green:=clr;
			clr-=85;
			blue:=clr;
			clr-=85;
			red:=clr;

			glcolor3f(red/85,green/85,blue/85);
			glvertex3f(x-shagx,y-shagy,0);
			glend();
			end;
		end;
	case LongInt(SGMouseWheelVariable) of
	1:zum+=0.08;
	-1: zum-=0.08;
	end;
	if GlSanMouseReadKey=2 then
		begin
		zum:=1;
		r1:=0;
		r2:=0;
		UpZum:=0;
		LeftZum:=0;
		end;
	if GlSanMouseB(3) then
		begin
		R1-=GlSanMouseXY(1).x/3;
		R2-=GlSanMouseXY(1).y/3;
		end;
	if GlSanMouseB(1) then
		begin
		UpZum+=GlSanMouseXY(1).y/(170);
		LeftZum-=GlSanMouseXY(1).x/(170);
		end;
	until GlSanAfterUntil(27,false,boole);
glSanDon:=SanDON;
end;

procedure Proga_Trig(const bool:boolean);
const
	dl=10000;
var
	CHV:array[1..6]of glsancolor4f;
	Nul,K:GlSanKoor2f;
	SinS,CosS,TgS:real;

begin
glPolygonMode (GL_FRONT_AND_BACK, GL_FILL);
fillchar(chv,sizeof(chv),0);
CHV[1].Import(1,1,0,0.5);
CHV[2].Import(1,1,1,0.5);
CHV[3].Import(0,1,0,0.9);
CHV[4].Import(1,0,1,0.9);
CHV[5].Import(0,1,1,0.9);
CHV[6].Import(1,0,1,0.3);
Nul.x:=width/2;//width, height
Nul.y:=height/2;
glLineWidth (1.5);
tgs:=0;
repeat
GlSanClear;
glLoadIdentity();
glTranslatef(0,0,-6.0*maximum(abs(tgs/1.5),abs(1/tgs/1.5)));
glRotatef( 0,0,1,0);
CHV[1].SanSetColor;
GlSanCircle(100,1.5);
GlSanLine(dl,0,0,-dl,0,0);
GlSanLine(0,dl,0,0,-dl,0);
GlSanOutText(GlSanKoorImport(4,0.2,0),'oX',0.09);
GlSanOutText(GlSanKoorImport(-0.2,4,0),'oY',0.09);
CHV[2].SanSetColor;
GlSanLine(1.5,dl,0,1.5,-dl,0);
GlSanLine(-dl,1.5,0,dl,1.5,0);
glpushmatrix;
glrotatef(270,0,0,1);
GlSanOutText(GlSanKoorImport(2,1.7,0),'Ось Котангенса',0.09);
glpopmatrix;
GlSanOutText(GlSanKoorImport(4,1.7,0),'Ось Тангенса',0.09);
K.x:=SGMouseCoords[1].x;
K.y:=SGMouseCoords[1].y;
K.x:=k.x-nul.x;
K.y:=k.y-nul.y;
TgS:=k.y/k.x;
CosS:=sqrt(1/(1+sqr(TgS)));
SinS:=sqrt(1-sqr(CosS));
if (k.x<0)  then CosS:=-CosS;
if (k.y>0)  then SinS:=-SinS;
//CHV[6].SanSetColor;
//GlSanCircleConst(100,1.5,arccos(CosS,5));
CHV[3].SanSetColor;
GlSanSphere(0,0,0,0.03);
GlSanSphere(CosS*1.5,SinS*1.5,0,0.03);
GlSanLine(0,0,0,CosS*1.5,SinS*1.5,0);
CHV[4].SanSetColor;
GlSanOutText(GlSanKoorImport(CosS*1.5-0.25,-0.2,0),'Cos',0.08);
GlSanOutText(GlSanKoorImport(-0.2,SinS*1.5-0.1,0),'Sin',0.08);
GlSanSphere(0,SinS*1.5,0,0.03);
GlSanSphere(CosS*1.5,0,0,0.03);
GlSanLine(0,SinS*1.5,0,CosS*1.5,SinS*1.5,0);
GlSanLine(CosS*1.5,0,0,CosS*1.5,SinS*1.5,0);
CHV[5].SanSetColor;
GlSanOutText(GlSanKoorImport(1.3,-TgS*1.5,0),'Ctg',0.08);
GlSanOutText(GlSanKoorImport(-(1/TgS)*1.5-0.18,1.5,0),'Tg',0.08);
GlSanSphere(1.5,-TgS*1.5,0,0.03);
GlSanLine(GlSanRastMinT(GlSanKoorImport(CosS*1.5,SinS*1.5,0),
	GlSanKoorImport(0,0,0),GlSanKoorImport(1.5,-TgS*1.5,0)),GlSanKoorImport(1.5,-TgS*1.5,0));
GlSanSphere(-(1/TgS)*1.5,1.5,0,0.03);
GlSanLine(GlSanRastMinT(GlSanKoorImport(0,0,0),GlSanKoorImport(CosS*1.5,SinS*1.5,0),GlSanKoorImport(-(1/TgS)*1.5,1.5,0)),GlSanKoorImport(-(1/TgS)*1.5,1.5,0));
until GlSanAfterUntil(27,false,bool);
end;

procedure Proga_Water(koef,vsplesk:longint);
type
	setka=array[1..501,1..501]of real;
const viviodzum=2;
var rotation : real;

	a,aa,b,bp:setka;
	x,y,kol:longint;
	v,g,h,vis:real;
	pov:boolean;
	koor:GlSanKoor;
	DON:boolean;{Delay of FPS}
	r1:real = 0;
	r2:real = 52;
	zum:real =1;
procedure drawing( a:setka);
var color,rast:real;
	x,y,i,j:longint;
begin
if pov then
	begin
	vis:=0;
	for x:=2 to koef-1 do
		for y:=2 to koef-1 do
			vis:=vis+a[x,y];
	vis:=vis/(sqr(koef-3));
	for i:=2 to koef-1 do
		for j:=2 to koef-1 do
			begin
			a[i,j]:=a[i,j]*sqr(sqr(1-abs(a[i,j])/vsplesk));
			end;
	end;
glTranslatef(0.0,0.0+2.1,-3.53*(viviodzum)*zum);
glRotatef( rotation, 0*viviodzum, 1*viviodzum,0*viviodzum );
glrotatef(R2,1,0,0);
glrotatef(R1,0,1,0);
rast:=0.0;
	for x:=2 to koef-1 do
		begin
		for y:=koef-1 downto 2 do
			begin
			glBegin( GL_TRIANGLEs );
			color:=(a[x,y]+aa[x,y])*5;
			if pov then glColor4f(0,color,color,0.3) else glColor4f(color,0,0,0.3);
			glVertex3f((-2+((4/koef)*x))*viviodzum, (a[x,y]-1+aa[x,y])*viviodzum+rast,(-2+((4/koef)*y))*viviodzum);
			color:=(a[x+1,y]+aa[x+1,y])*5;
			if pov then glColor4f(0,color,color,0.3) else glColor4f(color,0,0,0.3);
			glVertex3f((-2+((4/koef)*(x+1)))*viviodzum,(aa[x+1,y]-1+a[x+1,y])*viviodzum+rast,(-2+((4/koef)*y))*viviodzum);
			color:=(a[x,y+1]+aa[x,y+1])*5;
			if pov then glColor4f(0,color,color,0.3) else glColor4f(color,0,0,0.3);
			glVertex3f((-2+((4/koef)*x))*viviodzum,(aa[x,y+1]-1+a[x,y+1])*viviodzum+rast,(-2+((4/koef)*(y+1)))*viviodzum);
			color:=(a[x+1,y]+aa[x+1,y])*5;
			if pov then glColor4f(0,color,color,0.3) else glColor4f(color,0,0,0.3);
			glVertex3f((-2+((4/koef)*(x+1)))*viviodzum,( aa[x+1,y]-1+a[x+1,y])*viviodzum+rast,(-2+((4/koef)*y))*viviodzum);
			color:=(a[x+1,y+1]+aa[x+1,y+1])*5;
			if pov then glColor4f(0,color,color,0.3) else glColor4f(color,0,0,0.3);
			glVertex3f((-2+((4/koef)*(x+1)))*viviodzum,(aa[x+1,y+1]-1+a[x+1,y+1])*viviodzum+rast,(-2+((4/koef)*(y+1)))*viviodzum);
			color:=(a[x,y+1]+aa[x,y+1])*5;
			if pov then glColor4f(0,color,color,0.3) else glColor4f(color,0,0,0.3);
			glVertex3f((-2+((4/koef)*x))*viviodzum,(aa[x,y+1]-1+a[x,y+1])*viviodzum+rast,(-2+((4/koef)*(y+1)))*viviodzum);
			glEnd();
			end;
		end;
end;
procedure go(x,y:longint);
var i,j:integer;
begin
for i:=-1 to 1 do
	for j:=-1 to 1 do
		if(a[x,y]-a[x+i,y+j]<0)then
			begin
				g:=a[x,y]-a[x+i,y+j];
				if abs(i)+abs(j)=2
					then
						v:=-0.54*g/h
					else
						v:=-0.98*g/h;
				b[x,y]:=b[x,y]+v;
				b[x+i,y+j]:=b[x+i,y+j]-v;
			end;
end;
begin
	DON:=GlSanDON;
	GlSanDON:=false;
	SanShowCursor:=true;
	fillchar(a,sizeof(a),0);
	fillchar(bp,sizeof(bp),0);
	fillchar(b,sizeof(b),0);
	fillchar(aa,sizeof(aa),0);
	//koef:=80; vsplesk:=5;
	h:=7;
	kol:=0;
	pov:=true;
	rotation := 1.0;
	REPEAT
		if (kol mod 150=0)then
			begin
			{}
			x:=random(koef-4)+3;
			y:=random(koef-4)+3;
			a[x,y]:=vsplesk;
			{}
			kol:=1;
			end;
			for x:=2 to koef do
				for y:=2 to koef do
					begin
					go(x,y);
					end;
			for x:=2 to koef-1 do
				for y:=2 to koef-1 do
					begin
					a[x,y]:=a[x,y]+b[x,y]+bp[x,y];
					bp[x,y]:=b[x,y]*0.9+bp[x,y];
					end;
			fillchar(b,sizeof(b),0);
		if (SGKeyPressedVariable<>#0) then
			case LongInt(SGKeyPressedVariable) of
			189:if koef>20 then Dec(koef);
			187:if koef<500 then Inc(koef);
			1:rotation:=0;
			78{n}:if pov then pov:=false else pov:=true;
			82:
				begin
				//fillchar(a,sizeof(a),0);
				fillchar(bp,sizeof(bp),0);
				//fillchar(b,sizeof(b),0);
				end;
			end;
		drawing(a);
		inc(kol);
		rotation += 0.00001;
		Koor:=GlSanReadMouseXYZ;
		glcolor4f(0,0.1,1,1);
		if GlSanMouseB(1) AND GlSanCursorInWindow and GlSanMXYZT(Koor) then
				begin
				kol:=1;
				a[round(((Koor.x+4)/8)*koef),round(((Koor.z+4)/8)*koef)]:=vsplesk;
				end;
		glloadidentity;
		gltranslatef(0,0,-6);
		if FPS>55 then glcolor3f(0,1,0) else if fps>30 then glcolor3f(1,1,0) else glcolor3f(1,0,0);
		GlSanOutText(GlSanKoorImport(-0.5*GlSanTextLength(GlSanStr(koef),0.0015)-0.06,-0.06,5.89),GlSanStr(koef),0.0015);
		if GlSanMouseB(3) then
			begin
			R1-=GlSanMouseXY(1).x/3;
			R2-=GlSanMouseXY(1).y/3;
			end;
		case LongInt(SGMouseWheelVariable) of
		1:zum+=0.08;
		-1: zum-=0.08;
		end;
	UNTIL GlSanAfterUntil(27,false,false);
	GlSanDON:=DON;
end;

procedure Proga_AnySech(const Kill:boolean; const PObj:pointer);
type
	LinesAr=array of array[1..2] of longint;
	TochkiAr=array of GlSanKoor;
	PloskostiAr=array of array[1..2] of longint;
var
	Obj:^GlSanLightObject;
	r1:real=0;
	r2:real=0;
	zum:real=1;
	Lines:^LinesAr;
	i,ii,j,jj,k:longint;
	Bool:boolean;
	Itap:byte=0;
	Koor:GlSanKoor;
	Tochki:^TochkiAr;
	Ploskosti:^PloskostiAr;
	SphereRadiusMAX:real = 0.25;
	SphereRadiusMIN:real = 0.05;
	SphereRadius:real = 0.2;
begin
New(Lines);
New(Tochki);
New(Ploskosti);
SetLength(Lines^,0);
SetLength(Tochki^,0);
SetLength(Ploskosti^,0);
Obj:=PObj;
for i:=1 to Obj^.KolF do
	begin
	for j:=1 to Obj^.F[i]^.Kol do
		begin
		if j=1 then
			begin
			ii:=Obj^.F[i]^.N[j];
			jj:=Obj^.F[i]^.N[Obj^.F[i]^.Kol];
			end
		else
			begin
			ii:=Obj^.F[i]^.N[j];
			jj:=Obj^.F[i]^.N[j-1];
			end;
		Bool:=true;
		for k:=low(Lines^) to High(Lines^) do
			begin
			if (((Lines^[k,1]=ii) and (Lines^[k,2]=jj)) or ((Lines^[k,2]=ii) and (Lines^[k,1]=jj))) then
				bool:=false;
			end;
		if Bool then
			begin
			SetLength(Lines^,Length(Lines^)+1);
			Lines^[High(Lines^),1]:=ii;
			Lines^[High(Lines^),2]:=jj;
			end;
		end;
	end;
GlSanClear;
repeat
SphereRadius+=0.03;
if SphereRadius>SphereRadiusMAX then SphereRadius:=SphereRadiusMIN;
gltranslatef(0,0,-7*zum);
glrotatef(R2,1,0,0);
glrotatef(R1,0,1,0);
glcolor4f(0,1,0,0.8);
glLineWidth (1.8);
for i:=Low(Lines^) to High(Lines^) do
	GlSanLine(Obj^.V[Lines^[i,1]]^,Obj^.V[Lines^[i,2]]^);
case Itap of
0:
	begin
	Koor:=GlSanReadMouseXYZ;
	if GlSanMouseC(1) then
		begin
		if GlSanMXYZT(koor) and GlSanCursorInWindow then
			begin
			SetLength(Tochki^,Length(Tochki^)+1);
			Tochki^[High(Tochki^)]:=Koor;
			if Length(Tochki^)=3 then Itap+=1;
			end;
		end;
	glcolor4f(1,0,0,0.8);
	if GlSanMXYZT(koor) and GlSanCursorInWindow then
		GlSanSphere(Koor,SphereRadius);
	end;
1:
	begin
	for i:=1 to Obj^.KolF do
		for j:=1 to Obj^.KolF do
			begin
			Bool:=true;
			for ii:=Low(Ploskosti^) to High(Ploskosti^) do
				begin
				if (((i=Ploskosti^[ii,1]) and (j=Ploskosti^[ii,2])) or ((i=Ploskosti^[ii,2]) and (j=Ploskosti^[ii,1]))) then
					Bool:=false;
				end;
			if Bool then
				begin

				end;
			end;

	Itap+=1;
	end;
2:
	begin
	if Length(Tochki^)>3 then
		for i:=2 to High(Tochki^) do
			GlSanSphere(Tochki^[i],0.1);
	end;
end;
if GlSanMouseB(3) then
	begin
	R1-=GlSanMouseXY(1).x/3;
	R2-=GlSanMouseXY(1).y/3;
	end;
case LongInt(SGMouseWheelVariable) of
1:zum+=0.08;
-1: zum-=0.08;
end;
glcolor4f(0,1,0,0.8);
for i:=Low(Tochki^) to High(Tochki^) do
	GlSanSphere(Tochki^[i],0.2);
glcolor4f(0,1,0,0.1);
Obj^.Init(GlSanKoorImport(0,0,0),1);
until GlSanAfterUntil(27,false,Kill);
SetLength(Lines^,0);
SetLength(Tochki^,0);
SetLength(Ploskosti^,0);
Dispose(Lines);
Dispose(Tochki);
Dispose(Ploskosti);
end;


procedure Sphere2Obj3(var O:GlSanObj3); { Пишем заголовок процедуры }

procedure SetLengths;
begin
O.Dispose;
SetLength(O.V,212);
SetLength(O.F,225);
SetLength(O.F[0],3);
SetLength(O.F[1],4);
SetLength(O.F[2],4);
SetLength(O.F[3],4);
SetLength(O.F[4],4);
SetLength(O.F[5],4);
SetLength(O.F[6],4);
SetLength(O.F[7],4);
SetLength(O.F[8],4);
SetLength(O.F[9],4);
SetLength(O.F[10],4);
SetLength(O.F[11],4);
SetLength(O.F[12],4);
SetLength(O.F[13],4);
SetLength(O.F[14],3);
SetLength(O.F[15],3);
SetLength(O.F[16],4);
SetLength(O.F[17],4);
SetLength(O.F[18],4);
SetLength(O.F[19],4);
SetLength(O.F[20],4);
SetLength(O.F[21],4);
SetLength(O.F[22],4);
SetLength(O.F[23],4);
SetLength(O.F[24],4);
SetLength(O.F[25],4);
SetLength(O.F[26],4);
SetLength(O.F[27],4);
SetLength(O.F[28],4);
SetLength(O.F[29],3);
SetLength(O.F[30],3);
SetLength(O.F[31],4);
SetLength(O.F[32],4);
SetLength(O.F[33],4);
SetLength(O.F[34],4);
SetLength(O.F[35],4);
SetLength(O.F[36],4);
SetLength(O.F[37],4);
SetLength(O.F[38],4);
SetLength(O.F[39],4);
SetLength(O.F[40],4);
SetLength(O.F[41],4);
SetLength(O.F[42],4);
SetLength(O.F[43],4);
SetLength(O.F[44],3);
SetLength(O.F[45],3);
SetLength(O.F[46],4);
SetLength(O.F[47],4);
SetLength(O.F[48],4);
SetLength(O.F[49],4);
SetLength(O.F[50],4);
SetLength(O.F[51],4);
SetLength(O.F[52],4);
SetLength(O.F[53],4);
SetLength(O.F[54],4);
SetLength(O.F[55],4);
SetLength(O.F[56],4);
SetLength(O.F[57],4);
SetLength(O.F[58],4);
SetLength(O.F[59],3);
SetLength(O.F[60],3);
SetLength(O.F[61],4);
SetLength(O.F[62],4);
SetLength(O.F[63],4);
SetLength(O.F[64],4);
SetLength(O.F[65],4);
SetLength(O.F[66],4);
SetLength(O.F[67],4);
SetLength(O.F[68],4);
SetLength(O.F[69],4);
SetLength(O.F[70],4);
SetLength(O.F[71],4);
SetLength(O.F[72],4);
SetLength(O.F[73],4);
SetLength(O.F[74],3);
SetLength(O.F[75],3);
SetLength(O.F[76],4);
SetLength(O.F[77],4);
SetLength(O.F[78],4);
SetLength(O.F[79],4);
SetLength(O.F[80],4);
SetLength(O.F[81],4);
SetLength(O.F[82],4);
SetLength(O.F[83],4);
SetLength(O.F[84],4);
SetLength(O.F[85],4);
SetLength(O.F[86],4);
SetLength(O.F[87],4);
SetLength(O.F[88],4);
SetLength(O.F[89],3);
SetLength(O.F[90],3);
SetLength(O.F[91],4);
SetLength(O.F[92],4);
SetLength(O.F[93],4);
SetLength(O.F[94],4);
SetLength(O.F[95],4);
SetLength(O.F[96],4);
SetLength(O.F[97],4);
SetLength(O.F[98],4);
SetLength(O.F[99],4);
SetLength(O.F[100],4);
SetLength(O.F[101],4);
SetLength(O.F[102],4);
SetLength(O.F[103],4);
SetLength(O.F[104],3);
SetLength(O.F[105],3);
SetLength(O.F[106],4);
SetLength(O.F[107],4);
SetLength(O.F[108],4);
SetLength(O.F[109],4);
SetLength(O.F[110],4);
SetLength(O.F[111],4);
SetLength(O.F[112],4);
SetLength(O.F[113],4);
SetLength(O.F[114],4);
SetLength(O.F[115],4);
SetLength(O.F[116],4);
SetLength(O.F[117],4);
SetLength(O.F[118],4);
SetLength(O.F[119],3);
SetLength(O.F[120],3);
SetLength(O.F[121],4);
SetLength(O.F[122],4);
SetLength(O.F[123],4);
SetLength(O.F[124],4);
SetLength(O.F[125],4);
SetLength(O.F[126],4);
SetLength(O.F[127],4);
SetLength(O.F[128],4);
SetLength(O.F[129],4);
SetLength(O.F[130],4);
SetLength(O.F[131],4);
SetLength(O.F[132],4);
SetLength(O.F[133],4);
SetLength(O.F[134],3);
SetLength(O.F[135],3);
SetLength(O.F[136],4);
SetLength(O.F[137],4);
SetLength(O.F[138],4);
SetLength(O.F[139],4);
SetLength(O.F[140],4);
SetLength(O.F[141],4);
SetLength(O.F[142],4);
SetLength(O.F[143],4);
SetLength(O.F[144],4);
SetLength(O.F[145],4);
SetLength(O.F[146],4);
SetLength(O.F[147],4);
SetLength(O.F[148],4);
SetLength(O.F[149],3);
SetLength(O.F[150],3);
SetLength(O.F[151],4);
SetLength(O.F[152],4);
SetLength(O.F[153],4);
SetLength(O.F[154],4);
SetLength(O.F[155],4);
SetLength(O.F[156],4);
SetLength(O.F[157],4);
SetLength(O.F[158],4);
SetLength(O.F[159],4);
SetLength(O.F[160],4);
SetLength(O.F[161],4);
SetLength(O.F[162],4);
SetLength(O.F[163],4);
SetLength(O.F[164],3);
SetLength(O.F[165],3);
SetLength(O.F[166],4);
SetLength(O.F[167],4);
SetLength(O.F[168],4);
SetLength(O.F[169],4);
SetLength(O.F[170],4);
SetLength(O.F[171],4);
SetLength(O.F[172],4);
SetLength(O.F[173],4);
SetLength(O.F[174],4);
SetLength(O.F[175],4);
SetLength(O.F[176],4);
SetLength(O.F[177],4);
SetLength(O.F[178],4);
SetLength(O.F[179],3);
SetLength(O.F[180],3);
SetLength(O.F[181],4);
SetLength(O.F[182],4);
SetLength(O.F[183],4);
SetLength(O.F[184],4);
SetLength(O.F[185],4);
SetLength(O.F[186],4);
SetLength(O.F[187],4);
SetLength(O.F[188],4);
SetLength(O.F[189],4);
SetLength(O.F[190],4);
SetLength(O.F[191],4);
SetLength(O.F[192],4);
SetLength(O.F[193],4);
SetLength(O.F[194],3);
SetLength(O.F[195],3);
SetLength(O.F[196],4);
SetLength(O.F[197],4);
SetLength(O.F[198],4);
SetLength(O.F[199],4);
SetLength(O.F[200],4);
SetLength(O.F[201],4);
SetLength(O.F[202],4);
SetLength(O.F[203],4);
SetLength(O.F[204],4);
SetLength(O.F[205],4);
SetLength(O.F[206],4);
SetLength(O.F[207],4);
SetLength(O.F[208],4);
SetLength(O.F[209],3);
SetLength(O.F[210],3);
SetLength(O.F[211],4);
SetLength(O.F[212],4);
SetLength(O.F[213],4);
SetLength(O.F[214],4);
SetLength(O.F[215],4);
SetLength(O.F[216],4);
SetLength(O.F[217],4);
SetLength(O.F[218],4);
SetLength(O.F[219],4);
SetLength(O.F[220],4);
SetLength(O.F[221],4);
SetLength(O.F[222],4);
SetLength(O.F[223],4);
SetLength(O.F[224],3);
end;

begin
SetLengths;
O.V[0].Import(0.207912,0.000000,0.978148);
O.V[1].Import(0.406737,0.000000,0.913545);
O.V[2].Import(0.587785,0.000000,0.809017);
O.V[3].Import(0.743145,0.000000,0.669131);
O.V[4].Import(0.866025,0.000000,0.500000);
O.V[5].Import(0.951057,0.000000,0.309017);
O.V[6].Import(0.994522,0.000000,0.104528);
O.V[7].Import(0.994522,0.000000,-0.104529);
O.V[8].Import(0.951056,0.000000,-0.309017);
O.V[9].Import(0.866025,0.000000,-0.500000);
O.V[10].Import(0.743145,0.000000,-0.669131);
O.V[11].Import(0.587785,0.000000,-0.809017);
O.V[12].Import(0.406737,0.000000,-0.913545);
O.V[13].Import(0.207912,0.000000,-0.978148);
O.V[14].Import(-0.000000,0.000000,-1.000000);
O.V[15].Import(0.189937,0.084565,-0.978148);
O.V[16].Import(0.371572,0.165435,-0.913545);
O.V[17].Import(0.536968,0.239074,-0.809017);
O.V[18].Import(0.678897,0.302264,-0.669131);
O.V[19].Import(0.791154,0.352244,-0.500000);
O.V[20].Import(0.868833,0.386830,-0.309017);
O.V[21].Import(0.908541,0.404509,-0.104529);
O.V[22].Import(0.908541,0.404509,0.104528);
O.V[23].Import(0.868833,0.386830,0.309017);
O.V[24].Import(0.791154,0.352244,0.500000);
O.V[25].Import(0.678897,0.302264,0.669131);
O.V[26].Import(0.536969,0.239074,0.809017);
O.V[27].Import(0.371572,0.165435,0.913545);
O.V[28].Import(0.189937,0.084565,0.978148);
O.V[29].Import(0.139120,0.154509,0.978148);
O.V[30].Import(0.272160,0.302264,0.913545);
O.V[31].Import(0.393305,0.436810,0.809017);
O.V[32].Import(0.497261,0.552264,0.669131);
O.V[33].Import(0.579484,0.643582,0.500000);
O.V[34].Import(0.636381,0.706773,0.309017);
O.V[35].Import(0.665465,0.739074,0.104528);
O.V[36].Import(0.665465,0.739074,-0.104529);
O.V[37].Import(0.636381,0.706773,-0.309017);
O.V[38].Import(0.579484,0.643582,-0.500000);
O.V[39].Import(0.497261,0.552264,-0.669131);
O.V[40].Import(0.393305,0.436810,-0.809017);
O.V[41].Import(0.272160,0.302264,-0.913545);
O.V[42].Import(0.139120,0.154508,-0.978148);
O.V[43].Import(0.064248,0.197736,-0.978148);
O.V[44].Import(0.125688,0.386829,-0.913545);
O.V[45].Import(0.181636,0.559017,-0.809017);
O.V[46].Import(0.229644,0.706773,-0.669131);
O.V[47].Import(0.267616,0.823639,-0.500000);
O.V[48].Import(0.293892,0.904508,-0.309017);
O.V[49].Import(0.307324,0.945847,-0.104529);
O.V[50].Import(0.307324,0.945847,0.104528);
O.V[51].Import(0.293893,0.904509,0.309017);
O.V[52].Import(0.267617,0.823639,0.500000);
O.V[53].Import(0.229644,0.706773,0.669131);
O.V[54].Import(0.181636,0.559017,0.809017);
O.V[55].Import(0.125688,0.386830,0.913545);
O.V[56].Import(0.064248,0.197736,0.978148);
O.V[57].Import(-0.021733,0.206773,0.978148);
O.V[58].Import(-0.042516,0.404508,0.913545);
O.V[59].Import(-0.061440,0.584565,0.809017);
O.V[60].Import(-0.077680,0.739074,0.669131);
O.V[61].Import(-0.090524,0.861281,0.500000);
O.V[62].Import(-0.099413,0.945846,0.309017);
O.V[63].Import(-0.103956,0.989074,0.104528);
O.V[64].Import(-0.103956,0.989074,-0.104529);
O.V[65].Import(-0.099413,0.945846,-0.309017);
O.V[66].Import(-0.090524,0.861281,-0.500000);
O.V[67].Import(-0.077680,0.739074,-0.669131);
O.V[68].Import(-0.061440,0.584565,-0.809017);
O.V[69].Import(-0.042516,0.404508,-0.913545);
O.V[70].Import(-0.021733,0.206773,-0.978148);
O.V[71].Import(-0.103956,0.180057,-0.978148);
O.V[72].Import(-0.203368,0.352244,-0.913545);
O.V[73].Import(-0.293893,0.509037,-0.809017);
O.V[74].Import(-0.371572,0.643582,-0.669131);
O.V[75].Import(-0.433013,0.750000,-0.500000);
O.V[76].Import(-0.475528,0.823639,-0.309017);
O.V[77].Import(-0.497261,0.861281,-0.104529);
O.V[78].Import(-0.497261,0.861281,0.104528);
O.V[79].Import(-0.475528,0.823639,0.309017);
O.V[80].Import(-0.433013,0.750000,0.500000);
O.V[81].Import(-0.371572,0.643582,0.669131);
O.V[82].Import(-0.293893,0.509037,0.809017);
O.V[83].Import(-0.203368,0.352244,0.913545);
O.V[84].Import(-0.103956,0.180057,0.978148);
O.V[85].Import(-0.168204,0.122207,0.978148);
O.V[86].Import(-0.329057,0.239074,0.913545);
O.V[87].Import(-0.475528,0.345491,0.809017);
O.V[88].Import(-0.601217,0.436809,0.669131);
O.V[89].Import(-0.700629,0.509037,0.500000);
O.V[90].Import(-0.769421,0.559017,0.309017);
O.V[91].Import(-0.804585,0.584565,0.104528);
O.V[92].Import(-0.804585,0.584565,-0.104529);
O.V[93].Import(-0.769421,0.559017,-0.309017);
O.V[94].Import(-0.700629,0.509037,-0.500000);
O.V[95].Import(-0.601217,0.436809,-0.669131);
O.V[96].Import(-0.475528,0.345491,-0.809017);
O.V[97].Import(-0.329057,0.239074,-0.913545);
O.V[98].Import(-0.168204,0.122207,-0.978148);
O.V[99].Import(-0.203368,0.043227,-0.978148);
O.V[100].Import(-0.397848,0.084565,-0.913545);
O.V[101].Import(-0.574941,0.122207,-0.809017);
O.V[102].Import(-0.726905,0.154508,-0.669131);
O.V[103].Import(-0.847101,0.180057,-0.500000);
O.V[104].Import(-0.930274,0.197735,-0.309017);
O.V[105].Import(-0.972789,0.206772,-0.104529);
O.V[106].Import(-0.972789,0.206772,0.104528);
O.V[107].Import(-0.930274,0.197735,0.309017);
O.V[108].Import(-0.847101,0.180057,0.500000);
O.V[109].Import(-0.726905,0.154508,0.669131);
O.V[110].Import(-0.574941,0.122207,0.809017);
O.V[111].Import(-0.397848,0.084565,0.913545);
O.V[112].Import(-0.203368,0.043227,0.978148);
O.V[113].Import(-0.203368,-0.043227,0.978148);
O.V[114].Import(-0.397848,-0.084565,0.913545);
O.V[115].Import(-0.574941,-0.122208,0.809017);
O.V[116].Import(-0.726905,-0.154509,0.669131);
O.V[117].Import(-0.847101,-0.180057,0.500000);
O.V[118].Import(-0.930274,-0.197736,0.309017);
O.V[119].Import(-0.972789,-0.206773,0.104528);
O.V[120].Import(-0.972789,-0.206773,-0.104529);
O.V[121].Import(-0.930273,-0.197736,-0.309017);
O.V[122].Import(-0.847101,-0.180057,-0.500000);
O.V[123].Import(-0.726905,-0.154509,-0.669131);
O.V[124].Import(-0.574941,-0.122208,-0.809017);
O.V[125].Import(-0.397848,-0.084565,-0.913545);
O.V[126].Import(-0.203368,-0.043227,-0.978148);
O.V[127].Import(-0.168204,-0.122207,-0.978148);
O.V[128].Import(-0.329057,-0.239074,-0.913545);
O.V[129].Import(-0.475528,-0.345492,-0.809017);
O.V[130].Import(-0.601217,-0.436810,-0.669131);
O.V[131].Import(-0.700629,-0.509037,-0.500000);
O.V[132].Import(-0.769421,-0.559017,-0.309017);
O.V[133].Import(-0.804585,-0.584566,-0.104529);
O.V[134].Import(-0.804585,-0.584566,0.104528);
O.V[135].Import(-0.769421,-0.559017,0.309017);
O.V[136].Import(-0.700629,-0.509037,0.500000);
O.V[137].Import(-0.601217,-0.436810,0.669131);
O.V[138].Import(-0.475528,-0.345492,0.809017);
O.V[139].Import(-0.329057,-0.239074,0.913545);
O.V[140].Import(-0.168204,-0.122207,0.978148);
O.V[141].Import(-0.103956,-0.180057,0.978148);
O.V[142].Import(-0.203368,-0.352244,0.913545);
O.V[143].Import(-0.293892,-0.509037,0.809017);
O.V[144].Import(-0.371572,-0.643582,0.669131);
O.V[145].Import(-0.433012,-0.750000,0.500000);
O.V[146].Import(-0.475528,-0.823639,0.309017);
O.V[147].Import(-0.497261,-0.861281,0.104528);
O.V[148].Import(-0.497261,-0.861281,-0.104529);
O.V[149].Import(-0.475528,-0.823639,-0.309017);
O.V[150].Import(-0.433012,-0.750000,-0.500000);
O.V[151].Import(-0.371572,-0.643582,-0.669131);
O.V[152].Import(-0.293892,-0.509037,-0.809017);
O.V[153].Import(-0.203368,-0.352244,-0.913545);
O.V[154].Import(-0.103956,-0.180057,-0.978148);
O.V[155].Import(-0.021733,-0.206773,-0.978148);
O.V[156].Import(-0.042515,-0.404508,-0.913545);
O.V[157].Import(-0.061440,-0.584565,-0.809017);
O.V[158].Import(-0.077680,-0.739074,-0.669131);
O.V[159].Import(-0.090524,-0.861281,-0.500000);
O.V[160].Import(-0.099412,-0.945846,-0.309017);
O.V[161].Import(-0.103955,-0.989074,-0.104529);
O.V[162].Import(-0.103955,-0.989074,0.104528);
O.V[163].Import(-0.099412,-0.945846,0.309017);
O.V[164].Import(-0.090524,-0.861281,0.500000);
O.V[165].Import(-0.077680,-0.739074,0.669131);
O.V[166].Import(-0.061440,-0.584565,0.809017);
O.V[167].Import(-0.042515,-0.404508,0.913545);
O.V[168].Import(-0.021733,-0.206773,0.978148);
O.V[169].Import(0.064248,-0.197736,0.978148);
O.V[170].Import(0.125689,-0.386829,0.913545);
O.V[171].Import(0.181636,-0.559017,0.809017);
O.V[172].Import(0.229645,-0.706773,0.669131);
O.V[173].Import(0.267617,-0.823639,0.500000);
O.V[174].Import(0.293893,-0.904508,0.309017);
O.V[175].Import(0.307325,-0.945846,0.104528);
O.V[176].Import(0.307325,-0.945846,-0.104529);
O.V[177].Import(0.293893,-0.904508,-0.309017);
O.V[178].Import(0.267617,-0.823639,-0.500000);
O.V[179].Import(0.229645,-0.706773,-0.669131);
O.V[180].Import(0.181636,-0.559017,-0.809017);
O.V[181].Import(0.125689,-0.386829,-0.913545);
O.V[182].Import(0.064248,-0.197736,-0.978148);
O.V[183].Import(0.139120,-0.154508,-0.978148);
O.V[184].Import(0.272160,-0.302264,-0.913545);
O.V[185].Import(0.393305,-0.436809,-0.809017);
O.V[186].Import(0.497261,-0.552264,-0.669131);
O.V[187].Import(0.579484,-0.643582,-0.500000);
O.V[188].Import(0.636381,-0.706772,-0.309017);
O.V[189].Import(0.665465,-0.739073,-0.104529);
O.V[190].Import(0.665465,-0.739073,0.104528);
O.V[191].Import(0.636381,-0.706772,0.309017);
O.V[192].Import(0.579484,-0.643582,0.500000);
O.V[193].Import(0.497261,-0.552264,0.669131);
O.V[194].Import(0.393305,-0.436809,0.809017);
O.V[195].Import(0.272160,-0.302264,0.913545);
O.V[196].Import(0.139120,-0.154508,0.978148);
O.V[197].Import(0.000000,0.000000,1.000000);
O.V[198].Import(0.189937,-0.084565,0.978148);
O.V[199].Import(0.371572,-0.165434,0.913545);
O.V[200].Import(0.536969,-0.239074,0.809017);
O.V[201].Import(0.678897,-0.302264,0.669131);
O.V[202].Import(0.791154,-0.352244,0.500000);
O.V[203].Import(0.868833,-0.386829,0.309017);
O.V[204].Import(0.908541,-0.404508,0.104528);
O.V[205].Import(0.908541,-0.404508,-0.104529);
O.V[206].Import(0.868833,-0.386829,-0.309017);
O.V[207].Import(0.791154,-0.352244,-0.500000);
O.V[208].Import(0.678897,-0.302264,-0.669131);
O.V[209].Import(0.536969,-0.239073,-0.809017);
O.V[210].Import(0.371572,-0.165434,-0.913545);
O.V[211].Import(0.189937,-0.084565,-0.978148);
O.F[0,0]:=13;
O.F[0,1]:=15;
O.F[0,2]:=14;
O.F[1,0]:=12;
O.F[1,1]:=16;
O.F[1,2]:=15;
O.F[1,3]:=13;
O.F[2,0]:=11;
O.F[2,1]:=17;
O.F[2,2]:=16;
O.F[2,3]:=12;
O.F[3,0]:=10;
O.F[3,1]:=18;
O.F[3,2]:=17;
O.F[3,3]:=11;
O.F[4,0]:=9;
O.F[4,1]:=19;
O.F[4,2]:=18;
O.F[4,3]:=10;
O.F[5,0]:=8;
O.F[5,1]:=20;
O.F[5,2]:=19;
O.F[5,3]:=9;
O.F[6,0]:=7;
O.F[6,1]:=21;
O.F[6,2]:=20;
O.F[6,3]:=8;
O.F[7,0]:=6;
O.F[7,1]:=22;
O.F[7,2]:=21;
O.F[7,3]:=7;
O.F[8,0]:=5;
O.F[8,1]:=23;
O.F[8,2]:=22;
O.F[8,3]:=6;
O.F[9,0]:=4;
O.F[9,1]:=24;
O.F[9,2]:=23;
O.F[9,3]:=5;
O.F[10,0]:=3;
O.F[10,1]:=25;
O.F[10,2]:=24;
O.F[10,3]:=4;
O.F[11,0]:=2;
O.F[11,1]:=26;
O.F[11,2]:=25;
O.F[11,3]:=3;
O.F[12,0]:=1;
O.F[12,1]:=27;
O.F[12,2]:=26;
O.F[12,3]:=2;
O.F[13,0]:=27;
O.F[13,1]:=1;
O.F[13,2]:=0;
O.F[13,3]:=28;
O.F[14,0]:=197;
O.F[14,1]:=28;
O.F[14,2]:=0;
O.F[15,0]:=197;
O.F[15,1]:=29;
O.F[15,2]:=28;
O.F[16,0]:=28;
O.F[16,1]:=29;
O.F[16,2]:=30;
O.F[16,3]:=27;
O.F[17,0]:=27;
O.F[17,1]:=30;
O.F[17,2]:=31;
O.F[17,3]:=26;
O.F[18,0]:=26;
O.F[18,1]:=31;
O.F[18,2]:=32;
O.F[18,3]:=25;
O.F[19,0]:=25;
O.F[19,1]:=32;
O.F[19,2]:=33;
O.F[19,3]:=24;
O.F[20,0]:=24;
O.F[20,1]:=33;
O.F[20,2]:=34;
O.F[20,3]:=23;
O.F[21,0]:=23;
O.F[21,1]:=34;
O.F[21,2]:=35;
O.F[21,3]:=22;
O.F[22,0]:=22;
O.F[22,1]:=35;
O.F[22,2]:=36;
O.F[22,3]:=21;
O.F[23,0]:=21;
O.F[23,1]:=36;
O.F[23,2]:=37;
O.F[23,3]:=20;
O.F[24,0]:=20;
O.F[24,1]:=37;
O.F[24,2]:=38;
O.F[24,3]:=19;
O.F[25,0]:=19;
O.F[25,1]:=38;
O.F[25,2]:=39;
O.F[25,3]:=18;
O.F[26,0]:=18;
O.F[26,1]:=39;
O.F[26,2]:=40;
O.F[26,3]:=17;
O.F[27,0]:=17;
O.F[27,1]:=40;
O.F[27,2]:=41;
O.F[27,3]:=16;
O.F[28,0]:=16;
O.F[28,1]:=41;
O.F[28,2]:=42;
O.F[28,3]:=15;
O.F[29,0]:=15;
O.F[29,1]:=42;
O.F[29,2]:=14;
O.F[30,0]:=42;
O.F[30,1]:=43;
O.F[30,2]:=14;
O.F[31,0]:=41;
O.F[31,1]:=44;
O.F[31,2]:=43;
O.F[31,3]:=42;
O.F[32,0]:=40;
O.F[32,1]:=45;
O.F[32,2]:=44;
O.F[32,3]:=41;
O.F[33,0]:=39;
O.F[33,1]:=46;
O.F[33,2]:=45;
O.F[33,3]:=40;
O.F[34,0]:=38;
O.F[34,1]:=47;
O.F[34,2]:=46;
O.F[34,3]:=39;
O.F[35,0]:=37;
O.F[35,1]:=48;
O.F[35,2]:=47;
O.F[35,3]:=38;
O.F[36,0]:=36;
O.F[36,1]:=49;
O.F[36,2]:=48;
O.F[36,3]:=37;
O.F[37,0]:=35;
O.F[37,1]:=50;
O.F[37,2]:=49;
O.F[37,3]:=36;
O.F[38,0]:=34;
O.F[38,1]:=51;
O.F[38,2]:=50;
O.F[38,3]:=35;
O.F[39,0]:=33;
O.F[39,1]:=52;
O.F[39,2]:=51;
O.F[39,3]:=34;
O.F[40,0]:=32;
O.F[40,1]:=53;
O.F[40,2]:=52;
O.F[40,3]:=33;
O.F[41,0]:=31;
O.F[41,1]:=54;
O.F[41,2]:=53;
O.F[41,3]:=32;
O.F[42,0]:=30;
O.F[42,1]:=55;
O.F[42,2]:=54;
O.F[42,3]:=31;
O.F[43,0]:=29;
O.F[43,1]:=56;
O.F[43,2]:=55;
O.F[43,3]:=30;
O.F[44,0]:=197;
O.F[44,1]:=56;
O.F[44,2]:=29;
O.F[45,0]:=197;
O.F[45,1]:=57;
O.F[45,2]:=56;
O.F[46,0]:=56;
O.F[46,1]:=57;
O.F[46,2]:=58;
O.F[46,3]:=55;
O.F[47,0]:=55;
O.F[47,1]:=58;
O.F[47,2]:=59;
O.F[47,3]:=54;
O.F[48,0]:=54;
O.F[48,1]:=59;
O.F[48,2]:=60;
O.F[48,3]:=53;
O.F[49,0]:=53;
O.F[49,1]:=60;
O.F[49,2]:=61;
O.F[49,3]:=52;
O.F[50,0]:=52;
O.F[50,1]:=61;
O.F[50,2]:=62;
O.F[50,3]:=51;
O.F[51,0]:=51;
O.F[51,1]:=62;
O.F[51,2]:=63;
O.F[51,3]:=50;
O.F[52,0]:=50;
O.F[52,1]:=63;
O.F[52,2]:=64;
O.F[52,3]:=49;
O.F[53,0]:=49;
O.F[53,1]:=64;
O.F[53,2]:=65;
O.F[53,3]:=48;
O.F[54,0]:=48;
O.F[54,1]:=65;
O.F[54,2]:=66;
O.F[54,3]:=47;
O.F[55,0]:=47;
O.F[55,1]:=66;
O.F[55,2]:=67;
O.F[55,3]:=46;
O.F[56,0]:=46;
O.F[56,1]:=67;
O.F[56,2]:=68;
O.F[56,3]:=45;
O.F[57,0]:=45;
O.F[57,1]:=68;
O.F[57,2]:=69;
O.F[57,3]:=44;
O.F[58,0]:=44;
O.F[58,1]:=69;
O.F[58,2]:=70;
O.F[58,3]:=43;
O.F[59,0]:=43;
O.F[59,1]:=70;
O.F[59,2]:=14;
O.F[60,0]:=70;
O.F[60,1]:=71;
O.F[60,2]:=14;
O.F[61,0]:=69;
O.F[61,1]:=72;
O.F[61,2]:=71;
O.F[61,3]:=70;
O.F[62,0]:=68;
O.F[62,1]:=73;
O.F[62,2]:=72;
O.F[62,3]:=69;
O.F[63,0]:=67;
O.F[63,1]:=74;
O.F[63,2]:=73;
O.F[63,3]:=68;
O.F[64,0]:=66;
O.F[64,1]:=75;
O.F[64,2]:=74;
O.F[64,3]:=67;
O.F[65,0]:=65;
O.F[65,1]:=76;
O.F[65,2]:=75;
O.F[65,3]:=66;
O.F[66,0]:=64;
O.F[66,1]:=77;
O.F[66,2]:=76;
O.F[66,3]:=65;
O.F[67,0]:=63;
O.F[67,1]:=78;
O.F[67,2]:=77;
O.F[67,3]:=64;
O.F[68,0]:=62;
O.F[68,1]:=79;
O.F[68,2]:=78;
O.F[68,3]:=63;
O.F[69,0]:=61;
O.F[69,1]:=80;
O.F[69,2]:=79;
O.F[69,3]:=62;
O.F[70,0]:=60;
O.F[70,1]:=81;
O.F[70,2]:=80;
O.F[70,3]:=61;
O.F[71,0]:=59;
O.F[71,1]:=82;
O.F[71,2]:=81;
O.F[71,3]:=60;
O.F[72,0]:=58;
O.F[72,1]:=83;
O.F[72,2]:=82;
O.F[72,3]:=59;
O.F[73,0]:=57;
O.F[73,1]:=84;
O.F[73,2]:=83;
O.F[73,3]:=58;
O.F[74,0]:=197;
O.F[74,1]:=84;
O.F[74,2]:=57;
O.F[75,0]:=197;
O.F[75,1]:=85;
O.F[75,2]:=84;
O.F[76,0]:=84;
O.F[76,1]:=85;
O.F[76,2]:=86;
O.F[76,3]:=83;
O.F[77,0]:=83;
O.F[77,1]:=86;
O.F[77,2]:=87;
O.F[77,3]:=82;
O.F[78,0]:=82;
O.F[78,1]:=87;
O.F[78,2]:=88;
O.F[78,3]:=81;
O.F[79,0]:=81;
O.F[79,1]:=88;
O.F[79,2]:=89;
O.F[79,3]:=80;
O.F[80,0]:=80;
O.F[80,1]:=89;
O.F[80,2]:=90;
O.F[80,3]:=79;
O.F[81,0]:=79;
O.F[81,1]:=90;
O.F[81,2]:=91;
O.F[81,3]:=78;
O.F[82,0]:=78;
O.F[82,1]:=91;
O.F[82,2]:=92;
O.F[82,3]:=77;
O.F[83,0]:=77;
O.F[83,1]:=92;
O.F[83,2]:=93;
O.F[83,3]:=76;
O.F[84,0]:=76;
O.F[84,1]:=93;
O.F[84,2]:=94;
O.F[84,3]:=75;
O.F[85,0]:=75;
O.F[85,1]:=94;
O.F[85,2]:=95;
O.F[85,3]:=74;
O.F[86,0]:=74;
O.F[86,1]:=95;
O.F[86,2]:=96;
O.F[86,3]:=73;
O.F[87,0]:=73;
O.F[87,1]:=96;
O.F[87,2]:=97;
O.F[87,3]:=72;
O.F[88,0]:=72;
O.F[88,1]:=97;
O.F[88,2]:=98;
O.F[88,3]:=71;
O.F[89,0]:=71;
O.F[89,1]:=98;
O.F[89,2]:=14;
O.F[90,0]:=98;
O.F[90,1]:=99;
O.F[90,2]:=14;
O.F[91,0]:=97;
O.F[91,1]:=100;
O.F[91,2]:=99;
O.F[91,3]:=98;
O.F[92,0]:=96;
O.F[92,1]:=101;
O.F[92,2]:=100;
O.F[92,3]:=97;
O.F[93,0]:=95;
O.F[93,1]:=102;
O.F[93,2]:=101;
O.F[93,3]:=96;
O.F[94,0]:=94;
O.F[94,1]:=103;
O.F[94,2]:=102;
O.F[94,3]:=95;
O.F[95,0]:=93;
O.F[95,1]:=104;
O.F[95,2]:=103;
O.F[95,3]:=94;
O.F[96,0]:=92;
O.F[96,1]:=105;
O.F[96,2]:=104;
O.F[96,3]:=93;
O.F[97,0]:=91;
O.F[97,1]:=106;
O.F[97,2]:=105;
O.F[97,3]:=92;
O.F[98,0]:=90;
O.F[98,1]:=107;
O.F[98,2]:=106;
O.F[98,3]:=91;
O.F[99,0]:=89;
O.F[99,1]:=108;
O.F[99,2]:=107;
O.F[99,3]:=90;
O.F[100,0]:=88;
O.F[100,1]:=109;
O.F[100,2]:=108;
O.F[100,3]:=89;
O.F[101,0]:=87;
O.F[101,1]:=110;
O.F[101,2]:=109;
O.F[101,3]:=88;
O.F[102,0]:=86;
O.F[102,1]:=111;
O.F[102,2]:=110;
O.F[102,3]:=87;
O.F[103,0]:=85;
O.F[103,1]:=112;
O.F[103,2]:=111;
O.F[103,3]:=86;
O.F[104,0]:=197;
O.F[104,1]:=112;
O.F[104,2]:=85;
O.F[105,0]:=197;
O.F[105,1]:=113;
O.F[105,2]:=112;
O.F[106,0]:=112;
O.F[106,1]:=113;
O.F[106,2]:=114;
O.F[106,3]:=111;
O.F[107,0]:=111;
O.F[107,1]:=114;
O.F[107,2]:=115;
O.F[107,3]:=110;
O.F[108,0]:=110;
O.F[108,1]:=115;
O.F[108,2]:=116;
O.F[108,3]:=109;
O.F[109,0]:=109;
O.F[109,1]:=116;
O.F[109,2]:=117;
O.F[109,3]:=108;
O.F[110,0]:=108;
O.F[110,1]:=117;
O.F[110,2]:=118;
O.F[110,3]:=107;
O.F[111,0]:=107;
O.F[111,1]:=118;
O.F[111,2]:=119;
O.F[111,3]:=106;
O.F[112,0]:=106;
O.F[112,1]:=119;
O.F[112,2]:=120;
O.F[112,3]:=105;
O.F[113,0]:=105;
O.F[113,1]:=120;
O.F[113,2]:=121;
O.F[113,3]:=104;
O.F[114,0]:=104;
O.F[114,1]:=121;
O.F[114,2]:=122;
O.F[114,3]:=103;
O.F[115,0]:=103;
O.F[115,1]:=122;
O.F[115,2]:=123;
O.F[115,3]:=102;
O.F[116,0]:=102;
O.F[116,1]:=123;
O.F[116,2]:=124;
O.F[116,3]:=101;
O.F[117,0]:=101;
O.F[117,1]:=124;
O.F[117,2]:=125;
O.F[117,3]:=100;
O.F[118,0]:=100;
O.F[118,1]:=125;
O.F[118,2]:=126;
O.F[118,3]:=99;
O.F[119,0]:=99;
O.F[119,1]:=126;
O.F[119,2]:=14;
O.F[120,0]:=126;
O.F[120,1]:=127;
O.F[120,2]:=14;
O.F[121,0]:=125;
O.F[121,1]:=128;
O.F[121,2]:=127;
O.F[121,3]:=126;
O.F[122,0]:=124;
O.F[122,1]:=129;
O.F[122,2]:=128;
O.F[122,3]:=125;
O.F[123,0]:=123;
O.F[123,1]:=130;
O.F[123,2]:=129;
O.F[123,3]:=124;
O.F[124,0]:=122;
O.F[124,1]:=131;
O.F[124,2]:=130;
O.F[124,3]:=123;
O.F[125,0]:=121;
O.F[125,1]:=132;
O.F[125,2]:=131;
O.F[125,3]:=122;
O.F[126,0]:=120;
O.F[126,1]:=133;
O.F[126,2]:=132;
O.F[126,3]:=121;
O.F[127,0]:=119;
O.F[127,1]:=134;
O.F[127,2]:=133;
O.F[127,3]:=120;
O.F[128,0]:=118;
O.F[128,1]:=135;
O.F[128,2]:=134;
O.F[128,3]:=119;
O.F[129,0]:=117;
O.F[129,1]:=136;
O.F[129,2]:=135;
O.F[129,3]:=118;
O.F[130,0]:=116;
O.F[130,1]:=137;
O.F[130,2]:=136;
O.F[130,3]:=117;
O.F[131,0]:=115;
O.F[131,1]:=138;
O.F[131,2]:=137;
O.F[131,3]:=116;
O.F[132,0]:=114;
O.F[132,1]:=139;
O.F[132,2]:=138;
O.F[132,3]:=115;
O.F[133,0]:=113;
O.F[133,1]:=140;
O.F[133,2]:=139;
O.F[133,3]:=114;
O.F[134,0]:=197;
O.F[134,1]:=140;
O.F[134,2]:=113;
O.F[135,0]:=197;
O.F[135,1]:=141;
O.F[135,2]:=140;
O.F[136,0]:=140;
O.F[136,1]:=141;
O.F[136,2]:=142;
O.F[136,3]:=139;
O.F[137,0]:=139;
O.F[137,1]:=142;
O.F[137,2]:=143;
O.F[137,3]:=138;
O.F[138,0]:=138;
O.F[138,1]:=143;
O.F[138,2]:=144;
O.F[138,3]:=137;
O.F[139,0]:=137;
O.F[139,1]:=144;
O.F[139,2]:=145;
O.F[139,3]:=136;
O.F[140,0]:=136;
O.F[140,1]:=145;
O.F[140,2]:=146;
O.F[140,3]:=135;
O.F[141,0]:=135;
O.F[141,1]:=146;
O.F[141,2]:=147;
O.F[141,3]:=134;
O.F[142,0]:=134;
O.F[142,1]:=147;
O.F[142,2]:=148;
O.F[142,3]:=133;
O.F[143,0]:=133;
O.F[143,1]:=148;
O.F[143,2]:=149;
O.F[143,3]:=132;
O.F[144,0]:=132;
O.F[144,1]:=149;
O.F[144,2]:=150;
O.F[144,3]:=131;
O.F[145,0]:=131;
O.F[145,1]:=150;
O.F[145,2]:=151;
O.F[145,3]:=130;
O.F[146,0]:=130;
O.F[146,1]:=151;
O.F[146,2]:=152;
O.F[146,3]:=129;
O.F[147,0]:=129;
O.F[147,1]:=152;
O.F[147,2]:=153;
O.F[147,3]:=128;
O.F[148,0]:=128;
O.F[148,1]:=153;
O.F[148,2]:=154;
O.F[148,3]:=127;
O.F[149,0]:=127;
O.F[149,1]:=154;
O.F[149,2]:=14;
O.F[150,0]:=154;
O.F[150,1]:=155;
O.F[150,2]:=14;
O.F[151,0]:=153;
O.F[151,1]:=156;
O.F[151,2]:=155;
O.F[151,3]:=154;
O.F[152,0]:=152;
O.F[152,1]:=157;
O.F[152,2]:=156;
O.F[152,3]:=153;
O.F[153,0]:=151;
O.F[153,1]:=158;
O.F[153,2]:=157;
O.F[153,3]:=152;
O.F[154,0]:=150;
O.F[154,1]:=159;
O.F[154,2]:=158;
O.F[154,3]:=151;
O.F[155,0]:=149;
O.F[155,1]:=160;
O.F[155,2]:=159;
O.F[155,3]:=150;
O.F[156,0]:=148;
O.F[156,1]:=161;
O.F[156,2]:=160;
O.F[156,3]:=149;
O.F[157,0]:=147;
O.F[157,1]:=162;
O.F[157,2]:=161;
O.F[157,3]:=148;
O.F[158,0]:=146;
O.F[158,1]:=163;
O.F[158,2]:=162;
O.F[158,3]:=147;
O.F[159,0]:=145;
O.F[159,1]:=164;
O.F[159,2]:=163;
O.F[159,3]:=146;
O.F[160,0]:=144;
O.F[160,1]:=165;
O.F[160,2]:=164;
O.F[160,3]:=145;
O.F[161,0]:=143;
O.F[161,1]:=166;
O.F[161,2]:=165;
O.F[161,3]:=144;
O.F[162,0]:=142;
O.F[162,1]:=167;
O.F[162,2]:=166;
O.F[162,3]:=143;
O.F[163,0]:=141;
O.F[163,1]:=168;
O.F[163,2]:=167;
O.F[163,3]:=142;
O.F[164,0]:=197;
O.F[164,1]:=168;
O.F[164,2]:=141;
O.F[165,0]:=197;
O.F[165,1]:=169;
O.F[165,2]:=168;
O.F[166,0]:=168;
O.F[166,1]:=169;
O.F[166,2]:=170;
O.F[166,3]:=167;
O.F[167,0]:=167;
O.F[167,1]:=170;
O.F[167,2]:=171;
O.F[167,3]:=166;
O.F[168,0]:=166;
O.F[168,1]:=171;
O.F[168,2]:=172;
O.F[168,3]:=165;
O.F[169,0]:=165;
O.F[169,1]:=172;
O.F[169,2]:=173;
O.F[169,3]:=164;
O.F[170,0]:=164;
O.F[170,1]:=173;
O.F[170,2]:=174;
O.F[170,3]:=163;
O.F[171,0]:=163;
O.F[171,1]:=174;
O.F[171,2]:=175;
O.F[171,3]:=162;
O.F[172,0]:=162;
O.F[172,1]:=175;
O.F[172,2]:=176;
O.F[172,3]:=161;
O.F[173,0]:=161;
O.F[173,1]:=176;
O.F[173,2]:=177;
O.F[173,3]:=160;
O.F[174,0]:=160;
O.F[174,1]:=177;
O.F[174,2]:=178;
O.F[174,3]:=159;
O.F[175,0]:=159;
O.F[175,1]:=178;
O.F[175,2]:=179;
O.F[175,3]:=158;
O.F[176,0]:=158;
O.F[176,1]:=179;
O.F[176,2]:=180;
O.F[176,3]:=157;
O.F[177,0]:=157;
O.F[177,1]:=180;
O.F[177,2]:=181;
O.F[177,3]:=156;
O.F[178,0]:=156;
O.F[178,1]:=181;
O.F[178,2]:=182;
O.F[178,3]:=155;
O.F[179,0]:=155;
O.F[179,1]:=182;
O.F[179,2]:=14;
O.F[180,0]:=182;
O.F[180,1]:=183;
O.F[180,2]:=14;
O.F[181,0]:=181;
O.F[181,1]:=184;
O.F[181,2]:=183;
O.F[181,3]:=182;
O.F[182,0]:=180;
O.F[182,1]:=185;
O.F[182,2]:=184;
O.F[182,3]:=181;
O.F[183,0]:=179;
O.F[183,1]:=186;
O.F[183,2]:=185;
O.F[183,3]:=180;
O.F[184,0]:=178;
O.F[184,1]:=187;
O.F[184,2]:=186;
O.F[184,3]:=179;
O.F[185,0]:=177;
O.F[185,1]:=188;
O.F[185,2]:=187;
O.F[185,3]:=178;
O.F[186,0]:=176;
O.F[186,1]:=189;
O.F[186,2]:=188;
O.F[186,3]:=177;
O.F[187,0]:=175;
O.F[187,1]:=190;
O.F[187,2]:=189;
O.F[187,3]:=176;
O.F[188,0]:=174;
O.F[188,1]:=191;
O.F[188,2]:=190;
O.F[188,3]:=175;
O.F[189,0]:=173;
O.F[189,1]:=192;
O.F[189,2]:=191;
O.F[189,3]:=174;
O.F[190,0]:=172;
O.F[190,1]:=193;
O.F[190,2]:=192;
O.F[190,3]:=173;
O.F[191,0]:=171;
O.F[191,1]:=194;
O.F[191,2]:=193;
O.F[191,3]:=172;
O.F[192,0]:=170;
O.F[192,1]:=195;
O.F[192,2]:=194;
O.F[192,3]:=171;
O.F[193,0]:=169;
O.F[193,1]:=196;
O.F[193,2]:=195;
O.F[193,3]:=170;
O.F[194,0]:=197;
O.F[194,1]:=196;
O.F[194,2]:=169;
O.F[195,0]:=197;
O.F[195,1]:=198;
O.F[195,2]:=196;
O.F[196,0]:=196;
O.F[196,1]:=198;
O.F[196,2]:=199;
O.F[196,3]:=195;
O.F[197,0]:=195;
O.F[197,1]:=199;
O.F[197,2]:=200;
O.F[197,3]:=194;
O.F[198,0]:=194;
O.F[198,1]:=200;
O.F[198,2]:=201;
O.F[198,3]:=193;
O.F[199,0]:=193;
O.F[199,1]:=201;
O.F[199,2]:=202;
O.F[199,3]:=192;
O.F[200,0]:=192;
O.F[200,1]:=202;
O.F[200,2]:=203;
O.F[200,3]:=191;
O.F[201,0]:=191;
O.F[201,1]:=203;
O.F[201,2]:=204;
O.F[201,3]:=190;
O.F[202,0]:=190;
O.F[202,1]:=204;
O.F[202,2]:=205;
O.F[202,3]:=189;
O.F[203,0]:=189;
O.F[203,1]:=205;
O.F[203,2]:=206;
O.F[203,3]:=188;
O.F[204,0]:=188;
O.F[204,1]:=206;
O.F[204,2]:=207;
O.F[204,3]:=187;
O.F[205,0]:=187;
O.F[205,1]:=207;
O.F[205,2]:=208;
O.F[205,3]:=186;
O.F[206,0]:=186;
O.F[206,1]:=208;
O.F[206,2]:=209;
O.F[206,3]:=185;
O.F[207,0]:=185;
O.F[207,1]:=209;
O.F[207,2]:=210;
O.F[207,3]:=184;
O.F[208,0]:=184;
O.F[208,1]:=210;
O.F[208,2]:=211;
O.F[208,3]:=183;
O.F[209,0]:=183;
O.F[209,1]:=211;
O.F[209,2]:=14;
O.F[210,0]:=211;
O.F[210,1]:=13;
O.F[210,2]:=14;
O.F[211,0]:=210;
O.F[211,1]:=12;
O.F[211,2]:=13;
O.F[211,3]:=211;
O.F[212,0]:=209;
O.F[212,1]:=11;
O.F[212,2]:=12;
O.F[212,3]:=210;
O.F[213,0]:=208;
O.F[213,1]:=10;
O.F[213,2]:=11;
O.F[213,3]:=209;
O.F[214,0]:=207;
O.F[214,1]:=9;
O.F[214,2]:=10;
O.F[214,3]:=208;
O.F[215,0]:=206;
O.F[215,1]:=8;
O.F[215,2]:=9;
O.F[215,3]:=207;
O.F[216,0]:=205;
O.F[216,1]:=7;
O.F[216,2]:=8;
O.F[216,3]:=206;
O.F[217,0]:=204;
O.F[217,1]:=6;
O.F[217,2]:=7;
O.F[217,3]:=205;
O.F[218,0]:=203;
O.F[218,1]:=5;
O.F[218,2]:=6;
O.F[218,3]:=204;
O.F[219,0]:=202;
O.F[219,1]:=4;
O.F[219,2]:=5;
O.F[219,3]:=203;
O.F[220,0]:=201;
O.F[220,1]:=3;
O.F[220,2]:=4;
O.F[220,3]:=202;
O.F[221,0]:=200;
O.F[221,1]:=2;
O.F[221,2]:=3;
O.F[221,3]:=201;
O.F[222,0]:=199;
O.F[222,1]:=1;
O.F[222,2]:=2;
O.F[222,3]:=200;
O.F[223,0]:=1;
O.F[223,1]:=199;
O.F[223,2]:=198;
O.F[223,3]:=0;
O.F[224,0]:=197;
O.F[224,1]:=0;
O.F[224,2]:=198;
end;

procedure Proga_Fracktal_Koh3D(const bool:boolean);
var
	Window:^GlSanWnd = nil;
	TR:array of array[1..4] of GlSanKoor;
	a,b,c,d:GlSanKoor;
	Det:longint = 6;
	Zum,LeftZum,UpZum,r1,r2:real;
	i:longint;
procedure Rec(const t1,t2,t3,t4:GlSanKoor; const l:longint);
var a:array [1..6] of GlSanKoor;
begin
a[1]:=t1;
a[1].Togever(t4);
a[1].Zum(0.5);

a[2]:=t4;
a[2].Togever(t2);
a[2].Zum(0.5);

a[3]:=t4;
a[3].Togever(t3);
a[3].Zum(0.5);

a[4]:=t1;
a[4].Togever(t2);
a[4].Zum(0.5);

a[6]:=t1;
a[6].Togever(t3);
a[6].Zum(0.5);

a[5]:=t3;
a[5].Togever(t2);
a[5].Zum(0.5);

if l>1 then
	begin
	REC(t1,a[4],a[6],a[1],l-1);
	REC(t2,a[4],a[5],a[2],l-1);
	REC(t3,a[3],a[6],a[5],l-1);
	REC(t4,a[3],a[2],a[1],l-1);
	end
else

	begin
	SetLength(TR,Length(tR)+1);
	TR[High(TR),1]:=t1;
	TR[High(TR),2]:=t2;
	TR[High(TR),3]:=t3;
	TR[High(TR),4]:=t4;
	end;
end;

begin
GlSanCreateWnd(@Window,'Управление',GlSanKoor2fImport(130,170));
GlSanWndNewButton(@Window,GlSanKoor2fImport(10,50),GlSanKoor2fImport(60,100),'+');
GlSanWndNewButton(@Window,GlSanKoor2fImport(70,50),GlSanKoor2fImport(120,100),'-');
GlSanWndNewText(@Window,GlSanKoor2fImport(10,110),GlSanKoor2fImport(120,160),' ');
GlSanWndUserMove(@Window,3,GlSanKoor2fImport(width-10,0));
GlSanWndSetNewTittleText(@Window,1,GlSanStr(Det));
a.Import(0,3,0);
b.Import(cos(pi+pi/6)*3,sin(pi+pi/6)*3,0);
c.Import(cos(2*pi-pi/6)*3,sin(2*pi-pi/6)*3,0);
d.Import(0,0,3);
a.Zum(9/10);b.Zum(9/10);c.Zum(9/10);d.Zum(9/10);
SetLength(TR,0);
REC(a,b,c,d,det);
r1:=0;r2:=0;Zum:=1;Upzum:=0;LeftZum:=0;
repeat
gltranslatef(LeftZum,UpZum,-6*Zum);
glrotatef(r2,1,0,0);
glrotatef(r1,0,0,1);
glcolor4f(0,1,1,0.4);
if GlSanWndClickButton(@Window,1) then
	begin
	Det:=Det+1;
	SetLength(TR,0);
	REC(a,b,c,d,det);
	GlSanWndSetNewTittleText(@Window,1,GlSanStr(Det));
	end;
if GlSanWndClickButton(@Window,2) and (Det>2) then
	begin
	Det:=Det-1;
	SetLength(TR,0);
	REC(a,b,c,d,det);
	GlSanWndSetNewTittleText(@Window,1,GlSanStr(Det));
	end;
for i:=High(TR) downto Low(TR) do
	begin
	GlBegin(GL_TRIANGLES);
	GlSanVertex3f(TR[i,1]);
	GlSanVertex3f(TR[i,2]);
	GlSanVertex3f(TR[i,3]);

	GlSanVertex3f(TR[i,2]);
	GlSanVertex3f(TR[i,3]);
	GlSanVertex3f(TR[i,4]);

	GlSanVertex3f(TR[i,1]);
	GlSanVertex3f(TR[i,2]);
	GlSanVertex3f(TR[i,4]);

	GlSanVertex3f(TR[i,1]);
	GlSanVertex3f(TR[i,3]);
	GlSanVertex3f(TR[i,4]);
	glEnd();
	end;
if GlSanMouseB(3) then
	begin
	R1-=GlSanMouseXY(1).x/3;
	R2-=GlSanMouseXY(1).y/3;
	end;
if GlSanMouseB(1) then
		begin
		UpZum+=GlSanMouseXY(1).y/(170);
		LeftZum-=GlSanMouseXY(1).x/(170);
		end;
case LongInt(SGMouseWheelVariable) of
1:Zum+=0.05;
-1:Zum-=0.05;
end;
until GlSanAfterUntil(27,false,bool);
SetLength(TR,0);
GlSanKillWnd(@Window);
end;

procedure Proga_BOP(const bool:boolean);
var
	rx,ry:real;
	x,y:real;
	k:longint = 100;
	LW:real=0.3;
	Wnd:^GlSanWnd = nil;
	i:longint;
begin
GlSanCreateWnd(@Wnd,'Управление',GlSanKoor2fImport(130,290));
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(10,50),GlSanKoor2fImport(60,100),'+');
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(70,50),GlSanKoor2fImport(120,100),'-');
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(10,170),GlSanKoor2fImport(60,220),'LW+');
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(70,170),GlSanKoor2fImport(120,220),'LW-');
GlSanWndNewText(@Wnd,GlSanKoor2fImport(10,110),GlSanKoor2fImport(120,160),' ');
GlSanWndNewText(@Wnd,GlSanKoor2fImport(10,230),GlSanKoor2fImport(120,280),' ');
Wnd^.ArButtons[0].SetOnOn:=true;
Wnd^.ArButtons[1].SetOnOn:=true;
GlSanWndUserMove(@Wnd,3,GlSanKoor2fImport(width-10,0));
GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(k));
GlSanWndSetNewTittleText(@Wnd,2,GlSanStrReal(LW,3));
rx:=abs(GlSanWA[GlSanWAKol,1].x-GlSanWA[GlSanWAKol,3].x);
ry:=abs(GlSanWA[GlSanWAKol,1].y-GlSanWA[GlSanWAKol,3].y);
rx:=rx/k;
ry:=ry/k;
repeat
gltranslatef(0,0,-6);
glcolor4f(0,1,1,0.8);
gllinewidth(LW);
x:=0;
y:=0;
for i:=1 to k do
	begin
	glcolor4f(0,0.01*i,100/i,0.8);
	glBegin(GL_LINES);
	glvertex3f(GlsanWA[GlSanWAKol,1].x+x,GlSanWA[GlSanWAKol,1].y,GlSanWA[GlSanWAKol,1].z);
	glvertex3f(GlsanWA[GlSanWAKol,4].x,GlSanWA[GlSanWAKol,4].y+y,GlSanWA[GlSanWAKol,1].z);

	glvertex3f(GlsanWA[GlSanWAKol,3].x-x,GlSanWA[GlSanWAKol,3].y,GlSanWA[GlSanWAKol,1].z);
	glvertex3f(GlsanWA[GlSanWAKol,4].x,GlSanWA[GlSanWAKol,4].y+y,GlSanWA[GlSanWAKol,1].z);

	glvertex3f(GlsanWA[GlSanWAKol,1].x+x,GlSanWA[GlSanWAKol,1].y,GlSanWA[GlSanWAKol,1].z);
	glvertex3f(GlsanWA[GlSanWAKol,2].x,GlSanWA[GlSanWAKol,2].y-y,GlSanWA[GlSanWAKol,1].z);

	glvertex3f(GlsanWA[GlSanWAKol,3].x-x,GlSanWA[GlSanWAKol,3].y,GlSanWA[GlSanWAKol,1].z);
	glvertex3f(GlsanWA[GlSanWAKol,2].x,GlSanWA[GlSanWAKol,2].y-y,GlSanWA[GlSanWAKol,1].z);
	x+=rx;
	y+=ry;
	glEnd();
	end;
if GlSanWndClickButton(@Wnd,1) then
	begin
	k+=3;
	rx:=abs(GlSanWA[GlSanWAKol,1].x-GlSanWA[GlSanWAKol,3].x);
	ry:=abs(GlSanWA[GlSanWAKol,1].y-GlSanWA[GlSanWAKol,3].y);
	rx:=rx/k;
	ry:=ry/k;
	GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(k));
	end;
if GlSanWndClickButton(@Wnd,2) and (k>=4) then
	begin
	k+=-3;
	rx:=abs(GlSanWA[GlSanWAKol,1].x-GlSanWA[GlSanWAKol,3].x);
	ry:=abs(GlSanWA[GlSanWAKol,1].y-GlSanWA[GlSanWAKol,3].y);
	rx:=rx/k;
	ry:=ry/k;
	GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(k));
	end;
if GlSanWndClickButton(@Wnd,3)and (LW<2) then
	begin
	LW+=0.05;
	GlSanWndSetNewTittleText(@Wnd,2,GlSanStrReal(LW,3));
	end;
if GlSanWndClickButton(@Wnd,4) and (LW>0.1) then
	begin
	LW-=0.05;
	GlSanWndSetNewTittleText(@Wnd,2,GlSanStrReal(LW,3));
	end;
until GlSanAfterUntil(27,false,bool);
GlSanKillWnd(@Wnd);
end;

procedure Proga_Koh_Cub(const bool:boolean);
type
	ArQuad=array[1..8] of GlSanKoor;
var
	Wnd:^GlSanWnd=nil;
	TR:array of ArQuad;
	CR:array of GlSanColor4f;
	a:ArQuad;
	Det:longint = 3;
	Prozr:boolean=true;
	zum,r1,r2,upzum,leftzum:real;
	angle1,angle2:real;
	past_light:array[0..3]of glfloat;
	i:longint;
procedure Rec(const a:ArQuad; const l:longint);
var b:array [1..56] of GlSanKoor;
	t:GlSanKoor;
	c:ArQuad;
	i:longint;
begin
if l>1 then
	begin
	t:=a[8];t.Togever(a[2]);t.Togever(a[8]);t.Zum(1/3);b[18]:=t;
	t:=a[8];t.Togever(a[2]);t.Togever(a[2]);t.Zum(1/3);b[39]:=t;
	b[1].Import(b[18].x,a[4].y,a[6].z);b[2].Import(b[39].x,a[4].y,a[6].z);
	b[3].Import(a[8].x,a[4].y,b[18].z);b[4].Import(b[18].x,a[4].y,b[18].z);
	b[5].Import(b[39].x,a[4].y,b[18].z);b[6].Import(a[6].x,a[4].y,b[18].z);
	b[7].Import(a[8].x,a[4].y,b[39].z);b[8].Import(b[18].x,a[4].y,b[39].z);
	b[9].Import(b[39].x,a[4].y,b[39].z);b[10].Import(a[6].x,a[4].y,b[39].z);
	b[11].Import(b[18].x,a[4].y,a[2].z);b[12].Import(b[39].x,a[4].y,a[2].z);
	b[13].Import(a[8].x,b[18].y,a[8].z);b[14].Import(b[18].x,b[18].y,a[8].z);
	b[15].Import(b[39].x,b[18].y,a[8].z);b[16].Import(a[6].x,b[18].y,a[8].z);
	b[17].Import(a[8].x,b[18].y,b[18].z);b[18].Import(b[18].x,b[18].y,b[18].z);
	b[19].Import(b[39].x,b[18].y,b[18].z);b[20].Import(a[6].x,b[18].y,b[18].z);
	b[21].Import(a[8].x,b[18].y,b[39].z);b[22].Import(b[18].x,b[18].y,b[39].z);
	b[23].Import(b[39].x,b[18].y,b[39].z);b[24].Import(a[6].x,b[18].y,b[39].z);
	b[28].Import(a[8].x,b[18].y,a[4].z);b[25].Import(b[18].x,b[18].y,a[4].z);
	b[26].Import(b[39].x,b[18].y,a[4].z);b[27].Import(a[6].x,b[18].y,a[4].z);
	b[29].Import(a[8].x,b[39].y,a[8].z);b[30].Import(b[18].x,b[39].y,a[8].z);
	b[31].Import(b[39].x,b[39].y,a[8].z);b[32].Import(a[6].x,b[39].y,a[8].z);
	b[33].Import(a[8].x,b[39].y,b[18].z);b[34].Import(b[18].x,b[39].y,b[18].z);
	b[35].Import(b[39].x,b[39].y,b[18].z);b[36].Import(a[6].x,b[39].y,b[18].z);
	b[37].Import(a[8].x,b[39].y,b[39].z);b[38].Import(b[18].x,b[39].y,b[39].z);
	b[39].Import(b[39].x,b[39].y,b[39].z);b[40].Import(a[6].x,b[39].y,b[39].z);
	b[41].Import(a[8].x,b[39].y,a[4].z);b[42].Import(b[18].x,b[39].y,a[4].z);
	b[43].Import(b[39].x,b[39].y,a[4].z);b[44].Import(a[6].x,b[39].y,a[4].z);
	b[45].Import(b[18].x,a[6].y,a[6].z);b[46].Import(b[39].x,a[6].y,a[6].z);
	b[47].Import(a[8].x,a[6].y,b[18].z);b[48].Import(b[18].x,a[6].y,b[18].z);
	b[49].Import(b[39].x,a[6].y,b[18].z);b[50].Import(a[6].x,a[6].y,b[18].z);
	b[51].Import(a[8].x,a[6].y,b[39].z);b[52].Import(b[18].x,a[6].y,b[39].z);
	b[53].Import(b[39].x,a[6].y,b[39].z);b[54].Import(a[6].x,a[6].y,b[39].z);
	b[55].Import(b[18].x,a[6].y,a[2].z);b[56].Import(b[39].x,a[6].y,a[2].z);
	c[1]:=b[19];c[2]:=b[20];c[3]:=b[6];c[4]:=b[5];c[5]:=b[15];c[6]:=b[16];c[7]:=a[7];c[8]:=b[2];Rec(c,l-1);
	c[1]:=b[18];c[2]:=b[19];c[3]:=b[5];c[4]:=b[4];c[5]:=b[14];c[6]:=b[15];c[7]:=b[2];c[8]:=b[1];Rec(c,l-1);
	c[1]:=b[17];c[2]:=b[18];c[3]:=b[4];c[4]:=b[3];c[5]:=b[13];c[6]:=b[14];c[7]:=b[1];c[8]:=a[8];Rec(c,l-1);
	c[1]:=b[35];c[2]:=b[36];c[3]:=b[20];c[4]:=b[19];c[5]:=b[31];c[6]:=b[32];c[7]:=b[16];c[8]:=b[15];Rec(c,l-1);
	c[1]:=b[33];c[2]:=b[34];c[3]:=b[18];c[4]:=b[17];c[5]:=b[29];c[6]:=b[30];c[7]:=b[14];c[8]:=b[13];Rec(c,l-1);
	c[1]:=b[49];c[2]:=b[50];c[3]:=b[36];c[4]:=b[35];c[5]:=b[46];c[6]:=a[6];c[7]:=b[32];c[8]:=b[31];Rec(c,l-1);
	c[1]:=b[48];c[2]:=b[49];c[3]:=b[35];c[4]:=b[34];c[5]:=b[45];c[6]:=b[46];c[7]:=b[31];c[8]:=b[30];Rec(c,l-1);
	c[1]:=b[47];c[2]:=b[48];c[3]:=b[34];c[4]:=b[33];c[5]:=a[5];c[6]:=b[45];c[7]:=b[30];c[8]:=b[29];Rec(c,l-1);
	c[1]:=b[23];c[2]:=b[24];c[3]:=b[10];c[4]:=b[9];c[5]:=b[19];c[6]:=b[20];c[7]:=b[6];c[8]:=b[5];Rec(c,l-1);
	c[1]:=b[21];c[2]:=b[22];c[3]:=b[8];c[4]:=b[7];c[5]:=b[17];c[6]:=b[18];c[7]:=b[4];c[8]:=b[3];Rec(c,l-1);
	c[1]:=b[51];c[2]:=b[52];c[3]:=b[38];c[4]:=b[37];c[5]:=b[47];c[6]:=b[48];c[7]:=b[34];c[8]:=b[33];Rec(c,l-1);
	c[1]:=b[53];c[2]:=b[54];c[3]:=b[40];c[4]:=b[39];c[5]:=b[49];c[6]:=b[50];c[7]:=b[36];c[8]:=b[35];Rec(c,l-1);
	c[1]:=b[26];c[2]:=b[27];c[3]:=a[3];c[4]:=b[12];c[5]:=b[23];c[6]:=b[24];c[7]:=b[10];c[8]:=b[9];Rec(c,l-1);
	c[1]:=b[25];c[2]:=b[26];c[3]:=b[12];c[4]:=b[11];c[5]:=b[22];c[6]:=b[23];c[7]:=b[9];c[8]:=b[8];Rec(c,l-1);
	c[1]:=b[28];c[2]:=b[25];c[3]:=b[11];c[4]:=a[4];c[5]:=b[21];c[6]:=b[22];c[7]:=b[8];c[8]:=b[7];Rec(c,l-1);
	c[1]:=b[43];c[2]:=b[44];c[3]:=b[27];c[4]:=b[26];c[5]:=b[39];c[6]:=b[40];c[7]:=b[24];c[8]:=b[23];Rec(c,l-1);
	c[1]:=b[41];c[2]:=b[42];c[3]:=b[25];c[4]:=b[28];c[5]:=b[37];c[6]:=b[38];c[7]:=b[22];c[8]:=b[21];Rec(c,l-1);
	c[1]:=b[56];c[2]:=a[2];c[3]:=b[44];c[4]:=b[43];c[5]:=b[53];c[6]:=b[54];c[7]:=b[40];c[8]:=b[39];Rec(c,l-1);
	c[1]:=b[55];c[2]:=b[56];c[3]:=b[43];c[4]:=b[42];c[5]:=b[52];c[6]:=b[53];c[7]:=b[39];c[8]:=b[38];Rec(c,l-1);
	c[1]:=a[1];c[2]:=b[55];c[3]:=b[42];c[4]:=b[41];c[5]:=b[51];c[6]:=b[52];c[7]:=b[38];c[8]:=b[37];Rec(c,l-1);
	end
else

	begin
	SetLength(TR,Length(tR)+1);
	SetLength(CR,Length(CR)+1);
	TR[High(TR)]:=a;
	t:=a[1];
	for i:=2 to 8 do
		t.Togever(a[i]);
	t.Zum(1/8);
	t.Togever(GlSanKoorImport(1,1,1));
	CR[High(CR)].Import(t.x/2,t.y/2,t.z/2,(t.x+t.y+t.z)/6);
	end;
end;


begin
GlSanCreateWnd(@Wnd,'Управление',GlSanKoor2fImport(410,110));
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(10,50),GlSanKoor2fImport(60,100),'+');
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(70,50),GlSanKoor2fImport(120,100),'-');
GlSanWndNewText(@Wnd,GlSanKoor2fImport(130,50),GlSanKoor2fImport(180,100),' ');
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(190,50),GlSanKoor2fImport(320,100),'Вкл/Откл Прозрачность');
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(330,50),GlSanKoor2fImport(400,100),'Выход');
GlSanWndUserMove(@Wnd,3,GlSanKoor2fImport(0,height-10));
GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(Det));
fillchar(a,sizeof(a),0);
a[1].Import(-1,-1,1);
a[2].Import(1,-1,1);
a[3].Import(1,1,1);
a[4].Import(-1,1,1);
a[5].Import(-1,-1,-1);
a[6].Import(1,-1,-1);
a[7].Import(1,1,-1);
a[8].Import(-1,1,-1);
SetLength(TR,0);
SetLength(CR,0);
REC(a,det);
zum:=1;r1:=0;r2:=0;upzum:=0;leftzum:=0;
past_light[0]:=LightPosition[0];
past_light[1]:=LightPosition[1];
past_light[2]:=LightPosition[2];
past_light[3]:=LightPosition[3];
angle1:=0;
angle2:=0;
repeat
LightPosition[0]:=cos(angle1)*3;
LightPosition[1]:=sin(angle1)*3;
LightPosition[2]:=-sin(angle2)*3;
angle1+=0.02;
angle2+=0.03;
glLightfv(GL_LIGHT0,GL_POSITION,@LightPosition);
gltranslatef(leftzum,upzum,-6*Zum);
glrotatef(r2,1,0,0);
glrotatef(r1,0,0,1);
glcolor4f(0,0.5,0.5,0.2);
if GlSanWndClickButton(@Wnd,3) then
	begin
	Prozr:=not Prozr;
	end;
if GlSanWndClickButton(@Wnd,1) then
	begin
	Det:=Det+1;
	SetLength(TR,0);
	SetLength(CR,0);
	REC(a,det);
	GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(Det));
	end;
if GlSanWndClickButton(@Wnd,2) and (Det>1) then
	begin
	Det:=Det-1;
	SetLength(TR,0);
	SetLength(CR,0);
	REC(a,det);
	GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(Det));
	end;
glcolor3f(1,1,1);
GlSanSphere(GlSanKoorImport(LightPosition[0],LightPosition[1],LightPosition[2]),0.2);
for i:=High(TR) downto Low(TR)  do
	begin
	if Prozr then CR[i].SanSetColor else CR[i].SanSetColor3f;
	glnormal3f(0,0,1);
		GlSanQuad(TR[i,1],TR[i,2],TR[i,3],TR[i,4]);
		glnormal3f(0,0,-1);
		GlSanQuad(TR[i,5],TR[i,6],TR[i,7],TR[i,8]);
		glnormal3f(-1,0,0);
		GlSanQuad(TR[i,1],TR[i,4],TR[i,8],TR[i,5]);
		glnormal3f(1,0,0);
		GlSanQuad(TR[i,6],TR[i,7],TR[i,3],TR[i,2]);
		glnormal3f(0,-1,0);
		GlSanQuad(TR[i,1],TR[i,2],TR[i,6],TR[i,5]);
		glnormal3f(0,1,0);
		GlSanQuad(TR[i,8],TR[i,7],TR[i,3],TR[i,4]);
	end;
if GlSanMouseB(3) then
	begin
	R1-=GlSanMouseXY(1).x/3;
	R2-=GlSanMouseXY(1).y/3;
	end;
if GlSanMouseB(1) then
	begin
	UpZum+=GlSanMouseXY(1).y/(170);
	LeftZum-=GlSanMouseXY(1).x/(170);
	end;
case LongInt(SGMouseWheelVariable) of
1:Zum+=0.05;
-1:Zum-=0.05;
end;
until GlSanAfterUntil(27,GlSanWndClickButton(@Wnd,4),bool);
SetLength(TR,0);
SetLength(CR,0);
GlSanKillWnd(@Wnd);
LightPosition[0]:=past_light[0];
LightPosition[1]:=past_light[1];
LightPosition[2]:=past_light[2];
LightPosition[3]:=past_light[3];
end;

procedure Proga_Koh_Kover(const bool:boolean);
var
	Wnd:^GlSanWnd=nil;
	TR:array of array[1..4] of GlSanKoor;
	a,b,c,d:GlSanKoor;
	Det:longint = 2;
	TV:boolean=true;
	zum,r1,r2,upzum,leftzum:real;
	i:longint;
procedure Rec(const t1,t2,t3,t4:GlSanKoor; const l:longint);
var a:array [1..12] of GlSanKoor;
begin
fillchar(a,sizeof(a),0);
a[4].x:=(t1.x+(1/2)*t3.x)/(3/2);a[4].y:=(t1.y+(1/2)*t3.y)/(3/2);
a[9].x:=(t3.x+(1/2)*t1.x)/(3/2);a[9].y:=(t3.y+(1/2)*t1.y)/(3/2);
a[1].x:=a[4].x;a[1].y:=t1.y;a[2].x:=a[9].x;a[2].y:=t1.y;
a[3].x:=t1.x;a[3].y:=a[4].y;a[5].x:=a[9].x;a[5].y:=a[4].y;
a[6].x:=t4.x;a[6].y:=a[4].y;a[7].x:=t1.x;a[7].y:=a[9].y;
a[8].x:=a[4].x;a[8].y:=a[9].y;a[10].x:=t4.x;a[10].y:=a[9].y;
a[11].x:=a[4].x;a[11].y:=t2.y;a[12].x:=a[9].x;a[12].y:=t3.y;
if l>1 then
	begin
	REC(t1,a[3],a[4],a[1],l-1);REC(a[7],t2,a[11],a[8],l-1);
	REC(a[9],a[12],t3,a[10],l-1);REC(a[2],a[5],a[6],t3,l-1);
	REC(a[1],a[4],a[5],a[2],l-1);REC(a[3],a[7],a[8],a[4],l-1);
	REC(a[8],a[11],a[12],a[9],l-1);REC(a[5],a[9],a[10],a[6],l-1);
	end
else

	begin
	SetLength(TR,Length(tR)+1);
	TR[High(TR),1]:=a[4];TR[High(TR),2]:=a[5];
	TR[High(TR),3]:=a[9];TR[High(TR),4]:=a[8];
	end;
end;
begin
GlSanCreateWnd(@Wnd,'Управление',GlSanKoor2fImport(130,220));
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(10,50),GlSanKoor2fImport(60,100),'+');
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(70,50),GlSanKoor2fImport(120,100),'-');
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(10,170),GlSanKoor2fImport(120,210),'Тип Вывода');
GlSanWndNewText(@Wnd,GlSanKoor2fImport(10,110),GlSanKoor2fImport(120,160),' ');
GlSanWndUserMove(@Wnd,3,GlSanKoor2fImport(width-10,0));
GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(Det));
a.Import(-3,-3,0);
b.Import(-3,3,0);
c.Import(3,3,0);
d.Import(3,-3,0);
SetLength(TR,0);
REC(a,b,c,d,det);
zum:=1;r1:=0;r2:=0;upzum:=0;leftzum:=0;
repeat
gltranslatef(leftzum,upzum,-6*Zum);
glrotatef(r2,1,0,0);
glrotatef(r1,0,0,1);
glcolor4f(0,1,1,0.8);
if GlSanWndClickButton(@Wnd,3) then
	begin
	TV:=not TV;
	end;
if GlSanWndClickButton(@Wnd,1) then
	begin
	Det:=Det+1;
	SetLength(TR,0);
	REC(a,b,c,d,det);
	GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(Det));
	end;
if GlSanWndClickButton(@Wnd,2) and (Det>1) then
	begin
	Det:=Det-1;
	SetLength(TR,0);
	REC(a,b,c,d,det);
	GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(Det));
	end;
for i:=High(TR) downto Low(TR)  do
	begin
	if TV then
		begin
		GlBegin(GL_line_STRIP);
		GlSanVertex3f(TR[i,1]);
		GlSanVertex3f(TR[i,2]);
		GlSanVertex3f(TR[i,3]);
		GlSanVertex3f(TR[i,4]);
		GlSanVertex3f(TR[i,1]);
		glEnd();
		end
	else
		GlSanQuad(TR[i,1],TR[i,2],TR[i,3],TR[i,4]);
	end;
if GlSanMouseB(3) then
	begin
	R1-=GlSanMouseXY(1).x/3;
	R2-=GlSanMouseXY(1).y/3;
	end;
if GlSanMouseB(1) then
	begin
	UpZum+=GlSanMouseXY(1).y/(170);
	LeftZum-=GlSanMouseXY(1).x/(170);
	end;
case LongInt(SGMouseWheelVariable) of
1:Zum+=0.05;
-1:Zum-=0.05;
end;
until GlSanAfterUntil(27,false,bool);
SetLength(TR,0);
GlSanKillWnd(@Wnd);
end;

procedure Proga_Koh_Puram4(const bool:boolean);
var
	Wnd:^GlSanWnd=nil;
	TR:array of array[1..5] of GlSanKoor;
	CR:array of GlSanColor3f;
	a,b,c,d,e:GlSanKoor;
	Det:longint = 6;
	zum,r1,r2,upzum,leftzum:real;
	TV:boolean=false;
	t:GlSanKoor;
	i:longint;
procedure Rec(const t1,t2,t3,t4,t5:GlSanKoor; const l:longint);
var a:array [1..9] of GlSanKoor;
	t:GlSanKoor;
begin
a[1]:=t1;a[1].Togever(t5);a[1].Zum(0.5);a[2]:=t2;a[2].Togever(t5);a[2].Zum(0.5);
a[3]:=t3;a[3].Togever(t5);a[3].Zum(0.5);a[4]:=t4;a[4].Togever(t5);a[4].Zum(0.5);
a[5]:=t1;a[5].Togever(t2);a[5].Zum(0.5);a[6]:=t2;a[6].Togever(t3);a[6].Zum(0.5);
a[7]:=t4;a[7].Togever(t3);a[7].Zum(0.5);a[8]:=t1;a[8].Togever(t4);a[8].Zum(0.5);
a[9]:=a[5];a[9].Togever(a[7]);a[9].Zum(0.5);
if l>1 then
	begin
	REC(t1,a[5],a[9],a[8],a[1],l-1);REC(t2,a[6],a[9],a[5],a[2],l-1);
	REC(t3,a[7],a[9],a[6],a[3],l-1);REC(t4,a[8],a[9],a[7],a[4],l-1);
	REC(a[1],a[2],a[3],a[4],t5,l-1);
	end
else
	begin
	SetLength(TR,Length(TR)+1);SetLength(CR,Length(CR)+1);
	TR[High(TR),1]:=t1;TR[High(TR),2]:=t2;
	TR[High(TR),3]:=t3;TR[High(TR),4]:=t4;
	TR[High(TR),5]:=t5;
	t:=t1;t.Togever(t2);t.Togever(t3);t.Togever(t4);t.Togever(t5);t.Zum(0.2);
	T.Togever(GlSanKoorImport(3,3,0));T.Zum(1/6);t.z*=3;CR[High(TR)]:=T;
	end;
end;


begin
gldisable(GL_LIGHTING);
GlSanCreateWnd(@Wnd,'Управление',GlSanKoor2fImport(130,220));
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(10,50),GlSanKoor2fImport(60,100),'+');
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(70,50),GlSanKoor2fImport(120,100),'-');
GlSanWndNewText(@Wnd,GlSanKoor2fImport(10,110),GlSanKoor2fImport(120,160),' ');
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(10,170),GlSanKoor2fImport(120,210),'Тип Вывода');
GlSanWndUserMove(@Wnd,3,GlSanKoor2fImport(width-10,0));
GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(Det));
a.Import(0,3,0);
b.Import(3,0,0);
c.Import(0,-3,0);
d.Import(-3,0,0);
e.Import(0,0,3);
SetLength(TR,0);
SetLength(CR,0);
REC(a,b,c,d,e,det);
zum:=1;r1:=0;r2:=0;upzum:=0;leftzum:=0;
repeat
gltranslatef(leftzum,upzum,-6*Zum);
glrotatef(r2,1,0,0);
glrotatef(r1,0,0,1);
if GlSanWndClickButton(@Wnd,3) then
	TV:=not TV;
if GlSanWndClickButton(@Wnd,1) then
	begin
	Det:=Det+1;
	SetLength(TR,0);
	SetLength(CR,0);
	REC(a,b,c,d,e,det);
	GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(Det));
	end;
if GlSanWndClickButton(@Wnd,2) and (Det>1) then
	begin
	Det:=Det-1;
	SetLength(TR,0);
	SetLength(CR,0);
	REC(a,b,c,d,e,det);
	GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(Det));
	end;
for i:=High(TR) downto Low(TR)  do
	begin
	CR[i].SanSetColor;GlBegin(GL_TRIANGLES);
	GlSanVertex3f(TR[i,1]);GlSanVertex3f(TR[i,2]);GlSanVertex3f(TR[i,5]);
	GlSanVertex3f(TR[i,2]);GlSanVertex3f(TR[i,3]);GlSanVertex3f(TR[i,5]);
	GlSanVertex3f(TR[i,3]);GlSanVertex3f(TR[i,4]);GlSanVertex3f(TR[i,5]);
	GlSanVertex3f(TR[i,4]);GlSanVertex3f(TR[i,1]);GlSanVertex3f(TR[i,5]);
	glEnd();GlBegin(GL_quads);GlSanVertex3f(TR[i,1]);GlSanVertex3f(TR[i,2]);
	GlSanVertex3f(TR[i,3]);GlSanVertex3f(TR[i,4]);glEnd();
	if TV then
		begin
		t:=CR[i];t.Zum(1/1.5);T.SanSetColor;GlBegin(GL_lines);
		GlSanVertex3f(TR[i,1]);	GlSanVertex3f(TR[i,2]);
		GlSanVertex3f(TR[i,2]);	GlSanVertex3f(TR[i,3]);
		GlSanVertex3f(TR[i,3]);	GlSanVertex3f(TR[i,4]);
		GlSanVertex3f(TR[i,4]);	GlSanVertex3f(TR[i,1]);
		GlSanVertex3f(TR[i,1]);	GlSanVertex3f(TR[i,5]);
		GlSanVertex3f(TR[i,5]);	GlSanVertex3f(TR[i,2]);
		GlSanVertex3f(TR[i,3]);	GlSanVertex3f(TR[i,5]);
		GlSanVertex3f(TR[i,4]);	GlSanVertex3f(TR[i,5]);
		glend();
		end;
	end;
if GlSanMouseB(3) then
	begin
	R1-=GlSanMouseXY(1).x/3;
	R2-=GlSanMouseXY(1).y/3;
	end;
if GlSanMouseB(1) then
	begin
	UpZum+=GlSanMouseXY(1).y/(170);
	LeftZum-=GlSanMouseXY(1).x/(170);
	end;
case LongInt(SGMouseWheelVariable) of
1:Zum+=0.05;
-1:Zum-=0.05;
end;
until GlSanAfterUntil(27,false,bool);
SetLength(CR,0);
SetLength(TR,0);
glEnable(GL_LIGHTING);
GlSanKillWnd(@Wnd);
end;

procedure Proga_Koh_5U(const bool:boolean);
type
	ArQuad=array[1..5] of GlSanKoor;
var
	Wnd:^GlSanWnd = nil;
	TR:array of ArQuad;
	a:ArQuad;
	Det:longint = 7;
	Zum,LeftZum,UpZum,r1,r2:real;
	VT:boolean=false;
	VCCCP:boolean=false;
	i:longint;
procedure Rec(const a:ArQuad; const l:longint);
var b:array[1..10] of GlSanKoor;
	c:ArQuad;
begin
if l>1 then
	begin
	b[1]:=a[2];b[1].Togever(a[1]);b[1].Zum(1/2);
	b[2]:=a[3];b[2].Togever(a[2]);b[2].Zum(1/2);
	b[3]:=a[4];b[3].Togever(a[3]);b[3].Zum(1/2);
	b[4]:=a[5];b[4].Togever(a[4]);b[4].Zum(1/2);
	b[5]:=a[1];b[5].Togever(a[5]);b[5].Zum(1/2);
	B[6]:=GlSanLineCross(a[1],a[3],a[2],a[5]);
	B[7]:=GlSanLineCross(a[1],a[3],a[2],a[4]);
	B[8]:=GlSanLineCross(a[5],a[3],a[2],a[4]);
	B[9]:=GlSanLineCross(a[1],a[4],a[3],a[5]);
	B[10]:=GlSanLineCross(a[1],a[4],a[2],a[5]);
	c[1]:=a[2];c[2]:=b[2];c[3]:=b[7];c[4]:=b[6];c[5]:=b[1];rec(c,l-1);
	c[1]:=b[1];c[2]:=b[6];c[3]:=b[10];c[4]:=b[5];c[5]:=a[1];rec(c,l-1);
	c[1]:=a[5];c[2]:=b[5];c[3]:=b[10];c[4]:=b[9];c[5]:=b[4];rec(c,l-1);
	c[1]:=a[4];c[2]:=b[4];c[3]:=b[9];c[4]:=b[8];c[5]:=b[3];rec(c,l-1);
	c[1]:=a[3];c[2]:=b[3];c[3]:=b[8];c[4]:=b[7];c[5]:=b[2];rec(c,l-1);
	if VT then begin c[1]:=b[10];c[2]:=b[9];c[3]:=b[8];c[4]:=b[7];c[5]:=b[6];rec(c,l-1);end;
	end
else
	begin
	SetLength(TR,Length(tR)+1);
	TR[High(TR)]:=a;
	end;
end;
begin
GlSanCreateWnd(@Wnd,'Управление',GlSanKoor2fImport(130,270));
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(10,50),GlSanKoor2fImport(60,100),'+');
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(70,50),GlSanKoor2fImport(120,100),'-');
GlSanWndNewText(@Wnd,GlSanKoor2fImport(10,110),GlSanKoor2fImport(120,160),' ');
GlSanWndUserMove(@Wnd,3,GlSanKoor2fImport(width-10,0));
GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(Det));
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(10,170),GlSanKoor2fImport(120,210),'Вкл/Откл');
GlSanWndNewButton(@Wnd,GlSanKoor2fImport(10,220),GlSanKoor2fImport(120,260),'Вкл/Откл');
fillchar(a,sizeof(a),0);
for i:=1 to 5 do
	begin
	a[i].Import(cos(I*(2*PI/5)+0.0001+PI/2)*3+3,sIN(I*(2*PI/5)+0.0001+PI/2)*3+3,0);
	end;
SetLength(TR,0);
REC(a,det);
r1:=0;r2:=0;Zum:=1;Upzum:=0;LeftZum:=0;
repeat
gltranslatef(-3+LeftZum,-3+UpZum,-6*Zum);
glrotatef(r2,1,0,0);
glrotatef(r1,0,0,1);
glcolor4f(1,0.25,0,0.2);
if GlSanWndClickButton(@Wnd,3) then
	begin
	vt:=not VT;
	SetLength(TR,0);
	REC(a,det);
	end;
if GlSanWndClickButton(@Wnd,4) then
	begin
	vCCCP:=not VCCCP;
	end;
if GlSanWndClickButton(@Wnd,1) then
	begin
	Det:=Det+1;
	SetLength(TR,0);
	REC(a,det);
	GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(Det));
	end;
if GlSanWndClickButton(@Wnd,2) and (Det>1) then
	begin
	Det:=Det-1;
	SetLength(TR,0);
	REC(a,det);
	GlSanWndSetNewTittleText(@Wnd,1,GlSanStr(Det));
	end;
for i:=High(TR) downto Low(TR)  do
	begin
	glBegin(GL_LINE_StrIP);
	GlSanVertex3f(TR[i,1]);
	GlSanVertex3f(TR[i,2]);
	GlSanVertex3f(TR[i,3]);
	GlSanVertex3f(TR[i,4]);
	GlSanVertex3f(TR[i,5]);
	GlSanVertex3f(TR[i,1]);
	glEnd();
	end;
if VCCCP then
	begin
	glcolor4f(1,0,0,1);
	gllinewidth(300);
	GlSanOutTextS(GlSanKoorImport(a[5].x,a[5].y-2.5,a[5].z),'CCCP',0.6);
	end;
glloadidentity();
gltranslatef(LeftZum,UpZum,-6*Zum);
if GlSanMouseB(1) then
		begin
		UpZum+=GlSanMouseXY(1).y/(170);
		LeftZum-=GlSanMouseXY(1).x/(170);
		end;
case LongInt(SGMouseWheelVariable) of
1:Zum+=0.05;
-1:Zum-=0.05;
end;
until GlSanAfterUntil(27,false,bool);
GlSanKillWnd(@Wnd);
SetLength(TR,0);
end;

{
initialization
begin


end;
}
begin

end.
