program Find_in_pas;
uses crt,dos;
var
	ArWords:array of string = nil;
	ArFiles:array of string = nil;
	ArResults:array of packed record
		Kol:longint;
		Str:longint;
		Fail:string;
		end;
procedure ConstFiles;
var
	sr:dos.searchrec;
begin
findfirst('*.pas',$3F,sr);
while DosError<>18 do
	begin
	SetLength(ArFiles,Length(ArFiles)+1);
	ArFiles[High(ArFiles)]:=sr.name;
	findnext(sr);
	end;
findfirst('*.h',$3F,sr);
while DosError<>18 do
	begin
	SetLength(ArFiles,Length(ArFiles)+1);
	ArFiles[High(ArFiles)]:=sr.name;
	findnext(sr);
	end;
findfirst('*.cpp',$3F,sr);
while DosError<>18 do
	begin
	SetLength(ArFiles,Length(ArFiles)+1);
	ArFiles[High(ArFiles)]:=sr.name;
	findnext(sr);
	end;
findfirst('*.inc',$3F,sr);
while DosError<>18 do
	begin
	SetLength(ArFiles,Length(ArFiles)+1);
	ArFiles[High(ArFiles)]:=sr.name;
	findnext(sr);
	end;
findfirst('*.pp',$3F,sr);
while DosError<>18 do
	begin
	SetLength(ArFiles,Length(ArFiles)+1);
	ArFiles[High(ArFiles)]:=sr.name;
	findnext(sr);
	end;
findclose(sr);
end;

procedure ConstWords;
var
	l:longint;
	i:longint;
begin
textcolor(15);
write('Enter words quantity:');
textcolor(10);
readln(l);
textcolor(15);
SetLength(ArWords,l);
for i:=Low(ArWords) to High(ArWords) do
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
procedure FindInFiles;
var
	f:text;
	Oy:longint;
	i:longint;
	Str:string;
	ii:longint;
	iii:longint;
	iiii:longint;
	KolStr:longint = 0;
begin
writeln('Find was begining... Psess any key to stop him...');
Oy:=WhereY;
for i:=Low(ArFiles) to High(ArFiles) do
	begin
	Gotoxy(1,Oy);
	textcolor(15);
	write('Finded ');
	textcolor(10);
	write(Length(ArResults));
	textcolor(15);
	write(' Results. Process Files : ');
	textcolor(10);
	write(i+1);
	textcolor(15);
	write('/');
	textcolor(10);
	write(length(ArFiles));
	textcolor(15);
	writeln(' ...');
	assign(f,ArFiles[i]);
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
			SetLength(ArResults,Length(ArResults)+1);
			ArResults[High(ArResults)].Kol:=iii;
			ArResults[High(ArResults)].Str:=KolStr;
			ArResults[High(ArResults)].Fail:=ArFiles[i];
			end;
		end;
	close(f);
	if keypressed then
		break;
	end;
end;
procedure OutResults;
var
	f:text;
	i,ii,iii:longint;
begin
if Length(ArResults)>0 then
	begin
	textcolor(15);
	write('Your Results mast be in file "');
	textcolor(10);
	write('Your Results.txt');
	textcolor(15);
	writeln('" in this folder...');
	assign(f,'Your Results.txt');
	rewrite(f);
	writeln(f,'			Your find "',Length(ArWords),'" words:');
	for i:=Low(ArWords) to High(ArWords) do
		writeln(f,'	',i+1,') "',ArWords[i],'".');
	writeln(f,'			Finded:');
	for i:=Length(ArWords) downto 1 do
		begin
		ii:=-1;
		for iii:=Low(ArResults) to High(ArResults) do
			if ArResults[iii].Kol=i then
				ii:=0;
		if ii=0 then
			begin
			writeln(f,'			<',i,'sovpodeniy>');
			for iii:=Low(ArResults) to High(ArResults) do
				if ArResults[iii].Kol=i then
					begin
					writeln(f,'In file "',ArResults[iii].Fail,'" on string "',ArResults[iii].Str,'"...');
					end;
			end;
		end;
	close(f);
	end;
textcolor(8);
writeln('Press any key to out of this program...');
while not keypressed do 
	delay(1);
end;
begin
ConstWords;
ConstFiles;
SkanWords;
SetLength(ArResults,0);
FindInFiles;
OutResults;

end.
