{$INCLUDE SaGe.inc}

unit SaGeConsoleProgramFindInPas;

interface

uses
	 SaGeConsoleToolsBase
	;

procedure SGConsoleFindInPas(const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	 SaGeBase
	,SaGeStringUtils
	,SaGeFileUtils
	,SaGeVersion
	
	,Dos
	,Crt
	,Classes
	,StrMan
	;

procedure SGConsoleFindInPas(const VParams : TSGConcoleCallerParams = nil);
var
	ArWords:TSGStringList = nil;
	Oy:LongWord;
	PF,PS:LongWord;
	FArF:packed array of TFileStream = nil;
	i,ii:LongWord;
	ArF:TSGStringList = nil;
	FDir:string = '.';
var
	TempS,TempS2:String;
	NameFolder:string = '';
	ChisFi:LongWord = 0;
	StartingNow : Boolean = False;

procedure FindInFile(const VFile:String);
var
	f:text;
	Str:string;
	i:LongWord;
	ii:LongWord;
	iii:LongWord;
	iiii:LongWord;
	KolStr:LongWord = 0;
begin
PF+=1;
assign(f,VFile);
reset(f);
KolStr:=0;
while not eof(f) do
	begin
	KolStr+=1;
	readln(f,str);
	for ii:=1 to Length(str) do
		str[ii]:=UpCase(str[ii]);
	iii:=0;
	for ii:=Low(ArWords) to High(ArWords) do
		begin
		iiii:=Pos(ArWords[ii],str);
		if iiii<>0 then
			begin
			iii+=1;
			end;
		end;
	if iii<>0 then
		begin
		PS+=iii;
		if FArF=nil then
			iiii:=0
		else
			iiii:=Length(FArF);
		if iii>iiii then
			begin
			SetLength(FArF,iii);
			for i:=iiii to iii-1 do
				FArF[i]:=nil;
			end;
		if FArF[iii-1]=nil then
			FArF[iii-1]:=TFileStream.Create(NameFolder+DirectorySeparator+'Results of '+SGStr(iii)+' matches.txt',fmCreate);
		SGWriteStringToStream('"'+VFile+'" : "'+SGStr(KolStr)+'"'+SGWinEoln,FArF[iii-1],False);
		end;
	end;
close(f);

Gotoxy(1,Oy);
textcolor(15);
write('Finded ');
textcolor(10);
write(PS);
textcolor(15);
write(' matches. Processed ');
textcolor(10);
write(PF);
textcolor(15);
write(' files in ');
TextColor(14);
Write(ChisFi);
TextColor(15);
wRITElN(' derictories...');
end;

procedure DoFiles(const VDir:string);
var
	sr:dos.searchrec;
	I:LongWord;
begin
for i:=0 to High(ArF) do
	begin
	dos.findfirst(VDir+DirectorySeparator+'*.'+ArF[i],$3F,sr);
	while DosError<>18 do
		begin
		FindInFile(VDir+sr.name);
		dos.findnext(sr);
		end;
	dos.findclose(sr);
	end;
end;

procedure ConstWords;
var
	l:longint;
	i:longint;
	ii : LongWord;
begin
textcolor(15);
write('Enter words quantity:');
textcolor(10);
readln(l);
textcolor(15);
if (ArWords = nil) then
	ii := 0
else
	ii := Length(ArWords);
SetLength(ArWords,ii+l);
if (l>0) then
	for i:=ii to High(ArWords) do
		begin
		textcolor(15);
		write('Enter ',i+1,' word:');
		textcolor(10);
		readln(ArWords[i]);
		textcolor(15);
		end;
end;

procedure SkanWords;
var
	i:longint;
	ii:longint;
begin
for i:=Low(ArWords) to High(ArWords) do
	begin
	for ii:=1 to Length(ArWords[i]) do
		ArWords[i][ii]:=UpCase(ArWords[i][ii]);
	end;
i:=Low(ArWords);
while i<=High(ArWords) do
	begin
	if (ArWords[i]='') or (ArWords[i]=' ') or (ArWords[i]='  ') or (ArWords[i]='   ') or (ArWords[i]='    ') then
		begin
		for ii:=i to High(ArWords)-1 do
			ArWords[i]:=ArWords[i+1];
		SetLength(ArWords,Length(ArWords)-1);
		end;
	i+=1;
	end;
end;

procedure DoDirectories(const VDir : TSGString);
var
	sr:dos.searchrec;
begin
DoFiles(VDir + DirectorySeparator);
dos.findfirst(VDir+DirectorySeparator+'*',$10,sr);
while DosError<>18 do
	begin
	if (sr.name<>'.') and (sr.name<>'..') and (not(SGFileExists(VDir + DirectorySeparator + Sr.Name))) then
		BEGIN
		ChisFi+=1;
		DoDirectories(VDir + DirectorySeparator + Sr.Name);
		END;
	dos.findnext(sr);
	end;
dos.findclose(sr);
end;

begin
SGPrintEngineVersion();

SetLength(ArF,13);
ArF[0]:='pas';
ArF[1]:='pp';
ArF[2]:='inc';
ArF[3]:='cpp';
ArF[4]:='cxx';
ArF[5]:='h';
ArF[6]:='hpp';
ArF[7]:='hxx';
ArF[8]:='c';
ArF[9]:='html';
ArF[10]:='bat';
ArF[11]:='cmd';
ArF[12]:='sh';
textcolor(15);

if SGCountConsoleParams(VParams) <> 0 then
	for i := 0 to SGCountConsoleParams(VParams) - 1 do
		begin
		TempS := SGUpCaseString(StringTrimLeft(VParams[i],'-'));
		if TempS <> SGUpCaseString(VParams[i]) then
			begin
			if (Length(TempS)>2) or (TempS='H') then
				if (TempS[1]='F') and (TempS[2]='D') then
					begin
					TempS2:='';
					for ii:=3 to Length(TempS) do
						TempS2+=TempS[ii];
					while (Length(TempS2)>0) and ((TempS2[Length(TempS2)]='\') or (TempS2[Length(TempS2)]='/')) do
						SetLength(TempS2,Length(TempS2)-1);
					if TempS2='' then
						TempS2:='.';
					FDir:=TempS2;
					Write('Selected find directory "');TextColor(14);Write(FDir);TextColor(15);WriteLn('".');
					end
				else if (TempS='VIEWEXP') then
					begin
					Write('Finding expansion:');textColor(14);Write('{');
					for ii:=0 to High(ArF) do
						begin
						TextColor(13);Write(ArF[ii]);TextColor(14);
						if ii<>High(ArF) then
							Write(',');
						end;
					TextColor(14);WriteLn('}');TextColor(15);
					end
				else if (TempS='HELP') or (TempS='H') then
					begin
					WriteLn('This is help for "Find in pas".');
					Write('    -FD');TextColor(13);Write('($directory)');TextColor(15);WriteLn(' : for change find directory.');
					WriteLn('    -H; -HELP : for run help.');
					WriteLn('    -VIEWEXP : for view expansion for find');
					Exit;
					end
				else if (Length(TempS)>4) and (TempS[1]='W')and (TempS[2]='O')and (TempS[3]='R')and (TempS[4]='D') then
					begin
					if (ArWords = nil) then
						SetLength(ArWords,1)
					else
						SetLength(ArWords,Length(ArWords)+1);

					if (TempS[5] = '"') then
						begin
						TempS2 := '';
						for ii := 6 to Length(TempS)-1 do
							TempS2+=TempS[ii];
						end
					else
						begin
						TempS2 := '';
						for ii := 5 to Length(TempS) do
							TempS2+=TempS[ii];
						end;
					ArWords[High(ArWords)] := TempS2;
					TempS2:='';
					end
				else if (TempS='START') then
					begin
					StartingNow := True;
					end
				else
					WriteLn('FindInPas : error : comand syntax "',VParams[i],'"')
			else
				WriteLn('FindInPas : error : comand syntax "',VParams[i],'"');
			end
		else
			WriteLn('FindInPas : error : simbol "',VParams[i],'"');
		end;

PF:=0;PS:=0;OY:=0;
if (not StartingNow) then
	ConstWords();
if Length(ArWords) <> 0 then
	begin
	NameFolder := SGFreeDirectoryName('Find In Pas Results', 'Part');
	SGMakeDirectory(NameFolder);
	Write('Created results directory "');TextColor(14);Write(NameFolder);TextColor(15);WriteLn('".');
	SkanWords();
	WriteLn('Find was begining... Psess any key to stop him...');
	Oy:=WhereY;
	DoDirectories(FDir);
	if FArF<>nil then
		begin
		for i:=0 to High(FArF) do
			if FArF[i]<>nil then
				begin
				FArF[i].Destroy;
				end;
		SetLength(FArF,0);
		end;
	end;
if PS=0 then
	begin
	if Length(ArWords)<>0 then begin TextColor(12);Writeln('Matches don''t exists...'); end;
	if SGExistsDirectory(NameFolder) then
		begin
		RMDIR(NameFolder);
		TextColor(15);
		Write('Deleted results directory "');
		TextColor(14);
		Write(NameFolder);
		TextColor(15);
		WriteLn('".');
		end;
	end;
SetLength(ArF,0);
SetLength(ArWords,0);
end;

end.
