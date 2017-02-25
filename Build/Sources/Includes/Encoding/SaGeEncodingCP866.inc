class function TSGEncodingDeterminer.IsCP866(const VString : TSGString) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGUInt32;
begin
Result := True;
if Length(VString) > 0 then
	for i := 1 to Length(VString) do
		if  (TSGByte(VString[i]) >= 128) and 
			(not (VString[i] in 'ñğ©‰æ–ã“ªŠ¥…­£ƒè˜é™§‡å•êšä”ë›¢‚ €¯à®«‹¤„¦†íïŸç—á‘¬Œ¨ˆâ’ìœ¡î.,!"ü;%:?*()_+#@$^&`~<>''" '#13#10)) then
			begin
			Result := False;
			break;
			end;
end;
