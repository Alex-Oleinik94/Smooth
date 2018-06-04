{$INCLUDE SaGe.inc}

unit SaGeConsoleProgramUSMBIOS;

interface

uses
	 SaGeBase
	,SaGeConsoleCaller
	;

procedure SGConsoleUSMBIOS(const VParams : TSGConcoleCallerParams = nil);

implementation

uses
	Classes,
	TypInfo,
	SysUtils,
	uSMBIOS,
	Crt
	
	,SaGeVersion
	,SaGeConsoleTools
	,SaGeLog
	;


function SetToString(Info: PTypeInfo; const Value): String;
var
  LTypeInfo  : PTypeInfo;
  LIntegerSet: TIntegerSet;
  I: Integer;
 
begin
  Result := '';
 
    Integer(LIntegerSet) := 0;
    case GetTypeData(Info)^.OrdType of
      otSByte, otUByte: Integer(LIntegerSet)  := Byte(Value);
      otSWord, otUWord: Integer(LIntegerSet)  := Word(Value);
      otSLong, otULong: Integer(LIntegerSet)  := Integer(Value);
    end;
 
  LTypeInfo  := GetTypeData(Info)^.CompType{$IFNDEF FPC}^{$ENDIF};
  for I := 0 to SizeOf(Integer) * 8 - 1 do
    if I in LIntegerSet then
    begin
      if Result <> '' then Result := Result + ',';
      Result := Result + GetEnumName(LTypeInfo, I);
    end;
end;
 
 
procedure GetProcessorInfo;
Var
  SMBios             : TSMBios;
  LProcessorInfo     : TProcessorInformation;
  LSRAMTypes         : TCacheSRAMTypes;
begin
  SMBios:=TSMBios.Create;
  try
      TextColor(10);
      WriteLn('Processor Information');
      TextColor(7);
      if SMBios.HasProcessorInfo then
      for LProcessorInfo in SMBios.ProcessorInfo do
      begin
        WriteLn('Manufacturer       '+LProcessorInfo.ProcessorManufacturerStr);
        WriteLn('Socket Designation '+LProcessorInfo.SocketDesignationStr);
        WriteLn('Type               '+LProcessorInfo.ProcessorTypeStr);
        WriteLn('Familiy            '+LProcessorInfo.ProcessorFamilyStr);
        WriteLn('Version            '+LProcessorInfo.ProcessorVersionStr);
        WriteLn(Format('Processor ID       %x',[LProcessorInfo.RAWProcessorInformation^.ProcessorID]));
        WriteLn(Format('Voltaje            %n',[LProcessorInfo.GetProcessorVoltaje]));
        WriteLn(Format('External Clock     %d  Mhz',[LProcessorInfo.RAWProcessorInformation^.ExternalClock]));
        WriteLn(Format('Maximum processor speed %d  Mhz',[LProcessorInfo.RAWProcessorInformation^.MaxSpeed]));
        WriteLn(Format('Current processor speed %d  Mhz',[LProcessorInfo.RAWProcessorInformation^.CurrentSpeed]));
        WriteLn('Processor Upgrade   '+LProcessorInfo.ProcessorUpgradeStr);
        WriteLn(Format('External Clock     %d  Mhz',[LProcessorInfo.RAWProcessorInformation^.ExternalClock]));
 
        if SMBios.SmbiosVersion>='2.3' then
        begin
          WriteLn('Serial Number      '+LProcessorInfo.SerialNumberStr);
          WriteLn('Asset Tag          '+LProcessorInfo.AssetTagStr);
          WriteLn('Part Number        '+LProcessorInfo.PartNumberStr);
          if SMBios.SmbiosVersion>='2.5' then
          begin
            WriteLn(Format('Core Count         %d',[LProcessorInfo.RAWProcessorInformation^.CoreCount]));
            WriteLn(Format('Cores Enabled      %d',[LProcessorInfo.RAWProcessorInformation^.CoreEnabled]));
            WriteLn(Format('Threads Count      %d',[LProcessorInfo.RAWProcessorInformation^.ThreadCount]));
            WriteLn(Format('Processor Characteristics %.4x',[LProcessorInfo.RAWProcessorInformation^.ProcessorCharacteristics]));
          end;
        end;
        TextColor(1);Write('Press ENTER.');TextColor(7);ReadLn();
 
        if (LProcessorInfo.RAWProcessorInformation^.L1CacheHandle>0) and (LProcessorInfo.L2Chache<>nil)  then
        begin
          TextColor(10);
          WriteLn('L1 Cache Handle Info');
          TextColor(14);
          WriteLn('--------------------');
          TextColor(7);
          WriteLn('  Socket Designation    '+LProcessorInfo.L1Chache.SocketDesignationStr);
          WriteLn(Format('  Cache Configuration   %.4x',[LProcessorInfo.L1Chache.RAWCacheInformation^.CacheConfiguration]));
          WriteLn(Format('  Maximum Cache Size    %d Kb',[LProcessorInfo.L1Chache.GetMaximumCacheSize]));
          WriteLn(Format('  Installed Cache Size  %d Kb',[LProcessorInfo.L1Chache.GetInstalledCacheSize]));
          LSRAMTypes:=LProcessorInfo.L1Chache.GetSupportedSRAMType;
          WriteLn(Format('  Supported SRAM Type   [%s]',[SetToString(TypeInfo(TCacheSRAMTypes), LSRAMTypes)]));
          LSRAMTypes:=LProcessorInfo.L1Chache.GetCurrentSRAMType;
          WriteLn(Format('  Current SRAM Type     [%s]',[SetToString(TypeInfo(TCacheSRAMTypes), LSRAMTypes)]));
 
          WriteLn(Format('  Error Correction Type %s',[ErrorCorrectionTypeStr[LProcessorInfo.L1Chache.GetErrorCorrectionType]]));
          WriteLn(Format('  System Cache Type     %s',[SystemCacheTypeStr[LProcessorInfo.L1Chache.GetSystemCacheType]]));
          WriteLn(Format('  Associativity         %s',[LProcessorInfo.L1Chache.AssociativityStr]));
        end;
 
        if (LProcessorInfo.RAWProcessorInformation^.L2CacheHandle>0)  and (LProcessorInfo.L2Chache<>nil)  then
        begin
          TextColor(10);
          WriteLn('L2 Cache Handle Info');
          TextColor(14);
          WriteLn('--------------------');
          TextColor(7);
          WriteLn('  Socket Designation    '+LProcessorInfo.L2Chache.SocketDesignationStr);
          WriteLn(Format('  Cache Configuration   %.4x',[LProcessorInfo.L2Chache.RAWCacheInformation^.CacheConfiguration]));
          WriteLn(Format('  Maximum Cache Size    %d Kb',[LProcessorInfo.L2Chache.GetMaximumCacheSize]));
          WriteLn(Format('  Installed Cache Size  %d Kb',[LProcessorInfo.L2Chache.GetInstalledCacheSize]));
          LSRAMTypes:=LProcessorInfo.L2Chache.GetSupportedSRAMType;
          WriteLn(Format('  Supported SRAM Type   [%s]',[SetToString(TypeInfo(TCacheSRAMTypes), LSRAMTypes)]));
          LSRAMTypes:=LProcessorInfo.L2Chache.GetCurrentSRAMType;
          WriteLn(Format('  Current SRAM Type     [%s]',[SetToString(TypeInfo(TCacheSRAMTypes), LSRAMTypes)]));
 
          WriteLn(Format('  Error Correction Type %s',[ErrorCorrectionTypeStr[LProcessorInfo.L2Chache.GetErrorCorrectionType]]));
          WriteLn(Format('  System Cache Type     %s',[SystemCacheTypeStr[LProcessorInfo.L2Chache.GetSystemCacheType]]));
          WriteLn(Format('  Associativity         %s',[LProcessorInfo.L2Chache.AssociativityStr]));
        end;
 
        if (LProcessorInfo.RAWProcessorInformation^.L3CacheHandle>0) and (LProcessorInfo.L3Chache<>nil) then
        begin
          TextColor(10);
          WriteLn('L3 Cache Handle Info');
          TextColor(14);
          WriteLn('--------------------');
          TextColor(7);
          WriteLn('  Socket Designation    '+LProcessorInfo.L3Chache.SocketDesignationStr);
          WriteLn(Format('  Cache Configuration   %.4x',[LProcessorInfo.L3Chache.RAWCacheInformation^.CacheConfiguration]));
          WriteLn(Format('  Maximum Cache Size    %d Kb',[LProcessorInfo.L3Chache.GetMaximumCacheSize]));
          WriteLn(Format('  Installed Cache Size  %d Kb',[LProcessorInfo.L3Chache.GetInstalledCacheSize]));
          LSRAMTypes:=LProcessorInfo.L3Chache.GetSupportedSRAMType;
          WriteLn(Format('  Supported SRAM Type   [%s]',[SetToString(TypeInfo(TCacheSRAMTypes), LSRAMTypes)]));
          LSRAMTypes:=LProcessorInfo.L3Chache.GetCurrentSRAMType;
          WriteLn(Format('  Current SRAM Type     [%s]',[SetToString(TypeInfo(TCacheSRAMTypes), LSRAMTypes)]));
 
          WriteLn(Format('  Error Correction Type %s',[ErrorCorrectionTypeStr[LProcessorInfo.L3Chache.GetErrorCorrectionType]]));
          WriteLn(Format('  System Cache Type     %s',[SystemCacheTypeStr[LProcessorInfo.L3Chache.GetSystemCacheType]]));
          WriteLn(Format('  Associativity         %s',[LProcessorInfo.L3Chache.AssociativityStr]));
        end;
      end
      else
      Writeln('No Processor Info was found');
  finally
   SMBios.Free;
  end;
end;   

procedure SGConsoleUSMBIOS(const VParams : TSGConcoleCallerParams = nil);
begin
if (VParams = nil) or (Length(VParams) = 0) then
	GetProcessorInfo
else
	begin
	SGPrintEngineVersion();
	SGHint('Params is not allowed here!');
	end;
end;

initialization
begin
SGOtherConsoleCaller.AddComand('Other tools', @SGConsoleUSMBIOS, ['usmbios'], 'Launch uSMBIOS tool for get processor info');
end;

end.
