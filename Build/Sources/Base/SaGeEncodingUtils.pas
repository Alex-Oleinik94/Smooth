{$INCLUDE SaGe.inc}

unit SaGeEncodingUtils;

interface

uses
	 SaGeBase
	;

procedure Windows1251ToUTF8(var Str: TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure UTF8ToWindows1251(var Str: TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure OEM866ToUTF8(var Str: TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure UTF8ToOEM866(var Str: TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure OEM866ToWindows1251(var Str: TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
procedure Windows1251ToOEM866(var Str: TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

//Это функции для отладки WinAPI функций, связанных с символами, получиными в SaGeContextWinAPI как коды клавиш
function SGWhatIsTheSimbol(const l : TSGInt32; const Shift : TSGBoolean = False ; const Caps : TSGBoolean = False) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGGetLanguage() : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGWhatIsTheSimbolRU(const l : TSGInt32; const Shift : TSGBoolean = False; const Caps : TSGBoolean = False) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
function SGWhatIsTheSimbolEN(const l : TSGInt32; const Shift : TSGBoolean = False; const Caps : TSGBoolean = False) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

function SGConvertAnsiToASCII(const S : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}

implementation

uses
	 StrMan
	
	{$IFDEF MSWINDOWS}
		,Windows
	{$ENDIF}
	;

const
	SGAnsiToASCII : packed array[TSGChar] of TSGChar = {Ansi - WINDOWS1251(CP1251); ASCII - CP866 }
		(#$00, #$01, #$02, #$03, #$04, #$05, #$06, #$07,   { $00 - $07 }
		 #$08, #$09, #$0a, #$0b, #$0c, #$0d, #$0e, #$0f,   { $08 - $0f }
		 #$10, #$11, #$12, #$13, #$14, #$15, #$16, #$17,   { $10 - $17 }
		 #$18, #$19, #$1a, #$1b, #$1c, #$1d, #$1e, #$1f,   { $18 - $1f }
		 #$20, #$21, #$22, #$23, #$24, #$25, #$26, #$27,   { $20 - $27 }
		 #$28, #$29, #$2a, #$2b, #$2c, #$2d, #$2e, #$2f,   { $28 - $2f }
		 #$30, #$31, #$32, #$33, #$34, #$35, #$36, #$37,   { $30 - $37 }
		 #$38, #$39, #$3a, #$3b, #$3c, #$3d, #$3e, #$3f,   { $38 - $3f }
		 #$40, #$41, #$42, #$43, #$44, #$45, #$46, #$47,   { $40 - $47 }
		 #$48, #$49, #$4a, #$4b, #$4c, #$4d, #$4e, #$4f,   { $48 - $4f }
		 #$50, #$51, #$52, #$53, #$54, #$55, #$56, #$57,   { $50 - $57 }
		 #$58, #$59, #$5a, #$5b, #$5c, #$5d, #$5e, #$5f,   { $58 - $5f }
		 #$60, #$61, #$62, #$63, #$64, #$65, #$66, #$67,   { $60 - $67 }
		 #$68, #$69, #$6a, #$6b, #$6c, #$6d, #$6e, #$6f,   { $68 - $6f }
		 #$70, #$71, #$72, #$73, #$74, #$75, #$76, #$77,   { $70 - $77 }
		 #$78, #$79, #$7a, #$7b, #$7c, #$7d, #$7e, #$7f,   { $78 - $7f }
		 '?' , '?' , '?' , '?' , '?' , '?' , '?' , '?' ,   { $80 - $87 }
		 '?' , '?' , '?' , '?' , '?' , '?' , '?' , '?' ,   { $88 - $8f }
		 '?' , '?' , '?' , '?' , '?' , '?' , '?' , '?' ,   { $90 - $97 }
		 '?' , '?' , '?' , '?' , '?' , '?' , '?' , '?' ,   { $98 - $9f }
		 #$ff, #$ad, #$9b, #$9c, '?' , #$9d, '?' , '?' ,   { $a0 - $a7 }
		 '?' , '?' , #$a6, #$ae, #$aa, '?' , '?' , '?' ,   { $a8 - $af }
		 #$f8, #$f1, #$fd, '?' , '?' , #$e6, '?' , #$fa,   { $b0 - $b7 }
		 '?' , '?' , #$a7, #$af, #$ac, #$ab, '?' , #$a8,   { $b8 - $bf }
		 '?' , '?' , '?' , '?' , #$8e, #$8f, #$92, #$80,   { $c0 - $c7 }
		 '?' , #$90, '?' , '?' , '?' , '?' , '?' , '?' ,   { $c8 - $cf }
		 '?' , #$a5, '?' , '?' , '?' , '?' , #$99, '?' ,   { $d0 - $d7 }
		 '?' , '?' , '?' , '?' , #$9a, '?' , '?' , #$e1,   { $d8 - $df }
		 #$85, #$a0, #$83, '?' , #$84, #$86, #$91, #$87,   { $e0 - $e7 }
		 #$8a, #$82, #$88, #$89, #$8d, #$a1, #$8c, #$8b,   { $e8 - $ef }
		 '?' , #$a4, #$95, #$a2, #$93, '?' , #$94, #$f6,   { $f0 - $f7 }
		 '?' , #$97, #$a3, #$96, #$81, '?' , '?' , #$98);  { $f8 - $ff }

function SGConvertAnsiToASCII(const S : TSGString) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGUInt32;
begin
Result := '';
for i := 1 to Length(S) do
	Result += SGAnsiToASCII[S[i]];
end;

function SGWhatIsTheSimbolEN(const l : TSGInt32; const Shift : TSGBoolean = False; const Caps : TSGBoolean = False) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SGWhatIsTheSimbolEN:='';
case l of
32:Result:=' ';
48:if Shift then Result:=')' else Result:='0';
49:if Shift then Result:='!' else Result:='1';
50:if Shift then Result:='@' else Result:='2';
51:if Shift then Result:='#' else Result:='3';
52:if Shift then Result:='$' else Result:='4';
53:if Shift then Result:='%' else Result:='5';
54:if Shift then Result:='^' else Result:='6';
55:if Shift then Result:='&' else Result:='7';
56:if Shift then Result:='*' else Result:='8';
57:if Shift then Result:='(' else Result:='9';
65:if Shift xor Caps then Result:='A' else Result:='a';
66:if Shift xor Caps then Result:='B' else Result:='b';
67:if Shift xor Caps then Result:='C' else Result:='c';
68:if Shift xor Caps then Result:='D' else Result:='d';
69:if Shift xor Caps then Result:='E' else Result:='e';
70:if Shift xor Caps then Result:='F' else Result:='f';
71:if Shift xor Caps then Result:='G' else Result:='g';
72:if Shift xor Caps then Result:='H' else Result:='h';
73:if Shift xor Caps then Result:='I' else Result:='i';
74:if Shift xor Caps then Result:='J' else Result:='j';
75:if Shift xor Caps then Result:='K' else Result:='k';
76:if Shift xor Caps then Result:='L' else Result:='l';
77:if Shift xor Caps then Result:='M' else Result:='m';
78:if Shift xor Caps then Result:='N' else Result:='n';
79:if Shift xor Caps then Result:='O' else Result:='o';
80:if Shift xor Caps then Result:='P' else Result:='p';
81:if Shift xor Caps then Result:='Q' else Result:='q';
82:if Shift xor Caps then Result:='R' else Result:='r';
83:if Shift xor Caps then Result:='S' else Result:='s';
84:if Shift xor Caps then Result:='T' else Result:='t';
85:if Shift xor Caps then Result:='U' else Result:='u';
86:if Shift xor Caps then Result:='V' else Result:='v';
87:if Shift xor Caps then Result:='W' else Result:='w';
88:if Shift xor Caps then Result:='X' else Result:='x';
89:if Shift xor Caps then Result:='Y' else Result:='y';
90:if Shift xor Caps then Result:='Z' else Result:='z';
186:if Shift then Result:=':' else Result:=';';
187:if Shift then Result:='+' else Result:='=';
188:if Shift then Result:='<' else Result:=',';
189:if Shift then Result:='_' else Result:='-';
190:if Shift then Result:='>' else Result:='.';
191:if Shift then Result:='?' else Result:='/';
192:if Shift then Result:='~' else Result:='`';
219:if Shift then Result:='{' else Result:='[';
220:if Shift then Result:='|' else Result:='\';
221:if Shift then Result:='}' else Result:=']';
222:if Shift then Result:='"' else Result:='"';
end;
end;

function SGWhatIsTheSimbolRU(const l : TSGInt32; const Shift : TSGBoolean = False; const Caps : TSGBoolean = False) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
begin
SGWhatIsTheSimbolRU:='';
case l of
32:Result:=' ';
48:if Shift then Result:=')' else Result:='0';
49:if Shift then Result:='!' else Result:='1';
50:if Shift then Result:='"' else Result:='2';
51:if Shift then Result:='№' else Result:='3';
52:if Shift then Result:=';' else Result:='4';
53:if Shift then Result:='%' else Result:='5';
54:if Shift then Result:='^' else Result:='6';
55:if Shift then Result:='?' else Result:='7';
56:if Shift then Result:='*' else Result:='8';
57:if Shift then Result:='(' else Result:='9';
65:if Shift xor Caps then Result:='Ф' else Result:='ф';
66:if Shift xor Caps then Result:='И' else Result:='и';
67:if Shift xor Caps then Result:='С' else Result:='с';
68:if Shift xor Caps then Result:='В' else Result:='в';
69:if Shift xor Caps then Result:='У' else Result:='у';
70:if Shift xor Caps then Result:='А' else Result:='а';
71:if Shift xor Caps then Result:='П' else Result:='п';
72:if Shift xor Caps then Result:='Р' else Result:='р';
73:if Shift xor Caps then Result:='Ш' else Result:='ш';
74:if Shift xor Caps then Result:='О' else Result:='о';
75:if Shift xor Caps then Result:='Л' else Result:='л';
76:if Shift xor Caps then Result:='Д' else Result:='д';
77:if Shift xor Caps then Result:='Ь' else Result:='ь';
78:if Shift xor Caps then Result:='Т' else Result:='т';
79:if Shift xor Caps then Result:='Щ' else Result:='щ';
80:if Shift xor Caps then Result:='З' else Result:='з';
81:if Shift xor Caps then Result:='Й' else Result:='й';
82:if Shift xor Caps then Result:='К' else Result:='к';
83:if Shift xor Caps then Result:='Ы' else Result:='ы';
84:if Shift xor Caps then Result:='Е' else Result:='е';
85:if Shift xor Caps then Result:='Г' else Result:='г';
86:if Shift xor Caps then Result:='М' else Result:='м';
87:if Shift xor Caps then Result:='Ц' else Result:='ц';
88:if Shift xor Caps then Result:='Ч' else Result:='ч';
89:if Shift xor Caps then Result:='Н' else Result:='н';
90:if Shift xor Caps then Result:='Я' else Result:='я';
186:if Shift xor Caps then Result:='Ж' else Result:='ж';
187:if Shift xor Caps then Result:='+' else Result:='=';
188:if Shift xor Caps then Result:='Б' else Result:='б';
189:if Shift then Result:='_' else Result:='-';
190:if Shift xor Caps then Result:='Ю' else Result:='ю';
191:if Shift then Result:=',' else Result:='.';
192:if Shift xor Caps then Result:='Ё' else Result:='ё';
219:if Shift xor Caps then Result:='Х' else Result:='х';
220:if Shift then Result:='/' else Result:='\';
221:if Shift xor Caps then Result:='Ъ' else Result:='ъ';
222:if Shift xor Caps then Result:='Э' else Result:='э';
end;
end;

function SGGetLanguage(): TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
{$IFDEF MSWINDOWS}
	var
		Layout : array [0..kl_namelength] of TSGChar;
	{$ENDIF}
begin
{$IFDEF MSWINDOWS}
	GetKeyboardLayoutname(Layout);
	if layout='00000409' then
		Result:='EN'
	else
		Result:='RU';
{$ELSE}
	Result:='EN';
	{$ENDIF}
end;

function SGWhatIsTheSimbol(const l : TSGInt32; const Shift : TSGBoolean = False; const Caps : TSGBoolean = False) : TSGString;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	Language : TSGString = '';
begin
Language := SGGetLanguage();
if Language = 'EN' then
	begin
	Result := SGWhatIsTheSimbolEN(l, Shift, Caps);
	end
else
	if Language='RU' then
		Result := SGWhatIsTheSimbolRU(l, Shift, Caps)
	else
		Result := TSGChar(l);
end;

procedure Windows1251ToUTF8(var Str: TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
const
  bRD0: TSGByte = ($C0 - $90);
  bRD1: TSGByte = ($F0 - $80);
var
  xCh, GStr, NStr: TSGString;
  xL, iFor: TSGInteger;
  xChr: TSGChar;
begin
  GStr := Str;
  NStr := '';
  xL := length(Str);
  for iFor := 1 to xL do begin
      xCh := #$20;
      xChr := GStr[iFor];
    if (xChr >= #$00) and (xChr <= #$7F) then begin
        xCh := xChr;
        case ord(xChr) of
          $11: xCh := #$E2#$97#$80;
          $10: xCh := #$E2#$96#$B6;
          $1E: xCh := #$E2#$96#$B2;
          $1F: xCh := #$E2#$96#$BC;
        end;
      end
    else if (xChr >= #$C0) and (xChr <= #$EF) then
        xCh := #$D0 + chr(ord(xChr) - bRD0)
      else if (xChr >= #$F0) and (xChr <= #$FF) then
          xCh := #$D1 + chr(ord(xChr) - bRD1)
        else
          case ord(xChr) of
            $80: xCh := #$D0#$82;
            $81: xCh := #$D0#$83;
            $82: xCh := #$E2#$80#$9A;
            $83: xCh := #$D1#$93;
            $84: xCh := #$E2#$80#$0E;
            $93: xCh := #$E2#$80#$9C;
            $94: xCh := #$E2#$80#$9D;
            $AB: xCh := #$C2#$AB;
            $BB: xCh := #$C2#$BB;
            $85: xCh := #$E2#$80#$A6;
            $86: xCh := #$E2#$80#$A0;
            $87: xCh := #$E2#$80#$A1;
            $88: xCh := #$E2#$82#$AC;
            $89: xCh := #$E2#$80#$B0;
            $8A: xCh := #$D0#$89;
            $8B: xCh := #$E2#$80#$B9;
            $9B: xCh := #$E2#$80#$BA;
            $8C: xCh := #$D0#$8A;
            $8D: xCh := #$D0#$8C;
            $8E: xCh := #$D0#$8B;
            $8F: xCh := #$D0#$8F;
            $90: xCh := #$D1#$92;
            $91: xCh := #$E2#$80#$98;
            $92: xCh := #$E2#$80#$99;
            $95: xCh := #$E2#$80#$A2;
            $96: xCh := #$E2#$80#$93;
            $97: xCh := #$E2#$80#$92;
            $AD: xCh := #$E2#$80#$94;
            $99: xCh := #$E2#$84#$A2;
            $9A: xCh := #$D1#$99;
            $9C: xCh := #$D1#$9A;
            $9D: xCh := #$D1#$9C;
            $9E: xCh := #$D1#$9B;
            $9F: xCh := #$D1#$9F;
            $A1: xCh := #$D0#$8E;
            $A2: xCh := #$D1#$9E;
            $A3: xCh := #$D0#$88;
            $A4: xCh := #$C2#$A4;
            $A5: xCh := #$D2#$90;
            $A6: xCh := #$C2#$A6;
            $A7: xCh := #$C2#$A7;
            $A8: xCh := #$D0#$81;
            $A9: xCh := #$C2#$A9;
            $AA: xCh := #$D0#$84;
            $AC: xCh := #$C2#$AC;
            $AF: xCh := #$D0#$87;
            $B0: xCh := #$C2#$B0;
            $B1: xCh := #$C2#$B1;
            $B2: xCh := #$D0#$86;
            $B3: xCh := #$D1#$96;
            $B4: xCh := #$D2#$91;
            $B5: xCh := #$C2#$B5;
            $B6: xCh := #$C2#$B6;
            $B7: xCh := #$C2#$B7;
            $B8: xCh := #$D1#$91;
            $B9: xCh := #$E2#$84#$96;
            $BA: xCh := #$D1#$94;
            $BC: xCh := #$D1#$98;
            $BD: xCh := #$D0#$85;
            $BE: xCh := #$D1#$95;
            $BF: xCh := #$D1#$97;
          end;
      NStr := NStr + xCh;
    end;
  Str := NStr;
end;

procedure UTF8ToWindows1251(var Str: TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
const
  bRD0: TSGByte = ($C0 - $90);
  bRD1: TSGByte = ($F0 - $80);
var
  GStr, NStr: TSGString;
  xChr, xP: TSGChar;
  xL, iFor: TSGInteger;
  xGr1, xGr2: TSGChar;
  bitn: Boolean = true;
begin
  xL := length(Str);
  GStr := Str;
  NStr := '';
  for iFor := 1 to xL do
    begin
      xChr := #$20;
      xP := GStr[iFor];
      if (xP >= #$00) and (xP <= #$7F) then
        begin
          xChr := xP;
          xGr1:= #$00;
          xGr2:= #$00;
        end
      else
        if (xP = #$C2) or (xP = #$D0) or (xP = #$D1) then
          begin
            xGr1 := xP;
            xGr2 := #$00;
            bitn := true;
          end
        else
          if xP = #$E2 then
            begin
              xGr1 := xP;
              xGr2 := #$00;
              bitn := false;
            end
          else
            if (xP >= #$80) and (xP <= #$BF) then
              if (not bitn) and (xGr2 = #$00) then
                  xGr2 := xP
              else
                begin
                  if xGr2 = #$00 then
                    begin
                    if xGr1 = #$D0 then
                      if (xP >= #$90) and (xP <= #$BF) then
                        xChr := chr(ord(xP) + brD0)
                      else
                        case ord(xP) of
                          $81: xChr := #$A8;
                          $82: xChr := #$80;
                          $83: xChr := #$81;
                          $84: xChr := #$AA;
                          $85: xChr := #$BD;
                          $86: xChr := #$B2;
                          $87: xChr := #$AF;
                          $88: xChr := #$A3;
                          $89: xChr := #$8A;
                          $8A: xChr := #$8C;
                          $8B: xChr := #$8E;
                          $8C: xChr := #$8D;
                          $8E: xChr := #$A1;
                          $8F: xChr := #$8F;
                        end
                    else
                      if xGr1 = #$D1 then
                        if (xP >= #$80) and (xP <= #$8F) then
                          xChr := chr(ord(xP) + bRD1)
                        else
                          case ord(xP) of
                            $91: xChr := #$B8;
                            $92: xChr := #$90;
                            $93: xChr := #$83;
                            $94: xChr := #$BA;
                            $95: xChr := #$BE;
                            $96: xChr := #$B3;
                            $97: xChr := #$BF;
                            $98: xChr := #$BC;
                            $99: xChr := #$9A;
                            $9A: xChr := #$9C;
                            $9B: xChr := #$9E;
                            $9C: xChr := #$9D;
                            $9E: xChr := #$A2;
                            $9F: xChr := #$9F;
                          end
                      else
                        if xGr1 = #$C2 then
                          case ord(xP) of
                            $A4: xChr := xP;
                            $A6: xChr := xP;
                            $A7: xChr := xP;
                            $A9: xChr := xP;
                            $AB: xChr := xP;
                            $AC: xChr := xP;
                            $B0: xChr := xP;
                            $B1: xChr := xP;
                            $B5: xChr := xP;
                            $B6: xChr := xP;
                            $B7: xChr := xP;
                            $BB: xChr := xP;
                          end;
                    end
                  else
                    case ord(xGr2) of
                      $82: if xP = #$AC then xChr := #$88;
                      $84: case ord(xP) of
                             $A2: xChr := #$99;
                             $96: xChr := #$B9;
                           end;
                      $80: case ord(xP) of
                             $92: xChr := #$97;
                             $93: xChr := #$96;
                             $94: xChr := #$AD;
                             $98: xChr := #$91;
                             $99: xChr := #$92;
                             $9A: xChr := #$82;
                             $9C: xChr := #$93;
                             $9D: xChr := #$94;
                             $A0: xChr := #$86;
                             $A1: xChr := #$87;
                             $A2: xChr := #$95;
                             $A6: xChr := #$85;
                             $B0: xChr := #$89;
                             $B9: xChr := #$8B;
                             $BA: xChr := #$9B;
                             $0E: xChr := #$84;
                           end;
                      $96: case ord(xP) of
                             $B2: xChr := #$1E;
                             $B6: xChr := #$10;
                             $BC: xChr := #$1F;
                           end;
                      $97: case ord(xP) of
                             $80: xChr := #$11;
                           end;
                    end;
                  xGr1 := #$00;
                end;
      if xGr1 = #$00 then
        NStr := NStr + xChr;
    end;
  Str := NStr;
end;

procedure OEM866ToUTF8(var Str: TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
const
  bRD0: TSGByte = ($90 - $80);
  bRD1: TSGByte = ($E0 - $80);
var
  xCh, GStr, NStr: TSGString;
  xL, iFor: TSGInteger;
  xChr: TSGChar;
begin
  GStr := Str;
  NStr := '';
  xL := length(Str);
  for iFor := 1 to xL do
    begin
      xCh := #$20;
      xChr := GStr[iFor];
    if (xChr >= #$00) and (xChr <= #$7F) then
      begin
        xCh := xChr;
        case ord(xChr) of
          $11: xCh := #$E2#$97#$80;
          $10: xCh := #$E2#$96#$B6;
          $1E: xCh := #$E2#$96#$B2;
          $1F: xCh := #$E2#$96#$BC;
        end;
      end
    else if (xChr >= #$80) and (xChr <= #$AF) then
        xCh := #$D0 + chr(ord(xChr) + bRD0)
      else if (xChr >= #$E0) and (xChr <= #$EF) then
          xCh := #$D1 + chr(ord(xChr) - bRD1)
        else
          case ord(xChr) of
            $B0: xCh := #$E2#$96#$91;
            $B1: xCh := #$E2#$96#$92;
            $B2: xCh := #$E2#$96#$93;
            $B3: xCh := #$E2#$94#$82;
            $B4: xCh := #$E2#$94#$A4;
            $B5: xCh := #$E2#$95#$A1;
            $B6: xCh := #$E2#$95#$A2;
            $B7: xCh := #$E2#$95#$96;
            $B8: xCh := #$E2#$95#$95;
            $B9: xCh := #$E2#$95#$A3;
            $BA: xCh := #$E2#$95#$91;
            $BB: xCh := #$E2#$95#$97;
            $BC: xCh := #$E2#$95#$9D;
            $BD: xCh := #$E2#$95#$9C;
            $BE: xCh := #$E2#$95#$9B;
            $BF: xCh := #$E2#$95#$AE;
            $C0: xCh := #$E2#$95#$B0;
            $C1: xCh := #$E2#$94#$B4;
            $C2: xCh := #$E2#$94#$AC;
            $C3: xCh := #$E2#$94#$9C;
            $C4: xCh := #$E2#$94#$80;
            $C5: xCh := #$E2#$94#$BC;
            $C6: xCh := #$E2#$95#$9E;
            $C7: xCh := #$E2#$95#$9F;
            $C8: xCh := #$E2#$95#$9A;
            $C9: xCh := #$E2#$95#$94;
            $CA: xCh := #$E2#$95#$A9;
            $CB: xCh := #$E2#$95#$A6;
            $CC: xCh := #$E2#$95#$A0;
            $CD: xCh := #$E2#$95#$90;
            $CE: xCh := #$E2#$95#$AC;
            $CF: xCh := #$E2#$95#$A7;
            $D0: xCh := #$E2#$95#$A8;
            $D1: xCh := #$E2#$95#$A4;
            $D2: xCh := #$E2#$95#$A5;
            $D3: xCh := #$E2#$95#$99;
            $D4: xCh := #$E2#$95#$98;
            $D5: xCh := #$E2#$95#$92;
            $D6: xCh := #$E2#$95#$93;
            $D7: xCh := #$E2#$95#$AB;
            $D8: xCh := #$E2#$95#$AA;
            $D9: xCh := #$E2#$95#$AF;
            $DA: xCh := #$E2#$95#$AD;
            $DB: xCh := #$E2#$96#$88;
            $DC: xCh := #$E2#$96#$84;
            $DD: xCh := #$E2#$96#$8C;
            $DE: xCh := #$E2#$96#$90;
            $DF: xCh := #$E2#$95#$80;
            $F0: xCh := #$D0#$81;
            $F1: xCh := #$D1#$91;
            $F2: xCh := #$D0#$84;
            $F3: xCh := #$D1#$94;
            $F4: xCh := #$D0#$87;
            $F5: xCh := #$D1#$97;
            $F6: xCh := #$D0#$8E;
            $F7: xCh := #$D1#$9E;
            $F8: xCh := #$C2#$B0;
            $F9: xCh := #$E2#$80#$A2;
            $FA: xCh := #$C2#$B7;
            $FB: xCh := #$E2#$8E#$B7;
            $FC: xCh := #$E2#$84#$96;
            $FD: xCh := #$C2#$A4;
            $FE: xCh := #$E2#$8E#$B7;
          end;
      NStr := NStr + xCh;
    end;
  Str := NStr;
end;

procedure UTF8ToOEM866(var Str: TSGString); {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
const
  bRD0: TSGByte = ($90 - $80);
  bRD1: TSGByte = ($E0 - $80);
var
  GStr, NStr: TSGString;
  xChr, xP: TSGChar;
  xL, iFor: TSGInteger;
  xGr1, xGr2: TSGChar;
  bitn: Boolean = true;

begin
  xL := length(Str);
  GStr := Str;
  NStr := '';
  for iFor := 1 to xL do begin
      xChr := #$20;
      xP := GStr[iFor];
      if (xP >= #$00) and (xP <= #$7F) then
        begin
          xChr := xP;
          xGr1:= #$00;
          xGr2:= #$00;
        end
      else if (xP = #$C2) or (xP = #$D0) or (xP = #$D1) then
          begin
            xGr1 := xP;
            xGr2 := #$00;
            bitn := true;
          end
        else
          if xP = #$E2 then
            begin
              xGr1 := xP;
              xGr2 := #$00;
              bitn := false;
            end
          else if (xP >= #$80) and (xP <= #$BF) then
              if (not bitn) and (xGr2 = #$00) then
                  begin
                    xGr2 := xP;
                  end
              else
                begin
                  if xGr2 = #$00 then
                    begin
                    if xGr1 = #$D0 then
                      if (xP >= #$90) and (xP <= #$BF) then
                        xChr := chr(ord(xP) - brD0)
                      else
                        case ord(xP) of
                          $81: xChr := #$F0;
                          $84: xChr := #$F2;
                          $87: xChr := #$F4;
                          $8E: xChr := #$F6;
                        end
                    else if xGr1 = #$D1 then
                        if (xP >= #$80) and (xP <= #$8F) then
                          xChr := chr(ord(xP) + bRD1)
                        else
                          case ord(xP) of
                            $91: xChr := #$F1;
                            $94: xChr := #$F3;
                            $97: xChr := #$F5;
                            $9E: xChr := #$F7;
                          end
                      else if xGr1 = #$C2 then
                          case ord(xP) of
                            $A4: xChr := #$FD;
                            $B0: xChr := #$F8;
                            $B7: xChr := #$FA;
                          end;
                    end
                  else
                    case ord(xGr2) of
                      $8E: if xP = #$B7 then xChr := #$FE;
                      $84: if xP = #$96 then xChr := #$FC;
                      $80: if xP = #$A2 then xChr := #$F9;
                      $94: case ord(xP) of
                             $80: xChr := #$C4;
                             $82: xChr := #$B3;
                             $9C: xChr := #$C3;
                             $A4: xChr := #$B4;
                             $AC: xChr := #$C2;
                             $B4: xChr := #$C1;
                             $BC: xChr := #$C5;
                           end;
                      $95: case ord(xP) of
                             $A1: xChr := #$B5;
                             $A2: xChr := #$B6;
                             $96: xChr := #$B7;
                             $95: xChr := #$B8;
                             $A3: xChr := #$B9;
                             $91: xChr := #$BA;
                             $97: xChr := #$BB;
                             $9D: xChr := #$BC;
                             $9C: xChr := #$BD;
                             $9B: xChr := #$BE;
                             $AE: xChr := #$BF;
                             $B0: xChr := #$C0;
                             $9E: xChr := #$C6;
                             $9F: xChr := #$C7;
                             $9A: xChr := #$C8;
                             $94: xChr := #$C9;
                             $A9: xChr := #$CA;
                             $A6: xChr := #$CB;
                             $A0: xChr := #$CC;
                             $90: xChr := #$CD;
                             $AC: xChr := #$CE;
                             $A7: xChr := #$CF;
                             $A8: xChr := #$D0;
                             $A4: xChr := #$D1;
                             $A5: xChr := #$D2;
                             $99: xChr := #$D3;
                             $98: xChr := #$D4;
                             $92: xChr := #$D5;
                             $93: xChr := #$D6;
                             $AB: xChr := #$D7;
                             $AA: xChr := #$D8;
                             $AF: xChr := #$D9;
                             $AD: xChr := #$DA;
                             $80: xChr := #$DF;
                           end;
                      $96: case ord(xP) of
                             $90: xChr := #$DE;
                             $91: xChr := #$B0;
                             $92: xChr := #$B1;
                             $93: xChr := #$B2;
                             $88: xChr := #$DB;
                             $84: xChr := #$DC;
                             $8C: xChr := #$DD;
                             $B2: xChr := #$1E;
                             $B6: xChr := #$10;
                             $BC: xChr := #$1F;
                           end;
                      $97: if xP=#$80 then xChr := #$11;
                    end;
                  xGr1 := #$00;
                end;
      if xGr1 = #$00 then
        NStr := NStr + xChr;
    end;
  Str := NStr;
end;

procedure OEM866ToWindows1251(var Str: TSGString);  {$IFDEF SUPPORTINLINE}inline;{$ENDIF}
const
  Ap : TSGByte = ($C0 - $80);
  rya: TSGByte = ($F0 - $E0);
var
  iFor, xL: TSGInteger;
  GStr, NStr: TSGString;
  xCh, xChr: TSGChar;
begin
  NStr := '';
  GStr := Str;
  xL := length(GStr);
  for iFor := 1 to xL do
    begin
      xChr := #$20;
      xCh := GStr[iFor];
      if (xCh >= #$00) and (xCh <= #$7F) then
        xChr := xCh
      else if (xCh >= #$80) and (xCh <= #$AF) then
          xChr := chr(ord(xCh) + Ap)
        else if (xCh >= #$E0) and (xCh <= #$EF) then
            xChr := chr(ord(xCh) + rya)
          else
            case ord(xCh) of
              $B0: xChr := #$A9;
              $B1: xChr := #$AE;
              $B2: xChr := #$B5;
              $B3: xChr := #$A6;
              $B4: xChr := #$A6;
              $B5: xChr := #$A6;
              $B6: xChr := #$A6;
              $B9: xChr := #$A6;
              $BA: xChr := #$A6;
              $C3: xChr := #$A6;
              $C6: xChr := #$A6;
              $C7: xChr := #$A6;
              $CC: xChr := #$A6;
              $B7: xChr := #$2B;
              $B8: xChr := #$2B;
              $BB: xChr := #$2B;
              $BC: xChr := #$2B;
              $BD: xChr := #$2B;
              $BE: xChr := #$2B;
              $BF: xChr := #$2B;
              $C0: xChr := #$2B;
              $C5: xChr := #$2B;
              $C8: xChr := #$2B;
              $C9: xChr := #$2B;
              $CE: xChr := #$2B;
              $D3: xChr := #$2B;
              $D4: xChr := #$2B;
              $D5: xChr := #$2B;
              $D6: xChr := #$2B;
              $D7: xChr := #$2B;
              $D8: xChr := #$2B;
              $D9: xChr := #$2B;
              $DA: xChr := #$2B;
              $C1: xChr := #$97;
              $C2: xChr := #$97;
              $C4: xChr := #$97;
              $CA: xChr := #$97;
              $CB: xChr := #$97;
              $CD: xChr := #$97;
              $CF: xChr := #$97;
              $D0: xChr := #$97;
              $D1: xChr := #$97;
              $D2: xChr := #$97;
              $F0: xChr := #$A8;
              $F1: xChr := #$B8;
              $F2: xChr := #$AA;
              $F3: xChr := #$BA;
              $F4: xChr := #$AF;
              $F5: xChr := #$BF;
              $F6: xChr := #$A1;
              $F7: xChr := #$A2;
              $F8: xChr := #$B0;
              $F9: xChr := #$95;
              $FA: xChr := #$B7;
              $FB: xChr := #$AC;
              $FC: xChr := #$B9;
              $FD: xChr := #$A4;
            end;
      NStr := NStr + xChr;
    end;
  Str := NStr;
end;

procedure Windows1251ToOEM866(var Str: TSGString);{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
const
  Ap: TSGByte = ($C0 - $80);
  rya: TSGByte = ($F0 - $E0);
var
  iFor, xL: TSGInteger;
  GStr, NStr, xChr: TSGString;
  xCh: TSGChar;
begin
  NStr := '';
  GStr := Str;
  xL := length(GStr);
  for iFor := 1 to xL do
    begin
      xChr := #$20;
      xCh := GStr[iFor];
      if (xCh >= #$00) and (xCh <= #$7F) then
        xChr := xCh
      else if (xCh >= #$C0) and (xCh <= #$EF) then
          xChr := chr(ord(xCh) - Ap)
        else if (xCh >= #$F0) and (xCh <= #$FF) then
            xChr := chr(ord(xCh) - rya)
          else
            case ord(xCh) of
              $82: xChr := #$2C;
              $84: xChr := #$22;
              $93: xChr := #$22;
              $94: xChr := #$22;
              $AB: xChr := #$22;
              $BB: xChr := #$22;
              $85: if xL < 254 then xChr := #$2E#$2E#$2E
                      else xChr := #$2E;
              $8B: xChr := #$3C;
              $9B: xChr := #$3E;
              $91: xChr := #$27;
              $92: xChr := #$27;
              $95: xChr := #$F9;
              $96: xChr := #$C4;
              $97: xChr := #$C4;
              $A1: xChr := #$F6;
              $A2: xChr := #$F7;
              $A3: xChr := #$4A;
              $A4: xChr := #$FD;
              $A6: xChr := #$7C;
              $A8: xChr := #$F0;
              $A9: xChr := #$B0;
              $AA: xChr := #$F2;
              $AC: xChr := #$FB;
              $AD: xChr := #$2D;
              $AE: xChr := #$C1;
              $AF: xChr := #$F4;
              $B0: xChr := #$F8;
              $B2: xChr := #$49;
              $B3: xChr := #$69;
              $B5: xChr := #$B2;
              $B7: xChr := #$FA;
              $B8: xChr := #$F1;
              $B9: xChr := #$FC;
              $BA: xChr := #$F3;
              $BC: xChr := #$6A;
              $BD: xChr := #$53;
              $BE: xChr := #$73;
              $BF: xChr := #$F5;
            end;
      NStr := NStr + xChr;
    end;
  Str := NStr;
end;

end.
