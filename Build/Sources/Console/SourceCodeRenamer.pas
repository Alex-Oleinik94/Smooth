{$mode objfpc}

program SourceCodeRemaner;
uses
	 Classes
	,SysUtils
	;

function ReplaceWordInSourceString(const s, sw, r : string) : string;
var
	i : longword;
	w : string;
begin
Result := '';
w := '';
for i := 1 to Length(s) do
	begin
	if (w = '') then
		if (sw[1] = s[i]) then
			w += s[i]
		else
			Result += s[i]
	else if (Length(w) < Length(sw)) and (s[i] = sw[Length(w) + 1]) then
		begin
		w += s[i];
		if (Length(w) = Length(sw)) then
			begin
			Result += r;
			w := '';
			end;
		end
	else // if (Length(w) < Length(sw)) and (s[i] <> sw[Length(w) + 1]) then
		begin
		Result += w + s[i];
		w := '';
		end;
	end;
if (w <> '') then
	begin
	Result += w;
	w := '';
	end;
end;

function RenameSourceString(const s : string) : string;
begin
Result := ReplaceWordInSourceString(s, 'SaGe', 'Smooth');
Result := ReplaceWordInSourceString(Result, 'SG', 'S');
end;

procedure RenameSourceFile(FileName : string);
var
	FileStrings : array of string;
	inputf : TextFile;
	outputf : TextFile;
	s : string;
	i : longword;
begin
SetLength(FileStrings, 0);

Assign(inputf, FileName);
Reset(inputf);
while not eof(inputf) do
	begin
	readln(inputf, s);
	SetLength(FileStrings, Length(FileStrings) + 1);
	FileStrings[High(FileStrings)] := s;
	end;
Close(inputf);

for i := 0 to High(FileStrings) do
	FileStrings[i] := RenameSourceString(FileStrings[i]);

FileName := RenameSourceString(FileName);
Assign(outputf, FileName);
Rewrite(outputf);
for i := 0 to High(FileStrings) do
	writeln(outputf, FileStrings[i]);
Close(outputf);

SetLength(FileStrings, 0);
end;

procedure FindSourceCodeFiles(FileName : string);
var
	Found : Integer;
	SearchRec : TSearchRec;
	Catalog : String = '';
begin
if Catalog = '' then
	Catalog := '.';
if (not(Catalog[Length(Catalog)] in ['/','\'])) then
	Catalog += '\';
Found := FindFirst(Catalog + FileName, faAnyFile, SearchRec);
while Found = 0 do
	begin
	RenameSourceFile(SearchRec.Name);
	Found := FindNext(SearchRec);
	end;
SysUtils.FindClose(SearchRec);
end;

begin
FindSourceCodeFiles('SaGe*.pas');
FindSourceCodeFiles('Ex*.pas');
FindSourceCodeFiles('MakeInfo.ini');
end.