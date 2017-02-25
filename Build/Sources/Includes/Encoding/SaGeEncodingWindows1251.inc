class function TSGEncodingDeterminer.IsWindows1251(const VString : TSGString) : TSGBoolean;{$IFDEF SUPPORTINLINE}inline;{$ENDIF}
var
	i : TSGUInt32;
begin
Result := True;
if Length(VString) > 0 then
	for i := 1 to Length(VString) do
		if  (TSGByte(VString[i]) >= 128) and 
			(not (VString[i] in '¸¨éÉöÖóÓêÊåÅíÍãÃøØùÙçÇõÕúÚôÔûÛâÂàÀïÏğĞîÎëËäÄæÆıİÿß÷×ñÑìÌèÈòÒüÜáÁşŞ.,!"¹;%:?*()_+#@$^&`~<>''" '#13#10)) then
			begin
			Result := False;
			break;
			end;
end;
