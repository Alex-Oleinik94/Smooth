unit crt;

interface

uses 
	SysUtils;

const
	white = 0;

procedure Gotoxy(const a,b:byte);inline;
function wherey():byte;inline;
procedure textcolor(const a:byte);inline;
procedure clrscr();inline;
procedure textbackground(const a:byte);inline;
function readkey():char;inline;
procedure Delay(const t : LongWord);inline;

implementation

procedure Delay(const t : LongWord);inline;
begin
Sleep(t);
end;

procedure clrscr();inline;begin end;
procedure Gotoxy(const a,b:byte);inline;begin end;
function wherey():byte;inline;begin end;
procedure textcolor(const a:byte);inline;begin end;
procedure textbackground(const a:byte);inline;begin end;
function readkey():char;inline;begin end;
end.
