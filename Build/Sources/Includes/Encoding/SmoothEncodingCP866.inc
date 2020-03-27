class function TSEncodingDeterminer.IsCP866(const VString : TSString) : TSBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSUInt32;
begin
Result := True;
if Length(VString) > 0 then
	for i := 1 to Length(VString) do
		if  (TSByte(VString[i]) >= 128) and 
			(not (VString[i] in 'ñğ©‰æ–ã“ªŠ¥…­£ƒè˜é™§‡å•êšä”ë›¢‚ €¯à®«‹¤„¦†íïŸç—á‘¬Œ¨ˆâ’ìœ¡î.,!"ü;%:?*()_+#@$^&`~<>''" '#13#10)) then
			begin
			Result := False;
			break;
			end;
end;
